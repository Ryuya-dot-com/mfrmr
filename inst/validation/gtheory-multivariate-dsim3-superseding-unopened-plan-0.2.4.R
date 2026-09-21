# Internal D-SIM-3 superseding unopened plan.
#
# This artifact preserves the scientific denominator of the historical 855
# plan while assigning a disjoint 856 attempt namespace and binding every
# scenario to the qualified truth projection, allocation operator, and
# separate-univariate truth coefficient identities. It never initializes an
# RNG stream, generates a response, calls a backend, or computes a fitted
# coefficient.

mfrmr_gtds3p_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds3e_contract",
    "mfrmr_gtds3e_validate_contract", "mfrmr_gtds3e_plan",
    "mfrmr_gtds3e_assert_plan", "mfrmr_gtds3t_contract",
    "mfrmr_gtds3t_manifest", "mfrmr_gtds3t_assert_manifest",
    "mfrmr_gtds3o_contract", "mfrmr_gtds3o_manifest",
    "mfrmr_gtds3o_assert_manifest", "mfrmr_gtds3m_contract",
    "mfrmr_gtds3m_manifest", "mfrmr_gtds3m_assert_manifest"
  )
  target <- environment(mfrmr_gtds3p_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the D-SIM-3 execution, truth, operator, and metric chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3p_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3p_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM3-SUPERSEDING-UNOPENED-PLAN-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-31",
    SupersededExecutionContractHash =
      "1e26cdf45218c7a28a260e519a376346d99d76a69772382ef5b0787e130f8b85",
    SupersededExecutionPlanHash =
      "b91ab4229203efc15a3ca9421256d81ae7331143e42f845b5c6a879575552de7",
    ParentTruthContractHash =
      "fb66bd15526afa1f18f613dcbc4b0d470350bcf803a642fcde537602d017f327",
    ParentTruthManifestHash =
      "97d98f649cbc49d646a7f9ac37e8292d8eb1a8ceff4f369b609108d0812189e5",
    ParentOperatorContractHash =
      "89b158391acf18c090ab708d39780499f3fbf3882ec912e04a3e8d775263693a",
    ParentOperatorManifestHash =
      "526298d0c598e34a92e98b96b7bc59c0714fc053636bc25ea423d4c87c895093",
    ParentTruthMetricContractHash =
      "d73dd72c8bc849597dd68342a3608b1f34b315e7f1fd1ad52a87a9e26d963cb8",
    ParentTruthMetricManifestHash =
      "969afca1d3fb23a68d58500cd6959152b385b0e9b2e64c25cc75a3cd79feb37c"
  )
}

mfrmr_gtds3p_seed_band_registry <- function(old_contract) {
  bands <- old_contract$SeedBandRegistry
  bands$AssignedToCurrentContract <- FALSE
  bands$BandRole[bands$BandId == "DSIM3-EXPLORATORY-855"] <-
    "superseded_unopened_attempt_namespace"
  output <- rbind(bands, data.frame(
    BandOrdinal = 6L,
    BandId = "DSIM3-SUPERSEDING-856",
    LowerInclusive = 856000000L,
    UpperInclusive = 856999999L,
    BandRole = "superseding_unopened_dsim3_exploratory",
    AssignedToCurrentContract = TRUE,
    RngStreamOpened = FALSE,
    stringsAsFactors = FALSE
  ))
  row.names(output) <- NULL
  output
}

mfrmr_gtds3p_seed_policy <- function() {
  list(
    BandId = "DSIM3-SUPERSEDING-856",
    BaseSeed = 856000000L,
    ScenarioStride = 1000L,
    ReplicatesPerScenario = 2L,
    SeedFormula = "BaseSeed+1000*ScenarioOrdinal+Replicate",
    MinimumPlannedSeed = 856001001L,
    MaximumPlannedSeed = 856021002L,
    SupersededBandId = "DSIM3-EXPLORATORY-855",
    SupersededSeedsMayBeReused = FALSE,
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

mfrmr_gtds3p_identity_policy <- function() {
  data.frame(
    RuleOrdinal = 1:8,
    RuleId = c(
      "superseded_artifact_is_immutable",
      "superseded_plan_identity_is_not_reused",
      "dataset_attempt_identity_is_not_reused",
      "route_attempt_identity_is_not_reused",
      "estimand_coordinate_identity_is_not_reused",
      "superseded_seed_is_not_reused",
      "scientific_denominator_is_preserved_one_to_one",
      "downstream_qualification_must_be_rebound"
    ),
    Required = TRUE,
    OutcomeAdaptiveRevisionAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3p_contract <- function(
    old_contract = mfrmr_gtds3e_contract()) {
  mfrmr_gtds3p_require_primitives()
  mfrmr_gtds3e_validate_contract(old_contract)
  identity <- mfrmr_gtds3p_identity()
  payload <- c(identity, list(
    ScenarioCount = 21L,
    DatasetReplicatesPerScenario = 2L,
    PlannedDatasetAttemptCount = 42L,
    PlannedRouteUnitCount = 210L,
    PlannedDatasetEstimandUnitCount = 84L,
    PlannedRouteEstimandCoordinateCount = 420L,
    PlannedControlDefinitionCount = 3L,
    SeedBandRegistry = mfrmr_gtds3p_seed_band_registry(old_contract),
    SeedPolicy = mfrmr_gtds3p_seed_policy(),
    IdentityPolicyRegistry = mfrmr_gtds3p_identity_policy(),
    InheritedDenominatorRuleRegistry = old_contract$DenominatorRuleRegistry,
    InheritedTerminalStateRegistry = old_contract$TerminalStateRegistry,
    InheritedResourceLimitRegistry = old_contract$ResourceLimitRegistry,
    InheritedRouteDispositionMap = old_contract$RouteDispositionMap,
    SupersededPlanMutationAllowed = FALSE,
    SupersededAttemptIdentityReuseAllowed = FALSE,
    SupersededSeedReuseAllowed = FALSE,
    SemanticDenominatorRevisionAllowed = FALSE,
    OutcomeAdaptiveRevisionAllowed = FALSE,
    DownstreamQualificationInheritanceAllowed = FALSE,
    ContractFrozen = TRUE,
    ExecutionPlanFreezeAllowed = TRUE,
    PartialExecutionAllowed = FALSE,
    ResponseGenerationCurrentlyAllowed = FALSE,
    RngStreamAccessCurrentlyAllowed = FALSE,
    FitExecutionCurrentlyAllowed = FALSE,
    ExploratoryExecutionCurrentlyAllowed = FALSE,
    FittedCoefficientComputed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3p_hash(payload)
  )), class = c("mfrmr_gtds3p_contract", "list"))
}

mfrmr_gtds3p_validate_contract <- function(
    contract = mfrmr_gtds3p_contract()) {
  mfrmr_gtds3p_require_primitives()
  canonical <- mfrmr_gtds3p_contract()
  bands <- contract$SeedBandRegistry
  valid <- inherits(contract, "mfrmr_gtds3p_contract") &&
    identical(contract, canonical) &&
    identical(contract$ScenarioCount, 21L) &&
    identical(contract$PlannedDatasetAttemptCount, 42L) &&
    identical(contract$PlannedRouteUnitCount, 210L) &&
    identical(contract$PlannedDatasetEstimandUnitCount, 84L) &&
    identical(contract$PlannedRouteEstimandCoordinateCount, 420L) &&
    identical(contract$PlannedControlDefinitionCount, 3L) &&
    identical(nrow(bands), 6L) &&
    all(bands$UpperInclusive[-nrow(bands)] < bands$LowerInclusive[-1L]) &&
    identical(sum(bands$AssignedToCurrentContract), 1L) &&
    identical(
      bands$BandId[bands$AssignedToCurrentContract],
      contract$SeedPolicy$BandId
    ) &&
    all(!bands$RngStreamOpened) &&
    identical(nrow(contract$IdentityPolicyRegistry), 8L) &&
    all(contract$IdentityPolicyRegistry$Required) &&
    all(!contract$IdentityPolicyRegistry$OutcomeAdaptiveRevisionAllowed) &&
    identical(nrow(contract$InheritedDenominatorRuleRegistry), 14L) &&
    identical(nrow(contract$InheritedTerminalStateRegistry), 13L) &&
    identical(nrow(contract$InheritedResourceLimitRegistry), 5L) &&
    !isTRUE(contract$SupersededPlanMutationAllowed) &&
    !isTRUE(contract$SupersededAttemptIdentityReuseAllowed) &&
    !isTRUE(contract$SupersededSeedReuseAllowed) &&
    !isTRUE(contract$SemanticDenominatorRevisionAllowed) &&
    !isTRUE(contract$OutcomeAdaptiveRevisionAllowed) &&
    !isTRUE(contract$DownstreamQualificationInheritanceAllowed) &&
    isTRUE(contract$ContractFrozen) &&
    !isTRUE(contract$PartialExecutionAllowed) &&
    !isTRUE(contract$ResponseGenerationCurrentlyAllowed) &&
    !isTRUE(contract$RngStreamAccessCurrentlyAllowed) &&
    !isTRUE(contract$FitExecutionCurrentlyAllowed) &&
    !isTRUE(contract$ExploratoryExecutionCurrentlyAllowed) &&
    !isTRUE(contract$FittedCoefficientComputed) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The D-SIM-3 superseding plan contract is invalid or altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3p_seed_for <- function(scenario_ordinal, replicate, policy) {
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

mfrmr_gtds3p_profile_binding_registry <- function(
    truth_manifest, operator_manifest, metric_manifest) {
  truth <- truth_manifest$ProfileTruthRegistry
  operator <- operator_manifest$ProfileOperatorRegistry
  metric <- metric_manifest$ProfileTruthMetricRegistry
  scenario_ids <- truth$ScenarioId
  operator_index <- match(scenario_ids, operator$ScenarioId)
  metric_index <- match(scenario_ids, metric$ScenarioId)
  output <- data.frame(
    ProfileBindingOrdinal = seq_along(scenario_ids),
    ScenarioId = scenario_ids,
    TruthProjectionHash = truth$ProjectionHash,
    ProfileOperatorHash = operator$ProfileOperatorHash[operator_index],
    ProfileTruthCoefficientHash =
      metric$ProfileTruthCoefficientHash[metric_index],
    TruthProjectionQualified = truth$TruthRolesIdentifiable,
    AllocationOperatorQualified =
      operator$SeparateUnivariateOperatorQualified[operator_index],
    TruthMetricQualified = metric$TruthCoefficientReady[metric_index],
    ResponseInspected = FALSE,
    stringsAsFactors = FALSE
  )
  output$QualifiedReferenceBundleHash <- vapply(
    seq_len(nrow(output)), function(index) {
      mfrmr_gtds3p_hash(list(
        ScenarioId = output$ScenarioId[[index]],
        TruthProjectionHash = output$TruthProjectionHash[[index]],
        ProfileOperatorHash = output$ProfileOperatorHash[[index]],
        ProfileTruthCoefficientHash =
          output$ProfileTruthCoefficientHash[[index]]
      ))
    }, character(1L)
  )
  output
}

mfrmr_gtds3p_dataset_plan <- function(
    old_plan, bindings, contract) {
  old <- old_plan$DatasetAttemptRegistry
  binding_index <- match(old$ScenarioId, bindings$ScenarioId)
  seeds <- vapply(seq_len(nrow(old)), function(index) {
    mfrmr_gtds3p_seed_for(
      old$ScenarioOrdinal[[index]], old$Replicate[[index]],
      contract$SeedPolicy
    )
  }, integer(1L))
  output <- data.frame(
    DatasetOrdinal = old$DatasetOrdinal,
    DatasetId = vapply(seq_len(nrow(old)), function(index) {
      paste0("D3P-D", sprintf("%03d", index), "-", substr(
        mfrmr_gtds3p_hash(list(
          ContractHash = contract$ContractHash,
          ScenarioHash = old$ScenarioHash[[index]],
          Replicate = old$Replicate[[index]],
          DataSeed = seeds[[index]],
          QualifiedReferenceBundleHash =
            bindings$QualifiedReferenceBundleHash[[binding_index[[index]]]]
        )), 1L, 16L
      ))
    }, character(1L)),
    ScenarioOrdinal = old$ScenarioOrdinal,
    ScenarioId = old$ScenarioId,
    ScenarioHash = old$ScenarioHash,
    Replicate = old$Replicate,
    DataSeed = seeds,
    SeedBandId = contract$SeedPolicy$BandId,
    TruthProjectionHash = bindings$TruthProjectionHash[binding_index],
    ProfileOperatorHash = bindings$ProfileOperatorHash[binding_index],
    ProfileTruthCoefficientHash =
      bindings$ProfileTruthCoefficientHash[binding_index],
    QualifiedReferenceBundleHash =
      bindings$QualifiedReferenceBundleHash[binding_index],
    PlannedDatasetAttempt = TRUE,
    ResponseGenerated = FALSE,
    RngStreamOpened = FALSE,
    ExecutionSelected = FALSE,
    TerminalReceiptAvailable = FALSE,
    stringsAsFactors = FALSE
  )
  output
}

mfrmr_gtds3p_route_plan <- function(old_plan, datasets, contract) {
  old <- old_plan$RouteUnitRegistry
  output <- old
  output$DatasetId <- datasets$DatasetId[old$DatasetOrdinal]
  output$RouteUnitId <- vapply(seq_len(nrow(old)), function(index) {
    paste0("D3P-U", sprintf("%03d", index), "-", substr(
      mfrmr_gtds3p_hash(list(
        ContractHash = contract$ContractHash,
        DatasetId = output$DatasetId[[index]],
        RouteId = old$RouteId[[index]],
        QualificationStatus = old$QualificationStatus[[index]]
      )), 1L, 16L
    ))
  }, character(1L))
  binding_index <- match(output$DatasetOrdinal, datasets$DatasetOrdinal)
  output$QualifiedReferenceBundleHash <-
    datasets$QualifiedReferenceBundleHash[binding_index]
  output$TruthMetricBindingRole <- ifelse(
    output$RouteId == "separate_univariate",
    "direct_route_metric_contract",
    "scenario_reference_not_route_qualified"
  )
  output$TruthMetricDirectlyApplicable <-
    output$RouteId == "separate_univariate"
  output$DownstreamQualificationInherited <- FALSE
  output$ExecutionSelected <- FALSE
  output$BackendCallCurrentlyAllowed <- FALSE
  output$FitExecuted <- FALSE
  output$MetricComputed <- FALSE
  output
}

mfrmr_gtds3p_dataset_estimand_plan <- function(
    old_plan, datasets, contract) {
  old <- old_plan$DatasetEstimandRegistry
  output <- old
  output$DatasetId <- datasets$DatasetId[old$DatasetOrdinal]
  output$DatasetEstimandUnitId <- vapply(seq_len(nrow(old)), function(index) {
    paste0("D3P-E", sprintf("%03d", index), "-", substr(
      mfrmr_gtds3p_hash(list(
        ContractHash = contract$ContractHash,
        DatasetId = output$DatasetId[[index]],
        EstimandId = old$EstimandId[[index]]
      )), 1L, 16L
    ))
  }, character(1L))
  output$ProfileTruthCoefficientHash <-
    datasets$ProfileTruthCoefficientHash[old$DatasetOrdinal]
  output$ExecutionSelected <- FALSE
  output
}

mfrmr_gtds3p_coordinate_plan <- function(
    old_plan, datasets, routes, contract) {
  old <- old_plan$RouteEstimandCoordinateRegistry
  output <- old
  output$DatasetId <- datasets$DatasetId[old$DatasetOrdinal]
  output$RouteUnitId <- routes$RouteUnitId[old$RouteUnitOrdinal]
  output$CoordinateId <- vapply(seq_len(nrow(old)), function(index) {
    paste0("D3P-C", sprintf("%03d", index), "-", substr(
      mfrmr_gtds3p_hash(list(
        ContractHash = contract$ContractHash,
        RouteUnitId = output$RouteUnitId[[index]],
        EstimandId = old$EstimandId[[index]]
      )), 1L, 16L
    ))
  }, character(1L))
  output$ProfileTruthCoefficientHash <-
    datasets$ProfileTruthCoefficientHash[old$DatasetOrdinal]
  output$DirectTruthMetricBindingRequired <-
    routes$TruthMetricDirectlyApplicable[old$RouteUnitOrdinal]
  output$DownstreamQualificationInherited <- FALSE
  output$MetricAvailable <- FALSE
  output
}

mfrmr_gtds3p_control_plan <- function(old_plan, contract) {
  old <- old_plan$ControlUnitRegistry
  output <- old
  output$ReferenceControlId <- old$ControlId
  output$ControlUnitId <- vapply(seq_len(nrow(old)), function(index) {
    paste0("D3P-N", sprintf("%02d", index), "-", substr(
      mfrmr_gtds3p_hash(list(
        ContractHash = contract$ContractHash,
        ReferenceControlId = old$ControlId[[index]],
        ExpectedDisposition = old$ExpectedDisposition[[index]]
      )), 1L, 16L
    ))
  }, character(1L))
  output$ExecutionSelected <- FALSE
  output$ObservedDispositionAvailable <- FALSE
  output
}

mfrmr_gtds3p_supersession_registry <- function(
    old_plan, datasets, routes, estimands, coordinates, controls) {
  old_datasets <- old_plan$DatasetAttemptRegistry
  old_routes <- old_plan$RouteUnitRegistry
  old_estimands <- old_plan$DatasetEstimandRegistry
  old_coordinates <- old_plan$RouteEstimandCoordinateRegistry
  old_controls <- old_plan$ControlUnitRegistry
  list(
    DatasetAttempt = data.frame(
      DatasetOrdinal = datasets$DatasetOrdinal,
      ScenarioId = datasets$ScenarioId,
      Replicate = datasets$Replicate,
      SupersededDatasetId = old_datasets$DatasetId,
      SupersedingDatasetId = datasets$DatasetId,
      SupersededDataSeed = old_datasets$DataSeed,
      SupersedingDataSeed = datasets$DataSeed,
      ScientificUnitPreserved = TRUE,
      AttemptIdentityReused = FALSE,
      SeedReused = FALSE,
      stringsAsFactors = FALSE
    ),
    RouteUnit = data.frame(
      RouteUnitOrdinal = routes$RouteUnitOrdinal,
      ScenarioId = routes$ScenarioId,
      Replicate = routes$Replicate,
      RouteId = routes$RouteId,
      PlannedDisposition = routes$PlannedDisposition,
      SupersededRouteUnitId = old_routes$RouteUnitId,
      SupersedingRouteUnitId = routes$RouteUnitId,
      SupersededDatasetId = old_routes$DatasetId,
      SupersedingDatasetId = routes$DatasetId,
      ScientificUnitPreserved = TRUE,
      AttemptIdentityReused = FALSE,
      stringsAsFactors = FALSE
    ),
    DatasetEstimand = data.frame(
      DatasetEstimandUnitOrdinal = estimands$DatasetEstimandUnitOrdinal,
      ScenarioId = estimands$ScenarioId,
      Replicate = estimands$Replicate,
      EstimandId = estimands$EstimandId,
      SupersededDatasetEstimandUnitId =
        old_estimands$DatasetEstimandUnitId,
      SupersedingDatasetEstimandUnitId = estimands$DatasetEstimandUnitId,
      ScientificUnitPreserved = TRUE,
      AttemptIdentityReused = FALSE,
      stringsAsFactors = FALSE
    ),
    RouteEstimandCoordinate = data.frame(
      CoordinateOrdinal = coordinates$CoordinateOrdinal,
      ScenarioId = coordinates$ScenarioId,
      Replicate = coordinates$Replicate,
      RouteId = coordinates$RouteId,
      EstimandId = coordinates$EstimandId,
      SupersededCoordinateId = old_coordinates$CoordinateId,
      SupersedingCoordinateId = coordinates$CoordinateId,
      ScientificUnitPreserved = TRUE,
      AttemptIdentityReused = FALSE,
      stringsAsFactors = FALSE
    ),
    ControlDefinition = data.frame(
      ControlUnitOrdinal = controls$ControlUnitOrdinal,
      ReferenceControlId = old_controls$ControlId,
      SupersedingControlUnitId = controls$ControlUnitId,
      ScientificDefinitionPreserved = TRUE,
      PlanUnitIdentityReused = FALSE,
      stringsAsFactors = FALSE
    )
  )
}

mfrmr_gtds3p_downstream_rebinding_registry <- function() {
  data.frame(
    RebindingOrdinal = 1:6,
    InterfaceId = c(
      "generation_request", "route_admission_request",
      "fit_metric_worker", "terminal_receipt_orchestration",
      "resource_controller_request", "launch_readiness_reconciliation"
    ),
    HistoricalQualificationMayBeInherited = FALSE,
    QualifiedForSupersedingIdentity = FALSE,
    ExecutionCurrentlyAllowed = FALSE,
    RequiredBeforeExploratoryLaunch = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3p_gate_registry <- function() {
  data.frame(
    GateOrdinal = 1:10,
    GateId = c(
      "superseded_plan_exact_replay",
      "superseded_artifact_immutable",
      "qualified_truth_projection_bound",
      "qualified_allocation_operator_bound",
      "qualified_truth_metric_bound",
      "scientific_denominator_one_to_one",
      "attempt_and_seed_identities_disjoint",
      "outcome_blind_unopened_freeze",
      "terminal_resource_semantics_preserved",
      "shared_execution_bridge_rebound"
    ),
    Required = TRUE,
    Passed = c(rep(TRUE, 9L), FALSE),
    Blocking = c(rep(FALSE, 9L), TRUE),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3p_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds3p_require_primitives", "mfrmr_gtds3p_hash",
    "mfrmr_gtds3p_identity", "mfrmr_gtds3p_seed_band_registry",
    "mfrmr_gtds3p_seed_policy", "mfrmr_gtds3p_identity_policy",
    "mfrmr_gtds3p_contract", "mfrmr_gtds3p_validate_contract",
    "mfrmr_gtds3p_seed_for", "mfrmr_gtds3p_profile_binding_registry",
    "mfrmr_gtds3p_dataset_plan", "mfrmr_gtds3p_route_plan",
    "mfrmr_gtds3p_dataset_estimand_plan",
    "mfrmr_gtds3p_coordinate_plan", "mfrmr_gtds3p_control_plan",
    "mfrmr_gtds3p_supersession_registry",
    "mfrmr_gtds3p_downstream_rebinding_registry",
    "mfrmr_gtds3p_gate_registry", "mfrmr_gtds3p_implementation_identity",
    "mfrmr_gtds3p_payload_fields", "mfrmr_gtds3p_assert_plan",
    "mfrmr_gtds3p_plan"
  )
  target <- environment(mfrmr_gtds3p_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions),
    FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds3p_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3p_payload_fields <- function() {
  c(
    "Contract", "SupersededExecutionPlanHash",
    "ParentTruthManifestHash", "ParentOperatorManifestHash",
    "ParentTruthMetricManifestHash", "ProfileBindingRegistry",
    "DatasetAttemptRegistry", "RouteUnitRegistry",
    "DatasetEstimandRegistry", "RouteEstimandCoordinateRegistry",
    "ControlUnitRegistry", "SupersessionRegistry",
    "DownstreamRebindingRegistry", "ReadinessGateRegistry",
    "ImplementationIdentity", "Summary"
  )
}

mfrmr_gtds3p_assert_plan <- function(plan) {
  fields <- mfrmr_gtds3p_payload_fields()
  if (!inherits(plan, "mfrmr_gtds3p_plan") ||
      !identical(names(plan), c(fields, "PlanHash"))) {
    stop("A typed D-SIM-3 superseding unopened plan is required.",
         call. = FALSE)
  }
  mfrmr_gtds3p_validate_contract(plan$Contract)
  datasets <- plan$DatasetAttemptRegistry
  routes <- plan$RouteUnitRegistry
  estimands <- plan$DatasetEstimandRegistry
  coordinates <- plan$RouteEstimandCoordinateRegistry
  controls <- plan$ControlUnitRegistry
  maps <- plan$SupersessionRegistry
  gates <- plan$ReadinessGateRegistry
  rebinding <- plan$DownstreamRebindingRegistry
  old_plan <- mfrmr_gtds3e_plan()
  old_datasets <- old_plan$DatasetAttemptRegistry
  old_routes <- old_plan$RouteUnitRegistry
  old_estimands <- old_plan$DatasetEstimandRegistry
  old_coordinates <- old_plan$RouteEstimandCoordinateRegistry
  old_controls <- old_plan$ControlUnitRegistry
  expected_seeds <- vapply(seq_len(nrow(datasets)), function(index) {
    mfrmr_gtds3p_seed_for(
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
  valid <- identical(plan$PlanHash, mfrmr_gtds3p_hash(plan[fields])) &&
    identical(
      plan$ImplementationIdentity, mfrmr_gtds3p_implementation_identity()
    ) &&
    identical(plan$SupersededExecutionPlanHash,
              plan$Contract$SupersededExecutionPlanHash) &&
    identical(old_plan$PlanHash, plan$SupersededExecutionPlanHash) &&
    identical(plan$ParentTruthManifestHash,
              plan$Contract$ParentTruthManifestHash) &&
    identical(plan$ParentOperatorManifestHash,
              plan$Contract$ParentOperatorManifestHash) &&
    identical(plan$ParentTruthMetricManifestHash,
              plan$Contract$ParentTruthMetricManifestHash) &&
    identical(nrow(plan$ProfileBindingRegistry), 21L) &&
    all(plan$ProfileBindingRegistry$TruthProjectionQualified) &&
    all(plan$ProfileBindingRegistry$AllocationOperatorQualified) &&
    all(plan$ProfileBindingRegistry$TruthMetricQualified) &&
    all(!plan$ProfileBindingRegistry$ResponseInspected) &&
    identical(nrow(datasets), 42L) && identical(nrow(routes), 210L) &&
    identical(nrow(estimands), 84L) &&
    identical(nrow(coordinates), 420L) &&
    identical(nrow(controls), 3L) &&
    identical(unname(vapply(maps, nrow, integer(1L))),
              c(42L, 210L, 84L, 420L, 3L)) &&
    !anyDuplicated(datasets$DatasetId) &&
    !anyDuplicated(routes$RouteUnitId) &&
    !anyDuplicated(estimands$DatasetEstimandUnitId) &&
    !anyDuplicated(coordinates$CoordinateId) &&
    !anyDuplicated(controls$ControlUnitId) &&
    identical(datasets$DataSeed, expected_seeds) &&
    !anyDuplicated(datasets$DataSeed) &&
    all(datasets$DataSeed >= 856000000L & datasets$DataSeed <= 856999999L) &&
    identical(range(datasets$DataSeed), c(856001001L, 856021002L)) &&
    all(table(datasets$ScenarioId) == 2L) &&
    all(table(routes$DatasetId) == 5L) &&
    all(table(estimands$DatasetId) == 2L) &&
    all(table(coordinates$RouteUnitId) == 2L) &&
    identical(as.integer(disposition_counts), c(50L, 40L, 8L, 112L)) &&
    identical(
      datasets[c("ScenarioOrdinal", "ScenarioId", "ScenarioHash",
                 "Replicate")],
      old_datasets[c("ScenarioOrdinal", "ScenarioId", "ScenarioHash",
                     "Replicate")]
    ) &&
    identical(
      routes[c(
        "DatasetOrdinal", "ScenarioOrdinal", "ScenarioId", "Replicate",
        "RouteOrdinal", "RouteId", "CoverageRole", "QualificationStatus",
        "PlannedDisposition", "PreExecutionQualificationRequired",
        "BackendCallAllowedAfterQualification", "FrozenNoCallTerminalState",
        "CountsInRouteDenominator"
      )],
      old_routes[c(
        "DatasetOrdinal", "ScenarioOrdinal", "ScenarioId", "Replicate",
        "RouteOrdinal", "RouteId", "CoverageRole", "QualificationStatus",
        "PlannedDisposition", "PreExecutionQualificationRequired",
        "BackendCallAllowedAfterQualification", "FrozenNoCallTerminalState",
        "CountsInRouteDenominator"
      )]
    ) &&
    identical(
      estimands[c(
        "DatasetOrdinal", "ScenarioId", "Replicate", "EstimandId",
        "CountsAsIndependentDataset", "CrossEstimandVotingAllowed"
      )],
      old_estimands[c(
        "DatasetOrdinal", "ScenarioId", "Replicate", "EstimandId",
        "CountsAsIndependentDataset", "CrossEstimandVotingAllowed"
      )]
    ) &&
    identical(
      coordinates[c(
        "RouteUnitOrdinal", "DatasetOrdinal", "ScenarioId", "Replicate",
        "RouteId", "EstimandId", "CountsAsIndependentDataset",
        "CrossRouteVotingAllowed", "CrossEstimandVotingAllowed"
      )],
      old_coordinates[c(
        "RouteUnitOrdinal", "DatasetOrdinal", "ScenarioId", "Replicate",
        "RouteId", "EstimandId", "CountsAsIndependentDataset",
        "CrossRouteVotingAllowed", "CrossEstimandVotingAllowed"
      )]
    ) &&
    identical(
      controls[c(
        "ControlUnitOrdinal", "ControlId", "ControlType", "ScenarioId",
        "ReferenceDesignId", "ExpectedDisposition",
        "CountsInControlDenominator", "RngStreamRequired"
      )],
      old_controls[c(
        "ControlUnitOrdinal", "ControlId", "ControlType", "ScenarioId",
        "ReferenceDesignId", "ExpectedDisposition",
        "CountsInControlDenominator", "RngStreamRequired"
      )]
    ) &&
    identical(sum(routes$TruthMetricDirectlyApplicable), 42L) &&
    all(!datasets$ResponseGenerated) && all(!datasets$RngStreamOpened) &&
    all(!datasets$ExecutionSelected) &&
    all(!datasets$TerminalReceiptAvailable) &&
    all(routes$CountsInRouteDenominator) &&
    all(!routes$DownstreamQualificationInherited) &&
    all(!routes$ExecutionSelected) &&
    all(!routes$BackendCallCurrentlyAllowed) &&
    all(!routes$FitExecuted) && all(!routes$MetricComputed) &&
    all(!estimands$ExecutionSelected) &&
    all(!coordinates$DownstreamQualificationInherited) &&
    all(!coordinates$MetricAvailable) &&
    all(!controls$ExecutionSelected) &&
    all(!controls$ObservedDispositionAvailable) &&
    all(maps$DatasetAttempt$ScientificUnitPreserved) &&
    identical(maps$DatasetAttempt$SupersededDatasetId,
              old_datasets$DatasetId) &&
    identical(maps$DatasetAttempt$SupersedingDatasetId,
              datasets$DatasetId) &&
    identical(maps$DatasetAttempt$SupersededDataSeed,
              old_datasets$DataSeed) &&
    identical(maps$DatasetAttempt$SupersedingDataSeed,
              datasets$DataSeed) &&
    all(!maps$DatasetAttempt$AttemptIdentityReused) &&
    all(!maps$DatasetAttempt$SeedReused) &&
    length(intersect(
      maps$DatasetAttempt$SupersededDatasetId,
      maps$DatasetAttempt$SupersedingDatasetId
    )) == 0L &&
    length(intersect(
      maps$DatasetAttempt$SupersededDataSeed,
      maps$DatasetAttempt$SupersedingDataSeed
    )) == 0L &&
    all(maps$RouteUnit$ScientificUnitPreserved) &&
    identical(maps$RouteUnit$SupersededRouteUnitId,
              old_routes$RouteUnitId) &&
    identical(maps$RouteUnit$SupersedingRouteUnitId,
              routes$RouteUnitId) &&
    all(!maps$RouteUnit$AttemptIdentityReused) &&
    all(maps$DatasetEstimand$ScientificUnitPreserved) &&
    identical(maps$DatasetEstimand$SupersededDatasetEstimandUnitId,
              old_estimands$DatasetEstimandUnitId) &&
    identical(maps$DatasetEstimand$SupersedingDatasetEstimandUnitId,
              estimands$DatasetEstimandUnitId) &&
    all(!maps$DatasetEstimand$AttemptIdentityReused) &&
    all(maps$RouteEstimandCoordinate$ScientificUnitPreserved) &&
    identical(maps$RouteEstimandCoordinate$SupersededCoordinateId,
              old_coordinates$CoordinateId) &&
    identical(maps$RouteEstimandCoordinate$SupersedingCoordinateId,
              coordinates$CoordinateId) &&
    all(!maps$RouteEstimandCoordinate$AttemptIdentityReused) &&
    all(maps$ControlDefinition$ScientificDefinitionPreserved) &&
    identical(maps$ControlDefinition$ReferenceControlId,
              old_controls$ControlId) &&
    identical(maps$ControlDefinition$SupersedingControlUnitId,
              controls$ControlUnitId) &&
    all(!maps$ControlDefinition$PlanUnitIdentityReused) &&
    identical(nrow(rebinding), 6L) &&
    all(!rebinding$HistoricalQualificationMayBeInherited) &&
    all(!rebinding$QualifiedForSupersedingIdentity) &&
    all(!rebinding$ExecutionCurrentlyAllowed) &&
    all(rebinding$RequiredBeforeExploratoryLaunch) &&
    identical(nrow(gates), 10L) && identical(sum(gates$Passed), 9L) &&
    identical(sum(gates$Blocking), 1L) &&
    identical(gates$GateId[gates$Blocking],
              "shared_execution_bridge_rebound") &&
    identical(plan$Summary$PassingReadinessGateCount, 9L) &&
    identical(plan$Summary$BlockingReadinessGateCount, 1L) &&
    identical(
      plan$Summary$CurrentDisposition,
      "superseding_unopened_plan_frozen_execution_bridge_required"
    ) &&
    isTRUE(plan$Summary$ScientificDenominatorPreserved) &&
    isTRUE(plan$Summary$AttemptIdentityDisjoint) &&
    !isTRUE(plan$Summary$RngStreamOpened) &&
    !isTRUE(plan$Summary$ResponseGenerated) &&
    !isTRUE(plan$Summary$BackendCallMade) &&
    !isTRUE(plan$Summary$FitExecuted) &&
    !isTRUE(plan$Summary$FittedCoefficientComputed) &&
    !isTRUE(plan$Summary$ExploratoryExecutionAllowed) &&
    !isTRUE(plan$Summary$SimulationValidationReady) &&
    !isTRUE(plan$Summary$PublicSupportReady)
  if (!valid) {
    stop("The D-SIM-3 superseding unopened plan or boundary was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3p_plan <- function(
    contract = mfrmr_gtds3p_contract(),
    old_plan = mfrmr_gtds3e_plan(),
    truth_manifest = mfrmr_gtds3t_manifest(),
    operator_manifest = mfrmr_gtds3o_manifest(
      truth_manifest = truth_manifest
    ),
    metric_manifest = mfrmr_gtds3m_manifest(
      truth_manifest = truth_manifest,
      operator_manifest = operator_manifest
    )) {
  mfrmr_gtds3p_validate_contract(contract)
  mfrmr_gtds3e_assert_plan(old_plan)
  mfrmr_gtds3t_assert_manifest(truth_manifest)
  mfrmr_gtds3o_assert_manifest(operator_manifest)
  mfrmr_gtds3m_assert_manifest(metric_manifest)
  if (!identical(old_plan$PlanHash,
                 contract$SupersededExecutionPlanHash) ||
      !identical(truth_manifest$ManifestHash,
                 contract$ParentTruthManifestHash) ||
      !identical(operator_manifest$ManifestHash,
                 contract$ParentOperatorManifestHash) ||
      !identical(metric_manifest$ManifestHash,
                 contract$ParentTruthMetricManifestHash)) {
    stop("A superseded or semantic parent identity changed.", call. = FALSE)
  }
  bindings <- mfrmr_gtds3p_profile_binding_registry(
    truth_manifest, operator_manifest, metric_manifest
  )
  datasets <- mfrmr_gtds3p_dataset_plan(old_plan, bindings, contract)
  routes <- mfrmr_gtds3p_route_plan(old_plan, datasets, contract)
  estimands <- mfrmr_gtds3p_dataset_estimand_plan(
    old_plan, datasets, contract
  )
  coordinates <- mfrmr_gtds3p_coordinate_plan(
    old_plan, datasets, routes, contract
  )
  controls <- mfrmr_gtds3p_control_plan(old_plan, contract)
  supersession <- mfrmr_gtds3p_supersession_registry(
    old_plan, datasets, routes, estimands, coordinates, controls
  )
  rebinding <- mfrmr_gtds3p_downstream_rebinding_registry()
  gates <- mfrmr_gtds3p_gate_registry()
  implementation <- mfrmr_gtds3p_implementation_identity()
  summary <- list(
    ScenarioCount = 21L,
    PlannedDatasetAttemptCount = nrow(datasets),
    PlannedRouteUnitCount = nrow(routes),
    PlannedDatasetEstimandUnitCount = nrow(estimands),
    PlannedRouteEstimandCoordinateCount = nrow(coordinates),
    PlannedControlDefinitionCount = nrow(controls),
    BoundTruthProfileCount = nrow(bindings),
    DirectSeparateUnivariateRouteMetricBindingCount =
      sum(routes$TruthMetricDirectlyApplicable),
    MinimumPlannedSeed = min(datasets$DataSeed),
    MaximumPlannedSeed = max(datasets$DataSeed),
    ScientificDenominatorPreserved = TRUE,
    AttemptIdentityDisjoint = TRUE,
    SeedIdentityDisjoint = TRUE,
    SupersededPlanMutated = FALSE,
    DownstreamQualificationInherited = FALSE,
    ReadinessGateCount = nrow(gates),
    PassingReadinessGateCount = sum(gates$Passed),
    BlockingReadinessGateCount = sum(gates$Blocking),
    CurrentDisposition =
      "superseding_unopened_plan_frozen_execution_bridge_required",
    FeatureMaturity = "specified",
    RngStreamOpened = FALSE,
    ResponseGenerated = FALSE,
    BackendCallMade = FALSE,
    FitExecuted = FALSE,
    TruthCoefficientComputed = TRUE,
    FittedCoefficientComputed = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE,
    NextAction = paste(
      "build and shadow-qualify one identity-bound generation fit metric",
      "terminal and resource execution bridge for the superseding plan",
      "then rerun nonexecuting launch-readiness reconciliation"
    )
  )
  payload <- list(
    Contract = contract,
    SupersededExecutionPlanHash = old_plan$PlanHash,
    ParentTruthManifestHash = truth_manifest$ManifestHash,
    ParentOperatorManifestHash = operator_manifest$ManifestHash,
    ParentTruthMetricManifestHash = metric_manifest$ManifestHash,
    ProfileBindingRegistry = bindings,
    DatasetAttemptRegistry = datasets,
    RouteUnitRegistry = routes,
    DatasetEstimandRegistry = estimands,
    RouteEstimandCoordinateRegistry = coordinates,
    ControlUnitRegistry = controls,
    SupersessionRegistry = supersession,
    DownstreamRebindingRegistry = rebinding,
    ReadinessGateRegistry = gates,
    ImplementationIdentity = implementation,
    Summary = summary
  )
  plan <- structure(c(payload, list(
    PlanHash = mfrmr_gtds3p_hash(payload)
  )), class = c("mfrmr_gtds3p_plan", "list"))
  mfrmr_gtds3p_assert_plan(plan)
  plan
}
