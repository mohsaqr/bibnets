test_that("parse_names flips 'Last, First' to 'First Last'", {
  expect_equal(as.vector(parse_names("Saqr, Mohammed")), "Mohammed Saqr")
  expect_equal(
    as.vector(parse_names(c("Saqr, Mohammed", "Lopez-Pernas, Sonsoles"))),
    c("Mohammed Saqr", "Sonsoles Lopez-Pernas"))
})

test_that("parse_names strips periods from initials", {
  x <- parse_names("Saqr, M.")
  expect_equal(as.vector(x), "M Saqr")
  p <- attr(x, "parts")
  expect_equal(p$first, "M")
  expect_equal(p$last, "Saqr")
})

test_that("parse_names handles nobiliary particles", {
  expect_equal(as.vector(parse_names("van der Berg, Jan")), "Jan van der Berg")
  expect_equal(as.vector(parse_names("de la Cruz, Ana")), "Ana de la Cruz")
  expect_equal(as.vector(parse_names("von Neumann, John")), "John von Neumann")

  p <- attr(parse_names("van der Berg, Jan"), "parts")
  expect_equal(p$particle, "van der")
  expect_equal(p$last, "Berg")
  expect_equal(p$first, "Jan")
})

test_that("parse_names handles generational suffixes", {
  expect_equal(as.vector(parse_names("Smith, John, Jr.")), "John Smith Jr")
  expect_equal(as.vector(parse_names("Smith Jr, John")), "John Smith Jr")
  p <- attr(parse_names("Smith, John, Jr."), "parts")
  expect_equal(p$suffix, "Jr")
  expect_equal(p$last, "Smith")
})

test_that("parse_names does not eat single-letter initials as suffixes", {
  # bare "V" / "I" must not be treated as suffix
  p <- attr(parse_names("Wilson, V"), "parts")
  expect_equal(p$first, "V")
  expect_true(is.na(p$suffix))
})

test_that("parse_names leaves 'First Last' input unchanged", {
  expect_equal(as.vector(parse_names("Mohammed Saqr")), "Mohammed Saqr")
  p <- attr(parse_names("Mohammed Saqr"), "parts")
  expect_equal(p$first, "Mohammed")
  expect_equal(p$last, "Saqr")
  expect_equal(p$type, "person")
})

test_that("parse_names detects group/corporate authors", {
  orgs <- c("WHO Collaborating Group", "NEURO-ICU Study Group",
            "The Cancer Genome Atlas Network")
  out <- parse_names(orgs)
  expect_equal(as.vector(out), orgs)            # unchanged
  expect_true(all(attr(out, "parts")$type == "organization"))
  expect_true(all(is.na(attr(out, "parts")$first)))
})

test_that("parse_names preserves NA and empty strings", {
  out <- parse_names(c("Saqr, M.", NA, ""))
  expect_equal(as.vector(out), c("M Saqr", NA, ""))
  p <- attr(out, "parts")
  expect_equal(p$type, c("person", "missing", "empty"))
})

test_that("parse_names returns the 'parts' data frame with the right schema", {
  out <- parse_names(c("Saqr, Mohammed", "van der Berg, Jan"))
  p <- attr(out, "parts")
  expect_s3_class(p, "data.frame")
  expect_equal(names(p),
               c("original", "first", "last", "particle", "suffix", "type"))
  expect_equal(nrow(p), 2L)
  expect_equal(p$original, c("Saqr, Mohammed", "van der Berg, Jan"))
})

test_that("parse_names handles the empty vector", {
  out <- parse_names(character(0))
  expect_length(out, 0L)
  expect_equal(nrow(attr(out, "parts")), 0L)
})

test_that("parse_names rejects non-character input", {
  expect_error(parse_names(123), "must be a character vector")
  expect_error(parse_names(list("a")), "must be a character vector")
})

test_that("parse_names format = 'last_initials'", {
  expect_equal(
    as.vector(parse_names("Saqr, Mohammed", format = "last_initials")),
    "Saqr M.")
  expect_equal(
    as.vector(parse_names(
      c("van der Berg, Jan", "Smith, John, Jr.",
        "Garcia Marquez, Gabriel Jose"),
      format = "last_initials")),
    c("van der Berg J.", "Smith J. Jr", "Garcia Marquez G.J."))
  # no-comma personal input is reformatted from parsed parts
  expect_equal(
    as.vector(parse_names("Mohammed Saqr", format = "last_initials")),
    "Saqr M.")
})

test_that("parse_names format = 'last'", {
  expect_equal(
    as.vector(parse_names(
      c("Saqr, Mohammed", "van der Berg, Jan", "de la Cruz, Ana"),
      format = "last")),
    c("Saqr", "van der Berg", "de la Cruz"))
})

test_that("parse_names default format is 'first_last' (back-compatible)", {
  expect_equal(as.vector(parse_names("Saqr, Mohammed")),
               as.vector(parse_names("Saqr, Mohammed", format = "first_last")))
  expect_equal(as.vector(parse_names("Saqr, Mohammed")), "Mohammed Saqr")
})

test_that("parse_names leaves orgs / NA / empty unchanged in every format", {
  x <- c("WHO Collaborating Group", NA, "")
  for (f in c("first_last", "last_initials", "last")) {
    expect_equal(as.vector(parse_names(x, format = f)),
                 c("WHO Collaborating Group", NA, ""))
  }
})

test_that("parse_names rejects an unknown format", {
  expect_error(parse_names("Saqr, M.", format = "nope"))
})

test_that("parse_names 'parts' attribute is independent of format", {
  a <- attr(parse_names("van der Berg, Jan", format = "first_last"), "parts")
  b <- attr(parse_names("van der Berg, Jan", format = "last"), "parts")
  expect_equal(a, b)
})

test_that("parse_names auto-detects Scopus/bibnets surname-first labels", {
  out <- parse_names(c("WANG Y", "AYALA-ROMERO JA", "GARCIA-SAAVEDRA A"))
  expect_equal(as.vector(out),
               c("Y WANG", "JA AYALA-ROMERO", "A GARCIA-SAAVEDRA"))
  p <- attr(out, "parts")
  expect_equal(p$last, c("WANG", "AYALA-ROMERO", "GARCIA-SAAVEDRA"))
  expect_equal(p$first, c("Y", "J A", "A"))

  expect_equal(
    as.vector(parse_names(c("WANG Y", "AYALA-ROMERO JA"),
                          format = "last_initials")),
    c("WANG Y.", "AYALA-ROMERO J.A."))
  expect_equal(
    as.vector(parse_names("WANG Y", format = "last")), "WANG")
})

test_that("parse_names recognises particles in uppercase labels", {
  # bibnets uppercases entity labels; particles must still be detected
  out <- parse_names(c("VAN DER BERG J", "DE LA CRUZ, ANA"))
  expect_equal(as.vector(out), c("J VAN DER BERG", "ANA DE LA CRUZ"))
  p <- attr(out, "parts")
  expect_equal(p$particle, c("VAN DER", "DE LA"))
  expect_equal(p$last, c("BERG", "CRUZ"))
})

test_that("parse_names does not misread uppercase 'First Last' as surname-first", {
  # trailing token is >3 letters -> not initials -> given-first, unchanged
  out <- parse_names("MOHAMMED SAQR")
  expect_equal(as.vector(out), "MOHAMMED SAQR")
  p <- attr(out, "parts")
  expect_equal(p$first, "MOHAMMED")
  expect_equal(p$last, "SAQR")
})

test_that("parse_names mixed-case 'First Last' is unaffected by auto", {
  expect_equal(as.vector(parse_names("Mohammed Saqr")), "Mohammed Saqr")
  expect_equal(as.vector(parse_names("john li")), "john li")  # lowercase
})

test_that("parse_names surname_first override works (string and logical)", {
  expect_equal(as.vector(parse_names("Wang Yong", surname_first = "yes")),
               "Yong Wang")
  expect_equal(as.vector(parse_names("Wang Yong", surname_first = TRUE)),
               "Yong Wang")
  # force given-first: Scopus label returned unchanged
  expect_equal(as.vector(parse_names("WANG Y", surname_first = "no")),
               "WANG Y")
  expect_equal(as.vector(parse_names("WANG Y", surname_first = FALSE)),
               "WANG Y")
})

test_that("parse_names rejects an unknown surname_first", {
  expect_error(parse_names("WANG Y", surname_first = "maybe"))
})

test_that("parse_names is vectorised and length-stable", {
  x <- c("Saqr, M.", "Mohammed Saqr", "WHO Group", NA, "")
  out <- parse_names(x)
  expect_length(out, length(x))
  expect_equal(nrow(attr(out, "parts")), length(x))
})
