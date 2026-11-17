# Normalize a co-occurrence matrix

`normalize()` normalizes a square co-occurrence matrix by a similarity
measure: association strength, cosine, Jaccard, inclusion or equivalence
(van Eck & Waltman, 2009). The diagonal of the input matrix is used as
the total occurrence count \\w_i\\ of each item (a zero diagonal entry
is treated as 1). Matrices with 500 or more rows are processed in sparse
triplet form, so no dense outer product is allocated. Every network
builder calls this through its `similarity` argument; call it directly
to normalize a matrix you built yourself.

## Usage

``` r
normalize(A, method = "none")
```

## Arguments

- A:

  A square symmetric matrix (dense or sparse) representing co-occurrence
  counts.

- method:

  Character. Normalization method:

  `"none"`

  :   No normalization. Returns raw co-occurrence counts.

  `"association"`

  :   Association strength (probabilistic affinity index). \\s\_{ij} =
      c\_{ij} / (w_i \cdot w_j)\\. Often recommended as the best
      normalization for co-occurrence data.

  `"cosine"`

  :   Salton's cosine. \\s\_{ij} = c\_{ij} / \sqrt{w_i \cdot w_j}\\.

  `"jaccard"`

  :   Jaccard index. \\s\_{ij} = c\_{ij} / (w_i + w_j - c\_{ij})\\.

  `"inclusion"`

  :   Inclusion index (Simpson coefficient). \\s\_{ij} = c\_{ij} /
      \min(w_i, w_j)\\.

  `"equivalence"`

  :   Equivalence index (Salton's cosine squared). \\s\_{ij} = c\_{ij}^2
      / (w_i \cdot w_j)\\.

## Value

For `method = "none"`, `A` unchanged. Otherwise a sparse `Matrix` of the
same dimensions and dimnames holding \\s\_{ij}\\, with a zero diagonal.

## References

van Eck, N. J., & Waltman, L. (2009). How to normalize cooccurrence
data? An analysis of some well-known similarity measures. *Journal of
the American Society for Information Science and Technology*, 60(8),
1635–1651. [doi:10.1002/asi.21075](https://doi.org/10.1002/asi.21075)

## Examples

``` r
# Create a small co-occurrence matrix
A <- matrix(c(10, 3, 1, 3, 8, 2, 1, 2, 5), nrow = 3,
            dimnames = list(c("a", "b", "c"), c("a", "b", "c")))
normalize(A, "association")
#> 3 x 3 sparse Matrix of class "dsCMatrix"
#>        a      b    c
#> a .      0.0375 0.02
#> b 0.0375 .      0.05
#> c 0.0200 0.0500 .   
normalize(A, "cosine")
#> 3 x 3 sparse Matrix of class "dsCMatrix"
#>           a         b         c
#> a .         0.3354102 0.1414214
#> b 0.3354102 .         0.3162278
#> c 0.1414214 0.3162278 .        
normalize(A, "jaccard")
#> 3 x 3 sparse Matrix of class "dsCMatrix"
#>            a         b          c
#> a .          0.2000000 0.07142857
#> b 0.20000000 .         0.18181818
#> c 0.07142857 0.1818182 .         
```
