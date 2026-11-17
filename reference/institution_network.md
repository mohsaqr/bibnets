# Build an institution network

`institution_network()` builds a network between institutions
(affiliations). In a collaboration network two institutions are linked
when they appear on the same paper; in a coupling network they are
linked when their papers cite the same references; the equivalence type
uses the cosine similarity of the institutions' paper-incidence vectors.

## Usage

``` r
institution_network(
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
  affiliations = "affiliations",
  sep = ";",
  references_sep = ";",
  strip_quotes = TRUE,
  id = NULL
)
```

## Arguments

- data:

  A data frame with one row per work and an affiliation column
  (list-column or delimited string). An `id` column is optional (see
  `id`). For coupling, also needs `references`.

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

  Integer. Minimum papers per institution. Default 1.

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

- affiliations:

  Character. Name of the column containing institutions. Default
  `"affiliations"`.

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
method with an attention weighting of the affiliation order. It returns
a `bibnets_network` edge list by default. For countries see
[`country_network()`](https://pak.dynasite.org/bibnets-pkg/reference/country_network.md);
for authors see
[`author_network()`](https://pak.dynasite.org/bibnets-pkg/reference/author_network.md).

## Examples

``` r
data(learning_analytics)
institution_network(learning_analytics, "collaboration")
#> # bibnets network: institution_collaboration | 1,199 nodes · 2,649 edges | counting: full 
#>     from                            to                              weight  count
#>  1  FINLAND UNIVERSITY              UNIVERSITY OF EASTERN FINLAND       13     13
#>  2  DIPF                            LEIBNIZ INSTITUTE FOR RESEARC…      10     10
#>  3  UNIVERSIDADE FEDERAL DE SANTA…  UNIVERSITY OF VALPARAÍSO           10     10
#>  4  MAASTRICHT SCHOOL OF MANAGEME…  MAASTRICHT UNIVERSITY                6      6
#>  5  ESCUELA SUPERIOR POLITECNICA …  MONASH UNIVERSITY                    6      6
#>  6  PONTIFICIA UNIVERSIDAD CATÓLI…  UNIVERSIDADE FEDERAL DE SANTA…       6      6
#>  7  UNIVERSITY OF EASTERN FINLAND   UNIVERSITY OF JYVÄSKYLÄ            6      6
#>  8  PONTIFICIA UNIVERSIDAD CATÓLI…  UNIVERSITY OF VALPARAÍSO            6      6
#>  9  DIPF                            GOETHE UNIVERSITY FRANKFURT          5      5
#> 10  GOETHE UNIVERSITY FRANKFURT     LEIBNIZ INSTITUTE FOR RESEARC…       5      5
#> # ... 2,639 more edges
```
