# mfrmr 0.2.3 GPCM fixed-mu ordered-ratio profile P1k pilot
#
# P1k profiles the P1j ordered ratio rho on [0,1] at frozen mu values. The
# pilot uses one exact-high and one near-high reflection representative. It
# requires boundary-aware KKT conditions for rho and ordinary stationarity for
# all nuisance coordinates. It does not use optimizer code zero alone and does
# not promote the unrun reflected fixtures or three-target faces.

mfrmr_gfmr_p1k_specification <- "0.2.3-draft.1"
mfrmr_gfmr_p1k_contract <- "mfrmr_gpcm_fixed_mu_ratio_profile_p1k_v1"
mfrmr_gfmr_p1k_dependency_contract <-
  "mfrmr_gpcm_ordered_ratio_boundary_p1j_v1"
mfrmr_gfmr_p1k_dependency_sha256 <-
  "b8438e014db1cfa55ea55669991b693f43a2ec8834a97ffb5505268774be6d26"
mfrmr_gfmr_p1k_representative_scenarios <-
  c("EXT5-P-HI", "EXT5-P-NEAR-HI")
mfrmr_gfmr_p1k_routes <-
  c("singleton_boundary", "p1i_equal_side")
mfrmr_gfmr_p1k_mu_grid <- mfrmr_gtr_p1i_tau_grid
mfrmr_gfmr_p1k_quadrature <- mfrmr_gtr_p1i_quadrature
mfrmr_gfmr_p1k_route_tolerance <- 5e-6
mfrmr_gfmr_p1k_rho_tolerance <- 5e-5
mfrmr_gfmr_p1k_boundary_tolerance <- 1e-7
mfrmr_gfmr_p1k_kkt_tolerance <- 1e-4
mfrmr_gfmr_p1k_numeric_gradient_tolerance <- 5e-5
mfrmr_gfmr_p1k_numeric_gradient_step <- 1e-5
mfrmr_gfmr_p1k_derivative_mus <- c(0, 0.2)

mfrmr_gfmr_p1k_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gfmr_p1k_clamp_rho <- function(value) {
  min(1, max(0, as.numeric(value)[1L]))
}

mfrmr_gfmr_p1k_require_sources <- function() {
  target <- environment(mfrmr_gfmr_p1k_require_sources)
  required <- c(
    "mfrmr_gorb_p1j_contract", "mfrmr_gorb_p1j_ordered_pairs",
    "mfrmr_gorb_p1j_bundle", "mfrmr_gorb_p1j_from_p1i",
    "mfrmr_gorb_p1j_single_profile_rows",
    "mfrmr_gorb_p1j_single_object", "mfrmr_gorb_p1j_contexts",
    "mfrmr_gtr_p1i_target_id", "mfrmr_num_central_gradient",
    "mfrmr_gss_get", "mfrmr_gss_hash_vector"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )
  mfrmr_gfmr_p1k_assert(
    all(available) && identical(
      get("mfrmr_gorb_p1j_contract", envir = target, inherits = TRUE),
      mfrmr_gfmr_p1k_dependency_contract
    ),
    "Source P0 through P1j and their numerical dependencies before P1k."
  )
  invisible(TRUE)
}

mfrmr_gfmr_p1k_plan <- function(
    scenarios = mfrmr_gfmr_p1k_representative_scenarios) {
  scenarios <- as.character(scenarios)
  rows <- merge(
    expand.grid(
      ScenarioId = scenarios,
      RouteId = mfrmr_gfmr_p1k_routes,
      Mu = mfrmr_gfmr_p1k_mu_grid,
      KEEP.OUT.ATTRS = FALSE,
      stringsAsFactors = FALSE
    ),
    mfrmr_gorb_p1j_ordered_pairs,
    by = NULL
  )
  rows$ScenarioOrder <- match(rows$ScenarioId, scenarios)
  rows$OrderedPairOrder <- match(
    rows$OrderedPairId,
    mfrmr_gorb_p1j_ordered_pairs$OrderedPairId
  )
  rows$RouteOrder <- match(rows$RouteId, mfrmr_gfmr_p1k_routes)
  rows$MuOrder <- match(rows$Mu, mfrmr_gfmr_p1k_mu_grid)
  rows <- rows[order(
    rows$ScenarioOrder, rows$OrderedPairOrder,
    rows$MuOrder, rows$RouteOrder
  ), , drop = FALSE]
  rownames(rows) <- NULL
  rows$OptimizationQuadrature <- 121L
  rows$IndependentGradientScheduled <-
    rows$RouteId == "singleton_boundary" &
      rows$Mu %in% mfrmr_gfmr_p1k_derivative_mus
  rows$SelectionAuthorized <- FALSE
  rows$ConfirmationAuthorized <- FALSE
  list(
    profile = rows,
    representative_scenario_count = length(scenarios),
    ordered_pair_count = 12L,
    fixed_mu_cell_count = length(scenarios) * 12L * 7L,
    fit_count = nrow(rows),
    reflected_fixtures_evaluated = FALSE,
    full_four_fixture_profile_completed = FALSE,
    three_target_faces_evaluated = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE
  )
}

mfrmr_gfmr_p1k_best_single <- function(
    p1j,
    scenario_id,
    target_index,
    mu) {
  single <- mfrmr_gorb_p1j_single_profile_rows(p1j$p1i)
  rows <- single[
    single$ScenarioId == scenario_id &
      single$TargetIndex == target_index &
      single$Lambda == mu &
      single$ProfileCandidateEligible, , drop = FALSE
  ]
  mfrmr_gfmr_p1k_assert(
    nrow(rows) >= 1L,
    "P1k requires at least one eligible frozen singleton start."
  )
  row <- rows[which.min(rows$ObjectiveQ121), , drop = FALSE]
  list(
    row = row,
    x = mfrmr_gorb_p1j_single_object(
      p1j$p1i, scenario_id, target_index, row$RouteId, mu
    )
  )
}

mfrmr_gfmr_p1k_p1i_equal_start <- function(
    p1j,
    scenario_id,
    fast_index,
    slow_index,
    mu,
    context) {
  if (mu == 0) {
    slow <- mfrmr_gfmr_p1k_best_single(
      p1j, scenario_id, slow_index, mu
    )$x
    fast <- mfrmr_gfmr_p1k_best_single(
      p1j, scenario_id, fast_index, mu
    )$x
    return(list(x = (slow + fast) / 2, rho = 1))
  }
  target_indices <- sort(c(fast_index, slow_index))
  target_set_id <- mfrmr_gtr_p1i_target_id(target_indices)
  rows <- p1j$p1i$profile[
    p1j$p1i$profile$ScenarioId == scenario_id &
      p1j$p1i$profile$TargetSetId == target_set_id &
      p1j$p1i$profile$Tau == mu &
      p1j$p1i$profile$ProfileCandidateEligible, , drop = FALSE
  ]
  mfrmr_gfmr_p1k_assert(
    nrow(rows) >= 1L,
    "P1k requires an eligible positive P1i start at each positive mu."
  )
  row <- rows[which.min(rows$ObjectiveQ121), , drop = FALSE]
  key <- paste(
    scenario_id, target_set_id, row$RouteId, mu, sep = "::"
  )
  candidate <- p1j$p1i$profile_objects[[key]]
  converted <- mfrmr_gorb_p1j_from_p1i(
    candidate$w, mu, context, target_indices,
    fast_index, slow_index
  )
  list(x = converted$x, rho = 1)
}

mfrmr_gfmr_p1k_start <- function(
    p1j,
    scenario_id,
    route_id,
    fast_index,
    slow_index,
    mu,
    context) {
  if (route_id == "singleton_boundary") {
    single <- mfrmr_gfmr_p1k_best_single(
      p1j, scenario_id, slow_index, mu
    )
    return(c(single$x, 0))
  }
  if (route_id == "p1i_equal_side") {
    equal <- mfrmr_gfmr_p1k_p1i_equal_start(
      p1j, scenario_id, fast_index, slow_index, mu, context
    )
    return(c(equal$x, equal$rho))
  }
  stop("Unknown P1k route.", call. = FALSE)
}

mfrmr_gfmr_p1k_kkt <- function(value, gradient) {
  value <- as.numeric(value)
  gradient <- as.numeric(gradient)
  mfrmr_gfmr_p1k_assert(
    length(value) == length(gradient) && length(value) >= 2L &&
      all(is.finite(c(value, gradient))),
    "P1k KKT evaluation requires finite matching vectors."
  )
  rho <- value[length(value)]
  nuisance <- gradient[-length(gradient)]
  rho_gradient <- gradient[length(gradient)]
  rho_location <- if (rho <= mfrmr_gfmr_p1k_boundary_tolerance) {
    "lower"
  } else if (rho >= 1 - mfrmr_gfmr_p1k_boundary_tolerance) {
    "upper"
  } else {
    "interior"
  }
  rho_violation <- switch(
    rho_location,
    lower = max(0, -rho_gradient),
    upper = max(0, rho_gradient),
    interior = abs(rho_gradient)
  )
  nuisance_sup <- max(abs(nuisance))
  list(
    rho = rho,
    rho_location = rho_location,
    rho_gradient = rho_gradient,
    rho_kkt_violation = rho_violation,
    nuisance_gradient_sup = nuisance_sup,
    kkt_sup = max(nuisance_sup, rho_violation),
    kkt_pass = max(nuisance_sup, rho_violation) <=
      mfrmr_gfmr_p1k_kkt_tolerance
  )
}

mfrmr_gfmr_p1k_optimize <- function(
    start,
    fn,
    gr,
    maxit,
    reltol) {
  start <- as.numeric(start)
  lower <- c(rep(-Inf, length(start) - 1L), 0)
  upper <- c(rep(Inf, length(start) - 1L), 1)
  stages <- list()
  warnings <- character(0)
  current <- start
  tolerances <- unique(c(
    reltol,
    mfrmr_gss_get("mfrm_optimizer_polish_tolerances")(reltol)
  ))
  for (index in seq_along(tolerances)) {
    stage_reltol <- tolerances[index]
    control <- mfrmr_gss_get("build_mfrm_optim_control")(
      "L-BFGS-B", maxit = maxit, reltol = stage_reltol
    )
    error <- ""
    started <- proc.time()[["elapsed"]]
    opt <- tryCatch(
      withCallingHandlers(
        stats::optim(
          par = current, fn = fn, gr = gr,
          method = "L-BFGS-B", lower = lower, upper = upper,
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
    if (is.null(opt)) {
      stages[[index]] <- list(
        index = index, reltol = stage_reltol, opt = NULL,
        kkt = NULL, elapsed = elapsed, error = error
      )
      next
    }
    gradient <- suppressWarnings(as.numeric(gr(opt$par)))
    kkt <- if (
      length(gradient) == length(opt$par) &&
        all(is.finite(c(opt$par, gradient)))
    ) mfrmr_gfmr_p1k_kkt(opt$par, gradient) else NULL
    stages[[index]] <- list(
      index = index, reltol = stage_reltol, opt = opt,
      gradient = gradient, kkt = kkt,
      elapsed = elapsed, error = error
    )
    current <- opt$par
    if (!is.null(kkt) && isTRUE(kkt$kkt_pass) && opt$convergence == 0L) {
      break
    }
  }
  returned_stages <- Filter(function(value) !is.null(value$opt), stages)
  if (length(returned_stages) == 0L) {
    return(list(
      returned = FALSE,
      par = rep(NA_real_, length(start)),
      selected = NULL,
      stages = stages,
      warnings = unique(warnings),
      errors = unique(vapply(stages, `[[`, character(1L), "error")),
      elapsed = sum(vapply(stages, `[[`, numeric(1L), "elapsed"))
    ))
  }
  rank_stage <- function(value) {
    c(
      !isTRUE(value$kkt$kkt_pass),
      value$kkt$kkt_sup,
      value$opt$value
    )
  }
  ordering <- do.call(rbind, lapply(returned_stages, rank_stage))
  selected <- returned_stages[[do.call(order, as.data.frame(ordering))[1L]]]
  list(
    returned = TRUE,
    par = as.numeric(selected$opt$par),
    selected = selected,
    stages = stages,
    warnings = unique(warnings),
    errors = unique(vapply(stages, `[[`, character(1L), "error")),
    elapsed = sum(vapply(stages, `[[`, numeric(1L), "elapsed"))
  )
}

mfrmr_gfmr_p1k_profile_candidate <- function(
    p1j,
    scenario_id,
    route_id,
    fast_index,
    slow_index,
    mu,
    contexts,
    maxit,
    reltol) {
  context <- contexts[["121"]]
  layout <- mfrmr_gc4_p1g_layout(context)
  start <- mfrmr_gfmr_p1k_start(
    p1j, scenario_id, route_id, fast_index, slow_index, mu, context
  )
  fn <- function(value) mfrmr_gorb_p1j_bundle(
    value[seq_len(layout$dimension)], mu,
    mfrmr_gfmr_p1k_clamp_rho(value[layout$dimension + 1L]),
    context, fast_index, slow_index, include_gradient = FALSE
  )$objective
  gr <- function(value) {
    bundle <- mfrmr_gorb_p1j_bundle(
      value[seq_len(layout$dimension)], mu,
      mfrmr_gfmr_p1k_clamp_rho(value[layout$dimension + 1L]), context,
      fast_index, slow_index, include_gradient = TRUE
    )
    c(bundle$gradient, bundle$rho_gradient)
  }
  optimized <- mfrmr_gfmr_p1k_optimize(
    start, fn, gr, maxit, reltol
  )
  returned <- isTRUE(optimized$returned)
  value <- optimized$par
  objective <- NA_real_
  gradient <- rep(NA_real_, length(start))
  kkt <- list(
    rho = NA_real_, rho_location = "not_returned",
    rho_gradient = NA_real_, rho_kkt_violation = NA_real_,
    nuisance_gradient_sup = NA_real_, kkt_sup = NA_real_,
    kkt_pass = FALSE
  )
  objectives <- setNames(rep(NA_real_, length(contexts)), names(contexts))
  derivative_scheduled <- route_id == "singleton_boundary" &&
    mu %in% mfrmr_gfmr_p1k_derivative_mus
  numeric_difference <- NA_real_
  if (returned) {
    value[layout$dimension + 1L] <- mfrmr_gfmr_p1k_clamp_rho(
      value[layout$dimension + 1L]
    )
    objective <- fn(value)
    gradient <- gr(value)
    kkt <- mfrmr_gfmr_p1k_kkt(value, gradient)
    objectives <- vapply(contexts, function(candidate_context) {
      mfrmr_gorb_p1j_bundle(
        value[seq_len(layout$dimension)], mu,
        mfrmr_gfmr_p1k_clamp_rho(value[layout$dimension + 1L]),
        candidate_context,
        fast_index, slow_index, include_gradient = FALSE
      )$objective
    }, numeric(1L))
    if (derivative_scheduled && identical(kkt$rho_location, "interior")) {
      numeric_gradient <- mfrmr_num_central_gradient(
        fn, value, mfrmr_gfmr_p1k_numeric_gradient_step
      )
      numeric_difference <- max(abs(gradient - numeric_gradient))
    } else if (derivative_scheduled) {
      # Independent nuisance derivatives remain central. The constrained rho
      # derivative is checked by the P1j one-sided rule and the analytic KKT
      # sign, so it is excluded from an invalid central boundary perturbation.
      numeric_nuisance <- mfrmr_num_central_gradient(
        function(nuisance) fn(c(nuisance, kkt$rho)),
        value[seq_len(layout$dimension)],
        mfrmr_gfmr_p1k_numeric_gradient_step
      )
      numeric_difference <- max(abs(
        gradient[seq_len(layout$dimension)] - numeric_nuisance
      ))
    }
  }
  convergence_code <- if (
    returned && !is.null(optimized$selected$opt)
  ) optimized$selected$opt$convergence else NA_integer_
  derivative_complete <- !derivative_scheduled || (
    is.finite(numeric_difference) &&
      numeric_difference <= mfrmr_gfmr_p1k_numeric_gradient_tolerance
  )
  eligible <- returned && convergence_code == 0L &&
    isTRUE(kkt$kkt_pass) && all(is.finite(objectives)) &&
    derivative_complete
  row <- data.frame(
    ScenarioId = scenario_id,
    OrderedPairId = paste0(
      "C", fast_index, "_fast__C", slow_index, "_slow"
    ),
    FastIndex = fast_index,
    SlowIndex = slow_index,
    TargetSetId = mfrmr_gtr_p1i_target_id(c(fast_index, slow_index)),
    RouteId = route_id,
    Mu = mu,
    FitReturned = returned,
    ObjectiveQ121 = objective,
    ObjectiveQ61 = as.numeric(objectives[["61"]]),
    ObjectiveQ91 = as.numeric(objectives[["91"]]),
    QuadratureObjectiveRange = if (all(is.finite(objectives))) {
      diff(range(objectives))
    } else NA_real_,
    Rho = kkt$rho,
    RhoLocation = kkt$rho_location,
    RhoObjectiveDerivative = kkt$rho_gradient,
    RhoKktViolation = kkt$rho_kkt_violation,
    NuisanceGradientSupNorm = kkt$nuisance_gradient_sup,
    KktSupNorm = kkt$kkt_sup,
    KktPass = kkt$kkt_pass,
    ConvergenceCode = convergence_code,
    IndependentGradientScheduled = derivative_scheduled,
    AnalyticNumericGradientMaxAbsDifference = numeric_difference,
    ProfileCandidateEligible = eligible,
    ProfileEligibilityReason = if (eligible) {
      paste0("stationary_fixed_mu_ratio_", kkt$rho_location)
    } else if (returned) {
      "fixed_mu_ratio_returned_but_inference_ineligible"
    } else {
      "fixed_mu_ratio_not_returned"
    },
    ReflectedFixturesEvaluated = FALSE,
    FullFourFixtureProfileCompleted = FALSE,
    FullTwoTargetFaceGloballyCertified = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    ElapsedSeconds = optimized$elapsed,
    WarningCount = length(optimized$warnings),
    WarningText = paste(optimized$warnings, collapse = " | "),
    ErrorText = paste(optimized$errors[nzchar(optimized$errors)], collapse = " | "),
    StartVectorSHA256 = mfrmr_gss_hash_vector(start),
    ReturnedVectorSHA256 = if (returned) {
      mfrmr_gss_hash_vector(value)
    } else NA_character_,
    stringsAsFactors = FALSE
  )
  list(row = row, value = value, optimized = optimized)
}

mfrmr_gfmr_p1k_pairwise <- function(profile) {
  key <- interaction(
    profile$ScenarioId, profile$OrderedPairId, profile$Mu, drop = TRUE
  )
  groups <- split(profile, key)
  out <- lapply(groups, function(value) {
    first <- value[value$RouteId == mfrmr_gfmr_p1k_routes[1L], , drop = FALSE]
    second <- value[value$RouteId == mfrmr_gfmr_p1k_routes[2L], , drop = FALSE]
    complete <- nrow(first) == 1L && nrow(second) == 1L
    objective_difference <- if (complete) {
      abs(first$ObjectiveQ121 - second$ObjectiveQ121)
    } else NA_real_
    rho_difference <- if (complete) abs(first$Rho - second$Rho) else NA_real_
    eligible <- complete &&
      isTRUE(first$ProfileCandidateEligible) &&
      isTRUE(second$ProfileCandidateEligible)
    objective_agreement <- eligible && is.finite(objective_difference) &&
      objective_difference <= mfrmr_gfmr_p1k_route_tolerance
    rho_agreement <- eligible && is.finite(rho_difference) &&
      rho_difference <= mfrmr_gfmr_p1k_rho_tolerance
    agreement_class <- if (!eligible) {
      "route_ineligible"
    } else if (objective_agreement && rho_agreement) {
      "same_solution"
    } else if (objective_agreement) {
      "same_objective_coordinate_distinct"
    } else {
      "competing_kkt_solutions"
    }
    best_route_id <- if (!complete) NA_character_ else if (
      first$ObjectiveQ121 <= second$ObjectiveQ121
    ) first$RouteId else second$RouteId
    data.frame(
      ScenarioId = value$ScenarioId[1L],
      OrderedPairId = value$OrderedPairId[1L],
      FastIndex = value$FastIndex[1L],
      SlowIndex = value$SlowIndex[1L],
      TargetSetId = value$TargetSetId[1L],
      Mu = value$Mu[1L],
      BothRoutesPresent = complete,
      BothRoutesEligible = eligible,
      ObjectiveAbsDifference = objective_difference,
      RhoAbsDifference = rho_difference,
      ObjectiveAgreementWithinTolerance = objective_agreement,
      RhoAgreementWithinTolerance = rho_agreement,
      RoutesAgreeWithinTolerance = objective_agreement && rho_agreement,
      RouteAgreementClass = agreement_class,
      BestObservedRouteId = best_route_id,
      MinimumObjectiveQ121 = if (complete) {
        min(first$ObjectiveQ121, second$ObjectiveQ121)
      } else NA_real_,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  result <- do.call(rbind, out)
  rownames(result) <- NULL
  result
}

mfrmr_gfmr_p1k_portfolio <- function(profile, p1j) {
  groups <- split(
    profile,
    interaction(profile$ScenarioId, profile$TargetSetId, drop = TRUE)
  )
  out <- lapply(groups, function(value) {
    eligible <- value[value$ProfileCandidateEligible, , drop = FALSE]
    interior <- unique(p1j$p1i$profile$InteriorObjectiveQ121[
      p1j$p1i$profile$ScenarioId == value$ScenarioId[1L]
    ])
    mfrmr_gfmr_p1k_assert(
      length(interior) == 1L,
      "P1k portfolio requires one qualified interior objective."
    )
    best <- if (nrow(eligible) > 0L) min(eligible$ObjectiveQ121) else NA_real_
    data.frame(
      ScenarioId = value$ScenarioId[1L],
      TargetSetId = value$TargetSetId[1L],
      EligibleCandidateCount = nrow(eligible),
      BestObservedObjectiveQ121 = best,
      QualifiedInteriorObjectiveQ121 = interior,
      BestObservedMinusInterior = best - interior,
      BestObservedAboveInterior = is.finite(best) && best > interior,
      RatioProfileGloballyCertified = FALSE,
      FullTwoTargetFaceGloballyCertified = FALSE,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  result <- do.call(rbind, out)
  rownames(result) <- NULL
  result[order(result$ScenarioId, result$TargetSetId), , drop = FALSE]
}

mfrmr_gfmr_p1k_overall_decision <- function(
    profile,
    pairwise,
    portfolio,
    scenarios) {
  expected_profiles <- length(scenarios) * 12L * 7L * 2L
  expected_cells <- length(scenarios) * 12L * 7L
  all_fits_eligible <- nrow(profile) == expected_profiles &&
    all(profile$ProfileCandidateEligible)
  all_cells_eligible <- nrow(pairwise) == expected_cells &&
    all(pairwise$BothRoutesEligible)
  agreement_counts <- table(factor(
    pairwise$RouteAgreementClass,
    levels = c(
      "same_solution", "same_objective_coordinate_distinct",
      "competing_kkt_solutions", "route_ineligible"
    )
  ))
  complete <- all_fits_eligible && all_cells_eligible &&
    all(pairwise$RoutesAgreeWithinTolerance)
  data.frame(
    AllRepresentativeFitsEligible = all_fits_eligible,
    AllRepresentativeCellsHaveTwoEligibleRoutes = all_cells_eligible,
    SameSolutionCellCount = unname(agreement_counts[["same_solution"]]),
    SameObjectiveCoordinateDistinctCellCount = unname(
      agreement_counts[["same_objective_coordinate_distinct"]]
    ),
    CompetingKktSolutionCellCount = unname(
      agreement_counts[["competing_kkt_solutions"]]
    ),
    RouteIneligibleCellCount = unname(agreement_counts[["route_ineligible"]]),
    AnyCompetingKktSolutions =
      agreement_counts[["competing_kkt_solutions"]] > 0L,
    AllObservedRepresentativeMinimaAboveInterior =
      nrow(portfolio) == length(scenarios) * 6L &&
      all(portfolio$BestObservedAboveInterior),
    RepresentativeFixedMuRatioProfilesCompleted = complete,
    RepresentativeScenarioCount = length(scenarios),
    ReflectedFixturesEvaluated = FALSE,
    FullFourFixtureRatioProfilesCompleted = FALSE,
    CoefficientRatioProfilesCompleted = FALSE,
    AllSixTwoTargetFacesGloballyCertified = FALSE,
    ThreeTargetFacesEvaluated = FALSE,
    EmptyRandomProductHierarchyComplete = FALSE,
    GlobalJointBoundaryProfileCertified = FALSE,
    SourceSolutionDecision = if (complete) {
      "blocked_reflected_ratio_profiles_three_target_faces_remaining_rater_strata_and_upper_boundary_open"
    } else {
      "blocked_representative_ratio_profiles_incomplete"
    },
    HessianAuthorized = FALSE,
    DFFFitRankAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_run_gpcm_fixed_mu_ratio_profile_p1k <- function(
    p1j,
    scenarios = mfrmr_gfmr_p1k_representative_scenarios,
    maxit = 800L,
    reltol = 1e-12,
    progress = FALSE) {
  mfrmr_gfmr_p1k_require_sources()
  mfrmr_gfmr_p1k_assert(
    is.list(p1j) && identical(
      p1j$contract, mfrmr_gfmr_p1k_dependency_contract
    ),
    "P1k requires one complete P1j dependency result."
  )
  scenarios <- as.character(scenarios)
  mfrmr_gfmr_p1k_assert(
    length(scenarios) >= 1L &&
      all(scenarios %in% mfrmr_gcl_p1e_scenarios),
    "P1k scenarios must be declared endpoint fixtures."
  )
  plan <- mfrmr_gfmr_p1k_plan(scenarios)
  rows <- list()
  objects <- list()
  row_index <- 1L
  for (scenario_id in scenarios) {
    contexts <- mfrmr_gorb_p1j_contexts(p1j$p1i, scenario_id)
    for (order_index in seq_len(nrow(mfrmr_gorb_p1j_ordered_pairs))) {
      order <- mfrmr_gorb_p1j_ordered_pairs[order_index, ]
      for (mu in mfrmr_gfmr_p1k_mu_grid) {
        for (route_id in mfrmr_gfmr_p1k_routes) {
          if (isTRUE(progress)) message(
            "Fixed-mu P1k: ", scenario_id, " / ",
            order$OrderedPairId, " / mu=", mu, " / ", route_id
          )
          candidate <- mfrmr_gfmr_p1k_profile_candidate(
            p1j = p1j,
            scenario_id = scenario_id,
            route_id = route_id,
            fast_index = order$FastIndex,
            slow_index = order$SlowIndex,
            mu = mu,
            contexts = contexts,
            maxit = maxit,
            reltol = reltol
          )
          key <- paste(
            scenario_id, order$OrderedPairId, mu, route_id, sep = "::"
          )
          rows[[row_index]] <- candidate$row
          objects[[key]] <- candidate
          row_index <- row_index + 1L
        }
      }
    }
  }
  profile <- do.call(rbind, rows)
  rownames(profile) <- NULL
  pairwise <- mfrmr_gfmr_p1k_pairwise(profile)
  portfolio <- mfrmr_gfmr_p1k_portfolio(profile, p1j)
  overall <- mfrmr_gfmr_p1k_overall_decision(
    profile, pairwise, portfolio, scenarios
  )
  structure(
    list(
      contract = mfrmr_gfmr_p1k_contract,
      specification = mfrmr_gfmr_p1k_specification,
      dependency_contract = mfrmr_gfmr_p1k_dependency_contract,
      dependency_sha256 = mfrmr_gfmr_p1k_dependency_sha256,
      scenarios = scenarios,
      plan = plan,
      profile = profile,
      profile_objects = objects,
      pairwise = pairwise,
      portfolio = portfolio,
      overall_decision = overall,
      p1j = p1j,
      RepresentativeFixedMuRatioProfilesCompleted =
        overall$RepresentativeFixedMuRatioProfilesCompleted,
      ReflectedFixturesEvaluated = FALSE,
      FullFourFixtureRatioProfilesCompleted = FALSE,
      CoefficientRatioProfilesCompleted = FALSE,
      AllSixTwoTargetFacesGloballyCertified = FALSE,
      ThreeTargetFacesEvaluated = FALSE,
      EmptyRandomProductHierarchyComplete = FALSE,
      GlobalJointBoundaryProfileCertified = FALSE,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ),
    class = "mfrmr_gpcm_fixed_mu_ratio_profile_p1k"
  )
}
