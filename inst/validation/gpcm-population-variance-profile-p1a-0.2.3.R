# mfrmr 0.2.3 bounded GPCM population-variance nuisance-profile P1a audit
#
# This deterministic calibration fixes log population variance on a finite
# grid and reoptimizes every other free coordinate independently from the P0b
# default and variance_low basins. The lower local objective at a grid point is
# a diagnostic two-start envelope, not a certified global profile. A finite
# grid cannot establish either sigma2 -> 0 or sigma2 -> Inf as a likelihood
# limit, and fixed-q results cannot certify continuous-normal integration.

mfrmr_gvp_p1a_specification <- "0.2.3-draft.1"
mfrmr_gvp_p1a_contract <-
  "mfrmr_gpcm_population_variance_profile_p1a_v1"
mfrmr_gvp_p1a_dependency_contract <-
  "mfrmr_gpcm_endpoint_solution_stability_p0b_v1"
mfrmr_gvp_p1a_dependency_sha256 <-
  "63dbb2ae1ec6b9df56e252d8d7bf55a2ff61870c17d2c366da6ddedd46ca8364"
mfrmr_gvp_p1a_anchor_ids <- c("default", "variance_low")
mfrmr_gvp_p1a_grid_roles <- c(
  "small_tail_far", "small_tail_mid", "small_tail_near",
  "low_basin_minus_half", "low_basin_anchor", "low_basin_plus_half",
  "unit_variance", "bridge_midpoint", "default_basin_anchor",
  "large_tail_plus_four"
)

mfrmr_gvp_p1a_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gvp_p1a_require_sources <- function() {
  target <- environment(mfrmr_gvp_p1a_require_sources)
  required <- c(
    "mfrmr_gss_p0b_contract",
    "mfrmr_run_gpcm_endpoint_solution_stability_p0b",
    "mfrmr_gss_get", "mfrmr_gss_hash_vector",
    "mfrmr_gss_compare_signatures"
  )
  available <- vapply(
    required,
    exists,
    logical(1),
    envir = target,
    inherits = TRUE
  )
  mfrmr_gvp_p1a_assert(
    all(available) && identical(
      get("mfrmr_gss_p0b_contract", envir = target, inherits = TRUE),
      mfrmr_gvp_p1a_dependency_contract
    ),
    paste0(
      "Source the numerical P0, endpoint P0b, and their dependencies ",
      "before the population-variance P1a audit."
    )
  )
  invisible(TRUE)
}

mfrmr_gvp_p1a_grid <- function(scenario_result) {
  mfrmr_gvp_p1a_require_sources()
  context <- scenario_result$context
  objects <- scenario_result$candidate_objects
  sigma_index <- context$slices$log_sigma2
  mfrmr_gvp_p1a_assert(
    length(sigma_index) == 1L &&
      all(mfrmr_gvp_p1a_anchor_ids %in% names(objects)),
    "P1a requires one log-variance coordinate and both declared P0b basins."
  )
  anchor_values <- vapply(mfrmr_gvp_p1a_anchor_ids, function(id) {
    object <- objects[[id]]
    if (is.null(object) || length(object$par) < sigma_index) return(NA_real_)
    as.numeric(object$par[sigma_index])
  }, numeric(1L))
  names(anchor_values) <- mfrmr_gvp_p1a_anchor_ids
  mfrmr_gvp_p1a_assert(
    all(is.finite(anchor_values)) &&
      anchor_values[["default"]] > anchor_values[["variance_low"]],
    "P1a requires finite ordered default and variance_low log-variance anchors."
  )
  low <- anchor_values[["variance_low"]]
  high <- anchor_values[["default"]]
  values <- c(
    -16, -12, -8,
    low - 0.5, low, low + 0.5,
    0, low + 0.5 * (high - low), high, high + 4
  )
  mfrmr_gvp_p1a_assert(
    length(values) == length(mfrmr_gvp_p1a_grid_roles) &&
      all(is.finite(values)) && all(diff(values) > 0),
    "The P1a calibration grid must be finite and strictly increasing."
  )
  grid <- data.frame(
    GridOrder = seq_along(values),
    GridRole = mfrmr_gvp_p1a_grid_roles,
    LogSigma2 = as.numeric(values),
    Sigma2 = exp(as.numeric(values)),
    QuadPoints = 31L,
    GridBasis = paste0(
      "fixed_small_tail_plus_observed_p0b_default_and_variance_low_anchors"
    ),
    BoundaryLimitCertified = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  grid$GridSHA256 <- digest::digest(
    list(
      roles = grid$GridRole,
      values = grid$LogSigma2,
      anchor_ids = mfrmr_gvp_p1a_anchor_ids
    ),
    algo = "sha256",
    serialize = TRUE
  )
  grid
}

mfrmr_gvp_p1a_profile_row <- function(
    scenario_id,
    context,
    anchor_id,
    anchor_object,
    grid_row,
    maxit,
    reltol) {
  sigma_index <- context$slices$log_sigma2
  total_dimension <- nrow(context$coordinates)
  nuisance_index <- setdiff(seq_len(total_dimension), sigma_index)
  fixed_value <- as.numeric(grid_row$LogSigma2)
  anchor_par <- if (!is.null(anchor_object)) {
    as.numeric(anchor_object$par)
  } else {
    numeric(0)
  }
  base_ok <- length(anchor_par) == total_dimension &&
    all(is.finite(anchor_par)) && length(sigma_index) == 1L
  warnings <- character(0)
  error_text <- ""
  elapsed <- NA_real_
  opt <- NULL
  diagnostics <- NULL
  selected_method <- NA_character_
  selected_reltol <- NA_real_
  profile_stages <- 0L
  polish_triggered <- FALSE
  polish_succeeded <- FALSE

  if (base_ok) {
    embed <- function(nuisance) {
      full <- anchor_par
      full[nuisance_index] <- as.numeric(nuisance)
      full[sigma_index] <- fixed_value
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
    run_stage <- function(start, method, stage_reltol, index, label) {
      control <- mfrmr_gss_get("build_mfrm_optim_control")(
        method,
        maxit = as.integer(maxit),
        reltol = as.numeric(stage_reltol)
      )
      started <- proc.time()[["elapsed"]]
      stage_error <- ""
      stage_opt <- tryCatch(
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
      stage_elapsed <- proc.time()[["elapsed"]] - started
      if (is.null(stage_opt)) {
        return(list(
          index = index,
          label = label,
          method = method,
          reltol = stage_reltol,
          control = control,
          opt = NULL,
          diagnostics = list(
            ConvergenceCode = NA_integer_,
            ConvergenceStatus = "not_returned",
            ConvergenceReason = "profile_fit_failed",
            ConvergenceSeverity = "fail",
            GradientReviewTolerance = max(1e-4, 10 * stage_reltol),
            TerminalGradientSupNorm = NA_real_
          ),
          elapsed = stage_elapsed,
          error = stage_error
        ))
      }
      stage_gradient <- tryCatch(
        suppressWarnings(as.numeric(gradient(stage_opt$par))),
        error = function(condition) rep(NA_real_, length(stage_opt$par))
      )
      list(
        index = index,
        label = label,
        method = method,
        reltol = stage_reltol,
        control = control,
        opt = stage_opt,
        diagnostics = mfrmr_gss_get("build_optimizer_diagnostics")(
          opt = stage_opt,
          gradient = stage_gradient,
          reltol = as.numeric(stage_reltol),
          maxit = as.integer(maxit),
          optimizer_method = method,
          convergence_basis = "optimizer_gradient"
        ),
        elapsed = stage_elapsed,
        error = stage_error
      )
    }
    stages <- list(run_stage(
      anchor_par[nuisance_index],
      "L-BFGS-B",
      reltol,
      1L,
      "initial"
    ))
    selected <- stages[[1L]]
    if (!is.null(selected$opt)) {
      polish_triggered <- identical(selected$opt$convergence, 0L) &&
        identical(
          selected$diagnostics$ConvergenceReason,
          "code_zero_large_gradient"
        ) && reltol <= 1e-9
      if (polish_triggered) {
        stage_index <- 1L
        tolerances <- mfrmr_gss_get("mfrm_optimizer_polish_tolerances")(
          reltol
        )
        for (stage_reltol in tolerances) {
          stage_index <- stage_index + 1L
          candidate <- run_stage(
            selected$opt$par,
            "L-BFGS-B",
            stage_reltol,
            stage_index,
            "gradient_polish"
          )
          stages[[length(stages) + 1L]] <- candidate
          if (!is.null(candidate$opt) &&
              mfrmr_gss_get("mfrm_optimizer_stage_is_better")(
                candidate,
                selected
              )) {
            selected <- candidate
          }
          if (identical(
            selected$diagnostics$ConvergenceSeverity,
            "pass"
          )) break
        }
        if (!identical(selected$diagnostics$ConvergenceSeverity, "pass")) {
          for (stage_reltol in c(1e-13, 1e-14)) {
            stage_index <- stage_index + 1L
            candidate <- run_stage(
              selected$opt$par,
              "BFGS",
              stage_reltol,
              stage_index,
              "bounded_bfgs_fallback"
            )
            stages[[length(stages) + 1L]] <- candidate
            if (!is.null(candidate$opt) &&
                mfrmr_gss_get("mfrm_optimizer_stage_is_better")(
                  candidate,
                  selected
                )) {
              selected <- candidate
            }
            if (identical(
              selected$diagnostics$ConvergenceSeverity,
              "pass"
            )) break
          }
        }
      }
      opt <- selected$opt
      diagnostics <- selected$diagnostics
      selected_method <- as.character(selected$method)
      selected_reltol <- as.numeric(selected$reltol)
      polish_succeeded <- polish_triggered && identical(
        diagnostics$ConvergenceSeverity,
        "pass"
      )
    }
    profile_stages <- length(stages)
    elapsed <- sum(vapply(stages, `[[`, numeric(1L), "elapsed"))
    stage_errors <- vapply(stages, `[[`, character(1L), "error")
    error_text <- paste(stage_errors[nzchar(stage_errors)], collapse = " | ")
  } else {
    error_text <- "P0b anchor vector is missing or has the wrong free dimension."
  }

  returned <- !is.null(opt) && length(opt$par) == length(nuisance_index) &&
    all(is.finite(opt$par))
  full_par <- if (returned) {
    value <- anchor_par
    value[nuisance_index] <- as.numeric(opt$par)
    value[sigma_index] <- fixed_value
    value
  } else {
    rep(NA_real_, total_dimension)
  }
  objective <- if (returned) tryCatch(
    suppressWarnings(as.numeric(context$fn(full_par))[1L]),
    error = function(condition) NA_real_
  ) else NA_real_
  full_gradient <- if (returned) tryCatch(
    suppressWarnings(as.numeric(context$gr(full_par))),
    error = function(condition) rep(NA_real_, total_dimension)
  ) else rep(NA_real_, total_dimension)
  nuisance_gradient <- full_gradient[nuisance_index]
  fixed_gradient <- full_gradient[sigma_index]
  derivative_step <- 1e-6 * max(1, abs(fixed_value))
  numeric_fixed_gradient <- if (returned && is.finite(objective)) {
    high <- low <- full_par
    high[sigma_index] <- fixed_value + derivative_step
    low[sigma_index] <- fixed_value - derivative_step
    high_value <- tryCatch(
      suppressWarnings(as.numeric(context$fn(high))[1L]),
      error = function(condition) NA_real_
    )
    low_value <- tryCatch(
      suppressWarnings(as.numeric(context$fn(low))[1L]),
      error = function(condition) NA_real_
    )
    if (is.finite(high_value) && is.finite(low_value)) {
      (high_value - low_value) / (2 * derivative_step)
    } else NA_real_
  } else NA_real_
  diagnostics <- if (
    returned && all(is.finite(nuisance_gradient)) && !is.null(diagnostics)
  ) diagnostics else list(
    ConvergenceCode = NA_integer_,
    ConvergenceStatus = "not_returned",
    ConvergenceReason = "profile_fit_failed",
    ConvergenceSeverity = "fail",
    GradientReviewTolerance = max(1e-4, 10 * reltol)
  )
  dimension_identity <- returned && length(full_par) == total_dimension &&
    length(nuisance_index) + length(sigma_index) == total_dimension
  common_complete <- dimension_identity && is.finite(objective) &&
    length(full_gradient) == total_dimension && all(is.finite(full_gradient))
  existing_pass <- common_complete && identical(
    as.character(diagnostics$ConvergenceSeverity)[1L],
    "pass"
  )

  data.frame(
    ScenarioId = as.character(scenario_id),
    GridOrder = as.integer(grid_row$GridOrder),
    GridRole = as.character(grid_row$GridRole),
    GridSHA256 = as.character(grid_row$GridSHA256),
    AnchorId = as.character(anchor_id),
    AnchorVectorSHA256 = if (base_ok) {
      mfrmr_gss_hash_vector(anchor_par)
    } else NA_character_,
    LogSigma2 = fixed_value,
    Sigma2 = exp(fixed_value),
    QuadPoints = as.integer(grid_row$QuadPoints),
    TotalFreeDimension = as.integer(total_dimension),
    FixedDimension = as.integer(length(sigma_index)),
    NuisanceDimension = as.integer(length(nuisance_index)),
    DimensionIdentity = dimension_identity,
    FitReturned = returned,
    CommonEvaluationComplete = common_complete,
    CommonObjective = objective,
    NuisanceGradientMaxAbs = if (
      common_complete && length(nuisance_gradient) > 0L
    ) max(abs(nuisance_gradient)) else NA_real_,
    FixedAnalyticGradient = if (common_complete) {
      as.numeric(fixed_gradient)
    } else NA_real_,
    FixedNumericGradient = as.numeric(numeric_fixed_gradient),
    FixedDerivativeStep = as.numeric(derivative_step),
    FixedGradientAbsDifference = if (
      is.finite(fixed_gradient) && is.finite(numeric_fixed_gradient)
    ) abs(fixed_gradient - numeric_fixed_gradient) else NA_real_,
    InitialMethod = "L-BFGS-B",
    SelectedMethod = as.character(selected_method),
    RequestedReltol = as.numeric(reltol),
    SelectedReltol = as.numeric(selected_reltol),
    ProfileStages = as.integer(profile_stages),
    PolishTriggered = isTRUE(polish_triggered),
    PolishSucceeded = isTRUE(polish_succeeded),
    ConvergenceCode = suppressWarnings(as.integer(
      diagnostics$ConvergenceCode
    )[1L]),
    ConvergenceStatus = as.character(diagnostics$ConvergenceStatus)[1L],
    ConvergenceReason = as.character(diagnostics$ConvergenceReason)[1L],
    ConvergenceSeverity = as.character(diagnostics$ConvergenceSeverity)[1L],
    GradientReviewTolerance = as.numeric(
      diagnostics$GradientReviewTolerance
    )[1L],
    ExistingNuisanceOptimizerPass = existing_pass,
    ProfileStatus = if (existing_pass) {
      "finite_grid_local_nuisance_profile_existing_pass"
    } else if (common_complete) {
      "finite_grid_nuisance_optimization_review"
    } else {
      "blocked_profile_fit_failed"
    },
    BoundaryLimitCertified = FALSE,
    ContinuousIntegralCertificate = FALSE,
    ProfileSelectionAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    ElapsedSeconds = as.numeric(elapsed),
    WarningCount = length(unique(warnings)),
    WarningText = paste(unique(warnings), collapse = " | "),
    ErrorText = as.character(error_text),
    ReturnedVectorSHA256 = if (returned) {
      mfrmr_gss_hash_vector(full_par)
    } else NA_character_,
    stringsAsFactors = FALSE
  )
}

mfrmr_gvp_p1a_envelope <- function(profile_rows) {
  required <- c(
    "ScenarioId", "GridOrder", "GridRole", "GridSHA256", "AnchorId",
    "LogSigma2", "Sigma2", "FitReturned", "CommonEvaluationComplete",
    "CommonObjective", "NuisanceGradientMaxAbs", "FixedAnalyticGradient",
    "FixedNumericGradient", "ExistingNuisanceOptimizerPass"
  )
  mfrmr_gvp_p1a_assert(
    is.data.frame(profile_rows) && all(required %in% names(profile_rows)),
    "P1a diagnostic envelope requires complete typed profile rows."
  )
  keys <- unique(profile_rows[c(
    "ScenarioId", "GridOrder", "GridRole", "GridSHA256",
    "LogSigma2", "Sigma2"
  )])
  keys <- keys[order(keys$ScenarioId, keys$GridOrder), , drop = FALSE]
  rows <- lapply(seq_len(nrow(keys)), function(index) {
    key <- keys[index, , drop = FALSE]
    value <- profile_rows[
      profile_rows$ScenarioId == key$ScenarioId &
        profile_rows$GridOrder == key$GridOrder,
      , drop = FALSE
    ]
    finite <- which(
      value$CommonEvaluationComplete & is.finite(value$CommonObjective)
    )
    qualified <- which(
      value$CommonEvaluationComplete &
        is.finite(value$CommonObjective) &
        value$ExistingNuisanceOptimizerPass
    )
    lowest <- if (length(finite) > 0L) {
      finite[which.min(value$CommonObjective[finite])]
    } else integer(0)
    lowest_qualified <- if (length(qualified) > 0L) {
      qualified[which.min(value$CommonObjective[qualified])]
    } else integer(0)
    data.frame(
      key,
      DeclaredBasins = nrow(value),
      ReturnedBasins = sum(value$FitReturned),
      ExistingPassBasins = sum(value$ExistingNuisanceOptimizerPass),
      DiagnosticEnvelopeAnchor = if (length(lowest) == 1L) {
        as.character(value$AnchorId[lowest])
      } else NA_character_,
      DiagnosticEnvelopeExistingPass = if (length(lowest) == 1L) {
        isTRUE(value$ExistingNuisanceOptimizerPass[lowest])
      } else FALSE,
      DiagnosticEnvelopeObjective = if (length(lowest) == 1L) {
        as.numeric(value$CommonObjective[lowest])
      } else NA_real_,
      DiagnosticEnvelopeNuisanceGradientMaxAbs = if (
        length(lowest) == 1L
      ) as.numeric(value$NuisanceGradientMaxAbs[lowest]) else NA_real_,
      DiagnosticEnvelopeFixedAnalyticGradient = if (
        length(lowest) == 1L
      ) as.numeric(value$FixedAnalyticGradient[lowest]) else NA_real_,
      DiagnosticEnvelopeFixedNumericGradient = if (
        length(lowest) == 1L
      ) as.numeric(value$FixedNumericGradient[lowest]) else NA_real_,
      ObjectiveRangeAcrossBasins = if (length(finite) > 0L) {
        diff(range(value$CommonObjective[finite]))
      } else NA_real_,
      GridProfileQualified = length(lowest_qualified) == 1L,
      ExistingPassEnvelopeAnchor = if (length(lowest_qualified) == 1L) {
        as.character(value$AnchorId[lowest_qualified])
      } else NA_character_,
      ExistingPassEnvelopeObjective = if (length(lowest_qualified) == 1L) {
        as.numeric(value$CommonObjective[lowest_qualified])
      } else NA_real_,
      EnvelopeStatus = if (length(lowest) == 1L) {
        "diagnostic_minimum_of_two_local_profiles"
      } else "blocked_no_finite_local_profile",
      BoundaryLimitCertified = FALSE,
      ContinuousIntegralCertificate = FALSE,
      ProfileSelectionAuthorized = FALSE,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_gvp_p1a_signature <- function(scenario_summary) {
  mfrmr_gvp_p1a_assert(
    is.data.frame(scenario_summary) && nrow(scenario_summary) == 1L,
    "P1a signature requires one scenario-summary row."
  )
  complete <- isTRUE(scenario_summary$AllProfileRowsReturned)
  nuisance <- isTRUE(scenario_summary$AllProfileRowsExistingPass)
  signature <- data.frame(
    Metric = c(
      "source_p0b", "profile_return", "nuisance_stationarity",
      "small_variance_limit", "large_variance_limit", "quadrature",
      "continuous_integration", "solution_selection", "candidate_eap",
      "hessian", "overall"
    ),
    State = c(
      "review", if (complete) "pass" else "review",
      if (nuisance) "pass" else "review",
      "not_evaluated", "not_evaluated", "not_evaluated",
      "not_evaluated", "not_evaluated", "not_evaluated",
      "not_evaluated", if (complete) "review" else "blocked"
    ),
    Eligibility = c(
      "p0b_provenance_only", "instrument_execution_only",
      "existing_optimizer_rule_only", rep("not_selection_eligible", 8L)
    ),
    Reason = c(
      "p0b_candidates_not_stability_eligible",
      if (complete) {
        "all_declared_local_profile_rows_returned"
      } else "one_or_more_local_profile_rows_failed",
      if (nuisance) {
        "all_rows_pass_existing_nuisance_gradient_rule"
      } else "one_or_more_rows_fail_existing_nuisance_gradient_rule",
      "finite_lower_grid_cannot_certify_sigma2_zero_limit",
      "finite_upper_grid_cannot_certify_sigma2_infinite_limit",
      "q31_only_p1a_profile",
      "finite_quadrature_is_not_continuous_integral_certificate",
      "two_start_diagnostic_envelope_is_not_global_profile_selection",
      "candidate_posteriors_deferred_until_source_solution_adjudication",
      "uncertainty_deferred_until_source_solution_adjudication",
      "p1a_local_profile_calibration_only"
    ),
    stringsAsFactors = FALSE
  )
  mfrmr_gvp_p1a_assert(
    !anyDuplicated(signature$Metric) &&
      all(nzchar(signature$State)) &&
      all(nzchar(signature$Eligibility)) &&
      all(nzchar(signature$Reason)),
    "P1a signatures require unique non-empty canonical fields."
  )
  signature
}

mfrmr_run_gpcm_population_variance_profile_p1a <- function(
    maxit = 400L,
    reltol = 1e-10,
    progress = FALSE) {
  mfrmr_gvp_p1a_require_sources()
  maxit <- suppressWarnings(as.integer(maxit)[1L])
  reltol <- suppressWarnings(as.numeric(reltol)[1L])
  mfrmr_gvp_p1a_assert(
    is.finite(maxit) && maxit > 0L && is.finite(reltol) && reltol > 0,
    "P1a requires finite positive optimization controls."
  )
  p0b <- mfrmr_run_gpcm_endpoint_solution_stability_p0b(
    progress = progress
  )
  profile_rows <- list()
  grids <- list()
  row_index <- 1L
  for (scenario_id in names(p0b$scenario_results)) {
    result <- p0b$scenario_results[[scenario_id]]
    mfrmr_gvp_p1a_assert(
      !is.null(result$context) && !is.null(result$fit),
      paste0("P1a source scenario failed: ", scenario_id, ".")
    )
    grid <- mfrmr_gvp_p1a_grid(result)
    grids[[scenario_id]] <- grid
    for (grid_index in seq_len(nrow(grid))) {
      for (anchor_id in mfrmr_gvp_p1a_anchor_ids) {
        if (isTRUE(progress)) {
          message(
            "Variance P1a: ", scenario_id, " / ",
            grid$GridRole[grid_index], " / ", anchor_id
          )
        }
        profile_rows[[row_index]] <- mfrmr_gvp_p1a_profile_row(
          scenario_id = scenario_id,
          context = result$context,
          anchor_id = anchor_id,
          anchor_object = result$candidate_objects[[anchor_id]],
          grid_row = grid[grid_index, , drop = FALSE],
          maxit = maxit,
          reltol = reltol
        )
        row_index <- row_index + 1L
      }
    }
  }
  profiles <- do.call(rbind, profile_rows)
  rownames(profiles) <- NULL
  envelope <- mfrmr_gvp_p1a_envelope(profiles)
  summaries <- lapply(names(grids), function(scenario_id) {
    value <- profiles[profiles$ScenarioId == scenario_id, , drop = FALSE]
    curve <- envelope[envelope$ScenarioId == scenario_id, , drop = FALSE]
    finite <- which(is.finite(curve$DiagnosticEnvelopeObjective))
    lowest <- if (length(finite) > 0L) {
      finite[which.min(curve$DiagnosticEnvelopeObjective[finite])]
    } else integer(0)
    endpoint_objective <- function(role) {
      selected <- curve$DiagnosticEnvelopeObjective[curve$GridRole == role]
      if (length(selected) == 1L) as.numeric(selected) else NA_real_
    }
    data.frame(
      ScenarioId = scenario_id,
      GridSHA256 = unique(curve$GridSHA256),
      DeclaredGridPoints = nrow(grids[[scenario_id]]),
      DeclaredProfileRows = nrow(grids[[scenario_id]]) *
        length(mfrmr_gvp_p1a_anchor_ids),
      ReturnedProfileRows = sum(value$FitReturned),
      ExistingPassProfileRows = sum(value$ExistingNuisanceOptimizerPass),
      QualifiedGridPoints = sum(curve$GridProfileQualified),
      AllProfileRowsReturned = all(value$FitReturned),
      AllProfileRowsExistingPass = all(value$ExistingNuisanceOptimizerPass),
      DiagnosticEnvelopeMinimumRole = if (length(lowest) == 1L) {
        as.character(curve$GridRole[lowest])
      } else NA_character_,
      DiagnosticEnvelopeMinimumLogSigma2 = if (length(lowest) == 1L) {
        as.numeric(curve$LogSigma2[lowest])
      } else NA_real_,
      DiagnosticEnvelopeMinimumSigma2 = if (length(lowest) == 1L) {
        as.numeric(curve$Sigma2[lowest])
      } else NA_real_,
      DiagnosticEnvelopeMinimumObjective = if (length(lowest) == 1L) {
        as.numeric(curve$DiagnosticEnvelopeObjective[lowest])
      } else NA_real_,
      DiagnosticEnvelopeMinimumExistingPass = length(lowest) == 1L &&
        isTRUE(curve$DiagnosticEnvelopeExistingPass[lowest]),
      DiagnosticMinimumInteriorToFiniteGrid = length(lowest) == 1L &&
        lowest > 1L && lowest < nrow(curve),
      SmallTailFarObjective = endpoint_objective("small_tail_far"),
      SmallTailNearObjective = endpoint_objective("small_tail_near"),
      DefaultBasinAnchorObjective = endpoint_objective(
        "default_basin_anchor"
      ),
      LargeTailObjective = endpoint_objective("large_tail_plus_four"),
      MaximumBasinObjectiveRange = if (
        any(is.finite(curve$ObjectiveRangeAcrossBasins))
      ) max(curve$ObjectiveRangeAcrossBasins, na.rm = TRUE) else NA_real_,
      ProfileScope = "finite_grid_two_start_local_nuisance_profiles_q31",
      BoundaryLimitCertified = FALSE,
      ContinuousIntegralCertificate = FALSE,
      ProfileSelectionAuthorized = FALSE,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  summary <- do.call(rbind, summaries)
  rownames(summary) <- NULL
  signatures <- lapply(seq_len(nrow(summary)), function(index) {
    mfrmr_gvp_p1a_signature(summary[index, , drop = FALSE])
  })
  names(signatures) <- summary$ScenarioId
  structure(
    list(
      contract = mfrmr_gvp_p1a_contract,
      specification = mfrmr_gvp_p1a_specification,
      dependency_contract = mfrmr_gvp_p1a_dependency_contract,
      dependency_sha256 = mfrmr_gvp_p1a_dependency_sha256,
      anchor_ids = mfrmr_gvp_p1a_anchor_ids,
      grids = grids,
      profiles = profiles,
      diagnostic_envelope = envelope,
      scenario_summary = summary,
      decision_signatures = signatures,
      p0b = p0b,
      BoundaryLimitCertified = FALSE,
      ContinuousIntegralCertificate = FALSE,
      ProfileSelectionAuthorized = FALSE,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ),
    class = "mfrmr_gpcm_population_variance_profile_p1a"
  )
}
