# Resolve file paths from a file, vector of files, or directory

`resolve_paths()` expands `path` into a character vector of files: a
directory contributes its `.csv`, `.txt`, `.bib`, `.ris`, `.xls` and
`.xlsx` files, an existing file is kept, and a path that does not exist
is dropped.

## Usage

``` r
resolve_paths(path)
```
