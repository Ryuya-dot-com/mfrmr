load_conquest_external_comparison_normalizer <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-additive-mfrm-design-0.2.3.R",
    "external-comparison-eligibility-contract-0.2.3.R",
    "conquest-external-comparison-normalizer-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, env = env)
}

make_conquest_external_comparison_review <- function(env) {
  registry <- env$mfrmr_cq_ecec_expected_registry()
  plan <- env$mfrmr_cq_additive_plan()
  summary <- data.frame(
    RunId = plan$RunId,
    Model = plan$Model,
    Nodes = plan$Nodes,
    NativeDesignMatrixExact = TRUE,
    RawTokenStatus = "raw_tokens_retained_rounding_unestablished",
    ConsoleEndOfProgramObserved = TRUE,
    stringsAsFactors = FALSE
  )
  difference <- registry[, c("RunId", "Model", "Coordinate"), drop = FALSE]
  difference$NativeValue <- seq_len(nrow(difference))
  difference$MfrmrReferenceValue <-
    difference$NativeValue - seq_len(nrow(difference)) * 1e-7
  difference$Difference <-
    difference$NativeValue - difference$MfrmrReferenceValue
  difference$AbsDifference <- abs(difference$Difference)
  difference$AcceptanceThresholdSpecified <- FALSE
  difference$AcceptanceDecision <- NA_character_
  difference$ScientificEquivalenceInferred <- FALSE
  out <- list(
    specification = "0.2.3-wave-c-native-four-arm-review-v1",
    contract_version = "mfrmr_conquest_native_four_arm_review_v1",
    runtime_available = TRUE,
    four_arms_complete = TRUE,
    complete_console_transcripts = TRUE,
    cross_manifest_plan_identical = TRUE,
    cross_manifest_wide_sha256_identical = TRUE,
    unit_weights_contract = TRUE,
    native_design_matrices_exact = TRUE,
    raw_token_status = "raw_tokens_retained_rounding_unestablished",
    candidate_bound = FALSE,
    comparison_ready = FALSE,
    summary = summary,
    descriptive_differences = difference
  )
  class(out) <- c("mfrmr_conquest_native_four_arm_review", class(out))
  out
}

test_that("ConQuest expected registry is pre-result and exact", {
  adapter <- load_conquest_external_comparison_normalizer()
  registry <- adapter$env$mfrmr_cq_ecec_expected_registry()

  expect_identical(nrow(registry), 36L)
  expect_identical(sum(registry$Model == "RSM"), 16L)
  expect_identical(sum(registry$Model == "PCM"), 20L)
  expect_true(all(registry$ExpectedRow))
  expect_false(any(registry$ObservedRow))
  expect_false(any(registry$FitSucceeded))
  expect_true(all(is.na(registry$MetricValue)))
  expect_false(anyDuplicated(registry$ComparisonRowId) > 0L)
  expect_setequal(unique(registry$ExpectedEstimator), "MML")
  expect_setequal(unique(registry$ExpectedPenaltyMode), "none")
  expect_setequal(unique(registry$ExpectedFiniteParameterBox), "none")
})

test_that("rounded native ConQuest rows are bound but never aggregated", {
  adapter <- load_conquest_external_comparison_normalizer()
  review <- make_conquest_external_comparison_review(adapter$env)
  ledger <- adapter$env$mfrmr_normalize_conquest_native_four_arm_eligibility(
    review
  )

  expect_identical(nrow(ledger$Rows), 36L)
  expect_true(all(ledger$Rows$ObservedRow))
  expect_true(all(ledger$Rows$FitSucceeded))
  expect_true(all(is.finite(ledger$Rows$MetricValue)))
  expect_true(all(ledger$Rows$Disposition == "rejected"))
  expect_true(all(
    ledger$Rows$ReasonCodes == "source_precision_mismatch"
  ))
  expect_false(any(ledger$Rows$IncludeInAggregate))
  expect_true(all(ledger$Denominators$IncludedRows == 0L))
  expect_true(all(is.na(ledger$Denominators$AggregateValue)))
  expect_identical(ledger$Binding$ExpectedRows, 36L)
  expect_identical(ledger$Binding$ObservedRows, 36L)
  expect_identical(ledger$Binding$EligibleRows, 0L)
  expect_identical(ledger$Binding$IncludedRows, 0L)
  expect_identical(ledger$Binding$IneligibleIncludedRows, 0L)
  expect_false(ledger$Binding$SourcePrecisionReady)
  expect_false(ledger$Binding$CandidateBound)
  expect_false(ledger$Binding$ComparisonReady)
  expect_identical(
    ledger$Binding$Decision,
    "conquest_binding_complete_numeric_rows_excluded_source_precision"
  )
})

test_that("ConQuest normalization retains missing failed and unexpected rows", {
  adapter <- load_conquest_external_comparison_normalizer()
  review <- make_conquest_external_comparison_review(adapter$env)

  missing_id <- paste(review$descriptive_differences$RunId[1L],
                      review$descriptive_differences$Coordinate[1L], sep = "::")
  missing_review <- review
  missing_review$descriptive_differences <-
    missing_review$descriptive_differences[-1L, , drop = FALSE]
  missing_ledger <-
    adapter$env$mfrmr_normalize_conquest_native_four_arm_eligibility(
      missing_review
    )
  missing_row <- missing_ledger$Rows[
    missing_ledger$Rows$ComparisonRowId == missing_id, , drop = FALSE
  ]
  expect_identical(missing_row$Disposition, "missing")
  expect_identical(missing_row$ReasonCodes, "missing_expected_row")

  failed_review <- review
  failed_review$summary$ConsoleEndOfProgramObserved[
    failed_review$summary$RunId == "rsm_q031"
  ] <- FALSE
  failed_ledger <-
    adapter$env$mfrmr_normalize_conquest_native_four_arm_eligibility(
      failed_review
    )
  failed_rows <- failed_ledger$Rows[
    failed_ledger$Rows$RunId == "rsm_q031", , drop = FALSE
  ]
  expect_identical(nrow(failed_rows), 8L)
  expect_true(all(failed_rows$Disposition == "failed"))
  expect_true(all(failed_rows$ReasonCodes == "external_fit_failed"))

  unexpected_review <- review
  extra <- review$descriptive_differences[1L, , drop = FALSE]
  extra$Coordinate <- "unexpected_native_coordinate"
  extra$AbsDifference <- 0.123
  unexpected_review$descriptive_differences <- rbind(
    unexpected_review$descriptive_differences, extra
  )
  unexpected_ledger <-
    adapter$env$mfrmr_normalize_conquest_native_four_arm_eligibility(
      unexpected_review
    )
  unexpected_row <- unexpected_ledger$Rows[
    startsWith(unexpected_ledger$Rows$ComparisonRowId, "UNEXPECTED::"),
    , drop = FALSE
  ]
  expect_identical(nrow(unexpected_row), 1L)
  expect_identical(unexpected_row$Disposition, "unexpected")
  expect_identical(
    unexpected_row$ReasonCodes, "unexpected_row_not_in_registry"
  )
  expect_false(unexpected_row$IncludeInAggregate)
})

test_that("ConQuest adapter is order invariant and fails closed on identity", {
  adapter <- load_conquest_external_comparison_normalizer()
  review <- make_conquest_external_comparison_review(adapter$env)
  forward <- adapter$env$mfrmr_normalize_conquest_native_four_arm_eligibility(
    review
  )
  reverse_review <- review
  reverse_review$descriptive_differences <-
    reverse_review$descriptive_differences[
      rev(seq_len(nrow(reverse_review$descriptive_differences))),
      , drop = FALSE
    ]
  reverse <- adapter$env$mfrmr_normalize_conquest_native_four_arm_eligibility(
    reverse_review
  )
  expect_identical(forward$Rows, reverse$Rows)
  expect_identical(forward$Denominators, reverse$Denominators)
  expect_identical(forward$ReasonCounts, reverse$ReasonCounts)

  bad_input <- review
  bad_input$cross_manifest_wide_sha256_identical <- FALSE
  bad_input_ledger <-
    adapter$env$mfrmr_normalize_conquest_native_four_arm_eligibility(bad_input)
  expect_true(all(grepl(
    "observations_mismatch", bad_input_ledger$Rows$ReasonCodes, fixed = TRUE
  )))
  expect_true(all(grepl(
    "weights_mismatch", bad_input_ledger$Rows$ReasonCodes, fixed = TRUE
  )))

  unaudited_precision <- review
  unaudited_precision$summary$RawTokenStatus <- "invented_full_precision"
  unaudited_precision$raw_token_status <- "invented_full_precision"
  precision_ledger <-
    adapter$env$mfrmr_normalize_conquest_native_four_arm_eligibility(
      unaudited_precision
    )
  expect_true(all(grepl(
    "source_precision_unknown", precision_ledger$Rows$ReasonCodes,
    fixed = TRUE
  )))

  duplicate <- review
  duplicate$descriptive_differences <- rbind(
    duplicate$descriptive_differences,
    duplicate$descriptive_differences[1L, , drop = FALSE]
  )
  expect_error(
    adapter$env$mfrmr_normalize_conquest_native_four_arm_eligibility(
      duplicate
    ),
    "duplicate run/coordinate"
  )

  conflict <- review
  conflict$descriptive_differences$Model[1L] <- "PCM"
  expect_error(
    adapter$env$mfrmr_normalize_conquest_native_four_arm_eligibility(
      conflict
    ),
    "conflicts with its run/model summary"
  )
})

test_that("retained native ConQuest outputs bind to zero eligible rows", {
  adapter <- load_conquest_external_comparison_normalizer()
  output_dir <- file.path(
    adapter$root, "validation-results", "conquest-additive-native-20260811"
  )
  skip_if_not(dir.exists(output_dir),
              "restricted retained ConQuest outputs are unavailable")
  reviewer_sources <- c(
    "conquest-numeric-resolution-contract-0.2.3.R",
    "conquest-additive-native-rsm-q31-review-0.2.3.R",
    "conquest-additive-native-pcm-q31-review-0.2.3.R",
    "conquest-additive-native-four-arm-review-0.2.3.R"
  )
  for (file in reviewer_sources) {
    sys.source(file.path(adapter$validation, file), envir = adapter$env)
  }
  review <- adapter$env$mfrmr_review_conquest_additive_native_four_arms(
    output_dir
  )
  ledger <- adapter$env$mfrmr_normalize_conquest_native_four_arm_eligibility(
    review
  )

  expect_identical(nrow(ledger$Rows), 36L)
  expect_true(all(ledger$Rows$Disposition == "rejected"))
  expect_true(all(
    ledger$Rows$ReasonCodes == "source_precision_mismatch"
  ))
  expect_identical(ledger$Binding$EligibleRows, 0L)
  expect_identical(ledger$Binding$IncludedRows, 0L)
})

test_that("ConQuest normalizer record binds source and test identities", {
  skip_if_not_installed("digest")
  adapter <- load_conquest_external_comparison_normalizer()
  paths <- c(
    file.path(
      adapter$validation,
      "conquest-external-comparison-normalizer-0.2.3.R"
    ),
    file.path(
      adapter$validation,
      "conquest-additive-native-four-arm-review-0.2.3.R"
    ),
    file.path(
      adapter$root, "tests", "testthat",
      "test-conquest-external-comparison-normalizer.R"
    )
  )
  record <- paste(readLines(file.path(
    adapter$validation,
    "conquest-external-comparison-normalizer-record-0.2.3.md"
  ), warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  hashes <- vapply(
    paths, digest::digest, character(1), algo = "sha256", file = TRUE
  )
  expect_true(all(vapply(
    hashes, grepl, logical(1), x = record, fixed = TRUE
  )))
})
