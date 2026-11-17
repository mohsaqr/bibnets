# Prepare network for cograph::splot()

`to_cograph()` converts a bibnets edge list to a `cograph_network`
object by calling
[`cograph::as_cograph()`](https://sonsoles.me/cograph/reference/as_cograph.html).
Optionally merges node metadata (e.g., from
[`local_citations()`](https://pak.dynasite.org/bibnets-pkg/reference/local_citations.md))
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
  [`local_citations()`](https://pak.dynasite.org/bibnets-pkg/reference/local_citations.md)).
  All other columns are merged into the node table of the
  `cograph_network` and become available as aesthetic mappings.

- directed:

  Logical. Default `FALSE`.

## Value

A `cograph_network` (a list whose `nodes` and `edges` components are
data frames); with `nodes` supplied, its node table gains every non-`id`
column of `nodes`, matched by node label (`NA` where a node has no
metadata row).

## Details

Note: bibnets edge lists (`from`, `to`, `weight`) are accepted directly
by
[`cograph::splot()`](https://sonsoles.me/cograph/reference/splot.html)
without conversion. This function is only needed when you want to attach
node-level metadata.

## Examples

``` r
data(biblio_data)

# Without metadata
to_cograph(author_network(biblio_data, "collaboration"))
#> Cograph network: 6 nodes, 12 edges ( undirected )
#> Source: edgelist 
#> Data: bibnets_network (12 x 4) 
#>   Nodes (6): CHEN W, BROWN M, JONES A, LEE K, DAVIS R, SMITH J
#> Weights: 1 to 3 
#> Layout: none 
#>   Use as.data.frame() for the edge table, as.data.frame(what = "nodes") for the nodes.

# With metadata: local citation scores attached to a document network
to_cograph(document_network(biblio_data, type = "coupling"),
           nodes = local_citations(biblio_data))
#> Cograph network: 10 nodes, 36 edges ( undirected )
#> Source: edgelist 
#> Data: bibnets_network (36 x 4) 
#>   Nodes (10): W4, W1, W6, W2, W3, W5, ... +4 more
#> Weights: 1 to 4 
#> Layout: none 
#>   Use as.data.frame() for the edge table, as.data.frame(what = "nodes") for the nodes.
```
