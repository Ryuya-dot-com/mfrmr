load_conquest_candidate_003_numerical_review <- function() {
  skip_if_not_installed("digest")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-prospective-tolerance-contract-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-six-arm-candidate-binding-0.2.3.R",
    "conquest-six-arm-candidate-reference-preflight-0.2.3.R",
    "conquest-six-arm-candidate-003-binding-0.2.3.R",
    "conquest-six-arm-candidate-003-reference-preflight-0.2.3.R",
    "conquest-six-arm-candidate-003-execution-handoff-0.2.3.R",
    "conquest-six-arm-candidate-003-execution-result-0.2.3.R",
    "conquest-additive-mfrm-design-0.2.3.R",
    "conquest-numeric-resolution-contract-0.2.3.R",
    "conquest-additive-native-rsm-q31-review-0.2.3.R",
    "conquest-additive-native-pcm-q31-review-0.2.3.R",
    "conquest-additive-native-four-arm-review-0.2.3.R",
    "conquest-reported-output-precision-contract-0.2.3.R",
    "conquest-binary-external-comparison-normalizer-0.2.3.R",
    "conquest-external-comparison-normalizer-0.2.3.R",
    "conquest-six-arm-candidate-003-numerical-review-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(
    all(file.exists(paths)),
    "Repository-only candidate-003 numerical review is excluded."
  )
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, env = env)
}

test_that("candidate-003 reported-decimal coordinate bundle is exact", {
  ctx <- load_conquest_candidate_003_numerical_review()
  candidate_root <- file.path(
    ctx$root, ctx$env$mfrmr_cq_c3_candidate_root
  )
  if (dir.exists(candidate_root)) {
    coordinate <- ctx$env$mfrmr_cq_c3nr_coordinate_rows(candidate_root)
    rows <- coordinate$rows
    expect_identical(nrow(rows), 54L)
    expect_identical(
      as.integer(table(rows$Family)[c("Binary", "PCM", "RSM")]),
      c(18L, 20L, 16L)
    )
    expect_false(anyDuplicated(
      paste(rows$Family, rows$Nodes, rows$Coordinate)
    ) > 0L)
    expect_true(all(is.finite(rows$NativeValue)))
    expect_true(all(is.finite(rows$MfrmrReferenceValue)))
    expect_true(all(rows$SourcePrecisionStatus == "match"))
    expect_true(coordinate$additive_review$native_design_matrices_exact)
    expect_true(coordinate$additive_review$four_arms_complete)
    expect_false(
      coordinate$additive_policy$hidden_solution_equivalence_eligible
    )
    expect_false(
      coordinate$binary_policy$hidden_solution_equivalence_eligible
    )
    expect_identical(
      ctx$env$mfrmr_cq_c3nr_coordinate_hash(rows),
      "77ada46c876b3280b054f423b6a5717e71643ad65716796256f92c08c90b0dac"
    )
  } else {
    expect_false(dir.exists(candidate_root))
  }
})

test_that("all 57 prospective candidate-003 rows pass", {
  ctx <- load_conquest_candidate_003_numerical_review()
  candidate_root <- file.path(
    ctx$root, ctx$env$mfrmr_cq_c3_candidate_root
  )
  if (dir.exists(candidate_root)) {
    review <- ctx$env$mfrmr_cq_c3nr_review(candidate_root)
    expect_identical(
      review$status,
      "candidate_003_exact_reported_decimal_all_57_rows_pass"
    )
    expect_true(review$bundle_identity_ok)
    expect_identical(review$coordinate_rows_observed, 54L)
    expect_identical(review$tolerance_rows_expected, 57L)
    expect_identical(review$tolerance_rows_observed, 57L)
    expect_identical(review$tolerance_rows_passed, 57L)
    expect_identical(review$cross_engine_rows_passed, 19L)
    expect_identical(review$integration_rows_passed, 38L)
    expect_true(all(review$tolerance_ledger$SignedPass))
    expect_true(all(review$tolerance_ledger$AbsolutePass))
    expect_true(all(review$tolerance_ledger$RowPass))
    expect_identical(
      review$ledger_bundle_sha256,
      "8a248d978ee4b319351110404380caa242bf58e4cb20abbd9d3d745b45c2b8f0"
    )
    expect_true(review$comparison_passed)
    expect_true(review$reported_decimal_confirmation_passed)
    expect_identical(review$source_precision_scope, "exact_reported_decimal")
    expect_false(review$hidden_solution_interval_available)
    expect_false(review$hidden_solution_equivalence_eligible)
    expect_false(review$scientific_equivalence_inferred)
    expect_false(review$inference_ready)
    expect_false(review$dff_fit_rank_invariance_evaluated)
    expect_false(review$generic_confirmation_authorized)
    expect_false(review$release_authorized)
    expect_false(review$sparse_extension_authorized)
    expect_false(review$gpcm_extension_authorized)
    expect_false(review$large_simulation_authorized)
  } else {
    expect_false(dir.exists(candidate_root))
  }
})

test_that("the 57-row adjudicator rejects an out-of-budget coordinate", {
  ctx <- load_conquest_candidate_003_numerical_review()
  candidate_root <- file.path(
    ctx$root, ctx$env$mfrmr_cq_c3_candidate_root
  )
  if (dir.exists(candidate_root)) {
    coordinate <- ctx$env$mfrmr_cq_c3nr_coordinate_rows(candidate_root)$rows
    index <- which(
      coordinate$Family == "Binary" & coordinate$Nodes == 31L &
        coordinate$ParameterClass == "population_variance"
    )
    expect_identical(length(index), 1L)
    coordinate$SignedReportedDifference[index] <- 1e-3
    coordinate$AbsoluteReportedDifference[index] <- 1e-3
    ledger <- ctx$env$mfrmr_cq_c3nr_tolerance_ledger(
      coordinate, ctx$env$mfrmr_cq_ptf_build_tolerances()
    )$ledger
    failed <- ledger[
      ledger$CriterionId == "EXT-CQ-TOL" &
        ledger$Family == "Binary" &
        ledger$EstimandClass == "population_variance", , drop = FALSE
    ]
    expect_identical(nrow(failed), 1L)
    expect_false(failed$SignedPass)
    expect_false(failed$AbsolutePass)
    expect_false(failed$RowPass)
    expect_identical(sum(!ledger$RowPass), 1L)
  } else {
    expect_false(dir.exists(candidate_root))
  }
})

test_that("candidate-003 numerical-review record is source-bound", {
  ctx <- load_conquest_candidate_003_numerical_review()
  record_path <- file.path(
    ctx$validation,
    "conquest-six-arm-candidate-003-numerical-review-record-0.2.3.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  artifacts <- c(
    file.path(
      ctx$validation,
      c(
        "conquest-six-arm-candidate-003-numerical-review-0.2.3.R",
        "conquest-six-arm-candidate-003-execution-result-0.2.3.R"
      )
    ),
    file.path(
      ctx$root, "tests", "testthat",
      "test-conquest-six-arm-candidate-003-numerical-review.R"
    )
  )
  hashes <- vapply(
    artifacts, digest::digest, character(1L),
    algo = "sha256", file = TRUE, serialize = FALSE
  )
  expect_true(all(vapply(
    hashes, grepl, logical(1L), x = record, fixed = TRUE
  )))
  identities <- c(
    ctx$env$mfrmr_cq_c3nr_candidate_id,
    ctx$env$mfrmr_cq_c3nr_coordinate_bundle_sha256,
    ctx$env$mfrmr_cq_c3nr_ledger_bundle_sha256,
    ctx$env$mfrmr_cq_ptf_expected_tolerance_sha256
  )
  expect_true(all(vapply(
    identities, grepl, logical(1L), x = record, fixed = TRUE
  )))
  expect_true(grepl("ComparisonPassed.*TRUE", record))
  expect_true(grepl("ReportedDecimalConfirmationPassed.*TRUE", record))
  expect_true(grepl("ScientificEquivalenceInferred.*FALSE", record))
  expect_true(grepl("InferenceReady.*FALSE", record))
})
