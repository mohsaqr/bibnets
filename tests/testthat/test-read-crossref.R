## Tests for read_crossref() — uses synthetic data frames only; no API calls.
##
## Crossref column notes (from parser source):
##   doi, title, container.title, issued (string "YYYY-MM-DD" or "YYYY"),
##   is.referenced.by.count, abstract, type,
##   author  (list-col of data.frames with columns 'given', 'family'),
##   reference (list-col of data.frames with 'DOI', 'author', 'year',
##              'journal-title', or 'unstructured'),
##   subject  (list-col of character vectors)

## ── helpers ──────────────────────────────────────────────────────────────────

make_author_df <- function(given, family) {
  data.frame(given = given, family = family, stringsAsFactors = FALSE)
}

make_ref_df_doi <- function(dois) {
  data.frame(DOI = dois, stringsAsFactors = FALSE)
}

make_ref_df_unstructured <- function(strings) {
  data.frame(unstructured = strings, stringsAsFactors = FALSE)
}

## Minimal valid synthetic cr_works()$data with 3 records
make_synthetic <- function() {
  data.frame(
    doi   = c("10.1000/test1", "10.1000/test2", "10.1000/test3"),
    title = c("Title One", "Title Two: A Study", "Título Tres"),
    `container.title` = c("Journal A", "Journal B", "Journal C"),
    issued = c("2021-06-01", "2019", "2023-12-31"),
    `is.referenced.by.count` = c(10L, 0L, 5L),
    abstract = c("Abstract one.", NA_character_, "Resumen tres."),
    type  = c("journal-article", "book-chapter", "journal-article"),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

## ── Column presence & order ──────────────────────────────────────────────────

test_that("read_crossref returns all standard columns", {
  d <- make_synthetic()
  out <- read_crossref(d)
  expected <- c("id", "title", "year", "journal", "doi",
                "cited_by_count", "abstract", "type",
                "authors", "references", "keywords")
  expect_true(all(expected %in% names(out)))
})

test_that("standard columns appear in the correct order", {
  d <- make_synthetic()
  out <- read_crossref(d)
  col_positions <- match(
    c("id", "title", "year", "journal", "doi",
      "cited_by_count", "abstract", "type",
      "authors", "references", "keywords"),
    names(out)
  )
  expect_true(all(!is.na(col_positions)))
  expect_equal(col_positions, sort(col_positions))
})

test_that("read_crossref returns the correct number of rows", {
  d <- make_synthetic()
  expect_equal(nrow(read_crossref(d)), 3L)
})

## ── Types ─────────────────────────────────────────────────────────────────────

test_that("year column is integer", {
  d <- make_synthetic()
  out <- read_crossref(d)
  expect_type(out$year, "integer")
})

test_that("cited_by_count is integer", {
  d <- make_synthetic()
  out <- read_crossref(d)
  expect_type(out$cited_by_count, "integer")
})

test_that("authors, references, keywords are list-columns", {
  d <- make_synthetic()
  out <- read_crossref(d)
  expect_true(is.list(out$authors))
  expect_true(is.list(out$references))
  expect_true(is.list(out$keywords))
})

## ── ID / DOI logic ───────────────────────────────────────────────────────────

test_that("id equals doi when doi is present", {
  d <- make_synthetic()
  out <- read_crossref(d)
  expect_equal(out$id, d$doi)
})

test_that("id falls back to CR<n> when doi is NA", {
  d <- make_synthetic()
  d$doi[2] <- NA_character_
  out <- read_crossref(d)
  expect_equal(out$id[2], "CR2")
})

test_that("id falls back to CR<n> when doi is empty string", {
  d <- make_synthetic()
  d$doi[1] <- ""
  out <- read_crossref(d)
  expect_equal(out$id[1], "CR1")
})

## ── Year extraction ──────────────────────────────────────────────────────────

test_that("year is extracted from full date string", {
  d <- make_synthetic()
  out <- read_crossref(d)
  expect_equal(out$year[1], 2021L)
})

test_that("year is extracted from year-only string", {
  d <- make_synthetic()
  out <- read_crossref(d)
  expect_equal(out$year[2], 2019L)
})

test_that("year is NA_integer_ when issued contains no 4-digit sequence", {
  d <- data.frame(
    doi    = "10.1000/noyr",
    title  = "No Year",
    issued = "no-date-here",
    `is.referenced.by.count` = 0L,
    stringsAsFactors = FALSE, check.names = FALSE
  )
  out <- read_crossref(d)
  expect_true(is.na(out$year[1]))
})

test_that("year is NA_integer_ when issued is NA (regression)", {
  ## Regression: vapply over the issued vector previously inherited NA names,
  ## which made data.frame() throw 'row names contain missing values'.
  d <- data.frame(
    doi    = "10.1000/naissue",
    title  = "NA Issued",
    issued = NA_character_,
    `is.referenced.by.count` = 0L,
    stringsAsFactors = FALSE, check.names = FALSE
  )
  out <- read_crossref(d)
  expect_true(is.na(out$year[1]))
})

## ── cited_by_count ───────────────────────────────────────────────────────────

test_that("cited_by_count maps is.referenced.by.count correctly", {
  d <- make_synthetic()
  out <- read_crossref(d)
  expect_equal(out$cited_by_count, c(10L, 0L, 5L))
})

test_that("cited_by_count defaults to 0L when column absent", {
  d <- make_synthetic()
  d[["is.referenced.by.count"]] <- NULL
  out <- read_crossref(d)
  expect_true(all(out$cited_by_count == 0L))
})

## ── Authors ──────────────────────────────────────────────────────────────────

test_that("authors are extracted from nested author data.frame", {
  d <- make_synthetic()
  d$author <- list(
    make_author_df(c("Alice", "Bob"), c("Smith", "Jones")),
    make_author_df("Carlos", "García"),
    make_author_df("", "Solo")
  )
  out <- read_crossref(d)
  ## Parser pastes family + given then calls standardize_authors (toupper, trim)
  expect_true(length(out$authors[[1]]) == 2L)
  expect_equal(out$authors[[1]][1], "SMITH ALICE")
  expect_equal(out$authors[[1]][2], "JONES BOB")
})

test_that("non-ASCII author names are uppercased correctly", {
  d <- make_synthetic()
  d$author <- list(
    make_author_df("Carlos", "García"),
    NULL,
    NULL
  )
  out <- read_crossref(d)
  expect_equal(out$authors[[1]], toupper("GARCÍA CARLOS"))
})

test_that("NULL author cell yields empty character vector", {
  d <- make_synthetic()
  d$author <- list(NULL, NULL, NULL)
  out <- read_crossref(d)
  expect_equal(out$authors[[1]], character(0))
})

test_that("non-data.frame author cell yields empty character vector", {
  d <- make_synthetic()
  d$author <- list("some string", 42L, NULL)
  out <- read_crossref(d)
  expect_equal(out$authors[[1]], character(0))
  expect_equal(out$authors[[2]], character(0))
})

test_that("missing author column yields list of empty character vectors", {
  d <- make_synthetic()
  ## no 'author' column at all
  out <- read_crossref(d)
  expect_true(all(vapply(out$authors, length, integer(1)) == 0L))
})

## ── References ───────────────────────────────────────────────────────────────

test_that("references are extracted from DOI column in nested ref data.frame", {
  d <- make_synthetic()
  d$reference <- list(
    make_ref_df_doi(c("10.1000/ref1", "10.1000/ref2")),
    make_ref_df_doi(character(0)),
    NULL
  )
  out <- read_crossref(d)
  expect_equal(out$references[[1]], c("10.1000/REF1", "10.1000/REF2"))
})

test_that("references fall back to unstructured when DOI column absent", {
  d <- make_synthetic()
  d$reference <- list(
    make_ref_df_unstructured(c("Smith 2020 Journal X", "Jones 2019 Journal Y")),
    NULL,
    NULL
  )
  out <- read_crossref(d)
  expect_equal(
    out$references[[1]],
    c("SMITH 2020 JOURNAL X", "JONES 2019 JOURNAL Y")
  )
})

test_that("NULL reference cell yields empty character vector", {
  d <- make_synthetic()
  d$reference <- list(NULL, NULL, NULL)
  out <- read_crossref(d)
  expect_true(all(vapply(out$references, length, integer(1)) == 0L))
})

test_that("references with mixed DOI/NA fall back for NA rows", {
  d <- make_synthetic()
  ref_df <- data.frame(
    DOI    = c("10.1000/ref1", NA_character_),
    author = c("Smith A", "Jones B"),
    year   = c("2020", "2019"),
    `journal-title` = c("J A", "J B"),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  d$reference <- list(ref_df, NULL, NULL)
  out <- read_crossref(d)
  ## First ref has DOI; second falls back to "Jones B 2019 J B"
  expect_equal(out$references[[1]][1], "10.1000/REF1")
  expect_true(grepl("JONES B", out$references[[1]][2]))
})

test_that("missing reference column yields list of empty character vectors", {
  d <- make_synthetic()
  out <- read_crossref(d)
  expect_true(all(vapply(out$references, length, integer(1)) == 0L))
})

test_that("references with no DOI and no unstructured use author+year fallback", {
  ## Covers lines 95-97: ref data.frame has neither 'DOI' nor 'unstructured'
  d <- data.frame(
    doi    = "10.1000/abc",
    title  = "Test",
    issued = "2020",
    `is.referenced.by.count` = 0L,
    stringsAsFactors = FALSE, check.names = FALSE
  )
  ref_no_doi <- data.frame(
    author = c("Smith A", "Jones B"),
    year   = c("2015", "2016"),
    stringsAsFactors = FALSE
  )
  d$reference <- list(ref_no_doi)
  out <- read_crossref(d)
  expect_equal(length(out$references[[1]]), 2L)
  expect_true(grepl("SMITH A", out$references[[1]][1]))
  expect_true(grepl("2015", out$references[[1]][1]))
})

test_that("references with no DOI, no unstructured, no author use year-only fallback", {
  ## Covers the 'author' absent branch inside lines 95-97
  d <- data.frame(
    doi    = "10.1000/abc",
    title  = "Test",
    issued = "2020",
    `is.referenced.by.count` = 0L,
    stringsAsFactors = FALSE, check.names = FALSE
  )
  ref_year_only <- data.frame(
    year = c("2015", "2016"),
    stringsAsFactors = FALSE
  )
  d$reference <- list(ref_year_only)
  out <- read_crossref(d)
  expect_equal(length(out$references[[1]]), 2L)
  expect_true(grepl("2015", out$references[[1]][1]))
})

## ── Keywords (subject) ───────────────────────────────────────────────────────

test_that("keywords are extracted from subject list-column", {
  d <- make_synthetic()
  d$subject <- list(
    c("Bibliometrics", "Networks"),
    c("Education"),
    NULL
  )
  out <- read_crossref(d)
  expect_equal(out$keywords[[1]], c("Bibliometrics", "Networks"))
  expect_equal(out$keywords[[2]], c("Education"))
  expect_equal(out$keywords[[3]], character(0))
})

test_that("NULL subject cell yields empty character vector", {
  d <- make_synthetic()
  d$subject <- list(NULL, NULL, NULL)
  out <- read_crossref(d)
  expect_true(all(vapply(out$keywords, length, integer(1)) == 0L))
})

test_that("missing subject column yields empty keyword lists", {
  d <- make_synthetic()
  out <- read_crossref(d)
  expect_true(all(vapply(out$keywords, length, integer(1)) == 0L))
})

## ── Dot-hyphen column name aliasing ──────────────────────────────────────────

test_that("container-title (hyphen form) is accepted as journal", {
  d <- make_synthetic()
  ## rename container.title to container-title
  names(d)[names(d) == "container.title"] <- "container-title"
  out <- read_crossref(d)
  expect_equal(out$journal[1], "Journal A")
})

test_that("is-referenced-by-count (hyphen form) is accepted", {
  d <- make_synthetic()
  names(d)[names(d) == "is.referenced.by.count"] <- "is-referenced-by-count"
  out <- read_crossref(d)
  expect_equal(out$cited_by_count, c(10L, 0L, 5L))
})

## ── Edge cases ────────────────────────────────────────────────────────────────

test_that("empty input data frame returns zero-row result", {
  d <- make_synthetic()[0, ]
  out <- read_crossref(d)
  expect_equal(nrow(out), 0L)
  expect_true("id" %in% names(out))
})

test_that("non-data.frame input raises an error", {
  expect_error(read_crossref(list(a = 1, b = 2)))
  expect_error(read_crossref("not a data frame"))
})

test_that("all-NA doi column generates CR<n> ids for every row", {
  d <- make_synthetic()
  d$doi <- NA_character_
  out <- read_crossref(d)
  expect_equal(out$id, c("CR1", "CR2", "CR3"))
})

test_that("abstract column passes through NA values", {
  d <- make_synthetic()
  out <- read_crossref(d)
  expect_true(is.na(out$abstract[2]))
})

test_that("type column is preserved as-is", {
  d <- make_synthetic()
  out <- read_crossref(d)
  expect_equal(out$type, c("journal-article", "book-chapter", "journal-article"))
})
