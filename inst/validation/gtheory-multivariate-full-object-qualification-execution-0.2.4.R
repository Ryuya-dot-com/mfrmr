# Draft.85c4j multivariate G-theory full-object qualification execution.
#
# Repository-internal only. The controller binds the Draft.85c4i repair
# receipt to the Draft.85c4f four-route policy, runs a standalone worker in a
# fresh process, and independently revalidates all complete Draft.85b1 fit and
# parity objects. Process-capability isolation remains a separate closed gate.

mfrmr_gtvq_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtvb_assert_fit_integrity",
    "mfrmr_gtvb_compare", "mfrmr_gtvm_qualification_policy",
    "mfrmr_gtvm_assert_manifest", "mfrmr_gtvp_assert_receipt"
  )
  target <- environment(mfrmr_gtvq_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.81, Draft.85b1, Draft.85c4f, and Draft.85c4i before ",
      "Draft.85c4j: ", paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtvq_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4j requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvq_file_hash <- function(path) {
  path <- normalizePath(path, mustWork = TRUE)
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtvq_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    identical(sort(names(attributes(object))), c("class", "names"))
}

mfrmr_gtvq_source_registry <- function(validation_dir) {
  validation_dir <- normalizePath(validation_dir, mustWork = TRUE)
  files <- c(
    "gtheory-design-algebra-prototype-0.2.3.R",
    "gtheory-multivariate-algebra-prototype-0.2.3.R",
    "gtheory-multivariate-incidence-preflight-0.2.4.R",
    "gtheory-multivariate-matched-backend-prototype-0.2.4.R",
    "gtheory-multivariate-four-route-qualification-protocol-0.2.4.R"
  )
  paths <- file.path(validation_dir, files)
  if (!all(file.exists(paths))) {
    stop("The Draft.85c4j source registry is incomplete.", call. = FALSE)
  }
  data.frame(
    SourceOrdinal = seq_along(files), FileName = files,
    SHA256 = unname(vapply(
      paths, mfrmr_gtvq_file_hash, character(1L)
    )),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvq_worker_identity <- function(worker_environment) {
  function_names <- c(
    "mfrmr_gtvqw_hash", "mfrmr_gtvqw_file_hash",
    "mfrmr_gtvqw_exact_object", "mfrmr_gtvqw_component_map",
    "mfrmr_gtvqw_mvnorm", "mfrmr_gtvqw_fixture",
    "mfrmr_gtvqw_source_registry", "mfrmr_gtvqw_package_registry",
    "mfrmr_gtvqw_loaded_runtime_registry",
    "mfrmr_gtvqw_process_identity", "mfrmr_gtvqw_assert_request",
    "mfrmr_gtvqw_route_registry", "mfrmr_gtvqw_pair_registry",
    "mfrmr_gtvqw_implementation_identity", "mfrmr_gtvqw_main"
  )
  if (!is.environment(worker_environment) ||
      !identical(parent.env(worker_environment), baseenv()) ||
      !identical(
        sort(ls(worker_environment, all.names = TRUE), method = "radix"),
        sort(function_names, method = "radix")
      ) || !all(vapply(function_names, function(name) {
        is.function(get(name, envir = worker_environment, inherits = FALSE))
      }, logical(1L)))) {
    stop("The Draft.85c4j worker namespace was altered.", call. = FALSE)
  }
  data.frame(
    Function = function_names,
    SHA256 = vapply(function_names, function(name) {
      fun <- get(name, envir = worker_environment, inherits = FALSE)
      mfrmr_gtvq_hash(list(
        Formals = paste(deparse(formals(fun), width.cutoff = 500L),
                        collapse = "\n"),
        Body = paste(deparse(body(fun), width.cutoff = 500L),
                     collapse = "\n")
      ))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvq_request <- function(
    repair_receipt, c4f_manifest, worker_source_sha256, source_registry) {
  mfrmr_gtvq_require_primitives()
  policy <- mfrmr_gtvm_qualification_policy()
  mfrmr_gtvm_assert_policy(policy)
  tolerance <- stats::setNames(
    policy$ToleranceRegistry$Value,
    policy$ToleranceRegistry$ToleranceId
  )
  payload <- list(
    Contract =
      "gtheory_multivariate_full_object_qualification_request_draft85c4j_v1",
    C4IRepairReceiptHash = repair_receipt$ReceiptHash,
    C4FManifestHash = c4f_manifest$ManifestHash,
    C4FPolicyHash = policy$PolicyHash,
    WorkerSourceSHA256 = worker_source_sha256,
    SourceRegistry = source_registry,
    SourceRegistryHash = mfrmr_gtvq_hash(source_registry),
    RepairRoot = normalizePath(repair_receipt$RepairRoot, mustWork = TRUE),
    OverlayLibrary = normalizePath(
      repair_receipt$OverlayLibrary, mustWork = TRUE
    ),
    QualificationSeed = 85021L,
    CovarianceAbsoluteTolerance = tolerance[["covariance_absolute"]],
    CovarianceRelativeTolerance = tolerance[["covariance_relative"]],
    FixedAbsoluteTolerance = tolerance[["fixed_absolute"]],
    LogLikAbsoluteTolerance = tolerance[["loglik_absolute"]]
  )
  structure(c(payload, list(
    RequestHash = mfrmr_gtvq_hash(payload)
  )), class = c("mfrmr_gtvqw_request", "list"))
}

mfrmr_gtvq_route_object_registry <- function(fits, policy) {
  routes <- policy$RouteRegistry
  rows <- lapply(seq_len(nrow(routes)), function(index) {
    route <- routes[index, , drop = FALSE]
    fit <- fits[[route$RouteId]]
    abi <- if (identical(route$Backend, "glmmTMB")) {
      fit$EstimatorIdentity$DependencyABI
    } else NULL
    data.frame(
      RouteOrdinal = route$RouteOrdinal,
      RouteId = route$RouteId,
      Backend = route$Backend,
      Criterion = route$Criterion,
      SpecificationHash = fit$SpecificationHash,
      SemanticModelHash = fit$EstimatorIdentity$SemanticModelHash,
      FitResultHash = fit$ResultHash,
      FullFitObjectHash = mfrmr_gtvq_hash(fit),
      FitStatus = fit$FitDiagnostics$FitStatus,
      FitIntegrityPassed = TRUE,
      PointEstimationGatePassed = fit$PointEstimationGatePassed,
      BackendRowsMatch = fit$BackendRowsMatch,
      DependencyABIMatch = if (is.null(abi)) TRUE else abi$VersionMatch,
      DiagnosticOverrideUsed = if (is.null(abi)) FALSE else {
        abi$DiagnosticOverride
      },
      WarningCount = as.integer(fit$FitDiagnostics$WarningCount),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gtvq_pair_object_registry <- function(parities, route_registry,
                                             policy) {
  pairs <- policy$PairRegistry
  rows <- lapply(seq_len(nrow(pairs)), function(index) {
    pair <- pairs[index, , drop = FALSE]
    parity <- parities[[pair$PairId]]
    pair_routes <- route_registry[
      route_registry$RouteId %in% c(pair$Lme4RouteId, pair$GlmmTMBRouteId),
      , drop = FALSE
    ]
    data.frame(
      PairOrdinal = pair$PairOrdinal,
      PairId = pair$PairId,
      Criterion = pair$Criterion,
      SpecificationHash = parity$SpecificationHash,
      SemanticModelHash = parity$SemanticModelHash,
      ParityResultHash = parity$ResultHash,
      FullParityObjectHash = mfrmr_gtvq_hash(parity),
      NumericalParityPassed = parity$NumericalParityPassed,
      BothPointGatesPassed = parity$BothPointEstimationGatesPassed,
      BackendDependencyIdentityPassed =
        parity$BackendDependencyIdentityPassed,
      ExactSpecificationMatch =
        length(unique(pair_routes$SpecificationHash)) == 1L,
      ExactSemanticModelMatch =
        length(unique(pair_routes$SemanticModelHash)) == 1L,
      MaximumCovarianceAbsoluteDifference =
        max(parity$CovarianceComparison$AbsoluteDifference),
      MaximumCovarianceRelativeDifference =
        max(parity$CovarianceComparison$RelativeDifference),
      MaximumFixedAbsoluteDifference =
        max(parity$FixedEffectComparison$AbsoluteDifference),
      LogLikAbsoluteDifference =
        parity$LikelihoodComparison$AbsoluteDifference,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gtvq_assert_worker_receipt <- function(
    receipt, request, repair_receipt, worker_environment,
    controller_process_id = Sys.getpid()) {
  payload_fields <- c(
    "Contract", "RequestHash", "C4IRepairReceiptHash", "C4FManifestHash",
    "C4FPolicyHash", "WorkerSourceSHA256",
    "WorkerImplementationIdentity", "WorkerImplementationIdentityHash",
    "SourceRegistry", "SourceRegistryHash", "ProcessIdentity",
    "ProcessIdentityHash", "PackageRegistry", "PackageRegistryHash",
    "LoadedNamespaceRegistry", "LoadedNamespaceRegistryHash",
    "LoadedNativeBinaryRegistry", "LoadedNativeBinaryRegistryHash",
    "QualificationSeed", "FixtureDataHash", "IncidenceAuditHash",
    "SpecificationHash", "RouteObjectRegistry", "RouteObjectRegistryHash",
    "PairObjectRegistry", "PairObjectRegistryHash", "FullFitObjects",
    "FullFitObjectsHash", "FullParityObjects", "FullParityObjectsHash",
    "WorkerWarnings", "WorkerMessages"
  )
  suffix_fields <- c(
    "ReceiptHash", "CompleteFitObjectsReturned",
    "CompleteParityObjectsReturned", "AllRouteObjectChecksPassed",
    "AllPairObjectChecksPassed", "WorkerWarningFree",
    "DiagnosticOverrideUsed", "DependencyABIMatch",
    "LoadedNamespaceClosureCaptured",
    "FreshProcessClaimedByWorker", "ProcessCapabilityIsolationAssessed",
    "ProcessCapabilityIsolationReady", "WorkerSelfReported",
    "QualificationObjectsReady", "TrustedReceiptProduced",
    "OperationallyAdmissible", "BackendQualificationReady",
    "EstimationReady", "InferenceReady", "DecisionReady",
    "PublicSupportReady", "ConQuestRouteIncluded"
  )
  if (!mfrmr_gtvq_exact_object(
    receipt, c(payload_fields, suffix_fields),
    c("mfrmr_gtvqw_receipt", "list")
  )) {
    stop("A typed Draft.85c4j worker receipt is required.", call. = FALSE)
  }
  policy <- mfrmr_gtvm_qualification_policy()
  fits <- receipt$FullFitObjects
  parities <- receipt$FullParityObjects
  fit_names <- policy$RouteRegistry$RouteId
  pair_names <- policy$PairRegistry$PairId
  if (!is.list(fits) || !identical(names(fits), fit_names) ||
      !is.list(parities) || !identical(names(parities), pair_names)) {
    stop("The Draft.85c4j complete object registry was altered.",
         call. = FALSE)
  }
  for (fit in fits) mfrmr_gtvb_assert_fit_integrity(fit)
  canonical_parities <- list(
    matched_ml = mfrmr_gtvb_compare(
      fits$lme4_ml, fits$glmmTMB_ml,
      absolute_tolerance = request$CovarianceAbsoluteTolerance,
      relative_tolerance = request$CovarianceRelativeTolerance,
      fixed_tolerance = request$FixedAbsoluteTolerance,
      loglik_tolerance = request$LogLikAbsoluteTolerance
    ),
    matched_reml = mfrmr_gtvb_compare(
      fits$lme4_reml, fits$glmmTMB_reml,
      absolute_tolerance = request$CovarianceAbsoluteTolerance,
      relative_tolerance = request$CovarianceRelativeTolerance,
      fixed_tolerance = request$FixedAbsoluteTolerance,
      loglik_tolerance = request$LogLikAbsoluteTolerance
    )
  )
  if (!identical(parities, canonical_parities)) {
    stop("The Draft.85c4j parity objects are not canonical.", call. = FALSE)
  }
  routes <- mfrmr_gtvq_route_object_registry(fits, policy)
  pairs <- mfrmr_gtvq_pair_object_registry(parities, routes, policy)
  worker_identity <- mfrmr_gtvq_worker_identity(worker_environment)
  process <- receipt$ProcessIdentity
  process_payload_fields <- c(
    "ProcessId", "RVersion", "RPlatform", "RExecutable",
    "RExecutableSHA256", "RscriptExecutable", "RscriptExecutableSHA256",
    "LibraryOrder"
  )
  process_valid <- is.list(process) &&
    identical(names(process), c(
      process_payload_fields, "ProcessIdentityHash"
    )) && is.integer(process$ProcessId) && length(process$ProcessId) == 1L &&
    !is.na(process$ProcessId) && process$ProcessId > 0L &&
    !identical(process$ProcessId, as.integer(controller_process_id)) &&
    identical(process$ProcessIdentityHash,
              mfrmr_gtvq_hash(process[process_payload_fields])) &&
    identical(process$LibraryOrder[[1L]], repair_receipt$OverlayLibrary) &&
    identical(process$RExecutableSHA256,
              repair_receipt$ToolchainIdentity$RExecutableSHA256) &&
    identical(process$RscriptExecutableSHA256,
              repair_receipt$ToolchainIdentity$RscriptExecutableSHA256)
  namespaces <- receipt$LoadedNamespaceRegistry
  native <- receipt$LoadedNativeBinaryRegistry
  namespace_valid <- is.data.frame(namespaces) && nrow(namespaces) > 0L &&
    identical(names(namespaces), c(
      "NamespaceOrdinal", "Package", "Version", "PackagePath",
      "DescriptionSHA256"
    )) && identical(namespaces$NamespaceOrdinal, seq_len(nrow(namespaces))) &&
    identical(anyDuplicated(namespaces$Package), 0L) &&
    identical(namespaces$Package,
              sort(namespaces$Package, method = "radix")) &&
    all(vapply(seq_len(nrow(namespaces)), function(index) {
      path <- normalizePath(namespaces$PackagePath[[index]], mustWork = TRUE)
      description <- file.path(path, "DESCRIPTION")
      observed_version <- as.character(package_version(
        read.dcf(description, fields = "Version")[[1L]]
      ))
      identical(namespaces$Version[[index]], observed_version) &&
        identical(namespaces$PackagePath[[index]], path) &&
        identical(
          namespaces$DescriptionSHA256[[index]],
          mfrmr_gtvq_file_hash(description)
        )
    }, logical(1L))) &&
    identical(receipt$LoadedNamespaceRegistryHash,
              mfrmr_gtvq_hash(namespaces))
  native_valid <- is.data.frame(native) && identical(names(native), c(
    "Package", "NativeBinaryPath", "NativeBinarySHA256"
  )) && !anyDuplicated(native$NativeBinaryPath) &&
    all(vapply(seq_len(nrow(native)), function(index) {
      path <- normalizePath(native$NativeBinaryPath[[index]], mustWork = TRUE)
      identical(path, native$NativeBinaryPath[[index]]) &&
        identical(native$NativeBinarySHA256[[index]],
                  mfrmr_gtvq_file_hash(path))
    }, logical(1L))) &&
    identical(receipt$LoadedNativeBinaryRegistryHash,
              mfrmr_gtvq_hash(native))
  selected_packages <- repair_receipt$FreshProcessReceipt$PackageRegistry
  selected_namespaces <- namespaces[
    match(selected_packages$Package, namespaces$Package),
    c("Package", "Version", "PackagePath", "DescriptionSHA256"),
    drop = FALSE
  ]
  row.names(selected_namespaces) <- NULL
  selected_identity <- selected_packages[
    , c("Package", "Version", "PackagePath", "DescriptionSHA256"),
    drop = FALSE
  ]
  row.names(selected_identity) <- NULL
  runtime_closure_valid <- namespace_valid && native_valid &&
    !anyNA(selected_namespaces$Package) &&
    identical(selected_namespaces, selected_identity)
  route_ready <- nrow(routes) == 4L &&
    all(routes$FitIntegrityPassed) && all(routes$PointEstimationGatePassed) &&
    all(routes$BackendRowsMatch) && all(routes$DependencyABIMatch) &&
    !any(routes$DiagnosticOverrideUsed) &&
    all(routes$WarningCount == 0L) &&
    all(routes$FitStatus == "identified_point_fit")
  pair_ready <- nrow(pairs) == 2L &&
    all(pairs$NumericalParityPassed) && all(pairs$BothPointGatesPassed) &&
    all(pairs$BackendDependencyIdentityPassed) &&
    all(pairs$ExactSpecificationMatch) &&
    all(pairs$ExactSemanticModelMatch)
  expected_ready <- route_ready && pair_ready &&
    length(receipt$WorkerWarnings) == 0L
  valid <- identical(
    receipt$Contract,
    "gtheory_multivariate_full_object_worker_receipt_draft85c4j_v1"
  ) && identical(receipt$RequestHash, request$RequestHash) &&
    identical(receipt$C4IRepairReceiptHash, repair_receipt$ReceiptHash) &&
    identical(receipt$C4FManifestHash, request$C4FManifestHash) &&
    identical(receipt$C4FPolicyHash, policy$PolicyHash) &&
    identical(receipt$WorkerSourceSHA256, request$WorkerSourceSHA256) &&
    identical(receipt$WorkerImplementationIdentity, worker_identity) &&
    identical(receipt$WorkerImplementationIdentityHash,
              mfrmr_gtvq_hash(worker_identity)) &&
    identical(receipt$SourceRegistry, request$SourceRegistry) &&
    identical(receipt$SourceRegistryHash, request$SourceRegistryHash) &&
    process_valid &&
    identical(receipt$ProcessIdentityHash, process$ProcessIdentityHash) &&
    identical(receipt$PackageRegistry,
              repair_receipt$FreshProcessReceipt$PackageRegistry) &&
    identical(receipt$PackageRegistryHash,
              mfrmr_gtvq_hash(receipt$PackageRegistry)) &&
    runtime_closure_valid &&
    identical(receipt$QualificationSeed, 85021L) &&
    identical(receipt$SpecificationHash, fits[[1L]]$SpecificationHash) &&
    identical(receipt$RouteObjectRegistry, routes) &&
    identical(receipt$RouteObjectRegistryHash, mfrmr_gtvq_hash(routes)) &&
    identical(receipt$PairObjectRegistry, pairs) &&
    identical(receipt$PairObjectRegistryHash, mfrmr_gtvq_hash(pairs)) &&
    identical(receipt$FullFitObjectsHash, mfrmr_gtvq_hash(fits)) &&
    identical(receipt$FullParityObjectsHash, mfrmr_gtvq_hash(parities)) &&
    identical(receipt$ReceiptHash,
              mfrmr_gtvq_hash(receipt[payload_fields])) &&
    identical(receipt$CompleteFitObjectsReturned, TRUE) &&
    identical(receipt$CompleteParityObjectsReturned, TRUE) &&
    identical(receipt$AllRouteObjectChecksPassed, route_ready) &&
    identical(receipt$AllPairObjectChecksPassed, pair_ready) &&
    identical(receipt$WorkerWarningFree,
              length(receipt$WorkerWarnings) == 0L) &&
    identical(receipt$DiagnosticOverrideUsed,
              any(routes$DiagnosticOverrideUsed)) &&
    identical(receipt$DependencyABIMatch,
              all(routes$DependencyABIMatch)) &&
    identical(receipt$LoadedNamespaceClosureCaptured, TRUE) &&
    identical(receipt$FreshProcessClaimedByWorker, FALSE) &&
    identical(receipt$ProcessCapabilityIsolationAssessed, FALSE) &&
    identical(receipt$ProcessCapabilityIsolationReady, FALSE) &&
    identical(receipt$WorkerSelfReported, TRUE) &&
    identical(receipt$QualificationObjectsReady, expected_ready) &&
    !any(vapply(receipt[c(
      "TrustedReceiptProduced", "OperationallyAdmissible",
      "BackendQualificationReady", "EstimationReady", "InferenceReady",
      "DecisionReady", "PublicSupportReady", "ConQuestRouteIncluded"
    )], isTRUE, logical(1L)))
  if (!valid) {
    stop("The Draft.85c4j worker receipt or full objects were altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvq_route_receipt <- function(
    route_id, worker_receipt, fresh_process_verified,
    policy = mfrmr_gtvm_qualification_policy()) {
  route <- policy$RouteRegistry[
    policy$RouteRegistry$RouteId == route_id, , drop = FALSE
  ]
  fit <- worker_receipt$FullFitObjects[[route_id]]
  row <- worker_receipt$RouteObjectRegistry[
    worker_receipt$RouteObjectRegistry$RouteId == route_id, , drop = FALSE
  ]
  if (nrow(route) != 1L || nrow(row) != 1L || is.null(fit)) {
    stop("The Draft.85c4j route is outside the frozen registry.",
         call. = FALSE)
  }
  payload <- list(
    Contract =
      "gtheory_multivariate_revalidated_route_receipt_draft85c4j_v1",
    PolicyHash = policy$PolicyHash,
    WorkerReceiptHash = worker_receipt$ReceiptHash,
    RouteId = route$RouteId,
    Backend = route$Backend,
    Criterion = route$Criterion,
    ProcessIdentityHash = worker_receipt$ProcessIdentityHash,
    WorkerSourceSHA256 = worker_receipt$WorkerSourceSHA256,
    SpecificationHash = row$SpecificationHash,
    SemanticModelHash = row$SemanticModelHash,
    FitResultHash = row$FitResultHash,
    FullFitObjectHash = row$FullFitObjectHash,
    FitStatus = row$FitStatus,
    FitIntegrityPassed = row$FitIntegrityPassed,
    PointEstimationGatePassed = row$PointEstimationGatePassed,
    BackendRowsMatch = row$BackendRowsMatch,
    DependencyABIMatch = row$DependencyABIMatch,
    FreshProcessVerified = fresh_process_verified,
    DiagnosticOverrideUsed = row$DiagnosticOverrideUsed,
    WarningCount = row$WarningCount
  )
  ready <- all(unlist(payload[c(
    "FitIntegrityPassed", "PointEstimationGatePassed", "BackendRowsMatch",
    "DependencyABIMatch", "FreshProcessVerified"
  )], use.names = FALSE)) &&
    !payload$DiagnosticOverrideUsed && payload$WarningCount == 0L &&
    identical(payload$FitStatus, "identified_point_fit")
  structure(c(payload, list(
    ReceiptHash = mfrmr_gtvq_hash(payload),
    FullB1ObjectRevalidated = TRUE,
    RevalidatedReceiptReady = ready,
    ProcessCapabilityIsolationReady = FALSE,
    TrustedReceiptReady = FALSE,
    OperationallyAdmissible = FALSE,
    BackendQualificationReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvq_route_receipt", "list"))
}

mfrmr_gtvq_assert_route_receipt <- function(
    receipt, worker_receipt, policy = mfrmr_gtvm_qualification_policy()) {
  canonical <- mfrmr_gtvq_route_receipt(
    receipt$RouteId, worker_receipt, TRUE, policy
  )
  if (!mfrmr_gtvq_exact_object(
    receipt, names(canonical), class(canonical)
  ) || !identical(receipt, canonical)) {
    stop("The Draft.85c4j route receipt was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvq_pair_receipt <- function(
    pair_id, worker_receipt, route_receipts,
    policy = mfrmr_gtvm_qualification_policy()) {
  pair <- policy$PairRegistry[
    policy$PairRegistry$PairId == pair_id, , drop = FALSE
  ]
  parity <- worker_receipt$FullParityObjects[[pair_id]]
  row <- worker_receipt$PairObjectRegistry[
    worker_receipt$PairObjectRegistry$PairId == pair_id, , drop = FALSE
  ]
  if (nrow(pair) != 1L || nrow(row) != 1L || is.null(parity)) {
    stop("The Draft.85c4j pair is outside the frozen registry.",
         call. = FALSE)
  }
  lme4_receipt <- route_receipts[[pair$Lme4RouteId]]
  glmmtmb_receipt <- route_receipts[[pair$GlmmTMBRouteId]]
  payload <- list(
    Contract =
      "gtheory_multivariate_revalidated_pair_receipt_draft85c4j_v1",
    PolicyHash = policy$PolicyHash,
    WorkerReceiptHash = worker_receipt$ReceiptHash,
    PairId = pair$PairId,
    Criterion = pair$Criterion,
    Lme4RouteReceiptHash = lme4_receipt$ReceiptHash,
    GlmmTMBRouteReceiptHash = glmmtmb_receipt$ReceiptHash,
    SpecificationHash = row$SpecificationHash,
    SemanticModelHash = row$SemanticModelHash,
    ParityResultHash = row$ParityResultHash,
    FullParityObjectHash = row$FullParityObjectHash,
    ToleranceRegistryHash = policy$ToleranceRegistryHash,
    NumericalParityPassed = row$NumericalParityPassed,
    BothPointGatesPassed = row$BothPointGatesPassed,
    BackendDependencyIdentityPassed =
      row$BackendDependencyIdentityPassed,
    ExactSpecificationMatch = row$ExactSpecificationMatch,
    ExactSemanticModelMatch = row$ExactSemanticModelMatch,
    MaximumCovarianceAbsoluteDifference =
      row$MaximumCovarianceAbsoluteDifference,
    MaximumCovarianceRelativeDifference =
      row$MaximumCovarianceRelativeDifference,
    MaximumFixedAbsoluteDifference = row$MaximumFixedAbsoluteDifference,
    LogLikAbsoluteDifference = row$LogLikAbsoluteDifference
  )
  ready <- lme4_receipt$RevalidatedReceiptReady &&
    glmmtmb_receipt$RevalidatedReceiptReady &&
    all(unlist(payload[c(
      "NumericalParityPassed", "BothPointGatesPassed",
      "BackendDependencyIdentityPassed", "ExactSpecificationMatch",
      "ExactSemanticModelMatch"
    )], use.names = FALSE))
  structure(c(payload, list(
    ReceiptHash = mfrmr_gtvq_hash(payload),
    FullB1ObjectRevalidated = TRUE,
    RevalidatedPairReady = ready,
    ProcessCapabilityIsolationReady = FALSE,
    TrustedPairReady = FALSE,
    OperationallyAdmissible = FALSE,
    BackendQualificationReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvq_pair_receipt", "list"))
}

mfrmr_gtvq_assert_pair_receipt <- function(
    receipt, worker_receipt, route_receipts,
    policy = mfrmr_gtvm_qualification_policy()) {
  canonical <- mfrmr_gtvq_pair_receipt(
    receipt$PairId, worker_receipt, route_receipts, policy
  )
  if (!mfrmr_gtvq_exact_object(
    receipt, names(canonical), class(canonical)
  ) || !identical(receipt, canonical)) {
    stop("The Draft.85c4j pair receipt was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvq_receipt_payload_fields <- function() {
  c(
    "Contract", "C4IRepairReceiptHash", "C4FManifestHash", "C4FPolicyHash",
    "SourceRegistry", "SourceRegistryHash", "WorkerSourceSHA256",
    "WorkerIdentity", "WorkerIdentityHash", "Request", "RequestHash",
    "FreshProcessReceipt", "FreshProcessReceiptHash",
    "FreshProcessExitStatus", "FreshProcessOutput",
    "RouteReceipts", "RouteReceiptsHash", "PairReceipts",
    "PairReceiptsHash", "QualificationRoot", "QualificationReceiptPath",
    "ImplementationIdentity", "ImplementationIdentityHash",
    "ArtifactRetained", "ConQuestRouteIncluded"
  )
}

mfrmr_gtvq_implementation_identity <- function() {
  function_names <- c(
    "mfrmr_gtvq_require_primitives", "mfrmr_gtvq_hash",
    "mfrmr_gtvq_file_hash", "mfrmr_gtvq_exact_object",
    "mfrmr_gtvq_source_registry", "mfrmr_gtvq_worker_identity",
    "mfrmr_gtvq_request", "mfrmr_gtvq_route_object_registry",
    "mfrmr_gtvq_pair_object_registry", "mfrmr_gtvq_assert_worker_receipt",
    "mfrmr_gtvq_route_receipt", "mfrmr_gtvq_assert_route_receipt",
    "mfrmr_gtvq_pair_receipt", "mfrmr_gtvq_assert_pair_receipt",
    "mfrmr_gtvq_receipt_payload_fields",
    "mfrmr_gtvq_implementation_identity", "mfrmr_gtvq_assert_receipt",
    "mfrmr_gtvq_execute", "mfrmr_gtvq_dispatch_guard"
  )
  target <- environment(mfrmr_gtvq_implementation_identity)
  data.frame(
    Function = function_names,
    SHA256 = vapply(function_names, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtvq_hash(list(
        Formals = paste(deparse(formals(fun), width.cutoff = 500L),
                        collapse = "\n"),
        Body = paste(deparse(body(fun), width.cutoff = 500L),
                     collapse = "\n")
      ))
    }, character(1L)), stringsAsFactors = FALSE
  )
}

mfrmr_gtvq_assert_receipt <- function(
    receipt, repair_receipt, repair_worker_environment, c4e_manifest,
    c4f_manifest, worker_environment, repo_root = ".",
    validation_dir = file.path("inst", "validation")) {
  mfrmr_gtvq_require_primitives()
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  validation_dir <- normalizePath(validation_dir, mustWork = TRUE)
  mfrmr_gtvp_assert_receipt(
    repair_receipt, repair_worker_environment, c4e_manifest, repo_root
  )
  mfrmr_gtvm_assert_manifest(c4f_manifest, repo_root, c4e_manifest)
  payload_fields <- mfrmr_gtvq_receipt_payload_fields()
  suffix_fields <- c(
    "ReceiptHash", "QualificationWorkerImplemented",
    "FreshProcessQualificationExecuted", "FreshProcessVerified",
    "FreshProcessOutputEmpty", "FullB1FitObjectsReceived",
    "FullB1ParityObjectsReceived", "FullB1ObjectsRevalidated",
    "RouteReceiptsMaterialized", "PairReceiptsMaterialized",
    "AllRouteRevalidatedReceiptsReady", "AllPairRevalidatedReceiptsReady",
    "BackendQualificationNumericallyReady",
    "CandidateQualificationEvidenceReady",
    "ProcessCapabilityIsolationAssessed",
    "ProcessCapabilityIsolationReady", "TrustedReceiptProduced",
    "QualificationEvidenceReady", "BackendQualificationReady",
    "OperationallyAdmissible", "DiagnosticOverrideAllowed",
    "ExecutionGateClosed", "BackendExecutionOccurred",
    "PlannedResponseGenerated", "RecoveryExecuted", "RecoveryEvidenceReady",
    "EstimationReady", "InferenceReady", "DecisionReady",
    "PublicSupportReady"
  )
  if (!mfrmr_gtvq_exact_object(
    receipt, c(payload_fields, suffix_fields),
    c("mfrmr_gtvq_receipt", "list")
  )) {
    stop("A typed Draft.85c4j qualification receipt is required.",
         call. = FALSE)
  }
  source_registry <- mfrmr_gtvq_source_registry(validation_dir)
  worker_source <- file.path(
    validation_dir,
    "gtheory-multivariate-full-object-qualification-worker-0.2.4.R"
  )
  worker_identity <- mfrmr_gtvq_worker_identity(worker_environment)
  request <- mfrmr_gtvq_request(
    repair_receipt, c4f_manifest, mfrmr_gtvq_file_hash(worker_source),
    source_registry
  )
  mfrmr_gtvq_assert_worker_receipt(
    receipt$FreshProcessReceipt, request, repair_receipt,
    worker_environment, controller_process_id = Sys.getpid()
  )
  policy <- mfrmr_gtvm_qualification_policy()
  route_names <- policy$RouteRegistry$RouteId
  pair_names <- policy$PairRegistry$PairId
  if (!is.list(receipt$RouteReceipts) ||
      !identical(names(receipt$RouteReceipts), route_names) ||
      !is.list(receipt$PairReceipts) ||
      !identical(names(receipt$PairReceipts), pair_names)) {
    stop("The Draft.85c4j revalidated receipt registry was altered.",
         call. = FALSE)
  }
  for (item in receipt$RouteReceipts) {
    mfrmr_gtvq_assert_route_receipt(
      item, receipt$FreshProcessReceipt, policy
    )
  }
  for (item in receipt$PairReceipts) {
    mfrmr_gtvq_assert_pair_receipt(
      item, receipt$FreshProcessReceipt, receipt$RouteReceipts, policy
    )
  }
  route_ready <- all(vapply(
    receipt$RouteReceipts, function(item) item$RevalidatedReceiptReady,
    logical(1L)
  ))
  pair_ready <- all(vapply(
    receipt$PairReceipts, function(item) item$RevalidatedPairReady,
    logical(1L)
  ))
  numerical_ready <- route_ready && pair_ready &&
    receipt$FreshProcessReceipt$QualificationObjectsReady
  implementation <- mfrmr_gtvq_implementation_identity()
  root <- normalizePath(receipt$QualificationRoot, mustWork = TRUE)
  receipt_path <- normalizePath(receipt$QualificationReceiptPath,
                                mustWork = TRUE)
  ready_flags <- c(
    "QualificationWorkerImplemented", "FreshProcessQualificationExecuted",
    "FreshProcessVerified", "FreshProcessOutputEmpty",
    "FullB1FitObjectsReceived", "FullB1ParityObjectsReceived",
    "FullB1ObjectsRevalidated", "RouteReceiptsMaterialized",
    "PairReceiptsMaterialized", "AllRouteRevalidatedReceiptsReady",
    "AllPairRevalidatedReceiptsReady", "BackendQualificationNumericallyReady",
    "CandidateQualificationEvidenceReady", "ExecutionGateClosed",
    "BackendExecutionOccurred"
  )
  closed_flags <- c(
    "ProcessCapabilityIsolationAssessed", "ProcessCapabilityIsolationReady",
    "TrustedReceiptProduced", "QualificationEvidenceReady",
    "BackendQualificationReady", "OperationallyAdmissible",
    "DiagnosticOverrideAllowed", "PlannedResponseGenerated",
    "RecoveryExecuted", "RecoveryEvidenceReady", "EstimationReady",
    "InferenceReady", "DecisionReady", "PublicSupportReady"
  )
  valid <- identical(
    receipt$Contract,
    "gtheory_multivariate_full_object_qualification_draft85c4j_v1"
  ) && identical(receipt$C4IRepairReceiptHash,
                 repair_receipt$ReceiptHash) &&
    identical(receipt$C4FManifestHash, c4f_manifest$ManifestHash) &&
    identical(receipt$C4FPolicyHash, policy$PolicyHash) &&
    identical(receipt$SourceRegistry, source_registry) &&
    identical(receipt$SourceRegistryHash,
              mfrmr_gtvq_hash(source_registry)) &&
    identical(receipt$WorkerSourceSHA256,
              mfrmr_gtvq_file_hash(worker_source)) &&
    identical(receipt$WorkerIdentity, worker_identity) &&
    identical(receipt$WorkerIdentityHash,
              mfrmr_gtvq_hash(worker_identity)) &&
    identical(receipt$Request, request) &&
    identical(receipt$RequestHash, request$RequestHash) &&
    identical(receipt$FreshProcessReceiptHash,
              receipt$FreshProcessReceipt$ReceiptHash) &&
    identical(receipt$FreshProcessExitStatus, 0L) &&
    length(receipt$FreshProcessOutput) == 0L &&
    identical(receipt$RouteReceiptsHash,
              mfrmr_gtvq_hash(receipt$RouteReceipts)) &&
    identical(receipt$PairReceiptsHash,
              mfrmr_gtvq_hash(receipt$PairReceipts)) &&
    identical(root, normalizePath(dirname(receipt_path), mustWork = TRUE)) &&
    identical(receipt_path,
              normalizePath(file.path(root, "qualification-receipt.rds"),
                            mustWork = TRUE)) &&
    identical(receipt$ImplementationIdentity, implementation) &&
    identical(receipt$ImplementationIdentityHash,
              mfrmr_gtvq_hash(implementation)) &&
    isTRUE(receipt$ArtifactRetained) &&
    !isTRUE(receipt$ConQuestRouteIncluded) &&
    identical(receipt$ReceiptHash,
              mfrmr_gtvq_hash(receipt[payload_fields])) &&
    numerical_ready &&
    all(vapply(ready_flags, function(name) isTRUE(receipt[[name]]),
               logical(1L))) &&
    !any(vapply(closed_flags, function(name) isTRUE(receipt[[name]]),
                logical(1L)))
  if (!valid) {
    stop("The Draft.85c4j qualification receipt or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvq_execute <- function(
    repair_receipt, repair_worker_environment, c4e_manifest, c4f_manifest,
    worker_environment, repo_root = ".",
    validation_dir = file.path("inst", "validation"),
    authorize_qualification = FALSE, allow_exact_reuse = FALSE) {
  if (!isTRUE(authorize_qualification)) {
    stop("Full-object qualification requires `authorize_qualification=TRUE`.",
         call. = FALSE)
  }
  if (!is.logical(allow_exact_reuse) || length(allow_exact_reuse) != 1L ||
      is.na(allow_exact_reuse)) {
    stop("`allow_exact_reuse` must be TRUE or FALSE.", call. = FALSE)
  }
  mfrmr_gtvq_require_primitives()
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  validation_dir <- normalizePath(validation_dir, mustWork = TRUE)
  mfrmr_gtvp_assert_receipt(
    repair_receipt, repair_worker_environment, c4e_manifest, repo_root
  )
  mfrmr_gtvm_assert_manifest(c4f_manifest, repo_root, c4e_manifest)
  if (!isTRUE(repair_receipt$RepairedEnvironmentReadyForBackendQualification)) {
    stop("The Draft.85c4i repair is not ready for qualification.",
         call. = FALSE)
  }
  source_registry <- mfrmr_gtvq_source_registry(validation_dir)
  worker_source <- normalizePath(file.path(
    validation_dir,
    "gtheory-multivariate-full-object-qualification-worker-0.2.4.R"
  ), mustWork = TRUE)
  worker_source_hash <- mfrmr_gtvq_file_hash(worker_source)
  worker_identity <- mfrmr_gtvq_worker_identity(worker_environment)
  request <- mfrmr_gtvq_request(
    repair_receipt, c4f_manifest, worker_source_hash, source_registry
  )
  root_token <- substr(mfrmr_gtvq_hash(list(
    RepairReceiptHash = repair_receipt$ReceiptHash,
    C4FManifestHash = c4f_manifest$ManifestHash,
    WorkerSourceSHA256 = worker_source_hash,
    SourceRegistryHash = request$SourceRegistryHash
  )), 1L, 16L)
  root <- file.path(
    repair_receipt$RepairRoot, paste0("qualification-c4j-", root_token)
  )
  receipt_path <- file.path(root, "qualification-receipt.rds")
  if (dir.exists(root) || file.exists(root)) {
    if (isTRUE(allow_exact_reuse) && file.exists(receipt_path)) {
      receipt <- readRDS(receipt_path)
      mfrmr_gtvq_assert_receipt(
        receipt, repair_receipt, repair_worker_environment, c4e_manifest,
        c4f_manifest, worker_environment, repo_root, validation_dir
      )
      return(receipt)
    }
    stop("The deterministic Draft.85c4j qualification path is occupied.",
         call. = FALSE)
  }
  if (!dir.create(root)) {
    stop("Draft.85c4j could not create the qualification root.",
         call. = FALSE)
  }
  success <- FALSE
  on.exit({
    if (!success && dir.exists(root)) unlink(root, recursive = TRUE)
  }, add = TRUE)
  staged_source <- file.path(root, "source")
  if (!dir.create(staged_source)) {
    stop("Draft.85c4j could not create the staged source directory.",
         call. = FALSE)
  }
  copied <- file.copy(
    file.path(validation_dir, source_registry$FileName),
    file.path(staged_source, source_registry$FileName)
  )
  staged_worker <- file.path(staged_source, "qualification-worker.R")
  copied_worker <- file.copy(worker_source, staged_worker)
  if (!all(copied) || !isTRUE(copied_worker) ||
      !identical(mfrmr_gtvq_source_registry(staged_source),
                 source_registry) ||
      !identical(mfrmr_gtvq_file_hash(staged_worker), worker_source_hash)) {
    stop("The Draft.85c4j staged source identity did not match.",
         call. = FALSE)
  }
  request_path <- file.path(root, "qualification-request.rds")
  worker_receipt_path <- file.path(root, "worker-receipt.rds")
  saveRDS(request, request_path, version = 3L)
  library_order <- paste(
    c(repair_receipt$OverlayLibrary, .libPaths()),
    collapse = .Platform$path.sep
  )
  process_output <- suppressWarnings(system2(
    repair_receipt$ToolchainIdentity$RscriptExecutable,
    c(
      "--vanilla", staged_worker, request_path, staged_source,
      repair_receipt$OverlayLibrary, worker_receipt_path
    ),
    env = paste0("R_LIBS_USER=", library_order),
    stdout = TRUE, stderr = TRUE
  ))
  process_status <- attr(process_output, "status")
  if (is.null(process_status)) process_status <- 0L
  if (process_status != 0L || !file.exists(worker_receipt_path)) {
    stop(
      "Draft.85c4j fresh-process qualification failed: ",
      paste(process_output, collapse = " | "), call. = FALSE
    )
  }
  worker_receipt <- readRDS(worker_receipt_path)
  mfrmr_gtvq_assert_worker_receipt(
    worker_receipt, request, repair_receipt, worker_environment,
    controller_process_id = Sys.getpid()
  )
  policy <- mfrmr_gtvm_qualification_policy()
  route_receipts <- stats::setNames(lapply(
    policy$RouteRegistry$RouteId, function(route_id) {
      mfrmr_gtvq_route_receipt(route_id, worker_receipt, TRUE, policy)
    }
  ), policy$RouteRegistry$RouteId)
  pair_receipts <- stats::setNames(lapply(
    policy$PairRegistry$PairId, function(pair_id) {
      mfrmr_gtvq_pair_receipt(
        pair_id, worker_receipt, route_receipts, policy
      )
    }
  ), policy$PairRegistry$PairId)
  route_ready <- all(vapply(
    route_receipts, function(item) item$RevalidatedReceiptReady,
    logical(1L)
  ))
  pair_ready <- all(vapply(
    pair_receipts, function(item) item$RevalidatedPairReady,
    logical(1L)
  ))
  numerical_ready <- route_ready && pair_ready &&
    worker_receipt$QualificationObjectsReady &&
    length(process_output) == 0L
  implementation <- mfrmr_gtvq_implementation_identity()
  payload <- list(
    Contract =
      "gtheory_multivariate_full_object_qualification_draft85c4j_v1",
    C4IRepairReceiptHash = repair_receipt$ReceiptHash,
    C4FManifestHash = c4f_manifest$ManifestHash,
    C4FPolicyHash = policy$PolicyHash,
    SourceRegistry = source_registry,
    SourceRegistryHash = mfrmr_gtvq_hash(source_registry),
    WorkerSourceSHA256 = worker_source_hash,
    WorkerIdentity = worker_identity,
    WorkerIdentityHash = mfrmr_gtvq_hash(worker_identity),
    Request = request,
    RequestHash = request$RequestHash,
    FreshProcessReceipt = worker_receipt,
    FreshProcessReceiptHash = worker_receipt$ReceiptHash,
    FreshProcessExitStatus = as.integer(process_status),
    FreshProcessOutput = as.character(process_output),
    RouteReceipts = route_receipts,
    RouteReceiptsHash = mfrmr_gtvq_hash(route_receipts),
    PairReceipts = pair_receipts,
    PairReceiptsHash = mfrmr_gtvq_hash(pair_receipts),
    QualificationRoot = normalizePath(root, mustWork = TRUE),
    QualificationReceiptPath = normalizePath(receipt_path, mustWork = FALSE),
    ImplementationIdentity = implementation,
    ImplementationIdentityHash = mfrmr_gtvq_hash(implementation),
    ArtifactRetained = TRUE,
    ConQuestRouteIncluded = FALSE
  )
  receipt <- structure(c(payload, list(
    ReceiptHash = mfrmr_gtvq_hash(payload),
    QualificationWorkerImplemented = TRUE,
    FreshProcessQualificationExecuted = TRUE,
    FreshProcessVerified = TRUE,
    FreshProcessOutputEmpty = length(process_output) == 0L,
    FullB1FitObjectsReceived =
      identical(length(worker_receipt$FullFitObjects), 4L),
    FullB1ParityObjectsReceived =
      identical(length(worker_receipt$FullParityObjects), 2L),
    FullB1ObjectsRevalidated = TRUE,
    RouteReceiptsMaterialized = identical(length(route_receipts), 4L),
    PairReceiptsMaterialized = identical(length(pair_receipts), 2L),
    AllRouteRevalidatedReceiptsReady = route_ready,
    AllPairRevalidatedReceiptsReady = pair_ready,
    BackendQualificationNumericallyReady = numerical_ready,
    CandidateQualificationEvidenceReady = numerical_ready,
    ProcessCapabilityIsolationAssessed = FALSE,
    ProcessCapabilityIsolationReady = FALSE,
    TrustedReceiptProduced = FALSE,
    QualificationEvidenceReady = FALSE,
    BackendQualificationReady = FALSE,
    OperationallyAdmissible = FALSE,
    DiagnosticOverrideAllowed = FALSE,
    ExecutionGateClosed = TRUE,
    BackendExecutionOccurred = TRUE,
    PlannedResponseGenerated = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvq_receipt", "list"))
  saveRDS(receipt, receipt_path, version = 3L)
  mfrmr_gtvq_assert_receipt(
    receipt, repair_receipt, repair_worker_environment, c4e_manifest,
    c4f_manifest, worker_environment, repo_root, validation_dir
  )
  success <- TRUE
  receipt
}

mfrmr_gtvq_dispatch_guard <- function(
    receipt, action, callback, ..., authorize = FALSE,
    repair_receipt, repair_worker_environment, c4e_manifest, c4f_manifest,
    worker_environment, repo_root = ".",
    validation_dir = file.path("inst", "validation")) {
  mfrmr_gtvq_assert_receipt(
    receipt, repair_receipt, repair_worker_environment, c4e_manifest,
    c4f_manifest, worker_environment, repo_root, validation_dir
  )
  if (!is.character(action) || length(action) != 1L || is.na(action) ||
      !action %in% c(
        "capability_isolation", "receipt_trust", "operational_promotion"
      )) {
    stop("The Draft.85c4j action is outside full-object qualification.",
         call. = FALSE)
  }
  if (!is.function(callback)) {
    stop("`callback` must be a function.", call. = FALSE)
  }
  if (!is.logical(authorize) || length(authorize) != 1L || is.na(authorize)) {
    stop("`authorize` must be TRUE or FALSE.", call. = FALSE)
  }
  stop(
    "Draft.85c4j has no capability-isolation evidence; trust remains closed.",
    call. = FALSE
  )
}
