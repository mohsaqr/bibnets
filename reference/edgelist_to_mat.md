# Convert edge list to a square sparse matrix

`edgelist_to_mat()` converts an edge list to a square sparse matrix of
edge weights, one row and column per node. With `symmetric = TRUE` each
edge is entered in both directions. It is the inverse of
[`mat_to_edgelist()`](https://pak.dynasite.org/bibnets-pkg/reference/mat_to_edgelist.md)
and the engine behind
[`to_matrix()`](https://pak.dynasite.org/bibnets-pkg/reference/to_matrix.md).

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
