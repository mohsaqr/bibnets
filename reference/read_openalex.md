# Convert OpenAlex data to bibnets format

Takes the output of
[`openalexR::oa_fetch()`](https://docs.ropensci.org/openalexR/reference/oa_fetch.html)
(a tibble/data frame of works) and converts it to the standardized
bibnets format with list-columns.

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
if (FALSE) { # \dontrun{
library(openalexR)
raw <- oa_fetch(entity = "works", search = "bibliometric networks",
                count_only = FALSE)
data <- read_openalex(raw)
} # }
```
