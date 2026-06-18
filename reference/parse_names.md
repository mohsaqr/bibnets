# Reorder and parse author names

Converts author names to `"First Last"` order and breaks each name into
its components. The parser is aware of nobiliary particles (`van`,
`von`, `de`, `del`, `da`, `der`, ...) and generational suffixes (`Jr`,
`Sr`, `II`, `III`, `IV`), and is case-insensitive so it handles bibnets'
uppercased entity labels.

## Usage

``` r
parse_names(
  x,
  format = c("first_last", "last_initials", "last"),
  surname_first = c("auto", "yes", "no")
)
```

## Arguments

- x:

  Character vector of author names, one name per element. `NA` and empty
  strings are preserved.

- format:

  Output style for personal names (group/corporate authors, `NA`, and
  empty strings are returned unchanged in every style). One of:

  `"first_last"`

  :   (default) `"Saqr, Mohammed"` -\> `"Mohammed Saqr"`.

  `"last_initials"`

  :   `"Saqr, Mohammed"` -\> `"Saqr M."`; multiple given names become
      concatenated initials (`"Garcia Marquez G.J."`); any suffix is
      appended (`"Smith J. Jr"`).

  `"last"`

  :   surname only, including any particle (`"van der Berg"`,
      `"de la Cruz"`).

- surname_first:

  How to read **comma-less** strings (strings with a comma are always
  `"Last, First"`). One of:

  `"auto"`

  :   (default) surname-first when the trailing token looks like
      initials — an all-uppercase token of 1-3 letters, the Scopus /
      bibnets signature (`"WANG Y"` -\> `"Y Wang"`'s components).
      Otherwise treated as `"First Last"`. This is the "bibnets takes
      precedence" bias: native bibnets/Scopus labels parse correctly
      with no extra arguments, while ordinary mixed-case `"First Last"`
      input is never misread.

  `"yes"`

  :   force surname-first (`"Wang Yong"` -\> surname `Wang`, given
      `Yong`).

  `"no"`

  :   force given-first (`"First Last"`); comma-less input is returned
      unchanged.

  May also be given as the logical `TRUE` / `FALSE`. Inherently
  ambiguous input (e.g. uppercase `"MOHAMMED LI"`) follows the `auto`
  bias toward the bibnets/Scopus convention; pass `"no"` to override.

## Value

A character vector the same length as `x`, formatted per `format`. The
parsed components are attached as the attribute `"parts"` (independent
of `format`): a data frame with columns `original`, `first`, `last`,
`particle`, `suffix`, and `type` (one of `"person"`, `"organization"`,
`"empty"`, `"missing"`). Casing of the input is preserved; periods are
stripped from parsed initials.

## Details

Three name conventions are recognised:

- `"Last, First"` (a comma) — always parsed as surname-then-given.

- `"SURNAME Initials"` (no comma, e.g. `"WANG Y"`, `"AYALA-ROMERO JA"`)
  — the Scopus / bibnets author-label form.

- `"First Last"` (no comma, e.g. `"Mohammed Saqr"`).

Comma-less strings that look like group or corporate authors (e.g.
`"WHO Collaborating Group"`) are detected and left untouched, as are
`NA` and empty strings.

This is an optional, standalone utility. No reader or network builder in
`bibnets` calls it; entity labels are matched verbatim unless you choose
to apply this function yourself first.

## Input shape

`parse_names()` takes a **flat character vector** (one name per element)
— not a data frame and not a list. bibnets readers store authors as a
**list-column** (each element is a character vector, because a paper has
a variable number of authors), so map the function over it rather than
passing the column directly:

    df$authors <- lapply(df$authors, parse_names, format = "last_initials")

For an ordinary flat character column (or the `from` / `to` columns of a
`bibnets_network`), call it directly: `parse_names(df$col)`.

## Recommended workflow

Normalise names **before** building a network, on the reader's `authors`
list-column. Node identity in bibnets is fixed when the bipartite matrix
is built (labels are upper-cased and matched verbatim), so two spellings
of one author (`"Saqr, Mohammed"` and `"SAQR M"`) only merge into a
single node if they are normalised *before*
[`author_network()`](https://saqr.me/bibnets-pkg/reference/author_network.md)
is called:

    d <- read_biblio("scopus.csv")
    d$authors <- lapply(d$authors, parse_names, format = "last_initials")
    net <- author_network(d, type = "collaboration")

## Applying to an existing edgelist

You *can* call `parse_names()` on the `from` / `to` (or `source` /
`target`) columns of a built network, but it is a per-column,
graph-blind relabelling: edges, pairing, `weight` and `count` are
preserved, **but**

- apply the *same call to both* endpoint columns or the two ends use
  different labels;

- the mapping is many-to-one, so distinct authors can collapse onto one
  label (especially with `"last_initials"`), and bibnets does **not**
  re-aggregate the resulting duplicate edges.

Prefer the pre-build workflow above.

## Limitations

Comma-less names are inherently ambiguous; the `auto` heuristic is
biased toward the bibnets/Scopus surname-first convention and may
misread uppercase `"GIVEN SURNAME"` where the surname is 1-3 letters
(e.g. `"MOHAMMED LI"`). Suffix-first garbage (`"Jr., Sammy Davis"`) is
not specially handled. Use `surname_first` to force interpretation when
you know the source convention.

## See also

[`author_network()`](https://saqr.me/bibnets-pkg/reference/author_network.md)
and
[`read_biblio()`](https://saqr.me/bibnets-pkg/reference/read_biblio.md)
for the upstream stage where normalisation is best applied.

## Examples

``` r
parse_names(c("Saqr, Mohammed", "Lopez-Pernas, Sonsoles"))
#> [1] "Mohammed Saqr"         "Sonsoles Lopez-Pernas"
#> attr(,"parts")
#>                 original    first         last particle suffix   type
#> 1         Saqr, Mohammed Mohammed         Saqr     <NA>   <NA> person
#> 2 Lopez-Pernas, Sonsoles Sonsoles Lopez-Pernas     <NA>   <NA> person

# Alternative output styles
parse_names("Saqr, Mohammed", format = "last_initials")  # "Saqr M."
#> [1] "Saqr M."
#> attr(,"parts")
#>         original    first last particle suffix   type
#> 1 Saqr, Mohammed Mohammed Saqr     <NA>   <NA> person
parse_names("Saqr, Mohammed", format = "last")            # "Saqr"
#> [1] "Saqr"
#> attr(,"parts")
#>         original    first last particle suffix   type
#> 1 Saqr, Mohammed Mohammed Saqr     <NA>   <NA> person
parse_names("van der Berg, Jan", format = "last_initials") # "van der Berg J."
#> [1] "van der Berg J."
#> attr(,"parts")
#>            original first last particle suffix   type
#> 1 van der Berg, Jan   Jan Berg  van der   <NA> person

x <- parse_names("Saqr, M.")
x
#> [1] "M Saqr"
#> attr(,"parts")
#>   original first last particle suffix   type
#> 1 Saqr, M.     M Saqr     <NA>   <NA> person
attr(x, "parts")
#>   original first last particle suffix   type
#> 1 Saqr, M.     M Saqr     <NA>   <NA> person

# Particles and suffixes
parse_names(c("van der Berg, Jan", "Smith, John, Jr.", "de la Cruz, Ana"))
#> [1] "Jan van der Berg" "John Smith Jr"    "Ana de la Cruz"  
#> attr(,"parts")
#>            original first  last particle suffix   type
#> 1 van der Berg, Jan   Jan  Berg  van der   <NA> person
#> 2  Smith, John, Jr.  John Smith     <NA>     Jr person
#> 3   de la Cruz, Ana   Ana  Cruz    de la   <NA> person

# Scopus / bibnets surname-first labels are detected automatically
parse_names(c("WANG Y", "AYALA-ROMERO JA", "VAN DER BERG J"))
#> [1] "Y WANG"          "JA AYALA-ROMERO" "J VAN DER BERG" 
#> attr(,"parts")
#>          original first         last particle suffix   type
#> 1          WANG Y     Y         WANG     <NA>   <NA> person
#> 2 AYALA-ROMERO JA   J A AYALA-ROMERO     <NA>   <NA> person
#> 3  VAN DER BERG J     J         BERG  VAN DER   <NA> person
parse_names("WANG Y", format = "last_initials")          # "WANG Y."
#> [1] "WANG Y."
#> attr(,"parts")
#>   original first last particle suffix   type
#> 1   WANG Y     Y WANG     <NA>   <NA> person

# Override the auto heuristic when you know the convention
parse_names("Wang Yong", surname_first = "yes")          # "Yong Wang"
#> [1] "Yong Wang"
#> attr(,"parts")
#>    original first last particle suffix   type
#> 1 Wang Yong  Yong Wang     <NA>   <NA> person

# Group authors are detected and left unchanged
parse_names("WHO Collaborating Group")
#> [1] "WHO Collaborating Group"
#> attr(,"parts")
#>                  original first last particle suffix         type
#> 1 WHO Collaborating Group  <NA> <NA>     <NA>   <NA> organization

# Recommended workflow: normalise the authors list-column, then build
papers <- data.frame(id = c("P1", "P2", "P3"), stringsAsFactors = FALSE)
papers$authors <- list(
  c("Saqr, Mohammed", "Lopez, Ana"),
  c("SAQR M",         "Lopez, Ana"),
  c("Saqr, Mohammed", "Chen, Wei"))
papers$authors <- lapply(papers$authors, parse_names,
                         format = "last_initials")
net <- author_network(papers, type = "collaboration")
net
#> # bibnets network: author_collaboration | 3 nodes · 2 edges | counting: full 
#>    from      to       weight  count
#> 1  LOPEZ A.  SAQR M.       2      2
#> 2  CHEN W.   SAQR M.       1      1
```
