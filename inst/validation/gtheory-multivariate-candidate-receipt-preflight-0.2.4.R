# Draft.85c4a candidate-envelope and receipt-schema preflight.
#
# Repository-internal only. This controller exercises the standalone worker on
# c2 nonreserved fixtures. It establishes payload and namespace separation, not
# OS capability isolation, backend readiness, or execution authority.

mfrmr_gtvg_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtvd_plan", "mfrmr_gtvd_assert_plan",
    "mfrmr_gtve_manifest", "mfrmr_gtve_assert_manifest",
    "mfrmr_gtve_generate_fixture", "mfrmr_gtve_assert_generation"
  )
  target <- environment(mfrmr_gtvg_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.81 and the Draft.85a0-c2 chain before Draft.85c4a: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtvg_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    setequal(names(attributes(object)), c("names", "class"))
}

mfrmr_gtvg_worker_functions <- function() {
  c(
    "mfrmr_gtvgw_hash", "mfrmr_gtvgw_exact_object",
    "mfrmr_gtvgw_candidate_schema", "mfrmr_gtvgw_receive"
  )
}

mfrmr_gtvg_function_hash <- function(fun) {
  if (!is.function(fun)) {
    stop("A Draft.85c4a function identity is missing.", call. = FALSE)
  }
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtvg_worker_identity <- function(worker_environment) {
  if (!is.environment(worker_environment) ||
      !identical(parent.env(worker_environment), baseenv())) {
    stop("The Draft.85c4a worker must have baseenv() as its parent.",
         call. = FALSE)
  }
  required <- mfrmr_gtvg_worker_functions()
  bindings <- sort(ls(worker_environment, all.names = TRUE), method = "radix")
  if (!identical(bindings, sort(required, method = "radix"))) {
    stop("The candidate worker namespace has missing or additional bindings.",
         call. = FALSE)
  }
  functions <- lapply(required, get, envir = worker_environment,
                      inherits = FALSE)
  if (!all(vapply(functions, is.function, logical(1L)))) {
    stop("Every candidate worker binding must be a function.", call. = FALSE)
  }
  data.frame(
    Function = required,
    SHA256 = vapply(functions, mfrmr_gtvg_function_hash, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvg_candidate_schema <- function(data) {
  list(
    Names = names(data),
    Classes = unname(vapply(data, function(value) class(value)[[1L]],
                            character(1L))),
    RowNames = row.names(data)
  )
}

mfrmr_gtvg_candidate_envelope <- function(
    generation, plan = mfrmr_gtvd_plan(),
    registry = mfrmr_gtve_fixture_registry(plan),
    upstream_validated = FALSE) {
  if (!is.logical(upstream_validated) || length(upstream_validated) != 1L ||
      is.na(upstream_validated)) {
    stop("`upstream_validated` must be TRUE or FALSE.", call. = FALSE)
  }
  if (!isTRUE(upstream_validated)) {
    mfrmr_gtve_assert_generation(generation, plan, registry)
  }
  data <- generation$CandidateData
  expected_columns <- c(
    "RowId", "Stratum", "Object", "Rater", "ObjectRater", "Replicate",
    "Score"
  )
  if (!is.data.frame(data) || !identical(names(data), expected_columns) ||
      anyNA(data) || !all(is.finite(data$Score))) {
    stop("A canonical c2 candidate-only data table is required.",
         call. = FALSE)
  }
  data_hash <- mfrmr_gta_hash(data)
  schema_hash <- mfrmr_gta_hash(mfrmr_gtvg_candidate_schema(data))
  opaque_id <- paste0("C4A-", substr(mfrmr_gta_hash(list(
    Namespace = "gtheory_multivariate_candidate_draft85c4a_v1",
    CandidateDataHash = data_hash,
    CandidateSchemaHash = schema_hash
  )), 1L, 24L))
  payload <- list(
    Contract = "gtheory_multivariate_candidate_envelope_draft85c4a_v1",
    OpaqueCandidateId = opaque_id,
    EvidenceUse = "nonreserved_fixture_schema_only",
    CandidateData = data,
    CandidateDataHash = data_hash,
    CandidateSchemaHash = schema_hash,
    ExpectedRows = as.integer(nrow(data))
  )
  structure(c(payload, list(
    EnvelopeHash = mfrmr_gta_hash(payload),
    CandidatePayloadOnly = TRUE,
    BackendExecutionAuthorized = FALSE,
    RecoveryDenominatorEligible = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvg_candidate_envelope", "list"))
}

mfrmr_gtvg_assert_candidate_envelope <- function(envelope) {
  payload_fields <- c(
    "Contract", "OpaqueCandidateId", "EvidenceUse", "CandidateData",
    "CandidateDataHash", "CandidateSchemaHash", "ExpectedRows"
  )
  suffix_fields <- c(
    "EnvelopeHash", "CandidatePayloadOnly", "BackendExecutionAuthorized",
    "RecoveryDenominatorEligible", "PublicSupportReady"
  )
  if (!mfrmr_gtvg_exact_object(
    envelope, c(payload_fields, suffix_fields),
    c("mfrmr_gtvg_candidate_envelope", "list")
  )) {
    stop("A typed Draft.85c4a candidate envelope is required.",
         call. = FALSE)
  }
  data <- envelope$CandidateData
  expected_columns <- c(
    "RowId", "Stratum", "Object", "Rater", "ObjectRater", "Replicate",
    "Score"
  )
  schema_hash <- mfrmr_gta_hash(mfrmr_gtvg_candidate_schema(data))
  expected_opaque_id <- paste0("C4A-", substr(mfrmr_gta_hash(list(
    Namespace = "gtheory_multivariate_candidate_draft85c4a_v1",
    CandidateDataHash = mfrmr_gta_hash(data),
    CandidateSchemaHash = schema_hash
  )), 1L, 24L))
  valid <-
    identical(envelope$Contract,
              "gtheory_multivariate_candidate_envelope_draft85c4a_v1") &&
    identical(envelope$OpaqueCandidateId, expected_opaque_id) &&
    identical(envelope$EvidenceUse, "nonreserved_fixture_schema_only") &&
    is.data.frame(data) && identical(names(data), expected_columns) &&
    all(vapply(data[expected_columns[1:5]], is.character, logical(1L))) &&
    is.integer(data$Replicate) && is.numeric(data$Score) &&
    nrow(data) > 0L && !anyNA(data) && all(is.finite(data$Score)) &&
    identical(envelope$ExpectedRows, as.integer(nrow(data))) &&
    identical(envelope$CandidateDataHash, mfrmr_gta_hash(data)) &&
    identical(
      envelope$CandidateSchemaHash,
      schema_hash
    ) &&
    identical(
      envelope$EnvelopeHash,
      mfrmr_gta_hash(unclass(envelope[payload_fields]))
    ) &&
    isTRUE(envelope$CandidatePayloadOnly) &&
    !isTRUE(envelope$BackendExecutionAuthorized) &&
    !isTRUE(envelope$RecoveryDenominatorEligible) &&
    !isTRUE(envelope$PublicSupportReady)
  if (!valid) {
    stop("The Draft.85c4a candidate envelope was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvg_worker_receipt <- function(envelope, worker_environment) {
  mfrmr_gtvg_assert_candidate_envelope(envelope)
  mfrmr_gtvg_worker_identity(worker_environment)
  receive <- get("mfrmr_gtvgw_receive", envir = worker_environment,
                 inherits = FALSE)
  receipt <- receive(envelope)
  mfrmr_gtvg_assert_worker_receipt(receipt, envelope, worker_environment)
  receipt
}

mfrmr_gtvg_assert_worker_receipt <- function(
    receipt, envelope, worker_environment) {
  mfrmr_gtvg_assert_candidate_envelope(envelope)
  mfrmr_gtvg_worker_identity(worker_environment)
  receive <- get("mfrmr_gtvgw_receive", envir = worker_environment,
                 inherits = FALSE)
  expected <- receive(envelope)
  if (!identical(receipt, expected)) {
    stop("The Draft.85c4a candidate receipt was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvg_controller_identity <- function() {
  names <- c(
    "mfrmr_gtvg_require_primitives", "mfrmr_gtvg_exact_object",
    "mfrmr_gtvg_worker_functions", "mfrmr_gtvg_function_hash",
    "mfrmr_gtvg_worker_identity", "mfrmr_gtvg_candidate_schema",
    "mfrmr_gtvg_candidate_envelope",
    "mfrmr_gtvg_assert_candidate_envelope", "mfrmr_gtvg_worker_receipt",
    "mfrmr_gtvg_assert_worker_receipt", "mfrmr_gtvg_controller_identity",
    "mfrmr_gtvg_manifest", "mfrmr_gtvg_assert_manifest"
  )
  target <- environment(mfrmr_gtvg_controller_identity)
  data.frame(
    Function = names,
    SHA256 = vapply(names, function(name) {
      if (!exists(name, envir = target, inherits = TRUE)) {
        stop("A Draft.85c4a controller function is missing: ", name, ".",
             call. = FALSE)
      }
      mfrmr_gtvg_function_hash(get(name, envir = target, inherits = TRUE))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvg_manifest <- function(
    worker_environment, plan = mfrmr_gtvd_plan(),
    generator_manifest = mfrmr_gtve_manifest(plan)) {
  mfrmr_gtvd_assert_plan(plan)
  mfrmr_gtve_assert_manifest(
    generator_manifest, plan, generator_manifest$FixtureRegistry
  )
  worker_identity <- mfrmr_gtvg_worker_identity(worker_environment)
  controller_identity <- mfrmr_gtvg_controller_identity()
  registry <- generator_manifest$FixtureRegistry
  receipt_rows <- list()
  vault_rows <- list()
  for (index in seq_len(nrow(registry))) {
    generation <- mfrmr_gtve_generate_fixture(
      registry$FixtureId[[index]], plan, registry
    )
    envelope <- mfrmr_gtvg_candidate_envelope(
      generation, plan, registry, upstream_validated = TRUE
    )
    receipt <- mfrmr_gtvg_worker_receipt(envelope, worker_environment)
    receipt_rows[[index]] <- data.frame(
      CandidateOrdinal = as.integer(index),
      OpaqueCandidateId = envelope$OpaqueCandidateId,
      ExpectedRows = envelope$ExpectedRows,
      CandidateDataHash = envelope$CandidateDataHash,
      CandidateSchemaHash = envelope$CandidateSchemaHash,
      EnvelopeHash = envelope$EnvelopeHash,
      ReceiptHash = receipt$ReceiptHash,
      Attempted = receipt$Attempted,
      FitReturned = receipt$FitReturned,
      EstimateAvailable = receipt$EstimateAvailable,
      PointGatePassed = receipt$PointGatePassed,
      FailureStage = receipt$FailureStage,
      FailureCode = receipt$FailureCode,
      stringsAsFactors = FALSE
    )
    vault_rows[[index]] <- data.frame(
      OpaqueCandidateId = envelope$OpaqueCandidateId,
      FixtureId = generation$Identity$FixtureId,
      ScenarioId = generation$Identity$ScenarioId,
      ReferenceId = generation$Identity$ReferenceId,
      FixtureSeed = generation$Identity$FixtureSeed,
      GenerationHash = generation$GenerationHash,
      TruthAuditHash = generation$Identity$TruthAuditHash,
      stringsAsFactors = FALSE
    )
  }
  receipt_registry <- do.call(rbind, receipt_rows)
  row.names(receipt_registry) <- NULL
  reference_vault <- do.call(rbind, vault_rows)
  row.names(reference_vault) <- NULL
  namespace_audit <- data.frame(
    WorkerParent = environmentName(parent.env(worker_environment)),
    WorkerBindingCount = length(mfrmr_gtvg_worker_functions()),
    WorkerBindingsHash = mfrmr_gta_hash(
      sort(ls(worker_environment, all.names = TRUE), method = "radix")
    ),
    UpstreamPlanBindingsPresent = any(grepl(
      "^mfrmr_gtvd_", ls(worker_environment, all.names = TRUE)
    )),
    GeneratorBindingsPresent = any(grepl(
      "^mfrmr_gtve_", ls(worker_environment, all.names = TRUE)
    )),
    TruthNamedBindingsPresent = any(grepl(
      "truth|reference|seed|scenario", ls(worker_environment, all.names = TRUE),
      ignore.case = TRUE
    )),
    stringsAsFactors = FALSE
  )
  core <- list(
    Contract = "gtheory_multivariate_candidate_receipt_preflight_draft85c4a_v1",
    PlanHash = plan$PlanHash,
    GeneratorManifestHash = generator_manifest$ManifestHash,
    FixtureRegistryHash = generator_manifest$FixtureRegistryHash,
    CandidateReceiptRegistry = receipt_registry,
    NamespaceAudit = namespace_audit,
    ReferenceVaultHash = mfrmr_gta_hash(reference_vault),
    ReferenceVaultRows = as.integer(nrow(reference_vault)),
    ReferenceVaultContentRetained = FALSE
  )
  payload <- c(core, list(
    CoreHash = mfrmr_gta_hash(core),
    CandidateReceiptRegistryHash = mfrmr_gta_hash(receipt_registry),
    NamespaceAuditHash = mfrmr_gta_hash(namespace_audit),
    WorkerIdentity = worker_identity,
    WorkerIdentityHash = mfrmr_gta_hash(worker_identity),
    ControllerIdentity = controller_identity,
    ControllerIdentityHash = mfrmr_gta_hash(controller_identity)
  ))
  structure(c(payload, list(
    ManifestHash = mfrmr_gta_hash(payload),
    CandidateCount = as.integer(nrow(receipt_registry)),
    CandidateEnvelopeSchemaReady = TRUE,
    CandidateReceiptSchemaReady = TRUE,
    WorkerNamespaceSeparationReady = TRUE,
    CandidatePayloadAllowlistReady = TRUE,
    ReferenceVaultContentExcluded = TRUE,
    ProcessCapabilityIsolationReady = FALSE,
    TruthBlindProcessBoundaryReady = FALSE,
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
  )), class = c("mfrmr_gtvg_manifest", "list"))
}

mfrmr_gtvg_assert_manifest <- function(
    manifest, worker_environment, plan = mfrmr_gtvd_plan(),
    generator_manifest = mfrmr_gtve_manifest(plan)) {
  canonical <- mfrmr_gtvg_manifest(worker_environment, plan,
                                    generator_manifest)
  if (!identical(manifest, canonical)) {
    stop("The Draft.85c4a manifest, receipt, namespace, or readiness was altered.",
         call. = FALSE)
  }
  roots <- c(
    CoreHash =
      "9226fa5d8b425705337ef337bc384bd942abb3142ea19ce3adffcda1ab495bb3",
    CandidateReceiptRegistryHash =
      "976bc07b0441bda2c9eecd9f6ac56042934503a75ed56d61a68160520a00c81c",
    NamespaceAuditHash =
      "fbdc8cd1b9719618420fc2d54d3d755c3d82953619f31a0c558b784cd8d964a8",
    WorkerIdentityHash =
      "1dc35fb4a2cb48330232d9b1ab80fd9b1c462ffb04c958457d9a4611da5e7683"
  )
  if (!all(vapply(names(roots), function(name) {
    identical(manifest[[name]], unname(roots[[name]]))
  }, logical(1L)))) {
    stop("The Draft.85c4a literal content roots do not match.", call. = FALSE)
  }
  invisible(TRUE)
}
