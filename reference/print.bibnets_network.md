# Print a bibnets network edge list

Print a bibnets network edge list

## Usage

``` r
# S3 method for class 'bibnets_network'
print(x, n = 10L, ...)
```

## Arguments

- x:

  A `bibnets_network` data frame.

- n:

  Integer. Number of rows to show. Default 10.

- ...:

  Ignored.

## Value

Invisibly returns `x`.

## Examples

``` r
data(biblio_data)
edges <- author_network(biblio_data, "collaboration")
print(edges)
#> # bibnets network: author_collaboration | 6 nodes · 12 edges | counting: full 
#>     from     to       weight  count
#>  1  CHEN W   LEE K         3      3
#>  2  BROWN M  SMITH J       3      3
#>  3  BROWN M  LEE K         2      2
#>  4  JONES A  LEE K         2      2
#>  5  JONES A  SMITH J       2      2
#>  6  LEE K    SMITH J       2      2
#>  7  BROWN M  CHEN W        1      1
#>  8  BROWN M  DAVIS R       1      1
#>  9  CHEN W   DAVIS R       1      1
#> 10  CHEN W   JONES A       1      1
#> # ... 2 more edges
```
