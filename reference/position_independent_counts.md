# List the position-independent counting methods

`position_independent_counts()` returns the names of the four
position-independent counting methods: `"full"`, `"fractional"`,
`"paper"` and `"strength"`. Every network builder accepts these; the
position-dependent methods apply only to co-authorship networks (see
[`author_network()`](https://pak.dynasite.org/bibnets-pkg/reference/author_network.md)).

## Usage

``` r
position_independent_counts()
```

## Value

Character vector of method names.
