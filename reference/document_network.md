# Build a document network

Constructs a network between documents (papers) in the dataset.

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
  format = "edgelist"
)
```

## Arguments

- data:

  A data frame with `id` and `references` (list-column).

- type:

  Character. Relationship type:

  `"coupling"`

  :   Bibliographic coupling: documents linked when they share cited
      references.

  `"citation"`

  :   Direct citation: directed edges from citing to cited documents
      (internal citations only).

  `"co_citation"`

  :   Co-citation: documents linked when they are cited together by
      other documents in the dataset.

  `"equivalence"`

  :   Profile similarity of reference vectors.

- counting:

  Character. Counting method. Default `"full"`. Position-dependent
  methods are not applicable to document networks.

- similarity:

  Character. Similarity measure. Default `"none"`.

- threshold:

  Numeric. Minimum edge weight. Default 0.

- min_occur:

  Integer. Minimum reference frequency. Default 1.

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

## Value

Depends on `format`. For `type = "citation"`, edges are directed (from =
citing, to = cited) with `weight` and `count` both 1.

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
