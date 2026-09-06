gtheory_dsim3_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-multivariate-package-capability-contract-v4-0.2.4.R",
      "gtheory-multivariate-dsim2-plumbing-smoke-0.2.4.R",
      "gtheory-multivariate-dsim3-coverage-manifest-0.2.4.R"
    )
  )
}

load_gtheory_dsim3 <- local({
  environment <- NULL
  function() {
    paths <- gtheory_dsim3_paths()
    skip_if_not(all(file.exists(paths)),
                "repository-internal D-SIM-3 artifacts are excluded")
    skip_if_not_installed("digest")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = environment)
    }
    environment
  }
})

gtheory_dsim3_manifest <- local({
  manifest <- NULL
  function(environment) {
    if (is.null(manifest)) manifest <<- environment$mfrmr_gtds3_manifest()
    manifest
  }
})

test_that("D-SIM-3 freezes coverage without opening execution", {
  env <- load_gtheory_dsim3()
  contract <- env$mfrmr_gtds3_contract()
  expect_invisible(env$mfrmr_gtds3_validate_contract(contract))
  expect_s3_class(contract, "mfrmr_gtds3_contract")
  expect_identical(
    contract$ContractHash,
    "39b4b542f3afe617cc8f2912a23aa4211790460c8765d4ad38f9cd95575c508f"
  )
  expect_identical(length(contract$DatasetAxisIds), 12L)
  expect_identical(contract$ProjectedAxisIds,
                   c("estimand", "analysis_route"))
  expect_identical(contract$CanonicalDatasetScenarioCount, 21L)
  expect_false(contract$ScenarioRowsAreGeneratedDatasets)
  expect_false(contract$EstimandsAreDatasetReplicates)
  expect_false(contract$AnalysisRoutesAreDatasetReplicates)
  expect_false(contract$OutcomeDataAvailableToSelector)
  expect_false(contract$ResponseGenerationAllowed)
  expect_false(contract$RngAccessAllowed)
  expect_false(contract$FitExecutionAllowed)
  expect_false(contract$ExploratoryExecutionAllowed)
  expect_false(contract$SimulationValidationClaimAllowed)
  expect_false(contract$PublicSupportPromotionAllowed)
})

test_that("D-SIM-3 covers every declared level and feasible pair", {
  env <- load_gtheory_dsim3()
  manifest <- gtheory_dsim3_manifest(env)
  expect_invisible(env$mfrmr_gtds3_assert_manifest(manifest))
  expect_s3_class(manifest, "mfrmr_gtds3_manifest")
  expect_identical(
    manifest$ManifestHash,
    "4c6958f00aac7598d777387ec113cd43474031430492e83e6183d19dcedf7197"
  )
  expect_identical(manifest$Summary$DeclaredLevelCount, 44L)
  expect_identical(manifest$Summary$CoveredLevelCount, 44L)
  expect_identical(manifest$Summary$DatasetScenarioCount, 21L)
  expect_identical(manifest$Summary$GeneratedDatasetCount, 0L)
  expect_identical(manifest$Summary$FeasiblePairCount, 603L)
  expect_identical(manifest$Summary$CoveredFeasiblePairCount, 603L)
  expect_identical(manifest$Summary$ExcludedStructuralPairCount, 23L)
  expect_true(all(manifest$LevelCoverageRegistry$Covered))
  expect_true(all(manifest$FeasiblePairCoverageRegistry$Covered))
  expect_true(all(manifest$RoleCoverageRegistry$Complete))
  expect_true(all(nzchar(manifest$ExcludedPairRegistry$ExclusionReason)))
  expect_true(all(
    manifest$ExcludedPairRegistry$ExclusionReason ==
      "one_stratum_reserved_for_fixed_univariate_closure"
  ))
})

test_that("estimands and routes are projections over shared datasets", {
  env <- load_gtheory_dsim3()
  manifest <- gtheory_dsim3_manifest(env)
  estimands <- manifest$EstimandProjectionRegistry
  routes <- manifest$RouteProjectionRegistry
  expect_identical(nrow(estimands), 42L)
  expect_identical(sort(unique(estimands$EstimandId)),
                   c("ABS-PHI", "REL-G"))
  expect_true(all(table(estimands$ScenarioId) == 2L))
  expect_true(all(estimands$SharesGeneratedDatasetAcrossEstimands))
  expect_true(all(!estimands$CrossEstimandVotingAllowed))
  expect_true(all(!estimands$ExecutionSelected))
  expect_identical(nrow(routes), 105L)
  expect_true(all(table(routes$ScenarioId) == 5L))
  expect_true(all(routes$SharesGeneratedDatasetAcrossRoutes))
  expect_true(all(!routes$CountsAsIndependentDataset))
  expect_true(all(!routes$ExecutionSelected))
  expect_true(all(!routes$ResponseGenerated))
})

test_that("negative controls remain separate and nonexecuting", {
  env <- load_gtheory_dsim3()
  controls <- gtheory_dsim3_manifest(env)$NegativeControlRegistry
  expect_identical(
    controls$ControlId,
    c("NC-NAIVE-POOLING", "NC-DISCONNECTED-INCIDENCE",
      "NC-INDEFINITE-COVARIANCE")
  )
  expect_true(all(!controls$ResponseGenerationRequired))
  expect_true(all(!controls$ExecutionSelected))
  expect_true(all(!controls$PublicSupportReady))
})

test_that("D-SIM-3 replay is exact and remains nonpromoting", {
  env <- load_gtheory_dsim3()
  first <- gtheory_dsim3_manifest(env)
  replay <- env$mfrmr_gtds3_manifest()
  expect_identical(replay$ManifestHash, first$ManifestHash)
  expect_identical(replay$ScenarioRegistry, first$ScenarioRegistry)
  expect_identical(replay$FeasiblePairCoverageRegistry,
                   first$FeasiblePairCoverageRegistry)
  expect_true(first$Summary$Dsim3CoverageManifestSatisfied)
  expect_true(first$Summary$Dsim3ExecutionContractAllowed)
  expect_identical(first$Summary$FeatureMaturity, "specified")
  expect_false(first$Summary$ResponseGenerated)
  expect_false(first$Summary$RngStreamOpened)
  expect_false(first$Summary$FitExecuted)
  expect_false(first$Summary$ExploratoryExecutionAllowed)
  expect_false(first$Summary$SimulationValidationReady)
  expect_false(first$Summary$ReferenceValidationReady)
  expect_false(first$Summary$InferenceReady)
  expect_false(first$Summary$DecisionReady)
  expect_false(first$Summary$PublicSupportReady)
})

test_that("D-SIM-3 rejects altered coverage and self-promotion", {
  env <- load_gtheory_dsim3()
  manifest <- gtheory_dsim3_manifest(env)
  dropped <- manifest
  dropped$ScenarioRegistry <- dropped$ScenarioRegistry[-2L, , drop = FALSE]
  dropped$ManifestHash <- env$mfrmr_gtds3_hash(
    dropped[env$mfrmr_gtds3_payload_fields()]
  )
  expect_error(env$mfrmr_gtds3_assert_manifest(dropped),
               "manifest or readiness was altered")

  promoted <- manifest
  promoted$Summary$PublicSupportReady <- TRUE
  promoted$ManifestHash <- env$mfrmr_gtds3_hash(
    promoted[env$mfrmr_gtds3_payload_fields()]
  )
  expect_error(env$mfrmr_gtds3_assert_manifest(promoted),
               "manifest or readiness was altered")

  changed_contract <- env$mfrmr_gtds3_contract()
  changed_contract$ResponseGenerationAllowed <- TRUE
  expect_error(env$mfrmr_gtds3_validate_contract(changed_contract),
               "invalid or altered")
})

test_that("D-SIM-3 internal symbols remain outside public package surfaces", {
  public_files <- c(
    list.files(testthat::test_path("..", "..", "R"), recursive = TRUE,
               full.names = TRUE),
    list.files(testthat::test_path("..", "..", "man"), recursive = TRUE,
               full.names = TRUE),
    list.files(testthat::test_path("..", "..", "vignettes"),
               recursive = TRUE, full.names = TRUE),
    testthat::test_path("..", "..", "ROADMAP.md")
  )
  public_text <- unlist(lapply(public_files, function(file) {
    if (file.exists(file) && !dir.exists(file) &&
        grepl("\\.(R|Rd|Rmd|md)$", file)) {
      readLines(file, warn = FALSE, encoding = "UTF-8")
    } else character()
  }), use.names = FALSE)
  expect_false(any(grepl(
    "mfrmr_gtds3_|MFRMR-GTHEORY-MV-DSIM3-COVERAGE", public_text
  )))
})
