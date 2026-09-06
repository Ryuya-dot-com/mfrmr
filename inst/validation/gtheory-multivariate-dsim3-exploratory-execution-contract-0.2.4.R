# Internal D-SIM-3 exploratory execution contract and unopened plan.
#
# This file freezes the execution denominator, seed identities, terminal-state
# algebra, and resource envelope for the 21-cell D-SIM-3 coverage manifest. It
# never initializes an RNG stream, generates a response, or executes a fit.

mfrmr_gtds3e_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds_v4_contract",
    "mfrmr_gtds_v4_validate_contract", "mfrmr_gtds2_contract",
    "mfrmr_gtds3_contract", "mfrmr_gtds3_validate_contract",
    "mfrmr_gtds3_manifest", "mfrmr_gtds3_assert_manifest"
  )
  target <- environment(mfrmr_gtds3e_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the v4, D-SIM-2, and D-SIM-3 coverage contracts first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3e_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3e_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM3-EXPLORATORY-EXECUTION-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-30",
    ParentCoverageContractId = "MFRMR-GTHEORY-MV-DSIM3-COVERAGE-V1",
    ParentCoverageContractHash =
      "39b4b542f3afe617cc8f2912a23aa4211790460c8765d4ad38f9cd95575c508f",
    ParentCoverageManifestHash =
      "4c6958f00aac7598d777387ec113cd43474031430492e83e6183d19dcedf7197",
    ParentCoverageRecord =
      "gtheory-multivariate-dsim3-coverage-manifest-record-0.2.4.md"
  )
}

mfrmr_gtds3e_seed_band_registry <- function() {
  data.frame(
    BandOrdinal = 1:5,
    BandId = c(
      "LEGACY-PILOT-851", "LEGACY-CONFIRMATION-852",
      "LEGACY-NEGATIVE-CONTROL-853", "NONRESERVED-FIXTURE-854",
      "DSIM3-EXPLORATORY-855"
    ),
    LowerInclusive = c(
      851000000L, 852000000L, 853000000L, 854000000L, 855000000L
    ),
    UpperInclusive = c(
      851999999L, 852999999L, 853999999L, 854999999L, 855999999L
    ),
    BandRole = c(
      "historical_unopened_plan", "historical_unopened_plan",
      "historical_structural_control", "nonreserved_fixture_preflight",
      "prospective_dsim3_exploratory"
    ),
    AssignedToCurrentContract = c(rep(FALSE, 4L), TRUE),
    RngStreamOpened = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3e_seed_policy <- function() {
  list(
    BandId = "DSIM3-EXPLORATORY-855",
    BaseSeed = 855000000L,
    ScenarioStride = 1000L,
    ReplicatesPerScenario = 2L,
    SeedFormula = "BaseSeed+1000*ScenarioOrdinal+Replicate",
    MinimumPlannedSeed = 855001001L,
    MaximumPlannedSeed = 855021002L,
    RNGKind = "L'Ecuyer-CMRG",
    NormalKind = "Inversion",
    SampleKind = "Rejection",
    ComponentSubstreamOrder = "Object|Rater|Object:Rater|Residual",
    AssignmentUsesRandomness = FALSE,
    ReplacementSeedAllowed = FALSE,
    EarlyStoppingAllowed = FALSE,
    ExactSameSeedReplayMayReplaceOriginalReceipt = FALSE,
    FutureConfirmationSeedIdentityAssigned = FALSE,
    RngStreamOpened = FALSE
  )
}

mfrmr_gtds3e_resource_limit_registry <- function() {
  data.frame(
    LimitOrdinal = 1:5,
    ScopeId = c(
      "dataset_generation", "one_route_fit", "one_route_metric",
      "one_dataset_pipeline", "complete_exploratory_run"
    ),
    MaximumWallSeconds = c(300L, 1200L, 120L, 7200L, 172800L),
    MaximumPeakRssMiB = c(2048L, 8192L, 2048L, 8192L, 8192L),
    MaximumConcurrentWorkers = 1L,
    ExceedanceDisposition = c(
      "generation_resource_limit_terminal",
      "fit_resource_limit_terminal",
      "metric_resource_limit_terminal",
      "dataset_pipeline_resource_limit_terminal",
      "run_resource_limit_stop_new_launches_retain_all_registered_units"
    ),
    IsStatisticalAcceptanceThreshold = FALSE,
    EnforcementQualificationRequired = TRUE,
    EnforcementCurrentlyReady = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3e_denominator_rule_registry <- function() {
  data.frame(
    RuleOrdinal = 1:14,
    RuleId = c(
      "coverage_manifest_is_scenario_population",
      "two_datasets_per_scenario", "routes_share_dataset",
      "estimands_share_dataset", "route_estimands_do_not_vote",
      "all_route_rows_retained", "all_coordinate_rows_retained",
      "no_success_only_denominator", "no_replacement_seed",
      "exactly_one_dataset_terminal_state",
      "exactly_one_route_terminal_state", "unrecorded_blocks_completion",
      "resource_exceedance_is_terminal", "no_adaptive_expansion"
    ),
    Requirement = c(
      "all_21_frozen_design_cells_enter_the_exploratory_denominator",
      "exactly_two_distinct_seeded_dataset_attempts_per_design_cell",
      "five_route_units_reference_one_dataset_and_are_not_replications",
      "ABS_PHI_and_REL_G_reference_one_dataset_and_are_not_replications",
      "route_estimand_coordinates_remain_separate_and_never_vote",
      "prefit_block_fit_failure_or_hold_never_deletes_a_route_unit",
      "metric_unavailability_never_deletes_a_route_estimand_coordinate",
      "successful_generations_or_fits_cannot_redefine_any_denominator",
      "a_failed_dataset_is_never_regenerated_with_a_new_seed",
      "every_dataset_attempt_has_one_registered_terminal_receipt",
      "every_route_unit_has_one_registered_terminal_receipt",
      "missing_receipt_is_invalid_and_cannot_be_imputed_as_failure",
      "time_or_memory_exceedance_is_counted_without_replacement",
      "scenario_route_replicate_or_resource_limits_never_expand_after_output"
    ),
    CurrentContractSatisfied = TRUE,
    OutcomeAdaptiveRevisionAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3e_terminal_state_registry <- function() {
  data.frame(
    StateOrdinal = 1:13,
    UnitType = c(
      rep("dataset", 3L), rep("route", 9L), "integrity"
    ),
    TerminalState = c(
      "generation_complete", "generation_failure",
      "generation_resource_limit", "not_attempted_generation_dependency",
      "prefit_rejected_as_planned", "not_applicable_as_frozen",
      "missing_contract_block_as_frozen", "fit_failure",
      "fit_resource_limit", "metric_failure", "metric_resource_limit",
      "complete_nonpromoting", "unrecorded_invalid"
    ),
    ValidTerminalReceipt = c(rep(TRUE, 12L), FALSE),
    CountsInRegisteredDenominator = TRUE,
    ReplacementAllowed = FALSE,
    PromotesSupport = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3e_route_disposition_map <- function() {
  data.frame(
    QualificationStatus = c(
      "conditionally_representable_diagonal_residual",
      "nonpooling_comparator", "univariate_closure_comparator",
      "deliberately_invalid_negative_control",
      "not_applicable_univariate_closure",
      "conditional_linked_event_contract_not_implemented",
      "conditionally_representable_not_implemented",
      "requires_custom_covariance_contract",
      "requires_design_specific_or_custom_contract"
    ),
    PlannedDisposition = c(
      rep("qualification_candidate", 3L),
      "negative_control_prefit_reject", "frozen_not_applicable",
      rep("blocked_unimplemented_contract", 4L)
    ),
    PreExecutionQualificationRequired = c(rep(TRUE, 3L), rep(FALSE, 6L)),
    BackendCallAllowedAfterQualification = c(rep(TRUE, 3L), rep(FALSE, 6L)),
    FrozenNoCallTerminalState = c(
      rep("", 3L), "prefit_rejected_as_planned",
      "not_applicable_as_frozen", rep("missing_contract_block_as_frozen", 4L)
    ),
    CountsInRouteDenominator = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3e_contract <- function() {
  mfrmr_gtds3e_require_primitives()
  coverage <- mfrmr_gtds3_contract()
  identity <- mfrmr_gtds3e_identity()
  payload <- c(identity, list(
    ParentCoverageScenarioCount = coverage$CanonicalDatasetScenarioCount,
    DatasetReplicatesPerScenario = 2L,
    PlannedDatasetAttemptCount = 42L,
    PlannedRouteUnitCount = 210L,
    PlannedDatasetEstimandUnitCount = 84L,
    PlannedRouteEstimandCoordinateCount = 420L,
    PlannedControlDefinitionCount = 3L,
    SeedBandRegistry = mfrmr_gtds3e_seed_band_registry(),
    SeedPolicy = mfrmr_gtds3e_seed_policy(),
    ResourceLimitRegistry = mfrmr_gtds3e_resource_limit_registry(),
    DenominatorRuleRegistry = mfrmr_gtds3e_denominator_rule_registry(),
    TerminalStateRegistry = mfrmr_gtds3e_terminal_state_registry(),
    RouteDispositionMap = mfrmr_gtds3e_route_disposition_map(),
    OperationalOwnerAuthorizationRequired = FALSE,
    PackageUserDecisionRequired = FALSE,
    ExternalFreezeReceiptRequired = FALSE,
    SubstantiveTargetRequired = FALSE,
    ContractFrozen = TRUE,
    ExecutionPlanFreezeAllowed = TRUE,
    PreExecutionQualificationAllowed = TRUE,
    PartialExecutionAllowed = FALSE,
    ResponseGenerationCurrentlyAllowed = FALSE,
    RngStreamAccessCurrentlyAllowed = FALSE,
    FitExecutionCurrentlyAllowed = FALSE,
    ExploratoryExecutionCurrentlyAllowed = FALSE,
    AccuracyThresholdSelectionAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3e_hash(payload)
  )), class = c("mfrmr_gtds3e_contract", "list"))
}

mfrmr_gtds3e_validate_contract <- function(
    contract = mfrmr_gtds3e_contract()) {
  mfrmr_gtds3e_require_primitives()
  coverage <- mfrmr_gtds3_contract()
  mfrmr_gtds3_validate_contract(coverage)
  canonical <- mfrmr_gtds3e_contract()
  bands <- contract$SeedBandRegistry
  valid <- inherits(contract, "mfrmr_gtds3e_contract") &&
    identical(contract, canonical) &&
    identical(contract$ParentCoverageContractId, coverage$ContractId) &&
    identical(contract$ParentCoverageContractHash, coverage$ContractHash) &&
    identical(contract$ParentCoverageScenarioCount, 21L) &&
    identical(contract$DatasetReplicatesPerScenario, 2L) &&
    identical(contract$PlannedDatasetAttemptCount, 42L) &&
    identical(contract$PlannedRouteUnitCount, 210L) &&
    identical(contract$PlannedDatasetEstimandUnitCount, 84L) &&
    identical(contract$PlannedRouteEstimandCoordinateCount, 420L) &&
    identical(contract$PlannedControlDefinitionCount, 3L) &&
    isTRUE(contract$ContractFrozen) &&
    isTRUE(contract$ExecutionPlanFreezeAllowed) &&
    isTRUE(contract$PreExecutionQualificationAllowed) &&
    !isTRUE(contract$OperationalOwnerAuthorizationRequired) &&
    !isTRUE(contract$PackageUserDecisionRequired) &&
    !isTRUE(contract$ExternalFreezeReceiptRequired) &&
    !isTRUE(contract$SubstantiveTargetRequired) &&
    !isTRUE(contract$PartialExecutionAllowed) &&
    !isTRUE(contract$ResponseGenerationCurrentlyAllowed) &&
    !isTRUE(contract$RngStreamAccessCurrentlyAllowed) &&
    !isTRUE(contract$FitExecutionCurrentlyAllowed) &&
    !isTRUE(contract$ExploratoryExecutionCurrentlyAllowed) &&
    !isTRUE(contract$AccuracyThresholdSelectionAllowed) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed) &&
    identical(nrow(bands), 5L) &&
    all(bands$UpperInclusive[-nrow(bands)] < bands$LowerInclusive[-1L]) &&
    identical(sum(bands$AssignedToCurrentContract), 1L) &&
    identical(
      bands$BandId[bands$AssignedToCurrentContract],
      contract$SeedPolicy$BandId
    ) &&
    all(!bands$RngStreamOpened) &&
    !isTRUE(contract$SeedPolicy$ReplacementSeedAllowed) &&
    !isTRUE(contract$SeedPolicy$EarlyStoppingAllowed) &&
    !isTRUE(contract$SeedPolicy$RngStreamOpened) &&
    nrow(contract$DenominatorRuleRegistry) == 14L &&
    all(contract$DenominatorRuleRegistry$CurrentContractSatisfied) &&
    all(!contract$DenominatorRuleRegistry$OutcomeAdaptiveRevisionAllowed) &&
    nrow(contract$ResourceLimitRegistry) == 5L &&
    all(contract$ResourceLimitRegistry$EnforcementQualificationRequired) &&
    all(!contract$ResourceLimitRegistry$EnforcementCurrentlyReady)
  if (!valid) {
    stop("The D-SIM-3 exploratory execution contract is invalid or altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3e_seed_for <- function(scenario_ordinal, replicate, policy) {
  scenario_ordinal <- as.integer(scenario_ordinal)
  replicate <- as.integer(replicate)
  if (length(scenario_ordinal) != 1L || is.na(scenario_ordinal) ||
      scenario_ordinal < 1L || scenario_ordinal > 21L ||
      length(replicate) != 1L || is.na(replicate) ||
      replicate < 1L || replicate > policy$ReplicatesPerScenario) {
    stop("A canonical D-SIM-3 scenario and replicate are required.",
         call. = FALSE)
  }
  as.integer(
    policy$BaseSeed + policy$ScenarioStride * scenario_ordinal + replicate
  )
}

mfrmr_gtds3e_dataset_plan <- function(manifest, contract) {
  scenarios <- manifest$ScenarioRegistry
  rows <- vector(
    "list", nrow(scenarios) * contract$DatasetReplicatesPerScenario
  )
  cursor <- 0L
  for (index in seq_len(nrow(scenarios))) {
    for (replicate in seq_len(contract$DatasetReplicatesPerScenario)) {
      cursor <- cursor + 1L
      seed <- mfrmr_gtds3e_seed_for(
        scenarios$ScenarioOrdinal[[index]], replicate, contract$SeedPolicy
      )
      dataset_id <- paste0("D3E-D", sprintf("%03d", cursor), "-", substr(
        mfrmr_gtds3e_hash(list(
          ContractHash = contract$ContractHash,
          ScenarioHash = scenarios$ScenarioHash[[index]],
          Replicate = replicate, DataSeed = seed
        )), 1L, 16L
      ))
      rows[[cursor]] <- data.frame(
        DatasetOrdinal = cursor, DatasetId = dataset_id,
        ScenarioOrdinal = scenarios$ScenarioOrdinal[[index]],
        ScenarioId = scenarios$ScenarioId[[index]],
        ScenarioHash = scenarios$ScenarioHash[[index]],
        Replicate = as.integer(replicate), DataSeed = seed,
        SeedBandId = contract$SeedPolicy$BandId,
        PlannedDatasetAttempt = TRUE,
        ResponseGenerated = FALSE, RngStreamOpened = FALSE,
        ExecutionSelected = FALSE, TerminalReceiptAvailable = FALSE,
        stringsAsFactors = FALSE
      )
    }
  }
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3e_route_unit_plan <- function(
    datasets, manifest, contract) {
  routes <- manifest$RouteProjectionRegistry
  disposition <- contract$RouteDispositionMap
  rows <- vector("list", nrow(datasets))
  for (index in seq_len(nrow(datasets))) {
    dataset <- datasets[index, , drop = FALSE]
    scenario_routes <- routes[
      routes$ScenarioId == dataset$ScenarioId[[1L]], , drop = FALSE
    ]
    scenario_routes$DatasetOrdinal <- dataset$DatasetOrdinal[[1L]]
    scenario_routes$DatasetId <- dataset$DatasetId[[1L]]
    scenario_routes$Replicate <- dataset$Replicate[[1L]]
    map_index <- match(
      scenario_routes$QualificationStatus, disposition$QualificationStatus
    )
    scenario_routes$PlannedDisposition <-
      disposition$PlannedDisposition[map_index]
    scenario_routes$PreExecutionQualificationRequired <-
      disposition$PreExecutionQualificationRequired[map_index]
    scenario_routes$BackendCallAllowedAfterQualification <-
      disposition$BackendCallAllowedAfterQualification[map_index]
    scenario_routes$FrozenNoCallTerminalState <-
      disposition$FrozenNoCallTerminalState[map_index]
    scenario_routes$CountsInRouteDenominator <- TRUE
    scenario_routes$ExecutionSelected <- FALSE
    scenario_routes$BackendCallCurrentlyAllowed <- FALSE
    scenario_routes$FitExecuted <- FALSE
    scenario_routes$MetricComputed <- FALSE
    rows[[index]] <- scenario_routes
  }
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output$RouteUnitOrdinal <- seq_len(nrow(output))
  output$RouteUnitId <- paste0("D3E-U", sprintf("%03d", output$RouteUnitOrdinal),
    "-", vapply(seq_len(nrow(output)), function(index) {
      substr(mfrmr_gtds3e_hash(list(
        ContractHash = contract$ContractHash,
        DatasetId = output$DatasetId[[index]],
        RouteId = output$RouteId[[index]],
        QualificationStatus = output$QualificationStatus[[index]]
      )), 1L, 16L)
    }, character(1L)))
  output[c(
    "RouteUnitOrdinal", "RouteUnitId", "DatasetOrdinal", "DatasetId",
    "ScenarioOrdinal", "ScenarioId", "Replicate", "RouteOrdinal",
    "RouteId", "CoverageRole", "QualificationStatus",
    "PlannedDisposition", "PreExecutionQualificationRequired",
    "BackendCallAllowedAfterQualification", "FrozenNoCallTerminalState",
    "CountsInRouteDenominator", "ExecutionSelected",
    "BackendCallCurrentlyAllowed", "FitExecuted", "MetricComputed"
  )]
}

mfrmr_gtds3e_dataset_estimand_plan <- function(
    datasets, manifest, contract) {
  estimands <- unique(manifest$EstimandProjectionRegistry$EstimandId)
  grid <- expand.grid(
    DatasetOrdinal = datasets$DatasetOrdinal, EstimandId = estimands,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  grid$DatasetId <- datasets$DatasetId[grid$DatasetOrdinal]
  grid$ScenarioId <- datasets$ScenarioId[grid$DatasetOrdinal]
  grid$Replicate <- datasets$Replicate[grid$DatasetOrdinal]
  grid$DatasetEstimandUnitOrdinal <- seq_len(nrow(grid))
  grid$DatasetEstimandUnitId <- paste0(
    "D3E-E", sprintf("%03d", grid$DatasetEstimandUnitOrdinal), "-",
    vapply(seq_len(nrow(grid)), function(index) {
      substr(mfrmr_gtds3e_hash(list(
        ContractHash = contract$ContractHash,
        DatasetId = grid$DatasetId[[index]],
        EstimandId = grid$EstimandId[[index]]
      )), 1L, 16L)
    }, character(1L))
  )
  grid$CountsAsIndependentDataset <- FALSE
  grid$CrossEstimandVotingAllowed <- FALSE
  grid$ExecutionSelected <- FALSE
  grid[c(
    "DatasetEstimandUnitOrdinal", "DatasetEstimandUnitId",
    "DatasetOrdinal", "DatasetId", "ScenarioId", "Replicate",
    "EstimandId", "CountsAsIndependentDataset",
    "CrossEstimandVotingAllowed", "ExecutionSelected"
  )]
}

mfrmr_gtds3e_route_estimand_plan <- function(
    route_units, dataset_estimands, contract) {
  estimands <- unique(dataset_estimands$EstimandId)
  grid <- expand.grid(
    RouteUnitOrdinal = route_units$RouteUnitOrdinal,
    EstimandId = estimands,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  grid$RouteUnitId <- route_units$RouteUnitId[grid$RouteUnitOrdinal]
  grid$DatasetOrdinal <- route_units$DatasetOrdinal[grid$RouteUnitOrdinal]
  grid$DatasetId <- route_units$DatasetId[grid$RouteUnitOrdinal]
  grid$ScenarioId <- route_units$ScenarioId[grid$RouteUnitOrdinal]
  grid$Replicate <- route_units$Replicate[grid$RouteUnitOrdinal]
  grid$RouteId <- route_units$RouteId[grid$RouteUnitOrdinal]
  grid$CoordinateOrdinal <- seq_len(nrow(grid))
  grid$CoordinateId <- paste0(
    "D3E-C", sprintf("%03d", grid$CoordinateOrdinal), "-",
    vapply(seq_len(nrow(grid)), function(index) {
      substr(mfrmr_gtds3e_hash(list(
        ContractHash = contract$ContractHash,
        RouteUnitId = grid$RouteUnitId[[index]],
        EstimandId = grid$EstimandId[[index]]
      )), 1L, 16L)
    }, character(1L))
  )
  grid$CountsAsIndependentDataset <- FALSE
  grid$CrossRouteVotingAllowed <- FALSE
  grid$CrossEstimandVotingAllowed <- FALSE
  grid$MetricAvailable <- FALSE
  grid[c(
    "CoordinateOrdinal", "CoordinateId", "RouteUnitOrdinal", "RouteUnitId",
    "DatasetOrdinal", "DatasetId", "ScenarioId", "Replicate", "RouteId",
    "EstimandId", "CountsAsIndependentDataset", "CrossRouteVotingAllowed",
    "CrossEstimandVotingAllowed", "MetricAvailable"
  )]
}

mfrmr_gtds3e_control_plan <- function(manifest) {
  controls <- manifest$NegativeControlRegistry
  controls$ControlUnitOrdinal <- seq_len(nrow(controls))
  controls$CountsInControlDenominator <- TRUE
  controls$RngStreamRequired <- FALSE
  controls$ExecutionSelected <- FALSE
  controls$ObservedDispositionAvailable <- FALSE
  controls[c(
    "ControlUnitOrdinal", "ControlId", "ControlType", "ScenarioId",
    "ReferenceDesignId", "ExpectedDisposition",
    "CountsInControlDenominator", "RngStreamRequired", "ExecutionSelected",
    "ObservedDispositionAvailable"
  )]
}

mfrmr_gtds3e_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds3e_require_primitives", "mfrmr_gtds3e_hash",
    "mfrmr_gtds3e_identity", "mfrmr_gtds3e_seed_band_registry",
    "mfrmr_gtds3e_seed_policy", "mfrmr_gtds3e_resource_limit_registry",
    "mfrmr_gtds3e_denominator_rule_registry",
    "mfrmr_gtds3e_terminal_state_registry",
    "mfrmr_gtds3e_route_disposition_map", "mfrmr_gtds3e_contract",
    "mfrmr_gtds3e_validate_contract", "mfrmr_gtds3e_seed_for",
    "mfrmr_gtds3e_dataset_plan", "mfrmr_gtds3e_route_unit_plan",
    "mfrmr_gtds3e_dataset_estimand_plan",
    "mfrmr_gtds3e_route_estimand_plan", "mfrmr_gtds3e_control_plan",
    "mfrmr_gtds3e_implementation_identity", "mfrmr_gtds3e_payload_fields",
    "mfrmr_gtds3e_assert_plan", "mfrmr_gtds3e_plan"
  )
  target <- environment(mfrmr_gtds3e_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions), FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds3e_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3e_payload_fields <- function() {
  c(
    "Contract", "CoverageManifestHash", "DatasetAttemptRegistry",
    "RouteUnitRegistry", "DatasetEstimandRegistry",
    "RouteEstimandCoordinateRegistry", "ControlUnitRegistry",
    "ImplementationIdentity", "Summary"
  )
}

mfrmr_gtds3e_assert_plan <- function(plan) {
  fields <- mfrmr_gtds3e_payload_fields()
  if (!inherits(plan, "mfrmr_gtds3e_plan") ||
      !identical(names(plan), c(fields, "PlanHash"))) {
    stop("A typed D-SIM-3 exploratory execution plan is required.",
         call. = FALSE)
  }
  mfrmr_gtds3e_validate_contract(plan$Contract)
  datasets <- plan$DatasetAttemptRegistry
  routes <- plan$RouteUnitRegistry
  estimands <- plan$DatasetEstimandRegistry
  coordinates <- plan$RouteEstimandCoordinateRegistry
  controls <- plan$ControlUnitRegistry
  expected_seeds <- vapply(seq_len(nrow(datasets)), function(index) {
    mfrmr_gtds3e_seed_for(
      datasets$ScenarioOrdinal[[index]], datasets$Replicate[[index]],
      plan$Contract$SeedPolicy
    )
  }, integer(1L))
  disposition_counts <- table(factor(
    routes$PlannedDisposition,
    levels = c(
      "qualification_candidate", "negative_control_prefit_reject",
      "frozen_not_applicable", "blocked_unimplemented_contract"
    )
  ))
  valid <- identical(plan$PlanHash, mfrmr_gtds3e_hash(plan[fields])) &&
    identical(
      plan$ImplementationIdentity, mfrmr_gtds3e_implementation_identity()
    ) &&
    identical(plan$CoverageManifestHash,
              plan$Contract$ParentCoverageManifestHash) &&
    identical(nrow(datasets), 42L) &&
    identical(nrow(routes), 210L) &&
    identical(nrow(estimands), 84L) &&
    identical(nrow(coordinates), 420L) &&
    identical(nrow(controls), 3L) &&
    !anyDuplicated(datasets$DatasetId) &&
    !anyDuplicated(routes$RouteUnitId) &&
    !anyDuplicated(estimands$DatasetEstimandUnitId) &&
    !anyDuplicated(coordinates$CoordinateId) &&
    identical(datasets$DataSeed, expected_seeds) &&
    !anyDuplicated(datasets$DataSeed) &&
    min(datasets$DataSeed) == plan$Contract$SeedPolicy$MinimumPlannedSeed &&
    max(datasets$DataSeed) == plan$Contract$SeedPolicy$MaximumPlannedSeed &&
    all(datasets$DataSeed >= 855000000L & datasets$DataSeed <= 855999999L) &&
    identical(
      sort(unique(datasets$ScenarioId)), sprintf("D3-S%03d", 1:21)
    ) &&
    all(table(datasets$ScenarioId) == 2L) &&
    all(table(routes$DatasetId) == 5L) &&
    all(table(estimands$DatasetId) == 2L) &&
    all(table(coordinates$RouteUnitId) == 2L) &&
    identical(as.integer(disposition_counts), c(50L, 40L, 8L, 112L)) &&
    identical(sum(routes$BackendCallAllowedAfterQualification), 50L) &&
    identical(sum(routes$PreExecutionQualificationRequired), 50L) &&
    all(nzchar(routes$FrozenNoCallTerminalState[
      routes$PlannedDisposition != "qualification_candidate"
    ])) &&
    all(!datasets$ResponseGenerated) && all(!datasets$RngStreamOpened) &&
    all(!datasets$ExecutionSelected) &&
    all(!datasets$TerminalReceiptAvailable) &&
    all(routes$CountsInRouteDenominator) &&
    all(!routes$ExecutionSelected) &&
    all(!routes$BackendCallCurrentlyAllowed) &&
    all(!routes$FitExecuted) && all(!routes$MetricComputed) &&
    all(!estimands$CountsAsIndependentDataset) &&
    all(!estimands$CrossEstimandVotingAllowed) &&
    all(!estimands$ExecutionSelected) &&
    all(!coordinates$CountsAsIndependentDataset) &&
    all(!coordinates$CrossRouteVotingAllowed) &&
    all(!coordinates$CrossEstimandVotingAllowed) &&
    all(!coordinates$MetricAvailable) &&
    all(controls$CountsInControlDenominator) &&
    all(!controls$RngStreamRequired) && all(!controls$ExecutionSelected) &&
    all(!controls$ObservedDispositionAvailable) &&
    identical(
      controls$ControlId,
      c("NC-NAIVE-POOLING", "NC-DISCONNECTED-INCIDENCE",
        "NC-INDEFINITE-COVARIANCE")
    ) &&
    identical(plan$Summary$PlannedDatasetAttemptCount, 42L) &&
    identical(plan$Summary$PlannedRouteUnitCount, 210L) &&
    identical(plan$Summary$PlannedDatasetEstimandUnitCount, 84L) &&
    identical(plan$Summary$PlannedRouteEstimandCoordinateCount, 420L) &&
    identical(plan$Summary$QualificationCandidateRouteUnitCount, 50L) &&
    identical(plan$Summary$NegativeControlPrefitRejectRouteUnitCount, 40L) &&
    identical(plan$Summary$FrozenNotApplicableRouteUnitCount, 8L) &&
    identical(plan$Summary$BlockedUnimplementedContractRouteUnitCount, 112L) &&
    identical(plan$Summary$FeatureMaturity, "specified") &&
    isTRUE(plan$Summary$ContractFrozen) &&
    isTRUE(plan$Summary$ExecutionPlanFrozen) &&
    isTRUE(plan$Summary$PreExecutionQualificationAllowed) &&
    !isTRUE(plan$Summary$ExecutionCurrentlyAllowed) &&
    !isTRUE(plan$Summary$RngStreamOpened) &&
    !isTRUE(plan$Summary$ResponseGenerated) &&
    !isTRUE(plan$Summary$FitExecuted) &&
    !isTRUE(plan$Summary$SimulationValidationReady) &&
    !isTRUE(plan$Summary$PublicSupportReady)
  if (!valid) {
    stop("The D-SIM-3 exploratory execution plan or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3e_plan <- function(
    contract = mfrmr_gtds3e_contract(),
    manifest = mfrmr_gtds3_manifest()) {
  mfrmr_gtds3e_validate_contract(contract)
  mfrmr_gtds3_assert_manifest(manifest)
  if (!identical(manifest$ManifestHash,
                 contract$ParentCoverageManifestHash)) {
    stop("The D-SIM-3 coverage manifest identity changed.", call. = FALSE)
  }
  datasets <- mfrmr_gtds3e_dataset_plan(manifest, contract)
  routes <- mfrmr_gtds3e_route_unit_plan(datasets, manifest, contract)
  estimands <- mfrmr_gtds3e_dataset_estimand_plan(
    datasets, manifest, contract
  )
  coordinates <- mfrmr_gtds3e_route_estimand_plan(
    routes, estimands, contract
  )
  controls <- mfrmr_gtds3e_control_plan(manifest)
  implementation <- mfrmr_gtds3e_implementation_identity()
  disposition_counts <- table(routes$PlannedDisposition)
  summary <- list(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    CoverageManifestHash = manifest$ManifestHash,
    ScenarioCount = 21L,
    ReplicatesPerScenario = 2L,
    PlannedDatasetAttemptCount = nrow(datasets),
    PlannedRouteUnitCount = nrow(routes),
    PlannedDatasetEstimandUnitCount = nrow(estimands),
    PlannedRouteEstimandCoordinateCount = nrow(coordinates),
    QualificationCandidateRouteUnitCount =
      as.integer(disposition_counts[["qualification_candidate"]]),
    NegativeControlPrefitRejectRouteUnitCount =
      as.integer(disposition_counts[["negative_control_prefit_reject"]]),
    FrozenNotApplicableRouteUnitCount =
      as.integer(disposition_counts[["frozen_not_applicable"]]),
    BlockedUnimplementedContractRouteUnitCount =
      as.integer(disposition_counts[["blocked_unimplemented_contract"]]),
    ControlDefinitionCount = nrow(controls),
    MinimumPlannedSeed = min(datasets$DataSeed),
    MaximumPlannedSeed = max(datasets$DataSeed),
    ContractFrozen = TRUE,
    ExecutionPlanFrozen = TRUE,
    PreExecutionQualificationAllowed = TRUE,
    ExecutionCurrentlyAllowed = FALSE,
    RngStreamOpened = FALSE,
    ResponseGenerated = FALSE,
    FitExecuted = FALSE,
    ExploratoryResultAvailable = FALSE,
    AccuracyThresholdSelected = FALSE,
    SimulationValidationReady = FALSE,
    ReferenceValidationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE,
    FeatureMaturity = "specified",
    NextAction = paste(
      "qualify generator semantics, route adapters, terminal receipts, and",
      "resource enforcement for all 21 frozen profiles without opening the",
      "855 exploratory RNG streams"
    )
  )
  payload <- list(
    Contract = contract, CoverageManifestHash = manifest$ManifestHash,
    DatasetAttemptRegistry = datasets, RouteUnitRegistry = routes,
    DatasetEstimandRegistry = estimands,
    RouteEstimandCoordinateRegistry = coordinates,
    ControlUnitRegistry = controls,
    ImplementationIdentity = implementation, Summary = summary
  )
  plan <- structure(c(payload, list(
    PlanHash = mfrmr_gtds3e_hash(payload)
  )), class = c("mfrmr_gtds3e_plan", "list"))
  mfrmr_gtds3e_assert_plan(plan)
  plan
}
