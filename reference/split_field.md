# Split delimited strings into a list-column

`split_field()` splits delimited strings (semicolons are common in
Scopus/WoS exports) into character vectors, trimming whitespace around
each piece and dropping empty pieces. This is the operation every reader
and builder applies to a multi-valued character column; use it to
prepare a list-column yourself.

## Usage

``` r
split_field(x, sep = ";")
```

## Arguments

- x:

  A character vector (a factor is coerced to character) of delimited
  strings.

- sep:

  Character. Literal delimiter (not a regular expression). Default
  `";"`.

## Value

A list the same length as `x`; element `i` is the character vector of
pieces of `x[i]`. `NA` and empty strings give `character(0)`.

## Examples

``` r
split_field(c("Alice; Bob; Carol", "Dave; Eve"))
#> [[1]]
#> [1] "Alice" "Bob"   "Carol"
#> 
#> [[2]]
#> [1] "Dave" "Eve" 
#> 
split_field(c("a|b|c", "d||e", NA), sep = "|")
#> [[1]]
#> [1] "a" "b" "c"
#> 
#> [[2]]
#> [1] "d" "e"
#> 
#> [[3]]
#> character(0)
#> 
```
