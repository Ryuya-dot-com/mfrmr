# Draft.73 repository-only JML extreme-Person profile-limit prototype.
#
# For an independently free Person with an all-minimum or all-maximum retained
# response pattern, the conditional response likelihood tends to one as theta
# tends to the corresponding signed infinity.  The supremum objective for all
# remaining coordinates is therefore the JML objective with those Person rows
# removed.  This prototype fits that reduced objective without changing the
# public estimator or overwriting the raw finite optimizer trace.

mfrmr_jml_profile_limit_internal <- function(name) {
  getFromNamespace(name, "mfrmr")
}

mfrmr_jml_profile_limit_or <- function(value, replacement) {
  if (is.null(value) || length(value) == 0L) replacement else value
}

mfrmr_jml_profile_limit_free_from_expanded <- function(expanded, spec,
                                                        tolerance = 1e-9) {
  expanded <- as.numeric(expanded)
  names(expanded) <- as.character(spec$levels)
  n_params <- as.integer(spec$n_params)
  expand <- mfrmr_jml_profile_limit_internal(
    "expand_facet_with_constraints"
  )
  jacobian <- mfrmr_jml_profile_limit_internal("constraint_jacobian")(spec)
  baseline <- expand(numeric(n_params), spec)
  if (n_params == 0L) {
    if (length(expanded) != length(baseline) ||
        max(abs(expanded - baseline), 0) > tolerance) {
      stop("The requested expanded values violate a fixed constraint.",
           call. = FALSE)
    }
    return(numeric(0))
  }
  if (length(expanded) != nrow(jacobian) ||
      qr(jacobian, tol = tolerance)$rank != ncol(jacobian)) {
    stop("The profile-limit constraint map is not full-column-rank.",
         call. = FALSE)
  }
  free <- as.numeric(qr.solve(
    jacobian, expanded - baseline, tol = tolerance
  ))
  reconstructed <- expand(free, spec)
  if (max(abs(reconstructed - expanded), 0) > tolerance) {
    stop("The requested expanded values are outside the constraint image.",
         call. = FALSE)
  }
  free
}

mfrmr_jml_profile_limit_problem <- function(fit, tolerance = 1e-9) {
  if (!inherits(fit, "mfrm_fit") ||
      !identical(as.character(fit$config$method), "JML")) {
    stop("The profile-limit prototype requires a fitted JML mfrm_fit object.",
         call. = FALSE)
  }
  person <- as.data.frame(fit$facets$person, stringsAsFactors = FALSE)
  required <- c("Person", "ParameterStatus", "BoundaryDirection")
  if (!all(required %in% names(person))) {
    stop("The fit does not carry the current typed Person-boundary contract.",
         call. = FALSE)
  }
  coupled <- person$ParameterStatus == "weak_information" &
    person$BoundaryDirection %in% c("low", "high")
  if (any(coupled)) {
    return(list(
      State = "constraint_coupled_extreme_not_profiled",
      Complete = FALSE,
      ExcludedPersons = character(0),
      ConstraintCoupledPersons = as.character(person$Person[coupled]),
      ReadinessEffect = "none_prototype_only"
    ))
  }
  unbounded <- person$ParameterStatus %in%
    c("unbounded_low", "unbounded_high")
  if (!any(unbounded)) {
    return(list(
      State = "no_free_extreme_persons",
      Complete = TRUE,
      ExcludedPersons = character(0),
      ConstraintCoupledPersons = character(0),
      ReadinessEffect = "none_prototype_only"
    ))
  }

  excluded <- as.character(person$Person[unbounded])
  direction <- ifelse(
    person$ParameterStatus[unbounded] == "unbounded_high", "high", "low"
  )
  names(direction) <- excluded
  config <- fit$config
  theta_spec <- config$theta_spec
  theta_jacobian <- mfrmr_jml_profile_limit_internal(
    "constraint_jacobian"
  )(theta_spec)
  theta_rows <- match(excluded, rownames(theta_jacobian))
  if (anyNA(theta_rows)) {
    stop("Typed extreme Persons do not align with the theta constraint map.",
         call. = FALSE)
  }
  independent <- vapply(theta_rows, function(row) {
    active <- which(abs(theta_jacobian[row, ]) > tolerance)
    length(active) == 1L &&
      sum(abs(theta_jacobian[-row, active]) > tolerance) == 0L
  }, logical(1))
  if (!all(independent)) {
    return(list(
      State = "extreme_coordinate_not_independently_free",
      Complete = FALSE,
      ExcludedPersons = excluded,
      ConstraintCoupledPersons = excluded[!independent],
      ReadinessEffect = "none_prototype_only"
    ))
  }

  retained <- setdiff(as.character(theta_spec$levels), excluded)
  if (length(retained) == 0L) {
    return(list(
      State = "no_nonextreme_persons_remain",
      Complete = FALSE,
      ExcludedPersons = excluded,
      ConstraintCoupledPersons = character(0),
      ReadinessEffect = "none_prototype_only"
    ))
  }
  prep <- fit$prep
  row_keep <- !as.character(prep$data$Person) %in% excluded
  reduced_prep <- prep
  reduced_prep$data <- prep$data[row_keep, , drop = FALSE]
  reduced_prep$data$Person <- factor(
    as.character(reduced_prep$data$Person), levels = retained
  )
  reduced_prep$levels$Person <- retained
  reduced_prep$n_person <- length(retained)
  reduced_prep$n_obs <- nrow(reduced_prep$data)
  reduced_prep$weighted_n <- sum(reduced_prep$data$Weight)

  reduced_config <- config
  reduced_config$n_person <- length(retained)
  reduced_config$person_levels <- retained
  reduced_config$theta_spec <- mfrmr_jml_profile_limit_internal(
    "build_facet_constraint"
  )(
    levels = retained,
    anchors = theta_spec$anchors[retained],
    groups = theta_spec$groups[retained],
    group_values = theta_spec$group_values,
    centered = isTRUE(theta_spec$centered)
  )
  reduced_config$boundary_audit <- NULL

  build_indices <- mfrmr_jml_profile_limit_internal("build_indices")
  build_sizes <- mfrmr_jml_profile_limit_internal("build_param_sizes")
  build_slices <- mfrmr_jml_profile_limit_internal("build_param_slices")
  expand_params <- mfrmr_jml_profile_limit_internal("expand_params")
  build_start <- mfrmr_jml_profile_limit_internal(
    "build_initial_param_vector"
  )
  original_sizes <- build_sizes(config)
  reduced_sizes <- build_sizes(reduced_config)
  original_slices <- build_slices(original_sizes)
  reduced_slices <- build_slices(reduced_sizes)
  idx <- build_indices(
    reduced_prep,
    step_facet = reduced_config$step_facet,
    slope_facet = reduced_config$slope_facet,
    interaction_specs = reduced_config$interaction_specs
  )
  original_idx <- build_indices(
    fit$prep,
    step_facet = config$step_facet,
    slope_facet = config$slope_facet,
    interaction_specs = config$interaction_specs
  )
  original_params <- expand_params(fit$opt$par, original_sizes, config)
  start <- build_start(reduced_config, reduced_sizes)
  start[reduced_slices$theta] <-
    mfrmr_jml_profile_limit_free_from_expanded(
      original_params$theta[retained], reduced_config$theta_spec, tolerance
    )
  structural_blocks <- setdiff(names(reduced_sizes), "theta")
  for (block in structural_blocks) {
    old_index <- original_slices[[block]]
    new_index <- reduced_slices[[block]]
    if (length(old_index) != length(new_index)) {
      stop("The profile-limit refit changed structural block dimension `",
           block, "`.", call. = FALSE)
    }
    if (length(new_index) > 0L) start[new_index] <- fit$opt$par[old_index]
  }

  list(
    State = "profile_limit_problem_ready",
    Complete = TRUE,
    fit = fit,
    config = config,
    reduced_config = reduced_config,
    prep = fit$prep,
    reduced_prep = reduced_prep,
    idx = original_idx,
    reduced_idx = idx,
    original_sizes = original_sizes,
    reduced_sizes = reduced_sizes,
    original_slices = original_slices,
    reduced_slices = reduced_slices,
    start = start,
    ExcludedPersons = excluded,
    ExcludedDirections = direction,
    RetainedPersons = retained,
    ExcludedResponseRows = sum(!row_keep),
    ExcludedWeightedResponses = sum(prep$data$Weight[!row_keep]),
    ConstraintCoupledPersons = character(0),
    ReadinessEffect = "none_prototype_only"
  )
}

mfrmr_jml_profile_limit_parameter_table <- function(problem, profile_par) {
  expand <- mfrmr_jml_profile_limit_internal("expand_params")
  raw <- expand(
    problem$fit$opt$par, problem$original_sizes, problem$config
  )
  profile <- expand(
    profile_par, problem$reduced_sizes, problem$reduced_config
  )
  rows <- list()
  add <- function(parameter_class, facet, level, raw_value, profile_value) {
    rows[[length(rows) + 1L]] <<- data.frame(
      ParameterClass = parameter_class,
      Facet = facet,
      Level = level,
      RawFiniteEstimate = as.numeric(raw_value),
      ProfileLimitEstimate = as.numeric(profile_value),
      Difference = as.numeric(profile_value - raw_value),
      stringsAsFactors = FALSE
    )
  }
  for (person in problem$RetainedPersons) {
    add("Person", "Person", person, raw$theta[person], profile$theta[person])
  }
  for (facet in problem$config$facet_names) {
    levels <- as.character(problem$config$facet_specs[[facet]]$levels)
    for (level in levels) {
      add("Facet", facet, level,
          raw$facets[[facet]][level], profile$facets[[facet]][level])
    }
  }
  if (identical(problem$config$model, "RSM")) {
    for (step in seq_along(raw$steps)) {
      add("Step", "shared", paste0("Step", step),
          raw$steps[step], profile$steps[step])
    }
  } else {
    owner <- problem$config$step_facet
    owner_levels <- as.character(problem$config$facet_levels[[owner]])
    for (i in seq_along(owner_levels)) {
      for (step in seq_len(ncol(raw$steps_mat))) {
        add("Step", owner, paste0(owner_levels[i], ":Step", step),
            raw$steps_mat[i, step], profile$steps_mat[i, step])
      }
    }
  }
  if (identical(problem$config$model, "GPCM")) {
    slope_levels <- as.character(problem$config$gpcm_spec$levels)
    for (i in seq_along(slope_levels)) {
      level <- slope_levels[i]
      add("LogSlope", problem$config$slope_facet, level,
          raw$log_slopes[i], profile$log_slopes[i])
      add("Slope", problem$config$slope_facet, level,
          raw$slopes[i], profile$slopes[i])
    }
  }
  interactions <- problem$config$interaction_specs
  if (length(interactions) > 0L) {
    for (name in names(interactions)) {
      raw_matrix <- raw$interactions[[name]]
      profile_matrix <- profile$interactions[[name]]
      for (i in seq_len(nrow(raw_matrix))) {
        for (j in seq_len(ncol(raw_matrix))) {
          level <- paste0(
            interactions[[name]]$levels_a[i], ":",
            interactions[[name]]$levels_b[j]
          )
          add("Interaction", name, level,
              raw_matrix[i, j], profile_matrix[i, j])
        }
      }
    }
  }
  do.call(rbind, rows)
}

mfrmr_jml_profile_limit_path <- function(problem, profile_par,
                                          caps = c(4, 8, 12, 16, 24, 32),
                                          tolerance = 1e-9) {
  caps <- sort(unique(as.numeric(caps)))
  if (length(caps) == 0L || any(!is.finite(caps)) || any(caps <= 0)) {
    stop("`caps` must contain positive finite values.", call. = FALSE)
  }
  expand <- mfrmr_jml_profile_limit_internal("expand_params")
  objective <- mfrmr_jml_profile_limit_internal("mfrm_loglik_jml")
  profile <- expand(
    profile_par, problem$reduced_sizes, problem$reduced_config
  )
  profile_loglik <- -objective(
    profile_par, problem$reduced_idx, problem$reduced_config,
    problem$reduced_sizes
  )
  result <- lapply(caps, function(cap) {
    candidate <- problem$fit$opt$par
    for (block in setdiff(names(problem$reduced_sizes), "theta")) {
      candidate[problem$original_slices[[block]]] <-
        profile_par[problem$reduced_slices[[block]]]
    }
    theta <- numeric(length(problem$config$theta_spec$levels))
    names(theta) <- as.character(problem$config$theta_spec$levels)
    theta[problem$RetainedPersons] <- profile$theta[problem$RetainedPersons]
    theta[problem$ExcludedPersons] <- ifelse(
      problem$ExcludedDirections[problem$ExcludedPersons] == "high",
      cap, -cap
    )
    candidate[problem$original_slices$theta] <-
      mfrmr_jml_profile_limit_free_from_expanded(
        theta, problem$config$theta_spec, tolerance
      )
    loglik <- -objective(
      candidate, problem$idx, problem$config, problem$original_sizes
    )
    data.frame(
      Cap = cap,
      OriginalJMLLogLikelihood = loglik,
      ProfileLimitLogLikelihood = profile_loglik,
      GapToProfileLimit = profile_loglik - loglik,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, result)
}

mfrmr_jml_profile_limit_refit <- function(
    fit,
    caps = c(4, 8, 12, 16, 24, 32),
    maxit = NULL,
    reltol = NULL,
    optimizer = NULL,
    limit_tolerance = 1e-8) {
  problem <- mfrmr_jml_profile_limit_problem(fit)
  if (!identical(problem$State, "profile_limit_problem_ready")) {
    return(list(
      ContractVersion = "mfrmr-jml-extreme-profile-limit-prototype-v1",
      State = problem$State,
      Complete = isTRUE(problem$Complete),
      FiniteOriginalJMLMaximum = if (
        identical(problem$State, "no_free_extreme_persons")
      ) NA else FALSE,
      ExcludedPersons = problem$ExcludedPersons,
      ConstraintCoupledPersons = problem$ConstraintCoupledPersons,
      ReadinessEffect = "none_prototype_only"
    ))
  }
  control <- fit$config$estimation_control
  maxit <- as.integer(mfrmr_jml_profile_limit_or(
    maxit, mfrmr_jml_profile_limit_or(control$maxit, 400L)
  ))
  reltol <- as.numeric(mfrmr_jml_profile_limit_or(
    reltol, mfrmr_jml_profile_limit_or(control$reltol, 1e-9)
  ))
  optimizer <- as.character(
    mfrmr_jml_profile_limit_or(
      optimizer,
      mfrmr_jml_profile_limit_or(
        control$optimizer_used,
        mfrmr_jml_profile_limit_or(control$optimizer_requested, "auto")
      )
    )
  )
  run <- mfrmr_jml_profile_limit_internal("run_mfrm_direct_optimization")
  profile_opt <- run(
    start = problem$start,
    method = "JML",
    idx = problem$reduced_idx,
    config = problem$reduced_config,
    sizes = problem$reduced_sizes,
    quad_points = 1L,
    maxit = maxit,
    reltol = reltol,
    optimizer = optimizer,
    suppress_convergence_warning = TRUE
  )
  path <- mfrmr_jml_profile_limit_path(
    problem, profile_opt$par, caps = caps
  )
  monotone <- all(diff(path$OriginalJMLLogLikelihood) >= -limit_tolerance)
  nonnegative_gap <- all(path$GapToProfileLimit >= -limit_tolerance)
  limit_verified <- monotone && nonnegative_gap &&
    tail(path$GapToProfileLimit, 1L) <= limit_tolerance
  diagnostics <- profile_opt$optimizer_diagnostics
  convergence_pass <- identical(
    as.character(diagnostics$ConvergenceSeverity), "pass"
  )
  parameter_table <- mfrmr_jml_profile_limit_parameter_table(
    problem, profile_opt$par
  )
  structural <- parameter_table$ParameterClass != "Person"
  list(
    ContractVersion = "mfrmr-jml-extreme-profile-limit-prototype-v1",
    State = if (convergence_pass && limit_verified) {
      "profile_limit_refit_verified"
    } else if (!convergence_pass) {
      "profile_limit_optimizer_review"
    } else {
      "profile_limit_path_review"
    },
    Complete = convergence_pass && limit_verified,
    Model = as.character(problem$config$model),
    EstimateRole = "extended_jml_profile_limit",
    ObjectiveIdentity = paste(
      "drop_independently_free_extreme_person_contributions",
      "equals_boundary_supremum_v1",
      sep = "_"
    ),
    FiniteOriginalJMLMaximum = FALSE,
    OriginalLikelihoodMaximumAttained = FALSE,
    RawFiniteLogLikelihood = -as.numeric(fit$opt$value),
    ProfileLimitLogLikelihood = -as.numeric(profile_opt$value),
    ProfileLimitGain = -as.numeric(profile_opt$value) + as.numeric(fit$opt$value),
    ExcludedPersons = problem$ExcludedPersons,
    ExcludedDirections = problem$ExcludedDirections,
    ExcludedResponseRows = problem$ExcludedResponseRows,
    ExcludedWeightedResponses = problem$ExcludedWeightedResponses,
    RetainedPersons = problem$RetainedPersons,
    LimitPathMonotone = monotone,
    LimitGapNonnegative = nonnegative_gap,
    LimitVerified = limit_verified,
    TerminalLimitGap = tail(path$GapToProfileLimit, 1L),
    ProfileOptimizerSeverity = as.character(
      diagnostics$ConvergenceSeverity
    ),
    ProfileTerminalGradientSupNorm = as.numeric(
      diagnostics$TerminalGradientSupNorm
    ),
    MaximumAbsoluteStructuralChange = if (any(structural)) {
      max(abs(parameter_table$Difference[structural]), na.rm = TRUE)
    } else {
      0
    },
    path = path,
    parameters = parameter_table,
    profile_opt = profile_opt,
    problem = problem,
    ReadinessEffect = "none_prototype_only",
    Limitations = paste(
      "Repository-only extended-boundary evidence; not a finite original-JML",
      "maximum, finite-item bias correction, public estimator, SE, interval,",
      "or readiness promotion. Constraint-coupled extremes are not profiled."
    )
  )
}
