# Tests for the 0.1.6 helpers introduced for local-dependence and
# person-fit reporting: q3_statistic(), compute_person_fit_indices(),
# and mfrm_generalizability().

local({
  .toy <<- load_mfrmr_data("example_core")
  .fit <<- make_toy_fit()
  .diag <<- make_toy_diagnostics(.fit)
})

# --- q3_statistic ---------------------------------------------------------

test_that("q3_statistic returns the documented shape", {
  q3 <- q3_statistic(.fit, diagnostics = .diag)
  expect_s3_class(q3, "mfrm_q3")
  expect_true(all(c("Level1", "Level2", "Q3", "N", "AbsQ3",
                    "YenFlag", "MaraisFlag", "RelativeFlag",
                    "Interpretation") %in% names(q3$pairs)))
  expect_named(q3$thresholds, c("yen", "marais", "relative_offset"))
})

test_that("q3_statistic respects custom thresholds", {
  q3_strict <- q3_statistic(.fit, diagnostics = .diag,
                             yen_threshold = 0.05,
                             marais_threshold = 0.10)
  expect_gte(q3_strict$summary$YenFlagged, 0L)
  q3_lax <- q3_statistic(.fit, diagnostics = .diag,
                         yen_threshold = 0.99,
                         marais_threshold = 0.99)
  expect_equal(q3_lax$summary$YenFlagged, 0L)
})

test_that("q3_statistic rejects unknown facet", {
  expect_error(
    q3_statistic(.fit, diagnostics = .diag, facet = "NotAFacet"),
    "must be one of"
  )
})

# --- compute_person_fit_indices ------------------------------------------

test_that("compute_person_fit_indices returns one row per person", {
  pf <- compute_person_fit_indices(.diag, fit = .fit)
  expect_true(is.data.frame(pf))
  expect_true(all(c("Person", "N", "LogLik", "lz", "lz_star", "ECI4")
                  %in% names(pf)))
  expect_equal(length(unique(pf$Person)), nrow(pf))
})

test_that("compute_person_fit_indices works without fit (lz_star NA)", {
  pf <- compute_person_fit_indices(.diag, fit = NULL)
  expect_true(all(is.na(pf$lz_star)))
})

# --- mfrm_generalizability -----------------------------------------------

test_that("mfrm_generalizability returns variance components and G/Phi", {
  if (!requireNamespace("lme4", quietly = TRUE)) {
    skip("lme4 (Suggests) not installed.")
  }
  gt <- mfrm_generalizability(.fit)
  expect_s3_class(gt, "mfrm_generalizability")
  expect_true(all(c("Source", "Variance", "ProportionVariance")
                  %in% names(gt$variance_components)))
  expect_true(all(c("G", "Phi") %in% names(gt$coefficients)))
})
