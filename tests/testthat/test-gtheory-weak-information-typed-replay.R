gtheory_weak_information_typed_replay_paths <- function() {
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
      "gtheory-weak-information-typed-replay-0.2.3.R"
    )
  )
}

load_gtheory_weak_information_typed_replay <- function() {
  paths <- gtheory_weak_information_typed_replay_paths()
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

gtheory_weak_information_typed_replay_objects <- function(env) {
  feasibility_contract <- env$mfrmr_gtwf_contract()
  baseline <- env$mfrmr_gtwf_manifest(feasibility_contract)$Rows
  baseline$RawLikelihoodDrop <- 3 * baseline$TargetVariance
  baseline$PairReturned <- TRUE
  baseline$LikelihoodDiagnosticAvailable <- TRUE
  baseline$NegativeDropWithinTolerance <- TRUE
  baseline$ComparisonState <- "available_raw_boundary_diagnostic"
  baseline$RawLikelihoodDrop[seq_len(7L)] <- NA_real_
  baseline$LikelihoodDiagnosticAvailable[seq_len(7L)] <- FALSE
  baseline$NegativeDropWithinTolerance[seq_len(7L)] <- FALSE
  baseline$ComparisonState[seq_len(7L)] <-
    "not_evaluable_fit_or_identity_failure"
  feasibility <- structure(list(
    RunnerContractHash =
      "c97b5d08c29e7a7537fe4669f938de9e978b4bb651596007af0b7ea7b9378df7",
    ExecutionHash =
      "04ec60ab6d4351c0d8c6416543fa8ac46e15585bbe85680f829b341beb34a22b",
    ExactAccountingPassed = TRUE,
    FeasibilityEvidenceReady = TRUE,
    AtomicRows = baseline,
    ThresholdFrozen = FALSE, InferenceReady = FALSE, DecisionReady = FALSE
  ), class = "mfrmr_gtwx_execution")

  numerical_contract <- env$mfrmr_gtwy_contract(feasibility)
  numerical <- env$mfrmr_gtwy_manifest(numerical_contract)$Rows
  match_index <- match(numerical$RouteId, baseline$RouteId)
  numerical$RawLikelihoodDrop <- baseline$RawLikelihoodDrop[match_index]
  numerical$PairReturned <- baseline$PairReturned[match_index]
  numerical$LikelihoodDiagnosticAvailable <-
    baseline$LikelihoodDiagnosticAvailable[match_index]
  numerical$NegativeDropWithinTolerance <-
    baseline$NegativeDropWithinTolerance[match_index]
  numerical$ComparisonState <- baseline$ComparisonState[match_index]
  numerical_execution <- structure(list(
    NumericalSensitivityContractHash =
      "0538eb1a7636d4d784f06c10bb17f65aa958f4e677005462d6309827292083c6",
    NumericalSensitivityManifestHash =
      "53880242ed7441c93516defbd840c289df32bbc6d0677e4b441bc2543eda8d2f",
    FeasibilityExecutionHash = feasibility$ExecutionHash,
    ExecutionHash =
      "37be0b4dbac852454ced612b5f84706678f688f3f3ea7209793111ab6a706d94",
    ExactAccountingPassed = TRUE, DefaultReplayPassed = FALSE,
    NumericalSensitivityEvidenceReady = FALSE,
    AtomicRows = numerical,
    CalibrationEvidenceReady = FALSE, ThresholdFrozen = FALSE,
    InferenceReady = FALSE, DecisionReady = FALSE
  ), class = "mfrmr_gtwy_execution")
  list(Feasibility = feasibility, Numerical = numerical_execution)
}

test_that("Draft.83d2b2b1f freezes a typed viewed-ledger contract", {
  env <- load_gtheory_weak_information_typed_replay()
  objects <- gtheory_weak_information_typed_replay_objects(env)
  contract <- env$mfrmr_gtwz_contract(
    objects$Feasibility, objects$Numerical
  )

  expect_s3_class(contract, "mfrmr_gtwz_contract")
  expect_equal(contract$OriginalRouteCount, 3000L)
  expect_equal(contract$FiniteReplayTolerance, 1e-10)
  expect_equal(contract$MaterialNegativeTolerance, 1e-6)
  expect_setequal(contract$ReplayStates, c(
    "finite_match", "same_typed_nonfinite_state", "finite_mismatch",
    "nonfinite_state_mismatch", "finite_nonfinite_mismatch"
  ))
  expect_setequal(contract$NonFiniteKinds, c(
    "NA_real", "NaN", "positive_infinity", "negative_infinity",
    "other_nonfinite"
  ))
  expect_false(contract$GeneratorCallPermitted)
  expect_false(contract$PreFitCallPermitted)
  expect_false(contract$BackendFitPermitted)
  expect_false(contract$OptimizerCallPermitted)
  expect_false(contract$BootstrapPermitted)
  expect_false(contract$CalibrationDataGenerationPermitted)
  expect_false(contract$ThresholdSelectionPermitted)
  expect_false(contract$NumericalSensitivityEvidenceReady)
  expect_false(contract$DecisionReady)
  expect_true(all(grepl("^https://", contract$Sources$Locator)))
  expect_true(any(grepl("troubleshooting", contract$Sources$Locator)))
  expect_true(any(grepl("reference/glmmTMB", contract$Sources$Locator)))
  expect_true(any(grepl("reference/diagnose", contract$Sources$Locator)))
})

test_that("typed non-finite kinds and all five replay states stay distinct", {
  env <- load_gtheory_weak_information_typed_replay()
  objects <- gtheory_weak_information_typed_replay_objects(env)
  contract <- env$mfrmr_gtwz_contract(
    objects$Feasibility, objects$Numerical
  )
  baseline <- objects$Feasibility$AtomicRows[8L, , drop = FALSE]
  default <- objects$Numerical$AtomicRows[
    objects$Numerical$AtomicRows$IsDefault &
      objects$Numerical$AtomicRows$RouteId == baseline$RouteId,
    , drop = FALSE
  ]
  compare <- function(x, y, change_state = FALSE) {
    baseline$RawLikelihoodDrop <- x
    default$RawLikelihoodDrop <- y
    default$ComparisonState <- baseline$ComparisonState
    if (change_state) default$ComparisonState <- "changed_state"
    env$mfrmr_gtwz_compare_row(baseline, default, contract)$ReplayState
  }

  expect_identical(env$mfrmr_gtwz_nonfinite_kind(NA_real_), "NA_real")
  expect_identical(env$mfrmr_gtwz_nonfinite_kind(NaN), "NaN")
  expect_identical(env$mfrmr_gtwz_nonfinite_kind(Inf), "positive_infinity")
  expect_identical(env$mfrmr_gtwz_nonfinite_kind(-Inf), "negative_infinity")
  expect_identical(env$mfrmr_gtwz_nonfinite_kind(0), "finite")
  expect_error(env$mfrmr_gtwz_nonfinite_kind(c(NA_real_, NA_real_)),
               "one numeric value")
  expect_identical(compare(1, 1 + 1e-11), "finite_match")
  expect_identical(compare(1, 1 + 1e-8), "finite_mismatch")
  expect_identical(compare(NA_real_, NA_real_),
                   "same_typed_nonfinite_state")
  expect_identical(compare(NA_real_, NaN), "nonfinite_state_mismatch")
  expect_identical(compare(NA_real_, NA_real_, TRUE),
                   "nonfinite_state_mismatch")
  expect_identical(compare(1, NA_real_), "finite_nonfinite_mismatch")
})

test_that("typed replay closes only the missing state definition", {
  env <- load_gtheory_weak_information_typed_replay()
  objects <- gtheory_weak_information_typed_replay_objects(env)
  contract <- env$mfrmr_gtwz_contract(
    objects$Feasibility, objects$Numerical
  )
  result <- env$mfrmr_gtwz_adjudicate(
    contract, objects$Feasibility, objects$Numerical
  )

  expect_s3_class(result, "mfrmr_gtwz_adjudication")
  expect_true(result$ExactAccountingPassed)
  expect_equal(result$PlannedRows, 3000L)
  expect_equal(result$FiniteMatchCount, 2993L)
  expect_equal(result$SameTypedNonFiniteStateCount, 7L)
  expect_equal(result$MismatchCount, 0L)
  expect_equal(result$NonFinitePromotedToAvailableCount, 0L)
  expect_true(result$TypedReplayAdjudicationReady)
  expect_false(result$B1eDefaultReplayPassed)
  expect_false(result$NumericalStabilizationReady)
  expect_false(result$NumericalSensitivityEvidenceReady)
  expect_false(result$CalibrationEvidenceReady)
  expect_false(result$ThresholdFrozen)
  expect_false(result$InferenceReady)
  expect_false(result$DecisionReady)

  tampered <- objects$Numerical
  default_index <- which(tampered$AtomicRows$IsDefault)[1L]
  tampered$AtomicRows$RawLikelihoodDrop[default_index] <- 0
  tampered_result <- env$mfrmr_gtwz_adjudicate(
    contract, objects$Feasibility, tampered
  )
  expect_equal(tampered_result$MismatchCount, 1L)
  expect_false(tampered_result$TypedReplayAdjudicationReady)
})

test_that("exact b1d/b1e ledgers reproduce the frozen typed adjudication", {
  skip_if_not(identical(
    tolower(Sys.getenv("MFRMR_RUN_GTHEORY_TYPED_REPLAY_FULL", "false")),
    "true"
  ), "set MFRMR_RUN_GTHEORY_TYPED_REPLAY_FULL=true for exact-ledger replay")
  env <- load_gtheory_weak_information_typed_replay()
  feasibility_path <- Sys.getenv(
    "MFRMR_GTHEORY_FEASIBILITY_EXECUTION_RDS",
    "/private/tmp/mfrmr-gtwx-execution.rds"
  )
  numerical_path <- Sys.getenv(
    "MFRMR_GTHEORY_NUMERICAL_EXECUTION_RDS",
    "/private/tmp/mfrmr-gtwy-execution-v2.rds"
  )
  skip_if_not(file.exists(feasibility_path) && file.exists(numerical_path),
              "exact b1d/b1e ledgers are unavailable")
  feasibility <- readRDS(feasibility_path)
  numerical <- readRDS(numerical_path)
  contract <- env$mfrmr_gtwz_contract(feasibility, numerical)
  result <- env$mfrmr_gtwz_adjudicate(contract, feasibility, numerical)

  expect_identical(
    contract$ContractHash,
    "8a18d59548ab5d8523e29f7089d2ea70620f51b38e2444e133a2e78974ff0d4a"
  )
  expect_identical(
    result$ResultHash,
    "e200a9ee7984bbc3be32ab5ef209ce2eb26c0b42c8df3ad758bab7baf559f8c1"
  )
  expect_equal(result$FiniteMatchCount, 2993L)
  expect_equal(result$SameTypedNonFiniteStateCount, 7L)
  expect_equal(result$MismatchCount, 0L)
  expect_true(result$TypedReplayAdjudicationReady)
  expect_false(result$NumericalSensitivityEvidenceReady)
})
