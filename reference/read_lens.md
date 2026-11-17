# Read Lens.org CSV export

`read_lens()` parses a CSV file exported from Lens.org into a
standardized bibliometric data frame.
[`read_biblio()`](https://pak.dynasite.org/bibnets-pkg/reference/read_biblio.md)
reads several files at once and detects the format.

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
subset(data, select = c(id, title, year, journal, authors))
#>            id                                       title year
#> 1 000-111-222 Bibliometric networks in education research 2022
#> 2 000-333-444  Co-citation analysis of learning analytics 2021
#>                     journal            authors
#> 1 Journal of Scientometrics SMITH, J, JONES, A
#> 2        Learning Analytics   DAVIS, M, LEE, K
```
