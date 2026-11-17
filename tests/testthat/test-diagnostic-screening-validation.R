test_that("evaluate_mfrm_diagnostic_screening reports well-specified and local-dependence scenario contrasts", {
  for (model in c("RSM", "PCM")) {
    diag_eval <- suppressWarnings(mfrmr::evaluate_mfrm_diagnostic_screening(
      design = list(person = 18, rater = 3, criterion = 3, assignment = 3),
      reps = 2,
      model = model,
      maxit = 8,
      quad_points = 7,
      local_dependence_sd = 1.0,
      seed = 20260409
    ))

    expect_s3_class(diag_eval, "mfrm_diagnostic_screening")
    expect_true(is.data.frame(diag_eval$results))
    expect_true(is.data.frame(diag_eval$scenario_summary))
    expect_true(is.data.frame(diag_eval$performance_summary))
    expect_true(is.data.frame(diag_eval$scenario_contrast))
    expect_true(all(c("well_specified", "local_dependence") %in% diag_eval$scenario_summary$Scenario))
    expect_true(all(diag_eval$results$RunOK))
    expect_true(all(diag_eval$results$MarginalAvailable))
    expect_true(nrow(diag_eval$scenario_contrast) >= 1)
    expect_true(all(diag_eval$scenario_contrast$Scenario == "local_dependence"))
    expect_true("StrictSignalImproved" %in% names(diag_eval$scenario_contrast))
    expect_true("StrictSignalDominatesLegacy" %in% names(diag_eval$scenario_contrast))
    # One or two draws do not guarantee a stronger signal under misspecification.
    legacy <- split(diag_eval$results$LegacyMeanAbsZ, diag_eval$results$Scenario)
    expect_true(all(is.finite(unlist(legacy))))
    expected_delta <- vapply(as.character(diag_eval$scenario_contrast$Scenario),
      function(scenario) mean(legacy[[scenario]]) - mean(legacy$well_specified),
      numeric(1))
    expect_equal(diag_eval$scenario_contrast$DeltaLegacyMeanAbsZ,
                 unname(expected_delta))
    expect_true(all(c("type_I_proxy", "sensitivity_proxy") %in% diag_eval$performance_summary$EvaluationUse))
    expect_true(all(diag_eval$performance_summary$MeanElapsedSec >= 0))
    expect_true(all(diag_eval$scenario_summary$PairwiseAvailabilityRate > 0))
    expect_true(length(diag_eval$notes) >= 1)

    if (identical(model, "RSM")) {
      overview_plot <- plot(diag_eval, type = "overview", draw = FALSE)
      expect_s3_class(overview_plot, "ggplot")
      expect_s3_class(attr(overview_plot, "mfrmr_plot_data"), "mfrm_plot_data")
      expect_identical(attr(overview_plot, "mfrmr_plot_data")$name, "diagnostic_screening")
      overview_pd <- mfrmr::plot_data(overview_plot)
      expect_identical(overview_pd$type, "overview")
      expect_true(all(c("Signal", "Value", "SourceTable", "group") %in% names(overview_pd$plot_long)))
      expect_true(any(overview_pd$plot_long$Signal == "Strict combined any-flag rate"))
      expect_true(any(mfrmr::plot_data(diag_eval, type = "overview", component = "plot_long")$Signal == "Strict combined any-flag rate"))
      expect_true(all(c("overview", "reading_order", "next_actions", "reporting_notes", "figure_recipes") %in% names(overview_pd)))
      expect_true(any(mfrmr::plot_data(overview_plot, component = "next_actions")$Area == "Appendix and plot-data handoff"))
      expect_true(any(mfrmr::plot_data(overview_plot, component = "figure_recipes")$FigureID == "overview_rates"))
      expect_true(any(mfrmr::plot_data_components(overview_plot)$Component == "next_actions"))

      diag_summary <- summary(diag_eval)
      expect_s3_class(diag_summary, "summary.mfrm_diagnostic_screening")
      expect_true(all(c(
        "overview", "reading_order", "next_actions", "reporting_notes", "figure_recipes",
        "scenario_summary", "performance_summary",
        "plot_overview_rate", "plot_runtime"
      ) %in% names(diag_summary)))
      expect_true(any(diag_summary$reading_order$Table == "scenario_summary"))
      expect_true(any(diag_summary$reading_order$Table == "figure_recipes"))
      expect_true(any(diag_summary$next_actions$Area == "Appendix and plot-data handoff"))
      expect_true(any(diag_summary$figure_recipes$SummaryTable == "plot_overview_rate"))
      expect_true(any(grepl("export_summary_appendix", diag_summary$next_actions$Route, fixed = TRUE)))
      expect_true(any(grepl("standalone validation criteria", diag_summary$reporting_notes$ReportingBoundary, fixed = TRUE)))
      expect_true(any(diag_summary$plot_overview_rate$Signal == "Strict combined any-flag rate"))
      expect_true(any(grepl("operating-characteristic", diag_summary$notes, fixed = TRUE)))

      contrast_plot <- plot(diag_eval, type = "contrast", metric = "count", draw = FALSE)
      expect_s3_class(contrast_plot, "ggplot")
      expect_identical(mfrmr::plot_data(contrast_plot, "type"), "contrast")
      expect_true(any(mfrmr::plot_data(contrast_plot, "plot_long")$Metric == "DeltaPairwiseFlaggedLevelPairs"))
      expect_true(all(mfrmr::plot_data(contrast_plot, "plot_long")$Scenario == "local_dependence"))
    }
  }
})

test_that("evaluate_mfrm_diagnostic_screening supports latent misspecification scenarios", {
  for (model in c("RSM", "PCM")) {
    diag_eval <- suppressWarnings(mfrmr::evaluate_mfrm_diagnostic_screening(
      design = list(person = 18, rater = 3, criterion = 3, assignment = 3),
      reps = 1,
      scenarios = c("well_specified", "latent_misspecification"),
      model = model,
      maxit = 8,
      quad_points = 7,
      seed = 20260409
    ))

    expect_s3_class(diag_eval, "mfrm_diagnostic_screening")
    expect_true(all(c("well_specified", "latent_misspecification") %in% diag_eval$scenario_summary$Scenario))
    expect_true(all(diag_eval$results$RunOK))
    expect_true(all(diag_eval$results$MarginalAvailable))
    expect_true(is.data.frame(diag_eval$performance_summary))
    expect_true(nrow(diag_eval$scenario_contrast) >= 1)
    expect_true(all(diag_eval$scenario_contrast$Scenario == "latent_misspecification"))
    expect_true(any(diag_eval$performance_summary$EvaluationUse == "type_I_proxy"))
    expect_true(any(diag_eval$performance_summary$EvaluationUse == "sensitivity_proxy"))
    expect_true(all(diag_eval$scenario_summary$PairwiseAvailabilityRate > 0))
    expect_true(length(diag_eval$notes) >= 1)
  }
})

test_that("evaluate_mfrm_diagnostic_screening supports step-structure misspecification scenarios", {
  for (model in c("RSM", "PCM")) {
    diag_eval <- suppressWarnings(mfrmr::evaluate_mfrm_diagnostic_screening(
      design = list(person = 30, rater = 3, criterion = 3, assignment = 3),
      reps = 1,
      scenarios = c("well_specified", "step_structure_misspecification"),
      model = model,
      maxit = 10,
      quad_points = 9,
      seed = 20260409
    ))

    expect_s3_class(diag_eval, "mfrm_diagnostic_screening")
    expect_true(all(c("well_specified", "step_structure_misspecification") %in% diag_eval$scenario_summary$Scenario))
    expect_true(all(diag_eval$results$RunOK))
    expect_true(all(diag_eval$results$MarginalAvailable))
    expect_true(is.data.frame(diag_eval$performance_summary))
    expect_true(nrow(diag_eval$scenario_contrast) >= 1)
    expect_true(all(diag_eval$scenario_contrast$Scenario == "step_structure_misspecification"))
    expect_true("StrictSignalImproved" %in% names(diag_eval$scenario_contrast))
    expect_true("StrictSignalDominatesLegacy" %in% names(diag_eval$scenario_contrast))
    # One or two draws do not guarantee a stronger signal under misspecification.
    legacy <- split(diag_eval$results$LegacyMeanAbsZ, diag_eval$results$Scenario)
    expect_true(all(is.finite(unlist(legacy))))
    expected_delta <- vapply(as.character(diag_eval$scenario_contrast$Scenario),
      function(scenario) mean(legacy[[scenario]]) - mean(legacy$well_specified),
      numeric(1))
    expect_equal(diag_eval$scenario_contrast$DeltaLegacyMeanAbsZ,
                 unname(expected_delta))
    performance <- diag_eval$performance_summary
    for (i in which(performance$Scenario != "well_specified")) {
      rows <- diag_eval$results[diag_eval$results$Scenario == performance$Scenario[i], ]
      expect_equal(performance$LegacySensitivityProxy[i], mean(rows$LegacyFlaggedLevels > 0))
      expect_equal(performance$StrictSensitivityProxy[i],
        mean(rows$MarginalFlaggedGroups > 0 | rows$PairwiseFlaggedLevelPairs > 0))
    }
    expect_true(all(diag_eval$scenario_summary$PairwiseAvailabilityRate > 0))
    expect_true(length(diag_eval$notes) >= 1)
  }
})

test_that("evaluate_mfrm_diagnostic_screening can retain report-index review signals", {
  diagnose <- mfrmr::diagnose_mfrm
  diagnostic_calls <- list()
  testthat::local_mocked_bindings(
    diagnose_mfrm = function(fit, ...) {
      diagnostic_calls[[length(diagnostic_calls) + 1L]] <<- list(...)
      diagnose(fit, ...)
    },
    .package = "mfrmr"
  )
  diag_eval <- suppressWarnings(mfrmr::evaluate_mfrm_diagnostic_screening(
    design = list(person = 14, rater = 3, criterion = 3, assignment = 3),
    reps = 1,
    scenarios = "well_specified",
    model = "RSM",
    maxit = 8,
    quad_points = 7,
    include_report = TRUE,
    report_include = c("fit", "diagnostics", "tables", "precision", "reporting"),
    seed = 20260409
  ))

  expect_length(diagnostic_calls, 1L)
  expect_identical(diagnostic_calls[[1L]]$fit_df_method, "facets")
  expect_s3_class(diag_eval, "mfrm_diagnostic_screening")
  expect_true(all(c(
    "ReportIndexAvailable", "ReportFitReadiness", "ReportFitReviewSignalCount",
    "ReportPrecisionReadiness", "ReportPrecisionReviewSignalCount"
  ) %in% names(diag_eval$results)))
  expect_true(all(diag_eval$results$ReportIndexAvailable))
  expect_true(is.data.frame(diag_eval$report_signal_summary))
  expect_true(all(c(
    "ReportIndexAvailabilityRate", "MeanReportReviewAreas",
    "FitReportReviewRate", "MeanFitReportSignals"
  ) %in% names(diag_eval$report_signal_summary)))
  expect_true(all(diag_eval$report_signal_summary$ReportIndexAvailabilityRate > 0))

  report_plot <- plot(diag_eval, type = "report", metric = "rate", draw = FALSE)
  expect_s3_class(report_plot, "ggplot")
  expect_identical(mfrmr::plot_data(report_plot, "type"), "report")
  expect_true(any(mfrmr::plot_data(report_plot, "plot_long")$Signal == "Report-index availability rate"))
  expect_true(any(mfrmr::plot_data(report_plot, "plot_long")$Signal == "Fit review rate"))
  expect_true(any(mfrmr::plot_data(report_plot, component = "next_actions")$Area == "Report-index signals" &
                    mfrmr::plot_data(report_plot, component = "next_actions")$Status == "ok"))

  count_plot <- plot(diag_eval, type = "overview", metric = "count", draw = FALSE)
  expect_s3_class(count_plot, "ggplot")
  expect_true(any(mfrmr::plot_data(count_plot, "plot_long")$Signal == "Mean report fit signals"))
  expect_true(any(mfrmr::plot_data_components(count_plot)$Component == "plot_long"))
  expect_true(any(mfrmr::plot_data_components(count_plot)$Component == "reporting_notes"))
  expect_true(any(mfrmr::plot_data_components(count_plot)$Component == "figure_recipes"))

  diag_summary <- summary(diag_eval)
  expect_s3_class(diag_summary, "summary.mfrm_diagnostic_screening")
  expect_true(nrow(diag_summary$report_signal_summary) > 0L)
  expect_true(any(diag_summary$reading_order$Table == "report_signal_summary"))
  expect_true(any(diag_summary$figure_recipes$FigureID == "report_review_rates" &
                    diag_summary$figure_recipes$Availability == "available_when_report_rows_exist"))
  expect_true(any(diag_summary$next_actions$Area == "Report-index signals" &
                    diag_summary$next_actions$Status == "ok"))
  expect_true(any(grepl("report-index availability", diag_summary$reporting_notes$Evidence, fixed = TRUE)))
  expect_true(any(diag_summary$plot_report_rate$Signal == "Report-index availability rate"))
})

test_that("evaluate_mfrm_diagnostic_screening supports caveated GPCM screening output", {
  diag_eval <- suppressWarnings(mfrmr::evaluate_mfrm_diagnostic_screening(
    design = list(person = 10, rater = 2, criterion = 2, assignment = 2),
    reps = 1,
    scenarios = c("well_specified", "local_dependence"),
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    slopes = c(C01 = 1, C02 = 1),
    maxit = 10,
    seed = 1
  ))

  expect_s3_class(diag_eval, "mfrm_diagnostic_screening")
  expect_identical(diag_eval$settings$model, "GPCM")
  expect_identical(diag_eval$settings$gpcm_screening_status, "supported_with_caveat")
  expect_true(nrow(diag_eval$gpcm_boundary) > 0L)
  expect_true(all(diag_eval$results$Model == "GPCM"))
  expect_true(any(grepl("slope-aware operating-characteristic", diag_eval$notes, fixed = TRUE)))

  diag_summary <- summary(diag_eval)
  expect_s3_class(diag_summary, "summary.mfrm_diagnostic_screening")
  expect_true(nrow(diag_summary$gpcm_boundary) > 0L)
  expect_true(any(grepl("slope-aware operating-characteristic", diag_summary$notes, fixed = TRUE)))
  printed <- capture.output(print(diag_summary))
  expect_true(any(grepl("GPCM boundary", printed, fixed = TRUE)))

  diag_plot <- plot(diag_eval, type = "overview", metric = "rate", draw = FALSE)
  expect_s3_class(diag_plot, "ggplot")
  expect_true(nrow(mfrmr::plot_data(diag_plot, "gpcm_boundary")) > 0L)
})

test_that("screening report reuse is limited to matching PCA-free diagnostics", {
  bundle <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
  supplied <- list()
  modes <- character()
  fit_failure <- diagnostic_failure <- report_failure <- FALSE
  index <- data.frame(
    Area = c("Fit", "Precision", "Misfit / pathway", "Other"),
    Readiness = c("review", "ready", "request_if_needed", NA_character_),
    ReviewSignalCount = c(2, 0, NA_real_, NA_real_)
  )
  testthat::local_mocked_bindings(
    fit_mfrm = function(...) {
      if (fit_failure) stop("fit failed", call. = FALSE)
      bundle$fit
    },
    diagnose_mfrm = function(fit, residual_pca, ...) {
      if (diagnostic_failure) stop("diagnostics failed", call. = FALSE)
      modes <<- c(modes, residual_pca)
      bundle$diagnostics
    },
    mfrm_results = function(fit, include, diagnostics = NULL, ...) {
      supplied[[length(supplied) + 1L]] <<- list(diagnostics = diagnostics)
      list()
    },
    mfrm_report = function(...) {
      if (report_failure) stop("report failed", call. = FALSE)
      list(report_index = index)
    },
    .package = "mfrmr"
  )
  run <- function(pca = "none", include = TRUE) {
    evaluate_mfrm_diagnostic_screening(
      design = list(person = 6, rater = 2, criterion = 2, assignment = 2),
      reps = 1, scenarios = "well_specified", residual_pca = pca,
      include_report = include, seed = 123
    )
  }
  expected <- list(
    ReportIndexAvailable = TRUE, ReportAuditError = NA_character_,
    ReportReviewAreas = 1L, ReportReadyAreas = 1L,
    ReportRequestIfNeededAreas = 1L, ReportFitReadiness = "review",
    ReportFitReviewSignalCount = 2, ReportPrecisionReadiness = "ready",
    ReportPrecisionReviewSignalCount = 0,
    ReportMisfitReadiness = "request_if_needed",
    ReportMisfitReviewSignalCount = NA_real_
  )
  for (pca in c("none", "overall", "facet", "both")) {
    result <- run(pca)
    expect_identical(as.list(result$results[1, names(expected)]), expected)
    expect_identical(tail(supplied, 1)[[1]]$diagnostics,
                     if (pca == "none") bundle$diagnostics else NULL)
  }
  expect_identical(modes, c("none", "overall", "facet", "both"))
  expect_true(run(include = FALSE)$results$RunOK)
  expect_length(supplied, 4L)

  report_failure <- TRUE
  failed_report <- run()$results
  expect_true(failed_report$RunOK)
  expect_false(failed_report$ReportIndexAvailable)
  expect_identical(failed_report$ReportAuditError, "report failed")
  expect_true(is.na(failed_report$ReportFitReviewSignalCount))

  diagnostic_failure <- TRUE
  failed_diagnostic <- run()$results
  expect_false(failed_diagnostic$RunOK)
  expect_identical(failed_diagnostic$Error, "diagnostics failed")
  expect_length(supplied, 5L)

  fit_failure <- TRUE
  failed_fit <- run()$results
  expect_false(failed_fit$RunOK)
  expect_identical(failed_fit$Error, "fit failed")
  expect_length(supplied, 5L)
})
