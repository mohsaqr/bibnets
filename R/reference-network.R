#' Build a reference network
#'
#' Constructs a co-citation or equivalence network among cited references.
#' Two references are linked when they are cited together by the same paper.
#'
#' @param data A data frame with `id` and a references column (list-column
#'   or delimited string).
#' @param type Character. `"co_citation"` (default) or `"equivalence"`.
#' @param references Character. Name of the column containing cited references.
#'   Default `"references"`.
#' @param strip_quotes Logical. If `TRUE` (default), surrounding quote
#'   characters are removed from each reference.
#' @param id Optional. Name of the column to use as the work identifier
#'   (the matrix-row dimension). If `NULL` (default), an existing `id`
#'   column is used when present, otherwise row numbers are used.
#' @param counting Character. Counting method. Default `"full"`.
#' @param similarity Character. Similarity measure. Default `"none"`.
#' @param threshold Numeric. Minimum edge weight. Default 0.
#' @param min_occur Integer. Minimum times a reference must be cited. Default 1.
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
