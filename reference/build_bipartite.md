# Build a bipartite incidence matrix from bibliometric data

Constructs a sparse works x entities two-mode matrix from a data frame
with a list-column. This is the core engine behind all network
construction functions.

## Usage

``` r
build_bipartite(data, field, min_freq = 1L, deduplicate = TRUE)
```

## Arguments

- data:

  A data frame with at least columns `id` and the field specified.

- field:

  Character. Name of the list-column containing entities (e.g.,
  `"authors"`, `"references"`, `"keywords"`).

- min_freq:

  Integer. Minimum number of occurrences for an entity to be included.
  Default 1 (no filtering).

## Value

A sparse `dgCMatrix` with rows = works (named by `id`) and columns =
unique entities.
