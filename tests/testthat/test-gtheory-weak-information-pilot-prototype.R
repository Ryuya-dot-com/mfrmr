gtheory_weak_information_pilot_paths <- function() {
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
      "gtheory-weak-information-pilot-prototype-0.2.3.R"
    )
  )
}

load_gtheory_weak_information_pilot <- function() {
  paths <- gtheory_weak_information_pilot_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  skip_if_not_installed("digest")
  skip_if_not_installed("lme4")
  skip_if_not_installed("glmmTMB")
  skip_if_not_installed("TMB")
  if (!requireNamespace("reformulas", quietly = TRUE) &&
      !requireNamespace("lme4", quietly = TRUE)) {
    skip("Draft.81 formula parser requires reformulas or lme4")
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

test_that("Draft.83d2b2b0 freezes phase sizes and MC precision", {
  env <- load_gtheory_weak_information_pilot()
  plan <- env$mfrmr_gtwp_plan()
  phases <- plan$PhaseTable

  expect_s3_class(plan, "mfrmr_gtwp_plan")
  expect_identical(
    phases$PhaseId,
    c("schema_smoke", "feasibility_pilot", "calibration_pilot",
      "confirmation")
  )
  expect_identical(phases$ReplicateStart, c(2L, 101L, 201L, 501L))
  expect_identical(phases$ReplicateEnd, c(3L, 125L, 300L, 700L))
  expect_identical(phases$ReplicationsPerCell, c(2L, 25L, 100L, 200L))
  expect_identical(phases$PlannedUnits, c(24L, 3000L, 12000L, 24000L))
  expect_equal(
    phases$WorstCaseBernoulliMCSEPerCellMethod,
    sqrt(0.25 / c(2, 25, 100, 200)), tolerance = 1e-15
  )
  expect_identical(phases$ExecutionAuthorized,
                   c(TRUE, TRUE, FALSE, FALSE))
  expect_identical(phases$RuleSelectionPermitted,
                   c(FALSE, FALSE, TRUE, FALSE))
  expect_identical(
    plan$PlanHash,
    "427addf42c73047e184857f52e9aa126e6d5eb346ab105827d14b3affef38cbd"
  )
  expect_false(plan$ThresholdFrozen)
  expect_false(plan$ConfirmationAuthorized)
  expect_false(plan$ConfirmationViewed)
  expect_false(plan$DecisionReady)
})

test_that("Draft.83d2b2b0 manifests preserve seed and authorization firewalls", {
  env <- load_gtheory_weak_information_pilot()
  plan <- env$mfrmr_gtwp_plan()
  manifests <- lapply(plan$PhaseTable$PhaseId, function(phase) {
    env$mfrmr_gtwp_manifest(plan, phase)
  })
  names(manifests) <- plan$PhaseTable$PhaseId

  expect_identical(vapply(manifests, `[[`, integer(1L), "PlannedUnits"),
                   c(schema_smoke = 24L, feasibility_pilot = 3000L,
                     calibration_pilot = 12000L, confirmation = 24000L))
  expect_identical(vapply(manifests, `[[`, integer(1L),
                                    "IndependentDatasetCount"),
                   c(schema_smoke = 6L, feasibility_pilot = 750L,
                     calibration_pilot = 3000L, confirmation = 6000L))
  expect_true(all(vapply(manifests, `[[`, logical(1L), "PhaseComplete")))
  expect_identical(manifests$schema_smoke$ManifestHash,
                   "8962be56cad3f4a3bc3e77a1ee2a5621857900e9d554ac099dfbaf4c26651a72")
  expect_identical(manifests$feasibility_pilot$ManifestHash,
                   "ba2beeffee6128b6d920a2c3ad52f2ab1065e3263f380fa7cbfa186b1cadf8ef")
  expect_identical(manifests$calibration_pilot$ManifestHash,
                   "85d3ee963e93adfcc1d0bf505b1c34b1486f3eebfc605cf687a8e79240431676")
  expect_identical(manifests$confirmation$ManifestHash,
                   "7a7e9cca9065f088a93b6c2b16cdaa3340209db9e5b3aa0160a0b227b3d3af3b")

  dataset_seeds <- unlist(lapply(manifests, function(manifest) {
    rows <- manifest$Rows[!duplicated(manifest$Rows$DatasetId), ]
    stats::setNames(rows$Seed, rows$DatasetId)
  }))
  expect_identical(anyDuplicated(unname(dataset_seeds)), 0L)
  expect_lt(max(manifests$schema_smoke$Rows$Replicate),
            min(manifests$feasibility_pilot$Rows$Replicate))
  expect_false(manifests$calibration_pilot$ExecutionAuthorized)
  expect_false(manifests$confirmation$ExecutionAuthorized)
  expect_true(manifests$confirmation$ConfirmationUse)
  expect_false(any(vapply(manifests, `[[`, logical(1L), "DataGenerated")))
  expect_false(any(vapply(manifests, `[[`, logical(1L), "ResultsViewed")))
})

test_that("Draft.83d2b2b0 candidate rules remain unselected and truth blind", {
  env <- load_gtheory_weak_information_pilot()
  candidates <- env$mfrmr_gtwp_candidate_registry()

  expect_equal(nrow(candidates$Scores), 6L)
  expect_equal(nrow(candidates$Rules), 4L)
  expect_true(all(candidates$Scores$TruthBlindAtApplication))
  expect_equal(sum(candidates$Scores$CurrentAvailability ==
                     "implemented_covering_smoke"), 4L)
  expect_equal(sum(candidates$Scores$CurrentAvailability ==
                     "pending_enriched_diagnostic_refit"), 2L)
  expect_true(all(vapply(candidates$CutpointGrids, function(x) {
    all(is.finite(x)) && all(diff(x) > 0)
  }, logical(1L))))
  expect_identical(candidates$SelectionOrder$Priority, 1:6)
  expect_true(is.na(candidates$SelectedRuleFamily))
  expect_true(is.na(candidates$SelectedLowerCutpoint))
  expect_true(is.na(candidates$SelectedUpperCutpoint))
  expect_false(candidates$ThresholdFrozen)

  higher <- env$mfrmr_gtwp_classify(c(0, 0.5, 1, NA), 0.25, 0.75)
  lower <- env$mfrmr_gtwp_classify(
    c(0.1, 0.5, 1), 0.25, 0.75, direction = "lower"
  )
  expect_identical(as.character(higher),
                   c("not_resolved", "indeterminate", "resolved",
                     "not_evaluable"))
  expect_identical(as.character(lower),
                   c("resolved", "indeterminate", "not_resolved"))
  expect_error(env$mfrmr_gtwp_classify(1, 1, 1), "lower < upper")
})

test_that("Draft.83d2b2b0 keeps all resolution-state denominators", {
  env <- load_gtheory_weak_information_pilot()
  states <- data.frame(
    EvaluationRole = c(
      rep("negative_control_not_resolved", 4L),
      rep("positive_control_resolved", 4L),
      "transition_no_binary_requirement"
    ),
    ResolutionState = c(
      "not_resolved", "indeterminate", "resolved", "not_evaluable",
      "resolved", "indeterminate", "not_resolved", "not_evaluable",
      "indeterminate"
    ),
    stringsAsFactors = FALSE
  )
  accounting <- env$mfrmr_gtwp_state_accounting(states)

  expect_equal(accounting$NegativeExpected, 4L)
  expect_equal(accounting$NegativeFalseReady, 1L)
  expect_equal(accounting$NegativeIndeterminate, 1L)
  expect_equal(accounting$NegativeNotEvaluable, 1L)
  expect_equal(accounting$PositiveExpected, 4L)
  expect_equal(accounting$PositiveFalseBlock, 1L)
  expect_equal(accounting$PositiveIndeterminate, 1L)
  expect_equal(accounting$PositiveNotEvaluable, 1L)
  expect_equal(accounting$TransitionExpected, 1L)
  expect_equal(env$mfrmr_gtwp_binomial_upper(0, 25),
               1 - 0.05^(1 / 25), tolerance = 1e-15)
  expect_equal(env$mfrmr_gtwp_binomial_upper(0, 100),
               1 - 0.05^(1 / 100), tolerance = 1e-15)
  expect_equal(env$mfrmr_gtwp_binomial_upper(0, 200),
               1 - 0.05^(1 / 200), tolerance = 1e-15)
  expect_error(env$mfrmr_gtwp_binomial_upper(2, 1), "Invalid")
  expect_error(
    env$mfrmr_gtwp_state_accounting(data.frame(ResolutionState = "resolved")),
    "requires evaluation roles"
  )
})

test_that("Draft.83d2b2b0 executes only the viewed schema band", {
  env <- load_gtheory_weak_information_pilot()
  plan <- env$mfrmr_gtwp_plan()
  manifest <- env$mfrmr_gtwp_manifest(plan, "schema_smoke")
  result <- env$mfrmr_gtwp_execute_manifest(manifest, plan, progress = FALSE)
  passes <- with(result$ObservableRows,
                 tapply(BasePointGatePassed, VarianceId, sum))

  expect_s3_class(result, "mfrmr_gtwp_execution")
  expect_equal(result$PlannedUnits, 24L)
  expect_equal(result$IndependentDatasetCount, 6L)
  expect_equal(result$FitAttemptCount, 24L)
  expect_equal(result$FitReturnCount, 24L)
  expect_equal(result$BasePointGatePassCount, 16L)
  expect_true(result$AtomicAccountingPassed)
  expect_true(result$PhaseComplete)
  expect_true(result$SchemaExecutionReady)
  expect_identical(as.integer(passes[c(
    "exact_zero", "numerical_near_zero", "reference_1200"
  )]), c(8L, 4L, 4L))
  expect_identical(
    result$ExecutionHash,
    "463a188717f389858635c5447d2c750b32920b5d370d3fbb39cbada43ed9780c"
  )
  expect_false(result$FeasibilityEvidenceReady)
  expect_false(result$CalibrationEvidenceReady)
  expect_false(result$ThresholdFrozen)
  expect_false(result$ConfirmationAuthorized)
  expect_false(result$ConfirmationViewed)
  expect_false(result$DecisionReady)
})

test_that("Draft.83d2b2b0 fails closed before reserved phases are viewed", {
  env <- load_gtheory_weak_information_pilot()
  plan <- env$mfrmr_gtwp_plan()
  calibration <- env$mfrmr_gtwp_manifest(plan, "calibration_pilot")
  confirmation <- env$mfrmr_gtwp_manifest(plan, "confirmation")

  expect_error(
    env$mfrmr_gtwp_execute_manifest(calibration, plan, progress = FALSE),
    "not authorized"
  )
  expect_error(
    env$mfrmr_gtwp_execute_manifest(confirmation, plan, progress = FALSE),
    "not authorized"
  )
  expect_error(env$mfrmr_gtwp_manifest(plan, "unknown-phase"), "Unknown")
  expect_error(
    env$mfrmr_gtwp_manifest(
      plan, "schema_smoke",
      scenario_ids = "GT-WI-high_information-reference_1200"
    ),
    "outside the registered phase"
  )
  expect_error(env$mfrmr_gtwp_manifest(list(), "schema_smoke"),
               "must be a Draft.83d2b2b0")
  expect_error(env$mfrmr_gtwp_execute_manifest(list(), plan),
               "requires its plan and manifest")
})
