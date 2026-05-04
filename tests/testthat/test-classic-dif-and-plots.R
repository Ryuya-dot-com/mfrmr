test_that("classic curve helpers return plot payloads", {
  fit <- make_toy_fit()

  exp_curve <- plot_expected_score_curve(fit, draw = FALSE)
  expect_s3_class(exp_curve, "mfrm_plot_data")
  expect_true(is.data.frame(exp_curve$data$expected))
  expect_true(all(c("Theta", "ExpectedScore", "CurveGroup") %in%
                    names(exp_curve$data$expected)))

  tcc <- plot_test_characteristic_curve(fit, draw = FALSE)
  expect_s3_class(tcc, "mfrm_plot_data")
  expect_true(is.data.frame(tcc$data$tcc))
  expect_true(all(c("Theta", "ExpectedTotalScore", "ExpectedMeanScore") %in%
                    names(tcc$data$tcc)))

  cumulative <- plot_cumulative_category_curve(fit, draw = FALSE)
  expect_s3_class(cumulative, "mfrm_plot_data")
  expect_true(is.data.frame(cumulative$data$cumulative))
  expect_true(all(c("Theta", "Category", "CumulativeProbability") %in%
                    names(cumulative$data$cumulative)))

  kidmap <- plot_kidmap(fit, draw = FALSE)
  expect_s3_class(kidmap, "mfrm_plot_data")
  expect_identical(kidmap$name, "kidmap_person_fit")
})

test_that("analyze_dif_classical returns generalized MH screening rows", {
  toy <- load_mfrmr_data("example_bias")
  out <- analyze_dif_classical(
    toy,
    facet = "Criterion",
    group = "Group",
    person = "Person",
    score = "Score",
    methods = "mantel_haenszel",
    min_obs = 5
  )
  expect_s3_class(out, "mfrm_dff")
  expect_s3_class(out, "mfrm_classical_dif")
  expect_true(is.data.frame(out$dif_table))
  expect_true(all(out$dif_table$Method == "mantel_haenszel"))
  expect_true(any(is.finite(out$dif_table$p_value)))
  expect_true(all(out$dif_table$ClassificationSystem == "classical_screening"))
  expect_match(paste(capture.output(print(out)), collapse = "\n"),
               "0 flagged", fixed = TRUE)

  p <- plot_dif_summary(out, draw = FALSE)
  expect_s3_class(p, "mfrm_plot_data")
  rpt <- dif_report(out)
  expect_s3_class(rpt, "mfrm_dif_report")
  expect_match(rpt$narrative, "classical DIF", fixed = TRUE)
})

test_that("analyze_dif_classical logistic route requires explicit polytomous threshold", {
  toy <- load_mfrmr_data("example_bias")
  unavailable <- analyze_dif_classical(
    toy,
    facet = "Criterion",
    group = "Group",
    person = "Person",
    score = "Score",
    methods = "logistic",
    min_obs = 5
  )
  expect_true(all(unavailable$dif_table$Method == "logistic_unavailable"))

  logistic <- analyze_dif_classical(
    toy,
    facet = "Criterion",
    group = "Group",
    person = "Person",
    score = "Score",
    methods = "logistic",
    min_obs = 5,
    logistic_threshold = 4
  )
  expect_true(any(logistic$dif_table$Method == "logistic_uniform"))
  expect_true(any(logistic$dif_table$Method == "logistic_nonuniform"))
  expect_true(any(is.finite(logistic$dif_table$p_value)))
})
