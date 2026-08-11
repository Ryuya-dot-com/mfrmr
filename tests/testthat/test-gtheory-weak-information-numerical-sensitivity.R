gtheory_weak_information_numerical_paths <- function() {
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
      "gtheory-weak-information-diagnostic-refit-prototype-0.2.3.R",
      "gtheory-weak-information-bootstrap-prototype-0.2.3.R",
      "gtheory-weak-information-feasibility-prototype-0.2.3.R",
      "gtheory-weak-information-feasibility-runner-0.2.3.R",
      "gtheory-weak-information-numerical-sensitivity-0.2.3.R"
    )
  )
}

load_gtheory_weak_information_numerical <- function() {
  paths <- gtheory_weak_information_numerical_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  for (package in c(
    "digest", "lme4", "glmmTMB", "TMB", "minqa", "nloptr"
  )) {
    skip_if_not_installed(package)
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtheory_weak_information_feasibility_fixture <- function(env) {
  feasibility <- env$mfrmr_gtwf_contract()
  rows <- env$mfrmr_gtwf_manifest(feasibility)$Rows
  rows$RawLikelihoodDrop <- 3 * rows$TargetVariance
  structure(list(
    RunnerContractHash =
      "c97b5d08c29e7a7537fe4669f938de9e978b4bb651596007af0b7ea7b9378df7",
    ExecutionHash =
      "04ec60ab6d4351c0d8c6416543fa8ac46e15585bbe85680f829b341beb34a22b",
    ExactAccountingPassed = TRUE,
    FeasibilityEvidenceReady = TRUE,
    AtomicRows = rows,
    ThresholdFrozen = FALSE, InferenceReady = FALSE, DecisionReady = FALSE
  ), class = "mfrmr_gtwx_execution")
}

gtheory_weak_information_numerical_objects <- function(env) {
  feasibility_execution <-
    gtheory_weak_information_feasibility_fixture(env)
  contract <- env$mfrmr_gtwy_contract(feasibility_execution)
  manifest <- env$mfrmr_gtwy_manifest(contract)
  list(
    FeasibilityExecution = feasibility_execution,
    Contract = contract, Manifest = manifest
  )
}

test_that("Draft.83d2b2b1e freezes documented numerical profiles", {
  env <- load_gtheory_weak_information_numerical()
  objects <- gtheory_weak_information_numerical_objects(env)
  contract <- objects$Contract
  profiles <- contract$Profiles

  expect_s3_class(contract, "mfrmr_gtwy_contract")
  expect_equal(nrow(profiles), 6L)
  expect_equal(as.integer(table(profiles$Backend)), c(3L, 3L))
  expect_equal(sum(profiles$IsDefault), 2L)
  expect_equal(anyDuplicated(profiles$ProfileId), 0L)
  expect_equal(anyDuplicated(profiles$ProfileHash), 0L)
  expect_equal(contract$SensitivityPairCount, 9000L)
  expect_equal(contract$SensitivityBackendFitCount, 18000L)
  expect_false(contract$PracticalEquivalenceThresholdSelected)
  expect_false(contract$CalibrationDataGenerationPermitted)
  expect_false(contract$ThresholdSelectionPermitted)
  expect_false(contract$BootstrapPermitted)
  expect_false(contract$InferenceReady)
  expect_false(contract$DecisionReady)
  expect_true(all(grepl("^https://", contract$Sources$Locator)))
  expect_true(any(grepl("lme4/reference/convergence", contract$Sources$Locator)))
  expect_true(any(grepl("glmmtmb.*troubleshooting", contract$Sources$Locator,
                        ignore.case = TRUE)))

  strict <- env$mfrmr_gtwy_control("lme4_strict_nloptwrap")
  expect_identical(strict$optimizer, "nloptwrap")
  expect_equal(strict$optCtrl$xtol_abs, 1e-8)
  expect_equal(strict$optCtrl$ftol_abs, 1e-8)
  expect_equal(strict$optCtrl$maxeval, 100000)
  bobyqa <- env$mfrmr_gtwy_control("lme4_bobyqa")
  expect_identical(bobyqa$optimizer, "bobyqa")
  expect_equal(bobyqa$optCtrl$rhoend, 1e-8)
  expect_equal(bobyqa$optCtrl$maxfun, 100000)
  tight <- env$mfrmr_gtwy_control("glmmTMB_tight_nlminb")
  expect_equal(tight$optCtrl$iter.max, 2000)
  expect_equal(tight$optCtrl$eval.max, 2000)
  expect_equal(tight$optCtrl$rel.tol, 1e-10)
  expect_equal(tight$optCtrl$x.tol, 1e-10)
  bfgs <- env$mfrmr_gtwy_control("glmmTMB_optim_bfgs")
  expect_identical(bfgs$optimizer, stats::optim)
  expect_identical(bfgs$optArgs$method, "BFGS")
  expect_equal(bfgs$optCtrl$maxit, 2000)
  expect_equal(bfgs$optCtrl$reltol, 1e-10)
  expect_error(env$mfrmr_gtwy_control("unregistered"), "Unknown")
})

test_that("Draft.83d2b2b1e manifest closes the frozen denominator", {
  env <- load_gtheory_weak_information_numerical()
  objects <- gtheory_weak_information_numerical_objects(env)
  rows <- objects$Manifest$Rows

  expect_s3_class(objects$Manifest, "mfrmr_gtwy_manifest")
  expect_equal(nrow(rows), 9000L)
  expect_equal(length(unique(rows$DatasetId)), 750L)
  expect_true(all(table(rows$RouteId) == 3L))
  expect_true(all(table(rows$DatasetId) == 12L))
  expect_equal(anyDuplicated(rows$SensitivityRouteId), 0L)
  expect_equal(anyDuplicated(names(rows)), 0L)
  expect_true(all(table(rows$Backend, rows$ProfileRole) == 1500L))
  expect_true(all(table(
    rows$ScenarioId, rows$MethodId, rows$ProfileId
  )[table(rows$ScenarioId, rows$MethodId, rows$ProfileId) > 0] == 25L))
  expect_true(objects$Manifest$ResultsViewedBeforeContract)
  expect_false(objects$Manifest$CalibrationDataGenerated)
  expect_false(objects$Manifest$ThresholdSelectionPermitted)

  invalid <- objects$FeasibilityExecution
  invalid$ExecutionHash <- paste0("x", invalid$ExecutionHash)
  expect_error(env$mfrmr_gtwy_contract(invalid), "exact Draft")
})

test_that("Draft.83d2b2b1e checkpoints and dataset markers fail closed", {
  env <- load_gtheory_weak_information_numerical()
  objects <- gtheory_weak_information_numerical_objects(env)
  rows <- objects$Manifest$Rows
  routes <- rows[rows$DatasetId == rows$DatasetId[[1L]], , drop = FALSE]
  checkpoints <- lapply(seq_len(nrow(routes)), function(index) {
    route <- routes[index, , drop = FALSE]
    atomic <- env$mfrmr_gtwy_failure_row(
      route, "synthetic_checkpoint_test", "intentional typed failure"
    )
    env$mfrmr_gtwy_checkpoint(
      objects$Contract, objects$Manifest$ManifestHash,
      route, NULL, NULL, atomic
    )
  })
  first <- checkpoints[[1L]]
  expect_true(env$mfrmr_gtwy_validate_checkpoint(
    first, objects$Contract, objects$Manifest$ManifestHash,
    routes[1L, , drop = FALSE]
  )$Valid)
  tampered <- first
  tampered$Identity$AtomicResult$FailureStage <- "tampered"
  expect_false(env$mfrmr_gtwy_validate_checkpoint(
    tampered, objects$Contract, objects$Manifest$ManifestHash,
    routes[1L, , drop = FALSE]
  )$Valid)

  marker <- env$mfrmr_gtwy_marker(
    objects$Contract, objects$Manifest$ManifestHash,
    routes$DatasetId[[1L]], checkpoints
  )
  expect_true(env$mfrmr_gtwy_validate_marker(
    marker, objects$Contract, objects$Manifest$ManifestHash,
    routes$DatasetId[[1L]], checkpoints
  ))
  changed <- checkpoints
  changed[[1L]]$ResultHash <- paste0("x", changed[[1L]]$ResultHash)
  expect_false(env$mfrmr_gtwy_validate_marker(
    marker, objects$Contract, objects$Manifest$ManifestHash,
    routes$DatasetId[[1L]], changed
  ))

  root <- withr::local_tempdir(pattern = "mfrmr-gtwy-test-")
  path <- env$mfrmr_gtwy_route_path(root, routes$SensitivityRouteId[[1L]])
  env$mfrmr_gtwx_atomic_write(first, path)
  expect_identical(readRDS(path)$ResultHash, first$ResultHash)
})

test_that("Draft.83d2b2b1e summaries retain optimizer disagreement", {
  env <- load_gtheory_weak_information_numerical()
  objects <- gtheory_weak_information_numerical_objects(env)
  rows <- objects$Manifest$Rows
  baseline <- objects$FeasibilityExecution$AtomicRows
  baseline_drop <- baseline$RawLikelihoodDrop[match(rows$RouteId,
                                                     baseline$RouteId)]
  profile_shift <- ifelse(rows$ProfileRole == "default_replay", 0,
                          ifelse(rows$ProfileRole == "strict_same_algorithm",
                                 1e-7, 2e-7))
  rows$PairReturned <- TRUE
  rows$FullLogLikelihood <- -100 + profile_shift
  rows$ReducedLogLikelihood <-
    rows$FullLogLikelihood - (baseline_drop + profile_shift) / 2
  rows$RawLikelihoodDrop <- baseline_drop + profile_shift
  rows$LikelihoodDiagnosticAvailable <- TRUE
  rows$NegativeDropWithinTolerance <-
    rows$RawLikelihoodDrop >= -objects$Contract$NegativeLikelihoodTolerance
  rows$MaterialNegativeDrop <-
    rows$RawLikelihoodDrop < -objects$Contract$NegativeLikelihoodTolerance
  rows$TargetEstimate <- rows$TargetVariance + profile_shift
  rows$TargetBoundaryToleranceReached <- rows$TargetEstimate <= 1e-8
  rows$NuisanceBoundaryPresent <- FALSE

  first_route <- rows$RouteId[[1L]]
  altered <- rows$RouteId == first_route &
    rows$ProfileRole == "different_algorithm"
  rows$RawLikelihoodDrop[altered] <- -1e-3
  rows$ReducedLogLikelihood[altered] <-
    rows$FullLogLikelihood[altered] + 5e-4
  rows$NegativeDropWithinTolerance[altered] <- FALSE
  rows$MaterialNegativeDrop[altered] <- TRUE
  second_route <- unique(rows$RouteId)[[2L]]
  nonfinite <- rows$RouteId == second_route &
    rows$ProfileRole == "different_algorithm"
  rows$RawLikelihoodDrop[nonfinite] <- NA_real_
  rows$ReducedLogLikelihood[nonfinite] <- NA_real_
  rows$LikelihoodDiagnosticAvailable[nonfinite] <- FALSE
  rows$NegativeDropWithinTolerance[nonfinite] <- FALSE
  rows$MaterialNegativeDrop[nonfinite] <- FALSE
  summary <- env$mfrmr_gtwy_summaries(rows, baseline, objects$Contract)

  expect_equal(nrow(summary$RouteComparison), 3000L)
  expect_equal(nrow(summary$ProfileAvailability), 360L)
  expect_equal(nrow(summary$SpreadGrid), 80L)
  expect_true(summary$DefaultReplayPassed)
  expect_identical(
    summary$RouteComparison$SignState[
      summary$RouteComparison$RouteId == first_route
    ],
    "optimizer_sensitive_material_vs_within_tolerance"
  )
  expect_identical(
    summary$RouteComparison$SignState[
      summary$RouteComparison$RouteId == second_route
    ],
    "incomplete_profile_sign_state"
  )
  expect_equal(sum(summary$ProfileAvailability$MaterialNegativeN), 1L)
  expect_true(all(summary$RouteComparison$DefaultReplayWithinTolerance))
  expect_false(summary$PracticalEquivalenceThresholdSelected)
  expect_false(summary$CalibrationDataGenerated)
  expect_false(summary$BootstrapRun)
  expect_false(summary$PValuesAssigned)
  expect_false(summary$IntervalsAssigned)
})

test_that("Draft.83d2b2b1e executes and exactly resumes all profiles", {
  skip_if_not(
    identical(
      Sys.getenv("MFRMR_RUN_GTHEORY_NUMERICAL_SENSITIVITY_FULL"), "true"
    ),
    "the 18,000-fit numerical audit is an explicit validation tier"
  )
  checkpoint_root <- Sys.getenv(
    "MFRMR_GTHEORY_NUMERICAL_SENSITIVITY_CHECKPOINT_ROOT"
  )
  result_path <- Sys.getenv(
    "MFRMR_GTHEORY_NUMERICAL_SENSITIVITY_RESULT_PATH"
  )
  feasibility_path <- Sys.getenv(
    "MFRMR_GTHEORY_FEASIBILITY_RESULT_PATH"
  )
  skip_if_not(nzchar(checkpoint_root),
              "an explicit checkpoint root is required")
  skip_if_not(nzchar(feasibility_path) && file.exists(feasibility_path),
              "the exact feasibility execution is required")
  env <- load_gtheory_weak_information_numerical()
  feasibility_execution <- readRDS(feasibility_path)
  contract <- env$mfrmr_gtwy_contract(feasibility_execution)
  manifest <- env$mfrmr_gtwy_manifest(contract)
  execution <- env$mfrmr_gtwy_execute(
    contract, manifest, feasibility_execution,
    checkpoint_root = checkpoint_root, progress_every = 25L
  )
  resumed <- env$mfrmr_gtwy_execute(
    contract, manifest, feasibility_execution,
    checkpoint_root = checkpoint_root, progress_every = 100L
  )

  expect_s3_class(execution, "mfrmr_gtwy_execution")
  expect_equal(nrow(execution$AtomicRows), 9000L)
  expect_equal(nrow(execution$Summaries$RouteComparison), 3000L)
  expect_equal(length(execution$MarkerHashes), 750L)
  expect_true(execution$ExactAccountingPassed)
  expect_false(execution$DefaultReplayPassed)
  expect_false(execution$NumericalSensitivityEvidenceReady)
  replay <- execution$Summaries$RouteComparison
  expect_equal(sum(!replay$DefaultReplayWithinTolerance), 7L)
  expect_true(all(!is.finite(replay$BaselineRawLikelihoodDrop[
    !replay$DefaultReplayWithinTolerance
  ])))
  expect_true(all(!is.finite(replay$DefaultReplayRawLikelihoodDrop[
    !replay$DefaultReplayWithinTolerance
  ])))
  expect_identical(resumed$ExecutionHash, execution$ExecutionHash)
  expect_equal(resumed$CheckpointReuseCount, 9000L)
  expect_equal(resumed$ComputedRouteCount, 0L)
  expect_false(resumed$CalibrationEvidenceReady)
  expect_false(resumed$BootstrapOperatingCharacteristicsReady)
  expect_false(resumed$ThresholdFrozen)
  expect_false(resumed$ConfirmationAuthorized)
  expect_false(resumed$InferenceReady)
  expect_false(resumed$DecisionReady)
  if (nzchar(result_path)) saveRDS(resumed, result_path, version = 3L)
})
