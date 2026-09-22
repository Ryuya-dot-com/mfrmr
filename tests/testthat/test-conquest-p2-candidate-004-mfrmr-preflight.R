load_conquest_p2_candidate_004_mfrmr_preflight <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-p2-metric-boundary-contract-0.2.3.R",
    "conquest-p2-replacement-nondegenerate-fixture-0.2.3.R",
    "conquest-p2-candidate-003-coverage-conditioned-fixture-0.2.3.R",
    "conquest-p2-candidate-003-mfrmr-preflight-0.2.3.R",
    "conquest-p2-successor-integration-contract-0.2.3.R",
    "conquest-p2-adaptive-density-contract-0.2.3.R",
    "conquest-p2-log-centered-continuous-oracle-0.2.3.R",
    "conquest-p2-log-centered-continuous-oracle-observation-0.2.3.R",
    "conquest-p2-candidate-004-coverage-conditioned-fixture-0.2.3.R",
    "conquest-p2-candidate-004-fixture-observation-0.2.3.R",
    "conquest-p2-candidate-004-mfrmr-preflight-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "Candidate-004 preflight is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("the unopened preflight freezes six initial and two conditional fits", {
  ctx <- load_conquest_p2_candidate_004_mfrmr_preflight()
  review <- ctx$env$mfrmr_cq_p2c4p_review()
  plan <- review$plan

  expect_identical(
    review$status,
    "candidate_004_mfrmr_preflight_contract_frozen_execution_unopened"
  )
  expect_identical(review$initial_fit_cap, 6L)
  expect_identical(review$conditional_fit_cap, 2L)
  expect_identical(review$total_fit_cap, 8L)
  expect_identical(plan$Family, rep(c("RSM", "PCM"), each = 4L))
  expect_identical(plan$Nodes, rep(c(31L, 61L, 121L, 241L), times = 2L))
  expect_identical(sum(plan$ExecutionPhase == "initial"), 6L)
  expect_identical(
    sum(plan$ExecutionPhase == "conditional_dense_pair_2"), 2L
  )
  expect_true(review$q241_runs_only_after_complete_dense_pair_1_failure)
  expect_false(review$q31_governing)
  expect_true(review$mfrmr_preflight_execution_authorized)
  expect_false(review$external_execution_authorized)
})

test_that("dimensions and numerical budgets are inherited without tuning", {
  ctx <- load_conquest_p2_candidate_004_mfrmr_preflight()
  plan <- ctx$env$mfrmr_cq_p2c4p_plan()

  expect_identical(plan$ExpectedNpar, rep(c(10L, 14L), each = 4L))
  expect_identical(
    plan$ExpectedExpandedCoordinateCount, rep(c(13L, 19L), each = 4L)
  )
  expect_true(all(plan$MinimumPopulationVariance == 0.05))
  expect_true(all(plan$DenseCoordinateAbsoluteTolerance == 2e-6))
  expect_true(all(plan$DenseDevianceAbsoluteTolerance == 2e-6))
  expect_true(all(plan$UpperContinuousDevianceTolerance == 1e-7))
  expect_true(all(plan$DeclaredContinuousErrorBoundTolerance == 1e-8))
  expect_true(all(plan$FitAttemptCap == 1L))
  expect_false(any(plan$Candidate003OutputTuned))
})

test_that("all arms use the same explicit fitting contract", {
  ctx <- load_conquest_p2_candidate_004_mfrmr_preflight()
  env <- ctx$env
  fixture <- list(
    long = data.frame(Person = "P001", Rater = "R1", Criterion = "C1", Score = 0L),
    person = data.frame(Person = "P001", X = -1)
  )
  plan <- env$mfrmr_cq_p2c4p_plan()
  for (index in seq_len(nrow(plan))) {
    args <- env$mfrmr_cq_p2c4p_fit_arguments(
      plan$Family[index], plan$Nodes[index], fixture
    )
    expect_identical(args$data, fixture$long)
    expect_identical(args$person_data, fixture$person)
    expect_identical(args$model, plan$Family[index])
    expect_identical(args$quad_points, plan$Nodes[index])
    expect_identical(args$mml_engine, "direct")
    expect_identical(args$maxit, 2000L)
    expect_identical(args$reltol, 1e-12)
    expect_identical("step_facet" %in% names(args), plan$Family[index] == "PCM")
  }
})

candidate_004_stage_metrics <- function(stage_1_pass = TRUE, stage_2_pass = TRUE) {
  rows <- expand.grid(
    ArmId = c("RSM", "PCM"),
    Stage = c("dense_pair_1", "dense_pair_2"),
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  rows$LowerNodes <- ifelse(rows$Stage == "dense_pair_1", 61L, 121L)
  rows$UpperNodes <- ifelse(rows$Stage == "dense_pair_1", 121L, 241L)
  rows$CoordinateMovement <- 1e-6
  rows$DevianceMovement <- 1e-6
  rows$UpperContinuousDevianceMovement <- 1e-8
  rows$CompleteCoordinateDenominator <- TRUE
  rows$SelectedPairStructuralPass <- TRUE
  rows$ContinuousNumericalContractPassed <- TRUE
  rows$Finite <- TRUE
  if (!stage_1_pass) {
    rows$CoordinateMovement[rows$Stage == "dense_pair_1" & rows$ArmId == "PCM"] <- 3e-6
  }
  if (!stage_2_pass) {
    rows$DevianceMovement[rows$Stage == "dense_pair_2" & rows$ArmId == "PCM"] <- 3e-6
  }
  rows
}

test_that("the lowest whole-slice dense pair is selected and q241 is capped", {
  ctx <- load_conquest_p2_candidate_004_mfrmr_preflight()
  select <- ctx$env$mfrmr_cq_p2c4p_select_stage

  first <- select(candidate_004_stage_metrics())
  expect_identical(first$selected_stage, "dense_pair_1")
  expect_identical(first$selected_upper_nodes, 121L)

  second <- select(candidate_004_stage_metrics(stage_1_pass = FALSE))
  expect_identical(second$selected_stage, "dense_pair_2")
  expect_identical(second$selected_upper_nodes, 241L)

  stopped <- select(candidate_004_stage_metrics(FALSE, FALSE))
  expect_identical(
    stopped$status, "no_predeclared_dense_pair_passed_stop_at_q241"
  )
  expect_false(stopped$further_expansion_authorized)
  expect_false(stopped$threshold_change_authorized)
})

test_that("structural, denominator, and continuous failures cannot select", {
  ctx <- load_conquest_p2_candidate_004_mfrmr_preflight()
  select <- ctx$env$mfrmr_cq_p2c4p_select_stage
  fields <- c(
    "CompleteCoordinateDenominator", "SelectedPairStructuralPass",
    "ContinuousNumericalContractPassed", "Finite"
  )
  for (field in fields) {
    metrics <- candidate_004_stage_metrics()
    metrics[[field]][metrics$ArmId == "PCM"] <- FALSE
    expect_identical(
      select(metrics)$status,
      "no_predeclared_dense_pair_passed_stop_at_q241"
    )
  }
})

test_that("execution is opt-in, new-directory-only, and ConQuest-free", {
  ctx <- load_conquest_p2_candidate_004_mfrmr_preflight()
  env <- ctx$env
  output_dir <- file.path(withr::local_tempdir(), "held")
  expect_error(
    env$mfrmr_cq_p2c4p_execute(output_dir, authorize = FALSE),
    "Execution is held", fixed = TRUE
  )
  wrong <- file.path(withr::local_tempdir(), "wrong-candidate-path")
  expect_error(
    env$mfrmr_cq_p2c4p_execute(wrong, authorize = TRUE),
    "basename is not the frozen candidate path", fixed = TRUE
  )
  source <- paste(readLines(ctx$paths[14L], warn = FALSE), collapse = "\n")
  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("/Applications/ConQuest", source, fixed = TRUE))
  expect_false(grepl("unlink\\s*\\(", source, perl = TRUE))
  expect_false(grepl(
    "mfrmr_cq_p2_probability\\s*\\(", source, perl = TRUE
  ))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("frozen record stays unopened while roadmap records the later run", {
  ctx <- load_conquest_p2_candidate_004_mfrmr_preflight()
  record_path <- file.path(
    ctx$validation,
    "conquest-p2-candidate-004-mfrmr-preflight-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2c4p_specification, fixed = TRUE)
  expect_match(record, "`MfrmrPreflightExecutionOpened=FALSE`", fixed = TRUE)
  expect_match(record, "generating truth", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Freeze and run a candidate-004 mfrmr-only preflight",
    fixed = TRUE
  )
})
