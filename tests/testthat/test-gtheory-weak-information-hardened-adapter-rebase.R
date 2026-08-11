gtheory_hardened_adapter_paths <- function() {
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
    "gtheory-weak-information-rng-hardened-generator-0.2.3.R",
    "gtheory-weak-information-hardened-adapter-rebase-0.2.3.R"
  ))
}

load_gtheory_hardened_adapter <- function() {
  paths <- gtheory_hardened_adapter_paths()
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

gtheory_hardened_adapter_objects <- function(env) {
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
  parent_adapter <- env$mfrmr_gtwah_contract(
    runner, boundary, glmm_reference, lme4_reference
  )
  reserved <- env$mfrmr_gtwah_reserved_manifest(parent_adapter, sealed)
  preflight <- env$mfrmr_gtwai_contract(parent_adapter, reserved)
  shards <- env$mfrmr_gtwai_shard_bundle(preflight, reserved, sealed)
  value_contract <- env$mfrmr_gtwaj_contract(
    preflight, env$mfrmr_gtwae_policy()
  )
  value_audit <- env$mfrmr_gtwaj_audit(value_contract)
  hardening_contract <- env$mfrmr_gtwak_contract(
    preflight, shards, value_contract, value_audit
  )
  hardening_audit <- env$mfrmr_gtwak_audit(hardening_contract)
  rng_contract <- env$mfrmr_gtwal_contract(
    hardening_contract, hardening_audit
  )
  rng_manifest <- env$mfrmr_gtwal_replay_manifest()
  rng_replay <- env$mfrmr_gtwal_replay(rng_manifest)
  rng_audit <- env$mfrmr_gtwal_audit(
    rng_contract, rng_manifest, rng_replay
  )
  contract <- env$mfrmr_gtwam_contract(
    parent_adapter, rng_contract, rng_audit
  )
  list(
    ParentAdapter = parent_adapter,
    ParentDry = env$mfrmr_gtwah_dry_manifest(parent_adapter),
    RNGContract = rng_contract, RNGAudit = rng_audit,
    Contract = contract, Dry = env$mfrmr_gtwam_dry_manifest(contract)
  )
}

gtheory_hardened_adapter_cache <- new.env(parent = emptyenv())

gtheory_hardened_adapter_execution <- function() {
  if (!is.null(gtheory_hardened_adapter_cache$result)) {
    return(gtheory_hardened_adapter_cache$result)
  }
  env <- load_gtheory_hardened_adapter()
  objects <- gtheory_hardened_adapter_objects(env)
  old_root <- tempfile("mfrmr-gtwam-old-")
  new_root <- tempfile("mfrmr-gtwam-new-")
  dir.create(old_root)
  dir.create(new_root)
  on.exit(unlink(c(old_root, new_root), recursive = TRUE), add = TRUE)
  parent_execution <- env$mfrmr_gtwag_execute(
    objects$ParentAdapter, objects$ParentDry, old_root,
    candidate_evaluator = env$mfrmr_gtwah_candidate_evaluator,
    reference_evaluator = env$mfrmr_gtwah_reference_evaluator
  )
  hardened_execution <- env$mfrmr_gtwag_execute(
    objects$Contract, objects$Dry, new_root,
    candidate_evaluator = env$mfrmr_gtwam_candidate_evaluator,
    reference_evaluator = env$mfrmr_gtwam_reference_evaluator
  )
  reuse <- env$mfrmr_gtwag_execute(
    objects$Contract, objects$Dry, new_root,
    candidate_evaluator = env$mfrmr_gtwam_candidate_evaluator,
    reference_evaluator = env$mfrmr_gtwam_reference_evaluator
  )
  audit <- env$mfrmr_gtwam_audit(
    objects$Contract, objects$Dry, parent_execution, hardened_execution
  )
  result <- list(
    Env = env, Objects = objects, ParentExecution = parent_execution,
    HardenedExecution = hardened_execution, Reuse = reuse, Audit = audit
  )
  gtheory_hardened_adapter_cache$result <- result
  result
}

test_that("b1g18 freezes a distinct nonreserved hardened adapter contract", {
  result <- gtheory_hardened_adapter_execution()
  env <- result$Env
  contract <- result$Objects$Contract
  manifest <- result$Objects$Dry

  expect_true(env$mfrmr_gtwam_policy_hash_valid(
    contract$HardenedAdapterPolicy
  ))
  expect_true(env$mfrmr_gtwam_contract_hash_valid(contract))
  expect_true(env$mfrmr_gtwag_manifest_hash_valid(manifest))
  expect_identical(
    contract$HardenedAdapterPolicy$PolicyHash,
    "4a4d5ff4becc42e931806cc19d97449d8ec083b65b970d201230f4f4b5e19684"
  )
  expect_identical(
    contract$ContractHash,
    "0373db563cd16c63693b02b968dbbd49221a77e1f666b87cc63b17cb6f786e64"
  )
  expect_identical(
    manifest$ManifestHash,
    "090b761a835098b037b3f65021ebe22eeae9df822628df6898685b1f84e99d15"
  )
  expect_identical(
    unname(contract$AdapterHashes),
    c(
      "94713fabb2ba12301984912560ac8017d6d22c2c3d66525c67016326ff1ab7c9",
      "91770297261211cdca1eb9ad760e5ebc7b726a9bdb2730af9d3dd4633940e6db"
    )
  )
  expect_identical(
    contract$ParentAdapterContractHash,
    result$Objects$ParentAdapter$ContractHash
  )
  expect_identical(
    contract$HardenedGeneratorContractHash,
    result$Objects$RNGContract$ContractHash
  )
  expect_true(contract$HistoricalAdapterPreserved)
  expect_true(contract$NonreservedHardenedAdaptersFrozen)
  expect_false(contract$NonreservedAdapterRebaseReady)
  expect_false(contract$ReservedAdapterEntryPointReady)
  expect_false(contract$AuthorizationRNG01Closed)
  expect_identical(manifest$AtomicUnitCount, 4L)
  expect_identical(manifest$CandidateFitRowCount, 36L)
  expect_identical(manifest$CandidateDecisionRowCount, 192L)
  expect_identical(manifest$ReferenceRowCount, 8L)
  expect_identical(manifest$Replicates, 902L)
  expect_false(manifest$CalibrationExecutionAuthorized)
  expect_false(manifest$ReservedCalibrationUse)
  expect_false(manifest$ConfirmationUse)
})

test_that("b1g18 preparation preserves data but changes scientific lineage", {
  result <- gtheory_hardened_adapter_execution()
  env <- result$Env
  objects <- result$Objects
  unit <- objects$Dry$Units[1L, , drop = FALSE]
  old <- env$mfrmr_gtwah_prepare_unit(objects$ParentAdapter, unit)
  new <- env$mfrmr_gtwam_prepare_unit(objects$Contract, unit)

  expect_identical(old$Generation$AnalysisData, new$Generation$AnalysisData)
  expect_identical(new$AnalysisDataHash, new$HistoricalAnalysisDataHash)
  expect_identical(old$GeneratorHash, new$HistoricalGeneratorHash)
  expect_false(identical(old$GeneratorHash, new$GeneratorHash))
  expect_false(identical(old$PreFitHash, new$PreFitHash))
  expect_identical(old$Data, new$Data)

  reserved <- unit
  reserved$Replicate <- 201L
  reserved$DatasetId <- sprintf("%s/R0201", reserved$ScenarioId)
  reserved$AtomicUnitId <- paste(
    reserved$DatasetId, reserved$MethodId, sep = "::"
  )
  expect_error(
    env$mfrmr_gtwam_prepare_unit(objects$Contract, reserved),
    "cannot open a reserved replicate"
  )
})

test_that("b1g18 four-lane execution has exact historical semantic parity", {
  result <- gtheory_hardened_adapter_execution()
  env <- result$Env
  execution <- result$HardenedExecution
  audit <- result$Audit

  expect_true(execution$Complete)
  expect_true(execution$ExactAccountingPassed)
  expect_identical(nrow(execution$CandidateFits), 36L)
  expect_identical(nrow(execution$CandidateDecisions), 192L)
  expect_identical(nrow(execution$References), 8L)
  expect_identical(execution$CandidateFitFailureCount, 1L)
  expect_identical(execution$ReferenceUnresolvedCount, 0L)
  expect_identical(sum(execution$CandidateFits$FitReturned), 35L)
  expect_identical(
    execution$CandidateFits$FailureStage[
      !execution$CandidateFits$FitReturned
    ], "start_snapshot"
  )
  expect_true(env$mfrmr_gtwam_audit_hash_valid(audit))
  expect_identical(
    result$ParentExecution$ExecutionHash,
    "b9ad747a62b1e14cf1da1e0e4cee8a0a341db969596df3e2de87b25ba908caae"
  )
  expect_identical(
    execution$ExecutionHash,
    "14a44a4382e50ba2819d57072288bd213789935d4ed6d78fba674a8081b62aeb"
  )
  expect_identical(
    audit$AuditHash,
    "1e8461eca060b00215240d65c506873d6f082f66b6216fb1ff30761df7dfdb63"
  )
  expect_true(audit$CandidateSemanticParity)
  expect_true(audit$CandidateDecisionParity)
  expect_true(audit$ReferenceSemanticParity)
  expect_true(audit$HardenedCandidateReferenceGeneratorMatch)
  expect_true(audit$HardenedCandidateReferencePreFitMatch)
  expect_true(audit$NonreservedAdapterRebaseReady)
  expect_true(audit$RNGAdapterComponentProspectivelyResolved)
  expect_identical(result$Reuse$ReusedUnitCount, 4L)
  expect_identical(result$Reuse$ComputedUnitCount, 0L)
  expect_identical(result$Reuse$ExecutionHash, execution$ExecutionHash)
  expect_false(audit$ReservedAdapterEntryPointReady)
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

test_that("b1g18 rejects coherent manifest and audit mutations", {
  result <- gtheory_hardened_adapter_execution()
  env <- result$Env
  changed_manifest <- result$Objects$Dry
  changed_manifest$ConfirmationUse <- TRUE
  expect_false(env$mfrmr_gtwag_manifest_hash_valid(changed_manifest))

  changed_audit <- result$Audit
  changed_audit$CandidateSemanticParity <- FALSE
  audit_fields <- c(
    "Contract", "HardenedAdapterContractHash", "HardenedDryManifestHash",
    "ParentExecutionHash", "HardenedExecutionHash", "ParentCounts",
    "HardenedCounts", "CandidateSemanticParity", "CandidateDecisionParity",
    "ReferenceSemanticParity", "HardenedCandidateReferenceGeneratorMatch",
    "HardenedCandidateReferencePreFitMatch", "HistoricalAdapterPreserved",
    "ReservedManifestRebaseDeferred", "CalibrationResponsesUsed",
    "ConfirmationResponsesUsed"
  )
  changed_audit$AuditHash <- env$mfrmr_gta_hash(changed_audit[audit_fields])
  expect_false(env$mfrmr_gtwam_audit_hash_valid(changed_audit))
})
