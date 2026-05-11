# Read Lens.org CSV export

Parses a CSV file exported from Lens.org into a standardized
bibliometric data frame.

## Usage

``` r
read_lens(file, encoding = "UTF-8")
```

## Arguments

- file:

  Path to a Lens.org CSV export file.

- encoding:

  Character. File encoding. Default `"UTF-8"`.

## Value

A data frame in the standard bibnets format: `id`, `title`, `year`,
`journal`, `doi`, `cited_by_count`, `abstract`, `type`, plus
list-columns `authors`, `references`, and `keywords`.

## Examples

``` r
if (FALSE) { # \dontrun{
data <- read_lens("lens_export.csv")
} # }
```
