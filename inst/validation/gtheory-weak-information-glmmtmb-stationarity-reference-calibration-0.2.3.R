# Draft.83d2b2b1g6 high-accuracy stationarity-reference calibration.
#
# Repository-internal only. Tolerances are derived from double-precision error
# scales, checked on analytic objectives, and replayed on two nonreserved weak-
# information datasets. An AD-independent central-difference ladder estimates
# the attainable derivative resolution of each composed Laplace objective.
# Calibration replicates 201--300 remain sealed.

mfrmr_gtwta_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtw_registry", "mfrmr_gtw_generate",
    "mfrmr_gtd3_prefit_one", "mfrmr_gtwd_reduced_formula",
    "mfrmr_gtwd_capture", "mfrmr_gtwsy_scale_metrics",
    "mfrmr_gtwsz_contract"
  )
  reference_environment <- environment(mfrmr_gtwta_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = reference_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the complete Draft.83d2b2b1g5 chain before b1g6: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwta_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtwta_tolerance_policy <- function() {
  epsilon <- .Machine$double.eps
  identity <- list(
    Contract = "stationarity_reference_tolerance_policy_draft83d2b2b1g6_v2",
    Arithmetic = "IEEE_754_binary64_as_exposed_by_R_machine_double_eps",
    MachineEpsilon = epsilon,
    CentralDifferenceBalancingScale = epsilon^(1 / 3),
    CentralDifferenceErrorScale = epsilon^(2 / 3),
    DerivativeRelativeTolerance = 2^12 * epsilon^(2 / 3),
    DerivativeStepExponents = -4L:8L,
    DerivativeStabilityMultiplier = 2^2,
    DerivativeMinimumInteriorScales = 3L,
    DerivativeStepSelectionUsesAutomaticGradient = FALSE,
    DerivativeResolutionIsComponentwise = TRUE,
    HessianSymmetryRelativeTolerance = 2^12 * epsilon^(2 / 3),
    ObjectiveConsensusRelativeTolerance = 2^8 * epsilon^(2 / 3),
    ObjectiveReplayRelativeTolerance = 2^10 * epsilon,
    NewtonDecrementTolerance = 2^10 * sqrt(epsilon),
    GradientAbsoluteTolerance = 2^10 * sqrt(epsilon),
    CurvatureRelativeTolerance = 2^12 * epsilon^(2 / 3),
    BoundaryObjectiveRelativeTolerance = 2^8 * epsilon^(2 / 3),
    MinimumConsensusAlgorithms = 3L,
    NewtonMaximumIterations = 25L,
    NewtonMaximumBacktracks = 30L,
    NewtonArmijoConstant = 1e-4,
    NewtonBacktrackFactor = 0.5,
    SolverMaximumIterations = 10000L,
    SolverMaximumEvaluations = 20000L,
    SolverRelativeTolerance = 1e-12,
    SolverXTolerance = 1e-10,
    BoundaryLogSdOffsets = c(0, 2, 4, 8, 12, 16),
    CandidateCutoffUse = FALSE,
    Lme4DefaultCutoffUse = FALSE
  )
  structure(c(identity, list(
    PolicyHash = mfrmr_gta_hash(identity), ToleranceContractFrozen = TRUE
  )), class = "mfrmr_gtwta_tolerance_policy")
}

mfrmr_gtwta_softplus <- function(value) {
  value <- as.numeric(value)
  ifelse(value > 0, value + log1p(exp(-value)), log1p(exp(value)))
}

mfrmr_gtwta_analytic_registry <- function() {
  data.frame(
    FixtureId = c(
      "pd_quadratic", "ill_conditioned_quadratic", "flat_quartic",
      "stationary_saddle", "rosenbrock_minimum", "logsd_boundary_escape"
    ),
    Dimension = c(3L, 3L, 2L, 2L, 2L, 2L),
    EvaluationPoint = I(list(
      c(1, -2, 0.5), c(0, 0, 0), c(0, 0), c(0, 0), c(1, 1), c(0, 0)
    )),
    ExpectedState = c(
      "finite_local_minimum", "finite_stationary_flat",
      "finite_stationary_flat", "finite_saddle_or_max",
      "finite_local_minimum", "boundary_limit"
    ),
    KnownObjective = c(3, 0, 0, 0, 0, log(2)),
    UsesFittedData = FALSE, UsesCalibrationData = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwta_analytic_eval <- function(fixture_id, parameter) {
  fixture_id <- as.character(fixture_id)
  parameter <- as.numeric(parameter)
  if (identical(fixture_id, "pd_quadratic")) {
    center <- c(1, -2, 0.5)
    hessian <- matrix(c(4, 1, 0.2, 1, 3, 0.3, 0.2, 0.3, 2), 3L)
    delta <- parameter - center
    return(list(
      Objective = 3 + drop(crossprod(delta, hessian %*% delta)) / 2,
      Gradient = as.numeric(hessian %*% delta), Hessian = hessian
    ))
  }
  if (identical(fixture_id, "ill_conditioned_quadratic")) {
    hessian <- diag(c(1e-6, 1, 1e6))
    return(list(
      Objective = drop(crossprod(parameter, hessian %*% parameter)) / 2,
      Gradient = as.numeric(hessian %*% parameter), Hessian = hessian
    ))
  }
  if (identical(fixture_id, "flat_quartic")) {
    return(list(
      Objective = parameter[[1L]]^2 + parameter[[2L]]^4,
      Gradient = c(2 * parameter[[1L]], 4 * parameter[[2L]]^3),
      Hessian = diag(c(2, 12 * parameter[[2L]]^2))
    ))
  }
  if (identical(fixture_id, "stationary_saddle")) {
    return(list(
      Objective = parameter[[1L]]^2 - parameter[[2L]]^2,
      Gradient = c(2 * parameter[[1L]], -2 * parameter[[2L]]),
      Hessian = diag(c(2, -2))
    ))
  }
  if (identical(fixture_id, "rosenbrock_minimum")) {
    x <- parameter[[1L]]
    y <- parameter[[2L]]
    return(list(
      Objective = 100 * (y - x^2)^2 + (1 - x)^2,
      Gradient = c(
        -400 * x * (y - x^2) - 2 * (1 - x),
        200 * (y - x^2)
      ),
      Hessian = matrix(c(
        1200 * x^2 - 400 * y + 2, -400 * x,
        -400 * x, 200
      ), 2L, byrow = TRUE)
    ))
  }
  if (identical(fixture_id, "logsd_boundary_escape")) {
    eta <- parameter[[1L]]
    nuisance <- parameter[[2L]]
    logistic <- stats::plogis(2 * eta)
    return(list(
      Objective = mfrmr_gtwta_softplus(2 * eta) + nuisance^2,
      Gradient = c(2 * logistic, 2 * nuisance),
      Hessian = diag(c(4 * logistic * (1 - logistic), 2))
    ))
  }
  stop("Unknown analytic reference fixture.", call. = FALSE)
}

mfrmr_gtwta_derivative_audit <- function(fn, gr, parameter, policy) {
  parameter <- as.numeric(parameter)
  objective <- tryCatch(as.numeric(fn(parameter)),
                        error = function(error) NA_real_)
  ad_gradient <- as.numeric(gr(parameter))
  richardson_gradient <- tryCatch(
    as.numeric(numDeriv::grad(fn, parameter, method = "Richardson")),
    error = function(error) numeric()
  )
  parameter_scale <- pmax(1, abs(parameter))
  step_multipliers <- policy$CentralDifferenceBalancingScale *
    2^policy$DerivativeStepExponents
  central_gradients <- tryCatch(t(vapply(
    step_multipliers,
    function(multiplier) vapply(seq_along(parameter), function(component) {
      step <- multiplier * parameter_scale[[component]]
      plus <- parameter
      minus <- parameter
      plus[[component]] <- plus[[component]] + step
      minus[[component]] <- minus[[component]] - step
      (fn(plus) - fn(minus)) / (2 * step)
    }, numeric(1L)),
    numeric(length(parameter))
  )), error = function(error) matrix(numeric(), 0L, 0L))
  central_available <- is.matrix(central_gradients) &&
    nrow(central_gradients) == length(step_multipliers) &&
    ncol(central_gradients) == length(parameter) &&
    all(is.finite(central_gradients))
  interior <- if (length(step_multipliers) >=
                  policy$DerivativeMinimumInteriorScales) {
    2L:(length(step_multipliers) - 1L)
  } else integer()
  stability_scores <- if (central_available && length(interior) > 0L) {
    vapply(interior, function(index) {
      denominator <- pmax(
        1, abs(central_gradients[index - 1L, ]),
        abs(central_gradients[index, ]),
        abs(central_gradients[index + 1L, ])
      )
      max(
        abs(central_gradients[index, ] -
              central_gradients[index - 1L, ]) / denominator,
        abs(central_gradients[index + 1L, ] -
              central_gradients[index, ]) / denominator
      )
    }, numeric(1L))
  } else numeric()
  selected_index <- if (length(stability_scores) > 0L &&
                        all(is.finite(stability_scores))) {
    interior[[which.min(stability_scores)]]
  } else NA_integer_
  fd_gradient <- if (!is.na(selected_index)) {
    as.numeric(central_gradients[selected_index, ])
  } else numeric()
  resolution <- if (!is.na(selected_index)) {
    step <- step_multipliers[[selected_index]] * parameter_scale
    roundoff <- 2 * .Machine$double.eps * max(1, abs(objective)) / step
    pmax(
      abs(central_gradients[selected_index, ] -
            central_gradients[selected_index - 1L, ]),
      abs(central_gradients[selected_index + 1L, ] -
            central_gradients[selected_index, ]),
      roundoff
    )
  } else numeric()
  fd_hessian <- tryCatch(
    numDeriv::jacobian(gr, parameter, method = "Richardson"),
    error = function(error) matrix(numeric(), 0L, 0L)
  )
  gradient_available <- length(fd_gradient) == length(parameter) &&
    all(is.finite(c(ad_gradient, fd_gradient)))
  hessian_available <- is.matrix(fd_hessian) &&
    all(dim(fd_hessian) == length(parameter)) && all(is.finite(fd_hessian))
  gradient_relative <- if (gradient_available) {
    max(abs(ad_gradient - fd_gradient)) /
      max(1, abs(ad_gradient), abs(fd_gradient))
  } else NA_real_
  hessian_symmetry <- if (hessian_available)
    max(abs(fd_hessian - t(fd_hessian))) else NA_real_
  hessian_symmetry_tolerance <- if (hessian_available) {
    policy$HessianSymmetryRelativeTolerance *
      max(1, abs(fd_hessian))
  } else NA_real_
  hessian_symmetry_passed <- hessian_available &&
    hessian_symmetry <= hessian_symmetry_tolerance
  component_tolerance <- if (gradient_available &&
                             length(resolution) == length(parameter)) {
    pmax(
      policy$DerivativeRelativeTolerance *
        pmax(1, abs(ad_gradient), abs(fd_gradient)),
      policy$DerivativeStabilityMultiplier * resolution
    )
  } else numeric()
  component_passed <- if (gradient_available &&
                          length(component_tolerance) == length(parameter)) {
    abs(ad_gradient - fd_gradient) <= component_tolerance
  } else rep(FALSE, length(parameter))
  richardson_relative <- if (
      length(richardson_gradient) == length(parameter) &&
      all(is.finite(c(ad_gradient, richardson_gradient)))) {
    max(abs(ad_gradient - richardson_gradient)) /
      max(1, abs(ad_gradient), abs(richardson_gradient))
  } else NA_real_
  list(
    AdGradient = ad_gradient, FdGradient = fd_gradient,
    RichardsonGradient = richardson_gradient, FdHessian = fd_hessian,
    ObjectiveAtPoint = objective,
    CentralDifferenceStepMultipliers = step_multipliers,
    CentralDifferenceGradients = central_gradients,
    StabilityScores = stability_scores,
    SelectedStepIndex = selected_index,
    SelectedStepExponent = if (!is.na(selected_index))
      policy$DerivativeStepExponents[[selected_index]] else NA_integer_,
    SelectedStepMultiplier = if (!is.na(selected_index))
      step_multipliers[[selected_index]] else NA_real_,
    FiniteDifferenceResolution = resolution,
    ComponentTolerance = component_tolerance,
    ComponentPassed = component_passed,
    GradientAvailable = gradient_available,
    HessianAvailable = hessian_available,
    GradientRelativeDifference = gradient_relative,
    RichardsonRelativeDifference = richardson_relative,
    HessianSymmetryResidual = hessian_symmetry,
    HessianSymmetryTolerance = hessian_symmetry_tolerance,
    HessianSymmetryPassed = hessian_symmetry_passed,
    StepSelectionUsesAutomaticGradient = FALSE,
    DerivativeAgreementPassed = gradient_available && hessian_available &&
      hessian_symmetry_passed && all(component_passed)
  )
}

mfrmr_gtwta_curvature_state <- function(hessian, policy) {
  hessian <- as.matrix(hessian)
  if (nrow(hessian) == 0L || nrow(hessian) != ncol(hessian) ||
      !all(is.finite(hessian))) return("not_evaluable")
  eigenvalues <- tryCatch(eigen(
    (hessian + t(hessian)) / 2, symmetric = TRUE, only.values = TRUE
  )$values, error = function(error) numeric())
  if (length(eigenvalues) != nrow(hessian) || !all(is.finite(eigenvalues))) {
    return("not_evaluable")
  }
  tolerance <- policy$CurvatureRelativeTolerance *
    max(1, max(abs(eigenvalues)))
  if (min(eigenvalues) > tolerance) return("positive_definite")
  if (min(eigenvalues) < -tolerance) return("indefinite")
  "near_singular_or_semidefinite"
}

mfrmr_gtwta_stationarity_state <- function(parameter, objective, gradient,
                                             hessian, derivative_pass,
                                             consensus_pass, policy) {
  metrics <- mfrmr_gtwsy_scale_metrics(
    parameter, objective, gradient, hessian
  )
  curvature <- mfrmr_gtwta_curvature_state(hessian, policy)
  raw_small <- isTRUE(metrics$RawAvailable) &&
    metrics$RawMaximumAbsolute <= policy$GradientAbsoluteTolerance
  newton_small <- isTRUE(metrics$NewtonWhitenedAvailable) &&
    metrics$NewtonDecrement <= policy$NewtonDecrementTolerance
  if (!isTRUE(derivative_pass) || !isTRUE(consensus_pass)) {
    return("reference_unresolved")
  }
  if (identical(curvature, "positive_definite") && newton_small) {
    return("finite_local_minimum")
  }
  if (identical(curvature, "near_singular_or_semidefinite") && raw_small) {
    return("finite_stationary_flat")
  }
  if (identical(curvature, "indefinite") && raw_small) {
    return("finite_saddle_or_max")
  }
  if (isTRUE(metrics$RawAvailable)) return("finite_nonstationary")
  "not_evaluable"
}

mfrmr_gtwta_analytic_audit <- function(
    policy = mfrmr_gtwta_tolerance_policy()) {
  registry <- mfrmr_gtwta_analytic_registry()
  rows <- do.call(rbind, lapply(seq_len(nrow(registry)), function(index) {
    fixture_id <- registry$FixtureId[[index]]
    parameter <- registry$EvaluationPoint[[index]]
    fn <- function(value) mfrmr_gtwta_analytic_eval(
      fixture_id, value
    )$Objective
    gr <- function(value) mfrmr_gtwta_analytic_eval(
      fixture_id, value
    )$Gradient
    exact <- mfrmr_gtwta_analytic_eval(fixture_id, parameter)
    derivatives <- mfrmr_gtwta_derivative_audit(
      fn, gr, parameter, policy
    )
    state <- mfrmr_gtwta_stationarity_state(
      parameter, exact$Objective, exact$Gradient, exact$Hessian,
      derivatives$DerivativeAgreementPassed, TRUE, policy
    )
    if (identical(fixture_id, "logsd_boundary_escape")) {
      offsets <- policy$BoundaryLogSdOffsets
      profile <- vapply(offsets, function(offset) {
        fn(c(parameter[[1L]] - offset, 0))
      }, numeric(1L))
      tolerance <- policy$BoundaryObjectiveRelativeTolerance *
        max(1, abs(profile))
      decreasing <- all(diff(profile) <= tolerance[-1L]) &&
        profile[[1L]] - profile[[length(profile)]] > tolerance[[1L]]
      if (decreasing) state <- "boundary_limit"
    }
    data.frame(
      FixtureId = fixture_id, ExpectedState = registry$ExpectedState[[index]],
      ObservedState = state,
      ObjectiveDifference = exact$Objective - registry$KnownObjective[[index]],
      GradientRelativeDifference = derivatives$GradientRelativeDifference,
      HessianSymmetryResidual = derivatives$HessianSymmetryResidual,
      DerivativeAgreementPassed = derivatives$DerivativeAgreementPassed,
      StateMatched = identical(state, registry$ExpectedState[[index]]),
      stringsAsFactors = FALSE
    )
  }))
  identity <- list(
    Contract = "stationarity_reference_analytic_audit_draft83d2b2b1g6_v2",
    PolicyHash = policy$PolicyHash, Rows = rows
  )
  structure(c(identity, list(
    AuditHash = mfrmr_gta_hash(identity),
    AnalyticFixtureCount = nrow(rows),
    DerivativeAgreementReady = all(rows$DerivativeAgreementPassed),
    AnalyticStateRecoveryReady = all(rows$StateMatched)
  )), class = "mfrmr_gtwta_analytic_audit")
}

mfrmr_gtwta_solver_one <- function(fn, gr, start, algorithm, policy) {
  started <- proc.time()[["elapsed"]]
  result <- tryCatch({
    if (identical(algorithm, "nlminb")) {
      fit <- stats::nlminb(
        start, fn, gr, control = list(
          eval.max = policy$SolverMaximumEvaluations,
          iter.max = policy$SolverMaximumIterations,
          rel.tol = policy$SolverRelativeTolerance,
          x.tol = policy$SolverXTolerance
        )
      )
      list(par = fit$par, objective = fit$objective,
           code = as.integer(fit$convergence))
    } else {
      fit <- stats::optim(
        start, fn, if (identical(algorithm, "BFGS")) gr else NULL,
        method = algorithm,
        control = list(
          maxit = if (identical(algorithm, "Nelder-Mead"))
            2L * policy$SolverMaximumIterations else
            policy$SolverMaximumIterations,
          reltol = policy$SolverRelativeTolerance
        )
      )
      list(par = fit$par, objective = fit$value,
           code = as.integer(fit$convergence))
    }
  }, error = function(error) list(
    par = numeric(), objective = NA_real_, code = NA_integer_
  ))
  parameter <- as.numeric(result$par)
  returned <- length(parameter) == length(start) &&
    all(is.finite(parameter)) && is.finite(result$objective)
  list(
    Returned = returned, Parameter = parameter,
    Objective = as.numeric(result$objective), Code = result$code,
    RuntimeSeconds = proc.time()[["elapsed"]] - started
  )
}

mfrmr_gtwta_starts <- function(parameter) {
  parameter <- as.numeric(parameter)
  dimension <- length(parameter)
  direction <- rep(c(-1, 1), length.out = dimension) /
    sqrt(max(1, dimension))
  perturbation <- 0.05 * pmax(1, abs(parameter)) * direction
  list(reported = parameter, deterministic_plus = parameter + perturbation,
       deterministic_minus = parameter - perturbation)
}

mfrmr_gtwta_newton_polish <- function(fn, gr, parameter, policy) {
  parameter <- as.numeric(parameter)
  trace <- list()
  for (iteration in seq_len(policy$NewtonMaximumIterations)) {
    objective <- as.numeric(fn(parameter))
    gradient <- as.numeric(gr(parameter))
    hessian <- tryCatch(numDeriv::jacobian(
      gr, parameter, method = "Richardson"
    ), error = function(error) matrix(numeric(), 0L, 0L))
    metrics <- mfrmr_gtwsy_scale_metrics(
      parameter, objective, gradient, hessian
    )
    trace[[iteration]] <- data.frame(
      Iteration = iteration - 1L, Objective = objective,
      GradientMaximumAbsolute = metrics$RawMaximumAbsolute,
      NewtonDecrement = metrics$NewtonDecrement,
      StepAccepted = FALSE, StepScale = NA_real_, stringsAsFactors = FALSE
    )
    if (isTRUE(metrics$NewtonWhitenedAvailable) &&
        metrics$NewtonDecrement <= policy$NewtonDecrementTolerance) break
    if (!isTRUE(metrics$NewtonStepAvailable)) break
    direction <- -metrics$NewtonStep
    directional_derivative <- sum(gradient * direction)
    if (!is.finite(directional_derivative) ||
        directional_derivative >= 0) break
    accepted <- FALSE
    step_scale <- 1
    for (backtrack in 0:policy$NewtonMaximumBacktracks) {
      candidate <- parameter + step_scale * direction
      candidate_objective <- tryCatch(
        as.numeric(fn(candidate)), error = function(error) NA_real_
      )
      if (is.finite(candidate_objective) && candidate_objective <=
          objective + policy$NewtonArmijoConstant * step_scale *
            directional_derivative) {
        parameter <- candidate
        accepted <- TRUE
        break
      }
      step_scale <- step_scale * policy$NewtonBacktrackFactor
    }
    trace[[iteration]]$StepAccepted <- accepted
    trace[[iteration]]$StepScale <- if (accepted) step_scale else NA_real_
    if (!accepted) break
  }
  objective <- as.numeric(fn(parameter))
  gradient <- as.numeric(gr(parameter))
  hessian <- tryCatch(numDeriv::jacobian(
    gr, parameter, method = "Richardson"
  ), error = function(error) matrix(numeric(), 0L, 0L))
  list(
    Parameter = parameter, Objective = objective, Gradient = gradient,
    Hessian = hessian, Trace = do.call(rbind, trace)
  )
}

mfrmr_gtwta_reference <- function(fn, gr, parameter,
                                    policy = mfrmr_gtwta_tolerance_policy()) {
  starts <- mfrmr_gtwta_starts(parameter)
  algorithms <- c("nlminb", "BFGS", "Nelder-Mead")
  results <- list()
  index <- 0L
  for (start_id in names(starts)) {
    for (algorithm in algorithms) {
      index <- index + 1L
      result <- mfrmr_gtwta_solver_one(
        fn, gr, starts[[start_id]], algorithm, policy
      )
      results[[index]] <- c(list(
        StartId = start_id, Algorithm = algorithm
      ), result)
    }
  }
  rows <- do.call(rbind, lapply(results, function(result) data.frame(
    StartId = result$StartId, Algorithm = result$Algorithm,
    Returned = result$Returned, Code = result$Code,
    Objective = result$Objective,
    ParameterHash = if (result$Returned)
      mfrmr_gta_hash(unname(result$Parameter)) else "none",
    RuntimeSeconds = result$RuntimeSeconds, stringsAsFactors = FALSE
  )))
  available <- which(rows$Returned & is.finite(rows$Objective))
  if (length(available) == 0L) {
    return(list(
      State = "not_evaluable", Rows = rows, Sidecar = list(),
      SidecarHash = "none", ConsensusPassed = FALSE,
      DerivativeAgreementPassed = FALSE
    ))
  }
  best_index <- available[[which.min(rows$Objective[available])]]
  best <- results[[best_index]]
  polish <- mfrmr_gtwta_newton_polish(
    fn, gr, best$Parameter, policy
  )
  per_algorithm <- vapply(algorithms, function(algorithm) {
    values <- rows$Objective[rows$Algorithm == algorithm & rows$Returned]
    if (length(values) == 0L) NA_real_ else min(values)
  }, numeric(1L))
  tolerance <- policy$ObjectiveConsensusRelativeTolerance *
    max(1, abs(polish$Objective), abs(per_algorithm[is.finite(per_algorithm)]))
  consensus <- sum(is.finite(per_algorithm)) >=
    policy$MinimumConsensusAlgorithms &&
    max(abs(per_algorithm - polish$Objective), na.rm = TRUE) <= tolerance
  derivatives <- mfrmr_gtwta_derivative_audit(
    fn, gr, polish$Parameter, policy
  )
  state <- mfrmr_gtwta_stationarity_state(
    polish$Parameter, polish$Objective, polish$Gradient, polish$Hessian,
    derivatives$DerivativeAgreementPassed, consensus, policy
  )
  metrics <- mfrmr_gtwsy_scale_metrics(
    polish$Parameter, polish$Objective, polish$Gradient, polish$Hessian
  )
  sidecar <- list(
    Contract = "stationarity_high_accuracy_reference_sidecar_b1g6_v2",
    PolicyHash = policy$PolicyHash,
    SolverRows = within(rows, RuntimeSeconds <- NULL),
    SolverParameters = lapply(results, function(result) result$Parameter),
    AlgorithmBestObjectives = per_algorithm,
    PolishedParameter = polish$Parameter,
    PolishedObjective = polish$Objective,
    PolishedGradient = polish$Gradient,
    PolishedHessian = polish$Hessian,
    NewtonTrace = polish$Trace,
    FdGradient = derivatives$FdGradient,
    RichardsonGradient = derivatives$RichardsonGradient,
    FdHessian = derivatives$FdHessian,
    CentralDifferenceStepMultipliers =
      derivatives$CentralDifferenceStepMultipliers,
    CentralDifferenceGradients = derivatives$CentralDifferenceGradients,
    FiniteDifferenceStabilityScores = derivatives$StabilityScores,
    SelectedStepIndex = derivatives$SelectedStepIndex,
    SelectedStepExponent = derivatives$SelectedStepExponent,
    SelectedStepMultiplier = derivatives$SelectedStepMultiplier,
    FiniteDifferenceResolution = derivatives$FiniteDifferenceResolution,
    DerivativeComponentTolerance = derivatives$ComponentTolerance,
    DerivativeComponentPassed = derivatives$ComponentPassed,
    HessianSymmetryPassed = derivatives$HessianSymmetryPassed,
    StepSelectionUsesAutomaticGradient =
      derivatives$StepSelectionUsesAutomaticGradient
  )
  list(
    State = state, Rows = rows, Sidecar = sidecar,
    SidecarHash = mfrmr_gta_hash(sidecar),
    ConsensusPassed = consensus,
    ConsensusTolerance = tolerance,
    AlgorithmBestObjectiveRange = diff(range(per_algorithm, na.rm = TRUE)),
    DerivativeAgreementPassed = derivatives$DerivativeAgreementPassed,
    GradientRelativeDifference = derivatives$GradientRelativeDifference,
    CurvatureState = mfrmr_gtwta_curvature_state(polish$Hessian, policy),
    RawGradientMaximumAbsolute = metrics$RawMaximumAbsolute,
    NewtonDecrement = metrics$NewtonDecrement,
    PolishedObjective = polish$Objective,
    PolishedParameterHash = mfrmr_gta_hash(unname(polish$Parameter))
  )
}

mfrmr_gtwta_profile_boundary <- function(fn, gr, parameter, target_index,
                                           policy) {
  parameter <- as.numeric(parameter)
  target_index <- as.integer(target_index)
  if (length(target_index) != 1L || is.na(target_index) ||
      target_index < 1L || target_index > length(parameter)) {
    stop("One valid target log-SD index is required.", call. = FALSE)
  }
  free_index <- setdiff(seq_along(parameter), target_index)
  current <- parameter
  rows <- lapply(policy$BoundaryLogSdOffsets, function(offset) {
    target <- parameter[[target_index]] - offset
    start <- current[free_index]
    reconstruct <- function(free) {
      value <- current
      value[free_index] <- free
      value[[target_index]] <- target
      value
    }
    free_fn <- function(free) fn(reconstruct(free))
    free_gr <- function(free) gr(reconstruct(free))[free_index]
    fit <- tryCatch(stats::nlminb(
      start,
      free_fn, free_gr,
      control = list(
        eval.max = policy$SolverMaximumEvaluations,
        iter.max = policy$SolverMaximumIterations,
        rel.tol = policy$SolverRelativeTolerance,
        x.tol = policy$SolverXTolerance
      )
    ), error = function(error) NULL)
    returned <- !is.null(fit) && length(fit$par) == length(free_index) &&
      all(is.finite(fit$par)) && is.finite(fit$objective)
    polish <- if (returned) tryCatch(
      mfrmr_gtwta_newton_polish(free_fn, free_gr, fit$par, policy),
      error = function(error) NULL
    ) else NULL
    polished <- !is.null(polish) &&
      length(polish$Parameter) == length(free_index) &&
      is.finite(polish$Objective) && all(is.finite(c(
        polish$Parameter, polish$Gradient, polish$Hessian
      )))
    if (polished) current <<- reconstruct(polish$Parameter)
    gradient <- if (polished) as.numeric(gr(current)) else rep(NA_real_,
                                                               length(parameter))
    metrics <- if (polished) mfrmr_gtwsy_scale_metrics(
      polish$Parameter, polish$Objective, polish$Gradient, polish$Hessian
    ) else NULL
    curvature <- if (polished)
      mfrmr_gtwta_curvature_state(polish$Hessian, policy) else "not_evaluable"
    nuisance_stationary <- polished && (
      (identical(curvature, "positive_definite") &&
         isTRUE(metrics$NewtonWhitenedAvailable) &&
         metrics$NewtonDecrement <= policy$NewtonDecrementTolerance) ||
      (identical(curvature, "near_singular_or_semidefinite") &&
         isTRUE(metrics$RawAvailable) &&
         metrics$RawMaximumAbsolute <= policy$GradientAbsoluteTolerance)
    )
    data.frame(
      Offset = offset, TargetLogSd = target, Returned = polished,
      OptimizerCode = if (returned) as.integer(fit$convergence) else NA_integer_,
      Objective = if (polished) as.numeric(polish$Objective) else NA_real_,
      FreeGradientMaximumAbsolute = if (polished && length(free_index) > 0L)
        max(abs(gradient[free_index])) else NA_real_,
      FreeNewtonDecrement = if (polished &&
                                  isTRUE(metrics$NewtonWhitenedAvailable))
        metrics$NewtonDecrement else NA_real_,
      FreeCurvatureState = curvature,
      NuisanceStationarityPassed = nuisance_stationary,
      TargetGradient = if (polished) gradient[[target_index]] else NA_real_,
      ParameterHash = if (polished)
        mfrmr_gta_hash(unname(current)) else "none",
      stringsAsFactors = FALSE
    )
  })
  rows <- do.call(rbind, rows)
  available <- all(
    rows$Returned & rows$NuisanceStationarityPassed &
      is.finite(rows$Objective)
  )
  tolerance <- if (available) policy$BoundaryObjectiveRelativeTolerance *
    max(1, abs(rows$Objective)) else rep(NA_real_, nrow(rows))
  list(
    Rows = rows, Available = available,
    MonotoneTowardBoundary = available &&
      all(diff(rows$Objective) <= tolerance[-1L]),
    MaterialImprovementTowardBoundary = available &&
      rows$Objective[[1L]] - rows$Objective[[nrow(rows)]] > tolerance[[1L]],
    FinalParameter = current
  )
}

mfrmr_gtwta_contract <- function(stationarity_design_contract) {
  mfrmr_gtwta_require_primitives()
  if (!inherits(stationarity_design_contract, "mfrmr_gtwsz_contract") ||
      !identical(
        stationarity_design_contract$DesignContractHash,
        "278353d1668501d04dd3af4adc96dfcd39b232796057242418f89601b22b99ac"
      ) || isTRUE(stationarity_design_contract$CalibrationExecutionAuthorized)) {
    stop("The exact sealed b1g5 design is required.", call. = FALSE)
  }
  policy <- mfrmr_gtwta_tolerance_policy()
  analytic <- mfrmr_gtwta_analytic_audit(policy)
  if (!isTRUE(analytic$DerivativeAgreementReady) ||
      !isTRUE(analytic$AnalyticStateRecoveryReady)) {
    stop("Analytic reference calibration failed.", call. = FALSE)
  }
  sources <- data.frame(
    SourceId = c(
      "tmb_kristensen_2016", "tmb_derivative_documentation",
      "numderiv_manual", "nash_varadhan_2011", "nash_2014",
      "more_wild_2012", "shi_xie_xuan_nocedal_2022",
      "glmmtmb_troubleshooting", "self_liang_1987"
    ),
    Locator = c(
      "https://doi.org/10.18637/jss.v070.i05",
      "https://kaskr.github.io/adcomp/Introduction.html",
      "https://cran.r-project.org/web/packages/numDeriv/numDeriv.pdf",
      "https://doi.org/10.18637/jss.v043.i09",
      "https://doi.org/10.18637/jss.v060.i02",
      "https://doi.org/10.1145/2168773.2168777",
      "https://doi.org/10.1137/21M1452470",
      "https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html",
      "https://doi.org/10.1080/01621459.1987.10478472"
    ),
    Role = c(
      "automatic differentiation and Laplace objective",
      "TMB objective gradient and Hessian access",
      "independent Richardson derivatives",
      "multi-method optimization diagnostics",
      "optimization verification practice",
      "finite differences under deterministic computational noise",
      "adaptive differencing intervals balancing numerical errors",
      "restart alternate optimizer and Hessian diagnostics",
      "nonregular variance-component boundary"
    ),
    stringsAsFactors = FALSE
  )
  identity <- list(
    Contract = paste0(
      "gtheory_weak_information_glmmtmb_stationarity_reference_",
      "calibration_draft83d2b2b1g6_v2"
    ),
    UpstreamB1g5DesignContractHash =
      stationarity_design_contract$DesignContractHash,
    UpstreamB1g5ManifestHash =
      "0dbe9e92bed7baa27b6c5f29bed0759a789bcc02c285bd77d749a9cc9666e4d0",
    TolerancePolicy = policy, AnalyticAuditHash = analytic$AuditHash,
    NonreservedReplicates = c(901L, 902L),
    ReservedReplicates = c(2:3, 101:125, 201:300, 501:700),
    NonreservedScenarioIds = c(
      "GT-WI-baseline_complete-exact_zero",
      "GT-WI-baseline_complete-reference_1200"
    ),
    NonreservedMethodId = "glmmTMB_reml",
    NonreservedModelRoles = c("full", "reduced"),
    NonreservedObjectiveCount = 4L,
    ReferenceAlgorithms = c("nlminb", "BFGS", "Nelder-Mead"),
    ReferenceStartIds = names(mfrmr_gtwta_starts(c(0, 0))),
    ReferenceSolverRunsPerObjective = 9L,
    BoundaryProfileFullModelOnly = TRUE,
    GeneratingTruthMayLabelStationarity = FALSE,
    B1g4ObservedMagnitudesMaySetTolerance = FALSE,
    CalibrationReplicatesMayBeRead = FALSE,
    ReplayMaySelectCandidateCutoff = FALSE,
    Sources = sources,
    PackageVersions = c(
      glmmTMB = as.character(utils::packageVersion("glmmTMB")),
      TMB = as.character(utils::packageVersion("TMB")),
      numDeriv = as.character(utils::packageVersion("numDeriv")),
      R = as.character(getRversion())
    ),
    FunctionHashes = mfrmr_gtwta_function_hashes()
  )
  structure(c(identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    AnalyticReferenceReady = TRUE,
    ReferenceToleranceContractFrozen = TRUE,
    NonreservedReplayAuthorized = TRUE,
    NonreservedReplayReady = FALSE,
    ReferenceToleranceFrozen = FALSE,
    StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE, CalibrationResultsViewed = FALSE,
    FullExecutionAuthorized = FALSE, BootstrapOperatingCharacteristicsReady = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE, AnalyticAudit = analytic
  )), class = "mfrmr_gtwta_contract")
}

mfrmr_gtwta_manifest <- function(contract, registry = mfrmr_gtw_registry()) {
  if (!inherits(contract, "mfrmr_gtwta_contract") ||
      !isTRUE(contract$NonreservedReplayAuthorized) ||
      isTRUE(contract$CalibrationExecutionAuthorized)) {
    stop("An intact b1g6 reference contract is required.", call. = FALSE)
  }
  cells <- registry$Cells[match(
    contract$NonreservedScenarioIds, registry$Cells$ScenarioId
  ), , drop = FALSE]
  rows <- data.frame(
    ScenarioId = cells$ScenarioId,
    Replicate = contract$NonreservedReplicates,
    DatasetId = sprintf("%s/R%04d", cells$ScenarioId,
                        contract$NonreservedReplicates),
    Seed = cells$SeedStart + contract$NonreservedReplicates - 1L,
    DesignId = cells$DesignId, VarianceId = cells$VarianceId,
    MethodId = contract$NonreservedMethodId,
    Likelihood = "REML", ModelRoleCount = 2L,
    ReferenceSolverRunsPerObjective = contract$ReferenceSolverRunsPerObjective,
    CalibrationUse = FALSE, CandidateCutoffSelectionPermitted = FALSE,
    CalibrationExecutionAuthorized = FALSE, stringsAsFactors = FALSE
  )
  if (any(rows$Replicate %in% contract$ReservedReplicates) ||
      anyDuplicated(rows$Seed) || nrow(rows) != 2L) {
    stop("The b1g6 replay manifest collides with a reserved seed band.",
         call. = FALSE)
  }
  identity <- list(
    Contract = "stationarity_reference_nonreserved_manifest_b1g6_v1",
    ReferenceContractHash = contract$ContractHash,
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
  )), class = "mfrmr_gtwta_manifest")
}

mfrmr_gtwta_target_theta_index <- function(fit, target = "Rater") {
  terms <- names(fit$modelInfo$reTrms$cond$cnms)
  target_position <- match(target, terms)
  top_theta <- which(names(fit$fit$par) == "theta")
  if (is.na(target_position) || length(top_theta) != length(terms)) {
    stop("Cannot map the target random intercept to a top-level theta.",
         call. = FALSE)
  }
  as.integer(top_theta[[target_position]])
}

mfrmr_gtwta_fit_objective <- function(formula, data, reml = TRUE) {
  captured <- mfrmr_gtwd_capture(glmmTMB::glmmTMB(
    formula = formula, data = data,
    family = stats::gaussian(link = "identity"),
    ziformula = ~ 0, dispformula = ~ 1, REML = isTRUE(reml),
    control = glmmTMB::glmmTMBControl()
  ))
  list(
    Fit = captured$Fit, Warnings = captured$Warnings,
    Messages = captured$Messages
  )
}

mfrmr_gtwta_anchored_objective <- function(fit) {
  if (is.null(fit$obj$env$last.par.best) ||
      length(fit$obj$env$random) == 0L) {
    stop("A fitted TMB Laplace objective with random effects is required.",
         call. = FALSE)
  }
  reported_parameter <- fit$fit$par
  invisible(fit$obj$fn(reported_parameter))
  random_start_anchor <- fit$obj$env$last.par.best
  anchored_fn <- function(parameter) {
    fit$obj$env$last.par.best <- random_start_anchor
    fit$obj$fn(parameter)
  }
  anchored_gr <- function(parameter) {
    fit$obj$env$last.par.best <- random_start_anchor
    fit$obj$gr(parameter)
  }
  identity <- list(
    Contract = "tmb_laplace_random_start_anchor_b1g6_v1",
    RandomStartAnchorHash = mfrmr_gta_hash(unname(random_start_anchor)),
    RandomStartExpression = paste(
      deparse(fit$obj$env$random.start, width.cutoff = 500L), collapse = ""
    ),
    InnerMethod = fit$obj$env$inner.method,
    InnerControl = fit$obj$env$inner.control,
    RandomEffectDimension = length(fit$obj$env$random),
    OuterParameterDimension = length(reported_parameter),
    ResetBeforeEveryObjectiveEvaluation = TRUE,
    ResetBeforeEveryGradientEvaluation = TRUE
  )
  c(identity, list(Fn = anchored_fn, Gr = anchored_gr))
}

mfrmr_gtwta_execute <- function(contract, manifest,
                                  registry = mfrmr_gtw_registry()) {
  if (!inherits(contract, "mfrmr_gtwta_contract") ||
      !inherits(manifest, "mfrmr_gtwta_manifest") ||
      !identical(manifest$ReferenceContractHash, contract$ContractHash) ||
      !isTRUE(manifest$ExecutionAuthorized) || isTRUE(manifest$CalibrationUse) ||
      any(manifest$Rows$Replicate %in% contract$ReservedReplicates)) {
    stop("The exact nonreserved b1g6 replay is not authorized.", call. = FALSE)
  }
  policy <- contract$TolerancePolicy
  outputs <- list()
  row_index <- 0L
  dataset_hashes <- character(nrow(manifest$Rows))
  for (dataset_index in seq_len(nrow(manifest$Rows))) {
    manifest_row <- manifest$Rows[dataset_index, , drop = FALSE]
    generation <- mfrmr_gtw_generate(
      registry, manifest_row$ScenarioId[[1L]], manifest_row$Replicate[[1L]]
    )
    prefit <- mfrmr_gtd3_prefit_one(generation)
    if (!isTRUE(prefit$PreFitEligible)) {
      stop("The b1g6 nonreserved replay failed structural pre-fit.",
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
      fit_result <- tryCatch(mfrmr_gtwta_fit_objective(
        formulas[[model_role]], data, reml = TRUE
      ), error = function(error) error)
      if (inherits(fit_result, "error")) {
        outputs[[row_index]] <- list(
          Row = data.frame(
            DatasetId = manifest_row$DatasetId, ScenarioId = manifest_row$ScenarioId,
            Replicate = manifest_row$Replicate, ModelRole = model_role,
            FitReturned = FALSE, ReferenceState = "not_evaluable",
            ConsensusPassed = FALSE, DerivativeAgreementPassed = FALSE,
            CurvatureState = "not_evaluable", BoundaryState = "not_evaluable",
            PolishedObjective = NA_real_, RawGradientMaximumAbsolute = NA_real_,
            NewtonDecrement = NA_real_, SidecarHash = "none",
            CalibrationUse = FALSE, stringsAsFactors = FALSE
          ), Sidecar = list()
        )
        next
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
          reference$Sidecar$PolishedParameter,
          target_index, policy
        )
      }
      boundary_state <- if (is.null(boundary)) "not_applicable" else if (
        !isTRUE(boundary$Available)) "not_evaluable" else if (
          isTRUE(boundary$MonotoneTowardBoundary) &&
          isTRUE(boundary$MaterialImprovementTowardBoundary)
        ) "boundary_direction_supported" else "finite_interior_supported"
      sidecar <- list(
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
      sidecar_hash <- mfrmr_gta_hash(sidecar)
      outputs[[row_index]] <- list(
        Row = data.frame(
          DatasetId = manifest_row$DatasetId, ScenarioId = manifest_row$ScenarioId,
          Replicate = manifest_row$Replicate, ModelRole = model_role,
          FitReturned = TRUE, ReferenceState = reference$State,
          ConsensusPassed = reference$ConsensusPassed,
          DerivativeAgreementPassed = reference$DerivativeAgreementPassed,
          CurvatureState = reference$CurvatureState,
          BoundaryState = boundary_state,
          PolishedObjective = reference$PolishedObjective,
          RawGradientMaximumAbsolute = reference$RawGradientMaximumAbsolute,
          NewtonDecrement = reference$NewtonDecrement,
          SidecarHash = sidecar_hash, CalibrationUse = FALSE,
          stringsAsFactors = FALSE
        ), Sidecar = sidecar
      )
      dataset_outputs[[model_role]] <- outputs[[row_index]]
    }
    full <- dataset_outputs$full
    reduced <- dataset_outputs$reduced
    if (!is.null(full) && !is.null(reduced) &&
        identical(full$Row$BoundaryState, "boundary_direction_supported") &&
        is.finite(full$Row$PolishedObjective) &&
        is.finite(reduced$Row$PolishedObjective)) {
      profile_final <- tail(full$Sidecar$BoundaryProfile$Objective, 1L)
      tolerance <- policy$BoundaryObjectiveRelativeTolerance * max(
        1, abs(profile_final), abs(reduced$Row$PolishedObjective)
      )
      matched <- abs(profile_final - reduced$Row$PolishedObjective) <= tolerance
      full$Row$BoundaryState <- if (matched)
        "boundary_limit_supported" else "boundary_profile_not_reduced_matched"
      if (matched) full$Row$ReferenceState <- "boundary_limit"
      outputs[[row_index - 1L]] <- full
    }
  }
  rows <- do.call(rbind, lapply(outputs, `[[`, "Row"))
  row.names(rows) <- NULL
  sidecars <- lapply(outputs, `[[`, "Sidecar")
  sidecar_valid <- vapply(seq_along(sidecars), function(index) {
    identical(mfrmr_gta_hash(sidecars[[index]]), rows$SidecarHash[[index]])
  }, logical(1L))
  ready <- nrow(rows) == manifest$ObjectiveCount && all(rows$FitReturned) &&
    all(rows$ConsensusPassed) && all(rows$DerivativeAgreementPassed) &&
    all(!rows$ReferenceState %in% c("reference_unresolved", "not_evaluable")) &&
    all(sidecar_valid) && all(!rows$CalibrationUse)
  scientific_rows <- rows
  identity <- list(
    Contract = "stationarity_reference_nonreserved_execution_b1g6_v1",
    ReferenceContractHash = contract$ContractHash,
    ManifestHash = manifest$ManifestHash,
    GeneratorHashes = dataset_hashes,
    Rows = scientific_rows,
    SidecarHashes = rows$SidecarHash
  )
  structure(c(identity, list(
    ExecutionHash = mfrmr_gta_hash(identity), Sidecars = sidecars,
    ExactAccountingPassed = nrow(rows) == manifest$ObjectiveCount,
    FitReturnCount = sum(rows$FitReturned),
    ReferenceResolvedCount = sum(!rows$ReferenceState %in%
      c("reference_unresolved", "not_evaluable")),
    ConsensusPassCount = sum(rows$ConsensusPassed),
    DerivativeAgreementPassCount = sum(rows$DerivativeAgreementPassed),
    SidecarValidationPassed = all(sidecar_valid),
    NonreservedReplayReady = ready,
    ReferenceToleranceFrozen = ready,
    StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE, CalibrationResultsViewed = FALSE,
    FullExecutionAuthorized = FALSE,
    BootstrapOperatingCharacteristicsReady = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwta_execution")
}

mfrmr_gtwta_execution_hash_valid <- function(execution) {
  fields <- c(
    "Contract", "ReferenceContractHash", "ManifestHash", "GeneratorHashes",
    "Rows", "SidecarHashes"
  )
  inherits(execution, "mfrmr_gtwta_execution") &&
    all(fields %in% names(execution)) && identical(
      execution$ExecutionHash, mfrmr_gta_hash(execution[fields])
    ) && length(execution$Sidecars) == nrow(execution$Rows) &&
    all(vapply(seq_along(execution$Sidecars), function(index) {
      identical(mfrmr_gta_hash(execution$Sidecars[[index]]),
                execution$Rows$SidecarHash[[index]])
    }, logical(1L)))
}

mfrmr_gtwta_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwta_tolerance_policy", "mfrmr_gtwta_softplus",
    "mfrmr_gtwta_analytic_registry", "mfrmr_gtwta_analytic_eval",
    "mfrmr_gtwta_derivative_audit", "mfrmr_gtwta_curvature_state",
    "mfrmr_gtwta_stationarity_state", "mfrmr_gtwta_analytic_audit",
    "mfrmr_gtwta_solver_one", "mfrmr_gtwta_starts",
    "mfrmr_gtwta_newton_polish", "mfrmr_gtwta_reference",
    "mfrmr_gtwta_profile_boundary", "mfrmr_gtwta_contract",
    "mfrmr_gtwta_manifest", "mfrmr_gtwta_target_theta_index",
    "mfrmr_gtwta_fit_objective", "mfrmr_gtwta_anchored_objective",
    "mfrmr_gtwta_execute",
    "mfrmr_gtwta_execution_hash_valid"
  )
  reference_environment <- environment(mfrmr_gtwta_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwta_function_hash(get(
      name, envir = reference_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}
