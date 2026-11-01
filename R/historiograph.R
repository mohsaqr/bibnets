#' Compute local citation scores
#'
#' Counts how many times each document is cited by other documents
#' within the dataset.
#'
#' @param data A data frame with one row per work and a references column
#'   (list-column or delimited string) whose values use the same identifiers
#'   as the works. An `id` column is optional (see `id`). Optionally `year`,
#'   `title`, `journal`, `doi`, `cited_by_count`.
#' @param references Character. Name of the column containing cited references.
#'   Default `"references"`.
#' @param sep Character. Separator used to split the references column when it is a plain
#'   character column. Default `";"`.
#' @param strip_quotes Logical. If `TRUE` (default), surrounding quote
#'   characters are removed from each reference.
#' @param id Optional. Name of the column to use as the work identifier.
#'   If `NULL` (default), an existing `id` column is used when present,
#'   otherwise row numbers are used.
#'
#' @return A data frame with one row per document, sorted by decreasing
#'   `lcs`, with columns:
#'   \describe{
#'     \item{`id`}{Document identifier (character).}
#'     \item{`lcs`}{Local Citation Score (integer): times cited by other
#'       documents in the dataset.}
#'     \item{`gcs`}{Global Citation Score (integer): `cited_by_count`; only
#'       when that column is present.}
#'   }
#'   followed by `year` (integer), `title`, `journal` and `doi` when present
#'   in the input.
#'
#' @export
#' @examples
#' data(biblio_data)
#' local_citations(biblio_data)
local_citations <- function(data, references = "references", sep = ";",
                            strip_quotes = TRUE, id = NULL) {
  data <- resolve_id(data, id)
  check_data(data, references)
  data <- ensure_list_column(data, references, sep, strip_quotes)

  ids <- as.character(data[["id"]])

  ## Expand all references
  all_refs <- unlist(data[[references]], use.names = FALSE)
  all_refs <- all_refs[!is.na(all_refs)]

  ## Count how many times each dataset ID appears as a reference
  internal_refs <- all_refs[all_refs %in% ids]
  lcs_table <- table(internal_refs)

  lcs <- integer(length(ids))
  names(lcs) <- ids
  matched <- intersect(names(lcs_table), ids)
  lcs[matched] <- as.integer(lcs_table[matched])

  ## Build result
  result <- data.frame(
    id = ids,
    lcs = as.integer(lcs),
    stringsAsFactors = FALSE
  )

  ## Add metadata columns in canonical order: gcs, year, title, journal, doi
  if ("cited_by_count" %in% names(data)) {
    result$gcs <- as.integer(data[["cited_by_count"]])
  }
  for (col in c("year", "title", "journal", "doi")) {
    if (col %in% names(data)) {
      result[[col]] <- if (col == "year") as.integer(data[[col]]) else data[[col]]
    }
  }

  result <- result[order(-result$lcs), ]
  rownames(result) <- NULL
  result
}


#' Build a historiograph (chronological citation network)
#'
#' Constructs a Garfield-style historiograph: the `n` most locally cited
#' documents and the within-corpus citations they receive, each edge
#' carrying the publication years of both ends so the network can be laid
#' out chronologically. The citing document of an edge may be any document
#' in the data, not only one of the `n` selected.
#'
#' @param data A data frame with one row per work, a references column
#'   (list-column or delimited string) whose values use the same identifiers
#'   as the works, and `year`. An `id` column is optional (see `id`).
#'   Optionally `title`, `journal`, `doi`, `cited_by_count`.
#' @param n Integer. Number of top locally cited documents to include.
#'   Default 30.
#' @param min_lcs Integer. Minimum local citation score for inclusion.
#'   Default 1.
#' @inheritParams local_citations
#'
#' @return A list of two data frames:
#'   \describe{
#'     \item{`nodes`}{One row per included document (at most `n`, each with
#'       `lcs >= min_lcs`), with the [local_citations()] columns (`id`,
#'       `lcs`, `gcs` when available, `year`, and `title`, `journal`, `doi`
#'       when present), sorted by decreasing `lcs`.}
#'     \item{`edges`}{One row per distinct directed citation that points at
#'       an included document, with `from` (citing; any document in the
#'       data), `to` (cited), `year_from` and `year_to` (integer), sorted by
#'       `year_from` then `year_to`.}
#'   }
#'   Both are empty (zero rows) when no document reaches `min_lcs`.
#'
#' @references
#' Garfield, E. (2004). Historiographic mapping of knowledge domains
#' literature. *Journal of Information Science*, 30(2), 119--145.
#' \doi{10.1177/0165551504042802}
#'
#' @export
#' @examples
#' data(biblio_data)
#' historiograph(biblio_data, n = 5)
historiograph <- function(data, n = 30, min_lcs = 1,
                          references = "references", sep = ";",
                          strip_quotes = TRUE, id = NULL) {
  data <- resolve_id(data, id)
  check_data(data, c(references, "year"))
  data <- ensure_list_column(data, references, sep, strip_quotes)

  ## Compute local citations (data already split/stripped above; forward
  ## strip_quotes so node selection matches the edge-building labels below)
  lcs_df <- local_citations(data, references = references,
                            strip_quotes = strip_quotes)

  ## Filter by min_lcs
  lcs_df <- lcs_df[lcs_df$lcs >= min_lcs, ]

  if (nrow(lcs_df) == 0) {
    empty_nodes <- data.frame(
      id = character(0), lcs = integer(0), gcs = integer(0),
      year = integer(0), title = character(0),
      journal = character(0), doi = character(0),
      stringsAsFactors = FALSE
    )
    ## Drop columns absent from the input
    keep_cols <- c("id", "lcs",
                   if ("cited_by_count" %in% names(data)) "gcs",
                   "year",
                   intersect(c("title", "journal", "doi"), names(data)))
    return(list(
      nodes = empty_nodes[, keep_cols, drop = FALSE],
      edges = data.frame(from = character(0), to = character(0),
                          year_from = integer(0), year_to = integer(0),
                          stringsAsFactors = FALSE)
    ))
  }

  ## Top n by LCS
  if (nrow(lcs_df) > n) {
    lcs_df <- lcs_df[seq_len(n), ]
  }

  nodes <- lcs_df
  node_ids <- nodes$id

  ## Build directed citation edges among included nodes
  ids <- as.character(data[["id"]])
  refs_list <- data[[references]]
  years <- data[["year"]]

  ## Year lookup
  year_lookup <- stats::setNames(years, ids)

  ## Expand references for ALL papers (a non-top paper can cite a top paper)
  citing <- rep(ids, lengths(refs_list))
  cited <- unlist(refs_list, use.names = FALSE)

  keep <- !is.na(cited) & cited %in% node_ids & citing %in% ids
  citing <- citing[keep]
  cited  <- cited[keep]

  if (length(citing) == 0) {
    edges <- data.frame(from = character(0), to = character(0),
                         year_from = integer(0), year_to = integer(0),
                         stringsAsFactors = FALSE)
  } else {
    edges <- data.frame(
      from = citing,
      to = cited,
      year_from = as.integer(year_lookup[citing]),
      year_to = as.integer(year_lookup[cited]),
      stringsAsFactors = FALSE
    )
    ## Remove duplicates
    edges <- unique(edges)
    edges <- edges[order(edges$year_from, edges$year_to), ]
    rownames(edges) <- NULL
  }

  list(nodes = nodes, edges = edges)
}
