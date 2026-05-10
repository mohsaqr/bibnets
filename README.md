# bibnets

[![R-CMD-check](https://github.com/mohsaqr/bibnets/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/mohsaqr/bibnets/actions/workflows/R-CMD-check.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

`bibnets` is an R package for importing, constructing, and exporting
bibliometric networks. It reads scholarly export formats from Scopus, Web of
Science, OpenAlex, BibTeX, RIS, Lens.org, Dimensions, and Crossref; converts
multi-valued fields such as authors, references, keywords, countries, and
affiliations into sparse incidence matrices; returns edge lists for
co-authorship, co-citation, bibliographic coupling, keyword co-occurrence,
direct citation, historiograph, and custom co-occurrence analyses; and exports
to igraph, tidygraph, cograph, Gephi CSV, GraphML, and sparse matrix formats.

Beyond construction, `bibnets` supports six similarity and dissimilarity
normalizations (association strength, cosine, Jaccard, inclusion, equivalence,
and raw counts); thirteen counting methods including fractional, paper, and
position-aware authorship credit (harmonic, arithmetic, geometric, adaptive
geometric, golden-ratio, first-author, last-author, first-last, custom);
attention-style position weights (lead, last, proximity, circular) for
author, keyword, country, and institution networks; temporal network
construction with fixed, sliding, and cumulative time windows; disparity-filter
backbone extraction for multiscale weighted networks; Garfield-style
historiograph construction over the most locally cited documents; local
citation scoring; and threshold and top-n pruning utilities.

## Main Features

- **8 dedicated network builders plus one generic builder**:
  `author_network()`, `document_network()`, `reference_network()`,
  `keyword_network()`, `source_network()`, `institution_network()`,
  `country_network()`, `historiograph()`, and `conetwork()`.
- **Counting methods** for full, fractional, paper-level, strength, and
  position-aware authorship weighting, including harmonic, arithmetic,
  geometric, adaptive geometric, golden-ratio, first-author, last-author,
  first-last, and custom position-weighted schemes.
- **Attention-style position weights** through `attention = "lead"`, `"last"`,
  `"proximity"`, or `"circular"` for author, keyword, country, and institution
  networks.
- **6 similarity measures**: none, association strength, cosine, Jaccard,
  inclusion, and equivalence.
- **Readers for scholarly exports**: Scopus, Web of Science, OpenAlex nested
  data, OpenAlex flat CSV, BibTeX, RIS, Lens.org, Dimensions, Crossref, and
  generic CSV files.
- **Network reduction and export**: `backbone()`, `prune()`, `filter_top()`,
  `to_gephi()`, `to_graphml()`, `to_igraph()`, `to_tbl_graph()`,
  `to_matrix()`, and `to_cograph()`.
- **Temporal and historical analysis**: `temporal_network()`,
  `local_citations()`, and `historiograph()`.
- **Standard output**: all network builders return a `bibnets_network` edge
  list with `from`, `to`, `weight`, and `count` columns.

## Install

Once accepted on CRAN:

```r
install.packages("bibnets")
```

Development version from GitHub:

```r
# install.packages("remotes")
remotes::install_github("mohsaqr/bibnets")
```

## Quick Start

```r
library(bibnets)

# Read a file or folder. The reader is detected from file content.
data <- read_biblio("export.csv")

# Common networks
authors <- author_network(data, type = "collaboration")
refs    <- reference_network(data, type = "co_citation", min_occur = 2)
docs    <- document_network(data, type = "coupling", similarity = "cosine")
keys    <- keyword_network(data, similarity = "association")

# Inspect the standard edge-list schema
head(authors)
summary(authors)
```

The edge list separates two quantities:

- `count`: the raw binary co-occurrence count for the pair.
- `weight`: the analysis weight after counting and optional similarity
  normalization.

With `similarity = "none"` and `counting = "full"`, `weight` and `count` are
usually the same. Once fractional counting or similarity normalization is used,
they intentionally diverge.

## Reading Data

Use `read_biblio()` when you have a file, a vector of files, or a directory:

```r
data <- read_biblio("scopus_export.csv")
data <- read_biblio(c("wos_1.txt", "wos_2.txt"))
data <- read_biblio("exports/")
```

Use a format-specific reader when the source is already known:

```r
scopus <- read_scopus("scopus.csv")
wos    <- read_wos("savedrecs.txt")
oa     <- read_openalex_csv("openalex_works.csv")
dim    <- read_dimensions("dimensions.csv")
lens   <- read_lens("lens.csv")
```

For custom CSV files, tell `read_biblio()` which columns should be split into
list-columns:

```r
data <- read_biblio(
  "my_data.csv",
  format = "generic",
  id = "paper_id",
  actors = c("Authors", "Keywords"),
  sep = ";"
)
```

All readers try to return the same core columns: `id`, `title`, `year`,
`journal`, `doi`, `cited_by_count`, `abstract`, `type`, `authors`,
`references`, and `keywords`. Source-specific extras such as `countries`,
`affiliations`, `index_keywords`, and `keywords_plus` are preserved when
available.

## Network Builders

### Co-authorship

```r
edges <- author_network(data, type = "collaboration")
```

Two authors are linked when they appear on the same paper. Use `counting` to
change how each paper contributes:

```r
author_network(data, "collaboration", counting = "full")
author_network(data, "collaboration", counting = "fractional")
author_network(data, "collaboration", counting = "harmonic")
author_network(data, "collaboration", counting = "first_last")
```

Use `attention` instead of `counting` when the goal is position-based
weighting independent of the standard counting families. The same option is
available on `keyword_network()`, `country_network()`, and
`institution_network()`:

```r
author_network(data, attention = "lead")       # first author dominant
author_network(data, attention = "last")       # last author dominant
author_network(data, attention = "proximity")  # middle authors weighted most
author_network(data, attention = "circular")   # first and last upweighted
```

`attention` and `counting` are mutually exclusive: when `attention` is
non-NULL, the network is built directly from positional weights and the
`type`/`counting` arguments are ignored.

### Reference Co-citation

```r
refs <- reference_network(data, type = "co_citation", min_occur = 2)
```

Two references are linked when they are cited together by the same paper. This
is a column-mode projection of the `papers x references` matrix.

### Bibliographic Coupling and Direct Citation

```r
coupling <- document_network(data, type = "coupling", similarity = "cosine")
direct   <- document_network(data, type = "citation")
```

Coupling links two papers when they cite the same references. Direct citation
returns directed within-corpus citation edges from citing paper to cited paper.

### Keywords, Sources, Countries, and Institutions

```r
keyword_network(data, field = "keywords")
source_network(data, type = "coupling", min_occur = 2)
country_network(data, type = "collaboration", counting = "fractional")
institution_network(data, type = "collaboration", counting = "fractional")
```

Entity labels are trimmed and uppercased before matrix construction so that
minor casing differences do not create separate nodes.

### Generic Co-networks

`conetwork()` is useful when a dedicated wrapper is not needed:

```r
conetwork(data, "keywords")
conetwork(data, "authors", by = "keywords")
conetwork(data, "journal", by = "references", similarity = "cosine")
```

With one field, entities are linked when they co-occur in the same paper. With
`by`, entities are linked through shared values of another field.

## Counting and Normalization

Counting controls how each paper contributes to edge weights. Similarity
normalization controls how pair-level totals are rescaled after projection.

| Method | Main use | Interpretation |
|---|---|---|
| `"full"` | all networks | Each observed co-occurrence contributes 1. |
| `"fractional"` | all networks | Contribution is scaled by list size so large teams or long reference lists do not dominate. |
| `"paper"` | co-occurrence networks | Each paper contributes a fixed total amount spread across pairs. |
| `"strength"` | coupling networks | Uses reference-frequency weighting and row-list-size normalization for coupling-strength weighting. |
| `"harmonic"` | author collaboration | Authorship credit decreases by harmonic rank and sums to 1 per paper. |
| `"arithmetic"` | author collaboration | Authorship credit decreases linearly by position. |
| `"geometric"` | author collaboration | Authorship credit decays geometrically by position. |
| `"adaptive_geometric"` | author collaboration | Geometric decay adapts to the number of authors. |
| `"golden"` | author collaboration | Geometric decay based on the golden ratio. |
| `"first"` / `"last"` | author collaboration | Only the first or last author receives credit. |
| `"first_last"` | author collaboration | First and last authors are upweighted. |
| `"position_weighted"` | author collaboration | User-supplied position weights. |

Similarity options:

```r
keyword_network(data, similarity = "association")
keyword_network(data, similarity = "cosine")
keyword_network(data, similarity = "jaccard")
keyword_network(data, similarity = "inclusion")
keyword_network(data, similarity = "equivalence")
```

Association strength is often useful for co-occurrence data because it compares
the observed co-occurrence against the product of the two marginal frequencies.
Cosine normalization is often easier to interpret for coupling because it scales
shared references by the geometric mean of the two reference-list lengths.

## Network Reduction

```r
edges <- author_network(data, "collaboration")

strong_edges <- prune(edges, threshold = 3)
local_top    <- prune(edges, top_n = 5)
top_nodes    <- filter_top(edges, n = 50)
backbone_net <- backbone(edges, alpha = 0.05)
```

Use:

- `prune(threshold = x)` for an absolute edge-weight cutoff.
- `prune(top_n = k)` to retain locally strong edges for each node.
- `filter_top(n = k)` to keep only the most connected nodes.
- `backbone(alpha = x)` to apply the disparity filter for multiscale
  weighted networks.

## Temporal Networks and Historiographs

```r
temporal_network(data, keyword_network, window = 3)
temporal_network(data, author_network, "collaboration",
                 window = 2, strategy = "sliding")

lcs <- local_citations(data)
h   <- historiograph(data, n = 30)
```

`temporal_network()` supports fixed, sliding, and cumulative windows. If a
window cannot be built, it warns with the window label instead of silently
dismissing the failure.

`local_citations()` counts within-corpus citations. `historiograph()` then
builds a directed network among the top locally cited documents.

## Export

```r
to_matrix(edges)
to_gephi(edges)
to_graphml(edges, file = "network.graphml")

if (requireNamespace("igraph", quietly = TRUE)) {
  g <- to_igraph(edges)
}
```

Optional converters are guarded by `requireNamespace()`, so packages such as
`igraph`, `tidygraph`, and `cograph` are not required unless their output
formats are requested.

## Vignettes

Two vignettes ship with the package:

- `vignette("bibnets")` — end-to-end workflow: builders, counting and
  similarity options, attention weighting, network reduction, temporal
  windows, historiograph, and exports.
- `vignette("reading-data", package = "bibnets")` — readers for each
  supported source (Scopus, Web of Science, OpenAlex JSON and flat CSV,
  BibTeX, RIS, Lens, Dimensions, Crossref), the standard schema, generic
  CSV input, and multi-source merging.

## License

MIT
