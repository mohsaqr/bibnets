# Example bibliometric dataset

A small synthetic dataset of 10 scholarly papers with overlapping
authors, references, and keywords. Designed for testing and
demonstrating all network construction functions in bibnets.

## Usage

``` r
biblio_data
```

## Format

A data frame with 10 rows and 9 columns:

- id:

  Unique document identifier (W1–W10).

- title:

  Document title.

- year:

  Publication year (2018–2022).

- journal:

  Source journal (Scientometrics, Journal of Informetrics, JASIST,
  Quantitative Science Studies).

- doi:

  DOI string.

- cited_by_count:

  Times cited.

- authors:

  List-column of author name strings (6 unique authors).

- references:

  List-column of cited reference IDs (10 unique refs, R1–R10). Each
  paper cites exactly 4 references.

- keywords:

  List-column of keyword strings (24 unique keywords). Each paper has 3
  keywords.

## Examples

``` r
data(biblio_data)
reference_network(biblio_data)
#> # bibnets network: reference_co_citation | 13 nodes · 38 edges | counting: full 
#>     from  to  weight  count
#>  1  R3    W1       4      4
#>  2  R1    R2       3      3
#>  3  R2    R5       3      3
#>  4  R2    W1       3      3
#>  5  R4    W1       3      3
#>  6  R3    W2       3      3
#>  7  W1    W2       3      3
#>  8  R2    R3       2      2
#>  9  R3    R4       2      2
#> 10  R1    R5       2      2
#> # ... 28 more edges
document_network(biblio_data, "coupling")
#> # bibnets network: document_coupling | 10 nodes · 36 edges | counting: full 
#>     from  to  weight  count
#>  1  W4    W9       4      4
#>  2  W1    W3       3      3
#>  3  W4    W6       3      3
#>  4  W1    W7       3      3
#>  5  W6    W9       3      3
#>  6  W1    W2       2      2
#>  7  W2    W3       2      2
#>  8  W2    W4       2      2
#>  9  W3    W4       2      2
#> 10  W2    W5       2      2
#> # ... 26 more edges
author_network(biblio_data, "collaboration")
#> # bibnets network: author_collaboration | 6 nodes · 12 edges | counting: full 
#>     from     to       weight  count
#>  1  CHEN W   LEE K         3      3
#>  2  BROWN M  SMITH J       3      3
#>  3  BROWN M  LEE K         2      2
#>  4  JONES A  LEE K         2      2
#>  5  JONES A  SMITH J       2      2
#>  6  LEE K    SMITH J       2      2
#>  7  BROWN M  CHEN W        1      1
#>  8  BROWN M  DAVIS R       1      1
#>  9  CHEN W   DAVIS R       1      1
#> 10  CHEN W   JONES A       1      1
#> # ... 2 more edges
```
