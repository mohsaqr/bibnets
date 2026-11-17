# bibnets: Importing, Constructing, and Exporting Bibliometric Networks

`bibnets` builds bibliometric networks from the exports of scholarly
databases. A bibliometric network links authors, documents, references,
keywords, journals, institutions or countries through the records they
share: co-authorship links authors who write together, co-citation links
references cited together (Small, 1973), and bibliographic coupling
links documents that cite the same work (Kessler, 1963). These networks
show how a research field is organized: its collaborating groups, its
intellectual base and its topics. The weight of a link can be normalized
for how active each entity is
([`normalize()`](https://pak.dynasite.org/bibnets-pkg/reference/normalize.md)),
and authorship credit can be counted in full, fractionally or by author
position (the `counting` argument of the builders). Networks can be
built for time windows
([`temporal_network()`](https://pak.dynasite.org/bibnets-pkg/reference/temporal_network.md)),
reduced to their backbone with the disparity filter
([`backbone()`](https://pak.dynasite.org/bibnets-pkg/reference/backbone.md);
Serrano et al., 2009), and traced over time with a historiograph of the
most locally cited documents
([`historiograph()`](https://pak.dynasite.org/bibnets-pkg/reference/historiograph.md);
Garfield, 2004).

Records are read with
[`read_biblio()`](https://pak.dynasite.org/bibnets-pkg/reference/read_biblio.md)
from Scopus, Web of Science, OpenAlex, BibTeX, RIS, Lens.org, Dimensions
and Crossref exports, or taken from any data frame with its own column
names and separators. The builders
([`author_network()`](https://pak.dynasite.org/bibnets-pkg/reference/author_network.md),
[`document_network()`](https://pak.dynasite.org/bibnets-pkg/reference/document_network.md),
[`reference_network()`](https://pak.dynasite.org/bibnets-pkg/reference/reference_network.md),
[`keyword_network()`](https://pak.dynasite.org/bibnets-pkg/reference/keyword_network.md),
[`source_network()`](https://pak.dynasite.org/bibnets-pkg/reference/source_network.md),
[`institution_network()`](https://pak.dynasite.org/bibnets-pkg/reference/institution_network.md),
[`country_network()`](https://pak.dynasite.org/bibnets-pkg/reference/country_network.md)
and the generic
[`conetwork()`](https://pak.dynasite.org/bibnets-pkg/reference/conetwork.md))
return an edge list with `from`, `to`, `weight` and `count` columns,
which
[`to_igraph()`](https://pak.dynasite.org/bibnets-pkg/reference/to_igraph.md),
[`to_tbl_graph()`](https://pak.dynasite.org/bibnets-pkg/reference/to_tbl_graph.md),
[`to_cograph()`](https://pak.dynasite.org/bibnets-pkg/reference/to_cograph.md),
[`to_gephi()`](https://pak.dynasite.org/bibnets-pkg/reference/to_gephi.md),
[`to_graphml()`](https://pak.dynasite.org/bibnets-pkg/reference/to_graphml.md)
and
[`to_matrix()`](https://pak.dynasite.org/bibnets-pkg/reference/to_matrix.md)
export.

## References

Garfield, E. (2004). Historiographic mapping of knowledge domains
literature. *Journal of Information Science*, 30(2), 119–145.
[doi:10.1177/0165551504042802](https://doi.org/10.1177/0165551504042802)

Kessler, M. M. (1963). Bibliographic coupling between scientific papers.
*American Documentation*, 14(1), 10–25.
[doi:10.1002/asi.5090140103](https://doi.org/10.1002/asi.5090140103)

Serrano, M. A., Boguna, M., & Vespignani, A. (2009). Extracting the
multiscale backbone of complex weighted networks. *Proceedings of the
National Academy of Sciences*, 106(16), 6483–6488.

Small, H. (1973). Co-citation in the scientific literature: A new
measure of the relationship between two documents. *Journal of the
American Society for Information Science*, 24(4), 265–269.

## See also

Useful links:

- <https://github.com/mohsaqr/bibnets>

- Report bugs at <https://github.com/mohsaqr/bibnets/issues>

## Author

**Maintainer**: Mohammed Saqr <saqr@saqr.me>
([ORCID](https://orcid.org/0000-0001-5881-3109)) \[copyright holder\]

Authors:

- Mohammed Saqr <saqr@saqr.me>
  ([ORCID](https://orcid.org/0000-0001-5881-3109)) \[copyright holder\]

- Sonsoles López-Pernas ([ORCID](https://orcid.org/0000-0002-9621-1392))
