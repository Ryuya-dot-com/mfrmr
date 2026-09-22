load_conquest_reported_output_contract <- function() {
  skip_if_not_installed("digest")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-additive-mfrm-design-0.2.3.R",
    "external-comparison-eligibility-contract-0.2.3.R",
    "conquest-external-comparison-normalizer-0.2.3.R",
    "conquest-reported-output-precision-contract-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)),
              "Repository-only ConQuest precision files are excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, env = env)
}

make_reported_output_review <- function(env) {
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
  difference$NativeValue <- seq_len(nrow(difference)) / 10
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

make_reported_output_policy <- function(env, review) {
  difference <- review$descriptive_differences
  token <- sprintf("%.6f", difference$NativeValue)
  parsed <- env$mfrmr_cq_rop_parse_exact_decimal(token)
  rows <- data.frame(
    RunId = difference$RunId,
    Model = difference$Model,
    Coordinate = difference$Coordinate,
    FileRole = "synthetic_export",
    FileName = "synthetic.csv",
    FileSHA256 = paste(rep("a", 64L), collapse = ""),
    NativeToken = token,
    NativeValue = parsed$NumericValue,
    CanonicalExactDecimal = parsed$CanonicalExactDecimal,
    ReportedOutputEstimandReady = TRUE,
    HiddenSolutionIntervalAvailable = FALSE,
    HiddenSolutionEquivalenceEligible = FALSE,
    MfrmrReferenceValue = difference$MfrmrReferenceValue,
    SignedReportedDifference =
      parsed$NumericValue - difference$MfrmrReferenceValue,
    AbsoluteReportedDifference = abs(
      parsed$NumericValue - difference$MfrmrReferenceValue
    ),
    Metric = "absolute_difference_to_exact_reported_decimal",
    SourcePrecisionStatus = "match",
    stringsAsFactors = FALSE
  )
  out <- list(
    specification = env$mfrmr_cq_rop_specification,
    contract_version = env$mfrmr_cq_rop_contract,
    policy_id = env$mfrmr_cq_rop_policy_id,
    rows_sha256 = env$mfrmr_cq_rop_rows_sha256(rows),
    status = "reported_output_stratum_ready_hidden_solution_unresolved",
    manual_contract = env$mfrmr_cq_rop_manual_contract(),
    reported_output_estimand_ready = TRUE,
    hidden_solution_interval_available = FALSE,
    hidden_solution_equivalence_eligible = FALSE,
    rounding_rule_inferred = FALSE,
    tolerance_frozen = FALSE,
    candidate_bound = FALSE,
    comparison_ready = FALSE,
    scientific_equivalence_inferred = FALSE,
    confirmation_authorized = FALSE,
    rows = rows
  )
  class(out) <- c("mfrmr_conquest_reported_output_precision", class(out))
  out
}

test_that("manual evidence separates file tokens from hidden precision", {
  contract <- load_conquest_reported_output_contract()
  manual <- contract$env$mfrmr_cq_rop_manual_contract()

  expect_identical(
    manual$ManualSHA256,
    "60bce1a39f5430fd304178356fb943721f9f72c0ddee70a9866c28c87017459f"
  )
  expect_identical(manual$ManualPDFPage, 394L)
  expect_false(manual$ScreenDecimalsControlAppliesToFileOutput)
  expect_false(manual$FileRoundingRuleDocumented)
  expect_false(manual$HiddenPrecisionDocumented)
  expect_true(manual$ReportedDecimalTokenIsExactEstimand)
  expect_false(manual$HiddenSolutionIntervalAvailable)
})

test_that("decimal tokens have exact canonical identities", {
  env <- load_conquest_reported_output_contract()$env
  parsed <- env$mfrmr_cq_rop_parse_exact_decimal(c(
    "1.2300", "1.23", "123e-2", "-0.000000", ".5", "not_numeric",
    "1e9999999999"
  ))

  expect_identical(
    parsed$NumericGrammarValid,
    c(TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE)
  )
  expect_identical(
    parsed$CanonicalExactDecimal[1:3], rep("123e-2", 3L)
  )
  expect_identical(parsed$CanonicalExactDecimal[4L], "0e0")
  expect_identical(parsed$CanonicalExactDecimal[5L], "5e-1")
  expect_true(is.na(parsed$CanonicalExactDecimal[6L]))
  expect_identical(parsed$ExactSign[4L], 0L)
})

test_that("reported-output scope is eligible without promoting hidden solutions", {
  contract <- load_conquest_reported_output_contract()
  env <- contract$env
  review <- make_reported_output_review(env)
  policy <- make_reported_output_policy(env, review)

  expect_true(isTRUE(env$mfrmr_cq_rop_validate_policy(policy)))
  hidden <- env$mfrmr_normalize_conquest_native_four_arm_eligibility(review)
  expect_identical(hidden$Binding$EligibleRows, 0L)
  expect_identical(hidden$Binding$SourcePrecisionScope, "hidden_solution")

  reported <- env$mfrmr_normalize_conquest_native_four_arm_eligibility(
    review, reported_output_precision = policy
  )
  expect_identical(reported$Binding$EligibleRows, 36L)
  expect_identical(reported$Binding$IncludedRows, 36L)
  expect_true(reported$Binding$SourcePrecisionReady)
  expect_identical(
    reported$Binding$SourcePrecisionScope, "exact_reported_decimal"
  )
  expect_identical(
    reported$Binding$SourcePrecisionPolicyId,
    "conquest-reported-decimal-estimand-v1"
  )
  expect_false(reported$Binding$HiddenSolutionEquivalenceEligible)
  expect_false(reported$Binding$CandidateBound)
  expect_false(reported$Binding$ComparisonReady)
  expect_identical(
    reported$Binding$Decision,
    "conquest_reported_output_rows_eligible_candidate_tolerance_missing"
  )
  expect_true(all(
    reported$Rows$Metric ==
      "absolute_difference_to_exact_reported_decimal"
  ))
})

test_that("reported-output policy rejects token and scope mutation", {
  contract <- load_conquest_reported_output_contract()
  env <- contract$env
  review <- make_reported_output_review(env)
  policy <- make_reported_output_policy(env, review)

  changed_token <- policy
  changed_token$rows$NativeToken[1L] <- "99.000000"
  expect_error(
    env$mfrmr_cq_rop_validate_policy(changed_token),
    "token, file, scope, or content hash"
  )
  expect_error(
    env$mfrmr_normalize_conquest_native_four_arm_eligibility(
      review, reported_output_precision = changed_token
    ),
    "missing or silently promoted"
  )

  promoted <- policy
  promoted$hidden_solution_equivalence_eligible <- TRUE
  expect_error(
    env$mfrmr_normalize_conquest_native_four_arm_eligibility(
      review, reported_output_precision = promoted
    ),
    "missing or silently promoted"
  )
})

test_that("retained native outputs enter only the reported-output stratum", {
  contract <- load_conquest_reported_output_contract()
  output_dir <- file.path(
    contract$root, "validation-results", "conquest-additive-native-20260811"
  )
  skip_if_not(dir.exists(output_dir),
              "Restricted retained ConQuest outputs are unavailable.")
  sources <- c(
    "conquest-numeric-resolution-contract-0.2.3.R",
    "conquest-additive-native-rsm-q31-review-0.2.3.R",
    "conquest-additive-native-pcm-q31-review-0.2.3.R",
    "conquest-additive-native-four-arm-review-0.2.3.R"
  )
  for (file in sources) {
    sys.source(file.path(contract$validation, file), envir = contract$env)
  }
  review <- contract$env$mfrmr_review_conquest_additive_native_four_arms(
    output_dir
  )
  policy <- contract$env$mfrmr_cq_rop_review_four_arm(output_dir, review)
  expect_true(isTRUE(contract$env$mfrmr_cq_rop_validate_policy(policy)))
  expect_identical(nrow(policy$rows), 36L)
  expect_true(all(policy$rows$ReportedOutputEstimandReady))
  expect_true(all(!policy$rows$HiddenSolutionEquivalenceEligible))
  expect_true(all(nchar(policy$rows$FileSHA256) == 64L))

  ledger <- contract$env$mfrmr_normalize_conquest_native_four_arm_eligibility(
    review, reported_output_precision = policy
  )
  expect_identical(ledger$Binding$EligibleRows, 36L)
  expect_identical(ledger$Binding$IncludedRows, 36L)
  expect_true(ledger$Binding$SourcePrecisionReady)
  expect_false(ledger$Binding$HiddenSolutionEquivalenceEligible)
  expect_false(ledger$Binding$ComparisonReady)
})
