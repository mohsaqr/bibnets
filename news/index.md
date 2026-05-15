# Changelog

## bibnets 0.4.3

### CRAN reviewer requests

- All no-run wrappers in reader examples replaced with runnable
  examples, per CRAN reviewer guidance. File-based readers
  (`read_scopus`, `read_wos`, `read_dimensions`, `read_lens`) now use
  small bundled fixtures under `inst/extdata/`, reached via
  [`system.file()`](https://rdrr.io/r/base/system.file.html).
  API-wrapper readers (`read_openalex`, `read_crossref`) use an inline
  data frame matching the upstream column shape so the conversion path
  runs without a network call. `read_biblio` examples now demonstrate
  multi-file, directory, and generic-CSV modes against the bundled
  fixtures.
- New fixtures: `inst/extdata/scopus_sample.csv`, `wos_sample.txt`,
  `dimensions_sample.csv`, `lens_sample.csv` (2 records each).

## bibnets 0.4.2

### Documentation

- Title renamed to “Importing, Constructing, and Exporting Bibliometric
  Networks” to reflect the full lifecycle scope.
- Description rewritten to lead with attention-weighted networks (lead,
  last, proximity, circular) and other differentiators (position-aware
  counting, similarity/dissimilarity normalisations, temporal windows,
  disparity-filter backbone, historiograph, local citation scoring),
  dropping the enumeration of standard co-network types.
- README intro re-leads with capabilities; numerical method counts
  removed.
- Internal-comment author attributions stripped throughout.

## bibnets 0.4.1

### Bug fixes

- [`read_lens()`](https://saqr.me/bibnets-pkg/reference/read_lens.md) no
  longer inflates output to `n^2` rows when neither `Lens ID` nor `ID`
  columns are present.
- [`read_openalex()`](https://saqr.me/bibnets-pkg/reference/read_openalex.md)
  no longer inflates output to `n^2` rows when the `id` column is
  absent.
- [`read_scopus()`](https://saqr.me/bibnets-pkg/reference/read_scopus.md)
  now normalises empty-string DOIs to `NA`, so `is.na(doi)`
  deduplication checks behave as expected.
- [`read_wos()`](https://saqr.me/bibnets-pkg/reference/read_wos.md)
  empty-file return now includes the `keywords_plus` list-column to
  match the non-empty schema.
- [`read_crossref()`](https://saqr.me/bibnets-pkg/reference/read_crossref.md)
  no longer crashes with “row names contain missing values” when the
  `issued` column has `NA` entries.

### Documentation

- Converter examples
  ([`to_igraph()`](https://saqr.me/bibnets-pkg/reference/to_igraph.md),
  [`to_tbl_graph()`](https://saqr.me/bibnets-pkg/reference/to_tbl_graph.md),
  [`to_cograph()`](https://saqr.me/bibnets-pkg/reference/to_cograph.md))
  now use `@examplesIf requireNamespace(...)` so they execute when the
  suggested package is installed instead of being silently skipped.
- [`read_biblio()`](https://saqr.me/bibnets-pkg/reference/read_biblio.md),
  [`read_bibtex()`](https://saqr.me/bibnets-pkg/reference/read_bibtex.md),
  and [`read_ris()`](https://saqr.me/bibnets-pkg/reference/read_ris.md)
  now ship runnable examples backed by either the bundled
  `extdata/openalex_works.csv` fixture or a
  [`tempfile()`](https://rdrr.io/r/base/tempfile.html)-based minimal
  record.
- Reference list streamlined across DESCRIPTION, README, vignette, and
  Rd files.

### Testing

- Added eight new test files covering
  [`read_scopus()`](https://saqr.me/bibnets-pkg/reference/read_scopus.md),
  [`read_wos()`](https://saqr.me/bibnets-pkg/reference/read_wos.md),
  [`read_ris()`](https://saqr.me/bibnets-pkg/reference/read_ris.md),
  [`read_lens()`](https://saqr.me/bibnets-pkg/reference/read_lens.md),
  [`read_dimensions()`](https://saqr.me/bibnets-pkg/reference/read_dimensions.md),
  [`read_crossref()`](https://saqr.me/bibnets-pkg/reference/read_crossref.md),
  [`read_biblio()`](https://saqr.me/bibnets-pkg/reference/read_biblio.md),
  [`read_openalex()`](https://saqr.me/bibnets-pkg/reference/read_openalex.md),
  plus dedicated coverage for `R/edgelist.R` and
  [`build_bipartite_long()`](https://saqr.me/bibnets-pkg/reference/build_bipartite_long.md).
- Suite size: 1268 tests (was 499). Package line coverage: 92.5% (was
  61.8%).

## bibnets 0.3.0

### New functions

- [`temporal_network()`](https://saqr.me/bibnets-pkg/reference/temporal_network.md)
  — builds time-windowed networks with fixed, sliding, or cumulative
  strategies. Results include a `window` column for easy stacking.
- [`historiograph()`](https://saqr.me/bibnets-pkg/reference/historiograph.md)
  — Garfield-style chronological citation network among the most locally
  cited documents.
- [`local_citations()`](https://saqr.me/bibnets-pkg/reference/local_citations.md)
  — counts within-dataset citations (Local Citation Score).
- [`backbone()`](https://saqr.me/bibnets-pkg/reference/backbone.md) —
  disparity filter for extracting statistically significant edges from
  dense weighted networks.
- [`prune()`](https://saqr.me/bibnets-pkg/reference/prune.md) —
  threshold and top-n edge pruning.
- [`read_biblio()`](https://saqr.me/bibnets-pkg/reference/read_biblio.md)
  — universal reader with auto-format detection (Scopus, WoS, BibTeX,
  RIS, Dimensions, Lens.org).
- [`read_dimensions()`](https://saqr.me/bibnets-pkg/reference/read_dimensions.md)
  — Dimensions CSV export reader.
- [`read_crossref()`](https://saqr.me/bibnets-pkg/reference/read_crossref.md)
  — converter for
  [`rcrossref::cr_works()`](https://docs.ropensci.org/rcrossref/reference/cr_works.html)
  output.
- [`to_gephi()`](https://saqr.me/bibnets-pkg/reference/to_gephi.md) —
  exports node and edge tables in Gephi CSV format; writes `nodes.csv` +
  `edges.csv` when a directory path is supplied.
- [`to_graphml()`](https://saqr.me/bibnets-pkg/reference/to_graphml.md)
  — pure base-R GraphML writer; no XML package required.
- [`to_cograph()`](https://saqr.me/bibnets-pkg/reference/to_cograph.md)
  — converts edge list to a `cograph_network` object with optional node
  metadata for direct use with
  [`cograph::splot()`](https://sonsoles.me/cograph/reference/splot.html).

### Improvements

- All edge list functions now sort output by `weight` descending and
  reset row names.
- [`local_citations()`](https://saqr.me/bibnets-pkg/reference/local_citations.md)
  canonical column order: `id`, `lcs`, `gcs`, `year`, `title`,
  `journal`, `doi`.
- [`historiograph()`](https://saqr.me/bibnets-pkg/reference/historiograph.md)
  empty-result schema matches non-empty schema.
- All readers share a standard column order: `id`, `title`, `year`,
  `journal`, `doi`, `cited_by_count`, `abstract`, `type`, `authors`,
  `references`, `keywords`, then source-specific extras.
- [`backbone()`](https://saqr.me/bibnets-pkg/reference/backbone.md) and
  [`prune()`](https://saqr.me/bibnets-pkg/reference/prune.md) use
  single-pass O(m) node statistics via
  [`tapply()`](https://rdrr.io/r/base/tapply.html) /
  [`split()`](https://rdrr.io/r/base/split.html) — faster on large
  networks.
- [`temporal_network()`](https://saqr.me/bibnets-pkg/reference/temporal_network.md)
  converted from `for` loop to `lapply`.
- [`read_dimensions()`](https://saqr.me/bibnets-pkg/reference/read_dimensions.md)
  /
  [`read_crossref()`](https://saqr.me/bibnets-pkg/reference/read_crossref.md)
  now apply
  [`standardize_authors()`](https://saqr.me/bibnets-pkg/reference/standardize_authors.md)
  and `standardize_refs()` for consistency with other readers.

## bibnets 0.2.0

### Breaking changes

- Argument `count` renamed to `counting`; `measure` renamed to
  `similarity` across all network functions.
- `co_network()` renamed to
  [`conetwork()`](https://saqr.me/bibnets-pkg/reference/conetwork.md).

### New functions

- [`read_openalex()`](https://saqr.me/bibnets-pkg/reference/read_openalex.md)
  — reads OpenAlex JSON export.
- [`filter_top()`](https://saqr.me/bibnets-pkg/reference/filter_top.md)
  — keeps only the top-n most connected nodes.
- [`normalize()`](https://saqr.me/bibnets-pkg/reference/normalize.md) —
  post-hoc normalisation of any edge list.

## bibnets 0.1.0

Initial release.

- 8 network builders:
  [`author_network()`](https://saqr.me/bibnets-pkg/reference/author_network.md),
  [`document_network()`](https://saqr.me/bibnets-pkg/reference/document_network.md),
  [`reference_network()`](https://saqr.me/bibnets-pkg/reference/reference_network.md),
  [`keyword_network()`](https://saqr.me/bibnets-pkg/reference/keyword_network.md),
  [`institution_network()`](https://saqr.me/bibnets-pkg/reference/institution_network.md),
  [`country_network()`](https://saqr.me/bibnets-pkg/reference/country_network.md),
  [`source_network()`](https://saqr.me/bibnets-pkg/reference/source_network.md),
  [`conetwork()`](https://saqr.me/bibnets-pkg/reference/conetwork.md).
- 13 counting methods including harmonic, geometric, golden ratio,
  adaptive geometric.
- 6 similarity normalisations: association strength, cosine, Jaccard,
  inclusion, equivalence.
- 6 readers: Scopus, Web of Science, OpenAlex, BibTeX, RIS, Lens.org.
- Converters:
  [`to_igraph()`](https://saqr.me/bibnets-pkg/reference/to_igraph.md),
  [`to_tbl_graph()`](https://saqr.me/bibnets-pkg/reference/to_tbl_graph.md),
  [`to_matrix()`](https://saqr.me/bibnets-pkg/reference/to_matrix.md).
- Numerically validated against bibliometrix and biblionetwork.
