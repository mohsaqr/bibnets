#' Build a reference network
#'
#' Constructs a co-citation or equivalence network among cited references.
#' Two references are linked when they are cited together by the same paper.
#'
#' @param data A data frame with one row per work and a references column
#'   (list-column or delimited string). An `id` column is optional (see `id`).
#' @param type Character. `"co_citation"` (default) or `"equivalence"`
#'   (cosine similarity of the references' citing-paper vectors; `counting`
#'   and `similarity` are ignored).
#' @param references Character. Name of the column containing cited references.
#'   Default `"references"`.
#' @param sep Character. Separator used to split the references column when
#'   it is a plain character column. Default `";"`. Ignored for list-columns.
#' @param strip_quotes Logical. If `TRUE` (default), surrounding quote
#'   characters are removed from each reference.
#' @param id Optional. Name of the column to use as the work identifier
#'   (the matrix-row dimension). If `NULL` (default), an existing `id`
#'   column is used when present, otherwise row numbers are used.
#' @param counting Character. Counting method: `"full"` (default),
#'   `"fractional"`, `"paper"` or `"strength"`.
#' @param similarity Character. Similarity measure. Default `"none"`.
#' @param threshold Numeric. Minimum edge weight; edges with
#'   `weight < threshold` are dropped. Default 0 (keep all).
#' @param min_occur Integer. Minimum times a reference must be cited. Default 1.
#' @param top_n Integer or NULL. Keep only the `top_n` most frequent nodes
#'   and return the edges among them. Default `NULL` (all nodes).
#' @inheritParams author_network
#'
#' @return Depends on `format`. The default `"edgelist"` returns a
#'   `bibnets_network` data frame with one row per undirected edge, columns
#'   `from`, `to`, `weight` and `count`, sorted by decreasing `weight`, and
#'   attributes `network_type`, `counting` and `similarity`. See
#'   [author_network()] for the other formats.
#'
#' @export
#' @examples
#' data(biblio_data)
#' reference_network(biblio_data)
#' reference_network(biblio_data, similarity = "association")
reference_network <- function(data,
                              type = "co_citation",
                              counting = "full",
                              similarity = "none",
                              threshold = 0,
                              min_occur = 1L,
                              top_n = NULL,
                              self_loops = FALSE,
                              deduplicate = TRUE,
                              format = "edgelist",
                              references = "references",
                              sep = ";",
                              strip_quotes = TRUE,
                              id = NULL) {
  data <- resolve_id(data, id)
  check_data(data, references)
  check_choice(type, c("co_citation", "equivalence"), "type")
  check_choice(counting, position_independent_counts(), "counting")
  check_choice(similarity, c("none", "association", "cosine", "jaccard",
                              "inclusion", "equivalence"), "similarity")
  check_format(format)
  data <- ensure_list_column(data, references, sep, strip_quotes)

  B <- build_bipartite(data, field = references, min_freq = min_occur,
                       deduplicate = deduplicate, strip_quotes = strip_quotes)

  result <- if (type == "equivalence") {
    multiply_bipartite(B, mode = "columns", similarity = "cosine",
                       threshold = threshold, top_n = top_n,
                       self_loops = self_loops)
  } else {
    B <- apply_counting(B, counting = counting, network_type = "symmetric")
    multiply_bipartite(B, mode = "columns", similarity = similarity,
                       threshold = threshold, top_n = top_n,
                       self_loops = self_loops)
  }
  as_bibnets_network(result, network_type = paste0("reference_", type),
                      counting = counting, similarity = similarity,
                      format = format)
}
