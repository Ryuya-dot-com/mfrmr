load_gtheory_dsim3ad <- local({
  loaded <- NULL
  function() {
    root <- testthat::test_path("..", "..")
    validation <- file.path(root, "inst", "validation")
    controller <- file.path(
      validation,
      paste0(
        "gtheory-multivariate-dsim3-bounded-exploratory-launch-",
        "controller-0.2.4.R"
      )
    )
    analysis <- file.path(
      validation,
      paste0(
        "gtheory-multivariate-dsim3-descriptive-recovery-",
        "adjudication-0.2.4.R"
      )
    )
    record <- file.path(
      validation,
      paste0(
        "gtheory-multivariate-dsim3-descriptive-recovery-",
        "adjudication-record-0.2.4.md"
      )
    )
    skip_if_not(
      all(file.exists(c(controller, analysis, record))),
      "repository-internal descriptive recovery excluded"
    )
    skip_if_not_installed("digest")
    if (is.null(loaded)) {
      probe <- new.env(parent = globalenv())
      sys.source(controller, envir = probe, keep.source = FALSE)
      basenames <- probe$mfrmr_gtds3ac_source_basenames()
      environment <- new.env(parent = globalenv())
      for (basename in head(basenames, -1L)) {
        sys.source(file.path(validation, basename), envir = environment,
                   keep.source = FALSE)
      }
      sys.source(analysis, envir = environment, keep.source = FALSE)
      loaded <<- list(
        Environment = environment, SourceRoot = root,
        RecordPath = record
      )
    }
    loaded
  }
})

test_that("descriptive recovery contract is read-only and nonconfirmatory", {
  env <- load_gtheory_dsim3ad()$Environment
  contract <- env$mfrmr_gtds3ad_contract()
  expect_invisible(env$mfrmr_gtds3ad_validate_contract(contract))
  expect_identical(
    contract$ContractHash,
    "e274e2a73934a94578b79af347b5643724c56b99490791b693cb2cc12edd98c5"
  )
  expect_true(contract$ImmutableEvidenceReadOnly)
  expect_false(contract$ResponseGenerationAllowed)
  expect_false(contract$BackendCallAllowed)
  expect_false(contract$RefitAllowed)
  expect_false(contract$ReplacementSeedAllowed)
  expect_false(contract$FailureExclusionAllowed)
  expect_false(contract$RouteVotingAllowed)
  expect_true(contract$DirectTruthLimitedToQualifiedSeparateUnivariateRoutes)
  expect_false(contract$MultivariateParityIsIndependentReference)
  expect_false(contract$StandardizedBiasAcceptanceMayBeEvaluated)
  expect_false(contract$CoverageAcceptanceMayBeEvaluated)
  expect_true(contract$RecoveryEvidenceMayBeComputed)
  expect_false(contract$ConfirmationAuthorizationAllowed)
  expect_false(contract$SimulationValidationClaimAllowed)
  expect_false(contract$PublicSupportPromotionAllowed)
})

test_that("descriptive recovery record preserves multiverse denominators", {
  loaded <- load_gtheory_dsim3ad()
  record <- paste(
    readLines(loaded$RecordPath, warn = FALSE), collapse = "\n"
  )
  expect_match(
    record,
    "ad97f0f48f382bd41c6353dab6ce1405453b6146ce3fd4dfbb4ea04406fb8f8f",
    fixed = TRUE
  )
  expect_match(record, "184/188 scalar values", fixed = TRUE)
  expect_match(record, "40/40", fixed = TRUE)
  expect_match(record, "D3-S010", fixed = TRUE)
  expect_match(record, "0.324044", fixed = TRUE)
  expect_match(record, "D-SIM-4 is not automatically admitted", fixed = TRUE)
})

test_that("local descriptive manifest is exact when binary evidence exists", {
  loaded <- load_gtheory_dsim3ad()
  env <- loaded$Environment
  path <- file.path(
    loaded$SourceRoot, "validation-results",
    "gtheory-multivariate-dsim3-descriptive-recovery-0.2.4",
    "descriptive-recovery-manifest.rds"
  )
  if (!file.exists(path)) {
    skip("local descriptive-recovery binary evidence is not present")
  }
  manifest <- readRDS(path)
  expect_invisible(env$mfrmr_gtds3ad_assert_manifest(manifest))
  expect_identical(
    manifest$ManifestHash,
    "ad97f0f48f382bd41c6353dab6ce1405453b6146ce3fd4dfbb4ea04406fb8f8f"
  )
  expect_identical(nrow(manifest$CoordinateAdjudicationRegistry), 420L)
  expect_identical(
    unname(as.integer(table(factor(
      manifest$CoordinateAdjudicationRegistry$DescriptiveDisposition,
      levels = c(
        "direct_truth_compared", "direct_truth_metric_failure",
        "scenario_reference_parity_only", "frozen_no_call_preserved"
      )
    )))),
    c(82L, 2L, 16L, 320L)
  )
  expect_identical(nrow(manifest$DirectTruthScalarRegistry), 188L)
  expect_identical(
    sum(manifest$DirectTruthScalarRegistry$ComparisonAvailable), 184L
  )
  expect_identical(nrow(manifest$WithinBackendParityScalarRegistry), 40L)
  expect_true(all(
    manifest$WithinBackendParityScalarRegistry$ComparisonAvailable
  ))
  expect_identical(nrow(manifest$ProfileRecoverySummaryRegistry), 42L)
  expect_identical(nrow(manifest$ScenarioRoleRecoverySummaryRegistry), 8L)
  expect_identical(
    round(manifest$EstimandRecoverySummaryRegistry$RootMeanSquaredError, 8L),
    c(0.05240607, 0.05008863)
  )
  expect_true(manifest$Summary$DescriptiveRecoveryComputed)
  expect_false(manifest$Summary$MonteCarloAcceptanceEvaluated)
  expect_false(manifest$Summary$ConfirmationAuthorized)
  expect_false(manifest$Summary$SimulationValidationReady)
  expect_false(manifest$Summary$PublicSupportReady)
})
