# Separate, no-fit authorization decision for the sealed GPCM score v3
# confirmation runner. The default decision is NO-GO and writes nothing.

mfrmr_gsv3a_contract_version <-
  "mfrmr_gpcm_score_v3_confirmation_authorization_v1"
mfrmr_gsv3a_runner_sha256 <-
  "5159bfe10a9952e7a93d462f399766e4cdcecb1900c8399aa8de2cb7367ed5d1"
mfrmr_gsv3a_design_sha256 <-
  "c22bf47998fbad9b46e6d8b205af8a52ef6a03b17a190fb24207f2b0fc7d4ec6"

mfrmr_gsv3a_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl("gpcm-score-v3-confirmation-authorization-0\\.2\\.3\\.R$",
                     files)]
  if (length(hit) == 0L) return(NA_character_)
  dirname(normalizePath(hit[length(hit)], winslash = "/", mustWork = FALSE))
})

mfrmr_gsv3a_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsv3a_validation_dir <- function() {
  if (!is.na(mfrmr_gsv3a_source_dir) && dir.exists(mfrmr_gsv3a_source_dir)) {
    return(mfrmr_gsv3a_source_dir)
  }
  candidates <- c(file.path("inst", "validation"),
                  file.path("..", "inst", "validation"),
                  file.path("..", "..", "inst", "validation"), ".")
  candidates <- candidates[file.exists(file.path(
    candidates, "gpcm-score-v3-confirmation-runner-0.2.3.R"
  ))]
  mfrmr_gsv3a_assert(length(candidates) > 0L,
                     "Cannot locate confirmation authorization sources.")
  normalizePath(candidates[1], winslash = "/", mustWork = TRUE)
}

mfrmr_gsv3a_load_runner <- function() {
  env <- new.env(parent = globalenv())
  sys.source(file.path(mfrmr_gsv3a_validation_dir(),
                       "gpcm-score-v3-confirmation-runner-0.2.3.R"),
             envir = env)
  env
}

mfrmr_gsv3a_decide <- function(output_path = NULL, request_execution = FALSE,
                                fresh_process_attested = FALSE) {
  validation_dir <- mfrmr_gsv3a_validation_dir()
  runner_path <- file.path(validation_dir,
                           "gpcm-score-v3-confirmation-runner-0.2.3.R")
  design_path <- file.path(validation_dir,
                           "gpcm-score-v3-confirmation-design-0.2.3.R")
  runner_hash <- digest::digest(file = runner_path, algo = "sha256",
                                serialize = FALSE)
  design_hash <- digest::digest(file = design_path, algo = "sha256",
                                serialize = FALSE)
  runner <- mfrmr_gsv3a_load_runner()
  dry <- runner$mfrmr_run_gpcm_score_v3_confirmation(progress = FALSE)
  has_output <- length(output_path) == 1L && !is.na(output_path) &&
    nzchar(output_path)
  normalized_output <- if (has_output) {
    normalizePath(output_path, winslash = "/", mustWork = FALSE)
  } else NA_character_
  parent_exists <- has_output && dir.exists(dirname(normalized_output))
  target_absent <- has_output && !file.exists(normalized_output)
  gates <- c(
    ExactRunner = identical(runner_hash, mfrmr_gsv3a_runner_sha256),
    ExactDesign = identical(design_hash, mfrmr_gsv3a_design_sha256),
    ExactPayload = identical(dry$identity$PackagePayloadSHA256,
                             runner$mfrmr_gsv3c_frozen_payload),
    ExactFreeze = identical(dry$identity$FreezeSHA256,
                            runner$mfrmr_gsv3c_freeze_contract_sha256),
    ExactManifest = nrow(dry$manifest) == 6L &&
      !anyDuplicated(dry$manifest$ScenarioId) &&
      all(!dry$manifest$ResultOpened) &&
      all(!dry$manifest$ConfirmationExecutionAuthorized),
    CompleteDesign = identical(dry$design$ExpectedEvidenceRows, 96L) &&
      identical(dry$design$ExpectedCoordinateRows, 560L) &&
      identical(dry$design$ExpectedPointRows, 24L) &&
      identical(dry$design$ExpectedJacobianRows, 376L),
    DevelopmentSource = isTRUE(dry$identity$DevelopmentSourceLoaded),
    FreshProcessAttested = isTRUE(fresh_process_attested),
    ExplicitRequest = isTRUE(request_execution),
    OutputParentExists = parent_exists,
    OutputTargetAbsent = target_absent
  )
  go <- all(gates)
  data.frame(
    ContractVersion = mfrmr_gsv3a_contract_version,
    Status = if (go) "go_issued_not_executed" else "no_go_not_issued",
    RunnerIdentitySHA256 = dry$identity$IdentitySHA256,
    ManifestSHA256 = dry$manifest$ManifestSHA256[1],
    RunnerSHA256 = runner_hash, DesignSHA256 = design_hash,
    OutputPath = normalized_output, ProcessId = Sys.getpid(),
    ExactRunner = unname(gates["ExactRunner"]),
    ExactDesign = unname(gates["ExactDesign"]),
    ExactPayload = unname(gates["ExactPayload"]),
    ExactFreeze = unname(gates["ExactFreeze"]),
    ExactManifest = unname(gates["ExactManifest"]),
    CompleteDesign = unname(gates["CompleteDesign"]),
    DevelopmentSource = unname(gates["DevelopmentSource"]),
    FreshProcessAttested = unname(gates["FreshProcessAttested"]),
    ExplicitRequest = unname(gates["ExplicitRequest"]),
    OutputParentExists = unname(gates["OutputParentExists"]),
    OutputTargetAbsent = unname(gates["OutputTargetAbsent"]),
    ExecutionAuthorized = go, IssuedNotExecuted = go,
    ConfirmationResultOpened = FALSE, GeneralNUMSCORETOLFrozen = FALSE,
    InferenceAuthorized = FALSE, stringsAsFactors = FALSE
  )
}
