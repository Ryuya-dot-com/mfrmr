# Repository-only GPCM estimator-asymptotics diagnostic for mfrmr 0.2.3.
#
# The diagnostic separates two questions that are otherwise easily aliased:
# increasing Persons while each Person has fixed exposure, and increasing
# exposure while the Person count is fixed. It compares the current aligned
# single-owner GPCM under JML and MML. It does not select an estimator, estimate
# an incidental-bias correction, or authorize inferential use of optimizer
# slope traces.

mfrmr_gas_or <- function(x, y) {
  if (is.null(x) || length(x) == 0L) y else x
}

mfrmr_gas_fun <- function(name, exported = TRUE) {
  if (exists(name, mode = "function", inherits = TRUE)) {
    return(get(name, mode = "function", inherits = TRUE))
  }
  if (!"mfrmr" %in% loadedNamespaces()) {
    stop("Package `mfrmr` must be loaded before running this diagnostic.",
         call. = FALSE)
  }
  if (isTRUE(exported)) {
    return(getExportedValue("mfrmr", name))
  }
  getFromNamespace(name, "mfrmr")
}

mfrmr_gas_capture <- function(expr) {
  warnings <- character(0)
  value <- tryCatch(
    withCallingHandlers(
      expr,
      warning = function(condition) {
        warnings <<- c(warnings, conditionMessage(condition))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(condition) condition
  )
  list(value = value, warnings = unique(warnings))
}

mfrmr_gas_profile <- function(profile = c("smoke", "pilot")) {
  profile <- match.arg(profile)
  if (identical(profile, "smoke")) {
    return(list(
      person_counts = c(24L, 48L, 96L),
      fixed_persons = 48L,
      replicates = 1L,
      maxit = 100L,
      quad_points = 9L,
      seed_start = 863000L,
      evidence_use = "plumbing_and_directional_smoke_only"
    ))
  }
  list(
    person_counts = c(60L, 120L, 240L),
    fixed_persons = 120L,
    replicates = 20L,
    maxit = 300L,
    quad_points = 31L,
    seed_start = 873000L,
    evidence_use = "calibration_pilot_only"
  )
}

mfrmr_gas_cells <- function(profile = c("smoke", "pilot")) {
  profile <- match.arg(profile)
  settings <- mfrmr_gas_profile(profile)
  persons <- settings$person_counts
  middle <- settings$fixed_persons
  out <- data.frame(
    CellId = c(
      sprintf("N%03d-L08", persons[1L]),
      sprintf("N%03d-L08", persons[2L]),
      sprintf("N%03d-L08", persons[3L]),
      sprintf("N%03d-L16", middle),
      sprintf("N%03d-L24", middle)
    ),
    NPersons = c(persons, middle, middle),
    RatersPerPerson = c(2L, 2L, 2L, 4L, 6L),
    Criteria = 4L,
    Raters = 6L,
    Categories = 4L,
    stringsAsFactors = FALSE
  )
  out$ObservationsPerPerson <- out$RatersPerPerson * out$Criteria
  out$ExpectedRows <- out$NPersons * out$ObservationsPerPerson
  out
}

mfrmr_gas_sequence_membership <- function(
    profile = c("smoke", "pilot")) {
  profile <- match.arg(profile)
  cells <- mfrmr_gas_cells(profile)
  fixed_exposure <- cells[cells$ObservationsPerPerson == 8L, , drop = FALSE]
  fixed_persons <- cells[cells$NPersons == mfrmr_gas_profile(profile)$fixed_persons,
                         , drop = FALSE]
  rbind(
    data.frame(
      CellId = fixed_exposure$CellId,
      Sequence = "persons_increase_exposure_fixed",
      XName = "NPersons",
      XValue = fixed_exposure$NPersons,
      stringsAsFactors = FALSE
    ),
    data.frame(
      CellId = fixed_persons$CellId,
      Sequence = "exposure_increases_persons_fixed",
      XName = "ObservationsPerPerson",
      XValue = fixed_persons$ObservationsPerPerson,
      stringsAsFactors = FALSE
    )
  )
}

mfrmr_gas_manifest <- function(profile = c("smoke", "pilot"),
                               replicates = NULL) {
  profile <- match.arg(profile)
  settings <- mfrmr_gas_profile(profile)
  replicates <- as.integer(mfrmr_gas_or(replicates, settings$replicates))
  if (length(replicates) != 1L || is.na(replicates) || replicates < 1L) {
    stop("`replicates` must be one positive integer.", call. = FALSE)
  }
  cells <- mfrmr_gas_cells(profile)
  methods <- data.frame(
    Method = c("JML", "MML"),
    PersonTreatment = c("joint_fixed_effect", "integrated_normal_population"),
    stringsAsFactors = FALSE
  )
  repetitions <- data.frame(
    Replicate = seq_len(replicates),
    Seed = settings$seed_start + seq_len(replicates),
    stringsAsFactors = FALSE
  )
  out <- merge(merge(repetitions, cells, all = TRUE), methods, all = TRUE)
  out <- out[order(out$Replicate, match(out$CellId, cells$CellId),
                   match(out$Method, methods$Method)), , drop = FALSE]
  row.names(out) <- NULL
  out$Profile <- profile
  out$Model <- "GPCM"
  out$StepFacet <- "Criterion"
  out$SlopeFacet <- "Criterion"
  out$Maxit <- settings$maxit
  out$QuadPoints <- ifelse(out$Method == "MML",
                           settings$quad_points, NA_integer_)
  out$EvidenceUse <- settings$evidence_use
  out$IncidentalBiasDecision <- if (identical(profile, "pilot")) {
    "pilot_planned_no_prespecified_decision_rule"
  } else {
    "not_assigned_replicated_pilot_required"
  }
  out$EstimatorSelectionAuthorized <- FALSE
  out$BiasCorrectionAuthorized <- FALSE
  out$BayesianEstimatorRequired <- NA
  out$ConfirmationAuthorized <- FALSE
  out
}

mfrmr_gas_thresholds <- function(criteria, categories = 4L) {
  transitions <- as.integer(categories) - 1L
  base <- seq(-1.2, 1.2, length.out = transitions)
  do.call(rbind, lapply(seq_along(criteria), function(index) {
    data.frame(
      StepFacet = criteria[index],
      StepIndex = seq_len(transitions),
      Estimate = base + seq(-0.18, 0.18,
                            length.out = length(criteria))[index],
      stringsAsFactors = FALSE
    )
  }))
}

mfrmr_gas_generate_base <- function(manifest, replicate = 1L) {
  rows <- manifest[manifest$Replicate == as.integer(replicate), , drop = FALSE]
  if (nrow(rows) == 0L) {
    stop("The requested replicate is absent from `manifest`.", call. = FALSE)
  }
  if (length(unique(rows$Seed)) != 1L) {
    stop("Each replicate must use exactly one generating seed.", call. = FALSE)
  }
  criteria <- sprintf("C%02d", seq_len(unique(rows$Criteria)))
  log_slopes <- seq(-0.3, 0.3, length.out = length(criteria))
  slopes <- stats::setNames(exp(log_slopes - mean(log_slopes)), criteria)
  build_spec <- mfrmr_gas_fun("build_mfrm_sim_spec")
  simulate <- mfrmr_gas_fun("simulate_mfrm_data")
  spec <- build_spec(
    n_person = max(rows$NPersons),
    n_rater = unique(rows$Raters),
    n_criterion = unique(rows$Criteria),
    raters_per_person = unique(rows$Raters),
    score_levels = unique(rows$Categories),
    theta_sd = 1,
    rater_sd = 0.45,
    criterion_sd = 0.30,
    thresholds = mfrmr_gas_thresholds(
      criteria, categories = unique(rows$Categories)
    ),
    slopes = slopes,
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    assignment = "crossed"
  )
  data <- simulate(sim_spec = spec, seed = unique(rows$Seed))
  truth <- attr(data, "mfrm_truth")
  truth$population <- list(
    coefficients = stats::setNames(0, "(Intercept)"),
    sigma2 = 1,
    basis = "generating_normal_distribution_not_realized_sample_moments"
  )
  attr(data, "mfrm_truth") <- truth
  list(data = data, truth = truth, spec = spec)
}

mfrmr_gas_subset_cell <- function(base, cell) {
  data <- base$data
  persons <- sort(unique(as.character(data$Person)))
  raters <- sort(unique(as.character(data$Rater)))
  person_index <- match(as.character(data$Person), persons)
  rater_index <- match(as.character(data$Rater), raters)
  first_rater <- ((person_index - 1L) %% length(raters)) + 1L
  rotating_offset <- (rater_index - first_rater + length(raters)) %%
    length(raters)
  keep <- person_index <= as.integer(cell$NPersons) &
    rotating_offset < as.integer(cell$RatersPerPerson)
  out <- data[keep, , drop = FALSE]
  truth <- base$truth
  truth$person <- truth$person[names(truth$person) %in%
                                 persons[seq_len(as.integer(cell$NPersons))]]
  attr(out, "mfrm_truth") <- truth
  out
}

mfrmr_gas_graph_components <- function(data) {
  pairs <- unique(data[, c("Person", "Rater"), drop = FALSE])
  raters <- sort(unique(as.character(pairs$Rater)))
  adjacency <- matrix(FALSE, length(raters), length(raters),
                      dimnames = list(raters, raters))
  diag(adjacency) <- TRUE
  if (length(raters) > 1L) {
    combinations <- utils::combn(raters, 2L)
    for (column in seq_len(ncol(combinations))) {
      pair <- combinations[, column]
      linked <- length(intersect(
        pairs$Person[pairs$Rater == pair[1L]],
        pairs$Person[pairs$Rater == pair[2L]]
      )) > 0L
      adjacency[pair[1L], pair[2L]] <- linked
      adjacency[pair[2L], pair[1L]] <- linked
    }
  }
  unseen <- raters
  components <- 0L
  while (length(unseen) > 0L) {
    components <- components + 1L
    frontier <- unseen[1L]
    reached <- character(0)
    while (length(frontier) > 0L) {
      current <- frontier[1L]
      frontier <- frontier[-1L]
      if (current %in% reached) next
      reached <- c(reached, current)
      neighbours <- raters[adjacency[current, ]]
      frontier <- unique(c(frontier, setdiff(neighbours, reached)))
    }
    unseen <- setdiff(unseen, reached)
  }
  components
}

mfrmr_gas_design_audit <- function(data, cell) {
  exposure <- table(as.character(data$Person))
  graph_components <- mfrmr_gas_graph_components(data)
  data.frame(
    Replicate = as.integer(mfrmr_gas_or(cell$Replicate, NA_integer_)),
    Seed = as.integer(mfrmr_gas_or(cell$Seed, NA_integer_)),
    CellId = as.character(cell$CellId),
    Rows = nrow(data),
    Persons = length(unique(data$Person)),
    Raters = length(unique(data$Rater)),
    Criteria = length(unique(data$Criterion)),
    MinObservationsPerPerson = min(exposure),
    MaxObservationsPerPerson = max(exposure),
    ExpectedObservationsPerPerson = as.integer(cell$ObservationsPerPerson),
    RaterGraphComponents = graph_components,
    DesignContractPassed = nrow(data) == as.integer(cell$ExpectedRows) &&
      length(unique(data$Person)) == as.integer(cell$NPersons) &&
      min(exposure) == as.integer(cell$ObservationsPerPerson) &&
      max(exposure) == as.integer(cell$ObservationsPerPerson) &&
      graph_components == 1L,
    stringsAsFactors = FALSE
  )
}

mfrmr_gas_status_row <- function(row, fit = NULL, error = NA_character_,
                                 warnings = character(0), runtime = NA_real_) {
  fit_summary <- if (is.null(fit)) data.frame() else {
    as.data.frame(mfrmr_gas_or(fit$summary, data.frame()),
                  stringsAsFactors = FALSE)
  }
  take <- function(name, default = NA) {
    if (nrow(fit_summary) == 1L && name %in% names(fit_summary)) {
      fit_summary[[name]][1L]
    } else {
      default
    }
  }
  person_table <- if (is.null(fit)) data.frame() else {
    as.data.frame(mfrmr_gas_or(fit$facets$person, data.frame()),
                  stringsAsFactors = FALSE)
  }
  extreme_n <- if ("ResponseExtreme" %in% names(person_table)) {
    sum(person_table$ResponseExtreme != "none", na.rm = TRUE)
  } else {
    NA_integer_
  }
  data.frame(
    Replicate = as.integer(row$Replicate),
    Seed = as.integer(row$Seed),
    CellId = as.character(row$CellId),
    NPersons = as.integer(row$NPersons),
    ObservationsPerPerson = as.integer(row$ObservationsPerPerson),
    Method = as.character(row$Method),
    FitReturned = !is.null(fit),
    EstimationConverged = isTRUE(take("Converged", FALSE)),
    FitReadiness = as.character(take("FitReadiness", NA_character_)),
    InferenceReady = isTRUE(take("InferenceReady", FALSE)),
    BoundaryState = as.character(take("BoundaryState", NA_character_)),
    ReadinessReasons = as.character(take(
      "ReadinessReasonCodes", take("BoundaryReasonCodes", "")
    )),
    ExtremePersons = as.integer(extreme_n),
    RuntimeSeconds = as.numeric(runtime),
    Warnings = paste(unique(warnings), collapse = " | "),
    Error = as.character(error),
    stringsAsFactors = FALSE
  )
}

mfrmr_gas_slope_trace <- function(fit, truth, row) {
  fitted <- as.data.frame(mfrmr_gas_or(fit$slopes, data.frame()),
                          stringsAsFactors = FALSE)
  target <- as.data.frame(mfrmr_gas_or(truth$slope_table, data.frame()),
                          stringsAsFactors = FALSE)
  required_fit <- c("SlopeFacet", "OptimizerEstimate")
  required_truth <- c("SlopeFacet", "Estimate")
  if (!all(required_fit %in% names(fitted)) ||
      !all(required_truth %in% names(target))) {
    return(data.frame())
  }
  joined <- merge(
    fitted[, intersect(c(required_fit, "ComparisonEligibility"), names(fitted)),
           drop = FALSE],
    target[, required_truth, drop = FALSE],
    by = "SlopeFacet", suffixes = c(".Fit", ".Truth"), sort = FALSE
  )
  estimate <- as.numeric(joined$OptimizerEstimate)
  truth_value <- as.numeric(joined$Estimate)
  finite <- is.finite(estimate) & estimate > 0 &
    is.finite(truth_value) & truth_value > 0
  joined <- joined[finite, , drop = FALSE]
  if (nrow(joined) == 0L) return(data.frame())
  data.frame(
    Replicate = as.integer(row$Replicate),
    CellId = as.character(row$CellId),
    NPersons = as.integer(row$NPersons),
    ObservationsPerPerson = as.integer(row$ObservationsPerPerson),
    Method = as.character(row$Method),
    SlopeFacet = as.character(joined$SlopeFacet),
    TruthLogSlope = log(as.numeric(joined$Estimate)),
    OptimizerLogSlope = log(as.numeric(joined$OptimizerEstimate)),
    Error = log(as.numeric(joined$OptimizerEstimate)) -
      log(as.numeric(joined$Estimate)),
    ComparisonEligibility = if ("ComparisonEligibility" %in% names(joined)) {
      as.character(joined$ComparisonEligibility)
    } else {
      "not_recorded"
    },
    InferentialUse = "ineligible_optimizer_trace_only",
    stringsAsFactors = FALSE
  )
}

mfrmr_gas_fit_one <- function(row, data) {
  truth <- attr(data, "mfrm_truth")
  fit_args <- list(
    data = data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    model = "GPCM",
    method = as.character(row$Method),
    step_facet = "Criterion",
    slope_facet = "Criterion",
    rating_min = 1L,
    rating_max = as.integer(row$Categories),
    keep_original = TRUE,
    maxit = as.integer(row$Maxit),
    anchor_policy = "silent",
    attach_diagnostics = FALSE
  )
  if (identical(row$Method, "MML")) {
    fit_args$quad_points <- as.integer(row$QuadPoints)
  }
  start <- proc.time()[["elapsed"]]
  captured <- mfrmr_gas_capture(
    do.call(mfrmr_gas_fun("fit_mfrm"), fit_args)
  )
  runtime <- proc.time()[["elapsed"]] - start
  if (inherits(captured$value, "error")) {
    return(list(
      status = mfrmr_gas_status_row(
        row, error = conditionMessage(captured$value),
        warnings = captured$warnings, runtime = runtime
      ),
      recovery = data.frame(),
      slope_trace = data.frame()
    ))
  }
  fit <- captured$value
  recovery <- mfrmr_gas_fun("recovery_rows_from_fit", exported = FALSE)(
    fit, truth, rep = as.integer(row$Replicate), include_person = FALSE
  )
  recovery <- as.data.frame(recovery, stringsAsFactors = FALSE)
  if (nrow(recovery) > 0L) {
    # Slopes have a dedicated optimizer-trace table below because the current
    # primary slope may be comparison-ineligible even when it is finite.
    recovery <- recovery[recovery$ParameterType != "slope", , drop = FALSE]
  }
  if (nrow(recovery) > 0L) {
    recovery$Replicate <- as.integer(row$Replicate)
    recovery$CellId <- as.character(row$CellId)
    recovery$NPersons <- as.integer(row$NPersons)
    recovery$ObservationsPerPerson <- as.integer(row$ObservationsPerPerson)
    recovery$Method <- as.character(row$Method)
    recovery$InferenceEligible <- isTRUE(fit$summary$InferenceReady[1L]) &
      recovery$RecoveryComparable
    recovery$RecoveryUse <- "diagnostic_truth_recovery_only"
  }
  list(
    status = mfrmr_gas_status_row(
      row, fit = fit, warnings = captured$warnings, runtime = runtime
    ),
    recovery = recovery,
    slope_trace = mfrmr_gas_slope_trace(fit, truth, row)
  )
}

mfrmr_gas_bind <- function(rows) {
  rows <- rows[vapply(rows, function(value) {
    is.data.frame(value) && nrow(value) > 0L
  }, logical(1))]
  if (length(rows) == 0L) return(data.frame())
  all_names <- unique(unlist(lapply(rows, names), use.names = FALSE))
  rows <- lapply(rows, function(value) {
    missing <- setdiff(all_names, names(value))
    for (name in missing) value[[name]] <- NA
    value[, all_names, drop = FALSE]
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_run_gpcm_estimator_asymptotics <- function(
    profile = c("smoke", "pilot"), dry_run = TRUE,
    authorize_pilot = FALSE, replicates = NULL) {
  profile <- match.arg(profile)
  manifest <- mfrmr_gas_manifest(profile, replicates = replicates)
  membership <- mfrmr_gas_sequence_membership(profile)
  if (isTRUE(dry_run)) {
    return(structure(
      list(manifest = manifest, sequence_membership = membership),
      class = "mfrmr_gpcm_estimator_asymptotics_plan"
    ))
  }
  if (identical(profile, "pilot") && !isTRUE(authorize_pilot)) {
    stop("Pilot execution requires `authorize_pilot = TRUE`.", call. = FALSE)
  }

  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (had_seed) old_seed <- get(".Random.seed", envir = .GlobalEnv)
  on.exit({
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)

  status_rows <- list()
  recovery_rows <- list()
  slope_rows <- list()
  design_rows <- list()
  cursor <- 0L
  for (replicate in sort(unique(manifest$Replicate))) {
    base <- mfrmr_gas_generate_base(manifest, replicate = replicate)
    replicate_rows <- manifest[manifest$Replicate == replicate, , drop = FALSE]
    cells <- unique(replicate_rows$CellId)
    data_by_cell <- stats::setNames(vector("list", length(cells)), cells)
    for (cell_id in cells) {
      cell <- replicate_rows[replicate_rows$CellId == cell_id, , drop = FALSE][1L, ]
      data_by_cell[[cell_id]] <- mfrmr_gas_subset_cell(base, cell)
      design_rows[[length(design_rows) + 1L]] <-
        mfrmr_gas_design_audit(data_by_cell[[cell_id]], cell)
    }
    if (!all(vapply(design_rows, function(value) {
      isTRUE(value$DesignContractPassed[1L])
    }, logical(1)))) {
      stop("A generated cell failed the fixed-N/fixed-exposure design contract.",
           call. = FALSE)
    }
    for (index in seq_len(nrow(replicate_rows))) {
      cursor <- cursor + 1L
      row <- replicate_rows[index, , drop = FALSE]
      fitted <- mfrmr_gas_fit_one(row, data_by_cell[[row$CellId]])
      status_rows[[cursor]] <- fitted$status
      recovery_rows[[cursor]] <- fitted$recovery
      slope_rows[[cursor]] <- fitted$slope_trace
    }
  }
  structure(
    list(
      manifest = manifest,
      sequence_membership = membership,
      design = mfrmr_gas_bind(design_rows),
      status = mfrmr_gas_bind(status_rows),
      recovery = mfrmr_gas_bind(recovery_rows),
      slope_optimizer_trace = mfrmr_gas_bind(slope_rows),
      decisions = data.frame(
        IncidentalBiasDecision = if (identical(profile, "pilot")) {
          "pilot_completed_no_prespecified_decision_rule"
        } else {
          "not_assigned_replicated_pilot_required"
        },
        EstimatorSelectionAuthorized = FALSE,
        BiasCorrectionAuthorized = FALSE,
        BayesianEstimatorRequired = NA,
        ConfirmationAuthorized = FALSE,
        stringsAsFactors = FALSE
      )
    ),
    class = "mfrmr_gpcm_estimator_asymptotics"
  )
}

mfrmr_gas_safe_mean <- function(value) {
  value <- as.numeric(value)
  value <- value[is.finite(value)]
  if (length(value) == 0L) NA_real_ else mean(value)
}

mfrmr_gas_safe_rmse <- function(value) {
  value <- as.numeric(value)
  value <- value[is.finite(value)]
  if (length(value) == 0L) NA_real_ else sqrt(mean(value^2))
}

mfrmr_gas_group_rows <- function(data, keys) {
  missing <- setdiff(keys, names(data))
  if (length(missing) > 0L) {
    stop("Grouping columns are missing: ", paste(missing, collapse = ", "),
         call. = FALSE)
  }
  parts <- lapply(data[keys], function(value) {
    value <- as.character(value)
    value[is.na(value)] <- "<missing>"
    value
  })
  split(
    seq_len(nrow(data)),
    interaction(parts, drop = TRUE, lex.order = TRUE, sep = "\r")
  )
}

mfrmr_gas_replicate_metrics <- function(data, error_column, component) {
  keys <- c(
    "Replicate", "CellId", "NPersons", "ObservationsPerPerson", "Method"
  )
  missing <- setdiff(c(keys, error_column), names(data))
  if (length(missing) > 0L) {
    stop("Metric columns are missing: ", paste(missing, collapse = ", "),
         call. = FALSE)
  }
  if (length(component) != nrow(data)) {
    stop("`component` must contain one label per metric row.", call. = FALSE)
  }
  error <- as.numeric(data[[error_column]])
  if (any(!is.finite(error))) {
    stop("Replicate metrics require finite recovery errors.", call. = FALSE)
  }
  data$Component <- as.character(component)
  groups <- mfrmr_gas_group_rows(data, c(keys, "Component"))
  rows <- lapply(groups, function(index) {
    data.frame(
      data[index[1L], c(keys, "Component"), drop = FALSE],
      Coordinates = length(index),
      RMSE = sqrt(mean(error[index]^2)),
      MAE = mean(abs(error[index])),
      stringsAsFactors = FALSE
    )
  })
  mfrmr_gas_bind(rows)
}

mfrmr_gas_mc_interval <- function(value) {
  value <- as.numeric(value)
  if (any(!is.finite(value))) {
    stop("Monte Carlo summaries require finite replicate values.",
         call. = FALSE)
  }
  replicates <- length(value)
  estimate <- mean(value)
  spread <- if (replicates > 1L) stats::sd(value) else NA_real_
  mcse <- spread / sqrt(replicates)
  critical <- if (replicates > 1L) {
    stats::qt(0.975, df = replicates - 1L)
  } else {
    NA_real_
  }
  c(
    Replicates = replicates,
    Mean = estimate,
    SD = spread,
    MCSE = mcse,
    Lower95 = estimate - critical * mcse,
    Upper95 = estimate + critical * mcse
  )
}

mfrmr_gas_component_mc <- function(replicate_metrics) {
  if (!is.data.frame(replicate_metrics) || nrow(replicate_metrics) == 0L) {
    return(data.frame())
  }
  keys <- c(
    "CellId", "NPersons", "ObservationsPerPerson", "Method", "Component"
  )
  identity <- c("Replicate", keys)
  if (anyDuplicated(replicate_metrics[identity])) {
    stop("Each component must have one metric row per replicate and cell.",
         call. = FALSE)
  }
  groups <- mfrmr_gas_group_rows(replicate_metrics, keys)
  rows <- lapply(groups, function(index) {
    rmse <- mfrmr_gas_mc_interval(replicate_metrics$RMSE[index])
    mae <- mfrmr_gas_mc_interval(replicate_metrics$MAE[index])
    data.frame(
      replicate_metrics[index[1L], keys, drop = FALSE],
      Replicates = as.integer(rmse[["Replicates"]]),
      MeanRMSE = rmse[["Mean"]],
      SDRMSE = rmse[["SD"]],
      MCSERMSE = rmse[["MCSE"]],
      Lower95RMSE = rmse[["Lower95"]],
      Upper95RMSE = rmse[["Upper95"]],
      MeanMAE = mae[["Mean"]],
      MCSEMAE = mae[["MCSE"]],
      stringsAsFactors = FALSE
    )
  })
  mfrmr_gas_bind(rows)
}

mfrmr_gas_endpoint_contrasts <- function(replicate_metrics, membership) {
  if (!is.data.frame(replicate_metrics) || nrow(replicate_metrics) == 0L) {
    return(data.frame())
  }
  required_membership <- c("CellId", "Sequence", "XName", "XValue")
  missing <- setdiff(required_membership, names(membership))
  if (length(missing) > 0L) {
    stop("Sequence columns are missing: ", paste(missing, collapse = ", "),
         call. = FALSE)
  }
  pair_keys <- c("Replicate", "Method", "Component")
  rows <- list()
  for (sequence in unique(membership$Sequence)) {
    sequence_rows <- membership[membership$Sequence == sequence, , drop = FALSE]
    sequence_rows <- sequence_rows[order(sequence_rows$XValue), , drop = FALSE]
    low <- sequence_rows[1L, , drop = FALSE]
    high <- sequence_rows[nrow(sequence_rows), , drop = FALSE]
    low_metrics <- replicate_metrics[
      replicate_metrics$CellId == low$CellId, , drop = FALSE
    ]
    high_metrics <- replicate_metrics[
      replicate_metrics$CellId == high$CellId, , drop = FALSE
    ]
    if (anyDuplicated(low_metrics[pair_keys]) ||
        anyDuplicated(high_metrics[pair_keys])) {
      stop("Endpoint metrics must be unique by replicate, method, and component.",
           call. = FALSE)
    }
    paired <- merge(
      low_metrics[, c(pair_keys, "RMSE", "MAE"), drop = FALSE],
      high_metrics[, c(pair_keys, "RMSE", "MAE"), drop = FALSE],
      by = pair_keys, suffixes = c("Low", "High"), sort = FALSE
    )
    if (nrow(paired) != nrow(low_metrics) || nrow(paired) != nrow(high_metrics)) {
      stop("Endpoint contrasts require exactly matched replicate metrics.",
           call. = FALSE)
    }
    paired$RMSEDifference <- paired$RMSEHigh - paired$RMSELow
    paired$MAEDifference <- paired$MAEHigh - paired$MAELow
    groups <- mfrmr_gas_group_rows(paired, c("Method", "Component"))
    sequence_summary <- lapply(groups, function(index) {
      rmse <- mfrmr_gas_mc_interval(paired$RMSEDifference[index])
      mae <- mfrmr_gas_mc_interval(paired$MAEDifference[index])
      data.frame(
        Sequence = as.character(sequence),
        XName = as.character(low$XName),
        LowCell = as.character(low$CellId),
        HighCell = as.character(high$CellId),
        LowX = as.numeric(low$XValue),
        HighX = as.numeric(high$XValue),
        Method = as.character(paired$Method[index[1L]]),
        Component = as.character(paired$Component[index[1L]]),
        Replicates = as.integer(rmse[["Replicates"]]),
        MeanRMSEDifference = rmse[["Mean"]],
        MCSERMSEDifference = rmse[["MCSE"]],
        Lower95RMSEDifference = rmse[["Lower95"]],
        Upper95RMSEDifference = rmse[["Upper95"]],
        RMSEImprovementRate = mean(paired$RMSEDifference[index] < 0),
        MeanMAEDifference = mae[["Mean"]],
        stringsAsFactors = FALSE
      )
    })
    rows <- c(rows, sequence_summary)
  }
  mfrmr_gas_bind(rows)
}

mfrmr_gas_method_contrasts <- function(replicate_metrics) {
  if (!is.data.frame(replicate_metrics) || nrow(replicate_metrics) == 0L) {
    return(data.frame())
  }
  methods <- unique(as.character(replicate_metrics$Method))
  if (!setequal(methods, c("JML", "MML"))) {
    stop("Method contrasts require matched JML and MML metrics.",
         call. = FALSE)
  }
  pair_keys <- c(
    "Replicate", "CellId", "NPersons", "ObservationsPerPerson", "Component"
  )
  jml <- replicate_metrics[replicate_metrics$Method == "JML", , drop = FALSE]
  mml <- replicate_metrics[replicate_metrics$Method == "MML", , drop = FALSE]
  shared_components <- intersect(unique(jml$Component), unique(mml$Component))
  jml <- jml[jml$Component %in% shared_components, , drop = FALSE]
  mml <- mml[mml$Component %in% shared_components, , drop = FALSE]
  if (length(shared_components) == 0L) return(data.frame())
  if (anyDuplicated(jml[pair_keys]) || anyDuplicated(mml[pair_keys])) {
    stop("Method metrics must be unique within each replicate and cell.",
         call. = FALSE)
  }
  paired <- merge(
    jml[, c(pair_keys, "RMSE", "MAE"), drop = FALSE],
    mml[, c(pair_keys, "RMSE", "MAE"), drop = FALSE],
    by = pair_keys, suffixes = c("JML", "MML"), sort = FALSE
  )
  if (nrow(paired) != nrow(jml) || nrow(paired) != nrow(mml)) {
    stop("Method contrasts require exactly matched JML and MML metrics.",
         call. = FALSE)
  }
  paired$RMSEDifference <- paired$RMSEJML - paired$RMSEMML
  paired$MAEDifference <- paired$MAEJML - paired$MAEMML
  group_keys <- c(
    "CellId", "NPersons", "ObservationsPerPerson", "Component"
  )
  groups <- mfrmr_gas_group_rows(paired, group_keys)
  rows <- lapply(groups, function(index) {
    rmse <- mfrmr_gas_mc_interval(paired$RMSEDifference[index])
    mae <- mfrmr_gas_mc_interval(paired$MAEDifference[index])
    data.frame(
      paired[index[1L], group_keys, drop = FALSE],
      Contrast = "JML_minus_MML",
      Replicates = as.integer(rmse[["Replicates"]]),
      MeanRMSEDifference = rmse[["Mean"]],
      MCSERMSEDifference = rmse[["MCSE"]],
      Lower95RMSEDifference = rmse[["Lower95"]],
      Upper95RMSEDifference = rmse[["Upper95"]],
      MMLLowerRMSERate = mean(paired$RMSEDifference[index] > 0),
      MeanMAEDifference = mae[["Mean"]],
      stringsAsFactors = FALSE
    )
  })
  mfrmr_gas_bind(rows)
}

mfrmr_gas_coordinate_mc <- function(data, keys, error_column) {
  if (!is.data.frame(data) || nrow(data) == 0L) return(data.frame())
  missing <- setdiff(c("Replicate", keys, error_column), names(data))
  if (length(missing) > 0L) {
    stop("Coordinate columns are missing: ", paste(missing, collapse = ", "),
         call. = FALSE)
  }
  identity <- c("Replicate", keys)
  if (anyDuplicated(data[identity])) {
    stop("Each coordinate must occur once per replicate and cell.",
         call. = FALSE)
  }
  error <- as.numeric(data[[error_column]])
  if (any(!is.finite(error))) {
    stop("Coordinate summaries require finite recovery errors.",
         call. = FALSE)
  }
  groups <- mfrmr_gas_group_rows(data, keys)
  rows <- lapply(groups, function(index) {
    signed <- mfrmr_gas_mc_interval(error[index])
    data.frame(
      data[index[1L], keys, drop = FALSE],
      Replicates = as.integer(signed[["Replicates"]]),
      MeanError = signed[["Mean"]],
      SDError = signed[["SD"]],
      MCSEMeanError = signed[["MCSE"]],
      Lower95MeanError = signed[["Lower95"]],
      Upper95MeanError = signed[["Upper95"]],
      MAE = mean(abs(error[index])),
      RMSE = sqrt(mean(error[index]^2)),
      stringsAsFactors = FALSE
    )
  })
  mfrmr_gas_bind(rows)
}

mfrmr_gas_aggregate <- function(data, keys, error_column = NULL) {
  if (!is.data.frame(data) || nrow(data) == 0L) return(data.frame())
  groups <- split(seq_len(nrow(data)), interaction(data[keys], drop = TRUE))
  rows <- lapply(groups, function(index) {
    out <- data[index[1L], keys, drop = FALSE]
    out$Rows <- length(index)
    out$Replicates <- length(unique(data$Replicate[index]))
    if (!is.null(error_column)) {
      error <- data[[error_column]][index]
      out$MAE <- mfrmr_gas_safe_mean(abs(error))
      out$RMSE <- mfrmr_gas_safe_rmse(error)
      if ("InferenceEligible" %in% names(data)) {
        out$InferenceEligibleRate <- mean(
          as.logical(data$InferenceEligible[index]), na.rm = TRUE
        )
      }
    }
    out
  })
  mfrmr_gas_bind(rows)
}

mfrmr_gas_summarize <- function(result) {
  if (!inherits(result, "mfrmr_gpcm_estimator_asymptotics")) {
    stop("`result` must come from the executed asymptotics diagnostic.",
         call. = FALSE)
  }
  membership <- result$sequence_membership
  status <- merge(membership, result$status, by = "CellId", sort = FALSE)
  status_summary <- data.frame()
  if (nrow(status) > 0L) {
    groups <- split(seq_len(nrow(status)), interaction(
      status[c("Sequence", "XName", "XValue", "Method")], drop = TRUE
    ))
    rates <- lapply(groups, function(index) {
      data.frame(
        status[index[1L], c("Sequence", "XName", "XValue", "Method"),
               drop = FALSE],
        FitReturnRate = mean(status$FitReturned[index]),
        ConvergenceRate = mean(status$EstimationConverged[index]),
        InferenceReadyRate = mean(status$InferenceReady[index]),
        ExtremePersonMean = mfrmr_gas_safe_mean(status$ExtremePersons[index]),
        stringsAsFactors = FALSE
      )
    })
    status_summary <- mfrmr_gas_bind(rates)
  }

  recovery_summary <- data.frame()
  if (nrow(result$recovery) > 0L) {
    recovery <- merge(membership, result$recovery,
                      by = "CellId", sort = FALSE)
    recovery_summary <- mfrmr_gas_aggregate(
      recovery,
      c("Sequence", "XName", "XValue", "Method", "ParameterType", "Facet"),
      error_column = "ErrorAligned"
    )
  }
  slope_summary <- data.frame()
  slope_replicate <- data.frame()
  slope_component_mc <- data.frame()
  slope_coordinate_mc <- data.frame()
  slope_endpoint_contrasts <- data.frame()
  slope_method_contrasts <- data.frame()
  if (nrow(result$slope_optimizer_trace) > 0L) {
    slope <- merge(membership, result$slope_optimizer_trace,
                   by = "CellId", sort = FALSE)
    slope_summary <- mfrmr_gas_aggregate(
      slope, c("Sequence", "XName", "XValue", "Method"),
      error_column = "Error"
    )
    slope_replicate <- mfrmr_gas_replicate_metrics(
      result$slope_optimizer_trace,
      error_column = "Error",
      component = rep("optimizer_log_slope", nrow(result$slope_optimizer_trace))
    )
    slope_component_mc <- mfrmr_gas_component_mc(slope_replicate)
    slope_endpoint_contrasts <- mfrmr_gas_endpoint_contrasts(
      slope_replicate, membership
    )
    slope_method_contrasts <- mfrmr_gas_method_contrasts(slope_replicate)
    slope_coordinate_mc <- mfrmr_gas_coordinate_mc(
      result$slope_optimizer_trace,
      keys = c(
        "CellId", "NPersons", "ObservationsPerPerson", "Method", "SlopeFacet"
      ),
      error_column = "Error"
    )
  }

  recovery_replicate <- data.frame()
  recovery_component_mc <- data.frame()
  recovery_coordinate_mc <- data.frame()
  recovery_endpoint_contrasts <- data.frame()
  recovery_method_contrasts <- data.frame()
  if (nrow(result$recovery) > 0L) {
    component <- ifelse(
      result$recovery$ParameterType == "facet",
      paste0("facet_", tolower(result$recovery$Facet)),
      ifelse(
        result$recovery$ParameterType == "population",
        paste0("population_", result$recovery$Subparameter),
        as.character(result$recovery$ParameterType)
      )
    )
    recovery_replicate <- mfrmr_gas_replicate_metrics(
      result$recovery, error_column = "ErrorAligned", component = component
    )
    recovery_component_mc <- mfrmr_gas_component_mc(recovery_replicate)
    recovery_endpoint_contrasts <- mfrmr_gas_endpoint_contrasts(
      recovery_replicate, membership
    )
    recovery_method_contrasts <- mfrmr_gas_method_contrasts(
      recovery_replicate
    )
    recovery_coordinate_mc <- mfrmr_gas_coordinate_mc(
      result$recovery,
      keys = c(
        "CellId", "NPersons", "ObservationsPerPerson", "Method",
        "ParameterType", "Facet", "Level", "Subparameter"
      ),
      error_column = "ErrorAligned"
    )
  }
  profile <- unique(as.character(result$manifest$Profile))
  interpretation <- if (identical(profile, "pilot")) {
    paste(
      "The replicated pilot estimates numerical recovery trends and Monte",
      "Carlo uncertainty but had no prespecified estimator-selection rule.",
      "Finite optimizer slope traces remain inferentially ineligible, and a",
      "separate confirmation design is required for a release decision."
    )
  } else {
    paste(
      "Directional smoke results do not establish an incidental-bias limit.",
      "Only a prespecified replicated pilot may compare trends, and finite",
      "optimizer slope traces remain inferentially ineligible."
    )
  }
  list(
    status = status_summary,
    recovery = recovery_summary,
    slope_optimizer_trace = slope_summary,
    recovery_replicate = recovery_replicate,
    recovery_component_mc = recovery_component_mc,
    recovery_coordinate_mc = recovery_coordinate_mc,
    recovery_endpoint_contrasts = recovery_endpoint_contrasts,
    recovery_method_contrasts = recovery_method_contrasts,
    slope_replicate = slope_replicate,
    slope_component_mc = slope_component_mc,
    slope_coordinate_mc = slope_coordinate_mc,
    slope_endpoint_contrasts = slope_endpoint_contrasts,
    slope_method_contrasts = slope_method_contrasts,
    decisions = result$decisions,
    interpretation = interpretation
  )
}
