gtheory_weak_information_runner_paths <- function() {
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
      "gtheory-weak-information-feasibility-runner-0.2.3.R"
    )
  )
}

load_gtheory_weak_information_runner <- function() {
  paths <- gtheory_weak_information_runner_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  for (package in c("digest", "lme4", "glmmTMB", "TMB")) {
    skip_if_not_installed(package)
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtheory_weak_information_runner_contract <- function(env) {
  feasibility <- env$mfrmr_gtwf_contract()
  manifest <- env$mfrmr_gtwf_manifest(feasibility)
  authorization <- env$mfrmr_gtwx_authorization_reference(
    feasibility, manifest
  )
  runner <- env$mfrmr_gtwx_contract(
    feasibility, manifest, authorization
  )
  list(
    Feasibility = feasibility, Manifest = manifest,
    Authorization = authorization, Runner = runner
  )
}

test_that("Draft.83d2b2b1d binds the recorded upstream authorization", {
  env <- load_gtheory_weak_information_runner()
  objects <- gtheory_weak_information_runner_contract(env)
  contract <- objects$Runner

  expect_s3_class(contract, "mfrmr_gtwx_contract")
  expect_identical(
    objects$Authorization$AuthorizationHash,
    "e36e82198763e7a785a840cbd9bc029b658b919f58e14377a24e6ced1ca64e1a"
  )
  expect_true(env$mfrmr_gtwx_validate_authorization(objects$Authorization))
  expect_true(contract$ExecutionAuthorized)
  expect_equal(contract$PlannedRows, 3000L)
  expect_equal(contract$PlannedDatasets, 750L)
  expect_equal(contract$PlannedBackendFits, 6000L)
  expect_identical(contract$ReplicateBand, c(101L, 125L))
  expect_false(contract$ThresholdSelectionPermitted)
  expect_false(contract$InnerBootstrapPermitted)
  expect_false(contract$EarlyStoppingPermitted)
  expect_false(contract$FeasibilityEvidenceReady)
  expect_false(contract$InferenceReady)
  expect_false(contract$DecisionReady)
  expect_error(
    env$mfrmr_gtwx_contract(
      objects$Feasibility, objects$Manifest, authorization = NULL
    ),
    "separate Draft.83d2b2b1c authorization"
  )
  tampered <- objects$Authorization
  tampered$RuntimeExecutionHash <- paste0("x", tampered$RuntimeExecutionHash)
  expect_false(env$mfrmr_gtwx_validate_authorization(tampered))
  expect_error(
    env$mfrmr_gtwx_contract(
      objects$Feasibility, objects$Manifest, tampered
    ),
    "not jointly authorized"
  )
})

test_that("Draft.83d2b2b1d route and dataset checkpoints fail closed", {
  env <- load_gtheory_weak_information_runner()
  objects <- gtheory_weak_information_runner_contract(env)
  routes <- objects$Manifest$Rows[
    objects$Manifest$Rows$DatasetId ==
      objects$Manifest$Rows$DatasetId[[1L]], , drop = FALSE
  ]
  checkpoints <- lapply(seq_len(nrow(routes)), function(index) {
    route <- routes[index, , drop = FALSE]
    atomic <- env$mfrmr_gtwf_failure_row(
      route, "synthetic_checkpoint_test", "intentional typed failure"
    )
    env$mfrmr_gtwx_route_checkpoint(
      objects$Runner, route, NULL, NULL, atomic
    )
  })
  root <- withr::local_tempdir(pattern = "mfrmr-gtwx-test-")
  route_path <- env$mfrmr_gtwx_route_path(root, routes$RouteId[[1L]])
  env$mfrmr_gtwx_atomic_write(checkpoints[[1L]], route_path)
  restored <- readRDS(route_path)
  validation <- env$mfrmr_gtwx_validate_route(
    restored, objects$Runner, routes[1L, , drop = FALSE]
  )

  expect_true(validation$Valid)
  expect_identical(validation$Reason, "valid")
  expect_false(validation$AtomicResult$PairReturned[[1L]])
  expect_identical(
    validation$AtomicResult$FailureStage[[1L]],
    "synthetic_checkpoint_test"
  )

  tampered <- restored
  tampered$Identity$AtomicResult$FailureStage <- "tampered"
  expect_false(env$mfrmr_gtwx_validate_route(
    tampered, objects$Runner, routes[1L, , drop = FALSE]
  )$Valid)
  stale_contract <- objects$Runner
  stale_contract$RunnerContractHash <- paste0(
    "x", stale_contract$RunnerContractHash
  )
  expect_false(env$mfrmr_gtwx_validate_route(
    restored, stale_contract, routes[1L, , drop = FALSE]
  )$Valid)

  marker <- env$mfrmr_gtwx_dataset_marker(
    objects$Runner, routes$DatasetId[[1L]], checkpoints
  )
  expect_true(env$mfrmr_gtwx_validate_dataset(
    marker, objects$Runner, routes$DatasetId[[1L]], checkpoints
  ))
  changed <- checkpoints
  changed[[1L]]$RouteResultHash <- paste0(
    "x", changed[[1L]]$RouteResultHash
  )
  expect_false(env$mfrmr_gtwx_validate_dataset(
    marker, objects$Runner, routes$DatasetId[[1L]], changed
  ))

  second <- checkpoints[[1L]]
  second$Timing <- data.frame(ElapsedSeconds = 9)
  env$mfrmr_gtwx_atomic_write(second, route_path)
  expect_equal(readRDS(route_path)$Timing$ElapsedSeconds, 9)
  expect_error(env$mfrmr_gtwx_checkpoint_root("/"), "cannot be")
})

test_that("Draft.83d2b2b1d rank probability retains ties and denominator", {
  env <- load_gtheory_weak_information_runner()
  result <- env$mfrmr_gtwx_rank_probability(
    positive = c(2, 3, NA), negative = c(1, 2, Inf)
  )

  expect_equal(result$PositiveN, 2L)
  expect_equal(result$NegativeN, 2L)
  expect_equal(result$PairDenominator, 4L)
  expect_equal(result$Wins, 3L)
  expect_equal(result$Ties, 1L)
  expect_equal(result$Losses, 0L)
  expect_equal(result$RankProbability, 0.875)
  unavailable <- env$mfrmr_gtwx_rank_probability(numeric(), 1:3)
  expect_equal(unavailable$PairDenominator, 0L)
  expect_true(is.na(unavailable$RankProbability))
})

test_that("Draft.83d2b2b1d summaries are threshold-free and stratified", {
  env <- load_gtheory_weak_information_runner()
  objects <- gtheory_weak_information_runner_contract(env)
  rows <- objects$Manifest$Rows
  rows$PairReturned <- TRUE
  rows$LikelihoodDiagnosticAvailable <- TRUE
  rows$FeasibilityScoreAvailable <- TRUE
  rows$NegativeDropWithinTolerance <- TRUE
  rows$TargetFractionTotal <- rows$TargetVariance
  rows$TargetToResidualRatio <- 2 * rows$TargetVariance
  rows$RawLikelihoodDrop <- 3 * rows$TargetVariance
  rows$TargetBoundaryToleranceReached <- rows$TargetVariance <= 1e-8
  rows$NuisanceBoundaryPresent <- FALSE
  summary <- env$mfrmr_gtwx_summaries(rows, objects$Runner)

  expect_equal(nrow(summary$Availability), 120L)
  expect_true(all(summary$Availability$PlannedN == 25L))
  expect_true(all(summary$Availability$CommonScoreAvailableN == 25L))
  expect_equal(nrow(summary$SpearmanOrdering), 60L)
  expect_true(all(summary$SpearmanOrdering$AvailableN == 150L))
  expect_equal(summary$SpearmanOrdering$SpearmanRho, rep(1, 60),
               tolerance = 1e-12)
  expect_equal(nrow(summary$RegisteredControlRankProbability), 24L)
  expect_true(all(
    summary$RegisteredControlRankProbability$RankProbability == 1
  ))
  expect_true(all(is.na(summary$SpearmanOrdering$PValue)))
  expect_true(all(is.na(
    summary$RegisteredControlRankProbability$Threshold
  )))
  expect_false(summary$ThresholdSelected)
  expect_false(summary$InnerBootstrapRun)
  expect_false(summary$PValuesAssigned)
  expect_false(summary$IntervalsAssigned)
})

test_that("Draft.83d2b2b1d executes and exactly resumes the frozen ledger", {
  skip_if_not(
    identical(Sys.getenv("MFRMR_RUN_GTHEORY_FEASIBILITY_FULL"), "true"),
    "the 6,000-fit feasibility run is an explicit validation tier"
  )
  checkpoint_root <- Sys.getenv(
    "MFRMR_GTHEORY_FEASIBILITY_CHECKPOINT_ROOT"
  )
  skip_if_not(nzchar(checkpoint_root),
              "an explicit checkpoint root is required")
  env <- load_gtheory_weak_information_runner()
  objects <- gtheory_weak_information_runner_contract(env)
  execution <- env$mfrmr_gtwx_execute(
    objects$Runner, objects$Manifest, objects$Authorization,
    checkpoint_root = checkpoint_root, progress_every = 25L
  )
  resumed <- env$mfrmr_gtwx_execute(
    objects$Runner, objects$Manifest, objects$Authorization,
    checkpoint_root = checkpoint_root, progress_every = 100L
  )

  expect_s3_class(execution, "mfrmr_gtwx_execution")
  expect_equal(nrow(execution$AtomicRows), 3000L)
  expect_equal(length(execution$DatasetMarkerHashes), 750L)
  expect_true(execution$ExactAccountingPassed)
  expect_true(execution$FeasibilityEvidenceReady)
  expect_identical(resumed$ExecutionHash, execution$ExecutionHash)
  expect_equal(resumed$CheckpointReuseCount, 3000L)
  expect_equal(resumed$ComputedRouteCount, 0L)
  expect_equal(nrow(resumed$ThresholdFreeSummaries$Availability), 120L)
  expect_true(all(
    resumed$ThresholdFreeSummaries$Availability$PlannedN == 25L
  ))
  expect_false(resumed$ThresholdFreeSummaries$ThresholdSelected)
  expect_false(resumed$ThresholdFrozen)
  expect_false(resumed$ConfirmationAuthorized)
  expect_false(resumed$InferenceReady)
  expect_false(resumed$DecisionReady)

  result_path <- Sys.getenv("MFRMR_GTHEORY_FEASIBILITY_RESULT_PATH")
  if (nzchar(result_path)) saveRDS(resumed, result_path, version = 3L)
})
