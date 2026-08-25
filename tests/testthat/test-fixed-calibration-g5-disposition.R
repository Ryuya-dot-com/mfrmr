test_that("G5 narrows portable calibration without relabelling fitted GPCM", {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  record_path <- file.path(
    validation, "fixed-calibration-g5-lane-disposition-0.2.4.md"
  )
  skip_if_not(file.exists(record_path), "Fixed-calibration G5 record is excluded.")

  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(
    readLines(file.path(root, "ROADMAP.md"), warn = FALSE), collapse = "\n"
  )
  gpcm_help <- paste(
    readLines(file.path(root, "R", "help_gpcm_scope.R"), warn = FALSE),
    collapse = "\n"
  )

  expect_match(record, "`G5Complete=TRUE`", fixed = TRUE)
  expect_match(
    record, "`PortableCalibrationCore=RSM_PCM_MML_FIXED_N01`", fixed = TRUE
  )
  expect_match(record, "`OPT02PortableCalibration=UNAVAILABLE_0_2_4`",
               fixed = TRUE)
  expect_match(record, "`ExistingFittedObjectGPCMUnchanged=TRUE`",
               fixed = TRUE)
  expect_match(record, "`NextGate=G6-release-candidate-hardening`",
               fixed = TRUE)

  expect_match(roadmap, "- [x] **G5 — Optional-lane qualification**",
               fixed = TRUE)
  expect_match(roadmap, "- [ ] **G6 — Release-candidate hardening**",
               fixed = TRUE)
  expect_match(roadmap, "### Public-document audience boundary", fixed = TRUE)

  expect_match(
    gpcm_help, '"Fitted-object posterior scoring and information"', fixed = TRUE
  )
  expect_false(grepl(
    '"Fixed-calibration scoring and information"', gpcm_help, fixed = TRUE
  ))
})

test_that("public release prose does not expose 0.2.4 gate mechanics", {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  news <- paste(
    readLines(file.path(root, "NEWS.md"), warn = FALSE), collapse = "\n"
  )
  r_files <- list.files(
    file.path(root, "R"), pattern = "[.]R$", full.names = TRUE
  )
  roxygen <- unlist(lapply(r_files, function(path) {
    lines <- readLines(path, warn = FALSE)
    lines[grepl("^#'", lines)]
  }), use.names = FALSE)
  public_prose <- paste(c(news, roxygen), collapse = "\n")

  expect_false(grepl("\\b(?:CORE|OPT)-[0-9]+\\b", public_prose, perl = TRUE))
  expect_false(grepl("\\bG[0-9] (?:exit|gate)\\b", public_prose,
                     ignore.case = TRUE, perl = TRUE))
  expect_false(grepl("claim ledger|hosted workflow run|authorization hash",
                     public_prose, ignore.case = TRUE, perl = TRUE))
})
