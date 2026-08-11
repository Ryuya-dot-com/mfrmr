gtheory_one_shard_issuance_helper_env <- function() {
  parent_test <- testthat::test_path(
    "test-gtheory-weak-information-record-bound-entry-point.R"
  )
  skip_if_not(file.exists(parent_test),
              "the b1g23 test helper is excluded")
  expressions <- parse(parent_test)
  first_test <- which(vapply(expressions, function(expression) {
    is.call(expression) && identical(expression[[1L]], as.name("test_that"))
  }, logical(1L)))[1L]
  skip_if_not(is.finite(first_test), "the b1g23 helper boundary is absent")
  helper <- new.env(parent = globalenv())
  for (index in seq_len(first_test - 1L)) {
    eval(expressions[[index]], envir = helper)
  }
  helper
}

load_gtheory_one_shard_issuance <- function() {
  helper <- gtheory_one_shard_issuance_helper_env()
  env <- helper$load_gtheory_record_bound_entry()
  source_path <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-weak-information-one-shard-issuance-0.2.3.R"
  )
  skip_if_not(file.exists(source_path),
              "the repository-internal issuance layer is excluded")
  sys.source(source_path, envir = env)
  list(Env = env, Helper = helper, SourcePath = source_path)
}

gtheory_one_shard_issuance_objects <- function(loaded) {
  builder <- loaded$Helper$gtheory_record_bound_entry_objects
  builder_body <- body(builder)
  final_call <- builder_body[[length(builder_body)]]
  final_call[["Kernel"]] <- quote(kernel)
  final_call[["KernelWorker"]] <- quote(kernel_worker)
  final_call[["ProjectRoot"]] <- quote(project_root)
  final_call[["ShardBundle"]] <- quote(shard_bundle)
  builder_body[[length(builder_body)]] <- final_call
  body(builder) <- builder_body
  objects <- builder(loaded$Env)
  validation <- dirname(loaded$SourcePath)
  issuance <- loaded$Env$mfrmr_gtwas_contract(
    objects$Contract, objects$Prospective, objects$Kernel, validation
  )
  c(objects, list(Issuance = issuance, Validation = validation))
}

gtheory_one_shard_issuance_cache <- new.env(parent = emptyenv())

gtheory_one_shard_issuance_result <- function() {
  if (!is.null(gtheory_one_shard_issuance_cache$result)) {
    return(gtheory_one_shard_issuance_cache$result)
  }
  loaded <- load_gtheory_one_shard_issuance()
  objects <- gtheory_one_shard_issuance_objects(loaded)
  env <- loaded$Env
  preflight <- env$mfrmr_gtwas_preflight(
    objects$Issuance, objects$Contract, objects$Prospective,
    objects$Kernel, objects$KernelWorker, objects$ProjectRoot
  )
  record <- env$mfrmr_gtwas_issue_record(
    objects$Issuance, objects$Contract, objects$Prospective, preflight
  )
  active <- env$mfrmr_gtwar_active_manifest(
    objects$Contract, objects$Prospective, record
  )
  audit <- env$mfrmr_gtwas_audit(
    objects$Issuance, objects$Contract, objects$Prospective, preflight,
    record, active
  )
  result <- list(
    Env = env, Objects = objects, Preflight = preflight, Record = record,
    Active = active, Audit = audit
  )
  gtheory_one_shard_issuance_cache$result <- result
  result
}

test_that("b1g24 issues exactly one response-free R0201 record", {
  result <- gtheory_one_shard_issuance_result()
  env <- result$Env
  objects <- result$Objects
  contract <- objects$Issuance
  preflight <- result$Preflight
  record <- result$Record
  active <- result$Active
  audit <- result$Audit

  expect_true(env$mfrmr_gtwas_policy_hash_valid(contract$IssuancePolicy))
  expect_true(env$mfrmr_gtwas_contract_hash_valid(contract))
  expect_identical(
    contract$IssuancePolicy$SourceHash,
    "c93287f1e813bb3dd7265179f6adbe8742486b1f32ec7235297f8b8820a5700f"
  )
  expect_identical(
    contract$IssuancePolicy$PolicyHash,
    "688b30494612169df6db370da5460b24f8606106acf695a5921aeab217eb186e"
  )
  expect_identical(
    contract$ContractHash,
    "b9af6f03b4b3f0a34d1e8e33c6feb5a8ff62ef6516b78f136772cae79eacc620"
  )
  expect_true(env$mfrmr_gtwas_decision_hash_valid(
    preflight$Decision, contract, objects$Contract, objects$Prospective,
    preflight$RuntimeReceipt, preflight$SiteReceipt,
    preflight$OutputTarget
  ))
  expect_true(env$mfrmr_gtwar_issuance_decision_hash_valid(
    preflight$Decision, objects$Contract, objects$Prospective,
    preflight$RuntimeReceipt, preflight$SiteReceipt,
    preflight$OutputTarget
  ))
  expect_true(env$mfrmr_gtwas_preflight_hash_valid(
    preflight, contract, objects$Contract, objects$Prospective
  ))
  expect_true(env$mfrmr_gtwar_authorization_record_hash_valid(
    record, objects$Contract, objects$Prospective
  ))
  expect_true(env$mfrmr_gtwar_active_manifest_hash_valid(
    active, objects$Contract
  ))
  expect_true(env$mfrmr_gtwas_audit_hash_valid(
    audit, contract, objects$Contract, objects$Prospective, preflight,
    record, active
  ))
  expect_identical(
    preflight$Decision$GateRegistry$GateId,
    c(
      "ENTRY-01", "ACTIVE-CONVERSION-01", "RUNTIME-01",
      "SITE-RECEIPT-01", "SCOPE-01", "CONFIRM-01"
    )
  )
  expect_true(all(preflight$Decision$GateRegistry$ObservedPass))
  expect_identical(
    preflight$Decision$Decision,
    "go_one_shard_record_may_be_issued"
  )
  expect_identical(record$ShardId, "R0201")
  expect_identical(record$Replicate, 201L)
  expect_identical(record$MaximumShardCount, 1L)
  expect_true(record$CompleteFailureDenominatorRequired)
  expect_false(record$EarlyStoppingPermitted)
  expect_false(record$ConfirmationUse)
  expect_identical(active$ExecutionMode,
                   "authorized_reserved_single_shard")
  expect_identical(c(
    Datasets = active$DatasetCount,
    AtomicUnits = active$AtomicUnitCount,
    CandidateFits = active$CandidateFitRowCount,
    CandidateDecisions = active$CandidateDecisionRowCount,
    References = active$ReferenceRowCount
  ), c(
    Datasets = 30L, AtomicUnits = 120L, CandidateFits = 1080L,
    CandidateDecisions = 5760L, References = 240L
  ))
  expect_true(all(active$Units$ExecutionAuthorized))
  expect_true(all(active$Units$ReservedCalibrationUse))
  expect_true(all(
    active$Units$AtomicUnitIdentityHash !=
      active$Units$PriorAtomicUnitIdentityHash
  ))
  expect_false(any(active$Units$ResponseGenerated))
  expect_false(any(active$Units$PreFitComputed))
  expect_false(any(active$Units$CheckpointCreated))
  expect_true(audit$Replicate201MayBeOpened)
  expect_true(audit$OneShardExecutionAuthorized)
  expect_false(audit$LargeSimulationMayStart)
  expect_false(audit$CalibrationExecutionStarted)
  expect_false(audit$CalibrationDataGenerated)
  expect_false(audit$CalibrationResultsViewed)
  expect_false(audit$ConfirmationAuthorized)
  expect_false(file.exists(preflight$OutputTarget))
  expect_false(dir.exists(preflight$OutputTarget))
})

test_that("b1g24 preserves a valid auditable no-go preflight", {
  result <- gtheory_one_shard_issuance_result()
  env <- result$Env
  objects <- result$Objects
  root <- tempfile("mfrmr-gtwas-no-go-")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
  file.create(file.path(root, "DESCRIPTION"))
  occupied_target <- file.path(root, objects$Kernel$OutputRoot)
  dir.create(occupied_target, recursive = TRUE)

  preflight <- env$mfrmr_gtwas_preflight(
    objects$Issuance, objects$Contract, objects$Prospective,
    objects$Kernel, objects$KernelWorker, root
  )
  expect_true(env$mfrmr_gtwas_preflight_hash_valid(
    preflight, objects$Issuance, objects$Contract, objects$Prospective
  ))
  expect_false(preflight$IssuanceReady)
  expect_false(preflight$Decision$IssuanceReady)
  expect_false(preflight$Decision$GateRegistry$ObservedPass[[4L]])
  expect_identical(preflight$Decision$Decision,
                   "no_go_record_must_not_be_issued")
  expect_true(env$mfrmr_gtwas_decision_hash_valid(
    preflight$Decision, objects$Issuance, objects$Contract,
    objects$Prospective, preflight$RuntimeReceipt,
    preflight$SiteReceipt, preflight$OutputTarget
  ))
  expect_false(env$mfrmr_gtwar_issuance_decision_hash_valid(
    preflight$Decision, objects$Contract, objects$Prospective,
    preflight$RuntimeReceipt, preflight$SiteReceipt,
    preflight$OutputTarget
  ))
  expect_error(
    env$mfrmr_gtwas_issue_record(
      objects$Issuance, objects$Contract, objects$Prospective, preflight
    ),
    "six fresh one-shard issuance gates"
  )
})

test_that("b1g24 rejects decision record manifest and audit mutation", {
  result <- gtheory_one_shard_issuance_result()
  env <- result$Env
  objects <- result$Objects

  bad_decision <- result$Preflight$Decision
  bad_decision$GateRegistry$ObservedPass[[1L]] <- FALSE
  expect_false(env$mfrmr_gtwas_decision_hash_valid(
    bad_decision, objects$Issuance, objects$Contract,
    objects$Prospective, result$Preflight$RuntimeReceipt,
    result$Preflight$SiteReceipt, result$Preflight$OutputTarget
  ))
  alternative <- objects$ShardBundle$Manifests[["R0202"]]
  expect_error(
    env$mfrmr_gtwas_decision(
      objects$Issuance, objects$Contract, alternative,
      result$Preflight$RuntimeReceipt, result$Preflight$SiteReceipt,
      result$Preflight$OutputTarget
    ),
    "Exact b1g23 and b1g24 inputs"
  )
  expect_false(env$mfrmr_gtwas_decision_hash_valid(
    result$Preflight$Decision, objects$Issuance, objects$Contract,
    alternative, result$Preflight$RuntimeReceipt,
    result$Preflight$SiteReceipt, result$Preflight$OutputTarget
  ))
  bad_record <- result$Record
  bad_record$MaximumShardCount <- 2L
  expect_false(env$mfrmr_gtwar_authorization_record_hash_valid(
    bad_record, objects$Contract, objects$Prospective
  ))
  bad_manifest <- result$Active
  bad_manifest$Units$AtomicUnitIdentityHash[[1L]] <- "changed"
  expect_false(env$mfrmr_gtwar_active_manifest_hash_valid(
    bad_manifest, objects$Contract
  ))
  bad_audit <- result$Audit
  bad_audit$LargeSimulationMayStart <- TRUE
  expect_false(env$mfrmr_gtwas_audit_hash_valid(
    bad_audit, objects$Issuance, objects$Contract, objects$Prospective,
    result$Preflight, result$Record, result$Active
  ))
})
