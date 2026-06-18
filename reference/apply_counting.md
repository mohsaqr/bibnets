# Apply counting weights to a generic bipartite matrix

For position-independent counting of non-author fields (references,
keywords, etc.). Modifies the bipartite matrix row weights.

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
