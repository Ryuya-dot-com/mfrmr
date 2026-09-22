load_conquest_p2_metric_boundary_contract <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-p2-metric-boundary-contract-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(
    all(file.exists(paths)),
    "Repository-only ConQuest P2 metric files are excluded."
  )
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("boundary states forbid cross-layer numerical substitution", {
  ctx <- load_conquest_p2_metric_boundary_contract()
  states <- ctx$env$mfrmr_cq_p2m_boundary_state_registry()

  expect_identical(nrow(states), 11L)
  expect_false(anyDuplicated(states$QuantityState) > 0L)
  expect_identical(
    states$QuantityState[states$CoordinateMetricEligible],
    "finite_native_estimate"
  )
  expect_identical(
    states$QuantityState[states$PosteriorMetricConditionallyEligible],
    "finite_posterior_summary"
  )
  unbounded <- grepl("^unbounded_", states$QuantityState)
  expect_true(all(states$CategoricalStateComparable[unbounded]))
  expect_false(any(states$CoordinateMetricEligible[unbounded]))
  adjusted <- states$QuantityState == "finite_adjusted_display"
  expect_false(states$CoordinateMetricEligible[adjusted])
  expect_false(states$PosteriorMetricConditionallyEligible[adjusted])
  observed <- states$QuantityLayer == "observed_score"
  expect_setequal(
    states$QuantityState[observed],
    c("nonextreme_raw_score", "minimum_raw_score", "maximum_raw_score")
  )
  expect_true(all(states$CategoricalStateComparable[observed]))
  expect_false(any(states$CrossLayerSubstitutionAllowed))
  expect_false(any(states$CanPromoteReadiness))
  expect_false(any(states$ScientificEquivalenceInferred))
})

test_that("numeric budgets are reused or mathematically derived by estimand", {
  ctx <- load_conquest_p2_metric_boundary_contract()
  rules <- ctx$env$mfrmr_cq_p2m_metric_rule_registry()
  row <- function(id) rules[rules$RuleId == id, , drop = FALSE]

  expect_identical(nrow(rules), 18L)
  expect_false(anyDuplicated(rules$RuleId) > 0L)
  expect_true(all(rules$Frozen))
  expect_identical(
    row("P2-XENG-COORDINATE")$AbsoluteTolerance, 1e-5
  )
  expect_identical(
    row("P2-XENG-DEVIANCE")$AbsoluteTolerance, 2e-6
  )
  q <- grepl("Q-MOVEMENT", rules$RuleId, fixed = TRUE)
  expect_true(all(rules$AbsoluteTolerance[q] == 2e-6))
  numeric <- rules$NumericPassAuthorized
  expect_identical(
    rules$SignedLower[numeric], -rules$AbsoluteTolerance[numeric]
  )
  expect_identical(
    rules$SignedUpper[numeric], rules$AbsoluteTolerance[numeric]
  )

  rsm <- ctx$env$mfrmr_cq_p2m_probability_budget("RSM")
  pcm <- ctx$env$mfrmr_cq_p2m_probability_budget("PCM")
  expect_identical(rsm$MaximumPairwiseCoefficientL1, 15)
  expect_identical(pcm$MaximumPairwiseCoefficientL1, 15)
  expect_equal(
    rsm$AbsoluteProbabilityTolerance, expm1(15 * 1e-5),
    tolerance = 0
  )
  expect_equal(
    pcm$AbsoluteProbabilityTolerance, expm1(15 * 1e-5),
    tolerance = 0
  )
  expect_identical(rsm$ExpectedCells, 240L)
  expect_identical(pcm$ExpectedCells, 240L)

  posterior <- rules$RuleId %in%
    c("P2-PERSON-EAP", "P2-PERSON-POSTERIOR-SD")
  expect_true(all(is.na(rules$AbsoluteTolerance[posterior])))
  expect_false(any(rules$NumericPassAuthorized[posterior]))
  expect_true(all(
    rules$AcceptanceMode[posterior] ==
      "typed_ineligible_pending_identity_and_budget"
  ))
  ordering <- rules$RuleId %in%
    c("P2-RATER-ORDERING", "P2-CRITERION-ORDERING")
  expect_true(all(rules$TieBand[ordering] == 2e-5))
  expect_false(any(rules$CanPromoteMfrmrReadiness))
  expect_false(any(rules$ScientificEquivalenceInferred))
})

test_that("the metric-level and atomic P2 denominators are complete", {
  ctx <- load_conquest_p2_metric_boundary_contract()
  denominator <- ctx$env$mfrmr_cq_p2m_denominator_registry()
  rules <- ctx$env$mfrmr_cq_p2m_metric_rule_registry()
  registry <- ctx$env$mfrmr_cq_ssr_registry()
  p2_ids <- registry$RegistryRowId[registry$Priority == "P2"]

  expect_identical(nrow(denominator), 147L)
  expect_false(anyDuplicated(denominator$MetricRowId) > 0L)
  expect_identical(sum(denominator$ExpectedAtomicCount), 5073L)
  expect_true(all(denominator$RetainFailedOrIneligible))
  expect_false(any(denominator$ExternalExecutionAuthorized))
  expect_false(any(denominator$ComparisonPassed))
  expect_setequal(unique(denominator$RuleId), rules$RuleId)

  core_rules <- c(
    "P2-XENG-COORDINATE", "P2-XENG-DEVIANCE",
    "P2-CONQUEST-Q-MOVEMENT-COORDINATE",
    "P2-MFRMR-Q-MOVEMENT-COORDINATE",
    "P2-CONQUEST-Q-MOVEMENT-DEVIANCE",
    "P2-MFRMR-Q-MOVEMENT-DEVIANCE",
    "P2-RSM-CONDITIONAL-PROBABILITY",
    "P2-PCM-CONDITIONAL-PROBABILITY",
    "P2-PERSON-EAP", "P2-PERSON-POSTERIOR-SD",
    "P2-RATER-ORDERING", "P2-CRITERION-ORDERING",
    "P2-READINESS-STATE", "P2-DECISION-CONSEQUENCE"
  )
  core <- denominator[
    denominator$RuleId %in% core_rules &
      !grepl(";", denominator$RegistryScope, fixed = TRUE), ,
    drop = FALSE
  ]
  count <- table(core$RegistryScope)
  expect_identical(length(count), 11L)
  expect_true(all(count == 13L))

  coordinate <- denominator[
    denominator$RuleId == "P2-XENG-COORDINATE", , drop = FALSE
  ]
  expect_identical(sort(coordinate$ExpectedAtomicCount),
                   sort(c(rep(13L, 7L), rep(19L, 4L))))
  posterior <- denominator$RuleId %in%
    c("P2-PERSON-EAP", "P2-PERSON-POSTERIOR-SD")
  expect_identical(sum(posterior), 22L)
  expect_true(all(denominator$ExpectedAtomicCount[posterior] == 48L))
  expect_true(all(
    denominator$ExpectedResultState[posterior] ==
      "typed_ineligible_pending_posterior_identity"
  ))

  pair <- denominator$RuleId == "P2-PAIRED-MISSINGNESS"
  extreme <- denominator$RuleId == "P2-EXTREME-QUANTITY-TYPING"
  expect_identical(denominator$ExpectedAtomicCount[pair], 288L)
  expect_identical(denominator$ExpectedAtomicCount[extreme], 432L)
  scope_ids <- unique(unlist(strsplit(
    denominator$RegistryScope, ";", fixed = TRUE
  )))
  expect_setequal(scope_ids, p2_ids)
})

test_that("failure, stop, and expansion rules retain every observed outcome", {
  ctx <- load_conquest_p2_metric_boundary_contract()
  rules <- ctx$env$mfrmr_cq_p2m_stop_rule_registry()
  registry <- ctx$env$mfrmr_cq_ssr_registry()
  p2 <- registry[registry$Priority == "P2", , drop = FALSE]
  allowed <- unique(unlist(strsplit(
    p2$AllowedObservedOutcomes, ";", fixed = TRUE
  )))

  expect_identical(nrow(rules), 15L)
  expect_false(anyDuplicated(rules$ObservedOutcome) > 0L)
  expect_setequal(rules$ObservedOutcome, allowed)
  expect_true(all(rules$RetainInCompleteDenominator))
  expect_true(rules$NumericMetricsEligible[rules$ObservedOutcome == "eligible"])
  expect_false(any(rules$NumericMetricsEligible[
    rules$ObservedOutcome != "eligible"
  ]))
  expect_true(all(c(
    "implementation_defect", "unknown", "expected_typed_rejection"
  ) %in% rules$ObservedOutcome))
  expect_false(any(rules$WiderDesignExpansionAllowed))
  integration <- rules$ObservedOutcome == "integration_unresolved"
  expect_identical(
    rules$PermittedNarrowExpansion[integration],
    "prespecified_q_ladder_only"
  )
  control <- rules$ObservedOutcome == "unexpected_control_acceptance"
  expect_identical(rules$InvalidationScope[control],
                   "entire_execution_slice")
  expect_false(any(rules$CanPromoteMfrmrReadiness))
  expect_false(any(rules$CanInferScientificEquivalence))
})

test_that("semantic mutation of any P2 contract layer fails closed", {
  ctx <- load_conquest_p2_metric_boundary_contract()
  env <- ctx$env

  boundary <- env$mfrmr_cq_p2m_boundary_state_registry()
  boundary$CoordinateMetricEligible[
    boundary$QuantityState == "finite_adjusted_display"
  ] <- TRUE
  expect_false(env$mfrmr_cq_p2m_validate(
    boundary_states = boundary
  )$boundary_state_registry_ready)

  metric <- env$mfrmr_cq_p2m_metric_rule_registry()
  metric$AbsoluteTolerance[
    metric$RuleId == "P2-RSM-CONDITIONAL-PROBABILITY"
  ] <- 1e-3
  expect_false(env$mfrmr_cq_p2m_validate(
    metric_rules = metric
  )$metric_rule_registry_ready)

  denominator <- env$mfrmr_cq_p2m_denominator_registry()
  denominator <- denominator[-1L, , drop = FALSE]
  expect_false(env$mfrmr_cq_p2m_validate(
    denominator = denominator
  )$complete_denominator_ready)

  stop <- env$mfrmr_cq_p2m_stop_rule_registry()
  stop$WiderDesignExpansionAllowed[1L] <- TRUE
  expect_false(env$mfrmr_cq_p2m_validate(
    stop_rules = stop
  )$stop_rule_registry_ready)

  original_contract <- env$mfrmr_cq_ptf_contract
  env$mfrmr_cq_ptf_contract <- "wrong_tolerance_contract"
  expect_error(
    env$mfrmr_cq_p2m_metric_rule_registry(),
    "exact successor registry, P2 fixture, and prospective tolerance-freeze",
    fixed = TRUE
  )
  env$mfrmr_cq_ptf_contract <- original_contract
  expect_identical(
    nrow(env$mfrmr_cq_p2m_metric_rule_registry()), 18L
  )
})

test_that("P2 metric freeze reaches review but never execution or equivalence", {
  ctx <- load_conquest_p2_metric_boundary_contract()
  review <- ctx$env$mfrmr_cq_p2m_review()

  expect_identical(
    review$status,
    "P2_fixtures_metrics_boundaries_ready_for_independent_offline_review"
  )
  expect_true(review$fixture_contract$fixture_contract_ready)
  expect_true(review$boundary_quantities_typed)
  expect_true(review$metric_specific_rules_frozen)
  expect_true(review$complete_denominator_frozen)
  expect_true(review$stop_and_expansion_rules_frozen)
  expect_false(review$independent_review_passed)
  expect_false(review$external_execution_authorized)
  expect_false(review$comparison_passed)
  expect_false(review$scientific_equivalence_inferred)
})

test_that("the P2 metric contract is offline and path independent", {
  ctx <- load_conquest_p2_metric_boundary_contract()
  source <- paste(readLines(ctx$paths[4L], warn = FALSE), collapse = "\n")

  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("/Applications/ConQuest", source, fixed = TRUE))
  expect_false(grepl("SHA-256", source, fixed = TRUE))
})

test_that("the internal record closes construction but preserves review gates", {
  ctx <- load_conquest_p2_metric_boundary_contract()
  record_path <- file.path(
    ctx$validation,
    "conquest-p2-metric-boundary-contract-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expected <- c(
    ctx$env$mfrmr_cq_p2m_specification,
    ctx$env$mfrmr_cq_p2m_contract,
    "P2_fixtures_metrics_boundaries_ready_for_independent_offline_review",
    "| Metric-level denominator | 147 |",
    "| Full P2 atomic denominator | 5,073 |",
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
    "[x] Type every finite, unbounded, adjusted-display, and posterior",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Freeze parameter-class coordinate metrics",
    fixed = TRUE
  )
  expect_match(roadmap, "[ ] Review P2 fixtures", fixed = TRUE)
  expect_match(
    roadmap,
    "[ ] Authorize and run only the smallest frozen external P2 slice",
    fixed = TRUE
  )
})
