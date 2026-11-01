#' Example bibliometric dataset
#'
#' A small synthetic dataset of 10 scholarly papers with overlapping authors,
#' references, and keywords. Designed for testing and demonstrating all
#' network construction functions in bibnets.
#'
#' @format A data frame with 10 rows and 9 columns:
#' \describe{
#'   \item{id}{Unique document identifier (W1--W10).}
#'   \item{title}{Document title.}
#'   \item{year}{Publication year (2018--2022).}
#'   \item{journal}{Source journal (Scientometrics, Journal of Informetrics,
#'     JASIST, Quantitative Science Studies).}
#'   \item{doi}{DOI string.}
#'   \item{cited_by_count}{Times cited.}
#'   \item{authors}{List-column of author name strings (6 unique authors).}
#'   \item{references}{List-column of cited reference IDs (13 unique
#'     values): external references R1--R10 (R8 unused) and the in-corpus
#'     document IDs W1, W2, W3 and W5, which give the direct-citation,
#'     local-citation and historiograph examples something to find. Each
#'     paper cites exactly 4 references.}
#'   \item{keywords}{List-column of keyword strings (23 unique keywords).
#'     Each paper has 3 keywords.}
#' }
#'
#' @examples
#' data(biblio_data)
#' reference_network(biblio_data)
#' document_network(biblio_data, "coupling")
#' author_network(biblio_data, "collaboration")
"biblio_data"


#' Learning analytics dataset (OpenAlex)
#'
#' A corpus of 1,508 gold open-access scholarly works on learning analytics,
#' retrieved from OpenAlex (CC0 licence). All records have a verified title,
#' publication year, and at least one author. Journal names are present for
#' works published in a named source; preprints and book chapters may have
#' `NA` in `journal`.
#'
#' @format A data frame with 1,508 rows and 11 columns:
#' \describe{
#'   \item{id}{OpenAlex work ID (e.g. \code{"W2769342982"}).}
#'   \item{title}{Work title.}
#'   \item{year}{Publication year (integer).}
#'   \item{journal}{Source name, or \code{NA} if not available.}
#'   \item{doi}{DOI string without the \code{https://doi.org/} prefix,
#'     or \code{NA}.}
#'   \item{cited_by_count}{Number of citing works as recorded in OpenAlex.}
#'   \item{type}{Work type (\code{"article"}, \code{"review"},
#'     \code{"preprint"}, \code{"book-chapter"}, etc.).}
#'   \item{authors}{List-column of author display names (pipe-split from
#'     the OpenAlex flat export; one name per authorship slot).}
#'   \item{keywords}{List-column with one element: the primary OpenAlex
#'     topic for the work (e.g. \code{"Online Learning and Analytics"}).}
#'   \item{affiliations}{List-column of institution display names (one
#'     entry per authorship-institution pair).}
#'   \item{countries}{List-column of two-letter ISO country codes (one
#'     entry per authorship-institution pair).}
#' }
#'
#' @source OpenAlex \url{https://openalex.org}, CC0 licence.
#'
#' @examples
#' data(learning_analytics)
#' author_network(learning_analytics, "collaboration")
#' country_network(learning_analytics, "collaboration")
"learning_analytics"


#' Scopus dataset: green cloud computing and quantization (2020--2025)
#'
#' A 499-record subset of a Scopus bibliometric export on the intersection
#' of green cloud computing and quantization, covering 2020--2025. Includes
#' full reference strings, author keywords, and affiliations. The
#' references are formatted citation strings, not Scopus EIDs, so they do
#' not match the `id` column: use this dataset for co-citation, coupling,
#' keyword and collaboration networks, not for local citations or
#' historiographs.
#'
#' @format A data frame with 499 rows and 12 columns:
#' \describe{
#'   \item{id}{Scopus EID.}
#'   \item{title}{Work title.}
#'   \item{year}{Publication year (integer).}
#'   \item{journal}{Source title.}
#'   \item{doi}{DOI string without the \code{https://doi.org/} prefix.}
#'   \item{cited_by_count}{Times cited in Scopus.}
#'   \item{abstract}{Abstract text.}
#'   \item{type}{Document type (\code{"Article"}, \code{"Review"}, etc.).}
#'   \item{authors}{List-column of author name strings.}
#'   \item{references}{List-column of cited reference strings.}
#'   \item{keywords}{List-column of author keywords.}
#'   \item{affiliations}{List-column of affiliation strings.}
#' }
#'
#' @source Scopus bibliometric export. Dataset archived at
#'   \doi{10.5281/zenodo.17142636} (CC BY 4.0).
#'
#' @examples
#' data(scopus_quantum_cloud)
#' author_network(scopus_quantum_cloud, "collaboration")
#' keyword_network(scopus_quantum_cloud)
#' document_network(scopus_quantum_cloud, "coupling", similarity = "cosine")
"scopus_quantum_cloud"
