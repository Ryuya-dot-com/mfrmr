gtheory_stationarity_exact_resume_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
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
      paste0(
        "gtheory-weak-information-glmmtmb-stationarity-",
        "instrumentation-0.2.3.R"
      ),
      paste0(
        "gtheory-weak-information-glmmtmb-stationarity-calibration-",
        "design-0.2.3.R"
      ),
      paste0(
        "gtheory-weak-information-glmmtmb-stationarity-reference-",
        "calibration-0.2.3.R"
      ),
      paste0(
        "gtheory-weak-information-stationarity-calibration-",
        "authorization-audit-0.2.3.R"
      ),
      "gtheory-weak-information-glmmtmb-ml-reference-coverage-0.2.3.R",
      paste0(
        "gtheory-weak-information-lme4-objective-reference-",
        "preflight-0.2.3.R"
      ),
      "gtheory-weak-information-lme4-reference-coverage-0.2.3.R",
      paste0(
        "gtheory-weak-information-stationarity-acceptance-policy-",
        "0.2.3.R"
      ),
      "gtheory-weak-information-production-boundary-probe-0.2.3.R",
      paste0(
        "gtheory-weak-information-stationarity-exact-resume-runner-",
        "0.2.3.R"
      )
    )
  )
}

load_gtheory_stationarity_exact_resume <- function() {
  paths <- gtheory_stationarity_exact_resume_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  for (package in c(
    "digest", "lme4", "Matrix", "glmmTMB", "TMB", "minqa", "nloptr",
    "numDeriv", "withr"
  )) {
    skip_if_not_installed(package)
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtheory_stationarity_exact_resume_objects <- function(env) {
  plan <- env$mfrmr_gtwp_plan()
  design <- env$mfrmr_gtwsz_contract(plan)
  design_manifest <- env$mfrmr_gtwsz_manifest(design, plan)
  reference <- env$mfrmr_gtwta_contract(design)
  reference_manifest <- env$mfrmr_gtwta_manifest(reference)
  authorization_audit <- env$mfrmr_gtwaa_contract(
    design, design_manifest, reference, reference_manifest
  )
  sealed_manifest <- env$mfrmr_gtwaa_manifest(
    authorization_audit, design_manifest
  )
  ml_coverage <- env$mfrmr_gtwab_contract(authorization_audit, reference)
  objective_preflight <- env$mfrmr_gtwac_contract(ml_coverage)
  lme4_coverage <- env$mfrmr_gtwad_contract(objective_preflight)
  acceptance <- env$mfrmr_gtwae_contract(lme4_coverage)
  boundary <- env$mfrmr_gtwaf_contract(acceptance)
  runner <- env$mfrmr_gtwag_contract(
    boundary, authorization_audit, sealed_manifest
  )
  fixture <- env$mfrmr_gtwag_fixture_manifest(runner)
  list(
    Design = design, AuthorizationAudit = authorization_audit,
    SealedManifest = sealed_manifest, Acceptance = acceptance,
    Boundary = boundary, Runner = runner, Fixture = fixture
  )
}

test_that("b1g13 binds all three calibration ledgers without opening data", {
  env <- load_gtheory_stationarity_exact_resume()
  objects <- gtheory_stationarity_exact_resume_objects(env)
  contract <- objects$Runner
  units <- env$mfrmr_gtwag_sealed_units(
    contract, objects$SealedManifest
  )

  expect_identical(nrow(units), 12000L)
  expect_identical(length(unique(units$DatasetId)), 3000L)
  expect_identical(sum(units$ExpectedCandidateFitRows), 108000L)
  expect_identical(sum(units$ExpectedCandidateDecisionRows), 576000L)
  expect_identical(sum(units$ExpectedReferenceRows), 24000L)
  expect_true(all(table(units$DatasetId) == 4L))
  expect_equal(anyDuplicated(units$AtomicUnitId), 0L)
  expect_true(all(units$Replicate %in% 201:300))
  expect_true(all(units$CalibrationUse))
  expect_true(all(!units$ExecutionAuthorized))
  expect_true(all(nchar(units$AtomicUnitIdentityHash) == 64L))
  expect_identical(
    contract$ExpectedCalibrationCounts,
    c(
      AtomicUnits = 12000L, DatasetMarkers = 3000L,
      CandidateFitRows = 108000L, CandidateDecisionRows = 576000L,
      ReferenceRows = 24000L
    )
  )
})

test_that("b1g13 advances runner mechanics but no reserved authorization", {
  env <- load_gtheory_stationarity_exact_resume()
  objects <- gtheory_stationarity_exact_resume_objects(env)
  contract <- objects$Runner

  expect_identical(
    contract$UpstreamB1g12ContractHash,
    "53a36d72388eb8b4e096ef817aaf94959aa1b3fd3257190cf5c0a8164383d9da"
  )
  expect_identical(
    contract$SealedCalibrationManifestHash,
    "7cce9d42faccfbbdf928c9ec4978fef25c50aa562750141fbab45a53b75885f8"
  )
  expect_identical(
    contract$ReferenceReceiptHash,
    "777e7550a188f89515854738e3b7e42ef418037de4c9f7166a67d61e6dfa2e9e"
  )
  expect_identical(
    contract$ContractHash,
    "8fb599cd4abbabb454ce416fe3470d3e0f8d23f0bc8f2662630083fb1ec388da"
  )
  expect_true(contract$ExactResumeRunnerImplemented)
  expect_true(contract$RunnerImplementationReady)
  expect_true(contract$AtomicCheckpointSchemaReady)
  expect_true(contract$CompleteFailureAccountingRequired)
  expect_true(contract$ProductionBoundaryProbeReady)
  expect_true(contract$AcceptancePolicyFrozen)
  expect_true(contract$ReferenceMethodCoverageComplete)
  expect_false(contract$ProductionEvaluatorAdaptersFrozen)
  expect_false(contract$ReservedRunManifestFrozen)
  expect_false(contract$CalibrationAuthorizationReady)
  expect_false(contract$CalibrationExecutionAuthorized)
  expect_false(contract$CalibrationDataGenerated)
  expect_false(contract$CalibrationResultsViewed)
  expect_false(contract$StationarityThresholdFrozen)
  expect_false(contract$StationarityCriterionReady)
  expect_false(contract$ConfirmationAuthorized)
  expect_false(contract$InferenceReady)
  expect_false(contract$CoefficientEligible)
  expect_false(contract$DecisionReady)
})

test_that("b1g13 nonreserved manifest has exact independent identities", {
  env <- load_gtheory_stationarity_exact_resume()
  fixture <- gtheory_stationarity_exact_resume_objects(env)$Fixture

  expect_true(env$mfrmr_gtwag_manifest_hash_valid(fixture))
  expect_identical(
    fixture$ManifestHash,
    "af13168b59d6f083bade0c66b85ff6befa48b195f1a27434c95e8acc6e18d098"
  )
  expect_identical(fixture$AtomicUnitCount, 8L)
  expect_identical(fixture$DatasetCount, 2L)
  expect_identical(fixture$CandidateFitRowCount, 72L)
  expect_identical(fixture$CandidateDecisionRowCount, 384L)
  expect_identical(fixture$ReferenceRowCount, 16L)
  expect_identical(fixture$Replicates, c(901L, 902L))
  expect_false(fixture$ReservedCalibrationUse)
  expect_false(fixture$ConfirmationUse)
  expect_true(fixture$ExecutionAuthorized)
  expect_false(fixture$CalibrationExecutionAuthorized)
  expect_false(fixture$DataGenerated)
  expect_false(fixture$ResultsViewed)
  expect_true(all(fixture$Units$MechanicsFixture))
  expect_true(all(!fixture$Units$CalibrationUse))
  expect_false(any(fixture$Units$Replicate %in% c(201:300, 501:700)))
})

test_that("b1g13 atomic bundles retain failures and all 24 decisions", {
  env <- load_gtheory_stationarity_exact_resume()
  objects <- gtheory_stationarity_exact_resume_objects(env)
  unit <- objects$Fixture$Units[
    objects$Fixture$Units$Replicate == 902L &
      objects$Fixture$Units$MethodId == "glmmTMB_ml", , drop = FALSE
  ]
  bundle <- env$mfrmr_gtwag_evaluate_unit(
    objects$Runner, objects$Fixture, unit,
    env$mfrmr_gtwag_fixture_candidate_evaluator,
    env$mfrmr_gtwag_fixture_reference_evaluator
  )

  expect_true(env$mfrmr_gtwag_bundle_hash_valid(
    bundle, objects$Runner, objects$Fixture, unit
  ))
  expect_identical(nrow(bundle$CandidateFits), 12L)
  expect_identical(nrow(bundle$CandidateDecisions), 48L)
  expect_identical(nrow(bundle$References), 2L)
  expect_identical(bundle$CandidateFitFailureCount, 1L)
  expect_true(any(!bundle$CandidateFits$FitReturned))
  expect_true(all(bundle$CandidateDecisions$GeneratingTruthUsed == FALSE))
  expect_true(all(
    bundle$CandidateDecisions$MetricUsedToSelectProfile == FALSE
  ))
  expect_setequal(
    unique(bundle$CandidateDecisions$CandidateId),
    objects$Runner$CandidateGrid$CandidateId
  )
  ledger <- env$mfrmr_gtwag_acceptance_ledger(
    bundle$CandidateDecisions, bundle$References
  )
  expect_identical(nrow(ledger), 48L)
  expect_false(any(c(
    "TargetVariance", "TruthRegion", "EvaluationRole", "TrueVariance"
  ) %in% names(ledger)))
})

test_that("b1g13 evaluator errors expand to typed denominator rows", {
  env <- load_gtheory_stationarity_exact_resume()
  objects <- gtheory_stationarity_exact_resume_objects(env)
  unit <- objects$Fixture$Units[1L, , drop = FALSE]
  fail <- function(contract, unit) stop("intentional evaluator failure")
  bundle <- env$mfrmr_gtwag_evaluate_unit(
    objects$Runner, objects$Fixture, unit, fail, fail
  )

  expect_true(env$mfrmr_gtwag_bundle_hash_valid(
    bundle, objects$Runner, objects$Fixture, unit
  ))
  expect_identical(
    nrow(bundle$CandidateFits), unit$ExpectedCandidateFitRows[[1L]]
  )
  expect_true(all(!bundle$CandidateFits$FitReturned))
  expect_true(all(
    bundle$CandidateFits$FailureStage == "candidate_evaluator"
  ))
  expect_identical(
    nrow(bundle$CandidateDecisions),
    unit$ExpectedCandidateDecisionRows[[1L]]
  )
  expect_true(all(bundle$CandidateDecisions$CandidateState == "not_evaluable"))
  expect_identical(nrow(bundle$References), 2L)
  expect_true(all(bundle$References$ReferenceState == "not_evaluable"))
  expect_true(all(
    bundle$References$FailureStage == "reference_evaluator"
  ))
})

test_that("b1g13 checkpoints and dataset markers reject mutation", {
  env <- load_gtheory_stationarity_exact_resume()
  objects <- gtheory_stationarity_exact_resume_objects(env)
  units <- objects$Fixture$Units[
    objects$Fixture$Units$DatasetId ==
      objects$Fixture$Units$DatasetId[[1L]], , drop = FALSE
  ]
  checkpoints <- lapply(seq_len(nrow(units)), function(index) {
    unit <- units[index, , drop = FALSE]
    bundle <- env$mfrmr_gtwag_evaluate_unit(
      objects$Runner, objects$Fixture, unit,
      env$mfrmr_gtwag_fixture_candidate_evaluator,
      env$mfrmr_gtwag_fixture_reference_evaluator
    )
    env$mfrmr_gtwag_checkpoint(
      objects$Runner, objects$Fixture, unit, bundle
    )
  })
  root <- withr::local_tempdir(pattern = "mfrmr-gtwag-checkpoint-")
  path <- env$mfrmr_gtwag_checkpoint_path(root, units$AtomicUnitId[[1L]])
  env$mfrmr_gtwag_atomic_write(checkpoints[[1L]], path)
  restored <- env$mfrmr_gtwag_safe_read(path)

  expect_true(env$mfrmr_gtwag_validate_checkpoint(
    restored, objects$Runner, objects$Fixture, units[1L, , drop = FALSE]
  ))
  tampered <- restored
  tampered$Identity$Bundle$CandidateFits$FitReturned[[1L]] <- FALSE
  expect_false(env$mfrmr_gtwag_validate_checkpoint(
    tampered, objects$Runner, objects$Fixture, units[1L, , drop = FALSE]
  ))
  marker <- env$mfrmr_gtwag_dataset_marker(
    objects$Runner, objects$Fixture, units$DatasetId[[1L]], checkpoints
  )
  expect_true(env$mfrmr_gtwag_validate_marker(
    marker, objects$Runner, objects$Fixture,
    units$DatasetId[[1L]], checkpoints
  ))
  changed <- checkpoints
  changed[[1L]]$CheckpointHash <- paste0("x", changed[[1L]]$CheckpointHash)
  expect_false(env$mfrmr_gtwag_validate_marker(
    marker, objects$Runner, objects$Fixture,
    units$DatasetId[[1L]], changed
  ))
  expect_error(env$mfrmr_gtwag_checkpoint_root("/"), "cannot be")
})

test_that("b1g13 partial resume equals cold and full reuse executions", {
  env <- load_gtheory_stationarity_exact_resume()
  objects <- gtheory_stationarity_exact_resume_objects(env)
  resume_root <- withr::local_tempdir(pattern = "mfrmr-gtwag-resume-")
  cold_root <- withr::local_tempdir(pattern = "mfrmr-gtwag-cold-")

  partial <- env$mfrmr_gtwag_execute(
    objects$Runner, objects$Fixture, resume_root,
    interrupt_after_new_units = 3L
  )
  expect_s3_class(partial, "mfrmr_gtwag_progress")
  expect_false(partial$Complete)
  expect_identical(partial$ValidCheckpointCount, 3L)
  expect_identical(partial$ComputedUnitCount, 3L)
  expect_identical(partial$ReusedUnitCount, 0L)
  expect_identical(
    partial$CompletionClaim, "partial_checkpoint_set_not_evidence"
  )
  expect_false(partial$CalibrationEvidenceReady)

  resumed <- env$mfrmr_gtwag_execute(
    objects$Runner, objects$Fixture, resume_root
  )
  cold <- env$mfrmr_gtwag_execute(
    objects$Runner, objects$Fixture, cold_root
  )
  reused <- env$mfrmr_gtwag_execute(
    objects$Runner, objects$Fixture, resume_root
  )

  expect_s3_class(resumed, "mfrmr_gtwag_execution")
  expect_true(resumed$Complete)
  expect_true(resumed$ExactAccountingPassed)
  expect_identical(resumed$ReusedUnitCount, 3L)
  expect_identical(resumed$ComputedUnitCount, 5L)
  expect_identical(cold$ReusedUnitCount, 0L)
  expect_identical(cold$ComputedUnitCount, 8L)
  expect_identical(reused$ReusedUnitCount, 8L)
  expect_identical(reused$ComputedUnitCount, 0L)
  expect_identical(resumed$ExecutionHash, cold$ExecutionHash)
  expect_identical(resumed$ExecutionHash, reused$ExecutionHash)
  expect_identical(
    resumed$ExecutionHash,
    "4cdbb0ed2ba69588f81e3fcbd3df634b92a4b7e1929bac387cd6a8562a18100f"
  )
  expect_identical(resumed$CandidateFits, cold$CandidateFits)
  expect_identical(resumed$CandidateDecisions, cold$CandidateDecisions)
  expect_identical(resumed$References, cold$References)
  expect_identical(nrow(resumed$CandidateFits), 72L)
  expect_identical(nrow(resumed$CandidateDecisions), 384L)
  expect_identical(nrow(resumed$References), 16L)
  expect_identical(nrow(resumed$AcceptanceLedger), 384L)
  expect_identical(nrow(resumed$AcceptanceCellSummary), 192L)
  expect_identical(resumed$CandidateFitFailureCount, 4L)
  expect_identical(resumed$ReferenceUnresolvedCount, 4L)
  expect_false(resumed$CalibrationEvidenceReady)
  expect_false(resumed$CalibrationExecutionAuthorized)
  expect_false(resumed$StationarityThresholdFrozen)
  expect_false(resumed$ConfirmationAuthorized)
  expect_false(resumed$InferenceReady)
  expect_false(resumed$DecisionReady)

  first_unit <- objects$Fixture$Units[1L, , drop = FALSE]
  path <- env$mfrmr_gtwag_checkpoint_path(
    resume_root, first_unit$AtomicUnitId[[1L]]
  )
  damaged <- readRDS(path)
  damaged$Identity$Bundle$CandidateFits$FitReturned[[1L]] <- FALSE
  saveRDS(damaged, path, version = 3L)
  repaired <- env$mfrmr_gtwag_execute(
    objects$Runner, objects$Fixture, resume_root
  )
  expect_identical(repaired$ComputedUnitCount, 1L)
  expect_identical(repaired$ReusedUnitCount, 7L)
  expect_identical(repaired$ExecutionHash, cold$ExecutionHash)
})

test_that("b1g13 rejects stale manifests and evaluator identities", {
  env <- load_gtheory_stationarity_exact_resume()
  objects <- gtheory_stationarity_exact_resume_objects(env)
  root <- withr::local_tempdir(pattern = "mfrmr-gtwag-reject-")
  changed <- objects$Fixture
  changed$Units$ExpectedReferenceRows[[1L]] <- 3L

  expect_false(env$mfrmr_gtwag_manifest_hash_valid(changed))
  expect_error(
    env$mfrmr_gtwag_execute(objects$Runner, changed, root),
    "exact nonreserved"
  )
  different_evaluator <- function(contract, unit) {
    env$mfrmr_gtwag_fixture_candidate_evaluator(contract, unit)
  }
  expect_error(
    env$mfrmr_gtwag_execute(
      objects$Runner, objects$Fixture, root,
      candidate_evaluator = different_evaluator
    ),
    "exact nonreserved"
  )
  reserved <- objects$Fixture
  reserved$Replicates <- 201L
  fields <- c(
    "Contract", "RunnerContractHash", "ExecutionMode", "Units",
    "CandidateEvaluatorHash", "ReferenceEvaluatorHash", "Replicates",
    "ReservedCalibrationUse", "ConfirmationUse"
  )
  reserved$ManifestHash <- env$mfrmr_gta_hash(reserved[fields])
  expect_true(env$mfrmr_gtwag_manifest_hash_valid(reserved))
  expect_error(
    env$mfrmr_gtwag_execute(objects$Runner, reserved, root),
    "exact nonreserved"
  )
})

test_that("b1g13 function and policy identities reproduce", {
  env <- load_gtheory_stationarity_exact_resume()
  objects <- gtheory_stationarity_exact_resume_objects(env)
  hashes <- env$mfrmr_gtwag_function_hashes()
  policy <- env$mfrmr_gtwag_policy()

  expect_identical(length(hashes), 30L)
  expect_equal(anyDuplicated(names(hashes)), 0L)
  expect_true(all(nchar(hashes) == 64L))
  expect_identical(objects$Runner$FunctionHashes, hashes)
  expect_true(env$mfrmr_gtwag_policy_hash_valid(policy))
  expect_identical(
    policy$PolicyHash,
    "c346aebac1a13770e755402b6a0b7f0e1338d8f9f8b238103b7291e01e250f38"
  )
  changed <- policy
  changed$FixtureAtomicUnits <- 9L
  expect_false(env$mfrmr_gtwag_policy_hash_valid(changed))
  expect_true(any(grepl("readRDS", objects$Runner$Sources$Locator)))
  expect_true(any(grepl("Morris", objects$Runner$Sources$ContractRole,
                        ignore.case = TRUE)) == FALSE)
})
