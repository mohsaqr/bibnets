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
# Construct a minimal data frame matching the structure of
# rcrossref::cr_works(...)$data. In practice, pass that data frame directly.
raw <- data.frame(
  doi = c("10.1/a", "10.2/b"),
  title = c("First paper", "Second paper"),
  issued = c("2022-01-01", "2021-06-15"),
  container.title = c("Journal A", "Journal B"),
  is.referenced.by.count = c("3", "9"),
  type = c("journal-article", "journal-article"),
  stringsAsFactors = FALSE
)
raw$author <- list(
  data.frame(given = c("Jane", "Anne"),
             family = c("Smith", "Jones"),
             stringsAsFactors = FALSE),
  data.frame(given = "Mark", family = "Davis", stringsAsFactors = FALSE)
)
data <- read_crossref(raw)
head(data[, c("id", "title", "year", "journal")])
#>       id        title year   journal
#> 1 10.1/a  First paper 2022 Journal A
#> 2 10.2/b Second paper 2021 Journal B
```
