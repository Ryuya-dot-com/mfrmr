# Draft.85c4p nonreserved fit-candidate worker.
#
# Repository-internal only. This program consumes one exact Draft.85c4o
# envelope, invokes one qualified Draft.85b1 route, and returns the normalized
# fit plus a compact receipt. Capability isolation is deliberately left to a
# successor gate.

mfrmr_gtvww_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4p worker requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvww_file_hash <- function(path) {
  path <- normalizePath(path, mustWork = TRUE)
  if (dir.exists(path)) stop("A Draft.85c4p file is required.", call. = FALSE)
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtvww_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    identical(sort(names(attributes(object))), c("class", "names"))
}

mfrmr_gtvww_source_registry <- function(source_dir) {
  source_dir <- normalizePath(source_dir, mustWork = TRUE)
  files <- c(
    "gtheory-design-algebra-prototype-0.2.3.R",
    "gtheory-multivariate-algebra-prototype-0.2.3.R",
    "gtheory-multivariate-incidence-preflight-0.2.4.R",
    "gtheory-multivariate-matched-backend-prototype-0.2.4.R",
    "gtheory-multivariate-fit-candidate-envelope-worker-0.2.4.R"
  )
  paths <- file.path(source_dir, files)
  if (!all(file.exists(paths))) {
    stop("The Draft.85c4p staged source set is incomplete.", call. = FALSE)
  }
  data.frame(
    SourceOrdinal = seq_along(files), FileName = files,
    SHA256 = unname(vapply(paths, mfrmr_gtvww_file_hash, character(1L))),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvww_route_registry <- function() {
  data.frame(
    MethodOrdinal = 1:4,
    MethodId = c("lme4_reml", "glmmtmb_reml", "lme4_ml", "glmmtmb_ml"),
    QualificationRouteId = c(
      "lme4_reml", "glmmTMB_reml", "lme4_ml", "glmmTMB_ml"
    ),
    Backend = c("lme4", "glmmTMB", "lme4", "glmmTMB"),
    Criterion = c("REML", "REML", "ML", "ML"),
    ControlContract = c(
      "Draft85b1_lmerControl_default_no_override",
      "Draft85b1_glmmTMBControl_default_no_override",
      "Draft85b1_lmerControl_default_no_override",
      "Draft85b1_glmmTMBControl_default_no_override"
    ),
    MatrixTolerance = rep(1e-10, 4L),
    BoundaryTolerance = rep(1e-8, 4L),
    CorrelationTolerance = rep(1e-6, 4L),
    SingularTolerance = c(1e-4, NA_real_, 1e-4, NA_real_),
    DiagnosticOverrideAllowed = rep(FALSE, 4L),
    MethodControlHash = c(
      "908e5593e3fad9bd59a874b3189426a5072822310f10a6510ca8374b6c7f574b",
      "b4349fd18b3441e4e20e53c5a0835698999f9a60a5e2820afc1a280b61c6f515",
      "90d1795dee4e22d08e29e8d8a98654a6ee2f93043b79d20087d0e58aece1827f",
      "723e2fc6cb94ba043cb49b10fa33939408702c61771ef8e6537e3480cb64a76c"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvww_component_map <- function() {
  data.frame(
    ComponentId = c("Object", "Rater", "Object:Rater", "Residual"),
    UniverseRole = c(
      "object", "absolute_only", "relative_error", "relative_error"
    ),
    Members = c("Object", "Rater", "Object:Rater", ""),
    CovarianceStructure = c(
      rep("unstructured", 3L), "homoskedastic_independent"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvww_process_identity <- function() {
  rscript <- normalizePath(file.path(R.home("bin"), "Rscript"),
                           mustWork = TRUE)
  payload <- list(
    ProcessId = as.integer(Sys.getpid()),
    RVersion = as.character(getRversion()),
    RPlatform = R.version$platform,
    RscriptExecutable = rscript,
    RscriptExecutableSHA256 = mfrmr_gtvww_file_hash(rscript),
    LibraryOrder = normalizePath(.libPaths(), mustWork = TRUE)
  )
  c(payload, list(ProcessIdentityHash = mfrmr_gtvww_hash(payload)))
}

mfrmr_gtvww_package_registry <- function(backend) {
  if (!is.character(backend) || length(backend) != 1L || is.na(backend) ||
      !backend %in% c("lme4", "glmmTMB")) {
    stop("A canonical Draft.85c4p backend is required.", call. = FALSE)
  }
  packages <- if (identical(backend, "lme4")) {
    c("digest", "lme4")
  } else c("digest", "glmmTMB", "TMB")
  available <- vapply(packages, requireNamespace, logical(1L), quietly = TRUE)
  if (!all(available)) {
    stop("Draft.85c4p packages are incomplete: ",
         paste(packages[!available], collapse = ", "), ".", call. = FALSE)
  }
  data.frame(
    Package = packages,
    Version = vapply(packages, function(package) {
      as.character(utils::packageVersion(package))
    }, character(1L)),
    NamespacePath = vapply(packages, function(package) {
      normalizePath(getNamespaceInfo(asNamespace(package), "path"),
                    mustWork = TRUE)
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvww_assert_request <- function(request, source_dir, overlay, runtime) {
  payload_fields <- c(
    "Contract", "EvidenceUse", "NonreservedExecutionAuthorized",
    "C4OManifestHash", "C4LReceiptHash", "C4IRepairReceiptHash",
    "Envelope", "EnvelopeHash", "MethodId", "QualificationRouteId",
    "Backend", "Criterion", "MethodControlHash",
    "QualifiedRouteReceiptHash", "QualifiedFitSpecificationHash",
    "QualifiedSemanticModelHash", "WorkerSourceSHA256", "SourceRegistry",
    "SourceRegistryHash", "RepairRoot", "OverlayLibrary",
    "ComponentMapHash", "ObservationLinkColumns",
    "MaxCovarianceDesignCells"
  )
  if (!mfrmr_gtvww_exact_object(
    request, c(payload_fields, "RequestHash"),
    c("mfrmr_gtvww_request", "list")
  )) {
    stop("A typed Draft.85c4p fit request is required.", call. = FALSE)
  }
  route <- mfrmr_gtvww_route_registry()
  index <- match(request$MethodId, route$MethodId)
  source_registry <- mfrmr_gtvww_source_registry(source_dir)
  hashes <- unlist(request[c(
    "C4OManifestHash", "C4LReceiptHash", "C4IRepairReceiptHash",
    "EnvelopeHash", "MethodControlHash", "QualifiedRouteReceiptHash",
    "QualifiedFitSpecificationHash", "QualifiedSemanticModelHash",
    "WorkerSourceSHA256", "SourceRegistryHash", "ComponentMapHash",
    "RequestHash"
  )], use.names = FALSE)
  runtime$mfrmr_gtvvw_assert_envelope(request$Envelope)
  valid <- identical(
    request$Contract,
    "gtheory_multivariate_fit_candidate_request_draft85c4p_v1"
  ) && identical(request$EvidenceUse, "nonreserved_fixture_fit_only") &&
    isTRUE(request$NonreservedExecutionAuthorized) && !is.na(index) &&
    is.character(hashes) && length(hashes) == 12L && !anyNA(hashes) &&
    all(grepl("^[0-9a-f]{64}$", hashes)) &&
    identical(request$EnvelopeHash, request$Envelope$EnvelopeHash) &&
    identical(request$MethodId, request$Envelope$MethodId) &&
    identical(request$QualificationRouteId,
              route$QualificationRouteId[[index]]) &&
    identical(request$QualificationRouteId,
              request$Envelope$QualificationRouteId) &&
    identical(request$Backend, route$Backend[[index]]) &&
    identical(request$Backend, request$Envelope$Backend) &&
    identical(request$Criterion, route$Criterion[[index]]) &&
    identical(request$Criterion, request$Envelope$Criterion) &&
    identical(request$MethodControlHash,
              route$MethodControlHash[[index]]) &&
    identical(request$MethodControlHash,
              request$Envelope$MethodControlHash) &&
    identical(request$SourceRegistry, source_registry) &&
    identical(request$SourceRegistryHash, mfrmr_gtvww_hash(source_registry)) &&
    identical(normalizePath(request$OverlayLibrary, mustWork = TRUE),
              normalizePath(overlay, mustWork = TRUE)) &&
    identical(normalizePath(request$RepairRoot, mustWork = TRUE),
              normalizePath(dirname(overlay), mustWork = TRUE)) &&
    identical(request$ComponentMapHash,
              mfrmr_gtvww_hash(mfrmr_gtvww_component_map())) &&
    identical(request$ObservationLinkColumns,
              c("Rater", "ObservationLink")) &&
    identical(request$MaxCovarianceDesignCells, 5e6) &&
    !isTRUE(request$Envelope$PlannedCandidate) &&
    !isTRUE(request$Envelope$RecoveryDenominatorEligible) &&
    !isTRUE(request$Envelope$BackendExecutionAuthorized) &&
    identical(request$RequestHash, mfrmr_gtvww_hash(request[payload_fields]))
  if (!valid) {
    stop("The Draft.85c4p fit request was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvww_coordinate_registry <- function(fit, envelope) {
  strata <- fit$Spec$Strata
  components <- c("Object", "Rater", "Object:Rater")
  rows <- list(); cursor <- 0L
  for (component in components) {
    matrix <- fit$ComponentCovariances[[component]]
    for (left in seq_along(strata)) {
      for (right in left:length(strata)) {
        cursor <- cursor + 1L
        rows[[cursor]] <- data.frame(
          CoordinateOrdinal = as.integer(cursor),
          CoordinateId = paste0(
            component, "[", strata[[left]], ",", strata[[right]], "]"
          ),
          ComponentId = component,
          LeftStratum = strata[[left]], RightStratum = strata[[right]],
          CoordinateType = if (left == right) "variance" else "covariance",
          Estimate = as.numeric(matrix[left, right]),
          stringsAsFactors = FALSE
        )
      }
    }
  }
  cursor <- cursor + 1L
  rows[[cursor]] <- data.frame(
    CoordinateOrdinal = as.integer(cursor), CoordinateId = "Residual[I]",
    ComponentId = "Residual", LeftStratum = NA_character_,
    RightStratum = NA_character_, CoordinateType = "residual_variance",
    Estimate = as.numeric(fit$ComponentCovariances$Residual[1L, 1L]),
    stringsAsFactors = FALSE
  )
  registry <- do.call(rbind, rows)
  row.names(registry) <- NULL
  if (!identical(nrow(registry), envelope$CoordinateCount) ||
      any(!is.finite(registry$Estimate))) {
    stop("The Draft.85c4p coordinate extraction is incomplete.",
         call. = FALSE)
  }
  registry
}

mfrmr_gtvww_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtvww_hash", "mfrmr_gtvww_file_hash",
    "mfrmr_gtvww_exact_object", "mfrmr_gtvww_source_registry",
    "mfrmr_gtvww_route_registry", "mfrmr_gtvww_component_map",
    "mfrmr_gtvww_process_identity", "mfrmr_gtvww_package_registry",
    "mfrmr_gtvww_assert_request", "mfrmr_gtvww_coordinate_registry",
    "mfrmr_gtvww_implementation_identity", "mfrmr_gtvww_main"
  )
  target <- environment(mfrmr_gtvww_implementation_identity)
  data.frame(
    Function = functions,
    SHA256 = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtvww_hash(list(
        Formals = paste(deparse(formals(fun), width.cutoff = 500L),
                        collapse = "\n"),
        Body = paste(deparse(body(fun), width.cutoff = 500L), collapse = "\n")
      ))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvww_main <- function(arguments = commandArgs(trailingOnly = TRUE)) {
  if (length(arguments) != 4L) {
    stop("Draft.85c4p worker requires request, source, overlay, and output.",
         call. = FALSE)
  }
  request_path <- normalizePath(arguments[[1L]], mustWork = TRUE)
  source_dir <- normalizePath(arguments[[2L]], mustWork = TRUE)
  overlay <- normalizePath(arguments[[3L]], mustWork = TRUE)
  output_path <- arguments[[4L]]
  if (!identical(normalizePath(.libPaths()[[1L]], mustWork = TRUE), overlay)) {
    stop("The Draft.85c4p repair overlay is not first in library order.",
         call. = FALSE)
  }
  request <- readRDS(request_path)
  file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE),
                        value = TRUE)
  if (length(file_argument) != 1L || !identical(
    mfrmr_gtvww_file_hash(sub("^--file=", "", file_argument)),
    request$WorkerSourceSHA256
  )) {
    stop("The Draft.85c4p worker source identity changed.", call. = FALSE)
  }
  runtime <- new.env(parent = globalenv())
  for (file in request$SourceRegistry$FileName) {
    sys.source(file.path(source_dir, file), envir = runtime)
  }
  mfrmr_gtvww_assert_request(request, source_dir, overlay, runtime)
  data <- request$Envelope$CandidateData
  strata <- if (identical(
    request$Envelope$CoordinateLayoutId, "T2-GLOBAL-3C-R1"
  )) c("A", "B") else c("A", "B", "C")
  incidence <- runtime$mfrmr_gtvi_audit(
    data, object_col = "Object", stratum_col = "Stratum",
    score_col = "Score", condition_cols = request$ObservationLinkColumns,
    condition_scope = stats::setNames(
      rep("global", length(request$ObservationLinkColumns)),
      request$ObservationLinkColumns
    ), strata = strata, missingness = "complete"
  )
  spec <- runtime$mfrmr_gtvb_spec(
    data, incidence, mfrmr_gtvww_component_map(),
    request$ObservationLinkColumns,
    max_covariance_design_cells = request$MaxCovarianceDesignCells
  )
  if (!isTRUE(spec$PairIdentityReady) ||
      spec$DuplicateWithinStratumObservationKeys != 0L ||
      any(spec$ObservationPairAudit$SharedObservationLinks < 1L)) {
    stop("The Draft.85c4p observation-link specification is not ready.",
         call. = FALSE)
  }
  route <- mfrmr_gtvww_route_registry()
  index <- match(request$MethodId, route$MethodId)
  reml <- identical(request$Criterion, "REML")
  fit <- if (identical(request$Backend, "lme4")) {
    runtime$mfrmr_gtvb_fit_lme4(
      spec, reml = reml,
      matrix_tolerance = route$MatrixTolerance[[index]],
      boundary_tolerance = route$BoundaryTolerance[[index]],
      correlation_tolerance = route$CorrelationTolerance[[index]],
      singular_tolerance = route$SingularTolerance[[index]]
    )
  } else {
    runtime$mfrmr_gtvb_fit_glmmtmb(
      spec, reml = reml,
      matrix_tolerance = route$MatrixTolerance[[index]],
      boundary_tolerance = route$BoundaryTolerance[[index]],
      correlation_tolerance = route$CorrelationTolerance[[index]],
      allow_dependency_mismatch_diagnostic = FALSE
    )
  }
  runtime$mfrmr_gtvb_assert_fit_integrity(fit)
  coordinates <- mfrmr_gtvww_coordinate_registry(fit, request$Envelope)
  process <- mfrmr_gtvww_process_identity()
  packages <- mfrmr_gtvww_package_registry(request$Backend)
  implementation <- mfrmr_gtvww_implementation_identity()
  payload <- list(
    Contract = "gtheory_multivariate_fit_candidate_receipt_draft85c4p_v1",
    RequestHash = request$RequestHash,
    C4OManifestHash = request$C4OManifestHash,
    C4LReceiptHash = request$C4LReceiptHash,
    C4IRepairReceiptHash = request$C4IRepairReceiptHash,
    EnvelopeHash = request$EnvelopeHash,
    OpaqueExerciseId = request$Envelope$OpaqueExerciseId,
    CandidateDataHash = request$Envelope$CandidateDataHash,
    CandidateSchemaHash = request$Envelope$CandidateSchemaHash,
    MethodId = request$MethodId,
    QualificationRouteId = request$QualificationRouteId,
    Backend = request$Backend, Criterion = request$Criterion,
    MethodControlHash = request$MethodControlHash,
    QualifiedRouteReceiptHash = request$QualifiedRouteReceiptHash,
    QualifiedFitSpecificationHash = request$QualifiedFitSpecificationHash,
    QualifiedSemanticModelHash = request$QualifiedSemanticModelHash,
    SourceRegistryHash = request$SourceRegistryHash,
    WorkerSourceSHA256 = request$WorkerSourceSHA256,
    WorkerImplementationIdentity = implementation,
    WorkerImplementationIdentityHash = mfrmr_gtvww_hash(implementation),
    ProcessIdentity = process,
    ProcessIdentityHash = process$ProcessIdentityHash,
    PackageRegistry = packages,
    PackageRegistryHash = mfrmr_gtvww_hash(packages),
    SpecificationHash = fit$SpecificationHash,
    IncidenceAuditHash = fit$IncidenceAuditHash,
    ObservationKeyHash = fit$Spec$ObservationKeyHash,
    ObservationPairAuditHash = mfrmr_gtvww_hash(
      fit$Spec$ObservationPairAudit
    ),
    SemanticModelHash = fit$EstimatorIdentity$SemanticModelHash,
    FitResultHash = fit$ResultHash,
    FitQualification = fit$FitQualification,
    FitStatus = fit$FitDiagnostics$FitStatus,
    LogLikelihood = fit$LikelihoodIdentity$Value,
    LogLikelihoodDegreesFreedom = fit$LikelihoodIdentity$DegreesFreedom,
    CoordinateEstimateRegistry = coordinates,
    CoordinateEstimateRegistryHash = mfrmr_gtvww_hash(coordinates),
    Attempted = TRUE, BackendInvoked = TRUE, FitReturned = TRUE,
    PointEstimationGatePassed = fit$PointEstimationGatePassed
  )
  receipt <- structure(c(payload, list(
    ReceiptHash = mfrmr_gtvww_hash(payload),
    WorkerSelfReported = TRUE, FreshProcessSelfReported = TRUE,
    NonreservedFixture = TRUE, FitCapableWorkerImplemented = TRUE,
    FitCapableProcessCapabilityIsolationReady = FALSE,
    TruthBlindProcessBoundaryReady = FALSE,
    PlannedCandidate = FALSE, RecoveryDenominatorEligible = FALSE,
    CandidateCompletionSealed = FALSE, TruthReleaseAuthorized = FALSE,
    DenominatorAccountingReady = FALSE, RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE, InferenceReady = FALSE,
    DecisionReady = FALSE, PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvww_receipt", "list"))
  output_payload <- list(
    Contract = "gtheory_multivariate_fit_candidate_output_draft85c4p_v1",
    Receipt = receipt, Fit = fit
  )
  output <- structure(c(output_payload, list(
    OutputHash = mfrmr_gtvww_hash(list(
      Contract = output_payload$Contract,
      ReceiptHash = receipt$ReceiptHash, FitResultHash = fit$ResultHash
    ))
  )), class = c("mfrmr_gtvww_output", "list"))
  saveRDS(output, output_path, version = 3L)
  invisible(output)
}

if (identical(environment(), globalenv()) && !interactive()) {
  mfrmr_gtvww_main()
}
