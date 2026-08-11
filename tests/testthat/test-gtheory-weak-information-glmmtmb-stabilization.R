gtheory_weak_information_glmmtmb_stabilization_paths <- function() {
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
      "gtheory-weak-information-glmmtmb-stabilization-prototype-0.2.3.R"
    )
  )
}

load_gtheory_weak_information_glmmtmb_stabilization <- function() {
  paths <- gtheory_weak_information_glmmtmb_stabilization_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  for (package in c(
    "digest", "lme4", "glmmTMB", "TMB", "minqa", "nloptr", "numDeriv"
  )) {
    skip_if_not_installed(package)
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtheory_glmmtmb_stabilization_fixture <- function() {
  datasets <- sprintf("GT-STAB-D%04d", seq_len(750L))
  methods <- c("glmmTMB_ml", "glmmTMB_reml")
  base <- expand.grid(
    DatasetId = datasets, MethodId = methods,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  base$ScenarioId <- paste0("GT-STAB-", base$DatasetId)
  base$Replicate <- as.integer(sub(".*D", "", base$DatasetId))
  base$Seed <- base$Replicate
  base$RouteId <- paste(base$DatasetId, base$MethodId, sep = "::")
  base$Backend <- "glmmTMB"
  base$Likelihood <- ifelse(grepl("_reml$", base$MethodId), "REML", "ML")
  base$DesignId <- "fixture_design"
  base$VarianceId <- "fixture_variance"
  base$TargetVariance <- 0.1
  base$TruthRegion <- "fixture"
  base$EvaluationRole <- "viewed_fixture"
  base$RegistryHash <- "fixture_registry"
  base$FeasibilityContractHash <- "fixture_feasibility"
  profiles <- c("default", "tight", "alternative")
  glmm <- do.call(rbind, lapply(profiles, function(profile) {
    x <- base
    x$IsDefault <- profile == "default"
    x$SensitivityRouteId <- paste(x$RouteId, profile, sep = "::")
    x
  }))
  lme <- glmm
  lme$Backend <- "lme4"
  lme$MethodId <- sub("glmmTMB", "lme4", lme$MethodId, fixed = TRUE)
  lme$RouteId <- paste(lme$DatasetId, lme$MethodId, sep = "::")
  lme$SensitivityRouteId <- paste(
    lme$RouteId, rep(profiles, each = nrow(base)), sep = "::"
  )
  rows <- rbind(glmm, lme)
  row.names(rows) <- NULL
  numerical <- structure(list(
    NumericalSensitivityContractHash =
      "0538eb1a7636d4d784f06c10bb17f65aa958f4e677005462d6309827292083c6",
    NumericalSensitivityManifestHash =
      "53880242ed7441c93516defbd840c289df32bbc6d0677e4b441bc2543eda8d2f",
    FeasibilityExecutionHash =
      "04ec60ab6d4351c0d8c6416543fa8ac46e15585bbe85680f829b341beb34a22b",
    ExecutionHash =
      "37be0b4dbac852454ced612b5f84706678f688f3f3ea7209793111ab6a706d94",
    ExactAccountingPassed = TRUE, DefaultReplayPassed = FALSE,
    NumericalSensitivityEvidenceReady = FALSE, AtomicRows = rows,
    CalibrationEvidenceReady = FALSE, ThresholdFrozen = FALSE,
    InferenceReady = FALSE, DecisionReady = FALSE
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
  list(Numerical = numerical, Typed = typed)
}

test_that("Draft.83d2b2b1g freezes a symmetric non-adaptive profile DAG", {
  env <- load_gtheory_weak_information_glmmtmb_stabilization()
  objects <- gtheory_glmmtmb_stabilization_fixture()
  contract <- env$mfrmr_gtwst_contract(objects$Numerical, objects$Typed)
  profiles <- contract$Profiles

  expect_s3_class(contract, "mfrmr_gtwst_contract")
  expect_true(env$mfrmr_gtwst_validate_profile_graph(profiles))
  expect_equal(nrow(profiles), 6L)
  expect_equal(sum(profiles$IsColdRoot), 2L)
  expect_equal(as.integer(table(profiles$Algorithm)), c(3L, 3L))
  expect_equal(as.integer(table(profiles$LineageRole)), c(2L, 2L, 2L))
  expect_true(all(profiles$ExecutionOrder[profiles$IsColdRoot] == 1L))
  expect_true(all(profiles$ExecutionOrder[!profiles$IsColdRoot] == 2L))
  expect_false(contract$BareParListCallPermitted)
  expect_true(contract$JointBestSnapshotRequired)
  expect_true(contract$FixedCoordinateEqualityRequired)
  expect_true(contract$SameModelRoleTransferRequired)
  expect_false(contract$CrossRouteTransferPermitted)
  expect_false(contract$FullReducedTransferPermitted)
  expect_false(contract$AdaptiveFallbackPermitted)
  expect_identical(
    contract$ParentFailurePolicy,
    "typed_dependency_failure_retained_in_denominator"
  )
  expect_equal(contract$PlannedPairs, 9000L)
  expect_equal(contract$PlannedBackendFits, 18000L)
  expect_false(contract$GradientEligibilityThresholdSelected)
  expect_false(contract$HessianEligibilityThresholdSelected)
  expect_false(contract$ObjectiveEligibilityThresholdSelected)
  expect_false(contract$DiagnoseDefinesEligibility)
  expect_false(contract$StabilizationRunnerImplemented)
  expect_false(contract$StabilizationExecutionAuthorized)
  expect_false(contract$NumericalStabilizationReady)
  expect_false(contract$NumericalSensitivityEvidenceReady)
  expect_false(contract$CalibrationEvidenceReady)
  expect_false(contract$ThresholdFrozen)
  expect_false(contract$DecisionReady)
  expect_true(all(grepl("^https://", contract$Sources$Locator)))
})

test_that("all ten glmmTMB start blocks have canonical finite identity", {
  env <- load_gtheory_weak_information_glmmtmb_stabilization()
  blocks <- env$mfrmr_gtwst_start_blocks()
  values <- stats::setNames(lapply(seq_len(nrow(blocks)), function(index) {
    if (index %% 3L == 0L) numeric() else c(index / 10, -index / 10)
  }), blocks$BlockName)
  signature <- env$mfrmr_gtwst_start_signature(values)
  permuted <- env$mfrmr_gtwst_start_signature(rev(values))

  expect_s3_class(signature, "mfrmr_gtwst_start_signature")
  expect_equal(signature$Blocks$BlockOrder, seq_len(10L))
  expect_identical(signature$Blocks$BlockName, blocks$BlockName)
  expect_true(signature$ExactBlockSet)
  expect_true(signature$AllFinite)
  expect_identical(signature$SignatureHash, permuted$SignatureHash)
  expect_error(env$mfrmr_gtwst_start_signature(values[-1L]),
               "each exact named")
  duplicated <- c(values, list(beta = 0))
  expect_error(env$mfrmr_gtwst_start_signature(duplicated),
               "each exact named")
  nonnumeric <- values
  nonnumeric$theta <- "bad"
  expect_error(env$mfrmr_gtwst_start_signature(nonnumeric),
               "numeric and finite")
  nonfinite <- values
  nonfinite$theta <- Inf
  expect_error(env$mfrmr_gtwst_start_signature(nonfinite),
               "numeric and finite")
})

test_that("stabilization manifest closes every route and dependency", {
  env <- load_gtheory_weak_information_glmmtmb_stabilization()
  objects <- gtheory_glmmtmb_stabilization_fixture()
  contract <- env$mfrmr_gtwst_contract(objects$Numerical, objects$Typed)
  manifest <- env$mfrmr_gtwst_manifest(contract, objects$Numerical)
  rows <- manifest$Rows

  expect_s3_class(manifest, "mfrmr_gtwst_manifest")
  expect_true(manifest$ManifestReady)
  expect_equal(nrow(rows), 9000L)
  expect_equal(manifest$PlannedBackendFits, 18000L)
  expect_equal(manifest$BaseRouteCount, 1500L)
  expect_equal(manifest$IndependentDatasetCount, 750L)
  expect_equal(manifest$ColdRootPairCount, 3000L)
  expect_equal(manifest$DependentPairCount, 6000L)
  expect_equal(anyDuplicated(rows$StabilizationRouteId), 0L)
  expect_true(all(table(rows$RouteId) == 6L))
  expect_true(all(table(rows$DatasetId) == 12L))
  expect_true(all(table(rows$ProfileId) == 1500L))
  expect_true(all(rows$Backend == "glmmTMB"))
  expect_true(all(rows$CalibrationUse %in% FALSE))
  expect_true(all(rows$ThresholdSelectionPermitted %in% FALSE))
  dependent <- rows$ParentProfileId != "none"
  expect_true(all(rows$ParentStabilizationRouteId[dependent] %in%
                    rows$StabilizationRouteId))
  expect_true(all(rows$ParentStabilizationRouteId[!dependent] == "none"))
  expect_false(manifest$StabilizationRunnerImplemented)
  expect_false(manifest$StabilizationExecutionAuthorized)
  expect_false(manifest$NumericalStabilizationReady)
  expect_false(manifest$DecisionReady)
})

test_that("profile cycles and upstream identity changes fail closed", {
  env <- load_gtheory_weak_information_glmmtmb_stabilization()
  objects <- gtheory_glmmtmb_stabilization_fixture()
  contract <- env$mfrmr_gtwst_contract(objects$Numerical, objects$Typed)
  cyclic <- contract$Profiles
  cyclic$ParentProfileId[cyclic$ProfileId == "glmmTMB_cold_nlminb"] <-
    "glmmTMB_restart_nlminb_from_nlminb"
  cyclic$IsColdRoot <- cyclic$ParentProfileId == "none"
  expect_false(env$mfrmr_gtwst_validate_profile_graph(cyclic))

  wrong_numerical <- objects$Numerical
  wrong_numerical$ExecutionHash <- paste0("x", substring(
    wrong_numerical$ExecutionHash, 2L
  ))
  expect_error(env$mfrmr_gtwst_contract(wrong_numerical, objects$Typed),
               "exact b1e execution")
  wrong_typed <- objects$Typed
  wrong_typed$MismatchCount <- 1L
  expect_error(env$mfrmr_gtwst_contract(objects$Numerical, wrong_typed),
               "exact b1e execution")

  malformed <- objects$Numerical
  default_index <- which(
    malformed$AtomicRows$Backend == "glmmTMB" &
      malformed$AtomicRows$IsDefault
  )
  malformed$AtomicRows$RouteId[default_index[2L]] <-
    malformed$AtomicRows$RouteId[default_index[1L]]
  expect_error(env$mfrmr_gtwst_manifest(contract, malformed),
               "exact 1,500")
})

test_that("exact b1e/b1f ledgers reproduce the b1g design identities", {
  skip_if_not(identical(
    tolower(Sys.getenv("MFRMR_RUN_GTHEORY_GLMMTMB_STABILIZATION_DESIGN",
                       "false")), "true"
  ), "set MFRMR_RUN_GTHEORY_GLMMTMB_STABILIZATION_DESIGN=true")
  env <- load_gtheory_weak_information_glmmtmb_stabilization()
  numerical_path <- Sys.getenv(
    "MFRMR_GTHEORY_NUMERICAL_EXECUTION_RDS",
    "/private/tmp/mfrmr-gtwy-execution-v2.rds"
  )
  typed_path <- Sys.getenv(
    "MFRMR_GTHEORY_TYPED_REPLAY_RDS",
    "/private/tmp/mfrmr-gtwz-adjudication.rds"
  )
  skip_if_not(file.exists(numerical_path) && file.exists(typed_path),
              "exact b1e/b1f ledgers are unavailable")
  numerical <- readRDS(numerical_path)
  typed <- readRDS(typed_path)
  contract <- env$mfrmr_gtwst_contract(numerical, typed)
  manifest <- env$mfrmr_gtwst_manifest(contract, numerical)

  expect_identical(
    contract$ContractHash,
    "8feb8695c655c0621d61863e00d82fffe7fd5d7b619761decefaed6e89b0c326"
  )
  expect_identical(
    manifest$ManifestHash,
    "92435f41b0dab7e13bf1febcf6e043fc1ae8d4a2cb7d159401dd1d78b4c9ff3e"
  )
  expect_true(manifest$ManifestReady)
  expect_equal(manifest$PlannedPairs, 9000L)
  expect_equal(manifest$PlannedBackendFits, 18000L)
  expect_false(manifest$StabilizationExecutionAuthorized)
  expect_false(manifest$NumericalStabilizationReady)
  expect_false(manifest$NumericalSensitivityEvidenceReady)
})
