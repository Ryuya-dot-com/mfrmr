load_gtheory_execution_authorization_decision <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  paths <- file.path(validation, c(
    "gtheory-design-algebra-prototype-0.2.3.R",
    "gtheory-weak-information-execution-authorization-decision-0.2.3.R"
  ))
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  skip_if_not_installed("digest")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtheory_execution_authorization_decision_result <- function() {
  env <- load_gtheory_execution_authorization_decision()
  validation <- testthat::test_path("..", "..", "inst", "validation")
  receipt <- env$mfrmr_gtwaq_parent_receipt()
  policy <- env$mfrmr_gtwaq_policy()
  source_audit <- env$mfrmr_gtwaq_source_audit(
    file.path(
      validation,
      "gtheory-weak-information-guarded-shard-runner-0.2.3.R"
    ),
    file.path(
      validation,
      "gtheory-weak-information-stationarity-exact-resume-runner-0.2.3.R"
    ),
    policy
  )
  decision <- env$mfrmr_gtwaq_decision(receipt, policy, source_audit)
  list(
    Env = env, Receipt = receipt, Policy = policy,
    SourceAudit = source_audit, Decision = decision
  )
}

test_that("b1g22 freezes one response-free authorization decision", {
  result <- gtheory_execution_authorization_decision_result()
  env <- result$Env

  expect_true(env$mfrmr_gtwaq_parent_receipt_hash_valid(result$Receipt))
  expect_true(env$mfrmr_gtwaq_policy_hash_valid(result$Policy))
  expect_true(env$mfrmr_gtwaq_source_audit_hash_valid(result$SourceAudit))
  expect_true(env$mfrmr_gtwaq_decision_hash_valid(result$Decision))
  expect_identical(
    result$Receipt$ReceiptHash,
    "2be44c3fdda1dc455a83eecdd6c0613240050db4b4aee8cb0cb47399b8d73818"
  )
  expect_identical(
    result$Policy$PolicyHash,
    "4d89c7235e9ae8537b8b9743ba356c8eaf0ad85308cd9c1cf5a4ec87cc562c04"
  )
  expect_identical(
    result$SourceAudit$AuditHash,
    "d0a59e573ef9c6fba7af5a308a58bc974b04c0a87ca74dc70de1aca39c506b07"
  )
  expect_identical(
    result$Decision$DecisionHash,
    "3df37fa52c9ff688bd5110d4ae097a8fed10123eb898f9967fdcb5fd791c9ab6"
  )
  expect_identical(result$Receipt$CandidateShardId, "R0201")
  expect_identical(result$Receipt$CandidateReplicate, 201L)
  expect_identical(
    result$Receipt$CandidateShardCounts,
    c(
      Datasets = 30L, AtomicUnits = 120L, CandidateFits = 1080L,
      CandidateDecisions = 5760L, References = 240L
    )
  )
  expect_identical(
    result$Receipt$CandidateShardManifestHash,
    "dc8c2952e2246c807e1aa03c3752ab7b66ca87e3850b5c812a27df72a19d16c9"
  )
})

test_that("b1g22 refuses issuance while three prerequisites are absent", {
  result <- gtheory_execution_authorization_decision_result()
  decision <- result$Decision
  gates <- decision$GateRegistry

  expect_identical(
    gates$GateId[gates$ObservedPass],
    c(
      "LINEAGE-01", "RUNTIME-01", "RUNNER-REDUCTION-01",
      "RUNNER-SOURCE-01", "CONFIRM-01"
    )
  )
  expect_identical(
    decision$IssuanceBlockerIds,
    c("RESERVED-ENTRY-01", "ACTIVE-MANIFEST-01", "SITE-RECEIPT-01")
  )
  expect_identical(decision$Decision, "no_go_refused_not_issued")
  expect_true(decision$AuthorizationDecisionComplete)
  expect_true(decision$Runner01Closed)
  expect_false(decision$AuthorizationIssuanceReady)
  expect_false(decision$AuthorizationRecordIssued)
  expect_false(decision$ReservedAdapterEntryPointReady)
  expect_false(decision$AuthorizedReservedManifestReady)
  expect_false(decision$FreshSiteReceiptBound)
  expect_false(decision$AuthorizationRNG01Closed)
  expect_false(decision$AuthorizationActivationEligible)
  expect_false(decision$LargeSimulationMayStart)
  expect_false(decision$Replicate201MayBeOpened)
  expect_false(decision$CalibrationExecutionAuthorized)
  expect_false(decision$CalibrationDataGenerated)
  expect_false(decision$CalibrationResultsViewed)
  expect_false(decision$ConfirmationAuthorized)
  expect_false(decision$InferenceReady)
  expect_false(decision$DecisionReady)
  expect_identical(
    decision$NextImplementationRequired,
    "record_bound_reserved_entry_point_and_active_one_shard_manifest"
  )
})

test_that("b1g22 source audit observes both reserved execution stops", {
  result <- gtheory_execution_authorization_decision_result()
  audit <- result$SourceAudit

  expect_true(audit$GuardedSourceExact)
  expect_true(audit$ExactResumeSourceExact)
  expect_true(audit$GuardedReservedStopPresent)
  expect_true(audit$GuardedUsesNonreservedRunner)
  expect_true(audit$ExactRunnerReservedGuardPresent)
  expect_true(audit$ExactRunnerNonreservedMessagePresent)
  expect_false(audit$RecordBoundReservedEntryPointFound)
  expect_false(audit$ExecutableReservedManifestConversionFound)
  expect_false(audit$CalibrationResponsesUsed)
  expect_false(audit$ConfirmationResponsesUsed)
})

test_that("b1g22 rejects receipt policy source and decision mutations", {
  result <- gtheory_execution_authorization_decision_result()
  env <- result$Env

  bad_receipt <- result$Receipt
  bad_receipt$ReservedAdapterEntryPointReady <- TRUE
  expect_false(env$mfrmr_gtwaq_parent_receipt_hash_valid(bad_receipt))

  bad_policy <- result$Policy
  bad_policy$MaximumAuthorizedShardCount <- 2L
  expect_false(env$mfrmr_gtwaq_policy_hash_valid(bad_policy))

  bad_source <- result$SourceAudit
  bad_source$RecordBoundReservedEntryPointFound <- TRUE
  expect_false(env$mfrmr_gtwaq_source_audit_hash_valid(bad_source))

  bad_decision <- result$Decision
  bad_decision$AuthorizationRecordIssued <- TRUE
  expect_false(env$mfrmr_gtwaq_decision_hash_valid(bad_decision))

  bad_gate <- result$Decision
  bad_gate$GateRegistry$ObservedPass[
    bad_gate$GateRegistry$GateId == "RESERVED-ENTRY-01"
  ] <- TRUE
  expect_false(env$mfrmr_gtwaq_decision_hash_valid(bad_gate))
})
