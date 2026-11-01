#' Convert edge data frame to igraph
#'
#' Requires the suggested package igraph.
#'
#' @param edges A data frame with at least `from`, `to`, `weight` columns,
#'   as returned by any network function in bibnets.
#' @param directed Logical. Default `FALSE`.
#'
#' @return An `igraph` graph with one vertex per node label and one edge per
#'   row of `edges`; the remaining columns (`weight`, `count`, ...) become
#'   edge attributes.
#'
#' @export
#' @examplesIf requireNamespace("igraph", quietly = TRUE)
#' data(biblio_data)
#' edges <- author_network(biblio_data, "collaboration")
#' to_igraph(edges)
to_igraph <- function(edges, directed = FALSE) {
  if (!requireNamespace("igraph", quietly = TRUE)) {
    stop("Package 'igraph' is required. Install it with: ",
         "install.packages('igraph')", call. = FALSE)
  }
  check_edges(edges)
  igraph::graph_from_data_frame(edges, directed = directed)
}


#' Convert edge data frame to tbl_graph
#'
#' Requires the suggested packages tidygraph and igraph.
#'
#' @param edges A data frame with at least `from`, `to`, `weight` columns.
#' @param directed Logical. Default `FALSE`.
#'
#' @return A `tbl_graph` (tidygraph) with the edge columns as edge data and
#'   one node row per node label.
#'
#' @export
#' @examplesIf requireNamespace("tidygraph", quietly = TRUE)
#' data(biblio_data)
#' edges <- keyword_network(biblio_data)
#' to_tbl_graph(edges)
to_tbl_graph <- function(edges, directed = FALSE) {
  if (!requireNamespace("tidygraph", quietly = TRUE)) {
    stop("Package 'tidygraph' is required. Install it with: ",
         "install.packages('tidygraph')", call. = FALSE)
  }
  check_edges(edges)
  tidygraph::as_tbl_graph(to_igraph(edges, directed = directed))
}


#' Convert edge data frame to adjacency matrix
#'
#' @param edges A data frame with `from`, `to`, `weight` columns.
#' @param symmetric Logical. If `TRUE` (default), produces a symmetric matrix
#'   (each edge is entered in both directions).
#'
#' @return A square sparse `dgCMatrix` of edge weights with one row and
#'   column per node label (dimnames are the node labels).
#'
#' @export
#' @examples
#' data(biblio_data)
#' edges <- reference_network(biblio_data, min_occur = 2)
#' to_matrix(edges)
to_matrix <- function(edges, symmetric = TRUE) {
  check_edges(edges)
  edgelist_to_mat(edges, symmetric = symmetric)
}


#' Export to Gephi node and edge tables
#'
#' Converts a bibnets edge list (and optional node table) to the CSV format
#' expected by Gephi's Data Laboratory. Column names are remapped to Gephi
#' conventions (`Source`, `Target`, `Weight`, `Id`, `Label`).
#'
#' @param edges A data frame with at least `from`, `to`, `weight` columns.
#' @param nodes Optional data frame of node attributes. Must contain an `id`
#'   column. All other columns are included as Gephi node attributes.
#' @param file Optional directory path. If supplied, writes `nodes.csv` and
#'   `edges.csv` into that directory. If `NULL` (default), returns a list.
#' @param directed Logical. Sets the `Type` column. Default `FALSE`.
#'
#' @return If `file = NULL`, a list of two plain data frames: `nodes` (one
#'   row per node, columns `Id`, `Label`, then any extra node attributes) and
#'   `edges` (one row per edge, columns `Source`, `Target`, `Weight`, `Type`,
#'   then the remaining edge columns such as `count`). If `file` is an
#'   existing directory, writes `nodes.csv` and `edges.csv` there, reports
#'   the paths with a message, and returns the two paths invisibly.
#'
#' @export
#' @examples
#' data(biblio_data)
#' edges <- author_network(biblio_data, "collaboration")
#' to_gephi(head(edges, 3))
#'
#' # Write nodes.csv and edges.csv into a directory
#' out_dir <- tempfile("gephi")
#' dir.create(out_dir)
#' to_gephi(edges, file = out_dir)
#' unlink(out_dir, recursive = TRUE)
to_gephi <- function(edges, nodes = NULL, file = NULL, directed = FALSE) {
  check_edges(edges)

  type_label <- if (directed) "Directed" else "Undirected"

  ## Edge table — Gephi expects Source, Target, Weight, Type.
  ## Strip bibnets_network class and attributes so the returned data frame
  ## prints as a plain table (the renamed columns no longer match the
  ## bibnets print method's expected `from`/`to`/`weight`).
  edge_out <- as.data.frame(edges, stringsAsFactors = FALSE)
  class(edge_out) <- "data.frame"
  for (a in c("network_type", "counting", "similarity"))
    attr(edge_out, a) <- NULL
  names(edge_out)[names(edge_out) == "from"]   <- "Source"
  names(edge_out)[names(edge_out) == "to"]     <- "Target"
  names(edge_out)[names(edge_out) == "weight"] <- "Weight"
  edge_out$Type <- type_label

  ## Move standard columns to the front
  first <- intersect(c("Source", "Target", "Weight", "Type"), names(edge_out))
  edge_out <- edge_out[, c(first, setdiff(names(edge_out), first))]
  row.names(edge_out) <- NULL

  ## Node table — derive from edge list if not supplied
  if (is.null(nodes)) {
    all_ids <- unique(c(edges$from, edges$to))
    node_out <- data.frame(Id = all_ids, Label = all_ids,
                           stringsAsFactors = FALSE)
  } else {
    if (!is.data.frame(nodes) || !"id" %in% names(nodes))
      stop("'nodes' must be a data frame with an 'id' column.", call. = FALSE)
    node_out <- nodes
    names(node_out)[names(node_out) == "id"] <- "Id"
    node_out$Label <- node_out$Id
    first_n <- intersect(c("Id", "Label"), names(node_out))
    node_out <- node_out[, c(first_n, setdiff(names(node_out), first_n))]
  }

  if (is.null(file)) {
    return(list(nodes = node_out, edges = edge_out))
  }

  if (!dir.exists(file))
    stop("'file' must be an existing directory when writing CSVs. Got: '", file, "'", call. = FALSE)
  node_path <- file.path(file, "nodes.csv")
  edge_path <- file.path(file, "edges.csv")
  utils::write.csv(node_out, node_path, row.names = FALSE)
  utils::write.csv(edge_out, edge_path, row.names = FALSE)
  message("Written: ", node_path, "\n        ", edge_path)
  invisible(c(node_path, edge_path))
}


#' Export to GraphML
#'
#' Writes a bibnets edge list (and optional node attributes) to a GraphML
#' file using base R only, without an XML package.
#'
#' @param edges A data frame with at least `from`, `to`, `weight` columns.
#' @param nodes Optional data frame of node attributes with an `id` column.
#' @param file File path to write. If `NULL` (default), returns the GraphML
#'   as a character string.
#' @param directed Logical. Default `FALSE`.
#'
#' @return If `file = NULL`, the GraphML document as a single character
#'   string. Otherwise writes the file, reports the path with a message, and
#'   returns the path invisibly.
#'
#' @export
#' @examples
#' data(biblio_data)
#' edges <- keyword_network(biblio_data)
#' xml <- to_graphml(edges)
#' cat(substr(xml, 1, 300))
to_graphml <- function(edges, nodes = NULL, file = NULL, directed = FALSE) {
  check_edges(edges)

  r_to_graphml_type <- function(x) {
    if (is.integer(x))   return("int")
    if (is.numeric(x))   return("double")
    if (is.logical(x))   return("boolean")
    "string"
  }

  xml_escape <- function(x) {
    x <- gsub("&",  "&amp;",  as.character(x))
    x <- gsub("<",  "&lt;",   x)
    x <- gsub(">",  "&gt;",   x)
    x <- gsub("\"", "&quot;", x)
    x
  }

  edge_default <- if (directed) "directed" else "undirected"

  ## Key declarations
  edge_attr_cols <- setdiff(names(edges), c("from", "to"))
  edge_keys <- vapply(edge_attr_cols, function(col) {
    sprintf('  <key id="%s" for="edge" attr.name="%s" attr.type="%s"/>',
            col, col, r_to_graphml_type(edges[[col]]))
  }, character(1L))

  node_attr_cols <- character(0)
  node_keys <- character(0)
  if (!is.null(nodes)) {
    if (!is.data.frame(nodes) || !"id" %in% names(nodes))
      stop("'nodes' must be a data frame with an 'id' column.", call. = FALSE)
    node_attr_cols <- setdiff(names(nodes), "id")
    node_keys <- vapply(node_attr_cols, function(col) {
      sprintf('  <key id="%s" for="node" attr.name="%s" attr.type="%s"/>',
              col, col, r_to_graphml_type(nodes[[col]]))
    }, character(1L))
  }

  ## Build a <data> tag, skipping NA values entirely (GraphML treats absent
  ## data as the type's default; emitting "NA" pollutes downstream tools).
  data_tag <- function(col, value) {
    if (is.na(value)) return(NA_character_)
    sprintf('      <data key="%s">%s</data>', col, xml_escape(value))
  }

  drop_na <- function(x) x[!is.na(x)]

  ## Node elements
  all_ids <- unique(c(edges$from, edges$to))
  node_elems <- vapply(all_ids, function(v) {
    attrs <- ""
    if (!is.null(nodes)) {
      row <- nodes[nodes$id == v, , drop = FALSE]
      if (nrow(row) > 0) {
        tags <- drop_na(vapply(node_attr_cols, function(col) {
          data_tag(col, row[[col]][1])
        }, character(1L)))
        if (length(tags))
          attrs <- paste0("\n", paste(tags, collapse = "\n"), "\n    ")
      }
    }
    sprintf('    <node id="%s">%s</node>', xml_escape(v), attrs)
  }, character(1L))

  ## Edge elements
  edge_elems <- vapply(seq_len(nrow(edges)), function(i) {
    tags <- drop_na(vapply(edge_attr_cols, function(col) {
      data_tag(col, edges[[col]][i])
    }, character(1L)))
    body <- if (length(tags)) paste0("\n", paste(tags, collapse = "\n"), "\n    ") else ""
    sprintf('    <edge source="%s" target="%s">%s</edge>',
            xml_escape(edges$from[i]), xml_escape(edges$to[i]), body)
  }, character(1L))

  ## Assemble
  lines <- c(
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<graphml xmlns="http://graphml.graphdrawing.org/graphml"',
    '         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"',
    '         xsi:schemaLocation="http://graphml.graphdrawing.org/graphml',
    '         http://graphml.graphdrawing.org/graphml/1.0/graphml.xsd">',
    node_keys,
    edge_keys,
    sprintf('  <graph id="G" edgedefault="%s">', edge_default),
    node_elems,
    edge_elems,
    '  </graph>',
    '</graphml>'
  )

  xml <- paste(lines, collapse = "\n")

  if (is.null(file)) return(xml)

  writeLines(xml, file, useBytes = FALSE)
  message("Written: ", file)
  invisible(file)
}


#' Prepare network for cograph::splot()
#'
#' Converts a bibnets edge list to a `cograph_network` object by calling
#' `cograph::as_cograph()`. Optionally merges node metadata (e.g., from
#' [local_citations()]) into the network's node table so attributes like
#' `lcs` or `year` can be used directly in `splot()` aesthetic parameters
#' (e.g., `node_size = "lcs"`).
#'
#' Note: bibnets edge lists (`from`, `to`, `weight`) are accepted directly
#' by `cograph::splot()` without conversion. This function is only needed
#' when you want to attach node-level metadata.
#'
#' @param edges A data frame with at least `from`, `to`, `weight` columns.
#' @param nodes Optional data frame of node attributes with an `id` column
#'   (e.g., output of [local_citations()]). All other columns are merged into
#'   the node table of the `cograph_network` and become available as
#'   aesthetic mappings.
#' @param directed Logical. Default `FALSE`.
#'
#' @return A `cograph_network` (a list whose `nodes` and `edges` components
#'   are data frames); with `nodes` supplied, its node table gains every
#'   non-`id` column of `nodes`, matched by node label (`NA` where a node
#'   has no metadata row).
#'
#' @export
#' @examplesIf requireNamespace("cograph", quietly = TRUE)
#' data(biblio_data)
#'
#' # Without metadata
#' to_cograph(author_network(biblio_data, "collaboration"))
#'
#' # With metadata: local citation scores attached to a document network
#' to_cograph(document_network(biblio_data, type = "coupling"),
#'            nodes = local_citations(biblio_data))
to_cograph <- function(edges, nodes = NULL, directed = FALSE) {
  if (!requireNamespace("cograph", quietly = TRUE)) {
    stop("Package 'cograph' is required. Install it with: ",
         'install.packages("cograph", repos = "https://mohsaqr.r-universe.dev")',
         call. = FALSE)
  }
  check_edges(edges)

  net <- cograph::as_cograph(edges, directed = directed)

  if (!is.null(nodes)) {
    if (!is.data.frame(nodes) || !"id" %in% names(nodes))
      stop("'nodes' must be a data frame with an 'id' column.", call. = FALSE)
    ## Match node metadata by label (cograph stores node names in $nodes$label)
    attr_cols <- setdiff(names(nodes), "id")
    idx <- match(net$nodes$label, nodes$id)
    for (col in attr_cols) {
      net$nodes[[col]] <- nodes[[col]][idx]
    }
  }

  net
}
