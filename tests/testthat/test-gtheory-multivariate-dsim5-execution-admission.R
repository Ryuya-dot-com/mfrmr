load_gtheory_dsim5a <- local({
  value <- NULL
  function() {
    if (is.null(value)) {
      root <- testthat::test_path("..", "..")
      validation <- file.path(root, "inst", "validation")
      sources <- file.path(validation, c(
        "gtheory-multivariate-dsim5-launch-input-0.2.4.R",
        "gtheory-multivariate-dsim5-execution-admission-0.2.4.R"
      ))
      input_path <- file.path(
        root, "validation-results",
        "gtheory-multivariate-dsim5-launch-input-0.2.4",
        "launch-input.rds"
      )
      skip_if_not(all(file.exists(c(sources, input_path))),
                  "repository-internal D-SIM-5 admission excluded")
      skip_if_not_installed("digest")
      environment <- new.env(parent = globalenv())
      for (source in sources) sys.source(source, envir = environment)
      input <- readRDS(input_path)
      value <<- list(
        Environment = environment,
        Input = input,
        Manifest = environment$mfrmr_gtds5a_manifest(input)
      )
    }
    value
  }
})

test_that("D-SIM-5 admission authorizes the complete frozen denominator", {
  loaded <- load_gtheory_dsim5a()
  manifest <- loaded$Manifest
  summary <- manifest$Summary

  expect_invisible(loaded$Environment$mfrmr_gtds5a_assert_manifest(
    manifest, loaded$Input
  ))
  expect_identical(
    manifest$Contract$ContractHash,
    "f0744d6622755bd78489b81665f50d7bf3471548b426e31c22b9a32a67a838a6"
  )
  expect_identical(
    manifest$ManifestHash,
    "8f13db52ad19cbe5adcda0aabb6be6ec8ff949cb555d6043ea1dba0e74972510"
  )
  expect_identical(summary$AdmissionCriterionSatisfiedCount, 8L)
  expect_identical(summary$AuthorizedShardCount, 50L)
  expect_identical(summary$AuthorizedOuterRequestCount, 15000L)
  expect_identical(summary$AuthorizedInnerAttemptCount, 995000L)
  expect_identical(summary$AuthorizedBackendFitCallCount, 2022500L)
  expect_true(summary$FullDenominatorExecutionAdmitted)
  expect_true(summary$Dsim5ExecutionAuthorized)
})

test_that("D-SIM-5 admission forbids interim adaptation and starts nothing", {
  loaded <- load_gtheory_dsim5a()
  manifest <- loaded$Manifest
  contract <- manifest$Contract
  shards <- manifest$AuthorizedShardRegistry

  expect_false(contract$PartialShardSetAuthorizationAllowed)
  expect_false(contract$SequentialOutcomeReviewAllowed)
  expect_false(contract$OutcomeBasedCancellationAllowed)
  expect_false(contract$ReplacementOrReplenishmentAllowed)
  expect_true(contract$CompleteDenominatorRequiredBeforeAdjudication)
  expect_false(manifest$Summary$ExecutionStarted)
  expect_false(manifest$Summary$ResultViewed)
  expect_true(all(shards$ExecutionAuthorized))
  expect_false(any(shards$ExecutionStarted))
  expect_false(any(shards$RngStreamOpened))
  expect_false(any(shards$ResultViewed))

  changed <- manifest
  changed$AuthorizedShardRegistry$ExecutionAuthorized[[1L]] <- FALSE
  expect_error(
    loaded$Environment$mfrmr_gtds5a_assert_manifest(changed, loaded$Input),
    "admission manifest was altered"
  )
})
