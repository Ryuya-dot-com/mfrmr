conquest_native_rsm_review_dir <- function() {
  candidates <- c(
    file.path("inst", "validation"),
    testthat::test_path("..", "..", "inst", "validation")
  )
  candidates <- candidates[dir.exists(candidates)]
  if (length(candidates) == 0L) return(NA_character_)
  candidates[1]
}

load_conquest_native_rsm_review <- function() {
  testthat::skip_if_not_installed("digest")
  validation_dir <- conquest_native_rsm_review_dir()
  testthat::skip_if(is.na(validation_dir), "Repository validation files are unavailable.")
  env <- new.env(parent = globalenv())
  for (file in c(
    "conquest-additive-mfrm-design-0.2.3.R",
    "conquest-numeric-resolution-contract-0.2.3.R",
    "conquest-additive-native-rsm-q31-review-0.2.3.R"
  )) {
    sys.source(file.path(validation_dir, file), envir = env)
  }
  env
}

test_that("the expected native RSM q31 A matrix is exact", {
  env <- load_conquest_native_rsm_review()
  matrix <- env$mfrmr_cq_native_rsm_q31_expected_amatrix()
  expect_identical(dim(matrix), c(16L, 6L))
  expect_identical(matrix$GIN, rep(1:4, each = 4L))
  expect_identical(matrix$Category, rep(1:4, times = 4L))
  expect_identical(names(matrix), c(
    "GIN", "Category", "rater R1", "criterion C1",
    "category 1", "category 2"
  ))
  expect_identical(matrix[1:4, "rater R1"], 0:-3)
  expect_identical(matrix[5:8, "rater R1"], 0:3)
  expect_identical(matrix[13:16, "criterion C1"], 0:3)
  expect_identical(matrix[1:4, "category 1"], c(0L, -1L, -1L, 0L))
  expect_identical(matrix[1:4, "category 2"], c(0L, 0L, -1L, 0L))
})

test_that("native RSM q31 path resolution is run-specific", {
  env <- load_conquest_native_rsm_review()
  root <- tempfile("cq-native-rsm-paths-")
  dir.create(root)
  paths <- env$mfrmr_cq_native_rsm_q31_paths(root)
  expect_identical(paths$output_dir, normalizePath(root, winslash = "/"))
  expect_match(paths$command, "/rsm_q031/cq_additive_rsm_q031.cqc$")
  expect_match(
    paths$reference_summary,
    "/mfrmr_reference/rsm_q031_mfrmr_reference_summary.csv$"
  )
})
