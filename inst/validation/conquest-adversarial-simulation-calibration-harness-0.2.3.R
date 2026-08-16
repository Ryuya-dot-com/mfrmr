# Dry-run-first ASP-G4C calibration harness under construction.
#
# P1 freezes the complete tranche-A plan, schema, and empty ledgers before any
# response is generated. Engine adapters, generation, finalization, summaries,
# and live execution remain absent and unauthorized.

mfrmr_cq_ach_specification <-
  "0.2.3-conquest-adversarial-simulation-calibration-harness-v1-p1"
mfrmr_cq_ach_contract <-
  "mfrmr_conquest_adversarial_simulation_calibration_harness_v1"

mfrmr_cq_ach_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_ach_require_contracts <- function() {
  target <- environment(mfrmr_cq_ach_require_contracts)
  required <- c(
    "mfrmr_cq_acf_seed_registry", "mfrmr_cq_acf_resource_budget_registry",
    "mfrmr_cq_adne_metric_use_registry", "mfrmr_cq_ataa_review",
    "mfrmr_cq_ataa_harness_capability_registry"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- exists(
    "mfrmr_cq_ataa_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_ataa_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_adversarial_simulation_tranche_a_authorization_review_v1"
  )
  mfrmr_cq_ach_assert(
    all(available) && identity,
    "Source the complete G4A dependency chain before the G4C harness."
  )
  invisible(TRUE)
}

mfrmr_cq_ach_plan_row <- function(
    seed, engine, nodes, representation_id, representation_fit_role,
    primary_analysis_role, bridge_required) {
  eligible <- identical(
    as.character(seed$ExpectedStructuralDisposition[1L]),
    "eligible_numeric_comparison"
  )
  data.frame(
    DatasetOrder = as.integer(seed$ArmIndex[1L] * 5L - 5L +
                                seed$Replicate[1L]),
    DatasetId = as.character(seed$DatasetId[1L]),
    ArmIndex = as.integer(seed$ArmIndex[1L]),
    ArmId = as.character(seed$ArmId[1L]),
    ScenarioClassId = as.character(seed$ScenarioClassId[1L]),
    Family = as.character(seed$Family[1L]),
    Replicate = as.integer(seed$Replicate[1L]),
    Seed = as.integer(seed$Seed[1L]),
    Engine = as.character(engine),
    Nodes = as.integer(nodes),
    QuadratureId = paste0("q", as.integer(nodes)),
    RepresentationId = as.character(representation_id),
    RepresentationFitRole = as.character(representation_fit_role),
    PrimaryAnalysisRole = isTRUE(primary_analysis_role),
    RepresentationBridgeContractId = if (isTRUE(bridge_required)) {
      "paired_missingness_semantic_bridge_v1"
    } else {
      NA_character_
    },
    ExpectedStructuralDisposition =
      as.character(seed$ExpectedStructuralDisposition[1L]),
    StructuralPreFitStop = !eligible,
    AttemptCap = as.integer(eligible),
    ExpectedFreeDimension = if (seed$Family[1L] == "RSM") 10L else 14L,
    ExpectedModelIdentity = if (seed$Family[1L] == "RSM") {
      "rater_plus_criterion_plus_shared_step_with_regression_X"
    } else {
      "rater_plus_criterion_plus_criterion_by_step_with_regression_X"
    },
    DiagnosticEligibilityContract = if (eligible) {
      mfrmr_cq_adne_contract
    } else {
      NA_character_
    },
    RetainedInUnconditionalDenominator = TRUE,
    TruthMetricEligibleOnlyIfDiagnostic =
      eligible && isTRUE(primary_analysis_role),
    AutomaticRetryPermitted = FALSE,
    PeerFailureMaySuppressAttempt = FALSE,
    GlobalResourceAbortMaySuppressAttempt = TRUE,
    ResultMayChangeAttemptOrder = FALSE,
    ResponseGenerationAuthorizedByPlan = FALSE,
    ExecutionAuthorizedByPlan = FALSE,
    ConfirmationUsePermitted = FALSE,
    PublicClaimPermitted = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ach_plan <- function() {
  mfrmr_cq_ach_require_contracts()
  seed <- mfrmr_cq_acf_seed_registry()
  seed <- seed[seed$Tranche == "A", , drop = FALSE]
  rows <- vector("list", nrow(seed))
  for (index in seq_len(nrow(seed))) {
    current <- seed[index, , drop = FALSE]
    eligible <- current$ExpectedStructuralDisposition ==
      "eligible_numeric_comparison"
    paired <- isTRUE(current$PairedRepresentationComparisonRequired)
    selective <- isTRUE(current$SelectiveQ121FitRequired)
    primary_representation <- if (!eligible) {
      "not_applicable_structural_rejection"
    } else if (paired) {
      "planned_absence"
    } else {
      "observed_rows_only"
    }
    conquest_representation <- if (!eligible) {
      "not_applicable_structural_rejection"
    } else if (paired) {
      "canonical_wide_missing"
    } else {
      "observed_rows_only"
    }
    current_rows <- list(
      mfrmr_cq_ach_plan_row(
        current, "mfrmr", 61L, primary_representation,
        if (paired) "invariance_primary" else if (eligible) {
          "single_representation"
        } else {
          "prefit_stop"
        },
        primary_analysis_role = eligible,
        bridge_required = paired
      ),
      mfrmr_cq_ach_plan_row(
        current, "ConQuest", 61L, conquest_representation,
        if (paired) "external_canonical_bridge" else if (eligible) {
          "single_representation"
        } else {
          "prefit_stop"
        },
        primary_analysis_role = eligible,
        bridge_required = paired
      )
    )
    if (paired) {
      current_rows[[length(current_rows) + 1L]] <- mfrmr_cq_ach_plan_row(
        current, "mfrmr", 61L, "explicit_missing",
        "invariance_companion", primary_analysis_role = FALSE,
        bridge_required = TRUE
      )
    }
    if (selective) {
      current_rows[[length(current_rows) + 1L]] <- mfrmr_cq_ach_plan_row(
        current, "mfrmr", 121L, "observed_rows_only",
        "quadrature_sensitivity", primary_analysis_role = TRUE,
        bridge_required = FALSE
      )
      current_rows[[length(current_rows) + 1L]] <- mfrmr_cq_ach_plan_row(
        current, "ConQuest", 121L, "observed_rows_only",
        "quadrature_sensitivity", primary_analysis_role = TRUE,
        bridge_required = FALSE
      )
    }
    rows[[index]] <- do.call(rbind, current_rows)
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out$ScheduledOutcomeOrder <- seq_len(nrow(out))
  out$AttemptOrder <- NA_integer_
  attempted <- out$AttemptCap == 1L
  out$AttemptOrder[attempted] <- seq_len(sum(attempted))
  out$CrossEnginePairId <- NA_character_
  cross <- attempted & out$PrimaryAnalysisRole
  out$CrossEnginePairId[cross] <- paste(
    out$DatasetId[cross], out$Family[cross], out$QuadratureId[cross],
    "primary", sep = "::"
  )
  out$QuadraturePairId <- NA_character_
  q_pair_dataset <- seed$DatasetId[seed$SelectiveQ121FitRequired]
  q_pair <- attempted & out$PrimaryAnalysisRole &
    out$DatasetId %in% q_pair_dataset
  out$QuadraturePairId[q_pair] <- paste(
    out$DatasetId[q_pair], out$Family[q_pair], out$Engine[q_pair],
    "primary", sep = "::"
  )
  out$RepresentationPairId <- NA_character_
  representation_pair <- attempted & out$Engine == "mfrmr" &
    out$RepresentationFitRole %in% c(
      "invariance_primary", "invariance_companion"
    )
  out$RepresentationPairId[representation_pair] <- paste(
    out$DatasetId[representation_pair], out$Family[representation_pair],
    "q61", sep = "::"
  )
  first <- c(
    "ScheduledOutcomeOrder", "AttemptOrder", "DatasetOrder", "DatasetId"
  )
  out <- out[, c(first, setdiff(names(out), first)), drop = FALSE]
  audit <- mfrmr_cq_ach_plan_audit(out)
  mfrmr_cq_ach_assert(
    all(audit$Passed),
    "The G4C P1 plan failed its exact denominator and pairing audit."
  )
  out
}

mfrmr_cq_ach_pair_counts_valid <- function(value, pairs, expected_pairs) {
  observed <- table(value[!is.na(value)])
  length(observed) == pairs && all(observed == expected_pairs)
}

mfrmr_cq_ach_plan_audit <- function(plan) {
  required <- c(
    "ScheduledOutcomeOrder", "AttemptOrder", "DatasetId", "Family",
    "Engine", "Nodes", "QuadratureId", "RepresentationFitRole",
    "PrimaryAnalysisRole", "ExpectedStructuralDisposition", "AttemptCap",
    "CrossEnginePairId", "QuadraturePairId", "RepresentationPairId",
    "RetainedInUnconditionalDenominator", "AutomaticRetryPermitted",
    "PeerFailureMaySuppressAttempt", "ResultMayChangeAttemptOrder",
    "ResponseGenerationAuthorizedByPlan", "ExecutionAuthorizedByPlan"
  )
  complete <- is.data.frame(plan) && all(required %in% names(plan))
  if (!complete) {
    return(data.frame(
      Criterion = "required_columns", Passed = FALSE,
      stringsAsFactors = FALSE
    ))
  }
  attempted <- plan$AttemptCap == 1L
  negative <- plan$ExpectedStructuralDisposition ==
    "reject_before_numeric_comparison"
  dataset_rows <- table(plan$DatasetId)
  criterion <- c(
    required_columns = TRUE,
    scheduled_outcome_rows = nrow(plan) == 230L,
    scheduled_order = identical(plan$ScheduledOutcomeOrder, 1:230),
    unique_scheduled_order = !anyDuplicated(plan$ScheduledOutcomeOrder),
    dataset_denominator = length(unique(plan$DatasetId)) == 90L,
    dataset_row_shape = identical(
      as.integer(table(factor(as.integer(dataset_rows), levels = 2:4))),
      c(60L, 10L, 20L)
    ),
    fit_attempt_denominator = sum(plan$AttemptCap) == 190L,
    attempt_order = identical(plan$AttemptOrder[attempted], 1:190),
    stopped_rows_have_no_attempt_order = all(is.na(plan$AttemptOrder[!attempted])),
    mfrmr_attempts = sum(attempted & plan$Engine == "mfrmr") == 100L,
    ConQuest_attempts = sum(attempted & plan$Engine == "ConQuest") == 90L,
    q61_attempts = sum(attempted & plan$Nodes == 61L) == 150L,
    q121_attempts = sum(attempted & plan$Nodes == 121L) == 40L,
    negative_dataset_denominator =
      length(unique(plan$DatasetId[negative])) == 20L,
    negative_outcome_rows = sum(negative) == 40L,
    negative_prefit_stops = !any(attempted[negative]),
    paired_representation_rows =
      sum(!is.na(plan$RepresentationPairId)) == 20L,
    representation_pairs = mfrmr_cq_ach_pair_counts_valid(
      plan$RepresentationPairId, 10L, 2L
    ),
    cross_engine_rows = sum(!is.na(plan$CrossEnginePairId)) == 180L,
    cross_engine_pairs = mfrmr_cq_ach_pair_counts_valid(
      plan$CrossEnginePairId, 90L, 2L
    ),
    quadrature_rows = sum(!is.na(plan$QuadraturePairId)) == 80L,
    quadrature_pairs = mfrmr_cq_ach_pair_counts_valid(
      plan$QuadraturePairId, 40L, 2L
    ),
    primary_metric_rows_exclude_invariance_companion =
      sum(attempted & plan$TruthMetricEligibleOnlyIfDiagnostic) == 180L,
    all_rows_retained = all(plan$RetainedInUnconditionalDenominator),
    retry_forbidden = !any(plan$AutomaticRetryPermitted),
    peer_failure_independence = !any(plan$PeerFailureMaySuppressAttempt),
    result_blind_order = !any(plan$ResultMayChangeAttemptOrder),
    generation_closed = !any(plan$ResponseGenerationAuthorizedByPlan),
    execution_closed = !any(plan$ExecutionAuthorizedByPlan),
    confirmation_closed = !any(plan$ConfirmationUsePermitted),
    public_claim_closed = !any(plan$PublicClaimPermitted)
  )
  data.frame(
    Criterion = names(criterion), Passed = unname(criterion),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ach_schema_registry <- function() {
  data.frame(
    TableOrder = 1:14,
    TableId = c(
      "dataset_manifest", "response_data", "truth_registry",
      "structural_disposition", "generation_journal", "execution_plan",
      "attempt_journal", "engine_outcome", "representation_bridge",
      "diagnostic_eligibility", "metric_summary", "resource_summary",
      "artifact_inventory", "execution_summary"
    ),
    ExpectedRowsBeforeExecution = c(
      90L, NA, 90L, 90L, 90L, 230L, 190L, 230L, 40L, 190L, NA, 1L, NA, 1L
    ),
    MaterializedBeforeAnyFit = c(
      FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE,
      FALSE, FALSE, FALSE, TRUE, TRUE, TRUE
    ),
    RowDroppable = FALSE,
    ResultMayChangeSchema = FALSE,
    ConfirmationUsePermitted = FALSE,
    PublicClaimPermitted = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ach_generation_journal_template <- function(
    plan = mfrmr_cq_ach_plan()) {
  first <- !duplicated(plan$DatasetId)
  data.frame(
    DatasetOrder = plan$DatasetOrder[first],
    DatasetId = plan$DatasetId[first],
    ArmId = plan$ArmId[first],
    Family = plan$Family[first],
    Replicate = plan$Replicate[first],
    Seed = plan$Seed[first],
    ExpectedStructuralDisposition =
      plan$ExpectedStructuralDisposition[first],
    GenerationStarted = FALSE,
    Generated = FALSE,
    StructuralDispositionObserved = "pending_not_generated",
    RepresentationBridgePassed = NA,
    TerminalCode = "pending_not_generated",
    RowRetained = TRUE,
    ResultOpened = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ach_attempt_journal_template <- function(
    plan = mfrmr_cq_ach_plan()) {
  attempted <- plan$AttemptCap == 1L
  out <- plan[attempted, c(
    "AttemptOrder", "ScheduledOutcomeOrder", "DatasetId", "Family",
    "Engine", "Nodes", "QuadratureId", "RepresentationId",
    "RepresentationFitRole", "ExpectedFreeDimension"
  ), drop = FALSE]
  out$AttemptCount <- 0L
  out$Started <- FALSE
  out$Completed <- FALSE
  out$ElapsedSeconds <- NA_real_
  out$TerminalCode <- "pending_not_executed"
  out$SecondaryCode <- NA_character_
  out$ParseableResult <- FALSE
  out$ObservedFreeDimension <- NA_integer_
  out$ModelIdentityMatch <- FALSE
  out$DiagnosticNumericEligible <- FALSE
  out$InferenceReady <- NA
  out$AutomaticRetryPermitted <- FALSE
  out$NumericAgreementInspected <- FALSE
  out
}

mfrmr_cq_ach_outcome_template <- function(plan = mfrmr_cq_ach_plan()) {
  negative <- plan$AttemptCap == 0L
  out <- plan[, c(
    "ScheduledOutcomeOrder", "AttemptOrder", "DatasetId", "Family",
    "Engine", "Nodes", "QuadratureId", "RepresentationId",
    "RepresentationFitRole", "ExpectedStructuralDisposition",
    "CrossEnginePairId", "QuadraturePairId", "RepresentationPairId"
  ), drop = FALSE]
  out$Attempted <- FALSE
  out$TerminalCode <- ifelse(
    negative, "expected_structural_rejection", "pending_not_executed"
  )
  out$SecondaryCode <- ifelse(
    negative, "frozen_expected_structural_prefit_stop", NA_character_
  )
  out$ParseableResult <- FALSE
  out$ModelIdentityMatch <- FALSE
  out$DiagnosticNumericEligible <- FALSE
  out$InferenceReady <- NA
  out$RowRetained <- TRUE
  out$CalibrationMetricUsePermitted <- FALSE
  out$NumericAgreementInspected <- FALSE
  out
}

mfrmr_cq_ach_dry_run_review <- function(
    g4x_output_dir, calibration_output_dir) {
  mfrmr_cq_ach_require_contracts()
  g4a <- mfrmr_cq_ataa_review(g4x_output_dir, calibration_output_dir)
  plan <- mfrmr_cq_ach_plan()
  audit <- mfrmr_cq_ach_plan_audit(plan)
  schema <- mfrmr_cq_ach_schema_registry()
  generation <- mfrmr_cq_ach_generation_journal_template(plan)
  journal <- mfrmr_cq_ach_attempt_journal_template(plan)
  outcome <- mfrmr_cq_ach_outcome_template(plan)
  capability <- mfrmr_cq_ataa_harness_capability_registry()
  complete <- all(audit$Passed) && nrow(schema) == 14L &&
    nrow(generation) == 90L && nrow(journal) == 190L &&
    nrow(outcome) == 230L && all(generation$RowRetained) &&
    all(outcome$RowRetained) && !any(journal$Started) &&
    !any(outcome$Attempted) &&
    identical(sum(capability$ProviderAvailable), 6L) &&
    identical(sum(!capability$ProviderAvailable), 12L) &&
    identical(
      g4a$status,
      paste0(
        "ASP_G4A_scientific_value_retained_execution_hold_",
        "harness_freeze_required"
      )
    )
  list(
    specification = mfrmr_cq_ach_specification,
    contract_version = mfrmr_cq_ach_contract,
    status = if (complete) {
      "ASP_G4C_P1_plan_schema_frozen_integrated_harness_incomplete"
    } else {
      "ASP_G4C_P1_plan_or_schema_hold"
    },
    g4a_review = g4a,
    plan = plan,
    plan_audit = audit,
    schema_registry = schema,
    generation_journal_template = generation,
    attempt_journal_template = journal,
    outcome_template = outcome,
    upstream_and_harness_capabilities_available =
      sum(capability$ProviderAvailable),
    harness_capabilities_still_missing = sum(!capability$ProviderAvailable),
    exact_outcome_ledger_materialization_ready = complete,
    deterministic_generation_implemented = FALSE,
    engine_adapters_implemented = FALSE,
    finalizer_and_metric_summary_implemented = FALSE,
    response_generation_authorized = FALSE,
    execution_authorized = FALSE,
    fresh_tranche_A_sentinel_observed = FALSE,
    numeric_agreement_inspected = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE,
    next_action = "ASP-G4C-P2-DETERMINISTIC-GENERATION-AND-BRIDGE"
  )
}
