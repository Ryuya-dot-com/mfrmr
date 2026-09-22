load_conquest_p3_metric_precision_contract <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-gpcm-overlap-contract-0.2.3.R",
    "conquest-p3-item-only-adversarial-fixtures-0.2.3.R",
    "conquest-p3-metric-precision-contract-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(
    all(file.exists(paths)),
    "Repository-only ConQuest P3 metric files are excluded."
  )
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("P3 budgets are prospective and stratum-specific", {
  ctx <- load_conquest_p3_metric_precision_contract()
  env <- ctx$env
  budgets <- env$mfrmr_cq_p3m_budget_registry()
  pcm <- env$mfrmr_cq_p3m_probability_budget("PCM")
  gpcm <- env$mfrmr_cq_p3m_probability_budget("GPCM")

  expect_identical(nrow(budgets), 11L)
  expect_false(anyDuplicated(budgets$BudgetId) > 0L)
  expect_true(all(budgets$Frozen))
  expect_false(any(budgets$CandidateOutputInformed))
  expect_false(any(budgets$OpenedCalibrationTransferred))
  expect_false(any(budgets$ScientificEquivalenceInferred))
  expect_identical(
    budgets$AbsoluteTolerance[
      budgets$BudgetId == "P3-Q121-CONTINUOUS-DEVIANCE"
    ],
    1e-7
  )
  expect_true(all(budgets$AbsoluteTolerance[
    budgets$BudgetId != "P3-Q121-CONTINUOUS-DEVIANCE"
  ] == 1e-5))

  expect_identical(pcm$MaximumPairwiseCoefficientL1, 9)
  expect_identical(gpcm$MaximumPairwiseCoefficientL1, 12)
  expect_equal(
    pcm$AbsoluteProbabilityTolerance, expm1(9e-5), tolerance = 0
  )
  expect_lt(
    abs(gpcm$AbsoluteProbabilityTolerance - expm1(12e-5)), 1e-18
  )
  expect_identical(pcm$ExpectedCells, 80L)
  expect_identical(gpcm$ExpectedCells, 80L)
  expect_false(pcm$CandidateOutputInformed)
  expect_false(gpcm$CandidateOutputInformed)
})

test_that("raw tokens are compared as explicit resolution intervals", {
  ctx <- load_conquest_p3_metric_precision_contract()
  env <- ctx$env
  states <- env$mfrmr_cq_p3m_raw_token_state_registry()
  scientific <- env$mfrmr_cq_p3m_parse_raw_token("-1.234e-05")

  expect_identical(nrow(states), 5L)
  expect_identical(
    states$TokenState[states$NumericComparisonConditionallyEligible],
    "raw_decimal"
  )
  expect_false(any(states$HiddenDigitsImputed))
  expect_identical(scientific$State, "raw_decimal")
  expect_identical(scientific$DecimalPlaces, 3L)
  expect_identical(scientific$Exponent, -5L)
  expect_equal(scientific$HalfUnitLastPlace, 5e-9, tolerance = 0)
  expect_identical(
    env$mfrmr_cq_p3m_parse_raw_token(NULL)$State, "raw_token_missing"
  )
  expect_identical(
    env$mfrmr_cq_p3m_parse_raw_token(NA_real_)$State, "raw_token_missing"
  )
  expect_identical(
    env$mfrmr_cq_p3m_parse_raw_token("not-a-number")$State,
    "raw_token_unparsable"
  )
  expect_identical(
    env$mfrmr_cq_p3m_parse_raw_token("1e999")$State,
    "raw_token_nonfinite"
  )
  expect_identical(
    env$mfrmr_cq_p3m_parse_raw_token(1.25)$State,
    "display_reconstruction_only"
  )

  pass <- env$mfrmr_cq_p3m_compare_raw_tokens(
    "1.000000", "1.000008", 1e-5
  )
  limited <- env$mfrmr_cq_p3m_compare_raw_tokens(
    "1.000000", "1.000010", 1e-5
  )
  fail <- env$mfrmr_cq_p3m_compare_raw_tokens(
    "1.000000", "1.000012", 1e-5
  )
  reconstructed <- env$mfrmr_cq_p3m_compare_raw_tokens(
    1.000000, "1.000000", 1e-5
  )

  expect_identical(pass$Classification, "eligible")
  expect_true(pass$NumericPass)
  expect_lt(abs(pass$MinimumPossibleAbsoluteDifference - 7e-6), 1e-16)
  expect_lt(abs(pass$MaximumPossibleAbsoluteDifference - 9e-6), 1e-16)
  expect_identical(limited$Classification, "reported_resolution_limited")
  expect_false(limited$NumericPass)
  expect_identical(fail$Classification, "numerical_disagreement")
  expect_false(fail$NumericPass)
  expect_identical(
    reconstructed$Classification, "reported_resolution_limited"
  )
  expect_false(any(c(
    pass$HiddenDigitsImputed, limited$HiddenDigitsImputed,
    fail$HiddenDigitsImputed, reconstructed$HiddenDigitsImputed
  )))
})

test_that("integration is resolved before optimizer or cross-engine labels", {
  ctx <- load_conquest_p3_metric_precision_contract()
  env <- ctx$env

  converged <- env$mfrmr_cq_p3m_classify_integration(
    1, 1, 1e-6, 2e-6, 1e-8
  )
  expect_identical(converged$State, "integration_eligible")
  expect_true(converged$CrossEngineNumericEligible)
  expect_false(converged$Q31Q61DiagnosticThresholdApplied)

  missing <- env$mfrmr_cq_p3m_classify_integration(
    NA_real_, 1, 1e-6, 2e-6, 1e-8
  )
  coordinate <- env$mfrmr_cq_p3m_classify_integration(
    0, 0, 1.1e-5, 2e-6, 1e-8
  )
  deviance <- env$mfrmr_cq_p3m_classify_integration(
    0, 0, 1e-6, 1.1e-5, 1e-8
  )
  continuous <- env$mfrmr_cq_p3m_classify_integration(
    0, 0, 1e-6, 2e-6, 1.1e-7
  )
  nonfinite <- env$mfrmr_cq_p3m_classify_integration(
    0, 0, 1e-6, 2e-6, Inf
  )
  expect_identical(missing$State, "q31_q61_diagnostic_missing")
  expect_identical(coordinate$State, "q61_q121_coordinate_unresolved")
  expect_identical(deviance$State, "q61_q121_deviance_unresolved")
  expect_identical(
    continuous$State, "q121_continuous_target_unresolved"
  )
  expect_identical(nonfinite$State, "nonfinite_integration_value")
  expect_true(all(vapply(
    list(missing, coordinate, deviance, continuous, nonfinite),
    function(result) identical(result$ObservedOutcome, "integration_unresolved") &&
      !result$CrossEngineNumericEligible,
    logical(1L)
  )))

  classify <- env$mfrmr_cq_p3m_classify_numeric_gate
  expect_identical(
    classify(FALSE, FALSE, "implementation_defect",
             "q61_q121_deviance_unresolved", FALSE),
    "model_identity_mismatch"
  )
  expect_identical(
    classify(TRUE, FALSE, "eligible", "integration_eligible", TRUE),
    "mfrmr_optimizer_or_readiness_review"
  )
  expect_identical(
    classify(TRUE, TRUE, "reported_resolution_limited",
             "integration_eligible", TRUE),
    "reported_resolution_limited"
  )
  expect_identical(
    classify(TRUE, TRUE, "numerical_disagreement",
             "q61_q121_deviance_unresolved", FALSE),
    "integration_unresolved"
  )
  expect_identical(
    classify(TRUE, TRUE, "numerical_disagreement",
             "integration_eligible", TRUE),
    "numerical_disagreement"
  )
  expect_identical(
    classify(TRUE, TRUE, "eligible", "integration_eligible", TRUE),
    "eligible"
  )
})

test_that("metric rules separate estimands and forbid voting", {
  ctx <- load_conquest_p3_metric_precision_contract()
  env <- ctx$env
  rules <- env$mfrmr_cq_p3m_metric_rule_registry()
  row <- function(id) rules[rules$RuleId == id, , drop = FALSE]

  expect_identical(nrow(rules), 23L)
  expect_false(anyDuplicated(rules$RuleId) > 0L)
  expect_true(all(rules$Frozen))
  expect_true(all(rules$RetainEveryAtomicOutcome))
  expect_false(any(rules$CanPassOnCorrelation))
  expect_false(any(rules$CanUseTwoAgainstOneVote))
  expect_true(all(
    rules$ThirdEngineRole == "optional_pairwise_separate_no_vote"
  ))
  expect_false(any(rules$CanPromoteMfrmrReadiness))
  expect_false(any(rules$ScientificEquivalenceInferred))
  expect_true(all(rules$FailureOutcome %in%
    env$mfrmr_cq_p3m_stop_rule_registry()$ObservedOutcome))
  expect_true(all(nzchar(rules$FailureDetail)))

  expect_identical(
    row("P3-XENG-LOG-RELATIVE-SLOPE")$Units, "centered_log_slope"
  )
  expect_identical(
    row("P3-XENG-LOG-POPULATION-SCALE")$Units,
    "log_standard_deviation"
  )
  expect_identical(
    row("P3-XENG-TRANSITION-STEP")$Units, "latent_trait_transition"
  )
  expect_identical(
    row("P3-XENG-REGRESSION")$ComparisonTransform,
    "inverse_map_beta_X_equals_sigma_times_beta_CQ"
  )
  expect_identical(
    row("P3-XENG-LOG-RELATIVE-SLOPE")$ComparisonTransform,
    "center_log_of_all_four_positive_item_slopes"
  )
  expect_true(row("P3-PCM-UNIT-SLOPE-STATE")$NumericPassAuthorized == FALSE)
  diagnostic <- grepl("Q31-Q61-DIAGNOSTIC", rules$RuleId, fixed = TRUE)
  expect_true(all(is.na(rules$AbsoluteTolerance[diagnostic])))
  expect_false(any(rules$NumericPassAuthorized[diagnostic]))
  final_q <- grepl("Q61-Q121", rules$RuleId, fixed = TRUE)
  expect_true(all(rules$AbsoluteTolerance[final_q] == 1e-5))
  continuous <- grepl("Q121-CONTINUOUS", rules$RuleId, fixed = TRUE)
  expect_true(all(rules$AbsoluteTolerance[continuous] == 1e-7))
})

test_that("the P3 metric and atomic denominators are complete", {
  ctx <- load_conquest_p3_metric_precision_contract()
  env <- ctx$env
  denominator <- env$mfrmr_cq_p3m_denominator_registry()
  rules <- env$mfrmr_cq_p3m_metric_rule_registry()

  expect_identical(nrow(denominator), 61L)
  expect_identical(sum(denominator$ExpectedAtomicCount), 861L)
  expect_false(anyDuplicated(denominator$MetricRowId) > 0L)
  expect_true(all(denominator$RetainFailedOrIneligible))
  expect_false(any(denominator$ExternalExecutionAuthorized))
  expect_false(any(denominator$ComparisonPassed))
  expect_true(all(denominator$RuleId %in% rules$RuleId))
  expect_identical(
    as.integer(table(denominator$RegistryScope)), c(20L, 19L, 1L, 1L, 19L, 1L)
  )

  total <- aggregate(
    ExpectedAtomicCount ~ RegistryScope, denominator, sum
  )
  expected <- c(
    "P3-PCM-UNIT-SLOPE-INTERCEPT" = 260L,
    "P3-GPCM-NONUNIT-INTERCEPT" = 293L,
    "P3-GPCM-NONUNIT-COVARIATE" = 305L,
    "P3-NONOVERLAP-MULTIFACET-OWNER" = 1L,
    "P3-UNSUPPORTED-JML-SCORESFREE" = 1L,
    "P3-NONOVERLAP-MULTIDIMENSIONAL" = 1L
  )
  observed <- setNames(total$ExpectedAtomicCount, total$RegistryScope)
  expect_identical(observed[names(expected)], expected)

  raw <- denominator[
    denominator$RuleId == "P3-RAW-TOKEN-RESOLUTION", , drop = FALSE
  ]
  expect_identical(raw$ExpectedAtomicCount, c(84L, 102L, 108L))
  probability <- denominator[
    grepl("CONDITIONAL-PROBABILITY", denominator$RuleId, fixed = TRUE), ,
    drop = FALSE
  ]
  expect_true(all(probability$ExpectedAtomicCount == 80L))
  nonoverlap <- denominator[
    denominator$FailureDenominator == "P3_NONOVERLAP_DENOMINATOR", ,
    drop = FALSE
  ]
  expect_identical(nrow(nonoverlap), 3L)
  expect_true(all(nonoverlap$RuleId == "P3-NONOVERLAP-DISPOSITION"))
})

test_that("all P3 observed outcomes have fail-closed stop rules", {
  ctx <- load_conquest_p3_metric_precision_contract()
  env <- ctx$env
  stop <- env$mfrmr_cq_p3m_stop_rule_registry()
  registry <- env$mfrmr_cq_ssr_registry()
  allowed <- unique(unlist(strsplit(
    registry$AllowedObservedOutcomes[registry$Priority == "P3"],
    ";", fixed = TRUE
  )))

  expect_identical(nrow(stop), 14L)
  expect_setequal(stop$ObservedOutcome, allowed)
  expect_true(all(stop$RetainInCompleteDenominator))
  expect_false(anyNA(stop$RequiredNextAction))
  expect_false(anyNA(stop$PermittedNarrowExpansion))
  expect_false(anyNA(stop$InvalidationScope))
  expect_true(all(nzchar(stop$RequiredNextAction)))
  expect_false(any(stop$WiderDesignExpansionAllowed))
  expect_false(any(stop$CanUseTwoAgainstOneVote))
  expect_false(any(stop$CanPromoteMfrmrReadiness))
  expect_false(any(stop$CanInferScientificEquivalence))
  expect_true(stop$NumericMetricsEligible[stop$ObservedOutcome == "eligible"])
  expect_false(any(stop$NumericMetricsEligible[
    stop$ObservedOutcome != "eligible"
  ]))
  expect_identical(
    stop$PermittedNarrowExpansion[
      stop$ObservedOutcome == "integration_unresolved"
    ],
    "prespecified_q_ladder_only"
  )
  expect_identical(
    stop$InvalidationScope[
      stop$ObservedOutcome == "implementation_defect"
    ],
    "entire_execution_slice"
  )
})

test_that("semantic mutation of every P3 metric layer fails closed", {
  ctx <- load_conquest_p3_metric_precision_contract()
  env <- ctx$env

  budgets <- env$mfrmr_cq_p3m_budget_registry()
  budgets$AbsoluteTolerance[1L] <- 1e-3
  expect_false(env$mfrmr_cq_p3m_validate(
    budgets = budgets
  )$budget_registry_ready)

  raw <- env$mfrmr_cq_p3m_raw_token_state_registry()
  raw$HiddenDigitsImputed[1L] <- TRUE
  expect_false(env$mfrmr_cq_p3m_validate(
    raw_states = raw
  )$raw_token_registry_ready)

  integration <- env$mfrmr_cq_p3m_integration_state_registry()
  integration$CrossEngineDisagreementInferred[1L] <- TRUE
  expect_false(env$mfrmr_cq_p3m_validate(
    integration_states = integration
  )$integration_state_registry_ready)

  metrics <- env$mfrmr_cq_p3m_metric_rule_registry()
  metrics$CanUseTwoAgainstOneVote[1L] <- TRUE
  expect_false(env$mfrmr_cq_p3m_validate(
    metric_rules = metrics
  )$metric_rule_registry_ready)

  denominator <- env$mfrmr_cq_p3m_denominator_registry()
  denominator <- denominator[-1L, , drop = FALSE]
  expect_false(env$mfrmr_cq_p3m_validate(
    denominator = denominator
  )$complete_denominator_ready)

  stop <- env$mfrmr_cq_p3m_stop_rule_registry()
  stop$WiderDesignExpansionAllowed[1L] <- TRUE
  expect_false(env$mfrmr_cq_p3m_validate(
    stop_rules = stop
  )$stop_rule_registry_ready)

  original_contract <- env$mfrmr_cq_p3_contract
  env$mfrmr_cq_p3_contract <- "wrong_P3_fixture_contract"
  expect_error(
    env$mfrmr_cq_p3m_metric_rule_registry(),
    "exact successor registry and P3 item-only fixture contract",
    fixed = TRUE
  )
  env$mfrmr_cq_p3_contract <- original_contract
  expect_identical(nrow(env$mfrmr_cq_p3m_metric_rule_registry()), 23L)
})

test_that("P3 metric freeze reaches review but never execution", {
  ctx <- load_conquest_p3_metric_precision_contract()
  review <- ctx$env$mfrmr_cq_p3m_review()

  expect_identical(
    review$status,
    "P3_fixtures_metrics_precision_and_denominator_ready_for_independent_offline_review"
  )
  expect_true(review$fixture_contract$fixture_semantics_ready)
  expect_true(review$fixture_contract$fixture_and_matrix_ready)
  expect_true(review$fixture_contract$finite_integration_ladder_ready)
  expect_true(review$metric_specific_rules_frozen)
  expect_true(review$raw_token_rules_frozen)
  expect_true(review$integration_rules_frozen)
  expect_true(review$complete_denominator_frozen)
  expect_true(review$stop_and_invalidation_rules_frozen)
  expect_false(review$independent_review_passed)
  expect_false(review$external_execution_authorized)
  expect_false(review$comparison_passed)
  expect_false(review$scientific_equivalence_inferred)
})

test_that("the P3 metric contract is offline and path independent", {
  ctx <- load_conquest_p3_metric_precision_contract()
  source <- paste(readLines(ctx$paths[4L], warn = FALSE), collapse = "\n")

  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("/Applications/ConQuest", source, fixed = TRUE))
  expect_false(grepl("SHA-256", source, fixed = TRUE))
  expect_false(grepl("mfrmr_cq_ptf", source, fixed = TRUE))
})

test_that("the P3 metric record advances construction but preserves gates", {
  ctx <- load_conquest_p3_metric_precision_contract()
  record_path <- file.path(
    ctx$validation, "conquest-p3-metric-precision-contract-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expected <- c(
    ctx$env$mfrmr_cq_p3m_specification,
    ctx$env$mfrmr_cq_p3m_contract,
    "P3_fixtures_metrics_precision_and_denominator_ready_for_independent_offline_review",
    "| Metric-level denominator | 61 |",
    "| Full P3 atomic denominator | 861 |",
    "`IndependentReviewPassed` | `FALSE`",
    "`ExternalExecutionAuthorized` | `FALSE`",
    "`ComparisonPassed` | `FALSE`",
    "`ScientificEquivalenceInferred` | `FALSE`"
  )
  expect_true(all(vapply(
    expected, grepl, logical(1L), x = record, fixed = TRUE
  )))
  expect_match(
    roadmap,
    "[x] Freeze a q ladder and distinguish `integration_unresolved`",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Freeze relative-slope, population-scale, transition-threshold",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[ ] Authorize the external candidate only after P0/P1 pass",
    fixed = TRUE
  )
})
