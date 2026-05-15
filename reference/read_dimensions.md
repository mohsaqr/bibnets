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
f <- system.file("extdata", "dimensions_sample.csv", package = "bibnets")
data <- read_dimensions(f)
head(data[, c("id", "title", "year", "journal")])
#>         id                                       title year
#> 1 pub.1001 Bibliometric networks in education research 2022
#> 2 pub.1002  Co-citation analysis of learning analytics 2021
#>                     journal
#> 1 Journal of Scientometrics
#> 2        Learning Analytics
```
