# Small paired PCM/GPCM JML calibration for the 0.2.3 comparison contract.
#
# This repository-only runner fits both models to the same simulated response
# data under unit and moderate Criterion-owned slope regimes. It deliberately
# estimates no selection rate and cannot promote either model or the GPCM JML
# route. A finite likelihood difference from a non-ready fit is retained only
# as an optimizer trace.

mfrmr_pgjp_specification <- "0.2.3-draft.1"
mfrmr_pgjp_contract <- "mfrmr_pcm_gpcm_jml_paired_calibration_v1"

mfrmr_pgjp_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_pgjp_require_support <- function() {
  required <- c(
    "build_mfrm_sim_spec", "simulate_mfrm_data", "fit_mfrm",
    "build_weighting_review"
  )
  missing <- required[!vapply(required, exists, logical(1), mode = "function")]
  if (length(missing) > 0L) {
    stop(
      "Load the development package before running this calibration; missing: ",
      paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Package `digest` is required for paired-data identity.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_pgjp_manifest <- function(profile = c("smoke", "pilot")) {
  profile <- match.arg(profile)
  repetitions <- if (identical(profile, "smoke")) 1L else 3L
  regimes <- data.frame(
    SlopeRegime = c("unit_slopes", "moderate"),
    SeedBase = c(613000L, 613100L),
    stringsAsFactors = FALSE
  )
  out <- do.call(rbind, lapply(seq_len(nrow(regimes)), function(i) {
    data.frame(
      Profile = profile,
      SlopeRegime = regimes$SlopeRegime[[i]],
      Replicate = seq_len(repetitions),
      Seed = regimes$SeedBase[[i]] + seq_len(repetitions),
      stringsAsFactors = FALSE
    )
  }))
  row.names(out) <- NULL
  out$ScenarioId <- sprintf(
    "PGJP-%s-%s-R%02d",
    toupper(substr(profile, 1L, 1L)),
    ifelse(out$SlopeRegime == "unit_slopes", "UNIT", "MOD"),
    out$Replicate
  )
  out$NPersons <- 40L
  out$NRaters <- 3L
  out$NCriteria <- 4L
  out$NCategories <- 4L
  out$Design <- "complete_crossed"
  out$StepOwner <- "Criterion"
  out$SlopeOwner <- "Criterion"
  out$Estimator <- "JML"
  out$Maxit <- 100L
  out$CalibrationOnly <- TRUE
  out$ModelSelectionAuthorized <- FALSE
  out$BroadSimulationAuthorized <- FALSE
  out$ConfirmationAuthorized <- FALSE
  out
}

mfrmr_pgjp_thresholds <- function(levels, n_categories = 4L) {
  n_steps <- as.integer(n_categories) - 1L
  base <- seq(-1.35, 1.35, length.out = n_steps)
  offsets <- seq(-0.25, 0.25, length.out = length(levels))
  do.call(rbind, lapply(seq_along(levels), function(i) {
    data.frame(
      StepFacet = levels[[i]],
      StepIndex = seq_len(n_steps),
      Estimate = base + offsets[[i]],
      stringsAsFactors = FALSE
    )
  }))
}

mfrmr_pgjp_slopes <- function(levels, regime) {
  log_slope <- switch(
    as.character(regime),
    unit_slopes = rep(0, length(levels)),
    moderate = seq(-0.25, 0.25, length.out = length(levels)),
    stop("Unknown paired calibration slope regime: ", regime, call. = FALSE)
  )
  log_slope <- log_slope - mean(log_slope)
  stats::setNames(exp(log_slope), levels)
}

mfrmr_pgjp_capture <- function(expr) {
  warnings <- character(0)
  value <- withCallingHandlers(
    tryCatch(expr, error = function(e) e),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  list(value = value, warnings = unique(warnings))
}

mfrmr_pgjp_inference_ready <- function(fit) {
  if (exists("mfrm_inference_ready", mode = "function")) {
    return(isTRUE(mfrm_inference_ready(fit)))
  }
  summary_row <- fit$summary
  is.data.frame(summary_row) && nrow(summary_row) > 0L &&
    "InferenceReady" %in% names(summary_row) &&
    isTRUE(as.logical(summary_row$InferenceReady[[1L]]))
}

mfrmr_pgjp_slope_recovery <- function(fit, truth) {
  slope_table <- fit$slopes
  if (!is.data.frame(slope_table) || nrow(slope_table) < 1L) {
    return(c(N = 0, MaxAbsCenteredLogSlope = NA_real_, LogRMSE = NA_real_))
  }
  estimate_column <- if ("OptimizerEstimate" %in% names(slope_table)) {
    "OptimizerEstimate"
  } else {
    "Estimate"
  }
  estimate <- suppressWarnings(as.numeric(slope_table[[estimate_column]]))
  names(estimate) <- as.character(slope_table$SlopeFacet)
  truth_slope <- truth$slope_table
  if (!is.data.frame(truth_slope)) {
    return(c(N = 0, MaxAbsCenteredLogSlope = NA_real_, LogRMSE = NA_real_))
  }
  truth_value <- suppressWarnings(as.numeric(truth_slope$Estimate))
  names(truth_value) <- as.character(truth_slope$SlopeFacet)
  common <- intersect(names(truth_value), names(estimate))
  ok <- is.finite(truth_value[common]) & truth_value[common] > 0 &
    is.finite(estimate[common]) & estimate[common] > 0
  common <- common[ok]
  if (length(common) < 1L) {
    return(c(N = 0, MaxAbsCenteredLogSlope = NA_real_, LogRMSE = NA_real_))
  }
  fitted_log <- log(estimate[common])
  fitted_log <- fitted_log - mean(fitted_log)
  truth_log <- log(truth_value[common])
  truth_log <- truth_log - mean(truth_log)
  c(
    N = length(common),
    MaxAbsCenteredLogSlope = max(abs(fitted_log)),
    LogRMSE = sqrt(mean((fitted_log - truth_log)^2))
  )
}

mfrmr_pgjp_empty_result <- function(row, state, error = NA_character_) {
  data.frame(
    ScenarioId = as.character(row$ScenarioId),
    SlopeRegime = as.character(row$SlopeRegime),
    Replicate = as.integer(row$Replicate),
    Seed = as.integer(row$Seed),
    Executed = TRUE,
    PairFitSucceeded = FALSE,
    RunState = as.character(state),
    Error = as.character(error),
    Warnings = NA_character_,
    DataSHA256 = NA_character_,
    Rows = NA_integer_,
    CategoryCounts = NA_character_,
    PCMInferenceReady = FALSE,
    GPCMInferenceReady = FALSE,
    EvidenceTier = NA_character_,
    ObservedLogLikDifference = NA_real_,
    LogLikDifferenceStatus = NA_character_,
    FittedSlopeCount = 0L,
    MaxAbsCenteredLogSlope = NA_real_,
    SlopeLogRMSE = NA_real_,
    FormalModelSelectionAvailable = FALSE,
    SelectionRoute = NA_character_,
    PCMvsGPCMLRT = NA_character_,
    FACETSComparisonRole = NA_character_,
    CalibrationOnly = TRUE,
    ModelSelectionAuthorized = FALSE,
    BroadSimulationAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_pgjp_run_one <- function(row) {
  mfrmr_pgjp_require_support()
  row <- as.list(row)
  criteria <- sprintf("C%02d", seq_len(as.integer(row$NCriteria)))
  slopes <- mfrmr_pgjp_slopes(criteria, row$SlopeRegime)
  built <- mfrmr_pgjp_capture(build_mfrm_sim_spec(
    n_person = as.integer(row$NPersons),
    n_rater = as.integer(row$NRaters),
    n_criterion = as.integer(row$NCriteria),
    raters_per_person = as.integer(row$NRaters),
    score_levels = as.integer(row$NCategories),
    theta_sd = 1,
    rater_sd = 0.45,
    criterion_sd = 0.30,
    thresholds = mfrmr_pgjp_thresholds(criteria, row$NCategories),
    slopes = slopes,
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    assignment = "crossed"
  ))
  if (inherits(built$value, "error")) {
    return(mfrmr_pgjp_empty_result(
      row, "generation_failed", conditionMessage(built$value)
    ))
  }
  generated <- mfrmr_pgjp_capture(simulate_mfrm_data(
    sim_spec = built$value,
    seed = as.integer(row$Seed)
  ))
  if (inherits(generated$value, "error")) {
    return(mfrmr_pgjp_empty_result(
      row, "generation_failed", conditionMessage(generated$value)
    ))
  }
  data <- generated$value
  truth <- attr(data, "mfrm_truth")
  data_hash <- digest::digest(
    data[, c("Person", "Rater", "Criterion", "Score"), drop = FALSE],
    algo = "sha256"
  )
  common_fit_args <- list(
    data = data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 1L,
    rating_max = as.integer(row$NCategories),
    keep_original = TRUE,
    method = "JML",
    step_facet = "Criterion",
    maxit = as.integer(row$Maxit)
  )
  pcm <- mfrmr_pgjp_capture(do.call(
    fit_mfrm, c(common_fit_args, list(model = "PCM"))
  ))
  gpcm <- mfrmr_pgjp_capture(do.call(
    fit_mfrm,
    c(common_fit_args, list(model = "GPCM", slope_facet = "Criterion"))
  ))
  warnings <- unique(c(
    built$warnings, generated$warnings, pcm$warnings, gpcm$warnings
  ))
  if (inherits(pcm$value, "error") || inherits(gpcm$value, "error")) {
    errors <- c(
      if (inherits(pcm$value, "error")) paste0("PCM: ", conditionMessage(pcm$value)),
      if (inherits(gpcm$value, "error")) paste0("GPCM: ", conditionMessage(gpcm$value))
    )
    out <- mfrmr_pgjp_empty_result(row, "fit_failed", paste(errors, collapse = " | "))
    out$Warnings <- paste(warnings, collapse = " | ")
    out$DataSHA256 <- data_hash
    out$Rows <- nrow(data)
    return(out)
  }
  reviewed <- mfrmr_pgjp_capture(build_weighting_review(
    pcm$value, gpcm$value, theta_points = 21L, top_n = 4L
  ))
  if (inherits(reviewed$value, "error")) {
    out <- mfrmr_pgjp_empty_result(
      row, "comparison_failed", conditionMessage(reviewed$value)
    )
    out$Warnings <- paste(c(warnings, reviewed$warnings), collapse = " | ")
    out$DataSHA256 <- data_hash
    out$Rows <- nrow(data)
    return(out)
  }
  contract <- as.data.frame(reviewed$value$comparison_contract)
  recovery <- mfrmr_pgjp_slope_recovery(gpcm$value, truth)
  counts <- table(factor(data$Score, levels = seq_len(row$NCategories)))
  out <- mfrmr_pgjp_empty_result(row, "paired_fit_retained")
  out$PairFitSucceeded <- TRUE
  out$Warnings <- paste(c(warnings, reviewed$warnings), collapse = " | ")
  out$DataSHA256 <- data_hash
  out$Rows <- nrow(data)
  out$CategoryCounts <- paste(as.integer(counts), collapse = ";")
  out$PCMInferenceReady <- mfrmr_pgjp_inference_ready(pcm$value)
  out$GPCMInferenceReady <- mfrmr_pgjp_inference_ready(gpcm$value)
  out$EvidenceTier <- as.character(contract$EvidenceTier[[1L]])
  out$ObservedLogLikDifference <- as.numeric(
    contract$ObservedLogLikDifference[[1L]]
  )
  out$LogLikDifferenceStatus <- as.character(
    contract$LogLikDifferenceStatus[[1L]]
  )
  out$FittedSlopeCount <- as.integer(recovery[["N"]])
  out$MaxAbsCenteredLogSlope <- as.numeric(
    recovery[["MaxAbsCenteredLogSlope"]]
  )
  out$SlopeLogRMSE <- as.numeric(recovery[["LogRMSE"]])
  out$FormalModelSelectionAvailable <- isTRUE(
    contract$FormalModelSelectionAvailable[[1L]]
  )
  out$SelectionRoute <- as.character(contract$SelectionRoute[[1L]])
  out$PCMvsGPCMLRT <- as.character(contract$PCMvsGPCMLRT[[1L]])
  out$FACETSComparisonRole <- as.character(contract$FACETSComparisonRole[[1L]])
  out
}

mfrmr_pgjp_validate_results <- function(results, manifest) {
  mfrmr_pgjp_assert(
    is.data.frame(results) && nrow(results) == nrow(manifest) &&
      identical(as.character(results$ScenarioId), as.character(manifest$ScenarioId)),
    "Paired calibration result rows do not match the declared manifest."
  )
  mfrmr_pgjp_assert(
    all(results$PairFitSucceeded) && all(results$Rows == 480L) &&
      all(results$FittedSlopeCount == 4L) &&
      all(nchar(results$DataSHA256) == 64L),
    "Paired fitting, row support, or paired-data identity is incomplete."
  )
  mfrmr_pgjp_assert(
    all(grepl("^jml_", results$EvidenceTier)) &&
      all(!results$FormalModelSelectionAvailable) &&
      all(results$SelectionRoute ==
            "withheld_JML_has_no_automatic_PCM_GPCM_selection") &&
      all(results$PCMvsGPCMLRT == "withheld_current_scope"),
    "JML optimizer evidence was incorrectly promoted to model selection."
  )
  mfrmr_pgjp_assert(
    all(results$FACETSComparisonRole ==
          "PCM_JML_side_only_no_FACETS_free_slope_GPCM_counterpart"),
    "FACETS must remain a comparator for the PCM/JML side only."
  )
  mfrmr_pgjp_assert(
    all(results$CalibrationOnly) &&
      all(!results$ModelSelectionAuthorized) &&
      all(!results$BroadSimulationAuthorized) &&
      all(!results$ConfirmationAuthorized),
    "The paired calibration cannot authorize selection, broad simulation, or confirmation."
  )
  invisible(TRUE)
}

mfrmr_pgjp_summary <- function(results) {
  rows <- lapply(split(results, results$SlopeRegime), function(data) {
    data.frame(
      SlopeRegime = data$SlopeRegime[[1L]],
      PlannedPairs = nrow(data),
      SuccessfulPairs = sum(data$PairFitSucceeded),
      PCMInferenceReady = sum(data$PCMInferenceReady),
      GPCMInferenceReady = sum(data$GPCMInferenceReady),
      MeanLogLikDifference = mean(data$ObservedLogLikDifference),
      MeanMaxAbsCenteredLogSlope = mean(data$MaxAbsCenteredLogSlope),
      MeanSlopeLogRMSE = mean(data$SlopeLogRMSE),
      FormalSelections = sum(data$FormalModelSelectionAvailable),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out <- out[
    match(c("unit_slopes", "moderate"), out$SlopeRegime), , drop = FALSE
  ]
  row.names(out) <- NULL
  out
}

mfrmr_run_pcm_gpcm_jml_paired_calibration <- function(
    profile = c("smoke", "pilot"), execute = TRUE, progress = interactive()) {
  profile <- match.arg(profile)
  manifest <- mfrmr_pgjp_manifest(profile)
  if (!isTRUE(execute)) {
    return(list(
      Specification = mfrmr_pgjp_specification,
      Contract = mfrmr_pgjp_contract,
      manifest = manifest,
      results = data.frame(),
      summary = data.frame(),
      CalibrationOnly = TRUE,
      ModelSelectionAuthorized = FALSE,
      BroadSimulationAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ))
  }
  rows <- vector("list", nrow(manifest))
  for (i in seq_len(nrow(manifest))) {
    if (isTRUE(progress)) {
      message("[", i, "/", nrow(manifest), "] ", manifest$ScenarioId[[i]])
    }
    rows[[i]] <- mfrmr_pgjp_run_one(manifest[i, , drop = FALSE])
  }
  results <- do.call(rbind, rows)
  row.names(results) <- NULL
  mfrmr_pgjp_validate_results(results, manifest)
  list(
    Specification = mfrmr_pgjp_specification,
    Contract = mfrmr_pgjp_contract,
    manifest = manifest,
    results = results,
    summary = mfrmr_pgjp_summary(results),
    CalibrationOnly = TRUE,
    ModelSelectionAuthorized = FALSE,
    BroadSimulationAuthorized = FALSE,
    ConfirmationAuthorized = FALSE
  )
}
