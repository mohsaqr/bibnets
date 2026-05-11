# Build a weighted bipartite matrix using positional counting

For position-dependent counting methods, this replaces the binary
bipartite matrix entries with positional weights derived from author
order.

## Usage

``` r
build_author_bipartite(
  data,
  field = "authors",
  counting = "full",
  position_weights = c(1, 0.8, 0.6, 0.4),
  first_last_weight = 2,
  deduplicate = TRUE
)
```

## Arguments

- data:

  A data frame with `id` and `authors` (list-column where author order
  is preserved).

- counting:

  Character. Counting method.

- position_weights:

  Numeric vector for `counting = "position_weighted"`.

- first_last_weight:

  Numeric for `counting = "first_last"`.

## Value

A sparse weighted bipartite matrix (works x authors).
