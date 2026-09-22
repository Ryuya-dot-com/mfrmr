gtheory_monte_carlo_value_paths <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  file.path(validation, c(
    "gtheory-design-algebra-prototype-0.2.3.R",
    "gtheory-balanced-estimation-prototype-0.2.3.R",
    "gtheory-design-incidence-audit-0.2.3.R",
    "gtheory-covariance-information-audit-0.2.3.R",
    "gtheory-glmmtmb-parity-prototype-0.2.3.R",
    "gtheory-ademp-registry-prototype-0.2.3.R",
    "gtheory-ademp-generator-prototype-0.2.3.R",
    "gtheory-ademp-prefit-prototype-0.2.3.R",
    "gtheory-ademp-fit-prototype-0.2.3.R",
    "gtheory-weak-information-calibration-prototype-0.2.3.R",
    "gtheory-weak-information-pilot-prototype-0.2.3.R",
    "gtheory-weak-information-diagnostic-refit-prototype-0.2.3.R",
    "gtheory-weak-information-bootstrap-prototype-0.2.3.R",
    "gtheory-weak-information-feasibility-prototype-0.2.3.R",
    "gtheory-weak-information-feasibility-runner-0.2.3.R",
    "gtheory-weak-information-numerical-sensitivity-0.2.3.R",
    "gtheory-weak-information-typed-replay-0.2.3.R",
    "gtheory-weak-information-glmmtmb-stabilization-prototype-0.2.3.R",
    "gtheory-weak-information-glmmtmb-stabilization-runner-0.2.3.R",
    "gtheory-weak-information-glmmtmb-stationarity-instrumentation-0.2.3.R",
    "gtheory-weak-information-glmmtmb-stationarity-calibration-design-0.2.3.R",
    "gtheory-weak-information-glmmtmb-stationarity-reference-calibration-0.2.3.R",
    "gtheory-weak-information-stationarity-calibration-authorization-audit-0.2.3.R",
    "gtheory-weak-information-glmmtmb-ml-reference-coverage-0.2.3.R",
    "gtheory-weak-information-lme4-objective-reference-preflight-0.2.3.R",
    "gtheory-weak-information-lme4-reference-coverage-0.2.3.R",
    "gtheory-weak-information-stationarity-acceptance-policy-0.2.3.R",
    "gtheory-weak-information-production-boundary-probe-0.2.3.R",
    "gtheory-weak-information-stationarity-exact-resume-runner-0.2.3.R",
    "gtheory-weak-information-production-adapter-preflight-0.2.3.R",
    "gtheory-weak-information-one-way-authorization-preflight-0.2.3.R",
    "gtheory-weak-information-monte-carlo-value-audit-0.2.3.R"
  ))
}

load_gtheory_monte_carlo_value <- function() {
  paths <- gtheory_monte_carlo_value_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  for (package in c(
    "digest", "lme4", "Matrix", "glmmTMB", "TMB", "minqa", "nloptr",
    "numDeriv"
  )) skip_if_not_installed(package)
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtheory_monte_carlo_value_contract <- function(env) {
  plan <- env$mfrmr_gtwp_plan()
  design <- env$mfrmr_gtwsz_contract(plan)
  design_manifest <- env$mfrmr_gtwsz_manifest(design, plan)
  glmm_reference <- env$mfrmr_gtwta_contract(design)
  glmm_reference_manifest <- env$mfrmr_gtwta_manifest(glmm_reference)
  authorization <- env$mfrmr_gtwaa_contract(
    design, design_manifest, glmm_reference, glmm_reference_manifest
  )
  sealed <- env$mfrmr_gtwaa_manifest(authorization, design_manifest)
  ml_coverage <- env$mfrmr_gtwab_contract(authorization, glmm_reference)
  objective_preflight <- env$mfrmr_gtwac_contract(ml_coverage)
  lme4_reference <- env$mfrmr_gtwad_contract(objective_preflight)
  acceptance <- env$mfrmr_gtwae_contract(lme4_reference)
  boundary <- env$mfrmr_gtwaf_contract(acceptance)
  runner <- env$mfrmr_gtwag_contract(boundary, authorization, sealed)
  adapter <- env$mfrmr_gtwah_contract(
    runner, boundary, glmm_reference, lme4_reference
  )
  reserved <- env$mfrmr_gtwah_reserved_manifest(adapter, sealed)
  authorization_preflight <- env$mfrmr_gtwai_contract(adapter, reserved)
  list(
    Contract = env$mfrmr_gtwaj_contract(authorization_preflight),
    AuthorizationPreflight = authorization_preflight,
    AcceptancePolicy = env$mfrmr_gtwae_policy()
  )
}

gtheory_monte_carlo_value_cache <- new.env(parent = emptyenv())

gtheory_monte_carlo_value_cached <- function() {
  if (!is.null(gtheory_monte_carlo_value_cache$result)) {
    return(gtheory_monte_carlo_value_cache$result)
  }
  env <- load_gtheory_monte_carlo_value()
  objects <- gtheory_monte_carlo_value_contract(env)
  result <- list(Env = env, Objects = objects)
  gtheory_monte_carlo_value_cache$result <- result
  result
}

test_that("b1g15a scalar Monte Carlo calculations reproduce", {
  env <- load_gtheory_monte_carlo_value()

  expect_equal(env$mfrmr_gtwaj_binomial_mcse(0.5, 100), 0.05,
               tolerance = 1e-15)
  expect_equal(env$mfrmr_gtwaj_binomial_mcse(0.05, 100),
               sqrt(0.05 * 0.95 / 100), tolerance = 1e-15)
  expect_equal(env$mfrmr_gtwaj_zero_event_upper(100),
               stats::qbeta(0.95, 1, 100), tolerance = 1e-14)
  expect_equal(env$mfrmr_gtwaj_detection_probability(0.03, 100),
               1 - 0.97^100, tolerance = 1e-15)
  expect_identical(
    vapply(c(0.05, 0.03, 0.02, 0.01, 0.005),
           env$mfrmr_gtwaj_minimum_n_zero_upper, integer(1L)),
    c(59L, 99L, 149L, 299L, 598L)
  )
  expect_identical(env$mfrmr_gtwaj_minimum_n_mcse(0.05, 0.01), 475L)
  expect_identical(env$mfrmr_gtwaj_minimum_n_mcse(0.80, 0.01), 1600L)
  expect_identical(env$mfrmr_gtwaj_minimum_n_mcse(0.95, 0.005), 1900L)
  expect_equal(
    env$mfrmr_gtwaj_paired_difference_mcse(0.10, 0.05, 100),
    sqrt((0.15 - 0.05^2) / 100), tolerance = 1e-15
  )

  expect_error(env$mfrmr_gtwaj_binomial_mcse(-0.1, 100),
               "finite probabilities")
  expect_error(env$mfrmr_gtwaj_zero_event_upper(0), "positive integer")
  expect_error(env$mfrmr_gtwaj_zero_event_upper(100, 1),
               "strictly between")
  expect_error(env$mfrmr_gtwaj_minimum_n_mcse(0.5, 0), "finite positive")
  expect_error(env$mfrmr_gtwaj_paired_difference_mcse(0.8, 0.3, 100),
               "discordance")
})

test_that("b1g15a binds exact upstream identities and independence units", {
  result <- gtheory_monte_carlo_value_cached()
  env <- result$Env
  contract <- result$Objects$Contract
  policy <- contract$Policy

  expect_s3_class(contract, "mfrmr_gtwaj_contract")
  expect_true(env$mfrmr_gtwaj_contract_hash_valid(contract))
  expect_true(env$mfrmr_gtwaj_policy_hash_valid(policy))
  expect_identical(
    contract$UpstreamAuthorizationPreflightContractHash,
    "44a6d4e2677af111e6eeeae8b7b3143ce8521db34da1769a86b85f32c63ca551"
  )
  expect_identical(
    contract$AcceptancePolicyHash,
    "7962e47df285812d8c785f206d51925b44a13d02037b7b40a619cb80ce833a62"
  )
  expect_identical(policy$ScenarioCount, 30L)
  expect_identical(policy$DesignCount * policy$VarianceRegionCount, 30L)
  expect_identical(policy$CalibrationReplicatesPerScenario, 100L)
  expect_identical(policy$ConfirmationReplicatesPerScenario, 200L)
  expect_identical(policy$IndependentMonteCarloUnit,
                   "scenario_by_replicate_dataset")
  expect_identical(policy$PrimaryCell, "scenario_method_model_role")
  expect_true(policy$MethodsArePairedWithinDataset)
  expect_true(policy$ModelRolesAreRepeatedWithinDataset)
  expect_false(policy$OptimizerFitsAreIndependentReplicates)
  expect_false(policy$CandidateDecisionsAreIndependentReplicates)
  expect_false(policy$ReferencesAreIndependentReplicates)
  expect_false(policy$CrossScenarioPoolingForPrimaryPrecisionAllowed)
  expect_false(policy$PostSelectionCoverageClaimAllowed)
  expect_true(policy$ConfirmationRemainsIndependentAndSealed)
  expect_identical(policy$PurposeAuditEventRate, 0.03)
  expect_identical(
    policy$PurposeAuditCompleteDenominatorZeroEventUpperBenchmark, 0.03
  )
  expect_identical(policy$PurposeAuditDetectionProbabilityBenchmark, 0.95)
  expect_false(policy$PurposeAuditBenchmarkEntersCandidateSelection)
  expect_false(policy$CalibrationResponsesUsed)
  expect_false(policy$ConfirmationResponsesUsed)
})

test_that("b1g15a phase precision distinguishes calibration and validation", {
  result <- gtheory_monte_carlo_value_cached()
  contract <- result$Objects$Contract
  phase <- contract$PhasePrecision
  detection <- contract$EventDetection
  future <- contract$FuturePrecisionRequirements

  expect_identical(phase$Phase,
                   c("feasibility", "calibration", "confirmation"))
  expect_identical(phase$ReplicatesPerPrimaryCell, c(25L, 100L, 200L))
  expect_equal(phase$WorstCaseBernoulliMCSE, c(0.10, 0.05, sqrt(0.25 / 200)),
               tolerance = 1e-15)
  expect_equal(phase$ZeroEventUpper95,
               c(0.112928145006, 0.0295130496070, 0.0148670392313),
               tolerance = 1e-11)
  expect_equal(
    detection$CalibrationDetectAtLeastOne[
      detection$EventProbability == 0.03
    ],
    1 - 0.97^100, tolerance = 1e-15
  )
  expect_gt(contract$CompleteDenominatorCalibrationDetectAtLeastOneAt003,
            0.95)
  expect_lt(contract$CompleteDenominatorCalibrationZeroEventUpper95, 0.03)
  expect_lt(contract$CompleteDenominatorConfirmationZeroEventUpper95,
            contract$CompleteDenominatorCalibrationZeroEventUpper95)

  expect_identical(future$NForMCSE001, c(475L, 475L, 1600L, 2500L))
  expect_identical(future$NForMCSE0005, c(1900L, 1900L, 6400L, 10000L))
  expect_identical(future$NFor95HalfWidth002,
                   c(457L, 457L, 1537L, 2401L))
  expect_identical(future$NFor95HalfWidth001,
                   c(1825L, 1825L, 6147L, 9604L))
  expect_gt(future$NForMCSE001[future$PerformanceMeasure == "coverage"],
            100L)
  expect_gt(future$NForMCSE001[future$PerformanceMeasure == "power"],
            100L)
})

test_that("b1g15a audit retains cost only for its narrow purpose", {
  result <- gtheory_monte_carlo_value_cached()
  env <- result$Env
  contract <- result$Objects$Contract
  audit <- env$mfrmr_gtwaj_audit(contract)

  expect_s3_class(audit, "mfrmr_gtwaj_audit")
  expect_true(env$mfrmr_gtwaj_audit_hash_valid(audit))
  expect_identical(audit$ExactWorkloadCounts, c(
    IndependentDatasets = 3000L, CandidateFits = 108000L,
    CandidateDecisions = 576000L, References = 24000L
  ))
  expect_equal(audit$IndependentReplicateFractionOfCandidateFits, 1 / 36,
               tolerance = 1e-15)
  expect_identical(audit$PlannedCalibrationReplicatesPerPrimaryCell, 100L)
  expect_equal(audit$CompleteDenominatorCalibrationWorstCaseBernoulliMCSE,
               0.05,
               tolerance = 1e-15)
  expect_equal(audit$CompleteDenominatorCalibrationMCSEAtRate005,
               audit$CompleteDenominatorCalibrationMCSEAtRate095,
               tolerance = 1e-15)
  expect_equal(audit$CompleteDenominatorCalibrationMCSEAtRate080, 0.04,
               tolerance = 1e-15)
  expect_true(audit$NumericalCalibrationDesignPurposeJustified)
  expect_false(audit$CalibrationPrecisionEvidenceReady)
  expect_false(audit$BroadBiasRMSECoverageClaimSupported)
  expect_false(audit$DStudyOperatingCharacteristicClaimSupported)
  expect_false(audit$UniversalSampleSizeRuleSupported)
  expect_true(audit$BroadClaimsRequireSeparatePrecisionDesignedStudy)
  expect_false(audit$PurposeAuditBenchmarkEntersCandidateSelection)
  expect_identical(
    audit$ExecutionValueConclusion,
    "proportionate_for_numerical_calibration_only_not_broad_validation"
  )
  expect_true(audit$MonteCarloValueAuditReady)
  expect_true(audit$CurrentCalibrationDesignRetained)
  expect_false(audit$ActivationEligibilityChanged)
  expect_false(audit$ExecutionAuthorizationRecordIssued)
  expect_false(audit$CalibrationExecutionAuthorized)
  expect_false(audit$CalibrationDataGenerated)
  expect_false(audit$CalibrationResultsViewed)
  expect_false(audit$ConfirmationAuthorized)
  expect_false(audit$InferenceReady)
  expect_false(audit$CoefficientEligible)
  expect_false(audit$DecisionReady)
})

test_that("b1g15a validators recompute tables flags and upstream identity", {
  result <- gtheory_monte_carlo_value_cached()
  env <- result$Env
  contract <- result$Objects$Contract
  audit <- env$mfrmr_gtwaj_audit(contract)

  mutated <- contract
  mutated$PhasePrecision$ZeroEventUpper95[
    mutated$PhasePrecision$Phase == "calibration"
  ] <- 0
  expect_false(env$mfrmr_gtwaj_contract_hash_valid(mutated))

  mutated <- contract
  mutated$BroadBiasRMSECoverageClaimSupported <- TRUE
  expect_false(env$mfrmr_gtwaj_contract_hash_valid(mutated))

  mutated <- contract
  mutated$PlannedIndependentCalibrationReplicatesPerPrimaryCell <- 108000L
  expect_false(env$mfrmr_gtwaj_contract_hash_valid(mutated))

  mutated <- audit
  mutated$CalibrationExecutionAuthorized <- TRUE
  expect_false(env$mfrmr_gtwaj_audit_hash_valid(mutated))

  mutated <- audit
  mutated$BroadBiasRMSECoverageClaimSupported <- TRUE
  expect_false(env$mfrmr_gtwaj_audit_hash_valid(mutated))

  mutated <- audit
  mutated$MonteCarloValueAuditReady <- FALSE
  expect_false(env$mfrmr_gtwaj_audit_hash_valid(mutated))

  upstream <- result$Objects$AuthorizationPreflight
  upstream$ContractHash <- paste0("f", substring(upstream$ContractHash, 2L))
  expect_error(env$mfrmr_gtwaj_contract(upstream), "Exact non-authorizing")
})
