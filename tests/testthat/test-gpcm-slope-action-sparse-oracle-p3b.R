load_gpcm_slope_action_sparse_oracle <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  source_paths <- file.path(
    root, "inst", "validation",
    c(
      "gpcm-slope-action-projection-p3a-0.2.3.R",
      "gpcm-slope-action-sparse-oracle-p3b-0.2.3.R"
    )
  )
  record_path <- file.path(
    root, "inst", "validation",
    "gpcm-slope-action-sparse-oracle-p3b-record-0.2.3.md"
  )
  expect_true(all(file.exists(source_paths)))
  expect_true(file.exists(record_path))
  env <- new.env(parent = baseenv())
  for (source_path in source_paths) sys.source(source_path, envir = env)
  list(env = env, source_paths = source_paths, record_path = record_path)
}

sparse_oracle_test_result <- local({
  cached <- NULL
  function() {
    if (is.null(cached)) {
      context <- load_gpcm_slope_action_sparse_oracle()
      set.seed(7319)
      initial_seed <- .Random.seed
      result <- context$env$mfrmr_run_gpcm_slope_action_sparse_oracle()
      expect_identical(.Random.seed, initial_seed)
      cached <<- list(context = context, result = result)
    }
    cached
  }
})

test_that("cycles rather than connectedness identify slope action", {
  audit <- sparse_oracle_test_result()$result
  structure <- audit$structure
  expect_identical(
    structure$Design,
    c("complete", "balanced_cycle", "localized_cycle", "connected_tree")
  )
  expect_identical(structure$EdgeCount, c(16L, 8L, 8L, 7L))
  expect_identical(structure$Components, rep(1L, 4L))
  expect_true(all(structure$Connected))
  expect_identical(structure$CycleRank, c(9L, 1L, 1L, 0L))

  expect_identical(nrow(audit$projections), 16L)
  expect_identical(nrow(audit$stability), 8L)
  expect_true(all(audit$projections$OptimizerConvergence == 0L))
  tree <- audit$projections$Design == "connected_tree"
  cycles <- !tree
  expect_true(all(abs(audit$projections$ProjectedKLPerResponse[tree]) < 1e-12))
  expect_true(all(audit$projections$MaxProbabilityDifference[tree] < 1e-12))
  expect_true(all(audit$projections$ProjectedKLPerResponse[cycles] > 1e-6))
  expect_true(all(audit$stability$ProjectedKLAbsQ41MinusQ31 < 1e-7))
  expect_true(all(
    audit$stability$MaxProbabilityDifferenceAbsQ41MinusQ31 < 1e-7
  ))
})

test_that("known-ability selection exposes cycle placement", {
  audit <- sparse_oracle_test_result()$result
  simulation <- audit$simulation
  expect_identical(nrow(simulation), 24L)
  expect_identical(sort(unique(simulation$SampleSize)), c(50L, 100L, 250L))
  expect_true(all(simulation$Replications == 400L))

  tree <- simulation$Design == "connected_tree"
  expect_true(all(is.na(simulation$TruthSelectionRate[tree])))
  expect_true(all(
    simulation$SelectionStatus[tree] == "not_identifiable_on_observed_edges"
  ))
  identifiable <- !tree
  expect_true(all(is.finite(simulation$TruthSelectionRate[identifiable])))
  expect_true(all(simulation$TieRate[identifiable] == 0))
  expect_true(all(
    simulation$MeanLogLikelihoodAdvantagePerResponse[identifiable] > 0
  ))

  at_250 <- simulation[
    simulation$SampleSize == 250L & identifiable, , drop = FALSE
  ]
  mean_rate <- tapply(
    at_250$TruthSelectionRate, at_250$Design, mean
  )
  expect_gt(mean_rate[["complete"]], mean_rate[["balanced_cycle"]])
  expect_gt(mean_rate[["balanced_cycle"]], mean_rate[["localized_cycle"]])
  expect_gt(mean_rate[["complete"]], 0.90)
  expect_lt(mean_rate[["localized_cycle"]], 0.70)

  expect_false(audit$public_family_added)
  expect_false(audit$model_selection_enabled)
  expect_false(audit$readiness_overridden)
  expect_false(audit$practical_threshold_frozen)
  expect_false(audit$release_authorized)
})

test_that("the record keeps the oracle boundary explicit", {
  audit <- sparse_oracle_test_result()
  record <- paste(readLines(audit$context$record_path), collapse = "\n")
  expect_match(record, "known-ability, fixed-parameter", fixed = TRUE)
  expect_match(record, "It is not JML, MML", fixed = TRUE)
  expect_match(record, "PublicFamilyAdded = FALSE", fixed = TRUE)
  expect_match(record, "ModelSelectionEnabled = FALSE", fixed = TRUE)
  expect_match(record, "PracticalThresholdFrozen = FALSE", fixed = TRUE)
})
