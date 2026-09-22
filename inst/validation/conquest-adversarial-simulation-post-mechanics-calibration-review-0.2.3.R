# Truth-blind ASP-G4R review after the bounded engine-mechanics execution.
#
# This review reads mechanics, categorical readiness, and frozen denominator
# contracts only. It does not read coordinates, deviances, likelihoods, truth
# errors, or cross-engine numerical differences, and it authorizes no run.

mfrmr_cq_amcr_specification <-
  "0.2.3-conquest-adversarial-simulation-post-mechanics-calibration-review-v1"
mfrmr_cq_amcr_contract <-
  "mfrmr_conquest_adversarial_simulation_post_mechanics_calibration_review_v1"

mfrmr_cq_amcr_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_amcr_require_contracts <- function() {
  target <- environment(mfrmr_cq_amcr_require_contracts)
  required <- c(
    "mfrmr_cq_ameh_review_execution",
    "mfrmr_cq_ameh_expected_artifact_registry",
    "mfrmr_cq_ameh_loaded_namespace",
    "mfrmr_cq_asp_metric_registry", "mfrmr_cq_acf_summary_registry"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- exists(
    "mfrmr_cq_ameh_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_ameh_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_adversarial_simulation_engine_mechanics_harness_v1"
  )
  mfrmr_cq_amcr_assert(
    all(available) && identity,
    "Source the complete G4X mechanics and frozen metric contracts first."
  )
  invisible(TRUE)
}

mfrmr_cq_amcr_split_codes <- function(value) {
  value <- as.character(value)
  value <- value[!is.na(value) & nzchar(value)]
  if (length(value) == 0L) return(character(0))
  unique(trimws(unlist(strsplit(value, ";", fixed = TRUE))))
}

mfrmr_cq_amcr_readiness_audit <- function(output_dir) {
  mfrmr_cq_amcr_require_contracts()
  mechanics <- mfrmr_cq_ameh_review_execution(output_dir)
  mfrmr_cq_amcr_assert(
    identical(
      mechanics$status,
      "ASP_G4X_engine_mechanics_complete_calibration_review_required"
    ) && isTRUE(mechanics$accounting_complete) &&
      isTRUE(mechanics$artifact_accounting_complete) &&
      isTRUE(mechanics$mechanics_gate_met) &&
      isTRUE(mechanics$run_once_consumed) &&
      !isTRUE(mechanics$rerun_authorized),
    "G4X mechanics are incomplete, unreviewable, or not run-once consumed."
  )
  root <- mechanics$output_dir
  registry <- mfrmr_cq_ameh_expected_artifact_registry(mechanics$plan)
  summary_registry <- registry[
    registry$Engine == "mfrmr" & registry$ArtifactKind == "summary", ,
    drop = FALSE
  ]
  rows <- lapply(seq_len(nrow(summary_registry)), function(index) {
    order <- summary_registry$AttemptOrder[index]
    journal <- mechanics$journal[
      mechanics$journal$AttemptOrder == order, , drop = FALSE
    ]
    required <- c(
      "Model", "Converged", "FitReadiness", "InferenceReady",
      "InputState", "EstimabilityState", "CategoryState", "BoundaryState",
      "NumericalState", "ReadinessReasonCodes", "ICQuadraturePoints",
      "MMLEngineRequested", "MMLEngineUsed", "ConvergenceCode",
      "ConvergenceStatus", "ConvergenceSeverity", "ReviewableWarning"
    )
    summary_path <- file.path(root, summary_registry$RelativePath[index])
    header <- utils::read.csv(
      summary_path, nrows = 0L, stringsAsFactors = FALSE,
      check.names = FALSE
    )
    mfrmr_cq_amcr_assert(
      nrow(journal) == 1L && all(required %in% names(header)),
      "A retained mfrmr mechanics summary lacks categorical readiness fields."
    )
    column_class <- rep("NULL", ncol(header))
    names(column_class) <- names(header)
    column_class[required] <- ifelse(
      required %in% c("Converged", "InferenceReady", "ReviewableWarning"),
      "logical", ifelse(
        required %in% c("ICQuadraturePoints", "ConvergenceCode"),
        "integer", "character"
      )
    )
    summary <- utils::read.csv(
      summary_path, stringsAsFactors = FALSE, check.names = FALSE,
      na.strings = "", colClasses = column_class
    )
    mfrmr_cq_amcr_assert(
      nrow(summary) == 1L && setequal(names(summary), required),
      "A readiness-only read materialized an unregistered summary field."
    )
    data.frame(
      AttemptOrder = order,
      DatasetId = journal$DatasetId,
      Family = journal$Family,
      Model = as.character(summary$Model[1L]),
      RepresentationId = journal$RepresentationId,
      TerminalCode = journal$TerminalCode,
      ParseableResult = journal$ParseableResult,
      ModelIdentityMatch = journal$ModelIdentityMatch,
      ExpectedFreeDimension = journal$ExpectedFreeDimension,
      ObservedFreeDimension = journal$ObservedFreeDimension,
      Converged = as.logical(summary$Converged[1L]),
      ConvergenceStatus = as.character(summary$ConvergenceStatus[1L]),
      FitReadiness = as.character(summary$FitReadiness[1L]),
      InferenceReady = as.logical(summary$InferenceReady[1L]),
      InputState = as.character(summary$InputState[1L]),
      EstimabilityState = as.character(summary$EstimabilityState[1L]),
      CategoryState = as.character(summary$CategoryState[1L]),
      BoundaryState = as.character(summary$BoundaryState[1L]),
      NumericalState = as.character(summary$NumericalState[1L]),
      ReadinessReasonCodes = as.character(summary$ReadinessReasonCodes[1L]),
      ICQuadraturePoints = as.integer(summary$ICQuadraturePoints[1L]),
      MMLEngineRequested = as.character(summary$MMLEngineRequested[1L]),
      MMLEngineUsed = as.character(summary$MMLEngineUsed[1L]),
      ConvergenceCode = as.integer(summary$ConvergenceCode[1L]),
      ConvergenceSeverity = as.character(summary$ConvergenceSeverity[1L]),
      ReviewableWarning = as.logical(summary$ReviewableWarning[1L]),
      NumericEstimateFieldMaterialized = FALSE,
      CrossEngineDifferenceComputed = FALSE,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  allowed_reason <- c("design_rank_not_evaluated", "input_review_required")
  observed_reason <- unique(unlist(lapply(
    out$ReadinessReasonCodes, mfrmr_cq_amcr_split_codes
  )))
  explicit <- out$RepresentationId == "explicit_missing"
  mfrmr_cq_amcr_assert(
    nrow(out) == 16L && identical(out$AttemptOrder, sort(out$AttemptOrder)) &&
      identical(
        as.integer(table(factor(out$Family, levels = c("RSM", "PCM")))),
        c(8L, 8L)
      ) && sum(explicit) == 2L &&
      all(out$TerminalCode ==
            "optimizer_nonconvergence_or_readiness_hold") &&
      all(out$ParseableResult) && all(out$ModelIdentityMatch) &&
      all(out$ExpectedFreeDimension == out$ObservedFreeDimension) &&
      all(out$Model == out$Family) && all(out$ICQuadraturePoints == 61L) &&
      all(out$MMLEngineRequested == "direct") &&
      all(out$MMLEngineUsed == "direct") &&
      all(out$Converged) && all(out$ConvergenceCode == 0L) &&
      all(out$ConvergenceStatus == "converged") &&
      all(out$ConvergenceSeverity == "pass") &&
      !any(out$ReviewableWarning) &&
      all(out$FitReadiness == "review") && !any(out$InferenceReady) &&
      all(out$EstimabilityState == "not_evaluated") &&
      all(out$CategoryState == "adequate") &&
      all(out$BoundaryState == "finite") &&
      all(out$NumericalState == "ready") &&
      setequal(observed_reason, allowed_reason) &&
      all(vapply(
        out$ReadinessReasonCodes[explicit],
        function(value) all(allowed_reason %in% mfrmr_cq_amcr_split_codes(value)),
        logical(1L)
      )) &&
      !any(out$NumericEstimateFieldMaterialized) &&
      !any(out$CrossEngineDifferenceComputed),
    "The retained mfrmr mechanics/readiness state is not the bounded G4X state."
  )
  list(mechanics = mechanics, readiness = out)
}

mfrmr_cq_amcr_readiness_reachability <- function(mechanics) {
  smoke_root <- as.character(mechanics$authority$SmokeOutputDir[1L])
  source_root <- normalizePath(
    file.path(smoke_root, "..", ".."), winslash = "/", mustWork = TRUE
  )
  namespace <- mfrmr_cq_ameh_loaded_namespace(source_root)
  build_sizes <- get("build_param_sizes", envir = namespace, inherits = FALSE)
  nonlinear_blocks <- get(
    "mfrmr_estimability_nonlinear_blocks",
    envir = namespace, inherits = FALSE
  )
  derive_fit <- get(
    "mfrmr_readiness_derive_fit", envir = namespace, inherits = FALSE
  )
  inference_ready <- get(
    "mfrmr_readiness_inference_ready", envir = namespace, inherits = FALSE
  )
  out <- do.call(rbind, lapply(c("RSM", "PCM"), function(family) {
    config <- list(
      method = "MML", model = family, n_cat = 4L,
      facet_names = c("Rater", "Criterion"),
      facet_specs = list(
        Rater = list(n_params = 3L), Criterion = list(n_params = 2L)
      ),
      facet_levels = list(
        Rater = paste0("R", 1:4), Criterion = paste0("C", 1:3)
      ),
      interaction_specs = list(), step_facet = if (family == "PCM") {
        "Criterion"
      } else {
        NULL
      },
      population_spec = list(
        active = TRUE,
        design_matrix = matrix(0, nrow = 1L, ncol = 2L)
      )
    )
    sizes <- build_sizes(config)
    nonlinear <- nonlinear_blocks(sizes)
    fit_readiness <- derive_fit(
      InputState = "pass", EstimabilityState = "not_evaluated",
      CategoryState = "adequate", BoundaryState = "finite",
      NumericalState = "ready"
    )
    data.frame(
      Family = family,
      Method = "MML",
      PopulationModelActive = TRUE,
      LogSigma2FreeCoordinates = as.integer(sizes$log_sigma2),
      NonlinearBlocks = paste(nonlinear, collapse = ";"),
      PreFitEstimabilityComplete = length(nonlinear) == 0L,
      IncompleteEstimabilityState = "not_evaluated",
      DerivedFitReadiness = fit_readiness,
      DerivedInferenceReady = inference_ready(fit_readiness),
      NumericAgreementInspected = FALSE,
      stringsAsFactors = FALSE
    )
  }))
  rownames(out) <- NULL
  mfrmr_cq_amcr_assert(
    nrow(out) == 2L && all(out$LogSigma2FreeCoordinates == 1L) &&
      all(vapply(
        strsplit(out$NonlinearBlocks, ";", fixed = TRUE),
        function(value) "log_sigma2" %in% value, logical(1L)
      )) && !any(out$PreFitEstimabilityComplete) &&
      all(out$DerivedFitReadiness == "review") &&
      !any(out$DerivedInferenceReady) &&
      !any(out$NumericAgreementInspected),
    "The working-tree nonlinear MML readiness reachability changed."
  )
  out
}

mfrmr_cq_amcr_metric_denominator_audit <- function() {
  mfrmr_cq_amcr_require_contracts()
  metric <- mfrmr_cq_asp_metric_registry()
  numeric_id <- c(
    "ASP-PROBABILITY-TRUTH-ERROR",
    "ASP-CONTINUOUS-TARGET-ORACLE-ERROR",
    "ASP-PARAMETER-BIAS", "ASP-PARAMETER-RMSE",
    "ASP-CROSS-ENGINE-COORDINATE-DIFFERENCE",
    "ASP-QUADRATURE-SENSITIVITY"
  )
  metric$RequiresSuccessfulOrJointNumericFit <-
    metric$MetricId %in% numeric_id
  metric$PopulatableWithZeroMfrmrCompleteNumericOutcomes <-
    !metric$RequiresSuccessfulOrJointNumericFit &
    metric$AnalysisState == "active_design"
  metric$MfrmrOrJointLaneBlockedUnderCurrentTerminalSemantics <-
    metric$RequiresSuccessfulOrJointNumericFit
  metric$DiagnosticEligibilityAddendumRequired <-
    metric$RequiresSuccessfulOrJointNumericFit
  metric$InferenceReadyMayBeRelabelled <- FALSE
  metric$CalibrationExecutionAuthorized <- FALSE
  summary <- mfrmr_cq_acf_summary_registry()
  representation <- summary[
    summary$SummaryId == "ASP-REPRESENTATION-INVARIANCE", , drop = FALSE
  ]
  mfrmr_cq_amcr_assert(
    nrow(metric) == 12L &&
      sum(metric$MfrmrOrJointLaneBlockedUnderCurrentTerminalSemantics) == 6L &&
      identical(
        metric$MetricId[
          metric$MfrmrOrJointLaneBlockedUnderCurrentTerminalSemantics
        ],
        numeric_id
      ) && nrow(representation) == 1L &&
      isTRUE(representation$ConditionalNumericSummaryRequiresUnconditionalCompanion) &&
      !any(metric$InferenceReadyMayBeRelabelled) &&
      !any(metric$CalibrationExecutionAuthorized),
    "The frozen calibration metric denominator boundary drifted."
  )
  list(
    metric = metric,
    representation_numeric_blocked = TRUE,
    zero_mfrmr_complete_numeric_outcomes_observed = TRUE,
    numeric_agreement_inspected = FALSE
  )
}

mfrmr_cq_amcr_option_registry <- function() {
  data.frame(
    OptionId = c(
      "run_frozen_tranche_A_unchanged",
      "relabel_readiness_holds_as_complete",
      "lower_or_bypass_InferenceReady",
      "freeze_separate_diagnostic_numeric_eligibility",
      "complete_nonlinear_estimability_before_calibration",
      "retain_mechanics_only_and_cancel_numeric_calibration"
    ),
    Decision = c(
      "reject_zero_joint_numeric_denominator",
      "reject_terminal_semantic_erosion",
      "reject_inference_boundary_erosion",
      "recommended_next_bounded_contract",
      "scientifically_stronger_longer_term_alternative",
      "fallback_if_no_diagnostic_addendum_is_accepted"
    ),
    PreservesInferenceReadyMeaning = c(TRUE, FALSE, FALSE, TRUE, TRUE, TRUE),
    PreservesFrozenSeedsDGPAndWorkload = c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE),
    RequiresNumericalAgreementInspectionNow = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_amcr_addendum_checklist <- function() {
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
    RequiredBeforeCalibrationGeneration = TRUE,
    Complete = FALSE,
    NumericAgreementInspectionRequired = FALSE,
    MayChangeInferenceReady = FALSE,
    MayAuthorizeExecutionAlone = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_amcr_review <- function(output_dir) {
  observed <- mfrmr_cq_amcr_readiness_audit(output_dir)
  reachability <- mfrmr_cq_amcr_readiness_reachability(observed$mechanics)
  denominator <- mfrmr_cq_amcr_metric_denominator_audit()
  option <- mfrmr_cq_amcr_option_registry()
  checklist <- mfrmr_cq_amcr_addendum_checklist()
  readiness <- observed$readiness
  mechanics <- observed$mechanics
  current_zero <- sum(
    readiness$TerminalCode == "complete_numeric_eligible"
  ) == 0L
  hold <- isTRUE(mechanics$mechanics_gate_met) && current_zero &&
    sum(
      denominator$metric$MfrmrOrJointLaneBlockedUnderCurrentTerminalSemantics
    ) == 6L &&
    denominator$representation_numeric_blocked &&
    !any(checklist$Complete) &&
    !any(option$CalibrationExecutionAuthorized)
  list(
    specification = mfrmr_cq_amcr_specification,
    contract_version = mfrmr_cq_amcr_contract,
    status = if (hold) {
      "ASP_G4R_calibration_hold_diagnostic_eligibility_addendum_required"
    } else {
      "ASP_G4R_review_invalid_or_not_bounded"
    },
    mechanics_review = mechanics,
    mfrmr_readiness = readiness,
    readiness_reachability = reachability,
    metric_denominator = denominator$metric,
    option_registry = option,
    addendum_checklist = checklist,
    mechanics_gate_met = isTRUE(mechanics$mechanics_gate_met),
    mfrmr_complete_numeric_outcomes = sum(
      readiness$TerminalCode == "complete_numeric_eligible"
    ),
    frozen_numeric_metrics_with_mfrmr_or_joint_lane_blocked = sum(
      denominator$metric$MfrmrOrJointLaneBlockedUnderCurrentTerminalSemantics
    ),
    representation_numeric_summary_blocked =
      denominator$representation_numeric_blocked,
    calibration_partially_informative_for_counts_and_resources = TRUE,
    calibration_informative_for_frozen_numeric_objective = FALSE,
    diagnostic_numeric_eligibility_addendum_required = hold,
    calibration_response_generation_authorized = FALSE,
    calibration_execution_authorized = FALSE,
    rerun_engine_mechanics_authorized = FALSE,
    numeric_agreement_inspected = FALSE,
    evidence_promotion_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE,
    next_action = "ASP-G4N-DIAGNOSTIC-NUMERIC-ELIGIBILITY-ADDENDUM"
  )
}
