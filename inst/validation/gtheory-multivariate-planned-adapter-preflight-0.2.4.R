# Draft.85c4m multivariate G-theory truth-blind planned-adapter preflight.
#
# Repository-internal only. This layer projects the three canonical c1
# handoff previews through a sealed non-attempt worker after revalidating the
# c4l backend-qualification integration receipt. It proves an allowlisted
# request/receipt schema, not OS process-capability isolation or study-lane
# execution authority.

mfrmr_gtvt_require_primitives <- function() {
  required <- c(
    "mfrmr_gtvd_plan", "mfrmr_gtvd_assert_plan",
    "mfrmr_gtvd_candidate_handoff_preview",
    "mfrmr_gtvd_assert_handoff_preview", "mfrmr_gtve_assert_manifest",
    "mfrmr_gtvs_assert_receipt"
  )
  target <- environment(mfrmr_gtvt_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.85c1/c2 and the c3-through-c4l chain before c4m: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtvt_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4m requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvt_file_hash <- function(path) {
  path <- normalizePath(path, mustWork = TRUE)
  if (dir.exists(path)) {
    stop("A Draft.85c4m source file is required.", call. = FALSE)
  }
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtvt_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    identical(sort(names(attributes(object))), c("class", "names"))
}

mfrmr_gtvt_worker_functions <- function() {
  c(
    "mfrmr_gtvtw_hash", "mfrmr_gtvtw_exact_object",
    "mfrmr_gtvtw_candidate_unit_schema", "mfrmr_gtvtw_receive"
  )
}

mfrmr_gtvt_worker_identity <- function(worker_environment) {
  required <- mfrmr_gtvt_worker_functions()
  if (!is.environment(worker_environment) ||
      !identical(parent.env(worker_environment), baseenv()) ||
      !identical(
        sort(ls(worker_environment, all.names = TRUE), method = "radix"),
        sort(required, method = "radix")
      ) || !all(vapply(required, function(name) {
        is.function(get(name, envir = worker_environment, inherits = FALSE))
      }, logical(1L)))) {
    stop("The Draft.85c4m worker namespace was altered.", call. = FALSE)
  }
  data.frame(
    Function = required,
    SHA256 = vapply(required, function(name) {
      fun <- get(name, envir = worker_environment, inherits = FALSE)
      mfrmr_gtvt_hash(list(
        Formals = paste(deparse(formals(fun), width.cutoff = 500L),
                        collapse = "\n"),
        Body = paste(deparse(body(fun), width.cutoff = 500L),
                     collapse = "\n")
      ))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvt_worker_static_audit <- function(worker_environment) {
  mfrmr_gtvt_worker_identity(worker_environment)
  calls <- c(
    "source", "sys.source", "readRDS", "readLines", "scan", "file",
    "url", "socketConnection", "download.file", "system", "system2"
  )
  text <- paste(vapply(mfrmr_gtvt_worker_functions(), function(name) {
    fun <- get(name, envir = worker_environment, inherits = FALSE)
    paste(deparse(body(fun), width.cutoff = 500L), collapse = "\n")
  }, character(1L)), collapse = "\n")
  found <- vapply(calls, function(call) {
    grepl(paste0("\\b", gsub("\\.", "\\\\.", call), "\\s*\\("),
          text, perl = TRUE)
  }, logical(1L))
  data.frame(
    ForbiddenCallOrdinal = seq_along(calls),
    ForbiddenCall = calls,
    Present = unname(found),
    Passed = !unname(found),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvt_candidate_unit_schema <- function(units) {
  list(
    Names = names(units),
    Classes = unname(vapply(
      units, function(value) class(value)[[1L]], character(1L)
    ))
  )
}

mfrmr_gtvt_request <- function(
    plan, stage_id, backend_qualification_receipt_hash,
    backend_qualification_route_registry_hash) {
  mfrmr_gtvd_assert_plan(plan)
  handoff <- mfrmr_gtvd_candidate_handoff_preview(plan, stage_id)
  mfrmr_gtvd_assert_handoff_preview(plan, handoff)
  hashes <- c(
    backend_qualification_receipt_hash,
    backend_qualification_route_registry_hash
  )
  if (!is.character(hashes) || length(hashes) != 2L || anyNA(hashes) ||
      !all(grepl("^[0-9a-f]{64}$", hashes))) {
    stop("Two exact Draft.85c4l qualification hashes are required.",
         call. = FALSE)
  }
  units <- handoff$CandidateUnits
  schema <- mfrmr_gtvt_candidate_unit_schema(units)
  request_id <- paste0("C4M-", substr(mfrmr_gtvt_hash(list(
    Namespace = "gtheory_multivariate_planned_adapter_request_draft85c4m_v1",
    PlanHash = plan$PlanHash,
    LaneOpaqueId = handoff$LaneOpaqueId,
    HandoffPreviewHash = handoff$HandoffPreviewHash,
    CandidateUnitHash = handoff$CandidateUnitHash,
    BackendQualificationReceiptHash = backend_qualification_receipt_hash
  )), 1L, 24L))
  payload <- list(
    Contract =
      "gtheory_multivariate_planned_adapter_request_draft85c4m_v1",
    OpaqueRequestId = request_id,
    LaneOpaqueId = handoff$LaneOpaqueId,
    PlanHash = plan$PlanHash,
    HandoffPreviewHash = handoff$HandoffPreviewHash,
    CandidateUnits = units,
    CandidateUnitHash = handoff$CandidateUnitHash,
    CandidateUnitSchema = schema,
    CandidateUnitSchemaHash = mfrmr_gtvt_hash(schema),
    ExpectedUnits = handoff$ExpectedUnits,
    BackendQualificationReceiptHash = backend_qualification_receipt_hash,
    BackendQualificationRouteRegistryHash =
      backend_qualification_route_registry_hash,
    RequestPurpose = "planned_adapter_schema_only"
  )
  structure(c(payload, list(
    RequestHash = mfrmr_gtvt_hash(payload),
    CandidateColumnAllowlistReady = handoff$CandidateColumnAllowlistReady,
    BackendQualificationBound = TRUE,
    ProtectedMaterialIncluded = FALSE,
    ExecutionAuthorized = FALSE,
    CandidateExecutionOccurred = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvtw_request", "list"))
}

mfrmr_gtvt_assert_request <- function(
    request, plan, stage_id, backend_qualification_receipt_hash,
    backend_qualification_route_registry_hash) {
  canonical <- mfrmr_gtvt_request(
    plan, stage_id, backend_qualification_receipt_hash,
    backend_qualification_route_registry_hash
  )
  if (!mfrmr_gtvt_exact_object(
    request, names(canonical), class(canonical)
  ) || !identical(request, canonical)) {
    stop("The Draft.85c4m adapter request was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvt_worker_receipt <- function(request, worker_environment) {
  mfrmr_gtvt_worker_identity(worker_environment)
  receive <- get("mfrmr_gtvtw_receive", envir = worker_environment,
                 inherits = FALSE)
  receipt <- receive(request)
  mfrmr_gtvt_assert_worker_receipt(receipt, request, worker_environment)
  receipt
}

mfrmr_gtvt_assert_worker_receipt <- function(
    receipt, request, worker_environment) {
  mfrmr_gtvt_worker_identity(worker_environment)
  receive <- get("mfrmr_gtvtw_receive", envir = worker_environment,
                 inherits = FALSE)
  expected <- receive(request)
  if (!mfrmr_gtvt_exact_object(
    receipt, names(expected), class(expected)
  ) || !identical(receipt, expected)) {
    stop("The Draft.85c4m adapter receipt was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvt_lane_bundle <- function(plan, c4l_receipt, worker_environment) {
  stage_ids <- plan$StageCatalog$StageId
  requests <- receipts <- handoffs <- setNames(vector("list", 3L), stage_ids)
  rows <- vector("list", 3L)
  for (index in seq_along(stage_ids)) {
    stage_id <- stage_ids[[index]]
    handoff <- mfrmr_gtvd_candidate_handoff_preview(plan, stage_id)
    request <- mfrmr_gtvt_request(
      plan, stage_id, c4l_receipt$ReceiptHash,
      c4l_receipt$QualificationRouteRegistryHash
    )
    receipt <- mfrmr_gtvt_worker_receipt(request, worker_environment)
    mfrmr_gtvt_assert_request(
      request, plan, stage_id, c4l_receipt$ReceiptHash,
      c4l_receipt$QualificationRouteRegistryHash
    )
    handoffs[[stage_id]] <- handoff
    requests[[stage_id]] <- request
    receipts[[stage_id]] <- receipt
    rows[[index]] <- data.frame(
      StageOrdinal = plan$StageCatalog$StageOrdinal[[index]],
      StageId = stage_id,
      LaneOpaqueId = handoff$LaneOpaqueId,
      HandoffId = handoff$HandoffId,
      HandoffPreviewHash = handoff$HandoffPreviewHash,
      CandidateUnitHash = handoff$CandidateUnitHash,
      ExpectedUnits = handoff$ExpectedUnits,
      OpaqueRequestId = request$OpaqueRequestId,
      RequestHash = request$RequestHash,
      ReceiptHash = receipt$ReceiptHash,
      ObservedUnits = receipt$ObservedUnits,
      StageIdVisibleToWorker = FALSE,
      AdapterRequestAccepted = receipt$AdapterRequestAccepted,
      Attempted = receipt$Attempted,
      CandidateDataReceived = receipt$CandidateDataReceived,
      BackendInvoked = receipt$BackendInvoked,
      AdapterReceiptReady = TRUE,
      stringsAsFactors = FALSE
    )
  }
  registry <- do.call(rbind, rows)
  row.names(registry) <- NULL
  list(
    Handoffs = handoffs, Requests = requests, Receipts = receipts,
    LaneRegistry = registry
  )
}

mfrmr_gtvt_schema_roots <- function(bundle, worker_identity) {
  request <- bundle$Requests[[1L]]
  receipt <- bundle$Receipts[[1L]]
  request_schema <- list(
    Contract = request$Contract,
    Class = class(request),
    PayloadFields = names(request)[seq_len(13L)],
    SuffixFields = names(request)[14:length(request)],
    CandidateUnitSchema = request$CandidateUnitSchema,
    CandidateUnitSchemaHash = request$CandidateUnitSchemaHash
  )
  receipt_schema <- list(
    Contract = receipt$Contract,
    Class = class(receipt),
    PayloadFields = names(receipt)[seq_len(14L)],
    SuffixFields = names(receipt)[15:length(receipt)]
  )
  list(
    RequestSchema = request_schema,
    RequestSchemaHash = mfrmr_gtvt_hash(request_schema),
    ReceiptSchema = receipt_schema,
    ReceiptSchemaHash = mfrmr_gtvt_hash(receipt_schema),
    WorkerIdentityHash = mfrmr_gtvt_hash(worker_identity)
  )
}

mfrmr_gtvt_access_registry <- function(bundle) {
  questions <- c(
    "scenario_identity", "data_seed", "reference_identity", "truth",
    "accuracy_threshold"
  )
  forbidden <- c(
    "ScenarioId|ScenarioOrdinal|OpaqueScenarioToken|StageId",
    "Replicate|DataSeed|AssignmentId",
    "ReferenceId|ReferenceCovarianceHash|ReferenceFactorRegistry",
    paste0(
      "BoundaryClass|ExpectedPreFitState|StructuralRowsHash|TruthValue|",
      "GeneratingCovariance|GeneratingFactor"
    ),
    "RecoveryThreshold|AccuracyThreshold|CriterionTable"
  )
  request_fields <- unique(unlist(lapply(bundle$Requests, function(request) {
    c(names(request), names(request$CandidateUnits))
  }), use.names = FALSE))
  present <- vapply(strsplit(forbidden, "\\|"), function(fields) {
    any(fields %in% request_fields)
  }, logical(1L))
  data.frame(
    QuestionOrdinal = 1:5,
    QuestionId = questions,
    ForbiddenFieldSet = forbidden,
    ForbiddenFieldPresent = unname(present),
    CanonicalC1HandoffProjection = rep(TRUE, 5L),
    ProtectedMaterialPresent = rep(FALSE, 5L),
    CandidateCanRead = rep(FALSE, 5L),
    ProofBasis = rep(
      "exact_c1_handoff_projection_and_request_field_allowlist", 5L
    ),
    ProcessCapabilityRecheckRequired = rep(TRUE, 5L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvt_prerequisite_projection <- function(c4l_receipt) {
  prior <- c4l_receipt$PrerequisiteProjection
  truth_index <- match("truth_blind_process_boundary", prior$PrerequisiteId)
  if (!is.data.frame(prior) || is.na(truth_index) ||
      !identical(sum(prior$ProjectedSatisfied), 2L) ||
      isTRUE(prior$ProjectedSatisfied[[truth_index]])) {
    stop("The Draft.85c4l prerequisite state is not canonical for c4m.",
         call. = FALSE)
  }
  evidence_state <- prior$EvidenceState
  evidence_state[[truth_index]] <-
    "planned_adapter_schema_ready_process_capability_isolation_missing"
  data.frame(
    PrerequisiteOrdinal = prior$PrerequisiteOrdinal,
    PrerequisiteId = prior$PrerequisiteId,
    Requirement = prior$Requirement,
    C4LProjectedSatisfied = prior$ProjectedSatisfied,
    C4MProjectedSatisfied = prior$ProjectedSatisfied,
    TransitionedByC4M = rep(FALSE, nrow(prior)),
    PartialExecutionAllowed = prior$PartialExecutionAllowed,
    EvidenceState = evidence_state,
    AdapterSchemaEvidenceAvailable = seq_len(nrow(prior)) == truth_index,
    ProcessCapabilityEvidenceAvailable = rep(FALSE, nrow(prior)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvt_payload_fields <- function() {
  c(
    "Contract", "PlanHash", "PlanCoreHash", "GeneratorManifestHash",
    "C3ManifestHash", "C4LReceiptHash", "C4LPrerequisiteProjectionHash",
    "C4LQualificationRouteRegistryHash", "WorkerSourceSHA256", "WorkerIdentity",
    "WorkerIdentityHash", "WorkerStaticAudit", "WorkerStaticAuditHash",
    "RequestSchema", "RequestSchemaHash", "ReceiptSchema",
    "ReceiptSchemaHash", "LaneAdapterRegistry", "LaneAdapterRegistryHash",
    "AccessQuestionRegistry", "AccessQuestionRegistryHash",
    "PrerequisiteProjection", "PrerequisiteProjectionHash",
    "ImplementationIdentity", "ImplementationIdentityHash",
    "RequestObjectsRetained", "PlannedUnitTopologyIncluded",
    "CandidateDataIncluded", "PlannedSeedMaterialIncluded",
    "ScenarioIdentityIncluded", "ReferenceIdentityIncluded",
    "ReferenceTruthIncluded", "AccuracyThresholdIncluded",
    "ConQuestRouteIncluded"
  )
}

mfrmr_gtvt_implementation_identity <- function() {
  function_names <- c(
    "mfrmr_gtvt_require_primitives", "mfrmr_gtvt_hash", "mfrmr_gtvt_file_hash",
    "mfrmr_gtvt_exact_object", "mfrmr_gtvt_worker_functions",
    "mfrmr_gtvt_worker_identity", "mfrmr_gtvt_worker_static_audit",
    "mfrmr_gtvt_candidate_unit_schema", "mfrmr_gtvt_request",
    "mfrmr_gtvt_assert_request", "mfrmr_gtvt_worker_receipt",
    "mfrmr_gtvt_assert_worker_receipt", "mfrmr_gtvt_lane_bundle",
    "mfrmr_gtvt_schema_roots", "mfrmr_gtvt_access_registry",
    "mfrmr_gtvt_prerequisite_projection", "mfrmr_gtvt_payload_fields",
    "mfrmr_gtvt_implementation_identity", "mfrmr_gtvt_manifest",
    "mfrmr_gtvt_assert_manifest", "mfrmr_gtvt_dispatch_guard"
  )
  target <- environment(mfrmr_gtvt_implementation_identity)
  data.frame(
    Function = function_names,
    SHA256 = vapply(function_names, function(name) {
      if (!exists(name, envir = target, inherits = FALSE)) {
        stop("A Draft.85c4m implementation function is missing: ", name,
             ".", call. = FALSE)
      }
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtvt_hash(list(
        Formals = paste(deparse(formals(fun), width.cutoff = 500L),
                        collapse = "\n"),
        Body = paste(deparse(body(fun), width.cutoff = 500L),
                     collapse = "\n")
      ))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvt_manifest <- function(
    plan, generator_manifest, c3_manifest, c4e_manifest, c4f_manifest,
    repair_receipt, qualification_receipt, capability_evidence, c4l_receipt,
    repair_worker_environment, qualification_worker_environment,
    capability_worker_environment, adapter_worker_environment,
    repo_root = ".", validation_dir = file.path("inst", "validation")) {
  mfrmr_gtvt_require_primitives()
  mfrmr_gtvd_assert_plan(plan)
  mfrmr_gtve_assert_manifest(
    generator_manifest, plan, generator_manifest$FixtureRegistry
  )
  mfrmr_gtvs_assert_receipt(
    c4l_receipt, c3_manifest, c4e_manifest, c4f_manifest, repair_receipt,
    qualification_receipt, capability_evidence,
    repair_worker_environment, qualification_worker_environment,
    capability_worker_environment, repo_root, validation_dir
  )
  if (!identical(c3_manifest$PlanHash, plan$PlanHash) ||
      !identical(c3_manifest$GeneratorManifestHash,
                 generator_manifest$ManifestHash) ||
      !identical(c4l_receipt$C3ManifestHash, c3_manifest$ManifestHash) ||
      !isTRUE(c4l_receipt$BackendQualificationReady)) {
    stop("The Draft.85c4m plan, c3, and c4l roots do not join.",
         call. = FALSE)
  }
  validation_dir <- normalizePath(validation_dir, mustWork = TRUE)
  worker_source <- file.path(
    validation_dir, "gtheory-multivariate-planned-adapter-worker-0.2.4.R"
  )
  worker_identity <- mfrmr_gtvt_worker_identity(adapter_worker_environment)
  worker_audit <- mfrmr_gtvt_worker_static_audit(adapter_worker_environment)
  if (!all(worker_audit$Passed)) {
    stop("The Draft.85c4m worker contains a forbidden discovery call.",
         call. = FALSE)
  }
  bundle <- mfrmr_gtvt_lane_bundle(
    plan, c4l_receipt, adapter_worker_environment
  )
  schemas <- mfrmr_gtvt_schema_roots(bundle, worker_identity)
  access <- mfrmr_gtvt_access_registry(bundle)
  if (any(access$ForbiddenFieldPresent) ||
      any(access$CandidateCanRead) ||
      any(access$ProtectedMaterialPresent)) {
    stop("The Draft.85c4m request allowlist exposes protected material.",
         call. = FALSE)
  }
  prerequisites <- mfrmr_gtvt_prerequisite_projection(c4l_receipt)
  implementation <- mfrmr_gtvt_implementation_identity()
  lanes <- bundle$LaneRegistry
  payload <- list(
    Contract = "gtheory_multivariate_planned_adapter_draft85c4m_v1",
    PlanHash = plan$PlanHash,
    PlanCoreHash = plan$PlanCoreHash,
    GeneratorManifestHash = generator_manifest$ManifestHash,
    C3ManifestHash = c3_manifest$ManifestHash,
    C4LReceiptHash = c4l_receipt$ReceiptHash,
    C4LPrerequisiteProjectionHash =
      c4l_receipt$PrerequisiteProjectionHash,
    C4LQualificationRouteRegistryHash =
      c4l_receipt$QualificationRouteRegistryHash,
    WorkerSourceSHA256 = mfrmr_gtvt_file_hash(worker_source),
    WorkerIdentity = worker_identity,
    WorkerIdentityHash = mfrmr_gtvt_hash(worker_identity),
    WorkerStaticAudit = worker_audit,
    WorkerStaticAuditHash = mfrmr_gtvt_hash(worker_audit),
    RequestSchema = schemas$RequestSchema,
    RequestSchemaHash = schemas$RequestSchemaHash,
    ReceiptSchema = schemas$ReceiptSchema,
    ReceiptSchemaHash = schemas$ReceiptSchemaHash,
    LaneAdapterRegistry = lanes,
    LaneAdapterRegistryHash = mfrmr_gtvt_hash(lanes),
    AccessQuestionRegistry = access,
    AccessQuestionRegistryHash = mfrmr_gtvt_hash(access),
    PrerequisiteProjection = prerequisites,
    PrerequisiteProjectionHash = mfrmr_gtvt_hash(prerequisites),
    ImplementationIdentity = implementation,
    ImplementationIdentityHash = mfrmr_gtvt_hash(implementation),
    RequestObjectsRetained = FALSE,
    PlannedUnitTopologyIncluded = TRUE,
    CandidateDataIncluded = FALSE,
    PlannedSeedMaterialIncluded = FALSE,
    ScenarioIdentityIncluded = FALSE,
    ReferenceIdentityIncluded = FALSE,
    ReferenceTruthIncluded = FALSE,
    AccuracyThresholdIncluded = FALSE,
    ConQuestRouteIncluded = FALSE
  )
  structure(c(payload, list(
    ManifestHash = mfrmr_gtvt_hash(payload),
    AdapterWorkerImplemented = TRUE,
    WorkerNamespaceSeparationReady = TRUE,
    WorkerStaticForbiddenCallAuditReady = TRUE,
    ThreeLaneOpaqueTransportReady = nrow(lanes) == 3L &&
      all(lanes$AdapterReceiptReady),
    CandidateColumnAllowlistReady = TRUE,
    ProtectedMaterialExcluded = TRUE,
    BackendQualificationBound = TRUE,
    BackendQualificationReady = TRUE,
    AdapterRequestSchemaReady = TRUE,
    AdapterReceiptSchemaReady = TRUE,
    PayloadTruthBlindReady = TRUE,
    RefusalTransportExercised = TRUE,
    ProcessCapabilityIsolationAssessed = FALSE,
    ProcessCapabilityIsolationReady = FALSE,
    TruthBlindProcessBoundaryReady = FALSE,
    PlannedExecutionIsolationReady = FALSE,
    ExactlyZeroC3PrerequisitesTransitioned =
      !any(prerequisites$TransitionedByC4M),
    C3SatisfiedPrerequisiteCount =
      as.integer(sum(prerequisites$C4MProjectedSatisfied)),
    AllExecutionPrerequisitesReady =
      all(prerequisites$C4MProjectedSatisfied),
    ExternalFreezeReady = FALSE,
    CleanSourceIdentityReady = FALSE,
    IndependentAccuracyRuleReady = FALSE,
    PilotExecutionAuthorized = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    NegativeControlExecutionAuthorized = FALSE,
    ExecutionGateClosed = TRUE,
    AdapterBackendExecutionOccurred = FALSE,
    CandidateExecutionOccurred = FALSE,
    CandidateCompletionSealed = FALSE,
    TruthReleaseAuthorized = FALSE,
    DenominatorAccountingReady = FALSE,
    PlannedResponseGenerated = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvt_manifest", "list"))
}

mfrmr_gtvt_assert_manifest <- function(
    manifest, plan, generator_manifest, c3_manifest, c4e_manifest,
    c4f_manifest, repair_receipt, qualification_receipt,
    capability_evidence, c4l_receipt, repair_worker_environment,
    qualification_worker_environment, capability_worker_environment,
    adapter_worker_environment, repo_root = ".",
    validation_dir = file.path("inst", "validation")) {
  canonical <- mfrmr_gtvt_manifest(
    plan, generator_manifest, c3_manifest, c4e_manifest, c4f_manifest,
    repair_receipt, qualification_receipt, capability_evidence, c4l_receipt,
    repair_worker_environment, qualification_worker_environment,
    capability_worker_environment, adapter_worker_environment,
    repo_root, validation_dir
  )
  if (!mfrmr_gtvt_exact_object(
    manifest, names(canonical), class(canonical)
  ) || !identical(manifest, canonical)) {
    stop("The Draft.85c4m manifest, schema, or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvt_dispatch_guard <- function(
    manifest, action, callback, ..., authorize = FALSE,
    plan, generator_manifest, c3_manifest, c4e_manifest, c4f_manifest,
    repair_receipt, qualification_receipt, capability_evidence, c4l_receipt,
    repair_worker_environment, qualification_worker_environment,
    capability_worker_environment, adapter_worker_environment,
    repo_root = ".", validation_dir = file.path("inst", "validation")) {
  allowed_actions <- c(
    "candidate_execution", "pilot", "confirmation", "negative_control",
    "planned_response", "recovery", "public_promotion"
  )
  if (!is.character(action) || length(action) != 1L || is.na(action) ||
      !action %in% allowed_actions) {
    stop("The Draft.85c4m action is outside the adapter contract.",
         call. = FALSE)
  }
  if (!is.function(callback)) {
    stop("`callback` must be a function.", call. = FALSE)
  }
  if (!is.logical(authorize) || length(authorize) != 1L || is.na(authorize)) {
    stop("`authorize` must be TRUE or FALSE.", call. = FALSE)
  }
  mfrmr_gtvt_assert_manifest(
    manifest, plan, generator_manifest, c3_manifest, c4e_manifest,
    c4f_manifest, repair_receipt, qualification_receipt,
    capability_evidence, c4l_receipt, repair_worker_environment,
    qualification_worker_environment, capability_worker_environment,
    adapter_worker_environment, repo_root, validation_dir
  )
  stop(
    "Draft.85c4m proves planned-adapter schema only; process isolation and ",
    "every candidate, study, recovery, decision, and public dispatch remain ",
    "closed.", call. = FALSE
  )
}
