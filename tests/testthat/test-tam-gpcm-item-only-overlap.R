load_tam_gpcm_item_only_overlap <- function() {
  skip_if_not_installed("TAM")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  source_path <- file.path(
    root, "inst", "validation", "tam-gpcm-item-only-overlap-0.2.3.R"
  )
  record_path <- file.path(
    root, "inst", "validation",
    "tam-gpcm-item-only-overlap-record-0.2.3.md"
  )
  expect_true(file.exists(source_path))
  expect_true(file.exists(record_path))
  env <- new.env(parent = globalenv())
  sys.source(source_path, envir = env)
  list(
    root = root, env = env, source_path = source_path,
    record_path = record_path
  )
}

test_that("TAM GPCM overlap keeps the item-only boundary explicit", {
  context <- load_tam_gpcm_item_only_overlap()
  plan <- context$env$mfrmr_tgio_plan()

  expect_identical(plan$Nodes, c(31L, 41L))
  expect_true(all(plan$Scope == "item_only_no_rater_facet"))
  expect_true(all(plan$TAMRoute == "tam.mml.2pl"))
  expect_true(all(plan$MfrmrSlopeOwner == "Criterion"))
  expect_true(all(grepl("different_fixed_grid_rules", plan$IntegrationComparison)))

  source_text <- paste(readLines(context$source_path), collapse = "\n")
  record_text <- paste(readLines(context$record_path), collapse = "\n")
  cryptographic_term <- "\\bSHA(?:-[0-9]+)?\\b|digest::|\\bmd5\\b"
  expect_false(grepl(
    cryptographic_term, source_text, ignore.case = TRUE, perl = TRUE
  ))
  expect_false(grepl(
    cryptographic_term, record_text, ignore.case = TRUE, perl = TRUE
  ))
  expect_match(record_text, "FullManyFacetGPCMCompared = FALSE", fixed = TRUE)
  expect_match(record_text, "InferenceReadinessOverridden = FALSE", fixed = TRUE)
})

test_that("TAM and mfrmr agree on the bounded item-only GPCM overlap", {
  context <- load_tam_gpcm_item_only_overlap()
  result <- context$env$mfrmr_run_tam_gpcm_item_only_overlap()

  expect_identical(
    result$status,
    "bounded_item_only_gpcm_overlap_complete"
  )
  expect_identical(nrow(result$summaries), 2L)
  expect_identical(nrow(result$parameters), 34L)
  expect_true(all(result$summaries$TAMIterations < 1000L))
  expect_true(all(result$summaries$TAMWarningCount == 0L))
  expect_true(all(result$summaries$MfrmrWarningCount == 0L))
  expect_lt(
    max(result$summaries$CoordinateMapIdentityMaxAbsDifference),
    1e-12
  )

  # Broad engineering guards for this fixed external fixture.  They are not
  # scientific equivalence thresholds and are not a readiness criterion.
  expect_lt(max(abs(result$summaries$DevianceSignedDifference)), 1e-3)
  expect_lt(max(result$summaries$SlopeMaxAbsDifference), 1e-3)
  expect_lt(max(result$summaries$ThresholdMaxAbsDifference), 1e-3)
  expect_lt(max(result$summaries$FittedProbabilityMaxAbsDifference), 1e-3)
  expect_lt(max(result$stability$SlopeMaxAbsQ41MinusQ31), 1e-3)
  expect_lt(max(result$stability$ThresholdMaxAbsQ41MinusQ31), 1e-3)
  expect_lt(
    max(result$stability$PopulationVarianceAbsQ41MinusQ31),
    1e-3
  )

  expect_false(result$full_many_facet_gpcm_compared)
  expect_true(result$common_continuous_likelihood_target)
  expect_false(result$identical_finite_quadrature_rule)
  expect_false(result$cross_engine_se_comparison_available)
  expect_false(result$inference_readiness_overridden)
  expect_false(result$comparison_tolerance_frozen)
  expect_false(result$release_authorized)
  expect_true(all(!result$summaries$MfrmrInferenceReady))
})
