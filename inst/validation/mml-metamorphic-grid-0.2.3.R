# Repository-only MML metamorphic pilot for mfrmr 0.2.3.
#
# The runner compares semantically identical retained datasets after row,
# label, factor, missing-value, and weight transformations across RSM, PCM,
# and bounded GPCM. It is calibration and internal-invariance evidence only;
# it cannot authorize confirmation or freeze an optimizer tolerance.

mfrmr_mml_meta_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl("mml-metamorphic-grid-0\\.2\\.3\\.R$", files)]
  if (length(hit) > 0L) {
    return(dirname(normalizePath(
      hit[length(hit)], winslash = "/", mustWork = FALSE
    )))
  }
  candidates <- c(
    file.path("inst", "validation", "mml-metamorphic-grid-0.2.3.R"),
    "mml-metamorphic-grid-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) NA_character_ else {
    dirname(normalizePath(path, winslash = "/", mustWork = TRUE))
  }
})

mfrmr_mml_meta_require_identity <- function() {
  target_env <- environment(mfrmr_mml_meta_require_identity)
  required <- c(
    "mfrmr_gpcm_repilot_hash_object",
    "mfrmr_gpcm_repilot_hash_file",
    "mfrmr_gpcm_repilot_runtime_package_identity",
    "mfrmr_gpcm_repilot_capability_manifest"
  )
  if (all(vapply(required, exists, logical(1), envir = target_env,
                 mode = "function", inherits = TRUE))) {
    return(invisible(TRUE))
  }
  candidates <- c(
    if (!is.na(mfrmr_mml_meta_source_dir)) {
      file.path(
        mfrmr_mml_meta_source_dir,
        "gpcm-attribution-replicated-pilot-0.2.3.R"
      )
    } else character(0),
    file.path(
      "inst", "validation",
      "gpcm-attribution-replicated-pilot-0.2.3.R"
    )
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) stop("Cannot locate evidence-identity helpers.", call. = FALSE)
  sys.source(path, envir = target_env)
  if (!all(vapply(required, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    stop("Evidence-identity helpers did not load completely.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_mml_meta_fun <- function(name, exported = FALSE) {
  if (!requireNamespace("mfrmr", quietly = TRUE)) {
    stop("Package `mfrmr` must be installed for the metamorphic pilot.",
         call. = FALSE)
  }
  if (isTRUE(exported)) getExportedValue("mfrmr", name) else {
    getFromNamespace(name, "mfrmr")
  }
}

mfrmr_mml_meta_permutation <- function(n) {
  if (n < 2L) return(seq_len(n))
  order((seq_len(n) * 37L) %% (n + 1L), seq_len(n), decreasing = TRUE)
}

mfrmr_mml_meta_label_map <- function(values, prefix) {
  original <- sort(unique(as.character(values)))
  index <- seq_along(original)
  label <- sprintf(
    "%s_%s_%03d",
    prefix,
    ifelse(index %% 2L == 0L, "alpha", "zeta"),
    rev(index)
  )
  data.frame(Original = original, Label = label, stringsAsFactors = FALSE)
}

mfrmr_mml_meta_apply_map <- function(values, map) {
  if (is.null(map) || nrow(map) == 0L) return(as.character(values))
  out <- map$Label[match(as.character(values), map$Original)]
  if (anyNA(out)) stop("A metamorphic label map was incomplete.", call. = FALSE)
  out
}

mfrmr_mml_meta_restore_map <- function(values, map) {
  if (is.null(map) || nrow(map) == 0L) return(as.character(values))
  out <- map$Original[match(as.character(values), map$Label)]
  ifelse(is.na(out), as.character(values), out)
}

mfrmr_mml_meta_base_data <- function(seed = 451001L) {
  simulate <- mfrmr_mml_meta_fun("simulate_mfrm_data", exported = TRUE)
  data <- simulate(
    n_person = 24L,
    n_rater = 3L,
    n_criterion = 3L,
    raters_per_person = 3L,
    score_levels = 4L,
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    slopes = c(C01 = 0.80, C02 = 1.00, C03 = 1.25),
    seed = as.integer(seed)
  )
  as.data.frame(data[c("Person", "Rater", "Criterion", "Score")],
                stringsAsFactors = FALSE)
}

mfrmr_mml_meta_maps <- function(data, person = FALSE, facets = FALSE) {
  list(
    Person = if (person) {
      mfrmr_mml_meta_label_map(data$Person, "candidate")
    } else NULL,
    Rater = if (facets) {
      mfrmr_mml_meta_label_map(data$Rater, "judge")
    } else NULL,
    Criterion = if (facets) {
      mfrmr_mml_meta_label_map(data$Criterion, "scale")
    } else NULL
  )
}

mfrmr_mml_meta_relabel <- function(data, maps) {
  data$Person <- mfrmr_mml_meta_apply_map(data$Person, maps$Person)
  data$Rater <- mfrmr_mml_meta_apply_map(data$Rater, maps$Rater)
  data$Criterion <- mfrmr_mml_meta_apply_map(
    data$Criterion, maps$Criterion
  )
  data
}

mfrmr_mml_meta_factorize <- function(data) {
  data$Person <- factor(
    data$Person,
    levels = unique(c(
      "unused_person", rev(unique(as.character(data$Person)))
    ))
  )
  data$Rater <- factor(
    data$Rater,
    levels = unique(c(
      rev(unique(as.character(data$Rater))), "unused_rater"
    ))
  )
  data$Criterion <- factor(
    data$Criterion,
    levels = unique(c(
      "unused_scale", rev(unique(as.character(data$Criterion)))
    ))
  )
  data
}

mfrmr_mml_meta_pair <- function(scenario_id, data) {
  identity_maps <- list(Person = NULL, Rater = NULL, Criterion = NULL)
  permute <- function(x) x[mfrmr_mml_meta_permutation(nrow(x)), , drop = FALSE]
  missing_rows <- seq.int(11L, nrow(data), by = 23L)
  zero_rows <- seq.int(17L, nrow(data), by = 29L)
  zero_rows <- setdiff(zero_rows, missing_rows)

  if (identical(scenario_id, "row_reverse")) {
    return(list(
      reference = data,
      challenge = data[rev(seq_len(nrow(data))), , drop = FALSE],
      reference_maps = identity_maps,
      challenge_maps = identity_maps
    ))
  }
  if (identical(scenario_id, "row_permutation")) {
    return(list(
      reference = data,
      challenge = permute(data),
      reference_maps = identity_maps,
      challenge_maps = identity_maps
    ))
  }
  if (identical(scenario_id, "unused_factor_levels")) {
    return(list(
      reference = data,
      challenge = permute(mfrmr_mml_meta_factorize(data)),
      reference_maps = identity_maps,
      challenge_maps = identity_maps
    ))
  }
  if (identical(scenario_id, "person_nonlexical_labels")) {
    maps <- mfrmr_mml_meta_maps(data, person = TRUE)
    return(list(
      reference = data,
      challenge = permute(mfrmr_mml_meta_relabel(data, maps)),
      reference_maps = identity_maps,
      challenge_maps = maps
    ))
  }
  if (identical(scenario_id, "facet_nonlexical_labels")) {
    maps <- mfrmr_mml_meta_maps(data, facets = TRUE)
    return(list(
      reference = data,
      challenge = permute(mfrmr_mml_meta_relabel(data, maps)),
      reference_maps = identity_maps,
      challenge_maps = maps
    ))
  }
  if (identical(scenario_id, "missing_outcome_filter")) {
    challenge <- data
    challenge$Score[missing_rows] <- NA
    return(list(
      reference = data[-missing_rows, , drop = FALSE],
      challenge = permute(challenge),
      reference_maps = identity_maps,
      challenge_maps = identity_maps
    ))
  }
  if (identical(scenario_id, "zero_weight_filter")) {
    reference <- data[-zero_rows, , drop = FALSE]
    reference$Weight <- 1
    challenge <- data
    challenge$Weight <- 1
    challenge$Weight[zero_rows] <- 0
    return(list(
      reference = reference,
      challenge = permute(challenge),
      reference_maps = identity_maps,
      challenge_maps = identity_maps
    ))
  }
  if (identical(scenario_id, "appended_zero_weight_levels")) {
    reference <- data
    reference$Weight <- 1
    appended <- data.frame(
      Person = c("unused_person_a", "unused_person_b"),
      Rater = c("unused_rater", "unused_rater"),
      Criterion = c("unused_scale", "unused_scale"),
      Score = c(1L, 4L),
      Weight = c(0, 0),
      stringsAsFactors = FALSE
    )
    challenge <- rbind(reference, appended)
    return(list(
      reference = reference,
      challenge = permute(mfrmr_mml_meta_factorize(challenge)),
      reference_maps = identity_maps,
      challenge_maps = identity_maps
    ))
  }
  if (identical(scenario_id, "positive_weight_permutation")) {
    weighted <- data
    person_index <- match(weighted$Person, sort(unique(weighted$Person)))
    rater_index <- match(weighted$Rater, sort(unique(weighted$Rater)))
    weighted$Weight <- c(0.5, 1, 1.5, 2)[
      1L + (person_index + 2L * rater_index) %% 4L
    ]
    return(list(
      reference = weighted,
      challenge = permute(weighted),
      reference_maps = identity_maps,
      challenge_maps = identity_maps
    ))
  }
  if (identical(scenario_id, "combined_filter_label_factor")) {
    maps <- mfrmr_mml_meta_maps(data, person = TRUE, facets = TRUE)
    retained <- data[-union(missing_rows, zero_rows), , drop = FALSE]
    retained$Weight <- 1
    challenge <- data
    challenge$Weight <- 1
    challenge$Score[missing_rows] <- NA
    challenge$Weight[zero_rows] <- 0
    challenge <- mfrmr_mml_meta_factorize(
      mfrmr_mml_meta_relabel(challenge, maps)
    )
    return(list(
      reference = retained,
      challenge = permute(challenge),
      reference_maps = identity_maps,
      challenge_maps = maps
    ))
  }
  stop("Unknown metamorphic scenario: ", scenario_id, call. = FALSE)
}

mfrmr_mml_meta_scenarios <- function() {
  data.frame(
    ScenarioId = c(
      "row_reverse", "row_permutation", "unused_factor_levels",
      "person_nonlexical_labels", "facet_nonlexical_labels",
      "missing_outcome_filter", "zero_weight_filter",
      "appended_zero_weight_levels", "positive_weight_permutation",
      "combined_filter_label_factor"
    ),
    Contract = c(
      rep("row_order_invariance", 2L),
      "observed_level_invariance",
      "person_identifier_equivariance",
      "facet_identifier_equivariance",
      "missing_encoding_equivalence",
      "zero_weight_filter_equivalence",
      "unretained_level_invariance",
      "weighted_row_order_invariance",
      "combined_filter_label_factor_equivalence"
    ),
    InputProvenanceEqualityRequired = c(
      TRUE, TRUE, TRUE, TRUE, TRUE,
      FALSE, FALSE, FALSE, TRUE, FALSE
    ),
    ConfirmationAuthorized = FALSE,
    CriterionState = "pilot_required_not_frozen",
    stringsAsFactors = FALSE
  )
}

mfrmr_mml_meta_manifest <- function(seed = 451001L,
                                    models = c("RSM", "PCM", "GPCM")) {
  mfrmr_mml_meta_require_identity()
  scenarios <- mfrmr_mml_meta_scenarios()
  models <- unique(match.arg(
    toupper(models), c("RSM", "PCM", "GPCM"), several.ok = TRUE
  ))
  out <- merge(
    scenarios,
    data.frame(Model = models, stringsAsFactors = FALSE),
    all = TRUE
  )
  out <- out[order(match(out$ScenarioId, scenarios$ScenarioId),
                   match(out$Model, c("RSM", "PCM", "GPCM"))),
             , drop = FALSE]
  row.names(out) <- NULL
  out$Method <- "MML"
  out$Seed <- as.integer(seed)
  out$ComparisonId <- paste("MML-META", out$Model,
                            toupper(out$ScenarioId), sep = "-")
  manifest_for_hash <- out
  out$ManifestSHA256 <- mfrmr_gpcm_repilot_hash_object(manifest_for_hash)
  out
}

mfrmr_mml_meta_capture <- function(expression) {
  warnings <- character(0)
  value <- tryCatch(
    withCallingHandlers(
      expression,
      warning = function(warning) {
        warnings <<- c(warnings, conditionMessage(warning))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(error) error
  )
  list(value = value, warnings = unique(warnings))
}

mfrmr_mml_meta_fit <- function(data, model, quad_points, maxit, reltol) {
  fit <- mfrmr_mml_meta_fun("fit_mfrm", exported = TRUE)
  args <- list(
    data = data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 1L,
    rating_max = 4L,
    keep_original = TRUE,
    model = model,
    method = "MML",
    quad_points = as.integer(quad_points),
    maxit = as.integer(maxit),
    reltol = as.numeric(reltol)
  )
  if (!identical(model, "RSM")) args$step_facet <- "Criterion"
  if (identical(model, "GPCM")) args$slope_facet <- "Criterion"
  if ("Weight" %in% names(data)) args$weight <- "Weight"
  start <- proc.time()[["elapsed"]]
  captured <- mfrmr_mml_meta_capture(do.call(fit, args))
  captured$runtime <- proc.time()[["elapsed"]] - start
  captured
}

mfrmr_mml_meta_canonicalize <- function(fit, maps) {
  restore <- function(values, facet) {
    mfrmr_mml_meta_restore_map(values, maps[[facet]])
  }
  person <- as.data.frame(fit$facets$person, stringsAsFactors = FALSE)
  person$Person <- restore(person$Person, "Person")

  facets <- as.data.frame(fit$facets$others, stringsAsFactors = FALSE)
  if (nrow(facets) > 0L) {
    facets$Level <- vapply(seq_len(nrow(facets)), function(i) {
      restore(facets$Level[i], facets$Facet[i])
    }, character(1))
  }

  steps <- as.data.frame(fit$steps, stringsAsFactors = FALSE)
  if (nrow(steps) > 0L && "StepFacet" %in% names(steps)) {
    steps$StepFacet <- restore(steps$StepFacet, "Criterion")
  }

  slopes <- as.data.frame(fit$slopes, stringsAsFactors = FALSE)
  if (nrow(slopes) > 0L && "SlopeFacet" %in% names(slopes)) {
    slopes$SlopeFacet <- restore(slopes$SlopeFacet, "Criterion")
  }

  obs <- as.data.frame(
    mfrmr_mml_meta_fun("compute_obs_table")(fit),
    stringsAsFactors = FALSE
  )
  obs$Person <- restore(obs$Person, "Person")
  obs$Rater <- restore(obs$Rater, "Rater")
  obs$Criterion <- restore(obs$Criterion, "Criterion")

  list(person = person, facets = facets, steps = steps,
       slopes = slopes, observations = obs)
}

mfrmr_mml_meta_compare_table <- function(reference, challenge, component,
                                          keys, metrics, tolerance_class) {
  if (length(metrics) == 0L) {
    return(data.frame(
      Component = character(0), Metric = character(0),
      Comparable = logical(0), KeySetEqual = logical(0), N = integer(0),
      MaxAbsDifference = numeric(0), MeanAbsDifference = numeric(0),
      ToleranceClass = character(0), stringsAsFactors = FALSE
    ))
  }
  empty <- data.frame(
    Component = component,
    Metric = metrics,
    Comparable = FALSE,
    KeySetEqual = FALSE,
    N = 0L,
    MaxAbsDifference = NA_real_,
    MeanAbsDifference = NA_real_,
    ToleranceClass = tolerance_class,
    stringsAsFactors = FALSE
  )
  if (!all(c(keys, metrics) %in% names(reference)) ||
      !all(c(keys, metrics) %in% names(challenge))) {
    return(empty)
  }
  order_frame <- function(data) {
    key <- do.call(paste, c(lapply(data[keys], as.character), sep = "\034"))
    data[order(key), , drop = FALSE]
  }
  reference <- order_frame(reference)
  challenge <- order_frame(challenge)
  ref_key <- do.call(paste, c(lapply(reference[keys], as.character),
                              sep = "\034"))
  challenge_key <- do.call(paste, c(lapply(challenge[keys], as.character),
                                    sep = "\034"))
  key_equal <- identical(ref_key, challenge_key)
  rows <- lapply(metrics, function(metric) {
    differences <- if (key_equal) {
      abs(as.numeric(reference[[metric]]) - as.numeric(challenge[[metric]]))
    } else numeric(0)
    finite <- is.finite(differences)
    data.frame(
      Component = component,
      Metric = metric,
      Comparable = key_equal && any(finite),
      KeySetEqual = key_equal,
      N = sum(finite),
      MaxAbsDifference = if (any(finite)) max(differences[finite]) else NA_real_,
      MeanAbsDifference = if (any(finite)) mean(differences[finite]) else NA_real_,
      ToleranceClass = tolerance_class,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_mml_meta_compare <- function(reference_fit, challenge_fit,
                                    reference_maps, challenge_maps,
                                    input_provenance_equality_required) {
  reference <- mfrmr_mml_meta_canonicalize(reference_fit, reference_maps)
  challenge <- mfrmr_mml_meta_canonicalize(challenge_fit, challenge_maps)
  step_keys <- if (all(
    "StepFacet" %in% names(reference$steps) &&
      "StepFacet" %in% names(challenge$steps)
  )) c("StepFacet", "Step") else "Step"
  tables <- list(
    mfrmr_mml_meta_compare_table(
      reference$person, challenge$person, "person", "Person",
      c("Estimate", "PosteriorSD"), "parameter"
    ),
    mfrmr_mml_meta_compare_table(
      reference$facets, challenge$facets, "facet", c("Facet", "Level"),
      "Estimate", "parameter"
    ),
    mfrmr_mml_meta_compare_table(
      reference$steps, challenge$steps, "step", step_keys,
      "Estimate", "parameter"
    ),
    mfrmr_mml_meta_compare_table(
      reference$slopes, challenge$slopes, "slope", "SlopeFacet",
      intersect(c("LogEstimate", "Estimate"), names(reference$slopes)),
      "parameter"
    ),
    mfrmr_mml_meta_compare_table(
      reference$observations, challenge$observations, "observation",
      c("Person", "Rater", "Criterion"),
      c(
        "PersonMeasure", "Expected", "Var", "Residual", "StdResidual",
        "ScoreInformation"
      ),
      "observation"
    )
  )
  metric_rows <- do.call(rbind, tables)
  result_status_fields <- c(
    "EstimabilityState", "CategoryState", "BoundaryState", "NumericalState"
  )
  provenance_fields <- c(
    "FitReadiness", "InferenceReady", "InputState", "ReadinessReasonCodes"
  )
  ref_summary <- as.data.frame(reference_fit$summary, stringsAsFactors = FALSE)
  challenge_summary <- as.data.frame(
    challenge_fit$summary, stringsAsFactors = FALSE
  )
  compare_fields <- function(fields) all(vapply(fields, function(field) {
    identical(as.character(ref_summary[[field]][1L]),
              as.character(challenge_summary[[field]][1L]))
  }, logical(1)))
  result_status_equal <- compare_fields(result_status_fields)
  provenance_equal <- compare_fields(provenance_fields)
  numerical_ready <- identical(
    as.character(ref_summary$NumericalState[1L]), "ready"
  ) && identical(
    as.character(challenge_summary$NumericalState[1L]), "ready"
  )
  scalar_rows <- data.frame(
    Component = "fit",
    Metric = c("LogLik", "Deviance"),
    Comparable = TRUE,
    KeySetEqual = TRUE,
    N = 1L,
    MaxAbsDifference = abs(c(
      ref_summary$LogLik[1L] - challenge_summary$LogLik[1L],
      ref_summary$Deviance[1L] - challenge_summary$Deviance[1L]
    )),
    MeanAbsDifference = abs(c(
      ref_summary$LogLik[1L] - challenge_summary$LogLik[1L],
      ref_summary$Deviance[1L] - challenge_summary$Deviance[1L]
    )),
    ToleranceClass = "objective",
    stringsAsFactors = FALSE
  )
  list(
    metrics = rbind(metric_rows, scalar_rows),
    result_status_equal = result_status_equal,
    numerical_ready = numerical_ready,
    input_provenance_equal = provenance_equal,
    input_provenance_equality_required =
      isTRUE(input_provenance_equality_required),
    status_pass = result_status_equal && numerical_ready &&
      (!isTRUE(input_provenance_equality_required) || provenance_equal),
    reference_result_status = paste(
      vapply(result_status_fields, function(field) {
        paste0(field, "=", as.character(ref_summary[[field]][1L]))
      }, character(1)),
      collapse = ";"
    ),
    challenge_result_status = paste(
      vapply(result_status_fields, function(field) {
        paste0(field, "=", as.character(challenge_summary[[field]][1L]))
      }, character(1)),
      collapse = ";"
    ),
    reference_input_provenance = paste(
      vapply(provenance_fields, function(field) {
        paste0(field, "=", as.character(ref_summary[[field]][1L]))
      }, character(1)), collapse = ";"
    ),
    challenge_input_provenance = paste(
      vapply(provenance_fields, function(field) {
        paste0(field, "=", as.character(challenge_summary[[field]][1L]))
      }, character(1)), collapse = ";"
    )
  )
}

mfrmr_mml_meta_tolerances <- function() {
  data.frame(
    ToleranceClass = c("objective", "parameter", "observation"),
    PilotTolerance = c(1e-6, 5e-5, 5e-5),
    CriterionState = "pilot_required_not_frozen",
    stringsAsFactors = FALSE
  )
}

mfrmr_run_mml_metamorphic_grid <- function(
    seed = 451001L, models = c("RSM", "PCM", "GPCM"),
    scenarios = NULL, quad_points = 7L, maxit = 400L, reltol = 1e-9,
    dry_run = FALSE, authorize = FALSE, progress = interactive(),
    output_dir = NULL) {
  mfrmr_mml_meta_require_identity()
  scalar_integer <- function(value, name, minimum) {
    if (length(value) != 1L || is.na(value) || !is.finite(value) ||
        value != as.integer(value) || value < minimum) {
      stop("`", name, "` must be one finite integer >= ", minimum, ".",
           call. = FALSE)
    }
    as.integer(value)
  }
  seed <- scalar_integer(seed, "seed", 1L)
  quad_points <- scalar_integer(quad_points, "quad_points", 3L)
  maxit <- scalar_integer(maxit, "maxit", 1L)
  if (length(reltol) != 1L || is.na(reltol) || !is.finite(reltol) ||
      reltol <= 0) {
    stop("`reltol` must be one finite positive number.", call. = FALSE)
  }
  reltol <- as.numeric(reltol)
  manifest <- mfrmr_mml_meta_manifest(seed = seed, models = models)
  if (!is.null(scenarios)) {
    unknown <- setdiff(scenarios, manifest$ScenarioId)
    if (length(unknown) > 0L) {
      stop("Unknown metamorphic scenario(s): ", paste(unknown, collapse = ", "),
           call. = FALSE)
    }
    manifest <- manifest[manifest$ScenarioId %in% scenarios, , drop = FALSE]
    row.names(manifest) <- NULL
  }
  selected_manifest <- manifest[setdiff(names(manifest), "ManifestSHA256")]
  selected_manifest_sha <-
    mfrmr_gpcm_repilot_hash_object(selected_manifest)
  manifest$SelectedManifestSHA256 <- selected_manifest_sha
  registry <- data.frame(
    Comparisons = nrow(manifest),
    Models = length(unique(manifest$Model)),
    Scenarios = length(unique(manifest$ScenarioId)),
    QuadPoints = as.integer(quad_points),
    Maxit = as.integer(maxit),
    Reltol = as.numeric(reltol),
    DeclaredManifestSHA256 = unique(manifest$ManifestSHA256),
    SelectedManifestSHA256 = selected_manifest_sha,
    ConfirmationAuthorized = FALSE,
    CriterionState = "pilot_required_not_frozen",
    stringsAsFactors = FALSE
  )
  if (isTRUE(dry_run)) {
    return(structure(
      list(registry = registry, manifest = manifest, results = data.frame(),
           metric_results = data.frame(), confirmation_authorized = FALSE),
      class = "mfrmr_mml_metamorphic_grid"
    ))
  }
  if (!isTRUE(authorize)) {
    stop("Metamorphic pilot execution requires `authorize = TRUE`.",
         call. = FALSE)
  }
  if (!is.null(output_dir) &&
      (file.exists(output_dir) || dir.exists(output_dir))) {
    stop("`output_dir` must not already exist; evidence is never overwritten.",
         call. = FALSE)
  }
  base_data <- mfrmr_mml_meta_base_data(seed)
  tolerances <- mfrmr_mml_meta_tolerances()
  rows <- vector("list", nrow(manifest))
  metric_rows <- vector("list", nrow(manifest))
  fit_cache <- new.env(parent = emptyenv())
  fit_cached <- function(data, model) {
    key <- mfrmr_gpcm_repilot_hash_object(list(
      data = data, model = model, quad_points = quad_points,
      maxit = maxit, reltol = reltol
    ))
    if (exists(key, envir = fit_cache, inherits = FALSE)) {
      value <- get(key, envir = fit_cache, inherits = FALSE)
      value$cache_reused <- TRUE
      return(value)
    }
    value <- mfrmr_mml_meta_fit(data, model, quad_points, maxit, reltol)
    value$cache_reused <- FALSE
    assign(key, value, envir = fit_cache)
    value
  }
  for (i in seq_len(nrow(manifest))) {
    model <- manifest$Model[i]
    scenario <- manifest$ScenarioId[i]
    if (isTRUE(progress)) {
      message(sprintf("[%d/%d] %s %s", i, nrow(manifest), model, scenario))
    }
    pair <- mfrmr_mml_meta_pair(scenario, base_data)
    reference <- fit_cached(pair$reference, model)
    challenge <- fit_cached(pair$challenge, model)
    reference_error <- inherits(reference$value, "error")
    challenge_error <- inherits(challenge$value, "error")
    if (!reference_error && !challenge_error) {
      comparison <- mfrmr_mml_meta_compare(
        reference$value, challenge$value,
        pair$reference_maps, pair$challenge_maps,
        manifest$InputProvenanceEqualityRequired[i]
      )
      metrics <- merge(
        comparison$metrics, tolerances,
        by = "ToleranceClass", all.x = TRUE, sort = FALSE
      )
      metrics$WithinPilotTolerance <- metrics$Comparable &
        metrics$KeySetEqual & is.finite(metrics$MaxAbsDifference) &
        metrics$MaxAbsDifference <= metrics$PilotTolerance
      comparison_pass <- all(metrics$WithinPilotTolerance) &&
        isTRUE(comparison$status_pass)
    } else {
      comparison <- list(
        result_status_equal = FALSE,
        numerical_ready = FALSE,
        input_provenance_equal = FALSE,
        input_provenance_equality_required =
          manifest$InputProvenanceEqualityRequired[i],
        status_pass = FALSE,
        reference_result_status = NA_character_,
        challenge_result_status = NA_character_,
        reference_input_provenance = NA_character_,
        challenge_input_provenance = NA_character_
      )
      metrics <- data.frame()
      comparison_pass <- FALSE
    }
    if (nrow(metrics) > 0L) {
      metrics$ComparisonId <- manifest$ComparisonId[i]
      metrics$ScenarioId <- scenario
      metrics$Model <- model
      metric_rows[[i]] <- metrics
    }
    rows[[i]] <- data.frame(
      ComparisonId = manifest$ComparisonId[i],
      ScenarioId = scenario,
      Contract = manifest$Contract[i],
      Model = model,
      Method = "MML",
      ReferenceRowsInput = nrow(pair$reference),
      ChallengeRowsInput = nrow(pair$challenge),
      ReferenceRowsRetained = if (reference_error) NA_integer_ else {
        nrow(reference$value$prep$data)
      },
      ChallengeRowsRetained = if (challenge_error) NA_integer_ else {
        nrow(challenge$value$prep$data)
      },
      ReferenceDataSHA256 = mfrmr_gpcm_repilot_hash_object(pair$reference),
      ChallengeDataSHA256 = mfrmr_gpcm_repilot_hash_object(pair$challenge),
      ReferenceFitSucceeded = !reference_error,
      ChallengeFitSucceeded = !challenge_error,
      ReferenceCacheReused = reference$cache_reused,
      ChallengeCacheReused = challenge$cache_reused,
      ReferenceRuntimeSeconds = reference$runtime,
      ChallengeRuntimeSeconds = challenge$runtime,
      ReferenceWarnings = paste(reference$warnings, collapse = " | "),
      ChallengeWarnings = paste(challenge$warnings, collapse = " | "),
      ReferenceError = if (reference_error) {
        conditionMessage(reference$value)
      } else "",
      ChallengeError = if (challenge_error) {
        conditionMessage(challenge$value)
      } else "",
      ResultStatusEqual = comparison$result_status_equal,
      NumericalReady = comparison$numerical_ready,
      InputProvenanceEqual = comparison$input_provenance_equal,
      InputProvenanceEqualityRequired =
        comparison$input_provenance_equality_required,
      StatusPass = comparison$status_pass,
      ReferenceResultStatus = comparison$reference_result_status,
      ChallengeResultStatus = comparison$challenge_result_status,
      ReferenceInputProvenance = comparison$reference_input_provenance,
      ChallengeInputProvenance = comparison$challenge_input_provenance,
      AllMetricKeysEqual = nrow(metrics) > 0L && all(metrics$KeySetEqual),
      AllMetricsWithinPilotTolerance = nrow(metrics) > 0L &&
        all(metrics$WithinPilotTolerance),
      PilotScreenPass = comparison_pass,
      ReleaseUse = "calibration_only",
      CriterionState = "pilot_required_not_frozen",
      ConfirmationAuthorized = FALSE,
      DeclaredManifestSHA256 = manifest$ManifestSHA256[i],
      SelectedManifestSHA256 = manifest$SelectedManifestSHA256[i],
      stringsAsFactors = FALSE
    )
  }
  results <- do.call(rbind, rows)
  metric_results <- do.call(rbind, metric_rows[!vapply(
    metric_rows, is.null, logical(1)
  )])
  row.names(results) <- NULL
  if (!is.null(metric_results) && nrow(metric_results) > 0L) {
    metric_results <- metric_results[c(
      "ComparisonId", "ScenarioId", "Model", "Component", "Metric",
      "Comparable", "KeySetEqual", "N", "MaxAbsDifference",
      "MeanAbsDifference", "ToleranceClass", "PilotTolerance",
      "WithinPilotTolerance", "CriterionState"
    )]
    row.names(metric_results) <- NULL
  } else {
    metric_results <- data.frame()
  }
  package_identity <- mfrmr_gpcm_repilot_runtime_package_identity()
  capabilities <- mfrmr_gpcm_repilot_capability_manifest()
  runner_path <- file.path(
    mfrmr_mml_meta_source_dir, "mml-metamorphic-grid-0.2.3.R"
  )
  runner_sha <- mfrmr_gpcm_repilot_hash_file(runner_path)
  execution_identity <- data.frame(
    DeclaredManifestSHA256 = unique(manifest$ManifestSHA256),
    SelectedManifestSHA256 = unique(manifest$SelectedManifestSHA256),
    PackageSHA256 = package_identity$PackageSHA256,
    CapabilitySHA256 = attr(capabilities, "CompositeSHA256"),
    RunnerSHA256 = runner_sha,
    QuadPoints = as.integer(quad_points),
    Maxit = as.integer(maxit),
    Reltol = as.numeric(reltol),
    stringsAsFactors = FALSE
  )
  execution_identity$ExecutionSHA256 <-
    mfrmr_gpcm_repilot_hash_object(execution_identity)
  out <- structure(
    list(
      registry = registry,
      manifest = manifest,
      results = results,
      metric_results = metric_results,
      tolerances = tolerances,
      execution_identity = execution_identity,
      package_identity = package_identity,
      capability_manifest = capabilities,
      confirmation_authorized = FALSE,
      session_info = utils::sessionInfo()
    ),
    class = "mfrmr_mml_metamorphic_grid"
  )
  if (!is.null(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
    utils::write.csv(registry, file.path(output_dir, "registry.csv"),
                     row.names = FALSE, na = "")
    utils::write.csv(manifest, file.path(output_dir, "manifest.csv"),
                     row.names = FALSE, na = "")
    utils::write.csv(results, file.path(output_dir, "results.csv"),
                     row.names = FALSE, na = "")
    utils::write.csv(metric_results,
                     file.path(output_dir, "metric-results.csv"),
                     row.names = FALSE, na = "")
    utils::write.csv(tolerances, file.path(output_dir, "tolerances.csv"),
                     row.names = FALSE, na = "")
    utils::write.csv(execution_identity,
                     file.path(output_dir, "execution-identity.csv"),
                     row.names = FALSE, na = "")
    utils::write.csv(package_identity,
                     file.path(output_dir, "package-identity.csv"),
                     row.names = FALSE, na = "")
    utils::write.csv(capabilities,
                     file.path(output_dir, "capability-manifest.csv"),
                     row.names = FALSE, na = "")
    saveRDS(out, file.path(output_dir, "mml-metamorphic-grid.rds"))
  }
  out
}
