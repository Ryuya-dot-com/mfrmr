# Draft.85c4i isolated ABI-repair identity worker.
#
# This standalone worker observes the repaired overlay in a fresh R process.
# It does not fit a model, inspect a response, or assert its own freshness.

mfrmr_gtvpw_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4i identity worker requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvpw_file_hash <- function(path) {
  if (!is.character(path) || length(path) != 1L || is.na(path) ||
      !file.exists(path) || dir.exists(path)) {
    stop("A Draft.85c4i identity file is missing.", call. = FALSE)
  }
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtvpw_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    setequal(names(attributes(object)), c("names", "class"))
}

mfrmr_gtvpw_package_row <- function(package, ordinal) {
  package_path <- normalizePath(find.package(package), mustWork = TRUE)
  description_path <- normalizePath(
    file.path(package_path, "DESCRIPTION"), mustWork = TRUE
  )
  dll_candidate <- file.path(
    package_path, "libs", paste0(package, .Platform$dynlib.ext)
  )
  dll_available <- file.exists(dll_candidate) && !dir.exists(dll_candidate)
  data.frame(
    PackageOrdinal = as.integer(ordinal),
    Package = package,
    Version = as.character(utils::packageVersion(package)),
    PackagePath = package_path,
    DescriptionSHA256 = mfrmr_gtvpw_file_hash(description_path),
    NativeDLLAvailable = dll_available,
    NativeDLLPath = if (dll_available) {
      normalizePath(dll_candidate, mustWork = TRUE)
    } else {
      NA_character_
    },
    NativeDLLSHA256 = if (dll_available) {
      mfrmr_gtvpw_file_hash(dll_candidate)
    } else {
      NA_character_
    },
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvpw_main <- function(arguments = commandArgs(trailingOnly = TRUE)) {
  if (!is.character(arguments) || length(arguments) != 2L ||
      anyNA(arguments) || any(!nzchar(arguments))) {
    stop("Draft.85c4i identity worker requires overlay and output paths.",
         call. = FALSE)
  }
  overlay <- normalizePath(arguments[[1L]], mustWork = TRUE)
  output <- arguments[[2L]]
  if (!identical(normalizePath(.libPaths()[[1L]], mustWork = TRUE), overlay)) {
    stop("The repaired overlay is not first in the library order.",
         call. = FALSE)
  }
  packages <- c("lme4", "glmmTMB", "TMB", "Matrix", "RcppEigen")
  if (!all(vapply(packages, requireNamespace, logical(1L), quietly = TRUE))) {
    stop("The repaired environment is missing a required package.",
         call. = FALSE)
  }
  suppressPackageStartupMessages(library(glmmTMB))
  namespace <- asNamespace("glmmTMB")
  if (!exists(".TMB.build.version", envir = namespace, inherits = FALSE) ||
      !exists("get_abi_version", envir = namespace, inherits = FALSE)) {
    stop("The repaired glmmTMB namespace lacks ABI identity fields.",
         call. = FALSE)
  }
  registry <- do.call(rbind, lapply(seq_along(packages), function(index) {
    mfrmr_gtvpw_package_row(packages[[index]], index)
  }))
  row.names(registry) <- NULL
  build_tmb <- as.character(get(
    ".TMB.build.version", envir = namespace, inherits = FALSE
  ))
  runtime_tmb <- as.character(utils::packageVersion("TMB"))
  abi <- as.character(get(
    "get_abi_version", envir = namespace, inherits = FALSE
  )())
  overlay_packages <- registry$Package %in% c("glmmTMB", "TMB")
  overlay_ready <- all(startsWith(
    registry$PackagePath[overlay_packages], paste0(overlay, .Platform$file.sep)
  )) && !any(startsWith(
    registry$PackagePath[!overlay_packages],
    paste0(overlay, .Platform$file.sep)
  ))
  native_ready <- all(
    registry$NativeDLLAvailable[registry$Package != "RcppEigen"]
  ) && all(nchar(
    registry$NativeDLLSHA256[registry$NativeDLLAvailable]
  ) == 64L)
  payload <- list(
    Contract = "gtheory_multivariate_abi_repair_identity_draft85c4i_v1",
    OverlayLibrary = overlay,
    LibraryOrder = normalizePath(.libPaths(), mustWork = TRUE),
    RVersion = R.version.string,
    RPlatform = R.version$platform,
    PackageRegistry = registry,
    PackageRegistryHash = mfrmr_gtvpw_hash(registry),
    LoadedGlmmTMBBuildTMBVersion = build_tmb,
    RuntimeTMBVersion = runtime_tmb,
    GlmmTMBABIVersion = abi
  )
  receipt <- structure(c(payload, list(
    ReceiptHash = mfrmr_gtvpw_hash(payload),
    OverlayLibraryOrderReady = overlay_ready,
    RequiredPackagesAvailable = TRUE,
    NativeBinaryIdentityReady = native_ready,
    DependencyABIMatch = identical(build_tmb, runtime_tmb),
    FreshProcessClaimedByWorker = FALSE,
    BackendExecutionOccurred = FALSE,
    QualificationEvidenceReady = FALSE,
    BackendQualificationReady = FALSE,
    ExecutionAuthorized = FALSE,
    RecoveryEvidenceReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvp_identity_receipt", "list"))
  saveRDS(receipt, output, version = 3L)
  invisible(receipt)
}

if (sys.nframe() == 0L) {
  mfrmr_gtvpw_main()
}
