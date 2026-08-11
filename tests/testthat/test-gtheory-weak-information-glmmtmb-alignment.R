gtheory_glmmtmb_alignment_paths <- function() {
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
      "gtheory-weak-information-glmmtmb-stabilization-runner-0.2.3.R",
      "gtheory-weak-information-glmmtmb-alignment-runner-0.2.3.R"
    )
  )
}

load_gtheory_glmmtmb_alignment <- function() {
  paths <- gtheory_glmmtmb_alignment_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  for (package in c(
    "digest", "lme4", "glmmTMB", "TMB", "minqa", "nloptr", "numDeriv"
  )) skip_if_not_installed(package)
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtheory_glmmtmb_alignment_design_fixture <- function(env) {
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
  contract <- env$mfrmr_gtwst_contract(numerical, typed)
  list(
    Contract = contract,
    Manifest = env$mfrmr_gtwst_manifest(contract, numerical)
  )
}

gtheory_glmmtmb_alignment_upstream_fixture <- function(design) {
  rows <- design$Manifest$Rows
  rows <- rows[
    rows$Replicate == 101L &
      rows$VarianceId %in% c("exact_zero", "reference_1200"),
    , drop = FALSE
  ]
  profile_order <- match(rows$ProfileId, design$Contract$Profiles$ProfileId)
  rows <- rows[order(
    rows$DatasetId, rows$MethodId, rows$ExecutionOrder, profile_order,
    method = "radix"
  ), , drop = FALSE]
  atomic <- data.frame(
    StabilizationRouteId = rows$StabilizationRouteId,
    PairReturned = seq_len(120L) <= 116L,
    FullReturned = seq_len(120L) <= 117L,
    ReducedReturned = seq_len(120L) <= 119L,
    StabilizationState = ifelse(
      seq_len(120L) <= 116L, "returned_diagnostic_complete",
      "full_fit_failure"
    ),
    RawLikelihoodDrop = c(seq_len(116L), rep(NA_real_, 4L)),
    FullTopLevelParameterHash = paste0("full-", seq_len(120L)),
    ReducedTopLevelParameterHash = paste0("reduced-", seq_len(120L)),
    stringsAsFactors = FALSE
  )
  structure(list(
    RunnerContractHash =
      "3ae866b7b7179917400e6c5e5b9dd3fcf01b6ff70c6fc914564b80836c83f192",
    ExecutionHash =
      "c743de38ec7d5ff6606c5b1df7960caea4bca149b470063e8496db83b5ab439d",
    ExactAccountingPassed = TRUE, PlannedPairs = 120L,
    PlannedBackendFits = 240L, PairReturnCount = 116L,
    AtomicRows = atomic, SmokeRunnerMechanicsReady = TRUE,
    FullExecutionAuthorized = FALSE, NumericalStabilizationReady = FALSE,
    NumericalSensitivityEvidenceReady = FALSE,
    CalibrationEvidenceReady = FALSE, ThresholdFrozen = FALSE,
    InferenceReady = FALSE, DecisionReady = FALSE
  ), class = "mfrmr_gtwsv_execution")
}

test_that("b1g2 contract preserves the full outcome-independent denominator", {
  env <- load_gtheory_glmmtmb_alignment()
  design <- gtheory_glmmtmb_alignment_design_fixture(env)
  upstream <- gtheory_glmmtmb_alignment_upstream_fixture(design)
  contract <- env$mfrmr_gtwsw_contract(
    design$Contract, design$Manifest, upstream
  )

  expect_s3_class(contract, "mfrmr_gtwsw_contract")
  expect_identical(
    contract$RunnerContractHash,
    "7632a74709576c78d4e89b9fd015952dbde5be98313b99ed380af7c5436e1177"
  )
  expect_equal(nrow(contract$SmokeIdentity), 120L)
  expect_true(contract$AlignmentAppliesToEveryReturnedFit)
  expect_identical(contract$AlignmentTolerance, "none")
  expect_false(contract$RandomModeMutationPermitted)
  expect_false(contract$OutcomeDependentSelection)
  expect_true(contract$AlignmentSmokeExecutionAuthorized)
  expect_false(contract$FullExecutionAuthorized)
  expect_false(contract$NumericalStabilizationReady)
  expect_false(contract$NumericalSensitivityEvidenceReady)
  expect_false(contract$InferenceReady)
  expect_false(contract$DecisionReady)

  changed <- upstream
  changed$PairReturnCount <- 117L
  expect_error(
    env$mfrmr_gtwsw_contract(design$Contract, design$Manifest, changed),
    "exact b1g1 negative-result"
  )
})

test_that("alignment overwrites only fixed coordinates without a tolerance", {
  env <- load_gtheory_glmmtmb_alignment()
  object_environment <- new.env(parent = emptyenv())
  object_environment$last.par.best <- c(1 + 1e-10, 2, 3)
  object_environment$lfixed <- function() c(TRUE, FALSE, TRUE)
  object_environment$parList <- function(x, par) {
    list(
      beta = x, betazi = numeric(), betadisp = numeric(),
      b = par[2L], bzi = numeric(), bdisp = numeric(),
      theta = numeric(), thetazi = numeric(), thetadisp = numeric(),
      psi = numeric()
    )
  }
  fit <- structure(list(
    obj = list(env = object_environment), fit = list(par = c(1, 3))
  ), class = "glmmTMB")

  signature <- env$mfrmr_gtwsw_extract_start(fit)
  expect_s3_class(signature, "mfrmr_gtwsw_start_signature")
  expect_false(signature$PreAlignmentFixedExact)
  expect_lt(
    abs(signature$PreAlignmentMaximumAbsoluteFixedDifference - 1e-10),
    1e-15
  )
  expect_true(signature$AlignmentApplied)
  expect_true(signature$AlignedFixedCoordinateExact)
  expect_true(signature$FixedCoordinateExact)
  expect_identical(signature$StartList$b, 2)
  expect_false(identical(
    signature$RawJointBestHash, signature$AlignedJointBestHash
  ))

  isolated <- env$mfrmr_gtwsw_runner_environment()
  empty <- isolated$mfrmr_gtwsv_empty_diagnostics()
  expect_named(empty, c(
    names(env$mfrmr_gtwsv_empty_diagnostics()),
    "RawJointBestHash", "AlignedJointBestHash",
    "PreAlignmentFixedExact",
    "PreAlignmentMaximumAbsoluteFixedDifference",
    "AlignmentApplied", "AlignedFixedCoordinateExact"
  ))
})

test_that("comparison keeps all 120 rows and fails closed", {
  env <- load_gtheory_glmmtmb_alignment()
  design <- gtheory_glmmtmb_alignment_design_fixture(env)
  upstream <- gtheory_glmmtmb_alignment_upstream_fixture(design)
  after <- upstream$AtomicRows
  after$PairReturned[117:118] <- TRUE
  after$FullReturned[118] <- TRUE
  after$ReducedReturned[120] <- TRUE
  after$StabilizationState[117:118] <- "returned_diagnostic_complete"
  aligned <- structure(list(
    UpstreamExecutionHash = upstream$ExecutionHash,
    ExecutionHash = "synthetic-alignment-execution",
    ExactAccountingPassed = TRUE, AtomicRows = after,
    AlignmentMechanicsReady = TRUE
  ), class = "mfrmr_gtwsw_execution")

  comparison <- env$mfrmr_gtwsw_compare(upstream, aligned)
  expect_s3_class(comparison, "mfrmr_gtwsw_comparison")
  expect_equal(comparison$Summary$ComparisonDenominator, 120L)
  expect_true(comparison$Summary$OrderedIdentityExact)
  expect_false(comparison$Summary$CompleteCaseSelectionUsed)
  expect_true(comparison$FullDenominatorComparisonReady)
  expect_false(comparison$FullExecutionAuthorized)
  expect_false(comparison$NumericalStabilizationReady)

  incomplete <- aligned
  incomplete$AtomicRows <- incomplete$AtomicRows[-1L, , drop = FALSE]
  expect_error(
    env$mfrmr_gtwsw_compare(upstream, incomplete),
    "full 120-row comparison denominator"
  )
})

test_that("exact b1g2 smoke and no-fit resume reproduce", {
  skip_if_not(identical(
    tolower(Sys.getenv("MFRMR_RUN_GTHEORY_GLMMTMB_ALIGNMENT_SMOKE", "false")),
    "true"
  ), "set MFRMR_RUN_GTHEORY_GLMMTMB_ALIGNMENT_SMOKE=true")
  env <- load_gtheory_glmmtmb_alignment()
  design_path <- Sys.getenv(
    "MFRMR_GTHEORY_GLMMTMB_STABILIZATION_DESIGN_RDS",
    "/private/tmp/mfrmr-gtwst-design-v2.rds"
  )
  upstream_path <- Sys.getenv(
    "MFRMR_GTHEORY_GLMMTMB_STABILIZATION_SMOKE_RDS",
    "/private/tmp/mfrmr-gtwsv-smoke-v2.rds"
  )
  execution_path <- Sys.getenv(
    "MFRMR_GTHEORY_GLMMTMB_ALIGNMENT_SMOKE_RDS",
    "/private/tmp/mfrmr-gtwsw-smoke-v1.rds"
  )
  checkpoint_root <- Sys.getenv(
    "MFRMR_GTHEORY_GLMMTMB_ALIGNMENT_CHECKPOINT_ROOT",
    "/private/tmp/mfrmr-gtwsw-7632a747"
  )
  skip_if_not(all(file.exists(c(
    design_path, upstream_path, execution_path
  ))), "exact design, upstream, or alignment smoke is unavailable")
  design <- readRDS(design_path)
  upstream <- readRDS(upstream_path)
  execution <- readRDS(execution_path)
  contract <- env$mfrmr_gtwsw_contract(
    design$Contract, design$Manifest, upstream
  )

  expect_identical(contract$RunnerContractHash,
                   execution$RunnerContractHash)
  expect_identical(
    execution$ExecutionHash,
    "e2716a4ae71784e218d15f2509ed8c15326c1b7c6bc9acf78826a81822581482"
  )
  expect_true(execution$ExactAccountingPassed)
  expect_true(execution$AlignmentMechanicsReady)
  expect_equal(execution$PlannedPairs, 120L)
  expect_equal(execution$PlannedBackendFits, 240L)
  expect_equal(execution$PairReturnCount, 120L)
  expect_equal(execution$AlignmentSummary$FullPreAlignmentMismatchCount, 1L)
  expect_equal(
    execution$AlignmentSummary$ReducedPreAlignmentMismatchCount, 1L
  )
  expect_equal(execution$AlignmentSummary$FullAlignedExactCount, 120L)
  expect_equal(execution$AlignmentSummary$ReducedAlignedExactCount, 120L)
  expect_equal(unname(execution$Summaries$StateCounts[
    "nonfinite_objective_or_likelihood"
  ]), 14L)
  expect_equal(unname(execution$Summaries$StateCounts[
    "finite_material_negative_drop"
  ]), 21L)
  expect_equal(unname(execution$Summaries$StateCounts[
    "returned_diagnostic_complete"
  ]), 85L)
  expect_equal(execution$CheckpointReuseCount, 0L)
  expect_equal(execution$ComputedBaseRouteCount, 20L)
  expect_false(execution$FullExecutionAuthorized)
  expect_false(execution$NumericalStabilizationReady)
  expect_false(execution$DecisionReady)

  comparison <- env$mfrmr_gtwsw_compare(upstream, execution)
  expect_identical(
    comparison$ComparisonHash,
    "651b6f07cb7977b7d1245b1048e0b7b905c4999f8da43bfbcd30180d9581d435"
  )
  expect_equal(comparison$Summary$ComparisonDenominator, 120L)
  expect_equal(comparison$Summary$PairReturnRecoveredCount, 4L)
  expect_equal(comparison$Summary$PairReturnLostCount, 0L)
  expect_equal(comparison$Summary$StabilizationStateChangedCount, 4L)
  expect_equal(comparison$Summary$TypedLikelihoodDropMismatchCount, 1L)
  expect_equal(comparison$Summary$FullTopLevelHashMismatchCount, 0L)
  expect_equal(comparison$Summary$ReducedTopLevelHashMismatchCount, 0L)
  expect_true(comparison$FullDenominatorComparisonReady)
  expect_false(comparison$FullExecutionAuthorized)

  resumed <- env$mfrmr_gtwsw_execute(
    contract, design$Manifest, checkpoint_root, progress_every = 0L
  )
  expect_identical(resumed$ExecutionHash, execution$ExecutionHash)
  expect_identical(resumed$AtomicRows, execution$AtomicRows)
  expect_equal(resumed$CheckpointReuseCount, 20L)
  expect_equal(resumed$ComputedBaseRouteCount, 0L)
})
