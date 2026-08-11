gtheory_hardened_lineage_paths <- function() {
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
    "gtheory-weak-information-rng-hardened-generator-0.2.3.R",
    "gtheory-weak-information-hardened-adapter-rebase-0.2.3.R",
    "gtheory-weak-information-hardened-reserved-lineage-0.2.3.R"
  ))
}

load_gtheory_hardened_lineage <- function() {
  paths <- gtheory_hardened_lineage_paths()
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

gtheory_hardened_lineage_objects <- function(env) {
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
  historical_adapter <- env$mfrmr_gtwah_contract(
    runner, boundary, glmm_reference, lme4_reference
  )
  historical_manifest <- env$mfrmr_gtwah_reserved_manifest(
    historical_adapter, sealed
  )
  receipt <- env$mfrmr_gtwan_parent_receipt()
  contract <- env$mfrmr_gtwan_contract(
    historical_adapter, historical_manifest, sealed, receipt
  )
  manifest <- env$mfrmr_gtwan_reserved_manifest(
    contract, historical_manifest, sealed
  )
  bundle <- env$mfrmr_gtwan_shard_bundle(contract, manifest, sealed)
  audit <- env$mfrmr_gtwan_audit(
    contract, historical_manifest, manifest, bundle
  )
  list(
    Sealed = sealed, HistoricalAdapter = historical_adapter,
    HistoricalManifest = historical_manifest, Receipt = receipt,
    Contract = contract, Manifest = manifest, Bundle = bundle, Audit = audit
  )
}

gtheory_hardened_lineage_cache <- new.env(parent = emptyenv())

gtheory_hardened_lineage_result <- function() {
  if (!is.null(gtheory_hardened_lineage_cache$result)) {
    return(gtheory_hardened_lineage_cache$result)
  }
  env <- load_gtheory_hardened_lineage()
  result <- list(Env = env, Objects = gtheory_hardened_lineage_objects(env))
  gtheory_hardened_lineage_cache$result <- result
  result
}

test_that("b1g19 freezes a response-free hardened lineage contract", {
  result <- gtheory_hardened_lineage_result()
  env <- result$Env
  objects <- result$Objects

  expect_true(env$mfrmr_gtwan_parent_receipt_hash_valid(objects$Receipt))
  expect_true(env$mfrmr_gtwan_policy_hash_valid(
    objects$Contract$LineagePolicy
  ))
  expect_true(env$mfrmr_gtwan_contract_hash_valid(objects$Contract))
  expect_true(env$mfrmr_gtwan_reserved_manifest_hash_valid(objects$Manifest))
  expect_true(env$mfrmr_gtwan_shard_bundle_hash_valid(objects$Bundle))
  expect_true(env$mfrmr_gtwan_audit_hash_valid(objects$Audit))
  expect_identical(
    objects$Receipt$ReceiptHash,
    "3e7911686df046bc5fe507ab276194e463952c45b04230facbadb42120500313"
  )
  expect_identical(
    objects$Contract$LineagePolicy$PolicyHash,
    "6a68e71aa5cb30c7f1460b8c81ba76e135ed42dcf2d341a8f966d2e1783ea905"
  )
  expect_identical(
    objects$Contract$ContractHash,
    "5075f23a5af8edb7d77ff3cd4c4efaad4d7a624995c3ee04a62ed04a2bee49f5"
  )
  expect_identical(
    objects$Manifest$ManifestHash,
    "da3905e9b9a605f42e877f695226a0c5ee7089cc04f68ad7ee6350de25c9cbd6"
  )
  expect_identical(
    objects$Bundle$BundleHash,
    "634159d6d85ea04ecf9447330af122c01284644211aa2dd78d85ab34a92661df"
  )
  expect_identical(
    objects$Audit$AuditHash,
    "9bc4d4dafbeec602f7718c7249bf15f4aeb5a6dbd5862b46e4d8889dc2540d7a"
  )
  expect_identical(
    objects$HistoricalManifest$ManifestHash,
    "019fedf063ce90c3492f9eb37f6dbec43a42474ce9096e7cc2891491d7a158c8"
  )
  expect_identical(
    objects$Contract$HardenedAdapterContractHash,
    "0373db563cd16c63693b02b968dbbd49221a77e1f666b87cc63b17cb6f786e64"
  )
  expect_identical(
    objects$Contract$HardenedGeneratorContractHash,
    "90869c6874e2884b7bf5bc96c1939bd95d1b41603ea76a1d2b1c617f32c700d2"
  )
  expect_false(objects$Contract$ReservedAdapterEntryPointReady)
  expect_false(objects$Contract$RuntimeContractExtensionReady)
  expect_false(objects$Contract$AuthorizedSingleShardRunnerReady)
  expect_false(objects$Contract$AuthorizationRNG01Closed)
})

test_that("b1g19 preserves workload partitions but rebases every identity", {
  result <- gtheory_hardened_lineage_result()
  objects <- result$Objects
  old <- objects$HistoricalManifest
  new <- objects$Manifest
  audit <- objects$Audit

  expect_identical(new$DatasetCount, 3000L)
  expect_identical(new$AtomicUnitCount, 12000L)
  expect_identical(new$CandidateFitRowCount, 108000L)
  expect_identical(new$CandidateDecisionRowCount, 576000L)
  expect_identical(new$ReferenceRowCount, 24000L)
  expect_identical(new$ShardCount, 100L)
  expect_identical(audit$HistoricalCounts, audit$HardenedCounts)
  expect_true(audit$CountParity)
  expect_true(audit$UnitPartitionParity)
  expect_true(audit$ShardPartitionParity)
  expect_identical(audit$RebasedAtomicUnitIdentityCount, 12000L)
  expect_identical(audit$RebasedShardIdentityCount, 100L)
  expect_true(audit$AllAtomicUnitIdentitiesRebased)
  expect_true(audit$AllShardIdentitiesRebased)
  expect_length(audit$ActiveHistoricalIdentityOverlap, 0L)
  expect_true(audit$ActiveIdentityExclusionPassed)
  expect_identical(
    new$UnitAssignments$HistoricalAtomicUnitIdentityHash,
    old$UnitAssignments$AtomicUnitIdentityHash
  )
  expect_identical(
    new$Shards$HistoricalShardIdentityHash,
    old$Shards$ShardIdentityHash
  )
})

test_that("b1g19 freezes exactly 100 inert reserved shard manifests", {
  result <- gtheory_hardened_lineage_result()
  objects <- result$Objects
  bundle <- objects$Bundle
  audit <- objects$Audit

  expect_identical(bundle$Registry$ShardId, sprintf("R%04d", 201:300))
  expect_true(all(bundle$Registry$DatasetCount == 30L))
  expect_true(all(bundle$Registry$AtomicUnitCount == 120L))
  expect_true(all(bundle$Registry$CandidateFitRowCount == 1080L))
  expect_true(all(bundle$Registry$CandidateDecisionRowCount == 5760L))
  expect_true(all(bundle$Registry$ReferenceRowCount == 240L))
  expect_false(any(bundle$Registry$ExecutionAuthorized))
  expect_true(all(vapply(bundle$Manifests, function(manifest) {
    !manifest$ResponseGenerationPermitted &&
      !manifest$ModelFittingPermitted &&
      !manifest$CalibrationExecutionAuthorized &&
      !manifest$CalibrationDataGenerated &&
      !manifest$CalibrationResultsViewed &&
      !manifest$ConfirmationUse
  }, logical(1L))))
  expect_true(audit$ConfirmationReplicatesAbsent)
  expect_true(audit$ResponseFreeConstruction)
  expect_true(audit$OutputTargetAbsent)
  expect_true(audit$HardenedReservedLineageAuditReady)
  expect_true(audit$ReservedManifestRebaseReady)
  expect_true(audit$ProspectiveShardManifestsFrozen)
  expect_false(audit$ReservedAdapterEntryPointReady)
  expect_false(audit$RuntimeContractExtensionReady)
  expect_false(audit$AuthorizedSingleShardRunnerReady)
  expect_false(audit$AuthorizationRNG01Closed)
  expect_false(audit$AuthorizationActivationEligible)
  expect_false(audit$LargeSimulationMayStart)
  expect_false(audit$Replicate201MayBeOpened)
  expect_false(audit$CalibrationExecutionAuthorized)
  expect_false(audit$CalibrationDataGenerated)
  expect_false(audit$CalibrationResultsViewed)
  expect_false(audit$ConfirmationAuthorized)
  expect_false(audit$InferenceReady)
  expect_false(audit$DecisionReady)
})

test_that("b1g19 rejects lineage, response, and confirmation mutations", {
  result <- gtheory_hardened_lineage_result()
  env <- result$Env
  objects <- result$Objects

  bad_contract <- objects$Contract
  bad_contract$HardenedGeneratorContractHash <- paste0(
    "x", substring(bad_contract$HardenedGeneratorContractHash, 2L)
  )
  expect_false(env$mfrmr_gtwan_contract_hash_valid(bad_contract))

  bad_manifest <- objects$Manifest
  bad_manifest$UnitAssignments$AtomicUnitIdentityHash[[1L]] <- paste0(
    "x", substring(
      bad_manifest$UnitAssignments$AtomicUnitIdentityHash[[1L]], 2L
    )
  )
  manifest_fields <- c(
    "Contract", "HardenedLineageContractHash",
    "ParentEvidenceReceiptHash", "HistoricalReservedManifestHash",
    "UpstreamSealedManifestHash", "OutputRoot", "InheritedRuntimeHash",
    "ActiveIdentityRegistry", "HistoricalProvenanceRegistry",
    "UnitAssignments", "Shards", "ScientificHashExclusions",
    "ResponseGenerationPermitted", "ModelFittingPermitted",
    "OutputRootCreationPermitted", "EarlyStoppingPermitted",
    "CalibrationExecutionAuthorized", "ConfirmationUse"
  )
  bad_manifest$ManifestHash <- env$mfrmr_gta_hash(
    bad_manifest[manifest_fields]
  )
  expect_false(env$mfrmr_gtwan_reserved_manifest_hash_valid(bad_manifest))

  bad_confirmation <- objects$Manifest
  bad_confirmation$ConfirmationUse <- TRUE
  bad_confirmation$ManifestHash <- env$mfrmr_gta_hash(
    bad_confirmation[manifest_fields]
  )
  expect_false(env$mfrmr_gtwan_reserved_manifest_hash_valid(
    bad_confirmation
  ))

  bad_shard <- objects$Bundle$Manifests[[1L]]
  bad_shard$Units$ResponseGenerated[[1L]] <- TRUE
  shard_fields <- c(
    "Contract", "HardenedLineageContractHash", "ReservedManifestHash",
    "HardenedAdapterContractHash", "HardenedGeneratorContractHash",
    "ShardId", "Replicate", "Units", "CandidateEvaluatorHash",
    "ReferenceEvaluatorHash", "OutputSubdirectory",
    "ReservedCalibrationUse", "ConfirmationUse",
    "ResponseGenerationPermitted", "ModelFittingPermitted",
    "EarlyStoppingPermitted"
  )
  bad_shard$ManifestHash <- env$mfrmr_gta_hash(bad_shard[shard_fields])
  expect_false(env$mfrmr_gtwan_shard_manifest_hash_valid(bad_shard))

  expect_error(
    env$mfrmr_gtwan_shard_manifest(
      objects$Contract, objects$Manifest, objects$Sealed, "R0501"
    ), "registered reserved shard"
  )
})
