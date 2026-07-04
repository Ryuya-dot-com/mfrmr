test_that("bootstrap_mfrm_generalizability returns intervals and retained failures table", {
  if (!requireNamespace("lme4", quietly = TRUE)) {
    skip("lme4 (Suggests) not installed.")
  }
  fit <- make_toy_fit(maxit = 20)

  boot <- bootstrap_mfrm_generalizability(
    fit,
    reps = 2,
    ci = 0.80,
    seed = 20260615,
    progress = FALSE
  )

  expect_s3_class(boot, "mfrm_generalizability_bootstrap")
  expect_s3_class(boot$point_estimate, "mfrm_generalizability")
  expect_s3_class(boot$resamples, "mfrm_resamples")
  expect_true(all(c("overview", "intervals", "coefficient_draws",
                    "variance_draws", "failures", "settings") %in%
                    names(boot)))
  expect_equal(boot$overview$RepsRequested[1], 2L)
  expect_true(all(c("G", "Phi") %in% boot$intervals$Metric))
  expect_true(any(boot$intervals$Target == "variance_component"))
  expect_true(all(c("Lower", "Upper", "SuccessfulReps", "Method") %in%
                    names(boot$intervals)))
  expect_equal(boot$settings$ci, 0.80)

  boot_summary <- summary(boot)
  expect_s3_class(boot_summary, "summary.mfrm_generalizability_bootstrap")
  expect_true(all(c("overview", "key_metrics", "intervals",
                    "failures", "terminology") %in% names(boot_summary)))
  expect_output(print(boot_summary), "bootstrap G-study uncertainty")
  expect_output(print(boot), "G/Phi intervals")
})

test_that("mfrm_analysis_audit summarizes supplied and missing analysis layers", {
  if (!requireNamespace("lme4", quietly = TRUE)) {
    skip("lme4 (Suggests) not installed.")
  }
  fit <- make_toy_fit(maxit = 20)
  diag <- make_toy_diagnostics(fit)
  gt <- mfrm_generalizability(fit, progress = FALSE)
  ds <- mfrm_d_study(gt)
  cmp <- compare_mfrm_generalizability(
    fit,
    random_interactions = c("Person:Rater", "Rater:Criterion"),
    design_grid = data.frame(Rater = 2:3, Criterion = 2:3),
    progress = FALSE
  )
  boot <- bootstrap_mfrm_generalizability(
    fit,
    reps = 1,
    seed = 810,
    progress = FALSE
  )

  audit <- mfrm_analysis_audit(
    fit,
    diagnostics = diag,
    generalizability = gt,
    generalizability_bootstrap = boot,
    comparison = cmp,
    d_study = ds
  )

  expect_s3_class(audit, "mfrm_analysis_audit")
  expect_true(all(c("overview", "checkpoints", "next_actions",
                    "components", "terminology") %in% names(audit)))
  expect_true(all(c("Area", "Checkpoint", "Status", "Evidence",
                    "NextAction", "Boundary") %in% names(audit$checkpoints)))
  expect_true(any(audit$checkpoints$Checkpoint == "g_study_bootstrap"))
  expect_true(any(audit$checkpoints$Checkpoint ==
                    "g_study_interaction_identifiability"))
  cmp_checkpoint <- audit$checkpoints[
    audit$checkpoints$Checkpoint == "g_study_interaction_comparison",
    ,
    drop = FALSE
  ]
  expect_true(nrow(cmp_checkpoint) == 1L)
  expect_match(cmp_checkpoint$Evidence, "comparison review", fixed = TRUE)
  expect_true(any(audit$checkpoints$Status %in% c("ok", "missing", "review", "info")))
  expect_s3_class(summary(audit), "summary.mfrm_analysis_audit")
  expect_output(print(summary(audit)), "analysis audit summary")
  expect_output(print(audit), "Next actions")

  cmp_summary <- summary(cmp)
  expect_s3_class(cmp_summary, "summary.mfrm_generalizability_comparison")
  expect_true(all(c("overview", "comparison_review", "variance_delta",
                    "design_check_overview", "warnings") %in%
                    names(cmp_summary)))
  expect_output(print(cmp_summary), "G-study comparison summary")

  cmp_bundle <- build_summary_table_bundle(cmp, appendix_preset = "recommended")
  expect_s3_class(cmp_bundle, "mfrm_summary_table_bundle")
  expect_true("comparison_review" %in% names(cmp_bundle$tables))
  expect_true(any(cmp_bundle$table_index$Role == "gstudy_comparison_review"))

  audit_bundle <- build_summary_table_bundle(audit, appendix_preset = "recommended")
  expect_true("checkpoints" %in% names(audit_bundle$tables))
  expect_true(any(audit_bundle$table_index$Role == "analysis_review_checkpoints"))

  appendix_dir <- file.path(tempdir(), "mfrmr-gstudy-comparison-appendix")
  unlink(appendix_dir, recursive = TRUE, force = TRUE)
  appendix <- export_summary_appendix(
    cmp,
    output_dir = appendix_dir,
    prefix = "gstudy_cmp",
    preset = "recommended",
    overwrite = TRUE
  )
  expect_s3_class(appendix, "mfrm_summary_appendix_export")
  expect_true(any(appendix$selection_catalog$Role == "gstudy_comparison_review" &
                    appendix$selection_catalog$Selected %in% TRUE))
  expect_true(any(appendix$written_files$Component ==
                    "summary_mfrm_generalizability_comparison_comparison_review"))

  audit_missing <- mfrm_analysis_audit(fit)
  expect_true(any(audit_missing$checkpoints$Status == "missing"))
  expect_error(
    mfrm_analysis_audit(fit, run_diagnostics = NA),
    "run_diagnostics"
  )
})
