# Draft.83d2b2b1g10 lme4 ML/REML reference coverage.
#
# Repository-internal only. This file implements a box-constrained,
# likelihood-mode-preserving lme4 reference route and may execute only the
# nonreserved replicates 901 and 902. It cannot authorize calibration.

mfrmr_gtwad_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtwac_function_hashes",
    "mfrmr_gtw_registry", "mfrmr_gtw_generate",
    "mfrmr_gtd3_prefit_one", "mfrmr_gtwd_reduced_formula",
    "mfrmr_gtwd_capture"
  )
  coverage_environment <- environment(mfrmr_gtwad_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = coverage_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the b1g9 chain before b1g10 lme4 coverage: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwad_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtwad_policy <- function() {
  epsilon <- .Machine$double.eps
  identity <- list(
    Contract = "lme4_box_reference_policy_draft83d2b2b1g10_v3",
    Arithmetic = "IEEE_754_binary64_as_exposed_by_R_machine_double_eps",
    LowerBound = 0,
    ActiveSetTolerance = 2^10 * sqrt(epsilon),
    GradientAbsoluteTolerance = 2^10 * sqrt(epsilon),
    NewtonDecrementTolerance = 2^10 * sqrt(epsilon),
    DerivativeRelativeTolerance = 2^12 * epsilon^(2 / 3),
    DerivativeStabilityMultiplier = 4,
    CentralDifferenceBalancingScale = epsilon^(1 / 3),
    DerivativeStepExponents = -4L:8L,
    HessianSymmetryRelativeTolerance = 2^12 * epsilon^(2 / 3),
    CurvatureRelativeTolerance = 2^12 * epsilon^(2 / 3),
    ObjectiveConsensusRelativeTolerance = 2^8 * epsilon^(2 / 3),
    ObjectiveReplayRelativeTolerance = 2^10 * epsilon,
    BoundaryObjectiveRelativeTolerance = 2^8 * epsilon^(2 / 3),
    SolverAlgorithms = c("nlminb", "L-BFGS-B", "bobyqa"),
    MinimumConsensusAlgorithms = 3L,
    SolverMaximumIterations = 10000L,
    SolverMaximumEvaluations = 20000L,
    SolverRelativeTolerance = 1e-12,
    SolverXTolerance = 1e-10,
    BOBYQARhoEnd = 1e-10,
    NewtonMaximumIterations = 12L,
    OracleNewtonMaximumIterations = 3L,
    NewtonMaximumBacktracks = 30L,
    NewtonArmijoConstant = 1e-4,
    NewtonBacktrackFactor = 0.5,
    BoundaryThetaFractions = c(1, 0.75, 0.5, 0.25, 0.1, 0.025, 0),
    BoundaryFirstOrderSufficiencyClaim = FALSE,
    CandidateCutoffUse = FALSE,
    Lme4DefaultCutoffUse = FALSE
  )
  structure(c(identity, list(
    PolicyHash = mfrmr_gta_hash(identity), PolicyFrozen = TRUE
  )), class = "mfrmr_gtwad_policy")
}

mfrmr_gtwad_source_registry <- function() {
  data.frame(
    SourceId = c(
      "lme4_lmer_current", "lme4_modular_current",
      "lme4_control_current", "lme4_convergence_current",
      "lme4_singularity_current", "minqa_bobyqa_current"
    ),
    Locator = c(
      "https://lme4.github.io/lme4/reference/lmer.html",
      "https://lme4.github.io/lme4/articles/lmer.pdf",
      "https://lme4.github.io/lme4/reference/lmerControl.html",
      "https://lme4.github.io/lme4/reference/convergence.html",
      "https://lme4.github.io/lme4/reference/isSingular.html",
      "https://cran.r-project.org/package=minqa"
    ),
    ContractRole = c(
      "theta-only profiled objective identity and nonnegative lower bounds",
      "modular deviance construction and optimizer separation",
      "optimizer controls and restart identities",
      "gradient and Hessian checks are diagnostic rather than proof",
      "boundary singularity is statistically nonregular",
      "independent bound-constrained derivative-free solver"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwad_sparse_oracle <- function(fit, theta,
                                       reml = lme4::isREML(fit)) {
  structure_audit <- mfrmr_gtwac_simple_intercept_structure(fit)
  if (!isTRUE(structure_audit$SimpleIndependentRandomIntercepts)) {
    stop(
      "The b1g10 sparse oracle supports zero-offset unweighted independent ",
      "random intercepts only.", call. = FALSE
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
    structure_audit$ZtList, function(value) Matrix::t(value)
  )
  a <- Matrix::Diagonal(n)
  for (index in seq_along(theta)) {
    a <- a + theta[[index]]^2 * Matrix::tcrossprod(z_list[[index]])
  }
  factor <- tryCatch(
    Matrix::Cholesky(a, LDL = FALSE, perm = TRUE, super = TRUE),
    error = function(error) NULL
  )
  if (is.null(factor)) {
    return(list(
      Available = FALSE, Objective = NA_real_,
      Gradient = rep(NA_real_, length(theta)), Theta = theta
    ))
  }
  a_inverse_x <- as.matrix(Matrix::solve(factor, x))
  a_inverse_y <- as.numeric(Matrix::solve(factor, y))
  b <- crossprod(x, a_inverse_x)
  b_inverse <- tryCatch(solve(b), error = function(error) NULL)
  if (is.null(b_inverse)) {
    return(list(
      Available = FALSE, Objective = NA_real_,
      Gradient = rep(NA_real_, length(theta)), Theta = theta
    ))
  }
  beta <- b_inverse %*% crossprod(x, a_inverse_y)
  residual <- y - as.numeric(x %*% beta)
  q <- as.numeric(Matrix::solve(factor, residual))
  rss <- sum(residual * q)
  factor_l <- Matrix::expand(factor)$L
  log_determinant_a <- 2 * sum(log(Matrix::diag(factor_l)))
  if (!is.finite(rss) || rss <= 0 || !is.finite(log_determinant_a)) {
    return(list(
      Available = FALSE, Objective = NA_real_,
      Gradient = rep(NA_real_, length(theta)), Theta = theta
    ))
  }
  if (isTRUE(reml)) {
    degrees <- n - p
    log_determinant_b <- as.numeric(
      determinant(b, logarithm = TRUE)$modulus
    )
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
    a_inverse_z <- as.matrix(Matrix::solve(factor, z))
    trace_basis_z <- if (isTRUE(reml)) {
      a_inverse_z - a_inverse_x %*% b_inverse %*%
        crossprod(x, a_inverse_z)
    } else {
      a_inverse_z
    }
    trace_term <- 2 * theta[[index]] * sum(z * trace_basis_z)
    quadratic_term <- 2 * theta[[index]] * sum(crossprod(z, q)^2)
    trace_term - degrees * quadratic_term / rss
  }, numeric(1L))
  names(gradient) <- structure_audit$ThetaNames
  list(
    Available = TRUE, Objective = as.numeric(objective),
    Gradient = gradient,
    Theta = stats::setNames(theta, structure_audit$ThetaNames),
    BetaProfile = as.numeric(beta), ResidualQuadratic = rss,
    LogDeterminantA = log_determinant_a,
    LogDeterminantB = log_determinant_b,
    DegreesOfFreedom = degrees,
    ObjectiveScale = if (isTRUE(reml)) {
      "profiled_reml_criterion_theta_only"
    } else {
      "minus_two_profiled_ml_loglik_theta_only"
    },
    SparseCholesky = TRUE, FixedEffectsProfiledOut = TRUE,
    ResidualScaleProfiledOut = TRUE
  )
}

mfrmr_gtwad_box_gradient <- function(fn, parameter, lower, policy) {
  parameter <- as.numeric(parameter)
  lower <- rep_len(as.numeric(lower), length(parameter))
  if (length(parameter) == 0L || any(!is.finite(parameter)) ||
      any(!is.finite(lower)) || any(parameter < lower)) {
    stop("A finite parameter inside finite lower bounds is required.",
         call. = FALSE)
  }
  objective <- as.numeric(fn(parameter))
  parameter_scale <- pmax(1, abs(parameter))
  multipliers <- policy$CentralDifferenceBalancingScale *
    2^policy$DerivativeStepExponents
  component_results <- lapply(seq_along(parameter), function(component) {
    values <- vapply(multipliers, function(multiplier) {
      step <- multiplier * parameter_scale[[component]]
      if (parameter[[component]] - step >= lower[[component]]) {
        plus <- parameter
        minus <- parameter
        plus[[component]] <- plus[[component]] + step
        minus[[component]] <- minus[[component]] - step
        return((fn(plus) - fn(minus)) / (2 * step))
      }
      points <- lapply(0:4, function(index) {
        value <- parameter
        value[[component]] <- parameter[[component]] + index * step
        value
      })
      objectives <- vapply(points, fn, numeric(1L))
      sum(c(-25, 48, -36, 16, -3) * objectives) / (12 * step)
    }, numeric(1L))
    interior <- if (length(values) >= 3L) 2L:(length(values) - 1L) else integer()
    stability <- if (length(interior) > 0L && all(is.finite(values))) {
      vapply(interior, function(index) {
        denominator <- max(1, abs(values[index - 1L]), abs(values[index]),
                           abs(values[index + 1L]))
        max(abs(values[index] - values[index - 1L]),
            abs(values[index + 1L] - values[index])) / denominator
      }, numeric(1L))
    } else numeric()
    selected <- if (length(stability) > 0L && all(is.finite(stability))) {
      interior[[which.min(stability)]]
    } else NA_integer_
    if (is.na(selected)) {
      return(list(
        Gradient = NA_real_, Resolution = NA_real_, Selected = NA_integer_,
        Route = "not_evaluable", Values = values, Stability = stability
      ))
    }
    step <- multipliers[[selected]] * parameter_scale[[component]]
    roundoff <- 2 * .Machine$double.eps * max(1, abs(objective)) / step
    resolution <- max(
      abs(values[selected] - values[selected - 1L]),
      abs(values[selected + 1L] - values[selected]), roundoff
    )
    list(
      Gradient = values[[selected]], Resolution = resolution,
      Selected = selected,
      Route = if (parameter[[component]] - step >= lower[[component]]) {
        "central"
      } else {
        "forward_five_point"
      },
      Values = values, Stability = stability
    )
  })
  gradient <- vapply(component_results, `[[`, numeric(1L), "Gradient")
  resolution <- vapply(component_results, `[[`, numeric(1L), "Resolution")
  selected <- vapply(component_results, `[[`, integer(1L), "Selected")
  routes <- vapply(component_results, `[[`, character(1L), "Route")
  list(
    Objective = objective, Gradient = gradient, Resolution = resolution,
    SelectedStepIndex = selected,
    SelectedStepExponent = ifelse(
      is.na(selected), NA_integer_, policy$DerivativeStepExponents[selected]
    ),
    Routes = routes, StepMultipliers = multipliers,
    ComponentResults = component_results,
    Available = all(is.finite(c(gradient, resolution)))
  )
}

mfrmr_gtwad_derivative_audit <- function(fn, parameter, lower, policy) {
  adaptive <- mfrmr_gtwad_box_gradient(fn, parameter, lower, policy)
  richardson <- tryCatch(
    as.numeric(numDeriv::grad(fn, parameter, method = "Richardson")),
    error = function(error) rep(NA_real_, length(parameter))
  )
  hessian <- tryCatch(
    as.matrix(numDeriv::hessian(fn, parameter, method = "Richardson")),
    error = function(error) matrix(numeric(), 0L, 0L)
  )
  hessian_available <- is.matrix(hessian) &&
    identical(dim(hessian), rep(length(parameter), 2L)) &&
    all(is.finite(hessian))
  symmetry <- if (hessian_available) max(abs(hessian - t(hessian))) else NA_real_
  symmetry_tolerance <- if (hessian_available) {
    policy$HessianSymmetryRelativeTolerance * max(1, abs(hessian))
  } else NA_real_
  component_tolerance <- if (adaptive$Available && all(is.finite(richardson))) {
    pmax(
      policy$DerivativeRelativeTolerance *
        pmax(1, abs(adaptive$Gradient), abs(richardson)),
      policy$DerivativeStabilityMultiplier * adaptive$Resolution
    )
  } else rep(NA_real_, length(parameter))
  component_passed <- adaptive$Available && all(is.finite(richardson)) &&
    all(abs(adaptive$Gradient - richardson) <= component_tolerance)
  list(
    Adaptive = adaptive, RichardsonGradient = richardson,
    Hessian = hessian, HessianAvailable = hessian_available,
    HessianSymmetryResidual = symmetry,
    HessianSymmetryTolerance = symmetry_tolerance,
    HessianSymmetryPassed = hessian_available &&
      symmetry <= symmetry_tolerance,
    ComponentTolerance = component_tolerance,
    GradientAgreementPassed = component_passed,
    DerivativeAgreementPassed = component_passed && hessian_available &&
      symmetry <= symmetry_tolerance
  )
}

mfrmr_gtwad_kkt_audit <- function(parameter, gradient, hessian, lower,
                                   policy) {
  parameter <- as.numeric(parameter)
  gradient <- as.numeric(gradient)
  lower <- rep_len(as.numeric(lower), length(parameter))
  hessian <- as.matrix(hessian)
  valid <- length(parameter) > 0L && length(gradient) == length(parameter) &&
    length(lower) == length(parameter) && all(is.finite(c(
      parameter, gradient, lower
    ))) && identical(dim(hessian), rep(length(parameter), 2L)) &&
    all(is.finite(hessian)) && all(parameter >= lower)
  if (!valid) {
    return(list(
      Available = FALSE, KKTPassed = FALSE,
      FreeCurvatureState = "not_evaluable",
      NewtonDecrement = NA_real_
    ))
  }
  scale <- pmax(1, abs(parameter), abs(lower))
  active <- parameter - lower <= policy$ActiveSetTolerance * scale
  free <- !active
  gradient_tolerance <- policy$GradientAbsoluteTolerance *
    pmax(1, abs(gradient))
  free_pass <- !any(free) || all(abs(gradient[free]) <= gradient_tolerance[free])
  active_pass <- !any(active) || all(
    gradient[active] >= -gradient_tolerance[active]
  )
  free_hessian <- hessian[free, free, drop = FALSE]
  eigenvalues <- if (any(free)) tryCatch(eigen(
    (free_hessian + t(free_hessian)) / 2,
    symmetric = TRUE, only.values = TRUE
  )$values, error = function(error) numeric()) else numeric()
  curvature_tolerance <- if (length(eigenvalues) > 0L) {
    policy$CurvatureRelativeTolerance * max(1, abs(eigenvalues))
  } else 0
  curvature <- if (!any(free)) {
    "vacuous_no_free_coordinates"
  } else if (length(eigenvalues) != sum(free) || !all(is.finite(eigenvalues))) {
    "not_evaluable"
  } else if (min(eigenvalues) > curvature_tolerance) {
    "positive_definite"
  } else if (min(eigenvalues) < -curvature_tolerance) {
    "indefinite"
  } else {
    "near_singular_or_semidefinite"
  }
  newton_decrement <- if (any(free) && identical(curvature, "positive_definite")) {
    value <- tryCatch(
      sum(gradient[free] * solve(free_hessian, gradient[free])),
      error = function(error) NA_real_
    )
    if (is.finite(value) && value >= 0) sqrt(value) else NA_real_
  } else if (!any(free)) 0 else NA_real_
  newton_pass <- is.finite(newton_decrement) &&
    newton_decrement <= policy$NewtonDecrementTolerance
  numerical_free_pass <- free_pass || newton_pass
  list(
    Available = TRUE, Active = active, Free = free,
    ActiveCount = sum(active), FreeCount = sum(free),
    FreeGradientMaximumAbsolute = if (any(free)) {
      max(abs(gradient[free]))
    } else 0,
    ActiveGradientMinimum = if (any(active)) min(gradient[active]) else NA_real_,
    FreeRawFirstOrderPassed = free_pass,
    FreeCurvatureScaledFirstOrderPassed = newton_pass,
    FreeFirstOrderPassed = numerical_free_pass,
    ActiveOneSidedFirstOrderPassed = active_pass,
    FreeCurvatureState = curvature,
    FreeCurvatureEigenvalues = eigenvalues,
    NewtonDecrement = newton_decrement,
    NewtonDecrementPassed = newton_pass,
    BoundaryFirstOrderSufficiencyClaim = FALSE,
    RawKKTPassed = free_pass && active_pass,
    KKTPassed = numerical_free_pass && active_pass
  )
}

mfrmr_gtwad_solver_one <- function(fn, start, lower, algorithm, policy) {
  start <- pmax(as.numeric(start), as.numeric(lower))
  lower <- rep_len(as.numeric(lower), length(start))
  started <- proc.time()[["elapsed"]]
  result <- tryCatch({
    if (identical(algorithm, "nlminb")) {
      fit <- stats::nlminb(
        start, fn, lower = lower,
        control = list(
          eval.max = policy$SolverMaximumEvaluations,
          iter.max = policy$SolverMaximumIterations,
          rel.tol = policy$SolverRelativeTolerance,
          x.tol = policy$SolverXTolerance
        )
      )
      list(Parameter = fit$par, Objective = fit$objective,
           Code = as.integer(fit$convergence), Message = fit$message)
    } else if (identical(algorithm, "L-BFGS-B")) {
      fit <- stats::optim(
        start, fn, method = "L-BFGS-B", lower = lower,
        control = list(
          maxit = policy$SolverMaximumIterations,
          factr = 100, pgtol = policy$GradientAbsoluteTolerance
        )
      )
      list(Parameter = fit$par, Objective = fit$value,
           Code = as.integer(fit$convergence), Message = fit$message)
    } else if (identical(algorithm, "bobyqa")) {
      rho_begin <- max(1e-3, min(0.2, max(0.01, max(abs(start)) / 5)))
      fit <- minqa::bobyqa(
        start, fn, lower = lower, upper = rep(Inf, length(start)),
        control = list(
          maxfun = policy$SolverMaximumEvaluations,
          rhobeg = rho_begin, rhoend = policy$BOBYQARhoEnd
        )
      )
      list(Parameter = fit$par, Objective = fit$fval,
           Code = as.integer(fit$ierr), Message = fit$msg)
    } else {
      stop("Unknown b1g10 solver algorithm.", call. = FALSE)
    }
  }, error = function(error) list(
    Parameter = numeric(), Objective = NA_real_, Code = NA_integer_,
    Message = conditionMessage(error)
  ))
  parameter <- as.numeric(result$Parameter)
  returned <- length(parameter) == length(start) &&
    all(is.finite(parameter)) && is.finite(result$Objective) &&
    all(parameter >= lower)
  list(
    Returned = returned, Parameter = parameter,
    Objective = as.numeric(result$Objective), Code = result$Code,
    Message = as.character(result$Message),
    RuntimeSeconds = proc.time()[["elapsed"]] - started
  )
}

mfrmr_gtwad_starts <- function(parameter, lower) {
  parameter <- as.numeric(parameter)
  lower <- rep_len(as.numeric(lower), length(parameter))
  direction <- rep(c(-1, 1), length.out = length(parameter)) /
    sqrt(max(1, length(parameter)))
  perturbation <- 0.05 * pmax(1, abs(parameter)) * direction
  list(
    reported = pmax(parameter, lower),
    deterministic_plus = pmax(parameter + perturbation, lower),
    deterministic_minus = pmax(parameter - perturbation, lower)
  )
}

mfrmr_gtwad_projected_newton <- function(fn, parameter, lower, policy) {
  parameter <- pmax(as.numeric(parameter), as.numeric(lower))
  lower <- rep_len(as.numeric(lower), length(parameter))
  trace <- list()
  for (iteration in seq_len(policy$NewtonMaximumIterations)) {
    objective <- as.numeric(fn(parameter))
    gradient <- tryCatch(as.numeric(numDeriv::grad(
      fn, parameter, method = "Richardson"
    )), error = function(error) rep(NA_real_, length(parameter)))
    hessian <- tryCatch(as.matrix(numDeriv::hessian(
      fn, parameter, method = "Richardson"
    )), error = function(error) matrix(numeric(), 0L, 0L))
    kkt <- mfrmr_gtwad_kkt_audit(
      parameter, gradient, hessian, lower, policy
    )
    trace[[iteration]] <- data.frame(
      Iteration = iteration - 1L, Objective = objective,
      ActiveCount = if (isTRUE(kkt$Available)) kkt$ActiveCount else NA_integer_,
      FreeGradientMaximumAbsolute = if (isTRUE(kkt$Available)) {
        kkt$FreeGradientMaximumAbsolute
      } else NA_real_,
      NewtonDecrement = kkt$NewtonDecrement,
      KKTPassed = isTRUE(kkt$KKTPassed), StepAccepted = FALSE,
      StepScale = NA_real_, stringsAsFactors = FALSE
    )
    if (isTRUE(kkt$KKTPassed) && isTRUE(kkt$NewtonDecrementPassed) &&
        kkt$FreeCurvatureState %in%
          c("positive_definite", "vacuous_no_free_coordinates")) break
    if (!isTRUE(kkt$Available)) break
    working_free <- kkt$Free | (kkt$Active & gradient < 0)
    if (!any(working_free)) break
    free_hessian <- hessian[working_free, working_free, drop = FALSE]
    free_gradient <- gradient[working_free]
    direction_free <- tryCatch(
      -solve(free_hessian, free_gradient), error = function(error) numeric()
    )
    if (length(direction_free) != sum(working_free) ||
        any(!is.finite(direction_free))) break
    direction <- rep(0, length(parameter))
    direction[working_free] <- direction_free
    directional_derivative <- sum(gradient * direction)
    if (!is.finite(directional_derivative) || directional_derivative >= 0) break
    maximum_scale <- 1
    negative <- direction < 0
    if (any(negative)) {
      maximum_scale <- min(1, 0.99 * min(
        (parameter[negative] - lower[negative]) / -direction[negative]
      ))
    }
    step_scale <- maximum_scale
    accepted <- FALSE
    for (backtrack in 0:policy$NewtonMaximumBacktracks) {
      candidate <- pmax(parameter + step_scale * direction, lower)
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
  derivatives <- mfrmr_gtwad_derivative_audit(
    fn, parameter, lower, policy
  )
  kkt <- mfrmr_gtwad_kkt_audit(
    parameter, derivatives$Adaptive$Gradient,
    derivatives$Hessian, lower, policy
  )
  list(
    Parameter = parameter, Objective = objective,
    Gradient = derivatives$Adaptive$Gradient,
    Hessian = derivatives$Hessian,
    Derivatives = derivatives, KKT = kkt,
    Trace = do.call(rbind, trace)
  )
}

mfrmr_gtwad_oracle_newton <- function(fn, oracle, initial, lower, policy) {
  if (!is.function(oracle) || !is.list(initial) ||
      is.null(initial$Parameter)) {
    stop("An oracle and one numerical polish are required.", call. = FALSE)
  }
  parameter <- pmax(as.numeric(initial$Parameter), as.numeric(lower))
  lower <- rep_len(as.numeric(lower), length(parameter))
  trace <- list()
  for (iteration in seq_len(policy$OracleNewtonMaximumIterations)) {
    oracle_result <- tryCatch(oracle(parameter), error = function(error) NULL)
    hessian <- tryCatch(as.matrix(numDeriv::hessian(
      fn, parameter, method = "Richardson"
    )), error = function(error) matrix(numeric(), 0L, 0L))
    available <- is.list(oracle_result) &&
      isTRUE(oracle_result$Available) &&
      length(oracle_result$Gradient) == length(parameter) &&
      all(is.finite(c(oracle_result$Objective, oracle_result$Gradient)))
    kkt <- if (available) mfrmr_gtwad_kkt_audit(
      parameter, oracle_result$Gradient, hessian, lower, policy
    ) else list(Available = FALSE, RawKKTPassed = FALSE)
    trace[[iteration]] <- data.frame(
      Iteration = iteration - 1L,
      OracleObjective = if (available) oracle_result$Objective else NA_real_,
      OracleGradientMaximumAbsolute = if (available) {
        max(abs(oracle_result$Gradient))
      } else NA_real_,
      RawKKTPassed = isTRUE(kkt$RawKKTPassed),
      NewtonDecrement = if (isTRUE(kkt$Available)) {
        kkt$NewtonDecrement
      } else NA_real_,
      StepAccepted = FALSE, StepScale = NA_real_,
      stringsAsFactors = FALSE
    )
    if (!available || !isTRUE(kkt$Available)) break
    curvature_ready <- kkt$FreeCurvatureState %in%
      c("positive_definite", "vacuous_no_free_coordinates")
    if (isTRUE(kkt$RawKKTPassed) && curvature_ready) break
    gradient <- as.numeric(oracle_result$Gradient)
    working_free <- kkt$Free | (kkt$Active & gradient < 0)
    if (!any(working_free)) break
    free_hessian <- hessian[working_free, working_free, drop = FALSE]
    direction_free <- tryCatch(
      -solve(free_hessian, gradient[working_free]),
      error = function(error) numeric()
    )
    if (length(direction_free) != sum(working_free) ||
        any(!is.finite(direction_free))) break
    direction <- rep(0, length(parameter))
    direction[working_free] <- direction_free
    directional_derivative <- sum(gradient * direction)
    if (!is.finite(directional_derivative) || directional_derivative >= 0) break
    maximum_scale <- 1
    negative <- direction < 0
    if (any(negative)) {
      maximum_scale <- min(1, 0.99 * min(
        (parameter[negative] - lower[negative]) / -direction[negative]
      ))
    }
    step_scale <- maximum_scale
    accepted <- FALSE
    for (backtrack in 0:policy$NewtonMaximumBacktracks) {
      candidate <- pmax(parameter + step_scale * direction, lower)
      candidate_oracle <- tryCatch(
        oracle(candidate), error = function(error) NULL
      )
      candidate_available <- is.list(candidate_oracle) &&
        isTRUE(candidate_oracle$Available) &&
        is.finite(candidate_oracle$Objective)
      if (candidate_available && candidate_oracle$Objective <=
          oracle_result$Objective + policy$NewtonArmijoConstant *
            step_scale * directional_derivative) {
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
  oracle_result <- tryCatch(oracle(parameter), error = function(error) NULL)
  derivatives <- mfrmr_gtwad_derivative_audit(
    fn, parameter, lower, policy
  )
  oracle_available <- is.list(oracle_result) &&
    isTRUE(oracle_result$Available) &&
    length(oracle_result$Gradient) == length(parameter) &&
    all(is.finite(c(oracle_result$Objective, oracle_result$Gradient)))
  kkt <- if (oracle_available) mfrmr_gtwad_kkt_audit(
    parameter, oracle_result$Gradient, derivatives$Hessian, lower, policy
  ) else list(Available = FALSE, RawKKTPassed = FALSE, KKTPassed = FALSE)
  list(
    Parameter = parameter, Objective = as.numeric(fn(parameter)),
    Gradient = if (oracle_available) {
      as.numeric(oracle_result$Gradient)
    } else derivatives$Adaptive$Gradient,
    Hessian = derivatives$Hessian,
    Derivatives = derivatives, KKT = kkt,
    Trace = initial$Trace, OracleTrace = do.call(rbind, trace),
    Oracle = oracle_result
  )
}

mfrmr_gtwad_reference <- function(fn, parameter, lower,
                                   policy = mfrmr_gtwad_policy(),
                                   oracle = NULL) {
  starts <- mfrmr_gtwad_starts(parameter, lower)
  algorithms <- policy$SolverAlgorithms
  results <- list()
  index <- 0L
  for (start_id in names(starts)) {
    for (algorithm in algorithms) {
      index <- index + 1L
      result <- mfrmr_gtwad_solver_one(
        fn, starts[[start_id]], lower, algorithm, policy
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
    ParameterHash = if (result$Returned) {
      mfrmr_gta_hash(unname(result$Parameter))
    } else "none",
    RuntimeSeconds = result$RuntimeSeconds, stringsAsFactors = FALSE
  )))
  available <- which(rows$Returned & is.finite(rows$Objective))
  if (length(available) == 0L) {
    return(list(
      State = "not_evaluable", Rows = rows, Sidecar = list(),
      SidecarHash = "none", ConsensusPassed = FALSE,
      DerivativeAgreementPassed = FALSE, KKTPassed = FALSE
    ))
  }
  best_index <- available[[which.min(rows$Objective[available])]]
  numerical_polish <- mfrmr_gtwad_projected_newton(
    fn, results[[best_index]]$Parameter, lower, policy
  )
  polish <- if (is.function(oracle)) {
    mfrmr_gtwad_oracle_newton(
      fn, oracle, numerical_polish, lower, policy
    )
  } else numerical_polish
  per_algorithm <- vapply(algorithms, function(algorithm) {
    values <- rows$Objective[rows$Algorithm == algorithm & rows$Returned]
    if (length(values) == 0L) NA_real_ else min(values)
  }, numeric(1L))
  finite_algorithm <- is.finite(per_algorithm)
  consensus_tolerance <- policy$ObjectiveConsensusRelativeTolerance * max(
    1, abs(polish$Objective), abs(per_algorithm[finite_algorithm])
  )
  consensus <- sum(finite_algorithm) >= policy$MinimumConsensusAlgorithms &&
    max(abs(per_algorithm[finite_algorithm] - polish$Objective)) <=
      consensus_tolerance
  oracle_result <- if (is.function(oracle) && !is.null(polish$Oracle)) {
    polish$Oracle
  } else if (is.function(oracle)) tryCatch(
    oracle(polish$Parameter), error = function(error) NULL
  ) else NULL
  oracle_available <- is.list(oracle_result) &&
    isTRUE(oracle_result$Available) && is.finite(oracle_result$Objective) &&
    length(oracle_result$Gradient) == length(polish$Parameter) &&
    all(is.finite(oracle_result$Gradient))
  oracle_objective_tolerance <- if (oracle_available) {
    policy$ObjectiveReplayRelativeTolerance * max(
      1, abs(oracle_result$Objective), abs(polish$Objective)
    )
  } else NA_real_
  oracle_gradient_tolerance <- if (oracle_available) {
    pmax(
      policy$DerivativeRelativeTolerance * pmax(
        1, abs(oracle_result$Gradient),
        abs(polish$Derivatives$Adaptive$Gradient)
      ),
      policy$DerivativeStabilityMultiplier *
        polish$Derivatives$Adaptive$Resolution
    )
  } else rep(NA_real_, length(polish$Parameter))
  oracle_objective_pass <- oracle_available &&
    abs(oracle_result$Objective - polish$Objective) <=
      oracle_objective_tolerance
  oracle_gradient_pass <- oracle_available && all(
    abs(oracle_result$Gradient - polish$Derivatives$Adaptive$Gradient) <=
      oracle_gradient_tolerance
  )
  derivative_pass <- if (is.function(oracle)) {
    oracle_objective_pass && oracle_gradient_pass &&
      polish$Derivatives$HessianSymmetryPassed
  } else {
    polish$Derivatives$DerivativeAgreementPassed
  }
  curvature_ready <- polish$KKT$FreeCurvatureState %in%
    c("positive_definite", "vacuous_no_free_coordinates")
  state <- if (
    consensus && derivative_pass &&
      polish$KKT$RawKKTPassed && polish$KKT$KKTPassed &&
      polish$KKT$NewtonDecrementPassed &&
      curvature_ready
  ) "finite_box_local_minimum" else "reference_unresolved"
  sidecar <- list(
    Contract = "lme4_box_high_accuracy_reference_sidecar_b1g10_v3",
    PolicyHash = policy$PolicyHash,
    SolverRows = within(rows, RuntimeSeconds <- NULL),
    SolverParameters = lapply(results, function(result) result$Parameter),
    AlgorithmBestObjectives = per_algorithm,
    PolishedParameter = polish$Parameter,
    PolishedObjective = polish$Objective,
    PolishedGradient = polish$Gradient,
    PolishedHessian = polish$Hessian,
    NewtonTrace = polish$Trace,
    OracleNewtonTrace = if (!is.null(polish$OracleTrace)) {
      polish$OracleTrace
    } else data.frame(),
    AdaptiveGradient = polish$Derivatives$Adaptive$Gradient,
    RichardsonGradient = polish$Derivatives$RichardsonGradient,
    DerivativeRoutes = polish$Derivatives$Adaptive$Routes,
    SelectedStepExponent =
      polish$Derivatives$Adaptive$SelectedStepExponent,
    FiniteDifferenceResolution = polish$Derivatives$Adaptive$Resolution,
    DerivativeComponentTolerance = polish$Derivatives$ComponentTolerance,
    HessianSymmetryPassed = polish$Derivatives$HessianSymmetryPassed,
    IndependentOracleRequested = is.function(oracle),
    IndependentOracleAvailable = oracle_available,
    IndependentOracleObjective = if (oracle_available) {
      oracle_result$Objective
    } else NA_real_,
    IndependentOracleGradient = if (oracle_available) {
      oracle_result$Gradient
    } else rep(NA_real_, length(polish$Parameter)),
    IndependentOracleObjectiveTolerance = oracle_objective_tolerance,
    IndependentOracleGradientTolerance = oracle_gradient_tolerance,
    IndependentOracleObjectivePassed = oracle_objective_pass,
    IndependentOracleGradientPassed = oracle_gradient_pass,
    ActiveSet = polish$KKT$Active,
    KKT = polish$KKT
  )
  list(
    State = state, Rows = rows, Sidecar = sidecar,
    SidecarHash = mfrmr_gta_hash(sidecar),
    ConsensusPassed = consensus,
    ConsensusTolerance = consensus_tolerance,
    AlgorithmBestObjectiveRange = diff(range(
      per_algorithm[finite_algorithm]
    )),
    DerivativeAgreementPassed = derivative_pass,
    IndependentOracleAvailable = oracle_available,
    IndependentOracleObjectivePassed = oracle_objective_pass,
    IndependentOracleGradientPassed = oracle_gradient_pass,
    IndependentOracleObjectiveAbsoluteDifference = if (oracle_available) {
      abs(oracle_result$Objective - polish$Objective)
    } else NA_real_,
    RawKKTPassed = polish$KKT$RawKKTPassed,
    KKTPassed = polish$KKT$KKTPassed,
    NewtonDecrementPassed = polish$KKT$NewtonDecrementPassed,
    FreeCurvatureState = polish$KKT$FreeCurvatureState,
    ActiveCount = polish$KKT$ActiveCount,
    PolishedObjective = polish$Objective,
    PolishedParameterHash = mfrmr_gta_hash(unname(polish$Parameter))
  )
}

mfrmr_gtwad_profile_boundary <- function(fn, parameter, target_index, lower,
                                          policy) {
  parameter <- as.numeric(parameter)
  lower <- rep_len(as.numeric(lower), length(parameter))
  target_index <- as.integer(target_index)
  if (length(target_index) != 1L || is.na(target_index) ||
      target_index < 1L || target_index > length(parameter)) {
    stop("One valid target theta index is required.", call. = FALSE)
  }
  free_index <- setdiff(seq_along(parameter), target_index)
  current <- parameter
  rows <- lapply(policy$BoundaryThetaFractions, function(fraction) {
    target <- lower[[target_index]] + fraction *
      (parameter[[target_index]] - lower[[target_index]])
    reconstruct <- function(free) {
      value <- current
      value[free_index] <- free
      value[[target_index]] <- target
      value
    }
    free_fn <- function(free) fn(reconstruct(free))
    algorithm_results <- lapply(policy$SolverAlgorithms, function(algorithm) {
      mfrmr_gtwad_solver_one(
        free_fn, current[free_index], lower[free_index], algorithm, policy
      )
    })
    names(algorithm_results) <- policy$SolverAlgorithms
    objectives <- vapply(
      algorithm_results, `[[`, numeric(1L), "Objective"
    )
    returned <- vapply(algorithm_results, `[[`, logical(1L), "Returned")
    available <- which(returned & is.finite(objectives))
    if (length(available) == 0L) {
      return(data.frame(
        Fraction = fraction, TargetTheta = target, Returned = FALSE,
        ConsensusPassed = FALSE, Objective = NA_real_,
        NuisanceKKTRequested = TRUE, NuisanceKKTPassed = FALSE,
        NuisanceNewtonDecrementPassed = FALSE,
        NuisanceCurvatureState = "not_evaluable",
        TargetGradient = NA_real_, ParameterHash = "none",
        stringsAsFactors = FALSE
      ))
    }
    best <- algorithm_results[[available[[which.min(objectives[available])]]]]
    polish <- mfrmr_gtwad_projected_newton(
      free_fn, best$Parameter, lower[free_index], policy
    )
    current <<- reconstruct(polish$Parameter)
    tolerance <- policy$ObjectiveConsensusRelativeTolerance * max(
      1, abs(polish$Objective), abs(objectives[available])
    )
    consensus <- length(available) == length(policy$SolverAlgorithms) &&
      max(abs(objectives[available] - polish$Objective)) <= tolerance
    target_gradient <- tryCatch(
      mfrmr_gtwad_box_gradient(
        fn, current, lower, policy
      )$Gradient[[target_index]], error = function(error) NA_real_
    )
    data.frame(
      Fraction = fraction, TargetTheta = target,
      Returned = is.finite(polish$Objective),
      ConsensusPassed = consensus, Objective = polish$Objective,
      NuisanceKKTRequested = TRUE,
      NuisanceKKTPassed = isTRUE(polish$KKT$KKTPassed),
      NuisanceNewtonDecrementPassed =
        isTRUE(polish$KKT$NewtonDecrementPassed),
      NuisanceCurvatureState = polish$KKT$FreeCurvatureState,
      TargetGradient = target_gradient,
      ParameterHash = mfrmr_gta_hash(unname(current)),
      stringsAsFactors = FALSE
    )
  })
  rows <- do.call(rbind, rows)
  available <- all(
    rows$Returned & rows$ConsensusPassed & rows$NuisanceKKTPassed &
      rows$NuisanceNewtonDecrementPassed &
      rows$NuisanceCurvatureState %in%
        c("positive_definite", "vacuous_no_free_coordinates") &
      is.finite(rows$Objective)
  )
  tolerance <- if (available) policy$BoundaryObjectiveRelativeTolerance *
    pmax(1, abs(rows$Objective)) else rep(NA_real_, nrow(rows))
  list(
    Rows = rows, Available = available,
    MonotoneTowardBoundary = available && all(
      diff(rows$Objective) >= -tolerance[-1L]
    ),
    MaterialWorseningTowardBoundary = available &&
      rows$Objective[[nrow(rows)]] - rows$Objective[[1L]] > tolerance[[1L]],
    MaterialImprovementTowardBoundary = available &&
      rows$Objective[[1L]] - rows$Objective[[nrow(rows)]] > tolerance[[1L]],
    FinalParameter = current
  )
}

mfrmr_gtwad_analytic_audit <- function(policy = mfrmr_gtwad_policy()) {
  fixtures <- list(
    interior = list(
      Fn = function(value) sum((value - c(1, 2))^2),
      Start = c(0.3, 0.6), Expected = c(1, 2),
      ExpectedActive = 0L, ExpectedState = "finite_box_local_minimum"
    ),
    active_linear = list(
      Fn = function(value) value[[1L]] + value[[1L]]^2 +
        (value[[2L]] - 1)^2,
      Start = c(0.4, 0.4), Expected = c(0, 1),
      ExpectedActive = 1L, ExpectedState = "finite_box_local_minimum"
    ),
    active_even = list(
      Fn = function(value) value[[1L]]^2 + (value[[2L]] - 1)^2,
      Start = c(0.4, 0.4), Expected = c(0, 1),
      ExpectedActive = 1L, ExpectedState = "finite_box_local_minimum"
    ),
    boundary_escape = list(
      Fn = function(value) -value[[1L]]^2 + value[[1L]]^4 +
        (value[[2L]] - 1)^2,
      Start = c(0.4, 0.4), Expected = c(1 / sqrt(2), 1),
      ExpectedActive = 0L, ExpectedState = "finite_box_local_minimum"
    )
  )
  rows <- do.call(rbind, lapply(names(fixtures), function(name) {
    fixture <- fixtures[[name]]
    result <- mfrmr_gtwad_reference(
      fixture$Fn, fixture$Start, c(0, 0), policy
    )
    parameter <- result$Sidecar$PolishedParameter
    data.frame(
      Fixture = name, State = result$State,
      ConsensusPassed = result$ConsensusPassed,
      DerivativeAgreementPassed = result$DerivativeAgreementPassed,
      RawKKTPassed = result$RawKKTPassed,
      KKTPassed = result$KKTPassed,
      FreeCurvatureState = result$FreeCurvatureState,
      ActiveCount = result$ActiveCount,
      ParameterMaximumAbsoluteDifference = max(abs(
        parameter - fixture$Expected
      )),
      StateMatched = identical(result$State, fixture$ExpectedState),
      ActiveSetMatched = identical(result$ActiveCount, fixture$ExpectedActive),
      stringsAsFactors = FALSE
    )
  }))
  profile_fn <- function(value) (value[[1L]] - 0.7)^2 +
    (value[[2L]] - 1)^2
  profile <- mfrmr_gtwad_profile_boundary(
    profile_fn, c(0.7, 1), 1L, c(0, 0), policy
  )
  identity <- list(
    Contract = "lme4_box_reference_analytic_audit_b1g10_v3",
    Rows = rows, ProfileRows = profile$Rows,
    ProfileAvailable = profile$Available,
    ProfileMonotoneTowardBoundary = profile$MonotoneTowardBoundary,
    ProfileMaterialWorseningTowardBoundary =
      profile$MaterialWorseningTowardBoundary
  )
  structure(c(identity, list(
    AuditHash = mfrmr_gta_hash(identity),
    AnalyticFixtureReady = all(
      rows$ConsensusPassed & rows$DerivativeAgreementPassed &
        rows$RawKKTPassed & rows$KKTPassed &
        rows$FreeCurvatureState %in%
          c("positive_definite", "vacuous_no_free_coordinates") &
        rows$ParameterMaximumAbsoluteDifference <= 1e-5 &
        rows$StateMatched & rows$ActiveSetMatched
    ),
    BoundaryProfileMechanicsReady = isTRUE(profile$Available) &&
      isTRUE(profile$MonotoneTowardBoundary) &&
      isTRUE(profile$MaterialWorseningTowardBoundary) &&
      tail(profile$Rows$TargetTheta, 1L) == 0
  )), class = "mfrmr_gtwad_analytic_audit")
}

mfrmr_gtwad_contract <- function(objective_preflight_contract) {
  mfrmr_gtwad_require_primitives()
  if (!inherits(objective_preflight_contract, "mfrmr_gtwac_contract") ||
      !identical(
        objective_preflight_contract$ContractHash,
        "20d6fb656ac2f2996e5881a07729a3e4fb2f417859f90efde7ee72784ba62092"
      ) || !isTRUE(objective_preflight_contract$Lme4ObjectivePreflightReady) ||
      isTRUE(objective_preflight_contract$CalibrationExecutionAuthorized)) {
    stop("The exact non-authorizing b1g9 contract is required.",
         call. = FALSE)
  }
  policy <- mfrmr_gtwad_policy()
  audit <- mfrmr_gtwad_analytic_audit(policy)
  ready <- isTRUE(audit$AnalyticFixtureReady) &&
    isTRUE(audit$BoundaryProfileMechanicsReady)
  if (!ready) stop("The b1g10 analytic solver preflight failed.",
                   call. = FALSE)
  identity <- list(
    Contract = "lme4_reference_coverage_draft83d2b2b1g10_v3",
    UpstreamB1g9ContractHash = objective_preflight_contract$ContractHash,
    AnalyticAuditHash = audit$AuditHash,
    Policy = policy,
    Backend = "lme4",
    MethodIds = c("lme4_ml", "lme4_reml"),
    Likelihoods = c("ML", "REML"),
    Coordinate = "nonnegative_relative_standard_deviation_theta",
    FirstOrderBoundarySufficiencyClaim = FALSE,
    BoundaryEvidence = paste(
      "nuisance-reoptimized theta profile and exact reduced-objective match",
      "kept separate from KKT"
    ),
    NonreservedScenarioIds = c(
      "GT-WI-baseline_complete-exact_zero",
      "GT-WI-baseline_complete-reference_1200"
    ),
    NonreservedReplicates = c(901L, 902L),
    ReservedReplicates = c(2:3, 101:125, 201:300, 501:700),
    Sources = mfrmr_gtwad_source_registry(),
    PackageVersions = c(
      lme4 = as.character(utils::packageVersion("lme4")),
      Matrix = as.character(utils::packageVersion("Matrix")),
      minqa = as.character(utils::packageVersion("minqa")),
      numDeriv = as.character(utils::packageVersion("numDeriv")),
      R = as.character(getRversion())
    ),
    NamespaceFunctionHashes = objective_preflight_contract$
      NamespaceFunctionHashes,
    UpstreamFunctionHashes = objective_preflight_contract$FunctionHashes,
    FunctionHashes = mfrmr_gtwad_function_hashes()
  )
  structure(c(identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    BoxConstrainedSolverReady = TRUE,
    BoundaryProfileMechanicsReady = TRUE,
    NonreservedLme4ReplayAuthorized = TRUE,
    NonreservedLme4ReplayReady = FALSE,
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
  )), class = "mfrmr_gtwad_contract")
}

mfrmr_gtwad_manifest <- function(contract, registry = mfrmr_gtw_registry()) {
  if (!inherits(contract, "mfrmr_gtwad_contract") ||
      !isTRUE(contract$NonreservedLme4ReplayAuthorized) ||
      isTRUE(contract$CalibrationExecutionAuthorized)) {
    stop("An intact b1g10 coverage contract is required.", call. = FALSE)
  }
  scenario_rows <- registry$Cells[match(
    contract$NonreservedScenarioIds, registry$Cells$ScenarioId
  ), , drop = FALSE]
  rows <- do.call(rbind, lapply(seq_len(nrow(scenario_rows)), function(index) {
    data.frame(
      ScenarioId = scenario_rows$ScenarioId[[index]],
      Replicate = contract$NonreservedReplicates[[index]],
      DatasetId = sprintf(
        "%s/R%04d", scenario_rows$ScenarioId[[index]],
        contract$NonreservedReplicates[[index]]
      ),
      Seed = scenario_rows$SeedStart[[index]] +
        contract$NonreservedReplicates[[index]] - 1L,
      DesignId = scenario_rows$DesignId[[index]],
      VarianceId = scenario_rows$VarianceId[[index]],
      MethodId = contract$MethodIds,
      Likelihood = contract$Likelihoods,
      REMLArgument = c(FALSE, TRUE),
      ModelRoleCount = 2L,
      ReferenceSolverRunsPerObjective = 9L,
      FullProfilePointCount = length(
        contract$Policy$BoundaryThetaFractions
      ),
      ProfileSolverRunsPerPoint = 3L,
      CalibrationUse = FALSE,
      CalibrationExecutionAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  }))
  rows$RouteId <- paste(rows$DatasetId, rows$MethodId, sep = "/")
  if (nrow(rows) != 4L || anyDuplicated(rows$RouteId) ||
      any(rows$Replicate %in% contract$ReservedReplicates)) {
    stop("The b1g10 manifest collides with a reserved or duplicate route.",
         call. = FALSE)
  }
  identity <- list(
    Contract = "lme4_reference_nonreserved_manifest_b1g10_v3",
    ReferenceContractHash = contract$ContractHash,
    RegistryHash = registry$RegistryHash, Rows = rows
  )
  structure(c(identity, list(
    ManifestHash = mfrmr_gta_hash(identity),
    DatasetCount = length(unique(rows$DatasetId)),
    MethodRouteCount = nrow(rows),
    ObjectiveCount = sum(rows$ModelRoleCount),
    PlannedObjectiveSolverRunCount = sum(
      rows$ModelRoleCount * rows$ReferenceSolverRunsPerObjective
    ),
    PlannedProfileSolverRunCount = sum(
      rows$FullProfilePointCount * rows$ProfileSolverRunsPerPoint
    ),
    ExecutionAuthorized = TRUE, CalibrationUse = FALSE,
    DataGenerated = FALSE, ResultsViewed = FALSE
  )), class = "mfrmr_gtwad_manifest")
}

mfrmr_gtwad_manifest_hash_valid <- function(manifest) {
  fields <- c("Contract", "ReferenceContractHash", "RegistryHash", "Rows")
  inherits(manifest, "mfrmr_gtwad_manifest") &&
    all(fields %in% names(manifest)) && identical(
      manifest$ManifestHash, mfrmr_gta_hash(manifest[fields])
    )
}

mfrmr_gtwad_fit_objective <- function(formula, data, reml) {
  control <- lme4::lmerControl(
    optimizer = "nloptwrap", calc.derivs = TRUE,
    optCtrl = list(
      xtol_abs = 1e-10, ftol_abs = 1e-10, maxeval = 100000
    )
  )
  captured <- mfrmr_gtwd_capture(lme4::lmer(
    formula, data = data, REML = isTRUE(reml), control = control
  ))
  devfun <- lme4::lmer(
    formula, data = data, REML = isTRUE(reml),
    control = lme4::lmerControl(calc.derivs = FALSE),
    devFunOnly = TRUE
  )
  criterion <- if (isTRUE(reml)) {
    as.numeric(lme4::REMLcrit(captured$Fit))
  } else {
    as.numeric(stats::deviance(captured$Fit))
  }
  list(
    Fit = captured$Fit, Devfun = devfun, Criterion = criterion,
    LogLikCriterion = -2 * as.numeric(stats::logLik(
      captured$Fit, REML = isTRUE(reml)
    )),
    Warnings = captured$Warnings, Messages = captured$Messages,
    Control = control
  )
}

mfrmr_gtwad_target_index <- function(fit, target = "Rater") {
  expected <- paste0(target, ".(Intercept)")
  index <- match(expected, names(lme4::getME(fit, "theta")))
  if (is.na(index)) stop("The target lme4 theta coordinate is absent.",
                         call. = FALSE)
  as.integer(index)
}

mfrmr_gtwad_execute <- function(contract, manifest,
                                 registry = mfrmr_gtw_registry()) {
  if (!inherits(contract, "mfrmr_gtwad_contract") ||
      !inherits(manifest, "mfrmr_gtwad_manifest") ||
      !mfrmr_gtwad_manifest_hash_valid(manifest) ||
      !identical(manifest$ReferenceContractHash, contract$ContractHash) ||
      !isTRUE(manifest$ExecutionAuthorized) || isTRUE(manifest$CalibrationUse) ||
      any(manifest$Rows$Replicate %in% contract$ReservedReplicates)) {
    stop("The exact nonreserved b1g10 replay is not authorized.",
         call. = FALSE)
  }
  outputs <- list()
  generators <- list()
  row_index <- 0L
  for (route_index in seq_len(nrow(manifest$Rows))) {
    route <- manifest$Rows[route_index, , drop = FALSE]
    generation <- mfrmr_gtw_generate(
      registry, route$ScenarioId[[1L]], route$Replicate[[1L]]
    )
    prefit <- mfrmr_gtd3_prefit_one(generation)
    if (!isTRUE(prefit$PreFitEligible)) {
      stop("The b1g10 nonreserved replay failed structural pre-fit.",
           call. = FALSE)
    }
    generators[[route$DatasetId[[1L]]]] <- generation$GeneratorHash
    data <- prefit$StructuralRankAudit$PreparedData$Data
    formulas <- list(
      full = stats::as.formula(generation$Spec$FormulaCanonical),
      reduced = mfrmr_gtwd_reduced_formula(generation$Spec, "Rater")
    )
    route_outputs <- list()
    for (model_role in names(formulas)) {
      row_index <- row_index + 1L
      fit_result <- tryCatch(mfrmr_gtwad_fit_objective(
        formulas[[model_role]], data, route$REMLArgument[[1L]]
      ), error = function(error) error)
      if (inherits(fit_result, "error")) {
        outputs[[row_index]] <- list(
          Row = data.frame(
            RouteId = route$RouteId, DatasetId = route$DatasetId,
            ScenarioId = route$ScenarioId, Replicate = route$Replicate,
            MethodId = route$MethodId, Likelihood = route$Likelihood,
            REMLArgument = route$REMLArgument, ModelRole = model_role,
            FitReturned = FALSE, ReferenceState = "not_evaluable",
            ConsensusPassed = FALSE, DerivativeAgreementPassed = FALSE,
            RawKKTPassed = FALSE, KKTPassed = FALSE,
            NewtonDecrementPassed = FALSE,
            FreeCurvatureState = "not_evaluable",
            BoundaryState = "not_evaluable",
            PolishedObjective = NA_real_, ActiveCount = NA_integer_,
            IndependentOracleAvailable = FALSE,
            IndependentOracleObjectivePassed = FALSE,
            IndependentOracleGradientPassed = FALSE,
            IndependentOracleObjectiveAbsoluteDifference = NA_real_,
            SidecarHash = "none", CalibrationUse = FALSE,
            stringsAsFactors = FALSE
          ), Sidecar = list()
        )
        next
      }
      fit <- fit_result$Fit
      theta <- lme4::getME(fit, "theta")
      lower <- lme4::getME(fit, "lower")
      reference <- mfrmr_gtwad_reference(
        fit_result$Devfun, theta, lower, contract$Policy,
        oracle = function(parameter) mfrmr_gtwad_sparse_oracle(
          fit, parameter, route$REMLArgument[[1L]]
        )
      )
      boundary <- NULL
      if (identical(model_role, "full") &&
          !identical(reference$SidecarHash, "none")) {
        boundary <- mfrmr_gtwad_profile_boundary(
          fit_result$Devfun, reference$Sidecar$PolishedParameter,
          mfrmr_gtwad_target_index(fit, "Rater"), lower, contract$Policy
        )
      }
      boundary_state <- if (is.null(boundary)) {
        "not_applicable"
      } else if (!isTRUE(boundary$Available)) {
        "not_evaluable"
      } else if (isTRUE(boundary$MonotoneTowardBoundary) &&
                 isTRUE(boundary$MaterialWorseningTowardBoundary)) {
        "finite_interior_supported"
      } else if (isTRUE(boundary$MaterialImprovementTowardBoundary)) {
        "boundary_direction_supported"
      } else {
        "profile_indeterminate"
      }
      fit_identity <- list(
        Backend = "lme4", MethodId = route$MethodId[[1L]],
        Likelihood = route$Likelihood[[1L]],
        REML = route$REMLArgument[[1L]],
        Formula = paste(deparse(
          formulas[[model_role]], width.cutoff = 500L
        ), collapse = " "),
        ControlHash = mfrmr_gta_hash(fit_result$Control)
      )
      sidecar <- list(
        Contract = "lme4_reference_execution_sidecar_b1g10_v3",
        FitCallIdentity = fit_identity,
        Reference = reference$Sidecar,
        BoundaryProfile = if (is.null(boundary)) list() else boundary$Rows,
        Warnings = fit_result$Warnings, Messages = fit_result$Messages,
        ReportedTheta = unname(theta), ReportedCriterion = fit_result$Criterion,
        LogLikCriterion = fit_result$LogLikCriterion,
        CriterionAccessor = if (route$REMLArgument[[1L]]) {
          "REMLcrit"
        } else "deviance"
      )
      sidecar_hash <- mfrmr_gta_hash(sidecar)
      outputs[[row_index]] <- list(
        Row = data.frame(
          RouteId = route$RouteId, DatasetId = route$DatasetId,
          ScenarioId = route$ScenarioId, Replicate = route$Replicate,
          MethodId = route$MethodId, Likelihood = route$Likelihood,
          REMLArgument = route$REMLArgument, ModelRole = model_role,
          FitReturned = TRUE, ReferenceState = reference$State,
          ConsensusPassed = reference$ConsensusPassed,
          DerivativeAgreementPassed = reference$DerivativeAgreementPassed,
          RawKKTPassed = reference$RawKKTPassed,
          KKTPassed = reference$KKTPassed,
          NewtonDecrementPassed = reference$NewtonDecrementPassed,
          FreeCurvatureState = reference$FreeCurvatureState,
          BoundaryState = boundary_state,
          PolishedObjective = reference$PolishedObjective,
          ActiveCount = reference$ActiveCount,
          IndependentOracleAvailable = reference$IndependentOracleAvailable,
          IndependentOracleObjectivePassed =
            reference$IndependentOracleObjectivePassed,
          IndependentOracleGradientPassed =
            reference$IndependentOracleGradientPassed,
          IndependentOracleObjectiveAbsoluteDifference =
            reference$IndependentOracleObjectiveAbsoluteDifference,
          SidecarHash = sidecar_hash, CalibrationUse = FALSE,
          stringsAsFactors = FALSE
        ), Sidecar = sidecar
      )
      route_outputs[[model_role]] <- outputs[[row_index]]
    }
    full <- route_outputs$full
    reduced <- route_outputs$reduced
    if (!is.null(full) && !is.null(reduced) &&
        isTRUE(full$Row$FitReturned) && isTRUE(reduced$Row$FitReturned) &&
        length(full$Sidecar$BoundaryProfile) > 0L) {
      final_profile <- tail(full$Sidecar$BoundaryProfile$Objective, 1L)
      tolerance <- contract$Policy$BoundaryObjectiveRelativeTolerance * max(
        1, abs(final_profile), abs(reduced$Row$PolishedObjective)
      )
      matched <- is.finite(final_profile) &&
        abs(final_profile - reduced$Row$PolishedObjective) <= tolerance
      full$Row$BoundaryReducedObjectiveMatched <- matched
      full$Row$BoundaryReducedObjectiveDifference <- abs(
        final_profile - reduced$Row$PolishedObjective
      )
      if (identical(full$Row$BoundaryState, "boundary_direction_supported")) {
        full$Row$BoundaryState <- if (matched) {
          "boundary_limit_supported"
        } else "boundary_profile_not_reduced_matched"
        if (matched) full$Row$ReferenceState <- "boundary_limit"
      }
      outputs[[row_index - 1L]] <- full
    }
  }
  rows <- do.call(rbind, lapply(outputs, function(output) {
    row <- output$Row
    if (!"BoundaryReducedObjectiveMatched" %in% names(row)) {
      row$BoundaryReducedObjectiveMatched <- NA
      row$BoundaryReducedObjectiveDifference <- NA_real_
    }
    row
  }))
  row.names(rows) <- NULL
  sidecars <- lapply(outputs, `[[`, "Sidecar")
  sidecar_valid <- vapply(seq_along(sidecars), function(index) {
    identical(mfrmr_gta_hash(sidecars[[index]]), rows$SidecarHash[[index]])
  }, logical(1L))
  full_rows <- rows$ModelRole == "full"
  ready <- nrow(rows) == manifest$ObjectiveCount && all(rows$FitReturned) &&
    all(rows$ConsensusPassed) && all(rows$DerivativeAgreementPassed) &&
    all(rows$IndependentOracleAvailable) &&
    all(rows$IndependentOracleObjectivePassed) &&
    all(rows$IndependentOracleGradientPassed) &&
    all(rows$RawKKTPassed) &&
    all(rows$KKTPassed) && all(rows$NewtonDecrementPassed) &&
    all(rows$FreeCurvatureState %in%
          c("positive_definite", "vacuous_no_free_coordinates")) &&
    all(!rows$ReferenceState %in% c("reference_unresolved", "not_evaluable")) &&
    all(rows$BoundaryState[full_rows] %in%
          c("finite_interior_supported", "boundary_limit_supported")) &&
    all(rows$BoundaryReducedObjectiveMatched[full_rows]) &&
    all(sidecar_valid) && all(!rows$CalibrationUse)
  scientific_rows <- rows
  identity <- list(
    Contract = "lme4_reference_nonreserved_execution_b1g10_v3",
    ReferenceContractHash = contract$ContractHash,
    ManifestHash = manifest$ManifestHash,
    GeneratorHashes = generators,
    Rows = scientific_rows, SidecarHashes = rows$SidecarHash
  )
  structure(c(identity, list(
    ExecutionHash = mfrmr_gta_hash(identity), Sidecars = sidecars,
    ExactAccountingPassed = nrow(rows) == manifest$ObjectiveCount,
    FitReturnCount = sum(rows$FitReturned),
    ReferenceResolvedCount = sum(!rows$ReferenceState %in%
      c("reference_unresolved", "not_evaluable")),
    ConsensusPassCount = sum(rows$ConsensusPassed),
    DerivativeAgreementPassCount = sum(rows$DerivativeAgreementPassed),
    RawKKTPassCount = sum(rows$RawKKTPassed),
    KKTPassCount = sum(rows$KKTPassed),
    BoundaryProfilePassCount = sum(rows$BoundaryState[full_rows] %in%
      c("finite_interior_supported", "boundary_limit_supported")),
    SidecarValidationPassed = all(sidecar_valid),
    NonreservedLme4ReplayReady = ready,
    Lme4MLReferenceMechanicsReady = ready && all(
      rows$ReferenceState[rows$MethodId == "lme4_ml"] %in%
        c("finite_box_local_minimum", "boundary_limit")
    ),
    Lme4REMLReferenceMechanicsReady = ready && all(
      rows$ReferenceState[rows$MethodId == "lme4_reml"] %in%
        c("finite_box_local_minimum", "boundary_limit")
    ),
    ReferenceReadyMethodCount = if (ready) 4L else 2L,
    ReferenceMethodCoverageComplete = ready,
    CalibrationAuthorizationReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE, CalibrationResultsViewed = FALSE,
    StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    ConfirmationAuthorized = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtwad_execution")
}

mfrmr_gtwad_execution_hash_valid <- function(execution) {
  fields <- c(
    "Contract", "ReferenceContractHash", "ManifestHash", "GeneratorHashes",
    "Rows", "SidecarHashes"
  )
  inherits(execution, "mfrmr_gtwad_execution") &&
    all(fields %in% names(execution)) && identical(
      execution$ExecutionHash, mfrmr_gta_hash(execution[fields])
    ) && length(execution$Sidecars) == nrow(execution$Rows) &&
    all(vapply(seq_along(execution$Sidecars), function(index) {
      identical(
        mfrmr_gta_hash(execution$Sidecars[[index]]),
        execution$Rows$SidecarHash[[index]]
      )
    }, logical(1L)))
}

mfrmr_gtwad_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwad_policy", "mfrmr_gtwad_source_registry",
    "mfrmr_gtwad_sparse_oracle",
    "mfrmr_gtwad_box_gradient", "mfrmr_gtwad_derivative_audit",
    "mfrmr_gtwad_kkt_audit", "mfrmr_gtwad_solver_one",
    "mfrmr_gtwad_starts", "mfrmr_gtwad_projected_newton",
    "mfrmr_gtwad_oracle_newton",
    "mfrmr_gtwad_reference", "mfrmr_gtwad_profile_boundary",
    "mfrmr_gtwad_analytic_audit", "mfrmr_gtwad_contract",
    "mfrmr_gtwad_manifest", "mfrmr_gtwad_manifest_hash_valid",
    "mfrmr_gtwad_fit_objective", "mfrmr_gtwad_target_index",
    "mfrmr_gtwad_execute", "mfrmr_gtwad_execution_hash_valid"
  )
  coverage_environment <- environment(mfrmr_gtwad_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwad_function_hash(get(
      name, envir = coverage_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}
