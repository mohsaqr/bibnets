# bibnets 0.4.2

## Documentation

- Title renamed to "Importing, Constructing, and Exporting Bibliometric
  Networks" to reflect the full lifecycle scope.
- Description rewritten to lead with attention-weighted networks (lead,
  last, proximity, circular) and other differentiators (position-aware
  counting, similarity/dissimilarity normalisations, temporal windows,
  disparity-filter backbone, historiograph, local citation scoring),
  dropping the enumeration of standard co-network types.
- README intro re-leads with capabilities; numerical method counts removed.
- Internal-comment author attributions stripped throughout.

# bibnets 0.4.1

## Bug fixes

- `read_lens()` no longer inflates output to `n^2` rows when neither
  `Lens ID` nor `ID` columns are present.
- `read_openalex()` no longer inflates output to `n^2` rows when the `id`
  column is absent.
- `read_scopus()` now normalises empty-string DOIs to `NA`, so
  `is.na(doi)` deduplication checks behave as expected.
- `read_wos()` empty-file return now includes the `keywords_plus`
  list-column to match the non-empty schema.
- `read_crossref()` no longer crashes with "row names contain missing
  values" when the `issued` column has `NA` entries.

## Documentation

- Converter examples (`to_igraph()`, `to_tbl_graph()`, `to_cograph()`) now
  use `@examplesIf requireNamespace(...)` so they execute when the
  suggested package is installed instead of being silently skipped.
- `read_biblio()`, `read_bibtex()`, and `read_ris()` now ship runnable
  examples backed by either the bundled `extdata/openalex_works.csv`
  fixture or a `tempfile()`-based minimal record.
- Reference list streamlined across DESCRIPTION, README, vignette, and
  Rd files.

## Testing

- Added eight new test files covering `read_scopus()`, `read_wos()`,
  `read_ris()`, `read_lens()`, `read_dimensions()`, `read_crossref()`,
  `read_biblio()`, `read_openalex()`, plus dedicated coverage for
  `R/edgelist.R` and `build_bipartite_long()`.
- Suite size: 1268 tests (was 499). Package line coverage: 92.5%
  (was 61.8%).

# bibnets 0.3.0

## New functions

- `temporal_network()` — builds time-windowed networks with fixed, sliding, or
  cumulative strategies. Results include a `window` column for easy stacking.
- `historiograph()` — Garfield-style chronological citation network among the
  most locally cited documents.
- `local_citations()` — counts within-dataset citations (Local Citation Score).
- `backbone()` — disparity filter for extracting statistically significant
  edges from dense weighted networks.
- `prune()` — threshold and top-n edge pruning.
- `read_biblio()` — universal reader with auto-format detection (Scopus, WoS,
  BibTeX, RIS, Dimensions, Lens.org).
- `read_dimensions()` — Dimensions CSV export reader.
- `read_crossref()` — converter for `rcrossref::cr_works()` output.
- `to_gephi()` — exports node and edge tables in Gephi CSV format; writes
  `nodes.csv` + `edges.csv` when a directory path is supplied.
- `to_graphml()` — pure base-R GraphML writer; no XML package required.
- `to_cograph()` — converts edge list to a `cograph_network` object with
  optional node metadata for direct use with `cograph::splot()`.

## Improvements

- All edge list functions now sort output by `weight` descending and reset
  row names.
- `local_citations()` canonical column order: `id`, `lcs`, `gcs`, `year`,
  `title`, `journal`, `doi`.
- `historiograph()` empty-result schema matches non-empty schema.
- All readers share a standard column order: `id`, `title`, `year`, `journal`,
  `doi`, `cited_by_count`, `abstract`, `type`, `authors`, `references`,
  `keywords`, then source-specific extras.
- `backbone()` and `prune()` use single-pass O(m) node statistics via
  `tapply()` / `split()` — faster on large networks.
- `temporal_network()` converted from `for` loop to `lapply`.
- `read_dimensions()` / `read_crossref()` now apply `standardize_authors()`
  and `standardize_refs()` for consistency with other readers.

# bibnets 0.2.0

## Breaking changes

- Argument `count` renamed to `counting`; `measure` renamed to `similarity`
  across all network functions.
- `co_network()` renamed to `conetwork()`.

## New functions

- `read_openalex()` — reads OpenAlex JSON export.
- `filter_top()` — keeps only the top-n most connected nodes.
- `normalize()` — post-hoc normalisation of any edge list.

# bibnets 0.1.0

Initial release.

- 8 network builders: `author_network()`, `document_network()`,
  `reference_network()`, `keyword_network()`, `institution_network()`,
  `country_network()`, `source_network()`, `conetwork()`.
- 13 counting methods including harmonic, geometric, golden ratio, adaptive
  geometric.
- 6 similarity normalisations: association strength, cosine, Jaccard,
  inclusion, equivalence.
- 6 readers: Scopus, Web of Science, OpenAlex, BibTeX, RIS, Lens.org.
- Converters: `to_igraph()`, `to_tbl_graph()`, `to_matrix()`.
- Numerically validated against bibliometrix and biblionetwork.
