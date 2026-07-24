test_that("CRAN smoke covers the primary MML review and export route", {
  dat <- load_mfrmr_data("example_operational")
  roster_env <- new.env(parent = emptyenv())
  utils::data(
    list = "mfrmr_example_operational_design",
    package = "mfrmr",
    envir = roster_env
  )
  described <- describe_mfrm_data(
    dat,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 1,
    rating_max = 4,
    expected_design = roster_env$mfrmr_example_operational_design
  )
  expect_s3_class(described, "mfrm_data_description")
  expect_equal(described$structural_missingness$summary$MissingExpectedCells, 6L)
  expect_true(all(described$design_connectivity$Connected))

  fit <- fit_mfrm(
    dat,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "MML",
    model = "RSM",
    quad_points = 7,
    maxit = 30
  )
  expect_s3_class(fit, "mfrm_fit")
  expect_equal(fit$summary$Method, "MML")
  expect_true(isTRUE(fit$summary$Converged))
  expect_true(isTRUE(fit$summary$InferenceReady))
  expect_identical(fit$summary$ConvergenceSeverity, "pass")

  diagnostics <- diagnose_mfrm(
    fit,
    residual_pca = "none",
    diagnostic_mode = "both",
    fit_df_method = "both"
  )
  expect_s3_class(diagnostics, "mfrm_diagnostics")

  fit_summary <- summary(fit, profile = "fit", detail = "brief")
  facets_summary <- summary(
    fit,
    profile = "facets",
    detail = "brief",
    diagnostics = diagnostics,
    compute = "never"
  )
  expect_s3_class(fit_summary, "summary.mfrm_fit")
  expect_s3_class(facets_summary, "summary.mfrm_fit")
  expect_s3_class(facets_summary$results, "mfrm_results")

  native <- plot(
    fit,
    type = "wright",
    renderer = "native",
    show_ci = TRUE,
    top_n = Inf,
    draw = FALSE
  )
  score_values <- fit$prep$score_map$OriginalScore
  rubric_labels <- stats::setNames(paste("Rubric", score_values), score_values)
  facets <- plot_wright_unified(
    fit,
    renderer = "facets",
    show_ci = FALSE,
    top_n = Inf,
    category_labels = rubric_labels,
    draw = FALSE
  )
  pathway <- plot(
    fit,
    type = "fit_pathway",
    diagnostics = diagnostics,
    fit_stat = "Infit",
    include_person = TRUE,
    draw = FALSE
  )
  expect_s3_class(native, "mfrm_plot_data")
  expect_type(facets, "list")
  expect_identical(facets$renderer, "facets")
  expect_s3_class(pathway, "mfrm_plot_data")

  output_dir <- tempfile("mfrmr-cran-smoke-")
  on.exit(unlink(output_dir, recursive = TRUE, force = TRUE), add = TRUE)
  expect_warning(
    written <- export_mfrm(
      fit,
      diagnostics = diagnostics,
      output_dir = output_dir,
      prefix = "smoke",
      tables = c("facets", "summary", "steps")
    ),
    "not deidentify|identif|sensitive"
  )
  expect_s3_class(written, "data.frame")
  expect_true(all(file.exists(written$Path)))
  expect_true(all(!written$Deidentified))
  expect_true(all(!written$ShareableWithoutReview))
})
