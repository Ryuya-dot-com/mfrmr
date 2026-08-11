gtheory_guarded_runner_paths <- function() {
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
    "gtheory-weak-information-guarded-shard-runner-0.2.3.R"
  ))
}

load_gtheory_guarded_runner <- function() {
  paths <- gtheory_guarded_runner_paths()
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

gtheory_guarded_runner_objects <- function(env) {
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
  rng_audit <- env$mfrmr_gtwal_audit(
    rng_contract, rng_manifest, rng_replay
  )
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
  runner_worker <- file.path(
    validation,
    "gtheory-weak-information-guarded-shard-runner-worker-0.2.3.R"
  )
  guarded <- env$mfrmr_gtwap_contract(
    hardened_adapter, lineage, kernel, kernel_preflight, runner_worker
  )
  list(
    HardenedAdapter = hardened_adapter,
    HardenedManifest = env$mfrmr_gtwam_dry_manifest(hardened_adapter),
    Lineage = lineage, ReservedManifest = reserved_manifest,
    Kernel = kernel, KernelPreflight = kernel_preflight,
    Guarded = guarded, Manifest = env$mfrmr_gtwap_fixture_manifest(guarded),
    Worker = runner_worker
  )
}

gtheory_guarded_runner_cache <- new.env(parent = emptyenv())

gtheory_guarded_runner_context <- function() {
  if (!is.null(gtheory_guarded_runner_cache$context)) {
    return(gtheory_guarded_runner_cache$context)
  }
  context <- list(
    Env = load_gtheory_guarded_runner()
  )
  context$Objects <- gtheory_guarded_runner_objects(context$Env)
  gtheory_guarded_runner_cache$context <- context
  context
}

gtheory_guarded_runner_result <- function() {
  mfrmr_skip_if_not_gtheory_slow()
  if (!is.null(gtheory_guarded_runner_cache$result)) {
    return(gtheory_guarded_runner_cache$result)
  }
  context <- gtheory_guarded_runner_context()
  env <- context$Env
  objects <- context$Objects
  fixture_parent <- tempfile("mfrmr-gtwap-test-")
  dir.create(fixture_parent)
  on.exit(unlink(fixture_parent, recursive = TRUE, force = TRUE), add = TRUE)
  parent_root <- file.path(fixture_parent, "parent")
  dir.create(parent_root)
  parent_execution <- env$mfrmr_gtwag_execute(
    objects$HardenedAdapter, objects$HardenedManifest, parent_root,
    candidate_evaluator = env$mfrmr_gtwam_candidate_evaluator,
    reference_evaluator = env$mfrmr_gtwam_reference_evaluator
  )
  target <- file.path(fixture_parent, "guarded")
  initial <- env$mfrmr_gtwap_run_fixture(
    objects$Guarded, objects$Manifest, objects$Worker, target
  )
  resume <- env$mfrmr_gtwap_run_fixture(
    objects$Guarded, objects$Manifest, objects$Worker, target
  )
  audit <- env$mfrmr_gtwap_audit(
    objects$Guarded, objects$Manifest, parent_execution, initial, resume
  )
  result <- list(
    Env = env, Objects = objects, ParentExecution = parent_execution,
    Initial = initial, Resume = resume, Audit = audit
  )
  gtheory_guarded_runner_cache$result <- result
  result
}

test_that("b1g21 freezes one guarded nonreserved reduction contract", {
  context <- gtheory_guarded_runner_context()
  env <- context$Env
  contract <- context$Objects$Guarded
  manifest <- context$Objects$Manifest

  expect_true(env$mfrmr_gtwap_policy_hash_valid(
    contract$GuardedRunnerPolicy
  ))
  expect_true(env$mfrmr_gtwap_contract_hash_valid(contract))
  expect_true(env$mfrmr_gtwap_fixture_manifest_hash_valid(
    manifest, contract
  ))
  expect_identical(
    contract$GuardedRunnerPolicy$PolicyHash,
    "ecdf55015369c04e9ec81549fe68a624d0c0a025a154f28eeedc3adbd41d86aa"
  )
  expect_identical(
    contract$ContractHash,
    "f6d932f5261b3816bd16afa820cc2c36acf188d5144277b22623a9b41245f552"
  )
  expect_identical(
    manifest$ManifestHash,
    "0a515e0977774887094321284a723e058d9b1723f3d45f505245429dc93d6db3"
  )
  expect_identical(
    contract$GuardedRunnerPolicy$RunnerSourceHash,
    "b179c44076107c64e0f7d030585d38dec11bffba5231dcf4a702631a11742e1c"
  )
  expect_identical(
    contract$GuardedRunnerPolicy$WorkerSourceHash,
    "8a7bfbe987a4178f83351508d29defeb631acb9f3cd9c1f724ae85d68fbf2df7"
  )
  expect_identical(manifest$AtomicUnitCount, 4L)
  expect_identical(manifest$CandidateFitRowCount, 36L)
  expect_identical(manifest$CandidateDecisionRowCount, 192L)
  expect_identical(manifest$ReferenceRowCount, 8L)
  expect_identical(manifest$Replicates, 902L)
  expect_true(contract$AuthorizationBoundReservedEntryPointDefined)
  expect_true(contract$GuardedSingleShardRunnerImplemented)
  expect_true(contract$RunnerImplementationReady)
  expect_false("AuthorizationKernelPreflightHash" %in% names(contract))
  expect_false(
    "AuthorizationKernelPreflightHash" %in%
      names(contract$GuardedRunnerPolicy)
  )
  expect_false(contract$ReservedAdapterEntryPointReady)
  expect_false(contract$AuthorizationRecordIssued)
  expect_false(contract$LargeSimulationMayStart)
})

test_that("b1g21 executes and exactly resumes in an isolated child", {
  result <- gtheory_guarded_runner_result()
  env <- result$Env
  objects <- result$Objects

  expect_true(env$mfrmr_gtwap_run_receipt_hash_valid(
    result$Initial, objects$Guarded, objects$Manifest
  ))
  expect_true(env$mfrmr_gtwap_run_receipt_hash_valid(
    result$Resume, objects$Guarded, objects$Manifest
  ))
  expect_identical(result$Initial$ActivationState, "initial_activation")
  expect_identical(result$Resume$ActivationState, "exact_resume")
  expect_identical(result$Initial$Execution$ComputedUnitCount, 4L)
  expect_identical(result$Resume$Execution$ComputedUnitCount, 0L)
  expect_identical(result$Resume$Execution$ReusedUnitCount, 4L)
  expect_identical(
    result$Initial$ExecutionHash, result$Resume$ExecutionHash
  )
  expect_true(env$mfrmr_gtwap_audit_hash_valid(result$Audit))
  expect_true(result$Audit$CandidateSemanticParity)
  expect_true(result$Audit$CandidateDecisionParity)
  expect_true(result$Audit$ReferenceSemanticParity)
  expect_true(result$Audit$GuardedSingleShardRunnerReady)
  expect_true(result$Audit$Runner01Closed)
  expect_identical(
    result$Audit$RemainingAuthorizationBlockerIds, "AUTH-RECORD-01"
  )
  expect_false(result$Audit$ReservedExecutionAttempted)
  expect_false(result$Audit$ReservedAdapterEntryPointReady)
  expect_false(result$Audit$AuthorizedSingleShardRunnerReady)
  expect_false(result$Audit$AuthorizationRecordIssued)
  expect_false(result$Audit$AuthorizationRNG01Closed)
  expect_false(result$Audit$LargeSimulationMayStart)
  expect_false(result$Audit$Replicate201MayBeOpened)
  expect_false(result$Audit$CalibrationExecutionAuthorized)
  expect_false(result$Audit$CalibrationDataGenerated)
  expect_false(result$Audit$ConfirmationAuthorized)
})

test_that("b1g21 keeps reserved and confirmation bands sealed", {
  context <- gtheory_guarded_runner_context()
  env <- context$Env
  contract <- context$Objects$Guarded
  unit <- context$Objects$Manifest$Units[1L, , drop = FALSE]

  reserved <- unit
  reserved$Replicate <- 201L
  reserved$DatasetId <- sprintf("%s/R0201", reserved$ScenarioId)
  reserved$AtomicUnitId <- paste(
    reserved$DatasetId, reserved$MethodId, sep = "::"
  )
  expect_error(
    env$mfrmr_gtwap_prepare_unit(contract, reserved),
    "separately issued authorization record"
  )
  confirmation <- unit
  confirmation$Replicate <- 501L
  confirmation$DatasetId <- sprintf("%s/R0501", confirmation$ScenarioId)
  confirmation$AtomicUnitId <- paste(
    confirmation$DatasetId, confirmation$MethodId, sep = "::"
  )
  expect_error(
    env$mfrmr_gtwap_prepare_unit(contract, confirmation),
    "remain inaccessible"
  )
  bad_manifest <- context$Objects$Manifest
  bad_manifest$Replicates <- 201L
  expect_false(env$mfrmr_gtwap_fixture_manifest_hash_valid(
    bad_manifest, contract
  ))
})

test_that("b1g21 rejects contract, manifest, and worker mutations", {
  context <- gtheory_guarded_runner_context()
  env <- context$Env
  objects <- context$Objects

  bad_contract <- objects$Guarded
  bad_contract$GuardedRunnerPolicy$WorkerSourceHash <- "changed"
  expect_false(env$mfrmr_gtwap_contract_hash_valid(bad_contract))
  bad_manifest <- objects$Manifest
  bad_manifest$Units$AtomicUnitIdentityHash[[1L]] <- "changed"
  expect_false(env$mfrmr_gtwap_fixture_manifest_hash_valid(
    bad_manifest, objects$Guarded
  ))
  expect_error(
    env$mfrmr_gtwap_run_fixture(
      objects$Guarded, objects$Manifest,
      testthat::test_path("..", "..", "DESCRIPTION"),
      tempfile("mfrmr-gtwap-bad-")
    ),
    "exact b1g21 fixture and worker"
  )
})

test_that("b1g21 rejects executed receipt and job mutations", {
  result <- gtheory_guarded_runner_result()
  env <- result$Env
  objects <- result$Objects

  tampered <- result$Initial
  tampered$Execution$CandidateFits$Objective[[1L]] <- 999
  expect_false(env$mfrmr_gtwap_run_receipt_hash_valid(
    tampered, objects$Guarded, objects$Manifest
  ))
  tampered_job <- result$Initial$Job
  tampered_job$ActivationMarkerHash <- "changed"
  expect_false(env$mfrmr_gtwap_job_hash_valid(tampered_job))
})
