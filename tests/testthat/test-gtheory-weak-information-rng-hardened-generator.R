gtheory_rng_hardened_paths <- function() {
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
    "gtheory-weak-information-preactivation-hardening-audit-0.2.3.R",
    "gtheory-weak-information-rng-hardened-generator-0.2.3.R"
  ))
}

load_gtheory_rng_hardened <- function() {
  paths <- gtheory_rng_hardened_paths()
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

gtheory_rng_hardened_parent <- function(env) {
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
  list(Contract = contract, Audit = env$mfrmr_gtwak_audit(contract))
}

gtheory_rng_hardened_cache <- new.env(parent = emptyenv())

gtheory_rng_hardened_cached <- function() {
  if (!is.null(gtheory_rng_hardened_cache$result)) {
    return(gtheory_rng_hardened_cache$result)
  }
  env <- load_gtheory_rng_hardened()
  parent <- gtheory_rng_hardened_parent(env)
  policy <- env$mfrmr_gtwal_policy()
  manifest <- env$mfrmr_gtwal_replay_manifest(policy = policy)
  replay <- env$mfrmr_gtwal_replay(manifest, policy = policy)
  contract <- env$mfrmr_gtwal_contract(parent$Contract, parent$Audit)
  audit <- env$mfrmr_gtwal_audit(contract, manifest, replay)
  result <- list(
    Env = env, Parent = parent, Policy = policy, Manifest = manifest,
    Replay = replay, Contract = contract, Audit = audit
  )
  gtheory_rng_hardened_cache$result <- result
  result
}

test_that("b1g17 freezes a non-authorizing hardened generator contract", {
  cached <- gtheory_rng_hardened_cached()
  env <- cached$Env
  policy <- cached$Policy
  contract <- cached$Contract

  expect_true(env$mfrmr_gtwal_policy_hash_valid(policy))
  expect_true(env$mfrmr_gtwal_contract_hash_valid(contract))
  expect_identical(length(env$mfrmr_gtwal_function_hashes()), 17L)
  expect_identical(
    policy$PolicyHash,
    "9d54aeee4e7cf9bc3b20e8e96fa99dfa79febf070cc0d732377287ce897e20a9"
  )
  expect_identical(
    env$mfrmr_gta_hash(env$mfrmr_gtwal_function_hashes()),
    "8d7a998844dbb482b605915382ab0b3409f6d2caff0a4f37559a74f1fa5aa2c9"
  )
  expect_identical(
    contract$HardenedGeneratorFunctionHash,
    "428c98d225abc51e13b8e07e625d242d3a94c1e2a2d54e34f98b429b00785612"
  )
  expect_identical(
    contract$ContractHash,
    "90869c6874e2884b7bf5bc96c1939bd95d1b41603ea76a1d2b1c617f32c700d2"
  )
  expect_identical(
    contract$HistoricalGeneratorFunctionHash,
    cached$Parent$Contract$GeneratorFunctionHash
  )
  expect_true(contract$HistoricalGeneratorPreserved)
  expect_true(contract$HardenedGeneratorContractFrozen)
  expect_false(contract$ReservedAccessEnabled)
  expect_false(contract$DownstreamAdaptersRebased)
  expect_false(contract$ExecutionAuthorizationRecordIssued)
  expect_false(contract$CalibrationExecutionAuthorized)
  expect_false(contract$ConfirmationAuthorized)
  expect_false(contract$InferenceReady)
  expect_false(contract$DecisionReady)

  forged_contract <- contract
  forged_contract$ParentBlockerIds <- "RNG-01"
  contract_fields <- c(
    "Contract", "ParentHardeningContractHash", "ParentHardeningDecisionHash",
    "ParentBlockerIds", "HistoricalGeneratorFunctionHash",
    "HardenedGeneratorFunctionHash", "Policy", "Sources", "FunctionHashes"
  )
  forged_contract$ContractHash <- env$mfrmr_gta_hash(
    forged_contract[contract_fields]
  )
  expect_false(env$mfrmr_gtwal_contract_hash_valid(forged_contract))
})

test_that("b1g17 replays all 30 scenarios independently of ambient RNG", {
  cached <- gtheory_rng_hardened_cached()
  env <- cached$Env
  manifest <- cached$Manifest
  replay <- cached$Replay

  expect_true(env$mfrmr_gtwal_manifest_hash_valid(manifest))
  expect_true(env$mfrmr_gtwal_replay_hash_valid(replay))
  expect_identical(
    manifest$ManifestHash,
    "d3fe95bc5eae79dbc76e622fb2767eb3b0d14a378c767eaaf15872685ca351f7"
  )
  expect_identical(
    replay$ReplayHash,
    "39054c3ef7b78783065134ee38303d73d3c6601edfddc8e68cebb8990949f955"
  )
  expect_identical(manifest$ScenarioCount, 30L)
  expect_identical(replay$ScenarioCount, 30L)
  expect_true(all(replay$Rows$RequiredGenerationHashValid))
  expect_true(all(replay$Rows$AlternateGenerationHashValid))
  expect_true(all(replay$Rows$RequiredCallerStateRestored))
  expect_true(all(replay$Rows$AlternateCallerStateRestored))
  expect_true(all(replay$Rows$GeneratorHashEqualAcrossAmbientKinds))
  expect_true(all(replay$Rows$AnalysisDataHashEqualAcrossAmbientKinds))
  expect_true(all(
    replay$Rows$HistoricalHashEqualAcrossWrappedAmbientKinds
  ))
  expect_false(replay$ReservedResponseOpened)
  expect_false(replay$CalibrationResponsesUsed)
  expect_false(replay$ConfirmationResponsesUsed)
})

test_that("b1g17 restores caller state and rejects reserved access", {
  cached <- gtheory_rng_hardened_cached()
  env <- cached$Env
  policy <- cached$Policy
  registry <- env$mfrmr_gtw_registry()
  scenario <- registry$Cells$ScenarioId[[1L]]

  old_kind <- RNGkind()
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (had_seed) get(".Random.seed", envir = .GlobalEnv) else NULL
  on.exit({
    do.call(RNGkind, as.list(old_kind))
    if (had_seed) assign(".Random.seed", old_seed, envir = .GlobalEnv) else
      if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE))
        rm(".Random.seed", envir = .GlobalEnv)
  }, add = TRUE)

  do.call(RNGkind, as.list(policy$AlternateAmbientRNGKind))
  set.seed(170017L)
  before_kind <- unname(RNGkind())
  before_seed <- get(".Random.seed", envir = .GlobalEnv)
  generation <- env$mfrmr_gtwal_generate(
    registry, scenario, policy$NonreservedReplayReplicate, policy
  )
  expect_true(env$mfrmr_gtwal_generation_hash_valid(generation))
  expect_identical(unname(RNGkind()), before_kind)
  expect_identical(get(".Random.seed", envir = .GlobalEnv), before_seed)

  expect_error(
    env$mfrmr_gtwal_generate(
      registry, scenario, policy$ReservedCalibrationReplicates[[1L]], policy
    ),
    "cannot open reserved calibration or confirmation"
  )
  expect_identical(unname(RNGkind()), before_kind)
  expect_identical(get(".Random.seed", envir = .GlobalEnv), before_seed)

  mutated <- generation
  mutated$GeneratorIdentity$RequiredRNGKind[[1L]] <- "Wichmann-Hill"
  mutated$GeneratorHash <- env$mfrmr_gta_hash(mutated$GeneratorIdentity)
  expect_false(env$mfrmr_gtwal_generation_hash_valid(mutated))

  forged_policy <- policy
  forged_policy$RequiredRNGKind[[1L]] <- "Wichmann-Hill"
  forged_identity <- unclass(forged_policy)
  forged_identity$PolicyHash <- NULL
  forged_identity$PolicyFrozen <- NULL
  forged_policy$PolicyHash <- env$mfrmr_gta_hash(forged_identity)
  expect_false(env$mfrmr_gtwal_policy_hash_valid(forged_policy))

  rm(".Random.seed", envir = .GlobalEnv)
  no_seed_kind <- unname(RNGkind())
  no_seed_generation <- env$mfrmr_gtwal_generate(
    registry, scenario, policy$NonreservedReplayReplicate, policy
  )
  expect_true(env$mfrmr_gtwal_generation_hash_valid(no_seed_generation))
  expect_identical(unname(RNGkind()), no_seed_kind)
  expect_false(exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE))
})

test_that("b1g17 closes only the prospective generator subgate", {
  cached <- gtheory_rng_hardened_cached()
  env <- cached$Env
  audit <- cached$Audit

  expect_true(env$mfrmr_gtwal_audit_hash_valid(audit))
  expect_identical(
    audit$AuditHash,
    "918e7da5e0ba484bbdef4251965c25ff31c5d4a39be237c3d218ed47fceae397"
  )
  expect_identical(audit$ScenarioCount, 30L)
  expect_identical(nrow(audit$ComponentGates), 6L)
  expect_true(all(audit$ComponentGates$ObservedPass[1:5]))
  expect_identical(audit$ComponentBlockerIds, "RNG-ADAPTER-01")
  expect_true(audit$HardenedGeneratorAuditReady)
  expect_true(audit$HardenedGeneratorReady)
  expect_true(audit$RNG01ProspectivelyResolved)
  expect_false(audit$AuthorizationRNG01Closed)
  expect_false(audit$DownstreamAdaptersRebased)
  expect_setequal(audit$ParentAuthorizationBlockerIds, c(
    "RNG-01", "RUNTIME-01", "THREAD-01", "PROCESS-01", "RUNNER-01",
    "LOCK-01", "ROOT-01", "CAPACITY-01"
  ))
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
})
