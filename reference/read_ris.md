# Read an RIS file

Parses a `.ris` file into a standardized bibliometric data frame. Like
BibTeX, standard RIS does not include cited references.

## Usage

``` r
read_ris(file, encoding = "UTF-8")
```

## Arguments

- file:

  Path to a `.ris` file.

- encoding:

  Character. File encoding. Default `"UTF-8"`.

## Value

A data frame in the standard bibnets format: `id`, `title`, `year`,
`journal`, `doi`, `cited_by_count`, `abstract`, `type`, plus
list-columns `authors`, `references` (typically empty for RIS), and
`keywords`.

## Examples

``` r
# Write a minimal RIS record to a temp file, then read it
ris <- "TY  - JOUR
AU  - Smith, J.
AU  - Jones, K.
TI  - Bibliometric networks
JO  - Test Journal
PY  - 2020
DO  - 10.1000/test
ER  - "
f <- tempfile(fileext = ".ris")
writeLines(ris, f)
data <- read_ris(f)
data[, c("id", "title", "year", "journal", "doi")]
#>             id                 title year      journal          doi
#> 1 10.1000/test Bibliometric networks 2020 Test Journal 10.1000/test
unlink(f)
```
