# Read a flat OpenAlex CSV export

Reads the flat CSV format downloaded directly from the OpenAlex website
(`openalex.org/works` exports). Multi-value fields are pipe-delimited
(`|`). This is distinct from the nested tibble produced by
[`openalexR::oa_fetch()`](https://docs.ropensci.org/openalexR/reference/oa_fetch.html),
which is handled by
[`read_openalex()`](https://saqr.me/bibnets-pkg/reference/read_openalex.md).

## Usage

``` r
read_openalex_csv(file, sep = "|")
```

## Arguments

- file:

  Path to the CSV file.

- sep:

  Character. Delimiter for multi-value fields. Default `"|"`.

## Value

A data frame in the standard bibnets format: `id`, `title`, `year`,
`journal`, `doi`, `cited_by_count`, `abstract`, `type`, plus
list-columns `authors`, `references`, `keywords`, `affiliations`,
`countries`. `abstract` and `references` are always `NA` / empty (not
available in the flat export).

## Examples

``` r
f <- system.file("extdata", "openalex_works.csv", package = "bibnets")
data <- read_openalex_csv(f)
```
