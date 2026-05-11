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
if (FALSE) { # \dontrun{
# Read an entire folder (merges all files)
data <- read_biblio("scopus_exports/")

# Multiple files
data <- read_biblio(c("scopus1.csv", "scopus2.csv"))

# Explicit format and generic-CSV mode
data <- read_biblio("my_data.csv", format = "generic",
                    id = "doc_id",
                    actors = c("Authors", "Keywords"),
                    sep = ";")
} # }
```
