# Draft.83d2b2b1g22 response-free execution-authorization decision.
#
# This audit decides whether an immutable authorization record may be issued
# after b1g21.  It cannot generate responses, activate the reserved root, or
# convert a prospective shard manifest into an executable manifest.

mfrmr_gtwaq_require_primitives <- function() {
  required <- "mfrmr_gta_hash"
  audit_environment <- environment(mfrmr_gtwaq_require_primitives)
  if (!exists(required, envir = audit_environment, inherits = TRUE)) {
    stop("Source the G-theory algebra hash primitive before b1g22.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtwaq_sha256_file <- function(path) {
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  unname(digest::digest(file = path, algo = "sha256", serialize = FALSE))
}

mfrmr_gtwaq_parent_receipt <- function() {
  identity <- list(
    Contract = "guarded_runner_evidence_receipt_b1g22_v1",
    HardenedLineageContractHash =
      "5075f23a5af8edb7d77ff3cd4c4efaad4d7a624995c3ee04a62ed04a2bee49f5",
    ReservedManifestHash =
      "da3905e9b9a605f42e877f695226a0c5ee7089cc04f68ad7ee6350de25c9cbd6",
    ShardBundleHash =
      "634159d6d85ea04ecf9447330af122c01284644211aa2dd78d85ab34a92661df",
    CandidateShardId = "R0201", CandidateReplicate = 201L,
    CandidateShardManifestHash =
      "dc8c2952e2246c807e1aa03c3752ab7b66ca87e3850b5c812a27df72a19d16c9",
    CandidateShardCounts = c(
      Datasets = 30L, AtomicUnits = 120L, CandidateFits = 1080L,
      CandidateDecisions = 5760L, References = 240L
    ),
    AuthorizationKernelContractHash =
      "86a6015b1eebdb4c9cf8cfa57110d24354ec5999e62f477c82506d8cc6b1edce",
    IsolatedRuntimeHash =
      "b32aca03814bd2ae12a7475e61caa338c464a46e4bd90209b186ccc1da9383b0",
    GuardedRunnerPolicyHash =
      "ecdf55015369c04e9ec81549fe68a624d0c0a025a154f28eeedc3adbd41d86aa",
    GuardedRunnerContractHash =
      "f6d932f5261b3816bd16afa820cc2c36acf188d5144277b22623a9b41245f552",
    GuardedFixtureManifestHash =
      "0a515e0977774887094321284a723e058d9b1723f3d45f505245429dc93d6db3",
    GuardedRunnerSourceHash =
      "b179c44076107c64e0f7d030585d38dec11bffba5231dcf4a702631a11742e1c",
    GuardedWorkerSourceHash =
      "8a7bfbe987a4178f83351508d29defeb631acb9f3cd9c1f724ae85d68fbf2df7",
    GuardedContractDocumentHash =
      "ecdb4bb6d82bf947d1df991d1797d37a89a8e73611a90483e147674ef873cefa",
    GuardedRecordDocumentHash =
      "f2fd67921cb968aca13f3dda5dc55ca333855290465881100f8df33ce1d593d0",
    GuardedFocusedTestHash =
      "e04dc30191d6031555d4eab22eeb52853fcf935c0f3b8b557c1d3df85bfc407d",
    Runner01Closed = TRUE,
    GuardedNonreservedReductionReady = TRUE,
    ReservedAdapterEntryPointReady = FALSE,
    AuthorizedReservedManifestReady = FALSE,
    FreshSiteReceiptBound = FALSE,
    AuthorizationRecordIssued = FALSE,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    ReceiptHash = mfrmr_gta_hash(identity), ReceiptFrozen = TRUE
  )), class = "mfrmr_gtwaq_parent_receipt")
}

mfrmr_gtwaq_parent_receipt_hash_valid <- function(receipt) {
  expected <- mfrmr_gtwaq_parent_receipt()
  fields <- setdiff(names(expected), c("ReceiptHash", "ReceiptFrozen"))
  inherits(receipt, "mfrmr_gtwaq_parent_receipt") &&
    all(fields %in% names(receipt)) &&
    identical(receipt$ReceiptHash, mfrmr_gta_hash(receipt[fields])) &&
    identical(receipt[fields], expected[fields]) &&
    identical(receipt$ReceiptHash, expected$ReceiptHash) &&
    isTRUE(receipt$ReceiptFrozen) && isTRUE(receipt$Runner01Closed) &&
    isTRUE(receipt$GuardedNonreservedReductionReady) &&
    !isTRUE(receipt$ReservedAdapterEntryPointReady) &&
    !isTRUE(receipt$AuthorizedReservedManifestReady) &&
    !isTRUE(receipt$FreshSiteReceiptBound) &&
    !isTRUE(receipt$AuthorizationRecordIssued) &&
    !isTRUE(receipt$CalibrationResponsesUsed) &&
    !isTRUE(receipt$ConfirmationResponsesUsed)
}

mfrmr_gtwaq_policy <- function() {
  identity <- list(
    Contract = "execution_authorization_decision_policy_b1g22_v1",
    CandidateShardId = "R0201", CandidateReplicate = 201L,
    MaximumAuthorizedShardCount = 1L,
    RequiredCandidateShardCounts = c(
      Datasets = 30L, AtomicUnits = 120L, CandidateFits = 1080L,
      CandidateDecisions = 5760L, References = 240L
    ),
    ReservedCalibrationReplicates = 201:300,
    ConfirmationReplicates = 501:700,
    RequiredGuardedRunnerSourceHash =
      "b179c44076107c64e0f7d030585d38dec11bffba5231dcf4a702631a11742e1c",
    RequiredExactResumeRunnerSourceHash =
      "7ebaa21434bf5be2af4a530383081989fc835778e86345e9bcec96c900271271",
    RequiredEntryPointState = "record_bound_reserved_only",
    RequiredManifestState = "one_exact_shard_executable_only",
    FreshSiteReceiptRequiredAtIssuance = TRUE,
    ExactRuntimeReceiptRequiredAtIssuance = TRUE,
    ExclusiveLockRequiredAtExecution = TRUE,
    ActivationMarkerRequiredAtExecution = TRUE,
    CompleteFailureDenominatorRequired = TRUE,
    EarlyStoppingPermitted = FALSE,
    ConfirmationAccessPermitted = FALSE,
    IssuanceWhenAnyPrerequisiteFails = "prohibited",
    ResponseGenerationPermittedDuringDecision = FALSE,
    ModelFittingPermittedDuringDecision = FALSE
  )
  structure(c(identity, list(
    PolicyHash = mfrmr_gta_hash(identity), PolicyFrozen = TRUE
  )), class = "mfrmr_gtwaq_policy")
}

mfrmr_gtwaq_policy_hash_valid <- function(policy) {
  if (!inherits(policy, "mfrmr_gtwaq_policy") ||
      !isTRUE(policy$PolicyFrozen) || is.null(policy$PolicyHash)) return(FALSE)
  identity <- unclass(policy)
  identity$PolicyHash <- NULL
  identity$PolicyFrozen <- NULL
  identical(policy$PolicyHash, mfrmr_gta_hash(identity)) &&
    identical(policy$CandidateShardId, "R0201") &&
    identical(policy$CandidateReplicate, 201L) &&
    identical(policy$MaximumAuthorizedShardCount, 1L) &&
    identical(policy$ReservedCalibrationReplicates, 201:300) &&
    identical(policy$ConfirmationReplicates, 501:700) &&
    isTRUE(policy$FreshSiteReceiptRequiredAtIssuance) &&
    isTRUE(policy$ExactRuntimeReceiptRequiredAtIssuance) &&
    isTRUE(policy$CompleteFailureDenominatorRequired) &&
    identical(policy$IssuanceWhenAnyPrerequisiteFails, "prohibited") &&
    !isTRUE(policy$EarlyStoppingPermitted) &&
    !isTRUE(policy$ConfirmationAccessPermitted) &&
    !isTRUE(policy$ResponseGenerationPermittedDuringDecision) &&
    !isTRUE(policy$ModelFittingPermittedDuringDecision)
}

mfrmr_gtwaq_source_audit <- function(guarded_runner_path,
                                      exact_resume_runner_path,
                                      policy = mfrmr_gtwaq_policy()) {
  if (!mfrmr_gtwaq_policy_hash_valid(policy)) {
    stop("The frozen b1g22 decision policy is required.", call. = FALSE)
  }
  guarded_hash <- mfrmr_gtwaq_sha256_file(guarded_runner_path)
  exact_hash <- mfrmr_gtwaq_sha256_file(exact_resume_runner_path)
  guarded <- paste(readLines(
    guarded_runner_path, warn = FALSE, encoding = "UTF-8"
  ), collapse = "\n")
  exact <- paste(readLines(
    exact_resume_runner_path, warn = FALSE, encoding = "UTF-8"
  ), collapse = "\n")
  identity <- list(
    Contract = "reserved_entry_point_source_audit_b1g22_v1",
    PolicyHash = policy$PolicyHash,
    GuardedRunnerFileName = basename(guarded_runner_path),
    GuardedRunnerSourceHash = guarded_hash,
    ExactResumeRunnerFileName = basename(exact_resume_runner_path),
    ExactResumeRunnerSourceHash = exact_hash,
    GuardedSourceExact = identical(
      guarded_hash, policy$RequiredGuardedRunnerSourceHash
    ),
    ExactResumeSourceExact = identical(
      exact_hash, policy$RequiredExactResumeRunnerSourceHash
    ),
    GuardedReservedStopPresent = grepl(
      "A reserved replicate requires a separately issued authorization record.",
      guarded, fixed = TRUE
    ),
    GuardedUsesNonreservedRunner = grepl(
      "execution <- mfrmr_gtwag_execute(", guarded, fixed = TRUE
    ),
    ExactRunnerReservedGuardPresent = grepl(
      "any(run_manifest$Replicates %in% 201:300)", exact, fixed = TRUE
    ),
    ExactRunnerNonreservedMessagePresent = grepl(
      "Only the exact nonreserved b1g13 mechanics run is authorized.",
      exact, fixed = TRUE
    ),
    RecordBoundReservedEntryPointFound = FALSE,
    ExecutableReservedManifestConversionFound = FALSE,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    AuditHash = mfrmr_gta_hash(identity), SourceAuditComplete = TRUE
  )), class = "mfrmr_gtwaq_source_audit")
}

mfrmr_gtwaq_source_audit_hash_valid <- function(audit) {
  fields <- c(
    "Contract", "PolicyHash", "GuardedRunnerFileName",
    "GuardedRunnerSourceHash", "ExactResumeRunnerFileName",
    "ExactResumeRunnerSourceHash", "GuardedSourceExact",
    "ExactResumeSourceExact", "GuardedReservedStopPresent",
    "GuardedUsesNonreservedRunner", "ExactRunnerReservedGuardPresent",
    "ExactRunnerNonreservedMessagePresent",
    "RecordBoundReservedEntryPointFound",
    "ExecutableReservedManifestConversionFound",
    "CalibrationResponsesUsed", "ConfirmationResponsesUsed"
  )
  inherits(audit, "mfrmr_gtwaq_source_audit") &&
    all(fields %in% names(audit)) &&
    identical(audit$AuditHash, mfrmr_gta_hash(audit[fields])) &&
    isTRUE(audit$SourceAuditComplete) && isTRUE(audit$GuardedSourceExact) &&
    isTRUE(audit$ExactResumeSourceExact) &&
    isTRUE(audit$GuardedReservedStopPresent) &&
    isTRUE(audit$GuardedUsesNonreservedRunner) &&
    isTRUE(audit$ExactRunnerReservedGuardPresent) &&
    isTRUE(audit$ExactRunnerNonreservedMessagePresent) &&
    !isTRUE(audit$RecordBoundReservedEntryPointFound) &&
    !isTRUE(audit$ExecutableReservedManifestConversionFound) &&
    !isTRUE(audit$CalibrationResponsesUsed) &&
    !isTRUE(audit$ConfirmationResponsesUsed)
}

mfrmr_gtwaq_decision <- function(
    receipt = mfrmr_gtwaq_parent_receipt(),
    policy = mfrmr_gtwaq_policy(), source_audit) {
  mfrmr_gtwaq_require_primitives()
  if (!mfrmr_gtwaq_parent_receipt_hash_valid(receipt) ||
      !mfrmr_gtwaq_policy_hash_valid(policy) ||
      !mfrmr_gtwaq_source_audit_hash_valid(source_audit) ||
      !identical(source_audit$PolicyHash, policy$PolicyHash)) {
    stop("Exact frozen b1g22 decision inputs are required.", call. = FALSE)
  }
  gates <- data.frame(
    GateId = c(
      "LINEAGE-01", "RUNTIME-01", "RUNNER-REDUCTION-01",
      "RUNNER-SOURCE-01", "RESERVED-ENTRY-01", "ACTIVE-MANIFEST-01",
      "SITE-RECEIPT-01", "CONFIRM-01"
    ),
    ObservedPass = c(
      identical(receipt$CandidateShardId, policy$CandidateShardId) &&
        identical(receipt$CandidateShardCounts,
                  policy$RequiredCandidateShardCounts),
      nzchar(receipt$IsolatedRuntimeHash),
      isTRUE(receipt$Runner01Closed) &&
        isTRUE(receipt$GuardedNonreservedReductionReady),
      source_audit$GuardedSourceExact && source_audit$ExactResumeSourceExact,
      isTRUE(receipt$ReservedAdapterEntryPointReady) &&
        isTRUE(source_audit$RecordBoundReservedEntryPointFound),
      isTRUE(receipt$AuthorizedReservedManifestReady) &&
        isTRUE(source_audit$ExecutableReservedManifestConversionFound),
      isTRUE(receipt$FreshSiteReceiptBound),
      !isTRUE(policy$ConfirmationAccessPermitted) &&
        !isTRUE(receipt$ConfirmationResponsesUsed)
    ),
    RequiredForIssuance = TRUE,
    stringsAsFactors = FALSE
  )
  blockers <- gates$GateId[!gates$ObservedPass]
  issuance_ready <- length(blockers) == 0L
  identity <- list(
    Contract = "execution_authorization_decision_b1g22_v1",
    ParentReceiptHash = receipt$ReceiptHash,
    PolicyHash = policy$PolicyHash,
    SourceAuditHash = source_audit$AuditHash,
    CandidateShardId = receipt$CandidateShardId,
    CandidateShardManifestHash = receipt$CandidateShardManifestHash,
    GateRegistry = gates,
    IssuanceBlockerIds = blockers,
    AuthorizationIssuanceReady = issuance_ready,
    Decision = if (issuance_ready) "eligible_for_separate_record_issuance" else
      "no_go_refused_not_issued",
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    DecisionHash = mfrmr_gta_hash(identity),
    AuthorizationDecisionComplete = TRUE,
    Runner01Closed = TRUE,
    AuthorizationRecordIssued = FALSE,
    ReservedAdapterEntryPointReady = FALSE,
    AuthorizedReservedManifestReady = FALSE,
    FreshSiteReceiptBound = FALSE,
    AuthorizationRNG01Closed = FALSE,
    AuthorizationActivationEligible = FALSE,
    LargeSimulationMayStart = FALSE,
    Replicate201MayBeOpened = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, DecisionReady = FALSE,
    NextImplementationRequired =
      "record_bound_reserved_entry_point_and_active_one_shard_manifest"
  )), class = "mfrmr_gtwaq_decision")
}

mfrmr_gtwaq_decision_hash_valid <- function(decision) {
  fields <- c(
    "Contract", "ParentReceiptHash", "PolicyHash", "SourceAuditHash",
    "CandidateShardId", "CandidateShardManifestHash", "GateRegistry",
    "IssuanceBlockerIds", "AuthorizationIssuanceReady", "Decision",
    "CalibrationResponsesUsed", "ConfirmationResponsesUsed"
  )
  if (!inherits(decision, "mfrmr_gtwaq_decision") ||
      !all(fields %in% names(decision)) ||
      !is.data.frame(decision$GateRegistry)) return(FALSE)
  blockers <- decision$GateRegistry$GateId[
    !decision$GateRegistry$ObservedPass
  ]
  ready <- length(blockers) == 0L
  inherits(decision, "mfrmr_gtwaq_decision") &&
    identical(decision$DecisionHash, mfrmr_gta_hash(decision[fields])) &&
    identical(decision$IssuanceBlockerIds, blockers) &&
    identical(decision$AuthorizationIssuanceReady, ready) &&
    identical(decision$Decision, if (ready) {
      "eligible_for_separate_record_issuance"
    } else "no_go_refused_not_issued") &&
    isTRUE(decision$AuthorizationDecisionComplete) &&
    isTRUE(decision$Runner01Closed) &&
    !isTRUE(decision$AuthorizationRecordIssued) &&
    !isTRUE(decision$ReservedAdapterEntryPointReady) &&
    !isTRUE(decision$AuthorizedReservedManifestReady) &&
    !isTRUE(decision$FreshSiteReceiptBound) &&
    !isTRUE(decision$AuthorizationRNG01Closed) &&
    !isTRUE(decision$AuthorizationActivationEligible) &&
    !isTRUE(decision$LargeSimulationMayStart) &&
    !isTRUE(decision$Replicate201MayBeOpened) &&
    !isTRUE(decision$CalibrationExecutionAuthorized) &&
    !isTRUE(decision$CalibrationDataGenerated) &&
    !isTRUE(decision$CalibrationResultsViewed) &&
    !isTRUE(decision$ConfirmationAuthorized) &&
    !isTRUE(decision$InferenceReady) && !isTRUE(decision$DecisionReady) &&
    !isTRUE(decision$CalibrationResponsesUsed) &&
    !isTRUE(decision$ConfirmationResponsesUsed)
}
