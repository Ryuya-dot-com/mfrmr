test_that("build_model_choice_review bundles comparison and user guidance", {
  toy <- load_mfrmr_data("example_core")
  keep_people <- unique(toy$Person)[1:8]
  toy <- toy[toy$Person %in% keep_people, , drop = FALSE]

  rsm_fit <- suppressWarnings(fit_mfrm(
    toy,
    "Person",
    c("Rater", "Criterion"),
    "Score",
    method = "MML",
    model = "RSM",
    quad_points = 5,
    maxit = 18
  ))
  gpcm_fit <- suppressWarnings(fit_mfrm(
    toy,
    "Person",
    c("Rater", "Criterion"),
    "Score",
    method = "MML",
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    quad_points = 5,
    maxit = 18
  ))

  review <- build_model_choice_review(RSM = rsm_fit, GPCM = gpcm_fit)

  expect_s3_class(review, "mfrm_model_choice_review")
  expect_s3_class(review, "mfrm_bundle")
  expect_true(all(c(
    "overview", "comparison", "comparison_table", "model_roles",
    "comparison_guidance", "comparison_reporting_templates",
    "downstream_routes", "report_templates", "route_map", "support_status",
    "weighting_review_status", "weighting_review", "notes", "settings"
  ) %in% names(review)))
  expect_true(isTRUE(review$overview$HasBoundedGPCM[1]))
  expect_identical(review$overview$OperationalReference[1], "RSM")
  expect_identical(review$overview$SensitivityModel[1], "GPCM")
  expect_identical(as.character(review$overview$ComparisonFamily[1]), "bounded_gpcm_sensitivity")
  expect_identical(
    as.character(review$overview$ComparisonStrength[1]),
    as.character(review$comparison$comparison_basis$comparison_strength)
  )
  expect_true(as.character(review$overview$ComparisonStrength[1]) %in%
                c("formal_mml_ic_available", "descriptive_only"))
  expect_identical(as.character(review$overview$PopulationSDModes[1]), "fixed")
  expect_false(isTRUE(review$overview$MixedPopulationSDModes[1]))
  expect_true(all(c(
    "ComparisonFamily", "ComparisonStrength", "InterpretationGuard"
  ) %in% names(review$comparison_table)))
  expect_identical(
    as.character(review$comparison_guidance$ComparisonFamily[1]),
    "bounded_gpcm_sensitivity"
  )
  expect_true(all(c(
    "APAStyleTemplate", "TechnicalAppendixTemplate", "NextAction"
  ) %in% names(review$comparison_reporting_templates)))
  expect_match(
    review$comparison_guidance$InterpretationGuard[1],
    "slope-aware sensitivity evidence",
    fixed = TRUE
  )
  expect_true(all(c(
    "PopulationSDMode", "PopulationMetric", "PopulationSDSEStatus"
  ) %in% names(review$model_roles)))
  expect_true(all(as.character(review$model_roles$PopulationSDMode) == "fixed"))
  expect_true(any(review$model_roles$RecommendedRole == "equal_weighting_reference"))
  expect_true(any(review$model_roles$RecommendedRole == "slope_aware_sensitivity"))
  expect_true(any(grepl("slope_facet == step_facet", review$model_roles$ScoreContract, fixed = TRUE)))
  expect_true(any(review$downstream_routes$FullAPARoute == "supported_with_caveat" &
                    review$downstream_routes$Model == "GPCM"))
  expect_true(any(review$downstream_routes$ScoreSideExport == "supported_with_caveat" &
                    review$downstream_routes$Model == "GPCM"))
  expect_true(any(review$downstream_routes$LinkingSynthesis == "supported_with_caveat" &
                    review$downstream_routes$Model == "GPCM"))
  expect_true(any(review$downstream_routes$FairAverage == "supported_with_caveat" &
                    review$downstream_routes$Model == "GPCM"))
  expect_true(any(grepl("automatic operational-scoring decision", review$key_warnings, fixed = TRUE)))
  expect_true(nrow(review$support_status) > 0)
  expect_false(isTRUE(review$weighting_review_status$Requested[1]))
  expect_false("weighting_audit_status" %in% names(review))
  expect_false("weighting_audit" %in% names(review))
  expect_false("run_weighting_audit" %in% names(review$settings))

  sx <- summary(review)
  expect_s3_class(sx, "summary.mfrm_model_choice_review")
  expect_true(all(c(
    "overview", "comparison_table", "model_roles", "downstream_routes",
    "comparison_guidance", "comparison_reporting_templates",
    "report_templates", "route_map", "weighting_review_status"
  ) %in% names(sx)))
  expect_true("PopulationMetric" %in% names(sx$model_roles))
  expect_false("weighting_audit_status" %in% names(sx))

  diag <- suppressWarnings(diagnose_mfrm(
    rsm_fit,
    residual_pca = "none",
    diagnostic_mode = "legacy"
  ))
  apa <- build_apa_outputs(rsm_fit, diag, model_comparison = review)
  apa_text_flat <- gsub("[[:space:]]+", " ", as.character(apa$report_text))
  expect_true("results_model_comparison" %in% apa$section_map$SectionId)
  expect_match(apa_text_flat, "Model Comparison Reporting", fixed = TRUE)
  expect_match(apa_text_flat, "slope-aware sensitivity evidence", fixed = TRUE)
  expect_true(nrow(apa$model_comparison_guidance) > 0L)
  apa_summary <- summary(apa)
  guard_check <- apa_summary$content_checks[
    apa_summary$content_checks$Check == "Model-comparison reporting guard",
    ,
    drop = FALSE
  ]
  expect_equal(nrow(guard_check), 1L)
  expect_true(guard_check$Passed[1])

  apa_bundle <- build_summary_table_bundle(apa)
  expect_true("model_comparison_guidance" %in% names(apa_bundle$tables))
  expect_true("model_comparison_reporting_templates" %in% names(apa_bundle$tables))

  review_bundle <- build_summary_table_bundle(review)
  expect_identical(review_bundle$summary_class, "summary.mfrm_model_choice_review")
  expect_true(all(c(
    "comparison_guidance", "comparison_reporting_templates", "comparison_table"
  ) %in% names(review_bundle$tables)))

  res <- suppressWarnings(mfrm_results(
    rsm_fit,
    include = c("fit", "diagnostics", "tables")
  ))
  report <- mfrm_report(res, style = "apa", model_comparison = review)
  expect_true("model_comparison_guidance" %in% names(report$tables))
  expect_true(nrow(report$model_comparison_guidance) > 0L)
  expect_true(any(report$template_index$Area == "Model comparison"))
  expect_match(report$markdown, "Model Comparison Guidance", fixed = TRUE)
  expect_match(report$markdown, "bounded_gpcm_sensitivity", fixed = TRUE)
})

test_that("build_model_choice_review can attach the detailed weighting review", {
  toy <- load_mfrmr_data("example_core")
  keep_people <- unique(toy$Person)[1:8]
  toy <- toy[toy$Person %in% keep_people, , drop = FALSE]

  rsm_fit <- suppressWarnings(fit_mfrm(
    toy,
    "Person",
    c("Rater", "Criterion"),
    "Score",
    method = "MML",
    model = "RSM",
    quad_points = 5,
    maxit = 18
  ))
  gpcm_fit <- suppressWarnings(fit_mfrm(
    toy,
    "Person",
    c("Rater", "Criterion"),
    "Score",
    method = "MML",
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    quad_points = 5,
    maxit = 18
  ))

  review <- build_model_choice_review(
    RSM = rsm_fit,
    GPCM = gpcm_fit,
    run_weighting_review = TRUE,
    theta_points = 11,
    top_n = 3
  )

  expect_true(isTRUE(review$weighting_review_status$Requested[1]))
  expect_true(isTRUE(review$weighting_review_status$Available[1]))
  expect_s3_class(review$weighting_review, "mfrm_weighting_review")
})

test_that("build_model_choice_review handles RSM versus PCM without GPCM routes", {
  rsm_fit <- make_toy_fit(method = "JML", model = "RSM", maxit = 12)
  toy <- load_mfrmr_data("example_core")
  pcm_fit <- suppressWarnings(fit_mfrm(
    toy,
    "Person",
    c("Rater", "Criterion"),
    "Score",
    method = "JML",
    model = "PCM",
    step_facet = "Criterion",
    maxit = 12
  ))

  review <- build_model_choice_review(RSM = rsm_fit, PCM = pcm_fit)

  expect_s3_class(review, "mfrm_model_choice_review")
  expect_false(isTRUE(review$overview$HasBoundedGPCM[1]))
  expect_identical(as.character(review$overview$ComparisonFamily[1]), "response_model_choice")
  expect_equal(nrow(review$support_status), 0)
  expect_true(all(review$downstream_routes$FullAPARoute == "supported"))
  expect_true(any(grepl("score interpretation", review$next_actions, fixed = TRUE)))
})
