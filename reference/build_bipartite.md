# Build a bipartite incidence matrix from bibliometric data

`build_bipartite()` builds a sparse works x entities two-mode matrix
from a data frame with a list-column. This is the core engine behind all
network construction functions: each network is a projection of this
matrix (see
[`multiply_bipartite()`](https://pak.dynasite.org/bibnets-pkg/reference/multiply_bipartite.md)).

## Usage

``` r
build_bipartite(
  data,
  field,
  min_freq = 1L,
  deduplicate = TRUE,
  sep = ";",
  strip_quotes = TRUE
)
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

- sep:

  Character. Separator used to split `field` when it is a plain
  character column. Default `";"`.

- strip_quotes:

  Logical. Strip surrounding quote characters from entities. Default
  `TRUE`.

## Value

A sparse `dgCMatrix` with rows = works (named by `id`) and columns =
unique entities.

## Details

It returns a `dgCMatrix` with one row per work and one column per unique
entity. When the data are already in long form, use
[`build_bipartite_long()`](https://pak.dynasite.org/bibnets-pkg/reference/build_bipartite_long.md).
