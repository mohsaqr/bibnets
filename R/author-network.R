#' Build an author network
#'
#' Constructs a network between authors using one of four relationship types
#' and any of 13 counting methods, including 9 position-dependent methods
#' that respect author byline order.
#'
#' @param data A data frame with at least `id` and an author column
#'   (list-column or delimited string, order preserved). For
#'   coupling/co-citation, also needs `references`.
#' @param authors Character. Name of the column containing authors. Default
#'   `"authors"`. Use this to point at any column of a custom data set,
#'   e.g. `authors = "Author Names"`.
#' @param sep Character. Separator used to split the entity column when it
#'   is a plain character column rather than a list-column, e.g. `sep = ","`
#'   or `sep = " and "`. Default `";"`. Ignored for list-columns. `sep`
#'   applies only to the author column; the references column uses
#'   `references_sep`.
#' @param references_sep Character. Separator for the `references` column in
#'   `type = "coupling"`. Default `";"` (reference strings usually contain
#'   internal commas, so this is kept independent of `sep`). Set it when
#'   your references are delimited differently.
#' @param strip_quotes Logical. If `TRUE` (default), surrounding quote
#'   characters are removed from each entity, so a quoted CSV value such as
#'   `"Alice"` or `""Alice""` is treated as `Alice`. Set `FALSE` to keep
#'   quotes as part of the label.
#' @param id Optional. Name of the column to use as the work identifier
#'   (the matrix-row dimension). If `NULL` (default), an existing `id`
#'   column is used when present, otherwise row numbers are used.
#' @param type Character. Relationship type:
#'   \describe{
#'     \item{`"collaboration"`}{Co-authorship: authors linked when they
#'       co-author a publication.}
#'     \item{`"coupling"`}{Bibliographic coupling aggregated at author level:
#'       authors linked when they cite the same references.}
#'     \item{`"co_citation"`}{Author co-citation: authors linked when they
#'       are cited together by the same paper. Requires a
#'       `cited_first_authors` list-column.}
#'     \item{`"equivalence"`}{Profile similarity: cosine similarity of
#'       authors' full collaboration/citation profiles.}
#'   }
#' @param counting Character. Counting method. Position-independent methods
#'   (`"full"`, `"fractional"`, `"paper"`, `"strength"`) work for all types.
#'   Position-dependent methods (`"harmonic"`, `"arithmetic"`, `"geometric"`,
#'   `"adaptive_geometric"`, `"golden"`, `"first"`, `"last"`,
#'   `"first_last"`, `"position_weighted"`) are available for
#'   `type = "collaboration"`.
#' @param similarity Character. Similarity measure: `"none"`, `"association"`,
#'   `"cosine"`, `"jaccard"`, `"inclusion"`, `"equivalence"`.
#' @param threshold Numeric. Minimum edge weight. Default 0.
#' @param min_occur Integer. Minimum number of papers for an author to be
#'   included. Default 1.
#' @param position_weights Numeric vector. Custom weights for
#'   `counting = "position_weighted"`. Default `c(1, 0.8, 0.6, 0.4)`.
#' @param first_last_weight Numeric. Multiplier for `counting = "first_last"`.
#'   Default 2.
#' @param attention Character or NULL. Attention-based weighting independent of
#'   `type` and `counting`. One of `"proximity"` (center authors weighted most),
#'   `"lead"` (first author dominates, quadratic drop), `"last"` (last author
#'   dominates, quadratic rise), `"circular"` (first and last both prominent).
#'   Default `NULL` (disabled).
#' @param top_n Integer or NULL. Return only the top n edges by weight.
#'   Default NULL (all edges).
#' @param self_loops Logical. If `TRUE`, include self-loops (an entity linked
#'   to itself). Default `FALSE`.
#' @param deduplicate Logical. If `TRUE` (default), each `(paper, entity)`
#'   pair is counted at most once — duplicate entries in the source data
#'   (e.g., the same author listed twice on a paper) are treated as one
#'   occurrence. Set to `FALSE` to count every raw occurrence.
#' @param format Character. Output format:
#'   \describe{
#'     \item{`"edgelist"`}{Default. A `bibnets_network` data frame with
#'       columns `from`, `to`, `weight`, `count`.}
#'     \item{`"gephi"`}{Gephi-ready data frame: `Source`, `Target`,
#'       `Weight`, `Count`, `Type`.}
#'     \item{`"igraph"`}{An igraph graph object (requires igraph).}
#'     \item{`"cograph"`}{A cograph_network object (requires cograph).}
#'     \item{`"matrix"`}{A sparse adjacency matrix.}
#'   }
#'
#' @return Depends on `format`: a `bibnets_network` data frame (default),
#'   a Gephi-ready data frame, an igraph graph, a cograph_network, or a
#'   sparse matrix.
#'
#' @export
#' @examples
#' data(biblio_data)
#' author_network(biblio_data, "collaboration")
#' author_network(biblio_data, "collaboration", counting = "harmonic")
#' author_network(biblio_data, "collaboration", counting = "geometric",
#'                similarity = "association")
#'
#' # Custom CSV: any column name, any separator
#' d <- data.frame(id = 1:3,
#'                 Researchers = c("Smith J, Doe A", "Smith J, Lee K",
#'                                 "Doe A, Lee K"))
#' author_network(d, authors = "Researchers", sep = ",")
author_network <- function(data,
                           type = "collaboration",
                           counting = "full",
                           similarity = "none",
                           threshold = 0,
                           min_occur = 1L,
                           position_weights = c(1, 0.8, 0.6, 0.4),
                           first_last_weight = 2,
                           attention = NULL,
                           top_n = NULL,
                           self_loops = FALSE,
                           deduplicate = TRUE,
                           format = "edgelist",
                           authors = "authors",
                           sep = ";",
                           references_sep = ";",
                           strip_quotes = TRUE,
                           id = NULL) {
  data <- resolve_id(data, id)
  check_data(data, authors)
  check_choice(similarity, c("none", "association", "cosine", "jaccard",
                              "inclusion", "equivalence"), "similarity")
  check_format(format)
  data <- ensure_list_column(data, authors, sep, strip_quotes)

  if (!is.null(attention)) {
    check_choice(attention, all_attention_methods(), "attention")
    B <- build_author_bipartite(data, field = authors,
                                counting = paste0("attention_", attention),
                                deduplicate = deduplicate,
                                strip_quotes = strip_quotes)
    result <- multiply_bipartite(B, mode = "columns", similarity = similarity,
                                 threshold = threshold, top_n = top_n,
                                 self_loops = self_loops)
    return(as_bibnets_network(result,
      network_type = paste0("author_attention_", attention),
      counting = attention, similarity = similarity, format = format))
  }

  check_choice(type, c("collaboration", "coupling", "co_citation", "equivalence"), "type")
  check_choice(counting, all_counts(), "counting")

  is_positional <- counting %in% position_dependent_counts()

  result <- if (type == "collaboration") {
    if (is_positional) {
      B <- build_author_bipartite(
        data, field = authors, counting = counting,
        position_weights = position_weights,
        first_last_weight = first_last_weight,
        deduplicate = deduplicate, strip_quotes = strip_quotes
      )
      multiply_bipartite(B, mode = "columns", similarity = similarity,
                         threshold = threshold, top_n = top_n,
                         self_loops = self_loops)
    } else {
      B <- build_bipartite(data, field = authors, min_freq = min_occur,
                           deduplicate = deduplicate, strip_quotes = strip_quotes)
      B <- apply_counting(B, counting = counting, network_type = "symmetric")
      multiply_bipartite(B, mode = "columns", similarity = similarity,
                         threshold = threshold, top_n = top_n,
                         self_loops = self_loops)
    }

  } else if (type == "coupling") {
    check_data(data, "references")
    data <- ensure_list_column(data, "references", references_sep, strip_quotes)
    agg <- aggregate_by_entity(data, entity_field = authors,
                                value_field = "references",
                                min_freq = min_occur)
    B <- build_bipartite(agg, field = "references", strip_quotes = strip_quotes)
    ct <- if (is_positional) "full" else counting
    B <- apply_counting(B, counting = ct, network_type = "coupling")
    multiply_bipartite(B, mode = "rows", similarity = similarity,
                       threshold = threshold, top_n = top_n,
                       self_loops = self_loops)

  } else if (type == "co_citation") {
    cc_field <- if ("cited_first_authors" %in% names(data)) {
      "cited_first_authors"
    } else {
      stop("Column 'cited_first_authors' not found. ",
           "Parse reference strings to extract cited authors first.",
           call. = FALSE)
    }
    B <- build_bipartite(data, field = cc_field, min_freq = min_occur,
                         deduplicate = deduplicate, strip_quotes = strip_quotes)
    ct <- if (is_positional) "full" else counting
    B <- apply_counting(B, counting = ct, network_type = "symmetric")
    multiply_bipartite(B, mode = "columns", similarity = similarity,
                       threshold = threshold, top_n = top_n,
                       self_loops = self_loops)

  } else {
    B <- build_bipartite(data, field = authors, min_freq = min_occur,
                         deduplicate = deduplicate, strip_quotes = strip_quotes)
    multiply_bipartite(B, mode = "columns", similarity = "cosine",
                       threshold = threshold, top_n = top_n,
                       self_loops = self_loops)
  }

  as_bibnets_network(result,
    network_type = paste0("author_", type),
    counting = counting, similarity = similarity,
    format = format)
}
