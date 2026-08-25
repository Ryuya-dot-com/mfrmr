# 0.2.4 fixed-calibration amended G4 current-source contract.
#
# This repository-only file freezes the current-source confirmation design,
# semantic identities, complete boundary denominator, numerical rules,
# candidate-binding requirements, platform cells, and resource ceilings. It
# deliberately executes no fit, score, replay, checkpoint, persistence,
# benchmark, package build, or subprocess.

mfrmr_fc_g4_current_specification <-
  "0.2.4-fixed-calibration-g4-current-source-boundary-evidence-v4"
mfrmr_fc_g4_current_contract <-
  "mfrmr_fixed_calibration_g4_current_source_evidence_v4"

mfrmr_fc_g4_current_scoring_identity <- function() {
  data.frame(
    Field = c(
      "ScoringAlgorithm", "PriorFamily", "PriorMean", "PriorSD",
      "QuadratureRule", "DefaultScoringQuadratureOrder",
      "MinimumScoringQuadratureOrder", "HistoricalControlQuadratureOrder",
      "OneNodeSourceFitQuadratureOrder"
    ),
    Value = c(
      "quadrature_eap_v1", "normal", "0", "1",
      "gauss_hermite_standard_normal_golub_welsch_v1", "31", "2", "9",
      "1"
    ),
    SemanticIdentityComponent = c(
      TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE
    ),
    FrozenBeforeCurrentExecution = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4_current_confirmation_design <- function() {
  data.frame(
    Family = rep(c("RSM", "PCM"), 3L),
    EvidenceRole = rep(c(
      "current_default31_confirmation",
      "one_node_source_fit_adversary",
      "historical_explicit9_regression_control"
    ), each = 2L),
    CalibrationId = c(
      "fc-g4-current-rsm-default31-024-f",
      "fc-g4-current-pcm-default31-024-f",
      "fc-g4-current-rsm-source1-024-g",
      "fc-g4-current-pcm-source1-024-g",
      "fc-g4-confirmation-rsm-024-a",
      "fc-g4-confirmation-pcm-024-a"
    ),
    SourceFixtureId = c(
      "fc-g4-current-source-rsm-mod1031-offset227",
      "fc-g4-current-source-pcm-mod1031-offset227",
      "fc-g4-current-source1-rsm-mod1033-offset389",
      "fc-g4-current-source1-pcm-mod1033-offset389",
      "fc-g4-source-rsm-mod997-offset000",
      "fc-g4-source-pcm-mod997-offset000"
    ),
    ConfirmationFixtureId = c(
      "fc-g4-current-confirm-rsm-mod1031-offset887",
      "fc-g4-current-confirm-pcm-mod1031-offset887",
      "fc-g4-current-confirm-source1-rsm-mod1033-offset941",
      "fc-g4-current-confirm-source1-pcm-mod1033-offset941",
      "fc-g4-confirm-rsm-mod997-offset401",
      "fc-g4-confirm-pcm-mod997-offset401"
    ),
    SourcePersons = c(56L, 56L, 48L, 48L, 48L, 48L),
    ConfirmationPersons = c(10L, 10L, 8L, 8L, 7L, 7L),
    Raters = 4L,
    Criteria = 3L,
    Categories = 4L,
    FitQuadratureOrder = c(13L, 13L, 1L, 1L, 9L, 9L),
    ScoringQuadratureOrder = c(31L, 31L, 31L, 31L, 9L, 9L),
    GeneratorIdentity = c(
      rep("closed-form-logits-mod1031-v1-no-r-rng", 2L),
      rep("closed-form-logits-mod1033-v1-no-r-rng", 2L),
      rep("historical-closed-form-logits-mod997-v1-no-r-rng", 2L)
    ),
    PreviouslyUsedFixture = c(FALSE, FALSE, FALSE, FALSE, TRUE, TRUE),
    CurrentExecutionOpened = FALSE,
    DisjointCurrentConfirmationAuthority = c(
      TRUE, TRUE, TRUE, TRUE, FALSE, FALSE
    ),
    ControlMayAuthorizeCurrentG4 = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4_current_numerical_rules <- function() {
  data.frame(
    RuleId = c(
      "PROBABILITY_ABSOLUTE", "POSTERIOR_DEFAULT31_ABSOLUTE",
      "POSTERIOR_EXPLICIT9_CONTROL_ABSOLUTE",
      "SOURCE1_POSTERIOR_ABSOLUTE", "NONDEGENERATE_POSTERIOR_SD",
      "METAMORPHIC_ABSOLUTE", "RANK_EXACT", "PLATFORM_SCORE_ABSOLUTE",
      "CHECKPOINT_PARAMETER_ABSOLUTE", "CHECKPOINT_LOGLIK_ABSOLUTE",
      "PRIOR_SENSITIVITY_REVIEW"
    ),
    Metric = c(
      "maximum absolute category-probability difference",
      "maximum absolute default-31 EAP/SD/interval difference",
      "maximum absolute explicit-nine EAP/SD/interval difference",
      "maximum absolute source-one/default-31 EAP/SD/interval difference",
      "minimum posterior SD under source-one/default-31 scoring",
      "maximum absolute EAP/SD/interval difference",
      "integer rank and explicit Jacobian entries",
      "maximum absolute EAP/SD/interval difference",
      "maximum absolute resumed-versus-uninterrupted parameter difference",
      "absolute resumed-versus-uninterrupted log-likelihood difference",
      "maximum absolute EAP change under N(0,0.7) or N(0,1.5)"
    ),
    Threshold = c(
      2e-14, 5e-14, 5e-14, 5e-14, 1e-10, 5e-14, 0, 1e-12,
      1e-10, 1e-10, 0.20
    ),
    Comparison = c(
      rep("less_than_or_equal", 4L), "greater_than",
      rep("less_than_or_equal", 5L), "review_if_greater_or_equal"
    ),
    RuleFrozenBeforeCurrentExecution = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4_current_denominator <- function() {
  cell_id <- c(
    "RSM_DEFAULT31_PROBABILITY_ORACLE",
    "PCM_DEFAULT31_PROBABILITY_ORACLE",
    "RSM_DEFAULT31_POSTERIOR_ORACLE",
    "PCM_DEFAULT31_POSTERIOR_ORACLE",
    "RSM_EXPLICIT9_HISTORICAL_CONTROL",
    "PCM_EXPLICIT9_HISTORICAL_CONTROL",
    "RSM_SOURCE1_DEFAULT31_POSTERIOR_ORACLE",
    "PCM_SOURCE1_DEFAULT31_POSTERIOR_ORACLE",
    "RSM_STEP_RANK_ORACLE", "PCM_STEP_RANK_ORACLE",
    "SCORING_ALGORITHM_MUTATION_REFUSAL",
    "QUADRATURE_ORDER_MUTATION_REFUSAL",
    "QUADRATURE_NODE_MUTATION_REFUSAL",
    "SIGN_MUTATION_REFUSAL", "COHERENT_SIGN_METAMORPHIC",
    "CATEGORY_MAP_MUTATION_REFUSAL", "EXTERNAL_SCORE_REVERSAL",
    "NAMESPACE_RECODING", "ROW_ORDER", "PERSON_CHUNK_ORDER",
    "C_COLLATION", "UTF8_RDS_ROUNDTRIP", "FRESH_VANILLA_PROCESS",
    "PRIOR_MUTATION_REFUSAL", "PRIOR_SENSITIVITY_ORACLE",
    "CORRUPT_COORDINATE_LOAD_REFUSAL",
    "ARTIFACT_NONFINITE_WEIGHT_REFUSAL",
    "ARTIFACT_NONPOSITIVE_WEIGHT_REFUSAL",
    "JML_SOURCE1_DEFAULT31_NONDEGENERATE",
    "EXPLICIT_SCORING_ONE_REFUSAL", "FITTED_NONREADY_DEFAULT_REFUSAL",
    "FITTED_NONREADY_REVIEW_LABEL",
    "FITTED_NONFINITE_WEIGHT_REFUSAL",
    "FITTED_NONPOSITIVE_WEIGHT_REFUSAL",
    "INTERACTION_REPLAY_FULL_ROUNDTRIP",
    "REPLAY_ARGUMENT_REGISTRY_COMPLETENESS",
    "REPLAY_SCORING_SETTING_PRESERVATION",
    "CHECKPOINT_SCORE_MUTATION_SAME_LAYOUT_REFUSAL",
    "CHECKPOINT_WEIGHT_MUTATION_SAME_LAYOUT_REFUSAL",
    "CHECKPOINT_FACET_LABEL_MUTATION_SAME_LAYOUT_REFUSAL",
    "CHECKPOINT_ANCHOR_MUTATION_SAME_LAYOUT_REFUSAL",
    "CHECKPOINT_QUADRATURE_MUTATION_REFUSAL",
    "HYBRID_CHECKPOINT_WRITE_RESUME",
    "CHECKPOINT_CROSS_STAGE_REFUSAL",
    "PURE_EM_SAME_MAXIT_REFUSAL",
    "PURE_EM_INCREASED_MAXIT_CONTINUATION",
    "CHECKPOINT_LEGACY_OR_CORRUPT_LAYOUT_REFUSAL",
    "CHECKPOINT_CONTROL_SCALAR_REFUSAL",
    "CHECKPOINT_CHECKED_ATOMIC_REPLACEMENT"
  )
  claim_group <- c(
    rep("portable_probability_posterior_mathematics", 8L),
    rep("independent_constraint_rank_mathematics", 2L),
    rep("semantic_identity_and_metamorphic_visibility", 7L),
    rep("operational_reproducibility", 6L),
    rep("prior_boundary", 2L),
    rep("artifact_persistence_and_input_refusal", 3L),
    rep("fitted_object_scoring_boundary", 6L),
    rep("replay_boundary", 3L),
    rep("checkpoint_objective_and_resume_boundary", 12L)
  )
  stopifnot(length(cell_id) == 49L, length(claim_group) == length(cell_id))
  data.frame(
    CellId = cell_id,
    ClaimGroup = claim_group,
    Required = TRUE,
    CurrentExecutionOpened = FALSE,
    FailureDisposition =
      "retain_failure_change_code_or_rule_then_issue_new_disjoint_identity",
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4_current_candidate_binding <- function() {
  data.frame(
    Field = c(
      "GitCommitSHA40", "GitTreeClean", "PackageVersion",
      "SourceTarballSHA256", "SourceTarballFileRegistrySHA256",
      "ProductionBoundaryRegistrySHA256", "ConfirmationWorkerSHA256",
      "ConfirmationTestSHA256", "ContractSHA256", "HostedRunnerSHA256",
      "HostedCellWorkflowSHA256", "HostedMatrixWorkflowSHA256"
    ),
    RequiredBeforeExecution = TRUE,
    BoundValue = NA_character_,
    BindingState = "unbound_before_candidate_freeze",
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4_current_production_boundary <- function() {
  data.frame(
    Path = c(
      "R/core-fixed-calibration.R", "R/api-prediction.R",
      "R/api-export-bundles.R", "R/core-optimizer.R", "DESCRIPTION"
    ),
    Boundary = c(
      "portable calibration schema identity and artifact-only scoring",
      "fitted-object scoring grid readiness and input validation",
      "fit and scoring replay completeness",
      "MML-EM checkpoint schema identity stage and iteration control",
      "development release identity"
    ),
    RequiredInCandidateRegistry = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4_current_platform_matrix <- function() {
  data.frame(
    CellId = c(
      "macos-release", "windows-release", "ubuntu-devel",
      "ubuntu-release", "ubuntu-oldrel-1"
    ),
    OS = c("macOS", "Windows", rep("Linux", 3L)),
    R = c("release", "release", "devel", "release", "oldrel-1"),
    ExecutionOrder = c(
      "prerequisite_first", rep("after_macos_release_pass", 4L)
    ),
    EvidenceStatus = "pending_unrun_for_bound_current_candidate",
    Required = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4_current_resource_budgets <- function() {
  data.frame(
    Scale = c("small", "medium", "operational_plausible"),
    Persons = c(10L, 500L, 2500L),
    Rows = c(120L, 6000L, 30000L),
    ScoringQuadratureOrder = 31L,
    MaxArtifactBytes = 1048576,
    MaxElapsedSeconds = c(2, 15, 60),
    MaxProfiledAllocationBytes = c(134217728, 536870912, 2147483648),
    MaxSerializedResultBytes = c(1048576, 16777216, 67108864),
    BudgetRole = "regression ceiling, not a speed or capacity promise",
    RuleFrozenBeforeCurrentMeasurement = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4_current_review <- function() {
  identity <- mfrmr_fc_g4_current_scoring_identity()
  design <- mfrmr_fc_g4_current_confirmation_design()
  rules <- mfrmr_fc_g4_current_numerical_rules()
  denominator <- mfrmr_fc_g4_current_denominator()
  binding <- mfrmr_fc_g4_current_candidate_binding()
  boundary <- mfrmr_fc_g4_current_production_boundary()
  platforms <- mfrmr_fc_g4_current_platform_matrix()
  resources <- mfrmr_fc_g4_current_resource_budgets()
  current_design <- design[design$DisjointCurrentConfirmationAuthority, ]
  historical_control <- design[
    design$EvidenceRole == "historical_explicit9_regression_control", ,
    drop = FALSE
  ]
  valid <-
    identical(nrow(identity), 9L) &&
    identical(identity$Value[identity$Field == "ScoringAlgorithm"],
              "quadrature_eap_v1") &&
    identical(identity$Value[
      identity$Field == "DefaultScoringQuadratureOrder"
    ], "31") &&
    identical(nrow(current_design), 4L) &&
    !any(current_design$PreviouslyUsedFixture) &&
    all(!current_design$CurrentExecutionOpened) &&
    identical(current_design$ScoringQuadratureOrder, rep(31L, 4L)) &&
    identical(current_design$FitQuadratureOrder, c(13L, 13L, 1L, 1L)) &&
    identical(current_design$SourcePersons, c(56L, 56L, 48L, 48L)) &&
    identical(current_design$ConfirmationPersons, c(10L, 10L, 8L, 8L)) &&
    identical(current_design$GeneratorIdentity, c(
      rep("closed-form-logits-mod1031-v1-no-r-rng", 2L),
      rep("closed-form-logits-mod1033-v1-no-r-rng", 2L)
    )) &&
    !anyDuplicated(current_design$CalibrationId) &&
    !anyDuplicated(current_design$SourceFixtureId) &&
    !anyDuplicated(current_design$ConfirmationFixtureId) &&
    identical(nrow(historical_control), 2L) &&
    all(historical_control$PreviouslyUsedFixture) &&
    !any(historical_control$DisjointCurrentConfirmationAuthority) &&
    !any(historical_control$ControlMayAuthorizeCurrentG4) &&
    identical(historical_control$ScoringQuadratureOrder, c(9L, 9L)) &&
    identical(nrow(rules), 11L) && !anyDuplicated(rules$RuleId) &&
    all(rules$RuleFrozenBeforeCurrentExecution) &&
    identical(nrow(denominator), 49L) && !anyDuplicated(denominator$CellId) &&
    all(denominator$Required) && !any(denominator$CurrentExecutionOpened) &&
    identical(nrow(binding), 12L) && all(binding$RequiredBeforeExecution) &&
    all(is.na(binding$BoundValue)) &&
    identical(nrow(boundary), 5L) &&
    all(boundary$RequiredInCandidateRegistry) &&
    identical(nrow(platforms), 5L) && all(platforms$Required) &&
    identical(platforms$ExecutionOrder[1], "prerequisite_first") &&
    identical(resources$Rows, c(120L, 6000L, 30000L)) &&
    all(resources$ScoringQuadratureOrder == 31L) &&
    all(resources$RuleFrozenBeforeCurrentMeasurement)
  list(
    specification = mfrmr_fc_g4_current_specification,
    contract_version = mfrmr_fc_g4_current_contract,
    status = if (valid) {
      "G4_current_rules_frozen_candidate_unbound_confirmation_unopened"
    } else {
      "G4_current_contract_invalid"
    },
    rules_frozen = isTRUE(valid),
    current_identities_disjoint_and_frozen = isTRUE(valid),
    historical_control_non_authorizing = isTRUE(valid),
    denominator_frozen = isTRUE(valid),
    candidate_binding_complete = FALSE,
    current_execution_opened = FALSE,
    CORE_05_complete = FALSE,
    CORE_06_complete = FALSE,
    G4_exit_complete = FALSE,
    G6_authorized = FALSE,
    public_api_authorized = FALSE
  )
}
