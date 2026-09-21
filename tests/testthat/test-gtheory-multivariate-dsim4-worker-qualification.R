load_gtheory_dsim4w <- local({
  loaded <- NULL
  function() {
    root <- testthat::test_path("..", "..")
    validation <- file.path(root, "inst", "validation")
    controller <- file.path(
      validation,
      "gtheory-multivariate-dsim3-bounded-exploratory-launch-controller-0.2.4.R"
    )
    worker <- file.path(
      validation,
      "gtheory-multivariate-dsim4-worker-qualification-0.2.4.R"
    )
    skip_if_not(all(file.exists(c(controller, worker))),
                "repository-internal D-SIM-4 worker evidence excluded")
    skip_if_not_installed("digest")
    skip_if_not_installed("lme4")
    if (is.null(loaded)) {
      probe <- new.env(parent = globalenv())
      sys.source(controller, envir = probe, keep.source = FALSE)
      environment <- new.env(parent = globalenv())
      for (file in head(probe$mfrmr_gtds3ac_source_basenames(), -1L)) {
        sys.source(file.path(validation, file), envir = environment,
                   keep.source = FALSE)
      }
      for (file in c(
        "gtheory-multivariate-dsim3-descriptive-recovery-adjudication-0.2.4.R",
        "gtheory-multivariate-dsim4-admission-decision-0.2.4.R",
        "gtheory-multivariate-dsim4-confirmation-freeze-0.2.4.R",
        "gtheory-multivariate-dsim4-worker-qualification-0.2.4.R"
      )) {
        sys.source(file.path(validation, file), envir = environment,
                   keep.source = FALSE)
      }
      freeze_path <- file.path(
        root, "validation-results",
        "gtheory-multivariate-dsim4-confirmation-freeze-0.2.4",
        "freeze-manifest.rds"
      )
      freeze <- if (file.exists(freeze_path)) readRDS(freeze_path) else
        environment$mfrmr_gtds4_manifest(
          environment$mfrmr_gtds3_manifest(), root
        )
      loaded <<- list(
        Environment = environment,
        Manifest = environment$mfrmr_gtds4w_manifest(freeze),
        SourceRoot = root,
        RecordPath = file.path(
          validation,
          "gtheory-multivariate-dsim4-worker-qualification-record-0.2.4.md"
        )
      )
    }
    loaded
  }
})

test_that("D-SIM-4 worker reconciles every frozen attempt identity", {
  loaded <- load_gtheory_dsim4w()
  env <- loaded$Environment
  manifest <- loaded$Manifest
  requests <- manifest$OuterRequestRegistry
  blocks <- manifest$InnerBlockRegistry

  expect_invisible(env$mfrmr_gtds4w_assert_manifest(manifest))
  expect_identical(
    manifest$Contract$ContractHash,
    "999e23abd17f017e03f3b2c627d79ddab146dedb9a602feacb08c741350c1999"
  )
  expect_identical(
    manifest$ManifestHash,
    "459abaa38eedfb5ecc8a918d3d1b99cd765867297ab392dd5c896ec276a06f1a"
  )
  expect_identical(
    manifest$InnerIdentityHash,
    "fe14e64b42fadce5a7f47d0706fc04cb38298adafa8a8b5313fb63e9a5759bd8"
  )
  expect_identical(nrow(requests), 15000L)
  expect_identical(nrow(blocks), 5000L)
  expect_identical(sum(blocks$InnerAttemptCount), 995000L)
  expect_identical(blocks$FirstInnerOrdinal[[1L]], 1L)
  expect_identical(tail(blocks$LastInnerOrdinal, 1L), 995000L)
  expect_true(all(blocks$FirstInnerOrdinal[-1L] ==
                    head(blocks$LastInnerOrdinal, -1L) + 1L))
  expect_false(anyDuplicated(requests$RequestHash) > 0L)
  expect_false(anyDuplicated(blocks$InnerBlockHash) > 0L)
  expect_setequal(
    requests$ModelSpecificationId,
    c(
      "separate_univariate::crossed::combined_error",
      "separate_univariate::crossed::separate_error",
      "separate_univariate::nested::combined_error"
    )
  )
  expect_true(all(!requests$DataSeedAccessAuthorized))
  expect_true(all(!requests$BootstrapSeedAccessAuthorized))
  expect_true(all(!requests$ExecutionAuthorized))
})

test_that("D-SIM-4 worker performs the exact 199-refit shadow interval", {
  shadow <- load_gtheory_dsim4w()$Manifest$ShadowQualification

  expect_identical(shadow$ScenarioId, "D3-S001")
  expect_identical(shadow$BootstrapSeed, 854900001L)
  expect_identical(nrow(shadow$PrimaryFitReceipts), 2L)
  expect_identical(nrow(shadow$BootstrapFitReceipts), 398L)
  expect_identical(nrow(shadow$BootstrapMetricRegistry), 796L)
  expect_identical(nrow(shadow$InnerReceiptRegistry), 199L)
  expect_true(all(shadow$BootstrapFitReceipts$FitReturned))
  expect_true(all(shadow$BootstrapFitReceipts$DesignIdentityPreserved))
  expect_true(all(shadow$InnerReceiptRegistry$TerminalState == "success"))
  expect_true(all(shadow$IntervalRegistry$IntervalAvailable))
  expect_true(all(shadow$IntervalRegistry$QuantileType == 7L))
  expect_true(all(
    shadow$PrimaryCoefficients$ReferenceMaximumError <= 1e-10
  ))
  expect_true(shadow$CallerRngStateRestored)
  expect_false(shadow$CountsAsDsim5Attempt)
})

test_that("D-SIM-4 worker keeps failed bootstrap attempts in bounds", {
  manifest <- load_gtheory_dsim4w()$Manifest

  expect_true(all(!manifest$FailureProbeIntervalRegistry$IntervalAvailable))
  expect_true(all(
    manifest$FailureProbeIntervalRegistry$FailedBootstrapRule ==
      "interval_unavailable_outer_attempt_retained"
  ))
  expect_true(all(manifest$GateRegistry$Passed))
  expect_identical(manifest$Summary$ExpectedPrimaryFitCallCount, 32500L)
  expect_identical(manifest$Summary$ExpectedInnerRefitCallCount, 1990000L)
  expect_identical(
    manifest$Summary$ExpectedTotalBackendFitCallCount, 2022500L
  )
  expect_true(manifest$Summary$WorkerQualified)
  expect_true(manifest$Summary$StaticReconciliationReady)
  expect_false(manifest$Summary$Planned857SeedOpened)
  expect_false(manifest$Summary$Planned858SeedOpened)
  expect_false(manifest$Summary$Dsim5ExecutionAuthorized)
  expect_false(manifest$Summary$SimulationValidationReady)
  expect_false(manifest$Summary$PublicSupportReady)
})

test_that("D-SIM-4 worker record preserves its claim ceiling", {
  loaded <- load_gtheory_dsim4w()
  record <- paste(readLines(loaded$RecordPath, warn = FALSE), collapse = "\n")

  expect_match(record, "static reconciliation 10/10", fixed = TRUE)
  expect_match(record, "2,022,500 planned backend fit calls", fixed = TRUE)
  expect_match(record, "D-SIM-5 execution authorized: **no**", fixed = TRUE)
  expect_match(record, loaded$Manifest$ManifestHash, fixed = TRUE)
  expect_match(record, loaded$Manifest$InnerIdentityHash, fixed = TRUE)
})
