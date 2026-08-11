# Draft.83d2b2b1g4 prospective, scale-aware stationarity instrumentation.
#
# Repository-internal only. This replays the exact 120-pair b1g2 smoke while
# retaining raw fixed-coordinate derivatives. It measures several coordinate
# summaries but deliberately defines no stationarity cutoff or pass state.

mfrmr_gtwsy_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtwy_function_hash",
    "mfrmr_gtwsw_contract", "mfrmr_gtwsw_runner_environment",
    "mfrmr_gtwsx_alignment_execution_hash_valid"
  )
  audit_environment <- environment(mfrmr_gtwsy_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = audit_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the complete Draft.83d2b2b1g3 chain before b1g4: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwsy_validate_upstream <- function(alignment_execution,
                                            adjudication) {
  inherits(alignment_execution, "mfrmr_gtwsw_execution") &&
    inherits(adjudication, "mfrmr_gtwsx_adjudication") &&
    identical(
      alignment_execution$ExecutionHash,
      "e2716a4ae71784e218d15f2509ed8c15326c1b7c6bc9acf78826a81822581482"
    ) &&
    identical(
      adjudication$ResultHash,
      "c7c35d5b961c578b6234a1f29f628f13dac357bc1b046e012832d28ca7f3d4de"
    ) &&
    mfrmr_gtwsx_alignment_execution_hash_valid(alignment_execution) &&
    identical(adjudication$AlignmentExecutionHash,
              alignment_execution$ExecutionHash) &&
    isTRUE(alignment_execution$ExactAccountingPassed) &&
    isTRUE(alignment_execution$AlignmentMechanicsReady) &&
    isTRUE(adjudication$ExactAccountingPassed) &&
    identical(alignment_execution$PairReturnCount, 120L) &&
    identical(adjudication$PairCount, 120L) &&
    !isTRUE(adjudication$StationarityCriterionReady) &&
    !isTRUE(adjudication$FullExecutionAuthorized) &&
    !isTRUE(adjudication$NumericalStabilizationReady) &&
    !isTRUE(adjudication$CalibrationEvidenceReady) &&
    !isTRUE(adjudication$ThresholdFrozen) &&
    !isTRUE(adjudication$InferenceReady) &&
    !isTRUE(adjudication$DecisionReady)
}

mfrmr_gtwsy_safe_numeric <- function(value) {
  suppressWarnings(as.numeric(value))
}

mfrmr_gtwsy_scale_metrics <- function(parameter, objective, gradient,
                                        hessian) {
  parameter <- mfrmr_gtwsy_safe_numeric(parameter)
  gradient <- mfrmr_gtwsy_safe_numeric(gradient)
  objective <- mfrmr_gtwsy_safe_numeric(objective)
  dimension <- length(parameter)
  raw_available <- dimension > 0L && length(gradient) == dimension &&
    length(objective) == 1L && is.finite(objective) &&
    all(is.finite(parameter)) && all(is.finite(gradient))
  empty <- list(
    RawAvailable = raw_available,
    RawMaximumAbsolute = if (raw_available) max(abs(gradient)) else NA_real_,
    RawL2Norm = if (raw_available) sqrt(sum(gradient^2)) else NA_real_,
    ObjectiveRelativeParameterScaledAvailable = FALSE,
    ObjectiveRelativeParameterScaledMaximumAbsolute = NA_real_,
    HessianAvailable = FALSE, HessianDimension = 0L,
    HessianPositiveDefinite = FALSE, HessianCholeskyAvailable = FALSE,
    HessianReciprocalCondition = NA_real_,
    Lme4ScaledAvailable = FALSE, Lme4ScaledMaximumAbsolute = NA_real_,
    Lme4ScaledL2Norm = NA_real_,
    Lme4MinimumGradientMaximumAbsolute = NA_real_,
    NewtonWhitenedAvailable = FALSE,
    NewtonWhitenedMaximumAbsolute = NA_real_,
    NewtonDecrement = NA_real_, NewtonStepAvailable = FALSE,
    NewtonRelativeStepMaximumAbsolute = NA_real_,
    ObjectiveRelativeParameterScaledGradient = numeric(),
    Lme4ScaledGradient = numeric(), Lme4MinimumGradient = numeric(),
    NewtonWhitenedGradient = numeric(), NewtonStep = numeric()
  )
  if (raw_available) {
    relative_gradient <- gradient * pmax(1, abs(parameter)) /
      max(1, abs(objective))
    empty$ObjectiveRelativeParameterScaledAvailable <- TRUE
    empty$ObjectiveRelativeParameterScaledMaximumAbsolute <-
      max(abs(relative_gradient))
    empty$ObjectiveRelativeParameterScaledGradient <- relative_gradient
  }
  if (!raw_available || !is.matrix(hessian) ||
      any(dim(hessian) != c(dimension, dimension)) ||
      !all(is.finite(hessian))) return(empty)
  symmetric <- (hessian + t(hessian)) / 2
  eigenvalues <- tryCatch(
    eigen(symmetric, symmetric = TRUE, only.values = TRUE)$values,
    error = function(error) numeric()
  )
  if (length(eigenvalues) != dimension || !all(is.finite(eigenvalues))) {
    return(empty)
  }
  empty$HessianAvailable <- TRUE
  empty$HessianDimension <- dimension
  empty$HessianPositiveDefinite <- all(eigenvalues > 0)
  empty$HessianReciprocalCondition <- tryCatch(
    as.numeric(rcond(symmetric, norm = "O")),
    error = function(error) NA_real_
  )
  if (!empty$HessianPositiveDefinite) return(empty)
  factor <- tryCatch(chol(symmetric), error = function(error) NULL)
  if (is.null(factor)) return(empty)
  empty$HessianCholeskyAvailable <- TRUE

  # This vector exactly follows lme4::checkConv(): solve(chol(H), g).
  lme4_scaled <- tryCatch(
    as.numeric(solve(factor, gradient)), error = function(error) numeric()
  )
  # H = R'R, so R^{-T}g has squared norm g'H^{-1}g.
  newton_whitened <- tryCatch(
    as.numeric(solve(t(factor), gradient)),
    error = function(error) numeric()
  )
  newton_step <- tryCatch(
    as.numeric(solve(symmetric, gradient)),
    error = function(error) numeric()
  )
  if (length(lme4_scaled) == dimension && all(is.finite(lme4_scaled))) {
    lme4_minimum <- pmin(abs(lme4_scaled), abs(gradient))
    empty$Lme4ScaledAvailable <- TRUE
    empty$Lme4ScaledMaximumAbsolute <- max(abs(lme4_scaled))
    empty$Lme4ScaledL2Norm <- sqrt(sum(lme4_scaled^2))
    empty$Lme4MinimumGradientMaximumAbsolute <- max(lme4_minimum)
    empty$Lme4ScaledGradient <- lme4_scaled
    empty$Lme4MinimumGradient <- lme4_minimum
  }
  if (length(newton_whitened) == dimension &&
      all(is.finite(newton_whitened))) {
    empty$NewtonWhitenedAvailable <- TRUE
    empty$NewtonWhitenedMaximumAbsolute <- max(abs(newton_whitened))
    empty$NewtonDecrement <- sqrt(sum(newton_whitened^2))
    empty$NewtonWhitenedGradient <- newton_whitened
  }
  if (length(newton_step) == dimension && all(is.finite(newton_step))) {
    empty$NewtonStepAvailable <- TRUE
    empty$NewtonRelativeStepMaximumAbsolute <- max(
      abs(newton_step) / pmax(1, abs(parameter))
    )
    empty$NewtonStep <- newton_step
  }
  empty
}

mfrmr_gtwsy_raw_instrumentation <- function(fit, base, runner_contract) {
  parameter <- mfrmr_gtwsy_safe_numeric(fit$fit$par)
  names(parameter) <- names(fit$fit$par)
  objective <- mfrmr_gtwsy_safe_numeric(fit$fit$objective[[1L]])
  outer_attempt <- tryCatch(
    fit$obj$gr(fit$fit$par), error = function(error) numeric()
  )
  outer_gradient <- mfrmr_gtwsy_safe_numeric(outer_attempt)
  names(outer_gradient) <- names(fit$fit$par)[seq_along(outer_gradient)]
  sd_gradient <- mfrmr_gtwsy_safe_numeric(fit$sdr$gradient.fixed)
  names(sd_gradient) <- names(fit$fit$par)[seq_along(sd_gradient)]
  arguments <- runner_contract$Richardson$MethodArguments
  hessian_attempt <- tryCatch(
    suppressWarnings(numDeriv::jacobian(
      fit$obj$gr, fit$fit$par,
      method = runner_contract$Richardson$Method,
      method.args = arguments
    )),
    error = function(error) error
  )
  hessian_available <- is.matrix(hessian_attempt) &&
    nrow(hessian_attempt) == length(parameter) &&
    ncol(hessian_attempt) == length(parameter) &&
    length(parameter) > 0L && all(is.finite(hessian_attempt))
  hessian <- if (hessian_available) hessian_attempt else
    matrix(numeric(), nrow = 0L, ncol = 0L)
  symmetric <- if (hessian_available) (hessian + t(hessian)) / 2 else
    matrix(numeric(), nrow = 0L, ncol = 0L)
  eigenvalues <- if (hessian_available) tryCatch(
    eigen(symmetric, symmetric = TRUE, only.values = TRUE)$values,
    error = function(error) numeric()
  ) else numeric()
  scales <- mfrmr_gtwsy_scale_metrics(
    parameter, objective, outer_gradient, hessian
  )
  outer_sd_available <- length(outer_gradient) == length(parameter) &&
    length(sd_gradient) == length(parameter) && length(parameter) > 0L &&
    all(is.finite(outer_gradient)) && all(is.finite(sd_gradient))
  outer_sd_difference <- if (outer_sd_available)
    outer_gradient - sd_gradient else numeric()
  sidecar <- list(
    Contract = paste0(
      "glmmtmb_fixed_coordinate_derivative_sidecar_",
      "draft83d2b2b1g4_v1"
    ),
    ParameterNames = names(parameter), Parameter = parameter,
    Objective = objective, OuterGradient = outer_gradient,
    SdreportGradient = sd_gradient,
    RichardsonJacobian = hessian,
    RichardsonSymmetricHessian = symmetric,
    RichardsonEigenvalues = eigenvalues,
    ObjectiveRelativeParameterScaledGradient =
      scales$ObjectiveRelativeParameterScaledGradient,
    Lme4ScaledGradient = scales$Lme4ScaledGradient,
    Lme4MinimumGradient = scales$Lme4MinimumGradient,
    NewtonWhitenedGradient = scales$NewtonWhitenedGradient,
    NewtonStep = scales$NewtonStep
  )
  sidecar_hash <- mfrmr_gta_hash(sidecar)
  list(
    RawDerivativeSidecarAvailable = TRUE,
    RawDerivativeSidecarHash = sidecar_hash,
    RawDerivativeSidecar = I(list(sidecar)),
    EvaluationPointHash = mfrmr_gta_hash(list(
      Parameter = parameter, Objective = objective
    )),
    InstrumentedParameterLength = length(parameter),
    InstrumentedParameterHash = mfrmr_gta_hash(unname(parameter)),
    InstrumentedObjective = objective,
    InstrumentedOuterGradientHash = if (scales$RawAvailable)
      mfrmr_gta_hash(unname(outer_gradient)) else "none",
    InstrumentedSdGradientHash = if (outer_sd_available)
      mfrmr_gta_hash(unname(sd_gradient)) else "none",
    OuterSdGradientDifferenceAvailable = outer_sd_available,
    OuterSdGradientMaximumAbsoluteDifference = if (outer_sd_available)
      max(abs(outer_sd_difference)) else NA_real_,
    OuterSdGradientL2Difference = if (outer_sd_available)
      sqrt(sum(outer_sd_difference^2)) else NA_real_,
    InstrumentedRichardsonHash = if (hessian_available)
      mfrmr_gta_hash(hessian) else "none",
    InstrumentedRichardsonSymmetricHash = if (hessian_available)
      mfrmr_gta_hash(symmetric) else "none",
    InstrumentedRichardsonEigenvalueHash = if (
      length(eigenvalues) == length(parameter) && all(is.finite(eigenvalues))
    ) mfrmr_gta_hash(eigenvalues) else "none",
    BaseOuterGradientHashExact = identical(
      base$OuterGradientHash,
      if (scales$RawAvailable) mfrmr_gta_hash(unname(outer_gradient)) else
        "none"
    ),
    BaseRichardsonHashExact = identical(
      base$RichardsonJacobianHash,
      if (hessian_available) mfrmr_gta_hash(hessian) else "none"
    ),
    RawGradientAvailable = scales$RawAvailable,
    RawGradientMaximumAbsolute = scales$RawMaximumAbsolute,
    RawGradientL2Norm = scales$RawL2Norm,
    ObjectiveRelativeParameterScaledAvailable =
      scales$ObjectiveRelativeParameterScaledAvailable,
    ObjectiveRelativeParameterScaledMaximumAbsolute =
      scales$ObjectiveRelativeParameterScaledMaximumAbsolute,
    InstrumentedHessianAvailable = scales$HessianAvailable,
    InstrumentedHessianDimension = scales$HessianDimension,
    InstrumentedHessianPositiveDefinite =
      scales$HessianPositiveDefinite,
    InstrumentedHessianCholeskyAvailable =
      scales$HessianCholeskyAvailable,
    InstrumentedHessianReciprocalCondition =
      scales$HessianReciprocalCondition,
    Lme4ScaledGradientAvailable = scales$Lme4ScaledAvailable,
    Lme4ScaledGradientMaximumAbsolute =
      scales$Lme4ScaledMaximumAbsolute,
    Lme4ScaledGradientL2Norm = scales$Lme4ScaledL2Norm,
    Lme4MinimumGradientMaximumAbsolute =
      scales$Lme4MinimumGradientMaximumAbsolute,
    NewtonWhitenedGradientAvailable = scales$NewtonWhitenedAvailable,
    NewtonWhitenedGradientMaximumAbsolute =
      scales$NewtonWhitenedMaximumAbsolute,
    NewtonDecrement = scales$NewtonDecrement,
    NewtonStepAvailable = scales$NewtonStepAvailable,
    NewtonRelativeStepMaximumAbsolute =
      scales$NewtonRelativeStepMaximumAbsolute,
    StationarityState = "not_calibrated",
    StationarityThresholdApplied = FALSE
  )
}

mfrmr_gtwsy_empty_instrumentation <- function() {
  list(
    RawDerivativeSidecarAvailable = FALSE,
    RawDerivativeSidecarHash = "none",
    RawDerivativeSidecar = I(list(list())), EvaluationPointHash = "none",
    InstrumentedParameterLength = 0L, InstrumentedParameterHash = "none",
    InstrumentedObjective = NA_real_,
    InstrumentedOuterGradientHash = "none",
    InstrumentedSdGradientHash = "none",
    OuterSdGradientDifferenceAvailable = FALSE,
    OuterSdGradientMaximumAbsoluteDifference = NA_real_,
    OuterSdGradientL2Difference = NA_real_,
    InstrumentedRichardsonHash = "none",
    InstrumentedRichardsonSymmetricHash = "none",
    InstrumentedRichardsonEigenvalueHash = "none",
    BaseOuterGradientHashExact = FALSE, BaseRichardsonHashExact = FALSE,
    RawGradientAvailable = FALSE, RawGradientMaximumAbsolute = NA_real_,
    RawGradientL2Norm = NA_real_,
    ObjectiveRelativeParameterScaledAvailable = FALSE,
    ObjectiveRelativeParameterScaledMaximumAbsolute = NA_real_,
    InstrumentedHessianAvailable = FALSE,
    InstrumentedHessianDimension = 0L,
    InstrumentedHessianPositiveDefinite = FALSE,
    InstrumentedHessianCholeskyAvailable = FALSE,
    InstrumentedHessianReciprocalCondition = NA_real_,
    Lme4ScaledGradientAvailable = FALSE,
    Lme4ScaledGradientMaximumAbsolute = NA_real_,
    Lme4ScaledGradientL2Norm = NA_real_,
    Lme4MinimumGradientMaximumAbsolute = NA_real_,
    NewtonWhitenedGradientAvailable = FALSE,
    NewtonWhitenedGradientMaximumAbsolute = NA_real_,
    NewtonDecrement = NA_real_, NewtonStepAvailable = FALSE,
    NewtonRelativeStepMaximumAbsolute = NA_real_,
    StationarityState = "not_evaluable",
    StationarityThresholdApplied = FALSE
  )
}

mfrmr_gtwsy_fit_diagnostics <- function(fit, final_signature,
                                          runner_contract) {
  base <- mfrmr_gtwsv_fit_diagnostics_alignment(
    fit, final_signature, runner_contract
  )
  c(base, mfrmr_gtwsy_raw_instrumentation(fit, base, runner_contract))
}

mfrmr_gtwsy_empty_diagnostics <- function() {
  c(mfrmr_gtwsv_empty_diagnostics_alignment(),
    mfrmr_gtwsy_empty_instrumentation())
}

mfrmr_gtwsy_runner_environment <- function() {
  mfrmr_gtwsy_require_primitives()
  isolated <- mfrmr_gtwsw_runner_environment()
  for (name in c(
    "mfrmr_gtwsy_safe_numeric", "mfrmr_gtwsy_scale_metrics",
    "mfrmr_gtwsy_raw_instrumentation", "mfrmr_gtwsy_empty_instrumentation"
  )) {
    value <- get(name, envir = environment(mfrmr_gtwsy_runner_environment),
                 inherits = TRUE)
    environment(value) <- isolated
    assign(name, value, envir = isolated)
  }
  for (name in c(
    "mfrmr_gtwsv_fit_diagnostics", "mfrmr_gtwsv_empty_diagnostics"
  )) {
    value <- get(name, envir = isolated, inherits = FALSE)
    assign(paste0(name, "_alignment"), value, envir = isolated)
  }
  replacements <- list(
    mfrmr_gtwsv_fit_diagnostics = mfrmr_gtwsy_fit_diagnostics,
    mfrmr_gtwsv_empty_diagnostics = mfrmr_gtwsy_empty_diagnostics
  )
  for (name in names(replacements)) {
    value <- replacements[[name]]
    environment(value) <- isolated
    assign(name, value, envir = isolated)
  }
  isolated
}

mfrmr_gtwsy_sidecar_valid <- function(sidecar, expected_hash) {
  required <- c(
    "Contract", "ParameterNames", "Parameter", "Objective",
    "OuterGradient", "SdreportGradient", "RichardsonJacobian",
    "RichardsonSymmetricHessian", "RichardsonEigenvalues",
    "ObjectiveRelativeParameterScaledGradient", "Lme4ScaledGradient",
    "Lme4MinimumGradient", "NewtonWhitenedGradient", "NewtonStep"
  )
  is.list(sidecar) && all(required %in% names(sidecar)) &&
    identical(mfrmr_gta_hash(sidecar), expected_hash) &&
    length(sidecar$Parameter) > 0L &&
    length(sidecar$OuterGradient) == length(sidecar$Parameter) &&
    length(sidecar$SdreportGradient) == length(sidecar$Parameter) &&
    is.matrix(sidecar$RichardsonJacobian) &&
    all(dim(sidecar$RichardsonJacobian) == length(sidecar$Parameter))
}

mfrmr_gtwsy_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwsy_validate_upstream", "mfrmr_gtwsy_safe_numeric",
    "mfrmr_gtwsy_scale_metrics", "mfrmr_gtwsy_raw_instrumentation",
    "mfrmr_gtwsy_empty_instrumentation", "mfrmr_gtwsy_fit_diagnostics",
    "mfrmr_gtwsy_empty_diagnostics", "mfrmr_gtwsy_runner_environment",
    "mfrmr_gtwsy_sidecar_valid", "mfrmr_gtwsy_contract",
    "mfrmr_gtwsy_execute", "mfrmr_gtwsy_execution_hash_valid",
    "mfrmr_gtwsy_fit_rows", "mfrmr_gtwsy_metric_summaries",
    "mfrmr_gtwsy_route_spreads", "mfrmr_gtwsy_adjudicate"
  )
  audit_environment <- environment(mfrmr_gtwsy_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwy_function_hash(get(
      name, envir = audit_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}

mfrmr_gtwsy_contract <- function(design_contract, design_manifest,
                                   upstream_execution,
                                   alignment_execution, adjudication) {
  mfrmr_gtwsy_require_primitives()
  if (!mfrmr_gtwsy_validate_upstream(alignment_execution, adjudication)) {
    stop("The exact b1g2 execution and b1g3 adjudication are required.",
         call. = FALSE)
  }
  alignment_contract <- mfrmr_gtwsw_contract(
    design_contract, design_manifest, upstream_execution
  )
  if (!identical(
    alignment_contract$RunnerContractHash,
    "7632a74709576c78d4e89b9fd015952dbde5be98313b99ed380af7c5436e1177"
  ) || !identical(
    as.character(alignment_contract$SmokeIdentity$StabilizationRouteId),
    as.character(alignment_execution$AtomicRows$StabilizationRouteId)
  )) stop("The b1g2 contract identity changed.", call. = FALSE)
  check_conv <- getFromNamespace("checkConv", "lme4")
  check_conv_hash <- mfrmr_gtwy_function_hash(check_conv)
  if (!identical(check_conv_hash,
                 "43b4605c2f8077b0f24c454594604f008e84cce2333062a7ee156d6fe0dc4c50") ||
      !identical(as.character(utils::packageVersion("lme4")), "2.0.6")) {
    stop("The installed lme4 gradient-scaling contract changed.",
         call. = FALSE)
  }
  numderiv_hash <- mfrmr_gtwy_function_hash(numDeriv::jacobian)
  sources <- data.frame(
    SourceId = c(
      "lme4_convergence_current", "lme4_checkconv_source_current",
      "tmb_introduction_current", "tmb_model_object_current",
      "numderiv_manual_current", "glmmtmb_troubleshooting_current"
    ),
    Locator = c(
      "https://lme4.github.io/lme4/reference/convergence.html",
      "https://github.com/lme4/lme4/blob/master/R/checkConv.R",
      "https://kaskr.github.io/adcomp/Introduction.html",
      "https://kaskr.github.io/adcomp/ModelObject.html",
      "https://cran.r-project.org/web/packages/numDeriv/numDeriv.pdf",
      "https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html"
    ),
    Role = c(
      "KKT_gradient_hessian_scaling_and_optimizer_agreement",
      "solve_chol_hessian_gradient_and_componentwise_minimum",
      "automatic_differentiation_objective_and_gradient_basis",
      "TMB_object_fn_gr_and_report_contract",
      "frozen_Richardson_gradient_Jacobian",
      "separate_gradient_curvature_restart_optimizer_checks"
    ),
    stringsAsFactors = FALSE
  )
  identity <- list(
    Contract = paste0(
      "gtheory_weak_information_glmmtmb_stationarity_",
      "instrumentation_draft83d2b2b1g4_v1"
    ),
    ContractArtifact = paste0(
      "gtheory-weak-information-glmmtmb-stationarity-",
      "instrumentation-contract-0.2.3.md"
    ),
    UpstreamAlignmentContractHash = alignment_contract$RunnerContractHash,
    UpstreamAlignmentExecutionHash = alignment_execution$ExecutionHash,
    UpstreamAdjudicationHash = adjudication$ResultHash,
    StabilizationContractHash = alignment_contract$StabilizationContractHash,
    StabilizationManifestHash = alignment_contract$StabilizationManifestHash,
    Profiles = alignment_contract$Profiles,
    SmokeIdentity = alignment_contract$SmokeIdentity,
    SmokePairCount = 120L, SmokeBackendFitCount = 240L,
    SmokeBaseRouteCount = alignment_contract$SmokeBaseRouteCount,
    SmokeDatasetCount = alignment_contract$SmokeDatasetCount,
    SmokeRowsPerBaseRoute = alignment_contract$SmokeRowsPerBaseRoute,
    SmokeRowsPerDataset = alignment_contract$SmokeRowsPerDataset,
    SmokeSelection = alignment_contract$SmokeSelection,
    TargetComponent = alignment_contract$TargetComponent,
    BoundaryTolerance = alignment_contract$BoundaryTolerance,
    NegativeLikelihoodTolerance =
      alignment_contract$NegativeLikelihoodTolerance,
    Richardson = alignment_contract$Richardson,
    ParentFailurePolicy = alignment_contract$ParentFailurePolicy,
    AtomicUnit = alignment_contract$AtomicUnit,
    AlignmentRule = alignment_contract$AlignmentRule,
    AlignmentAppliesToEveryReturnedFit = TRUE,
    AlignmentTolerance = "none", RandomModeMutationPermitted = FALSE,
    RawVectorRetentionRequired = TRUE,
    RawHessianRetentionRequired = TRUE,
    EvaluationPoint = "fit$fit$par_after_return",
    Lme4ScaledGradientDefinition = "solve(chol(H), g)",
    Lme4MinimumGradientDefinition = "pmin(abs(solve(chol(H),g)),abs(g))",
    NewtonWhitenedDefinition = "solve(t(chol(H)), g)",
    NewtonDecrementDefinition = "sqrt(g_transpose_H_inverse_g)",
    ObjectiveRelativeParameterScaledDefinition =
      "g_i*max(1,abs(par_i))/max(1,abs(objective))",
    CoordinateSystemsMayNotBePooled = TRUE,
    OutcomeDependentSelection = FALSE, ComparisonDenominator = 120L,
    ScientificHashExclusions = alignment_contract$ScientificHashExclusions,
    EarlyStoppingPermitted = FALSE, AdaptiveFallbackPermitted = FALSE,
    CalibrationDataGenerationPermitted = FALSE,
    ThresholdSelectionPermitted = FALSE,
    OptimizerSelectionPermitted = FALSE, BootstrapPermitted = FALSE,
    ObservedValuesMayDefineThreshold = FALSE,
    Lme4CheckConvFunctionHash = check_conv_hash,
    NumDerivJacobianFunctionHash = numderiv_hash,
    PackageVersions = c(
      lme4 = as.character(utils::packageVersion("lme4")),
      glmmTMB = as.character(utils::packageVersion("glmmTMB")),
      TMB = as.character(utils::packageVersion("TMB")),
      numDeriv = as.character(utils::packageVersion("numDeriv")),
      R = as.character(getRversion())
    ),
    Sources = sources, FunctionHashes = mfrmr_gtwsy_function_hashes()
  )
  structure(c(identity, list(
    RunnerContractHash = mfrmr_gta_hash(identity), RunnerImplemented = TRUE,
    SmokeExecutionAuthorized = TRUE,
    StationarityInstrumentationSmokeAuthorized = TRUE,
    FullExecutionAuthorized = FALSE, StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    NumericalEligibilitySufficientRuleFrozen = FALSE,
    NumericalStabilizationReady = FALSE,
    NumericalSensitivityEvidenceReady = FALSE,
    CalibrationEvidenceReady = FALSE, ThresholdFrozen = FALSE,
    ConfirmationAuthorized = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )), class = c(
    "mfrmr_gtwsy_contract", "mfrmr_gtwsw_contract", "mfrmr_gtwsv_contract"
  ))
}

mfrmr_gtwsy_execute <- function(runner_contract, design_manifest,
                                  alignment_execution, checkpoint_root,
                                  progress_every = 1L) {
  if (!inherits(runner_contract, "mfrmr_gtwsy_contract") ||
      !isTRUE(runner_contract$StationarityInstrumentationSmokeAuthorized) ||
      isTRUE(runner_contract$FullExecutionAuthorized) ||
      isTRUE(runner_contract$ObservedValuesMayDefineThreshold) ||
      isTRUE(runner_contract$ThresholdSelectionPermitted) ||
      isTRUE(runner_contract$OptimizerSelectionPermitted) ||
      !mfrmr_gtwsx_alignment_execution_hash_valid(alignment_execution) ||
      !identical(runner_contract$UpstreamAlignmentExecutionHash,
                 alignment_execution$ExecutionHash)) {
    stop("The exact b1g4 instrumentation smoke is not authorized.",
         call. = FALSE)
  }
  isolated <- mfrmr_gtwsy_runner_environment()
  underlying <- isolated$mfrmr_gtwsv_execute(
    runner_contract, design_manifest, checkpoint_root, progress_every
  )
  rows <- underlying$AtomicRows
  if (!identical(
    as.character(rows$StabilizationRouteId),
    as.character(runner_contract$SmokeIdentity$StabilizationRouteId)
  )) stop("The b1g4 ordered denominator changed.", call. = FALSE)
  full_returned <- rows$FullReturned %in% TRUE
  reduced_returned <- rows$ReducedReturned %in% TRUE
  full_sidecar_valid <- vapply(seq_len(nrow(rows)), function(index) {
    !full_returned[[index]] || mfrmr_gtwsy_sidecar_valid(
      rows$FullRawDerivativeSidecar[[index]],
      rows$FullRawDerivativeSidecarHash[[index]]
    )
  }, logical(1L))
  reduced_sidecar_valid <- vapply(seq_len(nrow(rows)), function(index) {
    !reduced_returned[[index]] || mfrmr_gtwsy_sidecar_valid(
      rows$ReducedRawDerivativeSidecar[[index]],
      rows$ReducedRawDerivativeSidecarHash[[index]]
    )
  }, logical(1L))
  before <- alignment_execution$AtomicRows
  before <- before[match(rows$StabilizationRouteId,
                         before$StabilizationRouteId), , drop = FALSE]
  typed_equal <- function(left, right) mapply(function(x, y) {
    identical(x, y) ||
      (length(x) == 1L && length(y) == 1L && is.na(x) && is.na(y) &&
       identical(typeof(x), typeof(y)))
  }, left, right, USE.NAMES = FALSE)
  replay_fields <- c(
    "FullTopLevelParameterHash", "ReducedTopLevelParameterHash",
    "FullObjective", "ReducedObjective", "FullLogLikelihood",
    "ReducedLogLikelihood", "RawLikelihoodDrop"
  )
  replay_mismatches <- stats::setNames(vapply(replay_fields, function(field) {
    sum(!typed_equal(before[[field]], rows[[field]]))
  }, integer(1L)), replay_fields)
  instrumentation_summary <- list(
    FullReturnedCount = sum(full_returned),
    ReducedReturnedCount = sum(reduced_returned),
    FullValidSidecarCount = sum(full_returned & full_sidecar_valid),
    ReducedValidSidecarCount = sum(reduced_returned & reduced_sidecar_valid),
    FullBaseOuterGradientRepeatExactCount = sum(
      full_returned & rows$FullBaseOuterGradientHashExact %in% TRUE
    ),
    ReducedBaseOuterGradientRepeatExactCount = sum(
      reduced_returned & rows$ReducedBaseOuterGradientHashExact %in% TRUE
    ),
    FullBaseRichardsonRepeatExactCount = sum(
      full_returned & rows$FullBaseRichardsonHashExact %in% TRUE
    ),
    ReducedBaseRichardsonRepeatExactCount = sum(
      reduced_returned & rows$ReducedBaseRichardsonHashExact %in% TRUE
    ),
    FullPositiveDefiniteInstrumentedHessianCount = sum(
      full_returned & rows$FullInstrumentedHessianPositiveDefinite %in% TRUE
    ),
    ReducedPositiveDefiniteInstrumentedHessianCount = sum(
      reduced_returned &
        rows$ReducedInstrumentedHessianPositiveDefinite %in% TRUE
    ),
    FullCholeskyAvailableInstrumentedHessianCount = sum(
      full_returned &
        rows$FullInstrumentedHessianCholeskyAvailable %in% TRUE
    ),
    ReducedCholeskyAvailableInstrumentedHessianCount = sum(
      reduced_returned &
        rows$ReducedInstrumentedHessianCholeskyAvailable %in% TRUE
    ),
    ReplayMismatchCounts = replay_mismatches,
    StationarityThresholdApplied = FALSE,
    OptimizerSelected = FALSE, CalibrationDataGenerated = FALSE
  )
  exact <- isTRUE(underlying$ExactAccountingPassed) &&
    nrow(rows) == runner_contract$SmokePairCount &&
    sum(full_returned) == 120L && sum(reduced_returned) == 120L &&
    all(full_sidecar_valid) && all(reduced_sidecar_valid) &&
    all(rows$FullStationarityState == "not_calibrated") &&
    all(rows$ReducedStationarityState == "not_calibrated") &&
    all(!(rows$FullStationarityThresholdApplied %in% TRUE)) &&
    all(!(rows$ReducedStationarityThresholdApplied %in% TRUE))
  if (!exact) stop("The b1g4 instrumentation accounting failed.",
                   call. = FALSE)
  identity <- list(
    Contract = paste0(
      "gtheory_weak_information_glmmtmb_stationarity_",
      "instrumentation_smoke_draft83d2b2b1g4_v1"
    ),
    RunnerContractHash = runner_contract$RunnerContractHash,
    UpstreamAlignmentExecutionHash = alignment_execution$ExecutionHash,
    UnderlyingExecutionHash = underlying$ExecutionHash,
    StabilizationContractHash = runner_contract$StabilizationContractHash,
    StabilizationManifestHash = runner_contract$StabilizationManifestHash,
    AtomicRows = rows,
    BaseRouteCheckpointHashes = underlying$BaseRouteCheckpointHashes,
    DatasetMarkerHashes = underlying$DatasetMarkerHashes,
    Summaries = underlying$Summaries,
    InstrumentationSummary = instrumentation_summary
  )
  structure(c(identity, list(
    ExecutionHash = mfrmr_gta_hash(identity),
    RouteTiming = underlying$RouteTiming,
    CheckpointReuse = underlying$CheckpointReuse,
    CheckpointReuseCount = underlying$CheckpointReuseCount,
    ComputedBaseRouteCount = underlying$ComputedBaseRouteCount,
    ExactAccountingPassed = exact, PlannedPairs = 120L,
    PlannedBackendFits = 240L, PairReturnCount = 120L,
    RawDerivativeSidecarsReady = TRUE,
    ScaleAwareObservablesReady = TRUE,
    FitReplayExact = all(replay_mismatches == 0L),
    StationarityInstrumentationSmokeReady = TRUE,
    FullExecutionAuthorized = FALSE, StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    NumericalEligibilitySufficientRuleFrozen = FALSE,
    NumericalStabilizationReady = FALSE,
    NumericalSensitivityEvidenceReady = FALSE,
    CalibrationEvidenceReady = FALSE,
    BootstrapOperatingCharacteristicsReady = FALSE,
    ThresholdFrozen = FALSE, ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = c("mfrmr_gtwsy_execution", "mfrmr_gtwsv_execution"))
}

mfrmr_gtwsy_execution_hash_valid <- function(execution) {
  fields <- c(
    "Contract", "RunnerContractHash", "UpstreamAlignmentExecutionHash",
    "UnderlyingExecutionHash", "StabilizationContractHash",
    "StabilizationManifestHash", "AtomicRows", "BaseRouteCheckpointHashes",
    "DatasetMarkerHashes", "Summaries", "InstrumentationSummary"
  )
  all(fields %in% names(execution)) && identical(
    execution$ExecutionHash, mfrmr_gta_hash(execution[fields])
  )
}

mfrmr_gtwsy_fit_rows <- function(execution) {
  if (!inherits(execution, "mfrmr_gtwsy_execution") ||
      !mfrmr_gtwsy_execution_hash_valid(execution)) {
    stop("An intact b1g4 execution is required.", call. = FALSE)
  }
  source <- execution$AtomicRows
  rows <- lapply(c("Full", "Reduced"), function(role) {
    data.frame(
      StabilizationRouteId = source$StabilizationRouteId,
      RouteId = source$RouteId, DatasetId = source$DatasetId,
      DesignId = source$DesignId, VarianceId = source$VarianceId,
      MethodId = source$MethodId, Likelihood = source$Likelihood,
      ProfileId = source$ProfileId, ModelRole = tolower(role),
      Objective = source[[paste0(role, "Objective")]],
      ParameterLength =
        source[[paste0(role, "InstrumentedParameterLength")]],
      RawGradientMaximumAbsolute =
        source[[paste0(role, "RawGradientMaximumAbsolute")]],
      RawGradientL2Norm =
        source[[paste0(role, "RawGradientL2Norm")]],
      ObjectiveRelativeParameterScaledMaximumAbsolute = source[[paste0(
        role, "ObjectiveRelativeParameterScaledMaximumAbsolute"
      )]],
      HessianPositiveDefinite = source[[paste0(
        role, "InstrumentedHessianPositiveDefinite"
      )]],
      HessianCholeskyAvailable = source[[paste0(
        role, "InstrumentedHessianCholeskyAvailable"
      )]],
      HessianReciprocalCondition = source[[paste0(
        role, "InstrumentedHessianReciprocalCondition"
      )]],
      Lme4ScaledGradientMaximumAbsolute = source[[paste0(
        role, "Lme4ScaledGradientMaximumAbsolute"
      )]],
      Lme4MinimumGradientMaximumAbsolute = source[[paste0(
        role, "Lme4MinimumGradientMaximumAbsolute"
      )]],
      NewtonWhitenedGradientMaximumAbsolute = source[[paste0(
        role, "NewtonWhitenedGradientMaximumAbsolute"
      )]],
      NewtonDecrement = source[[paste0(role, "NewtonDecrement")]],
      NewtonRelativeStepMaximumAbsolute = source[[paste0(
        role, "NewtonRelativeStepMaximumAbsolute"
      )]],
      OuterSdGradientMaximumAbsoluteDifference = source[[paste0(
        role, "OuterSdGradientMaximumAbsoluteDifference"
      )]],
      StationarityState = source[[paste0(role, "StationarityState")]],
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_gtwsy_metric_summaries <- function(rows) {
  metrics <- c(
    "RawGradientMaximumAbsolute",
    "ObjectiveRelativeParameterScaledMaximumAbsolute",
    "Lme4ScaledGradientMaximumAbsolute",
    "Lme4MinimumGradientMaximumAbsolute", "NewtonDecrement",
    "NewtonRelativeStepMaximumAbsolute",
    "OuterSdGradientMaximumAbsoluteDifference"
  )
  strata <- split(rows, interaction(
    rows$ModelRole, rows$VarianceId, rows$Likelihood, drop = TRUE,
    lex.order = TRUE
  ))
  result <- list()
  cursor <- 0L
  for (stratum in strata) for (metric in metrics) {
    cursor <- cursor + 1L
    value <- stratum[[metric]]
    value <- value[is.finite(value)]
    quantiles <- if (length(value) > 0L) stats::quantile(
      value, probs = c(0, 0.5, 0.9, 1), names = FALSE, type = 8
    ) else rep(NA_real_, 4L)
    result[[cursor]] <- data.frame(
      ModelRole = stratum$ModelRole[[1L]],
      VarianceId = stratum$VarianceId[[1L]],
      Likelihood = stratum$Likelihood[[1L]], Metric = metric,
      AvailableN = length(value), Minimum = quantiles[[1L]],
      Median = quantiles[[2L]], Quantile90 = quantiles[[3L]],
      Maximum = quantiles[[4L]], ThresholdApplied = FALSE,
      stringsAsFactors = FALSE
    )
  }
  do.call(rbind, result)
}

mfrmr_gtwsy_route_spreads <- function(rows) {
  groups <- split(rows, interaction(
    rows$RouteId, rows$ModelRole, drop = TRUE, lex.order = TRUE
  ))
  metric <- c(
    "RawGradientMaximumAbsolute",
    "ObjectiveRelativeParameterScaledMaximumAbsolute",
    "Lme4ScaledGradientMaximumAbsolute", "NewtonDecrement",
    "NewtonRelativeStepMaximumAbsolute"
  )
  do.call(rbind, lapply(groups, function(group) {
    if (nrow(group) != 6L || anyDuplicated(group$ProfileId)) {
      stop("Each route/model spread requires six frozen profiles.",
           call. = FALSE)
    }
    best_objective <- group$ProfileId[[which.min(group$Objective)]]
    values <- lapply(metric, function(name) {
      value <- group[[name]]
      finite <- which(is.finite(value))
      if (length(finite) == 0L) return(list(
        available = 0L, minimum = NA_real_, maximum = NA_real_,
        min_profile = "none", best_match = FALSE, correlation = NA_real_
      ))
      best <- finite[[which.min(value[finite])]]
      correlation <- if (length(finite) >= 3L &&
        length(unique(value[finite])) > 1L &&
        length(unique(group$Objective[finite])) > 1L) suppressWarnings(
          stats::cor(group$Objective[finite], value[finite],
                     method = "spearman")
        ) else NA_real_
      list(
        available = length(finite), minimum = min(value[finite]),
        maximum = max(value[finite]),
        min_profile = group$ProfileId[[best]],
        best_match = identical(group$ProfileId[[best]], best_objective),
        correlation = correlation
      )
    })
    names(values) <- metric
    data.frame(
      RouteId = group$RouteId[[1L]], ModelRole = group$ModelRole[[1L]],
      BestObjectiveProfileId = best_objective,
      RawAvailableProfiles = values[[1L]]$available,
      RawRange = values[[1L]]$maximum - values[[1L]]$minimum,
      RawMinimumProfileId = values[[1L]]$min_profile,
      RawBestObjectiveMatch = values[[1L]]$best_match,
      RawObjectiveSpearman = values[[1L]]$correlation,
      ObjectiveRelativeAvailableProfiles = values[[2L]]$available,
      ObjectiveRelativeRange = values[[2L]]$maximum - values[[2L]]$minimum,
      ObjectiveRelativeMinimumProfileId = values[[2L]]$min_profile,
      ObjectiveRelativeBestObjectiveMatch = values[[2L]]$best_match,
      ObjectiveRelativeObjectiveSpearman = values[[2L]]$correlation,
      Lme4ScaledAvailableProfiles = values[[3L]]$available,
      Lme4ScaledRange = values[[3L]]$maximum - values[[3L]]$minimum,
      Lme4ScaledMinimumProfileId = values[[3L]]$min_profile,
      Lme4ScaledBestObjectiveMatch = values[[3L]]$best_match,
      Lme4ScaledObjectiveSpearman = values[[3L]]$correlation,
      NewtonDecrementAvailableProfiles = values[[4L]]$available,
      NewtonDecrementRange = values[[4L]]$maximum - values[[4L]]$minimum,
      NewtonDecrementMinimumProfileId = values[[4L]]$min_profile,
      NewtonDecrementBestObjectiveMatch = values[[4L]]$best_match,
      NewtonDecrementObjectiveSpearman = values[[4L]]$correlation,
      NewtonStepAvailableProfiles = values[[5L]]$available,
      NewtonStepRange = values[[5L]]$maximum - values[[5L]]$minimum,
      NewtonStepMinimumProfileId = values[[5L]]$min_profile,
      NewtonStepBestObjectiveMatch = values[[5L]]$best_match,
      NewtonStepObjectiveSpearman = values[[5L]]$correlation,
      OptimizerSelected = FALSE, ThresholdApplied = FALSE,
      stringsAsFactors = FALSE
    )
  }))
}

mfrmr_gtwsy_adjudicate <- function(runner_contract, execution) {
  if (!inherits(runner_contract, "mfrmr_gtwsy_contract") ||
      !inherits(execution, "mfrmr_gtwsy_execution") ||
      !identical(execution$RunnerContractHash,
                 runner_contract$RunnerContractHash) ||
      !mfrmr_gtwsy_execution_hash_valid(execution) ||
      isTRUE(runner_contract$ObservedValuesMayDefineThreshold)) {
    stop("The exact threshold-free b1g4 execution is required.",
         call. = FALSE)
  }
  rows <- mfrmr_gtwsy_fit_rows(execution)
  metric_summaries <- mfrmr_gtwsy_metric_summaries(rows)
  spreads <- mfrmr_gtwsy_route_spreads(rows)
  exact <- nrow(rows) == 240L && nrow(spreads) == 40L &&
    all(rows$StationarityState == "not_calibrated") &&
    all(!(metric_summaries$ThresholdApplied %in% TRUE)) &&
    all(!(spreads$ThresholdApplied %in% TRUE)) &&
    all(!(spreads$OptimizerSelected %in% TRUE))
  if (!exact) stop("The b1g4 threshold-free adjudication failed.",
                   call. = FALSE)
  summary <- list(
    FitCount = nrow(rows), RouteModelCount = nrow(spreads),
    RawGradientAvailableCount = sum(is.finite(
      rows$RawGradientMaximumAbsolute
    )),
    ObjectiveRelativeAvailableCount = sum(is.finite(
      rows$ObjectiveRelativeParameterScaledMaximumAbsolute
    )),
    PositiveDefiniteHessianCount = sum(rows$HessianPositiveDefinite),
    CholeskyAvailableHessianCount = sum(rows$HessianCholeskyAvailable),
    Lme4ScaledAvailableCount = sum(is.finite(
      rows$Lme4ScaledGradientMaximumAbsolute
    )),
    NewtonDecrementAvailableCount = sum(is.finite(rows$NewtonDecrement)),
    RawBestObjectiveProfileMatchCount = sum(spreads$RawBestObjectiveMatch),
    ObjectiveRelativeBestObjectiveProfileMatchCount =
      sum(spreads$ObjectiveRelativeBestObjectiveMatch),
    Lme4ScaledBestObjectiveProfileMatchCount =
      sum(spreads$Lme4ScaledBestObjectiveMatch),
    NewtonDecrementBestObjectiveProfileMatchCount =
      sum(spreads$NewtonDecrementBestObjectiveMatch),
    NewtonStepBestObjectiveProfileMatchCount =
      sum(spreads$NewtonStepBestObjectiveMatch),
    ThresholdSelected = FALSE, OptimizerSelected = FALSE,
    CalibrationDataGenerated = FALSE
  )
  identity <- list(
    Contract = paste0(
      "gtheory_weak_information_glmmtmb_stationarity_",
      "instrumentation_adjudication_draft83d2b2b1g4_v1"
    ),
    RunnerContractHash = runner_contract$RunnerContractHash,
    ExecutionHash = execution$ExecutionHash, FitRows = rows,
    MetricSummaries = metric_summaries, RouteSpreadRows = spreads,
    Summary = summary
  )
  structure(c(identity, list(
    ResultHash = mfrmr_gta_hash(identity), ExactAccountingPassed = exact,
    ScaleAwareMeasurementSchemaReady = TRUE,
    RawDerivativeRetentionReady = TRUE,
    CrossProfileMeasurementReady = TRUE,
    StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    NumericalEligibilitySufficientRuleFrozen = FALSE,
    FullExecutionAuthorized = FALSE,
    NumericalStabilizationReady = FALSE,
    NumericalSensitivityEvidenceReady = FALSE,
    CalibrationEvidenceReady = FALSE, ThresholdFrozen = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwsy_adjudication")
}
