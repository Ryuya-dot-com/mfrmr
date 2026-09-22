# Draft.74 paired raw-JML versus extended profile-limit recovery pilot.

mfrmr_jml_profile_recovery_source_dir <- local({
  frames <- sys.frames()
  files <- vapply(frames, function(frame) {
    value <- frame$ofile
    if (is.null(value) || length(value) == 0L) {
      NA_character_
    } else {
      as.character(value)[1L]
    }
  }, character(1))
  files <- files[!is.na(files) & nzchar(files)]
  own_file <- basename(files) ==
    "jml-extreme-profile-recovery-pilot-0.2.3.R"
  if (any(own_file)) files <- files[own_file]
  if (length(files) == 0L) NA_character_ else dirname(normalizePath(
    tail(files, 1L), winslash = "/", mustWork = FALSE
  ))
})

mfrmr_jml_profile_recovery_or <- function(value, replacement) {
  if (is.null(value) || length(value) == 0L) replacement else value
}

mfrmr_jml_profile_recovery_require <- function() {
  target_env <- environment(mfrmr_jml_profile_recovery_require)
  if (exists("mfrmr_jml_profile_limit_refit", envir = target_env,
             inherits = TRUE)) {
    return(invisible(TRUE))
  }
  candidates <- c(
    if (!is.na(mfrmr_jml_profile_recovery_source_dir)) {
      file.path(
        mfrmr_jml_profile_recovery_source_dir,
        "jml-extreme-profile-limit-prototype-0.2.3.R"
      )
    },
    file.path(
      "inst", "validation",
      "jml-extreme-profile-limit-prototype-0.2.3.R"
    ),
    file.path(
      "..", "inst", "validation",
      "jml-extreme-profile-limit-prototype-0.2.3.R"
    ),
    file.path(
      "..", "..", "inst", "validation",
      "jml-extreme-profile-limit-prototype-0.2.3.R"
    ),
    file.path(
      "..", "..", "..", "inst", "validation",
      "jml-extreme-profile-limit-prototype-0.2.3.R"
    )
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) {
    stop("The Draft.73 profile-limit prototype is unavailable.", call. = FALSE)
  }
  sys.source(path, envir = target_env)
  invisible(TRUE)
}

mfrmr_jml_profile_recovery_manifest <- function(
    tier = c("smoke", "pilot")) {
  tier <- match.arg(tier)
  if (identical(tier, "smoke")) {
    grid <- expand.grid(
      Model = c("RSM", "PCM", "GPCM"),
      Information = "low",
      ExtremeFraction = 0.125,
      Replicate = 1L,
      KEEP.OUT.ATTRS = FALSE,
      stringsAsFactors = FALSE
    )
    grid$Persons <- 48L
    grid$Raters <- 3L
    grid$Criteria <- 2L
    grid$Maxit <- 240L
  } else {
    grid <- expand.grid(
      Model = c("RSM", "PCM", "GPCM"),
      Information = c("low", "high"),
      ExtremeFraction = c(0, 0.10, 0.25),
      Replicate = seq_len(5L),
      KEEP.OUT.ATTRS = FALSE,
      stringsAsFactors = FALSE
    )
    grid$Persons <- 80L
    grid$Raters <- ifelse(grid$Information == "low", 3L, 5L)
    grid$Criteria <- ifelse(grid$Information == "low", 2L, 4L)
    grid$Maxit <- 400L
  }
  grid$RatersPerPerson <- grid$Raters
  grid$ResponseRows <- grid$Persons * grid$Raters * grid$Criteria
  grid$ResponsesPerPerson <- grid$Raters * grid$Criteria
  grid$ForcedExtremeN <- 2L * floor(
    grid$Persons * grid$ExtremeFraction / 2L
  )
  grid$ForcedExtremeHighN <- grid$ForcedExtremeN %/% 2L
  grid$ForcedExtremeLowN <- grid$ForcedExtremeN %/% 2L
  grid$Seed <- 740000L + seq_len(nrow(grid)) * 101L
  grid$ManifestRow <- seq_len(nrow(grid))
  grid$Tier <- tier
  grid$ScenarioId <- sprintf(
    "INT-JML-EXT-PROFILE-%s-%s-E%03d-R%02d",
    grid$Model,
    toupper(grid$Information),
    as.integer(round(100 * grid$ExtremeFraction)),
    grid$Replicate
  )
  grid$ContractVersion <-
    "mfrmr-jml-extreme-profile-recovery-pilot-v1"
  grid$Generator <- "simulate_mfrm_data_then_force_signed_extremes_v1"
  grid$RawEstimatorIdentity <- "mfrmr_jml_raw_finite_trace"
  grid$ProfileEstimatorIdentity <- "mfrmr_jml_extended_profile_limit_v1"
  grid$ExtremeAdjustment <- "none"
  grid$BiasCorrection <- "none"
  grid$PersonRecoveryEligible <- FALSE
  grid$StructuralRecoveryEligible <- TRUE
  grid$Reltol <- 1e-10
  grid$Optimizer <- "BFGS"
  grid$LimitCaps <- "4,8,12,16,24,32,48,64"
  grid$LimitTolerance <- 1e-8
  grid[, c(
    "ContractVersion", "ManifestRow", "ScenarioId", "Tier", "Model",
    "Information", "Persons", "Raters", "Criteria", "RatersPerPerson",
    "ResponseRows", "ResponsesPerPerson", "ExtremeFraction",
    "ForcedExtremeN", "ForcedExtremeHighN", "ForcedExtremeLowN",
    "Replicate", "Seed", "Maxit", "Reltol", "Optimizer", "LimitCaps",
    "LimitTolerance", "Generator",
    "RawEstimatorIdentity", "ProfileEstimatorIdentity",
    "ExtremeAdjustment", "BiasCorrection", "PersonRecoveryEligible",
    "StructuralRecoveryEligible"
  )]
}

mfrmr_jml_profile_recovery_slopes <- function(n_criterion) {
  values <- exp(seq(-0.30, 0.30, length.out = n_criterion))
  values / exp(mean(log(values)))
}

mfrmr_jml_profile_recovery_generate <- function(row) {
  model <- as.character(row$Model)
  criteria <- as.integer(row$Criteria)
  slopes <- if (identical(model, "GPCM")) {
    mfrmr_jml_profile_recovery_slopes(criteria)
  } else {
    NULL
  }
  data <- simulate_mfrm_data(
    n_person = as.integer(row$Persons),
    n_rater = as.integer(row$Raters),
    n_criterion = criteria,
    raters_per_person = as.integer(row$RatersPerPerson),
    assignment = "crossed",
    score_levels = 4L,
    model = model,
    step_facet = "Criterion",
    slope_facet = if (identical(model, "GPCM")) "Criterion" else NULL,
    slopes = slopes,
    seed = as.integer(row$Seed)
  )
  truth <- attr(data, "mfrm_truth")
  persons <- sort(unique(as.character(data$Person)))
  n_high <- as.integer(row$ForcedExtremeHighN)
  n_low <- as.integer(row$ForcedExtremeLowN)
  high <- if (n_high > 0L) persons[seq_len(n_high)] else character(0)
  low_start <- n_high + 1L
  low <- if (n_low > 0L) {
    persons[seq.int(low_start, length.out = n_low)]
  } else {
    character(0)
  }
  data$Score[as.character(data$Person) %in% high] <- 4L
  data$Score[as.character(data$Person) %in% low] <- 1L
  attr(data, "mfrm_truth") <- truth
  attr(data, "mfrmr_forced_extremes") <- list(high = high, low = low)
  data
}

mfrmr_jml_profile_recovery_apply <- function(fit, profile) {
  if (!is.list(profile) ||
      !identical(profile$EstimateRole, "extended_jml_profile_limit")) {
    stop("A completed extended profile-limit result is required.",
         call. = FALSE)
  }
  out <- fit
  parameters <- as.data.frame(profile$parameters, stringsAsFactors = FALSE)
  person <- parameters$ParameterClass == "Person"
  if (any(person)) {
    index <- match(
      as.character(out$facets$person$Person),
      as.character(parameters$Level[person])
    )
    replace <- !is.na(index)
    out$facets$person$Estimate[replace] <-
      parameters$ProfileLimitEstimate[person][index[replace]]
  }
  facet <- parameters$ParameterClass == "Facet"
  if (any(facet)) {
    source_key <- paste(parameters$Facet[facet], parameters$Level[facet],
                        sep = "\r")
    target_key <- paste(out$facets$others$Facet, out$facets$others$Level,
                        sep = "\r")
    index <- match(target_key, source_key)
    if (anyNA(index)) {
      stop("Profile facet rows do not align with the fitted facet table.",
           call. = FALSE)
    }
    out$facets$others$Estimate <-
      parameters$ProfileLimitEstimate[facet][index]
  }
  step <- parameters$ParameterClass == "Step"
  if (sum(step) != nrow(out$steps)) {
    stop("Profile step rows do not align with the fitted step table.",
         call. = FALSE)
  }
  out$steps$Estimate <- parameters$ProfileLimitEstimate[step]
  if (identical(as.character(fit$config$model), "GPCM")) {
    slope <- parameters$ParameterClass == "Slope"
    index <- match(
      as.character(out$slopes$SlopeFacet),
      as.character(parameters$Level[slope])
    )
    if (anyNA(index)) {
      stop("Profile slope rows do not align with the fitted slope table.",
           call. = FALSE)
    }
    out$slopes$Estimate <- parameters$ProfileLimitEstimate[slope][index]
  }
  for (name in intersect(
    c("SE", "S.E.", "ModelSE", "Std.Error", "StdError"),
    names(out$facets$others)
  )) {
    out$facets$others[[name]] <- NA_real_
  }
  for (name in intersect(
    c("SE", "S.E.", "ModelSE", "Std.Error", "StdError"),
    names(out$slopes)
  )) {
    out$slopes[[name]] <- NA_real_
  }
  out
}

mfrmr_jml_profile_recovery_rows <- function(fit, truth, manifest_row,
                                             estimator_variant) {
  rows <- mfrmr_jml_profile_recovery_internal(
    "recovery_rows_from_fit"
  )(
    fit = fit,
    truth = truth,
    rep = as.integer(manifest_row$ManifestRow),
    include_person = FALSE
  )
  rows$ScenarioId <- as.character(manifest_row$ScenarioId)
  rows$Model <- as.character(manifest_row$Model)
  rows$Information <- as.character(manifest_row$Information)
  rows$ExtremeFraction <- as.numeric(manifest_row$ExtremeFraction)
  rows$EstimatorVariant <- estimator_variant
  rows$ExtremeAdjustment <- "none"
  rows$BiasCorrection <- "none"
  rows$PersonRecoveryEligible <- FALSE
  rows
}

mfrmr_jml_profile_recovery_internal <- function(name) {
  getFromNamespace(name, "mfrmr")
}

mfrmr_jml_profile_recovery_fit_one <- function(row) {
  mfrmr_jml_profile_recovery_require()
  data <- mfrmr_jml_profile_recovery_generate(row)
  truth <- attr(data, "mfrm_truth")
  forced <- attr(data, "mfrmr_forced_extremes")
  fit_args <- list(
    data = data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 1,
    rating_max = 4,
    keep_original = TRUE,
    method = "JML",
    model = as.character(row$Model),
    maxit = as.integer(row$Maxit),
    reltol = as.numeric(row$Reltol),
    optimizer = as.character(row$Optimizer)
  )
  if (!identical(as.character(row$Model), "RSM")) {
    fit_args$step_facet <- "Criterion"
  }
  if (identical(as.character(row$Model), "GPCM")) {
    fit_args$slope_facet <- "Criterion"
  }
  started <- proc.time()[["elapsed"]]
  fit <- suppressMessages(suppressWarnings(do.call(fit_mfrm, fit_args)))
  raw_elapsed <- proc.time()[["elapsed"]] - started
  person <- as.data.frame(fit$facets$person, stringsAsFactors = FALSE)
  free_extreme <- person$ParameterStatus %in%
    c("unbounded_low", "unbounded_high")
  forced_ids <- c(forced$high, forced$low)
  forced_status <- person$ParameterStatus[
    match(forced_ids, as.character(person$Person))
  ]
  forced_expected <- c(
    rep("unbounded_high", length(forced$high)),
    rep("unbounded_low", length(forced$low))
  )
  forced_typed <- all(forced_status %in%
                        c("unbounded_low", "unbounded_high"))
  forced_direction_correct <- identical(
    as.character(forced_status), as.character(forced_expected)
  )

  raw_rows <- mfrmr_jml_profile_recovery_rows(
    fit, truth, row, "raw_finite_jml"
  )
  profile_started <- proc.time()[["elapsed"]]
  profile <- if (sum(free_extreme) > 0L) {
    suppressWarnings(mfrmr_jml_profile_limit_refit(
      fit,
      caps = as.numeric(strsplit(
        as.character(row$LimitCaps), ",", fixed = TRUE
      )[[1L]]),
      maxit = as.integer(row$Maxit),
      reltol = as.numeric(row$Reltol),
      optimizer = as.character(row$Optimizer),
      limit_tolerance = as.numeric(row$LimitTolerance)
    ))
  } else {
    list(
      State = "no_free_extreme_persons",
      Complete = TRUE,
      EstimateRole = "profile_limit_noop",
      ProfileLimitGain = 0,
      TerminalLimitGap = 0,
      MaximumAbsoluteStructuralChange = 0,
      ExcludedPersons = character(0),
      ReadinessEffect = "none_prototype_only"
    )
  }
  profile_elapsed <- proc.time()[["elapsed"]] - profile_started
  profile_ok <- identical(profile$State, "profile_limit_refit_verified") ||
    identical(profile$State, "no_free_extreme_persons")
  profile_fit <- if (identical(
    profile$EstimateRole, "extended_jml_profile_limit"
  )) {
    mfrmr_jml_profile_recovery_apply(fit, profile)
  } else {
    fit
  }
  profile_rows <- mfrmr_jml_profile_recovery_rows(
    profile_fit, truth, row, "extended_profile_limit"
  )
  profile_rows$SE <- NA_real_
  profile_rows$Covered95 <- NA
  raw_severity <- as.character(fit$summary$ConvergenceSeverity[1])
  raw_readiness <- as.character(fit$readiness$fit$FitReadiness[1])
  raw_inference_ready <- isTRUE(fit$readiness$fit$InferenceReady[1])
  for (variant in c("raw_rows", "profile_rows")) {
    value <- get(variant)
    value$RawConvergenceSeverity <- raw_severity
    value$RawFitReadiness <- raw_readiness
    value$RawInferenceReady <- raw_inference_ready
    value$ProfileState <- as.character(profile$State)
    value$ProfileOK <- profile_ok
    value$ForcedExtremeN <- as.integer(row$ForcedExtremeN)
    value$ActualFreeExtremeN <- sum(free_extreme)
    assign(variant, value)
  }

  raw_key <- paste(
    raw_rows$ParameterType, raw_rows$Facet, raw_rows$Level,
    raw_rows$Subparameter, sep = "\r"
  )
  profile_key <- paste(
    profile_rows$ParameterType, profile_rows$Facet, profile_rows$Level,
    profile_rows$Subparameter, sep = "\r"
  )
  index <- match(raw_key, profile_key)
  paired_complete <- !anyNA(index)
  max_pair_difference <- if (paired_complete && nrow(raw_rows) > 0L) {
    max(abs(
      profile_rows$EstimateAligned[index] - raw_rows$EstimateAligned
    ))
  } else {
    NA_real_
  }
  inference_ready <- raw_inference_ready
  false_ready <- sum(free_extreme) > 0L && inference_ready
  run <- data.frame(
    ContractVersion = as.character(row$ContractVersion),
    ManifestRow = as.integer(row$ManifestRow),
    ScenarioId = as.character(row$ScenarioId),
    Model = as.character(row$Model),
    Information = as.character(row$Information),
    ExtremeFraction = as.numeric(row$ExtremeFraction),
    ForcedExtremeN = as.integer(row$ForcedExtremeN),
    ForcedTypedN = sum(forced_status %in%
                         c("unbounded_low", "unbounded_high")),
    ForcedTyped = forced_typed,
    ForcedDirectionCorrect = forced_direction_correct,
    ActualFreeExtremeN = sum(free_extreme),
    SpontaneousExtremeN = sum(free_extreme) - sum(
      as.character(person$Person[free_extreme]) %in% forced_ids
    ),
    RawFitOK = TRUE,
    RawConvergenceSeverity = raw_severity,
    RawFitReadiness = raw_readiness,
    RawInferenceReady = inference_ready,
    FalseReady = false_ready,
    ProfileState = as.character(profile$State),
    ProfileComplete = isTRUE(profile$Complete),
    ProfileOK = profile_ok,
    ProfileLimitGain = as.numeric(profile$ProfileLimitGain),
    TerminalLimitGap = as.numeric(profile$TerminalLimitGap),
    MaximumAbsoluteStructuralChange = as.numeric(
      profile$MaximumAbsoluteStructuralChange
    ),
    PairedRowsComplete = paired_complete,
    MaximumAbsolutePairedChange = max_pair_difference,
    RawElapsedSeconds = raw_elapsed,
    ProfileElapsedSeconds = profile_elapsed,
    RecoveryRowsPerEstimator = nrow(raw_rows),
    Error = "",
    stringsAsFactors = FALSE
  )
  list(
    run = run,
    recovery = dplyr::bind_rows(raw_rows, profile_rows),
    fit = fit,
    profile = profile
  )
}

mfrmr_jml_profile_recovery_error_row <- function(row, error) {
  data.frame(
    ContractVersion = as.character(row$ContractVersion),
    ManifestRow = as.integer(row$ManifestRow),
    ScenarioId = as.character(row$ScenarioId),
    Model = as.character(row$Model),
    Information = as.character(row$Information),
    ExtremeFraction = as.numeric(row$ExtremeFraction),
    ForcedExtremeN = as.integer(row$ForcedExtremeN),
    ForcedTypedN = NA_integer_,
    ForcedTyped = FALSE,
    ForcedDirectionCorrect = FALSE,
    ActualFreeExtremeN = NA_integer_,
    SpontaneousExtremeN = NA_integer_,
    RawFitOK = FALSE,
    RawConvergenceSeverity = NA_character_,
    RawFitReadiness = NA_character_,
    RawInferenceReady = FALSE,
    FalseReady = FALSE,
    ProfileState = "not_run_raw_failure",
    ProfileComplete = FALSE,
    ProfileOK = FALSE,
    ProfileLimitGain = NA_real_,
    TerminalLimitGap = NA_real_,
    MaximumAbsoluteStructuralChange = NA_real_,
    PairedRowsComplete = FALSE,
    MaximumAbsolutePairedChange = NA_real_,
    RawElapsedSeconds = NA_real_,
    ProfileElapsedSeconds = NA_real_,
    RecoveryRowsPerEstimator = 0L,
    Error = conditionMessage(error),
    stringsAsFactors = FALSE
  )
}

mfrmr_run_jml_profile_recovery_pilot <- function(
    tier = c("smoke", "pilot"),
    dry_run = FALSE,
    authorize_pilot = FALSE,
    progress = interactive()) {
  tier <- match.arg(tier)
  manifest <- mfrmr_jml_profile_recovery_manifest(tier)
  if (isTRUE(dry_run)) return(manifest)
  if (identical(tier, "pilot") && !isTRUE(authorize_pilot)) {
    stop(
      "The 90-dataset Draft.74 pilot requires `authorize_pilot = TRUE`; ",
      "use `dry_run = TRUE` to inspect its frozen manifest.",
      call. = FALSE
    )
  }
  mfrmr_jml_profile_recovery_require()
  outputs <- vector("list", nrow(manifest))
  run_rows <- vector("list", nrow(manifest))
  recovery_rows <- vector("list", nrow(manifest))
  for (i in seq_len(nrow(manifest))) {
    if (isTRUE(progress)) {
      message("[", i, "/", nrow(manifest), "] ", manifest$ScenarioId[i])
    }
    row <- manifest[i, , drop = FALSE]
    value <- tryCatch(
      mfrmr_jml_profile_recovery_fit_one(row),
      error = function(e) e
    )
    if (inherits(value, "error")) {
      run_rows[[i]] <- mfrmr_jml_profile_recovery_error_row(row, value)
      recovery_rows[[i]] <- tibble::tibble()
      outputs[[i]] <- value
    } else {
      run_rows[[i]] <- value$run
      recovery_rows[[i]] <- value$recovery
      outputs[[i]] <- value
    }
  }
  runs <- dplyr::bind_rows(run_rows)
  recovery <- dplyr::bind_rows(recovery_rows)
  summary <- if (nrow(recovery) > 0L) {
    recovery |>
      dplyr::group_by(
        .data$Model, .data$Information, .data$ExtremeFraction,
        .data$EstimatorVariant, .data$ParameterType, .data$Facet,
        .data$ComparisonScale
      ) |>
      dplyr::summarise(
        Rows = dplyr::n(),
        Reps = dplyr::n_distinct(.data$rep),
        Bias = mean(.data$ErrorAligned, na.rm = TRUE),
        RMSE = sqrt(mean(.data$ErrorAligned^2, na.rm = TRUE)),
        MAE = mean(abs(.data$ErrorAligned), na.rm = TRUE),
        MeanSE = if (all(is.na(.data$SE))) NA_real_ else
          mean(.data$SE, na.rm = TRUE),
        SEAvailableRate = mean(is.finite(.data$SE) & .data$SE > 0),
        .groups = "drop"
      )
  } else {
    tibble::tibble()
  }
  contract_passed <- nrow(runs) == nrow(manifest) &&
    all(runs$RawFitOK) && all(runs$ForcedTyped) &&
    all(runs$ForcedDirectionCorrect) &&
    all(runs$ProfileOK) && all(runs$PairedRowsComplete) &&
    !any(runs$FalseReady)
  list(
    ContractVersion = "mfrmr-jml-extreme-profile-recovery-pilot-v1",
    Tier = tier,
    Manifest = manifest,
    Runs = runs,
    Recovery = recovery,
    Summary = summary,
    Outputs = outputs,
    ContractPassed = contract_passed,
    EvidenceReady = FALSE,
    ReadinessEffect = "none_pilot_only",
    Limitations = paste(
      "Calibration-only paired structural recovery. No Person recovery,",
      "coverage claim, threshold, preferred estimator, public option,",
      "bias correction, checklist promotion, or confirmation decision."
    )
  )
}
