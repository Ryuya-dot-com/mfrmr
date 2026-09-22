# No-fit retrospective audit of the immutable, once-consumed GPCM score v4
# confirmation artifact. It preserves the sealed runner/authorization/
# validator sources and separates numerical formula checks from process and
# fit-readiness acceptance. It authorizes neither retry nor rule adjustment.

mfrmr_gsv4qr_contract_version <-
  "mfrmr_gpcm_score_v4_confirmation_retrospective_audit_v1"
mfrmr_gsv4qr_expected <- c(
  ArtifactSHA256 =
    "f6683b41e84cf705f95b2bb1a2853f7dfa8da9ba6434ff1b116f7e88128a4887",
  RunnerSHA256 =
    "53de91632f368bc404ff064b7819d820ee7f592db74b286071a70b8f88715c1a",
  AuthorizationSHA256 =
    "677a21bd6d6c8fe6a735c137e6e7acfa8f43dce343594283ca5ec6c39d6402e2",
  ValidatorSHA256 =
    "7646c8cfb042942c5bbc00454410e3f5528a370e057478e1c8e16a96acadcaf9"
)

mfrmr_gsv4qr_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "gpcm-score-v4-confirmation-retrospective-audit-0\\.2\\.3\\.R$", files
  )]
  if (length(hit) == 0L) return(NA_character_)
  dirname(normalizePath(hit[length(hit)], winslash = "/", mustWork = FALSE))
})

mfrmr_gsv4qr_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsv4qr_validation_dir <- function() {
  if (!is.na(mfrmr_gsv4qr_source_dir) && dir.exists(mfrmr_gsv4qr_source_dir)) {
    return(mfrmr_gsv4qr_source_dir)
  }
  candidates <- c(
    file.path("inst", "validation"), file.path("..", "inst", "validation"),
    file.path("..", "..", "inst", "validation"), "."
  )
  found <- candidates[file.exists(file.path(
    candidates, "gpcm-score-v4-confirmation-validator-0.2.3.R"
  ))]
  mfrmr_gsv4qr_assert(
    length(found) > 0L, "Cannot resolve v4 confirmation audit sources."
  )
  normalizePath(found[[1L]], winslash = "/", mustWork = TRUE)
}

mfrmr_gsv4qr_hash_file <- function(path) {
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gsv4qr_load_validator <- function() {
  validation_dir <- mfrmr_gsv4qr_validation_dir()
  sources <- c(
    RunnerSHA256 = "gpcm-score-v4-confirmation-runner-0.2.3.R",
    AuthorizationSHA256 =
      "gpcm-score-v4-confirmation-authorization-0.2.3.R",
    ValidatorSHA256 = "gpcm-score-v4-confirmation-validator-0.2.3.R"
  )
  actual <- vapply(sources, function(file) {
    mfrmr_gsv4qr_hash_file(file.path(validation_dir, file))
  }, character(1L))
  mfrmr_gsv4qr_assert(
    identical(unname(actual), unname(mfrmr_gsv4qr_expected[names(sources)])),
    "A sealed v4 confirmation source changed after execution."
  )
  env <- new.env(parent = globalenv())
  sys.source(file.path(
    validation_dir, "gpcm-score-v4-confirmation-validator-0.2.3.R"
  ), envir = env)
  env
}

mfrmr_gsv4qr_max_by_key <- function(values, keys, expected_keys) {
  vapply(expected_keys, function(key) {
    selected <- values[keys == key]
    if (length(selected) == 0L || all(is.na(selected))) NA_real_ else {
      max(selected)
    }
  }, numeric(1L))
}

mfrmr_gsv4qr_numerical_audit <- function(result, validator) {
  evidence <- result$evidence
  coordinates <- result$coordinates
  point <- result$point_summary
  jacobian <- result$jacobian
  expected <- validator$mfrmr_gsv4qv_expected_counts()
  expected_jacobian <- validator$mfrmr_gsv4qv_expected_jacobian()
  key3 <- c("ScenarioId", "Point", "ParameterClass")
  actual <- as.data.frame(table(
    coordinates$ScenarioId, coordinates$Point,
    coordinates$ParameterClassFrozen
  ), stringsAsFactors = FALSE)
  names(actual) <- c(key3, "ActualCount")
  counts <- merge(expected, actual, by = key3, all = TRUE)
  counts <- merge(
    counts, evidence[c(key3, "CoordinateCount")], by = key3, all = TRUE
  )
  actual_jacobian <- as.data.frame(table(
    jacobian$ScenarioId, jacobian$Point
  ), stringsAsFactors = FALSE)
  names(actual_jacobian) <- c("ScenarioId", "Point", "ActualCount")
  jacobian_counts <- merge(
    expected_jacobian, actual_jacobian,
    by = c("ScenarioId", "Point"), all = TRUE
  )
  denominator_pass <- nrow(evidence) == 96L &&
    nrow(coordinates) == 888L && nrow(point) == 24L &&
    nrow(jacobian) == 688L && nrow(counts) == 96L && !anyNA(counts) &&
    all(counts$ExpectedCount == counts$ActualCount) &&
    all(counts$ExpectedCount == counts$CoordinateCount) &&
    nrow(jacobian_counts) == 24L && !anyNA(jacobian_counts) &&
    all(jacobian_counts$ExpectedCount == jacobian_counts$ActualCount)

  evidence_key <- paste(
    evidence$ScenarioId, evidence$Point, evidence$ParameterClass, sep = "::"
  )
  coordinate_key <- paste(
    coordinates$ScenarioId, coordinates$Point,
    coordinates$ParameterClassFrozen, sep = "::"
  )
  point_key <- paste(point$ScenarioId, point$Point, sep = "::")
  coordinate_point_key <- paste(
    coordinates$ScenarioId, coordinates$Point, sep = "::"
  )
  jacobian_key <- paste(jacobian$ScenarioId, jacobian$Point, sep = "::")
  evidence_point_key <- paste(
    evidence$ScenarioId, evidence$Point, sep = "::"
  )
  coordinate_analytic <- mfrmr_gsv4qr_max_by_key(
    coordinates$AnalyticScoreCombinedRatio, coordinate_key, evidence_key
  )
  coordinate_fd <- mfrmr_gsv4qr_max_by_key(
    coordinates$FiniteDifferenceCombinedRatio, coordinate_key, evidence_key
  )
  point_analytic <- mfrmr_gsv4qr_max_by_key(
    coordinates$AnalyticScoreCombinedRatio, coordinate_point_key, point_key
  )
  point_fd <- mfrmr_gsv4qr_max_by_key(
    coordinates$FiniteDifferenceCombinedRatio, coordinate_point_key, point_key
  )
  point_log <- mfrmr_gsv4qr_max_by_key(
    jacobian$LogCombinedRatio, jacobian_key, point_key
  )
  point_slope <- mfrmr_gsv4qr_max_by_key(
    jacobian$SlopeCombinedRatio, jacobian_key, point_key
  )
  evidence_log <- point_log[match(evidence_point_key, point_key)]
  evidence_slope <- point_slope[match(evidence_point_key, point_key)]
  point_region <- vapply(point_key, function(key) {
    region <- unique(evidence$SlopeRegion[evidence_point_key == key])
    if (length(region) == 1L) region else "inconsistent"
  }, character(1L))
  finite_evidence <- evidence$SlopeRegion == "finite_slope_region"
  extreme_evidence <-
    evidence$SlopeRegion == "extreme_slope_review_handoff"
  finite_coordinate <- coordinates$SlopeRegion == "finite_slope_region"
  extreme_coordinate <-
    coordinates$SlopeRegion == "extreme_slope_review_handoff"
  constructed <- coordinates$Point != "retained_solution"

  aggregation_pass <- isTRUE(all.equal(
    unname(evidence$MaxAnalyticScoreCombinedRatio),
    unname(coordinate_analytic), tolerance = 0
  )) && isTRUE(all.equal(
    unname(evidence$FiniteDifferenceCombinedRatio),
    unname(coordinate_fd), tolerance = 0
  )) && isTRUE(all.equal(
    unname(evidence$LogJacobianCombinedRatio),
    unname(evidence_log), tolerance = 0
  )) && isTRUE(all.equal(
    unname(evidence$SlopeJacobianCombinedRatio),
    unname(evidence_slope), tolerance = 0
  )) && isTRUE(all.equal(
    unname(point$MaxAnalyticScoreCombinedRatio),
    unname(point_analytic), tolerance = 0
  )) && isTRUE(all.equal(
    unname(point$MaxFiniteDifferenceCombinedRatio),
    unname(point_fd), tolerance = 0
  )) && isTRUE(all.equal(
    unname(point$MaxLogJacobianCombinedRatio),
    unname(point_log), tolerance = 0
  )) && isTRUE(all.equal(
    unname(point$MaxSlopeJacobianCombinedRatio),
    unname(point_slope), tolerance = 0
  )) && identical(unname(point$SlopeRegion), unname(point_region))

  rule_pass <- all(finite_evidence | extreme_evidence) &&
    all(finite_evidence[evidence$Point != "retained_solution"]) &&
    all(is.finite(coordinates$AnalyticScoreCombinedRatio)) &&
    all(coordinates$AnalyticScoreCombinedRatio <= 1) &&
    all(is.finite(coordinates$FiniteDifferenceCombinedRatio[
      finite_coordinate
    ])) && all(coordinates$FiniteDifferenceCombinedRatio[
      finite_coordinate
    ] <= 1) && all(is.na(coordinates$FiniteDifferenceCombinedRatio[
      extreme_coordinate
    ])) && all(jacobian$LogCombinedRatio <= 1) &&
    all(jacobian$SlopeCombinedRatio <= 1) &&
    all(coordinates$StructuralOraclePass) &&
    all(evidence$StructuralOraclePass) && all(evidence$AnalyticScorePass) &&
    all(evidence$EvaluationComplete) &&
    all(evidence$FiniteDifferenceStatus[finite_evidence] == "pass") &&
    all(evidence$FiniteDifferenceStatus[extreme_evidence] ==
          "not_applicable_extreme_slope") &&
    all(coordinates$V4ConstructionRawExcess[constructed] <=
          coordinates$V4ConstructionAllowance[constructed])

  list(
    denominator_pass = denominator_pass,
    aggregation_pass = aggregation_pass,
    rule_pass = rule_pass,
    numerical_pass = denominator_pass && aggregation_pass && rule_pass,
    point_region_named_identical = identical(point$SlopeRegion, point_region),
    point_region_value_identical =
      identical(unname(point$SlopeRegion), unname(point_region)),
    max_analytic = max(coordinates$AnalyticScoreCombinedRatio),
    max_finite_difference =
      max(coordinates$FiniteDifferenceCombinedRatio, na.rm = TRUE),
    max_log_jacobian = max(jacobian$LogCombinedRatio),
    max_slope_jacobian = max(jacobian$SlopeCombinedRatio),
    max_constructed_raw_excess =
      max(coordinates$V4ConstructionRawExcess[constructed]),
    max_constructed_allowance =
      max(coordinates$V4ConstructionAllowance[constructed])
  )
}

mfrmr_gsv4qr_audit_result <- function(result, artifact_path, validator) {
  validator$mfrmr_gsv4qv_validate_sources()
  validator$mfrmr_gsv4qv_validate_identity(result$identity, result$manifest)
  validator$mfrmr_gsv4qv_validate_authorization(
    result$authorization, result$identity, result$manifest, artifact_path
  )
  numerical <- mfrmr_gsv4qr_numerical_audit(result, validator)
  sealed_validation <- tryCatch(
    validator$mfrmr_gsv4qv_validate_result(result, artifact_path),
    error = function(error) error
  )
  sealed_accepted <- !inherits(sealed_validation, "error")
  sealed_reason <- if (sealed_accepted) NA_character_ else {
    conditionMessage(sealed_validation)
  }
  fit_gate <- all(result$fits$FitSucceeded) &&
    all(result$fits$OptimizerConvergence == 0L) &&
    all(result$fits$FitReadiness == "review") &&
    all(!result$fits$InferenceReady)
  runner_pass <- identical(
    result$decision$Status, "v4_candidate_score_confirmation_pass"
  ) && isTRUE(result$decision$BoundedV4RuleConfirmed)
  validator_attribute_defect <- !numerical$point_region_named_identical &&
    numerical$point_region_value_identical && numerical$numerical_pass &&
    identical(
      sealed_reason,
      "The v4 confirmation numerical rules or aggregation failed."
    )
  accepted <- sealed_accepted && fit_gate && numerical$numerical_pass
  data.frame(
    ContractVersion = mfrmr_gsv4qr_contract_version,
    Status = if (accepted) "accepted" else {
      "rejected_runner_false_positive_and_blocked_fits"
    },
    ArtifactSHA256 = mfrmr_gsv4qr_hash_file(artifact_path),
    CompleteDenominator = numerical$denominator_pass,
    NumericalAggregationPass = numerical$aggregation_pass,
    NumericalImplementationChecksPass = numerical$numerical_pass,
    MaxAnalyticScoreCombinedRatio = numerical$max_analytic,
    MaxFiniteDifferenceCombinedRatio = numerical$max_finite_difference,
    MaxLogJacobianCombinedRatio = numerical$max_log_jacobian,
    MaxSlopeJacobianCombinedRatio = numerical$max_slope_jacobian,
    MaxConstructedRawExcess = numerical$max_constructed_raw_excess,
    MaxConstructedAllowance = numerical$max_constructed_allowance,
    SealedValidatorAccepted = sealed_accepted,
    SealedValidatorReason = sealed_reason,
    SealedValidatorNameAttributeDefect = validator_attribute_defect,
    FitGatePass = fit_gate,
    BlockedFitCount = sum(result$fits$FitReadiness == "blocked"),
    ReviewFitCount = sum(result$fits$FitReadiness == "review"),
    RunnerReportedPass = runner_pass,
    RunnerDecisionFalsePositive = runner_pass && !accepted,
    ConfirmationAccepted = accepted,
    RetryAuthorized = FALSE,
    RuleAdjustmentAuthorized = FALSE,
    GeneralNUMSCORETOLFrozen = FALSE,
    BoundaryProven = FALSE,
    InferenceAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_audit_gpcm_score_v4_confirmation <- function(artifact_path) {
  mfrmr_gsv4qr_assert(
    length(artifact_path) == 1L && file.exists(artifact_path),
    "The v4 confirmation artifact is absent."
  )
  absolute <- normalizePath(artifact_path, winslash = "/", mustWork = TRUE)
  mfrmr_gsv4qr_assert(
    identical(
      mfrmr_gsv4qr_hash_file(absolute),
      unname(mfrmr_gsv4qr_expected["ArtifactSHA256"])
    ),
    "The immutable v4 confirmation artifact SHA-256 is wrong."
  )
  validator <- mfrmr_gsv4qr_load_validator()
  mfrmr_gsv4qr_audit_result(readRDS(absolute), absolute, validator)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) < 1L) {
    stop("Supply the v4 confirmation artifact path.", call. = FALSE)
  }
  print(mfrmr_audit_gpcm_score_v4_confirmation(args[[1L]]))
}
