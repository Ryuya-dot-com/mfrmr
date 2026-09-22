gtheory_stationarity_authorization_audit_paths <- function() {
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
      paste0(
        "gtheory-weak-information-glmmtmb-stationarity-",
        "instrumentation-0.2.3.R"
      ),
      paste0(
        "gtheory-weak-information-glmmtmb-stationarity-calibration-",
        "design-0.2.3.R"
      ),
      paste0(
        "gtheory-weak-information-glmmtmb-stationarity-reference-",
        "calibration-0.2.3.R"
      ),
      paste0(
        "gtheory-weak-information-stationarity-calibration-",
        "authorization-audit-0.2.3.R"
      )
    )
  )
}

load_gtheory_stationarity_authorization_audit <- function() {
  paths <- gtheory_stationarity_authorization_audit_paths()
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

gtheory_stationarity_authorization_objects <- function(env) {
  plan <- env$mfrmr_gtwp_plan()
  design <- env$mfrmr_gtwsz_contract(plan)
  design_manifest <- env$mfrmr_gtwsz_manifest(design, plan)
  reference <- env$mfrmr_gtwta_contract(design)
  reference_manifest <- env$mfrmr_gtwta_manifest(reference)
  audit <- env$mfrmr_gtwaa_contract(
    design, design_manifest, reference, reference_manifest
  )
  manifest <- env$mfrmr_gtwaa_manifest(audit, design_manifest)
  list(
    Plan = plan, Design = design, DesignManifest = design_manifest,
    Reference = reference, ReferenceManifest = reference_manifest,
    Audit = audit, Manifest = manifest
  )
}

test_that("b1g7 accounts for backend-specific optimizer registries", {
  env <- load_gtheory_stationarity_authorization_audit()
  profiles <- env$mfrmr_gtwaa_profile_registry()
  lanes <- env$mfrmr_gtwaa_method_lanes()

  expect_identical(
    as.integer(table(profiles$Backend)[c("glmmTMB", "lme4")]),
    c(6L, 3L)
  )
  expect_equal(anyDuplicated(profiles[c("Backend", "ProfileId")]), 0L)
  expect_equal(anyDuplicated(profiles$ProfileHash), 0L)
  expect_identical(
    lanes$CorrectedCandidateFitCount,
    c(36000L, 36000L, 18000L, 18000L)
  )
  expect_identical(sum(lanes$CorrectedCandidateFitCount), 108000L)
  expect_identical(sum(lanes$ReferenceProblemCount), 24000L)
  expect_identical(sum(lanes$ReferenceMechanicsReady), 1L)
  expect_true(lanes$ReferenceMechanicsReady[lanes$MethodId == "glmmTMB_reml"])
  expect_false(any(lanes$CalibrationExecutionAuthorized))
})

test_that("b1g7 candidate-state algebra fails closed", {
  env <- load_gtheory_stationarity_authorization_audit()
  state <- function(score, curvature, boundary = "not_run") {
    env$mfrmr_gtwaa_candidate_state(
      score, 0.01, 0.05, curvature, boundary
    )$ApplicationState
  }

  expect_identical(
    state(0.005, "positive_definite_factorable"),
    "numerically_eligible"
  )
  expect_identical(
    state(0.02, "positive_definite_factorable"), "indeterminate"
  )
  expect_identical(
    state(0.08, "positive_definite_factorable"),
    "numerically_ineligible"
  )
  expect_identical(
    state(0.005, "spectral_positive_not_factorable"), "indeterminate"
  )
  expect_identical(
    state(0.005, "near_singular_or_semidefinite"), "indeterminate"
  )
  expect_identical(
    state(0.005, "indefinite"), "numerically_ineligible"
  )
  expect_identical(
    state(Inf, "positive_definite_factorable"), "not_evaluable"
  )
  expect_identical(
    state(0.08, "indefinite", "boundary_limit_supported"),
    "boundary_handoff"
  )
  expect_identical(
    state(0.005, "positive_definite_factorable",
          "boundary_probe_inconclusive"),
    "indeterminate"
  )
  expect_error(
    env$mfrmr_gtwaa_first_order_state(0.1, 0.05, 0.01),
    "ordered"
  )
  expect_error(
    state(0.005, "unregistered_curvature"), "registered"
  )
})

test_that("b1g7 selects profiles without looking at the target metric", {
  env <- load_gtheory_stationarity_authorization_audit()
  profiles <- env$mfrmr_gtwaa_profile_registry()
  registry <- profiles[profiles$Backend == "glmmTMB", , drop = FALSE]
  ledger <- data.frame(
    ProfileId = rev(registry$ProfileId), FitReturned = TRUE,
    Objective = rep(10, nrow(registry)), stringsAsFactors = FALSE
  )
  target <- registry$ProfileId[[4L]]
  ledger$Objective[ledger$ProfileId == target] <- 1
  selected <- env$mfrmr_gtwaa_select_profile(ledger, "glmmTMB", profiles)

  expect_identical(selected$SelectedProfileId, target)
  expect_identical(selected$SelectedObjective, 1)
  expect_false(selected$MetricUsedToSelectProfile)

  ledger$Objective <- 5
  tied <- env$mfrmr_gtwaa_select_profile(ledger, "glmmTMB", profiles)
  expect_identical(tied$SelectedProfileId, registry$ProfileId[[1L]])

  ledger$FitReturned <- FALSE
  ledger$Objective <- NA_real_
  absent <- env$mfrmr_gtwaa_select_profile(ledger, "glmmTMB", profiles)
  expect_identical(absent$SelectionState, "not_evaluable")
  expect_identical(absent$AvailableProfileCount, 0L)

  expect_error(
    env$mfrmr_gtwaa_select_profile(ledger[-1L, ], "glmmTMB", profiles),
    "complete"
  )
  malformed <- ledger
  malformed$FitReturned <- as.integer(malformed$FitReturned)
  expect_error(
    env$mfrmr_gtwaa_select_profile(malformed, "glmmTMB", profiles),
    "complete"
  )
})

test_that("b1g7 corrects b1g5 workload without authorizing calibration", {
  env <- load_gtheory_stationarity_authorization_audit()
  objects <- gtheory_stationarity_authorization_objects(env)
  audit <- objects$Audit
  manifest <- objects$Manifest

  expect_true(audit$PreauthorizationAuditReady)
  expect_false(audit$CalibrationAuthorizationReady)
  expect_true(audit$BackendProfileAccountingReady)
  expect_true(audit$CandidateStateAlgebraReady)
  expect_true(audit$PrimaryProfileAggregationReady)
  expect_true(audit$B1g6ReceiptBound)
  expect_false(audit$ReferenceMethodCoverageComplete)
  expect_false(audit$AcceptancePolicyFrozen)
  expect_false(audit$RunnerImplementationReady)
  expect_false(audit$CalibrationExecutionAuthorized)
  expect_false(audit$ConfirmationAuthorized)
  expect_false(audit$InferenceReady)
  expect_identical(audit$OriginalB1g5CandidateFitCount, 144000L)
  expect_identical(audit$CorrectedCandidateFitCount, 108000L)
  expect_identical(audit$CandidateFitOvercount, 36000L)
  expect_identical(audit$CorrectedReferenceProblemCount, 24000L)
  expect_identical(
    audit$CorrectedCandidateFitCountInterpretation,
    "planned_upper_bound_if_every_registered_profile_is_evaluated"
  )
  expect_false(audit$MetricMaySelectOptimizerProfile)
  expect_identical(audit$ProfileAggregationUnit,
                   "dataset_method_model_role")
  expect_false(audit$CandidateRuleMayUseGeneratingTruth)
  expect_false(audit$CandidateBoundaryProbeImplemented)
  expect_false(audit$ConfirmationMayBeRead)
  expect_false(audit$CandidateFitObjectsRetained)
  expect_false(audit$RandomEffectModesRetained)
  expect_false(audit$OriginalDataDuplicatedInSidecars)

  expect_identical(manifest$BaseMethodUnitCount, 12000L)
  expect_identical(manifest$IndependentDatasetCount, 3000L)
  expect_identical(manifest$OriginalB1g5CandidateFitCount, 144000L)
  expect_identical(manifest$CorrectedCandidateFitCount, 108000L)
  expect_identical(manifest$CandidateFitOvercount, 36000L)
  expect_identical(manifest$ReferenceProblemCount, 24000L)
  expect_identical(manifest$ReferenceReadyMethodCount, 1L)
  expect_setequal(manifest$Rows$Replicate, 201:300)
  expect_false(any(manifest$Rows$Replicate %in% 501:700))
  expect_false(manifest$ExecutionAuthorized)
  expect_false(manifest$RuleSelectionPermitted)
  expect_false(manifest$ConfirmationAuthorized)
  expect_true(env$mfrmr_gtwaa_manifest_hash_valid(manifest))

  changed <- manifest
  changed$Rows$CorrectedCandidateFitCount[[1L]] <- 13L
  expect_false(env$mfrmr_gtwaa_manifest_hash_valid(changed))
  expect_identical(
    audit$AuthorizationAuditHash,
    "b293987e768ec0e998d3224a6df0689f0ab8b6f2268704ef422e333865d82765"
  )
  expect_identical(
    manifest$ManifestHash,
    "7cce9d42faccfbbdf928c9ec4978fef25c50aa562750141fbab45a53b75885f8"
  )
})

test_that("b1g7 binds the retained b1g6 receipt when available", {
  path <- Sys.getenv(
    "MFRMR_GTHEORY_GLMMTMB_REFERENCE_REPLAY_RDS",
    "/private/tmp/mfrmr-gtwta-reference-replay-v4.rds"
  )
  skip_if_not(file.exists(path), "retained b1g6 replay is unavailable")
  env <- load_gtheory_stationarity_authorization_audit()
  execution <- readRDS(path)

  expect_true(env$mfrmr_gtwaa_b1g6_execution_valid(execution))
  changed <- execution
  changed$ExecutionHash <- paste0("0", substring(changed$ExecutionHash, 2L))
  expect_false(env$mfrmr_gtwaa_b1g6_execution_valid(changed))
})
