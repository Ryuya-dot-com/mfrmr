# Repository-only FACETS RSM/PCM stress envelope for already-open pilot seeds.
#
# The envelope separates capacity, sparse topology, and facet-count growth.
# It records truth recovery and paired coordinates without using file hashes,
# opening confirmation seeds, or authorizing a FACETS replacement claim.

mfrmr_facets_mfs_contract_id <-
  "mfrmr_facets_rsm_pcm_stress_envelope_v1"

mfrmr_facets_mfs_registry <- function() {
  data.frame(
    ScenarioId = c(
      "MFS-LARGE-F5",
      "MFS-SPARSE-DISTRIBUTED-F5",
      "MFS-SPARSE-WEAK-BRIDGE-F5",
      "MFS-DISCONNECTED-F5",
      "MFS-MANY-F10",
      "MFS-MANY-F30"
    ),
    StressAxis = c(
      "capacity", "sparse_topology", "sparse_topology",
      "negative_control", "facet_count", "facet_count"
    ),
    TotalFacets = c(5L, 5L, 5L, 5L, 10L, 30L),
    Persons = c(1000L, 1000L, 1000L, 1000L, 200L, 200L),
    RowsPerPerson = c(40L, 10L, 10L, 10L, 32L, 64L),
    TargetRows = c(40000L, 10000L, 10000L, 10000L, 6400L, 12800L),
    RaterLevels = c(20L, 20L, 20L, 20L, 8L, 8L),
    CriterionLevels = c(10L, 10L, 10L, 10L, 6L, 6L),
    Topology = c(
      "balanced_capacity", "distributed_ring", "two_blocks_six_bridge_persons",
      "two_disconnected_person_rater_components", "balanced_random",
      "balanced_random"
    ),
    ExpectedState = c(
      rep("comparison_eligible_if_both_numerical_gates_pass", 3L),
      "must_not_be_comparison_eligible", rep(
        "comparison_eligible_if_both_numerical_gates_pass", 2L
      )
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_facets_mfs_validate_registry <- function(
    registry = mfrmr_facets_mfs_registry()) {
  required <- c(
    "ScenarioId", "StressAxis", "TotalFacets", "Persons",
    "RowsPerPerson", "TargetRows", "RaterLevels", "CriterionLevels",
    "Topology", "ExpectedState"
  )
  missing <- setdiff(required, names(registry))
  if (length(missing)) {
    stop("FACETS stress registry is missing: ", paste(missing, collapse = ", "),
         ".", call. = FALSE)
  }
  checks <- c(
    nrow(registry) == 6L,
    !anyDuplicated(registry$ScenarioId),
    all(registry$TargetRows == registry$Persons * registry$RowsPerPerson),
    identical(sort(unique(registry$TotalFacets)), c(5L, 10L, 30L)),
    all(registry$TotalFacets >= 3L),
    all(registry$Persons > 0L),
    all(registry$RowsPerPerson > 0L),
    sum(registry$ExpectedState == "must_not_be_comparison_eligible") == 1L
  )
  if (!all(checks)) {
    stop("FACETS stress registry failed its structural contract.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_facets_mfs_require_support <- function() {
  required <- c(
    "mfrmr_facets_mfx_allowed_pilot_seeds",
    "mfrmr_facets_mfx_report_version",
    "mfrmr_run_facets_mfp_external_pilot",
    "mfrmr_facets_mfp_capture",
    "mfrmr_facets_mfp_fit_telemetry"
  )
  support_env <- environment()
  missing <- required[!vapply(required, exists, logical(1), envir = support_env,
                              mode = "function", inherits = TRUE)]
  if (length(missing)) {
    stop(
      "FACETS stress support is missing: source the precision contract and ",
      "pilot adapter first (", paste(missing, collapse = ", "), ").",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_facets_mfs_validate_request <- function(
    base_seed, scenario_ids = mfrmr_facets_mfs_registry()$ScenarioId,
    models = c("RSM", "PCM")) {
  mfrmr_facets_mfs_require_support()
  valid_seed <- is.numeric(base_seed) && length(base_seed) == 1L &&
    !is.na(base_seed) && is.finite(base_seed) && base_seed == floor(base_seed)
  if (!valid_seed || !as.integer(base_seed) %in%
      mfrmr_facets_mfx_allowed_pilot_seeds()) {
    stop(
      "`base_seed` must be an already-open pilot seed; confirmation seeds ",
      "are not permitted.", call. = FALSE
    )
  }
  registry <- mfrmr_facets_mfs_registry()
  valid_scenarios <- is.character(scenario_ids) && length(scenario_ids) > 0L &&
    !anyNA(scenario_ids) && all(scenario_ids %in% registry$ScenarioId) &&
    !anyDuplicated(scenario_ids)
  if (!valid_scenarios) {
    stop("`scenario_ids` must be unique registered stress scenarios.",
         call. = FALSE)
  }
  valid_models <- is.character(models) && length(models) > 0L &&
    !anyNA(models) && all(models %in% c("RSM", "PCM")) &&
    !anyDuplicated(models)
  if (!valid_models) {
    stop("`models` must contain unique values from RSM and PCM.",
         call. = FALSE)
  }
  list(
    base_seed = as.integer(base_seed),
    registry = registry[match(scenario_ids, registry$ScenarioId), , drop = FALSE],
    models = models
  )
}

mfrmr_facets_mfs_facet_levels <- function(registry_row) {
  total <- as.integer(registry_row$TotalFacets)
  extra_count <- total - 3L
  extra_names <- if (extra_count > 0L) {
    sprintf("Aux%02d", seq.int(3L, length.out = extra_count))
  } else character(0)
  facet_names <- c("Rater", extra_names, "Criterion")
  levels <- c(
    list(Rater = sprintf("R%02d", seq_len(registry_row$RaterLevels))),
    stats::setNames(
      lapply(extra_names, function(x) c("L1", "L2")), extra_names
    ),
    list(Criterion = sprintf(
      "C%02d", seq_len(registry_row$CriterionLevels)
    ))
  )
  list(names = facet_names, levels = levels)
}

mfrmr_facets_mfs_rater_cycle <- function(
    scenario_id, person_index, rater_levels, rows_per_person, persons) {
  all_raters <- seq_len(rater_levels)
  if (identical(scenario_id, "MFS-LARGE-F5")) {
    pool <- all_raters
  } else if (scenario_id %in% c(
      "MFS-SPARSE-WEAK-BRIDGE-F5", "MFS-DISCONNECTED-F5")) {
    half_raters <- rater_levels %/% 2L
    first_group <- person_index <= persons %/% 2L
    group_start <- if (first_group) 1L else half_raters + 1L
    local_index <- (person_index - 1L) %% half_raters
    pool <- group_start - 1L + c(
      local_index %% half_raters + 1L,
      (local_index + 1L) %% half_raters + 1L
    )
    bridge_people <- seq.int(persons %/% 2L - 2L, persons %/% 2L + 3L)
    if (identical(scenario_id, "MFS-SPARSE-WEAK-BRIDGE-F5") &&
        person_index %in% bridge_people) {
      opposite <- if (first_group) pool[1L] + half_raters else
        pool[1L] - half_raters
      pool <- c(pool, opposite)
    }
  } else if (identical(scenario_id, "MFS-SPARSE-DISTRIBUTED-F5")) {
    first <- (person_index - 1L) %% rater_levels + 1L
    pool <- c(first, first %% rater_levels + 1L)
  } else {
    first <- (2L * person_index - 2L) %% rater_levels + 1L
    pool <- ((first - 1L + 0:3) %% rater_levels) + 1L
  }
  rep(pool, length.out = rows_per_person)
}

mfrmr_facets_mfs_person_rows <- function(
    registry_row, facet_spec, person_index) {
  rows <- as.integer(registry_row$RowsPerPerson)
  person <- sprintf("P%04d", person_index)
  out <- data.frame(Person = rep(person, rows), stringsAsFactors = FALSE)
  rater_codes <- mfrmr_facets_mfs_rater_cycle(
    registry_row$ScenarioId, person_index, registry_row$RaterLevels,
    rows, registry_row$Persons
  )
  out$Rater <- facet_spec$levels$Rater[sample(rater_codes, rows)]
  other_facets <- setdiff(facet_spec$names, "Rater")
  for (facet in other_facets) {
    values <- facet_spec$levels[[facet]]
    out[[facet]] <- sample(rep(values, length.out = rows), rows)
  }
  key_fields <- c("Rater", other_facets)
  key <- do.call(paste, c(out[key_fields], sep = "\r"))
  attempt <- 0L
  while (anyDuplicated(key) && attempt < 100L) {
    attempt <- attempt + 1L
    for (facet in other_facets) {
      values <- facet_spec$levels[[facet]]
      out[[facet]] <- sample(rep(values, length.out = rows), rows)
    }
    key <- do.call(paste, c(out[key_fields], sep = "\r"))
  }
  if (anyDuplicated(key)) {
    stop("Could not construct unique stress cells for ", person, ".",
         call. = FALSE)
  }
  out
}

mfrmr_facets_mfs_design <- function(
    scenario_id, model = c("RSM", "PCM"), seed) {
  model <- match.arg(model)
  registry <- mfrmr_facets_mfs_registry()
  matched <- match(scenario_id, registry$ScenarioId)
  if (is.na(matched)) stop("Unknown FACETS stress scenario.", call. = FALSE)
  scenario <- registry[matched, , drop = FALSE]
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (had_seed) {
    old_seed <- get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  }
  on.exit({
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)
  set.seed(as.integer(seed))
  facet_spec <- mfrmr_facets_mfs_facet_levels(scenario)
  person_rows <- lapply(seq_len(scenario$Persons), function(person_index) {
    mfrmr_facets_mfs_person_rows(scenario, facet_spec, person_index)
  })
  data <- do.call(rbind, person_rows)
  row.names(data) <- NULL

  persons <- unique(data$Person)
  truth <- list(Person = stats::setNames(
    stats::rnorm(length(persons), 0, 0.9), persons
  ))
  for (facet in facet_spec$names) {
    levels <- facet_spec$levels[[facet]]
    span <- if (identical(facet, "Rater")) 0.75 else if (
      identical(facet, "Criterion")
    ) 0.45 else 0.15
    truth[[facet]] <- stats::setNames(
      seq(-span, span, length.out = length(levels)), levels
    )
  }
  eta <- truth$Person[data$Person]
  for (facet in facet_spec$names) {
    eta <- eta - truth[[facet]][data[[facet]]]
  }
  base_steps <- c(-0.8, 0, 0.8)
  criterion_shift <- stats::setNames(
    seq(-0.18, 0.18, length.out = length(facet_spec$levels$Criterion)),
    facet_spec$levels$Criterion
  )
  step_matrix <- t(vapply(data$Criterion, function(criterion) {
    if (identical(model, "RSM")) return(base_steps)
    steps <- base_steps + c(-1, 0, 1) * criterion_shift[criterion]
    steps - mean(steps)
  }, numeric(3)))
  log_numerator <- cbind(
    0,
    eta - step_matrix[, 1L],
    2 * eta - rowSums(step_matrix[, 1:2, drop = FALSE]),
    3 * eta - rowSums(step_matrix)
  )
  row_max <- apply(log_numerator, 1L, max)
  numerator <- exp(log_numerator - row_max)
  probability <- numerator / rowSums(numerator)
  cumulative <- t(apply(probability, 1L, cumsum))
  draw <- stats::runif(nrow(data))
  data$Score <- as.integer(rowSums(draw > cumulative))
  if (!identical(sort(unique(data$Score)), 0:3)) {
    stop("Stress design did not realize every score category.", call. = FALSE)
  }
  truth$Steps <- if (identical(model, "RSM")) {
    data.frame(
      StepFacet = "Common", Step = paste0("Step_", 1:3),
      Estimate = base_steps, stringsAsFactors = FALSE
    )
  } else {
    do.call(rbind, lapply(facet_spec$levels$Criterion, function(criterion) {
      steps <- base_steps + c(-1, 0, 1) * criterion_shift[criterion]
      steps <- steps - mean(steps)
      data.frame(
        StepFacet = criterion, Step = paste0("Step_", 1:3),
        Estimate = steps, stringsAsFactors = FALSE
      )
    }))
  }
  list(
    data = data[, c("Person", facet_spec$names, "Score"), drop = FALSE],
    truth = truth,
    facet_names = facet_spec$names,
    model = model,
    total_facets = as.integer(scenario$TotalFacets),
    seed = as.integer(seed),
    scenario_id = scenario_id
  )
}

mfrmr_facets_mfs_truth_table <- function(design, kind = c("element", "step")) {
  kind <- match.arg(kind)
  if (identical(kind, "step")) {
    out <- as.data.frame(design$truth$Steps, stringsAsFactors = FALSE)
    names(out)[names(out) == "Estimate"] <- "TrueValue"
    return(out)
  }
  facets <- c("Person", design$facet_names)
  do.call(rbind, lapply(facets, function(facet) {
    values <- design$truth[[facet]]
    data.frame(
      Facet = facet, Level = names(values), TrueValue = as.numeric(values),
      stringsAsFactors = FALSE
    )
  }))
}

mfrmr_facets_mfs_recovery_rows <- function(
    coordinates, design, kind = c("element", "step")) {
  kind <- match.arg(kind)
  if (!is.data.frame(coordinates) || !nrow(coordinates)) return(data.frame())
  truth <- mfrmr_facets_mfs_truth_table(design, kind)
  keys <- if (identical(kind, "element")) c("Facet", "Level") else
    c("StepFacet", "Step")
  matched <- merge(coordinates, truth, by = keys, all.x = TRUE, sort = FALSE)
  if (anyNA(matched$TrueValue) || nrow(matched) != nrow(coordinates)) {
    stop("Stress truth coordinates do not match the paired estimates.",
         call. = FALSE)
  }
  parameter_block <- if (identical(kind, "element")) matched$Facet else "Step"
  parameter_id <- if (identical(kind, "element")) {
    paste(matched$Facet, matched$Level, sep = "::")
  } else {
    paste(matched$StepFacet, matched$Step, sep = "::")
  }
  engines <- c(mfrmr = "MfrmrEstimate", FACETS = "FACETSEstimate")
  do.call(rbind, lapply(names(engines), function(engine) {
    estimate <- as.numeric(matched[[engines[[engine]]]])
    data.frame(
      ScenarioId = design$scenario_id,
      Model = design$model,
      Engine = engine,
      ParameterClass = if (identical(kind, "element")) "Element" else "Step",
      ParameterBlock = parameter_block,
      ParameterId = parameter_id,
      TrueValue = matched$TrueValue,
      Estimate = estimate,
      Error = estimate - matched$TrueValue,
      RecoveryEligible = TRUE,
      stringsAsFactors = FALSE
    )
  }))
}

mfrmr_facets_mfs_summarize_recovery <- function(recovery) {
  if (!is.data.frame(recovery) || !nrow(recovery)) return(data.frame())
  groups <- split(
    recovery,
    interaction(
      recovery$ScenarioId, recovery$Model, recovery$Engine,
      recovery$ParameterClass, recovery$ParameterBlock,
      drop = TRUE, lex.order = TRUE
    )
  )
  out <- do.call(rbind, lapply(groups, function(x) {
    finite <- is.finite(x$TrueValue) & is.finite(x$Estimate) &
      is.finite(x$Error)
    data.frame(
      ScenarioId = x$ScenarioId[1L], Model = x$Model[1L],
      Engine = x$Engine[1L], ParameterClass = x$ParameterClass[1L],
      ParameterBlock = x$ParameterBlock[1L], N = nrow(x),
      FiniteN = sum(finite),
      RecoveryEligibleN = sum(finite & x$RecoveryEligible),
      Bias = if (any(finite)) mean(x$Error[finite]) else NA_real_,
      MAE = if (any(finite)) mean(abs(x$Error[finite])) else NA_real_,
      RMSE = if (any(finite)) sqrt(mean(x$Error[finite]^2)) else NA_real_,
      stringsAsFactors = FALSE
    )
  }))
  row.names(out) <- NULL
  out
}

mfrmr_facets_mfs_internal_recovery <- function(fit, design, eligible) {
  person <- as.data.frame(fit$facets$person, stringsAsFactors = FALSE)
  person_status <- if ("ParameterStatus" %in% names(person)) {
    as.character(person$ParameterStatus)
  } else rep("estimable", nrow(person))
  element <- rbind(
    data.frame(
      Facet = "Person", Level = as.character(person$Person),
      Estimate = as.numeric(person$Estimate), Status = person_status,
      stringsAsFactors = FALSE
    ),
    transform(
      as.data.frame(fit$facets$others, stringsAsFactors = FALSE),
      Facet = as.character(Facet), Level = as.character(Level),
      Estimate = as.numeric(Estimate), Status = "estimable"
    )[, c("Facet", "Level", "Estimate", "Status"), drop = FALSE]
  )
  element_truth <- mfrmr_facets_mfs_truth_table(design, "element")
  element <- merge(
    element, element_truth, by = c("Facet", "Level"), all.x = TRUE,
    sort = FALSE
  )
  if (anyNA(element$TrueValue) || nrow(element) != nrow(element_truth)) {
    stop("mfrmr stress element estimates do not match truth coordinates.",
         call. = FALSE)
  }
  element_rows <- data.frame(
    ScenarioId = design$scenario_id, Model = design$model, Engine = "mfrmr",
    ParameterClass = "Element", ParameterBlock = element$Facet,
    ParameterId = paste(element$Facet, element$Level, sep = "::"),
    TrueValue = element$TrueValue, Estimate = element$Estimate,
    Error = element$Estimate - element$TrueValue,
    RecoveryEligible = isTRUE(eligible) & element$Status == "estimable" &
      is.finite(element$Estimate), stringsAsFactors = FALSE
  )

  step <- as.data.frame(fit$steps, stringsAsFactors = FALSE)
  if (!"StepFacet" %in% names(step)) step$StepFacet <- "Common"
  step_truth <- mfrmr_facets_mfs_truth_table(design, "step")
  step <- merge(
    step, step_truth, by = c("StepFacet", "Step"), all.x = TRUE,
    sort = FALSE
  )
  if (anyNA(step$TrueValue) || nrow(step) != nrow(step_truth)) {
    stop("mfrmr stress step estimates do not match truth coordinates.",
         call. = FALSE)
  }
  step_rows <- data.frame(
    ScenarioId = design$scenario_id, Model = design$model, Engine = "mfrmr",
    ParameterClass = "Step", ParameterBlock = "Step",
    ParameterId = paste(step$StepFacet, step$Step, sep = "::"),
    TrueValue = step$TrueValue, Estimate = as.numeric(step$Estimate),
    Error = as.numeric(step$Estimate) - step$TrueValue,
    RecoveryEligible = isTRUE(eligible) & is.finite(step$Estimate),
    stringsAsFactors = FALSE
  )
  rbind(element_rows, step_rows)
}

mfrmr_facets_mfs_fit_mfrmr <- function(design, maxit = 400L,
                                        existing_fit = NULL) {
  independently_attempted <- is.null(existing_fit)
  captured <- if (independently_attempted) {
    args <- list(
      data = design$data, person = "Person", facets = design$facet_names,
      score = "Score", rating_min = 0L, rating_max = 3L,
      model = design$model, method = "JML", maxit = as.integer(maxit)
    )
    if (identical(design$model, "PCM")) args$step_facet <- "Criterion"
    mfrmr_facets_mfp_capture(
      do.call(getExportedValue("mfrmr", "fit_mfrm"), args)
    )
  } else {
    list(
      value = existing_fit, error = NA_character_, error_class = character(0),
      warnings = character(0)
    )
  }
  if (is.null(captured$value)) {
    return(list(
      fit = NULL, fit_returned = FALSE, numerical_gate_passed = FALSE,
      convergence_code = NA_integer_, estimation_converged = FALSE,
      terminal_gradient = NA_real_, gradient_tolerance = NA_real_,
      error = captured$error,
      error_class = paste(captured$error_class, collapse = ";"),
      warnings = captured$warnings,
      independently_attempted = independently_attempted,
      recovery = data.frame()
    ))
  }
  telemetry <- mfrmr_facets_mfp_fit_telemetry(captured$value)
  gate <- isTRUE(telemetry$NumericalGatePassed)
  list(
    fit = captured$value, fit_returned = TRUE,
    numerical_gate_passed = gate,
    convergence_code = telemetry$ConvergenceCode,
    estimation_converged = telemetry$EstimationConverged,
    terminal_gradient = telemetry$TerminalGradientSupNorm,
    gradient_tolerance = telemetry$GradientReviewTolerance,
    error = NA_character_, error_class = NA_character_,
    warnings = captured$warnings,
    independently_attempted = independently_attempted,
    recovery = mfrmr_facets_mfs_internal_recovery(
      captured$value, design, gate
    )
  )
}

# Diagnose a retained RSM/PCM JML point without changing fit readiness. The
# free-coordinate gradient is the optimizer quantity; the expanded element
# score residuals retain the observed-minus-expected score scale. They answer
# different questions and must not be treated as interchangeable thresholds.
mfrmr_facets_mfs_jml_context <- function(fit) {
  if (!inherits(fit, "mfrm_fit") || !is.list(fit$config) ||
      !is.list(fit$prep) || !is.list(fit$opt)) {
    stop("`fit` must be a complete mfrm_fit object.", call. = FALSE)
  }
  config <- fit$config
  if (!identical(config$method, "JML") ||
      !config$model %in% c("RSM", "PCM")) {
    stop("The stress stationarity audit requires an RSM or PCM JML fit.",
         call. = FALSE)
  }
  namespace <- asNamespace("mfrmr")
  internal <- function(name) get(name, envir = namespace, inherits = FALSE)
  build_indices <- internal("build_indices")
  build_param_sizes <- internal("build_param_sizes")
  objective_function <- internal("mfrm_loglik_jml")
  gradient_function <- internal("mfrm_grad_jml")
  idx <- build_indices(
    fit$prep, step_facet = config$step_facet,
    slope_facet = config$slope_facet,
    interaction_specs = config$interaction_specs
  )
  sizes <- build_param_sizes(config)
  size_values <- vapply(sizes, as.integer, integer(1))
  par <- as.numeric(fit$opt$par)
  if (length(par) != sum(size_values) || any(!is.finite(par))) {
    stop("The retained optimizer vector does not match the model dimensions.",
         call. = FALSE)
  }
  objective <- function(candidate) {
    as.numeric(objective_function(candidate, idx, config, sizes))[1L]
  }
  gradient <- function(candidate) {
    as.numeric(gradient_function(candidate, idx, config, sizes))
  }
  retained_objective <- objective(par)
  stored_objective <- as.numeric(fit$opt$value)[1L]
  retained_gradient <- gradient(par)
  if (length(retained_gradient) != length(par) ||
      any(!is.finite(retained_gradient)) ||
      !is.finite(retained_objective) || !is.finite(stored_objective)) {
    stop("The retained objective or analytic gradient is not finite.",
         call. = FALSE)
  }
  list(
    fit = fit, config = config, idx = idx, sizes = sizes,
    size_values = size_values, par = par,
    block_labels = rep(names(size_values), size_values),
    objective_function = objective_function,
    gradient_function = gradient_function,
    constraint_jacobian = internal("constraint_jacobian"),
    expand_params = internal("expand_params"),
    compute_eta = internal("compute_eta"),
    probability_bundle = internal("compute_response_probability_bundle"),
    objective = objective, gradient = gradient,
    retained_objective = retained_objective,
    stored_objective = stored_objective,
    retained_gradient = retained_gradient
  )
}

mfrmr_facets_mfs_jml_stationarity_audit <- function(
    fit, max_numeric_probes = 12L, numeric_relative_step = 3e-5,
    curvature_relative_step = 1e-3,
    numeric_agreement_tolerance = 1e-6,
    replication_factors = c(1L, 2L, 10L)) {
  context <- mfrmr_facets_mfs_jml_context(fit)
  config <- context$config
  valid_probe_count <- is.numeric(max_numeric_probes) &&
    length(max_numeric_probes) == 1L && is.finite(max_numeric_probes) &&
    max_numeric_probes == floor(max_numeric_probes) && max_numeric_probes >= 1L
  controls <- c(
    numeric_relative_step, curvature_relative_step,
    numeric_agreement_tolerance
  )
  valid_replication <- is.numeric(replication_factors) &&
    length(replication_factors) > 0L && !anyNA(replication_factors) &&
    all(is.finite(replication_factors)) &&
    all(replication_factors == floor(replication_factors)) &&
    all(replication_factors >= 1L) && !anyDuplicated(replication_factors)
  if (!valid_probe_count || length(controls) != 3L ||
      any(!is.finite(controls)) || any(controls <= 0) ||
      !valid_replication) {
    stop("Stationarity-audit controls must be finite positive scalars.",
         call. = FALSE)
  }
  max_numeric_probes <- as.integer(max_numeric_probes)
  replication_factors <- as.integer(replication_factors)

  idx <- context$idx
  sizes <- context$sizes
  size_values <- context$size_values
  par <- context$par
  block_labels <- context$block_labels
  objective_function <- context$objective_function
  gradient_function <- context$gradient_function
  expand_params <- context$expand_params
  compute_eta <- context$compute_eta
  probability_bundle <- context$probability_bundle
  objective <- context$objective
  retained_objective <- context$retained_objective
  stored_objective <- context$stored_objective
  gradient <- context$retained_gradient

  block_indices <- split(seq_along(gradient), block_labels)
  free_gradient_blocks <- do.call(rbind, lapply(
    names(block_indices), function(block) {
      values <- gradient[block_indices[[block]]]
      data.frame(
        Block = block, FreeCoordinates = length(values),
        GradientSupNorm = max(abs(values)),
        GradientRMS = sqrt(mean(values^2)), stringsAsFactors = FALSE
      )
    }
  ))
  per_block_maximum <- vapply(block_indices, function(indices) {
    indices[which.max(abs(gradient[indices]))]
  }, integer(1))
  probe_order <- unique(c(
    per_block_maximum, order(abs(gradient), decreasing = TRUE)
  ))
  probe_indices <- probe_order[seq_len(min(
    length(probe_order), max_numeric_probes
  ))]
  numeric_probes <- do.call(rbind, lapply(probe_indices, function(index) {
    step <- numeric_relative_step * max(1, abs(par[index]))
    plus <- minus <- par
    plus[index] <- plus[index] + step
    minus[index] <- minus[index] - step
    numeric_gradient <- (objective(plus) - objective(minus)) / (2 * step)
    difference <- numeric_gradient - gradient[index]
    data.frame(
      OptimizerIndex = index, Block = block_labels[index],
      ParameterValue = par[index], Step = step,
      AnalyticGradient = gradient[index], NumericGradient = numeric_gradient,
      AbsoluteDifference = abs(difference),
      ScaledDifference = abs(difference) /
        max(1, abs(numeric_gradient), abs(gradient[index])),
      stringsAsFactors = FALSE
    )
  }))

  worst_index <- which.max(abs(gradient))
  curvature_step <- curvature_relative_step * max(1, abs(par[worst_index]))
  plus <- minus <- par
  plus[worst_index] <- plus[worst_index] + curvature_step
  minus[worst_index] <- minus[worst_index] - curvature_step
  local_curvature <- (
    objective(plus) - 2 * retained_objective + objective(minus)
  ) / curvature_step^2
  local_newton_step <- if (is.finite(local_curvature) &&
      local_curvature > 0) {
    -gradient[worst_index] / local_curvature
  } else {
    NA_real_
  }
  moved_objective <- NA_real_
  if (is.finite(local_newton_step)) {
    moved <- par
    moved[worst_index] <- moved[worst_index] + local_newton_step
    moved_objective <- objective(moved)
  }

  params <- expand_params(par, sizes, config)
  eta <- compute_eta(idx, params, config)
  response <- probability_bundle(config, idx, params, eta)
  row_weight <- if (is.null(idx$weight)) {
    rep(1, length(idx$score_k))
  } else {
    as.numeric(idx$weight)
  }
  row_score_residual <- (idx$score_k - response$expected_k) * row_weight
  element_rows <- function(block, ids, level_names) {
    score <- numeric(length(level_names))
    grouped <- rowsum(
      matrix(row_score_residual, ncol = 1L), ids, reorder = FALSE
    )
    score[as.integer(rownames(grouped))] <- as.numeric(grouped)
    observations <- tabulate(ids, nbins = length(level_names))
    grouped_weight <- rowsum(
      matrix(row_weight, ncol = 1L), ids, reorder = FALSE
    )
    weighted_observations <- numeric(length(level_names))
    weighted_observations[as.integer(rownames(grouped_weight))] <-
      as.numeric(grouped_weight)
    data.frame(
      ParameterBlock = block, ParameterId = as.character(level_names),
      Observations = observations,
      WeightedObservations = weighted_observations,
      ScoreResidual = score,
      MeanScoreResidual = score / weighted_observations,
      stringsAsFactors = FALSE
    )
  }
  expanded_element_residuals <- element_rows(
    "Person", idx$person, fit$prep$levels$Person
  )
  for (facet in config$facet_names) {
    expanded_element_residuals <- rbind(
      expanded_element_residuals,
      element_rows(
        facet, idx$facets[[facet]], fit$prep$levels[[facet]]
      )
    )
  }
  element_groups <- split(
    expanded_element_residuals,
    expanded_element_residuals$ParameterBlock
  )
  expanded_element_summary <- do.call(rbind, lapply(
    names(element_groups), function(block) {
      values <- element_groups[[block]]
      data.frame(
        ParameterBlock = block, Levels = nrow(values),
        ScoreResidualSupNorm = max(abs(values$ScoreResidual)),
        MeanScoreResidualSupNorm = max(abs(values$MeanScoreResidual)),
        stringsAsFactors = FALSE
      )
    }
  ))

  gradient_tolerance <- as.numeric(
    fit$summary$GradientReviewTolerance[1L]
  )
  terminal_gradient <- max(abs(gradient))
  objective_difference <- retained_objective - stored_objective
  objective_scale <- max(1, abs(retained_objective), abs(stored_objective))
  local_objective_improvement <- retained_objective - moved_objective
  replication_transport <- do.call(rbind, lapply(
    replication_factors, function(factor) {
      transported_idx <- idx
      transported_idx$weight <- row_weight * factor
      transported_objective <- as.numeric(objective_function(
        par, transported_idx, config, sizes
      ))[1L]
      transported_gradient <- as.numeric(gradient_function(
        par, transported_idx, config, sizes
      ))
      expected_objective <- retained_objective * factor
      expected_gradient <- gradient * factor
      transport_scale <- max(1, abs(expected_objective))
      data.frame(
        ReplicationFactor = factor,
        Objective = transported_objective,
        ExpectedObjective = expected_objective,
        ObjectiveScaledDifference =
          abs(transported_objective - expected_objective) / transport_scale,
        GradientSupNorm = max(abs(transported_gradient)),
        ExpectedGradientSupNorm = terminal_gradient * factor,
        GradientScaledDifference = max(
          abs(transported_gradient - expected_gradient)
        ) / max(1, max(abs(expected_gradient))),
        RawGradientGatePassed = is.finite(gradient_tolerance) &&
          max(abs(transported_gradient)) <= gradient_tolerance,
        SameMLESetByConstantScaling = TRUE,
        ReadinessChanged = FALSE,
        stringsAsFactors = FALSE
      )
    }
  ))
  # This checks two floating-point summation routes for an exact algebraic
  # scaling identity. It is an implementation tolerance, not a fit threshold.
  replication_transport_tolerance <- 1e-10
  replication_transport_agrees <- all(
    replication_transport$ObjectiveScaledDifference <=
      replication_transport_tolerance
  ) && all(
    replication_transport$GradientScaledDifference <=
      replication_transport_tolerance
  )
  out <- list(
    summary = data.frame(
      Model = config$model, Method = config$method,
      FreeCoordinates = length(par),
      RetainedObjective = retained_objective,
      StoredObjective = stored_objective,
      ObjectiveDifference = objective_difference,
      ObjectiveReconstructionAgrees =
        abs(objective_difference) <=
          100 * .Machine$double.eps * objective_scale,
      TerminalGradientSupNorm = terminal_gradient,
      GradientReviewTolerance = gradient_tolerance,
      CurrentGradientGatePassed = is.finite(gradient_tolerance) &&
        terminal_gradient <= gradient_tolerance,
      NumericGradientAgrees = all(
        numeric_probes$ScaledDifference <= numeric_agreement_tolerance
      ),
      ReplicationTransportAgrees = replication_transport_agrees,
      ReplicationTransportTolerance = replication_transport_tolerance,
      RawGradientGateStableAcrossRequestedReplication =
        length(unique(replication_transport$RawGradientGatePassed)) == 1L,
      WorstGradientIndex = worst_index,
      WorstGradientBlock = block_labels[worst_index],
      WorstExpandedElementScoreResidual = max(
        abs(expanded_element_residuals$ScoreResidual)
      ),
      WorstExpandedMeanScoreResidual = max(
        abs(expanded_element_residuals$MeanScoreResidual)
      ),
      LocalCurvature = local_curvature,
      LocalNewtonParameterChange = local_newton_step,
      LocalObjectiveImprovement = local_objective_improvement,
      LocalRelativeObjectiveImprovement =
        local_objective_improvement / max(1, abs(retained_objective)),
      ReadinessChanged = FALSE,
      FACETSStoppingRuleApplied = FALSE,
      DecisionUse = "diagnostic_only",
      stringsAsFactors = FALSE
    ),
    free_gradient_blocks = free_gradient_blocks,
    numeric_probes = numeric_probes,
    replication_transport = replication_transport,
    expanded_element_residuals = expanded_element_residuals,
    expanded_element_summary = expanded_element_summary
  )
  class(out) <- c("mfrmr_facets_mfs_stationarity_audit", "list")
  out
}

# Identify optimizer coordinates that represent only Persons already classified
# as unbounded. A centered or grouped constraint can mix an unbounded Person
# with estimable Persons in the same free direction; that case is deliberately
# not guessed at and cannot authorize the boundary-conditioned audit below.
mfrmr_facets_mfs_boundary_coordinate_map <- function(context) {
  person <- as.data.frame(context$fit$facets$person, stringsAsFactors = FALSE)
  required <- c("Person", "ParameterStatus")
  if (!all(required %in% names(person))) {
    return(list(
      status = "person_status_unavailable", certified = FALSE,
      boundary_persons = character(0), optimizer_indices = integer(0)
    ))
  }
  spec <- context$config$theta_spec
  levels <- as.character(spec$levels)
  matched <- match(levels, as.character(person$Person))
  if (anyNA(matched) || anyDuplicated(as.character(person$Person)) ||
      length(matched) != nrow(person)) {
    return(list(
      status = "person_level_alignment_failed", certified = FALSE,
      boundary_persons = character(0), optimizer_indices = integer(0)
    ))
  }
  status <- as.character(person$ParameterStatus[matched])
  boundary <- status %in% c(
    "unbounded_low", "unbounded_high", "unbounded_both"
  )
  boundary_persons <- levels[boundary]
  if (!length(boundary_persons)) {
    return(list(
      status = "no_known_person_boundary", certified = TRUE,
      boundary_persons = character(0), optimizer_indices = integer(0)
    ))
  }

  jacobian <- context$constraint_jacobian(spec)
  theta_coordinates <- as.integer(context$sizes$theta)
  if (!is.matrix(jacobian) ||
      !identical(dim(jacobian), c(length(levels), theta_coordinates)) ||
      any(!is.finite(jacobian))) {
    return(list(
      status = "constraint_jacobian_unavailable", certified = FALSE,
      boundary_persons = boundary_persons, optimizer_indices = integer(0)
    ))
  }
  nonzero <- jacobian != 0
  boundary_columns <- which(colSums(nonzero[boundary, , drop = FALSE]) > 0L)
  mixed_columns <- boundary_columns[
    colSums(nonzero[!boundary, boundary_columns, drop = FALSE]) > 0L
  ]
  if (length(mixed_columns)) {
    return(list(
      status = "ambiguous_constraint_mixing", certified = FALSE,
      boundary_persons = boundary_persons, optimizer_indices = integer(0)
    ))
  }
  list(
    status = "boundary_coordinates_certified", certified = TRUE,
    boundary_persons = boundary_persons,
    optimizer_indices = as.integer(boundary_columns)
  )
}

# Solve the observed-information system after fixing selected optimizer
# coordinates. The returned vector remains on the full optimizer scale, with
# excluded coordinates set to zero. This is diagnostic only; it is not a
# covariance calculation and never authorizes standard errors.
mfrmr_facets_mfs_information_subspace <- function(
    hessian, gradient, excluded_indices = integer(0),
    eigen_relative_tolerance = 1e-10) {
  gradient <- as.numeric(gradient)
  dimension <- length(gradient)
  valid <- is.matrix(hessian) &&
    identical(dim(hessian), c(dimension, dimension)) &&
    dimension > 0L && all(is.finite(hessian)) && all(is.finite(gradient)) &&
    is.numeric(excluded_indices) && !anyNA(excluded_indices) &&
    all(excluded_indices == floor(excluded_indices)) &&
    all(excluded_indices >= 1L & excluded_indices <= dimension) &&
    !anyDuplicated(excluded_indices) &&
    is.numeric(eigen_relative_tolerance) &&
    length(eigen_relative_tolerance) == 1L &&
    is.finite(eigen_relative_tolerance) && eigen_relative_tolerance > 0
  if (!valid) {
    stop("The information-subspace inputs are invalid.", call. = FALSE)
  }
  excluded_indices <- as.integer(excluded_indices)
  retained_indices <- setdiff(seq_len(dimension), excluded_indices)
  if (!length(retained_indices)) {
    return(list(
      status = "no_interior_coordinates", evaluated = FALSE,
      retained_indices = retained_indices,
      parameter_change = numeric(0), eigenvalues = numeric(0),
      minimum_eigenvalue = NA_real_, maximum_eigenvalue = NA_real_,
      condition_number = NA_real_, positive_definite = FALSE,
      predicted_objective_improvement = NA_real_
    ))
  }

  information <- hessian[retained_indices, retained_indices, drop = FALSE]
  information <- (information + t(information)) / 2
  eigenvalues <- as.numeric(eigen(
    information, symmetric = TRUE, only.values = TRUE
  )$values)
  minimum <- min(eigenvalues)
  maximum <- max(eigenvalues)
  threshold <- eigen_relative_tolerance * max(1, max(abs(eigenvalues)))
  positive_definite <- minimum > threshold
  if (!positive_definite) {
    return(list(
      status = "nonpositive_or_weak_information", evaluated = TRUE,
      retained_indices = retained_indices,
      parameter_change = numeric(0), eigenvalues = eigenvalues,
      minimum_eigenvalue = minimum, maximum_eigenvalue = maximum,
      condition_number = if (minimum > 0) maximum / minimum else Inf,
      positive_definite = FALSE,
      predicted_objective_improvement = NA_real_
    ))
  }

  factor <- chol(information)
  right_hand_side <- gradient[retained_indices]
  solution <- backsolve(
    factor, forwardsolve(t(factor), right_hand_side)
  )
  parameter_change <- numeric(dimension)
  parameter_change[retained_indices] <- -as.numeric(solution)
  list(
    status = "positive_definite", evaluated = TRUE,
    retained_indices = retained_indices,
    parameter_change = parameter_change, eigenvalues = eigenvalues,
    minimum_eigenvalue = minimum, maximum_eigenvalue = maximum,
    condition_number = maximum / minimum, positive_definite = TRUE,
    predicted_objective_improvement = as.numeric(
      crossprod(right_hand_side, solution) / 2
    )
  )
}

# Evaluate the complete correlated local Newton displacement for moderate-size
# retained points. This is deliberately separate from the production
# covariance and readiness paths: it calibrates a representation-invariant
# numerical scale and does not provide standard errors or inferential claims.
mfrmr_facets_mfs_information_displacement_audit <- function(
    fit, max_free_dimension = 300L, difference_step = 1e-3,
    eigen_relative_tolerance = 1e-10,
    replication_factors = c(1L, 2L, 10L)) {
  valid_dimension <- is.numeric(max_free_dimension) &&
    length(max_free_dimension) == 1L && is.finite(max_free_dimension) &&
    max_free_dimension == floor(max_free_dimension) &&
    max_free_dimension >= 1L
  valid_controls <- is.numeric(difference_step) &&
    length(difference_step) == 1L && is.finite(difference_step) &&
    difference_step > 0 && is.numeric(eigen_relative_tolerance) &&
    length(eigen_relative_tolerance) == 1L &&
    is.finite(eigen_relative_tolerance) && eigen_relative_tolerance > 0
  valid_replication <- is.numeric(replication_factors) &&
    length(replication_factors) > 0L && !anyNA(replication_factors) &&
    all(is.finite(replication_factors)) &&
    all(replication_factors == floor(replication_factors)) &&
    all(replication_factors >= 1L) && !anyDuplicated(replication_factors)
  if (!valid_dimension || !valid_controls || !valid_replication) {
    stop(
      "Information-displacement controls are invalid; use a positive integer ",
      "dimension, positive finite tolerances, and unique positive integer ",
      "replication factors.", call. = FALSE
    )
  }
  max_free_dimension <- as.integer(max_free_dimension)
  replication_factors <- as.integer(replication_factors)
  context <- mfrmr_facets_mfs_jml_context(fit)
  free_dimension <- length(context$par)
  boundary_map <- mfrmr_facets_mfs_boundary_coordinate_map(context)
  boundary_count <- length(boundary_map$boundary_persons)
  boundary_coordinate_count <- length(boundary_map$optimizer_indices)

  empty_summary <- data.frame(
    Model = context$config$model, Method = context$config$method,
    Status = "not_evaluated_dimension_limit", Evaluated = FALSE,
    FreeCoordinates = free_dimension, DimensionLimit = max_free_dimension,
    DifferenceStep = difference_step,
    HessianMaximumAsymmetry = NA_real_,
    HessianMinimumEigenvalue = NA_real_,
    HessianMaximumEigenvalue = NA_real_,
    HessianConditionNumber = NA_real_,
    HessianPositiveDefiniteAtTolerance = FALSE,
    GradientSupNorm = max(abs(context$retained_gradient)),
    FullNewtonParameterChangeSupNorm = NA_real_,
    DiagonalNewtonParameterChangeSupNorm = NA_real_,
    CorrelatedToDiagonalDisplacementRatio = NA_real_,
    PredictedObjectiveImprovement = NA_real_,
    ActualObjectiveImprovement = NA_real_,
    RelativeObjectiveImprovement = NA_real_,
    KnownBoundaryPersonCount = boundary_count,
    BoundaryCoordinateMapStatus = boundary_map$status,
    BoundaryCoordinateMapCertified = isTRUE(boundary_map$certified),
    KnownBoundaryOptimizerCoordinates = boundary_coordinate_count,
    FullWorstChangeAtKnownBoundary = NA,
    InteriorSubspaceStatus = "not_evaluated_dimension_limit",
    InteriorSubspaceEvaluated = FALSE,
    InteriorCoordinates = NA_integer_,
    InteriorHessianMinimumEigenvalue = NA_real_,
    InteriorHessianConditionNumber = NA_real_,
    InteriorNewtonParameterChangeSupNorm = NA_real_,
    InteriorActualObjectiveImprovement = NA_real_,
    InteriorRelativeObjectiveImprovement = NA_real_,
    KnownBoundaryPrecedenceRequired = boundary_count > 0L,
    ReplicationDisplacementStable = FALSE,
    ReplicationDisplacementTolerance = 1e-12,
    ReadinessChanged = FALSE,
    ParameterDisplacementThresholdSelected = FALSE,
    DecisionUse = "diagnostic_only", stringsAsFactors = FALSE
  )
  if (free_dimension > max_free_dimension) {
    out <- list(
      summary = empty_summary, block_displacement = data.frame(),
      replication_transport = data.frame(), hessian = NULL,
      eigenvalues = numeric(0), parameter_change = numeric(0),
      boundary_map = boundary_map,
      interior_parameter_change = numeric(0)
    )
    class(out) <- c(
      "mfrmr_facets_mfs_information_displacement_audit", "list"
    )
    return(out)
  }

  raw_hessian <- stats::optimHess(
    par = context$par, fn = context$objective,
    gr = context$gradient,
    control = list(
      fnscale = 1,
      parscale = rep(1, free_dimension),
      ndeps = rep(difference_step, free_dimension)
    )
  )
  if (!is.matrix(raw_hessian) ||
      !identical(dim(raw_hessian), c(free_dimension, free_dimension)) ||
      any(!is.finite(raw_hessian))) {
    stop("The observed-information Hessian was malformed or non-finite.",
         call. = FALSE)
  }
  maximum_asymmetry <- max(abs(raw_hessian - t(raw_hessian)))
  hessian <- (raw_hessian + t(raw_hessian)) / 2
  decomposition <- eigen(hessian, symmetric = TRUE, only.values = TRUE)
  eigenvalues <- as.numeric(decomposition$values)
  eigen_scale <- max(abs(eigenvalues))
  eigen_threshold <- eigen_relative_tolerance * max(1, eigen_scale)
  positive_definite <- min(eigenvalues) > eigen_threshold

  interior <- NULL
  interior_actual_improvement <- NA_real_
  if (isTRUE(boundary_map$certified)) {
    interior <- mfrmr_facets_mfs_information_subspace(
      hessian = hessian, gradient = context$retained_gradient,
      excluded_indices = boundary_map$optimizer_indices,
      eigen_relative_tolerance = eigen_relative_tolerance
    )
    if (length(interior$parameter_change) == free_dimension) {
      interior_moved_objective <- context$objective(
        context$par + interior$parameter_change
      )
      interior_actual_improvement <-
        context$retained_objective - interior_moved_objective
    }
  }
  fill_interior_summary <- function(summary) {
    if (is.null(interior)) {
      summary$InteriorSubspaceStatus <- boundary_map$status
      return(summary)
    }
    summary$InteriorSubspaceStatus <- interior$status
    summary$InteriorSubspaceEvaluated <- isTRUE(interior$evaluated)
    summary$InteriorCoordinates <- length(interior$retained_indices)
    summary$InteriorHessianMinimumEigenvalue <- interior$minimum_eigenvalue
    summary$InteriorHessianConditionNumber <- interior$condition_number
    summary$InteriorNewtonParameterChangeSupNorm <-
      if (length(interior$parameter_change) == free_dimension) {
        max(abs(interior$parameter_change))
      } else {
        NA_real_
      }
    summary$InteriorActualObjectiveImprovement <-
      interior_actual_improvement
    summary$InteriorRelativeObjectiveImprovement <-
      interior_actual_improvement /
        max(1, abs(context$retained_objective))
    summary
  }

  if (!positive_definite) {
    empty_summary$Status <- "evaluated_nonpositive_or_weak_information"
    empty_summary$Evaluated <- TRUE
    empty_summary$HessianMaximumAsymmetry <- maximum_asymmetry
    empty_summary$HessianMinimumEigenvalue <- min(eigenvalues)
    empty_summary$HessianMaximumEigenvalue <- max(eigenvalues)
    empty_summary$HessianConditionNumber <- if (min(eigenvalues) > 0) {
      max(eigenvalues) / min(eigenvalues)
    } else {
      Inf
    }
    empty_summary <- fill_interior_summary(empty_summary)
    out <- list(
      summary = empty_summary, block_displacement = data.frame(),
      replication_transport = data.frame(), hessian = hessian,
      eigenvalues = eigenvalues, parameter_change = numeric(0),
      boundary_map = boundary_map,
      interior_parameter_change = if (is.null(interior)) {
        numeric(0)
      } else {
        interior$parameter_change
      }
    )
    class(out) <- c(
      "mfrmr_facets_mfs_information_displacement_audit", "list"
    )
    return(out)
  }

  factor <- chol(hessian)
  information_solve <- function(right_hand_side, multiplier = 1) {
    scaled_factor <- sqrt(multiplier) * factor
    scaled_right_hand_side <- multiplier * right_hand_side
    backsolve(
      scaled_factor,
      forwardsolve(t(scaled_factor), scaled_right_hand_side)
    )
  }
  newton_displacement <- information_solve(context$retained_gradient)
  parameter_change <- -as.numeric(newton_displacement)
  moved <- context$par + parameter_change
  moved_objective <- context$objective(moved)
  actual_improvement <- context$retained_objective - moved_objective
  predicted_improvement <- as.numeric(
    crossprod(context$retained_gradient, newton_displacement) / 2
  )
  diagonal_change <- -context$retained_gradient / diag(hessian)
  full_sup_norm <- max(abs(parameter_change))
  diagonal_sup_norm <- max(abs(diagonal_change))

  displacement_groups <- split(
    seq_along(parameter_change), context$block_labels
  )
  block_displacement <- do.call(rbind, lapply(
    names(displacement_groups), function(block) {
      indices <- displacement_groups[[block]]
      values <- parameter_change[indices]
      diagonal_values <- diagonal_change[indices]
      data.frame(
        Block = block, FreeCoordinates = length(indices),
        ParameterChangeSupNorm = max(abs(values)),
        ParameterChangeRMS = sqrt(mean(values^2)),
        DiagonalChangeSupNorm = max(abs(diagonal_values)),
        stringsAsFactors = FALSE
      )
    }
  ))

  replication_transport <- do.call(rbind, lapply(
    replication_factors, function(replication_factor) {
      transported <- -as.numeric(information_solve(
        context$retained_gradient, replication_factor
      ))
      data.frame(
        ReplicationFactor = replication_factor,
        ParameterChangeSupNorm = max(abs(transported)),
        MaximumDifferenceFromBase = max(abs(transported - parameter_change)),
        SameMLESetByConstantScaling = TRUE,
        ReadinessChanged = FALSE,
        stringsAsFactors = FALSE
      )
    }
  ))
  replication_stable <- all(
    replication_transport$MaximumDifferenceFromBase <= 1e-12
  )
  condition_number <- max(eigenvalues) / min(eigenvalues)
  summary <- empty_summary
  summary$Status <- "evaluated_positive_definite"
  summary$Evaluated <- TRUE
  summary$HessianMaximumAsymmetry <- maximum_asymmetry
  summary$HessianMinimumEigenvalue <- min(eigenvalues)
  summary$HessianMaximumEigenvalue <- max(eigenvalues)
  summary$HessianConditionNumber <- condition_number
  summary$HessianPositiveDefiniteAtTolerance <- TRUE
  summary$FullNewtonParameterChangeSupNorm <- full_sup_norm
  summary$DiagonalNewtonParameterChangeSupNorm <- diagonal_sup_norm
  summary$CorrelatedToDiagonalDisplacementRatio <-
    if (diagonal_sup_norm > 0) {
      full_sup_norm / diagonal_sup_norm
    } else if (full_sup_norm == 0) {
      1
    } else {
      Inf
    }
  summary$PredictedObjectiveImprovement <- predicted_improvement
  summary$ActualObjectiveImprovement <- actual_improvement
  summary$RelativeObjectiveImprovement <-
    actual_improvement / max(1, abs(context$retained_objective))
  if (boundary_coordinate_count > 0L) {
    summary$FullWorstChangeAtKnownBoundary <-
      which.max(abs(parameter_change)) %in% boundary_map$optimizer_indices
  } else {
    summary$FullWorstChangeAtKnownBoundary <- FALSE
  }
  summary <- fill_interior_summary(summary)
  summary$ReplicationDisplacementStable <- replication_stable

  out <- list(
    summary = summary, block_displacement = block_displacement,
    replication_transport = replication_transport, hessian = hessian,
    eigenvalues = eigenvalues, parameter_change = parameter_change,
    boundary_map = boundary_map,
    interior_parameter_change = if (is.null(interior)) {
      numeric(0)
    } else {
      interior$parameter_change
    }
  )
  class(out) <- c(
    "mfrmr_facets_mfs_information_displacement_audit", "list"
  )
  out
}

mfrmr_facets_mfs_cg_solve <- function(
    right_hand_side, hessian_vector, residual_tolerance = 1e-8,
    max_iterations = 500L) {
  right_hand_side <- as.numeric(right_hand_side)
  valid <- length(right_hand_side) > 0L &&
    all(is.finite(right_hand_side)) && is.function(hessian_vector) &&
    is.numeric(residual_tolerance) && length(residual_tolerance) == 1L &&
    is.finite(residual_tolerance) && residual_tolerance > 0 &&
    is.numeric(max_iterations) && length(max_iterations) == 1L &&
    is.finite(max_iterations) && max_iterations == floor(max_iterations) &&
    max_iterations >= 1L
  if (!valid) {
    stop("Conjugate-gradient controls or right-hand side are invalid.",
         call. = FALSE)
  }
  max_iterations <- as.integer(max_iterations)
  initial_norm <- sqrt(sum(right_hand_side^2))
  if (initial_norm == 0) {
    return(list(
      status = "zero_right_hand_side", converged = TRUE,
      solution = numeric(length(right_hand_side)), iterations = 0L,
      recurrence_relative_residual = 0,
      explicit_relative_residual = 0,
      nonpositive_curvature_encountered = FALSE,
      trace = data.frame()
    ))
  }

  solution <- numeric(length(right_hand_side))
  residual <- right_hand_side
  direction <- residual
  residual_squared <- sum(residual^2)
  trace_rows <- vector("list", max_iterations)
  restarted <- FALSE
  for (iteration in seq_len(max_iterations)) {
    product <- as.numeric(hessian_vector(direction))
    if (length(product) != length(direction) || any(!is.finite(product))) {
      stop("The Hessian-vector product was malformed or non-finite.",
           call. = FALSE)
    }
    curvature <- sum(direction * product)
    if (!is.finite(curvature) || curvature <= 0) {
      trace_rows[[iteration]] <- data.frame(
        Iteration = iteration,
        RelativeResidual = sqrt(residual_squared) / initial_norm,
        Curvature = curvature, StepLength = NA_real_,
        SolutionSupNorm = max(abs(solution)), Restarted = restarted,
        stringsAsFactors = FALSE
      )
      trace <- do.call(rbind, trace_rows[seq_len(iteration)])
      return(list(
        status = "nonpositive_curvature_encountered", converged = FALSE,
        solution = numeric(0), iterations = iteration,
        recurrence_relative_residual =
          sqrt(residual_squared) / initial_norm,
        explicit_relative_residual = NA_real_,
        nonpositive_curvature_encountered = TRUE, trace = trace
      ))
    }
    step_length <- residual_squared / curvature
    solution <- solution + step_length * direction
    residual <- residual - step_length * product
    next_residual_squared <- sum(residual^2)
    relative_residual <- sqrt(next_residual_squared) / initial_norm
    trace_rows[[iteration]] <- data.frame(
      Iteration = iteration, RelativeResidual = relative_residual,
      Curvature = curvature, StepLength = step_length,
      SolutionSupNorm = max(abs(solution)), Restarted = restarted,
      stringsAsFactors = FALSE
    )
    restarted <- FALSE

    if (relative_residual <= residual_tolerance) {
      explicit_residual <- right_hand_side -
        as.numeric(hessian_vector(solution))
      if (length(explicit_residual) != length(solution) ||
          any(!is.finite(explicit_residual))) {
        stop("The explicit matrix-free residual was malformed or non-finite.",
             call. = FALSE)
      }
      explicit_relative <- sqrt(sum(explicit_residual^2)) / initial_norm
      if (explicit_relative <= residual_tolerance) {
        return(list(
          status = "converged_krylov", converged = TRUE,
          solution = solution, iterations = iteration,
          recurrence_relative_residual = relative_residual,
          explicit_relative_residual = explicit_relative,
          nonpositive_curvature_encountered = FALSE,
          trace = do.call(rbind, trace_rows[seq_len(iteration)])
        ))
      }
      # Finite-difference Hessian-vector products are only approximately
      # additive. Restart from the explicitly reconstructed residual rather
      # than accepting a small recurrence residual that has drifted.
      residual <- explicit_residual
      direction <- residual
      residual_squared <- sum(residual^2)
      restarted <- TRUE
      next
    }
    beta <- next_residual_squared / residual_squared
    direction <- residual + beta * direction
    residual_squared <- next_residual_squared
  }

  explicit_residual <- right_hand_side -
    as.numeric(hessian_vector(solution))
  explicit_relative <- sqrt(sum(explicit_residual^2)) / initial_norm
  list(
    status = "iteration_limit", converged = FALSE,
    solution = numeric(0), iterations = max_iterations,
    recurrence_relative_residual = sqrt(residual_squared) / initial_norm,
    explicit_relative_residual = explicit_relative,
    nonpositive_curvature_encountered = FALSE,
    trace = do.call(rbind, trace_rows)
  )
}

# Matrix-free displacement on the gradient-generated Krylov subspace,
# optionally conditional on certified Person-boundary coordinates. A
# successful solve establishes a local score-correction vector only; it cannot
# certify positive curvature in directions orthogonal to that subspace.
mfrmr_facets_mfs_matrix_free_displacement_audit <- function(
    fit, direction_step = 1e-3, residual_tolerance = 1e-8,
    max_iterations = 500L, dense_reference = NULL,
    dense_relative_tolerance = 1e-5,
    condition_on_known_person_boundaries = TRUE) {
  controls <- c(
    direction_step, residual_tolerance, dense_relative_tolerance
  )
  valid_iterations <- is.numeric(max_iterations) &&
    length(max_iterations) == 1L && is.finite(max_iterations) &&
    max_iterations == floor(max_iterations) && max_iterations >= 1L
  valid_conditioning <- is.logical(condition_on_known_person_boundaries) &&
    length(condition_on_known_person_boundaries) == 1L &&
    !is.na(condition_on_known_person_boundaries)
  if (length(controls) != 3L || any(!is.finite(controls)) ||
      any(controls <= 0) || !valid_iterations || !valid_conditioning) {
    stop("Matrix-free displacement controls are invalid.",
         call. = FALSE)
  }
  context <- mfrmr_facets_mfs_jml_context(fit)
  boundary_map <- mfrmr_facets_mfs_boundary_coordinate_map(context)
  if (isTRUE(condition_on_known_person_boundaries) &&
      !isTRUE(boundary_map$certified)) {
    stop(
      "Known Person boundaries could not be isolated in optimizer ",
      "coordinates: ", boundary_map$status, ".", call. = FALSE
    )
  }
  excluded_indices <- if (isTRUE(condition_on_known_person_boundaries)) {
    boundary_map$optimizer_indices
  } else {
    integer(0)
  }
  retained_indices <- setdiff(seq_along(context$par), excluded_indices)
  if (!length(retained_indices)) {
    stop("No optimizer coordinates remain after boundary conditioning.",
         call. = FALSE)
  }
  hessian_vector_evaluations <- 0L
  hessian_vector <- function(retained_direction) {
    retained_direction <- as.numeric(retained_direction)
    if (length(retained_direction) != length(retained_indices) ||
        any(!is.finite(retained_direction))) {
      stop("A Hessian-vector direction was malformed or non-finite.",
           call. = FALSE)
    }
    direction <- numeric(length(context$par))
    direction[retained_indices] <- retained_direction
    direction <- as.numeric(direction)
    direction_norm <- max(abs(direction))
    if (direction_norm == 0) return(numeric(length(retained_indices)))
    epsilon <- direction_step / direction_norm
    hessian_vector_evaluations <<- hessian_vector_evaluations + 1L
    product <- (
      context$gradient(context$par + epsilon * direction) -
        context$gradient(context$par - epsilon * direction)
    ) / (2 * epsilon)
    product[retained_indices]
  }
  solved <- mfrmr_facets_mfs_cg_solve(
    right_hand_side = context$retained_gradient[retained_indices],
    hessian_vector = hessian_vector,
    residual_tolerance = residual_tolerance,
    max_iterations = max_iterations
  )

  parameter_change <- numeric(0)
  if (isTRUE(solved$converged)) {
    parameter_change <- numeric(length(context$par))
    parameter_change[retained_indices] <- -as.numeric(solved$solution)
  }
  block_displacement <- data.frame()
  predicted_improvement <- actual_improvement <- NA_real_
  if (length(parameter_change) == length(context$par)) {
    groups <- split(seq_along(parameter_change), context$block_labels)
    block_displacement <- do.call(rbind, lapply(names(groups), function(block) {
      values <- parameter_change[groups[[block]]]
      data.frame(
        Block = block, FreeCoordinates = length(values),
        ParameterChangeSupNorm = max(abs(values)),
        ParameterChangeRMS = sqrt(mean(values^2)),
        stringsAsFactors = FALSE
      )
    }))
    predicted_improvement <- as.numeric(
      -crossprod(context$retained_gradient, parameter_change) / 2
    )
    moved_objective <- context$objective(context$par + parameter_change)
    actual_improvement <- context$retained_objective - moved_objective
  }

  dense_candidate <- numeric(0)
  dense_is_audit <- !is.null(dense_reference) &&
    inherits(
      dense_reference,
      "mfrmr_facets_mfs_information_displacement_audit"
    ) && isTRUE(dense_reference$summary$Evaluated)
  if (dense_is_audit) {
    dense_candidate <- if (isTRUE(condition_on_known_person_boundaries)) {
      dense_reference$interior_parameter_change
    } else {
      dense_reference$parameter_change
    }
  }
  dense_available <- length(dense_candidate) == length(context$par)
  dense_maximum_difference <- dense_relative_difference <- NA_real_
  dense_agrees <- NA
  if (dense_available && length(parameter_change) == length(context$par)) {
    dense_maximum_difference <- max(abs(
      parameter_change - dense_candidate
    ))
    dense_scale <- max(1e-12, max(abs(dense_candidate)))
    dense_relative_difference <- dense_maximum_difference / dense_scale
    dense_agrees <- dense_relative_difference <= dense_relative_tolerance
  }

  summary <- data.frame(
    Model = context$config$model, Method = context$config$method,
    Status = solved$status, Converged = isTRUE(solved$converged),
    FreeCoordinates = length(context$par),
    RetainedInteriorCoordinates = length(retained_indices),
    BoundaryConditioningRequested =
      isTRUE(condition_on_known_person_boundaries),
    BoundaryCoordinateMapStatus = boundary_map$status,
    BoundaryCoordinateMapCertified = isTRUE(boundary_map$certified),
    KnownBoundaryPersonCount = length(boundary_map$boundary_persons),
    ExcludedBoundaryOptimizerCoordinates = length(excluded_indices),
    DirectionStep = direction_step,
    ResidualTolerance = residual_tolerance,
    Iterations = solved$iterations,
    HessianVectorEvaluations = hessian_vector_evaluations,
    RecurrenceRelativeResidual = solved$recurrence_relative_residual,
    ExplicitRelativeResidual = solved$explicit_relative_residual,
    NonpositiveCurvatureEncountered =
      solved$nonpositive_curvature_encountered,
    ParameterChangeSupNorm = if (length(parameter_change)) {
      max(abs(parameter_change))
    } else {
      NA_real_
    },
    PredictedObjectiveImprovement = predicted_improvement,
    ActualObjectiveImprovement = actual_improvement,
    RelativeObjectiveImprovement = actual_improvement /
      max(1, abs(context$retained_objective)),
    DenseReferenceAvailable = dense_available,
    DenseMaximumParameterDifference = dense_maximum_difference,
    DenseRelativeParameterDifference = dense_relative_difference,
    DenseReferenceAgrees = dense_agrees,
    DenseReferenceTolerance = dense_relative_tolerance,
    GlobalPositiveDefinitenessCertified = FALSE,
    StandardErrorsAuthorized = FALSE,
    ReadinessChanged = FALSE,
    ParameterDisplacementThresholdSelected = FALSE,
    DecisionUse = "diagnostic_only", stringsAsFactors = FALSE
  )
  out <- list(
    summary = summary, block_displacement = block_displacement,
    parameter_change = parameter_change, solver_trace = solved$trace,
    boundary_map = boundary_map
  )
  class(out) <- c(
    "mfrmr_facets_mfs_matrix_free_displacement_audit", "list"
  )
  out
}

mfrmr_facets_mfs_bind_rows <- function(rows) {
  rows <- rows[lengths(rows) > 0L]
  if (!length(rows)) return(data.frame())
  fields <- unique(unlist(lapply(rows, names), use.names = FALSE))
  normalized <- lapply(rows, function(x) {
    missing <- setdiff(fields, names(x))
    for (field in missing) x[[field]] <- NA
    x[, fields, drop = FALSE]
  })
  do.call(rbind, normalized)
}

mfrmr_facets_mfs_collapse_messages <- function(messages) {
  messages <- unique(as.character(messages))
  messages <- messages[!is.na(messages) & nzchar(messages)]
  paste(messages, collapse = " | ")
}

mfrmr_facets_mfs_preflight <- function(request, facets_exe, work_dir) {
  registry <- merge(
    request$registry,
    data.frame(Model = request$models, stringsAsFactors = FALSE),
    all = TRUE
  )
  registry <- registry[order(
    match(registry$ScenarioId, request$registry$ScenarioId),
    match(registry$Model, request$models)
  ), , drop = FALSE]
  registry$BaseSeed <- request$base_seed
  registry$DesignSeed <- request$base_seed +
    match(registry$Model, c("RSM", "PCM"))
  registry$ExecutionStatus <- "not_run"
  registry$ComparisonEligible <- FALSE
  registry$FileHashUsed <- FALSE
  registry$ConfirmationAuthorized <- FALSE
  registry$FACETSReplacementClaimAuthorized <- FALSE
  out <- list(
    contract_id = mfrmr_facets_mfs_contract_id,
    manifest = registry,
    element_coordinates = data.frame(), step_coordinates = data.frame(),
    recovery = data.frame(), recovery_summary = data.frame(),
    decision = data.frame(
      Status = "stress_preflight_no_files_created",
      PlannedCases = nrow(registry), CompletedCases = 0L,
      EligibleCases = 0L, NegativeControlsRetained = 0L,
      ExternalExecutionRequested = FALSE, PilotOnly = TRUE,
      BiasIsMonteCarloEstimate = FALSE, ConfirmationOutcomeOpened = FALSE,
      FACETSReplacementClaimAuthorized = FALSE, FileHashRequired = FALSE,
      stringsAsFactors = FALSE
    ),
    facets_exe = normalizePath(facets_exe, winslash = "/", mustWork = FALSE),
    work_dir = normalizePath(work_dir, winslash = "/", mustWork = FALSE)
  )
  class(out) <- c("mfrmr_facets_mfs_result", "list")
  out
}

mfrmr_run_facets_mfs_pilot <- function(
    facets_exe, work_dir, base_seed = 451001L,
    scenario_ids = mfrmr_facets_mfs_registry()$ScenarioId,
    models = c("RSM", "PCM"), execute = FALSE, maxit = 400L) {
  request <- mfrmr_facets_mfs_validate_request(
    base_seed, scenario_ids, models
  )
  if (!isTRUE(execute)) {
    return(mfrmr_facets_mfs_preflight(request, facets_exe, work_dir))
  }
  if (!file.exists(facets_exe)) {
    stop("FACETS executable was not found: ", facets_exe, ".", call. = FALSE)
  }
  if (dir.exists(work_dir) && length(list.files(
      work_dir, all.files = TRUE, no.. = TRUE
    ))) {
    stop("FACETS stress work directory must be absent or empty: ", work_dir,
         ".", call. = FALSE)
  }
  dir.create(work_dir, recursive = TRUE, showWarnings = FALSE)
  manifests <- list()
  elements <- list()
  steps <- list()
  recovery <- list()
  index <- 0L
  for (scenario_index in seq_len(nrow(request$registry))) {
    scenario <- request$registry[scenario_index, , drop = FALSE]
    for (model in request$models) {
      index <- index + 1L
      design_seed <- request$base_seed + match(model, c("RSM", "PCM"))
      design <- mfrmr_facets_mfs_design(
        scenario$ScenarioId, model, design_seed
      )
      case_root <- file.path(
        work_dir, tolower(scenario$ScenarioId), tolower(model)
      )
      builder <- local({
        fixed_design <- design
        function(total_facets, model, seed) fixed_design
      })
      captured <- mfrmr_facets_mfp_capture(
        mfrmr_run_facets_mfp_external_pilot(
          facets_exe = facets_exe, work_dir = case_root, execute = TRUE,
          total_facets = scenario$TotalFacets, models = model,
          seed = request$base_seed, maxit = maxit,
          design_builder = builder, retain_fit = TRUE
        )
      )
      raw <- captured$value
      existing_fit <- if (!is.null(raw) && length(raw$fits) &&
          !is.null(raw$fits[[1L]])) raw$fits[[1L]] else NULL
      mfrmr_result <- mfrmr_facets_mfs_fit_mfrmr(
        design, maxit = maxit, existing_fit = existing_fit
      )
      if (is.null(captured$value)) {
        typed_structural_rejection <- isTRUE(grepl(
          "(^|;)mfrmr_estimability_error($|;)",
          as.character(mfrmr_result$error_class), perl = TRUE
        ))
        manifests[[index]] <- data.frame(
          scenario, Model = model, BaseSeed = request$base_seed,
          DesignSeed = design_seed, Rows = nrow(design$data),
          ExecutionStatus = if (typed_structural_rejection && identical(
              scenario$ExpectedState, "must_not_be_comparison_eligible"
            )) "negative_control_rejected" else "runner_failure",
          ComparisonEligible = FALSE,
          FACETSReportVersion = NA_character_, FACETSVersionMatched = FALSE,
          MfrmrIndependentFitAttempted =
            mfrmr_result$independently_attempted,
          MfrmrFitReturned = mfrmr_result$fit_returned,
          MfrmrErrorClass = mfrmr_result$error_class,
          MfrmrConvergenceCode = mfrmr_result$convergence_code,
          MfrmrEstimationConverged = mfrmr_result$estimation_converged,
          MfrmrTerminalGradientSupNorm = mfrmr_result$terminal_gradient,
          MfrmrGradientReviewTolerance = mfrmr_result$gradient_tolerance,
          MfrmrNumericalGatePassed = mfrmr_result$numerical_gate_passed,
          MfrmrError = mfrmr_result$error,
          Warnings = mfrmr_facets_mfs_collapse_messages(c(
            captured$warnings, mfrmr_result$warnings
          )),
          Error = captured$error, FileHashUsed = FALSE, PilotOnly = TRUE,
          ConfirmationAuthorized = FALSE,
          FACETSReplacementClaimAuthorized = FALSE,
          stringsAsFactors = FALSE
        )
        if (nrow(mfrmr_result$recovery)) {
          recovery[[paste0(index, "-mfrmr")]] <- mfrmr_result$recovery
        }
        next
      }
      manifest <- raw$manifest[1L, , drop = FALSE]
      report_path <- file.path(
        case_root, paste0(tolower(model), "-f", scenario$TotalFacets),
        "report.txt"
      )
      report_version <- mfrmr_facets_mfx_report_version(report_path)
      version_matched <- !is.na(report_version) && report_version == "4.5.0"
      eligible <- isTRUE(manifest$ComparisonEligible) && version_matched
      expected_negative <- identical(
        scenario$ExpectedState, "must_not_be_comparison_eligible"
      )
      typed_structural_rejection <- expected_negative &&
        !mfrmr_result$fit_returned &&
        isTRUE(grepl(
          "(^|;)mfrmr_estimability_error($|;)",
          as.character(mfrmr_result$error_class), perl = TRUE
        ))
      status <- if (expected_negative && eligible) {
        "false_ready_failure"
      } else if (typed_structural_rejection) {
        "negative_control_rejected"
      } else if (expected_negative) {
        "negative_control_unresolved"
      } else if (eligible) {
        "completed"
      } else if (mfrmr_result$numerical_gate_passed) {
        "mfrmr_only_external_failure"
      } else {
        "joint_numerical_failure"
      }
      manifest$ScenarioId <- scenario$ScenarioId
      manifest$StressAxis <- scenario$StressAxis
      manifest$Topology <- scenario$Topology
      manifest$ExpectedState <- scenario$ExpectedState
      manifest$ExecutionStatus <- status
      manifest$ComparisonEligible <- eligible && !expected_negative
      manifest$FACETSReportVersion <- report_version
      manifest$FACETSVersionMatched <- version_matched
      manifest$MfrmrIndependentFitAttempted <-
        mfrmr_result$independently_attempted
      manifest$MfrmrFitReturned <- mfrmr_result$fit_returned
      manifest$MfrmrErrorClass <- mfrmr_result$error_class
      manifest$MfrmrConvergenceCode <- mfrmr_result$convergence_code
      manifest$MfrmrEstimationConverged <-
        mfrmr_result$estimation_converged
      manifest$MfrmrTerminalGradientSupNorm <-
        mfrmr_result$terminal_gradient
      manifest$MfrmrGradientReviewTolerance <-
        mfrmr_result$gradient_tolerance
      manifest$MfrmrNumericalGatePassed <-
        mfrmr_result$numerical_gate_passed
      manifest$MfrmrError <- mfrmr_result$error
      manifest$Warnings <- mfrmr_facets_mfs_collapse_messages(c(
          manifest$Warnings, captured$warnings, mfrmr_result$warnings
      ))
      if (!version_matched && is.na(manifest$Error)) {
        manifest$Error <- "FACETS report version was not 4.5.0."
      }
      manifest$FileHashUsed <- FALSE
      manifest$PilotOnly <- TRUE
      manifest$ConfirmationAuthorized <- FALSE
      manifest$FACETSReplacementClaimAuthorized <- FALSE
      manifests[[index]] <- manifest
      if (!manifest$ComparisonEligible) {
        if (nrow(mfrmr_result$recovery)) {
          recovery[[paste0(index, "-mfrmr")]] <- mfrmr_result$recovery
        }
        next
      }
      element <- raw$element_comparisons
      step <- raw$step_comparisons
      element$ScenarioId <- scenario$ScenarioId
      step$ScenarioId <- scenario$ScenarioId
      elements[[index]] <- element
      steps[[index]] <- step
      recovery[[paste0(index, "-element")]] <-
        mfrmr_facets_mfs_recovery_rows(element, design, "element")
      recovery[[paste0(index, "-step")]] <-
        mfrmr_facets_mfs_recovery_rows(step, design, "step")
    }
  }
  manifest <- mfrmr_facets_mfs_bind_rows(manifests)
  element_coordinates <- mfrmr_facets_mfs_bind_rows(elements)
  step_coordinates <- mfrmr_facets_mfs_bind_rows(steps)
  recovery_rows <- mfrmr_facets_mfs_bind_rows(recovery)
  negative_retained <- manifest$ExpectedState ==
    "must_not_be_comparison_eligible" &
    manifest$ExecutionStatus == "negative_control_rejected"
  mfrmr_eligible <- manifest$MfrmrNumericalGatePassed %in% TRUE
  external_blocked <- manifest$ExecutionStatus ==
    "mfrmr_only_external_failure"
  overall_status <- if (all(
      manifest$ExecutionStatus %in% c(
        "completed", "negative_control_rejected"
      )
    )) {
    "stress_pilot_completed"
  } else if (all(
      manifest$ExecutionStatus %in% c(
        "mfrmr_only_external_failure", "negative_control_rejected"
      )
    )) {
    "mfrmr_stress_completed_external_comparison_blocked"
  } else {
    "stress_pilot_completed_with_failures"
  }
  out <- list(
    contract_id = mfrmr_facets_mfs_contract_id,
    manifest = manifest,
    element_coordinates = element_coordinates,
    step_coordinates = step_coordinates,
    recovery = recovery_rows,
    recovery_summary = mfrmr_facets_mfs_summarize_recovery(recovery_rows),
    decision = data.frame(
      Status = overall_status,
      PlannedCases = nrow(manifest),
      CompletedCases = sum(manifest$ExecutionStatus == "completed"),
      EligibleCases = sum(manifest$ComparisonEligible),
      MfrmrNumericallyEligibleCases = sum(mfrmr_eligible),
      ExternalComparisonBlockedCases = sum(external_blocked),
      NegativeControlsRetained = sum(negative_retained),
      ExternalExecutionRequested = TRUE, PilotOnly = TRUE,
      BiasIsMonteCarloEstimate = FALSE, ConfirmationOutcomeOpened = FALSE,
      FACETSReplacementClaimAuthorized = FALSE, FileHashRequired = FALSE,
      stringsAsFactors = FALSE
    ),
    facets_exe = normalizePath(facets_exe, winslash = "/", mustWork = TRUE),
    work_dir = normalizePath(work_dir, winslash = "/", mustWork = TRUE)
  )
  class(out) <- c("mfrmr_facets_mfs_result", "list")
  out
}

mfrmr_run_mfs_mfrmr_only <- function(
    base_seed = 451001L,
    scenario_ids = mfrmr_facets_mfs_registry()$ScenarioId,
    models = c("RSM", "PCM"), maxit = 400L) {
  valid_maxit <- is.numeric(maxit) && length(maxit) == 1L && !is.na(maxit) &&
    is.finite(maxit) && maxit == floor(maxit) && maxit >= 1L
  if (!valid_maxit) {
    stop("`maxit` must be one positive finite integer.", call. = FALSE)
  }
  maxit <- as.integer(maxit)
  request <- mfrmr_facets_mfs_validate_request(
    base_seed, scenario_ids, models
  )
  manifests <- list()
  recovery <- list()
  index <- 0L
  for (scenario_index in seq_len(nrow(request$registry))) {
    scenario <- request$registry[scenario_index, , drop = FALSE]
    for (model in request$models) {
      index <- index + 1L
      design_seed <- request$base_seed + match(model, c("RSM", "PCM"))
      design <- mfrmr_facets_mfs_design(
        scenario$ScenarioId, model, design_seed
      )
      result <- mfrmr_facets_mfs_fit_mfrmr(design, maxit = maxit)
      typed_structural_rejection <- !result$fit_returned && isTRUE(grepl(
        "(^|;)mfrmr_estimability_error($|;)", result$error_class, perl = TRUE
      ))
      expected_negative <- identical(
        scenario$ExpectedState, "must_not_be_comparison_eligible"
      )
      status <- if (expected_negative && typed_structural_rejection) {
        "negative_control_rejected"
      } else if (expected_negative && result$fit_returned) {
        "false_ready_failure"
      } else if (result$numerical_gate_passed) {
        "numerically_eligible"
      } else if (result$fit_returned) {
        "numerical_review"
      } else {
        "fit_error"
      }
      manifests[[index]] <- data.frame(
        ScenarioId = scenario$ScenarioId, StressAxis = scenario$StressAxis,
        Model = model, BaseSeed = request$base_seed,
        DesignSeed = design_seed, TotalFacets = scenario$TotalFacets,
        Rows = nrow(design$data), ExpectedState = scenario$ExpectedState,
        ExecutionStatus = status, FitReturned = result$fit_returned,
        ErrorClass = result$error_class,
        ConvergenceCode = result$convergence_code,
        EstimationConverged = result$estimation_converged,
        TerminalGradientSupNorm = result$terminal_gradient,
        GradientReviewTolerance = result$gradient_tolerance,
        NumericalGatePassed = result$numerical_gate_passed,
        Warnings = mfrmr_facets_mfs_collapse_messages(result$warnings),
        Error = result$error, Maxit = as.integer(maxit),
        PilotOnly = TRUE, BiasIsMonteCarloEstimate = FALSE,
        FACETSComparisonPerformed = FALSE,
        FACETSReplacementClaimAuthorized = FALSE,
        stringsAsFactors = FALSE
      )
      if (nrow(result$recovery)) recovery[[index]] <- result$recovery
    }
  }
  manifest <- mfrmr_facets_mfs_bind_rows(manifests)
  recovery_rows <- mfrmr_facets_mfs_bind_rows(recovery)
  out <- list(
    contract_id = mfrmr_facets_mfs_contract_id,
    manifest = manifest,
    recovery = recovery_rows,
    recovery_summary = mfrmr_facets_mfs_summarize_recovery(recovery_rows),
    decision = data.frame(
      Status = if (all(manifest$ExecutionStatus %in% c(
          "numerically_eligible", "negative_control_rejected"
        ))) "mfrmr_stress_completed" else
        "mfrmr_stress_completed_with_numerical_review",
      PlannedCases = nrow(manifest),
      NumericallyEligibleCases = sum(manifest$NumericalGatePassed),
      NegativeControlsRetained = sum(
        manifest$ExecutionStatus == "negative_control_rejected"
      ),
      FACETSComparisonPerformed = FALSE,
      BiasIsMonteCarloEstimate = FALSE,
      FACETSReplacementClaimAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  )
  class(out) <- c("mfrmr_facets_mfs_internal_result", "list")
  out
}

print.mfrmr_facets_mfs_result <- function(x, ...) {
  cat("FACETS RSM/PCM stress envelope\n")
  cat("Status:", x$decision$Status, "\n")
  cat("Planned cases:", x$decision$PlannedCases, "\n")
  cat("Eligible cases:", x$decision$EligibleCases, "\n")
  cat("Pilot only: yes; FACETS replacement claim: no\n")
  invisible(x)
}
