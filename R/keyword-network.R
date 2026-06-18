#' Build a keyword co-occurrence network
#'
#' Constructs a network where two keywords are linked when they appear
#' together in the same document.
#'
#' @param data A data frame with `id` and a keyword list-column.
#' @param keywords Character. Name of the keyword column (list-column or
#'   delimited string). Default `"keywords"`. Any column of a custom data
#'   set works, e.g. `keywords = "Tags"`.
#' @param strip_quotes Logical. If `TRUE` (default), surrounding quote
#'   characters are removed from each keyword.
#' @param id Optional. Name of the column to use as the work identifier
#'   (the matrix-row dimension). If `NULL` (default), an existing `id`
#'   column is used when present, otherwise row numbers are used.
#' @param field Deprecated. Use `keywords` instead.
#' @param counting Character. Counting method. Default `"full"`.
#' @param similarity Character. Similarity measure. Default `"none"`.
#' @param threshold Numeric. Minimum edge weight. Default 0.
#' @param min_occur Integer. Minimum keyword frequency. Default 1.
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
#' keyword_network(biblio_data)
#' keyword_network(biblio_data, similarity = "association")
#'
#' # Custom CSV: any column name, any separator
#' d <- data.frame(id = 1:3, Tags = c("ml, ai", "ml, nlp", "ai, nlp"))
#' keyword_network(d, keywords = "Tags", sep = ",")
keyword_network <- function(data,
                            keywords = "keywords",
                            counting = "full",
                            similarity = "none",
                            threshold = 0,
                            min_occur = 1L,
                            attention = NULL,
                            top_n = NULL,
                            self_loops = FALSE,
                            deduplicate = TRUE,
                            format = "edgelist",
                            sep = ";",
                            strip_quotes = TRUE,
                            field = NULL,
                            id = NULL) {
  if (!is.null(field)) {
    warning("Argument 'field' is deprecated; use 'keywords' instead.",
            call. = FALSE)
    keywords <- field
  }
  data <- resolve_id(data, id)
  check_data(data, keywords)
  data <- ensure_list_column(data, keywords, sep, strip_quotes)
  check_choice(similarity, c("none", "association", "cosine", "jaccard",
                              "inclusion", "equivalence"), "similarity")
  check_format(format)

  if (!is.null(attention)) {
    check_choice(attention, all_attention_methods(), "attention")
    B <- build_author_bipartite(data, field = keywords,
                                counting = paste0("attention_", attention),
                                deduplicate = deduplicate,
                                strip_quotes = strip_quotes)
    result <- multiply_bipartite(B, mode = "columns", similarity = similarity,
                                 threshold = threshold, top_n = top_n,
                                 self_loops = self_loops)
    return(as_bibnets_network(result,
      network_type = paste0("keyword_attention_", attention),
      counting = attention, similarity = similarity, format = format))
  }

  check_choice(counting, position_independent_counts(), "counting")
  B <- build_bipartite(data, field = keywords, min_freq = min_occur,
                       deduplicate = deduplicate, strip_quotes = strip_quotes)
  B <- apply_counting(B, counting = counting, network_type = "symmetric")
  result <- multiply_bipartite(B, mode = "columns", similarity = similarity,
                               threshold = threshold, top_n = top_n,
                               self_loops = self_loops)
  as_bibnets_network(result, network_type = "keyword_co_occurrence",
                      counting = counting, similarity = similarity,
                      format = format)
}
