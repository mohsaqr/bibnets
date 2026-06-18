# Export to GraphML

Writes a bibnets edge list (and optional node attributes) to a GraphML
file using pure base R — no XML package required.

## Usage

``` r
to_graphml(edges, nodes = NULL, file = NULL, directed = FALSE)
```

## Arguments

- edges:

  A data frame with at least `from`, `to`, `weight` columns.

- nodes:

  Optional data frame of node attributes with an `id` column.

- file:

  File path to write. If `NULL` (default), returns the GraphML as a
  character string.

- directed:

  Logical. Default `FALSE`.

## Value

If `file = NULL`: GraphML as a character string. Otherwise writes the
file and returns the path invisibly.

## Examples

``` r
data(biblio_data)
edges <- keyword_network(biblio_data)
xml <- to_graphml(edges)
cat(substr(xml, 1, 300))
#> <?xml version="1.0" encoding="UTF-8"?>
#> <graphml xmlns="http://graphml.graphdrawing.org/graphml"
#>          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
#>          xsi:schemaLocation="http://graphml.graphdrawing.org/graphml
#>          http://graphml.graphdrawing.org/graphml/1.0/graphml.xsd">
#>   <ke
```
