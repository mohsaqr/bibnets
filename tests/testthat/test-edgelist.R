## Tests for internal helpers in R/edgelist.R
## Functions: mat_to_edgelist(), edgelist_to_mat()
##
## Use bibnets:::name so file_coverage() can instrument the source file
## directly without depending on exported wrappers.

library(Matrix)

# ── helpers ────────────────────────────────────────────────────────────────────

make_sym_mat <- function() {
  ## 3 x 3 named symmetric sparse matrix
  A <- Matrix::sparseMatrix(
    i = c(1, 1, 2, 2, 3, 3),
    j = c(2, 3, 1, 3, 1, 2),
    x = c(5, 3, 5, 2, 3, 2),
    dims = c(3L, 3L),
    dimnames = list(c("A", "B", "C"), c("A", "B", "C"))
  )
  A
}

make_dir_mat <- function() {
  ## Asymmetric: A->B=5, B->C=2 (upper ≠ lower)
  A <- Matrix::sparseMatrix(
    i = c(1, 2),
    j = c(2, 3),
    x = c(5, 2),
    dims = c(3L, 3L),
    dimnames = list(c("A", "B", "C"), c("A", "B", "C"))
  )
  A
}

make_edges <- function() {
  data.frame(
    from   = c("A", "A", "B"),
    to     = c("B", "C", "C"),
    weight = c(5,   3,   2),
    stringsAsFactors = FALSE
  )
}

# ── mat_to_edgelist ────────────────────────────────────────────────────────────

test_that("mat_to_edgelist returns data.frame with from/to/weight columns", {
  A   <- make_sym_mat()
  out <- bibnets:::mat_to_edgelist(A)
  expect_true(is.data.frame(out))
  expect_true(all(c("from", "to", "weight") %in% names(out)))
})

test_that("mat_to_edgelist undirected returns only upper triangle", {
  A   <- make_sym_mat()
  out <- bibnets:::mat_to_edgelist(A, directed = FALSE)
  ## Upper triangle for 3 nodes has 3 pairs: A-B, A-C, B-C
  expect_equal(nrow(out), 3L)
  ## Every from should be alphabetically less than to (upper triangle)
  expect_true(all(out$from < out$to))
})

test_that("mat_to_edgelist directed returns all non-diagonal non-zero entries", {
  A   <- make_sym_mat()        # symmetric: 6 off-diagonal entries
  out <- bibnets:::mat_to_edgelist(A, directed = TRUE)
  expect_equal(nrow(out), 6L)
})

test_that("mat_to_edgelist weights are correct", {
  A   <- make_sym_mat()
  out <- bibnets:::mat_to_edgelist(A, directed = FALSE)
  w_AB <- out$weight[out$from == "A" & out$to == "B"]
  w_AC <- out$weight[out$from == "A" & out$to == "C"]
  w_BC <- out$weight[out$from == "B" & out$to == "C"]
  expect_equal(w_AB, 5)
  expect_equal(w_AC, 3)
  expect_equal(w_BC, 2)
})

test_that("mat_to_edgelist is sorted descending by weight", {
  A   <- make_sym_mat()
  out <- bibnets:::mat_to_edgelist(A, directed = FALSE)
  expect_equal(out$weight, sort(out$weight, decreasing = TRUE))
})

test_that("mat_to_edgelist preserves named nodes", {
  A   <- make_sym_mat()
  out <- bibnets:::mat_to_edgelist(A)
  expect_true(all(out$from %in% c("A", "B", "C")))
  expect_true(all(out$to   %in% c("A", "B", "C")))
})

test_that("mat_to_edgelist generates integer names when dimnames NULL", {
  A <- Matrix::sparseMatrix(
    i = c(1, 1), j = c(2, 3), x = c(4, 2),
    dims = c(3L, 3L)
    ## no dimnames
  )
  out <- bibnets:::mat_to_edgelist(A, directed = FALSE)
  expect_equal(nrow(out), 2L)
  expect_true(all(out$from %in% c("1", "2", "3")))
  expect_true(all(out$to   %in% c("1", "2", "3")))
})

test_that("mat_to_edgelist empty sparse matrix returns 0-row data frame", {
  A <- Matrix::sparseMatrix(i = integer(0), j = integer(0), x = numeric(0),
                            dims = c(3L, 3L),
                            dimnames = list(c("A","B","C"), c("A","B","C")))
  out <- bibnets:::mat_to_edgelist(A, directed = FALSE)
  expect_equal(nrow(out), 0L)
  expect_true(all(c("from", "to", "weight") %in% names(out)))
})

test_that("mat_to_edgelist diagonal-only sparse matrix returns 0-row data frame", {
  ## Only diagonal: after removing diagonal, nothing remains
  A <- Matrix::sparseMatrix(i = c(1, 2), j = c(1, 2), x = c(9, 7),
                            dims = c(3L, 3L),
                            dimnames = list(c("A","B","C"), c("A","B","C")))
  out <- bibnets:::mat_to_edgelist(A, directed = FALSE)
  expect_equal(nrow(out), 0L)
})

test_that("mat_to_edgelist single-edge sparse matrix works", {
  A <- Matrix::sparseMatrix(i = c(1, 2), j = c(2, 1), x = c(7, 7),
                            dims = c(2L, 2L),
                            dimnames = list(c("X", "Y"), c("X", "Y")))
  out <- bibnets:::mat_to_edgelist(A, directed = FALSE)
  expect_equal(nrow(out), 1L)
  expect_equal(out$weight, 7)
})

test_that("mat_to_edgelist directed single-edge matrix returns two rows", {
  A <- Matrix::sparseMatrix(i = c(1, 2), j = c(2, 1), x = c(7, 7),
                            dims = c(2L, 2L),
                            dimnames = list(c("X", "Y"), c("X", "Y")))
  out <- bibnets:::mat_to_edgelist(A, directed = TRUE)
  expect_equal(nrow(out), 2L)
})

test_that("mat_to_edgelist works on dense base matrix (non-Matrix branch)", {
  ## Dense path: inherits(A, "Matrix") is FALSE
  A <- matrix(c(0, 5, 3,
                5, 0, 2,
                3, 2, 0), nrow = 3, ncol = 3,
              dimnames = list(c("A", "B", "C"), c("A", "B", "C")))
  out <- bibnets:::mat_to_edgelist(A, directed = FALSE)
  expect_equal(nrow(out), 3L)
  expect_equal(out$weight[out$from == "A" & out$to == "B"], 5)
})

test_that("mat_to_edgelist dense all-zero matrix returns 0-row data frame", {
  A <- matrix(0, nrow = 3, ncol = 3,
              dimnames = list(c("A","B","C"), c("A","B","C")))
  out <- bibnets:::mat_to_edgelist(A, directed = FALSE)
  expect_equal(nrow(out), 0L)
  expect_true(all(c("from", "to", "weight") %in% names(out)))
})

test_that("mat_to_edgelist stopifnot fires on non-square matrix", {
  A <- matrix(1:6, nrow = 2, ncol = 3)
  expect_error(bibnets:::mat_to_edgelist(A))
})

test_that("mat_to_edgelist directed asymmetric matrix returns only A->B (not B->A)", {
  A <- make_dir_mat()   # only A[1,2]=5, A[2,3]=2
  out_dir  <- bibnets:::mat_to_edgelist(A, directed = TRUE)
  out_undir <- bibnets:::mat_to_edgelist(A, directed = FALSE)
  ## directed: 2 entries
  expect_equal(nrow(out_dir), 2L)
  ## undirected: same 2 entries (already upper triangle)
  expect_equal(nrow(out_undir), 2L)
  expect_true(any(out_dir$from == "A" & out_dir$to == "B"))
})

# ── edgelist_to_mat ────────────────────────────────────────────────────────────

test_that("edgelist_to_mat returns dgCMatrix", {
  edges <- make_edges()
  A <- bibnets:::edgelist_to_mat(edges)
  expect_true(inherits(A, "dgCMatrix"))
})

test_that("edgelist_to_mat is square with correct dimensions", {
  edges <- make_edges()
  A <- bibnets:::edgelist_to_mat(edges)
  expect_equal(nrow(A), 3L)
  expect_equal(ncol(A), 3L)
})

test_that("edgelist_to_mat preserves dimnames derived from edges", {
  edges <- make_edges()
  A <- bibnets:::edgelist_to_mat(edges)
  expect_equal(sort(rownames(A)), c("A", "B", "C"))
  expect_equal(sort(colnames(A)), c("A", "B", "C"))
})

test_that("edgelist_to_mat symmetric=TRUE makes matrix symmetric", {
  edges <- make_edges()
  A <- bibnets:::edgelist_to_mat(edges, symmetric = TRUE)
  expect_equal(as.matrix(A), t(as.matrix(A)))
})

test_that("edgelist_to_mat symmetric=FALSE gives asymmetric matrix", {
  edges <- make_edges()   # upper-triangle edges only
  A <- bibnets:::edgelist_to_mat(edges, symmetric = FALSE)
  ## lower triangle is zero
  expect_equal(as.matrix(A)["B", "A"], 0)
  expect_equal(as.matrix(A)["A", "B"], 5)
})

test_that("edgelist_to_mat places weights at correct positions", {
  edges <- make_edges()
  A <- bibnets:::edgelist_to_mat(edges, symmetric = TRUE)
  m <- as.matrix(A)
  expect_equal(m["A", "B"], 5)
  expect_equal(m["A", "C"], 3)
  expect_equal(m["B", "C"], 2)
})

test_that("edgelist_to_mat diagonal is zero after symmetrization", {
  edges <- make_edges()
  A <- bibnets:::edgelist_to_mat(edges, symmetric = TRUE)
  m <- as.matrix(A)
  expect_equal(unname(diag(m)), c(0, 0, 0))
})

test_that("edgelist_to_mat accepts custom nodes vector", {
  edges <- make_edges()
  nodes <- c("A", "B", "C", "D")   # extra node not in edges
  A <- bibnets:::edgelist_to_mat(edges, nodes = nodes, symmetric = TRUE)
  expect_equal(nrow(A), 4L)
  expect_equal(ncol(A), 4L)
  expect_true("D" %in% rownames(A))
  ## D row and column should be all zero
  expect_equal(sum(as.matrix(A)["D", ]), 0)
})

test_that("edgelist_to_mat round-trip: edges -> mat -> edges matches original", {
  edges_in <- make_edges()
  A        <- bibnets:::edgelist_to_mat(edges_in, symmetric = TRUE)
  edges_out <- bibnets:::mat_to_edgelist(A, directed = FALSE)

  ## Same edge pairs (order may differ)
  pairs_in  <- paste(sort(edges_in$from), sort(edges_in$to),  sep = "-")
  pairs_out <- paste(sort(edges_out$from), sort(edges_out$to), sep = "-")
  expect_equal(sort(pairs_in), sort(pairs_out))

  ## Weights preserved for each pair
  for (i in seq_len(nrow(edges_in))) {
    f <- edges_in$from[i]; t_node <- edges_in$to[i]
    expected_w <- edges_in$weight[i]
    actual_w   <- edges_out$weight[edges_out$from == f & edges_out$to == t_node]
    if (length(actual_w) == 0)
      actual_w <- edges_out$weight[edges_out$from == t_node & edges_out$to == f]
    expect_equal(actual_w, expected_w)
  }
})

test_that("edgelist_to_mat single-edge round-trip", {
  edges <- data.frame(from = "X", to = "Y", weight = 3.5,
                      stringsAsFactors = FALSE)
  A   <- bibnets:::edgelist_to_mat(edges, symmetric = TRUE)
  out <- bibnets:::mat_to_edgelist(A, directed = FALSE)
  expect_equal(nrow(out), 1L)
  expect_equal(out$weight, 3.5)
  expect_true(all(sort(c(out$from, out$to)) == c("X", "Y")))
})
