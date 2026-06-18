# Build a co-occurrence network from any field

With one field, entities are linked when they co-occur in the same
document. With `by`, entities are linked when they share values of the
`by` field across documents.

## Usage

``` r
conetwork(
  data,
  field,
  by = NULL,
  sep = ";",
  counting = "full",
  similarity = "none",
  threshold = 0,
  min_occur = 1L,
  top_n = NULL,
  self_loops = FALSE,
  deduplicate = TRUE,
  format = "edgelist",
  strip_quotes = TRUE,
  id = NULL
)
```

## Arguments

- data:

  A data frame with column `id` and the specified field(s).

- field:

  Character. The entity field — determines what the nodes are.

- by:

  Character or `NULL`. What links the nodes. If `NULL` (default),
  entities are linked by co-occurring in the same document. If
  specified, entities are linked when they share values from the `by`
  field.

- sep:

  Character or `NULL`. Delimiter for splitting character columns.
  Default `";"`. Set to `NULL` if columns are already list-columns.

- counting:

  Character. Counting method. Default `"full"`.

- similarity:

  Character. Normalization method. Default `"none"`.

- threshold:

  Numeric. Minimum edge weight. Default 0.

- min_occur:

  Integer. Minimum entity frequency. Default 1.

- top_n:

  Integer or NULL. Return only the top n edges by weight. Default NULL
  (all edges).

- self_loops:

  Logical. If `TRUE`, include self-loops (an entity linked to itself).
  Default `FALSE`.

- deduplicate:

  Logical. If `TRUE` (default), each `(paper, entity)` pair is counted
  at most once — duplicate entries in the source data (e.g., the same
  author listed twice on a paper) are treated as one occurrence. Set to
  `FALSE` to count every raw occurrence.

- format:

  Character. Output format:

  `"edgelist"`

  :   Default. A `bibnets_network` data frame with columns `from`, `to`,
      `weight`, `count`.

  `"gephi"`

  :   Gephi-ready data frame: `Source`, `Target`, `Weight`, `Count`,
      `Type`.

  `"igraph"`

  :   An igraph graph object (requires igraph).

  `"cograph"`

  :   A cograph_network object (requires cograph).

  `"matrix"`

  :   A sparse adjacency matrix.

- strip_quotes:

  Logical. If `TRUE` (default), surrounding quote characters are removed
  from each entity, so a quoted CSV value such as `"Alice"` or
  `""Alice""` is treated as `Alice`. Set `FALSE` to keep quotes as part
  of the label.

- id:

  Optional. Name of the column to use as the work identifier (the
  matrix-row dimension). If `NULL` (default), an existing `id` column is
  used when present, otherwise row numbers are used.

## Value

Depends on `format`: a `bibnets_network` data frame (default), a
Gephi-ready data frame, an igraph graph, a cograph_network, or a sparse
matrix.

## Details

Fields can be list-columns (already split) or character columns with
delimiters (auto-split via `sep`).

## Examples

``` r
data(biblio_data)

# Co-occurrence: keywords appearing in the same document
conetwork(biblio_data, "keywords")
#> # bibnets network: keywords_co_occurrence | 23 nodes · 30 edges | counting: full 
#>     from               to                   weight  count
#>  1  CITATION NETWORKS  CLUSTERING                1      1
#>  2  BIBLIOMETRICS      CO-CITATION               1      1
#>  3  BIBLIOMETRICS      CO-OCCURRENCE             1      1
#>  4  CITATION NETWORKS  COMMUNITY DETECTION       1      1
#>  5  CLUSTERING         COMMUNITY DETECTION       1      1
#>  6  BIBLIOMETRICS      COUPLING                  1      1
#>  7  AUTHOR NAMES       DISAMBIGUATION            1      1
#>  8  CITATION PATTERNS  DYNAMICS                  1      1
#>  9  AUTHOR NAMES       ENTITY RESOLUTION         1      1
#> 10  DISAMBIGUATION     ENTITY RESOLUTION         1      1
#> # ... 20 more edges

# Authors linked by shared keywords
conetwork(biblio_data, "authors", by = "keywords")
#> # bibnets network: authors_by_keywords | 6 nodes · 15 edges | counting: full 
#>     from     to       weight  count
#>  1  CHEN W   LEE K         8      8
#>  2  BROWN M  SMITH J       8      8
#>  3  BROWN M  LEE K         6      6
#>  4  JONES A  LEE K         6      6
#>  5  JONES A  SMITH J       6      6
#>  6  LEE K    SMITH J       6      6
#>  7  DAVIS R  JONES A       4      4
#>  8  BROWN M  CHEN W        3      3
#>  9  BROWN M  DAVIS R       3      3
#> 10  CHEN W   DAVIS R       3      3
#> # ... 5 more edges

# Keywords linked by shared authors
conetwork(biblio_data, "keywords", by = "authors")
#> # bibnets network: keywords_by_authors | 23 nodes · 190 edges | counting: full 
#>     from           to                   weight  count
#>  1  BIBLIOMETRICS  CO-OCCURRENCE             4      4
#>  2  BIBLIOMETRICS  NETWORK ANALYSIS          4      4
#>  3  CO-OCCURRENCE  NETWORK ANALYSIS          4      4
#>  4  BIBLIOMETRICS  NORMALIZATION             4      4
#>  5  BIBLIOMETRICS  CO-CITATION               3      3
#>  6  CO-CITATION    CO-OCCURRENCE             3      3
#>  7  BIBLIOMETRICS  FRACTIONAL COUNTING       3      3
#>  8  BIBLIOMETRICS  KEYWORD MAPPING           3      3
#>  9  CO-OCCURRENCE  KEYWORD MAPPING           3      3
#> 10  BIBLIOMETRICS  KNOWLEDGE DOMAINS         3      3
#> # ... 180 more edges

# Journals linked by shared references (= journal coupling)
conetwork(biblio_data, "journal", by = "references", similarity = "cosine")
#> # bibnets network: journal_by_references | 4 nodes · 6 edges | counting: full | similarity: cosine 
#>    from                          to                            weight  count
#> 1  JASIST                        SCIENTOMETRICS                0.8018      6
#> 2  JASIST                        JOURNAL OF INFORMETRICS       0.7071      6
#> 3  JOURNAL OF INFORMETRICS       SCIENTOMETRICS                0.6299      5
#> 4  JOURNAL OF INFORMETRICS       QUANTITATIVE SCIENCE STUDIES  0.3333      2
#> 5  QUANTITATIVE SCIENCE STUDIES  SCIENTOMETRICS                 0.189      1
#> 6  JASIST                        QUANTITATIVE SCIENCE STUDIES  0.1768      1

# Auto-splits semicolon-delimited string columns
d <- data.frame(id = 1:3, tags = c("ml; dl; nlp", "ml; cv", "dl; cv"))
conetwork(d, "tags")
#> # bibnets network: tags_co_occurrence | 4 nodes · 5 edges | counting: full 
#>    from  to   weight  count
#> 1  CV    DL        1      1
#> 2  CV    ML        1      1
#> 3  DL    ML        1      1
#> 4  DL    NLP       1      1
#> 5  ML    NLP       1      1
```
