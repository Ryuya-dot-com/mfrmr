# Source-bound freeze seal for the bounded GPCM score-rule v3 calibration.
#
# This validator performs no fit and opens no confirmation fixture. It freezes
# the calibrated rule only for a later disjoint confirmation; it does not
# freeze a general NUM-SCORE-TOL or authorize inference or confirmation.

mfrmr_gsv3f_contract_version <- "mfrmr_gpcm_score_v3_freeze_v1"
mfrmr_gsv3f_expected_payload <-
  "ef9fe233ceaa43b9a85ee58230b80bc425dd9be38ed21867c5deeb6beea7565a"
mfrmr_gsv3f_expected_identity <-
  "5651592f12e2ba5f4c4d394d49516de1d1720e0a1c300feb1af7be4dc753f3a7"
mfrmr_gsv3f_expected_manifest <-
  "520c6969633d7e41369bbacbaf1d5e66cf20c684c9d2ddbe9b5f82ffbc7a829d"

mfrmr_gsv3f_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl("gpcm-score-v3-freeze-contract-0\\.2\\.3\\.R$", files)]
  if (length(hit) == 0L) return(NA_character_)
  dirname(normalizePath(hit[length(hit)], winslash = "/", mustWork = FALSE))
})

mfrmr_gsv3f_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsv3f_validation_dir <- function() {
  if (!is.na(mfrmr_gsv3f_source_dir) && dir.exists(mfrmr_gsv3f_source_dir)) {
    return(mfrmr_gsv3f_source_dir)
  }
  candidates <- c(
    file.path("inst", "validation"),
    file.path("..", "inst", "validation"),
    file.path("..", "..", "inst", "validation"),
    file.path("..", "..", "..", "inst", "validation"),
    "."
  )
  candidates <- candidates[file.exists(file.path(
    candidates, "gpcm-score-v3-rule-contract-0.2.3.R"
  ))]
  mfrmr_gsv3f_assert(length(candidates) > 0L,
                     "Cannot locate the v3 freeze source directory.")
  normalizePath(candidates[1], winslash = "/", mustWork = TRUE)
}

mfrmr_gsv3f_hash_file <- function(path) {
  mfrmr_gsv3f_assert(requireNamespace("digest", quietly = TRUE),
                     "Package `digest` is required for the v3 freeze seal.")
  mfrmr_gsv3f_assert(file.exists(path), paste0("Missing sealed file: ", path))
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gsv3f_hash_object <- function(object) {
  mfrmr_gsv3f_assert(requireNamespace("digest", quietly = TRUE),
                     "Package `digest` is required for the v3 freeze seal.")
  digest::digest(object, algo = "sha256", serialize = TRUE)
}

mfrmr_gsv3f_source_registry <- function() {
  data.frame(
    File = c(
      "numerical-stationarity-pilot-0.2.3.R",
      "gpcm-score-calibration-design-0.2.3.R",
      "gpcm-score-calibration-design-contract-0.2.3.md",
      "gpcm-nonunit-score-oracle-0.2.3.R",
      "gpcm-score-calibration-runner-0.2.3.R",
      "gpcm-extreme-score-attribution-0.2.3.R",
      "gpcm-score-v3-rule-contract-0.2.3.R",
      "gpcm-score-v3-rule-contract-0.2.3.md",
      "gpcm-score-v3-replay-runner-0.2.3.R"
    ),
    SHA256 = c(
      "68df33bc1c114309f875a0cf8056ac720254740633fe55ca909535d032663344",
      "4dbb7ff17f55edab5ab6540e03f36ff4a32e2f0b69f3b2c896327e7be7adfb8c",
      "45d1b6f04146d8b8d129b4a042dd80827442c3b660ce8aea7a6bfe9188768096",
      "878e8bff3cca5fd8f2fbc04ae4a516e21f741a3b14223cd6c455a235aea008f8",
      "17210072493ec52ae0097fd5104ffce5a4a8724c4bc8e516c90dc98d78644b14",
      "652cd36190ef2dc3c22a4ee9f1e2861af44ade1ca8a0a0ea5c3060359149398d",
      "caa58301fcb676d22ab60263c23b641dfd6b6559bc5f72fa52391db0ebe61e60",
      "4fdb7ff2d625db100fe752c89051d4b6eae99ae7e2fb7177f9346af4ef5227f2",
      "9a6a8cc73ba1c72fb532b9254389973bfec29cb65da99642db6db9081ae0f0f9"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv3f_artifact_registry <- function() {
  data.frame(
    Artifact = c("V2", "Attribution", "V3"),
    RelativePath = c(
      file.path("gpcm-score-calibration-v2-source-bound-final",
                "gpcm-score-calibration-v2.rds"),
      file.path("gpcm-score-calibration-v2-source-bound-final",
                "extreme-score-attribution.rds"),
      file.path("gpcm-score-calibration-v3-source-bound-final",
                "gpcm-score-calibration-v3.rds")
    ),
    SHA256 = c(
      "c3bc7cd84ecf930a1b52fdfbd1c9f965aceb9072c7ee675dc4e0e42363f0f5dc",
      "3a98f86bafa44c49d5826e1826162c71314d486545b38481fbe734b746721c7f",
      "a133d1e5aea075d9017637453dc497ba9028d9ad82f3ca5c175bab67c5ba2296"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv3f_rule <- function() {
  data.frame(
    Rule = c(
      "independent_analytic_score", "finite_difference_score",
      "expanded_log_jacobian", "expanded_slope_jacobian"
    ),
    AbsoluteFloor = c(1e-8, 1e-7, 5e-10, 1e-9),
    RelativeRate = c(1e-10, 5e-7, 1e-9, 1e-9),
    ReferenceSpreadMultiplier = c(0, 10, 0, 0),
    RoundoffMultiplier = c(0, 10, 0, 0),
    LogSlopeEnvelope = 3,
    FrozenForDisjointConfirmation = TRUE,
    FinalNUMSCORETOLFrozen = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv3f_payload_identity <- function(root) {
  paths <- c(
    file.path(root, c("DESCRIPTION", "NAMESPACE")),
    list.files(file.path(root, "R"), pattern = "[.]R$", full.names = TRUE),
    list.files(file.path(root, "src"), full.names = TRUE, recursive = TRUE)
  )
  paths <- sort(unique(paths[file.exists(paths) & !dir.exists(paths)]))
  ledger <- data.frame(
    Path = substring(paths, nchar(root) + 2L),
    SHA256 = vapply(paths, mfrmr_gsv3f_hash_file, character(1L)),
    stringsAsFactors = FALSE
  )
  mfrmr_gsv3f_hash_object(ledger)
}

mfrmr_validate_gpcm_score_v3_freeze <- function(artifact_root = NULL) {
  validation_dir <- mfrmr_gsv3f_validation_dir()
  root <- normalizePath(file.path(validation_dir, "..", ".."),
                        winslash = "/", mustWork = TRUE)
  if (is.null(artifact_root)) {
    artifact_root <- file.path(root, "validation-results")
  }
  source_registry <- mfrmr_gsv3f_source_registry()
  source_paths <- file.path(validation_dir, source_registry$File)
  source_hashes <- vapply(source_paths, mfrmr_gsv3f_hash_file, character(1L))
  mfrmr_gsv3f_assert(
    identical(unname(source_hashes), source_registry$SHA256),
    "The frozen v3 source chain changed."
  )
  mfrmr_gsv3f_assert(
    identical(mfrmr_gsv3f_payload_identity(root), mfrmr_gsv3f_expected_payload),
    "The frozen package payload changed."
  )

  artifact_registry <- mfrmr_gsv3f_artifact_registry()
  artifact_paths <- file.path(artifact_root, artifact_registry$RelativePath)
  artifact_hashes <- vapply(artifact_paths, mfrmr_gsv3f_hash_file, character(1L))
  mfrmr_gsv3f_assert(
    identical(unname(artifact_hashes), artifact_registry$SHA256),
    "The frozen v2, attribution, or v3 artifact changed."
  )
  names(artifact_paths) <- artifact_registry$Artifact
  v2 <- readRDS(artifact_paths["V2"])
  attribution <- readRDS(artifact_paths["Attribution"])
  v3 <- readRDS(artifact_paths["V3"])

  mfrmr_gsv3f_assert(
    identical(v2$decision$Status, "rejected") &&
      identical(v2$identity$NumericalBaseSHA256,
                source_registry$SHA256[source_registry$File ==
                  "numerical-stationarity-pilot-0.2.3.R"]) &&
      !isTRUE(v2$general_num_score_tol_frozen) &&
      !isTRUE(v2$confirmation_authorized),
    "The sealed v2 negative calibration is invalid."
  )
  mfrmr_gsv3f_assert(
    identical(attribution$decision$Status, "attribution_agreement") &&
      identical(attribution$decision$V2CalibrationStatus,
                "rejected_unchanged") &&
      !isTRUE(attribution$calibration_result_changed) &&
      !isTRUE(attribution$confirmation_authorized),
    "The sealed analytic attribution is invalid."
  )
  mfrmr_gsv3f_assert(
    identical(v3$decision$Status, "v3_rule_contract_ready") &&
      identical(v3$identity$IdentitySHA256, mfrmr_gsv3f_expected_identity) &&
      identical(v3$manifest$ReplayManifestSHA256[1],
                mfrmr_gsv3f_expected_manifest) &&
      identical(v3$identity$PackagePayloadSHA256,
                mfrmr_gsv3f_expected_payload) &&
      nrow(v3$evidence) == 128L && nrow(v3$coordinates) == 672L &&
      nrow(v3$point_summary) == 32L && nrow(v3$jacobian) == 384L &&
      !anyDuplicated(v3$evidence[c(
        "ScenarioId", "Point", "ParameterClass"
      )]) &&
      all(v3$evidence$EvaluationComplete %in% TRUE) &&
      all(v3$evidence$AnalyticScorePass %in% TRUE) &&
      all(v3$evidence$LogJacobianCombinedRatio <= 1) &&
      all(v3$evidence$SlopeJacobianCombinedRatio <= 1) &&
      !any(v3$fits$InferenceReady %in% TRUE) &&
      !isTRUE(v3$general_num_score_tol_frozen) &&
      !isTRUE(v3$boundary_proven) && !isTRUE(v3$confirmation_authorized),
    "The sealed v3 calibration result is invalid."
  )

  actual <- as.data.frame(table(
    v3$coordinates$ScenarioId, v3$coordinates$Point,
    v3$coordinates$ParameterClassFrozen
  ), stringsAsFactors = FALSE)
  names(actual) <- c("ScenarioId", "Point", "ParameterClass", "ActualCount")
  counts <- merge(
    v3$evidence[c("ScenarioId", "Point", "ParameterClass", "CoordinateCount")],
    actual, by = c("ScenarioId", "Point", "ParameterClass"), all = TRUE
  )
  mfrmr_gsv3f_assert(
    nrow(counts) == 128L && !anyNA(counts) &&
      all(counts$CoordinateCount == counts$ActualCount) &&
      all(table(v3$jacobian$ScenarioId, v3$jacobian$Point) == 12L),
    "The sealed v3 evidence denominator is incomplete."
  )

  data.frame(
    ContractVersion = mfrmr_gsv3f_contract_version,
    Status = "calibration_rule_frozen_for_disjoint_confirmation",
    SourceChainComplete = TRUE,
    EvidenceDenominatorComplete = TRUE,
    V2CalibrationStatus = "rejected_unchanged",
    CalibrationRuleFrozenForDisjointConfirmation = TRUE,
    FinalNUMSCORETOLFrozen = FALSE,
    BoundaryProven = FALSE,
    InferenceAuthorized = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}
