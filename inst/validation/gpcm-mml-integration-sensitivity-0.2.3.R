# Fixed-grid GPCM MML integration sensitivity for mfrmr 0.2.3 Draft.68.

mfrmr_gpcm_mml_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "gpcm-mml-integration-sensitivity-0\\.2\\.3\\.R$", files
  )]
  if (length(hit) == 0L) NA_character_ else {
    dirname(normalizePath(tail(hit, 1L), winslash = "/", mustWork = FALSE))
  }
})

mfrmr_gpcm_mml_runtime_sha256 <-
  "31c87d7a888ca760afa02476f1c226bae148403475e34b75eefaaa9679522920"
mfrmr_gpcm_mml_owner_execution_sha256 <-
  "f96895c9325e15390c5fd896a687a47cf786f6b4f71af94c3481753991e38037"
mfrmr_gpcm_mml_quad_points <- c(31L, 61L, 91L)

mfrmr_gpcm_mml_load_support <- function() {
  if (is.na(mfrmr_gpcm_mml_source_dir)) {
    stop("Cannot resolve the MML sensitivity source directory.",
         call. = FALSE)
  }
  owner_runner <- file.path(
    mfrmr_gpcm_mml_source_dir, "gpcm-owner-specific-pilot-0.2.3.R"
  )
  if (!exists(
    "mfrmr_gpcm_owner_manifest", envir = .GlobalEnv,
    mode = "function", inherits = FALSE
  )) {
    sys.source(owner_runner, envir = .GlobalEnv)
  }
  mfrmr_gpcm_owner_require_support()
  runtime <- mfrmr_gpcm_repilot_runtime_package_identity()
  if (!identical(
    as.character(runtime$PackageSHA256), mfrmr_gpcm_mml_runtime_sha256
  )) {
    stop("The loaded runtime is not the registered Draft.68 MML build.",
         call. = FALSE)
  }
  invisible(runtime)
}

mfrmr_gpcm_mml_contract_path <- function() {
  path <- file.path(
    mfrmr_gpcm_mml_source_dir,
    "gpcm-mml-integration-sensitivity-contract-0.2.3.md"
  )
  if (!file.exists(path)) stop("The MML sensitivity contract is missing.",
                               call. = FALSE)
  path
}

mfrmr_gpcm_mml_manifest <- function(profile = c("smoke", "pilot")) {
  profile <- match.arg(profile)
  mfrmr_gpcm_mml_load_support()
  owner <- mfrmr_gpcm_owner_manifest(profile)
  designs <- if (identical(profile, "pilot")) {
    c("core", "weak_bridge", "range_restricted", "zero_shared")
  } else {
    c("core", "weak_bridge")
  }
  out <- owner[
    owner$Estimator == "MML" & owner$DesignId %in% designs,
    , drop = FALSE
  ]
  out <- out[order(
    match(out$SlopeOwner, c("Criterion", "Rater")),
    match(out$DesignId, designs), out$Replicate
  ), , drop = FALSE]
  row.names(out) <- NULL
  out$DatasetId <- out$ScenarioId
  out$SensitivitySchema <- "mfrmr-gpcm-mml-integration-dataset-v1"
  out$QuadraturePoints <- paste(mfrmr_gpcm_mml_quad_points, collapse = ";")
  out$CommonEvaluationQuadrature <- 91L
  out$Maxit <- if (identical(profile, "pilot")) 400L else 20L
  out$MmlEngine <- "direct"
  out$Optimizer <- "auto"
  out$SourceOwnerExecutionSHA256 <- mfrmr_gpcm_mml_owner_execution_sha256
  out$ConfirmationAuthorized <- FALSE
  out$ConfirmationEvidence <- FALSE
  out$ThresholdStatus <- "integration_sensitivity_not_frozen"
  out$ReleaseUse <- "calibration_integration_only"
  expected <- if (identical(profile, "pilot")) 40L else 4L
  if (nrow(out) != expected || anyDuplicated(out$DatasetId)) {
    stop("The MML sensitivity manifest violates its frozen dataset panel.",
         call. = FALSE)
  }
  out
}

mfrmr_gpcm_mml_validate_source_owner <- function(source_dir) {
  if (is.null(source_dir) || !dir.exists(source_dir)) {
    stop("The completed Draft.66 owner bundle is required.", call. = FALSE)
  }
  completion <- mfrmr_gpcm_owner_validate_completion(
    source_dir, mfrmr_gpcm_mml_owner_execution_sha256
  )
  owner_rds <- file.path(source_dir, "gpcm-owner-specific-pilot.rds")
  source <- readRDS(owner_rds)
  source_ids <- as.character(source$results$ScenarioId)
  list(
    completion = completion,
    source_ids = source_ids,
    source_rds_sha256 = mfrmr_gpcm_repilot_hash_file(owner_rds)
  )
}

mfrmr_gpcm_mml_internal <- function(name) {
  getFromNamespace(name, "mfrmr")
}

mfrmr_gpcm_mml_common_nll <- function(fit, quad_points = 91L) {
  config <- fit$config
  prep <- fit$prep
  idx <- mfrmr_gpcm_mml_internal("build_indices")(
    prep,
    step_facet = config$step_facet,
    slope_facet = config$slope_facet,
    interaction_specs = config$interaction_specs
  )
  sizes <- mfrmr_gpcm_mml_internal("build_param_sizes")(config)
  quad <- mfrmr_gpcm_mml_internal("gauss_hermite_normal")(
    as.integer(quad_points)
  )
  as.numeric(mfrmr_gpcm_mml_internal("mfrm_loglik_mml")(
    fit$opt$par, idx, config, sizes, quad
  ))
}

mfrmr_gpcm_mml_named_vector <- function(fit, component) {
  if (identical(component, "log_slope")) {
    table <- as.data.frame(fit$slopes, stringsAsFactors = FALSE)
    value <- if ("OptimizerLogEstimate" %in% names(table)) {
      table$OptimizerLogEstimate
    } else table$LogEstimate
    return(stats::setNames(as.numeric(value), as.character(table$SlopeFacet)))
  }
  if (identical(component, "facet")) {
    table <- as.data.frame(fit$facets$others, stringsAsFactors = FALSE)
    key <- paste(table$Facet, table$Level, sep = "::")
    return(stats::setNames(as.numeric(table$Estimate), key))
  }
  if (identical(component, "step")) {
    table <- as.data.frame(fit$steps, stringsAsFactors = FALSE)
    facet <- if ("StepFacet" %in% names(table)) table$StepFacet else "shared"
    key <- paste(facet, table$Step, sep = "::")
    return(stats::setNames(as.numeric(table$Estimate), key))
  }
  person <- as.data.frame(fit$facets$person, stringsAsFactors = FALSE)
  if (identical(component, "eap")) {
    return(stats::setNames(as.numeric(person$Estimate), person$Person))
  }
  if (identical(component, "posterior_sd")) {
    value <- if ("PosteriorSD" %in% names(person)) {
      person$PosteriorSD
    } else person$SD
    return(stats::setNames(as.numeric(value), person$Person))
  }
  stop("Unknown MML comparison component.", call. = FALSE)
}

mfrmr_gpcm_mml_difference <- function(fit, reference, component) {
  candidate <- mfrmr_gpcm_mml_named_vector(fit, component)
  baseline <- mfrmr_gpcm_mml_named_vector(reference, component)
  common <- intersect(names(candidate), names(baseline))
  if (length(common) == 0L) {
    return(c(N = 0, RMSE = NA_real_, MaxAbs = NA_real_))
  }
  delta <- candidate[common] - baseline[common]
  finite <- is.finite(delta)
  if (!any(finite)) {
    return(c(N = 0, RMSE = NA_real_, MaxAbs = NA_real_))
  }
  delta <- delta[finite]
  c(N = length(delta), RMSE = sqrt(mean(delta^2)), MaxAbs = max(abs(delta)))
}

mfrmr_gpcm_mml_fit_one <- function(row, data, truth, quad_points, maxit) {
  owner <- as.character(row$SlopeOwner)
  fit_args <- list(
    data = data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    keep_original = TRUE,
    model = "GPCM",
    method = "MML",
    step_facet = owner,
    slope_facet = owner,
    rating_min = 1L,
    rating_max = 4L,
    quad_points = as.integer(quad_points),
    maxit = as.integer(maxit),
    optimizer = "auto",
    mml_engine = "direct"
  )
  captured <- mfrmr_gpcm_stress_capture(
    do.call(mfrmr_gpcm_stress_fun("fit_mfrm"), fit_args)
  )
  fit <- captured$value
  base <- data.frame(
    DatasetId = as.character(row$DatasetId),
    SlopeOwner = owner,
    DesignId = as.character(row$DesignId),
    Replicate = as.integer(row$Replicate),
    Seed = as.integer(row$Seed),
    QuadraturePoints = as.integer(quad_points),
    GridRole = if (quad_points == 31L) "standard_reference" else {
      "dense_sensitivity"
    },
    FitSucceeded = !inherits(fit, "error"),
    Error = if (inherits(fit, "error")) conditionMessage(fit) else "",
    Warnings = paste(captured$warnings, collapse = " | "),
    ConvergenceCode = NA_integer_,
    ConvergenceSeverity = NA_character_,
    RawFitReadiness = NA_character_,
    RawInferenceReady = FALSE,
    EvidenceFitReadiness = if (
      identical(as.character(row$DesignId), "zero_shared")
    ) "blocked" else NA_character_,
    EvidenceInferenceReady = FALSE,
    OwnGridNLL = NA_real_,
    CommonQ91NLL = NA_real_,
    CommonQ91Regret = NA_real_,
    SlopeLogRMSETruth = NA_real_,
    SlopeDeltaN = NA_integer_,
    SlopeLogDeltaRMSE = NA_real_,
    SlopeLogDeltaMaxAbs = NA_real_,
    FacetDeltaN = NA_integer_,
    FacetDeltaRMSE = NA_real_,
    FacetDeltaMaxAbs = NA_real_,
    StepDeltaN = NA_integer_,
    StepDeltaRMSE = NA_real_,
    StepDeltaMaxAbs = NA_real_,
    EAPDeltaN = NA_integer_,
    EAPDeltaRMSE = NA_real_,
    EAPDeltaMaxAbs = NA_real_,
    PosteriorSDDeltaN = NA_integer_,
    PosteriorSDDeltaRMSE = NA_real_,
    PosteriorSDDeltaMaxAbs = NA_real_,
    FunctionEvaluations = NA_integer_,
    GradientEvaluations = NA_integer_,
    SlopeNumericBoundaryRejections = NA_integer_,
    ConfirmationAuthorized = FALSE,
    ThresholdStatus = "integration_sensitivity_not_frozen",
    stringsAsFactors = FALSE
  )
  if (inherits(fit, "error")) {
    return(list(result = base, fit = NULL))
  }
  readiness <- mfrmr_gpcm_owner_readiness(fit)
  recovery <- mfrmr_gpcm_owner_slope_recovery(fit, truth)
  diagnostics <- fit$opt$optimizer_diagnostics %||% list()
  eval_cache <- fit$opt$evaluation_cache %||% list()
  base$ConvergenceCode <- as.integer(
    diagnostics$ConvergenceCode %||% fit$opt$convergence %||% NA_integer_
  )
  base$ConvergenceSeverity <- as.character(
    diagnostics$ConvergenceSeverity %||% NA_character_
  )
  base$RawFitReadiness <- readiness$state
  base$RawInferenceReady <- isTRUE(readiness$ready)
  if (!identical(as.character(row$DesignId), "zero_shared")) {
    base$EvidenceFitReadiness <- readiness$state
    base$EvidenceInferenceReady <- isTRUE(readiness$ready) &&
      identical(readiness$state, "ready")
  }
  base$OwnGridNLL <- as.numeric(fit$opt$value)
  base$CommonQ91NLL <- mfrmr_gpcm_mml_common_nll(fit, 91L)
  base$SlopeLogRMSETruth <- as.numeric(recovery[["LogRMSE"]])
  base$FunctionEvaluations <- as.integer(
    diagnostics$FunctionEvaluations %||% NA_integer_
  )
  base$GradientEvaluations <- as.integer(
    diagnostics$GradientEvaluations %||% NA_integer_
  )
  base$SlopeNumericBoundaryRejections <- as.integer(
    eval_cache$GPCMSlopeNumericBoundaryRejections %||% 0L
  )
  list(result = base, fit = fit)
}

mfrmr_gpcm_mml_run_dataset <- function(row, maxit) {
  built <- mfrmr_gpcm_owner_build(row)
  data <- built$data
  data_sha <- mfrmr_gpcm_repilot_hash_object(data)
  fitted <- lapply(mfrmr_gpcm_mml_quad_points, function(q) {
    mfrmr_gpcm_mml_fit_one(row, data, built$truth, q, maxit)
  })
  results <- do.call(rbind, lapply(fitted, `[[`, "result"))
  results$DataSHA256 <- data_sha
  reference <- fitted[[match(31L, mfrmr_gpcm_mml_quad_points)]]$fit
  if (!is.null(reference)) {
    components <- c(
      log_slope = "SlopeLog", facet = "Facet", step = "Step",
      eap = "EAP", posterior_sd = "PosteriorSD"
    )
    for (i in seq_along(fitted)) {
      fit <- fitted[[i]]$fit
      if (is.null(fit)) next
      for (component in names(components)) {
        difference <- mfrmr_gpcm_mml_difference(
          fit, reference, component
        )
        prefix <- unname(components[[component]])
        results[[paste0(prefix, "DeltaN")]][i] <-
          as.integer(difference[["N"]])
        results[[paste0(prefix, "DeltaRMSE")]][i] <-
          as.numeric(difference[["RMSE"]])
        results[[paste0(prefix, "DeltaMaxAbs")]][i] <-
          as.numeric(difference[["MaxAbs"]])
      }
    }
  }
  finite_common <- is.finite(results$CommonQ91NLL)
  if (any(finite_common)) {
    best <- min(results$CommonQ91NLL[finite_common])
    results$CommonQ91Regret[finite_common] <-
      results$CommonQ91NLL[finite_common] - best
  }
  results
}

mfrmr_gpcm_mml_checkpoint <- function(row, results, execution_sha256) {
  checkpoint <- list(
    Schema = "mfrmr-gpcm-mml-integration-checkpoint-v1",
    ExecutionSHA256 = execution_sha256,
    DatasetId = as.character(row$DatasetId),
    ManifestRow = row,
    ManifestRowSHA256 = mfrmr_gpcm_repilot_hash_object(row),
    Results = results,
    ResultsSHA256 = mfrmr_gpcm_repilot_hash_object(results)
  )
  checkpoint$CheckpointSHA256 <- mfrmr_gpcm_repilot_hash_object(
    checkpoint[names(checkpoint) != "CheckpointSHA256"]
  )
  checkpoint
}

mfrmr_gpcm_mml_validate_checkpoint <- function(checkpoint, row,
                                                 execution_sha256) {
  required <- c(
    "Schema", "ExecutionSHA256", "DatasetId", "ManifestRow",
    "ManifestRowSHA256", "Results", "ResultsSHA256", "CheckpointSHA256"
  )
  if (!is.list(checkpoint) || !all(required %in% names(checkpoint)) ||
      !identical(checkpoint$Schema,
                 "mfrmr-gpcm-mml-integration-checkpoint-v1") ||
      !identical(checkpoint$ExecutionSHA256, execution_sha256) ||
      !identical(checkpoint$DatasetId, as.character(row$DatasetId)) ||
      !identical(checkpoint$ManifestRowSHA256,
                 mfrmr_gpcm_repilot_hash_object(row)) ||
      !identical(checkpoint$ManifestRow, row) ||
      !identical(checkpoint$ResultsSHA256,
                 mfrmr_gpcm_repilot_hash_object(checkpoint$Results)) ||
      !identical(checkpoint$CheckpointSHA256,
                 mfrmr_gpcm_repilot_hash_object(
                   checkpoint[names(checkpoint) != "CheckpointSHA256"]
                 ))) {
    stop("MML integration checkpoint validation failed.", call. = FALSE)
  }
  if (!is.data.frame(checkpoint$Results) || nrow(checkpoint$Results) != 3L ||
      !identical(
        as.integer(checkpoint$Results$QuadraturePoints),
        mfrmr_gpcm_mml_quad_points
      )) {
    stop("MML integration checkpoint has an invalid three-grid payload.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gpcm_mml_checkpoint_path <- function(directory, dataset_id) {
  file.path(directory, paste0(dataset_id, ".rds"))
}

mfrmr_gpcm_mml_numeric_summary <- function(results) {
  metrics <- c(
    "CommonQ91Regret", "SlopeLogRMSETruth", "SlopeLogDeltaRMSE",
    "SlopeLogDeltaMaxAbs", "FacetDeltaMaxAbs", "StepDeltaMaxAbs",
    "EAPDeltaRMSE", "EAPDeltaMaxAbs", "PosteriorSDDeltaRMSE",
    "PosteriorSDDeltaMaxAbs"
  )
  groups <- split(
    seq_len(nrow(results)),
    interaction(
      results$SlopeOwner, results$DesignId, results$QuadraturePoints,
      drop = TRUE, lex.order = TRUE
    )
  )
  rows <- list()
  index <- 0L
  for (group in groups) {
    first <- results[group[1L], , drop = FALSE]
    for (metric in metrics) {
      value <- as.numeric(results[[metric]][group])
      finite <- value[is.finite(value)]
      index <- index + 1L
      rows[[index]] <- data.frame(
        SlopeOwner = first$SlopeOwner,
        DesignId = first$DesignId,
        QuadraturePoints = first$QuadraturePoints,
        Metric = metric,
        Planned = length(group),
        Finite = length(finite),
        Missing = length(group) - length(finite),
        Mean = if (length(finite)) mean(finite) else NA_real_,
        SD = if (length(finite) >= 2L) stats::sd(finite) else NA_real_,
        MCSE = if (length(finite) >= 2L) {
          stats::sd(finite) / sqrt(length(finite))
        } else NA_real_,
        Minimum = if (length(finite)) min(finite) else NA_real_,
        Maximum = if (length(finite)) max(finite) else NA_real_,
        ThresholdFrozen = FALSE,
        stringsAsFactors = FALSE
      )
    }
  }
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_gpcm_mml_rate_summary <- function(results) {
  groups <- split(
    seq_len(nrow(results)),
    interaction(
      results$SlopeOwner, results$DesignId, results$QuadraturePoints,
      drop = TRUE, lex.order = TRUE
    )
  )
  out <- lapply(groups, function(group) {
    first <- results[group[1L], , drop = FALSE]
    summarize <- function(value) {
      value <- as.logical(value)
      value[is.na(value)] <- FALSE
      count <- sum(value)
      interval <- mfrmr_gpcm_repilot_wilson(count, length(value))
      c(
        Count = count,
        Rate = count / length(value),
        MCSE = sqrt((count / length(value)) *
                      (1 - count / length(value)) / length(value)),
        WilsonLower = interval[["Lower"]],
        WilsonUpper = interval[["Upper"]]
      )
    }
    fit <- summarize(results$FitSucceeded[group])
    pass <- summarize(results$ConvergenceSeverity[group] == "pass")
    ready <- summarize(results$EvidenceInferenceReady[group])
    data.frame(
      SlopeOwner = first$SlopeOwner,
      DesignId = first$DesignId,
      QuadraturePoints = first$QuadraturePoints,
      Planned = length(group),
      FitCount = fit[["Count"]], FitRate = fit[["Rate"]],
      FitMCSE = fit[["MCSE"]], FitWilsonLower = fit[["WilsonLower"]],
      FitWilsonUpper = fit[["WilsonUpper"]],
      PassCount = pass[["Count"]], PassRate = pass[["Rate"]],
      PassMCSE = pass[["MCSE"]], PassWilsonLower = pass[["WilsonLower"]],
      PassWilsonUpper = pass[["WilsonUpper"]],
      EvidenceReadyCount = ready[["Count"]],
      EvidenceReadyRate = ready[["Rate"]],
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, out)
  row.names(out) <- NULL
  out
}

mfrmr_gpcm_mml_write <- function(result, output_dir) {
  artifacts <- list(
    "dataset-manifest.csv" = result$manifest,
    "run-results.csv" = result$results,
    "rate-summary.csv" = result$rate_summary,
    "numeric-summary.csv" = result$numeric_summary,
    "summary.csv" = result$summary,
    "execution-identity.csv" = result$execution_identity,
    "checkpoint-ledger.csv" = result$checkpoint_ledger
  )
  for (name in names(artifacts)) {
    utils::write.csv(artifacts[[name]], file.path(output_dir, name),
                     row.names = FALSE, na = "")
  }
  result_path <- file.path(output_dir, "gpcm-mml-integration-sensitivity.rds")
  mfrmr_gpcm_repilot_atomic_save_rds(result, result_path)
  checkpoints <- list.files(
    file.path(output_dir, "checkpoints"), full.names = TRUE
  )
  inventory_paths <- c(file.path(output_dir, names(artifacts)), result_path,
                       checkpoints)
  relative <- substring(
    normalizePath(inventory_paths, winslash = "/", mustWork = TRUE),
    nchar(normalizePath(output_dir, winslash = "/", mustWork = TRUE)) + 2L
  )
  inventory <- data.frame(
    File = relative,
    SHA256 = vapply(inventory_paths, mfrmr_gpcm_repilot_hash_file,
                    character(1), USE.NAMES = FALSE),
    stringsAsFactors = FALSE
  )
  inventory <- inventory[order(inventory$File), , drop = FALSE]
  row.names(inventory) <- NULL
  completion <- list(
    Schema = "mfrmr-gpcm-mml-integration-completion-v1",
    ExecutionSHA256 = as.character(
      result$execution_identity$ExecutionSHA256
    ),
    Inventory = inventory,
    InventorySHA256 = mfrmr_gpcm_repilot_hash_object(inventory),
    CompletedUTC = format(Sys.time(), tz = "UTC", usetz = TRUE)
  )
  mfrmr_gpcm_repilot_atomic_save_rds(
    completion, file.path(output_dir, "run-complete.rds")
  )
  invisible(completion)
}

mfrmr_run_gpcm_mml_integration_sensitivity <- function(
    profile = c("smoke", "pilot"),
    source_dir = NULL,
    output_dir = NULL,
    authorize = FALSE,
    resume = FALSE,
    progress = interactive()) {
  profile <- match.arg(profile)
  runtime <- mfrmr_gpcm_mml_load_support()
  if (identical(profile, "pilot") && !isTRUE(authorize)) {
    stop("The full MML sensitivity requires `authorize = TRUE`.",
         call. = FALSE)
  }
  source <- if (identical(profile, "pilot")) {
    mfrmr_gpcm_mml_validate_source_owner(source_dir)
  } else NULL
  manifest <- mfrmr_gpcm_mml_manifest(profile)
  if (!is.null(source) && !all(manifest$DatasetId %in% source$source_ids)) {
    stop("The MML panel is not contained in the completed owner execution.",
         call. = FALSE)
  }
  runner_path <- file.path(
    mfrmr_gpcm_mml_source_dir,
    "gpcm-mml-integration-sensitivity-0.2.3.R"
  )
  owner_runner <- file.path(
    mfrmr_gpcm_mml_source_dir, "gpcm-owner-specific-pilot-0.2.3.R"
  )
  identity_contract <- file.path(
    mfrmr_gpcm_mml_source_dir, "gpcm-model-identity-contract-0.2.3.csv"
  )
  execution <- data.frame(
    Schema = "mfrmr-gpcm-mml-integration-execution-v1",
    SpecificationId = "0.2.3-draft.68",
    Profile = profile,
    PlannedDatasets = nrow(manifest),
    PlannedFitRows = nrow(manifest) * 3L,
    Maxit = unique(manifest$Maxit),
    QuadraturePoints = paste(mfrmr_gpcm_mml_quad_points, collapse = ";"),
    CommonEvaluationQuadrature = 91L,
    RuntimePackageSHA256 = as.character(runtime$PackageSHA256),
    RunnerSHA256 = mfrmr_gpcm_repilot_hash_file(runner_path),
    ContractSHA256 = mfrmr_gpcm_repilot_hash_file(
      mfrmr_gpcm_mml_contract_path()
    ),
    OwnerRunnerSHA256 = mfrmr_gpcm_repilot_hash_file(owner_runner),
    IdentityContractSHA256 = mfrmr_gpcm_repilot_hash_file(identity_contract),
    SourceOwnerExecutionSHA256 = mfrmr_gpcm_mml_owner_execution_sha256,
    SourceOwnerRDS_SHA256 = if (is.null(source)) NA_character_ else {
      source$source_rds_sha256
    },
    ManifestSHA256 = mfrmr_gpcm_repilot_hash_object(manifest),
    ConfirmationAuthorized = FALSE,
    ThresholdStatus = "integration_sensitivity_not_frozen",
    stringsAsFactors = FALSE
  )
  execution$ExecutionSHA256 <- mfrmr_gpcm_repilot_hash_object(execution)
  execution_sha <- as.character(execution$ExecutionSHA256)

  checkpoint_dir <- if (is.null(output_dir)) NULL else {
    file.path(output_dir, "checkpoints")
  }
  if (!is.null(output_dir)) {
    dir.create(checkpoint_dir, recursive = TRUE, showWarnings = FALSE)
    existing_completion <- file.path(output_dir, "run-complete.rds")
    if (file.exists(existing_completion)) {
      stop("The MML sensitivity output is already complete.", call. = FALSE)
    }
    existing <- list.files(checkpoint_dir, full.names = TRUE)
    if (length(existing) > 0L && !isTRUE(resume)) {
      stop("Existing MML checkpoints require `resume = TRUE`.", call. = FALSE)
    }
    expected_names <- paste0(manifest$DatasetId, ".rds")
    if (any(!basename(existing) %in% expected_names)) {
      stop("The MML checkpoint directory contains an orphan file.",
           call. = FALSE)
    }
  } else if (isTRUE(resume)) {
    stop("MML resume requires an output directory.", call. = FALSE)
  }

  rows <- vector("list", nrow(manifest))
  ledger <- vector("list", nrow(manifest))
  for (i in seq_len(nrow(manifest))) {
    row <- manifest[i, , drop = FALSE]
    path <- if (is.null(checkpoint_dir)) NA_character_ else {
      mfrmr_gpcm_mml_checkpoint_path(checkpoint_dir, row$DatasetId)
    }
    resumed <- !is.na(path) && file.exists(path)
    if (resumed) {
      checkpoint <- readRDS(path)
      mfrmr_gpcm_mml_validate_checkpoint(checkpoint, row, execution_sha)
      results <- checkpoint$Results
    } else {
      if (isTRUE(progress)) {
        message(sprintf("[gpcm-mml %d/%d] %s", i, nrow(manifest),
                        row$DatasetId))
      }
      results <- mfrmr_gpcm_mml_run_dataset(row, unique(manifest$Maxit))
      checkpoint <- mfrmr_gpcm_mml_checkpoint(row, results, execution_sha)
      mfrmr_gpcm_mml_validate_checkpoint(checkpoint, row, execution_sha)
      if (!is.null(checkpoint_dir)) {
        mfrmr_gpcm_repilot_atomic_save_rds(checkpoint, path)
      }
    }
    rows[[i]] <- results
    ledger[[i]] <- data.frame(
      DatasetId = as.character(row$DatasetId),
      Source = if (resumed) "resumed_checkpoint" else "executed",
      ResultRows = nrow(results),
      CheckpointFile = if (is.na(path)) NA_character_ else basename(path),
      CheckpointSHA256 = if (is.na(path)) NA_character_ else {
        mfrmr_gpcm_repilot_hash_file(path)
      },
      ExecutionSHA256 = execution_sha,
      stringsAsFactors = FALSE
    )
  }
  results <- do.call(rbind, rows)
  row.names(results) <- NULL
  expected_order <- as.vector(vapply(
    manifest$DatasetId,
    function(id) paste(id, mfrmr_gpcm_mml_quad_points, sep = "::"),
    character(3), USE.NAMES = FALSE
  ))
  observed_order <- paste(results$DatasetId, results$QuadraturePoints, sep = "::")
  if (nrow(results) != nrow(manifest) * 3L ||
      !identical(observed_order, expected_order) ||
      any(table(results$DatasetId) != 3L)) {
    stop("The MML aggregate lost its declared dataset/grid order.",
         call. = FALSE)
  }
  summary <- data.frame(
    Profile = profile,
    PlannedDatasets = nrow(manifest),
    PlannedFitRows = nrow(manifest) * 3L,
    ExecutedFitRows = nrow(results),
    FitSucceeded = sum(results$FitSucceeded),
    ConvergencePass = sum(results$ConvergenceSeverity == "pass", na.rm = TRUE),
    RawInferenceReady = sum(results$RawInferenceReady),
    EvidenceInferenceReady = sum(results$EvidenceInferenceReady),
    BoundaryProposalRejections = sum(
      results$SlopeNumericBoundaryRejections, na.rm = TRUE
    ),
    ConfirmationAuthorized = FALSE,
    ThresholdStatus = "integration_sensitivity_not_frozen",
    stringsAsFactors = FALSE
  )
  result <- structure(
    list(
      manifest = manifest,
      results = results,
      rate_summary = mfrmr_gpcm_mml_rate_summary(results),
      numeric_summary = mfrmr_gpcm_mml_numeric_summary(results),
      summary = summary,
      execution_identity = execution,
      checkpoint_ledger = do.call(rbind, ledger),
      source_completion = if (is.null(source)) NULL else source$completion,
      confirmation_authorized = FALSE,
      session_info = utils::sessionInfo()
    ),
    class = c("mfrmr_gpcm_mml_integration_sensitivity", "list")
  )
  if (!is.null(output_dir)) mfrmr_gpcm_mml_write(result, output_dir)
  result
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  profile <- if (length(args) >= 1L) args[[1L]] else "smoke"
  result <- mfrmr_run_gpcm_mml_integration_sensitivity(
    profile = profile,
    source_dir = if (length(args) >= 2L) args[[2L]] else NULL,
    output_dir = if (length(args) >= 3L) args[[3L]] else NULL,
    authorize = identical(profile, "pilot"),
    progress = TRUE
  )
  print(result$summary)
}
