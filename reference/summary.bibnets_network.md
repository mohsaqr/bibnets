# Summarise a bibnets network

[`summary()`](https://rdrr.io/r/base/summary.html) describes a
`bibnets_network` edge list. It prints the network type, counting and
similarity methods, the number of nodes and edges, the density (edges
over the `n (n - 1) / 2` possible undirected pairs), the minimum, median
and maximum `weight`, and the five nodes with the most edges.

## Usage

``` r
# S3 method for class 'bibnets_network'
summary(object, ...)
```

## Arguments

- object:

  A `bibnets_network` data frame.

- ...:

  Ignored.

## Value

`object`, unchanged and invisibly (a `bibnets_network` data frame).
Called for its printed output.

## Examples

``` r
data(biblio_data)
edges <- author_network(biblio_data, "collaboration")
summary(edges)
#> bibnets network
#> ------------------------------
#> Type       : author_collaboration
#> Counting   : full
#> Similarity : none
#> Nodes      : 6
#> Edges      : 12
#> Density    : 0.8000
#> Weight     : min 1  median 1.5  max 3
#> Top nodes  : BROWN M(4), CHEN W(4), DAVIS R(4), JONES A(4), LEE K(4)
```
