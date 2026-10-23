# Accuracy-controlled ordinary direct MML. Only resolved fixed/adaptive modes
# reach model evaluation, information, scoring or saved calibration consumers.

mfrmr_mml_accuracy_control <- function(control = NULL) {
  defaults <- list(adaptive_points = c(31L, 61L, 121L),
    loglik_tol = 1e-7, posterior_tol = 1e-6, gradient_tol = 1e-4)
  if (is.null(control)) return(defaults)
  if (!is.list(control) || (length(control) &&
      (is.null(names(control)) || anyNA(names(control)) ||
       any(!names(control) %in% names(defaults)) || anyDuplicated(names(control))))) {
    stop("`mml_accuracy_control` must be a named list of adaptive_points, loglik_tol, posterior_tol and/or gradient_tol.",
      call. = FALSE)
  }
  defaults[names(control)] <- control
  points <- defaults$adaptive_points
  if (!is.numeric(points) || !length(points) || any(!is.finite(points)) ||
      any(points < 3 | points != floor(points) | points > (.Machine$integer.max - 1) / 2) ||
      is.unsorted(points, strictly = TRUE)) {
    stop("`adaptive_points` must contain strictly increasing integer orders >= 3.", call. = FALSE)
  }
  defaults$adaptive_points <- as.integer(points)
  for (name in c("loglik_tol", "posterior_tol", "gradient_tol")) {
    value <- defaults[[name]]
    if (!is.numeric(value) || length(value) != 1L || !is.finite(value) || value <= 0) {
      stop("`", name, "` must be a finite positive scalar.", call. = FALSE)
    }
  }
  # Fail before fitting if a requested rule cannot be represented.
  invisible(lapply(unique(c(points, 2L * points + 1L)), gauss_hermite_normal))
  defaults
}

mfrmr_check_mml_accuracy <- function(opt, idx, config, sizes, labels,
                                    adaptive_points, control) {
  nodes <- config$estimation_control$quad_points
  adaptive <- mfrmr_adaptive_integration(config)
  reference_nodes <- 2L * adaptive_points + 1L
  params <- expand_params(opt$par, sizes, config)
  review <- mfrmr_adaptive_quadrature_review(
    idx, config, params,
    if (adaptive) list(nodes = 0, weights = 1) else gauss_hermite_normal(nodes),
    labels, c(adaptive_points, reference_nodes))
  low <- review[review$AdaptiveNodes == adaptive_points, , drop = FALSE]
  high <- review[review$AdaptiveNodes == reference_nodes, , drop = FALSE]
  if (nrow(low) != length(labels) || nrow(high) != length(labels) ||
      any(review$Status != "computed") || !identical(low$Person, high$Person)) {
    stop("Person integration check unavailable: ",
      paste(unique(review$Detail[nzchar(review$Detail)]), collapse = "; "), call. = FALSE)
  }
  supnorm <- function(x) {
    if (any(!is.finite(x))) stop("Non-finite integration check.", call. = FALSE)
    if (length(x)) max(abs(x)) else 0
  }
  # Include both the retained rule versus the reference and convergence of
  # two adaptive rules. A good total likelihood cannot hide an inaccurate Person.
  candidate <- if (adaptive) low else high
  prefix <- if (adaptive) "Adaptive" else "Fixed"
  difference <- function(field) pmax(
    abs(candidate[[paste0(prefix, field)]] - high[[paste0("Adaptive", field)]]),
    abs(low[[paste0("Adaptive", field)]] - high[[paste0("Adaptive", field)]]))
  per_person <- data.frame(Person = high$Person,
    LogMarginalDifference = difference("LogMarginal"),
    EAPDifference = difference("EAP"),
    PosteriorSDDifference = difference("PosteriorSD"), stringsAsFactors = FALSE)
  reference_config <- config
  reference_config$estimation_control$mml_integration <- "adaptive"
  evaluate <- function(order) mfrmr_make_adaptive_mml_evaluator(
    idx, reference_config, sizes, order)(opt$par)
  low_value <- evaluate(adaptive_points)
  high_value <- evaluate(reference_nodes)
  retained_gradient <- if (adaptive) low_value$gradient else mfrm_grad_mml_core(
    params, compute_base_eta(idx, params, config), idx, config, sizes,
    gauss_hermite_normal(nodes))
  loglik_difference <- supnorm(per_person$LogMarginalDifference)
  eap_difference <- supnorm(per_person$EAPDifference)
  sd_difference <- supnorm(per_person$PosteriorSDDifference)
  gradient_difference <- max(supnorm(retained_gradient - high_value$gradient),
    supnorm(low_value$gradient - high_value$gradient))
  gradient_norm <- max(supnorm(retained_gradient), supnorm(high_value$gradient))
  passed <- isTRUE(opt$convergence == 0L) &&
    loglik_difference <= control$loglik_tol &&
    max(eap_difference, sd_difference) <= control$posterior_tol &&
    max(gradient_difference, gradient_norm) <= control$gradient_tol
  list(passed = passed, per_person = per_person,
    metrics = c(MaxLogMarginalDifference = loglik_difference,
      MaxEAPDifference = eap_difference, MaxPosteriorSDDifference = sd_difference,
      MaxGradientDifference = gradient_difference, MaxGradient = gradient_norm))
}

mfrmr_optimize_accuracy_mml <- function(start, idx, config, sizes, labels,
                                      maxit, reltol, optimizer, control) {
  history <- list()
  last_par <- start
  orders <- control$adaptive_points
  initial_nodes <- config$estimation_control$quad_points
  fail <- function(detail) {
    stop(structure(list(
      message = paste0("MML numerical accuracy was not established: ", detail,
        " Inspect the condition's history and control; no fit was returned."),
      call = NULL, history = do.call(rbind, history), control = control,
      last_parameters = last_par,
      last_integration = config$estimation_control$mml_integration,
      last_quad_points = config$estimation_control$quad_points),
      class = c("mfrmr_mml_accuracy_error", "error", "condition")))
  }
  for (stage in seq_len(length(orders) + 1L)) {
    adaptive <- stage > 1L
    nodes <- if (adaptive) orders[stage - 1L] else initial_nodes
    check_order <- if (adaptive) nodes else orders[1L]
    config$estimation_control$mml_integration <- if (adaptive) "adaptive" else "fixed"
    config$estimation_control$quad_points <- nodes
    row <- data.frame(Stage = stage, Integration = config$estimation_control$mml_integration,
      QuadPoints = nodes, ReferencePoints = 2L * check_order + 1L,
      OptimizerConvergence = NA_integer_, LogLik = NA_real_, ParameterChange = NA_real_,
      MaxLogMarginalDifference = NA_real_, MaxEAPDifference = NA_real_,
      MaxPosteriorSDDifference = NA_real_, MaxGradientDifference = NA_real_,
      MaxGradient = NA_real_, Status = "unavailable", Detail = "", stringsAsFactors = FALSE)
    opt <- tryCatch(run_mfrm_optimization(last_par, "MML", idx, config, sizes,
      nodes, maxit, reltol, optimizer, suppress_convergence_warning = TRUE), error = identity)
    if (inherits(opt, "error")) {
      row$Detail <- conditionMessage(opt)
      history[[stage]] <- row
      fail(row$Detail)
    }
    row$OptimizerConvergence <- opt$convergence
    row$LogLik <- -opt$value
    row$ParameterChange <- if (stage == 1L) NA_real_ else max(abs(opt$par - last_par), 0)
    last_par <- opt$par
    checked <- tryCatch(mfrmr_check_mml_accuracy(opt, idx, config, sizes, labels,
      check_order, control), error = identity)
    if (inherits(checked, "error")) {
      row$Detail <- conditionMessage(checked)
    } else {
      row[names(checked$metrics)] <- as.list(checked$metrics)
      row$Status <- if (checked$passed) "criteria_met" else "refinement_required"
    }
    history[[stage]] <- row
    if (!inherits(checked, "error") && checked$passed) {
      config$mml_accuracy <- list(status = "criteria_met", control = control,
        history = do.call(rbind, history), per_person = checked$per_person,
        scope = "integration_and_stationarity_at_retained_calibration")
      return(list(opt = opt, config = config))
    }
  }
  fail("the specified adaptive orders were exhausted before all criteria were met.")
}
