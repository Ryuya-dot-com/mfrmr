# Internal D-SIM-0 v4 package-capability contract.
#
# V4 supersedes the v3 operational-owner admission path.  An R package does
# not own the downstream decision context: it owns estimand semantics,
# supported-design declarations, numerical behavior, diagnostics, and support
# claims.  Both Phi and G therefore enter the validation multiverse.  This
# contract generates no data, opens no planned seed, and promotes no public
# feature by itself.

mfrmr_gtds_v4_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The D-SIM-0 v4 contract requires the `digest` package.",
         call. = FALSE)
  }
  digest::digest(
    value, algo = "sha256", serialize = TRUE, serializeVersion = 3L
  )
}

mfrmr_gtds_v4_estimand_registry <- function() {
  data.frame(
    EstimandOrdinal = 1:2,
    EstimandId = c("ABS-PHI", "REL-G"),
    Coefficient = c("Phi", "G"),
    ScientificMeaning = c(
      "absolute_score_dependability_not_cut_score_classification",
      "relative_rank_order_dependability"
    ),
    ErrorVarianceRole = c(
      "relative_error_plus_absolute_facet_main_effects",
      "relative_error_excluding_absolute_facet_main_effects"
    ),
    IncludedInValidationMultiverse = TRUE,
    UserSelectsSubstantiveInterpretation = TRUE,
    UniversalTargetSuppliedByPackage = FALSE,
    OperationalOwnerRequiredForPackageValidation = FALSE,
    CrossEstimandPoolingAllowed = FALSE,
    CrossEstimandVotingAllowed = FALSE,
    PublicSupportReady = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v4_responsibility_registry <- function() {
  data.frame(
    ResponsibilityOrdinal = 1:10,
    ResponsibilityId = c(
      "estimand_definition", "design_grammar", "numerical_validation",
      "failure_diagnostics", "support_claim",
      "analysis_design_declaration", "coefficient_interpretation",
      "substantive_target", "action_consequence", "project_preregistration"
    ),
    AccountableLayer = c(
      rep("mfrmr_package", 5L), rep("package_user", 4L),
      "analysis_project_optional_protocol"
    ),
    PackageProvides = c(
      "formula_and_error_partition",
      "machine_checkable_supported_and_unsupported_design_identity",
      "deterministic_oracle_simulation_and_reference_checks",
      "convergence_boundary_identification_and_attempt_accounting",
      "evidence_bounded_maturity_label",
      "validated_input_schema",
      "separate_G_and_Phi_outputs_with_nonprescriptive_documentation",
      "no_universal_threshold",
      "no_embedded_action_policy",
      "reusable_contract_and_provenance_fields"
    ),
    BlocksPackageDsim0 = c(rep(TRUE, 5L), rep(FALSE, 5L)),
    OperationalOwnerEvidenceRequired = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v4_multiverse_axis_registry <- function() {
  rows <- list(
    c("estimand", "ABS-PHI", "all", "absolute coefficient family"),
    c("estimand", "REL-G", "all", "relative coefficient family"),
    c("stratum_count", "one", "closure", "univariate reduction oracle"),
    c("stratum_count", "two", "all", "minimum multivariate design"),
    c("stratum_count", "three", "all", "higher-order covariance design"),
    c("condition_sharing", "disjoint", "all", "conditions differ by stratum"),
    c("condition_sharing", "identical", "all", "conditions shared by stratum"),
    c("condition_sharing", "partial_explicit", "targeted", "explicit mixed incidence"),
    c("observation_event", "distinct", "all", "one event per stratum score"),
    c("observation_event", "one_event_multiple_scores", "targeted", "linked stratum residuals"),
    c("observation_event", "mixed_explicit", "targeted", "explicit event map"),
    c("crossing", "fully_crossed", "all", "complete crossing"),
    c("crossing", "nested", "targeted", "declared nesting"),
    c("crossing", "partially_crossed", "targeted", "connected incomplete crossing"),
    c("balance", "balanced", "all", "equal cell exposure"),
    c("balance", "moderately_unbalanced", "pairwise", "nonuniform exposure"),
    c("balance", "severely_unbalanced", "boundary", "information stress"),
    c("missingness", "none", "all", "complete registered observations"),
    c("missingness", "mcar_10", "pairwise", "ten percent MCAR"),
    c("missingness", "mcar_30", "boundary", "thirty percent MCAR"),
    c("missingness", "structural", "targeted", "design-induced absence"),
    c("object_count", "50", "boundary", "small sample"),
    c("object_count", "200", "all", "reference sample"),
    c("object_count", "1000", "pairwise", "large sample"),
    c("rater_count", "2", "boundary", "weak rater information"),
    c("rater_count", "4", "all", "reference allocation"),
    c("rater_count", "8", "pairwise", "high rater information"),
    c("repeat_count", "1", "all", "single rating event"),
    c("repeat_count", "2", "all", "replicated rating event"),
    c("variance_regime", "regular_interior", "all", "identified interior"),
    c("variance_regime", "near_zero_component", "boundary", "boundary variance"),
    c("variance_regime", "dominant_component", "boundary", "variance imbalance"),
    c("variance_regime", "near_singular_covariance", "boundary", "PSD rank stress"),
    c("cross_stratum_covariance", "zero", "all", "independent strata component"),
    c("cross_stratum_covariance", "positive_psd", "all", "positive linked component"),
    c("cross_stratum_covariance", "negative_psd", "targeted", "negative but PSD-valid component"),
    c("response_distribution", "gaussian", "all", "reference continuous score"),
    c("response_distribution", "heavy_tailed", "pairwise", "distributional stress"),
    c("response_distribution", "ordinal_aggregate", "targeted", "derived bounded score stress"),
    c("analysis_route", "multivariate_reml_glmmtmb", "all", "conditional general candidate"),
    c("analysis_route", "multivariate_ml_glmmtmb", "pairwise", "estimator sensitivity"),
    c("analysis_route", "multivariate_lme4_restricted", "targeted", "design-qualified sensitivity"),
    c("analysis_route", "separate_univariate", "all", "nonpooling comparator"),
    c("analysis_route", "naive_pooling_negative_control", "negative_control", "deliberately invalid comparator")
  )
  value <- as.data.frame(do.call(rbind, rows), stringsAsFactors = FALSE)
  names(value) <- c("AxisId", "LevelId", "CoverageRole", "Meaning")
  value$AxisOrdinal <- match(value$AxisId, unique(value$AxisId))
  value$LevelOrdinal <- ave(
    seq_len(nrow(value)), value$AxisId, FUN = seq_along
  )
  value$OutcomeAdaptiveSelectionAllowed <- FALSE
  value$RequiresValidDesignBinding <- value$AxisId %in% c(
    "condition_sharing", "observation_event", "crossing", "missingness",
    "analysis_route"
  )
  value[c(
    "AxisOrdinal", "AxisId", "LevelOrdinal", "LevelId", "CoverageRole",
    "Meaning", "OutcomeAdaptiveSelectionAllowed", "RequiresValidDesignBinding"
  )]
}

mfrmr_gtds_v4_acceptance_registry <- function() {
  data.frame(
    CriterionOrdinal = 1:10,
    CriterionId = c(
      "deterministic_algebra", "univariate_closure", "label_invariance",
      "psd_validity", "estimand_bias", "interval_coverage",
      "matched_route_parity", "structural_negative_control",
      "attempt_accounting", "resource_envelope"
    ),
    EvidenceClass = c(
      rep("deterministic", 4L), rep("monte_carlo", 2L),
      "reference_implementation", "negative_control", "safety", "descriptive"
    ),
    AcceptanceRule = c(
      "absolute_error_le_1e-10",
      "one_stratum_result_matches_public_univariate_formula_within_1e-10",
      "permitted_row_level_and_stratum_relabeling_changes_no_coefficient_beyond_1e-10",
      "generated_and_estimated_covariance_eigenvalues_ge_minus_1e-8_or_fail_closed",
      "absolute_standardized_bias_le_0.05_plus_two_MCSE",
      "absolute_empirical_coverage_minus_0.95_le_0.03_plus_two_MCSE",
      "matched_design_coefficient_difference_le_1e-6",
      "unsupported_or_nonidentified_design_never_returns_support_ready",
      "every_attempt_has_exactly_one_terminal_state_and_enters_denominator",
      "runtime_and_peak_memory_reported_without_post_outcome_exclusion"
    ),
    AppliesToRegularInterior = c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE),
    AppliesToBoundaryOrControl = c(TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE),
    RequiredForSimulationValidated = c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE),
    RequiredForReferenceValidated = c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE),
    OperationalConsequenceRequired = FALSE,
    OutcomeAdaptiveRevisionAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v4_maturity_registry <- function() {
  data.frame(
    MaturityOrdinal = 1:5,
    MaturityId = c(
      "specified", "implemented", "simulation_validated",
      "reference_validated", "stable"
    ),
    RequiredEvidence = c(
      "estimand_design_and_acceptance_contract",
      "executable_code_and_deterministic_unit_oracles",
      "versioned_multiverse_meets_simulation_acceptance_registry",
      "independent_formula_or_external_implementation_agrees_on_registered_overlap",
      "simulation_and_reference_validation_plus_documented_limits_and_regression_protection"
    ),
    Current = c(TRUE, FALSE, FALSE, FALSE, FALSE),
    RequiresNamedOperationalOwner = FALSE,
    RequiresUserActionConsequence = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v4_stage_registry <- function() {
  data.frame(
    StageOrdinal = 0:6,
    StageId = paste0("D-SIM-", 0:6),
    Purpose = c(
      "freeze_package_capability_scope_axes_and_acceptance_rules",
      "complete_deterministic_oracles_and_design_qualification",
      "run_nonreserved_generator_fit_metric_smoke",
      "run_exploratory_design_multiverse_without_support_promotion",
      "freeze_confirmation_subset_replications_source_and_seed_identity",
      "run_confirmation_with_complete_attempt_accounting",
      "assign_evidence_bounded_package_maturity"
    ),
    CurrentStatus = c(
      "complete", "next", rep("blocked_by_predecessor", 5L)
    ),
    RequiresOperationalOwnerEvidence = FALSE,
    AllowsPlannedResponseGeneration = c(rep(FALSE, 3L), TRUE, FALSE, TRUE, FALSE),
    AllowsPublicSupportPromotion = c(rep(FALSE, 6L), TRUE),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v4_implementation_identity <- function() {
  ids <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds_v4_estimand_registry",
    "mfrmr_gtds_v4_responsibility_registry",
    "mfrmr_gtds_v4_multiverse_axis_registry",
    "mfrmr_gtds_v4_acceptance_registry",
    "mfrmr_gtds_v4_maturity_registry", "mfrmr_gtds_v4_stage_registry",
    "mfrmr_gtds_v4_implementation_identity", "mfrmr_gtds_v4_contract",
    "mfrmr_gtds_v4_validate_contract", "mfrmr_gtds_v4_adjudicate"
  )
  function_environment <- environment(mfrmr_gtds_v4_implementation_identity)
  bodies <- lapply(ids, function(id) {
    if (!exists(id, envir = function_environment, mode = "function",
                inherits = TRUE)) {
      stop(paste("Missing D-SIM-0 v4 function:", id), call. = FALSE)
    }
    deparse(body(get(id, envir = function_environment, inherits = TRUE)),
            width.cutoff = 500L)
  })
  names(bodies) <- ids
  mfrmr_gtds_v4_hash(bodies)
}

mfrmr_gtds_v4_contract <- function() {
  payload <- list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM0-CAPABILITY-V4",
    ContractVersion = "4.0.0",
    ContractDate = "2026-08-30",
    SupersedesActivationPath =
      "MFRMR-GTHEORY-MV-DSIM0-MULTIVERSE-V3-owner-admission",
    Scope = "package_capability_validation_not_downstream_action_policy",
    Estimands = mfrmr_gtds_v4_estimand_registry(),
    Responsibilities = mfrmr_gtds_v4_responsibility_registry(),
    MultiverseAxes = mfrmr_gtds_v4_multiverse_axis_registry(),
    AcceptanceCriteria = mfrmr_gtds_v4_acceptance_registry(),
    Maturity = mfrmr_gtds_v4_maturity_registry(),
    Stages = mfrmr_gtds_v4_stage_registry(),
    OperationalOwnerGateRequired = FALSE,
    UserDecisionContextPartOfPackageContract = FALSE,
    Dsim0Satisfied = TRUE,
    Dsim1Allowed = TRUE,
    ExploratorySimulationAllowed = FALSE,
    ConfirmationSimulationAllowed = FALSE,
    PlannedSeedAccessAllowed = FALSE,
    PublicSupportReady = FALSE,
    ImplementationIdentityHash = mfrmr_gtds_v4_implementation_identity()
  )
  structure(
    c(payload, list(ContractHash = mfrmr_gtds_v4_hash(payload))),
    class = c("mfrmr_gtds_v4_contract", "list")
  )
}

mfrmr_gtds_v4_validate_contract <- function(contract =
                                               mfrmr_gtds_v4_contract()) {
  expected_names <- c(
    "ContractId", "ContractVersion", "ContractDate",
    "SupersedesActivationPath", "Scope", "Estimands", "Responsibilities",
    "MultiverseAxes", "AcceptanceCriteria", "Maturity", "Stages",
    "OperationalOwnerGateRequired", "UserDecisionContextPartOfPackageContract",
    "Dsim0Satisfied", "Dsim1Allowed", "ExploratorySimulationAllowed",
    "ConfirmationSimulationAllowed", "PlannedSeedAccessAllowed",
    "PublicSupportReady", "ImplementationIdentityHash", "ContractHash"
  )
  if (!is.list(contract) || !identical(names(contract), expected_names)) {
    stop("The D-SIM-0 v4 contract has an invalid top-level schema.",
         call. = FALSE)
  }
  payload <- unclass(contract)[setdiff(names(contract), "ContractHash")]
  hash_valid <- identical(contract$ContractHash, mfrmr_gtds_v4_hash(payload))
  estimands_valid <- is.data.frame(contract$Estimands) &&
    identical(contract$Estimands$EstimandId, c("ABS-PHI", "REL-G")) &&
    all(contract$Estimands$IncludedInValidationMultiverse) &&
    all(contract$Estimands$UserSelectsSubstantiveInterpretation) &&
    all(!contract$Estimands$UniversalTargetSuppliedByPackage) &&
    all(!contract$Estimands$OperationalOwnerRequiredForPackageValidation) &&
    all(!contract$Estimands$CrossEstimandPoolingAllowed) &&
    all(!contract$Estimands$CrossEstimandVotingAllowed)
  responsibility_valid <- is.data.frame(contract$Responsibilities) &&
    all(contract$Responsibilities$OperationalOwnerEvidenceRequired == FALSE) &&
    identical(
      contract$Responsibilities$BlocksPackageDsim0,
      c(rep(TRUE, 5L), rep(FALSE, 5L))
    )
  axes_valid <- is.data.frame(contract$MultiverseAxes) &&
    all(c(
      "estimand", "stratum_count", "condition_sharing",
      "observation_event", "crossing", "balance", "missingness",
      "object_count", "rater_count", "repeat_count", "variance_regime",
      "cross_stratum_covariance", "response_distribution", "analysis_route"
    ) %in% contract$MultiverseAxes$AxisId) &&
    all(!contract$MultiverseAxes$OutcomeAdaptiveSelectionAllowed)
  criteria_valid <- is.data.frame(contract$AcceptanceCriteria) &&
    identical(nrow(contract$AcceptanceCriteria), 10L) &&
    all(nzchar(contract$AcceptanceCriteria$AcceptanceRule)) &&
    all(!contract$AcceptanceCriteria$OperationalConsequenceRequired) &&
    all(!contract$AcceptanceCriteria$OutcomeAdaptiveRevisionAllowed)
  maturity_valid <- is.data.frame(contract$Maturity) &&
    identical(
      contract$Maturity$MaturityId,
      c("specified", "implemented", "simulation_validated",
        "reference_validated", "stable")
    ) && identical(contract$Maturity$Current,
                   c(TRUE, FALSE, FALSE, FALSE, FALSE)) &&
    all(!contract$Maturity$RequiresNamedOperationalOwner) &&
    all(!contract$Maturity$RequiresUserActionConsequence)
  stage_valid <- is.data.frame(contract$Stages) &&
    identical(contract$Stages$StageId, paste0("D-SIM-", 0:6)) &&
    identical(contract$Stages$CurrentStatus,
              c("complete", "next", rep("blocked_by_predecessor", 5L))) &&
    all(!contract$Stages$RequiresOperationalOwnerEvidence)
  flags_valid <-
    identical(contract$OperationalOwnerGateRequired, FALSE) &&
    identical(contract$UserDecisionContextPartOfPackageContract, FALSE) &&
    identical(contract$Dsim0Satisfied, TRUE) &&
    identical(contract$Dsim1Allowed, TRUE) &&
    identical(contract$ExploratorySimulationAllowed, FALSE) &&
    identical(contract$ConfirmationSimulationAllowed, FALSE) &&
    identical(contract$PlannedSeedAccessAllowed, FALSE) &&
    identical(contract$PublicSupportReady, FALSE)
  identity_valid <- identical(
    contract$ImplementationIdentityHash,
    mfrmr_gtds_v4_implementation_identity()
  )
  if (!all(c(
    hash_valid, estimands_valid, responsibility_valid, axes_valid,
    criteria_valid, maturity_valid, stage_valid, flags_valid, identity_valid
  ))) {
    stop("The D-SIM-0 v4 package-capability contract is invalid.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds_v4_adjudicate <- function(contract = mfrmr_gtds_v4_contract()) {
  mfrmr_gtds_v4_validate_contract(contract)
  summary <- data.frame(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    GateStatus = "dsim0_package_scope_complete_dsim1_allowed",
    IncludedEstimandCount = sum(
      contract$Estimands$IncludedInValidationMultiverse
    ),
    OperationalOwnerGateRequired = FALSE,
    Dsim0Satisfied = TRUE,
    Dsim1Allowed = TRUE,
    ExploratorySimulationAllowed = FALSE,
    ConfirmationSimulationAllowed = FALSE,
    PlannedSeedAccessAllowed = FALSE,
    PublicSupportReady = FALSE,
    NextAction = paste(
      "complete D-SIM-1 deterministic algebra, univariate closure,",
      "PSD, incidence, observation-event, and backend-eligibility oracles"
    ),
    stringsAsFactors = FALSE
  )
  result <- list(
    Summary = summary,
    Estimands = contract$Estimands,
    Responsibilities = contract$Responsibilities,
    Stages = contract$Stages
  )
  class(result) <- c("mfrmr_gtds_v4_adjudication", "list")
  result
}
