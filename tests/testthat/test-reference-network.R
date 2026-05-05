test_that("reference_network co_citation with full counting", {
  d <- make_test_data()
  edges <- reference_network(d, min_occur = 1, threshold = 0)

  get_w <- function(a, b) {
    row <- edges[
      (edges$from == a & edges$to == b) |
      (edges$from == b & edges$to == a), ]
    if (nrow(row) == 0) return(0)
    row$weight[1]
  }

  ## R1-R2: cited together in W1, W2 -> 2
  ## R2-R3: cited together in W1, W3 -> 2
  ## R2-R4: cited together in W2, W3 -> 2
  expect_equal(get_w("R1", "R2"), 2)
  expect_equal(get_w("R2", "R3"), 2)
  expect_equal(get_w("R2", "R4"), 2)
  expect_equal(get_w("R1", "R3"), 1)
})

test_that("reference_network with association strength", {
  d <- make_test_data()
  edges <- reference_network(d, similarity = "association", threshold = 0)

  expect_true(all(edges$weight > 0))
  expect_true(all(is.finite(edges$weight)))
})

test_that("reference_network strength counting is finite in column mode", {
  d <- data.frame(id = paste0("W", 1:4), stringsAsFactors = FALSE)
  d$references <- list(
    c("R1", "R2", "R3", "R4", "R5"),
    c("R1", "R2"),
    c("R1", "R3"),
    c("R2", "R3")
  )

  edges <- reference_network(d, counting = "strength", threshold = 0)

  expect_gt(nrow(edges), 0L)
  expect_false(anyNA(edges$weight))
  expect_true(all(is.finite(edges$weight)))
})
