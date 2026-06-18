# Build a source (journal) network

Constructs a network between publication sources (journals, book
series).

## Usage

``` r
source_network(
  data,
  type = "coupling",
  counting = "full",
  similarity = "none",
  threshold = 0,
  min_occur = 1L,
  top_n = NULL,
  self_loops = FALSE,
  deduplicate = TRUE,
  format = "edgelist",
  journal = "journal",
  sep = ";",
  references_sep = ";",
  strip_quotes = TRUE,
  id = NULL
)
```

## Arguments

- data:

  A data frame with `id` and `journal` (character column). For coupling,
  also needs `references`. For co-citation, needs a `cited_journals`
  list-column.

- type:

  Character. `"coupling"` (default), `"co_citation"`, or
  `"equivalence"`.

- counting:

  Character. Counting method. Default `"full"`.

- similarity:

  Character. Similarity measure. Default `"none"`.

- threshold:

  Numeric. Minimum edge weight. Default 0.

- min_occur:

  Integer. Minimum papers per source. Default 1.

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

- journal:

  Character. Name of the column containing the publication source.
  Default `"journal"`. Use this to point at any column of a custom data
  set, e.g. `journal = "Source title"`.

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
data(biblio_data)
source_network(biblio_data, "coupling")
#> # bibnets network: source_coupling | 4 nodes · 6 edges | counting: full 
#>    from                          to                            weight  count
#> 1  JASIST                        JOURNAL OF INFORMETRICS            6      6
#> 2  JASIST                        SCIENTOMETRICS                     6      6
#> 3  JOURNAL OF INFORMETRICS       SCIENTOMETRICS                     5      5
#> 4  JOURNAL OF INFORMETRICS       QUANTITATIVE SCIENCE STUDIES       2      2
#> 5  JASIST                        QUANTITATIVE SCIENCE STUDIES       1      1
#> 6  QUANTITATIVE SCIENCE STUDIES  SCIENTOMETRICS                     1      1
```
