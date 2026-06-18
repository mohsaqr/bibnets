# Convert edge data frame to adjacency matrix

Convert edge data frame to adjacency matrix

## Usage

``` r
to_matrix(edges, symmetric = TRUE)
```

## Arguments

- edges:

  A data frame with `from`, `to`, `weight` columns.

- symmetric:

  Logical. If `TRUE` (default), produces a symmetric matrix.

## Value

A sparse Matrix.

## Examples

``` r
data(biblio_data)
edges <- reference_network(biblio_data, min_occur = 2)
to_matrix(edges)
#> 11 x 11 sparse Matrix of class "dgCMatrix"
#>   [[ suppressing 11 column names ‘R1’, ‘R10’, ‘R2’ ... ]]
#>                          
#> R1  . 1 3 1 1 2 . . 1 . .
#> R10 1 . 1 . . 1 1 . . 1 1
#> R2  3 1 . 2 1 3 . 1 3 . 1
#> R3  1 . 2 . 2 2 1 . 4 3 .
#> R4  1 . 1 2 . . . . 3 2 .
#> R5  2 1 3 2 . . . . 1 . .
#> R6  . 1 . 1 . . . . 1 2 1
#> R7  . . 1 . . . . . 2 . 1
#> W1  1 . 3 4 3 1 1 2 . 3 1
#> W2  . 1 . 3 2 . 2 . 3 . 1
#> W3  . 1 1 . . . 1 1 1 1 .
```
