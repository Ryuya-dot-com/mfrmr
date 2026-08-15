# Semantic dependency sentinel for ConQuest P2 candidate 004.
#
# This contract separates preservation of historical evidence from continued
# applicability to current source. It consumes declared semantic change
# classes, not file bytes, digests, or superficial path equality.

mfrmr_cq_p2c4ds_specification <-
  "0.2.3-conquest-p2-candidate-004-dependency-sentinel-v1"
mfrmr_cq_p2c4ds_contract <-
  "mfrmr_conquest_p2_candidate_004_dependency_sentinel_v1"

mfrmr_cq_p2c4ds_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2c4ds_registry <- function() {
  data.frame(
    ChangeClass = c(
      "likelihood_semantics", "constraint_semantics",
      "category_handling_semantics", "integration_or_optimizer_semantics",
      "external_output_parser_semantics", "coordinate_transform_semantics",
      "conquest_runtime_identity", "frozen_acceptance_contract",
      "raw_evidence_semantics", "documentation_or_test_only",
      "unknown_or_mixed"
    ),
    Trigger = c(
      "The RSM/PCM MML objective, weighting, population model, or deviance identity changes.",
      "Free-coordinate, anchoring, sum-zero, A-matrix, or parameter ownership semantics change.",
      "Score recoding, category support, step ownership, or response layout semantics change.",
      "Quadrature nodes or weights, optimizer target, convergence, polish, or selected-q semantics change.",
      "ConQuest output selection, token parsing, terminal-state parsing, or schema interpretation changes.",
      "ConQuest-to-mfrmr coordinate, variance, deviance, probability, or ordering transformation changes.",
      "The ConQuest version, edition, architecture route, expiry state, or executable semantics change.",
      "A candidate-004 frozen budget, denominator, scope, or run-once binding changes.",
      "A retained candidate-004 response, command, native output, fit object, or execution journal changes.",
      "Only prose, presentation, or tests change without changing any preceding semantics.",
      "The author cannot rule out one of the preceding semantic changes."
    ),
    HistoricalCandidateState = c(
      rep("retained_as_versioned_historical_evidence", 7L),
      "contract_integrity_incident",
      "primary_evidence_quarantined",
      "retained_as_versioned_historical_evidence",
      "retained_pending_manual_classification"
    ),
    IndependentReviewAction = c(
      rep("may_continue_only_for_explicit_historical_source_claim", 4L),
      rep("restart_from_raw_artifacts", 2L),
      "may_continue_only_for_recorded_runtime_claim",
      "block_until_contract_integrity_is_resolved",
      "block_and_quarantine_primary_evidence",
      "no_scientific_reset",
      "block_until_manually_classified"
    ),
    CurrentSourceAction = c(
      rep("detach_current_source_claim_and_require_successor", 4L),
      rep("recompute_from_raw_before_review", 2L),
      "require_new_runtime_sentinel_and_successor_for_new_runtime_claim",
      "do_not_rewrite_frozen_candidate_post_output",
      "do_not_repair_or_rerun_candidate_004",
      "no_scientific_reset",
      "manual_dependency_review_required"
    ),
    Candidate004RerunAuthorized = FALSE,
    PublicClaimAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4ds_declaration_template <- function() {
  registry <- mfrmr_cq_p2c4ds_registry()
  data.frame(
    ChangeClass = registry$ChangeClass,
    Changed = FALSE,
    Rationale = "",
    Reviewer = "",
    ReviewDate = "",
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4ds_review <- function(change_classes = character()) {
  registry <- mfrmr_cq_p2c4ds_registry()
  change_classes <- unique(as.character(change_classes))
  mfrmr_cq_p2c4ds_assert(
    !anyNA(change_classes) && all(nzchar(change_classes)),
    "Declared change classes must be non-missing names."
  )
  unknown <- setdiff(change_classes, registry$ChangeClass)
  mfrmr_cq_p2c4ds_assert(
    length(unknown) == 0L,
    paste0("Unknown semantic change class: ", paste(unknown, collapse = ", "))
  )

  model_change <- any(change_classes %in% c(
    "likelihood_semantics", "constraint_semantics",
    "category_handling_semantics", "integration_or_optimizer_semantics"
  ))
  reviewer_change <- any(change_classes %in% c(
    "external_output_parser_semantics", "coordinate_transform_semantics"
  ))
  runtime_change <- "conquest_runtime_identity" %in% change_classes
  contract_change <- "frozen_acceptance_contract" %in% change_classes
  raw_change <- "raw_evidence_semantics" %in% change_classes
  manual <- "unknown_or_mixed" %in% change_classes
  documentation_only <- length(change_classes) > 0L && all(
    change_classes == "documentation_or_test_only"
  )

  disposition <- if (raw_change) {
    "raw_evidence_incident_review_blocked"
  } else if (contract_change) {
    "frozen_contract_mutation_review_blocked"
  } else if (manual) {
    "manual_dependency_classification_required"
  } else if (model_change) {
    "current_source_claim_detached_successor_required"
  } else if (runtime_change) {
    "new_runtime_sentinel_and_successor_required"
  } else if (reviewer_change) {
    "independent_review_restart_from_raw_required"
  } else if (documentation_only) {
    "documentation_or_test_only_no_scientific_reset"
  } else {
    "no_declared_semantic_change"
  }

  blocking_review_change <- raw_change || contract_change || manual
  list(
    specification = mfrmr_cq_p2c4ds_specification,
    contract_version = mfrmr_cq_p2c4ds_contract,
    disposition = disposition,
    declared_change_classes = change_classes,
    historical_candidate_record_retained = TRUE,
    historical_primary_evidence_usable = !raw_change,
    independent_review_blocked = blocking_review_change,
    independent_review_restart_from_raw_required = reviewer_change,
    historical_scope_label_required = model_change || runtime_change,
    current_source_claim_attached = !(model_change || runtime_change),
    successor_candidate_required_for_current_claim = model_change || runtime_change,
    new_runtime_sentinel_required = runtime_change,
    frozen_contract_integrity_review_required = contract_change,
    raw_evidence_quarantine_required = raw_change,
    manual_dependency_review_required = manual,
    candidate_004_rerun_authorized = FALSE,
    wider_execution_authorized = FALSE,
    P3_execution_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}

mfrmr_cq_p2c4ds_plan <- function() {
  list(
    specification = mfrmr_cq_p2c4ds_specification,
    contract_version = mfrmr_cq_p2c4ds_contract,
    status = "candidate_004_semantic_dependency_sentinel_frozen",
    registry = mfrmr_cq_p2c4ds_registry(),
    declaration_template = mfrmr_cq_p2c4ds_declaration_template(),
    byte_identity_is_scientific_gate = FALSE,
    path_change_alone_is_scientific_decision = FALSE,
    semantic_change_declaration_required = TRUE,
    candidate_004_rerun_authorized = FALSE,
    public_claim_authorized = FALSE
  )
}
