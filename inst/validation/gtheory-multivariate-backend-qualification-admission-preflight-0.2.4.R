# Draft.85c4e multivariate G-theory backend-qualification admission.
#
# Repository-internal only. This file binds the current package/native-binary
# identity to a declarative repair plan and four empty qualification-receipt
# lanes. It does not install a package, rebuild a native library, fit a model,
# generate a planned response, invoke ConQuest, or authorize execution.

mfrmr_gtvl_require_primitives <- function() {
  required <- c(
    "mfrmr_gtvf_environment_snapshot",
    "mfrmr_gtvf_assert_environment_snapshot"
  )
  target <- environment(mfrmr_gtvl_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the Draft.85c3 environment boundary before Draft.85c4e: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtvl_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4e requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvl_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    setequal(names(attributes(object)), c("names", "class"))
}

mfrmr_gtvl_file_hash <- function(path) {
  if (!is.character(path) || length(path) != 1L || is.na(path) ||
      !file.exists(path) || dir.exists(path)) {
    stop("A Draft.85c4e identity file is missing.", call. = FALSE)
  }
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtvl_package_registry <- function() {
  packages <- c("lme4", "glmmTMB", "TMB")
  rows <- lapply(seq_along(packages), function(index) {
    package <- packages[[index]]
    available <- suppressWarnings(
      requireNamespace(package, quietly = TRUE)
    )
    if (!available) {
      return(data.frame(
        PackageOrdinal = as.integer(index), Package = package,
        Available = FALSE, Version = NA_character_,
        PackagePath = NA_character_, DescriptionPath = NA_character_,
        DescriptionSHA256 = NA_character_, NativeDLLPath = NA_character_,
        NativeDLLSHA256 = NA_character_, stringsAsFactors = FALSE
      ))
    }
    package_path <- normalizePath(
      system.file(package = package), mustWork = TRUE
    )
    description_path <- normalizePath(
      file.path(package_path, "DESCRIPTION"), mustWork = TRUE
    )
    dll_path <- normalizePath(
      file.path(package_path, "libs", paste0(package, .Platform$dynlib.ext)),
      mustWork = TRUE
    )
    data.frame(
      PackageOrdinal = as.integer(index), Package = package,
      Available = TRUE,
      Version = as.character(utils::packageVersion(package)),
      PackagePath = package_path,
      DescriptionPath = description_path,
      DescriptionSHA256 = mfrmr_gtvl_file_hash(description_path),
      NativeDLLPath = dll_path,
      NativeDLLSHA256 = mfrmr_gtvl_file_hash(dll_path),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gtvl_assert_package_registry <- function(registry) {
  expected_names <- c(
    "PackageOrdinal", "Package", "Available", "Version", "PackagePath",
    "DescriptionPath", "DescriptionSHA256", "NativeDLLPath",
    "NativeDLLSHA256"
  )
  valid <- is.data.frame(registry) && identical(names(registry), expected_names) &&
    identical(registry$PackageOrdinal, 1:3) &&
    identical(registry$Package, c("lme4", "glmmTMB", "TMB")) &&
    is.logical(registry$Available) && !anyNA(registry$Available) &&
    !anyDuplicated(registry$Package)
  if (!valid) {
    stop("A canonical Draft.85c4e package registry is required.",
         call. = FALSE)
  }
  identity_fields <- c(
    "Version", "PackagePath", "DescriptionPath", "DescriptionSHA256",
    "NativeDLLPath", "NativeDLLSHA256"
  )
  for (index in seq_len(nrow(registry))) {
    present <- registry$Available[[index]]
    values <- unlist(registry[index, identity_fields], use.names = FALSE)
    if (present) {
      files <- unlist(registry[index, c(
        "DescriptionPath", "NativeDLLPath"
      )], use.names = FALSE)
      hashes <- unlist(registry[index, c(
        "DescriptionSHA256", "NativeDLLSHA256"
      )], use.names = FALSE)
      if (anyNA(values) || any(!nzchar(values)) ||
          !all(file.exists(files)) || any(dir.exists(files)) ||
          !identical(unname(hashes), unname(vapply(
            files, mfrmr_gtvl_file_hash, character(1L)
          )))) {
        stop("A Draft.85c4e package/native identity was altered.",
             call. = FALSE)
      }
    } else if (!all(is.na(values))) {
      stop("An unavailable Draft.85c4e package carries an identity.",
           call. = FALSE)
    }
  }
  invisible(TRUE)
}

mfrmr_gtvl_environment_identity <- function(
    c3_snapshot = mfrmr_gtvf_environment_snapshot(),
    package_registry = mfrmr_gtvl_package_registry()) {
  mfrmr_gtvl_require_primitives()
  mfrmr_gtvf_assert_environment_snapshot(c3_snapshot)
  mfrmr_gtvl_assert_package_registry(package_registry)
  snapshot_available <- c(
    lme4 = c3_snapshot$Lme4Available,
    glmmTMB = c3_snapshot$GlmmTMBAvailable,
    TMB = c3_snapshot$TMBAvailable
  )
  snapshot_versions <- c(
    lme4 = c3_snapshot$Lme4Version,
    glmmTMB = c3_snapshot$GlmmTMBVersion,
    TMB = c3_snapshot$TMBVersion
  )
  names(snapshot_available) <- names(snapshot_versions) <-
    c("lme4", "glmmTMB", "TMB")
  if (!identical(unname(snapshot_available), package_registry$Available) ||
      !identical(unname(snapshot_versions), package_registry$Version)) {
    stop("The Draft.85c4e package registry and c3 snapshot disagree.",
         call. = FALSE)
  }
  if (c3_snapshot$GlmmTMBAvailable) {
    namespace <- suppressWarnings(asNamespace("glmmTMB"))
    loaded_build_tmb <- if (exists(
      ".TMB.build.version", envir = namespace, inherits = FALSE
    )) {
      as.character(get(
        ".TMB.build.version", envir = namespace, inherits = FALSE
      ))
    } else {
      NA_character_
    }
    if (!exists("get_abi_version", envir = namespace, inherits = FALSE)) {
      abi_version <- NA_character_
    } else {
      abi_version <- as.character(get(
        "get_abi_version", envir = namespace, inherits = FALSE
      )())
    }
  } else {
    loaded_build_tmb <- NA_character_
    abi_version <- NA_character_
  }
  native_ready <- all(package_registry$Available) &&
    !anyNA(package_registry[c(
      "DescriptionSHA256", "NativeDLLSHA256"
    )]) &&
    all(nchar(package_registry$DescriptionSHA256) == 64L) &&
    all(nchar(package_registry$NativeDLLSHA256) == 64L)
  payload <- list(
    Contract = "gtheory_multivariate_backend_environment_draft85c4e_v1",
    C3EnvironmentSnapshot = c3_snapshot,
    C3EnvironmentSnapshotHash = c3_snapshot$SnapshotHash,
    PackageRegistry = package_registry,
    PackageRegistryHash = mfrmr_gtvl_hash(package_registry),
    LoadedGlmmTMBBuildTMBVersion = loaded_build_tmb,
    GlmmTMBABIVersion = abi_version,
    RequiredBackendRoutes = c(
      "lme4_ml", "lme4_reml", "glmmTMB_ml", "glmmTMB_reml"
    ),
    ConQuestRouteIncluded = FALSE
  )
  build_identity_matches <- identical(
    c3_snapshot$GlmmTMBBuildTMBVersion, loaded_build_tmb
  )
  eligible <- c3_snapshot$EnvironmentReadyForBackendQualification &&
    build_identity_matches &&
    native_ready && !is.na(abi_version) && nzchar(abi_version)
  structure(c(payload, list(
    EnvironmentIdentityHash = mfrmr_gtvl_hash(payload),
    RequiredPackagesAvailable = c3_snapshot$RequiredPackagesAvailable,
    DependencyABIMatch = c3_snapshot$DependencyABIMatch,
    BuildIdentityMatchesLoadedNamespace = build_identity_matches,
    NativeBinaryIdentityReady = native_ready,
    QualificationEnvironmentEligible = eligible,
    DiagnosticOverrideAllowed = FALSE,
    RepairRequired = !eligible,
    RepairExecuted = FALSE,
    BackendExecutionOccurred = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvl_environment", "list"))
}

mfrmr_gtvl_assert_environment_identity <- function(identity) {
  payload_fields <- c(
    "Contract", "C3EnvironmentSnapshot", "C3EnvironmentSnapshotHash",
    "PackageRegistry", "PackageRegistryHash",
    "LoadedGlmmTMBBuildTMBVersion", "GlmmTMBABIVersion",
    "RequiredBackendRoutes", "ConQuestRouteIncluded"
  )
  suffix_fields <- c(
    "EnvironmentIdentityHash", "RequiredPackagesAvailable",
    "DependencyABIMatch", "BuildIdentityMatchesLoadedNamespace",
    "NativeBinaryIdentityReady",
    "QualificationEnvironmentEligible", "DiagnosticOverrideAllowed",
    "RepairRequired", "RepairExecuted", "BackendExecutionOccurred",
    "PublicSupportReady"
  )
  if (!mfrmr_gtvl_exact_object(
    identity, c(payload_fields, suffix_fields),
    c("mfrmr_gtvl_environment", "list")
  )) {
    stop("A typed Draft.85c4e environment identity is required.",
         call. = FALSE)
  }
  expected <- mfrmr_gtvl_environment_identity(
    identity$C3EnvironmentSnapshot, identity$PackageRegistry
  )
  if (!identical(identity, expected)) {
    stop("The Draft.85c4e environment identity or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvl_repair_plan <- function(environment_identity) {
  mfrmr_gtvl_assert_environment_identity(environment_identity)
  data.frame(
    StepOrdinal = 1:6,
    StepId = c(
      "isolated_library_created", "package_sources_pinned",
      "selected_tmb_installed", "glmmtmb_rebuilt_against_selected_tmb",
      "fresh_process_identity_reobserved",
      "four_route_receipts_completed"
    ),
    RequiredEvidence = c(
      "IsolatedLibraryIdentity", "PackageSourceArtifactRegistry",
      "SelectedTMBInstallReceipt", "GlmmTMBRebuildReceipt",
      "FreshProcessEnvironmentIdentity", "QualificationReceiptRegistry"
    ),
    CurrentSatisfied = rep(FALSE, 6L),
    MutatingActionExecuted = rep(FALSE, 6L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvl_route_registry <- function(environment_identity) {
  mfrmr_gtvl_assert_environment_identity(environment_identity)
  data.frame(
    RouteOrdinal = 1:4,
    RouteId = environment_identity$RequiredBackendRoutes,
    Backend = rep(c("lme4", "glmmTMB"), each = 2L),
    Criterion = rep(c("ML", "REML"), 2L),
    RequiresSharedABIMatch = c(FALSE, FALSE, TRUE, TRUE),
    EnvironmentEligible = rep(
      environment_identity$QualificationEnvironmentEligible, 4L
    ),
    RouteReceiptReady = rep(FALSE, 4L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvl_qualification_receipt_template <- function(
    environment_identity, route_registry =
      mfrmr_gtvl_route_registry(environment_identity)) {
  mfrmr_gtvl_assert_environment_identity(environment_identity)
  if (!identical(route_registry, mfrmr_gtvl_route_registry(
    environment_identity
  ))) {
    stop("The Draft.85c4e route registry was altered.", call. = FALSE)
  }
  data.frame(
    RouteOrdinal = route_registry$RouteOrdinal,
    RouteId = route_registry$RouteId,
    EnvironmentIdentityHash = rep(
      environment_identity$EnvironmentIdentityHash, 4L
    ),
    QualificationReceiptId = rep(NA_character_, 4L),
    FitSpecificationHash = rep(NA_character_, 4L),
    FitResultHash = rep(NA_character_, 4L),
    FreshProcess = rep(FALSE, 4L),
    DiagnosticOverrideUsed = rep(NA, 4L),
    ReceiptReady = rep(FALSE, 4L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvl_implementation_identity <- function() {
  function_names <- c(
    "mfrmr_gtvl_require_primitives", "mfrmr_gtvl_hash",
    "mfrmr_gtvl_exact_object", "mfrmr_gtvl_file_hash",
    "mfrmr_gtvl_package_registry", "mfrmr_gtvl_assert_package_registry",
    "mfrmr_gtvl_environment_identity",
    "mfrmr_gtvl_assert_environment_identity", "mfrmr_gtvl_repair_plan",
    "mfrmr_gtvl_route_registry",
    "mfrmr_gtvl_qualification_receipt_template",
    "mfrmr_gtvl_implementation_identity", "mfrmr_gtvl_manifest",
    "mfrmr_gtvl_assert_manifest", "mfrmr_gtvl_dispatch_guard"
  )
  target <- environment(mfrmr_gtvl_implementation_identity)
  data.frame(
    Function = function_names,
    SHA256 = vapply(function_names, function(name) {
      if (!exists(name, envir = target, inherits = FALSE)) {
        stop("A Draft.85c4e implementation function is missing: ", name,
             ".", call. = FALSE)
      }
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtvl_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvl_manifest <- function(
    repo_root = ".",
    environment_identity = mfrmr_gtvl_environment_identity()) {
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  mfrmr_gtvl_assert_environment_identity(environment_identity)
  current_environment <- mfrmr_gtvl_environment_identity(
    mfrmr_gtvf_environment_snapshot(), mfrmr_gtvl_package_registry()
  )
  mfrmr_gtvl_assert_environment_identity(current_environment)
  matches_current <- identical(environment_identity, current_environment)
  matched_backend_source <- file.path(
    repo_root, "inst", "validation",
    "gtheory-multivariate-matched-backend-prototype-0.2.4.R"
  )
  upstream <- data.frame(
    RootOrdinal = 1:4,
    RootId = c(
      "c1_plan", "c3_admission", "c4d_source_freeze_admission",
      "c4d_candidate_artifact"
    ),
    SHA256 = c(
      "51f6d05a596cf05157b7599f48f29c144038e23b89cad045c47d8560d370cac2",
      "e1c7285018d814ac5332adb94f780e73410f70120cd079ca282d889935ea3b02",
      "495e65541057d684558d63a166ff20ba38b83e729c822411442fb091fea25661",
      "76a208fab44f87fcd723a0c9d390de23c6ac1eba5da2e31490de6010951f5c57"
    ),
    stringsAsFactors = FALSE
  )
  repair_plan <- mfrmr_gtvl_repair_plan(current_environment)
  routes <- mfrmr_gtvl_route_registry(current_environment)
  receipts <- mfrmr_gtvl_qualification_receipt_template(
    current_environment, routes
  )
  implementation <- mfrmr_gtvl_implementation_identity()
  payload <- list(
    Contract =
      "gtheory_multivariate_backend_qualification_admission_draft85c4e_v1",
    UpstreamRootRegistry = upstream,
    UpstreamRootRegistryHash = mfrmr_gtvl_hash(upstream),
    MatchedBackendSourceSHA256 = mfrmr_gtvl_file_hash(
      matched_backend_source
    ),
    SuppliedEnvironmentIdentity = environment_identity,
    SuppliedEnvironmentIdentityHash =
      environment_identity$EnvironmentIdentityHash,
    CurrentEnvironmentIdentity = current_environment,
    CurrentEnvironmentIdentityHash =
      current_environment$EnvironmentIdentityHash,
    RepairPlan = repair_plan,
    RepairPlanHash = mfrmr_gtvl_hash(repair_plan),
    QualificationRouteRegistry = routes,
    QualificationRouteRegistryHash = mfrmr_gtvl_hash(routes),
    QualificationReceiptTemplate = receipts,
    QualificationReceiptTemplateHash = mfrmr_gtvl_hash(receipts),
    ImplementationIdentity = implementation,
    ImplementationIdentityHash = mfrmr_gtvl_hash(implementation),
    PlannedSeedMaterialIncluded = FALSE,
    ConQuestRouteIncluded = FALSE
  )
  current_eligible <- current_environment$QualificationEnvironmentEligible
  structure(c(payload, list(
    ManifestHash = mfrmr_gtvl_hash(payload),
    SourceFreezeAdmissionBound = TRUE,
    CleanSourceIdentityReady = FALSE,
    ExternalFreezeReady = FALSE,
    EnvironmentIdentityMatchesCurrentProcess = matches_current,
    CandidateEnvironmentEligible =
      environment_identity$QualificationEnvironmentEligible,
    RequiredPackagesAvailable =
      current_environment$RequiredPackagesAvailable,
    DependencyABIMatch = current_environment$DependencyABIMatch,
    BuildIdentityMatchesLoadedNamespace =
      current_environment$BuildIdentityMatchesLoadedNamespace,
    NativeBinaryIdentityReady =
      current_environment$NativeBinaryIdentityReady,
    EnvironmentReadyForBackendQualification =
      matches_current && current_eligible,
    RepairPlanConstructed = TRUE,
    RepairRequired = current_environment$RepairRequired,
    RepairExecuted = FALSE,
    AllRouteReceiptsReady = all(receipts$ReceiptReady),
    BackendQualificationAdmissionReady =
      matches_current && current_eligible && all(receipts$ReceiptReady),
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
  )), class = c("mfrmr_gtvl_manifest", "list"))
}

mfrmr_gtvl_assert_manifest <- function(
    manifest, repo_root = ".",
    environment_identity = mfrmr_gtvl_environment_identity()) {
  canonical <- mfrmr_gtvl_manifest(repo_root, environment_identity)
  if (!mfrmr_gtvl_exact_object(
    manifest, names(canonical), class(canonical)
  ) || !identical(manifest, canonical)) {
    stop("The Draft.85c4e qualification manifest or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvl_dispatch_guard <- function(
    manifest, action, callback, ..., authorize = FALSE, repo_root = ".",
    environment_identity = mfrmr_gtvl_environment_identity()) {
  mfrmr_gtvl_assert_manifest(manifest, repo_root, environment_identity)
  if (!is.character(action) || length(action) != 1L || is.na(action) ||
      !action %in% c("environment_repair", "route_qualification")) {
    stop("The Draft.85c4e action is outside the admission contract.",
         call. = FALSE)
  }
  if (!is.function(callback)) {
    stop("`callback` must be a function.", call. = FALSE)
  }
  if (!is.logical(authorize) || length(authorize) != 1L || is.na(authorize)) {
    stop("`authorize` must be TRUE or FALSE.", call. = FALSE)
  }
  stop(
    "Draft.85c4e cannot repair or fit a backend; execution remains closed.",
    call. = FALSE
  )
}
