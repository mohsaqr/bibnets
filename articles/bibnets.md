# Getting Started with bibnets

``` r

library(bibnets)
```

## Introduction

`bibnets` imports scholarly metadata and constructs bibliometric
networks from works, authors, references, keywords, sources, countries,
and institutions. It represents co-authorship, co-citation,
bibliographic coupling, keyword co-occurrence, direct citation,
historiograph, and custom co-occurrence analyses as network edge lists.

### Input and imports

[`read_biblio()`](https://saqr.me/bibnets-pkg/reference/read_biblio.md)
is the entry point for file-based input. It accepts a file, a set of
files, or a directory, detects supported file exports when
`format = "auto"`, and dispatches to the corresponding reader. The file
readers cover Scopus CSV with
[`read_scopus()`](https://saqr.me/bibnets-pkg/reference/read_scopus.md),
Web of Science plain-text and tab-delimited exports with
[`read_wos()`](https://saqr.me/bibnets-pkg/reference/read_wos.md), flat
OpenAlex CSV with
[`read_openalex_csv()`](https://saqr.me/bibnets-pkg/reference/read_openalex_csv.md),
BibTeX with
[`read_bibtex()`](https://saqr.me/bibnets-pkg/reference/read_bibtex.md),
RIS with
[`read_ris()`](https://saqr.me/bibnets-pkg/reference/read_ris.md),
Lens.org CSV with
[`read_lens()`](https://saqr.me/bibnets-pkg/reference/read_lens.md),
Dimensions CSV with
[`read_dimensions()`](https://saqr.me/bibnets-pkg/reference/read_dimensions.md),
and generic CSV input through `read_biblio(format = "generic")` or
inferred generic input when source columns are mapped by name. OpenAlex
records returned by
[`openalexR::oa_fetch()`](https://docs.ropensci.org/openalexR/reference/oa_fetch.html)
are converted with
[`read_openalex()`](https://saqr.me/bibnets-pkg/reference/read_openalex.md).
Crossref records returned by
[`rcrossref::cr_works()`](https://docs.ropensci.org/rcrossref/reference/cr_works.html)
are converted with
[`read_crossref()`](https://saqr.me/bibnets-pkg/reference/read_crossref.md).

The source-specific readers return a common data frame with `id`,
`title`, `year`, `journal`, `doi`, `cited_by_count`, `abstract`, `type`,
and list-columns such as `authors`, `references`, and `keywords`.
Source-specific fields, including `countries`, `affiliations`,
`index_keywords`, and `keywords_plus`, are kept when present.

### Network construction

Network construction follows the same matrix path across builders. A
works-by-entities bipartite matrix is created by
[`build_bipartite()`](https://saqr.me/bibnets-pkg/reference/build_bipartite.md)
or, for position-dependent weighting, by
[`build_author_bipartite()`](https://saqr.me/bibnets-pkg/reference/build_author_bipartite.md).
The matrix is weighted by
[`apply_counting()`](https://saqr.me/bibnets-pkg/reference/apply_counting.md)
or by positional weights, projected by
[`multiply_bipartite()`](https://saqr.me/bibnets-pkg/reference/multiply_bipartite.md),
and returned by `as_bibnets_network()`.

The counting methods are `"full"`, `"fractional"`, `"paper"`,
`"strength"`, `"harmonic"`, `"arithmetic"`, `"geometric"`,
`"adaptive_geometric"`, `"golden"`, `"first"`, `"last"`, `"first_last"`,
and `"position_weighted"`. The attention profiles are `"lead"`,
`"last"`, `"proximity"`, and `"circular"`; in the implementation these
map to `"attention_lead"`, `"attention_last"`, `"attention_proximity"`,
and `"attention_circular"` positional weights. Attention weighting is
available for author, keyword, country, and institution networks.

Projected matrices can be returned as raw counts with `"none"` or
normalized with `"cosine"`, `"association"`, `"jaccard"`, `"inclusion"`,
or `"equivalence"`. The same similarity names are accepted by
[`normalize()`](https://saqr.me/bibnets-pkg/reference/normalize.md).

### Speed

The incidence matrix is stored as a sparse `dgCMatrix`. Projection uses
[`crossprod()`](https://rdrr.io/r/base/crossprod.html) for column-mode
networks and [`tcrossprod()`](https://rdrr.io/r/base/crossprod.html) for
row-mode networks, and edge extraction is performed from the sparse
projected matrix without materializing a dense matrix. Memory use
follows the number of non-zero matrix entries and retained edges rather
than the size of a dense node-by-node matrix. The hard dependencies are
Matrix, stats, and utils.

### Exports

The default return value is an edge list. Export and conversion
functions are
[`to_igraph()`](https://saqr.me/bibnets-pkg/reference/to_igraph.md),
[`to_tbl_graph()`](https://saqr.me/bibnets-pkg/reference/to_tbl_graph.md),
[`to_cograph()`](https://saqr.me/bibnets-pkg/reference/to_cograph.md),
[`to_gephi()`](https://saqr.me/bibnets-pkg/reference/to_gephi.md),
[`to_graphml()`](https://saqr.me/bibnets-pkg/reference/to_graphml.md),
and [`to_matrix()`](https://saqr.me/bibnets-pkg/reference/to_matrix.md).
[`to_gephi()`](https://saqr.me/bibnets-pkg/reference/to_gephi.md) writes
or returns Gephi-ready node and edge CSV tables.
[`to_graphml()`](https://saqr.me/bibnets-pkg/reference/to_graphml.md)
writes or returns GraphML.
[`to_matrix()`](https://saqr.me/bibnets-pkg/reference/to_matrix.md)
returns a sparse adjacency matrix.

### Output

Every builder returns a **`bibnets_network`**: a tidy data frame with
four columns —

- `from`, `to` — the two endpoints of an edge,
- `count` — the raw binary co-occurrence count for that pair,
- `weight` — the analytical weight after counting and optional
  similarity normalization.

With `counting = "full"` and `similarity = "none"`, `weight` equals
`count`. They diverge once fractional counting or a similarity measure
is applied.

The builders, at a glance:

| Function | Nodes | An edge means |
|----|----|----|
| [`author_network()`](https://saqr.me/bibnets-pkg/reference/author_network.md) | authors | co-authorship, author coupling, or co-citation |
| [`reference_network()`](https://saqr.me/bibnets-pkg/reference/reference_network.md) | cited references | two references cited together |
| [`document_network()`](https://saqr.me/bibnets-pkg/reference/document_network.md) | documents | shared references, shared citers, or direct citation |
| [`keyword_network()`](https://saqr.me/bibnets-pkg/reference/keyword_network.md) | keywords | two keywords appear together |
| [`source_network()`](https://saqr.me/bibnets-pkg/reference/source_network.md) | journals | sources share references or are co-cited |
| [`country_network()`](https://saqr.me/bibnets-pkg/reference/country_network.md) | countries | countries collaborate or share references |
| [`institution_network()`](https://saqr.me/bibnets-pkg/reference/institution_network.md) | institutions | institutions collaborate or share references |
| [`conetwork()`](https://saqr.me/bibnets-pkg/reference/conetwork.md) | any field | entities co-occur, or share values of another field |
| [`local_citations()`](https://saqr.me/bibnets-pkg/reference/local_citations.md) | documents | within-corpus citation counts |
| [`historiograph()`](https://saqr.me/bibnets-pkg/reference/historiograph.md) | documents | directed citation history among top-cited papers |
| [`temporal_network()`](https://saqr.me/bibnets-pkg/reference/temporal_network.md) | any builder’s nodes | the same network over time windows |

## Quick start

You do **not** need a special reader. Any data frame with one row per
paper works — point a builder at the column that holds the entity and
tell it the delimiter:

``` r

papers <- data.frame(
  `Author Names` = c("Smith J, Doe A, Lee K", "Smith J, Lee K",
                     "Doe A, Lee K", "Smith J, Doe A"),
  check.names = FALSE
)

author_network(papers, authors = "Author Names", sep = ",")
#> # bibnets network: author_collaboration | 3 nodes · 3 edges | counting: full 
#>    from   to       weight  count
#> 1  DOE A  LEE K         2      2
#> 2  DOE A  SMITH J       2      2
#> 3  LEE K  SMITH J       2      2
```

If your data is a scholarly export instead, read it first — the format
is detected from the file content — then build with the defaults:

``` r

data    <- read_biblio("scopus.csv")
authors <- author_network(data, type = "collaboration")
```

Either way the result is the same four-column edge list, ready to
inspect, prune, or export.

## Reading your own data

### Scholarly exports

[`read_biblio()`](https://saqr.me/bibnets-pkg/reference/read_biblio.md)
accepts a file, a folder, or several files, and detects Scopus, Web of
Science, OpenAlex, BibTeX, RIS, Lens.org, and Dimensions from the
content:

``` r

data <- read_biblio("export.csv")
data <- read_biblio("folder_with_exports/")
data <- read_biblio(c("part_1.csv", "part_2.csv"))
```

The format-specific readers can also be called directly
([`read_scopus()`](https://saqr.me/bibnets-pkg/reference/read_scopus.md),
[`read_wos()`](https://saqr.me/bibnets-pkg/reference/read_wos.md),
[`read_openalex_csv()`](https://saqr.me/bibnets-pkg/reference/read_openalex_csv.md),
[`read_dimensions()`](https://saqr.me/bibnets-pkg/reference/read_dimensions.md),
[`read_lens()`](https://saqr.me/bibnets-pkg/reference/read_lens.md),
[`read_bibtex()`](https://saqr.me/bibnets-pkg/reference/read_bibtex.md),
[`read_ris()`](https://saqr.me/bibnets-pkg/reference/read_ris.md)).

### A custom CSV

For a CSV that matches no known export, map each source column onto a
standard field **by name** — `authors`, `keywords`, `references`,
`countries`, `affiliations`, or `journal`. Naming any of them reads the
file as a generic CSV, so you do not pass `format` yourself:

``` r

data <- read_biblio(
  "custom.csv",
  id       = "paper_id",
  authors  = "Author Names",
  keywords = "Tags",
  sep      = ","
)
```

Each mapped column is split on `sep` into the standard list-column, so
afterwards every builder works with its defaults.

### A plain data frame, directly

As the quick start showed, you can skip the reader entirely and let the
builder split a column for you. The same column arguments are available
on every builder:

``` r

author_network(my_df, authors = "Author Names", sep = ",")
keyword_network(my_df, keywords = "Tags",       sep = ",")
```

The work identifier is the `id` column. You need not supply one: when no
`id` column is present each row is treated as one document; pass
`id = "paper_id"` to use a differently-named column. Surrounding quotes
are stripped by default (`strip_quotes = TRUE`), and in a coupling
network the references column takes its own `references_sep`. The
companion
[`vignette("reading-data")`](https://saqr.me/bibnets-pkg/articles/reading-data.md)
covers every reader and these options in full.

### The standard schema

Readers return a common set of columns:

``` r

data(scopus_quantum_cloud)
sc <- scopus_quantum_cloud
names(sc)[1:12]
#>  [1] "id"             "title"          "year"           "journal"       
#>  [5] "doi"            "cited_by_count" "abstract"       "type"          
#>  [9] "authors"        "references"     "keywords"       "affiliations"
```

The columns that matter for network construction are `id`, the
list-columns `authors` / `references` / `keywords`, and `year` (used by
[`temporal_network()`](https://saqr.me/bibnets-pkg/reference/temporal_network.md)).
Source-specific extras such as `countries`, `affiliations`, and
`keywords_plus` are kept when available.

## Datasets used here

``` r

data(biblio_data)
data(learning_analytics)

small <- biblio_data            # tiny, synthetic
oa    <- learning_analytics     # 1,508 OpenAlex records on learning analytics

c(small = nrow(small), scopus = nrow(sc), openalex = nrow(oa))
#>    small   scopus openalex 
#>       10      499     1508
```

## Author collaboration

Two authors are linked when they appear on the same paper:

``` r

authors <- author_network(oa, type = "collaboration")
head(authors, 5)
#> # bibnets network: author_collaboration | 9 nodes · 5 edges | counting: full 
#>    from                        to                          weight  count
#> 1  MOHAMMED SAQR               SONSOLES LÓPEZ‐PERNAS        19     19
#> 2  CRISTIAN CECHINEL           ROBERTO MUÑOZ                  11     11
#> 3  DRAGAN GAŠEVIĆ            ROBERTO MARTÍNEZ‐MALDONADO      10     10
#> 4  ROBERTO MARTÍNEZ‐MALDONADO  VANESSA ECHEVERRÍA             10     10
#> 5  FERNANDA PIRES              MARCELA PESSOA                   8      8
summary(authors)
#> bibnets network
#> ------------------------------
#> Type       : author_collaboration
#> Counting   : full
#> Similarity : none
#> Nodes      : 4029
#> Edges      : 12270
#> Density    : 0.0015
#> Weight     : min 1  median 1  max 19
#> Top nodes  : DRAGAN GAŠEVIĆ(89), ARI KORHONEN(60), CLAUDIA SZABO(60), JUDY SHEARD(60), PAUL DENNY(56)
```

Use `min_occur` to drop rare authors before projection:

``` r

nrow(author_network(oa, type = "collaboration"))
#> [1] 12270
nrow(author_network(oa, type = "collaboration", min_occur = 2))
#> [1] 1362
```

### Counting methods

`counting` controls how much each paper contributes to an edge:

``` r

head(author_network(small, type = "collaboration", counting = "full"), 3)
#> # bibnets network: author_collaboration | 4 nodes · 3 edges | counting: full 
#>    from     to       weight  count
#> 1  CHEN W   LEE K         3      3
#> 2  BROWN M  SMITH J       3      3
#> 3  BROWN M  LEE K         2      2
head(author_network(small, type = "collaboration", counting = "fractional"), 3)
#> # bibnets network: author_collaboration | 5 nodes · 3 edges | counting: fractional 
#>    from     to       weight  count
#> 1  CHEN W   LEE K         2      3
#> 2  BROWN M  SMITH J       2      3
#> 3  JONES A  SMITH J     1.5      2
head(author_network(small, type = "collaboration", counting = "harmonic"), 3)
#> # bibnets network: author_collaboration | 5 nodes · 3 edges | counting: harmonic 
#>    from     to       weight  count
#> 1  BROWN M  SMITH J  0.4702      3
#> 2  JONES A  SMITH J   0.371      2
#> 3  CHEN W   LEE K    0.3214      3
head(author_network(small, type = "collaboration", counting = "first_last"), 3)
#> # bibnets network: author_collaboration | 5 nodes · 3 edges | counting: first_last 
#>    from     to       weight  count
#> 1  BROWN M  SMITH J    0.49      3
#> 2  CHEN W   LEE K      0.41      3
#> 3  JONES A  SMITH J    0.33      2
```

- `"full"` — every observed co-occurrence counts 1 (use for raw events).
- `"fractional"` — scaled by list size so large teams don’t dominate.
- `"harmonic"` / `"first_last"` and other position methods — only when
  author order is analytically meaningful.

### Attention weights

`attention` applies a smooth positional profile instead of a named
counting scheme (available for author, keyword, country, and institution
networks):

``` r

head(author_network(small, attention = "lead"), 3)
#> # bibnets network: author_attention_lead | 4 nodes · 3 edges | counting: lead 
#>    from     to       weight  count
#> 1  BROWN M  SMITH J  0.3896      3
#> 2  JONES A  SMITH J  0.3437      2
#> 3  JONES A  LEE K    0.2041      2
```

| `attention`   | Highest weight at |
|---------------|-------------------|
| `"lead"`      | first position    |
| `"last"`      | last position     |
| `"proximity"` | middle positions  |
| `"circular"`  | first and last    |

## Reference co-citation

Two references are linked when a paper cites both:

``` r

refs <- reference_network(sc, min_occur = 2)
head(refs, 5)
#> # bibnets network: reference_co_citation | 7 nodes · 5 edges | counting: full 
#>    from                            to                              weight  count
#> 1  HE K., ZHANG X., REN S., SUN …  SIMONYAN K., ZISSERMAN A., VE…      10     10
#> 2  HE K., ZHANG X., REN S., SUN …  SANDLER M., HOWARD A., ZHU M.…       8      8
#> 3  HAN S., MAO H., DALLY W.J., D…  SIMONYAN K., ZISSERMAN A., VE…       8      8
#> 4  HE K., ZHANG X., REN S., SUN …  SIMONYAN K., ZISSERMAN A., VE…       8      8
#> 5  KRIZHEVSKY A., HINTON G., LEA…  SIMONYAN K., ZISSERMAN A., VE…       7      7
```

A similarity measure offsets the advantage of very frequently cited
works:

``` r

head(reference_network(sc, min_occur = 2, similarity = "cosine"), 3)
#> # bibnets network: reference_co_citation | 6 nodes · 3 edges | counting: full | similarity: cosine 
#>    from                            to                              weight  count
#> 1  ANDRI R., CAVIGELLI L., ROSSI…  CAPOTONDI A., RUSCI M., FARIS…       1      2
#> 2  BAI Y., ZENG B., LI C., ZHANG…  CASTELLI M., CLEMENTE F.M., P…       1      2
#> 3  CHEN K., ET AL., A DNN OPTIMI…  CHEN Y., ET AL., SAMBA: SINGL…       1      2
```

## Document coupling and citation

Coupling links two documents that share cited references:

``` r

head(document_network(sc, type = "coupling", similarity = "cosine"), 5)
#> # bibnets network: document_coupling | 10 nodes · 5 edges | counting: full | similarity: cosine 
#>    from                to                  weight  count
#> 1  2-s2.0-85169545148  2-s2.0-85150169631  0.4671     12
#> 2  2-s2.0-85203687776  2-s2.0-85200587918  0.3872     10
#> 3  2-s2.0-85131677679  2-s2.0-85172072697  0.3424      7
#> 4  2-s2.0-85187392673  2-s2.0-85124224751   0.269     11
#> 5  2-s2.0-85161914543  2-s2.0-85100337829  0.2443     13
```

Direct citation is directed — `from` cites `to` — and only within the
corpus (the cited work must also be a row in the data):

``` r

head(document_network(sc, type = "citation"), 5)
#> # bibnets network: document_citation | 0 nodes · 0 edges | counting: full
```

## Keyword co-occurrence

``` r

kw <- keyword_network(sc, min_occur = 2)
head(kw, 5)
#> # bibnets network: keyword_co_occurrence | 5 nodes · 5 edges | counting: full 
#>    from            to              weight  count
#> 1  EDGE COMPUTING  QUANTIZATION        16     16
#> 2  DEEP LEARNING   QUANTIZATION        14     14
#> 3  DEEP LEARNING   EDGE COMPUTING      13     13
#> 4  DEEP LEARNING   FPGA                10     10
#> 5  PRUNING         QUANTIZATION        10     10
```

Labels are trimmed and upper-cased during construction, so
`machine learning`, `Machine Learning`, and `MACHINE LEARNING` are one
node. Association strength is a common choice for co-occurrence maps:

``` r

head(keyword_network(sc, min_occur = 2, similarity = "association"), 3)
#> # bibnets network: keyword_co_occurrence | 6 nodes · 3 edges | counting: full | similarity: association 
#>    from                    to                          weight  count
#> 1  AIR QUALITY PREDICTION  POST-TRAINING QUANTISATION     0.5      2
#> 2  LFSR SEED               QUANTIZATION (SIGNAL)          0.5      2
#> 3  BOOTH MULTIPLIERS       SHIFT MULTIPLIERS              0.5      2
```

## Countries, institutions, and sources

``` r

head(country_network(oa, counting = "fractional"), 5)
#> # bibnets network: country_collaboration | 8 nodes · 5 edges | counting: fractional 
#>    from  to  weight  count
#> 1  BR    CL     9.7     11
#> 2  CA    US     9.5     13
#> 3  AU    US   8.967     15
#> 4  DE    NL   8.311     10
#> 5  CN    US     8.2     11
head(institution_network(oa, counting = "fractional", min_occur = 2), 5)
#> # bibnets network: institution_collaboration | 10 nodes · 5 edges | counting: fractional 
#>    from                            to                             weight  count
#> 1  FINLAND UNIVERSITY              UNIVERSITY OF EASTERN FINLAND   5.778     13
#> 2  MAASTRICHT SCHOOL OF MANAGEME…  MAASTRICHT UNIVERSITY           4.833      6
#> 3  ESCUELA SUPERIOR POLITECNICA …  MONASH UNIVERSITY               4.667      6
#> 4  UNIVERSIDADE FEDERAL DE SANTA…  UNIVERSITY OF VALPARAÍSO       4.417     10
#> 5  KUMAMOTO UNIVERSITY             KYUSHU UNIVERSITY                   4      4
head(source_network(sc, type = "coupling", min_occur = 2), 5)
#> # bibnets network: source_coupling | 5 nodes · 5 edges | counting: full 
#>    from                            to                              weight  count
#> 1  IEEE TRANSACTIONS ON CIRCUITS…  IEEE TRANSACTIONS ON COMPUTER…      48     48
#> 2  IEEE TRANSACTIONS ON CIRCUITS…  PROCEEDINGS OF THE IEEE             40     40
#> 3  IEEE TRANSACTIONS ON CIRCUITS…  IEEE TRANSACTIONS ON VERY LAR…      39     39
#> 4  IEEE JOURNAL OF SOLID-STATE C…  IEEE TRANSACTIONS ON CIRCUITS…      31     31
#> 5  IEEE TRANSACTIONS ON COMPUTER…  IEEE TRANSACTIONS ON VERY LAR…      29     29
```

For coupling networks, `min_occur` is applied to the aggregated entity
before the network is built.

## Generic co-networks

[`conetwork()`](https://saqr.me/bibnets-pkg/reference/conetwork.md)
covers projections without a dedicated wrapper. One field links entities
that co-occur; a second field (`by`) links them through a shared value:

``` r

head(conetwork(sc, "keywords", min_occur = 2), 3)
#> # bibnets network: keywords_co_occurrence | 3 nodes · 3 edges | counting: full 
#>    from            to              weight  count
#> 1  EDGE COMPUTING  QUANTIZATION        16     16
#> 2  DEEP LEARNING   QUANTIZATION        14     14
#> 3  DEEP LEARNING   EDGE COMPUTING      13     13
head(conetwork(sc, "authors", by = "keywords", min_occur = 2), 3)
#> # bibnets network: authors_by_keywords | 6 nodes · 3 edges | counting: full 
#>    from       to                 weight  count
#> 1  CAI H      LIU B                  36     36
#> 2  WANG Y     YIN S                  30     30
#> 3  AMROUCH H  ANAGNOSTOPOULOS I      24     24
```

The second result links authors through shared keywords — a thematic
similarity network, not a co-authorship one.

## Normalization

The same raw counts support different similarity scores; only `weight`
changes, `count` does not:

``` r

none <- keyword_network(sc, min_occur = 2, similarity = "none")
cos  <- keyword_network(sc, min_occur = 2, similarity = "cosine")
head(none[, c("from", "to", "weight", "count")], 3)
#> # bibnets network: unknown | 3 nodes · 3 edges 
#>    from            to              weight  count
#> 1  EDGE COMPUTING  QUANTIZATION        16     16
#> 2  DEEP LEARNING   QUANTIZATION        14     14
#> 3  DEEP LEARNING   EDGE COMPUTING      13     13
head(cos[,  c("from", "to", "weight", "count")], 3)
#> # bibnets network: unknown | 6 nodes · 3 edges 
#>    from                    to                          weight  count
#> 1  AIR QUALITY PREDICTION  POST-TRAINING QUANTISATION       1      2
#> 2  LFSR SEED               QUANTIZATION (SIGNAL)            1      2
#> 3  BOOTH MULTIPLIERS       SHIFT MULTIPLIERS                1      2
```

Use `"none"` for raw weights, `"cosine"` for overlap scaled by size,
`"association"` to emphasize pairs that co-occur more than expected, and
`"jaccard"` / `"inclusion"` / `"equivalence"` to match a downstream
convention.

## Reducing large networks

``` r

edges <- author_network(oa, type = "collaboration")
c(all        = nrow(edges),
  threshold  = nrow(prune(edges, threshold = 2)),
  top_n      = nrow(prune(edges, top_n = 5)),
  top_nodes  = nrow(filter_top(edges, n = 50)))
#>       all threshold     top_n top_nodes 
#>     12270       779     12188       956
```

- `prune(threshold = x)` — absolute edge-weight cutoff.
- `prune(top_n = k)` — keep each node’s strongest edges.
- `filter_top(n = k)` — keep edges among the most-connected nodes.

[`backbone()`](https://saqr.me/bibnets-pkg/reference/backbone.md)
applies the disparity filter, which keeps edges that are strong relative
to a node’s local strength distribution — not a global cutoff:

``` r

bb <- backbone(edges, alpha = 0.05)
nrow(bb)
#> [1] 232
```

## Temporal networks

[`temporal_network()`](https://saqr.me/bibnets-pkg/reference/temporal_network.md)
runs any builder over time windows (fixed, sliding, or cumulative):

``` r

tn <- temporal_network(oa, author_network, "collaboration", window = 3)
names(tn)
#> [1] "2011-2013" "2014-2016" "2017-2019" "2020-2022" "2023-2025" "2026-2026"
```

Each window’s edge list carries a `window` column. Windows with fewer
than two records, or no surviving edges, are dropped; a builder error
inside a window becomes a warning labelled with that window.

## Local citations and historiographs

[`local_citations()`](https://saqr.me/bibnets-pkg/reference/local_citations.md)
counts how often each document is cited by others in the same corpus;
[`historiograph()`](https://saqr.me/bibnets-pkg/reference/historiograph.md)
builds the directed citation graph among the top-cited documents:

``` r

head(local_citations(sc), 5)
#>                    id lcs gcs year
#> 1 2-s2.0-105007159281   0   0 2025
#> 2 2-s2.0-105006878874   0   0 2025
#> 3  2-s2.0-85211114952   0   0 2024
#> 4 2-s2.0-105001072133   0   0 2025
#> 5  2-s2.0-85210832535   0   5 2025
#>                                                                                                                                  title
#> 1                                          Quantum Computing in the RAN with Qu4Fec: Closing Gaps Towards Quantum-based FEC Processors
#> 2                                                An FPGA-based bit-level weight sparsity and mixed-bit accelerator for neural networks
#> 3                             FQP: A Fibonacci Quantization Processor with Multiplication-Free Computing and Topological-Order Routing
#> 4                                                   SysCIM: A Heterogeneous Chip Architecture for High-Efficiency CNN Training at Edge
#> 5 Integer-Valued Training and Spike-Driven Inference Spiking Neural Network for High-Performance and Energy-Efficient Object Detection
#>                                                                                                                                 journal
#> 1                                                               Proceedings of the ACM on Measurement and Analysis of Computing Systems
#> 2                                                                                                       Journal of Systems Architecture
#> 3                                                                                            Proceedings - Design Automation Conference
#> 4                                                                      IEEE Transactions on Very Large Scale Integration (VLSI) Systems
#> 5 Lecture Notes in Computer Science (including subseries Lecture Notes in Artificial Intelligence and Lecture Notes in Bioinformatics) 
#>                            doi
#> 1              10.1145/3727128
#> 2 10.1016/j.sysarc.2025.103463
#> 3      10.1145/3649329.3656502
#> 4   10.1109/TVLSI.2025.3526363
#> 5 10.1007/978-3-031-73411-3_15

h <- historiograph(sc, n = 10)
h$nodes
#> [1] id      lcs     gcs     year    title   journal doi    
#> <0 rows> (or 0-length row.names)
head(h$edges, 5)
#> [1] from      to        year_from year_to  
#> <0 rows> (or 0-length row.names)
```

Both require reference strings or IDs to match document IDs in the data;
if the cited works are external, local counts stay low.

## Author-name normalization

[`parse_names()`](https://saqr.me/bibnets-pkg/reference/parse_names.md)
reorders and splits author names (it recognizes `Last, First`,
`SURNAME Initials`, and `First Last`). Because node identity is fixed
when a network is built, normalize *before* building so that two
spellings of one author merge:

``` r

parse_names(c("Saqr, Mohammed", "WANG Y", "Mohammed Saqr"))
#> [1] "Mohammed Saqr" "Y WANG"        "Mohammed Saqr"
#> attr(,"parts")
#>         original    first last particle suffix   type
#> 1 Saqr, Mohammed Mohammed Saqr     <NA>   <NA> person
#> 2         WANG Y        Y WANG     <NA>   <NA> person
#> 3  Mohammed Saqr Mohammed Saqr     <NA>   <NA> person
```

See
[`vignette("parsing-author-names")`](https://saqr.me/bibnets-pkg/articles/parsing-author-names.md)
for the full treatment.

## Exporting

The edge list is already usable; converters cover the common targets:

``` r

edges <- keyword_network(sc, min_occur = 2)

m <- to_matrix(edges)            # sparse adjacency matrix
m[1:4, 1:4]
#> 4 x 4 sparse Matrix of class "dgCMatrix"
#>                ACCELERATION ACCELERATOR ACCURACY AI ACCELERATOR
#> ACCELERATION              .           .        .              .
#> ACCELERATOR               .           .        .              .
#> ACCURACY                  .           .        .              .
#> AI ACCELERATOR            .           .        .              .

gephi <- to_gephi(edges)         # Gephi node/edge tables
head(gephi$edges, 3)
#>           Source         Target Weight       Type count
#> 1 EDGE COMPUTING   QUANTIZATION     16 Undirected    16
#> 2  DEEP LEARNING   QUANTIZATION     14 Undirected    14
#> 3  DEEP LEARNING EDGE COMPUTING     13 Undirected    13

cat(substr(to_graphml(edges), 1, 200))   # GraphML, no XML dependency
#> <?xml version="1.0" encoding="UTF-8"?>
#> <graphml xmlns="http://graphml.graphdrawing.org/graphml"
#>          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
#>          xsi:schemaLocation="http://graph
```

[`to_igraph()`](https://saqr.me/bibnets-pkg/reference/to_igraph.md),
[`to_tbl_graph()`](https://saqr.me/bibnets-pkg/reference/to_tbl_graph.md),
and
[`to_cograph()`](https://saqr.me/bibnets-pkg/reference/to_cograph.md)
are available when their (suggested) packages are installed.

## Reading a `bibnets_network`

The object records how it was built, as attributes:

``` r

edges <- author_network(oa, type = "collaboration", counting = "harmonic")
c(type     = attr(edges, "network_type"),
  counting = attr(edges, "counting"),
  sim      = attr(edges, "similarity"))
#>                   type               counting                    sim 
#> "author_collaboration"             "harmonic"                 "none"

summary(edges)
#> bibnets network
#> ------------------------------
#> Type       : author_collaboration
#> Counting   : harmonic
#> Similarity : none
#> Nodes      : 4029
#> Edges      : 12270
#> Density    : 0.0015
#> Weight     : min 1.43e-05  median 0.0106  max 1.41
#> Top nodes  : DRAGAN GAŠEVIĆ(89), ARI KORHONEN(60), CLAUDIA SZABO(60), JUDY SHEARD(60), PAUL DENNY(56)
```

[`print()`](https://rdrr.io/r/base/print.html) reports the network type,
node and edge counts, and the counting and similarity methods — so a
saved edge list always says how it was made.
