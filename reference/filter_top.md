# Filter edges to top-n nodes

Keeps only edges between the most frequent nodes. Node frequency is
determined by how many edges each node participates in.

## Usage

``` r
filter_top(edges, n)
```

## Arguments

- edges:

  A data frame with at least `from`, `to`, `weight` columns.

- n:

  Integer. Number of top nodes to keep.

## Value

A filtered data frame with edges among the top `n` nodes.

## Examples

``` r
data(biblio_data)
edges <- author_network(biblio_data, "collaboration")

# Keep only edges among the top 3 most connected authors
filter_top(edges, 3)
#> # bibnets network: author_collaboration | 3 nodes · 3 edges | counting: full 
#>    from     to       weight  count
#> 1  BROWN M  CHEN W        1      1
#> 2  BROWN M  DAVIS R       1      1
#> 3  CHEN W   DAVIS R       1      1
```
