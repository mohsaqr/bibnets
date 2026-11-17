# Extract network backbone using the disparity filter

`backbone()` extracts the backbone of a weighted edge list with the
disparity filter (Serrano et al., 2009). For each edge, it computes an
alpha (p-value) from both endpoints and keeps the edge if it is
statistically significant from at least one endpoint.

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

The input edge data frame (same class and columns) restricted to the
retained edges, with an added numeric `alpha` column (the smaller of the
two endpoint alphas), one row per retained edge, sorted by decreasing
`weight`.

## Details

Under the null model, the total strength \\s_i\\ of node \\i\\ is
distributed uniformly across its \\k_i\\ edges; the probability that a
single edge weight is as large as \\w\_{ij}\\ is then \$\$\alpha\_{ij} =
\left(1 - \frac{w\_{ij}}{s_i}\right)^{k_i - 1}\$\$

An edge is retained if \\\min(\alpha\_{ij}, \alpha\_{ji}) \< \alpha\\.
Nodes with only one edge always have \\\alpha = 0\\ and are always kept.
It returns the retained edges with their `alpha`. To prune by a fixed
weight cut-off or a per-node edge count instead, use
[`prune()`](https://pak.dynasite.org/bibnets-pkg/reference/prune.md); to
keep the edges among the most connected nodes, use
[`filter_top()`](https://pak.dynasite.org/bibnets-pkg/reference/filter_top.md).

## References

Serrano, M. A., Boguna, M., & Vespignani, A. (2009). Extracting the
multiscale backbone of complex weighted networks. *Proceedings of the
National Academy of Sciences*, 106(16), 6483–6488.
[doi:10.1073/pnas.0808904106](https://doi.org/10.1073/pnas.0808904106)

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
