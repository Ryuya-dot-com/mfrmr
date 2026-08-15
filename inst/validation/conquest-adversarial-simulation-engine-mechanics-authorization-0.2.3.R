# Prospective ASP-G4E authorization for the bounded engine-mechanics smoke.
#
# This contract binds the retained G3 datasets to the corrected G4-v2 workload
# and authorizes only the scope of a future run-once mechanics harness. It does
# not fit a model, launch ConQuest, create an output directory, inspect numeric
# agreement, or substitute a recorded console transcript for a fresh sentinel.

mfrmr_cq_amea_specification <-
  "0.2.3-conquest-adversarial-simulation-engine-mechanics-authorization-v1"
mfrmr_cq_amea_contract <-
  "mfrmr_conquest_adversarial_simulation_engine_mechanics_authorization_v1"
mfrmr_cq_amea_execution_identity <-
  "mfrmr-0.2.3-conquest-asp-engine-mechanics-001"
mfrmr_cq_amea_authorization_date <- as.Date("2026-08-16")
mfrmr_cq_amea_run_not_after <- as.Date("2026-08-31")
mfrmr_cq_amea_output_basename <-
  "conquest-adversarial-simulation-engine-mechanics-20260816-v1"
mfrmr_cq_amea_smoke_output_basename <-
  "conquest-adversarial-simulation-smoke-20260815-v1"

mfrmr_cq_amea_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_amea_require_contracts <- function() {
  target <- environment(mfrmr_cq_amea_require_contracts)
  required_functions <- c(
    "mfrmr_cq_ase_review_output", "mfrmr_cq_acf_review",
    "mfrmr_cq_acf_engine_mechanics_registry",
    "mfrmr_cq_acf_representation_bridge_registry",
    "mfrmr_cq_acf_resource_budget_registry",
    "mfrmr_cq_acf_runtime_contract"
  )
  available <- vapply(
    required_functions, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- c(
    exists("mfrmr_cq_ase_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_ase_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_adversarial_simulation_smoke_execution_v1"
      ),
    exists("mfrmr_cq_acf_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_acf_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_adversarial_simulation_calibration_freeze_v2"
      )
  )
  mfrmr_cq_amea_assert(
    all(available) && all(identity),
    "Source the retained G3 execution and corrected G4-v2 freeze first."
  )
  invisible(TRUE)
}

mfrmr_cq_amea_stage_registry <- function() {
  data.frame(
    StageOrder = 1:6,
    StageId = c(
      "retained_G3_semantic_revalidation",
      "fresh_data_free_runtime_sentinel",
      "structural_and_representation_prefit",
      "scheduled_run_once_fit_attempts",
      "lossless_terminal_classification",
      "mechanics_completion_audit"
    ),
    ModelFitMayOccur = c(FALSE, FALSE, FALSE, TRUE, FALSE, FALSE),
    ConQuestMayLaunch = c(FALSE, TRUE, FALSE, TRUE, FALSE, FALSE),
    NumericAgreementMayBeInspected = FALSE,
    ResultMayTuneDGPOrThreshold = FALSE,
    ResultMayAuthorizeCalibrationDirectly = FALSE,
    ExecutionPerformedByThisContract = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_amea_execution_plan <- function() {
  mfrmr_cq_amea_require_contracts()
  out <- mfrmr_cq_acf_engine_mechanics_registry()
  out$ScheduledOutcomeOrder <- seq_len(nrow(out))
  out$AttemptOrder <- NA_integer_
  attempt <- out$AttemptRequiredAtFutureMechanicsGate
  out$AttemptOrder[attempt] <- seq_len(sum(attempt))
  out$ExecutionIdentity <- mfrmr_cq_amea_execution_identity
  out$RunOnce <- TRUE
  out$AutomaticRetryPermitted <- FALSE
  out$PeerOrCompanionFailureMaySuppressAttempt <- FALSE
  out$GlobalResourceAbortMaySuppressAttempt <- TRUE
  out$NumericAgreementMayAffectAttemptOrder <- FALSE
  out$CalibrationUsePermitted <- FALSE
  out$PublicClaimPermitted <- FALSE
  out$ExecutionAuthorizedByThisContract <- FALSE
  out <- out[, c(
    "ScheduledOutcomeOrder", "AttemptOrder", "ExecutionIdentity",
    "DatasetId", "ArmId", "ScenarioClassId", "Family", "Engine",
    "RepresentationId", "RepresentationFitRole",
    "RepresentationBridgeContractId", "QuadratureId",
    "StructuralDispositionFromRetainedG3",
    "AttemptRequiredAtFutureMechanicsGate", "AttemptCap",
    "ConQuestCanonicalBridgeForBothPairedRepresentations",
    "RetainedG3DataUsed", "MechanicsOnly", "RunOnce",
    "AutomaticRetryPermitted",
    "PeerOrCompanionFailureMaySuppressAttempt",
    "GlobalResourceAbortMaySuppressAttempt",
    "NumericAgreementMayAffectAttemptOrder", "CalibrationUsePermitted",
    "PublicClaimPermitted", "ExecutionAuthorizedByThisContract"
  )]
  mfrmr_cq_amea_assert(
    nrow(out) == 38L && sum(out$AttemptCap) == 30L &&
      identical(out$AttemptOrder[!is.na(out$AttemptOrder)], 1:30) &&
      sum(out$QuadratureId == "prefit_stop") == 8L &&
      sum(out$RepresentationId == "explicit_missing") == 2L &&
      !any(out$AutomaticRetryPermitted) &&
      !any(out$PeerOrCompanionFailureMaySuppressAttempt),
    "The G4E mechanics plan drifted from the corrected G4-v2 denominator."
  )
  out
}

mfrmr_cq_amea_output_schema_registry <- function() {
  data.frame(
    TableId = c(
      "authority_snapshot", "retained_source_audit",
      "representation_bridge_audit", "execution_plan",
      "attempt_journal", "engine_outcome", "attempt_artifact_inventory",
      "resource_summary", "execution_summary"
    ),
    ExpectedRowsAtClosedRun = c(1L, 7L, 8L, 38L, 30L, 38L, 30L, 1L, 1L),
    RequiredColumns = c(
      paste(
        "Specification;ContractVersion;ExecutionIdentity;AuthorizationDate",
        "RunNotAfter;ExecutablePath;ScopeAuthorized;LiveSentinelObserved",
        sep = ";"
      ),
      "SourceObject;ExpectedRows;ObservedRows;SemanticValidationPassed",
      paste(
        "DatasetId;Family;CheckOrder;CheckId;Passed;PrimaryTerminalCode",
        "SecondaryCode", sep = ";"
      ),
      paste(
        "ScheduledOutcomeOrder;AttemptOrder;DatasetId;Family;Engine",
        "RepresentationId;QuadratureId;AttemptCap", sep = ";"
      ),
      paste(
        "AttemptOrder;DatasetId;Engine;RepresentationId;Started;Completed",
        "ElapsedSeconds;TerminalCode", sep = ";"
      ),
      paste(
        "DatasetId;Engine;RepresentationId;Attempted;TerminalCode",
        "SecondaryCode;RowRetained", sep = ";"
      ),
      paste(
        "AttemptOrder;Engine;ArtifactDirectory;ExpectedArtifactKinds",
        "PresentArtifactKinds;UnexpectedArtifactKinds;ArtifactSetComplete",
        sep = ";"
      ),
      paste(
        "FitAttempts;ElapsedSeconds;RetainedBytes;WallTimeCapSeconds",
        "StorageCapBytes;GlobalAbortTriggered", sep = ";"
      ),
      paste(
        "RetainedDatasets;RetainedOutcomeRows;RetainedAttemptOutcomeRows",
        "MechanicsGateMet;CalibrationAuthorized;NumericAgreementInspected",
        sep = ";"
      )
    ),
    FailureOrUnattemptedRowsRequired = TRUE,
    NumericAgreementColumnPermitted = FALSE,
    WriteAuthorizedByThisContract = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_amea_fatal_gate_registry <- function() {
  data.frame(
    GateOrder = 1:19,
    GateId = c(
      "RETAINED_G3_SEMANTIC_REPLAY_PASSES",
      "RETAINED_G3_HAS_ZERO_FIT_ATTEMPTS",
      "CORRECTED_G4_V2_FREEZE_COMPLETE",
      "EXACT_EIGHTEEN_RETAINED_DATASETS",
      "EXACT_THIRTY_EIGHT_OUTCOME_ROWS",
      "EXACT_THIRTY_RUN_ONCE_FIT_ATTEMPTS",
      "FOUR_NEGATIVE_CONTROLS_REMAIN_PREFIT",
      "PAIRED_REPRESENTATION_DENOMINATOR_COMPLETE",
      "FOUR_PART_SEMANTIC_BRIDGE_FROZEN",
      "LOSSLESS_OUTPUT_SCHEMA_FROZEN",
      "EXACT_CONQUEST_RUNTIME_BINDING_FROZEN",
      "FRESH_LIVE_SENTINEL_REQUIRED_NOT_REPLAYED",
      "NEW_EXACT_OUTPUT_ROOT_IS_ABSENT",
      "WORKTREE_CLEAN_AT_AUTHORIZATION",
      "ORDINARY_TESTS_EXTERNAL_RUNTIME_FREE",
      "EIGHT_HOUR_TWO_GIB_RESOURCE_CAP",
      "NO_RETRY_OR_PEER_FAILURE_SUPPRESSION",
      "NO_NUMERIC_AGREEMENT_OR_INTERPRETIVE_USE",
      "NARROW_SCOPE_ATTESTATION_COMPLETE"
    ),
    BlocksHarnessPreparation = TRUE,
    BlocksLiveExecution = TRUE,
    CanBeWaivedForExpiryPressure = FALSE,
    FailureMayTuneDGPOrThreshold = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_amea_attestation <- function() {
  data.frame(
    AttestationId = "mfrmr-0.2.3-conquest-asp-g4e-scope-001",
    Role = "maintainer_scope_audit",
    AuthorOverlapDeclared = TRUE,
    ExactThirtyAttemptCapAccepted = TRUE,
    ExactThirtyEightOutcomeDenominatorAccepted = TRUE,
    FreshSentinelDeferredToSameExecutionSession = TRUE,
    NoNumericAgreementInspectionAccepted = TRUE,
    NoCalibrationOrPublicClaimAccepted = TRUE,
    IndependentReviewRequiredForMechanicsAuthorization = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_amea_review <- function(
    smoke_output_dir,
    output_dir,
    authorization_date = mfrmr_cq_amea_authorization_date,
    worktree_clean = TRUE,
    ordinary_tests_external_runtime_free = TRUE) {
  mfrmr_cq_amea_require_contracts()
  authorization_date <- as.Date(authorization_date)[1L]
  smoke_output_dir <- normalizePath(
    as.character(smoke_output_dir)[1L], winslash = "/", mustWork = TRUE
  )
  output_dir <- normalizePath(
    as.character(output_dir)[1L], winslash = "/", mustWork = FALSE
  )
  g3 <- mfrmr_cq_ase_review_output(smoke_output_dir)
  g4 <- mfrmr_cq_acf_review()
  plan <- mfrmr_cq_amea_execution_plan()
  bridge <- mfrmr_cq_acf_representation_bridge_registry()
  schema <- mfrmr_cq_amea_output_schema_registry()
  runtime <- mfrmr_cq_acf_runtime_contract()
  budget <- mfrmr_cq_acf_resource_budget_registry()
  mechanics_budget <- budget[
    budget$Stage == "engine_mechanics_smoke", , drop = FALSE
  ]
  attestation <- mfrmr_cq_amea_attestation()
  negative <- plan$StructuralDispositionFromRetainedG3 ==
    "reject_before_numeric_comparison"
  paired <- plan$ScenarioClassId == "ASP-INV-PAIRED-MISSINGNESS"
  source_ready <- identical(
    basename(smoke_output_dir), mfrmr_cq_amea_smoke_output_basename
  ) && identical(
    g3$status, "ASP_G3_eighteen_smoke_datasets_generated_and_retained"
  ) && isTRUE(g3$semantic_replay_match) && isTRUE(g3$tables_valid) &&
    isTRUE(g3$container_valid)
  g4_ready <- identical(
    g4$status, "ASP_G4_calibration_contract_frozen_execution_closed"
  ) && isTRUE(g4$G4_calibration_freeze_complete) &&
    isTRUE(g4$paired_missingness_workload_corrected_before_engine_execution) &&
    !isTRUE(g4$any_fit_attempted) && !isTRUE(g4$calibration_results_opened)
  bridge_ready <- nrow(bridge) == 4L &&
    identical(bridge$CheckOrder, 1:4) &&
    all(bridge$RequiredForEachPairedDatasetBridgeCheck) &&
    !any(bridge$ByteEqualityRequired)
  schema_ready <- nrow(schema) == 9L &&
    identical(sum(schema$ExpectedRowsAtClosedRun), 154L) &&
    all(schema$FailureOrUnattemptedRowsRequired) &&
    !any(schema$NumericAgreementColumnPermitted) &&
    !any(schema$WriteAuthorizedByThisContract)
  runtime_ready <- nrow(runtime) == 1L && identical(
    runtime$ExecutablePath, "/Applications/ConQuest/ConQuest"
  ) && identical(runtime$RequiredVersion, "5.47.5") &&
    identical(runtime$RunNotAfter, mfrmr_cq_amea_run_not_after) &&
    authorization_date <= runtime$RunNotAfter &&
    authorization_date < runtime$ExpiryDate &&
    isTRUE(runtime$FreshDataFreeSentinelRequiredEachSession)
  output_ready <- identical(
    basename(output_dir), mfrmr_cq_amea_output_basename
  ) && !file.exists(output_dir) && !dir.exists(output_dir)
  attested <- isTRUE(attestation$AuthorOverlapDeclared) &&
    isTRUE(attestation$ExactThirtyAttemptCapAccepted) &&
    isTRUE(attestation$ExactThirtyEightOutcomeDenominatorAccepted) &&
    isTRUE(attestation$FreshSentinelDeferredToSameExecutionSession) &&
    isTRUE(attestation$NoNumericAgreementInspectionAccepted) &&
    isTRUE(attestation$NoCalibrationOrPublicClaimAccepted) &&
    !isTRUE(attestation$IndependentReviewRequiredForMechanicsAuthorization)
  gate_passed <- c(
    source_ready,
    identical(g3$fit_attempts, 0L) && !isTRUE(g3$ConQuest_execution_attempted),
    g4_ready,
    identical(g3$generated_datasets, 18L) &&
      identical(length(unique(plan$DatasetId)), 18L),
    nrow(plan) == 38L,
    sum(plan$AttemptCap) == 30L &&
      identical(plan$AttemptOrder[!is.na(plan$AttemptOrder)], 1:30),
    sum(negative) == 8L && sum(plan$AttemptCap[negative]) == 0L &&
      identical(g3$rejected_structural_arms, 4L),
    sum(paired) == 6L &&
      sum(plan$RepresentationId == "explicit_missing") == 2L &&
      sum(plan$ConQuestCanonicalBridgeForBothPairedRepresentations) == 2L,
    bridge_ready,
    schema_ready,
    runtime_ready,
    isTRUE(runtime$FreshDataFreeSentinelRequiredEachSession),
    output_ready,
    isTRUE(worktree_clean),
    isTRUE(ordinary_tests_external_runtime_free),
    nrow(mechanics_budget) == 1L &&
      mechanics_budget$CumulativeWallTimeCapSeconds == 28800L &&
      mechanics_budget$RetainedStorageCapBytes == 2 * 1024^3,
    !any(plan$AutomaticRetryPermitted) &&
      !any(plan$PeerOrCompanionFailureMaySuppressAttempt),
    !any(plan$NumericAgreementMayAffectAttemptOrder) &&
      !any(plan$CalibrationUsePermitted) && !any(plan$PublicClaimPermitted),
    attested
  )
  gates <- mfrmr_cq_amea_fatal_gate_registry()
  gates$Passed <- gate_passed
  gates$ObservedState <- ifelse(gates$Passed, "pass", "blocked")
  within_window <- !is.na(authorization_date) &&
    authorization_date >= mfrmr_cq_amea_authorization_date &&
    authorization_date <= mfrmr_cq_amea_run_not_after
  scope_authorized <- within_window && all(gates$Passed)
  list(
    specification = mfrmr_cq_amea_specification,
    contract_version = mfrmr_cq_amea_contract,
    execution_identity = mfrmr_cq_amea_execution_identity,
    status = if (scope_authorized) {
      "ASP_G4E_engine_mechanics_scope_authorized_live_sentinel_pending"
    } else {
      "ASP_G4E_engine_mechanics_authorization_blocked"
    },
    authorization_date = authorization_date,
    run_not_after = mfrmr_cq_amea_run_not_after,
    smoke_output_dir = smoke_output_dir,
    output_dir = output_dir,
    retained_G3_review = g3,
    corrected_G4_review = g4,
    stages = mfrmr_cq_amea_stage_registry(),
    plan = plan,
    representation_bridge = bridge,
    output_schema = schema,
    runtime_contract = runtime,
    resource_budget = mechanics_budget,
    attestation = attestation,
    gates = gates,
    failed_gates = gates[!gates$Passed, , drop = FALSE],
    all_nineteen_fatal_gates_passed = all(gates$Passed),
    engine_mechanics_scope_authorized = scope_authorized,
    live_execution_authorized = FALSE,
    fresh_runtime_sentinel_observed = FALSE,
    fresh_runtime_sentinel_required_at_execution = TRUE,
    harness_preparation_authorized = scope_authorized,
    new_response_generation_authorized = FALSE,
    fit_attempt_cap = 30L,
    retained_outcome_row_cap = 38L,
    numeric_agreement_inspection_authorized = FALSE,
    calibration_generation_authorized = FALSE,
    calibration_execution_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    public_text_change_authorized = FALSE,
    scientific_equivalence_inferred = FALSE,
    any_fit_attempted = FALSE,
    ConQuest_execution_attempted = FALSE,
    next_action = "ASP-G4H-ENGINE-MECHANICS-HARNESS-FREEZE"
  )
}
