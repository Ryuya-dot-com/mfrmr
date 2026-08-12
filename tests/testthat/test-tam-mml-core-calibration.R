load_tam_mml_core_calibration <- function() {
  skip_if_not_installed("TAM")
  skip_if_not_installed("digest")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  paths <- file.path(validation, c(
    "conquest-additive-mfrm-design-0.2.3.R",
    "conquest-additive-mfrm-reference-preflight-0.2.3.R",
    "tam-mml-core-calibration-0.2.3.R"
  ))
  skip_if_not(all(file.exists(paths)), "TAM MML calibration is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, env = env)
}

test_that("TAM MML calibration freezes the matched model and runtime identity", {
  ctx <- load_tam_mml_core_calibration()
  plan <- ctx$env$mfrmr_tmc_plan()
  runtime <- ctx$env$mfrmr_tmc_runtime_identity()

  expect_identical(nrow(plan), 4L)
  expect_identical(plan$Model, c("RSM", "RSM", "PCM", "PCM"))
  expect_identical(plan$Nodes, c(31L, 61L, 31L, 61L))
  expect_true(all(plan$Constraint == "cases"))
  expect_true(all(plan$SlopeMode == "fixed_unit"))
  expect_true(all(plan$EvidenceRole == "calibration_only"))
  expect_true(all(runtime$VersionMatch))
  expect_true(all(runtime$FunctionMatch))
})

test_that("TAM MML complete-crossing calibration is finite but nonconfirmatory", {
  ctx <- load_tam_mml_core_calibration()
  result <- ctx$env$mfrmr_run_tam_mml_core_calibration(ctx$root)

  expect_identical(
    result$status,
    "tam_mml_core_calibration_complete_tolerance_candidate_missing"
  )
  expect_true(result$calibration_complete)
  expect_identical(nrow(result$summaries), 4L)
  expect_identical(nrow(result$coordinates), 46L)
  expect_identical(nrow(result$integration), 25L)
  expect_true(all(result$summaries$TAMIterations < 2000L))
  expect_true(all(result$summaries$WarningCount == 0L))
  expect_true(all(result$summaries$MessageCount == 0L))
  expect_true(all(result$summaries$MfrmrOracleLogLikAbsoluteDifference <= 1e-9))
  expect_true(all(
    result$summaries$MfrmrOracleProbabilityMaximumAbsoluteDifference <= 1e-13
  ))

  # This is an engineering regression guard for the observed calibration, not
  # EXT-TAM-TOL and not a scientific-equivalence threshold.
  expect_lt(max(result$coordinates$AbsoluteDifference), 1e-5)
  expect_lt(max(abs(result$summaries$DevianceSignedDifference)), 1e-5)
  expect_lt(max(abs(result$integration$TAMQ61MinusQ31)), 1e-5)
  expect_lt(max(abs(result$integration$MfrmrQ61MinusQ31)), 1e-5)

  expect_false(result$comparison_tolerance_frozen)
  expect_false(result$candidate_bound)
  expect_false(result$comparison_passed)
  expect_false(result$hidden_solution_equivalence_inferred)
  expect_false(result$inference_ready)
  expect_false(result$dff_fit_rank_invariance_evaluated)
  expect_false(result$sparse_extension_authorized)
  expect_false(result$gpcm_extension_authorized)
  expect_false(result$large_simulation_authorized)
  expect_false(result$release_authorized)
})

test_that("TAM cases coordinates isolate location from facet contrasts", {
  ctx <- load_tam_mml_core_calibration()
  fixture <- ctx$env$mfrmr_cq_additive_fixture()
  prepared <- ctx$env$mfrmr_tmc_prepare(fixture)
  tam <- ctx$env$mfrmr_tmc_fit_tam(prepared, "RSM", 31L)$fit
  table <- ctx$env$mfrmr_tmc_tam_parameter_table(
    tam, "RSM", "rsm_q031", 31L
  )

  criterion <- table[table$Facet == "Criterion", , drop = FALSE]
  rater <- table[table$Facet == "Rater", , drop = FALSE]
  intercept <- table$Estimate[
    table$Facet == "Population" & table$Level == "Intercept"
  ]
  raw_item_mean <- mean(tam$xsi.facets$xsi[tam$xsi.facets$facet == "item"])
  expect_equal(sum(criterion$Estimate), 0, tolerance = 1e-12)
  expect_equal(sum(rater$Estimate), 0, tolerance = 1e-12)
  expect_equal(intercept, -raw_item_mean, tolerance = 1e-12)
})

test_that("TAM MML calibration record is source-bound and nonpromotional", {
  ctx <- load_tam_mml_core_calibration()
  record_path <- file.path(
    ctx$validation, "tam-mml-core-calibration-record-0.2.3.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  source_path <- file.path(
    ctx$validation, "tam-mml-core-calibration-0.2.3.R"
  )
  source_hash <- digest::digest(
    source_path, algo = "sha256", file = TRUE, serialize = FALSE
  )
  expect_true(grepl(source_hash, record, fixed = TRUE))
  expect_true(grepl(
    ctx$env$mfrmr_tmc_expected_tam_function_sha256, record, fixed = TRUE
  ))
  expect_true(grepl("ComparisonToleranceFrozen.*FALSE", record))
  expect_true(grepl("CandidateBound.*FALSE", record))
  expect_true(grepl("ComparisonPassed.*FALSE", record))
  expect_true(grepl("GPCMExtensionAuthorized.*FALSE", record))
  expect_true(grepl("ReleaseAuthorized.*FALSE", record))
})
