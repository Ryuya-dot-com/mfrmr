# mfrmr 0.2.3 bounded GPCM zero-population-variance P1c audit
#
# For fixed nuisance coordinates eta, the Person marginal is
#   m_p(v; eta) = E[L_p(mu_p + sqrt(v) Z; eta)].
# The response likelihood is continuous and bounded by one, so dominated
# convergence gives m_p(v; eta) -> L_p(mu_p; eta) as v -> 0+. Standard-normal
# q=1 Gauss-Hermite has node 0 and weight 1 and therefore evaluates that
# degenerate likelihood exactly. P1c locally refits nuisance coordinates at
# that boundary, checks an independent conditional GPCM oracle, and inspects a
# one-sided natural-variance path. It does not adjudicate the upper/joint
# variance boundary or select a package solution.

mfrmr_gzb_p1c_specification <- "0.2.3-draft.1"
mfrmr_gzb_p1c_contract <- "mfrmr_gpcm_zero_variance_boundary_p1c_v1"
mfrmr_gzb_p1c_dependency_contract <-
  "mfrmr_gpcm_low_basin_quadrature_p1b_v1"
mfrmr_gzb_p1c_dependency_sha256 <-
  "80a53048c687d10011bdf9a5e389abc9b29458b60277ec28e75ad94a05aafd9a"
mfrmr_gzb_p1c_scenarios <- c(
  "EXT5-P-HI", "EXT5-P-LO", "EXT5-P-NEAR-HI", "EXT5-P-NEAR-LO"
)
mfrmr_gzb_p1c_boundary_starts <- c(
  "variance_low", "default", "zero_nuisance"
)
mfrmr_gzb_p1c_variance_ladder <- c(
  1e-2, 3e-3, 1e-3, 3e-4, 1e-4, 3e-5, 1e-5, 3e-6, 1e-6, 1e-7, 1e-8
)

mfrmr_gzb_p1c_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gzb_p1c_abs_difference <- function(left, right) {
  left <- suppressWarnings(as.numeric(left)[1L])
  right <- suppressWarnings(as.numeric(right)[1L])
  if (is.finite(left) && is.finite(right)) abs(left - right) else NA_real_
}

mfrmr_gzb_p1c_require_sources <- function() {
  target <- environment(mfrmr_gzb_p1c_require_sources)
  required <- c(
    "mfrmr_gqi_p1b_contract",
    "mfrmr_run_gpcm_endpoint_solution_stability_p0b",
    "mfrmr_gqi_p1b_context", "mfrmr_gqi_p1b_run_candidate",
    "mfrmr_gqi_p1b_candidate", "mfrmr_num_central_gradient",
    "mfrmr_gss_p0b_gradient_steps",
    "mfrmr_gss_get", "mfrmr_gss_hash_vector",
    "mfrmr_gss_semantic_vector", "mfrmr_gss_compare_signatures"
  )
  available <- vapply(
    required,
    exists,
    logical(1),
    envir = target,
    inherits = TRUE
  )
  mfrmr_gzb_p1c_assert(
    all(available) && identical(
      get("mfrmr_gqi_p1b_contract", envir = target, inherits = TRUE),
      mfrmr_gzb_p1c_dependency_contract
    ),
    paste0(
      "Source the numerical P0, endpoint P0b, population-variance P1a, ",
      "quadrature P1b, and their dependencies before P1c."
    )
  )
  invisible(TRUE)
}

mfrmr_gzb_p1c_plan <- function() {
  boundary <- expand.grid(
    ScenarioId = mfrmr_gzb_p1c_scenarios,
    StartId = mfrmr_gzb_p1c_boundary_starts,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  boundary$ScenarioOrder <- match(
    boundary$ScenarioId, mfrmr_gzb_p1c_scenarios
  )
  boundary$StartOrder <- match(
    boundary$StartId, mfrmr_gzb_p1c_boundary_starts
  )
  boundary <- boundary[order(
    boundary$ScenarioOrder, boundary$StartOrder
  ), , drop = FALSE]
  rownames(boundary) <- NULL
  boundary$BoundaryQuadrature <- 1L
  boundary$PathQuadrature <- 121L
  boundary$BoundaryStartEligible <- TRUE
  boundary$GlobalBoundaryProfileCertified <- FALSE
  boundary$SelectionAuthorized <- FALSE
  boundary$ConfirmationAuthorized <- FALSE

  interior <- data.frame(
    ScenarioOrder = seq_along(mfrmr_gzb_p1c_scenarios),
    ScenarioId = mfrmr_gzb_p1c_scenarios,
    StartId = "variance_low",
    NativeQuadrature = 61L,
    CommonEvaluationQuadrature = 121L,
    SourceBasis = "p1b_qualified_low_lane",
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  list(boundary = boundary, interior = interior)
}

mfrmr_gzb_p1c_zero_limit_contract <- function() {
  quad <- mfrmr_gss_get("gauss_hermite_normal")(1L)
  data.frame(
    Distribution = "N(mu, sigma2)",
    Limit = "sigma2_to_zero_from_above",
    ConditionalLikelihoodContinuous = TRUE,
    ConditionalLikelihoodBounded = TRUE,
    LimitJustification = "dominated_convergence_fixed_nuisance",
    BoundaryQuadrature = 1L,
    BoundaryNode = as.numeric(quad$nodes),
    BoundaryWeight = as.numeric(quad$weights),
    ExactDegenerateLikelihood = identical(as.numeric(quad$nodes), 0) &&
      identical(as.numeric(quad$weights), 1),
    NuisanceGlobalOptimumCertified = FALSE,
    UpperVarianceBoundaryEvaluated = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gzb_p1c_direct_degenerate_objective <- function(context, par) {
  params <- mfrmr_gss_get("expand_params")(
    as.numeric(par), context$sizes, context$config
  )
  population <- mfrmr_gss_get("materialize_population_spec")(
    context$config, params
  )
  person_ids <- seq_len(context$config$n_person)
  lookup <- as.integer(population$person_lookup[person_ids])
  mfrmr_gzb_p1c_assert(
    isTRUE(population$active) && length(lookup) == length(person_ids) &&
      !anyNA(lookup),
    "P1c degenerate oracle requires an aligned active population model."
  )
  design <- population$design_matrix[lookup, , drop = FALSE]
  beta <- as.numeric(population$coefficients)
  mfrmr_gzb_p1c_assert(
    ncol(design) == length(beta),
    "P1c population coefficients do not match the design matrix."
  )
  mu <- as.numeric(design %*% beta)
  base_eta <- mfrmr_gss_get("compute_base_eta")(
    context$idx, params, context$config
  )
  eta <- base_eta + mu[context$idx$person]
  step_cum <- t(apply(
    params$steps_mat,
    1L,
    function(value) c(0, cumsum(value))
  ))
  -mfrmr_gss_get("loglik_gpcm")(
    eta = eta,
    score_k = context$idx$score_k,
    step_cum_mat = step_cum,
    criterion_idx = context$idx$step_idx,
    slopes = params$slopes,
    slope_idx = context$idx$slope_idx,
    weight = context$idx$weight
  )
}

mfrmr_gzb_p1c_optimize_boundary <- function(
    context,
    start_par,
    maxit,
    reltol) {
  total_dimension <- nrow(context$coordinates)
  sigma_index <- as.integer(context$slices$log_sigma2)
  nuisance_index <- setdiff(seq_len(total_dimension), sigma_index)
  start_par <- as.numeric(start_par)
  mfrmr_gzb_p1c_assert(
    length(start_par) == total_dimension && all(is.finite(start_par)) &&
      length(sigma_index) == 1L,
    "P1c boundary optimization requires one finite full start vector."
  )
  embed <- function(nuisance, log_sigma2 = 0) {
    full <- start_par
    full[nuisance_index] <- as.numeric(nuisance)
    full[sigma_index] <- as.numeric(log_sigma2)
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
      method,
      maxit = as.integer(maxit),
      reltol = as.numeric(stage_reltol)
    )
    stage_error <- ""
    started <- proc.time()[["elapsed"]]
    opt <- tryCatch(
      withCallingHandlers(
        stats::optim(
          par = start,
          fn = value,
          gr = gradient,
          method = method,
          control = control
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
          ConvergenceReason = "boundary_fit_failed",
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
  full_par <- if (returned) {
    embed(selected$opt$par, log_sigma2 = 0)
  } else {
    rep(NA_real_, total_dimension)
  }
  list(
    returned = returned,
    par = full_par,
    nuisance_index = nuisance_index,
    sigma_index = sigma_index,
    selected = selected,
    stages = stages,
    warnings = unique(warnings),
    elapsed = sum(vapply(stages, `[[`, numeric(1L), "elapsed")),
    errors = unique(vapply(stages, `[[`, character(1L), "error"))
  )
}

mfrmr_gzb_p1c_boundary_candidate <- function(
    scenario_id,
    start_id,
    context,
    path_context,
    start_par,
    maxit,
    reltol) {
  optimized <- mfrmr_gzb_p1c_optimize_boundary(
    context, start_par, maxit, reltol
  )
  returned <- isTRUE(optimized$returned)
  par <- optimized$par
  objective <- oracle <- NA_real_
  gradient <- numeric(0)
  numeric_gradient <- numeric(0)
  derivative_audit <- data.frame()
  semantic <- data.frame()
  invariance <- rep(NA_real_, 3L)
  if (returned) {
    objective <- tryCatch(
      suppressWarnings(as.numeric(context$fn(par))[1L]),
      error = function(condition) NA_real_
    )
    oracle <- tryCatch(
      suppressWarnings(mfrmr_gzb_p1c_direct_degenerate_objective(
        context, par
      )),
      error = function(condition) NA_real_
    )
    gradient <- tryCatch(
      suppressWarnings(as.numeric(context$gr(par)))[optimized$nuisance_index],
      error = function(condition) rep(
        NA_real_, length(optimized$nuisance_index)
      )
    )
    nuisance_fn <- function(value) {
      full <- par
      full[optimized$nuisance_index] <- as.numeric(value)
      suppressWarnings(as.numeric(context$fn(full))[1L])
    }
    derivative_audit <- do.call(rbind, lapply(
      mfrmr_gss_p0b_gradient_steps,
      function(step) {
        numeric_value <- tryCatch(
          mfrmr_num_central_gradient(
            nuisance_fn,
            par[optimized$nuisance_index],
            step
          ),
          error = function(condition) rep(
            NA_real_, length(optimized$nuisance_index)
          )
        )
        data.frame(
          ScenarioId = scenario_id,
          StartId = start_id,
          RelativeStep = step,
          NumericGradientMaxAbs = if (
            length(numeric_value) > 0L && all(is.finite(numeric_value))
          ) max(abs(numeric_value)) else NA_real_,
          AnalyticNumericGradientMaxAbsDifference = if (
            length(numeric_value) == length(gradient) &&
              all(is.finite(c(numeric_value, gradient)))
          ) max(abs(numeric_value - gradient)) else NA_real_,
          BoundaryCandidateEligible = FALSE,
          SelectionAuthorized = FALSE,
          ConfirmationAuthorized = FALSE,
          stringsAsFactors = FALSE
        )
      }
    ))
    numeric_gradient <- tryCatch(
      mfrmr_num_central_gradient(
        nuisance_fn,
        par[optimized$nuisance_index],
        min(mfrmr_gss_p0b_gradient_steps)
      ),
      error = function(condition) rep(
        NA_real_, length(optimized$nuisance_index)
      )
    )
    semantic <- tryCatch(
      mfrmr_gss_semantic_vector(context, par),
      error = function(condition) data.frame()
    )
    invariance <- vapply(c(-32, 0, 32), function(log_sigma2) {
      full <- par
      full[optimized$sigma_index] <- log_sigma2
      tryCatch(
        suppressWarnings(as.numeric(context$fn(full))[1L]),
        error = function(condition) NA_real_
      )
    }, numeric(1L))
  }
  diagnostics <- optimized$selected$diagnostics %||% list()
  severity <- as.character(
    diagnostics$ConvergenceSeverity %||% "fail"
  )[1L]
  complete <- returned && is.finite(objective) && is.finite(oracle) &&
    length(gradient) == length(optimized$nuisance_index) &&
    all(is.finite(gradient)) && all(is.finite(numeric_gradient)) &&
    all(is.finite(invariance)) && nrow(semantic) > 0L
  eligible <- complete && identical(severity, "pass")
  if (nrow(derivative_audit) > 0L) {
    derivative_audit$BoundaryCandidateEligible <- eligible
  }
  path <- if (returned && is.finite(objective)) {
    do.call(rbind, lapply(
      seq_along(mfrmr_gzb_p1c_variance_ladder),
      function(index) {
        variance <- mfrmr_gzb_p1c_variance_ladder[index]
        full <- par
        full[optimized$sigma_index] <- log(variance)
        value <- tryCatch(
          suppressWarnings(as.numeric(path_context$fn(full))[1L]),
          error = function(condition) NA_real_
        )
        score <- tryCatch(
          suppressWarnings(as.numeric(path_context$gr(full)))[
            optimized$sigma_index
          ],
          error = function(condition) NA_real_
        )
        data.frame(
          ScenarioId = scenario_id,
          StartId = start_id,
          PathOrder = index,
          Sigma2 = variance,
          LogSigma2 = log(variance),
          Quadrature = as.integer(path_context$quad_points),
          Objective = value,
          ObjectiveMinusBoundary = if (is.finite(value)) {
            value - objective
          } else NA_real_,
          NaturalVarianceDifferenceQuotient = if (is.finite(value)) {
            (value - objective) / variance
          } else NA_real_,
          LogVarianceAnalyticGradient = as.numeric(score),
          BoundaryCandidateEligible = eligible,
          SelectionAuthorized = FALSE,
          ConfirmationAuthorized = FALSE,
          stringsAsFactors = FALSE
        )
      }
    ))
  } else {
    data.frame()
  }
  selected_stage <- optimized$selected
  log_slopes <- if (nrow(semantic) > 0L) {
    semantic$Value[semantic$ParameterClass == "log_slope"]
  } else numeric(0)
  slopes <- if (nrow(semantic) > 0L) {
    semantic$Value[semantic$ParameterClass == "slope"]
  } else numeric(0)
  derivative_difference <- if (nrow(derivative_audit) > 0L) {
    derivative_audit$AnalyticNumericGradientMaxAbsDifference
  } else numeric(0)
  smallest_derivative <- if (nrow(derivative_audit) > 0L) {
    derivative_audit[
      which.min(derivative_audit$RelativeStep), , drop = FALSE
    ]
  } else data.frame()
  row <- data.frame(
    ScenarioId = scenario_id,
    StartId = start_id,
    StartVectorSHA256 = mfrmr_gss_hash_vector(start_par),
    BoundaryQuadrature = 1L,
    PathQuadrature = as.integer(path_context$quad_points),
    TotalFreeDimension = nrow(context$coordinates),
    BoundaryFixedDimension = length(optimized$sigma_index),
    BoundaryNuisanceDimension = length(optimized$nuisance_index),
    DimensionIdentity = returned &&
      length(par) == nrow(context$coordinates),
    FitReturned = returned,
    BoundaryObjective = objective,
    DirectOracleObjective = oracle,
    BoundaryOracleAbsDifference = mfrmr_gzb_p1c_abs_difference(
      objective, oracle
    ),
    Q1LogSigma2InvarianceRange = if (all(is.finite(invariance))) {
      diff(range(invariance))
    } else NA_real_,
    BoundaryNuisanceGradientMaxAbs = if (length(gradient) > 0L &&
      all(is.finite(gradient))) max(abs(gradient)) else NA_real_,
    BoundarySmallestStepAnalyticNumericGradientMaxAbsDifference = if (
      length(gradient) == length(numeric_gradient) && length(gradient) > 0L &&
        all(is.finite(c(gradient, numeric_gradient)))
    ) max(abs(gradient - numeric_gradient)) else NA_real_,
    BoundaryMinimumAnalyticNumericGradientMaxAbsDifference = if (
      any(is.finite(derivative_difference))
    ) min(derivative_difference, na.rm = TRUE) else NA_real_,
    SmallestIndependentDerivativeStep = if (
      nrow(smallest_derivative) == 1L
    ) smallest_derivative$RelativeStep else NA_real_,
    MaximumAbsExpandedLogSlope = if (
      length(log_slopes) > 0L && all(is.finite(log_slopes))
    ) max(abs(log_slopes)) else NA_real_,
    MinimumExpandedSlope = if (
      length(slopes) > 0L && all(is.finite(slopes))
    ) min(slopes) else NA_real_,
    MaximumExpandedSlope = if (
      length(slopes) > 0L && all(is.finite(slopes))
    ) max(slopes) else NA_real_,
    ExpandedSlopeRatio = if (
      length(slopes) > 0L && all(is.finite(slopes)) && min(slopes) > 0
    ) max(slopes) / min(slopes) else NA_real_,
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
    ExistingBoundaryNuisancePass = identical(severity, "pass"),
    BoundaryComparisonEligible = eligible,
    BoundaryEligibilityReason = if (eligible) {
      "exact_zero_limit_nuisance_stationarity_and_oracle_complete"
    } else if (complete) {
      "exact_zero_limit_complete_but_nuisance_stationarity_not_passed"
    } else {
      "exact_zero_limit_or_oracle_incomplete"
    },
    SelectedMethod = as.character(selected_stage$method %||% NA_character_),
    SelectedReltol = as.numeric(selected_stage$reltol %||% NA_real_),
    OptimizationStages = length(optimized$stages),
    ZeroVarianceLikelihoodLimitImplemented = TRUE,
    NuisanceGlobalOptimumCertified = FALSE,
    JointVarianceSlopeBoundaryStatus = "not_evaluated",
    UpperVarianceBoundaryEvaluated = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    ElapsedSeconds = optimized$elapsed,
    WarningCount = length(optimized$warnings),
    WarningText = paste(optimized$warnings, collapse = " | "),
    ErrorText = paste(optimized$errors[nzchar(optimized$errors)], collapse = " | "),
    ReturnedVectorSHA256 = if (returned) {
      mfrmr_gss_hash_vector(par)
    } else NA_character_,
    stringsAsFactors = FALSE
  )
  list(
    row = row,
    par = par,
    semantic = semantic,
    path = path,
    derivative_audit = derivative_audit,
    optimized = optimized
  )
}

mfrmr_gzb_p1c_boundary_pairwise <- function(candidates) {
  keys <- names(candidates)
  scenario_ids <- unique(vapply(candidates, function(value) {
    as.character(value$row$ScenarioId)
  }, character(1L)))
  rows <- list()
  index <- 1L
  for (scenario_id in scenario_ids) {
    scenario_keys <- keys[vapply(candidates, function(value) {
      identical(as.character(value$row$ScenarioId), scenario_id)
    }, logical(1L))]
    for (pair in utils::combn(scenario_keys, 2L, simplify = FALSE)) {
      left <- candidates[[pair[1L]]]
      right <- candidates[[pair[2L]]]
      required <- c(
        "SemanticKey", "ParameterClass", "CoordinateSystem", "Value"
      )
      semantic <- if (
        all(required %in% names(left$semantic)) &&
          all(required %in% names(right$semantic))
      ) {
        merge(
          left$semantic[, required, drop = FALSE],
          right$semantic[, required, drop = FALSE],
          by = c("SemanticKey", "ParameterClass", "CoordinateSystem"),
          suffixes = c("Left", "Right"),
          all = FALSE,
          sort = FALSE
        )
      } else data.frame()
      if (nrow(semantic) > 0L) {
        keep <- !semantic$ParameterClass %in% c(
          "population_log_sigma2", "population_sigma2"
        )
        semantic <- semantic[keep, , drop = FALSE]
      }
      delta <- if (nrow(semantic) > 0L) {
        abs(semantic$ValueLeft - semantic$ValueRight)
      } else numeric(0)
      rows[[index]] <- data.frame(
        ScenarioId = scenario_id,
        LeftStartId = left$row$StartId,
        RightStartId = right$row$StartId,
        BothBoundaryEligible = isTRUE(
          left$row$BoundaryComparisonEligible
        ) && isTRUE(right$row$BoundaryComparisonEligible),
        BoundaryObjectiveAbsDifference = mfrmr_gzb_p1c_abs_difference(
          left$row$BoundaryObjective, right$row$BoundaryObjective
        ),
        MatchedNuisanceCoordinates = nrow(semantic),
        NuisanceSemanticMaxAbsDifference = if (
          length(delta) > 0L && all(is.finite(delta))
        ) max(delta) else NA_real_,
        NuisanceToleranceStatus = "not_frozen_calibration_only",
        SelectionAuthorized = FALSE,
        ConfirmationAuthorized = FALSE,
        stringsAsFactors = FALSE
      )
      index <- index + 1L
    }
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_gzb_p1c_boundary_summary <- function(candidate_rows) {
  rows <- lapply(unique(candidate_rows$ScenarioId), function(scenario_id) {
    value <- candidate_rows[
      candidate_rows$ScenarioId == scenario_id, , drop = FALSE
    ]
    eligible <- which(
      value$BoundaryComparisonEligible & is.finite(value$BoundaryObjective)
    )
    selected <- if (length(eligible) > 0L) {
      eligible[which.min(value$BoundaryObjective[eligible])]
    } else integer(0)
    data.frame(
      ScenarioId = scenario_id,
      DeclaredBoundaryStarts = nrow(value),
      ReturnedBoundaryStarts = sum(value$FitReturned),
      ExistingPassBoundaryStarts = sum(value$ExistingBoundaryNuisancePass),
      EligibleBoundaryStarts = length(eligible),
      DiagnosticBoundaryEnvelopeStart = if (length(selected) == 1L) {
        value$StartId[selected]
      } else NA_character_,
      DiagnosticBoundaryEnvelopeObjective = if (length(selected) == 1L) {
        value$BoundaryObjective[selected]
      } else NA_real_,
      BoundaryObjectiveRangeAcrossEligibleStarts = if (
        length(eligible) > 0L
      ) diff(range(value$BoundaryObjective[eligible])) else NA_real_,
      MaximumBoundaryOracleAbsDifference = if (
        any(is.finite(value$BoundaryOracleAbsDifference))
      ) max(value$BoundaryOracleAbsDifference, na.rm = TRUE) else NA_real_,
      MaximumQ1LogSigma2InvarianceRange = if (
        any(is.finite(value$Q1LogSigma2InvarianceRange))
      ) max(value$Q1LogSigma2InvarianceRange, na.rm = TRUE) else NA_real_,
      MaximumExpandedSlopeAcrossReturnedStarts = if (
        any(is.finite(value$MaximumExpandedSlope))
      ) max(value$MaximumExpandedSlope, na.rm = TRUE) else NA_real_,
      MaximumExpandedSlopeRatioAcrossReturnedStarts = if (
        any(is.finite(value$ExpandedSlopeRatio))
      ) max(value$ExpandedSlopeRatio, na.rm = TRUE) else NA_real_,
      ZeroVarianceLikelihoodLimitImplemented = TRUE,
      NuisanceGlobalOptimumCertified = FALSE,
      JointVarianceSlopeBoundaryStatus = "not_evaluated",
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_gzb_p1c_decision <- function(
    boundary_summary,
    interior_row,
    boundary_candidate) {
  mfrmr_gzb_p1c_assert(
    is.data.frame(boundary_summary) && nrow(boundary_summary) == 1L &&
      is.data.frame(interior_row) && nrow(interior_row) == 1L,
    "P1c decision requires one boundary and one interior summary."
  )
  path <- if (is.list(boundary_candidate) &&
    is.data.frame(boundary_candidate$path)) {
    boundary_candidate$path
  } else data.frame()
  smallest <- if (nrow(path) > 0L) {
    path[which.min(path$Sigma2), , drop = FALSE]
  } else data.frame()
  quotient <- if (nrow(path) > 0L) {
    path$NaturalVarianceDifferenceQuotient[
      is.finite(path$NaturalVarianceDifferenceQuotient)
    ]
  } else numeric(0)
  boundary_exact <- as.numeric(
    boundary_summary$DiagnosticBoundaryEnvelopeObjective
  )
  interior_common <- as.numeric(interior_row$CommonDenseObjective)
  boundary_proxy <- if (nrow(smallest) == 1L) {
    as.numeric(smallest$Objective)
  } else NA_real_
  all_negative <- length(quotient) == nrow(path) && length(quotient) > 0L &&
    all(quotient < 0)
  all_positive <- length(quotient) == nrow(path) && length(quotient) > 0L &&
    all(quotient > 0)
  data.frame(
    ScenarioId = boundary_summary$ScenarioId,
    InteriorNativeQuadrature = as.integer(interior_row$QuadPoints),
    InteriorCommonQuadrature = as.integer(
      interior_row$CommonEvaluationQuadrature
    ),
    InteriorQualified = isTRUE(interior_row$P1BComparisonEligible),
    InteriorCommonObjective = interior_common,
    BoundaryQualified = isTRUE(
      boundary_summary$EligibleBoundaryStarts > 0L
    ),
    BoundaryExactObjective = boundary_exact,
    BoundarySmallestPathSigma2 = if (nrow(smallest) == 1L) {
      smallest$Sigma2
    } else NA_real_,
    BoundarySmallestPathObjective = boundary_proxy,
    BoundaryContinuityAbsDifference = mfrmr_gzb_p1c_abs_difference(
      boundary_exact, boundary_proxy
    ),
    BoundaryExactMinusInteriorCommon = boundary_exact - interior_common,
    BoundaryProxyMinusInteriorCommon = boundary_proxy - interior_common,
    NaturalVarianceDifferenceQuotientMinimum = if (length(quotient)) {
      min(quotient)
    } else NA_real_,
    NaturalVarianceDifferenceQuotientMaximum = if (length(quotient)) {
      max(quotient)
    } else NA_real_,
    NaturalVarianceDirection = if (all_negative) {
      "negative_objective_derivative_toward_positive_variance_observed"
    } else if (all_positive) {
      "positive_objective_derivative_toward_positive_variance_observed"
    } else {
      "mixed_or_incomplete_one_sided_path"
    },
    ZeroBoundaryOrdering = if (
      is.finite(boundary_proxy) && is.finite(interior_common) &&
        boundary_proxy > interior_common
    ) {
      "interior_observed_lower_on_q121_proxy"
    } else if (is.finite(boundary_proxy) && is.finite(interior_common)) {
      "boundary_not_observed_worse_on_q121_proxy"
    } else "comparison_incomplete",
    UpperVarianceJointPathStatus = "not_evaluated",
    SolutionToleranceStatus = "not_frozen",
    SourceSolutionDecision =
      "blocked_zero_profile_upper_joint_boundary_and_selection_rule_unresolved",
    HessianAuthorized = FALSE,
    DFFFitRankAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gzb_p1c_signature <- function(decision_row) {
  mfrmr_gzb_p1c_assert(
    is.data.frame(decision_row) && nrow(decision_row) == 1L,
    "P1c signature requires one decision row."
  )
  zero_limit <- isTRUE(decision_row$BoundaryQualified)
  interior <- isTRUE(decision_row$InteriorQualified)
  direction <- identical(
    decision_row$NaturalVarianceDirection,
    "negative_objective_derivative_toward_positive_variance_observed"
  )
  signature <- data.frame(
    Metric = c(
      "zero_variance_likelihood_limit", "boundary_nuisance_stationarity",
      "interior_candidate", "natural_variance_right_path",
      "upper_joint_variance_boundary", "solution_tolerance",
      "source_solution_selection", "hessian", "dff_fit_rank", "overall"
    ),
    State = c(
      "implemented_exact_q1_and_direct_oracle",
      if (zero_limit) "qualified_local_boundary_candidate" else "blocked",
      if (interior) "qualified_local_interior_candidate" else "blocked",
      if (direction) "interior_direction_observed" else "review",
      "not_evaluated", "not_frozen", "blocked", "not_evaluated",
      "not_evaluated", if (zero_limit && interior) "review" else "blocked"
    ),
    Eligibility = c(
      "fixed_nuisance_limit_only", "local_nuisance_candidate_only",
      "p1b_finite_q_candidate_only", "calibration_only",
      rep("not_selection_eligible", 6L)
    ),
    Reason = c(
      "bounded_continuous_response_likelihood_and_q1_node_zero_weight_one",
      if (zero_limit) {
        "at_least_one_boundary_start_passed_existing_nuisance_rule"
      } else "no_boundary_start_passed_existing_nuisance_rule",
      if (interior) {
        "q61_refit_and_q121_common_evaluation_complete"
      } else "interior_refit_or_common_evaluation_incomplete",
      if (direction) {
        "fixed_nuisance_q121_difference_quotients_negative"
      } else "one_sided_difference_quotients_mixed_or_incomplete",
      "large_variance_joint_nuisance_path_not_adjudicated",
      "observed_differences_are_not_acceptance_thresholds",
      "upper_boundary_and_prespecified_selection_rule_remain_open",
      "source_solution_not_selected",
      "source_solution_not_selected",
      "p1c_zero_boundary_calibration_only"
    ),
    stringsAsFactors = FALSE
  )
  mfrmr_gzb_p1c_assert(
    !anyDuplicated(signature$Metric) && all(nzchar(signature$State)) &&
      all(nzchar(signature$Eligibility)) && all(nzchar(signature$Reason)),
    "P1c signatures require unique non-empty fields."
  )
  signature
}

mfrmr_run_gpcm_zero_variance_boundary_p1c <- function(
    maxit = 800L,
    reltol = 1e-12,
    progress = FALSE) {
  mfrmr_gzb_p1c_require_sources()
  maxit <- suppressWarnings(as.integer(maxit)[1L])
  reltol <- suppressWarnings(as.numeric(reltol)[1L])
  mfrmr_gzb_p1c_assert(
    is.finite(maxit) && maxit > 0L && is.finite(reltol) && reltol > 0,
    "P1c requires finite positive optimization controls."
  )
  plan <- mfrmr_gzb_p1c_plan()
  zero_limit <- mfrmr_gzb_p1c_zero_limit_contract()
  mfrmr_gzb_p1c_assert(
    isTRUE(zero_limit$ExactDegenerateLikelihood),
    "P1c requires exact q=1 node-zero, weight-one quadrature."
  )
  p0b <- mfrmr_run_gpcm_endpoint_solution_stability_p0b(
    progress = progress
  )
  boundary_candidates <- list()
  boundary_rows <- list()
  path_rows <- list()
  derivative_rows <- list()
  interior_objects <- list()
  interior_rows <- list()
  row_index <- path_index <- derivative_index <- interior_index <- 1L
  for (scenario_id in mfrmr_gzb_p1c_scenarios) {
    source <- p0b$scenario_results[[scenario_id]]
    mfrmr_gzb_p1c_assert(
      !is.null(source$fit) && !is.null(source$candidate_objects),
      paste0("P1c source scenario failed: ", scenario_id, ".")
    )
    contexts <- lapply(c(1L, 61L, 121L), function(q) {
      mfrmr_gqi_p1b_context(source$fit, q)
    })
    names(contexts) <- c("1", "61", "121")
    low_source <- source$candidate_objects[["variance_low"]]
    mfrmr_gzb_p1c_assert(
      !is.null(low_source) && all(is.finite(low_source$par)),
      paste0("P1c low source vector is missing: ", scenario_id, ".")
    )
    interior_run <- mfrmr_gqi_p1b_run_candidate(
      scenario_id = scenario_id,
      lane = "qualified_low",
      start_id = "variance_low",
      source_par = low_source$par,
      fit = source$fit,
      native_context = contexts[["61"]],
      common_context = contexts[["121"]],
      maxit = maxit,
      reltol = reltol
    )
    interior <- mfrmr_gqi_p1b_candidate(interior_run)
    interior_objects[[scenario_id]] <- interior
    interior_rows[[interior_index]] <- interior$row
    interior_index <- interior_index + 1L

    for (start_id in mfrmr_gzb_p1c_boundary_starts) {
      start_par <- if (identical(start_id, "zero_nuisance")) {
        rep(0, nrow(contexts[["1"]]$coordinates))
      } else {
        source$candidate_objects[[start_id]]$par
      }
      mfrmr_gzb_p1c_assert(
        length(start_par) == nrow(contexts[["1"]]$coordinates) &&
          all(is.finite(start_par)),
        paste0("P1c boundary start is invalid: ", scenario_id, "/", start_id)
      )
      if (isTRUE(progress)) {
        message("Zero-variance P1c: ", scenario_id, " / ", start_id)
      }
      candidate <- mfrmr_gzb_p1c_boundary_candidate(
        scenario_id = scenario_id,
        start_id = start_id,
        context = contexts[["1"]],
        path_context = contexts[["121"]],
        start_par = start_par,
        maxit = maxit,
        reltol = reltol
      )
      key <- paste(scenario_id, start_id, sep = "::")
      boundary_candidates[[key]] <- candidate
      boundary_rows[[row_index]] <- candidate$row
      row_index <- row_index + 1L
      if (nrow(candidate$path) > 0L) {
        path_rows[[path_index]] <- candidate$path
        path_index <- path_index + 1L
      }
      if (nrow(candidate$derivative_audit) > 0L) {
        derivative_rows[[derivative_index]] <- candidate$derivative_audit
        derivative_index <- derivative_index + 1L
      }
    }
  }
  candidate_rows <- do.call(rbind, boundary_rows)
  rownames(candidate_rows) <- NULL
  paths <- if (length(path_rows) > 0L) {
    do.call(rbind, path_rows)
  } else data.frame()
  rownames(paths) <- NULL
  derivative_audit <- if (length(derivative_rows) > 0L) {
    do.call(rbind, derivative_rows)
  } else data.frame()
  rownames(derivative_audit) <- NULL
  interior_table <- do.call(rbind, interior_rows)
  rownames(interior_table) <- NULL
  pairwise <- mfrmr_gzb_p1c_boundary_pairwise(boundary_candidates)
  boundary_summary <- mfrmr_gzb_p1c_boundary_summary(candidate_rows)
  decisions <- list()
  signatures <- list()
  for (scenario_id in mfrmr_gzb_p1c_scenarios) {
    summary_row <- boundary_summary[
      boundary_summary$ScenarioId == scenario_id, , drop = FALSE
    ]
    interior_row <- interior_table[
      interior_table$ScenarioId == scenario_id, , drop = FALSE
    ]
    selected_key <- paste(
      scenario_id,
      summary_row$DiagnosticBoundaryEnvelopeStart,
      sep = "::"
    )
    selected_candidate <- boundary_candidates[[selected_key]]
    decision <- mfrmr_gzb_p1c_decision(
      summary_row, interior_row, selected_candidate
    )
    decisions[[scenario_id]] <- decision
    signatures[[scenario_id]] <- mfrmr_gzb_p1c_signature(decision)
  }
  decision_table <- do.call(rbind, decisions)
  rownames(decision_table) <- NULL
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
      contract = mfrmr_gzb_p1c_contract,
      specification = mfrmr_gzb_p1c_specification,
      dependency_contract = mfrmr_gzb_p1c_dependency_contract,
      dependency_sha256 = mfrmr_gzb_p1c_dependency_sha256,
      plan = plan,
      zero_limit_contract = zero_limit,
      boundary_candidates = candidate_rows,
      boundary_candidate_objects = boundary_candidates,
      boundary_pairwise = pairwise,
      boundary_summary = boundary_summary,
      natural_variance_paths = paths,
      boundary_derivative_audit = derivative_audit,
      interior_candidates = interior_table,
      interior_candidate_objects = interior_objects,
      decisions = decision_table,
      decision_signatures = signatures,
      signature_comparisons = signature_comparisons,
      p0b = p0b,
      UpperVarianceJointPathStatus = "not_evaluated",
      SolutionToleranceStatus = "not_frozen",
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ),
    class = "mfrmr_gpcm_zero_variance_boundary_p1c"
  )
}
