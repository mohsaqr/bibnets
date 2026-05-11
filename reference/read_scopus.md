# Read Scopus CSV export

Parses a CSV file exported from Scopus into a standardized bibliometric
data frame with list-columns for multi-valued fields.

## Usage

``` r
read_scopus(file, encoding = "UTF-8")
```

## Arguments

- file:

  Path to a Scopus CSV export file.

- encoding:

  Character. File encoding. Default `"UTF-8"`.

## Value

A data frame in the standard bibnets format: `id`, `title`, `year`,
`journal`, `doi`, `cited_by_count`, `abstract`, `type`, plus
list-columns `authors`, `references`, and `keywords`. Scopus-specific
extras: `index_keywords` (list-column), `affiliations` (character),
`language` (character).

## Examples

``` r
if (FALSE) { # \dontrun{
data <- read_scopus("scopus_export.csv")
} # }
```
