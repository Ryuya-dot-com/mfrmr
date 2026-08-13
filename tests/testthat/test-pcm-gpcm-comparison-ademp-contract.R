pcm_gpcm_ademp_paths <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  c(
    contract = file.path(
      validation, "pcm-gpcm-comparison-ademp-contract-0.2.3.R"
    ),
    record = file.path(
      validation, "pcm-gpcm-comparison-ademp-contract-record-0.2.3.md"
    )
  )
}

pcm_gpcm_ademp_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    path <- pcm_gpcm_ademp_paths()[["contract"]]
    testthat::skip_if_not(file.exists(path))
    testthat::skip_if_not_installed("digest")
    value <<- new.env(parent = globalenv())
    sys.source(path, envir = value)
    value
  }
})

test_that("PCM/GPCM ADEMP registry separates exact and practical truth", {
  env <- pcm_gpcm_ademp_environment()
  registry <- env$mfrmr_pgac_registry()

  expect_s3_class(registry, "mfrmr_pgac_registry")
  expect_identical(nrow(registry$FactorCatalog), 11L)
  expect_identical(nrow(registry$TruthRegistry), 4L)
  expect_identical(nrow(registry$ScenarioRegistry), 16L)
  expect_identical(anyDuplicated(registry$ScenarioRegistry$ScenarioId), 0L)
  expect_identical(
    sort(unique(registry$ScenarioRegistry$SlopeOwner)),
    c("Criterion", "Rater")
  )
  expect_true(all(
    registry$ScenarioRegistry$SlopeOwner ==
      registry$ScenarioRegistry$StepOwner
  ))
  expect_identical(
    registry$TruthRegistry$KernelTruthModel[
      registry$TruthRegistry$SlopeRegime == "unit_slopes"
    ],
    "PCM"
  )
  expect_identical(
    registry$TruthRegistry$PracticalDecisionTarget[
      registry$TruthRegistry$SlopeRegime == "near_flat"
    ],
    "indifference_band"
  )
  expect_true(all(nchar(registry$RegistrySHA256) == 64L))
})

test_that("estimator lanes prohibit JML and ungated MML selection", {
  env <- pcm_gpcm_ademp_environment()
  registry <- env$mfrmr_pgac_registry()
  methods <- registry$MethodRegistry
  routing <- registry$MetricRouting

  expect_identical(sort(methods$EstimatorLane), c("JML", "MML"))
  expect_false(methods$InformationCriterionMetricsPlanned[
    methods$EstimatorLane == "JML"
  ])
  expect_true(methods$InformationCriterionMetricsPlanned[
    methods$EstimatorLane == "MML"
  ])
  expect_true(all(!methods$CurrentInformationCriterionMetricsEligible))
  expect_true(all(!methods$LRTEligible))
  selection <- routing$MetricFamily == "model_selection"
  expect_true(all(
    routing$EligibilityState[
      selection & routing$EstimatorLane == "JML"
    ] == "structurally_ineligible_JML_model_selection"
  ))
  expect_false(any(
    routing$EligibilityState == "eligible_model_selection"
  ))
})

test_that("paired manifests share datasets but never pool estimators", {
  env <- pcm_gpcm_ademp_environment()
  registry <- env$mfrmr_pgac_registry()
  smoke <- env$mfrmr_pgac_execution_manifest(registry, "smoke")
  pilot <- env$mfrmr_pgac_execution_manifest(registry, "pilot")

  expect_identical(nrow(smoke), 8L)
  expect_identical(nrow(pilot), 160L)
  expect_identical(anyDuplicated(pilot$PairId), 0L)
  expect_true(all(table(pilot$DatasetId) == 2L))
  expect_true(all(table(pilot$ScenarioId, pilot$EstimatorLane) == 5L))
  split_seed <- split(pilot$Seed, pilot$DatasetId)
  expect_true(all(vapply(split_seed, function(x) length(unique(x)) == 1L,
                         logical(1))))
  expect_true(all(pilot$RegistrySHA256 == registry$RegistrySHA256))
})

test_that("metrics cover recovery prediction consequence and availability", {
  env <- pcm_gpcm_ademp_environment()
  metrics <- env$mfrmr_pgac_registry()$MetricCatalog

  expect_true(all(c(
    "execution", "readiness", "model_evidence", "model_selection",
    "parameter_recovery", "prediction", "substantive_consequence"
  ) %in% metrics$MetricFamily))
  expect_true(all(c(
    "slope_log_rmse", "person_location_rmse", "threshold_rmse",
    "heldout_log_loss", "pcm_gpcm_person_rank_agreement",
    "ability_cut_decision_flip_rate", "criterion_information_share_rmse"
  ) %in% metrics$MetricId))
  expect_identical(
    metrics$DenominatorId[metrics$MetricId == "pair_fit_return_rate"],
    "all_planned_pairs"
  )
  expect_true("metric_availability_rate" %in% metrics$MetricId)
})

test_that("failure accounting retains every planned pair", {
  env <- pcm_gpcm_ademp_environment()
  registry <- env$mfrmr_pgac_registry()
  manifest <- env$mfrmr_pgac_execution_manifest(registry, "smoke")
  results <- env$mfrmr_pgac_empty_pair_results(manifest)
  results$Generated <- TRUE
  results$SupportAuditPassed <- TRUE
  results$PCMFitAttempted <- TRUE
  results$GPCMFitAttempted <- TRUE
  results$PCMFitReturned <- TRUE
  results$GPCMFitReturned <- c(TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE)
  results$PCMInferenceReady <- TRUE
  results$GPCMInferenceReady <- c(TRUE, FALSE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE)
  results$PairComparisonBuilt <-
    results$PCMFitReturned & results$GPCMFitReturned
  results$FailureStage <- ifelse(
    results$PCMInferenceReady & results$GPCMInferenceReady,
    "none", "readiness"
  )
  results$FailureCode <- ifelse(
    results$FailureStage == "none", "none", "pair_not_inference_ready"
  )

  summary <- env$mfrmr_pgac_denominator_summary(
    registry, manifest, results
  )
  expect_true(all(summary$PlannedPairs == 4L))
  expect_true(all(summary$RecordedPairs == 4L))
  expect_true(all(summary$UnrecordedPairs == 0L))
  expect_true(all(summary$PCMReadyPairs == 4L))
  expect_equal(sum(summary$GPCMReadyPairs), 3L)
  expect_true(all(summary$FormalSelectionPairs == 0L))
  expect_true(all(summary$ExactAccountingPassed))

  partial <- results[-1L, , drop = FALSE]
  incomplete <- env$mfrmr_pgac_denominator_summary(
    registry, manifest, partial
  )
  expect_true(any(incomplete$UnrecordedPairs > 0L))
  expect_true(any(!incomplete$ExactAccountingPassed))

  bypass <- results
  mml <- which(bypass$EstimatorLane == "MML")[[1L]]
  bypass$FormalModelSelectionAvailable[[mml]] <- TRUE
  expect_error(
    env$mfrmr_pgac_denominator_summary(registry, manifest, bypass),
    "bypassed"
  )
})

test_that("registry mutations and execution authority fail closed", {
  env <- pcm_gpcm_ademp_environment()
  make <- function() env$mfrmr_pgac_registry()

  owner <- make()
  owner$ScenarioRegistry$StepOwner[[1L]] <- "Rater"
  expect_error(env$mfrmr_pgac_validate_registry(owner), "aligned ownership")

  selection <- make()
  selection$MethodRegistry$CurrentInformationCriterionMetricsEligible[
    selection$MethodRegistry$EstimatorLane == "MML"
  ] <- TRUE
  expect_error(env$mfrmr_pgac_validate_registry(selection),
               "selection gate drifted")

  authority <- make()
  authority$FeasibilityPilotAuthorized <- TRUE
  expect_error(env$mfrmr_pgac_validate_registry(authority),
               "cannot authorize")
})

test_that("ADEMP record binds contract and focused tests", {
  paths <- pcm_gpcm_ademp_paths()
  skip_if_not(all(file.exists(paths)))
  contract_hash <- digest::digest(
    paths[["contract"]], algo = "sha256", file = TRUE, serialize = FALSE
  )
  test_hash <- digest::digest(
    testthat::test_path("test-pcm-gpcm-comparison-ademp-contract.R"),
    algo = "sha256", file = TRUE, serialize = FALSE
  )
  record <- paste(
    readLines(paths[["record"]], warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  expect_match(record, contract_hash, fixed = TRUE)
  expect_match(record, test_hash, fixed = TRUE)
  expect_match(record, "BroadSimulationAuthorized = FALSE", fixed = TRUE)
  expect_match(record, "ConfirmationAuthorized = FALSE", fixed = TRUE)
})
