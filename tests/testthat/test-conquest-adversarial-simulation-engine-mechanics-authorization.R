load_conquest_adversarial_simulation_engine_mechanics_authorization <-
    function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  paths <- file.path(validation, c(
    "conquest-semantic-runtime-preflight-0.2.3.R",
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-adversarial-simulation-program-0.2.3.R",
    "conquest-adversarial-simulation-template-contract-0.2.3.R",
    "conquest-adversarial-simulation-dgp-oracle-contract-0.2.3.R",
    "conquest-adversarial-simulation-smoke-authorization-0.2.3.R",
    "conquest-adversarial-simulation-smoke-execution-0.2.3.R",
    "conquest-adversarial-simulation-calibration-freeze-0.2.3.R",
    "conquest-adversarial-simulation-engine-mechanics-authorization-0.2.3.R"
  ))
  skip_if_not(all(file.exists(paths)), "ConQuest ASP G4E files are excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

mfrmr_cq_amea_test_paths <- function(ctx) {
  list(
    smoke = file.path(
      ctx$root, "validation-results", ctx$env$mfrmr_cq_amea_smoke_output_basename
    ),
    output = file.path(
      tempdir(), ctx$env$mfrmr_cq_amea_output_basename
    )
  )
}

test_that("G4E freezes exactly 38 outcomes and 30 run-once attempts", {
  env <- load_conquest_adversarial_simulation_engine_mechanics_authorization()$env
  plan <- env$mfrmr_cq_amea_execution_plan()

  expect_identical(nrow(plan), 38L)
  expect_identical(length(unique(plan$DatasetId)), 18L)
  expect_identical(sum(plan$AttemptCap), 30L)
  expect_identical(plan$AttemptOrder[!is.na(plan$AttemptOrder)], 1:30)
  expect_identical(sum(plan$QuadratureId == "prefit_stop"), 8L)
  expect_identical(
    sum(plan$RepresentationId == "explicit_missing"), 2L
  )
  expect_identical(
    sum(plan$ConQuestCanonicalBridgeForBothPairedRepresentations), 2L
  )
  expect_true(all(plan$RunOnce))
  expect_false(any(plan$AutomaticRetryPermitted))
  expect_false(any(plan$PeerOrCompanionFailureMaySuppressAttempt))
  expect_false(any(plan$NumericAgreementMayAffectAttemptOrder))
  expect_false(any(plan$CalibrationUsePermitted))
  expect_false(any(plan$ExecutionAuthorizedByThisContract))
})

test_that("the paired bridge is semantic and four-part", {
  env <- load_conquest_adversarial_simulation_engine_mechanics_authorization()$env
  bridge <- env$mfrmr_cq_acf_representation_bridge_registry()

  expect_identical(nrow(bridge), 4L)
  expect_identical(bridge$CheckOrder, 1:4)
  expect_true(all(bridge$RequiredForEachPairedDatasetBridgeCheck))
  expect_true(all(
    bridge$ComparisonLevel == "typed_semantic_relation_after_key_sort"
  ))
  expect_false(any(bridge$ByteEqualityRequired))
  expect_false(any(bridge$NumericAgreementInspected))
  expect_identical(
    unique(bridge$SecondaryCodeOnFailure), "representation_bridge_mismatch"
  )
})

test_that("the lossless output boundary excludes numeric agreement", {
  env <- load_conquest_adversarial_simulation_engine_mechanics_authorization()$env
  schema <- env$mfrmr_cq_amea_output_schema_registry()
  stages <- env$mfrmr_cq_amea_stage_registry()

  expect_identical(nrow(schema), 9L)
  expect_identical(sum(schema$ExpectedRowsAtClosedRun), 154L)
  expect_true(all(schema$FailureOrUnattemptedRowsRequired))
  expect_false(any(schema$NumericAgreementColumnPermitted))
  expect_false(any(schema$WriteAuthorizedByThisContract))
  expect_identical(stages$StageOrder, 1:6)
  expect_false(any(stages$NumericAgreementMayBeInspected))
  expect_false(any(stages$ResultMayAuthorizeCalibrationDirectly))
  expect_false(any(stages$ExecutionPerformedByThisContract))
})

test_that("all fatal gates authorize scope but not live execution", {
  ctx <- load_conquest_adversarial_simulation_engine_mechanics_authorization()
  path <- mfrmr_cq_amea_test_paths(ctx)
  review <- ctx$env$mfrmr_cq_amea_review(path$smoke, path$output)

  expect_identical(
    review$status,
    "ASP_G4E_engine_mechanics_scope_authorized_live_sentinel_pending"
  )
  expect_identical(nrow(review$gates), 19L)
  expect_true(all(review$gates$Passed))
  expect_true(review$all_nineteen_fatal_gates_passed)
  expect_true(review$engine_mechanics_scope_authorized)
  expect_true(review$harness_preparation_authorized)
  expect_false(review$live_execution_authorized)
  expect_false(review$fresh_runtime_sentinel_observed)
  expect_true(review$fresh_runtime_sentinel_required_at_execution)
  expect_identical(review$fit_attempt_cap, 30L)
  expect_identical(review$retained_outcome_row_cap, 38L)
  expect_false(review$new_response_generation_authorized)
  expect_false(review$numeric_agreement_inspection_authorized)
  expect_false(review$calibration_generation_authorized)
  expect_false(review$calibration_execution_authorized)
  expect_false(review$any_fit_attempted)
  expect_false(review$ConQuest_execution_attempted)
})

test_that("output, worktree, test, and date drift block scope", {
  ctx <- load_conquest_adversarial_simulation_engine_mechanics_authorization()
  path <- mfrmr_cq_amea_test_paths(ctx)
  env <- ctx$env

  expect_false(env$mfrmr_cq_amea_review(
    path$smoke, path$output, worktree_clean = FALSE
  )$engine_mechanics_scope_authorized)
  expect_false(env$mfrmr_cq_amea_review(
    path$smoke, path$output, ordinary_tests_external_runtime_free = FALSE
  )$engine_mechanics_scope_authorized)
  expect_false(env$mfrmr_cq_amea_review(
    path$smoke, path$output, authorization_date = as.Date("2026-09-01")
  )$engine_mechanics_scope_authorized)
  expect_false(env$mfrmr_cq_amea_review(
    path$smoke, path$smoke
  )$engine_mechanics_scope_authorized)
})

test_that("G4E source has no direct RNG, fit, launch, write, or hash route", {
  ctx <- load_conquest_adversarial_simulation_engine_mechanics_authorization()
  parsed <- getParseData(parse(ctx$paths[10L], keep.source = TRUE))
  calls <- parsed$text[parsed$token == "SYMBOL_FUNCTION_CALL"]

  expect_false(any(c(
    "set.seed", "runif", "rnorm", "sample", "fit_mfrm", "system", "system2",
    "write.csv", "writeLines", "saveRDS", "dir.create", "file.create"
  ) %in% calls))
  source <- paste(readLines(ctx$paths[10L], warn = FALSE), collapse = "\n")
  expect_false(grepl(
    "SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE
  ))
  expect_false(grepl("ConQuest version:|<End of Program", source, fixed = FALSE))
})

test_that("G4E record and internal roadmap retain the live hold", {
  ctx <- load_conquest_adversarial_simulation_engine_mechanics_authorization()
  record <- paste(readLines(file.path(
    ctx$validation,
    paste0(
      "conquest-adversarial-simulation-engine-mechanics-",
      "authorization-record-0.2.3.md"
    )
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_amea_specification, fixed = TRUE)
  expect_match(record, "`EngineMechanicsScopeAuthorized=TRUE`", fixed = TRUE)
  expect_match(record, "`LiveExecutionAuthorized=FALSE`", fixed = TRUE)
  expect_match(record, "semantic equivalence, not byte equality", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Freeze a separate run-once engine-mechanics authorization",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Freeze the fail-closed G4H engine-mechanics harness",
    fixed = TRUE
  )
})
