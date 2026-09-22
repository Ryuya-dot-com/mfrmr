# Draft.83d2b2b1g prospective glmmTMB stabilization design.
#
# Repository-internal only. This file freezes a profile DAG, start signature,
# diagnostic schema, and exact manifest. It performs no fitting.

mfrmr_gtwst_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtwy_function_hash",
    "mfrmr_gtwz_validate_numerical"
  )
  audit_environment <- environment(mfrmr_gtwst_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = audit_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the Draft.83d2b2b1f chain before Draft.83d2b2b1g: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwst_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwst_start_blocks", "mfrmr_gtwst_profiles",
    "mfrmr_gtwst_validate_typed_replay", "mfrmr_gtwst_start_signature",
    "mfrmr_gtwst_contract", "mfrmr_gtwst_validate_profile_graph",
    "mfrmr_gtwst_manifest"
  )
  audit_environment <- environment(mfrmr_gtwst_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwy_function_hash(get(
      name, envir = audit_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}

mfrmr_gtwst_start_blocks <- function() {
  data.frame(
    BlockOrder = seq_len(10L),
    BlockName = c(
      "beta", "betazi", "betadisp", "b", "bzi", "bdisp", "theta",
      "thetazi", "thetadisp", "psi"
    ),
    BlockRole = c(
      "conditional_fixed", "zero_inflation_fixed", "dispersion_fixed",
      "conditional_mode", "zero_inflation_mode", "dispersion_mode",
      "conditional_random_parameter", "zero_inflation_random_parameter",
      "dispersion_random_parameter", "extra_family_parameter"
    ),
    EmptyBlockRetained = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwst_profiles <- function() {
  rows <- data.frame(
    ExecutionOrder = c(1L, 2L, 2L, 1L, 2L, 2L),
    ProfileId = c(
      "glmmTMB_cold_nlminb",
      "glmmTMB_restart_nlminb_from_nlminb",
      "glmmTMB_warm_bfgs_from_nlminb",
      "glmmTMB_cold_bfgs",
      "glmmTMB_restart_bfgs_from_bfgs",
      "glmmTMB_warm_nlminb_from_bfgs"
    ),
    Algorithm = c("nlminb", "nlminb", "optim_BFGS", "optim_BFGS",
                  "optim_BFGS", "nlminb"),
    ParentProfileId = c(
      "none", "glmmTMB_cold_nlminb", "glmmTMB_cold_nlminb", "none",
      "glmmTMB_cold_bfgs", "glmmTMB_cold_bfgs"
    ),
    StartRule = c(
      "NULL_cold", "exact_all_blocks_from_parent_same_model",
      "exact_all_blocks_from_parent_same_model", "NULL_cold",
      "exact_all_blocks_from_parent_same_model",
      "exact_all_blocks_from_parent_same_model"
    ),
    LineageRole = c(
      "cold_root", "self_restart", "cross_algorithm_warm_start",
      "cold_root", "self_restart", "cross_algorithm_warm_start"
    ),
    ControlId = c(
      "glmmTMBControl_default_nlminb",
      "glmmTMBControl_default_nlminb",
      "optim_BFGS_maxit_2000_reltol_1e-10",
      "optim_BFGS_maxit_2000_reltol_1e-10",
      "optim_BFGS_maxit_2000_reltol_1e-10",
      "glmmTMBControl_default_nlminb"
    ),
    stringsAsFactors = FALSE
  )
  rows$IsColdRoot <- rows$ParentProfileId == "none"
  rows$ProfileHash <- vapply(seq_len(nrow(rows)), function(index) {
    mfrmr_gta_hash(rows[index, setdiff(names(rows), "ProfileHash"),
                              drop = FALSE])
  }, character(1L))
  rows
}

mfrmr_gtwst_validate_typed_replay <- function(adjudication) {
  inherits(adjudication, "mfrmr_gtwz_adjudication") &&
    identical(
      adjudication$TypedReplayContractHash,
      "8a18d59548ab5d8523e29f7089d2ea70620f51b38e2444e133a2e78974ff0d4a"
    ) &&
    identical(
      adjudication$NumericalSensitivityExecutionHash,
      "37be0b4dbac852454ced612b5f84706678f688f3f3ea7209793111ab6a706d94"
    ) &&
    identical(
      adjudication$ResultHash,
      "e200a9ee7984bbc3be32ab5ef209ce2eb26c0b42c8df3ad758bab7baf559f8c1"
    ) &&
    isTRUE(adjudication$ExactAccountingPassed) &&
    identical(adjudication$PlannedRows, 3000L) &&
    identical(adjudication$FiniteMatchCount, 2993L) &&
    identical(adjudication$SameTypedNonFiniteStateCount, 7L) &&
    identical(as.integer(adjudication$MismatchCount), 0L) &&
    identical(adjudication$NonFinitePromotedToAvailableCount, 0L) &&
    isTRUE(adjudication$TypedReplayAdjudicationReady) &&
    !isTRUE(adjudication$B1eDefaultReplayPassed) &&
    !isTRUE(adjudication$NumericalStabilizationReady) &&
    !isTRUE(adjudication$NumericalSensitivityEvidenceReady) &&
    !isTRUE(adjudication$CalibrationEvidenceReady) &&
    !isTRUE(adjudication$ThresholdFrozen) &&
    !isTRUE(adjudication$InferenceReady) &&
    !isTRUE(adjudication$DecisionReady)
}

mfrmr_gtwst_start_signature <- function(start) {
  blocks <- mfrmr_gtwst_start_blocks()
  expected <- blocks$BlockName
  if (!is.list(start) || is.null(names(start)) ||
      anyDuplicated(names(start)) || !setequal(names(start), expected)) {
    stop("A start must contain each exact named glmmTMB block once.",
         call. = FALSE)
  }
  start <- start[expected]
  valid_numeric <- vapply(start, is.numeric, logical(1L))
  finite <- vapply(start, function(value) all(is.finite(value)), logical(1L))
  if (!all(valid_numeric) || !all(finite)) {
    stop("Every glmmTMB start block must be numeric and finite.",
         call. = FALSE)
  }
  block_rows <- data.frame(
    BlockOrder = blocks$BlockOrder, BlockName = expected,
    BlockRole = blocks$BlockRole,
    BlockLength = vapply(start, length, integer(1L)),
    BlockHash = vapply(start, mfrmr_gta_hash, character(1L)),
    AllFinite = finite, stringsAsFactors = FALSE
  )
  identity <- list(
    Contract = "glmmtmb_exact_all_start_blocks_v1",
    Blocks = block_rows, Values = start
  )
  structure(c(identity, list(
    SignatureHash = mfrmr_gta_hash(identity),
    ExactBlockSet = TRUE, AllFinite = TRUE
  )), class = "mfrmr_gtwst_start_signature")
}

mfrmr_gtwst_contract <- function(numerical_execution, typed_adjudication) {
  mfrmr_gtwst_require_primitives()
  if (!mfrmr_gtwz_validate_numerical(numerical_execution) ||
      !mfrmr_gtwst_validate_typed_replay(typed_adjudication)) {
    stop("The exact b1e execution and b1f adjudication are required.",
         call. = FALSE)
  }
  profiles <- mfrmr_gtwst_profiles()
  start_blocks <- mfrmr_gtwst_start_blocks()
  richardson <- list(
    Function = "numDeriv::jacobian", Method = "Richardson",
    MethodArguments = list(
      eps = 1e-4, d = 1e-4, r = 4, v = 2,
      zero.tol = sqrt(.Machine$double.eps)
    )
  )
  sources <- data.frame(
    SourceId = c(
      "glmmTMB_troubleshooting_current", "glmmTMB_reference_current",
      "glmmTMB_diagnose_current", "numDeriv_current"
    ),
    Locator = c(
      "https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html",
      "https://glmmtmb.github.io/glmmTMB/reference/glmmTMB.html",
      "https://glmmtmb.github.io/glmmTMB/reference/diagnose.html",
      "https://cran.r-project.org/package=numDeriv"
    ),
    stringsAsFactors = FALSE
  )
  identity <- list(
    Contract =
      "gtheory_weak_information_glmmtmb_stabilization_draft83d2b2b1g_v1",
    ContractArtifact =
      "gtheory-weak-information-glmmtmb-stabilization-contract-0.2.3.md",
    NumericalSensitivityContractHash =
      numerical_execution$NumericalSensitivityContractHash,
    NumericalSensitivityManifestHash =
      numerical_execution$NumericalSensitivityManifestHash,
    NumericalSensitivityExecutionHash = numerical_execution$ExecutionHash,
    TypedReplayContractHash = typed_adjudication$TypedReplayContractHash,
    TypedReplayResultHash = typed_adjudication$ResultHash,
    Backend = "glmmTMB", BaseRouteCount = 1500L,
    IndependentDatasetCount = 750L, MethodCountPerDataset = 2L,
    Profiles = profiles, ProfileCountPerBaseRoute = nrow(profiles),
    PlannedPairs = 1500L * nrow(profiles),
    PlannedBackendFits = 2L * 1500L * nrow(profiles),
    StabilizationRowsPerDataset = 2L * nrow(profiles),
    StartBlocks = start_blocks,
    StartExtraction = paste0(
      "joint_best <- fit$obj$env$last.par.best; ",
      "fit$obj$env$parList(x=fit$fit$par, par=joint_best)"
    ),
    BareParListCallPermitted = FALSE,
    JointBestSnapshotRequired = TRUE,
    FixedCoordinateEqualityRequired = TRUE,
    SameModelRoleTransferRequired = TRUE,
    CrossRouteTransferPermitted = FALSE,
    FullReducedTransferPermitted = FALSE,
    AdaptiveFallbackPermitted = FALSE,
    ParentFailurePolicy = "typed_dependency_failure_retained_in_denominator",
    Diagnostics = c(
      "optimizer_code_message_warning_objective",
      "joint_best_snapshot_fixed_coordinate_equality_final_start_hash",
      "tmb_outer_gradient_dimension_hash_maxabs_l2",
      "sdreport_fixed_gradient_dimension_hash_maxabs_l2",
      "sdreport_pdhess_inverse_covariance_hessian",
      "richardson_gradient_jacobian_symmetry_and_eigenspectrum",
      "boundary_row_likelihood_df_and_nested_drop_identity"
    ),
    Richardson = richardson,
    GradientReportingGrid = c(1e-6, 1e-5, 1e-4, 1e-3),
    RelativeHessianEigenvalueReportingGrid = c(1e-10, 1e-8, 1e-6, 1e-4),
    ObjectiveChangeReportingGrid = c(1e-8, 1e-6, 1e-4, 1e-2),
    GradientEligibilityThresholdSelected = FALSE,
    HessianEligibilityThresholdSelected = FALSE,
    ObjectiveEligibilityThresholdSelected = FALSE,
    DiagnoseDefinesEligibility = FALSE,
    CalibrationDataGenerationPermitted = FALSE,
    ThresholdSelectionPermitted = FALSE,
    BootstrapPermitted = FALSE, EarlyStoppingPermitted = FALSE,
    PackageVersions = c(
      glmmTMB = as.character(utils::packageVersion("glmmTMB")),
      TMB = as.character(utils::packageVersion("TMB")),
      numDeriv = as.character(utils::packageVersion("numDeriv")),
      digest = as.character(utils::packageVersion("digest"))
    ),
    FunctionHashes = mfrmr_gtwst_function_hashes(), Sources = sources
  )
  structure(c(identity, list(
    ContractHash = mfrmr_gta_hash(identity), ManifestReady = FALSE,
    StabilizationRunnerImplemented = FALSE,
    StabilizationExecutionAuthorized = FALSE,
    NumericalStabilizationReady = FALSE,
    NumericalSensitivityEvidenceReady = FALSE,
    CalibrationEvidenceReady = FALSE,
    BootstrapOperatingCharacteristicsReady = FALSE,
    ThresholdFrozen = FALSE, ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwst_contract")
}

mfrmr_gtwst_validate_profile_graph <- function(profiles) {
  required <- c(
    "ExecutionOrder", "ProfileId", "Algorithm", "ParentProfileId",
    "StartRule", "LineageRole", "ControlId", "IsColdRoot", "ProfileHash"
  )
  if (!is.data.frame(profiles) || !all(required %in% names(profiles)) ||
      nrow(profiles) != 6L || anyDuplicated(profiles$ProfileId) ||
      anyDuplicated(profiles$ProfileHash)) return(FALSE)
  roots <- profiles$ParentProfileId == "none"
  if (sum(roots) != 2L || !all(profiles$ExecutionOrder[roots] == 1L) ||
      !all(profiles$IsColdRoot == roots) ||
      !all(profiles$StartRule[roots] == "NULL_cold")) return(FALSE)
  children <- which(!roots)
  parent_index <- match(profiles$ParentProfileId[children],
                        profiles$ProfileId)
  if (anyNA(parent_index) ||
      !all(profiles$ExecutionOrder[parent_index] <
           profiles$ExecutionOrder[children]) ||
      !all(profiles$StartRule[children] ==
           "exact_all_blocks_from_parent_same_model")) return(FALSE)
  identical(as.integer(sort(table(profiles$Algorithm))), c(3L, 3L))
}

mfrmr_gtwst_manifest <- function(contract, numerical_execution) {
  if (!inherits(contract, "mfrmr_gtwst_contract") ||
      !mfrmr_gtwz_validate_numerical(numerical_execution) ||
      !identical(contract$NumericalSensitivityExecutionHash,
                 numerical_execution$ExecutionHash) ||
      !mfrmr_gtwst_validate_profile_graph(contract$Profiles) ||
      isTRUE(contract$StabilizationExecutionAuthorized) ||
      isTRUE(contract$CalibrationDataGenerationPermitted) ||
      isTRUE(contract$ThresholdSelectionPermitted)) {
    stop("A valid design-only stabilization contract is required.",
         call. = FALSE)
  }
  base <- numerical_execution$AtomicRows[
    numerical_execution$AtomicRows$Backend == "glmmTMB" &
      numerical_execution$AtomicRows$IsDefault %in% TRUE, , drop = FALSE
  ]
  base <- base[order(base$RouteId, method = "radix"), , drop = FALSE]
  if (nrow(base) != contract$BaseRouteCount ||
      anyDuplicated(base$RouteId) ||
      length(unique(base$DatasetId)) != contract$IndependentDatasetCount ||
      !all(table(base$DatasetId) == contract$MethodCountPerDataset)) {
    stop("The exact 1,500 b1e default glmmTMB routes are required.",
         call. = FALSE)
  }
  base_columns <- c(
    "ScenarioId", "Replicate", "DatasetId", "Seed", "RouteId",
    "MethodId", "Backend", "Likelihood", "DesignId", "VarianceId",
    "TargetVariance", "TruthRegion", "EvaluationRole", "RegistryHash",
    "FeasibilityContractHash"
  )
  base <- base[, base_columns, drop = FALSE]
  pieces <- lapply(seq_len(nrow(base)), function(index) {
    route <- base[index, , drop = FALSE]
    route <- route[rep(1L, nrow(contract$Profiles)), , drop = FALSE]
    row.names(route) <- NULL
    cbind(route, contract$Profiles, stringsAsFactors = FALSE)
  })
  rows <- do.call(rbind, pieces)
  row.names(rows) <- NULL
  rows$StabilizationRouteId <- paste(rows$RouteId, rows$ProfileId, sep = "::")
  rows$ParentStabilizationRouteId <- ifelse(
    rows$ParentProfileId == "none", "none",
    paste(rows$RouteId, rows$ParentProfileId, sep = "::")
  )
  rows$StabilizationContractHash <- contract$ContractHash
  rows$SameModelRoleTransferRequired <- TRUE
  rows$ParentFailurePolicy <- contract$ParentFailurePolicy
  rows$CalibrationUse <- FALSE
  rows$ThresholdSelectionPermitted <- FALSE
  exact <- nrow(rows) == contract$PlannedPairs &&
    !anyDuplicated(rows$StabilizationRouteId) &&
    all(table(rows$RouteId) == contract$ProfileCountPerBaseRoute) &&
    all(table(rows$DatasetId) == contract$StabilizationRowsPerDataset) &&
    all(table(rows$ProfileId) == contract$BaseRouteCount) &&
    all(rows$Backend == "glmmTMB") &&
    all(rows$ParentProfileId == "none" |
      rows$ParentStabilizationRouteId %in% rows$StabilizationRouteId)
  if (!exact) stop("Stabilization manifest accounting failed.",
                   call. = FALSE)
  identity <- list(
    Contract =
      "gtheory_weak_information_glmmtmb_stabilization_manifest_draft83d2b2b1g_v1",
    StabilizationContractHash = contract$ContractHash,
    NumericalSensitivityExecutionHash = numerical_execution$ExecutionHash,
    Rows = rows, ExactAccounting = exact
  )
  structure(c(identity, list(
    ManifestHash = mfrmr_gta_hash(identity), PlannedPairs = nrow(rows),
    PlannedBackendFits = 2L * nrow(rows),
    BaseRouteCount = length(unique(rows$RouteId)),
    IndependentDatasetCount = length(unique(rows$DatasetId)),
    ColdRootPairCount = sum(rows$IsColdRoot),
    DependentPairCount = sum(!rows$IsColdRoot),
    ResultsViewedBeforeContract = TRUE,
    CalibrationDataGenerated = FALSE, ManifestReady = exact,
    StabilizationRunnerImplemented = FALSE,
    StabilizationExecutionAuthorized = FALSE,
    NumericalStabilizationReady = FALSE,
    NumericalSensitivityEvidenceReady = FALSE,
    ThresholdFrozen = FALSE, InferenceReady = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwst_manifest")
}
