# Align columns before row-binding bibliographic files

`align_biblio_columns()` gives every data frame in a list the same
columns in the same order, so that they can be row-bound. A missing
list-column is filled with empty character vectors and any other missing
column with `NA`. It returns the list of aligned data frames.

## Usage

``` r
align_biblio_columns(dfs)
```
