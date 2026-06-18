# Scopus dataset — Green Cloud Computing and Quantization (2020–2025)

First 500 records from a Scopus bibliometric export on the intersection
of green cloud computing and quantization, covering 2020–2025. Includes
full references, author keywords, index keywords, and affiliations.

## Usage

``` r
scopus_quantum_cloud
```

## Format

A data frame with 499 rows and 12 columns:

- id:

  Scopus EID.

- title:

  Work title.

- year:

  Publication year (integer).

- journal:

  Source title.

- doi:

  DOI string without the `https://doi.org/` prefix.

- cited_by_count:

  Times cited in Scopus.

- abstract:

  Abstract text.

- type:

  Document type (`"Article"`, `"Review"`, etc.).

- authors:

  List-column of author name strings.

- references:

  List-column of cited reference strings.

- keywords:

  List-column of author keywords.

- affiliations:

  List-column of affiliation strings.

## Source

Scopus bibliometric export. Dataset archived at
[doi:10.5281/zenodo.17142636](https://doi.org/10.5281/zenodo.17142636)
(CC BY 4.0).

## Examples

``` r
data(scopus_quantum_cloud)
author_network(scopus_quantum_cloud, "collaboration")
#> # bibnets network: author_collaboration | 1,695 nodes · 7,854 edges | counting: full 
#>     from        to         weight  count
#>  1  WANG Y      YIN S           9      9
#>  2  WANG Y      WEI S           7      7
#>  3  WEI S       YIN S           7      7
#>  4  CAI H       LIU B           6      6
#>  5  LIU L       WANG Y          6      6
#>  6  LIU L       WEI S           6      6
#>  7  LIU L       YIN S           6      6
#>  8  CHUANG Y-C  HUANG C-T       5      5
#>  9  CHANG M-F   TANG K-T        5      5
#> 10  MARTINS RP  UN K-F          5      5
#> # ... 7,844 more edges
keyword_network(scopus_quantum_cloud)
#> # bibnets network: keyword_co_occurrence | 1,267 nodes · 4,993 edges | counting: full 
#>     from                   to                    weight  count
#>  1  EDGE COMPUTING         QUANTIZATION              16     16
#>  2  DEEP LEARNING          QUANTIZATION              14     14
#>  3  DEEP LEARNING          EDGE COMPUTING            13     13
#>  4  DEEP LEARNING          FPGA                      10     10
#>  5  PRUNING                QUANTIZATION              10     10
#>  6  EDGE COMPUTING         ENERGY EFFICIENCY          9      9
#>  7  DEEP LEARNING          ENERGY EFFICIENCY          8      8
#>  8  APPROXIMATE COMPUTING  QUANTIZATION               7      7
#>  9  MODEL COMPRESSION      QUANTIZATION               7      7
#> 10  FPGA                   HARDWARE ACCELERATOR       6      6
#> # ... 4,983 more edges
document_network(scopus_quantum_cloud, "coupling", similarity = "cosine")
#> # bibnets network: document_coupling | 381 nodes · 3,920 edges | counting: full | similarity: cosine 
#>     from                 to                  weight  count
#>  1  2-s2.0-85169545148   2-s2.0-85150169631  0.4671     12
#>  2  2-s2.0-85203687776   2-s2.0-85200587918  0.3872     10
#>  3  2-s2.0-85131677679   2-s2.0-85172072697  0.3424      7
#>  4  2-s2.0-85187392673   2-s2.0-85124224751   0.269     11
#>  5  2-s2.0-85161914543   2-s2.0-85100337829  0.2443     13
#>  6  2-s2.0-85208437403   2-s2.0-85151751249   0.189      1
#>  7  2-s2.0-85190173543   2-s2.0-85176469543  0.1723     13
#>  8  2-s2.0-85183972273   2-s2.0-85118652902  0.1636      8
#>  9  2-s2.0-85183972273   2-s2.0-85103250029  0.1576      4
#> 10  2-s2.0-105007025300  2-s2.0-85151751249  0.1508      1
#> # ... 3,910 more edges
```
