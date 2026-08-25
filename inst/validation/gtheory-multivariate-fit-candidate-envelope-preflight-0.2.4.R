# Draft.85c4o fit-candidate envelope and dispatch-contract preflight.
#
# Repository-internal only. This layer uses one nonreserved c2 fixture to
# exercise the observation-linked candidate-data release and all four qualified
# route envelopes. The standalone worker validates the contract and refuses
# fitting.
# No planned candidate data are generated and no estimator is invoked.

mfrmr_gtvv_require_primitives <- function() {
  required <- c(
    "mfrmr_gtvd_assert_plan", "mfrmr_gtve_assert_manifest",
    "mfrmr_gtve_generate_fixture", "mfrmr_gtve_assert_generation",
    "mfrmr_gtvu_assert_evidence"
  )
  target <- environment(mfrmr_gtvv_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.85c1/c2 and the c3-through-c4n chain before c4o: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtvv_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4o requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvv_file_hash <- function(path) {
  path <- normalizePath(path, mustWork = TRUE)
  if (dir.exists(path)) {
    stop("A Draft.85c4o source file is required.", call. = FALSE)
  }
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtvv_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    identical(sort(names(attributes(object))), c("class", "names"))
}

mfrmr_gtvv_function_hash <- function(fun) {
  if (!is.function(fun)) {
    stop("A Draft.85c4o implementation function is missing.", call. = FALSE)
  }
  mfrmr_gtvv_hash(list(
    Formals = paste(deparse(formals(fun), width.cutoff = 500L),
                    collapse = "\n"),
    Body = paste(deparse(body(fun), width.cutoff = 500L), collapse = "\n")
  ))
}

mfrmr_gtvv_worker_functions <- function() {
  c(
    "mfrmr_gtvvw_hash", "mfrmr_gtvvw_exact_object",
    "mfrmr_gtvvw_candidate_schema", "mfrmr_gtvvw_assert_envelope",
    "mfrmr_gtvvw_receive"
  )
}

mfrmr_gtvv_worker_identity <- function(worker_environment) {
  functions <- mfrmr_gtvv_worker_functions()
  if (!is.environment(worker_environment) ||
      !identical(parent.env(worker_environment), baseenv()) ||
      !identical(
        sort(ls(worker_environment, all.names = TRUE), method = "radix"),
        sort(functions, method = "radix")
      ) || !all(vapply(functions, function(name) {
        is.function(get(name, envir = worker_environment, inherits = FALSE))
      }, logical(1L)))) {
    stop("The Draft.85c4o contract-worker namespace was altered.",
         call. = FALSE)
  }
  data.frame(
    Function = functions,
    SHA256 = vapply(functions, function(name) {
      mfrmr_gtvv_function_hash(get(
        name, envir = worker_environment, inherits = FALSE
      ))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvv_worker_static_audit <- function(worker_environment) {
  mfrmr_gtvv_worker_identity(worker_environment)
  calls <- c(
    "source", "sys.source", "readRDS", "readLines", "scan", "file",
    "url", "socketConnection", "download.file", "system", "system2",
    "lmer", "glmmTMB"
  )
  text <- paste(vapply(mfrmr_gtvv_worker_functions(), function(name) {
    fun <- get(name, envir = worker_environment, inherits = FALSE)
    paste(deparse(body(fun), width.cutoff = 500L), collapse = "\n")
  }, character(1L)), collapse = "\n")
  present <- vapply(calls, function(call) {
    grepl(paste0("\\b", gsub("\\.", "\\\\.", call), "\\s*\\("),
          text, perl = TRUE)
  }, logical(1L))
  data.frame(
    ForbiddenCallOrdinal = seq_along(calls),
    ForbiddenCall = calls,
    Present = unname(present),
    Passed = !unname(present),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvv_candidate_schema <- function(data) {
  list(
    Names = names(data),
    Classes = unname(vapply(
      data, function(value) class(value)[[1L]], character(1L)
    )),
    RowNames = row.names(data)
  )
}

mfrmr_gtvv_observation_links <- function(data) {
  required <- c("Object", "Rater", "Replicate")
  if (!is.data.frame(data) || !all(required %in% names(data)) ||
      anyNA(data[required]) ||
      !all(vapply(data[c("Object", "Rater")], is.character, logical(1L))) ||
      !is.integer(data$Replicate) || any(data$Replicate < 1L)) {
    stop("Draft.85c4o requires canonical within-cell observation identity.",
         call. = FALSE)
  }
  vapply(seq_len(nrow(data)), function(index) {
    paste0("OL-", substr(mfrmr_gtvv_hash(list(
      Namespace =
        "gtheory_multivariate_within_cell_observation_link_draft85c4o_v2",
      Object = data$Object[[index]],
      Rater = data$Rater[[index]],
      WithinCellOrdinal = data$Replicate[[index]]
    )), 1L, 24L))
  }, character(1L))
}

mfrmr_gtvv_candidate_release <- function(
    generation, method_id, plan, generator_manifest, c4l_receipt) {
  registry <- generator_manifest$FixtureRegistry
  mfrmr_gtve_assert_generation(generation, plan, registry)
  method_index <- match(method_id, plan$MethodRegistry$MethodId)
  if (is.na(method_index)) {
    stop("A canonical Draft.85c1 method is required.", call. = FALSE)
  }
  method <- plan$MethodRegistry[method_index, , drop = FALSE]
  qualification_route_id <- if (identical(method$Backend, "glmmTMB")) {
    sub("^glmmtmb", "glmmTMB", method$MethodId)
  } else method$MethodId
  route_index <- match(
    qualification_route_id, c4l_receipt$QualificationRouteRegistry$RouteId
  )
  if (is.na(route_index) ||
      !isTRUE(c4l_receipt$QualificationRouteRegistry$ReceiptReady[[
        route_index
      ]])) {
    stop("The Draft.85c4o route lacks trusted c4l qualification.",
         call. = FALSE)
  }
  scenario_index <- match(
    generation$Identity$ScenarioId, plan$ScenarioRegistry$ScenarioId
  )
  if (is.na(scenario_index)) {
    stop("The nonreserved generation scenario is not canonical.",
         call. = FALSE)
  }
  coordinate_layout_id <-
    plan$ScenarioRegistry$CoordinateLayoutId[[scenario_index]]
  coordinate_count <- as.integer(sum(
    plan$CoordinateLayouts$CoordinateLayoutId == coordinate_layout_id
  ))
  original <- generation$CandidateData
  released <- original[c(
    "RowId", "Stratum", "Object", "Rater", "ObjectRater", "Score"
  )]
  released$ObservationLink <- mfrmr_gtvv_observation_links(original)
  released <- released[c(
    "RowId", "Stratum", "Object", "Rater", "ObjectRater",
    "ObservationLink", "Score"
  )]
  if (!identical(setdiff(names(original), names(released)), "Replicate") ||
      "Replicate" %in% names(released)) {
    stop("The Draft.85c4o release transform changed.", call. = FALSE)
  }
  schema <- mfrmr_gtvv_candidate_schema(released)
  data_hash <- mfrmr_gtvv_hash(released)
  schema_hash <- mfrmr_gtvv_hash(schema)
  opaque_id <- paste0("C4O-", substr(mfrmr_gtvv_hash(list(
    Namespace = "gtheory_multivariate_fit_candidate_exercise_draft85c4o_v1",
    CandidateDataHash = data_hash,
    CandidateSchemaHash = schema_hash,
    MethodId = method$MethodId,
    MethodControlHash = method$MethodControlHash,
    BackendQualificationReceiptHash = c4l_receipt$ReceiptHash
  )), 1L, 24L))
  payload <- list(
    Contract = "gtheory_multivariate_fit_candidate_envelope_draft85c4o_v1",
    OpaqueExerciseId = opaque_id,
    EvidenceUse = "nonreserved_fixture_interface_only",
    MethodId = method$MethodId,
    QualificationRouteId = qualification_route_id,
    Backend = method$Backend,
    Criterion = method$Criterion,
    MethodControlHash = method$MethodControlHash,
    CoordinateLayoutId = coordinate_layout_id,
    CoordinateCount = coordinate_count,
    CandidateData = released,
    CandidateDataHash = data_hash,
    CandidateSchema = schema,
    CandidateSchemaHash = schema_hash,
    ExpectedRows = as.integer(nrow(released)),
    BackendQualificationReceiptHash = c4l_receipt$ReceiptHash,
    BackendQualificationRouteRegistryHash =
      c4l_receipt$QualificationRouteRegistryHash,
    InputAuthority = "generator_candidate_release_only",
    FitAuthority = "separate_candidate_process_successor_contract_only"
  )
  structure(c(payload, list(
    EnvelopeHash = mfrmr_gtvv_hash(payload),
    CandidatePayloadOnly = TRUE,
    ProtectedMaterialExcluded = TRUE,
    BackendQualificationBound = TRUE,
    BackendExecutionAuthorized = FALSE,
    PlannedCandidate = FALSE,
    RecoveryDenominatorEligible = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvvw_envelope", "list"))
}

mfrmr_gtvv_assert_candidate_envelope <- function(
    envelope, generation, method_id, plan, generator_manifest,
    c4l_receipt) {
  canonical <- mfrmr_gtvv_candidate_release(
    generation, method_id, plan, generator_manifest, c4l_receipt
  )
  if (!mfrmr_gtvv_exact_object(
    envelope, names(canonical), class(canonical)
  ) || !identical(envelope, canonical)) {
    stop("The Draft.85c4o candidate envelope was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvv_worker_receipt <- function(envelope, worker_environment) {
  mfrmr_gtvv_worker_identity(worker_environment)
  receive <- get("mfrmr_gtvvw_receive", envir = worker_environment,
                 inherits = FALSE)
  receipt <- receive(envelope)
  mfrmr_gtvv_assert_worker_receipt(receipt, envelope, worker_environment)
  receipt
}

mfrmr_gtvv_assert_worker_receipt <- function(
    receipt, envelope, worker_environment) {
  mfrmr_gtvv_worker_identity(worker_environment)
  receive <- get("mfrmr_gtvvw_receive", envir = worker_environment,
                 inherits = FALSE)
  expected <- receive(envelope)
  if (!mfrmr_gtvv_exact_object(
    receipt, names(expected), class(expected)
  ) || !identical(receipt, expected)) {
    stop("The Draft.85c4o contract-worker receipt was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvv_exercise_bundle <- function(
    plan, generator_manifest, c4l_receipt, worker_environment) {
  registry <- generator_manifest$FixtureRegistry
  generation <- mfrmr_gtve_generate_fixture(
    registry$FixtureId[[1L]], plan, registry
  )
  mfrmr_gtve_assert_generation(generation, plan, registry)
  methods <- plan$MethodRegistry$MethodId
  envelopes <- receipts <- setNames(vector("list", length(methods)), methods)
  rows <- vector("list", length(methods))
  for (index in seq_along(methods)) {
    envelope <- mfrmr_gtvv_candidate_release(
      generation, methods[[index]], plan, generator_manifest, c4l_receipt
    )
    receipt <- mfrmr_gtvv_worker_receipt(envelope, worker_environment)
    envelopes[[methods[[index]]]] <- envelope
    receipts[[methods[[index]]]] <- receipt
    rows[[index]] <- data.frame(
      RouteOrdinal = as.integer(index),
      MethodId = envelope$MethodId,
      QualificationRouteId = envelope$QualificationRouteId,
      Backend = envelope$Backend,
      Criterion = envelope$Criterion,
      OpaqueExerciseId = envelope$OpaqueExerciseId,
      CandidateDataHash = envelope$CandidateDataHash,
      CandidateSchemaHash = envelope$CandidateSchemaHash,
      ExpectedRows = envelope$ExpectedRows,
      ObservedRows = receipt$ObservedRows,
      EnvelopeHash = envelope$EnvelopeHash,
      ReceiptHash = receipt$ReceiptHash,
      EnvelopeAccepted = receipt$EnvelopeAccepted,
      Attempted = receipt$Attempted,
      BackendInvoked = receipt$BackendInvoked,
      FitReturned = receipt$FitReturned,
      FitCapableWorkerImplemented = receipt$FitCapableWorkerImplemented,
      stringsAsFactors = FALSE
    )
  }
  exercise <- do.call(rbind, rows)
  row.names(exercise) <- NULL
  protected_source <- list(
    FixtureId = generation$Identity$FixtureId,
    ScenarioId = generation$Identity$ScenarioId,
    AssignmentId = generation$Identity$AssignmentId,
    ReferenceId = generation$Identity$ReferenceId,
    FixtureSeed = generation$Identity$FixtureSeed,
    TruthAuditHash = generation$Identity$TruthAuditHash
  )
  first <- envelopes[[1L]]
  release_audit <- data.frame(
    OriginalColumnCount = as.integer(ncol(generation$CandidateData)),
    ReleasedColumnCount = as.integer(ncol(first$CandidateData)),
    RemovedColumn = "Replicate",
    AddedColumn = "ObservationLink",
    ObservationLinkUniqueWithinStratum = !anyDuplicated(paste(
      first$CandidateData$Stratum, first$CandidateData$Object,
      first$CandidateData$ObservationLink, sep = "\036"
    )),
    CandidateRows = as.integer(nrow(first$CandidateData)),
    CandidateDataHash = first$CandidateDataHash,
    CandidateSchemaHash = first$CandidateSchemaHash,
    ProtectedSourceContentRetained = FALSE,
    stringsAsFactors = FALSE
  )
  list(
    Envelopes = envelopes,
    Receipts = receipts,
    ExerciseRegistry = exercise,
    ReleaseAudit = release_audit,
    ProtectedSourceAuditHash = mfrmr_gtvv_hash(protected_source),
    CandidateSchema = first$CandidateSchema,
    EnvelopeSchema = list(Class = class(first), Fields = names(first)),
    ReceiptSchema = list(
      Class = class(receipts[[1L]]), Fields = names(receipts[[1L]])
    )
  )
}

mfrmr_gtvv_route_contract_registry <- function(plan, c4l_receipt) {
  methods <- plan$MethodRegistry
  route_ids <- ifelse(
    methods$Backend == "glmmTMB",
    sub("^glmmtmb", "glmmTMB", methods$MethodId), methods$MethodId
  )
  matched <- match(route_ids, c4l_receipt$QualificationRouteRegistry$RouteId)
  if (anyNA(matched)) {
    stop("The c1 methods and c4l qualified routes do not join.",
         call. = FALSE)
  }
  routes <- c4l_receipt$QualificationRouteRegistry[matched, , drop = FALSE]
  data.frame(
    MethodOrdinal = methods$MethodOrdinal,
    MethodId = methods$MethodId,
    Backend = methods$Backend,
    Criterion = methods$Criterion,
    MethodControlHash = methods$MethodControlHash,
    QualificationRouteId = route_ids,
    TrustedQualificationReceiptHash =
      routes$TrustedQualificationReceiptHash,
    FitSpecificationHash = routes$FitSpecificationHash,
    SemanticModelHash = routes$SemanticModelHash,
    QualifiedProcessCapabilityIsolationReady =
      routes$ProcessCapabilityIsolationReady,
    RouteReceiptReady = routes$ReceiptReady,
    CandidateFitContractMayInvokeBackend = rep(TRUE, nrow(methods)),
    FitCapableWorkerImplementedInC4O = rep(FALSE, nrow(methods)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvv_planned_topology_registry <- function(
    plan, c4m_manifest) {
  units <- plan$CandidateUnitManifest
  rows <- lapply(seq_len(nrow(plan$StageCatalog)), function(index) {
    stage <- plan$StageCatalog[index, , drop = FALSE]
    selected <- units$StageId == stage$StageId
    c4m_index <- match(stage$StageId, c4m_manifest$LaneAdapterRegistry$StageId)
    data.frame(
      StageOrdinal = stage$StageOrdinal,
      StageId = stage$StageId,
      LaneOpaqueId = stage$LaneOpaqueId,
      PlannedDatasetCount = as.integer(length(unique(
        units$OpaqueDatasetId[selected]
      ))),
      PlannedMethodUnitCount = as.integer(sum(selected)),
      C4MExpectedUnits = c4m_manifest$LaneAdapterRegistry$ExpectedUnits[[
        c4m_index
      ]],
      FourRoutesPerDataset = identical(
        as.integer(sum(selected)),
        4L * as.integer(length(unique(units$OpaqueDatasetId[selected])))
      ),
      SecondDenominatorCreated = FALSE,
      stringsAsFactors = FALSE
    )
  })
  registry <- do.call(rbind, rows)
  row.names(registry) <- NULL
  registry
}

mfrmr_gtvv_access_registry <- function(bundle) {
  envelope_fields <- c(
    bundle$EnvelopeSchema$Fields, bundle$CandidateSchema$Names
  )
  questions <- c(
    "scenario_identity", "data_seed", "reference_identity", "truth",
    "accuracy_threshold"
  )
  forbidden <- c(
    "ScenarioId|ScenarioOrdinal|OpaqueScenarioToken|StageId",
    "Replicate|DataSeed|FixtureSeed|AssignmentId",
    "ReferenceId|ReferenceCovarianceHash|ReferenceFactorRegistry",
    paste0(
      "TruthAudit|TruthValue|GeneratingCovariance|GeneratingFactor|",
      "ExpectedPreFitState|BoundaryClass"
    ),
    "RecoveryThreshold|AccuracyThreshold|CriterionTable"
  )
  present <- vapply(strsplit(forbidden, "\\|"), function(fields) {
    any(fields %in% envelope_fields)
  }, logical(1L))
  data.frame(
    QuestionOrdinal = 1:5,
    QuestionId = questions,
    ForbiddenFieldSet = forbidden,
    ForbiddenFieldPresent = unname(present),
    CandidateContractCanRead = rep(FALSE, 5L),
    ProtectedMaterialPresent = rep(FALSE, 5L),
    FitWorkerCapabilityRecheckRequired = rep(TRUE, 5L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvv_authority_registry <- function() {
  data.frame(
    AuthorityOrdinal = 1:3,
    AuthorityId = c(
      "generator_vault", "candidate_release_transform",
      "candidate_fit_contract"
    ),
    ProtectedMaterialMayBeRead = c(TRUE, TRUE, FALSE),
    CandidateDataMayBeRead = c(TRUE, TRUE, TRUE),
    BackendContractMayBeInvoked = c(FALSE, FALSE, TRUE),
    ImplementedInC4O = c(TRUE, TRUE, FALSE),
    ProcessCapabilityIsolationAssessed = rep(FALSE, 3L),
    CrossAuthorityObjectRetained = rep(FALSE, 3L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvv_prerequisite_projection <- function(c4n_evidence) {
  prior <- c4n_evidence$PrerequisiteProjection
  truth_index <- match("truth_blind_process_boundary", prior$PrerequisiteId)
  if (!is.data.frame(prior) || is.na(truth_index) ||
      !identical(sum(prior$C4NProjectedSatisfied), 2L) ||
      isTRUE(prior$C4NProjectedSatisfied[[truth_index]])) {
    stop("The Draft.85c4n prerequisite state is not canonical for c4o.",
         call. = FALSE)
  }
  evidence_state <- prior$EvidenceState
  evidence_state[[truth_index]] <- paste0(
    "fit_candidate_envelope_and_route_contract_ready_",
    "fit_worker_and_capability_isolation_missing"
  )
  data.frame(
    PrerequisiteOrdinal = prior$PrerequisiteOrdinal,
    PrerequisiteId = prior$PrerequisiteId,
    Requirement = prior$Requirement,
    C4NProjectedSatisfied = prior$C4NProjectedSatisfied,
    C4OProjectedSatisfied = prior$C4NProjectedSatisfied,
    TransitionedByC4O = rep(FALSE, nrow(prior)),
    PartialExecutionAllowed = prior$PartialExecutionAllowed,
    EvidenceState = evidence_state,
    FitCandidateEnvelopeContractEvidenceAvailable =
      seq_len(nrow(prior)) == truth_index,
    FitCapableWorkerEvidenceAvailable = rep(FALSE, nrow(prior)),
    FitCapableProcessIsolationEvidenceAvailable = rep(FALSE, nrow(prior)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvv_payload_fields <- function() {
  c(
    "Contract", "PlanHash", "PlanCoreHash", "GeneratorManifestHash",
    "C3ManifestHash", "C4LReceiptHash", "C4MManifestHash",
    "C4NEvidenceHash", "C4NPrerequisiteProjectionHash",
    "CandidateUnitManifestHash", "WorkerSourceSHA256", "WorkerIdentity",
    "WorkerIdentityHash", "WorkerStaticAudit", "WorkerStaticAuditHash",
    "CandidateDataSchema", "CandidateDataSchemaHash", "EnvelopeSchema",
    "EnvelopeSchemaHash", "ReceiptSchema", "ReceiptSchemaHash",
    "RouteExerciseRegistry", "RouteExerciseRegistryHash", "ReleaseAudit",
    "ReleaseAuditHash", "ProtectedSourceAuditHash",
    "RouteContractRegistry", "RouteContractRegistryHash",
    "PlannedTopologyRegistry", "PlannedTopologyRegistryHash",
    "AccessQuestionRegistry", "AccessQuestionRegistryHash",
    "AuthoritySeparationRegistry", "AuthoritySeparationRegistryHash",
    "PrerequisiteProjection", "PrerequisiteProjectionHash",
    "ImplementationIdentity", "ImplementationIdentityHash",
    "ExerciseEnvelopeObjectsRetained", "ExerciseCandidateDataRetained",
    "ProtectedSourceAuditContentRetained", "PlannedCandidateDataIncluded",
    "NonreservedFixtureCandidateDataExercised",
    "PlannedReplicateIdentityIncluded",
    "WithinCellReplicateOrdinalIncluded", "ObservationLinkIncluded",
    "ScenarioIdentityIncluded", "PlannedSeedMaterialIncluded",
    "ReferenceIdentityIncluded", "ReferenceTruthIncluded",
    "AccuracyThresholdIncluded", "ConQuestRouteIncluded"
  )
}

mfrmr_gtvv_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtvv_require_primitives", "mfrmr_gtvv_hash",
    "mfrmr_gtvv_file_hash", "mfrmr_gtvv_exact_object",
    "mfrmr_gtvv_function_hash", "mfrmr_gtvv_worker_functions",
    "mfrmr_gtvv_worker_identity", "mfrmr_gtvv_worker_static_audit",
    "mfrmr_gtvv_candidate_schema", "mfrmr_gtvv_observation_links",
    "mfrmr_gtvv_candidate_release",
    "mfrmr_gtvv_assert_candidate_envelope", "mfrmr_gtvv_worker_receipt",
    "mfrmr_gtvv_assert_worker_receipt", "mfrmr_gtvv_exercise_bundle",
    "mfrmr_gtvv_route_contract_registry",
    "mfrmr_gtvv_planned_topology_registry", "mfrmr_gtvv_access_registry",
    "mfrmr_gtvv_authority_registry", "mfrmr_gtvv_prerequisite_projection",
    "mfrmr_gtvv_payload_fields", "mfrmr_gtvv_implementation_identity",
    "mfrmr_gtvv_manifest", "mfrmr_gtvv_assert_manifest",
    "mfrmr_gtvv_dispatch_guard"
  )
  target <- environment(mfrmr_gtvv_implementation_identity)
  data.frame(
    Function = functions,
    SHA256 = vapply(functions, function(name) {
      if (!exists(name, envir = target, inherits = FALSE)) {
        stop("A Draft.85c4o function is missing: ", name, ".",
             call. = FALSE)
      }
      mfrmr_gtvv_function_hash(get(name, envir = target, inherits = FALSE))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvv_manifest <- function(
    plan, generator_manifest, c3_manifest, c4e_manifest, c4f_manifest,
    repair_receipt, qualification_receipt, capability_evidence, c4l_receipt,
    c4m_manifest, c4n_evidence, repair_worker_environment,
    qualification_worker_environment, capability_worker_environment,
    adapter_worker_environment, c4n_capability_worker_environment,
    contract_worker_environment, repo_root = ".",
    validation_dir = file.path("inst", "validation")) {
  mfrmr_gtvv_require_primitives()
  mfrmr_gtvd_assert_plan(plan)
  mfrmr_gtve_assert_manifest(
    generator_manifest, plan, generator_manifest$FixtureRegistry
  )
  mfrmr_gtvu_assert_evidence(
    c4n_evidence, plan, generator_manifest, c3_manifest, c4e_manifest,
    c4f_manifest, repair_receipt, qualification_receipt,
    capability_evidence, c4l_receipt, c4m_manifest,
    repair_worker_environment, qualification_worker_environment,
    capability_worker_environment, adapter_worker_environment,
    c4n_capability_worker_environment, repo_root, validation_dir
  )
  if (!identical(c4n_evidence$PlanHash, plan$PlanHash) ||
      !identical(c4n_evidence$C4MManifestHash, c4m_manifest$ManifestHash) ||
      !identical(c4n_evidence$C4LReceiptHash, c4l_receipt$ReceiptHash) ||
      !isTRUE(c4n_evidence$PlannedAdapterProcessCapabilityIsolationReady) ||
      isTRUE(c4n_evidence$TruthBlindProcessBoundaryReady)) {
    stop("The Draft.85c4o parent roots or scope state changed.",
         call. = FALSE)
  }
  validation_dir <- normalizePath(validation_dir, mustWork = TRUE)
  worker_source <- file.path(
    validation_dir,
    "gtheory-multivariate-fit-candidate-envelope-worker-0.2.4.R"
  )
  worker_identity <- mfrmr_gtvv_worker_identity(contract_worker_environment)
  worker_audit <- mfrmr_gtvv_worker_static_audit(
    contract_worker_environment
  )
  if (!all(worker_audit$Passed)) {
    stop("The Draft.85c4o contract worker contains an execution call.",
         call. = FALSE)
  }
  bundle <- mfrmr_gtvv_exercise_bundle(
    plan, generator_manifest, c4l_receipt, contract_worker_environment
  )
  route_contracts <- mfrmr_gtvv_route_contract_registry(plan, c4l_receipt)
  topology <- mfrmr_gtvv_planned_topology_registry(plan, c4m_manifest)
  access <- mfrmr_gtvv_access_registry(bundle)
  authorities <- mfrmr_gtvv_authority_registry()
  prerequisites <- mfrmr_gtvv_prerequisite_projection(c4n_evidence)
  implementation <- mfrmr_gtvv_implementation_identity()
  if (any(access$ForbiddenFieldPresent) ||
      any(access$CandidateContractCanRead) ||
      !all(route_contracts$RouteReceiptReady) ||
      !all(topology$FourRoutesPerDataset) ||
      !identical(topology$PlannedMethodUnitCount,
                 topology$C4MExpectedUnits) ||
      !identical(sum(topology$PlannedMethodUnitCount), 20168L)) {
    stop("The Draft.85c4o interface topology or access audit changed.",
         call. = FALSE)
  }
  payload <- list(
    Contract = "gtheory_multivariate_fit_candidate_contract_draft85c4o_v1",
    PlanHash = plan$PlanHash,
    PlanCoreHash = plan$PlanCoreHash,
    GeneratorManifestHash = generator_manifest$ManifestHash,
    C3ManifestHash = c3_manifest$ManifestHash,
    C4LReceiptHash = c4l_receipt$ReceiptHash,
    C4MManifestHash = c4m_manifest$ManifestHash,
    C4NEvidenceHash = c4n_evidence$EvidenceHash,
    C4NPrerequisiteProjectionHash =
      c4n_evidence$PrerequisiteProjectionHash,
    CandidateUnitManifestHash = plan$CandidateUnitManifestHash,
    WorkerSourceSHA256 = mfrmr_gtvv_file_hash(worker_source),
    WorkerIdentity = worker_identity,
    WorkerIdentityHash = mfrmr_gtvv_hash(worker_identity),
    WorkerStaticAudit = worker_audit,
    WorkerStaticAuditHash = mfrmr_gtvv_hash(worker_audit),
    CandidateDataSchema = bundle$CandidateSchema,
    CandidateDataSchemaHash = mfrmr_gtvv_hash(bundle$CandidateSchema),
    EnvelopeSchema = bundle$EnvelopeSchema,
    EnvelopeSchemaHash = mfrmr_gtvv_hash(bundle$EnvelopeSchema),
    ReceiptSchema = bundle$ReceiptSchema,
    ReceiptSchemaHash = mfrmr_gtvv_hash(bundle$ReceiptSchema),
    RouteExerciseRegistry = bundle$ExerciseRegistry,
    RouteExerciseRegistryHash = mfrmr_gtvv_hash(bundle$ExerciseRegistry),
    ReleaseAudit = bundle$ReleaseAudit,
    ReleaseAuditHash = mfrmr_gtvv_hash(bundle$ReleaseAudit),
    ProtectedSourceAuditHash = bundle$ProtectedSourceAuditHash,
    RouteContractRegistry = route_contracts,
    RouteContractRegistryHash = mfrmr_gtvv_hash(route_contracts),
    PlannedTopologyRegistry = topology,
    PlannedTopologyRegistryHash = mfrmr_gtvv_hash(topology),
    AccessQuestionRegistry = access,
    AccessQuestionRegistryHash = mfrmr_gtvv_hash(access),
    AuthoritySeparationRegistry = authorities,
    AuthoritySeparationRegistryHash = mfrmr_gtvv_hash(authorities),
    PrerequisiteProjection = prerequisites,
    PrerequisiteProjectionHash = mfrmr_gtvv_hash(prerequisites),
    ImplementationIdentity = implementation,
    ImplementationIdentityHash = mfrmr_gtvv_hash(implementation),
    ExerciseEnvelopeObjectsRetained = FALSE,
    ExerciseCandidateDataRetained = FALSE,
    ProtectedSourceAuditContentRetained = FALSE,
    PlannedCandidateDataIncluded = FALSE,
    NonreservedFixtureCandidateDataExercised = TRUE,
    PlannedReplicateIdentityIncluded = FALSE,
    WithinCellReplicateOrdinalIncluded = FALSE,
    ObservationLinkIncluded = TRUE,
    ScenarioIdentityIncluded = FALSE,
    PlannedSeedMaterialIncluded = FALSE,
    ReferenceIdentityIncluded = FALSE,
    ReferenceTruthIncluded = FALSE,
    AccuracyThresholdIncluded = FALSE,
    ConQuestRouteIncluded = FALSE
  )
  structure(c(payload, list(
    ManifestHash = mfrmr_gtvv_hash(payload),
    ContractWorkerImplemented = TRUE,
    WorkerNamespaceSeparationReady = TRUE,
    WorkerStaticNoExecutionAuditReady = TRUE,
    CandidateReleaseTransformReady = TRUE,
    CandidateDataObservationLinkSchemaReady = TRUE,
    RawWithinCellReplicateRemoved = TRUE,
    ObservationLinkPairIdentityReady = TRUE,
    FourRouteEnvelopeContractReady = TRUE,
    FourRouteReceiptContractReady = TRUE,
    BackendQualificationBound = TRUE,
    BackendQualificationReady = TRUE,
    PlannedDenominatorTopologyBound = TRUE,
    SecondDenominatorAbsent = TRUE,
    AuthoritySeparationContractReady = TRUE,
    ProtectedMaterialExcluded = TRUE,
    PayloadTruthBlindReady = TRUE,
    C4NNonAttemptAdapterCapabilityReady = TRUE,
    FitCapableWorkerImplemented = FALSE,
    FitCapableProcessCapabilityIsolationReady = FALSE,
    TruthBlindProcessBoundaryReady = FALSE,
    PlannedExecutionIsolationReady = FALSE,
    ExactlyZeroC3PrerequisitesTransitioned =
      !any(prerequisites$TransitionedByC4O),
    C3SatisfiedPrerequisiteCount =
      as.integer(sum(prerequisites$C4OProjectedSatisfied)),
    AllExecutionPrerequisitesReady =
      all(prerequisites$C4OProjectedSatisfied),
    ExternalFreezeReady = FALSE,
    CleanSourceIdentityReady = FALSE,
    IndependentAccuracyRuleReady = FALSE,
    PilotExecutionAuthorized = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    NegativeControlExecutionAuthorized = FALSE,
    BackendExecutionOccurred = FALSE,
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
    PublicSupportReady = FALSE,
    ExecutionGateClosed = TRUE
  )), class = c("mfrmr_gtvv_manifest", "list"))
}

mfrmr_gtvv_assert_manifest <- function(
    manifest, plan, generator_manifest, c3_manifest, c4e_manifest,
    c4f_manifest, repair_receipt, qualification_receipt,
    capability_evidence, c4l_receipt, c4m_manifest, c4n_evidence,
    repair_worker_environment, qualification_worker_environment,
    capability_worker_environment, adapter_worker_environment,
    c4n_capability_worker_environment, contract_worker_environment,
    repo_root = ".", validation_dir = file.path("inst", "validation")) {
  canonical <- mfrmr_gtvv_manifest(
    plan, generator_manifest, c3_manifest, c4e_manifest, c4f_manifest,
    repair_receipt, qualification_receipt, capability_evidence, c4l_receipt,
    c4m_manifest, c4n_evidence, repair_worker_environment,
    qualification_worker_environment, capability_worker_environment,
    adapter_worker_environment, c4n_capability_worker_environment,
    contract_worker_environment, repo_root, validation_dir
  )
  if (!mfrmr_gtvv_exact_object(
    manifest, names(canonical), class(canonical)
  ) || !identical(manifest, canonical)) {
    stop("The Draft.85c4o manifest, contract, or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvv_dispatch_guard <- function(
    manifest, action, callback, ..., authorize = FALSE,
    plan, generator_manifest, c3_manifest, c4e_manifest, c4f_manifest,
    repair_receipt, qualification_receipt, capability_evidence, c4l_receipt,
    c4m_manifest, c4n_evidence, repair_worker_environment,
    qualification_worker_environment, capability_worker_environment,
    adapter_worker_environment, c4n_capability_worker_environment,
    contract_worker_environment, repo_root = ".",
    validation_dir = file.path("inst", "validation")) {
  allowed_actions <- c(
    "fit_worker", "candidate_execution", "pilot", "confirmation",
    "negative_control", "planned_response", "recovery", "public_promotion"
  )
  if (!is.character(action) || length(action) != 1L || is.na(action) ||
      !action %in% allowed_actions) {
    stop("The Draft.85c4o action is outside the contract.", call. = FALSE)
  }
  if (!is.function(callback)) {
    stop("`callback` must be a function.", call. = FALSE)
  }
  if (!is.logical(authorize) || length(authorize) != 1L || is.na(authorize)) {
    stop("`authorize` must be TRUE or FALSE.", call. = FALSE)
  }
  mfrmr_gtvv_assert_manifest(
    manifest, plan, generator_manifest, c3_manifest, c4e_manifest,
    c4f_manifest, repair_receipt, qualification_receipt,
    capability_evidence, c4l_receipt, c4m_manifest, c4n_evidence,
    repair_worker_environment, qualification_worker_environment,
    capability_worker_environment, adapter_worker_environment,
    c4n_capability_worker_environment, contract_worker_environment,
    repo_root, validation_dir
  )
  stop(
    "Draft.85c4o defines the candidate-fit contract only; the fit-capable ",
    "worker, its capability isolation, and every execution dispatch remain ",
    "closed.", call. = FALSE
  )
}
