# Build an institution network

Constructs a network between institutions (affiliations).

## Usage

``` r
institution_network(
  data,
  type = "collaboration",
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

  A data frame with `id` and `affiliations` (list-column of institution
  names). For coupling, also needs `references`.

- type:

  Character. `"collaboration"` (default), `"coupling"`, or
  `"equivalence"`.

- counting:

  Character. Counting method. Default `"full"`.

- similarity:

  Character. Similarity measure. Default `"none"`.

- threshold:

  Numeric. Minimum edge weight. Default 0.

- min_occur:

  Integer. Minimum papers per institution. Default 1.

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
data(open_alex_gold_open_access_learning_analytics)
institution_network(open_alex_gold_open_access_learning_analytics, "collaboration")
#> # bibnets network: institution_collaboration | 1,199 nodes · 2,649 edges | counting: full 
#>     from                            to                              weight  count
#>  1  FINLAND UNIVERSITY              UNIVERSITY OF EASTERN FINLAND       13     13
#>  2  DIPF                            LEIBNIZ INSTITUTE FOR RESEARC…      10     10
#>  3  UNIVERSIDADE FEDERAL DE SANTA…  UNIVERSITY OF VALPARAÍSO           10     10
#>  4  MAASTRICHT SCHOOL OF MANAGEME…  MAASTRICHT UNIVERSITY                6      6
#>  5  ESCUELA SUPERIOR POLITECNICA …  MONASH UNIVERSITY                    6      6
#>  6  PONTIFICIA UNIVERSIDAD CATÓLI…  UNIVERSIDADE FEDERAL DE SANTA…       6      6
#>  7  UNIVERSITY OF EASTERN FINLAND   UNIVERSITY OF JYVÄSKYLÄ            6      6
#>  8  PONTIFICIA UNIVERSIDAD CATÓLI…  UNIVERSITY OF VALPARAÍSO            6      6
#>  9  DIPF                            GOETHE UNIVERSITY FRANKFURT          5      5
#> 10  GOETHE UNIVERSITY FRANKFURT     LEIBNIZ INSTITUTE FOR RESEARC…       5      5
#> # ... 2,639 more edges
```
