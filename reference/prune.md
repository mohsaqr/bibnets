# Prune a weighted edge list

Reduces a weighted edge list by removing weak or excess edges.

## Usage

``` r
prune(edges, threshold = NULL, top_n = NULL)
```

## Arguments

- edges:

  A data frame with at least columns `from`, `to`, and `weight`.

- threshold:

  Numeric. Keep only edges with `weight >= threshold`.

- top_n:

  Integer. For each node, keep only its `top_n` strongest edges. An edge
  is kept if it is in the top `top_n` for *either* endpoint.

## Value

The filtered edge data frame (same columns as input).

## Examples

``` r
edges <- data.frame(
  from   = c("A","A","A","B","B","C"),
  to     = c("B","C","D","C","D","D"),
  weight = c(5,  1,  2,  4,  1,  3)
)

# Keep only edges with weight >= 3
prune(edges, threshold = 3)
#>   from to weight
#> 1    A  B      5
#> 2    B  C      4
#> 3    C  D      3

# Keep the 2 strongest edges per node
prune(edges, top_n = 2)
#>   from to weight
#> 1    A  B      5
#> 2    B  C      4
#> 3    C  D      3
#> 4    A  D      2
```
