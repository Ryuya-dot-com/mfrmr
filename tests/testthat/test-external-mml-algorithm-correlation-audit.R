.external_mml_algorithm_audit_cache <- new.env(parent = emptyenv())

load_external_mml_algorithm_correlation_audit <- function() {
  if (exists("context", envir = .external_mml_algorithm_audit_cache,
             inherits = FALSE)) {
    return(get("context", envir = .external_mml_algorithm_audit_cache,
               inherits = FALSE))
  }
  for (package in c("TAM", "immer", "digest")) {
    skip_if_not_installed(package)
  }
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  pkgload::load_all(root, quiet = TRUE)
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
    "conquest-six-arm-candidate-003-numerical-review-0.2.3.R",
    "conquest-additive-mfrm-reference-preflight-0.2.3.R",
    "tam-mml-core-calibration-0.2.3.R",
    "external-mml-algorithm-correlation-audit-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "External MML audit is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  candidate_root <- file.path(root, env$mfrmr_cq_c3_candidate_root)
  skip_if_not(dir.exists(candidate_root), "ConQuest candidate 003 is absent.")
  context <- list(
    root = root,
    validation = validation,
    env = env,
    result = env$mfrmr_run_external_mml_algorithm_correlation_audit(
      root, candidate_root
    )
  )
  assign(
    "context", context, envir = .external_mml_algorithm_audit_cache
  )
  context
}

test_that("external MML correlation audit uses independent free coordinates", {
  ctx <- load_external_mml_algorithm_correlation_audit()
  result <- ctx$result
  expect_identical(
    result$status,
    "external_mml_algorithm_correlation_and_log_domain_audit_complete"
  )
  expect_true(result$audit_complete)
  expect_identical(nrow(result$correlation_metrics), 17L)
  expect_identical(nrow(result$objective_audit), 14L)

  metric <- result$correlation_metrics
  aggregate <- metric[is.na(metric$Nodes), , drop = FALSE]
  expect_identical(nrow(aggregate), 3L)
  expect_equal(
    aggregate$CoordinateRows[match(
      c(
        "ConQuest_exact_reported_decimal_vs_mfrmr",
        "TAM_vs_mfrmr",
        "ConQuest_exact_reported_decimal_vs_TAM"
      ), aggregate$Comparison
    )],
    c(48L, 32L, 32L)
  )
  expected_correlation <- c(
    ConQuest_exact_reported_decimal_vs_mfrmr = 0.99999999999757549,
    TAM_vs_mfrmr = 0.99999999999999889,
    ConQuest_exact_reported_decimal_vs_TAM = 0.99999999999904288
  )
  expect_equal(
    aggregate$PearsonCorrelation[match(
      names(expected_correlation), aggregate$Comparison
    )],
    unname(expected_correlation),
    tolerance = 5e-15
  )
  expect_gt(min(metric$PearsonCorrelation), 0.99999999999)
  expect_lt(max(metric$PearsonDistanceFromOne), 5e-12)
  expect_lt(max(metric$MaximumAbsoluteDifference), 6e-6)
  expect_true(all(metric$EvidenceRole == "descriptive_not_acceptance"))
  expect_false(result$correlation_is_acceptance_rule)
  expect_false(result$dff_fit_person_rater_rank_invariance_evaluated)
  expect_false(result$scientific_equivalence_inferred)
})

test_that("external MML objective evidence remains separate from correlation", {
  ctx <- load_external_mml_algorithm_correlation_audit()
  objective <- ctx$result$objective_audit
  expect_true(all(objective$EvidenceRole == "objective_check_not_correlation"))
  expect_lt(
    max(abs(objective$SignedDifference[
      objective$Comparison == "ConQuest_exact_reported_decimal_vs_mfrmr"
    ])),
    2e-6
  )
  expect_lt(
    max(abs(objective$SignedDifference[
      objective$Comparison == "TAM_vs_mfrmr"
    ])),
    3e-7
  )
  expect_false(ctx$result$numerical_difference_is_floating_point_only)
  expect_true(ctx$result$integration_approximation_difference_present)
})

test_that("MML aggregation remains finite where probability products underflow", {
  ctx <- load_external_mml_algorithm_correlation_audit()
  stress <- ctx$result$log_domain_stress
  stability <- ctx$result$source_stability
  expect_false(stress$NaiveFinite)
  expect_true(stress$MfrmrFinite)
  expect_equal(
    stress$MfrmrPersonLogMarginal,
    stress$AnalyticSumOfLogs,
    tolerance = 1e-10
  )
  expect_true(stress$PersonAggregatorUsesLogProbabilitySum)
  expect_true(stress$PersonIntegratorUsesShiftedLogSumExp)
  expect_false(stress$PersonAggregatorContainsProduct)
  expect_true(all(unlist(stability[1L, 1:4])))
  expect_false(stability$NaiveLogOfProductPatternFound)
})

test_that("algorithm ledger does not confuse objective and solver identity", {
  ctx <- load_external_mml_algorithm_correlation_audit()
  ledger <- ctx$result$algorithm_ledger
  identity <- ctx$result$tam_algorithm_identity
  expect_identical(nrow(ledger), 7L)
  expect_identical(nrow(identity), 7L)
  expect_true(all(identity$IdentityMatch))
  expect_identical(unique(identity$Version), "4.3.25")
  expect_setequal(identity$Function, c(
    "tam.mml.mfr", "tam_mml_calc_prob", "tam_mml_mstep_regression",
    "tam_mml_mstep_intercept", "tam_mml_mstep_xsi",
    "tam_mml_compute_deviance", "tam_acceleration_inits"
  ))
  expect_true(any(grepl("broad EM/MML family", ledger$AlgorithmIdentityToConQuest)))
  expect_true(any(grepl("independent direct optimizer", ledger$AlgorithmIdentityToConQuest)))
  expect_identical(sum(grepl(
    "different.*objective", ledger$AlgorithmIdentityToConQuest
  )), 3L)
  expect_false(ctx$result$same_algorithm_required)
  expect_true(ctx$result$same_objective_and_coordinate_map_required)
})

test_that("external MML audit record is source-bound", {
  ctx <- load_external_mml_algorithm_correlation_audit()
  record_path <- file.path(
    ctx$validation,
    "external-mml-algorithm-correlation-audit-record-0.2.3.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  artifacts <- c(
    file.path(
      ctx$validation,
      "external-mml-algorithm-correlation-audit-0.2.3.R"
    ),
    file.path(
      ctx$root, "tests", "testthat",
      "test-external-mml-algorithm-correlation-audit.R"
    )
  )
  hashes <- vapply(
    artifacts, digest::digest, character(1L), algo = "sha256",
    file = TRUE, serialize = FALSE
  )
  expect_true(all(vapply(
    hashes, grepl, logical(1L), x = record, fixed = TRUE
  )))
  expect_true(grepl(ctx$env$mfrmr_emaca_contract, record, fixed = TRUE))
})
