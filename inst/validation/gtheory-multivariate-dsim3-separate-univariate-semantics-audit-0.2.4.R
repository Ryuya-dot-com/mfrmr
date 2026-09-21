# Internal D-SIM-3 separate-univariate semantics audit.
#
# This audit separates backend feasibility from coefficient recoverability.
# It inspects the frozen structural assignments only.  It never initializes an
# RNG stream, generates a response, calls a backend, fits a model, or computes
# an empirical coefficient.

mfrmr_gtds3s_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds3e_plan",
    "mfrmr_gtds3e_assert_plan", "mfrmr_gtds3c_contract",
    "mfrmr_gtds3c_compile_profile", "mfrmr_gtds3b_contract"
  )
  target <- environment(mfrmr_gtds3s_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the D-SIM-3 plan, compiler, and binding chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3s_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3s_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM3-SEPARATE-UNIVARIATE-SEMANTICS-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-31",
    ParentExecutionPlanHash =
      "b91ab4229203efc15a3ca9421256d81ae7331143e42f845b5c6a879575552de7",
    ParentCompilerContractHash =
      "67cb6077c0b0fb083362c0b7bae498be6695e61a0f84d1636f992479ef79f666",
    ParentCompilerManifestHash =
      "dd69c9eb4f7b75641efb9f4b9bbfcee7818b8a645a7c70cdbc8f9b2551d74a3b",
    ParentBindingContractHash =
      "293dd2af3e8f13282ae545efa6063306f4cf59d4d7bf1027dca57de9376ae1c4",
    ParentBindingManifestHash =
      "8fcdc0297a0f09c0525a10f8c1a1ffca4310f7b7509f4df3f793f14f68151625"
  )
}

mfrmr_gtds3s_component_rule_registry <- function() {
  grid <- expand.grid(
    Crossing = c("fully_crossed", "partially_crossed", "nested"),
    RepeatCount = c(1L, 2L),
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  grid$RuleOrdinal <- seq_len(nrow(grid))
  repeated <- grid$RepeatCount > 1L
  nested <- grid$Crossing == "nested"
  grid$ObjectTerm <- "(1|ObjectId)"
  grid$ConditionTerm <- "(1|ConditionId)"
  grid$ObjectConditionTerm <- ifelse(
    repeated & !nested, "(1|ObjectConditionId)", "omitted"
  )
  grid$LevelOneResidual <- ifelse(
    repeated,
    "event_residual_after_identifiable_cell_interaction",
    "combined_object_condition_plus_event_residual"
  )
  grid$GeneratedRaterRole <- "absolute_only"
  grid$GeneratedObjectRaterRole <- "relative_error"
  grid$GeneratedPartitionsAliased <- nested
  grid$GeneratedRolesSeparatelyIdentifiable <- !nested
  grid$RequiredTruthRevision <- ifelse(
    nested,
    paste(
      "collapse_generated_Rater_and_Object:Rater_partition_and_assign_the",
      "combined_nested_condition_component_to_relative_and_absolute_error",
      sep = "_"
    ),
    "none"
  )
  grid$FitRepresentationFrozen <- TRUE
  grid$CoefficientRecoveryFromCurrentTruthAllowed <- !nested
  grid[c(
    "RuleOrdinal", "Crossing", "RepeatCount", "ObjectTerm",
    "ConditionTerm", "ObjectConditionTerm", "LevelOneResidual",
    "GeneratedRaterRole", "GeneratedObjectRaterRole",
    "GeneratedPartitionsAliased", "GeneratedRolesSeparatelyIdentifiable",
    "RequiredTruthRevision", "FitRepresentationFrozen",
    "CoefficientRecoveryFromCurrentTruthAllowed"
  )]
}

mfrmr_gtds3s_likelihood_registry <- function() {
  data.frame(
    ResponseDistribution = c(
      "gaussian", "heavy_tailed", "ordinal_aggregate"
    ),
    Backend = "lme4",
    EstimationCriterion = "REML",
    WorkingLikelihood = "Gaussian_linear_mixed_model",
    ComparatorMeaning = c(
      "model_matched_univariate_comparator",
      "Gaussian_working_likelihood_robustness_stress",
      "continuous_score_working_approximation_not_an_ordinal_model"
    ),
    GeneralOrdinalSupportClaimAllowed = FALSE,
    IndependentDatasetEvidence = FALSE,
    PublicSupportClaimAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3s_output_registry <- function() {
  data.frame(
    EstimandId = c("ABS-PHI", "REL-G"),
    OutputCoefficient = c("Phi", "G"),
    RouteCoordinatePayload = "named_per_stratum_numeric_vector",
    ScalarPoolingAcrossStrataAllowed = FALSE,
    CrossStratumCovarianceRecovered = FALSE,
    AllRegisteredStrataRequired = TRUE,
    RecoveryPassAggregation = "conjunctive_across_strata",
    CountsAsIndependentDataset = FALSE,
    CrossRouteVotingAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3s_contract <- function() {
  mfrmr_gtds3s_require_primitives()
  identity <- mfrmr_gtds3s_identity()
  payload <- c(identity, list(
    RequestedRouteId = "separate_univariate",
    RequestedBackend = "lme4",
    RequestedCriterion = "REML",
    ExpectedScenarioCount = 21L,
    ExpectedDatasetReplicateCount = 2L,
    ExpectedRouteUnitCount = 42L,
    ExpectedStratumPartitionTemplateCount = 47L,
    ExpectedFitPartitionCount = 94L,
    ExpectedCrossingCounts = c(
      fully_crossed = 10L, partially_crossed = 5L, nested = 6L
    ),
    ExpectedCurrentTruthIdentifiableScenarioCount = 15L,
    ExpectedExistingOperatorCompatibleScenarioCount = 10L,
    ExpectedCurrentRouteSemanticReadyScenarioCount = 10L,
    ComponentRuleRegistry = mfrmr_gtds3s_component_rule_registry(),
    LikelihoodRegistry = mfrmr_gtds3s_likelihood_registry(),
    OutputRegistry = mfrmr_gtds3s_output_registry(),
    StructuralAssignmentDefinesProspectiveAllocation = TRUE,
    PostMissingnessObservedCountsDefineProspectiveAllocation = FALSE,
    IncidenceOperatorDefinition = paste(
      "for_each_stratum_average_over_objects_of_the_outer_product_of",
      "equal_weights_on_that_objects_registered_structural_conditions",
      sep = "_"
    ),
    ExistingGlobalConditionOperatorMaySubstitute = FALSE,
    ScenarioSpecificPatchAllowed = FALSE,
    PartialLaunchAllowed = FALSE,
    AuditMayUseRng = FALSE,
    AuditMayGenerateResponse = FALSE,
    AuditMayCallBackend = FALSE,
    AuditMayFit = FALSE,
    AuditMayComputeEmpiricalMetric = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3s_hash(payload)
  )), class = c("mfrmr_gtds3s_contract", "list"))
}

mfrmr_gtds3s_validate_contract <- function(
    contract = mfrmr_gtds3s_contract()) {
  rules <- contract$ComponentRuleRegistry
  likelihood <- contract$LikelihoodRegistry
  output <- contract$OutputRegistry
  valid <- inherits(contract, "mfrmr_gtds3s_contract") &&
    identical(contract$ContractId,
              mfrmr_gtds3s_identity()$ContractId) &&
    identical(contract$ExpectedRouteUnitCount, 42L) &&
    identical(contract$ExpectedFitPartitionCount, 94L) &&
    is.data.frame(rules) && nrow(rules) == 6L &&
    !anyDuplicated(paste(rules$Crossing, rules$RepeatCount)) &&
    all(rules$FitRepresentationFrozen) &&
    identical(sum(rules$GeneratedPartitionsAliased), 2L) &&
    is.data.frame(likelihood) && nrow(likelihood) == 3L &&
    all(likelihood$Backend == "lme4") &&
    all(likelihood$EstimationCriterion == "REML") &&
    !any(likelihood$GeneralOrdinalSupportClaimAllowed) &&
    is.data.frame(output) && nrow(output) == 2L &&
    identical(output$EstimandId, c("ABS-PHI", "REL-G")) &&
    !any(output$ScalarPoolingAcrossStrataAllowed) &&
    !any(output$CrossStratumCovarianceRecovered) &&
    all(output$AllRegisteredStrataRequired) &&
    !isTRUE(contract$ExistingGlobalConditionOperatorMaySubstitute) &&
    !isTRUE(contract$ScenarioSpecificPatchAllowed) &&
    !isTRUE(contract$PartialLaunchAllowed) &&
    !isTRUE(contract$AuditMayUseRng) &&
    !isTRUE(contract$AuditMayGenerateResponse) &&
    !isTRUE(contract$AuditMayCallBackend) &&
    !isTRUE(contract$AuditMayFit) &&
    !isTRUE(contract$AuditMayComputeEmpiricalMetric) &&
    !isTRUE(contract$ExploratoryExecutionAllowed) &&
    identical(
      contract$ContractHash,
      mfrmr_gtds3s_hash(contract[setdiff(names(contract), "ContractHash")])
    )
  if (!valid) {
    stop("The D-SIM-3 separate-univariate semantics contract is invalid.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3s_component_count <- function(object, condition) {
  object <- as.character(object)
  condition <- as.character(condition)
  object_levels <- sort(unique(object), method = "radix")
  condition_levels <- sort(unique(condition), method = "radix")
  object_index <- match(object, object_levels)
  condition_index <- length(object_levels) + match(condition, condition_levels)
  parent <- seq_len(length(object_levels) + length(condition_levels))
  edge <- !duplicated(paste(object_index, condition_index, sep = "\r"))
  for (index in which(edge)) {
    left <- object_index[[index]]
    right <- condition_index[[index]]
    while (parent[[left]] != left) left <- parent[[left]]
    while (parent[[right]] != right) right <- parent[[right]]
    if (left != right) parent[[right]] <- left
  }
  roots <- integer(length(parent))
  for (index in seq_along(parent)) {
    root <- index
    while (parent[[root]] != root) root <- parent[[root]]
    roots[[index]] <- root
  }
  as.integer(length(unique(roots)))
}

mfrmr_gtds3s_partition_alias <- function(assignments) {
  object_condition <- paste(
    assignments$ObjectId, assignments$ConditionId, sep = "\r"
  )
  mapping <- unique(data.frame(
    ConditionId = as.character(assignments$ConditionId),
    ObjectConditionId = object_condition,
    stringsAsFactors = FALSE
  ))
  !anyDuplicated(mapping$ConditionId) &&
    !anyDuplicated(mapping$ObjectConditionId) &&
    length(unique(mapping$ConditionId)) ==
      length(unique(mapping$ObjectConditionId))
}

mfrmr_gtds3s_incidence_registry <- function(
    coverage = mfrmr_gtds3_manifest(),
    compiler_contract = mfrmr_gtds3c_contract()) {
  rows <- list()
  cursor <- 0L
  for (scenario_id in coverage$ScenarioRegistry$ScenarioId) {
    compilation <- mfrmr_gtds3c_compile_profile(
      scenario_id, compiler_contract, coverage, validate = FALSE
    )
    profile <- unlist(compilation$Profile, use.names = TRUE)
    assignments <- compilation$AssignmentRegistry
    for (stratum in compilation$StratumRegistry$Stratum) {
      cursor <- cursor + 1L
      part <- assignments[assignments$Stratum == stratum, , drop = FALSE]
      structural <- unique(part[c("ObjectId", "ConditionId")])
      counts <- table(structural$ObjectId)
      global_diagonal <- 1 / length(unique(structural$ConditionId))
      incidence_diagonal <- mean(1 / as.numeric(counts))
      crossing <- as.character(profile[["crossing"]])
      nested <- crossing == "nested"
      equivalent <- abs(global_diagonal - incidence_diagonal) <= 1e-12
      components <- mfrmr_gtds3s_component_count(
        structural$ObjectId, structural$ConditionId
      )
      alias <- mfrmr_gtds3s_partition_alias(part)
      rows[[cursor]] <- data.frame(
        PartitionOrdinal = cursor,
        ScenarioId = scenario_id,
        Stratum = stratum,
        Crossing = crossing,
        RepeatCount = as.integer(profile[["repeat_count"]]),
        StructuralObjectCount = length(unique(structural$ObjectId)),
        StructuralConditionCount = length(unique(structural$ConditionId)),
        MinimumConditionsPerObject = min(as.integer(counts)),
        MaximumConditionsPerObject = max(as.integer(counts)),
        IncidenceGraphComponentCount = components,
        ConnectedIncidence = components == 1L,
        GlobalConditionOperatorDiagonal = global_diagonal,
        RequiredIncidenceOperatorDiagonal = incidence_diagonal,
        ExistingGlobalOperatorEquivalent = equivalent,
        RaterObjectRaterPartitionsAliased = alias,
        CurrentTruthRolesSeparatelyIdentifiable = !alias,
        IncidenceOperatorImplementationReady = equivalent,
        CurrentMetricSemanticsReady = !alias && equivalent,
        stringsAsFactors = FALSE
      )
    }
  }
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3s_profile_registry <- function(incidence, coverage) {
  scenarios <- coverage$ScenarioRegistry
  rows <- lapply(seq_len(nrow(scenarios)), function(index) {
    scenario <- scenarios[index, , drop = FALSE]
    partitions <- incidence[
      incidence$ScenarioId == scenario$ScenarioId[[1L]], , drop = FALSE
    ]
    truth_ready <- all(partitions$CurrentTruthRolesSeparatelyIdentifiable)
    operator_ready <- all(partitions$IncidenceOperatorImplementationReady)
    data.frame(
      ScenarioOrdinal = scenario$ScenarioOrdinal,
      ScenarioId = scenario$ScenarioId,
      Crossing = scenario$crossing,
      RepeatCount = as.integer(scenario$repeat_count),
      ResponseDistribution = scenario$response_distribution,
      StratumPartitionTemplateCount = nrow(partitions),
      PlannedFitPartitionCount = 2L * nrow(partitions),
      PlannedRouteUnitCount = 2L,
      BackendCriterionFrozen = TRUE,
      FitComponentRepresentationFrozen = TRUE,
      PerStratumVectorOutputFrozen = TRUE,
      CurrentTruthRolesSeparatelyIdentifiable = truth_ready,
      RequiredIncidenceOperatorSpecified = TRUE,
      IncidenceOperatorImplementationReady = operator_ready,
      CurrentRouteSemanticsReady = truth_ready && operator_ready,
      ExecutionAuthorized = FALSE,
      BlockingReason = if (truth_ready && operator_ready) {
        "fit_metric_worker_and_shadow_qualification_not_yet_implemented"
      } else if (!truth_ready) {
        paste(
          "nested_generated_Rater_and_Object:Rater_partitions_are_aliased",
          "but_have_different_error_roles", sep = "_"
        )
      } else {
        paste(
          "object_incidence_averaged_D_study_operator_is_specified_but",
          "not_implemented", sep = "_"
        )
      },
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3s_route_registry <- function(execution_plan, profiles) {
  routes <- execution_plan$RouteUnitRegistry[
    execution_plan$RouteUnitRegistry$RouteId == "separate_univariate" &
      execution_plan$RouteUnitRegistry$PlannedDisposition ==
        "qualification_candidate", , drop = FALSE
  ]
  match_index <- match(routes$ScenarioId, profiles$ScenarioId)
  data.frame(
    RouteUnitOrdinal = routes$RouteUnitOrdinal,
    RouteUnitId = routes$RouteUnitId,
    DatasetId = routes$DatasetId,
    ScenarioId = routes$ScenarioId,
    Replicate = routes$Replicate,
    RouteId = routes$RouteId,
    Backend = "lme4",
    EstimationCriterion = "REML",
    PlannedFitPartitionCount = profiles$StratumPartitionTemplateCount[
      match_index
    ],
    BackendCriterionFrozen = TRUE,
    CurrentTruthRolesSeparatelyIdentifiable =
      profiles$CurrentTruthRolesSeparatelyIdentifiable[match_index],
    IncidenceOperatorImplementationReady =
      profiles$IncidenceOperatorImplementationReady[match_index],
    CurrentRouteSemanticsReady =
      profiles$CurrentRouteSemanticsReady[match_index],
    ExactBackendRequestCompiled = FALSE,
    BackendCallMade = FALSE,
    FitExecuted = FALSE,
    MetricComputed = FALSE,
    ExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3s_gate_registry <- function(profiles, routes, incidence) {
  pass <- c(
    TRUE,
    all(profiles$BackendCriterionFrozen),
    all(profiles$FitComponentRepresentationFrozen),
    all(profiles$PerStratumVectorOutputFrozen),
    all(profiles$RequiredIncidenceOperatorSpecified),
    all(incidence$CurrentTruthRolesSeparatelyIdentifiable),
    all(incidence$IncidenceOperatorImplementationReady),
    all(routes$CurrentRouteSemanticsReady),
    FALSE,
    FALSE
  )
  data.frame(
    GateOrdinal = 1:10,
    GateId = c(
      "parent_plan_identity", "backend_criterion_semantics",
      "per_stratum_fit_component_semantics", "coordinate_output_semantics",
      "prospective_allocation_definition", "truth_role_identifiability",
      "incidence_operator_implementation", "all_42_route_unit_semantics",
      "superseding_truth_and_plan_contract", "shadow_worker_qualification"
    ),
    GatePassed = pass,
    Blocking = !pass,
    AuditOnly = TRUE,
    ExecutionAttempted = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3s_gap_registry <- function() {
  data.frame(
    GapOrdinal = 1:4,
    GapId = c(
      "nested_truth_component_alias", "incidence_aware_dstudy_operator",
      "superseding_binding_and_execution_plan", "fit_metric_worker"
    ),
    RequiredArtifact = c(
      paste(
        "design_dependent_truth_component_registry_that_collapses_the",
        "nested_condition_partition_without_mixing_error_roles", sep = "_"
      ),
      paste(
        "tested_object_incidence_averaged_operator_using_registered",
        "structural_not_post_missingness_allocations", sep = "_"
      ),
      paste(
        "new_binding_and_execution_contract_identities_that_retain_all",
        "denominators_and_do_not_mutate_the_unopened_plan", sep = "_"
      ),
      paste(
        "identity_bound_lme4_REML_stratum_worker_and_vector_G_Phi_adapter",
        "qualified_only_on_nonreserved_shadow_fixtures", sep = "_"
      )
    ),
    DependencyOrder = 1:4,
    GapOpen = TRUE,
    ExecutionRequiredToClose = c(FALSE, FALSE, FALSE, TRUE),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3s_manifest <- function(
    contract = mfrmr_gtds3s_contract(),
    execution_plan = mfrmr_gtds3e_plan(),
    coverage = mfrmr_gtds3_manifest(),
    compiler_contract = mfrmr_gtds3c_contract()) {
  mfrmr_gtds3s_validate_contract(contract)
  mfrmr_gtds3e_assert_plan(execution_plan)
  binding_contract <- mfrmr_gtds3b_contract()
  if (!identical(execution_plan$PlanHash, contract$ParentExecutionPlanHash) ||
      !identical(compiler_contract$ContractHash,
                 contract$ParentCompilerContractHash) ||
      !identical(binding_contract$ContractHash,
                 contract$ParentBindingContractHash)) {
    stop("The D-SIM-3 semantics audit parent identity changed.",
         call. = FALSE)
  }
  incidence <- mfrmr_gtds3s_incidence_registry(
    coverage, compiler_contract
  )
  profiles <- mfrmr_gtds3s_profile_registry(incidence, coverage)
  routes <- mfrmr_gtds3s_route_registry(execution_plan, profiles)
  gates <- mfrmr_gtds3s_gate_registry(profiles, routes, incidence)
  gaps <- mfrmr_gtds3s_gap_registry()
  crossing_counts <- table(factor(
    profiles$Crossing, levels = names(contract$ExpectedCrossingCounts)
  ))
  summary <- list(
    ScenarioCount = nrow(profiles),
    RouteUnitCount = nrow(routes),
    StratumPartitionTemplateCount = nrow(incidence),
    PlannedFitPartitionCount = sum(routes$PlannedFitPartitionCount),
    CrossingCounts = stats::setNames(
      as.integer(crossing_counts), names(contract$ExpectedCrossingCounts)
    ),
    BackendCriterionFrozenRouteUnitCount =
      sum(routes$BackendCriterionFrozen),
    CurrentTruthIdentifiableScenarioCount = sum(
      profiles$CurrentTruthRolesSeparatelyIdentifiable
    ),
    ExistingOperatorCompatibleScenarioCount = sum(
      profiles$IncidenceOperatorImplementationReady
    ),
    CurrentRouteSemanticReadyScenarioCount = sum(
      profiles$CurrentRouteSemanticsReady
    ),
    CurrentRouteSemanticReadyRouteUnitCount = sum(
      routes$CurrentRouteSemanticsReady
    ),
    ReadinessGateCount = nrow(gates),
    PassingReadinessGateCount = sum(gates$GatePassed),
    BlockingReadinessGateCount = sum(gates$Blocking),
    OpenGapCount = sum(gaps$GapOpen),
    CurrentDisposition =
      "no_go_truth_estimand_and_incidence_operator_revision_required",
    NextAction = paste(
      "supersede the D-SIM-3 truth binding for nested designs, implement",
      "the incidence-aware prospective operator, then issue a new unopened",
      "execution plan before any fit worker",
      sep = "_"
    ),
    Planned855RngStreamOpened = FALSE,
    ExploratoryResponseGenerated = FALSE,
    BackendCallMade = FALSE,
    FitReturned = FALSE,
    EmpiricalMetricComputed = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE
  )
  payload <- list(
    Contract = contract,
    ParentExecutionPlanHash = execution_plan$PlanHash,
    ComponentRuleRegistry = contract$ComponentRuleRegistry,
    LikelihoodRegistry = contract$LikelihoodRegistry,
    OutputRegistry = contract$OutputRegistry,
    IncidencePartitionRegistry = incidence,
    ProfileSemanticsRegistry = profiles,
    RouteUnitSemanticsRegistry = routes,
    ReadinessGateRegistry = gates,
    OpenGapRegistry = gaps,
    Summary = summary
  )
  structure(c(payload, list(
    ManifestHash = mfrmr_gtds3s_hash(payload)
  )), class = c("mfrmr_gtds3s_manifest", "list"))
}

mfrmr_gtds3s_assert_manifest <- function(
    manifest, contract = mfrmr_gtds3s_contract(),
    execution_plan = mfrmr_gtds3e_plan()) {
  if (!inherits(manifest, "mfrmr_gtds3s_manifest")) {
    stop("A typed D-SIM-3 separate-univariate manifest is required.",
         call. = FALSE)
  }
  mfrmr_gtds3s_validate_contract(contract)
  mfrmr_gtds3e_assert_plan(execution_plan)
  incidence <- manifest$IncidencePartitionRegistry
  profiles <- manifest$ProfileSemanticsRegistry
  routes <- manifest$RouteUnitSemanticsRegistry
  gates <- manifest$ReadinessGateRegistry
  valid <- identical(manifest$Contract, contract) &&
    identical(manifest$ParentExecutionPlanHash, execution_plan$PlanHash) &&
    identical(nrow(incidence), 47L) &&
    identical(nrow(profiles), 21L) &&
    identical(nrow(routes), 42L) &&
    identical(sum(routes$PlannedFitPartitionCount), 94L) &&
    all(routes$Backend == "lme4") &&
    all(routes$EstimationCriterion == "REML") &&
    all(routes$BackendCriterionFrozen) &&
    identical(sum(profiles$CurrentTruthRolesSeparatelyIdentifiable), 15L) &&
    identical(sum(profiles$IncidenceOperatorImplementationReady), 10L) &&
    identical(sum(profiles$CurrentRouteSemanticsReady), 10L) &&
    identical(sum(routes$CurrentRouteSemanticsReady), 20L) &&
    all(incidence$ExistingGlobalOperatorEquivalent ==
          (incidence$Crossing == "fully_crossed")) &&
    all(incidence$RaterObjectRaterPartitionsAliased ==
          (incidence$Crossing == "nested")) &&
    identical(gates$GatePassed,
              c(TRUE, TRUE, TRUE, TRUE, TRUE,
                FALSE, FALSE, FALSE, FALSE, FALSE)) &&
    identical(manifest$Summary$CurrentDisposition,
              "no_go_truth_estimand_and_incidence_operator_revision_required") &&
    !isTRUE(manifest$Summary$Planned855RngStreamOpened) &&
    !isTRUE(manifest$Summary$ExploratoryResponseGenerated) &&
    !isTRUE(manifest$Summary$BackendCallMade) &&
    !isTRUE(manifest$Summary$FitReturned) &&
    !isTRUE(manifest$Summary$EmpiricalMetricComputed) &&
    !isTRUE(manifest$Summary$ExploratoryExecutionAllowed) &&
    identical(
      manifest$ManifestHash,
      mfrmr_gtds3s_hash(manifest[setdiff(names(manifest), "ManifestHash")])
    )
  if (!valid) {
    stop("The D-SIM-3 separate-univariate manifest was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}
