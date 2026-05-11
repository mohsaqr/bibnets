# OpenAlex Gold Open Access Learning Analytics dataset

A corpus of 1,508 gold open-access scholarly works on learning
analytics, retrieved from OpenAlex (CC0 licence). All records have a
verified title, publication year, and at least one author. Journal names
are present for works published in a named source; preprints and book
chapters may have `NA` in `journal`.

## Usage

``` r
open_alex_gold_open_access_learning_analytics
```

## Format

A data frame with 1,508 rows and 11 columns:

- id:

  OpenAlex work ID (e.g. `"W2769342982"`).

- title:

  Work title.

- year:

  Publication year (integer).

- journal:

  Source name, or `NA` if not available.

- doi:

  DOI string without the `https://doi.org/` prefix, or `NA`.

- cited_by_count:

  Number of citing works as recorded in OpenAlex.

- type:

  Work type (`"article"`, `"review"`, `"preprint"`, `"book-chapter"`,
  etc.).

- authors:

  List-column of author display names (pipe-split from the OpenAlex flat
  export; one name per authorship slot).

- keywords:

  List-column with one element: the primary OpenAlex topic for the work
  (e.g. `"Online Learning and Analytics"`).

- affiliations:

  List-column of institution display names (one entry per
  authorship–institution pair).

- countries:

  List-column of two-letter ISO country codes (one entry per
  authorship–institution pair).

## Source

OpenAlex <https://openalex.org>, CC0 licence.

## Examples

``` r
data(open_alex_gold_open_access_learning_analytics)
d <- open_alex_gold_open_access_learning_analytics
author_network(d, "collaboration")
#> # bibnets network: author_collaboration | 4,029 nodes · 12,270 edges | counting: full 
#>     from                        to                          weight  count
#>  1  MOHAMMED SAQR               SONSOLES LÓPEZ‐PERNAS        19     19
#>  2  CRISTIAN CECHINEL           ROBERTO MUÑOZ                  11     11
#>  3  DRAGAN GAŠEVIĆ            ROBERTO MARTÍNEZ‐MALDONADO      10     10
#>  4  ROBERTO MARTÍNEZ‐MALDONADO  VANESSA ECHEVERRÍA             10     10
#>  5  FERNANDA PIRES              MARCELA PESSOA                   8      8
#>  6  LIXIANG YAN                 ROBERTO MARTÍNEZ‐MALDONADO       8      8
#>  7  RIORDAN ALFREDO             ROBERTO MARTÍNEZ‐MALDONADO       8      8
#>  8  DRAGAN GAŠEVIĆ            VANESSA ECHEVERRÍA              8      8
#>  9  RIORDAN ALFREDO             VANESSA ECHEVERRÍA              8      8
#> 10  FABRIZIO HONDA              FERNANDA PIRES                   7      7
#> # ... 12,260 more edges
country_network(d, "collaboration")
#> # bibnets network: country_collaboration | 94 nodes · 426 edges | counting: full 
#>     from  to  weight  count
#>  1  AU    US      15     15
#>  2  CA    US      13     13
#>  3  GB    US      13     13
#>  4  BR    CL      11     11
#>  5  CN    US      11     11
#>  6  DE    NL      10     10
#>  7  AU    GB       9      9
#>  8  BR    US       9      9
#>  9  ES    US       9      9
#> 10  AU    DE       8      8
#> # ... 416 more edges
```
