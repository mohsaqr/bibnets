# Summarise a bibnets network

Summarise a bibnets network

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

Invisibly returns `object`.

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
