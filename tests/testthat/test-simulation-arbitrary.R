test_that("arbitrary simulation spec supports five or more facets and design choices", {
  spec <- build_mfrm_arbitrary_sim_spec(
    n_person = c(8, 10),
    facets = list(
      Rater = c(3, 4),
      Criteria = c(2, 3),
      Task = c(3, 4),
      Occasion = 2,
      Prompt = 2
    ),
    facets_per_person = list(Rater = c(2, 3), Task = 2),
    score_levels = 4
  )

  expect_s3_class(spec, "mfrm_arbitrary_sim_spec")
  expect_identical(spec$facet_names, c("Rater", "Criteria", "Task", "Occasion", "Prompt"))
  expect_true(nrow(spec$design_grid) > 1L)
  expect_true(all(spec$design_grid$Rater_per_person <= spec$design_grid$n_Rater))
  expect_true(all(spec$design_grid$Task_per_person <= spec$design_grid$n_Task))

  grid <- summarize_mfrm_sim_grid(spec)
  expect_s3_class(grid, "mfrm_sim_grid_summary")
  expect_equal(nrow(grid), nrow(spec$design_grid))
  expect_true(all(c("n_Rater", "n_Task", "Observations", "MeanObsPerPerson", "MinPairCoverage") %in% names(grid)))

  p <- plot_mfrm_sim_grid(
    grid,
    x_var = "n_Rater",
    metric = "Observations",
    group_var = "n_Task",
    panel_var = "n_Criteria",
    draw = FALSE
  )
  expect_s3_class(p, "mfrm_plot_data")
  expect_equal(p$data$x_var, "n_Rater")
  expect_equal(p$data$group_var, "n_Task")
  expect_equal(p$data$panel_var, "n_Criteria")
  expect_true(all(c("n_Rater", "n_Task", "n_Criteria", ".x", ".y", ".group", ".panel") %in% names(p$data$data)))

  metric_catalog <- list_mfrm_sim_metrics(spec)
  expect_true(all(c("Metric", "Component", "Role", "SuggestedDefault") %in% names(metric_catalog)))
  expect_true("MeanObsPerPerson" %in% metric_catalog$Metric)
  dash <- plot_mfrm_sim_dashboard(
    spec,
    metrics = c("MeanObsPerPerson", "MinPairCoverage"),
    x_var = "n_Rater",
    group_var = "n_Task",
    panel_var = "n_Criteria",
    draw = FALSE
  )
  expect_s3_class(dash, "mfrm_plot_data")
  expect_equal(dash$data$metrics, c("MeanObsPerPerson", "MinPairCoverage"))
  expect_true(all(c(".metric", ".value", ".x", ".group", ".panel") %in% names(dash$data$data)))
})

test_that("simulate_mfrm_arbitrary_data returns a reusable long-format design", {
  spec <- build_mfrm_arbitrary_sim_spec(
    n_person = 10,
    facets = c(Rater = 3, Criteria = 2, Task = 3, Occasion = 2, Prompt = 2),
    facets_per_person = c(Rater = 2, Task = 2),
    score_levels = 4
  )

  sim <- simulate_mfrm_arbitrary_data(
    spec,
    seed = 11,
    interaction_effects = data.frame(Rater = "Rater03", Task = "Task03", Effect = -0.6)
  )

  expect_true(is.data.frame(sim))
  expect_named(sim, c("Study", "Person", "Rater", "Criteria", "Task", "Occasion", "Prompt", "Score"))
  expect_equal(nrow(sim), 10 * 2 * 2 * 2 * 2 * 2)
  expect_true(all(sim$Score %in% 1:4))

  truth <- attr(sim, "mfrm_truth")
  expect_true(is.list(truth))
  expect_equal(length(truth$facets), 5L)
  expect_equal(nrow(truth$signals$interaction_effects), 1L)
  expect_equal(truth$design$facets_per_person$Rater, 2L)

  design <- summarize_mfrm_sim_design(sim)
  expect_s3_class(design, "mfrm_sim_design_summary")
  expect_equal(design$overview$Facets, 5L)
  expect_equal(design$assignment$MaxLevelsPerPerson[design$assignment$Facet == "Rater"], 2)
  expect_equal(design$assignment$MaxLevelsPerPerson[design$assignment$Facet == "Task"], 2)

  p1 <- plot_mfrm_sim_design(design, draw = FALSE)
  p2 <- plot_mfrm_sim_design(design, type = "pair_coverage", draw = FALSE)
  expect_s3_class(p1, "mfrm_plot_data")
  expect_s3_class(p2, "mfrm_plot_data")
})

test_that("arbitrary simulated data can be fitted by the existing estimator", {
  spec <- build_mfrm_arbitrary_sim_spec(
    n_person = 12,
    facets = c(Rater = 3, Criteria = 2, Task = 2, Occasion = 2, Prompt = 2),
    facets_per_person = c(Rater = 2, Task = 1),
    score_levels = 3
  )
  sim <- simulate_mfrm_arbitrary_data(spec, seed = 12)

  fit <- suppressWarnings(fit_mfrm(
    sim,
    person = "Person",
    facets = spec$facet_names,
    score = "Score",
    rating_min = 1,
    rating_max = 3,
    model = "RSM",
    method = "JML",
    maxit = 20
  ))

  expect_s3_class(fit, "mfrm_fit")
  expect_identical(fit$config$facet_names, spec$facet_names)
  diag <- diagnose_mfrm(fit, residual_pca = "none")
  expect_s3_class(diag, "mfrm_diagnostics")
})

test_that("evaluate_mfrm_bias_detection summarizes arbitrary pairwise targets", {
  spec <- build_mfrm_arbitrary_sim_spec(
    n_person = 18,
    facets = c(Rater = 3, Criteria = 2, Task = 3),
    facets_per_person = c(Rater = 2, Task = 2),
    score_levels = 4
  )
  targets <- data.frame(
    Target = "rater_task",
    Rater = "Rater03",
    Task = "Task03",
    Effect = -0.8
  )

  eval <- suppressWarnings(evaluate_mfrm_bias_detection(
    spec,
    bias_targets = targets,
    reps = 1,
    seed = 2,
    fit_method = "JML",
    fit_args = list(rating_min = 1, rating_max = 4),
    maxit = 20,
    bias_max_iter = 1
  ))

  expect_s3_class(eval, "mfrm_bias_detection")
  expect_named(eval$results, c(
    "design_id", "n_person", "n_Rater", "n_Criteria", "n_Task",
    "Rater_per_person", "Task_per_person", "rep",
    "Target", "FacetA", "LevelA", "FacetB", "LevelB",
    "FacetPair", "TrueEffect", "Observations", "ElapsedSec", "Converged",
    "BiasSize", "BiasP", "BiasPAdjusted", "BiasT",
    "BiasScreenMetricAvailable", "BiasDetected",
    "BiasScreenFalsePositiveRate", "RunOK", "Error"
  ))
  expect_equal(nrow(eval$target_summary), 1L)
  expect_equal(eval$target_summary$FacetPair, "Rater x Task")
  expect_equal(eval$pair_summary$FacetA, "Rater")
  expect_equal(eval$pair_summary$FacetB, "Task")
  expect_true(is.data.frame(eval$estimates))
  expect_true(is.data.frame(eval$reliability))
  expect_true(is.data.frame(eval$fit_summary))
  expect_true(all(c("design_id", "rep", "Facet", "Level", "Estimate") %in% names(eval$estimates)))
  expect_true(all(c("design_id", "rep", "Facet", "Reliability") %in% names(eval$reliability)))
  expect_true(all(c("design_id", "Facet", "MeanReliability", "MeanSeparation") %in% names(eval$fit_summary)))

  s <- summary(eval)
  p <- plot(eval, draw = FALSE)
  p_rel <- plot(eval, metric = "reliability", facet = "Rater", draw = FALSE)
  expect_s3_class(s, "summary.mfrm_bias_detection")
  expect_s3_class(p, "mfrm_plot_data")
  expect_s3_class(p_rel, "mfrm_plot_data")
  expect_s3_class(as.data.frame(eval, component = "estimates"), "data.frame")
  expect_s3_class(as.data.frame(eval, component = "reliability"), "data.frame")
  expect_s3_class(as.data.frame(s, component = "fit_summary"), "data.frame")

  bias_metrics <- list_mfrm_sim_metrics(eval)
  expect_true("MeanReliability" %in% bias_metrics$Metric)
  dash_rel <- plot_mfrm_sim_dashboard(
    eval,
    metrics = c("MeanReliability", "MeanSeparation"),
    x_var = "n_Rater",
    facet = "Rater",
    draw = FALSE
  )
  expect_s3_class(dash_rel, "mfrm_plot_data")
  expect_true(all(dash_rel$data$data$.metric %in% c("MeanReliability", "MeanSeparation")))
})

test_that("extract_mfrm_arbitrary_sim_spec reuses fitted skeleton and estimates", {
  base_spec <- build_mfrm_arbitrary_sim_spec(
    n_person = 12,
    facets = c(Rater = 3, Criteria = 2, Task = 2),
    facets_per_person = c(Rater = 2),
    score_levels = 4
  )
  dat <- simulate_mfrm_arbitrary_data(base_spec, seed = 31)
  dat$Group <- ifelse(as.integer(sub("P", "", dat$Person)) %% 2L == 0L, "B", "A")

  fit <- suppressWarnings(fit_mfrm(
    dat,
    person = "Person",
    facets = base_spec$facet_names,
    score = "Score",
    rating_min = 1,
    rating_max = 4,
    model = "RSM",
    method = "JML",
    maxit = 20
  ))

  fitted_spec <- extract_mfrm_arbitrary_sim_spec(
    fit,
    data = dat,
    group = "Group"
  )
  expect_s3_class(fitted_spec, "mfrm_arbitrary_sim_spec")
  expect_identical(fitted_spec$assignment, "skeleton")
  expect_identical(fitted_spec$parameter_source, "estimates")
  expect_equal(nrow(fitted_spec$empirical_skeleton), nrow(fit$prep$data))
  expect_identical(fitted_spec$facet_levels$Rater, sort(unique(as.character(dat$Rater))))
  expect_equal(fitted_spec$rating_min, 1L)
  expect_equal(fitted_spec$rating_max, 4L)
  expect_equal(fitted_spec$weight_col, "Weight")
  expect_equal(length(fitted_spec$empirical_parameters$thresholds), 3L)

  sim <- simulate_mfrm_arbitrary_data(fitted_spec, seed = 32)
  expect_named(sim, c("Study", "Person", "Rater", "Criteria", "Task", "Score", "Group", "Weight"))
  expect_equal(nrow(sim), nrow(fit$prep$data))
  expect_true(all(sim$Score %in% 1:4))
  expect_true(all(sort(unique(sim$Group)) %in% c("A", "B")))

  design <- summarize_mfrm_sim_design(fitted_spec)
  expect_equal(design$overview$Observations, nrow(fit$prep$data))
  expect_equal(design$overview$ScoreLevels, 4L)
  expect_equal(design$assignment$MedianLevelsPerPerson[design$assignment$Facet == "Rater"], 2)
})

test_that("extract_mfrm_arbitrary_sim_spec can create balanced fitted-design simulations", {
  base_spec <- build_mfrm_arbitrary_sim_spec(
    n_person = 10,
    facets = c(Rater = 4, Criteria = 2, Task = 3),
    facets_per_person = c(Rater = 2, Task = 2),
    score_levels = 4
  )
  dat <- simulate_mfrm_arbitrary_data(base_spec, seed = 41)
  fit <- suppressWarnings(fit_mfrm(
    dat,
    person = "Person",
    facets = base_spec$facet_names,
    score = "Score",
    rating_min = 1,
    rating_max = 4,
    model = "RSM",
    method = "JML",
    maxit = 20
  ))

  fitted_spec <- extract_mfrm_arbitrary_sim_spec(
    fit,
    assignment = "balanced",
    parameter_source = "resampled",
    facets_per_person = c(Rater = 2, Task = 2)
  )
  sim <- simulate_mfrm_arbitrary_data(fitted_spec, seed = 42)

  expect_identical(fitted_spec$assignment, "balanced")
  expect_identical(fitted_spec$parameter_source, "resampled")
  expect_equal(length(unique(sim$Rater[sim$Person == unique(sim$Person)[1]])), 2)
  expect_equal(length(unique(sim$Task[sim$Person == unique(sim$Person)[1]])), 2)
  expect_true(all(unique(sim$Rater) %in% unique(dat$Rater)))
  expect_true(all(unique(sim$Task) %in% unique(dat$Task)))
})
