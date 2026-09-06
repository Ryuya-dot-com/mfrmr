gtheory_dsim3ac_basenames <- function() {
  c(
    "gtheory-multivariate-package-capability-contract-v4-0.2.4.R",
    "gtheory-multivariate-dsim2-plumbing-smoke-0.2.4.R",
    "gtheory-multivariate-dsim3-coverage-manifest-0.2.4.R",
    "gtheory-multivariate-dsim3-exploratory-execution-contract-0.2.4.R",
    "gtheory-multivariate-dsim3-preexecution-qualification-0.2.4.R",
    "gtheory-multivariate-dsim3-semantic-design-compiler-0.2.4.R",
    "gtheory-multivariate-dsim3-covariance-distribution-binding-0.2.4.R",
    "gtheory-multivariate-dsim3-response-generator-adapter-0.2.4.R",
    "gtheory-multivariate-dsim3-route-receipt-adapter-0.2.4.R",
    paste0(
      "gtheory-multivariate-dsim3-separate-univariate-semantics-audit-",
      "0.2.4.R"
    ),
    paste0(
      "gtheory-multivariate-dsim3-design-dependent-truth-projection-",
      "0.2.4.R"
    ),
    "gtheory-multivariate-dsim3-incidence-allocation-operator-0.2.4.R",
    paste0(
      "gtheory-multivariate-dsim3-separate-univariate-truth-",
      "coefficient-0.2.4.R"
    ),
    "gtheory-multivariate-dsim3-superseding-unopened-plan-0.2.4.R",
    paste0(
      "gtheory-multivariate-dsim3-execution-bridge-request-contract-",
      "0.2.4.R"
    ),
    "gtheory-multivariate-dsim3-fit-metric-worker-0.2.4.R",
    paste0(
      "gtheory-multivariate-dsim3-planned-seed-generation-adapter-",
      "0.2.4.R"
    ),
    paste0(
      "gtheory-multivariate-dsim3-final-launch-readiness-",
      "reconciliation-0.2.4.R"
    ),
    paste0(
      "gtheory-multivariate-dsim3-bounded-exploratory-launch-",
      "controller-0.2.4.R"
    )
  )
}

load_gtheory_dsim3ac <- local({
  environment <- NULL
  function() {
    root <- testthat::test_path("..", "..")
    validation <- file.path(root, "inst", "validation")
    paths <- file.path(validation, gtheory_dsim3ac_basenames())
    worker <- file.path(
      validation,
      paste0(
        "gtheory-multivariate-dsim3-bounded-exploratory-launch-",
        "worker-0.2.4.R"
      )
    )
    skip_if_not(all(file.exists(c(paths, worker))),
                "repository-internal bounded launch excluded")
    for (package in c("digest", "lme4", "processx")) {
      skip_if_not_installed(package)
    }
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) {
        sys.source(path, envir = environment, keep.source = FALSE)
      }
    }
    list(Environment = environment, SourceRoot = root)
  }
})

gtheory_dsim3ac_request <- local({
  request <- NULL
  function(environment) {
    if (is.null(request)) request <<- environment$mfrmr_gtds3x_manifest()
    request
  }
})

test_that("bounded launch contract fixes scope and no-retry semantics", {
  loaded <- load_gtheory_dsim3ac()
  env <- loaded$Environment
  contract <- env$mfrmr_gtds3ac_contract()
  expect_invisible(env$mfrmr_gtds3ac_validate_contract(contract))
  expect_identical(
    contract$ContractHash,
    "5ea53cc09a1261b1b73eac3d72f433273a454aaa1ae7ee6302921c278dd7a642"
  )
  expect_identical(
    c(
      contract$ExpectedDatasetAttemptCount,
      contract$ExpectedCandidateRouteAttemptCount,
      contract$ExpectedMetricRequestCount,
      contract$ExpectedTerminalReceiptCount,
      contract$ExpectedFrozenNoCallRouteCount,
      contract$ExpectedCompleteRouteDenominatorCount,
      contract$ExpectedCoordinateDenominatorCount
    ),
    c(42L, 50L, 100L, 92L, 160L, 210L, 420L)
  )
  expect_true(contract$DatasetProcessIsolationRequired)
  expect_true(contract$AtomicDatasetCheckpointRequired)
  expect_true(contract$ExactCheckpointResumeAllowed)
  expect_false(contract$InterruptedAttemptMayBeReexecuted)
  expect_false(contract$CompletedAttemptMayBeReexecuted)
  expect_false(contract$ReplacementSeedAllowed)
  expect_false(contract$PartialLaunchAllowed)
  expect_false(contract$RecoveryAnalysisDuringLaunchAllowed)
  expect_false(contract$SimulationValidationClaimAllowed)
  expect_false(contract$PublicSupportPromotionAllowed)
})

test_that("bounded launch pins all source identities and resource ceilings", {
  loaded <- load_gtheory_dsim3ac()
  env <- loaded$Environment
  contract <- env$mfrmr_gtds3ac_contract()
  evidence <- env$mfrmr_gtds3ac_evidence_paths(loaded$SourceRoot)
  sources <- env$mfrmr_gtds3ac_source_registry(
    loaded$SourceRoot, contract
  )
  expect_identical(
    names(evidence),
    c("generator", "prior_source", "prior_record", "adapter_source",
      "adapter_record")
  )
  expect_true(all(file.exists(evidence)))
  expect_identical(nrow(sources), 20L)
  expect_identical(
    unname(as.integer(table(sources$SourceRole))), c(1L, 19L)
  )
  expect_true(all(sources$FrozenWorkerIdentityMatch))
  expect_identical(
    contract$ResourceRegistry$MaximumWallSeconds,
    c(300L, 1200L, 120L, 7200L, 172800L)
  )
  expect_identical(
    contract$ResourceRegistry$MaximumPeakRssMiB,
    c(2048L, 8192L, 2048L, 8192L, 8192L)
  )
  expect_true(all(contract$ResourceRegistry$MaximumConcurrentWorkers == 1L))
})

test_that("shadow bridge qualifies fit and metrics without opening 856", {
  loaded <- load_gtheory_dsim3ac()
  env <- loaded$Environment
  set.seed(240831L)
  caller_state <- .Random.seed
  qualification <- env$mfrmr_gtds3ac_shadow_bridge_qualification(
    request_manifest = gtheory_dsim3ac_request(env)
  )
  expect_identical(.Random.seed, caller_state)
  expect_identical(qualification$ScenarioId, "D3-S001")
  expect_identical(qualification$ShadowSeed, 854100001L)
  expect_identical(qualification$FitCallCount, 1L)
  expect_identical(qualification$MetricVectorCount, 2L)
  expect_true(qualification$AllMetricsReady)
  expect_false(qualification$CallerCountsAs856Attempt)
  expect_false(qualification$Planned856RngStreamOpened)
})

test_that("bounded launch record preserves the complete fixed denominator", {
  loaded <- load_gtheory_dsim3ac()
  env <- loaded$Environment
  record_path <- file.path(
    loaded$SourceRoot, "inst", "validation",
    paste0(
      "gtheory-multivariate-dsim3-bounded-exploratory-launch-",
      "record-0.2.4.md"
    )
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  expect_match(
    record,
    "84b89383d974f7a3a40df738b0ce618f86324d3b1ea54ea99ea2ed20a4019aea",
    fixed = TRUE
  )
  expect_match(record, "42/42 registered datasets", fixed = TRUE)
  expect_match(record, "49 `complete_nonpromoting`", fixed = TRUE)
  expect_match(record, "98 `complete_nonpromoting`", fixed = TRUE)
  expect_match(record, "92/92", fixed = TRUE)
  expect_match(record, "D3-S012", fixed = TRUE)
  expect_match(record, "must not be rerun", fixed = TRUE)

  output <- file.path(
    loaded$SourceRoot, "validation-results",
    "gtheory-multivariate-dsim3-bounded-exploratory-launch-0.2.4"
  )
  result_path <- file.path(output, "launch-result.rds")
  input_path <- file.path(output, "launch-input.rds")
  completion_path <- file.path(output, "run-complete.rds")
  if (!all(file.exists(c(result_path, input_path, completion_path)))) {
    skip("local bounded-launch binary evidence is not present")
  }
  manifest <- readRDS(result_path)
  input <- readRDS(input_path)
  completion <- readRDS(completion_path)
  expect_invisible(env$mfrmr_gtds3ac_assert_manifest(manifest, input))
  expect_identical(
    manifest$ManifestHash,
    "84b89383d974f7a3a40df738b0ce618f86324d3b1ea54ea99ea2ed20a4019aea"
  )
  expect_identical(
    unname(as.integer(table(
      manifest$RouteTerminalReceiptRegistry$TerminalState
    ))),
    c(49L, 1L)
  )
  expect_identical(manifest$Summary$ComputedMetricRequestCount, 98L)
  expect_identical(manifest$Summary$TerminalReceiptCount, 92L)
  expect_false(manifest$Summary$RecoveryEvidenceComputed)
  expect_identical(completion$NewCheckpointCount, 42L)
  expect_identical(completion$ResumedCheckpointCount, 0L)
  expect_identical(completion$ParentFailureCheckpointCount, 0L)
})
