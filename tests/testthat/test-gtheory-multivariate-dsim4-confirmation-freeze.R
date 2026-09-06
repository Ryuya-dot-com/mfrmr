load_gtheory_dsim4f <- local({
  loaded <- NULL
  function() {
    root <- testthat::test_path("..", "..")
    validation <- file.path(root, "inst", "validation")
    controller <- file.path(
      validation,
      "gtheory-multivariate-dsim3-bounded-exploratory-launch-controller-0.2.4.R"
    )
    freeze <- file.path(
      validation,
      "gtheory-multivariate-dsim4-confirmation-freeze-0.2.4.R"
    )
    record <- file.path(
      validation,
      "gtheory-multivariate-dsim4-confirmation-freeze-record-0.2.4.md"
    )
    skip_if_not(
      all(file.exists(c(controller, freeze, record))),
      "repository-internal D-SIM-4 freeze evidence excluded"
    )
    skip_if_not_installed("digest")
    if (is.null(loaded)) {
      probe <- new.env(parent = globalenv())
      sys.source(controller, envir = probe, keep.source = FALSE)
      environment <- new.env(parent = globalenv())
      for (basename in head(probe$mfrmr_gtds3ac_source_basenames(), -1L)) {
        sys.source(file.path(validation, basename), envir = environment,
                   keep.source = FALSE)
      }
      sys.source(
        file.path(
          validation,
          "gtheory-multivariate-dsim3-descriptive-recovery-adjudication-0.2.4.R"
        ), envir = environment, keep.source = FALSE
      )
      sys.source(
        file.path(
          validation,
          "gtheory-multivariate-dsim4-admission-decision-0.2.4.R"
        ), envir = environment, keep.source = FALSE
      )
      sys.source(freeze, envir = environment, keep.source = FALSE)
      loaded <<- list(
        Environment = environment, SourceRoot = root, RecordPath = record
      )
    }
    loaded
  }
})

test_that("D-SIM-4 freezes one minimal role-complete level cover", {
  loaded <- load_gtheory_dsim4f()
  env <- loaded$Environment
  contract <- env$mfrmr_gtds4_contract()
  coverage <- env$mfrmr_gtds3_manifest()
  selected <- env$mfrmr_gtds4_select_scenarios(coverage)
  level_coverage <- env$mfrmr_gtds4_level_coverage(coverage, selected)

  expect_invisible(env$mfrmr_gtds4_validate_contract(contract))
  expect_identical(
    contract$ContractHash,
    "676da443b2b692c444ca5e0b944f4794a4f49f4a55ebd5c6927308abf951296a"
  )
  expect_identical(
    selected$ScenarioId,
    c("D3-S001", "D3-S002", "D3-S003", "D3-S004", "D3-S005", "D3-S018")
  )
  expect_setequal(
    selected$ScenarioRole,
    c("boundary", "closure", "full_anchor", "targeted_structural")
  )
  expect_identical(nrow(level_coverage), 37L)
  expect_true(all(level_coverage$Covered))
  expect_true(all(!selected$SelectionInspectedDsim3Outcome))
  expect_true(all(selected$SelectionWeight == 1))
  expect_identical(sum(selected$IntervalEligible), 2L)
})

test_that("D-SIM-4 freezes precision, interval, and seed identities", {
  env <- load_gtheory_dsim4f()$Environment
  contract <- env$mfrmr_gtds4_contract()
  selected <- env$mfrmr_gtds4_select_scenarios(
    env$mfrmr_gtds3_manifest()
  )
  attempts <- env$mfrmr_gtds4_attempt_registry(selected, contract)

  expect_identical(
    contract$ReplicationContract$OuterReplicateCountPerScenario, 2500L
  )
  expect_equal(
    contract$ReplicationContract$WorstCaseCoverageMcse, 0.01,
    tolerance = 1e-15
  )
  expect_identical(
    contract$IntervalContract$MethodId,
    "full_refit_parametric_bootstrap_percentile_v1"
  )
  expect_identical(contract$IntervalContract$ConfidenceLevel, 0.95)
  expect_identical(contract$IntervalContract$BootstrapReplicateCount, 199L)
  expect_identical(nrow(attempts), 15000L)
  expect_identical(sum(attempts$IntervalEligible), 5000L)
  expect_identical(sum(attempts$InnerBootstrapAttemptCount), 995000L)
  expect_false(anyDuplicated(attempts$DataSeed) > 0L)
  expect_false(anyDuplicated(attempts$BootstrapSeed[
    attempts$IntervalEligible
  ]) > 0L)
  expect_true(all(!attempts$RngStreamOpened))
  expect_true(all(!attempts$ResponseGenerated))
  expect_true(all(!attempts$BackendCallMade))
  expect_true(all(!attempts$ExecutionAuthorized))
  expect_true(all(attempts$TerminalStateCount == 0L))
  expect_true(all(!attempts$ReplacementAllowed))
})

test_that("D-SIM-4 reference formula is independent and guarded", {
  env <- load_gtheory_dsim4f()$Environment
  value <- env$mfrmr_gtds4_reference_coefficient(1, 0.5, 0.25)
  expect_equal(
    value,
    c(`ABS-PHI` = 1 / 1.75, `REL-G` = 1 / 1.5),
    tolerance = 1e-15
  )
  expect_error(
    env$mfrmr_gtds4_reference_coefficient(1, -0.5, 0.25),
    "finite nonnegative"
  )
  expect_error(
    env$mfrmr_gtds4_reference_coefficient(0, 0, 0),
    "denominators must be positive"
  )
  expect_false(
    env$mfrmr_gtds4_contract()$ReferenceContract$IndependentFitBackendClaimed
  )
})

test_that("D-SIM-4 freeze record preserves the execution boundary", {
  loaded <- load_gtheory_dsim4f()
  record <- paste(readLines(loaded$RecordPath, warn = FALSE), collapse = "\n")
  expect_match(record, "14/14 freeze requirements", fixed = TRUE)
  expect_match(record, "15,000 outer attempts", fixed = TRUE)
  expect_match(record, "995,000 inner bootstrap", fixed = TRUE)
  expect_match(record, "D-SIM-5 execution authorized: **no**", fixed = TRUE)
  expect_match(record, "feature maturity: `specified`", fixed = TRUE)
})

test_that("local D-SIM-4 freeze manifest is exact when present", {
  loaded <- load_gtheory_dsim4f()
  env <- loaded$Environment
  path <- file.path(
    loaded$SourceRoot, "validation-results",
    "gtheory-multivariate-dsim4-confirmation-freeze-0.2.4",
    "freeze-manifest.rds"
  )
  if (!file.exists(path)) {
    skip("local D-SIM-4 freeze binary evidence is not present")
  }
  manifest <- readRDS(path)
  expect_invisible(env$mfrmr_gtds4_assert_manifest(manifest))
  expect_identical(
    manifest$ManifestHash,
    "8e8b4b3d4f28a1ac9c94a42fbbdb193aa4979c57bf8a6f2d1a5ecb24ee4d713e"
  )
  expect_true(all(manifest$FreezeRequirementRegistry$Frozen))
  expect_true(manifest$Summary$ConfirmationContractFrozen)
  expect_false(manifest$Summary$Dsim5ExecutionAuthorized)
  expect_false(manifest$Summary$PlannedSeedOpened)
  expect_false(manifest$Summary$ResponseGenerated)
  expect_false(manifest$Summary$SimulationValidationReady)
  expect_false(manifest$Summary$ReferenceValidationReady)
  expect_false(manifest$Summary$PublicSupportReady)
})
