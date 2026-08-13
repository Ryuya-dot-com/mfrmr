rater_anchor_canonical_hash_environment <- function() {
  path <- testthat::test_path(
    "..", "..", "inst", "validation",
    "rater-anchor-sparse-canonical-hash-0.2.3.R"
  )
  if (!file.exists(path)) {
    stop("Required repository canonical-hash helper is missing.", call. = FALSE)
  }
  testthat::skip_if_not_installed("digest")
  env <- new.env(parent = globalenv())
  sys.source(path, envir = env)
  env
}

test_that("canonical table hashes ignore representational ordering", {
  env <- rater_anchor_canonical_hash_environment()
  original <- data.frame(
    Label = c("e\u0301", "\u00e9", NA_character_),
    Value = c(1 / 3, -0, NA_real_),
    Count = c(2L, 1L, NA_integer_),
    Flag = c(TRUE, FALSE, NA),
    stringsAsFactors = FALSE
  )
  reordered <- original[c(3L, 1L, 2L), c("Flag", "Count", "Value", "Label")]
  row.names(reordered) <- c("arbitrary", "row", "names")

  expect_identical(
    env$mfrmr_rash_hash_table(original, "fixture"),
    env$mfrmr_rash_hash_table(reordered, "fixture")
  )
})

test_that("canonical hashes retain scientific and domain differences", {
  env <- rater_anchor_canonical_hash_environment()
  base <- data.frame(Id = "A", Estimate = 0.123456789012,
                     stringsAsFactors = FALSE)
  changed <- base
  changed$Estimate <- 0.123456789112
  below_precision <- base
  below_precision$Estimate <- base$Estimate + 1e-14

  expect_false(identical(
    env$mfrmr_rash_hash_table(base, "fixture"),
    env$mfrmr_rash_hash_table(changed, "fixture")
  ))
  expect_identical(
    env$mfrmr_rash_hash_table(base, "fixture"),
    env$mfrmr_rash_hash_table(below_precision, "fixture")
  )
  expect_false(identical(
    env$mfrmr_rash_hash_table(base, "fixture"),
    env$mfrmr_rash_hash_table(base, "different_fixture")
  ))
})

test_that("canonical hashes reject unsupported evidence columns", {
  env <- rater_anchor_canonical_hash_environment()
  expect_error(
    env$mfrmr_rash_hash_table(
      data.frame(When = as.Date("2026-08-14")), "fixture"
    ),
    "support only factor"
  )
  expect_error(
    env$mfrmr_rash_hash_table(
      data.frame(A = 1, A = 2, check.names = FALSE), "fixture"
    ),
    "unique, non-empty"
  )
})

test_that("canonical text-file hashes ignore platform line endings", {
  env <- rater_anchor_canonical_hash_environment()
  lf <- tempfile("mfrmr_hash_lf_", fileext = ".R")
  crlf <- tempfile("mfrmr_hash_crlf_", fileext = ".R")
  on.exit(unlink(c(lf, crlf)), add = TRUE)
  writeBin(charToRaw("x <- 1\ny <- '\u00e9'\n"), lf)
  writeBin(charToRaw("x <- 1\r\ny <- '\u00e9'\r\n"), crlf)

  expect_identical(
    env$mfrmr_rash_hash_text_file(lf),
    env$mfrmr_rash_hash_text_file(crlf)
  )
})
