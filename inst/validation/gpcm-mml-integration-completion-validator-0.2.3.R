# Independent completion validator for the Draft.68 MML sensitivity bundle.

mfrmr_gpcm_mml_resolve_validator_source_dir <- function() {
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  args <- sub("^--file=", "", grep(
    "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
  ))
  hit <- c(files[grepl(
    "gpcm-mml-integration-completion-validator-0\\.2\\.3\\.R$", files
  )], args)
  candidates <- unique(c(
    dirname(hit),
    getwd(),
    file.path(getwd(), "inst", "validation")
  ))
  runner <- file.path(
    candidates, "gpcm-mml-integration-sensitivity-0.2.3.R"
  )
  found <- candidates[file.exists(runner)]
  if (length(found) == 0L) NA_character_ else {
    normalizePath(found[[1L]], winslash = "/", mustWork = TRUE)
  }
}

mfrmr_gpcm_mml_validator_source_dir <-
  mfrmr_gpcm_mml_resolve_validator_source_dir()

mfrmr_validate_gpcm_mml_integration_completion <- function(
    output_dir,
    expected_execution_sha256 =
      "d993825cc8a58a3e3e1d17c6e4a8a6e2cc4fb16611c0429acd32296b81f70e70") {
  if (is.na(mfrmr_gpcm_mml_validator_source_dir)) {
    stop("Cannot resolve the MML completion-validator source directory.",
         call. = FALSE)
  }
  runner <- file.path(
    mfrmr_gpcm_mml_validator_source_dir,
    "gpcm-mml-integration-sensitivity-0.2.3.R"
  )
  env <- new.env(parent = globalenv())
  sys.source(runner, envir = env)
  env$mfrmr_gpcm_mml_source_dir <- mfrmr_gpcm_mml_validator_source_dir
  env$mfrmr_gpcm_mml_load_support()
  hash_object <- get(
    "mfrmr_gpcm_repilot_hash_object", envir = env, inherits = TRUE
  )
  hash_file <- get(
    "mfrmr_gpcm_repilot_hash_file", envir = env, inherits = TRUE
  )

  marker_path <- file.path(output_dir, "run-complete.rds")
  result_path <- file.path(output_dir, "gpcm-mml-integration-sensitivity.rds")
  if (!file.exists(marker_path) || !file.exists(result_path)) {
    stop("The MML sensitivity completion bundle is incomplete.",
         call. = FALSE)
  }
  marker <- readRDS(marker_path)
  if (!is.list(marker) || !identical(
    marker$Schema, "mfrmr-gpcm-mml-integration-completion-v1"
  ) || !identical(
    as.character(marker$ExecutionSHA256),
    as.character(expected_execution_sha256)
  )) {
    stop("The MML sensitivity completion marker has the wrong identity.",
         call. = FALSE)
  }
  inventory <- as.data.frame(marker$Inventory, stringsAsFactors = FALSE)
  if (!identical(
    marker$InventorySHA256,
    hash_object(inventory)
  ) || anyDuplicated(inventory$File) || any(grepl("^/|[.][.]/", inventory$File))) {
    stop("The MML sensitivity completion inventory is malformed.",
         call. = FALSE)
  }
  paths <- file.path(output_dir, inventory$File)
  if (any(!file.exists(paths))) {
    stop("The MML sensitivity inventory names a missing artifact.",
         call. = FALSE)
  }
  actual_hashes <- vapply(
    paths, hash_file,
    character(1), USE.NAMES = FALSE
  )
  if (!identical(actual_hashes, as.character(inventory$SHA256))) {
    stop("The MML sensitivity artifact inventory hash check failed.",
         call. = FALSE)
  }
  actual_files <- list.files(
    output_dir, recursive = TRUE, all.files = TRUE, no.. = TRUE
  )
  actual_files <- sort(setdiff(actual_files, "run-complete.rds"))
  if (!identical(sort(inventory$File), actual_files)) {
    stop("The MML sensitivity bundle contains unlisted or omitted artifacts.",
         call. = FALSE)
  }

  result <- readRDS(result_path)
  execution_sha <- as.character(
    result$execution_identity$ExecutionSHA256[1]
  )
  expected_manifest <- env$mfrmr_gpcm_mml_manifest("pilot")
  required_manifest <- c(
    "DatasetId", "SlopeOwner", "DesignId", "Replicate", "Seed"
  )
  if (!identical(execution_sha, expected_execution_sha256) ||
      !all(required_manifest %in% names(result$manifest)) ||
      !identical(result$manifest, expected_manifest) ||
      !identical(
        as.character(result$execution_identity$ManifestSHA256[1]),
        hash_object(result$manifest)
      ) ||
      anyDuplicated(result$manifest$DatasetId) ||
      nrow(result$manifest) != 40L || nrow(result$results) != 120L) {
    stop("The MML aggregate result violates its declared execution.",
         call. = FALSE)
  }
  checkpoint_dir <- file.path(output_dir, "checkpoints")
  for (i in seq_len(nrow(result$manifest))) {
    row <- result$manifest[i, , drop = FALSE]
    checkpoint <- readRDS(env$mfrmr_gpcm_mml_checkpoint_path(
      checkpoint_dir, row$DatasetId
    ))
    env$mfrmr_gpcm_mml_validate_checkpoint(
      checkpoint, row, expected_execution_sha256
    )
  }
  observed <- paste(
    result$results$DatasetId,
    result$results$QuadraturePoints,
    sep = "::"
  )
  expected <- as.vector(vapply(
    result$manifest$DatasetId,
    function(id) paste(id, c(31L, 61L, 91L), sep = "::"),
    character(3), USE.NAMES = FALSE
  ))
  data_hash_count <- vapply(
    split(result$results$DataSHA256, result$results$DatasetId),
    function(value) length(unique(value)), integer(1)
  )
  row_count <- table(result$results$DatasetId)
  if (!identical(observed, expected) ||
      length(data_hash_count) != 40L || any(data_hash_count != 1L) ||
      length(row_count) != 40L || any(row_count != 3L) ||
      isTRUE(result$confirmation_authorized)) {
    stop("The MML aggregate lost grid pairing or confirmation protection.",
         call. = FALSE)
  }
  invisible(marker)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) < 1L) stop("Supply the completed MML sensitivity directory.",
                              call. = FALSE)
  marker <- mfrmr_validate_gpcm_mml_integration_completion(args[[1L]])
  print(marker[c("Schema", "ExecutionSHA256", "InventorySHA256")])
}
