# Optional same-design, same-integration starting-value review for ordinary MML.

mfrmr_mml_start_vectors <- function(start, requested, map) {
  vectors <- list(default = as.numeric(start))
  if (is.numeric(requested) && !is.complex(requested) && is.null(dim(requested))) {
    if (!length(requested) || any(!is.finite(requested)))
      stop("`mml_starts` offsets must be a nonempty finite numeric vector.", call. = FALSE)
    offsets <- unique(as.numeric(requested[requested != 0]))
    for (i in seq_along(offsets))
      vectors[[paste0("offset_", i)]] <- start + offsets[i] * rep(c(1, -1), length.out = length(start))
  } else if (is.list(requested) && !is.data.frame(requested) && length(requested)) {
    labels <- names(requested)
    if (is.null(labels) || anyNA(labels) || any(!nzchar(labels)) ||
        anyDuplicated(labels) || "default" %in% labels)
      stop("Name each `mml_starts` list entry uniquely; 'default' is reserved.", call. = FALSE)
    for (label in labels) {
      value <- requested[[label]]
      keys <- names(value)
      if (!is.numeric(value) || is.complex(value) || !is.null(dim(value)) ||
          !length(value) || any(!is.finite(value)) || is.null(keys) ||
          anyNA(keys) || any(!nzchar(keys)) || anyDuplicated(keys) ||
          anyDuplicated(map$Coordinate) || any(!keys %in% map$Coordinate))
        stop("Each named start must contain finite values named by distinct `parameter_map$Coordinate` entries; unlisted coordinates use the default start.", call. = FALSE)
      candidate <- as.numeric(start)
      candidate[match(keys, map$Coordinate)] <- value
      vectors[[label]] <- candidate
    }
  } else {
    stop("`mml_starts` must be numeric offsets or a named list of named numeric coordinate values.", call. = FALSE)
  }
  lapply(vectors, function(x) stats::setNames(as.numeric(x), map$Coordinate))
}

mfrmr_run_mml_starts <- function(start, requested, prep, idx, config, sizes,
                                  quad_points, maxit, reltol, optimizer) {
  map <- mfrmr_mml_optimizer_parameter_map(prep, idx, config, sizes)
  starts <- mfrmr_mml_start_vectors(start, requested, map)
  evaluator <- make_mfrm_direct_evaluator("MML",
    make_param_cache(sizes, config, idx, is_mml = TRUE), idx, config, sizes,
    gauss_hermite_normal(quad_points))
  attempts <- rows <- vector("list", length(starts))
  names(attempts) <- names(starts)
  for (i in seq_along(starts)) {
    mfrmr_fit_progress(sprintf("MML starting-value review: attempt %d of %d", i, length(starts)))
    warnings <- character()
    opt <- NULL
    began <- proc.time()[["elapsed"]]
    result <- tryCatch(withCallingHandlers({
      opt <- run_mfrm_optimization(unname(starts[[i]]), "MML", idx, config, sizes,
        quad_points = quad_points, maxit = maxit, reltol = reltol, optimizer = optimizer)
      value <- evaluator$value(opt$par)
      gradient <- evaluator$gradient(opt$par)
      if (length(value) != 1L || !is.finite(value) || length(opt$par) != length(start) ||
          any(!is.finite(opt$par)) || length(gradient) != length(start) || any(!is.finite(gradient)))
        stop("Nonfinite or incomplete terminal objective, coordinates or gradient.")
      list(value = value, gradient = if (length(gradient)) max(abs(gradient)) else 0,
        gradient_rms = if (length(gradient)) sqrt(mean(gradient^2)) else 0)
    }, warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }), error = identity)
    failed <- inherits(result, "error")
    diagnostic <- opt$optimizer_diagnostics %||% list()
    if (!failed && identical(diagnostic$ConvergenceSeverity, "pass") &&
        !isTRUE(result$gradient <= diagnostic$GradientReviewTolerance)) {
      diagnostic$ConvergenceSeverity <- "review"
      diagnostic$ConvergenceStatus <- "gradient_review"
      diagnostic$ConvergenceReason <- "common_gradient_review"
      diagnostic$ConvergenceDetail <- "The common reevaluation did not pass the terminal-gradient tolerance."
      diagnostic$ReviewableWarning <- TRUE
    }
    if (!failed) {
      diagnostic$TerminalGradientSupNorm <- result$gradient
      diagnostic$TerminalGradientRMS <- result$gradient_rms
      opt$optimizer_diagnostics <- diagnostic
    }
    stages <- opt$optimizer_polish$Stages %||% data.frame()
    curvature <- stages$SmallestCurvature[which(stages$Selected %||% logical())]
    rows[[i]] <- data.frame(
      Start = names(starts)[i],
      EngineRequested = config$estimation_control$mml_engine_requested,
      EngineUsed = opt$mml_engine$Used %||% NA_character_,
      OptimizerNegativeLogLik = opt$value %||% NA_real_,
      NegativeLogLik = if (failed) NA_real_ else result$value,
      TerminalGradientSupNorm = if (failed) NA_real_ else result$gradient,
      GradientTolerance = diagnostic$GradientReviewTolerance %||% NA_real_,
      ConvergenceCode = opt$convergence %||% NA_integer_,
      NumericalStatus = if (failed) "error" else diagnostic$ConvergenceSeverity %||% "review",
      SmallestCurvature = if (length(curvature)) curvature[1L] else NA_real_,
      ElapsedSeconds = proc.time()[["elapsed"]] - began,
      Warning = paste(unique(warnings), collapse = " | "),
      Error = if (failed) conditionMessage(result) else "",
      stringsAsFactors = FALSE)
    attempts[i] <- list(opt)
  }
  table <- do.call(rbind, rows)
  table$Selected <- FALSE
  table$LogLikLoss <- NA_real_
  table$MaxAbsCoordinateChange <- NA_real_
  review <- list(table = table, parameter_map = map, starts = starts, attempts = attempts,
    integration = list(mode = config$estimation_control$mml_integration, points = quad_points),
    notes = c(
      "All attempts use the same prepared rows, weights, anchors, constraints and integration rule. The default start is always included.",
      "Selection uses the smallest reevaluated negative log likelihood among evaluable attempts, including unfinished attempts. Numerical and inferential readiness remain separate.",
      "Coordinate changes use free optimizer coordinates (including log slopes and log variance), not a common effect-size scale. Missing curvature means it was not evaluated.",
      "ElapsedSeconds covers optimization and common reevaluation for each attempt; preparation and subsequent fit diagnostics are excluded. Main fit iteration counts describe the selected optimizer.",
      "Agreement across these starts is not proof of a global maximum, accurate quadrature, identification or confidence-interval coverage. Inspect warnings and failures; use mml_quadrature_sensitivity() separately."))
  valid <- which(is.finite(table$NegativeLogLik))
  if (!length(valid)) {
    condition <- structure(list(message = "No MML start produced an evaluable result; inspect the error's $start_review.",
      call = NULL, start_review = review), class = c("mfrm_start_error", "error", "condition"))
    stop(condition)
  }
  # Never replace a better unfinished solution with a worse code-zero solution.
  selected <- valid[which.min(table$NegativeLogLik[valid])]
  opt <- attempts[[selected]]
  opt$value <- table$NegativeLogLik[selected]
  review$table$Selected <- seq_len(nrow(table)) == selected
  review$table$LogLikLoss <- table$NegativeLogLik - table$NegativeLogLik[selected]
  review$table$MaxAbsCoordinateChange <- vapply(seq_along(attempts), function(i) {
    if (!i %in% valid) return(NA_real_)
    if (!length(opt$par)) return(0)
    max(abs(attempts[[i]]$par - opt$par))
  }, numeric(1))
  opt$start_review <- review
  if (any(table$NumericalStatus != "pass") || any(nzchar(table$Warning)))
    warning("MML starting-value review retained warnings or non-passing attempts; inspect summary(fit)$starting_values and fit$opt$start_review before interpreting results.", call. = FALSE)
  opt
}

mfrmr_mml_start_tables <- function(fit) {
  review <- fit$opt$start_review
  if (is.null(review)) return(list())
  coordinates <- do.call(rbind, lapply(seq_along(review$starts), function(i) {
    map <- review$parameter_map
    terminal <- review$attempts[[i]]$par
    data.frame(Start = rep(names(review$starts)[i], nrow(map)), map,
      Initial = unname(review$starts[[i]]),
      Terminal = if (length(terminal) == nrow(map)) unname(terminal) else rep(NA_real_, nrow(map)),
      row.names = NULL)
  }))
  list(starting_values = review$table, starting_value_coordinates = coordinates,
    starting_value_notes = data.frame(Note = review$notes))
}
