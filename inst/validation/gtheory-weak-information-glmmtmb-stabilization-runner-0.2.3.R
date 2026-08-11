# Draft.83d2b2b1g1 glmmTMB stabilization runner and covering smoke.
#
# Repository-internal only. Full-manifest execution, calibration, thresholds,
# bootstrap, inference, and D-study decisions remain unauthorized.

mfrmr_gtwsv_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtwy_function_hash", "mfrmr_gtw_registry",
    "mfrmr_gtw_generate", "mfrmr_gtd3_prefit_one",
    "mfrmr_gtwd_reduced_formula", "mfrmr_gtwd_capture",
    "mfrmr_gtwd_glmmtmb_zero", "mfrmr_gtm_hessian_minimum",
    "mfrmr_gtwst_start_signature", "mfrmr_gtwx_checkpoint_root",
    "mfrmr_gtwx_atomic_write", "mfrmr_gtwx_safe_read"
  )
  audit_environment <- environment(mfrmr_gtwsv_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = audit_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the corrected Draft.83d2b2b1g chain before b1g1: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwsv_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwsv_validate_design", "mfrmr_gtwsv_smoke_rows",
    "mfrmr_gtwsv_control", "mfrmr_gtwsv_extract_start",
    "mfrmr_gtwsv_gradient_summary", "mfrmr_gtwsv_richardson",
    "mfrmr_gtwsv_fit_diagnostics", "mfrmr_gtwsv_fit_one",
    "mfrmr_gtwsv_pair_state", "mfrmr_gtwsv_fit_pair",
    "mfrmr_gtwsv_atomic_row", "mfrmr_gtwsv_failure_rows",
    "mfrmr_gtwsv_base_route", "mfrmr_gtwsv_contract",
    "mfrmr_gtwsv_checkpoint", "mfrmr_gtwsv_validate_checkpoint",
    "mfrmr_gtwsv_marker", "mfrmr_gtwsv_validate_marker",
    "mfrmr_gtwsv_summaries", "mfrmr_gtwsv_execute"
  )
  audit_environment <- environment(mfrmr_gtwsv_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwy_function_hash(get(
      name, envir = audit_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}

mfrmr_gtwsv_validate_design <- function(contract, manifest) {
  inherits(contract, "mfrmr_gtwst_contract") &&
    inherits(manifest, "mfrmr_gtwst_manifest") &&
    identical(
      contract$ContractHash,
      "8feb8695c655c0621d61863e00d82fffe7fd5d7b619761decefaed6e89b0c326"
    ) &&
    identical(
      manifest$ManifestHash,
      "92435f41b0dab7e13bf1febcf6e043fc1ae8d4a2cb7d159401dd1d78b4c9ff3e"
    ) &&
    identical(manifest$StabilizationContractHash, contract$ContractHash) &&
    isTRUE(manifest$ExactAccounting) && isTRUE(manifest$ManifestReady) &&
    identical(manifest$PlannedPairs, 9000L) &&
    identical(manifest$PlannedBackendFits, 18000L) &&
    is.data.frame(manifest$Rows) && nrow(manifest$Rows) == 9000L &&
    !anyDuplicated(manifest$Rows$StabilizationRouteId) &&
    !isTRUE(contract$StabilizationRunnerImplemented) &&
    !isTRUE(contract$StabilizationExecutionAuthorized) &&
    !isTRUE(manifest$StabilizationRunnerImplemented) &&
    !isTRUE(manifest$StabilizationExecutionAuthorized) &&
    !isTRUE(contract$CalibrationDataGenerationPermitted) &&
    !isTRUE(contract$ThresholdSelectionPermitted) &&
    !isTRUE(contract$NumericalStabilizationReady) &&
    !isTRUE(manifest$NumericalStabilizationReady) &&
    !isTRUE(manifest$NumericalSensitivityEvidenceReady) &&
    !isTRUE(manifest$ThresholdFrozen) &&
    !isTRUE(manifest$InferenceReady) && !isTRUE(manifest$DecisionReady)
}

mfrmr_gtwsv_smoke_rows <- function(design_contract, design_manifest) {
  if (!mfrmr_gtwsv_validate_design(design_contract, design_manifest)) {
    stop("The exact corrected b1g design and manifest are required.",
         call. = FALSE)
  }
  rows <- design_manifest$Rows
  rows <- rows[
    rows$Replicate == 101L &
      rows$VarianceId %in% c("exact_zero", "reference_1200"),
    , drop = FALSE
  ]
  profile_order <- match(rows$ProfileId, design_contract$Profiles$ProfileId)
  rows <- rows[order(
    rows$DatasetId, rows$MethodId, rows$ExecutionOrder, profile_order,
    method = "radix"
  ), , drop = FALSE]
  row.names(rows) <- NULL
  base <- unique(rows[, c(
    "RouteId", "DatasetId", "DesignId", "VarianceId", "MethodId",
    "Likelihood"
  )])
  exact <- nrow(rows) == 120L && nrow(base) == 20L &&
    length(unique(rows$DatasetId)) == 10L &&
    setequal(unique(rows$DesignId), c(
      "baseline_complete", "few_levels_complete", "high_information",
      "imbalanced_hub", "sparse_connected"
    )) &&
    setequal(unique(rows$VarianceId), c("exact_zero", "reference_1200")) &&
    setequal(unique(rows$MethodId), c("glmmTMB_ml", "glmmTMB_reml")) &&
    all(table(rows$RouteId) == 6L) && all(table(rows$DatasetId) == 12L) &&
    all(table(rows$ProfileId) == 20L) &&
    !anyDuplicated(rows$StabilizationRouteId) &&
    all(rows$CalibrationUse %in% FALSE) &&
    all(rows$ThresholdSelectionPermitted %in% FALSE)
  if (!exact) stop("The stabilization covering-smoke accounting failed.",
                   call. = FALSE)
  rows
}

mfrmr_gtwsv_control <- function(profile_id, profiles) {
  profile <- profiles[profiles$ProfileId == profile_id, , drop = FALSE]
  if (nrow(profile) != 1L) stop("Unknown stabilization profile.",
                                call. = FALSE)
  if (identical(profile$Algorithm[[1L]], "nlminb")) {
    glmmTMB::glmmTMBControl()
  } else if (identical(profile$Algorithm[[1L]], "optim_BFGS")) {
    glmmTMB::glmmTMBControl(
      optimizer = stats::optim,
      optCtrl = list(maxit = 2000, reltol = 1e-10),
      optArgs = list(method = "BFGS")
    )
  } else {
    stop("Unknown stabilization algorithm.", call. = FALSE)
  }
}

mfrmr_gtwsv_extract_start <- function(fit) {
  if (!inherits(fit, "glmmTMB")) {
    stop("Start extraction requires one glmmTMB fit.", call. = FALSE)
  }
  joint_best <- as.numeric(fit$obj$env$last.par.best)
  fixed_index <- fit$obj$env$lfixed()
  top <- as.numeric(fit$fit$par)
  if (!is.logical(fixed_index) || length(fixed_index) != length(joint_best) ||
      sum(fixed_index) != length(top) || !all(is.finite(joint_best)) ||
      !all(is.finite(top))) {
    stop("The immediate joint-best snapshot is invalid.", call. = FALSE)
  }
  fixed_exact <- identical(unname(joint_best[fixed_index]), unname(top))
  if (!fixed_exact) {
    stop("Joint-best fixed coordinates differ from fit$fit$par.",
         call. = FALSE)
  }
  blocks <- fit$obj$env$parList(x = fit$fit$par, par = joint_best)
  block_signature <- mfrmr_gtwst_start_signature(blocks)
  identity <- list(
    Contract = "glmmtmb_immediate_joint_best_start_signature_v1",
    JointBestHash = mfrmr_gta_hash(joint_best),
    JointBestLength = length(joint_best),
    FixedIndexHash = mfrmr_gta_hash(fixed_index),
    FixedCoordinateHash = mfrmr_gta_hash(joint_best[fixed_index]),
    TopLevelParameterHash = mfrmr_gta_hash(top),
    FixedCoordinateExact = fixed_exact,
    BlockSignatureHash = block_signature$SignatureHash,
    BlockLengths = block_signature$Blocks$BlockLength,
    BlockHashes = block_signature$Blocks$BlockHash
  )
  structure(c(identity, list(
    SignatureHash = mfrmr_gta_hash(identity),
    StartList = block_signature$Values
  )), class = "mfrmr_gtwsv_start_signature")
}

mfrmr_gtwsv_gradient_summary <- function(value) {
  value <- suppressWarnings(as.numeric(value))
  available <- length(value) > 0L && all(is.finite(value))
  list(
    Available = available, Length = length(value),
    Hash = if (available) mfrmr_gta_hash(value) else "none",
    MaximumAbsolute = if (available) max(abs(value)) else NA_real_,
    L2Norm = if (available) sqrt(sum(value^2)) else NA_real_
  )
}

mfrmr_gtwsv_richardson <- function(fit, runner_contract) {
  arguments <- runner_contract$Richardson$MethodArguments
  attempted <- tryCatch(
    suppressWarnings(numDeriv::jacobian(
      fit$obj$gr, fit$fit$par,
      method = runner_contract$Richardson$Method,
      method.args = arguments
    )),
    error = function(error) error
  )
  if (inherits(attempted, "error") || !is.matrix(attempted) ||
      nrow(attempted) != ncol(attempted) || nrow(attempted) == 0L ||
      !all(is.finite(attempted))) {
    return(list(
      Available = FALSE, Dimension = 0L, JacobianHash = "none",
      SymmetryResidual = NA_real_, EigenvalueHash = "none",
      MinimumEigenvalue = NA_real_, MaximumEigenvalue = NA_real_,
      MinimumRelativeEigenvalue = NA_real_,
      MinimumAbsoluteRelativeEigenvalue = NA_real_,
      PositiveDefinite = FALSE,
      FailureDigest = if (inherits(attempted, "error"))
        mfrmr_gta_hash(conditionMessage(attempted)) else
        mfrmr_gta_hash("invalid_richardson_matrix")
    ))
  }
  symmetry <- max(abs(attempted - t(attempted)))
  symmetric <- (attempted + t(attempted)) / 2
  eigenvalues <- eigen(
    symmetric, symmetric = TRUE, only.values = TRUE
  )$values
  denominator <- max(abs(eigenvalues))
  list(
    Available = TRUE, Dimension = nrow(attempted),
    JacobianHash = mfrmr_gta_hash(attempted),
    SymmetryResidual = symmetry,
    EigenvalueHash = mfrmr_gta_hash(eigenvalues),
    MinimumEigenvalue = min(eigenvalues),
    MaximumEigenvalue = max(eigenvalues),
    MinimumRelativeEigenvalue = if (denominator > 0)
      min(eigenvalues) / denominator else NA_real_,
    MinimumAbsoluteRelativeEigenvalue = if (denominator > 0)
      min(abs(eigenvalues)) / denominator else NA_real_,
    PositiveDefinite = all(eigenvalues > 0), FailureDigest = "none"
  )
}

mfrmr_gtwsv_fit_diagnostics <- function(fit, final_signature,
                                          runner_contract) {
  outer_attempt <- tryCatch(fit$obj$gr(fit$fit$par),
                            error = function(error) numeric())
  outer <- mfrmr_gtwsv_gradient_summary(outer_attempt)
  sd_gradient <- mfrmr_gtwsv_gradient_summary(fit$sdr$gradient.fixed)
  richardson <- mfrmr_gtwsv_richardson(fit, runner_contract)
  optimizer_code <- suppressWarnings(as.integer(fit$fit$convergence[[1L]]))
  if (length(optimizer_code) == 0L || is.na(optimizer_code)) {
    optimizer_code <- NA_integer_
  }
  objective <- suppressWarnings(as.numeric(fit$fit$objective[[1L]]))
  log_likelihood <- suppressWarnings(as.numeric(stats::logLik(fit)))
  log_likelihood_df <- suppressWarnings(as.integer(attr(
    stats::logLik(fit), "df"
  )))
  pd_hessian <- fit$sdr$pdHess
  if (length(pd_hessian) != 1L || is.na(pd_hessian)) pd_hessian <- FALSE
  list(
    OptimizerCode = optimizer_code,
    OptimizerMessageDigest = mfrmr_gta_hash(as.character(fit$fit$message)),
    Objective = objective, LogLikelihood = log_likelihood,
    LogLikelihoodDf = log_likelihood_df,
    Nobs = as.integer(stats::nobs(fit)),
    TopLevelParameterHash = final_signature$TopLevelParameterHash,
    JointBestHash = final_signature$JointBestHash,
    JointBestLength = final_signature$JointBestLength,
    FixedCoordinateExact = final_signature$FixedCoordinateExact,
    FinalStartSignatureHash = final_signature$SignatureHash,
    OuterGradientAvailable = outer$Available,
    OuterGradientLength = outer$Length, OuterGradientHash = outer$Hash,
    OuterGradientMaximumAbsolute = outer$MaximumAbsolute,
    OuterGradientL2Norm = outer$L2Norm,
    SdGradientAvailable = sd_gradient$Available,
    SdGradientLength = sd_gradient$Length,
    SdGradientHash = sd_gradient$Hash,
    SdGradientMaximumAbsolute = sd_gradient$MaximumAbsolute,
    SdGradientL2Norm = sd_gradient$L2Norm,
    SdreportPositiveDefiniteHessian = isTRUE(pd_hessian),
    InverseCovarianceMinimumHessianEigenvalue =
      mfrmr_gtm_hessian_minimum(fit),
    RichardsonAvailable = richardson$Available,
    RichardsonDimension = richardson$Dimension,
    RichardsonJacobianHash = richardson$JacobianHash,
    RichardsonSymmetryResidual = richardson$SymmetryResidual,
    RichardsonEigenvalueHash = richardson$EigenvalueHash,
    RichardsonMinimumEigenvalue = richardson$MinimumEigenvalue,
    RichardsonMaximumEigenvalue = richardson$MaximumEigenvalue,
    RichardsonMinimumRelativeEigenvalue =
      richardson$MinimumRelativeEigenvalue,
    RichardsonMinimumAbsoluteRelativeEigenvalue =
      richardson$MinimumAbsoluteRelativeEigenvalue,
    RichardsonPositiveDefinite = richardson$PositiveDefinite,
    RichardsonFailureDigest = richardson$FailureDigest
  )
}

mfrmr_gtwsv_empty_diagnostics <- function() {
  list(
    OptimizerCode = NA_integer_, OptimizerMessageDigest = "none",
    Objective = NA_real_, LogLikelihood = NA_real_,
    LogLikelihoodDf = NA_integer_, Nobs = NA_integer_,
    TopLevelParameterHash = "none", JointBestHash = "none",
    JointBestLength = 0L, FixedCoordinateExact = FALSE,
    FinalStartSignatureHash = "none", OuterGradientAvailable = FALSE,
    OuterGradientLength = 0L, OuterGradientHash = "none",
    OuterGradientMaximumAbsolute = NA_real_, OuterGradientL2Norm = NA_real_,
    SdGradientAvailable = FALSE, SdGradientLength = 0L,
    SdGradientHash = "none", SdGradientMaximumAbsolute = NA_real_,
    SdGradientL2Norm = NA_real_,
    SdreportPositiveDefiniteHessian = FALSE,
    InverseCovarianceMinimumHessianEigenvalue = NA_real_,
    RichardsonAvailable = FALSE, RichardsonDimension = 0L,
    RichardsonJacobianHash = "none", RichardsonSymmetryResidual = NA_real_,
    RichardsonEigenvalueHash = "none",
    RichardsonMinimumEigenvalue = NA_real_,
    RichardsonMaximumEigenvalue = NA_real_,
    RichardsonMinimumRelativeEigenvalue = NA_real_,
    RichardsonMinimumAbsoluteRelativeEigenvalue = NA_real_,
    RichardsonPositiveDefinite = FALSE, RichardsonFailureDigest = "none"
  )
}

mfrmr_gtwsv_fit_one <- function(formula, data, reml, profile,
                                  parent_result, model_role,
                                  runner_contract) {
  parent_required <- profile$ParentProfileId[[1L]] != "none"
  input_signature <- NULL
  start <- NULL
  if (parent_required) {
    if (is.null(parent_result) || !isTRUE(parent_result$Returned) ||
        !inherits(parent_result$FinalSignature,
                  "mfrmr_gtwsv_start_signature")) {
      return(list(
        Returned = FALSE, FailureStage = "parent_fit_or_start_unavailable",
        FailureDigest = mfrmr_gta_hash(paste(
          profile$ParentProfileId[[1L]], model_role, sep = "::"
        )), InputStartSignatureHash = "unavailable",
        ParentFinalStartSignatureHash = if (is.null(parent_result) ||
          is.null(parent_result$FinalStartSignatureHash)) "none" else
          parent_result$FinalStartSignatureHash,
        StartTransferVerified = FALSE, FinalStartSignatureHash = "none",
        FinalSignature = NULL, Fit = NULL,
        Warnings = character(), Messages = character(),
        Diagnostics = mfrmr_gtwsv_empty_diagnostics()
      ))
    }
    input_signature <- parent_result$FinalSignature
    start <- input_signature$StartList
  }
  control <- mfrmr_gtwsv_control(
    profile$ProfileId[[1L]], runner_contract$Profiles
  )
  captured <- tryCatch(
    mfrmr_gtwd_capture(glmmTMB::glmmTMB(
      formula = formula, data = data,
      family = stats::gaussian(link = "identity"),
      ziformula = ~ 0, dispformula = ~ 1, REML = reml,
      start = start, control = control
    )),
    error = function(error) error
  )
  if (inherits(captured, "error")) {
    return(list(
      Returned = FALSE, FailureStage = paste0(model_role, "_fit_failure"),
      FailureDigest = mfrmr_gta_hash(conditionMessage(captured)),
      InputStartSignatureHash = if (is.null(input_signature))
        "cold_NULL" else input_signature$SignatureHash,
      ParentFinalStartSignatureHash = if (is.null(input_signature))
        "none" else input_signature$SignatureHash,
      StartTransferVerified = !parent_required,
      FinalStartSignatureHash = "none", FinalSignature = NULL,
      Fit = NULL, Warnings = character(), Messages = character(),
      Diagnostics = mfrmr_gtwsv_empty_diagnostics()
    ))
  }
  final_signature <- tryCatch(
    mfrmr_gtwsv_extract_start(captured$Fit), error = function(error) error
  )
  if (inherits(final_signature, "error")) {
    return(list(
      Returned = FALSE, FailureStage = paste0(model_role,
                                               "_start_snapshot_failure"),
      FailureDigest = mfrmr_gta_hash(conditionMessage(final_signature)),
      InputStartSignatureHash = if (is.null(input_signature))
        "cold_NULL" else input_signature$SignatureHash,
      ParentFinalStartSignatureHash = if (is.null(input_signature))
        "none" else input_signature$SignatureHash,
      StartTransferVerified = FALSE, FinalStartSignatureHash = "none",
      FinalSignature = NULL, Fit = NULL,
      Warnings = captured$Warnings, Messages = captured$Messages,
      Diagnostics = mfrmr_gtwsv_empty_diagnostics()
    ))
  }
  transfer_verified <- if (parent_required) {
    identical(input_signature$SignatureHash,
              parent_result$FinalStartSignatureHash)
  } else TRUE
  diagnostics <- mfrmr_gtwsv_fit_diagnostics(
    captured$Fit, final_signature, runner_contract
  )
  list(
    Returned = TRUE, FailureStage = "none", FailureDigest = "none",
    InputStartSignatureHash = if (is.null(input_signature))
      "cold_NULL" else input_signature$SignatureHash,
    ParentFinalStartSignatureHash = if (is.null(input_signature))
      "none" else parent_result$FinalStartSignatureHash,
    StartTransferVerified = transfer_verified,
    FinalStartSignatureHash = final_signature$SignatureHash,
    FinalSignature = final_signature, Fit = captured$Fit,
    Warnings = captured$Warnings, Messages = captured$Messages,
    Diagnostics = diagnostics
  )
}

mfrmr_gtwsv_pair_state <- function(full, reduced, same_rows,
                                     df_difference, drop,
                                     negative_tolerance = 1e-6) {
  parent_failure <- any(c(full$FailureStage, reduced$FailureStage) ==
                          "parent_fit_or_start_unavailable")
  if (parent_failure) return("parent_fit_or_start_unavailable")
  if (!full$Returned && !reduced$Returned)
    return("full_and_reduced_fit_failure")
  if (!full$Returned) return("full_fit_failure")
  if (!reduced$Returned) return("reduced_fit_failure")
  fd <- full$Diagnostics
  rd <- reduced$Diagnostics
  if (!all(is.finite(c(fd$Objective, rd$Objective,
                       fd$LogLikelihood, rd$LogLikelihood, drop))))
    return("nonfinite_objective_or_likelihood")
  if (!identical(fd$OptimizerCode, 0L) || !identical(rd$OptimizerCode, 0L))
    return("optimizer_nonzero")
  if (!isTRUE(fd$OuterGradientAvailable) ||
      !isTRUE(rd$OuterGradientAvailable) ||
      !isTRUE(fd$SdGradientAvailable) || !isTRUE(rd$SdGradientAvailable))
    return("gradient_unavailable")
  if (!isTRUE(fd$RichardsonAvailable) || !isTRUE(rd$RichardsonAvailable))
    return("hessian_unavailable")
  if (!isTRUE(fd$SdreportPositiveDefiniteHessian) ||
      !isTRUE(rd$SdreportPositiveDefiniteHessian) ||
      !isTRUE(fd$RichardsonPositiveDefinite) ||
      !isTRUE(rd$RichardsonPositiveDefinite)) return("nonpositive_hessian")
  if (!isTRUE(same_rows) || !identical(df_difference, 1L))
    return("likelihood_identity_failure")
  if (is.finite(drop) && drop < -negative_tolerance)
    return("finite_material_negative_drop")
  "returned_diagnostic_complete"
}

mfrmr_gtwsv_fit_pair <- function(generation, prefit, route,
                                   parent_pair, runner_contract) {
  profile <- runner_contract$Profiles[
    runner_contract$Profiles$ProfileId == route$ProfileId[[1L]],
    , drop = FALSE
  ]
  reml <- identical(route$Likelihood[[1L]], "REML")
  full_formula <- stats::as.formula(generation$Spec$FormulaCanonical)
  reduced_formula <- mfrmr_gtwd_reduced_formula(
    generation$Spec, runner_contract$TargetComponent
  )
  data <- prefit$StructuralRankAudit$PreparedData$Data
  full_parent <- if (is.null(parent_pair)) NULL else parent_pair$Full
  reduced_parent <- if (is.null(parent_pair)) NULL else parent_pair$Reduced
  full <- mfrmr_gtwsv_fit_one(
    full_formula, data, reml, profile, full_parent, "full", runner_contract
  )
  reduced <- mfrmr_gtwsv_fit_one(
    reduced_formula, data, reml, profile, reduced_parent, "reduced",
    runner_contract
  )
  if (full$Returned && reduced$Returned) {
    full_diag <- full$Diagnostics
    reduced_diag <- reduced$Diagnostics
    drop <- 2 * (full_diag$LogLikelihood - reduced_diag$LogLikelihood)
    same_rows <- identical(full_diag$Nobs, reduced_diag$Nobs) &&
      identical(full_diag$Nobs, nrow(data))
    df_difference <- full_diag$LogLikelihoodDf -
      reduced_diag$LogLikelihoodDf
  } else {
    drop <- NA_real_
    same_rows <- FALSE
    df_difference <- NA_integer_
  }
  state <- mfrmr_gtwsv_pair_state(
    full, reduced, same_rows, df_difference, drop,
    runner_contract$NegativeLikelihoodTolerance
  )
  list(
    Full = full, Reduced = reduced, RawLikelihoodDrop = drop,
    SameRows = same_rows, LikelihoodDfDifference = df_difference,
    StabilizationState = state,
    ParentProfileId = profile$ParentProfileId[[1L]],
    PairReturned = full$Returned && reduced$Returned,
    StartTransferVerified = full$StartTransferVerified &&
      reduced$StartTransferVerified
  )
}

mfrmr_gtwsv_diag_fields <- function(diagnostic, prefix) {
  names(diagnostic) <- paste0(prefix, names(diagnostic))
  diagnostic
}

mfrmr_gtwsv_atomic_row <- function(route, pair, runner_contract) {
  full <- pair$Full
  reduced <- pair$Reduced
  payload <- c(
    as.list(route),
    list(
      RunnerContractHash = runner_contract$RunnerContractHash,
      PairReturned = pair$PairReturned,
      FullReturned = full$Returned, ReducedReturned = reduced$Returned,
      ParentProfileIdObserved = pair$ParentProfileId,
      FullInputStartSignatureHash = full$InputStartSignatureHash,
      ReducedInputStartSignatureHash = reduced$InputStartSignatureHash,
      FullParentFinalStartSignatureHash =
        full$ParentFinalStartSignatureHash,
      ReducedParentFinalStartSignatureHash =
        reduced$ParentFinalStartSignatureHash,
      StartTransferVerified = pair$StartTransferVerified,
      FullWarningCount = length(full$Warnings),
      ReducedWarningCount = length(reduced$Warnings),
      FullWarningDigest = mfrmr_gta_hash(full$Warnings),
      ReducedWarningDigest = mfrmr_gta_hash(reduced$Warnings),
      FullMessageCount = length(full$Messages),
      ReducedMessageCount = length(reduced$Messages),
      FullMessageDigest = mfrmr_gta_hash(full$Messages),
      ReducedMessageDigest = mfrmr_gta_hash(reduced$Messages),
      FullFailureStage = full$FailureStage,
      ReducedFailureStage = reduced$FailureStage,
      FullFailureDigest = full$FailureDigest,
      ReducedFailureDigest = reduced$FailureDigest
    ),
    mfrmr_gtwsv_diag_fields(full$Diagnostics, "Full"),
    mfrmr_gtwsv_diag_fields(reduced$Diagnostics, "Reduced"),
    list(
      SameRows = pair$SameRows,
      LikelihoodDfDifference = pair$LikelihoodDfDifference,
      RawLikelihoodDrop = pair$RawLikelihoodDrop,
      MaterialNegativeDrop = is.finite(pair$RawLikelihoodDrop) &&
        pair$RawLikelihoodDrop < -runner_contract$NegativeLikelihoodTolerance,
      StabilizationState = pair$StabilizationState,
      ThresholdApplied = FALSE, PValue = NA_real_, Interval = "none",
      CalibrationUse = FALSE, DecisionUse = FALSE
    )
  )
  identity <- list(
    Contract = "glmmtmb_stabilization_atomic_pair_draft83d2b2b1g1_v1",
    Payload = payload
  )
  row <- data.frame(payload, stringsAsFactors = FALSE, check.names = FALSE)
  row$PairResultHash <- mfrmr_gta_hash(identity)
  row
}

mfrmr_gtwsv_failure_rows <- function(routes, runner_contract, stage,
                                      message) {
  digest <- mfrmr_gta_hash(as.character(message))
  rows <- lapply(seq_len(nrow(routes)), function(index) {
    route <- routes[index, , drop = FALSE]
    fit_failure <- list(
      Returned = FALSE, FailureStage = stage, FailureDigest = digest,
      InputStartSignatureHash = "unavailable",
      ParentFinalStartSignatureHash = "unavailable",
      StartTransferVerified = FALSE, FinalStartSignatureHash = "none",
      FinalSignature = NULL, Fit = NULL, Warnings = character(),
      Messages = character(), Diagnostics = mfrmr_gtwsv_empty_diagnostics()
    )
    pair <- list(
      Full = fit_failure, Reduced = fit_failure, RawLikelihoodDrop = NA_real_,
      SameRows = FALSE, LikelihoodDfDifference = NA_integer_,
      StabilizationState = "generation_or_prefit_failure",
      ParentProfileId = route$ParentProfileId[[1L]], PairReturned = FALSE,
      StartTransferVerified = FALSE
    )
    mfrmr_gtwsv_atomic_row(route, pair, runner_contract)
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_gtwsv_base_route <- function(generation, prefit, routes,
                                    runner_contract) {
  if (!inherits(generation, "mfrmr_gtd2_generation") ||
      !inherits(prefit, "mfrmr_gtd3_prefit") ||
      !isTRUE(prefit$PreFitEligible) || !is.data.frame(routes) ||
      nrow(routes) != 6L || length(unique(routes$RouteId)) != 1L) {
    stop("One eligible six-profile base route is required.", call. = FALSE)
  }
  order_index <- order(
    routes$ExecutionOrder,
    match(routes$ProfileId, runner_contract$Profiles$ProfileId),
    method = "radix"
  )
  routes <- routes[order_index, , drop = FALSE]
  pairs <- list()
  atomic <- vector("list", nrow(routes))
  for (index in seq_len(nrow(routes))) {
    route <- routes[index, , drop = FALSE]
    parent_id <- route$ParentProfileId[[1L]]
    parent <- if (identical(parent_id, "none")) NULL else pairs[[parent_id]]
    pair <- mfrmr_gtwsv_fit_pair(
      generation, prefit, route, parent, runner_contract
    )
    pairs[[route$ProfileId[[1L]]]] <- pair
    atomic[[index]] <- mfrmr_gtwsv_atomic_row(
      route, pair, runner_contract
    )
  }
  atomic <- do.call(rbind, atomic)
  row.names(atomic) <- NULL
  atomic <- atomic[match(routes$StabilizationRouteId,
                         atomic$StabilizationRouteId), , drop = FALSE]
  if (nrow(atomic) != 6L || anyDuplicated(atomic$StabilizationRouteId)) {
    stop("Base-route stabilization accounting failed.", call. = FALSE)
  }
  atomic
}

mfrmr_gtwsv_contract <- function(design_contract, design_manifest) {
  mfrmr_gtwsv_require_primitives()
  smoke_rows <- mfrmr_gtwsv_smoke_rows(design_contract, design_manifest)
  smoke_identity <- smoke_rows[, c(
    "StabilizationRouteId", "RouteId", "DatasetId", "ScenarioId",
    "Replicate", "DesignId", "VarianceId", "MethodId", "Likelihood",
    "ProfileId", "ProfileHash", "ParentStabilizationRouteId"
  ), drop = FALSE]
  identity <- list(
    Contract =
      "gtheory_weak_information_glmmtmb_stabilization_runner_draft83d2b2b1g1_v1",
    ContractArtifact = paste0(
      "gtheory-weak-information-glmmtmb-stabilization-runner-",
      "contract-0.2.3.md"
    ),
    StabilizationContractHash = design_contract$ContractHash,
    StabilizationManifestHash = design_manifest$ManifestHash,
    Profiles = design_contract$Profiles,
    SmokeIdentity = smoke_identity,
    SmokePairCount = 120L, SmokeBackendFitCount = 240L,
    SmokeBaseRouteCount = 20L, SmokeDatasetCount = 10L,
    SmokeRowsPerBaseRoute = 6L, SmokeRowsPerDataset = 12L,
    SmokeSelection = list(
      DesignId = sort(unique(smoke_rows$DesignId), method = "radix"),
      VarianceId = c("exact_zero", "reference_1200"), Replicate = 101L,
      MethodId = c("glmmTMB_ml", "glmmTMB_reml"),
      OutcomeDependentSelection = FALSE
    ),
    TargetComponent = "Rater", BoundaryTolerance = 1e-8,
    NegativeLikelihoodTolerance = 1e-6,
    Richardson = design_contract$Richardson,
    ParentFailurePolicy = design_contract$ParentFailurePolicy,
    AtomicUnit = "one_base_route_all_six_profiles",
    ScientificHashExclusions = c(
      "timing", "checkpoint_root", "execution_order",
      "computed_or_reused", "progress_frequency"
    ),
    EarlyStoppingPermitted = FALSE, AdaptiveFallbackPermitted = FALSE,
    CalibrationDataGenerationPermitted = FALSE,
    ThresholdSelectionPermitted = FALSE, BootstrapPermitted = FALSE,
    PackageVersions = c(
      glmmTMB = as.character(utils::packageVersion("glmmTMB")),
      TMB = as.character(utils::packageVersion("TMB")),
      numDeriv = as.character(utils::packageVersion("numDeriv")),
      digest = as.character(utils::packageVersion("digest"))
    ),
    FunctionHashes = mfrmr_gtwsv_function_hashes()
  )
  structure(c(identity, list(
    RunnerContractHash = mfrmr_gta_hash(identity),
    RunnerImplemented = TRUE, SmokeExecutionAuthorized = TRUE,
    FullExecutionAuthorized = FALSE,
    NumericalStabilizationReady = FALSE,
    NumericalSensitivityEvidenceReady = FALSE,
    CalibrationEvidenceReady = FALSE,
    ThresholdFrozen = FALSE, ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwsv_contract")
}

mfrmr_gtwsv_checkpoint_path <- function(checkpoint_root, route_id) {
  file.path(
    mfrmr_gtwx_checkpoint_root(checkpoint_root), "base-routes",
    paste0(mfrmr_gta_hash(route_id), ".rds")
  )
}

mfrmr_gtwsv_marker_path <- function(checkpoint_root, dataset_id) {
  file.path(
    mfrmr_gtwx_checkpoint_root(checkpoint_root), "datasets",
    paste0(mfrmr_gta_hash(dataset_id), ".rds")
  )
}

mfrmr_gtwsv_checkpoint <- function(runner_contract, routes, generation,
                                    prefit, atomic_rows, timing = NULL) {
  identity <- list(
    Contract = "glmmtmb_stabilization_base_checkpoint_draft83d2b2b1g1_v1",
    RunnerContractHash = runner_contract$RunnerContractHash,
    StabilizationContractHash = runner_contract$StabilizationContractHash,
    StabilizationManifestHash = runner_contract$StabilizationManifestHash,
    BaseRouteIdentity = routes,
    GeneratorHash = if (is.null(generation)) "none" else
      generation$GeneratorHash,
    AnalysisDataHash = if (is.null(generation)) "none" else
      generation$GeneratorIdentity$AnalysisDataHash,
    PreFitHash = if (is.null(prefit)) "none" else prefit$ResultHash,
    RetainedDataHash = if (is.null(prefit)) "none" else
      prefit$StructuralRankAudit$PreparedData$RetainedDataHash,
    AtomicRows = atomic_rows
  )
  structure(list(
    Identity = identity, ResultHash = mfrmr_gta_hash(identity), Timing = timing
  ), class = "mfrmr_gtwsv_checkpoint")
}

mfrmr_gtwsv_validate_checkpoint <- function(checkpoint, runner_contract,
                                              routes) {
  valid <- inherits(checkpoint, "mfrmr_gtwsv_checkpoint") &&
    is.list(checkpoint$Identity) &&
    identical(checkpoint$ResultHash, mfrmr_gta_hash(checkpoint$Identity)) &&
    identical(checkpoint$Identity$RunnerContractHash,
              runner_contract$RunnerContractHash) &&
    identical(checkpoint$Identity$BaseRouteIdentity, routes) &&
    is.data.frame(checkpoint$Identity$AtomicRows) &&
    nrow(checkpoint$Identity$AtomicRows) == 6L &&
    identical(
      as.character(checkpoint$Identity$AtomicRows$StabilizationRouteId),
      as.character(routes$StabilizationRouteId)
    ) && !anyDuplicated(checkpoint$Identity$AtomicRows$StabilizationRouteId)
  list(
    Valid = isTRUE(valid),
    ResultHash = if (isTRUE(valid)) checkpoint$ResultHash else "none",
    AtomicRows = if (isTRUE(valid)) checkpoint$Identity$AtomicRows else NULL
  )
}

mfrmr_gtwsv_marker <- function(runner_contract, dataset_id, checkpoints) {
  hashes <- vapply(checkpoints, `[[`, character(1L), "ResultHash")
  names(hashes) <- vapply(checkpoints, function(checkpoint) {
    checkpoint$Identity$BaseRouteIdentity$RouteId[[1L]]
  }, character(1L))
  hashes <- hashes[order(names(hashes), method = "radix")]
  identity <- list(
    Contract = "glmmtmb_stabilization_dataset_marker_draft83d2b2b1g1_v1",
    RunnerContractHash = runner_contract$RunnerContractHash,
    DatasetId = dataset_id, BaseRouteResultHashes = hashes,
    BaseRouteCount = length(hashes), PairRowCount = 12L,
    CompletionState = "both_likelihood_routes_all_profiles_valid"
  )
  structure(list(
    Identity = identity, MarkerHash = mfrmr_gta_hash(identity)
  ), class = "mfrmr_gtwsv_marker")
}

mfrmr_gtwsv_validate_marker <- function(marker, runner_contract,
                                          dataset_id, checkpoints) {
  if (!inherits(marker, "mfrmr_gtwsv_marker") ||
      !identical(marker$MarkerHash, mfrmr_gta_hash(marker$Identity))) {
    return(FALSE)
  }
  expected <- mfrmr_gtwsv_marker(
    runner_contract, dataset_id, checkpoints
  )
  identical(marker$Identity, expected$Identity) &&
    identical(marker$MarkerHash, expected$MarkerHash) &&
    identical(marker$Identity$BaseRouteCount, 2L)
}

mfrmr_gtwsv_summaries <- function(rows, runner_contract) {
  states <- c(
    "generation_or_prefit_failure", "parent_fit_or_start_unavailable",
    "full_and_reduced_fit_failure", "full_fit_failure",
    "reduced_fit_failure", "nonfinite_objective_or_likelihood",
    "optimizer_nonzero", "gradient_unavailable", "hessian_unavailable",
    "nonpositive_hessian", "likelihood_identity_failure",
    "finite_material_negative_drop", "returned_diagnostic_complete"
  )
  state_counts <- table(factor(rows$StabilizationState, levels = states))
  profile_groups <- split(rows, rows$ProfileId)
  profile <- do.call(rbind, lapply(profile_groups, function(group) {
    data.frame(
      ProfileId = group$ProfileId[[1L]], PlannedN = nrow(group),
      PairReturnedN = sum(group$PairReturned %in% TRUE),
      TransferVerifiedN = sum(group$StartTransferVerified %in% TRUE),
      FullRichardsonAvailableN = sum(group$FullRichardsonAvailable %in% TRUE),
      ReducedRichardsonAvailableN =
        sum(group$ReducedRichardsonAvailable %in% TRUE),
      FullRichardsonPositiveDefiniteN =
        sum(group$FullRichardsonPositiveDefinite %in% TRUE),
      ReducedRichardsonPositiveDefiniteN =
        sum(group$ReducedRichardsonPositiveDefinite %in% TRUE),
      MaterialNegativeN = sum(group$MaterialNegativeDrop %in% TRUE),
      stringsAsFactors = FALSE
    )
  }))
  row.names(profile) <- NULL
  profile <- profile[order(profile$ProfileId, method = "radix"), , drop = FALSE]
  list(
    StateCounts = state_counts, ProfileSummary = profile,
    ThresholdSelected = FALSE, CalibrationDataGenerated = FALSE,
    OptimizerSelected = FALSE, StartRuleSelected = FALSE
  )
}

mfrmr_gtwsv_execute <- function(runner_contract, design_manifest,
                                 checkpoint_root, progress_every = 1L) {
  if (!inherits(runner_contract, "mfrmr_gtwsv_contract") ||
      !isTRUE(runner_contract$RunnerImplemented) ||
      !isTRUE(runner_contract$SmokeExecutionAuthorized) ||
      isTRUE(runner_contract$FullExecutionAuthorized) ||
      isTRUE(runner_contract$CalibrationDataGenerationPermitted) ||
      isTRUE(runner_contract$ThresholdSelectionPermitted) ||
      isTRUE(runner_contract$BootstrapPermitted) ||
      isTRUE(runner_contract$EarlyStoppingPermitted) ||
      !inherits(design_manifest, "mfrmr_gtwst_manifest") ||
      !identical(runner_contract$StabilizationManifestHash,
                 design_manifest$ManifestHash)) {
    stop("The exact b1g1 covering-smoke execution is not authorized.",
         call. = FALSE)
  }
  checkpoint_root <- mfrmr_gtwx_checkpoint_root(checkpoint_root)
  progress_every <- as.integer(progress_every)
  if (length(progress_every) != 1L || is.na(progress_every) ||
      progress_every < 0L) stop("Invalid progress frequency.", call. = FALSE)
  rows <- design_manifest$Rows[
    design_manifest$Rows$StabilizationRouteId %in%
      runner_contract$SmokeIdentity$StabilizationRouteId, , drop = FALSE
  ]
  rows <- rows[match(runner_contract$SmokeIdentity$StabilizationRouteId,
                     rows$StabilizationRouteId), , drop = FALSE]
  if (nrow(rows) != runner_contract$SmokePairCount || anyNA(rows$RouteId)) {
    stop("Authorized smoke rows are incomplete.", call. = FALSE)
  }
  dataset_ids <- unique(rows$DatasetId)
  registry <- mfrmr_gtw_registry()
  atomic_out <- list()
  timing_out <- list()
  checkpoint_hashes <- character()
  marker_hashes <- character()
  reused <- logical()
  cursor <- 0L
  for (dataset_index in seq_along(dataset_ids)) {
    dataset_id <- dataset_ids[[dataset_index]]
    dataset_rows <- rows[rows$DatasetId == dataset_id, , drop = FALSE]
    route_ids <- unique(dataset_rows$RouteId)
    routes <- lapply(route_ids, function(route_id) {
      dataset_rows[dataset_rows$RouteId == route_id, , drop = FALSE]
    })
    paths <- vapply(route_ids, function(route_id) {
      mfrmr_gtwsv_checkpoint_path(checkpoint_root, route_id)
    }, character(1L))
    checkpoints <- lapply(paths, mfrmr_gtwx_safe_read)
    validations <- lapply(seq_along(routes), function(index) {
      mfrmr_gtwsv_validate_checkpoint(
        checkpoints[[index]], runner_contract, routes[[index]]
      )
    })
    valid <- vapply(validations, `[[`, logical(1L), "Valid")
    initially_valid <- valid
    generation <- NULL
    prefit <- NULL
    generation_error <- NULL
    if (!all(valid)) {
      generated <- tryCatch({
        generation <- mfrmr_gtw_generate(
          registry, dataset_rows$ScenarioId[[1L]],
          dataset_rows$Replicate[[1L]]
        )
        prefit <- mfrmr_gtd3_prefit_one(generation)
        if (!isTRUE(prefit$PreFitEligible))
          stop("Covering-smoke pre-fit is ineligible.", call. = FALSE)
        TRUE
      }, error = function(error) error)
      if (inherits(generated, "error")) generation_error <- generated
      for (route_index in which(!valid)) {
        route_rows <- routes[[route_index]]
        clock <- system.time({
          if (is.null(generation_error)) {
            atomic <- mfrmr_gtwsv_base_route(
              generation, prefit, route_rows, runner_contract
            )
          } else {
            atomic <- mfrmr_gtwsv_failure_rows(
              route_rows, runner_contract, "generation_or_prefit_failure",
              conditionMessage(generation_error)
            )
          }
        }, gcFirst = TRUE)
        timing <- data.frame(
          RouteId = route_rows$RouteId[[1L]],
          UserSeconds = unname(clock[["user.self"]]),
          SystemSeconds = unname(clock[["sys.self"]]),
          ElapsedSeconds = unname(clock[["elapsed"]]),
          stringsAsFactors = FALSE
        )
        checkpoint <- mfrmr_gtwsv_checkpoint(
          runner_contract, route_rows, generation, prefit, atomic, timing
        )
        mfrmr_gtwx_atomic_write(checkpoint, paths[[route_index]])
        checkpoints[[route_index]] <- checkpoint
        validations[[route_index]] <- mfrmr_gtwsv_validate_checkpoint(
          checkpoint, runner_contract, route_rows
        )
        valid[[route_index]] <- validations[[route_index]]$Valid
      }
    }
    if (!all(valid)) stop("A smoke base route is incomplete.", call. = FALSE)
    marker_path <- mfrmr_gtwsv_marker_path(checkpoint_root, dataset_id)
    marker <- mfrmr_gtwx_safe_read(marker_path)
    marker_valid <- mfrmr_gtwsv_validate_marker(
      marker, runner_contract, dataset_id, checkpoints
    )
    if (!marker_valid) {
      marker <- mfrmr_gtwsv_marker(
        runner_contract, dataset_id, checkpoints
      )
      mfrmr_gtwx_atomic_write(marker, marker_path)
      marker_valid <- mfrmr_gtwsv_validate_marker(
        marker, runner_contract, dataset_id, checkpoints
      )
    }
    if (!marker_valid) stop("A smoke dataset marker failed.", call. = FALSE)
    for (route_index in seq_along(routes)) {
      cursor <- cursor + 1L
      atomic_out[[cursor]] <- validations[[route_index]]$AtomicRows
      checkpoint_hashes[[cursor]] <- validations[[route_index]]$ResultHash
      reused[[cursor]] <- initially_valid[[route_index]]
      timing_out[[cursor]] <- checkpoints[[route_index]]$Timing
    }
    marker_hashes[[dataset_index]] <- marker$MarkerHash
    if (progress_every > 0L &&
        (dataset_index %% progress_every == 0L ||
         dataset_index == length(dataset_ids))) {
      message(sprintf(
        "[glmmTMB stabilization smoke dataset %d/%d] %s",
        dataset_index, length(dataset_ids), dataset_id
      ))
    }
  }
  atomic <- do.call(rbind, atomic_out)
  timing <- do.call(rbind, timing_out)
  row.names(atomic) <- NULL
  row.names(timing) <- NULL
  order_index <- match(runner_contract$SmokeIdentity$StabilizationRouteId,
                       atomic$StabilizationRouteId)
  if (anyNA(order_index)) stop("Smoke atomic rows are incomplete.",
                               call. = FALSE)
  atomic <- atomic[order_index, , drop = FALSE]
  checkpoint_hashes <- checkpoint_hashes[match(
    unique(runner_contract$SmokeIdentity$RouteId),
    vapply(atomic_out, function(x) x$RouteId[[1L]], character(1L))
  )]
  names(checkpoint_hashes) <- unique(runner_contract$SmokeIdentity$RouteId)
  names(marker_hashes) <- dataset_ids
  exact <- nrow(atomic) == runner_contract$SmokePairCount &&
    !anyDuplicated(atomic$StabilizationRouteId) &&
    identical(as.character(atomic$StabilizationRouteId),
              as.character(runner_contract$SmokeIdentity$StabilizationRouteId)) &&
    all(table(atomic$RouteId) == runner_contract$SmokeRowsPerBaseRoute) &&
    all(table(atomic$DatasetId) == runner_contract$SmokeRowsPerDataset) &&
    length(checkpoint_hashes) == runner_contract$SmokeBaseRouteCount &&
    length(marker_hashes) == runner_contract$SmokeDatasetCount
  if (!exact) stop("Final covering-smoke accounting failed.", call. = FALSE)
  summaries <- mfrmr_gtwsv_summaries(atomic, runner_contract)
  identity <- list(
    Contract =
      "gtheory_weak_information_glmmtmb_stabilization_smoke_draft83d2b2b1g1_v1",
    RunnerContractHash = runner_contract$RunnerContractHash,
    StabilizationContractHash = runner_contract$StabilizationContractHash,
    StabilizationManifestHash = runner_contract$StabilizationManifestHash,
    AtomicRows = atomic, BaseRouteCheckpointHashes = checkpoint_hashes,
    DatasetMarkerHashes = marker_hashes, Summaries = summaries
  )
  structure(c(identity, list(
    ExecutionHash = mfrmr_gta_hash(identity), RouteTiming = timing,
    CheckpointReuse = reused, CheckpointReuseCount = sum(reused),
    ComputedBaseRouteCount = sum(!reused), ExactAccountingPassed = exact,
    PlannedPairs = runner_contract$SmokePairCount,
    PlannedBackendFits = runner_contract$SmokeBackendFitCount,
    PairReturnCount = sum(atomic$PairReturned %in% TRUE),
    StartTransferVerifiedCount =
      sum(atomic$StartTransferVerified %in% TRUE),
    SmokeRunnerMechanicsReady = exact,
    FullExecutionAuthorized = FALSE,
    NumericalStabilizationReady = FALSE,
    NumericalSensitivityEvidenceReady = FALSE,
    CalibrationEvidenceReady = FALSE,
    BootstrapOperatingCharacteristicsReady = FALSE,
    ThresholdFrozen = FALSE, ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwsv_execution")
}
