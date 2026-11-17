# Build a historiograph (chronological citation network)

`historiograph()` builds a Garfield-style historiograph (Garfield,
2004): the `n` most locally cited documents and the within-corpus
citations they receive, each edge carrying the publication years of both
ends so the network can be laid out chronologically. The citing document
of an edge may be any document in the data, not only one of the `n`
selected.

## Usage

``` r
historiograph(
  data,
  n = 30,
  min_lcs = 1,
  references = "references",
  sep = ";",
  strip_quotes = TRUE,
  id = NULL
)
```

## Arguments

- data:

  A data frame with one row per work, a references column (list-column
  or delimited string) whose values use the same identifiers as the
  works, and `year`. An `id` column is optional (see `id`). Optionally
  `title`, `journal`, `doi`, `cited_by_count`.

- n:

  Integer. Number of top locally cited documents to include. Default 30.

- min_lcs:

  Integer. Minimum local citation score for inclusion. Default 1.

- references:

  Character. Name of the column containing cited references. Default
  `"references"`.

- sep:

  Character. Separator used to split the references column when it is a
  plain character column. Default `";"`.

- strip_quotes:

  Logical. If `TRUE` (default), surrounding quote characters are removed
  from each reference.

- id:

  Optional. Name of the column to use as the work identifier. If `NULL`
  (default), an existing `id` column is used when present, otherwise row
  numbers are used.

## Value

A list of two data frames:

- `nodes`:

  One row per included document (at most `n`, each with
  `lcs >= min_lcs`), with the
  [`local_citations()`](https://pak.dynasite.org/bibnets-pkg/reference/local_citations.md)
  columns (`id`, `lcs`, `gcs` when available, `year`, and `title`,
  `journal`, `doi` when present), sorted by decreasing `lcs`.

- `edges`:

  One row per distinct directed citation that points at an included
  document, with `from` (citing; any document in the data), `to`
  (cited), `year_from` and `year_to` (integer), sorted by `year_from`
  then `year_to`.

Both are empty (zero rows) when no document reaches `min_lcs`.

## Details

The documents are ranked by
[`local_citations()`](https://pak.dynasite.org/bibnets-pkg/reference/local_citations.md);
`n` and `min_lcs` set how many are kept. It returns a list with a
`nodes` and an `edges` data frame.

## References

Garfield, E. (2004). Historiographic mapping of knowledge domains
literature. *Journal of Information Science*, 30(2), 119–145.
[doi:10.1177/0165551504042802](https://doi.org/10.1177/0165551504042802)

## Examples

``` r
data(biblio_data)
historiograph(biblio_data, n = 5)
#> $nodes
#>   id lcs gcs year                                         title
#> 1 W1   7  45 2018 Co-citation analysis of scientific literature
#> 2 W2   4  32 2019    Bibliographic coupling and research fronts
#> 3 W3   2  18 2020          Fractional counting in bibliometrics
#> 4 W5   1  12 2021      Community detection in citation networks
#>                   journal            doi
#> 1          Scientometrics 10.1000/test.1
#> 2 Journal of Informetrics 10.1000/test.2
#> 3          Scientometrics 10.1000/test.3
#> 4 Journal of Informetrics 10.1000/test.5
#> 
#> $edges
#>    from to year_from year_to
#> 1    W2 W1      2019    2018
#> 2    W4 W1      2019    2018
#> 3    W9 W1      2019    2018
#> 4    W4 W2      2019    2019
#> 5    W9 W2      2019    2019
#> 6    W3 W1      2020    2018
#> 7    W6 W1      2020    2018
#> 8    W6 W2      2020    2019
#> 9    W5 W1      2021    2018
#> 10  W10 W2      2021    2019
#> 11   W5 W3      2021    2020
#> 12  W10 W3      2021    2020
#> 13   W8 W1      2022    2018
#> 14   W8 W5      2022    2021
#> 
```
