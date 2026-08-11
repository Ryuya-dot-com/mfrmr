# Draft.83d2b2b1g12 coordinate-correct production boundary probe.
#
# Repository-internal only. This is the lower-cost application probe that a
# future calibration runner may compare with the high-accuracy references.
# It does not select a stationarity threshold or authorize calibration.

mfrmr_gtwaf_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtwae_function_hashes",
    "mfrmr_gtwta_anchored_objective", "mfrmr_gtwta_target_theta_index",
    "mfrmr_gtwad_target_index"
  )
  probe_environment <- environment(mfrmr_gtwaf_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = probe_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the b1g11 chain before b1g12 boundary probing: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwaf_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtwaf_policy <- function() {
  epsilon <- .Machine$double.eps
  identity <- list(
    Contract = "production_boundary_probe_policy_draft83d2b2b1g12_v1",
    Arithmetic = "IEEE_754_binary64_as_exposed_by_R_machine_double_eps",
    Lme4Coordinate = "nonnegative_relative_standard_deviation_theta",
    GlmmTMBCoordinate = "unconstrained_log_standard_deviation",
    Lme4ThetaFractions = c(1, 0.75, 0.5, 0.25, 0.1, 0.025, 0),
    GlmmTMBLogSdOffsets = c(0, 4, 8, 12, 16, 20),
    ThetaActiveTolerance = 2^10 * sqrt(epsilon),
    LogSdBoundarySentinel = -18,
    ObjectiveDirectionRelativeTolerance = 2^8 * epsilon^(2 / 3),
    ReducedEndpointRelativeTolerance = 2^8 * epsilon^(2 / 3),
    PrimarySolver = "optim_L_BFGS_B_single_warm_start",
    FailureFallbackSolver = "nlminb_same_point_single_restart",
    SolverMaximumIterations = 2000L,
    SolverMaximumEvaluations = 4000L,
    SolverFactr = 1e7,
    SolverProjectedGradientTolerance = 0,
    FallbackRelativeTolerance = 1e-10,
    FallbackXTolerance = 1e-8,
    ReducedObjectiveRequired = TRUE,
    NuisanceReoptimizationRequired = TRUE,
    EndpointReductionRequired = TRUE,
    FirstOrderBoundarySufficiencyClaim = FALSE,
    GeneratingTruthUsed = FALSE,
    CandidateCutoffUsed = FALSE,
    CalibrationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    PolicyHash = mfrmr_gta_hash(identity), PolicyFrozen = TRUE
  )), class = "mfrmr_gtwaf_policy")
}

mfrmr_gtwaf_policy_hash_valid <- function(policy) {
  if (!inherits(policy, "mfrmr_gtwaf_policy") ||
      !isTRUE(policy$PolicyFrozen) || is.null(policy$PolicyHash)) return(FALSE)
  identity <- unclass(policy)
  identity$PolicyHash <- NULL
  identity$PolicyFrozen <- NULL
  identical(policy$PolicyHash, mfrmr_gta_hash(identity))
}

mfrmr_gtwaf_source_registry <- function() {
  data.frame(
    SourceId = c(
      "lme4_lmer_current", "lme4_singularity_current",
      "glmmtmb_troubleshooting_current", "glmmtmb_diagnose_current",
      "self_liang_1987"
    ),
    Locator = c(
      "https://lme4.github.io/lme4/reference/lmer.html",
      "https://lme4.github.io/lme4/reference/isSingular.html",
      paste0(
        "https://glmmtmb.github.io/glmmTMB/articles/",
        "troubleshooting.html"
      ),
      "https://glmmtmb.github.io/glmmTMB/reference/diagnose.html",
      "https://doi.org/10.1080/01621459.1987.10478472"
    ),
    ContractRole = c(
      "lme4 deviance function uses relative-SD theta coordinates",
      "boundary singularity is not equivalent to nonconvergence",
      "large negative glmmTMB log-SD indicates a near-zero component",
      "optimizer, Hessian, and large-parameter diagnostics remain distinct",
      "variance-component boundaries are statistically nonregular"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwaf_validate_probe_inputs <- function(
    fn, parameter, target_index, coordinate, lower, reduced_objective,
    policy) {
  coordinate <- match.arg(coordinate, c("theta", "log_sd"))
  parameter <- as.numeric(parameter)
  target_index <- as.integer(target_index)
  lower <- as.numeric(lower)
  if (!is.function(fn) || length(parameter) == 0L ||
      any(!is.finite(parameter))) {
    stop("A finite nonempty parameter vector and objective are required.",
         call. = FALSE)
  }
  if (length(target_index) != 1L || is.na(target_index) ||
      target_index < 1L || target_index > length(parameter)) {
    stop("One valid target coordinate is required.", call. = FALSE)
  }
  if (!length(lower) %in% c(1L, length(parameter))) {
    stop("Lower bounds must be scalar or match the parameter dimension.",
         call. = FALSE)
  }
  lower <- rep_len(lower, length(parameter))
  if (any(is.na(lower)) ||
      any(lower == Inf) || any(parameter < lower)) {
    stop("Lower bounds must contain the supplied parameter.", call. = FALSE)
  }
  if (identical(coordinate, "theta") &&
      (!is.finite(lower[[target_index]]) ||
       lower[[target_index]] != 0 || parameter[[target_index]] < 0)) {
    stop("The lme4 target must use a finite exact-zero lower bound.",
         call. = FALSE)
  }
  if (identical(coordinate, "log_sd") &&
      is.finite(lower[[target_index]])) {
    stop("The glmmTMB log-SD target must not have a finite lower bound.",
         call. = FALSE)
  }
  reduced_objective <- as.numeric(reduced_objective)
  if (length(reduced_objective) != 1L || !is.finite(reduced_objective)) {
    stop("One finite reduced-model objective is required.", call. = FALSE)
  }
  if (!mfrmr_gtwaf_policy_hash_valid(policy)) {
    stop("The frozen b1g12 policy is required.", call. = FALSE)
  }
  list(
    Fn = fn, Parameter = parameter, TargetIndex = target_index,
    Coordinate = coordinate, Lower = lower,
    ReducedObjective = reduced_objective, Policy = policy
  )
}

mfrmr_gtwaf_target_grid <- function(parameter, target_index, coordinate,
                                     lower, policy) {
  target <- parameter[[target_index]]
  if (identical(coordinate, "theta")) {
    values <- lower[[target_index]] + policy$Lme4ThetaFractions *
      (target - lower[[target_index]])
    labels <- policy$Lme4ThetaFractions
    grid_name <- "fraction"
  } else {
    values <- target - policy$GlmmTMBLogSdOffsets
    labels <- policy$GlmmTMBLogSdOffsets
    grid_name <- "offset"
  }
  data.frame(
    GridIndex = seq_along(values), GridName = grid_name,
    GridValue = labels, TargetValue = values,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwaf_nuisance_fit <- function(fn, parameter, target_index, target,
                                      lower, policy) {
  free_index <- setdiff(seq_along(parameter), target_index)
  reconstruct <- function(free) {
    value <- parameter
    value[free_index] <- free
    value[[target_index]] <- target
    value
  }
  if (length(free_index) == 0L) {
    value <- reconstruct(numeric())
    objective <- tryCatch(as.numeric(fn(value)), error = function(error) NA_real_)
    returned <- length(objective) == 1L && is.finite(objective)
    return(list(
      Parameter = value, Objective = if (returned) objective else NA_real_,
      Returned = returned, Converged = returned, OptimizerCode = 0L,
      SolverId = "none", FallbackAttempted = FALSE,
      FallbackReturned = FALSE, Message = "no_nuisance_coordinates"
    ))
  }
  free_fn <- function(free) fn(reconstruct(free))
  fit <- tryCatch(stats::optim(
    par = parameter[free_index], fn = free_fn, method = "L-BFGS-B",
    lower = lower[free_index],
    control = list(
      maxit = policy$SolverMaximumIterations,
      factr = policy$SolverFactr,
      pgtol = policy$SolverProjectedGradientTolerance
    )
  ), error = function(error) error)
  if (inherits(fit, "error")) {
    return(list(
      Parameter = rep(NA_real_, length(parameter)), Objective = NA_real_,
      Returned = FALSE, Converged = FALSE, OptimizerCode = NA_integer_,
      SolverId = "optim_L_BFGS_B", FallbackAttempted = FALSE,
      FallbackReturned = FALSE, Message = conditionMessage(fit)
    ))
  }
  returned <- length(fit$par) == length(free_index) &&
    all(is.finite(fit$par)) && length(fit$value) == 1L &&
    is.finite(fit$value)
  converged <- returned && identical(as.integer(fit$convergence), 0L)
  if (returned && !converged) {
    fallback <- tryCatch(stats::nlminb(
      start = fit$par, objective = free_fn, lower = lower[free_index],
      control = list(
        eval.max = policy$SolverMaximumEvaluations,
        iter.max = policy$SolverMaximumIterations,
        rel.tol = policy$FallbackRelativeTolerance,
        x.tol = policy$FallbackXTolerance
      )
    ), error = function(error) error)
    fallback_returned <- !inherits(fallback, "error") &&
      length(fallback$par) == length(free_index) &&
      all(is.finite(fallback$par)) &&
      length(fallback$objective) == 1L && is.finite(fallback$objective)
    fallback_converged <- fallback_returned &&
      identical(as.integer(fallback$convergence), 0L)
    if (fallback_returned) {
      return(list(
        Parameter = reconstruct(fallback$par),
        Objective = as.numeric(fallback$objective),
        Returned = TRUE, Converged = fallback_converged,
        OptimizerCode = as.integer(fallback$convergence),
        SolverId = "nlminb_failure_fallback",
        FallbackAttempted = TRUE, FallbackReturned = TRUE,
        Message = paste0(
          "L-BFGS-B code ", fit$convergence, ": ", fit$message,
          "; nlminb: ", fallback$message
        )
      ))
    }
    return(list(
      Parameter = reconstruct(fit$par), Objective = as.numeric(fit$value),
      Returned = TRUE, Converged = FALSE,
      OptimizerCode = as.integer(fit$convergence),
      SolverId = "optim_L_BFGS_B_then_failed_nlminb_fallback",
      FallbackAttempted = TRUE, FallbackReturned = FALSE,
      Message = paste0(
        "L-BFGS-B code ", fit$convergence, ": ", fit$message,
        "; nlminb failure: ", if (inherits(fallback, "error")) {
          conditionMessage(fallback)
        } else if (is.null(fallback$message)) {
          "nonfinite_or_malformed_return"
        } else {
          as.character(fallback$message)
        }
      )
    ))
  }
  list(
    Parameter = if (returned) reconstruct(fit$par) else
      rep(NA_real_, length(parameter)),
    Objective = if (returned) as.numeric(fit$value) else NA_real_,
    Returned = returned, Converged = converged,
    OptimizerCode = as.integer(fit$convergence),
    SolverId = "optim_L_BFGS_B",
    FallbackAttempted = FALSE, FallbackReturned = FALSE,
    Message = if (is.null(fit$message)) "" else as.character(fit$message)
  )
}

mfrmr_gtwaf_probe <- function(
    fn, parameter, target_index, reduced_objective,
    coordinate = c("theta", "log_sd"),
    lower = if (match.arg(coordinate) == "theta") 0 else -Inf,
    policy = mfrmr_gtwaf_policy()) {
  validated <- mfrmr_gtwaf_validate_probe_inputs(
    fn, parameter, target_index, match.arg(coordinate), lower,
    reduced_objective, policy
  )
  grid <- mfrmr_gtwaf_target_grid(
    validated$Parameter, validated$TargetIndex, validated$Coordinate,
    validated$Lower, policy
  )
  current <- validated$Parameter
  rows <- vector("list", nrow(grid))
  for (index in seq_len(nrow(grid))) {
    fit <- mfrmr_gtwaf_nuisance_fit(
      validated$Fn, current, validated$TargetIndex,
      grid$TargetValue[[index]], validated$Lower, policy
    )
    if (isTRUE(fit$Converged)) current <- fit$Parameter
    rows[[index]] <- data.frame(
      GridIndex = grid$GridIndex[[index]],
      GridName = grid$GridName[[index]],
      GridValue = grid$GridValue[[index]],
      Coordinate = validated$Coordinate,
      TargetValue = grid$TargetValue[[index]],
      Returned = fit$Returned, Converged = fit$Converged,
      SolverId = fit$SolverId, OptimizerCode = fit$OptimizerCode,
      FallbackAttempted = fit$FallbackAttempted,
      FallbackReturned = fit$FallbackReturned,
      Objective = fit$Objective,
      ParameterHash = if (fit$Returned) {
        mfrmr_gta_hash(unname(fit$Parameter))
      } else "none",
      Message = fit$Message, stringsAsFactors = FALSE
    )
  }
  rows <- do.call(rbind, rows)
  available <- all(rows$Returned & rows$Converged & is.finite(rows$Objective))
  direction_tolerance <- if (available) {
    policy$ObjectiveDirectionRelativeTolerance * pmax(
      1, abs(rows$Objective[-1L]), abs(rows$Objective[-nrow(rows)])
    )
  } else rep(NA_real_, max(0L, nrow(rows) - 1L))
  endpoint_tolerance <- policy$ReducedEndpointRelativeTolerance * max(
    1, abs(validated$ReducedObjective),
    if (available) abs(tail(rows$Objective, 1L)) else 0
  )
  endpoint_matched <- available &&
    abs(tail(rows$Objective, 1L) - validated$ReducedObjective) <=
      endpoint_tolerance
  monotone_improvement <- available && all(
    diff(rows$Objective) <= direction_tolerance
  )
  monotone_worsening <- available && all(
    diff(rows$Objective) >= -direction_tolerance
  )
  material_tolerance <- policy$ObjectiveDirectionRelativeTolerance * max(
    1, if (available) abs(rows$Objective[c(1L, nrow(rows))]) else 0
  )
  material_improvement <- available &&
    rows$Objective[[1L]] - rows$Objective[[nrow(rows)]] > material_tolerance
  material_worsening <- available &&
    rows$Objective[[nrow(rows)]] - rows$Objective[[1L]] > material_tolerance
  start_matches_reduced <- available &&
    abs(rows$Objective[[1L]] - validated$ReducedObjective) <=
      endpoint_tolerance
  already_boundary <- if (identical(validated$Coordinate, "theta")) {
    validated$Parameter[[validated$TargetIndex]] <=
      policy$ThetaActiveTolerance && start_matches_reduced
  } else {
    validated$Parameter[[validated$TargetIndex]] <=
      policy$LogSdBoundarySentinel && start_matches_reduced
  }
  state <- if (!available) {
    "not_evaluable"
  } else if (!endpoint_matched) {
    "boundary_probe_inconclusive"
  } else if (already_boundary ||
             (monotone_improvement && material_improvement)) {
    "boundary_limit_supported"
  } else if (monotone_worsening && material_worsening) {
    "finite_interior_supported"
  } else {
    "boundary_probe_inconclusive"
  }
  identity <- list(
    Contract = "production_boundary_profile_b1g12_v1",
    Coordinate = validated$Coordinate,
    TargetIndex = validated$TargetIndex,
    InitialTargetValue = validated$Parameter[[validated$TargetIndex]],
    ReducedObjective = validated$ReducedObjective,
    Rows = rows,
    Available = available,
    ReducedEndpointMatched = endpoint_matched,
    ReducedEndpointAbsoluteDifference = if (available) {
      abs(tail(rows$Objective, 1L) - validated$ReducedObjective)
    } else NA_real_,
    ReducedEndpointTolerance = endpoint_tolerance,
    MonotoneImprovementTowardBoundary = monotone_improvement,
    MonotoneWorseningTowardBoundary = monotone_worsening,
    MaterialImprovementTowardBoundary = material_improvement,
    MaterialWorseningTowardBoundary = material_worsening,
    AlreadyAtBoundary = already_boundary,
    State = state,
    ApplicationState = c(
      boundary_limit_supported = "boundary_handoff",
      finite_interior_supported = "continue_first_order_curvature",
      boundary_probe_inconclusive = "indeterminate",
      not_evaluable = "not_evaluable"
    )[[state]],
    FirstOrderBoundarySufficiencyClaim = FALSE,
    GeneratingTruthUsed = FALSE,
    PolicyHash = policy$PolicyHash
  )
  structure(c(identity, list(
    ProbeHash = mfrmr_gta_hash(identity)
  )), class = "mfrmr_gtwaf_probe")
}

mfrmr_gtwaf_probe_hash_valid <- function(probe) {
  if (!inherits(probe, "mfrmr_gtwaf_probe") ||
      is.null(probe$ProbeHash)) return(FALSE)
  identity <- unclass(probe)
  identity$ProbeHash <- NULL
  identical(probe$ProbeHash, mfrmr_gta_hash(identity))
}

mfrmr_gtwaf_not_applicable <- function(model_role = "reduced") {
  if (!identical(model_role, "reduced")) {
    stop("Only a reduced model has no target component to probe.",
         call. = FALSE)
  }
  identity <- list(
    Contract = "production_boundary_profile_not_applicable_b1g12_v1",
    ModelRole = model_role, State = "not_applicable",
    ApplicationState = "not_applicable",
    FirstOrderBoundarySufficiencyClaim = FALSE,
    GeneratingTruthUsed = FALSE
  )
  structure(c(identity, list(
    ProbeHash = mfrmr_gta_hash(identity)
  )), class = "mfrmr_gtwaf_probe")
}

mfrmr_gtwaf_probe_lme4 <- function(full_fit_result, reduced_fit_result,
                                    target = "Rater",
                                    policy = mfrmr_gtwaf_policy()) {
  if (!is.list(full_fit_result) || !is.list(reduced_fit_result) ||
      !inherits(full_fit_result$Fit, "merMod") ||
      !inherits(reduced_fit_result$Fit, "merMod") ||
      !is.function(full_fit_result$Devfun) ||
      !is.finite(reduced_fit_result$Criterion)) {
    stop("Full and reduced mfrmr_gtwad lme4 fit results are required.",
         call. = FALSE)
  }
  fit <- full_fit_result$Fit
  result <- mfrmr_gtwaf_probe(
    full_fit_result$Devfun, lme4::getME(fit, "theta"),
    mfrmr_gtwad_target_index(fit, target),
    reduced_fit_result$Criterion, coordinate = "theta",
    lower = lme4::getME(fit, "lower"), policy = policy
  )
  result$Backend <- "lme4"
  result$ObjectiveScale <- if (lme4::isREML(fit)) {
    "profiled_reml_criterion_theta_only"
  } else {
    "minus_two_profiled_ml_loglik_theta_only"
  }
  result$ProbeHash <- NULL
  result$ProbeHash <- mfrmr_gta_hash(unclass(result))
  result
}

mfrmr_gtwaf_probe_glmmtmb <- function(full_fit_result, reduced_fit_result,
                                       target = "Rater",
                                       policy = mfrmr_gtwaf_policy()) {
  if (!is.list(full_fit_result) || !is.list(reduced_fit_result) ||
      !inherits(full_fit_result$Fit, "glmmTMB") ||
      !inherits(reduced_fit_result$Fit, "glmmTMB") ||
      !is.finite(reduced_fit_result$Fit$fit$objective)) {
    stop("Full and reduced mfrmr_gtwta glmmTMB fit results are required.",
         call. = FALSE)
  }
  fit <- full_fit_result$Fit
  objective <- mfrmr_gtwta_anchored_objective(fit)
  result <- mfrmr_gtwaf_probe(
    objective$Fn, fit$fit$par,
    mfrmr_gtwta_target_theta_index(fit, target),
    reduced_fit_result$Fit$fit$objective, coordinate = "log_sd",
    lower = rep(-Inf, length(fit$fit$par)), policy = policy
  )
  result$Backend <- "glmmTMB"
  result$ObjectiveScale <- "tmb_laplace_negative_log_likelihood"
  result$RandomStartAnchorHash <- objective$RandomStartAnchorHash
  result$ProbeHash <- NULL
  result$ProbeHash <- mfrmr_gta_hash(unclass(result))
  result
}

mfrmr_gtwaf_analytic_audit <- function(policy = mfrmr_gtwaf_policy()) {
  fixtures <- list(
    theta_interior = list(
      Fn = function(value) (value[[1L]] - 1)^2 +
        (value[[2L]] - 2)^2,
      Parameter = c(1, 0), Coordinate = "theta", Lower = c(0, -Inf),
      Reduced = 1, Expected = "finite_interior_supported"
    ),
    theta_boundary = list(
      Fn = function(value) value[[1L]]^2 + (value[[2L]] - 2)^2,
      Parameter = c(0.5, 0), Coordinate = "theta", Lower = c(0, -Inf),
      Reduced = 0, Expected = "boundary_limit_supported"
    ),
    theta_active = list(
      Fn = function(value) value[[1L]]^2 + (value[[2L]] - 2)^2,
      Parameter = c(0, 0), Coordinate = "theta", Lower = c(0, -Inf),
      Reduced = 0, Expected = "boundary_limit_supported"
    ),
    log_sd_interior = list(
      Fn = function(value) (exp(2 * value[[1L]]) - 1)^2 + value[[2L]]^2,
      Parameter = c(0, 1), Coordinate = "log_sd", Lower = c(-Inf, -Inf),
      Reduced = 1, Expected = "finite_interior_supported"
    ),
    log_sd_boundary = list(
      Fn = function(value) exp(2 * value[[1L]]) + value[[2L]]^2,
      Parameter = c(-1, 1), Coordinate = "log_sd", Lower = c(-Inf, -Inf),
      Reduced = 0, Expected = "boundary_limit_supported"
    ),
    flat = list(
      Fn = function(value) (value[[2L]] - 2)^2,
      Parameter = c(0.5, 0), Coordinate = "theta", Lower = c(0, -Inf),
      Reduced = 0, Expected = "boundary_probe_inconclusive"
    ),
    endpoint_mismatch = list(
      Fn = function(value) value[[1L]]^2 + (value[[2L]] - 2)^2,
      Parameter = c(0.5, 0), Coordinate = "theta", Lower = c(0, -Inf),
      Reduced = 1, Expected = "boundary_probe_inconclusive"
    )
  )
  results <- lapply(fixtures, function(fixture) mfrmr_gtwaf_probe(
    fixture$Fn, fixture$Parameter, 1L, fixture$Reduced,
    fixture$Coordinate, fixture$Lower, policy
  ))
  rows <- do.call(rbind, lapply(names(fixtures), function(name) {
    result <- results[[name]]
    data.frame(
      Fixture = name, Coordinate = result$Coordinate,
      State = result$State, ExpectedState = fixtures[[name]]$Expected,
      StateMatched = identical(result$State, fixtures[[name]]$Expected),
      Available = result$Available,
      ReducedEndpointMatched = result$ReducedEndpointMatched,
      FirstOrderBoundarySufficiencyClaim =
        result$FirstOrderBoundarySufficiencyClaim,
      GeneratingTruthUsed = result$GeneratingTruthUsed,
      stringsAsFactors = FALSE
    )
  }))
  failure <- mfrmr_gtwaf_probe(
    function(value) NA_real_, c(0.5, 0), 1L, 0,
    "theta", c(0, -Inf), policy
  )
  identity <- list(
    Contract = "production_boundary_probe_analytic_audit_b1g12_v1",
    Rows = rows, FailureState = failure$State,
    FailureApplicationState = failure$ApplicationState,
    ThetaBoundaryEndpoint = tail(
      results$theta_boundary$Rows$TargetValue, 1L
    ),
    LogSdBoundaryEndpoint = tail(
      results$log_sd_boundary$Rows$TargetValue, 1L
    )
  )
  structure(c(identity, list(
    AuditHash = mfrmr_gta_hash(identity),
    AnalyticStateRecoveryReady = all(rows$StateMatched) &&
      all(rows$Available) && identical(failure$State, "not_evaluable"),
    CoordinateEndpointsReady =
      identical(identity$ThetaBoundaryEndpoint, 0) &&
      identical(identity$LogSdBoundaryEndpoint, -21),
    TruthBlindReady = all(!rows$GeneratingTruthUsed) &&
      all(!rows$FirstOrderBoundarySufficiencyClaim)
  )), class = "mfrmr_gtwaf_analytic_audit")
}

mfrmr_gtwaf_contract <- function(acceptance_contract) {
  mfrmr_gtwaf_require_primitives()
  if (!inherits(acceptance_contract, "mfrmr_gtwae_contract") ||
      !identical(
        acceptance_contract$ContractHash,
        "1dcc877da78d3975271b33629b3d67bd9f0f48d675fb1ed62e5704baa46b8b1a"
      ) || !isTRUE(acceptance_contract$AcceptancePolicyFrozen) ||
      isTRUE(acceptance_contract$CalibrationExecutionAuthorized)) {
    stop("The exact non-authorizing b1g11 contract is required.",
         call. = FALSE)
  }
  policy <- mfrmr_gtwaf_policy()
  audit <- mfrmr_gtwaf_analytic_audit(policy)
  if (!isTRUE(audit$AnalyticStateRecoveryReady) ||
      !isTRUE(audit$CoordinateEndpointsReady) ||
      !isTRUE(audit$TruthBlindReady)) {
    stop("The b1g12 analytic probe preflight failed.", call. = FALSE)
  }
  identity <- list(
    Contract = "production_boundary_probe_contract_draft83d2b2b1g12_v1",
    UpstreamB1g11ContractHash = acceptance_contract$ContractHash,
    AcceptancePolicyHash = acceptance_contract$Policy$PolicyHash,
    Policy = policy, Sources = mfrmr_gtwaf_source_registry(),
    AnalyticAuditHash = audit$AuditHash,
    FunctionHashes = mfrmr_gtwaf_function_hashes()
  )
  structure(c(identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    ProductionBoundaryProbeReady = TRUE,
    BackendCoordinateTranslationReady = TRUE,
    ReducedEndpointMatchRequired = TRUE,
    NuisanceReoptimizationRequired = TRUE,
    InconclusiveStateRetained = TRUE,
    NonEvaluableStateRetained = TRUE,
    FirstOrderBoundarySufficiencyClaim = FALSE,
    AcceptancePolicyFrozen = TRUE,
    ReferenceMethodCoverageComplete = TRUE,
    RunnerImplementationReady = FALSE,
    CalibrationAuthorizationReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE, CalibrationResultsViewed = FALSE,
    StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    ConfirmationAuthorized = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE,
    Audit = audit
  )), class = "mfrmr_gtwaf_contract")
}

mfrmr_gtwaf_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwaf_source_registry", "mfrmr_gtwaf_policy",
    "mfrmr_gtwaf_policy_hash_valid",
    "mfrmr_gtwaf_validate_probe_inputs", "mfrmr_gtwaf_target_grid",
    "mfrmr_gtwaf_nuisance_fit", "mfrmr_gtwaf_probe",
    "mfrmr_gtwaf_probe_hash_valid", "mfrmr_gtwaf_not_applicable",
    "mfrmr_gtwaf_probe_lme4",
    "mfrmr_gtwaf_probe_glmmtmb", "mfrmr_gtwaf_analytic_audit",
    "mfrmr_gtwaf_contract"
  )
  probe_environment <- environment(mfrmr_gtwaf_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwaf_function_hash(get(
      name, envir = probe_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}
