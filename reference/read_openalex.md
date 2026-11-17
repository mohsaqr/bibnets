# Convert OpenAlex data to bibnets format

`read_openalex()` converts the output of
[`openalexR::oa_fetch()`](https://docs.ropensci.org/openalexR/reference/oa_fetch.html)
(a tibble/data frame of works) to the standardized bibnets format with
list-columns. For a flat CSV downloaded from the OpenAlex website, use
[`read_openalex_csv()`](https://pak.dynasite.org/bibnets-pkg/reference/read_openalex_csv.md).

## Usage

``` r
read_openalex(data)
```

## Arguments

- data:

  A data frame from `oa_fetch(entity = "works", ...)`. Must contain at
  least an `id` column. Common columns include `display_name`,
  `publication_year`, `so`, `doi`, `cited_by_count`, `referenced_works`,
  `ab`, and `author` (nested).

## Value

A data frame in the standard bibnets format: `id`, `title`, `year`,
`journal`, `doi`, `cited_by_count`, `abstract`, `type`, plus
list-columns `authors`, `references`, and `keywords`.

## Examples

``` r
# Construct a minimal data frame matching the structure returned by
# openalexR::oa_fetch(entity = "works", ...). In practice, pass the
# result of oa_fetch() directly.
raw <- data.frame(
  id = c("W123", "W456"),
  display_name = c("First paper", "Second paper"),
  publication_year = c(2022L, 2021L),
  so = c("Journal A", "Journal B"),
  doi = c("https://doi.org/10.1/a", "https://doi.org/10.2/b"),
  cited_by_count = c(5L, 12L),
  author = I(list(
    data.frame(au_display_name = c("Smith J", "Jones A")),
    data.frame(au_display_name = "Davis M")
  )),
  referenced_works = I(list(c("W100", "W200"), "W123"))
)
data <- read_openalex(raw)
subset(data, select = c(id, title, year, doi, authors, references))
#>     id        title year    doi          authors references
#> 1 W123  First paper 2022 10.1/a SMITH J, JONES A W100, W200
#> 2 W456 Second paper 2021 10.2/b          DAVIS M       W123
```
