load_conquest_adversarial_simulation_smoke_authorization <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  paths <- file.path(validation, c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-adversarial-simulation-program-0.2.3.R",
    "conquest-adversarial-simulation-template-contract-0.2.3.R",
    "conquest-adversarial-simulation-dgp-oracle-contract-0.2.3.R",
    "conquest-adversarial-simulation-smoke-authorization-0.2.3.R"
  ))
  skip_if_not(all(file.exists(paths)), "ConQuest ASP G3 files are excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("one sealed smoke seed is frozen for every scenario-family arm", {
  env <- load_conquest_adversarial_simulation_smoke_authorization()$env
  seeds <- env$mfrmr_cq_asg_seed_registry()

  expect_identical(nrow(seeds), 18L)
  expect_identical(anyDuplicated(seeds$ArmId), 0L)
  expect_identical(anyDuplicated(seeds$DatasetId), 0L)
  expect_identical(anyDuplicated(seeds$Seed), 0L)
  expect_identical(seeds$Seed, 987001:987018)
  expect_setequal(
    seeds$ArmId, env$mfrmr_cq_ast_template_registry()$ArmId
  )
  expect_true(all(
    seeds$EvaluationUse == "mechanics_only_not_operating_characteristics"
  ))
  expect_false(any(seeds$MayTuneDGP))
  expect_false(any(seeds$MayTuneMetricThreshold))
  expect_false(any(seeds$MayEstimateFailureRate))
  expect_false(any(seeds$MayEnterCalibration))
  expect_false(any(seeds$MayEnterConfirmation))
  expect_false(any(seeds$MaySupportPublicClaim))
  expect_false(any(seeds$ResultOpened))
  expect_false(any(seeds$Generated))
  expect_true(all(seeds$RetainIfGenerated))
  expect_false(any(seeds$Candidate004DataReused))
  expect_false(any(seeds$Candidate004OutputInformed))
})

test_that("future phases must exclude the frozen smoke namespace", {
  env <- load_conquest_adversarial_simulation_smoke_authorization()$env
  phases <- env$mfrmr_cq_asg_phase_separation_contract()

  expect_identical(phases$Phase, c("smoke", "calibration", "confirmation"))
  expect_identical(phases$SeedState, c("frozen", "not_frozen", "not_frozen"))
  expect_identical(phases$ExactSeedsAssigned, c(18L, 0L, 0L))
  expect_identical(phases$NamespaceStart[1L], 987000L)
  expect_identical(phases$NamespaceEnd[1L], 987099L)
  expect_true(all(phases$MustExcludeFrozenSmokeNamespace[2:3]))
  expect_false(any(phases$ReuseAcrossPhasesPermitted))
})

test_that("output schema retains failures and maps all metric layers", {
  env <- load_conquest_adversarial_simulation_smoke_authorization()$env
  schema <- env$mfrmr_cq_asg_output_schema_registry()
  metric <- env$mfrmr_cq_asg_metric_schema_map()
  policy <- env$mfrmr_cq_asg_non_evaluative_policy()

  expect_identical(nrow(schema), 6L)
  expect_identical(anyDuplicated(schema$TableId), 0L)
  expect_setequal(schema$TableId, c(
    "dataset_manifest", "response_data", "structural_disposition",
    "engine_outcome", "metric_outcome", "continuous_oracle"
  ))
  expect_true(all(schema$FailureOrIneligibleRowsRequired))
  expect_false(any(schema$WriteAuthorizedByThisContract))
  expect_true(grepl(
    "RetainedInUnconditionalDenominator",
    schema$RequiredColumns[schema$TableId == "dataset_manifest"],
    fixed = TRUE
  ))
  expect_true(grepl(
    "FailureClass",
    schema$RequiredColumns[schema$TableId == "engine_outcome"],
    fixed = TRUE
  ))
  expect_identical(nrow(metric), 12L)
  expect_setequal(metric$MetricId, env$mfrmr_cq_asp_metric_registry()$MetricId)
  expect_false(any(metric$MayBeEstimatedFromSmoke))
  expect_identical(sum(metric$ActiveAtSmoke), 4L)
  expect_identical(sum(policy$PermittedForSmoke), 3L)
  expect_false(any(policy$AuthorizedByThisContract))
  expect_false(any(policy$ResultCanChangeFrozenDesign))
})

test_that("coefficient identity removes a duplicate integration path", {
  env <- load_conquest_adversarial_simulation_smoke_authorization()$env
  coefficient <- env$mfrmr_cq_asg_coefficient_audit()
  integrand <- env$mfrmr_cq_asg_integrand_probe_audit()

  expect_identical(nrow(coefficient), 8L)
  expect_identical(sum(coefficient$LocationCategoryCoefficients), 384L)
  expect_lte(
    max(coefficient$MaximumThetaCoefficientDifference),
    env$mfrmr_cq_asg_coefficient_tolerance
  )
  expect_lte(
    max(coefficient$MaximumInterceptDifference),
    env$mfrmr_cq_asg_coefficient_tolerance
  )
  expect_true(all(coefficient$EqualityHoldsForEveryFiniteTheta))
  expect_false(any(coefficient$CandidateOutputRead))
  expect_identical(integrand$Arms, 4L)
  expect_identical(integrand$Persons, 192L)
  expect_identical(integrand$IntegrandEvaluations, 960L)
  expect_lte(
    integrand$MaximumAbsoluteDifference,
    env$mfrmr_cq_asg_integrand_probe_tolerance
  )
  expect_true(integrand$PrototypeFixtureOnly)
  expect_false(integrand$SampledResponseDataUsed)
})

test_that("full-Person qualification authorizes generation but no fit", {
  env <- load_conquest_adversarial_simulation_smoke_authorization()$env
  unopened <- env$mfrmr_cq_asg_review(run_full_continuous_oracle = FALSE)
  review <- env$mfrmr_cq_asg_review(run_full_continuous_oracle = TRUE)
  continuous <- review$full_person_continuous_audit

  expect_identical(
    unopened$status, "ASP_G3_core_frozen_full_person_oracle_unopened"
  )
  expect_false(unopened$G3_authorization_complete)
  expect_identical(
    review$status,
    "ASP_G3_smoke_contract_frozen_generation_authorized_not_run"
  )
  expect_identical(nrow(continuous), 4L)
  expect_identical(sum(continuous$Persons), 192L)
  expect_true(all(continuous$Persons == 48L))
  expect_identical(
    sort(continuous$ObservedRows), c(288L, 288L, 576L, 576L)
  )
  expect_true(all(continuous$ModesInterior))
  expect_true(all(continuous$IntegrationsConverged))
  expect_true(all(
    continuous$DeclaredDevianceErrorEnvelope <=
      env$mfrmr_cq_asg_maximum_deviance_error_envelope
  ))
  expect_true(all(continuous$QuadratureErrorIsNumericalEstimate))
  expect_true(all(continuous$OmittedNormalTailErrorIsAnalyticBound))
  expect_true(all(continuous$PrototypeFixtureOnly))
  expect_false(any(continuous$SampledResponseDataUsed))
  expect_false(any(continuous$FitAttempted))
  expect_false(any(continuous$ExternalExecutionAttempted))
  expect_true(review$G2_exact_DGP_prerequisite_frozen)
  expect_true(review$G3_authorization_complete)
  expect_false(review$G3_smoke_execution_complete)
  expect_false(review$G3_complete)
  expect_true(review$smoke_seed_band_frozen)
  expect_true(review$output_schema_frozen)
  expect_true(review$full_person_continuous_oracle_qualified)
  expect_true(review$algebraic_coefficient_identity_qualified)
  expect_false(review$smoke_results_opened)
  expect_false(review$smoke_operating_characteristics_permitted)
  expect_identical(review$authorized_smoke_datasets, 18L)
  expect_identical(review$maximum_datasets_per_arm, 1L)
  expect_true(review$smoke_dataset_generation_authorized)
  expect_false(review$any_sampled_response_generated)
  expect_false(review$any_fit_authorized)
  expect_false(review$ConQuest_execution_authorized)
  expect_identical(length(review$remaining_generation_blockers), 4L)
  expect_identical(
    review$next_action, "ASP-G3-NONEVALUATIVE-SMOKE-GENERATION"
  )
  expect_false(review$public_text_change_authorized)
  expect_false(review$scientific_equivalence_inferred)
})

test_that("authorization source does not generate, fit, launch, or hash", {
  ctx <- load_conquest_adversarial_simulation_smoke_authorization()
  source <- paste(readLines(ctx$paths[6L], warn = FALSE), collapse = "\n")

  expect_false(grepl(
    "rnorm\\s*\\(|runif\\s*\\(|sample\\s*\\(|set.seed\\s*\\(",
    source, perl = TRUE
  ))
  expect_false(grepl(
    "fit_mfrm\\s*\\(|system2\\s*\\(|system\\s*\\(", source, perl = TRUE
  ))
  expect_false(grepl(
    "SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE
  ))
})

test_that("record and roadmap separate authorization from execution", {
  ctx <- load_conquest_adversarial_simulation_smoke_authorization()
  record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-adversarial-simulation-smoke-authorization-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_asg_specification, fixed = TRUE)
  expect_match(record, "`G3AuthorizationComplete=TRUE`", fixed = TRUE)
  expect_match(record, "`G3SmokeExecutionComplete=FALSE`", fixed = TRUE)
  expect_match(record, "`AnySampledResponseGenerated=FALSE`", fixed = TRUE)
  expect_match(
    roadmap, "[x] Freeze a mechanics-only smoke seed band and output schema",
    fixed = TRUE
  )
  expect_match(
    roadmap, "[x] Generate exactly one sealed smoke dataset per",
    fixed = TRUE
  )
})
