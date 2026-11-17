# Convert edge data frame to igraph

`to_igraph()` converts a bibnets edge list to an `igraph` graph with
[`igraph::graph_from_data_frame()`](https://r.igraph.org/reference/graph_from_data_frame.html).
It requires the suggested package igraph. For a `tbl_graph` use
[`to_tbl_graph()`](https://pak.dynasite.org/bibnets-pkg/reference/to_tbl_graph.md);
for a cograph network use
[`to_cograph()`](https://pak.dynasite.org/bibnets-pkg/reference/to_cograph.md).

## Usage

``` r
to_igraph(edges, directed = FALSE)
```

## Arguments

- edges:

  A data frame with at least `from`, `to`, `weight` columns, as returned
  by any network function in bibnets.

- directed:

  Logical. Default `FALSE`.

## Value

An `igraph` graph with one vertex per node label and one edge per row of
`edges`; the remaining columns (`weight`, `count`, ...) become edge
attributes.

## Examples

``` r
data(biblio_data)
edges <- author_network(biblio_data, "collaboration")
to_igraph(edges)
#> IGRAPH 876c1ce UNW- 6 12 -- 
#> + attr: name (v/c), weight (e/n), count (e/n)
#> + edges from 876c1ce (vertex names):
#>  [1] CHEN W --LEE K   BROWN M--SMITH J BROWN M--LEE K   JONES A--LEE K  
#>  [5] JONES A--SMITH J LEE K  --SMITH J CHEN W --BROWN M BROWN M--DAVIS R
#>  [9] CHEN W --DAVIS R CHEN W --JONES A JONES A--DAVIS R DAVIS R--SMITH J
```
