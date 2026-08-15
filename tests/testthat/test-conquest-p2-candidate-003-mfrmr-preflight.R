load_conquest_p2_candidate_003_mfrmr_preflight <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-p2-metric-boundary-contract-0.2.3.R",
    "conquest-p2-replacement-nondegenerate-fixture-0.2.3.R",
    "conquest-p2-candidate-003-coverage-conditioned-fixture-0.2.3.R",
    "conquest-p2-candidate-003-mfrmr-preflight-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "Candidate-003 preflight is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("the unopened preflight has exactly four mfrmr arms", {
  ctx <- load_conquest_p2_candidate_003_mfrmr_preflight()
  review <- ctx$env$mfrmr_cq_p2c3p_review()
  plan <- review$plan

  expect_identical(
    review$status, "mfrmr_preflight_contract_frozen_execution_unopened"
  )
  expect_identical(review$fit_cap, 4L)
  expect_identical(
    review$frozen_output_basename,
    "conquest-p2-candidate-003-mfrmr-preflight-20260815-v1"
  )
  expect_identical(plan$Family, c("RSM", "RSM", "PCM", "PCM"))
  expect_identical(plan$Nodes, c(31L, 61L, 31L, 61L))
  expect_identical(plan$ExpectedNpar, c(10L, 10L, 14L, 14L))
  expect_identical(
    plan$ExpectedExpandedCoordinateCount, c(13L, 13L, 19L, 19L)
  )
  expect_true(all(plan$MinimumPopulationVariance == 0.05))
  expect_true(all(plan$QCoordinateAbsoluteTolerance == 2e-6))
  expect_true(all(plan$QDevianceAbsoluteTolerance == 2e-6))
  expect_true(all(plan$FitAttemptCap == 1L))
  expect_false(review$design_rank_not_evaluated_is_inference_ready)
  expect_false(review$truth_recovery_authorized)
  expect_false(review$external_execution_authorized)
  expect_false(review$evidence_promotion_authorized)
})

test_that("all arms use identical candidate data and frozen fit arguments", {
  ctx <- load_conquest_p2_candidate_003_mfrmr_preflight()
  env <- ctx$env
  fixture <- env$mfrmr_cq_p2c3p_fixture()
  plan <- env$mfrmr_cq_p2c3p_plan()

  expect_identical(nrow(fixture$long), 288L)
  expect_identical(nrow(fixture$person), 48L)
  expect_identical(sort(unique(fixture$long$Score)), 0:3)
  for (index in seq_len(nrow(plan))) {
    args <- env$mfrmr_cq_p2c3p_fit_arguments(
      plan$Family[index], plan$Nodes[index], fixture
    )
    expect_identical(args$data, fixture$long)
    expect_identical(args$person_data, fixture$person)
    expect_identical(args$method, "MML")
    expect_identical(args$model, plan$Family[index])
    expect_identical(args$quad_points, plan$Nodes[index])
    expect_identical(args$mml_engine, "direct")
    expect_identical(args$maxit, 2000L)
    expect_identical(args$reltol, 1e-12)
    expect_identical("step_facet" %in% names(args),
                     plan$Family[index] == "PCM")
  }
})

candidate_003_gate_summary <- function(
    npar = 10L, sigma2 = 0.4, inference_ready = FALSE,
    fit_readiness = "review", estimability = "not_evaluated",
    reason = "design_rank_not_evaluated", severity = "pass") {
  summary <- data.frame(
    Npar = npar, InferenceReady = inference_ready,
    FitReadiness = fit_readiness, EstimabilityState = estimability,
    ReadinessReasonCodes = reason, ConvergenceStatus = "converged",
    ConvergenceSeverity = severity, NumericalState = "ready",
    BoundaryState = "finite", TerminalGradientSupNorm = 1e-6,
    stringsAsFactors = FALSE
  )
  list(summary = summary, sigma2 = sigma2)
}

test_that("the only permitted readiness hold is not relabelled inference-ready", {
  ctx <- load_conquest_p2_candidate_003_mfrmr_preflight()
  env <- ctx$env
  held <- candidate_003_gate_summary()
  gate <- env$mfrmr_cq_p2c3p_fit_gate(held$summary, held$sigma2, 10L)

  expect_false(gate$InferenceReady)
  expect_true(gate$OnlyDesignRankNotEvaluatedHold)
  expect_true(gate$ReadinessStateRetained)
  expect_true(gate$StructuralNumericalPass)
  expect_false(gate$ExternalExecutionAuthorized)
  expect_false(gate$EvidencePromotionAuthorized)

  other <- candidate_003_gate_summary(reason = "another_readiness_hold")
  other_gate <- env$mfrmr_cq_p2c3p_fit_gate(
    other$summary, other$sigma2, 10L
  )
  expect_false(other_gate$OnlyDesignRankNotEvaluatedHold)
  expect_false(other_gate$StructuralNumericalPass)
})

test_that("dimension, numerical, and population-boundary failures stop", {
  ctx <- load_conquest_p2_candidate_003_mfrmr_preflight()
  env <- ctx$env
  wrong_dimension <- candidate_003_gate_summary(npar = 9L)
  collapsed <- candidate_003_gate_summary(sigma2 = 0.049)
  failed <- candidate_003_gate_summary(severity = "fail")

  expect_false(env$mfrmr_cq_p2c3p_fit_gate(
    wrong_dimension$summary, wrong_dimension$sigma2, 10L
  )$StructuralNumericalPass)
  expect_false(env$mfrmr_cq_p2c3p_fit_gate(
    collapsed$summary, collapsed$sigma2, 10L
  )$StructuralNumericalPass)
  expect_false(env$mfrmr_cq_p2c3p_fit_gate(
    failed$summary, failed$sigma2, 10L
  )$StructuralNumericalPass)
})

test_that("q review requires both frozen movement budgets", {
  ctx <- load_conquest_p2_candidate_003_mfrmr_preflight()
  env <- ctx$env
  plan <- env$mfrmr_cq_p2c3p_plan()
  fit_summary <- data.frame(
    Family = plan$Family, Nodes = plan$Nodes,
    Deviance = c(100, 100 + 1e-6, 120, 120 + 1e-6),
    StructuralNumericalPass = TRUE, stringsAsFactors = FALSE
  )
  coordinates <- do.call(rbind, lapply(seq_len(nrow(plan)), function(index) {
    count <- plan$ExpectedExpandedCoordinateCount[index]
    data.frame(
      Family = plan$Family[index], Nodes = plan$Nodes[index],
      Coordinate = paste0("Coordinate::", seq_len(count)),
      Estimate = seq_len(count) / 10 +
        if (plan$Nodes[index] == 61L) 1e-6 else 0,
      stringsAsFactors = FALSE
    )
  }))
  passed <- env$mfrmr_cq_p2c3p_q_review(fit_summary, coordinates, plan)
  expect_true(all(passed$Passed))

  coordinates$Estimate[
    coordinates$Family == "PCM" & coordinates$Nodes == 61L &
      coordinates$Coordinate == "Coordinate::19"
  ] <- 1.9 + 3e-6
  failed <- env$mfrmr_cq_p2c3p_q_review(fit_summary, coordinates, plan)
  expect_true(failed$Passed[failed$Family == "RSM"])
  expect_false(failed$Passed[failed$Family == "PCM"])
  expect_identical(
    failed$FailureOutcome[failed$Family == "PCM"], "integration_unresolved"
  )
})

test_that("execution is opt-in, new-directory-only, and ConQuest-free", {
  ctx <- load_conquest_p2_candidate_003_mfrmr_preflight()
  env <- ctx$env
  output_dir <- file.path(withr::local_tempdir(), "held")
  expect_error(
    env$mfrmr_cq_p2c3p_execute(output_dir, authorize = FALSE),
    "Execution is held",
    fixed = TRUE
  )
  expect_false(dir.exists(output_dir))
  wrong <- file.path(withr::local_tempdir(), "wrong-candidate-path")
  expect_error(
    env$mfrmr_cq_p2c3p_execute(wrong, authorize = TRUE),
    "basename is not the frozen candidate path",
    fixed = TRUE
  )
  expect_false(dir.exists(wrong))
  source <- paste(readLines(ctx$paths[7L], warn = FALSE), collapse = "\n")
  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("/Applications/ConQuest", source, fixed = TRUE))
  expect_false(grepl("unlink\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("the record keeps the consumed failure and claim authority closed", {
  ctx <- load_conquest_p2_candidate_003_mfrmr_preflight()
  record_path <- file.path(
    ctx$validation,
    "conquest-p2-candidate-003-mfrmr-preflight-record-0.2.3.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  expect_match(record, ctx$env$mfrmr_cq_p2c3p_specification, fixed = TRUE)
  expect_match(record, ctx$env$mfrmr_cq_p2c3p_contract, fixed = TRUE)
  expect_match(record, "population variance of at least 0.05", fixed = TRUE)
  expect_match(record, "`2e-6`", fixed = TRUE)
  expect_match(record, "`MfrmrPreflightExecutionOpened=TRUE`", fixed = TRUE)
  expect_match(record, "`MfrmrPreflightExecutionConsumed=TRUE`", fixed = TRUE)
  expect_match(record, "`ExternalExecutionAuthorized=FALSE`", fixed = TRUE)
})
