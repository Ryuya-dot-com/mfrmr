# Independent completion validator for the Draft.71 boundary challenge.

mfrmr_gpcm_mml_boundary_challenge_resolve_validator_source_dir <- function() {
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  args <- sub("^--file=", "", grep(
    "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
  ))
  hit <- c(files[grepl(
    "gpcm-mml-boundary-challenge-completion-validator-0\\.2\\.3\\.R$",
    files
  )], args)
  candidates <- unique(c(
    dirname(hit), getwd(), file.path(getwd(), "inst", "validation")
  ))
  runner <- file.path(
    candidates, "gpcm-mml-boundary-challenge-0.2.3.R"
  )
  found <- candidates[file.exists(runner)]
  if (length(found) == 0L) NA_character_ else {
    normalizePath(found[[1L]], winslash = "/", mustWork = TRUE)
  }
}

mfrmr_gpcm_mml_boundary_challenge_validator_source_dir <-
  mfrmr_gpcm_mml_boundary_challenge_resolve_validator_source_dir()

mfrmr_validate_gpcm_mml_boundary_challenge_completion <- function(
    output_dir,
    expected_execution_sha256 =
      "1b442b29510fa763ebe1277a4c314b3c27dcff9dea3715cda8db7d55811ab11f") {
  if (is.na(mfrmr_gpcm_mml_boundary_challenge_validator_source_dir)) {
    stop("Cannot resolve the boundary-challenge validator source directory.",
         call. = FALSE)
  }
  runner <- file.path(
    mfrmr_gpcm_mml_boundary_challenge_validator_source_dir,
    "gpcm-mml-boundary-challenge-0.2.3.R"
  )
  contract <- file.path(
    mfrmr_gpcm_mml_boundary_challenge_validator_source_dir,
    "gpcm-mml-boundary-challenge-contract-0.2.3.md"
  )
  env <- new.env(parent = globalenv())
  sys.source(runner, envir = env)
  env$mfrmr_gpcm_mml_boundary_challenge_source_dir <-
    mfrmr_gpcm_mml_boundary_challenge_validator_source_dir
  env$mfrmr_gpcm_mml_boundary_challenge_load_support()
  hash_object <- get(
    "mfrmr_gpcm_repilot_hash_object", envir = env, inherits = TRUE
  )
  hash_file <- get(
    "mfrmr_gpcm_repilot_hash_file", envir = env, inherits = TRUE
  )

  marker_path <- file.path(output_dir, "run-complete.rds")
  result_path <- file.path(output_dir, "gpcm-mml-boundary-challenge.rds")
  if (!file.exists(marker_path) || !file.exists(result_path)) {
    stop("The boundary-challenge completion bundle is incomplete.",
         call. = FALSE)
  }
  marker <- readRDS(marker_path)
  if (!is.list(marker) || !identical(
    marker$Schema, "mfrmr-gpcm-mml-boundary-challenge-completion-v1"
  ) || !identical(
    as.character(marker$ExecutionSHA256), expected_execution_sha256
  )) {
    stop("The boundary-challenge completion marker has the wrong identity.",
         call. = FALSE)
  }
  inventory <- as.data.frame(marker$Inventory, stringsAsFactors = FALSE)
  if (!identical(marker$InventorySHA256, hash_object(inventory)) ||
      nrow(inventory) != 17L || anyDuplicated(inventory$File) ||
      any(grepl("^/|[.][.]/", inventory$File))) {
    stop("The boundary-challenge completion inventory is malformed.",
         call. = FALSE)
  }
  paths <- file.path(output_dir, inventory$File)
  if (any(!file.exists(paths)) || !identical(
    vapply(paths, hash_file, character(1), USE.NAMES = FALSE),
    as.character(inventory$SHA256)
  )) {
    stop("The boundary-challenge artifact inventory hash check failed.",
         call. = FALSE)
  }
  actual_files <- sort(setdiff(list.files(
    output_dir, recursive = TRUE, all.files = TRUE, no.. = TRUE
  ), "run-complete.rds"))
  if (!identical(sort(inventory$File), actual_files)) {
    stop("The boundary-challenge bundle has unlisted or omitted artifacts.",
         call. = FALSE)
  }

  result <- readRDS(result_path)
  execution <- result$execution_identity
  payload <- execution[, setdiff(
    names(execution), "ExecutionSHA256"
  ), drop = FALSE]
  expected_manifest <- env$mfrmr_gpcm_mml_boundary_challenge_manifest()
  if (!identical(
    as.character(execution$ExecutionSHA256[1L]), expected_execution_sha256
  ) || !identical(hash_object(payload), expected_execution_sha256) ||
      !identical(as.character(execution$RunnerSHA256[1L]),
                 hash_file(runner)) ||
      !identical(as.character(execution$ContractSHA256[1L]),
                 hash_file(contract)) ||
      !identical(result$manifest, expected_manifest) ||
      !identical(as.character(execution$ManifestSHA256[1L]),
                 hash_object(result$manifest)) ||
      nrow(result$manifest) != 10L || anyDuplicated(result$manifest$DatasetId) ||
      nrow(result$results) != 30L || nrow(result$dataset_summary) != 10L) {
    stop("The boundary-challenge aggregate violates its execution.",
         call. = FALSE)
  }
  regenerated_hash <- vapply(seq_len(nrow(result$manifest)), function(i) {
    row <- result$manifest[i, , drop = FALSE]
    data <- env$mfrmr_gpcm_mml_boundary_challenge_build_data(
      as.character(row$SlopeOwner), as.character(row$Challenge)
    )
    hash_object(data)
  }, character(1))
  if (!identical(
    regenerated_hash, as.character(result$manifest$InputDataSHA256)
  )) {
    stop("The boundary-challenge deterministic inputs do not regenerate.",
         call. = FALSE)
  }

  checkpoint_results <- vector("list", nrow(result$manifest))
  checkpoint_datasets <- vector("list", nrow(result$manifest))
  for (i in seq_len(nrow(result$manifest))) {
    row <- result$manifest[i, , drop = FALSE]
    path <- file.path(
      output_dir, "checkpoints", paste0(row$DatasetId, ".rds")
    )
    checkpoint <- readRDS(path)
    env$mfrmr_gpcm_mml_boundary_challenge_validate_checkpoint(
      checkpoint, row, expected_execution_sha256
    )
    checkpoint_results[[i]] <- checkpoint$Results
    checkpoint_datasets[[i]] <- checkpoint$DatasetSummary
    ledger <- result$checkpoint_ledger[i, , drop = FALSE]
    if (!identical(as.character(ledger$DatasetId),
                   as.character(row$DatasetId)) ||
        !identical(as.character(ledger$CheckpointFile), basename(path)) ||
        !identical(as.character(ledger$CheckpointSHA256), hash_file(path)) ||
        !identical(as.character(ledger$ExecutionSHA256),
                   expected_execution_sha256)) {
      stop("The boundary-challenge checkpoint ledger is inconsistent.",
           call. = FALSE)
    }
  }
  reconstructed_results <- do.call(rbind, checkpoint_results)
  reconstructed_datasets <- do.call(rbind, checkpoint_datasets)
  row.names(reconstructed_results) <- row.names(reconstructed_datasets) <- NULL
  if (!identical(result$results, reconstructed_results) ||
      !identical(result$dataset_summary, reconstructed_datasets)) {
    stop("The boundary-challenge aggregate differs from its checkpoints.",
         call. = FALSE)
  }
  expected_order <- as.vector(vapply(
    result$manifest$DatasetId,
    function(id) paste(id, c(31L, 61L, 91L), sep = "::"),
    character(3), USE.NAMES = FALSE
  ))
  if (!identical(paste(
    result$results$DatasetId, result$results$QuadraturePoints, sep = "::"
  ), expected_order)) {
    stop("The boundary-challenge q-grid order is incomplete.", call. = FALSE)
  }
  input_index <- match(
    result$results$DatasetId, result$manifest$DatasetId
  )
  retained_counts <- vapply(
    split(result$results$RetainedDataSHA256, result$results$DatasetId),
    function(x) length(unique(x)), integer(1)
  )
  if (anyNA(input_index) || !identical(
    as.character(result$results$InputDataSHA256),
    as.character(result$manifest$InputDataSHA256[input_index])
  ) || length(retained_counts) != 10L || any(retained_counts != 1L)) {
    stop("The boundary-challenge input or retained-data pairing failed.",
         call. = FALSE)
  }

  expected_summary <- data.frame(
    PlannedDatasets = 10L,
    PlannedFitRows = 30L,
    ExecutedFitRows = nrow(result$results),
    FitSucceeded = sum(result$results$FitSucceeded),
    AuditComplete = sum(result$results$AuditComplete),
    ArmExpectationsPassed = sum(result$results$ArmExpectationPassed),
    DatasetExpectationsPassed = sum(
      result$dataset_summary$DatasetExpectationPassed
    ),
    CertifiedArms = sum(
      result$results$CertifiedPairs > 0L, na.rm = TRUE
    ),
    NoneCertifiedArms = sum(
      result$results$CertifiedPairs == 0L, na.rm = TRUE
    ),
    EvidenceInferenceReady = sum(result$results$EvidenceInferenceReady),
    ConfirmationAuthorized = FALSE,
    ReadinessPropagation = FALSE,
    stringsAsFactors = FALSE
  )
  if (!identical(result$summary, expected_summary) ||
      isTRUE(result$confirmation_authorized) ||
      isTRUE(result$readiness_propagation) ||
      any(result$results$ConfirmationAuthorized) ||
      any(result$results$ReadinessPropagation) ||
      any(result$results$EvidenceInferenceReady)) {
    stop("The boundary challenge lost its non-promotion controls.",
         call. = FALSE)
  }
  invisible(marker)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) < 1L) {
    stop("Supply the completed Draft.71 boundary-challenge directory.",
         call. = FALSE)
  }
  marker <- mfrmr_validate_gpcm_mml_boundary_challenge_completion(args[[1L]])
  print(marker[c("Schema", "ExecutionSHA256", "InventorySHA256")])
}
