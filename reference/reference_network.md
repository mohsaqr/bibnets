# Build a reference network

Constructs a co-citation or equivalence network among cited references.
Two references are linked when they are cited together by the same
paper.

## Usage

``` r
reference_network(
  data,
  type = "co_citation",
  counting = "full",
  similarity = "none",
  threshold = 0,
  min_occur = 1L,
  top_n = NULL,
  self_loops = FALSE,
  deduplicate = TRUE,
  format = "edgelist"
)
```

## Arguments

- data:

  A data frame with `id` and `references` (list-column).

- type:

  Character. `"co_citation"` (default) or `"equivalence"`.

- counting:

  Character. Counting method. Default `"full"`.

- similarity:

  Character. Similarity measure. Default `"none"`.

- threshold:

  Numeric. Minimum edge weight. Default 0.

- min_occur:

  Integer. Minimum times a reference must be cited. Default 1.

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
reference_network(biblio_data)
#> # bibnets network: reference_co_citation | 13 nodes · 38 edges | counting: full 
#>     from  to  weight  count
#>  1  R3    W1       4      4
#>  2  R1    R2       3      3
#>  3  R2    R5       3      3
#>  4  R2    W1       3      3
#>  5  R4    W1       3      3
#>  6  R3    W2       3      3
#>  7  W1    W2       3      3
#>  8  R2    R3       2      2
#>  9  R3    R4       2      2
#> 10  R1    R5       2      2
#> # ... 28 more edges
reference_network(biblio_data, similarity = "association")
#> # bibnets network: reference_co_citation | 13 nodes · 38 edges | counting: full | similarity: association 
#>     from  to  weight  count
#>  1  R9    W5       1      1
#>  2  R7    R9     0.5      1
#>  3  R7    W5     0.5      1
#>  4  R10   R6    0.25      1
#>  5  R6    W2    0.25      2
#>  6  R10   W3    0.25      1
#>  7  R6    W3    0.25      1
#>  8  R7    W3    0.25      1
#>  9  R1    R5  0.2222      2
#> 10  R1    R2     0.2      3
#> # ... 28 more edges
```
