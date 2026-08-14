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
mfrmr_facets_mfs_jml_stationarity_audit <- function(
    fit, max_numeric_probes = 12L, numeric_relative_step = 3e-5,
    curvature_relative_step = 1e-3,
    numeric_agreement_tolerance = 1e-6,
    replication_factors = c(1L, 2L, 10L)) {
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

  namespace <- asNamespace("mfrmr")
  internal <- function(name) get(name, envir = namespace, inherits = FALSE)
  build_indices <- internal("build_indices")
  build_param_sizes <- internal("build_param_sizes")
  objective_function <- internal("mfrm_loglik_jml")
  gradient_function <- internal("mfrm_grad_jml")
  expand_params <- internal("expand_params")
  compute_eta <- internal("compute_eta")
  probability_bundle <- internal("compute_response_probability_bundle")

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
  block_labels <- rep(names(size_values), size_values)
  objective <- function(candidate) {
    as.numeric(objective_function(candidate, idx, config, sizes))[1L]
  }
  retained_objective <- objective(par)
  stored_objective <- as.numeric(fit$opt$value)[1L]
  gradient <- as.numeric(gradient_function(par, idx, config, sizes))
  if (length(gradient) != length(par) || any(!is.finite(gradient)) ||
      !is.finite(retained_objective) || !is.finite(stored_objective)) {
    stop("The retained objective or analytic gradient is not finite.",
         call. = FALSE)
  }

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
