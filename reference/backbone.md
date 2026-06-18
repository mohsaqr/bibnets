# Extract network backbone using the disparity filter

Applies the disparity filter to a weighted edge list. For each edge, it
computes an alpha (p-value) from both endpoints and keeps the edge if it
is statistically significant from at least one endpoint.

## Usage

``` r
backbone(edges, alpha = 0.05)
```

## Arguments

- edges:

  A data frame with at least columns `from`, `to`, and `weight`. Must be
  an undirected edge list (each pair appears once).

- alpha:

  Numeric. Significance threshold in (0, 1). Default `0.05`.

## Value

The filtered edge data frame with an added `alpha` column (the minimum
alpha from the two endpoints).

## Details

The null model asks: given that node \\i\\ has total strength \\s_i\\
distributed uniformly across \\k_i\\ edges, what is the probability that
a single edge weight is as large as \\w\_{ij}\\? The answer is
\$\$\alpha\_{ij} = \left(1 - \frac{w\_{ij}}{s_i}\right)^{k_i - 1}\$\$

An edge is retained if \\\min(\alpha\_{ij}, \alpha\_{ji}) \< \alpha\\.
Nodes with only one edge always have \\\alpha = 0\\ and are always kept.

## Examples

``` r
edges <- data.frame(
  from   = c("A", "A", "A", "B", "C"),
  to     = c("B", "C", "D", "C", "D"),
  weight = c(10,   1,   1,   8,   1)
)
backbone(edges, alpha = 0.05)
#>   from to weight      alpha
#> 1    A  B     10 0.02777778
#> 2    B  C      8 0.04000000
```
