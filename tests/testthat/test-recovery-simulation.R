test_that("evaluate_mfrm_recovery returns row-level and summary recovery tables", {
  rec <- suppressWarnings(
    evaluate_mfrm_recovery(
      n_person = 12,
      n_rater = 2,
      n_criterion = 2,
      raters_per_person = 2,
      reps = 1,
      maxit = 8,
      include_diagnostics = TRUE,
      seed = 20260509
    )
  )

  expect_s3_class(rec, "mfrm_recovery_simulation")
  expect_s3_class(rec$recovery, "data.frame")
  expect_s3_class(rec$recovery_summary, "data.frame")
  expect_s3_class(rec$rep_overview, "data.frame")
  expect_s3_class(rec$diagnostic_oc, "data.frame")
  expect_s3_class(rec$diagnostic_oc_summary, "data.frame")
  expect_s3_class(rec$runtime, "data.frame")
  expect_true(all(c("Truth", "Estimate", "EstimateAligned", "ErrorAligned",
                    "RawTruth", "RawEstimate", "ComparisonScale") %in%
                    names(rec$recovery)))
  expect_true(all(c("ParameterType", "Facet", "RMSE", "Bias", "MAE",
                    "Correlation", "Coverage95", "McseBias", "McseRMSE") %in%
                    names(rec$recovery_summary)))
  expect_true(all(c("ScoreLevelsDeclared", "ScoreLevelsObserved",
                    "ZeroScoreLevels", "MinScoreCount",
                    "MinScoreProportion") %in%
                    names(rec$rep_overview)))
  expect_true(all(c("DiagnosticOK", "DiagnosticRows", "DiagnosticError") %in%
                    names(rec$rep_overview)))
  expect_true(all(c("Facet", "MeanSeparation", "MeanReliability",
                    "MeanInfit", "MeanOutfit", "ValidationUse") %in%
                    names(rec$diagnostic_oc_summary)))
  expect_true(all(rec$diagnostic_oc_summary$ValidationUse ==
                    "diagnostic_only_not_release_gate"))
  expect_true(all(is.finite(rec$rep_overview$MinScoreCount)))
  expect_true(any(rec$recovery$ParameterType == "facet"))
  expect_true(any(rec$recovery$ParameterType == "step"))
  expect_true(all(is.finite(rec$recovery_summary$RMSE)))
  expect_true(is.list(rec$ademp))
  expect_match(rec$ademp$aims, "parameter recovery", ignore.case = TRUE)
  expect_false(rec$settings$progress)
  expect_true(all(c("TotalElapsedSec", "CompletedReps", "FailedRuns",
                    "MeanRepElapsedSec", "ProgressShown") %in%
                    names(rec$runtime)))
  expect_equal(rec$runtime$CompletedReps[1], 1L)
  expect_false(rec$runtime$ProgressShown[1])

  s <- summary(rec)
  expect_s3_class(s, "summary.mfrm_recovery_simulation")
  expect_true(all(c("overview", "recovery_summary", "rep_overview",
                    "runtime", "diagnostic_oc", "diagnostic_oc_summary",
                    "reading_order", "next_actions", "reporting_notes",
                    "ademp") %in%
                    names(s)))
  expect_s3_class(s$runtime, "data.frame")
  expect_s3_class(s$reading_order, "data.frame")
  expect_s3_class(s$next_actions, "data.frame")
  expect_s3_class(s$reporting_notes, "data.frame")
  expect_true(all(c("Step", "Route", "WhatToRead") %in%
                    names(s$reading_order)))
  expect_true(all(c("Priority", "Area", "Status", "NextAction") %in%
                    names(s$next_actions)))
  expect_true(any(grepl("assess_mfrm_recovery", s$next_actions$NextAction, fixed = TRUE)))
  expect_true(all(c("DiagnosticRuns", "DiagnosticSuccessfulRuns",
                    "DiagnosticSuccessRate") %in% names(s$overview)))
  expect_equal(s$overview$DiagnosticRuns[1], 1L)
  expect_equal(s$overview$DiagnosticSuccessfulRuns[1], 1L)
  expect_equal(s$overview$DiagnosticSuccessRate[1], 1)
  expect_output(print(s), "Recommended reading order")
  expect_output(print(s), "Next actions")
  expect_output(print(s), "Reporting notes")
  expect_output(print(s), "Diagnostic operating-characteristic summary")
  expect_output(print(s), "Runtime")
  expect_output(print(s), "MFRM Parameter Recovery Simulation Summary")
  expect_output(print(rec), "MFRM Parameter Recovery Simulation Summary")

  summary_plot <- plot(rec, type = "summary", metric = "rmse", draw = FALSE)
  expect_s3_class(summary_plot, "mfrm_plot_data")
  expect_identical(summary_plot$name, "recovery_simulation")
  expect_identical(summary_plot$data$type, "summary")
  expect_true(all(c("plot_table", "metric", "metric_label", "reading_order",
                    "guidance", "figure_recipes", "interpretation_note",
                    "notes") %in%
                    names(summary_plot$data)))
  expect_true(nrow(summary_plot$data$plot_table) > 0)
  expect_s3_class(summary_plot$data$figure_recipes, "data.frame")
  expect_true(any(summary_plot$data$figure_recipes$FigureID ==
                    "recovery_metric_summary"))
  expect_true(any(summary_plot$data$figure_recipes$SelectedRoute))
  expect_true(any(grepl("first metric-level scan",
                        summary_plot$data$guidance, fixed = TRUE)))
  expect_match(summary_plot$data$interpretation_note,
               "Use assess_mfrm_recovery", fixed = TRUE)
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    expect_s3_class(as_ggplot(summary_plot), "ggplot")
    expect_s3_class(as_ggplot(rec, type = "summary", metric = "rmse"),
                    "ggplot")
  }

  error_plot <- plot(rec, type = "errors", parameter_type = "facet", draw = FALSE)
  expect_s3_class(error_plot, "mfrm_plot_data")
  expect_identical(error_plot$data$type, "errors")
  expect_true(all(error_plot$data$plot_table$ParameterType == "facet"))
  expect_true(any(error_plot$data$figure_recipes$SelectedRoute &
                    error_plot$data$figure_recipes$Type == "errors"))

  scatter_plot <- plot(rec, type = "scatter", comparison = "unaligned", draw = FALSE)
  expect_s3_class(scatter_plot, "mfrm_plot_data")
  expect_identical(scatter_plot$data$comparison, "unaligned")
  expect_true(any(grepl("truth-estimate",
                        scatter_plot$data$guidance, fixed = TRUE)))

  status_plot <- plot(rec, type = "replications", draw = FALSE)
  expect_s3_class(status_plot, "mfrm_plot_data")
  expect_identical(status_plot$data$type, "replications")
  expect_true(all(c("rep_overview", "reading_order", "guidance",
                    "figure_recipes") %in% names(status_plot$data)))
  expect_true(any(status_plot$data$figure_recipes$SelectedRoute &
                    status_plot$data$figure_recipes$Type == "replications"))

  assessment <- assess_mfrm_recovery(
    rec,
    min_reps = 1,
    max_rmse = c(default = 2),
    max_abs_bias = c(default = 1)
  )
  expect_s3_class(assessment, "mfrm_recovery_assessment")
  expect_s3_class(assessment$overview, "data.frame")
  expect_s3_class(assessment$checklist, "data.frame")
  expect_s3_class(assessment$condition_review, "data.frame")
  expect_s3_class(assessment$condition_reporting_notes, "data.frame")
  expect_s3_class(assessment$diagnostic_reporting_notes, "data.frame")
  expect_s3_class(assessment$diagnostic_review, "data.frame")
  expect_s3_class(assessment$metric_review, "data.frame")
  expect_s3_class(assessment$uncertainty_review, "data.frame")
  expect_s3_class(assessment$reading_order, "data.frame")
  expect_true(all(c("Step", "Route", "WhatToRead", "Purpose") %in%
                    names(assessment$reading_order)))
  expect_true(all(c("Section", "Item", "Status", "Evidence", "NextAction") %in%
                    names(assessment$checklist)))
  expect_true(all(c("RMSEStatus", "BiasStatus", "CoverageStatus",
                    "OverallStatus", "NextAction") %in%
                    names(assessment$metric_review)))
  expect_true(all(c("CoverageStatus", "SEStatus", "Interpretation", "NextAction") %in%
                    names(assessment$uncertainty_review)))
  expect_true(all(c("Model", "GPCMSlopeRegime", "StressLevel", "Status",
                    "ScoreSupportStatus", "ScoreSupportInterpretation",
                    "Interpretation", "NextAction") %in%
                    names(assessment$condition_review)))
  expect_true(all(c("ConditionArea", "ReportingAttention", "ConditionFinding",
                    "ValidationUse") %in%
                    names(assessment$condition_reporting_notes)))
  expect_true(all(assessment$condition_reporting_notes$ValidationUse ==
                    "generator_condition_not_release_gate"))
  expect_true(all(c("Facet", "ReportingAttention", "DiagnosticFinding",
                    "Evidence", "ValidationUse") %in%
                    names(assessment$diagnostic_reporting_notes)))
  expect_true(all(assessment$diagnostic_reporting_notes$ValidationUse ==
                    "diagnostic_only_not_release_gate"))
  expect_true(all(c("Facet", "MeanSeparation", "MeanReliability",
                    "DiagnosticAvailability", "Status", "ValidationUse",
                    "Interpretation", "NextAction") %in%
                    names(assessment$diagnostic_review)))
  expect_true(all(assessment$diagnostic_review$DiagnosticAvailability ==
                    "available"))
  expect_true(all(assessment$diagnostic_review$Status == "not_assessed"))
  expect_true(all(assessment$diagnostic_review$ValidationUse ==
                    "diagnostic_only_not_release_gate"))
  expect_identical(assessment$condition_review$Status[1], "not_assessed")
  expect_true(length(assessment$next_actions) > 0)

  assessment_summary <- summary(assessment)
  expect_s3_class(assessment_summary, "summary.mfrm_recovery_assessment")
  expect_s3_class(assessment_summary$condition_review, "data.frame")
  expect_s3_class(assessment_summary$condition_reporting_notes, "data.frame")
  expect_s3_class(assessment_summary$diagnostic_reporting_notes, "data.frame")
  expect_s3_class(assessment_summary$diagnostic_review, "data.frame")
  expect_s3_class(assessment_summary$uncertainty_review, "data.frame")
  expect_s3_class(assessment_summary$reading_order, "data.frame")
  expect_output(print(assessment_summary), "MFRM Recovery Adequacy Assessment")
  expect_output(print(assessment_summary), "Recommended reading order")
  expect_output(print(assessment_summary), "Condition review")
  expect_output(print(assessment_summary), "Condition reporting notes")
  expect_output(print(assessment_summary), "Diagnostic reporting notes")
  expect_output(print(assessment_summary), "Diagnostic operating-characteristic review")
  expect_output(print(assessment_summary), "Uncertainty review")
  expect_output(print(assessment), "MFRM Recovery Adequacy Assessment")

  assessment_status_plot <- plot(assessment, type = "status", draw = FALSE)
  expect_s3_class(assessment_status_plot, "mfrm_plot_data")
  expect_identical(assessment_status_plot$name, "recovery_assessment")
  expect_identical(assessment_status_plot$data$type, "status")
  expect_true(all(c("plot_table", "section_status", "status_counts",
                    "checklist", "condition_reporting_notes",
                    "condition_review", "diagnostic_reporting_notes",
                    "diagnostic_review",
                    "reading_order", "guidance") %in%
                    names(assessment_status_plot$data)))
  expect_s3_class(assessment_status_plot$data$condition_reporting_notes,
                  "data.frame")
  expect_s3_class(assessment_status_plot$data$diagnostic_reporting_notes,
                  "data.frame")
  expect_true(all(assessment_status_plot$data$condition_reporting_notes$ValidationUse ==
                    "generator_condition_not_release_gate"))
  expect_true(all(assessment_status_plot$data$diagnostic_reporting_notes$ValidationUse ==
                    "diagnostic_only_not_release_gate"))
  expect_true(nrow(assessment_status_plot$data$status_counts) > 0)
  expect_true("AttentionOrder" %in% names(assessment_status_plot$data$section_status))
  expect_true(any(grepl("Read this plot before metric-level plots",
                        assessment_status_plot$data$guidance, fixed = TRUE)))

  assessment_metric_plot <- plot(assessment, type = "metrics",
                                 metric = "rmse", draw = FALSE)
  expect_s3_class(assessment_metric_plot, "mfrm_plot_data")
  expect_identical(assessment_metric_plot$name, "recovery_assessment")
  expect_identical(assessment_metric_plot$data$type, "metrics")
  expect_identical(assessment_metric_plot$data$metric, "rmse")
  expect_true(all(c("Value", "Limit", "Status", "AttentionOrder") %in%
                    names(assessment_metric_plot$data$plot_table)))
  expect_true(all(c("metric_review", "condition_reporting_notes",
                    "condition_review", "diagnostic_reporting_notes",
                    "diagnostic_review",
                    "reading_order", "guidance") %in%
                    names(assessment_metric_plot$data)))
  expect_s3_class(assessment_metric_plot$data$condition_reporting_notes,
                  "data.frame")
  expect_s3_class(assessment_metric_plot$data$diagnostic_reporting_notes,
                  "data.frame")
  expect_true(nrow(assessment_metric_plot$data$plot_table) > 0)
  expect_true(any(grepl("sorted by status priority",
                        assessment_metric_plot$data$guidance, fixed = TRUE)))

  assessment_no_limits <- assess_mfrm_recovery(
    rec,
    min_reps = 1,
    min_se_available = NULL,
    max_mcse_rmse_ratio = NULL
  )
  rmse_row <- assessment_no_limits$checklist[
    assessment_no_limits$checklist$Item == "RMSE threshold",
    ,
    drop = FALSE
  ]
  expect_identical(rmse_row$Status[1], "not_assessed")
  expect_error(
    evaluate_mfrm_recovery(reps = 1, progress = NA),
    "`progress` must be a single TRUE/FALSE value"
  )

  expect_identical(
    mfrmr:::recovery_assessment_coverage_status(0.93, target = NULL),
    "not_assessed"
  )
  expect_identical(
    mfrmr:::recovery_assessment_coverage_status(NA_real_, target = NULL),
    "not_available"
  )
})

test_that("evaluate_mfrm_recovery carries opt-in MML population SD estimates", {
  rec <- suppressWarnings(evaluate_mfrm_recovery(
    n_person = 16,
    n_rater = 2,
    n_criterion = 2,
    raters_per_person = 2,
    reps = 1,
    theta_sd = 1.35,
    fit_method = "MML",
    model = "RSM",
    quad_points = 5,
    maxit = 20,
    estimate_population_sd = TRUE,
    seed = 20260614
  ))

  expect_s3_class(rec, "mfrm_recovery_simulation")
  expect_true(all(c("PopulationSDMode", "PopulationPriorSD",
                    "EstimatedPopulationSD", "PopulationSDSE",
                    "PopulationSDSEStatus") %in% names(rec$rep_overview)))
  expect_true(rec$rep_overview$RunOK[1])
  expect_identical(rec$rep_overview$PopulationSDMode[1], "estimated")
  expect_true(is.finite(rec$rep_overview$EstimatedPopulationSD[1]))
  expect_true(rec$settings$estimate_population_sd)
  expect_equal(rec$settings$population_prior_sd, 1, tolerance = 1e-12)

  expect_error(
    evaluate_mfrm_recovery(
      n_person = 8,
      n_rater = 2,
      n_criterion = 2,
      reps = 1,
      fit_method = "JML",
      estimate_population_sd = TRUE
    ),
    "requires `fit_method = \"MML\"`",
    fixed = TRUE
  )
  gpcm_rec <- suppressWarnings(evaluate_mfrm_recovery(
    n_person = 12,
    n_rater = 2,
    n_criterion = 2,
    raters_per_person = 2,
    reps = 1,
    fit_method = "MML",
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    quad_points = 5,
    maxit = 20,
    estimate_population_sd = TRUE,
    seed = 20260615
  ))
  expect_true(gpcm_rec$rep_overview$RunOK[1])
  expect_identical(gpcm_rec$rep_overview$PopulationSDMode[1], "estimated")
  expect_true(is.finite(gpcm_rec$rep_overview$EstimatedPopulationSD[1]))
})

test_that("evaluate_mfrm_recovery keeps optional diagnostics non-gating", {
  rec <- suppressWarnings(
    evaluate_mfrm_recovery(
      n_person = 10,
      n_rater = 2,
      n_criterion = 2,
      raters_per_person = 2,
      reps = 1,
      maxit = 5,
      include_diagnostics = FALSE,
      seed = 20260513
    )
  )

  expect_s3_class(rec, "mfrm_recovery_simulation")
  expect_equal(nrow(rec$diagnostic_oc), 0L)
  expect_equal(nrow(rec$diagnostic_oc_summary), 0L)
  expect_true(all(is.na(rec$rep_overview$DiagnosticOK)))
  expect_true(all(is.na(rec$rep_overview$DiagnosticRows)))

  s <- summary(rec)
  expect_equal(s$overview$DiagnosticRuns[1], 0L)
  expect_equal(s$overview$DiagnosticSuccessfulRuns[1], 0L)
  expect_true(is.na(s$overview$DiagnosticSuccessRate[1]))
  expect_s3_class(s$diagnostic_oc, "data.frame")
  expect_s3_class(s$diagnostic_oc_summary, "data.frame")

  assessment <- assess_mfrm_recovery(
    rec,
    min_reps = 1,
    min_se_available = NULL,
    max_mcse_rmse_ratio = NULL
  )
  expect_s3_class(assessment$diagnostic_review, "data.frame")
  expect_equal(nrow(assessment$diagnostic_review), 0L)
  expect_s3_class(assessment$diagnostic_reporting_notes, "data.frame")
  expect_equal(nrow(assessment$diagnostic_reporting_notes), 0L)
  expect_false(any(grepl("fit/separation", assessment$checklist$Item,
                         fixed = TRUE)))
})

test_that("evaluate_mfrm_recovery records diagnostic failures without failing recovery", {
  testthat::local_mocked_bindings(
    diagnose_mfrm = function(...) stop("forced diagnostic failure"),
    .package = "mfrmr"
  )

  rec <- suppressWarnings(
    evaluate_mfrm_recovery(
      n_person = 10,
      n_rater = 2,
      n_criterion = 2,
      raters_per_person = 2,
      reps = 1,
      maxit = 5,
      include_diagnostics = TRUE,
      seed = 20260514
    )
  )

  expect_s3_class(rec, "mfrm_recovery_simulation")
  expect_true(rec$rep_overview$RunOK[1])
  expect_false(rec$rep_overview$DiagnosticOK[1])
  expect_equal(rec$rep_overview$DiagnosticRows[1], 1L)
  expect_match(rec$rep_overview$DiagnosticError[1], "forced diagnostic failure",
               fixed = TRUE)
  expect_equal(nrow(rec$diagnostic_oc), 1L)
  expect_false(rec$diagnostic_oc$DiagnosticOK[1])
  expect_equal(rec$diagnostic_oc$ValidationUse[1],
               "diagnostic_only_not_release_gate")
  expect_match(rec$diagnostic_oc$DiagnosticError[1], "forced diagnostic failure",
               fixed = TRUE)
  expect_equal(nrow(rec$diagnostic_oc_summary), 0L)
  expect_true(any(grepl("optional fit/separation diagnostic", rec$notes,
                        fixed = TRUE)))

  s <- summary(rec)
  expect_equal(s$overview$DiagnosticRuns[1], 1L)
  expect_equal(s$overview$DiagnosticSuccessfulRuns[1], 0L)
  expect_equal(s$overview$DiagnosticSuccessRate[1], 0)

  assessment <- assess_mfrm_recovery(
    rec,
    min_reps = 1,
    min_se_available = NULL,
    max_mcse_rmse_ratio = NULL
  )
  expect_equal(nrow(assessment$diagnostic_review), 0L)
  expect_equal(nrow(assessment$diagnostic_reporting_notes), 0L)
  expect_true(any(grepl("Fit/separation operating characteristics are diagnostic context",
                        assessment$notes, fixed = TRUE)))
})

test_that("evaluate_mfrm_recovery refits on the declared generator score support", {
  sim <- simulate_mfrm_data(
    n_person = 10,
    n_rater = 2,
    n_criterion = 2,
    raters_per_person = 2,
    score_levels = 5,
    seed = 20260510
  )
  fit_args <- mfrmr:::simulation_add_fit_score_support(list(data = sim), sim)
  expect_identical(fit_args$rating_min, 1L)
  expect_identical(fit_args$rating_max, 5L)

  messages <- character()
  rec <- withCallingHandlers(
    suppressWarnings(
      evaluate_mfrm_recovery(
        n_person = 10,
        n_rater = 2,
        n_criterion = 2,
        raters_per_person = 2,
        score_levels = 5,
        reps = 1,
        maxit = 5,
        seed = 20260511
      )
    ),
    message = function(m) {
      messages <<- c(messages, conditionMessage(m))
      invokeRestart("muffleMessage")
    }
  )

  expect_s3_class(rec, "mfrm_recovery_simulation")
  expect_false(any(grepl("Rating range inferred", messages, fixed = TRUE)))
})

test_that("evaluate_mfrm_recovery supports fitted bounded GPCM slope rows", {
  spec <- build_mfrm_sim_spec(
    n_person = 14,
    n_rater = 2,
    n_criterion = 2,
    raters_per_person = 2,
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    slopes = c(0.85, 1.15),
    assignment = "crossed"
  )
  expect_identical(spec$slope_regime, "moderate")

  unit_spec <- build_mfrm_sim_spec(
    n_person = 10,
    n_rater = 2,
    n_criterion = 2,
    raters_per_person = 2,
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    assignment = "crossed"
  )
  flat_spec <- build_mfrm_sim_spec(
    n_person = 10,
    n_rater = 2,
    n_criterion = 2,
    raters_per_person = 2,
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    slopes = c(0.99, 1.01),
    assignment = "crossed"
  )
  dispersed_spec <- build_mfrm_sim_spec(
    n_person = 10,
    n_rater = 2,
    n_criterion = 2,
    raters_per_person = 2,
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    slopes = c(0.45, 2.20),
    assignment = "crossed"
  )
  expect_identical(unit_spec$slope_regime, "unit_slopes")
  expect_identical(flat_spec$slope_regime, "near_flat")
  expect_identical(dispersed_spec$slope_regime, "high_dispersion")

  sim_flat <- simulate_mfrm_data(sim_spec = flat_spec, seed = 20260512)
  expect_identical(attr(sim_flat, "mfrm_simulation_spec")$slope_regime, "near_flat")

  rec <- suppressWarnings(
    evaluate_mfrm_recovery(
      sim_spec = spec,
      reps = 1,
      fit_method = "MML",
      quad_points = 5,
      maxit = 12,
      seed = 20260510,
      include_person = FALSE
    )
  )

  expect_s3_class(rec, "mfrm_recovery_simulation")
  expect_identical(rec$settings$gpcm_slope_regime, "moderate")
  expect_identical(rec$ademp$methods$gpcm_slope_regime, "moderate")
  expect_true(any(rec$recovery$ParameterType == "slope"))
  slope_rows <- rec$recovery[rec$recovery$ParameterType == "slope", , drop = FALSE]
  expect_true(all(slope_rows$ComparisonScale == "log_slope"))
  expect_true(all(!slope_rows$AlignWithinGroup))
  expect_equal(slope_rows$AlignmentShift, rep(0, nrow(slope_rows)), tolerance = 1e-12)
  expect_true(all(slope_rows$RecoveryBasis == "geometric_mean_one_log_slope"))
  expect_true(all(is.finite(slope_rows$RawTruth)))
  expect_true(all(is.finite(slope_rows$RawEstimate)))
  expect_equal(exp(mean(log(slope_rows$RawTruth))), 1, tolerance = 1e-12)
  expect_true(any(rec$recovery_summary$ParameterType == "slope"))
  expect_true(any(grepl("Bounded GPCM recovery", rec$notes, fixed = TRUE)))

  slope_plot <- plot(rec, type = "summary", metric = "bias",
                     parameter_type = "slope", draw = FALSE)
  expect_s3_class(slope_plot, "mfrm_plot_data")
  expect_true(all(slope_plot$data$plot_table$ParameterType == "slope"))

  assessment <- assess_mfrm_recovery(
    rec,
    min_reps = 1,
    max_rmse = c(slope = 2),
    max_abs_bias = c(slope = 1),
    min_se_available = NULL,
    max_mcse_rmse_ratio = NULL
  )
  expect_s3_class(assessment, "mfrm_recovery_assessment")
  expect_identical(assessment$condition_review$GPCMSlopeRegime[1], "moderate")
  expect_identical(assessment$condition_review$StressLevel[1], "moderate")
  expect_identical(assessment$condition_review$Status[1], "ok")
  expect_true(assessment$condition_review$ScoreSupportStatus[1] %in%
                c("ok", "review"))
  expect_true(is.finite(assessment$condition_review$MaxAbsCenteredLogSlope[1]))
  slope_review <- assessment$metric_review[
    assessment$metric_review$ParameterType == "slope",
    ,
    drop = FALSE
  ]
  expect_true(nrow(slope_review) > 0)
  expect_true(all(is.finite(slope_review$RMSELimit)))
  slope_uncertainty <- assessment$uncertainty_review[
    assessment$uncertainty_review$ParameterType == "slope",
    ,
    drop = FALSE
  ]
  expect_true(nrow(slope_uncertainty) > 0)
  expect_true(all(c("CoverageStatus", "SEStatus", "Interpretation", "NextAction") %in%
                    names(slope_uncertainty)))
  expect_true(all(nzchar(slope_uncertainty$Interpretation)))
})
