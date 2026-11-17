# Export to Gephi node and edge tables

`to_gephi()` converts a bibnets edge list (and optional node table) to
the CSV format expected by Gephi's Data Laboratory. Column names are
remapped to Gephi conventions (`Source`, `Target`, `Weight`, `Id`,
`Label`).

## Usage

``` r
to_gephi(edges, nodes = NULL, file = NULL, directed = FALSE)
```

## Arguments

- edges:

  A data frame with at least `from`, `to`, `weight` columns.

- nodes:

  Optional data frame of node attributes. Must contain an `id` column.
  All other columns are included as Gephi node attributes.

- file:

  Optional directory path. If supplied, writes `nodes.csv` and
  `edges.csv` into that directory. If `NULL` (default), returns a list.

- directed:

  Logical. Sets the `Type` column. Default `FALSE`.

## Value

If `file = NULL`, a list of two plain data frames: `nodes` (one row per
node, columns `Id`, `Label`, then any extra node attributes) and `edges`
(one row per edge, columns `Source`, `Target`, `Weight`, `Type`, then
the remaining edge columns such as `count`). If `file` is an existing
directory, writes `nodes.csv` and `edges.csv` there, reports the paths
with a message, and returns the two paths invisibly.

## Examples

``` r
data(biblio_data)
edges <- author_network(biblio_data, "collaboration")
to_gephi(head(edges, 3))
#> $nodes
#>        Id   Label
#> 1  CHEN W  CHEN W
#> 2 BROWN M BROWN M
#> 3   LEE K   LEE K
#> 4 SMITH J SMITH J
#> 
#> $edges
#>    Source  Target Weight       Type count
#> 1  CHEN W   LEE K      3 Undirected     3
#> 2 BROWN M SMITH J      3 Undirected     3
#> 3 BROWN M   LEE K      2 Undirected     2
#> 

# Write nodes.csv and edges.csv into a directory
out_dir <- tempfile("gephi")
dir.create(out_dir)
to_gephi(edges, file = out_dir)
#> Written: /tmp/Rtmpac1oe5/gephi1a21897ecbc/nodes.csv
#>         /tmp/Rtmpac1oe5/gephi1a21897ecbc/edges.csv
unlink(out_dir, recursive = TRUE)
```
