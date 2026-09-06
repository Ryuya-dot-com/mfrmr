# Internal D-SIM-3 design-dependent truth projection.
#
# Generator components and estimand components are deliberately distinct.
# The qualified four-stream generator is preserved.  For nested designs only,
# its aliased Rater and Object:Rater partitions are projected to one
# NestedCondition estimand component with a relative-error role.  This file
# opens no RNG stream and computes no G or Phi coefficient.

mfrmr_gtds3t_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds3b_contract",
    "mfrmr_gtds3b_bind_profile", "mfrmr_gtds3b_correlation",
    "mfrmr_gtds3b_matrix_audit", "mfrmr_gtds3g_contract",
    "mfrmr_gtds3s_contract", "mfrmr_gtds3s_manifest",
    "mfrmr_gtds3s_assert_manifest"
  )
  target <- environment(mfrmr_gtds3t_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the D-SIM-3 binding, generator, and semantics chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3t_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3t_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM3-DESIGN-DEPENDENT-TRUTH-V2",
    ContractVersion = "2.0.0",
    ContractDate = "2026-08-31",
    ParentBindingContractHash =
      "293dd2af3e8f13282ae545efa6063306f4cf59d4d7bf1027dca57de9376ae1c4",
    ParentBindingManifestHash =
      "8fcdc0297a0f09c0525a10f8c1a1ffca4310f7b7509f4df3f793f14f68151625",
    ParentGeneratorContractHash =
      "92a6b8b1b0728bc33477e4ec6737c0a3c448f8934708120cbc8aeff51025b2d4",
    ParentGeneratorManifestHash =
      "c334578b20b886d158f5fd1aa82c3c1bd9e24f64e7e9d1d4d1c25e7f868da46a",
    ParentSemanticsContractHash =
      "ed0eda8a02cd4ea4dc46084f56f6683ac967da0705c08e8fb4f804cf6ed94adf",
    ParentSemanticsManifestHash =
      "815d29f76640f2886b572ffda418582a02135d51cd50dadbab5ff6e4308bbb2f"
  )
}

mfrmr_gtds3t_mapping_registry <- function() {
  data.frame(
    MappingOrdinal = 1:8,
    DesignClass = c(rep("crossed", 4L), rep("nested", 4L)),
    SourceGeneratorComponent = c(
      "Object", "Rater", "Object:Rater", "Residual",
      "Object", "Rater", "Object:Rater", "Residual"
    ),
    TargetEstimandComponent = c(
      "Object", "Rater", "Object:Rater", "Residual",
      "Object", "NestedCondition", "NestedCondition", "Residual"
    ),
    TargetUniverseRole = c(
      "object", "absolute_only", "relative_error", "relative_error",
      "object", "relative_error", "relative_error", "relative_error"
    ),
    TargetIdentitySource = c(
      "global_object_universe", "condition_identity",
      "object_by_condition_identity", "observation_event_identity",
      "global_object_universe", "object_nested_condition_identity",
      "object_nested_condition_identity", "observation_event_identity"
    ),
    AggregationRule = c(
      rep("identity_projection", 4L),
      "identity_projection", "independent_covariance_sum",
      "independent_covariance_sum", "identity_projection"
    ),
    SourceDrawRetained = TRUE,
    GeneratorPayloadMutationRequired = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3t_estimand_registry <- function() {
  data.frame(
    EstimandId = c("ABS-PHI", "REL-G"),
    Coefficient = c("Phi", "G"),
    CrossedProjection = "unchanged",
    NestedProjection = c(
      "unchanged_total_error_after_alias_collapse",
      "revised_to_include_combined_nested_condition_relative_error"
    ),
    AllocationOperatorRequired = TRUE,
    CoefficientComputed = FALSE,
    IndependentEstimandVote = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3t_contract <- function() {
  mfrmr_gtds3t_require_primitives()
  identity <- mfrmr_gtds3t_identity()
  payload <- c(identity, list(
    ExpectedProfileCount = 21L,
    ExpectedCrossedProfileCount = 15L,
    ExpectedNestedProfileCount = 6L,
    ExpectedExpandedMappingCount = 84L,
    ExpectedTargetComponentBindingCount = 78L,
    ExpectedAliasResolutionCount = 6L,
    ExpectedDistributionEquivalenceCount = 21L,
    ExpectedIdentifiableTruthProfileCount = 21L,
    MappingRegistry = mfrmr_gtds3t_mapping_registry(),
    EstimandRegistry = mfrmr_gtds3t_estimand_registry(),
    GeneratorComponentRegistryPreserved = TRUE,
    GeneratorSubstreamIdentityPreserved = TRUE,
    GeneratorPayloadHashMayBeRelabeled = FALSE,
    CollapsedSourceComponents = c("Rater", "Object:Rater"),
    CollapsedSourceComponentsMustBeGaussian = TRUE,
    CollapsedSourceStreamsMustBeDistinct = TRUE,
    EstimandComponentRegistrySuperseded = TRUE,
    NestedSourcePartitionsMustAlias = TRUE,
    NestedDifferentlyRolledDuplicateComponentsAllowed = FALSE,
    NestedConditionContributesToRelativeAndAbsoluteError = TRUE,
    AbsoluteErrorComponentCovarianceMustBePreserved = TRUE,
    LatentResponseDistributionMustBePreserved = TRUE,
    ExistingUnopenedExecutionPlanMayBeMutated = FALSE,
    SupersedingExecutionPlanRequired = TRUE,
    IncidenceAwareAllocationOperatorRequired = TRUE,
    MatrixTolerance = 1e-10,
    ProjectionMayUseRng = FALSE,
    ProjectionMayGenerateResponse = FALSE,
    ProjectionMayCallBackend = FALSE,
    ProjectionMayFit = FALSE,
    ProjectionMayComputeCoefficient = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3t_hash(payload)
  )), class = c("mfrmr_gtds3t_contract", "list"))
}

mfrmr_gtds3t_validate_contract <- function(
    contract = mfrmr_gtds3t_contract()) {
  canonical <- mfrmr_gtds3t_contract()
  mapping <- contract$MappingRegistry
  estimands <- contract$EstimandRegistry
  valid <- inherits(contract, "mfrmr_gtds3t_contract") &&
    identical(contract, canonical) &&
    is.data.frame(mapping) && nrow(mapping) == 8L &&
    identical(sum(mapping$DesignClass == "crossed"), 4L) &&
    identical(sum(mapping$DesignClass == "nested"), 4L) &&
    identical(sum(mapping$TargetEstimandComponent == "NestedCondition"),
              2L) &&
    all(mapping$SourceDrawRetained) &&
    !any(mapping$GeneratorPayloadMutationRequired) &&
    is.data.frame(estimands) && nrow(estimands) == 2L &&
    identical(estimands$EstimandId, c("ABS-PHI", "REL-G")) &&
    all(estimands$AllocationOperatorRequired) &&
    !any(estimands$CoefficientComputed) &&
    isTRUE(contract$GeneratorComponentRegistryPreserved) &&
    isTRUE(contract$GeneratorSubstreamIdentityPreserved) &&
    !isTRUE(contract$GeneratorPayloadHashMayBeRelabeled) &&
    identical(contract$CollapsedSourceComponents,
              c("Rater", "Object:Rater")) &&
    isTRUE(contract$CollapsedSourceComponentsMustBeGaussian) &&
    isTRUE(contract$CollapsedSourceStreamsMustBeDistinct) &&
    isTRUE(contract$EstimandComponentRegistrySuperseded) &&
    isTRUE(contract$NestedSourcePartitionsMustAlias) &&
    !isTRUE(contract$NestedDifferentlyRolledDuplicateComponentsAllowed) &&
    isTRUE(contract$NestedConditionContributesToRelativeAndAbsoluteError) &&
    isTRUE(contract$AbsoluteErrorComponentCovarianceMustBePreserved) &&
    isTRUE(contract$LatentResponseDistributionMustBePreserved) &&
    !isTRUE(contract$ExistingUnopenedExecutionPlanMayBeMutated) &&
    isTRUE(contract$SupersedingExecutionPlanRequired) &&
    isTRUE(contract$IncidenceAwareAllocationOperatorRequired) &&
    !isTRUE(contract$ProjectionMayUseRng) &&
    !isTRUE(contract$ProjectionMayGenerateResponse) &&
    !isTRUE(contract$ProjectionMayCallBackend) &&
    !isTRUE(contract$ProjectionMayFit) &&
    !isTRUE(contract$ProjectionMayComputeCoefficient) &&
    !isTRUE(contract$ExploratoryExecutionAllowed) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The D-SIM-3 design-dependent truth contract is invalid.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3t_matrix_sum <- function(matrices) {
  if (length(matrices) == 0L) stop("At least one matrix is required.")
  Reduce(`+`, matrices)
}

mfrmr_gtds3t_source_unit_covariance <- function(
    source_binding, component_id, binding_contract, profile,
    tolerance = 1e-10) {
  component <- source_binding$ComponentBindings[[component_id]]
  strata <- rownames(component$CovarianceMatrix)
  full_overlap <- matrix(
    1, nrow = length(strata), ncol = length(strata),
    dimnames = list(strata, strata)
  )
  correlation <- mfrmr_gtds3b_correlation(
    binding_contract, profile, component_id, full_overlap
  )
  scale <- diag(
    sqrt(component$MarginalVariances), nrow = length(strata)
  )
  dimnames(scale) <- list(strata, strata)
  unit <- scale %*% correlation %*% scale
  dimnames(unit) <- list(strata, strata)
  implied <- unit * component$OverlapMatrix
  error <- max(abs(implied - component$CovarianceMatrix))
  if (error > tolerance) {
    stop("A source unit covariance did not reproduce its binding.",
         call. = FALSE)
  }
  list(Matrix = unit, ImplicationMaximumError = error)
}

mfrmr_gtds3t_factor <- function(matrix, matrix_id, tolerance) {
  symmetric <- (matrix + t(matrix)) / 2
  dimnames(symmetric) <- dimnames(matrix)
  audit <- mfrmr_gtds3b_matrix_audit(
    symmetric, matrix_id, tolerance = tolerance
  )
  factor <- signif(t(chol(symmetric)), 14L)
  rownames(factor) <- rownames(matrix)
  colnames(factor) <- paste0("Factor", seq_len(ncol(matrix)))
  reconstruction <- factor %*% t(factor)
  dimnames(reconstruction) <- dimnames(matrix)
  error <- max(abs(reconstruction - symmetric))
  if (error > tolerance) {
    stop("A projected truth factor did not reconstruct its covariance.",
         call. = FALSE)
  }
  list(Matrix = symmetric, Audit = audit,
       Factor = factor, ReconstructionMaximumError = error)
}

mfrmr_gtds3t_target_component <- function(
    target_id, mapping, source_binding, binding_contract, profile,
    source_alias_qualified, contract) {
  selected <- mapping[mapping$TargetEstimandComponent == target_id,
                      , drop = FALSE]
  source_ids <- selected$SourceGeneratorComponent
  roles <- unique(selected$TargetUniverseRole)
  identities <- unique(selected$TargetIdentitySource)
  if (length(roles) != 1L || length(identities) != 1L) {
    stop("A target truth component has inconsistent semantics.",
         call. = FALSE)
  }
  sources <- source_binding$ComponentBindings[source_ids]
  overlaps <- lapply(sources, `[[`, "OverlapMatrix")
  alias_required <- length(source_ids) > 1L
  overlap_equal <- all(vapply(overlaps[-1L], function(matrix) {
    isTRUE(all.equal(matrix, overlaps[[1L]], tolerance = 0,
                     check.attributes = TRUE))
  }, logical(1L)))
  alias_qualified <- !alias_required ||
    (isTRUE(source_alias_qualified) && overlap_equal)
  if (!alias_qualified) {
    stop("Source partitions cannot be collapsed into one truth component.",
         call. = FALSE)
  }
  units <- lapply(source_ids, function(component_id) {
    mfrmr_gtds3t_source_unit_covariance(
      source_binding, component_id, binding_contract, profile,
      contract$MatrixTolerance
    )
  })
  unit_matrix <- mfrmr_gtds3t_matrix_sum(lapply(units, `[[`, "Matrix"))
  overlap <- overlaps[[1L]]
  effective <- unit_matrix * overlap
  dimnames(effective) <- dimnames(unit_matrix)
  source_effective <- mfrmr_gtds3t_matrix_sum(lapply(
    sources, `[[`, "CovarianceMatrix"
  ))
  source_sum_error <- max(abs(effective - source_effective))
  unit_factor <- mfrmr_gtds3t_factor(
    unit_matrix, paste0("ProjectedUnit/", target_id),
    contract$MatrixTolerance
  )
  effective_audit <- mfrmr_gtds3b_matrix_audit(
    effective, paste0("ProjectedEffective/", target_id),
    tolerance = contract$MatrixTolerance
  )
  if (source_sum_error > contract$MatrixTolerance) {
    stop("The projected component changed effective covariance.",
         call. = FALSE)
  }
  payload <- list(
    TargetComponentId = target_id,
    UniverseRole = roles[[1L]],
    IdentitySource = identities[[1L]],
    SourceGeneratorComponents = source_ids,
    AggregationRule = if (length(source_ids) == 1L) {
      "identity_projection"
    } else "independent_covariance_sum",
    SourcePartitionAliasRequired = alias_required,
    SourcePartitionAliasQualified = alias_qualified,
    IdentityOverlapMatrix = overlap,
    UnitCovarianceMatrix = unit_factor$Matrix,
    EffectiveCovarianceMatrix = effective,
    UnitFactorMatrix = unit_factor$Factor,
    UnitCovarianceAudit = unit_factor$Audit,
    EffectiveCovarianceAudit = effective_audit,
    SourceUnitImplicationMaximumError = max(vapply(
      units, `[[`, numeric(1L), "ImplicationMaximumError"
    )),
    EffectiveSourceSumMaximumError = source_sum_error,
    UnitFactorReconstructionMaximumError =
      unit_factor$ReconstructionMaximumError
  )
  structure(c(payload, list(
    TargetComponentHash = mfrmr_gtds3t_hash(payload)
  )), class = c("mfrmr_gtds3t_component", "list"))
}

mfrmr_gtds3t_error_sum <- function(components, roles) {
  selected <- components[vapply(components, function(component) {
    component$UniverseRole %in% roles
  }, logical(1L))]
  mfrmr_gtds3t_matrix_sum(lapply(
    selected, `[[`, "EffectiveCovarianceMatrix"
  ))
}

mfrmr_gtds3t_source_error_sum <- function(source_binding, roles) {
  registry <- source_binding$ComponentRegistry
  ids <- registry$ComponentId[registry$UniverseRole %in% roles]
  mfrmr_gtds3t_matrix_sum(lapply(
    source_binding$ComponentBindings[ids], `[[`, "CovarianceMatrix"
  ))
}

mfrmr_gtds3t_project_profile <- function(
    scenario_id, contract = mfrmr_gtds3t_contract(),
    semantics_manifest = mfrmr_gtds3s_manifest(),
    binding_contract = mfrmr_gtds3b_contract(),
    compiler_contract = mfrmr_gtds3c_contract(),
    coverage = mfrmr_gtds3_manifest(), validate = TRUE) {
  if (isTRUE(validate)) {
    mfrmr_gtds3t_validate_contract(contract)
    mfrmr_gtds3s_assert_manifest(semantics_manifest)
  }
  source <- mfrmr_gtds3b_bind_profile(
    scenario_id, binding_contract, compiler_contract, coverage,
    validate = FALSE
  )
  profile <- unlist(source$Profile, use.names = TRUE)
  crossing <- profile[["crossing"]]
  design_class <- if (crossing == "nested") "nested" else "crossed"
  mapping <- contract$MappingRegistry[
    contract$MappingRegistry$DesignClass == design_class, , drop = FALSE
  ]
  semantics_row <- semantics_manifest$ProfileSemanticsRegistry[
    semantics_manifest$ProfileSemanticsRegistry$ScenarioId == scenario_id,
    , drop = FALSE
  ]
  incidence_rows <- semantics_manifest$IncidencePartitionRegistry[
    semantics_manifest$IncidencePartitionRegistry$ScenarioId == scenario_id,
    , drop = FALSE
  ]
  if (nrow(semantics_row) != 1L || nrow(incidence_rows) == 0L) {
    stop("The source semantics profile is not uniquely registered.",
         call. = FALSE)
  }
  source_alias <- all(
    incidence_rows$RaterObjectRaterPartitionsAliased
  )
  alias_expected <- design_class == "nested"
  if (!identical(source_alias, alias_expected)) {
    stop("The source partition identity does not match the design class.",
         call. = FALSE)
  }
  target_ids <- unique(mapping$TargetEstimandComponent)
  components <- stats::setNames(lapply(target_ids, function(target_id) {
    mfrmr_gtds3t_target_component(
      target_id, mapping, source, binding_contract, profile,
      source_alias, contract
    )
  }), target_ids)
  source_total <- mfrmr_gtds3t_matrix_sum(lapply(
    source$ComponentBindings, `[[`, "CovarianceMatrix"
  ))
  target_total <- mfrmr_gtds3t_matrix_sum(lapply(
    components, `[[`, "EffectiveCovarianceMatrix"
  ))
  latent_error <- max(abs(source_total - target_total))
  source_absolute <- mfrmr_gtds3t_source_error_sum(
    source, c("absolute_only", "relative_error")
  )
  target_absolute <- mfrmr_gtds3t_error_sum(
    components, c("absolute_only", "relative_error")
  )
  absolute_error <- max(abs(source_absolute - target_absolute))
  source_relative <- mfrmr_gtds3t_source_error_sum(
    source, "relative_error"
  )
  target_relative <- mfrmr_gtds3t_error_sum(
    components, "relative_error"
  )
  relative_revision <- max(abs(source_relative - target_relative))
  target_registry <- data.frame(
    TargetComponentOrdinal = seq_along(components),
    TargetComponentId = names(components),
    UniverseRole = vapply(
      components, `[[`, character(1L), "UniverseRole"
    ),
    IdentitySource = vapply(
      components, `[[`, character(1L), "IdentitySource"
    ),
    SourceComponentCount = vapply(
      components, function(x) length(x$SourceGeneratorComponents),
      integer(1L)
    ),
    SourceGeneratorComponents = vapply(
      components, function(x) paste(x$SourceGeneratorComponents,
                                    collapse = "+"), character(1L)
    ),
    SourcePartitionAliasRequired = vapply(
      components, `[[`, logical(1L), "SourcePartitionAliasRequired"
    ),
    SourcePartitionAliasQualified = vapply(
      components, `[[`, logical(1L), "SourcePartitionAliasQualified"
    ),
    PositiveSemidefinite = vapply(
      components, function(x) {
        isTRUE(x$UnitCovarianceAudit$PositiveSemidefinite) &&
          isTRUE(x$EffectiveCovarianceAudit$PositiveSemidefinite)
      }, logical(1L)
    ),
    EffectiveSourceSumMaximumError = vapply(
      components, `[[`, numeric(1L), "EffectiveSourceSumMaximumError"
    ),
    UnitFactorReconstructionMaximumError = vapply(
      components, `[[`, numeric(1L),
      "UnitFactorReconstructionMaximumError"
    ),
    TargetComponentHash = vapply(
      components, `[[`, character(1L), "TargetComponentHash"
    ),
    stringsAsFactors = FALSE
  )
  summary <- list(
    ScenarioId = scenario_id,
    Crossing = crossing,
    DesignClass = design_class,
    SourceBindingHash = source$BindingHash,
    SourceGeneratorComponentCount = 4L,
    TargetEstimandComponentCount = length(components),
    SourceAliasPresent = source_alias,
    SourceAliasResolved = !source_alias ||
      ("NestedCondition" %in% names(components) &&
         length(components$NestedCondition$SourceGeneratorComponents) == 2L),
    TargetComponentsPositiveSemidefinite =
      all(target_registry$PositiveSemidefinite),
    LatentResponseCovarianceMaximumError = latent_error,
    LatentResponseDistributionPreserved =
      latent_error <= contract$MatrixTolerance,
    AbsoluteErrorCovarianceMaximumError = absolute_error,
    AbsoluteErrorCovariancePreserved =
      absolute_error <= contract$MatrixTolerance,
    RelativeErrorCovarianceRevisionMagnitude = relative_revision,
    RelativeErrorRoleRevised = if (design_class == "nested") {
      relative_revision > contract$MatrixTolerance
    } else relative_revision <= contract$MatrixTolerance,
    TruthRolesIdentifiable = TRUE,
    GeneratorPayloadMutationRequired = FALSE,
    CoefficientComputed = FALSE,
    IncidenceAwareAllocationOperatorReady = FALSE,
    ExploratoryExecutionAllowed = FALSE
  )
  payload <- list(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    ScenarioId = scenario_id,
    Profile = source$Profile,
    SourceBindingHash = source$BindingHash,
    SourceToTargetMapping = mapping,
    TargetComponentRegistry = target_registry,
    TargetComponents = components,
    Summary = summary
  )
  structure(c(payload, list(
    ProjectionHash = mfrmr_gtds3t_hash(payload)
  )), class = c("mfrmr_gtds3t_projection", "list"))
}

mfrmr_gtds3t_gate_registry <- function(profiles, components, mappings) {
  pass <- c(
    TRUE, TRUE,
    nrow(mappings) == 84L,
    sum(profiles$SourceAliasResolved & profiles$DesignClass == "nested") == 6L,
    nrow(components) == 78L && all(components$PositiveSemidefinite),
    all(profiles$LatentResponseDistributionPreserved),
    all(profiles$AbsoluteErrorCovariancePreserved),
    all(profiles$TruthRolesIdentifiable),
    FALSE, FALSE
  )
  data.frame(
    GateOrdinal = 1:10,
    GateId = c(
      "parent_semantics_identity", "parent_generator_identity",
      "source_target_mapping", "nested_alias_resolution",
      "projected_component_psd", "latent_distribution_equivalence",
      "absolute_error_partition_preservation",
      "all_profile_truth_role_identifiability",
      "incidence_aware_allocation_operator",
      "superseding_plan_and_execution_bridge"
    ),
    GatePassed = pass,
    Blocking = !pass,
    ProjectionOnly = TRUE,
    ExecutionAttempted = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3t_gap_registry <- function() {
  data.frame(
    GapOrdinal = 1:3,
    GapId = c(
      "incidence_aware_dstudy_operator", "superseding_execution_plan",
      "fit_metric_execution_bridge"
    ),
    DependencyOrder = 1:3,
    RequiredArtifact = c(
      paste(
        "object_incidence_averaged_structural_allocation_operator_with",
        "fully_crossed_reduction_and_independent_oracle", sep = "_"
      ),
      paste(
        "new_unopened_plan_binding_this_truth_projection_and_operator",
        "without_relabeling_parent_generator_payloads", sep = "_"
      ),
      paste(
        "identity_bound_fit_metric_worker_and_terminal_resource",
        "orchestration_qualified_on_nonreserved_shadow_fixtures", sep = "_"
      )
    ),
    GapOpen = TRUE,
    ExecutionRequiredToClose = c(FALSE, FALSE, TRUE),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3t_manifest <- function(
    contract = mfrmr_gtds3t_contract(),
    semantics_manifest = mfrmr_gtds3s_manifest(),
    binding_contract = mfrmr_gtds3b_contract(),
    compiler_contract = mfrmr_gtds3c_contract(),
    coverage = mfrmr_gtds3_manifest()) {
  mfrmr_gtds3t_validate_contract(contract)
  mfrmr_gtds3s_assert_manifest(semantics_manifest)
  generator_contract <- mfrmr_gtds3g_contract()
  if (!identical(binding_contract$ContractHash,
                 contract$ParentBindingContractHash) ||
      !identical(generator_contract$ContractHash,
                 contract$ParentGeneratorContractHash) ||
      !identical(semantics_manifest$Contract$ContractHash,
                 contract$ParentSemanticsContractHash) ||
      !identical(semantics_manifest$ManifestHash,
                 contract$ParentSemanticsManifestHash)) {
    stop("A parent identity of the truth projection changed.",
         call. = FALSE)
  }
  collapsed <- contract$CollapsedSourceComponents
  collapsed_gaussian <- all(
    generator_contract$ComponentEffectsAreGaussian[collapsed]
  )
  collapsed_streams_distinct <- all(
    collapsed %in% generator_contract$SubstreamOrder
  ) && !anyDuplicated(collapsed)
  if (!collapsed_gaussian || !collapsed_streams_distinct) {
    stop(
      "Collapsed source effects must be Gaussian independent streams.",
      call. = FALSE
    )
  }
  scenarios <- coverage$ScenarioRegistry$ScenarioId
  projections <- lapply(scenarios, function(scenario_id) {
    mfrmr_gtds3t_project_profile(
      scenario_id, contract, semantics_manifest, binding_contract,
      compiler_contract, coverage, validate = FALSE
    )
  })
  profile_rows <- lapply(seq_along(projections), function(index) {
    projection <- projections[[index]]
    summary <- projection$Summary
    data.frame(
      ProjectionOrdinal = index,
      ScenarioId = summary$ScenarioId,
      Crossing = summary$Crossing,
      DesignClass = summary$DesignClass,
      SourceGeneratorComponentCount =
        summary$SourceGeneratorComponentCount,
      TargetEstimandComponentCount =
        summary$TargetEstimandComponentCount,
      SourceAliasPresent = summary$SourceAliasPresent,
      SourceAliasResolved = summary$SourceAliasResolved,
      TargetComponentsPositiveSemidefinite =
        summary$TargetComponentsPositiveSemidefinite,
      LatentResponseCovarianceMaximumError =
        summary$LatentResponseCovarianceMaximumError,
      LatentResponseDistributionPreserved =
        summary$LatentResponseDistributionPreserved,
      AbsoluteErrorCovarianceMaximumError =
        summary$AbsoluteErrorCovarianceMaximumError,
      AbsoluteErrorCovariancePreserved =
        summary$AbsoluteErrorCovariancePreserved,
      RelativeErrorCovarianceRevisionMagnitude =
        summary$RelativeErrorCovarianceRevisionMagnitude,
      RelativeErrorRoleRevised = summary$RelativeErrorRoleRevised,
      TruthRolesIdentifiable = summary$TruthRolesIdentifiable,
      GeneratorPayloadMutationRequired = FALSE,
      CoefficientComputed = FALSE,
      IncidenceAwareAllocationOperatorReady = FALSE,
      ExploratoryExecutionAllowed = FALSE,
      SourceBindingHash = summary$SourceBindingHash,
      ProjectionHash = projection$ProjectionHash,
      stringsAsFactors = FALSE
    )
  })
  profiles <- do.call(rbind, profile_rows)
  component_rows <- list(); mapping_rows <- list()
  component_cursor <- 0L; mapping_cursor <- 0L
  for (index in seq_along(projections)) {
    projection <- projections[[index]]
    registry <- projection$TargetComponentRegistry
    registry$ScenarioId <- projection$ScenarioId
    registry$ProjectionOrdinal <- index
    for (row_index in seq_len(nrow(registry))) {
      component_cursor <- component_cursor + 1L
      component_rows[[component_cursor]] <- data.frame(
        TargetBindingOrdinal = component_cursor,
        registry[row_index, , drop = FALSE],
        stringsAsFactors = FALSE
      )
    }
    mapping <- projection$SourceToTargetMapping
    for (row_index in seq_len(nrow(mapping))) {
      mapping_cursor <- mapping_cursor + 1L
      mapping_rows[[mapping_cursor]] <- data.frame(
        ExpandedMappingOrdinal = mapping_cursor,
        ScenarioId = projection$ScenarioId,
        mapping[row_index, , drop = FALSE],
        stringsAsFactors = FALSE
      )
    }
  }
  components <- do.call(rbind, component_rows)
  mappings <- do.call(rbind, mapping_rows)
  row.names(profiles) <- row.names(components) <- row.names(mappings) <- NULL
  gates <- mfrmr_gtds3t_gate_registry(profiles, components, mappings)
  gaps <- mfrmr_gtds3t_gap_registry()
  summary <- list(
    ProfileCount = nrow(profiles),
    CrossedProfileCount = sum(profiles$DesignClass == "crossed"),
    NestedProfileCount = sum(profiles$DesignClass == "nested"),
    ExpandedMappingCount = nrow(mappings),
    TargetComponentBindingCount = nrow(components),
    AliasResolutionCount = sum(
      profiles$SourceAliasResolved & profiles$DesignClass == "nested"
    ),
    DistributionEquivalentProfileCount = sum(
      profiles$LatentResponseDistributionPreserved
    ),
    AbsoluteErrorPreservedProfileCount = sum(
      profiles$AbsoluteErrorCovariancePreserved
    ),
    IdentifiableTruthProfileCount = sum(profiles$TruthRolesIdentifiable),
    RelativeErrorRevisedProfileCount = sum(
      profiles$DesignClass == "nested" & profiles$RelativeErrorRoleRevised
    ),
    GeneratorPayloadMutationCount = sum(
      profiles$GeneratorPayloadMutationRequired
    ),
    CollapsedSourceComponentsGaussian = collapsed_gaussian,
    CollapsedSourceStreamsDistinct = collapsed_streams_distinct,
    ReadinessGateCount = nrow(gates),
    PassingReadinessGateCount = sum(gates$GatePassed),
    BlockingReadinessGateCount = sum(gates$Blocking),
    OpenGapCount = sum(gaps$GapOpen),
    CurrentDisposition =
      "truth_projection_qualified_operator_and_plan_still_required",
    NextAction = paste(
      "implement and independently oracle-test the incidence-aware",
      "prospective allocation operator before issuing a superseding",
      "unopened plan or fit worker",
      sep = "_"
    ),
    Planned855RngStreamOpened = FALSE,
    ResponseGeneratedByProjection = FALSE,
    GeneratorPayloadRelabeled = FALSE,
    BackendCallMade = FALSE,
    FitReturned = FALSE,
    CoefficientComputed = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE
  )
  payload <- list(
    Contract = contract,
    ParentSemanticsManifestHash = semantics_manifest$ManifestHash,
    ParentGeneratorManifestHash = contract$ParentGeneratorManifestHash,
    ProfileTruthRegistry = profiles,
    TargetComponentBindingRegistry = components,
    ExpandedSourceTargetMappingRegistry = mappings,
    ReadinessGateRegistry = gates,
    OpenGapRegistry = gaps,
    Summary = summary
  )
  structure(c(payload, list(
    ManifestHash = mfrmr_gtds3t_hash(payload)
  )), class = c("mfrmr_gtds3t_manifest", "list"))
}

mfrmr_gtds3t_assert_manifest <- function(
    manifest, contract = mfrmr_gtds3t_contract()) {
  if (!inherits(manifest, "mfrmr_gtds3t_manifest")) {
    stop("A typed D-SIM-3 truth-projection manifest is required.",
         call. = FALSE)
  }
  mfrmr_gtds3t_validate_contract(contract)
  profiles <- manifest$ProfileTruthRegistry
  components <- manifest$TargetComponentBindingRegistry
  mappings <- manifest$ExpandedSourceTargetMappingRegistry
  gates <- manifest$ReadinessGateRegistry
  nested <- profiles$DesignClass == "nested"
  crossed <- profiles$DesignClass == "crossed"
  valid <- identical(manifest$Contract, contract) &&
    identical(manifest$ParentSemanticsManifestHash,
              contract$ParentSemanticsManifestHash) &&
    identical(manifest$ParentGeneratorManifestHash,
              contract$ParentGeneratorManifestHash) &&
    identical(nrow(profiles), 21L) &&
    identical(sum(crossed), 15L) && identical(sum(nested), 6L) &&
    identical(nrow(mappings), 84L) &&
    identical(nrow(components), 78L) &&
    all(profiles$SourceAliasPresent == nested) &&
    all(profiles$SourceAliasResolved) &&
    all(profiles$TargetComponentsPositiveSemidefinite) &&
    all(profiles$LatentResponseDistributionPreserved) &&
    all(profiles$AbsoluteErrorCovariancePreserved) &&
    all(profiles$TruthRolesIdentifiable) &&
    all(profiles$RelativeErrorRoleRevised) &&
    all(profiles$RelativeErrorCovarianceRevisionMagnitude[nested] >
          contract$MatrixTolerance) &&
    all(profiles$RelativeErrorCovarianceRevisionMagnitude[crossed] <=
          contract$MatrixTolerance) &&
    !any(profiles$GeneratorPayloadMutationRequired) &&
    !any(profiles$CoefficientComputed) &&
    !any(profiles$IncidenceAwareAllocationOperatorReady) &&
    !any(profiles$ExploratoryExecutionAllowed) &&
    all(components$PositiveSemidefinite) &&
    all(components$EffectiveSourceSumMaximumError <=
          contract$MatrixTolerance) &&
    all(components$UnitFactorReconstructionMaximumError <=
          contract$MatrixTolerance) &&
    identical(gates$GatePassed,
              c(rep(TRUE, 8L), FALSE, FALSE)) &&
    identical(manifest$Summary$CurrentDisposition,
              "truth_projection_qualified_operator_and_plan_still_required") &&
    !isTRUE(manifest$Summary$Planned855RngStreamOpened) &&
    !isTRUE(manifest$Summary$ResponseGeneratedByProjection) &&
    !isTRUE(manifest$Summary$GeneratorPayloadRelabeled) &&
    isTRUE(manifest$Summary$CollapsedSourceComponentsGaussian) &&
    isTRUE(manifest$Summary$CollapsedSourceStreamsDistinct) &&
    !isTRUE(manifest$Summary$BackendCallMade) &&
    !isTRUE(manifest$Summary$FitReturned) &&
    !isTRUE(manifest$Summary$CoefficientComputed) &&
    !isTRUE(manifest$Summary$ExploratoryExecutionAllowed) &&
    identical(
      manifest$ManifestHash,
      mfrmr_gtds3t_hash(manifest[setdiff(names(manifest), "ManifestHash")])
    )
  if (!valid) {
    stop("The D-SIM-3 truth-projection manifest was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}
