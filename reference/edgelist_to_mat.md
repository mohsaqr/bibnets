# Convert edge list to a square sparse matrix

Convert edge list to a square sparse matrix

## Usage

``` r
edgelist_to_mat(edges, nodes = NULL, symmetric = TRUE)
```

## Arguments

- edges:

  A data frame with columns `from`, `to`, `weight`.

- nodes:

  Optional character vector of node names. If `NULL`, derived from the
  edge list.

- symmetric:

  Logical. If `TRUE` (default), the matrix is made symmetric.

## Value

A sparse `dgCMatrix`.
