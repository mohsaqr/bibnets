# Build time-windowed networks

Splits data by time windows and builds a separate network for each
window using any network function.

## Usage

``` r
temporal_network(
  data,
  network_fun,
  ...,
  window = 3,
  step = NULL,
  strategy = "fixed",
  time_col = "year"
)
```

## Arguments

- data:

  A data frame with a numeric time column.

- network_fun:

  Function or character string naming a network function (e.g.,
  `author_network`, `"reference_network"`, `conetwork`).

- ...:

  Additional arguments passed to `network_fun` (e.g., `type`,
  `counting`, `similarity`, `threshold`, `top_n`).

- window:

  Integer. Width of each time window in units of the time column (years,
  months, quarters, etc.). Default 3.

- step:

  Integer or `NULL`. Step size between windows. Default `NULL` (equals
  `window` for fixed, 1 for sliding).

- strategy:

  Character. Time window strategy:

  `"fixed"`

  :   Disjoint non-overlapping windows (default).

  `"sliding"`

  :   Overlapping windows advancing by `step` units.

  `"cumulative"`

  :   Each window starts at the earliest value and extends further.

- time_col:

  Character. Name of the column containing the time variable. Default
  `"year"`. Works with any numeric time unit: years, months, quarters,
  semesters, weeks, etc. (e.g., `"month"`, `"quarter"`, `"time"`).

## Value

A named list of data frames (edge lists). Names are window labels like
`"2018-2020"`.

## Examples

``` r
data(biblio_data)

# Fixed 3-year windows
temporal_network(biblio_data, author_network, "collaboration")
#> $`2018-2020`
#> # bibnets network: author_collaboration | 6 nodes · 10 edges | counting: full 
#>     from     to       weight  count
#>  1  BROWN M  SMITH J       3      3
#>  2  JONES A  LEE K         2      2
#>  3  JONES A  SMITH J       2      2
#>  4  LEE K    SMITH J       2      2
#>  5  BROWN M  DAVIS R       1      1
#>  6  CHEN W   JONES A       1      1
#>  7  DAVIS R  JONES A       1      1
#>  8  BROWN M  LEE K         1      1
#>  9  CHEN W   LEE K         1      1
#> 10  DAVIS R  SMITH J       1      1
#> 
#> $`2021-2022`
#> # bibnets network: author_collaboration | 4 nodes · 4 edges | counting: full 
#>    from     to       weight  count
#> 1  CHEN W   LEE K         2      2
#> 2  BROWN M  CHEN W        1      1
#> 3  CHEN W   DAVIS R       1      1
#> 4  BROWN M  LEE K         1      1
#> 

# Sliding window
temporal_network(biblio_data, author_network, "collaboration",
                 window = 2, strategy = "sliding")
#> $`2018-2019`
#> # bibnets network: author_collaboration | 5 nodes · 7 edges | counting: full 
#>    from     to       weight  count
#> 1  BROWN M  SMITH J       3      3
#> 2  JONES A  SMITH J       2      2
#> 3  LEE K    SMITH J       2      2
#> 4  BROWN M  DAVIS R       1      1
#> 5  BROWN M  LEE K         1      1
#> 6  JONES A  LEE K         1      1
#> 7  DAVIS R  SMITH J       1      1
#> 
#> $`2019-2020`
#> # bibnets network: author_collaboration | 6 nodes · 8 edges | counting: full 
#>    from     to       weight  count
#> 1  BROWN M  SMITH J       2      2
#> 2  BROWN M  DAVIS R       1      1
#> 3  CHEN W   JONES A       1      1
#> 4  DAVIS R  JONES A       1      1
#> 5  CHEN W   LEE K         1      1
#> 6  JONES A  LEE K         1      1
#> 7  DAVIS R  SMITH J       1      1
#> 8  JONES A  SMITH J       1      1
#> 
#> $`2020-2021`
#> # bibnets network: author_collaboration | 5 nodes · 6 edges | counting: full 
#>    from     to       weight  count
#> 1  CHEN W   LEE K         3      3
#> 2  BROWN M  CHEN W        1      1
#> 3  CHEN W   JONES A       1      1
#> 4  DAVIS R  JONES A       1      1
#> 5  BROWN M  LEE K         1      1
#> 6  JONES A  LEE K         1      1
#> 
#> $`2021-2022`
#> # bibnets network: author_collaboration | 4 nodes · 4 edges | counting: full 
#>    from     to       weight  count
#> 1  CHEN W   LEE K         2      2
#> 2  BROWN M  CHEN W        1      1
#> 3  CHEN W   DAVIS R       1      1
#> 4  BROWN M  LEE K         1      1
#> 

# Cumulative
temporal_network(biblio_data, reference_network,
                 threshold = 0, strategy = "cumulative", window = 2)
#> $`2018-2019`
#> # bibnets network: reference_co_citation | 8 nodes · 19 edges | counting: full 
#>     from  to   weight  count
#>  1  R1    R2        3      3
#>  2  R4    W1        3      3
#>  3  R3    R4        2      2
#>  4  R1    R5        2      2
#>  5  R2    R5        2      2
#>  6  R3    W1        2      2
#>  7  R3    W2        2      2
#>  8  R4    W2        2      2
#>  9  W1    W2        2      2
#> 10  R1    R10       1      1
#> # ... 9 more edges
#> 
#> $`2018-2020`
#> # bibnets network: reference_co_citation | 9 nodes · 23 edges | counting: full 
#>     from  to  weight  count
#>  1  R3    W1       4      4
#>  2  R1    R2       3      3
#>  3  R2    R5       3      3
#>  4  R4    W1       3      3
#>  5  R3    W2       3      3
#>  6  W1    W2       3      3
#>  7  R2    R3       2      2
#>  8  R3    R4       2      2
#>  9  R1    R5       2      2
#> 10  R3    R5       2      2
#> # ... 13 more edges
#> 
#> $`2018-2021`
#> # bibnets network: reference_co_citation | 11 nodes · 33 edges | counting: full 
#>     from  to  weight  count
#>  1  R3    W1       4      4
#>  2  R1    R2       3      3
#>  3  R2    R5       3      3
#>  4  R2    W1       3      3
#>  5  R4    W1       3      3
#>  6  R3    W2       3      3
#>  7  W1    W2       3      3
#>  8  R2    R3       2      2
#>  9  R3    R4       2      2
#> 10  R1    R5       2      2
#> # ... 23 more edges
#> 
#> $`2018-2022`
#> # bibnets network: reference_co_citation | 13 nodes · 38 edges | counting: full 
#>     from  to  weight  count
#>  1  R3    W1       4      4
#>  2  R1    R2       3      3
#>  3  R2    R5       3      3
#>  4  R2    W1       3      3
#>  5  R4    W1       3      3
#>  6  R3    W2       3      3
#>  7  W1    W2       3      3
#>  8  R2    R3       2      2
#>  9  R3    R4       2      2
#> 10  R1    R5       2      2
#> # ... 28 more edges
#> 

# With string name
temporal_network(biblio_data, "keyword_network", window = 3)
#> $`2018-2020`
#> # bibnets network: keyword_co_occurrence | 15 nodes · 21 edges | counting: full 
#>     from            to                   weight  count
#>  1  BIBLIOMETRICS   CO-CITATION               1      1
#>  2  BIBLIOMETRICS   CO-OCCURRENCE             1      1
#>  3  BIBLIOMETRICS   COUPLING                  1      1
#>  4  AUTHOR NAMES    DISAMBIGUATION            1      1
#>  5  AUTHOR NAMES    ENTITY RESOLUTION         1      1
#>  6  DISAMBIGUATION  ENTITY RESOLUTION         1      1
#>  7  BIBLIOMETRICS   FRACTIONAL COUNTING       1      1
#>  8  BIBLIOMETRICS   KEYWORD MAPPING           1      1
#>  9  CO-OCCURRENCE   KEYWORD MAPPING           1      1
#> 10  BIBLIOMETRICS   NETWORK ANALYSIS          1      1
#> # ... 11 more edges
#> 
#> $`2021-2022`
#> # bibnets network: keyword_co_occurrence | 9 nodes · 9 edges | counting: full 
#>    from               to                   weight  count
#> 1  CITATION NETWORKS  CLUSTERING                1      1
#> 2  CITATION NETWORKS  COMMUNITY DETECTION       1      1
#> 3  CLUSTERING         COMMUNITY DETECTION       1      1
#> 4  CITATION PATTERNS  DYNAMICS                  1      1
#> 5  BIBLIOMETRICS      KNOWLEDGE DOMAINS         1      1
#> 6  BIBLIOMETRICS      SCIENCE MAPPING           1      1
#> 7  KNOWLEDGE DOMAINS  SCIENCE MAPPING           1      1
#> 8  CITATION PATTERNS  TEMPORAL ANALYSIS         1      1
#> 9  DYNAMICS           TEMPORAL ANALYSIS         1      1
#> 
```
