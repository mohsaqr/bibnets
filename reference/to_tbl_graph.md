# Convert edge data frame to tbl_graph

Convert edge data frame to tbl_graph

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

A tbl_graph object (tidygraph).

## Examples

``` r
data(biblio_data)
edges <- keyword_network(biblio_data)
tg <- to_tbl_graph(edges)
```
