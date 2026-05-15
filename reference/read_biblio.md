# Read bibliometric data

Universal reader that handles files, folders, format detection, and
generic CSV input. Accepts a single file, multiple files, or a
directory.

## Usage

``` r
read_biblio(path, format = "auto", id = NULL, actors = NULL, sep = ";", ...)
```

## Arguments

- path:

  Character. Path to a file, a vector of file paths, or a directory
  containing export files.

- format:

  Character. File format:

  `"auto"`

  :   Default. Auto-detect from file content.

  `"scopus"`

  :   Scopus CSV.

  `"wos"`

  :   Web of Science plaintext.

  `"wos_tab"`

  :   Web of Science tab-delimited.

  `"bibtex"`

  :   BibTeX .bib file.

  `"ris"`

  :   RIS file.

  `"dimensions"`

  :   Dimensions CSV.

  `"lens"`

  :   Lens.org CSV.

  `"openalex_csv"`

  :   Flat OpenAlex CSV export (pipe-delimited fields).

  `"generic"`

  :   Any CSV. Use `id` and `actors` to specify columns.

- id:

  Character. Column name for document identifier. Only used when
  `format = "generic"`. Default `NULL` (uses row numbers).

- actors:

  Character vector. Column names to split into list-columns. Only used
  when `format = "generic"`.

- sep:

  Character. Delimiter for splitting actor columns. Default `";"`.

- ...:

  Additional arguments passed to the format-specific reader.

## Value

A data frame.

## Examples

``` r
# Auto-detect format from file content (here: a bundled OpenAlex CSV)
f <- system.file("extdata", "openalex_works.csv", package = "bibnets")
data <- read_biblio(f)
head(data[, c("id", "title", "year", "journal")])
#>            id
#> 1 W2769342982
#> 2 W2264893711
#> 3 W2612059685
#> 4 W3118164373
#> 5 W4300484403
#> 6 W4252599113
#>                                                                                                                title
#> 1                                                                         Open University Learning Analytics dataset
#> 2                                                      Educational Data Mining and Learning Analytics in Programming
#> 3                                                   Predicting Student Performance using Advanced Learning Analytics
#> 4 Predicting Student Performance Using Data Mining and Learning Analytics Techniques: A Systematic Literature Review
#> 5                           Artificial Intelligence and Learning Analytics in Teacher Education: A Systematic Review
#> 6                                                                     Educational Data Mining and Learning Analytics
#>   year            journal
#> 1 2017    Scientific Data
#> 2 2015                   
#> 3 2017                   
#> 4 2020   Applied Sciences
#> 5 2022 Education Sciences
#> 6 2016                   

# Read multiple files at once; auto-detects each format
f_scopus <- system.file("extdata", "scopus_sample.csv", package = "bibnets")
f_wos    <- system.file("extdata", "wos_sample.txt",  package = "bibnets")
combined <- read_biblio(c(f_scopus, f_wos))
#> Read 2 files: 4 rows total
head(combined[, c("id", "title", "year", "journal")])
#>                    id                                       title year
#> 1          2-s2.0-001 Bibliometric networks in education research 2022
#> 2          2-s2.0-002  Co-citation analysis of learning analytics 2021
#> 3 WOS:000000000000001 Bibliometric networks in education research 2022
#> 4 WOS:000000000000002  Co-citation analysis of learning analytics 2021
#>                     journal
#> 1 Journal of Scientometrics
#> 2        Learning Analytics
#> 3 Journal of Scientometrics
#> 4        Learning Analytics

# Read every supported export in a directory (here: the bundled extdata)
folder <- system.file("extdata", package = "bibnets")
all_data <- read_biblio(folder)
#> Read 5 files: 1516 rows total
nrow(all_data)
#> [1] 1516

# Generic CSV: point read_biblio at any CSV and name the list-column fields
tmp <- tempfile(fileext = ".csv")
write.csv(data.frame(
  doc_id  = c("a", "b"),
  Authors = c("Smith J; Jones A", "Davis M"),
  Keywords = c("networks; bibliometrics", "analytics")
), tmp, row.names = FALSE)
generic <- read_biblio(tmp, format = "generic",
                       id = "doc_id",
                       actors = c("Authors", "Keywords"),
                       sep = ";")
head(generic)
#>   doc_id          Authors                Keywords id
#> 1      a Smith J, Jones A networks, bibliometrics  a
#> 2      b          Davis M               analytics  b
```
