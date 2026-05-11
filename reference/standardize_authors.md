# Standardize author names

Uppercase, whitespace normalisation, and dot removal from initials
(`F.J.` → `FJ`). Name order and format are preserved — consistent with
how bibliometrix handles multi-source data.

## Usage

``` r
standardize_authors(x, flip_names = FALSE)
```

## Arguments

- x:

  Character vector of author names.

- flip_names:

  Logical. If `TRUE`, names in `Last, First` format are reordered to
  `First Last`. Off by default — enable only when all names in `x`
  reliably follow the `Last, First` convention.

## Value

Character vector, uppercased and cleaned.
