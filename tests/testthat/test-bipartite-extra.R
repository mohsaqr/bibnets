## Extra tests for R/bipartite.R — targets build_bipartite_long() and
## edge-case branches of build_bipartite() to raise coverage from 53.57% → ≥85%.
##
## All tests run under devtools::test() which exposes internal functions.

# ── build_bipartite_long() — basic usage ────────────────────────────────────

test_that("build_bipartite_long returns a dgCMatrix with correct dims", {
  edges <- data.frame(
    source = c("W1", "W1", "W2", "W3"),
    target = c("R1", "R2", "R1", "R3"),
    stringsAsFactors = FALSE
  )
  B <- build_bipartite_long(edges)

  expect_true(is(B, "dgCMatrix"))
  expect_equal(nrow(B), 3L)   # W1, W2, W3
  expect_equal(ncol(B), 3L)   # R1, R2, R3
})

test_that("build_bipartite_long uppercases and trims row/col names", {
  edges <- data.frame(
    source = c("  w1 ", "w2"),
    target = c("  r1 ", "r2"),
    stringsAsFactors = FALSE
  )
  B <- build_bipartite_long(edges)

  expect_equal(rownames(B), c("W1", "W2"))
  expect_equal(colnames(B), c("R1", "R2"))
})

test_that("build_bipartite_long assigns 1s in correct cells", {
  edges <- data.frame(
    source = c("A", "A", "B"),
    target = c("X", "Y", "X"),
    stringsAsFactors = FALSE
  )
  B <- build_bipartite_long(edges)

  # rows sorted: A, B; cols sorted: X, Y
  expect_equal(as.numeric(B["A", ]), c(1, 1))
  expect_equal(as.numeric(B["B", ]), c(1, 0))
})

test_that("build_bipartite_long sorts row and column names lexicographically", {
  edges <- data.frame(
    source = c("W3", "W1", "W2"),
    target = c("RC", "RA", "RB"),
    stringsAsFactors = FALSE
  )
  B <- build_bipartite_long(edges)

  expect_equal(rownames(B), c("W1", "W2", "W3"))
  expect_equal(colnames(B), c("RA", "RB", "RC"))
})

# ── build_bipartite_long() — min_freq filtering ─────────────────────────────

test_that("build_bipartite_long filters targets by min_freq", {
  edges <- data.frame(
    source = c("W1", "W2", "W3", "W4"),
    target = c("R1", "R1", "R2", "R3"),
    stringsAsFactors = FALSE
  )
  # R1 appears 2×, R2 1×, R3 1×
  B2 <- build_bipartite_long(edges, min_freq = 2L)

  expect_equal(ncol(B2), 1L)
  expect_equal(colnames(B2), "R1")
})

test_that("build_bipartite_long min_freq=1 keeps all targets", {
  edges <- data.frame(
    source = c("W1", "W2", "W3"),
    target = c("R1", "R2", "R3"),
    stringsAsFactors = FALSE
  )
  B <- build_bipartite_long(edges, min_freq = 1L)
  expect_equal(ncol(B), 3L)
})

test_that("build_bipartite_long min_freq=3 keeps only targets appearing 3+ times", {
  edges <- data.frame(
    source = c("W1", "W2", "W3", "W4", "W5"),
    target = c("R1", "R1", "R1", "R2", "R2"),
    stringsAsFactors = FALSE
  )
  B3 <- build_bipartite_long(edges, min_freq = 3L)
  expect_equal(ncol(B3), 1L)
  expect_equal(colnames(B3), "R1")
})

# ── build_bipartite_long() — NA / empty handling ────────────────────────────

test_that("build_bipartite_long drops rows where source or target is NA", {
  edges <- data.frame(
    source = c("W1", NA_character_,  "W3"),
    target = c("R1", "R2",           NA_character_),
    stringsAsFactors = FALSE
  )
  B <- build_bipartite_long(edges)

  # Only W1→R1 survives
  expect_equal(nrow(B), 1L)
  expect_equal(ncol(B), 1L)
  expect_equal(rownames(B), "W1")
  expect_equal(colnames(B), "R1")
})

test_that("build_bipartite_long drops rows with empty-string source or target", {
  edges <- data.frame(
    source = c("W1", "",  "W3"),
    target = c("",   "R2", "R3"),
    stringsAsFactors = FALSE
  )
  B <- build_bipartite_long(edges)

  # W1→"" and ""→R2 are both dropped; only W3→R3 survives
  expect_equal(nrow(B), 1L)
  expect_equal(rownames(B), "W3")
  expect_equal(colnames(B), "R3")
})

# ── build_bipartite_long() — error paths ────────────────────────────────────

test_that("build_bipartite_long errors when 'source' column is missing", {
  bad <- data.frame(from = "W1", target = "R1", stringsAsFactors = FALSE)
  expect_error(build_bipartite_long(bad))
})

test_that("build_bipartite_long errors when 'target' column is missing", {
  bad <- data.frame(source = "W1", to = "R1", stringsAsFactors = FALSE)
  expect_error(build_bipartite_long(bad))
})

test_that("build_bipartite_long errors when input is not a data frame", {
  expect_error(build_bipartite_long(list(source = "W1", target = "R1")))
})

# ── build_bipartite_long() — single-row edge ────────────────────────────────

test_that("build_bipartite_long handles a single-row input", {
  edges <- data.frame(source = "W1", target = "R1", stringsAsFactors = FALSE)
  B <- build_bipartite_long(edges)

  expect_equal(dim(B), c(1L, 1L))
  expect_equal(B[1L, 1L], 1)
})

# ── build_bipartite_long() — many-to-one / one-to-many ──────────────────────

test_that("build_bipartite_long handles multiple sources sharing same target", {
  edges <- data.frame(
    source = c("W1", "W2", "W3"),
    target = c("R1", "R1", "R1"),
    stringsAsFactors = FALSE
  )
  B <- build_bipartite_long(edges)

  expect_equal(ncol(B), 1L)
  expect_equal(sum(B), 3)   # each source has one 1
})

test_that("build_bipartite_long handles one source pointing to many targets", {
  edges <- data.frame(
    source = c("W1", "W1", "W1"),
    target = c("R1", "R2", "R3"),
    stringsAsFactors = FALSE
  )
  B <- build_bipartite_long(edges)

  expect_equal(nrow(B), 1L)
  expect_equal(sum(B["W1", ]), 3)
})

# ── build_bipartite() — deduplicate = FALSE ──────────────────────────────────
# (the TRUE branch is already covered 135× by existing tests; FALSE is new)

test_that("build_bipartite deduplicate=FALSE keeps repeated (paper, entity) pairs", {
  d <- data.frame(id = "W1", stringsAsFactors = FALSE)
  d$kw <- list(c("ML", "ML", "DL"))  # ML appears twice

  B_dup   <- build_bipartite(d, "kw", deduplicate = FALSE)
  B_dedup <- build_bipartite(d, "kw", deduplicate = TRUE)

  # With dedup TRUE: ML=1, DL=1 (binary)
  expect_equal(as.numeric(B_dedup["W1", "ML"]), 1)
  # With dedup FALSE: ML=2, DL=1 (counts raw occurrences)
  expect_equal(as.numeric(B_dup["W1", "ML"]), 2)
  expect_equal(as.numeric(B_dup["W1", "DL"]), 1)
})

test_that("build_bipartite deduplicate=FALSE with no repeats matches deduplicate=TRUE", {
  d <- data.frame(id = c("W1", "W2"), stringsAsFactors = FALSE)
  d$kw <- list(c("A", "B"), c("B", "C"))

  B_t <- build_bipartite(d, "kw", deduplicate = TRUE)
  B_f <- build_bipartite(d, "kw", deduplicate = FALSE)

  expect_equal(as.matrix(B_t), as.matrix(B_f))
})

# ── build_bipartite() — ensure_list_column auto-split ───────────────────────

test_that("build_bipartite auto-splits semicolon-delimited character column", {
  d <- data.frame(
    id  = c("W1", "W2"),
    kw  = c("ML; DL", "NLP; CV; ML"),
    stringsAsFactors = FALSE
  )
  # kw is a plain character vector, not a list
  B <- build_bipartite(d, "kw")

  expect_true(is(B, "dgCMatrix"))
  # Uppercased entities: CV, DL, ML, NLP
  expect_true("ML" %in% colnames(B))
  expect_true("DL" %in% colnames(B))
  expect_equal(ncol(B), 4L)
  expect_equal(as.numeric(B["W1", "ML"]), 1)
  expect_equal(as.numeric(B["W2", "NLP"]), 1)
})

# ── build_bipartite() — edge cases ──────────────────────────────────────────

test_that("build_bipartite with min_freq=2 excludes singletons", {
  d <- data.frame(id = c("W1", "W2", "W3"), stringsAsFactors = FALSE)
  d$kw <- list(c("A", "B"), c("A", "C"), c("B", "D"))
  # A: 2, B: 2, C: 1, D: 1 -> keep A and B only

  B <- build_bipartite(d, "kw", min_freq = 2L)
  expect_equal(sort(colnames(B)), c("A", "B"))
})

test_that("build_bipartite with min_freq=3 keeps only universal entities", {
  d <- make_test_data()
  B <- build_bipartite(d, "references", min_freq = 3L)

  expect_equal(colnames(B), "R2")   # R2 is in all 3 papers
  expect_equal(nrow(B), 3L)
})

test_that("build_bipartite entity labels are always uppercased", {
  d <- data.frame(id = "W1", stringsAsFactors = FALSE)
  d$auth <- list(c("alice", "Bob", " CAROL "))

  B <- build_bipartite(d, "auth")
  expect_equal(sort(colnames(B)), c("ALICE", "BOB", "CAROL"))
})

test_that("build_bipartite errors when required column is missing", {
  d <- data.frame(id = "W1", stringsAsFactors = FALSE)
  expect_error(
    build_bipartite(d, "authors"),
    regexp = "authors"
  )
})

test_that("build_bipartite errors when 'id' column is missing", {
  d <- data.frame(authors = I(list(c("Alice"))), stringsAsFactors = FALSE)
  expect_error(
    build_bipartite(d, "authors"),
    regexp = "id"
  )
})

test_that("build_bipartite errors when data is not a data frame", {
  expect_error(
    build_bipartite(list(id = "W1", authors = list("Alice")), "authors"),
    regexp = "data frame"
  )
})

test_that("build_bipartite handles all-empty list-column entries gracefully", {
  d <- data.frame(id = c("W1", "W2"), stringsAsFactors = FALSE)
  d$kw <- list(character(0), character(0))

  B <- build_bipartite(d, "kw")
  expect_equal(ncol(B), 0L)
  expect_equal(nrow(B), 2L)
})

test_that("build_bipartite handles single-record input", {
  d <- data.frame(id = "W1", stringsAsFactors = FALSE)
  d$kw <- list(c("A", "B", "C"))

  B <- build_bipartite(d, "kw")
  expect_equal(nrow(B), 1L)
  expect_equal(ncol(B), 3L)
  expect_equal(sum(B), 3)
})

test_that("build_bipartite handles single entity per record", {
  d <- data.frame(id = c("W1", "W2"), stringsAsFactors = FALSE)
  d$kw <- list("X", "Y")

  B <- build_bipartite(d, "kw")
  expect_equal(nrow(B), 2L)
  expect_equal(ncol(B), 2L)
  expect_equal(sum(diag(as.matrix(B))), 2)
})
