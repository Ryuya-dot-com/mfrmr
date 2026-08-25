# Draft.85c4c c3/c4a/c4b isolation-integration preflight.
#
# Repository-internal only. This layer translates the runtime-bound c4b
# fixture evidence into c3's five access questions. It does not promote that
# fixture result to planned execution, materialize an accuracy threshold, open
# a seed, call an estimator, or modify the historical c3 manifest.

mfrmr_gtvj_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtvd_plan", "mfrmr_gtvd_assert_plan",
    "mfrmr_gtve_manifest", "mfrmr_gtve_assert_manifest",
    "mfrmr_gtvf_manifest", "mfrmr_gtvf_assert_manifest",
    "mfrmr_gtvg_manifest", "mfrmr_gtvg_assert_manifest",
    "mfrmr_gtvh_assert_live_evidence"
  )
  target <- environment(mfrmr_gtvj_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.81 and the Draft.85a0-c4b chain before Draft.85c4c: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtvj_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    setequal(names(attributes(object)), c("names", "class"))
}

mfrmr_gtvj_function_hash <- function(fun) {
  if (!is.function(fun)) {
    stop("A Draft.85c4c implementation function is missing.", call. = FALSE)
  }
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtvj_implementation_identity <- function() {
  function_names <- c(
    "mfrmr_gtvj_require_primitives", "mfrmr_gtvj_exact_object",
    "mfrmr_gtvj_function_hash", "mfrmr_gtvj_implementation_identity",
    "mfrmr_gtvj_schema_roots", "mfrmr_gtvj_access_registry",
    "mfrmr_gtvj_isolation_receipt", "mfrmr_gtvj_assert_isolation_receipt",
    "mfrmr_gtvj_prerequisite_audit", "mfrmr_gtvj_manifest",
    "mfrmr_gtvj_assert_manifest", "mfrmr_gtvj_dispatch_guard"
  )
  target <- environment(mfrmr_gtvj_implementation_identity)
  data.frame(
    Function = function_names,
    SHA256 = vapply(function_names, function(name) {
      if (!exists(name, envir = target, inherits = TRUE)) {
        stop(
          "A Draft.85c4c implementation function is missing: ", name, ".",
          call. = FALSE
        )
      }
      mfrmr_gtvj_function_hash(get(name, envir = target, inherits = TRUE))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvj_schema_roots <- function(c4a_manifest, c4b_evidence) {
  receipt_row <- c4a_manifest$CandidateReceiptRegistry[1L, , drop = FALSE]
  input_schema <- list(
    Contract = "gtheory_multivariate_candidate_envelope_draft85c4a_v1",
    Class = c("mfrmr_gtvg_candidate_envelope", "list"),
    PayloadFields = c(
      "Contract", "OpaqueCandidateId", "EvidenceUse", "CandidateData",
      "CandidateDataHash", "CandidateSchemaHash", "ExpectedRows"
    ),
    SuffixFields = c(
      "EnvelopeHash", "CandidatePayloadOnly", "BackendExecutionAuthorized",
      "RecoveryDenominatorEligible", "PublicSupportReady"
    ),
    CandidateSchemaHash = receipt_row$CandidateSchemaHash[[1L]]
  )
  receipt_schema <- list(
    Contract = "gtheory_multivariate_candidate_receipt_draft85c4a_v1",
    Class = c("mfrmr_gtvg_candidate_receipt", "list"),
    PayloadFields = c(
      "Contract", "OpaqueCandidateId", "EvidenceUse", "EnvelopeHash",
      "CandidateDataHash", "CandidateSchemaHash", "ObservedRows",
      "Attempted", "FitReturned", "EstimateAvailable", "PointGatePassed",
      "FailureStage", "FailureCode"
    ),
    SuffixFields = c(
      "ReceiptHash", "BackendExecutionOccurred", "PlannedResponseGenerated",
      "RecoveryExecuted", "RecoveryEvidenceReady", "EstimationReady",
      "InferenceReady", "DecisionReady", "PublicSupportReady"
    ),
    WorkerIdentityHash = c4a_manifest$WorkerIdentityHash
  )
  executor_components <- data.frame(
    Component = c(
      "capability_worker_file", "candidate_worker_file", "runtime_identity",
      "profile_semantic"
    ),
    SHA256 = c(
      c4b_evidence$RuntimeIdentity$CapabilityWorkerHash,
      c4b_evidence$RuntimeIdentity$CandidateWorkerHash,
      c4b_evidence$RuntimeIdentityHash,
      c4b_evidence$ProfileSemanticHash
    ),
    stringsAsFactors = FALSE
  )
  list(
    CandidateInputSchema = input_schema,
    CandidateInputSchemaSHA256 = mfrmr_gta_hash(input_schema),
    CandidateReceiptSchema = receipt_schema,
    CandidateReceiptSchemaSHA256 = mfrmr_gta_hash(receipt_schema),
    CandidateExecutorComponents = executor_components,
    CandidateExecutorSHA256 = mfrmr_gta_hash(executor_components)
  )
}

mfrmr_gtvj_access_registry <- function(c3_manifest, c4b_evidence) {
  questions <- c(
    "scenario_identity", "data_seed", "reference_identity", "truth",
    "accuracy_threshold"
  )
  c3_fields <- c(
    "CandidateCanReadScenarioIdentity", "CandidateCanReadDataSeed",
    "CandidateCanReadReferenceIdentity", "CandidateCanReadTruth",
    "CandidateCanReadAccuracyThreshold"
  )
  control_mode <- c(rep("probe_vault_read", 4L), "probe_source_read")
  control_index <- match(control_mode, c4b_evidence$ControlRegistry$Mode)
  control_passed <- c4b_evidence$ControlRegistry$ControlPassed[control_index]
  template_values <- unlist(
    c3_manifest$IsolationTemplate[c3_fields], use.names = FALSE
  )
  if (!all(is.na(template_values)) || anyNA(control_passed) ||
      !all(control_passed)) {
    stop(
      "The Draft.85c3 template or c4b access controls are not integrable.",
      call. = FALSE
    )
  }
  data.frame(
    QuestionOrdinal = 1:5,
    QuestionId = questions,
    C3Field = c3_fields,
    FixtureMaterialPresent = c(TRUE, TRUE, TRUE, TRUE, FALSE),
    PlannedMaterialPresent = FALSE,
    EvidenceMode = control_mode,
    EvidenceControlPassed = unname(control_passed),
    CandidateCanRead = FALSE,
    AnswerBasis = c(
      rep("nonreserved_fixture_vault_read_denied", 4L),
      "threshold_not_materialized_and_source_tree_read_denied"
    ),
    PlannedExecutionRecheckRequired = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvj_isolation_receipt <- function(
    worker_environment, c4b_evidence,
    plan = mfrmr_gtvd_plan(),
    generator_manifest = mfrmr_gtve_manifest(plan),
    environment_snapshot = mfrmr_gtvf_environment_snapshot(),
    c3_manifest = mfrmr_gtvf_manifest(
      plan, generator_manifest, environment_snapshot
    ),
    c4a_manifest = mfrmr_gtvg_manifest(
      worker_environment, plan, generator_manifest
    )) {
  mfrmr_gtvj_require_primitives()
  mfrmr_gtvd_assert_plan(plan)
  mfrmr_gtve_assert_manifest(
    generator_manifest, plan, generator_manifest$FixtureRegistry
  )
  mfrmr_gtvf_assert_manifest(
    c3_manifest, plan, generator_manifest, environment_snapshot
  )
  mfrmr_gtvg_assert_manifest(
    c4a_manifest, worker_environment, plan, generator_manifest
  )
  mfrmr_gtvh_assert_live_evidence(c4b_evidence, worker_environment)
  first <- c4a_manifest$CandidateReceiptRegistry[1L, , drop = FALSE]
  bound <-
    identical(c3_manifest$PlanHash, plan$PlanHash) &&
    identical(c4a_manifest$PlanHash, plan$PlanHash) &&
    identical(c4b_evidence$PlanHash, plan$PlanHash) &&
    identical(c3_manifest$GeneratorManifestHash,
              generator_manifest$ManifestHash) &&
    identical(c4a_manifest$GeneratorManifestHash,
              generator_manifest$ManifestHash) &&
    identical(c4b_evidence$GeneratorManifestHash,
              generator_manifest$ManifestHash) &&
    identical(c4b_evidence$OpaqueCandidateId,
              first$OpaqueCandidateId[[1L]]) &&
    identical(c4b_evidence$EnvelopeHash, first$EnvelopeHash[[1L]]) &&
    identical(c4b_evidence$CandidateDataHash,
              first$CandidateDataHash[[1L]]) &&
    identical(c4b_evidence$NormalCandidateReceiptHash,
              first$ReceiptHash[[1L]])
  if (!bound) {
    stop("The Draft.85c3/c4a/c4b isolation identities do not join.",
         call. = FALSE)
  }
  schemas <- mfrmr_gtvj_schema_roots(c4a_manifest, c4b_evidence)
  access <- mfrmr_gtvj_access_registry(c3_manifest, c4b_evidence)
  audit_payload <- list(
    Namespace = "gtheory_multivariate_isolation_audit_draft85c4c_v1",
    C4BEvidenceHash = c4b_evidence$EvidenceHash,
    RuntimeIdentityHash = c4b_evidence$RuntimeIdentityHash,
    ControlRegistryHash = c4b_evidence$ControlRegistryHash,
    AccessQuestionRegistryHash = mfrmr_gta_hash(access)
  )
  payload <- list(
    Contract = "gtheory_multivariate_isolation_receipt_draft85c4c_v1",
    PlanHash = plan$PlanHash,
    GeneratorManifestHash = generator_manifest$ManifestHash,
    C3ManifestHash = c3_manifest$ManifestHash,
    C3IsolationTemplateHash = c3_manifest$IsolationTemplate$TemplateHash,
    C4AManifestHash = c4a_manifest$ManifestHash,
    C4BEvidenceHash = c4b_evidence$EvidenceHash,
    CandidateExecutorComponents = schemas$CandidateExecutorComponents,
    CandidateExecutorSHA256 = schemas$CandidateExecutorSHA256,
    CandidateInputSchema = schemas$CandidateInputSchema,
    CandidateInputSchemaSHA256 = schemas$CandidateInputSchemaSHA256,
    CandidateReceiptSchema = schemas$CandidateReceiptSchema,
    CandidateReceiptSchemaSHA256 = schemas$CandidateReceiptSchemaSHA256,
    ReferenceVaultSHA256 = c4b_evidence$ReferenceVaultHash,
    RegistryReferenceVaultSHA256 = c4a_manifest$ReferenceVaultHash,
    IsolationAuditId = paste0(
      "C4C-", substr(mfrmr_gta_hash(audit_payload), 1L, 24L)
    ),
    AccessQuestionRegistry = access,
    AccessQuestionRegistryHash = mfrmr_gta_hash(access),
    TruthReleaseRequiresCompleteReceipts =
      c3_manifest$IsolationTemplate$TruthReleaseRequiresCompleteReceipts
  )
  structure(c(payload, list(
    ReceiptHash = mfrmr_gta_hash(payload),
    FixtureAccessQuestionsReady = TRUE,
    ProcessCapabilityIsolationReady = TRUE,
    FixtureTruthBlindProcessBoundaryReady = TRUE,
    PlannedExecutionIsolationReady = FALSE,
    ConfirmationThresholdMaterialized = FALSE,
    ConfirmationIsolationRecheckRequired = TRUE,
    CandidateCompletionSealed = FALSE,
    TruthReleaseAuthorized = FALSE,
    BackendQualificationReady = FALSE,
    PilotExecutionAuthorized = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    BackendExecutionOccurred = FALSE,
    PlannedResponseGenerated = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvj_isolation_receipt", "list"))
}

mfrmr_gtvj_assert_isolation_receipt <- function(
    receipt, worker_environment, c4b_evidence,
    plan = mfrmr_gtvd_plan(),
    generator_manifest = mfrmr_gtve_manifest(plan),
    environment_snapshot = mfrmr_gtvf_environment_snapshot(),
    c3_manifest = mfrmr_gtvf_manifest(
      plan, generator_manifest, environment_snapshot
    ),
    c4a_manifest = mfrmr_gtvg_manifest(
      worker_environment, plan, generator_manifest
    )) {
  canonical <- mfrmr_gtvj_isolation_receipt(
    worker_environment, c4b_evidence, plan, generator_manifest,
    environment_snapshot, c3_manifest, c4a_manifest
  )
  if (!mfrmr_gtvj_exact_object(receipt, names(canonical), class(canonical)) ||
      !identical(receipt, canonical)) {
    stop("The Draft.85c4c isolation receipt or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvj_prerequisite_audit <- function(c3_manifest, isolation_receipt) {
  audit <- c3_manifest$PrerequisiteAudit
  isolation_row <- match(
    "truth_blind_process_boundary", audit$PrerequisiteId
  )
  audit$CurrentSatisfied[[isolation_row]] <- FALSE
  audit$EvidenceState[[isolation_row]] <-
    "fixture_only_runtime_bound_isolation_requires_planned_successor"
  data.frame(
    audit,
    FixtureEvidenceAvailable = c(
      rep(FALSE, isolation_row - 1L),
      isolation_receipt$FixtureTruthBlindProcessBoundaryReady,
      rep(FALSE, nrow(audit) - isolation_row)
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvj_manifest <- function(
    worker_environment, c4b_evidence,
    plan = mfrmr_gtvd_plan(),
    generator_manifest = mfrmr_gtve_manifest(plan),
    environment_snapshot = mfrmr_gtvf_environment_snapshot(),
    c3_manifest = mfrmr_gtvf_manifest(
      plan, generator_manifest, environment_snapshot
    ),
    c4a_manifest = mfrmr_gtvg_manifest(
      worker_environment, plan, generator_manifest
    )) {
  receipt <- mfrmr_gtvj_isolation_receipt(
    worker_environment, c4b_evidence, plan, generator_manifest,
    environment_snapshot, c3_manifest, c4a_manifest
  )
  prerequisites <- mfrmr_gtvj_prerequisite_audit(c3_manifest, receipt)
  implementation <- mfrmr_gtvj_implementation_identity()
  payload <- list(
    Contract = "gtheory_multivariate_isolation_integration_draft85c4c_v1",
    PlanHash = plan$PlanHash,
    GeneratorManifestHash = generator_manifest$ManifestHash,
    HistoricalC3ManifestHash = c3_manifest$ManifestHash,
    C4AManifestHash = c4a_manifest$ManifestHash,
    C4BEvidenceHash = c4b_evidence$EvidenceHash,
    IsolationReceipt = receipt,
    IsolationReceiptHash = receipt$ReceiptHash,
    PrerequisiteAudit = prerequisites,
    PrerequisiteAuditHash = mfrmr_gta_hash(prerequisites),
    ImplementationIdentity = implementation,
    ImplementationIdentityHash = mfrmr_gta_hash(implementation),
    PlannedSeedMaterialIncluded = FALSE
  )
  structure(c(payload, list(
    ManifestHash = mfrmr_gta_hash(payload),
    C3IsolationQuestionIntegrationReady = TRUE,
    ProcessCapabilityIsolationReady = TRUE,
    FixtureTruthBlindProcessBoundaryReady = TRUE,
    TruthBlindProcessBoundaryReady = FALSE,
    PlannedExecutionIsolationReady = FALSE,
    ConfirmationIsolationRecheckRequired = TRUE,
    C3HistoricalManifestModified = FALSE,
    CandidateCompletionSealed = FALSE,
    TruthReleaseAuthorized = FALSE,
    ExternalFreezeReady = FALSE,
    CleanSourceIdentityReady = FALSE,
    IndependentAccuracyRuleReady = FALSE,
    BackendQualificationReady = FALSE,
    PilotExecutionAuthorized = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    NegativeControlExecutionAuthorized = FALSE,
    ExecutionGateClosed = TRUE,
    BackendExecutionOccurred = FALSE,
    PlannedResponseGenerated = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvj_manifest", "list"))
}

mfrmr_gtvj_assert_manifest <- function(
    manifest, worker_environment, c4b_evidence,
    plan = mfrmr_gtvd_plan(),
    generator_manifest = mfrmr_gtve_manifest(plan),
    environment_snapshot = mfrmr_gtvf_environment_snapshot(),
    c3_manifest = mfrmr_gtvf_manifest(
      plan, generator_manifest, environment_snapshot
    ),
    c4a_manifest = mfrmr_gtvg_manifest(
      worker_environment, plan, generator_manifest
    )) {
  canonical <- mfrmr_gtvj_manifest(
    worker_environment, c4b_evidence, plan, generator_manifest,
    environment_snapshot, c3_manifest, c4a_manifest
  )
  if (!mfrmr_gtvj_exact_object(manifest, names(canonical), class(canonical)) ||
      !identical(manifest, canonical)) {
    stop("The Draft.85c4c integration manifest or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvj_dispatch_guard <- function(
    manifest, worker_environment, c4b_evidence, callback, ...,
    authorize = FALSE, plan = mfrmr_gtvd_plan(),
    generator_manifest = mfrmr_gtve_manifest(plan),
    environment_snapshot = mfrmr_gtvf_environment_snapshot(),
    c3_manifest = mfrmr_gtvf_manifest(
      plan, generator_manifest, environment_snapshot
    ),
    c4a_manifest = mfrmr_gtvg_manifest(
      worker_environment, plan, generator_manifest
    )) {
  mfrmr_gtvj_assert_manifest(
    manifest, worker_environment, c4b_evidence, plan, generator_manifest,
    environment_snapshot, c3_manifest, c4a_manifest
  )
  if (!is.function(callback)) {
    stop("`callback` must be a function.", call. = FALSE)
  }
  if (!is.logical(authorize) || length(authorize) != 1L || is.na(authorize)) {
    stop("`authorize` must be TRUE or FALSE.", call. = FALSE)
  }
  stop(
    "Draft.85c4c integrates fixture isolation only; execution remains closed.",
    call. = FALSE
  )
}
