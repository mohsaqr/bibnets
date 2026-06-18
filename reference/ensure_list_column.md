# Ensure a column is a list-column, splitting if needed

Ensure a column is a list-column, splitting if needed

## Usage

``` r
ensure_list_column(data, field, sep = ";", strip_quotes = TRUE)
```

## Arguments

- strip_quotes:

  Logical. If `TRUE` (default), surrounding quote characters and
  whitespace are removed from every entity (e.g. a quoted CSV value
  `"Alice"` becomes `Alice`). See
  [`strip_surrounding_quotes()`](https://saqr.me/bibnets-pkg/reference/strip_surrounding_quotes.md).
