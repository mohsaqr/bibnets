# Build a source (journal) network

`source_network()` builds a network between publication sources
(journals, book series). By default two sources are linked by
bibliographic coupling, when their papers share cited references; the
other types are source co-citation (sources cited together, from a
`cited_journals` column) and the cosine similarity of the sources'
pooled reference vectors.

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

  A data frame with one row per work and a journal column (one value per
  work). An `id` column is optional (see `id`). Coupling and equivalence
  also need `references`; co-citation needs a `cited_journals`
  list-column.

- type:

  Character. `"coupling"` (default; sources linked by the references
  their papers share), `"co_citation"` (sources cited together, from
  `cited_journals`), or `"equivalence"` (cosine similarity of the
  sources' pooled reference vectors; `counting` and `similarity` are
  ignored).

- counting:

  Character. Counting method: `"full"` (default), `"fractional"`,
  `"paper"` or `"strength"`.

- similarity:

  Character. Similarity measure. Default `"none"`.

- threshold:

  Numeric. Minimum edge weight; edges with `weight < threshold` are
  dropped. Default 0 (keep all).

- min_occur:

  Integer. Minimum papers per source. Default 1.

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

- journal:

  Character. Name of the column containing the publication source.
  Default `"journal"`. Use this to point at any column of a custom data
  set, e.g. `journal = "Source title"`.

- sep:

  Character. Not used: the journal column holds one value per work and
  is never split. Kept for a signature consistent with the other
  builders.

- references_sep:

  Character. Separator for the `references` column in
  `type = "coupling"` and `"equivalence"`. Default `";"`.

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

`counting` and `similarity` weight the edges and `threshold`,
`min_occur` and `top_n` prune them. It returns a `bibnets_network` edge
list by default. To link sources by any other field, use
`conetwork(data, "journal", by = ...)` (see
[`conetwork()`](https://pak.dynasite.org/bibnets-pkg/reference/conetwork.md)).

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
