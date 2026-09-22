# Independent completion validator for the Draft.70 MML boundary/grid bundle.

mfrmr_gpcm_mml_boundary_grid_resolve_validator_source_dir <- function() {
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  args <- sub("^--file=", "", grep(
    "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
  ))
  hit <- c(files[grepl(
    "gpcm-mml-boundary-grid-completion-validator-0\\.2\\.3\\.R$", files
  )], args)
  candidates <- unique(c(
    dirname(hit),
    getwd(),
    file.path(getwd(), "inst", "validation")
  ))
  runner <- file.path(
    candidates, "gpcm-mml-boundary-grid-calibration-0.2.3.R"
  )
  found <- candidates[file.exists(runner)]
  if (length(found) == 0L) NA_character_ else {
    normalizePath(found[[1L]], winslash = "/", mustWork = TRUE)
  }
}

mfrmr_gpcm_mml_boundary_grid_validator_source_dir <-
  mfrmr_gpcm_mml_boundary_grid_resolve_validator_source_dir()

mfrmr_validate_gpcm_mml_boundary_grid_completion <- function(
    output_dir,
    source_integration_dir,
    expected_execution_sha256 =
      "63a40b54a84d2c4f5c9bd9bb57deff73d1e91447dbb151cde022ce059f402ab7") {
  if (is.na(mfrmr_gpcm_mml_boundary_grid_validator_source_dir)) {
    stop("Cannot resolve the boundary/grid completion-validator source directory.",
         call. = FALSE)
  }
  runner <- file.path(
    mfrmr_gpcm_mml_boundary_grid_validator_source_dir,
    "gpcm-mml-boundary-grid-calibration-0.2.3.R"
  )
  contract <- file.path(
    mfrmr_gpcm_mml_boundary_grid_validator_source_dir,
    "gpcm-mml-boundary-grid-calibration-contract-0.2.3.md"
  )
  env <- new.env(parent = globalenv())
  sys.source(runner, envir = env)
  env$mfrmr_gpcm_mml_boundary_grid_source_dir <-
    mfrmr_gpcm_mml_boundary_grid_validator_source_dir
  env$mfrmr_gpcm_mml_boundary_grid_load_support()
  hash_object <- get(
    "mfrmr_gpcm_repilot_hash_object", envir = env, inherits = TRUE
  )
  hash_file <- get(
    "mfrmr_gpcm_repilot_hash_file", envir = env, inherits = TRUE
  )

  marker_path <- file.path(output_dir, "run-complete.rds")
  result_path <- file.path(
    output_dir, "gpcm-mml-boundary-grid-calibration.rds"
  )
  if (!file.exists(marker_path) || !file.exists(result_path)) {
    stop("The boundary/grid completion bundle is incomplete.", call. = FALSE)
  }
  marker <- readRDS(marker_path)
  if (!is.list(marker) || !identical(
    marker$Schema, "mfrmr-gpcm-mml-boundary-grid-completion-v1"
  ) || !identical(
    as.character(marker$ExecutionSHA256),
    as.character(expected_execution_sha256)
  )) {
    stop("The boundary/grid completion marker has the wrong identity.",
         call. = FALSE)
  }
  inventory <- as.data.frame(marker$Inventory, stringsAsFactors = FALSE)
  if (!identical(marker$InventorySHA256, hash_object(inventory)) ||
      nrow(inventory) != 49L || anyDuplicated(inventory$File) ||
      any(grepl("^/|[.][.]/", inventory$File))) {
    stop("The boundary/grid completion inventory is malformed.",
         call. = FALSE)
  }
  paths <- file.path(output_dir, inventory$File)
  if (any(!file.exists(paths))) {
    stop("The boundary/grid inventory names a missing artifact.",
         call. = FALSE)
  }
  actual_hashes <- vapply(
    paths, hash_file, character(1), USE.NAMES = FALSE
  )
  if (!identical(actual_hashes, as.character(inventory$SHA256))) {
    stop("The boundary/grid artifact inventory hash check failed.",
         call. = FALSE)
  }
  actual_files <- sort(setdiff(list.files(
    output_dir, recursive = TRUE, all.files = TRUE, no.. = TRUE
  ), "run-complete.rds"))
  if (!identical(sort(inventory$File), actual_files)) {
    stop("The boundary/grid bundle contains unlisted or omitted artifacts.",
         call. = FALSE)
  }

  result <- readRDS(result_path)
  execution <- result$execution_identity
  execution_sha <- as.character(execution$ExecutionSHA256[1L])
  execution_payload <- execution[, setdiff(
    names(execution), "ExecutionSHA256"
  ), drop = FALSE]
  expected_manifest <- env$mfrmr_gpcm_mml_boundary_grid_manifest(NULL)
  if (!identical(execution_sha, expected_execution_sha256) ||
      !identical(execution_sha, hash_object(execution_payload)) ||
      !identical(as.character(execution$RunnerSHA256[1L]),
                 hash_file(runner)) ||
      !identical(as.character(execution$ContractSHA256[1L]),
                 hash_file(contract)) ||
      !identical(result$manifest, expected_manifest) ||
      !identical(as.character(execution$ManifestSHA256[1L]),
                 hash_object(result$manifest)) ||
      nrow(result$manifest) != 40L || anyDuplicated(result$manifest$DatasetId) ||
      nrow(result$results) != 120L || nrow(result$dataset_summary) != 40L) {
    stop("The boundary/grid aggregate violates its declared execution.",
         call. = FALSE)
  }

  checkpoint_dir <- file.path(output_dir, "checkpoints")
  checkpoint_results <- vector("list", nrow(result$manifest))
  checkpoint_datasets <- vector("list", nrow(result$manifest))
  for (i in seq_len(nrow(result$manifest))) {
    row <- result$manifest[i, , drop = FALSE]
    path <- file.path(checkpoint_dir, paste0(row$DatasetId, ".rds"))
    checkpoint <- readRDS(path)
    env$mfrmr_gpcm_mml_boundary_grid_validate_checkpoint(
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
      stop("The boundary/grid checkpoint ledger is inconsistent.",
           call. = FALSE)
    }
  }
  reconstructed_results <- do.call(rbind, checkpoint_results)
  reconstructed_datasets <- do.call(rbind, checkpoint_datasets)
  row.names(reconstructed_results) <- row.names(reconstructed_datasets) <- NULL
  if (!identical(result$results, reconstructed_results) ||
      !identical(result$dataset_summary, reconstructed_datasets)) {
    stop("The boundary/grid aggregate does not equal its checkpoints.",
         call. = FALSE)
  }

  expected_order <- as.vector(vapply(
    result$manifest$DatasetId,
    function(id) paste(id, c(31L, 61L, 91L), sep = "::"),
    character(3), USE.NAMES = FALSE
  ))
  observed_order <- paste(
    result$results$DatasetId, result$results$QuadraturePoints, sep = "::"
  )
  data_hash_count <- vapply(
    split(result$results$DataSHA256, result$results$DatasetId),
    function(value) length(unique(value)), integer(1)
  )
  if (!identical(observed_order, expected_order) ||
      length(data_hash_count) != 40L || any(data_hash_count != 1L) ||
      !all(result$results$SourceRowMatched) ||
      !all(result$results$SourceDataSHA256Matched) ||
      !all(result$dataset_summary$SourceRowsMatched) ||
      !all(result$dataset_summary$SourceDataSHA256Matched)) {
    stop("The boundary/grid aggregate lost grid or source-data pairing.",
         call. = FALSE)
  }

  source_marker_path <- file.path(source_integration_dir, "run-complete.rds")
  source_result_path <- file.path(
    source_integration_dir, "gpcm-mml-integration-sensitivity.rds"
  )
  if (!file.exists(source_marker_path) || !file.exists(source_result_path)) {
    stop("The frozen Draft.68 source bundle is unavailable.", call. = FALSE)
  }
  source_marker <- readRDS(source_marker_path)
  source_result <- readRDS(source_result_path)
  if (!identical(
    as.character(source_marker$ExecutionSHA256),
    as.character(execution$SourceMMLExecutionSHA256[1L])
  ) || !identical(
    as.character(source_marker$InventorySHA256),
    as.character(execution$SourceMMLInventorySHA256[1L])
  ) || !identical(
    hash_file(source_result_path),
    as.character(execution$SourceMMLRDS_SHA256[1L])
  )) {
    stop("The frozen Draft.68 source identity does not match.", call. = FALSE)
  }
  source_key <- paste(
    source_result$results$DatasetId,
    source_result$results$QuadraturePoints,
    sep = "::"
  )
  source_index <- match(observed_order, source_key)
  if (anyNA(source_index) || !identical(
    as.character(result$results$DataSHA256),
    as.character(source_result$results$DataSHA256[source_index])
  )) {
    stop("The boundary/grid rows do not match the frozen Draft.68 panel.",
         call. = FALSE)
  }
  own_difference <- result$results$OwnGridNLL -
    source_result$results$OwnGridNLL[source_index]
  common_difference <- result$results$CommonQ91NLL -
    source_result$results$CommonQ91NLL[source_index]
  if (!isTRUE(all.equal(
    result$results$OwnGridNLLDifferenceFromDraft68,
    own_difference, tolerance = 0, check.attributes = FALSE
  )) || !isTRUE(all.equal(
    result$results$CommonQ91NLLDifferenceFromDraft68,
    common_difference, tolerance = 0, check.attributes = FALSE
  ))) {
    stop("The boundary/grid Draft.68 likelihood differences are inconsistent.",
         call. = FALSE)
  }

  expected_summary <- data.frame(
    PlannedDatasets = 40L,
    PlannedFitRows = 120L,
    ExecutedFitRows = nrow(result$results),
    FitSucceeded = sum(result$results$FitSucceeded),
    AuditComplete = sum(result$results$AuditComplete),
    CertifiedArms = sum(result$results$CertifiedPairs > 0L, na.rm = TRUE),
    CertifiedDatasets = sum(result$dataset_summary$AnyCertifiedPair),
    AuditStateStableDatasets = sum(
      result$dataset_summary$AuditStatesIdentical
    ),
    CertifiedDirectionStableDatasets = sum(
      result$dataset_summary$CertifiedDirectionsIdentical
    ),
    SourceDataMatchedDatasets = sum(
      result$dataset_summary$SourceDataSHA256Matched
    ),
    EvidenceInferenceReady = sum(result$results$EvidenceInferenceReady),
    ConfirmationAuthorized = FALSE,
    ThresholdStatus = "retrospective_calibration_not_frozen",
    stringsAsFactors = FALSE
  )
  if (!identical(result$summary, expected_summary) ||
      isTRUE(result$confirmation_authorized) ||
      any(result$results$ConfirmationAuthorized) ||
      any(result$dataset_summary$ConfirmationAuthorized) ||
      any(result$numeric_summary$ThresholdFrozen)) {
    stop("The boundary/grid completion lost its non-confirmation protection.",
         call. = FALSE)
  }
  invisible(marker)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) < 2L) {
    stop("Supply the completed Draft.70 and frozen Draft.68 directories.",
         call. = FALSE)
  }
  marker <- mfrmr_validate_gpcm_mml_boundary_grid_completion(
    args[[1L]], args[[2L]]
  )
  print(marker[c("Schema", "ExecutionSHA256", "InventorySHA256")])
}
