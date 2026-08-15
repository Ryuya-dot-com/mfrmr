load_conquest_adversarial_simulation_calibration_freeze <- function() {
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
    "conquest-adversarial-simulation-calibration-freeze-0.2.3.R"
  ))
  skip_if_not(all(file.exists(paths)), "ConQuest ASP G4 files are excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("G4 freezes 450 disjoint calibration identities without opening data", {
  env <- load_conquest_adversarial_simulation_calibration_freeze()$env
  seed <- env$mfrmr_cq_acf_seed_registry()
  phase <- env$mfrmr_cq_acf_phase_separation()
  smoke_seed <- env$mfrmr_cq_asg_seed_registry()$Seed

  expect_identical(nrow(seed), 450L)
  expect_identical(length(unique(seed$ArmId)), 18L)
  expect_identical(anyDuplicated(seed$DatasetId), 0L)
  expect_identical(anyDuplicated(seed$Seed), 0L)
  expect_identical(range(seed$Seed), c(988101L, 989825L))
  expect_false(any(seed$Seed %in% smoke_seed))
  expect_identical(
    as.integer(table(factor(seed$Tranche, levels = c("A", "B")))),
    c(90L, 360L)
  )
  expect_true(all(table(seed$ArmId) == 25L))
  expect_identical(sum(seed$PrimaryQ61FitRequired), 350L)
  expect_identical(sum(seed$Q61FitAttemptCount), 750L)
  expect_identical(sum(seed$Q61OutcomeRowCount), 950L)
  expect_identical(
    sum(seed$PairedRepresentationComparisonRequired), 50L
  )
  expect_identical(sum(seed$SelectiveQ121FitRequired), 100L)
  expect_identical(sum(seed$SelectiveQ121FitAttemptCount), 200L)
  expect_identical(sum(seed$PlannedOutcomeRowCount), 1150L)
  expect_false(any(seed$Generated))
  expect_false(any(seed$ResultOpened))
  expect_true(all(seed$RetainIfGenerated))
  expect_false(any(seed$MayTuneDGP))
  expect_false(any(seed$MayTuneMetricThreshold))
  expect_false(any(seed$MayEnterConfirmation))
  expect_identical(phase$ExactSeedsAssigned, c(18L, 450L, 0L))
  expect_true(phase$AssignedSeedDisjoint[phase$Phase == "calibration"])
  expect_true(is.na(
    phase$AssignedSeedDisjoint[phase$Phase == "confirmation"]
  ))
})

test_that("retained G3 data first face a bounded mechanics-only engine gate", {
  env <- load_conquest_adversarial_simulation_calibration_freeze()$env
  mechanics <- env$mfrmr_cq_acf_engine_mechanics_registry()
  bridge <- env$mfrmr_cq_acf_representation_bridge_registry()
  profile <- env$mfrmr_cq_acf_engine_profile_registry()

  expect_identical(nrow(mechanics), 38L)
  expect_identical(sum(mechanics$AttemptRequiredAtFutureMechanicsGate), 30L)
  expect_identical(sum(mechanics$AttemptCap), 30L)
  expect_identical(
    sum(mechanics$QuadratureId == "prefit_stop"), 8L
  )
  expect_identical(
    sum(mechanics$RepresentationId == "explicit_missing"), 2L
  )
  expect_identical(
    sum(mechanics$ConQuestCanonicalBridgeForBothPairedRepresentations), 2L
  )
  paired <- mechanics[
    mechanics$ScenarioClassId == "ASP-INV-PAIRED-MISSINGNESS", ,
    drop = FALSE
  ]
  expect_identical(nrow(paired), 6L)
  expect_setequal(
    paired$RepresentationId[paired$Engine == "mfrmr"],
    c("planned_absence", "explicit_missing")
  )
  expect_true(all(
    paired$RepresentationId[paired$Engine == "ConQuest"] ==
      "canonical_wide_missing"
  ))
  expect_identical(nrow(bridge), 4L)
  expect_identical(bridge$CheckOrder, 1:4)
  expect_true(all(bridge$RequiredForEachPairedDatasetBridgeCheck))
  expect_false(any(bridge$ByteEqualityRequired))
  expect_false(any(bridge$NumericAgreementInspected))
  expect_false(any(bridge$ExecutionAuthorizedByThisContract))
  expect_true(all(
    mechanics$AttemptCap[
      mechanics$StructuralDispositionFromRetainedG3 ==
        "reject_before_numeric_comparison"
    ] == 0L
  ))
  expect_true(all(mechanics$RetainedG3DataUsed))
  expect_true(all(mechanics$MechanicsOnly))
  expect_false(any(mechanics$MayEstimateOperatingCharacteristics))
  expect_false(any(mechanics$MayEnterCalibrationOrConfirmation))
  expect_false(any(mechanics$AttemptAuthorizedByThisContract))
  expect_identical(nrow(profile), 8L)
  expect_setequal(profile$Nodes, c(61L, 121L))
  expect_false(any(profile$AutomaticRetryPermitted))
  expect_false(any(profile$ExecutionAuthorizedByThisContract))
})

test_that("terminal failure taxonomy is ordered, lossless, and engine-independent", {
  env <- load_conquest_adversarial_simulation_calibration_freeze()$env
  taxonomy <- env$mfrmr_cq_acf_failure_taxonomy()
  semantic <- env$mfrmr_cq_acf_semantic_code_map()

  expect_identical(nrow(taxonomy), 18L)
  expect_identical(taxonomy$Precedence, seq_len(nrow(taxonomy)))
  expect_identical(anyDuplicated(taxonomy$TerminalCode), 0L)
  expect_true(all(taxonomy$RowMustBeRetained))
  expect_false(any(taxonomy$FailureRowDroppable))
  expect_identical(
    taxonomy$TerminalCode[taxonomy$MaySuppressOtherEligibleEngineAttempt],
    "global_resource_abort_unattempted"
  )
  expect_identical(
    env$mfrmr_cq_acf_terminal_class(c(
      "registered_semantic_execution_failure", "terminal_marker_missing"
    )),
    "terminal_marker_missing"
  )
  expect_setequal(
    semantic$SecondaryCode[semantic$SourceRegistry == "semantic_regex_registry"],
    env$mfrmr_cq_srp_failure_registry()$FailureCode
  )
  expect_identical(
    semantic$PrimaryTerminalCode[
      semantic$SecondaryCode == "process_exit_nonzero"
    ],
    "host_or_process_failure"
  )
  expect_identical(
    semantic$PrimaryTerminalCode[
      semantic$SecondaryCode == "incomplete_output_set"
    ],
    "required_native_output_incomplete"
  )
  expect_identical(
    semantic$PrimaryTerminalCode[
      semantic$SecondaryCode == "representation_bridge_mismatch"
    ],
    "generation_or_schema_failure"
  )
  expect_true(all(semantic$PreserveMatchedTextAndLineNumbers))
})

test_that("calibration summaries are exploratory, stratified, and nonconfirmatory", {
  env <- load_conquest_adversarial_simulation_calibration_freeze()$env
  summary <- env$mfrmr_cq_acf_summary_registry()

  expect_identical(nrow(summary), 14L)
  expect_true(all(summary$CalibrationExploratorySummaryPermitted))
  expect_true(all(nzchar(summary$PrimaryStrata)))
  expect_false(any(summary$PrimaryPooledSummaryPermitted))
  expect_false(any(summary$FailureRowsDroppable))
  expect_false(any(summary$MayTuneDGP))
  expect_false(any(summary$MaySelectMetricThreshold))
  expect_false(any(summary$MaySetConfirmationDecisionRule))
  expect_false(any(summary$MayEnterConfirmationDataset))
  expect_false(any(summary$MaySupportPublicClaim))
  expect_false("ASP-UNCERTAINTY-COVERAGE" %in% summary$SummaryId)
  expect_true(all(c(
    "ASP-ELAPSED-RUNTIME", "ASP-RETAINED-STORAGE",
    "ASP-REPRESENTATION-INVARIANCE"
  ) %in% summary$SummaryId))
})

test_that("resource caps distinguish outcome rows from actual fit attempts", {
  env <- load_conquest_adversarial_simulation_calibration_freeze()$env
  tranche_a <- env$mfrmr_cq_acf_workload_registry(5L)
  full <- env$mfrmr_cq_acf_workload_registry(25L)
  budget <- env$mfrmr_cq_acf_resource_budget_registry()
  runtime <- env$mfrmr_cq_acf_runtime_contract()

  expect_identical(nrow(tranche_a), 8L)
  expect_identical(sum(tranche_a$PlannedAttemptCount), 190L)
  expect_identical(nrow(full), 8L)
  expect_identical(sum(full$PlannedAttemptCount), 950L)
  expect_identical(budget$Q61FitAttemptCap, c(30L, 150L, 750L))
  expect_identical(budget$TotalFitAttemptCap, c(30L, 190L, 950L))
  expect_identical(budget$ScheduledOutcomeRowCap, c(38L, 230L, 1150L))
  expect_true(all(budget$PerFitTimeoutSeconds == 600L))
  expect_true(all(budget$CumulativeWallTimeCapSeconds > 0L))
  expect_true(all(budget$RetainedStorageCapBytes > 0))
  expect_false(any(budget$AutomaticRetryPermitted))
  expect_false(any(budget$ExecutionAuthorizedByThisContract))
  expect_identical(runtime$ExecutablePath, "/Applications/ConQuest/ConQuest")
  expect_identical(runtime$RequiredVersion, "5.47.5")
  expect_lt(runtime$RunNotAfter, runtime$ExpiryDate)
  expect_true(runtime$FreshDataFreeSentinelRequiredEachSession)
  expect_true(runtime$SentinelMustPrecedeEngineMechanics)
  expect_true(runtime$SentinelMustPrecedeCalibrationGeneration)
})

test_that("resource projection uses cellwise maxima and shared dataset cost", {
  env <- load_conquest_adversarial_simulation_calibration_freeze()$env
  full <- env$mfrmr_cq_acf_workload_registry(25L)
  observation <- full[, c("Engine", "Family", "Nodes"), drop = FALSE]
  observation$MaximumElapsedSeconds <- 1
  observation$MaximumRetainedBytes <- 1024
  projection <- env$mfrmr_cq_acf_resource_projection(
    observation,
    maximum_dataset_generation_seconds = 1,
    maximum_dataset_retained_bytes = 2048
  )

  expect_identical(
    projection$ProjectionMethod, env$mfrmr_cq_acf_projection_method
  )
  expect_identical(projection$ObservedWorkloadCells, 8L)
  expect_identical(projection$FullPlannedFitAttempts, 950L)
  expect_identical(projection$FullPlannedDatasets, 450L)
  expect_equal(projection$ProjectedFullElapsedSeconds, 1400)
  expect_equal(
    projection$ProjectedFullStorageBytes, 950 * 1024 + 450 * 2048
  )
  expect_false(projection$NumericAgreementInspected)

  expect_error(
    env$mfrmr_cq_acf_resource_projection(
      observation[-1L, ], 1, 2048
    ),
    "all eight frozen workload cells", fixed = TRUE
  )
  bad <- observation
  bad$MaximumRetainedBytes <- as.character(bad$MaximumRetainedBytes)
  expect_error(
    env$mfrmr_cq_acf_resource_projection(bad, 1, 2048),
    "finite, and nonnegative", fixed = TRUE
  )
})

test_that("engine mechanics requires accounting and parser coverage, not agreement", {
  env <- load_conquest_adversarial_simulation_calibration_freeze()$env
  audit <- list(
    RetainedDatasets = 18L,
    RetainedOutcomeRows = 38L,
    ExpectedNegativeRejections = 4L,
    NegativeControlFitAttempts = 0L,
    EligiblePlannedAttempts = 30L,
    RetainedAttemptOutcomeRows = 30L,
    PeerEligibleAttemptsSuppressed = 0L,
    EngineFamilyCellsWithParseableQ61 = 4L,
    PairedRepresentationOutcomeRows = 6L,
    ExplicitMissingMfrmrAttemptOutcomes = 2L,
    ExplicitMissingMfrmrParseableCells = 2L,
    ConQuestRepresentationBridgeChecks = 2L,
    FreshRuntimeSentinelPassed = TRUE,
    ModelIdentityMismatches = 0L,
    GlobalAbortTriggered = FALSE,
    RowsDropped = 0L,
    MaximumCrossEngineDifference = Inf
  )
  decision <- env$mfrmr_cq_acf_engine_mechanics_decision(audit)

  expect_true(decision$mechanics_gate_met)
  expect_false(decision$all_fit_attempts_required_to_succeed)
  expect_false(decision$numeric_agreement_inspected)
  expect_false(decision$calibration_generation_authorized)
  expect_true(decision$separate_authorization_required)
  audit$MaximumCrossEngineDifference <- 0
  expect_identical(
    env$mfrmr_cq_acf_engine_mechanics_decision(audit)$criterion,
    decision$criterion
  )
  audit$PeerEligibleAttemptsSuppressed <- 1L
  expect_false(
    env$mfrmr_cq_acf_engine_mechanics_decision(audit)$mechanics_gate_met
  )
})

test_that("tranche expansion can inspect operations but not agreement", {
  env <- load_conquest_adversarial_simulation_calibration_freeze()$env
  budget <- env$mfrmr_cq_acf_resource_budget_registry()
  full <- budget[budget$Stage == "calibration_full", , drop = FALSE]
  audit <- list(
    GeneratedDatasetsRetained = 90L,
    RetainedScheduledOutcomeRows = 230L,
    NegativeControlDatasets = 20L,
    ExpectedNegativeRejections = 20L,
    NegativeControlFitAttempts = 0L,
    FreshRuntimeSentinelPassed = TRUE,
    GeneratorOrSchemaFailures = 0L,
    SeedOrDGPDrift = 0L,
    SystemicAdapterFailures = 0L,
    PairedRepresentationDatasets = 10L,
    PairedRepresentationOutcomeRowsRetained = 30L,
    ExplicitMissingMfrmrFitAttempts = 10L,
    ConQuestRepresentationBridgeChecks = 10L,
    RepresentationAdapterFailures = 0L,
    WorkloadCellsObserved = 8L,
    ProjectionMethod = env$mfrmr_cq_acf_projection_method,
    ProjectedFullElapsedSeconds =
      full$CumulativeWallTimeCapSeconds * 0.79,
    ProjectedFullStorageBytes = full$RetainedStorageCapBytes * 0.79,
    GlobalAbortTriggered = FALSE,
    RowsDropped = 0L,
    MaximumCrossEngineDifference = Inf
  )
  decision <- env$mfrmr_cq_acf_expansion_decision(audit)

  expect_true(decision$operational_gate_met)
  expect_false(decision$numeric_agreement_inspected)
  expect_false(decision$tranche_B_execution_authorized)
  expect_true(decision$separate_authorization_required)
  audit$MaximumCrossEngineDifference <- 0
  expect_identical(
    env$mfrmr_cq_acf_expansion_decision(audit)$criterion,
    decision$criterion
  )
  audit$RowsDropped <- 1L
  expect_false(
    env$mfrmr_cq_acf_expansion_decision(audit)$operational_gate_met
  )
  audit$ProjectedFullElapsedSeconds <- c(1, 2)
  expect_error(
    env$mfrmr_cq_acf_expansion_decision(audit),
    "finite numeric scalars", fixed = TRUE
  )
})

test_that("G4 completes only the freeze and advances to engine authorization", {
  env <- load_conquest_adversarial_simulation_calibration_freeze()$env
  review <- env$mfrmr_cq_acf_review()

  expect_identical(
    review$status, "ASP_G4_calibration_contract_frozen_execution_closed"
  )
  expect_true(review$G3_prerequisite_complete)
  expect_true(review$G4_calibration_freeze_complete)
  expect_true(review$calibration_seed_band_frozen)
  expect_true(review$failure_taxonomy_frozen)
  expect_true(review$permitted_exploratory_summaries_frozen)
  expect_true(review$sequential_and_resource_rules_frozen)
  expect_true(review$engine_mechanics_prerequisite_frozen)
  expect_true(
    review$paired_missingness_workload_corrected_before_engine_execution
  )
  expect_true(review$no_engine_or_calibration_results_opened_before_correction)
  expect_false(review$engine_mechanics_execution_authorized)
  expect_false(review$calibration_response_generation_authorized)
  expect_false(review$calibration_execution_authorized)
  expect_false(review$calibration_results_opened)
  expect_false(review$confirmation_seed_band_frozen)
  expect_false(review$any_sampled_response_generated)
  expect_false(review$any_fit_attempted)
  expect_false(review$ConQuest_execution_attempted)
  expect_identical(
    review$next_action, "ASP-G4E-ENGINE-MECHANICS-SMOKE-AUTHORIZATION"
  )
  expect_false(review$public_text_change_authorized)
  expect_false(review$scientific_equivalence_inferred)

  bad <- env$mfrmr_cq_acf_g3_evidence_registry()
  bad$FitAttempts <- 1L
  expect_false(env$mfrmr_cq_acf_review(bad)$G4_calibration_freeze_complete)
})

test_that("G4 source itself cannot generate, fit, launch, or hash", {
  ctx <- load_conquest_adversarial_simulation_calibration_freeze()
  parsed <- getParseData(parse(ctx$paths[9L], keep.source = TRUE))
  calls <- parsed$text[parsed$token == "SYMBOL_FUNCTION_CALL"]

  expect_false(any(c(
    "set.seed", "runif", "rnorm", "sample", "fit_mfrm", "system", "system2"
  ) %in% calls))
  source <- paste(readLines(ctx$paths[9L], warn = FALSE), collapse = "\n")
  expect_false(grepl(
    "SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE
  ))
})

test_that("G4 record and roadmap preserve the closed execution boundary", {
  ctx <- load_conquest_adversarial_simulation_calibration_freeze()
  record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-adversarial-simulation-calibration-freeze-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_acf_specification, fixed = TRUE)
  expect_match(record, "`G4CalibrationFreezeComplete=TRUE`", fixed = TRUE)
  expect_match(record, "`CalibrationExecutionAuthorized=FALSE`", fixed = TRUE)
  expect_match(record, "favorable or unfavorable numerical", fixed = TRUE)
  expect_match(
    roadmap, "[x] Freeze the calibration seed band, failure taxonomy",
    fixed = TRUE
  )
  expect_match(
    roadmap, "[x] Freeze a separate run-once engine-mechanics authorization",
    fixed = TRUE
  )
})
