#' Read bibliometric data
#'
#' Universal reader that handles files, folders, format detection, and
#' generic CSV input. Accepts a single file, multiple files, or a directory.
#'
#' @param path Character. Path to a file, a vector of file paths, or a
#'   directory containing export files.
#' @param format Character. File format:
#'   \describe{
#'     \item{`"auto"`}{Default. Auto-detect from file content.}
#'     \item{`"scopus"`}{Scopus CSV.}
#'     \item{`"wos"`}{Web of Science plaintext.}
#'     \item{`"wos_tab"`}{Web of Science tab-delimited.}
#'     \item{`"bibtex"`}{BibTeX .bib file.}
#'     \item{`"ris"`}{RIS file.}
#'     \item{`"dimensions"`}{Dimensions CSV.}
#'     \item{`"lens"`}{Lens.org CSV.}
#'     \item{`"openalex_csv"`}{Flat OpenAlex CSV export (pipe-delimited fields).}
#'     \item{`"generic"`}{Any CSV. Map its columns with `id`, `authors`,
#'       `keywords`, `references`, `countries`, `affiliations`, `journal`.
#'       Inferred automatically when any of those arguments is supplied, so
#'       `format = "generic"` is optional in that case.}
#'   }
#' @param id Character. Column name for document identifier. Only used
#'   when `format = "generic"`. Default `NULL` (uses row numbers).
#' @param authors,keywords,references,countries,affiliations Character. For
#'   `format = "generic"`, the name of the source column to map onto that
#'   standard field. Its cells are split on `sep` into a list-column. For
#'   example `authors = "Author Names"` reads the `Author Names` column into
#'   the standard `authors` list-column.
#' @param journal Character. For `format = "generic"`, the name of the source
#'   column to use as the (scalar) `journal` field. Not split.
#' @param sep Character. Delimiter for splitting the mapped multi-valued
#'   columns. Default `";"`.
#' @param list_cols Character vector. For `format = "generic"`, additional
#'   columns to split into list-columns *in place* (keeping their original
#'   names), for fields without a dedicated argument above.
#' @param ... Additional arguments passed to the format-specific reader.
#' @param actors Deprecated. Use the entity arguments (`authors`, `keywords`,
#'   ...) or `list_cols` instead.
#'
#' @return A data frame.
#'
#' @export
#' @examples
#' # Auto-detect format from file content (here: a bundled OpenAlex CSV)
#' f <- system.file("extdata", "openalex_works.csv", package = "bibnets")
#' data <- read_biblio(f)
#' head(data[, c("id", "title", "year", "journal")])
#'
#' # Read multiple files at once; auto-detects each format
#' f_scopus <- system.file("extdata", "scopus_sample.csv", package = "bibnets")
#' f_wos    <- system.file("extdata", "wos_sample.txt",  package = "bibnets")
#' combined <- read_biblio(c(f_scopus, f_wos))
#' head(combined[, c("id", "title", "year", "journal")])
#'
#' # Read every supported export in a directory (here: the bundled extdata)
#' folder <- system.file("extdata", package = "bibnets")
#' all_data <- read_biblio(folder)
#' nrow(all_data)
#'
#' # Custom CSV: map each source column onto a standard field by name.
#' # Naming columns implies format = "generic" (no need to pass it).
#' tmp <- tempfile(fileext = ".csv")
#' write.csv(data.frame(
#'   doc_id  = c("a", "b"),
#'   Authors = c("Smith J; Jones A", "Davis M"),
#'   Keywords = c("networks; bibliometrics", "analytics")
#' ), tmp, row.names = FALSE)
#' generic <- read_biblio(tmp,
#'                        id = "doc_id",
#'                        authors = "Authors",
#'                        keywords = "Keywords",
#'                        sep = ";")
#' head(generic)
read_biblio <- function(path,
                        format = "auto",
                        id = NULL,
                        authors = NULL,
                        keywords = NULL,
                        references = NULL,
                        countries = NULL,
                        affiliations = NULL,
                        journal = NULL,
                        sep = ";",
                        list_cols = NULL,
                        ...,
                        actors = NULL) {
  ## Back-compat: 'actors' was renamed in 0.6.0.
  if (!is.null(actors)) {
    warning("Argument 'actors' is deprecated; use the entity arguments ",
            "(authors, keywords, ...) or 'list_cols' instead.", call. = FALSE)
    if (is.null(list_cols)) list_cols <- actors
  }

  ## If the caller maps columns by name, the read is generic by definition —
  ## no need to also pass format = "generic".
  mapping_supplied <- !is.null(id) || !is.null(authors) || !is.null(keywords) ||
    !is.null(references) || !is.null(countries) || !is.null(affiliations) ||
    !is.null(journal) || !is.null(list_cols)
  if (identical(format, "auto") && mapping_supplied) {
    format <- "generic"
  }

  ## Collect all file paths
  files <- resolve_paths(path)

  if (length(files) == 0) {
    stop("No files found at: ", paste(path, collapse = ", "), call. = FALSE)
  }

  ## Read each file
  dfs <- lapply(files, function(f) {
    read_single_biblio(f, format = format, id = id, sep = sep,
                        authors = authors, keywords = keywords,
                        references = references, countries = countries,
                        affiliations = affiliations, journal = journal,
                        list_cols = list_cols, ...)
  })

  ## Combine
  dfs <- align_biblio_columns(dfs)
  result <- do.call(rbind, dfs)
  rownames(result) <- NULL

  if (length(files) > 1) {
    message(sprintf("Read %d files: %d rows total", length(files), nrow(result)))
  }

  result
}


#' Align columns before row-binding bibliographic files
#' @keywords internal
align_biblio_columns <- function(dfs) {
  all_cols <- unique(unlist(lapply(dfs, names), use.names = FALSE))
  list_cols <- all_cols[vapply(all_cols, function(col) {
    any(vapply(dfs, function(d) col %in% names(d) && is.list(d[[col]]),
               logical(1L)))
  }, logical(1L))]

  lapply(dfs, function(d) {
    missing <- setdiff(all_cols, names(d))
    for (col in missing) {
      if (col %in% list_cols) {
        d[[col]] <- replicate(nrow(d), character(0), simplify = FALSE)
      } else {
        d[[col]] <- rep(NA, nrow(d))
      }
    }
    d[, all_cols, drop = FALSE]
  })
}


#' Read a single bibliometric file
#' @keywords internal
read_single_biblio <- function(file, format, id, sep,
                               authors = NULL, keywords = NULL,
                               references = NULL, countries = NULL,
                               affiliations = NULL, journal = NULL,
                               list_cols = NULL, ...) {
  if (format == "generic") {
    return(read_generic(file, id = id, sep = sep,
                        authors = authors, keywords = keywords,
                        references = references, countries = countries,
                        affiliations = affiliations, journal = journal,
                        list_cols = list_cols))
  }

  if (format == "auto") {
    format <- detect_format(file)
  }

  switch(format,
    scopus       = read_scopus(file, ...),
    wos          = read_wos(file, ...),
    wos_tab      = read_wos(file, format = "tab", ...),
    bibtex       = read_bibtex(file, ...),
    ris          = read_ris(file, ...),
    dimensions   = read_dimensions(file, ...),
    lens         = read_lens(file, ...),
    openalex_csv = read_openalex_csv(file, ...),
    stop(
      "Could not detect file format for: ", file, "\n\n",
      "Supported file formats:\n",
      "  auto, scopus, wos, wos_tab, bibtex, ris, dimensions, lens,\n",
      "  openalex_csv, generic\n\n",
      "Note: Nested OpenAlex (openalexR::oa_fetch()) and Crossref data\n",
      "must be loaded into R first, then converted with\n",
      "read_openalex() or read_crossref().\n\n",
      "For generic CSV, use: read_biblio(file, format = 'generic', ",
      "authors = 'Authors', keywords = 'Keywords', sep = ';')",
      call. = FALSE
    )
  )
}


#' Read a generic CSV with user-specified columns
#' @keywords internal
read_generic <- function(file, id = NULL, sep = ";",
                         authors = NULL, keywords = NULL, references = NULL,
                         countries = NULL, affiliations = NULL, journal = NULL,
                         list_cols = NULL) {
  check_file(file)

  data <- utils::read.csv(file, stringsAsFactors = FALSE, fileEncoding = "UTF-8",
                           check.names = FALSE)

  ## Set ID column
  if (!is.null(id) && id %in% names(data)) {
    data[["id"]] <- as.character(data[[id]])
  } else if (!"id" %in% names(data)) {
    data[["id"]] <- as.character(seq_len(nrow(data)))
  }

  warn_missing <- function(cols) {
    miss <- cols[!cols %in% names(data)]
    if (length(miss) > 0)
      warning("Column(s) not found in file and skipped: ",
              paste0("'", miss, "'", collapse = ", "),
              ". Available columns: ",
              paste0("'", names(data), "'", collapse = ", "),
              call. = FALSE)
  }

  ## Map entity arguments (standard field name <- source column) onto
  ## list-columns. NULLs drop out of c(), so only supplied args remain.
  entity_map <- c(authors = authors, keywords = keywords,
                  references = references, countries = countries,
                  affiliations = affiliations)
  if (length(entity_map) > 0) {
    warn_missing(entity_map)
    present <- entity_map[entity_map %in% names(data)]
    data[names(present)] <- lapply(present,
                                   function(src) split_field(data[[src]], sep = sep))
  }

  ## journal is a scalar field (not split)
  if (!is.null(journal)) {
    warn_missing(journal)
    if (journal %in% names(data)) data[["journal"]] <- as.character(data[[journal]])
  }

  ## list_cols: split any further columns in place, keeping their names
  if (!is.null(list_cols)) {
    warn_missing(list_cols)
    cols <- intersect(list_cols, names(data))
    data[cols] <- lapply(data[cols], split_field, sep = sep)
  }

  data
}


#' Resolve file paths from a file, vector of files, or directory
#' @keywords internal
resolve_paths <- function(path) {
  unlist(lapply(path, function(p) {
    if (dir.exists(p)) {
      list.files(p, pattern = "\\.(csv|txt|bib|ris|xlsx?)$",
                 full.names = TRUE, ignore.case = TRUE)
    } else if (file.exists(p)) {
      p
    } else {
      character(0)
    }
  }), use.names = FALSE)
}


#' Detect bibliometric file format
#' @param file Path to file.
#' @return Character: format name or `"unknown"`.
#' @keywords internal
detect_format <- function(file) {
  lines <- readLines(file, n = 10, warn = FALSE, encoding = "UTF-8")
  lines <- lines[nchar(trimws(lines)) > 0]
  if (length(lines) == 0) return("unknown")

  first <- trimws(lines[1])

  ## BibTeX: starts with @
  if (grepl("^@", first)) return("bibtex")

  ## RIS: starts with TY  -
  if (grepl("^TY\\s+-", first)) return("ris")

  ## WoS plaintext: starts with FN or PT
  if (grepl("^(FN|PT)\\s", first)) return("wos")

  ## CSV-based: check header line — Dimensions prepends a metadata row so
  ## also check line 2 when line 1 looks like "About the data: ..."
  header <- tolower(first)
  if (grepl("^\"?about the data", header) && length(lines) >= 2) {
    header <- tolower(trimws(lines[2]))
  }

  ## Scopus: has EID column
  if (grepl("\\beid\\b", header)) return("scopus")

  ## Dimensions: has "publication id" or "dimensions url"
  if (grepl("publication id|dimensions url", header)) return("dimensions")

  ## Lens: has "lens id"
  if (grepl("lens id", header)) return("lens")

  ## OpenAlex flat CSV: has "authorships.author.display_name" column header
  if (grepl("authorships\\.author\\.display_name", header)) return("openalex_csv")

  "unknown"
}
