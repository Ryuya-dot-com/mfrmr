# Prospective ASP-G4 calibration freeze for the ConQuest comparison.
#
# This contract fixes the disjoint calibration seeds, an engine-mechanics
# prerequisite, terminal failure semantics, allowed exploratory summaries,
# and finite resource limits. It creates no randomness, generates no response,
# fits no model, and launches no external process.

mfrmr_cq_acf_specification <-
  "0.2.3-conquest-adversarial-simulation-calibration-freeze-v2"
mfrmr_cq_acf_contract <-
  "mfrmr_conquest_adversarial_simulation_calibration_freeze_v2"
mfrmr_cq_acf_calibration_namespace_start <- 988000L
mfrmr_cq_acf_calibration_namespace_end <- 989999L
mfrmr_cq_acf_replicates_per_arm <- 25L
mfrmr_cq_acf_tranche_a_replicates_per_arm <- 5L
mfrmr_cq_acf_conquest_path <- "/Applications/ConQuest/ConQuest"
mfrmr_cq_acf_conquest_version <- "5.47.5"
mfrmr_cq_acf_conquest_expiry <- as.Date("2026-09-01")
mfrmr_cq_acf_run_not_after <- as.Date("2026-08-31")
mfrmr_cq_acf_expansion_review_fraction <- 0.8
mfrmr_cq_acf_projection_method <-
  "cellwise_max_plus_dataset_max_linear_projection_v1"

mfrmr_cq_acf_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_acf_require_contracts <- function() {
  target <- environment(mfrmr_cq_acf_require_contracts)
  ready <- exists(
    "mfrmr_cq_ase_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_ase_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_adversarial_simulation_smoke_execution_v1"
  ) && exists(
    "mfrmr_cq_asg_seed_registry", envir = target,
    mode = "function", inherits = TRUE
  ) && exists(
    "mfrmr_cq_ast_template_registry", envir = target,
    mode = "function", inherits = TRUE
  ) && exists(
    "mfrmr_cq_asp_metric_registry", envir = target,
    mode = "function", inherits = TRUE
  ) && exists(
    "mfrmr_cq_srp_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_srp_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_semantic_runtime_preflight_v1"
  ) && exists(
    "mfrmr_cq_srp_failure_registry", envir = target,
    mode = "function", inherits = TRUE
  )
  mfrmr_cq_acf_assert(
    ready,
    paste(
      "Source the semantic runtime and complete ASP-G3 dependency chain",
      "before the ASP-G4 calibration freeze."
    )
  )
  invisible(TRUE)
}

mfrmr_cq_acf_g3_evidence_registry <- function() {
  data.frame(
    EvidenceSource =
      "conquest-adversarial-simulation-smoke-execution-record-0.2.3.md",
    Status = "ASP_G3_eighteen_smoke_datasets_generated_and_retained",
    GeneratedDatasets = 18L,
    UniqueArms = 18L,
    SeedMinimum = 987001L,
    SeedMaximum = 987018L,
    StructurallyEligibleDatasets = 14L,
    ExpectedStructuralRejections = 4L,
    PrototypeResponseVectorsReused = 0L,
    RetainedUnconditionalDatasets = 18L,
    FitAttempts = 0L,
    ConQuestAttempts = 0L,
    OperatingCharacteristicsEstimated = FALSE,
    MayInformMechanicsAttemptCounts = TRUE,
    MayTuneDGPOrThreshold = FALSE,
    MayEnterCalibrationOrConfirmation = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_acf_seed_registry <- function() {
  mfrmr_cq_acf_require_contracts()
  template <- mfrmr_cq_ast_template_registry()
  allocation <- expand.grid(
    ArmIndex = seq_len(nrow(template)),
    Replicate = seq_len(mfrmr_cq_acf_replicates_per_arm),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  allocation <- allocation[order(
    allocation$ArmIndex, allocation$Replicate
  ), , drop = FALSE]
  rownames(allocation) <- NULL
  arm <- template[allocation$ArmIndex, , drop = FALSE]
  expected <- ifelse(
    arm$ExpectedDisposition == "reject_before_numeric_comparison",
    "reject_before_numeric_comparison", "eligible_numeric_comparison"
  )
  paired <- arm$ScenarioClassId == "ASP-INV-PAIRED-MISSINGNESS"
  selective <- expected == "eligible_numeric_comparison" &
    arm$ScenarioClassId %in% c(
      "ASP-POS-COMPLETE", "ASP-SENS-RARE-BOUNDARY-CATEGORY"
    )
  out <- data.frame(
    Phase = "exploratory_calibration_only",
    Tranche = ifelse(
      allocation$Replicate <= mfrmr_cq_acf_tranche_a_replicates_per_arm,
      "A", "B"
    ),
    DatasetId = sprintf(
      "CQASP-CAL-A%02d-R%02d",
      allocation$ArmIndex, allocation$Replicate
    ),
    ArmIndex = allocation$ArmIndex,
    ArmId = arm$ArmId,
    ScenarioClassId = arm$ScenarioClassId,
    Family = arm$Family,
    Replicate = allocation$Replicate,
    Seed = as.integer(
      mfrmr_cq_acf_calibration_namespace_start +
        allocation$ArmIndex * 100L + allocation$Replicate
    ),
    ExpectedStructuralDisposition = expected,
    PrimaryQ61FitRequired =
      expected == "eligible_numeric_comparison",
    PairedRepresentationComparisonRequired =
      expected == "eligible_numeric_comparison" & paired,
    Q61FitAttemptCount = ifelse(
      expected == "eligible_numeric_comparison", 2L + as.integer(paired), 0L
    ),
    Q61OutcomeRowCount = 2L + as.integer(paired),
    SelectiveQ121FitRequired = selective,
    SelectiveQ121FitAttemptCount = 2L * as.integer(selective),
    PlannedOutcomeRowCount =
      2L + as.integer(paired) + 2L * as.integer(selective),
    EvidenceUse = "exploratory_calibration_only_not_confirmation",
    Generated = FALSE,
    ResultOpened = FALSE,
    RetainIfGenerated = TRUE,
    MayTuneDGP = FALSE,
    MayTuneMetricThreshold = FALSE,
    MayEnterConfirmation = FALSE,
    MaySupportPublicClaim = FALSE,
    stringsAsFactors = FALSE
  )
  mfrmr_cq_acf_assert(
    nrow(out) == 450L && !anyDuplicated(out$DatasetId) &&
      !anyDuplicated(out$Seed) && min(out$Seed) >=
        mfrmr_cq_acf_calibration_namespace_start &&
      max(out$Seed) <= mfrmr_cq_acf_calibration_namespace_end,
    "The frozen calibration allocation drifted."
  )
  out
}

mfrmr_cq_acf_phase_separation <- function() {
  smoke <- mfrmr_cq_asg_seed_registry()
  calibration <- mfrmr_cq_acf_seed_registry()
  data.frame(
    Phase = c("smoke", "calibration", "confirmation"),
    NamespaceStart = c(987000L, 988000L, NA_integer_),
    NamespaceEnd = c(987099L, 989999L, NA_integer_),
    ExactSeedsAssigned = c(nrow(smoke), nrow(calibration), 0L),
    ResultsOpened = c(TRUE, FALSE, FALSE),
    DisjointFromAllEarlierPhasesRequired = c(FALSE, TRUE, TRUE),
    AssignedSeedDisjoint = c(TRUE, TRUE, NA),
    ReuseInCalibrationPermitted = c(FALSE, FALSE, FALSE),
    ReuseInConfirmationPermitted = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_acf_engine_mechanics_registry <- function() {
  smoke <- mfrmr_cq_asg_seed_registry()
  index <- rep(seq_len(nrow(smoke)), each = 2L)
  engine <- rep(c("mfrmr", "ConQuest"), times = nrow(smoke))
  eligible <- smoke$ExpectedDisposition[index] !=
    "reject_before_numeric_comparison"
  paired <- smoke$ScenarioClassId[index] == "ASP-INV-PAIRED-MISSINGNESS"
  out <- data.frame(
    DatasetOrder = index,
    DatasetId = smoke$DatasetId[index],
    ArmId = smoke$ArmId[index],
    ScenarioClassId = smoke$ScenarioClassId[index],
    Family = smoke$Family[index],
    Engine = engine,
    RepresentationId = ifelse(
      !eligible, "not_applicable_structural_rejection",
      ifelse(
        paired & engine == "mfrmr", "planned_absence",
        ifelse(paired, "canonical_wide_missing", "observed_rows_only")
      )
    ),
    RepresentationFitRole = ifelse(
      !eligible, "prefit_stop",
      ifelse(
        paired & engine == "mfrmr", "invariance_primary",
        ifelse(paired, "external_canonical_bridge", "single_representation")
      )
    ),
    QuadratureId = ifelse(eligible, "q61", "prefit_stop"),
    StructuralDispositionFromRetainedG3 = ifelse(
      eligible, "eligible_numeric_comparison",
      "reject_before_numeric_comparison"
    ),
    AttemptRequiredAtFutureMechanicsGate = eligible,
    AttemptCap = as.integer(eligible),
    RetainedG3DataUsed = TRUE,
    MechanicsOnly = TRUE,
    MayEstimateOperatingCharacteristics = FALSE,
    MayTuneDGPOrThreshold = FALSE,
    MayEnterCalibrationOrConfirmation = FALSE,
    AttemptAuthorizedByThisContract = FALSE,
    stringsAsFactors = FALSE
  )
  companion <- out[
    paired & engine == "mfrmr" & eligible, , drop = FALSE
  ]
  companion$RepresentationId <- "explicit_missing"
  companion$RepresentationFitRole <- "invariance_companion"
  out <- rbind(out, companion)
  out$RepresentationOrder <- match(
    out$RepresentationId,
    c(
      "observed_rows_only", "planned_absence", "explicit_missing",
      "canonical_wide_missing", "not_applicable_structural_rejection"
    )
  )
  out$EngineOrder <- match(out$Engine, c("mfrmr", "ConQuest"))
  out <- out[order(
    out$DatasetOrder, out$EngineOrder, out$RepresentationOrder
  ), , drop = FALSE]
  out$ConQuestCanonicalBridgeForBothPairedRepresentations <-
    out$ScenarioClassId == "ASP-INV-PAIRED-MISSINGNESS" &
    out$Engine == "ConQuest"
  out$RepresentationBridgeContractId <- ifelse(
    out$ScenarioClassId == "ASP-INV-PAIRED-MISSINGNESS",
    "paired_missingness_semantic_bridge_v1", NA_character_
  )
  out$DatasetOrder <- NULL
  out$RepresentationOrder <- NULL
  out$EngineOrder <- NULL
  rownames(out) <- NULL
  out
}

mfrmr_cq_acf_representation_bridge_registry <- function() {
  data.frame(
    BridgeContractId = "paired_missingness_semantic_bridge_v1",
    CheckOrder = 1:4,
    CheckId = c(
      "observed_response_relation_equivalent",
      "explicit_missing_is_exact_design_complement",
      "canonical_cell_map_equivalent",
      "ConQuest_input_semantic_roundtrip_equivalent"
    ),
    RequiredEvidence = c(
      paste(
        "after filtering ResponseObserved and sorting the typed key",
        "Person/Rater/Criterion, both representations have equal Response"
      ),
      paste(
        "explicit-missing keys with ResponseObserved=FALSE equal the frozen",
        "design keys absent from planned-absence"
      ),
      paste(
        "expanding either representation against the frozen design yields",
        "the same typed key/observed-mask/response relation"
      ),
      paste(
        "parsing the rendered ConQuest input yields the same canonical",
        "typed key/observed-mask/response relation"
      )
    ),
    ComparisonLevel = "typed_semantic_relation_after_key_sort",
    ByteEqualityRequired = FALSE,
    RequiredForEachPairedDatasetBridgeCheck = TRUE,
    TerminalCodeOnFailure = "generation_or_schema_failure",
    SecondaryCodeOnFailure = "representation_bridge_mismatch",
    NumericAgreementInspected = FALSE,
    ExecutionAuthorizedByThisContract = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_acf_engine_profile_registry <- function() {
  grid <- expand.grid(
    Engine = c("mfrmr", "ConQuest"),
    Family = c("RSM", "PCM"),
    Nodes = c(61L, 121L),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  grid <- grid[order(
    match(grid$Nodes, c(61L, 121L)),
    match(grid$Engine, c("mfrmr", "ConQuest")),
    match(grid$Family, c("RSM", "PCM"))
  ), , drop = FALSE]
  rownames(grid) <- NULL
  grid$QuadratureId <- paste0("q", grid$Nodes)
  grid$ScenarioScope <- ifelse(
    grid$Nodes == 61L,
    "all_structurally_eligible_scenario_family_datasets",
    "complete_and_rare_boundary_scenario_family_datasets_only"
  )
  grid$ModelIdentity <- ifelse(
    grid$Family == "RSM",
    "rater_plus_criterion_plus_shared_step_with_regression_X",
    "rater_plus_criterion_plus_criterion_by_step_with_regression_X"
  )
  grid$ExpectedFreeDimension <- ifelse(grid$Family == "RSM", 10L, 14L)
  grid$OptimizerControl <- ifelse(
    grid$Engine == "mfrmr",
    "MML_direct_maxit_2000_reltol_1e-12",
    paste0(
      "MML_quadrature_iterations_2000_convergence_1e-8_",
      "deviancechange_1e-10"
    )
  )
  grid$RuntimeBinding <- ifelse(
    grid$Engine == "mfrmr",
    "checked_source_tree_mfrmr_0.2.3",
    "ConQuest_5.47.5_Demonstration_x86_64_Rosetta"
  )
  grid$ExecutablePath <- ifelse(
    grid$Engine == "ConQuest", mfrmr_cq_acf_conquest_path, NA_character_
  )
  grid$InvocationRoute <- ifelse(
    grid$Engine == "ConQuest", "/usr/bin/arch -x86_64", NA_character_
  )
  grid$AttemptCapPerScheduledFitCell <- 1L
  grid$AutomaticRetryPermitted <- FALSE
  grid$ExecutionAuthorizedByThisContract <- FALSE
  grid
}

mfrmr_cq_acf_runtime_contract <- function() {
  data.frame(
    Engine = "ConQuest",
    ExecutablePath = mfrmr_cq_acf_conquest_path,
    RequiredVersion = mfrmr_cq_acf_conquest_version,
    RequiredEdition = "Demonstration Version",
    RequiredArchitecture = "Mach-O 64-bit executable x86_64",
    InvocationRoute = "/usr/bin/arch -x86_64",
    ExpiryDate = mfrmr_cq_acf_conquest_expiry,
    RunNotAfter = mfrmr_cq_acf_run_not_after,
    FreshDataFreeSentinelRequiredEachSession = TRUE,
    SentinelTimeoutSeconds = 30L,
    SentinelMustPrecedeEngineMechanics = TRUE,
    SentinelMustPrecedeCalibrationGeneration = TRUE,
    RuntimeDriftRequiresNewAuthorizationAddendum = TRUE,
    RuntimeDriftMayChangeSeedsDGPOrMetrics = FALSE,
    ExecutionAuthorizedByThisContract = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_acf_failure_taxonomy <- function() {
  code <- c(
    "generation_or_schema_failure",
    "expected_structural_rejection",
    "unexpected_structural_rejection",
    "global_resource_abort_unattempted",
    "runtime_unavailable_or_expired",
    "fit_timeout",
    "host_or_process_failure",
    "terminal_marker_missing",
    "registered_semantic_execution_failure",
    "required_native_output_incomplete",
    "native_output_parse_failure",
    "model_identity_mismatch",
    "optimizer_error",
    "optimizer_nonconvergence_or_readiness_hold",
    "nonfinite_fit_output",
    "parameter_boundary_or_estimability_hold",
    "continuous_oracle_ineligible",
    "complete_numeric_eligible"
  )
  nature <- c(
    "data_integrity", "expected_negative_control", "scientific_structural",
    "global_safety", "runtime", "operational", "operational", "semantic",
    "semantic", "artifact", "adapter", "model_identity", "numerical",
    "numerical", "numerical", "estimability", "oracle", "success"
  )
  scope <- c(
    rep("dataset", 3L), "phase", "engine_session",
    rep("dataset_engine", 13L)
  )
  data.frame(
    Precedence = seq_along(code),
    TerminalCode = code,
    FailureNature = nature,
    ClassificationUnit = scope,
    CountsAsExpectedDisposition = code == "expected_structural_rejection",
    CountsAsEngineFailure = code %in% code[5:17],
    PreFitStopBothEngines = code %in% code[1:3],
    GlobalAbortClass = code == "global_resource_abort_unattempted",
    MaySuppressOtherEligibleEngineAttempt =
      code == "global_resource_abort_unattempted",
    RowMustBeRetained = TRUE,
    FailureRowDroppable = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_acf_semantic_code_map <- function() {
  semantic <- mfrmr_cq_srp_failure_registry()
  observed <- data.frame(
    SecondaryCode = semantic$FailureCode,
    PrimaryTerminalCode = ifelse(
      semantic$PrimaryClass == "runtime_unavailable_or_expired",
      "runtime_unavailable_or_expired",
      "registered_semantic_execution_failure"
    ),
    SourceRegistry = "semantic_regex_registry",
    PreserveMatchedTextAndLineNumbers = TRUE,
    RowMustBeRetained = TRUE,
    stringsAsFactors = FALSE
  )
  synthetic_code <- c(
    "executable_missing", "executable_not_executable",
    "launcher_missing_or_not_executable", "exit_status_missing",
    "process_exit_nonzero", "host_execution_error",
    "terminal_marker_missing", "runtime_version_missing",
    "architecture_missing", "non_sentinel_input",
    "demonstration_expiry_missing_or_unparsed",
    "runtime_expired_by_date", "incomplete_output_set",
    "representation_bridge_mismatch"
  )
  synthetic_primary <- c(
    rep("runtime_unavailable_or_expired", 3L),
    rep("host_or_process_failure", 3L),
    "terminal_marker_missing", rep("model_identity_mismatch", 3L),
    rep("runtime_unavailable_or_expired", 2L),
    "required_native_output_incomplete", "generation_or_schema_failure"
  )
  synthetic <- data.frame(
    SecondaryCode = synthetic_code,
    PrimaryTerminalCode = synthetic_primary,
    SourceRegistry = "semantic_preflight_synthetic_code",
    PreserveMatchedTextAndLineNumbers = TRUE,
    RowMustBeRetained = TRUE,
    stringsAsFactors = FALSE
  )
  rbind(observed, synthetic)
}

mfrmr_cq_acf_terminal_class <- function(observed_codes) {
  taxonomy <- mfrmr_cq_acf_failure_taxonomy()
  observed_codes <- unique(as.character(observed_codes))
  mfrmr_cq_acf_assert(
    length(observed_codes) > 0L &&
      all(observed_codes %in% taxonomy$TerminalCode),
    "Terminal classification requires registered observed codes."
  )
  observed <- taxonomy[taxonomy$TerminalCode %in% observed_codes, , drop = FALSE]
  observed$TerminalCode[which.min(observed$Precedence)]
}

mfrmr_cq_acf_summary_registry <- function() {
  metric <- mfrmr_cq_asp_metric_registry()
  active <- metric[
    metric$MetricId != "ASP-UNCERTAINTY-COVERAGE", , drop = FALSE
  ]
  out <- data.frame(
    SummaryId = c(active$MetricId, "ASP-ELAPSED-RUNTIME", "ASP-RETAINED-STORAGE"),
    Perspective = c(active$Perspective, "resource", "resource"),
    Statistic = c(
      "count_and_rate", "count_and_rate", "count_and_rate",
      "count_and_rate", "error_distribution", "error_distribution",
      "coordinate_bias", "coordinate_RMSE",
      "coordinate_difference_distribution",
      "q61_to_q121_difference_distribution", "count_and_rate",
      "min_median_p90_max_and_total_seconds",
      "min_median_p90_max_and_total_bytes"
    ),
    PrimaryStrata = c(
      rep("scenario_class_by_family", 11L),
      "engine_by_family_by_quadrature", "table_and_artifact_kind"
    ),
    CalibrationExploratorySummaryPermitted = TRUE,
    PrimaryPooledSummaryPermitted = FALSE,
    ConditionalNumericSummaryRequiresUnconditionalCompanion = c(
      active$MandatoryUnconditionalCompanion, FALSE, FALSE
    ),
    FailureRowsDroppable = FALSE,
    MayTuneDGP = FALSE,
    MaySelectMetricThreshold = FALSE,
    MaySetConfirmationDecisionRule = FALSE,
    MayEnterConfirmationDataset = FALSE,
    MaySupportPublicClaim = FALSE,
    stringsAsFactors = FALSE
  )
  representation <- data.frame(
    SummaryId = "ASP-REPRESENTATION-INVARIANCE",
    Perspective = "representation_invariance",
    Statistic =
      "mfrmr_planned_absence_vs_explicit_missing_coordinate_and_deviance_difference",
    PrimaryStrata = "family",
    CalibrationExploratorySummaryPermitted = TRUE,
    PrimaryPooledSummaryPermitted = FALSE,
    ConditionalNumericSummaryRequiresUnconditionalCompanion = TRUE,
    FailureRowsDroppable = FALSE,
    MayTuneDGP = FALSE,
    MaySelectMetricThreshold = FALSE,
    MaySetConfirmationDecisionRule = FALSE,
    MayEnterConfirmationDataset = FALSE,
    MaySupportPublicClaim = FALSE,
    stringsAsFactors = FALSE
  )
  active_rows <- seq_len(nrow(active))
  resource_rows <- nrow(active) + seq_len(2L)
  rbind(out[active_rows, , drop = FALSE], representation,
        out[resource_rows, , drop = FALSE])
}

mfrmr_cq_acf_workload_registry <- function(replicates = 25L) {
  replicates <- as.integer(replicates)[1L]
  mfrmr_cq_acf_assert(
    replicates %in% c(5L, 25L),
    "The workload registry permits only frozen tranche A or full calibration."
  )
  seeds <- mfrmr_cq_acf_seed_registry()
  seeds <- seeds[seeds$Replicate <= replicates, , drop = FALSE]
  primary <- seeds[seeds$PrimaryQ61FitRequired, , drop = FALSE]
  paired <- primary[
    primary$PairedRepresentationComparisonRequired, , drop = FALSE
  ]
  dense <- seeds[seeds$SelectiveQ121FitRequired, , drop = FALSE]
  q61 <- data.frame(Family = primary$Family, Nodes = 61L)
  q61 <- q61[rep(seq_len(nrow(q61)), each = 2L), , drop = FALSE]
  q61$Engine <- rep(c("mfrmr", "ConQuest"), times = nrow(q61) / 2L)
  q61_companion <- data.frame(
    Family = paired$Family, Nodes = 61L, Engine = "mfrmr"
  )
  q121 <- data.frame(Family = dense$Family, Nodes = 121L)
  q121 <- q121[rep(seq_len(nrow(q121)), each = 2L), , drop = FALSE]
  q121$Engine <- rep(c("mfrmr", "ConQuest"), times = nrow(q121) / 2L)
  rows <- rbind(q61, q61_companion, q121)
  rows$QuadratureId <- paste0("q", rows$Nodes)
  rows$Attempt <- 1L
  out <- stats::aggregate(
    Attempt ~ Engine + Family + Nodes + QuadratureId,
    data = rows, FUN = sum
  )
  names(out)[names(out) == "Attempt"] <- "PlannedAttemptCount"
  out <- out[order(
    match(out$Nodes, c(61L, 121L)),
    match(out$Engine, c("mfrmr", "ConQuest")),
    match(out$Family, c("RSM", "PCM"))
  ), , drop = FALSE]
  rownames(out) <- NULL
  out$AttemptCapPerScheduledFitCell <- 1L
  out$AutomaticRetryPermitted <- FALSE
  out
}

mfrmr_cq_acf_resource_budget_registry <- function() {
  gib <- 1024^3
  data.frame(
    Stage = c("engine_mechanics_smoke", "calibration_tranche_A", "calibration_full"),
    ExistingDatasetCap = c(18L, 0L, 0L),
    NewGeneratedDatasetCap = c(0L, 90L, 450L),
    StructurallyEligibleDatasetCap = c(14L, 70L, 350L),
    ExpectedNegativeControlDatasetCount = c(4L, 20L, 100L),
    Q61FitAttemptCap = c(30L, 150L, 750L),
    SelectiveQ121FitAttemptCap = c(0L, 40L, 200L),
    TotalFitAttemptCap = c(30L, 190L, 950L),
    ScheduledOutcomeRowCap = c(38L, 230L, 1150L),
    PerFitTimeoutSeconds = 600L,
    CumulativeWallTimeCapSeconds = c(28800L, 28800L, 129600L),
    RetainedStorageCapBytes = c(2 * gib, 2 * gib, 8 * gib),
    ExpansionReviewFraction = mfrmr_cq_acf_expansion_review_fraction,
    ProjectionMethod = mfrmr_cq_acf_projection_method,
    AutomaticRetryPermitted = FALSE,
    ExecutionAuthorizedByThisContract = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_acf_resource_projection <- function(
    cell_observation,
    maximum_dataset_generation_seconds,
    maximum_dataset_retained_bytes) {
  required <- c(
    "Engine", "Family", "Nodes", "MaximumElapsedSeconds",
    "MaximumRetainedBytes"
  )
  mfrmr_cq_acf_assert(
    is.data.frame(cell_observation) &&
      all(required %in% names(cell_observation)) &&
      nrow(cell_observation) == 8L,
    "Resource projection requires all eight frozen workload cells."
  )
  full <- mfrmr_cq_acf_workload_registry(25L)
  observed_key <- paste(
    cell_observation$Engine, cell_observation$Family,
    as.integer(cell_observation$Nodes), sep = "::"
  )
  full_key <- paste(full$Engine, full$Family, full$Nodes, sep = "::")
  index <- match(full_key, observed_key)
  numeric_inputs <- c(
    "MaximumElapsedSeconds", "MaximumRetainedBytes"
  )
  numeric_ready <- all(vapply(
    cell_observation[numeric_inputs], is.numeric, logical(1L)
  )) && is.numeric(maximum_dataset_generation_seconds) &&
    is.numeric(maximum_dataset_retained_bytes)
  numeric_value <- c(
    cell_observation$MaximumElapsedSeconds,
    cell_observation$MaximumRetainedBytes,
    maximum_dataset_generation_seconds,
    maximum_dataset_retained_bytes
  )
  mfrmr_cq_acf_assert(
    !anyDuplicated(observed_key) && !anyNA(index) &&
      length(maximum_dataset_generation_seconds) == 1L &&
      length(maximum_dataset_retained_bytes) == 1L &&
      numeric_ready &&
      all(is.finite(numeric_value)) && all(numeric_value >= 0),
    "Resource projection inputs must be unique, complete, finite, and nonnegative."
  )
  elapsed <- cell_observation$MaximumElapsedSeconds[index]
  bytes <- cell_observation$MaximumRetainedBytes[index]
  projected_elapsed <- sum(elapsed * full$PlannedAttemptCount) +
    maximum_dataset_generation_seconds * 450L
  projected_bytes <- sum(bytes * full$PlannedAttemptCount) +
    maximum_dataset_retained_bytes * 450L
  budget <- mfrmr_cq_acf_resource_budget_registry()
  cap <- budget[budget$Stage == "calibration_full", , drop = FALSE]
  data.frame(
    ProjectionMethod = mfrmr_cq_acf_projection_method,
    ObservedWorkloadCells = nrow(cell_observation),
    FullPlannedFitAttempts = sum(full$PlannedAttemptCount),
    FullPlannedDatasets = 450L,
    ProjectedFullElapsedSeconds = projected_elapsed,
    ProjectedFullStorageBytes = projected_bytes,
    RuntimeExpansionGuard =
      cap$CumulativeWallTimeCapSeconds *
      mfrmr_cq_acf_expansion_review_fraction,
    StorageExpansionGuard =
      cap$RetainedStorageCapBytes *
      mfrmr_cq_acf_expansion_review_fraction,
    RuntimeWithinExpansionGuard = projected_elapsed <=
      cap$CumulativeWallTimeCapSeconds *
      mfrmr_cq_acf_expansion_review_fraction,
    StorageWithinExpansionGuard = projected_bytes <=
      cap$RetainedStorageCapBytes *
      mfrmr_cq_acf_expansion_review_fraction,
    NumericAgreementInspected = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_acf_mechanics_completion_registry <- function() {
  data.frame(
    Input = c(
      "RetainedDatasets", "RetainedOutcomeRows",
      "ExpectedNegativeRejections", "NegativeControlFitAttempts",
      "EligiblePlannedAttempts", "RetainedAttemptOutcomeRows",
      "PeerEligibleAttemptsSuppressed", "EngineFamilyCellsWithParseableQ61",
      "PairedRepresentationOutcomeRows",
      "ExplicitMissingMfrmrAttemptOutcomes",
      "ExplicitMissingMfrmrParseableCells",
      "ConQuestRepresentationBridgeChecks",
      "FreshRuntimeSentinelPassed", "ModelIdentityMismatches",
      "GlobalAbortTriggered", "RowsDropped"
    ),
    RequiredValue = c(
      "18", "38", "4", "0", "30", "30", "0", "4",
      "6", "2", "2", "2", "TRUE", "0", "FALSE", "0"
    ),
    MechanicsOnly = TRUE,
    NumericAgreementInspected = FALSE,
    MayTuneDGPOrThreshold = FALSE,
    ExecutionAuthorizedByCriterion = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_acf_engine_mechanics_decision <- function(audit) {
  registry <- mfrmr_cq_acf_mechanics_completion_registry()
  mfrmr_cq_acf_assert(
    is.list(audit) && all(registry$Input %in% names(audit)),
    "The engine-mechanics audit is incomplete."
  )
  criterion <- c(
    retained_datasets = identical(as.integer(audit$RetainedDatasets), 18L),
    retained_outcome_rows = identical(
      as.integer(audit$RetainedOutcomeRows), 38L
    ),
    expected_negative_rejections = identical(
      as.integer(audit$ExpectedNegativeRejections), 4L
    ),
    negative_controls_prefit = identical(
      as.integer(audit$NegativeControlFitAttempts), 0L
    ),
    eligible_attempt_denominator = identical(
      as.integer(audit$EligiblePlannedAttempts), 30L
    ),
    attempt_outcomes_retained = identical(
      as.integer(audit$RetainedAttemptOutcomeRows), 30L
    ),
    peer_engine_independence = identical(
      as.integer(audit$PeerEligibleAttemptsSuppressed), 0L
    ),
    parser_path_coverage = identical(
      as.integer(audit$EngineFamilyCellsWithParseableQ61), 4L
    ),
    paired_representation_outcomes = identical(
      as.integer(audit$PairedRepresentationOutcomeRows), 6L
    ),
    explicit_missing_attempts = identical(
      as.integer(audit$ExplicitMissingMfrmrAttemptOutcomes), 2L
    ),
    explicit_missing_parser_coverage = identical(
      as.integer(audit$ExplicitMissingMfrmrParseableCells), 2L
    ),
    ConQuest_representation_bridge = identical(
      as.integer(audit$ConQuestRepresentationBridgeChecks), 2L
    ),
    runtime_sentinel = isTRUE(audit$FreshRuntimeSentinelPassed),
    model_identity = identical(
      as.integer(audit$ModelIdentityMismatches), 0L
    ),
    no_global_abort = !isTRUE(audit$GlobalAbortTriggered),
    no_rows_dropped = identical(as.integer(audit$RowsDropped), 0L)
  )
  met <- all(criterion)
  list(
    status = if (met) {
      "engine_mechanics_gate_met_calibration_authorization_review_required"
    } else {
      "engine_mechanics_hold"
    },
    criterion = data.frame(
      Criterion = names(criterion), Passed = unname(criterion),
      stringsAsFactors = FALSE
    ),
    mechanics_gate_met = met,
    all_fit_attempts_required_to_succeed = FALSE,
    numeric_agreement_inspected = FALSE,
    calibration_generation_authorized = FALSE,
    separate_authorization_required = TRUE,
    scientific_equivalence_inferred = FALSE
  )
}

mfrmr_cq_acf_stop_expand_registry <- function() {
  data.frame(
    Event = c(
      "fresh_runtime_sentinel_fails_before_any_engine_run",
      "expected_structural_negative_control",
      "unexpected_structural_rejection",
      "one_engine_fit_or_parse_failure",
      "representation_bridge_mismatch",
      "per_fit_timeout",
      "global_wall_or_storage_cap_reached",
      "existing_or_nonempty_output_target",
      "tranche_A_operational_review_passes",
      "favorable_or_unfavorable_numeric_agreement"
    ),
    Action = c(
      "keep_calibration_generation_closed",
      "retain_dataset_and_stop_both_engines_prefit",
      "retain_dataset_and_stop_both_engines_prefit_then_continue_phase",
      "retain_failure_attempt_peer_engine_and_continue_phase",
      "retain_all_scheduled_rows_and_stop_that_dataset_before_fitting",
      "retain_timeout_attempt_peer_engine_and_continue_phase",
      "abort_new_work_and_materialize_unattempted_ledger_rows",
      "halt_without_overwrite",
      "eligible_for_separate_tranche_B_authorization_review",
      "no_stop_expand_or_tuning_effect"
    ),
    MayDropRows = FALSE,
    MayRetryCompletedOrFailedAttempt = FALSE,
    MayChangeSeedDGPOrMetric = FALSE,
    ExecutionAuthorizedByRule = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_acf_expansion_decision <- function(audit) {
  required <- c(
    "GeneratedDatasetsRetained", "RetainedScheduledOutcomeRows",
    "NegativeControlDatasets", "ExpectedNegativeRejections",
    "NegativeControlFitAttempts", "FreshRuntimeSentinelPassed",
    "GeneratorOrSchemaFailures", "SeedOrDGPDrift",
    "SystemicAdapterFailures", "PairedRepresentationDatasets",
    "PairedRepresentationOutcomeRowsRetained",
    "ExplicitMissingMfrmrFitAttempts",
    "ConQuestRepresentationBridgeChecks", "RepresentationAdapterFailures",
    "WorkloadCellsObserved",
    "ProjectionMethod",
    "ProjectedFullElapsedSeconds", "ProjectedFullStorageBytes",
    "GlobalAbortTriggered", "RowsDropped"
  )
  mfrmr_cq_acf_assert(
    is.list(audit) && all(required %in% names(audit)),
    "The tranche-A operational audit is incomplete."
  )
  scalar_finite <- function(value) {
    is.numeric(value) && length(value) == 1L && !is.na(value) &&
      is.finite(value)
  }
  mfrmr_cq_acf_assert(
    scalar_finite(audit$ProjectedFullElapsedSeconds) &&
      scalar_finite(audit$ProjectedFullStorageBytes),
    "Projected runtime and storage must be finite numeric scalars."
  )
  budget <- mfrmr_cq_acf_resource_budget_registry()
  full <- budget[budget$Stage == "calibration_full", , drop = FALSE]
  criterion <- c(
    retained_datasets = identical(as.integer(audit$GeneratedDatasetsRetained), 90L),
    retained_outcome_rows = identical(
      as.integer(audit$RetainedScheduledOutcomeRows), 230L
    ),
    negative_control_denominator = identical(
      as.integer(audit$NegativeControlDatasets), 20L
    ),
    expected_negative_rejections = identical(
      as.integer(audit$ExpectedNegativeRejections), 20L
    ),
    negative_controls_prefit = identical(
      as.integer(audit$NegativeControlFitAttempts), 0L
    ),
    runtime_sentinel = isTRUE(audit$FreshRuntimeSentinelPassed),
    generator_schema_integrity = identical(
      as.integer(audit$GeneratorOrSchemaFailures), 0L
    ),
    frozen_identity = identical(as.integer(audit$SeedOrDGPDrift), 0L),
    adapter_mechanics = identical(
      as.integer(audit$SystemicAdapterFailures), 0L
    ),
    paired_representation_denominator = identical(
      as.integer(audit$PairedRepresentationDatasets), 10L
    ),
    paired_representation_outcomes = identical(
      as.integer(audit$PairedRepresentationOutcomeRowsRetained), 30L
    ),
    explicit_missing_mfrmr_attempts = identical(
      as.integer(audit$ExplicitMissingMfrmrFitAttempts), 10L
    ),
    ConQuest_representation_bridge = identical(
      as.integer(audit$ConQuestRepresentationBridgeChecks), 10L
    ),
    representation_adapter = identical(
      as.integer(audit$RepresentationAdapterFailures), 0L
    ),
    projection_cells_complete = identical(
      as.integer(audit$WorkloadCellsObserved), 8L
    ),
    projection_method_frozen = identical(
      as.character(audit$ProjectionMethod), mfrmr_cq_acf_projection_method
    ),
    projected_runtime_within_guard =
      is.finite(audit$ProjectedFullElapsedSeconds) &&
      audit$ProjectedFullElapsedSeconds <=
        full$CumulativeWallTimeCapSeconds *
        mfrmr_cq_acf_expansion_review_fraction,
    projected_storage_within_guard =
      is.finite(audit$ProjectedFullStorageBytes) &&
      audit$ProjectedFullStorageBytes <=
        full$RetainedStorageCapBytes *
        mfrmr_cq_acf_expansion_review_fraction,
    no_global_abort = !isTRUE(audit$GlobalAbortTriggered),
    no_rows_dropped = identical(as.integer(audit$RowsDropped), 0L)
  )
  met <- all(criterion)
  list(
    status = if (met) {
      "tranche_A_operational_gate_met_separate_authorization_required"
    } else {
      "tranche_A_operational_hold"
    },
    criterion = data.frame(
      Criterion = names(criterion), Passed = unname(criterion),
      stringsAsFactors = FALSE
    ),
    operational_gate_met = met,
    numeric_agreement_inspected = FALSE,
    tranche_B_execution_authorized = FALSE,
    separate_authorization_required = TRUE,
    calibration_result_may_set_confirmation_rule = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}

mfrmr_cq_acf_review <- function(
    g3_evidence = mfrmr_cq_acf_g3_evidence_registry()) {
  mfrmr_cq_acf_require_contracts()
  seed <- mfrmr_cq_acf_seed_registry()
  phase <- mfrmr_cq_acf_phase_separation()
  mechanics <- mfrmr_cq_acf_engine_mechanics_registry()
  bridge <- mfrmr_cq_acf_representation_bridge_registry()
  profile <- mfrmr_cq_acf_engine_profile_registry()
  runtime <- mfrmr_cq_acf_runtime_contract()
  taxonomy <- mfrmr_cq_acf_failure_taxonomy()
  semantic <- mfrmr_cq_acf_semantic_code_map()
  summary <- mfrmr_cq_acf_summary_registry()
  tranche_a <- mfrmr_cq_acf_workload_registry(5L)
  full <- mfrmr_cq_acf_workload_registry(25L)
  budget <- mfrmr_cq_acf_resource_budget_registry()
  mechanics_completion <- mfrmr_cq_acf_mechanics_completion_registry()
  rules <- mfrmr_cq_acf_stop_expand_registry()
  g3_ready <- is.data.frame(g3_evidence) && nrow(g3_evidence) == 1L &&
    identical(
      g3_evidence$Status,
      "ASP_G3_eighteen_smoke_datasets_generated_and_retained"
    ) && g3_evidence$GeneratedDatasets == 18L &&
    g3_evidence$UniqueArms == 18L &&
    g3_evidence$StructurallyEligibleDatasets == 14L &&
    g3_evidence$ExpectedStructuralRejections == 4L &&
    g3_evidence$PrototypeResponseVectorsReused == 0L &&
    g3_evidence$RetainedUnconditionalDatasets == 18L &&
    g3_evidence$FitAttempts == 0L && g3_evidence$ConQuestAttempts == 0L &&
    !g3_evidence$OperatingCharacteristicsEstimated &&
    !g3_evidence$MayTuneDGPOrThreshold &&
    !g3_evidence$MayEnterCalibrationOrConfirmation
  frozen <- g3_ready && nrow(seed) == 450L &&
    identical(sort(unique(seed$Replicate)), 1:25) &&
    sum(seed$Tranche == "A") == 90L && sum(seed$Tranche == "B") == 360L &&
    sum(seed$PrimaryQ61FitRequired) == 350L &&
    sum(seed$Q61FitAttemptCount) == 750L &&
    sum(seed$PairedRepresentationComparisonRequired) == 50L &&
    sum(seed$SelectiveQ121FitRequired) == 100L &&
    sum(seed$SelectiveQ121FitAttemptCount) == 200L &&
    sum(seed$PlannedOutcomeRowCount) == 1150L &&
    !any(seed$Generated) && !any(seed$ResultOpened) &&
    !any(seed$Seed %in% mfrmr_cq_asg_seed_registry()$Seed) &&
    isTRUE(phase$AssignedSeedDisjoint[phase$Phase == "calibration"]) &&
    is.na(phase$AssignedSeedDisjoint[phase$Phase == "confirmation"]) &&
    nrow(mechanics) == 38L && sum(mechanics$AttemptCap) == 30L &&
    sum(mechanics$RepresentationId == "explicit_missing") == 2L &&
    sum(mechanics$ConQuestCanonicalBridgeForBothPairedRepresentations) == 2L &&
    nrow(bridge) == 4L && identical(bridge$CheckOrder, 1:4) &&
    all(bridge$RequiredForEachPairedDatasetBridgeCheck) &&
    !any(bridge$ByteEqualityRequired) &&
    !any(bridge$NumericAgreementInspected) &&
    !any(bridge$ExecutionAuthorizedByThisContract) &&
    !any(mechanics$AttemptAuthorizedByThisContract) &&
    nrow(profile) == 8L && !any(profile$AutomaticRetryPermitted) &&
    !any(profile$ExecutionAuthorizedByThisContract) &&
    runtime$RunNotAfter < runtime$ExpiryDate &&
    runtime$FreshDataFreeSentinelRequiredEachSession &&
    nrow(taxonomy) == 18L && !anyDuplicated(taxonomy$TerminalCode) &&
    identical(taxonomy$Precedence, seq_len(nrow(taxonomy))) &&
    all(taxonomy$RowMustBeRetained) && !any(taxonomy$FailureRowDroppable) &&
    nrow(semantic) == nrow(mfrmr_cq_srp_failure_registry()) + 14L &&
    !anyDuplicated(semantic$SecondaryCode) &&
    nrow(summary) == 14L &&
    !any(summary$FailureRowsDroppable) &&
    !any(summary$MaySelectMetricThreshold) &&
    !any(summary$MaySetConfirmationDecisionRule) &&
    nrow(tranche_a) == 8L && sum(tranche_a$PlannedAttemptCount) == 190L &&
    nrow(full) == 8L && sum(full$PlannedAttemptCount) == 950L &&
    identical(budget$TotalFitAttemptCap, c(30L, 190L, 950L)) &&
    all(budget$ProjectionMethod == mfrmr_cq_acf_projection_method) &&
    !any(budget$ExecutionAuthorizedByThisContract) &&
    nrow(mechanics_completion) == 16L &&
    !any(mechanics_completion$NumericAgreementInspected) &&
    !any(mechanics_completion$ExecutionAuthorizedByCriterion) &&
    nrow(rules) == 10L && !any(rules$MayDropRows) &&
    !any(rules$MayRetryCompletedOrFailedAttempt) &&
    !any(rules$MayChangeSeedDGPOrMetric)
  list(
    specification = mfrmr_cq_acf_specification,
    contract_version = mfrmr_cq_acf_contract,
    status = if (frozen) {
      "ASP_G4_calibration_contract_frozen_execution_closed"
    } else {
      "ASP_G4_calibration_freeze_failed"
    },
    g3_evidence = g3_evidence,
    seed_registry = seed,
    phase_separation = phase,
    engine_mechanics_registry = mechanics,
    engine_profile_registry = profile,
    runtime_contract = runtime,
    failure_taxonomy = taxonomy,
    semantic_code_map = semantic,
    permitted_summary_registry = summary,
    tranche_A_workload = tranche_a,
    full_calibration_workload = full,
    resource_budget = budget,
    mechanics_completion_registry = mechanics_completion,
    stop_expand_registry = rules,
    G3_prerequisite_complete = g3_ready,
    G4_calibration_freeze_complete = frozen,
    calibration_seed_band_frozen = frozen,
    failure_taxonomy_frozen = frozen,
    permitted_exploratory_summaries_frozen = frozen,
    sequential_and_resource_rules_frozen = frozen,
    engine_mechanics_prerequisite_frozen = frozen,
    paired_missingness_workload_corrected_before_engine_execution = frozen,
    no_engine_or_calibration_results_opened_before_correction = TRUE,
    engine_mechanics_execution_authorized = FALSE,
    calibration_response_generation_authorized = FALSE,
    calibration_execution_authorized = FALSE,
    calibration_results_opened = FALSE,
    confirmation_seed_band_frozen = FALSE,
    confirmation_decision_rules_frozen = FALSE,
    any_sampled_response_generated = FALSE,
    any_fit_attempted = FALSE,
    ConQuest_execution_attempted = FALSE,
    next_action = "ASP-G4E-ENGINE-MECHANICS-SMOKE-AUTHORIZATION",
    public_text_change_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
