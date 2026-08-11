gtheory_authorization_kernel_paths <- function() {
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
    "gtheory-weak-information-hardened-reserved-lineage-0.2.3.R",
    "gtheory-weak-information-authorization-kernel-0.2.3.R"
  ))
}

load_gtheory_authorization_kernel <- function() {
  paths <- gtheory_authorization_kernel_paths()
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

gtheory_authorization_kernel_lineage <- function(env) {
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
  contract <- env$mfrmr_gtwan_contract(
    historical_adapter, historical_manifest, sealed
  )
  manifest <- env$mfrmr_gtwan_reserved_manifest(
    contract, historical_manifest, sealed
  )
  bundle <- env$mfrmr_gtwan_shard_bundle(contract, manifest, sealed)
  audit <- env$mfrmr_gtwan_audit(
    contract, historical_manifest, manifest, bundle
  )
  list(
    Sealed = sealed, Contract = contract, Manifest = manifest,
    Bundle = bundle, Audit = audit
  )
}

gtheory_authorization_kernel_cache <- new.env(parent = emptyenv())

gtheory_authorization_kernel_result <- function() {
  if (!is.null(gtheory_authorization_kernel_cache$result)) {
    return(gtheory_authorization_kernel_cache$result)
  }
  env <- load_gtheory_authorization_kernel()
  lineage <- gtheory_authorization_kernel_lineage(env)
  worker <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-weak-information-authorization-kernel-worker-0.2.3.R"
  )
  project_root <- normalizePath(testthat::test_path("..", ".."))
  contract <- env$mfrmr_gtwao_contract(
    lineage$Contract, lineage$Manifest, lineage$Bundle, lineage$Audit, worker
  )
  preflight <- env$mfrmr_gtwao_preflight(
    contract, lineage$Audit, worker, project_root
  )
  result <- list(
    Env = env, Lineage = lineage, Worker = worker,
    ProjectRoot = project_root, Contract = contract, Preflight = preflight
  )
  gtheory_authorization_kernel_cache$result <- result
  result
}

test_that("b1g20 freezes one reusable response-free kernel contract", {
  result <- gtheory_authorization_kernel_result()
  env <- result$Env
  contract <- result$Contract
  preflight <- result$Preflight

  expect_true(env$mfrmr_gtwao_lineage_receipt_hash_valid(
    contract$LineageReceipt
  ))
  expect_true(env$mfrmr_gtwao_policy_hash_valid(contract$KernelPolicy))
  expect_true(env$mfrmr_gtwao_contract_hash_valid(contract))
  expect_true(env$mfrmr_gtwao_runtime_probe_hash_valid(
    preflight$RuntimeProbe
  ))
  expect_true(env$mfrmr_gtwao_site_probe_hash_valid(preflight$SiteProbe))
  expect_true(env$mfrmr_gtwao_mechanics_audit_hash_valid(
    preflight$MechanicsAudit
  ))
  expect_true(env$mfrmr_gtwao_preflight_hash_valid(preflight))
  expect_identical(
    contract$LineageReceipt$ReceiptHash,
    "4a453c9b44fd03ae456ba1fda2f8d65208c3ab63b23c6c51d1f6026dfe3e4e92"
  )
  expect_identical(
    contract$KernelPolicy$PolicyHash,
    "ca0b9691600d4aa1241741cb0fa8710de1ea892a8e243c323425c6b76047136c"
  )
  expect_identical(
    contract$ContractHash,
    "86a6015b1eebdb4c9cf8cfa57110d24354ec5999e62f477c82506d8cc6b1edce"
  )
  expect_identical(
    preflight$RuntimeProbe$Runtime$RuntimeHash,
    "b32aca03814bd2ae12a7475e61caa338c464a46e4bd90209b186ccc1da9383b0"
  )
  expect_identical(
    preflight$RuntimeProbe$ProbeHash,
    "53a4b57eaf4556ede168f1e686e3be87697a2b3175f464cc88090d394693715e"
  )
  expect_identical(
    preflight$MechanicsAudit$AuditHash,
    "ec573bb5e939e4bd711ae267c41894db89b14d576a19d4ac7ac45c268b3071cf"
  )
  second_runtime <- env$mfrmr_gtwao_isolated_runtime_probe(
    contract, result$Worker
  )
  expect_identical(
    second_runtime$Runtime$RuntimeHash,
    preflight$RuntimeProbe$Runtime$RuntimeHash
  )
  expect_identical(second_runtime$ProbeHash,
                   preflight$RuntimeProbe$ProbeHash)
})

test_that("b1g20 reduces infrastructure blockers to runner and record", {
  result <- gtheory_authorization_kernel_result()
  preflight <- result$Preflight
  gates <- preflight$GateRegistry

  expect_identical(nrow(gates), 11L)
  expect_identical(
    gates$GateId[gates$ObservedPass],
    c(
      "RNG-01", "LINEAGE-01", "RUNTIME-01", "THREAD-01",
      "PROCESS-01", "LOCK-01", "ROOT-01", "CAPACITY-01", "CONFIRM-01"
    )
  )
  expect_identical(preflight$KernelBlockerIds, character())
  expect_identical(
    preflight$AuthorizationBlockerIds,
    c("RUNNER-01", "AUTH-RECORD-01")
  )
  expect_true(preflight$AuthorizationKernelReady)
  expect_true(preflight$RuntimeContractExtensionReady)
  expect_true(preflight$LockRootKernelReady)
  expect_true(preflight$PerShardSitePreflightReady)
  expect_true(preflight$SiteProbe$OutputTargetAbsent)
  expect_true(preflight$SiteProbe$CapacityReady)
  expect_gte(
    preflight$SiteProbe$AvailableBytes,
    preflight$SiteProbe$RequiredAvailableBytes
  )
  expect_false(preflight$ReservedAdapterEntryPointReady)
  expect_false(preflight$AuthorizedSingleShardRunnerReady)
  expect_false(preflight$AuthorizationRecordIssued)
  expect_false(preflight$AuthorizationRNG01Closed)
  expect_false(preflight$AuthorizationActivationEligible)
  expect_false(preflight$LargeSimulationMayStart)
  expect_false(preflight$Replicate201MayBeOpened)
  expect_false(preflight$CalibrationExecutionAuthorized)
  expect_false(preflight$CalibrationDataGenerated)
  expect_false(preflight$CalibrationResultsViewed)
  expect_false(preflight$ConfirmationAuthorized)
  expect_false(preflight$InferenceReady)
  expect_false(preflight$DecisionReady)
})

test_that("b1g20 lock and root lifecycle fails closed", {
  result <- gtheory_authorization_kernel_result()
  env <- result$Env
  contract <- result$Contract
  fixture_parent <- tempfile("mfrmr-gtwao-test-")
  dir.create(fixture_parent)
  on.exit(unlink(fixture_parent, recursive = TRUE, force = TRUE), add = TRUE)
  target <- file.path(fixture_parent, "root")
  owner <- env$mfrmr_gta_hash("test-owner")
  lock <- env$mfrmr_gtwao_lock_acquire(
    target, owner, contract$KernelPolicy
  )

  expect_error(
    env$mfrmr_gtwao_lock_acquire(target, owner, contract$KernelPolicy),
    "already held"
  )
  initial <- env$mfrmr_gtwao_activate_root(
    lock, contract$ReservedManifestHash, "runtime", contract$KernelPolicy
  )
  expect_identical(initial$State, "initial_activation")
  resume <- env$mfrmr_gtwao_activate_root(
    lock, contract$ReservedManifestHash, "runtime", contract$KernelPolicy
  )
  expect_identical(resume$State, "exact_resume")
  expect_identical(initial$MarkerHash, resume$MarkerHash)

  marker_path <- file.path(
    target, contract$KernelPolicy$ActivationMarkerName
  )
  marker <- readRDS(marker_path)
  marker$ManifestHash <- "changed"
  saveRDS(marker, marker_path, version = 3L)
  expect_error(
    env$mfrmr_gtwao_activate_root(
      lock, contract$ReservedManifestHash, "runtime", contract$KernelPolicy
    ), "identity changed"
  )
  expect_true(env$mfrmr_gtwao_lock_release(lock))
  expect_false(dir.exists(lock$LockPath))
})

test_that("b1g20 records runtime drift and capacity loss as non-ready", {
  result <- gtheory_authorization_kernel_result()
  env <- result$Env
  preflight <- result$Preflight

  drift <- preflight$RuntimeProbe
  drift$Runtime$RNGKind[[1L]] <- "Wichmann-Hill"
  runtime_fields <- c(
    "Contract", "Invocation", "RVersion", "RPlatform", "RArch", "OS",
    "OSRelease", "RNGKind", "MatrixProducts", "BLAS", "LAPACK",
    "LAVersion", "Locale", "TimeZone", "LocaleEnvironment",
    "StartupEnvironment", "PackageVersions", "GLMMTMBParallel",
    "ThreadEnvironment"
  )
  drift$Runtime$RuntimeHash <- env$mfrmr_gta_hash(
    drift$Runtime[runtime_fields]
  )
  drift$ChildRuntimeHash <- drift$Runtime$RuntimeHash
  drift$RNGKindExact <- FALSE
  drift$IsolatedRuntimeReady <- FALSE
  probe_fields <- c(
    "Contract", "AuthorizationKernelContractHash", "WorkerSourceHash",
    "ChildExitStatus", "ChildOutputHash", "ChildRuntimeHash",
    "RuntimeRecordValid", "RNGKindExact", "GLMMTMBSerialExact",
    "ThreadEnvironmentExact", "LocaleEnvironmentExact",
    "StartupEnvironmentSuppressed", "VanillaInvocationObserved",
    "IsolatedRuntimeReady", "CalibrationResponsesUsed",
    "ConfirmationResponsesUsed"
  )
  drift$ProbeHash <- env$mfrmr_gta_hash(drift[probe_fields])
  expect_true(env$mfrmr_gtwao_runtime_probe_hash_valid(drift))
  expect_false(drift$RNGKindExact)
  expect_false(drift$IsolatedRuntimeReady)

  low_capacity <- preflight$SiteProbe
  low_capacity$AvailableBytes <-
    low_capacity$RequiredAvailableBytes - 1
  low_capacity$CapacityReady <- FALSE
  low_capacity$SitePreflightReady <- FALSE
  site_fields <- c(
    "Contract", "AuthorizationKernelContractHash", "OutputTargetHash",
    "OutputTargetAbsent", "ProbeDirectoryCreated", "ActualWritePassed",
    "AtomicRenamePassed", "ReadbackPassed", "ProbeCleanupPassed",
    "DfExitStatus", "DfOutputHash", "AvailableBytes",
    "RequiredAvailableBytes", "CapacityReady", "SitePreflightReady",
    "CalibrationResponsesUsed", "ConfirmationResponsesUsed"
  )
  low_capacity$ProbeHash <- env$mfrmr_gta_hash(low_capacity[site_fields])
  expect_true(env$mfrmr_gtwao_site_probe_hash_valid(low_capacity))
  expect_false(low_capacity$CapacityReady)
  expect_false(low_capacity$SitePreflightReady)

  altered_worker <- tempfile("mfrmr-gtwao-worker-", fileext = ".R")
  on.exit(unlink(altered_worker), add = TRUE)
  expect_true(file.copy(result$Worker, altered_worker))
  cat("\n# mutation\n", file = altered_worker, append = TRUE)
  expect_error(
    env$mfrmr_gtwao_contract(
      result$Lineage$Contract, result$Lineage$Manifest,
      result$Lineage$Bundle, result$Lineage$Audit, altered_worker
    ), "worker evidence"
  )
})
