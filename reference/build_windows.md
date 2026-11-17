# Build time window definitions

`build_windows()` computes the time windows used by
[`temporal_network()`](https://pak.dynasite.org/bibnets-pkg/reference/temporal_network.md)
for the fixed, sliding or cumulative `strategy`. It returns a data frame
with one row per window and columns `start`, `end` and `label`
(`"start-end"`).

## Usage

``` r
build_windows(min_time, max_time, window, step, strategy)
```
