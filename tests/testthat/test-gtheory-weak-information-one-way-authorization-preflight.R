gtheory_one_way_authorization_paths <- function() {
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
    "gtheory-weak-information-one-way-authorization-preflight-0.2.3.R"
  ))
}

load_gtheory_one_way_authorization <- function() {
  paths <- gtheory_one_way_authorization_paths()
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

gtheory_one_way_authorization_objects <- function(env, probe = TRUE) {
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
  contract <- env$mfrmr_gtwai_contract(adapter, reserved)
  shards <- env$mfrmr_gtwai_shard_bundle(contract, reserved, sealed)
  result <- list(
    Design = design, Sealed = sealed, Adapter = adapter,
    Reserved = reserved, Contract = contract, Shards = shards
  )
  if (isTRUE(probe)) {
    package_root <- normalizePath(
      testthat::test_path("..", ".."), mustWork = TRUE
    )
    filesystem <- env$mfrmr_gtwai_filesystem_probe(
      contract, reserved, package_root
    )
    projection <- env$mfrmr_gtwai_resource_projection(contract, filesystem)
    audit <- env$mfrmr_gtwai_audit(
      contract, reserved, shards, filesystem
    )
    result$Filesystem <- filesystem
    result$Projection <- projection
    result$Audit <- audit
  }
  result
}

gtheory_one_way_authorization_cache <- new.env(parent = emptyenv())

gtheory_one_way_authorization_cached <- function() {
  if (!is.null(gtheory_one_way_authorization_cache$result)) {
    return(gtheory_one_way_authorization_cache$result)
  }
  env <- load_gtheory_one_way_authorization()
  objects <- gtheory_one_way_authorization_objects(env)
  result <- list(Env = env, Objects = objects)
  gtheory_one_way_authorization_cache$result <- result
  result
}

test_that("b1g15 freezes only the authorization-preflight contract", {
  env <- load_gtheory_one_way_authorization()
  objects <- gtheory_one_way_authorization_objects(env, probe = FALSE)
  contract <- objects$Contract

  expect_s3_class(contract, "mfrmr_gtwai_contract")
  expect_s3_class(contract, "mfrmr_gtwah_contract")
  expect_s3_class(contract, "mfrmr_gtwag_contract")
  expect_true(env$mfrmr_gtwai_contract_hash_valid(contract))
  expect_identical(
    contract$UpstreamAdapterContractHash,
    "baf48a948b86c1769aba8a574619c6ce57be17b4b5747ae935f0e430392518a1"
  )
  expect_identical(
    contract$UpstreamReservedManifestHash,
    "019fedf063ce90c3492f9eb37f6dbec43a42474ce9096e7cc2891491d7a158c8"
  )
  expect_identical(
    contract$UpstreamAdapterPreflightHash,
    "eddbe9cb3e1ab56d3389f9f896524f0bf0ae92b224b2997f4e5f6014219a31cf"
  )
  expect_true(env$mfrmr_gtwai_policy_hash_valid(
    contract$AuthorizationPolicy
  ))
  expect_true(env$mfrmr_gtwai_measurement_hash_valid(contract$Measurement))
  expect_identical(length(env$mfrmr_gtwai_function_hashes()), 19L)
  expect_true(contract$AuthorizationPreflightContractFrozen)
  expect_false(contract$ProspectiveShardManifestsFrozen)
  expect_false(contract$FilesystemPreflightReady)
  expect_false(contract$CapacityPreflightReady)
  expect_false(contract$SchedulingPlanFrozen)
  expect_false(contract$AuthorizationReadinessAuditReady)
  expect_false(contract$AuthorizationActivationEligible)
  expect_false(contract$ExecutionAuthorizationRecordIssued)
  expect_false(contract$CalibrationAuthorizationReady)
  expect_false(contract$CalibrationExecutionAuthorized)
  expect_false(contract$CalibrationDataGenerated)
  expect_false(contract$CalibrationResultsViewed)
  expect_false(contract$ConfirmationAuthorized)
  expect_false(contract$InferenceReady)
  expect_false(contract$CoefficientEligible)
  expect_false(contract$DecisionReady)
})

test_that("b1g15 resource measurement is nonreserved and planning-only", {
  env <- load_gtheory_one_way_authorization()
  measurement <- env$mfrmr_gtwai_measurement_receipt()

  expect_true(env$mfrmr_gtwai_measurement_hash_valid(measurement))
  expect_identical(measurement$Replicate, 902L)
  expect_identical(measurement$AtomicUnitCount, 4L)
  expect_identical(measurement$CheckpointBytes,
                   c(2955, 2969, 3573, 3588))
  expect_identical(measurement$DatasetMarkerBytes, 671)
  expect_identical(measurement$CombinedLedgerObjectBytes, 124728)
  expect_equal(sum(measurement$ElapsedSecondsByMethod), 89.047,
               tolerance = 1e-12)
  expect_false(measurement$RuntimeGuarantee)
  expect_false(measurement$CalibrationResponsesUsed)
  expect_false(measurement$ConfirmationResponsesUsed)

  changed <- measurement
  changed$CheckpointBytes[[1L]] <- changed$CheckpointBytes[[1L]] + 1
  expect_false(env$mfrmr_gtwai_measurement_hash_valid(changed))
})

test_that("b1g15 freezes 100 exact prospective non-executable shards", {
  result <- gtheory_one_way_authorization_cached()
  env <- result$Env
  bundle <- result$Objects$Shards

  expect_true(env$mfrmr_gtwai_shard_bundle_hash_valid(bundle))
  expect_identical(bundle$ShardCount, 100L)
  expect_identical(bundle$DatasetCount, 3000L)
  expect_identical(bundle$AtomicUnitCount, 12000L)
  expect_identical(bundle$CandidateFitRowCount, 108000L)
  expect_identical(bundle$CandidateDecisionRowCount, 576000L)
  expect_identical(bundle$ReferenceRowCount, 24000L)
  expect_identical(bundle$Registry$ShardId, sprintf("R%04d", 201:300))
  expect_identical(bundle$Registry$Replicate, 201:300)
  expect_true(all(bundle$Registry$DatasetCount == 30L))
  expect_true(all(bundle$Registry$AtomicUnitCount == 120L))
  expect_true(all(bundle$Registry$CandidateFitRowCount == 1080L))
  expect_true(all(bundle$Registry$CandidateDecisionRowCount == 5760L))
  expect_true(all(bundle$Registry$ReferenceRowCount == 240L))
  expect_true(all(!bundle$Registry$ExecutionAuthorized))
  expect_false(bundle$ExecutionAuthorized)
  expect_false(bundle$CalibrationExecutionAuthorized)
  expect_false(bundle$CalibrationDataGenerated)
  expect_false(bundle$CalibrationResultsViewed)

  first <- bundle$Manifests[[1L]]
  expect_true(env$mfrmr_gtwai_shard_manifest_hash_valid(first))
  expect_identical(first$ShardId, "R0201")
  expect_identical(first$Replicate, 201L)
  expect_identical(length(unique(first$Units$DatasetId)), 30L)
  expect_true(all(table(first$Units$DatasetId) == 4L))
  expect_true(all(first$Units$Replicate == 201L))
  expect_true(all(!first$Units$ExecutionAuthorized))
  expect_true(first$ReservedCalibrationUse)
  expect_false(first$ConfirmationUse)
  expect_false(first$EarlyStoppingPermitted)
  expect_false(first$ExecutionAuthorized)
  expect_false(first$CalibrationExecutionAuthorized)
  expect_match(first$OutputSubdirectory, "shards/R0201$|shards\\\\R0201$")
})

test_that("b1g15 shard identities and reserved adapter firewall fail closed", {
  result <- gtheory_one_way_authorization_cached()
  env <- result$Env
  objects <- result$Objects
  bundle <- objects$Shards
  changed_manifest <- bundle$Manifests[[1L]]
  changed_manifest$Units$ExecutionAuthorized[[1L]] <- TRUE
  expect_false(env$mfrmr_gtwai_shard_manifest_hash_valid(changed_manifest))

  changed_bundle <- bundle
  changed_bundle$CandidateFitRowCount <- 107999L
  expect_false(env$mfrmr_gtwai_shard_bundle_hash_valid(changed_bundle))

  reserved_unit <- bundle$Manifests[[1L]]$Units[1L, , drop = FALSE]
  expect_error(
    env$mfrmr_gtwah_candidate_evaluator(objects$Contract, reserved_unit),
    "not authorized"
  )
  expect_error(
    env$mfrmr_gtwah_reference_evaluator(objects$Contract, reserved_unit),
    "not authorized"
  )
  expect_error(
    env$mfrmr_gtwag_execute(
      objects$Contract, bundle$Manifests[[1L]], tempfile("forbidden-")
    ),
    "Only the exact nonreserved"
  )
})

test_that("b1g15 parses POSIX df accounting and rejects malformed rows", {
  env <- load_gtheory_one_way_authorization()
  parsed <- env$mfrmr_gtwai_parse_df(c(
    "Filesystem 1024-blocks Used Available Capacity Mounted on",
    "/dev/example 100000 25000 75000 25% /example mount"
  ))

  expect_identical(parsed$Filesystem, "/dev/example")
  expect_identical(parsed$BlocksKiB, 100000)
  expect_identical(parsed$UsedKiB, 25000)
  expect_identical(parsed$AvailableKiB, 75000)
  expect_identical(parsed$Capacity, "25%")
  expect_identical(parsed$MountPoint, "/example mount")
  expect_error(env$mfrmr_gtwai_parse_df("header only"), "header and data")
  expect_error(
    env$mfrmr_gtwai_parse_df(c("header", "/dev/x bad 1 2 3 /")),
    "capacity fields"
  )
  expect_error(
    env$mfrmr_gtwai_parse_df(c("header", "/dev/x 1 -1 2 3 /")),
    "capacity fields"
  )
})

test_that("b1g15 probes the actual output parent without creating target", {
  result <- gtheory_one_way_authorization_cached()
  env <- result$Env
  objects <- result$Objects
  probe <- objects$Filesystem

  expect_true(env$mfrmr_gtwai_filesystem_probe_hash_valid(probe))
  expect_true(probe$FilesystemProbeReady)
  expect_true(probe$OutputTargetAbsentBeforeProbe)
  expect_true(probe$OutputParentExists)
  expect_true(probe$ProbeDirectoryCreated)
  expect_true(probe$ActualWritePassed)
  expect_true(probe$SameDirectoryRename)
  expect_true(probe$AtomicRenamePassed)
  expect_true(probe$ReadbackPassed)
  expect_true(probe$ProbeCleanupPassed)
  expect_identical(probe$DfExitStatus, 0L)
  expect_true(is.finite(probe$AvailableBytes))
  expect_gt(probe$AvailableBytes, 0)
  expect_false(probe$CalibrationExecutionAuthorized)
  expect_false(probe$CalibrationDataGenerated)
  expect_false(probe$CalibrationResultsViewed)
  expect_false(dir.exists(file.path(probe$ProjectRoot, probe$OutputRoot)))
  expect_length(list.files(
    dirname(file.path(probe$ProjectRoot, probe$OutputRoot)),
    pattern = "^\\.mfrmr-gtwai-"
  ), 0L)

  fake_root <- tempfile("mfrmr-gtwai-fake-root-")
  dir.create(file.path(fake_root, "validation-results"), recursive = TRUE)
  on.exit(unlink(fake_root, recursive = TRUE, force = TRUE), add = TRUE)
  fake_target <- file.path(fake_root, objects$Reserved$OutputRoot)
  dir.create(fake_target, recursive = TRUE)
  blocked <- env$mfrmr_gtwai_filesystem_probe(
    objects$Contract, objects$Reserved, fake_root,
    require_package_root = FALSE
  )
  expect_true(env$mfrmr_gtwai_filesystem_probe_hash_valid(blocked))
  expect_false(blocked$OutputTargetAbsentBeforeProbe)
  expect_false(blocked$FilesystemProbeReady)
  expect_true(dir.exists(fake_target))
})

test_that("b1g15 resource and authorization-readiness audit remain nonexecuting", {
  result <- gtheory_one_way_authorization_cached()
  env <- result$Env
  objects <- result$Objects
  projection <- objects$Projection
  audit <- objects$Audit

  expect_true(env$mfrmr_gtwai_resource_projection_hash_valid(projection))
  expect_identical(
    projection$RawProjectedDiskBytes,
    3588 * 12000 + 671 * 3000 + 124728 * 3000
  )
  expect_identical(projection$DiskSafetyMultiplier, 32)
  expect_identical(projection$MinimumResidualFreeBytes, 32 * 1024^3)
  expect_equal(projection$ObservedSerialHours, 74.2058333333333,
               tolerance = 1e-10)
  expect_equal(projection$PlanningSerialHours, 296.823333333333,
               tolerance = 1e-10)
  expect_equal(projection$PlanningShardHours, 2.96823333333333,
               tolerance = 1e-10)
  expect_identical(projection$MaxConcurrentShards, 1L)
  expect_false(projection$RuntimeGuarantee)
  expect_true(projection$CapacityPreflightReady)
  expect_true(projection$SchedulingPlanFrozen)
  expect_true(projection$ResourceProjectionReady)
  expect_false(projection$CalibrationExecutionAuthorized)

  expect_true(env$mfrmr_gtwai_audit_hash_valid(audit))
  expect_identical(
    audit$ExactCounts,
    c(
      Shards = 100L, Datasets = 3000L, AtomicUnits = 12000L,
      CandidateFits = 108000L, CandidateDecisions = 576000L,
      References = 24000L
    )
  )
  expect_true(audit$RuntimeHashMatch)
  expect_true(audit$AuthorizationFirewallIntact)
  expect_true(audit$ProspectiveShardManifestsFrozen)
  expect_true(audit$FilesystemPreflightReady)
  expect_true(audit$CapacityPreflightReady)
  expect_true(audit$SchedulingPlanFrozen)
  expect_true(audit$AuthorizationReadinessAuditReady)
  expect_true(audit$AuthorizationActivationEligible)
  expect_false(audit$ExecutionAuthorizationRecordIssued)
  expect_false(audit$CalibrationAuthorizationReady)
  expect_false(audit$CalibrationExecutionAuthorized)
  expect_false(audit$CalibrationDataGenerated)
  expect_false(audit$CalibrationResultsViewed)
  expect_false(audit$StationarityThresholdFrozen)
  expect_false(audit$StationarityCriterionReady)
  expect_false(audit$ConfirmationAuthorized)
  expect_false(audit$InferenceReady)
  expect_false(audit$CoefficientEligible)
  expect_false(audit$DecisionReady)
})

test_that("b1g15 low capacity and mutable readiness cannot pass", {
  result <- gtheory_one_way_authorization_cached()
  env <- result$Env
  objects <- result$Objects
  low <- objects$Filesystem
  low$AvailableBytes <- objects$Projection$RequiredAvailableBytes - 1
  identity_names <- names(low)[seq_len(match("ProbeHash", names(low)) - 1L)]
  low$ProbeHash <- env$mfrmr_gta_hash(low[identity_names])
  expect_true(env$mfrmr_gtwai_filesystem_probe_hash_valid(low))

  projection <- env$mfrmr_gtwai_resource_projection(objects$Contract, low)
  expect_true(env$mfrmr_gtwai_resource_projection_hash_valid(projection))
  expect_false(projection$CapacityPreflightReady)
  expect_false(projection$ResourceProjectionReady)

  audit <- env$mfrmr_gtwai_audit(
    objects$Contract, objects$Reserved, objects$Shards, low
  )
  expect_true(env$mfrmr_gtwai_audit_hash_valid(audit))
  expect_false(audit$CapacityPreflightReady)
  expect_false(audit$AuthorizationReadinessAuditReady)
  expect_false(audit$AuthorizationActivationEligible)
  expect_false(audit$CalibrationExecutionAuthorized)

  audit$AuthorizationActivationEligible <- TRUE
  expect_false(env$mfrmr_gtwai_audit_hash_valid(audit))
})
