# Build a document network

`document_network()` builds a network between documents (papers) in the
dataset. By default two documents are linked by bibliographic coupling,
when they share cited references (Kessler, 1963); the other types are
direct citation, co-citation of the cited items (Small, 1973) and the
cosine similarity of the documents' reference vectors.

## Usage

``` r
document_network(
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
  `id`); direct citation needs the references to use the same
  identifiers.

- type:

  Character. Relationship type:

  `"coupling"`

  :   Bibliographic coupling: documents linked when they share cited
      references.

  `"citation"`

  :   Direct citation: directed edges from citing to cited documents
      (internal citations only). `counting`, `similarity`, `threshold`
      and `min_occur` are not applied; `top_n` keeps the documents with
      the most citation edges.

  `"co_citation"`

  :   Co-citation of the cited items: the nodes are the values of the
      references column (as in
      [`reference_network()`](https://pak.dynasite.org/bibnets-pkg/reference/reference_network.md)),
      linked when the same document cites both. They are documents of
      the dataset only when the references are document identifiers.

  `"equivalence"`

  :   Cosine similarity of the documents' reference vectors; `counting`
      and `similarity` are ignored.

- counting:

  Character. Counting method: `"full"` (default), `"fractional"`,
  `"paper"` or `"strength"`. Position-dependent methods are not
  applicable to document networks.

- similarity:

  Character. Similarity measure. Default `"none"`.

- threshold:

  Numeric. Minimum edge weight; edges with `weight < threshold` are
  dropped. Default 0 (keep all).

- min_occur:

  Integer. Minimum reference frequency. Default 1.

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
`bibnets_network` data frame with one row per edge, columns `from`,
`to`, `weight` and `count`, and attributes `network_type`, `counting`
and `similarity`; see
[`author_network()`](https://pak.dynasite.org/bibnets-pkg/reference/author_network.md)
for the other formats. For `type = "citation"` the edges are directed
(`from` = citing, `to` = cited) with `weight` and `count` both 1, in
data order; the other types are undirected and sorted by decreasing
`weight`.

## Details

The documents and their references form a two-mode matrix, projected
onto the documents for coupling and onto the cited items for
co-citation; `counting` and `similarity` weight the edges and
`threshold`, `min_occur` and `top_n` prune them. It returns a
`bibnets_network` edge list by default, directed for
`type = "citation"`. For a co-citation network of the references
themselves see
[`reference_network()`](https://pak.dynasite.org/bibnets-pkg/reference/reference_network.md);
for local citation counts and a chronological citation network see
[`local_citations()`](https://pak.dynasite.org/bibnets-pkg/reference/local_citations.md)
and
[`historiograph()`](https://pak.dynasite.org/bibnets-pkg/reference/historiograph.md).

## References

Kessler, M. M. (1963). Bibliographic coupling between scientific papers.
*American Documentation*, 14(1), 10–25.
[doi:10.1002/asi.5090140103](https://doi.org/10.1002/asi.5090140103)

Small, H. (1973). Co-citation in the scientific literature: A new
measure of the relationship between two documents. *Journal of the
American Society for Information Science*, 24(4), 265–269.
[doi:10.1002/asi.4630240406](https://doi.org/10.1002/asi.4630240406)

## Examples

``` r
data(biblio_data)
document_network(biblio_data, "coupling")
#> # bibnets network: document_coupling | 10 nodes · 36 edges | counting: full 
#>     from  to  weight  count
#>  1  W4    W9       4      4
#>  2  W1    W3       3      3
#>  3  W4    W6       3      3
#>  4  W1    W7       3      3
#>  5  W6    W9       3      3
#>  6  W1    W2       2      2
#>  7  W2    W3       2      2
#>  8  W2    W4       2      2
#>  9  W3    W4       2      2
#> 10  W2    W5       2      2
#> # ... 26 more edges
document_network(biblio_data, "coupling", counting = "strength")
#> # bibnets network: document_coupling | 10 nodes · 36 edges | counting: strength 
#>     from  to   weight  count
#>  1  W4    W9   0.1981      4
#>  2  W1    W7   0.1938      3
#>  3  W1    W3   0.1619      3
#>  4  W6    W10  0.1579      2
#>  5  W4    W6   0.1229      3
#>  6  W5    W8   0.1229      2
#>  7  W6    W9   0.1229      3
#>  8  W1    W2   0.1186      2
#>  9  W2    W7   0.1186      2
#> 10  W3    W7   0.1186      2
#> # ... 26 more edges
```
