# Dry-run-first ASP-G4C calibration harness under construction.
#
# P1 froze the complete tranche-A plan, schema, and empty ledgers. P2 adds a
# sealed deterministic-generation provider and a semantic representation
# bridge, but deliberately issues no positive generation authority and creates
# no tranche-A response. Engine adapters, finalization, summaries, and live
# execution remain absent and unauthorized.

mfrmr_cq_ach_p1_specification <-
  "0.2.3-conquest-adversarial-simulation-calibration-harness-v1-p1"
mfrmr_cq_ach_specification <-
  "0.2.3-conquest-adversarial-simulation-calibration-harness-v1-p2"
mfrmr_cq_ach_contract <-
  "mfrmr_conquest_adversarial_simulation_calibration_harness_v1"
mfrmr_cq_ach_generation_authority_contract <-
  paste0(
    "mfrmr_conquest_adversarial_simulation_tranche_a_",
    "generation_authorization_v1"
  )

mfrmr_cq_ach_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_ach_require_contracts <- function() {
  target <- environment(mfrmr_cq_ach_require_contracts)
  required <- c(
    "mfrmr_cq_acf_seed_registry", "mfrmr_cq_acf_resource_budget_registry",
    "mfrmr_cq_acf_representation_bridge_registry",
    "mfrmr_cq_adne_metric_use_registry", "mfrmr_cq_ataa_review",
    "mfrmr_cq_ataa_harness_capability_registry", "mfrmr_cq_ataa_output_boundary",
    "mfrmr_cq_ase_rng_contract", "mfrmr_cq_ase_uniform_stream",
    "mfrmr_cq_ase_generate_arm", "mfrmr_cq_ase_read_tables",
    "mfrmr_cq_ase_validate_tables", "mfrmr_cq_ast_template",
    "mfrmr_cq_ado_truth", "mfrmr_cq_ameh_relation",
    "mfrmr_cq_ameh_relation_key", "mfrmr_cq_ameh_canonical_from_planned",
    "mfrmr_cq_ameh_wide_from_relation", "mfrmr_cq_ameh_relation_from_wide"
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
  ) && exists(
    "mfrmr_cq_ase_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_ase_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_adversarial_simulation_smoke_execution_v1"
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

mfrmr_cq_ach_scalar_equal <- function(left, right) {
  if (length(left) != 1L || length(right) != 1L) return(FALSE)
  if (is.na(left) || is.na(right)) return(is.na(left) && is.na(right))
  if (is.numeric(left) && is.numeric(right)) {
    return(identical(as.numeric(left), as.numeric(right)))
  }
  if (is.logical(left) || is.logical(right)) {
    return(is.logical(left) && is.logical(right) && identical(left, right))
  }
  identical(as.character(left), as.character(right))
}

mfrmr_cq_ach_registered_tranche_row <- function(allocation) {
  mfrmr_cq_ach_require_contracts()
  required <- c(
    "Phase", "Tranche", "DatasetId", "ArmIndex", "ArmId",
    "ScenarioClassId", "Family", "Replicate", "Seed",
    "ExpectedStructuralDisposition", "PrimaryQ61FitRequired",
    "PairedRepresentationComparisonRequired", "Q61FitAttemptCount",
    "Q61OutcomeRowCount", "SelectiveQ121FitRequired",
    "SelectiveQ121FitAttemptCount", "PlannedOutcomeRowCount", "EvidenceUse",
    "Generated", "ResultOpened", "RetainIfGenerated", "MayTuneDGP",
    "MayTuneMetricThreshold", "MayEnterConfirmation", "MaySupportPublicClaim"
  )
  mfrmr_cq_ach_assert(
    is.data.frame(allocation) && nrow(allocation) == 1L &&
      all(required %in% names(allocation)),
    "Generation requires one complete frozen tranche-A allocation row."
  )
  registry <- mfrmr_cq_acf_seed_registry()
  registered <- registry[
    registry$Tranche == "A" &
      registry$DatasetId == as.character(allocation$DatasetId[1L]),
    , drop = FALSE
  ]
  mfrmr_cq_ach_assert(
    nrow(registered) == 1L,
    "The allocation is not a uniquely registered tranche-A dataset."
  )
  matches <- vapply(required, function(field) {
    mfrmr_cq_ach_scalar_equal(allocation[[field]][1L], registered[[field]][1L])
  }, logical(1L))
  mfrmr_cq_ach_assert(
    all(matches),
    paste0(
      "The allocation differs from the frozen registry at: ",
      paste(names(matches)[!matches], collapse = ", "), "."
    )
  )
  mfrmr_cq_ach_assert(
    !isTRUE(registered$Generated) && !isTRUE(registered$ResultOpened) &&
      isTRUE(registered$RetainIfGenerated) &&
      !isTRUE(registered$MayTuneDGP) &&
      !isTRUE(registered$MayTuneMetricThreshold) &&
      !isTRUE(registered$MayEnterConfirmation) &&
      !isTRUE(registered$MaySupportPublicClaim),
    "The registered allocation is not sealed for exploratory calibration."
  )
  registered
}

mfrmr_cq_ach_generation_authority_schema <- function() {
  data.frame(
    FieldOrder = 1:16,
    Field = c(
      "AuthorizationIdentity", "AuthorizationContract", "HarnessContract",
      "DatasetId", "Seed", "CalibrationOutputDir", "GenerationAuthorized",
      "GenerationConsumed", "OneDatasetOnly", "OneTimeAuthorization",
      "FreshRuntimeSentinelPassed", "SentinelObservedInCurrentProcess",
      "FreshSentinelToken", "OutputTargetAbsentAtAuthorization", "ResultOpened",
      "ConfirmationOrPublicUsePermitted"
    ),
    Requirement = c(
      "exact_dataset_and_seed_identity", "exact_contract", "exact_contract",
      "exact_registered_dataset", "exact_registered_seed",
      "exact_absent_frozen_target", "must_be_true", "must_be_false",
      "must_be_true", "must_be_true", "must_be_true", "must_be_true",
      "must_validate_by_later_same_process_controller",
      "must_be_true_and_rechecked", "must_be_false", "must_be_false"
    ),
    IssuedByP2 = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ach_validate_generation_authority <- function(
    allocation, authority, calibration_output_dir) {
  registered <- mfrmr_cq_ach_registered_tranche_row(allocation)
  schema <- mfrmr_cq_ach_generation_authority_schema()
  mfrmr_cq_ach_assert(
    is.environment(authority) &&
      setequal(ls(authority, all.names = TRUE), schema$Field),
    "A target-bound mutable generation authority is required."
  )
  target <- normalizePath(
    as.character(calibration_output_dir)[1L], winslash = "/", mustWork = FALSE
  )
  authorized_target <- normalizePath(
    as.character(authority$CalibrationOutputDir)[1L],
    winslash = "/", mustWork = FALSE
  )
  boundary <- mfrmr_cq_ataa_output_boundary(target)
  expected_identity <- paste(
    registered$DatasetId, registered$Seed, "tranche_A_generation", sep = "::"
  )
  basic_valid <- identical(authority$AuthorizationIdentity, expected_identity) &&
    identical(
      authority$AuthorizationContract,
      mfrmr_cq_ach_generation_authority_contract
    ) && identical(authority$HarnessContract, mfrmr_cq_ach_contract) &&
    identical(as.character(authority$DatasetId), registered$DatasetId) &&
    identical(as.integer(authority$Seed), as.integer(registered$Seed)) &&
    identical(authorized_target, target) &&
    isTRUE(boundary$BasenameMatches) &&
    isTRUE(boundary$OutputTargetAbsent) &&
    !isTRUE(boundary$ExistingTargetMayBeReused) &&
    !isTRUE(boundary$OverwritePermitted) &&
    isTRUE(authority$GenerationAuthorized) &&
    !isTRUE(authority$GenerationConsumed) &&
    isTRUE(authority$OneDatasetOnly) &&
    isTRUE(authority$OneTimeAuthorization) &&
    isTRUE(authority$FreshRuntimeSentinelPassed) &&
    isTRUE(authority$SentinelObservedInCurrentProcess) &&
    isTRUE(authority$OutputTargetAbsentAtAuthorization) &&
    !isTRUE(authority$ResultOpened) &&
    !isTRUE(authority$ConfirmationOrPublicUsePermitted) &&
    !file.exists(target)
  mfrmr_cq_ach_assert(
    basic_valid,
    paste(
      "Generation authority is absent, consumed, stale, target-mismatched,",
      "or broader than exploratory tranche A."
    )
  )
  target_environment <- environment(mfrmr_cq_ach_validate_generation_authority)
  sentinel_validator_available <- exists(
    "mfrmr_cq_ach_validate_fresh_sentinel_token",
    envir = target_environment, mode = "function", inherits = TRUE
  )
  sentinel_valid <- sentinel_validator_available && isTRUE(tryCatch(
    get(
      "mfrmr_cq_ach_validate_fresh_sentinel_token",
      envir = target_environment, mode = "function", inherits = TRUE
    )(
      authority$FreshSentinelToken,
      dataset_id = registered$DatasetId,
      seed = registered$Seed,
      calibration_output_dir = target
    ),
    error = function(error) FALSE
  ))
  mfrmr_cq_ach_assert(
    sentinel_valid,
    paste(
      "A fresh same-process sentinel token from the later execution",
      "controller is required; sentinel booleans alone are insufficient."
    )
  )
  invisible(registered)
}

mfrmr_cq_ach_rng_contract <- function() {
  mfrmr_cq_ach_require_contracts()
  out <- mfrmr_cq_ase_rng_contract()
  out$HarnessContract <- mfrmr_cq_ach_contract
  out$SourceGeneratorContract <- mfrmr_cq_ase_contract
  out$FrozenTrancheSeedRequired <- TRUE
  out$PositiveAuthorityIssuedByP2 <- FALSE
  out$TrancheAResponseGeneratedByP2 <- FALSE
  out$SemanticReplayRequired <- TRUE
  out$ByteIdentityIsScientificAcceptanceCriterion <- FALSE
  out
}

mfrmr_cq_ach_smoke_allocation <- function(registered) {
  data.frame(
    Phase = registered$Phase,
    DatasetId = registered$DatasetId,
    ArmId = registered$ArmId,
    ScenarioClassId = registered$ScenarioClassId,
    Family = registered$Family,
    Replicate = registered$Replicate,
    Seed = registered$Seed,
    ExpectedDisposition = registered$ExpectedStructuralDisposition,
    EvaluationUse = registered$EvidenceUse,
    Generated = FALSE,
    ResultOpened = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ach_coordinate_string <- function(value) {
  if (is.matrix(value)) {
    index <- expand.grid(
      Column = colnames(value), Row = rownames(value),
      KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
    )
    observed <- value[cbind(
      match(index$Row, rownames(value)), match(index$Column, colnames(value))
    )]
    return(paste(
      paste(index$Row, index$Column, format(observed, digits = 17), sep = "="),
      collapse = ";"
    ))
  }
  paste(
    paste(names(value), format(as.numeric(value), digits = 17), sep = "="),
    collapse = ";"
  )
}

mfrmr_cq_ach_truth_row <- function(manifest) {
  truth <- mfrmr_cq_ado_truth(manifest$ProfileId, manifest$Family)
  data.frame(
    DatasetId = manifest$DatasetId,
    ProfileId = truth$ProfileId,
    Family = truth$Family,
    PopulationIntercept = truth$PopulationIntercept,
    PopulationSlope = truth$PopulationSlope,
    PopulationVariance = truth$PopulationVariance,
    RaterCoordinates = mfrmr_cq_ach_coordinate_string(truth$Rater),
    CriterionCoordinates = mfrmr_cq_ach_coordinate_string(truth$Criterion),
    StepCoordinates = mfrmr_cq_ach_coordinate_string(truth$Steps),
    LowerTailAnchorProbability = truth$LowerTailAnchorProbability,
    UpperTailAnchorProbability = truth$UpperTailAnchorProbability,
    ResponsePostprocessing = truth$ResponsePostprocessing,
    ModelConformingIIDForRecovery = truth$ModelConformingIIDForRecovery,
    RecoveryEligible = truth$RecoveryEligible,
    ConfirmationUsePermitted = FALSE,
    PublicClaimPermitted = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ach_generate_dataset <- function(
    allocation, authority, calibration_output_dir) {
  registered <- mfrmr_cq_ach_validate_generation_authority(
    allocation, authority, calibration_output_dir
  )
  authority$GenerationConsumed <- TRUE
  generated <- mfrmr_cq_ase_generate_arm(
    mfrmr_cq_ach_smoke_allocation(registered)
  )
  manifest <- generated$dataset_manifest
  manifest$SourceGeneratorContract <- manifest$SmokeContract
  manifest$SmokeContract <- NULL
  manifest$HarnessSpecification <- mfrmr_cq_ach_specification
  manifest$HarnessContract <- mfrmr_cq_ach_contract
  manifest$CalibrationResultCanTuneDesign <- manifest$SmokeResultCanTuneDesign
  manifest$SmokeResultCanTuneDesign <- NULL
  manifest$ConfirmationUsePermitted <- FALSE
  manifest$PublicClaimPermitted <- FALSE
  manifest$SemanticValidationRequired <- TRUE
  manifest$ByteIdentityAcceptedAsScientificEvidence <- FALSE
  list(
    dataset_manifest = manifest,
    response_data = generated$response_data,
    truth_registry = mfrmr_cq_ach_truth_row(manifest),
    structural_disposition = generated$structural_disposition
  )
}

mfrmr_cq_ach_expected_bridge_design <- function(arm_id) {
  companion <- mfrmr_cq_ast_template(arm_id)$ExplicitMissingCompanion
  mfrmr_cq_ach_assert(
    is.data.frame(companion),
    "A paired bridge requires the frozen explicit-missing design."
  )
  out <- companion[, c(
    "Person", "PersonIndex", "X", "Rater", "RaterIndex", "Criterion",
    "CriterionIndex"
  ), drop = FALSE]
  out$ResponseObserved <- !is.na(companion$Response)
  out <- out[order(
    out$PersonIndex, out$RaterIndex, out$CriterionIndex
  ), , drop = FALSE]
  rownames(out) <- NULL
  out
}

mfrmr_cq_ach_bridge_checks <- function(current, arm_id) {
  failed <- rep(FALSE, 4L)
  parsed <- tryCatch({
    list(
      planned = mfrmr_cq_ameh_relation(current[
        current$RepresentationId == "planned_absence", , drop = FALSE
      ]),
      explicit = mfrmr_cq_ameh_relation(current[
        current$RepresentationId == "explicit_missing", , drop = FALSE
      ]),
      expected = mfrmr_cq_ach_expected_bridge_design(arm_id)
    )
  }, error = function(error) NULL)
  if (is.null(parsed) || nrow(parsed$planned) == 0L ||
      nrow(parsed$explicit) == 0L) return(failed)
  planned <- parsed$planned
  explicit <- parsed$explicit
  expected <- parsed$expected
  representation_exact <- setequal(
    unique(as.character(current$RepresentationId)),
    c("planned_absence", "explicit_missing")
  )
  explicit_observed <- explicit[explicit$ResponseObserved, , drop = FALSE]
  rownames(explicit_observed) <- NULL
  observed_columns <- c(
    "Person", "PersonIndex", "X", "Rater", "RaterIndex", "Criterion",
    "CriterionIndex", "Response"
  )
  observed_equal <- representation_exact && identical(
    planned[, observed_columns, drop = FALSE],
    explicit_observed[, observed_columns, drop = FALSE]
  )
  planned_key <- mfrmr_cq_ameh_relation_key(planned)
  explicit_key <- mfrmr_cq_ameh_relation_key(explicit)
  expected_key <- mfrmr_cq_ameh_relation_key(expected)
  expected_observed_key <- expected_key[expected$ResponseObserved]
  missing_key <- mfrmr_cq_ameh_relation_key(
    explicit[!explicit$ResponseObserved, , drop = FALSE]
  )
  expected_missing_key <- expected_key[!expected$ResponseObserved]
  complement_equal <- representation_exact &&
    setequal(explicit_key, expected_key) &&
    setequal(planned_key, expected_observed_key) &&
    setequal(missing_key, expected_missing_key) &&
    !anyDuplicated(explicit_key) && !anyDuplicated(planned_key)
  canonical_planned <- tryCatch(
    mfrmr_cq_ameh_canonical_from_planned(planned, explicit),
    error = function(error) NULL
  )
  canonical_columns <- c(observed_columns, "ResponseObserved")
  design_columns <- setdiff(canonical_columns, "Response")
  expected_design <- expected[, design_columns, drop = FALSE]
  canonical_equal <- representation_exact && !is.null(canonical_planned) &&
    identical(
      canonical_planned[, canonical_columns, drop = FALSE],
      explicit[, canonical_columns, drop = FALSE]
    ) && identical(
      explicit[, design_columns, drop = FALSE], expected_design
    )
  roundtrip_equal <- representation_exact && tryCatch({
    planned_wide <- mfrmr_cq_ameh_wide_from_relation(canonical_planned)
    explicit_wide <- mfrmr_cq_ameh_wide_from_relation(explicit)
    isTRUE(all.equal(
      planned_wide, explicit_wide, check.attributes = FALSE
    )) && identical(
      mfrmr_cq_ameh_relation_from_wide(planned_wide),
      mfrmr_cq_ameh_relation_from_wide(explicit_wide)
    )
  }, error = function(error) FALSE)
  c(observed_equal, complement_equal, canonical_equal, roundtrip_equal)
}

mfrmr_cq_ach_representation_bridge_audit <- function(
    response_data, dataset_manifest) {
  mfrmr_cq_ach_require_contracts()
  mfrmr_cq_ach_assert(
    is.data.frame(response_data) && is.data.frame(dataset_manifest) &&
      all(c(
        "DatasetId", "ArmId", "ScenarioClassId", "Family"
      ) %in% names(dataset_manifest)) &&
      all(c("DatasetId", "RepresentationId") %in% names(response_data)),
    "The representation bridge requires typed response and manifest tables."
  )
  paired <- dataset_manifest[
    dataset_manifest$ScenarioClassId == "ASP-INV-PAIRED-MISSINGNESS",
    , drop = FALSE
  ]
  mfrmr_cq_ach_assert(
    nrow(paired) > 0L && !anyDuplicated(paired$DatasetId),
    "The representation bridge requires unique paired datasets."
  )
  bridge_contract <- mfrmr_cq_acf_representation_bridge_registry()
  out <- do.call(rbind, lapply(seq_len(nrow(paired)), function(index) {
    dataset_id <- paired$DatasetId[index]
    passed <- mfrmr_cq_ach_bridge_checks(
      response_data[response_data$DatasetId == dataset_id, , drop = FALSE],
      paired$ArmId[index]
    )
    data.frame(
      DatasetId = dataset_id,
      Family = paired$Family[index],
      CheckOrder = bridge_contract$CheckOrder,
      CheckId = bridge_contract$CheckId,
      ComparisonLevel = bridge_contract$ComparisonLevel,
      Passed = passed,
      PrimaryTerminalCode = ifelse(
        passed, NA_character_, bridge_contract$TerminalCodeOnFailure
      ),
      SecondaryCode = ifelse(
        passed, NA_character_, bridge_contract$SecondaryCodeOnFailure
      ),
      ByteEqualityRequired = FALSE,
      NumericAgreementInspected = FALSE,
      stringsAsFactors = FALSE
    )
  }))
  rownames(out) <- NULL
  out
}

mfrmr_cq_ach_retained_bridge_replay <- function(smoke_output_dir) {
  mfrmr_cq_ach_require_contracts()
  smoke_output_dir <- normalizePath(
    as.character(smoke_output_dir)[1L], winslash = "/", mustWork = TRUE
  )
  schema <- mfrmr_cq_asg_output_schema_registry()
  expected <- c(paste0(schema$TableId, ".csv"), "smoke_result.rds")
  present <- list.files(smoke_output_dir, all.files = FALSE, no.. = TRUE)
  tables <- mfrmr_cq_ase_read_tables(smoke_output_dir)
  source_valid <- identical(
    basename(smoke_output_dir), mfrmr_cq_ase_output_basename
  ) && setequal(present, expected) && mfrmr_cq_ase_validate_tables(tables) &&
    nrow(tables$dataset_manifest) == 18L &&
    sum(tables$engine_outcome$Attempted) == 0L
  mfrmr_cq_ach_assert(
    source_valid,
    "The retained G3 tables failed the non-generative source audit."
  )
  bridge <- mfrmr_cq_ach_representation_bridge_audit(
    tables$response_data, tables$dataset_manifest
  )
  mfrmr_cq_ach_assert(
    nrow(bridge) == 8L && all(bridge$Passed) &&
      !any(bridge$ByteEqualityRequired) &&
      !any(bridge$NumericAgreementInspected),
    "The retained G3 paired data failed the P2 semantic bridge replay."
  )
  list(
    source_output_dir = smoke_output_dir,
    source_dataset_count = nrow(tables$dataset_manifest),
    paired_dataset_count = length(unique(bridge$DatasetId)),
    bridge_check_count = nrow(bridge),
    bridge = bridge,
    response_generation_performed = FALSE,
    numeric_agreement_inspected = FALSE,
    byte_equality_inspected = FALSE
  )
}

mfrmr_cq_ach_p1_review <- function(g4x_output_dir, calibration_output_dir) {
  mfrmr_cq_ach_require_contracts()
  g4a <- mfrmr_cq_ataa_review(g4x_output_dir, calibration_output_dir)
  plan <- mfrmr_cq_ach_plan()
  audit <- mfrmr_cq_ach_plan_audit(plan)
  schema <- mfrmr_cq_ach_schema_registry()
  generation <- mfrmr_cq_ach_generation_journal_template(plan)
  journal <- mfrmr_cq_ach_attempt_journal_template(plan)
  outcome <- mfrmr_cq_ach_outcome_template(plan)
  capability <- mfrmr_cq_ataa_harness_capability_registry()
  p1_available <- capability$CapabilityOrder %in% c(1:5, 7L)
  complete <- all(audit$Passed) && nrow(schema) == 14L &&
    nrow(generation) == 90L && nrow(journal) == 190L &&
    nrow(outcome) == 230L && all(generation$RowRetained) &&
    all(outcome$RowRetained) && !any(journal$Started) &&
    !any(outcome$Attempted) &&
    all(capability$ProviderAvailable[p1_available]) &&
    identical(sum(p1_available), 6L) &&
    identical(sum(!p1_available), 12L) &&
    identical(
      g4a$status,
      paste0(
        "ASP_G4A_scientific_value_retained_execution_hold_",
        "harness_freeze_required"
      )
    )
  list(
    specification = mfrmr_cq_ach_p1_specification,
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
      sum(p1_available),
    harness_capabilities_still_missing = sum(!p1_available),
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

mfrmr_cq_ach_dry_run_review <- function(
    g4x_output_dir, calibration_output_dir,
    smoke_output_dir = file.path(
      dirname(g4x_output_dir), mfrmr_cq_ase_output_basename
    )) {
  mfrmr_cq_ach_require_contracts()
  g4a <- mfrmr_cq_ataa_review(g4x_output_dir, calibration_output_dir)
  plan <- mfrmr_cq_ach_plan()
  audit <- mfrmr_cq_ach_plan_audit(plan)
  schema <- mfrmr_cq_ach_schema_registry()
  generation <- mfrmr_cq_ach_generation_journal_template(plan)
  journal <- mfrmr_cq_ach_attempt_journal_template(plan)
  outcome <- mfrmr_cq_ach_outcome_template(plan)
  capability <- mfrmr_cq_ataa_harness_capability_registry()
  rng <- mfrmr_cq_ach_rng_contract()
  bridge <- mfrmr_cq_ach_retained_bridge_replay(smoke_output_dir)
  complete <- all(audit$Passed) && nrow(schema) == 14L &&
    nrow(generation) == 90L && nrow(journal) == 190L &&
    nrow(outcome) == 230L && all(generation$RowRetained) &&
    !any(generation$GenerationStarted) && !any(generation$Generated) &&
    !any(journal$Started) && !any(outcome$Attempted) &&
    identical(sum(capability$ProviderAvailable), 8L) &&
    identical(sum(!capability$ProviderAvailable), 10L) &&
    isTRUE(rng$CallerRNGStateRestored) &&
    isTRUE(rng$FrozenTrancheSeedRequired) &&
    !isTRUE(rng$PositiveAuthorityIssuedByP2) &&
    !isTRUE(rng$TrancheAResponseGeneratedByP2) &&
    identical(bridge$bridge_check_count, 8L) &&
    all(bridge$bridge$Passed) &&
    !isTRUE(bridge$response_generation_performed) &&
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
      paste0(
        "ASP_G4C_P2_generation_and_bridge_frozen_",
        "integrated_harness_incomplete"
      )
    } else {
      "ASP_G4C_P2_generation_or_bridge_hold"
    },
    g4a_review = g4a,
    plan = plan,
    plan_audit = audit,
    schema_registry = schema,
    generation_journal_template = generation,
    attempt_journal_template = journal,
    outcome_template = outcome,
    rng_contract = rng,
    retained_bridge_replay = bridge,
    generation_authority_schema = mfrmr_cq_ach_generation_authority_schema(),
    upstream_and_harness_capabilities_available =
      sum(capability$ProviderAvailable),
    harness_capabilities_still_missing = sum(!capability$ProviderAvailable),
    exact_outcome_ledger_materialization_ready = complete,
    deterministic_generation_implemented = TRUE,
    semantic_bridge_implemented = TRUE,
    retained_g3_bridge_checks = bridge$bridge_check_count,
    tranche_A_responses_generated = FALSE,
    positive_generation_authority_issued = FALSE,
    fresh_sentinel_token_validator_implemented = FALSE,
    engine_adapters_implemented = FALSE,
    finalizer_and_metric_summary_implemented = FALSE,
    response_generation_authorized = FALSE,
    execution_authorized = FALSE,
    fresh_tranche_A_sentinel_observed = FALSE,
    numeric_agreement_inspected = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE,
    next_action = "ASP-G4C-P3-ENGINE-ADAPTERS-ARTIFACTS-RESOURCES"
  )
}
