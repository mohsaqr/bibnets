## Tests for read_ris()
## testthat 3.0 — no network calls, all data via tempfile()

## Helper: write RIS text to a temp file and return the path
ris_tempfile <- function(text) {
  f <- tempfile(fileext = ".ris")
  writeLines(text, f)
  f
}

## ── Standard columns ─────────────────────────────────────────────────────────

test_that("read_ris returns the 11 standard bibnets columns", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "AU  - Smith, J.",
    "TI  - A test title",
    "JO  - Test Journal",
    "PY  - 2021",
    "DO  - 10.1000/xyz",
    "AB  - An abstract.",
    "KW  - network",
    "ER  - "
  ))
  d <- read_ris(f)
  expected <- c("id", "title", "year", "journal", "doi",
                "cited_by_count", "abstract", "type",
                "authors", "references", "keywords")
  expect_true(all(expected %in% names(d)))
})

test_that("read_ris column order matches bibnets standard schema", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "AU  - Smith, J.",
    "TI  - Title",
    "JO  - Journal",
    "PY  - 2020",
    "ER  - "
  ))
  d <- read_ris(f)
  scalar_cols <- c("id", "title", "year", "journal", "doi",
                   "cited_by_count", "abstract", "type")
  expect_equal(names(d)[seq_along(scalar_cols)], scalar_cols)
})

## ── Single record: values ────────────────────────────────────────────────────

test_that("read_ris single record: scalar fields parsed correctly", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "AU  - Smith, Jane",
    "TI  - Bibliometric analysis",
    "JO  - Test Journal",
    "PY  - 2020",
    "DO  - 10.1000/test",
    "AB  - An abstract here.",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_equal(nrow(d), 1L)
  expect_equal(d$title,   "Bibliometric analysis")
  expect_equal(d$journal, "Test Journal")
  expect_equal(d$year,    2020L)
  expect_equal(d$doi,     "10.1000/test")
  expect_equal(d$abstract, "An abstract here.")
  expect_equal(d$type,    "JOUR")
})

test_that("read_ris year is integer type", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - Title",
    "PY  - 2019",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_type(d$year, "integer")
})

test_that("read_ris cited_by_count is always NA_integer_", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - Title",
    "PY  - 2020",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_true(is.na(d$cited_by_count))
  expect_type(d$cited_by_count, "integer")
})

## ── Multi-record ─────────────────────────────────────────────────────────────

test_that("read_ris multi-record: correct row count", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - Paper One",
    "PY  - 2020",
    "ER  - ",
    "TY  - CONF",
    "TI  - Paper Two",
    "PY  - 2021",
    "ER  - ",
    "TY  - BOOK",
    "TI  - Paper Three",
    "PY  - 2022",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_equal(nrow(d), 3L)
})

test_that("read_ris multi-record: no field bleeding between records", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - First Paper",
    "AU  - Alpha, A.",
    "PY  - 2000",
    "DO  - 10.1/first",
    "ER  - ",
    "TY  - JOUR",
    "TI  - Second Paper",
    "AU  - Beta, B.",
    "PY  - 2001",
    "DO  - 10.1/second",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_equal(d$title[1],  "First Paper")
  expect_equal(d$title[2],  "Second Paper")
  expect_equal(d$doi[1],   "10.1/first")
  expect_equal(d$doi[2],   "10.1/second")
  expect_equal(d$year[1],  2000L)
  expect_equal(d$year[2],  2001L)
})

test_that("read_ris multi-record: each row has its own author list", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - Paper One",
    "AU  - Alpha, A.",
    "AU  - Beta, B.",
    "ER  - ",
    "TY  - JOUR",
    "TI  - Paper Two",
    "AU  - Gamma, G.",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_equal(length(d$authors[[1]]), 2L)
  expect_equal(length(d$authors[[2]]), 1L)
})

## ── Authors list-column ──────────────────────────────────────────────────────

test_that("read_ris authors list-column has correct length for multi-author record", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - Collab paper",
    "AU  - Smith, John",
    "AU  - Jones, Kate",
    "AU  - Brown, Lee",
    "PY  - 2022",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_equal(length(d$authors[[1]]), 3L)
})

test_that("read_ris authors are uppercased (standardize_authors)", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - Title",
    "AU  - Smith, Jane",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_equal(d$authors[[1]], toupper(d$authors[[1]]))
})

test_that("read_ris authors is always a list", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - Title",
    "AU  - Smith, J.",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_true(is.list(d$authors))
})

## ── Keywords list-column ─────────────────────────────────────────────────────

test_that("read_ris keywords list-column has correct length for multi-keyword record", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - Paper",
    "KW  - networks",
    "KW  - bibliometrics",
    "KW  - co-citation",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_equal(length(d$keywords[[1]]), 3L)
})

test_that("read_ris keywords values are trimmed", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - Paper",
    "KW  -   spaced keyword  ",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_equal(d$keywords[[1]], "spaced keyword")
})

test_that("read_ris keywords is always a list", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - Title",
    "KW  - science",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_true(is.list(d$keywords))
})

## ── References column ────────────────────────────────────────────────────────

test_that("read_ris references column is a list", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - Title",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_true(is.list(d$references))
})

test_that("read_ris references are empty for standard RIS (no references field)", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - Title",
    "AU  - Smith, J.",
    "KW  - networks",
    "PY  - 2020",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_equal(length(d$references[[1]]), 0L)
  expect_true(all(vapply(d$references, length, integer(1)) == 0L))
})

## ── Missing optional tags → NA / empty list ──────────────────────────────────

test_that("read_ris missing DOI yields NA", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - No DOI paper",
    "PY  - 2018",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_true(is.na(d$doi))
})

test_that("read_ris missing abstract yields NA", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - No abstract",
    "PY  - 2018",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_true(is.na(d$abstract))
})

test_that("read_ris missing keywords yields empty character vector in list", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - No keywords",
    "PY  - 2019",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_equal(d$keywords[[1]], character(0))
})

test_that("read_ris missing authors yields empty character vector in list", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - No authors",
    "PY  - 2020",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_equal(d$authors[[1]], character(0))
})

test_that("read_ris missing year yields NA_integer_", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - No year",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_true(is.na(d$year))
  expect_type(d$year, "integer")
})

test_that("read_ris missing title yields NA", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "PY  - 2020",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_true(is.na(d$title))
})

## ── Alternative tags ─────────────────────────────────────────────────────────

test_that("read_ris accepts Y1 as year fallback", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - Y1 year",
    "Y1  - 2015/03/01",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_equal(d$year, 2015L)
})

test_that("read_ris accepts T2 as journal fallback", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - T2 journal",
    "T2  - Fallback Journal",
    "PY  - 2016",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_equal(d$journal, "Fallback Journal")
})

test_that("read_ris accepts T1 as title fallback", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "T1  - T1 title here",
    "PY  - 2016",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_equal(d$title, "T1 title here")
})

test_that("read_ris accepts N2 as abstract fallback", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - Paper",
    "N2  - Abstract from N2.",
    "PY  - 2018",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_equal(d$abstract, "Abstract from N2.")
})

test_that("read_ris accepts A1 as author fallback when AU absent", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - Paper",
    "A1  - Doe, John",
    "PY  - 2015",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_equal(length(d$authors[[1]]), 1L)
  expect_equal(d$authors[[1]], "DOE, JOHN")
})

## ── ID assignment ────────────────────────────────────────────────────────────

test_that("read_ris uses DO as id when present", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - Has DOI",
    "DO  - 10.99/test",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_equal(d$id, "10.99/test")
})

test_that("read_ris generates RIS-prefixed id when DO absent", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - No DOI",
    "PY  - 2020",
    "ER  - "
  ))
  d <- read_ris(f)
  expect_match(d$id, "^RIS")
})

## ── Empty file / empty records ───────────────────────────────────────────────

test_that("read_ris empty file returns zero-row data frame with correct columns", {
  f <- ris_tempfile(character(0))
  d <- read_ris(f)
  expect_equal(nrow(d), 0L)
  expect_true(all(c("id", "title", "year", "journal", "doi",
                    "cited_by_count", "abstract", "type",
                    "authors", "references", "keywords") %in% names(d)))
})

test_that("read_ris file with only blank lines returns zero-row data frame", {
  f <- ris_tempfile(c("", "  ", ""))
  d <- read_ris(f)
  expect_equal(nrow(d), 0L)
})

## ── Error path ───────────────────────────────────────────────────────────────

test_that("read_ris errors informatively on non-existent file", {
  expect_error(read_ris("/tmp/does-not-exist.ris"), "File not found")
})

## ── Non-ASCII / UTF-8 author names ───────────────────────────────────────────

test_that("read_ris UTF-8 author names round-trip cleanly", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "TI  - UTF-8 test",
    "AU  - Échalas, Mélanie",
    "AU  - García, José",
    "PY  - 2023",
    "ER  - "
  ))
  d <- read_ris(f, encoding = "UTF-8")
  expect_equal(length(d$authors[[1]]), 2L)
  expect_true(is.character(d$authors[[1]]))
  ## Both names should survive (non-empty) after uppercasing
  expect_true(all(nchar(d$authors[[1]]) > 0L))
})

## ── read_biblio auto-detection ───────────────────────────────────────────────

test_that("read_biblio auto-detects RIS format and parses correctly", {
  f <- ris_tempfile(c(
    "TY  - JOUR",
    "AU  - Smith, J.",
    "TI  - Auto-detect test",
    "JO  - Some Journal",
    "PY  - 2020",
    "DO  - 10.1000/autodetect",
    "ER  - "
  ))
  d <- read_biblio(f)
  expect_equal(nrow(d), 1L)
  expect_equal(d$title, "Auto-detect test")
  expect_true(is.list(d$authors))
})
