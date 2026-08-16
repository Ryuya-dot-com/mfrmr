# Fail-closed ASP-G4N diagnostic-numeric-eligibility addendum.
#
# This contract separates exploratory technical use of a completed numerical
# result from the package's inferential readiness decision. It neither reads
# estimates nor changes a retained terminal code, readiness state, reason code,
# seed, DGP, workload, attempt order, denominator, or execution authority.

mfrmr_cq_adne_specification <-
  "0.2.3-conquest-adversarial-simulation-diagnostic-numeric-eligibility-addendum-v1"
mfrmr_cq_adne_contract <-
  "mfrmr_conquest_adversarial_simulation_diagnostic_numeric_eligibility_addendum_v1"

mfrmr_cq_adne_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_adne_require_contracts <- function() {
  target <- environment(mfrmr_cq_adne_require_contracts)
  required <- c(
    "mfrmr_cq_amcr_review", "mfrmr_cq_amcr_readiness_audit",
    "mfrmr_cq_ameh_review_execution", "mfrmr_cq_acf_failure_taxonomy",
    "mfrmr_cq_asp_metric_registry", "mfrmr_cq_acf_summary_registry"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- exists(
    "mfrmr_cq_amcr_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_amcr_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_adversarial_simulation_post_mechanics_calibration_review_v1"
  )
  mfrmr_cq_adne_assert(
    all(available) && identity,
    "Source the complete G4R dependency chain before the G4N addendum."
  )
  invisible(TRUE)
}

mfrmr_cq_adne_split_codes <- function(value) {
  value <- as.character(value)
  value <- value[!is.na(value) & nzchar(value)]
  if (length(value) == 0L) return(character(0))
  unique(trimws(unlist(strsplit(value, ";", fixed = TRUE))))
}

mfrmr_cq_adne_empty_code <- function(value) {
  value <- as.character(value)[1L]
  is.na(value) || !nzchar(trimws(value))
}

mfrmr_cq_adne_exact_codes <- function(observed, expected) {
  observed <- mfrmr_cq_adne_split_codes(observed)
  expected <- unique(as.character(expected))
  identical(sort(observed), sort(expected))
}

mfrmr_cq_adne_allowed_rank_hold_registry <- function() {
  data.frame(
    RepresentationClass = c("ordinary_or_planned", "explicit_missing"),
    RepresentationId = c(
      "observed_rows_only;planned_absence", "explicit_missing"
    ),
    RequiredInputState = c("pass", "review"),
    RequiredEstimabilityState = "not_evaluated",
    RequiredCategoryState = "adequate",
    RequiredBoundaryState = "finite",
    RequiredNumericalState = "ready",
    ExactAllowedReasonCodes = c(
      "design_rank_not_evaluated",
      "design_rank_not_evaluated;input_review_required"
    ),
    InferenceReadyMustRemainFalse = TRUE,
    DiagnosticUseOnly = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_adne_terminal_exclusion_registry <- function() {
  mfrmr_cq_adne_require_contracts()
  taxonomy <- mfrmr_cq_acf_failure_taxonomy()
  taxonomy$DiagnosticEligibilityRule <- ifelse(
    taxonomy$TerminalCode == "complete_numeric_eligible",
    "eligible_only_if_all_common_and_engine_specific_predicates_pass",
    ifelse(
      taxonomy$TerminalCode ==
        "optimizer_nonconvergence_or_readiness_hold",
      paste(
        "ineligible_except_mfrmr_converged_rank_not_evaluated",
        "narrow_exception"
      ),
      "always_diagnostic_ineligible"
    )
  )
  taxonomy$MayBeRelabelled <- FALSE
  taxonomy$MayBeDropped <- FALSE
  taxonomy
}

mfrmr_cq_adne_required_attempt_fields <- function() {
  c(
    "Family", "Engine", "QuadratureId", "RepresentationId",
    "StructuralDispositionFromRetainedG3", "AttemptCap", "Started",
    "Completed", "AttemptCount", "ParseableResult",
    "ExpectedFreeDimension", "ObservedFreeDimension", "ModelIdentityMatch",
    "AutomaticRetryPermitted", "NumericAgreementInspected", "TerminalCode",
    "SecondaryCode", "RegisteredFailureCount", "ExitStatus",
    "TerminalMarkerObserved", "ArtifactSetComplete",
    "SemanticBridgeSatisfied"
  )
}

mfrmr_cq_adne_required_readiness_fields <- function() {
  c(
    "Model", "ICQuadraturePoints", "MMLEngineRequested", "MMLEngineUsed",
    "Converged", "ConvergenceCode", "ConvergenceStatus",
    "ConvergenceSeverity", "ReviewableWarning", "FitReadiness",
    "InferenceReady",
    "InputState", "EstimabilityState", "CategoryState", "BoundaryState",
    "NumericalState", "ReadinessReasonCodes"
  )
}

mfrmr_cq_adne_classify_attempt <- function(attempt, readiness = NULL) {
  mfrmr_cq_adne_assert(
    is.data.frame(attempt) && nrow(attempt) == 1L &&
      all(mfrmr_cq_adne_required_attempt_fields() %in% names(attempt)),
    "Diagnostic eligibility requires one complete attempt-contract row."
  )
  engine <- as.character(attempt$Engine[1L])
  family <- as.character(attempt$Family[1L])
  quadrature <- as.character(attempt$QuadratureId[1L])
  expected_family_dimension <- switch(
    family, RSM = 10L, PCM = 14L, NA_integer_
  )
  mfrmr_cq_adne_assert(
    engine %in% c("mfrmr", "ConQuest"),
    "Diagnostic eligibility received an unregistered engine."
  )
  common <- c(
    structurally_eligible = identical(
      as.character(attempt$StructuralDispositionFromRetainedG3[1L]),
      "eligible_numeric_comparison"
    ),
    frozen_family_quadrature_identity =
      family %in% c("RSM", "PCM") && quadrature %in% c("q61", "q121") &&
      identical(
        as.integer(attempt$ExpectedFreeDimension[1L]),
        expected_family_dimension
      ),
    exactly_one_completed_attempt =
      isTRUE(attempt$Started[1L]) && isTRUE(attempt$Completed[1L]) &&
      identical(as.integer(attempt$AttemptCap[1L]), 1L) &&
      identical(as.integer(attempt$AttemptCount[1L]), 1L),
    finite_parseable_result = isTRUE(attempt$ParseableResult[1L]),
    expected_dimension_observed =
      !is.na(attempt$ExpectedFreeDimension[1L]) &&
      !is.na(attempt$ObservedFreeDimension[1L]) &&
      identical(
        as.integer(attempt$ExpectedFreeDimension[1L]),
        as.integer(attempt$ObservedFreeDimension[1L])
      ),
    model_identity_match = isTRUE(attempt$ModelIdentityMatch[1L]),
    complete_registered_artifact_set =
      isTRUE(attempt$ArtifactSetComplete[1L]),
    semantic_bridge_satisfied =
      isTRUE(attempt$SemanticBridgeSatisfied[1L]),
    no_retry_or_prior_numeric_inspection =
      !isTRUE(attempt$AutomaticRetryPermitted[1L]) &&
      !isTRUE(attempt$NumericAgreementInspected[1L])
  )

  inference_before <- NA
  eligibility_mode <- "ineligible"
  engine_specific <- FALSE
  if (engine == "ConQuest") {
    engine_specific <-
      identical(
        as.character(attempt$TerminalCode[1L]),
        "complete_numeric_eligible"
      ) &&
      mfrmr_cq_adne_empty_code(attempt$SecondaryCode[1L]) &&
      identical(as.integer(attempt$RegisteredFailureCount[1L]), 0L) &&
      identical(as.integer(attempt$ExitStatus[1L]), 0L) &&
      isTRUE(attempt$TerminalMarkerObserved[1L])
    if (engine_specific) eligibility_mode <- "complete_numeric"
  } else {
    mfrmr_cq_adne_assert(
      is.data.frame(readiness) && nrow(readiness) == 1L &&
        all(mfrmr_cq_adne_required_readiness_fields() %in% names(readiness)),
      "mfrmr diagnostic eligibility requires one categorical readiness row."
    )
    inference_before <- as.logical(readiness$InferenceReady[1L])
    converged <- isTRUE(readiness$Converged[1L]) &&
      identical(as.integer(readiness$ConvergenceCode[1L]), 0L) &&
      identical(as.character(readiness$ConvergenceStatus[1L]), "converged") &&
      identical(as.character(readiness$ConvergenceSeverity[1L]), "pass") &&
      !isTRUE(readiness$ReviewableWarning[1L]) &&
      identical(as.character(readiness$Model[1L]), family) &&
      identical(
        as.integer(readiness$ICQuadraturePoints[1L]),
        as.integer(sub("^q", "", quadrature))
      ) &&
      identical(as.character(readiness$MMLEngineRequested[1L]), "direct") &&
      identical(as.character(readiness$MMLEngineUsed[1L]), "direct")
    standard_ready <- converged &&
      identical(as.character(readiness$FitReadiness[1L]), "ready") &&
      isTRUE(readiness$InferenceReady[1L]) &&
      identical(as.character(readiness$InputState[1L]), "pass") &&
      identical(as.character(readiness$EstimabilityState[1L]), "identified") &&
      identical(as.character(readiness$CategoryState[1L]), "adequate") &&
      identical(as.character(readiness$BoundaryState[1L]), "finite") &&
      identical(as.character(readiness$NumericalState[1L]), "ready") &&
      mfrmr_cq_adne_exact_codes(
        readiness$ReadinessReasonCodes[1L], character(0)
      ) &&
      identical(
        as.character(attempt$TerminalCode[1L]),
        "complete_numeric_eligible"
      ) && mfrmr_cq_adne_empty_code(attempt$SecondaryCode[1L]) &&
      identical(as.integer(attempt$RegisteredFailureCount[1L]), 0L)

    representation <- as.character(attempt$RepresentationId[1L])
    explicit <- identical(representation, "explicit_missing")
    registered_representation <- representation %in% c(
      "observed_rows_only", "planned_absence", "explicit_missing"
    )
    expected_input <- if (explicit) "review" else "pass"
    expected_reason <- if (explicit) {
      c("design_rank_not_evaluated", "input_review_required")
    } else {
      "design_rank_not_evaluated"
    }
    bounded_rank_hold <- converged && registered_representation &&
      identical(as.character(readiness$FitReadiness[1L]), "review") &&
      identical(as.logical(readiness$InferenceReady[1L]), FALSE) &&
      identical(as.character(readiness$InputState[1L]), expected_input) &&
      identical(
        as.character(readiness$EstimabilityState[1L]), "not_evaluated"
      ) &&
      identical(as.character(readiness$CategoryState[1L]), "adequate") &&
      identical(as.character(readiness$BoundaryState[1L]), "finite") &&
      identical(as.character(readiness$NumericalState[1L]), "ready") &&
      mfrmr_cq_adne_exact_codes(
        readiness$ReadinessReasonCodes[1L], expected_reason
      ) &&
      identical(
        as.character(attempt$TerminalCode[1L]),
        "optimizer_nonconvergence_or_readiness_hold"
      ) && identical(
        as.character(attempt$SecondaryCode[1L]),
        "mfrmr_optimizer_nonconvergence_or_readiness_hold"
      ) && identical(as.integer(attempt$RegisteredFailureCount[1L]), 1L)

    engine_specific <- standard_ready || bounded_rank_hold
    if (standard_ready) eligibility_mode <- "complete_numeric"
    if (bounded_rank_hold) eligibility_mode <- "diagnostic_rank_hold_only"
  }

  predicate <- c(common, engine_specific_contract = engine_specific)
  eligible <- all(predicate)
  failed <- names(predicate)[!predicate]
  reason <- if (eligible) {
    paste0("eligible_", eligibility_mode)
  } else {
    paste0("ineligible_", paste(failed, collapse = ";"))
  }
  data.frame(
    StructuralEligibilityPassed = unname(common["structurally_eligible"]),
    FamilyQuadratureIdentityPassed =
      unname(common["frozen_family_quadrature_identity"]),
    CompletedAttemptPassed = unname(common["exactly_one_completed_attempt"]),
    FiniteParseablePassed = unname(common["finite_parseable_result"]),
    DimensionPassed = unname(common["expected_dimension_observed"]),
    ModelIdentityPassed = unname(common["model_identity_match"]),
    ArtifactSetPassed = unname(common["complete_registered_artifact_set"]),
    SemanticBridgePassed = unname(common["semantic_bridge_satisfied"]),
    RetryAndPriorInspectionPassed =
      unname(common["no_retry_or_prior_numeric_inspection"]),
    EngineSpecificContractPassed = engine_specific,
    DiagnosticNumericEligible = eligible,
    DiagnosticEligibilityMode = if (eligible) eligibility_mode else "ineligible",
    DiagnosticEligibilityReasonCodes = reason,
    InferenceReadyBeforeContract = inference_before,
    InferenceReadyAfterContract = inference_before,
    InferenceReadyPreserved = identical(inference_before, inference_before),
    TerminalCodeBeforeContract = as.character(attempt$TerminalCode[1L]),
    TerminalCodeAfterContract = as.character(attempt$TerminalCode[1L]),
    TerminalCodePreserved = TRUE,
    DiagnosticUseOnly = eligible,
    NumericValueInspected = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_adne_g4x_reachability_audit <- function(output_dir) {
  mfrmr_cq_adne_require_contracts()
  observed <- mfrmr_cq_amcr_readiness_audit(output_dir)
  mechanics <- observed$mechanics
  plan <- mechanics$plan
  journal <- mechanics$journal
  inventory <- mechanics$artifact_inventory
  bridge <- mechanics$representation_bridge
  rows <- lapply(seq_len(nrow(journal)), function(index) {
    order <- journal$AttemptOrder[index]
    planned <- plan[
      !is.na(plan$AttemptOrder) & plan$AttemptOrder == order, , drop = FALSE
    ]
    artifact <- inventory[
      inventory$AttemptOrder == order, , drop = FALSE
    ]
    paired <- !is.na(planned$RepresentationBridgeContractId[1L]) &&
      nzchar(planned$RepresentationBridgeContractId[1L])
    bridge_pass <- if (paired) {
      current <- bridge[bridge$DatasetId == planned$DatasetId[1L], , drop = FALSE]
      nrow(current) == 4L && all(current$Passed)
    } else {
      TRUE
    }
    attempt <- journal[index, , drop = FALSE]
    attempt$Family <- planned$Family[1L]
    attempt$QuadratureId <- planned$QuadratureId[1L]
    attempt$StructuralDispositionFromRetainedG3 <-
      planned$StructuralDispositionFromRetainedG3[1L]
    attempt$AttemptCap <- planned$AttemptCap[1L]
    attempt$ArtifactSetComplete <- artifact$ArtifactSetComplete[1L]
    attempt$SemanticBridgeSatisfied <- bridge_pass
    readiness <- if (attempt$Engine[1L] == "mfrmr") {
      observed$readiness[
        observed$readiness$AttemptOrder == order, , drop = FALSE
      ]
    } else {
      NULL
    }
    classified <- mfrmr_cq_adne_classify_attempt(attempt, readiness)
    data.frame(
      AttemptOrder = order,
      DatasetId = attempt$DatasetId[1L],
      Family = attempt$Family[1L],
      Engine = attempt$Engine[1L],
      QuadratureId = planned$QuadratureId[1L],
      RepresentationId = attempt$RepresentationId[1L],
      RepresentationFitRole = planned$RepresentationFitRole[1L],
      OriginalTerminalCode = attempt$TerminalCode[1L],
      classified,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  mfrmr_rows <- out$Engine == "mfrmr"
  conquest_rows <- out$Engine == "ConQuest"
  mfrmr_cq_adne_assert(
    nrow(out) == 30L && identical(out$AttemptOrder, 1:30) &&
      sum(mfrmr_rows) == 16L && sum(conquest_rows) == 14L &&
      all(out$DiagnosticNumericEligible) &&
      all(out$DiagnosticEligibilityMode[mfrmr_rows] ==
            "diagnostic_rank_hold_only") &&
      all(out$DiagnosticEligibilityMode[conquest_rows] ==
            "complete_numeric") &&
      all(out$InferenceReadyBeforeContract[mfrmr_rows] == FALSE) &&
      all(out$InferenceReadyAfterContract[mfrmr_rows] == FALSE) &&
      all(out$InferenceReadyPreserved) && all(out$TerminalCodePreserved) &&
      !any(out$NumericValueInspected),
    "The G4X categorical state is not exactly reachable under G4N."
  )
  out
}

mfrmr_cq_adne_metric_use_registry <- function() {
  mfrmr_cq_adne_require_contracts()
  summary <- mfrmr_cq_acf_summary_registry()
  conditional <- c(
    "ASP-PROBABILITY-TRUTH-ERROR",
    "ASP-CONTINUOUS-TARGET-ORACLE-ERROR",
    "ASP-PARAMETER-BIAS", "ASP-PARAMETER-RMSE",
    "ASP-CROSS-ENGINE-COORDINATE-DIFFERENCE",
    "ASP-QUADRATURE-SENSITIVITY", "ASP-REPRESENTATION-INVARIANCE"
  )
  requirement <- c(
    "ASP-STRUCTURAL-DISPOSITION" = "all_generated_rows",
    "ASP-CONQUEST-EXECUTION" = "all_generated_rows",
    "ASP-MFRMR-EXECUTION" = "all_generated_rows",
    "ASP-JOINT-NUMERIC-ELIGIBILITY" =
      "all_generated_rows_cross_tabulated_by_engine_eligibility",
    "ASP-PROBABILITY-TRUTH-ERROR" =
      "one_engine_primary_fit_diagnostic_numeric_eligible",
    "ASP-CONTINUOUS-TARGET-ORACLE-ERROR" =
      "one_engine_primary_fit_diagnostic_numeric_eligible",
    "ASP-PARAMETER-BIAS" =
      "one_engine_primary_fit_diagnostic_numeric_eligible",
    "ASP-PARAMETER-RMSE" =
      "one_engine_primary_fit_diagnostic_numeric_eligible",
    "ASP-CROSS-ENGINE-COORDINATE-DIFFERENCE" = paste(
      "both_engines_diagnostic_numeric_eligible_same_dataset_family_q",
      "and_primary_semantic_arm"
    ),
    "ASP-QUADRATURE-SENSITIVITY" = paste(
      "same_engine_dataset_family_primary_semantic_arm_both_q61_and_q121",
      "diagnostic_numeric_eligible"
    ),
    "ASP-FALSE-READY-OR-FALSE-PASS" = paste(
      "all_generated_rows_cross_tabulate_diagnostic_numeric_eligible",
      "against_unchanged_inference_ready"
    ),
    "ASP-REPRESENTATION-INVARIANCE" = paste(
      "mfrmr_invariance_primary_and_companion_both_diagnostic_numeric_eligible",
      "and_semantic_bridge_passed"
    ),
    "ASP-ELAPSED-RUNTIME" = "all_attempted_and_unattempted_rows",
    "ASP-RETAINED-STORAGE" = "all_registered_artifacts_and_absences"
  )
  index <- match(summary$SummaryId, names(requirement))
  mfrmr_cq_adne_assert(
    nrow(summary) == 14L && !anyNA(index),
    "The frozen summary registry cannot be mapped completely by G4N."
  )
  out <- data.frame(
    SummaryId = summary$SummaryId,
    UseClass = ifelse(
      summary$SummaryId %in% conditional,
      "conditional_exploratory_diagnostic_numeric",
      "unconditional_accounting_or_safety"
    ),
    EligibilityRequirement = unname(requirement[index]),
    InvarianceCompanionExcludedFromPrimaryMetrics =
      summary$SummaryId %in% conditional &
      summary$SummaryId != "ASP-REPRESENTATION-INVARIANCE",
    RequiresUnconditionalCompanion =
      summary$ConditionalNumericSummaryRequiresUnconditionalCompanion,
    FailureRowsRetained = TRUE,
    InferenceReadyMayFilterDiagnosticLane = FALSE,
    InferenceReadyMayBeChanged = FALSE,
    ExistingTerminalCodeMayBeChanged = FALSE,
    CalibrationExploratoryUsePermitted = TRUE,
    ConfirmationUsePermitted = FALSE,
    EvidencePromotionPermitted = FALSE,
    PublicClaimPermitted = FALSE,
    NumericValueInspectedByAddendum = FALSE,
    stringsAsFactors = FALSE
  )
  mfrmr_cq_adne_assert(
    sum(out$UseClass == "conditional_exploratory_diagnostic_numeric") == 7L &&
      all(out$FailureRowsRetained) &&
      !any(out$InferenceReadyMayFilterDiagnosticLane) &&
      !any(out$InferenceReadyMayBeChanged) &&
      !any(out$ExistingTerminalCodeMayBeChanged) &&
      !any(out$ConfirmationUsePermitted) &&
      !any(out$EvidencePromotionPermitted) &&
      !any(out$PublicClaimPermitted) &&
      !any(out$NumericValueInspectedByAddendum),
    "The G4N metric-use boundary is not fail-closed."
  )
  out
}

mfrmr_cq_adne_metric_gate <- function(
    summary_id,
    engine_eligible = FALSE,
    peer_engine_eligible = FALSE,
    q61_eligible = FALSE,
    q121_eligible = FALSE,
    representation_primary_eligible = FALSE,
    representation_companion_eligible = FALSE,
    semantic_bridge_passed = FALSE) {
  registry <- mfrmr_cq_adne_metric_use_registry()
  mfrmr_cq_adne_assert(
    length(summary_id) == 1L && summary_id %in% registry$SummaryId,
    "Metric gating requires one registered G4N summary."
  )
  truth <- c(
    "ASP-PROBABILITY-TRUTH-ERROR",
    "ASP-CONTINUOUS-TARGET-ORACLE-ERROR",
    "ASP-PARAMETER-BIAS", "ASP-PARAMETER-RMSE"
  )
  if (summary_id %in% truth) return(isTRUE(engine_eligible))
  if (summary_id == "ASP-CROSS-ENGINE-COORDINATE-DIFFERENCE") {
    return(isTRUE(engine_eligible) && isTRUE(peer_engine_eligible) &&
             isTRUE(semantic_bridge_passed))
  }
  if (summary_id == "ASP-QUADRATURE-SENSITIVITY") {
    return(isTRUE(q61_eligible) && isTRUE(q121_eligible))
  }
  if (summary_id == "ASP-REPRESENTATION-INVARIANCE") {
    return(isTRUE(representation_primary_eligible) &&
             isTRUE(representation_companion_eligible) &&
             isTRUE(semantic_bridge_passed))
  }
  TRUE
}

mfrmr_cq_adne_addendum_checklist <- function() {
  data.frame(
    CheckOrder = 1:12,
    CheckId = c(
      "preserve_inference_ready_false",
      "define_separate_diagnostic_numeric_eligible",
      "require_completed_parseable_finite_dimension_matched_fit",
      "require_optimizer_convergence_without_identity_or_numeric_failure",
      "retain_input_and_estimability_reason_codes",
      "map_each_numeric_metric_to_diagnostic_or_inferential_use",
      "retain_unconditional_failure_companions",
      "forbid_confirmation_or_public_promotion_from_diagnostic_lane",
      "preserve_seed_DGP_workload_and_attempt_order",
      "preserve_paired_representation_denominator_and_bridge",
      "add_adversarial_zero_denominator_and_false_ready_tests",
      "require_fresh_runtime_sentinel_for_later_execution"
    ),
    Complete = TRUE,
    NumericAgreementInspected = FALSE,
    MayChangeInferenceReady = FALSE,
    MayChangeTerminalCode = FALSE,
    MayAuthorizeCalibrationGenerationAlone = FALSE,
    MayAuthorizeExecutionAlone = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_adne_review <- function(output_dir) {
  mfrmr_cq_adne_require_contracts()
  g4r <- mfrmr_cq_amcr_review(output_dir)
  eligibility <- mfrmr_cq_adne_g4x_reachability_audit(output_dir)
  metric <- mfrmr_cq_adne_metric_use_registry()
  checklist <- mfrmr_cq_adne_addendum_checklist()
  mfrmr_rows <- eligibility$Engine == "mfrmr"
  conquest_rows <- eligibility$Engine == "ConQuest"
  frozen <- identical(
    g4r$status,
    "ASP_G4R_calibration_hold_diagnostic_eligibility_addendum_required"
  ) && all(checklist$Complete) &&
    sum(eligibility$DiagnosticNumericEligible[mfrmr_rows]) == 16L &&
    sum(eligibility$DiagnosticNumericEligible[conquest_rows]) == 14L &&
    !any(metric$InferenceReadyMayBeChanged) &&
    !any(metric$ExistingTerminalCodeMayBeChanged) &&
    !any(metric$ConfirmationUsePermitted) &&
    !any(metric$PublicClaimPermitted)
  list(
    specification = mfrmr_cq_adne_specification,
    contract_version = mfrmr_cq_adne_contract,
    status = if (frozen) {
      "ASP_G4N_diagnostic_numeric_eligibility_frozen_calibration_authorization_required"
    } else {
      "ASP_G4N_hold_contract_or_reachability_invalid"
    },
    g4r_review = g4r,
    diagnostic_eligibility_reachability = eligibility,
    metric_use_registry = metric,
    addendum_checklist = checklist,
    g4x_mfrmr_diagnostic_numeric_reachable = sum(
      eligibility$DiagnosticNumericEligible[mfrmr_rows]
    ),
    g4x_conquest_diagnostic_numeric_reachable = sum(
      eligibility$DiagnosticNumericEligible[conquest_rows]
    ),
    g4x_terminal_codes_relabelled = FALSE,
    g4x_inference_ready_states_changed = FALSE,
    calibration_numeric_values_inspected = FALSE,
    calibration_response_generation_authorized = FALSE,
    calibration_execution_authorized = FALSE,
    rerun_engine_mechanics_authorized = FALSE,
    confirmation_use_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE,
    separate_calibration_authorization_required = TRUE,
    next_action = "ASP-G4A-TRANCHE-A-AUTHORIZATION-REVIEW"
  )
}
