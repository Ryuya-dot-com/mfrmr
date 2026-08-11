# Draft.83d2b2b1g7 stationarity-calibration authorization audit.
#
# Repository-internal only. This file corrects backend/profile accounting,
# freezes a truth-blind candidate-state algebra and a metric-independent
# profile aggregator, and audits method-specific reference coverage. It does
# not generate replicate 201, authorize calibration, or inspect confirmation.

mfrmr_gtwaa_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtwsz_manifest_hash_valid",
    "mfrmr_gtwta_execution_hash_valid", "mfrmr_gtwst_profiles",
    "mfrmr_gtwy_profiles"
  )
  audit_environment <- environment(mfrmr_gtwaa_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = audit_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the b1g5/b1g6 and backend-profile chains before b1g7: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwaa_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtwaa_source_registry <- function() {
  data.frame(
    SourceId = c(
      "lme4_lmercontrol_current", "lme4_allfit_current",
      "glmmTMB_control_current", "glmmTMB_troubleshooting_current",
      "morris_white_crowther_2019"
    ),
    Locator = c(
      "https://lme4.github.io/lme4/reference/lmerControl.html",
      "https://lme4.github.io/lme4/reference/allFit.html",
      "https://glmmtmb.github.io/glmmTMB/reference/glmmTMBControl.html",
      "https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html",
      "https://doi.org/10.1002/sim.8086"
    ),
    ContractRole = c(
      "lme4 optimizer controls derivative checks and boundary restart",
      "lme4 backend-specific multi-optimizer comparison",
      "glmmTMB optimizer and control identity",
      "glmmTMB restart alternate optimizer and Hessian diagnostics",
      "ADEMP simulation design and complete failure accounting"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwaa_profile_registry <- function() {
  mfrmr_gtwaa_require_primitives()
  glmm <- mfrmr_gtwst_profiles()
  glmm <- data.frame(
    Backend = "glmmTMB", ProfileId = glmm$ProfileId,
    ProfilePriority = seq_len(nrow(glmm)), Algorithm = glmm$Algorithm,
    ParentProfileId = glmm$ParentProfileId,
    ControlId = glmm$ControlId, ProfileHash = glmm$ProfileHash,
    RegistrySource = "b1g_glmmTMB_six_profile_DAG",
    stringsAsFactors = FALSE
  )
  lme4 <- mfrmr_gtwy_profiles()
  lme4 <- lme4[lme4$Backend == "lme4", , drop = FALSE]
  lme4 <- data.frame(
    Backend = "lme4", ProfileId = lme4$ProfileId,
    ProfilePriority = seq_len(nrow(lme4)), Algorithm = lme4$Algorithm,
    ParentProfileId = "none", ControlId = lme4$ControlDescription,
    ProfileHash = lme4$ProfileHash,
    RegistrySource = "b1e_lme4_three_profile_audit",
    stringsAsFactors = FALSE
  )
  rows <- rbind(glmm, lme4)
  if (anyDuplicated(rows[c("Backend", "ProfileId")]) ||
      !identical(as.integer(table(rows$Backend)[c("glmmTMB", "lme4")]),
                 c(6L, 3L))) {
    stop("The backend-specific profile registry changed.", call. = FALSE)
  }
  row.names(rows) <- NULL
  rows
}

mfrmr_gtwaa_method_lanes <- function() {
  profiles <- mfrmr_gtwaa_profile_registry()
  profile_count <- table(profiles$Backend)
  rows <- data.frame(
    MethodId = c("glmmTMB_ml", "glmmTMB_reml", "lme4_ml", "lme4_reml"),
    Backend = c("glmmTMB", "glmmTMB", "lme4", "lme4"),
    Likelihood = c("ML", "REML", "ML", "REML"),
    BaseMethodUnits = 3000L,
    ModelRolesPerUnit = 2L,
    stringsAsFactors = FALSE
  )
  rows$BackendProfileCount <- as.integer(profile_count[rows$Backend])
  rows$CorrectedCandidateFitCount <- with(
    rows, BaseMethodUnits * ModelRolesPerUnit * BackendProfileCount
  )
  rows$ReferenceProblemCount <- with(
    rows, BaseMethodUnits * ModelRolesPerUnit
  )
  rows$ReferenceMechanicsState <- c(
    "nonreserved_ML_replay_not_run",
    "b1g6_nonreserved_REML_passed",
    "lme4_reference_not_implemented",
    "lme4_reference_not_implemented"
  )
  rows$ReferenceMechanicsReady <- c(FALSE, TRUE, FALSE, FALSE)
  rows$CalibrationExecutionAuthorized <- FALSE
  rows
}

mfrmr_gtwaa_first_order_state <- function(score, eligible_upper,
                                            ineligible_lower) {
  score <- as.numeric(score)
  eligible_upper <- as.numeric(eligible_upper)
  ineligible_lower <- as.numeric(ineligible_lower)
  if (length(score) != 1L || length(eligible_upper) != 1L ||
      length(ineligible_lower) != 1L || !is.finite(eligible_upper) ||
      !is.finite(ineligible_lower) || eligible_upper < 0 ||
      ineligible_lower <= eligible_upper) {
    stop("One valid ordered nonnegative candidate zone is required.",
         call. = FALSE)
  }
  if (!is.finite(score) || score < 0) return("not_evaluable")
  if (score <= eligible_upper) return("stationary_zone")
  if (score < ineligible_lower) return("indeterminate_zone")
  "nonstationary_zone"
}

mfrmr_gtwaa_candidate_state <- function(
    score, eligible_upper, ineligible_lower, curvature_state,
    boundary_probe_state = "not_run") {
  curvature_state <- as.character(curvature_state)
  boundary_probe_state <- as.character(boundary_probe_state)
  allowed_curvature <- c(
    "positive_definite_factorable", "spectral_positive_not_factorable",
    "near_singular_or_semidefinite", "indefinite", "not_evaluable"
  )
  allowed_boundary <- c(
    "finite_interior_supported", "boundary_limit_supported",
    "boundary_probe_inconclusive", "not_run", "not_evaluable"
  )
  if (length(curvature_state) != 1L ||
      !curvature_state %in% allowed_curvature ||
      length(boundary_probe_state) != 1L ||
      !boundary_probe_state %in% allowed_boundary) {
    stop("One registered curvature and boundary state is required.",
         call. = FALSE)
  }
  first_order <- mfrmr_gtwaa_first_order_state(
    score, eligible_upper, ineligible_lower
  )
  application <- if (boundary_probe_state == "not_evaluable") {
    "not_evaluable"
  } else if (boundary_probe_state == "boundary_limit_supported") {
    "boundary_handoff"
  } else if (boundary_probe_state == "boundary_probe_inconclusive") {
    "indeterminate"
  } else if (first_order == "not_evaluable" ||
             curvature_state == "not_evaluable") {
    "not_evaluable"
  } else if (first_order == "nonstationary_zone" ||
             curvature_state == "indefinite") {
    "numerically_ineligible"
  } else if (first_order == "indeterminate_zone" ||
             curvature_state %in% c(
               "spectral_positive_not_factorable",
               "near_singular_or_semidefinite"
             )) {
    "indeterminate"
  } else {
    "numerically_eligible"
  }
  data.frame(
    FirstOrderState = first_order,
    CurvatureState = curvature_state,
    BoundaryProbeState = boundary_probe_state,
    ApplicationState = application,
    GeneratingTruthUsed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwaa_select_profile <- function(fit_rows, backend,
                                         profiles =
                                           mfrmr_gtwaa_profile_registry()) {
  backend <- as.character(backend)
  registry <- profiles[profiles$Backend == backend, , drop = FALSE]
  required <- c("ProfileId", "FitReturned", "Objective")
  if (length(backend) != 1L || nrow(registry) == 0L ||
      !is.data.frame(fit_rows) || !all(required %in% names(fit_rows)) ||
      !is.logical(fit_rows$FitReturned) ||
      !is.numeric(fit_rows$Objective) ||
      anyDuplicated(fit_rows$ProfileId) ||
      !setequal(fit_rows$ProfileId, registry$ProfileId)) {
    stop("One complete backend-specific profile ledger is required.",
         call. = FALSE)
  }
  order_index <- match(registry$ProfileId, fit_rows$ProfileId)
  ordered <- fit_rows[order_index, , drop = FALSE]
  available <- which(ordered$FitReturned & is.finite(ordered$Objective))
  if (length(available) == 0L) {
    return(data.frame(
      Backend = backend, SelectionState = "not_evaluable",
      SelectedProfileId = "none", SelectedObjective = NA_real_,
      AvailableProfileCount = 0L,
      PlannedProfileCount = nrow(registry),
      MetricUsedToSelectProfile = FALSE, stringsAsFactors = FALSE
    ))
  }
  best <- available[[which.min(ordered$Objective[available])]]
  data.frame(
    Backend = backend, SelectionState = "best_observed_finite_objective",
    SelectedProfileId = ordered$ProfileId[[best]],
    SelectedObjective = ordered$Objective[[best]],
    AvailableProfileCount = length(available),
    PlannedProfileCount = nrow(registry),
    MetricUsedToSelectProfile = FALSE, stringsAsFactors = FALSE
  )
}

mfrmr_gtwaa_b1g6_receipt <- function() {
  list(
    ReferenceContractHash =
      "60e04706736c0e7273dfa321d0d41a3a9ed4bb8362a0b7d428f8507653ecce9a",
    ReferenceManifestHash =
      "87b42667d3dbeb2ecd045b23b32cf23a5f9919b0d26ac75c5771baf691770d3a",
    ReferenceExecutionHash =
      "28f155c91065cb56ebe695234eab7867392e25fe413ab362717e760f5e775e72",
    LikelihoodCovered = "REML", BackendCovered = "glmmTMB",
    NonreservedReplicates = c(901L, 902L)
  )
}

mfrmr_gtwaa_b1g6_execution_valid <- function(execution) {
  receipt <- mfrmr_gtwaa_b1g6_receipt()
  inherits(execution, "mfrmr_gtwta_execution") &&
    mfrmr_gtwta_execution_hash_valid(execution) &&
    identical(execution$ReferenceContractHash,
              receipt$ReferenceContractHash) &&
    identical(execution$ManifestHash, receipt$ReferenceManifestHash) &&
    identical(execution$ExecutionHash, receipt$ReferenceExecutionHash) &&
    isTRUE(execution$NonreservedReplayReady) &&
    isTRUE(execution$ReferenceToleranceFrozen) &&
    !isTRUE(execution$CalibrationExecutionAuthorized) &&
    !isTRUE(execution$InferenceReady)
}

mfrmr_gtwaa_contract <- function(design_contract, design_manifest,
                                   reference_contract,
                                   reference_manifest) {
  mfrmr_gtwaa_require_primitives()
  if (!inherits(design_contract, "mfrmr_gtwsz_contract") ||
      !inherits(design_manifest, "mfrmr_gtwsz_manifest") ||
      !mfrmr_gtwsz_manifest_hash_valid(design_manifest) ||
      !identical(
        design_contract$DesignContractHash,
        "278353d1668501d04dd3af4adc96dfcd39b232796057242418f89601b22b99ac"
      ) || !identical(
        design_manifest$ManifestHash,
        "0dbe9e92bed7baa27b6c5f29bed0759a789bcc02c285bd77d749a9cc9666e4d0"
      )) {
    stop("The exact sealed b1g5 design and manifest are required.",
         call. = FALSE)
  }
  receipt <- mfrmr_gtwaa_b1g6_receipt()
  if (!inherits(reference_contract, "mfrmr_gtwta_contract") ||
      !inherits(reference_manifest, "mfrmr_gtwta_manifest") ||
      !identical(reference_contract$ContractHash,
                 receipt$ReferenceContractHash) ||
      !identical(reference_manifest$ManifestHash,
                 receipt$ReferenceManifestHash) ||
      !isTRUE(reference_contract$ReferenceToleranceContractFrozen) ||
      isTRUE(reference_contract$CalibrationExecutionAuthorized)) {
    stop("The exact non-authorizing b1g6 reference contract is required.",
         call. = FALSE)
  }
  profiles <- mfrmr_gtwaa_profile_registry()
  lanes <- mfrmr_gtwaa_method_lanes()
  identity <- list(
    Contract = paste0(
      "gtheory_weak_information_stationarity_calibration_",
      "authorization_audit_draft83d2b2b1g7_v1"
    ),
    UpstreamB1g5DesignContractHash = design_contract$DesignContractHash,
    UpstreamB1g5ManifestHash = design_manifest$ManifestHash,
    UpstreamB1g6Receipt = receipt,
    Profiles = profiles,
    MethodLanes = lanes,
    ProfileAggregationUnit = "dataset_method_model_role",
    PrimaryProfileAggregation =
      "minimum_finite_objective_then_frozen_profile_priority",
    MetricMaySelectOptimizerProfile = FALSE,
    CandidateRuleMayUseGeneratingTruth = FALSE,
    CandidateStateOrder = c(
      "boundary_probe", "first_order_zone", "curvature_gate",
      "application_state"
    ),
    FactorabilityRequiredForNumericallyEligible = TRUE,
    SpectralPositiveNotFactorableState = "indeterminate",
    NearSingularState = "indeterminate",
    IndefiniteState = "numerically_ineligible",
    CandidateBoundaryProbeImplemented = FALSE,
    CalibrationReplicateRange = 201:300,
    ConfirmationReplicateRange = 501:700,
    ConfirmationMayBeRead = FALSE,
    OriginalB1g5CandidateFitCount = 144000L,
    CorrectedCandidateFitCount = sum(lanes$CorrectedCandidateFitCount),
    CorrectedCandidateFitCountInterpretation =
      "planned_upper_bound_if_every_registered_profile_is_evaluated",
    CandidateFitOvercount = 144000L -
      sum(lanes$CorrectedCandidateFitCount),
    CorrectedReferenceProblemCount = sum(lanes$ReferenceProblemCount),
    ReferenceCoverageRequiredForAuthorization =
      "backend_by_likelihood_nonreserved_pass",
    CheckpointAtomicUnit =
      "one_dataset_method_all_backend_profiles_both_model_roles_and_references",
    CandidateFitObjectsRetained = FALSE,
    RandomEffectModesRetained = FALSE,
    OriginalDataDuplicatedInSidecars = FALSE,
    RequiredCheckpointCounts = c(
      MethodUnitCheckpoints = 12000L, DatasetCompletionMarkers = 3000L
    ),
    Sources = mfrmr_gtwaa_source_registry(),
    FunctionHashes = mfrmr_gtwaa_function_hashes()
  )
  method_coverage_complete <- all(lanes$ReferenceMechanicsReady)
  structure(c(identity, list(
    AuthorizationAuditHash = mfrmr_gta_hash(identity),
    PreauthorizationAuditReady = TRUE,
    CalibrationAuthorizationReady = FALSE,
    BackendProfileAccountingReady = TRUE,
    WorkloadCorrectionReady = TRUE,
    CandidateStateAlgebraReady = TRUE,
    PrimaryProfileAggregationReady = TRUE,
    B1g6ReceiptBound = TRUE,
    ReferenceMethodCoverageComplete = method_coverage_complete,
    AcceptancePolicyFrozen = FALSE,
    RunnerImplementationReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE, CalibrationResultsViewed = FALSE,
    StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    FullExecutionAuthorized = FALSE, ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwaa_contract")
}

mfrmr_gtwaa_manifest <- function(contract, design_manifest) {
  if (!inherits(contract, "mfrmr_gtwaa_contract") ||
      !inherits(design_manifest, "mfrmr_gtwsz_manifest") ||
      !identical(contract$UpstreamB1g5ManifestHash,
                 design_manifest$ManifestHash) ||
      isTRUE(contract$CalibrationExecutionAuthorized)) {
    stop("An intact non-authorizing b1g7 audit is required.", call. = FALSE)
  }
  rows <- design_manifest$Rows
  profile_count <- stats::setNames(
    contract$MethodLanes$BackendProfileCount,
    contract$MethodLanes$MethodId
  )
  reference_state <- stats::setNames(
    contract$MethodLanes$ReferenceMechanicsState,
    contract$MethodLanes$MethodId
  )
  rows$OriginalB1g5ProfileCountPerModelRole <-
    rows$ProfileCountPerModelRole
  rows$BackendProfileCountPerModelRole <-
    as.integer(profile_count[rows$MethodId])
  rows$OriginalB1g5CandidateFitCount <- rows$CandidateFitCount
  rows$CorrectedCandidateFitCount <-
    rows$ModelRoleCount * rows$BackendProfileCountPerModelRole
  rows$ReferenceMechanicsState <- unname(reference_state[rows$MethodId])
  rows$NumericalCalibrationExecutionAuthorized <- FALSE
  rows$RuleSelectionPermitted <- FALSE
  rows$ConfirmationUse <- FALSE
  rows$StatisticalResolutionUseAuthorized <- FALSE
  if (anyNA(rows$BackendProfileCountPerModelRole) ||
      any(rows$Replicate < 201L | rows$Replicate > 300L) ||
      any(rows$Replicate %in% contract$ConfirmationReplicateRange)) {
    stop("The corrected audit manifest escaped its sealed calibration band.",
         call. = FALSE)
  }
  identity <- list(
    Contract = paste0(
      "gtheory_weak_information_stationarity_calibration_",
      "authorization_audit_manifest_draft83d2b2b1g7_v1"
    ),
    AuthorizationAuditHash = contract$AuthorizationAuditHash,
    UpstreamB1g5ManifestHash = design_manifest$ManifestHash,
    Rows = rows
  )
  structure(c(identity, list(
    ManifestHash = mfrmr_gta_hash(identity),
    BaseMethodUnitCount = nrow(rows),
    IndependentDatasetCount = length(unique(rows$DatasetId)),
    OriginalB1g5CandidateFitCount =
      sum(rows$OriginalB1g5CandidateFitCount),
    CorrectedCandidateFitCount = sum(rows$CorrectedCandidateFitCount),
    CandidateFitOvercount = sum(
      rows$OriginalB1g5CandidateFitCount - rows$CorrectedCandidateFitCount
    ),
    ReferenceProblemCount = sum(rows$ReferenceProblemCount),
    ReferenceReadyMethodCount = sum(
      contract$MethodLanes$ReferenceMechanicsReady
    ),
    ExecutionAuthorized = FALSE, DataGenerated = FALSE,
    ResultsViewed = FALSE, RuleSelectionPermitted = FALSE,
    ConfirmationAuthorized = FALSE
  )), class = "mfrmr_gtwaa_manifest")
}

mfrmr_gtwaa_manifest_hash_valid <- function(manifest) {
  fields <- c(
    "Contract", "AuthorizationAuditHash", "UpstreamB1g5ManifestHash",
    "Rows"
  )
  inherits(manifest, "mfrmr_gtwaa_manifest") &&
    all(fields %in% names(manifest)) && identical(
      manifest$ManifestHash, mfrmr_gta_hash(manifest[fields])
    )
}

mfrmr_gtwaa_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwaa_source_registry", "mfrmr_gtwaa_profile_registry",
    "mfrmr_gtwaa_method_lanes", "mfrmr_gtwaa_first_order_state",
    "mfrmr_gtwaa_candidate_state", "mfrmr_gtwaa_select_profile",
    "mfrmr_gtwaa_b1g6_receipt", "mfrmr_gtwaa_b1g6_execution_valid",
    "mfrmr_gtwaa_contract", "mfrmr_gtwaa_manifest",
    "mfrmr_gtwaa_manifest_hash_valid"
  )
  audit_environment <- environment(mfrmr_gtwaa_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwaa_function_hash(get(
      name, envir = audit_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}
