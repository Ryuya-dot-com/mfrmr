load_conquest_native_pcm_review <- function() {
  testthat::skip_if_not_installed("digest")
  candidates <- c(
    file.path("inst", "validation"),
    testthat::test_path("..", "..", "inst", "validation")
  )
  validation_dir <- candidates[dir.exists(candidates)][1]
  testthat::skip_if(is.na(validation_dir), "Repository validation files are unavailable.")
  env <- new.env(parent = globalenv())
  for (file in c(
    "conquest-additive-mfrm-design-0.2.3.R",
    "conquest-numeric-resolution-contract-0.2.3.R",
    "conquest-additive-native-pcm-q31-review-0.2.3.R"
  )) {
    sys.source(file.path(validation_dir, file), envir = env)
  }
  env
}

test_that("the expected native PCM q31 A matrix is exact", {
  env <- load_conquest_native_pcm_review()
  matrix <- env$mfrmr_cq_native_pcm_q31_expected_amatrix()
  expect_identical(dim(matrix), c(16L, 8L))
  expect_identical(matrix$GIN, rep(1:4, each = 4L))
  expect_identical(matrix$Category, rep(1:4, times = 4L))
  expect_identical(names(matrix), c(
    "GIN", "Category", "rater R1", "criterion C1",
    "criterion C1 category 1", "criterion C1 category 2",
    "criterion C2 category 1", "criterion C2 category 2"
  ))
  expect_identical(matrix[1:4, "criterion C1 category 1"],
                   c(0L, -1L, -1L, 0L))
  expect_identical(matrix[9:12, "criterion C1 category 1"],
                   rep(0L, 4L))
  expect_identical(matrix[9:12, "criterion C2 category 2"],
                   c(0L, 0L, -1L, 0L))
})

test_that("native PCM q31 path resolution is run-specific", {
  env <- load_conquest_native_pcm_review()
  root <- tempfile("cq-native-pcm-paths-")
  dir.create(root)
  paths <- env$mfrmr_cq_native_pcm_q31_paths(root)
  expect_match(paths$command, "/pcm_q031/cq_additive_pcm_q031.cqc$")
  expect_match(
    paths$reference_parameters,
    "/mfrmr_reference/pcm_q031_mfrmr_reference_parameters.csv$"
  )
})
