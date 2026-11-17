# Compute local citation scores

`local_citations()` computes the local citation score (LCS) of each
document: how many times it is cited by other documents within the
dataset. When the data carry `cited_by_count`, the global citation score
(GCS) is reported beside it.

## Usage

``` r
local_citations(
  data,
  references = "references",
  sep = ";",
  strip_quotes = TRUE,
  id = NULL
)
```

## Arguments

- data:

  A data frame with one row per work and a references column
  (list-column or delimited string) whose values use the same
  identifiers as the works. An `id` column is optional (see `id`).
  Optionally `year`, `title`, `journal`, `doi`, `cited_by_count`.

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

A data frame with one row per document, sorted by decreasing `lcs`, with
columns:

- `id`:

  Document identifier (character).

- `lcs`:

  Local Citation Score (integer): times cited by other documents in the
  dataset.

- `gcs`:

  Global Citation Score (integer): `cited_by_count`; only when that
  column is present.

followed by `year` (integer), `title`, `journal` and `doi` when present
in the input.

## Details

It returns one row per document, sorted by decreasing `lcs`. To lay the
most locally cited documents out as a chronological citation network,
use
[`historiograph()`](https://pak.dynasite.org/bibnets-pkg/reference/historiograph.md);
for the full citation network, use `document_network(type = "citation")`
(see
[`document_network()`](https://pak.dynasite.org/bibnets-pkg/reference/document_network.md)).

## Examples

``` r
data(biblio_data)
local_citations(biblio_data)
#>     id lcs gcs year                                         title
#> 1   W1   7  45 2018 Co-citation analysis of scientific literature
#> 2   W2   4  32 2019    Bibliographic coupling and research fronts
#> 3   W3   2  18 2020          Fractional counting in bibliometrics
#> 4   W5   1  12 2021      Community detection in citation networks
#> 5   W4   0  55 2019   Network analysis of scholarly communication
#> 6   W6   0   8 2020            Author name disambiguation methods
#> 7   W7   0  22 2018                 Keyword co-occurrence mapping
#> 8   W8   0   5 2022            Temporal patterns in citation data
#> 9   W9   0  38 2019           Normalization of co-occurrence data
#> 10 W10   0  15 2021          Mapping scientific knowledge domains
#>                         journal             doi
#> 1                Scientometrics  10.1000/test.1
#> 2       Journal of Informetrics  10.1000/test.2
#> 3                Scientometrics  10.1000/test.3
#> 4       Journal of Informetrics  10.1000/test.5
#> 5                        JASIST  10.1000/test.4
#> 6                Scientometrics  10.1000/test.6
#> 7                        JASIST  10.1000/test.7
#> 8  Quantitative Science Studies  10.1000/test.8
#> 9                        JASIST  10.1000/test.9
#> 10      Journal of Informetrics 10.1000/test.10
```
