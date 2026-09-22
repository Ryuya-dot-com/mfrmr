gtheory_glmmtmb_stabilization_runner_paths <- function() {
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
      "gtheory-weak-information-numerical-sensitivity-0.2.3.R",
      "gtheory-weak-information-typed-replay-0.2.3.R",
      "gtheory-weak-information-glmmtmb-stabilization-prototype-0.2.3.R",
      "gtheory-weak-information-glmmtmb-stabilization-runner-0.2.3.R"
    )
  )
}

load_gtheory_glmmtmb_stabilization_runner <- function() {
  paths <- gtheory_glmmtmb_stabilization_runner_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  for (package in c(
    "digest", "lme4", "glmmTMB", "TMB", "minqa", "nloptr", "numDeriv"
  )) skip_if_not_installed(package)
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtheory_glmmtmb_stabilization_exact_design_fixture <- function(env) {
  feasibility_contract <- env$mfrmr_gtwf_contract()
  feasibility_rows <- env$mfrmr_gtwf_manifest(feasibility_contract)$Rows
  feasibility <- structure(list(
    RunnerContractHash =
      "c97b5d08c29e7a7537fe4669f938de9e978b4bb651596007af0b7ea7b9378df7",
    ExecutionHash =
      "04ec60ab6d4351c0d8c6416543fa8ac46e15585bbe85680f829b341beb34a22b",
    ExactAccountingPassed = TRUE, FeasibilityEvidenceReady = TRUE,
    AtomicRows = feasibility_rows, ThresholdFrozen = FALSE,
    InferenceReady = FALSE, DecisionReady = FALSE
  ), class = "mfrmr_gtwx_execution")
  numerical_contract <- env$mfrmr_gtwy_contract(feasibility)
  numerical_rows <- env$mfrmr_gtwy_manifest(numerical_contract)$Rows
  numerical <- structure(list(
    NumericalSensitivityContractHash =
      "0538eb1a7636d4d784f06c10bb17f65aa958f4e677005462d6309827292083c6",
    NumericalSensitivityManifestHash =
      "53880242ed7441c93516defbd840c289df32bbc6d0677e4b441bc2543eda8d2f",
    FeasibilityExecutionHash = feasibility$ExecutionHash,
    ExecutionHash =
      "37be0b4dbac852454ced612b5f84706678f688f3f3ea7209793111ab6a706d94",
    ExactAccountingPassed = TRUE, DefaultReplayPassed = FALSE,
    NumericalSensitivityEvidenceReady = FALSE,
    AtomicRows = numerical_rows, CalibrationEvidenceReady = FALSE,
    ThresholdFrozen = FALSE, InferenceReady = FALSE, DecisionReady = FALSE
  ), class = "mfrmr_gtwy_execution")
  typed <- structure(list(
    TypedReplayContractHash =
      "8a18d59548ab5d8523e29f7089d2ea70620f51b38e2444e133a2e78974ff0d4a",
    NumericalSensitivityExecutionHash = numerical$ExecutionHash,
    ResultHash =
      "e200a9ee7984bbc3be32ab5ef209ce2eb26c0b42c8df3ad758bab7baf559f8c1",
    ExactAccountingPassed = TRUE, PlannedRows = 3000L,
    FiniteMatchCount = 2993L, SameTypedNonFiniteStateCount = 7L,
    MismatchCount = 0L, NonFinitePromotedToAvailableCount = 0L,
    TypedReplayAdjudicationReady = TRUE, B1eDefaultReplayPassed = FALSE,
    NumericalStabilizationReady = FALSE,
    NumericalSensitivityEvidenceReady = FALSE,
    CalibrationEvidenceReady = FALSE, ThresholdFrozen = FALSE,
    InferenceReady = FALSE, DecisionReady = FALSE
  ), class = "mfrmr_gtwz_adjudication")
  design_contract <- env$mfrmr_gtwst_contract(numerical, typed)
  design_manifest <- env$mfrmr_gtwst_manifest(design_contract, numerical)
  list(Contract = design_contract, Manifest = design_manifest)
}

test_that("Draft.83d2b2b1g1 authorizes only the factor-selected smoke", {
  env <- load_gtheory_glmmtmb_stabilization_runner()
  design <- gtheory_glmmtmb_stabilization_exact_design_fixture(env)
  contract <- env$mfrmr_gtwsv_contract(design$Contract, design$Manifest)
  smoke <- contract$SmokeIdentity

  expect_s3_class(contract, "mfrmr_gtwsv_contract")
  expect_identical(
    contract$RunnerContractHash,
    "3ae866b7b7179917400e6c5e5b9dd3fcf01b6ff70c6fc914564b80836c83f192"
  )
  expect_equal(nrow(smoke), 120L)
  expect_equal(length(unique(smoke$RouteId)), 20L)
  expect_equal(length(unique(smoke$DatasetId)), 10L)
  expect_equal(as.integer(table(smoke$ProfileId)), rep(20L, 6L))
  expect_setequal(smoke$DesignId, c(
    "baseline_complete", "few_levels_complete", "high_information",
    "imbalanced_hub", "sparse_connected"
  ))
  expect_setequal(smoke$VarianceId, c("exact_zero", "reference_1200"))
  expect_setequal(smoke$Likelihood, c("ML", "REML"))
  expect_true(contract$RunnerImplemented)
  expect_true(contract$SmokeExecutionAuthorized)
  expect_false(contract$FullExecutionAuthorized)
  expect_false(contract$SmokeSelection$OutcomeDependentSelection)
  expect_false(contract$EarlyStoppingPermitted)
  expect_false(contract$AdaptiveFallbackPermitted)
  expect_false(contract$CalibrationDataGenerationPermitted)
  expect_false(contract$ThresholdSelectionPermitted)
  expect_false(contract$BootstrapPermitted)
  expect_false(contract$NumericalStabilizationReady)
  expect_false(contract$NumericalSensitivityEvidenceReady)
  expect_false(contract$DecisionReady)
})

test_that("gradient and mutually exclusive state helpers fail closed", {
  env <- load_gtheory_glmmtmb_stabilization_runner()
  gradient <- env$mfrmr_gtwsv_gradient_summary(c(-3, 4))
  expect_true(gradient$Available)
  expect_equal(gradient$MaximumAbsolute, 4)
  expect_equal(gradient$L2Norm, 5)
  expect_false(env$mfrmr_gtwsv_gradient_summary(c(1, NA_real_))$Available)

  diagnostic <- env$mfrmr_gtwsv_empty_diagnostics()
  diagnostic$Objective <- 10
  diagnostic$LogLikelihood <- -10
  diagnostic$OptimizerCode <- 0L
  diagnostic$OuterGradientAvailable <- TRUE
  diagnostic$SdGradientAvailable <- TRUE
  diagnostic$RichardsonAvailable <- TRUE
  diagnostic$SdreportPositiveDefiniteHessian <- TRUE
  diagnostic$RichardsonPositiveDefinite <- TRUE
  fit <- list(Returned = TRUE, FailureStage = "none",
              Diagnostics = diagnostic)
  state <- function(full = fit, reduced = fit, same = TRUE, df = 1L,
                    drop = 0) {
    env$mfrmr_gtwsv_pair_state(full, reduced, same, df, drop)
  }
  expect_identical(state(), "returned_diagnostic_complete")
  expect_identical(state(drop = -2e-6), "finite_material_negative_drop")
  expect_identical(state(same = FALSE), "likelihood_identity_failure")
  bad_hessian <- fit
  bad_hessian$Diagnostics$RichardsonPositiveDefinite <- FALSE
  expect_identical(state(full = bad_hessian), "nonpositive_hessian")
  bad_gradient <- fit
  bad_gradient$Diagnostics$OuterGradientAvailable <- FALSE
  expect_identical(state(full = bad_gradient), "gradient_unavailable")
  bad_optimizer <- fit
  bad_optimizer$Diagnostics$OptimizerCode <- 1L
  expect_identical(state(full = bad_optimizer), "optimizer_nonzero")
  failed <- fit
  failed$Returned <- FALSE
  failed$FailureStage <- "full_fit_failure"
  expect_identical(state(full = failed), "full_fit_failure")
  parent <- failed
  parent$FailureStage <- "parent_fit_or_start_unavailable"
  expect_identical(state(full = parent),
                   "parent_fit_or_start_unavailable")
})

test_that("base-route checkpoints and dataset markers reject mutation", {
  env <- load_gtheory_glmmtmb_stabilization_runner()
  design <- gtheory_glmmtmb_stabilization_exact_design_fixture(env)
  contract <- env$mfrmr_gtwsv_contract(design$Contract, design$Manifest)
  smoke <- env$mfrmr_gtwsv_smoke_rows(design$Contract, design$Manifest)
  dataset <- smoke[smoke$DatasetId == smoke$DatasetId[[1L]], , drop = FALSE]
  route_ids <- unique(dataset$RouteId)
  checkpoints <- lapply(route_ids, function(route_id) {
    routes <- dataset[dataset$RouteId == route_id, , drop = FALSE]
    atomic <- data.frame(
      StabilizationRouteId = routes$StabilizationRouteId,
      stringsAsFactors = FALSE
    )
    env$mfrmr_gtwsv_checkpoint(contract, routes, NULL, NULL, atomic)
  })
  routes1 <- dataset[dataset$RouteId == route_ids[[1L]], , drop = FALSE]
  valid <- env$mfrmr_gtwsv_validate_checkpoint(
    checkpoints[[1L]], contract, routes1
  )
  expect_true(valid$Valid)
  tampered <- checkpoints[[1L]]
  tampered$Identity$AtomicRows$StabilizationRouteId[[1L]] <- "changed"
  expect_false(env$mfrmr_gtwsv_validate_checkpoint(
    tampered, contract, routes1
  )$Valid)
  marker <- env$mfrmr_gtwsv_marker(
    contract, dataset$DatasetId[[1L]], checkpoints
  )
  expect_true(env$mfrmr_gtwsv_validate_marker(
    marker, contract, dataset$DatasetId[[1L]], checkpoints
  ))
  marker$Identity$PairRowCount <- 11L
  expect_false(env$mfrmr_gtwsv_validate_marker(
    marker, contract, dataset$DatasetId[[1L]], checkpoints
  ))
})

test_that("exact covering smoke and no-fit resume reproduce", {
  skip_if_not(identical(
    tolower(Sys.getenv("MFRMR_RUN_GTHEORY_GLMMTMB_STABILIZATION_SMOKE",
                       "false")), "true"
  ), "set MFRMR_RUN_GTHEORY_GLMMTMB_STABILIZATION_SMOKE=true")
  env <- load_gtheory_glmmtmb_stabilization_runner()
  design_path <- Sys.getenv(
    "MFRMR_GTHEORY_GLMMTMB_STABILIZATION_DESIGN_RDS",
    "/private/tmp/mfrmr-gtwst-design-v2.rds"
  )
  execution_path <- Sys.getenv(
    "MFRMR_GTHEORY_GLMMTMB_STABILIZATION_SMOKE_RDS",
    "/private/tmp/mfrmr-gtwsv-smoke-v2.rds"
  )
  checkpoint_root <- Sys.getenv(
    "MFRMR_GTHEORY_GLMMTMB_STABILIZATION_CHECKPOINT_ROOT",
    "/private/tmp/mfrmr-gtwsv-3ae866b7"
  )
  skip_if_not(file.exists(design_path) && file.exists(execution_path),
              "exact design or smoke execution is unavailable")
  design <- readRDS(design_path)
  execution <- readRDS(execution_path)
  contract <- env$mfrmr_gtwsv_contract(design$Contract, design$Manifest)

  expect_identical(contract$RunnerContractHash,
                   execution$RunnerContractHash)
  expect_identical(
    execution$ExecutionHash,
    "c743de38ec7d5ff6606c5b1df7960caea4bca149b470063e8496db83b5ab439d"
  )
  expect_true(execution$ExactAccountingPassed)
  expect_equal(execution$PlannedPairs, 120L)
  expect_equal(execution$PlannedBackendFits, 240L)
  expect_equal(execution$PairReturnCount, 116L)
  expect_equal(unname(execution$Summaries$StateCounts[
    "returned_diagnostic_complete"
  ]), 84L)
  expect_equal(unname(execution$Summaries$StateCounts[
    "finite_material_negative_drop"
  ]), 21L)
  expect_equal(unname(execution$Summaries$StateCounts[
    "nonfinite_objective_or_likelihood"
  ]), 11L)
  expect_equal(unname(execution$Summaries$StateCounts[
    "parent_fit_or_start_unavailable"
  ]), 2L)
  expect_equal(sum(execution$AtomicRows$FullReturned &
                     execution$AtomicRows$FullFixedCoordinateExact), 117L)
  expect_equal(sum(execution$AtomicRows$ReducedReturned &
                     execution$AtomicRows$ReducedFixedCoordinateExact), 119L)
  dependent <- execution$AtomicRows$ParentProfileId != "none"
  expect_true(all(
    execution$AtomicRows$FullInputStartSignatureHash[
      dependent & execution$AtomicRows$FullReturned
    ] == execution$AtomicRows$FullParentFinalStartSignatureHash[
      dependent & execution$AtomicRows$FullReturned
    ]
  ))
  expect_true(execution$SmokeRunnerMechanicsReady)
  expect_false(execution$FullExecutionAuthorized)
  expect_false(execution$NumericalStabilizationReady)
  expect_false(execution$NumericalSensitivityEvidenceReady)
  expect_false(execution$DecisionReady)

  resumed <- env$mfrmr_gtwsv_execute(
    contract, design$Manifest, checkpoint_root, progress_every = 0L
  )
  expect_identical(resumed$ExecutionHash, execution$ExecutionHash)
  expect_identical(resumed$AtomicRows, execution$AtomicRows)
  expect_equal(resumed$CheckpointReuseCount, 20L)
  expect_equal(resumed$ComputedBaseRouteCount, 0L)
})
