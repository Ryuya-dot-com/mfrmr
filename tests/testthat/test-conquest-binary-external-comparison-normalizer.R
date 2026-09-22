load_conquest_binary_external_comparison_normalizer <- function() {
  skip_if_not_installed("digest")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-reported-output-precision-contract-0.2.3.R",
    "external-comparison-eligibility-contract-0.2.3.R",
    "conquest-binary-external-comparison-normalizer-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)),
              "Repository-only Binary ConQuest contracts are excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, env = env)
}

make_conquest_binary_core_review <- function(candidate_bound = FALSE,
                                              native_fingerprints = NULL) {
  manifest <- data.frame(
    RunId = c("q031a", "q061"),
    Nodes = c(31L, 61L),
    WideMD5 = rep(paste(rep("a", 32L), collapse = ""), 2L),
    MfrmrDeviance = c(424.738979414154, 424.738979414154),
    stringsAsFactors = FALSE
  )
  results <- data.frame(
    RunId = manifest$RunId,
    Nodes = manifest$Nodes,
    ExecutionComplete = TRUE,
    HigherLikelihoodRetained = FALSE,
    AdapterStatus = "accepted_arithmetic",
    HistoryExportMaxAbsDifference = 0,
    Npar = 8L,
    Persons = 60L,
    ArithmeticEligible = TRUE,
    ComparisonReady = FALSE,
    NativeOutputFingerprint = if (is.null(native_fingerprints)) {
      c("unretained-q31", "unretained-q61")
    } else {
      native_fingerprints
    },
    stringsAsFactors = FALSE
  )
  out <- list(
    contract_version = "mfrmr_conquest_binary_ladder_v1",
    candidate_bound = candidate_bound,
    comparison_ready = FALSE,
    manifest = manifest,
    results = results
  )
  class(out) <- c("mfrmr_conquest_binary_ladder_review", class(out))
  out
}

write_conquest_binary_native_arm <- function(output_dir, run_id, offset = 0) {
  run_dir <- file.path(output_dir, run_id)
  dir.create(run_dir, recursive = TRUE, showWarnings = FALSE)
  prefix <- paste0("cq_", run_id, "_conquest_")
  free_token <- sprintf("%.6f", c(
    0.123456, 0.654321, 0.333333,
    -0.8, -0.6, -0.1, 0.2, 0.5
  ) + offset)
  history <- cbind(data.frame(
    RowLabels = "row_1",
    `Run Number` = "1",
    Iteration = "10",
    LogLikelihood = "424.738979",
    check.names = FALSE,
    stringsAsFactors = FALSE
  ), as.data.frame(
    stats::setNames(as.list(free_token), paste0("free", seq_len(8L))),
    check.names = FALSE,
    stringsAsFactors = FALSE
  ))
  utils::write.csv(
    history, file.path(run_dir, paste0(prefix, "history.csv")),
    row.names = FALSE, quote = FALSE
  )
  utils::write.csv(
    data.frame(
      P = seq_len(5L), Estimate = free_token[4:8],
      Label = paste("item", tolower(sprintf("I%03d", seq_len(5L))))
    ),
    file.path(run_dir, paste0(prefix, "parameters.csv")),
    row.names = FALSE, quote = FALSE
  )
  utils::write.csv(
    data.frame(
      Dimension = c(1L, 1L), Regressor = c(1L, 2L),
      Estimate = free_token[1:2]
    ),
    file.path(run_dir, paste0(prefix, "reg_coefficients.csv")),
    row.names = FALSE, quote = FALSE
  )
  utils::write.csv(
    data.frame(Dim1 = 1L, Dim2 = 1L, Covariance = free_token[3L]),
    file.path(run_dir, paste0(prefix, "covariance.csv")),
    row.names = FALSE, quote = FALSE
  )
  utils::write.csv(
    data.frame(
      SeqNum = 1L, PID = "P001", weight_raw = 1, weight_scaled = 1
    ),
    file.path(run_dir, paste0(prefix, "cases_eap.csv")),
    row.names = FALSE, quote = FALSE
  )
  reference <- data.frame(
    MfrmrDeviance = 424.738979414154,
    Intercept = as.numeric(free_token[1L]) - 1e-7,
    Slope = as.numeric(free_token[2L]) - 2e-7,
    Variance = as.numeric(free_token[3L]) - 3e-7,
    Item1 = as.numeric(free_token[4L]) - 4e-7,
    Item2 = as.numeric(free_token[5L]) - 5e-7,
    Item3 = as.numeric(free_token[6L]) - 6e-7,
    Item4 = as.numeric(free_token[7L]) - 7e-7,
    Item5 = as.numeric(free_token[8L]) - 8e-7,
    stringsAsFactors = FALSE
  )
  utils::write.csv(
    reference,
    file.path(run_dir, paste0("cq_", run_id,
                              "_mfrmr_ladder_reference.csv")),
    row.names = FALSE, quote = FALSE
  )
  native_paths <- file.path(run_dir, paste0(prefix, c(
    "history.csv", "parameters.csv", "reg_coefficients.csv",
    "covariance.csv", "cases_eap.csv"
  )))
  paste(unname(tools::md5sum(native_paths)), collapse = ":")
}

test_that("Binary q31/q61 registry matches the eight-free-coordinate likelihood", {
  env <- load_conquest_binary_external_comparison_normalizer()$env
  registry <- env$mfrmr_cq_becec_expected_registry()

  expect_identical(nrow(registry), 18L)
  expect_identical(unique(registry$Model), "Binary")
  expect_identical(unique(registry$Nodes), c(31L, 61L))
  expect_identical(sum(registry$ParameterClass == "item_difficulty"), 10L)
  expect_identical(sum(registry$ParameterClass == "objective"), 2L)
  expect_false("Item6" %in% registry$Coordinate)
  expect_true(all(registry$ExpectedRow))
  expect_false(any(registry$ObservedRow))
  expect_true(all(is.na(registry$MetricValue)))
})

test_that("missing retained Binary output remains explicit and ineligible", {
  env <- load_conquest_binary_external_comparison_normalizer()$env
  review <- make_conquest_binary_core_review()
  ledger <- env$mfrmr_normalize_conquest_binary_ladder_eligibility(review)

  expect_identical(nrow(ledger$Rows), 18L)
  expect_true(all(ledger$Rows$Disposition == "missing"))
  expect_true(all(ledger$Rows$ReasonCodes == "missing_expected_row"))
  expect_identical(ledger$Binding$ObservedRows, 0L)
  expect_identical(ledger$Binding$EligibleRows, 0L)
  expect_identical(
    ledger$Binding$Decision, "binary_native_reported_output_not_retained"
  )
  expect_false(ledger$Binding$SourcePrecisionReady)
  expect_false(ledger$Binding$CandidateBound)
})

test_that("Binary native tokens normalize only in the exact reported stratum", {
  loaded <- load_conquest_binary_external_comparison_normalizer()
  env <- loaded$env
  output_dir <- file.path(tempdir(), "conquest-binary-reported-token-fixture")
  if (dir.exists(output_dir)) unlink(output_dir, recursive = TRUE, force = TRUE)
  fingerprints <- c(
    write_conquest_binary_native_arm(output_dir, "q031a", offset = 0),
    write_conquest_binary_native_arm(output_dir, "q061", offset = 1e-6)
  )
  review <- make_conquest_binary_core_review(
    native_fingerprints = fingerprints
  )

  policy <- env$mfrmr_cq_brop_review_core(output_dir, review)
  expect_true(isTRUE(env$mfrmr_cq_brop_validate_policy(policy)))
  expect_identical(nrow(policy$rows), 18L)
  expect_true(all(policy$rows$ReportedOutputEstimandReady))
  expect_true(all(!policy$rows$HiddenSolutionEquivalenceEligible))
  expect_false(policy$rounding_rule_inferred)

  ledger <- env$mfrmr_normalize_conquest_binary_ladder_eligibility(
    review, reported_output_precision = policy
  )
  expect_true(all(ledger$Rows$Disposition == "eligible"))
  expect_identical(ledger$Binding$ObservedRows, 18L)
  expect_identical(ledger$Binding$EligibleRows, 18L)
  expect_identical(ledger$Binding$IncludedRows, 18L)
  expect_true(ledger$Binding$SourcePrecisionReady)
  expect_identical(
    ledger$Binding$SourcePrecisionScope, "exact_reported_decimal"
  )
  expect_false(ledger$Binding$HiddenSolutionEquivalenceEligible)
  expect_false(ledger$Binding$CandidateBound)
  expect_false(ledger$Binding$ComparisonReady)
})

test_that("Binary token, coordinate, and review mutations fail closed", {
  loaded <- load_conquest_binary_external_comparison_normalizer()
  env <- loaded$env
  output_dir <- file.path(tempdir(), "conquest-binary-reported-mutation")
  if (dir.exists(output_dir)) unlink(output_dir, recursive = TRUE, force = TRUE)
  fingerprints <- c(
    write_conquest_binary_native_arm(output_dir, "q031a"),
    write_conquest_binary_native_arm(output_dir, "q061")
  )
  review <- make_conquest_binary_core_review(
    native_fingerprints = fingerprints
  )
  policy <- env$mfrmr_cq_brop_review_core(output_dir, review)

  changed <- policy
  changed$rows$NativeToken[1L] <- "99.000000"
  expect_error(
    env$mfrmr_cq_brop_validate_policy(changed),
    "token, registry, scope, or content hash"
  )

  promoted <- policy
  promoted$tolerance_frozen <- TRUE
  promoted$comparison_ready <- TRUE
  expect_error(
    env$mfrmr_cq_brop_validate_policy(promoted),
    "identity or scope"
  )

  bad_review <- review
  bad_review$results$HistoryExportMaxAbsDifference[1L] <- 1e-6
  bad_ledger <- env$mfrmr_normalize_conquest_binary_ladder_eligibility(
    bad_review, reported_output_precision = policy
  )
  expect_true(all(bad_ledger$Rows$Disposition == "rejected"))
  expect_true(all(grepl(
    "observations_mismatch", bad_ledger$Rows$ReasonCodes, fixed = TRUE
  )))
  expect_identical(bad_ledger$Binding$EligibleRows, 0L)

  parameter_file <- file.path(
    output_dir, "q061", "cq_q061_conquest_parameters.csv"
  )
  parameter <- utils::read.csv(parameter_file, stringsAsFactors = FALSE)
  parameter$Label[1L] <- "item I999"
  utils::write.csv(parameter, parameter_file, row.names = FALSE, quote = FALSE)
  expect_error(
    env$mfrmr_cq_brop_review_core(output_dir, review),
    "review fingerprints"
  )
})
