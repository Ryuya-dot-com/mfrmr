gtheory_dsim3o_paths <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  file.path(validation, c(
    "gtheory-multivariate-package-capability-contract-v4-0.2.4.R",
    "gtheory-multivariate-dsim2-plumbing-smoke-0.2.4.R",
    "gtheory-multivariate-dsim3-coverage-manifest-0.2.4.R",
    "gtheory-multivariate-dsim3-exploratory-execution-contract-0.2.4.R",
    "gtheory-multivariate-dsim3-preexecution-qualification-0.2.4.R",
    "gtheory-multivariate-dsim3-semantic-design-compiler-0.2.4.R",
    "gtheory-multivariate-dsim3-covariance-distribution-binding-0.2.4.R",
    "gtheory-multivariate-dsim3-response-generator-adapter-0.2.4.R",
    paste0(
      "gtheory-multivariate-dsim3-separate-univariate-semantics-audit-",
      "0.2.4.R"
    ),
    paste0(
      "gtheory-multivariate-dsim3-design-dependent-truth-projection-",
      "0.2.4.R"
    ),
    paste0(
      "gtheory-multivariate-dsim3-incidence-allocation-operator-",
      "0.2.4.R"
    )
  ))
}

load_gtheory_dsim3o <- local({
  environment <- NULL
  function() {
    paths <- gtheory_dsim3o_paths()
    skip_if_not(all(file.exists(paths)),
                "repository-internal D-SIM-3 allocation operator excluded")
    skip_if_not_installed("digest")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = environment)
    }
    environment
  }
})

gtheory_dsim3o_manifest <- local({
  manifest <- NULL
  function(environment) {
    if (is.null(manifest)) {
      manifest <<- environment$mfrmr_gtds3o_manifest()
    }
    manifest
  }
})

test_that("allocation contract binds the qualified truth projection", {
  env <- load_gtheory_dsim3o()
  contract <- env$mfrmr_gtds3o_contract()
  manifest <- gtheory_dsim3o_manifest(env)
  expect_invisible(env$mfrmr_gtds3o_validate_contract(contract))
  expect_invisible(env$mfrmr_gtds3o_assert_manifest(manifest))
  expect_identical(
    contract$ContractHash,
    "89b158391acf18c090ab708d39780499f3fbf3882ec912e04a3e8d775263693a"
  )
  expect_identical(
    manifest$ManifestHash,
    "526298d0c598e34a92e98b96b7bc59c0714fc053636bc25ea423d4c87c895093"
  )
  expect_identical(
    manifest$ParentTruthManifestHash,
    "97d98f649cbc49d646a7f9ac37e8292d8eb1a8ceff4f369b609108d0812189e5"
  )
  expect_identical(contract$RouteId, "separate_univariate")
  expect_false(contract$CrossStratumCovarianceRecovered)
  expect_identical(contract$OffDiagonalPolicy,
                   "exact_zero_not_estimated")
})

test_that("a hand-computed fixture fixes condition and event norms", {
  env <- load_gtheory_dsim3o()
  fixture <- data.frame(
    Stratum = "S",
    ObjectId = rep(c("O1", "O2"), each = 4L),
    ConditionId = rep(rep(c("C1", "C2"), each = 2L), 2L),
    EventId = paste0("E", 1:8),
    ResponseScheduled = c(TRUE, FALSE, TRUE, TRUE,
                          FALSE, TRUE, TRUE, FALSE),
    stringsAsFactors = FALSE
  )
  object <- env$mfrmr_gtds3o_operator_from_assignments(
    fixture, "S", "Object", validate = FALSE
  )
  condition <- env$mfrmr_gtds3o_operator_from_assignments(
    fixture, "S", "Rater", validate = FALSE
  )
  interaction <- env$mfrmr_gtds3o_operator_from_assignments(
    fixture, "S", "Object:Rater", validate = FALSE
  )
  event <- env$mfrmr_gtds3o_operator_from_assignments(
    fixture, "S", "Residual", validate = FALSE
  )
  expect_equal(object$OperatorMatrix[[1L]], 1, tolerance = 1e-12)
  expect_equal(condition$OperatorMatrix[[1L]], 1 / 2,
               tolerance = 1e-12)
  expect_equal(interaction$OperatorMatrix[[1L]], 1 / 2,
               tolerance = 1e-12)
  expect_equal(event$OperatorMatrix[[1L]], 1 / 4,
               tolerance = 1e-12)
  expect_false(condition$PostMissingnessCountUsed)
  expect_false(event$PostMissingnessCountUsed)
})

test_that("all profile component diagonals meet direct allocation formulas", {
  env <- load_gtheory_dsim3o()
  manifest <- gtheory_dsim3o_manifest(env)
  profiles <- manifest$ProfileOperatorRegistry
  operators <- manifest$TargetComponentOperatorRegistry
  diagonals <- manifest$StratumDiagonalOracleRegistry
  expect_identical(nrow(profiles), 21L)
  expect_identical(nrow(operators), 78L)
  expect_identical(nrow(diagonals), 173L)
  expect_true(all(profiles$SeparateUnivariateOperatorQualified))
  expect_true(all(operators$PositiveSemidefinite))
  expect_true(all(operators$OffDiagonalExactZero))
  expect_lte(max(operators$DirectOracleMaximumError), 1e-10)
  expect_lte(max(diagonals$DirectOracleMaximumError), 1e-10)
  expect_false(any(diagonals$PostMissingnessCountUsed))
})

test_that("registered structural allocation ignores missingness and labels", {
  env <- load_gtheory_dsim3o()
  manifest <- gtheory_dsim3o_manifest(env)
  profiles <- manifest$ProfileOperatorRegistry
  operators <- manifest$TargetComponentOperatorRegistry
  expect_true(all(profiles$RowOrderInvariant))
  expect_true(all(profiles$MissingnessMaskInvariant))
  expect_true(all(profiles$IdentityLabelInvariant))
  expect_true(all(operators$RowOrderInvariant))
  expect_true(all(operators$MissingnessMaskInvariant))
  expect_true(all(operators$IdentityLabelInvariant))
})

test_that("anchor profile uses one over k and one over k times repeat", {
  env <- load_gtheory_dsim3o()
  diagonals <- gtheory_dsim3o_manifest(env)$StratumDiagonalOracleRegistry
  anchor <- diagonals$ScenarioId == "D3-S001"
  selected <- diagonals[anchor, ]
  expect_true(all(selected$OperatorDiagonal[
    selected$ComponentClass == "object"
  ] == 1))
  expect_true(all(selected$OperatorDiagonal[
    selected$ComponentClass == "condition"
  ] == 1 / 4))
  expect_true(all(selected$OperatorDiagonal[
    selected$ComponentClass == "event"
  ] == 1 / 8))
})

test_that("legacy global identities fail in the predicted domains", {
  env <- load_gtheory_dsim3o()
  legacy <- gtheory_dsim3o_manifest(env)$LegacyOperatorComparisonRegistry
  condition <- legacy$OperatorClass == "condition"
  event <- legacy$OperatorClass == "event"
  full <- legacy$Crossing == "fully_crossed"
  partial <- legacy$Crossing == "partially_crossed"
  nested <- legacy$Crossing == "nested"
  expect_identical(sum(legacy$LegacyEquivalent[condition]), 21L)
  expect_true(all(legacy$LegacyEquivalent[condition & full]))
  expect_false(any(legacy$LegacyEquivalent[condition & partial]))
  expect_false(any(legacy$LegacyEquivalent[condition & nested]))
  expect_equal(
    legacy$IncidenceToLegacyRatio[condition & partial],
    rep(2, sum(condition & partial)), tolerance = 1e-12
  )
  expect_equal(
    legacy$IncidenceToLegacyRatio[condition & nested],
    legacy$StructuralObjectCount[condition & nested], tolerance = 1e-12
  )
  expect_false(any(legacy$LegacyEquivalent[event]))
  expect_equal(
    legacy$IncidenceToLegacyRatio[event],
    legacy$StructuralObjectCount[event], tolerance = 1e-12
  )
  expect_true(all(legacy$DiagnosisQualified))
})

test_that("operator qualification does not imply coefficient or execution", {
  env <- load_gtheory_dsim3o()
  manifest <- gtheory_dsim3o_manifest(env)
  expect_identical(
    manifest$ReadinessGateRegistry$GatePassed,
    c(rep(TRUE, 8L), FALSE, FALSE)
  )
  expect_true(all(manifest$OpenGapRegistry$GapOpen))
  expect_identical(
    manifest$Summary$CurrentDisposition,
    "separate_univariate_operator_qualified_metric_and_plan_required"
  )
  expect_false(manifest$Summary$Planned855RngStreamOpened)
  expect_false(manifest$Summary$ResponseInspected)
  expect_false(manifest$Summary$BackendCallMade)
  expect_false(manifest$Summary$FitReturned)
  expect_false(manifest$Summary$CoefficientComputed)
  expect_false(manifest$Summary$ExploratoryExecutionAllowed)
  expect_false(manifest$Summary$SimulationValidationReady)
  expect_false(manifest$Summary$PublicSupportReady)
})
