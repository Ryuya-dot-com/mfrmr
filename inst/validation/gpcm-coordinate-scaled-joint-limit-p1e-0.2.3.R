# mfrmr 0.2.3 coordinate-scaled GPCM joint-limit P1e audit
#
# P1d identified numerical stiffness on a joint path with
#   epsilon = exp(-t), rho = exp(-t / (J - 1)),
#   sigma = sigma0 * epsilon,
#   a_target = a_target0 / epsilon,
#   a_other = a_other0 * rho.
# P1e uses an exact finite-t reparameterization. Target location, Rater, and
# target steps are epsilon-scaled; non-target locations and steps are
# rho-inverse-scaled. It also evaluates and optimizes the resulting t -> Inf
# reduced likelihood directly. This fixture-specific audit does not profile
# other slope-rate rays or select a package solution.

mfrmr_gcl_p1e_specification <- "0.2.3-draft.1"
mfrmr_gcl_p1e_contract <-
  "mfrmr_gpcm_coordinate_scaled_joint_limit_p1e_v1"
mfrmr_gcl_p1e_dependency_contract <-
  "mfrmr_gpcm_zero_variance_log_slope_path_p1d_v1"
mfrmr_gcl_p1e_dependency_sha256 <-
  "5480c1e9c1ff04e208df9e375dd54b99395b25df28b11b5ba96625259338af51"
mfrmr_gcl_p1e_scenarios <- c(
  "EXT5-P-HI", "EXT5-P-LO", "EXT5-P-NEAR-HI", "EXT5-P-NEAR-LO"
)
mfrmr_gcl_p1e_routes <- c("interior_forward", "boundary_reverse")
mfrmr_gcl_p1e_t_ladder <- c(4, 6, 8, 10)
mfrmr_gcl_p1e_quadrature <- c(61L, 91L, 121L)
mfrmr_gcl_p1e_derivative_step <- 1e-6

mfrmr_gcl_p1e_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gcl_p1e_require_sources <- function() {
  target <- environment(mfrmr_gcl_p1e_require_sources)
  required <- c(
    "mfrmr_gjs_p1d_contract",
    "mfrmr_run_gpcm_zero_variance_log_slope_path_p1d",
    "mfrmr_gjs_p1d_fixed_path", "mfrmr_gqi_p1b_context",
    "mfrmr_num_central_gradient", "mfrmr_gss_get",
    "mfrmr_gss_hash_vector", "mfrmr_gss_compare_signatures"
  )
  available <- vapply(
    required, exists, logical(1), envir = target, inherits = TRUE
  )
  mfrmr_gcl_p1e_assert(
    all(available) && identical(
      get("mfrmr_gjs_p1d_contract", envir = target, inherits = TRUE),
      mfrmr_gcl_p1e_dependency_contract
    ),
    paste0(
      "Source P0 through P1d and their numerical dependencies before P1e."
    )
  )
  invisible(TRUE)
}

mfrmr_gcl_p1e_plan <- function() {
  finite <- expand.grid(
    ScenarioId = mfrmr_gcl_p1e_scenarios,
    RouteId = mfrmr_gcl_p1e_routes,
    T = mfrmr_gcl_p1e_t_ladder,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  finite$ScenarioOrder <- match(
    finite$ScenarioId, mfrmr_gcl_p1e_scenarios
  )
  finite$RouteOrder <- match(finite$RouteId, mfrmr_gcl_p1e_routes)
  finite$PathOrder <- match(finite$T, mfrmr_gcl_p1e_t_ladder)
  finite <- finite[order(
    finite$ScenarioOrder, finite$RouteOrder, finite$PathOrder
  ), , drop = FALSE]
  rownames(finite) <- NULL
  finite$OptimizationQuadrature <- 121L
  finite$SelectionAuthorized <- FALSE
  finite$ConfirmationAuthorized <- FALSE
  limit <- expand.grid(
    ScenarioId = mfrmr_gcl_p1e_scenarios,
    RouteId = mfrmr_gcl_p1e_routes,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  limit$ScenarioOrder <- match(limit$ScenarioId, mfrmr_gcl_p1e_scenarios)
  limit$RouteOrder <- match(limit$RouteId, mfrmr_gcl_p1e_routes)
  limit <- limit[order(limit$ScenarioOrder, limit$RouteOrder), , drop = FALSE]
  rownames(limit) <- NULL
  limit$OptimizationQuadrature <- 121L
  limit$SelectionAuthorized <- FALSE
  limit$ConfirmationAuthorized <- FALSE
  list(
    finite = finite,
    limit = limit,
    transformation = "exact_affine_finite_t_coordinate_scaling",
    reduced_limit = "direct_target_random_non_target_deterministic",
    global_joint_boundary_profile_certified = FALSE,
    selection_authorized = FALSE,
    confirmation_authorized = FALSE
  )
}

mfrmr_gcl_p1e_rate_contract <- function(n_criteria = 4L) {
  n_criteria <- as.integer(n_criteria)[1L]
  mfrmr_gcl_p1e_assert(
    is.finite(n_criteria) && n_criteria >= 2L,
    "P1e requires at least two criteria."
  )
  data.frame(
    Coordinate = c(
      "population_sd", "target_slope", "other_slope",
      "target_location", "rater", "target_steps",
      "other_location", "other_steps"
    ),
    LogRatePerT = c(
      -1, 1, -1 / (n_criteria - 1),
      -1, -1, -1,
      1 / (n_criteria - 1), 1 / (n_criteria - 1)
    ),
    FiniteTransformedCoordinate = c(
      "sigma0", "target_slope0", "other_slope0",
      "target_location_over_epsilon", "rater_over_epsilon",
      "target_steps_over_epsilon", "rho_times_other_location",
      "rho_times_other_steps"
    ),
    TargetRandomTermRetained = c(
      TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE
    ),
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gcl_p1e_fixture_contract <- function(context, target_index) {
  config <- context$config
  sizes <- context$sizes
  facets <- as.character(config$facet_names)
  rater_levels <- as.character(config$facet_levels[["Rater"]])
  criterion_levels <- as.character(config$facet_levels[["Criterion"]])
  target_index <- as.integer(target_index)[1L]
  checks <- c(
    identical(config$model, "GPCM"),
    identical(config$method, "MML"),
    identical(facets, c("Rater", "Criterion")),
    identical(as.character(config$step_facet), "Criterion"),
    identical(as.character(config$slope_facet), "Criterion"),
    identical(as.numeric(config$facet_signs[c("Rater", "Criterion")]),
              c(-1, -1)),
    length(config$interaction_specs %||% list()) == 0L,
    length(rater_levels) == 5L,
    length(criterion_levels) == 4L,
    sizes$Rater == 4L,
    sizes$Criterion == 3L,
    sizes$steps == 12L,
    sizes$log_slopes == 3L,
    sizes$beta == 1L,
    sizes$log_sigma2 == 1L,
    target_index >= 1L && target_index <= length(criterion_levels),
    is.matrix(config$population_spec$design_matrix),
    ncol(config$population_spec$design_matrix) == 1L,
    all(config$population_spec$design_matrix[, 1L] == 1)
  )
  data.frame(
    Model = config$model,
    Method = config$method,
    RaterLevels = length(rater_levels),
    CriterionLevels = length(criterion_levels),
    Categories = config$n_cat,
    TargetIndex = target_index,
    TargetLevel = criterion_levels[target_index],
    InterceptOnlyPopulation = is.matrix(
      config$population_spec$design_matrix
    ) && ncol(config$population_spec$design_matrix) == 1L &&
      all(config$population_spec$design_matrix[, 1L] == 1),
    ExactFixtureContract = all(checks),
    GeneralTransportAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gcl_p1e_layout <- function(context) {
  n_rater <- length(context$config$facet_levels[["Rater"]])
  n_criterion <- length(context$config$facet_levels[["Criterion"]])
  step_free_per_criterion <- context$sizes$steps / n_criterion
  position <- 1L
  allocate <- function(n) {
    out <- seq.int(position, length.out = n)
    position <<- position + n
    out
  }
  list(
    rater = allocate(n_rater - 1L),
    location = allocate(n_criterion),
    steps = allocate(context$sizes$steps),
    n_rater = n_rater,
    n_criterion = n_criterion,
    step_free_per_criterion = step_free_per_criterion,
    dimension = position - 1L
  )
}

mfrmr_gcl_p1e_transform <- function(
    context,
    anchor_par,
    target_index,
    t) {
  fixture <- mfrmr_gcl_p1e_fixture_contract(context, target_index)
  mfrmr_gcl_p1e_assert(
    isTRUE(fixture$ExactFixtureContract),
    "P1e coordinate transform is restricted to the declared intercept-only Rater/Criteria fixture."
  )
  layout <- mfrmr_gcl_p1e_layout(context)
  epsilon <- exp(-as.numeric(t)[1L])
  rho <- exp(-as.numeric(t)[1L] / (layout$n_criterion - 1L))
  fixed <- mfrmr_gjs_p1d_fixed_path(
    context, anchor_par, target_index, t
  )
  slices <- context$slices

  embed <- function(y) {
    y <- as.numeric(y)
    mfrmr_gcl_p1e_assert(
      length(y) == layout$dimension && all(is.finite(y)),
      "P1e transformed vector has invalid dimension or values."
    )
    out <- fixed$par
    out[slices$Rater] <- epsilon * y[layout$rater]

    scaled_location <- y[layout$location]
    raw_location <- scaled_location / rho
    raw_location[target_index] <- epsilon * scaled_location[target_index]
    beta <- mean(raw_location)
    criterion <- beta - raw_location
    out[slices$Criterion] <- criterion[seq_along(slices$Criterion)]
    out[slices$beta] <- beta

    scaled_steps <- matrix(
      y[layout$steps],
      nrow = layout$n_criterion,
      byrow = TRUE
    )
    raw_steps <- scaled_steps / rho
    raw_steps[target_index, ] <- epsilon * scaled_steps[target_index, ]
    out[slices$steps] <- as.numeric(t(raw_steps))
    out[fixed$fixed_index] <- fixed$fixed_value
    out
  }

  inverse <- function(par) {
    par <- as.numeric(par)
    mfrmr_gcl_p1e_assert(
      length(par) == nrow(context$coordinates) && all(is.finite(par)),
      "P1e inverse transform requires one finite raw vector."
    )
    params <- mfrmr_gss_get("expand_params")(
      par, context$sizes, context$config
    )
    out <- numeric(layout$dimension)
    out[layout$rater] <- par[slices$Rater] / epsilon
    raw_location <- as.numeric(params$population$coefficients[1L]) -
      as.numeric(params$facets[["Criterion"]])
    scaled_location <- rho * raw_location
    scaled_location[target_index] <- raw_location[target_index] / epsilon
    out[layout$location] <- scaled_location
    raw_steps <- matrix(
      par[slices$steps],
      nrow = layout$n_criterion,
      byrow = TRUE
    )
    scaled_steps <- rho * raw_steps
    scaled_steps[target_index, ] <- raw_steps[target_index, ] / epsilon
    out[layout$steps] <- as.numeric(t(scaled_steps))
    out
  }

  zero <- embed(rep(0, layout$dimension))
  jacobian <- vapply(seq_len(layout$dimension), function(index) {
    basis <- numeric(layout$dimension)
    basis[index] <- 1
    embed(basis) - zero
  }, numeric(length(zero)))
  mfrmr_gcl_p1e_assert(
    qr(jacobian)$rank == layout$dimension,
    "P1e finite-t coordinate Jacobian is rank deficient."
  )
  anchor_params <- mfrmr_gss_get("expand_params")(
    anchor_par, context$sizes, context$config
  )
  list(
    context = context,
    fixture = fixture,
    layout = layout,
    target_index = as.integer(target_index),
    t = as.numeric(t),
    epsilon = epsilon,
    rho = rho,
    fixed = fixed,
    embed = embed,
    inverse = inverse,
    jacobian = jacobian,
    anchor_slopes = as.numeric(anchor_params$slopes),
    anchor_sigma = sqrt(as.numeric(anchor_params$population$sigma2)),
    TransformedDimension = layout$dimension,
    RawDimension = nrow(context$coordinates),
    JacobianRank = qr(jacobian)$rank,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE
  )
}

mfrmr_gcl_p1e_softmax <- function(log_num) {
  row_max <- log_num[cbind(
    seq_len(nrow(log_num)), max.col(log_num, ties.method = "first")
  )]
  centered <- log_num - row_max
  denom <- rowSums(exp(centered))
  list(
    probs = exp(centered) / denom,
    log_denom = row_max + log(denom)
  )
}

mfrmr_gcl_p1e_limit_bundle <- function(
    y,
    transform,
    context,
    include_gradient = TRUE) {
  y <- as.numeric(y)
  layout <- transform$layout
  target <- transform$target_index
  idx <- context$idx
  n <- length(idx$score_k)
  n_nodes <- length(context$quad$nodes)
  k_values <- 0:(context$config$n_cat - 1L)
  observed_index <- cbind(seq_len(n), idx$score_k + 1L)
  rater <- mfrmr_gss_get("expand_facet")(
    y[layout$rater], layout$n_rater
  )
  location <- y[layout$location]
  step_free <- matrix(
    y[layout$steps], nrow = layout$n_criterion, byrow = TRUE
  )
  step_matrix <- t(vapply(seq_len(layout$n_criterion), function(index) {
    mfrmr_gss_get("expand_sum_zero_vector")(
      step_free[index, ], context$config$n_cat - 1L
    )
  }, numeric(context$config$n_cat - 1L)))
  step_cumulative <- t(apply(
    step_matrix, 1L, function(value) c(0, cumsum(value))
  ))
  criterion <- as.integer(idx$slope_idx)
  rater_index <- as.integer(idx$facets[["Rater"]])
  slopes <- transform$anchor_slopes
  log_probability <- matrix(0, nrow = n, ncol = n_nodes)
  probability <- vector("list", n_nodes)
  for (q in seq_len(n_nodes)) {
    eta <- location[criterion]
    target_obs <- criterion == target
    eta[target_obs] <- location[target] - rater[rater_index[target_obs]] +
      transform$anchor_sigma * context$quad$nodes[q]
    linear <- outer(eta, k_values) -
      step_cumulative[criterion, , drop = FALSE]
    log_num <- linear * matrix(
      slopes[criterion], nrow = n, ncol = length(k_values)
    )
    softmax <- mfrmr_gcl_p1e_softmax(log_num)
    lp <- log_num[observed_index] - softmax$log_denom
    if (!is.null(idx$weight)) lp <- lp * idx$weight
    log_probability[, q] <- lp
    probability[[q]] <- softmax$probs
  }
  ll_by_person <- rowsum(
    log_probability, idx$person, reorder = FALSE
  )
  person_ids <- as.integer(rownames(ll_by_person))
  log_weights <- log(as.numeric(context$quad$weights))
  log_joint <- sweep(ll_by_person, 2L, log_weights, "+")
  row_max <- apply(log_joint, 1L, max)
  log_marginal <- row_max + log(rowSums(exp(log_joint - row_max)))
  objective <- -sum(log_marginal)
  if (!isTRUE(include_gradient)) {
    return(list(objective = objective))
  }
  posterior <- exp(log_joint - log_marginal)
  person_to_row <- integer(context$config$n_person)
  person_to_row[person_ids] <- seq_along(person_ids)
  observation_person_row <- person_to_row[idx$person]
  observation_posterior <- posterior[observation_person_row, , drop = FALSE]

  score_rater <- numeric(layout$n_rater)
  score_location <- numeric(layout$n_criterion)
  score_step <- matrix(
    0, nrow = layout$n_criterion,
    ncol = context$config$n_cat - 1L
  )
  indicator_geq <- outer(
    idx$score_k, seq_len(context$config$n_cat - 1L), ">="
  ) * 1
  for (q in seq_len(n_nodes)) {
    probs <- probability[[q]]
    expected <- as.vector(probs %*% k_values)
    residual <- slopes[criterion] * (idx$score_k - expected)
    posterior_residual <- residual * observation_posterior[, q]
    if (!is.null(idx$weight)) posterior_residual <-
      posterior_residual * idx$weight
    location_sum <- rowsum(
      matrix(posterior_residual, ncol = 1L), criterion,
      reorder = FALSE
    )
    location_ids <- as.integer(rownames(location_sum))
    score_location[location_ids] <- score_location[location_ids] +
      as.vector(location_sum)
    target_obs <- criterion == target
    rater_sum <- rowsum(
      matrix(-posterior_residual[target_obs], ncol = 1L),
      rater_index[target_obs], reorder = FALSE
    )
    rater_ids <- as.integer(rownames(rater_sum))
    score_rater[rater_ids] <- score_rater[rater_ids] +
      as.vector(rater_sum)

    p_geq <- mfrmr_gss_get("compute_P_geq")(probs)
    step_score <- (p_geq - indicator_geq) *
      slopes[criterion] * observation_posterior[, q]
    if (!is.null(idx$weight)) step_score <- step_score * idx$weight
    step_sum <- rowsum(step_score, criterion, reorder = FALSE)
    step_ids <- as.integer(rownames(step_sum))
    score_step[step_ids, ] <- score_step[step_ids, , drop = FALSE] +
      step_sum
  }
  gradient <- c(
    -mfrmr_gss_get("project_sum_zero_gradient")(score_rater),
    -score_location,
    -mfrmr_gss_get("project_step_matrix_gradient")(score_step)
  )
  mfrmr_gcl_p1e_assert(
    length(gradient) == layout$dimension,
    "P1e reduced-limit gradient dimension is inconsistent."
  )
  list(
    objective = objective,
    gradient = gradient,
    log_probability = log_probability,
    posterior = posterior
  )
}

mfrmr_gcl_p1e_optimize <- function(
    start,
    fn,
    gr,
    maxit,
    reltol) {
  start <- as.numeric(start)
  warnings <- character(0)
  run_stage <- function(value, method, stage_reltol, index, label) {
    control <- mfrmr_gss_get("build_mfrm_optim_control")(
      method, maxit = as.integer(maxit), reltol = as.numeric(stage_reltol)
    )
    stage_error <- ""
    started <- proc.time()[["elapsed"]]
    opt <- tryCatch(
      withCallingHandlers(
        stats::optim(
          par = value, fn = fn, gr = gr,
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
          ConvergenceReason = "coordinate_scaled_fit_failed",
          ConvergenceSeverity = "fail",
          GradientReviewTolerance = max(1e-4, 10 * stage_reltol),
          TerminalGradientSupNorm = NA_real_
        ),
        elapsed = elapsed, error = stage_error
      ))
    }
    gradient <- tryCatch(
      suppressWarnings(as.numeric(gr(opt$par))),
      error = function(condition) rep(NA_real_, length(opt$par))
    )
    list(
      index = index, label = label, method = method,
      reltol = stage_reltol, control = control, opt = opt,
      diagnostics = mfrmr_gss_get("build_optimizer_diagnostics")(
        opt = opt,
        gradient = gradient,
        reltol = as.numeric(stage_reltol),
        maxit = as.integer(maxit),
        optimizer_method = method,
        convergence_basis = "optimizer_gradient"
      ),
      elapsed = elapsed, error = stage_error
    )
  }
  stages <- list(run_stage(start, "L-BFGS-B", reltol, 1L, "initial"))
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
          )) selected <- candidate
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
            )) selected <- candidate
        if (identical(selected$diagnostics$ConvergenceSeverity, "pass")) break
      }
    }
  }
  returned <- !is.null(selected$opt) &&
    length(selected$opt$par) == length(start) &&
    all(is.finite(selected$opt$par))
  list(
    returned = returned,
    par = if (returned) as.numeric(selected$opt$par) else {
      rep(NA_real_, length(start))
    },
    selected = selected,
    stages = stages,
    warnings = unique(warnings),
    errors = unique(vapply(stages, `[[`, character(1L), "error")),
    elapsed = sum(vapply(stages, `[[`, numeric(1L), "elapsed"))
  )
}

mfrmr_gcl_p1e_finite_candidate <- function(
    scenario_id,
    route_id,
    t,
    transform,
    contexts,
    source_par,
    maxit,
    reltol) {
  start <- transform$inverse(source_par)
  roundtrip <- transform$embed(start)
  fixed_index <- transform$fixed$fixed_index
  nuisance_index <- setdiff(seq_along(roundtrip), fixed_index)
  roundtrip_difference <- max(abs(
    roundtrip[nuisance_index] - source_par[nuisance_index]
  ))
  fn <- function(y) {
    suppressWarnings(as.numeric(
      contexts[["121"]]$fn(transform$embed(y))
    )[1L])
  }
  gr <- function(y) {
    raw <- transform$embed(y)
    as.numeric(crossprod(
      transform$jacobian,
      as.numeric(contexts[["121"]]$gr(raw))
    ))
  }
  optimized <- mfrmr_gcl_p1e_optimize(start, fn, gr, maxit, reltol)
  returned <- isTRUE(optimized$returned)
  y <- optimized$par
  raw <- if (returned) transform$embed(y) else {
    rep(NA_real_, transform$RawDimension)
  }
  objective <- NA_real_
  transformed_gradient <- numeric(0)
  numeric_gradient <- numeric(0)
  raw_gradient <- numeric(0)
  finite_objectives <- setNames(rep(NA_real_, 3L), names(contexts))
  limit_objectives <- setNames(rep(NA_real_, 3L), names(contexts))
  if (returned) {
    objective <- fn(y)
    transformed_gradient <- gr(y)
    numeric_gradient <- tryCatch(
      mfrmr_num_central_gradient(fn, y, mfrmr_gcl_p1e_derivative_step),
      error = function(condition) rep(NA_real_, length(y))
    )
    raw_gradient <- tryCatch(
      as.numeric(contexts[["121"]]$gr(raw))[nuisance_index],
      error = function(condition) rep(NA_real_, length(nuisance_index))
    )
    finite_objectives <- vapply(contexts, function(context) {
      suppressWarnings(as.numeric(context$fn(raw))[1L])
    }, numeric(1L))
    limit_objectives <- vapply(contexts, function(context) {
      mfrmr_gcl_p1e_limit_bundle(
        y, transform, context, include_gradient = FALSE
      )$objective
    }, numeric(1L))
  }
  diagnostics <- optimized$selected$diagnostics %||% list()
  severity <- as.character(
    diagnostics$ConvergenceSeverity %||% "fail"
  )[1L]
  tolerance <- as.numeric(
    diagnostics$GradientReviewTolerance %||% max(1e-4, 10 * reltol)
  )[1L]
  complete <- returned && is.finite(objective) &&
    length(transformed_gradient) == transform$TransformedDimension &&
    all(is.finite(c(
      transformed_gradient, numeric_gradient, raw_gradient,
      finite_objectives, limit_objectives
    )))
  eligible <- complete && identical(severity, "pass")
  row <- data.frame(
    ScenarioId = scenario_id,
    RouteId = route_id,
    T = t,
    Epsilon = transform$epsilon,
    Rho = transform$rho,
    RawDimension = transform$RawDimension,
    TransformedDimension = transform$TransformedDimension,
    JacobianRank = transform$JacobianRank,
    RoundtripNuisanceMaxAbsDifference = roundtrip_difference,
    FitReturned = returned,
    ObjectiveQ121 = objective,
    ObjectiveQ61 = as.numeric(finite_objectives[["61"]]),
    ObjectiveQ91 = as.numeric(finite_objectives[["91"]]),
    FiniteQuadratureObjectiveRange = if (
      all(is.finite(finite_objectives))
    ) diff(range(finite_objectives)) else NA_real_,
    LimitObjectiveQ121AtFiniteEstimate =
      as.numeric(limit_objectives[["121"]]),
    LimitQuadratureObjectiveRangeAtFiniteEstimate = if (
      all(is.finite(limit_objectives))
    ) diff(range(limit_objectives)) else NA_real_,
    FiniteMinusLimitObjectiveQ121 = objective -
      as.numeric(limit_objectives[["121"]]),
    TransformedGradientMaxAbs = if (
      length(transformed_gradient) > 0L &&
        all(is.finite(transformed_gradient))
    ) max(abs(transformed_gradient)) else NA_real_,
    RawNuisanceGradientMaxAbs = if (
      length(raw_gradient) > 0L && all(is.finite(raw_gradient))
    ) max(abs(raw_gradient)) else NA_real_,
    AnalyticNumericTransformedGradientMaxAbsDifference = if (
      length(transformed_gradient) == length(numeric_gradient) &&
        length(transformed_gradient) > 0L &&
        all(is.finite(c(transformed_gradient, numeric_gradient)))
    ) max(abs(transformed_gradient - numeric_gradient)) else NA_real_,
    ConvergenceCode = as.integer(
      diagnostics$ConvergenceCode %||% NA_integer_
    )[1L],
    ConvergenceReason = as.character(
      diagnostics$ConvergenceReason %||% "not_returned"
    )[1L],
    TransformedConvergenceSeverity = severity,
    TransformedStationarityPass = identical(severity, "pass"),
    RawStationarityPass = complete &&
      max(abs(raw_gradient)) <= tolerance,
    CoordinateScaledCandidateEligible = eligible,
    CoordinateScaledEligibilityReason = if (eligible) {
      "exact_transform_and_transformed_stationarity_complete"
    } else if (complete) {
      "exact_transform_complete_but_transformed_stationarity_not_passed"
    } else "coordinate_scaled_fit_or_derivative_incomplete",
    GlobalJointBoundaryProfileCertified = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    ElapsedSeconds = optimized$elapsed,
    WarningCount = length(optimized$warnings),
    WarningText = paste(optimized$warnings, collapse = " | "),
    ErrorText = paste(
      optimized$errors[nzchar(optimized$errors)], collapse = " | "
    ),
    StartVectorSHA256 = mfrmr_gss_hash_vector(start),
    ReturnedVectorSHA256 = if (returned) {
      mfrmr_gss_hash_vector(y)
    } else NA_character_,
    stringsAsFactors = FALSE
  )
  list(row = row, y = y, raw = raw, optimized = optimized)
}

mfrmr_gcl_p1e_limit_candidate <- function(
    scenario_id,
    route_id,
    transform,
    contexts,
    start,
    interior_objective,
    maxit,
    reltol) {
  fn <- function(y) mfrmr_gcl_p1e_limit_bundle(
    y, transform, contexts[["121"]], include_gradient = FALSE
  )$objective
  gr <- function(y) mfrmr_gcl_p1e_limit_bundle(
    y, transform, contexts[["121"]], include_gradient = TRUE
  )$gradient
  optimized <- mfrmr_gcl_p1e_optimize(start, fn, gr, maxit, reltol)
  returned <- isTRUE(optimized$returned)
  y <- optimized$par
  objective <- NA_real_
  gradient <- numeric(0)
  numeric_gradient <- numeric(0)
  objectives <- setNames(rep(NA_real_, 3L), names(contexts))
  if (returned) {
    objective <- fn(y)
    gradient <- gr(y)
    numeric_gradient <- tryCatch(
      mfrmr_num_central_gradient(fn, y, mfrmr_gcl_p1e_derivative_step),
      error = function(condition) rep(NA_real_, length(y))
    )
    objectives <- vapply(contexts, function(context) {
      mfrmr_gcl_p1e_limit_bundle(
        y, transform, context, include_gradient = FALSE
      )$objective
    }, numeric(1L))
  }
  diagnostics <- optimized$selected$diagnostics %||% list()
  severity <- as.character(
    diagnostics$ConvergenceSeverity %||% "fail"
  )[1L]
  complete <- returned && is.finite(objective) &&
    length(gradient) == transform$TransformedDimension &&
    all(is.finite(c(gradient, numeric_gradient, objectives)))
  eligible <- complete && identical(severity, "pass")
  row <- data.frame(
    ScenarioId = scenario_id,
    RouteId = route_id,
    TargetSlopeIndex = transform$target_index,
    ReducedLimit = "target_random_non_target_deterministic",
    FitReturned = returned,
    LimitObjectiveQ121 = objective,
    LimitObjectiveQ61 = as.numeric(objectives[["61"]]),
    LimitObjectiveQ91 = as.numeric(objectives[["91"]]),
    LimitQuadratureObjectiveRange = if (all(is.finite(objectives))) {
      diff(range(objectives))
    } else NA_real_,
    InteriorObjectiveQ121 = as.numeric(interior_objective),
    LimitMinusInteriorObjective = objective - as.numeric(interior_objective),
    LimitGradientMaxAbs = if (
      length(gradient) > 0L && all(is.finite(gradient))
    ) max(abs(gradient)) else NA_real_,
    AnalyticNumericLimitGradientMaxAbsDifference = if (
      length(gradient) == length(numeric_gradient) && length(gradient) > 0L &&
        all(is.finite(c(gradient, numeric_gradient)))
    ) max(abs(gradient - numeric_gradient)) else NA_real_,
    ConvergenceCode = as.integer(
      diagnostics$ConvergenceCode %||% NA_integer_
    )[1L],
    ConvergenceReason = as.character(
      diagnostics$ConvergenceReason %||% "not_returned"
    )[1L],
    ConvergenceSeverity = severity,
    ReducedLimitCandidateEligible = eligible,
    ReducedLimitEligibilityReason = if (eligible) {
      "direct_limit_likelihood_stationarity_and_derivative_complete"
    } else if (complete) {
      "direct_limit_complete_but_stationarity_not_passed"
    } else "direct_limit_fit_or_derivative_incomplete",
    GlobalJointBoundaryProfileCertified = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    ElapsedSeconds = optimized$elapsed,
    WarningCount = length(optimized$warnings),
    WarningText = paste(optimized$warnings, collapse = " | "),
    ErrorText = paste(
      optimized$errors[nzchar(optimized$errors)], collapse = " | "
    ),
    StartVectorSHA256 = mfrmr_gss_hash_vector(start),
    ReturnedVectorSHA256 = if (returned) {
      mfrmr_gss_hash_vector(y)
    } else NA_character_,
    stringsAsFactors = FALSE
  )
  list(row = row, y = y, optimized = optimized)
}

mfrmr_gcl_p1e_pairwise <- function(rows, objective_name, eligible_name) {
  groups <- split(rows, rows$ScenarioId)
  out <- lapply(groups, function(value) {
    forward <- value[value$RouteId == "interior_forward", , drop = FALSE]
    reverse <- value[value$RouteId == "boundary_reverse", , drop = FALSE]
    complete <- nrow(forward) == 1L && nrow(reverse) == 1L
    data.frame(
      ScenarioId = value$ScenarioId[1L],
      BothRoutesPresent = complete,
      BothRoutesEligible = complete && isTRUE(forward[[eligible_name]]) &&
        isTRUE(reverse[[eligible_name]]),
      ObjectiveAbsDifference = if (complete) abs(
        forward[[objective_name]] - reverse[[objective_name]]
      ) else NA_real_,
      RouteAgreementToleranceStatus = "not_frozen_calibration_only",
      GlobalJointBoundaryProfileCertified = FALSE,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  result <- do.call(rbind, out)
  rownames(result) <- NULL
  result
}

mfrmr_gcl_p1e_decision <- function(
    scenario_id,
    finite_rows,
    limit_rows,
    limit_pairwise) {
  finite <- finite_rows[finite_rows$ScenarioId == scenario_id, , drop = FALSE]
  limit <- limit_rows[limit_rows$ScenarioId == scenario_id, , drop = FALSE]
  pair <- limit_pairwise[
    limit_pairwise$ScenarioId == scenario_id, , drop = FALSE
  ]
  mfrmr_gcl_p1e_assert(
    nrow(finite) == 8L && nrow(limit) == 2L && nrow(pair) == 1L,
    "P1e decision requires all finite and direct-limit routes."
  )
  finite_complete <- all(finite$CoordinateScaledCandidateEligible)
  limits_complete <- all(limit$ReducedLimitCandidateEligible)
  both_above <- limits_complete && all(limit$LimitMinusInteriorObjective > 0)
  status <- if (finite_complete && limits_complete && both_above) {
    "declared_c4_ray_two_route_stationary_limit_above_interior"
  } else if (limits_complete) {
    "declared_c4_ray_stationary_limit_observed_selection_ineligible"
  } else {
    "coordinate_scaled_joint_limit_inconclusive"
  }
  data.frame(
    ScenarioId = scenario_id,
    AllFiniteTransformedPointsEligible = finite_complete,
    BothReducedLimitRoutesEligible = limits_complete,
    BothReducedLimitObjectivesAboveInterior = both_above,
    ReducedLimitRouteObjectiveAbsDifference = pair$ObjectiveAbsDifference,
    CoordinateScaledJointLimitStatus = status,
    DeclaredC4RayLocallyAdjudicated = finite_complete && limits_complete,
    OtherSlopeRateRaysEvaluated = FALSE,
    GlobalJointBoundaryProfileCertified = FALSE,
    UpperVarianceJointPathStatus = "not_evaluated",
    SolutionToleranceStatus = "not_frozen",
    SourceSolutionDecision =
      "blocked_other_joint_rays_upper_boundary_and_selection_rule_unresolved",
    HessianAuthorized = FALSE,
    DFFFitRankAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gcl_p1e_signature <- function(decision_row) {
  status <- as.character(decision_row$CoordinateScaledJointLimitStatus)
  data.frame(
    Metric = c(
      "finite_coordinate_transform", "direct_reduced_limit",
      "declared_c4_ray", "other_slope_rate_rays",
      "global_joint_boundary_profile", "upper_joint_variance_boundary",
      "source_solution_selection", "hessian", "dff_fit_rank", "overall"
    ),
    State = c(
      if (isTRUE(decision_row$AllFiniteTransformedPointsEligible)) {
        "stationary_exact_finite_transform"
      } else "blocked",
      if (isTRUE(decision_row$BothReducedLimitRoutesEligible)) {
        "stationary_two_route_direct_limit"
      } else "blocked",
      status,
      "not_evaluated",
      "not_certified",
      "not_evaluated",
      "blocked",
      "not_evaluated",
      "not_evaluated",
      "review"
    ),
    Eligibility = c(
      "declared_fixture_and_ray_only",
      "declared_fixture_and_ray_only",
      "local_boundary_calibration_only",
      rep("not_selection_eligible", 7L)
    ),
    Reason = c(
      "affine_roundtrip_and_chain_rule_gradient_checked",
      "target_random_non_target_deterministic_limit_optimized_directly",
      "one_observed_symmetric_compensation_ray_only",
      "asymmetric_and_curved_slope_rate_paths_remain_open",
      "one_ray_does_not_profile_the_joint_boundary",
      "large_variance_joint_path_remains_separate",
      "global_boundaries_and_selection_rule_remain_open",
      "source_solution_not_selected",
      "source_solution_not_selected",
      "p1e_coordinate_scaled_joint_limit_calibration_only"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_run_gpcm_coordinate_scaled_joint_limit_p1e <- function(
    maxit = 800L,
    reltol = 1e-12,
    progress = FALSE,
    p1d = NULL) {
  mfrmr_gcl_p1e_require_sources()
  maxit <- as.integer(maxit)[1L]
  reltol <- as.numeric(reltol)[1L]
  mfrmr_gcl_p1e_assert(
    is.finite(maxit) && maxit > 0L && is.finite(reltol) && reltol > 0,
    "P1e requires finite positive optimization controls."
  )
  plan <- mfrmr_gcl_p1e_plan()
  rate_contract <- mfrmr_gcl_p1e_rate_contract()
  if (is.null(p1d)) {
    p1d <- mfrmr_run_gpcm_zero_variance_log_slope_path_p1d(
      maxit = 600L, reltol = 1e-10, progress = progress
    )
  }
  mfrmr_gcl_p1e_assert(
    is.list(p1d) && identical(p1d$contract, mfrmr_gcl_p1e_dependency_contract),
    "P1e requires one complete P1d dependency result."
  )
  fixture_rows <- list()
  finite_objects <- list()
  finite_rows <- list()
  limit_objects <- list()
  limit_rows <- list()
  row_index <- limit_index <- fixture_index <- 1L
  for (scenario_id in mfrmr_gcl_p1e_scenarios) {
    source <- p1d$p1c$p0b$scenario_results[[scenario_id]]
    contexts <- lapply(mfrmr_gcl_p1e_quadrature, function(q) {
      mfrmr_gqi_p1b_context(source$fit, q)
    })
    names(contexts) <- as.character(mfrmr_gcl_p1e_quadrature)
    geometry <- p1d$geometry[
      p1d$geometry$ScenarioId == scenario_id, , drop = FALSE
    ]
    target_index <- as.integer(geometry$TargetSlopeIndex)
    anchor <- p1d$p1c$interior_candidate_objects[[scenario_id]]$opt$par
    fixture <- mfrmr_gcl_p1e_fixture_contract(
      contexts[["121"]], target_index
    )
    fixture$ScenarioId <- scenario_id
    fixture_rows[[fixture_index]] <- fixture
    fixture_index <- fixture_index + 1L
    for (route_id in mfrmr_gcl_p1e_routes) {
      p1d_route <- p1d$route_objects[[paste(
        scenario_id, route_id, sep = "::"
      )]]
      previous <- NULL
      for (t in mfrmr_gcl_p1e_t_ladder) {
        transform <- mfrmr_gcl_p1e_transform(
          contexts[["121"]], anchor, target_index, t
        )
        source_point <- p1d_route$objects[[sprintf("t_%02d", t)]]
        source_par <- if (!is.null(previous)) previous$raw else source_point$par
        if (isTRUE(progress)) message(
          "Coordinate-scaled P1e: ", scenario_id, " / ", route_id,
          " / t=", t
        )
        candidate <- mfrmr_gcl_p1e_finite_candidate(
          scenario_id = scenario_id,
          route_id = route_id,
          t = t,
          transform = transform,
          contexts = contexts,
          source_par = source_par,
          maxit = maxit,
          reltol = reltol
        )
        key <- paste(scenario_id, route_id, t, sep = "::")
        finite_objects[[key]] <- candidate
        finite_rows[[row_index]] <- candidate$row
        row_index <- row_index + 1L
        if (isTRUE(candidate$row$FitReturned)) previous <- candidate
      }
      terminal_key <- paste(
        scenario_id, route_id, max(mfrmr_gcl_p1e_t_ladder), sep = "::"
      )
      terminal <- finite_objects[[terminal_key]]
      limit_transform <- mfrmr_gcl_p1e_transform(
        contexts[["121"]], anchor, target_index,
        max(mfrmr_gcl_p1e_t_ladder)
      )
      interior <- p1d$p1c$interior_candidates[
        p1d$p1c$interior_candidates$ScenarioId == scenario_id,
        , drop = FALSE
      ]
      limit_candidate <- mfrmr_gcl_p1e_limit_candidate(
        scenario_id = scenario_id,
        route_id = route_id,
        transform = limit_transform,
        contexts = contexts,
        start = terminal$y,
        interior_objective = interior$CommonDenseObjective,
        maxit = maxit,
        reltol = reltol
      )
      limit_objects[[paste(scenario_id, route_id, sep = "::")]] <-
        limit_candidate
      limit_rows[[limit_index]] <- limit_candidate$row
      limit_index <- limit_index + 1L
    }
  }
  fixture_table <- do.call(rbind, fixture_rows)
  rownames(fixture_table) <- NULL
  finite_table <- do.call(rbind, finite_rows)
  rownames(finite_table) <- NULL
  limit_table <- do.call(rbind, limit_rows)
  rownames(limit_table) <- NULL
  limit_pairwise <- mfrmr_gcl_p1e_pairwise(
    limit_table, "LimitObjectiveQ121", "ReducedLimitCandidateEligible"
  )
  decisions <- do.call(rbind, lapply(
    mfrmr_gcl_p1e_scenarios,
    mfrmr_gcl_p1e_decision,
    finite_rows = finite_table,
    limit_rows = limit_table,
    limit_pairwise = limit_pairwise
  ))
  rownames(decisions) <- NULL
  signatures <- setNames(lapply(
    mfrmr_gcl_p1e_scenarios,
    function(scenario_id) mfrmr_gcl_p1e_signature(decisions[
      decisions$ScenarioId == scenario_id, , drop = FALSE
    ])
  ), mfrmr_gcl_p1e_scenarios)
  pairs <- list(
    exact = c("EXT5-P-HI", "EXT5-P-LO"),
    near = c("EXT5-P-NEAR-HI", "EXT5-P-NEAR-LO")
  )
  signature_comparisons <- do.call(rbind, lapply(names(pairs), function(id) {
    pair <- pairs[[id]]
    comparison <- mfrmr_gss_compare_signatures(
      signatures[[pair[1L]]], signatures[[pair[2L]]]
    )
    data.frame(
      Pair = id,
      HighScenarioId = pair[1L],
      LowScenarioId = pair[2L],
      comparison,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  }))
  structure(
    list(
      contract = mfrmr_gcl_p1e_contract,
      specification = mfrmr_gcl_p1e_specification,
      dependency_contract = mfrmr_gcl_p1e_dependency_contract,
      dependency_sha256 = mfrmr_gcl_p1e_dependency_sha256,
      plan = plan,
      rate_contract = rate_contract,
      fixture_contracts = fixture_table,
      finite_candidates = finite_table,
      finite_candidate_objects = finite_objects,
      reduced_limit_candidates = limit_table,
      reduced_limit_candidate_objects = limit_objects,
      reduced_limit_pairwise = limit_pairwise,
      decisions = decisions,
      decision_signatures = signatures,
      signature_comparisons = signature_comparisons,
      p1d = p1d,
      OtherSlopeRateRaysEvaluated = FALSE,
      GlobalJointBoundaryProfileCertified = FALSE,
      UpperVarianceJointPathStatus = "not_evaluated",
      SolutionToleranceStatus = "not_frozen",
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ),
    class = "mfrmr_gpcm_coordinate_scaled_joint_limit_p1e"
  )
}
