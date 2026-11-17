# Read a single bibliometric file

`read_single_biblio()` reads one file for
[`read_biblio()`](https://pak.dynasite.org/bibnets-pkg/reference/read_biblio.md).
It calls
[`read_generic()`](https://pak.dynasite.org/bibnets-pkg/reference/read_generic.md)
for `format = "generic"`; otherwise it detects the format with
[`detect_format()`](https://pak.dynasite.org/bibnets-pkg/reference/detect_format.md)
when `format = "auto"` and dispatches to the matching format-specific
reader, with an error that lists the supported formats when none
matches.

## Usage

``` r
read_single_biblio(
  file,
  format,
  id,
  sep,
  authors = NULL,
  keywords = NULL,
  references = NULL,
  countries = NULL,
  affiliations = NULL,
  journal = NULL,
  list_cols = NULL,
  ...
)
```
