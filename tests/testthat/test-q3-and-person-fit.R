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
  expect_s3_class(pf, "mfrm_person_fit_indices")
  expect_true(all(c("Person", "N", "LogLik", "lz", "lz_star",
                    "lz_star_status", "lz_star_c", "lz_star_variance",
                    "ReportIndex", "ReportValue", "ReportFlagLevel",
                    "ReportFlag", "ReviewStatus", "ReviewReason",
                    "ReportCaveat")
                  %in% names(pf)))
  expect_true(all(pf$lz_star_status %in% c(
    "computed_jml_conditional_calibration", "insufficient_information"
  )))
  expect_true(any(is.finite(pf$lz_star)))
  expect_true(all(pf$ReportIndex %in% c("lz_star", "lz", "none")))
  expect_true(all(pf$ReviewStatus %in% c(
    "review_1pct", "review_5pct", "not_flagged", "not_available"
  )))
  # ECI4 was removed in 0.2.0 — it was a misnamed duplicate of the
  # Outfit ZSTD (linear Smith form), not Tatsuoka & Tatsuoka (1983).
  expect_false("ECI4" %in% names(pf))
  expect_equal(length(unique(pf$Person)), nrow(pf))

  spf <- summary(pf, top_n = 5)
  expect_s3_class(spf, "summary.mfrm_person_fit_indices")
  expect_true(all(c("overview", "status_summary", "report_index_summary",
                    "lz_star_status_summary", "top_review", "caveats",
                    "thresholds", "reporting_map") %in% names(spf)))
  expect_true(is.data.frame(spf$top_review))
  expect_equal(spf$overview$Persons, nrow(pf))
  expect_true(any(spf$report_index_summary$Value == "lz_star"))
  printed <- capture.output(print(spf))
  expect_true(any(grepl("Person-Fit Summary", printed, fixed = TRUE)))
})

test_that("compute_person_fit_indices works without fit (lz_star fit-required)", {
  pf <- compute_person_fit_indices(.diag, fit = NULL)
  expect_true(all(is.na(pf$lz_star)))
  expect_true(all(pf$lz_star_status == "fit_required"))
})

test_that("lz uses true Drasgow polytomous form via PrObserved", {
  # Closed-form check: build a tiny synthetic obs table directly with
  # PrObserved / ItemEntropy / ItemVarLogP populated and verify the
  # output matches the manual computation.
  P_item1 <- c(0.1, 0.2, 0.4, 0.3)
  P_item2 <- c(0.05, 0.15, 0.5, 0.3)
  log_p_item1 <- log(P_item1)
  log_p_item2 <- log(P_item2)

  ent1 <- sum(P_item1 * log_p_item1)
  ent2 <- sum(P_item2 * log_p_item2)
  var1 <- sum(P_item1 * log_p_item1^2) - ent1^2
  var2 <- sum(P_item2 * log_p_item2^2) - ent2^2

  fake_obs <- data.frame(
    Person = c("p1", "p1"),
    Observed = c(2, 3),
    Expected = c(2, 3),
    Residual = c(0, 0),
    PrObserved = c(P_item1[3], P_item2[4]),
    ItemEntropy = c(ent1, ent2),
    ItemVarLogP = c(var1, var2),
    stringsAsFactors = FALSE
  )
  fake_diag <- list(obs = fake_obs)

  pf <- compute_person_fit_indices(fake_diag, fit = NULL)
  expected_loglik <- log(P_item1[3]) + log(P_item2[4])
  expected_e_logp <- ent1 + ent2
  expected_var_logp <- var1 + var2
  expected_lz <- (expected_loglik - expected_e_logp) / sqrt(expected_var_logp)

  expect_equal(pf$LogLik, expected_loglik, tolerance = 1e-12)
  expect_equal(pf$lz, expected_lz, tolerance = 1e-12)
})

test_that("lz_star uses Snijders weight projection for JML-style estimates", {
  P_item1 <- c(0.1, 0.2, 0.4, 0.3)
  P_item2 <- c(0.05, 0.15, 0.5, 0.3)
  slope_item1 <- 0.75
  slope_item2 <- 1.40
  k_vals <- 0:3
  log_p_item1 <- log(P_item1)
  log_p_item2 <- log(P_item2)
  expected1 <- sum(P_item1 * k_vals)
  expected2 <- sum(P_item2 * k_vals)
  r1 <- k_vals - expected1
  r2 <- k_vals - expected2

  ent1 <- sum(P_item1 * log_p_item1)
  ent2 <- sum(P_item2 * log_p_item2)
  var1 <- sum(P_item1 * log_p_item1^2) - ent1^2
  var2 <- sum(P_item2 * log_p_item2^2) - ent2^2
  cov1 <- slope_item1 * sum(P_item1 * log_p_item1 * r1)
  cov2 <- slope_item2 * sum(P_item2 * log_p_item2 * r2)
  info1 <- slope_item1^2 * sum(P_item1 * r1^2)
  info2 <- slope_item2^2 * sum(P_item2 * r2^2)

  fake_obs <- data.frame(
    Person = c("p1", "p1"),
    Observed = c(2, 3),
    Expected = c(expected1, expected2),
    Residual = c(2 - expected1, 3 - expected2),
    PrObserved = c(P_item1[3], P_item2[4]),
    ItemEntropy = c(ent1, ent2),
    ItemVarLogP = c(var1, var2),
    ItemLogPScoreCov = c(cov1, cov2),
    ScoreInformation = c(info1, info2),
    ObservedScoreDerivative = c(slope_item1 * r1[3], slope_item2 * r2[4]),
    stringsAsFactors = FALSE
  )
  fake_diag <- list(obs = fake_obs)
  fake_fit <- structure(
    list(config = list(method = "JMLE"),
         summary = data.frame(Method = "JML")),
    class = "mfrm_fit"
  )

  c_n <- (cov1 + cov2) / (info1 + info2)
  corrected_var <- (var1 + var2) - (cov1 + cov2)^2 / (info1 + info2)
  centered_loglik <- (log(P_item1[3]) - ent1) + (log(P_item2[4]) - ent2)
  score_sum <- slope_item1 * r1[3] + slope_item2 * r2[4]
  expected_lz_star <- (centered_loglik - c_n * score_sum) / sqrt(corrected_var)

  pf <- compute_person_fit_indices(fake_diag, fit = fake_fit)
  expect_equal(pf$lz_star, expected_lz_star, tolerance = 1e-12)
  expect_equal(pf$lz_star_c, c_n, tolerance = 1e-12)
  expect_equal(pf$lz_star_variance, corrected_var, tolerance = 1e-12)
  expect_identical(pf$lz_star_status, "computed_jml_conditional_calibration")
  expect_identical(pf$ReportIndex, "lz_star")
  expect_equal(pf$ReportValue, expected_lz_star, tolerance = 1e-12)
})

test_that("lz_star is not applied to MML/EAP person scores", {
  mml_fit <- make_toy_fit(method = "MML", maxit = 10)
  mml_diag <- make_toy_diagnostics(mml_fit)
  pf <- compute_person_fit_indices(mml_diag, fit = mml_fit)
  expect_true(all(is.na(pf$lz_star)))
  expect_true(all(pf$lz_star_status == "not_applicable_eap"))
  expect_true(all(pf$ReportIndex %in% c("lz", "none")))
  expect_true(all(grepl("not_applicable_eap", pf$ReportCaveat, fixed = TRUE)))
})

test_that("lz_star falls back with explicit status when Snijders information is degenerate", {
  P_item <- c(0.2, 0.5, 0.3)
  log_p <- log(P_item)
  ent <- sum(P_item * log_p)
  var_logp <- sum(P_item * log_p^2) - ent^2
  fake_obs <- data.frame(
    Person = "p1",
    Observed = 1,
    Expected = sum(P_item * 0:2),
    Residual = 0,
    PrObserved = P_item[2],
    ItemEntropy = ent,
    ItemVarLogP = var_logp,
    ItemLogPScoreCov = 0,
    ScoreInformation = 0,
    ObservedScoreDerivative = 0,
    stringsAsFactors = FALSE
  )
  fake_fit <- structure(
    list(config = list(method = "JML"),
         summary = data.frame(Method = "JML")),
    class = "mfrm_fit"
  )
  pf <- compute_person_fit_indices(list(obs = fake_obs), fit = fake_fit)
  expect_true(is.na(pf$lz_star))
  expect_identical(pf$lz_star_status, "insufficient_information")
  expect_identical(pf$ReportIndex, "lz")
  expect_true(grepl("insufficient_information", pf$ReportCaveat, fixed = TRUE))
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
  expect_identical(gt$design$model_scope, "main_effects")
  expect_length(gt$design$random_interaction_terms, 0L)
  expect_s3_class(gt$runtime, "data.frame")
  expect_true(all(c("ElapsedSec", "RatingRows", "RandomFacetCount",
                    "ProgressShown") %in% names(gt$runtime)))
  expect_false(gt$runtime$ProgressShown[1])
  expect_error(
    mfrm_generalizability(.fit, progress = NA),
    "`progress` must be a single TRUE/FALSE value"
  )
  s_gt <- summary(gt)
  expect_s3_class(s_gt, "summary.mfrm_generalizability")
  expect_true(all(c("overview", "variance_components", "coefficients",
                    "runtime", "notes") %in% names(s_gt)))
  expect_true(all(c("AnalysisRole", "MetricBasis") %in% names(s_gt$overview)))
  expect_identical(s_gt$overview$AnalysisRole[1],
                   "observed_score_g_theory_complement")
  expect_identical(s_gt$overview$MetricBasis[1], "observed_score")
  expect_output(print(s_gt), "Generalizability-theory Summary")
  expect_output(print(s_gt), "Runtime")
  expect_output(print(gt), "Elapsed")
  expect_output(print(gt), "not MFRM separation reliability")

  p_gt <- plot(gt, draw = FALSE)
  expect_s3_class(p_gt, "mfrm_plot_data")
  expect_identical(p_gt$name, "generalizability")
  expect_identical(p_gt$data$plot, "variance_components")
  expect_true(all(c(
    "plot_table", "reading_order", "guidance",
    "figure_recipes", "interpretation_note"
  ) %in% names(p_gt$data)))

  p_gt_coef <- plot(gt, type = "coefficients", draw = FALSE)
  expect_identical(p_gt_coef$data$plot, "coefficients")
  expect_true(all(c("Metric", "MetricFamily", "MetricRole", "Value", "Status") %in%
                    names(p_gt_coef$data$plot_table)))
  p_gt_design <- plot(gt, type = "design_check", draw = FALSE)
  expect_s3_class(p_gt_design, "mfrm_plot_data")
  expect_identical(p_gt_design$name, "generalizability_design_check")
  expect_identical(p_gt_design$data$plot, "interaction_cells")
  expect_true(all(c("plot_table", "interaction_overview",
                    "highest_order_review", "overview") %in%
                    names(p_gt_design$data)))
  p_gt_highest <- plot(
    gt,
    type = "design_check",
    design_check_type = "highest_order",
    draw = FALSE
  )
  expect_identical(p_gt_highest$data$plot, "highest_order")
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    expect_s3_class(as_ggplot(p_gt), "ggplot")
    expect_s3_class(as_ggplot(p_gt_coef), "ggplot")
    expect_s3_class(as_ggplot(gt, type = "design_check"), "ggplot")
  }
})

test_that("check_mfrm_generalizability_design reviews requested interaction cells", {
  design_check <- check_mfrm_generalizability_design(
    .fit,
    random_interactions = c("Person:Rater", "Rater:Criterion")
  )

  expect_s3_class(design_check, "mfrm_generalizability_design_check")
  expect_true(all(c("overview", "facet_overview", "interaction_overview",
                    "highest_order_review", "settings", "notes") %in%
                    names(design_check)))
  expect_equal(design_check$overview$RequestedInteractionCount[1], 2L)
  expect_setequal(design_check$interaction_overview$Interaction,
                  c("Person:Rater", "Rater:Criterion"))
  expect_true(all(design_check$interaction_overview$Status %in%
                    c("ok", "sensitivity_only", "review", "not_requested")))
  expect_true(all(c("FullCellFacets", "ReplicatedFullCellRate", "Status",
                    "MainConcern") %in%
                    names(design_check$highest_order_review)))
  expect_s3_class(summary(design_check),
                  "summary.mfrm_generalizability_design_check")
  expect_output(print(design_check), "G-study design check")
  p_interaction_design <- plot(design_check, draw = FALSE)
  expect_s3_class(p_interaction_design, "mfrm_plot_data")
  expect_identical(p_interaction_design$name, "generalizability_design_check")
  expect_identical(p_interaction_design$data$plot, "interaction_cells")
  expect_true(all(c("plot_table", "facet_overview", "interaction_overview",
                    "highest_order_review", "overview", "guidance",
                    "figure_recipes") %in% names(p_interaction_design$data)))
  expect_true(all(c("PlotGroup", "Value", "Status", "Metric",
                    "MainConcern") %in%
                    names(p_interaction_design$data$plot_table)))
  expect_s3_class(
    plot(design_check, type = "highest_order", draw = FALSE),
    "mfrm_plot_data"
  )
  expect_s3_class(
    plot(design_check, type = "facet_levels", metric = "Levels", draw = FALSE),
    "mfrm_plot_data"
  )
  expect_s3_class(
    plot(design_check, type = "overview", draw = FALSE),
    "mfrm_plot_data"
  )
  expect_s3_class(plot_data_components(p_interaction_design), "data.frame")
  expect_s3_class(
    plot_data(design_check, component = "plot_table"),
    "data.frame"
  )
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    expect_s3_class(as_ggplot(p_interaction_design), "ggplot")
    expect_s3_class(as_ggplot(design_check, type = "highest_order"), "ggplot")
  }

  main_effects_check <- check_mfrm_generalizability_design(.fit)
  expect_identical(main_effects_check$interaction_overview$Status[1],
                   "not_requested")
  expect_error(
    check_mfrm_generalizability_design(.fit, random_interactions = "Person:Person"),
    "two distinct facets"
  )
  expect_error(
    check_mfrm_generalizability_design(.fit, sparse_cell_threshold = 1.5),
    "sparse_cell_threshold"
  )
})

test_that("mfrm_generalizability can separate explicit random interactions", {
  if (!requireNamespace("lme4", quietly = TRUE)) {
    skip("lme4 (Suggests) not installed.")
  }
  gt <- mfrm_generalizability(
    .fit,
    random_interactions = c("Person:Rater", "Rater:Criterion")
  )
  expect_s3_class(gt, "mfrm_generalizability")
  expect_identical(gt$design$model_scope, "interaction_expanded")
  expect_setequal(gt$design$random_interaction_terms,
                  c("Person:Rater", "Rater:Criterion"))
  expect_true(all(c("Person:Rater", "Rater:Criterion") %in%
                    gt$variance_components$Source))
  expect_true(any(gt$variance_components$ComponentType == "object_interaction"))
  expect_true(any(gt$variance_components$ComponentType == "facet_interaction"))
  expect_true(all(c("ObjectInteractionVariance", "FacetInteractionVariance",
                    "RelativeErrorVariance", "AbsoluteErrorVariance") %in%
                    names(gt$coefficients)))
  expect_true(all(c("RandomInteractionCount", "RandomInteractions",
                    "LmerMessages", "SingularFit") %in% names(gt$runtime)))
  expect_s3_class(gt$design$design_check,
                  "mfrm_generalizability_design_check")
  expect_equal(gt$design$design_check$overview$RequestedInteractionCount[1], 2L)
  expect_true(all(c("DesignReviewCount", "DesignSensitivityOnlyCount",
                    "HighestOrderStatus") %in% names(summary(gt)$overview)))
  p_interaction <- plot(
    gt,
    type = "variance_components",
    component_type = "object_interaction",
    show_proportion = FALSE,
    sort_by = "source",
    top_n = 1,
    draw = FALSE
  )
  expect_s3_class(p_interaction, "mfrm_plot_data")
  expect_identical(p_interaction$data$metric, "Variance")
  expect_true(all(p_interaction$data$plot_table$ComponentType == "object_interaction"))
  expect_lte(nrow(p_interaction$data$plot_table), 1L)

  expect_error(
    mfrm_generalizability(.fit, random_interactions = "Person:Person"),
    "two distinct facets"
  )
  expect_error(
    mfrm_generalizability(.fit, random_interactions = "Person:MissingFacet"),
    "not available"
  )
  expect_error(
    mfrm_generalizability(.fit, random_interactions = "Person:Rater:Criterion"),
    "two-way terms"
  )
})

test_that("mfrm_generalizability quotes non-syntactic facet names", {
  if (!requireNamespace("lme4", quietly = TRUE)) {
    skip("lme4 (Suggests) not installed.")
  }
  d <- expand.grid(
    "Person ID" = paste0("P", seq_len(5)),
    "Rater ID" = paste0("R", seq_len(3)),
    Criterion = paste0("C", seq_len(2)),
    check.names = FALSE
  )
  set.seed(90210)
  d$Score <- stats::rnorm(nrow(d))
  fit <- list(
    prep = list(data = d),
    config = list(facet_names = c("Person ID", "Rater ID", "Criterion"))
  )
  class(fit) <- "mfrm_fit"

  gt <- mfrm_generalizability(
    fit,
    object_facet = "Person ID",
    random_facets = c("Rater ID", "Criterion"),
    random_interactions = "Person ID:Rater ID",
    progress = FALSE
  )
  expect_s3_class(gt, "mfrm_generalizability")
  expect_true("Person ID:Rater ID" %in% gt$variance_components$Source)
  expect_true(any(gt$variance_components$ComponentType == "object_interaction"))
})

test_that("mfrm_d_study projects G and Phi across planned counts", {
  if (!requireNamespace("lme4", quietly = TRUE)) {
    skip("lme4 (Suggests) not installed.")
  }
  gt <- mfrm_generalizability(.fit)
  expect_error(
    mfrm_d_study(gt, progress = NA),
    "`progress` must be a single TRUE/FALSE value"
  )
  ds <- mfrm_d_study(
    gt,
    data.frame(Rater = c(2, 4), Criterion = c(2, 4)),
    residual_scaling = "sensitivity"
  )

  expect_s3_class(ds, "mfrm_d_study")
  expect_s3_class(attr(ds, "runtime"), "data.frame")
  expect_true(all(c("ProjectionElapsedSec", "GStudyElapsedSec",
                    "SourceWasFit", "ProgressShown") %in%
                    names(attr(ds, "runtime"))))
  expect_false(attr(ds, "runtime")$SourceWasFit[1])
  expect_true(all(c(
    "Scenario", "n_Rater", "n_Criterion", "ResidualScaling",
    "ResidualDivisor", "G", "Phi", "GStatus", "PhiStatus"
  ) %in% names(ds)))
  expect_equal(nrow(ds), 6L)
  expect_true(all(c("highest_order", "single_condition", "none") %in% ds$ResidualScaling))
  expect_true(all(is.na(ds$G) | (ds$G >= 0 & ds$G <= 1)))
  expect_true(all(is.na(ds$Phi) | (ds$Phi >= 0 & ds$Phi <= 1)))

  highest <- ds[ds$ResidualScaling == "highest_order", , drop = FALSE]
  if (all(is.finite(highest$G))) {
    expect_gte(highest$G[2], highest$G[1] - 1e-8)
  }

  p <- plot(ds, draw = FALSE)
  expect_s3_class(p, "mfrm_plot_data")
  expect_identical(p$data$plot, "coefficients")
  expect_true(all(c(
    "table", "series", "x_var", "reading_order", "guidance",
    "figure_recipes", "interpretation_note"
  ) %in% names(p$data)))
  expect_true(is.list(plot_data(ds)))
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    expect_s3_class(as_ggplot(p), "ggplot")
  }

  ds_grid <- mfrm_d_study(
    gt,
    expand.grid(Rater = 2:4, Criterion = 2:4),
    residual_scaling = "sensitivity"
  )
  p_panel <- plot(
    ds_grid,
    x_var = "n_Rater",
    group_var = "n_Criterion",
    panel_grid = c("Metric", "ResidualScaling"),
    draw = FALSE
  )
  expect_identical(p_panel$data$group_var, "n_Criterion")
  expect_identical(p_panel$data$panel_grid, c("Metric", "ResidualScaling"))
  expect_true(all(c("MetricFamily", "Series", "Panel") %in% names(p_panel$data$series)))
  expect_true(all(p_panel$data$series$MetricFamily == "G-theory"))

  p_heat <- plot(
    ds_grid,
    type = "heatmap",
    x_var = "n_Rater",
    y_var = "n_Criterion",
    metric = "Phi",
    draw = FALSE
  )
  expect_identical(p_heat$data$plot, "heatmap")
  expect_identical(p_heat$data$metric, "Phi")
  expect_identical(p_heat$data$panel_by, "ResidualScaling")
  expect_s3_class(p_heat$data$surface, "data.frame")
  expect_true(any(p_heat$data$figure_recipes$SelectedRoute))
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    expect_s3_class(as_ggplot(p_heat), "ggplot")
  }

  p_error_heat <- plot(
    ds_grid,
    type = "heatmap",
    x_var = "n_Rater",
    y_var = "n_Criterion",
    metric = "AbsoluteErrorVariance",
    draw = FALSE
  )
  expect_identical(p_error_heat$data$metric, "AbsoluteErrorVariance")

  p_surface <- plot(
    ds_grid,
    type = "surface3d",
    x_var = "n_Rater",
    y_var = "n_Criterion",
    metric = "G",
    panel_by = "ResidualScaling",
    draw = FALSE
  )
  expect_identical(p_surface$data$plot, "surface3d")
  expect_identical(p_surface$data$metric, "G")

  default_ds <- mfrm_d_study(gt)
  expect_equal(nrow(default_ds), 1L)
  expect_identical(default_ds$ResidualScaling, "highest_order")
})

test_that("mfrm_d_study projects explicit interaction components", {
  if (!requireNamespace("lme4", quietly = TRUE)) {
    skip("lme4 (Suggests) not installed.")
  }
  gt <- mfrm_generalizability(
    .fit,
    random_interactions = c("Person:Rater", "Rater:Criterion")
  )
  ds <- mfrm_d_study(
    gt,
    data.frame(Rater = c(2, 4), Criterion = c(2, 4)),
    residual_scaling = "highest_order"
  )
  expect_true(all(c("MainEffectErrorVariance",
                    "ObjectInteractionErrorVariance",
                    "FacetInteractionErrorVariance",
                    "ResidualErrorVariance") %in% names(ds)))
  expect_true(all(ds$RelativeErrorVariance >= ds$ResidualErrorVariance - 1e-8))
  expect_true(all(ds$AbsoluteErrorVariance >= ds$RelativeErrorVariance - 1e-8))
  expect_identical(attr(ds, "random_interactions"),
                   c("Person:Rater", "Rater:Criterion"))
})

test_that("compare_mfrm_generalizability returns baseline and expanded sensitivity output", {
  if (!requireNamespace("lme4", quietly = TRUE)) {
    skip("lme4 (Suggests) not installed.")
  }
  cmp <- compare_mfrm_generalizability(
    .fit,
    random_interactions = c("Person:Rater", "Rater:Criterion"),
    design_grid = data.frame(Rater = 2:3, Criterion = 2:3)
  )
  expect_s3_class(cmp, "mfrm_generalizability_comparison")
  expect_true(all(c("summary", "comparison_review", "coefficients", "variance_components",
                    "variance_delta", "d_study", "design_checks",
                    "warnings") %in% names(cmp)))
  expect_setequal(
    unique(cmp$coefficients$Model),
    c("baseline_main_effects", "interaction_expanded",
      "expanded_minus_baseline")
  )
  expect_true(all(c("overview", "overview_raw", "facet_overview",
                    "interaction_overview", "highest_order_review") %in%
                    names(cmp$design_checks)))
  expect_true(all(c("BaselineDesignReview", "ExpandedDesignReview",
                    "ExpandedDesignSensitivityOnly", "ComparisonReview",
                    "ComparisonSensitivityOnly") %in%
                    names(cmp$summary)))
  expect_true(all(c("Checkpoint", "Status", "Evidence", "Interpretation",
                    "NextAction", "Boundary") %in%
                    names(cmp$comparison_review)))
  expect_true(all(c("interaction_design_support", "fit_stability",
                    "coefficient_movement", "variance_movement",
                    "dstudy_projection_movement", "reporting_boundary") %in%
                    cmp$comparison_review$Checkpoint))
  expect_true(all(c("baseline_main_effects", "interaction_expanded") %in%
                    unique(cmp$d_study$Model)))
  expect_true(any(cmp$variance_delta$Source == "Person:Rater"))
  expect_true(any(cmp$variance_delta$Source == "Rater:Criterion"))
  expect_output(print(cmp), "G-study sensitivity comparison")
  expect_output(print(cmp), "Comparison review")
  expect_output(print(cmp), "not MFRM separation reliability")

  p_coef <- plot(cmp, draw = FALSE)
  expect_s3_class(p_coef, "mfrm_plot_data")
  expect_identical(p_coef$name, "generalizability_comparison")
  expect_identical(p_coef$data$plot, "coefficients")
  expect_true(all(c("Model", "ModelLabel", "Metric", "Value") %in%
                    names(p_coef$data$plot_table)))
  expect_true("comparison_review" %in% names(p_coef$data))

  p_coef_delta <- plot(cmp, type = "coefficient_delta", metric = c("G", "Phi"), draw = FALSE)
  expect_identical(p_coef_delta$data$plot, "coefficient_delta")
  expect_true(all(p_coef_delta$data$plot_table$Model == "expanded_minus_baseline"))

  p_design <- plot(cmp, type = "design_check", draw = FALSE)
  expect_s3_class(p_design, "mfrm_plot_data")
  expect_identical(p_design$data$plot, "design_check")
  expect_true(all(c("Model", "ModelLabel", "PlotGroup", "Value",
                    "Status", "Metric") %in%
                    names(p_design$data$plot_table)))
  expect_true("design_checks" %in% names(p_design$data))
  expect_true("comparison_review" %in% names(p_design$data))
  expect_true(all(c("baseline_main_effects", "interaction_expanded") %in%
                    p_design$data$plot_table$Model))

  p_var_delta <- plot(
    cmp,
    type = "variance_delta",
    component_type = "object_interaction",
    top_n = 2,
    draw = FALSE
  )
  expect_identical(p_var_delta$data$plot, "variance_delta")
  expect_true(all(p_var_delta$data$plot_table$ComponentType == "object_interaction"))

  p_overlay <- plot(
    cmp,
    type = "d_study_overlay",
    metric = "Phi",
    x_var = "n_Rater",
    panel_by = "ResidualScaling",
    draw = FALSE
  )
  expect_identical(p_overlay$data$plot, "d_study_overlay")
  expect_identical(p_overlay$data$x_var, "n_Rater")
  expect_true(all(c("Series", "Panel", "ModelLabel") %in% names(p_overlay$data$series)))

  cmp_without_models <- cmp
  cmp_without_models$coefficients <- data.frame(
    Model = NA_character_,
    G = 0.8,
    stringsAsFactors = FALSE
  )
  expect_error(
    plot(cmp_without_models, type = "coefficients", draw = FALSE),
    "No comparison model rows"
  )

  cmp_without_metrics <- cmp
  cmp_without_metrics$coefficients <- data.frame(
    Model = "baseline_main_effects",
    Label = "not numeric",
    stringsAsFactors = FALSE
  )
  expect_error(
    plot(cmp_without_metrics, type = "coefficients", draw = FALSE),
    "No finite metric columns"
  )

  if (requireNamespace("ggplot2", quietly = TRUE)) {
    expect_s3_class(as_ggplot(p_coef), "ggplot")
    expect_s3_class(as_ggplot(p_coef_delta), "ggplot")
    expect_s3_class(as_ggplot(p_design), "ggplot")
    expect_s3_class(as_ggplot(p_var_delta), "ggplot")
    expect_s3_class(as_ggplot(p_overlay), "ggplot")
  }
  expect_error(
    compare_mfrm_generalizability(.fit),
    "random_interactions"
  )
})
