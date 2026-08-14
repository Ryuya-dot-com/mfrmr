load_gpcm_slope_action_public_mml_bridge <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  source_paths <- file.path(
    root, "inst", "validation",
    c(
      "gpcm-slope-action-projection-p3a-0.2.3.R",
      "gpcm-slope-action-sparse-oracle-p3b-0.2.3.R",
      "gpcm-slope-action-mml-refit-p3c-0.2.3.R",
      "gpcm-slope-action-public-mml-bridge-p3d-0.2.3.R"
    )
  )
  record_path <- file.path(
    root, "inst", "validation",
    "gpcm-slope-action-public-mml-bridge-p3d-record-0.2.3.md"
  )
  expect_true(all(file.exists(source_paths)))
  expect_true(file.exists(record_path))
  env <- new.env(parent = baseenv())
  for (source_path in source_paths) sys.source(source_path, envir = env)
  list(env = env, source_paths = source_paths, record_path = record_path)
}

public_mml_bridge_test_result <- local({
  cached <- NULL
  function() {
    if (is.null(cached)) {
      context <- load_gpcm_slope_action_public_mml_bridge()
      env <- context$env
      base <- env$mfrmr_gsap_scenarios()$moderate_crossed$parameters
      truth <- env$mfrmr_gsam_parameters(
        base$slopes, base$severities, base$boundaries, 0, 1
      )
      edges <- env$mfrmr_gsab_designs()$complete
      data <- env$mfrmr_gsam_simulate(
        40L, edges, truth, "complete_predictor", seed = 20260814L
      )
      run <- env$mfrmr_gsapd_run_one(data$responses, edges, points = 15L)
      cached <<- list(context = context, run = run)
    }
    cached
  }
})

test_that("the public fit and independent likelihood share one kernel", {
  audit <- public_mml_bridge_test_result()
  env <- audit$context$env
  run <- audit$run
  summary <- run$summary
  guard <- env$mfrmr_gsapd_kernel_match_guard(summary)

  expect_identical(nrow(summary), 1L)
  expect_identical(summary$PublicNpar, 19L)
  expect_lt(summary$NLLAbsDifference, 1e-6)
  expect_lt(summary$MappedPublicNLLAbsDifference, 1e-8)
  expect_lt(summary$ProbabilityMaxAbsDifference, 1e-4)
  expect_lt(summary$SlopeSEMaxAbsDifference, 1e-4)
  expect_lt(summary$PopulationSDSEAbsDifference, 1e-4)
  expect_identical(summary$PublicCovarianceStatus, "ok")
  expect_identical(summary$PublicCovarianceRank, 19L)
  expect_identical(summary$IndependentHessianStatus, "positive_definite")
  expect_identical(summary$IndependentHessianRank, 19L)
  expect_true(summary$PublicEstimationConverged)
  expect_identical(summary$IndependentConvergence, 0L)
  expect_true(guard$matched)
  expect_true(all(guard$checks$Passed))

  expect_equal(exp(mean(log(run$public_map$slopes))), 1, tolerance = 1e-12)
  expect_equal(sum(run$public_map$severities), 0, tolerance = 1e-12)
  expect_equal(mean(run$public_map$boundaries), 0, tolerance = 1e-12)
})

test_that("numerical agreement does not override public readiness", {
  summary <- public_mml_bridge_test_result()$run$summary
  expect_identical(summary$PublicFitReadiness, "review")
  expect_false(summary$PublicInferenceReady)
  expect_match(
    summary$PublicReadinessReasons,
    "design_rank_not_evaluated",
    fixed = TRUE
  )
  expect_match(
    summary$PublicReadinessReasons,
    "mml_gpcm_slope_boundary_not_evaluated",
    fixed = TRUE
  )
})

test_that("the bridge guard fails closed and captured conditions remain visible", {
  audit <- public_mml_bridge_test_result()
  env <- audit$context$env
  changed <- audit$run$summary
  changed$ProbabilityMaxAbsDifference <- Inf
  expect_false(env$mfrmr_gsapd_kernel_match_guard(changed)$matched)
  changed$ProbabilityMaxAbsDifference <- NA_real_
  expect_false(env$mfrmr_gsapd_kernel_match_guard(changed)$matched)
  expect_error(
    env$mfrmr_gsapd_kernel_match_guard(changed[0, , drop = FALSE]),
    "non-empty complete bridge summary",
    fixed = TRUE
  )

  captured <- env$mfrmr_gsapd_capture({
    warning("visible bridge warning")
    message("visible bridge message")
    1L
  })
  expect_identical(captured$value, 1L)
  expect_identical(captured$warnings, "visible bridge warning")
  expect_identical(captured$messages, "visible bridge message\n")
  expect_error(
    env$mfrmr_gsapd_capture(stop("visible bridge error")),
    "visible bridge error",
    fixed = TRUE
  )
})

test_that("the bridge record retains its scientific boundary", {
  audit <- public_mml_bridge_test_result()
  record <- paste(readLines(audit$context$record_path), collapse = "\n")
  expect_match(record, "not enough to call the readiness contract overly strict", fixed = TRUE)
  expect_match(record, "ReadinessOverridden = FALSE", fixed = TRUE)
  expect_match(record, "PublicSEEligibilityOverridden = FALSE", fixed = TRUE)
  expect_match(record, "TAMManyFacetEquivalenceClaimed = FALSE", fixed = TRUE)

  source_text <- paste(
    unlist(lapply(audit$context$source_paths, readLines)),
    collapse = "\n"
  )
  expect_false(grepl("sha-?256|md5|digest::", source_text, ignore.case = TRUE))
})
