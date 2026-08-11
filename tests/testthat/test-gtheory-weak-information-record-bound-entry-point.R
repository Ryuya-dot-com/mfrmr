gtheory_record_bound_entry_paths <- function() {
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
    "gtheory-weak-information-hardened-adapter-rebase-0.2.3.R",
    "gtheory-weak-information-hardened-reserved-lineage-0.2.3.R",
    "gtheory-weak-information-authorization-kernel-0.2.3.R",
    "gtheory-weak-information-guarded-shard-runner-0.2.3.R",
    "gtheory-weak-information-execution-authorization-decision-0.2.3.R",
    "gtheory-weak-information-record-bound-entry-point-0.2.3.R"
  ))
}

load_gtheory_record_bound_entry <- function() {
  paths <- gtheory_record_bound_entry_paths()
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

gtheory_record_bound_entry_objects <- function(env) {
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
  exact_runner <- env$mfrmr_gtwag_contract(boundary, authorization, sealed)
  parent_adapter <- env$mfrmr_gtwah_contract(
    exact_runner, boundary, glmm_reference, lme4_reference
  )
  historical_manifest <- env$mfrmr_gtwah_reserved_manifest(
    parent_adapter, sealed
  )
  adapter_preflight <- env$mfrmr_gtwai_contract(
    parent_adapter, historical_manifest
  )
  old_shards <- env$mfrmr_gtwai_shard_bundle(
    adapter_preflight, historical_manifest, sealed
  )
  value_contract <- env$mfrmr_gtwaj_contract(
    adapter_preflight, env$mfrmr_gtwae_policy()
  )
  value_audit <- env$mfrmr_gtwaj_audit(value_contract)
  hardening_contract <- env$mfrmr_gtwak_contract(
    adapter_preflight, old_shards, value_contract, value_audit
  )
  hardening_audit <- env$mfrmr_gtwak_audit(hardening_contract)
  rng_contract <- env$mfrmr_gtwal_contract(
    hardening_contract, hardening_audit
  )
  rng_manifest <- env$mfrmr_gtwal_replay_manifest()
  rng_replay <- env$mfrmr_gtwal_replay(rng_manifest)
  rng_audit <- env$mfrmr_gtwal_audit(rng_contract, rng_manifest, rng_replay)
  hardened_adapter <- env$mfrmr_gtwam_contract(
    parent_adapter, rng_contract, rng_audit
  )
  lineage <- env$mfrmr_gtwan_contract(
    parent_adapter, historical_manifest, sealed
  )
  reserved_manifest <- env$mfrmr_gtwan_reserved_manifest(
    lineage, historical_manifest, sealed
  )
  shard_bundle <- env$mfrmr_gtwan_shard_bundle(
    lineage, reserved_manifest, sealed
  )
  lineage_audit <- env$mfrmr_gtwan_audit(
    lineage, historical_manifest, reserved_manifest, shard_bundle
  )
  validation <- testthat::test_path("..", "..", "inst", "validation")
  kernel_worker <- file.path(
    validation,
    "gtheory-weak-information-authorization-kernel-worker-0.2.3.R"
  )
  kernel <- env$mfrmr_gtwao_contract(
    lineage, reserved_manifest, shard_bundle, lineage_audit, kernel_worker
  )
  project_root <- normalizePath(testthat::test_path("..", ".."))
  kernel_preflight <- env$mfrmr_gtwao_preflight(
    kernel, lineage_audit, kernel_worker, project_root
  )
  guarded_worker <- file.path(
    validation,
    "gtheory-weak-information-guarded-shard-runner-worker-0.2.3.R"
  )
  guarded <- env$mfrmr_gtwap_contract(
    hardened_adapter, lineage, kernel, kernel_preflight, guarded_worker
  )
  guarded_manifest <- env$mfrmr_gtwap_fixture_manifest(guarded)
  decision_policy <- env$mfrmr_gtwaq_policy()
  source_audit <- env$mfrmr_gtwaq_source_audit(
    file.path(validation,
              "gtheory-weak-information-guarded-shard-runner-0.2.3.R"),
    file.path(validation,
              "gtheory-weak-information-stationarity-exact-resume-runner-0.2.3.R"),
    decision_policy
  )
  decision <- env$mfrmr_gtwaq_decision(
    env$mfrmr_gtwaq_parent_receipt(), decision_policy, source_audit
  )
  prospective <- shard_bundle$Manifests[["R0201"]]
  worker <- file.path(
    validation,
    "gtheory-weak-information-record-bound-entry-point-worker-0.2.3.R"
  )
  contract <- env$mfrmr_gtwar_contract(
    guarded, prospective, decision, source_audit, worker
  )
  record <- env$mfrmr_gtwar_reduction_record(contract, guarded_manifest)
  active <- env$mfrmr_gtwar_active_manifest(
    contract, guarded_manifest, record
  )
  list(
    Guarded = guarded, GuardedManifest = guarded_manifest,
    Decision = decision, SourceAudit = source_audit,
    Prospective = prospective, Contract = contract,
    Record = record, Active = active, Worker = worker
  )
}

gtheory_record_bound_entry_cache <- new.env(parent = emptyenv())

gtheory_record_bound_entry_result <- function() {
  if (!is.null(gtheory_record_bound_entry_cache$result)) {
    return(gtheory_record_bound_entry_cache$result)
  }
  env <- load_gtheory_record_bound_entry()
  objects <- gtheory_record_bound_entry_objects(env)
  root <- tempfile("mfrmr-gtwar-test-")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
  parent_root <- file.path(root, "parent")
  dir.create(parent_root)
  parent <- env$mfrmr_gtwag_execute(
    objects$Guarded, objects$GuardedManifest, parent_root,
    candidate_evaluator = env$mfrmr_gtwap_candidate_evaluator,
    reference_evaluator = env$mfrmr_gtwap_reference_evaluator
  )
  target <- file.path(root, "record-bound")
  initial <- env$mfrmr_gtwar_run_reduction(
    objects$Contract, objects$Active, objects$Record,
    objects$Worker, target
  )
  resume <- env$mfrmr_gtwar_run_reduction(
    objects$Contract, objects$Active, objects$Record,
    objects$Worker, target
  )
  result <- list(
    Env = env, Objects = objects, Parent = parent,
    Initial = initial, Resume = resume
  )
  gtheory_record_bound_entry_cache$result <- result
  result
}

test_that("b1g23 freezes record-bound entry mechanics without issuance", {
  result <- gtheory_record_bound_entry_result()
  env <- result$Env
  objects <- result$Objects
  contract <- objects$Contract
  active <- objects$Active

  expect_true(env$mfrmr_gtwar_policy_hash_valid(
    contract$RecordBoundEntryPolicy
  ))
  expect_true(env$mfrmr_gtwar_contract_hash_valid(contract))
  expect_true(env$mfrmr_gtwar_reduction_record_hash_valid(
    objects$Record, contract, objects$GuardedManifest
  ))
  expect_true(env$mfrmr_gtwar_active_manifest_hash_valid(active, contract))
  expect_identical(
    contract$RecordBoundEntryPolicy$PolicyHash,
    "61ee07c4ea86087a7ad8731ef374b38ec7f12621cc8e818501f4e4bab85abd07"
  )
  expect_identical(
    contract$ContractHash,
    "0dca57ff5546d49c2ef49b27e89bd571d19fbbe93ea3698dbdb7d87b69abfd3a"
  )
  expect_identical(
    objects$Record$AuthorizationRecordHash,
    "c1c08749050445743e6938357b64aed921fc6b620fdbec31c3586ea40c2f0af0"
  )
  expect_identical(
    active$ActiveManifestHash,
    "2221cc38bf526b1cf7d0f66d59090b1af7b1c8b9cbdc6f144caaa06c57399f3a"
  )
  expect_identical(
    active$ManifestHash,
    "f19fae6e4aab925e84416ef1f58d9435e07c5d22af70438dcb291c95481f620a"
  )
  expect_identical(
    contract$RecordBoundEntryPolicy$EntrySourceHash,
    "eec3a92a69aa1d1378137342094e536c4c71c3674b15c7a1260869cbcb0d1394"
  )
  expect_identical(
    contract$RecordBoundEntryPolicy$WorkerSourceHash,
    "a2ed1788b2ad96f3feb298beee67bff2aa99e8d97f3a874f6ed2bd32c3e799cd"
  )
  expect_identical(
    contract$RecordBoundEntryPolicy$ParentPrepareFunctionHash,
    "5e786d135a50fcbeb01fedb168d0f86cdb6986187db0e355a6d3aac6601de6e7"
  )
  expect_identical(
    contract$RecordBoundEntryPolicy$ReusedPrepareCoreHash,
    "94d55cb209c99959adf772f9e92329a1e42c6e806921b32a833ecf604dbc073d"
  )
  expect_identical(
    contract$RecordBoundEntryPolicy$ParentGeneratorFunctionHash,
    "8a644cf5b512d3e66bcd729ff00e64db3801ab741490092697dc5b170c445986"
  )
  expect_identical(
    contract$RecordBoundEntryPolicy$ReusedGeneratorCoreHash,
    "8c5a59ac392fe048cf437a7c36f021ecc1f4dbccb69d7df365306acd7059d170"
  )
  expect_identical(
    contract$RecordBoundEntryPolicy$ParentExecuteFunctionHash,
    "1e2b73c4e26c44586a859b6dda9dd2343ed0d435cec416cbc4982accaf7a2e02"
  )
  expect_identical(
    contract$RecordBoundEntryPolicy$ReusedExecuteCoreHash,
    "d718ee9d716d81d8dc4149a8d2dd3a337c98c8d5d299ebdea895487204d0bd25"
  )
  expect_identical(objects$Prospective$ManifestHash,
                   contract$ProspectiveManifestHash)
  expect_identical(active$AtomicUnitCount, 4L)
  expect_identical(active$CandidateFitRowCount, 36L)
  expect_identical(active$CandidateDecisionRowCount, 192L)
  expect_identical(active$ReferenceRowCount, 8L)
  expect_true(contract$ReservedEntryPointImplementationReady)
  expect_true(contract$ActiveManifestConversionImplementationReady)
  expect_true(contract$ReservedAdapterEntryPointReady)
  expect_true(contract$ActiveManifestConversionReady)
  expect_false(contract$ProductionIssuanceFunctionDefined)
  expect_false(exists(
    "mfrmr_gtwar_issue_authorization_record", envir = env, inherits = FALSE
  ))
  parent_generator <- paste(
    deparse(body(env$mfrmr_gtwal_generate), width.cutoff = 500L),
    collapse = "\n"
  )
  reused_generator <- paste(
    deparse(body(env$mfrmr_gtwar_generate_core()), width.cutoff = 500L),
    collapse = "\n"
  )
  expect_match(parent_generator,
               "b1g17 cannot open reserved calibration", fixed = TRUE)
  expect_false(grepl(
    "b1g17 cannot open reserved calibration", reused_generator, fixed = TRUE
  ))
  expect_false(contract$AuthorizationRecordIssued)
  expect_false(contract$ActiveReservedManifestIssued)
  expect_false(contract$FreshSiteReceiptBound)
  expect_false(contract$LargeSimulationMayStart)
  expect_false(contract$Replicate201MayBeOpened)
})

test_that("b1g23 reduces the reused cores and exactly resumes", {
  result <- gtheory_record_bound_entry_result()
  env <- result$Env
  objects <- result$Objects
  initial <- result$Initial
  resume <- result$Resume

  expect_true(env$mfrmr_gtwar_run_receipt_hash_valid(
    initial, objects$Contract, objects$Active, objects$Record
  ))
  expect_true(env$mfrmr_gtwar_run_receipt_hash_valid(
    resume, objects$Contract, objects$Active, objects$Record
  ))
  expect_identical(initial$ActivationState, "initial_activation")
  expect_identical(resume$ActivationState, "exact_resume")
  expect_identical(initial$Execution$ComputedUnitCount, 4L)
  expect_identical(resume$Execution$ComputedUnitCount, 0L)
  expect_identical(resume$Execution$ReusedUnitCount, 4L)
  expect_identical(initial$ExecutionHash, resume$ExecutionHash)
  expect_identical(initial$Execution$CandidateFits,
                   result$Parent$CandidateFits)
  expect_identical(initial$Execution$CandidateDecisions,
                   result$Parent$CandidateDecisions)
  expect_identical(initial$Execution$References,
                   result$Parent$References)
  expect_identical(nrow(initial$Execution$CandidateFits), 36L)
  expect_identical(nrow(initial$Execution$CandidateDecisions), 192L)
  expect_identical(nrow(initial$Execution$References), 8L)
  expect_identical(initial$Execution$CandidateFitFailureCount, 1L)
  expect_true(initial$Execution$RecordBoundEntryPointUsed)
  expect_false(initial$CalibrationExecutionAuthorized)
  expect_false(initial$CalibrationDataGenerated)
  expect_false(initial$CalibrationResultsViewed)
  expect_false(initial$ConfirmationAuthorized)
})

test_that("b1g23 keeps R0201 inert until a separate production record", {
  result <- gtheory_record_bound_entry_result()
  env <- result$Env
  objects <- result$Objects
  contract <- objects$Contract
  prospective <- objects$Prospective

  expect_identical(prospective$ShardId, "R0201")
  expect_identical(prospective$Replicate, 201L)
  expect_identical(c(
    Datasets = prospective$DatasetCount,
    AtomicUnits = prospective$AtomicUnitCount,
    CandidateFits = prospective$CandidateFitRowCount,
    CandidateDecisions = prospective$CandidateDecisionRowCount,
    References = prospective$ReferenceRowCount
  ), c(
    Datasets = 30L, AtomicUnits = 120L, CandidateFits = 1080L,
    CandidateDecisions = 5760L, References = 240L
  ))
  expect_error(
    env$mfrmr_gtwar_active_manifest(
      contract, prospective, objects$Record
    ),
    "cannot activate a reserved manifest"
  )
  reserved_unit <- prospective$Units[1L, , drop = FALSE]
  reserved_unit$AuthorizationRecordHash <- "not-issued"
  expect_error(
    env$mfrmr_gtwar_prepare_unit(contract, reserved_unit),
    "active record-bound"
  )
  expect_false(env$mfrmr_gtwar_authorization_record_hash_valid(
    objects$Record, contract, prospective
  ))
  expect_error(
    env$mfrmr_gtwar_run_authorized_shard(
      contract, objects$Active, objects$Record, objects$Worker,
      tempfile("mfrmr-gtwar-prohibited-")
    ),
    "separately issued exact R0201 production record"
  )
  project_root <- normalizePath(testthat::test_path("..", ".."))
  expect_false(dir.exists(file.path(
    project_root, prospective$OutputSubdirectory
  )))
  expect_false(contract$CalibrationExecutionAuthorized)
  expect_false(contract$CalibrationDataGenerated)
  expect_false(contract$CalibrationResultsViewed)
  expect_false(contract$ConfirmationAuthorized)
  expect_false(contract$InferenceReady)
  expect_false(contract$DecisionReady)
})

test_that("b1g23 rejects contract manifest record job and result mutations", {
  result <- gtheory_record_bound_entry_result()
  env <- result$Env
  objects <- result$Objects

  bad_contract <- objects$Contract
  bad_contract$RecordBoundEntryPolicy$MaximumAuthorizedShardCount <- 2L
  expect_false(env$mfrmr_gtwar_contract_hash_valid(bad_contract))
  bad_record <- objects$Record
  bad_record$ProductionIssuance <- TRUE
  expect_false(env$mfrmr_gtwar_reduction_record_hash_valid(
    bad_record, objects$Contract, objects$GuardedManifest
  ))
  expect_error(
    env$mfrmr_gtwar_capability_activate(
      objects$Contract, objects$Active, bad_record
    ),
    "Exact record-bound inputs|required|reduction record"
  )
  bad_manifest <- objects$Active
  bad_manifest$Units$AtomicUnitIdentityHash[[1L]] <- "changed"
  expect_false(env$mfrmr_gtwar_active_manifest_hash_valid(
    bad_manifest, objects$Contract
  ))
  bad_job <- result$Initial$Job
  bad_job$ActivationMarkerHash <- "changed"
  expect_false(env$mfrmr_gtwar_job_hash_valid(bad_job))
  bad_result <- result$Initial
  bad_result$Execution$CandidateFits$Objective[[1L]] <- 999
  expect_false(env$mfrmr_gtwar_run_receipt_hash_valid(
    bad_result, objects$Contract, objects$Active, objects$Record
  ))
})
