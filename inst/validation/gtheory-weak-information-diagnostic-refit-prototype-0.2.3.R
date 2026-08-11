# Draft.83d2b2b1a source-audited weak-information diagnostic refit prototype.
#
# Repository-internal only. This file records raw full/reduced likelihood
# differences and backend-coordinate local quadratic diagnostics. It computes
# no p-value, confidence interval, calibrated threshold, or D-study decision.

mfrmr_gtwd_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gta_component_id",
    "mfrmr_gtc_lme4_diagnostics", "mfrmr_gtm_diagnostics",
    "mfrmr_gtd4_lme4_components", "mfrmr_gtm_components",
    "mfrmr_gtw_registry", "mfrmr_gtw_generate", "mfrmr_gtd3_prefit_one",
    "mfrmr_gtwp_plan", "mfrmr_gtwp_manifest"
  )
  prototype_environment <- environment(mfrmr_gtwd_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = prototype_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.81/83c/83d/83d2b2a/83d2b2b0 before ",
      "Draft.83d2b2b1a: ", paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwd_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtwd_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwd_inference_contract", "mfrmr_gtwd_reduced_formula",
    "mfrmr_gtwd_lme4_coordinate", "mfrmr_gtwd_glmmtmb_coordinate",
    "mfrmr_gtwd_diagnostic_pair", "mfrmr_gtwd_execute_schema"
  )
  environment <- environment(mfrmr_gtwd_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwd_function_hash(get(name, envir = environment, inherits = TRUE))
  }, character(1L)), functions)
}

mfrmr_gtwd_inference_contract <- function(
    registry = mfrmr_gtw_registry(), historical_plan = mfrmr_gtwp_plan(registry)) {
  mfrmr_gtwd_require_primitives()
  if (!inherits(registry, "mfrmr_gtw_registry") ||
      !inherits(historical_plan, "mfrmr_gtwp_plan")) {
    stop("Draft.83d2b2b1a requires the registered calibration and pilot plan.",
         call. = FALSE)
  }
  scores <- data.frame(
    ScoreId = c(
      "target_fraction_total", "target_to_residual_ratio",
      "target_relative_se_profiled", "reduced_likelihood_drop",
      "lme4_profiled_relative_sd_local_scale",
      "glmmtmb_log_sd_joint_local_scale",
      "backend_relative_difference", "ml_reml_relative_difference"
    ),
    SupersedingStatus = c(
      "retained_descriptive_candidate", "retained_descriptive_candidate",
      "withdrawn_noncommensurate_backend_coordinates",
      "retained_raw_separate_ml_reml_diagnostic",
      "validation_only_not_common_component_se",
      "validation_only_not_common_component_se",
      "validation_only", "validation_only"
    ),
    InferentialUse = "none_no_test_no_interval_no_decision",
    CommonCrossBackendCutpointEligible = c(
      TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE
    ),
    stringsAsFactors = FALSE
  )
  rules <- data.frame(
    RuleFamilyId = c(
      "fraction_zone", "ratio_zone", "ratio_precision_zone",
      "likelihood_precision_zone"
    ),
    SupersedingStatus = c(
      "retained_for_future_empirical_calibration",
      "retained_for_future_empirical_calibration",
      "withdrawn_requires_invalid_common_relative_se",
      "withdrawn_requires_invalid_common_relative_se"
    ),
    ThresholdFrozen = FALSE,
    stringsAsFactors = FALSE
  )
  sources <- data.frame(
    SourceId = c(
      "Self_Liang_1987", "Crainiceanu_Ruppert_2004",
      "Greven_et_al_2008", "Bates_et_al_2015", "Brooks_et_al_2017",
      "lme4_pvalues_current", "glmmTMB_fit_current",
      "glmmTMB_vcov_current", "RLRsim_manual_current"
    ),
    Locator = c(
      "doi:10.1080/01621459.1987.10478472",
      "doi:10.1111/j.1467-9868.2004.00438.x",
      "doi:10.1198/106186008X386599",
      "doi:10.18637/jss.v067.i01", "doi:10.32614/RJ-2017-066",
      "https://lme4.github.io/lme4/reference/pvalues.html",
      "https://glmmtmb.github.io/glmmTMB/reference/glmmTMB.html",
      "https://glmmtmb.github.io/glmmTMB/reference/vcov.glmmTMB.html",
      "https://cran.r-universe.dev/RLRsim/doc/manual.html"
    ),
    stringsAsFactors = FALSE
  )
  identity <- list(
    Contract = "gtheory_weak_information_inference_draft83d2b2b1a_v1",
    CalibrationRegistryHash = registry$RegistryHash,
    HistoricalPilotPlanHash = historical_plan$PlanHash,
    MathematicalAuditArtifact =
      "gtheory-weak-information-inference-audit-0.2.3.md",
    TargetComponent = "Rater",
    FullReducedContract = paste(
      "same retained rows, response, fixed effects, backend, and ML/REML;",
      "remove only target random intercept"
    ),
    LikelihoodDrop = "2*(full_logLik-reduced_logLik)_raw_not_truncated",
    LikelihoodReferenceLaw = "not_assigned_multi_component_boundary_problem",
    ExactRLRsimApplicable = FALSE,
    FuturePrimaryNullCalibration =
      "custom_reduced_model_parametric_bootstrap_exact_design_same_pipeline",
    NullSeparationEqualsPositiveRecovery = FALSE,
    BackendCoordinatesCommensurate = FALSE,
    Scores = scores, Rules = rules, Sources = sources,
    HistoricalFeasibilityExecutionSuperseded = TRUE,
    FeasibilityExecutionAuthorized = FALSE,
    FunctionHashes = mfrmr_gtwd_function_hashes()
  )
  structure(c(identity, list(
    ContractHash = mfrmr_gta_hash(identity), SchemaRefitAuthorized = TRUE,
    FeasibilityEvidenceReady = FALSE, CalibrationEvidenceReady = FALSE,
    ThresholdFrozen = FALSE, ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwd_contract")
}

mfrmr_gtwd_reduced_formula <- function(spec, target_component = "Rater") {
  if (!inherits(spec, "mfrmr_gta_spec")) {
    stop("`spec` must be a typed Draft.81 G-theory specification.",
         call. = FALSE)
  }
  target_component <- as.character(target_component)
  target <- which(spec$EffectMap$ComponentId == target_component)
  if (length(target_component) != 1L || length(target) != 1L ||
      identical(target_component, "Residual")) {
    stop("The target must identify exactly one non-residual component.",
         call. = FALSE)
  }
  if (!identical(spec$EffectMap$ComponentForm[[target]], "random_intercept")) {
    stop("Draft.83d2b2b1a can remove a scalar random intercept only.",
         call. = FALSE)
  }
  keep <- spec$EffectMap$ComponentId != target_component &
    !is.na(spec$EffectMap$FormulaTerm)
  terms <- spec$EffectMap$FormulaTerm[keep]
  rhs <- if (length(terms) > 0L) {
    paste("1 +", paste(terms, collapse = " + "))
  } else "1"
  formula <- stats::as.formula(paste(spec$ScoreColumn, "~", rhs))
  bars <- if (requireNamespace("reformulas", quietly = TRUE)) {
    reformulas::findbars(formula)
  } else {
    getFromNamespace("findbars", "lme4")(formula)
  }
  if (length(bars) != sum(keep)) {
    stop("Reduced formula did not preserve all non-target random terms.",
         call. = FALSE)
  }
  formula
}

mfrmr_gtwd_capture <- function(expression) {
  warnings <- character()
  messages <- character()
  fit <- withCallingHandlers(
    expression,
    warning = function(warning) {
      warnings <<- c(warnings, conditionMessage(warning))
      invokeRestart("muffleWarning")
    },
    message = function(message) {
      messages <<- c(messages, conditionMessage(message))
      invokeRestart("muffleMessage")
    }
  )
  list(Fit = fit, Warnings = warnings, Messages = messages)
}

mfrmr_gtwd_lme4_component_ids <- function(fit, spec) {
  theta <- lme4::getME(fit, "theta")
  if (is.null(names(theta)) || any(!nzchar(names(theta)))) {
    stop("lme4 theta coordinates are not named.", call. = FALSE)
  }
  group <- sub(".(Intercept)", "", names(theta), fixed = TRUE)
  declared <- c(spec$ObjectFacet, spec$RandomFacets, spec$FixedFacets)
  ids <- vapply(group, function(value) {
    mfrmr_gta_component_id(
      strsplit(value, ":", fixed = TRUE)[[1L]], declared
    )
  }, character(1L))
  expected <- spec$EffectMap$ComponentId[
    !is.na(spec$EffectMap$FormulaTerm)
  ]
  if (anyDuplicated(ids) || !setequal(ids, expected)) {
    stop("lme4 theta names do not match the typed random-component map.",
         call. = FALSE)
  }
  ids
}

mfrmr_gtwd_lme4_coordinate <- function(
    fit, spec, target_component = "Rater", boundary_tolerance = 1e-8) {
  theta <- as.numeric(lme4::getME(fit, "theta"))
  theta_ids <- mfrmr_gtwd_lme4_component_ids(fit, spec)
  index <- match(target_component, theta_ids)
  if (is.na(index)) stop("Target lme4 theta coordinate is absent.", call. = FALSE)
  estimates <- mfrmr_gtd4_lme4_components(fit, spec)
  coordinate_variance <- stats::setNames(
    as.numeric(stats::sigma(fit))^2 * theta^2, theta_ids
  )
  expected <- estimates[names(coordinate_variance)]
  tolerance <- 1e-8 * pmax(1, abs(expected))
  map_exact <- all(is.finite(coordinate_variance)) &&
    all(abs(coordinate_variance - expected) <= tolerance)
  hessian <- fit@optinfo$derivs$Hessian
  covariance <- NULL
  pd <- FALSE
  if (is.matrix(hessian) && identical(dim(hessian), c(length(theta), length(theta))) &&
      all(is.finite(hessian))) {
    symmetric <- (hessian + t(hessian)) / 2
    eigenvalues <- eigen(symmetric, symmetric = TRUE, only.values = TRUE)$values
    pd <- all(eigenvalues > 0)
    if (pd) covariance <- 2 * solve(symmetric)
  }
  local_scale <- if (pd && is.finite(covariance[index, index]) &&
                     covariance[index, index] >= 0) {
    sqrt(covariance[index, index])
  } else NA_real_
  target_theta <- theta[[index]]
  boundary <- estimates[[target_component]] <= boundary_tolerance
  relative_scale <- if (!boundary && is.finite(local_scale) &&
                        abs(target_theta) > sqrt(.Machine$double.eps)) {
    local_scale / abs(target_theta)
  } else NA_real_
  data.frame(
    CoordinateSpace = "lme4_profiled_relative_standard_deviation",
    CoordinateEstimate = target_theta,
    TargetVarianceEstimate = unname(estimates[[target_component]]),
    CoordinateVarianceMapExact = map_exact,
    LocalQuadraticScale = local_scale,
    LocalRelativeScale = relative_scale,
    LocalRelativeScaleMeaning =
      "profiled_relative_sd_scale_ratio_not_component_standard_error",
    HessianPositiveDefinite = pd,
    TargetBoundaryToleranceReached = boundary,
    LocalDiagnosticAvailable = map_exact && is.finite(local_scale),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwd_glmmtmb_coordinate <- function(
    fit, spec, target_component = "Rater", boundary_tolerance = 1e-8) {
  # Pass the fitted top-level parameter vector explicitly. A bare parList()
  # call can reflect a mutable TMB environment state after later evaluations.
  theta <- as.numeric(fit$obj$env$parList(fit$fit$par)$theta)
  ids <- spec$EffectMap$ComponentId[!is.na(spec$EffectMap$FormulaTerm)]
  if (length(theta) != length(ids)) {
    stop("glmmTMB theta length does not match the typed random-component map.",
         call. = FALSE)
  }
  index <- match(target_component, ids)
  if (is.na(index)) stop("Target glmmTMB theta coordinate is absent.",
                         call. = FALSE)
  estimates <- mfrmr_gtm_components(fit, spec)
  coordinate_variance <- stats::setNames(exp(2 * theta), ids)
  expected <- estimates[ids]
  tolerance <- 1e-8 * pmax(1, abs(expected))
  map_exact <- all(is.finite(coordinate_variance)) &&
    all(abs(coordinate_variance - expected) <= tolerance)
  covariance <- fit$sdr$cov.fixed
  theta_positions <- if (is.matrix(covariance)) {
    which(rownames(covariance) == "theta")
  } else integer()
  covariance_exact <- length(theta_positions) == length(theta) &&
    is.matrix(covariance) && all(is.finite(covariance))
  local_scale <- if (covariance_exact &&
                     covariance[theta_positions[[index]],
                                theta_positions[[index]]] >= 0) {
    sqrt(covariance[theta_positions[[index]], theta_positions[[index]]])
  } else NA_real_
  pd <- covariance_exact && all(eigen(
    (covariance + t(covariance)) / 2, symmetric = TRUE,
    only.values = TRUE
  )$values > 0)
  boundary <- estimates[[target_component]] <= boundary_tolerance
  data.frame(
    CoordinateSpace = "glmmTMB_joint_log_standard_deviation",
    CoordinateEstimate = theta[[index]],
    TargetVarianceEstimate = unname(estimates[[target_component]]),
    CoordinateVarianceMapExact = map_exact,
    LocalQuadraticScale = local_scale,
    LocalRelativeScale = if (is.finite(local_scale)) 2 * local_scale else NA_real_,
    LocalRelativeScaleMeaning =
      "first_order_delta_relative_variance_scale_not_boundary_wald_se",
    HessianPositiveDefinite = pd,
    TargetBoundaryToleranceReached = boundary,
    LocalDiagnosticAvailable = map_exact && covariance_exact && pd &&
      is.finite(local_scale),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwd_lme4_zero <- function(fit, tolerance) {
  vc <- as.data.frame(lme4::VarCorr(fit))
  as.numeric(vc$vcov[is.na(vc$var2)]) <= tolerance
}

mfrmr_gtwd_glmmtmb_zero <- function(fit, tolerance) {
  conditional <- glmmTMB::VarCorr(fit)$cond
  values <- c(vapply(conditional, function(x) as.numeric(x[1L, 1L]),
                     numeric(1L)), Residual = as.numeric(stats::sigma(fit))^2)
  values <= tolerance
}

mfrmr_gtwd_diagnostic_pair <- function(
    generation, prefit, method_id, target_component = "Rater",
    boundary_tolerance = 1e-8, singular_tolerance = 1e-4,
    negative_likelihood_tolerance = 1e-6) {
  if (!inherits(generation, "mfrmr_gtd2_generation") ||
      !inherits(prefit, "mfrmr_gtd3_prefit") || !prefit$PreFitEligible) {
    stop("Diagnostic refits require one eligible generated/prefit unit.",
         call. = FALSE)
  }
  method_id <- as.character(method_id)
  if (length(method_id) != 1L ||
      !method_id %in% c("lme4_ml", "lme4_reml", "glmmTMB_ml", "glmmTMB_reml")) {
    stop("Unknown Draft.83d2b2b1a method.", call. = FALSE)
  }
  backend <- if (grepl("^lme4_", method_id)) "lme4" else "glmmTMB"
  reml <- grepl("_reml$", method_id)
  likelihood_identity <- if (reml) "REML" else "ML"
  full_formula <- stats::as.formula(generation$Spec$FormulaCanonical)
  reduced_formula <- mfrmr_gtwd_reduced_formula(
    generation$Spec, target_component
  )
  data <- prefit$StructuralRankAudit$PreparedData$Data
  if (backend == "lme4") {
    control <- lme4::lmerControl()
    full <- mfrmr_gtwd_capture(lme4::lmer(
      full_formula, data = data, REML = reml, control = control
    ))
    reduced <- mfrmr_gtwd_capture(lme4::lmer(
      reduced_formula, data = data, REML = reml, control = control
    ))
    full_zero <- mfrmr_gtwd_lme4_zero(full$Fit, boundary_tolerance)
    reduced_zero <- mfrmr_gtwd_lme4_zero(reduced$Fit, boundary_tolerance)
    full_diagnostics <- mfrmr_gtc_lme4_diagnostics(
      full$Fit, full$Warnings, full$Messages, full_zero, singular_tolerance
    )
    reduced_diagnostics <- mfrmr_gtc_lme4_diagnostics(
      reduced$Fit, reduced$Warnings, reduced$Messages, reduced_zero,
      singular_tolerance
    )
    coordinate <- mfrmr_gtwd_lme4_coordinate(
      full$Fit, generation$Spec, target_component, boundary_tolerance
    )
    full_optimizer_ok <- full_diagnostics$OptimizerCode == 0L &&
      full_diagnostics$FitStatus != "optimizer_warning"
    reduced_optimizer_ok <- reduced_diagnostics$OptimizerCode == 0L &&
      reduced_diagnostics$FitStatus != "optimizer_warning"
    full_singular <- full_diagnostics$Singular
    reduced_singular <- reduced_diagnostics$Singular
    full_pd <- is.finite(full_diagnostics$MinimumHessianEigenvalue) &&
      full_diagnostics$MinimumHessianEigenvalue > 0
    reduced_pd <- is.finite(reduced_diagnostics$MinimumHessianEigenvalue) &&
      reduced_diagnostics$MinimumHessianEigenvalue > 0
  } else {
    family <- stats::gaussian(link = "identity")
    control <- glmmTMB::glmmTMBControl()
    full <- mfrmr_gtwd_capture(glmmTMB::glmmTMB(
      formula = full_formula, data = data, family = family,
      ziformula = ~ 0, dispformula = ~ 1, REML = reml, control = control
    ))
    reduced <- mfrmr_gtwd_capture(glmmTMB::glmmTMB(
      formula = reduced_formula, data = data, family = family,
      ziformula = ~ 0, dispformula = ~ 1, REML = reml, control = control
    ))
    full_zero <- mfrmr_gtwd_glmmtmb_zero(full$Fit, boundary_tolerance)
    reduced_zero <- mfrmr_gtwd_glmmtmb_zero(reduced$Fit, boundary_tolerance)
    full_diagnostics <- mfrmr_gtm_diagnostics(
      full$Fit, full$Warnings, full$Messages, full_zero
    )
    reduced_diagnostics <- mfrmr_gtm_diagnostics(
      reduced$Fit, reduced$Warnings, reduced$Messages, reduced_zero
    )
    coordinate <- mfrmr_gtwd_glmmtmb_coordinate(
      full$Fit, generation$Spec, target_component, boundary_tolerance
    )
    full_optimizer_ok <- full_diagnostics$OptimizerCode == 0L &&
      isTRUE(full_diagnostics$PositiveDefiniteHessian)
    reduced_optimizer_ok <- reduced_diagnostics$OptimizerCode == 0L &&
      isTRUE(reduced_diagnostics$PositiveDefiniteHessian)
    full_singular <- NA
    reduced_singular <- NA
    full_pd <- full_diagnostics$PositiveDefiniteHessian
    reduced_pd <- reduced_diagnostics$PositiveDefiniteHessian
  }
  full_likelihood <- stats::logLik(full$Fit)
  reduced_likelihood <- stats::logLik(reduced$Fit)
  full_value <- as.numeric(full_likelihood)
  reduced_value <- as.numeric(reduced_likelihood)
  drop <- 2 * (full_value - reduced_value)
  nobs_full <- as.integer(stats::nobs(full$Fit))
  nobs_reduced <- as.integer(stats::nobs(reduced$Fit))
  df_full <- as.integer(attr(full_likelihood, "df"))
  df_reduced <- as.integer(attr(reduced_likelihood, "df"))
  same_rows <- identical(nobs_full, nobs_reduced) &&
    identical(nobs_full, nrow(data))
  df_difference <- df_full - df_reduced
  likelihood_available <- all(is.finite(c(full_value, reduced_value, drop))) &&
    same_rows && identical(df_difference, 1L) &&
    isTRUE(full_optimizer_ok) && isTRUE(reduced_optimizer_ok)
  negative_ok <- is.finite(drop) && drop >= -negative_likelihood_tolerance
  comparison_state <- if (!likelihood_available) {
    "not_evaluable_fit_or_identity_failure"
  } else if (!negative_ok) {
    "invalid_materially_negative_nested_drop"
  } else if (drop < 0) {
    "available_small_negative_numerical_drop_retained"
  } else {
    "available_raw_boundary_diagnostic"
  }
  full_formula_text <- paste(deparse(full_formula, width.cutoff = 500L),
                             collapse = " ")
  reduced_formula_text <- paste(deparse(reduced_formula, width.cutoff = 500L),
                                collapse = " ")
  payload <- list(
    Contract = "gtheory_weak_information_diagnostic_pair_draft83d2b2b1a_v1",
    ScenarioId = generation$ScenarioId, Replicate = generation$Replicate,
    GeneratorHash = generation$GeneratorHash, PreFitHash = prefit$ResultHash,
    MethodId = method_id, Backend = backend,
    LikelihoodIdentity = likelihood_identity,
    TargetComponent = target_component,
    FullFormulaCanonical = full_formula_text,
    ReducedFormulaCanonical = reduced_formula_text,
    RetainedDataHash = prefit$StructuralRankAudit$PreparedData$RetainedDataHash,
    FullLogLikelihood = full_value, ReducedLogLikelihood = reduced_value,
    RawLikelihoodDrop = drop, LikelihoodDfDifference = df_difference,
    SameRows = same_rows, LikelihoodDiagnosticAvailable = likelihood_available,
    NegativeDropWithinTolerance = negative_ok,
    ComparisonState = comparison_state,
    FullOptimizerPassed = isTRUE(full_optimizer_ok),
    ReducedOptimizerPassed = isTRUE(reduced_optimizer_ok),
    FullHessianPositiveDefinite = isTRUE(full_pd),
    ReducedHessianPositiveDefinite = isTRUE(reduced_pd),
    FullSingular = full_singular, ReducedSingular = reduced_singular,
    FullBoundaryComponentCount = sum(full_zero),
    ReducedBoundaryComponentCount = sum(reduced_zero),
    CoordinateDiagnostic = coordinate,
    ReferenceDistribution = "none_assigned_multi_component_boundary",
    PValue = NA_real_, Interval = "none"
  )
  structure(c(payload, list(
    ResultHash = mfrmr_gta_hash(payload), FullFit = full$Fit,
    ReducedFit = reduced$Fit, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtwd_pair")
}

mfrmr_gtwd_failure_row <- function(manifest_row, message) {
  data.frame(
    manifest_row[c(
      "ScenarioId", "Replicate", "DatasetId", "MethodId", "Backend",
      "DesignId", "VarianceId", "TargetVariance", "TruthRegion",
      "EvaluationRole", "Likelihood"
    )],
    PairReturned = FALSE, PairResultHash = "none",
    FullOptimizerPassed = FALSE, ReducedOptimizerPassed = FALSE,
    FullHessianPositiveDefinite = FALSE,
    ReducedHessianPositiveDefinite = FALSE,
    FullSingular = NA, ReducedSingular = NA,
    FullBoundaryComponentCount = NA_integer_,
    ReducedBoundaryComponentCount = NA_integer_,
    SameRows = FALSE, LikelihoodDfDifference = NA_integer_,
    FullLogLikelihood = NA_real_, ReducedLogLikelihood = NA_real_,
    RawLikelihoodDrop = NA_real_, NegativeDropWithinTolerance = FALSE,
    LikelihoodDiagnosticAvailable = FALSE,
    ComparisonState = "not_evaluable_refit_error",
    CoordinateSpace = "unavailable", CoordinateEstimate = NA_real_,
    TargetVarianceEstimate = NA_real_, CoordinateVarianceMapExact = FALSE,
    LocalQuadraticScale = NA_real_, LocalRelativeScale = NA_real_,
    LocalRelativeScaleMeaning = "unavailable",
    TargetBoundaryToleranceReached = NA,
    LocalDiagnosticAvailable = FALSE,
    FailureMessageDigest = mfrmr_gta_hash(message),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwd_pair_row <- function(manifest_row, pair) {
  coordinate <- pair$CoordinateDiagnostic
  data.frame(
    manifest_row[c(
      "ScenarioId", "Replicate", "DatasetId", "MethodId", "Backend",
      "DesignId", "VarianceId", "TargetVariance", "TruthRegion",
      "EvaluationRole", "Likelihood"
    )],
    PairReturned = TRUE, PairResultHash = pair$ResultHash,
    FullOptimizerPassed = pair$FullOptimizerPassed,
    ReducedOptimizerPassed = pair$ReducedOptimizerPassed,
    FullHessianPositiveDefinite = pair$FullHessianPositiveDefinite,
    ReducedHessianPositiveDefinite = pair$ReducedHessianPositiveDefinite,
    FullSingular = pair$FullSingular, ReducedSingular = pair$ReducedSingular,
    FullBoundaryComponentCount = pair$FullBoundaryComponentCount,
    ReducedBoundaryComponentCount = pair$ReducedBoundaryComponentCount,
    SameRows = pair$SameRows,
    LikelihoodDfDifference = pair$LikelihoodDfDifference,
    FullLogLikelihood = pair$FullLogLikelihood,
    ReducedLogLikelihood = pair$ReducedLogLikelihood,
    RawLikelihoodDrop = pair$RawLikelihoodDrop,
    NegativeDropWithinTolerance = pair$NegativeDropWithinTolerance,
    LikelihoodDiagnosticAvailable = pair$LikelihoodDiagnosticAvailable,
    ComparisonState = pair$ComparisonState,
    CoordinateSpace = coordinate$CoordinateSpace,
    CoordinateEstimate = coordinate$CoordinateEstimate,
    TargetVarianceEstimate = coordinate$TargetVarianceEstimate,
    CoordinateVarianceMapExact = coordinate$CoordinateVarianceMapExact,
    LocalQuadraticScale = coordinate$LocalQuadraticScale,
    LocalRelativeScale = coordinate$LocalRelativeScale,
    LocalRelativeScaleMeaning = coordinate$LocalRelativeScaleMeaning,
    TargetBoundaryToleranceReached =
      coordinate$TargetBoundaryToleranceReached,
    LocalDiagnosticAvailable = coordinate$LocalDiagnosticAvailable,
    FailureMessageDigest = "none", stringsAsFactors = FALSE
  )
}

mfrmr_gtwd_execute_schema <- function(
    contract = mfrmr_gtwd_inference_contract(), progress = interactive()) {
  if (!inherits(contract, "mfrmr_gtwd_contract") ||
      !isTRUE(contract$SchemaRefitAuthorized)) {
    stop("Draft.83d2b2b1a schema refit is not authorized.", call. = FALSE)
  }
  historical_plan <- mfrmr_gtwp_plan()
  if (!identical(contract$HistoricalPilotPlanHash, historical_plan$PlanHash)) {
    stop("Inference and historical pilot identities differ.", call. = FALSE)
  }
  manifest <- mfrmr_gtwp_manifest(historical_plan, "schema_smoke")
  rows <- manifest$Rows
  outputs <- vector("list", nrow(rows))
  pairs <- vector("list", nrow(rows))
  unit_cache <- list()
  for (index in seq_len(nrow(rows))) {
    dataset_id <- rows$DatasetId[[index]]
    if (is.null(unit_cache[[dataset_id]])) {
      generation <- mfrmr_gtw_generate(
        historical_plan$CalibrationRegistry, rows$ScenarioId[[index]],
        rows$Replicate[[index]]
      )
      unit_cache[[dataset_id]] <- list(
        Generation = generation,
        PreFit = mfrmr_gtd3_prefit_one(generation)
      )
    }
    unit <- unit_cache[[dataset_id]]
    if (isTRUE(progress)) {
      message(sprintf("[%d/%d] %s / %s", index, nrow(rows), dataset_id,
                      rows$MethodId[[index]]))
    }
    result <- tryCatch(
      mfrmr_gtwd_diagnostic_pair(
        unit$Generation, unit$PreFit, rows$MethodId[[index]],
        target_component = contract$TargetComponent
      ),
      error = function(error) error
    )
    if (inherits(result, "error")) {
      outputs[[index]] <- mfrmr_gtwd_failure_row(
        rows[index, , drop = FALSE], conditionMessage(result)
      )
      pairs[[index]] <- NULL
    } else {
      outputs[[index]] <- mfrmr_gtwd_pair_row(
        rows[index, , drop = FALSE], result
      )
      pairs[[index]] <- result
    }
  }
  diagnostic_rows <- do.call(rbind, outputs)
  row.names(diagnostic_rows) <- NULL
  identity <- list(
    Contract = "gtheory_weak_information_schema_refit_draft83d2b2b1a_v1",
    InferenceContractHash = contract$ContractHash,
    HistoricalSchemaManifestHash = manifest$ManifestHash,
    FunctionHashes = mfrmr_gtwd_function_hashes(),
    DiagnosticRows = diagnostic_rows
  )
  structure(c(identity, list(
    ExecutionHash = mfrmr_gta_hash(identity), PairDetails = pairs,
    PlannedUnits = nrow(rows), PairReturnCount = sum(diagnostic_rows$PairReturned),
    LikelihoodAvailableCount = sum(
      diagnostic_rows$LikelihoodDiagnosticAvailable
    ),
    LocalDiagnosticAvailableCount = sum(
      diagnostic_rows$LocalDiagnosticAvailable
    ),
    MaterialNegativeDropCount = sum(
      diagnostic_rows$PairReturned &
        !diagnostic_rows$NegativeDropWithinTolerance
    ),
    ExactAccountingPassed = nrow(diagnostic_rows) == nrow(rows),
    SchemaEvidenceReady = nrow(diagnostic_rows) == nrow(rows),
    FeasibilityEvidenceReady = FALSE, CalibrationEvidenceReady = FALSE,
    ThresholdFrozen = FALSE, ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwd_schema_execution")
}
