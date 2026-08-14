facets_mrc_environment <- local({
  cache <- NULL
  function() {
    if (!is.null(cache)) return(cache)
    cache <<- new.env(parent = globalenv())
    validation_dir <- testthat::test_path("..", "..", "inst", "validation")
    files <- c(
      "facets-multifacet-precision-contract-0.2.3.R",
      "facets-multifacet-pilot-adapter-0.2.3.R",
      "facets-rsm-pcm-stress-envelope-0.2.3.R",
      "facets-readiness-calibration-0.2.3.R"
    )
    paths <- file.path(validation_dir, files)
    expect_true(all(file.exists(paths)))
    for (path in paths) sys.source(path, envir = cache)
    cache
  }
})

test_that("readiness registry uses only opened seeds and selects no threshold", {
  env <- facets_mrc_environment()
  registry <- env$mfrmr_facets_mrc_registry()

  expect_equal(nrow(registry), 72L)
  expect_identical(
    sort(unique(registry$BaseSeed)),
    sort(env$mfrmr_facets_mfx_allowed_pilot_seeds())
  )
  expect_equal(sort(unique(registry$Model)), c("PCM", "RSM"))
  expect_equal(length(unique(registry$ScenarioId)), 6L)
  expect_true(all(!registry$FACETSRunRequired))
  expect_true(all(!registry$ThresholdSelectionAuthorized))
  expect_true(all(!registry$ReadinessChangeAuthorized))
  expect_true(all(!registry$ConfirmationAuthorized))
  expect_true(all(!registry$FACETSReplacementClaimAuthorized))
})

test_that("readiness preflight opens no fit and rejects unknown seeds", {
  env <- facets_mrc_environment()
  result <- env$mfrmr_run_facets_mrc_calibration(
    base_seeds = c(451001L, 452001L),
    scenario_ids = c("MFS-MANY-F10", "MFS-SPARSE-WEAK-BRIDGE-F5"),
    models = c("RSM", "PCM")
  )

  expect_s3_class(result, "mfrmr_facets_mrc_result")
  expect_false(result$executed)
  expect_equal(nrow(result$cases), 8L)
  expect_true(all(result$cases$PilotObservationState == "not_run"))
  expect_true(all(!result$cases$CompleteDiagnosticCase))
  expect_equal(nrow(result$summary), 0L)
  expect_length(result$fits, 0L)
  expect_false(result$threshold_selected)
  expect_false(result$readiness_changed)
  expect_false(result$confirmation_authorized)
  expect_error(
    env$mfrmr_run_facets_mrc_calibration(base_seeds = 999001L),
    "already-open pilot seeds"
  )
})

test_that("interior residual excludes only explicit boundary Persons", {
  env <- facets_mrc_environment()
  stationarity <- list(expanded_element_residuals = data.frame(
    ParameterBlock = c("Person", "Person", "Rater"),
    ParameterId = c("P1", "P2", "R1"),
    ScoreResidual = c(0.2, 9, 0.4),
    MeanScoreResidual = c(0.02, 0.9, 0.01),
    stringsAsFactors = FALSE
  ))
  class(stationarity) <- c(
    "mfrmr_facets_mfs_stationarity_audit", "list"
  )
  fit <- list(facets = list(person = data.frame(
    Person = c("P1", "P2"), Extreme = c("none", "high"),
    stringsAsFactors = FALSE
  )))

  result <- env$mfrmr_facets_mrc_interior_residual(stationarity, fit)

  expect_equal(result$AllElementCoordinates, 3L)
  expect_equal(result$InteriorElementCoordinates, 2L)
  expect_equal(result$BoundaryPersonCoordinatesExcluded, 1L)
  expect_equal(result$InteriorScoreResidualSupNorm, 0.4)
  expect_equal(result$InteriorMeanScoreResidualSupNorm, 0.02)
})

test_that("pilot state vocabulary separates structure, boundary, and audit", {
  env <- facets_mrc_environment()
  classify <- env$mfrmr_facets_mrc_classify
  common <- list(
    expected_state = "comparison_eligible_if_both_numerical_gates_pass",
    fit_returned = TRUE,
    typed_structural_rejection = FALSE,
    estimation_converged = TRUE,
    stationarity_returned = TRUE,
    boundary_map_certified = TRUE,
    displacement_converged = TRUE,
    boundary_person_count = 0L
  )

  expect_identical(do.call(classify, common), "interior_pilot_observation")
  common$boundary_person_count <- 2L
  expect_identical(
    do.call(classify, common), "boundary_conditioned_pilot_observation"
  )
  common$boundary_person_count <- 0L
  common$displacement_converged <- FALSE
  expect_identical(do.call(classify, common), "displacement_audit_review")
  negative <- common
  negative$expected_state <- "must_not_be_comparison_eligible"
  negative$fit_returned <- FALSE
  negative$typed_structural_rejection <- TRUE
  expect_identical(
    do.call(classify, negative), "structurally_unidentified_negative_control"
  )
})

test_that("opened calibration summaries describe maxima without self-passing", {
  env <- facets_mrc_environment()
  cases <- data.frame(
    ScenarioId = rep("MFS-MANY-F10", 2L),
    Model = rep("PCM", 2L),
    FitReturned = TRUE,
    EstimationConverged = TRUE,
    RawGradientGatePassed = c(TRUE, FALSE),
    RawGradientGateStableAcrossReplication = c(FALSE, TRUE),
    RawGradientGateChangedByReplication = c(TRUE, FALSE),
    KnownBoundaryPersonCount = c(0L, 1L),
    DisplacementConverged = TRUE,
    CompleteDiagnosticCase = TRUE,
    TerminalGradientSupNorm = c(1e-5, 2e-4),
    InteriorMeanScoreResidualSupNorm = c(1e-6, 2e-5),
    BoundaryConditionedParameterChangeSupNorm = c(3e-5, 4e-5),
    BoundaryConditionedRelativeObjectiveImprovement = c(1e-12, 2e-12),
    stringsAsFactors = FALSE
  )

  summary <- env$mfrmr_facets_mrc_summarize(cases)

  expect_equal(summary$Cases, 2L)
  expect_equal(summary$RawGradientGatePassedCases, 1L)
  expect_equal(summary$RawGradientGateChangedByReplicationCases, 1L)
  expect_equal(summary$BoundaryCases, 1L)
  expect_equal(summary$MaximumRawGradient, 2e-4)
  expect_equal(summary$MaximumBoundaryConditionedDisplacement, 4e-5)
  expect_false(summary$ThresholdSelected)
  expect_false(summary$ReadinessChanged)
  expect_false(summary$ConfirmationAuthorized)
})
