# Construct a co-occurrence network via two-mode multiplication

`multiply_bipartite()` projects a weighted works x entities matrix onto
a one-mode co-occurrence network and returns its edges. With
`mode = "columns"` it links the entities (columns) that occur in the
same rows (`crossprod(B)`, e.g. co-citation); with `mode = "rows"` it
links the rows that share entities (`tcrossprod(B)`, e.g. coupling).

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
  [`normalize()`](https://pak.dynasite.org/bibnets-pkg/reference/normalize.md)).

- threshold:

  Numeric. Minimum edge weight to retain.

- top_n:

  Integer or `NULL`. If specified, keep only the top `n` most frequent
  nodes and return all edges among them.

- self_loops:

  Logical. Keep diagonal entries as self-loops. Only honoured with
  `similarity = "none"`.

## Value

A data frame with columns `from`, `to`, `weight`, `count`.

## Details

It is the unified engine for all bibliometric networks. It operates
entirely in sparse representation and never allocates a dense n x n
matrix; `top_n` keeps the most frequent nodes, `similarity` normalizes
the projection with
[`normalize()`](https://pak.dynasite.org/bibnets-pkg/reference/normalize.md),
and `threshold` drops weak edges.
