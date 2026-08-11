# mfrmr 0.2.3 bounded GPCM joint zero-variance/log-slope P1d audit
#
# P1c proved the sigma2 -> 0+ likelihood identity only for fixed finite
# nuisance coordinates. P1d deliberately studies a non-uniform sequence:
#   v(t) = v0 exp(-2 t),
#   log a_target(t) = log a_target(0) + t,
#   log a_other(t) = log a_other(0) - t / (J - 1).
# The sum-zero log-slope identification is preserved and
# a_target(t) * sqrt(v(t)) is constant. The fixed-nuisance q=1 limit therefore
# cannot be transported to this joint path. Every finite point is optimized
# and evaluated with standardized-normal quadrature. This is a bounded local
# recession diagnostic, not a global boundary profile or solution selector.

mfrmr_gjs_p1d_specification <- "0.2.3-draft.1"
mfrmr_gjs_p1d_contract <-
  "mfrmr_gpcm_zero_variance_log_slope_path_p1d_v1"
mfrmr_gjs_p1d_dependency_contract <-
  "mfrmr_gpcm_zero_variance_boundary_p1c_v1"
mfrmr_gjs_p1d_dependency_sha256 <-
  "9feeabfc715d32bc7056e116c58273dcc82363e2111363c1df42d485f6afd8f5"
mfrmr_gjs_p1d_scenarios <- c(
  "EXT5-P-HI", "EXT5-P-LO", "EXT5-P-NEAR-HI", "EXT5-P-NEAR-LO"
)
mfrmr_gjs_p1d_routes <- c("interior_forward", "boundary_reverse")
mfrmr_gjs_p1d_t_ladder <- c(0, 2, 4, 6, 8, 10)
mfrmr_gjs_p1d_quadrature <- c(61L, 91L, 121L)
mfrmr_gjs_p1d_derivative_steps <- c(1e-4, 1e-5, 1e-6)

mfrmr_gjs_p1d_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gjs_p1d_require_sources <- function() {
  target <- environment(mfrmr_gjs_p1d_require_sources)
  required <- c(
    "mfrmr_gzb_p1c_contract",
    "mfrmr_run_gpcm_zero_variance_boundary_p1c",
    "mfrmr_gqi_p1b_context", "mfrmr_num_central_gradient",
    "mfrmr_gss_get", "mfrmr_gss_hash_vector",
    "mfrmr_gss_semantic_vector", "mfrmr_gss_compare_signatures"
  )
  available <- vapply(
    required, exists, logical(1), envir = target, inherits = TRUE
  )
  mfrmr_gjs_p1d_assert(
    all(available) && identical(
      get("mfrmr_gzb_p1c_contract", envir = target, inherits = TRUE),
      mfrmr_gjs_p1d_dependency_contract
    ),
    paste0(
      "Source the numerical P0, endpoint P0b, population-variance P1a, ",
      "quadrature P1b, zero-boundary P1c, and their dependencies before P1d."
    )
  )
  invisible(TRUE)
}

mfrmr_gjs_p1d_plan <- function() {
  path <- expand.grid(
    ScenarioId = mfrmr_gjs_p1d_scenarios,
    RouteId = mfrmr_gjs_p1d_routes,
    T = mfrmr_gjs_p1d_t_ladder,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  path$ScenarioOrder <- match(path$ScenarioId, mfrmr_gjs_p1d_scenarios)
  path$RouteOrder <- match(path$RouteId, mfrmr_gjs_p1d_routes)
  path$PathOrder <- match(path$T, mfrmr_gjs_p1d_t_ladder)
  path <- path[order(
    path$ScenarioOrder, path$RouteOrder, path$PathOrder
  ), , drop = FALSE]
  rownames(path) <- NULL
  path$OptimizationQuadrature <- 121L
  path$EvaluationQuadrature <- "61,91,121"
  path$SelectionAuthorized <- FALSE
  path$ConfirmationAuthorized <- FALSE
  list(
    path = path,
    direction_source =
      "lowest_finite_p1c_boundary_trace_diagnostic_only",
    direction_family = "one_dominant_sum_zero_log_slope_ray",
    variance_rate = -2,
    fixed_nuisance_q1_transport_authorized = FALSE,
    upper_variance_boundary_evaluated = FALSE,
    selection_authorized = FALSE,
    confirmation_authorized = FALSE
  )
}

mfrmr_gjs_p1d_direction <- function(n_levels, target_index) {
  n_levels <- suppressWarnings(as.integer(n_levels)[1L])
  target_index <- suppressWarnings(as.integer(target_index)[1L])
  mfrmr_gjs_p1d_assert(
    is.finite(n_levels) && n_levels >= 2L && is.finite(target_index) &&
      target_index >= 1L && target_index <= n_levels,
    "P1d requires a valid target among at least two slope levels."
  )
  direction <- rep(-1 / (n_levels - 1), n_levels)
  direction[target_index] <- 1
  mfrmr_gjs_p1d_assert(
    abs(sum(direction)) <= .Machine$double.eps * n_levels,
    "P1d joint direction must preserve sum-zero log slopes."
  )
  direction
}

mfrmr_gjs_p1d_limit_contract <- function(n_levels = 4L) {
  direction <- mfrmr_gjs_p1d_direction(n_levels, 1L)
  data.frame(
    NaturalVariancePath = "v0_exp_minus_2t",
    TargetLogSlopeRate = direction[1L],
    OtherLogSlopeRate = direction[2L],
    ExpandedLogSlopeRateSum = sum(direction),
    TargetLogEffectiveSdRate = direction[1L] - 1,
    OtherLogEffectiveSdRate = direction[2L] - 1,
    SumZeroIdentificationPreserved = abs(sum(direction)) <=
      .Machine$double.eps * n_levels,
    TargetSlopeTimesSdInvariant = identical(direction[1L] - 1, 0),
    FixedFiniteNuisanceAssumptionPreserved = FALSE,
    FixedNuisanceQ1LimitTransportAuthorized = FALSE,
    StandardNormalQuadratureRetained = TRUE,
    GlobalJointBoundaryProfileCertified = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gjs_p1d_geometry <- function(p1c, scenario_id) {
  rows <- p1c$boundary_candidates
  rows <- rows[
    rows$ScenarioId == scenario_id & rows$FitReturned &
      is.finite(rows$BoundaryObjective), , drop = FALSE
  ]
  mfrmr_gjs_p1d_assert(
    nrow(rows) > 0L,
    paste0("P1d has no finite P1c diagnostic trace for ", scenario_id, ".")
  )
  selected <- rows[which.min(rows$BoundaryObjective), , drop = FALSE]
  key <- paste(scenario_id, selected$StartId, sep = "::")
  candidate <- p1c$boundary_candidate_objects[[key]]
  interior <- p1c$interior_candidate_objects[[scenario_id]]
  mfrmr_gjs_p1d_assert(
    is.list(candidate) && is.data.frame(candidate$semantic) &&
      is.list(interior) && is.list(interior$opt) &&
      length(interior$opt$par) > 0L && all(is.finite(interior$opt$par)),
    paste0("P1d geometry inputs are incomplete for ", scenario_id, ".")
  )
  boundary_log <- candidate$semantic[
    candidate$semantic$ParameterClass == "log_slope",
    c("SemanticKey", "Value"),
    drop = FALSE
  ]
  mfrmr_gjs_p1d_assert(
    nrow(boundary_log) >= 2L && all(is.finite(boundary_log$Value)),
    paste0("P1d boundary log-slope geometry is incomplete for ", scenario_id, ".")
  )
  target_index <- which.max(boundary_log$Value)
  direction <- mfrmr_gjs_p1d_direction(nrow(boundary_log), target_index)
  data.frame(
    ScenarioId = scenario_id,
    GeometrySourceStartId = as.character(selected$StartId),
    GeometrySourceBoundaryObjective = as.numeric(selected$BoundaryObjective),
    GeometrySourceBoundaryEligible = isTRUE(
      selected$BoundaryComparisonEligible
    ),
    TargetSlopeIndex = target_index,
    TargetSlopeKey = as.character(boundary_log$SemanticKey[target_index]),
    TargetBoundaryLogSlope = as.numeric(boundary_log$Value[target_index]),
    SlopeLevels = nrow(boundary_log),
    DirectionSum = sum(direction),
    DirectionMaximum = max(direction),
    DirectionMinimum = min(direction),
    DirectionSourceStatus = "diagnostic_nonselection_geometry",
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gjs_p1d_fixed_path <- function(
    context,
    anchor_par,
    target_index,
    t) {
  anchor_par <- as.numeric(anchor_par)
  t <- suppressWarnings(as.numeric(t)[1L])
  sigma_index <- as.integer(context$slices$log_sigma2)
  slope_index <- as.integer(context$slices$log_slopes)
  params <- mfrmr_gss_get("expand_params")(
    anchor_par, context$sizes, context$config
  )
  anchor_log_slopes <- as.numeric(params$log_slopes)
  anchor_log_sigma2 <- as.numeric(params$population$log_sigma2)
  direction <- mfrmr_gjs_p1d_direction(
    length(anchor_log_slopes), target_index
  )
  expanded_log_slopes <- anchor_log_slopes + t * direction
  fixed_index <- c(slope_index, sigma_index)
  fixed_value <- c(
    expanded_log_slopes[seq_along(slope_index)],
    anchor_log_sigma2 - 2 * t
  )
  path_direction <- rep(0, length(anchor_par))
  path_direction[slope_index] <- direction[seq_along(slope_index)]
  path_direction[sigma_index] <- -2
  full <- anchor_par
  full[fixed_index] <- fixed_value
  expanded <- mfrmr_gss_get("expand_params")(
    full, context$sizes, context$config
  )
  target_effective_log_scale <-
    expanded$log_slopes[target_index] +
      0.5 * expanded$population$log_sigma2
  list(
    par = full,
    fixed_index = fixed_index,
    fixed_value = fixed_value,
    nuisance_index = setdiff(seq_along(full), fixed_index),
    path_direction = path_direction,
    expanded_log_slopes = as.numeric(expanded$log_slopes),
    slopes = as.numeric(expanded$slopes),
    log_sigma2 = as.numeric(expanded$population$log_sigma2),
    sigma2 = as.numeric(expanded$population$sigma2),
    target_effective_log_scale = target_effective_log_scale,
    direction = direction
  )
}

mfrmr_gjs_p1d_optimize <- function(
    context,
    start_par,
    fixed_index,
    fixed_value,
    maxit,
    reltol) {
  start_par <- as.numeric(start_par)
  fixed_index <- as.integer(fixed_index)
  fixed_value <- as.numeric(fixed_value)
  nuisance_index <- setdiff(seq_along(start_par), fixed_index)
  mfrmr_gjs_p1d_assert(
    length(start_par) == nrow(context$coordinates) &&
      all(is.finite(start_par)) && length(fixed_index) == length(fixed_value) &&
      !anyDuplicated(fixed_index) && all(fixed_index %in% seq_along(start_par)),
    "P1d constrained optimization received invalid coordinates."
  )
  embed <- function(nuisance) {
    full <- start_par
    full[nuisance_index] <- as.numeric(nuisance)
    full[fixed_index] <- fixed_value
    full
  }
  value <- function(nuisance) {
    tryCatch(
      suppressWarnings(as.numeric(context$fn(embed(nuisance)))[1L]),
      mfrmr_gpcm_slope_numeric_boundary_error = function(condition) 1e100
    )
  }
  gradient <- function(nuisance) {
    as.numeric(context$gr(embed(nuisance)))[nuisance_index]
  }
  warnings <- character(0)
  run_stage <- function(start, method, stage_reltol, index, label) {
    control <- mfrmr_gss_get("build_mfrm_optim_control")(
      method, maxit = as.integer(maxit), reltol = as.numeric(stage_reltol)
    )
    stage_error <- ""
    started <- proc.time()[["elapsed"]]
    opt <- tryCatch(
      withCallingHandlers(
        stats::optim(
          par = start, fn = value, gr = gradient,
          method = method, control = control
        ),
        warning = function(condition) {
          warnings <<- c(warnings, conditionMessage(condition))
          invokeRestart("muffleWarning")
        }
      ),
      error = function(condition) {
        stage_error <<- conditionMessage(condition)
        NULL
      }
    )
    elapsed <- proc.time()[["elapsed"]] - started
    if (is.null(opt)) {
      return(list(
        index = index, label = label, method = method,
        reltol = stage_reltol, control = control, opt = NULL,
        diagnostics = list(
          ConvergenceCode = NA_integer_,
          ConvergenceStatus = "not_returned",
          ConvergenceReason = "joint_path_fit_failed",
          ConvergenceSeverity = "fail",
          GradientReviewTolerance = max(1e-4, 10 * stage_reltol),
          TerminalGradientSupNorm = NA_real_
        ),
        elapsed = elapsed, error = stage_error
      ))
    }
    stage_gradient <- tryCatch(
      suppressWarnings(as.numeric(gradient(opt$par))),
      error = function(condition) rep(NA_real_, length(opt$par))
    )
    list(
      index = index, label = label, method = method,
      reltol = stage_reltol, control = control, opt = opt,
      diagnostics = mfrmr_gss_get("build_optimizer_diagnostics")(
        opt = opt,
        gradient = stage_gradient,
        reltol = as.numeric(stage_reltol),
        maxit = as.integer(maxit),
        optimizer_method = method,
        convergence_basis = "optimizer_gradient"
      ),
      elapsed = elapsed, error = stage_error
    )
  }
  stages <- list(run_stage(
    start_par[nuisance_index], "L-BFGS-B", reltol, 1L, "initial"
  ))
  selected <- stages[[1L]]
  if (!is.null(selected$opt) &&
      !identical(selected$diagnostics$ConvergenceSeverity, "pass")) {
    stage_index <- 1L
    for (stage_reltol in mfrmr_gss_get(
      "mfrm_optimizer_polish_tolerances"
    )(reltol)) {
      stage_index <- stage_index + 1L
      candidate <- run_stage(
        selected$opt$par, "L-BFGS-B", stage_reltol,
        stage_index, "gradient_polish"
      )
      stages[[length(stages) + 1L]] <- candidate
      if (!is.null(candidate$opt) &&
          mfrmr_gss_get("mfrm_optimizer_stage_is_better")(
            candidate, selected
          )) {
        selected <- candidate
      }
      if (identical(selected$diagnostics$ConvergenceSeverity, "pass")) break
    }
    if (!identical(selected$diagnostics$ConvergenceSeverity, "pass")) {
      for (stage_reltol in c(1e-13, 1e-14)) {
        stage_index <- stage_index + 1L
        candidate <- run_stage(
          selected$opt$par, "BFGS", stage_reltol,
          stage_index, "bfgs_polish"
        )
        stages[[length(stages) + 1L]] <- candidate
        if (!is.null(candidate$opt) &&
            mfrmr_gss_get("mfrm_optimizer_stage_is_better")(
              candidate, selected
            )) {
          selected <- candidate
        }
        if (identical(selected$diagnostics$ConvergenceSeverity, "pass")) break
      }
    }
  }
  returned <- !is.null(selected$opt) &&
    length(selected$opt$par) == length(nuisance_index) &&
    all(is.finite(selected$opt$par))
  par <- if (returned) embed(selected$opt$par) else {
    rep(NA_real_, length(start_par))
  }
  list(
    returned = returned,
    par = par,
    fixed_index = fixed_index,
    fixed_value = fixed_value,
    nuisance_index = nuisance_index,
    selected = selected,
    stages = stages,
    warnings = unique(warnings),
    errors = unique(vapply(stages, `[[`, character(1L), "error")),
    elapsed = sum(vapply(stages, `[[`, numeric(1L), "elapsed"))
  )
}

mfrmr_gjs_p1d_path_point <- function(
    scenario_id,
    route_id,
    context,
    evaluation_contexts,
    anchor_par,
    target_index,
    t,
    start_par,
    maxit,
    reltol) {
  fixed <- mfrmr_gjs_p1d_fixed_path(
    context, anchor_par, target_index, t
  )
  start_par <- as.numeric(start_par)
  start_par[fixed$fixed_index] <- fixed$fixed_value
  optimized <- mfrmr_gjs_p1d_optimize(
    context = context,
    start_par = start_par,
    fixed_index = fixed$fixed_index,
    fixed_value = fixed$fixed_value,
    maxit = maxit,
    reltol = reltol
  )
  returned <- isTRUE(optimized$returned)
  par <- optimized$par
  objective <- NA_real_
  gradient <- numeric(0)
  semantic <- data.frame()
  quadrature_objectives <- setNames(
    rep(NA_real_, length(evaluation_contexts)), names(evaluation_contexts)
  )
  derivative_audit <- data.frame()
  if (returned) {
    objective <- tryCatch(
      suppressWarnings(as.numeric(context$fn(par))[1L]),
      error = function(condition) NA_real_
    )
    gradient <- tryCatch(
      suppressWarnings(as.numeric(context$gr(par))),
      error = function(condition) rep(NA_real_, length(par))
    )
    quadrature_objectives <- vapply(
      evaluation_contexts,
      function(value) tryCatch(
        suppressWarnings(as.numeric(value$fn(par))[1L]),
        error = function(condition) NA_real_
      ),
      numeric(1L)
    )
    semantic <- tryCatch(
      mfrmr_gss_semantic_vector(context, par),
      error = function(condition) data.frame()
    )
    fixed_nuisance_path <- function(delta) {
      full <- par + as.numeric(delta)[1L] * fixed$path_direction
      tryCatch(
        suppressWarnings(as.numeric(context$fn(full))[1L]),
        error = function(condition) NA_real_
      )
    }
    derivative_audit <- do.call(rbind, lapply(
      mfrmr_gjs_p1d_derivative_steps,
      function(step) {
        numeric_value <- (
          fixed_nuisance_path(step) - fixed_nuisance_path(-step)
        ) / (2 * step)
        analytic_value <- if (
          length(gradient) == length(fixed$path_direction) &&
            all(is.finite(gradient))
        ) sum(gradient * fixed$path_direction) else NA_real_
        data.frame(
          ScenarioId = scenario_id,
          RouteId = route_id,
          T = t,
          RelativeStep = step,
          AnalyticPathDerivative = analytic_value,
          NumericFixedNuisancePathDerivative = numeric_value,
          AnalyticNumericAbsDifference = if (
            is.finite(analytic_value) && is.finite(numeric_value)
          ) abs(analytic_value - numeric_value) else NA_real_,
          SelectionAuthorized = FALSE,
          ConfirmationAuthorized = FALSE,
          stringsAsFactors = FALSE
        )
      }
    ))
  }
  diagnostics <- optimized$selected$diagnostics %||% list()
  severity <- as.character(
    diagnostics$ConvergenceSeverity %||% "fail"
  )[1L]
  fixed_exact <- returned && identical(
    as.numeric(par[fixed$fixed_index]), as.numeric(fixed$fixed_value)
  )
  nuisance_gradient <- if (
    length(gradient) == length(par) && all(is.finite(gradient))
  ) gradient[fixed$nuisance_index] else numeric(0)
  analytic_path_derivative <- if (
    length(gradient) == length(par) && all(is.finite(gradient))
  ) sum(gradient * fixed$path_direction) else NA_real_
  derivative_difference <- if (nrow(derivative_audit) > 0L) {
    derivative_audit$AnalyticNumericAbsDifference
  } else numeric(0)
  complete <- returned && is.finite(objective) && fixed_exact &&
    length(nuisance_gradient) == length(fixed$nuisance_index) &&
    all(is.finite(nuisance_gradient)) &&
    all(is.finite(quadrature_objectives)) &&
    is.finite(analytic_path_derivative) && nrow(semantic) > 0L
  eligible <- complete && identical(severity, "pass")
  log_slopes <- if (nrow(semantic) > 0L) {
    semantic$Value[semantic$ParameterClass == "log_slope"]
  } else numeric(0)
  slopes <- if (nrow(semantic) > 0L) {
    semantic$Value[semantic$ParameterClass == "slope"]
  } else numeric(0)
  row <- data.frame(
    ScenarioId = scenario_id,
    RouteId = route_id,
    T = t,
    PathOrder = match(t, mfrmr_gjs_p1d_t_ladder),
    TargetSlopeIndex = target_index,
    OptimizationQuadrature = as.integer(context$quad_points),
    Sigma2 = fixed$sigma2,
    LogSigma2 = fixed$log_sigma2,
    TargetEffectiveLogScale = fixed$target_effective_log_scale,
    ExpandedLogSlopeSum = sum(fixed$expanded_log_slopes),
    MinimumPrescribedSlope = min(fixed$slopes),
    MaximumPrescribedSlope = max(fixed$slopes),
    PrescribedSlopeRatio = max(fixed$slopes) / min(fixed$slopes),
    FitReturned = returned,
    ObjectiveQ121 = objective,
    ObjectiveQ61 = as.numeric(quadrature_objectives[["61"]]),
    ObjectiveQ91 = as.numeric(quadrature_objectives[["91"]]),
    QuadratureObjectiveRange = if (all(is.finite(quadrature_objectives))) {
      diff(range(quadrature_objectives))
    } else NA_real_,
    NuisanceGradientMaxAbs = if (length(nuisance_gradient) > 0L) {
      max(abs(nuisance_gradient))
    } else NA_real_,
    AnalyticProfilePathDerivative = analytic_path_derivative,
    MinimumAnalyticNumericPathDerivativeAbsDifference = if (
      any(is.finite(derivative_difference))
    ) min(derivative_difference, na.rm = TRUE) else NA_real_,
    MaximumReturnedLogSlopeAbs = if (
      length(log_slopes) > 0L && all(is.finite(log_slopes))
    ) max(abs(log_slopes)) else NA_real_,
    MaximumReturnedSlope = if (
      length(slopes) > 0L && all(is.finite(slopes))
    ) max(slopes) else NA_real_,
    FixedCoordinatesExact = fixed_exact,
    ConvergenceCode = suppressWarnings(as.integer(
      diagnostics$ConvergenceCode %||% NA_integer_
    )[1L]),
    ConvergenceStatus = as.character(
      diagnostics$ConvergenceStatus %||% "not_returned"
    )[1L],
    ConvergenceReason = as.character(
      diagnostics$ConvergenceReason %||% "not_returned"
    )[1L],
    ConvergenceSeverity = severity,
    ExistingNuisanceStationarityPass = identical(severity, "pass"),
    PathPointEligible = eligible,
    PathPointEligibilityReason = if (eligible) {
      "fixed_joint_coordinates_and_nuisance_stationarity_complete"
    } else if (complete) {
      "joint_path_complete_but_nuisance_stationarity_not_passed"
    } else {
      "joint_path_or_derivative_incomplete"
    },
    FixedNuisanceQ1TransportAuthorized = FALSE,
    ContinuousIntegralCertified = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    ElapsedSeconds = optimized$elapsed,
    WarningCount = length(optimized$warnings),
    WarningText = paste(optimized$warnings, collapse = " | "),
    ErrorText = paste(
      optimized$errors[nzchar(optimized$errors)], collapse = " | "
    ),
    StartVectorSHA256 = mfrmr_gss_hash_vector(start_par),
    ReturnedVectorSHA256 = if (returned) {
      mfrmr_gss_hash_vector(par)
    } else NA_character_,
    stringsAsFactors = FALSE
  )
  list(
    row = row,
    par = par,
    semantic = semantic,
    derivative_audit = derivative_audit,
    optimized = optimized
  )
}

mfrmr_gjs_p1d_run_route <- function(
    scenario_id,
    route_id,
    contexts,
    anchor_par,
    boundary_seed_par,
    target_index,
    maxit,
    reltol,
    progress = FALSE) {
  mfrmr_gjs_p1d_assert(
    route_id %in% mfrmr_gjs_p1d_routes,
    "P1d received an undeclared route."
  )
  order <- if (identical(route_id, "interior_forward")) {
    mfrmr_gjs_p1d_t_ladder
  } else rev(mfrmr_gjs_p1d_t_ladder)
  current <- if (identical(route_id, "interior_forward")) {
    as.numeric(anchor_par)
  } else as.numeric(boundary_seed_par)
  objects <- list()
  rows <- list()
  derivatives <- list()
  for (index in seq_along(order)) {
    t <- order[index]
    if (isTRUE(progress)) {
      message(
        "Joint zero/slope P1d: ", scenario_id, " / ", route_id,
        " / t=", t
      )
    }
    point <- mfrmr_gjs_p1d_path_point(
      scenario_id = scenario_id,
      route_id = route_id,
      context = contexts[["121"]],
      evaluation_contexts = contexts,
      anchor_par = anchor_par,
      target_index = target_index,
      t = t,
      start_par = current,
      maxit = maxit,
      reltol = reltol
    )
    key <- sprintf("t_%02d", as.integer(t))
    objects[[key]] <- point
    rows[[index]] <- point$row
    derivatives[[index]] <- point$derivative_audit
    if (isTRUE(point$row$FitReturned)) current <- point$par
  }
  table <- do.call(rbind, rows)
  table <- table[order(table$T), , drop = FALSE]
  rownames(table) <- NULL
  derivative_table <- do.call(rbind, derivatives)
  derivative_table <- derivative_table[order(
    derivative_table$T, derivative_table$RelativeStep
  ), , drop = FALSE]
  rownames(derivative_table) <- NULL
  list(points = table, objects = objects, derivative_audit = derivative_table)
}

mfrmr_gjs_p1d_route_summary <- function(path_points) {
  groups <- split(
    path_points,
    interaction(
      path_points$ScenarioId, path_points$RouteId,
      drop = TRUE, lex.order = TRUE
    )
  )
  rows <- lapply(groups, function(value) {
    value <- value[order(value$T), , drop = FALSE]
    eligible <- value$PathPointEligible & is.finite(value$ObjectiveQ121)
    all_eligible <- nrow(value) == length(mfrmr_gjs_p1d_t_ladder) &&
      all(eligible)
    objective_change <- diff(value$ObjectiveQ121)
    terminal <- value[nrow(value), , drop = FALSE]
    strictly_decreasing <- all_eligible && length(objective_change) > 0L &&
      all(objective_change < 0)
    strictly_increasing <- all_eligible && length(objective_change) > 0L &&
      all(objective_change > 0)
    terminal_negative <- all_eligible &&
      is.finite(terminal$AnalyticProfilePathDerivative) &&
      terminal$AnalyticProfilePathDerivative < 0
    terminal_positive <- all_eligible &&
      is.finite(terminal$AnalyticProfilePathDerivative) &&
      terminal$AnalyticProfilePathDerivative > 0
    status <- if (strictly_decreasing && terminal_negative) {
      "recession_signal_observed_not_certified"
    } else if (strictly_increasing && terminal_positive) {
      "increasing_path_observed_not_certified"
    } else if (all_eligible && terminal_positive) {
      "finite_turnback_signal_observed_not_certified"
    } else {
      "joint_path_inconclusive"
    }
    data.frame(
      ScenarioId = value$ScenarioId[1L],
      RouteId = value$RouteId[1L],
      DeclaredPoints = nrow(value),
      ReturnedPoints = sum(value$FitReturned),
      EligiblePoints = sum(value$PathPointEligible),
      AllPointsEligible = all_eligible,
      ObjectiveAtT0 = value$ObjectiveQ121[1L],
      ObjectiveAtTMax = terminal$ObjectiveQ121,
      ObjectiveChangeTMaxMinusT0 =
        terminal$ObjectiveQ121 - value$ObjectiveQ121[1L],
      StrictlyDecreasingObserved = strictly_decreasing,
      StrictlyIncreasingObserved = strictly_increasing,
      TerminalAnalyticPathDerivative =
        terminal$AnalyticProfilePathDerivative,
      MaximumQuadratureObjectiveRange = if (
        any(is.finite(value$QuadratureObjectiveRange))
      ) max(value$QuadratureObjectiveRange, na.rm = TRUE) else NA_real_,
      MaximumNuisanceGradient = if (
        any(is.finite(value$NuisanceGradientMaxAbs))
      ) max(value$NuisanceGradientMaxAbs, na.rm = TRUE) else NA_real_,
      TargetEffectiveLogScaleRange = if (
        all(is.finite(value$TargetEffectiveLogScale))
      ) diff(range(value$TargetEffectiveLogScale)) else NA_real_,
      MaximumPrescribedSlope = if (
        any(is.finite(value$MaximumPrescribedSlope))
      ) max(value$MaximumPrescribedSlope, na.rm = TRUE) else NA_real_,
      MaximumPrescribedSlopeRatio = if (
        any(is.finite(value$PrescribedSlopeRatio))
      ) max(value$PrescribedSlopeRatio, na.rm = TRUE) else NA_real_,
      RouteStatus = status,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_gjs_p1d_route_pairwise <- function(path_points) {
  rows <- lapply(
    split(path_points, interaction(path_points$ScenarioId, path_points$T)),
    function(value) {
      forward <- value[value$RouteId == "interior_forward", , drop = FALSE]
      reverse <- value[value$RouteId == "boundary_reverse", , drop = FALSE]
      complete <- nrow(forward) == 1L && nrow(reverse) == 1L
      data.frame(
        ScenarioId = value$ScenarioId[1L],
        T = value$T[1L],
        BothRoutesPresent = complete,
        BothRoutesEligible = complete && isTRUE(forward$PathPointEligible) &&
          isTRUE(reverse$PathPointEligible),
        ObjectiveAbsDifference = if (complete) {
          abs(forward$ObjectiveQ121 - reverse$ObjectiveQ121)
        } else NA_real_,
        PathDerivativeAbsDifference = if (complete) {
          abs(
            forward$AnalyticProfilePathDerivative -
              reverse$AnalyticProfilePathDerivative
          )
        } else NA_real_,
        RouteAgreementToleranceStatus = "not_frozen_calibration_only",
        SelectionAuthorized = FALSE,
        ConfirmationAuthorized = FALSE,
        stringsAsFactors = FALSE
      )
    }
  )
  out <- do.call(rbind, rows)
  out <- out[order(out$ScenarioId, out$T), , drop = FALSE]
  rownames(out) <- NULL
  out
}

mfrmr_gjs_p1d_decision <- function(scenario_id, route_summary) {
  value <- route_summary[
    route_summary$ScenarioId == scenario_id, , drop = FALSE
  ]
  mfrmr_gjs_p1d_assert(
    nrow(value) == length(mfrmr_gjs_p1d_routes) &&
      setequal(value$RouteId, mfrmr_gjs_p1d_routes),
    "P1d decision requires both declared routes."
  )
  all_eligible <- all(value$AllPointsEligible)
  both_recession <- all_eligible && all(
    value$RouteStatus == "recession_signal_observed_not_certified"
  )
  both_turnback <- all_eligible && all(value$RouteStatus %in% c(
    "finite_turnback_signal_observed_not_certified",
    "increasing_path_observed_not_certified"
  ))
  status <- if (both_recession) {
    "bounded_recession_signal_observed_not_certified"
  } else if (both_turnback) {
    "bounded_nonrecession_signal_observed_not_certified"
  } else {
    "bounded_joint_path_inconclusive"
  }
  data.frame(
    ScenarioId = scenario_id,
    BothRoutesCompleteAndEligible = all_eligible,
    ForwardRouteStatus = value$RouteStatus[
      value$RouteId == "interior_forward"
    ],
    ReverseRouteStatus = value$RouteStatus[
      value$RouteId == "boundary_reverse"
    ],
    JointZeroVarianceLogSlopePathStatus = status,
    FixedNuisanceQ1TransportAuthorized = FALSE,
    GlobalJointBoundaryProfileCertified = FALSE,
    UpperVarianceJointPathStatus = "not_evaluated",
    SolutionToleranceStatus = "not_frozen",
    SourceSolutionDecision =
      "blocked_global_joint_boundary_upper_boundary_and_selection_rule_unresolved",
    HessianAuthorized = FALSE,
    DFFFitRankAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gjs_p1d_signature <- function(decision_row) {
  mfrmr_gjs_p1d_assert(
    is.data.frame(decision_row) && nrow(decision_row) == 1L,
    "P1d signature requires one decision row."
  )
  joint_state <- as.character(
    decision_row$JointZeroVarianceLogSlopePathStatus
  )
  signature <- data.frame(
    Metric = c(
      "fixed_nuisance_zero_limit", "joint_zero_variance_log_slope_path",
      "fixed_nuisance_q1_transport", "global_joint_boundary_profile",
      "upper_joint_variance_boundary", "source_solution_selection",
      "hessian", "dff_fit_rank", "overall"
    ),
    State = c(
      "implemented_in_p1c",
      joint_state,
      "prohibited_nonuniform_limit",
      "not_certified",
      "not_evaluated",
      "blocked",
      "not_evaluated",
      "not_evaluated",
      "review"
    ),
    Eligibility = c(
      "fixed_finite_nuisance_only",
      "bounded_declared_ray_calibration_only",
      rep("not_selection_eligible", 7L)
    ),
    Reason = c(
      "q1_identity_and_direct_conditional_oracle_already_closed",
      "two_route_finite_q121_profile_along_one_declared_compensating_ray",
      "target_slope_times_population_sd_remains_constant",
      "one_local_ray_does_not_profile_all_joint_boundary_directions",
      "large_variance_joint_path_remains_separate",
      "global_boundaries_and_prespecified_selection_rule_remain_open",
      "source_solution_not_selected",
      "source_solution_not_selected",
      "p1d_bounded_joint_path_calibration_only"
    ),
    stringsAsFactors = FALSE
  )
  mfrmr_gjs_p1d_assert(
    !anyDuplicated(signature$Metric) && all(nzchar(signature$State)) &&
      all(nzchar(signature$Eligibility)) && all(nzchar(signature$Reason)),
    "P1d signatures require unique non-empty fields."
  )
  signature
}

mfrmr_run_gpcm_zero_variance_log_slope_path_p1d <- function(
    maxit = 600L,
    reltol = 1e-10,
    progress = FALSE) {
  mfrmr_gjs_p1d_require_sources()
  maxit <- suppressWarnings(as.integer(maxit)[1L])
  reltol <- suppressWarnings(as.numeric(reltol)[1L])
  mfrmr_gjs_p1d_assert(
    is.finite(maxit) && maxit > 0L && is.finite(reltol) && reltol > 0,
    "P1d requires finite positive optimization controls."
  )
  plan <- mfrmr_gjs_p1d_plan()
  limit_contract <- mfrmr_gjs_p1d_limit_contract()
  mfrmr_gjs_p1d_assert(
    isTRUE(limit_contract$SumZeroIdentificationPreserved) &&
      isTRUE(limit_contract$TargetSlopeTimesSdInvariant) &&
      !isTRUE(limit_contract$FixedNuisanceQ1LimitTransportAuthorized),
    "P1d non-uniform joint-limit contract is invalid."
  )
  # Preserve the recorded P1c execution identity. The P1d controls apply only
  # to the new constrained q=121 path fits.
  p1c <- mfrmr_run_gpcm_zero_variance_boundary_p1c(
    maxit = 800L, reltol = 1e-12, progress = progress
  )
  geometry_rows <- list()
  route_objects <- list()
  path_rows <- list()
  derivative_rows <- list()
  scenario_index <- route_index <- 1L
  for (scenario_id in mfrmr_gjs_p1d_scenarios) {
    geometry <- mfrmr_gjs_p1d_geometry(p1c, scenario_id)
    geometry_rows[[scenario_index]] <- geometry
    scenario_index <- scenario_index + 1L
    source <- p1c$p0b$scenario_results[[scenario_id]]
    contexts <- lapply(mfrmr_gjs_p1d_quadrature, function(q) {
      mfrmr_gqi_p1b_context(source$fit, q)
    })
    names(contexts) <- as.character(mfrmr_gjs_p1d_quadrature)
    anchor <- p1c$interior_candidate_objects[[scenario_id]]$opt$par
    boundary_key <- paste(
      scenario_id, geometry$GeometrySourceStartId, sep = "::"
    )
    boundary_seed <- p1c$boundary_candidate_objects[[boundary_key]]$par
    mfrmr_gjs_p1d_assert(
      length(anchor) == nrow(contexts[["121"]]$coordinates) &&
        length(boundary_seed) == length(anchor) &&
        all(is.finite(c(anchor, boundary_seed))),
      paste0("P1d route seeds are incomplete for ", scenario_id, ".")
    )
    for (route_id in mfrmr_gjs_p1d_routes) {
      route <- mfrmr_gjs_p1d_run_route(
        scenario_id = scenario_id,
        route_id = route_id,
        contexts = contexts,
        anchor_par = anchor,
        boundary_seed_par = boundary_seed,
        target_index = geometry$TargetSlopeIndex,
        maxit = maxit,
        reltol = reltol,
        progress = progress
      )
      key <- paste(scenario_id, route_id, sep = "::")
      route_objects[[key]] <- route
      path_rows[[route_index]] <- route$points
      derivative_rows[[route_index]] <- route$derivative_audit
      route_index <- route_index + 1L
    }
  }
  geometry_table <- do.call(rbind, geometry_rows)
  rownames(geometry_table) <- NULL
  path_points <- do.call(rbind, path_rows)
  path_points <- path_points[order(
    match(path_points$ScenarioId, mfrmr_gjs_p1d_scenarios),
    match(path_points$RouteId, mfrmr_gjs_p1d_routes),
    path_points$T
  ), , drop = FALSE]
  rownames(path_points) <- NULL
  derivative_audit <- do.call(rbind, derivative_rows)
  rownames(derivative_audit) <- NULL
  route_summary <- mfrmr_gjs_p1d_route_summary(path_points)
  route_pairwise <- mfrmr_gjs_p1d_route_pairwise(path_points)
  decisions <- do.call(rbind, lapply(
    mfrmr_gjs_p1d_scenarios,
    mfrmr_gjs_p1d_decision,
    route_summary = route_summary
  ))
  rownames(decisions) <- NULL
  signatures <- setNames(lapply(
    mfrmr_gjs_p1d_scenarios,
    function(scenario_id) {
      mfrmr_gjs_p1d_signature(decisions[
        decisions$ScenarioId == scenario_id, , drop = FALSE
      ])
    }
  ), mfrmr_gjs_p1d_scenarios)
  reflection_pairs <- list(
    exact = c("EXT5-P-HI", "EXT5-P-LO"),
    near = c("EXT5-P-NEAR-HI", "EXT5-P-NEAR-LO")
  )
  signature_comparisons <- do.call(rbind, lapply(
    names(reflection_pairs),
    function(pair_id) {
      pair <- reflection_pairs[[pair_id]]
      comparison <- mfrmr_gss_compare_signatures(
        signatures[[pair[1L]]], signatures[[pair[2L]]]
      )
      data.frame(
        Pair = pair_id,
        HighScenarioId = pair[1L],
        LowScenarioId = pair[2L],
        comparison,
        SelectionAuthorized = FALSE,
        ConfirmationAuthorized = FALSE,
        stringsAsFactors = FALSE
      )
    }
  ))
  structure(
    list(
      contract = mfrmr_gjs_p1d_contract,
      specification = mfrmr_gjs_p1d_specification,
      dependency_contract = mfrmr_gjs_p1d_dependency_contract,
      dependency_sha256 = mfrmr_gjs_p1d_dependency_sha256,
      plan = plan,
      limit_contract = limit_contract,
      geometry = geometry_table,
      path_points = path_points,
      path_derivative_audit = derivative_audit,
      route_objects = route_objects,
      route_summary = route_summary,
      route_pairwise = route_pairwise,
      decisions = decisions,
      decision_signatures = signatures,
      signature_comparisons = signature_comparisons,
      p1c = p1c,
      FixedNuisanceQ1TransportAuthorized = FALSE,
      GlobalJointBoundaryProfileCertified = FALSE,
      UpperVarianceJointPathStatus = "not_evaluated",
      SolutionToleranceStatus = "not_frozen",
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ),
    class = "mfrmr_gpcm_zero_variance_log_slope_path_p1d"
  )
}
