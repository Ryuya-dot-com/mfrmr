load_conquest_p2_candidate_004_mfrmr_preflight_observation <- function() {
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
    "conquest-p2-candidate-004-mfrmr-preflight-0.2.3.R",
    "conquest-p2-candidate-004-mfrmr-preflight-observation-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "Candidate-004 observation is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("six expected fits pass structural and numerical gates only", {
  ctx <- load_conquest_p2_candidate_004_mfrmr_preflight_observation()
  review <- ctx$env$mfrmr_cq_p2c4po_review()
  fits <- review$fit_summary

  expect_identical(nrow(fits), 6L)
  expect_identical(fits$Nodes, rep(c(31L, 61L, 121L), times = 2L))
  expect_identical(fits$ObservedNpar, fits$ExpectedNpar)
  expect_true(all(fits$StructuralNumericalPass))
  expect_true(all(fits$PopulationVariance >= 0.05))
  expect_false(any(fits$InferenceReady))
  expect_true(all(fits$OnlyDesignRankNotEvaluatedHold))
  expect_false(review$design_rank_not_evaluated_is_inference_ready)
  expect_true(review$six_initial_fits_attempted)
})

test_that("q31 remains diagnostic while q61--q121 governs", {
  ctx <- load_conquest_p2_candidate_004_mfrmr_preflight_observation()
  review <- ctx$env$mfrmr_cq_p2c4po_review()

  expect_false(any(review$diagnostic$Governing))
  expect_true(all(
    review$diagnostic$MaximumAbsoluteQ31Q61CoordinateMovement > 2e-6
  ))
  expect_true(all(review$diagnostic$AbsoluteQ31Q61DevianceMovement > 2e-6))
  expect_true(all(review$dense_stage_metrics$CoordinateMovement <= 2e-6))
  expect_true(all(review$dense_stage_metrics$DevianceMovement <= 2e-6))
  expect_true(all(
    review$dense_stage_metrics$UpperContinuousDevianceMovement <= 1e-7
  ))
  expect_true(all(
    review$dense_stage_metrics$DeclaredContinuousDevianceErrorBound <= 1e-8
  ))
  expect_true(review$dense_pair_1_selected)
  expect_false(review$q241_attempted)
})

test_that("the consumed pass authorizes review but not external execution", {
  ctx <- load_conquest_p2_candidate_004_mfrmr_preflight_observation()
  review <- ctx$env$mfrmr_cq_p2c4po_review()

  expect_identical(
    review$status,
    "candidate_004_mfrmr_preflight_passed_external_review_required"
  )
  expect_true(review$eligible_for_new_external_authorization_review)
  expect_false(review$external_execution_authorized)
  expect_false(review$evidence_promotion_authorized)
  expect_false(review$truth_recovery_authorized)
  expect_false(review$candidate_003_reclassified)
  expect_false(review$scientific_equivalence_inferred)
})

test_that("the observation cannot fit, integrate, read artifacts, or launch", {
  ctx <- load_conquest_p2_candidate_004_mfrmr_preflight_observation()
  source <- paste(readLines(ctx$paths[15L], warn = FALSE), collapse = "\n")

  expect_false(grepl("fit_mfrm\\s*\\(|p2c4p_execute\\s*\\(", source, perl = TRUE))
  expect_false(grepl("integrate\\s*\\(|optimize\\s*\\(", source, perl = TRUE))
  expect_false(grepl("readRDS\\s*\\(|read[.]csv\\s*\\(", source, perl = TRUE))
  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("record and roadmap retain the exact next authorization boundary", {
  ctx <- load_conquest_p2_candidate_004_mfrmr_preflight_observation()
  record_path <- file.path(
    ctx$validation,
    "conquest-p2-candidate-004-mfrmr-preflight-observation-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2c4po_specification, fixed = TRUE)
  expect_match(record, "`Q241Attempted=FALSE`", fixed = TRUE)
  expect_match(record, "`ExternalExecutionAuthorized=FALSE`", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Freeze and run a candidate-004 mfrmr-only preflight",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[ ] Bind a fit-eligible candidate 004",
    fixed = TRUE
  )
})
