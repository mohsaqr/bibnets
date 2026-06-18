# Convert edge data frame to igraph

Convert edge data frame to igraph

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

An igraph graph object.

## Examples

``` r
data(biblio_data)
edges <- author_network(biblio_data, "collaboration")
g <- to_igraph(edges)
```
