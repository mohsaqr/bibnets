# Prune a weighted edge list

`prune()` reduces a weighted edge list by removing weak or excess edges.
Supply exactly one of `threshold` (a global cut-off) or `top_n` (a
local, per-node cut-off); supplying both or neither is an error.

## Usage

``` r
prune(edges, threshold = NULL, top_n = NULL)
```

## Arguments

- edges:

  A data frame with at least columns `from`, `to`, and `weight`.

- threshold:

  Numeric or `NULL`. Keep only edges with `weight >= threshold`. Default
  `NULL`.

- top_n:

  Integer or `NULL`. For each node, keep only its `top_n` strongest
  edges. An edge is kept if it is in the top `top_n` for *either*
  endpoint (ties at the cut-off are kept). Default `NULL`.

## Value

The edge data frame restricted to the retained edges, with the same
class and columns as the input, one row per edge, sorted by decreasing
`weight`.

## Details

It returns the retained edges. To keep the edges among the most
connected nodes, use
[`filter_top()`](https://pak.dynasite.org/bibnets-pkg/reference/filter_top.md);
for a statistical backbone, use
[`backbone()`](https://pak.dynasite.org/bibnets-pkg/reference/backbone.md).

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
