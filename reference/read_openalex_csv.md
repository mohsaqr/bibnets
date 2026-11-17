# Read a flat OpenAlex CSV export

`read_openalex_csv()` reads the flat CSV format downloaded directly from
the OpenAlex website (`openalex.org/works` exports). Multi-value fields
are pipe-delimited (`|`). This is distinct from the nested tibble
produced by
[`openalexR::oa_fetch()`](https://docs.ropensci.org/openalexR/reference/oa_fetch.html),
which is handled by
[`read_openalex()`](https://pak.dynasite.org/bibnets-pkg/reference/read_openalex.md).

## Usage

``` r
read_openalex_csv(file, sep = "|")
```

## Arguments

- file:

  Path to the CSV file.

- sep:

  Character. Delimiter for multi-value fields. Default `"|"`.

## Value

A data frame in the standard bibnets format: `id`, `title`, `year`,
`journal`, `doi`, `cited_by_count`, `abstract`, `type`, plus
list-columns `authors`, `references`, `keywords`, `affiliations`,
`countries`, one row per work. `abstract` is always `NA` and every
`references` element is empty, because the flat export carries neither.

## Examples

``` r
f <- system.file("extdata", "openalex_works.csv", package = "bibnets")
data <- read_openalex_csv(f)
head(subset(data, select = c(id, year, authors, countries)))
#>            id year
#> 1 W2769342982 2017
#> 2 W2264893711 2015
#> 3 W2612059685 2017
#> 4 W3118164373 2020
#> 5 W4300484403 2022
#> 6 W4252599113 2016
#>                                                                                                                                                                                                                                                   authors
#> 1                                                                                                                                                                                                            Jakub Kužílek, Martin Hlosta, Zdeněk Zdráhal
#> 2 Petri Ihantola, Arto Vihavainen, Alireza Ahadi, Matthew Butler, Jürgen Börstler, Stephen H. Edwards, Essi Isohanni, Ari Korhonen, Andrew Petersen, Kelly Rivers, Miguel A. Rubio, Judy Sheard, Bronius Skūpas, Jaime Spacco, Claudia Szabo, Daniel Toll
#> 3                                                                                                                                                  Ali Daud, Naif Radi Aljohani, Rabeeh Ayaz Abbasi, Miltiadis D. Lytras, Farhat Abbas, Jalal S. Alowibdi
#> 4                                                                                                                                                                                                                    Abdallah Namoun, Abdullah Alshanqiti
#> 5                                                                                                                                                                                                     Sdenka Zobeida Salas‐Pilco, Kejiang Xiao, Xinyun Hu
#> 6                                                                                                                                                                                                             Ryan S. Baker, Taylor Martin, Lisa M. Rossi
#>                                                        countries
#> 1                                             CZ, GB, GB, CZ, GB
#> 2 FI, FI, AU, AU, SE, US, FI, FI, CA, US, ES, AU, LT, US, AU, SE
#> 3                                         SA, SA, SA, GR, PK, SA
#> 4                                                         SA, SA
#> 5                                                     CN, CN, HK
#> 6                                                               
```
