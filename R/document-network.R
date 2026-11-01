#' Build a document network
#'
#' Constructs a network between documents (papers) in the dataset.
#'
#' @param data A data frame with one row per work and a references column
#'   (list-column or delimited string). An `id` column is optional (see `id`);
#'   direct citation needs the references to use the same identifiers.
#' @param references Character. Name of the column containing cited references.
#'   Default `"references"`.
#' @param sep Character. Separator used to split the references column when
#'   it is a plain character column. Default `";"`. Ignored for list-columns.
#' @param strip_quotes Logical. If `TRUE` (default), surrounding quote
#'   characters are removed from each reference.
#' @param id Optional. Name of the column to use as the work identifier
#'   (the matrix-row dimension). If `NULL` (default), an existing `id`
#'   column is used when present, otherwise row numbers are used.
#' @param type Character. Relationship type:
#'   \describe{
#'     \item{`"coupling"`}{Bibliographic coupling: documents linked when they
#'       share cited references.}
#'     \item{`"citation"`}{Direct citation: directed edges from citing to
#'       cited documents (internal citations only). `counting`,
#'       `similarity`, `threshold` and `min_occur` are not applied; `top_n`
#'       keeps the documents with the most citation edges.}
#'     \item{`"co_citation"`}{Co-citation of the cited items: the nodes are
#'       the values of the references column (as in [reference_network()]),
#'       linked when the same document cites both. They are documents of the
#'       dataset only when the references are document identifiers.}
#'     \item{`"equivalence"`}{Cosine similarity of the documents' reference
#'       vectors; `counting` and `similarity` are ignored.}
#'   }
#' @param counting Character. Counting method: `"full"` (default),
#'   `"fractional"`, `"paper"` or `"strength"`. Position-dependent methods
#'   are not applicable to document networks.
#' @param similarity Character. Similarity measure. Default `"none"`.
#' @param threshold Numeric. Minimum edge weight; edges with
#'   `weight < threshold` are dropped. Default 0 (keep all).
#' @param min_occur Integer. Minimum reference frequency. Default 1.
#' @param top_n Integer or NULL. Keep only the `top_n` most frequent nodes
#'   and return the edges among them. Default `NULL` (all nodes).
#' @inheritParams author_network
#'
#' @return Depends on `format`. The default `"edgelist"` returns a
#'   `bibnets_network` data frame with one row per edge, columns `from`,
#'   `to`, `weight` and `count`, and attributes `network_type`, `counting`
#'   and `similarity`; see [author_network()] for the other formats. For
#'   `type = "citation"` the edges are directed (`from` = citing, `to` =
#'   cited) with `weight` and `count` both 1, in data order; the other
#'   types are undirected and sorted by decreasing `weight`.
#'
#' @references
#' Kessler, M. M. (1963). Bibliographic coupling between scientific
#' papers. *American Documentation*, 14(1), 10--25.
#' \doi{10.1002/asi.5090140103}
#'
#' Small, H. (1973). Co-citation in the scientific literature: A new
#' measure of the relationship between two documents. *Journal of the
#' American Society for Information Science*, 24(4), 265--269.
#' \doi{10.1002/asi.4630240406}
#'
#' @export
#' @examples
#' data(biblio_data)
#' document_network(biblio_data, "coupling")
#' document_network(biblio_data, "coupling", counting = "strength")
document_network <- function(data,
                             type = "coupling",
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
  check_choice(type, c("coupling", "citation", "co_citation", "equivalence"), "type")
  check_choice(counting, position_independent_counts(), "counting")
  check_choice(similarity, c("none", "association", "cosine", "jaccard",
                              "inclusion", "equivalence"), "similarity")
  check_format(format)
  data <- ensure_list_column(data, references, sep, strip_quotes)

  result <- if (type == "citation") {
    edges <- build_direct_citation(data, field = references)
    if (!is.null(top_n) && nrow(edges) > 0) {
      freq <- sort(table(c(edges$from, edges$to)), decreasing = TRUE)
      top_nodes <- names(freq)[seq_len(min(top_n, length(freq)))]
      edges <- edges[edges$from %in% top_nodes & edges$to %in% top_nodes, ]
    }
    edges
  } else {
    B <- build_bipartite(data, field = references, min_freq = min_occur,
                         deduplicate = deduplicate, strip_quotes = strip_quotes)
    if (type == "coupling") {
      B <- apply_counting(B, counting = counting, network_type = "coupling")
      multiply_bipartite(B, mode = "rows", similarity = similarity,
                         threshold = threshold, top_n = top_n,
                         self_loops = self_loops)
    } else if (type == "co_citation") {
      B <- apply_counting(B, counting = counting, network_type = "symmetric")
      multiply_bipartite(B, mode = "columns", similarity = similarity,
                         threshold = threshold, top_n = top_n,
                         self_loops = self_loops)
    } else {
      multiply_bipartite(B, mode = "rows", similarity = "cosine",
                         threshold = threshold, top_n = top_n,
                         self_loops = self_loops)
    }
  }

  directed <- (type == "citation")
  as_bibnets_network(result, network_type = paste0("document_", type),
                      counting = counting, similarity = similarity,
                      format = format, directed = directed)
}


#' @keywords internal
build_direct_citation <- function(data, field = "references") {
  ids <- as.character(data[["id"]])
  refs_list <- data[[field]]

  citing <- rep(ids, lengths(refs_list))
  cited <- unlist(refs_list, use.names = FALSE)

  keep <- cited %in% ids & !is.na(cited)
  citing <- citing[keep]
  cited <- cited[keep]

  if (length(citing) == 0L) {
    return(data.frame(
      from = character(0), to = character(0),
      weight = numeric(0), count = integer(0),
      stringsAsFactors = FALSE
    ))
  }

  data.frame(
    from = citing, to = cited,
    weight = rep(1, length(citing)),
    count = rep(1L, length(citing)),
    stringsAsFactors = FALSE
  )
}
