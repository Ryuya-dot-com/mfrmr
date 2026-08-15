# Repository-only minimum ConQuest diagnostic-authorization contract.
#
# This contract separates a narrow pre-execution fatal-gate audit from an
# independent post-output evidence review. A maintainer may authorize only the
# exact sealed P2 diagnostic slice after declaring author overlap. Independence
# remains mandatory before evidence promotion, widening, confirmation, or a
# public claim. Sourcing this file has no side effects and never launches an
# external process.

mfrmr_cq_mda_specification <-
  "0.2.3-conquest-minimum-diagnostic-authorization-v1"
mfrmr_cq_mda_contract <-
  "mfrmr_conquest_minimum_diagnostic_authorization_v1"
mfrmr_cq_mda_execution_identity <-
  "mfrmr-0.2.3-conquest-p2-minimum-diagnostic-001"

mfrmr_cq_mda_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_mda_require_contracts <- function() {
  target <- environment(mfrmr_cq_mda_require_contracts)
  required <- c(
    "mfrmr_cq_srp_failure_registry", "mfrmr_cq_ssr_validate",
    "mfrmr_cq_ssr_registry", "mfrmr_cq_p2_fixture_registry",
    "mfrmr_cq_p2_review", "mfrmr_cq_ptf_budget_registry",
    "mfrmr_cq_p2m_review"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- c(
    exists("mfrmr_cq_srp_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_srp_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_semantic_runtime_preflight_v1"
      ),
    exists("mfrmr_cq_ssr_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_ssr_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_successor_semantic_registry_v1"
      ),
    exists("mfrmr_cq_p2_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_additive_adversarial_fixtures_v1"
      ),
    exists("mfrmr_cq_p2m_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2m_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_metric_boundary_contract_v1"
      ),
    exists("mfrmr_cq_ptf_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_ptf_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_prospective_tolerance_table_v1"
      )
  )
  mfrmr_cq_mda_assert(
    all(available) && all(identity),
    paste(
      "Source the exact runtime, successor-registry, P2 fixture, tolerance,",
      "and P2 metric contracts before the minimum diagnostic authorization."
    )
  )
  invisible(TRUE)
}

mfrmr_cq_mda_review_tier_registry <- function() {
  data.frame(
    ReviewTier = c(
      "minimum_preexecution_fatal_gate_audit",
      "independent_postoutput_evidence_review"
    ),
    PermittedReviewer = c(
      "maintainer_or_independent_reviewer_with_author_overlap_declared",
      "reviewer_independent_of_artifact_authorship_and_execution_adjudication"
    ),
    Timing = c("before_first_diagnostic_fit", "after_complete_slice_classification"),
    RequiredScope = c(
      paste0(
        "runtime_semantics;C1_identity;fixture_and_metric_contracts;exact_",
        "slice;empty_output_boundary;offline_tests;clean_tree;execution_cap"
      ),
      paste0(
        "transcripts;native_outputs;A_C_orientation;raw_tokens;q_states;",
        "complete_denominator;failure_classification;claim_ceiling"
      )
    ),
    BlocksSmallestDiagnosticExecution = c(TRUE, FALSE),
    BlocksEvidencePromotion = TRUE,
    BlocksWiderExecution = TRUE,
    BlocksPublicClaim = TRUE,
    CanInferScientificEquivalence = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_mda_slice_registry <- function() {
  mfrmr_cq_mda_require_contracts()
  registry <- mfrmr_cq_ssr_registry()
  fixtures <- mfrmr_cq_p2_fixture_registry()
  id <- c(
    "P2-RSM-CONNECTED-MULTIBRIDGE",
    "P2-PCM-CONNECTED-MULTIBRIDGE"
  )
  selected <- registry[match(id, registry$RegistryRowId), , drop = FALSE]
  mfrmr_cq_mda_assert(
    !anyNA(selected$RegistryRowId) &&
      identical(selected$RegistryRowId, id) &&
      all(selected$Priority == "P2") &&
      all(selected$ExpectedDisposition == "prospective_numeric_comparison") &&
      all(selected$DesignCase ==
        "connected_sparse_multiple_independent_bridges") &&
      all(selected$IntegrationNodeLadder == "31;61") &&
      all(selected$ExpectedOutputCount == 8L),
    "The frozen minimum P2 slice no longer matches the successor registry."
  )
  fixture_id <- vapply(
    fixtures[id], `[[`, character(1L), "SemanticFixtureId"
  )
  data.frame(
    ExecutionIdentity = mfrmr_cq_mda_execution_identity,
    Sequence = seq_along(id),
    RegistryRowId = id,
    SemanticFixtureId = unname(fixture_id),
    Family = selected$Family,
    DesignCase = selected$DesignCase,
    IntegrationNodeLadder = selected$IntegrationNodeLadder,
    ExpectedFreeDimension = selected$ExpectedFreeDimension,
    ExpectedNativeOutputsPerFit = selected$ExpectedOutputCount,
    ConQuestFits = 2L,
    MfrmrFits = 2L,
    DiagnosticPurpose = c(
      "exercise_connected_sparse_shared_step_runtime_and_parser_path",
      "exercise_connected_sparse_criterion_step_runtime_and_parser_path"
    ),
    EvidencePromotionAuthorized = FALSE,
    WiderExecutionAuthorized = FALSE,
    P3ExecutionAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_mda_fatal_gate_registry <- function() {
  data.frame(
    GateId = c(
      "CURRENT_RUNTIME_SEMANTIC_SENTINEL",
      "RUNTIME_NOT_EXPIRED_ON_AUTHORIZATION_DATE",
      "EXPLICIT_EXECUTABLE_PATH_MATCH",
      "P1_SEMANTIC_AND_NEGATIVE_CONTROL_CONSTRUCTION",
      "P2_FIXTURE_MATRIX_AND_ORACLE_CONSTRUCTION",
      "P2_METRIC_DENOMINATOR_AND_STOP_CONSTRUCTION",
      "EXACT_TWO_ROW_SLICE_IDENTITY",
      "CANDIDATE_OUTPUT_BOUNDARY_EMPTY",
      "ORDINARY_TESTS_EXTERNAL_RUNTIME_FREE",
      "WORKTREE_CLEAN_BEFORE_EXECUTION",
      "EXACT_Q_AND_FIT_CAP_ACCEPTED",
      "AUDITOR_IDENTITY_PRESENT",
      "AUTHOR_OVERLAP_EXPLICITLY_DECLARED",
      "NO_INTERPRETIVE_CLAIM_ACCEPTED",
      "MINIMUM_FATAL_GATE_CHECKLIST_COMPLETED"
    ),
    EvidenceClass = c(
      "live_data_free_runtime_result", "live_data_free_runtime_result",
      "explicit_invocation_binding", "repository_contract_review",
      "repository_contract_review", "repository_contract_review",
      "frozen_slice_registry", "isolated_output_directory_check",
      "ordinary_test_dependency_review", "version_control_status",
      "frozen_execution_cap", "maintainer_attestation",
      "maintainer_attestation", "maintainer_attestation",
      "maintainer_attestation"
    ),
    FailureOutcome = c(
      "semantic_execution_failure", "runtime_unavailable_or_expired",
      "semantic_execution_failure", rep("model_identity_mismatch", 3L),
      "model_identity_mismatch", "implementation_defect",
      "implementation_defect", "implementation_defect",
      "implementation_defect", rep("unknown", 4L)
    ),
    BlocksSmallestDiagnosticExecution = TRUE,
    BlocksEvidencePromotion = TRUE,
    CanBeWaivedForExpiryPressure = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_mda_attestation_template <- function() {
  data.frame(
    AuditId = "mfrmr-0.2.3-conquest-p2-minimum-audit-001",
    AuditorId = "",
    ReviewerRole = "maintainer",
    AuthorOverlapDeclared = NA,
    FatalGateChecklistCompleted = FALSE,
    ExactSliceAndCapAccepted = FALSE,
    NoInterpretiveClaimAccepted = FALSE,
    AuditDate = as.Date(NA),
    IndependentComprehensiveReviewPassed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_mda_attestation <- function(
    auditor_id, reviewer_role = "maintainer", author_overlap_declared,
    fatal_gate_checklist_completed, exact_slice_and_cap_accepted,
    no_interpretive_claim_accepted, audit_date = Sys.Date()) {
  reviewer_role <- as.character(reviewer_role)[1L]
  mfrmr_cq_mda_assert(
    reviewer_role %in% c("maintainer", "independent_reviewer"),
    "The minimum audit reviewer role must be maintainer or independent_reviewer."
  )
  data.frame(
    AuditId = "mfrmr-0.2.3-conquest-p2-minimum-audit-001",
    AuditorId = trimws(as.character(auditor_id)[1L]),
    ReviewerRole = reviewer_role,
    AuthorOverlapDeclared = as.logical(author_overlap_declared)[1L],
    FatalGateChecklistCompleted =
      as.logical(fatal_gate_checklist_completed)[1L],
    ExactSliceAndCapAccepted = as.logical(exact_slice_and_cap_accepted)[1L],
    NoInterpretiveClaimAccepted =
      as.logical(no_interpretive_claim_accepted)[1L],
    AuditDate = as.Date(audit_date)[1L],
    IndependentComprehensiveReviewPassed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_mda_construction_review <- function() {
  mfrmr_cq_mda_require_contracts()
  semantic <- mfrmr_cq_ssr_validate()
  fixture <- mfrmr_cq_p2_review(run_continuous_oracles = FALSE)
  metric <- mfrmr_cq_p2m_review()
  slice <- mfrmr_cq_mda_slice_registry()
  fixtures <- mfrmr_cq_p2_fixture_registry()
  same_data <- identical(
    fixtures[[slice$RegistryRowId[1L]]]$Data,
    fixtures[[slice$RegistryRowId[2L]]]$Data
  )
  slice_ready <- nrow(slice) == 2L &&
    identical(slice$Family, c("RSM", "PCM")) &&
    all(slice$IntegrationNodeLadder == "31;61") &&
    sum(slice$ConQuestFits) == 4L && sum(slice$MfrmrFits) == 4L &&
    same_data && !any(slice$EvidencePromotionAuthorized) &&
    !any(slice$WiderExecutionAuthorized) &&
    !any(slice$P3ExecutionAuthorized) &&
    !any(slice$ScientificEquivalenceInferred)
  review_tiers <- mfrmr_cq_mda_review_tier_registry()
  tiers_ready <- nrow(review_tiers) == 2L &&
    review_tiers$BlocksSmallestDiagnosticExecution[1L] &&
    !review_tiers$BlocksSmallestDiagnosticExecution[2L] &&
    all(review_tiers$BlocksEvidencePromotion) &&
    all(review_tiers$BlocksWiderExecution) &&
    all(review_tiers$BlocksPublicClaim) &&
    !any(review_tiers$CanInferScientificEquivalence)
  fatal <- mfrmr_cq_mda_fatal_gate_registry()
  fatal_ready <- nrow(fatal) == 15L &&
    all(fatal$BlocksSmallestDiagnosticExecution) &&
    all(fatal$BlocksEvidencePromotion) &&
    !any(fatal$CanBeWaivedForExpiryPressure) &&
    !any(fatal$ScientificEquivalenceInferred)
  construction_ready <- isTRUE(semantic$semantic_signature_ready) &&
    isTRUE(semantic$negative_controls_ready) &&
    isTRUE(fixture$fixture_contract_ready) &&
    isTRUE(metric$metric_specific_rules_frozen) &&
    isTRUE(metric$complete_denominator_frozen) &&
    isTRUE(metric$stop_and_expansion_rules_frozen) &&
    slice_ready && tiers_ready && fatal_ready
  list(
    specification = mfrmr_cq_mda_specification,
    contract_version = mfrmr_cq_mda_contract,
    status = if (construction_ready) {
      "minimum_diagnostic_contract_ready_runtime_and_attestation_unbound"
    } else {
      "minimum_diagnostic_contract_invalid"
    },
    semantic_registry = semantic,
    fixture_contract = fixture,
    metric_contract = metric,
    slice = slice,
    review_tiers = review_tiers,
    fatal_gates = fatal,
    semantic_construction_ready = isTRUE(
      semantic$semantic_signature_ready && semantic$negative_controls_ready
    ),
    P2_fixture_construction_ready = isTRUE(fixture$fixture_contract_ready),
    P2_metric_construction_ready = isTRUE(
      metric$metric_specific_rules_frozen &&
        metric$complete_denominator_frozen &&
        metric$stop_and_expansion_rules_frozen
    ),
    exact_slice_frozen = slice_ready,
    review_tiers_frozen = tiers_ready,
    fatal_gate_definitions_frozen = fatal_ready,
    all_construction_layers_ready = construction_ready,
    current_runtime_bound = FALSE,
    minimum_audit_attested = FALSE,
    smallest_P2_diagnostic_execution_authorized = FALSE,
    independent_comprehensive_review_passed = FALSE,
    evidence_promotion_authorized = FALSE,
    wider_execution_authorized = FALSE,
    P3_execution_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}

mfrmr_cq_mda_runtime_review <- function(
    runtime_preflight, explicit_executable_path, authorization_date,
    maximum_preflight_age_days = 1L) {
  authorization_date <- as.Date(authorization_date)[1L]
  maximum_preflight_age_days <- as.integer(maximum_preflight_age_days)[1L]
  valid_shape <- is.list(runtime_preflight) &&
    is.data.frame(runtime_preflight$summary) &&
    nrow(runtime_preflight$summary) == 1L
  if (!valid_shape) {
    return(list(
      SemanticCurrent = FALSE, NotExpired = FALSE,
      ExplicitPathMatch = FALSE, Failure = "runtime_preflight_missing_or_invalid"
    ))
  }
  summary <- runtime_preflight$summary
  required <- c(
    "Specification", "ContractVersion", "Status", "ExecutablePath",
    "RunDate", "ExpiryDate", "ExpiredByDate", "RegisteredFailureCount",
    "ModelEstimationAttempted", "SemanticSuccess",
    "ScientificComparisonAuthorized"
  )
  if (!all(required %in% names(summary)) || is.na(authorization_date) ||
      !is.finite(maximum_preflight_age_days) || maximum_preflight_age_days < 0L) {
    return(list(
      SemanticCurrent = FALSE, NotExpired = FALSE,
      ExplicitPathMatch = FALSE, Failure = "runtime_preflight_schema_invalid"
    ))
  }
  run_date <- as.Date(summary$RunDate)[1L]
  expiry_date <- as.Date(summary$ExpiryDate)[1L]
  age <- as.integer(authorization_date - run_date)
  explicit_path <- as.character(explicit_executable_path)[1L]
  path_match <- length(explicit_path) == 1L && !is.na(explicit_path) &&
    nzchar(explicit_path) && identical(
      as.character(summary$ExecutablePath)[1L], explicit_path
    )
  semantic_current <- identical(
    as.character(summary$Specification)[1L], mfrmr_cq_srp_specification
  ) && identical(
    as.character(summary$ContractVersion)[1L], mfrmr_cq_srp_contract
  ) && identical(as.character(summary$Status)[1L], "runtime_semantic_ready") &&
    isTRUE(summary$SemanticSuccess) &&
    identical(as.integer(summary$RegisteredFailureCount), 0L) &&
    identical(summary$ModelEstimationAttempted, FALSE) &&
    identical(summary$ScientificComparisonAuthorized, FALSE) &&
    !is.na(run_date) && age >= 0L && age <= maximum_preflight_age_days
  not_expired <- !is.na(expiry_date) && authorization_date <= expiry_date &&
    !isTRUE(summary$ExpiredByDate)
  list(
    SemanticCurrent = semantic_current,
    NotExpired = not_expired,
    ExplicitPathMatch = path_match,
    RunDate = run_date,
    AuthorizationDate = authorization_date,
    PreflightAgeDays = age,
    ExpiryDate = expiry_date,
    Failure = if (semantic_current && not_expired && path_match) "" else {
      "runtime_current_expiry_or_path_gate_failed"
    }
  )
}

mfrmr_cq_mda_assess <- function(
    runtime_preflight,
    explicit_executable_path,
    attestation = mfrmr_cq_mda_attestation_template(),
    authorization_date = Sys.Date(),
    requested_registry_rows = mfrmr_cq_mda_slice_registry()$RegistryRowId,
    requested_node_ladder = "31;61",
    requested_conquest_fits = 4L,
    requested_mfrmr_fits = 4L,
    candidate_outputs_absent = FALSE,
    ordinary_tests_external_runtime_free = FALSE,
    worktree_clean = FALSE,
    maximum_preflight_age_days = 1L) {
  construction <- mfrmr_cq_mda_construction_review()
  runtime <- mfrmr_cq_mda_runtime_review(
    runtime_preflight, explicit_executable_path, authorization_date,
    maximum_preflight_age_days
  )
  slice <- construction$slice
  exact_slice <- identical(
    as.character(requested_registry_rows), slice$RegistryRowId
  )
  exact_cap <- identical(as.character(requested_node_ladder)[1L], "31;61") &&
    identical(as.integer(requested_conquest_fits)[1L], 4L) &&
    identical(as.integer(requested_mfrmr_fits)[1L], 4L)
  required_attestation <- names(mfrmr_cq_mda_attestation_template())
  attestation_shape <- is.data.frame(attestation) && nrow(attestation) == 1L &&
    all(required_attestation %in% names(attestation))
  if (!attestation_shape) attestation <- mfrmr_cq_mda_attestation_template()
  auditor_present <- nzchar(trimws(as.character(attestation$AuditorId)[1L]))
  overlap_declared <- !is.na(attestation$AuthorOverlapDeclared[1L])
  no_claim <- isTRUE(attestation$NoInterpretiveClaimAccepted[1L]) &&
    !isTRUE(attestation$IndependentComprehensiveReviewPassed[1L])
  gate_passed <- c(
    runtime$SemanticCurrent,
    runtime$NotExpired,
    runtime$ExplicitPathMatch,
    construction$semantic_construction_ready,
    construction$P2_fixture_construction_ready,
    construction$P2_metric_construction_ready,
    exact_slice,
    isTRUE(candidate_outputs_absent),
    isTRUE(ordinary_tests_external_runtime_free),
    isTRUE(worktree_clean),
    exact_cap && isTRUE(attestation$ExactSliceAndCapAccepted[1L]),
    auditor_present,
    overlap_declared,
    no_claim,
    isTRUE(attestation$FatalGateChecklistCompleted[1L])
  )
  definitions <- mfrmr_cq_mda_fatal_gate_registry()
  gates <- definitions
  gates$Passed <- as.logical(gate_passed)
  gates$ObservedState <- ifelse(gates$Passed, "pass", "blocked")
  all_pass <- isTRUE(construction$all_construction_layers_ready) &&
    all(gates$Passed)
  list(
    specification = mfrmr_cq_mda_specification,
    contract_version = mfrmr_cq_mda_contract,
    execution_identity = mfrmr_cq_mda_execution_identity,
    status = if (all_pass) {
      "smallest_P2_diagnostic_execution_authorized_no_evidence_promotion"
    } else {
      "minimum_diagnostic_authorization_blocked"
    },
    construction_review = construction,
    runtime_review = runtime,
    attestation = attestation,
    requested_registry_rows = as.character(requested_registry_rows),
    gates = gates,
    failed_gates = gates[!gates$Passed, , drop = FALSE],
    minimum_audit_attested = all_pass,
    maintainer_self_audit_permitted_when_overlap_declared = TRUE,
    smallest_P2_diagnostic_execution_authorized = all_pass,
    P0_closed = FALSE,
    P1_closed = FALSE,
    independent_comprehensive_review_passed = FALSE,
    evidence_promotion_authorized = FALSE,
    wider_execution_authorized = FALSE,
    P3_execution_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
