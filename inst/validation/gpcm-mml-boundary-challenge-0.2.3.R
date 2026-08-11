# Draft.71 deterministic MML GPCM boundary-path challenge for mfrmr 0.2.3.

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0L) y else x

mfrmr_gpcm_mml_boundary_challenge_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "gpcm-mml-boundary-challenge-0\\.2\\.3\\.R$", files
  )]
  candidates <- unique(c(
    dirname(hit), getwd(), file.path(getwd(), "inst", "validation")
  ))
  target <- file.path(
    candidates, "gpcm-mml-boundary-grid-calibration-0.2.3.R"
  )
  found <- candidates[file.exists(target)]
  if (length(found) == 0L) NA_character_ else {
    normalizePath(found[[1L]], winslash = "/", mustWork = TRUE)
  }
})

mfrmr_gpcm_mml_boundary_challenge_runtime_sha256 <-
  "2a6344a815dadee12dc50eeac339e2f5774cf43cce2b86771a24aa8c132aa0e3"
mfrmr_gpcm_mml_boundary_challenge_quad_points <- c(31L, 61L, 91L)
mfrmr_gpcm_mml_boundary_challenge_maxit <- 50L

mfrmr_gpcm_mml_boundary_challenge_load_support <- function() {
  if (is.na(mfrmr_gpcm_mml_boundary_challenge_source_dir)) {
    stop("Cannot resolve the boundary-challenge source directory.",
         call. = FALSE)
  }
  target_env <- environment(mfrmr_gpcm_mml_boundary_challenge_load_support)
  if (!exists(
    "mfrmr_gpcm_repilot_hash_object", envir = target_env,
    mode = "function", inherits = FALSE
  )) {
    sys.source(file.path(
      mfrmr_gpcm_mml_boundary_challenge_source_dir,
      "gpcm-mml-boundary-grid-calibration-0.2.3.R"
    ), envir = target_env)
  }
  assign(
    "mfrmr_gpcm_mml_boundary_grid_source_dir",
    mfrmr_gpcm_mml_boundary_challenge_source_dir,
    envir = target_env
  )
  assign(
    "mfrmr_gpcm_mml_boundary_grid_runtime_sha256",
    mfrmr_gpcm_mml_boundary_challenge_runtime_sha256,
    envir = target_env
  )
  runtime <- mfrmr_gpcm_mml_boundary_grid_load_support()
  if (!identical(
    as.character(runtime$PackageSHA256),
    mfrmr_gpcm_mml_boundary_challenge_runtime_sha256
  )) {
    stop("The loaded runtime is not the registered Draft.71 build.",
         call. = FALSE)
  }
  invisible(runtime)
}

mfrmr_gpcm_mml_boundary_challenge_contract_path <- function() {
  path <- file.path(
    mfrmr_gpcm_mml_boundary_challenge_source_dir,
    "gpcm-mml-boundary-challenge-contract-0.2.3.md"
  )
  if (!file.exists(path)) stop("The Draft.71 contract is missing.",
                               call. = FALSE)
  path
}

mfrmr_gpcm_mml_boundary_challenge_build_data <- function(
    slope_owner, challenge) {
  data <- expand.grid(
    Person = sprintf("P%02d", seq_len(12L)),
    Rater = c("R1", "R2"),
    Criterion = c("C1", "C2"),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  owner_column <- if (identical(slope_owner, "Criterion")) {
    "Criterion"
  } else if (identical(slope_owner, "Rater")) {
    "Rater"
  } else {
    stop("Unknown Draft.71 slope owner.", call. = FALSE)
  }
  owner_levels <- if (identical(owner_column, "Criterion")) {
    c("C1", "C2")
  } else c("R1", "R2")
  owner_value <- data[[owner_column]]
  data$Weight <- 1
  if (challenge %in% c(
    "positive_forward", "zero_weight_discordant",
    "epsilon_weight_discordant"
  )) {
    data$Score <- ifelse(owner_value == owner_levels[[1L]], 1L, 0L)
  } else if (identical(challenge, "positive_reverse")) {
    data$Score <- ifelse(owner_value == owner_levels[[1L]], 0L, 1L)
  } else if (identical(challenge, "mixed_negative")) {
    person_index <- as.integer(sub("^P", "", data$Person))
    data$Score <- as.integer(person_index %% 2L == 0L)
  } else {
    stop("Unknown Draft.71 boundary challenge.", call. = FALSE)
  }
  if (challenge %in% c(
    "zero_weight_discordant", "epsilon_weight_discordant"
  )) {
    discordant <- which(owner_value == owner_levels[[1L]])[[1L]]
    data$Score[[discordant]] <- 0L
    data$Weight[[discordant]] <- if (
      identical(challenge, "zero_weight_discordant")
    ) 0 else 1e-8
  }
  data$Score <- as.integer(data$Score)
  row.names(data) <- NULL
  data
}

mfrmr_gpcm_mml_boundary_challenge_manifest <- function() {
  owners <- c("Criterion", "Rater")
  challenges <- c(
    "positive_forward", "positive_reverse", "mixed_negative",
    "zero_weight_discordant", "epsilon_weight_discordant"
  )
  rows <- list()
  cursor <- 0L
  for (owner in owners) {
    owner_levels <- if (identical(owner, "Criterion")) {
      c("C1", "C2")
    } else c("R1", "R2")
    for (challenge in challenges) {
      cursor <- cursor + 1L
      positive <- challenge %in% c(
        "positive_forward", "positive_reverse", "zero_weight_discordant"
      )
      direction <- if (!positive) {
        ""
      } else if (identical(challenge, "positive_reverse")) {
        paste(owner_levels[[2L]], owner_levels[[1L]], sep = ">")
      } else paste(owner_levels[[1L]], owner_levels[[2L]], sep = ">")
      data <- mfrmr_gpcm_mml_boundary_challenge_build_data(owner, challenge)
      rows[[cursor]] <- data.frame(
        DatasetId = paste(
          "GPCM", "MML", "BOUNDARY", toupper(substr(owner, 1L, 1L)),
          toupper(gsub("_", "-", challenge)), sep = "-"
        ),
        SlopeOwner = owner,
        Challenge = challenge,
        ExpectedAuditState = if (positive) {
          "certified_fixed_quadrature_marginal_boundary_path"
        } else "none_certified_fixed_quadrature_marginal",
        ExpectedCertifiedPairs = if (positive) 1L else 0L,
        ExpectedDirection = direction,
        ExpectedRetainedRows = if (
          identical(challenge, "zero_weight_discordant")
        ) 47L else 48L,
        InputDataSHA256 = mfrmr_gpcm_repilot_hash_object(data),
        ConfirmationAuthorized = FALSE,
        EvidenceRole = "deterministic_calibration",
        ReadinessPropagation = FALSE,
        stringsAsFactors = FALSE
      )
    }
  }
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_gpcm_mml_boundary_challenge_fit <- function(row, q) {
  data <- mfrmr_gpcm_mml_boundary_challenge_build_data(
    as.character(row$SlopeOwner), as.character(row$Challenge)
  )
  nonowner <- if (identical(as.character(row$SlopeOwner), "Criterion")) {
    "Rater"
  } else "Criterion"
  nonowner_levels <- if (identical(nonowner, "Rater")) {
    c("R1", "R2")
  } else c("C1", "C2")
  anchors <- data.frame(
    Facet = nonowner,
    Level = nonowner_levels,
    Anchor = c(-10, -10),
    stringsAsFactors = FALSE
  )
  warnings <- character(0)
  error <- NULL
  fit <- withCallingHandlers(
    tryCatch(
      fit_mfrm(
        data,
        person = "Person",
        facets = c("Rater", "Criterion"),
        score = "Score",
        weight = "Weight",
        keep_original = TRUE,
        method = "MML",
        model = "GPCM",
        step_facet = as.character(row$SlopeOwner),
        slope_facet = as.character(row$SlopeOwner),
        anchors = anchors,
        rating_min = 0,
        rating_max = 1,
        quad_points = as.integer(q),
        maxit = mfrmr_gpcm_mml_boundary_challenge_maxit,
        optimizer = "auto",
        mml_engine = "direct"
      ),
      error = function(e) {
        error <<- conditionMessage(e)
        NULL
      }
    ),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    },
    message = function(m) invokeRestart("muffleMessage")
  )
  list(
    fit = fit,
    error = error,
    warnings = unique(warnings),
    input_data_sha256 = mfrmr_gpcm_repilot_hash_object(data)
  )
}

mfrmr_gpcm_mml_boundary_challenge_result_row <- function(row, q, fitted) {
  fit <- fitted$fit
  audit <- if (is.null(fit)) list() else {
    fit$config$boundary_audit$gpcm_slope_boundary %||% list()
  }
  certificates <- as.data.frame(
    audit$certificates %||% data.frame(), stringsAsFactors = FALSE
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
  targets <- as.data.frame(
    audit$target_status %||% data.frame(), stringsAsFactors = FALSE
  )
  target_status <- if (nrow(targets) > 0L &&
                       all(c("Level", "CandidateStatus") %in% names(targets))) {
    paste(sort(paste(targets$Level, targets$CandidateStatus, sep = "=")),
          collapse = ";")
  } else ""
  groups <- as.data.frame(
    audit$group_support %||% data.frame(), stringsAsFactors = FALSE
  )
  group_support <- if (nrow(groups) > 0L) {
    paste(vapply(seq_len(nrow(groups)), function(i) {
      paste0(
        groups$Level[[i]], ":max=", groups$MaxCompatible[[i]],
        ":min=", groups$MinCompatible[[i]],
        ":max_margin=", format(groups$MaxSupportMargin[[i]], digits = 17),
        ":min_margin=", format(groups$MinSupportMargin[[i]], digits = 17)
      )
    }, character(1)), collapse = ";")
  } else ""
  summary <- if (is.null(fit)) data.frame() else fit$summary
  first <- function(name, default = NA) {
    if (is.data.frame(summary) && nrow(summary) > 0L && name %in% names(summary)) {
      summary[[name]][[1L]]
    } else default
  }
  retained_hash <- if (is.null(fit)) NA_character_ else {
    mfrmr_gpcm_repilot_hash_object(fit$prep$data)
  }
  maximum_improvement <- if (nrow(certified) > 0L) {
    max(as.numeric(certified$BoundaryImprovement), na.rm = TRUE)
  } else NA_real_
  result <- data.frame(
    DatasetId = as.character(row$DatasetId),
    SlopeOwner = as.character(row$SlopeOwner),
    Challenge = as.character(row$Challenge),
    QuadraturePoints = as.integer(q),
    FitSucceeded = !is.null(fit),
    Error = as.character(fitted$error %||% ""),
    Warnings = paste(fitted$warnings, collapse = " | "),
    ConvergenceCode = suppressWarnings(as.integer(
      first("ConvergenceCode", NA_integer_)
    )),
    ConvergenceSeverity = as.character(
      first("ConvergenceSeverity", NA_character_)
    ),
    EvidenceInferenceReady = isTRUE(
      first("InferenceReady", if (is.null(fit)) FALSE else {
        fit$readiness$fit$InferenceReady %||% FALSE
      })
    ),
    InputDataSHA256 = fitted$input_data_sha256,
    RetainedDataSHA256 = retained_hash,
    RetainedRows = if (is.null(fit)) NA_integer_ else nrow(fit$prep$data),
    AuditState = as.character(audit$state %||% NA_character_),
    AuditComplete = isTRUE(audit$complete),
    AuditScopeComplete = isTRUE(audit$scope_complete),
    FixedQuadratureCertificate = isTRUE(
      audit$fixed_quadrature_certificate
    ),
    ContinuousIntegralCertificate = isTRUE(
      audit$continuous_integral_certificate
    ),
    ReadinessEffect = as.character(
      audit$readiness_effect %||% NA_character_
    ),
    CertifiedPairs = as.integer(nrow(certified)),
    CertifiedDirections = directions,
    TargetStatuses = target_status,
    GroupSupport = group_support,
    AuditLikelihoodDifference = as.numeric(
      audit$likelihood_difference %||% NA_real_
    ),
    MaximumBoundaryImprovement = maximum_improvement,
    SlopeNumericBoundaryRejections = if (is.null(fit)) NA_integer_ else {
      as.integer(fit$opt$GPCMSlopeNumericBoundaryRejections %||% 0L)
    },
    ExpectedAuditState = as.character(row$ExpectedAuditState),
    ExpectedCertifiedPairs = as.integer(row$ExpectedCertifiedPairs),
    ExpectedDirection = as.character(row$ExpectedDirection),
    ExpectedRetainedRows = as.integer(row$ExpectedRetainedRows),
    ConfirmationAuthorized = FALSE,
    ReadinessPropagation = FALSE,
    stringsAsFactors = FALSE
  )
  result$StateExpectationPassed <- identical(
    result$AuditState, result$ExpectedAuditState
  )
  result$PairExpectationPassed <- identical(
    result$CertifiedPairs, result$ExpectedCertifiedPairs
  )
  result$DirectionExpectationPassed <- identical(
    result$CertifiedDirections, result$ExpectedDirection
  )
  result$RetainedRowsExpectationPassed <- identical(
    result$RetainedRows, result$ExpectedRetainedRows
  )
  result$LikelihoodReconstructionPassed <-
    is.finite(result$AuditLikelihoodDifference) &&
    abs(result$AuditLikelihoodDifference) <= 1e-8
  result$PositiveImprovementPassed <- if (
    result$ExpectedCertifiedPairs > 0L
  ) {
    is.finite(result$MaximumBoundaryImprovement) &&
      result$MaximumBoundaryImprovement > 0
  } else TRUE
  result$ReadinessProtectionPassed <-
    !result$EvidenceInferenceReady &&
    identical(result$ReadinessEffect, "none_instrumentation_only") &&
    !result$ReadinessPropagation && !result$ConfirmationAuthorized
  result$ArmExpectationPassed <- all(
    result$FitSucceeded,
    result$AuditComplete,
    result$AuditScopeComplete,
    result$FixedQuadratureCertificate,
    !result$ContinuousIntegralCertificate,
    result$StateExpectationPassed,
    result$PairExpectationPassed,
    result$DirectionExpectationPassed,
    result$RetainedRowsExpectationPassed,
    result$LikelihoodReconstructionPassed,
    result$PositiveImprovementPassed,
    result$ReadinessProtectionPassed
  )
  result
}

mfrmr_gpcm_mml_boundary_challenge_run_dataset <- function(row) {
  rows <- lapply(
    mfrmr_gpcm_mml_boundary_challenge_quad_points,
    function(q) mfrmr_gpcm_mml_boundary_challenge_result_row(
      row, q, mfrmr_gpcm_mml_boundary_challenge_fit(row, q)
    )
  )
  results <- do.call(rbind, rows)
  row.names(results) <- NULL
  retained_hashes <- unique(results$RetainedDataSHA256[
    !is.na(results$RetainedDataSHA256)
  ])
  dataset <- data.frame(
    DatasetId = as.character(row$DatasetId),
    SlopeOwner = as.character(row$SlopeOwner),
    Challenge = as.character(row$Challenge),
    ExpectedAuditState = as.character(row$ExpectedAuditState),
    ExpectedDirection = as.character(row$ExpectedDirection),
    AllFitsSucceeded = all(results$FitSucceeded),
    AllAuditsComplete = all(results$AuditComplete),
    AllArmExpectationsPassed = all(results$ArmExpectationPassed),
    AuditStatesIdentical = length(unique(results$AuditState)) == 1L,
    CertifiedDirectionsIdentical =
      length(unique(results$CertifiedDirections)) == 1L,
    TargetStatusesIdentical = length(unique(results$TargetStatuses)) == 1L,
    RetainedDataHashesIdentical = length(retained_hashes) == 1L,
    EvidenceInferenceReadyArms = sum(results$EvidenceInferenceReady),
    ConfirmationAuthorized = FALSE,
    ReadinessPropagation = FALSE,
    stringsAsFactors = FALSE
  )
  dataset$DatasetExpectationPassed <- all(
    dataset$AllFitsSucceeded,
    dataset$AllAuditsComplete,
    dataset$AllArmExpectationsPassed,
    dataset$AuditStatesIdentical,
    dataset$CertifiedDirectionsIdentical,
    dataset$TargetStatusesIdentical,
    dataset$RetainedDataHashesIdentical,
    dataset$EvidenceInferenceReadyArms == 0L,
    !dataset$ConfirmationAuthorized,
    !dataset$ReadinessPropagation
  )
  list(results = results, dataset = dataset)
}

mfrmr_gpcm_mml_boundary_challenge_checkpoint <- function(
    row, run, execution_sha256) {
  checkpoint <- list(
    Schema = "mfrmr-gpcm-mml-boundary-challenge-checkpoint-v1",
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

mfrmr_gpcm_mml_boundary_challenge_validate_checkpoint <- function(
    checkpoint, row, execution_sha256) {
  required <- c(
    "Schema", "ExecutionSHA256", "DatasetId", "ManifestRow",
    "ManifestRowSHA256", "Results", "ResultsSHA256", "DatasetSummary",
    "DatasetSummarySHA256", "CheckpointSHA256"
  )
  valid <- is.list(checkpoint) && all(required %in% names(checkpoint)) &&
    identical(checkpoint$Schema,
              "mfrmr-gpcm-mml-boundary-challenge-checkpoint-v1") &&
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
      nrow(checkpoint$Results) != 3L || !identical(
        as.integer(checkpoint$Results$QuadraturePoints),
        mfrmr_gpcm_mml_boundary_challenge_quad_points
      ) || !is.data.frame(checkpoint$DatasetSummary) ||
      nrow(checkpoint$DatasetSummary) != 1L) {
    stop("Draft.71 boundary-challenge checkpoint validation failed.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gpcm_mml_boundary_challenge_write <- function(result, output_dir) {
  artifacts <- list(
    "dataset-manifest.csv" = result$manifest,
    "run-results.csv" = result$results,
    "dataset-summary.csv" = result$dataset_summary,
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
    output_dir, "gpcm-mml-boundary-challenge.rds"
  )
  mfrmr_gpcm_repilot_atomic_save_rds(result, result_path)
  checkpoints <- list.files(
    file.path(output_dir, "checkpoints"), full.names = TRUE
  )
  inventory_paths <- c(
    file.path(output_dir, names(artifacts)), result_path, checkpoints
  )
  root <- normalizePath(output_dir, winslash = "/", mustWork = TRUE)
  relative <- substring(
    normalizePath(inventory_paths, winslash = "/", mustWork = TRUE),
    nchar(root) + 2L
  )
  inventory <- data.frame(
    File = relative,
    SHA256 = vapply(
      inventory_paths, mfrmr_gpcm_repilot_hash_file,
      character(1), USE.NAMES = FALSE
    ),
    stringsAsFactors = FALSE
  )
  inventory <- inventory[order(inventory$File), , drop = FALSE]
  row.names(inventory) <- NULL
  completion <- list(
    Schema = "mfrmr-gpcm-mml-boundary-challenge-completion-v1",
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

mfrmr_run_gpcm_mml_boundary_challenge <- function(
    output_dir = NULL,
    authorize = FALSE,
    resume = FALSE,
    dry_run = FALSE,
    progress = interactive()) {
  runtime <- mfrmr_gpcm_mml_boundary_challenge_load_support()
  if (!isTRUE(dry_run) && !isTRUE(authorize)) {
    stop("The Draft.71 challenge requires `authorize = TRUE`.",
         call. = FALSE)
  }
  manifest <- mfrmr_gpcm_mml_boundary_challenge_manifest()
  runner_path <- file.path(
    mfrmr_gpcm_mml_boundary_challenge_source_dir,
    "gpcm-mml-boundary-challenge-0.2.3.R"
  )
  execution <- data.frame(
    Schema = "mfrmr-gpcm-mml-boundary-challenge-execution-v1",
    SpecificationId = "0.2.3-draft.71",
    PlannedDatasets = nrow(manifest),
    PlannedFitRows = nrow(manifest) * 3L,
    Maxit = mfrmr_gpcm_mml_boundary_challenge_maxit,
    QuadraturePoints = paste(
      mfrmr_gpcm_mml_boundary_challenge_quad_points, collapse = ";"
    ),
    RuntimePackageSHA256 = as.character(runtime$PackageSHA256),
    RunnerSHA256 = mfrmr_gpcm_repilot_hash_file(runner_path),
    ContractSHA256 = mfrmr_gpcm_repilot_hash_file(
      mfrmr_gpcm_mml_boundary_challenge_contract_path()
    ),
    ManifestSHA256 = mfrmr_gpcm_repilot_hash_object(manifest),
    ConfirmationAuthorized = FALSE,
    EvidenceRole = "deterministic_calibration",
    ReadinessPropagation = FALSE,
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
      stop("The Draft.71 output is already complete.", call. = FALSE)
    }
    existing <- list.files(checkpoint_dir, full.names = TRUE)
    if (length(existing) > 0L && !isTRUE(resume)) {
      stop("Existing Draft.71 checkpoints require `resume = TRUE`.",
           call. = FALSE)
    }
    expected <- paste0(manifest$DatasetId, ".rds")
    if (any(!basename(existing) %in% expected)) {
      stop("The Draft.71 checkpoint directory contains an orphan file.",
           call. = FALSE)
    }
  } else if (isTRUE(resume)) {
    stop("Draft.71 resume requires an output directory.", call. = FALSE)
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
      mfrmr_gpcm_mml_boundary_challenge_validate_checkpoint(
        checkpoint, row, execution_sha
      )
    } else {
      if (isTRUE(progress)) {
        message(sprintf(
          "[gpcm-mml-boundary-challenge %d/%d] %s",
          i, nrow(manifest), row$DatasetId
        ))
      }
      run <- mfrmr_gpcm_mml_boundary_challenge_run_dataset(row)
      checkpoint <- mfrmr_gpcm_mml_boundary_challenge_checkpoint(
        row, run, execution_sha
      )
      mfrmr_gpcm_mml_boundary_challenge_validate_checkpoint(
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
      id, mfrmr_gpcm_mml_boundary_challenge_quad_points, sep = "::"
    ),
    character(3), USE.NAMES = FALSE
  ))
  if (!identical(
    paste(results$DatasetId, results$QuadraturePoints, sep = "::"),
    expected_order
  ) || !identical(
    as.character(dataset_summary$DatasetId),
    as.character(manifest$DatasetId)
  )) {
    stop("The Draft.71 aggregate lost its declared order.", call. = FALSE)
  }
  summary <- data.frame(
    PlannedDatasets = nrow(manifest),
    PlannedFitRows = nrow(manifest) * 3L,
    ExecutedFitRows = nrow(results),
    FitSucceeded = sum(results$FitSucceeded),
    AuditComplete = sum(results$AuditComplete),
    ArmExpectationsPassed = sum(results$ArmExpectationPassed),
    DatasetExpectationsPassed = sum(
      dataset_summary$DatasetExpectationPassed
    ),
    CertifiedArms = sum(results$CertifiedPairs > 0L, na.rm = TRUE),
    NoneCertifiedArms = sum(results$CertifiedPairs == 0L, na.rm = TRUE),
    EvidenceInferenceReady = sum(results$EvidenceInferenceReady),
    ConfirmationAuthorized = FALSE,
    ReadinessPropagation = FALSE,
    stringsAsFactors = FALSE
  )
  result <- structure(list(
    manifest = manifest,
    results = results,
    dataset_summary = dataset_summary,
    summary = summary,
    execution_identity = execution,
    checkpoint_ledger = do.call(rbind, ledger),
    confirmation_authorized = FALSE,
    readiness_propagation = FALSE,
    session_info = utils::sessionInfo()
  ), class = c("mfrmr_gpcm_mml_boundary_challenge", "list"))
  if (!is.null(output_dir)) {
    mfrmr_gpcm_mml_boundary_challenge_write(result, output_dir)
  }
  result
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  result <- mfrmr_run_gpcm_mml_boundary_challenge(
    output_dir = if (length(args) >= 1L) args[[1L]] else NULL,
    authorize = TRUE,
    progress = TRUE
  )
  print(result$summary)
}
