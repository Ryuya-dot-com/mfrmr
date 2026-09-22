# No-execution ASP-G4A tranche-A authorization review.
#
# This review separates scientific information value from executable readiness.
# It generates no response, reads no numerical agreement result, fits no model,
# and launches no external process.

mfrmr_cq_ataa_specification <-
  "0.2.3-conquest-adversarial-simulation-tranche-a-authorization-review-v1"
mfrmr_cq_ataa_contract <-
  "mfrmr_conquest_adversarial_simulation_tranche_a_authorization_review_v1"
mfrmr_cq_ataa_review_date <- as.Date("2026-08-16")
mfrmr_cq_ataa_output_basename <-
  "conquest-adversarial-simulation-calibration-tranche-a-20260816-v1"

mfrmr_cq_ataa_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_ataa_require_contracts <- function() {
  target <- environment(mfrmr_cq_ataa_require_contracts)
  required <- c(
    "mfrmr_cq_acf_review", "mfrmr_cq_acf_seed_registry",
    "mfrmr_cq_acf_workload_registry", "mfrmr_cq_acf_resource_budget_registry",
    "mfrmr_cq_adne_review", "mfrmr_cq_adne_metric_use_registry",
    "mfrmr_cq_ameh_review_execution"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- exists(
    "mfrmr_cq_adne_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_adne_contract", envir = target, inherits = TRUE),
    paste0(
      "mfrmr_conquest_adversarial_simulation_diagnostic_numeric_",
      "eligibility_addendum_v1"
    )
  )
  mfrmr_cq_ataa_assert(
    all(available) && identity,
    "Source the complete G4N dependency chain before the G4A review."
  )
  invisible(TRUE)
}

mfrmr_cq_ataa_output_boundary <- function(output_dir) {
  parent <- normalizePath(
    dirname(output_dir), winslash = "/", mustWork = TRUE
  )
  target <- file.path(parent, basename(output_dir))
  data.frame(
    OutputDir = target,
    ExpectedBasename = mfrmr_cq_ataa_output_basename,
    BasenameMatches = identical(
      basename(target), mfrmr_cq_ataa_output_basename
    ),
    OutputTargetAbsent = !file.exists(target),
    ExistingTargetMayBeReused = FALSE,
    OverwritePermitted = FALSE,
    ExecutionAuthorizedByBoundary = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ataa_provider_available <- function(
    provider, contract_object, expected_contract) {
  target <- environment(mfrmr_cq_ataa_provider_available)
  exists(provider, envir = target, mode = "function", inherits = TRUE) &&
    exists(contract_object, envir = target, inherits = TRUE) &&
    identical(
      get(contract_object, envir = target, inherits = TRUE), expected_contract
    )
}

mfrmr_cq_ataa_harness_capability_registry <- function() {
  mfrmr_cq_ataa_require_contracts()
  capability <- c(
    "frozen_seed_allocation",
    "frozen_failure_taxonomy",
    "diagnostic_metric_use_gates",
    "diagnostic_attempt_classifier",
    "retained_G4X_mechanics_reviewer",
    "deterministic_tranche_A_dataset_generator",
    "exact_230_row_190_attempt_plan_materializer",
    "per_dataset_representation_bridge_validator",
    "mfrmr_q61_q121_adapter",
    "ConQuest_q61_q121_adapter_and_parser",
    "fresh_sentinel_same_process_execution_controller",
    "complete_outcome_ledger_finalizer",
    "registered_artifact_inventory_and_unexpected_file_guard",
    "per_fit_and_global_resource_abort_controller",
    "G4N_eligibility_application_without_terminal_relabelling",
    "conditional_and_unconditional_metric_summarizer",
    "run_once_authorization_record_consumer",
    "retained_execution_reviewer"
  )
  provider <- c(
    "mfrmr_cq_acf_seed_registry",
    "mfrmr_cq_acf_failure_taxonomy",
    "mfrmr_cq_adne_metric_use_registry",
    "mfrmr_cq_adne_classify_attempt",
    "mfrmr_cq_ameh_review_execution",
    "mfrmr_cq_ach_generate_dataset",
    "mfrmr_cq_ach_plan",
    "mfrmr_cq_ach_representation_bridge_audit",
    "mfrmr_cq_ach_mfrmr_fit",
    "mfrmr_cq_ach_conquest_fit",
    "mfrmr_cq_ach_execute",
    "mfrmr_cq_ach_finalize_outcomes",
    "mfrmr_cq_ach_artifact_inventory",
    "mfrmr_cq_ach_resource_controller",
    "mfrmr_cq_ach_apply_diagnostic_eligibility",
    "mfrmr_cq_ach_metric_summary",
    "mfrmr_cq_ach_consume_authorization",
    "mfrmr_cq_ach_review_execution"
  )
  upstream <- seq_along(capability) <= 5L
  contract_object <- ifelse(
    upstream,
    c(
      "mfrmr_cq_acf_contract", "mfrmr_cq_acf_contract",
      "mfrmr_cq_adne_contract", "mfrmr_cq_adne_contract",
      "mfrmr_cq_ameh_contract"
    ),
    "mfrmr_cq_ach_contract"
  )
  expected_contract <- ifelse(
    upstream,
    c(
      rep("mfrmr_conquest_adversarial_simulation_calibration_freeze_v2", 2L),
      rep(paste0(
        "mfrmr_conquest_adversarial_simulation_diagnostic_numeric_",
        "eligibility_addendum_v1"
      ), 2L),
      "mfrmr_conquest_adversarial_simulation_engine_mechanics_harness_v1"
    ),
    "mfrmr_conquest_adversarial_simulation_calibration_harness_v1"
  )
  available <- mapply(
    mfrmr_cq_ataa_provider_available,
    provider, contract_object, expected_contract,
    USE.NAMES = FALSE
  )
  out <- data.frame(
    CapabilityOrder = seq_along(capability),
    CapabilityId = capability,
    ProviderFunction = provider,
    ProviderContractObject = contract_object,
    ExpectedProviderContract = expected_contract,
    UpstreamContractComplete = upstream,
    ProviderAvailable = available,
    RequiredBeforeResponseGeneration = c(
      rep(FALSE, 5L), TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, TRUE, TRUE,
      FALSE, FALSE, FALSE, TRUE, TRUE
    ),
    RequiredBeforeLiveExecution = !upstream,
    MayBeSatisfiedByG4HAlone = FALSE,
    ExecutionAuthorizedByCapability = FALSE,
    stringsAsFactors = FALSE
  )
  mfrmr_cq_ataa_assert(
    nrow(out) == 18L && identical(out$CapabilityOrder, 1:18) &&
      all(out$ProviderAvailable[upstream]) &&
      !any(out$MayBeSatisfiedByG4HAlone) &&
      !any(out$ExecutionAuthorizedByCapability),
    "The G4A capability registry or completed upstream boundary changed."
  )
  out
}

mfrmr_cq_ataa_information_value_registry <- function() {
  data.frame(
    QuestionOrder = 1:8,
    QuestionId = c(
      "main_numeric_denominator_reachable",
      "first_simulation_operating_characteristics",
      "cross_engine_and_truth_information_not_in_G4X",
      "five_replicates_per_arm_precision",
      "selection_and_confirmation_leakage",
      "unconditional_failure_information",
      "independent_third_party_recalculation",
      "execution_without_calibration_harness"
    ),
    Evidence = c(
      "G4N_reaches_16_mfrmr_and_14_ConQuest_G4X_attempts",
      "90_disjoint_datasets_and_230_outcome_rows_are_frozen",
      "G4X_opened_no_truth_error_coordinate_difference_or_q121_result",
      "tranche_A_has_five_replicates_per_scenario_family_arm",
      "seeds_DGP_metrics_attempt_order_and_failure_rows_are_frozen",
      "all_generated_rows_and_failures_have_mandatory_companions",
      "not_needed_for_exploratory_software_calibration",
      "no_integrated_tranche_A_generator_runner_finalizer_or_reviewer"
    ),
    Decision = c(
      "supports_bounded_calibration",
      "supports_bounded_calibration",
      "supports_bounded_calibration",
      "diagnostic_only_not_precision_or_threshold_setting",
      "controlled_if_frozen_contract_is_preserved",
      "supports_bounded_calibration",
      "not_a_prerequisite",
      "blocks_generation_and_execution"
    ),
    SupportsHarnessInvestment = c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE),
    ExecutionBlocker = c(rep(FALSE, 7L), TRUE),
    MaySetThresholdOrConfirmationRule = FALSE,
    MaySupportPublicClaim = FALSE,
    NumericAgreementInspected = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ataa_identity_audit <- function(
    g4x_output_dir, calibration_output_dir,
    review_date = mfrmr_cq_ataa_review_date) {
  mfrmr_cq_ataa_require_contracts()
  review_date <- as.Date(review_date)
  mfrmr_cq_ataa_assert(
    length(review_date) == 1L && !is.na(review_date),
    "G4A requires one explicit review date."
  )
  freeze <- mfrmr_cq_acf_review()
  g4n <- mfrmr_cq_adne_review(g4x_output_dir)
  seed <- freeze$seed_registry
  tranche <- seed$Tranche == "A"
  tranche_seed <- seed[tranche, , drop = FALSE]
  workload <- freeze$tranche_A_workload
  budget <- freeze$resource_budget[
    freeze$resource_budget$Stage == "calibration_tranche_A", , drop = FALSE
  ]
  boundary <- mfrmr_cq_ataa_output_boundary(calibration_output_dir)
  runtime <- freeze$runtime_contract
  runway <- as.integer(runtime$RunNotAfter - review_date)
  expiry_runway <- as.integer(runtime$ExpiryDate - review_date)
  frozen <- identical(
    freeze$status, "ASP_G4_calibration_contract_frozen_execution_closed"
  ) && identical(
    g4n$status,
    paste0(
      "ASP_G4N_diagnostic_numeric_eligibility_frozen_",
      "calibration_authorization_required"
    )
  ) && nrow(tranche_seed) == 90L &&
    sum(tranche_seed$PrimaryQ61FitRequired) == 70L &&
    sum(tranche_seed$ExpectedStructuralDisposition ==
          "reject_before_numeric_comparison") == 20L &&
    sum(tranche_seed$PairedRepresentationComparisonRequired) == 10L &&
    sum(tranche_seed$SelectiveQ121FitRequired) == 20L &&
    !any(tranche_seed$Generated) && !any(tranche_seed$ResultOpened) &&
    nrow(workload) == 8L && sum(workload$PlannedAttemptCount) == 190L &&
    budget$ScheduledOutcomeRowCap == 230L &&
    isTRUE(boundary$BasenameMatches) && isTRUE(boundary$OutputTargetAbsent)
  mfrmr_cq_ataa_assert(
    frozen,
    "The G4A frozen identity, denominator, or output boundary drifted."
  )
  list(
    freeze = freeze,
    g4n = g4n,
    tranche_seed_registry = tranche_seed,
    tranche_workload = workload,
    tranche_budget = budget,
    output_boundary = boundary,
    review_date = review_date,
    days_until_run_not_after = runway,
    days_until_demonstration_expiry = expiry_runway,
    executable_path_present = file.exists(runtime$ExecutablePath),
    executable_path_executable = file.access(runtime$ExecutablePath, 1L) == 0L,
    fresh_tranche_A_sentinel_observed = FALSE,
    frozen_identity_complete = frozen,
    response_generation_observed = FALSE,
    numeric_agreement_inspected = FALSE
  )
}

mfrmr_cq_ataa_resource_audit <- function(identity) {
  mechanics <- identity$g4n$g4r_review$mechanics_review
  resource <- mechanics$resource
  budget <- identity$tranche_budget
  scale <- budget$TotalFitAttemptCap / resource$FitAttempts
  projected_elapsed <- resource$ElapsedSeconds * scale
  projected_bytes <- resource$RetainedBytes * scale
  worst_case_fit_timeout_seconds <-
    budget$TotalFitAttemptCap * budget$PerFitTimeoutSeconds
  preliminary <-
    isTRUE(mechanics$mechanics_gate_met) &&
    !isTRUE(resource$GlobalAbortTriggered) &&
    projected_elapsed < budget$CumulativeWallTimeCapSeconds &&
    projected_bytes < budget$RetainedStorageCapBytes &&
    identity$days_until_run_not_after >= 0L &&
    identity$days_until_demonstration_expiry > 0L &&
    identity$executable_path_present && identity$executable_path_executable
  data.frame(
    G4XObservedAttempts = as.integer(resource$FitAttempts),
    TrancheAPlannedAttempts = as.integer(budget$TotalFitAttemptCap),
    G4XObservedElapsedSeconds = as.numeric(resource$ElapsedSeconds),
    G4XObservedRetainedBytes = as.numeric(resource$RetainedBytes),
    SimpleLinearElapsedProjectionSeconds = projected_elapsed,
    SimpleLinearStorageProjectionBytes = projected_bytes,
    TrancheAWallTimeCapSeconds = as.numeric(budget$CumulativeWallTimeCapSeconds),
    TrancheAStorageCapBytes = as.numeric(budget$RetainedStorageCapBytes),
    WorstCasePerFitTimeoutSumSeconds = worst_case_fit_timeout_seconds,
    GlobalCapRequired = worst_case_fit_timeout_seconds >
      budget$CumulativeWallTimeCapSeconds,
    Q121MechanicsObserved = FALSE,
    DatasetGenerationCostObserved = FALSE,
    CalibrationScenarioTailRuntimeObserved = FALSE,
    ResourceFeasibilityPreliminary = preliminary,
    ResourceEvidenceSufficientForExecutionAuthorization = FALSE,
    NumericAgreementInspected = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ataa_review <- function(
    g4x_output_dir, calibration_output_dir,
    review_date = mfrmr_cq_ataa_review_date) {
  identity <- mfrmr_cq_ataa_identity_audit(
    g4x_output_dir, calibration_output_dir, review_date
  )
  value <- mfrmr_cq_ataa_information_value_registry()
  resource <- mfrmr_cq_ataa_resource_audit(identity)
  capability <- mfrmr_cq_ataa_harness_capability_registry()
  scientific_value <-
    sum(value$Decision == "supports_bounded_calibration") >= 4L &&
    identical(
      value$Decision[value$QuestionId == "five_replicates_per_arm_precision"],
      "diagnostic_only_not_precision_or_threshold_setting"
    ) &&
    !any(value$MaySetThresholdOrConfirmationRule) &&
    !any(value$MaySupportPublicClaim)
  harness_ready <- all(capability$ProviderAvailable)
  hold <- identity$frozen_identity_complete && scientific_value &&
    isTRUE(resource$ResourceFeasibilityPreliminary) && !harness_ready &&
    !isTRUE(identity$fresh_tranche_A_sentinel_observed)
  list(
    specification = mfrmr_cq_ataa_specification,
    contract_version = mfrmr_cq_ataa_contract,
    status = if (hold) {
      "ASP_G4A_scientific_value_retained_execution_hold_harness_freeze_required"
    } else if (
      identity$frozen_identity_complete && scientific_value &&
        isTRUE(resource$ResourceFeasibilityPreliminary) && harness_ready &&
        !isTRUE(identity$fresh_tranche_A_sentinel_observed)
    ) {
      "ASP_G4A_harness_ready_separate_live_authorization_required"
    } else {
      "ASP_G4A_hold_identity_value_resource_or_boundary_invalid"
    },
    identity_audit = identity,
    information_value_registry = value,
    resource_audit = resource,
    harness_capability_registry = capability,
    scientific_value_gate_met = scientific_value,
    information_gain_exceeds_harness_investment = scientific_value,
    tranche_A_precision_or_threshold_claim_supported = FALSE,
    resource_feasibility_preliminary =
      isTRUE(resource$ResourceFeasibilityPreliminary),
    resource_evidence_sufficient_for_execution = FALSE,
    harness_capabilities_available = sum(capability$ProviderAvailable),
    harness_capabilities_missing = sum(!capability$ProviderAvailable),
    calibration_harness_ready = harness_ready,
    calibration_harness_implementation_authorized = hold,
    calibration_response_generation_authorized = FALSE,
    calibration_execution_authorized = FALSE,
    fresh_tranche_A_sentinel_observed = FALSE,
    numeric_agreement_inspected = FALSE,
    confirmation_use_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE,
    next_action = "ASP-G4C-TRANCHE-A-HARNESS-FREEZE"
  )
}
