## Tests for read_wos() — plaintext (tagged) and tab-delimited formats
## Synthetic files only; no network/API calls.

## ---------------------------------------------------------------------------
## Helpers
## ---------------------------------------------------------------------------

## Write a minimal WoS plaintext file and return its path
wos_pt_file <- function(records_text) {
  f <- tempfile(fileext = ".txt")
  writeLines(records_text, f)
  f
}

## Build a single WoS plaintext record from a named list of tag->value pairs.
## Each value may be a character vector (multiple continuation lines).
make_record <- function(fields) {
  lines <- character(0)
  for (nm in names(fields)) {
    vals <- fields[[nm]]
    lines <- c(lines, sprintf("%-2s %s", nm, vals[1]))
    if (length(vals) > 1) {
      lines <- c(lines, vapply(vals[-1], function(v) sprintf("   %s", v),
                               character(1)))
    }
  }
  c(lines, "ER")
}

## ---------------------------------------------------------------------------
## Plaintext: standard columns are returned
## ---------------------------------------------------------------------------

test_that("read_wos plaintext returns standard bibnets columns", {
  rec <- make_record(list(
    UT = "WOS:000001",
    TI = "A great paper",
    AU = c("Smith, John", "Doe, Jane"),
    PY = "2020",
    SO = "Journal of Testing",
    DI = "10.1000/test.001",
    TC = "5",
    AB = "This is an abstract.",
    DT = "Article",
    DE = "network analysis; bibliometrics",
    ID = "machine learning; deep learning",
    CR = "Ref A, 2010; Ref B, 2011"
  ))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")

  expected_cols <- c("id", "title", "year", "journal", "doi",
                     "cited_by_count", "abstract", "type",
                     "authors", "references", "keywords", "keywords_plus")
  expect_true(all(expected_cols %in% names(d)))
})

test_that("read_wos plaintext column order matches standard schema", {
  rec <- make_record(list(
    UT = "WOS:000001",
    TI = "Title",
    AU = "Smith, J",
    PY = "2020",
    SO = "Journal",
    DI = "10.1/x",
    TC = "1",
    AB = "Abstract.",
    DT = "Article",
    DE = "kw1",
    ID = "kw2"
  ))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  # first 8 scalar columns in order
  expect_equal(names(d)[1:8],
               c("id", "title", "year", "journal", "doi",
                 "cited_by_count", "abstract", "type"))
})

## ---------------------------------------------------------------------------
## Plaintext: scalar field values
## ---------------------------------------------------------------------------

test_that("read_wos plaintext parses a full record correctly", {
  rec <- make_record(list(
    UT = "WOS:000001",
    TI = "A great paper",
    AU = c("Smith, John", "Doe, Jane"),
    PY = "2020",
    SO = "Journal of Testing",
    DI = "10.1000/test.001",
    TC = "5",
    AB = "This is an abstract.",
    DT = "Article",
    DE = "network analysis; bibliometrics",
    ID = "machine learning; deep learning",
    CR = "Ref A, 2010; Ref B, 2011"
  ))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")

  expect_equal(nrow(d), 1L)
  expect_equal(d$id,             "WOS:000001")
  expect_equal(d$title,          "A great paper")
  expect_equal(d$year,           2020L)
  expect_equal(d$journal,        "Journal of Testing")
  expect_equal(d$doi,            "10.1000/test.001")
  expect_equal(d$cited_by_count, 5L)
  expect_equal(d$abstract,       "This is an abstract.")
  expect_equal(d$type,           "Article")
})

test_that("read_wos plaintext year is integer", {
  rec <- make_record(list(UT = "WOS:1", TI = "T", AU = "Smith, J",
                          PY = "2018", SO = "J"))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  expect_type(d$year, "integer")
})

test_that("read_wos plaintext cited_by_count is integer", {
  rec <- make_record(list(UT = "WOS:1", TI = "T", AU = "Smith, J",
                          PY = "2018", SO = "J", TC = "42"))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  expect_type(d$cited_by_count, "integer")
  expect_equal(d$cited_by_count, 42L)
})

## ---------------------------------------------------------------------------
## Plaintext: list-columns
## ---------------------------------------------------------------------------

test_that("read_wos plaintext authors is a list-column", {
  rec <- make_record(list(UT = "WOS:1", TI = "T", AU = c("Smith, J", "Doe, A"),
                          PY = "2020", SO = "J"))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  expect_true(is.list(d$authors))
})

test_that("read_wos plaintext author names are uppercased", {
  rec <- make_record(list(UT = "WOS:1", TI = "T",
                          AU = c("Smith, John", "Doe, Jane"),
                          PY = "2020", SO = "J"))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  expect_true(all(d$authors[[1]] == toupper(d$authors[[1]])))
})

test_that("read_wos plaintext multi-line author list collects all authors", {
  ## AU tag with continuation lines (each author on its own line)
  rec <- make_record(list(
    UT = "WOS:1",
    TI = "T",
    AU = c("Alpha, A", "Beta, B", "Gamma, G"),
    PY = "2020",
    SO = "J"
  ))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  expect_equal(length(d$authors[[1]]), 3L)
})

test_that("read_wos plaintext references is a list-column", {
  rec <- make_record(list(UT = "WOS:1", TI = "T", AU = "Smith, J",
                          PY = "2020", SO = "J",
                          CR = "Ref A, 2010; Ref B, 2011"))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  expect_true(is.list(d$references))
})

test_that("read_wos plaintext references are split on semicolon", {
  rec <- make_record(list(UT = "WOS:1", TI = "T", AU = "Smith, J",
                          PY = "2020", SO = "J",
                          CR = "Ref A, 2010; Ref B, 2011"))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  expect_equal(length(d$references[[1]]), 2L)
})

test_that("read_wos plaintext references are uppercased", {
  rec <- make_record(list(UT = "WOS:1", TI = "T", AU = "Smith, J",
                          PY = "2020", SO = "J", CR = "ref a, 2010"))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  expect_true(all(d$references[[1]] == toupper(d$references[[1]])))
})

test_that("read_wos plaintext keywords is a list-column split on semicolon", {
  rec <- make_record(list(UT = "WOS:1", TI = "T", AU = "Smith, J",
                          PY = "2020", SO = "J",
                          DE = "network analysis; bibliometrics"))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  expect_true(is.list(d$keywords))
  expect_equal(length(d$keywords[[1]]), 2L)
  expect_true("network analysis" %in% d$keywords[[1]])
})

test_that("read_wos plaintext keywords_plus is a list-column split on semicolon", {
  rec <- make_record(list(UT = "WOS:1", TI = "T", AU = "Smith, J",
                          PY = "2020", SO = "J",
                          ID = "machine learning; deep learning"))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  expect_true(is.list(d$keywords_plus))
  expect_equal(length(d$keywords_plus[[1]]), 2L)
})

## ---------------------------------------------------------------------------
## Plaintext: missing / optional tags → NA / empty list
## ---------------------------------------------------------------------------

test_that("read_wos plaintext missing DOI returns NA", {
  rec <- make_record(list(UT = "WOS:1", TI = "T", AU = "Smith, J",
                          PY = "2020", SO = "J"))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  expect_true(is.na(d$doi))
})

test_that("read_wos plaintext missing TC defaults to 0L", {
  rec <- make_record(list(UT = "WOS:1", TI = "T", AU = "Smith, J",
                          PY = "2020", SO = "J"))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  expect_equal(d$cited_by_count, 0L)
})

test_that("read_wos plaintext missing CR returns empty list element", {
  rec <- make_record(list(UT = "WOS:1", TI = "T", AU = "Smith, J",
                          PY = "2020", SO = "J"))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  expect_equal(length(d$references[[1]]), 0L)
})

test_that("read_wos plaintext missing DE returns empty keywords list element", {
  rec <- make_record(list(UT = "WOS:1", TI = "T", AU = "Smith, J",
                          PY = "2020", SO = "J"))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  expect_equal(length(d$keywords[[1]]), 0L)
})

test_that("read_wos plaintext missing ID returns empty keywords_plus list element", {
  rec <- make_record(list(UT = "WOS:1", TI = "T", AU = "Smith, J",
                          PY = "2020", SO = "J"))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  expect_equal(length(d$keywords_plus[[1]]), 0L)
})

test_that("read_wos plaintext missing PY returns NA_integer_", {
  rec <- make_record(list(UT = "WOS:1", TI = "T", AU = "Smith, J", SO = "J"))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  expect_true(is.na(d$year))
  expect_type(d$year, "integer")
})

test_that("read_wos plaintext missing UT falls back to generated id", {
  rec <- make_record(list(TI = "T", AU = "Smith, J", PY = "2020", SO = "J"))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  expect_false(is.na(d$id))
  expect_true(nchar(d$id) > 0)
})

## ---------------------------------------------------------------------------
## Plaintext: multi-record file
## ---------------------------------------------------------------------------

test_that("read_wos plaintext parses multiple records", {
  rec1 <- make_record(list(UT = "WOS:001", TI = "First paper",
                           AU = "Alpha, A", PY = "2020", SO = "Journal A"))
  rec2 <- make_record(list(UT = "WOS:002", TI = "Second paper",
                           AU = "Beta, B", PY = "2021", SO = "Journal B",
                           DI = "10.99/x", TC = "3"))
  rec3 <- make_record(list(UT = "WOS:003", TI = "Third paper",
                           AU = "Gamma, G", PY = "2022", SO = "Journal C",
                           CR = "Some ref, 2000", DE = "keyword"))
  f <- wos_pt_file(c(rec1, "", rec2, "", rec3))
  d <- read_wos(f, format = "plaintext")
  expect_equal(nrow(d), 3L)
  expect_equal(d$id,    c("WOS:001", "WOS:002", "WOS:003"))
  expect_equal(d$year,  c(2020L, 2021L, 2022L))
  expect_equal(d$cited_by_count[2], 3L)
})

## ---------------------------------------------------------------------------
## Plaintext: FN/VR/EF header lines are skipped
## ---------------------------------------------------------------------------

test_that("read_wos plaintext ignores FN/VR/EF file-header lines", {
  rec <- make_record(list(UT = "WOS:1", TI = "T", AU = "Smith, J",
                          PY = "2020", SO = "J"))
  lines <- c(
    "FN Web of Science",
    "VR 1.0",
    rec,
    "EF"
  )
  f <- wos_pt_file(lines)
  d <- read_wos(f, format = "plaintext")
  expect_equal(nrow(d), 1L)
})

## ---------------------------------------------------------------------------
## Plaintext: CRLF line endings
## ---------------------------------------------------------------------------

test_that("read_wos plaintext handles Windows CRLF line endings", {
  rec <- make_record(list(UT = "WOS:CRLF", TI = "CRLF paper",
                          AU = "Smith, J", PY = "2019", SO = "J",
                          TC = "2"))
  f <- tempfile(fileext = ".txt")
  ## Write with explicit CRLF line endings (Windows-style)
  ## Encode each line as UTF-8 bytes followed by CR+LF
  crlf_bytes <- do.call(c, lapply(rec, function(ln) {
    c(chartr("", "", iconv(ln, to = "UTF-8")), as.raw(c(0x0d, 0x0a)))
  }))
  ## Use paste+rawToChar approach: build the full text with \r\n
  full_text <- paste(rec, collapse = "\r\n")
  writeBin(chartr("", "", full_text), f)
  ## Actually write raw bytes: convert string to raw with CRLF
  raw_content <- iconv(paste(rec, collapse = "\r\n"), to = "UTF-8")
  con <- file(f, open = "wb")
  writeBin(raw_content, con)
  close(con)
  d <- read_wos(f, format = "plaintext")
  expect_equal(nrow(d), 1L)
  expect_equal(d$year, 2019L)
})

## ---------------------------------------------------------------------------
## Plaintext: non-ASCII characters in title/abstract
## ---------------------------------------------------------------------------

test_that("read_wos plaintext handles non-ASCII characters", {
  rec <- make_record(list(
    UT = "WOS:NONASCII",
    TI = "Über die Netzwerkanalyse",
    AU = "Müller, Hans",
    PY = "2021",
    SO = "Zeitschrift",
    AB = "Résumé: données bibliométriques"
  ))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  expect_equal(nrow(d), 1L)
  expect_true(grepl("Netzwerkanalyse", d$title))
})

## ---------------------------------------------------------------------------
## Plaintext: DOI with trailing DOI strip in references
## ---------------------------------------------------------------------------

test_that("read_wos plaintext CR DOI suffix is stripped from references", {
  rec <- make_record(list(
    UT = "WOS:DOI",
    TI = "DOI test",
    AU = "Smith, J",
    PY = "2020",
    SO = "J",
    CR = "Author A, 2010, DOI 10.1000/abc; Author B, 2011, DOI 10.9999/xyz"
  ))
  f <- wos_pt_file(rec)
  d <- read_wos(f, format = "plaintext")
  refs <- d$references[[1]]
  expect_equal(length(refs), 2L)
  expect_false(any(grepl("DOI", refs, ignore.case = FALSE)))
})

## ---------------------------------------------------------------------------
## Plaintext: empty file → empty data frame
## ---------------------------------------------------------------------------

test_that("read_wos plaintext empty file returns empty data frame", {
  f <- wos_pt_file(character(0))
  d <- read_wos(f, format = "plaintext")
  expect_equal(nrow(d), 0L)
  expect_true(all(c("id", "title", "year", "journal", "doi",
                    "cited_by_count", "abstract", "type") %in% names(d)))
  ## Regression: empty result must include keywords_plus to match non-empty schema
  expect_true("keywords_plus" %in% names(d))
  expect_true(is.list(d$keywords_plus))
})

## ---------------------------------------------------------------------------
## Plaintext: trailing whitespace in field values
## ---------------------------------------------------------------------------

test_that("read_wos plaintext trims trailing whitespace from field values", {
  lines <- c(
    "UT WOS:TRIM   ",
    "TI  Title with trailing spaces   ",
    "AU  Smith, J   ",
    "PY  2020   ",
    "SO  Journal   ",
    "ER"
  )
  f <- wos_pt_file(lines)
  d <- read_wos(f, format = "plaintext")
  expect_false(grepl("\\s+$", d$title))
  expect_false(grepl("\\s+$", d$journal))
})

## ---------------------------------------------------------------------------
## Error handling
## ---------------------------------------------------------------------------

test_that("read_wos errors on non-existent file", {
  expect_error(read_wos("no_such_file.txt"), "not found")
})

test_that("read_wos errors on invalid format argument", {
  f <- wos_pt_file(character(0))
  expect_error(read_wos(f, format = "invalid"), "format")
})

## ---------------------------------------------------------------------------
## Tab-delimited format
## ---------------------------------------------------------------------------

## Build a tab-delimited WoS export file from a header + rows list
wos_tab_file <- function(header, rows) {
  f <- tempfile(fileext = ".txt")
  lines <- c(
    paste(header, collapse = "\t"),
    vapply(rows, function(r) paste(r, collapse = "\t"), character(1))
  )
  writeLines(lines, f)
  f
}

## Canonical WoS tab header (abbreviated to what the parser actually uses)
wos_tab_header <- c("UT", "TI", "AU", "PY", "SO", "DI", "TC",
                    "AB", "DT", "DE", "ID", "CR")

test_that("read_wos tab returns standard bibnets columns", {
  f <- wos_tab_file(
    wos_tab_header,
    list(c("WOS:T001", "Tab paper", "Smith, J; Doe, A",
           "2021", "Tab Journal", "10.1/t", "7",
           "An abstract.", "Article",
           "networks; analysis", "deep learning",
           "Ref A, 2010; Ref B, 2011"))
  )
  d <- read_wos(f, format = "tab")
  expected_cols <- c("id", "title", "year", "journal", "doi",
                     "cited_by_count", "abstract", "type",
                     "authors", "references", "keywords", "keywords_plus")
  expect_true(all(expected_cols %in% names(d)))
})

test_that("read_wos tab parses scalar fields correctly", {
  f <- wos_tab_file(
    wos_tab_header,
    list(c("WOS:T001", "Tab paper", "Smith, J",
           "2021", "Tab Journal", "10.1/t", "7",
           "An abstract.", "Article", "networks", "deep learning", ""))
  )
  d <- read_wos(f, format = "tab")
  expect_equal(nrow(d), 1L)
  expect_equal(d$id,             "WOS:T001")
  expect_equal(d$title,          "Tab paper")
  expect_equal(d$year,           2021L)
  expect_equal(d$journal,        "Tab Journal")
  expect_equal(d$doi,            "10.1/t")
  expect_equal(d$cited_by_count, 7L)
  expect_equal(d$abstract,       "An abstract.")
  expect_equal(d$type,           "Article")
})

test_that("read_wos tab year is integer", {
  f <- wos_tab_file(
    wos_tab_header,
    list(c("WOS:T001", "T", "S, J", "2019", "J", "", "0", "", "A", "", "", ""))
  )
  d <- read_wos(f, format = "tab")
  expect_type(d$year, "integer")
})

test_that("read_wos tab cited_by_count is integer", {
  f <- wos_tab_file(
    wos_tab_header,
    list(c("WOS:T001", "T", "S, J", "2019", "J", "", "15", "", "A", "", "", ""))
  )
  d <- read_wos(f, format = "tab")
  expect_type(d$cited_by_count, "integer")
  expect_equal(d$cited_by_count, 15L)
})

test_that("read_wos tab authors are split on semicolon and uppercased", {
  f <- wos_tab_file(
    wos_tab_header,
    list(c("WOS:T001", "T", "Smith, J; Doe, A", "2020", "J",
           "", "0", "", "A", "", "", ""))
  )
  d <- read_wos(f, format = "tab")
  expect_true(is.list(d$authors))
  expect_equal(length(d$authors[[1]]), 2L)
  expect_true(all(d$authors[[1]] == toupper(d$authors[[1]])))
})

test_that("read_wos tab references are split on semicolon", {
  f <- wos_tab_file(
    wos_tab_header,
    list(c("WOS:T001", "T", "S, J", "2020", "J", "", "0", "", "A",
           "", "", "Ref A, 2010; Ref B, 2011; Ref C, 2012"))
  )
  d <- read_wos(f, format = "tab")
  expect_true(is.list(d$references))
  expect_equal(length(d$references[[1]]), 3L)
})

test_that("read_wos tab keywords split on semicolon", {
  f <- wos_tab_file(
    wos_tab_header,
    list(c("WOS:T001", "T", "S, J", "2020", "J", "", "0", "", "A",
           "networks; analysis; visualization", "", ""))
  )
  d <- read_wos(f, format = "tab")
  expect_true(is.list(d$keywords))
  expect_equal(length(d$keywords[[1]]), 3L)
})

test_that("read_wos tab keywords_plus split on semicolon", {
  f <- wos_tab_file(
    wos_tab_header,
    list(c("WOS:T001", "T", "S, J", "2020", "J", "", "0", "", "A",
           "", "machine learning; NLP", ""))
  )
  d <- read_wos(f, format = "tab")
  expect_true(is.list(d$keywords_plus))
  expect_equal(length(d$keywords_plus[[1]]), 2L)
})

test_that("read_wos tab multiple records parsed correctly", {
  rows <- list(
    c("WOS:T001", "Paper One", "Alpha, A", "2019", "J1",
      "10.1/a", "3", "Abs1", "Article", "kw1", "kp1", "r1; r2"),
    c("WOS:T002", "Paper Two", "Beta, B; Gamma, G", "2020", "J2",
      "10.1/b", "8", "Abs2", "Review", "kw2; kw3", "", ""),
    c("WOS:T003", "Paper Three", "Delta, D", "2021", "J3",
      "", "0", "", "Article", "", "", "")
  )
  f <- wos_tab_file(wos_tab_header, rows)
  d <- read_wos(f, format = "tab")
  expect_equal(nrow(d), 3L)
  expect_equal(d$id,   c("WOS:T001", "WOS:T002", "WOS:T003"))
  expect_equal(d$year, c(2019L, 2020L, 2021L))
  expect_equal(length(d$references[[1]]), 2L)
  expect_equal(length(d$authors[[2]]), 2L)
})

test_that("read_wos tab with alternative 'Title' / 'Source Title' headers", {
  alt_header <- c("Accession Number", "Title", "Authors",
                  "Publication Year", "Source Title", "DOI",
                  "Times Cited", "Abstract", "Document Type",
                  "Author Keywords", "Keywords Plus", "Cited References")
  f <- wos_tab_file(
    alt_header,
    list(c("WOS:ALT1", "Alt Title", "Smith, J", "2022", "Alt Journal",
           "10.99/alt", "12", "Alt abstract.", "Article",
           "alt kw", "alt kp", ""))
  )
  d <- read_wos(f, format = "tab")
  expect_equal(nrow(d), 1L)
  expect_equal(d$title,   "Alt Title")
  expect_equal(d$journal, "Alt Journal")
})

test_that("read_wos tab empty AU cell returns empty authors list element", {
  f <- wos_tab_file(
    wos_tab_header,
    list(c("WOS:T001", "T", "", "2020", "J", "", "0", "", "A", "", "", ""))
  )
  d <- read_wos(f, format = "tab")
  expect_equal(length(d$authors[[1]]), 0L)
})

test_that("read_wos tab errors on non-existent file", {
  expect_error(read_wos("no_such_file.txt", format = "tab"), "not found")
})

## ---------------------------------------------------------------------------
## Coverage: line 85 — plaintext record with no AU tag at all
## ---------------------------------------------------------------------------

test_that("read_wos plaintext record without AU tag returns empty authors list", {
  ## Deliberately omit the AU field entirely
  lines <- c(
    "UT WOS:NOAU",
    "TI  Paper Without Author",
    "PY  2022",
    "SO  Journal",
    "ER"
  )
  f <- wos_pt_file(lines)
  d <- read_wos(f, format = "plaintext")
  expect_equal(nrow(d), 1L)
  expect_equal(length(d$authors[[1]]), 0L)
})

## ---------------------------------------------------------------------------
## Coverage: line 160 — tab get_col fallback when column name absent
## ---------------------------------------------------------------------------

test_that("read_wos tab get_col returns NA default when column absent", {
  ## Use a header that has none of the expected DOI column names
  header_no_doi <- c("UT", "TI", "AU", "PY", "SO", "TC",
                     "AB", "DT", "DE", "ID", "CR")
  f <- wos_tab_file(
    header_no_doi,
    list(c("WOS:NODOI", "No DOI paper", "Smith, J",
           "2023", "Journal", "0", "Abstract.", "Article", "kw", "kp", ""))
  )
  d <- read_wos(f, format = "tab")
  expect_equal(nrow(d), 1L)
  expect_true(is.na(d$doi))
})
