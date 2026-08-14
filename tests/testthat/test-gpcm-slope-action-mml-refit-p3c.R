load_gpcm_slope_action_mml_refit <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  source_paths <- file.path(
    root, "inst", "validation",
    c(
      "gpcm-slope-action-projection-p3a-0.2.3.R",
      "gpcm-slope-action-sparse-oracle-p3b-0.2.3.R",
      "gpcm-slope-action-mml-refit-p3c-0.2.3.R"
    )
  )
  record_path <- file.path(
    root, "inst", "validation",
    "gpcm-slope-action-mml-refit-p3c-record-0.2.3.md"
  )
  expect_true(all(file.exists(source_paths)))
  expect_true(file.exists(record_path))
  env <- new.env(parent = baseenv())
  for (source_path in source_paths) sys.source(source_path, envir = env)
  list(env = env, record_path = record_path)
}

mml_refit_test_result <- local({
  cached <- NULL
  function() {
    if (is.null(cached)) {
      context <- load_gpcm_slope_action_mml_refit()
      set.seed(9713)
      initial_seed <- .Random.seed
      result <- context$env$mfrmr_run_gpcm_slope_action_mml_refit(
        replications = 1L,
        training_persons = 80L,
        validation_persons = 100L,
        fit_points = 15L,
        evaluation_points = 21L,
        maxit = 300L
      )
      expect_identical(.Random.seed, initial_seed)
      cached <<- list(context = context, result = result)
    }
    cached
  }
})

test_that("MML coordinates retain the intended identification", {
  context <- load_gpcm_slope_action_mml_refit()
  base <- context$env$mfrmr_gsap_scenarios()$moderate_crossed$parameters
  parameters <- context$env$mfrmr_gsam_parameters(
    base$slopes, base$severities, base$boundaries, 0.2, 1.1
  )
  round_trip <- context$env$mfrmr_gsam_unpack(
    context$env$mfrmr_gsam_pack(parameters)
  )
  expect_equal(round_trip$slopes, parameters$slopes, tolerance = 1e-12)
  expect_equal(round_trip$severities, parameters$severities, tolerance = 1e-12)
  expect_equal(round_trip$boundaries, parameters$boundaries, tolerance = 1e-12)
  expect_equal(round_trip$population_mean, 0.2, tolerance = 1e-12)
  expect_equal(round_trip$population_sd, 1.1, tolerance = 1e-12)
  expect_equal(exp(mean(log(round_trip$slopes))), 1, tolerance = 1e-12)
  expect_equal(sum(round_trip$severities), 0, tolerance = 1e-12)
  expect_equal(mean(round_trip$boundaries), 0, tolerance = 1e-12)
})

test_that("analytic marginal gradients match central differences", {
  context <- load_gpcm_slope_action_mml_refit()
  env <- context$env
  base <- env$mfrmr_gsap_scenarios()$moderate_crossed$parameters
  truth <- env$mfrmr_gsam_parameters(
    base$slopes, base$severities, base$boundaries, 0, 1
  )
  edges <- env$mfrmr_gsab_designs()$balanced_cycle
  data <- env$mfrmr_gsam_simulate(
    24L, edges, truth, "complete_predictor", 20260814L
  )
  for (action in env$mfrmr_gsap_actions()) {
    check <- env$mfrmr_gsam_gradient_check(
      data$responses, edges, action, points = 11L
    )
    expect_lt(max(check$AbsoluteDifference), 1e-6)
  }
})

test_that("finite-sample MML smoke remains fail-closed and curvature-aware", {
  audit <- mml_refit_test_result()$result
  expect_identical(
    audit$status,
    "gpcm_slope_action_finite_sample_mml_refit_complete"
  )
  expect_identical(nrow(audit$fits), 8L)
  expect_identical(nrow(audit$comparisons), 4L)
  expect_identical(nrow(audit$comparison_summary), 4L)
  expect_identical(nrow(audit$recovery_summary), 4L)
  expect_true(all(audit$fits$Convergence == 0L))
  expect_true(all(audit$fits$HessianStatus == "positive_definite"))
  expect_true(all(audit$fits$HessianRank == audit$fits$HessianDimension))
  expect_true(all(audit$fits$StartNLLRange < 1e-4))
  expect_true(all(audit$fits$TerminalGradientSupNorm < 1e-3))
  expect_true(all(audit$fits$TrainingQChangePerPerson < 1e-2))
  expect_true(all(
    audit$comparison_summary$TrainingSelectionQChangeCount == 0L
  ))
  expect_true(all(is.finite(audit$fits$PopulationSDSE)))
  expect_true(all(is.finite(
    as.matrix(audit$fits[paste0("RelativeSlopeSE", 1:4)])
  )))

  expect_false(audit$public_family_added)
  expect_false(audit$public_model_selection_enabled)
  expect_false(audit$readiness_overridden)
  expect_false(audit$standard_error_rule_frozen)
  expect_false(audit$practical_threshold_frozen)
  expect_false(audit$release_authorized)
})

test_that("the MML record does not promote the bounded pilot", {
  audit <- mml_refit_test_result()
  record <- paste(readLines(audit$context$record_path), collapse = "\n")
  expect_match(record, "12 replications cannot establish coverage", fixed = TRUE)
  expect_match(record, "PublicFamilyAdded = FALSE", fixed = TRUE)
  expect_match(record, "PublicModelSelectionEnabled = FALSE", fixed = TRUE)
  expect_match(record, "ReadinessOverridden = FALSE", fixed = TRUE)
  expect_match(record, "StandardErrorRuleFrozen = FALSE", fixed = TRUE)
})
