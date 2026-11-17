# Build an author network

`author_network()` builds a network between authors using one of four
relationship types: co-authorship (`"collaboration"`), bibliographic
coupling (`"coupling"`), author co-citation (`"co_citation"`) or profile
similarity (`"equivalence"`). Edges are weighted by any of 13 counting
methods, including 9 position-dependent methods that respect author
byline order, such as harmonic counting (Hagen, 2008); full and
fractional counting are described by Perianes-Rodriguez et al. (2016).

## Usage

``` r
author_network(
  data,
  type = "collaboration",
  counting = "full",
  similarity = "none",
  threshold = 0,
  min_occur = 1L,
  position_weights = c(1, 0.8, 0.6, 0.4),
  first_last_weight = 2,
  attention = NULL,
  top_n = NULL,
  self_loops = FALSE,
  deduplicate = TRUE,
  format = "edgelist",
  authors = "authors",
  sep = ";",
  references_sep = ";",
  strip_quotes = TRUE,
  id = NULL
)
```

## Arguments

- data:

  A data frame with one row per work and an author column (list-column
  or delimited string, byline order preserved). An `id` column is
  optional (see `id`). `type = "coupling"` also needs a `references`
  column; `type = "co_citation"` needs a `cited_first_authors`
  list-column.

- type:

  Character. Relationship type:

  `"collaboration"`

  :   Co-authorship: authors linked when they co-author a publication.

  `"coupling"`

  :   Bibliographic coupling aggregated at author level: authors linked
      when they cite the same references.

  `"co_citation"`

  :   Author co-citation: authors linked when they are cited together by
      the same paper. Requires a `cited_first_authors` list-column.

  `"equivalence"`

  :   Profile similarity: cosine similarity of the authors'
      paper-incidence vectors. `counting` and `similarity` are ignored
      (always cosine).

- counting:

  Character. Counting method. Position-independent methods (`"full"`,
  `"fractional"`, `"paper"`, `"strength"`) work for all types.
  Position-dependent methods (`"harmonic"`, `"arithmetic"`,
  `"geometric"`, `"adaptive_geometric"`, `"golden"`, `"first"`,
  `"last"`, `"first_last"`, `"position_weighted"`) apply to
  `type = "collaboration"`; for the other types they fall back to
  `"full"`.

- similarity:

  Character. Similarity measure: `"none"`, `"association"`, `"cosine"`,
  `"jaccard"`, `"inclusion"`, `"equivalence"`.

- threshold:

  Numeric. Minimum edge weight; edges with `weight < threshold` are
  dropped. Default 0 (keep all).

- min_occur:

  Integer. Minimum number of papers for an author to be included.
  Default 1. Not applied with a position-dependent `counting` method or
  with `attention`.

- position_weights:

  Numeric vector. Custom weights for `counting = "position_weighted"`.
  Default `c(1, 0.8, 0.6, 0.4)`.

- first_last_weight:

  Numeric. Multiplier for `counting = "first_last"`. Default 2.

- attention:

  Character or NULL. Attention-based weighting independent of `type` and
  `counting`. One of `"proximity"` (center authors weighted most),
  `"lead"` (first author dominates, quadratic drop), `"last"` (last
  author dominates, quadratic rise), `"circular"` (first and last both
  prominent). The weights of one paper sum to 1 and an edge receives the
  product of its two endpoints' weights. When `attention` is set, `type`
  and `counting` are ignored. Default `NULL` (disabled).

- top_n:

  Integer or NULL. Keep only the `top_n` most frequent nodes (largest
  diagonal of the projected matrix, i.e. the number of papers under full
  counting) and return the edges among them. Default `NULL` (all nodes).

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

- authors:

  Character. Name of the column containing authors. Default `"authors"`.
  Use this to point at any column of a custom data set, e.g.
  `authors = "Author Names"`.

- sep:

  Character. Separator used to split the entity column (the one named by
  the column argument, e.g. `authors`) when it is a plain character
  column rather than a list-column, e.g. `sep = ","` or `sep = " and "`.
  Default `";"`. Ignored for list-columns. In coupling networks the
  references column is split with `references_sep` instead.

- references_sep:

  Character. Separator for the `references` column in
  `type = "coupling"`. Default `";"` (reference strings usually contain
  internal commas, so this is kept independent of `sep`). Set it when
  your references are delimited differently.

- strip_quotes:

  Logical. If `TRUE` (default), surrounding quote characters are removed
  from each entity, so a quoted CSV value such as `"Alice"` or
  `""Alice""` is treated as `Alice`. Set `FALSE` to keep quotes as part
  of the label.

- id:

  Optional. Name of the column to use as the work identifier (the
  matrix-row dimension). If `NULL` (default), an existing `id` column is
  used when present, otherwise row numbers are used.

## Value

Depends on `format`. The default `"edgelist"` returns a
`bibnets_network`: a data frame with one row per undirected edge and
columns `from`, `to` (character), `weight` (numeric) and `count`
(integer raw co-occurrence), sorted by decreasing `weight`, with
attributes `network_type`, `counting` and `similarity`. `"gephi"`
returns a plain data frame with columns `Source`, `Target`, `Weight`,
`Count`, `Type`; `"igraph"` an igraph graph; `"cograph"` a
`cograph_network`; `"matrix"` a symmetric sparse `dgCMatrix`.

## Details

The authors and the works form a two-mode matrix that is projected onto
the authors; `similarity` normalizes the projected counts, `threshold`,
`min_occur` and `top_n` prune the result, and `attention` replaces the
counting method with an attention weighting of the byline. It returns a
`bibnets_network` edge list by default, or the network in another
`format`. For networks of other entities use
[`keyword_network()`](https://pak.dynasite.org/bibnets-pkg/reference/keyword_network.md),
[`reference_network()`](https://pak.dynasite.org/bibnets-pkg/reference/reference_network.md),
[`document_network()`](https://pak.dynasite.org/bibnets-pkg/reference/document_network.md),
[`source_network()`](https://pak.dynasite.org/bibnets-pkg/reference/source_network.md),
[`country_network()`](https://pak.dynasite.org/bibnets-pkg/reference/country_network.md),
[`institution_network()`](https://pak.dynasite.org/bibnets-pkg/reference/institution_network.md)
or, for any column,
[`conetwork()`](https://pak.dynasite.org/bibnets-pkg/reference/conetwork.md).

## References

Perianes-Rodriguez, A., Waltman, L., & van Eck, N. J. (2016).
Constructing bibliometric networks: A comparison between full and
fractional counting. *Journal of Informetrics*, 10(4), 1178–1195.
[doi:10.1016/j.joi.2016.10.006](https://doi.org/10.1016/j.joi.2016.10.006)

Hagen, N. T. (2008). Harmonic allocation of authorship credit:
Source-level correction of bibliometric bias assures accurate
publication and citation analysis. *PLoS ONE*, 3(12), e4021.
[doi:10.1371/journal.pone.0004021](https://doi.org/10.1371/journal.pone.0004021)

## Examples

``` r
data(biblio_data)
author_network(biblio_data, "collaboration")
#> # bibnets network: author_collaboration | 6 nodes · 12 edges | counting: full 
#>     from     to       weight  count
#>  1  CHEN W   LEE K         3      3
#>  2  BROWN M  SMITH J       3      3
#>  3  BROWN M  LEE K         2      2
#>  4  JONES A  LEE K         2      2
#>  5  JONES A  SMITH J       2      2
#>  6  LEE K    SMITH J       2      2
#>  7  BROWN M  CHEN W        1      1
#>  8  BROWN M  DAVIS R       1      1
#>  9  CHEN W   DAVIS R       1      1
#> 10  CHEN W   JONES A       1      1
#> # ... 2 more edges
author_network(biblio_data, "collaboration", counting = "harmonic")
#> # bibnets network: author_collaboration | 6 nodes · 12 edges | counting: harmonic 
#>     from     to       weight  count
#>  1  BROWN M  SMITH J  0.4702      3
#>  2  JONES A  SMITH J   0.371      2
#>  3  CHEN W   LEE K    0.3214      3
#>  4  CHEN W   DAVIS R  0.2222      1
#>  5  DAVIS R  JONES A  0.2222      1
#>  6  JONES A  LEE K    0.1983      2
#>  7  LEE K    SMITH J  0.1983      2
#>  8  BROWN M  CHEN W   0.1488      1
#>  9  BROWN M  DAVIS R  0.1488      1
#> 10  BROWN M  LEE K    0.1488      2
#> # ... 2 more edges
author_network(biblio_data, "collaboration", counting = "geometric",
               similarity = "association")
#> # bibnets network: author_collaboration | 6 nodes · 12 edges | counting: geometric | similarity: association 
#>     from     to       weight  count
#>  1  CHEN W   LEE K    0.7868      3
#>  2  CHEN W   DAVIS R  0.5303      1
#>  3  BROWN M  SMITH J  0.4494      3
#>  4  DAVIS R  JONES A  0.3619      1
#>  5  JONES A  LEE K    0.3606      2
#>  6  JONES A  SMITH J  0.3255      2
#>  7  BROWN M  DAVIS R  0.3029      1
#>  8  BROWN M  CHEN W   0.2935      1
#>  9  BROWN M  LEE K    0.2465      2
#> 10  LEE K    SMITH J  0.2262      2
#> # ... 2 more edges

# Custom CSV: any column name, any separator
d <- data.frame(id = 1:3,
                Researchers = c("Smith J, Doe A", "Smith J, Lee K",
                                "Doe A, Lee K"))
author_network(d, authors = "Researchers", sep = ",")
#> # bibnets network: author_collaboration | 3 nodes · 3 edges | counting: full 
#>    from   to       weight  count
#> 1  DOE A  LEE K         1      1
#> 2  DOE A  SMITH J       1      1
#> 3  LEE K  SMITH J       1      1
```
