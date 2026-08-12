load_immer_conditional_estimand_eligibility <- function() {
  skip_if_not_installed("immer")
  skip_if_not_installed("digest")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  path <- file.path(
    root, "inst", "validation",
    "immer-conditional-estimand-eligibility-0.2.3.R"
  )
  skip_if_not(file.exists(path), "immer conditional contract is excluded.")
  env <- new.env(parent = globalenv())
  sys.source(path, envir = env)
  list(root = root, path = path, env = env)
}

test_that("immer conditional routes are source and help-topic bound", {
  ctx <- load_immer_conditional_estimand_eligibility()
  runtime <- ctx$env$mfrmr_icee_runtime_identity()
  expect_identical(runtime$Route, c("CML", "CCML"))
  expect_identical(runtime$PrimaryFunction, c("immer_cml", "immer_ccml"))
  expect_true(all(runtime$VersionMatch))
  expect_true(all(runtime$FunctionMatch))
  expect_true(all(runtime$HelpTopic == runtime$PrimaryFunction))
})

test_that("immer conditioning eliminates person and population estimands", {
  ctx <- load_immer_conditional_estimand_eligibility()
  registry <- ctx$env$mfrmr_icee_registry()
  eliminated <- registry$EstimandClass %in%
    c("person_parameter", "population_parameter")
  expect_identical(nrow(registry), 22L)
  expect_identical(as.integer(table(registry$Route)[c("CCML", "CML")]),
                   c(11L, 11L))
  expect_true(all(grepl("eliminated_by_conditioning",
                        registry$ReasonCode[eliminated], fixed = TRUE)))
  expect_true(all(!registry$ExactStructuralEstimandEligible[eliminated]))
  expect_true(all(!registry$CanValidatePersonAbility))
  expect_true(all(!registry$CanValidatePopulationDistribution))
})

test_that("immer structural rows require exact design and constraint maps", {
  ctx <- load_immer_conditional_estimand_eligibility()
  registry <- ctx$env$mfrmr_icee_registry()
  eligible <- registry$ExactStructuralEstimandEligible
  expect_identical(sum(eligible), 8L)
  expect_true(all(registry$EstimandClass[eligible] == "structural_parameter"))
  expect_true(all(registry$RequiresExactDesignMatrix[eligible]))
  expect_true(all(registry$RequiresMatchedCategorySupport[eligible]))
  expect_true(all(registry$RequiresMatchedConstraintTransform[eligible]))
  expect_true(all(!registry$ExactMfrmrObjectiveEligible))
  expect_true(all(!registry$CanEnterMMLOrJMLObjectiveAggregate))
})

test_that("immer CML and CCML objectives and slopes fail closed", {
  ctx <- load_immer_conditional_estimand_eligibility()
  registry <- ctx$env$mfrmr_icee_registry()
  objective <- registry[registry$Estimand == "objective_value", ]
  slope <- registry[registry$Estimand == "free_discrimination", ]
  expect_true(grepl("conditional_objective_not_mml_or_jml_objective",
                    objective$ReasonCode[objective$Route == "CML"], fixed = TRUE))
  expect_true(grepl("composite_conditional_objective_not_full_likelihood",
                    objective$ReasonCode[objective$Route == "CCML"], fixed = TRUE))
  expect_true(all(!slope$ExactStructuralEstimandEligible))
  expect_true(all(!slope$CanValidateFreeGPCMSlope))
})

test_that("immer conditional boundary is review-ready but nonpromotional", {
  ctx <- load_immer_conditional_estimand_eligibility()
  review <- ctx$env$mfrmr_icee_review()
  expect_identical(
    review$status,
    "immer_conditional_estimand_boundary_ready_candidate_missing"
  )
  expect_true(review$boundary_ready)
  expect_identical(review$structural_estimand_rows, 8L)
  expect_identical(review$exact_objective_rows, 0L)
  expect_false(review$fitted_comparison_run)
  expect_false(review$tolerance_frozen)
  expect_false(review$candidate_bound)
  expect_false(review$comparison_passed)
  expect_false(review$scientific_equivalence_inferred)
  expect_false(review$native_mfrmr_cml_claim)
  expect_false(review$native_mfrmr_ccml_claim)
  expect_false(review$free_gpcm_slope_claim)
  expect_false(review$dff_fit_rank_invariance_evaluated)
  expect_false(review$large_simulation_authorized)
  expect_false(review$release_authorized)
})

test_that("immer conditional record is source-bound", {
  ctx <- load_immer_conditional_estimand_eligibility()
  record_path <- file.path(
    dirname(ctx$path),
    "immer-conditional-estimand-eligibility-record-0.2.3.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  source_hash <- digest::digest(
    ctx$path, algo = "sha256", file = TRUE, serialize = FALSE
  )
  expect_true(grepl(source_hash, record, fixed = TRUE))
  expect_true(all(vapply(
    ctx$env$mfrmr_icee_expected_function_sha256,
    grepl, logical(1L), x = record, fixed = TRUE
  )))
  expect_true(grepl("StructuralEstimandRows.*8", record))
  expect_true(grepl("ExactObjectiveRows.*0", record))
  expect_true(grepl("ComparisonPassed.*FALSE", record))
  expect_true(grepl("FreeGPCMSlopeClaim.*FALSE", record))
  expect_true(grepl("ReleaseAuthorized.*FALSE", record))
})
