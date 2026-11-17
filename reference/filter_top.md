# Filter edges to top-n nodes

`filter_top()` keeps only the edges between the `n` most frequent nodes.
Node frequency is determined by how many edges each node participates
in. It returns the edges whose two endpoints are both among the top
nodes. To prune by edge weight or keep each node's strongest edges, use
[`prune()`](https://pak.dynasite.org/bibnets-pkg/reference/prune.md);
for a statistical backbone, use
[`backbone()`](https://pak.dynasite.org/bibnets-pkg/reference/backbone.md).

## Usage

``` r
filter_top(edges, n)
```

## Arguments

- edges:

  A data frame with at least `from`, `to`, `weight` columns.

- n:

  Integer. Number of top nodes to keep (ties in edge count are broken by
  the order of [`table()`](https://rdrr.io/r/base/table.html), i.e.
  alphabetically).

## Value

The edge data frame restricted to edges whose two endpoints are both
among the top `n` nodes, with the same class and columns as the input,
sorted by decreasing `weight`.

## Examples

``` r
data(biblio_data)
edges <- author_network(biblio_data, "collaboration")

# Keep only edges among the top 3 most connected authors
filter_top(edges, 3)
#> # bibnets network: author_collaboration | 3 nodes · 3 edges | counting: full 
#>    from     to       weight  count
#> 1  BROWN M  CHEN W        1      1
#> 2  BROWN M  DAVIS R       1      1
#> 3  CHEN W   DAVIS R       1      1
```
