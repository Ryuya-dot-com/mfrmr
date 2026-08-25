# 0.2.4 fixed-calibration post-maintenance G4 v6 contract.
#
# This repository-only file prospectively freezes the successor confirmation
# design required after the 0.2.3.1 maintenance merge. It performs no fit,
# score, replay, checkpoint, persistence, build, or subprocess operation.

mfrmr_fc_g4v6_specification <-
  "0.2.4-fixed-calibration-post-maintenance-boundary-evidence-v6"
mfrmr_fc_g4v6_contract <-
  "mfrmr_fixed_calibration_g4_post_maintenance_evidence_v6"

mfrmr_fc_g4v6_scoring_identity <- function() {
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
    FrozenBeforeV6Execution = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4v6_confirmation_design <- function() {
  data.frame(
    Family = rep(c("RSM", "PCM"), 3L),
    EvidenceRole = rep(c(
      "current_default31_confirmation",
      "one_node_source_fit_adversary",
      "historical_explicit9_regression_control"
    ), each = 2L),
    CalibrationId = c(
      "fc-g4-v6-rsm-default31-024-j",
      "fc-g4-v6-pcm-default31-024-j",
      "fc-g4-v6-rsm-source1-024-k",
      "fc-g4-v6-pcm-source1-024-k",
      "fc-g4-confirmation-rsm-024-a",
      "fc-g4-confirmation-pcm-024-a"
    ),
    SourceFixtureId = c(
      "fc-g4-v6-source-rsm-mod1061-offset307",
      "fc-g4-v6-source-pcm-mod1061-offset307",
      "fc-g4-v6-source1-rsm-mod1063-offset463",
      "fc-g4-v6-source1-pcm-mod1063-offset463",
      "fc-g4-source-rsm-mod997-offset000",
      "fc-g4-source-pcm-mod997-offset000"
    ),
    ConfirmationFixtureId = c(
      "fc-g4-v6-confirm-rsm-mod1061-offset947",
      "fc-g4-v6-confirm-pcm-mod1061-offset947",
      "fc-g4-v6-confirm-source1-rsm-mod1063-offset1007",
      "fc-g4-v6-confirm-source1-pcm-mod1063-offset1007",
      "fc-g4-confirm-rsm-mod997-offset401",
      "fc-g4-confirm-pcm-mod997-offset401"
    ),
    SourcePersons = c(61L, 61L, 53L, 53L, 48L, 48L),
    ConfirmationPersons = c(13L, 13L, 10L, 10L, 7L, 7L),
    Raters = 4L,
    Criteria = 3L,
    Categories = 4L,
    FitQuadratureOrder = c(15L, 15L, 1L, 1L, 9L, 9L),
    ScoringQuadratureOrder = c(31L, 31L, 31L, 31L, 9L, 9L),
    GeneratorIdentity = c(
      rep("closed-form-logits-mod1061-v1-no-r-rng", 2L),
      rep("closed-form-logits-mod1063-v1-no-r-rng", 2L),
      rep("historical-closed-form-logits-mod997-v1-no-r-rng", 2L)
    ),
    Modulus = c(1061L, 1061L, 1063L, 1063L, 997L, 997L),
    SourcePrefix = c(
      "G4V6D31RS", "G4V6D31PS", "G4V6S01RS", "G4V6S01PS",
      "G4H09RS", "G4H09PS"
    ),
    ConfirmationPrefix = c(
      "G4V6D31RC", "G4V6D31PC", "G4V6S01RC", "G4V6S01PC",
      "G4H09RC", "G4H09PC"
    ),
    SourceOffset = c(307L, 307L, 463L, 463L, 0L, 0L),
    ConfirmationOffset = c(947L, 947L, 1007L, 1007L, 401L, 401L),
    PreviouslyUsedFixture = c(FALSE, FALSE, FALSE, FALSE, TRUE, TRUE),
    V6ExecutionOpened = FALSE,
    DisjointV6ConfirmationAuthority = c(
      TRUE, TRUE, TRUE, TRUE, FALSE, FALSE
    ),
    ControlMayAuthorizeV6G4 = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4v6_numerical_rules <- function() {
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
    RuleFrozenBeforeV6Execution = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4v6_denominator <- function() {
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
    "FITTED_NONREADY_REVIEW_LABEL", "FITTED_NONFINITE_WEIGHT_REFUSAL",
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
    V6ExecutionOpened = FALSE,
    FailureDisposition =
      "retain_failure_change_code_or_rule_then_issue_new_disjoint_identity",
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4v6_candidate_binding <- function() {
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
    BindingState = "unbound_before_v6_candidate_freeze",
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4v6_production_boundary <- function() {
  data.frame(
    Path = c(
      "R/core-fixed-calibration.R", "R/api-prediction.R",
      "R/api-reference-benchmark.R", "R/api-export-bundles.R",
      "R/core-optimizer.R", "DESCRIPTION", "src/mml_backend.cpp",
      "src/cpp11.cpp"
    ),
    Boundary = c(
      "portable calibration schema identity and artifact-only scoring",
      "fitted-object scoring grid readiness and input validation",
      "reference benchmark scoring-readiness propagation",
      "fit and scoring replay completeness",
      "MML-EM checkpoint schema identity stage and iteration control",
      "development and public-predecessor release identity",
      "compiled likelihood backend after LTO-compatible header repair",
      "compiled registration translation unit after header repair"
    ),
    RequiredInCandidateRegistry = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4v6_platform_matrix <- function() {
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
    EvidenceStatus = "pending_unrun_for_bound_v6_candidate",
    Required = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4v6_resource_budgets <- function() {
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
    RuleFrozenBeforeV6Measurement = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4v6_review <- function() {
  identity <- mfrmr_fc_g4v6_scoring_identity()
  design <- mfrmr_fc_g4v6_confirmation_design()
  rules <- mfrmr_fc_g4v6_numerical_rules()
  denominator <- mfrmr_fc_g4v6_denominator()
  binding <- mfrmr_fc_g4v6_candidate_binding()
  boundary <- mfrmr_fc_g4v6_production_boundary()
  platforms <- mfrmr_fc_g4v6_platform_matrix()
  resources <- mfrmr_fc_g4v6_resource_budgets()
  current <- design[design$DisjointV6ConfirmationAuthority, , drop = FALSE]
  control <- design[
    design$EvidenceRole == "historical_explicit9_regression_control", ,
    drop = FALSE
  ]
  consumed <- "mod997|mod1009|mod1013|mod1019|mod1021|mod1031|mod1033|mod1039|mod1049"
  valid <-
    identical(nrow(identity), 9L) &&
    identical(identity$Value[identity$Field == "ScoringAlgorithm"],
              "quadrature_eap_v1") &&
    identical(identity$Value[
      identity$Field == "DefaultScoringQuadratureOrder"
    ], "31") &&
    identical(nrow(current), 4L) &&
    !any(current$PreviouslyUsedFixture) &&
    all(!current$V6ExecutionOpened) &&
    identical(current$ScoringQuadratureOrder, rep(31L, 4L)) &&
    identical(current$FitQuadratureOrder, c(15L, 15L, 1L, 1L)) &&
    identical(current$SourcePersons, c(61L, 61L, 53L, 53L)) &&
    identical(current$ConfirmationPersons, c(13L, 13L, 10L, 10L)) &&
    identical(current$GeneratorIdentity, c(
      rep("closed-form-logits-mod1061-v1-no-r-rng", 2L),
      rep("closed-form-logits-mod1063-v1-no-r-rng", 2L)
    )) &&
    !any(grepl(consumed, current$GeneratorIdentity)) &&
    !anyDuplicated(current$CalibrationId) &&
    !anyDuplicated(current$SourceFixtureId) &&
    !anyDuplicated(current$ConfirmationFixtureId) &&
    identical(nrow(control), 2L) && all(control$PreviouslyUsedFixture) &&
    !any(control$DisjointV6ConfirmationAuthority) &&
    !any(control$ControlMayAuthorizeV6G4) &&
    identical(control$ScoringQuadratureOrder, c(9L, 9L)) &&
    identical(nrow(rules), 11L) && !anyDuplicated(rules$RuleId) &&
    all(rules$RuleFrozenBeforeV6Execution) &&
    identical(nrow(denominator), 49L) &&
    !anyDuplicated(denominator$CellId) && all(denominator$Required) &&
    !any(denominator$V6ExecutionOpened) &&
    identical(nrow(binding), 12L) && all(binding$RequiredBeforeExecution) &&
    all(is.na(binding$BoundValue)) &&
    identical(nrow(boundary), 8L) &&
    all(c("src/mml_backend.cpp", "src/cpp11.cpp") %in% boundary$Path) &&
    all(boundary$RequiredInCandidateRegistry) &&
    identical(nrow(platforms), 5L) && all(platforms$Required) &&
    identical(platforms$ExecutionOrder[1L], "prerequisite_first") &&
    identical(resources$Rows, c(120L, 6000L, 30000L)) &&
    all(resources$ScoringQuadratureOrder == 31L) &&
    all(resources$RuleFrozenBeforeV6Measurement)
  list(
    specification = mfrmr_fc_g4v6_specification,
    contract_version = mfrmr_fc_g4v6_contract,
    status = if (valid) {
      "G4_v6_rules_frozen_candidate_unbound_confirmation_unopened"
    } else {
      "G4_v6_contract_invalid"
    },
    rules_frozen = isTRUE(valid),
    v6_identities_disjoint_and_frozen = isTRUE(valid),
    historical_control_non_authorizing = isTRUE(valid),
    denominator_frozen = isTRUE(valid),
    compiled_boundary_frozen = isTRUE(valid),
    candidate_binding_complete = FALSE,
    v6_execution_opened = FALSE,
    CORE_05_complete = FALSE,
    CORE_06_complete = FALSE,
    G4_exit_complete = FALSE,
    G6_authorized = FALSE,
    public_api_authorized = FALSE
  )
}

# Compatibility aliases let the established evaluator consume the v6 contract
# without changing the historical v5 contract or its retained evidence.
mfrmr_fc_g4_current_specification <- mfrmr_fc_g4v6_specification
mfrmr_fc_g4_current_contract <- mfrmr_fc_g4v6_contract
mfrmr_fc_g4_current_scoring_identity <- mfrmr_fc_g4v6_scoring_identity
mfrmr_fc_g4_current_confirmation_design <-
  mfrmr_fc_g4v6_confirmation_design
mfrmr_fc_g4_current_numerical_rules <- mfrmr_fc_g4v6_numerical_rules
mfrmr_fc_g4_current_denominator <- mfrmr_fc_g4v6_denominator
mfrmr_fc_g4_current_candidate_binding <- mfrmr_fc_g4v6_candidate_binding
mfrmr_fc_g4_current_production_boundary <-
  mfrmr_fc_g4v6_production_boundary
mfrmr_fc_g4_current_platform_matrix <- mfrmr_fc_g4v6_platform_matrix
mfrmr_fc_g4_current_resource_budgets <- mfrmr_fc_g4v6_resource_budgets
mfrmr_fc_g4_current_review <- mfrmr_fc_g4v6_review
