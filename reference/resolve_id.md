# Resolve the work-identifier column

Materializes a top-level `id` column that the network pipeline uses to
index works (matrix rows). Resolution rules:

## Usage

``` r
resolve_id(data, id = NULL)
```

## Arguments

- data:

  A data frame.

- id:

  `NULL` or a single column name (character scalar).

## Value

`data` with a guaranteed character `id` column.

## Details

- `id = NULL` (default): use the existing `id` column if one is present,
  otherwise fall back to row numbers (`seq_len(nrow(data))`).

- `id = "colname"`: copy the named column to `id`. The column must
  exist.

When `id` names a column other than `"id"` and the data *already* has a
distinct `"id"` column, the request is ambiguous (the existing `"id"`
column might itself be an entity field). Rather than silently
overwriting it, this errors and asks the caller to resolve the conflict.
