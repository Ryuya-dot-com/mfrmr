gtheory_weak_information_bootstrap_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-balanced-estimation-prototype-0.2.3.R",
      "gtheory-design-incidence-audit-0.2.3.R",
      "gtheory-covariance-information-audit-0.2.3.R",
      "gtheory-glmmtmb-parity-prototype-0.2.3.R",
      "gtheory-ademp-registry-prototype-0.2.3.R",
      "gtheory-ademp-generator-prototype-0.2.3.R",
      "gtheory-ademp-prefit-prototype-0.2.3.R",
      "gtheory-ademp-fit-prototype-0.2.3.R",
      "gtheory-weak-information-calibration-prototype-0.2.3.R",
      "gtheory-weak-information-pilot-prototype-0.2.3.R",
      "gtheory-weak-information-diagnostic-refit-prototype-0.2.3.R",
      "gtheory-weak-information-bootstrap-prototype-0.2.3.R"
    )
  )
}

load_gtheory_weak_information_bootstrap <- function() {
  paths <- gtheory_weak_information_bootstrap_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  skip_if_not_installed("digest")
  skip_if_not_installed("lme4")
  skip_if_not_installed("glmmTMB")
  skip_if_not_installed("TMB")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

test_that("Draft.83d2b2b1b separates mechanics from inferential calibration", {
  env <- load_gtheory_weak_information_bootstrap()
  contract <- env$mfrmr_gtwb_contract()

  expect_s3_class(contract, "mfrmr_gtwb_contract")
  expect_true(contract$MechanicsSchemaAuthorized)
  expect_false(contract$ExactFiniteSampleTest)
  expect_false(contract$ShrinkedParametricBootstrapImplemented)
  expect_equal(contract$BootstrapReplicates, 3L)
  expect_equal(contract$ObservedRouteCount, 12L)
  expect_equal(contract$BootstrapPairCount, 36L)
  expect_equal(contract$SchemaFitCount, 96L)
  expect_equal(contract$MonteCarloGridWidth, 0.25)
  expect_equal(contract$ResolutionFeasibilityRows, 3000L)
  expect_equal(contract$ResolutionFeasibilityFitCount, 6000L)
  expect_equal(contract$NaiveNestedBootstrapFitCountB199, 1200000L)
  expect_false(contract$ResolutionFeasibilityAuthorized)
  expect_false(contract$BootstrapOperatingCharacteristicsReady)
  expect_false(contract$InferenceReady)
  expect_false(contract$DecisionReady)
})

test_that("Draft.83d2b2b1b manifest has exact routes and seed separation", {
  env <- load_gtheory_weak_information_bootstrap()
  contract <- env$mfrmr_gtwb_contract()
  manifest <- env$mfrmr_gtwb_manifest(contract)

  expect_s3_class(manifest, "mfrmr_gtwb_manifest")
  expect_equal(nrow(manifest$ParentRoutes), 12L)
  expect_equal(nrow(manifest$BootstrapRows), 36L)
  expect_equal(length(unique(manifest$ParentRoutes$ScenarioId)), 3L)
  expect_equal(length(unique(manifest$ParentRoutes$MethodId)), 4L)
  expect_true(all(manifest$ParentRoutes$Replicate == 2L))
  expect_equal(
    as.integer(table(manifest$BootstrapRows$ParentRouteId)),
    rep(3L, 12L)
  )
  expect_equal(anyDuplicated(manifest$BootstrapRows$BootstrapSeed), 0L)
  expect_true(all(manifest$BootstrapRows$BootstrapSeed >= 832300000L))
  expect_true(all(manifest$BootstrapRows$BootstrapIndex %in% 1:3))
})

test_that("Draft.83d2b2b1b plus-one bounds retain failed draws", {
  env <- load_gtheory_weak_information_bootstrap()
  complete <- env$mfrmr_gtwb_p_bounds(
    1, c(2, 0, 0.5), c(TRUE, TRUE, TRUE), 3L
  )
  failed <- env$mfrmr_gtwb_p_bounds(
    1, c(2, NA, 0.5), c(TRUE, FALSE, TRUE), 3L
  )

  expect_equal(complete$ExceedanceCount, 1L)
  expect_equal(complete$FailureCount, 0L)
  expect_equal(complete$PLower, 0.5)
  expect_equal(complete$PUpper, 0.5)
  expect_equal(complete$PPoint, 0.5)
  expect_equal(failed$ExceedanceCount, 1L)
  expect_equal(failed$FailureCount, 1L)
  expect_equal(failed$PLower, 0.5)
  expect_equal(failed$PUpper, 0.75)
  expect_true(is.na(failed$PPoint))
  expect_equal(failed$GridWidth, 0.25)
  expect_error(
    env$mfrmr_gtwb_p_bounds(1, c(2, 0), c(TRUE, TRUE), 3L),
    "every planned bootstrap row"
  )
})

test_that("Draft.83d2b2b1b contract records source and nonclaim boundaries", {
  path <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-weak-information-bootstrap-contract-0.2.3.md"
  )
  skip_if_not(file.exists(path),
              "repository-internal validation artifacts are excluded")
  text <- paste(readLines(path, warn = FALSE), collapse = "\n")

  expect_match(text, "lme4.github.io/lme4/reference/bootMer.html", fixed = TRUE)
  expect_match(text, "glmmtmb.github.io/glmmTMB/articles/sim.html", fixed = TRUE)
  expect_match(text, "10.2202/1544-6115.1585", fixed = TRUE)
  expect_match(text, "arxiv.org/abs/2306.10779", fixed = TRUE)
  expect_match(text, "arxiv.org/abs/2604.25744", fixed = TRUE)
  expect_match(text, "does not mean an exact finite-\nsample test", fixed = TRUE)
  expect_match(text, "failed draws count\nin the denominator", fixed = TRUE)
  expect_match(text, "1{,}200{,}000", fixed = TRUE)
})

test_that("Draft.83d2b2b1b native simulations are deterministic exact-design draws", {
  env <- load_gtheory_weak_information_bootstrap()
  registry <- env$mfrmr_gtw_registry()
  generation <- env$mfrmr_gtw_generate(
    registry, "GT-WI-baseline_complete-reference_1200", 2L
  )
  prefit <- env$mfrmr_gtd3_prefit_one(generation)
  original <- prefit$StructuralRankAudit$PreparedData$Data
  original_design <- env$mfrmr_gtwb_design_hash(
    original, generation$Spec$ScoreColumn
  )

  for (method in c("lme4_ml", "glmmTMB_reml")) {
    backend <- if (grepl("^lme4", method)) "lme4" else "glmmTMB"
    pair <- env$mfrmr_gtwd_diagnostic_pair(generation, prefit, method)
    first <- env$mfrmr_gtwb_simulate_null(
      pair$ReducedFit, backend, 832399901L, nrow(original)
    )
    repeated <- env$mfrmr_gtwb_simulate_null(
      pair$ReducedFit, backend, 832399901L, nrow(original)
    )
    different <- env$mfrmr_gtwb_simulate_null(
      pair$ReducedFit, backend, 832399902L, nrow(original)
    )
    cloned <- env$mfrmr_gtwb_clone_unit(
      generation, prefit, first, 832399901L,
      paste0("test::", method), 1L
    )

    expect_identical(first, repeated)
    expect_false(isTRUE(all.equal(first, different)))
    expect_equal(length(first), nrow(original))
    expect_identical(cloned$DesignHash, original_design)
    expect_false(identical(cloned$DataHash, env$mfrmr_gta_hash(original)))
    expect_true(cloned$ExactDesignPreserved)
    factor_columns <- names(original)[vapply(original, is.factor, logical(1L))]
    expect_identical(
      lapply(cloned$Data[factor_columns], levels),
      lapply(original[factor_columns], levels)
    )
  }
})

test_that("Draft.83d2b2b1b executes only the 96-fit mechanics schema", {
  skip_if_not(
    identical(Sys.getenv("MFRMR_RUN_GTHEORY_BOOTSTRAP_SCHEMA"), "true"),
    "the 96-fit bootstrap mechanics schema is an explicit validation tier"
  )
  env <- load_gtheory_weak_information_bootstrap()
  result <- env$mfrmr_gtwb_execute_schema(progress = FALSE)

  expect_s3_class(result, "mfrmr_gtwb_schema_execution")
  expect_equal(result$PlannedObservedRoutes, 12L)
  expect_equal(result$PlannedBootstrapPairs, 36L)
  expect_equal(result$PlannedFitCount, 96L)
  expect_equal(nrow(result$MonteCarloBounds), 12L)
  expect_true(result$ExactAccountingPassed)
  expect_true(result$ExactDesignIdentityPassed)
  expect_true(result$MechanicsSchemaEvidenceReady)
  expect_true(all(result$BootstrapRows$SameRows[
    result$BootstrapRows$PairReturned
  ]))
  expect_true(all(result$BootstrapRows$LikelihoodDfDifference[
    result$BootstrapRows$PairReturned
  ] == 1L))
  expect_true(all(result$MonteCarloBounds$GridWidth == 0.25))
  expect_equal(
    result$MonteCarloBounds$FailureCount,
    as.integer(tapply(
      !result$BootstrapRows$BootstrapStatisticAvailable,
      result$BootstrapRows$ParentRouteId, sum
    )[result$MonteCarloBounds$ParentRouteId])
  )
  expect_false(result$BootstrapOperatingCharacteristicsReady)
  expect_false(result$InferenceReady)
  expect_false(result$DecisionReady)
})
