# Independent, no-fit validator for the one-time GPCM score v4 calibration-only
# boundary-completion artifact. This file does not source or call the runner.

mfrmr_gsv4v_contract_version <-
  "mfrmr_gpcm_score_v4_boundary_completion_validator_v1"
mfrmr_gsv4v_expected <- c(
  ArtifactSHA256 =
    "5998c6c5f01a9436af0af152d30315655291275d72c169649e048f0d5647400e",
  RunnerSHA256 =
    "78e0bcfd14c5c4343e0ff4beeb9c250b324539f1dffe8468bed4ccaf13f8090e",
  AuthorizationSourceSHA256 =
    "41f51a6d3e56b09ec92d67aee2f3ff92b0438a49c4e0d370701071072a95d3a3",
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
    "57ad036bb60bd0f2cff0d2666584f3cb6d51ccb7255f4993068803a3c15a2c89",
  IdentitySHA256 =
    "2130e8d859e5cfb120e6f46dc8b692b979f026e1dfd99496f4927d30e24e8387",
  ManifestSHA256 =
    "88fcdf2706d059ed3ac386ff80d23a4d02f10d7bc1acb747261318cc8da0192b"
)

mfrmr_gsv4v_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  args <- sub("^--file=", "", grep(
    "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
  ))
  hit <- c(files[grepl(
    "gpcm-score-v4-boundary-completion-validator-0\\.2\\.3\\.R$", files
  )], args)
  candidates <- unique(c(
    dirname(hit), getwd(), file.path(getwd(), "inst", "validation")
  ))
  found <- candidates[file.exists(file.path(
    candidates, "gpcm-score-v4-boundary-completion-runner-0.2.3.R"
  ))]
  if (length(found) == 0L) NA_character_ else {
    normalizePath(found[[1L]], winslash = "/", mustWork = TRUE)
  }
})

mfrmr_gsv4v_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsv4v_validation_dir <- function() {
  if (!is.na(mfrmr_gsv4v_source_dir) && dir.exists(mfrmr_gsv4v_source_dir)) {
    return(mfrmr_gsv4v_source_dir)
  }
  candidates <- c(
    file.path("inst", "validation"),
    file.path("..", "inst", "validation"),
    file.path("..", "..", "inst", "validation"), "."
  )
  found <- candidates[file.exists(file.path(
    candidates, "gpcm-score-v4-boundary-completion-runner-0.2.3.R"
  ))]
  mfrmr_gsv4v_assert(length(found) > 0L,
                     "Cannot resolve v4 completion validation sources.")
  normalizePath(found[[1L]], winslash = "/", mustWork = TRUE)
}

mfrmr_gsv4v_hash_file <- function(path) {
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gsv4v_hash_object <- function(object) {
  digest::digest(object, algo = "sha256", serialize = TRUE)
}

mfrmr_gsv4v_resolve_embedded_target <- function(path) {
  root <- normalizePath(file.path(mfrmr_gsv4v_validation_dir(), "..", ".."),
                        winslash = "/", mustWork = TRUE)
  absolute <- grepl("^/", path)
  resolved <- if (absolute) path else file.path(root, path)
  list(
    absolute_recorded = absolute,
    form = if (absolute) "absolute" else "repository_relative",
    resolved = normalizePath(resolved, winslash = "/", mustWork = TRUE)
  )
}

mfrmr_gsv4v_validate_result <- function(
    result, artifact_path = NULL,
    expected_artifact_sha256 = unname(
      mfrmr_gsv4v_expected["ArtifactSHA256"]
    )) {
  validation_dir <- mfrmr_gsv4v_validation_dir()
  mfrmr_gsv4v_assert(is.list(result),
                     "The v4 completion result is not a list.")
  required_parts <- c(
    "identity", "manifest", "authorization", "fit", "coordinates",
    "evidence", "point_summary", "jacobian", "decision", "executed",
    "calibration_only", "confirmation_authorized"
  )
  mfrmr_gsv4v_assert(all(required_parts %in% names(result)),
                     "The v4 completion result schema is incomplete.")

  artifact_checked <- length(artifact_path) == 1L && !is.na(artifact_path) &&
    nzchar(artifact_path)
  if (artifact_checked) {
    mfrmr_gsv4v_assert(file.exists(artifact_path),
                       "The v4 completion artifact is absent.")
    mfrmr_gsv4v_assert(
      identical(mfrmr_gsv4v_hash_file(artifact_path), expected_artifact_sha256),
      "The v4 completion artifact SHA-256 is wrong."
    )
  }

  source_files <- c(
    RunnerSHA256 = "gpcm-score-v4-boundary-completion-runner-0.2.3.R",
    AuthorizationSourceSHA256 =
      "gpcm-score-v4-boundary-completion-authorization-0.2.3.R",
    DesignSHA256 = "gpcm-score-v4-boundary-completion-design-0.2.3.R",
    V4RuleSHA256 = "gpcm-score-v4-rule-contract-0.2.3.R",
    RetrospectiveSHA256 =
      "gpcm-score-v4-retrospective-calibration-0.2.3.R",
    V3ReplayRunnerSHA256 = "gpcm-score-v3-replay-runner-0.2.3.R"
  )
  actual_source_hashes <- vapply(source_files, function(file) {
    mfrmr_gsv4v_hash_file(file.path(validation_dir, file))
  }, character(1L))
  mfrmr_gsv4v_assert(
    identical(unname(actual_source_hashes),
              unname(mfrmr_gsv4v_expected[names(source_files)])),
    "A v4 completion source identity changed after execution."
  )

  identity <- result$identity
  # IdentitySHA256 was computed before the column was appended. Column
  # selection recreates that original data.frame attribute order; `$<- NULL`
  # does not, and serialized object hashes are attribute-order sensitive.
  identity_canonical <- identity[, setdiff(
    names(identity), "IdentitySHA256"
  ), drop = FALSE]
  mfrmr_gsv4v_assert(
    is.data.frame(identity) && nrow(identity) == 1L &&
      identical(identity$IdentitySHA256,
                unname(mfrmr_gsv4v_expected["IdentitySHA256"])) &&
      identical(mfrmr_gsv4v_hash_object(identity_canonical),
                identity$IdentitySHA256) &&
      identical(identity$CompletionRunnerSHA256,
                unname(mfrmr_gsv4v_expected["RunnerSHA256"])) &&
      identical(identity$DesignSHA256,
                unname(mfrmr_gsv4v_expected["DesignSHA256"])) &&
      identical(identity$V4RuleSHA256,
                unname(mfrmr_gsv4v_expected["V4RuleSHA256"])) &&
      identical(identity$RetrospectiveSHA256,
                unname(mfrmr_gsv4v_expected["RetrospectiveSHA256"])) &&
      identical(identity$V3ReplayRunnerSHA256,
                unname(mfrmr_gsv4v_expected["V3ReplayRunnerSHA256"])) &&
      identical(identity$PackagePayloadSHA256,
                unname(mfrmr_gsv4v_expected["PackagePayloadSHA256"])),
    "The v4 completion runner identity is invalid."
  )

  manifest <- result$manifest
  manifest_canonical <- manifest
  manifest_canonical$ManifestSHA256 <- NULL
  mfrmr_gsv4v_assert(
    is.data.frame(manifest) && nrow(manifest) == 1L &&
      identical(manifest$ManifestSHA256,
                unname(mfrmr_gsv4v_expected["ManifestSHA256"])) &&
      identical(mfrmr_gsv4v_hash_object(manifest_canonical),
                manifest$ManifestSHA256) &&
      identical(manifest$FixtureSHA256,
                unname(mfrmr_gsv4v_expected["FixtureSHA256"])) &&
      identical(manifest$RunnerIdentitySHA256, identity$IdentitySHA256) &&
      identical(manifest$ExpectedEvidenceRows, 4L) &&
      identical(manifest$ExpectedCoordinateRows, 24L) &&
      identical(manifest$ExpectedPointRows, 1L) &&
      identical(manifest$ExpectedJacobianRows, 30L),
    "The v4 completion manifest is invalid."
  )

  authorization <- result$authorization
  required_authorization <- c(
    "ContractVersion", "Status", "RunnerIdentitySHA256", "ManifestSHA256",
    "AuthorizationSourceSHA256", "AuthorizationSHA256", "OutputPath",
    "ProcessId", "IssuedAtUTC", "ExecutionAuthorized", "IssuedNotExecuted",
    "ConsumedAtUTC", "ConsumedRowSHA256", "FitOpened",
    "ConfirmationAuthorized", "GeneralNUMSCORETOLFrozen",
    "InferenceAuthorized"
  )
  mfrmr_gsv4v_assert(
    is.data.frame(authorization) && nrow(authorization) == 1L &&
      all(required_authorization %in% names(authorization)),
    "The embedded v4 completion authorization is incomplete."
  )
  consumed_canonical <- authorization
  consumed_canonical$ConsumedRowSHA256 <- NULL
  issued <- authorization
  issued$Status <- "go_issued_not_executed"
  issued$IssuedNotExecuted <- TRUE
  issued$ConsumedAtUTC <- NA_character_
  issued$ConsumedRowSHA256 <- NA_character_
  issued_canonical <- issued
  issued_canonical$AuthorizationSHA256 <- NULL
  gate_names <- c(
    "ExactRunner", "ExactDesign", "ExactRule", "ExactRetrospective",
    "ExactReplayRunner", "ExactPayload", "ExactManifest", "CompleteDesign",
    "CalibrationOnly", "DevelopmentSource", "FreshProcessAttested",
    "ExplicitRequest", "OutputParentExists", "OutputTargetAbsent"
  )
  mfrmr_gsv4v_assert(
    identical(authorization$Status, "consumed_result_embedded") &&
      identical(authorization$RunnerIdentitySHA256, identity$IdentitySHA256) &&
      identical(authorization$ManifestSHA256, manifest$ManifestSHA256) &&
      identical(authorization$AuthorizationSourceSHA256,
                unname(mfrmr_gsv4v_expected["AuthorizationSourceSHA256"])) &&
      identical(authorization$ConsumedRowSHA256,
                mfrmr_gsv4v_hash_object(consumed_canonical)) &&
      identical(authorization$AuthorizationSHA256,
                mfrmr_gsv4v_hash_object(issued_canonical)) &&
      all(gate_names %in% names(authorization)) &&
      all(unlist(authorization[gate_names], use.names = FALSE)) &&
      isTRUE(authorization$ExecutionAuthorized) &&
      !isTRUE(authorization$IssuedNotExecuted) &&
      !is.na(authorization$ConsumedAtUTC) && !isTRUE(authorization$FitOpened) &&
      !isTRUE(authorization$ConfirmationAuthorized) &&
      !isTRUE(authorization$GeneralNUMSCORETOLFrozen) &&
      !isTRUE(authorization$InferenceAuthorized),
    "The embedded v4 completion authorization cannot be verified."
  )
  embedded_target <- mfrmr_gsv4v_resolve_embedded_target(
    authorization$OutputPath
  )
  if (artifact_checked) {
    mfrmr_gsv4v_assert(
      identical(
        embedded_target$resolved,
        normalizePath(artifact_path, winslash = "/", mustWork = TRUE)
      ),
      "The embedded authorization target does not resolve to the artifact."
    )
  }

  coordinates <- result$coordinates
  evidence <- result$evidence
  point <- result$point_summary
  jacobian <- result$jacobian
  classes <- c("owner_additive", "other_additive", "steps", "log_slopes")
  expected_counts <- c(5L, 2L, 12L, 5L)
  class_counts <- as.integer(table(factor(
    coordinates$ParameterClassFrozen, levels = classes
  )))
  required_coordinate_numeric <- c(
    "PackageAnalyticScore", "IndependentAnalyticScore",
    "AnalyticScoreCombinedRatio", "FiniteDifferenceReference",
    "FiniteDifferenceCombinedRatio", "V4ConstructionRawExcess",
    "V4ConstructionAllowance", "FivePointScore_1e-03",
    "FivePointScore_3e-04", "FivePointScore_1e-04"
  )
  mfrmr_gsv4v_assert(
    nrow(evidence) == 4L && nrow(coordinates) == 24L && nrow(point) == 1L &&
      nrow(jacobian) == 30L && identical(evidence$ParameterClass, classes) &&
      identical(as.integer(evidence$CoordinateCount), expected_counts) &&
      identical(class_counts, expected_counts) &&
      all(required_coordinate_numeric %in% names(coordinates)) &&
      all(is.finite(unlist(coordinates[required_coordinate_numeric],
                           use.names = FALSE))) &&
      all(coordinates$StructuralOraclePass) &&
      all(coordinates$AnalyticScoreCombinedRatio <= 1) &&
      all(coordinates$FiniteDifferenceCombinedRatio <= 1) &&
      all(jacobian$LogCombinedRatio <= 1) &&
      all(jacobian$SlopeCombinedRatio <= 1) &&
      all(coordinates$V4ConstructionRawExcess > 0) &&
      all(coordinates$V4ConstructionRawExcess <=
            coordinates$V4ConstructionAllowance),
    "The v4 completion numerical denominator or coordinate rules failed."
  )
  coordinate_max <- function(column) vapply(classes, function(class) {
    max(coordinates[[column]][coordinates$ParameterClassFrozen == class])
  }, numeric(1L))
  mfrmr_gsv4v_assert(
    isTRUE(all.equal(
      unname(evidence$MaxAnalyticScoreCombinedRatio),
      unname(coordinate_max("AnalyticScoreCombinedRatio")), tolerance = 0
    )) && isTRUE(all.equal(
      unname(evidence$FiniteDifferenceCombinedRatio),
      unname(coordinate_max("FiniteDifferenceCombinedRatio")), tolerance = 0
    )) && all(evidence$StructuralOraclePass) &&
      all(evidence$AnalyticScorePass) &&
      all(evidence$FiniteDifferenceStatus == "pass") &&
      all(evidence$LogJacobianCombinedRatio <= 1) &&
      all(evidence$SlopeJacobianCombinedRatio <= 1) &&
      all(evidence$EvaluationComplete) && all(evidence$CalibrationOnly) &&
      all(!evidence$ConfirmationEligible) &&
      all(!evidence$ConfirmationAuthorized),
    "The v4 completion evidence aggregation is invalid."
  )
  mfrmr_gsv4v_assert(
    identical(point$EntrywiseJacobianRows, 30L) &&
      identical(point$FiniteDifferenceStatus, "pass") &&
      identical(point$MaxAnalyticScoreCombinedRatio,
                max(coordinates$AnalyticScoreCombinedRatio)) &&
      identical(point$MaxFiniteDifferenceCombinedRatio,
                max(coordinates$FiniteDifferenceCombinedRatio)) &&
      identical(point$MaxLogJacobianCombinedRatio,
                max(jacobian$LogCombinedRatio)) &&
      identical(point$MaxSlopeJacobianCombinedRatio,
                max(jacobian$SlopeCombinedRatio)) &&
      !isTRUE(point$SourceInferenceReady) && !isTRUE(point$BoundaryProven) &&
      !isTRUE(point$CalibrationAuthorized) &&
      !isTRUE(point$ConfirmationAuthorized),
    "The v4 completion point summary is invalid."
  )

  decision <- result$decision
  mfrmr_gsv4v_assert(
    is.data.frame(result$fit) && nrow(result$fit) == 1L &&
      isTRUE(result$fit$FitSucceeded) &&
      identical(result$fit$OptimizerConvergence, 0L) &&
      identical(result$fit$FitReadiness, "review") &&
      !isTRUE(result$fit$InferenceReady) &&
      identical(decision$Status, "boundary_completion_calibration_pass") &&
      isTRUE(decision$CompleteDenominator) &&
      isTRUE(decision$NumericalRulePass) &&
      isTRUE(decision$ConsumedAuthorizationEmbedded) &&
      isTRUE(decision$CalibrationOnly) &&
      !isTRUE(decision$ConfirmationEligible) &&
      !isTRUE(decision$V4ConfirmationAuthorized) &&
      !isTRUE(decision$GeneralNUMSCORETOLFrozen) &&
      !isTRUE(decision$InferenceAuthorized) && isTRUE(result$executed) &&
      isTRUE(result$calibration_only) &&
      !isTRUE(result$confirmation_authorized),
    "The v4 completion decision lost its calibration-only boundary."
  )

  data.frame(
    ContractVersion = mfrmr_gsv4v_contract_version,
    Status = "validated_calibration_only_numerical_pass",
    ArtifactIntegrityPass = artifact_checked,
    SourceIdentityPass = TRUE,
    AuthorizationIssueHashPass = TRUE,
    AuthorizationConsumedRowHashPass = TRUE,
    TargetPathForm = embedded_target$form,
    AbsoluteTargetRecorded = embedded_target$absolute_recorded,
    TargetResolvesToArtifact = artifact_checked,
    CompleteDenominator = TRUE,
    NumericalRulePass = TRUE,
    FitReadiness = as.character(result$fit$FitReadiness),
    CalibrationOnly = TRUE,
    ConfirmationEligible = FALSE,
    V4FreezeReviewReady = TRUE,
    V4Frozen = FALSE,
    GeneralNUMSCORETOLFrozen = FALSE,
    InferenceAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_validate_gpcm_score_v4_boundary_completion <- function(
    artifact_path,
    expected_artifact_sha256 = unname(
      mfrmr_gsv4v_expected["ArtifactSHA256"]
    )) {
  mfrmr_gsv4v_assert(length(artifact_path) == 1L && file.exists(artifact_path),
                     "The v4 completion artifact is absent.")
  result <- readRDS(artifact_path)
  mfrmr_gsv4v_validate_result(
    result, artifact_path = artifact_path,
    expected_artifact_sha256 = expected_artifact_sha256
  )
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) < 1L) {
    stop("Supply the v4 boundary-completion artifact path.", call. = FALSE)
  }
  print(mfrmr_validate_gpcm_score_v4_boundary_completion(args[[1L]]))
}
