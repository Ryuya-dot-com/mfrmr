# mfrmr 0.2.3 GPCM local profile turning-point P1m audit
#
# P1m refines one representative from each P1l mechanism lane. It brackets
# roots of the nuisance-profile envelope derivative and checks local nuisance
# Hessian regularity. It does not turn numerical point evaluations into a
# theorem about the complete rho interval or the full two-target face.

mfrmr_gpt_p1m_specification <- "0.2.3-draft.1"
mfrmr_gpt_p1m_contract <- "mfrmr_gpcm_profile_turning_point_p1m_v1"
mfrmr_gpt_p1m_dependency_contract <-
  "mfrmr_gpcm_fixed_rho_basin_continuation_p1l_v1"
mfrmr_gpt_p1m_dependency_sha256 <-
  "8c2feb1938d9055e17c796b1d85632235bbeaf875145dc94b7adfe465abba318"
mfrmr_gpt_p1m_selection_tie_tolerance <- 1e-8
mfrmr_gpt_p1m_gradient_tolerance <- 2e-6
mfrmr_gpt_p1m_quadrature_tolerance <- 1e-8
mfrmr_gpt_p1m_route_objective_tolerance <- 1e-7
mfrmr_gpt_p1m_route_coordinate_tolerance <- 5e-5
mfrmr_gpt_p1m_derivative_sign_tolerance <- 5e-6
mfrmr_gpt_p1m_bracket_width_tolerance <- 1e-7
mfrmr_gpt_p1m_max_bisection_iterations <- 24L
mfrmr_gpt_p1m_hessian_eigen_tolerance <- 1e-4
mfrmr_gpt_p1m_hessian_symmetry_relative_tolerance <- 1e-5
mfrmr_gpt_p1m_hessian_spectral_perturbation_ratio_tolerance <- 0.01
mfrmr_gpt_p1m_hessian_minimum_eigen_relative_tolerance <- 1e-3
mfrmr_gpt_p1m_monotone_grid <- seq(0, 1, by = 0.125)
mfrmr_gpt_p1m_expected_representatives <- c(
  objective_profile_maximum =
    "EXT5-P-NEAR-HI::C4_fast__C3_slow::0",
  objective_profile_minimum =
    "EXT5-P-HI::C1_fast__C4_slow::0",
  objective_monotone_increasing =
    "EXT5-P-HI::C1_fast__C2_slow::0",
  coordinate_profile_minimum =
    "EXT5-P-HI::C4_fast__C1_slow::0.003"
)

mfrmr_gpt_p1m_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gpt_p1m_require_sources <- function() {
  target <- environment(mfrmr_gpt_p1m_require_sources)
  required <- c(
    "mfrmr_gfrb_p1l_contract", "mfrmr_gfrb_p1l_rho_grid",
    "mfrmr_gorb_p1j_bundle", "mfrmr_gorb_p1j_contexts",
    "mfrmr_gss_get", "mfrmr_gss_hash_vector"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )
  mfrmr_gpt_p1m_assert(
    all(available) && identical(
      get("mfrmr_gfrb_p1l_contract", envir = target, inherits = TRUE),
      mfrmr_gpt_p1m_dependency_contract
    ),
    "Source P0 through P1l and their numerical dependencies before P1m."
  )
  mfrmr_gpt_p1m_assert(
    requireNamespace("numDeriv", quietly = TRUE),
    "P1m requires numDeriv for nuisance-Hessian diagnostics."
  )
  invisible(TRUE)
}

mfrmr_gpt_p1m_validate_result <- function(result, scope) {
  mfrmr_gpt_p1m_assert(
    is.list(result) && identical(
      result$contract, mfrmr_gpt_p1m_dependency_contract
    ) && identical(result$registry_scope, scope) &&
      is.data.frame(result$cells) && is.data.frame(result$registry) &&
      is.data.frame(result$profile) && is.list(result$profile_objects),
    paste0("P1m requires one complete ", scope, " P1l result.")
  )
  invisible(TRUE)
}

mfrmr_gpt_p1m_join_cells <- function(result, lane) {
  cells <- merge(
    result$cells,
    result$registry[, c(
      "CellId", "ScenarioId", "OrderedPairId", "FastIndex", "SlowIndex",
      "TargetSetId", "Mu", "ObjectiveAbsDifference", "RhoAbsDifference",
      "P1kAgreementClass", "P1kLowRouteRho", "P1kHighRouteRho",
      "P1kLowRouteObjectiveQ121", "P1kHighRouteObjectiveQ121"
    )],
    by = "CellId",
    suffixes = c("", ".Registry")
  )
  registry_names <- grep("\\.Registry$", names(cells), value = TRUE)
  for (name in registry_names) {
    base <- sub("\\.Registry$", "", name)
    if (!base %in% names(cells)) names(cells)[names(cells) == name] <- base
  }
  cells$Lane <- lane
  cells
}

mfrmr_gpt_p1m_select_one <- function(
    cells,
    mechanism,
    metric,
    representative_id) {
  candidates <- cells[cells$MechanismClass == mechanism, , drop = FALSE]
  mfrmr_gpt_p1m_assert(
    nrow(candidates) >= 1L && metric %in% names(candidates) &&
      all(is.finite(candidates[[metric]])),
    paste0("P1m could not select representative for ", representative_id, ".")
  )
  maximum <- max(candidates[[metric]])
  tied <- candidates[
    maximum - candidates[[metric]] <=
      mfrmr_gpt_p1m_selection_tie_tolerance, , drop = FALSE
  ]
  tied <- tied[order(tied$CellId), , drop = FALSE]
  selected <- tied[1L, , drop = FALSE]
  selected$RepresentativeId <- representative_id
  selected$SelectionMetric <- metric
  selected$SelectionMetricValue <- selected[[metric]]
  selected$SelectionRule <- paste0(
    "largest_", metric, "_then_cell_id_within_",
    format(mfrmr_gpt_p1m_selection_tie_tolerance, scientific = TRUE)
  )
  selected
}

mfrmr_gpt_p1m_representatives <- function(objective_p1l, coordinate_p1l) {
  mfrmr_gpt_p1m_validate_result(objective_p1l, "objective_discordant")
  mfrmr_gpt_p1m_validate_result(coordinate_p1l, "coordinate_only")
  objective <- mfrmr_gpt_p1m_join_cells(
    objective_p1l, "objective_discordant"
  )
  coordinate <- mfrmr_gpt_p1m_join_cells(
    coordinate_p1l, "coordinate_only"
  )
  selected <- list(
    mfrmr_gpt_p1m_select_one(
      objective,
      "route_coalescence_profile_maximum_bracket",
      "ObjectiveAbsDifference",
      "objective_profile_maximum"
    ),
    mfrmr_gpt_p1m_select_one(
      objective,
      "route_coalescence_profile_minimum_bracket",
      "ObjectiveAbsDifference",
      "objective_profile_minimum"
    ),
    mfrmr_gpt_p1m_select_one(
      objective,
      "route_coalescence_monotone_increasing_grid",
      "ObjectiveAbsDifference",
      "objective_monotone_increasing"
    ),
    mfrmr_gpt_p1m_select_one(
      coordinate,
      "route_coalescence_profile_minimum_bracket",
      "RhoAbsDifference",
      "coordinate_profile_minimum"
    )
  )
  keep <- c(
    "RepresentativeId", "Lane", "CellId", "ScenarioId",
    "OrderedPairId", "FastIndex", "SlowIndex", "TargetSetId", "Mu",
    "P1kAgreementClass", "MechanismClass", "SelectionMetric",
    "SelectionMetricValue", "SelectionRule", "P1kLowRouteRho",
    "P1kHighRouteRho", "P1kLowRouteObjectiveQ121",
    "P1kHighRouteObjectiveQ121"
  )
  out <- do.call(rbind, lapply(selected, function(value) {
    value[, keep, drop = FALSE]
  }))
  rownames(out) <- NULL
  expected <- unname(mfrmr_gpt_p1m_expected_representatives[
    out$RepresentativeId
  ])
  mfrmr_gpt_p1m_assert(
    identical(out$CellId, expected),
    "P1m representative selection drifted from its frozen expected cells."
  )
  out$RepresentativeSelectionFrozen <- TRUE
  out$ReflectedFixture <- FALSE
  out$SelectionAuthorized <- FALSE
  out$ConfirmationAuthorized <- FALSE
  out
}

mfrmr_gpt_p1m_result_for_lane <- function(
    objective_p1l,
    coordinate_p1l,
    lane) {
  if (identical(lane, "objective_discordant")) {
    objective_p1l
  } else if (identical(lane, "coordinate_only")) {
    coordinate_p1l
  } else {
    stop("Unknown P1m lane.", call. = FALSE)
  }
}

mfrmr_gpt_p1m_profile_rows <- function(result, cell_id) {
  rows <- result$pairwise[result$pairwise$CellId == cell_id, , drop = FALSE]
  rows <- rows[order(rows$Rho), , drop = FALSE]
  mfrmr_gpt_p1m_assert(
    nrow(rows) >= 2L && all(rows$BothRoutesEligible),
    paste0("P1m requires eligible P1l profile rows for ", cell_id, ".")
  )
  rows
}

mfrmr_gpt_p1m_derivative_sign <- function(value) {
  ifelse(
    value > mfrmr_gpt_p1m_derivative_sign_tolerance,
    1L,
    ifelse(
      value < -mfrmr_gpt_p1m_derivative_sign_tolerance,
      -1L, 0L
    )
  )
}

mfrmr_gpt_p1m_choose_bracket <- function(rows, mechanism) {
  rows <- rows[order(rows$Rho), , drop = FALSE]
  sign <- mfrmr_gpt_p1m_derivative_sign(
    rows$MeanRhoObjectiveDerivative
  )
  expected <- if (identical(
    mechanism, "route_coalescence_profile_maximum_bracket"
  )) c(1L, -1L) else if (identical(
    mechanism, "route_coalescence_profile_minimum_bracket"
  )) c(-1L, 1L) else {
    stop("P1m bracket selection requires a turning-point mechanism.",
         call. = FALSE)
  }
  pairs <- which(outer(
    seq_len(nrow(rows)), seq_len(nrow(rows)),
    function(left, right) left < right
  ) & outer(sign, sign, function(left, right) {
    left == expected[1L] & right == expected[2L]
  }), arr.ind = TRUE)
  mfrmr_gpt_p1m_assert(
    nrow(pairs) >= 1L,
    "P1m could not recover the P1l derivative-sign bracket."
  )
  widths <- rows$Rho[pairs[, 2L]] - rows$Rho[pairs[, 1L]]
  pair <- pairs[order(widths, rows$Rho[pairs[, 1L]])[1L], ]
  data.frame(
    LeftRho = rows$Rho[pair[1L]],
    RightRho = rows$Rho[pair[2L]],
    LeftDerivative = rows$MeanRhoObjectiveDerivative[pair[1L]],
    RightDerivative = rows$MeanRhoObjectiveDerivative[pair[2L]],
    LeftSign = expected[1L],
    RightSign = expected[2L],
    InitialBracketWidth = widths[order(
      widths, rows$Rho[pairs[, 1L]]
    )[1L]],
    stringsAsFactors = FALSE
  )
}

mfrmr_gpt_p1m_start_at <- function(result, cell_id, route_id, rho) {
  rows <- result$profile[
    result$profile$CellId == cell_id &
      result$profile$RouteId == route_id, , drop = FALSE
  ]
  mfrmr_gpt_p1m_assert(
    nrow(rows) >= 1L,
    paste0("P1m cannot recover P1l route start for ", cell_id, ".")
  )
  row <- rows[which.min(abs(rows$Rho - rho)), , drop = FALSE]
  candidate <- result$profile_objects[[row$CandidateKey]]
  mfrmr_gpt_p1m_assert(
    is.list(candidate) && is.numeric(candidate$value) &&
      all(is.finite(candidate$value)),
    paste0("P1m P1l route object is invalid for ", cell_id, ".")
  )
  as.numeric(candidate$value)
}

mfrmr_gpt_p1m_optimize <- function(start, fn, gr, maxit = 2000L) {
  start <- as.numeric(start)
  specifications <- list(
    list(method = "BFGS", reltol = 1e-13),
    list(method = "L-BFGS-B", reltol = 1e-14),
    list(method = "BFGS", reltol = 1e-14)
  )
  stages <- list()
  warnings <- character(0)
  current <- start
  for (index in seq_along(specifications)) {
    specification <- specifications[[index]]
    control <- mfrmr_gss_get("build_mfrm_optim_control")(
      specification$method,
      maxit = as.integer(maxit),
      reltol = specification$reltol
    )
    error <- ""
    started <- proc.time()[["elapsed"]]
    opt <- tryCatch(
      withCallingHandlers(
        stats::optim(
          current, fn, gr, method = specification$method,
          control = control
        ),
        warning = function(condition) {
          warnings <<- c(warnings, conditionMessage(condition))
          invokeRestart("muffleWarning")
        }
      ),
      error = function(condition) {
        error <<- conditionMessage(condition)
        NULL
      }
    )
    elapsed <- proc.time()[["elapsed"]] - started
    gradient <- if (is.null(opt)) {
      rep(NA_real_, length(start))
    } else {
      tryCatch(
        as.numeric(gr(opt$par)),
        error = function(condition) rep(NA_real_, length(start))
      )
    }
    gradient_sup <- if (all(is.finite(gradient))) {
      max(abs(gradient))
    } else Inf
    stages[[index]] <- list(
      index = index,
      method = specification$method,
      reltol = specification$reltol,
      opt = opt,
      gradient = gradient,
      gradient_sup = gradient_sup,
      elapsed = elapsed,
      error = error
    )
    if (!is.null(opt)) current <- opt$par
    if (!is.null(opt) && opt$convergence == 0L &&
        gradient_sup <= mfrmr_gpt_p1m_gradient_tolerance) break
  }
  current_gradient <- tryCatch(
    as.numeric(gr(current)),
    error = function(condition) rep(NA_real_, length(current))
  )
  if (
    all(is.finite(current_gradient)) &&
      max(abs(current_gradient)) > mfrmr_gpt_p1m_gradient_tolerance
  ) {
    for (newton_index in seq_len(2L)) {
      started <- proc.time()[["elapsed"]]
      error <- ""
      jacobian <- tryCatch(
        as.matrix(numDeriv::jacobian(
          gr, current, method = "Richardson"
        )),
        error = function(condition) {
          error <<- conditionMessage(condition)
          matrix(NA_real_, 0L, 0L)
        }
      )
      symmetric <- if (
        is.matrix(jacobian) &&
          identical(dim(jacobian), rep(length(current), 2L)) &&
          all(is.finite(jacobian))
      ) (jacobian + t(jacobian)) / 2 else matrix(NA_real_, 0L, 0L)
      minimum_eigenvalue <- if (length(symmetric) > 0L) {
        tryCatch(
          min(eigen(
            symmetric, symmetric = TRUE, only.values = TRUE
          )$values),
          error = function(condition) NA_real_
        )
      } else NA_real_
      step <- if (
        is.finite(minimum_eigenvalue) && minimum_eigenvalue > 0
      ) tryCatch(
        solve(symmetric, current_gradient),
        error = function(condition) {
          error <<- conditionMessage(condition)
          rep(NA_real_, length(current))
        }
      ) else rep(NA_real_, length(current))
      current_objective <- suppressWarnings(as.numeric(fn(current))[1L])
      current_gradient_sup <- max(abs(current_gradient))
      objective_roundoff_tolerance <-
        100 * .Machine$double.eps * max(1, abs(current_objective))
      accepted <- FALSE
      candidate <- current
      candidate_objective <- current_objective
      candidate_gradient <- current_gradient
      if (all(is.finite(step)) && is.finite(current_objective)) {
        for (alpha in c(1, 0.5, 0.25, 0.1, 0.05, 0.01)) {
          trial <- current - alpha * step
          trial_objective <- suppressWarnings(as.numeric(fn(trial))[1L])
          trial_gradient <- tryCatch(
            as.numeric(gr(trial)),
            error = function(condition) rep(NA_real_, length(trial))
          )
          if (
            is.finite(trial_objective) && all(is.finite(trial_gradient)) &&
              max(abs(trial_gradient)) < current_gradient_sup &&
              trial_objective <=
                current_objective + objective_roundoff_tolerance
          ) {
            candidate <- trial
            candidate_objective <- trial_objective
            candidate_gradient <- trial_gradient
            accepted <- TRUE
            break
          }
        }
      }
      gradient_sup <- if (all(is.finite(candidate_gradient))) {
        max(abs(candidate_gradient))
      } else Inf
      elapsed <- proc.time()[["elapsed"]] - started
      stages[[length(stages) + 1L]] <- list(
        index = length(stages) + 1L,
        method = "richardson_newton",
        reltol = NA_real_,
        opt = list(
          par = candidate,
          value = candidate_objective,
          convergence = if (accepted) 0L else 1L
        ),
        gradient = candidate_gradient,
        gradient_sup = gradient_sup,
        hessian = symmetric,
        minimum_eigenvalue = minimum_eigenvalue,
        elapsed = elapsed,
        error = error
      )
      if (accepted) {
        current <- candidate
        current_gradient <- candidate_gradient
      }
      if (!accepted || gradient_sup <= mfrmr_gpt_p1m_gradient_tolerance) {
        break
      }
    }
  }
  returned <- Filter(function(value) !is.null(value$opt), stages)
  if (length(returned) == 0L) return(list(
    returned = FALSE,
    par = rep(NA_real_, length(start)),
    selected = NULL,
    stages = stages,
    warnings = unique(warnings),
    elapsed = sum(vapply(stages, `[[`, numeric(1L), "elapsed"))
  ))
  ordering <- order(
    vapply(returned, function(value) value$gradient_sup, numeric(1L)),
    vapply(returned, function(value) value$opt$value, numeric(1L))
  )
  selected <- returned[[ordering[1L]]]
  list(
    returned = TRUE,
    par = as.numeric(selected$opt$par),
    selected = selected,
    stages = stages,
    warnings = unique(warnings),
    elapsed = sum(vapply(stages, `[[`, numeric(1L), "elapsed"))
  )
}

mfrmr_gpt_p1m_hessian <- function(fn, gr, value, independent = FALSE) {
  gradient_jacobian <- tryCatch(
    as.matrix(numDeriv::jacobian(gr, value, method = "Richardson")),
    error = function(condition) matrix(NA_real_, 0L, 0L)
  )
  available <- is.matrix(gradient_jacobian) &&
    identical(dim(gradient_jacobian), rep(length(value), 2L)) &&
    all(is.finite(gradient_jacobian))
  symmetric <- if (available) {
    (gradient_jacobian + t(gradient_jacobian)) / 2
  } else matrix(NA_real_, 0L, 0L)
  eigenvalues <- if (available) {
    tryCatch(
      eigen(symmetric, symmetric = TRUE, only.values = TRUE)$values,
      error = function(condition) numeric(0)
    )
  } else numeric(0)
  symmetry_relative <- if (available) {
    max(abs(gradient_jacobian - t(gradient_jacobian))) /
      max(1, abs(gradient_jacobian))
  } else NA_real_
  independent_hessian <- if (isTRUE(independent)) {
    tryCatch(
      as.matrix(numDeriv::hessian(fn, value, method = "Richardson")),
      error = function(condition) matrix(NA_real_, 0L, 0L)
    )
  } else matrix(NA_real_, 0L, 0L)
  independent_available <- isTRUE(independent) &&
    is.matrix(independent_hessian) &&
    identical(dim(independent_hessian), rep(length(value), 2L)) &&
    all(is.finite(independent_hessian))
  agreement <- if (available && independent_available) {
    max(abs(symmetric - independent_hessian))
  } else NA_real_
  agreement_relative <- if (available && independent_available) {
    agreement / max(1, abs(symmetric), abs(independent_hessian))
  } else NA_real_
  minimum <- if (length(eigenvalues) == length(value)) {
    min(eigenvalues)
  } else NA_real_
  maximum <- if (length(eigenvalues) == length(value)) {
    max(eigenvalues)
  } else NA_real_
  independent_symmetric <- if (independent_available) {
    (independent_hessian + t(independent_hessian)) / 2
  } else matrix(NA_real_, 0L, 0L)
  independent_eigenvalues <- if (independent_available) {
    tryCatch(
      eigen(
        independent_symmetric, symmetric = TRUE, only.values = TRUE
      )$values,
      error = function(condition) numeric(0)
    )
  } else numeric(0)
  independent_minimum <- if (
    length(independent_eigenvalues) == length(value)
  ) min(independent_eigenvalues) else NA_real_
  spectral_difference <- if (available && independent_available) {
    tryCatch(
      max(svd(
        symmetric - independent_symmetric, nu = 0L, nv = 0L
      )$d),
      error = function(condition) NA_real_
    )
  } else NA_real_
  spectral_perturbation_ratio <- if (
    is.finite(spectral_difference) && is.finite(minimum) && minimum > 0
  ) spectral_difference / minimum else Inf
  minimum_eigen_relative_difference <- if (
    is.finite(independent_minimum) && is.finite(minimum) && minimum > 0
  ) abs(independent_minimum - minimum) / minimum else Inf
  list(
    gradient_jacobian = gradient_jacobian,
    symmetric = symmetric,
    independent_hessian = independent_hessian,
    available = available,
    independent_scheduled = isTRUE(independent),
    independent_available = independent_available,
    symmetry_relative = symmetry_relative,
    minimum_eigenvalue = minimum,
    maximum_eigenvalue = maximum,
    condition_number = if (
      is.finite(minimum) && minimum > 0 && is.finite(maximum)
    ) maximum / minimum else Inf,
    agreement_max_abs_difference = agreement,
    agreement_relative_difference = agreement_relative,
    independent_minimum_eigenvalue = independent_minimum,
    spectral_difference = spectral_difference,
    spectral_perturbation_ratio = spectral_perturbation_ratio,
    minimum_eigen_relative_difference =
      minimum_eigen_relative_difference,
    positive_definite = available && is.finite(minimum) &&
      minimum > mfrmr_gpt_p1m_hessian_eigen_tolerance,
    symmetry_pass = available && is.finite(symmetry_relative) &&
      symmetry_relative <=
        mfrmr_gpt_p1m_hessian_symmetry_relative_tolerance,
    independent_agreement_pass = !isTRUE(independent) || (
      independent_available &&
        is.finite(independent_minimum) &&
        independent_minimum > mfrmr_gpt_p1m_hessian_eigen_tolerance &&
        is.finite(spectral_perturbation_ratio) &&
        spectral_perturbation_ratio <=
          mfrmr_gpt_p1m_hessian_spectral_perturbation_ratio_tolerance &&
        is.finite(minimum_eigen_relative_difference) &&
        minimum_eigen_relative_difference <=
          mfrmr_gpt_p1m_hessian_minimum_eigen_relative_tolerance
    )
  )
}

mfrmr_gpt_p1m_point <- function(
    representative,
    rho,
    starts,
    contexts,
    point_id,
    hessian_scheduled = FALSE,
    independent_hessian_scheduled = FALSE,
    maxit = 2000L) {
  starts <- lapply(starts, as.numeric)
  context <- contexts[["121"]]
  fn <- function(value) mfrmr_gorb_p1j_bundle(
    value, representative$Mu, rho, context,
    representative$FastIndex, representative$SlowIndex,
    include_gradient = FALSE
  )$objective
  gr <- function(value) mfrmr_gorb_p1j_bundle(
    value, representative$Mu, rho, context,
    representative$FastIndex, representative$SlowIndex,
    include_gradient = TRUE
  )$gradient
  fits <- lapply(starts, function(start) {
    optimized <- mfrmr_gpt_p1m_optimize(start, fn, gr, maxit = maxit)
    returned <- isTRUE(optimized$returned)
    value <- optimized$par
    bundle <- if (returned) mfrmr_gorb_p1j_bundle(
      value, representative$Mu, rho, context,
      representative$FastIndex, representative$SlowIndex,
      include_gradient = TRUE
    ) else NULL
    objectives <- if (returned) vapply(contexts, function(candidate_context) {
      mfrmr_gorb_p1j_bundle(
        value, representative$Mu, rho, candidate_context,
        representative$FastIndex, representative$SlowIndex,
        include_gradient = FALSE
      )$objective
    }, numeric(1L)) else setNames(rep(NA_real_, length(contexts)), names(contexts))
    gradient_sup <- if (returned && all(is.finite(bundle$gradient))) {
      max(abs(bundle$gradient))
    } else NA_real_
    convergence <- if (
      returned && !is.null(optimized$selected$opt)
    ) optimized$selected$opt$convergence else NA_integer_
    eligible <- returned && convergence == 0L &&
      is.finite(gradient_sup) &&
      gradient_sup <= mfrmr_gpt_p1m_gradient_tolerance &&
      all(is.finite(objectives)) &&
      diff(range(objectives)) <= mfrmr_gpt_p1m_quadrature_tolerance
    list(
      returned = returned,
      eligible = eligible,
      value = value,
      objective = if (returned) bundle$objective else NA_real_,
      derivative = if (returned) bundle$rho_gradient else NA_real_,
      gradient_sup = gradient_sup,
      objectives = objectives,
      convergence = convergence,
      optimized = optimized
    )
  })
  eligible_index <- which(vapply(fits, `[[`, logical(1L), "eligible"))
  selected_index <- if (length(eligible_index) > 0L) {
    eligible_index[which.min(vapply(
      fits[eligible_index], `[[`, numeric(1L), "objective"
    ))]
  } else NA_integer_
  selected <- if (is.na(selected_index)) NULL else fits[[selected_index]]
  route_objective_difference <- if (length(fits) == 2L &&
      all(vapply(fits, `[[`, logical(1L), "eligible"))) {
    abs(fits[[1L]]$objective - fits[[2L]]$objective)
  } else NA_real_
  route_coordinate_difference <- if (length(fits) == 2L &&
      all(vapply(fits, `[[`, logical(1L), "eligible"))) {
    max(abs(fits[[1L]]$value - fits[[2L]]$value))
  } else NA_real_
  routes_coalesce <- length(fits) == 1L || (
    is.finite(route_objective_difference) &&
      route_objective_difference <=
        mfrmr_gpt_p1m_route_objective_tolerance &&
      is.finite(route_coordinate_difference) &&
      route_coordinate_difference <=
        mfrmr_gpt_p1m_route_coordinate_tolerance
  )
  hessian <- if (!is.null(selected) && isTRUE(hessian_scheduled)) {
    mfrmr_gpt_p1m_hessian(
      fn, gr, selected$value,
      independent = independent_hessian_scheduled
    )
  } else NULL
  eligible <- !is.null(selected) && all(vapply(
    fits, `[[`, logical(1L), "eligible"
  )) && routes_coalesce && (
    !isTRUE(hessian_scheduled) || (
      isTRUE(hessian$positive_definite) &&
        isTRUE(hessian$symmetry_pass) &&
        isTRUE(hessian$independent_agreement_pass)
    )
  )
  row <- data.frame(
    RepresentativeId = representative$RepresentativeId,
    Lane = representative$Lane,
    CellId = representative$CellId,
    PointId = point_id,
    Rho = rho,
    RouteCount = length(starts),
    AllRoutesEligible = all(vapply(fits, `[[`, logical(1L), "eligible")),
    RoutesCoalesce = routes_coalesce,
    ObjectiveQ121 = if (is.null(selected)) NA_real_ else selected$objective,
    ObjectiveQ61 = if (is.null(selected)) NA_real_ else {
      selected$objectives[["61"]]
    },
    ObjectiveQ91 = if (is.null(selected)) NA_real_ else {
      selected$objectives[["91"]]
    },
    QuadratureObjectiveRange = if (is.null(selected)) NA_real_ else {
      diff(range(selected$objectives))
    },
    RhoObjectiveDerivative = if (is.null(selected)) NA_real_ else {
      selected$derivative
    },
    NuisanceGradientSupNorm = if (is.null(selected)) NA_real_ else {
      selected$gradient_sup
    },
    RouteObjectiveAbsDifference = route_objective_difference,
    RouteCoordinateMaxAbsDifference = route_coordinate_difference,
    HessianScheduled = isTRUE(hessian_scheduled),
    HessianAvailable = !is.null(hessian) && isTRUE(hessian$available),
    HessianSymmetryRelative = if (is.null(hessian)) NA_real_ else {
      hessian$symmetry_relative
    },
    MinimumNuisanceHessianEigenvalue = if (is.null(hessian)) NA_real_ else {
      hessian$minimum_eigenvalue
    },
    MaximumNuisanceHessianEigenvalue = if (is.null(hessian)) NA_real_ else {
      hessian$maximum_eigenvalue
    },
    NuisanceHessianConditionNumber = if (is.null(hessian)) NA_real_ else {
      hessian$condition_number
    },
    NuisanceHessianPositiveDefinite = !is.null(hessian) &&
      isTRUE(hessian$positive_definite),
    IndependentHessianScheduled = isTRUE(independent_hessian_scheduled),
    IndependentHessianAvailable = !is.null(hessian) &&
      isTRUE(hessian$independent_available),
    HessianAgreementMaxAbsDifference = if (is.null(hessian)) NA_real_ else {
      hessian$agreement_max_abs_difference
    },
    HessianAgreementRelativeDifference = if (is.null(hessian)) NA_real_ else {
      hessian$agreement_relative_difference
    },
    IndependentMinimumNuisanceHessianEigenvalue = if (
      is.null(hessian)
    ) NA_real_ else hessian$independent_minimum_eigenvalue,
    HessianSpectralPerturbationRatio = if (is.null(hessian)) {
      NA_real_
    } else hessian$spectral_perturbation_ratio,
    HessianMinimumEigenRelativeDifference = if (is.null(hessian)) {
      NA_real_
    } else hessian$minimum_eigen_relative_difference,
    PointEligible = eligible,
    FiniteNumericalAudit = TRUE,
    ContinuousGlobalProfileCertified = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    ElapsedSeconds = sum(vapply(fits, function(value) {
      value$optimized$elapsed
    }, numeric(1L))),
    StartVectorSHA256 = paste(vapply(
      starts, mfrmr_gss_hash_vector, character(1L)
    ), collapse = " | "),
    ReturnedVectorSHA256 = if (is.null(selected)) NA_character_ else {
      mfrmr_gss_hash_vector(selected$value)
    },
    stringsAsFactors = FALSE
  )
  list(
    row = row,
    value = if (is.null(selected)) rep(NA_real_, length(starts[[1L]])) else {
      selected$value
    },
    fits = fits,
    hessian = hessian
  )
}

mfrmr_gpt_p1m_bisect <- function(
    representative,
    result,
    contexts,
    bracket,
    maxit = 2000L,
    progress = FALSE) {
  left_start <- mfrmr_gpt_p1m_start_at(
    result, representative$CellId, "low_to_high", bracket$LeftRho
  )
  right_start <- mfrmr_gpt_p1m_start_at(
    result, representative$CellId, "low_to_high", bracket$RightRho
  )
  left <- mfrmr_gpt_p1m_point(
    representative, bracket$LeftRho, list(left_start), contexts,
    "initial_bracket_left", maxit = maxit
  )
  right <- mfrmr_gpt_p1m_point(
    representative, bracket$RightRho, list(right_start), contexts,
    "initial_bracket_right", maxit = maxit
  )
  expected <- c(bracket$LeftSign, bracket$RightSign)
  strict_sign <- c(
    mfrmr_gpt_p1m_derivative_sign(left$row$RhoObjectiveDerivative),
    mfrmr_gpt_p1m_derivative_sign(right$row$RhoObjectiveDerivative)
  )
  initial_valid <- isTRUE(left$row$PointEligible) &&
    isTRUE(right$row$PointEligible) && identical(strict_sign, expected)
  trace <- list(left$row, right$row)
  objects <- list(
    initial_bracket_left = left,
    initial_bracket_right = right
  )
  if (!initial_valid) return(list(
    returned = FALSE,
    initial_bracket_valid = FALSE,
    trace = do.call(rbind, trace),
    objects = objects,
    final = NULL,
    iterations = 0L,
    final_left = left,
    final_right = right
  ))
  iterations <- 0L
  while (
    right$row$Rho - left$row$Rho >
      mfrmr_gpt_p1m_bracket_width_tolerance &&
      iterations < mfrmr_gpt_p1m_max_bisection_iterations
  ) {
    iterations <- iterations + 1L
    rho <- (left$row$Rho + right$row$Rho) / 2
    if (isTRUE(progress)) message(
      "P1m bisection: ", representative$RepresentativeId,
      " / iteration=", iterations, " / rho=", rho
    )
    midpoint <- mfrmr_gpt_p1m_point(
      representative, rho,
      list((left$value + right$value) / 2), contexts,
      paste0("bisection_", iterations), maxit = maxit
    )
    trace[[length(trace) + 1L]] <- midpoint$row
    objects[[paste0("bisection_", iterations)]] <- midpoint
    if (!isTRUE(midpoint$row$PointEligible)) break
    derivative <- midpoint$row$RhoObjectiveDerivative
    if (!is.finite(derivative)) break
    if (derivative * expected[1L] > 0) {
      left <- midpoint
    } else {
      right <- midpoint
    }
  }
  final_rho <- (left$row$Rho + right$row$Rho) / 2
  final_starts <- list(
    mfrmr_gpt_p1m_start_at(
      result, representative$CellId, "low_to_high", final_rho
    ),
    mfrmr_gpt_p1m_start_at(
      result, representative$CellId, "high_to_low", final_rho
    )
  )
  final <- mfrmr_gpt_p1m_point(
    representative, final_rho, final_starts, contexts,
    "refined_turning_point",
    hessian_scheduled = TRUE,
    independent_hessian_scheduled = identical(
      representative$RepresentativeId, "objective_profile_maximum"
    ),
    maxit = maxit
  )
  trace[[length(trace) + 1L]] <- final$row
  objects$refined_turning_point <- final
  list(
    returned = isTRUE(final$row$PointEligible),
    initial_bracket_valid = initial_valid,
    trace = do.call(rbind, trace),
    objects = objects,
    final = final,
    iterations = iterations,
    final_left = left,
    final_right = right
  )
}

mfrmr_gpt_p1m_turning_audit <- function(
    representative,
    result,
    contexts,
    maxit = 2000L,
    progress = FALSE) {
  rows <- mfrmr_gpt_p1m_profile_rows(result, representative$CellId)
  bracket <- mfrmr_gpt_p1m_choose_bracket(
    rows, representative$MechanismClass
  )
  refined <- mfrmr_gpt_p1m_bisect(
    representative, result, contexts, bracket,
    maxit = maxit, progress = progress
  )
  endpoint_low <- mfrmr_gpt_p1m_point(
    representative, 0,
    list(mfrmr_gpt_p1m_start_at(
      result, representative$CellId, "low_to_high", 0
    )),
    contexts, "global_endpoint_low", maxit = maxit
  )
  endpoint_high <- mfrmr_gpt_p1m_point(
    representative, 1,
    list(mfrmr_gpt_p1m_start_at(
      result, representative$CellId, "high_to_low", 1
    )),
    contexts, "global_endpoint_high", maxit = maxit
  )
  trace <- rbind(refined$trace, endpoint_low$row, endpoint_high$row)
  objects <- c(
    refined$objects,
    list(global_endpoint_low = endpoint_low, global_endpoint_high = endpoint_high)
  )
  is_maximum <- identical(
    representative$MechanismClass,
    "route_coalescence_profile_maximum_bracket"
  )
  final_objective <- if (is.null(refined$final)) {
    NA_real_
  } else refined$final$row$ObjectiveQ121
  endpoint_objectives <- c(
    endpoint_low$row$ObjectiveQ121, endpoint_high$row$ObjectiveQ121
  )
  objective_shape_pass <- all(is.finite(c(
    final_objective, endpoint_objectives
  ))) && if (is_maximum) {
    final_objective > max(endpoint_objectives)
  } else {
    final_objective < min(endpoint_objectives)
  }
  preferred_endpoint <- if (!all(is.finite(endpoint_objectives))) {
    "unavailable"
  } else if (endpoint_objectives[1L] <= endpoint_objectives[2L]) {
    "rho_0"
  } else "rho_1"
  final_width <- refined$final_right$row$Rho - refined$final_left$row$Rho
  final_raw_sign_bracket <-
    refined$final_left$row$RhoObjectiveDerivative * bracket$LeftSign > 0 &&
    refined$final_right$row$RhoObjectiveDerivative * bracket$RightSign > 0
  local_supported <- isTRUE(refined$returned) &&
    isTRUE(refined$initial_bracket_valid) &&
    final_width <= mfrmr_gpt_p1m_bracket_width_tolerance &&
    isTRUE(final_raw_sign_bracket) &&
    isTRUE(refined$final$row$RoutesCoalesce) &&
    isTRUE(refined$final$row$NuisanceHessianPositiveDefinite) &&
    objective_shape_pass
  summary <- data.frame(
    RepresentativeId = representative$RepresentativeId,
    Lane = representative$Lane,
    CellId = representative$CellId,
    MechanismClass = representative$MechanismClass,
    InitialLeftRho = bracket$LeftRho,
    InitialRightRho = bracket$RightRho,
    InitialBracketWidth = bracket$InitialBracketWidth,
    InitialBracketValidAfterStrictPolish = refined$initial_bracket_valid,
    BisectionIterationCount = refined$iterations,
    FinalLeftRho = refined$final_left$row$Rho,
    FinalRightRho = refined$final_right$row$Rho,
    FinalBracketWidth = final_width,
    FinalRawDerivativeSignBracketValid = final_raw_sign_bracket,
    RefinedTurningPointRho = if (is.null(refined$final)) {
      NA_real_
    } else refined$final$row$Rho,
    RefinedTurningPointDerivative = if (is.null(refined$final)) {
      NA_real_
    } else refined$final$row$RhoObjectiveDerivative,
    RefinedTurningPointObjectiveQ121 = final_objective,
    LowEndpointObjectiveQ121 = endpoint_objectives[1L],
    HighEndpointObjectiveQ121 = endpoint_objectives[2L],
    PreferredEndpoint = preferred_endpoint,
    ObjectiveShapePass = objective_shape_pass,
    TurningPointRoutesCoalesce = !is.null(refined$final) &&
      isTRUE(refined$final$row$RoutesCoalesce),
    MinimumNuisanceHessianEigenvalue = if (is.null(refined$final)) {
      NA_real_
    } else refined$final$row$MinimumNuisanceHessianEigenvalue,
    NuisanceHessianConditionNumber = if (is.null(refined$final)) {
      NA_real_
    } else refined$final$row$NuisanceHessianConditionNumber,
    LocalTurningPointMechanismSupported = local_supported,
    ContinuousGlobalProfileCertified = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  list(summary = summary, trace = trace, objects = objects)
}

mfrmr_gpt_p1m_monotone_audit <- function(
    representative,
    result,
    contexts,
    maxit = 2000L,
    progress = FALSE) {
  trace <- list()
  objects <- list()
  current <- mfrmr_gpt_p1m_start_at(
    result, representative$CellId, "low_to_high", 0
  )
  for (index in seq_along(mfrmr_gpt_p1m_monotone_grid)) {
    rho <- mfrmr_gpt_p1m_monotone_grid[index]
    if (isTRUE(progress)) message(
      "P1m monotone grid: ", representative$RepresentativeId,
      " / rho=", rho
    )
    hessian_scheduled <- index == length(mfrmr_gpt_p1m_monotone_grid)
    point <- mfrmr_gpt_p1m_point(
      representative, rho, list(current), contexts,
      paste0("monotone_grid_", index),
      hessian_scheduled = hessian_scheduled,
      independent_hessian_scheduled = FALSE,
      maxit = maxit
    )
    trace[[index]] <- point$row
    objects[[paste0("monotone_grid_", index)]] <- point
    if (isTRUE(point$row$PointEligible)) current <- point$value
  }
  trace <- do.call(rbind, trace)
  all_positive <- all(
    trace$RhoObjectiveDerivative >
      mfrmr_gpt_p1m_derivative_sign_tolerance
  )
  nondecreasing_objective <- all(diff(trace$ObjectiveQ121) >=
    -mfrmr_gpt_p1m_route_objective_tolerance)
  endpoint_hessian <- trace[nrow(trace), , drop = FALSE]
  supported <- all(trace$PointEligible) && all_positive &&
    nondecreasing_objective &&
    isTRUE(endpoint_hessian$NuisanceHessianPositiveDefinite)
  summary <- data.frame(
    RepresentativeId = representative$RepresentativeId,
    Lane = representative$Lane,
    CellId = representative$CellId,
    MechanismClass = representative$MechanismClass,
    AdaptiveGridPointCount = nrow(trace),
    MinimumObservedRhoDerivative = min(trace$RhoObjectiveDerivative),
    MaximumObservedRhoDerivative = max(trace$RhoObjectiveDerivative),
    ObjectiveNondecreasingOnGrid = nondecreasing_objective,
    AllGridDerivativesStrictlyPositive = all_positive,
    MinimumNuisanceHessianEigenvalue =
      endpoint_hessian$MinimumNuisanceHessianEigenvalue,
    NuisanceHessianConditionNumber =
      endpoint_hessian$NuisanceHessianConditionNumber,
    AdaptiveGridMonotonicitySupported = supported,
    ContinuousMonotonicityCertified = FALSE,
    ContinuousGlobalProfileCertified = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  list(summary = summary, trace = trace, objects = objects)
}

mfrmr_gpt_p1m_overall <- function(turning, monotone) {
  all_turning_supported <- nrow(turning) == 3L &&
    all(turning$LocalTurningPointMechanismSupported)
  monotone_supported <- nrow(monotone) == 1L &&
    isTRUE(monotone$AdaptiveGridMonotonicitySupported)
  data.frame(
    RepresentativeMechanismCount = nrow(turning) + nrow(monotone),
    AllThreeTurningPointRepresentativesLocallySupported =
      all_turning_supported,
    MonotoneRepresentativeAdaptiveGridSupported = monotone_supported,
    AllRepresentativeLocalMechanismsSupported =
      all_turning_supported && monotone_supported,
    ContinuousMonotonicityCertified = FALSE,
    ContinuousGlobalProfileCertified = FALSE,
    ReflectedFixturesEvaluated = FALSE,
    FullFourFixtureRatioProfilesCompleted = FALSE,
    CoefficientRatioProfilesCompleted = FALSE,
    AllSixTwoTargetFacesGloballyCertified = FALSE,
    ThreeTargetFacesEvaluated = FALSE,
    EmptyRandomProductHierarchyComplete = FALSE,
    GlobalJointBoundaryProfileCertified = FALSE,
    HessianInferenceAuthorized = FALSE,
    DFFFitRankAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_run_gpcm_profile_turning_point_p1m <- function(
    objective_p1l,
    coordinate_p1l,
    maxit = 2000L,
    progress = FALSE) {
  mfrmr_gpt_p1m_require_sources()
  representatives <- mfrmr_gpt_p1m_representatives(
    objective_p1l, coordinate_p1l
  )
  contexts_by_scenario <- list()
  turning <- list()
  monotone <- NULL
  trace <- list()
  objects <- list()
  turning_index <- 1L
  for (index in seq_len(nrow(representatives))) {
    representative <- representatives[index, , drop = FALSE]
    result <- mfrmr_gpt_p1m_result_for_lane(
      objective_p1l, coordinate_p1l, representative$Lane
    )
    scenario <- representative$ScenarioId
    if (is.null(contexts_by_scenario[[scenario]])) {
      contexts_by_scenario[[scenario]] <- mfrmr_gorb_p1j_contexts(
        result$p1k$p1j$p1i, scenario
      )
    }
    contexts <- contexts_by_scenario[[scenario]]
    if (identical(
      representative$MechanismClass,
      "route_coalescence_monotone_increasing_grid"
    )) {
      audited <- mfrmr_gpt_p1m_monotone_audit(
        representative, result, contexts,
        maxit = maxit, progress = progress
      )
      monotone <- audited$summary
    } else {
      audited <- mfrmr_gpt_p1m_turning_audit(
        representative, result, contexts,
        maxit = maxit, progress = progress
      )
      turning[[turning_index]] <- audited$summary
      turning_index <- turning_index + 1L
    }
    trace[[representative$RepresentativeId]] <- audited$trace
    objects[[representative$RepresentativeId]] <- audited$objects
  }
  turning <- do.call(rbind, turning)
  rownames(turning) <- NULL
  rownames(monotone) <- NULL
  overall <- mfrmr_gpt_p1m_overall(turning, monotone)
  structure(
    list(
      contract = mfrmr_gpt_p1m_contract,
      specification = mfrmr_gpt_p1m_specification,
      dependency_contract = mfrmr_gpt_p1m_dependency_contract,
      dependency_sha256 = mfrmr_gpt_p1m_dependency_sha256,
      representatives = representatives,
      turning = turning,
      monotone = monotone,
      trace = trace,
      objects = objects,
      overall_decision = overall,
      objective_p1l = objective_p1l,
      coordinate_p1l = coordinate_p1l,
      AllRepresentativeLocalMechanismsSupported =
        overall$AllRepresentativeLocalMechanismsSupported,
      ContinuousMonotonicityCertified = FALSE,
      ContinuousGlobalProfileCertified = FALSE,
      ReflectedFixturesEvaluated = FALSE,
      FullFourFixtureRatioProfilesCompleted = FALSE,
      CoefficientRatioProfilesCompleted = FALSE,
      AllSixTwoTargetFacesGloballyCertified = FALSE,
      ThreeTargetFacesEvaluated = FALSE,
      EmptyRandomProductHierarchyComplete = FALSE,
      GlobalJointBoundaryProfileCertified = FALSE,
      HessianInferenceAuthorized = FALSE,
      DFFFitRankAuthorized = FALSE,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ),
    class = "mfrmr_gpcm_profile_turning_point_p1m"
  )
}
