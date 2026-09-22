# Separate, target-bound, no-fit authorization decision for the single GPCM
# score v4 calibration-only boundary completion. The default decision is NO-GO
# and writes nothing. A GO row is valid only in the process that issued it.

mfrmr_gsv4a_contract_version <-
  "mfrmr_gpcm_score_v4_boundary_completion_authorization_v1"
mfrmr_gsv4a_expected <- c(
  CompletionRunnerSHA256 =
    "78e0bcfd14c5c4343e0ff4beeb9c250b324539f1dffe8468bed4ccaf13f8090e",
  DesignSHA256 =
    "bf6ae572a3c0c2253c6fbd35fc5138eaaae92728d7d9588f1d50cebfafcae838",
  V4RuleSHA256 =
    "c746bd02b435e851af0ff89fff6320c34e66a1aa9fe8c52d0b6447689dd5a126",
  RetrospectiveSHA256 =
    "831fcd4683e46785291c832242867f1962b56ce3a142c09da78fcbc311d08025",
  V3ReplayRunnerSHA256 =
    "9a6a8cc73ba1c72fb532b9254389973bfec29cb65da99642db6db9081ae0f0f9",
  PackagePayloadSHA256 =
    "ef9fe233ceaa43b9a85ee58230b80bc425dd9be38ed21867c5deeb6beea7565a",
  FixtureSHA256 =
    "57ad036bb60bd0f2cff0d2666584f3cb6d51ccb7255f4993068803a3c15a2c89"
)

mfrmr_gsv4a_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "gpcm-score-v4-boundary-completion-authorization-0\\.2\\.3\\.R$",
    files
  )]
  if (length(hit) == 0L) return(NA_character_)
  dirname(normalizePath(hit[length(hit)], winslash = "/", mustWork = FALSE))
})

mfrmr_gsv4a_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsv4a_validation_dir <- function() {
  if (!is.na(mfrmr_gsv4a_source_dir) && dir.exists(mfrmr_gsv4a_source_dir)) {
    return(mfrmr_gsv4a_source_dir)
  }
  candidates <- c(file.path("inst", "validation"),
                  file.path("..", "inst", "validation"),
                  file.path("..", "..", "inst", "validation"), ".")
  candidates <- candidates[file.exists(file.path(
    candidates, "gpcm-score-v4-boundary-completion-runner-0.2.3.R"
  ))]
  mfrmr_gsv4a_assert(length(candidates) > 0L,
                     "Cannot locate v4 completion authorization sources.")
  normalizePath(candidates[1], winslash = "/", mustWork = TRUE)
}

mfrmr_gsv4a_load_runner <- function() {
  env <- new.env(parent = globalenv())
  sys.source(file.path(
    mfrmr_gsv4a_validation_dir(),
    "gpcm-score-v4-boundary-completion-runner-0.2.3.R"
  ), envir = env)
  env
}

mfrmr_gsv4a_hash_file <- function(path) {
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gsv4a_decide <- function(output_path = NULL,
                                request_execution = FALSE,
                                fresh_process_attested = FALSE) {
  validation_dir <- mfrmr_gsv4a_validation_dir()
  source_path <- file.path(
    validation_dir,
    "gpcm-score-v4-boundary-completion-authorization-0.2.3.R"
  )
  runner_path <- file.path(
    validation_dir, "gpcm-score-v4-boundary-completion-runner-0.2.3.R"
  )
  runner_hash <- mfrmr_gsv4a_hash_file(runner_path)
  source_hash <- mfrmr_gsv4a_hash_file(source_path)
  runner <- mfrmr_gsv4a_load_runner()
  dry <- runner$mfrmr_run_gpcm_score_v4_boundary_completion(progress = FALSE)

  has_output <- length(output_path) == 1L && !is.na(output_path) &&
    nzchar(output_path)
  normalized_output <- if (has_output) {
    normalizePath(output_path, winslash = "/", mustWork = FALSE)
  } else NA_character_
  parent_exists <- has_output && dir.exists(dirname(normalized_output))
  target_absent <- has_output && !file.exists(normalized_output)

  identity <- dry$identity
  manifest <- dry$manifest
  design <- dry$design
  gates <- c(
    ExactRunner = identical(
      runner_hash, unname(mfrmr_gsv4a_expected["CompletionRunnerSHA256"])
    ) && identical(
      identity$CompletionRunnerSHA256,
      unname(mfrmr_gsv4a_expected["CompletionRunnerSHA256"])
    ),
    ExactDesign = identical(
      identity$DesignSHA256,
      unname(mfrmr_gsv4a_expected["DesignSHA256"])
    ),
    ExactRule = identical(
      identity$V4RuleSHA256,
      unname(mfrmr_gsv4a_expected["V4RuleSHA256"])
    ),
    ExactRetrospective = identical(
      identity$RetrospectiveSHA256,
      unname(mfrmr_gsv4a_expected["RetrospectiveSHA256"])
    ),
    ExactReplayRunner = identical(
      identity$V3ReplayRunnerSHA256,
      unname(mfrmr_gsv4a_expected["V3ReplayRunnerSHA256"])
    ),
    ExactPayload = identical(
      identity$PackagePayloadSHA256,
      unname(mfrmr_gsv4a_expected["PackagePayloadSHA256"])
    ),
    ExactManifest = nrow(manifest) == 1L &&
      identical(manifest$ScenarioId, "NUM-GPCM-SCORE-V4-CAL-BND6-C") &&
      identical(
        manifest$FixtureSHA256,
        unname(mfrmr_gsv4a_expected["FixtureSHA256"])
      ) && !isTRUE(manifest$AuthorizationEmbedded),
    CompleteDesign = identical(design$ExpectedEvidenceRows, 4L) &&
      identical(design$ExpectedCoordinateRows, 24L) &&
      identical(design$ExpectedPointRows, 1L) &&
      identical(design$ExpectedJacobianRows, 30L),
    CalibrationOnly = isTRUE(design$CalibrationOnly) &&
      !isTRUE(design$ConfirmationEligible) &&
      !isTRUE(design$ExecutionAuthorized),
    DevelopmentSource = isTRUE(identity$DevelopmentSourceLoaded),
    FreshProcessAttested = isTRUE(fresh_process_attested),
    ExplicitRequest = isTRUE(request_execution),
    OutputParentExists = parent_exists,
    OutputTargetAbsent = target_absent
  )
  go <- all(gates)
  out <- data.frame(
    ContractVersion = mfrmr_gsv4a_contract_version,
    Status = if (go) "go_issued_not_executed" else "no_go_not_issued",
    RunnerIdentitySHA256 = identity$IdentitySHA256,
    ManifestSHA256 = manifest$ManifestSHA256[1],
    AuthorizationSourceSHA256 = source_hash,
    AuthorizationSHA256 = NA_character_,
    OutputPath = normalized_output,
    ProcessId = Sys.getpid(),
    IssuedAtUTC = format(Sys.time(), tz = "UTC", usetz = TRUE),
    ExecutionAuthorized = go,
    IssuedNotExecuted = go,
    ConsumedAtUTC = NA_character_,
    ConsumedRowSHA256 = NA_character_,
    ExactRunner = unname(gates["ExactRunner"]),
    ExactDesign = unname(gates["ExactDesign"]),
    ExactRule = unname(gates["ExactRule"]),
    ExactRetrospective = unname(gates["ExactRetrospective"]),
    ExactReplayRunner = unname(gates["ExactReplayRunner"]),
    ExactPayload = unname(gates["ExactPayload"]),
    ExactManifest = unname(gates["ExactManifest"]),
    CompleteDesign = unname(gates["CompleteDesign"]),
    CalibrationOnly = unname(gates["CalibrationOnly"]),
    DevelopmentSource = unname(gates["DevelopmentSource"]),
    FreshProcessAttested = unname(gates["FreshProcessAttested"]),
    ExplicitRequest = unname(gates["ExplicitRequest"]),
    OutputParentExists = unname(gates["OutputParentExists"]),
    OutputTargetAbsent = unname(gates["OutputTargetAbsent"]),
    FitOpened = FALSE,
    ConfirmationAuthorized = FALSE,
    GeneralNUMSCORETOLFrozen = FALSE,
    InferenceAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  canonical <- out
  canonical$AuthorizationSHA256 <- NULL
  out$AuthorizationSHA256 <- runner$mfrmr_gscr_hash_object(canonical)
  out
}
