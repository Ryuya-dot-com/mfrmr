# Internal D-SIM-3 pre-execution qualification audit.
#
# This file compares the frozen 21-cell execution plan with existing generator,
# route, terminal-receipt, and resource-enforcement capabilities. It performs
# no RNG initialization, response generation, backend call, or fit.

mfrmr_gtds3q_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds_v4_contract",
    "mfrmr_gtds3_dataset_axis_registry", "mfrmr_gtds3_manifest",
    "mfrmr_gtds3_assert_manifest", "mfrmr_gtds3e_contract",
    "mfrmr_gtds3e_validate_contract", "mfrmr_gtds3e_plan",
    "mfrmr_gtds3e_assert_plan"
  )
  target <- environment(mfrmr_gtds3q_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the v4 and D-SIM-3 coverage/execution contracts first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3q_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3q_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM3-PREEXEC-QUALIFICATION-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-30",
    ParentExecutionContractId =
      "MFRMR-GTHEORY-MV-DSIM3-EXPLORATORY-EXECUTION-V1",
    ParentExecutionContractHash =
      "1e26cdf45218c7a28a260e519a376346d99d76a69772382ef5b0787e130f8b85",
    ParentExecutionPlanHash =
      "b91ab4229203efc15a3ca9421256d81ae7331143e42f845b5c6a879575552de7",
    ParentExecutionRecord = paste0(
      "gtheory-multivariate-dsim3-exploratory-execution-contract-record-",
      "0.2.4.md"
    )
  )
}

mfrmr_gtds3q_asset_registry <- function() {
  data.frame(
    AssetOrdinal = 1:5,
    AssetId = c(
      "GT-GEN-C2", "GT-FIT-C4P", "GT-UNIV-D1", "GT-TERM-D2",
      "GT-RESOURCE-NONE"
    ),
    SourceArtifact = c(
      "gtheory-multivariate-generator-preflight-0.2.4.R",
      "gtheory-multivariate-fit-candidate-execution-0.2.4.R",
      "gtheory-multivariate-dsim1-deterministic-qualification-0.2.4.R",
      "gtheory-multivariate-dsim2-plumbing-smoke-0.2.4.R",
      "no_enforceable_dsim3_resource_adapter"
    ),
    EvidenceRole = c(
      "legacy_gaussian_fixture_generator_primitives",
      "one_exact_two_stratum_gaussian_fit_layout",
      "deterministic_univariate_algebra_not_dataset_fit_adapter",
      "one_route_generator_fit_metric_terminal_algebra",
      "explicit_absence_of_current_enforcement"
    ),
    ExistingEvidenceAvailable = c(TRUE, TRUE, TRUE, TRUE, FALSE),
    ExactDsim3BindingAvailable = FALSE,
    ExecutionAuthorityConferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3q_primitive_support_map <- function() {
  list(
    stratum_count = c("two", "three"),
    condition_sharing = "identical",
    observation_event = "distinct",
    crossing = c("fully_crossed", "partially_crossed"),
    balance = c("balanced", "moderately_unbalanced"),
    missingness = "none",
    object_count = character(),
    rater_count = character(),
    repeat_count = c("1", "2"),
    variance_regime = c(
      "regular_interior", "near_zero_component",
      "near_singular_covariance"
    ),
    cross_stratum_covariance = c(
      "zero", "positive_psd", "negative_psd"
    ),
    response_distribution = "gaussian"
  )
}

mfrmr_gtds3q_level_block_reason <- function(axis_id, level_id, available) {
  if (isTRUE(available)) {
    return("legacy_primitive_available_but_no_exact_dsim3_profile_binding")
  }
  reasons <- c(
    stratum_count = "one_stratum_stochastic_generator_absent",
    condition_sharing = "typed_disjoint_or_partial_condition_compiler_absent",
    observation_event = "linked_or_mixed_observation_event_generator_absent",
    crossing = "nested_or_severe_crossing_semantics_not_compiled",
    balance = "severe_imbalance_semantics_not_bound",
    missingness = "mcar_and_structural_response_missingness_layer_absent",
    object_count = "legacy_generator_hardcodes_30_objects",
    rater_count = "legacy_generator_hardcodes_6_raters",
    repeat_count = "declared_repeat_level_not_supported",
    variance_regime = "declared_variance_regime_factor_contract_absent",
    cross_stratum_covariance = "declared_cross_stratum_factor_contract_absent",
    response_distribution = "heavy_tail_and_ordinal_distribution_layer_absent"
  )
  reason <- unname(reasons[[axis_id]])
  if (is.null(reason) || is.na(reason)) {
    reason <- "no_qualified_generator_primitive"
  }
  paste(reason, level_id, sep = ":")
}

mfrmr_gtds3q_level_qualification <- function() {
  mfrmr_gtds3q_require_primitives()
  v4 <- mfrmr_gtds_v4_contract()
  axes <- mfrmr_gtds3_dataset_axis_registry(v4)
  support <- mfrmr_gtds3q_primitive_support_map()
  available <- vapply(seq_len(nrow(axes)), function(index) {
    axes$LevelId[[index]] %in% support[[axes$AxisId[[index]]]]
  }, logical(1L))
  asset <- ifelse(
    axes$AxisId %in% c(
      "variance_regime", "cross_stratum_covariance",
      "response_distribution"
    ), "GT-GEN-C2", "GT-GEN-C2"
  )
  data.frame(
    LevelQualificationOrdinal = seq_len(nrow(axes)),
    AxisId = axes$AxisId, LevelId = axes$LevelId,
    CoverageRole = axes$CoverageRole,
    EvidenceAssetId = asset,
    LegacyPrimitiveAvailable = available,
    ExactDsim3AxisLevelBindingReady = FALSE,
    FullProfileCompilerRequired = TRUE,
    BlockingReason = vapply(seq_len(nrow(axes)), function(index) {
      mfrmr_gtds3q_level_block_reason(
        axes$AxisId[[index]], axes$LevelId[[index]], available[[index]]
      )
    }, character(1L)),
    RngStreamOpened = FALSE, ResponseGenerated = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3q_profile_qualification <- function(
    coverage, level_qualification) {
  scenarios <- coverage$ScenarioRegistry
  axis_ids <- coverage$Contract$DatasetAxisIds
  rows <- lapply(seq_len(nrow(scenarios)), function(index) {
    profile <- unlist(
      scenarios[index, axis_ids, drop = FALSE], use.names = TRUE
    )
    positions <- match(
      paste(names(profile), profile, sep = "\036"),
      paste(level_qualification$AxisId, level_qualification$LevelId,
            sep = "\036")
    )
    available <- level_qualification$LegacyPrimitiveAvailable[positions]
    gaps <- paste0(names(profile)[!available], "=", profile[!available])
    data.frame(
      ProfileQualificationOrdinal = index,
      ScenarioId = scenarios$ScenarioId[[index]],
      ScenarioRole = scenarios$ScenarioRole[[index]],
      ScenarioHash = scenarios$ScenarioHash[[index]],
      DeclaredAxisCount = length(axis_ids),
      LegacyPrimitiveAvailableCount = as.integer(sum(available)),
      LegacyPrimitiveGapCount = as.integer(sum(!available)),
      LegacyPrimitiveGapLevels = paste(gaps, collapse = ";"),
      AllLegacyPrimitivesAvailable = all(available),
      FullProfileCompilerReady = FALSE,
      ExactRowEventIdentityReady = FALSE,
      ExactCovarianceFactorBindingReady = FALSE,
      ExactDistributionBindingReady = FALSE,
      GeneratorSemanticsQualified = FALSE,
      ExecutionSelected = FALSE,
      RngStreamOpened = FALSE,
      ResponseGenerated = FALSE,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gtds3q_route_qualification <- function(
    execution_plan, profile_qualification) {
  candidates <- execution_plan$RouteUnitRegistry[
    execution_plan$RouteUnitRegistry$PlannedDisposition ==
      "qualification_candidate", , drop = FALSE
  ]
  legacy_fit <- candidates$RouteId == "multivariate_lme4_restricted"
  profile_ready <- profile_qualification$GeneratorSemanticsQualified[
    match(candidates$ScenarioId, profile_qualification$ScenarioId)
  ]
  data.frame(
    RouteQualificationOrdinal = seq_len(nrow(candidates)),
    RouteUnitId = candidates$RouteUnitId,
    DatasetId = candidates$DatasetId,
    ScenarioId = candidates$ScenarioId,
    Replicate = candidates$Replicate,
    RouteId = candidates$RouteId,
    QualificationStatus = candidates$QualificationStatus,
    EvidenceAssetId = ifelse(
      legacy_fit, "GT-FIT-C4P", "GT-UNIV-D1"
    ),
    LegacyFitOrAlgebraEvidenceAvailable = TRUE,
    LegacyDatasetFitAdapterAvailable = legacy_fit,
    GeneratorDependencyQualified = profile_ready,
    ExactScenarioRouteAdapterReady = FALSE,
    Dsim3TerminalReceiptBindingReady = FALSE,
    Dsim3ResourceEnforcementReady = FALSE,
    RouteUnitQualified = FALSE,
    BlockingReason = ifelse(
      legacy_fit,
      paste(
        "legacy_lme4_worker_is_bound_to_one_30_object_6_rater",
        "two_stratum_gaussian_layout_not_this_dsim3_profile", sep = "_"
      ),
      paste(
        "univariate_algebra_exists_but_no_shared_dataset",
        "separate_fit_adapter_is_bound", sep = "_"
      )
    ),
    ExecutionSelected = FALSE, BackendCallMade = FALSE, FitExecuted = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3q_terminal_qualification <- function(execution_contract) {
  states <- execution_contract$TerminalStateRegistry
  legacy <- states$TerminalState %in% c(
    "generation_complete", "generation_failure",
    "not_attempted_generation_dependency", "fit_failure", "metric_failure",
    "complete_nonpromoting", "unrecorded_invalid"
  )
  data.frame(
    TerminalQualificationOrdinal = seq_len(nrow(states)),
    UnitType = states$UnitType, TerminalState = states$TerminalState,
    SemanticStateDefined = TRUE,
    LegacyStateOrAssertionEvidenceAvailable = legacy,
    GenericDsim3ReceiptSchemaReady = FALSE,
    ResourceMetadataBound = FALSE,
    ExactOneReceiptValidatorReady = FALSE,
    TerminalStateQualified = FALSE,
    EvidenceAssetId = ifelse(legacy, "GT-TERM-D2", "GT-RESOURCE-NONE"),
    BlockingReason =
      "no_generic_dsim3_dataset_and_route_terminal_receipt_adapter",
    RngStreamOpened = FALSE, ExecutionObserved = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3q_resource_qualification <- function(execution_contract) {
  resources <- execution_contract$ResourceLimitRegistry
  data.frame(
    ResourceQualificationOrdinal = seq_len(nrow(resources)),
    ScopeId = resources$ScopeId,
    MaximumWallSeconds = resources$MaximumWallSeconds,
    MaximumPeakRssMiB = resources$MaximumPeakRssMiB,
    MaximumConcurrentWorkers = resources$MaximumConcurrentWorkers,
    LimitContractDefined = TRUE,
    WallTimeoutEnforcementReady = FALSE,
    PeakRssEnforcementReady = FALSE,
    ExceedanceReceiptReady = FALSE,
    ResourceScopeQualified = FALSE,
    BlockingReason = "no_dsim3_process_controller_enforces_and_receipts_limits",
    ExecutionObserved = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3q_control_qualification <- function(execution_plan) {
  controls <- execution_plan$ControlUnitRegistry
  adapter_required <- controls$ControlId == "NC-NAIVE-POOLING"
  data.frame(
    ControlQualificationOrdinal = seq_len(nrow(controls)),
    ControlId = controls$ControlId,
    ControlType = controls$ControlType,
    ExpectedDisposition = controls$ExpectedDisposition,
    DeterministicRuleQualified = TRUE,
    EvidenceAssetId = ifelse(
      adapter_required, "GT-TERM-D2", "GT-UNIV-D1"
    ),
    ExecutionAdapterRequired = adapter_required,
    ExecutionAdapterReady = !adapter_required,
    ControlQualifiedForPreExecution = !adapter_required,
    RngStreamRequired = FALSE,
    ExecutionSelected = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3q_contract <- function() {
  mfrmr_gtds3q_require_primitives()
  execution <- mfrmr_gtds3e_contract()
  identity <- mfrmr_gtds3q_identity()
  payload <- c(identity, list(
    ExpectedProfileQualificationCount = 21L,
    ExpectedGeneratorLevelQualificationCount = 37L,
    ExpectedCandidateRouteQualificationCount = 50L,
    ExpectedTerminalStateQualificationCount = 13L,
    ExpectedResourceScopeQualificationCount = 5L,
    ExpectedControlQualificationCount = 3L,
    ExistingAssetRegistry = mfrmr_gtds3q_asset_registry(),
    FullProfileQualificationRequired = TRUE,
    AllCandidateRoutesQualificationRequired = TRUE,
    AllTerminalStatesQualificationRequired = TRUE,
    AllResourceScopesQualificationRequired = TRUE,
    PartialExecutionAllowed = FALSE,
    ScenarioSpecificExceptionAllowed = FALSE,
    OperationalOwnerAuthorizationRequired = FALSE,
    ExternalFreezeReceiptRequired = FALSE,
    SubstantiveTargetRequired = FALSE,
    QualificationAuditMayUseRng = FALSE,
    QualificationAuditMayGenerateResponses = FALSE,
    QualificationAuditMayCallBackend = FALSE,
    ExploratoryExecutionCurrentlyAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE,
    ParentExecutionPlanFrozen = isTRUE(execution$ContractFrozen)
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3q_hash(payload)
  )), class = c("mfrmr_gtds3q_contract", "list"))
}

mfrmr_gtds3q_validate_contract <- function(
    contract = mfrmr_gtds3q_contract()) {
  mfrmr_gtds3q_require_primitives()
  parent <- mfrmr_gtds3e_contract()
  mfrmr_gtds3e_validate_contract(parent)
  canonical <- mfrmr_gtds3q_contract()
  valid <- inherits(contract, "mfrmr_gtds3q_contract") &&
    identical(contract, canonical) &&
    identical(contract$ParentExecutionContractId, parent$ContractId) &&
    identical(contract$ParentExecutionContractHash, parent$ContractHash) &&
    identical(contract$ExpectedProfileQualificationCount, 21L) &&
    identical(contract$ExpectedGeneratorLevelQualificationCount, 37L) &&
    identical(contract$ExpectedCandidateRouteQualificationCount, 50L) &&
    identical(contract$ExpectedTerminalStateQualificationCount, 13L) &&
    identical(contract$ExpectedResourceScopeQualificationCount, 5L) &&
    identical(contract$ExpectedControlQualificationCount, 3L) &&
    isTRUE(contract$FullProfileQualificationRequired) &&
    isTRUE(contract$AllCandidateRoutesQualificationRequired) &&
    isTRUE(contract$AllTerminalStatesQualificationRequired) &&
    isTRUE(contract$AllResourceScopesQualificationRequired) &&
    !isTRUE(contract$PartialExecutionAllowed) &&
    !isTRUE(contract$ScenarioSpecificExceptionAllowed) &&
    !isTRUE(contract$OperationalOwnerAuthorizationRequired) &&
    !isTRUE(contract$ExternalFreezeReceiptRequired) &&
    !isTRUE(contract$SubstantiveTargetRequired) &&
    !isTRUE(contract$QualificationAuditMayUseRng) &&
    !isTRUE(contract$QualificationAuditMayGenerateResponses) &&
    !isTRUE(contract$QualificationAuditMayCallBackend) &&
    !isTRUE(contract$ExploratoryExecutionCurrentlyAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed) &&
    isTRUE(contract$ParentExecutionPlanFrozen) &&
    nrow(contract$ExistingAssetRegistry) == 5L &&
    all(!contract$ExistingAssetRegistry$ExactDsim3BindingAvailable) &&
    all(!contract$ExistingAssetRegistry$ExecutionAuthorityConferred)
  if (!valid) {
    stop("The D-SIM-3 pre-execution qualification contract is invalid.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3q_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds3q_require_primitives", "mfrmr_gtds3q_hash",
    "mfrmr_gtds3q_identity", "mfrmr_gtds3q_asset_registry",
    "mfrmr_gtds3q_primitive_support_map",
    "mfrmr_gtds3q_level_block_reason",
    "mfrmr_gtds3q_level_qualification",
    "mfrmr_gtds3q_profile_qualification",
    "mfrmr_gtds3q_route_qualification",
    "mfrmr_gtds3q_terminal_qualification",
    "mfrmr_gtds3q_resource_qualification",
    "mfrmr_gtds3q_control_qualification", "mfrmr_gtds3q_contract",
    "mfrmr_gtds3q_validate_contract",
    "mfrmr_gtds3q_implementation_identity", "mfrmr_gtds3q_payload_fields",
    "mfrmr_gtds3q_assert_manifest", "mfrmr_gtds3q_manifest"
  )
  target <- environment(mfrmr_gtds3q_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions), FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds3q_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)), stringsAsFactors = FALSE
  )
}

mfrmr_gtds3q_payload_fields <- function() {
  c(
    "Contract", "ParentExecutionPlanHash", "AssetRegistry",
    "GeneratorLevelQualificationRegistry",
    "ProfileQualificationRegistry", "CandidateRouteQualificationRegistry",
    "TerminalQualificationRegistry", "ResourceQualificationRegistry",
    "ControlQualificationRegistry", "ImplementationIdentity", "Summary"
  )
}

mfrmr_gtds3q_assert_manifest <- function(manifest) {
  fields <- mfrmr_gtds3q_payload_fields()
  if (!inherits(manifest, "mfrmr_gtds3q_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed D-SIM-3 pre-execution qualification manifest is required.",
         call. = FALSE)
  }
  mfrmr_gtds3q_validate_contract(manifest$Contract)
  levels <- manifest$GeneratorLevelQualificationRegistry
  profiles <- manifest$ProfileQualificationRegistry
  routes <- manifest$CandidateRouteQualificationRegistry
  terminals <- manifest$TerminalQualificationRegistry
  resources <- manifest$ResourceQualificationRegistry
  controls <- manifest$ControlQualificationRegistry
  route_counts <- table(factor(
    routes$RouteId,
    levels = c("multivariate_lme4_restricted", "separate_univariate")
  ))
  valid <- identical(
    manifest$ManifestHash, mfrmr_gtds3q_hash(manifest[fields])
  ) && identical(
    manifest$ImplementationIdentity, mfrmr_gtds3q_implementation_identity()
  ) && identical(
    manifest$ParentExecutionPlanHash,
    manifest$Contract$ParentExecutionPlanHash
  ) && identical(nrow(levels), 37L) && identical(nrow(profiles), 21L) &&
    identical(nrow(routes), 50L) && identical(nrow(terminals), 13L) &&
    identical(nrow(resources), 5L) && identical(nrow(controls), 3L) &&
    !anyDuplicated(profiles$ScenarioId) && !anyDuplicated(routes$RouteUnitId) &&
    identical(sum(levels$LegacyPrimitiveAvailable), 18L) &&
    all(!levels$ExactDsim3AxisLevelBindingReady) &&
    identical(
      sort(profiles$ScenarioId, method = "radix"), sprintf("D3-S%03d", 1:21)
    ) &&
    all(!profiles$FullProfileCompilerReady) &&
    all(!profiles$GeneratorSemanticsQualified) &&
    all(profiles$LegacyPrimitiveGapCount > 0L) &&
    all(grepl("object_count=", profiles$LegacyPrimitiveGapLevels,
              fixed = TRUE)) &&
    all(grepl("rater_count=", profiles$LegacyPrimitiveGapLevels,
              fixed = TRUE)) &&
    all(!profiles$ExecutionSelected) && all(!profiles$RngStreamOpened) &&
    all(!profiles$ResponseGenerated) &&
    identical(as.integer(route_counts), c(8L, 42L)) &&
    identical(sum(routes$LegacyDatasetFitAdapterAvailable), 8L) &&
    all(!routes$GeneratorDependencyQualified) &&
    all(!routes$ExactScenarioRouteAdapterReady) &&
    all(!routes$Dsim3TerminalReceiptBindingReady) &&
    all(!routes$Dsim3ResourceEnforcementReady) &&
    all(!routes$RouteUnitQualified) && all(!routes$ExecutionSelected) &&
    all(!routes$BackendCallMade) && all(!routes$FitExecuted) &&
    all(!terminals$GenericDsim3ReceiptSchemaReady) &&
    all(!terminals$TerminalStateQualified) &&
    all(!resources$WallTimeoutEnforcementReady) &&
    all(!resources$PeakRssEnforcementReady) &&
    all(!resources$ResourceScopeQualified) &&
    identical(sum(controls$ControlQualifiedForPreExecution), 2L) &&
    all(!controls$RngStreamRequired) && all(!controls$ExecutionSelected) &&
    isTRUE(manifest$Summary$QualificationAuditComplete) &&
    identical(manifest$Summary$LegacyPrimitiveAvailableLevelCount, 18L) &&
    identical(manifest$Summary$DeclaredGeneratorLevelCount, 37L) &&
    identical(manifest$Summary$QualifiedGeneratorLevelCount, 0L) &&
    identical(manifest$Summary$ProfileQualificationCount, 21L) &&
    identical(manifest$Summary$GeneratorQualifiedProfileCount, 0L) &&
    identical(manifest$Summary$CandidateRouteQualificationCount, 50L) &&
    identical(manifest$Summary$QualifiedCandidateRouteUnitCount, 0L) &&
    identical(manifest$Summary$TerminalStateQualificationCount, 13L) &&
    identical(manifest$Summary$QualifiedTerminalStateCount, 0L) &&
    identical(manifest$Summary$ResourceScopeQualificationCount, 5L) &&
    identical(manifest$Summary$QualifiedResourceScopeCount, 0L) &&
    identical(manifest$Summary$ControlQualificationCount, 3L) &&
    identical(manifest$Summary$QualifiedControlCount, 2L) &&
    !isTRUE(manifest$Summary$AllExecutionPrerequisitesQualified) &&
    !isTRUE(manifest$Summary$ExploratoryExecutionAllowed) &&
    !isTRUE(manifest$Summary$RngStreamOpened) &&
    !isTRUE(manifest$Summary$ResponseGenerated) &&
    !isTRUE(manifest$Summary$BackendCallMade) &&
    !isTRUE(manifest$Summary$FitExecuted) &&
    !isTRUE(manifest$Summary$SimulationValidationReady) &&
    !isTRUE(manifest$Summary$PublicSupportReady) &&
    identical(manifest$Summary$FeatureMaturity, "specified")
  if (!valid) {
    stop("The D-SIM-3 pre-execution qualification manifest was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3q_manifest <- function(
    contract = mfrmr_gtds3q_contract(),
    coverage = mfrmr_gtds3_manifest(),
    execution_plan = mfrmr_gtds3e_plan()) {
  mfrmr_gtds3q_validate_contract(contract)
  mfrmr_gtds3_assert_manifest(coverage)
  mfrmr_gtds3e_assert_plan(execution_plan)
  if (!identical(execution_plan$PlanHash,
                 contract$ParentExecutionPlanHash)) {
    stop("The parent D-SIM-3 execution plan identity changed.", call. = FALSE)
  }
  levels <- mfrmr_gtds3q_level_qualification()
  profiles <- mfrmr_gtds3q_profile_qualification(coverage, levels)
  routes <- mfrmr_gtds3q_route_qualification(execution_plan, profiles)
  terminals <- mfrmr_gtds3q_terminal_qualification(execution_plan$Contract)
  resources <- mfrmr_gtds3q_resource_qualification(execution_plan$Contract)
  controls <- mfrmr_gtds3q_control_qualification(execution_plan)
  implementation <- mfrmr_gtds3q_implementation_identity()
  summary <- list(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    ParentExecutionPlanHash = execution_plan$PlanHash,
    ExistingAssetCount = nrow(contract$ExistingAssetRegistry),
    LegacyPrimitiveAvailableLevelCount = sum(levels$LegacyPrimitiveAvailable),
    DeclaredGeneratorLevelCount = nrow(levels),
    QualifiedGeneratorLevelCount = sum(levels$ExactDsim3AxisLevelBindingReady),
    ProfileQualificationCount = nrow(profiles),
    GeneratorQualifiedProfileCount = sum(profiles$GeneratorSemanticsQualified),
    CandidateRouteQualificationCount = nrow(routes),
    QualifiedCandidateRouteUnitCount = sum(routes$RouteUnitQualified),
    TerminalStateQualificationCount = nrow(terminals),
    QualifiedTerminalStateCount = sum(terminals$TerminalStateQualified),
    ResourceScopeQualificationCount = nrow(resources),
    QualifiedResourceScopeCount = sum(resources$ResourceScopeQualified),
    ControlQualificationCount = nrow(controls),
    QualifiedControlCount = sum(controls$ControlQualifiedForPreExecution),
    QualificationAuditComplete = TRUE,
    AllExecutionPrerequisitesQualified = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    PartialExecutionAllowed = FALSE,
    ScenarioSpecificExceptionAllowed = FALSE,
    RngStreamOpened = FALSE,
    ResponseGenerated = FALSE,
    BackendCallMade = FALSE,
    FitExecuted = FALSE,
    ExploratoryResultAvailable = FALSE,
    SimulationValidationReady = FALSE,
    ReferenceValidationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE,
    FeatureMaturity = "specified",
    NextAction = paste(
      "implement one shared D-SIM-3 semantic execution substrate: typed",
      "design/event/count/missingness compiler, covariance/distribution",
      "generator, generic route and terminal-receipt adapters, and enforceable",
      "resource controller; do not patch individual scenarios or open 855"
    )
  )
  payload <- list(
    Contract = contract,
    ParentExecutionPlanHash = execution_plan$PlanHash,
    AssetRegistry = contract$ExistingAssetRegistry,
    GeneratorLevelQualificationRegistry = levels,
    ProfileQualificationRegistry = profiles,
    CandidateRouteQualificationRegistry = routes,
    TerminalQualificationRegistry = terminals,
    ResourceQualificationRegistry = resources,
    ControlQualificationRegistry = controls,
    ImplementationIdentity = implementation, Summary = summary
  )
  manifest <- structure(c(payload, list(
    ManifestHash = mfrmr_gtds3q_hash(payload)
  )), class = c("mfrmr_gtds3q_manifest", "list"))
  mfrmr_gtds3q_assert_manifest(manifest)
  manifest
}
