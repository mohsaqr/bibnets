# Build bipartite matrix from a long-format edge table

`build_bipartite_long()` builds a sparse two-mode matrix from data that
is already in long form (e.g., a two-column data frame of
document-reference pairs). It is the long-form alternative to
[`build_bipartite()`](https://pak.dynasite.org/bibnets-pkg/reference/build_bipartite.md),
which takes a list-column.

## Usage

``` r
build_bipartite_long(edges, min_freq = 1L)
```

## Arguments

- edges:

  A data frame with columns `source` (work id) and `target` (entity id).

- min_freq:

  Integer. Minimum entity frequency. Default 1.

## Value

A sparse `dgCMatrix`.
