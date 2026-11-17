# Build a network where entities share values from another field

`build_by_network()` builds the network behind `conetwork(by = ...)`:
two entities of `field` are linked when they share values of the `by`
field across documents. It pools each entity's `by` values, builds an
entities x values two-mode matrix and projects it onto the entities,
returning an edge data frame with columns `from`, `to`, `weight` and
`count`.

## Usage

``` r
build_by_network(
  data,
  field,
  by,
  counting,
  similarity,
  threshold,
  min_occur,
  top_n = NULL,
  self_loops = FALSE,
  deduplicate = TRUE,
  strip_quotes = TRUE
)
```
