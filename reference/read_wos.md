# Read Web of Science plaintext or tab-delimited export

Parses a Web of Science export file (plaintext or tab-delimited) into a
standardized bibliometric data frame.

## Usage

``` r
read_wos(file, format = "plaintext")
```

## Arguments

- file:

  Path to a WoS export file (.txt).

- format:

  Character. `"plaintext"` (default) for WoS tagged format, or `"tab"`
  for tab-delimited export.

## Value

A data frame in the standard bibnets format: `id`, `title`, `year`,
`journal`, `doi`, `cited_by_count`, `abstract`, `type`, plus
list-columns `authors`, `references`, and `keywords`. WoS-specific
extra: `keywords_plus` (list-column).

## Examples

``` r
f <- system.file("extdata", "wos_sample.txt", package = "bibnets")
data <- read_wos(f)
head(data[, c("id", "title", "year", "journal")])
#>                    id                                       title year
#> 1 WOS:000000000000001 Bibliometric networks in education research 2022
#> 2 WOS:000000000000002  Co-citation analysis of learning analytics 2021
#>                     journal
#> 1 Journal of Scientometrics
#> 2        Learning Analytics
```
