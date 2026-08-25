# Draft.85c4i isolated ABI-repair execution.
#
# Repository-internal only. This controller installs pinned TMB/glmmTMB source
# artifacts into a deterministic temporary overlay, observes that overlay in a
# fresh process, and retains a typed repair receipt. It does not fit a model.

mfrmr_gtvp_require_primitives <- function() {
  required <- c("mfrmr_gtvl_manifest", "mfrmr_gtvl_assert_manifest")
  target <- environment(mfrmr_gtvp_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the Draft.85c4e chain before Draft.85c4i: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtvp_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4i requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvp_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    setequal(names(attributes(object)), c("names", "class"))
}

mfrmr_gtvp_file_hash <- function(path) {
  if (!is.character(path) || length(path) != 1L || is.na(path) ||
      !file.exists(path) || dir.exists(path)) {
    stop("A Draft.85c4i identity file is missing.", call. = FALSE)
  }
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtvp_command_output <- function(command, arguments) {
  output <- suppressWarnings(system2(
    command, arguments, stdout = TRUE, stderr = TRUE
  ))
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  if (status != 0L) {
    stop(
      "A Draft.85c4i identity command failed: ",
      paste(output, collapse = " | "), call. = FALSE
    )
  }
  as.character(output)
}

mfrmr_gtvp_source_plan <- function() {
  data.frame(
    SourceOrdinal = 1:2,
    Package = c("TMB", "glmmTMB"),
    Version = c("1.9.25", "1.1.14"),
    FileName = c("TMB_1.9.25.tar.gz", "glmmTMB_1.1.14.tar.gz"),
    CanonicalURL = c(
      "https://cran.r-project.org/src/contrib/TMB_1.9.25.tar.gz",
      "https://cran.r-project.org/src/contrib/glmmTMB_1.1.14.tar.gz"
    ),
    SHA256 = c(
      "cf9663b29949cd5eaccb32e11900c9e07caec7d6ac4f17cfd938317dc33acff2",
      "623c81cfe4b3c6825db15d44781eccf7a357cf15b423fe9f00459f52beeffbbd"
    ),
    Repository = rep("CRAN", 2L),
    DatePublicationUTC = c(
      "2026-08-22 09:50:02 UTC", "2026-01-15 06:10:22 UTC"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvp_tar_description <- function(path, package) {
  staging <- tempfile("mfrmr-c4i-description-", tmpdir = tempdir())
  if (!dir.create(staging)) {
    stop("Draft.85c4i could not stage a source DESCRIPTION.",
         call. = FALSE)
  }
  on.exit(unlink(staging, recursive = TRUE), add = TRUE)
  member <- paste0(package, "/DESCRIPTION")
  status <- utils::untar(path, files = member, exdir = staging)
  description <- file.path(staging, member)
  if (!identical(status, 0L) || !file.exists(description)) {
    stop("A Draft.85c4i source DESCRIPTION could not be extracted.",
         call. = FALSE)
  }
  as.list(read.dcf(description)[1L, , drop = TRUE])
}

mfrmr_gtvp_source_registry <- function(source_dir) {
  source_dir <- normalizePath(source_dir, mustWork = TRUE)
  plan <- mfrmr_gtvp_source_plan()
  paths <- file.path(source_dir, plan$FileName)
  if (!all(file.exists(paths)) || any(dir.exists(paths))) {
    stop("The Draft.85c4i pinned source set is incomplete.", call. = FALSE)
  }
  actual_hash <- unname(vapply(
    paths, mfrmr_gtvp_file_hash, character(1L)
  ))
  if (!identical(actual_hash, plan$SHA256)) {
    stop("A Draft.85c4i source artifact hash changed.", call. = FALSE)
  }
  descriptions <- lapply(seq_along(paths), function(index) {
    mfrmr_gtvp_tar_description(paths[[index]], plan$Package[[index]])
  })
  observed <- data.frame(
    SourceOrdinal = plan$SourceOrdinal,
    Package = vapply(descriptions, `[[`, character(1L), "Package"),
    Version = vapply(descriptions, `[[`, character(1L), "Version"),
    FileName = plan$FileName,
    CanonicalURL = plan$CanonicalURL,
    SHA256 = actual_hash,
    Bytes = as.numeric(file.info(paths)$size),
    Repository = vapply(descriptions, `[[`, character(1L), "Repository"),
    DatePublicationUTC = vapply(
      descriptions, `[[`, character(1L), "Date/Publication"
    ),
    stringsAsFactors = FALSE
  )
  comparable <- observed[names(plan)]
  if (!identical(comparable, plan) || any(observed$Bytes <= 0)) {
    stop("A Draft.85c4i source DESCRIPTION or size changed.",
         call. = FALSE)
  }
  observed
}

mfrmr_gtvp_toolchain_identity <- function() {
  r_exec <- normalizePath(file.path(R.home("bin"), "R"), mustWork = TRUE)
  rscript <- normalizePath(
    file.path(R.home("bin"), "Rscript"), mustWork = TRUE
  )
  gfortran <- normalizePath("/opt/homebrew/bin/gfortran", mustWork = TRUE)
  default_fc <- paste(mfrmr_gtvp_command_output(
    r_exec, c("CMD", "config", "FC")
  ), collapse = "\n")
  default_flibs <- paste(mfrmr_gtvp_command_output(
    r_exec, c("CMD", "config", "FLIBS")
  ), collapse = "\n")
  runtime_names <- c(
    "libgfortran.dylib", "libquadmath.dylib", "libemutls_w.a",
    "libheapt_w.a"
  )
  runtime_paths <- vapply(runtime_names, function(name) {
    result <- mfrmr_gtvp_command_output(
      gfortran, paste0("-print-file-name=", name)
    )
    normalizePath(result[[1L]], mustWork = TRUE)
  }, character(1L))
  version_output <- mfrmr_gtvp_command_output(gfortran, "--version")
  default_fc_path <- strsplit(default_fc, "[[:space:]]+")[[1L]][[1L]]
  payload <- list(
    Contract = "gtheory_multivariate_abi_toolchain_draft85c4i_v1",
    RVersion = R.version.string,
    RPlatform = R.version$platform,
    RExecutable = r_exec,
    RExecutableSHA256 = mfrmr_gtvp_file_hash(r_exec),
    RscriptExecutable = rscript,
    RscriptExecutableSHA256 = mfrmr_gtvp_file_hash(rscript),
    DefaultFC = default_fc,
    DefaultFLIBS = default_flibs,
    OverrideGFortran = gfortran,
    OverrideGFortranSHA256 = mfrmr_gtvp_file_hash(gfortran),
    OverrideGFortranVersion = version_output,
    RuntimeRegistry = data.frame(
      RuntimeOrdinal = seq_along(runtime_names),
      Runtime = runtime_names,
      Path = unname(runtime_paths),
      SHA256 = vapply(runtime_paths, mfrmr_gtvp_file_hash, character(1L)),
      stringsAsFactors = FALSE
    )
  )
  structure(c(payload, list(
    ToolchainIdentityHash = mfrmr_gtvp_hash(payload),
    DefaultRFortranToolchainReady = file.exists(default_fc_path) &&
      !grepl("/opt/gfortran", default_flibs, fixed = TRUE),
    ToolchainOverrideRequired = !file.exists(default_fc_path) ||
      grepl("/opt/gfortran", default_flibs, fixed = TRUE),
    ToolchainOverrideReady = TRUE
  )), class = c("mfrmr_gtvp_toolchain", "list"))
}

mfrmr_gtvp_makevars_text <- function(toolchain) {
  if (!inherits(toolchain, "mfrmr_gtvp_toolchain") ||
      !isTRUE(toolchain$ToolchainOverrideReady)) {
    stop("A ready Draft.85c4i toolchain override is required.",
         call. = FALSE)
  }
  registry <- toolchain$RuntimeRegistry
  runtime_path <- setNames(registry$Path, registry$Runtime)
  flibs <- c(
    paste0("-L", dirname(runtime_path[["libemutls_w.a"]])),
    paste0("-L", dirname(runtime_path[["libgfortran.dylib"]])),
    "-lemutls_w", "-lheapt_w", "-lgfortran", "-lquadmath"
  )
  paste(c(
    paste0("FC=", toolchain$OverrideGFortran),
    paste0("F77=", toolchain$OverrideGFortran),
    paste0("FLIBS=", paste(flibs, collapse = " "))
  ), collapse = "\n")
}

mfrmr_gtvp_toolchain_audit <- function(toolchain, makevars_text) {
  canonical <- mfrmr_gtvp_toolchain_identity()
  valid_identity <- identical(toolchain, canonical)
  data.frame(
    Rule = c(
      "toolchain_identity_current", "default_toolchain_not_ready",
      "override_required", "override_ready", "fc_pinned",
      "f77_pinned", "bad_opt_gfortran_absent", "all_runtime_dirs_pinned"
    ),
    Passed = c(
      valid_identity,
      !isTRUE(toolchain$DefaultRFortranToolchainReady),
      isTRUE(toolchain$ToolchainOverrideRequired),
      isTRUE(toolchain$ToolchainOverrideReady),
      grepl(paste0("FC=", toolchain$OverrideGFortran),
            makevars_text, fixed = TRUE),
      grepl(paste0("F77=", toolchain$OverrideGFortran),
            makevars_text, fixed = TRUE),
      !grepl("/opt/gfortran", makevars_text, fixed = TRUE),
      all(vapply(unique(dirname(toolchain$RuntimeRegistry$Path)), function(x) {
        grepl(x, makevars_text, fixed = TRUE)
      }, logical(1L)))
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvp_worker_identity <- function(worker_environment) {
  functions <- c(
    "mfrmr_gtvpw_hash", "mfrmr_gtvpw_file_hash",
    "mfrmr_gtvpw_exact_object", "mfrmr_gtvpw_package_row",
    "mfrmr_gtvpw_main"
  )
  if (!is.environment(worker_environment) ||
      !identical(parent.env(worker_environment), baseenv()) ||
      !identical(
        sort(ls(worker_environment, all.names = TRUE), method = "radix"),
        sort(functions, method = "radix")
      ) || !all(vapply(functions, function(name) {
        is.function(get(name, envir = worker_environment, inherits = FALSE))
      }, logical(1L)))) {
    stop("The Draft.85c4i identity-worker namespace was altered.",
         call. = FALSE)
  }
  data.frame(
    Function = functions,
    SHA256 = vapply(functions, function(name) {
      fun <- get(name, envir = worker_environment, inherits = FALSE)
      mfrmr_gtvp_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvp_identity_payload_fields <- function() {
  c(
    "Contract", "OverlayLibrary", "LibraryOrder", "RVersion", "RPlatform",
    "PackageRegistry", "PackageRegistryHash",
    "LoadedGlmmTMBBuildTMBVersion", "RuntimeTMBVersion",
    "GlmmTMBABIVersion"
  )
}

mfrmr_gtvp_assert_identity_receipt <- function(receipt, overlay) {
  payload_fields <- mfrmr_gtvp_identity_payload_fields()
  suffix_fields <- c(
    "ReceiptHash", "OverlayLibraryOrderReady", "RequiredPackagesAvailable",
    "NativeBinaryIdentityReady", "DependencyABIMatch",
    "FreshProcessClaimedByWorker", "BackendExecutionOccurred",
    "QualificationEvidenceReady", "BackendQualificationReady",
    "ExecutionAuthorized", "RecoveryEvidenceReady", "PublicSupportReady"
  )
  if (!mfrmr_gtvp_exact_object(
    receipt, c(payload_fields, suffix_fields),
    c("mfrmr_gtvp_identity_receipt", "list")
  )) {
    stop("A typed Draft.85c4i identity receipt is required.",
         call. = FALSE)
  }
  registry <- receipt$PackageRegistry
  expected_versions <- c(
    lme4 = "2.0.6", glmmTMB = "1.1.14", TMB = "1.9.25",
    Matrix = "1.7.6", RcppEigen = "0.3.4.0.2"
  )
  registry_ready <- is.data.frame(registry) && nrow(registry) == 5L &&
    identical(registry$PackageOrdinal, 1:5) &&
    identical(registry$Package, names(expected_versions)) &&
    identical(registry$Version, unname(expected_versions)) &&
    all(file.exists(registry$PackagePath)) &&
    all(nchar(registry$DescriptionSHA256) == 64L) &&
    all(vapply(seq_len(nrow(registry)), function(index) {
      description <- file.path(registry$PackagePath[[index]], "DESCRIPTION")
      identical(
        registry$DescriptionSHA256[[index]], mfrmr_gtvp_file_hash(description)
      ) && if (registry$NativeDLLAvailable[[index]]) {
        identical(
          registry$NativeDLLSHA256[[index]],
          mfrmr_gtvp_file_hash(registry$NativeDLLPath[[index]])
        )
      } else {
        is.na(registry$NativeDLLPath[[index]]) &&
          is.na(registry$NativeDLLSHA256[[index]])
      }
    }, logical(1L)))
  valid <- identical(
    receipt$Contract,
    "gtheory_multivariate_abi_repair_identity_draft85c4i_v1"
  ) && identical(receipt$OverlayLibrary,
                 normalizePath(overlay, mustWork = TRUE)) &&
    identical(receipt$LibraryOrder[[1L]], receipt$OverlayLibrary) &&
    registry_ready && identical(
      receipt$PackageRegistryHash, mfrmr_gtvp_hash(registry)
    ) && identical(receipt$LoadedGlmmTMBBuildTMBVersion, "1.9.25") &&
    identical(receipt$RuntimeTMBVersion, "1.9.25") &&
    identical(receipt$GlmmTMBABIVersion, "2") &&
    identical(receipt$ReceiptHash, mfrmr_gtvp_hash(receipt[payload_fields])) &&
    isTRUE(receipt$OverlayLibraryOrderReady) &&
    isTRUE(receipt$RequiredPackagesAvailable) &&
    isTRUE(receipt$NativeBinaryIdentityReady) &&
    isTRUE(receipt$DependencyABIMatch) &&
    !isTRUE(receipt$FreshProcessClaimedByWorker) &&
    !isTRUE(receipt$BackendExecutionOccurred) &&
    !isTRUE(receipt$QualificationEvidenceReady) &&
    !isTRUE(receipt$BackendQualificationReady) &&
    !isTRUE(receipt$ExecutionAuthorized) &&
    !isTRUE(receipt$RecoveryEvidenceReady) &&
    !isTRUE(receipt$PublicSupportReady)
  if (!valid) {
    stop("The Draft.85c4i identity receipt or package identity was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvp_build_registry <- function(
    packages, source_registry, overlay, log_paths, statuses) {
  rows <- lapply(seq_along(packages), function(index) {
    package <- packages[[index]]
    log_lines <- readLines(log_paths[[index]], warn = FALSE)
    warning_lines <- grep("warning:", log_lines, value = TRUE)
    warning_class <- if (length(warning_lines) == 0L) {
      "none"
    } else if (all(grepl(
      "warning: variable .* set but not used", warning_lines
    ))) {
      "rcppeigen_unused_but_set_only"
    } else {
      "unclassified_build_warning"
    }
    package_path <- file.path(overlay, package)
    description <- file.path(package_path, "DESCRIPTION")
    dll <- file.path(package_path, "libs", paste0(package, .Platform$dynlib.ext))
    data.frame(
      BuildOrdinal = as.integer(index),
      Package = package,
      SourceSHA256 = source_registry$SHA256[
        match(package, source_registry$Package)
      ],
      ExitStatus = as.integer(statuses[[index]]),
      LogPath = normalizePath(log_paths[[index]], mustWork = TRUE),
      LogSHA256 = mfrmr_gtvp_file_hash(log_paths[[index]]),
      CompilerWarningCount = as.integer(length(warning_lines)),
      CompilerWarningLinesHash = mfrmr_gtvp_hash(warning_lines),
      WarningClass = warning_class,
      InstalledDescriptionPath = normalizePath(description, mustWork = TRUE),
      InstalledDescriptionSHA256 = mfrmr_gtvp_file_hash(description),
      InstalledDLLPath = normalizePath(dll, mustWork = TRUE),
      InstalledDLLSHA256 = mfrmr_gtvp_file_hash(dll),
      stringsAsFactors = FALSE
    )
  })
  registry <- do.call(rbind, rows)
  row.names(registry) <- NULL
  registry
}

mfrmr_gtvp_repair_root <- function(source_registry, toolchain) {
  file.path("/private/tmp", paste0("mfrmr-c4i-", substr(mfrmr_gtvp_hash(list(
    Namespace = "gtheory_multivariate_abi_repair_root_draft85c4i_v1",
    C4EManifestHash =
      "cb8214df9c468858ca3e4e267e815eab99918f880fb99ed6a336a2b053ef80ce",
    C4HCapabilityEvidenceHash =
      "5cd3d148d28cdf59846c5108e21ddd55094da1e006829104a79104e5c08fe103",
    SourceArtifactRegistryHash = mfrmr_gtvp_hash(source_registry),
    ToolchainIdentityHash = toolchain$ToolchainIdentityHash
  )), 1L, 16L)))
}

mfrmr_gtvp_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtvp_require_primitives", "mfrmr_gtvp_hash",
    "mfrmr_gtvp_exact_object", "mfrmr_gtvp_file_hash",
    "mfrmr_gtvp_command_output", "mfrmr_gtvp_source_plan",
    "mfrmr_gtvp_tar_description", "mfrmr_gtvp_source_registry",
    "mfrmr_gtvp_toolchain_identity", "mfrmr_gtvp_makevars_text",
    "mfrmr_gtvp_toolchain_audit", "mfrmr_gtvp_worker_identity",
    "mfrmr_gtvp_identity_payload_fields",
    "mfrmr_gtvp_assert_identity_receipt", "mfrmr_gtvp_build_registry",
    "mfrmr_gtvp_repair_root", "mfrmr_gtvp_implementation_identity",
    "mfrmr_gtvp_receipt_payload_fields", "mfrmr_gtvp_assert_receipt",
    "mfrmr_gtvp_execute", "mfrmr_gtvp_dispatch_guard"
  )
  target <- environment(mfrmr_gtvp_implementation_identity)
  data.frame(
    Function = functions,
    SHA256 = vapply(functions, function(name) {
      if (!exists(name, envir = target, inherits = FALSE)) {
        stop("A Draft.85c4i implementation function is missing: ", name,
             ".", call. = FALSE)
      }
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtvp_hash(list(
        Formals = paste(deparse(formals(fun)), collapse = "\n"),
        Body = paste(deparse(body(fun)), collapse = "\n")
      ))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvp_receipt_payload_fields <- function() {
  c(
    "Contract", "C4EManifestHash", "C4HCapabilityEvidenceHash",
    "SourceArtifactRegistry", "SourceArtifactRegistryHash",
    "ToolchainIdentity", "ToolchainIdentityHash", "ToolchainAudit",
    "ToolchainAuditHash", "MakevarsSHA256", "RepairRoot",
    "OverlayLibrary", "BuildReceiptRegistry", "BuildReceiptRegistryHash",
    "IdentityWorkerSourceSHA256", "IdentityWorkerIdentity",
    "IdentityWorkerIdentityHash", "FreshProcessReceipt",
    "FreshProcessReceiptHash", "FreshProcessExitStatus",
    "FreshProcessOutput", "ImplementationIdentity",
    "ImplementationIdentityHash", "ArtifactRetained",
    "ConQuestRouteIncluded"
  )
}

mfrmr_gtvp_assert_receipt <- function(
    receipt, worker_environment, c4e_manifest, repo_root = ".") {
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  mfrmr_gtvl_assert_manifest(c4e_manifest, repo_root)
  payload_fields <- mfrmr_gtvp_receipt_payload_fields()
  suffix_fields <- c(
    "ReceiptHash", "IsolatedLibraryCreated", "PackageSourcesPinned",
    "SelectedTMBInstalled", "GlmmTMBRebuiltAgainstSelectedTMB",
    "FreshProcessIdentityReobserved", "FourRouteReceiptsCompleted",
    "RepairExecuted", "RepairReceiptReady",
    "DefaultRFortranToolchainReady", "ToolchainOverrideReady",
    "SourceBuildWarningFree", "BuildDiagnosticsAdmissible",
    "RepairedEnvironmentABIMatch",
    "RepairedEnvironmentReadyForBackendQualification",
    "RepairProcessCapabilityIsolationReady", "QualificationWorkerImplemented",
    "FullB1ObjectsReceived", "RouteReceiptsMaterialized",
    "PairReceiptsMaterialized", "TrustedReceiptProduced",
    "QualificationEvidenceReady", "BackendQualificationReady",
    "DiagnosticOverrideAllowed", "PilotExecutionAuthorized",
    "ConfirmationExecutionAuthorized", "NegativeControlExecutionAuthorized",
    "ExecutionGateClosed", "BackendExecutionOccurred",
    "PlannedResponseGenerated", "RecoveryExecuted", "RecoveryEvidenceReady",
    "EstimationReady", "InferenceReady", "DecisionReady",
    "PublicSupportReady"
  )
  if (!mfrmr_gtvp_exact_object(
    receipt, c(payload_fields, suffix_fields),
    c("mfrmr_gtvp_repair_receipt", "list")
  )) {
    stop("A typed Draft.85c4i repair receipt is required.", call. = FALSE)
  }
  root <- normalizePath(receipt$RepairRoot, mustWork = TRUE)
  overlay <- normalizePath(receipt$OverlayLibrary, mustWork = TRUE)
  source_dir <- file.path(root, "source")
  source_registry <- mfrmr_gtvp_source_registry(source_dir)
  toolchain <- mfrmr_gtvp_toolchain_identity()
  makevars <- file.path(root, "Makevars")
  makevars_text <- paste(readLines(makevars, warn = FALSE), collapse = "\n")
  audit <- mfrmr_gtvp_toolchain_audit(toolchain, makevars_text)
  build <- receipt$BuildReceiptRegistry
  build_ready <- is.data.frame(build) && nrow(build) == 2L &&
    identical(build$BuildOrdinal, 1:2) &&
    identical(build$Package, c("TMB", "glmmTMB")) &&
    identical(build$ExitStatus, c(0L, 0L)) &&
    identical(build$CompilerWarningCount, c(0L, 3L)) &&
    identical(build$WarningClass, c(
      "none", "rcppeigen_unused_but_set_only"
    )) && all(vapply(seq_len(nrow(build)), function(index) {
      identical(build$LogSHA256[[index]],
                mfrmr_gtvp_file_hash(build$LogPath[[index]])) &&
        identical(build$InstalledDescriptionSHA256[[index]],
                  mfrmr_gtvp_file_hash(
                    build$InstalledDescriptionPath[[index]]
                  )) &&
        identical(build$InstalledDLLSHA256[[index]],
                  mfrmr_gtvp_file_hash(build$InstalledDLLPath[[index]]))
    }, logical(1L)))
  mfrmr_gtvp_assert_identity_receipt(receipt$FreshProcessReceipt, overlay)
  worker_identity <- mfrmr_gtvp_worker_identity(worker_environment)
  worker_source <- file.path(root, "source", "identity-worker.R")
  ready_flags <- c(
    "IsolatedLibraryCreated", "PackageSourcesPinned", "SelectedTMBInstalled",
    "GlmmTMBRebuiltAgainstSelectedTMB", "FreshProcessIdentityReobserved",
    "RepairExecuted", "RepairReceiptReady", "ToolchainOverrideReady",
    "BuildDiagnosticsAdmissible", "RepairedEnvironmentABIMatch",
    "RepairedEnvironmentReadyForBackendQualification", "ExecutionGateClosed"
  )
  closed_flags <- c(
    "FourRouteReceiptsCompleted", "DefaultRFortranToolchainReady",
    "SourceBuildWarningFree", "RepairProcessCapabilityIsolationReady",
    "QualificationWorkerImplemented", "FullB1ObjectsReceived",
    "RouteReceiptsMaterialized", "PairReceiptsMaterialized",
    "TrustedReceiptProduced", "QualificationEvidenceReady",
    "BackendQualificationReady", "DiagnosticOverrideAllowed",
    "PilotExecutionAuthorized", "ConfirmationExecutionAuthorized",
    "NegativeControlExecutionAuthorized", "BackendExecutionOccurred",
    "PlannedResponseGenerated", "RecoveryExecuted", "RecoveryEvidenceReady",
    "EstimationReady", "InferenceReady", "DecisionReady",
    "PublicSupportReady"
  )
  valid <- identical(
    receipt$Contract, "gtheory_multivariate_abi_repair_draft85c4i_v1"
  ) && identical(
    receipt$C4EManifestHash,
    "cb8214df9c468858ca3e4e267e815eab99918f880fb99ed6a336a2b053ef80ce"
  ) && identical(receipt$C4EManifestHash, c4e_manifest$ManifestHash) &&
    identical(
      receipt$C4HCapabilityEvidenceHash,
      "5cd3d148d28cdf59846c5108e21ddd55094da1e006829104a79104e5c08fe103"
    ) && identical(receipt$SourceArtifactRegistry, source_registry) &&
    identical(receipt$SourceArtifactRegistryHash,
              mfrmr_gtvp_hash(source_registry)) &&
    identical(receipt$ToolchainIdentity, toolchain) &&
    identical(receipt$ToolchainIdentityHash,
              toolchain$ToolchainIdentityHash) &&
    identical(receipt$ToolchainAudit, audit) && all(audit$Passed) &&
    identical(receipt$ToolchainAuditHash, mfrmr_gtvp_hash(audit)) &&
    identical(receipt$MakevarsSHA256, mfrmr_gtvp_file_hash(makevars)) &&
    identical(overlay, normalizePath(file.path(root, "library"),
                                     mustWork = TRUE)) &&
    build_ready && identical(receipt$BuildReceiptRegistryHash,
                             mfrmr_gtvp_hash(build)) &&
    identical(receipt$IdentityWorkerSourceSHA256,
              mfrmr_gtvp_file_hash(worker_source)) &&
    identical(
      receipt$IdentityWorkerSourceSHA256,
      "7130738bec5d7fe3172906e7d428ea182c6941a13381cf11a1c12c5d101667db"
    ) && identical(receipt$IdentityWorkerIdentity, worker_identity) &&
    identical(receipt$IdentityWorkerIdentityHash,
              mfrmr_gtvp_hash(worker_identity)) &&
    identical(receipt$FreshProcessReceiptHash,
              receipt$FreshProcessReceipt$ReceiptHash) &&
    identical(receipt$FreshProcessExitStatus, 0L) &&
    length(receipt$FreshProcessOutput) == 0L &&
    identical(receipt$ImplementationIdentity,
              mfrmr_gtvp_implementation_identity()) &&
    identical(receipt$ImplementationIdentityHash,
              mfrmr_gtvp_hash(receipt$ImplementationIdentity)) &&
    isTRUE(receipt$ArtifactRetained) &&
    !isTRUE(receipt$ConQuestRouteIncluded) &&
    identical(receipt$ReceiptHash,
              mfrmr_gtvp_hash(receipt[payload_fields])) &&
    all(vapply(ready_flags, function(name) isTRUE(receipt[[name]]),
               logical(1L))) &&
    !any(vapply(closed_flags, function(name) isTRUE(receipt[[name]]),
                logical(1L)))
  if (!valid) {
    stop("The Draft.85c4i repair receipt or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvp_execute <- function(
    source_dir, worker_environment, c4e_manifest, repo_root = ".",
    validation_dir = file.path("inst", "validation"),
    authorize_repair = FALSE, allow_exact_reuse = FALSE) {
  if (!isTRUE(authorize_repair)) {
    stop("ABI repair requires `authorize_repair=TRUE`.", call. = FALSE)
  }
  if (!is.logical(allow_exact_reuse) || length(allow_exact_reuse) != 1L ||
      is.na(allow_exact_reuse)) {
    stop("`allow_exact_reuse` must be TRUE or FALSE.", call. = FALSE)
  }
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  validation_dir <- normalizePath(validation_dir, mustWork = TRUE)
  mfrmr_gtvl_assert_manifest(c4e_manifest, repo_root)
  if (!identical(
    c4e_manifest$ManifestHash,
    "cb8214df9c468858ca3e4e267e815eab99918f880fb99ed6a336a2b053ef80ce"
  )) {
    stop("The sealed Draft.85c4e manifest root changed.", call. = FALSE)
  }
  source_dir <- normalizePath(source_dir, mustWork = TRUE)
  sources <- mfrmr_gtvp_source_registry(source_dir)
  toolchain <- mfrmr_gtvp_toolchain_identity()
  makevars_text <- mfrmr_gtvp_makevars_text(toolchain)
  audit <- mfrmr_gtvp_toolchain_audit(toolchain, makevars_text)
  if (!all(audit$Passed)) {
    stop("The Draft.85c4i toolchain audit failed.", call. = FALSE)
  }
  worker_identity <- mfrmr_gtvp_worker_identity(worker_environment)
  worker_source <- normalizePath(file.path(
    validation_dir,
    "gtheory-multivariate-abi-repair-identity-worker-0.2.4.R"
  ), mustWork = TRUE)
  worker_hash <- mfrmr_gtvp_file_hash(worker_source)
  if (!identical(
    worker_hash,
    "7130738bec5d7fe3172906e7d428ea182c6941a13381cf11a1c12c5d101667db"
  )) {
    stop("The sealed Draft.85c4i identity-worker source changed.",
         call. = FALSE)
  }
  root <- mfrmr_gtvp_repair_root(sources, toolchain)
  receipt_path <- file.path(root, "repair-receipt.rds")
  if (dir.exists(root) || file.exists(root)) {
    if (isTRUE(allow_exact_reuse) && file.exists(receipt_path)) {
      receipt <- readRDS(receipt_path)
      mfrmr_gtvp_assert_receipt(
        receipt, worker_environment, c4e_manifest, repo_root
      )
      if (!identical(receipt$SourceArtifactRegistry, sources) ||
          !identical(receipt$ToolchainIdentity, toolchain)) {
        stop("The retained Draft.85c4i repair identity changed.",
             call. = FALSE)
      }
      return(receipt)
    }
    stop("The deterministic Draft.85c4i repair path is occupied.",
         call. = FALSE)
  }
  if (!dir.create(root)) {
    stop("Draft.85c4i could not create the repair root.", call. = FALSE)
  }
  success <- FALSE
  on.exit({
    if (!success && dir.exists(root)) unlink(root, recursive = TRUE)
  }, add = TRUE)
  staged_source <- file.path(root, "source")
  overlay <- file.path(root, "library")
  logs <- file.path(root, "logs")
  if (!all(vapply(c(staged_source, overlay, logs), dir.create, logical(1L)))) {
    stop("Draft.85c4i could not create repair directories.", call. = FALSE)
  }
  copied_sources <- file.copy(
    file.path(source_dir, sources$FileName),
    file.path(staged_source, sources$FileName)
  )
  staged_worker <- file.path(staged_source, "identity-worker.R")
  copied_worker <- file.copy(worker_source, staged_worker)
  if (!all(copied_sources) || !isTRUE(copied_worker) ||
      !identical(mfrmr_gtvp_source_registry(staged_source), sources) ||
      !identical(mfrmr_gtvp_file_hash(staged_worker), worker_hash)) {
    stop("Draft.85c4i staged source identity did not match.",
         call. = FALSE)
  }
  makevars <- file.path(root, "Makevars")
  writeLines(makevars_text, makevars, useBytes = TRUE)
  library_order <- paste(
    c(normalizePath(overlay, mustWork = TRUE), .libPaths()),
    collapse = .Platform$path.sep
  )
  build_packages <- c("TMB", "glmmTMB")
  statuses <- integer(2L)
  log_paths <- file.path(logs, paste0(build_packages, "-install.log"))
  for (index in seq_along(build_packages)) {
    package <- build_packages[[index]]
    tarball <- file.path(staged_source, sources$FileName[
      match(package, sources$Package)
    ])
    output <- suppressWarnings(system2(
      toolchain$RExecutable,
      c("CMD", "INSTALL", paste0("--library=", overlay), tarball),
      env = c(
        paste0("R_MAKEVARS_USER=", makevars),
        paste0("R_LIBS_USER=", library_order)
      ), stdout = TRUE, stderr = TRUE
    ))
    status <- attr(output, "status")
    if (is.null(status)) status <- 0L
    statuses[[index]] <- as.integer(status)
    writeLines(as.character(output), log_paths[[index]], useBytes = TRUE)
    if (status != 0L) {
      stop(
        "Draft.85c4i source build failed for ", package, ": ",
        paste(tail(output, 20L), collapse = " | "), call. = FALSE
      )
    }
  }
  build <- mfrmr_gtvp_build_registry(
    build_packages, sources, overlay, log_paths, statuses
  )
  if (!identical(build$CompilerWarningCount, c(0L, 3L)) ||
      !identical(build$WarningClass, c(
        "none", "rcppeigen_unused_but_set_only"
      ))) {
    stop("Draft.85c4i build diagnostics were not prespecified.",
         call. = FALSE)
  }
  identity_path <- file.path(root, "fresh-process-identity.rds")
  process_output <- suppressWarnings(system2(
    toolchain$RscriptExecutable,
    c("--vanilla", staged_worker, overlay, identity_path),
    env = paste0("R_LIBS_USER=", library_order),
    stdout = TRUE, stderr = TRUE
  ))
  process_status <- attr(process_output, "status")
  if (is.null(process_status)) process_status <- 0L
  if (process_status != 0L || !file.exists(identity_path)) {
    stop(
      "Draft.85c4i fresh-process identity failed: ",
      paste(process_output, collapse = " | "), call. = FALSE
    )
  }
  identity_receipt <- readRDS(identity_path)
  mfrmr_gtvp_assert_identity_receipt(identity_receipt, overlay)
  implementation <- mfrmr_gtvp_implementation_identity()
  payload <- list(
    Contract = "gtheory_multivariate_abi_repair_draft85c4i_v1",
    C4EManifestHash = c4e_manifest$ManifestHash,
    C4HCapabilityEvidenceHash =
      "5cd3d148d28cdf59846c5108e21ddd55094da1e006829104a79104e5c08fe103",
    SourceArtifactRegistry = sources,
    SourceArtifactRegistryHash = mfrmr_gtvp_hash(sources),
    ToolchainIdentity = toolchain,
    ToolchainIdentityHash = toolchain$ToolchainIdentityHash,
    ToolchainAudit = audit,
    ToolchainAuditHash = mfrmr_gtvp_hash(audit),
    MakevarsSHA256 = mfrmr_gtvp_file_hash(makevars),
    RepairRoot = normalizePath(root, mustWork = TRUE),
    OverlayLibrary = normalizePath(overlay, mustWork = TRUE),
    BuildReceiptRegistry = build,
    BuildReceiptRegistryHash = mfrmr_gtvp_hash(build),
    IdentityWorkerSourceSHA256 = worker_hash,
    IdentityWorkerIdentity = worker_identity,
    IdentityWorkerIdentityHash = mfrmr_gtvp_hash(worker_identity),
    FreshProcessReceipt = identity_receipt,
    FreshProcessReceiptHash = identity_receipt$ReceiptHash,
    FreshProcessExitStatus = as.integer(process_status),
    FreshProcessOutput = as.character(process_output),
    ImplementationIdentity = implementation,
    ImplementationIdentityHash = mfrmr_gtvp_hash(implementation),
    ArtifactRetained = TRUE,
    ConQuestRouteIncluded = FALSE
  )
  receipt <- structure(c(payload, list(
    ReceiptHash = mfrmr_gtvp_hash(payload),
    IsolatedLibraryCreated = TRUE,
    PackageSourcesPinned = TRUE,
    SelectedTMBInstalled = TRUE,
    GlmmTMBRebuiltAgainstSelectedTMB = TRUE,
    FreshProcessIdentityReobserved = TRUE,
    FourRouteReceiptsCompleted = FALSE,
    RepairExecuted = TRUE,
    RepairReceiptReady = TRUE,
    DefaultRFortranToolchainReady =
      toolchain$DefaultRFortranToolchainReady,
    ToolchainOverrideReady = toolchain$ToolchainOverrideReady,
    SourceBuildWarningFree = sum(build$CompilerWarningCount) == 0L,
    BuildDiagnosticsAdmissible = all(build$WarningClass %in% c(
      "none", "rcppeigen_unused_but_set_only"
    )),
    RepairedEnvironmentABIMatch = identity_receipt$DependencyABIMatch,
    RepairedEnvironmentReadyForBackendQualification = TRUE,
    RepairProcessCapabilityIsolationReady = FALSE,
    QualificationWorkerImplemented = FALSE,
    FullB1ObjectsReceived = FALSE,
    RouteReceiptsMaterialized = FALSE,
    PairReceiptsMaterialized = FALSE,
    TrustedReceiptProduced = FALSE,
    QualificationEvidenceReady = FALSE,
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
  )), class = c("mfrmr_gtvp_repair_receipt", "list"))
  saveRDS(receipt, receipt_path, version = 3L)
  mfrmr_gtvp_assert_receipt(
    receipt, worker_environment, c4e_manifest, repo_root
  )
  success <- TRUE
  receipt
}

mfrmr_gtvp_dispatch_guard <- function(
    receipt, action, callback, ..., authorize = FALSE,
    worker_environment, c4e_manifest, repo_root = ".") {
  mfrmr_gtvp_assert_receipt(
    receipt, worker_environment, c4e_manifest, repo_root
  )
  if (!is.character(action) || length(action) != 1L || is.na(action) ||
      !action %in% c("qualification_worker", "backend_fit", "receipt_trust")) {
    stop("The Draft.85c4i action is outside ABI repair.", call. = FALSE)
  }
  if (!is.function(callback)) {
    stop("`callback` must be a function.", call. = FALSE)
  }
  if (!is.logical(authorize) || length(authorize) != 1L || is.na(authorize)) {
    stop("`authorize` must be TRUE or FALSE.", call. = FALSE)
  }
  stop(
    "Draft.85c4i completes repair only; qualification remains closed.",
    call. = FALSE
  )
}
