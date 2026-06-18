# Strip surrounding quote characters from entity labels

Removes leading/trailing double-quote characters (straight `"`, the CSV
doubled `""`, and curly quotes) plus surrounding whitespace, so quoted
values such as `"Alice"` or `""Bob""` become `Alice` / `Bob`. Quotes
inside a label (e.g. an apostrophe in `O'Brien`) are left untouched.

## Usage

``` r
strip_surrounding_quotes(x)
```

## Arguments

- x:

  Character vector.

## Value

Character vector with surrounding quotes/whitespace removed.
