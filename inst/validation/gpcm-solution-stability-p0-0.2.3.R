# mfrmr 0.2.3 repository-only GPCM solution-stability P0 audit
#
# This runner executes a prespecified, deterministic multi-start panel for the
# fixed GPCM-MML numerical fixture. Every returned vector is reevaluated through
# one canonical objective/score evaluator and transformed to labelled expanded
# parameter coordinates. The runner deliberately does not select a production
# solution: boundary, Hessian, interval, DFF, fit, rank, and separation gates
# remain explicit P1--P3 dependencies.
#
# From the repository root:
#
#   pkgload::load_all(".")
#   source("inst/validation/numerical-stationarity-pilot-0.2.3.R")
#   source("inst/validation/gpcm-solution-stability-p0-0.2.3.R")
#   stability <- mfrmr_run_gpcm_solution_stability_p0()
#   stability$summary
#   stability$candidates
#   stability$pairwise

mfrmr_gss_specification <- "0.2.3-draft.1"
mfrmr_gss_contract <- "mfrmr_gpcm_solution_stability_p0_v1"
mfrmr_gss_dependency_contract <- "mfrmr_mml_canonical_score_audit_v1"
mfrmr_gss_start_ids <- c(
  "default",
  "retained_restart",
  "zero_null",
  "slope_low_high",
  "variance_low",
  "variance_high",
  "seeded_perturbation"
)
mfrmr_gss_seed <- 20260812L

mfrmr_gss_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gss_or <- function(value, fallback) {
  if (is.null(value) || length(value) == 0L) fallback else value
}

mfrmr_gss_namespace <- function() {
  mfrmr_gss_assert(
    exists("mfrmr_num_contract", inherits = TRUE) &&
      identical(
        get("mfrmr_num_contract", inherits = TRUE),
        mfrmr_gss_dependency_contract
      ),
    paste0(
      "Source numerical-stationarity-pilot-0.2.3.R before the GPCM ",
      "solution-stability P0 runner."
    )
  )
  namespace <- mfrmr_num_namespace()
  required <- c(
    "build_initial_param_vector", "build_param_slices", "expand_params",
    "mfrmr_mml_optimizer_parameter_map", "run_mfrm_direct_optimization",
    "with_preserved_rng_seed"
  )
  available <- vapply(
    required,
    exists,
    logical(1),
    envir = namespace,
    inherits = FALSE
  )
  mfrmr_gss_assert(
    all(available),
    paste0(
      "The loaded mfrmr namespace is missing required P0 internals: ",
      paste(required[!available], collapse = ", "), "."
    )
  )
  namespace
}

mfrmr_gss_get <- function(name) {
  get(name, envir = mfrmr_gss_namespace(), inherits = FALSE)
}

mfrmr_gss_hash_vector <- function(value) {
  mfrmr_gss_assert(
    requireNamespace("digest", quietly = TRUE),
    "The repository-only P0 runner requires the suggested `digest` package."
  )
  value <- as.numeric(value)
  mfrmr_gss_assert(
    length(value) > 0L && all(is.finite(value)),
    "Only non-empty finite vectors can be fingerprinted."
  )
  digest::digest(
    paste(sprintf("%.17g", value), collapse = "\n"),
    algo = "sha256",
    serialize = FALSE
  )
}

mfrmr_gss_context_fingerprint <- function(fixture, context) {
  digest::digest(
    list(
      fixture_sha256 = fixture$sha256,
      model = context$config$model,
      method = context$config$method,
      identification = context$config$gpcm_mml_identification,
      facet_names = context$config$facet_names,
      facet_levels = context$config$facet_levels,
      step_facet = context$config$step_facet,
      slope_facet = context$config$slope_facet,
      n_cat = context$config$n_cat,
      sizes = context$sizes,
      quadrature = list(
        nodes = as.numeric(context$quad$nodes),
        weights = as.numeric(context$quad$weights)
      )
    ),
    algo = "sha256",
    serialize = TRUE
  )
}

mfrmr_gss_build_registry <- function(fit, fixture, context, maxit, reltol) {
  slices <- context$slices
  default <- as.numeric(
    mfrmr_gss_get("build_initial_param_vector")(
      context$config,
      context$sizes
    )
  )
  retained <- as.numeric(fit$opt$par)
  zero <- rep(0, length(default))

  slope_low_high <- default
  slope_index <- slices$log_slopes
  mfrmr_gss_assert(
    length(slope_index) > 0L,
    "The declared P0 GPCM fixture must have free log-slope coordinates."
  )
  slope_direction <- seq(-0.75, 0.55, length.out = length(slope_index))
  if (length(slope_index) == 1L) slope_direction <- -0.55
  slope_low_high[slope_index] <- slope_direction

  variance_index <- slices$log_sigma2
  mfrmr_gss_assert(
    length(variance_index) == 1L,
    "The declared free-population MML fixture must have one log-variance coordinate."
  )
  variance_low <- default
  variance_low[variance_index] <- -2
  variance_high <- default
  variance_high[variance_index] <- 2

  preserve_seed <- mfrmr_gss_get("with_preserved_rng_seed")
  seeded_perturbation <- preserve_seed(
    mfrmr_gss_seed,
    default + stats::rnorm(length(default), mean = 0, sd = 0.15)
  )

  vectors <- list(
    default = default,
    retained_restart = retained,
    zero_null = zero,
    slope_low_high = slope_low_high,
    variance_low = variance_low,
    variance_high = variance_high,
    seeded_perturbation = seeded_perturbation
  )
  roles <- c(
    "package_default",
    "retained_solution_restart",
    "all_free_coordinates_zero",
    "declared_low_high_log_slope_dispersion",
    "declared_low_population_variance",
    "declared_high_population_variance",
    "fixed_seed_moderate_free_coordinate_perturbation"
  )
  free_dimension <- length(default)
  context_sha256 <- mfrmr_gss_context_fingerprint(fixture, context)
  registry <- data.frame(
    StartOrder = seq_along(mfrmr_gss_start_ids),
    StartId = mfrmr_gss_start_ids,
    StartRole = roles,
    Seed = c(NA_integer_, NA_integer_, NA_integer_, NA_integer_,
             NA_integer_, NA_integer_, mfrmr_gss_seed),
    FixtureId = fixture$fixture_id,
    FixtureSHA256 = fixture$sha256,
    ContextSHA256 = context_sha256,
    Model = "GPCM",
    Method = "MML",
    Identification = "free_population",
    QuadPoints = as.integer(length(context$quad$nodes)),
    Optimizer = "L-BFGS-B",
    Maxit = as.integer(maxit),
    Reltol = as.numeric(reltol),
    FreeDimensionDeclared = as.integer(free_dimension),
    StartVectorSHA256 = vapply(vectors, mfrmr_gss_hash_vector, character(1)),
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  registry$StartVector <- I(unname(vectors))
  mfrmr_gss_validate_registry(registry, context, fixture)
  registry
}

mfrmr_gss_validate_registry <- function(registry, context, fixture) {
  required <- c(
    "StartOrder", "StartId", "StartRole", "Seed", "FixtureId",
    "FixtureSHA256", "ContextSHA256", "Model", "Method",
    "Identification", "QuadPoints", "Optimizer", "Maxit", "Reltol",
    "FreeDimensionDeclared", "StartVectorSHA256", "SelectionAuthorized",
    "ConfirmationAuthorized", "StartVector"
  )
  mfrmr_gss_assert(
    is.data.frame(registry) && all(required %in% names(registry)),
    "The P0 start registry is missing required columns."
  )
  mfrmr_gss_assert(
    identical(as.character(registry$StartId), mfrmr_gss_start_ids) &&
      identical(as.integer(registry$StartOrder), seq_along(mfrmr_gss_start_ids)) &&
      !anyDuplicated(registry$StartId),
    "The P0 start registry must retain the exact prespecified IDs and order."
  )
  mfrmr_gss_assert(
    is.list(registry$StartVector) &&
      length(registry$StartVector) == length(mfrmr_gss_start_ids),
    "The P0 start registry must contain one vector per declared start."
  )
  expected_dimension <- sum(vapply(context$sizes, as.integer, integer(1)))
  vector_ok <- vapply(registry$StartVector, function(value) {
    length(value) == expected_dimension && all(is.finite(as.numeric(value)))
  }, logical(1))
  mfrmr_gss_assert(
    all(vector_ok) && all(registry$FreeDimensionDeclared == expected_dimension),
    "Every P0 starting vector must match the canonical optimizer dimension."
  )
  actual_hashes <- vapply(
    registry$StartVector,
    mfrmr_gss_hash_vector,
    character(1)
  )
  mfrmr_gss_assert(
    identical(as.character(registry$StartVectorSHA256), unname(actual_hashes)),
    "A P0 starting vector no longer matches its registered fingerprint."
  )
  expected_context <- mfrmr_gss_context_fingerprint(fixture, context)
  identity_ok <-
    registry$FixtureId == fixture$fixture_id &
    registry$FixtureSHA256 == fixture$sha256 &
    registry$ContextSHA256 == expected_context &
    registry$Model == "GPCM" &
    registry$Method == "MML" &
    registry$Identification == "free_population" &
    registry$QuadPoints == length(context$quad$nodes) &
    registry$Optimizer == "L-BFGS-B"
  mfrmr_gss_assert(
    all(identity_ok),
    "The P0 registry mixes fixtures, models, identification, quadrature, or optimizers."
  )
  mfrmr_gss_assert(
    all(!registry$SelectionAuthorized) &&
      all(!registry$ConfirmationAuthorized),
    "P0 start-registry rows cannot authorize selection or confirmation."
  )
  invisible(TRUE)
}

mfrmr_gss_semantic_vector <- function(context, par) {
  par <- as.numeric(par)
  mfrmr_gss_assert(
    length(par) == nrow(context$coordinates) && all(is.finite(par)),
    "Semantic expansion requires one complete finite free-coordinate vector."
  )
  mfrmr_gss_assert(
    length(context$config$interaction_specs) == 0L,
    "The P0 semantic contract is intentionally restricted to the no-interaction GPCM fixture."
  )
  params <- mfrmr_gss_get("expand_params")(
    par,
    context$sizes,
    context$config
  )
  rows <- list()
  add_rows <- function(parameter_class, keys, coordinate_system, values) {
    rows[[length(rows) + 1L]] <<- data.frame(
      SemanticKey = as.character(keys),
      ParameterClass = as.character(parameter_class),
      CoordinateSystem = as.character(coordinate_system),
      Value = as.numeric(values),
      stringsAsFactors = FALSE
    )
  }

  for (facet in context$config$facet_names) {
    levels <- as.character(context$config$facet_levels[[facet]])
    add_rows(
      paste0("facet:", facet),
      paste("facet", facet, levels, sep = "::"),
      "expanded_identified_facet_coordinate",
      params$facets[[facet]]
    )
  }
  step_levels <- as.character(
    context$config$facet_levels[[context$config$step_facet]]
  )
  step_count <- context$config$n_cat - 1L
  step_keys <- unlist(lapply(step_levels, function(level) {
    paste("step", context$config$step_facet, level,
          paste0("transition", seq_len(step_count)), sep = "::")
  }), use.names = FALSE)
  add_rows(
    "step",
    step_keys,
    "expanded_within_ladder_sum_zero_step_coordinate",
    as.numeric(t(params$steps_mat))
  )

  slope_levels <- as.character(
    context$config$facet_levels[[context$config$slope_facet]]
  )
  add_rows(
    "log_slope",
    paste("log_slope", context$config$slope_facet, slope_levels, sep = "::"),
    "expanded_sum_zero_log_slope_coordinate",
    params$log_slopes
  )
  add_rows(
    "slope",
    paste("slope", context$config$slope_facet, slope_levels, sep = "::"),
    "positive_geometric_mean_one_slope_coordinate",
    params$slopes
  )

  beta <- params$population$coefficients
  add_rows(
    "population_beta",
    paste("population_beta", names(beta), sep = "::"),
    "latent_population_location_coordinate",
    beta
  )
  add_rows(
    "population_log_sigma2",
    "population::log_sigma2",
    "log_population_variance_coordinate",
    params$population$log_sigma2
  )
  add_rows(
    "population_sigma2",
    "population::sigma2",
    "positive_population_variance_coordinate",
    params$population$sigma2
  )
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  mfrmr_gss_assert(
    nrow(out) > 0L && !anyDuplicated(out$SemanticKey) && all(is.finite(out$Value)),
    "The expanded semantic vector must have unique finite labelled coordinates."
  )
  out
}

mfrmr_gss_dimension_audit <- function(fit, context, par) {
  optimizer_map <- mfrmr_gss_get("mfrmr_mml_optimizer_parameter_map")(
    prep = fit$prep,
    idx = context$idx,
    config = context$config,
    sizes = context$sizes
  )
  raw_score_dimension <- suppressWarnings(as.integer(
    fit$config$estimability_audit$mml_observed_pattern_score$free_dimension
  ))
  score_dimension <- if (length(raw_score_dimension) == 1L) {
    raw_score_dimension
  } else {
    NA_integer_
  }
  values <- c(
    returned_vector = length(par),
    parameter_sizes = sum(vapply(context$sizes, as.integer, integer(1))),
    canonical_coordinate_table = nrow(context$coordinates),
    mml_optimizer_map = nrow(optimizer_map),
    observed_pattern_score_audit = score_dimension
  )
  list(
    values = values,
    identity = length(values) == 5L && all(is.finite(values)) &&
      length(unique(as.integer(values))) == 1L,
    optimizer_map = optimizer_map
  )
}

mfrmr_gss_run_candidate <- function(start_row, fit, context, use_fit_opt = FALSE) {
  warnings <- character(0)
  error_text <- ""
  elapsed <- NA_real_
  opt <- NULL
  if (isTRUE(use_fit_opt)) {
    opt <- fit$opt
    elapsed <- 0
  } else {
    started <- proc.time()[["elapsed"]]
    opt <- tryCatch(
      withCallingHandlers(
        mfrmr_gss_get("run_mfrm_direct_optimization")(
          start = as.numeric(start_row$StartVector[[1L]]),
          method = "MML",
          idx = context$idx,
          config = context$config,
          sizes = context$sizes,
          quad_points = as.integer(start_row$QuadPoints),
          maxit = as.integer(start_row$Maxit),
          reltol = as.numeric(start_row$Reltol),
          quad = context$quad,
          optimizer = as.character(start_row$Optimizer),
          suppress_convergence_warning = TRUE
        ),
        warning = function(condition) {
          warnings <<- c(warnings, conditionMessage(condition))
          invokeRestart("muffleWarning")
        }
      ),
      error = function(condition) {
        error_text <<- conditionMessage(condition)
        NULL
      }
    )
    elapsed <- proc.time()[["elapsed"]] - started
  }
  list(
    opt = opt,
    warnings = unique(warnings),
    error = error_text,
    elapsed = elapsed
  )
}

mfrmr_gss_candidate_row <- function(start_row, run, fit, context) {
  opt <- run$opt
  par <- if (!is.null(opt)) as.numeric(opt$par) else numeric(0)
  returned <- length(par) > 0L && all(is.finite(par))
  common_objective <- NA_real_
  common_gradient <- rep(NA_real_, nrow(context$coordinates))
  independent_gradient <- rep(NA_real_, nrow(context$coordinates))
  dimension <- list(
    identity = FALSE,
    values = c(
      returned_vector = NA_integer_,
      parameter_sizes = NA_integer_,
      canonical_coordinate_table = NA_integer_,
      mml_optimizer_map = NA_integer_,
      observed_pattern_score_audit = NA_integer_
    )
  )
  if (returned) {
    common_objective <- tryCatch(
      suppressWarnings(as.numeric(context$fn(par))[1L]),
      error = function(condition) NA_real_
    )
    common_gradient <- tryCatch(
      suppressWarnings(as.numeric(context$gr(par))),
      error = function(condition) rep(NA_real_, nrow(context$coordinates))
    )
    independent_gradient <- tryCatch(
      suppressWarnings(mfrmr_num_central_gradient(
        context$fn,
        par,
        mfrmr_num_primary_step
      )),
      error = function(condition) rep(NA_real_, nrow(context$coordinates))
    )
    dimension <- mfrmr_gss_dimension_audit(fit, context, par)
  }
  common_complete <- returned && is.finite(common_objective) &&
    length(common_gradient) == nrow(context$coordinates) &&
    all(is.finite(common_gradient)) &&
    length(independent_gradient) == nrow(context$coordinates) &&
    all(is.finite(independent_gradient))
  gradient_difference <- if (common_complete) {
    abs(common_gradient - independent_gradient)
  } else {
    rep(NA_real_, nrow(context$coordinates))
  }
  gradient_scaled_difference <- if (common_complete) {
    gradient_difference / pmax(
      1,
      abs(common_gradient),
      abs(independent_gradient)
    )
  } else {
    rep(NA_real_, nrow(context$coordinates))
  }
  diagnostics <- mfrmr_gss_or(opt$optimizer_diagnostics, list())
  severity <- as.character(
    mfrmr_gss_or(diagnostics$ConvergenceSeverity, "fail")
  )[1L]
  native_objective <- suppressWarnings(as.numeric(
    mfrmr_gss_or(opt$value, NA_real_)
  )[1L])
  existing_optimizer_pass <- identical(severity, "pass")
  p0_comparison_eligible <- common_complete && isTRUE(dimension$identity) &&
    existing_optimizer_pass
  data.frame(
    StartOrder = as.integer(start_row$StartOrder),
    StartId = as.character(start_row$StartId),
    StartRole = as.character(start_row$StartRole),
    StartVectorSHA256 = as.character(start_row$StartVectorSHA256),
    ReturnedVectorSHA256 = if (returned) mfrmr_gss_hash_vector(par) else NA_character_,
    FitReturned = returned,
    NativeObjective = native_objective,
    CommonObjective = common_objective,
    NativeCommonObjectiveAbsDifference = if (
      is.finite(native_objective) && is.finite(common_objective)
    ) abs(native_objective - common_objective) else NA_real_,
    CommonGradientMaxAbs = if (common_complete) max(abs(common_gradient)) else NA_real_,
    CommonGradientRMS = if (common_complete) sqrt(mean(common_gradient^2)) else NA_real_,
    IndependentGradientStep = as.numeric(mfrmr_num_primary_step),
    IndependentGradientMaxAbs = if (common_complete) {
      max(abs(independent_gradient))
    } else {
      NA_real_
    },
    AnalyticNumericGradientMaxAbsDifference = if (common_complete) {
      max(gradient_difference)
    } else {
      NA_real_
    },
    AnalyticNumericGradientMaxScaledDifference = if (common_complete) {
      max(gradient_scaled_difference)
    } else {
      NA_real_
    },
    FreeDimensionReturned = if (returned) length(par) else NA_integer_,
    FreeDimensionSizes = as.integer(dimension$values[["parameter_sizes"]]),
    FreeDimensionCoordinates = as.integer(
      dimension$values[["canonical_coordinate_table"]]
    ),
    FreeDimensionOptimizerMap = as.integer(
      dimension$values[["mml_optimizer_map"]]
    ),
    FreeDimensionScoreAudit = as.integer(
      dimension$values[["observed_pattern_score_audit"]]
    ),
    DimensionIdentity = isTRUE(dimension$identity),
    CommonEvaluationComplete = common_complete,
    ConvergenceCode = suppressWarnings(as.integer(
      mfrmr_gss_or(diagnostics$ConvergenceCode, mfrmr_gss_or(opt$convergence, NA_integer_))
    )[1L]),
    ConvergenceStatus = as.character(
      mfrmr_gss_or(diagnostics$ConvergenceStatus, "not_returned")
    )[1L],
    ConvergenceReason = as.character(
      mfrmr_gss_or(diagnostics$ConvergenceReason, "not_returned")
    )[1L],
    ConvergenceSeverity = severity,
    ExistingOptimizerNumericalPass = existing_optimizer_pass,
    P0ComparisonEligible = p0_comparison_eligible,
    P0StabilityEligible = FALSE,
    P0StabilityEligibilityReason =
      "tolerance_boundary_and_integration_rules_not_frozen",
    BoundaryStatus = "not_evaluated_p0_candidate_only",
    DecisionStatus = "review_p1_p3_dependencies_not_evaluated",
    ToleranceStatus = "not_frozen",
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    ElapsedSeconds = as.numeric(run$elapsed),
    WarningCount = length(run$warnings),
    WarningText = paste(run$warnings, collapse = " | "),
    ErrorText = as.character(run$error),
    stringsAsFactors = FALSE
  )
}

mfrmr_gss_pairwise <- function(candidates, candidate_objects, context) {
  complete_ids <- as.character(
    candidates$StartId[candidates$CommonEvaluationComplete]
  )
  if (length(complete_ids) < 2L) {
    return(list(summary = data.frame(), semantic = data.frame()))
  }
  pairs <- utils::combn(complete_ids, 2L, simplify = FALSE)
  summaries <- vector("list", length(pairs))
  semantic_rows <- list()
  semantic_index <- 1L
  for (index in seq_along(pairs)) {
    left_id <- pairs[[index]][1L]
    right_id <- pairs[[index]][2L]
    left_par <- as.numeric(candidate_objects[[left_id]]$par)
    right_par <- as.numeric(candidate_objects[[right_id]]$par)
    mfrmr_gss_assert(
      length(left_par) == length(right_par),
      "Pairwise free-coordinate vectors have different dimensions."
    )
    left_semantic <- mfrmr_gss_semantic_vector(context, left_par)
    right_semantic <- mfrmr_gss_semantic_vector(context, right_par)
    mfrmr_gss_assert(
      identical(left_semantic$SemanticKey, right_semantic$SemanticKey) &&
        identical(left_semantic$ParameterClass, right_semantic$ParameterClass),
      "Pairwise semantic coordinates are not aligned by exact key and class."
    )
    absolute <- abs(left_semantic$Value - right_semantic$Value)
    scaled <- absolute / pmax(
      1,
      abs(left_semantic$Value),
      abs(right_semantic$Value)
    )
    for (parameter_class in unique(left_semantic$ParameterClass)) {
      selected <- left_semantic$ParameterClass == parameter_class
      maximum <- which.max(absolute[selected])
      selected_rows <- which(selected)
      semantic_rows[[semantic_index]] <- data.frame(
        LeftStartId = left_id,
        RightStartId = right_id,
        ParameterClass = parameter_class,
        CoordinateCount = sum(selected),
        MaxAbsDifference = max(absolute[selected]),
        MaxScaledDifference = max(scaled[selected]),
        MaxDifferenceKey = left_semantic$SemanticKey[selected_rows[maximum]],
        stringsAsFactors = FALSE
      )
      semantic_index <- semantic_index + 1L
    }
    left_row <- candidates[candidates$StartId == left_id, , drop = FALSE]
    right_row <- candidates[candidates$StartId == right_id, , drop = FALSE]
    free_absolute <- abs(left_par - right_par)
    free_scaled <- free_absolute / pmax(1, abs(left_par), abs(right_par))
    summaries[[index]] <- data.frame(
      LeftStartId = left_id,
      RightStartId = right_id,
      ObjectiveAbsDifference = abs(
        left_row$CommonObjective - right_row$CommonObjective
      ),
      FreeCoordinateMaxAbsDifference = max(free_absolute),
      FreeCoordinateMaxScaledDifference = max(free_scaled),
      SemanticMaxAbsDifference = max(absolute),
      SemanticMaxScaledDifference = max(scaled),
      BothP0ComparisonEligible = isTRUE(left_row$P0ComparisonEligible) &&
        isTRUE(right_row$P0ComparisonEligible),
      ToleranceStatus = "not_frozen",
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  }
  list(
    summary = do.call(rbind, summaries),
    semantic = do.call(rbind, semantic_rows)
  )
}

mfrmr_gss_candidate_signature <- function(candidate_row, overrides = NULL) {
  mfrmr_gss_assert(
    is.data.frame(candidate_row) && nrow(candidate_row) == 1L,
    "A decision signature requires exactly one candidate row."
  )
  pass_return <- isTRUE(candidate_row$FitReturned)
  pass_dimension <- isTRUE(candidate_row$DimensionIdentity)
  pass_common <- isTRUE(candidate_row$CommonEvaluationComplete)
  convergence <- as.character(candidate_row$ConvergenceSeverity)
  signature <- data.frame(
    Metric = c(
      "optimizer_return", "numerical_convergence", "free_dimension_identity",
      "common_objective_gradient", "boundary", "hessian", "intervals",
      "dff", "fit", "person_rank", "rater_rank", "facet_separation",
      "overall"
    ),
    State = c(
      if (pass_return) "pass" else "fail",
      if (convergence %in% c("pass", "review", "fail")) convergence else "fail",
      if (pass_dimension) "pass" else "fail",
      if (pass_common) "pass" else "fail",
      rep("not_evaluated", 8L),
      if (isTRUE(candidate_row$P0ComparisonEligible)) "review" else "blocked"
    ),
    Eligibility = c(
      rep("numeric_gate", 4L),
      rep("not_selection_eligible", 8L),
      "not_selection_eligible"
    ),
    Reason = c(
      if (pass_return) "optimizer_returned_finite_vector" else "no_finite_vector",
      as.character(candidate_row$ConvergenceReason),
      if (pass_dimension) "five_dimension_counts_agree" else "dimension_mismatch",
      if (pass_common) "canonical_objective_and_gradient_finite" else "common_evaluation_failed",
      "scheduled_for_p1", "scheduled_for_p2", "scheduled_for_p2",
      "scheduled_for_p3", "scheduled_for_p3", "scheduled_for_p3",
      "scheduled_for_p3", "scheduled_for_p3",
      if (isTRUE(candidate_row$P0ComparisonEligible)) {
        "numeric_only_p0_pass_later_gates_missing"
      } else {
        "p0_numeric_gate_not_passed"
      }
    ),
    stringsAsFactors = FALSE
  )
  if (!is.null(overrides)) {
    mfrmr_gss_assert(
      is.data.frame(overrides) && nrow(overrides) > 0L &&
        all(c("Metric", "State", "Eligibility", "Reason") %in% names(overrides)) &&
        !anyDuplicated(overrides$Metric) && all(overrides$Metric %in% signature$Metric),
      "Decision-signature overrides must uniquely target declared metrics."
    )
    matched <- match(overrides$Metric, signature$Metric)
    signature$State[matched] <- as.character(overrides$State)
    signature$Eligibility[matched] <- as.character(overrides$Eligibility)
    signature$Reason[matched] <- as.character(overrides$Reason)
  }
  mfrmr_gss_assert(
    !anyDuplicated(signature$Metric) &&
      all(nzchar(signature$State)) &&
      all(nzchar(signature$Eligibility)) &&
      all(nzchar(signature$Reason)),
    "Decision signatures require unique, non-empty canonical fields."
  )
  signature
}

mfrmr_gss_compare_signatures <- function(left, right) {
  required <- c("Metric", "State", "Eligibility", "Reason")
  valid <- function(value) {
    is.data.frame(value) && all(required %in% names(value)) &&
      !anyDuplicated(value$Metric)
  }
  mfrmr_gss_assert(
    valid(left) && valid(right),
    "Both decision signatures must have unique canonical metrics."
  )
  mfrmr_gss_assert(
    setequal(left$Metric, right$Metric),
    "Decision signatures have different metric keys."
  )
  left <- left[order(left$Metric), required, drop = FALSE]
  right <- right[match(left$Metric, right$Metric), required, drop = FALSE]
  changed <- left$State != right$State |
    left$Eligibility != right$Eligibility |
    left$Reason != right$Reason
  data.frame(
    DecisionInvariant = !any(changed),
    ChangedMetricCount = sum(changed),
    ChangedMetrics = paste(left$Metric[changed], collapse = " | "),
    stringsAsFactors = FALSE
  )
}

mfrmr_run_gpcm_solution_stability_p0 <- function(
    maxit = 1200L,
    reltol = 1e-12,
    quad_points = 31L) {
  mfrmr_gss_namespace()
  maxit <- suppressWarnings(as.integer(maxit)[1L])
  reltol <- suppressWarnings(as.numeric(reltol)[1L])
  quad_points <- suppressWarnings(as.integer(quad_points)[1L])
  mfrmr_gss_assert(
    is.finite(maxit) && maxit > 0L && is.finite(reltol) && reltol > 0 &&
      identical(quad_points, 31L),
    "P0 requires positive controls and the prespecified common 31-point quadrature."
  )
  fixture <- mfrmr_num_fixture("polytomous_fixed")
  fit_fun <- getExportedValue("mfrmr", "fit_mfrm")
  baseline_fit <- suppressMessages(suppressWarnings(fit_fun(
    data = fixture$data,
    person = "Person",
    facets = "Item",
    score = "Score",
    rating_min = fixture$rating_min,
    rating_max = fixture$rating_max,
    model = "GPCM",
    method = "MML",
    step_facet = "Item",
    slope_facet = "Item",
    quad_points = quad_points,
    maxit = maxit,
    reltol = reltol,
    optimizer = "L-BFGS-B",
    mml_engine = "direct",
    gpcm_mml_identification = "free_population"
  )))
  context <- mfrmr_num_fit_context(baseline_fit)
  registry <- mfrmr_gss_build_registry(
    baseline_fit,
    fixture,
    context,
    maxit = maxit,
    reltol = reltol
  )

  runs <- vector("list", nrow(registry))
  names(runs) <- registry$StartId
  candidate_objects <- vector("list", nrow(registry))
  names(candidate_objects) <- registry$StartId
  candidate_rows <- vector("list", nrow(registry))
  for (index in seq_len(nrow(registry))) {
    start_row <- registry[index, , drop = FALSE]
    run <- mfrmr_gss_run_candidate(
      start_row,
      baseline_fit,
      context,
      use_fit_opt = identical(as.character(start_row$StartId), "default")
    )
    runs[[index]] <- run
    candidate_objects[index] <- list(run$opt)
    candidate_rows[[index]] <- mfrmr_gss_candidate_row(
      start_row,
      run,
      baseline_fit,
      context
    )
  }
  candidates <- do.call(rbind, candidate_rows)
  rownames(candidates) <- NULL
  pairwise <- mfrmr_gss_pairwise(candidates, candidate_objects, context)

  signatures <- lapply(seq_len(nrow(candidates)), function(index) {
    mfrmr_gss_candidate_signature(candidates[index, , drop = FALSE])
  })
  names(signatures) <- candidates$StartId
  signature_pairs <- utils::combn(candidates$StartId, 2L, simplify = FALSE)
  signature_comparisons <- do.call(rbind, lapply(signature_pairs, function(ids) {
    comparison <- mfrmr_gss_compare_signatures(
      signatures[[ids[1L]]],
      signatures[[ids[2L]]]
    )
    data.frame(
      LeftStartId = ids[1L],
      RightStartId = ids[2L],
      comparison,
      stringsAsFactors = FALSE
    )
  }))

  finite_objective <- which(is.finite(candidates$CommonObjective))
  diagnostic_best <- if (length(finite_objective) > 0L) {
    candidates$StartId[finite_objective[which.min(
      candidates$CommonObjective[finite_objective]
    )]]
  } else {
    NA_character_
  }
  summary <- data.frame(
    Contract = mfrmr_gss_contract,
    Specification = mfrmr_gss_specification,
    FixtureSHA256 = fixture$sha256,
    ContextSHA256 = unique(registry$ContextSHA256),
    DeclaredStarts = nrow(registry),
    ReturnedStarts = sum(candidates$FitReturned),
    ExistingOptimizerPassStarts = sum(candidates$ExistingOptimizerNumericalPass),
    P0ComparisonEligibleStarts = sum(candidates$P0ComparisonEligible),
    P0StabilityEligibleStarts = sum(candidates$P0StabilityEligible),
    DiagnosticLowestObjectiveStart = diagnostic_best,
    CommonObjectiveRange = if (length(finite_objective) > 0L) {
      diff(range(candidates$CommonObjective[finite_objective]))
    } else {
      NA_real_
    },
    ToleranceStatus = "not_frozen",
    BoundaryHessianDecisionStatus = "not_evaluated_p0",
    OverallStatus = "p0_evaluated_selection_blocked",
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  structure(
    list(
      contract = mfrmr_gss_contract,
      specification = mfrmr_gss_specification,
      fixture_manifest = data.frame(
        FixtureId = fixture$fixture_id,
        Seed = fixture$seed,
        Rows = nrow(fixture$data),
        SHA256 = fixture$sha256,
        stringsAsFactors = FALSE
      ),
      registry = registry,
      candidates = candidates,
      pairwise = pairwise$summary,
      semantic_differences = pairwise$semantic,
      decision_signatures = signatures,
      decision_signature_comparisons = signature_comparisons,
      summary = summary,
      baseline_fit = baseline_fit,
      candidate_objects = candidate_objects,
      context = context
    ),
    class = "mfrmr_gpcm_solution_stability_p0"
  )
}
