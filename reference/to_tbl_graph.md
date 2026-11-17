# Convert edge data frame to tbl_graph

`to_tbl_graph()` converts a bibnets edge list to a tidygraph
`tbl_graph`, through
[`to_igraph()`](https://pak.dynasite.org/bibnets-pkg/reference/to_igraph.md).
It requires the suggested packages tidygraph and igraph.

## Usage

``` r
to_tbl_graph(edges, directed = FALSE)
```

## Arguments

- edges:

  A data frame with at least `from`, `to`, `weight` columns.

- directed:

  Logical. Default `FALSE`.

## Value

A `tbl_graph` (tidygraph) with the edge columns as edge data and one
node row per node label.

## Examples

``` r
data(biblio_data)
edges <- keyword_network(biblio_data)
to_tbl_graph(edges)
#> # A tbl_graph: 23 nodes and 30 edges
#> #
#> # An undirected simple graph with 4 components
#> #
#> # Node Data: 23 × 1 (active)
#>    name               
#>    <chr>              
#>  1 CITATION NETWORKS  
#>  2 BIBLIOMETRICS      
#>  3 CLUSTERING         
#>  4 AUTHOR NAMES       
#>  5 CITATION PATTERNS  
#>  6 DISAMBIGUATION     
#>  7 CO-OCCURRENCE      
#>  8 CO-AUTHORSHIP      
#>  9 CO-CITATION        
#> 10 FRACTIONAL COUNTING
#> # ℹ 13 more rows
#> #
#> # Edge Data: 30 × 4
#>    from    to weight count
#>   <int> <int>  <dbl> <int>
#> 1     1     3      1     1
#> 2     2     9      1     1
#> 3     2     7      1     1
#> # ℹ 27 more rows
```
