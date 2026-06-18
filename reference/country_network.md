# Build a country network

Constructs a network between countries based on collaboration or
coupling.

## Usage

``` r
country_network(
  data,
  type = "collaboration",
  counting = "full",
  similarity = "none",
  threshold = 0,
  min_occur = 1L,
  attention = NULL,
  top_n = NULL,
  self_loops = FALSE,
  deduplicate = TRUE,
  format = "edgelist",
  countries = "countries",
  sep = ";",
  references_sep = ";",
  strip_quotes = TRUE,
  id = NULL
)
```

## Arguments

- data:

  A data frame with `id` and a country column (list-column or delimited
  string). For coupling, also needs `references`.

- type:

  Character. `"collaboration"` (default), `"coupling"`, or
  `"equivalence"`.

- counting:

  Character. Counting method. Default `"full"`.

- similarity:

  Character. Similarity measure. Default `"none"`.

- threshold:

  Numeric. Minimum edge weight. Default 0.

- min_occur:

  Integer. Minimum papers per country. Default 1.

- attention:

  Character or NULL. Attention-based weighting independent of `type` and
  `counting`. One of `"proximity"` (center authors weighted most),
  `"lead"` (first author dominates, quadratic drop), `"last"` (last
  author dominates, quadratic rise), `"circular"` (first and last both
  prominent). Default `NULL` (disabled).

- top_n:

  Integer or NULL. Return only the top n edges by weight. Default NULL
  (all edges).

- self_loops:

  Logical. If `TRUE`, include self-loops (an entity linked to itself).
  Default `FALSE`.

- deduplicate:

  Logical. If `TRUE` (default), each `(paper, entity)` pair is counted
  at most once — duplicate entries in the source data (e.g., the same
  author listed twice on a paper) are treated as one occurrence. Set to
  `FALSE` to count every raw occurrence.

- format:

  Character. Output format:

  `"edgelist"`

  :   Default. A `bibnets_network` data frame with columns `from`, `to`,
      `weight`, `count`.

  `"gephi"`

  :   Gephi-ready data frame: `Source`, `Target`, `Weight`, `Count`,
      `Type`.

  `"igraph"`

  :   An igraph graph object (requires igraph).

  `"cograph"`

  :   A cograph_network object (requires cograph).

  `"matrix"`

  :   A sparse adjacency matrix.

- countries:

  Character. Name of the column containing countries. Default
  `"countries"`.

- sep:

  Character. Separator used to split the entity column when it is a
  plain character column rather than a list-column, e.g. `sep = ","` or
  `sep = " and "`. Default `";"`. Ignored for list-columns. `sep`
  applies only to the author column; the references column uses
  `references_sep`.

- references_sep:

  Character. Separator for the `references` column in
  `type = "coupling"`. Default `";"`.

- strip_quotes:

  Logical. If `TRUE` (default), surrounding quote characters are removed
  from each entity.

- id:

  Optional. Name of the column to use as the work identifier (the
  matrix-row dimension). If `NULL` (default), an existing `id` column is
  used when present, otherwise row numbers are used.

## Value

Depends on `format`: a `bibnets_network` data frame (default), a
Gephi-ready data frame, an igraph graph, a cograph_network, or a sparse
matrix.

## Examples

``` r
data(learning_analytics)
country_network(learning_analytics, "collaboration")
#> # bibnets network: country_collaboration | 94 nodes · 426 edges | counting: full 
#>     from  to  weight  count
#>  1  AU    US      15     15
#>  2  CA    US      13     13
#>  3  GB    US      13     13
#>  4  BR    CL      11     11
#>  5  CN    US      11     11
#>  6  DE    NL      10     10
#>  7  AU    GB       9      9
#>  8  BR    US       9      9
#>  9  ES    US       9      9
#> 10  AU    DE       8      8
#> # ... 416 more edges
```
