#' Build a country network
#'
#' Constructs a network between countries based on collaboration or coupling.
#'
#' @param data A data frame with `id` and a country column (list-column or
#'   delimited string). For coupling, also needs `references`.
#' @param countries Character. Name of the column containing countries.
#'   Default `"countries"`.
#' @param references_sep Character. Separator for the `references` column in
#'   `type = "coupling"`. Default `";"`.
#' @param strip_quotes Logical. If `TRUE` (default), surrounding quote
#'   characters are removed from each entity.
#' @param id Optional. Name of the column to use as the work identifier
#'   (the matrix-row dimension). If `NULL` (default), an existing `id`
#'   column is used when present, otherwise row numbers are used.
#' @param type Character. `"collaboration"` (default), `"coupling"`, or
#'   `"equivalence"`.
#' @param counting Character. Counting method. Default `"full"`.
#' @param similarity Character. Similarity measure. Default `"none"`.
#' @param threshold Numeric. Minimum edge weight. Default 0.
#' @param min_occur Integer. Minimum papers per country. Default 1.
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
#' data(learning_analytics)
#' country_network(learning_analytics, "collaboration")
country_network <- function(data,
                            type = "collaboration",
                            counting = "full",
                            similarity = "none",
                            threshold = 0,
                            min_occur = 1L,
                            attention = NULL,
                            top_n = NULL,
                            self_loops = FALSE,
                            deduplicate = TRUE,
                            format = "edgelist",
                            countries = "countries",
                            sep = ";",
                            references_sep = ";",
                            strip_quotes = TRUE,
                            id = NULL) {
  data <- resolve_id(data, id)
  check_data(data, countries)
  check_choice(similarity, c("none", "association", "cosine", "jaccard",
                              "inclusion", "equivalence"), "similarity")
  check_format(format)
  data <- ensure_list_column(data, countries, sep, strip_quotes)

  if (!is.null(attention)) {
    check_choice(attention, all_attention_methods(), "attention")
    B <- build_author_bipartite(data, field = countries,
                                counting = paste0("attention_", attention),
                                deduplicate = deduplicate,
                                strip_quotes = strip_quotes)
    result <- multiply_bipartite(B, mode = "columns", similarity = similarity,
                                 threshold = threshold, top_n = top_n,
                                 self_loops = self_loops)
    return(as_bibnets_network(result,
      network_type = paste0("country_attention_", attention),
      counting = attention, similarity = similarity, format = format))
  }

  check_choice(type, c("collaboration", "coupling", "equivalence"), "type")
  check_choice(counting, position_independent_counts(), "counting")

  result <- if (type == "collaboration") {
    B <- build_bipartite(data, field = countries, min_freq = min_occur,
                         deduplicate = deduplicate, strip_quotes = strip_quotes)
    B <- apply_counting(B, counting = counting, network_type = "symmetric")
    multiply_bipartite(B, mode = "columns", similarity = similarity,
                       threshold = threshold, top_n = top_n,
                       self_loops = self_loops)

  } else if (type == "coupling") {
    if (!"references" %in% names(data))
      stop("Column 'references' not found. Required for type = 'coupling'.", call. = FALSE)
    data <- ensure_list_column(data, "references", references_sep, strip_quotes)
    agg <- aggregate_by_entity(data, entity_field = countries,
                                value_field = "references",
                                min_freq = min_occur)
    B <- build_bipartite(agg, field = "references", strip_quotes = strip_quotes)
    B <- apply_counting(B, counting = counting, network_type = "coupling")
    multiply_bipartite(B, mode = "rows", similarity = similarity,
                       threshold = threshold, top_n = top_n,
                       self_loops = self_loops)

  } else {
    B <- build_bipartite(data, field = countries, min_freq = min_occur,
                         deduplicate = deduplicate, strip_quotes = strip_quotes)
    multiply_bipartite(B, mode = "columns", similarity = "cosine",
                       threshold = threshold, top_n = top_n,
                       self_loops = self_loops)
  }

  as_bibnets_network(result, network_type = paste0("country_", type),
                      counting = counting, similarity = similarity,
                      format = format)
}
