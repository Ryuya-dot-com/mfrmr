# Draft.83d2b2b1g9 lme4 objective-reference preflight.
#
# Repository-internal only. This file independently verifies the theta-only
# profiled ML deviance and REML criterion used by lmer. It does not execute
# the nonreserved method replay or authorize calibration.

mfrmr_gtwac_require_primitives <- function() {
  required <- c("mfrmr_gta_hash", "mfrmr_gtwab_function_hashes")
  preflight_environment <- environment(mfrmr_gtwac_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = preflight_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the b1g8 chain before the b1g9 lme4 preflight: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwac_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtwac_source_registry <- function() {
  data.frame(
    SourceId = c(
      "lme4_lmer_current", "lme4_lmer_vignette_current",
      "lme4_theory_current", "lme4_control_current",
      "lme4_profile_current", "lme4_singularity_current"
    ),
    Locator = c(
      "https://lme4.github.io/lme4/reference/lmer.html",
      "https://lme4.github.io/lme4/articles/lmer.pdf",
      "https://lme4.github.io/lme4/articles/Theory.pdf",
      "https://lme4.github.io/lme4/reference/lmerControl.html",
      "https://lme4.github.io/lme4/reference/profile-methods.html",
      "https://lme4.github.io/lme4/reference/isSingular.html"
    ),
    ContractRole = c(
      "REML argument and theta-only devFunOnly identity",
      "profiled ML deviance and REML criterion algebra",
      "Gaussian LMM likelihood factorization",
      "optimizer derivative and boundary controls",
      "likelihood-profile objective matching tolerances",
      "singular boundary is statistically defined but inferentially nonregular"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwac_fixture_data <- function() {
  rows <- expand.grid(
    Person = factor(seq_len(12L)), Rater = factor(seq_len(4L)),
    Replicate = seq_len(2L), KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = TRUE
  )
  person <- as.integer(rows$Person)
  rater <- as.integer(rows$Rater)
  rows$Score <- 0.4 + sin(0.7 * person) + 0.45 * cos(1.1 * rater) +
    0.15 * sin(0.3 * person * rater) + 0.05 * (rows$Replicate - 1)
  rows
}

mfrmr_gtwac_simple_intercept_structure <- function(fit) {
  if (!inherits(fit, "lmerMod")) {
    stop("One fitted lmer model is required.", call. = FALSE)
  }
  theta <- lme4::getME(fit, "theta")
  lower <- lme4::getME(fit, "lower")
  zt_list <- lme4::getME(fit, "Ztlist")
  conditional_names <- lme4::getME(fit, "cnms")
  weights <- stats::weights(fit)
  offset <- lme4::getME(fit, "offset")
  simple <- length(theta) == length(zt_list) &&
    length(lower) == length(theta) && all(lower == 0) &&
    length(conditional_names) == length(theta) &&
    all(lengths(conditional_names) == 1L) &&
    all(vapply(zt_list, function(value) {
      ncol(value) == length(lme4::getME(fit, "y"))
    }, logical(1L))) && length(weights) == length(lme4::getME(fit, "y")) &&
    all(is.finite(weights)) && all(weights == 1) &&
    length(offset) == length(lme4::getME(fit, "y")) &&
    all(is.finite(offset)) && all(offset == 0)
  list(
    SimpleIndependentRandomIntercepts = simple,
    Theta = theta, ThetaNames = names(theta), Lower = lower,
    ZtList = zt_list, ConditionalNames = conditional_names,
    PriorWeights = weights, Offset = offset
  )
}

mfrmr_gtwac_dense_oracle <- function(fit, theta,
                                       reml = lme4::isREML(fit)) {
  structure_audit <- mfrmr_gtwac_simple_intercept_structure(fit)
  if (!isTRUE(structure_audit$SimpleIndependentRandomIntercepts)) {
    stop(
      "The b1g9 dense oracle supports zero-offset unweighted independent ",
      "random ",
      "intercepts only.", call. = FALSE
    )
  }
  theta <- as.numeric(theta)
  if (length(theta) != length(structure_audit$Theta) ||
      any(!is.finite(theta)) || any(theta < 0)) {
    stop("One finite nonnegative theta vector is required.", call. = FALSE)
  }
  x <- as.matrix(lme4::getME(fit, "X"))
  y <- as.numeric(lme4::getME(fit, "y"))
  n <- length(y)
  p <- ncol(x)
  z_list <- lapply(
    structure_audit$ZtList,
    function(value) as.matrix(Matrix::t(value))
  )
  a <- diag(n)
  for (index in seq_along(theta)) {
    a <- a + theta[[index]]^2 * tcrossprod(z_list[[index]])
  }
  r <- tryCatch(chol(a), error = function(error) NULL)
  if (is.null(r)) {
    return(list(
      Available = FALSE, Objective = NA_real_, Gradient = rep(
        NA_real_, length(theta)
      ), Theta = theta
    ))
  }
  a_inverse <- chol2inv(r)
  b <- crossprod(x, a_inverse %*% x)
  b_inverse <- tryCatch(solve(b), error = function(error) NULL)
  if (is.null(b_inverse)) {
    return(list(
      Available = FALSE, Objective = NA_real_, Gradient = rep(
        NA_real_, length(theta)
      ), Theta = theta
    ))
  }
  beta <- b_inverse %*% crossprod(x, a_inverse %*% y)
  residual <- y - as.numeric(x %*% beta)
  q <- as.numeric(a_inverse %*% residual)
  rss <- sum(residual * q)
  log_determinant_a <- 2 * sum(log(diag(r)))
  p_matrix <- a_inverse -
    a_inverse %*% x %*% b_inverse %*% t(x) %*% a_inverse
  if (!is.finite(rss) || rss <= 0) {
    return(list(
      Available = FALSE, Objective = NA_real_, Gradient = rep(
        NA_real_, length(theta)
      ), Theta = theta
    ))
  }
  if (isTRUE(reml)) {
    degrees <- n - p
    log_determinant_b <- as.numeric(determinant(
      b, logarithm = TRUE
    )$modulus)
    objective <- log_determinant_a + log_determinant_b +
      degrees * (1 + log(2 * pi * rss / degrees))
  } else {
    degrees <- n
    log_determinant_b <- 0
    objective <- log_determinant_a +
      degrees * (1 + log(2 * pi * rss / degrees))
  }
  gradient <- vapply(seq_along(theta), function(index) {
    z <- z_list[[index]]
    trace_basis <- if (isTRUE(reml)) p_matrix else a_inverse
    trace_term <- 2 * theta[[index]] * sum(z * (trace_basis %*% z))
    quadratic_term <- 2 * theta[[index]] * sum(crossprod(z, q)^2)
    trace_term - degrees * quadratic_term / rss
  }, numeric(1L))
  names(gradient) <- structure_audit$ThetaNames
  list(
    Available = TRUE, Objective = as.numeric(objective),
    Gradient = gradient, Theta = stats::setNames(
      theta, structure_audit$ThetaNames
    ), BetaProfile = as.numeric(beta), ResidualQuadratic = rss,
    LogDeterminantA = log_determinant_a,
    LogDeterminantB = log_determinant_b,
    DegreesOfFreedom = degrees,
    ObjectiveScale = if (isTRUE(reml)) {
      "profiled_reml_criterion_theta_only"
    } else {
      "minus_two_profiled_ml_loglik_theta_only"
    },
    RelativeCovarianceCoordinate = TRUE,
    ResidualScaleProfiledOut = TRUE,
    FixedEffectsProfiledOut = TRUE
  )
}

mfrmr_gtwac_namespace_hashes <- function() {
  namespace <- asNamespace("lme4")
  deviance_method <- getS3method("deviance", "merMod")
  loglik_method <- getS3method("logLik", "merMod")
  functions <- list(
    lmer = get("lmer", namespace),
    mkLmerDevfun = get("mkLmerDevfun", namespace),
    optimizeLmer = get("optimizeLmer", namespace),
    devfun2 = get("devfun2", namespace),
    REMLcrit = get("REMLcrit", namespace),
    deviance_merMod = deviance_method,
    logLik_merMod = loglik_method
  )
  vapply(functions, mfrmr_gtwac_function_hash, character(1L))
}

mfrmr_gtwac_mode_audit <- function(reml) {
  data <- mfrmr_gtwac_fixture_data()
  formula <- Score ~ 1 + (1 | Person) + (1 | Rater)
  fit <- lme4::lmer(
    formula, data = data, REML = isTRUE(reml),
    control = lme4::lmerControl(calc.derivs = TRUE)
  )
  theta_fit <- lme4::getME(fit, "theta")
  theta_eval <- pmax(0.2, theta_fit * c(0.85, 1.15))
  names(theta_eval) <- names(theta_fit)
  devfun <- lme4::lmer(
    formula, data = data, REML = isTRUE(reml),
    control = lme4::lmerControl(calc.derivs = FALSE),
    devFunOnly = TRUE
  )
  oracle <- mfrmr_gtwac_dense_oracle(fit, theta_eval, reml)
  devfun_objective <- as.numeric(devfun(theta_eval))
  numeric_gradient <- as.numeric(numDeriv::grad(
    devfun, theta_eval, method = "Richardson"
  ))
  fit_oracle <- mfrmr_gtwac_dense_oracle(fit, theta_fit, reml)
  fit_criterion <- if (isTRUE(reml)) {
    as.numeric(lme4::REMLcrit(fit))
  } else {
    as.numeric(stats::deviance(fit))
  }
  loglik_criterion <- -2 * as.numeric(stats::logLik(
    fit, REML = isTRUE(reml)
  ))
  baseline <- vapply(seq_len(3L), function(index) {
    as.numeric(devfun(theta_eval))
  }, numeric(1L))
  perturbed <- theta_eval
  perturbed[[1L]] <- perturbed[[1L]] * 1.07
  invisible(devfun(perturbed))
  after_perturbation <- vapply(seq_len(3L), function(index) {
    as.numeric(devfun(theta_eval))
  }, numeric(1L))
  data.frame(
    Likelihood = if (isTRUE(reml)) "REML" else "ML",
    ObjectiveScale = oracle$ObjectiveScale,
    OracleObjective = oracle$Objective,
    DevfunObjective = devfun_objective,
    ObjectiveAbsoluteDifference = abs(oracle$Objective - devfun_objective),
    GradientMaximumAbsoluteDifference = max(abs(
      oracle$Gradient - numeric_gradient
    )),
    AnalyticGradientMaximumAbsoluteValue = max(abs(oracle$Gradient)),
    NumericGradientMaximumAbsoluteValue = max(abs(numeric_gradient)),
    FitOracleAbsoluteDifference = abs(
      fit_oracle$Objective - fit_criterion
    ),
    LogLikCriterionAbsoluteDifference = abs(
      loglik_criterion - fit_criterion
    ),
    EvaluationOrderRange = diff(range(c(baseline, after_perturbation))),
    ThetaDimension = length(theta_eval),
    FixedEffectsProfiledOut = oracle$FixedEffectsProfiledOut,
    ResidualScaleProfiledOut = oracle$ResidualScaleProfiledOut,
    RelativeCovarianceCoordinate = oracle$RelativeCovarianceCoordinate,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwac_boundary_identity_audit <- function(reml) {
  data <- mfrmr_gtwac_fixture_data()
  full_formula <- Score ~ 1 + (1 | Person) + (1 | Rater)
  reduced_formula <- Score ~ 1 + (1 | Person)
  full_fit <- lme4::lmer(full_formula, data = data, REML = isTRUE(reml))
  reduced_fit <- lme4::lmer(
    reduced_formula, data = data, REML = isTRUE(reml)
  )
  full_devfun <- lme4::lmer(
    full_formula, data = data, REML = isTRUE(reml), devFunOnly = TRUE
  )
  reduced_devfun <- lme4::lmer(
    reduced_formula, data = data, REML = isTRUE(reml), devFunOnly = TRUE
  )
  full_theta <- lme4::getME(full_fit, "theta")
  reduced_theta <- lme4::getME(reduced_fit, "theta")
  person_index <- match("Person.(Intercept)", names(full_theta))
  rater_index <- match("Rater.(Intercept)", names(full_theta))
  if (is.na(person_index) || is.na(rater_index) ||
      !identical(names(reduced_theta), "Person.(Intercept)")) {
    stop("The fixture theta map changed.", call. = FALSE)
  }
  full_boundary <- full_theta
  full_boundary[[person_index]] <- reduced_theta[[1L]]
  full_boundary[[rater_index]] <- 0
  full_oracle <- mfrmr_gtwac_dense_oracle(full_fit, full_boundary, reml)
  reduced_oracle <- mfrmr_gtwac_dense_oracle(
    reduced_fit, reduced_theta, reml
  )
  data.frame(
    Likelihood = if (isTRUE(reml)) "REML" else "ML",
    FullBoundaryDevfun = as.numeric(full_devfun(full_boundary)),
    ReducedDevfun = as.numeric(reduced_devfun(reduced_theta)),
    DevfunAbsoluteDifference = abs(
      full_devfun(full_boundary) - reduced_devfun(reduced_theta)
    ),
    OracleAbsoluteDifference = abs(
      full_oracle$Objective - reduced_oracle$Objective
    ),
    TargetThetaAtBoundary = full_boundary[[rater_index]],
    SameFixedEffectMatrix = identical(
      lme4::getME(full_fit, "X"), lme4::getME(reduced_fit, "X")
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwac_api_negative_audit <- function() {
  data <- mfrmr_gtwac_fixture_data()
  formula <- Score ~ 1 + (1 | Person) + (1 | Rater)
  fit_ml <- lme4::lmer(formula, data = data, REML = FALSE)
  fit_reml <- lme4::lmer(formula, data = data, REML = TRUE)
  devfun2_body <- paste(deparse(body(lme4::devfun2)), collapse = "\n")
  deviance_method <- getS3method("deviance", "merMod")
  deviance_body <- paste(deparse(body(deviance_method)), collapse = "\n")
  devfun2 <- lme4::devfun2(fit_ml)
  devfun2_at_optimum <- tryCatch(
    as.numeric(devfun2(attr(devfun2, "optimum"))),
    error = function(error) NA_real_
  )
  reml_criterion <- as.numeric(lme4::REMLcrit(fit_reml))
  deviance_with_reml_argument <- as.numeric(stats::deviance(
    fit_reml, REML = TRUE
  ))
  data.frame(
    InstalledLme4Version = as.character(utils::packageVersion("lme4")),
    Devfun2Basedev = as.numeric(attr(devfun2, "basedev")),
    Devfun2AtAdvertisedOptimum = devfun2_at_optimum,
    Devfun2BaselineReproductionPassed = is.finite(devfun2_at_optimum) &&
      isTRUE(all.equal(
        devfun2_at_optimum, as.numeric(attr(devfun2, "basedev")),
        tolerance = 1e-8
      )),
    Devfun2ForcesML = grepl("refitML", devfun2_body, fixed = TRUE),
    Devfun2PreservesInputREMLMode = !grepl(
      "refitML", devfun2_body, fixed = TRUE
    ),
    REMLCriterion = reml_criterion,
    DevianceWithREMLArgument = deviance_with_reml_argument,
    DevianceArgumentReturnsREMLCriterion = isTRUE(all.equal(
      reml_criterion, deviance_with_reml_argument, tolerance = 1e-8
    )),
    DevianceMethodForcesML = grepl(
      "devCrit(object, REML = FALSE)", deviance_body, fixed = TRUE
    ),
    Devfun2EligibleForB1g9 = FALSE,
    DevianceREMLArgumentEligibleForB1g9 = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwac_preflight_audit <- function() {
  mode_rows <- rbind(
    mfrmr_gtwac_mode_audit(FALSE), mfrmr_gtwac_mode_audit(TRUE)
  )
  boundary_rows <- rbind(
    mfrmr_gtwac_boundary_identity_audit(FALSE),
    mfrmr_gtwac_boundary_identity_audit(TRUE)
  )
  negative <- mfrmr_gtwac_api_negative_audit()
  objective_tolerance <- 2^12 * .Machine$double.eps * pmax(
    1, abs(mode_rows$OracleObjective)
  )
  gradient_tolerance <- 2^12 * .Machine$double.eps^(2 / 3) * pmax(
    1, mode_rows$AnalyticGradientMaximumAbsoluteValue,
    mode_rows$NumericGradientMaximumAbsoluteValue
  )
  boundary_tolerance <- 2^12 * .Machine$double.eps * pmax(
    1, abs(boundary_rows$ReducedDevfun)
  )
  identity <- list(
    Contract = "lme4_theta_only_objective_preflight_b1g9_v1",
    ModeRows = mode_rows, BoundaryRows = boundary_rows,
    ApiNegativeAudit = negative,
    ObjectiveTolerance = objective_tolerance,
    GradientTolerance = gradient_tolerance,
    BoundaryTolerance = boundary_tolerance,
    NamespaceFunctionHashes = mfrmr_gtwac_namespace_hashes()
  )
  structure(c(identity, list(
    AuditHash = mfrmr_gta_hash(identity),
    ObjectiveOracleAgreementReady = all(
      mode_rows$ObjectiveAbsoluteDifference <= objective_tolerance
    ),
    GradientOracleAgreementReady = all(
      mode_rows$GradientMaximumAbsoluteDifference <= gradient_tolerance
    ),
    FitCriterionIdentityReady = all(
      mode_rows$FitOracleAbsoluteDifference <= objective_tolerance &
        mode_rows$LogLikCriterionAbsoluteDifference <= objective_tolerance
    ),
    EvaluationOrderStabilityReady = all(
      mode_rows$EvaluationOrderRange <= objective_tolerance
    ),
    ExactZeroReductionReady = all(
      boundary_rows$DevfunAbsoluteDifference <= boundary_tolerance &
        boundary_rows$OracleAbsoluteDifference <= boundary_tolerance &
        boundary_rows$TargetThetaAtBoundary == 0 &
        boundary_rows$SameFixedEffectMatrix
    ),
    Devfun2Excluded = isTRUE(negative$Devfun2ForcesML) &&
      !isTRUE(negative$Devfun2PreservesInputREMLMode),
    DevianceREMLArgumentExcluded =
      isTRUE(negative$DevianceMethodForcesML) &&
        !isTRUE(negative$DevianceArgumentReturnsREMLCriterion)
  )), class = "mfrmr_gtwac_preflight_audit")
}

mfrmr_gtwac_contract <- function(ml_coverage_contract) {
  mfrmr_gtwac_require_primitives()
  if (!inherits(ml_coverage_contract, "mfrmr_gtwab_contract") ||
      !identical(
        ml_coverage_contract$ContractHash,
        "1216ae3591fc026a61b4fb6581ebe79e33d34e4e2b6bf04a969a4c93c3e06689"
      ) || isTRUE(ml_coverage_contract$CalibrationExecutionAuthorized)) {
    stop("The exact non-authorizing b1g8 contract is required.",
         call. = FALSE)
  }
  audit <- mfrmr_gtwac_preflight_audit()
  ready <- isTRUE(audit$ObjectiveOracleAgreementReady) &&
    isTRUE(audit$GradientOracleAgreementReady) &&
    isTRUE(audit$FitCriterionIdentityReady) &&
    isTRUE(audit$EvaluationOrderStabilityReady) &&
    isTRUE(audit$ExactZeroReductionReady) &&
    isTRUE(audit$Devfun2Excluded) &&
    isTRUE(audit$DevianceREMLArgumentExcluded)
  if (!ready) {
    stop("The lme4 objective-reference preflight failed.", call. = FALSE)
  }
  identity <- list(
    Contract = "lme4_objective_reference_preflight_draft83d2b2b1g9_v1",
    UpstreamB1g8ContractHash = ml_coverage_contract$ContractHash,
    UpstreamB1g8ExecutionHash =
      "46ea4be751a3c54904bac28da31f15e5e05f347b9e8f10a1194887f55557807d",
    PreflightAuditHash = audit$AuditHash,
    SupportedStructure =
      paste0(
        "unweighted_zero_offset_independent_random_intercepts_",
        "theta_relative_sd"
      ),
    MLObjective = "minus_two_profiled_ml_loglik_theta_only",
    REMLObjective = "profiled_reml_criterion_theta_only",
    FixedEffectsProfiledOut = TRUE,
    ResidualScaleProfiledOut = TRUE,
    RawMetricPoolingAcrossBackendsAllowed = FALSE,
    GlmmTMBAbsoluteObjectiveComparisonAllowed = FALSE,
    Devfun2Allowed = FALSE,
    DevianceREMLArgumentAllowed = FALSE,
    MLFitCriterionAccessor = "deviance(fit_ml)",
    REMLFitCriterionAccessor = "REMLcrit(fit_reml)",
    CrossCheckAccessor = "-2*logLik(fit,REML=mode)",
    NonreservedReplicates = c(901L, 902L),
    ReservedReplicates = c(2:3, 101:125, 201:300, 501:700),
    Sources = mfrmr_gtwac_source_registry(),
    PackageVersions = c(
      lme4 = as.character(utils::packageVersion("lme4")),
      Matrix = as.character(utils::packageVersion("Matrix")),
      numDeriv = as.character(utils::packageVersion("numDeriv")),
      R = as.character(getRversion())
    ),
    NamespaceFunctionHashes = mfrmr_gtwac_namespace_hashes(),
    FunctionHashes = mfrmr_gtwac_function_hashes()
  )
  structure(c(identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    IndependentGaussianOracleReady = TRUE,
    ThetaOnlyMLObjectiveIdentityReady = TRUE,
    ThetaOnlyREMLObjectiveIdentityReady = TRUE,
    ExactZeroReductionReady = TRUE,
    Lme4ObjectivePreflightReady = TRUE,
    Lme4BoxConstrainedReferenceSolverReady = FALSE,
    Lme4BoundaryProfileReady = FALSE,
    NonreservedLme4ReplayAuthorized = FALSE,
    Lme4MLReferenceMechanicsReady = FALSE,
    Lme4REMLReferenceMechanicsReady = FALSE,
    ReferenceMethodCoverageComplete = FALSE,
    CalibrationAuthorizationReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE, CalibrationResultsViewed = FALSE,
    StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    ConfirmationAuthorized = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE,
    Audit = audit
  )), class = "mfrmr_gtwac_contract")
}

mfrmr_gtwac_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwac_source_registry", "mfrmr_gtwac_fixture_data",
    "mfrmr_gtwac_simple_intercept_structure",
    "mfrmr_gtwac_dense_oracle", "mfrmr_gtwac_namespace_hashes",
    "mfrmr_gtwac_mode_audit", "mfrmr_gtwac_boundary_identity_audit",
    "mfrmr_gtwac_api_negative_audit", "mfrmr_gtwac_preflight_audit",
    "mfrmr_gtwac_contract"
  )
  preflight_environment <- environment(mfrmr_gtwac_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwac_function_hash(get(
      name, envir = preflight_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}
