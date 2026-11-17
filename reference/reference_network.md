# Build a reference network

`reference_network()` builds a co-citation or equivalence network among
cited references. In a co-citation network two references are linked
when they are cited together by the same paper; the equivalence network
instead uses the cosine similarity of the references' citing-paper
vectors.

## Usage

``` r
reference_network(
  data,
  type = "co_citation",
  counting = "full",
  similarity = "none",
  threshold = 0,
  min_occur = 1L,
  top_n = NULL,
  self_loops = FALSE,
  deduplicate = TRUE,
  format = "edgelist",
  references = "references",
  sep = ";",
  strip_quotes = TRUE,
  id = NULL
)
```

## Arguments

- data:

  A data frame with one row per work and a references column
  (list-column or delimited string). An `id` column is optional (see
  `id`).

- type:

  Character. `"co_citation"` (default) or `"equivalence"` (cosine
  similarity of the references' citing-paper vectors; `counting` and
  `similarity` are ignored).

- counting:

  Character. Counting method: `"full"` (default), `"fractional"`,
  `"paper"` or `"strength"`.

- similarity:

  Character. Similarity measure. Default `"none"`.

- threshold:

  Numeric. Minimum edge weight; edges with `weight < threshold` are
  dropped. Default 0 (keep all).

- min_occur:

  Integer. Minimum times a reference must be cited. Default 1.

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

- references:

  Character. Name of the column containing cited references. Default
  `"references"`.

- sep:

  Character. Separator used to split the references column when it is a
  plain character column. Default `";"`. Ignored for list-columns.

- strip_quotes:

  Logical. If `TRUE` (default), surrounding quote characters are removed
  from each reference.

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

The citing papers and their references form a two-mode matrix that is
projected onto the references; `counting` and `similarity` weight the
edges and `threshold`, `min_occur` and `top_n` prune them. It returns a
`bibnets_network` edge list by default. To link the citing documents
instead (bibliographic coupling or direct citation), use
[`document_network()`](https://pak.dynasite.org/bibnets-pkg/reference/document_network.md).

## Examples

``` r
data(biblio_data)
reference_network(biblio_data)
#> # bibnets network: reference_co_citation | 13 nodes · 38 edges | counting: full 
#>     from  to  weight  count
#>  1  R3    W1       4      4
#>  2  R1    R2       3      3
#>  3  R2    R5       3      3
#>  4  R2    W1       3      3
#>  5  R4    W1       3      3
#>  6  R3    W2       3      3
#>  7  W1    W2       3      3
#>  8  R2    R3       2      2
#>  9  R3    R4       2      2
#> 10  R1    R5       2      2
#> # ... 28 more edges
reference_network(biblio_data, similarity = "association")
#> # bibnets network: reference_co_citation | 13 nodes · 38 edges | counting: full | similarity: association 
#>     from  to  weight  count
#>  1  R9    W5       1      1
#>  2  R7    R9     0.5      1
#>  3  R7    W5     0.5      1
#>  4  R10   R6    0.25      1
#>  5  R6    W2    0.25      2
#>  6  R10   W3    0.25      1
#>  7  R6    W3    0.25      1
#>  8  R7    W3    0.25      1
#>  9  R1    R5  0.2222      2
#> 10  R1    R2     0.2      3
#> # ... 28 more edges
```
