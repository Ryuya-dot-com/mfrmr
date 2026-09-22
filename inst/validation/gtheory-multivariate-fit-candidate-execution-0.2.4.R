# Draft.85c4p nonreserved fit-candidate execution.
#
# Repository-internal only. The controller stages the exact Draft.85b1 and
# Draft.85c4o sources, launches one fresh process per qualified route, and
# independently revalidates the normalized fit objects. It does not assess
# default-deny capabilities or enter a planned recovery denominator.

mfrmr_gtvw_require_primitives <- function() {
  required <- c(
    "mfrmr_gtvd_assert_plan", "mfrmr_gtve_assert_manifest",
    "mfrmr_gtve_generate_fixture", "mfrmr_gtvv_candidate_release",
    "mfrmr_gtvv_assert_candidate_envelope", "mfrmr_gtvv_payload_fields",
    "mfrmr_gtvb_assert_fit_integrity", "mfrmr_gtvb_compare"
  )
  target <- environment(mfrmr_gtvw_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop("Source Draft.85b1, c1/c2, and c4o before c4p: ",
         paste(missing, collapse = ", "), ".", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvw_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4p requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvw_file_hash <- function(path) {
  path <- normalizePath(path, mustWork = TRUE)
  if (dir.exists(path)) stop("A Draft.85c4p file is required.", call. = FALSE)
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtvw_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    identical(sort(names(attributes(object))), c("class", "names"))
}

mfrmr_gtvw_source_registry <- function(validation_dir) {
  validation_dir <- normalizePath(validation_dir, mustWork = TRUE)
  files <- c(
    "gtheory-design-algebra-prototype-0.2.3.R",
    "gtheory-multivariate-algebra-prototype-0.2.3.R",
    "gtheory-multivariate-incidence-preflight-0.2.4.R",
    "gtheory-multivariate-matched-backend-prototype-0.2.4.R",
    "gtheory-multivariate-fit-candidate-envelope-worker-0.2.4.R"
  )
  paths <- file.path(validation_dir, files)
  if (!all(file.exists(paths))) {
    stop("The Draft.85c4p source registry is incomplete.", call. = FALSE)
  }
  data.frame(
    SourceOrdinal = seq_along(files), FileName = files,
    SHA256 = unname(vapply(paths, mfrmr_gtvw_file_hash, character(1L))),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvw_worker_identity <- function(worker_environment) {
  functions <- c(
    "mfrmr_gtvww_hash", "mfrmr_gtvww_file_hash",
    "mfrmr_gtvww_exact_object", "mfrmr_gtvww_source_registry",
    "mfrmr_gtvww_route_registry", "mfrmr_gtvww_component_map",
    "mfrmr_gtvww_process_identity", "mfrmr_gtvww_package_registry",
    "mfrmr_gtvww_assert_request", "mfrmr_gtvww_coordinate_registry",
    "mfrmr_gtvww_implementation_identity", "mfrmr_gtvww_main"
  )
  if (!is.environment(worker_environment) ||
      !identical(parent.env(worker_environment), baseenv()) ||
      !identical(sort(ls(worker_environment, all.names = TRUE),
                      method = "radix"), sort(functions, method = "radix")) ||
      !all(vapply(functions, function(name) {
        is.function(get(name, envir = worker_environment, inherits = FALSE))
      }, logical(1L)))) {
    stop("The Draft.85c4p worker namespace was altered.", call. = FALSE)
  }
  data.frame(
    Function = functions,
    SHA256 = vapply(functions, function(name) {
      fun <- get(name, envir = worker_environment, inherits = FALSE)
      mfrmr_gtvw_hash(list(
        Formals = paste(deparse(formals(fun), width.cutoff = 500L),
                        collapse = "\n"),
        Body = paste(deparse(body(fun), width.cutoff = 500L), collapse = "\n")
      ))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvw_request <- function(
    envelope, c4o_manifest, c4l_receipt, repair_receipt,
    worker_source_sha256, source_registry, worker_environment) {
  mfrmr_gtvw_require_primitives()
  route_index <- match(
    envelope$QualificationRouteId,
    c4l_receipt$QualificationRouteRegistry$RouteId
  )
  if (is.na(route_index) ||
      !isTRUE(c4l_receipt$QualificationRouteRegistry$ReceiptReady[[
        route_index
      ]])) {
    stop("The Draft.85c4p route is not qualified by c4l.", call. = FALSE)
  }
  route <- c4l_receipt$QualificationRouteRegistry[route_index, , drop = FALSE]
  component_map <- get(
    "mfrmr_gtvww_component_map", envir = worker_environment,
    inherits = FALSE
  )()
  payload <- list(
    Contract = "gtheory_multivariate_fit_candidate_request_draft85c4p_v1",
    EvidenceUse = "nonreserved_fixture_fit_only",
    NonreservedExecutionAuthorized = TRUE,
    C4OManifestHash = c4o_manifest$ManifestHash,
    C4LReceiptHash = c4l_receipt$ReceiptHash,
    C4IRepairReceiptHash = repair_receipt$ReceiptHash,
    Envelope = envelope, EnvelopeHash = envelope$EnvelopeHash,
    MethodId = envelope$MethodId,
    QualificationRouteId = envelope$QualificationRouteId,
    Backend = envelope$Backend, Criterion = envelope$Criterion,
    MethodControlHash = envelope$MethodControlHash,
    QualifiedRouteReceiptHash = route$TrustedQualificationReceiptHash,
    QualifiedFitSpecificationHash = route$FitSpecificationHash,
    QualifiedSemanticModelHash = route$SemanticModelHash,
    WorkerSourceSHA256 = worker_source_sha256,
    SourceRegistry = source_registry,
    SourceRegistryHash = mfrmr_gtvw_hash(source_registry),
    RepairRoot = normalizePath(repair_receipt$RepairRoot, mustWork = TRUE),
    OverlayLibrary = normalizePath(
      repair_receipt$OverlayLibrary, mustWork = TRUE
    ),
    ComponentMapHash = mfrmr_gtvw_hash(component_map),
    ObservationLinkColumns = c("Rater", "ObservationLink"),
    MaxCovarianceDesignCells = 5e6
  )
  structure(c(payload, list(
    RequestHash = mfrmr_gtvw_hash(payload)
  )), class = c("mfrmr_gtvww_request", "list"))
}

mfrmr_gtvw_assert_output <- function(
    output, request, worker_environment, controller_process_id) {
  if (!mfrmr_gtvw_exact_object(
    output, c("Contract", "Receipt", "Fit", "OutputHash"),
    c("mfrmr_gtvww_output", "list")
  )) {
    stop("A typed Draft.85c4p worker output is required.", call. = FALSE)
  }
  receipt <- output$Receipt
  fit <- output$Fit
  if (!"ReceiptHash" %in% names(receipt)) {
    stop("The Draft.85c4p worker receipt has no identity field.",
         call. = FALSE)
  }
  receipt_payload <- names(receipt)[seq_len(match("ReceiptHash", names(receipt)) - 1L)]
  receipt_suffix <- names(receipt)[match("ReceiptHash", names(receipt)):length(receipt)]
  expected_suffix <- c(
    "ReceiptHash", "WorkerSelfReported", "FreshProcessSelfReported",
    "NonreservedFixture", "FitCapableWorkerImplemented",
    "FitCapableProcessCapabilityIsolationReady",
    "TruthBlindProcessBoundaryReady", "PlannedCandidate",
    "RecoveryDenominatorEligible", "CandidateCompletionSealed",
    "TruthReleaseAuthorized", "DenominatorAccountingReady",
    "RecoveryEvidenceReady", "EstimationReady", "InferenceReady",
    "DecisionReady", "PublicSupportReady"
  )
  if (!inherits(fit, "mfrmr_gtvb_fit") ||
      !mfrmr_gtvw_exact_object(
        receipt, c(receipt_payload, expected_suffix),
        c("mfrmr_gtvww_receipt", "list")
      ) || !identical(receipt_suffix, expected_suffix)) {
    stop("The Draft.85c4p worker receipt shape changed.", call. = FALSE)
  }
  mfrmr_gtvb_assert_fit_integrity(fit)
  coordinate <- get(
    "mfrmr_gtvww_coordinate_registry", envir = worker_environment,
    inherits = FALSE
  )(fit, request$Envelope)
  false_flags <- c(
    "FitCapableProcessCapabilityIsolationReady",
    "TruthBlindProcessBoundaryReady", "PlannedCandidate",
    "RecoveryDenominatorEligible", "CandidateCompletionSealed",
    "TruthReleaseAuthorized", "DenominatorAccountingReady",
    "RecoveryEvidenceReady", "EstimationReady", "InferenceReady",
    "DecisionReady", "PublicSupportReady"
  )
  expected_packages <- if (identical(request$Backend, "lme4")) {
    c("digest", "lme4")
  } else c("digest", "glmmTMB", "TMB")
  valid <- identical(
    output$Contract,
    "gtheory_multivariate_fit_candidate_output_draft85c4p_v1"
  ) && identical(
    receipt$Contract,
    "gtheory_multivariate_fit_candidate_receipt_draft85c4p_v1"
  ) && identical(receipt$RequestHash, request$RequestHash) &&
    identical(receipt$EnvelopeHash, request$EnvelopeHash) &&
    identical(receipt$CandidateDataHash,
              request$Envelope$CandidateDataHash) &&
    identical(receipt$MethodId, request$MethodId) &&
    identical(receipt$QualificationRouteId,
              request$QualificationRouteId) &&
    identical(receipt$Backend, request$Backend) &&
    identical(receipt$Criterion, request$Criterion) &&
    identical(receipt$FitResultHash, fit$ResultHash) &&
    identical(receipt$SpecificationHash, fit$SpecificationHash) &&
    identical(receipt$SemanticModelHash,
              fit$EstimatorIdentity$SemanticModelHash) &&
    identical(receipt$FitQualification,
              "point_estimation_gate_passed") &&
    identical(receipt$FitStatus, "identified_point_fit") &&
    isTRUE(receipt$Attempted) && isTRUE(receipt$BackendInvoked) &&
    isTRUE(receipt$FitReturned) &&
    isTRUE(receipt$PointEstimationGatePassed) &&
    isTRUE(receipt$WorkerSelfReported) &&
    isTRUE(receipt$FreshProcessSelfReported) &&
    isTRUE(receipt$NonreservedFixture) &&
    isTRUE(receipt$FitCapableWorkerImplemented) &&
    !any(vapply(false_flags, function(name) receipt[[name]], logical(1L))) &&
    identical(receipt$PackageRegistry$Package, expected_packages) &&
    identical(receipt$PackageRegistryHash,
              mfrmr_gtvw_hash(receipt$PackageRegistry)) &&
    identical(receipt$CoordinateEstimateRegistry, coordinate) &&
    identical(receipt$CoordinateEstimateRegistryHash,
              mfrmr_gtvw_hash(coordinate)) &&
    identical(receipt$ReceiptHash,
              mfrmr_gtvw_hash(receipt[receipt_payload])) &&
    is.integer(receipt$ProcessIdentity$ProcessId) &&
    receipt$ProcessIdentity$ProcessId != as.integer(controller_process_id) &&
    identical(receipt$ProcessIdentity$LibraryOrder[[1L]],
              request$OverlayLibrary) &&
    identical(output$OutputHash, mfrmr_gtvw_hash(list(
      Contract = output$Contract, ReceiptHash = receipt$ReceiptHash,
      FitResultHash = fit$ResultHash
    )))
  if (!valid) {
    stop("The Draft.85c4p worker output was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvw_exercise <- function(
    plan, generator_manifest, c4o_manifest, c4l_receipt, repair_receipt,
    worker_environment, validation_dir = file.path("inst", "validation"),
    allow_exact_reuse = TRUE) {
  mfrmr_gtvw_require_primitives()
  validation_dir <- normalizePath(validation_dir, mustWork = TRUE)
  source_registry <- mfrmr_gtvw_source_registry(validation_dir)
  worker_source <- normalizePath(file.path(
    validation_dir, "gtheory-multivariate-fit-candidate-worker-0.2.4.R"
  ), mustWork = TRUE)
  worker_source_hash <- mfrmr_gtvw_file_hash(worker_source)
  worker_identity <- mfrmr_gtvw_worker_identity(worker_environment)
  generation <- mfrmr_gtve_generate_fixture(
    generator_manifest$FixtureRegistry$FixtureId[[1L]],
    plan, generator_manifest$FixtureRegistry
  )
  methods <- plan$MethodRegistry$MethodId
  envelopes <- stats::setNames(lapply(methods, function(method) {
    envelope <- mfrmr_gtvv_candidate_release(
      generation, method, plan, generator_manifest, c4l_receipt
    )
    mfrmr_gtvv_assert_candidate_envelope(
      envelope, generation, method, plan, generator_manifest, c4l_receipt
    )
    envelope
  }), methods)
  root_token <- substr(mfrmr_gtvw_hash(list(
    C4OManifestHash = c4o_manifest$ManifestHash,
    CandidateDataHash = envelopes[[1L]]$CandidateDataHash,
    WorkerSourceSHA256 = worker_source_hash,
    SourceRegistryHash = mfrmr_gtvw_hash(source_registry)
  )), 1L, 16L)
  root <- file.path(
    repair_receipt$RepairRoot, paste0("fit-candidate-c4p-", root_token)
  )
  if (!dir.exists(root) && !dir.create(root)) {
    stop("Draft.85c4p could not create the execution root.", call. = FALSE)
  }
  staged_source <- file.path(root, "source")
  if (!dir.exists(staged_source) && !dir.create(staged_source)) {
    stop("Draft.85c4p could not create the source stage.", call. = FALSE)
  }
  staged_worker <- file.path(staged_source, "fit-candidate-worker.R")
  staged_paths <- file.path(staged_source, source_registry$FileName)
  exact_stage <- all(file.exists(staged_paths)) && file.exists(staged_worker) &&
    identical(mfrmr_gtvw_source_registry(staged_source), source_registry) &&
    identical(mfrmr_gtvw_file_hash(staged_worker), worker_source_hash)
  if (!exact_stage) {
    if (length(list.files(staged_source, all.files = TRUE,
                          no.. = TRUE)) > 0L) {
      stop("The occupied Draft.85c4p source stage is not reusable.",
           call. = FALSE)
    }
    copied <- file.copy(
      file.path(validation_dir, source_registry$FileName), staged_paths
    )
    copied_worker <- file.copy(worker_source, staged_worker)
    if (!all(copied) || !isTRUE(copied_worker) ||
        !identical(mfrmr_gtvw_source_registry(staged_source),
                   source_registry) ||
        !identical(mfrmr_gtvw_file_hash(staged_worker), worker_source_hash)) {
      stop("The Draft.85c4p source staging identity changed.",
           call. = FALSE)
    }
  }
  requests <- outputs <- stats::setNames(vector("list", length(methods)), methods)
  process_rows <- vector("list", length(methods))
  library_order <- paste(
    c(repair_receipt$OverlayLibrary, .libPaths()),
    collapse = .Platform$path.sep
  )
  for (index in seq_along(methods)) {
    method <- methods[[index]]
    request <- mfrmr_gtvw_request(
      envelopes[[method]], c4o_manifest, c4l_receipt, repair_receipt,
      worker_source_hash, source_registry, worker_environment
    )
    request_path <- file.path(root, paste0(method, "-request.rds"))
    output_path <- file.path(root, paste0(method, "-output.rds"))
    use_existing <- isTRUE(allow_exact_reuse) &&
      file.exists(request_path) && file.exists(output_path) &&
      identical(readRDS(request_path), request)
    process_output <- character(); process_status <- 0L
    reused <- FALSE
    if (use_existing) {
      output <- readRDS(output_path)
      reused <- TRUE
    } else {
      if (file.exists(request_path) || file.exists(output_path)) {
        stop("A nonidentical Draft.85c4p route artifact is occupied.",
             call. = FALSE)
      }
      saveRDS(request, request_path, version = 3L)
      process_output <- suppressWarnings(system2(
        repair_receipt$ToolchainIdentity$RscriptExecutable,
        c(
          "--vanilla", staged_worker, request_path, staged_source,
          repair_receipt$OverlayLibrary, output_path
        ), env = paste0("R_LIBS_USER=", library_order),
        stdout = TRUE, stderr = TRUE
      ))
      status <- attr(process_output, "status")
      if (!is.null(status)) process_status <- as.integer(status)
      if (process_status != 0L || !file.exists(output_path)) {
        stop("Draft.85c4p route failed: ", method, ": ",
             paste(process_output, collapse = " | "), call. = FALSE)
      }
      output <- readRDS(output_path)
    }
    mfrmr_gtvw_assert_output(
      output, request, worker_environment, Sys.getpid()
    )
    requests[[method]] <- request
    outputs[[method]] <- output
    process_rows[[index]] <- data.frame(
      RouteOrdinal = as.integer(index), MethodId = method,
      ProcessId = output$Receipt$ProcessIdentity$ProcessId,
      ProcessIdentityHash = output$Receipt$ProcessIdentityHash,
      ExitStatus = as.integer(process_status),
      OutputLineCount = as.integer(length(process_output)),
      ExactArtifactReused = reused,
      stringsAsFactors = FALSE
    )
  }
  if (anyDuplicated(vapply(
    outputs, function(output) output$Receipt$ProcessIdentity$ProcessId,
    integer(1L)
  ))) {
    stop("Draft.85c4p requires one distinct process per route.", call. = FALSE)
  }
  parity <- list(
    matched_reml = mfrmr_gtvb_compare(
      outputs$lme4_reml$Fit, outputs$glmmtmb_reml$Fit,
      absolute_tolerance = 1e-4, relative_tolerance = 1e-4,
      fixed_tolerance = 1e-4, loglik_tolerance = 1e-5
    ),
    matched_ml = mfrmr_gtvb_compare(
      outputs$lme4_ml$Fit, outputs$glmmtmb_ml$Fit,
      absolute_tolerance = 1e-4, relative_tolerance = 1e-4,
      fixed_tolerance = 1e-4, loglik_tolerance = 1e-5
    )
  )
  route_rows <- lapply(seq_along(methods), function(index) {
    receipt <- outputs[[methods[[index]]]]$Receipt
    data.frame(
      RouteOrdinal = as.integer(index), MethodId = receipt$MethodId,
      QualificationRouteId = receipt$QualificationRouteId,
      Backend = receipt$Backend, Criterion = receipt$Criterion,
      RequestHash = receipt$RequestHash,
      EnvelopeHash = receipt$EnvelopeHash,
      QualifiedRouteReceiptHash = receipt$QualifiedRouteReceiptHash,
      QualifiedFitSpecificationHash =
        receipt$QualifiedFitSpecificationHash,
      QualifiedSemanticModelHash = receipt$QualifiedSemanticModelHash,
      SpecificationHash = receipt$SpecificationHash,
      SemanticModelHash = receipt$SemanticModelHash,
      FitResultHash = receipt$FitResultHash,
      ReceiptHash = receipt$ReceiptHash,
      FitQualification = receipt$FitQualification,
      FitStatus = receipt$FitStatus,
      LogLikelihood = receipt$LogLikelihood,
      CoordinateEstimateRegistryHash =
        receipt$CoordinateEstimateRegistryHash,
      Attempted = receipt$Attempted,
      BackendInvoked = receipt$BackendInvoked,
      FitReturned = receipt$FitReturned,
      PointEstimationGatePassed = receipt$PointEstimationGatePassed,
      stringsAsFactors = FALSE
    )
  })
  coordinate_rows <- lapply(methods, function(method) {
    output <- outputs[[method]]
    cbind(
      data.frame(MethodId = method, stringsAsFactors = FALSE),
      output$Receipt$CoordinateEstimateRegistry
    )
  })
  parity_rows <- lapply(names(parity), function(pair_id) {
    comparison <- parity[[pair_id]]
    data.frame(
      PairId = pair_id, Criterion = comparison$Method,
      SpecificationHash = comparison$SpecificationHash,
      SemanticModelHash = comparison$SemanticModelHash,
      ComparisonResultHash = comparison$ResultHash,
      MaximumCovarianceAbsoluteDifference = max(
        comparison$CovarianceComparison$AbsoluteDifference
      ),
      MaximumFixedAbsoluteDifference = max(
        comparison$FixedEffectComparison$AbsoluteDifference
      ),
      LogLikAbsoluteDifference =
        comparison$LikelihoodComparison$AbsoluteDifference,
      NumericalParityPassed = comparison$NumericalParityPassed,
      BothPointEstimationGatesPassed =
        comparison$BothPointEstimationGatesPassed,
      MatchedBackendPointReady = comparison$MatchedBackendPointReady,
      stringsAsFactors = FALSE
    )
  })
  list(
    RouteRegistry = do.call(rbind, route_rows),
    CoordinateEstimateRegistry = do.call(rbind, coordinate_rows),
    BackendParityRegistry = do.call(rbind, parity_rows),
    ProcessRegistry = do.call(rbind, process_rows),
    SourceRegistry = source_registry, WorkerIdentity = worker_identity,
    WorkerSourceSHA256 = worker_source_hash,
    ExecutionRoot = normalizePath(root, mustWork = TRUE),
    CandidateDataSchemaHash = envelopes[[1L]]$CandidateSchemaHash,
    CandidateDataHash = envelopes[[1L]]$CandidateDataHash,
    CandidateRows = envelopes[[1L]]$ExpectedRows
  )
}

mfrmr_gtvw_prerequisite_projection <- function(c4o_manifest) {
  prior <- c4o_manifest$PrerequisiteProjection
  truth <- match("truth_blind_process_boundary", prior$PrerequisiteId)
  if (is.na(truth) || !identical(sum(prior$C4OProjectedSatisfied), 2L) ||
      isTRUE(prior$C4OProjectedSatisfied[[truth]])) {
    stop("The Draft.85c4o prerequisite state changed.", call. = FALSE)
  }
  state <- prior$EvidenceState
  state[[truth]] <- paste0(
    "nonreserved_fit_worker_executed_",
    "fit_process_capability_isolation_missing"
  )
  data.frame(
    PrerequisiteOrdinal = prior$PrerequisiteOrdinal,
    PrerequisiteId = prior$PrerequisiteId,
    Requirement = prior$Requirement,
    C4OProjectedSatisfied = prior$C4OProjectedSatisfied,
    C4PProjectedSatisfied = prior$C4OProjectedSatisfied,
    TransitionedByC4P = rep(FALSE, nrow(prior)),
    PartialExecutionAllowed = prior$PartialExecutionAllowed,
    EvidenceState = state,
    FitCapableWorkerEvidenceAvailable = seq_len(nrow(prior)) == truth,
    FitCapableProcessIsolationEvidenceAvailable = rep(FALSE, nrow(prior)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvw_payload_fields <- function() {
  c(
    "Contract", "PlanHash", "GeneratorManifestHash", "C4OManifestHash",
    "C4LReceiptHash", "C4IRepairReceiptHash", "SourceRegistry",
    "SourceRegistryHash", "WorkerSourceSHA256", "WorkerIdentity",
    "WorkerIdentityHash", "RouteExecutionRegistry",
    "RouteExecutionRegistryHash", "CoordinateEstimateRegistry",
    "CoordinateEstimateRegistryHash", "BackendParityRegistry",
    "BackendParityRegistryHash", "ProcessRegistry", "ProcessRegistryHash",
    "CandidateDataSchemaHash", "CandidateDataHash", "CandidateRows",
    "ExecutionRoot", "PrerequisiteProjection",
    "PrerequisiteProjectionHash", "ImplementationIdentity",
    "ImplementationIdentityHash", "EvidenceUse",
    "PlannedCandidateDataIncluded", "PlannedReplicateIdentityIncluded",
    "ScenarioIdentityIncluded", "ReferenceIdentityIncluded",
    "ReferenceTruthIncluded", "AccuracyThresholdIncluded",
    "ConQuestRouteIncluded"
  )
}

mfrmr_gtvw_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtvw_require_primitives", "mfrmr_gtvw_hash",
    "mfrmr_gtvw_file_hash", "mfrmr_gtvw_exact_object",
    "mfrmr_gtvw_source_registry", "mfrmr_gtvw_worker_identity",
    "mfrmr_gtvw_request", "mfrmr_gtvw_assert_output",
    "mfrmr_gtvw_exercise", "mfrmr_gtvw_prerequisite_projection",
    "mfrmr_gtvw_payload_fields", "mfrmr_gtvw_implementation_identity",
    "mfrmr_gtvw_manifest", "mfrmr_gtvw_assert_manifest",
    "mfrmr_gtvw_dispatch_guard"
  )
  target <- environment(mfrmr_gtvw_implementation_identity)
  data.frame(
    Function = functions,
    SHA256 = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtvw_hash(list(
        Formals = paste(deparse(formals(fun), width.cutoff = 500L),
                        collapse = "\n"),
        Body = paste(deparse(body(fun), width.cutoff = 500L), collapse = "\n")
      ))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvw_manifest <- function(
    plan, generator_manifest, c4o_manifest, c4l_receipt, repair_receipt,
    worker_environment, validation_dir = file.path("inst", "validation"),
    allow_exact_reuse = TRUE) {
  mfrmr_gtvw_require_primitives()
  mfrmr_gtvd_assert_plan(plan)
  mfrmr_gtve_assert_manifest(
    generator_manifest, plan, generator_manifest$FixtureRegistry
  )
  c4o_payload <- c4o_manifest[mfrmr_gtvv_payload_fields()]
  if (!identical(c4o_manifest$ManifestHash, mfrmr_gtvw_hash(c4o_payload)) ||
      !identical(c4o_manifest$C4LReceiptHash, c4l_receipt$ReceiptHash) ||
      !identical(c4o_manifest$PlanHash, plan$PlanHash) ||
      !identical(c4o_manifest$GeneratorManifestHash,
                 generator_manifest$ManifestHash) ||
      !isTRUE(c4o_manifest$CandidateDataObservationLinkSchemaReady) ||
      !isTRUE(c4o_manifest$ObservationLinkPairIdentityReady) ||
      !isTRUE(c4o_manifest$BackendQualificationReady) ||
      isTRUE(c4o_manifest$FitCapableWorkerImplemented) ||
      !identical(c4l_receipt$C4IRepairReceiptHash,
                 repair_receipt$ReceiptHash)) {
    stop("The Draft.85c4p parent chain is not canonical.", call. = FALSE)
  }
  exercise <- mfrmr_gtvw_exercise(
    plan, generator_manifest, c4o_manifest, c4l_receipt, repair_receipt,
    worker_environment, validation_dir, allow_exact_reuse
  )
  prerequisites <- mfrmr_gtvw_prerequisite_projection(c4o_manifest)
  implementation <- mfrmr_gtvw_implementation_identity()
  if (!identical(nrow(exercise$RouteRegistry), 4L) ||
      !all(exercise$RouteRegistry$PointEstimationGatePassed) ||
      !all(exercise$BackendParityRegistry$MatchedBackendPointReady) ||
      any(exercise$ProcessRegistry$ExitStatus != 0L) ||
      !identical(nrow(exercise$CoordinateEstimateRegistry), 40L)) {
    stop("The Draft.85c4p nonreserved fit exercise is incomplete.",
         call. = FALSE)
  }
  payload <- list(
    Contract = "gtheory_multivariate_fit_candidate_execution_draft85c4p_v1",
    PlanHash = plan$PlanHash,
    GeneratorManifestHash = generator_manifest$ManifestHash,
    C4OManifestHash = c4o_manifest$ManifestHash,
    C4LReceiptHash = c4l_receipt$ReceiptHash,
    C4IRepairReceiptHash = repair_receipt$ReceiptHash,
    SourceRegistry = exercise$SourceRegistry,
    SourceRegistryHash = mfrmr_gtvw_hash(exercise$SourceRegistry),
    WorkerSourceSHA256 = exercise$WorkerSourceSHA256,
    WorkerIdentity = exercise$WorkerIdentity,
    WorkerIdentityHash = mfrmr_gtvw_hash(exercise$WorkerIdentity),
    RouteExecutionRegistry = exercise$RouteRegistry,
    RouteExecutionRegistryHash = mfrmr_gtvw_hash(exercise$RouteRegistry),
    CoordinateEstimateRegistry = exercise$CoordinateEstimateRegistry,
    CoordinateEstimateRegistryHash = mfrmr_gtvw_hash(
      exercise$CoordinateEstimateRegistry
    ),
    BackendParityRegistry = exercise$BackendParityRegistry,
    BackendParityRegistryHash = mfrmr_gtvw_hash(
      exercise$BackendParityRegistry
    ),
    ProcessRegistry = exercise$ProcessRegistry,
    ProcessRegistryHash = mfrmr_gtvw_hash(exercise$ProcessRegistry),
    CandidateDataSchemaHash = exercise$CandidateDataSchemaHash,
    CandidateDataHash = exercise$CandidateDataHash,
    CandidateRows = exercise$CandidateRows,
    ExecutionRoot = exercise$ExecutionRoot,
    PrerequisiteProjection = prerequisites,
    PrerequisiteProjectionHash = mfrmr_gtvw_hash(prerequisites),
    ImplementationIdentity = implementation,
    ImplementationIdentityHash = mfrmr_gtvw_hash(implementation),
    EvidenceUse = "nonreserved_fixture_fit_only",
    PlannedCandidateDataIncluded = FALSE,
    PlannedReplicateIdentityIncluded = FALSE,
    ScenarioIdentityIncluded = FALSE,
    ReferenceIdentityIncluded = FALSE,
    ReferenceTruthIncluded = FALSE,
    AccuracyThresholdIncluded = FALSE,
    ConQuestRouteIncluded = FALSE
  )
  structure(c(payload, list(
    ManifestHash = mfrmr_gtvw_hash(payload),
    FitCapableWorkerImplemented = TRUE,
    WorkerNamespaceSeparationReady = TRUE,
    ExactSourceStagingReady = TRUE,
    FourDistinctFreshProcessesObserved = TRUE,
    FourRouteFitExerciseReady = TRUE,
    ObservationLinkFitContractReady = TRUE,
    AllFourRoutesInvoked = TRUE,
    AllFourFitsReturned = TRUE,
    AllFourPointEstimationGatesPassed = TRUE,
    BothBackendParityPairsPassed = TRUE,
    NonreservedFixtureFitReady = TRUE,
    NonreservedCandidateArtifactsRetained = TRUE,
    FitCapableProcessCapabilityIsolationReady = FALSE,
    TruthBlindProcessBoundaryReady = FALSE,
    ExactlyZeroC3PrerequisitesTransitioned =
      !any(prerequisites$TransitionedByC4P),
    C3SatisfiedPrerequisiteCount = as.integer(sum(
      prerequisites$C4PProjectedSatisfied
    )),
    AllExecutionPrerequisitesReady = FALSE,
    ExternalFreezeReady = FALSE,
    CleanSourceIdentityReady = FALSE,
    IndependentAccuracyRuleReady = FALSE,
    PilotExecutionAuthorized = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    NegativeControlExecutionAuthorized = FALSE,
    PlannedExecutionOccurred = FALSE,
    CandidateCompletionSealed = FALSE,
    TruthReleaseAuthorized = FALSE,
    DenominatorAccountingReady = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE,
    ExecutionGateClosed = TRUE
  )), class = c("mfrmr_gtvw_manifest", "list"))
}

mfrmr_gtvw_assert_manifest <- function(manifest) {
  payload_fields <- mfrmr_gtvw_payload_fields()
  expected_suffix <- c(
    "ManifestHash", "FitCapableWorkerImplemented",
    "WorkerNamespaceSeparationReady", "ExactSourceStagingReady",
    "FourDistinctFreshProcessesObserved", "FourRouteFitExerciseReady",
    "ObservationLinkFitContractReady", "AllFourRoutesInvoked",
    "AllFourFitsReturned", "AllFourPointEstimationGatesPassed",
    "BothBackendParityPairsPassed", "NonreservedFixtureFitReady",
    "NonreservedCandidateArtifactsRetained",
    "FitCapableProcessCapabilityIsolationReady",
    "TruthBlindProcessBoundaryReady",
    "ExactlyZeroC3PrerequisitesTransitioned",
    "C3SatisfiedPrerequisiteCount", "AllExecutionPrerequisitesReady",
    "ExternalFreezeReady", "CleanSourceIdentityReady",
    "IndependentAccuracyRuleReady", "PilotExecutionAuthorized",
    "ConfirmationExecutionAuthorized", "NegativeControlExecutionAuthorized",
    "PlannedExecutionOccurred", "CandidateCompletionSealed",
    "TruthReleaseAuthorized", "DenominatorAccountingReady",
    "RecoveryExecuted", "RecoveryEvidenceReady", "EstimationReady",
    "InferenceReady", "DecisionReady", "PublicSupportReady",
    "ExecutionGateClosed"
  )
  if (!mfrmr_gtvw_exact_object(
    manifest, c(payload_fields, expected_suffix),
    c("mfrmr_gtvw_manifest", "list")
  )) {
    stop("A typed Draft.85c4p manifest is required.", call. = FALSE)
  }
  true_flags <- c(
    "FitCapableWorkerImplemented", "WorkerNamespaceSeparationReady",
    "ExactSourceStagingReady", "FourDistinctFreshProcessesObserved",
    "FourRouteFitExerciseReady", "ObservationLinkFitContractReady",
    "AllFourRoutesInvoked", "AllFourFitsReturned",
    "AllFourPointEstimationGatesPassed", "BothBackendParityPairsPassed",
    "NonreservedFixtureFitReady", "NonreservedCandidateArtifactsRetained",
    "ExactlyZeroC3PrerequisitesTransitioned", "ExecutionGateClosed"
  )
  false_flags <- setdiff(
    expected_suffix[-1L], c(true_flags, "C3SatisfiedPrerequisiteCount")
  )
  valid <- identical(
    manifest$Contract,
    "gtheory_multivariate_fit_candidate_execution_draft85c4p_v1"
  ) && identical(manifest$ManifestHash,
                 mfrmr_gtvw_hash(manifest[payload_fields])) &&
    identical(manifest$RouteExecutionRegistryHash,
              mfrmr_gtvw_hash(manifest$RouteExecutionRegistry)) &&
    identical(manifest$CoordinateEstimateRegistryHash,
              mfrmr_gtvw_hash(manifest$CoordinateEstimateRegistry)) &&
    identical(manifest$BackendParityRegistryHash,
              mfrmr_gtvw_hash(manifest$BackendParityRegistry)) &&
    identical(manifest$ProcessRegistryHash,
              mfrmr_gtvw_hash(manifest$ProcessRegistry)) &&
    identical(manifest$PrerequisiteProjectionHash,
              mfrmr_gtvw_hash(manifest$PrerequisiteProjection)) &&
    identical(manifest$ImplementationIdentity,
              mfrmr_gtvw_implementation_identity()) &&
    identical(manifest$ImplementationIdentityHash,
              mfrmr_gtvw_hash(manifest$ImplementationIdentity)) &&
    all(vapply(true_flags, function(name) manifest[[name]], logical(1L))) &&
    !any(vapply(false_flags, function(name) manifest[[name]], logical(1L))) &&
    identical(manifest$C3SatisfiedPrerequisiteCount, 2L) &&
    identical(nrow(manifest$RouteExecutionRegistry), 4L) &&
    identical(nrow(manifest$CoordinateEstimateRegistry), 40L) &&
    identical(nrow(manifest$BackendParityRegistry), 2L) &&
    identical(nrow(manifest$ProcessRegistry), 4L) &&
    !anyDuplicated(manifest$ProcessRegistry$ProcessId) &&
    all(manifest$RouteExecutionRegistry$Attempted) &&
    all(manifest$RouteExecutionRegistry$BackendInvoked) &&
    all(manifest$RouteExecutionRegistry$FitReturned) &&
    all(manifest$RouteExecutionRegistry$PointEstimationGatePassed) &&
    all(manifest$RouteExecutionRegistry$FitQualification ==
          "point_estimation_gate_passed") &&
    all(manifest$RouteExecutionRegistry$FitStatus ==
          "identified_point_fit") &&
    all(table(manifest$CoordinateEstimateRegistry$MethodId) == 10L) &&
    all(is.finite(manifest$CoordinateEstimateRegistry$Estimate)) &&
    all(manifest$ProcessRegistry$ExitStatus == 0L) &&
    all(manifest$BackendParityRegistry$NumericalParityPassed) &&
    all(manifest$BackendParityRegistry$BothPointEstimationGatesPassed) &&
    all(manifest$BackendParityRegistry$MatchedBackendPointReady)
  if (!valid) {
    stop("The Draft.85c4p manifest or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvw_dispatch_guard <- function(
    manifest, action, callback, ..., authorize = FALSE) {
  allowed <- c(
    "capability_isolation", "pilot", "confirmation", "negative_control",
    "planned_response", "recovery", "public_promotion"
  )
  if (!is.character(action) || length(action) != 1L || is.na(action) ||
      !action %in% allowed) {
    stop("The Draft.85c4p action is outside the contract.", call. = FALSE)
  }
  if (!is.function(callback)) stop("`callback` must be a function.", call. = FALSE)
  if (!is.logical(authorize) || length(authorize) != 1L || is.na(authorize)) {
    stop("`authorize` must be TRUE or FALSE.", call. = FALSE)
  }
  mfrmr_gtvw_assert_manifest(manifest)
  stop("Draft.85c4p proves nonreserved fit execution only; capability ",
       "isolation and every planned or public action remain closed.",
       call. = FALSE)
}
