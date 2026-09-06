load_gtheory_dsim5e <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    root <- testthat::test_path("..", "..")
    validation <- file.path(root, "inst", "validation")
    controller <- file.path(
      validation,
      "gtheory-multivariate-dsim3-bounded-exploratory-launch-controller-0.2.4.R"
    )
    executor <- file.path(
      validation,
      "gtheory-multivariate-dsim5-shard-executor-0.2.4.R"
    )
    input_path <- file.path(
      root, "validation-results",
      "gtheory-multivariate-dsim5-launch-input-0.2.4", "launch-input.rds"
    )
    admission_path <- file.path(
      root, "validation-results",
      "gtheory-multivariate-dsim5-execution-admission-0.2.4",
      "admission-manifest.rds"
    )
    manifest_path <- file.path(
      root, "validation-results",
      "gtheory-multivariate-dsim5-shard-executor-0.2.4",
      "executor-qualification-manifest.rds"
    )
    skip_if_not(all(file.exists(c(
      controller, executor, input_path, admission_path, manifest_path
    ))), "repository-internal D-SIM-5 executor excluded")
    skip_if_not_installed("digest")
    skip_if_not_installed("lme4")
    probe <- new.env(parent = globalenv())
    sys.source(controller, envir = probe, keep.source = FALSE)
    environment <- new.env(parent = globalenv())
    for (file in head(probe$mfrmr_gtds3ac_source_basenames(), -2L)) {
      sys.source(file.path(validation, file), envir = environment,
                 keep.source = FALSE)
    }
    for (file in c(
      "gtheory-multivariate-dsim3-descriptive-recovery-adjudication-0.2.4.R",
      "gtheory-multivariate-dsim4-admission-decision-0.2.4.R",
      "gtheory-multivariate-dsim4-confirmation-freeze-0.2.4.R",
      "gtheory-multivariate-dsim4-worker-qualification-0.2.4.R",
      "gtheory-multivariate-dsim5-launch-input-0.2.4.R",
      "gtheory-multivariate-dsim5-execution-admission-0.2.4.R",
      "gtheory-multivariate-dsim5-shard-executor-0.2.4.R"
    )) {
      sys.source(file.path(validation, file), envir = environment,
                 keep.source = FALSE)
    }
    input <- readRDS(input_path)
    admission <- readRDS(admission_path)
    manifest <- readRDS(manifest_path)
    environment$mfrmr_gtds5e_assert_manifest(manifest, input, admission)
    value <<- list(
      Environment = environment, Input = input, Admission = admission,
      Manifest = manifest, SourceRoot = root
    )
    value
  }
})

test_that("D-SIM-5 executor binds all admitted jobs without starting them", {
  loaded <- load_gtheory_dsim5e()
  manifest <- loaded$Manifest
  summary <- manifest$Summary

  expect_identical(
    manifest$Contract$ContractHash,
    "a64facef158aaf7f4e4463512af9b7367195f708d45183e2cd3d5d63ec9bf6f3"
  )
  expect_identical(
    manifest$ManifestHash,
    "e7a6442be5c1f5f987d5f5283c380f7a07c3ff9e7aef4cc187348814067d1fa7"
  )
  expect_identical(summary$QualifiedShardCount, 50L)
  expect_identical(summary$QualifiedOuterRequestCount, 15000L)
  expect_identical(summary$QualifiedInnerAttemptCount, 995000L)
  expect_true(summary$AllJobsAdmissionBound)
  expect_true(summary$OuterAttemptCheckpointAtomic)
  expect_true(summary$ExactResumeQualified)
  expect_false(summary$ResultValueAdaptiveBranchPresent)
  expect_true(summary$IntegratedShadowExecutorQualified)
  expect_false(summary$QualificationExecutionStarted)
  expect_false(summary$QualificationPlanned857RngStreamOpened)
  expect_false(summary$QualificationPlanned858RngStreamOpened)
  expect_true(summary$QualificationShadowBackendCallMade)
  expect_false(summary$QualificationPlannedBackendCallMade)
  expect_false(summary$ScientificAdjudicationComputed)
})

test_that("integrated executor path passes on the nonreserved shadow", {
  qualification <- load_gtheory_dsim5e()$Manifest$ShadowQualification
  result <- qualification$Result

  expect_identical(qualification$DataSeed, 854100001L)
  expect_identical(qualification$BootstrapSeed, 854900001L)
  expect_identical(result$TerminalState, "complete_with_interval")
  expect_identical(nrow(result$PrimaryFitReceiptRegistry), 2L)
  expect_true(all(result$PrimaryFitReceiptRegistry$FitReturned))
  expect_identical(nrow(result$InnerReceiptRegistry), 199L)
  expect_true(all(result$InnerReceiptRegistry$TerminalState == "success"))
  expect_identical(nrow(result$BootstrapMetricRegistry), 796L)
  expect_true(all(result$BootstrapMetricRegistry$TargetFinite))
  expect_identical(nrow(result$IntervalRegistry), 4L)
  expect_true(all(result$IntervalRegistry$IntervalAvailable))
  expect_true(result$BootstrapRngStreamOpened)
  expect_false(result$Planned857RngStreamOpened)
  expect_false(result$Planned858RngStreamOpened)
  expect_false(result$CountsAsDsim5Attempt)
  expect_false(result$Dsim5ExecutionStarted)
  expect_true(qualification$CallerRngStateRestored)
})

test_that("one shard job retains exact attempt and seed identities", {
  loaded <- load_gtheory_dsim5e()
  env <- loaded$Environment
  job <- env$mfrmr_gtds5e_job(
    "D5-SHARD-001", loaded$Input, loaded$Admission
  )
  assignments <- job$AssignmentRegistry

  expect_invisible(env$mfrmr_gtds5e_assert_job(
    job, loaded$Input, loaded$Admission
  ))
  expect_identical(nrow(assignments), 300L)
  expect_identical(sum(assignments$IntervalEligible), 100L)
  expect_identical(sum(assignments$InnerBootstrapAttemptCount), 19900L)
  expect_identical(job$Summary$ExpectedBackendFitCallCount, 40450L)
  expect_true(all(assignments$ExecutionAuthorized))
  expect_false(any(assignments$RngStreamOpened))
  expect_false(anyDuplicated(assignments$AssignmentExecutionHash) > 0L)
  expect_true(all(assignments$DataSeed >= 857010001L))
  expect_true(all(assignments$DataSeed <= 857060050L))
  expect_true(all(
    is.na(assignments$BootstrapSeed[!assignments$IntervalEligible])
  ))

  changed <- job
  changed$AssignmentRegistry$OuterRequestHash[[1L]] <- strrep("0", 64L)
  expect_error(
    env$mfrmr_gtds5e_assert_job(changed, loaded$Input, loaded$Admission),
    "shard job was altered"
  )
})

test_that("planned data adapter is pure until explicit attempt execution", {
  loaded <- load_gtheory_dsim5e()
  env <- loaded$Environment
  job <- env$mfrmr_gtds5e_job(
    "D5-SHARD-001", loaded$Input, loaded$Admission
  )
  assignment <- job$AssignmentRegistry[1L, , drop = FALSE]
  before <- env$mfrmr_gtds5e_rng_snapshot()
  contract <- env$mfrmr_gtds5e_data_contract(assignment)

  expect_identical(contract$ShadowSeedBandId,
                   "DSIM5-CONFIRMATION-DATA-857")
  expect_identical(contract$MinimumShadowSeed, assignment$DataSeed[[1L]])
  expect_identical(contract$MaximumShadowSeed, assignment$DataSeed[[1L]])
  expect_identical(contract$ReservedExploratoryLowerInclusive, 858000000L)
  expect_true(contract$ExploratoryExecutionAllowed)
  expect_false(contract$SimulationValidationClaimAllowed)
  expect_true(env$mfrmr_gtds5e_rng_restored(before))
})

test_that("resume consumes identity only and leaves the denominator fixed", {
  loaded <- load_gtheory_dsim5e()
  env <- loaded$Environment
  job <- env$mfrmr_gtds5e_job(
    "D5-SHARD-001", loaded$Input, loaded$Admission
  )
  assignment <- job$AssignmentRegistry[
    !job$AssignmentRegistry$IntervalEligible, , drop = FALSE
  ][1L, , drop = FALSE]
  before <- env$mfrmr_gtds5e_rng_snapshot()
  result <- env$mfrmr_gtds5e_result(
    assignment, job, "generation_failure", planned857_opened = TRUE,
    caller_rng_restored = TRUE, error_text = "qualification_probe_only"
  )
  directory <- tempfile("dsim5-resume-")
  dir.create(directory)
  on.exit(unlink(directory, recursive = TRUE), add = TRUE)
  env$mfrmr_gtds5e_atomic_save(
    result, env$mfrmr_gtds5e_result_path(directory, result$AttemptId)
  )
  plan <- env$mfrmr_gtds5e_resume_plan(job, directory)

  expect_invisible(env$mfrmr_gtds5e_assert_result(result, job))
  expect_identical(plan$CompletedCount, 1L)
  expect_identical(plan$RemainingCount, 299L)
  expect_identical(nrow(plan$CompletedRegistry), 1L)
  expect_false("TerminalState" %in% names(plan$CompletedRegistry))
  expect_false(plan$ResultValueUsedForResumeDecision)
  expect_identical(
    plan$RemainingAssignmentRegistry$AttemptId,
    job$AssignmentRegistry$AttemptId[
      job$AssignmentRegistry$AttemptId != assignment$AttemptId[[1L]]
    ]
  )
  expect_true(env$mfrmr_gtds5e_rng_restored(before))
})

test_that("executor record preserves the unstarted claim ceiling", {
  loaded <- load_gtheory_dsim5e()
  path <- file.path(
    loaded$SourceRoot, "inst", "validation",
    "gtheory-multivariate-dsim5-shard-executor-record-0.2.4.md"
  )
  record <- paste(readLines(path, warn = FALSE), collapse = "\n")

  expect_match(record, loaded$Manifest$ManifestHash, fixed = TRUE)
  expect_match(record, "execution not started", fixed = TRUE)
  expect_match(record, "no 857/858 RNG stream", fixed = TRUE)
  expect_match(record, "does not", fixed = TRUE)
})
