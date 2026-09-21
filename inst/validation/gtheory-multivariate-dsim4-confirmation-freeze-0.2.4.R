# Internal D-SIM-4 confirmation freeze.
#
# This file freezes a role-complete, outcome-independent D-SIM-5 study. It
# opens no seed, generates no response, calls no backend, and authorizes no
# execution or support claim.

mfrmr_gtds4_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds_v4_contract",
    "mfrmr_gtds_v4_validate_contract", "mfrmr_gtds_v4_acceptance_registry",
    "mfrmr_gtds3_contract", "mfrmr_gtds3_manifest",
    "mfrmr_gtds3_assert_manifest", "mfrmr_gtds4a_contract",
    "mfrmr_gtds4a_validate_contract"
  )
  target <- environment(mfrmr_gtds4_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the v4, D-SIM-3 coverage, and D-SIM-4 admission contracts ",
      "first: ", paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds4_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds4_file_hash <- function(path) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The D-SIM-4 freeze requires `digest`.", call. = FALSE)
  }
  path <- normalizePath(path, mustWork = TRUE)
  if (dir.exists(path)) stop("A source file is required.", call. = FALSE)
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtds4_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM4-CONFIRMATION-FREEZE-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-31",
    ParentCapabilityContractHash =
      "9b68d194e13625ec73992f314a9494e29c36f77838e0da19a15020f2af74a214",
    ParentCoverageContractHash =
      "39b4b542f3afe617cc8f2912a23aa4211790460c8765d4ad38f9cd95575c508f",
    ParentCoverageManifestHash =
      "4c6958f00aac7598d777387ec113cd43474031430492e83e6183d19dcedf7197",
    ParentAdmissionContractHash =
      "a4158f9afc9aab4e250a6b4a1c5341299ba79da094fb5b60b5bf72928ff72380",
    ParentAdmissionManifestHash =
      "2c98b5f29bafca074f4d095ce51c5c9ad2e04253cef48292a691b307d9c45282",
    ParentTruthMetricContractHash =
      "d73dd72c8bc849597dd68342a3608b1f34b315e7f1fd1ad52a87a9e26d963cb8",
    ParentFitWorkerContractHash =
      "9e5055fc47191f4426507c352b45b72a2a40256bd227dcf464d04e7058de44c7"
  )
}

mfrmr_gtds4_question_registry <- function() {
  data.frame(
    QuestionOrdinal = 1:3,
    QuestionId = c(
      "point_recovery", "interval_coverage", "fail_closed_behavior"
    ),
    Target = c(
      "finite_sample_G_and_Phi_recovery",
      "joint_full_refit_G_and_Phi_interval_coverage",
      "boundary_control_and_failure_accounting"
    ),
    EvaluatedSeparately = TRUE,
    CrossQuestionVotingAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds4_interval_contract <- function() {
  list(
    MethodId = "full_refit_parametric_bootstrap_percentile_v1",
    ConfidenceLevel = 0.95,
    Backend = "lme4",
    Criterion = "REML",
    RouteId = "separate_univariate",
    BootstrapReplicateCount = 199L,
    QuantileType = 7L,
    SimulationMode = "unconditional_new_random_effects_and_residuals",
    RefitRule = "same_rows_formula_backend_controls_and_D_study_operator",
    IntervalTargets = c("ABS-PHI", "REL-G"),
    EligibleScenarioRoles = c("full_anchor", "targeted_structural"),
    AvailableIntervalRule =
      "all_199_bootstrap_refits_terminal_success_and_target_finite",
    FailedBootstrapRule =
      "interval_unavailable_outer_attempt_retained_no_success_replenishment",
    MarginalComponentEndpointSubstitutionAllowed = FALSE,
    WaldOnlyIntervalAllowed = FALSE
  )
}

mfrmr_gtds4_replication_contract <- function() {
  n <- 2500L
  list(
    OuterReplicateCountPerScenario = n,
    WorstCaseCoverageMcseTarget = 0.01,
    WorstCaseCoverageMcseFormula = "sqrt(0.25 / N)",
    WorstCaseCoverageMcse = sqrt(0.25 / n),
    ReplicationCountDerivation = "ceiling(0.25 / 0.01^2)",
    OptionalStoppingAllowed = FALSE,
    PrecisionBasedExtensionAllowed = FALSE,
    SuccessfulFitReplenishmentAllowed = FALSE
  )
}

mfrmr_gtds4_seed_contract <- function() {
  list(
    DataSeedBandId = "DSIM5-CONFIRMATION-DATA-857",
    DataSeedFormula =
      "857000000 + confirmation_scenario_ordinal * 10000 + replicate",
    DataSeedMinimum = 857010001L,
    DataSeedMaximum = 857062500L,
    BootstrapSeedBandId = "DSIM5-CONFIRMATION-BOOTSTRAP-858",
    BootstrapSeedFormula =
      "858000000 + confirmation_scenario_ordinal * 10000 + replicate",
    BootstrapSeedMinimum = 858010001L,
    BootstrapSeedMaximum = 858062500L,
    SeedBandsDisjointFromDsim3 = TRUE,
    SeedBandsUnopened = TRUE,
    SeedReplacementAllowed = FALSE
  )
}

mfrmr_gtds4_reference_contract <- function() {
  list(
    ReferenceId = "base_R_direct_G_Phi_formula_v1",
    FunctionName = "mfrmr_gtds4_reference_coefficient",
    InputIdentity =
      "named_universe_relative_error_and_absolute_only_variance_scalars",
    OverlapRule = "every_finite_primary_route_stratum_in_all_six_scenarios",
    Tolerance = 1e-10,
    IndependentFromFitWorkerCoefficientFunction = TRUE,
    IndependentFitBackendClaimed = FALSE,
    ReferenceClaimCeiling =
      "coefficient_transformation_only_not_estimator_reference_validation"
  )
}

mfrmr_gtds4_reference_coefficient <- function(
    universe, relative_error, absolute_only) {
  values <- c(
    universe = universe, relative_error = relative_error,
    absolute_only = absolute_only
  )
  if (!is.numeric(values) || length(values) != 3L || anyNA(values) ||
      any(!is.finite(values)) || any(values < 0)) {
    stop("Reference variances must be three finite nonnegative scalars.",
         call. = FALSE)
  }
  relative_denominator <- universe + relative_error
  absolute_denominator <- relative_denominator + absolute_only
  if (relative_denominator <= 0 || absolute_denominator <= 0) {
    stop("Reference coefficient denominators must be positive.",
         call. = FALSE)
  }
  c(
    `ABS-PHI` = universe / absolute_denominator,
    `REL-G` = universe / relative_denominator
  )
}

mfrmr_gtds4_attempt_rule_registry <- function() {
  data.frame(
    RuleOrdinal = 1:6,
    RuleId = c(
      "one_terminal_per_outer_attempt", "failed_attempt_in_denominator",
      "no_replacement_seed", "no_success_replenishment",
      "no_post_outcome_exclusion", "interval_failure_bound"
    ),
    Rule = c(
      "Every planned outer attempt receives exactly one terminal state.",
      "Generation, fit, metric, and interval failures remain counted.",
      "A failed attempt is never regenerated under another seed.",
      "The planned count is not filled with extra successful attempts.",
      "No scenario, route, estimand, or replicate is removed after output.",
      "Unavailable intervals enter worst-case coverage bounds, not a success-only denominator."
    ),
    Frozen = TRUE,
    OutcomeAdaptiveRevisionAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds4_resource_registry <- function() {
  data.frame(
    ScopeOrdinal = 1:5,
    ScopeId = c(
      "outer_generation", "primary_fit", "bootstrap_interval",
      "one_outer_pipeline", "complete_confirmation"
    ),
    ReportWallSeconds = TRUE,
    ReportPeakRssMiB = TRUE,
    IsExecutionEnablementGate = FALSE,
    PostOutcomeExclusionAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds4_change_control_registry <- function() {
  data.frame(
    ChangeOrdinal = 1:5,
    ChangeClass = c(
      "estimator", "generator", "truth", "interval", "routing"
    ),
    InvalidatesFreeze = TRUE,
    RequiredAction =
      "issue_new_contract_version_and_disjoint_seed_namespace_before_execution",
    ResultAdaptiveAmendmentAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds4_source_registry <- function() {
  data.frame(
    SourceOrdinal = 1:8,
    SourceBasename = c(
      "gtheory-multivariate-package-capability-contract-v4-0.2.4.R",
      "gtheory-multivariate-dsim3-coverage-manifest-0.2.4.R",
      "gtheory-multivariate-dsim3-covariance-distribution-binding-0.2.4.R",
      "gtheory-multivariate-dsim3-design-dependent-truth-projection-0.2.4.R",
      "gtheory-multivariate-dsim3-incidence-allocation-operator-0.2.4.R",
      "gtheory-multivariate-dsim3-separate-univariate-truth-coefficient-0.2.4.R",
      "gtheory-multivariate-dsim3-fit-metric-worker-0.2.4.R",
      "gtheory-multivariate-dsim3-response-generator-adapter-0.2.4.R"
    ),
    ExpectedSHA256 = c(
      "b1487f12b6bf3502357e7d6b24735af91d43ea4d78bbc40299ecf709dcb68eb7",
      "0b92c809253a2fc7ba46fcec8a387133dba6cfc0518c869277f11aa01f606e10",
      "c7639e2d76e31c4deba9b7be6cbbc6825e62d73430f9f8bfea025f55a56e039b",
      "3b940929e1c0758634e4c1f7baad109e1cebf875dbd9d36392c74221b468b782",
      "a21d0a73cb706939cec6381fe9c87afb2915a824d70a3bd8bf6dd7ce4032533c",
      "476dad72321404cf16e81369c06beb3a7450c5825ba8cf728c5d85b1927d93ed",
      "6acac1c8665685f1b9b700daade2d5c3354516b3e6677c86bd1313bf10e746a6",
      "6a2e5cfbdb837079ec07650b4494af068fa7cbbcafb3fceae985e5d7fa4e2bc0"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds4_environment_registry <- function() {
  data.frame(
    IdentityOrdinal = 1:6,
    IdentityId = c(
      "R_version", "platform", "Matrix_version", "lme4_version",
      "digest_version", "processx_version"
    ),
    ExpectedValue = c(
      "4.6.1", "aarch64-apple-darwin23", "1.7.6", "2.0.6",
      "0.6.39", "3.9.0"
    ),
    RequiredForDsim5 = TRUE,
    OperationalOwnerEvidence = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds4_contract <- function() {
  mfrmr_gtds4_require_primitives()
  identity <- mfrmr_gtds4_identity()
  payload <- c(identity, list(
    RequiredEstimands = c("ABS-PHI", "REL-G"),
    RequiredScenarioRoles = c(
      "boundary", "closure", "full_anchor", "targeted_structural"
    ),
    ScenarioSelectionRule = paste(
      "minimum_cardinality_complete_dataset_level_cover_with_all_roles",
      "then_lexicographic_parent_scenario_id", sep = "_"
    ),
    ExpectedSelectedScenarioCount = 6L,
    ExpectedCoveredDatasetLevelCount = 37L,
    ScientificQuestions = mfrmr_gtds4_question_registry(),
    AcceptanceRegistry = mfrmr_gtds_v4_acceptance_registry(),
    IntervalContract = mfrmr_gtds4_interval_contract(),
    ReplicationContract = mfrmr_gtds4_replication_contract(),
    SeedContract = mfrmr_gtds4_seed_contract(),
    ReferenceContract = mfrmr_gtds4_reference_contract(),
    AttemptRules = mfrmr_gtds4_attempt_rule_registry(),
    ResourceRegistry = mfrmr_gtds4_resource_registry(),
    ChangeControlRegistry = mfrmr_gtds4_change_control_registry(),
    SourceRegistry = mfrmr_gtds4_source_registry(),
    EnvironmentRegistry = mfrmr_gtds4_environment_registry(),
    ExpectedOuterAttemptCount = 15000L,
    ExpectedIntervalEligibleOuterAttemptCount = 5000L,
    ExpectedInnerBootstrapAttemptCount = 995000L,
    Dsim3OutcomeRanksMaySelectScenarios = FALSE,
    EstimandPoolingOrVotingAllowed = FALSE,
    NamedOperationalOwnerRequired = FALSE,
    ResourceCapacityIsEnablementGate = FALSE,
    Dsim4FreezeComplete = TRUE,
    Dsim5ExecutionAuthorized = FALSE,
    PlannedSeedAccessAllowed = FALSE,
    PlannedResponseGenerationAllowed = FALSE,
    BackendCallAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    ReferenceValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds4_hash(payload)
  )), class = c("mfrmr_gtds4_contract", "list"))
}

mfrmr_gtds4_validate_contract <- function(
    contract = mfrmr_gtds4_contract()) {
  mfrmr_gtds4_require_primitives()
  canonical <- mfrmr_gtds4_contract()
  capability <- mfrmr_gtds_v4_contract()
  coverage <- mfrmr_gtds3_contract()
  admission <- mfrmr_gtds4a_contract()
  mfrmr_gtds_v4_validate_contract(capability)
  mfrmr_gtds4a_validate_contract(admission)
  valid <- inherits(contract, "mfrmr_gtds4_contract") &&
    identical(contract, canonical) &&
    identical(capability$ContractHash,
              contract$ParentCapabilityContractHash) &&
    identical(coverage$ContractHash, contract$ParentCoverageContractHash) &&
    identical(admission$ContractHash,
              contract$ParentAdmissionContractHash) &&
    identical(contract$RequiredEstimands, c("ABS-PHI", "REL-G")) &&
    identical(length(contract$RequiredScenarioRoles), 4L) &&
    identical(nrow(contract$ScientificQuestions), 3L) &&
    all(contract$ScientificQuestions$EvaluatedSeparately) &&
    all(!contract$ScientificQuestions$CrossQuestionVotingAllowed) &&
    identical(contract$AcceptanceRegistry,
              mfrmr_gtds_v4_acceptance_registry()) &&
    identical(contract$ExpectedSelectedScenarioCount, 6L) &&
    identical(contract$ExpectedCoveredDatasetLevelCount, 37L) &&
    identical(contract$ReplicationContract$OuterReplicateCountPerScenario,
              2500L) &&
    identical(contract$ReplicationContract$WorstCaseCoverageMcse, 0.01) &&
    identical(contract$IntervalContract$BootstrapReplicateCount, 199L) &&
    identical(contract$ExpectedOuterAttemptCount, 15000L) &&
    identical(contract$ExpectedIntervalEligibleOuterAttemptCount, 5000L) &&
    identical(contract$ExpectedInnerBootstrapAttemptCount, 995000L) &&
    all(contract$AttemptRules$Frozen) &&
    all(contract$ChangeControlRegistry$InvalidatesFreeze) &&
    all(!contract$ResourceRegistry$IsExecutionEnablementGate) &&
    !isTRUE(contract$Dsim3OutcomeRanksMaySelectScenarios) &&
    !isTRUE(contract$EstimandPoolingOrVotingAllowed) &&
    !isTRUE(contract$NamedOperationalOwnerRequired) &&
    !isTRUE(contract$ResourceCapacityIsEnablementGate) &&
    isTRUE(contract$Dsim4FreezeComplete) &&
    !any(vapply(c(
      "Dsim5ExecutionAuthorized", "PlannedSeedAccessAllowed",
      "PlannedResponseGenerationAllowed", "BackendCallAllowed",
      "SimulationValidationClaimAllowed", "ReferenceValidationClaimAllowed",
      "PublicSupportPromotionAllowed"
    ), function(name) isTRUE(contract[[name]]), logical(1L)))
  if (!valid) {
    stop("The D-SIM-4 confirmation contract is invalid or altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds4_select_scenarios <- function(coverage_manifest) {
  mfrmr_gtds3_assert_manifest(coverage_manifest)
  scenarios <- coverage_manifest$ScenarioRegistry
  target <- coverage_manifest$LevelCoverageRegistry
  target <- target[target$CoverageSource == "dataset_scenario",
                   c("AxisId", "LevelId"), drop = FALSE]
  target_tokens <- paste(target$AxisId, target$LevelId, sep = "\036")
  mandatory_roles <- c("full_anchor", "closure", "targeted_structural")
  mandatory <- which(scenarios$ScenarioRole %in% mandatory_roles)
  if (!identical(sort(unique(scenarios$ScenarioRole[mandatory])),
                 sort(mandatory_roles))) {
    stop("The D-SIM-3 role frame changed.", call. = FALSE)
  }
  boundary <- which(scenarios$ScenarioRole == "boundary")
  axis_ids <- coverage_manifest$Contract$DatasetAxisIds
  covers <- function(indices) {
    tokens <- unlist(lapply(axis_ids, function(axis) {
      paste(axis, scenarios[[axis]][indices], sep = "\036")
    }), use.names = FALSE)
    all(target_tokens %in% unique(tokens))
  }
  selected <- NULL
  for (size in seq_along(boundary)) {
    candidates <- utils::combn(boundary, size, simplify = FALSE)
    hit <- which(vapply(
      candidates, function(candidate) covers(c(mandatory, candidate)),
      logical(1L)
    ))
    if (length(hit) > 0L) {
      selected <- c(mandatory, candidates[[hit[[1L]]]])
      break
    }
  }
  if (is.null(selected)) {
    stop("No role-complete D-SIM-4 level cover exists.", call. = FALSE)
  }
  selected <- sort(unique(selected))
  output <- scenarios[selected, , drop = FALSE]
  output$ConfirmationScenarioOrdinal <- seq_len(nrow(output))
  output$ConfirmationScenarioId <- sprintf(
    "D4-S%03d", output$ConfirmationScenarioOrdinal
  )
  output$RegularInteriorAcceptance <-
    output$ScenarioRole %in% c("full_anchor", "targeted_structural") &
    output$variance_regime == "regular_interior"
  output$BoundaryOrControlAcceptance <-
    output$ScenarioRole %in% c("boundary", "closure")
  output$IntervalEligible <- output$RegularInteriorAcceptance
  output$SelectionInspectedDsim3Outcome <- FALSE
  output$SelectionWeight <- 1
  output
}

mfrmr_gtds4_level_coverage <- function(
    coverage_manifest, selected_scenarios) {
  target <- coverage_manifest$LevelCoverageRegistry
  target <- target[target$CoverageSource == "dataset_scenario",
                   c("AxisOrdinal", "AxisId", "LevelOrdinal", "LevelId",
                     "CoverageRole"), drop = FALSE]
  target$CoveringConfirmationScenarioIds <- vapply(
    seq_len(nrow(target)), function(index) {
      axis <- target$AxisId[[index]]
      level <- target$LevelId[[index]]
      paste(
        selected_scenarios$ConfirmationScenarioId[
          selected_scenarios[[axis]] == level
        ], collapse = ";"
      )
    }, character(1L)
  )
  target$Covered <- nzchar(target$CoveringConfirmationScenarioIds)
  target
}

mfrmr_gtds4_attempt_registry <- function(selected_scenarios, contract) {
  n <- contract$ReplicationContract$OuterReplicateCountPerScenario
  grid <- expand.grid(
    ConfirmationScenarioOrdinal =
      selected_scenarios$ConfirmationScenarioOrdinal,
    Replicate = seq_len(n), KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  grid <- grid[order(grid$ConfirmationScenarioOrdinal, grid$Replicate),
               , drop = FALSE]
  row.names(grid) <- NULL
  match_index <- match(
    grid$ConfirmationScenarioOrdinal,
    selected_scenarios$ConfirmationScenarioOrdinal
  )
  grid$AttemptOrdinal <- seq_len(nrow(grid))
  grid$AttemptId <- sprintf("D5-A%05d", grid$AttemptOrdinal)
  grid$ConfirmationScenarioId <-
    selected_scenarios$ConfirmationScenarioId[match_index]
  grid$ParentScenarioId <- selected_scenarios$ScenarioId[match_index]
  grid$ScenarioRole <- selected_scenarios$ScenarioRole[match_index]
  grid$DataSeed <- as.integer(
    857000000 + grid$ConfirmationScenarioOrdinal * 10000 + grid$Replicate
  )
  grid$IntervalEligible <- selected_scenarios$IntervalEligible[match_index]
  bootstrap_seed <-
    858000000 + grid$ConfirmationScenarioOrdinal * 10000 + grid$Replicate
  grid$BootstrapSeed <- as.integer(ifelse(
    grid$IntervalEligible, bootstrap_seed, NA_real_
  ))
  grid$InnerBootstrapAttemptCount <- ifelse(
    grid$IntervalEligible,
    contract$IntervalContract$BootstrapReplicateCount, 0L
  )
  grid$RngStreamOpened <- FALSE
  grid$ResponseGenerated <- FALSE
  grid$BackendCallMade <- FALSE
  grid$TerminalStateCount <- 0L
  grid$ExecutionAuthorized <- FALSE
  grid$ReplacementAllowed <- FALSE
  grid[c(
    "AttemptOrdinal", "AttemptId", "ConfirmationScenarioOrdinal",
    "ConfirmationScenarioId", "ParentScenarioId", "ScenarioRole",
    "Replicate", "DataSeed", "IntervalEligible", "BootstrapSeed",
    "InnerBootstrapAttemptCount", "RngStreamOpened", "ResponseGenerated",
    "BackendCallMade", "TerminalStateCount", "ExecutionAuthorized",
    "ReplacementAllowed"
  )]
}

mfrmr_gtds4_source_audit <- function(source_root, contract) {
  registry <- contract$SourceRegistry
  paths <- file.path(
    normalizePath(source_root, mustWork = TRUE), "inst", "validation",
    registry$SourceBasename
  )
  registry$ObservedSHA256 <- vapply(paths, mfrmr_gtds4_file_hash,
                                    character(1L))
  registry$ExactIdentity <-
    registry$ObservedSHA256 == registry$ExpectedSHA256
  registry
}

mfrmr_gtds4_environment_audit <- function(contract) {
  package_value <- function(package) {
    if (!requireNamespace(package, quietly = TRUE)) return(NA_character_)
    as.character(utils::packageVersion(package))
  }
  observed <- c(
    paste(R.version$major, R.version$minor, sep = "."),
    R.version$platform,
    package_value("Matrix"), package_value("lme4"),
    package_value("digest"), package_value("processx")
  )
  registry <- contract$EnvironmentRegistry
  registry$ObservedValue <- observed
  registry$ExactIdentity <-
    !is.na(observed) & observed == registry$ExpectedValue
  registry
}

mfrmr_gtds4_canonical_code <- function(value) {
  paste(deparse(value, width.cutoff = 500L, control = "all"),
        collapse = "\n")
}

mfrmr_gtds4_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds4_require_primitives", "mfrmr_gtds4_hash",
    "mfrmr_gtds4_file_hash", "mfrmr_gtds4_identity",
    "mfrmr_gtds4_question_registry", "mfrmr_gtds4_interval_contract",
    "mfrmr_gtds4_replication_contract", "mfrmr_gtds4_seed_contract",
    "mfrmr_gtds4_reference_contract", "mfrmr_gtds4_reference_coefficient",
    "mfrmr_gtds4_attempt_rule_registry", "mfrmr_gtds4_resource_registry",
    "mfrmr_gtds4_change_control_registry", "mfrmr_gtds4_source_registry",
    "mfrmr_gtds4_environment_registry", "mfrmr_gtds4_contract",
    "mfrmr_gtds4_validate_contract", "mfrmr_gtds4_select_scenarios",
    "mfrmr_gtds4_level_coverage", "mfrmr_gtds4_attempt_registry",
    "mfrmr_gtds4_source_audit", "mfrmr_gtds4_environment_audit",
    "mfrmr_gtds4_canonical_code", "mfrmr_gtds4_implementation_identity",
    "mfrmr_gtds4_freeze_requirement_registry",
    "mfrmr_gtds4_manifest_fields", "mfrmr_gtds4_manifest",
    "mfrmr_gtds4_assert_manifest"
  )
  target <- environment(mfrmr_gtds4_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions),
    FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds4_hash(list(
        Formals = mfrmr_gtds4_canonical_code(formals(fun)),
        Body = mfrmr_gtds4_canonical_code(body(fun))
      ))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds4_freeze_requirement_registry <- function(
    contract, scenarios, level_coverage, source_audit, environment_audit,
    implementation_identity) {
  frozen <- c(
    nrow(contract$ScientificQuestions) == 3L,
    identical(contract$RequiredEstimands, c("ABS-PHI", "REL-G")),
    setequal(unique(scenarios$ScenarioRole), contract$RequiredScenarioRoles),
    nrow(scenarios) == 6L && all(level_coverage$Covered) &&
      all(!scenarios$SelectionInspectedDsim3Outcome),
    identical(contract$AcceptanceRegistry,
              mfrmr_gtds_v4_acceptance_registry()),
    all(scenarios$BoundaryOrControlAcceptance[
      scenarios$ScenarioRole %in% c("boundary", "closure")
    ]),
    identical(contract$IntervalContract$ConfidenceLevel, 0.95) &&
      identical(contract$IntervalContract$BootstrapReplicateCount, 199L),
    identical(contract$ReplicationContract$OuterReplicateCountPerScenario,
              2500L) &&
      contract$ReplicationContract$WorstCaseCoverageMcse <=
        contract$ReplicationContract$WorstCaseCoverageMcseTarget,
    isTRUE(contract$ReferenceContract$
             IndependentFromFitWorkerCoefficientFunction) &&
      identical(contract$ReferenceContract$Tolerance, 1e-10),
    all(source_audit$ExactIdentity) &&
      all(environment_audit$ExactIdentity) &&
      nrow(implementation_identity) > 0L,
    isTRUE(contract$SeedContract$SeedBandsDisjointFromDsim3) &&
      isTRUE(contract$SeedContract$SeedBandsUnopened),
    all(contract$AttemptRules$Frozen) &&
      all(!contract$AttemptRules$OutcomeAdaptiveRevisionAllowed),
    all(contract$ResourceRegistry$ReportWallSeconds) &&
      all(contract$ResourceRegistry$ReportPeakRssMiB) &&
      all(!contract$ResourceRegistry$IsExecutionEnablementGate),
    all(contract$ChangeControlRegistry$InvalidatesFreeze) &&
      all(!contract$ChangeControlRegistry$ResultAdaptiveAmendmentAllowed)
  )
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
    Frozen = frozen,
    ResultAdaptiveRevisionAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds4_manifest_fields <- function() {
  c(
    "Contract", "ParentCoverageManifestHash", "ScenarioRegistry",
    "LevelCoverageRegistry", "AttemptRegistry", "SourceAuditRegistry",
    "EnvironmentAuditRegistry", "ImplementationIdentity",
    "FreezeRequirementRegistry", "Summary"
  )
}

mfrmr_gtds4_manifest <- function(
    coverage_manifest, source_root,
    contract = mfrmr_gtds4_contract()) {
  mfrmr_gtds4_validate_contract(contract)
  mfrmr_gtds3_assert_manifest(coverage_manifest)
  if (!identical(coverage_manifest$Contract$ContractHash,
                 contract$ParentCoverageContractHash) ||
      !identical(coverage_manifest$ManifestHash,
                 contract$ParentCoverageManifestHash)) {
    stop("The D-SIM-3 coverage identity changed.", call. = FALSE)
  }
  scenarios <- mfrmr_gtds4_select_scenarios(coverage_manifest)
  level_coverage <- mfrmr_gtds4_level_coverage(
    coverage_manifest, scenarios
  )
  attempts <- mfrmr_gtds4_attempt_registry(scenarios, contract)
  source_audit <- mfrmr_gtds4_source_audit(source_root, contract)
  environment_audit <- mfrmr_gtds4_environment_audit(contract)
  implementation <- mfrmr_gtds4_implementation_identity()
  freeze <- mfrmr_gtds4_freeze_requirement_registry(
    contract, scenarios, level_coverage, source_audit, environment_audit,
    implementation
  )
  summary <- list(
    SelectedScenarioCount = nrow(scenarios),
    CoveredDatasetLevelCount = sum(level_coverage$Covered),
    RequiredDatasetLevelCount = nrow(level_coverage),
    ScenarioRoleCount = length(unique(scenarios$ScenarioRole)),
    OuterAttemptCount = nrow(attempts),
    IntervalEligibleOuterAttemptCount = sum(attempts$IntervalEligible),
    InnerBootstrapAttemptCount = sum(attempts$InnerBootstrapAttemptCount),
    FreezeRequirementCount = nrow(freeze),
    FrozenRequirementCount = sum(freeze$Frozen),
    ExactSourceIdentityCount = sum(source_audit$ExactIdentity),
    ExactEnvironmentIdentityCount = sum(environment_audit$ExactIdentity),
    ConfirmationContractFrozen = all(freeze$Frozen),
    Dsim5ExecutionAuthorized = FALSE,
    PlannedSeedOpened = FALSE,
    ResponseGenerated = FALSE,
    BackendCallMade = FALSE,
    SimulationValidationReady = FALSE,
    ReferenceValidationReady = FALSE,
    PublicSupportReady = FALSE,
    FeatureMaturity = "specified",
    CurrentDisposition =
      "dsim4_confirmation_contract_frozen_dsim5_execution_closed",
    NextAction = paste(
      "qualify and statically reconcile the frozen interval and attempt",
      "worker before any D-SIM-5 seed is opened"
    )
  )
  payload <- list(
    Contract = contract,
    ParentCoverageManifestHash = coverage_manifest$ManifestHash,
    ScenarioRegistry = scenarios,
    LevelCoverageRegistry = level_coverage,
    AttemptRegistry = attempts,
    SourceAuditRegistry = source_audit,
    EnvironmentAuditRegistry = environment_audit,
    ImplementationIdentity = implementation,
    FreezeRequirementRegistry = freeze,
    Summary = summary
  )
  manifest <- structure(c(payload, list(
    ManifestHash = mfrmr_gtds4_hash(payload)
  )), class = c("mfrmr_gtds4_manifest", "list"))
  mfrmr_gtds4_assert_manifest(manifest)
  manifest
}

mfrmr_gtds4_assert_manifest <- function(manifest) {
  fields <- mfrmr_gtds4_manifest_fields()
  if (!inherits(manifest, "mfrmr_gtds4_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed D-SIM-4 freeze manifest is required.", call. = FALSE)
  }
  contract <- manifest$Contract
  scenarios <- manifest$ScenarioRegistry
  levels <- manifest$LevelCoverageRegistry
  attempts <- manifest$AttemptRegistry
  source <- manifest$SourceAuditRegistry
  environment <- manifest$EnvironmentAuditRegistry
  freeze <- manifest$FreezeRequirementRegistry
  summary <- manifest$Summary
  expected_ids <- c(
    "D3-S001", "D3-S002", "D3-S003", "D3-S004", "D3-S005",
    "D3-S018"
  )
  expected_data_seed <- as.integer(
    857000000 + attempts$ConfirmationScenarioOrdinal * 10000 +
      attempts$Replicate
  )
  expected_bootstrap_seed <- as.integer(
    858000000 + attempts$ConfirmationScenarioOrdinal * 10000 +
      attempts$Replicate
  )
  valid <- identical(
    manifest$ManifestHash, mfrmr_gtds4_hash(manifest[fields])
  ) && identical(contract, mfrmr_gtds4_contract()) &&
    identical(manifest$ParentCoverageManifestHash,
              contract$ParentCoverageManifestHash) &&
    identical(scenarios$ScenarioId, expected_ids) &&
    identical(scenarios$ConfirmationScenarioId,
              sprintf("D4-S%03d", 1:6)) &&
    setequal(unique(scenarios$ScenarioRole),
             contract$RequiredScenarioRoles) &&
    all(levels$Covered) && identical(nrow(levels), 37L) &&
    identical(nrow(attempts), 15000L) &&
    !anyDuplicated(attempts$AttemptId) &&
    !anyDuplicated(attempts$DataSeed) &&
    identical(attempts$DataSeed, expected_data_seed) &&
    all(attempts$BootstrapSeed[attempts$IntervalEligible] ==
          expected_bootstrap_seed[attempts$IntervalEligible]) &&
    all(is.na(attempts$BootstrapSeed[!attempts$IntervalEligible])) &&
    sum(attempts$IntervalEligible) == 5000L &&
    sum(attempts$InnerBootstrapAttemptCount) == 995000L &&
    all(!attempts$RngStreamOpened) &&
    all(!attempts$ResponseGenerated) &&
    all(!attempts$BackendCallMade) &&
    all(attempts$TerminalStateCount == 0L) &&
    all(!attempts$ExecutionAuthorized) &&
    all(!attempts$ReplacementAllowed) &&
    all(source$ExactIdentity) && all(environment$ExactIdentity) &&
    identical(manifest$ImplementationIdentity,
              mfrmr_gtds4_implementation_identity()) &&
    identical(nrow(freeze), 14L) && all(freeze$Frozen) &&
    all(!freeze$ResultAdaptiveRevisionAllowed) &&
    identical(summary$SelectedScenarioCount, 6L) &&
    identical(summary$CoveredDatasetLevelCount, 37L) &&
    identical(summary$RequiredDatasetLevelCount, 37L) &&
    identical(summary$ScenarioRoleCount, 4L) &&
    identical(summary$OuterAttemptCount, 15000L) &&
    identical(summary$IntervalEligibleOuterAttemptCount, 5000L) &&
    identical(summary$InnerBootstrapAttemptCount, 995000L) &&
    identical(summary$FrozenRequirementCount, 14L) &&
    isTRUE(summary$ConfirmationContractFrozen) &&
    !isTRUE(summary$Dsim5ExecutionAuthorized) &&
    !isTRUE(summary$PlannedSeedOpened) &&
    !isTRUE(summary$ResponseGenerated) &&
    !isTRUE(summary$BackendCallMade) &&
    !isTRUE(summary$SimulationValidationReady) &&
    !isTRUE(summary$ReferenceValidationReady) &&
    !isTRUE(summary$PublicSupportReady) &&
    identical(summary$FeatureMaturity, "specified")
  if (!valid) {
    stop("The D-SIM-4 freeze manifest was altered or is incomplete.",
         call. = FALSE)
  }
  invisible(TRUE)
}
