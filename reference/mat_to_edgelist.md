# Convert a sparse square matrix to a tidy edge list

Extracts non-zero entries directly from the sparse representation — no
dense matrix allocation. For undirected networks, only the upper
triangle is returned.

## Usage

``` r
mat_to_edgelist(A, directed = FALSE)
```

## Arguments

- A:

  A square sparse or dense matrix.

- directed:

  Logical. If `FALSE` (default), returns only upper-triangle entries. If
  `TRUE`, returns all non-zero off-diagonal entries.

## Value

A data frame with columns `from`, `to`, `weight`, sorted by descending
weight.
