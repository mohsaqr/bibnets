#' Build an author network
#'
#' Constructs a network between authors using one of four relationship types
#' and any of 13 counting methods, including 9 position-dependent methods
#' that respect author byline order.
#'
#' @param data A data frame with one row per work and an author column
#'   (list-column or delimited string, byline order preserved). An `id`
#'   column is optional (see `id`). `type = "coupling"` also needs a
#'   `references` column; `type = "co_citation"` needs a
#'   `cited_first_authors` list-column.
#' @param authors Character. Name of the column containing authors. Default
#'   `"authors"`. Use this to point at any column of a custom data set,
#'   e.g. `authors = "Author Names"`.
#' @param sep Character. Separator used to split the entity column (the one
#'   named by the column argument, e.g. `authors`) when it is a plain
#'   character column rather than a list-column, e.g. `sep = ","` or
#'   `sep = " and "`. Default `";"`. Ignored for list-columns. In coupling
#'   networks the references column is split with `references_sep`
#'   instead.
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
#'     \item{`"equivalence"`}{Profile similarity: cosine similarity of the
#'       authors' paper-incidence vectors. `counting` and `similarity` are
#'       ignored (always cosine).}
#'   }
#' @param counting Character. Counting method. Position-independent methods
#'   (`"full"`, `"fractional"`, `"paper"`, `"strength"`) work for all types.
#'   Position-dependent methods (`"harmonic"`, `"arithmetic"`, `"geometric"`,
#'   `"adaptive_geometric"`, `"golden"`, `"first"`, `"last"`,
#'   `"first_last"`, `"position_weighted"`) apply to
#'   `type = "collaboration"`; for the other types they fall back to
#'   `"full"`.
#' @param similarity Character. Similarity measure: `"none"`, `"association"`,
#'   `"cosine"`, `"jaccard"`, `"inclusion"`, `"equivalence"`.
#' @param threshold Numeric. Minimum edge weight; edges with
#'   `weight < threshold` are dropped. Default 0 (keep all).
#' @param min_occur Integer. Minimum number of papers for an author to be
#'   included. Default 1. Not applied with a position-dependent `counting`
#'   method or with `attention`.
#' @param position_weights Numeric vector. Custom weights for
#'   `counting = "position_weighted"`. Default `c(1, 0.8, 0.6, 0.4)`.
#' @param first_last_weight Numeric. Multiplier for `counting = "first_last"`.
#'   Default 2.
#' @param attention Character or NULL. Attention-based weighting independent of
#'   `type` and `counting`. One of `"proximity"` (center authors weighted most),
#'   `"lead"` (first author dominates, quadratic drop), `"last"` (last author
#'   dominates, quadratic rise), `"circular"` (first and last both prominent).
#'   The weights of one paper sum to 1 and an edge receives the product of
#'   its two endpoints' weights. When `attention` is set, `type` and
#'   `counting` are ignored. Default `NULL` (disabled).
#' @param top_n Integer or NULL. Keep only the `top_n` most frequent nodes
#'   (largest diagonal of the projected matrix, i.e. the number of papers
#'   under full counting) and return the edges among them. Default `NULL`
#'   (all nodes).
#' @param self_loops Logical. If `TRUE`, include self-loops (an entity linked
#'   to itself). Default `FALSE`. Only takes effect with
#'   `similarity = "none"`; every similarity measure zeroes the diagonal.
#' @param deduplicate Logical. If `TRUE` (default), each `(paper, entity)`
#'   pair is counted at most once -- duplicate entries in the source data
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
#' @return Depends on `format`. The default `"edgelist"` returns a
#'   `bibnets_network`: a data frame with one row per undirected edge and
#'   columns `from`, `to` (character), `weight` (numeric) and `count`
#'   (integer raw co-occurrence), sorted by decreasing `weight`, with
#'   attributes `network_type`, `counting` and `similarity`.
#'   `"gephi"` returns a plain data frame with columns `Source`, `Target`,
#'   `Weight`, `Count`, `Type`; `"igraph"` an igraph graph; `"cograph"` a
#'   `cograph_network`; `"matrix"` a symmetric sparse `dgCMatrix`.
#'
#' @references
#' Perianes-Rodriguez, A., Waltman, L., & van Eck, N. J. (2016).
#' Constructing bibliometric networks: A comparison between full and
#' fractional counting. *Journal of Informetrics*, 10(4), 1178--1195.
#' \doi{10.1016/j.joi.2016.10.006}
#'
#' Hagen, N. T. (2008). Harmonic allocation of authorship credit:
#' Source-level correction of bibliometric bias assures accurate
#' publication and citation analysis. *PLoS ONE*, 3(12), e4021.
#' \doi{10.1371/journal.pone.0004021}
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
