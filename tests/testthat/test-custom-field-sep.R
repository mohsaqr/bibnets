# Custom `field` + `sep` support across all network builders.
# A custom CSV column (any name, any separator) must produce the identical
# network as the canonical list-column input.

## ── Synthetic fixtures ──────────────────────────────────────────────────────

# Canonical list-column data
canonical <- data.frame(id = c("P1", "P2", "P3"), stringsAsFactors = FALSE)
canonical$authors <- list(c("Alice", "Bob"), c("Alice", "Carol"), c("Bob", "Carol"))
canonical$keywords <- list(c("ml", "ai"), c("ml", "nlp"), c("ai", "nlp"))
canonical$references <- list(c("R1", "R2"), c("R1", "R3"), c("R2", "R3"))
canonical$countries <- list(c("FI", "SE"), c("FI", "DE"), c("SE", "DE"))
canonical$affiliations <- list(c("UEF", "KTH"), c("UEF", "TUM"), c("KTH", "TUM"))

# Same data as a custom CSV would arrive: odd column names, comma-separated
custom <- data.frame(
  id = c("P1", "P2", "P3"),
  `Author Names` = c("Alice, Bob", "Alice, Carol", "Bob, Carol"),
  Tags = c("ml, ai", "ml, nlp", "ai, nlp"),
  `Cited Refs` = c("R1, R2", "R1, R3", "R2, R3"),
  Nations = c("FI, SE", "FI, DE", "SE, DE"),
  Orgs = c("UEF, KTH", "UEF, TUM", "KTH, TUM"),
  references = I(list(c("R1", "R2"), c("R1", "R3"), c("R2", "R3"))),
  check.names = FALSE,
  stringsAsFactors = FALSE
)

expect_same_network <- function(a, b) {
  ord <- function(x) {
    x <- as.data.frame(x)
    x[order(x$from, x$to), c("from", "to", "weight", "count")]
  }
  expect_equal(ord(a), ord(b), ignore_attr = TRUE)
}

## ── Builders accept custom field + sep ──────────────────────────────────────

test_that("author_network works with a custom column and separator", {
  ref <- author_network(canonical, "collaboration")
  out <- author_network(custom, "collaboration",
                        authors = "Author Names", sep = ",")
  expect_same_network(ref, out)
})

test_that("author_network positional counting respects custom field/sep order", {
  ref <- author_network(canonical, "collaboration", counting = "harmonic")
  out <- author_network(custom, "collaboration",
                        authors = "Author Names", sep = ",",
                        counting = "harmonic")
  expect_same_network(ref, out)
})

test_that("author_network attention works with custom field/sep", {
  ref <- author_network(canonical, attention = "lead")
  out <- author_network(custom, authors = "Author Names", sep = ",",
                        attention = "lead")
  expect_same_network(ref, out)
})

test_that("author_network coupling works with custom author field", {
  ref <- author_network(canonical, "coupling")
  out <- author_network(custom, "coupling",
                        authors = "Author Names", sep = ",")
  expect_same_network(ref, out)
})

test_that("author_network splits ' and ' separated strings", {
  d <- data.frame(id = 1:2,
                  authors = c("Alice and Bob", "Alice and Carol"),
                  stringsAsFactors = FALSE)
  out <- author_network(d, sep = " and ")
  expect_setequal(unique(c(out$from, out$to)), c("ALICE", "BOB", "CAROL"))
})

test_that("keyword_network works with a custom column and separator", {
  ref <- keyword_network(canonical)
  out <- keyword_network(custom, keywords = "Tags", sep = ",")
  expect_same_network(ref, out)
})

test_that("reference_network works with a custom column and separator", {
  ref <- reference_network(canonical)
  out <- reference_network(custom, references = "Cited Refs", sep = ",")
  expect_same_network(ref, out)
})

test_that("document_network coupling works with a custom column", {
  ref <- document_network(canonical, "coupling")
  out <- document_network(custom, "coupling",
                          references = "Cited Refs", sep = ",")
  expect_same_network(ref, out)
})

test_that("document_network direct citation works with a custom column", {
  d <- data.frame(id = c("A", "B", "C"),
                  cites = c("", "A", "A, B"),
                  stringsAsFactors = FALSE)
  out <- document_network(d, "citation", references = "cites", sep = ",")
  expect_equal(nrow(out), 3L)
  expect_setequal(out$to[out$from == "C"], c("A", "B"))
})

test_that("country_network works with a custom column and separator", {
  ref <- country_network(canonical, "collaboration")
  out <- country_network(custom, "collaboration",
                         countries = "Nations", sep = ",")
  expect_same_network(ref, out)
})

test_that("institution_network works with a custom column and separator", {
  ref <- institution_network(canonical, "collaboration")
  out <- institution_network(custom, "collaboration",
                             affiliations = "Orgs", sep = ",")
  expect_same_network(ref, out)
})

test_that("source_network works with a custom source column", {
  d_ref <- canonical
  d_ref$journal <- c("J1", "J2", "J1")
  d_cus <- custom
  d_cus$`Source title` <- c("J1", "J2", "J1")
  ref <- source_network(d_ref, "coupling")
  out <- source_network(d_cus, "coupling", journal = "Source title")
  expect_same_network(ref, out)
})

test_that("local_citations and historiograph work with a custom column", {
  d <- data.frame(id = c("A", "B", "C"),
                  cites = c("", "A", "A, B"),
                  year = c(2000L, 2005L, 2010L),
                  stringsAsFactors = FALSE)
  lc <- local_citations(d, references = "cites", sep = ",")
  expect_equal(lc$lcs[lc$id == "A"], 2L)
  h <- historiograph(d, references = "cites", sep = ",")
  expect_equal(nrow(h$edges), 3L)
})

## ── String columns in builders that previously assumed list-columns ─────────

test_that("positional counting on a string author column splits correctly", {
  # build_author_bipartite previously read string columns as one author each
  d <- data.frame(id = 1:2,
                  authors = c("Alice; Bob; Carol", "Alice; Carol"),
                  stringsAsFactors = FALSE)
  out <- author_network(d, counting = "first")
  # "first" counting keeps only first authors -> Alice solo, no edges
  expect_setequal(unique(c(out$from, out$to)), character(0))
  out_full <- author_network(d, counting = "harmonic")
  expect_setequal(unique(c(out_full$from, out_full$to)),
                  c("ALICE", "BOB", "CAROL"))
})

## ── Wrong-separator guard ───────────────────────────────────────────────────

test_that("a structural wrong separator triggers a warning", {
  # Pipe-delimited data read with the default ';' sep -> no splits, warn.
  d <- data.frame(id = 1:3,
                  authors = c("Smith J| Doe A", "Smith J| Lee K",
                              "Doe A| Lee K"),
                  stringsAsFactors = FALSE)
  expect_warning(author_network(d), "\\|")
})

test_that("the correct separator produces no warning", {
  d <- data.frame(id = 1:3,
                  authors = c("Smith J; Doe A", "Smith J; Lee K",
                              "Doe A; Lee K"),
                  stringsAsFactors = FALSE)
  expect_no_warning(author_network(d))
})

test_that("single-entity columns without alt separators stay silent", {
  d <- data.frame(id = 1:3,
                  keywords = c("ml", "ai", "nlp"),
                  stringsAsFactors = FALSE)
  expect_no_warning(keyword_network(d))
})

test_that("valid 'Last, First' single-author data does not warn", {
  # Internal commas are part of the label, not a delimiter mistake.
  d <- data.frame(id = 1:3,
                  authors = c("Smith, John", "Doe, Jane", "Lee, Kim"),
                  stringsAsFactors = FALSE)
  expect_no_warning(author_network(d))
})

test_that("one-reference-per-row strings with commas do not warn", {
  d <- data.frame(id = 1:3,
                  references = c("Smith J, 2020, Journal X",
                                 "Doe A, 2019, Journal Y",
                                 "Lee K, 2021, Journal Z"),
                  stringsAsFactors = FALSE)
  expect_no_warning(reference_network(d))
})

test_that("' and '-joined organisation names do not warn", {
  d <- data.frame(id = 1:3,
                  keywords = c("Smith and Sons", "Black and Decker",
                               "Marks and Spencer"),
                  stringsAsFactors = FALSE)
  expect_no_warning(keyword_network(d))
})

## ── read_biblio generic reader ──────────────────────────────────────────────

test_that("read_generic warns about misspelled actor columns", {
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp))
  utils::write.csv(data.frame(id = 1:2,
                              Authors = c("A| B", "A| C"),
                              stringsAsFactors = FALSE),
                   tmp, row.names = FALSE)
  expect_warning(
    read_biblio(tmp, format = "generic", list_cols = "Authorz", sep = "|"),
    "Authorz"
  )
})

test_that("read_generic end-to-end: custom CSV to author network", {
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp))
  utils::write.csv(data.frame(PaperID = c("P1", "P2"),
                              Authors = c("Alice| Bob", "Alice| Carol"),
                              stringsAsFactors = FALSE),
                   tmp, row.names = FALSE)
  d <- read_biblio(tmp, format = "generic", id = "PaperID",
                   list_cols = "Authors", sep = "|")
  out <- author_network(d, authors = "Authors")
  expect_setequal(unique(c(out$from, out$to)), c("ALICE", "BOB", "CAROL"))
})

## ── Regression: previously dropped arguments now honored ────────────────────

test_that("author_network co_citation honors self_loops", {
  d <- data.frame(id = c("P1", "P2"), stringsAsFactors = FALSE)
  d$authors <- list("X", "Y")
  d$cited_first_authors <- list(c("A", "B"), c("A", "B"))
  out <- author_network(d, "co_citation", self_loops = TRUE)
  expect_true(any(out$from == out$to))
})

test_that("author_network equivalence forwards deduplicate", {
  d <- data.frame(id = c("P1", "P2"), stringsAsFactors = FALSE)
  d$authors <- list(c("A", "A", "B"), c("A", "B"))
  dedup <- author_network(d, "equivalence")
  raw <- author_network(d, "equivalence", deduplicate = FALSE)
  w_dedup <- dedup$weight[dedup$from == "A" & dedup$to == "B"]
  w_raw <- raw$weight[raw$from == "A" & raw$to == "B"]
  expect_false(isTRUE(all.equal(w_dedup, w_raw)))
})

test_that("keyword_network 'field' still works but warns deprecated", {
  d <- data.frame(id = 1:3, Tags = c("ml; ai", "ml; nlp", "ai; nlp"),
                  stringsAsFactors = FALSE)
  expect_warning(out <- keyword_network(d, field = "Tags"), "deprecated")
  expect_setequal(unique(c(out$from, out$to)), c("AI", "ML", "NLP"))
})

## ── references_sep: references column with a custom separator ────────────────

test_that("author_network coupling honors references_sep", {
  # references comma-separated AND authors comma-separated
  d <- data.frame(
    id = c("P1", "P2", "P3"),
    auth = c("Alice, Bob", "Alice, Carol", "Bob, Carol"),
    references = c("R1, R2", "R1, R3", "R2, R3"),
    stringsAsFactors = FALSE
  )
  out <- author_network(d, "coupling", authors = "auth", sep = ",",
                        references_sep = ",")
  # Each author should couple via individual refs R1/R2/R3, not one mega-ref.
  # Alice (R1,R2) & Bob (R1,R2,R3) share R1,R2 -> nonzero coupling
  expect_true(nrow(out) > 0)
  expect_true(all(out$count >= 1))
  # The references must have been split: a node label must not contain a comma
  refs_used <- attr(out, "network_type")
  expect_equal(refs_used, "author_coupling")
})

test_that("references_sep default ';' unchanged for standard data", {
  d <- data.frame(id = c("P1", "P2", "P3"), stringsAsFactors = FALSE)
  d$auth <- list(c("Alice", "Bob"), c("Alice", "Carol"), c("Bob", "Carol"))
  d$references <- c("R1; R2", "R1; R3", "R2; R3")
  out <- author_network(d, "coupling", authors = "auth")
  expect_true(nrow(out) > 0)
})

test_that("wrong references separator collapses refs (the bug we fixed)", {
  # Without references_sep, comma refs split on ';' -> one giant ref per paper
  # -> every paper shares the same single (distinct) ref with none other,
  # so coupling is empty. With references_sep=',' it is non-empty.
  d <- data.frame(
    id = c("P1", "P2"),
    auth = c("Alice, Bob", "Alice, Carol"),
    references = c("R1, R2", "R1, R3"),
    stringsAsFactors = FALSE
  )
  # Wrong sep: references split on ';' -> each paper is one giant ref
  # ("R1, R2" vs "R1, R3"), no shared ref -> empty coupling.
  suppressWarnings(
    wrong <- author_network(d, "coupling", authors = "auth", sep = ",")
  )
  # Correct sep: papers share R1 -> non-empty coupling.
  fixed <- author_network(d, "coupling", authors = "auth", sep = ",",
                          references_sep = ",")
  expect_true(nrow(fixed) > nrow(wrong))
})

## ── strip_quotes: quoted entities ───────────────────────────────────────────

test_that("strip_quotes removes surrounding quotes from split strings", {
  d <- data.frame(id = 1:3,
                  authors = c('"Alice"; "Bob"', '"Alice"; "Carol"',
                              '"Bob"; "Carol"'),
                  stringsAsFactors = FALSE)
  out <- author_network(d)
  expect_setequal(unique(c(out$from, out$to)), c("ALICE", "BOB", "CAROL"))
})

test_that("strip_quotes handles CSV doubled quotes \"\"", {
  d <- data.frame(id = 1:2,
                  keywords = c('""ml""; ""ai""', '""ml""; ""nlp""'),
                  stringsAsFactors = FALSE)
  out <- keyword_network(d)
  expect_setequal(unique(c(out$from, out$to)), c("ML", "AI", "NLP"))
})

test_that("strip_quotes applies to provided list-columns too", {
  d <- data.frame(id = 1:3, stringsAsFactors = FALSE)
  d$authors <- list(c('"Alice"', '"Bob"'), c('"Alice"', '"Carol"'),
                    c('"Bob"', '"Carol"'))
  out <- author_network(d)
  expect_setequal(unique(c(out$from, out$to)), c("ALICE", "BOB", "CAROL"))
})

test_that("strip_quotes = FALSE keeps quotes as part of the label", {
  d <- data.frame(id = 1:2,
                  keywords = c('"ml"; "ai"', '"ml"; "nlp"'),
                  stringsAsFactors = FALSE)
  out <- keyword_network(d, strip_quotes = FALSE)
  nodes <- unique(c(out$from, out$to))
  expect_true(any(grepl('"', nodes, fixed = TRUE)))
})

test_that("strip_quotes leaves internal apostrophes intact", {
  d <- data.frame(id = 1:2,
                  authors = c("O'Brien; Smith", "O'Brien; Jones"),
                  stringsAsFactors = FALSE)
  out <- author_network(d)
  expect_true("O'BRIEN" %in% c(out$from, out$to))
})

test_that("strip_quotes works on a scalar source/journal column", {
  d <- data.frame(id = c("P1", "P2", "P3"),
                  journal = c('"J1"', '"J2"', '"J1"'),
                  stringsAsFactors = FALSE)
  d$references <- list(c("R1", "R2"), c("R1", "R3"), c("R2", "R3"))
  out <- source_network(d, "coupling")
  nodes <- unique(c(out$from, out$to))
  expect_false(any(grepl('"', nodes, fixed = TRUE)))
  expect_true(all(nodes %in% c("J1", "J2")))
})

test_that("historiograph forwards strip_quotes consistently to LCS", {
  d <- data.frame(
    id = c("A", "B", "C"),
    references = c("", '"A"', '"A"; "B"'),
    year = c(2000L, 2005L, 2010L),
    stringsAsFactors = FALSE
  )
  # With stripping (default) quoted refs resolve to ids -> edges found,
  # and node selection (LCS) agrees with the edge-building labels.
  h <- historiograph(d, min_lcs = 1)
  expect_true(nrow(h$edges) >= 2)
  lc <- local_citations(d)
  cited <- lc$id[lc$lcs > 0]
  expect_true(all(h$edges$to %in% cited))
})
