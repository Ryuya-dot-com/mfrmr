gtheory_dsim2_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-decision-simulation-contract-0.2.4.R",
      "gtheory-multivariate-decision-simulation-contract-v2-0.2.4.R",
      "gtheory-multivariate-incidence-preflight-0.2.4.R",
      "gtheory-multivariate-matched-backend-prototype-0.2.4.R",
      "gtheory-multivariate-k-oracle-prototype-0.2.4.R",
      "gtheory-multivariate-ademp-plan-prototype-0.2.4.R",
      "gtheory-multivariate-generator-preflight-0.2.4.R",
      "gtheory-multivariate-package-capability-contract-v4-0.2.4.R",
      "gtheory-multivariate-dsim1-deterministic-qualification-0.2.4.R",
      "gtheory-multivariate-dsim2-plumbing-smoke-0.2.4.R"
    )
  )
}

load_gtheory_dsim2 <- local({
  environment <- NULL
  function() {
    paths <- gtheory_dsim2_paths()
    skip_if_not(all(file.exists(paths)),
                "repository-internal D-SIM-2 artifacts are excluded")
    skip_if_not_installed("digest")
    skip_if_not_installed("lme4")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = environment)
    }
    environment
  }
})

gtheory_dsim2_objects <- local({
  objects <- NULL
  function(environment) {
    if (is.null(objects)) {
      plan <- environment$mfrmr_gtvd_plan()
      objects <<- list(
        plan = plan,
        registry = environment$mfrmr_gtve_fixture_registry(plan)
      )
    }
    objects
  }
})

gtheory_dsim2_result <- local({
  result <- NULL
  function(environment, objects) {
    if (is.null(result)) {
      result <<- environment$mfrmr_gtds2_run(
        objects$plan, objects$registry
      )
    }
    result
  }
})

gtheory_dsim2_stage_fixture <- function(status) {
  data.frame(
    StageOrdinal = 1:3,
    StageId = c("generator", "fit", "metric"),
    StageStatus = status,
    ArtifactHash = rep(NA_character_, 3L),
    ErrorClass = rep("", 3L), ErrorMessage = rep("", 3L),
    stringsAsFactors = FALSE
  )
}

test_that("D-SIM-2 freezes one narrow nonreserved route", {
  env <- load_gtheory_dsim2()
  contract <- env$mfrmr_gtds2_contract()
  expect_invisible(env$mfrmr_gtds2_validate_contract(contract))
  expect_s3_class(contract, "mfrmr_gtds2_contract")
  expect_identical(
    contract$ContractHash,
    "5202fcbe1975c3fc898f557b06c50f6fdcbb1cd248b745eb4500d42b163d960b"
  )
  expect_identical(contract$FixtureId, "FX-C1-I2-BAL")
  expect_identical(contract$DesignId, "S2-SHARED-DISTINCT-C1")
  expect_false(contract$CanonicalDsim1Anchor)
  expect_identical(contract$Backend, "lme4")
  expect_identical(contract$Criterion, "REML")
  expect_identical(contract$AttemptLimit, 1L)
  expect_false(contract$AutomaticScenarioExpansionAllowed)
  expect_false(contract$BackendComparisonAllowed)
  expect_false(contract$TruthRecoveryComparisonAllowed)
  expect_false(contract$PlannedRngStreamAllowed)
  expect_false(contract$SimulationValidationClaimAllowed)
  expect_false(contract$PublicSupportPromotionAllowed)
})

test_that("D-SIM-2 terminal states count every admissible failure", {
  env <- load_gtheory_dsim2()
  classify <- env$mfrmr_gtds2_terminal_state
  expect_identical(
    classify(gtheory_dsim2_stage_fixture(rep("completed", 3L))),
    "plumbing_complete_nonpromoting"
  )
  expect_identical(classify(gtheory_dsim2_stage_fixture(c(
    "failed", "not_attempted_dependency", "not_attempted_dependency"
  ))), "generator_failure")
  expect_identical(classify(gtheory_dsim2_stage_fixture(c(
    "completed", "failed", "not_attempted_dependency"
  ))), "fit_failure")
  expect_identical(classify(gtheory_dsim2_stage_fixture(c(
    "completed", "completed", "failed"
  ))), "metric_failure")
  expect_error(classify(gtheory_dsim2_stage_fixture(c(
    "failed", "completed", "completed"
  ))), "impossible or outcome-dropped")
})

test_that("D-SIM-2 traverses generator fit metric and terminal state", {
  env <- load_gtheory_dsim2()
  objects <- gtheory_dsim2_objects(env)
  result <- gtheory_dsim2_result(env, objects)
  expect_invisible(env$mfrmr_gtds2_assert_run(result))
  expect_s3_class(result, "mfrmr_gtds2_run")
  expect_match(result$RunHash, "^[0-9a-f]{64}$")
  expect_identical(
    result$Summary$TerminalState, "plumbing_complete_nonpromoting"
  )
  expect_identical(result$Summary$AttemptCount, 1L)
  expect_true(result$Summary$AttemptTerminallyCounted)
  expect_true(result$Summary$StochasticNonreservedFixtureGenerated)
  expect_true(result$Summary$FitExecuted)
  expect_true(result$Summary$MetricComputed)
  expect_true(result$Summary$Dsim2Satisfied)
  expect_true(result$Summary$BoundedInternalRouteImplemented)
  expect_true(result$Summary$Dsim3DesignConstructionAllowed)
  expect_false(result$Summary$Dsim3ExecutionAllowed)
  expect_identical(result$Summary$FeatureMaturity, "specified")
  expect_identical(result$Stages$StageStatus, rep("completed", 4L))
  expect_false(result$GenerationReceipt$PlanSeedCollision)
  expect_false(result$GenerationReceipt$PlannedRngStreamOpened)
  expect_false(result$GenerationReceipt$TruthReleasedDownstream)
  expect_identical(result$FitReceipt$SharedObservationLinks, 0L)
  expect_identical(result$FitReceipt$FitStatus, "identified_point_fit")
  expect_true(is.finite(result$MetricReceipt$G))
  expect_true(is.finite(result$MetricReceipt$Phi))
  expect_true(result$MetricReceipt$PhiNotGreaterThanG)
  expect_false(result$MetricReceipt$TruthCompared)
  expect_false(result$MetricReceipt$TargetCompared)
  expect_false(result$MetricReceipt$MetricPromotable)
})

test_that("D-SIM-2 replay preserves semantic identities", {
  env <- load_gtheory_dsim2()
  objects <- gtheory_dsim2_objects(env)
  first <- gtheory_dsim2_result(env, objects)
  replay <- env$mfrmr_gtds2_run(objects$plan, objects$registry)
  expect_identical(replay$RunHash, first$RunHash)
  expect_identical(
    replay$GenerationReceipt$ReceiptHash,
    first$GenerationReceipt$ReceiptHash
  )
  expect_identical(replay$FitReceipt$ReceiptHash,
                   first$FitReceipt$ReceiptHash)
  expect_identical(
    replay$MetricReceipt$MetricReceiptHash,
    first$MetricReceipt$MetricReceiptHash
  )
  expect_identical(replay$MetricReceipt$G, first$MetricReceipt$G)
  expect_identical(replay$MetricReceipt$Phi, first$MetricReceipt$Phi)
})

test_that("D-SIM-2 rejects self-promotion and altered stage state", {
  env <- load_gtheory_dsim2()
  objects <- gtheory_dsim2_objects(env)
  result <- gtheory_dsim2_result(env, objects)
  promoted <- result
  promoted$Summary$PublicSupportReady <- TRUE
  promoted$RunHash <- env$mfrmr_gtds2_hash(
    promoted[env$mfrmr_gtds2_run_payload_fields()]
  )
  expect_error(env$mfrmr_gtds2_assert_run(promoted),
               "result or readiness was altered")

  dropped <- result
  dropped$Stages$StageStatus[[2L]] <- "failed"
  dropped$Stages$StageStatus[[3L]] <- "completed"
  dropped$RunHash <- env$mfrmr_gtds2_hash(
    dropped[env$mfrmr_gtds2_run_payload_fields()]
  )
  expect_error(env$mfrmr_gtds2_assert_run(dropped),
               "impossible or outcome-dropped")

  changed_contract <- env$mfrmr_gtds2_contract()
  changed_contract$AttemptLimit <- 2L
  expect_error(env$mfrmr_gtds2_validate_contract(changed_contract),
               "invalid or altered")
})

test_that("D-SIM-2 internal symbols remain outside public package surfaces", {
  public_files <- c(
    list.files(testthat::test_path("..", "..", "R"), recursive = TRUE,
               full.names = TRUE),
    list.files(testthat::test_path("..", "..", "man"), recursive = TRUE,
               full.names = TRUE),
    list.files(testthat::test_path("..", "..", "vignettes"), recursive = TRUE,
               full.names = TRUE),
    testthat::test_path("..", "..", "ROADMAP.md")
  )
  public_text <- unlist(lapply(public_files, function(file) {
    if (file.exists(file) && !dir.exists(file) &&
        grepl("\\.(R|Rd|Rmd|md)$", file)) {
      readLines(file, warn = FALSE, encoding = "UTF-8")
    } else character()
  }), use.names = FALSE)
  expect_false(any(grepl(
    "mfrmr_gtds2_|MFRMR-GTHEORY-MV-DSIM2-PLUMBING", public_text
  )))
})
