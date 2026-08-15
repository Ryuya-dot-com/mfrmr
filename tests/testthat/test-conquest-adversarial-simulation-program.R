load_conquest_adversarial_simulation_program <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  script <- file.path(
    validation, "conquest-adversarial-simulation-program-0.2.3.R"
  )
  skip_if_not(file.exists(script), "ConQuest simulation program is excluded.")
  env <- new.env(parent = globalenv())
  sys.source(script, envir = env)
  list(root = root, validation = validation, script = script, env = env)
}

test_that("simulation becomes the selected nonpublic workstream", {
  env <- load_conquest_adversarial_simulation_program()$env
  priority <- env$mfrmr_cq_asp_priority_registry()
  selected <- priority[priority$CurrentWorkstreamSelected, , drop = FALSE]

  expect_identical(nrow(priority), 6L)
  expect_identical(anyDuplicated(priority$WorkstreamId), 0L)
  expect_identical(nrow(selected), 1L)
  expect_identical(
    selected$WorkstreamId, "adversarial_simulation_architecture"
  )
  expect_false(any(priority$Candidate004IndependentReviewPrerequisite))
  expect_false(any(priority$ExecutionAuthorized))
  expect_false(any(priority$PublicPromotionAuthorized))
})

test_that("scenario classes cover transport and structural adversity", {
  env <- load_conquest_adversarial_simulation_program()$env
  scenarios <- env$mfrmr_cq_asp_scenario_registry()

  expect_identical(nrow(scenarios), 9L)
  expect_identical(anyDuplicated(scenarios$ScenarioClassId), 0L)
  expect_true(all(scenarios$FamilyCoverage == "RSM;PCM"))
  expect_identical(
    sum(scenarios$ExpectedStructuralDisposition ==
          "reject_before_numeric_comparison"),
    2L
  )
  expect_identical(
    sum(scenarios$DeterministicTemplateState !=
          "available_for_RSM_and_PCM"),
    6L
  )
  expect_true(all(scenarios$DisjointFromOpenedCandidateData))
  expect_true(all(scenarios$IndependentDatasetIsSamplingUnit))
  expect_true(all(scenarios$AllGeneratedDatasetsRetainedInDenominator))
  expect_false(any(scenarios$PilotEligible))
  expect_false(any(scenarios$ConfirmationEligible))
})

test_that("metric layers keep failures beside conditional summaries", {
  env <- load_conquest_adversarial_simulation_program()$env
  metrics <- env$mfrmr_cq_asp_metric_registry()

  expect_identical(nrow(metrics), 12L)
  expect_identical(anyDuplicated(metrics$MetricId), 0L)
  expect_true("truth" %in% metrics$Perspective)
  expect_true("independent_oracle" %in% metrics$Perspective)
  expect_true("cross_engine" %in% metrics$Perspective)
  expect_true("decision_safety" %in% metrics$Perspective)
  expect_identical(
    metrics$AnalysisState[metrics$MetricId == "ASP-UNCERTAINTY-COVERAGE"],
    "deferred_until_covariance_estimand_is_proven"
  )
  expect_false(any(metrics$Candidate004ThresholdInherited))
  expect_false(any(metrics$FailureRowsDroppable))
  expect_false(any(metrics$PublicClaimAuthorized))
})

test_that("seven unresolved design fields block every generated response", {
  env <- load_conquest_adversarial_simulation_program()$env
  fields <- env$mfrmr_cq_asp_design_field_registry()
  pending <- fields[fields$State == "pending_before_generation", , drop = FALSE]

  expect_identical(nrow(fields), 17L)
  expect_identical(nrow(pending), 7L)
  expect_true(all(is.na(pending$Value)))
  expect_true(all(pending$BlocksGenerationWhenPending))
  expect_false(any(fields$CandidateOutputInformed))
  expect_identical(
    fields$Value[fields$Field == "candidate_004_review_dependency"],
    "not_a_prerequisite_for_the_successor_simulation"
  )
  expect_identical(
    fields$Value[fields$Field == "candidate_004_data_reuse"],
    "forbidden"
  )
})

test_that("the gate order starts at cross-family template completion", {
  env <- load_conquest_adversarial_simulation_program()$env
  gates <- env$mfrmr_cq_asp_gate_registry()
  current <- gates[gates$CurrentGate, , drop = FALSE]

  expect_identical(nrow(gates), 9L)
  expect_identical(current$GateId, "ASP-G1-TEMPLATE-COMPLETION")
  expect_identical(gates$State[1L], "complete")
  expect_true(all(gates$State[-1L] == "pending"))
  expect_false(any(gates$Candidate004IndependentReviewPrerequisite))
  expect_false(any(gates$ExecutionAuthorizedByThisGateRecord))
  expect_false(any(gates$PublicPromotionAuthorized))
})

test_that("the architecture remains execution closed", {
  ctx <- load_conquest_adversarial_simulation_program()
  review <- ctx$env$mfrmr_cq_asp_review()
  source <- paste(readLines(ctx$script, warn = FALSE), collapse = "\n")

  expect_identical(
    review$status, "prospective_architecture_frozen_execution_closed"
  )
  expect_false(review$candidate_004_historical_records_mutated)
  expect_false(review$candidate_004_handoff_cancelled)
  expect_false(review$candidate_004_active_promotion_target)
  expect_false(review$candidate_004_independent_review_blocks_program)
  expect_false(review$external_review_required_to_start_program)
  expect_true(review$optional_later_external_audit_retained)
  expect_true(review$population_simulation_claim_selected)
  expect_true(review$P2_RSM_PCM_first)
  expect_true(review$P3_item_only_GPCM_deferred_until_P2_classified)
  expect_true(review$many_facet_free_slope_GPCM_excluded)
  expect_false(review$exact_design_complete)
  expect_false(review$any_data_generation_authorized)
  expect_false(review$any_fit_authorized)
  expect_false(review$ConQuest_execution_authorized)
  expect_false(review$public_text_change_authorized)
  expect_false(review$scientific_equivalence_inferred)
  expect_false(grepl("rnorm\\s*\\(|runif\\s*\\(|sample\\s*\\(",
                     source, perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(|system2\\s*\\(|system\\s*\\(",
                     source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source,
                     ignore.case = TRUE))
})

test_that("record states the nonblocking review and generation firewall", {
  ctx <- load_conquest_adversarial_simulation_program()
  record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-adversarial-simulation-program-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_asp_specification, fixed = TRUE)
  expect_match(
    record, "`Candidate004IndependentReviewBlocksProgram=FALSE`",
    fixed = TRUE
  )
  expect_match(record, "`AnyDataGenerationAuthorized=FALSE`", fixed = TRUE)
  expect_match(record, "scenario-by-family dataset", fixed = TRUE)
  expect_match(record, "Smoke, calibration, and confirmation", fixed = TRUE)

  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  expect_match(
    roadmap, "#### P4S -- successor adversarial simulation program",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Reassess the independent post-output review by expected information gain",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[ ] Complete the six missing cross-family or disjoint deterministic",
    fixed = TRUE
  )
})
