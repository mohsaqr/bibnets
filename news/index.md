# Changelog

## bibnets 0.6.0

### Breaking changes

- The example dataset `open_alex_gold_open_access_learning_analytics` is
  renamed to `learning_analytics`. Update `data(...)` calls accordingly.

### New features

- **`id` argument on every network builder.**
  [`author_network()`](https://saqr.me/bibnets-pkg/reference/author_network.md),
  [`keyword_network()`](https://saqr.me/bibnets-pkg/reference/keyword_network.md),
  [`reference_network()`](https://saqr.me/bibnets-pkg/reference/reference_network.md),
  [`document_network()`](https://saqr.me/bibnets-pkg/reference/document_network.md),
  [`source_network()`](https://saqr.me/bibnets-pkg/reference/source_network.md),
  [`country_network()`](https://saqr.me/bibnets-pkg/reference/country_network.md),
  [`institution_network()`](https://saqr.me/bibnets-pkg/reference/institution_network.md),
  [`conetwork()`](https://saqr.me/bibnets-pkg/reference/conetwork.md),
  [`local_citations()`](https://saqr.me/bibnets-pkg/reference/local_citations.md),
  and
  [`historiograph()`](https://saqr.me/bibnets-pkg/reference/historiograph.md)
  gain an `id` argument that names the work-identifier column (the rows
  of the `works x entities` matrix). This completes the custom-column
  workflow introduced in 0.5.0, which had given every *entity* field a
  self-naming argument but still required the *works* column to be named
  `id`.
  - `id = NULL` (default): use an existing `id` column when present,
    otherwise fall back to row numbers (each row is one document). A
    custom data frame with no identifier column now builds without
    error.
  - `id = "paper_id"`: use any named column as the identifier.

  The new argument sits at the end of each signature, so existing
  positional calls are unaffected. If `id` names a column other than
  `"id"` while the data already has a distinct `"id"` column, the call
  errors rather than silently overwriting that column (which might
  itself be an entity field).

### Bug fixes

- [`split_field()`](https://saqr.me/bibnets-pkg/reference/split_field.md)
  (and therefore every builder) now coerces a `factor` entity column to
  character before splitting, instead of failing with “non-character
  argument”. Hand-built data frames with `stringsAsFactors = TRUE` now
  work like character columns.

### Generic reader: map columns by entity name

- `read_biblio(format = "generic", ...)` now takes entity-named
  arguments — `authors`, `keywords`, `references`, `countries`,
  `affiliations`, and `journal` — each naming the source column to map
  onto that standard field. Multi-valued fields are split on `sep` into
  the standard list-column; `journal` is kept scalar. This mirrors the
  network-builder vocabulary, so the same field names are used end to
  end:

  ``` r

  read_biblio("my.csv", format = "generic", id = "paper_id",
              authors = "Author Names", keywords = "Tags", sep = ",")
  ```

  `list_cols` is retained for splitting any further columns in place
  (keeping their original names). Naming any of these columns (or `id`)
  implies `format = "generic"`, so passing `format` is optional:

  ``` r

  read_biblio("my.csv", id = "paper_id", authors = "Author Names", sep = ",")
  ```

### Deprecations

- The generic reader’s `actors` argument is deprecated — the columns it
  named were never only “actors”. Use the entity arguments above (or
  `list_cols` for arbitrary columns). `actors` still works, mapped to
  `list_cols`, with a deprecation warning.

## bibnets 0.5.1

### Documentation

- The README now documents the custom column/separator network-builder
  arguments introduced in 0.5.0: a “Custom Columns and Separators”
  section covers the entity-named column arguments (`authors`,
  `keywords`, `references`, `journal`, `countries`, `affiliations`),
  `sep`, `references_sep`, and `strip_quotes`, with a per-builder
  default-argument table. The deprecated `keyword_network(field = )`
  example was updated to the `keywords =` form.
- No user-facing code changes.

## bibnets 0.5.0

### New features

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
  - [`local_citations()`](https://saqr.me/bibnets-pkg/reference/local_citations.md)
    and
    [`historiograph()`](https://saqr.me/bibnets-pkg/reference/historiograph.md)
    gain `references` + `sep`.

  `sep` accepts any delimiter (`","`, `"|"`, `" and "`, …) and applies
  to the named entity column. The new arguments sit at the end of each
  signature, so existing positional calls are unaffected.

- **`references_sep`** —
  [`author_network()`](https://saqr.me/bibnets-pkg/reference/author_network.md),
  [`country_network()`](https://saqr.me/bibnets-pkg/reference/country_network.md),
  [`institution_network()`](https://saqr.me/bibnets-pkg/reference/institution_network.md),
  and
  [`source_network()`](https://saqr.me/bibnets-pkg/reference/source_network.md)
  gain a `references_sep` argument (default `";"`) so the references
  column used for coupling can have its own separator, independent of
  the entity `sep`. (Reference strings often contain internal commas,
  which is why it is separate.)

- **`strip_quotes`** — every builder gains a `strip_quotes` argument
  (default `TRUE`) that removes surrounding quote characters (straight
  `"`, doubled `""`, and curly quotes) from each entity, so a quoted CSV
  value like `"Alice"` or `""Alice""` is treated as `Alice`. Set
  `strip_quotes = FALSE` to keep quotes as part of the label. Applies to
  both freshly-split strings and entities supplied in a list-column.

- [`parse_names()`](https://saqr.me/bibnets-pkg/reference/parse_names.md):
  optional, standalone utility that reorders author names to
  `"First Last"` and parses each into `first`/`last`/`particle`/`suffix`
  components (attached as the `"parts"` attribute). Handles three
  conventions: `"Last, First"` (comma), the Scopus / bibnets
  `"SURNAME Initials"` label form (`"WANG Y"`, `"AYALA-ROMERO JA"`), and
  `"First Last"`. The `surname_first` argument (`"auto"`/`"yes"`/`"no"`,
  default `"auto"`) controls comma-less interpretation, with
  auto-detection biased toward the bibnets/Scopus convention so native
  bibnets labels parse without extra arguments. Case-insensitive
  (recognises particles in bibnets’ uppercased labels). `format`
  argument selects output style: `"first_last"` (default),
  `"last_initials"` (`"Saqr M."`), or `"last"` (`"Saqr"`). Detects
  group/corporate authors and leaves them, `NA`, and empty strings
  unchanged. Not called by any reader or network builder — entity labels
  are still matched verbatim unless you apply this yourself. Base R
  only; no new dependencies. Documented in detail in
  [`?parse_names`](https://saqr.me/bibnets-pkg/reference/parse_names.md)
  and the new vignette
  [`vignette("parsing-author-names")`](https://saqr.me/bibnets-pkg/articles/parsing-author-names.md).

### Bug fixes

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

### Deprecations

- `keyword_network(field = )` is deprecated in favor of
  `keyword_network(keywords = )`. The old argument still works (with a
  warning) and stays in its original second position, so
  `keyword_network(d, "author_keywords")` is unchanged.

## bibnets 0.4.4

CRAN release: 2026-05-20

### CRAN pre-test fix

- The four `test-equiv-*.R` equivalence suites (vs `bibliometrix` and
  `biblionetwork`) have been moved out of the package into a local-only
  `local_testing_and_equivalence/` directory. These developer checks
  pulled in `data.table`/`biblionetwork`, whose OpenMP parallelism
  caused the “CPU time 4 times elapsed time” NOTE on the Debian r-devel
  pre-test. They remain runnable locally but are no longer part of
  `R CMD check`.
- `bibliometrix`, `biblionetwork`, and `data.table` removed from
  `Suggests` — they were used only by the relocated equivalence tests.
- `tests/testthat.R` keeps a 2-thread BLAS/OpenMP cap as defence for
  [`crossprod()`](https://rdrr.io/r/base/crossprod.html) /
  [`tcrossprod()`](https://rdrr.io/r/base/crossprod.html) in
  [`multiply_bipartite()`](https://saqr.me/bibnets-pkg/reference/multiply_bipartite.md).
- No user-facing code changes.

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
