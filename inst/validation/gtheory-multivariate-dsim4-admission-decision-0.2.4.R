# Internal D-SIM-4 admission decision.
#
# This layer decides whether constructing a separate confirmation contract is
# scientifically warranted. It reads the frozen D-SIM-3 descriptive manifest;
# it does not select confirmation scenarios, freeze a replication count, open
# a seed, generate a response, call a backend, or authorize D-SIM-5.

mfrmr_gtds4a_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds_v4_contract",
    "mfrmr_gtds_v4_validate_contract", "mfrmr_gtds3ad_assert_manifest"
  )
  target <- environment(mfrmr_gtds4a_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the v4 capability and D-SIM-3 descriptive chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds4a_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds4a_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM4-ADMISSION-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-31",
    ParentCapabilityContractHash =
      "9b68d194e13625ec73992f314a9494e29c36f77838e0da19a15020f2af74a214",
    ParentDescriptiveContractHash =
      "e274e2a73934a94578b79af347b5643724c56b99490791b693cb2cc12edd98c5",
    ParentDescriptiveManifestHash =
      "ad97f0f48f382bd41c6353dab6ce1405453b6146ce3fd4dfbb4ea04406fb8f8f"
  )
}

mfrmr_gtds4a_contract <- function() {
  mfrmr_gtds4a_require_primitives()
  identity <- mfrmr_gtds4a_identity()
  payload <- c(identity, list(
    DecisionTarget = "construct_separate_dsim4_confirmation_freeze_contract",
    DecisionOutcome = "admit_contract_construction_only",
    RequiredEstimands = c("ABS-PHI", "REL-G"),
    RequiredScenarioRoles = c(
      "boundary", "closure", "full_anchor", "targeted_structural"
    ),
    ExpectedAdmissionCriterionCount = 8L,
    ExpectedFreezeRequirementCount = 14L,
    Dsim3OutcomeRanksMaySelectConfirmationScenarios = FALSE,
    Dsim3LowErrorProfilesMayReceivePreferentialWeight = FALSE,
    Dsim3FailuresAndBoundarySignalsMustRemainVisible = TRUE,
    V4AcceptanceRulesMayBeRelaxed = FALSE,
    EstimandPoolingOrVotingAllowed = FALSE,
    WithinBackendParityCountsAsIndependentReference = FALSE,
    NamedOperationalOwnerRequired = FALSE,
    UserActionConsequenceRequired = FALSE,
    Dsim4ContractConstructionAdmitted = TRUE,
    Dsim4FreezeComplete = FALSE,
    Dsim5ExecutionAuthorized = FALSE,
    PlannedResponseGenerationAllowed = FALSE,
    BackendCallAllowed = FALSE,
    ConfirmationFitAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds4a_hash(payload)
  )), class = c("mfrmr_gtds4a_contract", "list"))
}

mfrmr_gtds4a_validate_contract <- function(
    contract = mfrmr_gtds4a_contract()) {
  canonical <- mfrmr_gtds4a_contract()
  valid <- inherits(contract, "mfrmr_gtds4a_contract") &&
    identical(contract, canonical) &&
    identical(contract$RequiredEstimands, c("ABS-PHI", "REL-G")) &&
    identical(length(contract$RequiredScenarioRoles), 4L) &&
    identical(contract$ExpectedAdmissionCriterionCount, 8L) &&
    identical(contract$ExpectedFreezeRequirementCount, 14L) &&
    !isTRUE(contract$Dsim3OutcomeRanksMaySelectConfirmationScenarios) &&
    !isTRUE(contract$Dsim3LowErrorProfilesMayReceivePreferentialWeight) &&
    isTRUE(contract$Dsim3FailuresAndBoundarySignalsMustRemainVisible) &&
    !isTRUE(contract$V4AcceptanceRulesMayBeRelaxed) &&
    !isTRUE(contract$EstimandPoolingOrVotingAllowed) &&
    !isTRUE(contract$WithinBackendParityCountsAsIndependentReference) &&
    !isTRUE(contract$NamedOperationalOwnerRequired) &&
    !isTRUE(contract$UserActionConsequenceRequired) &&
    isTRUE(contract$Dsim4ContractConstructionAdmitted) &&
    !isTRUE(contract$Dsim4FreezeComplete) &&
    !isTRUE(contract$Dsim5ExecutionAuthorized) &&
    !isTRUE(contract$PlannedResponseGenerationAllowed) &&
    !isTRUE(contract$BackendCallAllowed) &&
    !isTRUE(contract$ConfirmationFitAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The D-SIM-4 admission contract is invalid.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds4a_admission_registry <- function(descriptive_manifest) {
  mfrmr_gtds3ad_assert_manifest(descriptive_manifest)
  summary <- descriptive_manifest$Summary
  estimand <- descriptive_manifest$EstimandRecoverySummaryRegistry
  parity <- descriptive_manifest$WithinBackendParitySummaryRegistry
  satisfied <- c(
    identical(summary$CurrentDisposition,
              "bounded_exploratory_descriptive_recovery_complete_nonconfirmatory"),
    isTRUE(summary$FailureDenominatorPreserved) &&
      identical(summary$DirectTruthScalarCount, 188L) &&
      identical(summary$AvailableDirectTruthScalarCount, 184L),
    !isTRUE(summary$StandardizedBiasComputed) &&
      !isTRUE(summary$IntervalCoverageComputed) &&
      !isTRUE(summary$MonteCarloAcceptanceEvaluated),
    identical(estimand$EstimandId, c("ABS-PHI", "REL-G")),
    all(is.finite(estimand$RootMeanSquaredError)) &&
      max(estimand$MaximumAbsoluteError) > 0,
    all(!parity$IndependentReference),
    !isTRUE(summary$SimulationValidationReady) &&
      !isTRUE(summary$PublicSupportReady),
    identical(summary$FeatureMaturity, "specified")
  )
  data.frame(
    CriterionOrdinal = seq_len(8L),
    CriterionId = c(
      "exploratory_adjudication_complete",
      "denominator_and_failure_integrity",
      "confirmation_question_unresolved",
      "both_package_estimands_retained",
      "nontrivial_finite_sample_signal_preserved",
      "independent_reference_gap_explicit",
      "no_premature_validation_or_support_claim",
      "maturity_boundary_preserved"
    ),
    ScientificMeaning = c(
      "The bounded exploratory study has a final read-only disposition.",
      "Every planned scalar and failed route remains in its denominator.",
      "Bias, coverage, and Monte Carlo acceptance still require new data.",
      "Confirmation cannot collapse ABS-PHI and REL-G into one decision.",
      "Observed regular and boundary behavior is not a trivial exact pass.",
      "Shared-backend route parity cannot substitute for independent evidence.",
      "Exploratory evidence has not been promoted to package support.",
      "Admission changes the work stage, not package maturity."
    ),
    Required = TRUE,
    Satisfied = satisfied,
    OutcomeAdaptiveRevisionAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds4a_freeze_requirement_registry <- function() {
  data.frame(
    RequirementOrdinal = seq_len(14L),
    RequirementId = c(
      "scientific_question", "estimand_scope", "scenario_role_frame",
      "scenario_selection_rule", "regular_interior_acceptance",
      "boundary_and_control_rule", "interval_construction",
      "replication_and_mcse", "independent_reference_overlap",
      "source_and_environment_identity", "new_seed_namespace",
      "attempt_and_failure_accounting", "resource_reporting",
      "post_freeze_change_control"
    ),
    RequiredBinding = c(
      "Recovery, interval coverage, and fail-closed behavior are separate questions.",
      "ABS-PHI and REL-G remain separate nonvoting estimands.",
      "Boundary, closure, full-anchor, and targeted-structural roles all remain represented.",
      "Coverage structure, not D-SIM-3 error rank, selects the confirmation subset.",
      "Inherit v4 standardized-bias and coverage rules unchanged for regular interiors.",
      "Boundary and control cells use structural fail-closed and accounting criteria, not regular bias thresholds.",
      "Freeze the interval method and nominal level before any new response.",
      "Derive an exact replication count from a declared worst-case MCSE target.",
      "Name an actually independent formula or implementation and its overlap; shared-backend parity is insufficient.",
      "Bind content-addressed package source, dependency, platform, and implementation identities without an operational-owner gate.",
      "Use a disjoint, unopened, deterministic seed namespace with an exact formula.",
      "Give every attempt one terminal state; prohibit replacement seeds, success replenishment, and post-outcome exclusion.",
      "Report runtime and peak memory descriptively without turning capacity into an enablement gate.",
      "Any estimator, generator, truth, interval, or routing change invalidates the freeze and requires a new contract version."
    ),
    BindingSource = c(
      "D-SIM-4", "v4_inherited", "D-SIM-4", "D-SIM-4",
      "v4_inherited", "v4_inherited_plus_D-SIM-4", "D-SIM-4",
      "D-SIM-4", "D-SIM-4", "D-SIM-4", "D-SIM-4",
      "v4_inherited", "v4_inherited", "D-SIM-4"
    ),
    MustBeFrozenBeforeDsim5 = TRUE,
    FrozenByThisAdmission = FALSE,
    ResultAdaptiveRevisionAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds4a_evidence_snapshot <- function(descriptive_manifest) {
  estimand <- descriptive_manifest$EstimandRecoverySummaryRegistry
  profile <- descriptive_manifest$ProfileRecoverySummaryRegistry
  parity <- descriptive_manifest$WithinBackendParitySummaryRegistry
  data.frame(
    EvidenceId = c(
      "direct_truth_denominator", "abs_phi_recovery", "rel_g_recovery",
      "largest_boundary_error", "within_backend_parity",
      "monte_carlo_acceptance", "package_maturity"
    ),
    Value = c(
      paste0(descriptive_manifest$Summary$AvailableDirectTruthScalarCount,
             "/", descriptive_manifest$Summary$DirectTruthScalarCount),
      sprintf("RMSE=%.8f", estimand$RootMeanSquaredError[
        estimand$EstimandId == "ABS-PHI"
      ]),
      sprintf("RMSE=%.8f", estimand$RootMeanSquaredError[
        estimand$EstimandId == "REL-G"
      ]),
      sprintf("%s:%.7f", profile$ScenarioId[
        which.max(profile$MaximumAbsoluteError)
      ], max(profile$MaximumAbsoluteError)),
      paste0(sum(parity$AvailableComparisonCount), "/",
             sum(parity$PlannedComparisonCount), ":not_independent"),
      "not_evaluated_two_replicates_per_scenario",
      descriptive_manifest$Summary$FeatureMaturity
    ),
    DecisionUse = c(
      "preserve", "question_not_acceptance", "question_not_acceptance",
      "retain_boundary_role_not_scenario_rank", "independent_gap",
      "requires_separate_confirmation", "do_not_promote"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds4a_canonical_code <- function(value) {
  paste(deparse(value, width.cutoff = 500L, control = "all"),
        collapse = "\n")
}

mfrmr_gtds4a_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds4a_require_primitives", "mfrmr_gtds4a_hash",
    "mfrmr_gtds4a_identity", "mfrmr_gtds4a_contract",
    "mfrmr_gtds4a_validate_contract", "mfrmr_gtds4a_admission_registry",
    "mfrmr_gtds4a_freeze_requirement_registry",
    "mfrmr_gtds4a_evidence_snapshot", "mfrmr_gtds4a_canonical_code",
    "mfrmr_gtds4a_implementation_identity", "mfrmr_gtds4a_manifest_fields",
    "mfrmr_gtds4a_manifest", "mfrmr_gtds4a_assert_manifest"
  )
  target <- environment(mfrmr_gtds4a_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions), FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds4a_hash(list(
        Formals = mfrmr_gtds4a_canonical_code(formals(fun)),
        Body = mfrmr_gtds4a_canonical_code(body(fun))
      ))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds4a_manifest_fields <- function() {
  c(
    "Contract", "ParentDescriptiveManifestHash",
    "AdmissionCriterionRegistry", "FreezeRequirementRegistry",
    "ExploratoryEvidenceSnapshot", "ImplementationIdentity", "Summary"
  )
}

mfrmr_gtds4a_manifest <- function(
    descriptive_manifest, contract = mfrmr_gtds4a_contract()) {
  mfrmr_gtds4a_validate_contract(contract)
  mfrmr_gtds3ad_assert_manifest(descriptive_manifest)
  if (!identical(descriptive_manifest$Contract$ContractHash,
                 contract$ParentDescriptiveContractHash) ||
      !identical(descriptive_manifest$ManifestHash,
                 contract$ParentDescriptiveManifestHash)) {
    stop("The D-SIM-3 descriptive identity changed.", call. = FALSE)
  }
  capability <- mfrmr_gtds_v4_contract()
  mfrmr_gtds_v4_validate_contract(capability)
  if (!identical(capability$ContractHash,
                 contract$ParentCapabilityContractHash)) {
    stop("The v4 capability identity changed.", call. = FALSE)
  }
  criteria <- mfrmr_gtds4a_admission_registry(descriptive_manifest)
  freeze <- mfrmr_gtds4a_freeze_requirement_registry()
  evidence <- mfrmr_gtds4a_evidence_snapshot(descriptive_manifest)
  summary <- list(
    AdmissionCriterionCount = nrow(criteria),
    AdmissionCriterionSatisfiedCount = sum(criteria$Satisfied),
    FreezeRequirementCount = nrow(freeze),
    FreezeRequirementFrozenCount = sum(freeze$FrozenByThisAdmission),
    DecisionOutcome = "admit_contract_construction_only",
    ScientificRationale = paste(
      "Confirmation addresses unresolved package-level recovery and interval",
      "validity; it is not an operational enablement decision."
    ),
    LocalScenarioOptimizationAuthorized = FALSE,
    ConfirmationContractConstructionAdmitted = all(criteria$Satisfied),
    ConfirmationContractFrozen = FALSE,
    PlannedResponseGenerationAllowed = FALSE,
    Dsim5ExecutionAuthorized = FALSE,
    SimulationValidationReady = FALSE,
    ReferenceValidationReady = FALSE,
    PublicSupportReady = FALSE,
    FeatureMaturity = "specified",
    CurrentDisposition =
      "dsim4_contract_construction_admitted_execution_closed",
    NextAction = paste(
      "freeze one role-complete, outcome-independent D-SIM-4 contract;",
      "do not run D-SIM-5 until every freeze requirement is exact"
    )
  )
  payload <- list(
    Contract = contract,
    ParentDescriptiveManifestHash = descriptive_manifest$ManifestHash,
    AdmissionCriterionRegistry = criteria,
    FreezeRequirementRegistry = freeze,
    ExploratoryEvidenceSnapshot = evidence,
    ImplementationIdentity = mfrmr_gtds4a_implementation_identity(),
    Summary = summary
  )
  manifest <- structure(c(payload, list(
    ManifestHash = mfrmr_gtds4a_hash(payload)
  )), class = c("mfrmr_gtds4a_manifest", "list"))
  mfrmr_gtds4a_assert_manifest(manifest)
  manifest
}

mfrmr_gtds4a_assert_manifest <- function(manifest) {
  fields <- mfrmr_gtds4a_manifest_fields()
  if (!inherits(manifest, "mfrmr_gtds4a_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed D-SIM-4 admission manifest is required.", call. = FALSE)
  }
  contract <- manifest$Contract
  criteria <- manifest$AdmissionCriterionRegistry
  freeze <- manifest$FreezeRequirementRegistry
  evidence <- manifest$ExploratoryEvidenceSnapshot
  summary <- manifest$Summary
  valid <- identical(
    manifest$ManifestHash, mfrmr_gtds4a_hash(manifest[fields])
  ) && identical(contract, mfrmr_gtds4a_contract()) &&
    identical(manifest$ParentDescriptiveManifestHash,
              contract$ParentDescriptiveManifestHash) &&
    identical(manifest$ImplementationIdentity,
              mfrmr_gtds4a_implementation_identity()) &&
    identical(nrow(criteria), 8L) && all(criteria$Required) &&
    all(criteria$Satisfied) &&
    all(!criteria$OutcomeAdaptiveRevisionAllowed) &&
    identical(nrow(freeze), 14L) &&
    all(freeze$MustBeFrozenBeforeDsim5) &&
    all(!freeze$FrozenByThisAdmission) &&
    all(!freeze$ResultAdaptiveRevisionAllowed) &&
    identical(nrow(evidence), 7L) &&
    identical(evidence$Value[[1L]], "184/188") &&
    identical(evidence$Value[[2L]], "RMSE=0.05240607") &&
    identical(evidence$Value[[3L]], "RMSE=0.05008863") &&
    identical(evidence$Value[[4L]], "D3-S010:0.3240437") &&
    identical(evidence$Value[[5L]], "40/40:not_independent") &&
    identical(summary$AdmissionCriterionCount, 8L) &&
    identical(summary$AdmissionCriterionSatisfiedCount, 8L) &&
    identical(summary$FreezeRequirementCount, 14L) &&
    identical(summary$FreezeRequirementFrozenCount, 0L) &&
    identical(summary$DecisionOutcome,
              "admit_contract_construction_only") &&
    !isTRUE(summary$LocalScenarioOptimizationAuthorized) &&
    isTRUE(summary$ConfirmationContractConstructionAdmitted) &&
    !isTRUE(summary$ConfirmationContractFrozen) &&
    !isTRUE(summary$PlannedResponseGenerationAllowed) &&
    !isTRUE(summary$Dsim5ExecutionAuthorized) &&
    !isTRUE(summary$SimulationValidationReady) &&
    !isTRUE(summary$ReferenceValidationReady) &&
    !isTRUE(summary$PublicSupportReady) &&
    identical(summary$FeatureMaturity, "specified") &&
    identical(
      summary$CurrentDisposition,
      "dsim4_contract_construction_admitted_execution_closed"
    )
  if (!valid) {
    stop("The D-SIM-4 admission manifest was altered.", call. = FALSE)
  }
  invisible(TRUE)
}
