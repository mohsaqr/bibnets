## ── helpers ──────────────────────────────────────────────────────────────────

make_dim_csv <- function(rows, extra_cols = character(0), file = tempfile(fileext = ".csv")) {
  ## Dimensions CSVs always begin with a one-line metadata header then the
  ## real column-name row.  The parser (read_dimensions.R line 26) detects
  ## lines starting with ^"?About the data and skips 1 row.
  header <- paste0(
    '"About the data: Export created ',
    format(Sys.Date(), "%Y-%m-%d"),
    '"'
  )
  col_names <- c(
    "Publication ID", "Title", "PubYear", "Source title", "DOI",
    "Times cited", "Abstract", "Publication Type",
    "Authors", "Cited references",
    "Authors Affiliations - Name of Research organization",
    "Authors Affiliations - Country of Research organization",
    "Keywords",
    extra_cols
  )

  write_row <- function(r) {
    paste(vapply(r, function(v) {
      if (is.na(v)) "" else paste0('"', gsub('"', '""', v), '"')
    }, character(1)), collapse = ",")
  }

  lines <- c(
    header,
    paste(vapply(col_names, function(n) paste0('"', n, '"'), character(1)),
          collapse = ","),
    vapply(rows, write_row, character(1))
  )
  writeLines(lines, file)
  file
}

## Three representative rows used in most tests
typical_rows <- list(
  ## 1: full record, two authors, two references
  c(
    "pub.1111111111", "Learning Networks", "2021",
    "Journal of Education", "10.1000/xyz001", "15",
    "This paper studies learning networks.",
    "article",
    "Smith, John; Jones, Mary",
    "Brown A, Title X, 2018, Journal Z; Green B, Title Y, 2019, Journal W",
    "University A; University B",
    "USA; UK",
    "network; learning"
  ),
  ## 2: multiple affiliations & countries; non-ASCII author name
  c(
    "pub.2222222222", "Réseaux éducatifs", "2022",
    "Revue Française", "10.1000/xyz002", "3",
    "Study of éducation réseaux.",
    "article",
    "Müller, Hans; Lefèvre, Claire; Tanaka, Yuki",
    "White C, Study Z, 2020, Jour Q",
    "Universität Berlin; Université Paris; Kyoto University",
    "Germany; France; Japan",
    "éducation; réseaux; multilingual"
  ),
  ## 3: missing references (empty string)
  c(
    "pub.3333333333", "Citation-free Article", "2023",
    "Open Access Journal", "10.1000/xyz003", "0",
    "An article with no references.",
    "conference paper",
    "Doe, Jane",
    "",
    "State College",
    "USA",
    "open access"
  )
)

## ── Standard columns ──────────────────────────────────────────────────────────

test_that("read_dimensions returns all required standard columns", {
  f <- make_dim_csv(typical_rows)
  d <- read_dimensions(f)

  expected <- c("id", "title", "year", "journal", "doi",
                "cited_by_count", "abstract", "type",
                "authors", "references", "keywords",
                "affiliations", "countries")
  expect_true(all(expected %in% names(d)))
})

test_that("read_dimensions returns columns in correct order", {
  f <- make_dim_csv(typical_rows)
  d <- read_dimensions(f)
  std_order <- c("id", "title", "year", "journal", "doi",
                 "cited_by_count", "abstract", "type",
                 "authors", "references", "keywords",
                 "affiliations", "countries")
  expect_equal(names(d)[seq_along(std_order)], std_order)
})

test_that("read_dimensions returns 3 rows from 3-record fixture", {
  f <- make_dim_csv(typical_rows)
  d <- read_dimensions(f)
  expect_equal(nrow(d), 3L)
})

## ── Scalar column types ───────────────────────────────────────────────────────

test_that("year is integer", {
  f <- make_dim_csv(typical_rows)
  d <- read_dimensions(f)
  expect_type(d$year, "integer")
  expect_equal(d$year, c(2021L, 2022L, 2023L))
})

test_that("cited_by_count is integer with no NAs", {
  f <- make_dim_csv(typical_rows)
  d <- read_dimensions(f)
  expect_type(d$cited_by_count, "integer")
  expect_false(any(is.na(d$cited_by_count)))
  expect_equal(d$cited_by_count, c(15L, 3L, 0L))
})

test_that("id column is populated from Publication ID", {
  f <- make_dim_csv(typical_rows)
  d <- read_dimensions(f)
  expect_equal(d$id, c("pub.1111111111", "pub.2222222222", "pub.3333333333"))
})

test_that("title, journal, doi, abstract, type are character", {
  f <- make_dim_csv(typical_rows)
  d <- read_dimensions(f)
  for (col in c("title", "journal", "doi", "abstract", "type")) {
    expect_type(d[[col]], "character")
  }
})

## ── List-columns ──────────────────────────────────────────────────────────────

test_that("authors, references, keywords, affiliations, countries are list-columns", {
  f <- make_dim_csv(typical_rows)
  d <- read_dimensions(f)
  for (col in c("authors", "references", "keywords", "affiliations", "countries")) {
    expect_true(is.list(d[[col]]))
  }
})

test_that("semicolons split authors into multiple elements", {
  f <- make_dim_csv(typical_rows)
  d <- read_dimensions(f)
  expect_equal(length(d$authors[[1]]), 2L)   ## "Smith, John; Jones, Mary"
  expect_equal(length(d$authors[[2]]), 3L)   ## three authors
  expect_equal(length(d$authors[[3]]), 1L)   ## "Doe, Jane"
})

test_that("authors are uppercased", {
  f <- make_dim_csv(typical_rows)
  d <- read_dimensions(f)
  all_authors <- unlist(d$authors)
  expect_true(all(all_authors == toupper(all_authors)))
})

test_that("semicolons split references correctly", {
  f <- make_dim_csv(typical_rows)
  d <- read_dimensions(f)
  expect_equal(length(d$references[[1]]), 2L)
  expect_equal(length(d$references[[2]]), 1L)
})

test_that("references are uppercased", {
  f <- make_dim_csv(typical_rows)
  d <- read_dimensions(f)
  present <- unlist(d$references)
  expect_true(all(present == toupper(present)))
})

test_that("empty references yield character(0)", {
  f <- make_dim_csv(typical_rows)
  d <- read_dimensions(f)
  expect_equal(d$references[[3]], character(0))
})

test_that("keywords are split by semicolon", {
  f <- make_dim_csv(typical_rows)
  d <- read_dimensions(f)
  expect_equal(length(d$keywords[[1]]), 2L)   ## "network; learning"
  expect_equal(length(d$keywords[[2]]), 3L)
  expect_equal(length(d$keywords[[3]]), 1L)
})

test_that("affiliations are split by semicolon", {
  f <- make_dim_csv(typical_rows)
  d <- read_dimensions(f)
  expect_equal(length(d$affiliations[[1]]), 2L)
  expect_equal(length(d$affiliations[[2]]), 3L)
  expect_equal(length(d$affiliations[[3]]), 1L)
})

test_that("countries are split by semicolon", {
  f <- make_dim_csv(typical_rows)
  d <- read_dimensions(f)
  expect_equal(length(d$countries[[1]]), 2L)  ## "USA; UK"
  expect_equal(length(d$countries[[2]]), 3L)  ## three countries
  expect_equal(length(d$countries[[3]]), 1L)
})

## ── Dimensions metadata header quirk ─────────────────────────────────────────

test_that("file with About-the-data header is parsed correctly", {
  ## Parser should detect and skip the metadata line; only data rows returned.
  f <- make_dim_csv(typical_rows)
  first <- readLines(f, n = 1L)
  expect_true(grepl('^"About the data', first))
  d <- read_dimensions(f)
  expect_equal(nrow(d), 3L)
  ## First row title must be the first actual record, not junk from the header
  expect_equal(d$title[1], "Learning Networks")
})

test_that("file without About-the-data header is also parsed (skip_rows=0)", {
  ## Build a plain CSV with no metadata line — parser falls back to skip=0.
  rows <- typical_rows[1:2]
  col_names <- c(
    "Publication ID", "Title", "PubYear", "Source title", "DOI",
    "Times cited", "Abstract", "Publication Type",
    "Authors", "Cited references",
    "Authors Affiliations - Name of Research organization",
    "Authors Affiliations - Country of Research organization",
    "Keywords"
  )
  f <- tempfile(fileext = ".csv")
  write_row <- function(r) {
    paste(vapply(r, function(v) {
      if (is.na(v)) "" else paste0('"', gsub('"', '""', v), '"')
    }, character(1)), collapse = ",")
  }
  lines <- c(
    paste(vapply(col_names, function(n) paste0('"', n, '"'), character(1)),
          collapse = ","),
    vapply(rows, write_row, character(1))
  )
  writeLines(lines, f)
  d <- read_dimensions(f)
  expect_equal(nrow(d), 2L)
})

## ── Column name aliases ───────────────────────────────────────────────────────

test_that("Publication Year alias is accepted for year column", {
  f <- tempfile(fileext = ".csv")
  writeLines(c(
    '"About the data: test"',
    '"Publication ID","Title","Publication Year","Source title","DOI","Times cited","Abstract","Publication Type","Authors","Cited references","Authors Affiliations - Name of Research organization","Authors Affiliations - Country of Research organization","Keywords"',
    '"pub.99","Alt Year Test","2020","Some Journal","10.0/x","5","Abstract here.","article","Author, A","","Org A","CountryX","kw1"'
  ), f)
  d <- read_dimensions(f)
  expect_equal(d$year, 2020L)
})

test_that("Dimensions URL alias is accepted for id column", {
  f <- tempfile(fileext = ".csv")
  writeLines(c(
    '"About the data: test"',
    '"Dimensions URL","Title","PubYear","Source title","DOI","Times cited","Abstract","Publication Type","Authors","Cited references","Authors Affiliations - Name of Research organization","Authors Affiliations - Country of Research organization","Keywords"',
    '"https://app.dimensions.ai/pub.555","URL ID Test","2021","Journal","10.0/u","2","Abs.","article","Auth, B","","Org B","CountryY","kw2"'
  ), f)
  d <- read_dimensions(f)
  expect_equal(d$id[1], "https://app.dimensions.ai/pub.555")
})

## ── Fallback ID generation ────────────────────────────────────────────────────

test_that("rows with empty Publication ID get DIMn fallback id", {
  f <- tempfile(fileext = ".csv")
  writeLines(c(
    '"About the data: test"',
    '"Publication ID","Title","PubYear","Source title","DOI","Times cited","Abstract","Publication Type","Authors","Cited references","Authors Affiliations - Name of Research organization","Authors Affiliations - Country of Research organization","Keywords"',
    '"","No ID Paper","2020","Journal","10.0/n","1","Abs.","article","Auth, C","","Org C","CountryZ","kw3"'
  ), f)
  d <- read_dimensions(f)
  expect_equal(d$id[1], "DIM1")
})

## ── Missing optional columns ──────────────────────────────────────────────────

test_that("missing Keywords column produces empty list-column", {
  f <- tempfile(fileext = ".csv")
  writeLines(c(
    '"About the data: test"',
    '"Publication ID","Title","PubYear","Source title","DOI","Times cited","Abstract","Publication Type","Authors","Cited references","Authors Affiliations - Name of Research organization","Authors Affiliations - Country of Research organization"',
    '"pub.1","No KW","2021","J","10.0/k","0","A.","article","Auth, D","","Org D","CountryA"'
  ), f)
  d <- read_dimensions(f)
  expect_true(is.list(d$keywords))
  expect_equal(d$keywords[[1]], character(0))
})

test_that("missing affiliations/countries columns produce empty list-columns", {
  f <- tempfile(fileext = ".csv")
  writeLines(c(
    '"About the data: test"',
    '"Publication ID","Title","PubYear","Source title","DOI","Times cited","Abstract","Publication Type","Authors","Cited references","Keywords"',
    '"pub.2","No Aff","2022","J","10.0/a","2","Abs.","article","Auth, E","ref1","kw"'
  ), f)
  d <- read_dimensions(f)
  expect_true(is.list(d$affiliations))
  expect_true(is.list(d$countries))
  expect_equal(d$affiliations[[1]], character(0))
  expect_equal(d$countries[[1]], character(0))
})

## ── Non-ASCII / special characters ───────────────────────────────────────────

test_that("non-ASCII characters in author names are preserved", {
  f <- make_dim_csv(typical_rows)
  d <- read_dimensions(f)
  ## Row 2 has Müller, Hans; Lefèvre, Claire; Tanaka, Yuki
  ## After uppercasing these become MÜLLER, HANS etc.
  author_str <- paste(d$authors[[2]], collapse = " ")
  expect_true(nchar(author_str) > 0)
  expect_equal(length(d$authors[[2]]), 3L)
})

## ── Error on bad file ─────────────────────────────────────────────────────────

test_that("read_dimensions errors on non-existent file", {
  expect_error(read_dimensions("no_such_file_xyz.csv"))
})

## ── read_biblio integration ───────────────────────────────────────────────────

test_that("read_biblio auto-detects Dimensions format", {
  f <- make_dim_csv(typical_rows)
  d <- read_biblio(f)
  expect_equal(nrow(d), 3L)
  expect_true(is.list(d$authors))
  expect_true(is.list(d$affiliations))
})
