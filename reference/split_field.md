# Parse semicolon-delimited strings into list-column

Splits semicolon-separated strings (common in Scopus/WoS exports) into
character vectors, trimming whitespace.

## Usage

``` r
split_field(x, sep = ";")
```

## Arguments

- x:

  A character vector of semicolon-delimited strings.

- sep:

  Character. Delimiter. Default `";"`.

## Value

A list of character vectors.

## Examples

``` r
split_field(c("Alice; Bob; Carol", "Dave; Eve"))
#> [[1]]
#> [1] "Alice" "Bob"   "Carol"
#> 
#> [[2]]
#> [1] "Dave" "Eve" 
#> 
```
