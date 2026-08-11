# Draft.83c2 matched Gaussian glmmTMB and lme4 G-theory parity prototype.
#
# Repository-internal only. Source Draft.81, Draft.83a, and Draft.83c1 first.
# This file compares point estimators only inside an exact retained-row/model
# overlap. It computes no interval or D-study coefficient and never marks a
# result decision-ready.

mfrmr_gtm_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gta_component_id",
    "mfrmr_gtc_validate_tolerance", "mfrmr_gtc_function_hash",
    "mfrmr_gtc_covariance_design", "mfrmr_gtc_information"
  )
  prototype_environment <- environment(mfrmr_gtm_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = prototype_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.81, Draft.83a, and Draft.83c1 before Draft.83c2: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtm_control_identity <- function(control) {
  list(
    Optimizer = "stats::nlminb_default",
    OptimizerFunctionHash = mfrmr_gtc_function_hash(control$optimizer),
    OptimizerControlHash = mfrmr_gta_hash(control$optCtrl),
    OptimizerArgumentsHash = mfrmr_gta_hash(control$optArgs),
    Profile = isTRUE(control$profile),
    Collect = isTRUE(control$collect),
    ParallelHash = mfrmr_gta_hash(control$parallel),
    EigenvalueCheck = isTRUE(control$eigval_check),
    ZeroDispersionLogValue = as.numeric(control$zerodisp_val),
    StartMethodHash = mfrmr_gta_hash(control$start_method),
    RankCheck = as.character(control$rank_check),
    ConvergenceCheck = as.character(control$conv_check),
    FullCorrelation = isTRUE(control$full_cor)
  )
}

mfrmr_gtm_backend_function_hashes <- function() {
  c(
    glmmTMB = mfrmr_gtc_function_hash(glmmTMB::glmmTMB),
    VarCorrGlmmTMB = mfrmr_gtc_function_hash(
      getFromNamespace("VarCorr.glmmTMB", "glmmTMB")
    ),
    sigmaGlmmTMB = mfrmr_gtc_function_hash(
      getFromNamespace("sigma.glmmTMB", "glmmTMB")
    ),
    fixefGlmmTMB = mfrmr_gtc_function_hash(
      getFromNamespace("fixef.glmmTMB", "glmmTMB")
    ),
    logLikGlmmTMB = mfrmr_gtc_function_hash(
      getFromNamespace("logLik.glmmTMB", "glmmTMB")
    ),
    glmmTMBControl = mfrmr_gtc_function_hash(glmmTMB::glmmTMBControl)
  )
}

mfrmr_gtm_components <- function(fit, spec) {
  variance <- glmmTMB::VarCorr(fit)
  if (length(variance$zi) > 0L || length(variance$disp) > 0L) {
    stop("The matched Draft.83c2 overlap excludes zi/disp random effects.",
         call. = FALSE)
  }
  conditional <- variance$cond
  if (length(conditional) == 0L) {
    stop("glmmTMB returned no conditional random-effect components.",
         call. = FALSE)
  }
  if (any(vapply(conditional, function(x) !identical(dim(x), c(1L, 1L)),
                 logical(1L)))) {
    stop("Draft.83c2 accepts random-intercept scalar blocks only.",
         call. = FALSE)
  }
  declared <- c(spec$ObjectFacet, spec$RandomFacets, spec$FixedFacets)
  component_id <- vapply(names(conditional), function(group) {
    mfrmr_gta_component_id(
      strsplit(group, ":", fixed = TRUE)[[1L]], declared
    )
  }, character(1L))
  if (anyDuplicated(component_id)) {
    stop("glmmTMB returned duplicate semantic variance components.",
         call. = FALSE)
  }
  estimate <- stats::setNames(vapply(
    conditional, function(x) as.numeric(x[1L, 1L]), numeric(1L)
  ), component_id)
  residual <- as.numeric(stats::sigma(fit))^2
  estimate <- c(estimate, Residual = residual)
  required_ids <- spec$EffectMap$ComponentId
  if (!setequal(names(estimate), required_ids)) {
    stop(
      "glmmTMB variance-component identities do not match the typed map.",
      call. = FALSE
    )
  }
  estimate[required_ids]
}

mfrmr_gtm_hessian_minimum <- function(fit) {
  covariance <- fit$sdr$cov.fixed
  if (!is.matrix(covariance) || nrow(covariance) == 0L ||
      !all(is.finite(covariance))) return(NA_real_)
  values <- eigen(
    (covariance + t(covariance)) / 2,
    symmetric = TRUE, only.values = TRUE
  )$values
  if (any(values <= 0)) return(NA_real_)
  1 / max(values)
}

mfrmr_gtm_diagnostics <- function(fit, warnings, messages,
                                   zero_components) {
  convergence <- suppressWarnings(as.integer(fit$fit$convergence[[1L]]))
  if (length(convergence) == 0L || is.na(convergence)) convergence <- NA_integer_
  optimizer_message <- as.character(fit$fit$message)
  if (length(optimizer_message) == 0L) optimizer_message <- ""
  objective <- suppressWarnings(as.numeric(fit$fit$objective[[1L]]))
  gradient <- suppressWarnings(as.numeric(fit$sdr$gradient.fixed))
  maximum_gradient <- if (length(gradient) > 0L && all(is.finite(gradient))) {
    max(abs(gradient))
  } else NA_real_
  pd_hessian <- fit$sdr$pdHess
  if (length(pd_hessian) != 1L || is.na(pd_hessian)) pd_hessian <- NA
  optimizer_ok <- !is.na(convergence) && convergence == 0L &&
    is.finite(objective)
  status <- if (!optimizer_ok) {
    "optimizer_warning"
  } else if (!isTRUE(pd_hessian)) {
    "nonpositive_or_unavailable_hessian"
  } else if (any(zero_components)) {
    "boundary_tolerance_reached"
  } else {
    "identified"
  }
  data.frame(
    FitStatus = status,
    OptimizerCode = convergence,
    OptimizerMessage = optimizer_message[[1L]],
    Objective = objective,
    PositiveDefiniteHessian = pd_hessian,
    MaximumAbsoluteFixedGradient = maximum_gradient,
    MinimumApproximateFixedHessianEigenvalue =
      mfrmr_gtm_hessian_minimum(fit),
    BoundaryComponentCount = sum(zero_components),
    WarningCount = length(warnings),
    MessageCount = length(messages),
    Warnings = paste(warnings, collapse = " | "),
    Messages = paste(messages, collapse = " | "),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtm_fit <- function(
    spec, data, incidence_audit,
    missingness = incidence_audit$MissingnessMechanism,
    reml = TRUE, rank_tolerance = 1e-9,
    boundary_tolerance = 1e-8, max_matrix_cells = 5e6) {
  mfrmr_gtm_require_primitives()
  if (!requireNamespace("glmmTMB", quietly = TRUE)) {
    stop("Draft.83c2 requires the suggested `glmmTMB` package.",
         call. = FALSE)
  }
  boundary_tolerance <- mfrmr_gtc_validate_tolerance(
    boundary_tolerance, "`boundary_tolerance`", positive = FALSE
  )
  covariance_design <- mfrmr_gtc_covariance_design(
    spec, data, incidence_audit, missingness = missingness,
    rank_tolerance = rank_tolerance,
    max_matrix_cells = max_matrix_cells
  )
  if (!identical(covariance_design$CapacityStatus, "evaluated")) {
    stop(
      "glmmTMB fitting is blocked because the covariance audit hit capacity.",
      call. = FALSE
    )
  }
  prepared <- covariance_design$PreparedData
  formula <- stats::as.formula(spec$FormulaCanonical)
  family <- stats::gaussian(link = "identity")
  control <- glmmTMB::glmmTMBControl()
  warnings <- character()
  messages <- character()
  fit <- tryCatch(
    withCallingHandlers(
      glmmTMB::glmmTMB(
        formula = formula,
        data = prepared$Data,
        family = family,
        ziformula = ~ 0,
        dispformula = ~ 1,
        REML = isTRUE(reml),
        control = control
      ),
      warning = function(warning) {
        warnings <<- c(warnings, conditionMessage(warning))
        invokeRestart("muffleWarning")
      },
      message = function(message) {
        messages <<- c(messages, conditionMessage(message))
        invokeRestart("muffleMessage")
      }
    ),
    error = function(error) error
  )
  if (inherits(fit, "error")) {
    stop("glmmTMB::glmmTMB failed: ", conditionMessage(fit),
         call. = FALSE)
  }
  estimate <- mfrmr_gtm_components(fit, spec)
  zero_components <- estimate <= boundary_tolerance
  components <- merge(
    spec$EffectMap,
    covariance_design$ComponentAudit[
      c("ComponentId", "GroupingLevels", "StructuralStatus")
    ],
    by = "ComponentId", sort = FALSE
  )
  required_ids <- spec$EffectMap$ComponentId
  components <- components[
    match(required_ids, components$ComponentId), , drop = FALSE
  ]
  components$Estimate <- as.numeric(estimate)
  components$EstimatorFamily <- if (isTRUE(reml)) {
    "glmmTMB_reml"
  } else {
    "glmmTMB_ml"
  }
  components$ConstraintIdentity <- "log_sd_nonnegative_variance"
  components$BoundaryState <- ifelse(
    zero_components,
    "near_zero_at_declared_backend_tolerance",
    "interior_at_declared_backend_tolerance"
  )
  components$InferenceStatus <- "point_only_no_interval"
  row.names(components) <- NULL
  diagnostics <- mfrmr_gtm_diagnostics(
    fit, warnings, messages, zero_components
  )
  information <- mfrmr_gtc_information(
    covariance_design, estimate,
    rank_tolerance = rank_tolerance,
    boundary_tolerance = boundary_tolerance
  )
  selected_method <- if (isTRUE(reml)) "REML" else "ML"
  selected_information <- information$InformationSummary[
    information$InformationSummary$Method == selected_method, , drop = FALSE
  ]
  fit_qualification <- if (!incidence_audit$IncidenceScreenPassed) {
    "incidence_screen_failed"
  } else if (!covariance_design$StructuralRankFull) {
    "structural_covariance_confounding"
  } else if (!selected_information$InformationRankFull) {
    paste0(tolower(selected_method), "_information_rank_deficient")
  } else if (!information$RegularInterior) {
    "boundary_nonregular"
  } else if (!identical(diagnostics$FitStatus, "identified")) {
    paste0("glmmTMB_", diagnostics$FitStatus)
  } else {
    "point_estimation_gate_passed"
  }
  estimator_identity <- list(
    Family = if (isTRUE(reml)) "glmmTMB_reml" else "glmmTMB_ml",
    Backend = "glmmTMB",
    BackendVersion = as.character(utils::packageVersion("glmmTMB")),
    TMBVersion = as.character(utils::packageVersion("TMB")),
    Method = selected_method,
    Constraints = "random_effect_log_sd_and_log_dispersion",
    FormulaCanonical = paste(
      deparse(formula, width.cutoff = 500L), collapse = " "
    ),
    Response = "Gaussian_observed_score",
    FamilyName = family$family,
    Link = family$link,
    ZeroInflationFormula = "~0",
    DispersionFormula = "~1",
    RowContract = "draft83a_retained_rows_exact",
    RandomEffects = "independent_exchangeable_random_intercepts",
    FixedEffects = "intercept_only",
    Control = mfrmr_gtm_control_identity(control),
    BackendFunctionHashes = mfrmr_gtm_backend_function_hashes(),
    BoundaryTolerance = boundary_tolerance,
    Interval = "none"
  )
  likelihood <- stats::logLik(fit)
  likelihood_identity <- list(
    Value = as.numeric(likelihood),
    DegreesFreedom = as.integer(attr(likelihood, "df")),
    Observations = as.integer(stats::nobs(fit)),
    Criterion = selected_method,
    ConstantContract = "backend_reported_full_Gaussian_logLik"
  )
  payload <- list(
    Contract = "gtheory_glmmtmb_fit_draft83c2_v1",
    DesignHash = spec$DesignHash,
    IncidenceAuditHash = incidence_audit$AuditHash,
    RetainedDataHash = prepared$RetainedDataHash,
    CovarianceDesignHash = covariance_design$ResultHash,
    ExpectedInformationHash = information$ResultHash,
    EstimatorIdentity = estimator_identity,
    LikelihoodIdentity = likelihood_identity,
    Components = components,
    FitDiagnostics = diagnostics,
    SelectedInformation = selected_information,
    FitQualification = fit_qualification
  )
  structure(c(payload, list(
    ResultHash = mfrmr_gta_hash(payload),
    Spec = spec,
    PreparedData = prepared,
    BackendFit = fit,
    CovarianceDesign = covariance_design,
    ExpectedInformation = information,
    PointEstimateAvailable = TRUE,
    EstimationGatePassed = identical(
      fit_qualification, "point_estimation_gate_passed"
    ),
    InferenceReady = FALSE,
    CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtm_fit")
}

mfrmr_gtm_compare <- function(
    lme4_fit, glmmtmb_fit,
    absolute_tolerance = 5e-5,
    relative_tolerance = 5e-5,
    loglik_tolerance = 1e-6,
    intercept_tolerance = 1e-5) {
  mfrmr_gtm_require_primitives()
  if (!inherits(lme4_fit, "mfrmr_gtc_lme4_fit")) {
    stop("`lme4_fit` must be a Draft.83c1 lme4 fit.", call. = FALSE)
  }
  if (!inherits(glmmtmb_fit, "mfrmr_gtm_fit")) {
    stop("`glmmtmb_fit` must be a Draft.83c2 glmmTMB fit.", call. = FALSE)
  }
  tolerances <- c(
    Absolute = mfrmr_gtc_validate_tolerance(
      absolute_tolerance, "`absolute_tolerance`", positive = FALSE
    ),
    Relative = mfrmr_gtc_validate_tolerance(
      relative_tolerance, "`relative_tolerance`", positive = FALSE
    ),
    LogLik = mfrmr_gtc_validate_tolerance(
      loglik_tolerance, "`loglik_tolerance`", positive = FALSE
    ),
    Intercept = mfrmr_gtc_validate_tolerance(
      intercept_tolerance, "`intercept_tolerance`", positive = FALSE
    )
  )
  identity_fields <- c(
    "DesignHash", "IncidenceAuditHash", "RetainedDataHash",
    "CovarianceDesignHash"
  )
  identity_match <- vapply(identity_fields, function(field) {
    identical(lme4_fit[[field]], glmmtmb_fit[[field]])
  }, logical(1L))
  if (!all(identity_match)) {
    stop(
      "The backend fits do not share an exact design/audit/retained-row/",
      "covariance identity.", call. = FALSE
    )
  }
  model_contract_match <- identical(
    lme4_fit$EstimatorIdentity$Method,
    glmmtmb_fit$EstimatorIdentity$Method
  ) && identical(
    lme4_fit$EstimatorIdentity$FormulaCanonical,
    glmmtmb_fit$EstimatorIdentity$FormulaCanonical
  ) && identical(
    lme4_fit$EstimatorIdentity$Response,
    glmmtmb_fit$EstimatorIdentity$Response
  ) && identical(
    lme4_fit$EstimatorIdentity$RandomEffects,
    glmmtmb_fit$EstimatorIdentity$RandomEffects
  ) && identical(
    lme4_fit$EstimatorIdentity$FixedEffects,
    glmmtmb_fit$EstimatorIdentity$FixedEffects
  ) && identical(glmmtmb_fit$EstimatorIdentity$FamilyName, "gaussian") &&
    identical(glmmtmb_fit$EstimatorIdentity$Link, "identity") &&
    identical(glmmtmb_fit$EstimatorIdentity$ZeroInflationFormula, "~0") &&
    identical(glmmtmb_fit$EstimatorIdentity$DispersionFormula, "~1")
  if (!model_contract_match) {
    stop("The backend fits do not share the matched Gaussian model contract.",
         call. = FALSE)
  }
  component_ids <- lme4_fit$Components$ComponentId
  if (!identical(component_ids, glmmtmb_fit$Components$ComponentId)) {
    stop("Backend semantic component order does not match.", call. = FALSE)
  }
  lme4_estimate <- lme4_fit$Components$Estimate
  glmmtmb_estimate <- glmmtmb_fit$Components$Estimate
  absolute_difference <- abs(lme4_estimate - glmmtmb_estimate)
  scale <- pmax(abs(lme4_estimate), abs(glmmtmb_estimate),
                .Machine$double.eps)
  relative_difference <- absolute_difference / scale
  within <- absolute_difference <=
    tolerances[["Absolute"]] + tolerances[["Relative"]] * scale
  component_comparison <- data.frame(
    ComponentId = component_ids,
    Lme4Estimate = lme4_estimate,
    GlmmTMBEstimate = glmmtmb_estimate,
    AbsoluteDifference = absolute_difference,
    RelativeDifference = relative_difference,
    WithinTolerance = within,
    Lme4BoundaryState = lme4_fit$Components$BoundaryState,
    GlmmTMBBoundaryState = glmmtmb_fit$Components$BoundaryState,
    stringsAsFactors = FALSE
  )
  lme4_likelihood <- stats::logLik(lme4_fit$BackendFit)
  glmmtmb_likelihood <- stats::logLik(glmmtmb_fit$BackendFit)
  likelihood_comparison <- data.frame(
    Criterion = lme4_fit$EstimatorIdentity$Method,
    Lme4LogLik = as.numeric(lme4_likelihood),
    GlmmTMBLogLik = as.numeric(glmmtmb_likelihood),
    AbsoluteDifference = abs(
      as.numeric(lme4_likelihood) - as.numeric(glmmtmb_likelihood)
    ),
    DegreesFreedomMatch = identical(
      as.integer(attr(lme4_likelihood, "df")),
      as.integer(attr(glmmtmb_likelihood, "df"))
    ),
    ObservationsMatch = identical(
      as.integer(stats::nobs(lme4_fit$BackendFit)),
      as.integer(stats::nobs(glmmtmb_fit$BackendFit))
    ),
    stringsAsFactors = FALSE
  )
  likelihood_comparison$WithinTolerance <-
    likelihood_comparison$AbsoluteDifference <= tolerances[["LogLik"]] &&
    likelihood_comparison$DegreesFreedomMatch &&
    likelihood_comparison$ObservationsMatch
  lme4_intercept <- as.numeric(lme4::fixef(
    lme4_fit$BackendFit
  )[["(Intercept)"]])
  glmmtmb_intercept <- as.numeric(glmmTMB::fixef(
    glmmtmb_fit$BackendFit
  )$cond[["(Intercept)"]])
  intercept_comparison <- data.frame(
    Lme4Intercept = lme4_intercept,
    GlmmTMBIntercept = glmmtmb_intercept,
    AbsoluteDifference = abs(lme4_intercept - glmmtmb_intercept),
    WithinTolerance = abs(lme4_intercept - glmmtmb_intercept) <=
      tolerances[["Intercept"]],
    stringsAsFactors = FALSE
  )
  numerical_parity <- all(component_comparison$WithinTolerance) &&
    likelihood_comparison$WithinTolerance &&
    intercept_comparison$WithinTolerance
  both_point_gates <- isTRUE(lme4_fit$EstimationGatePassed) &&
    isTRUE(glmmtmb_fit$EstimationGatePassed)
  boundary_state <- if (
    all(grepl("interior", component_comparison$Lme4BoundaryState)) &&
    all(grepl("interior", component_comparison$GlmmTMBBoundaryState))
  ) {
    "both_interior"
  } else if (
    any(grepl("zero|boundary", component_comparison$Lme4BoundaryState)) &&
    any(grepl("zero", component_comparison$GlmmTMBBoundaryState))
  ) {
    "both_detect_boundary_at_backend_tolerance"
  } else {
    "backend_boundary_classification_differs"
  }
  payload <- list(
    Contract = "gtheory_matched_backend_parity_draft83c2_v1",
    DesignHash = lme4_fit$DesignHash,
    IncidenceAuditHash = lme4_fit$IncidenceAuditHash,
    RetainedDataHash = lme4_fit$RetainedDataHash,
    CovarianceDesignHash = lme4_fit$CovarianceDesignHash,
    Method = lme4_fit$EstimatorIdentity$Method,
    Lme4FitHash = lme4_fit$ResultHash,
    GlmmTMBFitHash = glmmtmb_fit$ResultHash,
    Tolerances = tolerances,
    ComponentComparison = component_comparison,
    LikelihoodComparison = likelihood_comparison,
    InterceptComparison = intercept_comparison,
    BoundaryComparisonStatus = boundary_state,
    NumericalParityPassed = numerical_parity,
    BothPointEstimationGatesPassed = both_point_gates,
    MatchedOverlapPassed = numerical_parity && both_point_gates
  )
  structure(c(payload, list(
    ResultHash = mfrmr_gta_hash(payload),
    InferenceReady = FALSE,
    CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtm_parity")
}
