# Warn when a separator likely failed to split a multi-entity column

Splitting with the wrong separator silently yields one "entity" per row
(e.g., a whole author byline as a single node). Heuristic: no row split
into more than one entity, yet most non-empty strings contain a common
*structural* delimiter.

## Usage

``` r
warn_if_sep_mismatch(col, parts, field, sep)
```

## Details

Only structural delimiters (`";"`, `"|"`, tab) are considered, because
they essentially never occur inside a single legitimate label. Commas
and `" and "` are deliberately excluded: they appear inside valid single
values (e.g. `"Last, First"` author names, one-reference-per-row
citation strings, or organisations like `"Smith and Sons"`), so warning
on them would mislead users with correct data.
