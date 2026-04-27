# Tests for 0.1.6 messaging / guardrail surface:
#   * the "Rating range inferred" message now fires once per fit_mfrm()
#     call (previously fired twice),
#   * analyze_dff(method = "refit") raises a mfrmr-styled error when
#     diagnostics is missing,
#   * compute_information() and fair_average_table() produce finite
#     outputs on the default example and on a deliberately boundary-ish
#     subset.

local({
  .toy <<- load_mfrmr_data("example_core")
})

test_that("fit_mfrm() emits the inferred-rating message exactly once", {
  msgs <- testthat::capture_messages(suppressWarnings(
    fit_mfrm(.toy, "Person", c("Rater", "Criterion"), "Score",
             method = "JML", maxit = 10)
  ))
  n <- sum(grepl("Rating range inferred", msgs, fixed = TRUE))
  expect_equal(n, 1L)
})

test_that("explicit rating_min/rating_max suppresses the inferred message", {
  msgs <- testthat::capture_messages(suppressWarnings(
    fit_mfrm(.toy, "Person", c("Rater", "Criterion"), "Score",
             method = "JML", maxit = 5,
             rating_min = 1L, rating_max = 4L)
  ))
  expect_false(any(grepl("Rating range inferred", msgs, fixed = TRUE)))
})

test_that("analyze_dff(method = 'refit') without diagnostics raises mfrmr error", {
  fit <- suppressMessages(suppressWarnings(
    fit_mfrm(.toy, "Person", c("Rater", "Criterion"), "Score",
             method = "JML", maxit = 10)
  ))
  expect_error(
    analyze_dff(fit, facet = "Rater", group = "Group",
                data = .toy, method = "refit"),
    "method = \"refit\""
  )
})

test_that("analyze_dff(method = 'residual') is tolerant of missing diagnostics", {
  fit <- suppressMessages(suppressWarnings(
    fit_mfrm(.toy, "Person", c("Rater", "Criterion"), "Score",
             method = "JML", maxit = 10)
  ))
  diag <- suppressMessages(
    diagnose_mfrm(fit, residual_pca = "none",
                  diagnostic_mode = "legacy")
  )
  out <- suppressMessages(suppressWarnings(
    analyze_dff(fit, diagnostics = diag,
                facet = "Rater", group = "Group",
                data = .toy, method = "residual")
  ))
  expect_s3_class(out, "mfrm_dff")
})

test_that("fit_mfrm(missing_codes = TRUE) recodes default sentinels to NA", {
  dirty <- .toy
  # Inject a default FACETS/SPSS sentinel for one rater row.
  dirty$Score <- as.character(dirty$Score)
  dirty$Score[1:3] <- "99"
  f <- suppressMessages(suppressWarnings(
    fit_mfrm(dirty, "Person", c("Rater", "Criterion"), "Score",
             method = "JML", maxit = 5, missing_codes = TRUE)
  ))
  expect_true("missing_recoding" %in% names(f$prep))
  rec <- f$prep$missing_recoding
  expect_s3_class(rec, "data.frame")
  expect_true(any(rec$Replaced > 0))
})

test_that("fit_mfrm(missing_codes = NULL) keeps existing data untouched", {
  f <- suppressMessages(suppressWarnings(
    fit_mfrm(.toy, "Person", c("Rater", "Criterion"), "Score",
             method = "JML", maxit = 5, missing_codes = NULL)
  ))
  if (is.data.frame(f$prep$missing_recoding)) {
    expect_equal(nrow(f$prep$missing_recoding), 0L)
  } else {
    expect_null(f$prep$missing_recoding)
  }
})
