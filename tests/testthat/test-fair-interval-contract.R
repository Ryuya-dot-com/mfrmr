test_that("zero-reference summaries use FairZ values and retain diagnostic scope", {
  fit <- make_toy_fit(maxit = 10)
  for (style in c("native", "legacy", "both")) {
    b <- fair_average_table(fit, reference = "zero", label_style = style)
    s <- summary(b, digits = 10)
    expect_equal(s$summary$FairMetric, "FairZ")
    expect_true(all(is.finite(s$preview$StandardizedAdjustedAverage)))
    expect_false("AdjustedAverage" %in% names(s$preview))
    expect_false(s$summary$FairCIEligible)
  }
  # Deliberately supplied bundle: counts refer to FairZ, even without settings.
  b <- list(stacked = data.frame(Facet = "Rater", Level = "R1",
    ObservedAverage = 1, StandardizedAdjustedAverage = 1.2,
    StandardizedAdjustedAverageSE = .1,
    StandardizedAdjustedAverageCI_Lower = 1,
    StandardizedAdjustedAverageCI_Upper = 1.4,
    StandardizedAdjustedAverageCI_Level = .95,
    StandardizedAdjustedAverageSEStatus = "ok"), settings = list())
  class(b) <- class(fair_average_table(fit))
  s <- summary(b, digits = 10)
  expect_equal(s$summary$FairSEAvailableRows, 1)
  expect_equal(s$summary$MeanStandardizedAdjustedAverageSE, .1)
  expect_equal(s$summary$StandardizedAdjustedAverageCILevel, .95)
  expect_false(s$preview$FairCIEligible)
  expect_true(any(grepl("diagnostic", s$notes)))
})

test_that("incomplete gradients cannot create a finite fair-score SE", {
  fit <- make_toy_fit(maxit = 10)
  fit$config$model <- "GPCM"
  raw <- list(Rater = data.frame(Level = "R1", FairM = 1, FairZ = 1))
  testthat::local_mocked_bindings(
    finite_difference_gradient = function(...) c(1, NA_real_), .package = "mfrmr")
  got <- mfrmr:::add_gpcm_fair_average_delta_se(raw, fit,
    covariance = list(status = "ok", cov = diag(2)))$Rater
  expect_true(is.na(got$FairMSE))
  expect_true(is.na(got$FairZSE))
  expect_match(got$FairZ_SE_Detail, "complete")
})

test_that("fair-score plot intervals cannot acquire formal eligibility", {
  fit <- make_toy_fit(maxit = 10)
  p <- plot_fair_average(fit, show_ci = TRUE, draw = FALSE,
    show_title = FALSE, show_notes = FALSE)
  d <- p$data$data
  expect_true(any(is.finite(d$CI_Lower)))
  expect_true(all(!d$CI_Eligible))
  expect_true(all(d$CI_ReportingUse[is.finite(d$CI_Lower)] == "diagnostic_only"))
  expect_true(any(grepl("Full-refit coverage unverified", p$data$notes$Text)))
  b <- fair_average_table(fit, fair_se = TRUE, reference = "zero")
  expect_true(all(!b$stacked$FairCIEligible))
  expect_true(all(b$stacked$FairCIReportingUse == "unavailable"))
})
