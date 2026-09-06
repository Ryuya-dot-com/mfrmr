gtheory_dsim3q_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-multivariate-package-capability-contract-v4-0.2.4.R",
      "gtheory-multivariate-dsim2-plumbing-smoke-0.2.4.R",
      "gtheory-multivariate-dsim3-coverage-manifest-0.2.4.R",
      "gtheory-multivariate-dsim3-exploratory-execution-contract-0.2.4.R",
      "gtheory-multivariate-dsim3-preexecution-qualification-0.2.4.R"
    )
  )
}

load_gtheory_dsim3q <- local({
  environment <- NULL
  function() {
    paths <- gtheory_dsim3q_paths()
    skip_if_not(all(file.exists(paths)),
                "repository-internal D-SIM-3 qualification excluded")
    skip_if_not_installed("digest")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = environment)
    }
    environment
  }
})

gtheory_dsim3q_manifest <- local({
  manifest <- NULL
  function(environment) {
    if (is.null(manifest)) manifest <<- environment$mfrmr_gtds3q_manifest()
    manifest
  }
})

test_that("pre-execution qualification is package-scoped and nonexecuting", {
  env <- load_gtheory_dsim3q()
  contract <- env$mfrmr_gtds3q_contract()
  expect_invisible(env$mfrmr_gtds3q_validate_contract(contract))
  expect_s3_class(contract, "mfrmr_gtds3q_contract")
  expect_identical(
    contract$ContractHash,
    "00cf1c34c0d3e70e4b2896b365f5592e04b00ef63bc6dede35d9bfc3bd94f762"
  )
  expect_identical(
    contract$ParentExecutionPlanHash,
    "b91ab4229203efc15a3ca9421256d81ae7331143e42f845b5c6a879575552de7"
  )
  expect_identical(contract$ExpectedProfileQualificationCount, 21L)
  expect_identical(contract$ExpectedGeneratorLevelQualificationCount, 37L)
  expect_identical(contract$ExpectedCandidateRouteQualificationCount, 50L)
  expect_identical(contract$ExpectedTerminalStateQualificationCount, 13L)
  expect_identical(contract$ExpectedResourceScopeQualificationCount, 5L)
  expect_true(contract$FullProfileQualificationRequired)
  expect_true(contract$AllCandidateRoutesQualificationRequired)
  expect_true(contract$AllTerminalStatesQualificationRequired)
  expect_true(contract$AllResourceScopesQualificationRequired)
  expect_false(contract$PartialExecutionAllowed)
  expect_false(contract$ScenarioSpecificExceptionAllowed)
  expect_false(contract$OperationalOwnerAuthorizationRequired)
  expect_false(contract$ExternalFreezeReceiptRequired)
  expect_false(contract$SubstantiveTargetRequired)
  expect_false(contract$QualificationAuditMayUseRng)
  expect_false(contract$QualificationAuditMayGenerateResponses)
  expect_false(contract$QualificationAuditMayCallBackend)
  expect_false(contract$ExploratoryExecutionCurrentlyAllowed)
  expect_false(contract$PublicSupportPromotionAllowed)
})

test_that("qualification separates reusable primitives from exact binding", {
  env <- load_gtheory_dsim3q()
  manifest <- gtheory_dsim3q_manifest(env)
  levels <- manifest$GeneratorLevelQualificationRegistry
  profiles <- manifest$ProfileQualificationRegistry
  expect_invisible(env$mfrmr_gtds3q_assert_manifest(manifest))
  expect_identical(nrow(levels), 37L)
  expect_identical(sum(levels$LegacyPrimitiveAvailable), 18L)
  expect_identical(sum(levels$ExactDsim3AxisLevelBindingReady), 0L)
  expect_identical(nrow(profiles), 21L)
  expect_identical(sum(profiles$GeneratorSemanticsQualified), 0L)
  expect_true(all(profiles$LegacyPrimitiveGapCount >= 2L))
  expect_true(all(grepl(
    "object_count=", profiles$LegacyPrimitiveGapLevels, fixed = TRUE
  )))
  expect_true(all(grepl(
    "rater_count=", profiles$LegacyPrimitiveGapLevels, fixed = TRUE
  )))
  anchor <- profiles[profiles$ScenarioId == "D3-S001", , drop = FALSE]
  expect_identical(anchor$LegacyPrimitiveGapCount, 2L)
  expect_identical(
    anchor$LegacyPrimitiveGapLevels, "object_count=200;rater_count=4"
  )
  expect_true(all(!profiles$FullProfileCompilerReady))
  expect_true(all(!profiles$ExactRowEventIdentityReady))
  expect_true(all(!profiles$ExactCovarianceFactorBindingReady))
  expect_true(all(!profiles$ExactDistributionBindingReady))
  expect_true(all(!profiles$ExecutionSelected))
  expect_true(all(!profiles$RngStreamOpened))
  expect_true(all(!profiles$ResponseGenerated))
})

test_that("all 50 candidate route units remain honestly unqualified", {
  env <- load_gtheory_dsim3q()
  routes <- gtheory_dsim3q_manifest(env)$CandidateRouteQualificationRegistry
  expect_identical(nrow(routes), 50L)
  expect_identical(
    as.integer(table(factor(
      routes$RouteId,
      levels = c("multivariate_lme4_restricted", "separate_univariate")
    ))), c(8L, 42L)
  )
  expect_identical(sum(routes$LegacyDatasetFitAdapterAvailable), 8L)
  expect_true(all(routes$LegacyFitOrAlgebraEvidenceAvailable))
  expect_true(all(!routes$GeneratorDependencyQualified))
  expect_true(all(!routes$ExactScenarioRouteAdapterReady))
  expect_true(all(!routes$Dsim3TerminalReceiptBindingReady))
  expect_true(all(!routes$Dsim3ResourceEnforcementReady))
  expect_true(all(!routes$RouteUnitQualified))
  expect_true(all(!routes$ExecutionSelected))
  expect_true(all(!routes$BackendCallMade))
  expect_true(all(!routes$FitExecuted))
})

test_that("terminal resource and control qualifications remain explicit", {
  env <- load_gtheory_dsim3q()
  manifest <- gtheory_dsim3q_manifest(env)
  terminals <- manifest$TerminalQualificationRegistry
  resources <- manifest$ResourceQualificationRegistry
  controls <- manifest$ControlQualificationRegistry
  expect_identical(nrow(terminals), 13L)
  expect_true(all(terminals$SemanticStateDefined))
  expect_identical(
    sum(terminals$LegacyStateOrAssertionEvidenceAvailable), 7L
  )
  expect_true(all(!terminals$GenericDsim3ReceiptSchemaReady))
  expect_true(all(!terminals$ResourceMetadataBound))
  expect_true(all(!terminals$ExactOneReceiptValidatorReady))
  expect_true(all(!terminals$TerminalStateQualified))
  expect_identical(nrow(resources), 5L)
  expect_true(all(resources$LimitContractDefined))
  expect_true(all(!resources$WallTimeoutEnforcementReady))
  expect_true(all(!resources$PeakRssEnforcementReady))
  expect_true(all(!resources$ExceedanceReceiptReady))
  expect_true(all(!resources$ResourceScopeQualified))
  expect_identical(nrow(controls), 3L)
  expect_true(all(controls$DeterministicRuleQualified))
  expect_identical(sum(controls$ControlQualifiedForPreExecution), 2L)
  expect_true(all(!controls$RngStreamRequired))
  expect_true(all(!controls$ExecutionSelected))
})

test_that("qualification audit does not disturb caller RNG state", {
  env <- load_gtheory_dsim3q()
  set.seed(240831L)
  caller_state <- .Random.seed
  manifest <- env$mfrmr_gtds3q_manifest()
  expect_identical(.Random.seed, caller_state)
  expect_false(manifest$Summary$RngStreamOpened)
  expect_false(manifest$Summary$ResponseGenerated)
  expect_false(manifest$Summary$BackendCallMade)
  expect_false(manifest$Summary$FitExecuted)
})

test_that("qualification audit completes as an evidence-bounded no-go", {
  env <- load_gtheory_dsim3q()
  manifest <- gtheory_dsim3q_manifest(env)
  expect_identical(
    manifest$ManifestHash,
    "05d5bf2bfb0942ddb728aff31dce69de7298065081f3f268e18943074cd96755"
  )
  expect_true(manifest$Summary$QualificationAuditComplete)
  expect_false(manifest$Summary$AllExecutionPrerequisitesQualified)
  expect_false(manifest$Summary$ExploratoryExecutionAllowed)
  expect_false(manifest$Summary$PartialExecutionAllowed)
  expect_false(manifest$Summary$ScenarioSpecificExceptionAllowed)
  expect_false(manifest$Summary$ExploratoryResultAvailable)
  expect_false(manifest$Summary$SimulationValidationReady)
  expect_false(manifest$Summary$ReferenceValidationReady)
  expect_false(manifest$Summary$InferenceReady)
  expect_false(manifest$Summary$DecisionReady)
  expect_false(manifest$Summary$PublicSupportReady)
  expect_identical(manifest$Summary$FeatureMaturity, "specified")
  expect_match(manifest$Summary$NextAction, "one shared D-SIM-3", fixed = TRUE)
  expect_match(manifest$Summary$NextAction, "do not patch individual scenarios",
               fixed = TRUE)
})

test_that("qualification replay is exact and mutations fail closed", {
  env <- load_gtheory_dsim3q()
  first <- gtheory_dsim3q_manifest(env)
  replay <- env$mfrmr_gtds3q_manifest()
  expect_identical(replay$ManifestHash, first$ManifestHash)
  expect_identical(replay$ProfileQualificationRegistry,
                   first$ProfileQualificationRegistry)
  expect_identical(replay$CandidateRouteQualificationRegistry,
                   first$CandidateRouteQualificationRegistry)

  promoted <- first
  promoted$Summary$ExploratoryExecutionAllowed <- TRUE
  promoted$ManifestHash <- env$mfrmr_gtds3q_hash(
    promoted[env$mfrmr_gtds3q_payload_fields()]
  )
  expect_error(env$mfrmr_gtds3q_assert_manifest(promoted),
               "manifest was altered")

  qualified <- first
  qualified$ProfileQualificationRegistry$GeneratorSemanticsQualified[[1L]] <-
    TRUE
  qualified$ManifestHash <- env$mfrmr_gtds3q_hash(
    qualified[env$mfrmr_gtds3q_payload_fields()]
  )
  expect_error(env$mfrmr_gtds3q_assert_manifest(qualified),
               "manifest was altered")

  dropped <- first
  dropped$CandidateRouteQualificationRegistry <-
    dropped$CandidateRouteQualificationRegistry[-1L, , drop = FALSE]
  dropped$ManifestHash <- env$mfrmr_gtds3q_hash(
    dropped[env$mfrmr_gtds3q_payload_fields()]
  )
  expect_error(env$mfrmr_gtds3q_assert_manifest(dropped),
               "manifest was altered")

  changed_contract <- env$mfrmr_gtds3q_contract()
  changed_contract$PartialExecutionAllowed <- TRUE
  expect_error(env$mfrmr_gtds3q_validate_contract(changed_contract),
               "contract is invalid")
})

test_that("qualification symbols remain outside public package surfaces", {
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
    "mfrmr_gtds3q_|MFRMR-GTHEORY-MV-DSIM3-PREEXEC-QUALIFICATION",
    public_text
  )))
})
