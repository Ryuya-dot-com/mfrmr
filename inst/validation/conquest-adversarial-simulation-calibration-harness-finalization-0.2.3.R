# Dry-run-first ASP-G4C-P4 finalization and retained-review contract.
#
# This final layer completes the prospective harness without issuing live
# authority, generating a tranche-A response, fitting either engine, or opening
# numeric agreement. It preserves all 230 scheduled rows, applies G4N as a
# separate diagnostic lane, keeps unconditional denominators beside every
# conditional numeric summary, consumes (but does not issue) a run-once live
# authorization, and reviews retained output without rerunning it.

mfrmr_cq_ach_p4_specification <-
  "0.2.3-conquest-adversarial-simulation-calibration-harness-v1-p4"
mfrmr_cq_ach_run_authorization_contract <- paste0(
  "mfrmr_conquest_adversarial_simulation_tranche_a_",
  "run_once_live_authorization_v1"
)

mfrmr_cq_ach_p4_require_contracts <- function() {
  target <- environment(mfrmr_cq_ach_p4_require_contracts)
  required <- c(
    "mfrmr_cq_ach_p3_review", "mfrmr_cq_ach_adapter_plan",
    "mfrmr_cq_ach_attempt_journal_template", "mfrmr_cq_ach_outcome_template",
    "mfrmr_cq_ach_artifact_inventory", "mfrmr_cq_ach_resource_state",
    "mfrmr_cq_ach_validate_fresh_sentinel_token",
    "mfrmr_cq_adne_classify_attempt", "mfrmr_cq_adne_metric_use_registry",
    "mfrmr_cq_acf_failure_taxonomy", "mfrmr_cq_acf_summary_registry",
    "mfrmr_cq_ataa_review",
    "mfrmr_cq_ataa_harness_capability_registry"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- exists(
    "mfrmr_cq_ach_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_ach_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_adversarial_simulation_calibration_harness_v1"
  ) && exists(
    "mfrmr_cq_adne_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_adne_contract", envir = target, inherits = TRUE),
    paste0(
      "mfrmr_conquest_adversarial_simulation_diagnostic_numeric_",
      "eligibility_addendum_v1"
    )
  )
  mfrmr_cq_ach_assert(
    all(available) && identity,
    "Source the complete G4C-P3 and G4N contracts before P4."
  )
  invisible(TRUE)
}

mfrmr_cq_ach_p4_same_frame <- function(observed, expected, fields = NULL) {
  if (!is.data.frame(observed) || !is.data.frame(expected) ||
      nrow(observed) != nrow(expected)) return(FALSE)
  if (is.null(fields)) {
    if (!setequal(names(observed), names(expected))) return(FALSE)
    fields <- names(expected)
  }
  if (!all(fields %in% names(observed)) ||
      !all(fields %in% names(expected))) return(FALSE)
  normalize <- function(value) {
    value <- as.character(value)
    value[is.na(value)] <- "<NA>"
    value
  }
  all(vapply(fields, function(field) {
    identical(normalize(observed[[field]]), normalize(expected[[field]]))
  }, logical(1L)))
}

mfrmr_cq_ach_artifact_completeness <- function(
    artifact_inventory, journal,
    plan = mfrmr_cq_ach_adapter_plan()) {
  mfrmr_cq_ach_p4_require_contracts()
  inventory <- if (is.list(artifact_inventory)) {
    artifact_inventory$registry
  } else {
    artifact_inventory
  }
  expected <- mfrmr_cq_ach_expected_artifact_registry(plan)
  mfrmr_cq_ach_assert(
    is.data.frame(inventory) &&
      all(c("Present", "Nonempty") %in% names(inventory)) &&
      mfrmr_cq_ach_p4_same_frame(
        inventory, expected,
        c("AttemptOrder", "Engine", "Nodes", "ArtifactKind", "RelativePath",
          "Requirement")
      ) && nrow(journal) == 190L &&
      identical(as.integer(journal$AttemptOrder), 1:190),
    "P4 artifact completeness requires the exact registered inventory."
  )
  rows <- lapply(seq_len(nrow(journal)), function(index) {
    order <- journal$AttemptOrder[index]
    current <- inventory[
      !is.na(inventory$AttemptOrder) & inventory$AttemptOrder == order,
      , drop = FALSE
    ]
    present_kind <- current$ArtifactKind[
      as.logical(current$Present) & as.logical(current$Nonempty)
    ]
    attempted <- isTRUE(journal$Started[index])
    terminal <- as.character(journal$TerminalCode[index])
    if (!attempted) {
      required <- character(0)
      complete <- !any(current$Present)
    } else if (journal$Engine[index] == "mfrmr") {
      native_terminal <- terminal %in% c(
        "complete_numeric_eligible",
        "optimizer_nonconvergence_or_readiness_hold",
        "model_identity_mismatch", "nonfinite_fit_output"
      )
      required <- if (native_terminal) {
        c("fit_rds", "summary", "population", "facets", "steps", "warnings")
      } else {
        "failure_record"
      }
      complete <- all(required %in% present_kind)
    } else {
      required <- if (terminal == "complete_numeric_eligible") {
        c(mfrmr_cq_ameh_conquest_suffix_registry()$ArtifactKind, "console")
      } else {
        "console"
      }
      complete <- all(required %in% present_kind)
    }
    data.frame(
      AttemptOrder = order,
      RequiredArtifactKinds = paste(required, collapse = ";"),
      PresentNonemptyArtifactKinds = paste(present_kind, collapse = ";"),
      ArtifactSetComplete = complete,
      ByteEqualityInspected = FALSE,
      NumericAgreementInspected = FALSE,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_cq_ach_placeholder_readiness <- function(arm, inference_ready = NA) {
  data.frame(
    Model = as.character(arm$Family),
    ICQuadraturePoints = as.integer(arm$Nodes),
    MMLEngineRequested = "direct", MMLEngineUsed = "direct",
    Converged = FALSE, ConvergenceCode = 1L,
    ConvergenceStatus = "not_observed", ConvergenceSeverity = "fail",
    ReviewableWarning = FALSE, FitReadiness = "not_observed",
    InferenceReady = as.logical(inference_ready), InputState = "not_observed",
    EstimabilityState = "not_observed", CategoryState = "not_observed",
    BoundaryState = "not_observed", NumericalState = "not_observed",
    ReadinessReasonCodes = "categorical_readiness_artifact_not_observed",
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ach_apply_diagnostic_eligibility <- function(
    plan, journal, artifact_inventory, representation_bridge,
    readiness_evidence = NULL) {
  mfrmr_cq_ach_p4_require_contracts()
  required_journal <- c(
    "AttemptOrder", "ScheduledOutcomeOrder", "DatasetId", "Family", "Engine",
    "Nodes", "QuadratureId", "RepresentationId", "ExpectedFreeDimension",
    "AttemptCount", "Started", "Completed", "TerminalCode", "SecondaryCode",
    "ParseableResult", "ObservedFreeDimension", "ModelIdentityMatch",
    "RegisteredFailureCount", "ExitStatus", "TerminalMarkerObserved",
    "InferenceReady", "AutomaticRetryPermitted", "NumericAgreementInspected"
  )
  attempt_plan <- plan[plan$AttemptCap == 1L, , drop = FALSE]
  mfrmr_cq_ach_assert(
    nrow(plan) == 230L && nrow(journal) == 190L &&
      all(required_journal %in% names(journal)) &&
      identical(as.integer(journal$AttemptOrder), 1:190) &&
      all(journal$Completed) &&
      all(journal$AttemptCount == as.integer(journal$Started)) &&
      mfrmr_cq_ach_p4_same_frame(
        journal, attempt_plan,
        c("AttemptOrder", "ScheduledOutcomeOrder", "DatasetId", "Family",
          "Engine", "Nodes", "QuadratureId", "RepresentationId",
          "ExpectedFreeDimension")
      ),
    "G4N application requires the exact completed 190-attempt ledger."
  )
  artifact <- mfrmr_cq_ach_artifact_completeness(
    artifact_inventory, journal, plan
  )
  bridge_required <- !is.na(attempt_plan$RepresentationBridgeContractId)
  bridge_pass <- rep(TRUE, nrow(attempt_plan))
  for (index in which(bridge_required)) {
    current <- representation_bridge[
      representation_bridge$DatasetId == attempt_plan$DatasetId[index],
      , drop = FALSE
    ]
    bridge_pass[index] <- nrow(current) == 4L && all(current$Passed)
  }
  rows <- lapply(seq_len(nrow(journal)), function(index) {
    arm <- attempt_plan[index, , drop = FALSE]
    attempt <- journal[index, , drop = FALSE]
    attempt$StructuralDispositionFromRetainedG3 <-
      arm$ExpectedStructuralDisposition
    attempt$AttemptCap <- arm$AttemptCap
    attempt$ArtifactSetComplete <- artifact$ArtifactSetComplete[index]
    attempt$SemanticBridgeSatisfied <- bridge_pass[index]
    observed_readiness <- NULL
    if (attempt$Engine == "mfrmr" && !is.null(readiness_evidence)) {
      observed_readiness <- readiness_evidence[
        readiness_evidence$AttemptOrder == attempt$AttemptOrder,
        , drop = FALSE
      ]
    }
    readiness_count <- if (is.null(observed_readiness)) {
      0L
    } else {
      nrow(observed_readiness)
    }
    readiness_required <- attempt$Engine == "mfrmr" &&
      attempt$TerminalCode %in% c(
        "complete_numeric_eligible",
        "optimizer_nonconvergence_or_readiness_hold"
      ) && isTRUE(attempt$ParseableResult)
    mfrmr_cq_ach_assert(
      !readiness_required || readiness_count == 1L,
      "A parseable mfrmr candidate requires one observed readiness row."
    )
    readiness <- if (attempt$Engine == "mfrmr") {
      if (readiness_count == 1L) {
        observed_readiness
      } else {
        mfrmr_cq_ach_placeholder_readiness(arm, attempt$InferenceReady)
      }
    } else {
      NULL
    }
    classified <- mfrmr_cq_adne_classify_attempt(attempt, readiness)
    data.frame(
      AttemptOrder = attempt$AttemptOrder,
      ScheduledOutcomeOrder = attempt$ScheduledOutcomeOrder,
      DatasetId = attempt$DatasetId,
      Family = attempt$Family,
      Engine = attempt$Engine,
      QuadratureId = attempt$QuadratureId,
      RepresentationId = attempt$RepresentationId,
      ReadinessEvidenceObserved = readiness_count == 1L,
      classified,
      stringsAsFactors = FALSE
    )
  })
  eligibility <- do.call(rbind, rows)
  rownames(eligibility) <- NULL
  mfrmr_cq_ach_assert(
    nrow(eligibility) == 190L &&
      identical(as.integer(eligibility$AttemptOrder), 1:190) &&
      all(eligibility$TerminalCodePreserved) &&
      all(eligibility$TerminalCodeBeforeContract == journal$TerminalCode) &&
      all(eligibility$TerminalCodeAfterContract == journal$TerminalCode) &&
      all(eligibility$InferenceReadyPreserved) &&
      !any(eligibility$NumericValueInspected),
    "P4 changed a terminal/readiness state while applying G4N."
  )
  updated <- journal
  updated$DiagnosticNumericEligible <- eligibility$DiagnosticNumericEligible
  list(journal = updated, diagnostic_eligibility = eligibility)
}

mfrmr_cq_ach_finalize_outcomes <- function(
    plan, journal, outcome, diagnostic_eligibility = NULL,
    global_abort_triggered = FALSE, global_abort_reason = NA_character_) {
  mfrmr_cq_ach_p4_require_contracts()
  attempt_plan <- plan[plan$AttemptCap == 1L, , drop = FALSE]
  mfrmr_cq_ach_assert(
    nrow(plan) == 230L && nrow(journal) == 190L && nrow(outcome) == 230L &&
      identical(as.integer(plan$ScheduledOutcomeOrder), 1:230) &&
      identical(as.integer(journal$AttemptOrder), 1:190) &&
      identical(as.integer(outcome$ScheduledOutcomeOrder), 1:230) &&
      mfrmr_cq_ach_p4_same_frame(
        journal, attempt_plan,
        c("AttemptOrder", "ScheduledOutcomeOrder", "DatasetId", "Engine",
          "QuadratureId", "RepresentationId")
      ) && mfrmr_cq_ach_p4_same_frame(
        outcome, plan,
        c("ScheduledOutcomeOrder", "AttemptOrder", "DatasetId", "Engine",
          "QuadratureId", "RepresentationId")
      ),
    "P4 finalization requires the exact 230-row/190-attempt ledgers."
  )
  pending <- !journal$Started
  if (any(pending)) {
    mfrmr_cq_ach_assert(
      isTRUE(global_abort_triggered) && length(global_abort_reason) == 1L &&
        !is.na(global_abort_reason) && nzchar(global_abort_reason),
      paste(
        "Unattempted eligible rows may be finalized only after a registered",
        "global resource abort."
      )
    )
    journal$Completed[pending] <- TRUE
    journal$TerminalCode[pending] <- "global_resource_abort_unattempted"
    journal$SecondaryCode[pending] <- as.character(global_abort_reason)
    journal$ParseableResult[pending] <- FALSE
    journal$ModelIdentityMatch[pending] <- FALSE
    journal$RegisteredFailureCount[pending] <- 1L
    journal$DiagnosticNumericEligible[pending] <- FALSE
  }
  mfrmr_cq_ach_assert(
    all(journal$Completed) &&
      all(journal$AttemptCount == as.integer(journal$Started)) &&
      !any(journal$AutomaticRetryPermitted) &&
      !any(journal$NumericAgreementInspected),
    "P4 cannot finalize an incomplete, retried, or inspected attempt ledger."
  )
  taxonomy <- mfrmr_cq_acf_failure_taxonomy()$TerminalCode
  mfrmr_cq_ach_assert(
    all(journal$TerminalCode %in% taxonomy),
    "P4 received an unregistered terminal code."
  )
  before_terminal <- journal$TerminalCode
  if (!is.null(diagnostic_eligibility)) {
    mfrmr_cq_ach_assert(
      nrow(diagnostic_eligibility) == 190L &&
        identical(
          as.integer(diagnostic_eligibility$AttemptOrder),
          as.integer(journal$AttemptOrder)
        ) && all(diagnostic_eligibility$TerminalCodePreserved) &&
        all(diagnostic_eligibility$TerminalCodeBeforeContract ==
              journal$TerminalCode) &&
        all(diagnostic_eligibility$TerminalCodeAfterContract ==
              journal$TerminalCode),
      "P4 finalization rejected a relabelled G4N eligibility ledger."
    )
    journal$DiagnosticNumericEligible <-
      diagnostic_eligibility$DiagnosticNumericEligible
  }
  index <- match(journal$ScheduledOutcomeOrder, outcome$ScheduledOutcomeOrder)
  outcome$Attempted[index] <- journal$Started
  outcome$TerminalCode[index] <- journal$TerminalCode
  outcome$SecondaryCode[index] <- journal$SecondaryCode
  outcome$ParseableResult[index] <- journal$ParseableResult
  outcome$ModelIdentityMatch[index] <- journal$ModelIdentityMatch
  outcome$DiagnosticNumericEligible[index] <-
    journal$DiagnosticNumericEligible
  outcome$InferenceReady[index] <- journal$InferenceReady
  primary <- plan$PrimaryAnalysisRole[index]
  outcome$CalibrationMetricUsePermitted[index] <-
    journal$DiagnosticNumericEligible & primary
  negative <- plan$AttemptCap == 0L
  accounting_complete <- nrow(outcome) == 230L &&
    all(outcome$RowRetained) && !any(outcome$NumericAgreementInspected) &&
    sum(negative) == 40L && !any(outcome$Attempted[negative]) &&
    all(outcome$TerminalCode[negative] == "expected_structural_rejection") &&
    all(outcome$TerminalCode %in% taxonomy) &&
    identical(before_terminal, journal$TerminalCode) &&
    identical(as.logical(outcome$Attempted[index]), as.logical(journal$Started))
  mfrmr_cq_ach_assert(
    accounting_complete,
    "P4 finalization failed exact retained-row accounting."
  )
  list(
    journal = journal,
    outcome = outcome,
    audit = data.frame(
      RetainedDatasets = length(unique(outcome$DatasetId)),
      RetainedOutcomeRows = nrow(outcome),
      RetainedAttemptRows = nrow(journal),
      AttemptedFits = sum(journal$Started),
      UnattemptedAfterGlobalAbort = sum(!journal$Started),
      ExpectedStructuralRejections = sum(
        outcome$TerminalCode == "expected_structural_rejection"
      ),
      TerminalCodesChangedByG4N = sum(
        before_terminal != journal$TerminalCode
      ),
      RowsDropped = 230L - nrow(outcome),
      AccountingComplete = accounting_complete,
      NumericAgreementInspected = FALSE,
      stringsAsFactors = FALSE
    )
  )
}

mfrmr_cq_ach_metric_observation_template <- function() {
  data.frame(
    SummaryId = character(0), UnitId = character(0),
    Stratum = character(0), Value = numeric(0),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ach_metric_units <- function(
    plan, outcome, diagnostic_eligibility,
    artifact_registry = mfrmr_cq_ach_expected_artifact_registry(plan)) {
  eligible <- setNames(
    as.logical(diagnostic_eligibility$DiagnosticNumericEligible),
    as.character(diagnostic_eligibility$AttemptOrder)
  )
  attempt <- plan[plan$AttemptCap == 1L, , drop = FALSE]
  attempt$Eligible <- eligible[as.character(attempt$AttemptOrder)]
  attempt$AttemptUnit <- sprintf("attempt:%03d", attempt$AttemptOrder)
  first_dataset <- !duplicated(plan$DatasetId)
  engine_q61 <- function(engine) {
    current <- plan[plan$Engine == engine & plan$Nodes == 61L &
                      !duplicated(paste(plan$DatasetId, plan$Engine)),
                    , drop = FALSE]
    data.frame(UnitId = current$DatasetId, Eligible = NA, stringsAsFactors = FALSE)
  }
  pair_units <- function(field) {
    current <- attempt[!is.na(attempt[[field]]), , drop = FALSE]
    split_current <- split(current, current[[field]])
    data.frame(
      UnitId = names(split_current),
      Eligible = vapply(
        split_current,
        function(value) nrow(value) == 2L && all(value$Eligible),
        logical(1L)
      ),
      stringsAsFactors = FALSE
    )
  }
  primary <- attempt$PrimaryAnalysisRole
  truth <- data.frame(
    UnitId = attempt$AttemptUnit[primary], Eligible = attempt$Eligible[primary],
    stringsAsFactors = FALSE
  )
  cross <- pair_units("CrossEnginePairId")
  quadrature <- pair_units("QuadraturePairId")
  representation <- pair_units("RepresentationPairId")
  all_attempt <- data.frame(
    UnitId = attempt$AttemptUnit, Eligible = attempt$Eligible,
    stringsAsFactors = FALSE
  )
  units <- list(
    "ASP-STRUCTURAL-DISPOSITION" = data.frame(
      UnitId = plan$DatasetId[first_dataset], Eligible = NA,
      stringsAsFactors = FALSE
    ),
    "ASP-CONQUEST-EXECUTION" = engine_q61("ConQuest"),
    "ASP-MFRMR-EXECUTION" = engine_q61("mfrmr"),
    "ASP-JOINT-NUMERIC-ELIGIBILITY" = cross,
    "ASP-PROBABILITY-TRUTH-ERROR" = truth,
    "ASP-CONTINUOUS-TARGET-ORACLE-ERROR" = truth,
    "ASP-PARAMETER-BIAS" = truth,
    "ASP-PARAMETER-RMSE" = truth,
    "ASP-CROSS-ENGINE-COORDINATE-DIFFERENCE" = cross,
    "ASP-QUADRATURE-SENSITIVITY" = quadrature,
    "ASP-FALSE-READY-OR-FALSE-PASS" = all_attempt,
    "ASP-REPRESENTATION-INVARIANCE" = representation,
    "ASP-ELAPSED-RUNTIME" = all_attempt,
    "ASP-RETAINED-STORAGE" = data.frame(
      UnitId = artifact_registry$RelativePath, Eligible = NA,
      stringsAsFactors = FALSE
    )
  )
  expected <- c(90L, 90L, 90L, 90L, 180L, 180L, 180L, 180L,
                90L, 40L, 190L, 10L, 190L, 1511L)
  observed <- vapply(units, nrow, integer(1L))
  mfrmr_cq_ach_assert(
    identical(unname(observed), expected) &&
      identical(names(units), mfrmr_cq_adne_metric_use_registry()$SummaryId),
    "The P4 metric-unit denominators drifted from the frozen workload."
  )
  units
}

mfrmr_cq_ach_metric_summary <- function(
    plan, outcome, diagnostic_eligibility,
    numeric_observations = mfrmr_cq_ach_metric_observation_template(),
    artifact_registry = mfrmr_cq_ach_expected_artifact_registry(plan)) {
  mfrmr_cq_ach_p4_require_contracts()
  mfrmr_cq_ach_assert(
    nrow(plan) == 230L && nrow(outcome) == 230L &&
      nrow(diagnostic_eligibility) == 190L &&
      identical(as.integer(diagnostic_eligibility$AttemptOrder), 1:190) &&
      is.data.frame(numeric_observations) && all(c(
        "SummaryId", "UnitId", "Stratum", "Value"
      ) %in% names(numeric_observations)) &&
      all(is.finite(numeric_observations$Value)),
    "P4 metric summarization requires exact ledgers and finite typed values."
  )
  registry <- mfrmr_cq_adne_metric_use_registry()
  summary_registry <- mfrmr_cq_acf_summary_registry()
  units <- mfrmr_cq_ach_metric_units(
    plan, outcome, diagnostic_eligibility, artifact_registry
  )
  numeric_ids <- c(
    registry$SummaryId[
      registry$UseClass == "conditional_exploratory_diagnostic_numeric"
    ],
    "ASP-ELAPSED-RUNTIME", "ASP-RETAINED-STORAGE"
  )
  mfrmr_cq_ach_assert(
    all(numeric_observations$SummaryId %in% numeric_ids) &&
      all(!is.na(numeric_observations$Stratum)) &&
      all(nzchar(numeric_observations$Stratum)) &&
      !anyDuplicated(paste(
        numeric_observations$SummaryId, numeric_observations$UnitId, sep = "\r"
      )),
    "P4 metric observations are unregistered or duplicated."
  )
  rows <- lapply(seq_len(nrow(registry)), function(index) {
    summary_id <- registry$SummaryId[index]
    current_units <- units[[summary_id]]
    conditional <- registry$UseClass[index] ==
      "conditional_exploratory_diagnostic_numeric"
    expected_units <- if (conditional) {
      current_units$UnitId[which(current_units$Eligible %in% TRUE)]
    } else if (summary_id == "ASP-ELAPSED-RUNTIME") {
      attempted_order <- outcome$AttemptOrder[outcome$Attempted &
                                                !is.na(outcome$AttemptOrder)]
      sprintf("attempt:%03d", attempted_order)
    } else if (summary_id == "ASP-RETAINED-STORAGE") {
      current_units$UnitId
    } else {
      character(0)
    }
    observation <- numeric_observations[
      numeric_observations$SummaryId == summary_id, , drop = FALSE
    ]
    mfrmr_cq_ach_assert(
      all(observation$UnitId %in% expected_units),
      paste0("P4 rejected an ineligible unit for `", summary_id, "`.")
    )
    coverage <- setequal(observation$UnitId, expected_units)
    value <- observation$Value
    computed <- length(value) > 0L && coverage
    eligibility_available <- any(!is.na(current_units$Eligible))
    accounting <- data.frame(
      SummaryId = summary_id,
      RecordType = "accounting",
      Stratum = NA_character_,
      UnitId = NA_character_,
      ObservationValue = NA_real_,
      UseClass = registry$UseClass[index],
      EligibilityRequirement = registry$EligibilityRequirement[index],
      PrimaryStatistic = summary_registry$Statistic[
        match(summary_id, summary_registry$SummaryId)
      ],
      UnconditionalDenominator = nrow(current_units),
      ConditionalDiagnosticDenominator = if (conditional) {
        length(expected_units)
      } else {
        NA_integer_
      },
      NonNumericOrFailureCount = if (conditional) {
        nrow(current_units) - length(expected_units)
      } else {
        NA_integer_
      },
      DiagnosticEligibilityAccountingAvailable = eligibility_available,
      DiagnosticEligibleCount = if (eligibility_available) {
        sum(current_units$Eligible %in% TRUE)
      } else {
        NA_integer_
      },
      DiagnosticIneligibleCount = if (eligibility_available) {
        sum(current_units$Eligible %in% FALSE)
      } else {
        NA_integer_
      },
      DiagnosticEligibilityUnknownCount = if (eligibility_available) {
        sum(is.na(current_units$Eligible))
      } else {
        NA_integer_
      },
      ExpectedNumericUnitCount = length(expected_units),
      NumericObservationCount = nrow(observation),
      StratumNumericUnitCount = NA_integer_,
      NumericCoverageComplete = coverage,
      NumericSummaryComputed = FALSE,
      PrimaryEstimate = NA_real_,
      Mean = NA_real_, SD = NA_real_, Median = NA_real_, P90 = NA_real_,
      Minimum = NA_real_, Maximum = NA_real_, Total = NA_real_,
      FailureRowsRetained = TRUE,
      PrimaryPooledSummaryPermitted = FALSE,
      ThresholdApplied = FALSE,
      ConfirmationUsePermitted = FALSE,
      EvidencePromotionPermitted = FALSE,
      PublicClaimPermitted = FALSE,
      ScientificEquivalenceInferred = FALSE,
      ByteEqualityInspected = FALSE,
      stringsAsFactors = FALSE
    )
    if (!computed) return(accounting)
    observation_rows <- lapply(seq_len(nrow(observation)), function(row_index) {
      current <- observation[row_index, , drop = FALSE]
      row <- accounting
      row$RecordType <- "observation"
      row$Stratum <- current$Stratum
      row$UnitId <- current$UnitId
      row$ObservationValue <- current$Value
      row$NumericObservationCount <- 1L
      row$StratumNumericUnitCount <- 1L
      row
    })
    split_observation <- split(observation, observation$Stratum)
    stratum <- lapply(names(split_observation), function(stratum_id) {
      current <- split_observation[[stratum_id]]
      stratum_value <- current$Value
      row <- accounting
      row$RecordType <- "stratum"
      row$Stratum <- stratum_id
      row$StratumNumericUnitCount <- nrow(current)
      row$NumericObservationCount <- nrow(current)
      row$NumericSummaryComputed <- TRUE
      row$Mean <- mean(stratum_value)
      row$SD <- if (length(stratum_value) > 1L) {
        stats::sd(stratum_value)
      } else {
        NA_real_
      }
      row$Median <- stats::median(stratum_value)
      row$P90 <- unname(stats::quantile(stratum_value, 0.9))
      row$Minimum <- min(stratum_value)
      row$Maximum <- max(stratum_value)
      row$Total <- sum(stratum_value)
      row$PrimaryEstimate <- if (summary_id == "ASP-PARAMETER-RMSE") {
        sqrt(mean(stratum_value^2))
      } else if (summary_id %in% c(
        "ASP-ELAPSED-RUNTIME", "ASP-RETAINED-STORAGE"
      )) {
        sum(stratum_value)
      } else {
        mean(stratum_value)
      }
      row
    })
    do.call(rbind, c(list(accounting), observation_rows, stratum))
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  mfrmr_cq_ach_assert(
    sum(out$RecordType == "accounting") == 14L &&
      !any(out$RecordType == "accounting" & out$NumericSummaryComputed) &&
      sum(out$RecordType == "observation") == nrow(numeric_observations) &&
      !any(out$RecordType == "observation" & out$NumericSummaryComputed) &&
      !any(out$PrimaryPooledSummaryPermitted) &&
      all(out$FailureRowsRetained) &&
      !any(out$ThresholdApplied) && !any(out$ConfirmationUsePermitted) &&
      !any(out$EvidencePromotionPermitted) &&
      !any(out$PublicClaimPermitted) &&
      !any(out$ScientificEquivalenceInferred) &&
      !any(out$ByteEqualityInspected),
    "The P4 metric summary crossed its exploratory-use boundary."
  )
  out
}

mfrmr_cq_ach_authorization_schema <- function() {
  data.frame(
    FieldOrder = 1:27,
    Field = c(
      "AuthorizationContract", "HarnessContract", "AuthorizationIdentity",
      "ProcessId", "OutputDir", "ExecutablePath", "AuthorizationDate",
      "RunNotAfter", "DatasetCount", "ScheduledOutcomeRows", "AttemptCount",
      "Q61AttemptCount", "Q121AttemptCount", "GenerationAuthorized",
      "ExecutionAuthorized", "OneRunOnly", "Consumed", "ConsumedAt",
      "OutputTargetAbsentAtAuthorization", "IncompleteTargetAbsentAtAuthorization",
      "ResultsOpened", "NumericAgreementInspected",
      "ConfirmationOrPublicUsePermitted", "FreshSentinelRequiredAfterConsumption",
      "SourceTreeClean", "OrdinaryTestsExternalRuntimeFree",
      "AuthorizationIssuedByP4"
    ),
    P4RequiredValue = c(
      mfrmr_cq_ach_run_authorization_contract, mfrmr_cq_ach_contract,
      "tranche_A::datasets=90::outcomes=230::attempts=190::q61=150::q121=40",
      "current_process", "exact_absent_target", mfrmr_cq_acf_conquest_path,
      "2026-08-16_through_2026-08-31", "2026-08-31", "90", "230", "190",
      "150", "40", "TRUE", "TRUE", "TRUE", "FALSE", "NA",
      "TRUE", "TRUE", "FALSE", "FALSE", "FALSE", "TRUE", "TRUE", "TRUE",
      "FALSE"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ach_consume_authorization <- function(
    authorization, calibration_output_dir, authorize = FALSE) {
  mfrmr_cq_ach_p4_require_contracts()
  schema <- mfrmr_cq_ach_authorization_schema()
  mfrmr_cq_ach_assert(
    identical(authorize, TRUE),
    "The P4 run-once authorization consumer is held."
  )
  mfrmr_cq_ach_assert(
    is.environment(authorization) &&
      inherits(authorization, "mfrmr_cq_ach_run_once_authorization") &&
      setequal(ls(authorization, all.names = TRUE), schema$Field),
    "P4 requires one exact mutable run-once authorization record."
  )
  target <- normalizePath(
    calibration_output_dir, winslash = "/", mustWork = FALSE
  )
  executable <- normalizePath(
    mfrmr_cq_acf_conquest_path, winslash = "/", mustWork = FALSE
  )
  date <- as.Date(authorization$AuthorizationDate)[1L]
  valid <- identical(
    authorization$AuthorizationContract,
    mfrmr_cq_ach_run_authorization_contract
  ) && identical(authorization$HarnessContract, mfrmr_cq_ach_contract) &&
    identical(
      authorization$AuthorizationIdentity,
      "tranche_A::datasets=90::outcomes=230::attempts=190::q61=150::q121=40"
    ) && identical(authorization$ProcessId, as.integer(Sys.getpid())) &&
    identical(
      normalizePath(authorization$OutputDir, winslash = "/", mustWork = FALSE),
      target
    ) && identical(basename(target), mfrmr_cq_ataa_output_basename) &&
    identical(
      normalizePath(
        authorization$ExecutablePath, winslash = "/", mustWork = FALSE
      ), executable
    ) && file.exists(executable) && file.access(executable, 1L) == 0L &&
    !is.na(date) && date >= as.Date("2026-08-16") &&
    date <= as.Date("2026-08-31") &&
    identical(as.Date(authorization$RunNotAfter), as.Date("2026-08-31")) &&
    identical(as.integer(authorization$DatasetCount), 90L) &&
    identical(as.integer(authorization$ScheduledOutcomeRows), 230L) &&
    identical(as.integer(authorization$AttemptCount), 190L) &&
    identical(as.integer(authorization$Q61AttemptCount), 150L) &&
    identical(as.integer(authorization$Q121AttemptCount), 40L) &&
    isTRUE(authorization$GenerationAuthorized) &&
    isTRUE(authorization$ExecutionAuthorized) &&
    isTRUE(authorization$OneRunOnly) && !isTRUE(authorization$Consumed) &&
    is.na(authorization$ConsumedAt) &&
    isTRUE(authorization$OutputTargetAbsentAtAuthorization) &&
    isTRUE(authorization$IncompleteTargetAbsentAtAuthorization) &&
    !file.exists(target) && !file.exists(paste0(target, ".incomplete")) &&
    !isTRUE(authorization$ResultsOpened) &&
    !isTRUE(authorization$NumericAgreementInspected) &&
    !isTRUE(authorization$ConfirmationOrPublicUsePermitted) &&
    isTRUE(authorization$FreshSentinelRequiredAfterConsumption) &&
    isTRUE(authorization$SourceTreeClean) &&
    isTRUE(authorization$OrdinaryTestsExternalRuntimeFree) &&
    !isTRUE(authorization$AuthorizationIssuedByP4)
  mfrmr_cq_ach_assert(
    valid,
    paste(
      "The run-once authorization is stale, widened, consumed, target-",
      "mismatched, or not separately issued."
    )
  )
  authorization$Consumed <- TRUE
  authorization$ConsumedAt <- Sys.time()
  invisible(authorization)
}

mfrmr_cq_ach_dataset_generation_authority <- function(
    run_authorization, allocation, sentinel_token, calibration_output_dir) {
  registered <- mfrmr_cq_ach_registered_tranche_row(allocation)
  target <- normalizePath(
    calibration_output_dir, winslash = "/", mustWork = FALSE
  )
  mfrmr_cq_ach_assert(
    is.environment(run_authorization) &&
      inherits(run_authorization, "mfrmr_cq_ach_run_once_authorization") &&
      isTRUE(run_authorization$Consumed) &&
      identical(run_authorization$ProcessId, as.integer(Sys.getpid())) &&
      identical(
        normalizePath(
          run_authorization$OutputDir, winslash = "/", mustWork = FALSE
        ), target
      ) && !file.exists(target) &&
      mfrmr_cq_ach_validate_fresh_sentinel_token(
        sentinel_token, registered$DatasetId, registered$Seed, target
      ),
    paste(
      "Dataset authority requires a consumed same-process run record and",
      "fresh sentinel before the output target exists."
    )
  )
  authority <- new.env(parent = emptyenv())
  authority$AuthorizationIdentity <- paste(
    registered$DatasetId, registered$Seed, "tranche_A_generation", sep = "::"
  )
  authority$AuthorizationContract <- mfrmr_cq_ach_generation_authority_contract
  authority$HarnessContract <- mfrmr_cq_ach_contract
  authority$DatasetId <- registered$DatasetId
  authority$Seed <- as.integer(registered$Seed)
  authority$CalibrationOutputDir <- target
  authority$GenerationAuthorized <- TRUE
  authority$GenerationConsumed <- FALSE
  authority$OneDatasetOnly <- TRUE
  authority$OneTimeAuthorization <- TRUE
  authority$FreshRuntimeSentinelPassed <- TRUE
  authority$SentinelObservedInCurrentProcess <- TRUE
  authority$FreshSentinelToken <- sentinel_token
  authority$OutputTargetAbsentAtAuthorization <- TRUE
  authority$ResultOpened <- FALSE
  authority$ConfirmationOrPublicUsePermitted <- FALSE
  authority
}

mfrmr_cq_ach_readiness_evidence <- function(root, plan, journal) {
  required <- mfrmr_cq_adne_required_readiness_fields()
  mfrmr_plan <- plan[plan$AttemptCap == 1L & plan$Engine == "mfrmr",
                     , drop = FALSE]
  rows <- lapply(seq_len(nrow(mfrmr_plan)), function(index) {
    arm <- mfrmr_plan[index, , drop = FALSE]
    current <- journal[journal$AttemptOrder == arm$AttemptOrder, , drop = FALSE]
    path <- file.path(
      root, arm$RunDirectory, paste0(arm$Prefix, "_mfrmr_summary.csv")
    )
    if (!isTRUE(current$Started) || !file.exists(path)) return(NULL)
    header <- utils::read.csv(
      path, nrows = 0L, stringsAsFactors = FALSE, check.names = FALSE
    )
    mfrmr_cq_ach_assert(
      all(required %in% names(header)),
      "A retained P4 mfrmr summary lacks G4N readiness fields."
    )
    value <- utils::read.csv(
      path, stringsAsFactors = FALSE, check.names = FALSE, na.strings = ""
    )
    mfrmr_cq_ach_assert(
      nrow(value) == 1L,
      "A retained P4 mfrmr summary must contain one row."
    )
    data.frame(
      AttemptOrder = arm$AttemptOrder,
      value[, required, drop = FALSE],
      stringsAsFactors = FALSE
    )
  })
  rows <- Filter(Negate(is.null), rows)
  if (length(rows) == 0L) {
    out <- data.frame(AttemptOrder = integer(0), stringsAsFactors = FALSE)
    for (field in required) out[[field]] <- logical(0)
    return(out)
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_cq_ach_review_execution <- function(output_dir) {
  mfrmr_cq_ach_p4_require_contracts()
  root <- normalizePath(output_dir, winslash = "/", mustWork = TRUE)
  mfrmr_cq_ach_assert(
    identical(basename(root), mfrmr_cq_ataa_output_basename),
    "The retained P4 output target has the wrong identity."
  )
  schema <- mfrmr_cq_ach_schema_registry()
  table_path <- setNames(
    file.path(root, paste0(schema$TableId, ".csv")), schema$TableId
  )
  mfrmr_cq_ach_assert(
    all(file.exists(table_path)),
    "The retained P4 output is missing a registered root ledger."
  )
  tables <- lapply(table_path, function(path) utils::read.csv(
    path, stringsAsFactors = FALSE, check.names = FALSE, na.strings = ""
  ))
  plan <- mfrmr_cq_ach_adapter_plan()
  plan_fields <- c(
    "ScheduledOutcomeOrder", "AttemptOrder", "DatasetId", "Seed", "Family",
    "Engine", "Nodes", "QuadratureId", "RepresentationId", "AttemptCap",
    "RunId", "RunDirectory", "Prefix"
  )
  plan_complete <- mfrmr_cq_ach_p4_same_frame(
    tables$execution_plan, plan, plan_fields
  )
  journal <- tables$attempt_journal
  outcome <- tables$engine_outcome
  eligibility <- tables$diagnostic_eligibility
  finalization <- tryCatch(
    mfrmr_cq_ach_finalize_outcomes(
      plan, journal, outcome, eligibility,
      global_abort_triggered = isTRUE(tables$resource_summary$GlobalAbortTriggered),
      global_abort_reason = if (
        isTRUE(tables$resource_summary$GlobalAbortTriggered)
      ) as.character(tables$resource_summary$GlobalAbortReason) else NA_character_
    ),
    error = function(error) NULL
  )
  expected_registry <- mfrmr_cq_ach_expected_artifact_registry(plan)
  observed_inventory <- mfrmr_cq_ach_artifact_inventory(root, plan)
  boundary_complete <- isTRUE(observed_inventory$output_boundary_inspected) &&
    isTRUE(observed_inventory$unexpected_file_guard_passed)
  artifact_complete <- mfrmr_cq_ach_p4_same_frame(
    tables$artifact_inventory, observed_inventory$registry,
    c("AttemptOrder", "Engine", "Nodes", "ArtifactKind", "RelativePath",
      "Requirement", "Present", "Nonempty")
  )
  attempt_artifact <- tryCatch(
    mfrmr_cq_ach_artifact_completeness(
      observed_inventory, journal, plan
    ),
    error = function(error) NULL
  )
  outcome_artifacts_complete <- !is.null(attempt_artifact) &&
    all(attempt_artifact$ArtifactSetComplete)
  sentinel_row <- observed_inventory$registry$ArtifactKind ==
    "fresh_runtime_sentinel_console"
  sentinel_artifact_complete <- sum(sentinel_row) == 1L &&
    isTRUE(observed_inventory$registry$Present[sentinel_row]) &&
    isTRUE(observed_inventory$registry$Nonempty[sentinel_row])
  readiness <- mfrmr_cq_ach_readiness_evidence(root, plan, journal)
  reapplied <- tryCatch(
    mfrmr_cq_ach_apply_diagnostic_eligibility(
      plan, journal, observed_inventory,
      tables$representation_bridge, readiness
    ),
    error = function(error) NULL
  )
  eligibility_reproduced <- !is.null(reapplied) &&
    mfrmr_cq_ach_p4_same_frame(
      eligibility, reapplied$diagnostic_eligibility,
      names(reapplied$diagnostic_eligibility)
    )
  retained_observation <- tables$metric_summary[
    tables$metric_summary$RecordType == "observation", , drop = FALSE
  ]
  retained_observation <- data.frame(
    SummaryId = retained_observation$SummaryId,
    UnitId = retained_observation$UnitId,
    Stratum = retained_observation$Stratum,
    Value = as.numeric(retained_observation$ObservationValue),
    stringsAsFactors = FALSE
  )
  metric_recomputed <- tryCatch(
    mfrmr_cq_ach_metric_summary(
      plan, outcome, eligibility, retained_observation,
      artifact_registry = expected_registry
    ),
    error = function(error) NULL
  )
  observed_accounting <- tables$metric_summary[
    tables$metric_summary$RecordType == "accounting", , drop = FALSE
  ]
  metric_contract_complete <- !is.null(metric_recomputed) &&
    mfrmr_cq_ach_p4_same_frame(
      tables$metric_summary, metric_recomputed, names(metric_recomputed)
    ) && all(observed_accounting$NumericCoverageComplete) &&
    !any(tables$metric_summary$PrimaryPooledSummaryPermitted) &&
    !any(tables$metric_summary$ThresholdApplied)
  authority <- tables$authority_snapshot
  authorization_consumed <- nrow(authority) == 1L &&
    isTRUE(authority$Consumed) && !is.na(authority$ConsumedAt) &&
    !isTRUE(authority$ConfirmationOrPublicUsePermitted) &&
    !isTRUE(authority$AuthorizationIssuedByP4)
  generation_complete <- nrow(tables$generation_journal) == 90L &&
    all(tables$generation_journal$Generated) &&
    all(tables$generation_journal$RowRetained)
  semantic_tables_complete <- nrow(tables$dataset_manifest) == 90L &&
    nrow(tables$truth_registry) == 90L &&
    nrow(tables$structural_disposition) == 90L &&
    nrow(tables$representation_bridge) == 40L &&
    all(tables$representation_bridge$Passed)
  complete <- plan_complete && generation_complete &&
    semantic_tables_complete && !is.null(finalization) &&
    isTRUE(finalization$audit$AccountingComplete) &&
    artifact_complete && outcome_artifacts_complete &&
    sentinel_artifact_complete && boundary_complete && eligibility_reproduced &&
    metric_contract_complete && authorization_consumed &&
    nrow(tables$resource_summary) == 1L &&
    nrow(tables$execution_summary) == 1L
  list(
    specification = mfrmr_cq_ach_p4_specification,
    contract_version = mfrmr_cq_ach_contract,
    status = if (complete) {
      "ASP_G4C_tranche_A_retained_execution_review_complete_exploratory_only"
    } else {
      "ASP_G4C_tranche_A_retained_execution_hold_incomplete_or_invalid"
    },
    output_dir = root,
    tables = tables,
    finalization = finalization,
    plan_complete = plan_complete,
    generation_complete = generation_complete,
    semantic_tables_complete = semantic_tables_complete,
    artifact_inventory_reconstructed = artifact_complete,
    outcome_artifacts_complete = outcome_artifacts_complete,
    sentinel_artifact_complete = sentinel_artifact_complete,
    no_unexpected_artifact = boundary_complete,
    diagnostic_eligibility_reproduced = eligibility_reproduced,
    metric_contract_complete = metric_contract_complete,
    run_once_authorization_consumed = authorization_consumed,
    retained_execution_review_complete = complete,
    rerun_authorized = FALSE,
    confirmation_use_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE,
    byte_equality_accepted_as_scientific_evidence = FALSE
  )
}

mfrmr_cq_ach_dry_run_review <- function(
    g4x_output_dir, calibration_output_dir,
    smoke_output_dir = file.path(
      dirname(g4x_output_dir), mfrmr_cq_ase_output_basename
    )) {
  mfrmr_cq_ach_p4_require_contracts()
  p3 <- mfrmr_cq_ach_p3_review(
    g4x_output_dir, calibration_output_dir, smoke_output_dir
  )
  g4a <- mfrmr_cq_ataa_review(g4x_output_dir, calibration_output_dir)
  plan <- mfrmr_cq_ach_adapter_plan()
  journal <- mfrmr_cq_ach_attempt_journal_template(plan)
  outcome <- mfrmr_cq_ach_outcome_template(plan)
  eligibility <- data.frame(
    AttemptOrder = journal$AttemptOrder,
    DiagnosticNumericEligible = FALSE,
    stringsAsFactors = FALSE
  )
  summary <- mfrmr_cq_ach_metric_summary(plan, outcome, eligibility)
  capability <- mfrmr_cq_ataa_harness_capability_registry()
  authorization_schema <- mfrmr_cq_ach_authorization_schema()
  complete <- identical(
    p3$status,
    paste0(
      "ASP_G4C_P3_engine_adapters_artifacts_resources_frozen_",
      "integrated_harness_incomplete"
    )
  ) && all(capability$ProviderAvailable) && nrow(plan) == 230L &&
    nrow(journal) == 190L && nrow(outcome) == 230L &&
    nrow(summary) == 14L &&
    identical(summary$UnconditionalDenominator,
              c(90L, 90L, 90L, 90L, rep(180L, 4L), 90L, 40L,
                190L, 10L, 190L, 1511L)) &&
    all(summary$FailureRowsRetained) && !any(summary$ThresholdApplied) &&
    nrow(authorization_schema) == 27L &&
    !any(authorization_schema$Field == "AuthorizationIssuedByP4" &
           authorization_schema$P4RequiredValue != "FALSE") &&
    identical(
      g4a$status,
      "ASP_G4A_harness_ready_separate_live_authorization_required"
    ) && !file.exists(calibration_output_dir)
  list(
    specification = mfrmr_cq_ach_p4_specification,
    contract_version = mfrmr_cq_ach_contract,
    status = if (complete) {
      paste0(
        "ASP_G4C_P4_integrated_dry_run_harness_frozen_",
        "separate_live_authorization_required"
      )
    } else {
      "ASP_G4C_P4_integrated_harness_hold"
    },
    p3_review = p3,
    g4a_review = g4a,
    plan = plan,
    empty_attempt_journal = journal,
    empty_outcome_ledger = outcome,
    empty_metric_summary = summary,
    authorization_schema = authorization_schema,
    upstream_and_harness_capabilities_available =
      sum(capability$ProviderAvailable),
    harness_capabilities_still_missing = sum(!capability$ProviderAvailable),
    complete_outcome_finalizer_implemented = TRUE,
    terminal_nonmutating_G4N_application_implemented = TRUE,
    conditional_and_unconditional_metric_summarizer_implemented = TRUE,
    run_once_authorization_consumer_implemented = TRUE,
    retained_execution_reviewer_implemented = TRUE,
    retained_execution_review_performed = FALSE,
    tranche_A_responses_generated = FALSE,
    fit_attempts = 0L,
    ConQuest_execution_attempted = FALSE,
    positive_live_authorization_issued_by_P4 = FALSE,
    response_generation_authorized = FALSE,
    execution_authorized = FALSE,
    fresh_tranche_A_sentinel_observed = FALSE,
    numeric_agreement_inspected = FALSE,
    threshold_selected = FALSE,
    confirmation_use_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE,
    next_action = "ASP-G4L-TRANCHE-A-LIVE-AUTHORIZATION-FREEZE"
  )
}
