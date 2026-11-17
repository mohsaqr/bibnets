# Convert a sparse square matrix to a tidy edge list

`mat_to_edgelist()` converts a square matrix to an edge list with
columns `from`, `to` and `weight`. It extracts non-zero entries directly
from the sparse representation, without a dense matrix allocation. For
undirected networks, only the upper triangle is returned.

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
