#' bibnets: Importing, Constructing, and Exporting Bibliometric Networks
#'
#' @description
#' `bibnets` builds bibliometric networks from the exports of scholarly
#' databases. A bibliometric network links authors, documents, references,
#' keywords, journals, institutions or countries through the records they
#' share: co-authorship links authors who write together, co-citation links
#' references cited together (Small, 1973), and bibliographic coupling links
#' documents that cite the same work (Kessler, 1963). These networks show how
#' a research field is organized: its collaborating groups, its intellectual
#' base and its topics. The weight of a link can be normalized for how active
#' each entity is ([normalize()]), and authorship credit can be counted in
#' full, fractionally or by author position (the `counting` argument of the
#' builders). Networks can
#' be built for time windows ([temporal_network()]), reduced to their backbone
#' with the disparity filter ([backbone()]; Serrano et al., 2009), and traced
#' over time with a historiograph of the most locally cited documents
#' ([historiograph()]; Garfield, 2004).
#'
#' Records are read with [read_biblio()] from Scopus, Web of Science,
#' OpenAlex, BibTeX, RIS, Lens.org, Dimensions and Crossref exports, or taken
#' from any data frame with its own column names and separators. The builders
#' ([author_network()], [document_network()], [reference_network()],
#' [keyword_network()], [source_network()], [institution_network()],
#' [country_network()] and the generic [conetwork()]) return an edge list
#' with `from`, `to`, `weight` and `count` columns, which [to_igraph()],
#' [to_tbl_graph()], [to_cograph()], [to_gephi()], [to_graphml()] and
#' [to_matrix()] export.
#'
#' @references
#' Garfield, E. (2004). Historiographic mapping of knowledge domains
#' literature. *Journal of Information Science*, 30(2), 119--145.
#' \doi{10.1177/0165551504042802}
#'
#' Kessler, M. M. (1963). Bibliographic coupling between scientific
#' papers. *American Documentation*, 14(1), 10--25.
#' \doi{10.1002/asi.5090140103}
#'
#' Serrano, M. A., Boguna, M., & Vespignani, A. (2009). Extracting the
#' multiscale backbone of complex weighted networks. *Proceedings of the
#' National Academy of Sciences*, 106(16), 6483--6488.
#'
#' Small, H. (1973). Co-citation in the scientific literature: A new
#' measure of the relationship between two documents. *Journal of the
#' American Society for Information Science*, 24(4), 265--269.
#'
#' @keywords internal
"_PACKAGE"
