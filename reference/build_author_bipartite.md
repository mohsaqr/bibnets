# Build a weighted bipartite matrix using positional counting

`build_author_bipartite()` builds the works x authors two-mode matrix
for position-dependent counting methods. It replaces the binary
bipartite matrix entries with positional weights derived from author
order (see
[`author_weights()`](https://pak.dynasite.org/bibnets-pkg/reference/author_weights.md));
authors with weight zero on a paper are dropped.

## Usage

``` r
build_author_bipartite(
  data,
  field = "authors",
  counting = "full",
  position_weights = c(1, 0.8, 0.6, 0.4),
  first_last_weight = 2,
  deduplicate = TRUE,
  sep = ";",
  strip_quotes = TRUE
)
```

## Arguments

- data:

  A data frame with `id` and an ordered entity column (list-column or
  delimited string).

- field:

  Character. Name of the entity column. Default `"authors"`.

- counting:

  Character. Counting method.

- position_weights:

  Numeric vector for `counting = "position_weighted"`.

- first_last_weight:

  Numeric for `counting = "first_last"`.

- deduplicate:

  Logical. Keep only the first position of an entity repeated within one
  paper.

- sep:

  Character. Separator for a plain character column.

- strip_quotes:

  Logical. Strip surrounding quotes from each entity.

## Value

A sparse weighted bipartite matrix (works x authors).
