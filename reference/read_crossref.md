# Convert Crossref API data to bibnets format

Takes the output of
[`rcrossref::cr_works()`](https://docs.ropensci.org/rcrossref/reference/cr_works.html)
(the `$data` tibble/data frame) and converts it to the standardized
bibnets format.

## Usage

``` r
read_crossref(data)
```

## Arguments

- data:

  A data frame from `cr_works(...)$data`.

## Value

A data frame in the standard bibnets format: `id`, `title`, `year`,
`journal`, `doi`, `cited_by_count`, `abstract`, `type`, plus
list-columns `authors`, `references`, and `keywords`.

## Examples

``` r
if (FALSE) { # \dontrun{
library(rcrossref)
raw <- cr_works(query = "bibliometric networks")
data <- read_crossref(raw$data)
} # }
```
