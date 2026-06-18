# Prepare network for cograph::splot()

Converts a bibnets edge list to a `cograph_network` object by calling
[`cograph::as_cograph()`](https://sonsoles.me/cograph/reference/as_cograph.html).
Optionally merges node metadata (e.g., from
[`local_citations()`](https://saqr.me/bibnets-pkg/reference/local_citations.md))
into the network's node table so attributes like `lcs` or `year` can be
used directly in `splot()` aesthetic parameters (e.g.,
`node_size = "lcs"`).

## Usage

``` r
to_cograph(edges, nodes = NULL, directed = FALSE)
```

## Arguments

- edges:

  A data frame with at least `from`, `to`, `weight` columns.

- nodes:

  Optional data frame of node attributes with an `id` column (e.g.,
  output of
  [`local_citations()`](https://saqr.me/bibnets-pkg/reference/local_citations.md)).
  All columns are merged into the `cograph_network$nodes` table and
  become available as aesthetic mappings.

- directed:

  Logical. Default `FALSE`.

## Value

A `cograph_network` object (S3 list with `$nodes` and `$edges`).

## Details

Note: bibnets edge lists (`from`, `to`, `weight`) are accepted directly
by
[`cograph::splot()`](https://sonsoles.me/cograph/reference/splot.html)
without conversion. This function is only needed when you want to attach
node-level metadata.

## Examples

``` r
data(biblio_data)

# Without metadata: splot() accepts bibnets edges directly
edges <- author_network(biblio_data, "collaboration")

# With metadata: document network + local citation scores as node size
edges <- document_network(biblio_data, type = "coupling")
nodes <- local_citations(biblio_data)   # keyed by document id
net   <- to_cograph(edges, nodes = nodes)
```
