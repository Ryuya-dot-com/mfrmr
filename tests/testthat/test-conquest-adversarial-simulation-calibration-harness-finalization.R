load_conquest_adversarial_simulation_calibration_p4 <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  paths <- file.path(validation, c(
    "conquest-semantic-runtime-preflight-0.2.3.R",
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-adversarial-simulation-program-0.2.3.R",
    "conquest-adversarial-simulation-template-contract-0.2.3.R",
    "conquest-adversarial-simulation-dgp-oracle-contract-0.2.3.R",
    "conquest-adversarial-simulation-smoke-authorization-0.2.3.R",
    "conquest-adversarial-simulation-smoke-execution-0.2.3.R",
    "conquest-adversarial-simulation-calibration-freeze-0.2.3.R",
    "conquest-adversarial-simulation-engine-mechanics-authorization-0.2.3.R",
    "conquest-adversarial-simulation-engine-mechanics-harness-0.2.3.R",
    "conquest-adversarial-simulation-post-mechanics-calibration-review-0.2.3.R",
    paste0(
      "conquest-adversarial-simulation-diagnostic-numeric-",
      "eligibility-addendum-0.2.3.R"
    ),
    "conquest-adversarial-simulation-tranche-a-authorization-review-0.2.3.R",
    "conquest-adversarial-simulation-calibration-harness-0.2.3.R",
    paste0(
      "conquest-adversarial-simulation-calibration-harness-engine-",
      "adapters-0.2.3.R"
    ),
    paste0(
      "conquest-adversarial-simulation-calibration-harness-",
      "finalization-0.2.3.R"
    )
  ))
  skip_if_not(all(file.exists(paths)), "ConQuest ASP G4C-P4 files excluded.")
  pkgload::load_all(root, quiet = TRUE)
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(
    root = root, validation = validation, paths = paths, env = env,
    smoke_output = file.path(
      root, "validation-results", env$mfrmr_cq_ase_output_basename
    ),
    g4x_output = file.path(
      root, "validation-results", env$mfrmr_cq_amea_output_basename
    ),
    calibration_output = file.path(
      root, "validation-results", env$mfrmr_cq_ataa_output_basename
    )
  )
}

synthetic_p4_bridge <- function(plan) {
  dataset_id <- unique(plan$DatasetId[
    !is.na(plan$RepresentationBridgeContractId)
  ])
  data.frame(
    DatasetId = rep(dataset_id, each = 4L),
    Passed = TRUE,
    stringsAsFactors = FALSE
  )
}

synthetic_p4_authorization <- function(ctx, target) {
  authorization <- new.env(parent = emptyenv())
  values <- list(
    AuthorizationContract = ctx$env$mfrmr_cq_ach_run_authorization_contract,
    HarnessContract = ctx$env$mfrmr_cq_ach_contract,
    AuthorizationIdentity = paste0(
      "tranche_A::datasets=90::outcomes=230::attempts=190::",
      "q61=150::q121=40"
    ),
    ProcessId = as.integer(Sys.getpid()),
    OutputDir = target,
    ExecutablePath = "/Applications/ConQuest/ConQuest",
    AuthorizationDate = as.Date("2026-08-16"),
    RunNotAfter = as.Date("2026-08-31"),
    DatasetCount = 90L,
    ScheduledOutcomeRows = 230L,
    AttemptCount = 190L,
    Q61AttemptCount = 150L,
    Q121AttemptCount = 40L,
    GenerationAuthorized = TRUE,
    ExecutionAuthorized = TRUE,
    OneRunOnly = TRUE,
    Consumed = FALSE,
    ConsumedAt = as.POSIXct(NA),
    OutputTargetAbsentAtAuthorization = TRUE,
    IncompleteTargetAbsentAtAuthorization = TRUE,
    ResultsOpened = FALSE,
    NumericAgreementInspected = FALSE,
    ConfirmationOrPublicUsePermitted = FALSE,
    FreshSentinelRequiredAfterConsumption = TRUE,
    SourceTreeClean = TRUE,
    OrdinaryTestsExternalRuntimeFree = TRUE,
    AuthorizationIssuedByP4 = FALSE
  )
  list2env(values, envir = authorization)
  class(authorization) <- "mfrmr_cq_ach_run_once_authorization"
  authorization
}

test_that("P4 finalization retains all rows and needs a real global abort", {
  ctx <- load_conquest_adversarial_simulation_calibration_p4()
  plan <- ctx$env$mfrmr_cq_ach_adapter_plan()
  journal <- ctx$env$mfrmr_cq_ach_attempt_journal_template(plan)
  outcome <- ctx$env$mfrmr_cq_ach_outcome_template(plan)
  started <- 1:2
  journal$Started[started] <- TRUE
  journal$Completed[started] <- TRUE
  journal$AttemptCount[started] <- 1L
  journal$TerminalCode[started] <- "optimizer_error"
  journal$SecondaryCode[started] <- "synthetic_registered_optimizer_error"
  journal$RegisteredFailureCount[started] <- 1L

  expect_error(
    ctx$env$mfrmr_cq_ach_finalize_outcomes(plan, journal, outcome),
    "registered global resource abort"
  )
  finalized <- ctx$env$mfrmr_cq_ach_finalize_outcomes(
    plan, journal, outcome,
    global_abort_triggered = TRUE,
    global_abort_reason = "cumulative_wall_time_cap_reached"
  )
  expect_identical(nrow(finalized$outcome), 230L)
  expect_identical(nrow(finalized$journal), 190L)
  expect_true(all(finalized$outcome$RowRetained))
  expect_true(all(finalized$journal$Completed))
  expect_identical(sum(finalized$journal$Started), 2L)
  expect_identical(
    sum(finalized$journal$TerminalCode == "global_resource_abort_unattempted"),
    188L
  )
  expect_identical(
    sum(finalized$outcome$TerminalCode == "expected_structural_rejection"),
    40L
  )
  expect_identical(finalized$journal$TerminalCode[started],
                   rep("optimizer_error", 2L))
  expect_identical(finalized$audit$TerminalCodesChangedByG4N, 0L)
  expect_identical(finalized$audit$RowsDropped, 0L)
  expect_true(finalized$audit$AccountingComplete)

  unknown <- journal
  unknown$TerminalCode[1L] <- "unregistered_terminal"
  expect_error(
    ctx$env$mfrmr_cq_ach_finalize_outcomes(
      plan, unknown, outcome,
      global_abort_triggered = TRUE,
      global_abort_reason = "cumulative_wall_time_cap_reached"
    ),
    "unregistered terminal code"
  )
})

test_that("P4 applies G4N without relabelling bounded mfrmr or ConQuest", {
  ctx <- load_conquest_adversarial_simulation_calibration_p4()
  plan <- ctx$env$mfrmr_cq_ach_adapter_plan()
  journal <- ctx$env$mfrmr_cq_ach_attempt_journal_template(plan)
  journal$Started <- TRUE
  journal$Completed <- TRUE
  journal$AttemptCount <- 1L
  journal$TerminalCode <- "optimizer_error"
  journal$SecondaryCode <- "synthetic_registered_engine_error"
  journal$RegisteredFailureCount <- 1L
  journal$ExitStatus[journal$Engine == "ConQuest"] <- 1L
  journal$TerminalMarkerObserved[journal$Engine == "ConQuest"] <- FALSE
  journal$InferenceReady[journal$Engine == "mfrmr"] <- FALSE
  inventory <- ctx$env$mfrmr_cq_ach_artifact_inventory(plan = plan)
  inventory$registry$Present[
    inventory$registry$ArtifactKind %in% c("failure_record", "console")
  ] <- TRUE
  inventory$registry$Nonempty <- inventory$registry$Present

  mfrmr_index <- which(journal$Engine == "mfrmr")[1L]
  mfrmr_order <- journal$AttemptOrder[mfrmr_index]
  journal$TerminalCode[mfrmr_index] <-
    "optimizer_nonconvergence_or_readiness_hold"
  journal$SecondaryCode[mfrmr_index] <-
    "mfrmr_optimizer_nonconvergence_or_readiness_hold"
  journal$ParseableResult[mfrmr_index] <- TRUE
  journal$ObservedFreeDimension[mfrmr_index] <-
    journal$ExpectedFreeDimension[mfrmr_index]
  journal$ModelIdentityMatch[mfrmr_index] <- TRUE
  inventory$registry$Present[
    inventory$registry$AttemptOrder == mfrmr_order &
      inventory$registry$ArtifactKind == "failure_record"
  ] <- FALSE
  inventory$registry$Nonempty[
    inventory$registry$AttemptOrder == mfrmr_order &
      inventory$registry$ArtifactKind == "failure_record"
  ] <- FALSE
  inventory$registry$Present[
    inventory$registry$AttemptOrder == mfrmr_order &
      inventory$registry$Requirement == "success"
  ] <- TRUE
  inventory$registry$Nonempty[
    inventory$registry$AttemptOrder == mfrmr_order &
      inventory$registry$Requirement == "success"
  ] <- TRUE

  conquest_index <- which(journal$Engine == "ConQuest")[1L]
  conquest_order <- journal$AttemptOrder[conquest_index]
  journal$TerminalCode[conquest_index] <- "complete_numeric_eligible"
  journal$SecondaryCode[conquest_index] <- NA_character_
  journal$ParseableResult[conquest_index] <- TRUE
  journal$ObservedFreeDimension[conquest_index] <-
    journal$ExpectedFreeDimension[conquest_index]
  journal$ModelIdentityMatch[conquest_index] <- TRUE
  journal$RegisteredFailureCount[conquest_index] <- 0L
  journal$ExitStatus[conquest_index] <- 0L
  journal$TerminalMarkerObserved[conquest_index] <- TRUE
  inventory$registry$Present[
    inventory$registry$AttemptOrder == conquest_order
  ] <- TRUE
  inventory$registry$Nonempty[
    inventory$registry$AttemptOrder == conquest_order
  ] <- TRUE

  readiness <- data.frame(
    AttemptOrder = mfrmr_order,
    Model = journal$Family[mfrmr_index],
    ICQuadraturePoints = journal$Nodes[mfrmr_index],
    MMLEngineRequested = "direct", MMLEngineUsed = "direct",
    Converged = TRUE, ConvergenceCode = 0L,
    ConvergenceStatus = "converged", ConvergenceSeverity = "pass",
    ReviewableWarning = FALSE, FitReadiness = "review",
    InferenceReady = FALSE, InputState = "pass",
    EstimabilityState = "not_evaluated", CategoryState = "adequate",
    BoundaryState = "finite", NumericalState = "ready",
    ReadinessReasonCodes = "design_rank_not_evaluated",
    stringsAsFactors = FALSE
  )
  terminal_before <- journal$TerminalCode
  expect_error(
    ctx$env$mfrmr_cq_ach_apply_diagnostic_eligibility(
      plan, journal, inventory, synthetic_p4_bridge(plan), NULL
    ),
    "requires one observed readiness row"
  )
  observed <- ctx$env$mfrmr_cq_ach_apply_diagnostic_eligibility(
    plan, journal, inventory, synthetic_p4_bridge(plan), readiness
  )

  expect_identical(observed$journal$TerminalCode, terminal_before)
  expect_identical(
    sum(observed$diagnostic_eligibility$DiagnosticNumericEligible), 2L
  )
  expect_identical(
    observed$diagnostic_eligibility$DiagnosticEligibilityMode[mfrmr_index],
    "diagnostic_rank_hold_only"
  )
  expect_identical(
    observed$diagnostic_eligibility$DiagnosticEligibilityMode[conquest_index],
    "complete_numeric"
  )
  expect_false(
    observed$diagnostic_eligibility$InferenceReadyAfterContract[mfrmr_index]
  )
  expect_true(all(observed$diagnostic_eligibility$TerminalCodePreserved))
  expect_false(any(observed$diagnostic_eligibility$NumericValueInspected))
})

test_that("P4 keeps conditional metrics beside frozen unconditional units", {
  ctx <- load_conquest_adversarial_simulation_calibration_p4()
  plan <- ctx$env$mfrmr_cq_ach_adapter_plan()
  outcome <- ctx$env$mfrmr_cq_ach_outcome_template(plan)
  eligibility <- data.frame(
    AttemptOrder = 1:190,
    DiagnosticNumericEligible = FALSE,
    stringsAsFactors = FALSE
  )
  empty <- ctx$env$mfrmr_cq_ach_metric_summary(
    plan, outcome, eligibility
  )
  expect_identical(
    empty$UnconditionalDenominator,
    c(90L, 90L, 90L, 90L, rep(180L, 4L), 90L, 40L,
      190L, 10L, 190L, 1511L)
  )
  conditional <- empty$UseClass ==
    "conditional_exploratory_diagnostic_numeric"
  expect_true(all(empty$ConditionalDiagnosticDenominator[conditional] == 0L))
  expect_false(any(empty$NumericSummaryComputed))
  expect_false(any(empty$PrimaryPooledSummaryPermitted))
  expect_true(all(empty$FailureRowsRetained))
  expect_false(any(empty$ThresholdApplied))
  expect_false(any(empty$PublicClaimPermitted))

  representation <- plan$AttemptOrder[!is.na(plan$RepresentationPairId)]
  eligibility$DiagnosticNumericEligible[
    eligibility$AttemptOrder %in% representation
  ] <- TRUE
  units <- ctx$env$mfrmr_cq_ach_metric_units(plan, outcome, eligibility)
  observation <- data.frame(
    SummaryId = "ASP-REPRESENTATION-INVARIANCE",
    UnitId = units[["ASP-REPRESENTATION-INVARIANCE"]]$UnitId,
    Stratum = "family",
    Value = seq_along(units[["ASP-REPRESENTATION-INVARIANCE"]]$UnitId) / 100,
    stringsAsFactors = FALSE
  )
  rmse_units <- units[["ASP-PARAMETER-RMSE"]]
  rmse_units <- rmse_units$UnitId[rmse_units$Eligible]
  observation <- rbind(
    observation,
    data.frame(
      SummaryId = "ASP-PARAMETER-RMSE",
      UnitId = rmse_units,
      Stratum = "registered_test_stratum",
      Value = rep(c(-1, 1), length.out = length(rmse_units)),
      stringsAsFactors = FALSE
    )
  )
  summarized <- ctx$env$mfrmr_cq_ach_metric_summary(
    plan, outcome, eligibility, observation
  )
  accounting <- summarized[
    summarized$SummaryId == "ASP-REPRESENTATION-INVARIANCE" &
      summarized$RecordType == "accounting", , drop = FALSE
  ]
  row <- summarized[
    summarized$SummaryId == "ASP-REPRESENTATION-INVARIANCE" &
      summarized$RecordType == "stratum", , drop = FALSE
  ]
  expect_identical(accounting$UnconditionalDenominator, 10L)
  expect_identical(accounting$ConditionalDiagnosticDenominator, 10L)
  expect_false(accounting$NumericSummaryComputed)
  expect_identical(row$NumericObservationCount, 10L)
  expect_true(row$NumericCoverageComplete)
  expect_true(row$NumericSummaryComputed)
  expect_false(row$PrimaryPooledSummaryPermitted)
  expect_false(row$ScientificEquivalenceInferred)
  rmse <- summarized[
    summarized$SummaryId == "ASP-PARAMETER-RMSE" &
      summarized$RecordType == "stratum", , drop = FALSE
  ]
  expect_identical(rmse$PrimaryEstimate, 1)
  expect_identical(rmse$Mean, 0)
  retained <- summarized[
    summarized$RecordType == "observation", , drop = FALSE
  ]
  expect_identical(nrow(retained), nrow(observation))
  reconstructed <- ctx$env$mfrmr_cq_ach_metric_summary(
    plan, outcome, eligibility,
    data.frame(
      SummaryId = retained$SummaryId,
      UnitId = retained$UnitId,
      Stratum = retained$Stratum,
      Value = retained$ObservationValue,
      stringsAsFactors = FALSE
    )
  )
  expect_true(ctx$env$mfrmr_cq_ach_p4_same_frame(
    summarized, reconstructed, names(reconstructed)
  ))
  tampered <- summarized
  tampered$PrimaryEstimate[
    tampered$SummaryId == "ASP-PARAMETER-RMSE" &
      tampered$RecordType == "stratum"
  ] <- 0
  expect_false(ctx$env$mfrmr_cq_ach_p4_same_frame(
    tampered, reconstructed, names(reconstructed)
  ))

  bad <- observation[1L, , drop = FALSE]
  bad$UnitId <- "unregistered_or_ineligible_unit"
  expect_error(
    ctx$env$mfrmr_cq_ach_metric_summary(plan, outcome, eligibility, bad),
    "ineligible unit"
  )
  duplicate <- rbind(observation, observation[1L, , drop = FALSE])
  expect_error(
    ctx$env$mfrmr_cq_ach_metric_summary(
      plan, outcome, eligibility, duplicate
    ),
    "duplicated"
  )
})

test_that("P4 consumes but never issues the separate live authorization", {
  ctx <- load_conquest_adversarial_simulation_calibration_p4()
  parent <- withr::local_tempdir()
  target <- file.path(parent, ctx$env$mfrmr_cq_ataa_output_basename)
  authorization <- synthetic_p4_authorization(ctx, target)

  expect_error(
    ctx$env$mfrmr_cq_ach_consume_authorization(authorization, target),
    "consumer is held"
  )
  expect_false(authorization$Consumed)

  mutated <- synthetic_p4_authorization(ctx, target)
  mutated$Q121AttemptCount <- 41L
  expect_error(
    ctx$env$mfrmr_cq_ach_consume_authorization(
      mutated, target, authorize = TRUE
    ),
    "stale, widened, consumed"
  )
  expect_false(mutated$Consumed)

  consumed <- ctx$env$mfrmr_cq_ach_consume_authorization(
    authorization, target, authorize = TRUE
  )
  expect_true(consumed$Consumed)
  expect_false(is.na(consumed$ConsumedAt))
  expect_false(consumed$AuthorizationIssuedByP4)
  expect_error(
    ctx$env$mfrmr_cq_ach_consume_authorization(
      authorization, target, authorize = TRUE
    ),
    "stale, widened, consumed"
  )

  reused <- synthetic_p4_authorization(ctx, target)
  expect_true(dir.create(target))
  expect_error(
    ctx$env$mfrmr_cq_ach_consume_authorization(
      reused, target, authorize = TRUE
    ),
    "stale, widened, consumed"
  )
  expect_false(reused$Consumed)
})

test_that("P4 closes 18 capabilities but does not open live execution", {
  ctx <- load_conquest_adversarial_simulation_calibration_p4()
  review <- ctx$env$mfrmr_cq_ach_dry_run_review(
    ctx$g4x_output, ctx$calibration_output, ctx$smoke_output
  )
  capability <- ctx$env$mfrmr_cq_ataa_harness_capability_registry()

  expect_identical(
    review$status,
    paste0(
      "ASP_G4C_P4_integrated_dry_run_harness_frozen_",
      "separate_live_authorization_required"
    )
  )
  expect_true(all(capability$ProviderAvailable))
  expect_identical(review$upstream_and_harness_capabilities_available, 18L)
  expect_identical(review$harness_capabilities_still_missing, 0L)
  expect_true(review$complete_outcome_finalizer_implemented)
  expect_true(review$terminal_nonmutating_G4N_application_implemented)
  expect_true(review$conditional_and_unconditional_metric_summarizer_implemented)
  expect_true(review$run_once_authorization_consumer_implemented)
  expect_true(review$retained_execution_reviewer_implemented)
  expect_false(review$retained_execution_review_performed)
  expect_false(review$tranche_A_responses_generated)
  expect_identical(review$fit_attempts, 0L)
  expect_false(review$ConQuest_execution_attempted)
  expect_false(review$positive_live_authorization_issued_by_P4)
  expect_false(review$response_generation_authorized)
  expect_false(review$execution_authorized)
  expect_false(review$fresh_tranche_A_sentinel_observed)
  expect_false(review$numeric_agreement_inspected)
  expect_false(review$threshold_selected)
  expect_false(review$public_claim_authorized)
  expect_false(review$scientific_equivalence_inferred)
  expect_identical(
    review$next_action,
    "ASP-G4L-TRANCHE-A-LIVE-AUTHORIZATION-FREEZE"
  )
})

test_that("P4 source and records stay execution-free and internal", {
  ctx <- load_conquest_adversarial_simulation_calibration_p4()
  source <- paste(readLines(ctx$paths[17L], warn = FALSE), collapse = "\n")
  expect_false(grepl("unlink\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
  expect_false(grepl(
    "mfrmr_cq_ach_(execute|fresh_sentinel|generate_dataset)\\s*\\(",
    source, perl = TRUE
  ))
  record <- paste(readLines(file.path(
    ctx$validation,
    paste0(
      "conquest-adversarial-simulation-calibration-harness-",
      "finalization-record-0.2.3.md"
    )
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  expect_match(record, ctx$env$mfrmr_cq_ach_p4_specification, fixed = TRUE)
  expect_match(record, "`HarnessCapabilitiesStillMissing=0`", fixed = TRUE)
  expect_match(record, "`TrancheAResponsesGenerated=FALSE`", fixed = TRUE)
  expect_match(record, "file-byte or hash equality", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] G4C-P4: implement G4N application",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Freeze the G4C tranche-A calibration harness",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[ ] Run the frozen disjoint calibration band",
    fixed = TRUE
  )
})
