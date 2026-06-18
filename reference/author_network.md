# Build an author network

Constructs a network between authors using one of four relationship
types and any of 13 counting methods, including 9 position-dependent
methods that respect author byline order.

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

  A data frame with at least `id` and an author column (list-column or
  delimited string, order preserved). For coupling/co-citation, also
  needs `references`.

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

  :   Profile similarity: cosine similarity of authors' full
      collaboration/citation profiles.

- counting:

  Character. Counting method. Position-independent methods (`"full"`,
  `"fractional"`, `"paper"`, `"strength"`) work for all types.
  Position-dependent methods (`"harmonic"`, `"arithmetic"`,
  `"geometric"`, `"adaptive_geometric"`, `"golden"`, `"first"`,
  `"last"`, `"first_last"`, `"position_weighted"`) are available for
  `type = "collaboration"`.

- similarity:

  Character. Similarity measure: `"none"`, `"association"`, `"cosine"`,
  `"jaccard"`, `"inclusion"`, `"equivalence"`.

- threshold:

  Numeric. Minimum edge weight. Default 0.

- min_occur:

  Integer. Minimum number of papers for an author to be included.
  Default 1.

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

- authors:

  Character. Name of the column containing authors. Default `"authors"`.
  Use this to point at any column of a custom data set, e.g.
  `authors = "Author Names"`.

- sep:

  Character. Separator used to split the entity column when it is a
  plain character column rather than a list-column, e.g. `sep = ","` or
  `sep = " and "`. Default `";"`. Ignored for list-columns. `sep`
  applies only to the author column; the references column uses
  `references_sep`.

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

Depends on `format`: a `bibnets_network` data frame (default), a
Gephi-ready data frame, an igraph graph, a cograph_network, or a sparse
matrix.

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
