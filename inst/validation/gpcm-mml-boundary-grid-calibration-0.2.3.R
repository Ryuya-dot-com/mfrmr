# Draft.70 retrospective MML boundary/grid calibration for mfrmr 0.2.3.

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0L) y else x

mfrmr_gpcm_mml_boundary_grid_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "gpcm-mml-boundary-grid-calibration-0\\.2\\.3\\.R$", files
  )]
  candidates <- unique(c(
    dirname(hit), getwd(), file.path(getwd(), "inst", "validation")
  ))
  target <- file.path(
    candidates, "gpcm-mml-integration-sensitivity-0.2.3.R"
  )
  found <- candidates[file.exists(target)]
  if (length(found) == 0L) NA_character_ else {
    normalizePath(found[[1L]], winslash = "/", mustWork = TRUE)
  }
})

mfrmr_gpcm_mml_boundary_grid_runtime_sha256 <-
  "2a6344a815dadee12dc50eeac339e2f5774cf43cce2b86771a24aa8c132aa0e3"
mfrmr_gpcm_mml_boundary_grid_source_execution_sha256 <-
  "d993825cc8a58a3e3e1d17c6e4a8a6e2cc4fb16611c0429acd32296b81f70e70"
mfrmr_gpcm_mml_boundary_grid_source_inventory_sha256 <-
  "7b06b49da81f40768618ab814caac39fe7d2bc53fdb43421fa24c0064ce91bb4"
mfrmr_gpcm_mml_boundary_grid_source_rds_sha256 <-
  "7753d1a886602b324cc9c6411ad61f3f00c18dda2f4920e453a16e3a3ea24c2f"
mfrmr_gpcm_mml_boundary_grid_quad_points <- c(31L, 61L, 91L)

mfrmr_gpcm_mml_boundary_grid_load_support <- function() {
  if (is.na(mfrmr_gpcm_mml_boundary_grid_source_dir)) {
    stop("Cannot resolve the MML boundary/grid source directory.",
         call. = FALSE)
  }
  target_env <- environment(mfrmr_gpcm_mml_boundary_grid_load_support)
  if (!exists(
    "mfrmr_gpcm_mml_fit_one", envir = target_env,
    mode = "function", inherits = FALSE
  )) {
    sys.source(file.path(
      mfrmr_gpcm_mml_boundary_grid_source_dir,
      "gpcm-mml-integration-sensitivity-0.2.3.R"
    ), envir = target_env)
  }
  assign(
    "mfrmr_gpcm_mml_source_dir",
    mfrmr_gpcm_mml_boundary_grid_source_dir,
    envir = target_env
  )
  assign(
    "mfrmr_gpcm_mml_runtime_sha256",
    mfrmr_gpcm_mml_boundary_grid_runtime_sha256,
    envir = target_env
  )
  runtime <- mfrmr_gpcm_mml_load_support()
  if (!identical(
    as.character(runtime$PackageSHA256),
    mfrmr_gpcm_mml_boundary_grid_runtime_sha256
  )) {
    stop("The loaded runtime is not the registered Draft.70 build.",
         call. = FALSE)
  }
  invisible(runtime)
}

mfrmr_gpcm_mml_boundary_grid_contract_path <- function() {
  path <- file.path(
    mfrmr_gpcm_mml_boundary_grid_source_dir,
    "gpcm-mml-boundary-grid-calibration-contract-0.2.3.md"
  )
  if (!file.exists(path)) stop("The Draft.70 contract is missing.",
                               call. = FALSE)
  path
}

mfrmr_gpcm_mml_boundary_grid_validate_source <- function(
    source_integration_dir,
    source_owner_dir) {
  marker_path <- file.path(source_integration_dir, "run-complete.rds")
  result_path <- file.path(
    source_integration_dir, "gpcm-mml-integration-sensitivity.rds"
  )
  if (!file.exists(marker_path) || !file.exists(result_path)) {
    stop("The complete Draft.68 MML source bundle is required.", call. = FALSE)
  }
  marker <- readRDS(marker_path)
  if (!identical(
    as.character(marker$ExecutionSHA256),
    mfrmr_gpcm_mml_boundary_grid_source_execution_sha256
  ) || !identical(
    as.character(marker$InventorySHA256),
    mfrmr_gpcm_mml_boundary_grid_source_inventory_sha256
  ) || !identical(
    mfrmr_gpcm_repilot_hash_file(result_path),
    mfrmr_gpcm_mml_boundary_grid_source_rds_sha256
  )) {
    stop("The Draft.68 MML source identity does not match.", call. = FALSE)
  }
  source_result <- readRDS(result_path)
  if (!identical(
    as.character(source_result$execution_identity$ExecutionSHA256[1]),
    mfrmr_gpcm_mml_boundary_grid_source_execution_sha256
  ) || nrow(source_result$manifest) != 40L ||
      nrow(source_result$results) != 120L) {
    stop("The Draft.68 MML aggregate is malformed.", call. = FALSE)
  }
  owner <- mfrmr_gpcm_mml_validate_source_owner(source_owner_dir)
  list(
    marker = marker,
    result = source_result,
    result_path = result_path,
    owner = owner
  )
}

mfrmr_gpcm_mml_boundary_grid_manifest <- function(source_result = NULL) {
  manifest <- mfrmr_gpcm_mml_manifest("pilot")
  manifest$BoundaryGridSchema <-
    "mfrmr-gpcm-mml-boundary-grid-dataset-v1"
  manifest$BoundaryAudit <-
    "fixed_quadrature_marginal_constant_pair_paths"
  manifest$DirectComparison <- "q91_minus_q61"
  manifest$SourceMMLExecutionSHA256 <-
    mfrmr_gpcm_mml_boundary_grid_source_execution_sha256
  manifest$ConfirmationAuthorized <- FALSE
  manifest$ConfirmationEvidence <- FALSE
  manifest$ThresholdStatus <- "retrospective_calibration_not_frozen"
  manifest$ReleaseUse <- "calibration_only"
  if (!is.null(source_result)) {
    source_manifest <- source_result$manifest
    fields <- c(
      "DatasetId", "SlopeOwner", "DesignId", "Replicate", "Seed"
    )
    if (!identical(manifest[, fields, drop = FALSE],
                   source_manifest[, fields, drop = FALSE])) {
      stop("The Draft.70 manifest diverges from Draft.68 source data.",
           call. = FALSE)
    }
  }
  manifest
}

mfrmr_gpcm_mml_boundary_grid_audit_row <- function(fit) {
  empty <- data.frame(
    AuditState = NA_character_,
    AuditComplete = FALSE,
    AuditScopeComplete = FALSE,
    FixedQuadratureCertificate = FALSE,
    ContinuousIntegralCertificate = FALSE,
    ReadinessEffect = NA_character_,
    CertifiedPairs = NA_integer_,
    CertifiedPairIds = NA_character_,
    CertifiedDirections = NA_character_,
    TargetStatuses = NA_character_,
    AuditLikelihoodDifference = NA_real_,
    MaximumBoundaryImprovement = NA_real_,
    stringsAsFactors = FALSE
  )
  if (is.null(fit)) return(empty)
  audit <- fit$config$boundary_audit$gpcm_slope_boundary %||% list()
  certificates <- as.data.frame(
    audit$certificates %||% data.frame(), stringsAsFactors = FALSE
  )
  targets <- as.data.frame(
    audit$target_status %||% data.frame(), stringsAsFactors = FALSE
  )
  certified <- if (nrow(certificates) > 0L &&
                   "Certified" %in% names(certificates)) {
    certificates[certificates$Certified %in% TRUE, , drop = FALSE]
  } else data.frame()
  directions <- if (nrow(certified) > 0L) {
    paste(sort(paste(
      certified$PositiveLevel, certified$NegativeLevel, sep = ">"
    )), collapse = ";")
  } else ""
  target_status <- if (nrow(targets) > 0L &&
                       all(c("Level", "CandidateStatus") %in% names(targets))) {
    paste(sort(paste(targets$Level, targets$CandidateStatus, sep = "=")),
          collapse = ";")
  } else ""
  improvement <- if (nrow(certified) > 0L) {
    max(as.numeric(certified$BoundaryImprovement), na.rm = TRUE)
  } else NA_real_
  data.frame(
    AuditState = as.character(audit$state %||% NA_character_),
    AuditComplete = isTRUE(audit$complete),
    AuditScopeComplete = isTRUE(audit$scope_complete),
    FixedQuadratureCertificate =
      isTRUE(audit$fixed_quadrature_certificate),
    ContinuousIntegralCertificate =
      isTRUE(audit$continuous_integral_certificate),
    ReadinessEffect = as.character(audit$readiness_effect %||% NA_character_),
    CertifiedPairs = as.integer(nrow(certified)),
    CertifiedPairIds = if (nrow(certified)) {
      paste(sort(certified$PairId), collapse = ";")
    } else "",
    CertifiedDirections = directions,
    TargetStatuses = target_status,
    AuditLikelihoodDifference =
      as.numeric(audit$likelihood_difference %||% NA_real_),
    MaximumBoundaryImprovement = improvement,
    stringsAsFactors = FALSE
  )
}

mfrmr_gpcm_mml_boundary_grid_run_dataset <- function(
    row, source_results, maxit) {
  built <- mfrmr_gpcm_owner_build(row)
  data_sha <- mfrmr_gpcm_repilot_hash_object(built$data)
  fitted <- lapply(mfrmr_gpcm_mml_boundary_grid_quad_points, function(q) {
    mfrmr_gpcm_mml_fit_one(row, built$data, built$truth, q, maxit)
  })
  rows <- lapply(fitted, function(value) {
    cbind(value$result, mfrmr_gpcm_mml_boundary_grid_audit_row(value$fit))
  })
  results <- do.call(rbind, rows)
  row.names(results) <- NULL
  results$DataSHA256 <- data_sha
  results$ThresholdStatus <- "retrospective_calibration_not_frozen"

  finite_common <- is.finite(results$CommonQ91NLL)
  if (any(finite_common)) {
    best <- min(results$CommonQ91NLL[finite_common])
    results$CommonQ91Regret[finite_common] <-
      results$CommonQ91NLL[finite_common] - best
  }

  source <- source_results[
    source_results$DatasetId == row$DatasetId, , drop = FALSE
  ]
  source <- source[match(
    results$QuadraturePoints, source$QuadraturePoints
  ), , drop = FALSE]
  source_match <- nrow(source) == 3L && !anyNA(source$QuadraturePoints) &&
    identical(as.integer(source$QuadraturePoints),
              as.integer(results$QuadraturePoints))
  results$SourceRowMatched <- source_match
  results$SourceDataSHA256Matched <- source_match &&
    all(as.character(source$DataSHA256) == data_sha)
  results$OwnGridNLLDifferenceFromDraft68 <- if (source_match) {
    results$OwnGridNLL - source$OwnGridNLL
  } else NA_real_
  results$CommonQ91NLLDifferenceFromDraft68 <- if (source_match) {
    results$CommonQ91NLL - source$CommonQ91NLL
  } else NA_real_

  components <- c(
    log_slope = "SlopeLog", facet = "Facet", step = "Step",
    eap = "EAP", posterior_sd = "PosteriorSD"
  )
  q61 <- match(61L, mfrmr_gpcm_mml_boundary_grid_quad_points)
  q91 <- match(91L, mfrmr_gpcm_mml_boundary_grid_quad_points)
  direct <- list()
  for (component in names(components)) {
    difference <- if (!is.null(fitted[[q61]]$fit) &&
                      !is.null(fitted[[q91]]$fit)) {
      mfrmr_gpcm_mml_difference(
        fitted[[q91]]$fit, fitted[[q61]]$fit, component
      )
    } else c(N = 0, RMSE = NA_real_, MaxAbs = NA_real_)
    prefix <- components[[component]]
    direct[[paste0(prefix, "N")]] <- as.integer(difference[["N"]])
    direct[[paste0(prefix, "RMSE")]] <- as.numeric(difference[["RMSE"]])
    direct[[paste0(prefix, "MaxAbs")]] <- as.numeric(difference[["MaxAbs"]])
  }
  audit_available <- all(results$FitSucceeded) &&
    all(!is.na(results$AuditState))
  dataset <- data.frame(
    DatasetId = as.character(row$DatasetId),
    SlopeOwner = as.character(row$SlopeOwner),
    DesignId = as.character(row$DesignId),
    Replicate = as.integer(row$Replicate),
    Seed = as.integer(row$Seed),
    DataSHA256 = data_sha,
    AllFitsSucceeded = all(results$FitSucceeded),
    AllAuditComplete = all(results$AuditComplete),
    AuditStatesIdentical = audit_available &&
      length(unique(results$AuditState)) == 1L,
    CertifiedDirectionsIdentical = audit_available &&
      length(unique(results$CertifiedDirections)) == 1L,
    TargetStatusesIdentical = audit_available &&
      length(unique(results$TargetStatuses)) == 1L,
    AnyCertifiedPair = any(results$CertifiedPairs > 0L, na.rm = TRUE),
    Q61CommonQ91Regret = results$CommonQ91Regret[q61],
    MaximumOwnGridNLLDifferenceFromDraft68 = if (source_match) {
      max(abs(results$OwnGridNLLDifferenceFromDraft68), na.rm = TRUE)
    } else NA_real_,
    MaximumCommonQ91NLLDifferenceFromDraft68 = if (source_match) {
      max(abs(results$CommonQ91NLLDifferenceFromDraft68), na.rm = TRUE)
    } else NA_real_,
    SourceRowsMatched = source_match,
    SourceDataSHA256Matched = all(results$SourceDataSHA256Matched),
    ConfirmationAuthorized = FALSE,
    ThresholdStatus = "retrospective_calibration_not_frozen",
    stringsAsFactors = FALSE
  )
  for (name in names(direct)) dataset[[paste0("Q61Q91", name)]] <- direct[[name]]
  list(results = results, dataset = dataset)
}

mfrmr_gpcm_mml_boundary_grid_checkpoint <- function(
    row, run, execution_sha256) {
  checkpoint <- list(
    Schema = "mfrmr-gpcm-mml-boundary-grid-checkpoint-v1",
    ExecutionSHA256 = execution_sha256,
    DatasetId = as.character(row$DatasetId),
    ManifestRow = row,
    ManifestRowSHA256 = mfrmr_gpcm_repilot_hash_object(row),
    Results = run$results,
    ResultsSHA256 = mfrmr_gpcm_repilot_hash_object(run$results),
    DatasetSummary = run$dataset,
    DatasetSummarySHA256 = mfrmr_gpcm_repilot_hash_object(run$dataset)
  )
  checkpoint$CheckpointSHA256 <- mfrmr_gpcm_repilot_hash_object(
    checkpoint[names(checkpoint) != "CheckpointSHA256"]
  )
  checkpoint
}

mfrmr_gpcm_mml_boundary_grid_validate_checkpoint <- function(
    checkpoint, row, execution_sha256) {
  required <- c(
    "Schema", "ExecutionSHA256", "DatasetId", "ManifestRow",
    "ManifestRowSHA256", "Results", "ResultsSHA256", "DatasetSummary",
    "DatasetSummarySHA256", "CheckpointSHA256"
  )
  valid <- is.list(checkpoint) && all(required %in% names(checkpoint)) &&
    identical(checkpoint$Schema,
              "mfrmr-gpcm-mml-boundary-grid-checkpoint-v1") &&
    identical(checkpoint$ExecutionSHA256, execution_sha256) &&
    identical(checkpoint$DatasetId, as.character(row$DatasetId)) &&
    identical(checkpoint$ManifestRow, row) &&
    identical(checkpoint$ManifestRowSHA256,
              mfrmr_gpcm_repilot_hash_object(row)) &&
    identical(checkpoint$ResultsSHA256,
              mfrmr_gpcm_repilot_hash_object(checkpoint$Results)) &&
    identical(checkpoint$DatasetSummarySHA256,
              mfrmr_gpcm_repilot_hash_object(checkpoint$DatasetSummary)) &&
    identical(checkpoint$CheckpointSHA256,
              mfrmr_gpcm_repilot_hash_object(
                checkpoint[names(checkpoint) != "CheckpointSHA256"]
              ))
  if (!valid || !is.data.frame(checkpoint$Results) ||
      nrow(checkpoint$Results) != 3L ||
      !identical(as.integer(checkpoint$Results$QuadraturePoints),
                 mfrmr_gpcm_mml_boundary_grid_quad_points) ||
      !is.data.frame(checkpoint$DatasetSummary) ||
      nrow(checkpoint$DatasetSummary) != 1L) {
    stop("Draft.70 boundary/grid checkpoint validation failed.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gpcm_mml_boundary_grid_audit_summary <- function(results) {
  groups <- split(
    seq_len(nrow(results)),
    interaction(
      results$SlopeOwner, results$DesignId, results$QuadraturePoints,
      drop = TRUE, lex.order = TRUE
    )
  )
  out <- lapply(groups, function(index) {
    first <- results[index[1L], , drop = FALSE]
    data.frame(
      SlopeOwner = first$SlopeOwner,
      DesignId = first$DesignId,
      QuadraturePoints = first$QuadraturePoints,
      Planned = length(index),
      FitSucceeded = sum(results$FitSucceeded[index]),
      AuditComplete = sum(results$AuditComplete[index]),
      CertifiedArms = sum(results$CertifiedPairs[index] > 0L, na.rm = TRUE),
      MaximumCertifiedPairs = if (any(is.finite(results$CertifiedPairs[index]))) {
        max(results$CertifiedPairs[index], na.rm = TRUE)
      } else NA_integer_,
      MaximumLikelihoodReconstructionError = if (any(is.finite(
        results$AuditLikelihoodDifference[index]
      ))) {
        max(abs(results$AuditLikelihoodDifference[index]), na.rm = TRUE)
      } else NA_real_,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, out)
  row.names(out) <- NULL
  out
}

mfrmr_gpcm_mml_boundary_grid_numeric_summary <- function(dataset_summary) {
  metrics <- c(
    "Q61CommonQ91Regret", "Q61Q91SlopeLogRMSE",
    "Q61Q91SlopeLogMaxAbs", "Q61Q91FacetRMSE", "Q61Q91FacetMaxAbs",
    "Q61Q91StepRMSE", "Q61Q91StepMaxAbs", "Q61Q91EAPRMSE",
    "Q61Q91EAPMaxAbs", "Q61Q91PosteriorSDRMSE",
    "Q61Q91PosteriorSDMaxAbs",
    "MaximumOwnGridNLLDifferenceFromDraft68",
    "MaximumCommonQ91NLLDifferenceFromDraft68"
  )
  groups <- split(
    seq_len(nrow(dataset_summary)),
    interaction(
      dataset_summary$SlopeOwner, dataset_summary$DesignId,
      drop = TRUE, lex.order = TRUE
    )
  )
  rows <- list()
  cursor <- 0L
  for (index in groups) {
    first <- dataset_summary[index[1L], , drop = FALSE]
    for (metric in metrics) {
      value <- as.numeric(dataset_summary[[metric]][index])
      finite <- value[is.finite(value)]
      cursor <- cursor + 1L
      rows[[cursor]] <- data.frame(
        SlopeOwner = first$SlopeOwner,
        DesignId = first$DesignId,
        Metric = metric,
        Planned = length(index),
        Finite = length(finite),
        Missing = length(index) - length(finite),
        Mean = if (length(finite)) mean(finite) else NA_real_,
        SD = if (length(finite) >= 2L) stats::sd(finite) else NA_real_,
        MCSE = if (length(finite) >= 2L) {
          stats::sd(finite) / sqrt(length(finite))
        } else NA_real_,
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

mfrmr_gpcm_mml_boundary_grid_write <- function(result, output_dir) {
  artifacts <- list(
    "dataset-manifest.csv" = result$manifest,
    "run-results.csv" = result$results,
    "dataset-summary.csv" = result$dataset_summary,
    "audit-summary.csv" = result$audit_summary,
    "numeric-summary.csv" = result$numeric_summary,
    "summary.csv" = result$summary,
    "execution-identity.csv" = result$execution_identity,
    "checkpoint-ledger.csv" = result$checkpoint_ledger
  )
  for (name in names(artifacts)) {
    utils::write.csv(
      artifacts[[name]], file.path(output_dir, name),
      row.names = FALSE, na = ""
    )
  }
  result_path <- file.path(
    output_dir, "gpcm-mml-boundary-grid-calibration.rds"
  )
  mfrmr_gpcm_repilot_atomic_save_rds(result, result_path)
  checkpoints <- list.files(
    file.path(output_dir, "checkpoints"), full.names = TRUE
  )
  inventory_paths <- c(
    file.path(output_dir, names(artifacts)), result_path, checkpoints
  )
  relative <- substring(
    normalizePath(inventory_paths, winslash = "/", mustWork = TRUE),
    nchar(normalizePath(output_dir, winslash = "/", mustWork = TRUE)) + 2L
  )
  inventory <- data.frame(
    File = relative,
    SHA256 = vapply(
      inventory_paths, mfrmr_gpcm_repilot_hash_file, character(1),
      USE.NAMES = FALSE
    ),
    stringsAsFactors = FALSE
  )
  inventory <- inventory[order(inventory$File), , drop = FALSE]
  row.names(inventory) <- NULL
  completion <- list(
    Schema = "mfrmr-gpcm-mml-boundary-grid-completion-v1",
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

mfrmr_run_gpcm_mml_boundary_grid_calibration <- function(
    source_integration_dir = NULL,
    source_owner_dir = NULL,
    output_dir = NULL,
    authorize = FALSE,
    resume = FALSE,
    dry_run = FALSE,
    progress = interactive()) {
  runtime <- mfrmr_gpcm_mml_boundary_grid_load_support()
  if (!isTRUE(dry_run) && !isTRUE(authorize)) {
    stop("The Draft.70 calibration requires `authorize = TRUE`.",
         call. = FALSE)
  }
  source <- if (isTRUE(dry_run) && is.null(source_integration_dir)) {
    NULL
  } else {
    mfrmr_gpcm_mml_boundary_grid_validate_source(
      source_integration_dir, source_owner_dir
    )
  }
  manifest <- mfrmr_gpcm_mml_boundary_grid_manifest(
    if (is.null(source)) NULL else source$result
  )
  runner_path <- file.path(
    mfrmr_gpcm_mml_boundary_grid_source_dir,
    "gpcm-mml-boundary-grid-calibration-0.2.3.R"
  )
  execution <- data.frame(
    Schema = "mfrmr-gpcm-mml-boundary-grid-execution-v1",
    SpecificationId = "0.2.3-draft.70",
    PlannedDatasets = nrow(manifest),
    PlannedFitRows = nrow(manifest) * 3L,
    Maxit = 400L,
    QuadraturePoints = paste(
      mfrmr_gpcm_mml_boundary_grid_quad_points, collapse = ";"
    ),
    RuntimePackageSHA256 = as.character(runtime$PackageSHA256),
    RunnerSHA256 = mfrmr_gpcm_repilot_hash_file(runner_path),
    ContractSHA256 = mfrmr_gpcm_repilot_hash_file(
      mfrmr_gpcm_mml_boundary_grid_contract_path()
    ),
    SourceMMLExecutionSHA256 =
      mfrmr_gpcm_mml_boundary_grid_source_execution_sha256,
    SourceMMLInventorySHA256 =
      mfrmr_gpcm_mml_boundary_grid_source_inventory_sha256,
    SourceMMLRDS_SHA256 =
      mfrmr_gpcm_mml_boundary_grid_source_rds_sha256,
    SourceOwnerExecutionSHA256 =
      mfrmr_gpcm_mml_owner_execution_sha256,
    ManifestSHA256 = mfrmr_gpcm_repilot_hash_object(manifest),
    ConfirmationAuthorized = FALSE,
    ThresholdStatus = "retrospective_calibration_not_frozen",
    stringsAsFactors = FALSE
  )
  execution$ExecutionSHA256 <- mfrmr_gpcm_repilot_hash_object(execution)
  if (isTRUE(dry_run)) {
    return(list(
      manifest = manifest,
      execution_identity = execution,
      confirmation_authorized = FALSE
    ))
  }

  checkpoint_dir <- if (is.null(output_dir)) NULL else {
    file.path(output_dir, "checkpoints")
  }
  if (!is.null(output_dir)) {
    dir.create(checkpoint_dir, recursive = TRUE, showWarnings = FALSE)
    if (file.exists(file.path(output_dir, "run-complete.rds"))) {
      stop("The Draft.70 output is already complete.", call. = FALSE)
    }
    existing <- list.files(checkpoint_dir, full.names = TRUE)
    if (length(existing) > 0L && !isTRUE(resume)) {
      stop("Existing Draft.70 checkpoints require `resume = TRUE`.",
           call. = FALSE)
    }
    expected <- paste0(manifest$DatasetId, ".rds")
    if (any(!basename(existing) %in% expected)) {
      stop("The Draft.70 checkpoint directory contains an orphan file.",
           call. = FALSE)
    }
  } else if (isTRUE(resume)) {
    stop("Draft.70 resume requires an output directory.", call. = FALSE)
  }

  fit_rows <- vector("list", nrow(manifest))
  dataset_rows <- vector("list", nrow(manifest))
  ledger <- vector("list", nrow(manifest))
  execution_sha <- as.character(execution$ExecutionSHA256)
  for (i in seq_len(nrow(manifest))) {
    row <- manifest[i, , drop = FALSE]
    path <- if (is.null(checkpoint_dir)) NA_character_ else {
      file.path(checkpoint_dir, paste0(row$DatasetId, ".rds"))
    }
    resumed <- !is.na(path) && file.exists(path)
    if (resumed) {
      checkpoint <- readRDS(path)
      mfrmr_gpcm_mml_boundary_grid_validate_checkpoint(
        checkpoint, row, execution_sha
      )
    } else {
      if (isTRUE(progress)) {
        message(sprintf(
          "[gpcm-mml-boundary-grid %d/%d] %s",
          i, nrow(manifest), row$DatasetId
        ))
      }
      run <- mfrmr_gpcm_mml_boundary_grid_run_dataset(
        row, source$result$results, maxit = 400L
      )
      checkpoint <- mfrmr_gpcm_mml_boundary_grid_checkpoint(
        row, run, execution_sha
      )
      mfrmr_gpcm_mml_boundary_grid_validate_checkpoint(
        checkpoint, row, execution_sha
      )
      if (!is.null(checkpoint_dir)) {
        mfrmr_gpcm_repilot_atomic_save_rds(checkpoint, path)
      }
    }
    fit_rows[[i]] <- checkpoint$Results
    dataset_rows[[i]] <- checkpoint$DatasetSummary
    ledger[[i]] <- data.frame(
      DatasetId = as.character(row$DatasetId),
      Source = if (resumed) "resumed_checkpoint" else "executed",
      ResultRows = nrow(checkpoint$Results),
      CheckpointFile = if (is.na(path)) NA_character_ else basename(path),
      CheckpointSHA256 = if (is.na(path)) NA_character_ else {
        mfrmr_gpcm_repilot_hash_file(path)
      },
      ExecutionSHA256 = execution_sha,
      stringsAsFactors = FALSE
    )
  }
  results <- do.call(rbind, fit_rows)
  dataset_summary <- do.call(rbind, dataset_rows)
  row.names(results) <- row.names(dataset_summary) <- NULL
  expected_order <- as.vector(vapply(
    manifest$DatasetId,
    function(id) paste(
      id, mfrmr_gpcm_mml_boundary_grid_quad_points, sep = "::"
    ),
    character(3), USE.NAMES = FALSE
  ))
  if (!identical(
    paste(results$DatasetId, results$QuadraturePoints, sep = "::"),
    expected_order
  ) || !identical(as.character(dataset_summary$DatasetId),
                  as.character(manifest$DatasetId))) {
    stop("The Draft.70 aggregate lost its declared order.", call. = FALSE)
  }
  summary <- data.frame(
    PlannedDatasets = nrow(manifest),
    PlannedFitRows = nrow(manifest) * 3L,
    ExecutedFitRows = nrow(results),
    FitSucceeded = sum(results$FitSucceeded),
    AuditComplete = sum(results$AuditComplete),
    CertifiedArms = sum(results$CertifiedPairs > 0L, na.rm = TRUE),
    CertifiedDatasets = sum(dataset_summary$AnyCertifiedPair),
    AuditStateStableDatasets = sum(dataset_summary$AuditStatesIdentical),
    CertifiedDirectionStableDatasets = sum(
      dataset_summary$CertifiedDirectionsIdentical
    ),
    SourceDataMatchedDatasets = sum(
      dataset_summary$SourceDataSHA256Matched
    ),
    EvidenceInferenceReady = sum(results$EvidenceInferenceReady),
    ConfirmationAuthorized = FALSE,
    ThresholdStatus = "retrospective_calibration_not_frozen",
    stringsAsFactors = FALSE
  )
  result <- structure(list(
    manifest = manifest,
    results = results,
    dataset_summary = dataset_summary,
    audit_summary = mfrmr_gpcm_mml_boundary_grid_audit_summary(results),
    numeric_summary = mfrmr_gpcm_mml_boundary_grid_numeric_summary(
      dataset_summary
    ),
    summary = summary,
    execution_identity = execution,
    checkpoint_ledger = do.call(rbind, ledger),
    source_completion = source$marker,
    confirmation_authorized = FALSE,
    session_info = utils::sessionInfo()
  ), class = c("mfrmr_gpcm_mml_boundary_grid_calibration", "list"))
  if (!is.null(output_dir)) {
    mfrmr_gpcm_mml_boundary_grid_write(result, output_dir)
  }
  result
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  result <- mfrmr_run_gpcm_mml_boundary_grid_calibration(
    source_integration_dir = if (length(args) >= 1L) args[[1L]] else NULL,
    source_owner_dir = if (length(args) >= 2L) args[[2L]] else NULL,
    output_dir = if (length(args) >= 3L) args[[3L]] else NULL,
    authorize = TRUE,
    progress = TRUE
  )
  print(result$summary)
}
