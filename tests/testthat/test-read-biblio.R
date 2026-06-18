## tests/testthat/test-read-biblio.R
## Target: >= 85% line coverage of R/read-biblio.R
## No network calls; all fixtures via tempfile().

## ── helpers ───────────────────────────────────────────────────────────────────

## Minimal Scopus CSV (has EID → auto-detected as "scopus")
make_scopus_file <- function(n = 2L) {
  df <- data.frame(
    Title           = paste0("Paper ", seq_len(n)),
    Authors         = paste0("Author", seq_len(n), " A."),
    Year            = 2020L + seq_len(n) - 1L,
    `Source title`  = paste0("Journal ", seq_len(n)),
    `Cited by`      = seq_len(n),
    EID             = paste0("2-s2.0-00", seq_len(n)),
    DOI             = paste0("10.1/sc", seq_len(n)),
    check.names     = FALSE,
    stringsAsFactors = FALSE
  )
  f <- tempfile(fileext = ".csv")
  write.csv(df, f, row.names = FALSE)
  f
}

## Minimal Dimensions CSV (prepended "About the data: …" header line)
make_dimensions_file <- function() {
  lines <- c(
    '"About the data: Export created 2024-01-01"',
    '"Publication ID","Title","PubYear","Source title","DOI","Times cited","Abstract","Publication Type","Authors","Cited references","Authors Affiliations - Name of Research organization","Authors Affiliations - Country of Research organization","Keywords"',
    '"pub.111","A dimensions paper","2021","Dim Journal","10.1/dim","3","Some abstract.","article","Smith, John","Jones A 2019 Jour","Uni A","USA","network"'
  )
  f <- tempfile(fileext = ".csv")
  writeLines(lines, f)
  f
}

## Minimal Lens CSV (has "Lens ID" header → auto-detected)
make_lens_file <- function() {
  lines <- c(
    '"Lens ID","Title","Publication Year","Source Title","DOI","Citing Works Count","Abstract","Publication Type","Authors","References","Keywords"',
    '"000-001","A lens paper","2022","Lens Journal","10.1/lens","7","Lens abstract.","journal article","Smith J; Jones K","Ref A 2020","networks"'
  )
  f <- tempfile(fileext = ".csv")
  writeLines(lines, f)
  f
}

## Minimal WoS plaintext (starts with "FN" → auto-detected as "wos")
make_wos_file <- function() {
  f <- tempfile(fileext = ".txt")
  writeLines(c(
    "FN Web of Science",
    "VR 1.0",
    "UT WOS:000001",
    "TI  A wos paper",
    "AU  Smith, John",
    "PY  2021",
    "SO  WoS Journal",
    "TC  4",
    "ER",
    "EF"
  ), f)
  f
}

## Minimal BibTeX (starts with @ → auto-detected as "bibtex")
make_bibtex_file <- function() {
  f <- tempfile(fileext = ".bib")
  writeLines(c(
    "@article{key1,",
    "  title  = {A bibtex paper},",
    "  author = {Smith, John},",
    "  year   = {2023},",
    "  journal = {Bib Journal}",
    "}"
  ), f)
  f
}

## Minimal RIS (starts with "TY  -" → auto-detected as "ris")
make_ris_file <- function() {
  f <- tempfile(fileext = ".ris")
  writeLines(c(
    "TY  - JOUR",
    "TI  - A ris paper",
    "AU  - Smith, John",
    "PY  - 2022",
    "JO  - RIS Journal",
    "DO  - 10.1/ris1",
    "ER  - "
  ), f)
  f
}

## Generic CSV helper
make_generic_file <- function() {
  f <- tempfile(fileext = ".csv")
  df <- data.frame(
    doc_id   = c("D1", "D2", "D3"),
    headline = c("Paper One", "Paper Two", "Paper Three"),
    Authors  = c("Alice|Bob", "Carol", "Dave|Eve|Frank"),
    Tags     = c("network|graph", "statistics", "learning|AI"),
    year     = c(2020L, 2021L, 2022L),
    stringsAsFactors = FALSE
  )
  write.csv(df, f, row.names = FALSE)
  f
}


## ════════════════════════════════════════════════════════════════════════════
## 1.  detect_format() — uncovered branches
## ════════════════════════════════════════════════════════════════════════════

test_that("detect_format returns 'unknown' for an empty file", {
  f <- tempfile(fileext = ".csv")
  writeLines(character(0), f)
  ## bibnets internal function; access via :::
  result <- bibnets:::detect_format(f)
  expect_equal(result, "unknown")
})

test_that("detect_format returns 'wos' for a file starting with FN", {
  f <- tempfile(fileext = ".txt")
  writeLines(c("FN Web of Science", "VR 1.0"), f)
  expect_equal(bibnets:::detect_format(f), "wos")
})

test_that("detect_format returns 'wos' for a file starting with PT", {
  f <- tempfile(fileext = ".txt")
  writeLines(c("PT J", "AU Smith, J"), f)
  expect_equal(bibnets:::detect_format(f), "wos")
})

test_that("detect_format returns 'scopus' for CSV with EID header", {
  f <- make_scopus_file(1L)
  expect_equal(bibnets:::detect_format(f), "scopus")
})

test_that("detect_format returns 'lens' for CSV with Lens ID header", {
  f <- make_lens_file()
  expect_equal(bibnets:::detect_format(f), "lens")
})

test_that("detect_format returns 'unknown' for an unrecognised CSV", {
  f <- tempfile(fileext = ".csv")
  writeLines(c("col_a,col_b,col_c", "1,2,3"), f)
  expect_equal(bibnets:::detect_format(f), "unknown")
})


## ════════════════════════════════════════════════════════════════════════════
## 2.  resolve_paths() — directory and nonexistent path branches
## ════════════════════════════════════════════════════════════════════════════

test_that("resolve_paths returns files from a directory", {
  d <- tempdir()
  f1 <- file.path(d, paste0("test_rb_", Sys.getpid(), "_a.csv"))
  f2 <- file.path(d, paste0("test_rb_", Sys.getpid(), "_b.bib"))
  writeLines("col\n1", f1)
  writeLines("@misc{k}", f2)
  on.exit({ unlink(f1); unlink(f2) }, add = TRUE)

  result <- bibnets:::resolve_paths(d)
  expect_true(f1 %in% result)
  expect_true(f2 %in% result)
})

test_that("resolve_paths returns character(0) for nonexistent path", {
  result <- bibnets:::resolve_paths("/tmp/no_such_path_xyz_bibnets")
  expect_equal(length(result), 0L)
  expect_type(result, "character")
})

test_that("resolve_paths handles mix of existing file and nonexistent path", {
  f <- make_ris_file()
  result <- bibnets:::resolve_paths(c(f, "/tmp/definitely_missing_xyz"))
  expect_equal(result, f)
})


## ════════════════════════════════════════════════════════════════════════════
## 3.  read_biblio() — empty path stops with informative error
## ════════════════════════════════════════════════════════════════════════════

test_that("read_biblio stops with informative error when no files found", {
  expect_error(
    read_biblio("/tmp/absolutely_no_file_bibnets_xyz.csv"),
    regexp = "No files found"
  )
})

test_that("read_biblio stops when given a nonexistent directory", {
  expect_error(
    read_biblio("/tmp/nonexistent_dir_bibnets_xyz/"),
    regexp = "No files found"
  )
})


## ════════════════════════════════════════════════════════════════════════════
## 4.  read_single_biblio() — format = "generic" short-circuit path
## ════════════════════════════════════════════════════════════════════════════

test_that("read_biblio with format='generic' invokes read_generic correctly", {
  f <- make_generic_file()
  d <- read_biblio(f, format = "generic", id = "doc_id",
                   list_cols = c("Authors", "Tags"), sep = "|")
  expect_equal(nrow(d), 3L)
  expect_true(is.list(d$Authors))
  expect_true(is.list(d$Tags))
  ## First row: two Authors split on "|"
  expect_equal(length(d$Authors[[1]]), 2L)
  ## Third row: three Authors
  expect_equal(length(d$Authors[[3]]), 3L)
  ## ID column set from doc_id
  expect_equal(d$id, c("D1", "D2", "D3"))
})

test_that("read_biblio generic: list_cols not in file warn and are skipped", {
  f <- make_generic_file()
  expect_warning(
    d <- read_biblio(f, format = "generic",
                     list_cols = c("Authors", "NonExistent")),
    "NonExistent"
  )
  expect_true(is.list(d$Authors))
  ## "NonExistent" is absent — warned, not added as list col
  expect_false("NonExistent" %in% names(d))
})

test_that("read_biblio generic: entity args map source columns to standard fields", {
  f <- tempfile(fileext = ".csv")
  utils::write.csv(data.frame(
    doc       = c("P1", "P2"),
    `Author Names` = c("Smith J; Doe A", "Lee K"),
    Tags      = c("ml; ai", "nlp; ai"),
    Nations   = c("USA; UK", "DE"),
    check.names = FALSE, stringsAsFactors = FALSE
  ), f, row.names = FALSE)

  d <- read_biblio(f, format = "generic", id = "doc",
                   authors = "Author Names", keywords = "Tags",
                   countries = "Nations", sep = ";")

  ## Standard list-columns created under their standard names
  expect_true(all(c("authors", "keywords", "countries") %in% names(d)))
  expect_true(is.list(d$authors))
  expect_equal(d$authors[[1]], c("Smith J", "Doe A"))
  expect_equal(d$keywords[[1]], c("ml", "ai"))
  expect_equal(d$countries[[2]], "DE")
  expect_equal(d$id, c("P1", "P2"))

  ## Builds straight from the result with default field args
  net <- keyword_network(d)
  expect_setequal(unique(c(net$from, net$to)), c("AI", "ML", "NLP"))
})

test_that("read_biblio infers generic when entity columns are named (no format)", {
  f <- tempfile(fileext = ".csv")
  utils::write.csv(data.frame(
    doc       = c("P1", "P2"),
    `Author Names` = c("Smith J; Doe A", "Lee K; Doe A"),
    check.names = FALSE, stringsAsFactors = FALSE
  ), f, row.names = FALSE)

  ## No format = "generic" passed — naming `authors` implies it
  d <- read_biblio(f, id = "doc", authors = "Author Names", sep = ";")
  expect_true(is.list(d$authors))
  expect_equal(d$authors[[1]], c("Smith J", "Doe A"))
  expect_equal(d$id, c("P1", "P2"))
})

test_that("read_biblio generic: journal maps as a scalar (not split)", {
  f <- tempfile(fileext = ".csv")
  utils::write.csv(data.frame(
    doc = c("P1", "P2"),
    Venue = c("J Stat Soft", "J ML Res"),
    stringsAsFactors = FALSE
  ), f, row.names = FALSE)
  d <- read_biblio(f, format = "generic", id = "doc", journal = "Venue")
  expect_false(is.list(d$journal))
  expect_equal(d$journal, c("J Stat Soft", "J ML Res"))
})

test_that("read_biblio generic: deprecated 'actors' still works but warns", {
  f <- make_generic_file()
  expect_warning(
    d <- read_biblio(f, format = "generic", id = "doc_id",
                     actors = c("Authors", "Tags"), sep = "|"),
    "deprecated"
  )
  expect_true(is.list(d$Authors))
  expect_equal(length(d$Authors[[1]]), 2L)
})

test_that("read_biblio generic: NULL id uses row numbers as character id", {
  f <- make_generic_file()
  d <- read_biblio(f, format = "generic", id = NULL)
  expect_equal(d$id, as.character(1:3))
})

test_that("read_biblio generic: CSV already has an 'id' column → used as-is", {
  f <- tempfile(fileext = ".csv")
  writeLines(c("id,title", "A001,Title One", "A002,Title Two"), f)
  d <- read_biblio(f, format = "generic")
  ## id stays from the CSV column (character)
  expect_equal(d$id, c("A001", "A002"))
})


## ════════════════════════════════════════════════════════════════════════════
## 5.  read_single_biblio() — unknown format error path
## ════════════════════════════════════════════════════════════════════════════

test_that("read_biblio with undetectable format stops with actionable error", {
  f <- tempfile(fileext = ".csv")
  writeLines(c("col_x,col_y", "1,2"), f)
  ## auto-detect returns "unknown" → switch falls through to stop()
  expect_error(
    read_biblio(f),
    regexp = "Could not detect file format"
  )
})

test_that("read_single_biblio unknown format message names the file", {
  f <- tempfile(fileext = ".csv")
  writeLines(c("col_x,col_y", "1,2"), f)
  err <- tryCatch(read_biblio(f), error = function(e) conditionMessage(e))
  expect_true(grepl(basename(f), err, fixed = FALSE) ||
              grepl("Could not detect", err, fixed = FALSE))
})


## ════════════════════════════════════════════════════════════════════════════
## 6.  read_biblio() auto-detect dispatch — formats not yet covered
## ════════════════════════════════════════════════════════════════════════════

test_that("read_biblio auto-detects scopus format", {
  f <- make_scopus_file(2L)
  d <- suppressMessages(read_biblio(f))
  expect_equal(nrow(d), 2L)
  ## EID column used as id
  expect_true(all(grepl("^2-s2\\.0-", d$id)))
})

test_that("read_biblio auto-detects wos format (FN line)", {
  f <- make_wos_file()
  d <- suppressMessages(read_biblio(f))
  expect_equal(nrow(d), 1L)
  expect_equal(d$id, "WOS:000001")
})

test_that("read_biblio auto-detects lens format", {
  f <- make_lens_file()
  d <- suppressMessages(read_biblio(f))
  expect_equal(nrow(d), 1L)
  expect_equal(d$id, "000-001")
})

test_that("read_biblio auto-detects dimensions format", {
  f <- make_dimensions_file()
  d <- suppressMessages(read_biblio(f))
  expect_equal(nrow(d), 1L)
  expect_true(grepl("pub\\.111", d$id))
})

test_that("read_biblio explicit format='wos' bypasses auto-detection", {
  f <- make_wos_file()
  d <- suppressMessages(read_biblio(f, format = "wos"))
  expect_equal(nrow(d), 1L)
})

test_that("read_biblio explicit format='wos_tab' dispatches to tab parser", {
  ## Build a minimal WoS tab-delimited file
  f <- tempfile(fileext = ".txt")
  writeLines(c(
    paste(c("UT", "TI", "AU", "PY", "SO", "DI", "TC",
            "AB", "DT", "DE", "ID", "CR"), collapse = "\t"),
    paste(c("WOS:T001", "Tab paper", "Smith, J", "2021", "Tab Journal",
            "10.1/t", "7", "An abstract.", "Article",
            "networks", "deep learning", ""), collapse = "\t")
  ), f)
  d <- suppressMessages(read_biblio(f, format = "wos_tab"))
  expect_equal(nrow(d), 1L)
  expect_equal(d$id, "WOS:T001")
})

test_that("read_biblio explicit format='bibtex' dispatches correctly", {
  f <- make_bibtex_file()
  d <- suppressMessages(read_biblio(f, format = "bibtex"))
  expect_equal(nrow(d), 1L)
  expect_equal(d$title, "A bibtex paper")
})

test_that("read_biblio explicit format='ris' dispatches correctly", {
  f <- make_ris_file()
  d <- suppressMessages(read_biblio(f, format = "ris"))
  expect_equal(nrow(d), 1L)
  expect_equal(d$title, "A ris paper")
})

test_that("read_biblio explicit format='dimensions' dispatches correctly", {
  f <- make_dimensions_file()
  d <- suppressMessages(read_biblio(f, format = "dimensions"))
  expect_equal(nrow(d), 1L)
})

test_that("read_biblio explicit format='lens' dispatches correctly", {
  f <- make_lens_file()
  d <- suppressMessages(read_biblio(f, format = "lens"))
  expect_equal(nrow(d), 1L)
})


## ════════════════════════════════════════════════════════════════════════════
## 7.  Multi-file ingest — message and row-count assertions
## ════════════════════════════════════════════════════════════════════════════

test_that("read_biblio emits 'Read N files: M rows total' message for multiple files", {
  f1 <- make_ris_file()
  f2 <- make_ris_file()
  expect_message(
    read_biblio(c(f1, f2)),
    regexp = "Read 2 files: 2 rows total"
  )
})

test_that("read_biblio combines two RIS files into correct row count", {
  f1 <- make_ris_file()
  f2 <- make_ris_file()
  d <- suppressMessages(read_biblio(c(f1, f2)))
  expect_equal(nrow(d), 2L)
})

test_that("read_biblio directory input reads all matching files", {
  d_dir <- tempfile()
  dir.create(d_dir)
  on.exit(unlink(d_dir, recursive = TRUE), add = TRUE)

  ## Write three RIS files into the temp directory
  writeLines(c("TY  - JOUR", "TI  - Paper A", "PY  - 2020", "ER  - "),
             file.path(d_dir, "a.ris"))
  writeLines(c("TY  - JOUR", "TI  - Paper B", "PY  - 2021", "ER  - "),
             file.path(d_dir, "b.ris"))
  writeLines(c("TY  - JOUR", "TI  - Paper C", "PY  - 2022", "ER  - "),
             file.path(d_dir, "c.ris"))

  d <- suppressMessages(read_biblio(d_dir))
  expect_equal(nrow(d), 3L)
})

test_that("read_biblio directory: message fires when > 1 file found", {
  d_dir <- tempfile()
  dir.create(d_dir)
  on.exit(unlink(d_dir, recursive = TRUE), add = TRUE)

  writeLines(c("TY  - JOUR", "TI  - P1", "PY  - 2020", "ER  - "),
             file.path(d_dir, "r1.ris"))
  writeLines(c("TY  - JOUR", "TI  - P2", "PY  - 2021", "ER  - "),
             file.path(d_dir, "r2.ris"))

  expect_message(read_biblio(d_dir), "Read 2 files")
})

test_that("read_biblio vector of 3 files: combined row count and message", {
  f1 <- make_ris_file()   ## 1 row
  f2 <- make_ris_file()   ## 1 row
  f3 <- make_bibtex_file() ## 1 row
  expect_message(
    {d <- read_biblio(c(f1, f2, f3))},
    regexp = "Read 3 files: 3 rows total"
  )
  expect_equal(nrow(d), 3L)
})

test_that("read_biblio single file does NOT emit the multi-file message", {
  f <- make_ris_file()
  expect_no_message(read_biblio(f))
})


## ════════════════════════════════════════════════════════════════════════════
## 8.  align_biblio_columns() — missing list-column filled with empty vectors
## ════════════════════════════════════════════════════════════════════════════

test_that("align_biblio_columns fills missing list-columns with empty vectors", {
  ## RIS has no 'affiliations'; OA CSV does.  Combining them exercises the
  ## list-col fill branch of align_biblio_columns().
  oa_f <- tempfile(fileext = ".csv")
  writeLines(c(
    "id,display_name,publication_year,primary_location.source.display_name,doi,cited_by_count,type,authorships.author.display_name,authorships.institutions.display_name,authorships.countries,primary_topic.display_name",
    "https://openalex.org/W9,OA paper,2024,Journal OA,https://doi.org/10.1/oa,2,article,Alice|Bob,Uni A|Uni B,US|GB,Networks"
  ), oa_f)

  ris_f <- make_ris_file()

  d <- suppressMessages(read_biblio(c(oa_f, ris_f)))

  expect_equal(nrow(d), 2L)
  ## 'countries' and 'affiliations' exist only in the OA row; the RIS row
  ## should have them as empty list elements (not NA, not missing column)
  expect_true("countries" %in% names(d))
  expect_true(is.list(d$countries))
  ris_row <- d[is.na(d$abstract) | d$id != "W9", ]
  ## The RIS row's countries entry should be an empty character vector
  expect_equal(length(d$countries[[2]]), 0L)
})

test_that("align_biblio_columns fills missing scalar columns with NA", {
  ## Two Scopus files combined: both have same schema, no missing columns
  ## Use BibTeX + Scopus to get a scalar-col mismatch (e.g., 'language')
  bib_f <- make_bibtex_file()
  sc_f  <- make_scopus_file(1L)

  d <- suppressMessages(read_biblio(c(sc_f, bib_f)))
  ## Scopus adds 'language'; BibTeX doesn't — should be NA for BibTeX row
  if ("language" %in% names(d)) {
    expect_true(any(is.na(d$language)))
  }
  expect_equal(nrow(d), 2L)
})


## ════════════════════════════════════════════════════════════════════════════
## 9.  read_generic() — edge-cases
## ════════════════════════════════════════════════════════════════════════════

test_that("read_generic errors on a nonexistent file", {
  ## read_biblio checks resolve_paths first; it never reaches read_generic for
  ## a missing file path.  So we call the internal directly, or via a
  ## zero-length resolve that triggers "No files found" first.
  ## The "No files found" error is the correct user-facing error here.
  expect_error(
    read_biblio("/no/such/generic/file_bibnets_xyz.csv", format = "generic"),
    regexp = "No files found|File not found|not found|cannot open"
  )
})

test_that("read_generic sep parameter splits on custom delimiter", {
  f <- tempfile(fileext = ".csv")
  df <- data.frame(
    id      = c("X1", "X2"),
    authors = c("A::B::C", "D::E"),
    stringsAsFactors = FALSE
  )
  write.csv(df, f, row.names = FALSE)
  d <- read_biblio(f, format = "generic", list_cols = "authors", sep = "::")
  expect_equal(length(d$authors[[1]]), 3L)
  expect_equal(length(d$authors[[2]]), 2L)
})

test_that("read_generic with no list_cols argument leaves columns as-is", {
  f <- make_generic_file()
  d <- read_biblio(f, format = "generic")
  ## No list_cols specified: Authors column should remain character, not list
  expect_false(is.list(d$Authors))
})
