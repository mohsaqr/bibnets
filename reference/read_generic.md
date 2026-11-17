# Read a generic CSV with user-specified columns

`read_generic()` reads any CSV and maps its columns onto the standard
bibnets fields by name. The `authors`, `keywords`, `references`,
`countries` and `affiliations` columns, and any `list_cols`, are split
on `sep` into list-columns; `journal` is copied as a single value; `id`
is set from the named column or from row numbers. Named columns missing
from the file are skipped with a warning. It returns every source column
plus the mapped fields.

## Usage

``` r
read_generic(
  file,
  id = NULL,
  sep = ";",
  authors = NULL,
  keywords = NULL,
  references = NULL,
  countries = NULL,
  affiliations = NULL,
  journal = NULL,
  list_cols = NULL
)
```
