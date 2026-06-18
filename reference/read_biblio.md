# Read bibliometric data

Universal reader that handles files, folders, format detection, and
generic CSV input. Accepts a single file, multiple files, or a
directory.

## Usage

``` r
read_biblio(
  path,
  format = "auto",
  id = NULL,
  authors = NULL,
  keywords = NULL,
  references = NULL,
  countries = NULL,
  affiliations = NULL,
  journal = NULL,
  sep = ";",
  list_cols = NULL,
  ...,
  actors = NULL
)
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

  :   Any CSV. Map its columns with `id`, `authors`, `keywords`,
      `references`, `countries`, `affiliations`, `journal`. Inferred
      automatically when any of those arguments is supplied, so
      `format = "generic"` is optional in that case.

- id:

  Character. Column name for document identifier. Only used when
  `format = "generic"`. Default `NULL` (uses row numbers).

- authors, keywords, references, countries, affiliations:

  Character. For `format = "generic"`, the name of the source column to
  map onto that standard field. Its cells are split on `sep` into a
  list-column. For example `authors = "Author Names"` reads the
  `Author Names` column into the standard `authors` list-column.

- journal:

  Character. For `format = "generic"`, the name of the source column to
  use as the (scalar) `journal` field. Not split.

- sep:

  Character. Delimiter for splitting the mapped multi-valued columns.
  Default `";"`.

- list_cols:

  Character vector. For `format = "generic"`, additional columns to
  split into list-columns *in place* (keeping their original names), for
  fields without a dedicated argument above.

- ...:

  Additional arguments passed to the format-specific reader.

- actors:

  Deprecated. Use the entity arguments (`authors`, `keywords`, ...) or
  `list_cols` instead.

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
#> Read 5 files: 38 rows total
nrow(all_data)
#> [1] 38

# Custom CSV: map each source column onto a standard field by name.
# Naming columns implies format = "generic" (no need to pass it).
tmp <- tempfile(fileext = ".csv")
write.csv(data.frame(
  doc_id  = c("a", "b"),
  Authors = c("Smith J; Jones A", "Davis M"),
  Keywords = c("networks; bibliometrics", "analytics")
), tmp, row.names = FALSE)
generic <- read_biblio(tmp,
                       id = "doc_id",
                       authors = "Authors",
                       keywords = "Keywords",
                       sep = ";")
head(generic)
#>   doc_id          Authors                Keywords id          authors
#> 1      a Smith J; Jones A networks; bibliometrics  a Smith J, Jones A
#> 2      b          Davis M               analytics  b          Davis M
#>                  keywords
#> 1 networks, bibliometrics
#> 2               analytics
```
