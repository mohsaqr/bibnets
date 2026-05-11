# Build bipartite matrix from a long-format edge table

Alternative constructor when data is already in long form (e.g., a
two-column data frame of document-reference pairs).

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
