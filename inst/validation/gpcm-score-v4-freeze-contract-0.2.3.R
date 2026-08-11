# No-fit source/artifact seal for the bounded GPCM score-rule v4 calibration.
# This freezes only the calibrated rule and interpretation for later disjoint
# confirmation design. It authorizes no fit, confirmation execution, inference,
# boundary theorem, or general NUM-SCORE-TOL.

mfrmr_gsv4f_contract_version <- "mfrmr_gpcm_score_v4_freeze_v1"
mfrmr_gsv4f_expected_payload <-
  "ef9fe233ceaa43b9a85ee58230b80bc425dd9be38ed21867c5deeb6beea7565a"

mfrmr_gsv4f_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl("gpcm-score-v4-freeze-contract-0\\.2\\.3\\.R$", files)]
  if (length(hit) == 0L) return(NA_character_)
  dirname(normalizePath(hit[length(hit)], winslash = "/", mustWork = FALSE))
})

mfrmr_gsv4f_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsv4f_validation_dir <- function() {
  if (!is.na(mfrmr_gsv4f_source_dir) && dir.exists(mfrmr_gsv4f_source_dir)) {
    return(mfrmr_gsv4f_source_dir)
  }
  candidates <- c(
    file.path("inst", "validation"),
    file.path("..", "inst", "validation"),
    file.path("..", "..", "inst", "validation"), "."
  )
  found <- candidates[file.exists(file.path(
    candidates, "gpcm-score-v4-rule-contract-0.2.3.R"
  ))]
  mfrmr_gsv4f_assert(length(found) > 0L,
                     "Cannot locate v4 freeze sources.")
  normalizePath(found[[1L]], winslash = "/", mustWork = TRUE)
}

mfrmr_gsv4f_hash_file <- function(path) {
  mfrmr_gsv4f_assert(requireNamespace("digest", quietly = TRUE),
                     "Package `digest` is required for the v4 freeze seal.")
  mfrmr_gsv4f_assert(file.exists(path), paste0("Missing sealed file: ", path))
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gsv4f_hash_object <- function(object) {
  digest::digest(object, algo = "sha256", serialize = TRUE)
}

mfrmr_gsv4f_source_registry <- function() {
  data.frame(
    File = c(
      "gpcm-score-v4-rule-contract-0.2.3.R",
      "gpcm-score-v4-retrospective-calibration-0.2.3.R",
      "gpcm-score-v4-boundary-completion-design-0.2.3.R",
      "gpcm-score-v4-boundary-completion-runner-0.2.3.R",
      "gpcm-score-v4-boundary-completion-authorization-0.2.3.R",
      "gpcm-score-v4-boundary-completion-validator-0.2.3.R"
    ),
    SHA256 = c(
      "c746bd02b435e851af0ff89fff6320c34e66a1aa9fe8c52d0b6447689dd5a126",
      "831fcd4683e46785291c832242867f1962b56ce3a142c09da78fcbc311d08025",
      "bf6ae572a3c0c2253c6fbd35fc5138eaaae92728d7d9588f1d50cebfafcae838",
      "78e0bcfd14c5c4343e0ff4beeb9c250b324539f1dffe8468bed4ccaf13f8090e",
      "41f51a6d3e56b09ec92d67aee2f3ff92b0438a49c4e0d370701071072a95d3a3",
      "ff2b8e55316251411076480751f1ed39459d5a2be8675c0bce8a99482631b9e7"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv4f_artifact_registry <- function() {
  data.frame(
    Artifact = c("RejectedV3Confirmation", "V4BoundaryCompletion"),
    RelativePath = c(
      file.path("gpcm-score-v3-confirmation-source-bound",
                "gpcm-score-v3-confirmation.rds"),
      file.path("gpcm-score-v4-boundary-completion-source-bound",
                "gpcm-score-v4-boundary-completion.rds")
    ),
    SHA256 = c(
      "7836d859cca48e9a3641d94edda000218bb9c9f2903d801d7b9c9f03da017f2e",
      "5998c6c5f01a9436af0af152d30315655291275d72c169649e048f0d5647400e"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv4f_rule <- function() {
  data.frame(
    Rule = c(
      "independent_analytic_score", "finite_difference_score",
      "expanded_log_jacobian", "expanded_slope_jacobian"
    ),
    AbsoluteFloor = c(1e-8, 1e-7, 5e-10, 1e-9),
    RelativeRate = c(1e-10, 5e-7, 1e-9, 1e-9),
    ReferenceSpreadMultiplier = c(0, 10, 0, 0),
    RoundoffMultiplier = c(0, 10, 0, 0),
    ConstructedLogSlopeEnvelope = 3,
    RetainedSolutionAllowance = 0,
    FrozenForDisjointConfirmation = TRUE,
    GeneralNUMSCORETOLFrozen = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv4f_payload_identity <- function(root) {
  paths <- c(
    file.path(root, c("DESCRIPTION", "NAMESPACE")),
    list.files(file.path(root, "R"), pattern = "[.]R$", full.names = TRUE),
    list.files(file.path(root, "src"), full.names = TRUE, recursive = TRUE)
  )
  paths <- sort(unique(paths[file.exists(paths) & !dir.exists(paths)]))
  ledger <- data.frame(
    Path = substring(paths, nchar(root) + 2L),
    SHA256 = vapply(paths, mfrmr_gsv4f_hash_file, character(1L)),
    stringsAsFactors = FALSE
  )
  mfrmr_gsv4f_hash_object(ledger)
}

mfrmr_validate_gpcm_score_v4_freeze <- function(artifact_root = NULL) {
  validation_dir <- mfrmr_gsv4f_validation_dir()
  root <- normalizePath(file.path(validation_dir, "..", ".."),
                        winslash = "/", mustWork = TRUE)
  if (is.null(artifact_root)) artifact_root <- file.path(root, "validation-results")

  sources <- mfrmr_gsv4f_source_registry()
  source_hashes <- vapply(
    file.path(validation_dir, sources$File),
    mfrmr_gsv4f_hash_file, character(1L)
  )
  mfrmr_gsv4f_assert(
    identical(unname(source_hashes), sources$SHA256),
    "The sealed v4 source chain changed."
  )
  mfrmr_gsv4f_assert(
    identical(mfrmr_gsv4f_payload_identity(root),
              mfrmr_gsv4f_expected_payload),
    "The sealed v4 package payload changed."
  )

  artifacts <- mfrmr_gsv4f_artifact_registry()
  artifact_paths <- file.path(artifact_root, artifacts$RelativePath)
  artifact_hashes <- vapply(
    artifact_paths, mfrmr_gsv4f_hash_file, character(1L)
  )
  mfrmr_gsv4f_assert(
    identical(unname(artifact_hashes), artifacts$SHA256),
    "The rejected v3 or v4 completion artifact changed."
  )
  names(artifact_paths) <- artifacts$Artifact

  env <- new.env(parent = globalenv())
  for (file in c(
    "gpcm-score-v4-rule-contract-0.2.3.R",
    "gpcm-score-v4-retrospective-calibration-0.2.3.R",
    "gpcm-score-v4-boundary-completion-validator-0.2.3.R"
  )) {
    sys.source(file.path(validation_dir, file), envir = env)
  }
  actual_rule <- env$mfrmr_gsv4_rule_registry()
  frozen_rule <- mfrmr_gsv4f_rule()
  mfrmr_gsv4f_assert(
    identical(actual_rule$Rule, frozen_rule$Rule) &&
      identical(actual_rule$AbsoluteFloor, frozen_rule$AbsoluteFloor) &&
      identical(actual_rule$RelativeRate, frozen_rule$RelativeRate) &&
      identical(actual_rule$ReferenceSpreadMultiplier,
                frozen_rule$ReferenceSpreadMultiplier) &&
      identical(actual_rule$RoundoffMultiplier,
                frozen_rule$RoundoffMultiplier) &&
      all(!actual_rule$ChangedFromV3) &&
      all(!actual_rule$ConfirmationAuthorized) &&
      identical(env$mfrmr_gsv4_envelope, 3) &&
      identical(env$mfrmr_gsv4_contract()$retained_solution_allowance, 0),
    "The bounded v4 numerical rule changed."
  )

  retrospective <- env$mfrmr_run_gpcm_score_v4_retrospective(
    artifact_paths["RejectedV3Confirmation"]
  )
  changed <- retrospective$points[retrospective$points$RegionChanged, ,
                                  drop = FALSE]
  mfrmr_gsv4f_assert(
    identical(
      retrospective$decision$Status,
      "classification_calibrated_numerical_evidence_incomplete"
    ) && isTRUE(retrospective$decision$ClassificationCalibrationPass) &&
      identical(retrospective$decision$MissingRequiredFiniteDifferencePoints,
                1L) && nrow(changed) == 1L &&
      identical(changed$Point, "finite_slope_stress_forward") &&
      changed$RawExcess > 0 &&
      changed$RawExcess <= changed$ConstructionAllowance &&
      all(retrospective$points$V4Region[
        retrospective$points$Point == "retained_solution"
      ] == retrospective$points$OriginalRegion[
        retrospective$points$Point == "retained_solution"
      ]) && !isTRUE(retrospective$decision$V4FreezeReady),
    "The v4 retrospective calibration lineage is invalid."
  )

  completion <- env$mfrmr_validate_gpcm_score_v4_boundary_completion(
    artifact_paths["V4BoundaryCompletion"]
  )
  completion_result <- readRDS(artifact_paths["V4BoundaryCompletion"])
  mfrmr_gsv4f_assert(
    identical(completion$Status,
              "validated_calibration_only_numerical_pass") &&
      isTRUE(completion$ArtifactIntegrityPass) &&
      isTRUE(completion$SourceIdentityPass) &&
      isTRUE(completion$AuthorizationIssueHashPass) &&
      isTRUE(completion$AuthorizationConsumedRowHashPass) &&
      identical(completion$TargetPathForm, "repository_relative") &&
      !isTRUE(completion$AbsoluteTargetRecorded) &&
      isTRUE(completion$TargetResolvesToArtifact) &&
      isTRUE(completion$CompleteDenominator) &&
      isTRUE(completion$NumericalRulePass) &&
      identical(completion$FitReadiness, "review") &&
      isTRUE(completion$CalibrationOnly) &&
      !isTRUE(completion$ConfirmationEligible) &&
      !isTRUE(completion$V4Frozen) &&
      !isTRUE(completion$GeneralNUMSCORETOLFrozen) &&
      !isTRUE(completion$InferenceAuthorized) &&
      !isTRUE(completion_result$point_summary$BoundaryProven),
    "The v4 boundary-completion evidence is not freeze-review complete."
  )

  source_seal <- mfrmr_gsv4f_hash_object(list(
    PackagePayloadSHA256 = mfrmr_gsv4f_expected_payload,
    Sources = sources,
    Artifacts = artifacts,
    Rule = frozen_rule,
    RelativeTargetDisclosed = TRUE
  ))
  data.frame(
    ContractVersion = mfrmr_gsv4f_contract_version,
    Status = "v4_bounded_rule_frozen_for_disjoint_confirmation",
    SourceSealSHA256 = source_seal,
    SourceChainComplete = TRUE,
    ArtifactChainComplete = TRUE,
    V3NegativeResultRetained = TRUE,
    UniqueConstructedBoundaryReclassification = TRUE,
    MissingFiniteDifferenceCompleted = TRUE,
    AuthorizationProvenanceComplete = TRUE,
    RepositoryRelativeTargetDisclosed = TRUE,
    AbsoluteTargetRecorded = FALSE,
    V4BoundedRuleFrozenForDisjointConfirmation = TRUE,
    DisjointConfirmationDesignMayProceed = TRUE,
    ConfirmationExecutionAuthorized = FALSE,
    GeneralNUMSCORETOLFrozen = FALSE,
    BoundaryProven = FALSE,
    InferenceAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}
