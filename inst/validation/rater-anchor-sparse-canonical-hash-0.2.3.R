# Canonical SHA-256 helpers for the repository-only Rater-anchor evidence.
#
# These helpers intentionally cover only atomic data-frame evidence and the
# simulation truth used by this validation family. They do not serialize
# arbitrary R objects. Columns and rows are ordered canonically, characters
# are UTF-8 byte encoded, missing values are typed, and finite doubles are
# recorded to 12 significant decimal digits. That precision is materially
# finer than every scientific gate in this validation contract.

mfrmr_rash_format <- "mfrmr_rater_anchor_canonical_tables_v1"

mfrmr_rash_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_rash_require_digest <- function() {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Package `digest` is required for canonical evidence identities.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_rash_utf8_hex <- function(value) {
  value <- enc2utf8(as.character(value))
  vapply(value, function(item) {
    if (is.na(item)) return("NA")
    raw <- charToRaw(item)
    if (length(raw) < 1L) return("")
    paste(sprintf("%02x", as.integer(raw)), collapse = "")
  }, character(1), USE.NAMES = FALSE)
}

mfrmr_rash_numeric <- function(value) {
  vapply(value, function(item) {
    if (is.na(item)) {
      if (is.nan(item)) return("NaN")
      return("NA")
    }
    if (is.infinite(item)) return(if (item > 0) "+Inf" else "-Inf")
    if (item == 0) return("0")
    rendered <- formatC(
      item, format = "e", digits = 11L, decimal.mark = "."
    )
    parts <- strsplit(rendered, "e", fixed = TRUE)[[1L]]
    paste0(parts[[1L]], "e", as.integer(parts[[2L]]))
  }, character(1), USE.NAMES = FALSE)
}

mfrmr_rash_column <- function(value) {
  if (is.factor(value)) {
    return(list(type = "factor_as_character", value = mfrmr_rash_utf8_hex(
      as.character(value)
    )))
  }
  if (identical(class(value), "character")) {
    return(list(type = "character", value = mfrmr_rash_utf8_hex(value)))
  }
  if (identical(class(value), "integer")) {
    encoded <- ifelse(is.na(value), "NA", as.character(value))
    return(list(type = "integer", value = encoded))
  }
  if (identical(class(value), "numeric")) {
    return(list(type = "numeric_12sf", value = mfrmr_rash_numeric(value)))
  }
  if (identical(class(value), "logical")) {
    encoded <- ifelse(is.na(value), "NA", ifelse(value, "TRUE", "FALSE"))
    return(list(type = "logical", value = encoded))
  }
  stop(
    "Canonical Rater-anchor hashes support only factor, character, integer, ",
    "numeric, and logical columns; found class `",
    paste(class(value), collapse = "/"), "`.",
    call. = FALSE
  )
}

mfrmr_rash_canonical_table <- function(table, domain) {
  mfrmr_rash_assert(is.data.frame(table), "Canonical evidence must be a data frame.")
  mfrmr_rash_assert(
    is.character(domain) && length(domain) == 1L && !is.na(domain) && nzchar(domain),
    "A non-empty scalar domain is required for a canonical evidence hash."
  )
  column_names <- names(table)
  mfrmr_rash_assert(
    length(column_names) == ncol(table) && all(nzchar(column_names)) &&
      !anyDuplicated(column_names),
    "Canonical evidence requires unique, non-empty column names."
  )
  column_order <- order(mfrmr_rash_utf8_hex(column_names), method = "radix")
  table <- as.data.frame(table[column_order], stringsAsFactors = FALSE)
  column_names <- names(table)
  encoded <- lapply(table, mfrmr_rash_column)
  header <- paste(vapply(seq_along(encoded), function(i) {
    paste0(mfrmr_rash_utf8_hex(column_names[[i]]), "=", encoded[[i]]$type)
  }, character(1)), collapse = "\t")
  rows <- if (nrow(table) < 1L) {
    character()
  } else {
    vapply(seq_len(nrow(table)), function(i) {
      paste(vapply(encoded, function(column) column$value[[i]], character(1)),
            collapse = "\t")
    }, character(1))
  }
  if (length(rows) > 1L) rows <- sort(rows, method = "radix")
  paste(
    paste0("format=", mfrmr_rash_format),
    paste0("domain_hex=", mfrmr_rash_utf8_hex(domain)),
    paste0("nrow=", nrow(table)),
    paste0("ncol=", ncol(table)),
    paste0("columns=", header),
    paste(rows, collapse = "\n"),
    sep = "\n"
  )
}

mfrmr_rash_hash_table <- function(table, domain) {
  mfrmr_rash_require_digest()
  digest::digest(
    mfrmr_rash_canonical_table(table, domain),
    algo = "sha256", serialize = FALSE
  )
}

mfrmr_rash_hash_text_file <- function(path) {
  mfrmr_rash_require_digest()
  mfrmr_rash_assert(
    is.character(path) && length(path) == 1L && !is.na(path) && file.exists(path),
    "Canonical text-file hashing requires one existing file."
  )
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  if (length(lines) > 0L) {
    lines[[1L]] <- sub("^\ufeff", "", lines[[1L]])
    canonical <- paste0(paste(enc2utf8(lines), collapse = "\n"), "\n")
  } else {
    canonical <- ""
  }
  digest::digest(
    paste("mfrmr_text_file_utf8_lf_v1", canonical, sep = "\n"),
    algo = "sha256", serialize = FALSE
  )
}

mfrmr_rash_hash_tables <- function(tables, domain) {
  mfrmr_rash_require_digest()
  mfrmr_rash_assert(
    is.list(tables) && length(tables) > 0L &&
      !is.null(names(tables)) && all(nzchar(names(tables))) &&
      !anyDuplicated(names(tables)),
    "Canonical evidence-table collections require unique, non-empty names."
  )
  component_order <- order(mfrmr_rash_utf8_hex(names(tables)), method = "radix")
  tables <- tables[component_order]
  payload <- vapply(seq_along(tables), function(i) {
    component <- names(tables)[[i]]
    paste0(
      "component_hex=", mfrmr_rash_utf8_hex(component), "\n",
      mfrmr_rash_canonical_table(
        tables[[i]], paste0(domain, "/", component)
      )
    )
  }, character(1))
  digest::digest(
    paste(
      paste0("collection_format=", mfrmr_rash_format),
      paste0("domain_hex=", mfrmr_rash_utf8_hex(domain)),
      paste(payload, collapse = "\n--component--\n"),
      sep = "\n"
    ),
    algo = "sha256", serialize = FALSE
  )
}

mfrmr_rash_truth_tables <- function(truth) {
  mfrmr_rash_assert(
    is.list(truth) && is.numeric(truth$person) &&
      is.list(truth$facets) && is.data.frame(truth$step_table),
    "Simulation truth does not satisfy the Rater-anchor hash contract."
  )
  mfrmr_rash_assert(
    !is.null(names(truth$person)) && !is.null(names(truth$facets)),
    "Simulation truth requires named Person and facet parameters."
  )
  facet_rows <- lapply(names(truth$facets), function(facet) {
    estimates <- truth$facets[[facet]]
    mfrmr_rash_assert(
      is.numeric(estimates) && !is.null(names(estimates)),
      paste0("Simulation facet `", facet, "` requires named numeric estimates.")
    )
    data.frame(
      Facet = facet, Level = names(estimates), Estimate = as.numeric(estimates),
      stringsAsFactors = FALSE
    )
  })
  list(
    person = data.frame(
      Level = names(truth$person), Estimate = as.numeric(truth$person),
      stringsAsFactors = FALSE
    ),
    facets = do.call(rbind, facet_rows),
    step_table = as.data.frame(truth$step_table, stringsAsFactors = FALSE)
  )
}

mfrmr_rash_hash_truth <- function(truth, domain = "simulation_truth") {
  mfrmr_rash_hash_tables(mfrmr_rash_truth_tables(truth), domain = domain)
}
