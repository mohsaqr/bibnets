# Curated, base-R only. Lowercase nobiliary / patronymic particles that
# attach to a surname in scholarly metadata. Conservative on purpose:
# only well-established particles, so personal surnames are not
# accidentally split.
.bibnets_particles <- c(
  "van", "von", "der", "den", "ter", "ten", "te",
  "de", "del", "della", "dei", "di", "da", "do", "dos", "das", "du",
  "la", "le", "lo", "el", "al",
  "af", "av", "bin", "ibn", "y", "zu", "vom", "zum", "vander"
)

# Generational suffixes. Bare "I"/"V" are deliberately excluded — they
# collide with single-letter initials and would corrupt names.
.bibnets_suffix_re <- "^(jr|sr|ii|iii|iv|2nd|3rd|4th)$"

# Heuristic for non-personal (group / corporate) authors. If a comma-less
# name matches, it is returned unchanged and typed "organization".
.bibnets_org_re <- paste0(
  "\\b(group|grp|consortium|collaborat|team|network|initiative|",
  "committee|society|association|institut|organi[sz]ation|foundation|",
  "project|study|trial|cent(er|re)|laborator|college|university|",
  "department|division|hospital|ministry|agency|council|board|",
  "company|inc|ltd|llc|gmbh|corp|working)\\b"
)

# Map a recognised suffix token to a canonical display form.
.norm_suffix <- function(tok) {
  key <- tolower(gsub(".", "", tok, fixed = TRUE))
  switch(key,
    jr = "Jr", sr = "Sr", ii = "II", iii = "III", iv = "IV",
    `2nd` = "Jr", `3rd` = "III", `4th` = "IV", toupper(key))
}

# A token "looks like initials" if, ignoring dots/hyphens, it is 1-3
# letters AND entirely uppercase. The all-uppercase requirement is
# deliberate: it is the unambiguous signature of Scopus / bibnets
# surname-first labels ("WANG Y", "AYALA-ROMERO JA") and never matches a
# mixed-case given name ("Saqr"), so auto-detection cannot regress
# ordinary "First Last" input.
.looks_like_initials <- function(t) {
  t2 <- gsub("[^[:alpha:]]", "", t)
  nzchar(t2) && nchar(t2) <= 3L && t2 == toupper(t2)
}

# Parse a single name string into a record. Internal; see parse_names().
# surname_first is one of "auto", "yes", "no" and only affects
# comma-less strings (a comma always means "Last, First").
.parse_one_name <- function(s, surname_first = "auto") {
  na_rec <- list(display = NA_character_, first = NA_character_,
                  last = NA_character_, particle = NA_character_,
                  suffix = NA_character_, type = "missing")
  if (is.na(s)) return(na_rec)

  s <- trimws(gsub("\\s+", " ", s))
  if (!nzchar(s)) {
    na_rec$display <- ""
    na_rec$type <- "empty"
    return(na_rec)
  }

  has_comma <- grepl(",", s, fixed = TRUE)

  # Non-personal author: only inferred for comma-less strings (a
  # "Last, First" comma is a strong signal of a person).
  if (!has_comma && grepl(.bibnets_org_re, s, ignore.case = TRUE)) {
    return(list(display = s, first = NA_character_, last = NA_character_,
                particle = NA_character_, suffix = NA_character_,
                type = "organization"))
  }

  no_dots <- function(t) gsub(".", "", t, fixed = TRUE)

  # Leading run of particle tokens within a surname token vector.
  # Case-insensitive: bibnets uppercases entity labels, so "DE LA CRUZ"
  # and "VAN DER BERG" must still have their particles recognised.
  leading_particles <- function(tok) {
    if (!length(tok)) return(integer(0))
    is_p <- tolower(tok) %in% .bibnets_particles
    which(cumprod(is_p) == 1L)
  }

  if (has_comma) {
    comp <- trimws(strsplit(s, ",", fixed = TRUE)[[1]])
    comp <- comp[nzchar(comp)]
    last_field <- comp[1]
    rest <- if (length(comp) > 1) comp[-1] else character(0)

    suffix <- NA_character_
    if (length(rest)) {
      tail_c <- rest[length(rest)]
      if (grepl(.bibnets_suffix_re, no_dots(tolower(tail_c)))) {
        suffix <- .norm_suffix(tail_c)
        rest <- rest[-length(rest)]
      }
    }
    given <- if (length(rest)) paste(rest, collapse = " ") else ""

    lf_tok <- strsplit(last_field, " ", fixed = TRUE)[[1]]
    lf_tok <- lf_tok[nzchar(lf_tok)]
    # Suffix sometimes trails the surname field ("Smith Jr, John").
    if (length(lf_tok) > 1 &&
        grepl(.bibnets_suffix_re, no_dots(tolower(lf_tok[length(lf_tok)])))) {
      suffix <- .norm_suffix(lf_tok[length(lf_tok)])
      lf_tok <- lf_tok[-length(lf_tok)]
    }

    p_idx <- leading_particles(lf_tok)
    particle <- if (length(p_idx))
      paste(lf_tok[p_idx], collapse = " ") else NA_character_
    last <- paste(lf_tok[setdiff(seq_along(lf_tok), p_idx)], collapse = " ")
    first <- no_dots(given)
    first <- if (nzchar(trimws(first))) trimws(first) else NA_character_

    pieces <- c(first, particle, last, suffix)
    display <- paste(pieces[!is.na(pieces) & nzchar(pieces)], collapse = " ")
    return(list(display = display, first = first,
                last = if (nzchar(last)) last else NA_character_,
                particle = particle, suffix = suffix, type = "person"))
  }

  # ---- No comma ----------------------------------------------------------
  tok <- strsplit(s, " ", fixed = TRUE)[[1]]
  tok <- tok[nzchar(tok)]
  suffix <- NA_character_
  if (length(tok) > 1 &&
      grepl(.bibnets_suffix_re, no_dots(tolower(tok[length(tok)])))) {
    suffix <- .norm_suffix(tok[length(tok)])
    tok <- tok[-length(tok)]
  }
  if (length(tok) <= 1) {
    return(list(display = s, first = NA_character_,
                last = if (length(tok)) no_dots(tok) else NA_character_,
                particle = NA_character_, suffix = suffix,
                type = "person"))
  }

  # Decide whether the surname comes first. A comma-less string is one of
  # three conventions and the trailing token disambiguates:
  #   "First Last"            -> given-first   (e.g. "Mohammed Saqr")
  #   "SURNAME Initials"      -> surname-first (e.g. "WANG Y", Scopus/bibnets)
  #   "Surname Given"         -> surname-first (only via surname_first="yes")
  # auto: surname-first iff the trailing token looks like initials. This
  # is the bibnets-takes-precedence bias — bibnets/Scopus author labels
  # are surname-first uppercase initials, so they parse correctly without
  # the caller doing anything.
  sf <- switch(surname_first,
    yes = TRUE,
    no  = FALSE,
    auto = .looks_like_initials(tok[length(tok)]))

  if (sf) {
    # Maximal trailing run of initials-looking tokens is the given part;
    # everything before it is the surname (with optional leading particle).
    is_ini <- vapply(tok, .looks_like_initials, logical(1))
    run <- rev(cumprod(rev(is_ini))) == 1L
    if (!any(run)) run[length(tok)] <- TRUE        # forced "yes", full given
    if (all(run))  run[seq_len(length(tok) - 1L)] <- FALSE  # keep >=1 surname
    given_tok   <- tok[run]
    surname_tok <- tok[!run]

    p_idx <- leading_particles(surname_tok)
    particle <- if (length(p_idx))
      paste(surname_tok[p_idx], collapse = " ") else NA_character_
    last <- paste(surname_tok[setdiff(seq_along(surname_tok), p_idx)],
                  collapse = " ")

    if (all(vapply(given_tok, .looks_like_initials, logical(1)))) {
      letters_v <- strsplit(gsub("[^[:alpha:]]", "",
                                 paste(given_tok, collapse = "")), "")[[1]]
      first   <- if (length(letters_v))
        paste(letters_v, collapse = " ") else NA_character_
      compact <- paste(letters_v, collapse = "")
    } else {
      first   <- no_dots(paste(given_tok, collapse = " "))
      compact <- first
    }

    surname_full <- trimws(paste(
      c(if (!is.na(particle)) particle, if (nzchar(last)) last),
      collapse = " "))
    pieces <- c(compact, surname_full, suffix)
    display <- paste(pieces[!is.na(pieces) & nzchar(pieces)], collapse = " ")
    return(list(display = display,
                first = if (!is.na(first) && nzchar(first)) first
                        else NA_character_,
                last = if (nzchar(last)) last else NA_character_,
                particle = particle, suffix = suffix, type = "person"))
  }

  # Given-first: assume "First [particle] Last". Returned unchanged in
  # first_last form; only break out the components.
  last <- tok[length(tok)]
  before <- tok[-length(tok)]
  is_p <- tolower(before) %in% .bibnets_particles
  trail <- rev(cumprod(rev(is_p))) == 1L
  particle <- if (any(trail))
    paste(before[trail], collapse = " ") else NA_character_
  first_v <- before[!trail]
  first <- if (length(first_v))
    no_dots(paste(first_v, collapse = " ")) else NA_character_
  list(display = s, first = first, last = last,
       particle = particle, suffix = suffix, type = "person")
}

# Build the output string for one parsed record in the requested style.
# Non-personal / empty / missing records are returned unchanged in every
# style (group authors must not be reformatted).
.format_name <- function(rec, format) {
  if (rec$type != "person") return(rec$display)

  surname <- trimws(paste(
    c(if (!is.na(rec$particle)) rec$particle,
      if (!is.na(rec$last)) rec$last),
    collapse = " "))

  if (format == "first_last") return(rec$display)
  if (format == "last")
    return(if (nzchar(surname)) surname else rec$display)

  # last_initials: "Saqr M.", "van der Berg J.", "Smith J. Jr"
  inits <- ""
  if (!is.na(rec$first) && nzchar(rec$first)) {
    toks <- strsplit(rec$first, "[ -]+")[[1]]
    toks <- toks[nzchar(toks)]
    inits <- paste0(toupper(substr(toks, 1, 1)), ".", collapse = "")
  }
  pieces <- c(surname, inits, if (!is.na(rec$suffix)) rec$suffix)
  pieces <- pieces[nzchar(pieces)]
  if (!length(pieces)) rec$display else paste(pieces, collapse = " ")
}

#' Reorder and parse author names
#'
#' Converts author names to `"First Last"` order and breaks each name
#' into its components. The parser is aware of nobiliary particles
#' (`van`, `von`, `de`, `del`, `da`, `der`, ...) and generational
#' suffixes (`Jr`, `Sr`, `II`, `III`, `IV`), and is case-insensitive so
#' it handles bibnets' uppercased entity labels.
#'
#' Three name conventions are recognised:
#' \itemize{
#'   \item `"Last, First"` (a comma) — always parsed as surname-then-given.
#'   \item `"SURNAME Initials"` (no comma, e.g. `"WANG Y"`,
#'     `"AYALA-ROMERO JA"`) — the Scopus / bibnets author-label form.
#'   \item `"First Last"` (no comma, e.g. `"Mohammed Saqr"`).
#' }
#' Comma-less strings that look like group or corporate authors
#' (e.g. `"WHO Collaborating Group"`) are detected and left untouched, as
#' are `NA` and empty strings.
#'
#' This is an optional, standalone utility. No reader or network builder
#' in `bibnets` calls it; entity labels are matched verbatim unless you
#' choose to apply this function yourself first.
#'
#' @param x Character vector of author names, one name per element.
#'   `NA` and empty strings are preserved.
#' @param format Output style for personal names (group/corporate
#'   authors, `NA`, and empty strings are returned unchanged in every
#'   style). One of:
#'   \describe{
#'     \item{`"first_last"`}{(default) `"Saqr, Mohammed"` ->
#'       `"Mohammed Saqr"`.}
#'     \item{`"last_initials"`}{`"Saqr, Mohammed"` -> `"Saqr M."`;
#'       multiple given names become concatenated initials
#'       (`"Garcia Marquez G.J."`); any suffix is appended
#'       (`"Smith J. Jr"`).}
#'     \item{`"last"`}{surname only, including any particle
#'       (`"van der Berg"`, `"de la Cruz"`).}
#'   }
#' @param surname_first How to read **comma-less** strings (strings with
#'   a comma are always `"Last, First"`). One of:
#'   \describe{
#'     \item{`"auto"`}{(default) surname-first when the trailing token
#'       looks like initials — an all-uppercase token of 1-3 letters,
#'       the Scopus / bibnets signature (`"WANG Y"` -> `"Y Wang"`'s
#'       components). Otherwise treated as `"First Last"`. This is the
#'       "bibnets takes precedence" bias: native bibnets/Scopus labels
#'       parse correctly with no extra arguments, while ordinary
#'       mixed-case `"First Last"` input is never misread.}
#'     \item{`"yes"`}{force surname-first (`"Wang Yong"` -> surname
#'       `Wang`, given `Yong`).}
#'     \item{`"no"`}{force given-first (`"First Last"`); comma-less input
#'       is returned unchanged.}
#'   }
#'   May also be given as the logical `TRUE` / `FALSE`. Inherently
#'   ambiguous input (e.g. uppercase `"MOHAMMED LI"`) follows the `auto`
#'   bias toward the bibnets/Scopus convention; pass `"no"` to override.
#' @return A character vector the same length as `x`, formatted per
#'   `format`. The parsed components are attached as the attribute
#'   `"parts"` (independent of `format`): a data frame with columns
#'   `original`, `first`, `last`, `particle`, `suffix`, and `type` (one
#'   of `"person"`, `"organization"`, `"empty"`, `"missing"`). Casing of
#'   the input is preserved; periods are stripped from parsed initials.
#' @details
#' # Input shape
#'
#' `parse_names()` takes a **flat character vector** (one name per
#' element) — not a data frame and not a list. bibnets readers store
#' authors as a **list-column** (each element is a character vector,
#' because a paper has a variable number of authors), so map the
#' function over it rather than passing the column directly:
#'
#' ```r
#' df$authors <- lapply(df$authors, parse_names, format = "last_initials")
#' ```
#'
#' For an ordinary flat character column (or the `from` / `to` columns of
#' a `bibnets_network`), call it directly: `parse_names(df$col)`.
#'
#' # Recommended workflow
#'
#' Normalise names **before** building a network, on the reader's
#' `authors` list-column. Node identity in bibnets is fixed when the
#' bipartite matrix is built (labels are upper-cased and matched
#' verbatim), so two spellings of one author (`"Saqr, Mohammed"` and
#' `"SAQR M"`) only merge into a single node if they are normalised
#' *before* `author_network()` is called:
#'
#' ```r
#' d <- read_biblio("scopus.csv")
#' d$authors <- lapply(d$authors, parse_names, format = "last_initials")
#' net <- author_network(d, type = "collaboration")
#' ```
#'
#' # Applying to an existing edgelist
#'
#' You *can* call `parse_names()` on the `from` / `to` (or
#' `source` / `target`) columns of a built network, but it is a
#' per-column, graph-blind relabelling: edges, pairing, `weight` and
#' `count` are preserved, **but**
#' \itemize{
#'   \item apply the *same call to both* endpoint columns or the two
#'     ends use different labels;
#'   \item the mapping is many-to-one, so distinct authors can collapse
#'     onto one label (especially with `"last_initials"`), and bibnets
#'     does **not** re-aggregate the resulting duplicate edges.
#' }
#' Prefer the pre-build workflow above.
#'
#' # Limitations
#'
#' Comma-less names are inherently ambiguous; the `auto` heuristic is
#' biased toward the bibnets/Scopus surname-first convention and may
#' misread uppercase `"GIVEN SURNAME"` where the surname is 1-3 letters
#' (e.g. `"MOHAMMED LI"`). Suffix-first garbage
#' (`"Jr., Sammy Davis"`) is not specially handled. Use `surname_first`
#' to force interpretation when you know the source convention.
#'
#' @seealso [author_network()] and [read_biblio()] for the upstream
#'   stage where normalisation is best applied.
#' @export
#' @examples
#' parse_names(c("Saqr, Mohammed", "Lopez-Pernas, Sonsoles"))
#'
#' # Alternative output styles
#' parse_names("Saqr, Mohammed", format = "last_initials")  # "Saqr M."
#' parse_names("Saqr, Mohammed", format = "last")            # "Saqr"
#' parse_names("van der Berg, Jan", format = "last_initials") # "van der Berg J."
#'
#' x <- parse_names("Saqr, M.")
#' x
#' attr(x, "parts")
#'
#' # Particles and suffixes
#' parse_names(c("van der Berg, Jan", "Smith, John, Jr.", "de la Cruz, Ana"))
#'
#' # Scopus / bibnets surname-first labels are detected automatically
#' parse_names(c("WANG Y", "AYALA-ROMERO JA", "VAN DER BERG J"))
#' parse_names("WANG Y", format = "last_initials")          # "WANG Y."
#'
#' # Override the auto heuristic when you know the convention
#' parse_names("Wang Yong", surname_first = "yes")          # "Yong Wang"
#'
#' # Group authors are detected and left unchanged
#' parse_names("WHO Collaborating Group")
#'
#' # Recommended workflow: normalise the authors list-column, then build
#' papers <- data.frame(id = c("P1", "P2", "P3"), stringsAsFactors = FALSE)
#' papers$authors <- list(
#'   c("Saqr, Mohammed", "Lopez, Ana"),
#'   c("SAQR M",         "Lopez, Ana"),
#'   c("Saqr, Mohammed", "Chen, Wei"))
#' papers$authors <- lapply(papers$authors, parse_names,
#'                          format = "last_initials")
#' net <- author_network(papers, type = "collaboration")
#' net
parse_names <- function(x,
                        format = c("first_last", "last_initials", "last"),
                        surname_first = c("auto", "yes", "no")) {
  if (!is.character(x)) {
    stop("'x' must be a character vector of author names, not ",
         class(x)[1], call. = FALSE)
  }
  format <- match.arg(format)
  if (is.logical(surname_first) && length(surname_first) == 1L &&
      !is.na(surname_first)) {
    surname_first <- if (surname_first) "yes" else "no"
  }
  surname_first <- match.arg(surname_first)
  if (length(x) == 0L) {
    out <- character(0)
    attr(out, "parts") <- data.frame(
      original = character(0), first = character(0), last = character(0),
      particle = character(0), suffix = character(0), type = character(0),
      stringsAsFactors = FALSE)
    return(out)
  }

  recs <- lapply(x, .parse_one_name, surname_first = surname_first)
  pick <- function(field) vapply(recs, `[[`, character(1), field)

  out <- vapply(recs, .format_name, character(1), format = format)
  attr(out, "parts") <- data.frame(
    original = x,
    first    = pick("first"),
    last     = pick("last"),
    particle = pick("particle"),
    suffix   = pick("suffix"),
    type     = pick("type"),
    stringsAsFactors = FALSE)
  out
}
