# Draft.85c4f multivariate G-theory four-route qualification protocol.
#
# Repository-internal only. This file freezes receipt schemas and acceptance
# semantics before any repaired-environment fit is run. It accepts only
# untrusted candidate summaries and cannot install, fit, trust, or authorize.

mfrmr_gtvm_require_primitives <- function() {
  required <- c(
    "mfrmr_gtvl_environment_identity", "mfrmr_gtvl_manifest",
    "mfrmr_gtvl_assert_manifest"
  )
  target <- environment(mfrmr_gtvm_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the Draft.85c4e admission layer before Draft.85c4f: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtvm_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4f requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvm_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    setequal(names(attributes(object)), c("names", "class"))
}

mfrmr_gtvm_sha256 <- function(value, argument) {
  if (!is.character(value) || length(value) != 1L || is.na(value) ||
      !grepl("^[0-9a-f]{64}$", value)) {
    stop(argument, " must be one lowercase SHA-256 value.", call. = FALSE)
  }
  value
}

mfrmr_gtvm_qualification_policy <- function() {
  routes <- data.frame(
    RouteOrdinal = 1:4,
    RouteId = c("lme4_ml", "lme4_reml", "glmmTMB_ml", "glmmTMB_reml"),
    Backend = rep(c("lme4", "glmmTMB"), each = 2L),
    Criterion = rep(c("ML", "REML"), 2L),
    RequiredFitStatus = rep("identified_point_fit", 4L),
    FreshProcessRequired = rep(TRUE, 4L),
    DiagnosticOverrideProhibited = rep(TRUE, 4L),
    BackendRowsMatchRequired = rep(TRUE, 4L),
    PointEstimationGateRequired = rep(TRUE, 4L),
    ZeroWarningsRequired = rep(TRUE, 4L),
    stringsAsFactors = FALSE
  )
  pairs <- data.frame(
    PairOrdinal = 1:2,
    PairId = c("matched_ml", "matched_reml"),
    Criterion = c("ML", "REML"),
    Lme4RouteId = c("lme4_ml", "lme4_reml"),
    GlmmTMBRouteId = c("glmmTMB_ml", "glmmTMB_reml"),
    ExactSpecificationRequired = rep(TRUE, 2L),
    ExactSemanticModelRequired = rep(TRUE, 2L),
    NumericalParityRequired = rep(TRUE, 2L),
    BothPointGatesRequired = rep(TRUE, 2L),
    DependencyIdentityRequired = rep(TRUE, 2L),
    stringsAsFactors = FALSE
  )
  tolerances <- data.frame(
    ToleranceOrdinal = 1:4,
    ToleranceId = c(
      "covariance_absolute", "covariance_relative",
      "fixed_absolute", "loglik_absolute"
    ),
    Value = c(1e-4, 1e-4, 1e-4, 1e-5),
    Inclusive = rep(TRUE, 4L),
    SourceContract = rep("Draft85b1_compare_defaults", 4L),
    stringsAsFactors = FALSE
  )
  payload <- list(
    Contract =
      "gtheory_multivariate_four_route_qualification_policy_draft85c4f_v1",
    RouteRegistry = routes,
    RouteRegistryHash = mfrmr_gtvm_hash(routes),
    PairRegistry = pairs,
    PairRegistryHash = mfrmr_gtvm_hash(pairs),
    ToleranceRegistry = tolerances,
    ToleranceRegistryHash = mfrmr_gtvm_hash(tolerances),
    FullB1FitObjectsRequired = TRUE,
    FullB1ParityObjectRequired = TRUE,
    SummaryOnlyReceiptSufficient = FALSE,
    PartialRouteQualificationAllowed = FALSE,
    DiagnosticOverrideAllowed = FALSE,
    OutcomeIndependentThresholdClaimed = FALSE,
    ConQuestRouteIncluded = FALSE
  )
  structure(c(payload, list(
    PolicyHash = mfrmr_gtvm_hash(payload),
    ReceiptSchemaReady = TRUE,
    TrustedWorkerImplemented = FALSE,
    QualificationExecuted = FALSE,
    RecoveryExecuted = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvm_policy", "list"))
}

mfrmr_gtvm_assert_policy <- function(policy) {
  canonical <- mfrmr_gtvm_qualification_policy()
  if (!mfrmr_gtvm_exact_object(
    policy, names(canonical), class(canonical)
  ) || !identical(policy, canonical)) {
    stop("The Draft.85c4f qualification policy was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvm_route_receipt_template <- function(
    environment_identity_hash,
    policy = mfrmr_gtvm_qualification_policy()) {
  mfrmr_gtvm_assert_policy(policy)
  mfrmr_gtvm_sha256(environment_identity_hash, "environment_identity_hash")
  routes <- policy$RouteRegistry
  data.frame(
    RouteOrdinal = routes$RouteOrdinal,
    RouteId = routes$RouteId,
    EnvironmentIdentityHash = rep(environment_identity_hash, 4L),
    ProcessIdentityHash = rep(NA_character_, 4L),
    WorkerSourceSHA256 = rep(NA_character_, 4L),
    SpecificationHash = rep(NA_character_, 4L),
    SemanticModelHash = rep(NA_character_, 4L),
    FitResultHash = rep(NA_character_, 4L),
    FitStatus = rep(NA_character_, 4L),
    CandidateReceiptReady = rep(FALSE, 4L),
    TrustedReceiptReady = rep(FALSE, 4L),
    OperationallyAdmissible = rep(FALSE, 4L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvm_route_candidate_receipt <- function(
    route_id, environment_identity_hash, process_identity_hash,
    worker_source_sha256, specification_hash, semantic_model_hash,
    fit_result_hash, fit_status, fit_returned, fit_integrity_passed,
    point_estimation_gate_passed, backend_rows_match, dependency_abi_match,
    fresh_process, diagnostic_override_used, warning_count,
    error_class = NA_character_, policy = mfrmr_gtvm_qualification_policy()) {
  mfrmr_gtvm_assert_policy(policy)
  route <- policy$RouteRegistry[
    policy$RouteRegistry$RouteId == route_id, , drop = FALSE
  ]
  if (nrow(route) != 1L) {
    stop("The Draft.85c4f route is outside the policy.", call. = FALSE)
  }
  hashes <- c(
    EnvironmentIdentityHash = environment_identity_hash,
    ProcessIdentityHash = process_identity_hash,
    WorkerSourceSHA256 = worker_source_sha256,
    SpecificationHash = specification_hash,
    SemanticModelHash = semantic_model_hash,
    FitResultHash = fit_result_hash
  )
  invisible(vapply(names(hashes), function(name) {
    mfrmr_gtvm_sha256(hashes[[name]], name)
  }, character(1L)))
  logical_values <- list(
    FitReturned = fit_returned,
    FitIntegrityPassed = fit_integrity_passed,
    PointEstimationGatePassed = point_estimation_gate_passed,
    BackendRowsMatch = backend_rows_match,
    DependencyABIMatch = dependency_abi_match,
    FreshProcess = fresh_process,
    DiagnosticOverrideUsed = diagnostic_override_used
  )
  if (!all(vapply(logical_values, function(value) {
    is.logical(value) && length(value) == 1L && !is.na(value)
  }, logical(1L)))) {
    stop("Draft.85c4f route states must be exact TRUE/FALSE values.",
         call. = FALSE)
  }
  if (!is.character(fit_status) || length(fit_status) != 1L ||
      is.na(fit_status) || !nzchar(fit_status)) {
    stop("fit_status must be one nonempty character value.", call. = FALSE)
  }
  if (!is.numeric(warning_count) || length(warning_count) != 1L ||
      is.na(warning_count) || !is.finite(warning_count) ||
      warning_count < 0 || warning_count != as.integer(warning_count)) {
    stop("warning_count must be one nonnegative integer.", call. = FALSE)
  }
  if (!is.character(error_class) || length(error_class) != 1L ||
      (!is.na(error_class) && !nzchar(error_class))) {
    stop("error_class must be one nonempty or missing character value.",
         call. = FALSE)
  }
  payload <- c(list(
    Contract =
      "gtheory_multivariate_route_candidate_receipt_draft85c4f_v1",
    PolicyHash = policy$PolicyHash,
    RouteId = route$RouteId,
    Backend = route$Backend,
    Criterion = route$Criterion
  ), as.list(hashes), list(
    FitStatus = fit_status,
    FitReturned = fit_returned,
    FitIntegrityPassed = fit_integrity_passed,
    PointEstimationGatePassed = point_estimation_gate_passed,
    BackendRowsMatch = backend_rows_match,
    DependencyABIMatch = dependency_abi_match,
    FreshProcess = fresh_process,
    DiagnosticOverrideUsed = diagnostic_override_used,
    WarningCount = as.integer(warning_count),
    ErrorClass = error_class
  ))
  candidate_ready <- all(unlist(logical_values[c(
    "FitReturned", "FitIntegrityPassed", "PointEstimationGatePassed",
    "BackendRowsMatch", "DependencyABIMatch", "FreshProcess"
  )], use.names = FALSE)) &&
    !diagnostic_override_used && warning_count == 0L && is.na(error_class) &&
    identical(fit_status, route$RequiredFitStatus)
  structure(c(payload, list(
    ReceiptPayloadHash = mfrmr_gtvm_hash(payload),
    CandidateReceiptReady = candidate_ready,
    SelfReportedSummary = TRUE,
    FullB1ObjectsRevalidated = FALSE,
    TrustedReceiptReady = FALSE,
    OperationallyAdmissible = FALSE,
    BackendQualificationReady = FALSE,
    ExecutionAuthorized = FALSE,
    RecoveryEvidenceReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvm_route_candidate", "list"))
}

mfrmr_gtvm_assert_route_candidate <- function(
    receipt, policy = mfrmr_gtvm_qualification_policy()) {
  mfrmr_gtvm_assert_policy(policy)
  payload_fields <- c(
    "Contract", "PolicyHash", "RouteId", "Backend", "Criterion",
    "EnvironmentIdentityHash", "ProcessIdentityHash", "WorkerSourceSHA256",
    "SpecificationHash", "SemanticModelHash", "FitResultHash", "FitStatus",
    "FitReturned", "FitIntegrityPassed", "PointEstimationGatePassed",
    "BackendRowsMatch", "DependencyABIMatch", "FreshProcess",
    "DiagnosticOverrideUsed", "WarningCount", "ErrorClass"
  )
  suffix_fields <- c(
    "ReceiptPayloadHash", "CandidateReceiptReady", "SelfReportedSummary",
    "FullB1ObjectsRevalidated", "TrustedReceiptReady",
    "OperationallyAdmissible", "BackendQualificationReady",
    "ExecutionAuthorized", "RecoveryEvidenceReady", "PublicSupportReady"
  )
  if (!mfrmr_gtvm_exact_object(
    receipt, c(payload_fields, suffix_fields),
    c("mfrmr_gtvm_route_candidate", "list")
  )) {
    stop("A typed Draft.85c4f route candidate is required.",
         call. = FALSE)
  }
  route <- policy$RouteRegistry[
    policy$RouteRegistry$RouteId == receipt$RouteId, , drop = FALSE
  ]
  state_fields <- c(
    "FitReturned", "FitIntegrityPassed", "PointEstimationGatePassed",
    "BackendRowsMatch", "DependencyABIMatch", "FreshProcess",
    "DiagnosticOverrideUsed"
  )
  states_valid <- all(vapply(receipt[state_fields], function(value) {
    is.logical(value) && length(value) == 1L && !is.na(value)
  }, logical(1L)))
  warning_valid <- is.integer(receipt$WarningCount) &&
    length(receipt$WarningCount) == 1L && !is.na(receipt$WarningCount) &&
    receipt$WarningCount >= 0L
  status_valid <- is.character(receipt$FitStatus) &&
    length(receipt$FitStatus) == 1L && !is.na(receipt$FitStatus) &&
    nzchar(receipt$FitStatus)
  error_valid <- is.character(receipt$ErrorClass) &&
    length(receipt$ErrorClass) == 1L &&
    (is.na(receipt$ErrorClass) || nzchar(receipt$ErrorClass))
  ready <- nrow(route) == 1L &&
    identical(
      receipt$Contract,
      "gtheory_multivariate_route_candidate_receipt_draft85c4f_v1"
    ) &&
    identical(receipt$PolicyHash, policy$PolicyHash) &&
    identical(receipt$Backend, route$Backend) &&
    identical(receipt$Criterion, route$Criterion) &&
    all(vapply(receipt[c(
      "EnvironmentIdentityHash", "ProcessIdentityHash", "WorkerSourceSHA256",
      "SpecificationHash", "SemanticModelHash", "FitResultHash"
    )], function(value) {
      is.character(value) && length(value) == 1L && !is.na(value) &&
        grepl("^[0-9a-f]{64}$", value)
    }, logical(1L))) && states_valid && warning_valid && status_valid &&
    error_valid &&
    identical(receipt$ReceiptPayloadHash,
              mfrmr_gtvm_hash(receipt[payload_fields]))
  expected_candidate <- ready && all(unlist(receipt[c(
    "FitReturned", "FitIntegrityPassed", "PointEstimationGatePassed",
    "BackendRowsMatch", "DependencyABIMatch", "FreshProcess"
  )], use.names = FALSE)) &&
    identical(receipt$DiagnosticOverrideUsed, FALSE) &&
    identical(receipt$WarningCount, 0L) && is.na(receipt$ErrorClass) &&
    identical(receipt$FitStatus, "identified_point_fit")
  valid <- ready && identical(receipt$CandidateReceiptReady,
                              expected_candidate) &&
    identical(receipt$SelfReportedSummary, TRUE) &&
    identical(receipt$FullB1ObjectsRevalidated, FALSE) &&
    identical(receipt$TrustedReceiptReady, FALSE) &&
    identical(receipt$OperationallyAdmissible, FALSE) &&
    identical(receipt$BackendQualificationReady, FALSE) &&
    identical(receipt$ExecutionAuthorized, FALSE) &&
    identical(receipt$RecoveryEvidenceReady, FALSE) &&
    identical(receipt$PublicSupportReady, FALSE)
  if (!valid) {
    stop("The Draft.85c4f route candidate or trust state was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvm_pair_receipt_template <- function(
    environment_identity_hash,
    policy = mfrmr_gtvm_qualification_policy()) {
  mfrmr_gtvm_assert_policy(policy)
  mfrmr_gtvm_sha256(environment_identity_hash, "environment_identity_hash")
  pairs <- policy$PairRegistry
  data.frame(
    PairOrdinal = pairs$PairOrdinal,
    PairId = pairs$PairId,
    Criterion = pairs$Criterion,
    EnvironmentIdentityHash = rep(environment_identity_hash, 2L),
    Lme4CandidateReceiptHash = rep(NA_character_, 2L),
    GlmmTMBCandidateReceiptHash = rep(NA_character_, 2L),
    ParityResultHash = rep(NA_character_, 2L),
    CandidatePairReady = rep(FALSE, 2L),
    TrustedPairReady = rep(FALSE, 2L),
    OperationallyAdmissible = rep(FALSE, 2L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvm_pair_candidate_receipt <- function(
    criterion, lme4_receipt, glmmtmb_receipt, parity_result_hash,
    numerical_parity_passed, both_point_gates_passed,
    backend_dependency_identity_passed, exact_specification_match,
    exact_semantic_model_match,
    policy = mfrmr_gtvm_qualification_policy()) {
  mfrmr_gtvm_assert_policy(policy)
  mfrmr_gtvm_assert_route_candidate(lme4_receipt, policy)
  mfrmr_gtvm_assert_route_candidate(glmmtmb_receipt, policy)
  pair <- policy$PairRegistry[
    policy$PairRegistry$Criterion == criterion, , drop = FALSE
  ]
  if (nrow(pair) != 1L ||
      !identical(lme4_receipt$RouteId, pair$Lme4RouteId) ||
      !identical(glmmtmb_receipt$RouteId, pair$GlmmTMBRouteId)) {
    stop("The Draft.85c4f pair routes do not match the criterion.",
         call. = FALSE)
  }
  mfrmr_gtvm_sha256(parity_result_hash, "parity_result_hash")
  flags <- list(
    NumericalParityPassed = numerical_parity_passed,
    BothPointGatesPassed = both_point_gates_passed,
    BackendDependencyIdentityPassed = backend_dependency_identity_passed,
    ExactSpecificationMatch = exact_specification_match,
    ExactSemanticModelMatch = exact_semantic_model_match
  )
  if (!all(vapply(flags, function(value) {
    is.logical(value) && length(value) == 1L && !is.na(value)
  }, logical(1L)))) {
    stop("Draft.85c4f pair states must be exact TRUE/FALSE values.",
         call. = FALSE)
  }
  identities_match <-
    identical(lme4_receipt$EnvironmentIdentityHash,
              glmmtmb_receipt$EnvironmentIdentityHash) &&
    identical(lme4_receipt$SpecificationHash,
              glmmtmb_receipt$SpecificationHash) &&
    identical(lme4_receipt$SemanticModelHash,
              glmmtmb_receipt$SemanticModelHash)
  payload <- list(
    Contract =
      "gtheory_multivariate_pair_candidate_receipt_draft85c4f_v1",
    PolicyHash = policy$PolicyHash,
    PairId = pair$PairId,
    Criterion = pair$Criterion,
    EnvironmentIdentityHash = lme4_receipt$EnvironmentIdentityHash,
    SpecificationHash = lme4_receipt$SpecificationHash,
    SemanticModelHash = lme4_receipt$SemanticModelHash,
    Lme4CandidateReceiptHash = lme4_receipt$ReceiptPayloadHash,
    GlmmTMBCandidateReceiptHash = glmmtmb_receipt$ReceiptPayloadHash,
    ParityResultHash = parity_result_hash,
    ToleranceRegistryHash = policy$ToleranceRegistryHash,
    NumericalParityPassed = numerical_parity_passed,
    BothPointGatesPassed = both_point_gates_passed,
    BackendDependencyIdentityPassed = backend_dependency_identity_passed,
    ExactSpecificationMatch = exact_specification_match,
    ExactSemanticModelMatch = exact_semantic_model_match,
    RouteIdentitiesMatch = identities_match
  )
  candidate_ready <- lme4_receipt$CandidateReceiptReady &&
    glmmtmb_receipt$CandidateReceiptReady && identities_match &&
    all(unlist(flags, use.names = FALSE))
  structure(c(payload, list(
    ReceiptPayloadHash = mfrmr_gtvm_hash(payload),
    CandidatePairReady = candidate_ready,
    SelfReportedSummary = TRUE,
    FullB1ObjectsRevalidated = FALSE,
    TrustedPairReady = FALSE,
    OperationallyAdmissible = FALSE,
    BackendQualificationReady = FALSE,
    ExecutionAuthorized = FALSE,
    RecoveryEvidenceReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvm_pair_candidate", "list"))
}

mfrmr_gtvm_assert_pair_candidate <- function(
    receipt, policy = mfrmr_gtvm_qualification_policy()) {
  mfrmr_gtvm_assert_policy(policy)
  payload_fields <- c(
    "Contract", "PolicyHash", "PairId", "Criterion",
    "EnvironmentIdentityHash", "SpecificationHash", "SemanticModelHash",
    "Lme4CandidateReceiptHash", "GlmmTMBCandidateReceiptHash",
    "ParityResultHash", "ToleranceRegistryHash", "NumericalParityPassed",
    "BothPointGatesPassed", "BackendDependencyIdentityPassed",
    "ExactSpecificationMatch", "ExactSemanticModelMatch",
    "RouteIdentitiesMatch"
  )
  suffix_fields <- c(
    "ReceiptPayloadHash", "CandidatePairReady", "SelfReportedSummary",
    "FullB1ObjectsRevalidated", "TrustedPairReady",
    "OperationallyAdmissible", "BackendQualificationReady",
    "ExecutionAuthorized", "RecoveryEvidenceReady", "PublicSupportReady"
  )
  if (!mfrmr_gtvm_exact_object(
    receipt, c(payload_fields, suffix_fields),
    c("mfrmr_gtvm_pair_candidate", "list")
  )) {
    stop("A typed Draft.85c4f pair candidate is required.", call. = FALSE)
  }
  pair <- policy$PairRegistry[
    policy$PairRegistry$PairId == receipt$PairId, , drop = FALSE
  ]
  hash_fields <- c(
    "EnvironmentIdentityHash", "SpecificationHash", "SemanticModelHash",
    "Lme4CandidateReceiptHash", "GlmmTMBCandidateReceiptHash",
    "ParityResultHash", "ToleranceRegistryHash"
  )
  hash_valid <- all(vapply(receipt[hash_fields], function(value) {
    is.character(value) && length(value) == 1L && !is.na(value) &&
      grepl("^[0-9a-f]{64}$", value)
  }, logical(1L)))
  flag_fields <- c(
    "NumericalParityPassed", "BothPointGatesPassed",
    "BackendDependencyIdentityPassed", "ExactSpecificationMatch",
    "ExactSemanticModelMatch", "RouteIdentitiesMatch"
  )
  flags_valid <- all(vapply(receipt[flag_fields], function(value) {
    is.logical(value) && length(value) == 1L && !is.na(value)
  }, logical(1L)))
  ready <- nrow(pair) == 1L &&
    identical(
      receipt$Contract,
      "gtheory_multivariate_pair_candidate_receipt_draft85c4f_v1"
    ) &&
    identical(receipt$Criterion, pair$Criterion) &&
    identical(receipt$PolicyHash, policy$PolicyHash) &&
    identical(receipt$ToleranceRegistryHash,
              policy$ToleranceRegistryHash) &&
    hash_valid && flags_valid &&
    identical(receipt$ReceiptPayloadHash,
              mfrmr_gtvm_hash(receipt[payload_fields]))
  expected_candidate <- ready && all(unlist(
    receipt[flag_fields], use.names = FALSE
  ))
  valid <- ready && identical(receipt$CandidatePairReady,
                              expected_candidate) &&
    identical(receipt$SelfReportedSummary, TRUE) &&
    identical(receipt$FullB1ObjectsRevalidated, FALSE) &&
    identical(receipt$TrustedPairReady, FALSE) &&
    identical(receipt$OperationallyAdmissible, FALSE) &&
    identical(receipt$BackendQualificationReady, FALSE) &&
    identical(receipt$ExecutionAuthorized, FALSE) &&
    identical(receipt$RecoveryEvidenceReady, FALSE) &&
    identical(receipt$PublicSupportReady, FALSE)
  if (!valid) {
    stop("The Draft.85c4f pair candidate or trust state was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvm_implementation_identity <- function() {
  function_names <- c(
    "mfrmr_gtvm_require_primitives", "mfrmr_gtvm_hash",
    "mfrmr_gtvm_exact_object", "mfrmr_gtvm_sha256",
    "mfrmr_gtvm_qualification_policy", "mfrmr_gtvm_assert_policy",
    "mfrmr_gtvm_route_receipt_template",
    "mfrmr_gtvm_route_candidate_receipt",
    "mfrmr_gtvm_assert_route_candidate",
    "mfrmr_gtvm_pair_receipt_template",
    "mfrmr_gtvm_pair_candidate_receipt",
    "mfrmr_gtvm_assert_pair_candidate",
    "mfrmr_gtvm_implementation_identity", "mfrmr_gtvm_manifest",
    "mfrmr_gtvm_assert_manifest", "mfrmr_gtvm_dispatch_guard"
  )
  target <- environment(mfrmr_gtvm_implementation_identity)
  data.frame(
    Function = function_names,
    SHA256 = vapply(function_names, function(name) {
      if (!exists(name, envir = target, inherits = FALSE)) {
        stop("A Draft.85c4f implementation function is missing: ", name,
             ".", call. = FALSE)
      }
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtvm_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvm_manifest <- function(repo_root = ".", c4e_manifest = NULL) {
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  mfrmr_gtvm_require_primitives()
  if (is.null(c4e_manifest)) {
    environment <- mfrmr_gtvl_environment_identity()
    c4e_manifest <- mfrmr_gtvl_manifest(repo_root, environment)
  }
  if (!inherits(c4e_manifest, "mfrmr_gtvl_manifest")) {
    stop("A typed Draft.85c4e manifest is required.", call. = FALSE)
  }
  mfrmr_gtvl_assert_manifest(
    c4e_manifest, repo_root, c4e_manifest$SuppliedEnvironmentIdentity
  )
  policy <- mfrmr_gtvm_qualification_policy()
  route_template <- mfrmr_gtvm_route_receipt_template(
    c4e_manifest$CurrentEnvironmentIdentityHash, policy
  )
  pair_template <- mfrmr_gtvm_pair_receipt_template(
    c4e_manifest$CurrentEnvironmentIdentityHash, policy
  )
  implementation <- mfrmr_gtvm_implementation_identity()
  c4e_source <- file.path(
    repo_root, "inst", "validation",
    "gtheory-multivariate-backend-qualification-admission-preflight-0.2.4.R"
  )
  payload <- list(
    Contract =
      "gtheory_multivariate_four_route_qualification_protocol_draft85c4f_v1",
    C4EManifestHash = c4e_manifest$ManifestHash,
    C4EEnvironmentIdentityHash =
      c4e_manifest$CurrentEnvironmentIdentityHash,
    C4ESourceSHA256 = digest::digest(
      file = c4e_source, algo = "sha256", serialize = FALSE
    ),
    QualificationPolicy = policy,
    QualificationPolicyHash = policy$PolicyHash,
    RouteReceiptTemplate = route_template,
    RouteReceiptTemplateHash = mfrmr_gtvm_hash(route_template),
    PairReceiptTemplate = pair_template,
    PairReceiptTemplateHash = mfrmr_gtvm_hash(pair_template),
    ImplementationIdentity = implementation,
    ImplementationIdentityHash = mfrmr_gtvm_hash(implementation),
    PlannedSeedMaterialIncluded = FALSE,
    ConQuestRouteIncluded = FALSE
  )
  structure(c(payload, list(
    ManifestHash = mfrmr_gtvm_hash(payload),
    QualificationPolicyReady = TRUE,
    ReceiptSchemaReady = TRUE,
    CandidateReceiptEvaluatorReady = TRUE,
    EnvironmentReadyForBackendQualification =
      c4e_manifest$EnvironmentReadyForBackendQualification,
    RepairRequired = c4e_manifest$RepairRequired,
    TrustedWorkerImplemented = FALSE,
    RouteReceiptsMaterialized = FALSE,
    PairReceiptsMaterialized = FALSE,
    AllRouteReceiptsReady = FALSE,
    AllPairReceiptsReady = FALSE,
    QualificationEvidenceReady = FALSE,
    BackendQualificationAdmissionReady = FALSE,
    BackendQualificationReady = FALSE,
    DiagnosticOverrideAllowed = FALSE,
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
  )), class = c("mfrmr_gtvm_manifest", "list"))
}

mfrmr_gtvm_assert_manifest <- function(
    manifest, repo_root = ".", c4e_manifest = NULL) {
  canonical <- mfrmr_gtvm_manifest(repo_root, c4e_manifest)
  if (!mfrmr_gtvm_exact_object(
    manifest, names(canonical), class(canonical)
  ) || !identical(manifest, canonical)) {
    stop("The Draft.85c4f protocol manifest or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvm_dispatch_guard <- function(
    manifest, action, callback, ..., authorize = FALSE, repo_root = ".",
    c4e_manifest = NULL) {
  mfrmr_gtvm_assert_manifest(manifest, repo_root, c4e_manifest)
  if (!is.character(action) || length(action) != 1L || is.na(action) ||
      !action %in% c("trusted_worker", "backend_fit", "receipt_promotion")) {
    stop("The Draft.85c4f action is outside the protocol.", call. = FALSE)
  }
  if (!is.function(callback)) {
    stop("`callback` must be a function.", call. = FALSE)
  }
  if (!is.logical(authorize) || length(authorize) != 1L || is.na(authorize)) {
    stop("`authorize` must be TRUE or FALSE.", call. = FALSE)
  }
  stop(
    "Draft.85c4f has no trusted worker or receipts; execution remains closed.",
    call. = FALSE
  )
}
