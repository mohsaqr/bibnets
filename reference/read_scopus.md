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
f <- system.file("extdata", "scopus_sample.csv", package = "bibnets")
data <- read_scopus(f)
head(data[, c("id", "title", "year", "journal")])
#>           id                                       title year
#> 1 2-s2.0-001 Bibliometric networks in education research 2022
#> 2 2-s2.0-002  Co-citation analysis of learning analytics 2021
#>                     journal
#> 1 Journal of Scientometrics
#> 2        Learning Analytics
```
