#' Build a co-occurrence network from any field
#'
#' With one field, entities are linked when they co-occur in the same
#' document. With `by`, entities are linked when they share values of the
#' `by` field across documents.
#'
#' Fields can be list-columns (already split) or character columns with
#' delimiters (auto-split via `sep`).
#'
#' @param data A data frame with column `id` and the specified field(s).
#' @param field Character. The entity field — determines what the nodes are.
#' @param by Character or `NULL`. What links the nodes. If `NULL` (default),
#'   entities are linked by co-occurring in the same document. If specified,
#'   entities are linked when they share values from the `by` field.
#' @param sep Character or `NULL`. Delimiter for splitting character columns.
#'   Default `";"`. Set to `NULL` if columns are already list-columns.
#' @param counting Character. Counting method. Default `"full"`.
#' @param similarity Character. Normalization method. Default `"none"`.
#' @param threshold Numeric. Minimum edge weight. Default 0.
#' @param min_occur Integer. Minimum entity frequency. Default 1.
#' @param top_n Integer or NULL. Return only the top n edges by weight.
#'   Default NULL (all edges).
#' @inheritParams author_network
#'
#' @return Depends on `format`: a `bibnets_network` data frame (default),
#'   a Gephi-ready data frame, an igraph graph, a cograph_network, or a
#'   sparse matrix.
#'
#' @export
#' @examples
#' data(biblio_data)
#'
#' # Co-occurrence: keywords appearing in the same document
#' conetwork(biblio_data, "keywords")
#'
#' # Authors linked by shared keywords
#' conetwork(biblio_data, "authors", by = "keywords")
#'
#' # Keywords linked by shared authors
#' conetwork(biblio_data, "keywords", by = "authors")
#'
#' # Journals linked by shared references (= journal coupling)
#' conetwork(biblio_data, "journal", by = "references", similarity = "cosine")
#'
#' # Auto-splits semicolon-delimited string columns
#' d <- data.frame(id = 1:3, tags = c("ml; dl; nlp", "ml; cv", "dl; cv"))
#' conetwork(d, "tags")
conetwork <- function(data,
                       field,
                       by = NULL,
                       sep = ";",
                       counting = "full",
                       similarity = "none",
                       threshold = 0,
                       min_occur = 1L,
                       top_n = NULL,
                       self_loops = FALSE,
                       deduplicate = TRUE,
                       format = "edgelist",
                       strip_quotes = TRUE,
                       id = NULL) {
  data <- resolve_id(data, id)
  check_data(data, field)
  check_choice(counting, position_independent_counts(), "counting")
  check_choice(similarity, c("none", "association", "cosine", "jaccard",
                              "inclusion", "equivalence"), "similarity")
  check_format(format)

  data <- ensure_list_column(data, field, sep, strip_quotes)

  result <- if (is.null(by)) {
    ## Co-occurrence within one field (same document)
    B <- build_bipartite(data, field = field, min_freq = min_occur,
                         deduplicate = deduplicate, strip_quotes = strip_quotes)
    B <- apply_counting(B, counting = counting, network_type = "symmetric")
    multiply_bipartite(B, mode = "columns", similarity = similarity,
                       threshold = threshold, top_n = top_n,
                       self_loops = self_loops)
  } else {
    ## Entities linked by shared values from `by` field
    if (!by %in% names(data))
      stop("Column '", by, "' not found in data.", call. = FALSE)
    data <- ensure_list_column(data, by, sep, strip_quotes)
    build_by_network(data, field = field, by = by,
                     counting = counting, similarity = similarity,
                     threshold = threshold, min_occur = min_occur,
                     top_n = top_n, self_loops = self_loops,
                     deduplicate = deduplicate, strip_quotes = strip_quotes)
  }

  net_type <- if (is.null(by)) {
    paste0(field, "_co_occurrence")
  } else {
    paste0(field, "_by_", by)
  }
  as_bibnets_network(result, network_type = net_type,
                      counting = counting, similarity = similarity,
                      format = format)
}


#' Build a network where entities share values from another field
#' @keywords internal
build_by_network <- function(data, field, by, counting, similarity,
                              threshold, min_occur, top_n = NULL,
                              self_loops = FALSE, deduplicate = TRUE,
                              strip_quotes = TRUE) {
  field_col <- data[[field]]
  by_col <- data[[by]]

  ## Expand field → (doc_idx, entity)
  if (is.list(field_col)) {
    f_doc <- rep(seq_len(nrow(data)), lengths(field_col))
    f_val <- unlist(field_col, use.names = FALSE)
  } else {
    f_doc <- seq_len(nrow(data))
    f_val <- as.character(field_col)
  }

  ## Expand by → (doc_idx, by_value)
  if (is.list(by_col)) {
    b_doc <- rep(seq_len(nrow(data)), lengths(by_col))
    b_val <- unlist(by_col, use.names = FALSE)
  } else {
    b_doc <- seq_len(nrow(data))
    b_val <- as.character(by_col)
  }

  ## Clean
  f_val <- toupper(trimws(as.character(f_val)))
  b_val <- toupper(trimws(as.character(b_val)))
  keep_f <- !is.na(f_val) & nchar(f_val) > 0
  f_doc <- f_doc[keep_f]; f_val <- f_val[keep_f]
  keep_b <- !is.na(b_val) & nchar(b_val) > 0
  b_doc <- b_doc[keep_b]; b_val <- b_val[keep_b]

  ## Frequency filter on field entities
  if (min_occur > 1L) {
    freq <- table(f_val)
    keep <- f_val %in% names(freq[freq >= min_occur])
    f_doc <- f_doc[keep]; f_val <- f_val[keep]
  }

  ## Join: for each entity, collect all by-values through shared docs
  f_df <- data.frame(doc = f_doc, entity = f_val, stringsAsFactors = FALSE)
  b_df <- data.frame(doc = b_doc, by_val = b_val, stringsAsFactors = FALSE)
  pairs <- merge(f_df, b_df, by = "doc")

  if (nrow(pairs) == 0L) {
    return(data.frame(from = character(0), to = character(0),
                      weight = numeric(0), count = integer(0),
                      stringsAsFactors = FALSE))
  }

  ## Unique entity × by_value pairs
  pairs <- unique(pairs[, c("entity", "by_val")])

  ## Aggregate per entity: which by-values does each entity have?
  agg <- stats::aggregate(by_val ~ entity, data = pairs,
                           FUN = function(x) list(unique(x)))
  agg_df <- data.frame(id = agg$entity, stringsAsFactors = FALSE)
  agg_df[["values"]] <- agg$by_val

  ## Build bipartite: entities × by_values, then project to entity × entity
  B <- build_bipartite(agg_df, field = "values", min_freq = 1L,
                       deduplicate = deduplicate, strip_quotes = strip_quotes)
  B <- apply_counting(B, counting = counting, network_type = "symmetric")
  multiply_bipartite(B, mode = "rows", similarity = similarity,
                     threshold = threshold, top_n = top_n,
                     self_loops = self_loops)
}


#' Ensure a column is a list-column, splitting if needed
#'
#' @param strip_quotes Logical. If `TRUE` (default), surrounding quote
#'   characters and whitespace are removed from every entity (e.g. a
#'   quoted CSV value `"Alice"` becomes `Alice`). See
#'   [strip_surrounding_quotes()].
#' @keywords internal
ensure_list_column <- function(data, field, sep = ";", strip_quotes = TRUE) {
  col <- data[[field]]
  if (!is.list(col) && !is.null(sep)) {
    parts <- split_field(col, sep = sep)
    warn_if_sep_mismatch(col, parts, field = field, sep = sep)
    data[[field]] <- parts
  } else if (!is.list(col)) {
    data[[field]] <- as.list(as.character(col))
  }
  if (strip_quotes) {
    data[[field]] <- lapply(data[[field]], strip_surrounding_quotes)
  }
  data
}


#' Warn when a separator likely failed to split a multi-entity column
#'
#' Splitting with the wrong separator silently yields one "entity" per row
#' (e.g., a whole author byline as a single node). Heuristic: no row split
#' into more than one entity, yet most non-empty strings contain a common
#' *structural* delimiter.
#'
#' Only structural delimiters (`";"`, `"|"`, tab) are considered, because
#' they essentially never occur inside a single legitimate label. Commas
#' and `" and "` are deliberately excluded: they appear inside valid
#' single values (e.g. `"Last, First"` author names, one-reference-per-row
#' citation strings, or organisations like `"Smith and Sons"`), so warning
#' on them would mislead users with correct data.
#' @keywords internal
warn_if_sep_mismatch <- function(col, parts, field, sep) {
  if (any(lengths(parts) > 1L)) return(invisible(NULL))
  strings <- as.character(col)
  strings <- strings[!is.na(strings) & nchar(trimws(strings)) > 0]
  if (length(strings) < 2L) return(invisible(NULL))
  candidates <- setdiff(c(";", "|", "\t"), sep)
  if (length(candidates) == 0L) return(invisible(NULL))
  hits <- vapply(candidates, function(s) {
    mean(grepl(s, strings, fixed = TRUE))
  }, numeric(1))
  if (any(hits >= 0.5)) {
    alt <- candidates[which.max(hits)]
    alt_label <- if (alt == "\t") "\\t" else alt
    warning(sprintf(
      paste0("Splitting column '%s' on sep = \"%s\" produced no ",
             "multi-entry rows, but most values contain \"%s\". ",
             "If entries are separated by \"%s\", pass that as sep."),
      field, sep, alt_label, alt_label), call. = FALSE)
  }
  invisible(NULL)
}
