# Draft.85c4j multivariate G-theory full-object qualification worker.
#
# Repository-internal only. This standalone worker runs the four frozen
# Draft.85b1 backend routes in a fresh R process using the Draft.85c4i repair
# overlay. It returns complete fit and parity objects. It does not claim
# process-capability isolation, operational trust, or public support.

mfrmr_gtvqw_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4j qualification worker requires `digest`.",
         call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvqw_file_hash <- function(path) {
  path <- normalizePath(path, mustWork = TRUE)
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtvqw_exact_object <- function(object, expected_names,
                                     expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    identical(sort(names(attributes(object))), c("class", "names"))
}

mfrmr_gtvqw_component_map <- function() {
  data.frame(
    ComponentId = c("Residual", "Object:Rater", "Rater", "Object"),
    UniverseRole = c(
      "relative_error", "relative_error", "absolute_only", "object"
    ),
    Members = c("", "Object:Rater", "Rater", "Object"),
    CovarianceStructure = c(
      "homoskedastic_independent", rep("unstructured", 3L)
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvqw_mvnorm <- function(n, covariance) {
  matrix(stats::rnorm(n * nrow(covariance)), n, nrow(covariance)) %*%
    chol(covariance)
}

mfrmr_gtvqw_fixture <- function(seed) {
  set.seed(seed)
  objects <- paste0("P", seq_len(24L))
  raters <- paste0("R", seq_len(5L))
  items <- paste0("I", seq_len(2L))
  strata <- c("A", "B")
  data <- expand.grid(
    Object = objects, Rater = raters, Item = items, Stratum = strata,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  object_effect <- mfrmr_gtvqw_mvnorm(
    length(objects), matrix(c(1.0, 0.35, 0.35, 0.8), 2L)
  )
  rater_effect <- mfrmr_gtvqw_mvnorm(
    length(raters), matrix(c(0.25, 0.08, 0.08, 0.20), 2L)
  )
  object_rater_effect <- mfrmr_gtvqw_mvnorm(
    length(objects) * length(raters),
    matrix(c(0.30, 0.06, 0.06, 0.25), 2L)
  )
  object_index <- match(data$Object, objects)
  rater_index <- match(data$Rater, raters)
  stratum_index <- match(data$Stratum, strata)
  object_rater_index <- (object_index - 1L) * length(raters) + rater_index
  data$Score <- c(A = 0, B = 0.4)[data$Stratum] +
    object_effect[cbind(object_index, stratum_index)] +
    rater_effect[cbind(rater_index, stratum_index)] +
    object_rater_effect[cbind(object_rater_index, stratum_index)] +
    stats::rnorm(nrow(data), sd = 0.5)
  data
}

mfrmr_gtvqw_source_registry <- function(source_dir) {
  source_dir <- normalizePath(source_dir, mustWork = TRUE)
  files <- c(
    "gtheory-design-algebra-prototype-0.2.3.R",
    "gtheory-multivariate-algebra-prototype-0.2.3.R",
    "gtheory-multivariate-incidence-preflight-0.2.4.R",
    "gtheory-multivariate-matched-backend-prototype-0.2.4.R",
    "gtheory-multivariate-four-route-qualification-protocol-0.2.4.R"
  )
  paths <- file.path(source_dir, files)
  if (!all(file.exists(paths))) {
    stop("The Draft.85c4j staged source set is incomplete.", call. = FALSE)
  }
  data.frame(
    SourceOrdinal = seq_along(files), FileName = files,
    SHA256 = unname(vapply(
      paths, mfrmr_gtvqw_file_hash, character(1L)
    )),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvqw_package_registry <- function(overlay) {
  overlay <- normalizePath(overlay, mustWork = TRUE)
  packages <- c("lme4", "glmmTMB", "TMB", "Matrix", "RcppEigen")
  available <- vapply(packages, requireNamespace, logical(1L), quietly = TRUE)
  if (!all(available)) {
    stop("The Draft.85c4j qualification packages are incomplete: ",
         paste(packages[!available], collapse = ", "), ".", call. = FALSE)
  }
  native_paths <- vapply(packages, function(package) {
    normalizePath(system.file(
      "libs", paste0(package, .Platform$dynlib.ext), package = package
    ), mustWork = TRUE)
  }, character(1L))
  registry <- data.frame(
    PackageOrdinal = seq_along(packages),
    Package = packages,
    Version = vapply(packages, function(package) {
      as.character(utils::packageVersion(package))
    }, character(1L)),
    PackagePath = vapply(packages, function(package) {
      normalizePath(find.package(package), mustWork = TRUE)
    }, character(1L)),
    DescriptionSHA256 = vapply(packages, function(package) {
      mfrmr_gtvqw_file_hash(system.file("DESCRIPTION", package = package))
    }, character(1L)),
    NativeDLLAvailable = rep(TRUE, length(packages)),
    NativeDLLPath = native_paths,
    NativeDLLSHA256 = vapply(native_paths, mfrmr_gtvqw_file_hash,
                            character(1L)),
    stringsAsFactors = FALSE
  )
  row.names(registry) <- NULL
  registry
}

mfrmr_gtvqw_loaded_runtime_registry <- function() {
  packages <- sort(loadedNamespaces(), method = "radix")
  namespace_rows <- lapply(seq_along(packages), function(index) {
    package <- packages[[index]]
    path <- normalizePath(find.package(package), mustWork = TRUE)
    description <- file.path(path, "DESCRIPTION")
    if (!file.exists(description)) {
      stop("A loaded namespace has no DESCRIPTION: ", package, ".",
           call. = FALSE)
    }
    data.frame(
      NamespaceOrdinal = as.integer(index),
      Package = package,
      Version = as.character(utils::packageVersion(package)),
      PackagePath = path,
      DescriptionSHA256 = mfrmr_gtvqw_file_hash(description),
      stringsAsFactors = FALSE
    )
  })
  namespaces <- do.call(rbind, namespace_rows)
  row.names(namespaces) <- NULL
  loaded_dlls <- getLoadedDLLs()
  native_paths <- sort(unique(vapply(loaded_dlls, function(dll) {
    path <- dll[["path"]]
    if (is.null(path) || !nzchar(path) || !file.exists(path)) NA_character_
    else normalizePath(path, mustWork = TRUE)
  }, character(1L))), method = "radix", na.last = NA)
  native_rows <- lapply(native_paths, function(path) {
    owners <- which(vapply(namespaces$PackagePath, function(package_path) {
      startsWith(path, paste0(package_path, .Platform$file.sep))
    }, logical(1L)))
    owner <- if (length(owners) == 1L) namespaces$Package[[owners]] else {
      "R_runtime_or_external"
    }
    data.frame(
      Package = owner,
      NativeBinaryPath = path,
      NativeBinarySHA256 = mfrmr_gtvqw_file_hash(path),
      stringsAsFactors = FALSE
    )
  })
  native <- if (length(native_rows) == 0L) {
    data.frame(
      Package = character(), NativeBinaryPath = character(),
      NativeBinarySHA256 = character(), stringsAsFactors = FALSE
    )
  } else do.call(rbind, native_rows)
  row.names(native) <- NULL
  list(NamespaceRegistry = namespaces, NativeBinaryRegistry = native)
}

mfrmr_gtvqw_process_identity <- function() {
  r_executable <- normalizePath(file.path(R.home("bin"), "R"),
                                mustWork = TRUE)
  rscript_executable <- normalizePath(file.path(R.home("bin"), "Rscript"),
                                      mustWork = TRUE)
  payload <- list(
    ProcessId = as.integer(Sys.getpid()),
    RVersion = as.character(getRversion()),
    RPlatform = R.version$platform,
    RExecutable = r_executable,
    RExecutableSHA256 = mfrmr_gtvqw_file_hash(r_executable),
    RscriptExecutable = rscript_executable,
    RscriptExecutableSHA256 = mfrmr_gtvqw_file_hash(rscript_executable),
    LibraryOrder = normalizePath(.libPaths(), mustWork = TRUE)
  )
  c(payload, list(ProcessIdentityHash = mfrmr_gtvqw_hash(payload)))
}

mfrmr_gtvqw_assert_request <- function(request, source_dir, overlay) {
  payload_fields <- c(
    "Contract", "C4IRepairReceiptHash", "C4FManifestHash", "C4FPolicyHash",
    "WorkerSourceSHA256", "SourceRegistry", "SourceRegistryHash",
    "RepairRoot", "OverlayLibrary", "QualificationSeed",
    "CovarianceAbsoluteTolerance", "CovarianceRelativeTolerance",
    "FixedAbsoluteTolerance", "LogLikAbsoluteTolerance"
  )
  if (!mfrmr_gtvqw_exact_object(
    request, c(payload_fields, "RequestHash"),
    c("mfrmr_gtvqw_request", "list")
  )) {
    stop("A typed Draft.85c4j qualification request is required.",
         call. = FALSE)
  }
  source_registry <- mfrmr_gtvqw_source_registry(source_dir)
  valid <- identical(
    request$Contract,
    "gtheory_multivariate_full_object_qualification_request_draft85c4j_v1"
  ) && all(vapply(request[c(
    "C4IRepairReceiptHash", "C4FManifestHash", "C4FPolicyHash",
    "WorkerSourceSHA256", "SourceRegistryHash", "RequestHash"
  )], function(value) {
    is.character(value) && length(value) == 1L && !is.na(value) &&
      grepl("^[0-9a-f]{64}$", value)
  }, logical(1L))) &&
    identical(request$SourceRegistry, source_registry) &&
    identical(request$SourceRegistryHash, mfrmr_gtvqw_hash(source_registry)) &&
    identical(normalizePath(request$OverlayLibrary, mustWork = TRUE),
              normalizePath(overlay, mustWork = TRUE)) &&
    identical(normalizePath(request$RepairRoot, mustWork = TRUE),
              normalizePath(dirname(overlay), mustWork = TRUE)) &&
    is.integer(request$QualificationSeed) &&
    identical(request$QualificationSeed, 85021L) &&
    identical(c(
      request$CovarianceAbsoluteTolerance,
      request$CovarianceRelativeTolerance,
      request$FixedAbsoluteTolerance,
      request$LogLikAbsoluteTolerance
    ), c(1e-4, 1e-4, 1e-4, 1e-5)) &&
    identical(request$RequestHash, mfrmr_gtvqw_hash(request[payload_fields]))
  if (!valid) {
    stop("The Draft.85c4j qualification request was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvqw_route_registry <- function(fits, policy) {
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
      FullFitObjectHash = mfrmr_gtvqw_hash(fit),
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

mfrmr_gtvqw_pair_registry <- function(parities, route_registry, policy) {
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
      FullParityObjectHash = mfrmr_gtvqw_hash(parity),
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

mfrmr_gtvqw_implementation_identity <- function() {
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
  target <- environment(mfrmr_gtvqw_implementation_identity)
  data.frame(
    Function = function_names,
    SHA256 = vapply(function_names, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtvqw_hash(list(
        Formals = paste(deparse(formals(fun), width.cutoff = 500L),
                        collapse = "\n"),
        Body = paste(deparse(body(fun), width.cutoff = 500L),
                     collapse = "\n")
      ))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvqw_main <- function(arguments = commandArgs(trailingOnly = TRUE)) {
  if (length(arguments) != 4L) {
    stop("Draft.85c4j worker requires request, source, overlay, and output paths.",
         call. = FALSE)
  }
  request_path <- normalizePath(arguments[[1L]], mustWork = TRUE)
  source_dir <- normalizePath(arguments[[2L]], mustWork = TRUE)
  overlay <- normalizePath(arguments[[3L]], mustWork = TRUE)
  output_path <- arguments[[4L]]
  if (!identical(normalizePath(.libPaths()[[1L]], mustWork = TRUE), overlay)) {
    stop("The Draft.85c4j repair overlay is not first in library order.",
         call. = FALSE)
  }
  request <- readRDS(request_path)
  mfrmr_gtvqw_assert_request(request, source_dir, overlay)
  file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE),
                        value = TRUE)
  if (length(file_argument) != 1L) {
    stop("The Draft.85c4j worker file identity is unavailable.",
         call. = FALSE)
  }
  worker_source <- normalizePath(
    sub("^--file=", "", file_argument), mustWork = TRUE
  )
  if (!identical(mfrmr_gtvqw_file_hash(worker_source),
                 request$WorkerSourceSHA256)) {
    stop("The Draft.85c4j worker source identity changed.", call. = FALSE)
  }
  runtime <- new.env(parent = globalenv())
  for (file in request$SourceRegistry$FileName) {
    sys.source(file.path(source_dir, file), envir = runtime)
  }
  policy <- runtime$mfrmr_gtvm_qualification_policy()
  runtime$mfrmr_gtvm_assert_policy(policy)
  if (!identical(policy$PolicyHash, request$C4FPolicyHash)) {
    stop("The frozen Draft.85c4f policy identity changed.", call. = FALSE)
  }
  package_registry <- mfrmr_gtvqw_package_registry(overlay)
  data <- mfrmr_gtvqw_fixture(request$QualificationSeed)
  incidence <- runtime$mfrmr_gtvi_audit(
    data, object_col = "Object", stratum_col = "Stratum",
    score_col = "Score", condition_cols = c("Rater", "Item"),
    condition_scope = c(Rater = "global", Item = "global"),
    strata = c("A", "B"), missingness = "complete"
  )
  spec <- runtime$mfrmr_gtvb_spec(
    data, incidence, mfrmr_gtvqw_component_map(), c("Rater", "Item"),
    max_covariance_design_cells = 2e6
  )
  worker_warnings <- character()
  worker_messages <- character()
  fits <- withCallingHandlers(list(
    lme4_ml = runtime$mfrmr_gtvb_fit_lme4(spec, reml = FALSE),
    lme4_reml = runtime$mfrmr_gtvb_fit_lme4(spec, reml = TRUE),
    glmmTMB_ml = runtime$mfrmr_gtvb_fit_glmmtmb(spec, reml = FALSE),
    glmmTMB_reml = runtime$mfrmr_gtvb_fit_glmmtmb(spec, reml = TRUE)
  ), warning = function(warning) {
    worker_warnings <<- c(worker_warnings, conditionMessage(warning))
    invokeRestart("muffleWarning")
  }, message = function(message) {
    worker_messages <<- c(worker_messages, conditionMessage(message))
    invokeRestart("muffleMessage")
  })
  for (fit in fits) runtime$mfrmr_gtvb_assert_fit_integrity(fit)
  parities <- list(
    matched_ml = runtime$mfrmr_gtvb_compare(
      fits$lme4_ml, fits$glmmTMB_ml,
      absolute_tolerance = request$CovarianceAbsoluteTolerance,
      relative_tolerance = request$CovarianceRelativeTolerance,
      fixed_tolerance = request$FixedAbsoluteTolerance,
      loglik_tolerance = request$LogLikAbsoluteTolerance
    ),
    matched_reml = runtime$mfrmr_gtvb_compare(
      fits$lme4_reml, fits$glmmTMB_reml,
      absolute_tolerance = request$CovarianceAbsoluteTolerance,
      relative_tolerance = request$CovarianceRelativeTolerance,
      fixed_tolerance = request$FixedAbsoluteTolerance,
      loglik_tolerance = request$LogLikAbsoluteTolerance
    )
  )
  route_registry <- mfrmr_gtvqw_route_registry(fits, policy)
  pair_registry <- mfrmr_gtvqw_pair_registry(parities, route_registry, policy)
  loaded_runtime <- mfrmr_gtvqw_loaded_runtime_registry()
  process_identity <- mfrmr_gtvqw_process_identity()
  implementation <- mfrmr_gtvqw_implementation_identity()
  payload <- list(
    Contract =
      "gtheory_multivariate_full_object_worker_receipt_draft85c4j_v1",
    RequestHash = request$RequestHash,
    C4IRepairReceiptHash = request$C4IRepairReceiptHash,
    C4FManifestHash = request$C4FManifestHash,
    C4FPolicyHash = request$C4FPolicyHash,
    WorkerSourceSHA256 = request$WorkerSourceSHA256,
    WorkerImplementationIdentity = implementation,
    WorkerImplementationIdentityHash = mfrmr_gtvqw_hash(implementation),
    SourceRegistry = request$SourceRegistry,
    SourceRegistryHash = request$SourceRegistryHash,
    ProcessIdentity = process_identity,
    ProcessIdentityHash = process_identity$ProcessIdentityHash,
    PackageRegistry = package_registry,
    PackageRegistryHash = mfrmr_gtvqw_hash(package_registry),
    LoadedNamespaceRegistry = loaded_runtime$NamespaceRegistry,
    LoadedNamespaceRegistryHash =
      mfrmr_gtvqw_hash(loaded_runtime$NamespaceRegistry),
    LoadedNativeBinaryRegistry = loaded_runtime$NativeBinaryRegistry,
    LoadedNativeBinaryRegistryHash =
      mfrmr_gtvqw_hash(loaded_runtime$NativeBinaryRegistry),
    QualificationSeed = request$QualificationSeed,
    FixtureDataHash = runtime$mfrmr_gta_hash(data),
    IncidenceAuditHash = incidence$AuditHash,
    SpecificationHash = spec$SpecificationHash,
    RouteObjectRegistry = route_registry,
    RouteObjectRegistryHash = mfrmr_gtvqw_hash(route_registry),
    PairObjectRegistry = pair_registry,
    PairObjectRegistryHash = mfrmr_gtvqw_hash(pair_registry),
    FullFitObjects = fits,
    FullFitObjectsHash = mfrmr_gtvqw_hash(fits),
    FullParityObjects = parities,
    FullParityObjectsHash = mfrmr_gtvqw_hash(parities),
    WorkerWarnings = worker_warnings,
    WorkerMessages = worker_messages
  )
  route_ready <- nrow(route_registry) == 4L &&
    all(route_registry$FitIntegrityPassed) &&
    all(route_registry$PointEstimationGatePassed) &&
    all(route_registry$BackendRowsMatch) &&
    all(route_registry$DependencyABIMatch) &&
    !any(route_registry$DiagnosticOverrideUsed) &&
    all(route_registry$WarningCount == 0L) &&
    all(route_registry$FitStatus == "identified_point_fit")
  pair_ready <- nrow(pair_registry) == 2L &&
    all(pair_registry$NumericalParityPassed) &&
    all(pair_registry$BothPointGatesPassed) &&
    all(pair_registry$BackendDependencyIdentityPassed) &&
    all(pair_registry$ExactSpecificationMatch) &&
    all(pair_registry$ExactSemanticModelMatch)
  receipt <- structure(c(payload, list(
    ReceiptHash = mfrmr_gtvqw_hash(payload),
    CompleteFitObjectsReturned = identical(length(fits), 4L),
    CompleteParityObjectsReturned = identical(length(parities), 2L),
    AllRouteObjectChecksPassed = route_ready,
    AllPairObjectChecksPassed = pair_ready,
    WorkerWarningFree = length(worker_warnings) == 0L,
    DiagnosticOverrideUsed = any(route_registry$DiagnosticOverrideUsed),
    DependencyABIMatch = all(route_registry$DependencyABIMatch),
    LoadedNamespaceClosureCaptured = TRUE,
    FreshProcessClaimedByWorker = FALSE,
    ProcessCapabilityIsolationAssessed = FALSE,
    ProcessCapabilityIsolationReady = FALSE,
    WorkerSelfReported = TRUE,
    QualificationObjectsReady = route_ready && pair_ready &&
      length(worker_warnings) == 0L,
    TrustedReceiptProduced = FALSE,
    OperationallyAdmissible = FALSE,
    BackendQualificationReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE,
    ConQuestRouteIncluded = FALSE
  )), class = c("mfrmr_gtvqw_receipt", "list"))
  saveRDS(receipt, output_path, version = 3L)
  invisible(receipt)
}

if (identical(environment(), globalenv()) && !interactive()) {
  mfrmr_gtvqw_main()
}
