# Draft.83d2b2b1g8 glmmTMB ML high-accuracy reference coverage.
#
# Repository-internal only. This file applies the frozen b1g6 high-accuracy
# mechanics to a distinct glmmTMB ML objective on nonreserved replicates 901
# and 902. It does not modify b1g6, read calibration, or authorize inference.

mfrmr_gtwab_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtw_registry", "mfrmr_gtw_generate",
    "mfrmr_gtd3_prefit_one", "mfrmr_gtwd_reduced_formula",
    "mfrmr_gtwta_fit_objective", "mfrmr_gtwta_anchored_objective",
    "mfrmr_gtwta_reference", "mfrmr_gtwta_profile_boundary",
    "mfrmr_gtwta_target_theta_index", "mfrmr_gtwta_function_hashes",
    "mfrmr_gtwaa_b1g6_receipt"
  )
  coverage_environment <- environment(mfrmr_gtwab_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = coverage_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the b1g6/b1g7 reference chain before b1g8: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwab_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtwab_source_registry <- function() {
  data.frame(
    SourceId = c(
      "glmmtmb_fit_reference_current", "glmmtmb_control_current",
      "glmmtmb_troubleshooting_current", "tmb_kristensen_2016",
      "more_wild_2012", "shi_xie_xuan_nocedal_2022"
    ),
    Locator = c(
      "https://glmmtmb.github.io/glmmTMB/reference/glmmTMB.html",
      "https://glmmtmb.github.io/glmmTMB/reference/glmmTMBControl.html",
      "https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html",
      "https://doi.org/10.18637/jss.v070.i05",
      "https://doi.org/10.1145/2168773.2168777",
      "https://doi.org/10.1137/21M1452470"
    ),
    ContractRole = c(
      "REML_FALSE identifies maximum likelihood for glmmTMB",
      "optimizer and inner-control identity",
      "restart alternate-optimizer and Hessian diagnostics",
      "automatic differentiation and Laplace objective",
      "finite differences under deterministic computational noise",
      "adaptive interval selection balancing numerical errors"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwab_contract <- function(authorization_audit,
                                   reference_contract) {
  mfrmr_gtwab_require_primitives()
  if (!inherits(authorization_audit, "mfrmr_gtwaa_contract") ||
      !identical(
        authorization_audit$AuthorizationAuditHash,
        "b293987e768ec0e998d3224a6df0689f0ab8b6f2268704ef422e333865d82765"
      ) || !isTRUE(authorization_audit$PreauthorizationAuditReady) ||
      isTRUE(authorization_audit$CalibrationAuthorizationReady) ||
      isTRUE(authorization_audit$CalibrationExecutionAuthorized)) {
    stop("The exact fail-closed b1g7 audit is required.", call. = FALSE)
  }
  receipt <- mfrmr_gtwaa_b1g6_receipt()
  if (!inherits(reference_contract, "mfrmr_gtwta_contract") ||
      !identical(reference_contract$ContractHash,
                 receipt$ReferenceContractHash) ||
      !isTRUE(reference_contract$ReferenceToleranceContractFrozen) ||
      isTRUE(reference_contract$CalibrationExecutionAuthorized)) {
    stop("The exact b1g6 reference-mechanics contract is required.",
         call. = FALSE)
  }
  reused <- c(
    "mfrmr_gtwta_tolerance_policy", "mfrmr_gtwta_derivative_audit",
    "mfrmr_gtwta_curvature_state", "mfrmr_gtwta_stationarity_state",
    "mfrmr_gtwta_solver_one", "mfrmr_gtwta_starts",
    "mfrmr_gtwta_newton_polish", "mfrmr_gtwta_reference",
    "mfrmr_gtwta_profile_boundary", "mfrmr_gtwta_target_theta_index",
    "mfrmr_gtwta_fit_objective", "mfrmr_gtwta_anchored_objective"
  )
  upstream_hashes <- mfrmr_gtwta_function_hashes()
  identity <- list(
    Contract = paste0(
      "gtheory_weak_information_glmmtmb_ml_reference_coverage_",
      "draft83d2b2b1g8_v1"
    ),
    UpstreamB1g7AuthorizationAuditHash =
      authorization_audit$AuthorizationAuditHash,
    UpstreamB1g6Receipt = receipt,
    UpstreamB1g6MechanicsFunctionHashes = upstream_hashes[reused],
    TolerancePolicy = reference_contract$TolerancePolicy,
    TolerancePolicyHash = mfrmr_gta_hash(reference_contract$TolerancePolicy),
    Backend = "glmmTMB", MethodId = "glmmTMB_ml",
    Likelihood = "ML", GlmmTMBREMLArgument = FALSE,
    NonreservedReplicates = c(901L, 902L),
    ReservedReplicates = c(2:3, 101:125, 201:300, 501:700),
    NonreservedScenarioIds = reference_contract$NonreservedScenarioIds,
    ModelRoles = c("full", "reduced"), ObjectiveCount = 4L,
    ReferenceAlgorithms = reference_contract$ReferenceAlgorithms,
    ReferenceStartIds = reference_contract$ReferenceStartIds,
    ReferenceSolverRunsPerObjective =
      reference_contract$ReferenceSolverRunsPerObjective,
    BoundaryProfileFullModelOnly = TRUE,
    GeneratingTruthMayLabelStationarity = FALSE,
    B1g4ObservedMagnitudesMaySetTolerance = FALSE,
    CalibrationReplicatesMayBeRead = FALSE,
    ConfirmationReplicatesMayBeRead = FALSE,
    ReplayMaySelectCandidateCutoff = FALSE,
    Sources = mfrmr_gtwab_source_registry(),
    PackageVersions = c(
      glmmTMB = as.character(utils::packageVersion("glmmTMB")),
      TMB = as.character(utils::packageVersion("TMB")),
      numDeriv = as.character(utils::packageVersion("numDeriv")),
      R = as.character(getRversion())
    ),
    FunctionHashes = mfrmr_gtwab_function_hashes()
  )
  structure(c(identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    B1g6MechanicsBound = TRUE, MLObjectiveIdentityFrozen = TRUE,
    NonreservedMLReplayAuthorized = TRUE,
    NonreservedMLReplayReady = FALSE,
    GlmmTMBMethodCoverageReady = FALSE,
    ReferenceReadyMethodCount = 1L,
    ReferenceMethodCoverageComplete = FALSE,
    CalibrationAuthorizationReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE, CalibrationResultsViewed = FALSE,
    StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    FullExecutionAuthorized = FALSE, ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwab_contract")
}

mfrmr_gtwab_manifest <- function(contract,
                                   registry = mfrmr_gtw_registry()) {
  if (!inherits(contract, "mfrmr_gtwab_contract") ||
      !isTRUE(contract$NonreservedMLReplayAuthorized) ||
      isTRUE(contract$CalibrationExecutionAuthorized) ||
      !identical(contract$Likelihood, "ML") ||
      !identical(contract$GlmmTMBREMLArgument, FALSE)) {
    stop("An intact non-authorizing b1g8 ML contract is required.",
         call. = FALSE)
  }
  cells <- registry$Cells[match(
    contract$NonreservedScenarioIds, registry$Cells$ScenarioId
  ), , drop = FALSE]
  rows <- data.frame(
    ScenarioId = cells$ScenarioId,
    Replicate = contract$NonreservedReplicates,
    DatasetId = sprintf(
      "%s/R%04d", cells$ScenarioId, contract$NonreservedReplicates
    ),
    Seed = cells$SeedStart + contract$NonreservedReplicates - 1L,
    DesignId = cells$DesignId, VarianceId = cells$VarianceId,
    MethodId = contract$MethodId, Backend = contract$Backend,
    Likelihood = contract$Likelihood, GlmmTMBREMLArgument = FALSE,
    ModelRoleCount = 2L,
    ReferenceSolverRunsPerObjective =
      contract$ReferenceSolverRunsPerObjective,
    CalibrationUse = FALSE, CandidateCutoffSelectionPermitted = FALSE,
    CalibrationExecutionAuthorized = FALSE, stringsAsFactors = FALSE
  )
  rows$RouteId <- paste(rows$DatasetId, rows$MethodId, sep = "::")
  if (anyNA(cells$ScenarioId) ||
      any(rows$Replicate %in% contract$ReservedReplicates) ||
      anyDuplicated(rows$Seed) || anyDuplicated(rows$RouteId) ||
      nrow(rows) != 2L) {
    stop("The b1g8 ML manifest escaped its nonreserved band.",
         call. = FALSE)
  }
  identity <- list(
    Contract = "glmmtmb_ml_reference_nonreserved_manifest_b1g8_v1",
    ReferenceCoverageContractHash = contract$ContractHash,
    RegistryHash = registry$RegistryHash, Rows = rows
  )
  structure(c(identity, list(
    ManifestHash = mfrmr_gta_hash(identity), DatasetCount = nrow(rows),
    ObjectiveCount = sum(rows$ModelRoleCount),
    PlannedSolverRunCount = sum(
      rows$ModelRoleCount * rows$ReferenceSolverRunsPerObjective
    ),
    ExecutionAuthorized = TRUE, CalibrationUse = FALSE,
    DataGenerated = FALSE, ResultsViewed = FALSE
  )), class = "mfrmr_gtwab_manifest")
}

mfrmr_gtwab_manifest_hash_valid <- function(manifest) {
  fields <- c(
    "Contract", "ReferenceCoverageContractHash", "RegistryHash", "Rows"
  )
  inherits(manifest, "mfrmr_gtwab_manifest") &&
    all(fields %in% names(manifest)) && identical(
      manifest$ManifestHash, mfrmr_gta_hash(manifest[fields])
    )
}

mfrmr_gtwab_reference_one <- function(formula, data, model_role,
                                        manifest_row, policy) {
  fit_result <- tryCatch(
    mfrmr_gtwta_fit_objective(formula, data, reml = FALSE),
    error = function(error) error
  )
  base_row <- data.frame(
    DatasetId = manifest_row$DatasetId,
    RouteId = manifest_row$RouteId,
    ScenarioId = manifest_row$ScenarioId,
    Replicate = manifest_row$Replicate,
    MethodId = manifest_row$MethodId,
    Backend = manifest_row$Backend,
    Likelihood = manifest_row$Likelihood,
    GlmmTMBREMLArgument = FALSE,
    ModelRole = model_role,
    stringsAsFactors = FALSE
  )
  if (inherits(fit_result, "error")) {
    sidecar <- list(
      FitCallIdentity = list(
        Backend = "glmmTMB", Likelihood = "ML", REML = FALSE
      ),
      ModelRole = model_role,
      Error = conditionMessage(fit_result)
    )
    row <- cbind(base_row, data.frame(
      FitReturned = FALSE, ReferenceState = "not_evaluable",
      ConsensusPassed = FALSE, DerivativeAgreementPassed = FALSE,
      CurvatureState = "not_evaluable", BoundaryState = "not_evaluable",
      PolishedObjective = NA_real_, RawGradientMaximumAbsolute = NA_real_,
      NewtonDecrement = NA_real_, SidecarHash = mfrmr_gta_hash(sidecar),
      CalibrationUse = FALSE, stringsAsFactors = FALSE
    ))
    return(list(Row = row, Sidecar = sidecar))
  }
  fit <- fit_result$Fit
  objective <- mfrmr_gtwta_anchored_objective(fit)
  reference <- mfrmr_gtwta_reference(
    objective$Fn, objective$Gr, fit$fit$par, policy
  )
  boundary <- NULL
  if (identical(model_role, "full") &&
      !identical(reference$SidecarHash, "none")) {
    target_index <- mfrmr_gtwta_target_theta_index(fit, "Rater")
    boundary <- mfrmr_gtwta_profile_boundary(
      objective$Fn, objective$Gr,
      reference$Sidecar$PolishedParameter, target_index, policy
    )
  }
  boundary_state <- if (is.null(boundary)) {
    "not_applicable"
  } else if (!isTRUE(boundary$Available)) {
    "not_evaluable"
  } else if (isTRUE(boundary$MonotoneTowardBoundary) &&
             isTRUE(boundary$MaterialImprovementTowardBoundary)) {
    "boundary_direction_supported"
  } else {
    "finite_interior_supported"
  }
  sidecar <- list(
    FitCallIdentity = list(
      Backend = "glmmTMB", Likelihood = "ML", REML = FALSE
    ),
    ModelRole = model_role,
    Reference = reference$Sidecar,
    BoundaryProfile = if (is.null(boundary)) list() else boundary$Rows,
    Warnings = fit_result$Warnings, Messages = fit_result$Messages,
    RandomStartAnchorHash = objective$RandomStartAnchorHash,
    RandomStartExpression = objective$RandomStartExpression,
    InnerMethod = objective$InnerMethod,
    InnerControl = objective$InnerControl,
    RandomEffectDimension = objective$RandomEffectDimension,
    ResetRandomStartBeforeEveryEvaluation = TRUE,
    ReportedParameter = unname(fit$fit$par),
    ReportedObjective = as.numeric(fit$fit$objective)
  )
  row <- cbind(base_row, data.frame(
    FitReturned = TRUE, ReferenceState = reference$State,
    ConsensusPassed = reference$ConsensusPassed,
    DerivativeAgreementPassed = reference$DerivativeAgreementPassed,
    CurvatureState = reference$CurvatureState,
    BoundaryState = boundary_state,
    PolishedObjective = reference$PolishedObjective,
    RawGradientMaximumAbsolute = reference$RawGradientMaximumAbsolute,
    NewtonDecrement = reference$NewtonDecrement,
    SidecarHash = mfrmr_gta_hash(sidecar), CalibrationUse = FALSE,
    stringsAsFactors = FALSE
  ))
  list(Row = row, Sidecar = sidecar)
}

mfrmr_gtwab_coverage_ledger <- function(ml_replay_ready = FALSE) {
  data.frame(
    MethodId = c("glmmTMB_ml", "glmmTMB_reml", "lme4_ml", "lme4_reml"),
    Backend = c("glmmTMB", "glmmTMB", "lme4", "lme4"),
    Likelihood = c("ML", "REML", "ML", "REML"),
    ReferenceMechanicsState = c(
      if (isTRUE(ml_replay_ready)) "b1g8_nonreserved_ML_passed" else
        "b1g8_nonreserved_ML_not_ready",
      "b1g6_nonreserved_REML_passed",
      "lme4_reference_not_implemented",
      "lme4_reference_not_implemented"
    ),
    ReferenceMechanicsReady = c(
      isTRUE(ml_replay_ready), TRUE, FALSE, FALSE
    ),
    CalibrationExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwab_execute <- function(contract, manifest,
                                  registry = mfrmr_gtw_registry()) {
  if (!inherits(contract, "mfrmr_gtwab_contract") ||
      !inherits(manifest, "mfrmr_gtwab_manifest") ||
      !mfrmr_gtwab_manifest_hash_valid(manifest) ||
      !identical(manifest$ReferenceCoverageContractHash,
                 contract$ContractHash) ||
      !isTRUE(manifest$ExecutionAuthorized) ||
      isTRUE(manifest$CalibrationUse) ||
      any(manifest$Rows$Replicate %in% contract$ReservedReplicates) ||
      !all(manifest$Rows$Likelihood == "ML") ||
      any(manifest$Rows$GlmmTMBREMLArgument)) {
    stop("The exact nonreserved b1g8 ML replay is not authorized.",
         call. = FALSE)
  }
  policy <- contract$TolerancePolicy
  outputs <- list()
  row_index <- 0L
  dataset_hashes <- character(nrow(manifest$Rows))
  for (dataset_index in seq_len(nrow(manifest$Rows))) {
    manifest_row <- manifest$Rows[dataset_index, , drop = FALSE]
    generation <- mfrmr_gtw_generate(
      registry, manifest_row$ScenarioId[[1L]],
      manifest_row$Replicate[[1L]]
    )
    prefit <- mfrmr_gtd3_prefit_one(generation)
    if (!isTRUE(prefit$PreFitEligible)) {
      stop("The b1g8 nonreserved ML replay failed structural pre-fit.",
           call. = FALSE)
    }
    data <- prefit$StructuralRankAudit$PreparedData$Data
    formulas <- list(
      full = stats::as.formula(generation$Spec$FormulaCanonical),
      reduced = mfrmr_gtwd_reduced_formula(generation$Spec, "Rater")
    )
    dataset_hashes[[dataset_index]] <- generation$GeneratorHash
    dataset_outputs <- list()
    for (model_role in names(formulas)) {
      row_index <- row_index + 1L
      result <- mfrmr_gtwab_reference_one(
        formulas[[model_role]], data, model_role, manifest_row, policy
      )
      outputs[[row_index]] <- result
      dataset_outputs[[model_role]] <- result
    }
    full <- dataset_outputs$full
    reduced <- dataset_outputs$reduced
    comparison <- list(
      State = "not_required", ProfileFinalObjective = NA_real_,
      ReducedObjective = reduced$Row$PolishedObjective,
      RelativeTolerance = NA_real_, Matched = NA
    )
    if (identical(full$Row$BoundaryState,
                  "boundary_direction_supported") &&
        is.finite(full$Row$PolishedObjective) &&
        is.finite(reduced$Row$PolishedObjective)) {
      profile_final <- tail(full$Sidecar$BoundaryProfile$Objective, 1L)
      tolerance <- policy$BoundaryObjectiveRelativeTolerance * max(
        1, abs(profile_final), abs(reduced$Row$PolishedObjective)
      )
      matched <- abs(profile_final - reduced$Row$PolishedObjective) <=
        tolerance
      comparison <- list(
        State = if (matched) "matched" else "not_matched",
        ProfileFinalObjective = profile_final,
        ReducedObjective = reduced$Row$PolishedObjective,
        RelativeTolerance = tolerance, Matched = matched
      )
      full$Row$BoundaryState <- if (matched) {
        "boundary_limit_supported"
      } else {
        "boundary_profile_not_reduced_matched"
      }
      if (matched) full$Row$ReferenceState <- "boundary_limit"
    }
    full$Sidecar$BoundaryReducedMatch <- comparison
    full$Row$SidecarHash <- mfrmr_gta_hash(full$Sidecar)
    outputs[[row_index - 1L]] <- full
  }
  rows <- do.call(rbind, lapply(outputs, `[[`, "Row"))
  row.names(rows) <- NULL
  sidecars <- lapply(outputs, `[[`, "Sidecar")
  sidecar_valid <- vapply(seq_along(sidecars), function(index) {
    identical(mfrmr_gta_hash(sidecars[[index]]),
              rows$SidecarHash[[index]])
  }, logical(1L))
  boundary_ready <- all(
    rows$BoundaryState[rows$ModelRole == "full"] %in%
      c("finite_interior_supported", "boundary_limit_supported")
  ) && all(rows$BoundaryState[rows$ModelRole == "reduced"] ==
             "not_applicable")
  ready <- nrow(rows) == manifest$ObjectiveCount &&
    all(rows$FitReturned) && all(rows$ConsensusPassed) &&
    all(rows$DerivativeAgreementPassed) &&
    all(!rows$ReferenceState %in%
          c("reference_unresolved", "not_evaluable")) &&
    all(rows$Likelihood == "ML") &&
    all(!rows$GlmmTMBREMLArgument) && boundary_ready &&
    all(sidecar_valid) && all(!rows$CalibrationUse)
  coverage <- mfrmr_gtwab_coverage_ledger(ready)
  identity <- list(
    Contract = "glmmtmb_ml_reference_nonreserved_execution_b1g8_v1",
    ReferenceCoverageContractHash = contract$ContractHash,
    ManifestHash = manifest$ManifestHash,
    GeneratorHashes = dataset_hashes,
    Rows = rows, SidecarHashes = rows$SidecarHash,
    CoverageLedger = coverage
  )
  structure(c(identity, list(
    ExecutionHash = mfrmr_gta_hash(identity), Sidecars = sidecars,
    ExactAccountingPassed = nrow(rows) == manifest$ObjectiveCount,
    FitReturnCount = sum(rows$FitReturned),
    ReferenceResolvedCount = sum(!rows$ReferenceState %in%
      c("reference_unresolved", "not_evaluable")),
    ConsensusPassCount = sum(rows$ConsensusPassed),
    DerivativeAgreementPassCount = sum(rows$DerivativeAgreementPassed),
    BoundaryProfilePassCount = sum(
      rows$ModelRole == "full" & rows$BoundaryState %in%
        c("finite_interior_supported", "boundary_limit_supported")
    ),
    SidecarValidationPassed = all(sidecar_valid),
    NonreservedMLReplayReady = ready,
    GlmmTMBMethodCoverageReady = ready,
    ReferenceReadyMethodCount = sum(coverage$ReferenceMechanicsReady),
    ReferenceMethodCoverageComplete =
      all(coverage$ReferenceMechanicsReady),
    CalibrationAuthorizationReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE, CalibrationResultsViewed = FALSE,
    StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    FullExecutionAuthorized = FALSE, ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwab_execution")
}

mfrmr_gtwab_execution_hash_valid <- function(execution) {
  fields <- c(
    "Contract", "ReferenceCoverageContractHash", "ManifestHash",
    "GeneratorHashes", "Rows", "SidecarHashes", "CoverageLedger"
  )
  inherits(execution, "mfrmr_gtwab_execution") &&
    all(fields %in% names(execution)) && identical(
      execution$ExecutionHash, mfrmr_gta_hash(execution[fields])
    ) && length(execution$Sidecars) == nrow(execution$Rows) &&
    all(vapply(seq_along(execution$Sidecars), function(index) {
      identical(mfrmr_gta_hash(execution$Sidecars[[index]]),
                execution$Rows$SidecarHash[[index]])
    }, logical(1L)))
}

mfrmr_gtwab_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwab_source_registry", "mfrmr_gtwab_contract",
    "mfrmr_gtwab_manifest", "mfrmr_gtwab_manifest_hash_valid",
    "mfrmr_gtwab_reference_one", "mfrmr_gtwab_coverage_ledger",
    "mfrmr_gtwab_execute", "mfrmr_gtwab_execution_hash_valid"
  )
  coverage_environment <- environment(mfrmr_gtwab_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwab_function_hash(get(
      name, envir = coverage_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}
