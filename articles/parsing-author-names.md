# Parsing and normalising author names

## What `parse_names()` is

[`parse_names()`](https://saqr.me/bibnets-pkg/reference/parse_names.md)
is an **optional, standalone utility** for cleaning author name strings.
It does two things:

1.  Reorders names to `"First Last"` (or other styles).
2.  Breaks each name into components (`first`, `last`, `particle`,
    `suffix`), returned as the `"parts"` attribute.

It is **not** called by any reader or network builder. bibnets matches
entity labels verbatim; you opt in to normalisation by calling this
function yourself.

``` r

parse_names(c("Saqr, Mohammed", "Lopez-Pernas, Sonsoles"))
#> [1] "Mohammed Saqr"         "Sonsoles Lopez-Pernas"
#> attr(,"parts")
#>                 original    first         last particle suffix   type
#> 1         Saqr, Mohammed Mohammed         Saqr     <NA>   <NA> person
#> 2 Lopez-Pernas, Sonsoles Sonsoles Lopez-Pernas     <NA>   <NA> person
```

## The three name conventions

Bibliometric exports use three incompatible conventions.
[`parse_names()`](https://saqr.me/bibnets-pkg/reference/parse_names.md)
recognises all three; the rule is decided per string.

| Input | Convention | Detected by |
|----|----|----|
| `"Saqr, Mohammed"` | `Last, First` | the comma |
| `"WANG Y"` | `SURNAME Initials` (Scopus/bibnets) | trailing uppercase 1–3 letter token |
| `"Mohammed Saqr"` | `First Last` | default for comma-less, non-initial |

``` r

parse_names(c("Saqr, Mohammed", "WANG Y", "Mohammed Saqr"))
#> [1] "Mohammed Saqr" "Y WANG"        "Mohammed Saqr"
#> attr(,"parts")
#>         original    first last particle suffix   type
#> 1 Saqr, Mohammed Mohammed Saqr     <NA>   <NA> person
#> 2         WANG Y        Y WANG     <NA>   <NA> person
#> 3  Mohammed Saqr Mohammed Saqr     <NA>   <NA> person
```

A comma always means `Last, First`. For comma-less strings the
`surname_first` argument controls interpretation:

- `"auto"` (default) — surname-first **iff** the trailing token looks
  like initials (all-uppercase, 1–3 letters). This is the
  *bibnets-takes-precedence* bias: native bibnets/Scopus labels parse
  correctly with no extra arguments, and ordinary mixed-case
  `"First Last"` is never misread.
- `"yes"` / `TRUE` — force surname-first.
- `"no"` / `FALSE` — force given-first (comma-less returned unchanged).

``` r

parse_names("Wang Yong", surname_first = "yes")   # force surname-first
#> [1] "Yong Wang"
#> attr(,"parts")
#>    original first last particle suffix   type
#> 1 Wang Yong  Yong Wang     <NA>   <NA> person
parse_names("WANG Y",    surname_first = "no")    # force given-first
#> [1] "WANG Y"
#> attr(,"parts")
#>   original first last particle suffix   type
#> 1   WANG Y  WANG    Y     <NA>   <NA> person
```

Particles and suffixes are handled, and detection is case-insensitive so
it works on bibnets’ upper-cased labels:

``` r

parse_names(c("van der Berg, Jan", "Smith, John, Jr.",
              "DE LA CRUZ, ANA", "VAN DER BERG J"))
#> [1] "Jan van der Berg" "John Smith Jr"    "ANA DE LA CRUZ"   "J VAN DER BERG"  
#> attr(,"parts")
#>            original first  last particle suffix   type
#> 1 van der Berg, Jan   Jan  Berg  van der   <NA> person
#> 2  Smith, John, Jr.  John Smith     <NA>     Jr person
#> 3   DE LA CRUZ, ANA   ANA  CRUZ    DE LA   <NA> person
#> 4    VAN DER BERG J     J  BERG  VAN DER   <NA> person
```

Group / corporate authors, `NA`, and empty strings are left untouched:

``` r

parse_names(c("WHO Collaborating Group", NA, ""))
#> [1] "WHO Collaborating Group" NA                       
#> [3] ""                       
#> attr(,"parts")
#>                  original first last particle suffix         type
#> 1 WHO Collaborating Group  <NA> <NA>     <NA>   <NA> organization
#> 2                    <NA>  <NA> <NA>     <NA>   <NA>      missing
#> 3                          <NA> <NA>     <NA>   <NA>        empty
```

## Output styles: `format`

``` r

nm <- c("Saqr, Mohammed", "van der Berg, Jan", "Garcia Marquez, Gabriel Jose")
data.frame(
  first_last    = parse_names(nm),
  last_initials = parse_names(nm, format = "last_initials"),
  last          = parse_names(nm, format = "last")
)
#>                    first_last       last_initials           last
#> 1               Mohammed Saqr             Saqr M.           Saqr
#> 2            Jan van der Berg     van der Berg J.   van der Berg
#> 3 Gabriel Jose Garcia Marquez Garcia Marquez G.J. Garcia Marquez
```

## The `"parts"` attribute

The parsed components ride along on every call, independent of `format`:

``` r

x <- parse_names(c("van der Berg, Jan", "Smith, John, Jr."))
attr(x, "parts")
#>            original first  last particle suffix   type
#> 1 van der Berg, Jan   Jan  Berg  van der   <NA> person
#> 2  Smith, John, Jr.  John Smith     <NA>     Jr person
```

`type` is one of `"person"`, `"organization"`, `"empty"`, `"missing"`.

## Input shape: vector, not data frame

[`parse_names()`](https://saqr.me/bibnets-pkg/reference/parse_names.md)
works on **one flat character vector**. It is not a data-frame function.

bibnets readers store authors as a **list-column**: each paper has a
variable number of authors, so the cell holds a *vector*, not a single
string.

``` r

papers <- data.frame(id = c("P1", "P2", "P3"), stringsAsFactors = FALSE)
papers$authors <- list(
  c("Saqr, Mohammed", "Lopez, Ana"),
  c("SAQR M",         "Lopez, Ana"),
  c("Saqr, Mohammed", "Chen, Wei"))
papers$authors
#> [[1]]
#> [1] "Saqr, Mohammed" "Lopez, Ana"    
#> 
#> [[2]]
#> [1] "SAQR M"     "Lopez, Ana"
#> 
#> [[3]]
#> [1] "Saqr, Mohammed" "Chen, Wei"
```

Map the function over the list-column with
[`lapply()`](https://rdrr.io/r/base/lapply.html):

``` r

papers$authors <- lapply(papers$authors, parse_names,
                          format = "last_initials")
papers$authors
#> [[1]]
#> [1] "Saqr M."  "Lopez A."
#> attr(,"parts")
#>         original    first  last particle suffix   type
#> 1 Saqr, Mohammed Mohammed  Saqr     <NA>   <NA> person
#> 2     Lopez, Ana      Ana Lopez     <NA>   <NA> person
#> 
#> [[2]]
#> [1] "SAQR M."  "Lopez A."
#> attr(,"parts")
#>     original first  last particle suffix   type
#> 1     SAQR M     M  SAQR     <NA>   <NA> person
#> 2 Lopez, Ana   Ana Lopez     <NA>   <NA> person
#> 
#> [[3]]
#> [1] "Saqr M." "Chen W."
#> attr(,"parts")
#>         original    first last particle suffix   type
#> 1 Saqr, Mohammed Mohammed Saqr     <NA>   <NA> person
#> 2      Chen, Wei      Wei Chen     <NA>   <NA> person
```

A flat character column (or a network’s `from` / `to`) is called
directly, no [`lapply()`](https://rdrr.io/r/base/lapply.html):

``` r

parse_names(c("WANG Y", "AYALA-ROMERO JA"))
#> [1] "Y WANG"          "JA AYALA-ROMERO"
#> attr(,"parts")
#>          original first         last particle suffix   type
#> 1          WANG Y     Y         WANG     <NA>   <NA> person
#> 2 AYALA-ROMERO JA   J A AYALA-ROMERO     <NA>   <NA> person
```

## Recommended workflow: normalise *before* building

Node identity in bibnets is fixed when the network is built (labels are
upper-cased and matched verbatim). Two spellings of one author merge
into a single node **only if normalised before**
[`author_network()`](https://saqr.me/bibnets-pkg/reference/author_network.md).

Here `"Saqr, Mohammed"` and `"SAQR M"` are the same person written two
ways. After normalising they both become `SAQR M.`, so the Saqr–Lopez
collaboration is correctly counted as **2**:

``` r

net <- author_network(papers, type = "collaboration")
net
#> # bibnets network: author_collaboration | 3 nodes · 2 edges | counting: full 
#>    from      to       weight  count
#> 1  LOPEZ A.  SAQR M.       2      2
#> 2  CHEN W.   SAQR M.       1      1
```

Had we built the network first and called
[`parse_names()`](https://saqr.me/bibnets-pkg/reference/parse_names.md)
on `from` / `to` afterwards, the two spellings would already have been
counted as two separate nodes — too late to merge by relabelling.

## Applying to an existing edgelist (and its hazards)

The network object is a data frame (`from`, `to`, `weight`, `count`)
with an extra `bibnets_network` class for printing:

``` r

class(net)
#> [1] "bibnets_network" "data.frame"
is.data.frame(net)
#> [1] TRUE
```

You *can* relabel `from` / `to` directly, but
[`parse_names()`](https://saqr.me/bibnets-pkg/reference/parse_names.md)
is graph-blind. Edges, pairing, `weight` and `count` are preserved, but:

- Apply the **same call to both** endpoint columns, or the two ends use
  different labels.
- The mapping is **many-to-one**: distinct authors can collapse onto one
  label (especially `"last_initials"`), and bibnets does **not**
  re-aggregate the resulting duplicate edges.

``` r

net$from <- as.vector(parse_names(net$from, format = "last"))
net$to   <- as.vector(parse_names(net$to,   format = "last"))
net
#> # bibnets network: author_collaboration | 3 nodes · 2 edges | counting: full 
#>    from   to    weight  count
#> 1  LOPEZ  SAQR       2      2
#> 2  CHEN   SAQR       1      1
```

Use [`as.vector()`](https://rdrr.io/r/base/vector.html) when assigning
back so the `"parts"` attribute is not carried on the column.

## Limitations

- Comma-less names are inherently ambiguous. The `auto` heuristic is
  biased toward the bibnets/Scopus surname-first convention and may
  misread uppercase `"GIVEN SURNAME"` when the surname is 1–3 letters
  (e.g. `"MOHAMMED LI"`). Pass `surname_first = "no"` to override.
- Suffix-first malformed input (`"Jr., Sammy Davis"`) is not specially
  handled.
- It normalises *string form*, not identity: it will not disambiguate
  two different people who share a surname and initial.

## Summary

- `parse_names(x)` — vector in, vector out, with a `"parts"` attribute.
- `lapply(df$authors, parse_names)` — for the authors list-column.
- Normalise **before**
  [`author_network()`](https://saqr.me/bibnets-pkg/reference/author_network.md)
  for correct node merging.
- `format` = `"first_last"` / `"last_initials"` / `"last"`;
  `surname_first` = `"auto"` / `"yes"` / `"no"`.
