load_conquest_p2_candidate_004_rank_hold_contract <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-semantic-runtime-preflight-0.2.3.R",
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
    "conquest-p2-candidate-004-mfrmr-preflight-0.2.3.R",
    "conquest-p2-candidate-004-mfrmr-preflight-observation-0.2.3.R",
    "conquest-p2-candidate-004-live-authorization-0.2.3.R",
    "conquest-p2-candidate-004-harness-0.2.3.R",
    "conquest-p2-candidate-004-execution-observation-0.2.3.R",
    "conquest-reported-output-precision-contract-0.2.3.R",
    "conquest-p2-candidate-004-numerical-review-contract-0.2.3.R",
    "conquest-p2-candidate-004-numerical-observation-0.2.3.R",
    "conquest-p2-candidate-004-rank-hold-contract-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "Candidate-004 rank contract is excluded.")
  env <- new.env(parent = globalenv())
  env$`%||%` <- function(x, y) if (is.null(x)) y else x
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("rank-hold layers forbid local-to-global promotion", {
  env <- load_conquest_p2_candidate_004_rank_hold_contract()$env
  layer <- env$mfrmr_cq_p2c4rh_layer_registry()

  expect_identical(nrow(layer), 9L)
  expect_false(any(layer$PassCanClearFitHold))
  expect_identical(
    layer$ExpectedState[layer$Layer == "global_marginal_identification"],
    "not_classified"
  )
  expect_identical(
    layer$ExpectedState[layer$Layer == "continuous_integral_identification"],
    "not_classified"
  )
  expect_identical(
    layer$ExpectedState[layer$Layer == "fit_readiness"], "not_evaluated"
  )
})

test_that("four saved-fit inspections preserve additive and nonlinear dimensions", {
  env <- load_conquest_p2_candidate_004_rank_hold_contract()$env
  plan <- env$mfrmr_cq_p2c4rh_plan()

  expect_identical(plan$RunId, c(
    "rsm_q061", "rsm_q121", "pcm_q061", "pcm_q121"
  ))
  expect_identical(plan$ExpectedFreeDimension, c(10L, 10L, 14L, 14L))
  expect_identical(plan$ExpectedAdditiveDimension, c(9L, 9L, 13L, 13L))
  expect_true(all(plan$ExpectedNonlinearBlock == "log_sigma2"))
  expect_true(all(plan$ReadOnlySavedFitInspection))
  expect_false(any(plan$NewFitAuthorized))
  expect_false(any(plan$ReadinessRewriteAuthorized))
})

test_that("the contract cannot fit, launch, or use ConQuest as rank evidence", {
  ctx <- load_conquest_p2_candidate_004_rank_hold_contract()
  source <- paste(readLines(tail(ctx$paths, 1L), warn = FALSE), collapse = "\n")

  expect_false(grepl("fit_mfrm\\s*\\(|system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("cross_engine_coordinate|ConQuestProbability", source, fixed = FALSE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
  expect_true(grepl("design_rank_hold_resolved = FALSE", source, fixed = TRUE))
  expect_true(grepl("mfrmr_inference_ready = FALSE", source, fixed = TRUE))
})

test_that("record and roadmap preserve the global hold", {
  ctx <- load_conquest_p2_candidate_004_rank_hold_contract()
  record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-p2-candidate-004-rank-hold-contract-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2c4rh_specification, fixed = TRUE)
  expect_match(record, "`DesignRankHoldResolved=FALSE`", fixed = TRUE)
  expect_match(record, "forbids a local layer", fixed = TRUE)
  expect_match(
    roadmap,
    "candidate-004 rank-hold contract is frozen",
    fixed = TRUE
  )
})
