# Getting Started with bibnets

``` r

library(bibnets)
```

## What bibnets Builds

Bibliometric data usually arrives as a table of papers. Each paper has
fields such as authors, references, keywords, countries, institutions,
source title, and year. Most bibliometric networks are projections of
those fields.

The core idea is simple:

1.  Build a sparse `papers x entities` matrix.
2.  Weight the matrix with a counting method.
3.  Multiply the matrix to obtain entity-entity or paper-paper links.
4.  Return a standard edge list.

Internally, this is the package pipeline:

    build_bipartite()
      -> apply_counting()
      -> multiply_bipartite()
      -> as_bibnets_network()

The exported builders wrap that pipeline for common bibliometric
questions:

| Function | Nodes | Link means |
|----|----|----|
| [`author_network()`](https://saqr.me/bibnets-pkg/reference/author_network.md) | authors | co-authorship, author coupling, or author co-citation |
| [`reference_network()`](https://saqr.me/bibnets-pkg/reference/reference_network.md) | cited references | references are cited together |
| [`document_network()`](https://saqr.me/bibnets-pkg/reference/document_network.md) | documents | shared references, shared citers, or direct citation |
| [`keyword_network()`](https://saqr.me/bibnets-pkg/reference/keyword_network.md) | keywords | keywords appear together in papers |
| [`source_network()`](https://saqr.me/bibnets-pkg/reference/source_network.md) | journals/sources | sources share references or are co-cited |
| [`country_network()`](https://saqr.me/bibnets-pkg/reference/country_network.md) | countries | countries collaborate or share references |
| [`institution_network()`](https://saqr.me/bibnets-pkg/reference/institution_network.md) | institutions | institutions collaborate or share references |
| [`conetwork()`](https://saqr.me/bibnets-pkg/reference/conetwork.md) | any field | entities co-occur or share values of another field |
| [`local_citations()`](https://saqr.me/bibnets-pkg/reference/local_citations.md) | documents | local citation counts inside the corpus |
| [`historiograph()`](https://saqr.me/bibnets-pkg/reference/historiograph.md) | documents | directed citation history among locally cited papers |
| [`temporal_network()`](https://saqr.me/bibnets-pkg/reference/temporal_network.md) | any builder’s nodes | the same network repeated over time windows |

Every network builder returns a `bibnets_network`: a data frame with
columns `from`, `to`, `weight`, and `count`.

`count` is the raw binary co-occurrence. `weight` is the analytical
weight after counting and optional similarity normalization.

## Data Used in This Vignette

The package includes small and medium example datasets:

``` r

data(biblio_data)
data(scopus_quantum_cloud)
data(open_alex_gold_open_access_learning_analytics)

small <- biblio_data
sc <- scopus_quantum_cloud
oa <- open_alex_gold_open_access_learning_analytics

nrow(small)
#> [1] 10
nrow(sc)
#> [1] 499
nrow(oa)
#> [1] 1508
```

`biblio_data` is a tiny synthetic dataset. `scopus_quantum_cloud`
contains 499 Scopus records.
`open_alex_gold_open_access_learning_analytics` contains 1,508 OpenAlex
records with authors, countries, institutions, and primary topics.

## Reading Your Own Data

For files, use
[`read_biblio()`](https://saqr.me/bibnets-pkg/reference/read_biblio.md):

``` r

data <- read_biblio("export.csv")
data <- read_biblio("folder_with_exports/")
data <- read_biblio(c("part_1.csv", "part_2.csv"))
```

[`read_biblio()`](https://saqr.me/bibnets-pkg/reference/read_biblio.md)
detects common formats from file content. You can also call a reader
directly:

``` r

read_scopus("scopus.csv")
read_wos("savedrecs.txt")
read_openalex_csv("openalex_works.csv")
read_dimensions("dimensions.csv")
read_lens("lens.csv")
read_bibtex("library.bib")
read_ris("library.ris")
```

For a custom CSV, specify the identifier and the columns that should be
split into list-columns:

``` r

data <- read_biblio(
  "custom.csv",
  format = "generic",
  id = "paper_id",
  actors = c("Authors", "Keywords"),
  sep = ";"
)
```

Readers return a common schema where possible:

``` r

names(sc)[1:12]
#>  [1] "id"             "title"          "year"           "journal"       
#>  [5] "doi"            "cited_by_count" "abstract"       "type"          
#>  [9] "authors"        "references"     "keywords"       "affiliations"
```

The most important columns for network construction are:

- `id`: the document identifier.
- `authors`: a list-column of author names.
- `references`: a list-column of cited references or cited work IDs.
- `keywords`: a list-column of author/index/topic keywords.
- `year`: the time variable used by
  [`temporal_network()`](https://saqr.me/bibnets-pkg/reference/temporal_network.md).

Source-specific columns such as `countries`, `affiliations`,
`index_keywords`, and `keywords_plus` are preserved when available.

## Author Collaboration

The simplest author network links two authors when they appear on the
same paper:

``` r

authors_full <- author_network(oa, type = "collaboration")
head(authors_full, 5)
#> # bibnets network: author_collaboration | 9 nodes · 5 edges | counting: full 
#>    from                        to                          weight  count
#> 1  MOHAMMED SAQR               SONSOLES LÓPEZ‐PERNAS        19     19
#> 2  CRISTIAN CECHINEL           ROBERTO MUÑOZ                  11     11
#> 3  DRAGAN GAŠEVIĆ            ROBERTO MARTÍNEZ‐MALDONADO      10     10
#> 4  ROBERTO MARTÍNEZ‐MALDONADO  VANESSA ECHEVERRÍA             10     10
#> 5  FERNANDA PIRES              MARCELA PESSOA                   8      8
```

The printed result has the standard schema:

``` r

summary(authors_full)
#> bibnets network
#> ------------------------------
#> Type       : author_collaboration
#> Counting   : full
#> Similarity : none
#> Nodes      : 4029
#> Edges      : 12270
#> Density    : 0.0015
#> Weight     : min 1  median 1  max 19
#> Top nodes  : DRAGAN GAŠEVIĆ(89), ARI KORHONEN(60), CLAUDIA SZABO(60), JUDY SHEARD(60), PAUL DENNY(56)
```

Use `min_occur` to remove very rare authors before projection:

``` r

authors_core <- author_network(oa, "collaboration", min_occur = 2)
nrow(authors_full)
#> [1] 12270
nrow(authors_core)
#> [1] 1362
```

## Counting Methods

Counting determines how much a paper contributes to edge weights.

Full counting gives every observed co-occurrence a weight of 1:

``` r

head(author_network(small, "collaboration", counting = "full"), 5)
#> # bibnets network: author_collaboration | 5 nodes · 5 edges | counting: full 
#>    from     to       weight  count
#> 1  CHEN W   LEE K         3      3
#> 2  BROWN M  SMITH J       3      3
#> 3  BROWN M  LEE K         2      2
#> 4  JONES A  LEE K         2      2
#> 5  JONES A  SMITH J       2      2
```

Fractional counting reduces the influence of long author lists:

``` r

head(author_network(small, "collaboration", counting = "fractional"), 5)
#> # bibnets network: author_collaboration | 5 nodes · 5 edges | counting: fractional 
#>    from     to       weight  count
#> 1  CHEN W   LEE K         2      3
#> 2  BROWN M  SMITH J       2      3
#> 3  JONES A  SMITH J     1.5      2
#> 4  BROWN M  LEE K         1      2
#> 5  JONES A  LEE K         1      2
```

Harmonic counting gives more credit to earlier byline positions while
keeping the paper’s total credit normalized:

``` r

head(author_network(small, "collaboration", counting = "harmonic"), 5)
#> # bibnets network: author_collaboration | 6 nodes · 5 edges | counting: harmonic 
#>    from     to       weight  count
#> 1  BROWN M  SMITH J  0.4702      3
#> 2  JONES A  SMITH J   0.371      2
#> 3  CHEN W   LEE K    0.3214      3
#> 4  CHEN W   DAVIS R  0.2222      1
#> 5  DAVIS R  JONES A  0.2222      1
```

First-last counting is useful only when the field’s authorship
conventions make both first and last positions meaningful:

``` r

head(author_network(small, "collaboration", counting = "first_last"), 5)
#> # bibnets network: author_collaboration | 6 nodes · 5 edges | counting: first_last 
#>    from     to       weight  count
#> 1  BROWN M  SMITH J    0.49      3
#> 2  CHEN W   LEE K      0.41      3
#> 3  JONES A  SMITH J    0.33      2
#> 4  LEE K    SMITH J    0.32      2
#> 5  CHEN W   DAVIS R    0.25      1
```

The correct method depends on the claim being made. Use `full` when the
question is about observed collaboration events. Use `fractional` when
papers with many entities should not dominate. Use position-dependent
methods only when author order is analytically meaningful.

## Attention-Style Position Weights

The `attention` argument applies a smooth position profile. It is
separate from `counting` and is available for author, keyword, country,
and institution networks.

``` r

lead <- author_network(small, attention = "lead")
last <- author_network(small, attention = "last")

head(lead, 5)
#> # bibnets network: author_attention_lead | 5 nodes · 5 edges | counting: lead 
#>    from     to       weight  count
#> 1  BROWN M  SMITH J  0.3896      3
#> 2  JONES A  SMITH J  0.3437      2
#> 3  JONES A  LEE K    0.2041      2
#> 4  CHEN W   LEE K    0.2008      3
#> 5  BROWN M  CHEN W   0.1837      1
head(last, 5)
#> # bibnets network: author_attention_last | 6 nodes · 5 edges | counting: last 
#>    from     to       weight  count
#> 1  CHEN W   LEE K    0.5273      3
#> 2  BROWN M  LEE K    0.2296      2
#> 3  BROWN M  SMITH J  0.2263      3
#> 4  JONES A  LEE K    0.2041      2
#> 5  DAVIS R  SMITH J  0.1837      1
```

The four profiles are:

| `attention`   | Highest weight           |
|---------------|--------------------------|
| `"lead"`      | first position           |
| `"last"`      | last position            |
| `"proximity"` | middle positions         |
| `"circular"`  | first and last positions |

Use attention weighting when the analysis needs a transparent positional
assumption rather than a named bibliometric counting convention.

## Reference Co-citation

Co-citation links two cited references when they are cited together by
at least one paper:

``` r

refs <- reference_network(sc, min_occur = 2)
head(refs, 5)
#> # bibnets network: reference_co_citation | 7 nodes · 5 edges | counting: full 
#>    from                            to                              weight  count
#> 1  HE K., ZHANG X., REN S., SUN …  SIMONYAN K., ZISSERMAN A., VE…      10     10
#> 2  HE K., ZHANG X., REN S., SUN …  SANDLER M., HOWARD A., ZHU M.…       8      8
#> 3  HAN S., MAO H., DALLY W.J., D…  SIMONYAN K., ZISSERMAN A., VE…       8      8
#> 4  HE K., ZHANG X., REN S., SUN …  SIMONYAN K., ZISSERMAN A., VE…       8      8
#> 5  KRIZHEVSKY A., HINTON G., LEA…  SIMONYAN K., ZISSERMAN A., VE…       7      7
```

Co-citation is a column-mode projection of the `papers x references`
matrix. The nodes are references; the links come from papers that cite
both references.

Similarity normalization can reduce the advantage of very frequently
cited references:

``` r

refs_cos <- reference_network(sc, min_occur = 2, similarity = "cosine")
head(refs_cos, 5)
#> # bibnets network: reference_co_citation | 10 nodes · 5 edges | counting: full | similarity: cosine 
#>    from                            to                              weight  count
#> 1  ANDRI R., CAVIGELLI L., ROSSI…  CAPOTONDI A., RUSCI M., FARIS…       1      2
#> 2  BAI Y., ZENG B., LI C., ZHANG…  CASTELLI M., CLEMENTE F.M., P…       1      2
#> 3  CHEN K., ET AL., A DNN OPTIMI…  CHEN Y., ET AL., SAMBA: SINGL…       1      2
#> 4  CHELLAPILLA K., PURI S., SIMA…  CHETLUR S., WOOLLEY C., VANDE…       1      2
#> 5  ATITALLAH B.B., HU Z., BOUCHA…  CHMURSKI M., ZUBERT M., BIERZ…       1      2
```

## Document Coupling and Citation

Bibliographic coupling links two documents when they share cited
references:

``` r

coupled_docs <- document_network(sc, type = "coupling", similarity = "cosine")
head(coupled_docs, 5)
#> # bibnets network: document_coupling | 10 nodes · 5 edges | counting: full | similarity: cosine 
#>    from                to                  weight  count
#> 1  2-s2.0-85169545148  2-s2.0-85150169631  0.4671     12
#> 2  2-s2.0-85203687776  2-s2.0-85200587918  0.3872     10
#> 3  2-s2.0-85131677679  2-s2.0-85172072697  0.3424      7
#> 4  2-s2.0-85187392673  2-s2.0-85124224751   0.269     11
#> 5  2-s2.0-85161914543  2-s2.0-85100337829  0.2443     13
```

Direct citation is different. It keeps direction: `from` is the citing
document and `to` is the cited document, but only when both documents
are inside the same corpus.

``` r

direct_docs <- document_network(sc, type = "citation")
head(direct_docs, 5)
#> # bibnets network: document_citation | 0 nodes · 0 edges | counting: full
```

Many exported datasets cite external works that are not themselves rows
in the dataset. Those external citations support co-citation and
coupling, but they do not become direct-citation edges unless the cited
work is also present in `id`.

## Keyword Co-occurrence

Keyword networks are often the quickest way to inspect a corpus
thematically:

``` r

kw <- keyword_network(sc, min_occur = 2)
head(kw, 5)
#> # bibnets network: keyword_co_occurrence | 5 nodes · 5 edges | counting: full 
#>    from            to              weight  count
#> 1  EDGE COMPUTING  QUANTIZATION        16     16
#> 2  DEEP LEARNING   QUANTIZATION        14     14
#> 3  DEEP LEARNING   EDGE COMPUTING      13     13
#> 4  DEEP LEARNING   FPGA                10     10
#> 5  PRUNING         QUANTIZATION        10     10
```

Entity labels are trimmed and uppercased during matrix construction.
This means that `machine learning`, `Machine Learning`, and
`MACHINE LEARNING` resolve to the same node.

Association strength is commonly useful for co-occurrence maps because
it downweights pairs that are common only because both keywords are
individually frequent:

``` r

kw_assoc <- keyword_network(sc, min_occur = 2, similarity = "association")
head(kw_assoc, 5)
#> # bibnets network: keyword_co_occurrence | 10 nodes · 5 edges | counting: full | similarity: association 
#>    from                     to                          weight  count
#> 1  AIR QUALITY PREDICTION   POST-TRAINING QUANTISATION     0.5      2
#> 2  LFSR SEED                QUANTIZATION (SIGNAL)          0.5      2
#> 3  BOOTH MULTIPLIERS        SHIFT MULTIPLIERS              0.5      2
#> 4  FERROELECTRIC CAPACITOR  SMALL-SIGNAL ANALYSIS          0.5      2
#> 5  K-NEAREST NEIGHBOR       SMART LIGHTING                 0.5      2
```

## Countries, Institutions, and Sources

OpenAlex-style data often contains country and institution list-columns:

``` r

country_edges <- country_network(oa, counting = "fractional")
head(country_edges, 5)
#> # bibnets network: country_collaboration | 8 nodes · 5 edges | counting: fractional 
#>    from  to  weight  count
#> 1  BR    CL     9.7     11
#> 2  CA    US     9.5     13
#> 3  AU    US   8.967     15
#> 4  DE    NL   8.311     10
#> 5  CN    US     8.2     11

inst_edges <- institution_network(oa, counting = "fractional", min_occur = 2)
head(inst_edges, 5)
#> # bibnets network: institution_collaboration | 10 nodes · 5 edges | counting: fractional 
#>    from                            to                             weight  count
#> 1  FINLAND UNIVERSITY              UNIVERSITY OF EASTERN FINLAND   5.778     13
#> 2  MAASTRICHT SCHOOL OF MANAGEME…  MAASTRICHT UNIVERSITY           4.833      6
#> 3  ESCUELA SUPERIOR POLITECNICA …  MONASH UNIVERSITY               4.667      6
#> 4  UNIVERSIDADE FEDERAL DE SANTA…  UNIVERSITY OF VALPARAÍSO       4.417     10
#> 5  KUMAMOTO UNIVERSITY             KYUSHU UNIVERSITY                   4      4
```

Source networks use `journal` as the entity field. Coupling links
sources that cite the same references:

``` r

source_edges <- source_network(sc, type = "coupling", min_occur = 2)
head(source_edges, 5)
#> # bibnets network: source_coupling | 5 nodes · 5 edges | counting: full 
#>    from                            to                              weight  count
#> 1  IEEE TRANSACTIONS ON CIRCUITS…  IEEE TRANSACTIONS ON COMPUTER…      48     48
#> 2  IEEE TRANSACTIONS ON CIRCUITS…  PROCEEDINGS OF THE IEEE             40     40
#> 3  IEEE TRANSACTIONS ON CIRCUITS…  IEEE TRANSACTIONS ON VERY LAR…      39     39
#> 4  IEEE JOURNAL OF SOLID-STATE C…  IEEE TRANSACTIONS ON CIRCUITS…      31     31
#> 5  IEEE TRANSACTIONS ON COMPUTER…  IEEE TRANSACTIONS ON VERY LAR…      29     29
```

For source, country, institution, and author coupling, `min_occur` is
applied to the aggregated entity before building the coupling network.

## Generic Co-networks

Use [`conetwork()`](https://saqr.me/bibnets-pkg/reference/conetwork.md)
when you want a projection not covered by a dedicated helper.

One-field use:

``` r

head(conetwork(sc, "keywords", min_occur = 2), 5)
#> # bibnets network: keywords_co_occurrence | 5 nodes · 5 edges | counting: full 
#>    from            to              weight  count
#> 1  EDGE COMPUTING  QUANTIZATION        16     16
#> 2  DEEP LEARNING   QUANTIZATION        14     14
#> 3  DEEP LEARNING   EDGE COMPUTING      13     13
#> 4  DEEP LEARNING   FPGA                10     10
#> 5  PRUNING         QUANTIZATION        10     10
```

Two-field use:

``` r

head(conetwork(sc, "authors", by = "keywords", min_occur = 2), 5)
#> # bibnets network: authors_by_keywords | 7 nodes · 5 edges | counting: full 
#>    from               to                 weight  count
#> 1  CAI H              LIU B                  36     36
#> 2  WANG Y             YIN S                  30     30
#> 3  AMROUCH H          ANAGNOSTOPOULOS I      24     24
#> 4  AMROUCH H          HENKEL J               24     24
#> 5  ANAGNOSTOPOULOS I  HENKEL J               24     24
```

The second example links authors through shared keywords. This is not a
co-authorship network; it is a thematic-similarity network between
authors.

Delimited character columns are split automatically:

``` r

toy <- data.frame(
  id = c("P1", "P2", "P3"),
  tags = c("methods; networks", "networks; R", "methods; R")
)

conetwork(toy, "tags")
#> # bibnets network: tags_co_occurrence | 3 nodes · 3 edges | counting: full 
#>    from      to        weight  count
#> 1  METHODS   NETWORKS       1      1
#> 2  METHODS   R              1      1
#> 3  NETWORKS  R              1      1
```

## Normalization

The same raw counts can support different similarity scores:

``` r

none <- keyword_network(sc, min_occur = 2, similarity = "none")
cos  <- keyword_network(sc, min_occur = 2, similarity = "cosine")

head(none[, c("from", "to", "weight", "count")], 3)
#> # bibnets network: unknown | 3 nodes · 3 edges 
#>    from            to              weight  count
#> 1  EDGE COMPUTING  QUANTIZATION        16     16
#> 2  DEEP LEARNING   QUANTIZATION        14     14
#> 3  DEEP LEARNING   EDGE COMPUTING      13     13
head(cos[, c("from", "to", "weight", "count")], 3)
#> # bibnets network: unknown | 6 nodes · 3 edges 
#>    from                    to                          weight  count
#> 1  AIR QUALITY PREDICTION  POST-TRAINING QUANTISATION       1      2
#> 2  LFSR SEED               QUANTIZATION (SIGNAL)            1      2
#> 3  BOOTH MULTIPLIERS       SHIFT MULTIPLIERS                1      2
```

Notice that `count` is unchanged. The `weight` column changes because
normalization is applied after raw co-occurrence has been counted.

Available methods are:

``` r

normalize(to_matrix(keyword_network(small)), "cosine")
#> 23 x 23 sparse Matrix of class "dsCMatrix"
#>   [[ suppressing 23 column names 'AUTHOR NAMES', 'BIBLIOMETRICS', 'CITATION NETWORKS' ... ]]
#>                                                                      
#> AUTHOR NAMES            . . . . . . . . . . 1 . 1 . . . . . . . . . .
#> BIBLIOMETRICS           . . . . . . 1 1 . 1 . . . 1 1 1 1 1 1 . 1 . .
#> CITATION NETWORKS       . . . . 1 . . . 1 . . . . . . . . . . . . . .
#> CITATION PATTERNS       . . . . . . . . . . . 1 . . . . . . . . . . 1
#> CLUSTERING              . . 1 . . . . . 1 . . . . . . . . . . . . . .
#> CO-AUTHORSHIP           . . . . . . . . . . . . . . . . 1 . . 1 . . .
#> CO-CITATION             . 1 . . . . . . . . . . . . . . 1 . . . . . .
#> CO-OCCURRENCE           . 1 . . . . . . . . . . . . 1 . . 1 . . . 1 .
#> COMMUNITY DETECTION     . . 1 . 1 . . . . . . . . . . . . . . . . . .
#> COUPLING                . 1 . . . . . . . . . . . . . . . . 1 . . . .
#> DISAMBIGUATION          1 . . . . . . . . . . . 1 . . . . . . . . . .
#> DYNAMICS                . . . 1 . . . . . . . . . . . . . . . . . . 1
#> ENTITY RESOLUTION       1 . . . . . . . . . 1 . . . . . . . . . . . .
#> FRACTIONAL COUNTING     . 1 . . . . . . . . . . . . . . . 1 . . . . .
#> KEYWORD MAPPING         . 1 . . . . . 1 . . . . . . . . . . . . . . .
#> KNOWLEDGE DOMAINS       . 1 . . . . . . . . . . . . . . . . . . 1 . .
#> NETWORK ANALYSIS        . 1 . . . 1 1 . . . . . . . . . . . . 1 . . .
#> NORMALIZATION           . 1 . . . . . 1 . . . . . 1 . . . . . . . 1 .
#> RESEARCH FRONTS         . 1 . . . . . . . 1 . . . . . . . . . . . . .
#> SCHOLARLY COMMUNICATION . . . . . 1 . . . . . . . . . . 1 . . . . . .
#> SCIENCE MAPPING         . 1 . . . . . . . . . . . . . 1 . . . . . . .
#> SIMILARITY MEASURES     . . . . . . . 1 . . . . . . . . . 1 . . . . .
#> TEMPORAL ANALYSIS       . . . 1 . . . . . . . 1 . . . . . . . . . . .
```

In practice:

- Use `similarity = "none"` for raw weighted counts.
- Use `similarity = "cosine"` for interpretable overlap scaled by
  marginal size.
- Use `similarity = "association"` when the goal is to emphasize pairs
  that co-occur more than expected from their individual frequencies.
- Use `jaccard`, `inclusion`, or `equivalence` when those coefficients
  match a downstream method or established reporting convention.

## Reducing Large Networks

Dense co-occurrence networks can be hard to inspect. `bibnets` provides
three different reduction strategies.

``` r

edges <- author_network(oa, "collaboration")

nrow(edges)
#> [1] 12270
nrow(prune(edges, threshold = 2))
#> [1] 779
nrow(prune(edges, top_n = 5))
#> [1] 12188
nrow(filter_top(edges, n = 50))
#> [1] 956
```

`prune(threshold = x)` keeps edges with weight at least `x`.
`prune(top_n = k)` keeps locally strong edges for each endpoint.
`filter_top(n = k)` first selects the most connected nodes, then keeps
edges among them.

[`backbone()`](https://saqr.me/bibnets-pkg/reference/backbone.md)
applies the disparity filter for multiscale weighted networks:

``` r

bb <- backbone(edges, alpha = 0.05)
nrow(bb)
#> [1] 232
head(bb, 5)
#> # bibnets network: author_collaboration | 9 nodes · 5 edges | counting: full 
#>    from                        to                          weight  count
#> 1  MOHAMMED SAQR               SONSOLES LÓPEZ‐PERNAS        19     19
#> 2  CRISTIAN CECHINEL           ROBERTO MUÑOZ                  11     11
#> 3  DRAGAN GAŠEVIĆ            ROBERTO MARTÍNEZ‐MALDONADO      10     10
#> 4  ROBERTO MARTÍNEZ‐MALDONADO  VANESSA ECHEVERRÍA             10     10
#> 5  FERNANDA PIRES              MARCELA PESSOA                   8      8
```

The disparity filter asks whether an edge is unusually strong relative
to at least one endpoint’s local strength distribution. This is
different from a global weight cutoff and can preserve meaningful edges
attached to smaller nodes.

## Temporal Networks

[`temporal_network()`](https://saqr.me/bibnets-pkg/reference/temporal_network.md)
runs any network builder over time windows:

``` r

tn <- temporal_network(oa, author_network, "collaboration", window = 3)
names(tn)
#> [1] "2011-2013" "2014-2016" "2017-2019" "2020-2022" "2023-2025" "2026-2026"
```

Fixed windows are non-overlapping. Sliding windows overlap:

``` r

tn_slide <- temporal_network(
  oa,
  author_network,
  "collaboration",
  window = 3,
  step = 1,
  strategy = "sliding"
)

names(tn_slide)
#>  [1] "2011-2013" "2012-2014" "2013-2015" "2014-2016" "2015-2017" "2016-2018"
#>  [7] "2017-2019" "2018-2020" "2019-2021" "2020-2022" "2021-2023" "2022-2024"
#> [13] "2023-2025" "2024-2026"
```

Cumulative windows always start at the first observed year and grow
forward:

``` r

tn_cum <- temporal_network(
  oa,
  author_network,
  "collaboration",
  window = 3,
  strategy = "cumulative"
)

names(tn_cum)
#>  [1] "2011-2013" "2011-2014" "2011-2015" "2011-2016" "2011-2017" "2011-2018"
#>  [7] "2011-2019" "2011-2020" "2011-2021" "2011-2022" "2011-2023" "2011-2024"
#> [13] "2011-2025" "2011-2026"
```

Each returned edge list has a `window` column. Windows with fewer than
two records or no surviving edges are omitted. If a builder errors
inside a window,
[`temporal_network()`](https://saqr.me/bibnets-pkg/reference/temporal_network.md)
reports a warning with the window label.

## Local Citations and Historiographs

[`local_citations()`](https://saqr.me/bibnets-pkg/reference/local_citations.md)
counts how often each document is cited by other documents inside the
same dataset:

``` r

lcs <- local_citations(sc)
head(lcs, 5)
#>                    id lcs gcs year
#> 1 2-s2.0-105007159281   0   0 2025
#> 2 2-s2.0-105006878874   0   0 2025
#> 3  2-s2.0-85211114952   0   0 2024
#> 4 2-s2.0-105001072133   0   0 2025
#> 5  2-s2.0-85210832535   0   5 2025
#>                                                                                                                                  title
#> 1                                          Quantum Computing in the RAN with Qu4Fec: Closing Gaps Towards Quantum-based FEC Processors
#> 2                                                An FPGA-based bit-level weight sparsity and mixed-bit accelerator for neural networks
#> 3                             FQP: A Fibonacci Quantization Processor with Multiplication-Free Computing and Topological-Order Routing
#> 4                                                   SysCIM: A Heterogeneous Chip Architecture for High-Efficiency CNN Training at Edge
#> 5 Integer-Valued Training and Spike-Driven Inference Spiking Neural Network for High-Performance and Energy-Efficient Object Detection
#>                                                                                                                                 journal
#> 1                                                               Proceedings of the ACM on Measurement and Analysis of Computing Systems
#> 2                                                                                                       Journal of Systems Architecture
#> 3                                                                                            Proceedings - Design Automation Conference
#> 4                                                                      IEEE Transactions on Very Large Scale Integration (VLSI) Systems
#> 5 Lecture Notes in Computer Science (including subseries Lecture Notes in Artificial Intelligence and Lecture Notes in Bioinformatics) 
#>                            doi
#> 1              10.1145/3727128
#> 2 10.1016/j.sysarc.2025.103463
#> 3      10.1145/3649329.3656502
#> 4   10.1109/TVLSI.2025.3526363
#> 5 10.1007/978-3-031-73411-3_15
```

[`historiograph()`](https://saqr.me/bibnets-pkg/reference/historiograph.md)
builds a directed citation graph among the top locally cited documents:

``` r

h <- historiograph(sc, n = 10)
h$nodes
#> [1] id      lcs     gcs     year    title   journal doi    
#> <0 rows> (or 0-length row.names)
head(h$edges, 5)
#> [1] from      to        year_from year_to  
#> <0 rows> (or 0-length row.names)
```

This requires reference strings or IDs to match document IDs in the same
data frame. If the cited works are external to the corpus, local
citation counts will be low or zero even when global citation counts are
high.

## Exporting Results

The default edge list is already useful for many tools:

``` r

edges <- keyword_network(sc, min_occur = 2)
head(edges, 5)
#> # bibnets network: keyword_co_occurrence | 5 nodes · 5 edges | counting: full 
#>    from            to              weight  count
#> 1  EDGE COMPUTING  QUANTIZATION        16     16
#> 2  DEEP LEARNING   QUANTIZATION        14     14
#> 3  DEEP LEARNING   EDGE COMPUTING      13     13
#> 4  DEEP LEARNING   FPGA                10     10
#> 5  PRUNING         QUANTIZATION        10     10
```

Convert to a sparse matrix:

``` r

m <- to_matrix(edges)
m[1:4, 1:4]
#> 4 x 4 sparse Matrix of class "dgCMatrix"
#>                ACCELERATION ACCELERATOR ACCURACY AI ACCELERATOR
#> ACCELERATION              .           .        .              .
#> ACCELERATOR               .           .        .              .
#> ACCURACY                  .           .        .              .
#> AI ACCELERATOR            .           .        .              .
```

Prepare Gephi tables:

``` r

gephi <- to_gephi(edges)
head(gephi$nodes, 3)
#>               Id          Label
#> 1 EDGE COMPUTING EDGE COMPUTING
#> 2  DEEP LEARNING  DEEP LEARNING
#> 3        PRUNING        PRUNING
head(gephi$edges, 3)
#>           Source         Target Weight       Type count
#> 1 EDGE COMPUTING   QUANTIZATION     16 Undirected    16
#> 2  DEEP LEARNING   QUANTIZATION     14 Undirected    14
#> 3  DEEP LEARNING EDGE COMPUTING     13 Undirected    13
```

Write GraphML without adding an XML dependency:

``` r

xml <- to_graphml(edges)
cat(substr(xml, 1, 300))
#> <?xml version="1.0" encoding="UTF-8"?>
#> <graphml xmlns="http://graphml.graphdrawing.org/graphml"
#>          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
#>          xsi:schemaLocation="http://graphml.graphdrawing.org/graphml
#>          http://graphml.graphdrawing.org/graphml/1.0/graphml.xsd">
#>   <ke
```

Optional graph objects are available when the suggested packages are
installed:

``` r

if (requireNamespace("igraph", quietly = TRUE)) {
  g <- to_igraph(edges)
}

if (requireNamespace("tidygraph", quietly = TRUE)) {
  tg <- to_tbl_graph(edges)
}

if (requireNamespace("cograph", quietly = TRUE)) {
  cg <- to_cograph(edges)
}
```

## Interpreting a `bibnets_network`

The object stores construction metadata as attributes:

``` r

edges <- author_network(oa, "collaboration", counting = "harmonic")

attr(edges, "network_type")
#> [1] "author_collaboration"
attr(edges, "counting")
#> [1] "harmonic"
attr(edges, "similarity")
#> [1] "none"
```

The [`print()`](https://rdrr.io/r/base/print.html) method reports the
network type, node count, edge count, counting method, and similarity
method. [`summary()`](https://rdrr.io/r/base/summary.html) reports basic
network and weight summaries:

``` r

summary(edges)
#> bibnets network
#> ------------------------------
#> Type       : author_collaboration
#> Counting   : harmonic
#> Similarity : none
#> Nodes      : 4029
#> Edges      : 12270
#> Density    : 0.0015
#> Weight     : min 1.43e-05  median 0.0106  max 1.41
#> Top nodes  : DRAGAN GAŠEVIĆ(89), ARI KORHONEN(60), CLAUDIA SZABO(60), JUDY SHEARD(60), PAUL DENNY(56)
```

These attributes are meant to make downstream output easier to audit. A
saved edge list should still say how it was produced.
