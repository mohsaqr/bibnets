# Apply counting weights to a generic bipartite matrix

`apply_counting()` weights a binary works x entities matrix by a
position-independent counting method (`"fractional"`, `"paper"` or
`"strength"`; `"full"` leaves it unchanged). It is used for non-author
fields (references, keywords, etc.). `"fractional"` and `"paper"` modify
the bipartite matrix row weights; `"strength"` weights the columns by
inverse document frequency and leaves the row normalization to
[`multiply_bipartite()`](https://pak.dynasite.org/bibnets-pkg/reference/multiply_bipartite.md).
For position-dependent counting use
[`build_author_bipartite()`](https://pak.dynasite.org/bibnets-pkg/reference/build_author_bipartite.md).

## Usage

``` r
apply_counting(B, counting = "full", network_type = "symmetric")
```

## Arguments

- B:

  A sparse binary bipartite matrix (works x entities).

- counting:

  Character. One of `"full"`, `"fractional"`, `"paper"`, `"strength"`.

- network_type:

  Character. `"symmetric"` or `"coupling"`.

## Value

A weighted sparse matrix.
