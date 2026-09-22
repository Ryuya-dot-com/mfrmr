load_gtheory_dsim5d <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    root <- testthat::test_path("..", "..")
    validation <- file.path(root, "inst", "validation")
    controller <- file.path(
      validation,
      "gtheory-multivariate-dsim3-bounded-exploratory-launch-controller-0.2.4.R"
    )
    source <- file.path(
      validation,
      "gtheory-multivariate-dsim5-complete-denominator-adjudication-0.2.4.R"
    )
    skip_if_not(all(file.exists(c(controller, source))),
                "repository-internal D-SIM-5 adjudicator excluded")
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
      "gtheory-multivariate-dsim5-shard-executor-0.2.4.R",
      basename(source)
    )) {
      sys.source(file.path(validation, file), envir = environment,
                 keep.source = FALSE)
    }
    input <- readRDS(file.path(
      root, "validation-results",
      "gtheory-multivariate-dsim5-launch-input-0.2.4", "launch-input.rds"
    ))
    admission <- readRDS(file.path(
      root, "validation-results",
      "gtheory-multivariate-dsim5-execution-admission-0.2.4",
      "admission-manifest.rds"
    ))
    value <<- list(
      Environment = environment, Input = input, Admission = admission
    )
    value
  }
})

test_that("blind identity sentinels reject missing duplicate foreign and altered rows", {
  env <- load_gtheory_dsim5d()$Environment
  expected <- data.frame(
    AttemptId = c("A1", "A2"),
    OuterRequestHash = c("o1", "o2"),
    InnerBlockHash = c("i1", "i2"), stringsAsFactors = FALSE
  )
  observed <- transform(
    expected, ResultHash = c(strrep("a", 64L), strrep("b", 64L)),
    TerminalStateCount = 1L
  )
  row.names(observed) <- c("unrelated-1", "unrelated-2")

  expect_invisible(env$mfrmr_gtds5d_assert_identity(expected, observed))
  expect_error(
    env$mfrmr_gtds5d_assert_identity(expected, observed[-1L, ]),
    "missing, duplicated, or foreign"
  )
  duplicate <- observed; duplicate$AttemptId[[2L]] <- "A1"
  expect_error(
    env$mfrmr_gtds5d_assert_identity(expected, duplicate),
    "missing, duplicated, or foreign"
  )
  foreign <- observed; foreign$AttemptId[[2L]] <- "A3"
  expect_error(
    env$mfrmr_gtds5d_assert_identity(expected, foreign),
    "missing, duplicated, or foreign"
  )
  altered <- observed; altered$OuterRequestHash[[1L]] <- "changed"
  expect_error(
    env$mfrmr_gtds5d_assert_identity(expected, altered), "was altered"
  )
})

test_that("checkpoint and receipt validation stay delegated to the frozen executor", {
  loaded <- load_gtheory_dsim5d()
  env <- loaded$Environment
  job <- env$mfrmr_gtds5e_job(
    "D5-SHARD-001", loaded$Input, loaded$Admission
  )
  assignment <- job$AssignmentRegistry[
    !job$AssignmentRegistry$IntervalEligible, , drop = FALSE
  ][1L, , drop = FALSE]
  result <- env$mfrmr_gtds5e_result(
    assignment, job, "generation_failure", planned857_opened = TRUE,
    caller_rng_restored = TRUE, error_text = "synthetic_sentinel"
  )
  truth <- data.frame(
    ScenarioId = result$ParentScenarioId, StratumOrdinal = 1L,
    Stratum = "synthetic", EstimandId = "ABS-PHI", Truth = 0.5,
    stringsAsFactors = FALSE
  )
  expect_silent(env$mfrmr_gtds5d_extract_result(
    result, job, assignment, truth
  ))
  changed <- result; changed$ErrorText <- "altered"
  expect_error(
    env$mfrmr_gtds5d_extract_result(changed, job, assignment, truth),
    "result was altered"
  )
  coefficient <- data.frame(
    ScenarioId = result$ConfirmationScenarioId, Stratum = "synthetic",
    G = 0.6, Phi = 0.5, CoefficientReady = TRUE,
    PhiNotGreaterThanG = TRUE, ReferenceMaximumError = 0,
    AttemptId = result$AttemptId,
    ConfirmationScenarioId = result$ConfirmationScenarioId,
    Replicate = result$Replicate,
    OuterRequestHash = result$OuterRequestHash,
    stringsAsFactors = FALSE
  )
  complete <- env$mfrmr_gtds5e_result(
    assignment, job, "complete_point_only",
    primary_coefficients = coefficient, planned857_opened = TRUE,
    response_generated = TRUE, backend_call_made = TRUE,
    caller_rng_restored = TRUE
  )
  extracted <- env$mfrmr_gtds5d_extract_result(
    complete, job, assignment, truth
  )
  expect_true(extracted$Point$EstimateAvailable)
  coefficient$ScenarioId <- result$ParentScenarioId
  malformed <- env$mfrmr_gtds5e_result(
    assignment, job, "complete_point_only",
    primary_coefficients = coefficient, planned857_opened = TRUE,
    response_generated = TRUE, backend_call_made = TRUE,
    caller_rng_restored = TRUE
  )
  expect_error(
    env$mfrmr_gtds5d_extract_result(malformed, job, assignment, truth),
    "coefficient registry is malformed"
  )

  completed <- job$AssignmentRegistry[c(
    "AttemptId", "OuterRequestHash", "InnerBlockHash"
  )]
  completed$ResultHash <- rep(strrep("c", 64L), nrow(completed))
  completed$TerminalStateCount <- 1L
  payload <- list(
    ContractHash = job$Contract$ContractHash,
    JobHash = job$JobHash,
    AdmissionManifestHash = job$AdmissionManifestHash,
    ShardId = job$Shard$ShardId[[1L]],
    ShardHash = job$Shard$ShardHash[[1L]],
    CompletedRegistry = completed,
    TerminalOuterAttemptCount = 300L,
    ExactResumeSupported = TRUE,
    ResultValueUsedForExecutionDecision = FALSE,
    ScientificAdjudicationComputed = FALSE,
    CompleteDenominatorAdjudicationReady = FALSE,
    PublicSupportReady = FALSE
  )
  receipt <- structure(c(payload, list(
    ShardReceiptHash = env$mfrmr_gtds5e_hash(payload)
  )), class = c("mfrmr_gtds5e_shard_receipt", "list"))
  directory <- tempfile("dsim5-blind-sentinel-")
  dir.create(directory)
  on.exit(unlink(directory, recursive = TRUE), add = TRUE)
  expect_error(
    env$mfrmr_gtds5d_read_shard(job, receipt, directory, truth),
    "partial or foreign"
  )
  receipt$TerminalOuterAttemptCount <- 299L
  expect_error(
    env$mfrmr_gtds5d_read_shard(job, receipt, directory, truth),
    "receipt was altered"
  )
})

test_that("bias and coverage rules use planned cells without success pooling", {
  env <- load_gtheory_dsim5d()$Environment
  estimates <- 0.5 + rep(c(-0.1, 0.1), 50L)
  point <- data.frame(
    Estimate = estimates, EstimateAvailable = TRUE, Truth = 0.5
  )
  bias <- env$mfrmr_gtds5d_bias_row(point)
  expect_identical(bias$Disposition, "pass")
  expect_equal(bias$StandardizedBias, 0, tolerance = 1e-12)
  point$EstimateAvailable[[1L]] <- FALSE
  expect_identical(
    env$mfrmr_gtds5d_bias_row(point)$Disposition, "indeterminate"
  )

  interval <- data.frame(
    IntervalAvailable = TRUE,
    Lower = c(rep(0.4, 95L), rep(0.6, 5L)),
    Upper = c(rep(0.6, 95L), rep(0.7, 5L)),
    Truth = 0.5
  )
  coverage <- env$mfrmr_gtds5d_coverage_row(interval)
  expect_identical(coverage$Disposition, "pass")
  expect_equal(coverage$CoverageLower, 0.95)
  expect_equal(coverage$CoverageUpper, 0.95)
  interval$IntervalAvailable[1:20] <- FALSE
  expect_identical(
    env$mfrmr_gtds5d_coverage_row(interval)$Disposition, "fail"
  )
})

test_that("adjudication contract keeps result values from selecting rules", {
  contract <- load_gtheory_dsim5d()$Environment$mfrmr_gtds5d_contract()

  expect_identical(
    contract$EvaluationUnit,
    "confirmation_scenario_by_stratum_by_estimand"
  )
  expect_false(contract$CrossCellPoolingAllowed)
  expect_true(contract$BiasRequiresCompletePlannedCell)
  expect_false(contract$BoundaryOrControlBiasApplied)
  expect_false(contract$ScientificValueMaySelectDefinitionOrThreshold)
  expect_false(contract$Dsim5PassAutomaticallyPromotesPublicSupport)
})
