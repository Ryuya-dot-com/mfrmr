# Repository-only replicated-pilot orchestration for the draft.42 GPCM
# isolated-attribution runner.  This script adds prespecified execution tiers,
# completeness accounting, Monte Carlo summaries, and runtime forecasting.
# It cannot authorize confirmation or freeze a numerical criterion.

mfrmr_gpcm_repilot_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "gpcm-attribution-replicated-pilot-0\\.2\\.3\\.R$", files
  )]
  if (length(hit) == 0L) NA_character_ else {
    dirname(normalizePath(hit[length(hit)], winslash = "/", mustWork = FALSE))
  }
})

mfrmr_gpcm_repilot_require_runner <- function() {
  target_env <- environment(mfrmr_gpcm_repilot_require_runner)
  required <- c(
    "mfrmr_run_gpcm_isolated_attribution_pilot",
    "mfrmr_gpcm_attribution_manifest",
    "mfrmr_gpcm_attribution_arms"
  )
  if (all(vapply(required, exists, logical(1), envir = target_env,
                 mode = "function", inherits = TRUE))) {
    return(invisible(TRUE))
  }
  candidates <- c(
    if (!is.na(mfrmr_gpcm_repilot_source_dir)) {
      file.path(
        mfrmr_gpcm_repilot_source_dir,
        "gpcm-isolated-attribution-pilot-0.2.3.R"
      )
    } else character(0),
    file.path(
      "inst", "validation", "gpcm-isolated-attribution-pilot-0.2.3.R"
    ),
    "gpcm-isolated-attribution-pilot-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) stop("Cannot locate the attribution runner.", call. = FALSE)
  sys.source(path, envir = target_env)
  if (!all(vapply(required, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    stop("The attribution runner did not load completely.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gpcm_repilot_tiers <- function() {
  list(
    feasibility = c(
      "reference", "slope_unit", "slope_strong", "slope_near_zero_high",
      "raters_2", "assignment_weak_bridge", "category_internal_zero",
      "missing_outcome", "interaction_person_rater",
      "diagnostic_local_dependence"
    ),
    core = c(
      "reference", "slope_unit", "slope_strong", "slope_near_zero_high",
      "slope_levels_two", "slope_levels_twelve",
      "categories_k2", "categories_k7", "category_rare_interior",
      "category_dominant_middle", "category_internal_zero",
      "category_boundary_zero", "raters_2", "raters_3",
      "assignment_sparse_connected", "assignment_weak_bridge",
      "assignment_zero_shared", "assignment_routed",
      "assignment_disconnected", "missing_mcar", "missing_rater",
      "missing_outcome", "cells_repeated", "cells_occasion",
      "cells_unequal_weights", "interaction_person_rater",
      "interaction_slope_correlated", "diagnostic_local_dependence",
      "diagnostic_bias", "sample_small"
    ),
    expanded = mfrmr_gpcm_attribution_arms()$ArmId
  )
}

mfrmr_gpcm_repilot_registry <- function(
    tier = c("feasibility", "core", "expanded"), reps = NULL) {
  mfrmr_gpcm_repilot_require_runner()
  tier <- match.arg(tier)
  arms <- mfrmr_gpcm_repilot_tiers()[[tier]]
  reps <- as.integer(if (is.null(reps)) {
    c(feasibility = 2L, core = 5L, expanded = 5L)[[tier]]
  } else reps)
  if (length(reps) != 1L || is.na(reps) || reps < 1L) {
    stop("`reps` must be one positive integer.", call. = FALSE)
  }
  manifest <- mfrmr_gpcm_attribution_manifest("pilot", reps = reps)
  manifest <- manifest[manifest$ArmId %in% arms, , drop = FALSE]
  row.names(manifest) <- NULL
  data.frame(
    Tier = tier,
    Arms = length(unique(manifest$ArmId)),
    Replicates = reps,
    DataCells = length(unique(manifest$DataCellId)),
    AnalysisRows = nrow(manifest),
    RoutesPerDataCell = 4L,
    RunPCA = TRUE,
    Maxit = 120L,
    QuadPoints = 7L,
    ConfirmationAuthorized = FALSE,
    ThresholdStatus = "pilot_required_not_frozen",
    ManifestHash = unique(manifest$ManifestHash),
    stringsAsFactors = FALSE
  )
}

mfrmr_gpcm_repilot_wilson <- function(successes, trials, level = 0.95) {
  if (!is.finite(trials) || trials <= 0L) return(c(Lower = NA, Upper = NA))
  p <- successes / trials
  z <- stats::qnorm(1 - (1 - level) / 2)
  denominator <- 1 + z^2 / trials
  center <- (p + z^2 / (2 * trials)) / denominator
  half <- z * sqrt(p * (1 - p) / trials + z^2 / (4 * trials^2)) /
    denominator
  c(Lower = max(0, center - half), Upper = min(1, center + half))
}

mfrmr_gpcm_repilot_rate_row <- function(data) {
  attempted <- nrow(data)
  summarize_rate <- function(value) {
    value <- as.logical(value)
    value[is.na(value)] <- FALSE
    successes <- sum(value)
    rate <- if (attempted > 0L) successes / attempted else NA_real_
    interval <- mfrmr_gpcm_repilot_wilson(successes, attempted)
    c(
      Count = successes,
      Rate = rate,
      BernoulliMCSE = if (attempted > 0L) {
        sqrt(rate * (1 - rate) / attempted)
      } else NA_real_,
      WilsonLower = interval[["Lower"]],
      WilsonUpper = interval[["Upper"]]
    )
  }
  metrics <- list(
    Executed = data$Executed,
    GenerationSucceeded = data$GenerationSucceeded,
    FitSucceeded = data$FitSucceeded,
    InferenceReady = data$InferenceReady,
    FalseReady = data$FalseReady,
    PairIdentityViolation = data$PairIdentityViolation,
    SlopePrimaryMetricEligible = data$SlopePrimaryMetricEligible,
    NumericExternalEligible = data$NumericExternalEligible
  )
  out <- data.frame(Attempted = attempted, stringsAsFactors = FALSE)
  for (name in names(metrics)) {
    values <- summarize_rate(metrics[[name]])
    for (suffix in names(values)) {
      out[[paste0(name, suffix)]] <- as.numeric(values[[suffix]])
    }
  }
  out
}

mfrmr_gpcm_repilot_rate_summary <- function(results) {
  groups <- split(
    seq_len(nrow(results)),
    interaction(results$ArmId, results$Route, drop = TRUE, lex.order = TRUE)
  )
  rows <- lapply(groups, function(index) {
    data <- results[index, , drop = FALSE]
    cbind(
      data.frame(
        ArmId = data$ArmId[1L],
        ChangedAxis = data$ChangedAxis[1L],
        ChangedLevel = data$ChangedLevel[1L],
        Route = data$Route[1L],
        FitModel = data$FitModel[1L],
        FitMethod = data$FitMethod[1L],
        stringsAsFactors = FALSE
      ),
      mfrmr_gpcm_repilot_rate_row(data)
    )
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_gpcm_repilot_numeric_summary <- function(data, value_names,
                                                group_names) {
  key_data <- lapply(data[group_names], function(value) {
    value <- as.character(value)
    value[is.na(value)] <- "<NA>"
    value
  })
  group_key <- do.call(paste, c(key_data, sep = "\034"))
  groups <- split(
    seq_len(nrow(data)),
    group_key,
    drop = TRUE
  )
  rows <- list()
  k <- 0L
  for (index in groups) {
    group <- data[index, , drop = FALSE]
    for (metric in value_names) {
      if (!metric %in% names(group)) next
      values <- as.numeric(group[[metric]])
      values <- values[is.finite(values)]
      k <- k + 1L
      n <- length(values)
      standard_deviation <- if (n >= 2L) stats::sd(values) else NA_real_
      rows[[k]] <- cbind(
        group[1L, group_names, drop = FALSE],
        data.frame(
          Metric = metric,
          N = n,
          Mean = if (n > 0L) mean(values) else NA_real_,
          SD = standard_deviation,
          MCSE = if (n >= 2L) standard_deviation / sqrt(n) else NA_real_,
          Median = if (n > 0L) stats::median(values) else NA_real_,
          Q95 = if (n > 0L) {
            as.numeric(stats::quantile(values, 0.95, names = FALSE, type = 8))
          } else NA_real_,
          Min = if (n > 0L) min(values) else NA_real_,
          Max = if (n > 0L) max(values) else NA_real_,
          stringsAsFactors = FALSE
        )
      )
    }
  }
  if (length(rows) == 0L) return(data.frame())
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_gpcm_repilot_metric_summary <- function(results) {
  mfrmr_gpcm_repilot_numeric_summary(
    results,
    c(
      "RuntimeSeconds", "Rows", "PositiveWeightRows", "MinCommonPersons",
      "MaxCategoryFraction", "NormalizedCategoryEntropy", "PersonRMSE",
      "RaterRMSE", "CriterionRMSE", "StepRMSE",
      "SlopeOptimizerLogRMSE", "PCAFirstEigenvalue"
    ),
    c("ArmId", "ChangedAxis", "ChangedLevel", "Route", "FitModel",
      "FitMethod")
  )
}

mfrmr_gpcm_repilot_contrast_summary <- function(contrasts) {
  if (nrow(contrasts) == 0L) return(data.frame())
  mfrmr_gpcm_repilot_numeric_summary(
    contrasts,
    c(
      "RuntimeSecondsDelta", "RowsDelta", "MinCommonPersonsDelta",
      "PersonRMSEDelta", "RaterRMSEDelta", "CriterionRMSEDelta",
      "StepRMSEDelta", "SlopeOptimizerLogRMSEDelta", "RuntimeRatio"
    ),
    c("ArmId.Arm", "ChangedAxis.Arm", "ChangedLevel.Arm", "Route",
      "FitModel", "FitMethod")
  )
}

mfrmr_gpcm_repilot_completeness <- function(manifest, results) {
  cells <- unique(manifest[c(
    "DataCellId", "ArmId", "Replicate", "Seed", "ManifestHash"
  )])
  rows <- lapply(seq_len(nrow(cells)), function(i) {
    data <- results[results$DataCellId == cells$DataCellId[i], , drop = FALSE]
    observed_routes <- sort(unique(as.character(data$Route)))
    expected_routes <- sort(c("GPCM_JML", "GPCM_MML", "PCM_JML", "PCM_MML"))
    successful <- data$GenerationSucceeded & !is.na(data$RetainedDataHash)
    hashes <- unique(data$RetainedDataHash[successful])
    data.frame(
      cells[i, , drop = FALSE],
      ExpectedRows = 4L,
      ObservedRows = nrow(data),
      CompleteRouteSet = identical(observed_routes, expected_routes),
      GeneratedRoutes = sum(successful),
      UniqueRetainedHashes = length(hashes),
      PairedDataIdentity = nrow(data) == 4L && all(data$PairedDataIdentity),
      PairIdentityViolation = any(data$PairIdentityViolation, na.rm = TRUE),
      MissingRoutes = paste(setdiff(expected_routes, observed_routes),
                            collapse = ";"),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_gpcm_repilot_analyze <- function(run, tier) {
  if (!inherits(run, "mfrmr_gpcm_isolated_attribution")) {
    stop("`run` must be an isolated-attribution pilot result.", call. = FALSE)
  }
  rates <- mfrmr_gpcm_repilot_rate_summary(run$results)
  metrics <- mfrmr_gpcm_repilot_metric_summary(run$results)
  contrast_metrics <- mfrmr_gpcm_repilot_contrast_summary(run$contrasts)
  completeness <- mfrmr_gpcm_repilot_completeness(run$manifest, run$results)
  total_runtime <- sum(run$results$RuntimeSeconds, na.rm = TRUE)
  data_cells <- length(unique(run$results$DataCellId))
  summary <- data.frame(
    Tier = tier,
    AnalysisRows = nrow(run$results),
    DataCells = data_cells,
    CompleteCells = sum(completeness$CompleteRouteSet),
    IdentityValidCells = sum(completeness$PairedDataIdentity),
    PairIdentityViolations = sum(completeness$PairIdentityViolation),
    FitFailures = sum(!run$results$FitSucceeded),
    FalseReadyRows = sum(run$results$FalseReady, na.rm = TRUE),
    PrimarySlopeEligibleRows = sum(
      run$results$SlopePrimaryMetricEligible, na.rm = TRUE
    ),
    NumericExternalEligibleRows = sum(
      run$results$NumericExternalEligible, na.rm = TRUE
    ),
    TotalFitRuntimeSeconds = total_runtime,
    MeanFitRuntimeSeconds = mean(run$results$RuntimeSeconds, na.rm = TRUE),
    RuntimePerDataCellSeconds = total_runtime / max(1L, data_cells),
    ThresholdStatus = "pilot_required_not_frozen",
    ConfirmationAuthorized = FALSE,
    MinimumReplicatesForCriterionFreeze = NA_integer_,
    Interpretation = paste0(
      "feasibility_and_variance_signal_only;_small_n_MCSE_and_Wilson_",
      "intervals_do_not_authorize_threshold_selection"
    ),
    stringsAsFactors = FALSE
  )
  list(
    summary = summary,
    rate_summary = rates,
    metric_summary = metrics,
    contrast_metric_summary = contrast_metrics,
    completeness = completeness
  )
}

mfrmr_gpcm_repilot_write <- function(x, output_dir) {
  if (!inherits(x, "mfrmr_gpcm_attribution_replicated_pilot") ||
      is.null(x$run) || is.null(x$analysis)) {
    stop("`x` must contain a completed replicated pilot and analysis.",
         call. = FALSE)
  }
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  utils::write.csv(x$registry, file.path(output_dir, "pilot-registry.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$run$manifest,
                   file.path(output_dir, "scenario-manifest.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$run$results, file.path(output_dir, "run-results.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$run$contrasts,
                   file.path(output_dir, "paired-contrasts.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$analysis$summary, file.path(output_dir, "summary.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$analysis$rate_summary,
                   file.path(output_dir, "rate-summary.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$analysis$metric_summary,
                   file.path(output_dir, "metric-summary.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$analysis$contrast_metric_summary,
                   file.path(output_dir, "contrast-metric-summary.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(x$analysis$completeness,
                   file.path(output_dir, "completeness-ledger.csv"),
                   row.names = FALSE, na = "")
  saveRDS(x, file.path(output_dir,
                       "gpcm-attribution-replicated-pilot.rds"))
  invisible(x)
}

mfrmr_run_gpcm_attribution_replicated_pilot <- function(
    tier = c("feasibility", "core", "expanded"), reps = NULL,
    maxit = 120L, quad_points = 7L, run_pca = TRUE,
    dry_run = FALSE, progress = interactive(), output_dir = NULL,
    authorize_core = FALSE, authorize_expanded = FALSE) {
  mfrmr_gpcm_repilot_require_runner()
  tier <- match.arg(tier)
  if (tier == "core" && !isTRUE(dry_run) && !isTRUE(authorize_core)) {
    stop("Core-tier execution requires `authorize_core = TRUE`.",
         call. = FALSE)
  }
  if (tier == "expanded" && !isTRUE(dry_run) &&
      !isTRUE(authorize_expanded)) {
    stop("Expanded-tier execution requires `authorize_expanded = TRUE`.",
         call. = FALSE)
  }
  arms <- mfrmr_gpcm_repilot_tiers()[[tier]]
  registry <- mfrmr_gpcm_repilot_registry(tier, reps = reps)
  if (isTRUE(dry_run)) {
    return(structure(
      list(
        registry = registry,
        arms = arms,
        run = NULL,
        analysis = NULL,
        confirmation_authorized = FALSE
      ),
      class = "mfrmr_gpcm_attribution_replicated_pilot"
    ))
  }
  run <- mfrmr_run_gpcm_isolated_attribution_pilot(
    profile = "pilot", arms = arms, reps = registry$Replicates,
    run_pca = run_pca, maxit = maxit, quad_points = quad_points,
    progress = progress
  )
  analysis <- mfrmr_gpcm_repilot_analyze(run, tier)
  out <- structure(
    list(
      registry = registry,
      arms = arms,
      run = run,
      analysis = analysis,
      confirmation_authorized = FALSE,
      session_info = utils::sessionInfo()
    ),
    class = "mfrmr_gpcm_attribution_replicated_pilot"
  )
  if (!is.null(output_dir)) {
    mfrmr_gpcm_repilot_write(out, output_dir)
  }
  out
}
