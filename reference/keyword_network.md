# Build a keyword co-occurrence network

Constructs a network where two keywords are linked when they appear
together in the same document.

## Usage

``` r
keyword_network(
  data,
  field = "keywords",
  counting = "full",
  similarity = "none",
  threshold = 0,
  min_occur = 1L,
  attention = NULL,
  top_n = NULL,
  self_loops = FALSE,
  deduplicate = TRUE,
  format = "edgelist"
)
```

## Arguments

- data:

  A data frame with `id` and a keyword list-column.

- field:

  Character. Name of the keyword list-column. Default `"keywords"`.
  Alternatives: `"author_keywords"`, `"index_keywords"`,
  `"keywords_plus"`.

- counting:

  Character. Counting method. Default `"full"`.

- similarity:

  Character. Similarity measure. Default `"none"`.

- threshold:

  Numeric. Minimum edge weight. Default 0.

- min_occur:

  Integer. Minimum keyword frequency. Default 1.

- attention:

  Character or NULL. Attention-based weighting independent of `type` and
  `counting`. One of `"proximity"` (center authors weighted most),
  `"lead"` (first author dominates, quadratic drop), `"last"` (last
  author dominates, quadratic rise), `"circular"` (first and last both
  prominent). Default `NULL` (disabled).

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

## Value

Depends on `format`: a `bibnets_network` data frame (default), a
Gephi-ready data frame, an igraph graph, a cograph_network, or a sparse
matrix.

## Examples

``` r
data(biblio_data)
keyword_network(biblio_data)
#> # bibnets network: keyword_co_occurrence | 23 nodes · 30 edges | counting: full 
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
keyword_network(biblio_data, similarity = "association")
#> # bibnets network: keyword_co_occurrence | 23 nodes · 30 edges | counting: full | similarity: association 
#>     from               to                       weight  count
#>  1  CITATION NETWORKS  CLUSTERING                    1      1
#>  2  CITATION NETWORKS  COMMUNITY DETECTION           1      1
#>  3  CLUSTERING         COMMUNITY DETECTION           1      1
#>  4  AUTHOR NAMES       DISAMBIGUATION                1      1
#>  5  CITATION PATTERNS  DYNAMICS                      1      1
#>  6  AUTHOR NAMES       ENTITY RESOLUTION             1      1
#>  7  DISAMBIGUATION     ENTITY RESOLUTION             1      1
#>  8  COUPLING           RESEARCH FRONTS               1      1
#>  9  CO-AUTHORSHIP      SCHOLARLY COMMUNICATION       1      1
#> 10  KNOWLEDGE DOMAINS  SCIENCE MAPPING               1      1
#> # ... 20 more edges
```
