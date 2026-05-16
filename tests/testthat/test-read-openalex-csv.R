# The bundled openalex_works.csv is a small 30-row fixture (a subset of
# the full OpenAlex "Works" export). It is read-only here, so parse it
# ONCE at file scope and share `oa` across the read_openalex_csv()
# assertions instead of re-parsing per test_that(). The read_biblio
# blocks deliberately keep their own calls — they exercise a different
# code path (format auto-detection) and must not reuse `oa`.
f  <- system.file("extdata", "openalex_works.csv", package = "bibnets")
oa <- read_openalex_csv(f)

test_that("read_openalex_csv returns standard columns", {
  expect_true(all(c("id", "title", "year", "journal", "doi",
                    "cited_by_count", "abstract", "type",
                    "authors", "references", "keywords",
                    "affiliations", "countries") %in% names(oa)))
})

test_that("read_openalex_csv returns 30 rows from bundled fixture", {
  expect_equal(nrow(oa), 30L)
})

test_that("read_openalex_csv strips OpenAlex URL prefix from id", {
  expect_false(any(grepl("https://openalex.org/", oa$id)))
  expect_true(all(grepl("^W[0-9]+$", oa$id)))
})

test_that("read_openalex_csv strips DOI URL prefix", {
  doi_present <- oa$doi[!is.na(oa$doi)]
  expect_false(any(grepl("^https://doi.org/", doi_present)))
})

test_that("read_openalex_csv produces list-columns for authors, references, keywords", {
  expect_true(is.list(oa$authors))
  expect_true(is.list(oa$references))
  expect_true(is.list(oa$keywords))
  expect_true(is.list(oa$affiliations))
  expect_true(is.list(oa$countries))
})

test_that("read_openalex_csv pipe-splits authors correctly", {
  multi_author <- Filter(function(x) length(x) > 1, oa$authors)
  expect_true(length(multi_author) > 0)
})

test_that("read_openalex_csv references column is always empty", {
  expect_true(all(vapply(oa$references, length, integer(1)) == 0L))
})

test_that("read_openalex_csv abstract column is all NA", {
  expect_true(all(is.na(oa$abstract)))
})

test_that("read_openalex_csv year is integer", {
  expect_type(oa$year, "integer")
})

test_that("read_openalex_csv cited_by_count is integer with no NAs", {
  expect_type(oa$cited_by_count, "integer")
  expect_false(any(is.na(oa$cited_by_count)))
})

test_that("read_biblio auto-detects openalex_csv format", {
  f <- system.file("extdata", "openalex_works.csv", package = "bibnets")
  d <- read_biblio(f)
  expect_equal(nrow(d), 30L)
  expect_true(is.list(d$authors))
})

test_that("read_biblio with format='openalex_csv' works explicitly", {
  f <- system.file("extdata", "openalex_works.csv", package = "bibnets")
  d <- read_biblio(f, format = "openalex_csv")
  expect_equal(nrow(d), 30L)
})

test_that("read_openalex_csv countries are pipe-split into character vectors", {
  multi_country <- Filter(function(x) length(x) > 1, oa$countries)
  expect_true(length(multi_country) > 0)
  all_codes <- unlist(oa$countries)
  expect_true(all(nchar(all_codes) == 2L))
})

test_that("read_openalex_csv keywords are single-element lists from primary_topic", {
  kw_lengths <- vapply(oa$keywords, length, integer(1))
  expect_true(all(kw_lengths %in% c(0L, 1L)))
  expect_true(any(kw_lengths == 1L))
})

test_that("read_openalex_csv errors on non-existent file", {
  expect_error(read_openalex_csv("no_such_file.csv"))
})

test_that("read_biblio row-binds files with source-specific columns", {
  oa <- tempfile(fileext = ".csv")
  bib <- tempfile(fileext = ".bib")

  writeLines(c(
    "id,display_name,publication_year,primary_location.source.display_name,doi,cited_by_count,type,authorships.author.display_name,authorships.institutions.display_name,authorships.countries,primary_topic.display_name",
    "https://openalex.org/W1,OpenAlex paper,2024,Journal A,https://doi.org/10.1/oa,2,article,Alice|Bob,Uni A|Uni B,US|GB,Networks"
  ), oa)
  writeLines(c(
    "@article{key1,",
    "  title = {BibTeX paper},",
    "  author = {Smith, Jane},",
    "  year = {2023},",
    "  journal = {Journal B}",
    "}"
  ), bib)

  d <- read_biblio(c(oa, bib))

  expect_equal(nrow(d), 2L)
  expect_true(all(c("countries", "affiliations", "authors") %in% names(d)))
  expect_true(is.list(d$countries))
  expect_true(is.list(d$authors))
})

test_that("read_bibtex extracts non-standard cited references", {
  bib <- tempfile(fileext = ".bib")
  writeLines(c(
    "@article{key1,",
    "  title = {BibTeX paper},",
    "  author = {Smith, Jane},",
    "  year = {2023},",
    "  cited-references = {Ref A, 2020; Ref B, 2021}",
    "}"
  ), bib)

  d <- read_bibtex(bib)

  expect_equal(d$references[[1]], c("REF A, 2020", "REF B, 2021"))
})
