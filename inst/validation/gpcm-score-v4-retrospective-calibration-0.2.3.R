# No-fit retrospective application of the prospective v4 classifier to the
# already opened, rejected v3 confirmation bundle. This cannot create missing
# finite differences or reconstruct the consumed authorization record.

mfrmr_gsv4r_contract_version <-
  "mfrmr_gpcm_score_v4_retrospective_calibration_v1"
mfrmr_gsv4r_v3_result_sha256 <-
  "7836d859cca48e9a3641d94edda000218bb9c9f2903d801d7b9c9f03da017f2e"
mfrmr_gsv4r_v4_rule_sha256 <-
  "c746bd02b435e851af0ff89fff6320c34e66a1aa9fe8c52d0b6447689dd5a126"

mfrmr_gsv4r_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl("gpcm-score-v4-retrospective-calibration-0\\.2\\.3\\.R$",
                     files)]
  if (length(hit) == 0L) return(NA_character_)
  dirname(normalizePath(hit[length(hit)], winslash = "/", mustWork = FALSE))
})

mfrmr_gsv4r_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsv4r_validation_dir <- function() {
  if (!is.na(mfrmr_gsv4r_source_dir) && dir.exists(mfrmr_gsv4r_source_dir)) {
    return(mfrmr_gsv4r_source_dir)
  }
  candidates <- c(file.path("inst", "validation"),
                  file.path("..", "inst", "validation"),
                  file.path("..", "..", "inst", "validation"), ".")
  candidates <- candidates[file.exists(file.path(
    candidates, "gpcm-score-v4-rule-contract-0.2.3.R"
  ))]
  mfrmr_gsv4r_assert(length(candidates) > 0L,
                     "Cannot locate v4 retrospective sources.")
  normalizePath(candidates[1], winslash = "/", mustWork = TRUE)
}

mfrmr_gsv4r_default_result <- function() {
  root <- normalizePath(file.path(mfrmr_gsv4r_validation_dir(), "..", ".."),
                        winslash = "/", mustWork = TRUE)
  file.path(root, "validation-results",
            "gpcm-score-v3-confirmation-source-bound",
            "gpcm-score-v3-confirmation.rds")
}

mfrmr_gsv4r_load <- function(result_path = mfrmr_gsv4r_default_result()) {
  mfrmr_gsv4r_assert(requireNamespace("digest", quietly = TRUE),
                     "Package `digest` is required for retrospective identity.")
  validation_dir <- mfrmr_gsv4r_validation_dir()
  rule_path <- file.path(validation_dir, "gpcm-score-v4-rule-contract-0.2.3.R")
  mfrmr_gsv4r_assert(
    file.exists(result_path) &&
      identical(digest::digest(file = result_path, algo = "sha256",
                               serialize = FALSE),
                mfrmr_gsv4r_v3_result_sha256),
    "The immutable rejected v3 result is missing or changed."
  )
  mfrmr_gsv4r_assert(
    identical(digest::digest(file = rule_path, algo = "sha256",
                             serialize = FALSE),
              mfrmr_gsv4r_v4_rule_sha256),
    "The prospective v4 rule changed."
  )
  target <- environment(mfrmr_gsv4r_load)
  sys.source(rule_path, envir = target)
  result <- readRDS(result_path)
  mfrmr_gsv4r_assert(
    identical(result$decision$Status, "rejected") &&
      isTRUE(result$decision$CompleteDenominator) &&
      nrow(result$evidence) == 96L && nrow(result$coordinates) == 560L &&
      nrow(result$point_summary) == 24L && nrow(result$jacobian) == 376L,
    "The rejected v3 result no longer has its complete denominator."
  )
  result
}

mfrmr_gsv4r_expanded_vectors <- function(result) {
  jacobian <- result$jacobian
  point_key <- unique(jacobian[c("ScenarioId", "Point")])
  rows <- lapply(seq_len(nrow(point_key)), function(index) {
    scenario <- point_key$ScenarioId[index]
    point <- point_key$Point[index]
    group <- jacobian[jacobian$ScenarioId == scenario &
                        jacobian$Point == point,
                      c("ExpandedLevel", "ExpandedLogSlope"), drop = FALSE]
    group <- group[!duplicated(group$ExpandedLevel), , drop = FALSE]
    group <- group[order(group$ExpandedLevel), , drop = FALSE]
    classification <- mfrmr_gsv4_classify_log_slopes(
      group$ExpandedLogSlope, point
    )
    original <- result$point_summary[
      result$point_summary$ScenarioId == scenario &
        result$point_summary$Point == point, , drop = FALSE
    ]
    mfrmr_gsv4r_assert(nrow(original) == 1L,
                       "V3 point summary is missing or duplicated.")
    data.frame(
      ScenarioId = scenario, Point = point,
      Levels = nrow(group), OriginalRegion = original$SlopeRegion,
      V4Region = classification$Region,
      RawMaximum = classification$RawMaximum,
      RawExcess = classification$RawExcess,
      ConstructionAllowance = classification$Allowance,
      AllowanceApplied = classification$AllowanceApplied,
      RegionChanged = original$SlopeRegion != classification$Region,
      OriginalFiniteDifferenceStatus = original$FiniteDifferenceStatus,
      V4FiniteDifferenceRequirement = if (
        classification$Region == "finite_slope_region") "required" else
          "not_applicable_extreme_slope",
      V4FiniteDifferenceAvailable =
        classification$Region != "finite_slope_region" ||
          original$FiniteDifferenceStatus == "pass",
      ResultOpenedForV4 = FALSE,
      V4ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_run_gpcm_score_v4_retrospective <- function(
    result_path = mfrmr_gsv4r_default_result()) {
  result <- mfrmr_gsv4r_load(result_path)
  points <- mfrmr_gsv4r_expanded_vectors(result)
  changed <- points[points$RegionChanged, , drop = FALSE]
  classification_pass <- nrow(points) == 24L && nrow(changed) == 1L &&
    identical(changed$ScenarioId, "NUM-GPCM-SCORE-CONF-WORK6-C") &&
    identical(changed$Point, "finite_slope_stress_forward") &&
    identical(changed$OriginalRegion, "extreme_slope_review_handoff") &&
    identical(changed$V4Region, "finite_slope_region") &&
    changed$RawExcess > 0 &&
    changed$RawExcess <= changed$ConstructionAllowance &&
    all(points$V4Region[points$Point == "retained_solution"] ==
          points$OriginalRegion[points$Point == "retained_solution"])
  missing_fd <- points$V4FiniteDifferenceRequirement == "required" &
    !points$V4FiniteDifferenceAvailable
  authorization_embedded <- "authorization" %in% names(result) &&
    is.data.frame(result$authorization) && nrow(result$authorization) == 1L
  decision <- data.frame(
    ContractVersion = mfrmr_gsv4r_contract_version,
    Status = if (classification_pass && any(missing_fd)) {
      "classification_calibrated_numerical_evidence_incomplete"
    } else "rejected",
    PointRows = nrow(points), RegionChanges = nrow(changed),
    ClassificationCalibrationPass = classification_pass,
    MissingRequiredFiniteDifferencePoints = sum(missing_fd),
    NumericalDecisionComplete = classification_pass && !any(missing_fd),
    ConsumedAuthorizationEmbedded = authorization_embedded,
    AuthorizationSchemaComplete = authorization_embedded,
    V4FreezeReady = classification_pass && !any(missing_fd) &&
      authorization_embedded,
    V3Status = "rejected_unchanged", V4ConfirmationAuthorized = FALSE,
    GeneralNUMSCORETOLFrozen = FALSE, InferenceAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  list(contract_version = mfrmr_gsv4r_contract_version,
       source_result_sha256 = mfrmr_gsv4r_v3_result_sha256,
       v4_rule_sha256 = mfrmr_gsv4r_v4_rule_sha256,
       points = points, decision = decision,
       executed_fit = FALSE, confirmation_authorized = FALSE)
}
