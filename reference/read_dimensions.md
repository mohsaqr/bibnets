# Read Dimensions CSV export

Parses a CSV file exported from Dimensions into a standardized
bibliometric data frame.

## Usage

``` r
read_dimensions(file, encoding = "UTF-8")
```

## Arguments

- file:

  Path to a Dimensions CSV export file.

- encoding:

  Character. File encoding. Default `"UTF-8"`.

## Value

A data frame in the standard bibnets format: `id`, `title`, `year`,
`journal`, `doi`, `cited_by_count`, `abstract`, `type`, plus
list-columns `authors`, `references`, and `keywords`.
Dimensions-specific extras: `affiliations` (list-column), `countries`
(list-column).

## Examples

``` r
if (FALSE) { # \dontrun{
data <- read_dimensions("dimensions_export.csv")
} # }
```
