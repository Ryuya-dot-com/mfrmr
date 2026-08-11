gtheory_glmmtmb_stationarity_calibration_design_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-balanced-estimation-prototype-0.2.3.R",
      "gtheory-design-incidence-audit-0.2.3.R",
      "gtheory-covariance-information-audit-0.2.3.R",
      "gtheory-glmmtmb-parity-prototype-0.2.3.R",
      "gtheory-ademp-registry-prototype-0.2.3.R",
      "gtheory-ademp-generator-prototype-0.2.3.R",
      "gtheory-ademp-prefit-prototype-0.2.3.R",
      "gtheory-ademp-fit-prototype-0.2.3.R",
      "gtheory-weak-information-calibration-prototype-0.2.3.R",
      "gtheory-weak-information-pilot-prototype-0.2.3.R",
      "gtheory-weak-information-glmmtmb-stationarity-instrumentation-0.2.3.R",
      paste0(
        "gtheory-weak-information-glmmtmb-stationarity-calibration-",
        "design-0.2.3.R"
      )
    )
  )
}

load_gtheory_glmmtmb_stationarity_calibration_design <- function() {
  paths <- gtheory_glmmtmb_stationarity_calibration_design_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  for (package in c("digest", "lme4", "glmmTMB", "TMB", "numDeriv")) {
    skip_if_not_installed(package)
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

test_that("b1g5 separates numerical, curvature, boundary, and resolution states", {
  env <- load_gtheory_glmmtmb_stationarity_calibration_design()
  states <- env$mfrmr_gtwsz_state_registry()

  expect_setequal(
    states$ReferenceState$State,
    c(
      "finite_local_minimum", "finite_stationary_flat",
      "finite_nonstationary", "finite_saddle_or_max", "boundary_limit",
      "reference_unresolved", "not_evaluable"
    )
  )
  expect_true("boundary_handoff" %in% states$ApplicationState$State)
  expect_true("spectral_positive_not_factorable" %in% states$CurvatureState)
  expect_true("boundary_limit_supported" %in% states$BoundaryState)
  expect_false(any(
    states$ApplicationState$State %in%
      c("resolved", "not_resolved")
  ))
})

test_that("Newton decrement and Hessian inertia obey affine mathematics", {
  env <- load_gtheory_glmmtmb_stationarity_calibration_design()
  parameter <- c(0.4, -1.2, 2.1)
  gradient <- c(0.02, -0.003, 0.15)
  hessian <- matrix(c(
    5, 1, 0.2,
    1, 3, 0.4,
    0.2, 0.4, 2
  ), nrow = 3L, byrow = TRUE)
  audit <- env$mfrmr_gtwsz_affine_audit(
    parameter, 120, gradient, hessian
  )

  expect_true(audit$PositiveDefinitenessPreserved)
  expect_true(audit$NewtonDecrementInvariant)
  expect_false(audit$RawGradientInvariant)
  expect_equal(nrow(audit$Rows), 4L)
  expect_gt(length(unique(signif(
    audit$Rows$Lme4ScaledMaximumAbsolute, 10
  ))), 1L)

  indefinite <- diag(c(2, 1, -0.5))
  fixtures <- env$mfrmr_gtwsz_coordinate_fixtures(3L)
  inertia <- vapply(fixtures, function(transform) {
    transformed <- env$mfrmr_gtwsz_affine_transform(
      parameter, gradient, indefinite, transform
    )
    sum(eigen(
      transformed$Hessian, symmetric = TRUE, only.values = TRUE
    )$values < 0)
  }, integer(1L))
  expect_true(all(inertia == 1L))
})

test_that("numerical error accounting retains unresolved and failure states", {
  env <- load_gtheory_glmmtmb_stationarity_calibration_design()
  accounting <- env$mfrmr_gtwsz_error_accounting(
    c(
      "numerically_eligible", "numerically_ineligible",
      "numerically_eligible", "boundary_handoff", "indeterminate",
      "not_evaluable"
    ),
    c(
      "finite_local_minimum", "finite_stationary_flat",
      "finite_nonstationary", "boundary_limit", "reference_unresolved",
      "not_evaluable"
    )
  )

  expect_equal(accounting$ReferencePositive, 2L)
  expect_equal(accounting$NumericalFalseUnready, 1L)
  expect_equal(accounting$ReferenceNegative, 2L)
  expect_equal(accounting$NumericalFalseReady, 1L)
  expect_equal(accounting$BoundaryHandoff, 1L)
  expect_equal(accounting$ReferenceUnresolved, 2L)
})

test_that("b1g5 freezes a sealed design and no calibration execution", {
  env <- load_gtheory_glmmtmb_stationarity_calibration_design()
  plan <- env$mfrmr_gtwp_plan()
  contract <- env$mfrmr_gtwsz_contract(plan)
  manifest <- env$mfrmr_gtwsz_manifest(contract, plan)

  expect_true(contract$DesignSchemaReady)
  expect_true(contract$CandidateArchitectureFrozen)
  expect_true(contract$ReferenceArchitectureFrozen)
  expect_true(contract$CoordinateAuditReady)
  expect_false(contract$ReferenceToleranceFrozen)
  expect_false(contract$StationarityThresholdFrozen)
  expect_false(contract$StationarityCriterionReady)
  expect_false(contract$CalibrationExecutionAuthorized)
  expect_false(contract$CalibrationDataGenerated)
  expect_false(contract$CalibrationResultsViewed)
  expect_false(contract$FullExecutionAuthorized)
  expect_false(contract$InferenceReady)
  expect_identical(manifest$BaseMethodUnitCount, 12000L)
  expect_identical(manifest$IndependentDatasetCount, 3000L)
  expect_identical(manifest$CandidateFitCount, 144000L)
  expect_identical(manifest$ReferenceProblemCount, 24000L)
  expect_true(env$mfrmr_gtwsz_manifest_hash_valid(manifest))
  expect_false(manifest$ExecutionAuthorized)
  expect_false(manifest$DataGenerated)
  expect_false(manifest$ResultsViewed)
  expect_false(manifest$ThresholdSelectionPermitted)

  changed <- manifest
  changed$Rows$CandidateFitCount[[1L]] <- 11L
  expect_false(env$mfrmr_gtwsz_manifest_hash_valid(changed))
})

test_that("b1g5 revalidates retained b1g4 artifacts when available", {
  paths <- c(
    execution = "/private/tmp/mfrmr-gtwsy-stationarity-v1.rds",
    adjudication = "/private/tmp/mfrmr-gtwsy-adjudication-v1.rds"
  )
  skip_if_not(all(file.exists(paths)), "retained b1g4 artifacts unavailable")
  env <- load_gtheory_glmmtmb_stationarity_calibration_design()
  execution <- readRDS(paths[["execution"]])
  adjudication <- readRDS(paths[["adjudication"]])

  expect_true(env$mfrmr_gtwsz_b1g4_artifacts_valid(
    execution, adjudication
  ))
  adjudication$Summary$ThresholdSelected <- TRUE
  expect_false(env$mfrmr_gtwsz_b1g4_artifacts_valid(
    execution, adjudication
  ))
})
