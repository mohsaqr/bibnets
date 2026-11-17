# Ensure a column is a list-column, splitting if needed

`ensure_list_column()` turns a column into a list-column. A character
column is split on `sep` with
[`split_field()`](https://pak.dynasite.org/bibnets-pkg/reference/split_field.md)
(with a warning from
[`warn_if_sep_mismatch()`](https://pak.dynasite.org/bibnets-pkg/reference/warn_if_sep_mismatch.md)
when the separator looks wrong); with `sep = NULL` each value becomes a
single entity. A list-column is kept as it is. It returns `data` with
the column replaced.

## Usage

``` r
ensure_list_column(data, field, sep = ";", strip_quotes = TRUE)
```

## Arguments

- strip_quotes:

  Logical. If `TRUE` (default), surrounding quote characters and
  whitespace are removed from every entity (e.g. a quoted CSV value
  `"Alice"` becomes `Alice`). See
  [`strip_surrounding_quotes()`](https://pak.dynasite.org/bibnets-pkg/reference/strip_surrounding_quotes.md).
