rater_anchor_sparse_prospective_paths <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  c(
    contract = file.path(
      validation, "rater-anchor-sparse-prospective-contract-0.2.3.R"
    ),
    record = file.path(
      validation, "rater-anchor-sparse-prospective-contract-record-0.2.3.md"
    )
  )
}

rater_anchor_sparse_prospective_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- rater_anchor_sparse_prospective_paths()
    testthat::skip_if_not(file.exists(paths[["contract"]]))
    testthat::skip_if_not_installed("digest")
    value <<- new.env(parent = globalenv())
    sys.source(paths[["contract"]], envir = value)
    value
  }
})

test_that("prospective registry separates percentage, error, and topology", {
  env <- rater_anchor_sparse_prospective_environment()
  registry <- env$mfrmr_rasp_registry()

  expect_s3_class(registry, "mfrmr_rasp_registry")
  expect_identical(
    registry$FingerprintScope, "within_run_pairing_and_provenance_only"
  )
  expect_identical(nrow(registry$FactorCatalog), 12L)
  expect_identical(nrow(registry$AnchorRegistry), 8L)
  expect_identical(nrow(registry$DesignRegistry), 7L)
  expect_identical(nrow(registry$MetricRegistry), 17L)
  expect_identical(nrow(registry$DecisionRegistry), 9L)
  expect_identical(nchar(registry$RegistrySHA256), 64L)
  expect_identical(registry$Model, "PCM")
  expect_identical(registry$Estimator, "JML")
  expect_false(registry$GPCMIncluded)
  expect_false(registry$FACETSExternalFitsIncluded)
  expect_false(registry$AppropriateAnchorRateSelected)
})

test_that("sixteen Raters make registered percentages exact counts", {
  env <- rater_anchor_sparse_prospective_environment()
  anchors <- env$mfrmr_rasp_registry()$AnchorRegistry
  eligible <- anchors[anchors$RateComparisonEligible, , drop = FALSE]

  expect_identical(eligible$AnchorCount, c(0L, 2L, 4L, 8L))
  expect_equal(eligible$AnchorRate, c(0, 0.125, 0.25, 0.5))
  expect_true(all(eligible$ErrorMechanism %in% c("none", "oracle_exact")))
  expect_true(all(
    anchors$SelectionSource[anchors$AnchorRate > 0] ==
      "external_calibration_estimate"
  ))
  expect_true(all(
    anchors$SelectionCalibrationSD[anchors$AnchorRate > 0] == 0.10
  ))
  expect_identical(
    anchors$ErrorSD[anchors$AnchorConfig == "normal_sd10_25_span"], 0.10
  )
  expect_identical(
    anchors$ErrorSD[anchors$AnchorConfig == "normal_sd25_25_span"], 0.25
  )
  expect_identical(
    anchors$ErrorShift[anchors$AnchorConfig == "shifted_plus25_25_span"],
    0.25
  )
})

test_that("sparse designs account for assignments separately from anchors", {
  env <- rater_anchor_sparse_prospective_environment()
  designs <- env$mfrmr_rasp_registry()$DesignRegistry

  expect_identical(
    designs$ExpectedRatingAssignments,
    c(2560L, 160L, 280L, 460L, 460L, 320L, 432L)
  )
  expect_identical(
    designs$AddedAssignmentsAboveSingle,
    designs$ExpectedRatingAssignments - 160L
  )
  expect_identical(
    designs$ExpectedResponseRows,
    4L * designs$ExpectedRatingAssignments
  )
  expect_equal(
    designs$ExpectedDensity,
    designs$ExpectedRatingAssignments / (160L * 16L),
    tolerance = 1e-12
  )
  expect_true(all(c(
    "disconnected_negative_control",
    "connected_repeat_rating_without_universal_link"
  ) %in% designs$Role))
})

test_that("prospective manifests preserve paired data and anchor identities", {
  env <- rater_anchor_sparse_prospective_environment()
  registry <- env$mfrmr_rasp_registry()
  smoke <- env$mfrmr_rasp_execution_manifest(registry, "smoke")
  feasibility <- env$mfrmr_rasp_execution_manifest(
    registry, "feasibility"
  )

  expect_identical(nrow(smoke), 12L)
  expect_identical(nrow(feasibility), 560L)
  expect_identical(length(unique(feasibility$DatasetId)), 70L)
  expect_identical(length(unique(feasibility$AnchorSetId)), 80L)
  expect_true(all(table(feasibility$DatasetId) == 8L))
  expect_true(all(table(feasibility$AnchorSetId) == 7L))
  expect_identical(anyDuplicated(feasibility$RunId), 0L)
  expect_true(all(feasibility$RegistrySHA256 == registry$RegistrySHA256))
  expect_true(all(!feasibility$ExecutionAuthorized))
  expect_true(all(!feasibility$AppropriateAnchorRateSelected))
  expect_true(all(!feasibility$ConfirmationAuthorized))
})

test_that("external anchor noise is independent and reused across designs", {
  env <- rater_anchor_sparse_prospective_environment()
  manifest <- env$mfrmr_rasp_execution_manifest(
    env$mfrmr_rasp_registry(), "feasibility"
  )
  noisy <- manifest$ErrorMechanism == "independent_normal"
  selected <- manifest$AnchorRate > 0

  expect_true(all(!is.na(manifest$ExternalSelectionSeed[selected])))
  expect_true(all(is.na(manifest$ExternalSelectionSeed[!selected])))
  by_replicate <- split(
    manifest$ExternalSelectionSeed[selected], manifest$Replicate[selected]
  )
  expect_true(all(vapply(
    by_replicate, function(x) length(unique(x)) == 1L, logical(1)
  )))
  expect_identical(
    length(unique(manifest$ExternalSelectionSeed[selected])), 10L
  )
  expect_false(any(
    manifest$ExternalSelectionSeed[selected] %in% manifest$DataSeed
  ))
  expect_true(all(!is.na(manifest$ExternalAnchorSeed[noisy])))
  expect_true(all(is.na(manifest$ExternalAnchorSeed[!noisy])))
  by_anchor_set <- split(
    manifest$ExternalAnchorSeed[noisy], manifest$AnchorSetId[noisy]
  )
  expect_true(all(vapply(
    by_anchor_set, function(x) length(unique(x)) == 1L, logical(1)
  )))
  expect_identical(
    length(unique(manifest$ExternalAnchorSeed[noisy])), 20L
  )
  expect_false(any(
    manifest$ExternalAnchorSeed[noisy] %in% manifest$DataSeed
  ))
})

test_that("decision rules prohibit percentage-only and feasibility claims", {
  env <- rater_anchor_sparse_prospective_environment()
  registry <- env$mfrmr_rasp_registry()
  decisions <- registry$DecisionRegistry
  precision <- registry$PrecisionPlan

  expect_true(all(c(
    "separate_networks", "free_rater_only", "resource_frontier",
    "operational_rate_authority"
  ) %in% decisions$RuleId))
  expect_match(
    decisions$FixedRule[decisions$RuleId == "resource_frontier"],
    "do not scalarize", fixed = TRUE
  )
  expect_match(
    decisions$FixedRule[decisions$RuleId == "feasibility_authority"],
    "cannot select a percentage", fixed = TRUE
  )
  expect_identical(
    precision$Replications[precision$Profile == "feasibility"], 10L
  )
  expect_true(is.na(
    precision$Replications[precision$Profile == "confirmation"]
  ))
  expect_identical(
    precision$WorstCaseBinaryMinReplications[
      precision$Profile == "confirmation"
    ],
    400L
  )
  expect_true(all(!precision$ExecutionAuthorized))
})

test_that("preflight fixes structural counts without authorizing fits", {
  env <- rater_anchor_sparse_prospective_environment()
  smoke <- env$mfrmr_rasp_preflight("smoke")
  feasibility <- env$mfrmr_rasp_preflight("feasibility")

  expect_identical(smoke$PlannedRuns, 12L)
  expect_identical(feasibility$PlannedRuns, 560L)
  expect_identical(feasibility$PlannedUniqueDatasets, 70L)
  expect_identical(feasibility$PlannedSelectionCalibrations, 10L)
  expect_identical(feasibility$PlannedExternalAnchorSets, 80L)
  expect_identical(
    feasibility$Status, "prospective_manifest_structurally_ready"
  )
  expect_identical(nchar(feasibility$ManifestSHA256), 64L)
  expect_false(feasibility$ExecutionAuthorized)
  expect_false(feasibility$AppropriateAnchorRateSelected)
  expect_false(feasibility$ConfirmationAuthorized)
})

test_that("failure denominators retain every prospective run", {
  env <- rater_anchor_sparse_prospective_environment()
  registry <- env$mfrmr_rasp_registry()
  manifest <- env$mfrmr_rasp_execution_manifest(registry, "smoke")
  results <- env$mfrmr_rasp_empty_results(manifest)
  empty <- env$mfrmr_rasp_denominator_summary(registry, manifest, results)

  expect_identical(empty$PlannedRuns, 12L)
  expect_identical(empty$RecordedRuns, 12L)
  expect_identical(empty$ExecutedRuns, 0L)
  expect_false(empty$ExactAccountingPassed)

  results$FailureStage <- "not_executed"
  results$FailureCode <- "prospective_contract_only"
  classified <- env$mfrmr_rasp_denominator_summary(
    registry, manifest, results
  )
  expect_identical(classified$ClassifiedFailureRuns, 12L)
  expect_true(classified$ExactAccountingPassed)
  expect_false(classified$AppropriateAnchorRateSelected)
  expect_false(classified$ConfirmationAuthorized)

  partial <- results[-1L, , drop = FALSE]
  incomplete <- env$mfrmr_rasp_denominator_summary(
    registry, manifest, partial
  )
  expect_identical(incomplete$UnrecordedRuns, 1L)
  expect_false(incomplete$ExactAccountingPassed)
})

test_that("registry and manifest mutations fail closed", {
  env <- rater_anchor_sparse_prospective_environment()

  bad_count <- env$mfrmr_rasp_registry()
  bad_count$AnchorRegistry$AnchorCount[[3L]] <- 3L
  expect_error(
    env$mfrmr_rasp_validate_registry(bad_count), "Anchor counts"
  )

  bad_cost <- env$mfrmr_rasp_registry()
  bad_cost$DesignRegistry$AddedAssignmentsAboveSingle[[1L]] <- 0L
  expect_error(
    env$mfrmr_rasp_validate_registry(bad_cost), "resource accounting"
  )

  bad_authority <- env$mfrmr_rasp_registry()
  bad_authority$FeasibilityExecutionAuthorized <- TRUE
  expect_error(
    env$mfrmr_rasp_validate_registry(bad_authority), "cannot execute"
  )

  registry <- env$mfrmr_rasp_registry()
  manifest <- env$mfrmr_rasp_execution_manifest(registry, "smoke")
  manifest$ExternalAnchorSeed[
    manifest$ErrorMechanism == "independent_normal"
  ][[1L]] <- 616001L
  expect_error(
    env$mfrmr_rasp_validate_manifest(registry, manifest, "smoke"),
    "External anchor errors"
  )
})

test_that("prospective record documents design and authority boundaries", {
  paths <- rater_anchor_sparse_prospective_paths()
  skip_if_not(all(file.exists(paths)))
  record <- paste(
    readLines(paths[["record"]], warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  expect_match(record, "560 declared feasibility fits", fixed = TRUE)
  expect_match(record, "within-run pairing", fixed = TRUE)
  expect_match(record, "not a\\s+cross-machine numerical")
  expect_match(record, "FeasibilityExecutionAuthorized = FALSE", fixed = TRUE)
  expect_match(record, "AppropriateAnchorRateSelected = FALSE", fixed = TRUE)
  expect_match(record, "ConfirmationAuthorized = FALSE", fixed = TRUE)
})
