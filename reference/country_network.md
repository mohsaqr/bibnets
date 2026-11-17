# Build a country network

`country_network()` builds a network between countries based on
collaboration or coupling. In a collaboration network two countries are
linked when they appear on the same paper; in a coupling network they
are linked when their papers cite the same references; the equivalence
type uses the cosine similarity of the countries' paper-incidence
vectors.

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

  A data frame with one row per work and a country column (list-column
  or delimited string). An `id` column is optional (see `id`). For
  coupling, also needs `references`.

- type:

  Character. `"collaboration"` (default), `"coupling"`, or
  `"equivalence"` (cosine similarity of paper-incidence vectors;
  `counting` and `similarity` are ignored). Ignored when `attention` is
  set.

- counting:

  Character. Counting method: `"full"` (default), `"fractional"`,
  `"paper"` or `"strength"`. Ignored when `attention` is set.

- similarity:

  Character. Similarity measure. Default `"none"`.

- threshold:

  Numeric. Minimum edge weight; edges with `weight < threshold` are
  dropped. Default 0 (keep all).

- min_occur:

  Integer. Minimum papers per country. Default 1.

- attention:

  Character or NULL. Attention-based weighting independent of `type` and
  `counting`. One of `"proximity"` (center authors weighted most),
  `"lead"` (first author dominates, quadratic drop), `"last"` (last
  author dominates, quadratic rise), `"circular"` (first and last both
  prominent). The weights of one paper sum to 1 and an edge receives the
  product of its two endpoints' weights. When `attention` is set, `type`
  and `counting` are ignored. Default `NULL` (disabled).

- top_n:

  Integer or NULL. Keep only the `top_n` most frequent nodes and return
  the edges among them. Default `NULL` (all nodes).

- self_loops:

  Logical. If `TRUE`, include self-loops (an entity linked to itself).
  Default `FALSE`. Only takes effect with `similarity = "none"`; every
  similarity measure zeroes the diagonal.

- deduplicate:

  Logical. If `TRUE` (default), each `(paper, entity)` pair is counted
  at most once – duplicate entries in the source data (e.g., the same
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

  Character. Separator used to split the entity column (the one named by
  the column argument, e.g. `authors`) when it is a plain character
  column rather than a list-column, e.g. `sep = ","` or `sep = " and "`.
  Default `";"`. Ignored for list-columns. In coupling networks the
  references column is split with `references_sep` instead.

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

Depends on `format`. The default `"edgelist"` returns a
`bibnets_network` data frame with one row per undirected edge, columns
`from`, `to`, `weight` and `count`, sorted by decreasing `weight`, and
attributes `network_type`, `counting` and `similarity`. See
[`author_network()`](https://pak.dynasite.org/bibnets-pkg/reference/author_network.md)
for the other formats.

## Details

`counting` and `similarity` weight the edges, `threshold`, `min_occur`
and `top_n` prune them, and `attention` replaces the type and counting
method with an attention weighting of the country order. It returns a
`bibnets_network` edge list by default. For institutions see
[`institution_network()`](https://pak.dynasite.org/bibnets-pkg/reference/institution_network.md);
for authors see
[`author_network()`](https://pak.dynasite.org/bibnets-pkg/reference/author_network.md).

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
