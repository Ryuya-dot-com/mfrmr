# Repository-only live authorization for the candidate-004 ConQuest slice.
#
# It binds a fresh data-free runtime sentinel and disclosed same-author minimum
# audit to exactly four q61/q121 ConQuest fits. It launches nothing and authorizes no
# evidence promotion, wider execution, P3 work, or public claim.

mfrmr_cq_p2c4a_specification <-
  "0.2.3-conquest-p2-candidate-004-live-authorization-v1"
mfrmr_cq_p2c4a_contract <-
  "mfrmr_conquest_p2_candidate_004_live_authorization_v1"
mfrmr_cq_p2c4a_execution_identity <-
  "mfrmr-0.2.3-conquest-p2-dense-pair-004-external-001"
mfrmr_cq_p2c4a_observation_date <- as.Date("2026-08-15")
mfrmr_cq_p2c4a_run_not_after <- as.Date("2026-08-16")
mfrmr_cq_p2c4a_executable_path <- "/Applications/ConQuest/ConQuest"
mfrmr_cq_p2c4a_output_basename <-
  "conquest-p2-candidate-004-external-20260815-v1"

mfrmr_cq_p2c4a_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2c4a_require_contracts <- function() {
  target <- environment(mfrmr_cq_p2c4a_require_contracts)
  ready <- exists("mfrmr_cq_srp_contract", envir = target, inherits = TRUE) &&
    identical(
      get("mfrmr_cq_srp_contract", envir = target, inherits = TRUE),
      "mfrmr_conquest_semantic_runtime_preflight_v1"
    ) && exists(
      "mfrmr_cq_srp_assess", envir = target, mode = "function", inherits = TRUE
    ) && exists(
      "mfrmr_cq_p2c4po_contract", envir = target, inherits = TRUE
    ) && identical(
      get("mfrmr_cq_p2c4po_contract", envir = target, inherits = TRUE),
      "mfrmr_conquest_p2_candidate_004_mfrmr_preflight_observation_v1"
    ) && exists(
      "mfrmr_cq_p2c4po_review", envir = target, mode = "function",
      inherits = TRUE
    )
  mfrmr_cq_p2c4a_assert(
    ready, "Source the exact runtime and candidate-004 preflight observations."
  )
  invisible(TRUE)
}

mfrmr_cq_p2c4a_runtime_observation <- function() {
  mfrmr_cq_p2c4a_require_contracts()
  mfrmr_cq_srp_assess(
    console_lines = c(
      "ConQuest version: 5.47.5",
      "Demonstration Version",
      "This version expires 1 September 2026",
      "<End of Program"
    ),
    exit_status = 0L,
    executable_path = mfrmr_cq_p2c4a_executable_path,
    executable_available = TRUE,
    executable = TRUE,
    launcher_available = TRUE,
    architecture = paste0(
      mfrmr_cq_p2c4a_executable_path,
      ": Mach-O 64-bit executable x86_64"
    ),
    invocation_route = paste(
      "/usr/bin/arch -x86_64", shQuote(mfrmr_cq_p2c4a_executable_path)
    ),
    locale = "C.UTF-8/C.UTF-8/C.UTF-8/C/C.UTF-8/C.UTF-8",
    run_date = mfrmr_cq_p2c4a_observation_date,
    command_is_data_free_quit = TRUE
  )
}

mfrmr_cq_p2c4a_slice_registry <- function() {
  family <- rep(c("RSM", "PCM"), each = 2L)
  nodes <- rep(c(61L, 121L), times = 2L)
  data.frame(
    ExecutionIdentity = mfrmr_cq_p2c4a_execution_identity,
    Sequence = seq_along(nodes),
    CandidateId = mfrmr_cq_p2c4p_candidate_id,
    Family = family,
    Nodes = nodes,
    ExpectedFreeDimension = rep(c(10L, 14L), each = 2L),
    ExpectedNativeOutputCount = 8L,
    ConQuestFitCap = 1L,
    NewMfrmrFitCap = 0L,
    SharedCandidateData = TRUE,
    EvidencePromotionAuthorized = FALSE,
    WiderExecutionAuthorized = FALSE,
    P3ExecutionAuthorized = FALSE,
    PublicClaimAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4a_fatal_gate_registry <- function() {
  data.frame(
    GateId = c(
      "CURRENT_RUNTIME_SEMANTIC_SENTINEL",
      "RUNTIME_NOT_EXPIRED_ON_AUTHORIZATION_DATE",
      "EXPLICIT_EXECUTABLE_PATH_MATCH",
      "CANDIDATE_004_FIXTURE_QUALIFIED",
      "CANDIDATE_004_MFRMR_PREFLIGHT_CONSUMED_PASS",
      "Q121_DENSE_AND_CONTINUOUS_TARGET_SELECTED",
      "EXACT_FOUR_ARM_Q61_Q121_SLICE",
      "CANDIDATE_OUTPUT_BOUNDARY_EMPTY",
      "RETAINED_MFRMR_PREFLIGHT_ARTIFACTS_READY",
      "ORDINARY_TESTS_EXTERNAL_RUNTIME_FREE",
      "WORKTREE_CLEAN_BEFORE_BUNDLE_PREPARATION",
      "EXACT_EXTERNAL_FIT_CAP_ACCEPTED",
      "AUDITOR_IDENTITY_AND_AUTHOR_OVERLAP_DECLARED",
      "NO_INTERPRETIVE_CLAIM_ACCEPTED",
      "MINIMUM_FATAL_GATE_CHECKLIST_COMPLETED"
    ),
    FailureOutcome = c(
      "semantic_execution_failure", "runtime_unavailable_or_expired",
      "semantic_execution_failure", "model_identity_mismatch",
      "mfrmr_optimizer_or_readiness_review", "integration_unresolved",
      "model_identity_mismatch", "implementation_defect",
      "implementation_defect", "implementation_defect",
      "implementation_defect", "implementation_defect",
      "unknown", "unknown", "unknown"
    ),
    BlocksCandidate004Execution = TRUE,
    BlocksEvidencePromotion = TRUE,
    CanBeWaivedForExpiryPressure = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4a_attestation <- function() {
  data.frame(
    AuditId = "mfrmr-0.2.3-conquest-p2-candidate-004-minimum-audit-001",
    AuditorId = "Codex maintainer audit 2026-08-15",
    ReviewerRole = "maintainer",
    AuthorOverlapDeclared = TRUE,
    ExactSliceAndCapAccepted = TRUE,
    NoInterpretiveClaimAccepted = TRUE,
    FatalGateChecklistCompleted = TRUE,
    IndependentComprehensiveReviewPassed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4a_review <- function(
    output_dir,
    authorization_date = mfrmr_cq_p2c4a_observation_date,
    preflight_artifacts_ready = TRUE,
    ordinary_tests_external_runtime_free = TRUE,
    worktree_clean = TRUE) {
  mfrmr_cq_p2c4a_require_contracts()
  authorization_date <- as.Date(authorization_date)[1L]
  runtime <- mfrmr_cq_p2c4a_runtime_observation()
  summary <- runtime$summary
  preflight <- mfrmr_cq_p2c4po_review()
  slice <- mfrmr_cq_p2c4a_slice_registry()
  attestation <- mfrmr_cq_p2c4a_attestation()
  output_dir <- normalizePath(
    as.character(output_dir)[1L], winslash = "/", mustWork = FALSE
  )
  runtime_current <- identical(summary$Status, "runtime_semantic_ready") &&
    isTRUE(summary$SemanticSuccess) &&
    identical(summary$RegisteredFailureCount, 0L) &&
    !isTRUE(summary$ModelEstimationAttempted) &&
    as.Date(summary$RunDate) == mfrmr_cq_p2c4a_observation_date &&
    authorization_date >= mfrmr_cq_p2c4a_observation_date &&
    authorization_date <= mfrmr_cq_p2c4a_run_not_after
  not_expired <- !isTRUE(summary$ExpiredByDate) &&
    authorization_date <= as.Date(summary$ExpiryDate)
  path_match <- identical(
    as.character(summary$ExecutablePath), mfrmr_cq_p2c4a_executable_path
  )
  fixture_ready <- identical(
    preflight$status,
    "candidate_004_mfrmr_preflight_passed_external_review_required"
  )
  preflight_ready <- isTRUE(
    preflight$eligible_for_new_external_authorization_review
  ) && !isTRUE(preflight$external_execution_authorized)
  q121_selected <- isTRUE(preflight$dense_pair_1_selected) &&
    !isTRUE(preflight$q241_attempted) &&
    identical(preflight$stage_selection$selected_upper_nodes, 121L)
  exact_slice <- nrow(slice) == 4L &&
    identical(slice$Family, c("RSM", "RSM", "PCM", "PCM")) &&
    identical(slice$Nodes, c(61L, 121L, 61L, 121L)) &&
    identical(slice$ExpectedFreeDimension, c(10L, 10L, 14L, 14L)) &&
    sum(slice$ConQuestFitCap) == 4L &&
    sum(slice$NewMfrmrFitCap) == 0L &&
    all(slice$SharedCandidateData)
  output_empty <- identical(
    basename(output_dir), mfrmr_cq_p2c4a_output_basename
  ) && !file.exists(output_dir) && !dir.exists(output_dir)
  attested <- nzchar(attestation$AuditorId) &&
    isTRUE(attestation$AuthorOverlapDeclared) &&
    isTRUE(attestation$ExactSliceAndCapAccepted) &&
    isTRUE(attestation$NoInterpretiveClaimAccepted) &&
    isTRUE(attestation$FatalGateChecklistCompleted) &&
    !isTRUE(attestation$IndependentComprehensiveReviewPassed)
  gate_passed <- c(
    runtime_current, not_expired, path_match, fixture_ready, preflight_ready,
    q121_selected, exact_slice, output_empty,
    isTRUE(preflight_artifacts_ready),
    isTRUE(ordinary_tests_external_runtime_free), isTRUE(worktree_clean),
    sum(slice$ConQuestFitCap) == 4L && sum(slice$NewMfrmrFitCap) == 0L,
    nzchar(attestation$AuditorId) && isTRUE(attestation$AuthorOverlapDeclared),
    isTRUE(attestation$NoInterpretiveClaimAccepted),
    isTRUE(attestation$FatalGateChecklistCompleted)
  )
  gates <- mfrmr_cq_p2c4a_fatal_gate_registry()
  gates$Passed <- gate_passed
  gates$ObservedState <- ifelse(gates$Passed, "pass", "blocked")
  within_live_window <- !is.na(authorization_date) &&
    authorization_date >= mfrmr_cq_p2c4a_observation_date &&
    authorization_date <= mfrmr_cq_p2c4a_run_not_after
  authorized <- within_live_window && attested && all(gates$Passed)
  list(
    specification = mfrmr_cq_p2c4a_specification,
    contract_version = mfrmr_cq_p2c4a_contract,
    execution_identity = mfrmr_cq_p2c4a_execution_identity,
    status = if (authorized) {
      "candidate_004_four_arm_q61_q121_live_authorization_active"
    } else {
      "candidate_004_external_authorization_blocked"
    },
    observation_date = mfrmr_cq_p2c4a_observation_date,
    run_not_after = mfrmr_cq_p2c4a_run_not_after,
    authorization_date = authorization_date,
    executable_path = mfrmr_cq_p2c4a_executable_path,
    output_dir = output_dir,
    runtime_observation = runtime,
    preflight_observation = preflight,
    slice = slice,
    attestation = attestation,
    gates = gates,
    failed_gates = gates[!gates$Passed, , drop = FALSE],
    all_fifteen_fatal_gates_passed = all(gates$Passed),
    candidate_004_external_execution_authorized = authorized,
    new_mfrmr_fit_authorized = FALSE,
    independent_comprehensive_review_passed = FALSE,
    evidence_promotion_authorized = FALSE,
    wider_execution_authorized = FALSE,
    P3_execution_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
