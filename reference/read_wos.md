# Read Web of Science plaintext or tab-delimited export

Parses a Web of Science export file (plaintext or tab-delimited) into a
standardized bibliometric data frame.

## Usage

``` r
read_wos(file, format = "plaintext")
```

## Arguments

- file:

  Path to a WoS export file (.txt).

- format:

  Character. `"plaintext"` (default) for WoS tagged format, or `"tab"`
  for tab-delimited export.

## Value

A data frame in the standard bibnets format: `id`, `title`, `year`,
`journal`, `doi`, `cited_by_count`, `abstract`, `type`, plus
list-columns `authors`, `references`, and `keywords`. WoS-specific
extra: `keywords_plus` (list-column).

## Examples

``` r
if (FALSE) { # \dontrun{
data <- read_wos("savedrecs.txt")
} # }
```
