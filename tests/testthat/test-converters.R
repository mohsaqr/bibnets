## Tests for to_gephi(), to_graphml(), to_matrix()

make_small_edges <- function() {
  data.frame(
    from   = c("A", "A", "B"),
    to     = c("B", "C", "C"),
    weight = c(5,   3,   2),
    count  = c(2L,  1L,  1L),
    stringsAsFactors = FALSE
  )
}

## ── to_gephi ────────────────────────────────────────────────────────────────

test_that("to_gephi returns list with nodes and edges", {
  edges <- make_small_edges()
  g <- to_gephi(edges)

  expect_true(is.list(g))
  expect_true(all(c("nodes", "edges") %in% names(g)))
})

test_that("to_gephi edge table has Gephi column names", {
  edges <- make_small_edges()
  g <- to_gephi(edges)
  expect_true(all(c("Source", "Target", "Weight", "Type") %in% names(g$edges)))
})

test_that("to_gephi node table has Id and Label", {
  edges <- make_small_edges()
  g <- to_gephi(edges)
  expect_true(all(c("Id", "Label") %in% names(g$nodes)))
  expect_equal(sort(g$nodes$Id), c("A", "B", "C"))
})

test_that("to_gephi Type is Undirected by default", {
  edges <- make_small_edges()
  g <- to_gephi(edges)
  expect_true(all(g$edges$Type == "Undirected"))
})

test_that("to_gephi Type is Directed when directed=TRUE", {
  edges <- make_small_edges()
  g <- to_gephi(edges, directed = TRUE)
  expect_true(all(g$edges$Type == "Directed"))
})

test_that("to_gephi custom nodes table merges correctly", {
  edges <- make_small_edges()
  nodes <- data.frame(id = c("A","B","C"), group = c("g1","g1","g2"),
                       stringsAsFactors = FALSE)
  g <- to_gephi(edges, nodes = nodes)
  expect_true("group" %in% names(g$nodes))
  expect_equal(nrow(g$nodes), 3)
})

test_that("to_gephi $edges is a plain data.frame, not bibnets_network", {
  ## Regression: previously the renamed Source/Target/Weight columns kept
  ## the bibnets_network class, causing the S3 print method to look up
  ## the now-missing $from / $to / $weight and display NA NA NA.
  edges <- structure(make_small_edges(), class = c("bibnets_network", "data.frame"),
                     network_type = "test", counting = "full")
  g <- to_gephi(edges)
  expect_identical(class(g$edges), "data.frame")
  expect_null(attr(g$edges, "network_type"))
  expect_null(attr(g$edges, "counting"))
  ## Print must not produce any NA tokens for from/to/weight
  out <- capture.output(print(g$edges))
  expect_false(any(grepl("\\bNA\\b", out)))
})

test_that("to_gephi writes CSV files to disk", {
  edges <- make_small_edges()
  tmp <- tempdir()
  paths <- to_gephi(edges, file = tmp)
  expect_true(file.exists(file.path(tmp, "nodes.csv")))
  expect_true(file.exists(file.path(tmp, "edges.csv")))
  ## Clean up
  file.remove(file.path(tmp, "nodes.csv"), file.path(tmp, "edges.csv"))
})

## ── to_graphml ──────────────────────────────────────────────────────────────

test_that("to_graphml returns a character string", {
  edges <- make_small_edges()
  xml <- to_graphml(edges)
  expect_true(is.character(xml))
  expect_equal(length(xml), 1)
})

test_that("to_graphml output starts with XML declaration", {
  edges <- make_small_edges()
  xml <- to_graphml(edges)
  expect_true(startsWith(xml, "<?xml"))
})

test_that("to_graphml contains node and edge elements", {
  edges <- make_small_edges()
  xml <- to_graphml(edges)
  expect_true(grepl('<node id="A"', xml, fixed = TRUE))
  expect_true(grepl('<node id="B"', xml, fixed = TRUE))
  expect_true(grepl('<edge source="A" target="B"', xml, fixed = TRUE))
})

test_that("to_graphml includes edge weight", {
  edges <- make_small_edges()
  xml <- to_graphml(edges)
  expect_true(grepl('key="weight"', xml, fixed = TRUE))
})

test_that("to_graphml undirected by default", {
  edges <- make_small_edges()
  xml <- to_graphml(edges)
  expect_true(grepl('edgedefault="undirected"', xml, fixed = TRUE))
})

test_that("to_graphml directed when directed=TRUE", {
  edges <- make_small_edges()
  xml <- to_graphml(edges, directed = TRUE)
  expect_true(grepl('edgedefault="directed"', xml, fixed = TRUE))
})

test_that("to_graphml includes node attributes when nodes supplied", {
  edges <- make_small_edges()
  nodes <- data.frame(id = c("A","B","C"), community = c(1L, 1L, 2L),
                       stringsAsFactors = FALSE)
  xml <- to_graphml(edges, nodes = nodes)
  expect_true(grepl('attr.name="community"', xml, fixed = TRUE))
})

test_that("to_graphml writes to file", {
  edges <- make_small_edges()
  tmp <- tempfile(fileext = ".graphml")
  path <- to_graphml(edges, file = tmp)
  expect_true(file.exists(tmp))
  content <- readLines(tmp)
  expect_true(any(grepl("graphml", content)))
  file.remove(tmp)
})

test_that("to_graphml never emits literal NA in <data> tags", {
  ## Regression: previously NA edge attribute values produced
  ## <data key="weight">NA</data>, which downstream tools treat as a string.
  edges <- data.frame(
    from = c("A", "B"), to = c("B", "C"),
    weight = c(NA_real_, 2),
    count  = c(1L, NA_integer_),
    stringsAsFactors = FALSE
  )
  xml <- to_graphml(edges)
  expect_false(grepl(">NA<",     xml, fixed = TRUE))
  expect_false(grepl(">NA_real", xml, fixed = TRUE))
  ## Non-NA values still emitted
  expect_true(grepl('<data key="weight">2</data>', xml, fixed = TRUE))
  expect_true(grepl('<data key="count">1</data>',  xml, fixed = TRUE))
})

test_that("to_graphml skips NA node attributes when nodes table has them", {
  edges <- make_small_edges()
  nodes <- data.frame(id = c("A","B","C"),
                      community = c(1L, NA_integer_, 2L),
                      stringsAsFactors = FALSE)
  xml <- to_graphml(edges, nodes = nodes)
  ## Node B has NA community → no <data key="community"> tag for that node
  expect_false(grepl(">NA<", xml, fixed = TRUE))
})

test_that("to_graphml escapes special characters in node IDs", {
  edges <- data.frame(
    from   = c('Smith & Jones', 'Smith & Jones'),
    to     = c('Lee <2020>', 'Other'),
    weight = c(1, 1),
    stringsAsFactors = FALSE
  )
  xml <- to_graphml(edges)
  expect_true(grepl("&amp;", xml, fixed = TRUE))
  expect_true(grepl("&lt;",  xml, fixed = TRUE))
})

## ── to_matrix ───────────────────────────────────────────────────────────────

test_that("to_matrix returns a matrix or Matrix", {
  edges <- make_small_edges()
  m <- to_matrix(edges)
  ## Works with either base matrix or Matrix class
  expect_true(is.matrix(m) || inherits(m, "Matrix"))
})

test_that("to_matrix symmetric by default", {
  edges <- make_small_edges()
  m <- to_matrix(edges)
  m_dense <- as.matrix(m)
  expect_equal(m_dense, t(m_dense))
})

test_that("to_matrix has correct dimensions and values", {
  edges <- make_small_edges()
  m <- to_matrix(edges)
  m_dense <- as.matrix(m)
  expect_equal(nrow(m_dense), 3)
  expect_equal(ncol(m_dense), 3)
  expect_equal(m_dense["A", "B"], 5)
  expect_equal(m_dense["A", "C"], 3)
  expect_equal(m_dense["B", "C"], 2)
})
