# Read a BibTeX file

Parses a `.bib` file into a standardized bibliometric data frame. Note:
standard BibTeX does not contain cited references, so the `references`
column will be empty unless the file includes a non-standard
`cited-references` or `note` field with reference data.

## Usage

``` r
read_bibtex(file, encoding = "UTF-8")
```

## Arguments

- file:

  Path to a `.bib` file.

- encoding:

  Character. File encoding. Default `"UTF-8"`.

## Value

A data frame in the standard bibnets format: `id`, `title`, `year`,
`journal`, `doi`, `cited_by_count`, `abstract`, `type`, plus
list-columns `authors`, `references` (typically empty for BibTeX), and
`keywords`.

## Examples

``` r
# Write a minimal BibTeX entry to a temp file, then read it
bib <- '@article{smith2020,
  title  = {Bibliometric networks},
  author = {Smith, J. and Jones, K.},
  journal = {Test Journal},
  year   = {2020},
  doi    = {10.1000/test}
}'
f <- tempfile(fileext = ".bib")
writeLines(bib, f)
data <- read_bibtex(f)
data[, c("id", "title", "year", "journal", "doi")]
#>          id                 title year      journal          doi
#> 1 smith2020 Bibliometric networks 2020 Test Journal 10.1000/test
unlink(f)
```
