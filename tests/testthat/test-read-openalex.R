## Tests for read_openalex() — uses synthetic data frames only; NO network calls.
##
## read_openalex() takes the output of openalexR::oa_fetch(entity="works") —
## a nested tibble/data frame — and returns the standard bibnets schema.
##
## Key openalexR column names (confirmed from parser source):
##   id                (OpenAlex work URL, e.g. "https://openalex.org/W123")
##   display_name      (title)
##   publication_year  (integer or character)
##   so                (source/journal name)
##   doi               (may be prefixed with "https://doi.org/")
##   cited_by_count    (integer)
##   ab                (abstract string)
##   type              (e.g. "article", "book-chapter")
##   author            (list-col of data.frames: au_display_name, au_id, ...)
##   referenced_works  (list-col of character vectors of OpenAlex IDs)
##   concepts          (list-col of data.frames: display_name, ...)
##   keywords          (list-col of data.frames or char vectors: display_name, keyword)

## ── helpers ──────────────────────────────────────────────────────────────────

make_author_df <- function(names) {
  data.frame(au_display_name = names, stringsAsFactors = FALSE)
}

make_concept_df <- function(names) {
  data.frame(display_name = names, stringsAsFactors = FALSE)
}

make_keyword_df <- function(names) {
  data.frame(display_name = names, stringsAsFactors = FALSE)
}

## Minimal valid synthetic oa_fetch() output with 3 records
make_synthetic <- function() {
  data.frame(
    id               = c("https://openalex.org/W1001",
                         "https://openalex.org/W1002",
                         "https://openalex.org/W1003"),
    display_name     = c("Title One", "Title Two", "Title Three"),
    publication_year = c(2021L, 2019L, 2023L),
    so               = c("Journal A", "Journal B", "Journal C"),
    doi              = c("https://doi.org/10.1000/aaa",
                         "https://doi.org/10.1000/bbb",
                         NA_character_),
    cited_by_count   = c(10L, 0L, 5L),
    ab               = c("Abstract one.", NA_character_, "Abstract three."),
    type             = c("article", "book-chapter", "article"),
    stringsAsFactors = FALSE
  )
}

## ── Column presence ───────────────────────────────────────────────────────────

test_that("read_openalex returns all standard columns", {
  d   <- make_synthetic()
  out <- read_openalex(d)
  expected <- c("id", "title", "year", "journal", "doi",
                "cited_by_count", "abstract", "type",
                "authors", "references", "keywords")
  expect_true(all(expected %in% names(out)))
})

test_that("standard columns appear in the correct order", {
  d   <- make_synthetic()
  out <- read_openalex(d)
  positions <- match(
    c("id", "title", "year", "journal", "doi",
      "cited_by_count", "abstract", "type",
      "authors", "references", "keywords"),
    names(out)
  )
  expect_true(all(!is.na(positions)))
  expect_equal(positions, sort(positions))
})

test_that("read_openalex returns the correct number of rows", {
  d <- make_synthetic()
  expect_equal(nrow(read_openalex(d)), 3L)
})

## ── Types ─────────────────────────────────────────────────────────────────────

test_that("year column is integer", {
  out <- read_openalex(make_synthetic())
  expect_type(out$year, "integer")
})

test_that("cited_by_count is integer", {
  out <- read_openalex(make_synthetic())
  expect_type(out$cited_by_count, "integer")
})

test_that("authors, references, keywords are list-columns", {
  d   <- make_synthetic()
  out <- read_openalex(d)
  expect_true(is.list(out$authors))
  expect_true(is.list(out$references))
  expect_true(is.list(out$keywords))
})

## ── ID handling ───────────────────────────────────────────────────────────────

test_that("id column is preserved verbatim from oa_fetch (no URL stripping)", {
  ## The parser passes the `id` column through unchanged; OpenAlex IDs keep
  ## their full URL form (stripping is not done in read_openalex).
  d   <- make_synthetic()
  out <- read_openalex(d)
  expect_equal(out$id, d$id)
})

test_that("id falls back to OA-prefixed sequence when id column is absent", {
  ## Regression: previously, safe_col() passed the length-n default through
  ## rep(default, n), inflating output to n*n rows. Fixed so a length-n
  ## default is used as-is.
  d    <- make_synthetic()
  d$id <- NULL
  out  <- read_openalex(d)
  expect_equal(nrow(out), 3L)
  expect_equal(out$id, paste0("OA", 1:3))
})

## ── DOI handling ──────────────────────────────────────────────────────────────

test_that("DOI URL prefix is stripped", {
  d   <- make_synthetic()
  out <- read_openalex(d)
  expect_equal(out$doi[1], "10.1000/aaa")
  expect_equal(out$doi[2], "10.1000/bbb")
})

test_that("NA doi passes through as NA", {
  d   <- make_synthetic()
  out <- read_openalex(d)
  expect_true(is.na(out$doi[3]))
})

test_that("doi without URL prefix is preserved unchanged", {
  d     <- make_synthetic()
  d$doi <- c("10.1000/plain", NA_character_, "10.5555/xyz")
  out   <- read_openalex(d)
  expect_equal(out$doi[1], "10.1000/plain")
  expect_equal(out$doi[3], "10.5555/xyz")
})

## ── Other scalar columns ──────────────────────────────────────────────────────

test_that("title maps from display_name", {
  d   <- make_synthetic()
  out <- read_openalex(d)
  expect_equal(out$title, d$display_name)
})

test_that("journal maps from so column", {
  d   <- make_synthetic()
  out <- read_openalex(d)
  expect_equal(out$journal, d$so)
})

test_that("year values are correct", {
  d   <- make_synthetic()
  out <- read_openalex(d)
  expect_equal(out$year, c(2021L, 2019L, 2023L))
})

test_that("cited_by_count maps correctly", {
  d   <- make_synthetic()
  out <- read_openalex(d)
  expect_equal(out$cited_by_count, c(10L, 0L, 5L))
})

test_that("abstract passes through correctly including NA", {
  d   <- make_synthetic()
  out <- read_openalex(d)
  expect_equal(out$abstract[1], "Abstract one.")
  expect_true(is.na(out$abstract[2]))
  expect_equal(out$abstract[3], "Abstract three.")
})

test_that("type column is preserved as-is", {
  d   <- make_synthetic()
  out <- read_openalex(d)
  expect_equal(out$type, c("article", "book-chapter", "article"))
})

## ── Missing optional columns ─────────────────────────────────────────────────

test_that("missing display_name yields NA titles", {
  d            <- make_synthetic()
  d$display_name <- NULL
  out          <- read_openalex(d)
  expect_true(all(is.na(out$title)))
})

test_that("missing so column yields NA journals", {
  d    <- make_synthetic()
  d$so <- NULL
  out  <- read_openalex(d)
  expect_true(all(is.na(out$journal)))
})

test_that("missing cited_by_count column defaults to 0L", {
  d                 <- make_synthetic()
  d$cited_by_count  <- NULL
  out               <- read_openalex(d)
  expect_true(all(out$cited_by_count == 0L))
  expect_type(out$cited_by_count, "integer")
})

test_that("missing type column yields NA types", {
  d      <- make_synthetic()
  d$type <- NULL
  out    <- read_openalex(d)
  expect_true(all(is.na(out$type)))
})

test_that("missing ab column yields NA abstracts", {
  d     <- make_synthetic()
  d$ab  <- NULL
  out   <- read_openalex(d)
  expect_true(all(is.na(out$abstract)))
})

## ── Authors ───────────────────────────────────────────────────────────────────

test_that("authors are extracted from nested author data.frame (au_display_name)", {
  d        <- make_synthetic()
  d$author <- list(
    make_author_df(c("Alice Smith", "Bob Jones")),
    make_author_df("Carlos García"),
    make_author_df("Dana Lee")
  )
  out <- read_openalex(d)
  expect_equal(length(out$authors[[1]]), 2L)
  ## standardize_authors uppercases names
  expect_equal(out$authors[[1]], c("ALICE SMITH", "BOB JONES"))
  expect_equal(out$authors[[2]], "CARLOS GARCÍA")
})

test_that("author display_name column also accepted when au_display_name absent", {
  d        <- make_synthetic()
  d$author <- list(
    data.frame(display_name = c("Eve White", "Frank Black"),
               stringsAsFactors = FALSE),
    NULL,
    NULL
  )
  out <- read_openalex(d)
  expect_equal(out$authors[[1]], c("EVE WHITE", "FRANK BLACK"))
})

test_that("au_name column also accepted as fallback for author names", {
  d        <- make_synthetic()
  d$author <- list(
    data.frame(au_name = c("Grace Hopper"),
               stringsAsFactors = FALSE),
    NULL,
    NULL
  )
  out <- read_openalex(d)
  expect_equal(out$authors[[1]], "GRACE HOPPER")
})

test_that("NULL author cell yields empty character vector", {
  d        <- make_synthetic()
  d$author <- list(NULL, NULL, NULL)
  out      <- read_openalex(d)
  expect_true(all(vapply(out$authors, length, integer(1)) == 0L))
})

test_that("non-data.frame author cell yields empty character vector", {
  d        <- make_synthetic()
  d$author <- list("not a data frame", NULL, NULL)
  out      <- read_openalex(d)
  expect_equal(out$authors[[1]], character(0))
})

test_that("author data.frame with no recognized name column yields empty vector", {
  d        <- make_synthetic()
  d$author <- list(
    data.frame(some_other_col = "x", stringsAsFactors = FALSE),
    NULL,
    NULL
  )
  out <- read_openalex(d)
  expect_equal(out$authors[[1]], character(0))
})

test_that("missing author column yields list of empty character vectors", {
  d   <- make_synthetic()
  out <- read_openalex(d)
  expect_true(all(vapply(out$authors, length, integer(1)) == 0L))
})

test_that("non-ASCII author names are uppercased correctly", {
  d        <- make_synthetic()
  d$author <- list(
    make_author_df("José Martínez"),
    make_author_df("Li Wei"),
    NULL
  )
  out <- read_openalex(d)
  expect_equal(out$authors[[1]], toupper("José Martínez"))
  expect_equal(out$authors[[2]], "LI WEI")
})

## ── References ────────────────────────────────────────────────────────────────

test_that("referenced_works list-col is flattened to character vectors", {
  d                  <- make_synthetic()
  d$referenced_works <- list(
    c("https://openalex.org/W999", "https://openalex.org/W888"),
    character(0),
    NULL
  )
  out <- read_openalex(d)
  expect_equal(out$references[[1]],
               c("https://openalex.org/W999", "https://openalex.org/W888"))
  expect_equal(out$references[[2]], character(0))
  expect_equal(out$references[[3]], character(0))
})

test_that("NULL referenced_works cell yields empty character vector", {
  d                  <- make_synthetic()
  d$referenced_works <- list(NULL, NULL, NULL)
  out                <- read_openalex(d)
  expect_true(all(vapply(out$references, length, integer(1)) == 0L))
})

test_that("missing referenced_works column yields empty reference lists", {
  d   <- make_synthetic()
  out <- read_openalex(d)
  expect_true(all(vapply(out$references, length, integer(1)) == 0L))
})

test_that("referenced_works as scalar character (non-list) is split by comma", {
  ## Parser uses split_field(as.character(...), sep=",") for non-list column
  d                  <- make_synthetic()
  d$referenced_works <- c("W1,W2", "W3", NA_character_)
  ## Make it NOT a list so the else branch is taken
  class(d$referenced_works) <- "character"
  out <- read_openalex(d)
  expect_equal(out$references[[1]], c("W1", "W2"))
  expect_equal(out$references[[2]], "W3")
})

## ── Keywords (concepts branch) ────────────────────────────────────────────────

test_that("keywords extracted from concepts column (display_name)", {
  d           <- make_synthetic()
  d$concepts  <- list(
    make_concept_df(c("Bibliometrics", "Network Analysis")),
    make_concept_df("Education"),
    NULL
  )
  out <- read_openalex(d)
  expect_equal(out$keywords[[1]], c("Bibliometrics", "Network Analysis"))
  expect_equal(out$keywords[[2]], "Education")
  expect_equal(out$keywords[[3]], character(0))
})

test_that("concepts column: concept_name accepted as fallback", {
  d          <- make_synthetic()
  d$concepts <- list(
    data.frame(concept_name = c("Topic A", "Topic B"),
               stringsAsFactors = FALSE),
    NULL,
    NULL
  )
  out <- read_openalex(d)
  expect_equal(out$keywords[[1]], c("Topic A", "Topic B"))
})

test_that("concepts column: NULL cell yields empty character vector", {
  d          <- make_synthetic()
  d$concepts <- list(NULL, NULL, NULL)
  out        <- read_openalex(d)
  expect_true(all(vapply(out$keywords, length, integer(1)) == 0L))
})

test_that("concepts column: non-data.frame cell yields empty character vector", {
  d          <- make_synthetic()
  d$concepts <- list("not a df", NULL, NULL)
  out        <- read_openalex(d)
  expect_equal(out$keywords[[1]], character(0))
})

test_that("concepts column: data.frame with no recognized name column yields empty", {
  d          <- make_synthetic()
  d$concepts <- list(
    data.frame(score = 0.9, stringsAsFactors = FALSE),
    NULL,
    NULL
  )
  out <- read_openalex(d)
  expect_equal(out$keywords[[1]], character(0))
})

## ── Keywords (keywords branch, no concepts column) ───────────────────────────

test_that("keywords extracted from keywords data.frame column (display_name)", {
  d           <- make_synthetic()
  d$keywords  <- list(
    make_keyword_df(c("Machine Learning", "Citation Analysis")),
    make_keyword_df("Open Access"),
    NULL
  )
  out <- read_openalex(d)
  expect_equal(out$keywords[[1]], c("Machine Learning", "Citation Analysis"))
  expect_equal(out$keywords[[2]], "Open Access")
  expect_equal(out$keywords[[3]], character(0))
})

test_that("keywords data.frame: keyword column accepted as fallback", {
  d          <- make_synthetic()
  d$keywords <- list(
    data.frame(keyword = c("scientometrics", "altmetrics"),
               stringsAsFactors = FALSE),
    NULL,
    NULL
  )
  out <- read_openalex(d)
  expect_equal(out$keywords[[1]], c("scientometrics", "altmetrics"))
})

test_that("keywords as plain character vector (non-data.frame) is accepted", {
  d          <- make_synthetic()
  d$keywords <- list(
    c("keyword one", "keyword two"),
    NULL,
    NULL
  )
  out <- read_openalex(d)
  expect_equal(out$keywords[[1]], c("keyword one", "keyword two"))
})

test_that("keywords column: NULL cell yields empty character vector", {
  d          <- make_synthetic()
  d$keywords <- list(NULL, NULL, NULL)
  out        <- read_openalex(d)
  expect_true(all(vapply(out$keywords, length, integer(1)) == 0L))
})

test_that("keywords column: data.frame with no recognized name yields empty", {
  d          <- make_synthetic()
  d$keywords <- list(
    data.frame(score = 0.5, stringsAsFactors = FALSE),
    NULL,
    NULL
  )
  out <- read_openalex(d)
  expect_equal(out$keywords[[1]], character(0))
})

test_that("concepts takes precedence over keywords when both columns present", {
  d          <- make_synthetic()
  d$concepts <- list(
    make_concept_df("From Concepts"),
    NULL,
    NULL
  )
  d$keywords <- list(
    make_keyword_df("From Keywords"),
    NULL,
    NULL
  )
  out <- read_openalex(d)
  ## Parser checks concepts first
  expect_equal(out$keywords[[1]], "From Concepts")
})

test_that("missing both concepts and keywords yields empty keyword lists", {
  d   <- make_synthetic()
  out <- read_openalex(d)
  expect_true(all(vapply(out$keywords, length, integer(1)) == 0L))
})

## ── Edge cases ────────────────────────────────────────────────────────────────

test_that("empty input data frame returns zero-row result with correct columns", {
  d   <- make_synthetic()[0, ]
  out <- read_openalex(d)
  expect_equal(nrow(out), 0L)
  expect_true(all(c("id", "title", "year", "journal", "doi",
                    "cited_by_count", "abstract", "type",
                    "authors", "references", "keywords") %in% names(out)))
})

test_that("non-data.frame input raises an error", {
  expect_error(read_openalex(list(a = 1, b = 2)))
  expect_error(read_openalex("not a data frame"))
  expect_error(read_openalex(42L))
})

test_that("single-row input works correctly", {
  d <- data.frame(
    id               = "https://openalex.org/W9999",
    display_name     = "Solo Paper",
    publication_year = 2020L,
    so               = "Solo Journal",
    doi              = "https://doi.org/10.9999/solo",
    cited_by_count   = 3L,
    ab               = "Solo abstract.",
    type             = "article",
    stringsAsFactors = FALSE
  )
  out <- read_openalex(d)
  expect_equal(nrow(out), 1L)
  expect_equal(out$doi, "10.9999/solo")
  expect_equal(out$year, 2020L)
})

test_that("publication_year as character is coerced to integer", {
  d                  <- make_synthetic()
  d$publication_year <- c("2021", "2019", "2023")
  out                <- read_openalex(d)
  expect_type(out$year, "integer")
  expect_equal(out$year, c(2021L, 2019L, 2023L))
})

test_that("all columns may contain NA without error", {
  d <- data.frame(
    id               = NA_character_,
    display_name     = NA_character_,
    publication_year = NA_integer_,
    so               = NA_character_,
    doi              = NA_character_,
    cited_by_count   = NA_integer_,
    ab               = NA_character_,
    type             = NA_character_,
    stringsAsFactors = FALSE
  )
  expect_no_error(read_openalex(d))
  out <- read_openalex(d)
  expect_equal(nrow(out), 1L)
})

test_that("result is a plain data.frame (not tibble or other subclass)", {
  d   <- make_synthetic()
  out <- read_openalex(d)
  expect_true(is.data.frame(out))
})
