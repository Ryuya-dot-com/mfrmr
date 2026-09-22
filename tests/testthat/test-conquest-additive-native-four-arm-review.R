test_that("the four-arm native reviewer never launches ConQuest", {
  candidates <- c(
    file.path("inst", "validation"),
    testthat::test_path("..", "..", "inst", "validation")
  )
  validation_dir <- candidates[dir.exists(candidates)][1]
  testthat::skip_if(is.na(validation_dir), "Repository validation files are unavailable.")
  script <- file.path(
    validation_dir, "conquest-additive-native-four-arm-review-0.2.3.R"
  )
  env <- new.env(parent = globalenv())
  sys.source(script, envir = env)
  expect_true(is.function(
    env$mfrmr_review_conquest_additive_native_four_arms
  ))
  lines <- readLines(script, warn = FALSE)
  expect_length(grep(
    "system2\\s*\\(|system\\s*\\(", lines, perl = TRUE, value = TRUE
  ), 0L)
})
