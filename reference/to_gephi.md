# Export to Gephi node and edge tables

Converts a bibnets edge list (and optional node table) to the CSV format
expected by Gephi's Data Laboratory. Column names are remapped to Gephi
conventions (`Source`, `Target`, `Weight`, `Id`, `Label`).

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

If `file = NULL`: a list with `$nodes` and `$edges` data frames. If
`file` is a directory path: writes two CSV files invisibly and returns
the file paths.

## Examples

``` r
data(biblio_data)
edges <- author_network(biblio_data, "collaboration")
gephi <- to_gephi(edges)
head(gephi$edges)
#>    Source  Target Weight       Type count
#> 1  CHEN W   LEE K      3 Undirected     3
#> 2 BROWN M SMITH J      3 Undirected     3
#> 3 BROWN M   LEE K      2 Undirected     2
#> 4 JONES A   LEE K      2 Undirected     2
#> 5 JONES A SMITH J      2 Undirected     2
#> 6   LEE K SMITH J      2 Undirected     2
```
