# Construct a co-occurrence network via two-mode multiplication

The unified engine for all bibliometric networks. Operates entirely in
sparse representation — never allocates a dense n x n matrix.

## Usage

``` r
multiply_bipartite(
  B,
  mode = "columns",
  similarity = "none",
  threshold = 0,
  top_n = NULL,
  self_loops = FALSE
)
```

## Arguments

- B:

  A sparse bipartite matrix (works x entities), already weighted by the
  counting method.

- mode:

  Character. `"columns"` for column-mode co-occurrence (e.g.,
  co-citation), `"rows"` for row-mode (e.g., coupling).

- similarity:

  Character. Normalization method (see
  [`normalize()`](https://saqr.me/bibnets-pkg/reference/normalize.md)).

- threshold:

  Numeric. Minimum edge weight to retain.

- top_n:

  Integer or `NULL`. If specified, keep only the top `n` most frequent
  nodes and return all edges among them.

## Value

A data frame with columns `from`, `to`, `weight`, `count`.
