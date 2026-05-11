# Package index

## Read scholarly data

Import metadata from Scopus, Web of Science, OpenAlex, BibTeX, RIS,
Lens.org, Dimensions, Crossref, and generic CSV files.

- [`read_biblio()`](https://saqr.me/bibnets-pkg/reference/read_biblio.md)
  : Read bibliometric data
- [`read_scopus()`](https://saqr.me/bibnets-pkg/reference/read_scopus.md)
  : Read Scopus CSV export
- [`read_wos()`](https://saqr.me/bibnets-pkg/reference/read_wos.md) :
  Read Web of Science plaintext or tab-delimited export
- [`read_openalex()`](https://saqr.me/bibnets-pkg/reference/read_openalex.md)
  : Convert OpenAlex data to bibnets format
- [`read_openalex_csv()`](https://saqr.me/bibnets-pkg/reference/read_openalex_csv.md)
  : Read a flat OpenAlex CSV export
- [`read_bibtex()`](https://saqr.me/bibnets-pkg/reference/read_bibtex.md)
  : Read a BibTeX file
- [`read_ris()`](https://saqr.me/bibnets-pkg/reference/read_ris.md) :
  Read an RIS file
- [`read_lens()`](https://saqr.me/bibnets-pkg/reference/read_lens.md) :
  Read Lens.org CSV export
- [`read_dimensions()`](https://saqr.me/bibnets-pkg/reference/read_dimensions.md)
  : Read Dimensions CSV export
- [`read_crossref()`](https://saqr.me/bibnets-pkg/reference/read_crossref.md)
  : Convert Crossref API data to bibnets format

## Build networks

Construct co-authorship, co-citation, bibliographic coupling, keyword
co-occurrence, source, country, institution, and custom co-networks.

- [`author_network()`](https://saqr.me/bibnets-pkg/reference/author_network.md)
  : Build an author network
- [`document_network()`](https://saqr.me/bibnets-pkg/reference/document_network.md)
  : Build a document network
- [`reference_network()`](https://saqr.me/bibnets-pkg/reference/reference_network.md)
  : Build a reference network
- [`keyword_network()`](https://saqr.me/bibnets-pkg/reference/keyword_network.md)
  : Build a keyword co-occurrence network
- [`source_network()`](https://saqr.me/bibnets-pkg/reference/source_network.md)
  : Build a source (journal) network
- [`institution_network()`](https://saqr.me/bibnets-pkg/reference/institution_network.md)
  : Build an institution network
- [`country_network()`](https://saqr.me/bibnets-pkg/reference/country_network.md)
  : Build a country network
- [`conetwork()`](https://saqr.me/bibnets-pkg/reference/conetwork.md) :
  Build a co-occurrence network from any field

## Temporal and historical analysis

Sliding, fixed, and cumulative temporal windows; Garfield
historiographs; local citation scoring.

- [`temporal_network()`](https://saqr.me/bibnets-pkg/reference/temporal_network.md)
  : Build time-windowed networks
- [`historiograph()`](https://saqr.me/bibnets-pkg/reference/historiograph.md)
  : Build a historiograph (chronological citation network)
- [`local_citations()`](https://saqr.me/bibnets-pkg/reference/local_citations.md)
  : Compute local citation scores

## Reduce and filter networks

Backbone extraction, edge thresholding, and top-node filtering.

- [`backbone()`](https://saqr.me/bibnets-pkg/reference/backbone.md) :
  Extract network backbone using the disparity filter
- [`prune()`](https://saqr.me/bibnets-pkg/reference/prune.md) : Prune a
  weighted edge list
- [`filter_top()`](https://saqr.me/bibnets-pkg/reference/filter_top.md)
  : Filter edges to top-n nodes

## Normalize edge weights

- [`normalize()`](https://saqr.me/bibnets-pkg/reference/normalize.md) :
  Normalize a co-occurrence matrix

## Export networks

Convert edge lists to igraph, tidygraph, cograph, Gephi CSV, GraphML,
and sparse matrices.

- [`to_gephi()`](https://saqr.me/bibnets-pkg/reference/to_gephi.md) :
  Export to Gephi node and edge tables
- [`to_graphml()`](https://saqr.me/bibnets-pkg/reference/to_graphml.md)
  : Export to GraphML
- [`to_igraph()`](https://saqr.me/bibnets-pkg/reference/to_igraph.md) :
  Convert edge data frame to igraph
- [`to_tbl_graph()`](https://saqr.me/bibnets-pkg/reference/to_tbl_graph.md)
  : Convert edge data frame to tbl_graph
- [`to_matrix()`](https://saqr.me/bibnets-pkg/reference/to_matrix.md) :
  Convert edge data frame to adjacency matrix
- [`to_cograph()`](https://saqr.me/bibnets-pkg/reference/to_cograph.md)
  : Prepare network for cograph::splot()

## Utilities

- [`split_field()`](https://saqr.me/bibnets-pkg/reference/split_field.md)
  : Parse semicolon-delimited strings into list-column
- [`print(`*`<bibnets_network>`*`)`](https://saqr.me/bibnets-pkg/reference/print.bibnets_network.md)
  : Print a bibnets network edge list
- [`summary(`*`<bibnets_network>`*`)`](https://saqr.me/bibnets-pkg/reference/summary.bibnets_network.md)
  : Summarise a bibnets network

## Datasets

- [`biblio_data`](https://saqr.me/bibnets-pkg/reference/biblio_data.md)
  : Example bibliometric dataset
- [`scopus_quantum_cloud`](https://saqr.me/bibnets-pkg/reference/scopus_quantum_cloud.md)
  : Scopus dataset — Green Cloud Computing and Quantization (2020–2025)
- [`open_alex_gold_open_access_learning_analytics`](https://saqr.me/bibnets-pkg/reference/open_alex_gold_open_access_learning_analytics.md)
  : OpenAlex Gold Open Access Learning Analytics dataset
