# Separate, target-bound, no-fit authorization decision for one GPCM score v4
# disjoint confirmation. The default decision is NO-GO and writes nothing. A
# GO row is valid only in the process that issued it and only for an absent,
# explicitly absolute output target.

mfrmr_gsv4qa_contract_version <-
  "mfrmr_gpcm_score_v4_confirmation_authorization_v1"
mfrmr_gsv4qa_expected <- c(
  ConfirmationRunnerSHA256 =
    "53de91632f368bc404ff064b7819d820ee7f592db74b286071a70b8f88715c1a",
  ConfirmationDesignSHA256 =
    "31b495b46aef7706835030efe3b41d2888242a4a8f7724ead435c2c7648fb11a",
  V4FreezeSHA256 =
    "3baab8bfabf5b05600a2a12057cfcb6b79c7c3c665824675afb6cafa9c56744b",
  V4RuleSHA256 =
    "c746bd02b435e851af0ff89fff6320c34e66a1aa9fe8c52d0b6447689dd5a126",
  V3ReplayRunnerSHA256 =
    "9a6a8cc73ba1c72fb532b9254389973bfec29cb65da99642db6db9081ae0f0f9",
  PackagePayloadSHA256 =
    "ef9fe233ceaa43b9a85ee58230b80bc425dd9be38ed21867c5deeb6beea7565a",
  IdentitySHA256 =
    "14bccb69494f98798abf3dd23dbf51ea18107d19d251e9df2dad29011400be2f",
  ManifestSHA256 =
    "04efdbcb857f6bd99ee4295e560594e6e1fd005a7623864e40bd857b34cf5b33",
  ValidatorSHA256 =
    "7646c8cfb042942c5bbc00454410e3f5528a370e057478e1c8e16a96acadcaf9"
)
mfrmr_gsv4qa_expected_fixtures <- c(
  braid5 =
    "7d751e4436ea6be7ae9bad5d1d990b527fb81f5ee5b3335dc9475225a779dbd0",
  weave6 =
    "53e53bdc816338008a07459d434c69a1b7acabfa41ef5dd215d2fefd8dcb2a7b",
  fan7 =
    "50bb1b0c48f7ee9154315d5794d9c44a60f842f6df986e57191cc7c78ddc899f"
)

mfrmr_gsv4qa_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "gpcm-score-v4-confirmation-authorization-0\\.2\\.3\\.R$", files
  )]
  if (length(hit) == 0L) return(NA_character_)
  dirname(normalizePath(hit[length(hit)], winslash = "/", mustWork = FALSE))
})

mfrmr_gsv4qa_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsv4qa_validation_dir <- function() {
  if (!is.na(mfrmr_gsv4qa_source_dir) && dir.exists(mfrmr_gsv4qa_source_dir)) {
    return(mfrmr_gsv4qa_source_dir)
  }
  candidates <- c(
    file.path("inst", "validation"), file.path("..", "inst", "validation"),
    file.path("..", "..", "inst", "validation"), "."
  )
  candidates <- candidates[file.exists(file.path(
    candidates, "gpcm-score-v4-confirmation-runner-0.2.3.R"
  ))]
  mfrmr_gsv4qa_assert(
    length(candidates) > 0L,
    "Cannot locate v4 confirmation authorization sources."
  )
  normalizePath(candidates[[1L]], winslash = "/", mustWork = TRUE)
}

mfrmr_gsv4qa_load_runner <- function() {
  env <- new.env(parent = globalenv())
  sys.source(file.path(
    mfrmr_gsv4qa_validation_dir(),
    "gpcm-score-v4-confirmation-runner-0.2.3.R"
  ), envir = env)
  env
}

mfrmr_gsv4qa_hash_file <- function(path) {
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gsv4qa_decide <- function(output_path = NULL,
                                 request_execution = FALSE,
                                 fresh_process_attested = FALSE) {
  validation_dir <- mfrmr_gsv4qa_validation_dir()
  source_path <- file.path(
    validation_dir, "gpcm-score-v4-confirmation-authorization-0.2.3.R"
  )
  runner_path <- file.path(
    validation_dir, "gpcm-score-v4-confirmation-runner-0.2.3.R"
  )
  runner_hash <- mfrmr_gsv4qa_hash_file(runner_path)
  source_hash <- mfrmr_gsv4qa_hash_file(source_path)
  validator_path <- file.path(
    validation_dir, "gpcm-score-v4-confirmation-validator-0.2.3.R"
  )
  validator_hash <- if (file.exists(validator_path)) {
    mfrmr_gsv4qa_hash_file(validator_path)
  } else NA_character_
  runner <- mfrmr_gsv4qa_load_runner()
  dry <- runner$mfrmr_run_gpcm_score_v4_confirmation(progress = FALSE)

  has_output <- length(output_path) == 1L && !is.na(output_path) &&
    nzchar(output_path)
  input_absolute <- has_output &&
    runner$mfrmr_gsv4q_is_absolute_path(output_path)
  normalized_output <- if (has_output) {
    normalizePath(output_path, winslash = "/", mustWork = FALSE)
  } else NA_character_
  parent_exists <- has_output && dir.exists(dirname(normalized_output))
  target_absent <- has_output && !file.exists(normalized_output)

  identity <- dry$identity
  manifest <- dry$manifest
  design <- dry$design
  fixture_by_design <- setNames(
    manifest$FixtureSHA256[match(
      names(mfrmr_gsv4qa_expected_fixtures), manifest$DesignId
    )],
    names(mfrmr_gsv4qa_expected_fixtures)
  )
  scenario_ids <- c(
    "NUM-GPCM-SCORE-V4-CONF-BRAID5-C",
    "NUM-GPCM-SCORE-V4-CONF-BRAID5-R",
    "NUM-GPCM-SCORE-V4-CONF-WEAVE6-C",
    "NUM-GPCM-SCORE-V4-CONF-WEAVE6-R",
    "NUM-GPCM-SCORE-V4-CONF-FAN7-C",
    "NUM-GPCM-SCORE-V4-CONF-FAN7-R"
  )
  gates <- c(
    ExactRunner = identical(
      runner_hash,
      unname(mfrmr_gsv4qa_expected["ConfirmationRunnerSHA256"])
    ) && identical(
      identity$V4RunnerSHA256,
      unname(mfrmr_gsv4qa_expected["ConfirmationRunnerSHA256"])
    ),
    ExactDesign = identical(
      identity$V4DesignSHA256,
      unname(mfrmr_gsv4qa_expected["ConfirmationDesignSHA256"])
    ),
    ExactFreeze = identical(
      identity$V4FreezeSHA256,
      unname(mfrmr_gsv4qa_expected["V4FreezeSHA256"])
    ),
    ExactRule = identical(
      identity$V4RuleSHA256,
      unname(mfrmr_gsv4qa_expected["V4RuleSHA256"])
    ),
    ExactReplayRunner = identical(
      identity$V3ReplayRunnerSHA256,
      unname(mfrmr_gsv4qa_expected["V3ReplayRunnerSHA256"])
    ),
    ExactPayload = identical(
      identity$PackagePayloadSHA256,
      unname(mfrmr_gsv4qa_expected["PackagePayloadSHA256"])
    ),
    ExactIdentity = identical(
      identity$IdentitySHA256,
      unname(mfrmr_gsv4qa_expected["IdentitySHA256"])
    ),
    ExactManifest = nrow(manifest) == 6L &&
      identical(manifest$ScenarioId, scenario_ids) &&
      length(unique(manifest$ManifestSHA256)) == 1L &&
      identical(
        manifest$ManifestSHA256[[1L]],
        unname(mfrmr_gsv4qa_expected["ManifestSHA256"])
      ) && identical(
        unname(fixture_by_design),
        unname(mfrmr_gsv4qa_expected_fixtures)
      ) && all(!manifest$ResultOpened) &&
      all(!manifest$ConfirmationExecutionAuthorized),
    ExactValidator = identical(
      validator_hash, unname(mfrmr_gsv4qa_expected["ValidatorSHA256"])
    ),
    CompleteDesign = identical(design$ExpectedEvidenceRows, 96L) &&
      identical(design$ExpectedCoordinateRows, 888L) &&
      identical(design$ExpectedPointRows, 24L) &&
      identical(design$ExpectedJacobianRows, 688L),
    DisjointConfirmation = !isTRUE(design$PriorFixtureIdentityOverlap) &&
      !isTRUE(design$CalibrationDataReused) &&
      !isTRUE(design$ResultOpened) && !isTRUE(design$RuleChangedAfterFreeze) &&
      isTRUE(design$FutureExecutionMustRecordAbsoluteTarget) &&
      !isTRUE(design$ConfirmationExecutionAuthorized),
    DevelopmentSource = isTRUE(identity$DevelopmentSourceLoaded),
    FreshProcessAttested = isTRUE(fresh_process_attested),
    ExplicitRequest = isTRUE(request_execution),
    InputPathAbsolute = input_absolute,
    OutputParentExists = parent_exists,
    OutputTargetAbsent = target_absent
  )
  go <- all(gates)
  out <- data.frame(
    ContractVersion = mfrmr_gsv4qa_contract_version,
    Status = if (go) "go_issued_not_executed" else "no_go_not_issued",
    RunnerIdentitySHA256 = identity$IdentitySHA256,
    ManifestSHA256 = manifest$ManifestSHA256[[1L]],
    AuthorizationSourceSHA256 = source_hash,
    ValidatorSHA256 = validator_hash,
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
    ExactFreeze = unname(gates["ExactFreeze"]),
    ExactRule = unname(gates["ExactRule"]),
    ExactReplayRunner = unname(gates["ExactReplayRunner"]),
    ExactPayload = unname(gates["ExactPayload"]),
    ExactIdentity = unname(gates["ExactIdentity"]),
    ExactManifest = unname(gates["ExactManifest"]),
    ExactValidator = unname(gates["ExactValidator"]),
    CompleteDesign = unname(gates["CompleteDesign"]),
    DisjointConfirmation = unname(gates["DisjointConfirmation"]),
    DevelopmentSource = unname(gates["DevelopmentSource"]),
    FreshProcessAttested = unname(gates["FreshProcessAttested"]),
    ExplicitRequest = unname(gates["ExplicitRequest"]),
    InputPathAbsolute = unname(gates["InputPathAbsolute"]),
    OutputParentExists = unname(gates["OutputParentExists"]),
    OutputTargetAbsent = unname(gates["OutputTargetAbsent"]),
    FitOpened = FALSE,
    ResultOpened = FALSE,
    GeneralNUMSCORETOLFrozen = FALSE,
    BoundaryProven = FALSE,
    InferenceAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  canonical <- out
  canonical$AuthorizationSHA256 <- NULL
  out$AuthorizationSHA256 <- runner$mfrmr_gscr_hash_object(canonical)
  out
}
