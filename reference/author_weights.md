# Compute positional author weights for a single paper

Given the number of authors and their positions, returns a weight vector
for positional counting methods. All methods normalize weights to sum to
1 per paper. Position-independent methods (fractional, paper, strength)
are handled by
[`apply_counting()`](https://saqr.me/bibnets-pkg/reference/apply_counting.md)
instead.

## Usage

``` r
author_weights(
  n,
  counting = "fractional",
  position_weights = c(1, 0.8, 0.6, 0.4),
  first_last_weight = 2
)
```

## Arguments

- n:

  Integer. Number of authors.

- counting:

  Character. Counting method.

- position_weights:

  Numeric vector. Custom weights for `counting = "position_weighted"`.
  Default `c(1, 0.8, 0.6, 0.4)`.

- first_last_weight:

  Numeric. Multiplier for first/last authors when
  `counting = "first_last"`. Default 2.

## Value

Numeric vector of length `n`, summing to 1.
