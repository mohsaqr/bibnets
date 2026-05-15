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
f <- system.file("extdata", "lens_sample.csv", package = "bibnets")
data <- read_lens(f)
head(data[, c("id", "title", "year", "journal")])
#>            id                                       title year
#> 1 000-111-222 Bibliometric networks in education research 2022
#> 2 000-333-444  Co-citation analysis of learning analytics 2021
#>                     journal
#> 1 Journal of Scientometrics
#> 2        Learning Analytics
```
