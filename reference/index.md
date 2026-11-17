# Package index

## Read scholarly data

Import metadata from Scopus, Web of Science, OpenAlex, BibTeX, RIS,
Lens.org, Dimensions, Crossref, and generic CSV files.

- [`read_biblio()`](https://pak.dynasite.org/bibnets-pkg/reference/read_biblio.md)
  : Read bibliometric data
- [`read_scopus()`](https://pak.dynasite.org/bibnets-pkg/reference/read_scopus.md)
  : Read Scopus CSV export
- [`read_wos()`](https://pak.dynasite.org/bibnets-pkg/reference/read_wos.md)
  : Read Web of Science plaintext or tab-delimited export
- [`read_openalex()`](https://pak.dynasite.org/bibnets-pkg/reference/read_openalex.md)
  : Convert OpenAlex data to bibnets format
- [`read_openalex_csv()`](https://pak.dynasite.org/bibnets-pkg/reference/read_openalex_csv.md)
  : Read a flat OpenAlex CSV export
- [`read_bibtex()`](https://pak.dynasite.org/bibnets-pkg/reference/read_bibtex.md)
  : Read a BibTeX file
- [`read_ris()`](https://pak.dynasite.org/bibnets-pkg/reference/read_ris.md)
  : Read an RIS file
- [`read_lens()`](https://pak.dynasite.org/bibnets-pkg/reference/read_lens.md)
  : Read Lens.org CSV export
- [`read_dimensions()`](https://pak.dynasite.org/bibnets-pkg/reference/read_dimensions.md)
  : Read Dimensions CSV export
- [`read_crossref()`](https://pak.dynasite.org/bibnets-pkg/reference/read_crossref.md)
  : Convert Crossref API data to bibnets format

## Build networks

Construct co-authorship, co-citation, bibliographic coupling, keyword
co-occurrence, source, country, institution, and custom co-networks.

- [`author_network()`](https://pak.dynasite.org/bibnets-pkg/reference/author_network.md)
  : Build an author network
- [`document_network()`](https://pak.dynasite.org/bibnets-pkg/reference/document_network.md)
  : Build a document network
- [`reference_network()`](https://pak.dynasite.org/bibnets-pkg/reference/reference_network.md)
  : Build a reference network
- [`keyword_network()`](https://pak.dynasite.org/bibnets-pkg/reference/keyword_network.md)
  : Build a keyword co-occurrence network
- [`source_network()`](https://pak.dynasite.org/bibnets-pkg/reference/source_network.md)
  : Build a source (journal) network
- [`institution_network()`](https://pak.dynasite.org/bibnets-pkg/reference/institution_network.md)
  : Build an institution network
- [`country_network()`](https://pak.dynasite.org/bibnets-pkg/reference/country_network.md)
  : Build a country network
- [`conetwork()`](https://pak.dynasite.org/bibnets-pkg/reference/conetwork.md)
  : Build a co-occurrence network from any field

## Temporal and historical analysis

Sliding, fixed, and cumulative temporal windows; Garfield
historiographs; local citation scoring.

- [`temporal_network()`](https://pak.dynasite.org/bibnets-pkg/reference/temporal_network.md)
  : Build time-windowed networks
- [`historiograph()`](https://pak.dynasite.org/bibnets-pkg/reference/historiograph.md)
  : Build a historiograph (chronological citation network)
- [`local_citations()`](https://pak.dynasite.org/bibnets-pkg/reference/local_citations.md)
  : Compute local citation scores

## Reduce and filter networks

Backbone extraction, edge thresholding, and top-node filtering.

- [`backbone()`](https://pak.dynasite.org/bibnets-pkg/reference/backbone.md)
  : Extract network backbone using the disparity filter
- [`prune()`](https://pak.dynasite.org/bibnets-pkg/reference/prune.md) :
  Prune a weighted edge list
- [`filter_top()`](https://pak.dynasite.org/bibnets-pkg/reference/filter_top.md)
  : Filter edges to top-n nodes

## Normalize edge weights

- [`normalize()`](https://pak.dynasite.org/bibnets-pkg/reference/normalize.md)
  : Normalize a co-occurrence matrix

## Export networks

Convert edge lists to igraph, tidygraph, cograph, Gephi CSV, GraphML,
and sparse matrices.

- [`to_gephi()`](https://pak.dynasite.org/bibnets-pkg/reference/to_gephi.md)
  : Export to Gephi node and edge tables
- [`to_graphml()`](https://pak.dynasite.org/bibnets-pkg/reference/to_graphml.md)
  : Export to GraphML
- [`to_igraph()`](https://pak.dynasite.org/bibnets-pkg/reference/to_igraph.md)
  : Convert edge data frame to igraph
- [`to_tbl_graph()`](https://pak.dynasite.org/bibnets-pkg/reference/to_tbl_graph.md)
  : Convert edge data frame to tbl_graph
- [`to_matrix()`](https://pak.dynasite.org/bibnets-pkg/reference/to_matrix.md)
  : Convert edge data frame to adjacency matrix
- [`to_cograph()`](https://pak.dynasite.org/bibnets-pkg/reference/to_cograph.md)
  : Prepare network for cograph::splot()

## Author names

Reorder and split author names into components before building author
networks.

- [`parse_names()`](https://pak.dynasite.org/bibnets-pkg/reference/parse_names.md)
  : Reorder and parse author names

## Utilities

- [`split_field()`](https://pak.dynasite.org/bibnets-pkg/reference/split_field.md)
  : Split delimited strings into a list-column
- [`print(`*`<bibnets_network>`*`)`](https://pak.dynasite.org/bibnets-pkg/reference/print.bibnets_network.md)
  : Print a bibnets network edge list
- [`summary(`*`<bibnets_network>`*`)`](https://pak.dynasite.org/bibnets-pkg/reference/summary.bibnets_network.md)
  : Summarise a bibnets network

## Datasets

- [`biblio_data`](https://pak.dynasite.org/bibnets-pkg/reference/biblio_data.md)
  : Example bibliometric dataset
- [`scopus_quantum_cloud`](https://pak.dynasite.org/bibnets-pkg/reference/scopus_quantum_cloud.md)
  : Scopus dataset: green cloud computing and quantization (2020–2025)
- [`learning_analytics`](https://pak.dynasite.org/bibnets-pkg/reference/learning_analytics.md)
  : Learning analytics dataset (OpenAlex)
