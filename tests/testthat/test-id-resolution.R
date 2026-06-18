test_that("resolve_id keeps an existing id column by default", {
  d <- data.frame(id = c("a", "b"), x = 1:2, stringsAsFactors = FALSE)
  out <- resolve_id(d)
  expect_identical(out$id, c("a", "b"))
})

test_that("resolve_id falls back to row numbers when id is absent", {
  d <- data.frame(x = 1:3, stringsAsFactors = FALSE)
  out <- resolve_id(d)
  expect_identical(out$id, c("1", "2", "3"))
})

test_that("resolve_id copies a named column to id", {
  d <- data.frame(paper_id = c("P1", "P2"), x = 1:2, stringsAsFactors = FALSE)
  out <- resolve_id(d, id = "paper_id")
  expect_identical(out$id, c("P1", "P2"))
})

test_that("resolve_id errors on a missing named column", {
  d <- data.frame(x = 1:2, stringsAsFactors = FALSE)
  expect_error(resolve_id(d, id = "nope"), "not found")
})

test_that("resolve_id errors on a non-scalar id", {
  d <- data.frame(x = 1:2, stringsAsFactors = FALSE)
  expect_error(resolve_id(d, id = c("a", "b")), "single column name")
})

test_that("resolve_id rejects a custom id that conflicts with an existing id column", {
  d <- data.frame(
    id       = c("keep", "this"),
    paper_id = c("P1", "P2"),
    stringsAsFactors = FALSE
  )
  expect_error(resolve_id(d, id = "paper_id"), "conflicts with the existing")
})

test_that("resolve_id does not overwrite a field column named 'id'", {
  # conetwork(field = "id", id = "paper_id") must keep the original id values
  d <- data.frame(
    id       = c("A; B", "B; C"),   # entity field happens to be named 'id'
    paper_id = c("P1", "P2"),
    stringsAsFactors = FALSE
  )
  expect_error(conetwork(d, "id", id = "paper_id"), "conflicts with the existing")
})

test_that("resolve_id accepts a custom id matching an identical existing id column", {
  d <- data.frame(
    id       = c("P1", "P2"),
    paper_id = c("P1", "P2"),       # same values -> no real conflict
    stringsAsFactors = FALSE
  )
  out <- resolve_id(d, id = "paper_id")
  expect_identical(out$id, c("P1", "P2"))
})

test_that("author_network builds without an id column (row-number fallback)", {
  no_id <- data.frame(
    `Author Names` = c("Smith J, Doe A", "Smith J, Lee K", "Doe A, Lee K"),
    check.names = FALSE, stringsAsFactors = FALSE
  )
  net <- author_network(no_id, authors = "Author Names", sep = ",")
  expect_s3_class(net, "bibnets_network")
  expect_setequal(unique(c(net$from, net$to)), c("DOE A", "LEE K", "SMITH J"))
})

test_that("author_network accepts a custom id column", {
  d <- data.frame(
    paper_id = c("P1", "P2", "P3"),
    auth     = c("Alice, Bob", "Alice, Carol", "Bob, Carol"),
    stringsAsFactors = FALSE
  )
  net <- author_network(d, authors = "auth", sep = ",", id = "paper_id")
  expect_setequal(unique(c(net$from, net$to)), c("ALICE", "BOB", "CAROL"))
})

test_that("id = NULL leaves an existing id column unchanged across builders", {
  data(biblio_data)
  with_id    <- author_network(biblio_data, "collaboration")
  expect_s3_class(with_id, "bibnets_network")
  expect_gt(nrow(with_id), 0)
})

test_that("keyword_network builds without an id column", {
  kw <- data.frame(
    Tags = c("ml, ai", "ml, nlp", "ai, nlp"),
    check.names = FALSE, stringsAsFactors = FALSE
  )
  net <- keyword_network(kw, keywords = "Tags", sep = ",")
  expect_setequal(unique(c(net$from, net$to)), c("AI", "ML", "NLP"))
})

test_that("conetwork accepts a custom id column", {
  d <- data.frame(
    doc = c("d1", "d2", "d3"),
    tags = c("a; b", "b; c", "a; c"),
    stringsAsFactors = FALSE
  )
  net <- conetwork(d, "tags", id = "doc")
  expect_setequal(unique(c(net$from, net$to)), c("A", "B", "C"))
})

test_that("split_field coerces a factor to character", {
  expect_identical(
    split_field(factor(c("a; b", "c; d"))),
    list(c("a", "b"), c("c", "d"))
  )
})

test_that("a factor entity column builds without error", {
  d <- data.frame(
    authors = factor(c("Alice; Bob", "Bob; Carol")),
    stringsAsFactors = FALSE
  )
  net <- author_network(d, authors = "authors")
  expect_setequal(unique(c(net$from, net$to)), c("ALICE", "BOB", "CAROL"))
})

test_that("local_citations resolves a custom id column", {
  d <- data.frame(
    docid = c("X1", "X2", "X3"),
    references = c("X2; X3", "X3", ""),
    stringsAsFactors = FALSE
  )
  lcs <- local_citations(d, id = "docid")
  expect_true("X3" %in% lcs$id)
  expect_equal(lcs$lcs[lcs$id == "X3"], 2)
})
