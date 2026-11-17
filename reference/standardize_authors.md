# Standardize author names

`standardize_authors()` cleans author names by uppercasing, whitespace
normalisation, and dot removal from initials (`F.J.` -\> `FJ`). Name
order and format are preserved, consistent with how bibliometrix handles
multi-source data. To reorder and parse names, use
[`parse_names()`](https://pak.dynasite.org/bibnets-pkg/reference/parse_names.md).

## Usage

``` r
standardize_authors(x, flip_names = FALSE)
```

## Arguments

- x:

  Character vector of author names.

- flip_names:

  Logical. If `TRUE`, names in `Last, First` format are reordered to
  `First Last`. Off by default; enable only when all names in `x`
  reliably follow the `Last, First` convention.

## Value

Character vector, uppercased and cleaned.
