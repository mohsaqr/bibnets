## tests/testthat/test-read-lens.R
## Coverage target: >=80% of R/read-lens.R

## ── helpers ──────────────────────────────────────────────────────────────────

## Build a minimal but realistic Lens.org CSV in a temp file.
## Column names are taken verbatim from R/read-lens.R get_col() calls.
make_lens_csv <- function(...) {
  header <- paste(
    "Lens ID", "Title", "Publication Year", "Source Title",
    "DOI", "Citing Works Count", "Abstract", "Publication Type",
    "Authors", "References", "Keywords",
    sep = ","
  )
  rows <- c(...)
  f <- tempfile(fileext = ".csv")
  writeLines(c(header, rows), f)
  f
}

## Escape a CSV field that may contain commas
q <- function(x) paste0('"', x, '"')

## ── standard columns ─────────────────────────────────────────────────────────

test_that("read_lens returns all standard bibnets columns", {
  row1 <- paste(
    "000-001", q("Network science"), "2021", q("Journal of Networks"),
    "10.1/net", "42", q("A study of networks."), "journal article",
    q("Smith, J.; Jones, M."), q("Doe, A. 2018; Roe, B. 2019"), q("networks; science"),
    sep = ","
  )
  f <- make_lens_csv(row1)
  d <- read_lens(f)

  expected_cols <- c("id", "title", "year", "journal", "doi",
                     "cited_by_count", "abstract", "type",
                     "authors", "references", "keywords")
  expect_true(all(expected_cols %in% names(d)))
})

## ── column types ─────────────────────────────────────────────────────────────

test_that("read_lens year is integer", {
  row1 <- paste(
    "000-001", q("A paper"), "2020", "Some Journal",
    "10.1/x", "5", q("Abstract here."), "journal article",
    q("Author A"), "", "",
    sep = ","
  )
  f <- make_lens_csv(row1)
  d <- read_lens(f)
  expect_type(d$year, "integer")
  expect_equal(d$year, 2020L)
})

test_that("read_lens cited_by_count is integer with no NAs", {
  row1 <- paste(
    "000-001", q("A paper"), "2020", "Some Journal",
    "10.1/x", "7", q("Abstract here."), "journal article",
    q("Author A"), "", "",
    sep = ","
  )
  f <- make_lens_csv(row1)
  d <- read_lens(f)
  expect_type(d$cited_by_count, "integer")
  expect_false(anyNA(d$cited_by_count))
  expect_equal(d$cited_by_count, 7L)
})

test_that("read_lens authors, references, keywords are list-columns", {
  row1 <- paste(
    "000-001", q("A paper"), "2020", "Some Journal",
    "10.1/x", "0", q("Abs."), "journal article",
    q("Smith, J.; Jones, M."), q("Ref A; Ref B"), q("kw1; kw2"),
    sep = ","
  )
  f <- make_lens_csv(row1)
  d <- read_lens(f)
  expect_true(is.list(d$authors))
  expect_true(is.list(d$references))
  expect_true(is.list(d$keywords))
})

## ── multi-value splitting ─────────────────────────────────────────────────────

test_that("read_lens splits authors on semicolon", {
  row1 <- paste(
    "000-001", q("A paper"), "2021", "Some Journal",
    "10.1/x", "3", q("Abstract."), "journal article",
    q("Smith, J.; Jones, M.; Doe, A."), "", "",
    sep = ","
  )
  f <- make_lens_csv(row1)
  d <- read_lens(f)
  expect_equal(length(d$authors[[1]]), 3L)
})

test_that("read_lens splits keywords on semicolon", {
  row1 <- paste(
    "000-001", q("A paper"), "2021", "Some Journal",
    "10.1/x", "0", q("Abstract."), "journal article",
    q("Author A"), "", q("network analysis; bibliometrics; citation"),
    sep = ","
  )
  f <- make_lens_csv(row1)
  d <- read_lens(f)
  expect_equal(length(d$keywords[[1]]), 3L)
})

test_that("read_lens splits references on semicolon", {
  row1 <- paste(
    "000-001", q("A paper"), "2021", "Some Journal",
    "10.1/x", "0", q("Abstract."), "journal article",
    q("Author A"), q("Ref A 2018; Ref B 2019; Ref C 2020"), "",
    sep = ","
  )
  f <- make_lens_csv(row1)
  d <- read_lens(f)
  expect_equal(length(d$references[[1]]), 3L)
})

## ── author standardization ────────────────────────────────────────────────────

test_that("read_lens uppercases author names", {
  row1 <- paste(
    "000-001", q("A paper"), "2021", "Some Journal",
    "10.1/x", "0", q("Abstract."), "journal article",
    q("Smith, Jane"), "", "",
    sep = ","
  )
  f <- make_lens_csv(row1)
  d <- read_lens(f)
  expect_equal(d$authors[[1]], "SMITH, JANE")
})

test_that("read_lens removes dots from author initials", {
  row1 <- paste(
    "000-001", q("A paper"), "2021", "Some Journal",
    "10.1/x", "0", q("Abstract."), "journal article",
    q("Smith, J.K."), "", "",
    sep = ","
  )
  f <- make_lens_csv(row1)
  d <- read_lens(f)
  expect_false(grepl("\\.", d$authors[[1]][1]))
})

## ── reference standardization ────────────────────────────────────────────────

test_that("read_lens uppercases references", {
  ## standardize_refs uppercases but does NOT strip dots (only standardize_authors does)
  row1 <- paste(
    "000-001", q("A paper"), "2021", "Some Journal",
    "10.1/x", "0", q("Abstract."), "journal article",
    "", q("doe, a. 2019"), "",
    sep = ","
  )
  f <- make_lens_csv(row1)
  d <- read_lens(f)
  expect_equal(d$references[[1]], "DOE, A. 2019")
})

## ── empty / missing fields ────────────────────────────────────────────────────

test_that("read_lens empty references field becomes empty list element", {
  row1 <- paste(
    "000-001", q("A paper"), "2021", "Some Journal",
    "10.1/x", "0", q("Abstract."), "journal article",
    q("Author A"), "", "",
    sep = ","
  )
  f <- make_lens_csv(row1)
  d <- read_lens(f)
  expect_equal(length(d$references[[1]]), 0L)
})

test_that("read_lens empty keywords field becomes empty list element", {
  row1 <- paste(
    "000-001", q("A paper"), "2021", "Some Journal",
    "10.1/x", "0", q("Abstract."), "journal article",
    q("Author A"), "", "",
    sep = ","
  )
  f <- make_lens_csv(row1)
  d <- read_lens(f)
  expect_equal(length(d$keywords[[1]]), 0L)
})

test_that("read_lens handles single-author record", {
  row1 <- paste(
    "000-002", q("Solo paper"), "2022", "Solo Journal",
    "10.2/solo", "1", q("Only one author."), "journal article",
    q("Lone, A."), "", q("solo"),
    sep = ","
  )
  f <- make_lens_csv(row1)
  d <- read_lens(f)
  expect_equal(nrow(d), 1L)
  expect_equal(length(d$authors[[1]]), 1L)
})

## ── multiple rows ─────────────────────────────────────────────────────────────

test_that("read_lens returns correct row count for multiple records", {
  row1 <- paste("000-001", q("Paper 1"), "2020", "Journal A",
                "10.1/a", "10", q("Abs 1"), "journal article",
                q("Alpha, A."), "", q("kw1"), sep = ",")
  row2 <- paste("000-002", q("Paper 2"), "2021", "Journal B",
                "10.1/b", "5",  q("Abs 2"), "journal article",
                q("Beta, B.; Gamma, G."), q("Ref X; Ref Y"), q("kw2; kw3"),
                sep = ",")
  row3 <- paste("000-003", q("Paper 3"), "2022", "Journal C",
                "", "0", q("Abs 3"), "conference paper",
                "", "", "",
                sep = ",")
  f <- make_lens_csv(row1, row2, row3)
  d <- read_lens(f)
  expect_equal(nrow(d), 3L)
})

test_that("read_lens preserves Lens ID values", {
  row1 <- paste("LNS-001", q("Paper 1"), "2020", "Journal A",
                "10.1/a", "10", q("Abs 1"), "journal article",
                q("Alpha, A."), "", q("kw1"), sep = ",")
  row2 <- paste("LNS-002", q("Paper 2"), "2021", "Journal B",
                "10.1/b", "5",  q("Abs 2"), "journal article",
                q("Beta, B."), "", "",
                sep = ",")
  f <- make_lens_csv(row1, row2)
  d <- read_lens(f)
  expect_equal(d$id, c("LNS-001", "LNS-002"))
})

## ── non-ASCII characters ──────────────────────────────────────────────────────

test_that("read_lens handles non-ASCII characters in title and abstract", {
  row1 <- paste(
    "000-005", q("Réseau éducatif"), "2023", "Revue Francophone",
    "10.5/fr", "2", q("Une étude sur les réseaux."), "journal article",
    q("Dupont, Jean-Pierre"), "", q("réseaux"),
    sep = ","
  )
  f <- make_lens_csv(row1)
  d <- read_lens(f)
  expect_equal(nrow(d), 1L)
  expect_true(grepl("é", d$title, fixed = TRUE))
})

## ── alternate column name fallbacks ──────────────────────────────────────────

test_that("read_lens accepts 'Author/s' instead of 'Authors'", {
  ## Use the alternate Lens column name
  header <- paste(
    "Lens ID", "Title", "Publication Year", "Source Title",
    "DOI", "Citing Works Count", "Abstract", "Publication Type",
    "Author/s", "References", "Keywords",
    sep = ","
  )
  row1 <- paste(
    "000-010", q("Alt author paper"), "2021", "Alt Journal",
    "10.1/alt", "3", q("Abstract alt."), "journal article",
    q("Alt, A.; Alt, B."), "", "",
    sep = ","
  )
  f <- tempfile(fileext = ".csv")
  writeLines(c(header, row1), f)
  d <- read_lens(f)
  expect_equal(length(d$authors[[1]]), 2L)
})

test_that("read_lens accepts 'Cited Works' instead of 'References'", {
  header <- paste(
    "Lens ID", "Title", "Publication Year", "Source Title",
    "DOI", "Citing Works Count", "Abstract", "Publication Type",
    "Authors", "Cited Works", "Keywords",
    sep = ","
  )
  row1 <- paste(
    "000-011", q("Cited works test"), "2020", "Test Journal",
    "10.1/cw", "1", q("Abstract cw."), "journal article",
    q("Test, T."), q("Ref One; Ref Two"), "",
    sep = ","
  )
  f <- tempfile(fileext = ".csv")
  writeLines(c(header, row1), f)
  d <- read_lens(f)
  expect_equal(length(d$references[[1]]), 2L)
})

test_that("read_lens accepts 'MeSH Terms' instead of 'Keywords'", {
  header <- paste(
    "Lens ID", "Title", "Publication Year", "Source Title",
    "DOI", "Citing Works Count", "Abstract", "Publication Type",
    "Authors", "References", "MeSH Terms",
    sep = ","
  )
  row1 <- paste(
    "000-012", q("MeSH test"), "2019", "Medical Journal",
    "10.1/med", "8", q("Abstract med."), "journal article",
    q("Med, M."), "", q("brain; neuron; cortex"),
    sep = ","
  )
  f <- tempfile(fileext = ".csv")
  writeLines(c(header, row1), f)
  d <- read_lens(f)
  expect_equal(length(d$keywords[[1]]), 3L)
})

test_that("read_lens accepts 'Fields of Study' instead of 'Keywords'", {
  header <- paste(
    "Lens ID", "Title", "Publication Year", "Source Title",
    "DOI", "Citing Works Count", "Abstract", "Publication Type",
    "Authors", "References", "Fields of Study",
    sep = ","
  )
  row1 <- paste(
    "000-013", q("FoS test"), "2022", "Science Journal",
    "10.1/fos", "4", q("Abstract fos."), "journal article",
    q("Fos, F."), "", q("physics; mathematics"),
    sep = ","
  )
  f <- tempfile(fileext = ".csv")
  writeLines(c(header, row1), f)
  d <- read_lens(f)
  expect_equal(length(d$keywords[[1]]), 2L)
})

test_that("read_lens accepts 'Year of Publication' instead of 'Publication Year'", {
  header <- paste(
    "Lens ID", "Title", "Year of Publication", "Source Title",
    "DOI", "Citing Works Count", "Abstract", "Publication Type",
    "Authors", "References", "Keywords",
    sep = ","
  )
  row1 <- paste(
    "000-014", q("Year test"), "2018", "Old Journal",
    "10.1/yr", "0", q("Abstract yr."), "journal article",
    q("Old, O."), "", q("history"),
    sep = ","
  )
  f <- tempfile(fileext = ".csv")
  writeLines(c(header, row1), f)
  d <- read_lens(f)
  expect_equal(d$year, 2018L)
})

test_that("read_lens accepts 'Document Type' instead of 'Publication Type'", {
  header <- paste(
    "Lens ID", "Title", "Publication Year", "Source Title",
    "DOI", "Citing Works Count", "Abstract", "Document Type",
    "Authors", "References", "Keywords",
    sep = ","
  )
  row1 <- paste(
    "000-015", q("DocType test"), "2023", "Doc Journal",
    "10.1/dt", "2", q("Abstract dt."), "conference paper",
    q("Doc, D."), "", q("doc"),
    sep = ","
  )
  f <- tempfile(fileext = ".csv")
  writeLines(c(header, row1), f)
  d <- read_lens(f)
  expect_equal(d$type, "conference paper")
})

test_that("read_lens accepts 'Cited By Count' instead of 'Citing Works Count'", {
  header <- paste(
    "Lens ID", "Title", "Publication Year", "Source Title",
    "DOI", "Cited By Count", "Abstract", "Publication Type",
    "Authors", "References", "Keywords",
    sep = ","
  )
  row1 <- paste(
    "000-016", q("Count test"), "2021", "Count Journal",
    "10.1/ct", "99", q("Abstract ct."), "journal article",
    q("Count, C."), "", q("counting"),
    sep = ","
  )
  f <- tempfile(fileext = ".csv")
  writeLines(c(header, row1), f)
  d <- read_lens(f)
  expect_equal(d$cited_by_count, 99L)
})

test_that("read_lens uses synthetic Lens ID when 'ID' column is present but no 'Lens ID'", {
  header <- paste(
    "ID", "Title", "Publication Year", "Source Title",
    "DOI", "Citing Works Count", "Abstract", "Publication Type",
    "Authors", "References", "Keywords",
    sep = ","
  )
  row1 <- paste(
    "ID-999", q("ID fallback"), "2020", "Fallback Journal",
    "10.1/fb", "0", q("Abstract fb."), "journal article",
    q("Fallback, F."), "", "",
    sep = ","
  )
  f <- tempfile(fileext = ".csv")
  writeLines(c(header, row1), f)
  d <- read_lens(f)
  expect_equal(d$id, "ID-999")
})

## ── missing columns fallback to NA ────────────────────────────────────────────

test_that("read_lens falls back to NA for missing optional columns", {
  ## Minimal CSV: only Lens ID and Title; everything else absent
  f <- tempfile(fileext = ".csv")
  writeLines(c(
    "Lens ID,Title",
    "000-020,Minimal paper"
  ), f)
  d <- read_lens(f)
  expect_equal(nrow(d), 1L)
  expect_true(is.na(d$doi))
  expect_true(is.na(d$abstract))
  expect_true(is.na(d$journal))
})

test_that("read_lens assigns synthetic LENS-prefixed IDs when no ID column present", {
  f <- tempfile(fileext = ".csv")
  writeLines(c(
    "Title,Publication Year",
    "Solo Paper,2021"
  ), f)
  d <- read_lens(f)
  expect_equal(d$id[[1]], "LENS1")
  expect_true(grepl("^LENS", d$id[[1]]))
})

test_that("read_lens synthetic IDs do not duplicate rows for multi-row files (regression)", {
  ## Regression for previously-observed n^2 row inflation when neither 'Lens ID'
  ## nor 'ID' columns existed and the default ID vector was passed to rep(default, n).
  f <- tempfile(fileext = ".csv")
  writeLines(c(
    "Title,Publication Year",
    "Paper A,2020",
    "Paper B,2021",
    "Paper C,2022"
  ), f)
  d <- read_lens(f)
  expect_equal(nrow(d), 3L)
  expect_equal(d$id, c("LENS1", "LENS2", "LENS3"))
})

## ── error on missing file ─────────────────────────────────────────────────────

test_that("read_lens errors on non-existent file", {
  expect_error(read_lens("no_such_file_lens.csv"), "File not found")
})

## ── read_biblio auto-detection ────────────────────────────────────────────────

test_that("read_biblio auto-detects lens format via 'Lens ID' header", {
  row1 <- paste("LNS-100", q("Auto-detect paper"), "2021", "Some Journal",
                "10.1/ad", "2", q("Abstract."), "journal article",
                q("Smith, A."), "", q("detection"),
                sep = ",")
  f <- make_lens_csv(row1)
  d <- read_biblio(f)
  expect_equal(nrow(d), 1L)
  expect_true(is.list(d$authors))
})

test_that("read_biblio with format='lens' works explicitly", {
  row1 <- paste("LNS-200", q("Explicit lens"), "2022", "Explicit Journal",
                "10.1/ex", "5", q("Abstract."), "journal article",
                q("Explicit, E."), "", q("explicit"),
                sep = ",")
  f <- make_lens_csv(row1)
  d <- read_biblio(f, format = "lens")
  expect_equal(nrow(d), 1L)
  expect_equal(d$id, "LNS-200")
})
