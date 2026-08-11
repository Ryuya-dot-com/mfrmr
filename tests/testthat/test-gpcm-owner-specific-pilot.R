owner_specific_runner_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-owner-specific-pilot-0.2.3.R"
  )
}

test_that("owner-specific GPCM manifest binds every Draft.66 identity axis", {
  skip_if_not_installed("digest")
  runner <- owner_specific_runner_path()
  skip_if_not(file.exists(runner),
              "repository-internal validation artifacts are excluded")
  expect_true(file.exists(runner))
  env <- new.env(parent = globalenv())
  source(runner, local = env)

  smoke <- env$mfrmr_gpcm_owner_manifest("smoke")
  expect_identical(nrow(smoke), 16L)
  expect_identical(anyDuplicated(smoke$ScenarioId), 0L)
  expect_true(all(smoke$Replicate == 1L))
  expect_identical(length(unique(smoke$DesignCellId)), 16L)
  expect_identical(sort(unique(smoke$SlopeOwner)), c("Criterion", "Rater"))
  expect_true(all(smoke$SlopeOwner == smoke$StepOwner))
  expect_true(all(smoke$SlopeComposition ==
                    "single_owner_relative_gm1"))
  expect_true(all(as.character(smoke$LatentDimensionCount) == "1"))
  expect_identical(sort(unique(smoke$Estimator)), c("JML", "MML"))
  expect_identical(
    unique(smoke$GateScenarioId[smoke$SlopeOwner == "Criterion"]),
    "NUM-GPCM-ALIGN-CRITERION"
  )
  expect_identical(
    unique(smoke$GateScenarioId[smoke$SlopeOwner == "Rater"]),
    "NUM-GPCM-ALIGN-RATER"
  )
  expect_true(all(nchar(smoke$RuntimeIdentity) == 64L))
  expect_true(all(nchar(smoke$RunnerSHA256) == 64L))
  expect_true(all(nchar(smoke$IdentityContractSHA256) == 64L))
  expect_true(all(nchar(smoke$ExecutionContractSHA256) == 64L))
  expect_true(all(nchar(smoke$ManifestHash) == 64L))
  expect_true(all(!smoke$ConfirmationAuthorized))
  expect_true(all(smoke$ReleaseUse == "calibration_only"))

  recovery <- env$mfrmr_gpcm_owner_slope_recovery(
    list(slopes = data.frame(
      SlopeFacet = c("A", "B"), Estimate = c(0.8, 1.25)
    )),
    list(slope_table = data.frame(
      SlopeFacet = c("A", "B"), Estimate = c(0.8, 1.25)
    ))
  )
  expect_identical(unname(recovery[["N"]]), 2)
  expect_equal(unname(recovery[["LogRMSE"]]), 0)

  pilot <- env$mfrmr_run_gpcm_owner_specific_pilot(
    "pilot", dry_run = TRUE, progress = FALSE
  )
  expect_identical(nrow(pilot$manifest), 120L)
  expect_identical(length(unique(pilot$manifest$DesignCellId)), 24L)
  per_cell <- table(pilot$manifest$DesignCellId)
  expect_true(all(per_cell == 5L))
  expect_identical(anyDuplicated(pilot$manifest$ScenarioId), 0L)
  expect_true(all(pilot$manifest$ReplicatesPlanned == 5L))
  expect_identical(nrow(pilot$results), 0L)
  expect_false(pilot$summary$ConfirmationAuthorized)
  expect_identical(
    pilot$execution_policy$BernoulliDenominator,
    "all_planned_manifest_rows"
  )
  expect_identical(pilot$execution_policy$SpecificationId,
                   "0.2.3-draft.66")
  expect_identical(pilot$execution_policy$PlannedRows, 120L)
  expect_identical(pilot$execution_policy$PlannedMaxit, 400L)
  expect_identical(pilot$execution_policy$PlannedQuadPoints, 31L)
  expect_identical(pilot$execution_identity$Maxit, 400L)
  expect_identical(pilot$execution_identity$QuadPoints, 31L)
  expect_false(pilot$execution_policy$OutcomeAdaptiveStopping)
  expect_identical(
    nchar(pilot$execution_identity$ExecutionSHA256), 64L
  )

  shards <- lapply(seq_len(7L), function(index) {
    env$mfrmr_gpcm_owner_select_shard(
      pilot$declared_manifest, index, 7L
    )$ScenarioId
  })
  expect_identical(length(unique(unlist(shards))), 120L)
  expect_identical(sort(unlist(shards)),
                   sort(pilot$declared_manifest$ScenarioId))
  expect_true(all(vapply(combn(shards, 2L, simplify = FALSE), function(pair) {
    length(intersect(pair[[1L]], pair[[2L]])) == 0L
  }, logical(1))))
  shard_one <- env$mfrmr_run_gpcm_owner_specific_pilot(
    "pilot", shard_index = 1L, shard_count = 7L,
    dry_run = TRUE, progress = FALSE
  )
  shard_two <- env$mfrmr_run_gpcm_owner_specific_pilot(
    "pilot", shard_index = 2L, shard_count = 7L,
    dry_run = TRUE, progress = FALSE
  )
  expect_identical(
    shard_one$execution_identity$ExecutionSHA256,
    shard_two$execution_identity$ExecutionSHA256
  )
  expect_false(identical(shard_one$selected_manifest_sha256,
                         shard_two$selected_manifest_sha256))
  expect_error(
    env$mfrmr_gpcm_owner_execution_identity(
      pilot$declared_manifest[-1L, , drop = FALSE]
    ),
    "violates the owner execution policy"
  )
  expect_error(
    env$mfrmr_run_gpcm_owner_specific_pilot(
      "pilot", quad_points = 15L, dry_run = TRUE, progress = FALSE
    ),
    "controls are frozen"
  )
  expect_error(
    env$mfrmr_run_gpcm_owner_specific_pilot(
      "pilot", scenario_ids = pilot$manifest$ScenarioId[[1L]],
      shard_count = 2L, dry_run = TRUE, progress = FALSE
    ),
    "cannot be combined"
  )
  expect_error(
    env$mfrmr_run_gpcm_owner_specific_pilot(
      "pilot", dry_run = FALSE, authorize = FALSE, progress = FALSE
    ),
    "resource-significant"
  )
})

test_that("owner summaries keep planned denominators and disclose MCSE", {
  skip_if_not_installed("digest")
  skip_if_not(file.exists(owner_specific_runner_path()),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  source(owner_specific_runner_path(), local = env)
  results <- data.frame(
    SlopeOwner = rep("Rater", 5L),
    Estimator = rep("MML", 5L),
    DesignId = rep("core", 5L),
    DesignCellId = rep("GPCM-OWNER-R-MML-CORE", 5L),
    Executed = c(TRUE, TRUE, TRUE, TRUE, FALSE),
    FitSucceeded = c(TRUE, TRUE, FALSE, TRUE, FALSE),
    RawInferenceReady = c(TRUE, NA, FALSE, TRUE, NA),
    EvidenceInferenceReady = c(TRUE, FALSE, FALSE, TRUE, FALSE),
    RawFalseReady = c(FALSE, FALSE, FALSE, FALSE, NA),
    UpstreamReadyBlocked = rep(FALSE, 5L),
    FalseReady = rep(FALSE, 5L),
    SlopeLogRMSE = c(0.1, 0.2, NA, 0.3, NA),
    stringsAsFactors = FALSE
  )
  rates <- env$mfrmr_gpcm_owner_rate_summary(results)
  numeric <- env$mfrmr_gpcm_owner_numeric_summary(results)
  expect_identical(rates$Planned, 5L)
  expect_identical(rates$RawInferenceReadyCount, 2)
  expect_equal(rates$RawInferenceReadyRate, 0.4)
  expect_true(rates$RawInferenceReadyWilsonLower < 0.4)
  expect_true(rates$RawInferenceReadyWilsonUpper > 0.4)
  expect_identical(numeric$Planned, 5L)
  expect_identical(numeric$Finite, 3L)
  expect_identical(numeric$MissingOrIneligible, 2L)
  expect_identical(numeric$FitFailures, 2L)
  expect_equal(numeric$MCSE, stats::sd(c(0.1, 0.2, 0.3)) / sqrt(3))
})

test_that("owner checkpoints resume and reject altered payloads", {
  skip_if_not_installed("digest")
  skip_if_not(file.exists(owner_specific_runner_path()),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  source(owner_specific_runner_path(), local = env)
  manifest <- env$mfrmr_gpcm_owner_manifest("smoke")
  selected <- manifest$ScenarioId[
    manifest$SlopeOwner == "Rater" & manifest$Estimator == "MML" &
      manifest$DesignId %in% c("core", "internal_zero")
  ]
  checkpoint_dir <- tempfile("gpcm-owner-checkpoints-")
  dir.create(checkpoint_dir)
  on.exit(unlink(checkpoint_dir, recursive = TRUE, force = TRUE), add = TRUE)

  expect_error(
    env$mfrmr_run_gpcm_owner_specific_pilot(
      "smoke", scenario_ids = selected, checkpoint_dir = checkpoint_dir,
      interrupt_after_rows = 1L, maxit = 25L, quad_points = 5L,
      progress = FALSE
    ),
    "Intentional owner checkpoint interruption"
  )
  expect_identical(length(list.files(checkpoint_dir, pattern = "[.]rds$")),
                   1L)
  resumed <- env$mfrmr_run_gpcm_owner_specific_pilot(
    "smoke", scenario_ids = selected, checkpoint_dir = checkpoint_dir,
    resume = TRUE, maxit = 25L, quad_points = 5L, progress = FALSE
  )
  expect_identical(resumed$checkpoint_summary$NewRows, 1L)
  expect_identical(resumed$checkpoint_summary$ResumedRows, 1L)
  expect_identical(resumed$summary$ExecutedRows, 2L)
  expect_identical(resumed$summary$FalseReadyRows, 0L)

  first_path <- file.path(checkpoint_dir, paste0(selected[[1L]], ".rds"))
  adulterated <- readRDS(first_path)
  adulterated$result$FalseReady <- !adulterated$result$FalseReady
  saveRDS(adulterated, first_path)
  expect_error(
    env$mfrmr_run_gpcm_owner_specific_pilot(
      "smoke", scenario_ids = selected[[2L]],
      checkpoint_dir = checkpoint_dir,
      resume = TRUE, maxit = 25L, quad_points = 5L, progress = FALSE
    ),
    "result payload hash mismatch"
  )
})

test_that("owner completion marker covers all declared checkpoints", {
  skip_if_not_installed("digest")
  skip_if_not(file.exists(owner_specific_runner_path()),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  source(owner_specific_runner_path(), local = env)
  output_dir <- tempfile("gpcm-owner-completion-")
  checkpoint_dir <- file.path(output_dir, "checkpoints")
  on.exit(unlink(output_dir, recursive = TRUE, force = TRUE), add = TRUE)
  env$mfrmr_gpcm_owner_run_one <- function(row, maxit, quad_points) {
    row <- env$mfrmr_gpcm_owner_empty_result(
      row, "test_attempt_retained"
    )
    row$Executed <- TRUE
    row
  }
  first <- env$mfrmr_run_gpcm_owner_specific_pilot(
    "smoke", output_dir = output_dir, shard_index = 1L, shard_count = 2L,
    progress = FALSE
  )
  expect_identical(first$checkpoint_summary$NewRows, 8L)
  expect_false(file.exists(file.path(output_dir, "run-complete.rds")))
  second <- env$mfrmr_run_gpcm_owner_specific_pilot(
    "smoke", output_dir = output_dir, resume = TRUE,
    shard_index = 2L, shard_count = 2L, progress = FALSE
  )
  expect_identical(second$checkpoint_summary$NewRows, 8L)
  expect_identical(
    first$execution_identity$ExecutionSHA256,
    second$execution_identity$ExecutionSHA256
  )
  expect_identical(length(list.files(checkpoint_dir, pattern = "[.]rds$")),
                   16L)
  expect_false(file.exists(file.path(output_dir, "run-complete.rds")))
  result <- env$mfrmr_run_gpcm_owner_specific_pilot(
    "smoke", output_dir = output_dir, resume = TRUE, progress = FALSE
  )
  expect_identical(result$checkpoint_summary$NewRows, 0L)
  expect_identical(result$checkpoint_summary$ResumedRows, 16L)
  marker <- env$mfrmr_gpcm_owner_validate_completion(
    output_dir, result$execution_identity$ExecutionSHA256
  )
  expect_identical(marker$declared_rows, 16L)
  expect_true(file.exists(file.path(output_dir, "run-complete.rds")))

  write("tampered", file.path(output_dir, "summary.csv"), append = TRUE)
  expect_error(
    env$mfrmr_gpcm_owner_validate_completion(
      output_dir, result$execution_identity$ExecutionSHA256
    ),
    "artifact hash mismatch"
  )
})

test_that("owner-specific GPCM smoke keeps support and identity fail closed", {
  skip_if_not_installed("digest")
  skip_if_not(file.exists(owner_specific_runner_path()),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  source(owner_specific_runner_path(), local = env)
  manifest <- env$mfrmr_gpcm_owner_manifest("smoke")
  selected <- manifest$ScenarioId[
    manifest$DesignId == "core" |
      (manifest$SlopeOwner == "Rater" & manifest$Estimator == "MML" &
         manifest$DesignId %in% c("zero_shared", "internal_zero"))
  ]
  result <- env$mfrmr_run_gpcm_owner_specific_pilot(
    "smoke",
    scenario_ids = selected,
    maxit = 35L,
    quad_points = 5L,
    progress = FALSE
  )

  expect_identical(result$summary$ManifestRows, 6L)
  expect_identical(result$summary$ExecutedRows, 6L)
  expect_identical(result$summary$FitSucceededRows, 5L)
  expect_identical(result$summary$IdentityViolations, 0L)
  expect_identical(result$summary$FalseReadyRows, 0L)
  expect_false(result$summary$ConfirmationAuthorized)
  expect_true(all(result$results$FitIdentityMatch[result$results$FitSucceeded]))
  expect_true(all(!result$results$FalseReady))
  expect_true(all(result$results$SlopeN[result$results$FitSucceeded] == 3L))
  expect_true(all(result$results$SlopeN[!result$results$FitSucceeded] == 0L))

  core <- result$results[result$results$DesignId == "core", , drop = FALSE]
  expect_identical(nrow(core), 4L)
  expect_identical(sort(unique(core$SlopeOwner)), c("Criterion", "Rater"))
  expect_identical(sort(unique(core$Estimator)), c("JML", "MML"))
  expect_true(all(is.finite(core$SlopeLogRMSE)))

  zero_shared <- result$results[
    result$results$DesignId == "zero_shared", , drop = FALSE
  ]
  internal_zero <- result$results[
    result$results$DesignId == "internal_zero", , drop = FALSE
  ]
  expect_identical(zero_shared$MinCommonPersons, 0L)
  expect_gt(internal_zero$OwnerCategoryZeroCells, 0L)
  expect_identical(internal_zero$ZeroCategories, 1L)
  expect_false(internal_zero$FitSucceeded)
  expect_identical(internal_zero$RunState, "expected_fail_closed")
  expect_match(internal_zero$Error, "unsupported internal-category",
               fixed = TRUE)
  expect_false(any(grepl(
    "recoded internally", internal_zero$Warnings, fixed = TRUE
  ), na.rm = TRUE))
  expect_identical(zero_shared$EvidenceFitReadiness, "blocked")
  expect_identical(internal_zero$EvidenceFitReadiness, "blocked")
  expect_false(zero_shared$EvidenceInferenceReady)
  expect_false(internal_zero$EvidenceInferenceReady)
  expect_false(zero_shared$FalseReady)
  expect_false(internal_zero$FalseReady)

  expect_error(
    env$mfrmr_run_gpcm_owner_specific_pilot(
      "smoke", scenario_ids = "not-registered", progress = FALSE
    ),
    "Unknown owner-specific scenario"
  )
})
