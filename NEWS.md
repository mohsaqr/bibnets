# bibnets 0.5.0

## New features

- **Custom data sets, any column name, any separator.** Every network
  builder now takes a self-describing column argument plus `sep`, so a
  non-standard CSV works in a single call without renaming columns or
  pre-splitting strings:
  - `author_network(d, authors = "Author Names", sep = ",")`
  - `keyword_network(d, keywords = "Tags", sep = ",")`
  - `reference_network(d, references = "Cited Refs", sep = ",")`
  - `document_network(d, references = "Cited Refs", sep = ",")`
  - `source_network(d, journal = "Source title")`
  - `country_network(d, countries = "Nations", sep = ",")`
  - `institution_network(d, affiliations = "Orgs", sep = ",")`
  - `local_citations()` and `historiograph()` gain `references` + `sep`.

  `sep` accepts any delimiter (`","`, `"|"`, `" and "`, ...) and applies
  to the named entity column. The new arguments sit at the end of each
  signature, so existing positional calls are unaffected.

- **`references_sep`** — `author_network()`, `country_network()`,
  `institution_network()`, and `source_network()` gain a `references_sep`
  argument (default `";"`) so the references column used for coupling can
  have its own separator, independent of the entity `sep`. (Reference
  strings often contain internal commas, which is why it is separate.)

- **`strip_quotes`** — every builder gains a `strip_quotes` argument
  (default `TRUE`) that removes surrounding quote characters (straight
  `"`, doubled `""`, and curly quotes) from each entity, so a quoted CSV
  value like `"Alice"` or `""Alice""` is treated as `Alice`. Set
  `strip_quotes = FALSE` to keep quotes as part of the label. Applies to
  both freshly-split strings and entities supplied in a list-column.

- `parse_names()`: optional, standalone utility that reorders author
  names to `"First Last"` and parses each into
  `first`/`last`/`particle`/`suffix` components (attached as the
  `"parts"` attribute). Handles three conventions: `"Last, First"`
  (comma), the Scopus / bibnets `"SURNAME Initials"` label form
  (`"WANG Y"`, `"AYALA-ROMERO JA"`), and `"First Last"`. The
  `surname_first` argument (`"auto"`/`"yes"`/`"no"`, default `"auto"`)
  controls comma-less interpretation, with auto-detection biased toward
  the bibnets/Scopus convention so native bibnets labels parse without
  extra arguments. Case-insensitive (recognises particles in bibnets'
  uppercased labels). `format` argument selects output style:
  `"first_last"` (default), `"last_initials"` (`"Saqr M."`), or `"last"`
  (`"Saqr"`). Detects group/corporate authors and leaves them, `NA`,
  and empty strings unchanged. Not called by any reader or network
  builder — entity labels are still matched verbatim unless you apply
  this yourself. Base R only; no new dependencies. Documented in
  detail in `?parse_names` and the new vignette
  `vignette("parsing-author-names")`.

## Bug fixes

- Positional counting (`"harmonic"`, `"first"`, etc.) on a plain
  character author column now splits correctly. Previously a delimited
  string was treated as a single author, silently producing a wrong
  network.
- `author_network(type = "co_citation", self_loops = TRUE)` now honors
  `self_loops` (previously ignored).
- `author_network(type = "equivalence")` now forwards `deduplicate`
  (previously ignored).
- A wrong separator (split yields no multi-entry rows, yet most values
  contain a structural delimiter `";"`, `"|"`, or tab) now emits a
  warning instead of silently building a degenerate network. The
  heuristic deliberately ignores commas and `" and "`, which occur
  inside valid single labels (`"Last, First"` names, reference strings,
  `"Smith and Sons"`), so correct data is never warned about.
- `read_biblio(format = "generic")` now warns, listing the available
  columns, when an `actors` column is not found (previously skipped
  silently).

## Deprecations

- `keyword_network(field = )` is deprecated in favor of
  `keyword_network(keywords = )`. The old argument still works (with a
  warning) and stays in its original second position, so
  `keyword_network(d, "author_keywords")` is unchanged.

# bibnets 0.4.4

## CRAN pre-test fix

- The four `test-equiv-*.R` equivalence suites (vs `bibliometrix` and
  `biblionetwork`) have been moved out of the package into a local-only
  `local_testing_and_equivalence/` directory. These developer checks
  pulled in `data.table`/`biblionetwork`, whose OpenMP parallelism caused
  the "CPU time 4 times elapsed time" NOTE on the Debian r-devel
  pre-test. They remain runnable locally but are no longer part of
  `R CMD check`.
- `bibliometrix`, `biblionetwork`, and `data.table` removed from
  `Suggests` — they were used only by the relocated equivalence tests.
- `tests/testthat.R` keeps a 2-thread BLAS/OpenMP cap as defence for
  `crossprod()` / `tcrossprod()` in `multiply_bipartite()`.
- No user-facing code changes.

# bibnets 0.4.3

## CRAN reviewer requests

- All no-run wrappers in reader examples replaced with runnable
  examples, per CRAN reviewer guidance. File-based readers
  (`read_scopus`, `read_wos`, `read_dimensions`, `read_lens`) now use
  small bundled fixtures under `inst/extdata/`, reached via
  `system.file()`. API-wrapper readers (`read_openalex`, `read_crossref`)
  use an inline data frame matching the upstream column shape so the
  conversion path runs without a network call. `read_biblio` examples
  now demonstrate multi-file, directory, and generic-CSV modes against
  the bundled fixtures.
- New fixtures: `inst/extdata/scopus_sample.csv`, `wos_sample.txt`,
  `dimensions_sample.csv`, `lens_sample.csv` (2 records each).

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
