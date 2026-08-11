# Independent, no-fit validator for the GPCM score v4 disjoint-confirmation
# result. This file does not source or call the confirmation runner. It is
# sealed before execution; the separate authorization binds this source hash.

mfrmr_gsv4qv_contract_version <-
  "mfrmr_gpcm_score_v4_confirmation_validator_v1"
mfrmr_gsv4qv_expected <- c(
  RunnerSHA256 =
    "53de91632f368bc404ff064b7819d820ee7f592db74b286071a70b8f88715c1a",
  DesignSHA256 =
    "31b495b46aef7706835030efe3b41d2888242a4a8f7724ead435c2c7648fb11a",
  FreezeSHA256 =
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
    "04efdbcb857f6bd99ee4295e560594e6e1fd005a7623864e40bd857b34cf5b33"
)
mfrmr_gsv4qv_scenarios <- c(
  "NUM-GPCM-SCORE-V4-CONF-BRAID5-C",
  "NUM-GPCM-SCORE-V4-CONF-BRAID5-R",
  "NUM-GPCM-SCORE-V4-CONF-WEAVE6-C",
  "NUM-GPCM-SCORE-V4-CONF-WEAVE6-R",
  "NUM-GPCM-SCORE-V4-CONF-FAN7-C",
  "NUM-GPCM-SCORE-V4-CONF-FAN7-R"
)
mfrmr_gsv4qv_points <- c(
  "retained_solution", "coupled_free_probe",
  "finite_slope_stress_forward", "finite_slope_stress_reverse"
)
mfrmr_gsv4qv_classes <-
  c("owner_additive", "other_additive", "steps", "log_slopes")

mfrmr_gsv4qv_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  args <- sub("^--file=", "", grep(
    "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
  ))
  hit <- c(files[grepl(
    "gpcm-score-v4-confirmation-validator-0\\.2\\.3\\.R$", files
  )], args)
  candidates <- unique(c(
    dirname(hit), getwd(), file.path(getwd(), "inst", "validation")
  ))
  found <- candidates[file.exists(file.path(
    candidates, "gpcm-score-v4-confirmation-runner-0.2.3.R"
  ))]
  if (length(found) == 0L) NA_character_ else {
    normalizePath(found[[1L]], winslash = "/", mustWork = TRUE)
  }
})

mfrmr_gsv4qv_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsv4qv_validation_dir <- function() {
  if (!is.na(mfrmr_gsv4qv_source_dir) && dir.exists(mfrmr_gsv4qv_source_dir)) {
    return(mfrmr_gsv4qv_source_dir)
  }
  candidates <- c(
    file.path("inst", "validation"), file.path("..", "inst", "validation"),
    file.path("..", "..", "inst", "validation"), "."
  )
  found <- candidates[file.exists(file.path(
    candidates, "gpcm-score-v4-confirmation-runner-0.2.3.R"
  ))]
  mfrmr_gsv4qv_assert(
    length(found) > 0L, "Cannot resolve v4 confirmation validation sources."
  )
  normalizePath(found[[1L]], winslash = "/", mustWork = TRUE)
}

mfrmr_gsv4qv_hash_file <- function(path) {
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gsv4qv_hash_object <- function(object) {
  digest::digest(object, algo = "sha256", serialize = TRUE)
}

mfrmr_gsv4qv_is_absolute <- function(path) {
  length(path) == 1L && !is.na(path) && nzchar(path) &&
    grepl("^(/|[A-Za-z]:[/\\\\]|\\\\\\\\)", path)
}

mfrmr_gsv4qv_expected_counts <- function() {
  class_counts <- rbind(
    c(6L, 3L, 21L, 6L), c(3L, 6L, 12L, 3L),
    c(3L, 5L, 16L, 3L), c(5L, 3L, 24L, 5L),
    c(7L, 4L, 40L, 7L), c(4L, 7L, 25L, 4L)
  )
  rows <- lapply(seq_along(mfrmr_gsv4qv_scenarios), function(index) {
    grid <- expand.grid(
      Point = mfrmr_gsv4qv_points,
      ParameterClass = mfrmr_gsv4qv_classes,
      KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
    )
    grid$ScenarioId <- mfrmr_gsv4qv_scenarios[[index]]
    grid$ExpectedCount <- as.integer(
      class_counts[index, match(grid$ParameterClass, mfrmr_gsv4qv_classes)]
    )
    grid[c("ScenarioId", "Point", "ParameterClass", "ExpectedCount")]
  })
  do.call(rbind, rows)
}

mfrmr_gsv4qv_expected_jacobian <- function() {
  per_point <- c(42L, 12L, 12L, 30L, 56L, 20L)
  grid <- expand.grid(
    ScenarioId = mfrmr_gsv4qv_scenarios, Point = mfrmr_gsv4qv_points,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  grid$ExpectedCount <- per_point[match(
    grid$ScenarioId, mfrmr_gsv4qv_scenarios
  )]
  grid
}

mfrmr_gsv4qv_validate_sources <- function() {
  validation_dir <- mfrmr_gsv4qv_validation_dir()
  sources <- c(
    RunnerSHA256 = "gpcm-score-v4-confirmation-runner-0.2.3.R",
    DesignSHA256 = "gpcm-score-v4-confirmation-design-0.2.3.R",
    FreezeSHA256 = "gpcm-score-v4-freeze-contract-0.2.3.R",
    V4RuleSHA256 = "gpcm-score-v4-rule-contract-0.2.3.R",
    V3ReplayRunnerSHA256 = "gpcm-score-v3-replay-runner-0.2.3.R"
  )
  actual <- vapply(sources, function(file) {
    mfrmr_gsv4qv_hash_file(file.path(validation_dir, file))
  }, character(1L))
  mfrmr_gsv4qv_assert(
    identical(unname(actual), unname(mfrmr_gsv4qv_expected[names(sources)])),
    "A v4 confirmation source identity changed before validation."
  )
  invisible(TRUE)
}

mfrmr_gsv4qv_validate_identity <- function(identity, manifest) {
  identity_canonical <- identity[, setdiff(
    names(identity), "IdentitySHA256"
  ), drop = FALSE]
  mfrmr_gsv4qv_assert(
    is.data.frame(identity) && nrow(identity) == 1L &&
      identical(identity$IdentitySHA256,
                unname(mfrmr_gsv4qv_expected["IdentitySHA256"])) &&
      identical(mfrmr_gsv4qv_hash_object(identity_canonical),
                identity$IdentitySHA256) &&
      identical(identity$V4RunnerSHA256,
                unname(mfrmr_gsv4qv_expected["RunnerSHA256"])) &&
      identical(identity$V4DesignSHA256,
                unname(mfrmr_gsv4qv_expected["DesignSHA256"])) &&
      identical(identity$V4FreezeSHA256,
                unname(mfrmr_gsv4qv_expected["FreezeSHA256"])) &&
      identical(identity$V4RuleSHA256,
                unname(mfrmr_gsv4qv_expected["V4RuleSHA256"])) &&
      identical(identity$V3ReplayRunnerSHA256,
                unname(mfrmr_gsv4qv_expected["V3ReplayRunnerSHA256"])) &&
      identical(identity$PackagePayloadSHA256,
                unname(mfrmr_gsv4qv_expected["PackagePayloadSHA256"])),
    "The v4 confirmation runner identity is invalid."
  )
  manifest_canonical <- manifest
  manifest_canonical$ManifestSHA256 <- NULL
  mfrmr_gsv4qv_assert(
    is.data.frame(manifest) && nrow(manifest) == 6L &&
      identical(manifest$ScenarioId, mfrmr_gsv4qv_scenarios) &&
      length(unique(manifest$ManifestSHA256)) == 1L &&
      identical(manifest$ManifestSHA256[[1L]],
                unname(mfrmr_gsv4qv_expected["ManifestSHA256"])) &&
      identical(mfrmr_gsv4qv_hash_object(manifest_canonical),
                manifest$ManifestSHA256[[1L]]) &&
      all(manifest$RunnerIdentitySHA256 == identity$IdentitySHA256) &&
      all(!manifest$ResultOpened) &&
      all(!manifest$ConfirmationExecutionAuthorized),
    "The v4 confirmation manifest is invalid."
  )
  invisible(TRUE)
}

mfrmr_gsv4qv_validate_authorization <- function(authorization, identity,
                                                 manifest, artifact_path) {
  required <- c(
    "ContractVersion", "Status", "RunnerIdentitySHA256", "ManifestSHA256",
    "AuthorizationSourceSHA256", "AuthorizationSHA256", "OutputPath",
    "ProcessId", "IssuedAtUTC", "ExecutionAuthorized", "IssuedNotExecuted",
    "ConsumedAtUTC", "ConsumedRowSHA256", "ValidatorSHA256",
    "ExactValidator", "InputPathAbsolute", "FitOpened", "ResultOpened",
    "GeneralNUMSCORETOLFrozen", "BoundaryProven", "InferenceAuthorized"
  )
  mfrmr_gsv4qv_assert(
    is.data.frame(authorization) && nrow(authorization) == 1L &&
      all(required %in% names(authorization)),
    "The embedded v4 confirmation authorization is incomplete."
  )
  validation_dir <- mfrmr_gsv4qv_validation_dir()
  actual_auth_hash <- mfrmr_gsv4qv_hash_file(file.path(
    validation_dir, "gpcm-score-v4-confirmation-authorization-0.2.3.R"
  ))
  actual_validator_hash <- mfrmr_gsv4qv_hash_file(file.path(
    validation_dir, "gpcm-score-v4-confirmation-validator-0.2.3.R"
  ))
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
    "ExactRunner", "ExactDesign", "ExactFreeze", "ExactRule",
    "ExactReplayRunner", "ExactPayload", "ExactIdentity", "ExactManifest",
    "ExactValidator", "CompleteDesign", "DisjointConfirmation",
    "DevelopmentSource", "FreshProcessAttested", "ExplicitRequest",
    "InputPathAbsolute", "OutputParentExists", "OutputTargetAbsent"
  )
  target <- normalizePath(artifact_path, winslash = "/", mustWork = TRUE)
  mfrmr_gsv4qv_assert(
    identical(authorization$Status, "consumed_result_embedded") &&
      identical(authorization$RunnerIdentitySHA256, identity$IdentitySHA256) &&
      identical(authorization$ManifestSHA256,
                manifest$ManifestSHA256[[1L]]) &&
      identical(authorization$AuthorizationSourceSHA256, actual_auth_hash) &&
      identical(authorization$ValidatorSHA256, actual_validator_hash) &&
      identical(authorization$ConsumedRowSHA256,
                mfrmr_gsv4qv_hash_object(consumed_canonical)) &&
      identical(authorization$AuthorizationSHA256,
                mfrmr_gsv4qv_hash_object(issued_canonical)) &&
      all(gate_names %in% names(authorization)) &&
      all(unlist(authorization[gate_names], use.names = FALSE)) &&
      mfrmr_gsv4qv_is_absolute(authorization$OutputPath) &&
      identical(normalizePath(
        authorization$OutputPath, winslash = "/", mustWork = TRUE
      ), target) && isTRUE(authorization$ExecutionAuthorized) &&
      !isTRUE(authorization$IssuedNotExecuted) &&
      !is.na(authorization$ConsumedAtUTC) && !isTRUE(authorization$FitOpened) &&
      !isTRUE(authorization$ResultOpened) &&
      !isTRUE(authorization$GeneralNUMSCORETOLFrozen) &&
      !isTRUE(authorization$BoundaryProven) &&
      !isTRUE(authorization$InferenceAuthorized),
    "The embedded v4 confirmation authorization cannot be verified."
  )
  invisible(TRUE)
}

mfrmr_gsv4qv_validate_numerics <- function(result) {
  coordinates <- result$coordinates
  evidence <- result$evidence
  point <- result$point_summary
  jacobian <- result$jacobian
  key3 <- c("ScenarioId", "Point", "ParameterClass")
  expected <- mfrmr_gsv4qv_expected_counts()
  actual <- as.data.frame(table(
    coordinates$ScenarioId, coordinates$Point,
    coordinates$ParameterClassFrozen
  ), stringsAsFactors = FALSE)
  names(actual) <- c(key3, "ActualCount")
  counts <- merge(expected, actual, by = key3, all = TRUE)
  evidence_counts <- evidence[c(key3, "CoordinateCount")]
  counts <- merge(counts, evidence_counts, by = key3, all = TRUE)
  expected_jacobian <- mfrmr_gsv4qv_expected_jacobian()
  actual_jacobian <- as.data.frame(table(
    jacobian$ScenarioId, jacobian$Point
  ), stringsAsFactors = FALSE)
  names(actual_jacobian) <- c("ScenarioId", "Point", "ActualCount")
  jacobian_counts <- merge(
    expected_jacobian, actual_jacobian,
    by = c("ScenarioId", "Point"), all = TRUE
  )
  point_keys <- paste(point$ScenarioId, point$Point, sep = "::")
  expected_point_keys <- paste(
    expected_jacobian$ScenarioId, expected_jacobian$Point, sep = "::"
  )
  required_coordinate <- c(
    "AnalyticScoreCombinedRatio", "FiniteDifferenceCombinedRatio",
    "SlopeRegion", "V4ConstructionRawExcess", "V4ConstructionAllowance",
    "DesignConfirmationEligible"
  )
  mfrmr_gsv4qv_assert(
    nrow(evidence) == 96L && nrow(coordinates) == 888L &&
      nrow(point) == 24L && nrow(jacobian) == 688L &&
      nrow(counts) == 96L && !anyNA(counts) &&
      all(counts$ExpectedCount == counts$ActualCount) &&
      all(counts$ExpectedCount == counts$CoordinateCount) &&
      nrow(jacobian_counts) == 24L && !anyNA(jacobian_counts) &&
      all(jacobian_counts$ExpectedCount == jacobian_counts$ActualCount) &&
      !anyDuplicated(point_keys) &&
      identical(sort(point_keys), sort(expected_point_keys)) &&
      all(required_coordinate %in% names(coordinates)),
    "The v4 confirmation denominator is incomplete or misallocated."
  )
  finite <- evidence$SlopeRegion == "finite_slope_region"
  extreme <- evidence$SlopeRegion == "extreme_slope_review_handoff"
  constructed <- evidence$Point != "retained_solution"
  coordinate_key <- paste(
    coordinates$ScenarioId, coordinates$Point,
    coordinates$ParameterClassFrozen, sep = "::"
  )
  evidence_key <- paste(
    evidence$ScenarioId, evidence$Point, evidence$ParameterClass, sep = "::"
  )
  coordinate_analytic <- vapply(evidence_key, function(key) {
    max(coordinates$AnalyticScoreCombinedRatio[coordinate_key == key])
  }, numeric(1L))
  coordinate_fd <- vapply(evidence_key, function(key) {
    value <- coordinates$FiniteDifferenceCombinedRatio[coordinate_key == key]
    if (all(is.na(value))) NA_real_ else max(value)
  }, numeric(1L))
  point_key <- paste(point$ScenarioId, point$Point, sep = "::")
  jacobian_key <- paste(jacobian$ScenarioId, jacobian$Point, sep = "::")
  jacobian_log <- vapply(point_key, function(key) {
    max(jacobian$LogCombinedRatio[jacobian_key == key])
  }, numeric(1L))
  jacobian_slope <- vapply(point_key, function(key) {
    max(jacobian$SlopeCombinedRatio[jacobian_key == key])
  }, numeric(1L))
  evidence_point_key <- paste(evidence$ScenarioId, evidence$Point, sep = "::")
  evidence_log <- jacobian_log[match(evidence_point_key, point_key)]
  evidence_slope <- jacobian_slope[match(evidence_point_key, point_key)]
  coordinate_point_key <- paste(
    coordinates$ScenarioId, coordinates$Point, sep = "::"
  )
  point_analytic <- vapply(point_key, function(key) {
    max(coordinates$AnalyticScoreCombinedRatio[coordinate_point_key == key])
  }, numeric(1L))
  point_fd <- vapply(point_key, function(key) {
    value <- coordinates$FiniteDifferenceCombinedRatio[
      coordinate_point_key == key
    ]
    if (all(is.na(value))) NA_real_ else max(value)
  }, numeric(1L))
  point_region <- vapply(point_key, function(key) {
    region <- unique(evidence$SlopeRegion[evidence_point_key == key])
    if (length(region) == 1L) region else "inconsistent"
  }, character(1L))
  mfrmr_gsv4qv_assert(
    all(finite | extreme) && all(finite[constructed]) &&
      all(coordinates$AnalyticScoreCombinedRatio <= 1) &&
      all(is.finite(coordinates$AnalyticScoreCombinedRatio)) &&
      all(coordinates$FiniteDifferenceCombinedRatio[
        coordinates$SlopeRegion == "finite_slope_region"
      ] <= 1) && all(is.na(coordinates$FiniteDifferenceCombinedRatio[
        coordinates$SlopeRegion == "extreme_slope_review_handoff"
      ])) && all(coordinates$StructuralOraclePass) &&
      all(coordinates$DesignConfirmationEligible) &&
      all(jacobian$LogCombinedRatio <= 1) &&
      all(jacobian$SlopeCombinedRatio <= 1) &&
      isTRUE(all.equal(
        unname(evidence$MaxAnalyticScoreCombinedRatio),
        unname(coordinate_analytic), tolerance = 0
      )) && isTRUE(all.equal(
        unname(evidence$FiniteDifferenceCombinedRatio),
        unname(coordinate_fd), tolerance = 0
      )) && all(evidence$StructuralOraclePass) &&
      all(evidence$AnalyticScorePass) && all(evidence$EvaluationComplete) &&
      all(evidence$FiniteDifferenceStatus[finite] == "pass") &&
      all(evidence$FiniteDifferenceStatus[extreme] ==
            "not_applicable_extreme_slope") &&
      isTRUE(all.equal(
        unname(evidence$LogJacobianCombinedRatio),
        unname(evidence_log), tolerance = 0
      )) && isTRUE(all.equal(
        unname(evidence$SlopeJacobianCombinedRatio),
        unname(evidence_slope), tolerance = 0
      )) && all(!evidence$SourceInferenceReady) &&
      all(!evidence$CalibrationDataReused) &&
      all(evidence$DesignConfirmationEligible) &&
      all(!evidence$ConfirmationAuthorized) &&
      isTRUE(all.equal(
        unname(point$MaxLogJacobianCombinedRatio),
        unname(jacobian_log), tolerance = 0
      )) && isTRUE(all.equal(
        unname(point$MaxSlopeJacobianCombinedRatio),
        unname(jacobian_slope), tolerance = 0
      )) && isTRUE(all.equal(
        unname(point$MaxAnalyticScoreCombinedRatio),
        unname(point_analytic), tolerance = 0
      )) && isTRUE(all.equal(
        unname(point$MaxFiniteDifferenceCombinedRatio),
        unname(point_fd), tolerance = 0
      )) && identical(point$SlopeRegion, point_region) &&
      all(point$FiniteDifferenceStatus[
        point_region == "finite_slope_region"
      ] == "pass") && all(point$FiniteDifferenceStatus[
        point_region == "extreme_slope_review_handoff"
      ] == "not_applicable_extreme_slope") &&
      all(point$EntrywiseJacobianRows ==
        expected_jacobian$ExpectedCount[match(
          point_key, expected_point_keys
        )]) && all(!point$SourceInferenceReady) &&
      all(!point$BoundaryProven) && all(!point$CalibrationAuthorized) &&
      all(!point$ConfirmationAuthorized),
    "The v4 confirmation numerical rules or aggregation failed."
  )
  invisible(TRUE)
}

mfrmr_gsv4qv_validate_result <- function(result, artifact_path) {
  mfrmr_gsv4qv_assert(
    is.list(result), "The v4 confirmation result is not a list."
  )
  required <- c(
    "identity", "manifest", "authorization", "fits", "coordinates",
    "evidence", "point_summary", "jacobian", "decision", "executed",
    "calibration_data_reused", "completion_fixture_reused",
    "general_num_score_tol_frozen", "boundary_proven",
    "inference_authorized"
  )
  mfrmr_gsv4qv_assert(
    all(required %in% names(result)),
    "The v4 confirmation result schema is incomplete."
  )
  mfrmr_gsv4qv_assert(
    length(artifact_path) == 1L && file.exists(artifact_path) &&
      mfrmr_gsv4qv_is_absolute(artifact_path),
    "An existing absolute v4 confirmation artifact path is required."
  )
  mfrmr_gsv4qv_validate_sources()
  mfrmr_gsv4qv_validate_identity(result$identity, result$manifest)
  mfrmr_gsv4qv_validate_authorization(
    result$authorization, result$identity, result$manifest, artifact_path
  )
  mfrmr_gsv4qv_validate_numerics(result)
  decision <- result$decision
  mfrmr_gsv4qv_assert(
    is.data.frame(result$fits) && nrow(result$fits) == 6L &&
      identical(result$fits$ScenarioId, result$manifest$ScenarioId) &&
      identical(result$fits$FixtureSHA256, result$manifest$FixtureSHA256) &&
      all(result$fits$FitSucceeded) &&
      all(result$fits$OptimizerConvergence == 0L) &&
      all(result$fits$FitReadiness == "review") &&
      all(!result$fits$InferenceReady) &&
      identical(decision$Status, "v4_candidate_score_confirmation_pass") &&
      isTRUE(decision$CompleteDenominator) &&
      isTRUE(decision$BoundedV4RuleConfirmed) &&
      isTRUE(decision$ConsumedAuthorizationEmbedded) &&
      !isTRUE(decision$CalibrationDataReused) &&
      !isTRUE(decision$CompletionFixtureReused) &&
      !isTRUE(decision$GeneralNUMSCORETOLFrozen) &&
      !isTRUE(decision$BoundaryProven) &&
      !isTRUE(decision$InferenceAuthorized) && isTRUE(result$executed) &&
      !isTRUE(result$calibration_data_reused) &&
      !isTRUE(result$completion_fixture_reused) &&
      !isTRUE(result$general_num_score_tol_frozen) &&
      !isTRUE(result$boundary_proven) &&
      !isTRUE(result$inference_authorized),
    "The v4 confirmation decision or non-promotion boundary is invalid."
  )
  data.frame(
    ContractVersion = mfrmr_gsv4qv_contract_version,
    Status = "validated_bounded_v4_confirmation_pass",
    ArtifactSHA256 = mfrmr_gsv4qv_hash_file(artifact_path),
    SourceIdentityPass = TRUE, AuthorizationIssueHashPass = TRUE,
    AuthorizationConsumedRowHashPass = TRUE, AbsoluteTargetRecorded = TRUE,
    TargetResolvesToArtifact = TRUE, CompleteDenominator = TRUE,
    NumericalRulePass = TRUE, BoundedV4RuleConfirmed = TRUE,
    GeneralNUMSCORETOLFrozen = FALSE, BoundaryProven = FALSE,
    InferenceAuthorized = FALSE, stringsAsFactors = FALSE
  )
}

mfrmr_validate_gpcm_score_v4_confirmation <- function(artifact_path) {
  mfrmr_gsv4qv_assert(
    length(artifact_path) == 1L && file.exists(artifact_path),
    "The v4 confirmation artifact is absent."
  )
  absolute <- normalizePath(artifact_path, winslash = "/", mustWork = TRUE)
  mfrmr_gsv4qv_validate_result(readRDS(absolute), absolute)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) < 1L) {
    stop("Supply the v4 confirmation artifact path.", call. = FALSE)
  }
  print(mfrmr_validate_gpcm_score_v4_confirmation(args[[1L]]))
}
