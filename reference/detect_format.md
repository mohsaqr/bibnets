# Detect bibliometric file format

`detect_format()` detects the format of a bibliometric export from its
first non-empty lines: BibTeX (`@`), RIS (`TY -`), Web of Science
plaintext (`FN` or `PT`), or, from the CSV header, Scopus, Dimensions
(whose header follows an `About the data` line), Lens.org or the flat
OpenAlex CSV.

## Usage

``` r
detect_format(file)
```

## Arguments

- file:

  Path to file.

## Value

Character: format name or `"unknown"`.
