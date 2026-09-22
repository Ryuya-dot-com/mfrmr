# No-execution ASP-G4L tranche-A live-authorization freeze.
#
# This layer freezes the only issuer accepted by the G4C-P4 run-once consumer.
# A review can establish issue-readiness, but it does not create an authority,
# run a sentinel, generate responses, fit mfrmr, launch ConQuest, or inspect a
# numeric result. A positive mutable authority can exist only after an explicit
# same-process opt-in to the issuer and must be consumed before the sentinel.

mfrmr_cq_atla_specification <-
  "0.2.3-conquest-adversarial-simulation-tranche-a-live-authorization-v1"
mfrmr_cq_atla_contract <- paste0(
  "mfrmr_conquest_adversarial_simulation_tranche_a_",
  "live_authorization_freeze_v1"
)
mfrmr_cq_atla_review_date <- as.Date("2026-08-16")
mfrmr_cq_atla_run_not_after <- as.Date("2026-08-31")
mfrmr_cq_atla_authorization_identity <- paste0(
  "tranche_A::datasets=90::outcomes=230::attempts=190::",
  "q61=150::q121=40"
)

mfrmr_cq_atla_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_atla_require_contracts <- function() {
  target <- environment(mfrmr_cq_atla_require_contracts)
  required <- c(
    "mfrmr_cq_ach_dry_run_review", "mfrmr_cq_ach_adapter_plan",
    "mfrmr_cq_ach_plan_audit", "mfrmr_cq_ach_schema_registry",
    "mfrmr_cq_ach_authorization_schema", "mfrmr_cq_ach_resource_state",
    "mfrmr_cq_ach_metric_summary", "mfrmr_cq_ach_attempt_journal_template",
    "mfrmr_cq_ach_outcome_template", "mfrmr_cq_ataa_harness_capability_registry",
    "mfrmr_cq_acf_seed_registry", "mfrmr_cq_acf_runtime_contract",
    "mfrmr_cq_ameh_review_execution"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- exists(
    "mfrmr_cq_ach_required_authorization_issuer_contract",
    envir = target, inherits = TRUE
  ) && identical(
    get(
      "mfrmr_cq_ach_required_authorization_issuer_contract",
      envir = target, inherits = TRUE
    ), mfrmr_cq_atla_contract
  )
  mfrmr_cq_atla_assert(
    all(available) && identity,
    "Source the complete G4C-P4 contract before G4L."
  )
  invisible(TRUE)
}

mfrmr_cq_atla_fatal_gate_registry <- function() {
  data.frame(
    GateOrder = 1:32,
    GateId = c(
      "G4C_P4_INTEGRATED_DRY_RUN_FROZEN",
      "ALL_EIGHTEEN_HARNESS_CAPABILITIES_AVAILABLE",
      "G4A_REQUIRES_SEPARATE_LIVE_AUTHORIZATION",
      "EXACT_PLAN_AUDIT_PASSES",
      "EXACT_NINETY_DATASET_TWO_HUNDRED_THIRTY_OUTCOME_SCOPE",
      "EXACT_ONE_HUNDRED_NINETY_ENGINE_ATTEMPT_SCOPE",
      "EXACT_Q61_Q121_ATTEMPT_SCOPE",
      "TWENTY_NEGATIVE_DATASETS_FORTY_PREFIT_ROWS_RETAINED",
      "PAIR_DENOMINATORS_EXACT",
      "FOURTEEN_TABLE_LOSSLESS_SCHEMA_FROZEN",
      "G4N_TERMINAL_AND_READINESS_NONMUTATION_FROZEN",
      "METRIC_DENOMINATOR_OBSERVATION_RECONSTRUCTION_FROZEN",
      "RETAINED_EXECUTION_REVIEWER_AVAILABLE",
      "RETAINED_G4X_RUN_ONCE_CONSUMED_NO_RERUN",
      "RETAINED_G3_SEMANTIC_BRIDGE_REPLAY_PASSES",
      "TRANCHE_A_SEEDS_UNGENERATED_AND_UNOPENED",
      "EXACT_CALIBRATION_OUTPUT_TARGET",
      "CALIBRATION_OUTPUT_TARGET_ABSENT",
      "INCOMPLETE_OUTPUT_SIBLING_ABSENT",
      "EXACT_CONQUEST_EXECUTABLE_PATH",
      "CONQUEST_EXECUTABLE_PRESENT",
      "CONQUEST_EXECUTABLE_EXECUTABLE",
      "AUTHORIZATION_NOT_BEFORE_FROZEN_REVIEW_DATE",
      "AUTHORIZATION_NOT_AFTER_FROZEN_RUN_DATE",
      "AUTHORIZATION_PRECEDES_DEMONSTRATION_EXPIRY",
      "FRESH_SENTINEL_DEFERRED_UNTIL_AFTER_CONSUMPTION",
      "WORKTREE_CLEAN_AT_ISSUE_REVIEW",
      "ORDINARY_TESTS_EXTERNAL_RUNTIME_FREE",
      "EXACT_HARD_RESOURCE_CAPS_RETAINED",
      "NO_RETRY_PEER_SUPPRESSION_OR_RESULT_DRIVEN_ORDER",
      "EXPLORATORY_NONPROMOTIONAL_ATTESTATION_COMPLETE",
      "EXACT_G4L_ISSUER_SCHEMA_AND_SAME_PROCESS_BOUNDARY"
    ),
    BlocksAuthorizationIssue = TRUE,
    BlocksLiveExecution = TRUE,
    CanBeWaivedForExpiryPressure = FALSE,
    FailureMayTuneSeedDGPMetricOrThreshold = FALSE,
    FileHashMaySatisfyGate = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_atla_attestation <- function() {
  data.frame(
    AuditId = "mfrmr-0.2.3-conquest-asp-g4l-live-authorization-001",
    ReviewerRole = "maintainer_preexecution_scope_audit",
    AuthorOverlapDeclared = TRUE,
    ExactNinetyDatasetScopeAccepted = TRUE,
    ExactTwoHundredThirtyOutcomeDenominatorAccepted = TRUE,
    ExactOneHundredNinetyAttemptCapAccepted = TRUE,
    ResourceEvidenceIsPreliminaryAccepted = TRUE,
    HardGlobalAbortMayRetainUnattemptedRowsAccepted = TRUE,
    FiveReplicatesAreDiagnosticNotPrecisionClaimAccepted = TRUE,
    FreshSentinelAfterConsumptionAccepted = TRUE,
    NoAutomaticRetryAccepted = TRUE,
    NoThresholdSelectionAccepted = TRUE,
    ExploratoryOnlyAccepted = TRUE,
    NoConfirmationEvidencePromotionOrPublicClaimAccepted = TRUE,
    IndependentThirdPartyRecalculationRequired = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_atla_safe_p4_review <- function(
    g4x_output_dir, calibration_output_dir, smoke_output_dir) {
  tryCatch(
    mfrmr_cq_ach_dry_run_review(
      g4x_output_dir, calibration_output_dir, smoke_output_dir
    ),
    error = function(error) NULL
  )
}

mfrmr_cq_atla_git_worktree_review <- function(
    repository_root, runner = base::system2) {
  root <- normalizePath(
    as.character(repository_root)[1L], winslash = "/", mustWork = TRUE
  )
  output <- tryCatch(
    runner(
      "git",
      c(
        "-C", shQuote(root), "status", "--porcelain=v1",
        "--untracked-files=all"
      ),
      stdout = TRUE,
      stderr = TRUE
    ),
    error = function(error) {
      value <- conditionMessage(error)
      attr(value, "status") <- 1L
      value
    }
  )
  exit_status <- attr(output, "status", exact = TRUE)
  if (is.null(exit_status)) exit_status <- 0L
  list(
    repository_root = root,
    command = "git -C <repository_root> status --porcelain=v1 --untracked-files=all",
    exit_status = as.integer(exit_status)[1L],
    status_lines = as.character(output),
    clean = identical(as.integer(exit_status)[1L], 0L) && length(output) == 0L
  )
}

mfrmr_cq_atla_review <- function(
    g4x_output_dir,
    calibration_output_dir,
    smoke_output_dir = file.path(
      dirname(g4x_output_dir), mfrmr_cq_ase_output_basename
    ),
    authorization_date = mfrmr_cq_atla_review_date,
    worktree_clean = FALSE,
    ordinary_tests_external_runtime_free = TRUE) {
  mfrmr_cq_atla_require_contracts()
  authorization_date <- as.Date(authorization_date)[1L]
  output_dir <- normalizePath(
    as.character(calibration_output_dir)[1L], winslash = "/", mustWork = FALSE
  )
  normalized_g4x_output_dir <- normalizePath(
    as.character(g4x_output_dir)[1L], winslash = "/", mustWork = TRUE
  )
  expected_output_dir <- normalizePath(
    file.path(dirname(normalized_g4x_output_dir), mfrmr_cq_ataa_output_basename),
    winslash = "/", mustWork = FALSE
  )
  p4 <- mfrmr_cq_atla_safe_p4_review(
    g4x_output_dir, output_dir, smoke_output_dir
  )
  plan <- mfrmr_cq_ach_adapter_plan()
  plan_audit <- mfrmr_cq_ach_plan_audit(plan)
  schema <- mfrmr_cq_ach_schema_registry()
  capability <- mfrmr_cq_ataa_harness_capability_registry()
  seed <- mfrmr_cq_acf_seed_registry()
  seed <- seed[seed$Tranche == "A", , drop = FALSE]
  runtime <- mfrmr_cq_acf_runtime_contract()
  resource <- mfrmr_cq_ach_resource_state()
  authorization_schema <- mfrmr_cq_ach_authorization_schema()
  attestation <- mfrmr_cq_atla_attestation()
  journal <- mfrmr_cq_ach_attempt_journal_template(plan)
  outcome <- mfrmr_cq_ach_outcome_template(plan)
  eligibility <- data.frame(
    AttemptOrder = journal$AttemptOrder,
    DiagnosticNumericEligible = FALSE,
    stringsAsFactors = FALSE
  )
  metric <- mfrmr_cq_ach_metric_summary(plan, outcome, eligibility)
  g4x <- tryCatch(
    mfrmr_cq_ameh_review_execution(g4x_output_dir),
    error = function(error) NULL
  )
  attempted <- plan$AttemptCap == 1L
  negative <- plan$ExpectedStructuralDisposition ==
    "reject_before_numeric_comparison"
  bridge_replay_ready <- !is.null(p4) && identical(
    p4$p3_review$p2_review$retained_bridge_replay$bridge_check_count, 8L
  ) && all(p4$p3_review$p2_review$retained_bridge_replay$bridge$Passed)
  attested <- isTRUE(attestation$AuthorOverlapDeclared) &&
    isTRUE(attestation$ExactNinetyDatasetScopeAccepted) &&
    isTRUE(attestation$ExactTwoHundredThirtyOutcomeDenominatorAccepted) &&
    isTRUE(attestation$ExactOneHundredNinetyAttemptCapAccepted) &&
    isTRUE(attestation$ResourceEvidenceIsPreliminaryAccepted) &&
    isTRUE(attestation$HardGlobalAbortMayRetainUnattemptedRowsAccepted) &&
    isTRUE(attestation$FiveReplicatesAreDiagnosticNotPrecisionClaimAccepted) &&
    isTRUE(attestation$FreshSentinelAfterConsumptionAccepted) &&
    isTRUE(attestation$NoAutomaticRetryAccepted) &&
    isTRUE(attestation$NoThresholdSelectionAccepted) &&
    isTRUE(attestation$ExploratoryOnlyAccepted) &&
    isTRUE(attestation$NoConfirmationEvidencePromotionOrPublicClaimAccepted) &&
    !isTRUE(attestation$IndependentThirdPartyRecalculationRequired)
  gate_passed <- c(
    !is.null(p4) && identical(
      p4$status,
      paste0(
        "ASP_G4C_P4_integrated_dry_run_harness_frozen_",
        "separate_live_authorization_required"
      )
    ),
    !is.null(p4) &&
      identical(p4$upstream_and_harness_capabilities_available, 18L) &&
      identical(p4$harness_capabilities_still_missing, 0L) &&
      all(capability$ProviderAvailable),
    !is.null(p4) && identical(
      p4$g4a_review$status,
      "ASP_G4A_harness_ready_separate_live_authorization_required"
    ),
    all(plan_audit$Passed),
    nrow(plan) == 230L && length(unique(plan$DatasetId)) == 90L,
    sum(plan$AttemptCap) == 190L &&
      sum(attempted & plan$Engine == "mfrmr") == 100L &&
      sum(attempted & plan$Engine == "ConQuest") == 90L,
    sum(attempted & plan$Nodes == 61L) == 150L &&
      sum(attempted & plan$Nodes == 121L) == 40L,
    length(unique(plan$DatasetId[negative])) == 20L &&
      sum(negative) == 40L && !any(attempted[negative]),
    length(unique(stats::na.omit(plan$CrossEnginePairId))) == 90L &&
      length(unique(stats::na.omit(plan$QuadraturePairId))) == 40L &&
      length(unique(stats::na.omit(plan$RepresentationPairId))) == 10L,
    nrow(schema) == 14L && !any(schema$RowDroppable) &&
      !any(schema$ResultMayChangeSchema),
    !is.null(p4) && isTRUE(
      p4$terminal_nonmutating_G4N_application_implemented
    ),
    !is.null(p4) &&
      isTRUE(p4$conditional_and_unconditional_metric_summarizer_implemented) &&
      nrow(metric) == 14L && all(metric$RecordType == "accounting") &&
      !any(metric$PrimaryPooledSummaryPermitted) &&
      all(metric$FailureRowsRetained),
    !is.null(p4) && isTRUE(p4$retained_execution_reviewer_implemented),
    !is.null(g4x) && isTRUE(g4x$run_once_consumed) &&
      !isTRUE(g4x$rerun_authorized) && isTRUE(g4x$mechanics_gate_met),
    bridge_replay_ready,
    nrow(seed) == 90L && !any(seed$Generated) && !any(seed$ResultOpened) &&
      !any(seed$MayTuneDGP) && !any(seed$MayTuneMetricThreshold),
    identical(output_dir, expected_output_dir),
    !file.exists(output_dir) && !dir.exists(output_dir),
    !file.exists(paste0(output_dir, ".incomplete")) &&
      !dir.exists(paste0(output_dir, ".incomplete")),
    nrow(runtime) == 1L && identical(
      normalizePath(runtime$ExecutablePath, winslash = "/", mustWork = FALSE),
      normalizePath(
        mfrmr_cq_acf_conquest_path, winslash = "/", mustWork = FALSE
      )
    ),
    file.exists(runtime$ExecutablePath),
    file.access(runtime$ExecutablePath, 1L) == 0L,
    !is.na(authorization_date) &&
      authorization_date >= mfrmr_cq_atla_review_date,
    !is.na(authorization_date) &&
      authorization_date <= mfrmr_cq_atla_run_not_after &&
      identical(runtime$RunNotAfter, mfrmr_cq_atla_run_not_after),
    !is.na(authorization_date) && authorization_date < runtime$ExpiryDate,
    isTRUE(runtime$FreshDataFreeSentinelRequiredEachSession) &&
      isTRUE(runtime$SentinelMustPrecedeCalibrationGeneration) &&
      !is.null(p4) && !isTRUE(p4$fresh_tranche_A_sentinel_observed) &&
      !isTRUE(p4$positive_live_authorization_issued_by_P4),
    isTRUE(worktree_clean),
    isTRUE(ordinary_tests_external_runtime_free),
    identical(as.integer(resource$TotalFitAttemptCap), 190L) &&
      identical(as.integer(resource$Q61FitAttemptCap), 150L) &&
      identical(as.integer(resource$Q121FitAttemptCap), 40L) &&
      identical(as.integer(resource$PerFitTimeoutSeconds), 600L) &&
      identical(as.numeric(resource$WallTimeCapSeconds), 28800) &&
      identical(as.numeric(resource$StorageCapBytes), 2 * 1024^3),
    !any(plan$AutomaticRetryPermitted) &&
      !any(plan$PeerFailureMaySuppressAttempt) &&
      !any(plan$ResultMayChangeAttemptOrder),
    attested,
    nrow(authorization_schema) == 28L && identical(
      authorization_schema$P4RequiredValue[
        authorization_schema$Field == "AuthorizationIssuerContract"
      ], mfrmr_cq_atla_contract
    ) && identical(
      authorization_schema$P4RequiredValue[
        authorization_schema$Field == "AuthorizationIssuedByP4"
      ], "FALSE"
    )
  )
  gates <- mfrmr_cq_atla_fatal_gate_registry()
  mfrmr_cq_atla_assert(
    length(gate_passed) == nrow(gates),
    "The G4L fatal-gate implementation drifted from its registry."
  )
  gates$Passed <- gate_passed
  gates$ObservedState <- ifelse(gates$Passed, "pass", "blocked")
  ready <- all(gates$Passed)
  list(
    specification = mfrmr_cq_atla_specification,
    contract_version = mfrmr_cq_atla_contract,
    authorization_identity = mfrmr_cq_atla_authorization_identity,
    status = if (ready) {
      "ASP_G4L_run_once_live_authorization_ready_for_same_process_issue"
    } else {
      "ASP_G4L_live_authorization_issue_blocked"
    },
    authorization_date = authorization_date,
    run_not_after = mfrmr_cq_atla_run_not_after,
    output_dir = output_dir,
    expected_output_dir = expected_output_dir,
    executable_path = runtime$ExecutablePath,
    p4_review = p4,
    plan = plan,
    plan_audit = plan_audit,
    schema_registry = schema,
    authorization_schema = authorization_schema,
    runtime_contract = runtime,
    resource_state = resource,
    attestation = attestation,
    gates = gates,
    failed_gates = gates[!gates$Passed, , drop = FALSE],
    all_thirty_two_fatal_gates_passed = ready,
    authorization_issue_ready = ready,
    positive_authorization_issued = FALSE,
    authorization_consumed = FALSE,
    fresh_runtime_sentinel_observed = FALSE,
    response_generation_authorized_by_review = FALSE,
    execution_authorized_by_review = FALSE,
    response_generated = FALSE,
    fit_attempts = 0L,
    ConQuest_execution_attempted = FALSE,
    numeric_agreement_inspected = FALSE,
    threshold_selected = FALSE,
    confirmation_use_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE,
    next_action = "ASP-G4M-SAME-PROCESS-ISSUE-CONSUME-SENTINEL-AND-RUN"
  )
}

mfrmr_cq_atla_issue <- function(
    g4x_output_dir,
    calibration_output_dir,
    smoke_output_dir = file.path(
      dirname(g4x_output_dir), mfrmr_cq_ase_output_basename
    ),
    authorization_date = Sys.Date(),
    ordinary_tests_external_runtime_free = FALSE,
    authorize = FALSE) {
  mfrmr_cq_atla_assert(
    identical(authorize, TRUE),
    "G4L authority issuance is held without explicit same-process opt-in."
  )
  pre_review <- mfrmr_cq_atla_review(
    g4x_output_dir = g4x_output_dir,
    calibration_output_dir = calibration_output_dir,
    smoke_output_dir = smoke_output_dir,
    authorization_date = authorization_date,
    worktree_clean = FALSE,
    ordinary_tests_external_runtime_free =
      ordinary_tests_external_runtime_free
  )
  non_worktree_failure <- pre_review$failed_gates$GateId !=
    "WORKTREE_CLEAN_AT_ISSUE_REVIEW"
  mfrmr_cq_atla_assert(
    !any(non_worktree_failure),
    "G4L authority issuance is blocked by one or more fatal gates."
  )
  repository_root <- dirname(dirname(
    normalizePath(g4x_output_dir, winslash = "/", mustWork = TRUE)
  ))
  worktree <- mfrmr_cq_atla_git_worktree_review(repository_root)
  mfrmr_cq_atla_assert(
    isTRUE(worktree$clean),
    "G4L authority issuance requires an actually clean Git worktree."
  )
  review <- mfrmr_cq_atla_review(
    g4x_output_dir = g4x_output_dir,
    calibration_output_dir = calibration_output_dir,
    smoke_output_dir = smoke_output_dir,
    authorization_date = authorization_date,
    worktree_clean = worktree$clean,
    ordinary_tests_external_runtime_free =
      ordinary_tests_external_runtime_free
  )
  mfrmr_cq_atla_assert(
    isTRUE(review$authorization_issue_ready) &&
      isTRUE(review$all_thirty_two_fatal_gates_passed),
    "G4L authority issuance is blocked by one or more fatal gates."
  )
  authorization <- new.env(parent = emptyenv())
  authorization$AuthorizationContract <-
    mfrmr_cq_ach_run_authorization_contract
  authorization$AuthorizationIssuerContract <- mfrmr_cq_atla_contract
  authorization$HarnessContract <- mfrmr_cq_ach_contract
  authorization$AuthorizationIdentity <- mfrmr_cq_atla_authorization_identity
  authorization$ProcessId <- as.integer(Sys.getpid())
  authorization$OutputDir <- review$output_dir
  authorization$ExecutablePath <- review$executable_path
  authorization$AuthorizationDate <- review$authorization_date
  authorization$RunNotAfter <- review$run_not_after
  authorization$DatasetCount <- 90L
  authorization$ScheduledOutcomeRows <- 230L
  authorization$AttemptCount <- 190L
  authorization$Q61AttemptCount <- 150L
  authorization$Q121AttemptCount <- 40L
  authorization$GenerationAuthorized <- TRUE
  authorization$ExecutionAuthorized <- TRUE
  authorization$OneRunOnly <- TRUE
  authorization$Consumed <- FALSE
  authorization$ConsumedAt <- as.POSIXct(NA)
  authorization$OutputTargetAbsentAtAuthorization <- TRUE
  authorization$IncompleteTargetAbsentAtAuthorization <- TRUE
  authorization$ResultsOpened <- FALSE
  authorization$NumericAgreementInspected <- FALSE
  authorization$ConfirmationOrPublicUsePermitted <- FALSE
  authorization$FreshSentinelRequiredAfterConsumption <- TRUE
  authorization$SourceTreeClean <- worktree$clean
  authorization$OrdinaryTestsExternalRuntimeFree <- TRUE
  authorization$AuthorizationIssuedByP4 <- FALSE
  class(authorization) <- "mfrmr_cq_ach_run_once_authorization"
  mfrmr_cq_atla_assert(
    setequal(
      ls(authorization, all.names = TRUE),
      mfrmr_cq_ach_authorization_schema()$Field
    ),
    "G4L issued an authority that differs from the P4 consumer schema."
  )
  authorization
}
