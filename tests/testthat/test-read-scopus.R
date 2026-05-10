## Tests for read_scopus() — synthetic CSV fixtures only (no network calls)

## ---------------------------------------------------------------------------
## Helper: build a proper quoted CSV file from a data frame
## ---------------------------------------------------------------------------

write_scopus_csv <- function(df) {
  f <- tempfile(fileext = ".csv")
  write.csv(df, f, row.names = FALSE)
  f
}

## Full-featured 3-record Scopus data frame
make_full_df <- function() {
  data.frame(
    Authors              = c("Smith J.; Doe A.", "Garcia M.", "Müller K.; Çelik O."),
    `Author full names`  = c("Smith, John; Doe, Alice", "Garcia, Maria", "Müller, Klaus; Çelik, Osman"),
    Title                = c("Network Analysis Study", "Survey Paper", "European Study"),
    Year                 = c(2020L, 2021L, 2022L),
    `Source title`       = c("Journal of Networks", "Review Journal", "European Journal"),
    `Cited by`           = c(15L, 5L, 0L),
    DOI                  = c("10.1000/test001", "10.1000/test002", ""),
    `Author Keywords`    = c("network analysis; machine learning", "survey", ""),
    `Index Keywords`     = c("graph theory; clustering", "review methodology", ""),
    References           = c("Ref A, 2019; Ref B, 2018", "", "Ref C, 2020"),
    Affiliations         = c("Uni A", "Uni B", "Uni C"),
    Abstract             = c("Abstract text here.", "Survey abstract.", "European abstract."),
    `Document Type`      = c("Article", "Review", "Conference Paper"),
    `Language of Original Document` = c("English", "Spanish", "German"),
    EID                  = c("2-s2.0-001", "2-s2.0-002", "2-s2.0-003"),
    check.names          = FALSE,
    stringsAsFactors     = FALSE
  )
}

## ---------------------------------------------------------------------------
## 1. Standard columns present in correct order
## ---------------------------------------------------------------------------

test_that("read_scopus returns all standard columns in correct order", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  expected_cols <- c("id", "title", "year", "journal", "doi",
                     "cited_by_count", "abstract", "type",
                     "authors", "references", "keywords",
                     "index_keywords", "affiliations", "language")
  expect_true(all(expected_cols %in% names(d)))
  ## The columns must appear in the expected order
  present <- names(d)[names(d) %in% expected_cols]
  expect_equal(present, expected_cols)
})

## ---------------------------------------------------------------------------
## 2. Row count
## ---------------------------------------------------------------------------

test_that("read_scopus returns correct number of rows", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  expect_equal(nrow(d), 3L)
})

## ---------------------------------------------------------------------------
## 3. Column types
## ---------------------------------------------------------------------------

test_that("read_scopus: character columns have correct types", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  expect_type(d$id,           "character")
  expect_type(d$title,        "character")
  expect_type(d$journal,      "character")
  expect_type(d$doi,          "character")
  expect_type(d$abstract,     "character")
  expect_type(d$type,         "character")
  expect_type(d$affiliations, "character")
  expect_type(d$language,     "character")
})

test_that("read_scopus: year is integer", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  expect_type(d$year, "integer")
})

test_that("read_scopus: cited_by_count is integer", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  expect_type(d$cited_by_count, "integer")
})

test_that("read_scopus: list-columns are lists", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  expect_true(is.list(d$authors))
  expect_true(is.list(d$references))
  expect_true(is.list(d$keywords))
  expect_true(is.list(d$index_keywords))
})

## ---------------------------------------------------------------------------
## 4. EID used as id when present
## ---------------------------------------------------------------------------

test_that("read_scopus uses EID column as id", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  expect_equal(d$id, c("2-s2.0-001", "2-s2.0-002", "2-s2.0-003"))
})

## ---------------------------------------------------------------------------
## 5. EID fallback: no EID column → sequential S1, S2, ...
## ---------------------------------------------------------------------------

test_that("read_scopus falls back to sequential id when no EID column", {
  df <- data.frame(
    Title = c("Paper One", "Paper Two"),
    Authors = c("Smith J.", "Doe A."),
    Year = c(2020L, 2021L),
    `Source title` = c("Some Journal", "Other Journal"),
    `Cited by` = c(3L, 0L),
    check.names = FALSE, stringsAsFactors = FALSE
  )
  d <- read_scopus(write_scopus_csv(df))
  expect_equal(d$id, c("S1", "S2"))
})

## ---------------------------------------------------------------------------
## 6. EID fallback: EID column present but empty → sequential id
## ---------------------------------------------------------------------------

test_that("read_scopus falls back to sequential id when EID is empty string", {
  df <- data.frame(
    Title = c("Paper One", "Paper Two"),
    Authors = c("Smith J.", "Doe A."),
    Year = c(2020L, 2021L),
    `Source title` = c("Some Journal", "Other Journal"),
    `Cited by` = c(3L, 0L),
    EID = c("", ""),
    check.names = FALSE, stringsAsFactors = FALSE
  )
  d <- read_scopus(write_scopus_csv(df))
  expect_equal(d$id, c("S1", "S2"))
})

## ---------------------------------------------------------------------------
## 7. Author splitting: semicolon-delimited, uppercased, dots removed
## ---------------------------------------------------------------------------

test_that("read_scopus splits multiple authors into list elements", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  ## Record 1: "Smith J.; Doe A." → 2 elements
  expect_equal(length(d$authors[[1]]), 2L)
})

test_that("read_scopus single author yields one-element list", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  ## Record 2: "Garcia M." → 1 element
  expect_equal(length(d$authors[[2]]), 1L)
})

test_that("read_scopus uppercases author names via standardize_authors", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  ## All author tokens should already be uppercase
  for (i in seq_along(d$authors)) {
    if (length(d$authors[[i]]) > 0)
      expect_equal(d$authors[[i]], toupper(d$authors[[i]]))
  }
})

test_that("read_scopus removes dots from author initials", {
  df <- data.frame(
    Authors = "Jones, F.J.; Brown, A.M.",
    Title = "Dots Test", Year = 2020L,
    `Source title` = "J", `Cited by` = 0L,
    check.names = FALSE, stringsAsFactors = FALSE
  )
  d <- read_scopus(write_scopus_csv(df))
  expect_false(any(grepl("\\.", d$authors[[1]])))
})

## ---------------------------------------------------------------------------
## 8. Reference splitting: semicolons, uppercased via standardize_refs
## ---------------------------------------------------------------------------

test_that("read_scopus splits references on semicolon", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  ## Record 1: "Ref A, 2019; Ref B, 2018" → 2 references
  expect_equal(length(d$references[[1]]), 2L)
})

test_that("read_scopus returns empty character vector for blank references", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  ## Record 2 has empty References field
  expect_equal(length(d$references[[2]]), 0L)
  expect_type(d$references[[2]], "character")
})

test_that("read_scopus uppercases references via standardize_refs", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  expect_equal(d$references[[1]], c("REF A, 2019", "REF B, 2018"))
})

## ---------------------------------------------------------------------------
## 9. Keyword splitting
## ---------------------------------------------------------------------------

test_that("read_scopus splits author keywords on semicolon", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  ## Record 1: "network analysis; machine learning" → 2
  expect_equal(length(d$keywords[[1]]), 2L)
  expect_equal(d$keywords[[1]], c("network analysis", "machine learning"))
})

test_that("read_scopus returns empty vector for missing author keywords", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  ## Record 3 has empty Author Keywords
  expect_equal(length(d$keywords[[3]]), 0L)
})

test_that("read_scopus splits index keywords on semicolon", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  expect_equal(length(d$index_keywords[[1]]), 2L)
  expect_equal(d$index_keywords[[1]], c("graph theory", "clustering"))
})

test_that("read_scopus returns empty vector for missing index keywords", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  expect_equal(length(d$index_keywords[[3]]), 0L)
})

## ---------------------------------------------------------------------------
## 10. Scalar field values
## ---------------------------------------------------------------------------

test_that("read_scopus parses cited_by_count correctly", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  expect_equal(d$cited_by_count, c(15L, 5L, 0L))
})

test_that("read_scopus parses year correctly", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  expect_equal(d$year, c(2020L, 2021L, 2022L))
})

test_that("read_scopus parses DOI correctly", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  expect_equal(d$doi[1], "10.1000/test001")
  expect_equal(d$doi[2], "10.1000/test002")
})

test_that("read_scopus parses language field", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  expect_equal(d$language, c("English", "Spanish", "German"))
})

test_that("read_scopus parses document type field", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  expect_equal(d$type, c("Article", "Review", "Conference Paper"))
})

## ---------------------------------------------------------------------------
## 11. Missing optional columns → NA defaults (no error)
## ---------------------------------------------------------------------------

test_that("read_scopus handles missing optional columns gracefully", {
  df <- data.frame(
    Title = "Minimal Paper", Year = 2023L,
    `Source title` = "Minimal Journal",
    check.names = FALSE, stringsAsFactors = FALSE
  )
  expect_no_error({
    d <- read_scopus(write_scopus_csv(df))
  })
  expect_equal(d$id, "S1")
  expect_true(is.na(d$doi))
  expect_true(is.na(d$abstract))
  expect_true(is.na(d$affiliations))
  expect_true(is.na(d$language))
  expect_equal(length(d$authors[[1]]),        0L)
  expect_equal(length(d$references[[1]]),     0L)
  expect_equal(length(d$keywords[[1]]),       0L)
  expect_equal(length(d$index_keywords[[1]]), 0L)
})

## ---------------------------------------------------------------------------
## 12. cited_by_count defaults to 0 (not NA) when column is absent
## ---------------------------------------------------------------------------

test_that("read_scopus defaults cited_by_count to 0 when column absent", {
  df <- data.frame(
    Title = "No Cited By", Year = 2023L,
    `Source title` = "Some Journal",
    check.names = FALSE, stringsAsFactors = FALSE
  )
  d <- read_scopus(write_scopus_csv(df))
  expect_equal(d$cited_by_count, 0L)
  expect_false(is.na(d$cited_by_count))
})

## ---------------------------------------------------------------------------
## 13. UTF-8 / non-ASCII characters in author names
## ---------------------------------------------------------------------------

test_that("read_scopus handles non-ASCII author names (UTF-8)", {
  f <- write_scopus_csv(make_full_df())
  d <- read_scopus(f)
  ## Record 3: Müller K. and Çelik O. → 2 authors, non-empty after uppercasing
  expect_equal(length(d$authors[[3]]), 2L)
  expect_true(all(nchar(d$authors[[3]]) > 0))
})

## ---------------------------------------------------------------------------
## 14. Case-insensitive alternate column spellings
## ---------------------------------------------------------------------------

test_that("read_scopus accepts 'Document Title' as alternate title column", {
  df <- data.frame(
    `Document Title` = "Alternate Title Paper", Year = 2023L,
    `Source title` = "Alt Journal", `Cited by` = 2L,
    check.names = FALSE, stringsAsFactors = FALSE
  )
  d <- read_scopus(write_scopus_csv(df))
  expect_equal(d$title, "Alternate Title Paper")
})

test_that("read_scopus accepts 'Author full names' as alternate authors column", {
  df <- data.frame(
    Title = "Some Paper",
    `Author full names` = "Jones A.; Brown B.",
    Year = 2022L,
    `Source title` = "Some Journal",
    `Cited by` = 1L,
    check.names = FALSE, stringsAsFactors = FALSE
  )
  d <- read_scopus(write_scopus_csv(df))
  expect_equal(length(d$authors[[1]]), 2L)
})

test_that("read_scopus accepts 'Authors with affiliations' as alternate affiliations column", {
  df <- data.frame(
    Title = "Affil Paper", Authors = "Smith J.", Year = 2021L,
    `Source title` = "Journal X", `Cited by` = 0L,
    `Authors with affiliations` = "Smith J., Uni D",
    check.names = FALSE, stringsAsFactors = FALSE
  )
  d <- read_scopus(write_scopus_csv(df))
  expect_false(is.na(d$affiliations))
  expect_equal(d$affiliations, "Smith J., Uni D")
})

## ---------------------------------------------------------------------------
## 15. File not found → informative error from check_file()
## ---------------------------------------------------------------------------

test_that("read_scopus errors informatively on missing file", {
  expect_error(read_scopus("no_such_file_xyz.csv"),
               regexp = "File not found")
})

## ---------------------------------------------------------------------------
## 16. Single-record file
## ---------------------------------------------------------------------------

test_that("read_scopus handles a single-row CSV correctly", {
  df <- data.frame(
    Authors = "Adams P.", Title = "Single Record Paper", Year = 2019L,
    `Source title` = "Journal One", `Cited by` = 10L,
    DOI = "10.1/single", EID = "2-s2.0-999",
    check.names = FALSE, stringsAsFactors = FALSE
  )
  d <- read_scopus(write_scopus_csv(df))
  expect_equal(nrow(d), 1L)
  expect_equal(d$id, "2-s2.0-999")
  expect_equal(d$year, 2019L)
  expect_equal(d$cited_by_count, 10L)
})

test_that("read_scopus normalizes empty-string DOI to NA (regression)", {
  ## Regression: empty DOI cells were previously stored as "" rather than NA,
  ## breaking is.na(doi) deduplication checks on downstream code.
  df <- data.frame(
    Title  = c("Has DOI", "Empty DOI"),
    Year   = c(2020L, 2021L),
    `Source title` = c("J1", "J2"),
    DOI    = c("10.1/x", ""),
    EID    = c("E1", "E2"),
    check.names = FALSE, stringsAsFactors = FALSE
  )
  d <- read_scopus(write_scopus_csv(df))
  expect_equal(d$doi[1], "10.1/x")
  expect_true(is.na(d$doi[2]))
})
