gtheory_preactivation_hardening_paths <- function() {
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
    "gtheory-weak-information-monte-carlo-value-audit-0.2.3.R",
    "gtheory-weak-information-preactivation-hardening-audit-0.2.3.R"
  ))
}

load_gtheory_preactivation_hardening <- function() {
  paths <- gtheory_preactivation_hardening_paths()
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

gtheory_preactivation_hardening_objects <- function(env) {
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
  preflight <- env$mfrmr_gtwai_contract(adapter, reserved)
  shards <- env$mfrmr_gtwai_shard_bundle(preflight, reserved, sealed)
  value_contract <- env$mfrmr_gtwaj_contract(
    preflight, env$mfrmr_gtwae_policy()
  )
  value_audit <- env$mfrmr_gtwaj_audit(value_contract)
  contract <- env$mfrmr_gtwak_contract(
    preflight, shards, value_contract, value_audit
  )
  audit <- env$mfrmr_gtwak_audit(contract)
  list(
    Plan = plan, Sealed = sealed, Adapter = adapter, Reserved = reserved,
    Preflight = preflight, Shards = shards, ValueContract = value_contract,
    ValueAudit = value_audit, Contract = contract, Audit = audit
  )
}

gtheory_preactivation_hardening_cache <- new.env(parent = emptyenv())

gtheory_preactivation_hardening_cached <- function() {
  if (!is.null(gtheory_preactivation_hardening_cache$result)) {
    return(gtheory_preactivation_hardening_cache$result)
  }
  env <- load_gtheory_preactivation_hardening()
  objects <- gtheory_preactivation_hardening_objects(env)
  result <- list(Env = env, Objects = objects)
  gtheory_preactivation_hardening_cache$result <- result
  result
}

test_that("b1g16 freezes a stronger but non-authorizing hardening contract", {
  cached <- gtheory_preactivation_hardening_cached()
  env <- cached$Env
  contract <- cached$Objects$Contract

  expect_s3_class(contract, "mfrmr_gtwak_contract")
  expect_true(env$mfrmr_gtwak_contract_hash_valid(contract))
  expect_true(env$mfrmr_gtwak_policy_hash_valid(contract$Policy))
  expect_true(env$mfrmr_gtwak_runtime_hash_valid(
    contract$ObservedExtendedRuntime
  ))
  expect_identical(
    contract$Policy$PolicyHash,
    "dc3fb20ef72d64842b1fed7273ebcaa6b2bd794b8757f59ccea03a4d3e945c3c"
  )
  expect_identical(
    env$mfrmr_gta_hash(env$mfrmr_gtwak_function_hashes()),
    "8e86f19edc198d4a75244ad58b97708158b731c271ca3133b618d97e59d2ba4d"
  )
  expect_identical(
    contract$ContractHash,
    "9ea428bfec87509cacdadba6250d837aef5090c07550f2c0603b79164f2c58c0"
  )
  expect_identical(length(env$mfrmr_gtwak_function_hashes()), 16L)
  expect_true(contract$PreactivationHardeningContractFrozen)
  expect_true(contract$PriorB1g15ReadinessPreservedAsHistoricalEvidence)
  expect_true(contract$StrongerActivationRequirementsAdded)
  expect_false(contract$ExtendedRuntimeIdentityBoundUpstream)
  expect_setequal(contract$MissingUpstreamRuntimeFields, c(
    "RNGKind", "MatrixProducts", "BLAS", "LAPACK", "LAVersion",
    "Locale", "TimeZone", "GLMMTMBParallel", "ThreadEnvironment"
  ))
  expect_identical(contract$ShardCounts, c(
    Shards = 100L, Datasets = 3000L, AtomicUnits = 12000L,
    CandidateFits = 108000L, CandidateDecisions = 576000L,
    References = 24000L
  ))
  expect_true(contract$UpstreamCompleteFailureAccountingRequired)
  expect_true(contract$UpstreamFailedFitRowsRetained)
  expect_true(contract$UpstreamFailedReferenceRowsRetained)
  expect_false(contract$ExecutionAuthorizationRecordIssued)
  expect_false(contract$CalibrationAuthorizationReady)
  expect_false(contract$CalibrationExecutionAuthorized)
  expect_false(contract$CalibrationDataGenerated)
  expect_false(contract$CalibrationResultsViewed)
  expect_false(contract$ConfirmationAuthorized)
  expect_false(contract$InferenceReady)
  expect_false(contract$DecisionReady)
})

test_that("b1g16 proves exact collision-free phase seed accounting", {
  cached <- gtheory_preactivation_hardening_cached()
  env <- cached$Env
  ledger <- env$mfrmr_gtwak_seed_ledger()
  audit <- env$mfrmr_gtwak_seed_audit(ledger)

  expect_true(env$mfrmr_gtwak_seed_ledger_hash_valid(ledger))
  expect_true(env$mfrmr_gtwak_seed_audit_hash_valid(audit))
  expect_identical(
    ledger$LedgerHash,
    "59bda7a07bb137f9108a3541775fe3c4c09d6ac94439dff6091b154fa0e41731"
  )
  expect_identical(
    audit$AuditHash,
    "34d69696fb17e6f3af9213113a7f629ab69ff16d2826f6412db01716009cd027"
  )
  expect_identical(ledger$DatasetCount, 9756L)
  expect_identical(ledger$UniqueSeedCount, 9756L)
  expect_identical(ledger$CalibrationDatasetCount, 3000L)
  expect_identical(ledger$ConfirmationDatasetCount, 6000L)
  expect_identical(audit$PhaseDatasetCounts, c(
    schema_smoke = 6L, feasibility_pilot = 750L,
    calibration_pilot = 3000L, confirmation = 6000L
  ))
  expect_identical(audit$MinimumSeed, 833201L)
  expect_identical(audit$MaximumSeed, 862899L)
  expect_true(audit$SeedLedgerExact)
  expect_true(audit$SeedCollisionFree)
  expect_true(audit$PhaseBandsDisjoint)
  expect_false(audit$CalibrationExecutionAuthorized)
  expect_false(audit$ConfirmationExecutionAuthorized)
  expect_false(audit$ResponsesGenerated)

  changed <- ledger
  changed$Rows$Seed[[2L]] <- changed$Rows$Seed[[1L]]
  expect_false(env$mfrmr_gtwak_seed_ledger_hash_valid(changed))
})

test_that("b1g16 nonreserved negative control exposes ambient RNG dependence", {
  cached <- gtheory_preactivation_hardening_cached()
  env <- cached$Env
  old_kind <- RNGkind()
  set.seed(41603L)
  old_seed <- .Random.seed
  probe <- env$mfrmr_gtwak_rng_probe()

  expect_true(env$mfrmr_gtwak_rng_probe_hash_valid(probe))
  expect_identical(
    probe$ProbeHash,
    "b95dbfdddca4515ec70dcfb23680039de565e744c2b6e4fbc6468a95c62bc7f0"
  )
  expect_identical(probe$Replicate, 901L)
  expect_false(probe$Replicate %in% c(201:300, 501:700))
  expect_true(probe$AmbientRNGAffectsGeneration)
  expect_false(probe$DataHashEqualAcrossAmbientRNGKinds)
  expect_false(probe$GeneratorCallsSetSeedWithExplicitKinds)
  expect_false(probe$GeneratorIdentityRecordsRNGKind)
  expect_false(probe$GeneratorRNGSelfContained)
  expect_false(probe$ReservedResponseOpened)
  expect_false(probe$CalibrationResponsesUsed)
  expect_false(probe$ConfirmationResponsesUsed)
  expect_identical(RNGkind(), old_kind)
  expect_identical(.Random.seed, old_seed)

  unsafe <- env$mfrmr_gtwak_policy()
  unsafe$NonreservedRNGProbeReplicate <- 201L
  identity <- unclass(unsafe)
  identity$PolicyHash <- NULL
  identity$PolicyFrozen <- NULL
  unsafe$PolicyHash <- env$mfrmr_gta_hash(identity)
  expect_error(
    env$mfrmr_gtwak_rng_probe(unsafe),
    "outside every reserved band"
  )
})

test_that("b1g16 records runtime and execution-path blockers explicitly", {
  cached <- gtheory_preactivation_hardening_cached()
  env <- cached$Env
  contract <- cached$Objects$Contract
  audit <- cached$Objects$Audit
  gates <- audit$GateRegistry

  expect_true(env$mfrmr_gtwak_audit_hash_valid(audit))
  expect_identical(
    audit$DecisionHash,
    "e4e32bc3fc93c4469ce88ccf46e91866b6a22ef3e81d71a9a3dc483d767f1799"
  )
  expect_identical(nrow(gates), 12L)
  expect_setequal(gates$GateId[gates$ObservedPass], c(
    "SEED-01", "SHARD-01", "DENOMINATOR-01", "CONFIRM-01"
  ))
  expect_identical(audit$BlockerIds, c(
    "RNG-01", "RUNTIME-01", "THREAD-01", "PROCESS-01", "RUNNER-01",
    "LOCK-01", "ROOT-01", "CAPACITY-01"
  ))
  expect_identical(audit$BlockerCount, 8L)
  expect_true(audit$PreactivationHardeningAuditReady)
  expect_true(audit$SeedLedgerExact)
  expect_true(audit$SeedCollisionFree)
  expect_true(audit$AmbientRNGAffectsGeneration)
  expect_false(audit$GeneratorRNGSelfContained)
  expect_false(audit$ExtendedRuntimeIdentityBoundUpstream)
  expect_true(audit$CurrentGLMMTMBSerialObserved)
  expect_false(audit$CurrentThreadEnvironmentExplicitlySerial)
  expect_true(audit$PriorB1g15ActivationEligibilitySuperseded)
  expect_false(audit$AuthorizationActivationEligible)
  expect_false(audit$LargeSimulationMayStart)
  expect_false(audit$Replicate201MayBeOpened)
  expect_false(audit$ExecutionAuthorizationRecordIssued)
  expect_false(audit$CalibrationExecutionAuthorized)
  expect_false(audit$CalibrationDataGenerated)
  expect_false(audit$CalibrationResultsViewed)
  expect_false(audit$ConfirmationAuthorized)
  expect_false(audit$InferenceReady)
  expect_false(audit$DecisionReady)

  changed <- audit
  changed$GateRegistry$ObservedPass[
    changed$GateRegistry$GateId == "LOCK-01"
  ] <- TRUE
  expect_false(env$mfrmr_gtwak_audit_hash_valid(changed))

  changed_contract <- contract
  changed_contract$MissingUpstreamRuntimeFields <- character()
  expect_false(env$mfrmr_gtwak_contract_hash_valid(changed_contract))
})

test_that("b1g16 does not create or inspect the reserved output target", {
  cached <- gtheory_preactivation_hardening_cached()
  audit <- cached$Objects$Audit
  package_root <- normalizePath(
    testthat::test_path("..", ".."), winslash = "/", mustWork = TRUE
  )
  target <- file.path(package_root, cached$Objects$Reserved$OutputRoot)
  parent <- dirname(target)
  residue <- list.files(
    parent, pattern = "^\\.mfrmr-gtwak-", all.files = TRUE,
    full.names = TRUE
  )

  expect_false(file.exists(target))
  expect_false(dir.exists(target))
  expect_length(residue, 0L)
  expect_false(audit$LargeSimulationMayStart)
  expect_false(audit$Replicate201MayBeOpened)
  expect_false(audit$CalibrationResponsesUsed)
  expect_false(audit$ConfirmationResponsesUsed)
})
