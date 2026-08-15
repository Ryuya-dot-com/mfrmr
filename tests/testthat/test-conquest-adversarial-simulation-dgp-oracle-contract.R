load_conquest_adversarial_simulation_dgp_oracles <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  paths <- file.path(validation, c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-adversarial-simulation-program-0.2.3.R",
    "conquest-adversarial-simulation-template-contract-0.2.3.R",
    "conquest-adversarial-simulation-dgp-oracle-contract-0.2.3.R"
  ))
  skip_if_not(all(file.exists(paths)), "ConQuest ASP DGP files are excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("four exact DGP profiles map onto all nine scenarios", {
  env <- load_conquest_adversarial_simulation_dgp_oracles()$env
  profiles <- env$mfrmr_cq_ado_profile_registry()
  mapping <- env$mfrmr_cq_ado_scenario_map()

  expect_identical(nrow(profiles), 4L)
  expect_identical(anyDuplicated(profiles$ProfileId), 0L)
  expect_true(all(profiles$Frozen))
  expect_false(any(profiles$CandidateOutputInformed))
  expect_identical(nrow(mapping), 9L)
  expect_identical(anyDuplicated(mapping$ScenarioClassId), 0L)
  expect_setequal(
    mapping$ScenarioClassId,
    env$mfrmr_cq_asp_scenario_registry()$ScenarioClassId
  )
  expect_identical(sum(mapping$RecoveryEligible), 6L)
  expect_identical(sum(mapping$FitExpected), 7L)
  expect_false(any(mapping$DataGenerationAuthorized))
  expect_false(any(mapping$PublicClaimAuthorized))
})

test_that("all DGP coordinates obey the declared constraints", {
  env <- load_conquest_adversarial_simulation_dgp_oracles()$env
  audit <- env$mfrmr_cq_ado_truth_audit()
  central_rsm <- env$mfrmr_cq_ado_truth("ASP-DGP-CENTRAL-MODEL", "RSM")
  rare_pcm <- env$mfrmr_cq_ado_truth("ASP-DGP-RARE-BOUNDARY", "PCM")

  expect_identical(nrow(audit), 8L)
  expect_true(all(audit$PopulationVariancePositive))
  expect_true(all(abs(audit$RaterSum) < 1e-15))
  expect_true(all(abs(audit$CriterionSum) < 1e-15))
  expect_true(all(audit$StepConstraintMaximum < 1e-15))
  expect_true(all(audit$Finite))
  expect_identical(central_rsm$PopulationIntercept, 0.10)
  expect_identical(central_rsm$PopulationSlope, 0.45)
  expect_identical(central_rsm$PopulationVariance, 0.70)
  expect_identical(unname(central_rsm$Steps), c(-0.90, 0.10, 0.80))
  expect_identical(
    unname(rare_pcm$Steps),
    matrix(c(-1.70, 0.10, 1.60, -1.50, -0.10, 1.60,
             -1.80, 0.20, 1.60), nrow = 3L, byrow = TRUE)
  )
})

test_that("direct generator probabilities match the reconstructed-A oracle", {
  env <- load_conquest_adversarial_simulation_dgp_oracles()$env
  audit <- env$mfrmr_cq_ado_probability_audit()

  expect_identical(audit$Cases, 672L)
  expect_lt(audit$MaximumAbsoluteDifference, 1e-14)
  expect_true(audit$AllDirectProbabilitiesPositive)
  expect_false(audit$GeneratorCallsMatrixOracle)
  expect_false(audit$CandidateOutputRead)
})

test_that("uniform primitives validate inputs without creating randomness", {
  env <- load_conquest_adversarial_simulation_dgp_oracles()$env
  probability <- c(0.1, 0.2, 0.3, 0.4)

  expect_identical(
    vapply(c(0.05, 0.10, 0.11, 0.30, 0.31, 0.60, 0.61, 0.99),
           function(value) env$mfrmr_cq_ado_response_from_uniform(
             probability, value
           ), integer(1L)),
    c(0L, 0L, 1L, 1L, 2L, 2L, 3L, 3L)
  )
  expect_error(
    env$mfrmr_cq_ado_response_from_uniform(probability, 0),
    "strictly inside (0,1)", fixed = TRUE
  )
  expect_error(
    env$mfrmr_cq_ado_response_from_uniform(probability, 1),
    "strictly inside (0,1)", fixed = TRUE
  )
  expect_error(
    env$mfrmr_cq_ado_response_from_uniform(c(0.2, 0.2, 0.2, 0.2), 0.5),
    "summing to one", fixed = TRUE
  )
})

test_that("extreme anchors are typed stress values rather than recovery draws", {
  env <- load_conquest_adversarial_simulation_dgp_oracles()$env
  templates <- env$mfrmr_cq_ast_templates()
  ordinary <- templates[["ASP-POS-COMPLETE::RSM"]]
  extreme <- templates[["ASP-SENS-EXTREME-PERSON::RSM"]]
  uniforms <- seq_len(48L) / 49
  ordinary_latent <- env$mfrmr_cq_ado_latent_from_uniform(ordinary, uniforms)
  extreme_latent <- env$mfrmr_cq_ado_latent_from_uniform(extreme, uniforms)

  expect_false(any(ordinary_latent$TailAnchorApplied))
  expect_true(ordinary_latent$RecoveryEligible[1L])
  expect_identical(sum(extreme_latent$TailAnchorApplied), 2L)
  expect_false(extreme_latent$RecoveryEligible[1L])
  expect_lt(extreme_latent$LatentValue[1L], ordinary_latent$LatentValue[1L])
  expect_gt(extreme_latent$LatentValue[48L], ordinary_latent$LatentValue[48L])
})

test_that("generator and oracle components are separate from fit paths", {
  env <- load_conquest_adversarial_simulation_dgp_oracles()$env
  contract <- env$mfrmr_cq_ado_generator_contract()

  expect_identical(nrow(contract), 6L)
  expect_false(any(contract$CallsMfrmrFit))
  expect_false(any(contract$CallsConQuest))
  expect_false(any(contract$CreatesRandomnessInternally))
  expect_true(all(contract$ImplementedAtG2[1:5]))
  expect_false(contract$ImplementedAtG2[6L])
  expect_identical(which(contract$PermittedInGenerationPath), 1:3)
  expect_true(grepl(
    "absent_until_ASP_G3", contract$Implementation[6L], fixed = TRUE
  ))
})

test_that("continuous oracle agrees across independent probability paths", {
  env <- load_conquest_adversarial_simulation_dgp_oracles()$env
  audit <- env$mfrmr_cq_ado_continuous_audit()

  expect_identical(nrow(audit), 4L)
  expect_setequal(audit$Family, c("RSM", "PCM"))
  expect_true(all(audit$Persons == 1L))
  expect_true(all(audit$FullArmAuditDeferredToG3))
  expect_true(all(audit$ModesInterior))
  expect_true(all(audit$IntegrationsConverged))
  expect_true(all(audit$AbsoluteLogLikelihoodDifference <= 1e-10))
  expect_true(all(
    audit$MaximumDeclaredDevianceErrorBound <=
      env$mfrmr_cq_ado_maximum_sentinel_deviance_error_envelope
  ))
  expect_false(any(audit$FitAttempted))
  expect_false(any(audit$ExternalExecutionAttempted))
})

test_that("G2 completion leaves five generation blockers", {
  env <- load_conquest_adversarial_simulation_dgp_oracles()$env
  unopened <- env$mfrmr_cq_ado_review(run_continuous_oracles = FALSE)
  review <- env$mfrmr_cq_ado_review(run_continuous_oracles = TRUE)

  expect_identical(
    unopened$status, "ASP_G2_core_frozen_continuous_audit_unopened"
  )
  expect_false(unopened$ASP_G2_complete)
  expect_identical(
    review$status,
    "ASP_G2_exact_DGP_and_separated_oracles_complete_execution_closed"
  )
  expect_true(review$ASP_G1_prerequisite_complete)
  expect_true(review$ASP_G2_complete)
  expect_true(review$exact_DGP_values_frozen)
  expect_true(review$generator_probability_path_separate_from_matrix_oracle)
  expect_true(review$both_probability_paths_separate_from_fit_paths)
  expect_true(review$continuous_oracle_log_centered)
  expect_true(review$quadrature_error_is_numerical_estimate_not_proof)
  expect_true(review$omitted_normal_tail_error_is_analytic_bound)
  expect_identical(review$maximum_sentinel_deviance_error_envelope, 1e-8)
  expect_true(review$continuous_G2_audit_is_one_person_per_arm_sentinel)
  expect_true(review$full_arm_continuous_audit_deferred_to_G3)
  expect_false(review$internal_randomness_created)
  expect_false(review$prototype_responses_reclassified_as_simulation)
  expect_identical(length(review$remaining_generation_blockers), 5L)
  expect_identical(review$next_gate, "ASP-G3-NONEVALUATIVE-SMOKE")
  expect_false(review$any_data_generation_authorized)
  expect_false(review$any_fit_authorized)
  expect_false(review$ConQuest_execution_authorized)
  expect_false(review$public_text_change_authorized)
  expect_false(review$scientific_equivalence_inferred)
})

test_that("G2 source has no RNG, fit, launch, or byte-identity acceptance", {
  ctx <- load_conquest_adversarial_simulation_dgp_oracles()
  source <- paste(readLines(ctx$paths[5L], warn = FALSE), collapse = "\n")

  expect_false(grepl("rnorm\\s*\\(|runif\\s*\\(|sample\\s*\\(",
                     source, perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(|system2\\s*\\(|system\\s*\\(",
                     source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source,
                     ignore.case = TRUE))
})

test_that("record and roadmap advance only to G3", {
  ctx <- load_conquest_adversarial_simulation_dgp_oracles()
  record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-adversarial-simulation-dgp-oracle-contract-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_ado_specification, fixed = TRUE)
  expect_match(record, "`ASPG2Complete=TRUE`", fixed = TRUE)
  expect_match(record, "`AnyDataGenerationAuthorized=FALSE`", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Freeze four exact DGP profiles and implement code-path-separated neutral",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Freeze a mechanics-only smoke seed band and output schema",
    fixed = TRUE
  )
})
