# Draft.85c4n planned-adapter capability isolation.
#
# Repository-internal only. This layer reruns the exact three Draft.85c4m
# non-attempt requests in fresh default-deny macOS processes and exercises six
# negative controls. It qualifies that deliberately narrow adapter surface; it
# does not qualify a fit-capable truth-blind study process.

mfrmr_gtvu_require_primitives <- function() {
  required <- c(
    "mfrmr_gtvt_assert_manifest", "mfrmr_gtvt_request",
    "mfrmr_gtvt_worker_receipt", "mfrmr_gtvt_hash"
  )
  target <- environment(mfrmr_gtvu_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the Draft.85c4m chain before Draft.85c4n: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtvu_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4n requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvu_file_hash <- function(path) {
  path <- normalizePath(path, mustWork = TRUE)
  if (dir.exists(path)) {
    stop("A Draft.85c4n runtime file is required.", call. = FALSE)
  }
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtvu_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    identical(sort(names(attributes(object))), c("class", "names"))
}

mfrmr_gtvu_function_hash <- function(fun) {
  if (!is.function(fun)) {
    stop("A Draft.85c4n implementation function is missing.", call. = FALSE)
  }
  mfrmr_gtvu_hash(list(
    Formals = paste(deparse(formals(fun), width.cutoff = 500L),
                    collapse = "\n"),
    Body = paste(deparse(body(fun), width.cutoff = 500L), collapse = "\n")
  ))
}

mfrmr_gtvu_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtvu_require_primitives", "mfrmr_gtvu_hash",
    "mfrmr_gtvu_file_hash", "mfrmr_gtvu_exact_object",
    "mfrmr_gtvu_function_hash", "mfrmr_gtvu_implementation_identity",
    "mfrmr_gtvu_capability_worker_identity", "mfrmr_gtvu_quote_profile",
    "mfrmr_gtvu_runtime_identity", "mfrmr_gtvu_staging",
    "mfrmr_gtvu_requests", "mfrmr_gtvu_policy_text",
    "mfrmr_gtvu_policy_audit", "mfrmr_gtvu_synthetic_vault",
    "mfrmr_gtvu_worker_payload_fields", "mfrmr_gtvu_assert_worker_result",
    "mfrmr_gtvu_invoke", "mfrmr_gtvu_prerequisite_projection",
    "mfrmr_gtvu_payload_fields", "mfrmr_gtvu_assert_evidence",
    "mfrmr_gtvu_live_preflight", "mfrmr_gtvu_dispatch_guard"
  )
  target <- environment(mfrmr_gtvu_implementation_identity)
  data.frame(
    Function = functions,
    SHA256 = vapply(functions, function(name) {
      if (!exists(name, envir = target, inherits = FALSE)) {
        stop("A Draft.85c4n function is missing: ", name, ".",
             call. = FALSE)
      }
      mfrmr_gtvu_function_hash(get(name, envir = target, inherits = FALSE))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvu_capability_worker_identity <- function(worker_environment) {
  functions <- c(
    "mfrmr_gtvuw_hash", "mfrmr_gtvuw_attempt", "mfrmr_gtvuw_probe",
    "mfrmr_gtvuw_run_adapter", "mfrmr_gtvuw_main"
  )
  if (!is.environment(worker_environment) ||
      !identical(parent.env(worker_environment), baseenv()) ||
      !identical(
        sort(ls(worker_environment, all.names = TRUE), method = "radix"),
        sort(functions, method = "radix")
      ) || !all(vapply(functions, function(name) {
        is.function(get(name, envir = worker_environment, inherits = FALSE))
      }, logical(1L)))) {
    stop("The Draft.85c4n capability-worker namespace was altered.",
         call. = FALSE)
  }
  data.frame(
    Function = functions,
    SHA256 = vapply(functions, function(name) {
      mfrmr_gtvu_function_hash(get(
        name, envir = worker_environment, inherits = FALSE
      ))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvu_quote_profile <- function(path) {
  encodeString(normalizePath(path, mustWork = FALSE), quote = "\"")
}

mfrmr_gtvu_runtime_identity <- function(
    c4m_manifest, validation_dir = file.path("inst", "validation")) {
  validation_dir <- normalizePath(validation_dir, mustWork = TRUE)
  sandbox_exec <- normalizePath("/usr/bin/sandbox-exec", mustWork = TRUE)
  environment_exec <- normalizePath("/usr/bin/env", mustWork = TRUE)
  r_home <- normalizePath(R.home(), mustWork = TRUE)
  r_exec <- normalizePath(file.path(r_home, "bin", "exec", "R"),
                          mustWork = TRUE)
  system_profile <- normalizePath(
    "/System/Library/Sandbox/Profiles/system.sb", mustWork = TRUE
  )
  adapter_worker <- normalizePath(file.path(
    validation_dir, "gtheory-multivariate-planned-adapter-worker-0.2.4.R"
  ), mustWork = TRUE)
  capability_worker <- normalizePath(file.path(
    validation_dir,
    "gtheory-multivariate-planned-adapter-capability-worker-0.2.4.R"
  ), mustWork = TRUE)
  adapter_hash <- mfrmr_gtvu_file_hash(adapter_worker)
  capability_hash <- mfrmr_gtvu_file_hash(capability_worker)
  if (!identical(adapter_hash, c4m_manifest$WorkerSourceSHA256)) {
    stop("The exact Draft.85c4m adapter worker changed.", call. = FALSE)
  }
  digest_path <- normalizePath(find.package("digest"), mustWork = TRUE)
  description_path <- file.path(digest_path, "DESCRIPTION")
  native_paths <- sort(list.files(
    file.path(digest_path, "libs"), pattern = "\\.(so|dylib)$",
    full.names = TRUE
  ), method = "radix")
  native_registry <- data.frame(
    FileName = basename(native_paths),
    Path = vapply(native_paths, normalizePath, character(1L), mustWork = TRUE),
    SHA256 = vapply(native_paths, mfrmr_gtvu_file_hash, character(1L)),
    stringsAsFactors = FALSE
  )
  traversal_sources <- c(digest_path, native_registry$Path)
  traversal_paths <- sort(unique(unlist(lapply(
    traversal_sources, function(path) {
      current <- dirname(path)
      chain <- character()
      while (!identical(current, dirname(current))) {
        chain <- c(chain, current)
        current <- dirname(current)
      }
      c(chain, current)
    }
  ), use.names = FALSE)), method = "radix")
  payload <- list(
    Contract = "gtheory_multivariate_c4n_runtime_identity_v1",
    OS = Sys.info()[["sysname"]],
    OSRelease = Sys.info()[["release"]],
    OSVersion = Sys.info()[["version"]],
    Machine = Sys.info()[["machine"]],
    RVersion = R.version.string,
    RuntimeLocale = "C.UTF-8",
    SandboxExecutable = sandbox_exec,
    SandboxExecutableHash = mfrmr_gtvu_file_hash(sandbox_exec),
    EnvironmentExecutable = environment_exec,
    EnvironmentExecutableHash = mfrmr_gtvu_file_hash(environment_exec),
    RHome = r_home,
    RExecutable = r_exec,
    RExecutableHash = mfrmr_gtvu_file_hash(r_exec),
    SystemProfile = system_profile,
    SystemProfileHash = mfrmr_gtvu_file_hash(system_profile),
    ValidationDirectory = validation_dir,
    AdapterWorkerPath = adapter_worker,
    AdapterWorkerHash = adapter_hash,
    CapabilityWorkerPath = capability_worker,
    CapabilityWorkerHash = capability_hash,
    DigestPackagePath = digest_path,
    DigestVersion = as.character(utils::packageVersion("digest")),
    DigestDescriptionHash = mfrmr_gtvu_file_hash(description_path),
    DigestNativeRegistry = native_registry,
    DigestNativeRegistryHash = mfrmr_gtvu_hash(native_registry),
    TraversalReadPaths = traversal_paths,
    TraversalReadPathsHash = mfrmr_gtvu_hash(traversal_paths)
  )
  structure(c(payload, list(
    RuntimeIdentityHash = mfrmr_gtvu_hash(payload)
  )), class = c("mfrmr_gtvu_runtime", "list"))
}

mfrmr_gtvu_staging <- function(root, create = TRUE) {
  if (!is.logical(create) || length(create) != 1L || is.na(create)) {
    stop("`create` must be TRUE or FALSE.", call. = FALSE)
  }
  root <- normalizePath(root, mustWork = isTRUE(create))
  paths <- list(
    Root = root,
    AllowedRoot = file.path(root, "allowed"),
    DeniedRoot = file.path(root, "denied")
  )
  if (!isTRUE(create)) {
    paths <- c(paths, list(
      Input = file.path(paths$AllowedRoot, "input"),
      Worker = file.path(paths$AllowedRoot, "worker"),
      RuntimeLibrary = file.path(paths$AllowedRoot, "runtime-library"),
      Output = file.path(paths$AllowedRoot, "output"),
      Scratch = file.path(paths$AllowedRoot, "scratch"),
      Vault = file.path(paths$DeniedRoot, "protected-vault"),
      ForbiddenOutput = file.path(paths$DeniedRoot, "forbidden-output")
    ))
    return(lapply(paths, normalizePath, mustWork = FALSE))
  }
  if (!all(vapply(paths[-1L], dir.create, logical(1L), recursive = FALSE))) {
    stop("Draft.85c4n could not create staging roots.", call. = FALSE)
  }
  paths <- c(paths, list(
    Input = file.path(paths$AllowedRoot, "input"),
    Worker = file.path(paths$AllowedRoot, "worker"),
    RuntimeLibrary = file.path(paths$AllowedRoot, "runtime-library"),
    Output = file.path(paths$AllowedRoot, "output"),
    Scratch = file.path(paths$AllowedRoot, "scratch"),
    Vault = file.path(paths$DeniedRoot, "protected-vault"),
    ForbiddenOutput = file.path(paths$DeniedRoot, "forbidden-output")
  ))
  children <- setdiff(names(paths), c("Root", "AllowedRoot", "DeniedRoot"))
  if (!all(vapply(paths[children], dir.create, logical(1L),
                  recursive = FALSE))) {
    stop("Draft.85c4n could not create staging children.", call. = FALSE)
  }
  lapply(paths, normalizePath, mustWork = TRUE)
}

mfrmr_gtvu_requests <- function(plan, c4l_receipt) {
  stage_ids <- plan$StageCatalog$StageId
  requests <- setNames(lapply(stage_ids, function(stage_id) {
    mfrmr_gtvt_request(
      plan, stage_id, c4l_receipt$ReceiptHash,
      c4l_receipt$QualificationRouteRegistryHash
    )
  }), stage_ids)
  requests
}

mfrmr_gtvu_policy_text <- function(runtime, staging) {
  if (!inherits(runtime, "mfrmr_gtvu_runtime")) {
    stop("A typed Draft.85c4n runtime identity is required.", call. = FALSE)
  }
  q <- mfrmr_gtvu_quote_profile
  r_framework <- normalizePath(
    file.path(runtime$RHome, "..", "..", ".."), mustWork = TRUE
  )
  traversal_rules <- paste0("  (literal ", vapply(
    runtime$TraversalReadPaths, q, character(1L)
  ), ")")
  lines <- c(
    "(version 1)", "(deny default)", "(import \"system.sb\")",
    "(allow process-fork)",
    "(allow process-exec",
    paste0("  (literal ", q(runtime$EnvironmentExecutable), ")"),
    paste0("  (literal ", q(runtime$RExecutable), ")"),
    "  (literal \"/bin/sh\")",
    "  (literal \"/bin/bash\")",
    "  (literal \"/bin/rm\"))",
    "(allow file-read* file-map-executable",
    paste0("  (subpath ", q(r_framework), ")"),
    "  (subpath \"/bin\")",
    "  (subpath \"/usr/lib\")",
    "  (subpath \"/System/Library\"))",
    "(allow file-read-metadata file-test-existence",
    "  (literal \"/\")",
    "  (literal \"/private\")",
    "  (literal \"/private/tmp\")",
    "  (subpath \"/Library\")",
    "  (subpath \"/private/tmp\")",
    "  (subpath \"/opt/homebrew\")",
    paste0("  (literal ", q(staging$Root), ")"),
    paste0("  (literal ", q(staging$AllowedRoot), ")"),
    paste0("  (literal ", q(staging$RuntimeLibrary), ")"),
    paste0("  (subpath ", q(staging$AllowedRoot), "))"),
    "(allow file-read*",
    "  (literal \"/private/var/select/sh\")",
    traversal_rules,
    paste0("  (literal ", q(staging$Root), ")"),
    paste0("  (subpath ", q(staging$AllowedRoot), "))"),
    "(allow file-write*",
    paste0("  (subpath ", q(staging$Output), ")"),
    paste0("  (subpath ", q(staging$Scratch), "))")
  )
  paste(lines, collapse = "\n")
}

mfrmr_gtvu_policy_audit <- function(profile_text, runtime, staging) {
  q <- mfrmr_gtvu_quote_profile
  data.frame(
    Rule = c(
      "version_one", "default_deny", "system_profile_import",
      "no_allow_default", "no_network_allow", "no_vault_path",
      "no_forbidden_output_path", "no_denied_root_path",
      "no_repository_path", "all_runtime_traversal_literals",
      "root_traversal_literal_read", "allowed_root_read", "input_allow",
      "worker_allow", "runtime_library_allow", "output_allow",
      "scratch_allow", "sanitized_env_exec_allow", "r_exec_allow",
      "exact_digest_target_bound", "exact_staging_metadata_traversal"
    ),
    Passed = c(
      grepl("\\(version 1\\)", profile_text),
      grepl("\\(deny default\\)", profile_text),
      grepl("\\(import \\\"system\\.sb\\\"\\)", profile_text),
      !grepl("\\(allow default\\)", profile_text),
      !grepl("allow network", profile_text),
      !grepl(staging$Vault, profile_text, fixed = TRUE),
      !grepl(staging$ForbiddenOutput, profile_text, fixed = TRUE),
      !grepl(staging$DeniedRoot, profile_text, fixed = TRUE),
      !grepl(runtime$ValidationDirectory, profile_text, fixed = TRUE),
      all(vapply(runtime$TraversalReadPaths, function(path) {
        grepl(paste0("(literal ", q(path), ")"),
              profile_text, fixed = TRUE)
      }, logical(1L))),
      grepl(paste0("(literal ", q(staging$Root), ")"),
            profile_text, fixed = TRUE),
      grepl(staging$AllowedRoot, profile_text, fixed = TRUE),
      startsWith(staging$Input, paste0(
        staging$AllowedRoot, .Platform$file.sep
      )),
      startsWith(staging$Worker, paste0(
        staging$AllowedRoot, .Platform$file.sep
      )),
      startsWith(staging$RuntimeLibrary, paste0(
        staging$AllowedRoot, .Platform$file.sep
      )),
      grepl(staging$Output, profile_text, fixed = TRUE),
      grepl(staging$Scratch, profile_text, fixed = TRUE),
      grepl(runtime$EnvironmentExecutable, profile_text, fixed = TRUE),
      grepl(runtime$RExecutable, profile_text, fixed = TRUE),
      startsWith(runtime$DigestPackagePath, normalizePath(
        file.path(runtime$RHome), mustWork = TRUE
      )),
      all(vapply(c(
        "/", "/private", "/private/tmp", staging$Root,
        staging$AllowedRoot, staging$RuntimeLibrary
      ), function(path) {
        grepl(paste0("(literal ", q(path), ")"),
              profile_text, fixed = TRUE)
      }, logical(1L)))
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvu_synthetic_vault <- function(requests) {
  list(
    Contract = "gtheory_multivariate_c4n_synthetic_denied_vault_v1",
    RequestHashes = vapply(requests, `[[`, character(1L), "RequestHash"),
    SyntheticForbiddenToken = mfrmr_gtvu_hash(list(
      Namespace = "gtheory_multivariate_c4n_denied_token_v1",
      RequestHashes = vapply(requests, `[[`, character(1L), "RequestHash")
    )),
    ContainsScenarioIdentity = FALSE,
    ContainsPlannedSeed = FALSE,
    ContainsReferenceIdentity = FALSE,
    ContainsTruth = FALSE,
    ContainsAccuracyThreshold = FALSE,
    ContainsCandidateData = FALSE
  )
}

mfrmr_gtvu_worker_payload_fields <- function() {
  c(
    "Contract", "Mode", "RunToken", "RequestHash", "OpaqueRequestId",
    "LaneOpaqueId", "AdapterWorkerSourceSHA256",
    "CapabilityWorkerSourceSHA256", "EnvironmentNames",
    "EnvironmentNamesHash", "ParentSecretVisible", "ActionSucceeded",
    "ActionMessage", "AdapterReceipt", "AdapterReceiptHash", "ControlPassed"
  )
}

mfrmr_gtvu_assert_worker_result <- function(
    result, expected_mode, request, runtime, adapter_worker_environment) {
  payload_fields <- mfrmr_gtvu_worker_payload_fields()
  suffix_fields <- c(
    "ResultHash", "WorkerSelfReported", "ProcessCapabilityIsolationReady",
    "TruthBlindProcessBoundaryReady", "CandidateExecutionAuthorized",
    "CandidateExecutionOccurred", "CandidateCompletionSealed",
    "TruthReleaseAuthorized", "BackendExecutionOccurred",
    "PlannedResponseGenerated", "RecoveryEvidenceReady", "EstimationReady",
    "InferenceReady", "DecisionReady", "PublicSupportReady"
  )
  if (!mfrmr_gtvu_exact_object(
    result, c(payload_fields, suffix_fields),
    c("mfrmr_gtvuw_result", "list")
  )) {
    stop("A typed Draft.85c4n worker result is required.", call. = FALSE)
  }
  normal <- startsWith(expected_mode, "normal_")
  closed <- suffix_fields[-c(1L, 2L)]
  valid <- identical(
    result$Contract,
    "gtheory_multivariate_planned_adapter_capability_worker_draft85c4n_v1"
  ) && identical(result$Mode, expected_mode) &&
    grepl("^C4N-[0-9a-f]{24}$", result$RunToken) &&
    identical(result$RequestHash, request$RequestHash) &&
    identical(result$OpaqueRequestId, request$OpaqueRequestId) &&
    identical(result$LaneOpaqueId, request$LaneOpaqueId) &&
    identical(result$AdapterWorkerSourceSHA256,
              runtime$AdapterWorkerHash) &&
    identical(result$CapabilityWorkerSourceSHA256,
              runtime$CapabilityWorkerHash) &&
    identical(result$EnvironmentNamesHash,
              mfrmr_gtvu_hash(result$EnvironmentNames)) &&
    !isTRUE(result$ParentSecretVisible) &&
    identical(isTRUE(result$ActionSucceeded), normal) &&
    isTRUE(result$ControlPassed) &&
    identical(result$ResultHash, mfrmr_gtvu_hash(result[payload_fields])) &&
    isTRUE(result$WorkerSelfReported) &&
    !isTRUE(result$ProcessCapabilityIsolationReady) &&
    !isTRUE(result$TruthBlindProcessBoundaryReady) &&
    !any(vapply(result[closed], isTRUE, logical(1L)))
  if (normal) {
    expected_receipt <- mfrmr_gtvt_worker_receipt(
      request, adapter_worker_environment
    )
    valid <- valid && identical(result$AdapterReceipt, expected_receipt) &&
      identical(result$AdapterReceiptHash, expected_receipt$ReceiptHash)
  } else {
    valid <- valid && is.null(result$AdapterReceipt) &&
      is.na(result$AdapterReceiptHash)
  }
  if (!valid) {
    stop("The Draft.85c4n worker result or receipt changed.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvu_invoke <- function(
    runtime, staging, profile_path, capability_worker_path,
    adapter_worker_path, request_path, mode, target, run_token) {
  output_path <- file.path(staging$Output, paste0(mode, ".rds"))
  arguments <- c(
    "-f", shQuote(profile_path),
    shQuote(runtime$EnvironmentExecutable), "-i",
    paste0("R_HOME=", shQuote(runtime$RHome)),
    paste0("R_LIBS_USER=", shQuote(staging$RuntimeLibrary)),
    paste0("TMPDIR=", shQuote(staging$Scratch)),
    "PATH=/usr/bin:/bin",
    paste0("LANG=", runtime$RuntimeLocale),
    paste0("LC_ALL=", runtime$RuntimeLocale), "TZ=UTC",
    shQuote(runtime$RExecutable), "--vanilla", "--slave",
    paste0("--file=", shQuote(capability_worker_path)), "--args",
    shQuote(mode), shQuote(adapter_worker_path), shQuote(request_path),
    shQuote(output_path), shQuote(target), shQuote(run_token),
    shQuote(runtime$AdapterWorkerHash), shQuote(runtime$CapabilityWorkerHash)
  )
  old_working_directory <- getwd()
  on.exit(setwd(old_working_directory), add = TRUE)
  setwd(staging$Scratch)
  output <- suppressWarnings(system2(
    runtime$SandboxExecutable, arguments, stdout = TRUE, stderr = TRUE
  ))
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  list(
    Status = as.integer(status), Output = as.character(output),
    OutputPath = output_path, OutputExists = file.exists(output_path)
  )
}

mfrmr_gtvu_prerequisite_projection <- function(c4m_manifest) {
  prior <- c4m_manifest$PrerequisiteProjection
  truth_index <- match("truth_blind_process_boundary", prior$PrerequisiteId)
  if (!is.data.frame(prior) || is.na(truth_index) ||
      !identical(sum(prior$C4MProjectedSatisfied), 2L) ||
      isTRUE(prior$C4MProjectedSatisfied[[truth_index]])) {
    stop("The Draft.85c4m prerequisite state is not canonical for c4n.",
         call. = FALSE)
  }
  evidence_state <- prior$EvidenceState
  evidence_state[[truth_index]] <- paste0(
    "non_attempt_adapter_process_isolated_",
    "fit_capable_truth_blind_boundary_missing"
  )
  data.frame(
    PrerequisiteOrdinal = prior$PrerequisiteOrdinal,
    PrerequisiteId = prior$PrerequisiteId,
    Requirement = prior$Requirement,
    C4MProjectedSatisfied = prior$C4MProjectedSatisfied,
    C4NProjectedSatisfied = prior$C4MProjectedSatisfied,
    TransitionedByC4N = rep(FALSE, nrow(prior)),
    PartialExecutionAllowed = prior$PartialExecutionAllowed,
    EvidenceState = evidence_state,
    AdapterSchemaEvidenceAvailable = prior$AdapterSchemaEvidenceAvailable,
    PlannedAdapterCapabilityEvidenceAvailable =
      seq_len(nrow(prior)) == truth_index,
    FitCapableTruthBlindBoundaryEvidenceAvailable = rep(FALSE, nrow(prior)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvu_payload_fields <- function() {
  c(
    "Contract", "PlanHash", "C4MManifestHash", "C4LReceiptHash",
    "C4LQualificationRouteRegistryHash", "RuntimeIdentity",
    "RuntimeIdentityHash", "StagedRuntimeRegistry",
    "StagedRuntimeRegistryHash", "ProfileHash", "ProfileSemanticHash",
    "PolicyAudit", "PolicyAuditHash", "ControlRegistry",
    "ControlRegistryHash", "ControlResults", "ControlResultsHash",
    "NormalReceiptRegistry", "NormalReceiptRegistryHash",
    "SyntheticVaultHash", "CapabilityWorkerIdentity",
    "CapabilityWorkerIdentityHash", "PrerequisiteProjection",
    "PrerequisiteProjectionHash", "ImplementationIdentity",
    "ImplementationIdentityHash", "StagingContentRetained",
    "CandidateDataIncluded", "PlannedSeedMaterialIncluded",
    "ScenarioIdentityIncluded", "ReferenceIdentityIncluded",
    "ReferenceTruthIncluded", "AccuracyThresholdIncluded",
    "ConQuestRouteIncluded"
  )
}

mfrmr_gtvu_assert_evidence <- function(
    evidence, plan, generator_manifest, c3_manifest, c4e_manifest,
    c4f_manifest, repair_receipt, qualification_receipt,
    capability_evidence, c4l_receipt, c4m_manifest,
    repair_worker_environment, qualification_worker_environment,
    capability_worker_environment, adapter_worker_environment,
    c4n_capability_worker_environment, repo_root = ".",
    validation_dir = file.path("inst", "validation")) {
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  validation_dir <- normalizePath(validation_dir, mustWork = TRUE)
  mfrmr_gtvt_assert_manifest(
    c4m_manifest, plan, generator_manifest, c3_manifest, c4e_manifest,
    c4f_manifest, repair_receipt, qualification_receipt,
    capability_evidence, c4l_receipt, repair_worker_environment,
    qualification_worker_environment, capability_worker_environment,
    adapter_worker_environment, repo_root, validation_dir
  )
  payload_fields <- mfrmr_gtvu_payload_fields()
  suffix_fields <- c(
    "EvidenceHash", "DefaultDenyProfileReady", "SanitizedEnvironmentReady",
    "ExactDigestRuntimeReady", "ThreeLaneFreshProcessReceiptsReady",
    "SyntheticProtectedVaultReadDenied", "RepositoryReadDenied",
    "OutsideWriteDenied", "ParentEnvironmentSecretAbsent",
    "UnlistedExecutableDenied", "ExternalNetworkDenied",
    "PayloadTruthBlindReady", "BackendQualificationReady",
    "PlannedAdapterProcessCapabilityIsolationReady",
    "ProcessCapabilityIsolationReady", "TruthBlindProcessBoundaryReady",
    "PlannedExecutionIsolationReady",
    "ExactlyZeroC3PrerequisitesTransitioned",
    "C3SatisfiedPrerequisiteCount", "AllExecutionPrerequisitesReady",
    "ExternalFreezeReady", "CleanSourceIdentityReady",
    "IndependentAccuracyRuleReady", "PilotExecutionAuthorized",
    "ConfirmationExecutionAuthorized", "NegativeControlExecutionAuthorized",
    "ExecutionGateClosed", "AdapterBackendExecutionOccurred",
    "CandidateExecutionOccurred", "CandidateCompletionSealed",
    "TruthReleaseAuthorized", "DenominatorAccountingReady",
    "PlannedResponseGenerated", "RecoveryExecuted", "RecoveryEvidenceReady",
    "EstimationReady", "InferenceReady", "DecisionReady",
    "PublicSupportReady"
  )
  if (!mfrmr_gtvu_exact_object(
    evidence, c(payload_fields, suffix_fields),
    c("mfrmr_gtvu_evidence", "list")
  )) {
    stop("A typed Draft.85c4n evidence object is required.", call. = FALSE)
  }
  runtime <- mfrmr_gtvu_runtime_identity(c4m_manifest, validation_dir)
  requests <- mfrmr_gtvu_requests(plan, c4l_receipt)
  expected_root <- file.path("/private/tmp", paste0("mfrmr-c4n-", substr(
    mfrmr_gtvu_hash(list(
      Namespace = "gtheory_multivariate_c4n_staging_v1",
      C4MManifestHash = c4m_manifest$ManifestHash,
      RuntimeIdentityHash = runtime$RuntimeIdentityHash
    )), 1L, 16L
  )))
  expected_staging <- mfrmr_gtvu_staging(expected_root, create = FALSE)
  expected_staged_runtime <- data.frame(
    PackageOrdinal = 1L,
    Package = "digest",
    StagedPath = file.path(expected_staging$RuntimeLibrary, "digest"),
    OriginPath = runtime$DigestPackagePath,
    Version = runtime$DigestVersion,
    DescriptionSHA256 = runtime$DigestDescriptionHash,
    NativeRegistryHash = runtime$DigestNativeRegistryHash,
    stringsAsFactors = FALSE
  )
  expected_profile <- mfrmr_gtvu_policy_text(runtime, expected_staging)
  expected_profile_semantic <- gsub(
    expected_staging$Root, "<STAGING_ROOT>", expected_profile, fixed = TRUE
  )
  expected_policy_audit <- mfrmr_gtvu_policy_audit(
    expected_profile, runtime, expected_staging
  )
  expected_synthetic_vault <- mfrmr_gtvu_synthetic_vault(requests)
  modes <- c(
    "normal_pilot", "normal_confirmation", "normal_negative_control",
    "probe_protected_vault_read", "probe_repository_read",
    "probe_outside_write", "probe_parent_environment",
    "probe_unlisted_exec", "probe_network"
  )
  request_map <- c(1L, 2L, 3L, rep(1L, 6L))
  if (!is.list(evidence$ControlResults) ||
      !identical(names(evidence$ControlResults), modes)) {
    stop("The Draft.85c4n control-result registry was altered.",
         call. = FALSE)
  }
  for (index in seq_along(modes)) {
    mfrmr_gtvu_assert_worker_result(
      evidence$ControlResults[[index]], modes[[index]],
      requests[[request_map[[index]]]], runtime, adapter_worker_environment
    )
  }
  controls <- evidence$ControlRegistry
  expected_classes <- c(
    rep("normal_adapter_receipt", 3L),
    rep("sandbox_operation_denied", 3L),
    "parent_environment_absent",
    rep("sandbox_operation_denied", 2L)
  )
  exact_controls <- is.data.frame(controls) && nrow(controls) == 9L &&
    identical(controls$ControlOrdinal, 1:9) &&
    identical(controls$Mode, modes) &&
    identical(controls$SandboxExitStatus, rep(0L, 9L)) &&
    all(controls$SandboxProcessOutputEmpty) &&
    all(controls$OutputReceiptExists) &&
    identical(controls$ActionSucceeded, c(rep(TRUE, 3L), rep(FALSE, 6L))) &&
    !any(controls$ParentSecretVisible) && all(controls$ControlPassed) &&
    identical(controls$DenialClass, expected_classes) &&
    all(nchar(controls$ActionMessageHash) == 64L) &&
    all(nchar(controls$ResultHash) == 64L)
  normal_receipts <- do.call(rbind, lapply(seq_len(3L), function(index) {
    result <- evidence$ControlResults[[index]]
    data.frame(
      StageOrdinal = as.integer(index),
      StageId = plan$StageCatalog$StageId[[index]],
      LaneOpaqueId = requests[[index]]$LaneOpaqueId,
      RequestHash = requests[[index]]$RequestHash,
      ReceiptHash = result$AdapterReceiptHash,
      ExpectedUnits = requests[[index]]$ExpectedUnits,
      ObservedUnits = result$AdapterReceipt$ObservedUnits,
      ExactCanonicalReceipt = identical(
        result$AdapterReceipt,
        mfrmr_gtvt_worker_receipt(requests[[index]], adapter_worker_environment)
      ),
      stringsAsFactors = FALSE
    )
  }))
  row.names(normal_receipts) <- NULL
  prerequisites <- mfrmr_gtvu_prerequisite_projection(c4m_manifest)
  implementation <- mfrmr_gtvu_implementation_identity()
  capability_identity <- mfrmr_gtvu_capability_worker_identity(
    c4n_capability_worker_environment
  )
  ready_flags <- c(
    "DefaultDenyProfileReady", "SanitizedEnvironmentReady",
    "ExactDigestRuntimeReady", "ThreeLaneFreshProcessReceiptsReady",
    "SyntheticProtectedVaultReadDenied", "RepositoryReadDenied",
    "OutsideWriteDenied", "ParentEnvironmentSecretAbsent",
    "UnlistedExecutableDenied", "ExternalNetworkDenied",
    "PayloadTruthBlindReady", "BackendQualificationReady",
    "PlannedAdapterProcessCapabilityIsolationReady",
    "ProcessCapabilityIsolationReady", "ExecutionGateClosed"
  )
  closed_flags <- c(
    "TruthBlindProcessBoundaryReady", "PlannedExecutionIsolationReady",
    "AllExecutionPrerequisitesReady", "ExternalFreezeReady",
    "CleanSourceIdentityReady", "IndependentAccuracyRuleReady",
    "PilotExecutionAuthorized", "ConfirmationExecutionAuthorized",
    "NegativeControlExecutionAuthorized", "AdapterBackendExecutionOccurred",
    "CandidateExecutionOccurred", "CandidateCompletionSealed",
    "TruthReleaseAuthorized", "DenominatorAccountingReady",
    "PlannedResponseGenerated", "RecoveryExecuted", "RecoveryEvidenceReady",
    "EstimationReady", "InferenceReady", "DecisionReady",
    "PublicSupportReady"
  )
  valid <- identical(
    evidence$Contract,
    "gtheory_multivariate_planned_adapter_capability_draft85c4n_v1"
  ) && identical(evidence$PlanHash, plan$PlanHash) &&
    identical(evidence$C4MManifestHash, c4m_manifest$ManifestHash) &&
    identical(evidence$C4LReceiptHash, c4l_receipt$ReceiptHash) &&
    identical(evidence$C4LQualificationRouteRegistryHash,
              c4l_receipt$QualificationRouteRegistryHash) &&
    identical(evidence$RuntimeIdentity, runtime) &&
    identical(evidence$RuntimeIdentityHash, runtime$RuntimeIdentityHash) &&
    identical(evidence$StagedRuntimeRegistry, expected_staged_runtime) &&
    identical(evidence$StagedRuntimeRegistryHash,
              mfrmr_gtvu_hash(expected_staged_runtime)) &&
    identical(evidence$ProfileHash, mfrmr_gtvu_hash(expected_profile)) &&
    identical(evidence$ProfileSemanticHash,
              mfrmr_gtvu_hash(expected_profile_semantic)) &&
    identical(evidence$PolicyAudit, expected_policy_audit) &&
    identical(evidence$PolicyAuditHash,
              mfrmr_gtvu_hash(expected_policy_audit)) &&
    all(evidence$PolicyAudit$Passed) && exact_controls &&
    identical(evidence$ControlRegistryHash, mfrmr_gtvu_hash(controls)) &&
    identical(evidence$ControlResultsHash,
              mfrmr_gtvu_hash(evidence$ControlResults)) &&
    identical(evidence$NormalReceiptRegistry, normal_receipts) &&
    identical(evidence$NormalReceiptRegistryHash,
              mfrmr_gtvu_hash(normal_receipts)) &&
    identical(evidence$SyntheticVaultHash,
              mfrmr_gtvu_hash(expected_synthetic_vault)) &&
    all(normal_receipts$ExactCanonicalReceipt) &&
    identical(normal_receipts$ExpectedUnits,
              normal_receipts$ObservedUnits) &&
    identical(evidence$CapabilityWorkerIdentity, capability_identity) &&
    identical(evidence$CapabilityWorkerIdentityHash,
              mfrmr_gtvu_hash(capability_identity)) &&
    identical(evidence$PrerequisiteProjection, prerequisites) &&
    identical(evidence$PrerequisiteProjectionHash,
              mfrmr_gtvu_hash(prerequisites)) &&
    identical(evidence$ImplementationIdentity, implementation) &&
    identical(evidence$ImplementationIdentityHash,
              mfrmr_gtvu_hash(implementation)) &&
    identical(evidence$EvidenceHash,
              mfrmr_gtvu_hash(evidence[payload_fields])) &&
    !isTRUE(evidence$StagingContentRetained) &&
    !isTRUE(evidence$CandidateDataIncluded) &&
    !isTRUE(evidence$PlannedSeedMaterialIncluded) &&
    !isTRUE(evidence$ScenarioIdentityIncluded) &&
    !isTRUE(evidence$ReferenceIdentityIncluded) &&
    !isTRUE(evidence$ReferenceTruthIncluded) &&
    !isTRUE(evidence$AccuracyThresholdIncluded) &&
    !isTRUE(evidence$ConQuestRouteIncluded) &&
    all(vapply(ready_flags, function(name) isTRUE(evidence[[name]]),
               logical(1L))) &&
    isTRUE(evidence$ExactlyZeroC3PrerequisitesTransitioned) &&
    identical(evidence$C3SatisfiedPrerequisiteCount, 2L) &&
    !any(vapply(closed_flags, function(name) isTRUE(evidence[[name]]),
                logical(1L)))
  if (!valid) {
    stop("The Draft.85c4n evidence, controls, or readiness changed.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvu_live_preflight <- function(
    plan, generator_manifest, c3_manifest, c4e_manifest, c4f_manifest,
    repair_receipt, qualification_receipt, capability_evidence, c4l_receipt,
    c4m_manifest, repair_worker_environment,
    qualification_worker_environment, capability_worker_environment,
    adapter_worker_environment, c4n_capability_worker_environment,
    repo_root = ".", validation_dir = file.path("inst", "validation"),
    authorize_live_sandbox = FALSE, keep_staging = FALSE) {
  mfrmr_gtvu_require_primitives()
  if (!identical(Sys.info()[["sysname"]], "Darwin")) {
    stop("Draft.85c4n live isolation requires macOS.", call. = FALSE)
  }
  if (!isTRUE(authorize_live_sandbox)) {
    stop("Live c4n isolation requires `authorize_live_sandbox=TRUE`.",
         call. = FALSE)
  }
  if (!is.logical(keep_staging) || length(keep_staging) != 1L ||
      is.na(keep_staging)) {
    stop("`keep_staging` must be TRUE or FALSE.", call. = FALSE)
  }
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  validation_dir <- normalizePath(validation_dir, mustWork = TRUE)
  mfrmr_gtvt_assert_manifest(
    c4m_manifest, plan, generator_manifest, c3_manifest, c4e_manifest,
    c4f_manifest, repair_receipt, qualification_receipt,
    capability_evidence, c4l_receipt, repair_worker_environment,
    qualification_worker_environment, capability_worker_environment,
    adapter_worker_environment, repo_root, validation_dir
  )
  runtime <- mfrmr_gtvu_runtime_identity(c4m_manifest, validation_dir)
  capability_identity <- mfrmr_gtvu_capability_worker_identity(
    c4n_capability_worker_environment
  )
  requests <- mfrmr_gtvu_requests(plan, c4l_receipt)
  root <- file.path("/private/tmp", paste0("mfrmr-c4n-", substr(
    mfrmr_gtvu_hash(list(
      Namespace = "gtheory_multivariate_c4n_staging_v1",
      C4MManifestHash = c4m_manifest$ManifestHash,
      RuntimeIdentityHash = runtime$RuntimeIdentityHash
    )), 1L, 16L
  )))
  if (file.exists(root) || dir.exists(root)) {
    stop("The deterministic Draft.85c4n staging path is occupied.",
         call. = FALSE)
  }
  if (!dir.create(root)) {
    stop("Draft.85c4n could not create temporary staging.", call. = FALSE)
  }
  if (!isTRUE(keep_staging)) {
    on.exit(unlink(root, recursive = TRUE), add = TRUE)
  }
  staging <- mfrmr_gtvu_staging(root)
  digest_staged <- file.path(staging$RuntimeLibrary, "digest")
  copy_created <- file.copy(
    runtime$DigestPackagePath, staging$RuntimeLibrary, recursive = TRUE
  )
  staged_runtime <- data.frame(
    PackageOrdinal = 1L,
    Package = "digest",
    StagedPath = normalizePath(digest_staged, mustWork = TRUE),
    OriginPath = runtime$DigestPackagePath,
    Version = runtime$DigestVersion,
    DescriptionSHA256 = mfrmr_gtvu_file_hash(file.path(
      digest_staged, "DESCRIPTION"
    )),
    NativeRegistryHash = runtime$DigestNativeRegistryHash,
    stringsAsFactors = FALSE
  )
  staged_native <- sort(list.files(
    file.path(digest_staged, "libs"), pattern = "\\.(so|dylib)$",
    full.names = TRUE
  ), method = "radix")
  staged_native_hashes <- vapply(
    staged_native, mfrmr_gtvu_file_hash, character(1L)
  )
  if (!isTRUE(copy_created) || Sys.readlink(digest_staged) != "" ||
      !identical(basename(staged_native),
                 runtime$DigestNativeRegistry$FileName) ||
      !identical(unname(staged_native_hashes),
                 runtime$DigestNativeRegistry$SHA256) ||
      !identical(staged_runtime$DescriptionSHA256,
                 runtime$DigestDescriptionHash)) {
    stop("The Draft.85c4n staged digest identity changed.", call. = FALSE)
  }
  request_paths <- setNames(file.path(
    staging$Input, paste0(names(requests), "-request.rds")
  ), names(requests))
  for (index in seq_along(requests)) {
    saveRDS(requests[[index]], request_paths[[index]], version = 3L)
  }
  synthetic_vault <- mfrmr_gtvu_synthetic_vault(requests)
  vault_path <- file.path(staging$Vault, "synthetic-protected-vault.rds")
  saveRDS(synthetic_vault, vault_path, version = 3L)
  adapter_worker_path <- file.path(staging$Worker, "planned-adapter-worker.R")
  capability_worker_path <- file.path(
    staging$Worker, "planned-adapter-capability-worker.R"
  )
  copied <- c(
    file.copy(runtime$AdapterWorkerPath, adapter_worker_path),
    file.copy(runtime$CapabilityWorkerPath, capability_worker_path)
  )
  if (!all(copied) ||
      !identical(mfrmr_gtvu_file_hash(adapter_worker_path),
                 runtime$AdapterWorkerHash) ||
      !identical(mfrmr_gtvu_file_hash(capability_worker_path),
                 runtime$CapabilityWorkerHash)) {
    stop("The Draft.85c4n staged worker identity changed.", call. = FALSE)
  }
  repository_target <- normalizePath(file.path(
    validation_dir,
    paste0(
      "gtheory-multivariate-planned-adapter-capability-isolation-",
      "preflight-0.2.4.R"
    )
  ), mustWork = TRUE)
  outside_target <- file.path(staging$ForbiddenOutput, "leak.rds")
  profile_text <- mfrmr_gtvu_policy_text(runtime, staging)
  policy_audit <- mfrmr_gtvu_policy_audit(profile_text, runtime, staging)
  if (!all(policy_audit$Passed)) {
    stop("The Draft.85c4n default-deny policy audit failed.", call. = FALSE)
  }
  profile_path <- file.path(root, "planned-adapter-profile.sb")
  writeLines(profile_text, profile_path, useBytes = TRUE)
  modes <- c(
    "normal_pilot", "normal_confirmation", "normal_negative_control",
    "probe_protected_vault_read", "probe_repository_read",
    "probe_outside_write", "probe_parent_environment",
    "probe_unlisted_exec", "probe_network"
  )
  request_map <- c(1L, 2L, 3L, rep(1L, 6L))
  targets <- c(
    rep("none", 3L), vault_path, repository_target, outside_target,
    "MFRMR_C4N_PARENT_SECRET", "/bin/cat", "127.0.0.1"
  )
  old_secret <- Sys.getenv("MFRMR_C4N_PARENT_SECRET", unset = NA_character_)
  on.exit({
    if (is.na(old_secret)) Sys.unsetenv("MFRMR_C4N_PARENT_SECRET") else
      Sys.setenv(MFRMR_C4N_PARENT_SECRET = old_secret)
  }, add = TRUE)
  Sys.setenv(MFRMR_C4N_PARENT_SECRET = "synthetic-parent-only-secret")
  rows <- vector("list", length(modes))
  results <- setNames(vector("list", length(modes)), modes)
  for (index in seq_along(modes)) {
    request <- requests[[request_map[[index]]]]
    run_token <- paste0("C4N-", substr(mfrmr_gtvu_hash(list(
      Namespace = "gtheory_multivariate_c4n_run_v1",
      RequestHash = request$RequestHash, Mode = modes[[index]],
      RuntimeIdentityHash = runtime$RuntimeIdentityHash
    )), 1L, 24L))
    invocation <- mfrmr_gtvu_invoke(
      runtime, staging, profile_path, capability_worker_path,
      adapter_worker_path, request_paths[[request_map[[index]]]],
      modes[[index]], targets[[index]], run_token
    )
    if (invocation$Status != 0L || !invocation$OutputExists) {
      stop(
        "The Draft.85c4n sandbox worker failed for ", modes[[index]],
        ": ", paste(invocation$Output, collapse = " | "), call. = FALSE
      )
    }
    result <- readRDS(invocation$OutputPath)
    mfrmr_gtvu_assert_worker_result(
      result, modes[[index]], request, runtime, adapter_worker_environment
    )
    results[[modes[[index]]]] <- result
    denial_class <- if (startsWith(modes[[index]], "normal_")) {
      "normal_adapter_receipt"
    } else if (identical(modes[[index]], "probe_parent_environment") &&
               identical(result$ActionMessage,
                         "environment_variable_absent")) {
      "parent_environment_absent"
    } else if (grepl(
      paste0(
        "operation not permitted|permission denied|error in running command|",
        "sandbox_exec_status_[1-9]|cannot open the connection"
      ), result$ActionMessage, ignore.case = TRUE
    )) {
      "sandbox_operation_denied"
    } else "unexpected_failure_class"
    rows[[index]] <- data.frame(
      ControlOrdinal = as.integer(index), Mode = modes[[index]],
      SandboxExitStatus = invocation$Status,
      SandboxProcessOutputEmpty = length(invocation$Output) == 0L,
      OutputReceiptExists = invocation$OutputExists,
      ActionSucceeded = result$ActionSucceeded,
      ParentSecretVisible = result$ParentSecretVisible,
      ControlPassed = result$ControlPassed,
      DenialClass = denial_class,
      ActionMessageHash = mfrmr_gtvu_hash(result$ActionMessage),
      ResultHash = result$ResultHash,
      stringsAsFactors = FALSE
    )
  }
  controls <- do.call(rbind, rows)
  row.names(controls) <- NULL
  expected_classes <- c(
    rep("normal_adapter_receipt", 3L),
    rep("sandbox_operation_denied", 3L),
    "parent_environment_absent",
    rep("sandbox_operation_denied", 2L)
  )
  if (!identical(controls$DenialClass, expected_classes) ||
      file.exists(outside_target)) {
    stop(
      "A Draft.85c4n denial control failed: ",
      paste(paste0(controls$Mode, "=", controls$DenialClass),
            collapse = ", "),
      if (file.exists(outside_target)) ", outside_file_created" else "",
      ".", call. = FALSE
    )
  }
  normal_receipts <- do.call(rbind, lapply(seq_len(3L), function(index) {
    result <- results[[index]]
    data.frame(
      StageOrdinal = as.integer(index),
      StageId = plan$StageCatalog$StageId[[index]],
      LaneOpaqueId = requests[[index]]$LaneOpaqueId,
      RequestHash = requests[[index]]$RequestHash,
      ReceiptHash = result$AdapterReceiptHash,
      ExpectedUnits = requests[[index]]$ExpectedUnits,
      ObservedUnits = result$AdapterReceipt$ObservedUnits,
      ExactCanonicalReceipt = identical(
        result$AdapterReceipt,
        mfrmr_gtvt_worker_receipt(requests[[index]], adapter_worker_environment)
      ),
      stringsAsFactors = FALSE
    )
  }))
  row.names(normal_receipts) <- NULL
  profile_semantic <- gsub(
    normalizePath(staging$Root, mustWork = TRUE), "<STAGING_ROOT>",
    profile_text, fixed = TRUE
  )
  prerequisites <- mfrmr_gtvu_prerequisite_projection(c4m_manifest)
  implementation <- mfrmr_gtvu_implementation_identity()
  payload <- list(
    Contract =
      "gtheory_multivariate_planned_adapter_capability_draft85c4n_v1",
    PlanHash = plan$PlanHash,
    C4MManifestHash = c4m_manifest$ManifestHash,
    C4LReceiptHash = c4l_receipt$ReceiptHash,
    C4LQualificationRouteRegistryHash =
      c4l_receipt$QualificationRouteRegistryHash,
    RuntimeIdentity = runtime,
    RuntimeIdentityHash = runtime$RuntimeIdentityHash,
    StagedRuntimeRegistry = staged_runtime,
    StagedRuntimeRegistryHash = mfrmr_gtvu_hash(staged_runtime),
    ProfileHash = mfrmr_gtvu_hash(profile_text),
    ProfileSemanticHash = mfrmr_gtvu_hash(profile_semantic),
    PolicyAudit = policy_audit,
    PolicyAuditHash = mfrmr_gtvu_hash(policy_audit),
    ControlRegistry = controls,
    ControlRegistryHash = mfrmr_gtvu_hash(controls),
    ControlResults = results,
    ControlResultsHash = mfrmr_gtvu_hash(results),
    NormalReceiptRegistry = normal_receipts,
    NormalReceiptRegistryHash = mfrmr_gtvu_hash(normal_receipts),
    SyntheticVaultHash = mfrmr_gtvu_hash(synthetic_vault),
    CapabilityWorkerIdentity = capability_identity,
    CapabilityWorkerIdentityHash = mfrmr_gtvu_hash(capability_identity),
    PrerequisiteProjection = prerequisites,
    PrerequisiteProjectionHash = mfrmr_gtvu_hash(prerequisites),
    ImplementationIdentity = implementation,
    ImplementationIdentityHash = mfrmr_gtvu_hash(implementation),
    StagingContentRetained = isTRUE(keep_staging),
    CandidateDataIncluded = FALSE,
    PlannedSeedMaterialIncluded = FALSE,
    ScenarioIdentityIncluded = FALSE,
    ReferenceIdentityIncluded = FALSE,
    ReferenceTruthIncluded = FALSE,
    AccuracyThresholdIncluded = FALSE,
    ConQuestRouteIncluded = FALSE
  )
  evidence <- structure(c(payload, list(
    EvidenceHash = mfrmr_gtvu_hash(payload),
    DefaultDenyProfileReady = TRUE,
    SanitizedEnvironmentReady = TRUE,
    ExactDigestRuntimeReady = TRUE,
    ThreeLaneFreshProcessReceiptsReady = TRUE,
    SyntheticProtectedVaultReadDenied = TRUE,
    RepositoryReadDenied = TRUE,
    OutsideWriteDenied = TRUE,
    ParentEnvironmentSecretAbsent = TRUE,
    UnlistedExecutableDenied = TRUE,
    ExternalNetworkDenied = TRUE,
    PayloadTruthBlindReady = TRUE,
    BackendQualificationReady = TRUE,
    PlannedAdapterProcessCapabilityIsolationReady = TRUE,
    ProcessCapabilityIsolationReady = TRUE,
    TruthBlindProcessBoundaryReady = FALSE,
    PlannedExecutionIsolationReady = FALSE,
    ExactlyZeroC3PrerequisitesTransitioned =
      !any(prerequisites$TransitionedByC4N),
    C3SatisfiedPrerequisiteCount =
      as.integer(sum(prerequisites$C4NProjectedSatisfied)),
    AllExecutionPrerequisitesReady =
      all(prerequisites$C4NProjectedSatisfied),
    ExternalFreezeReady = FALSE,
    CleanSourceIdentityReady = FALSE,
    IndependentAccuracyRuleReady = FALSE,
    PilotExecutionAuthorized = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    NegativeControlExecutionAuthorized = FALSE,
    ExecutionGateClosed = TRUE,
    AdapterBackendExecutionOccurred = FALSE,
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
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvu_evidence", "list"))
  if (isTRUE(keep_staging)) {
    saveRDS(
      evidence, file.path(staging$Output, "retained-c4n-evidence.rds"),
      version = 3L
    )
  } else {
    mfrmr_gtvu_assert_evidence(
      evidence, plan, generator_manifest, c3_manifest, c4e_manifest,
      c4f_manifest, repair_receipt, qualification_receipt,
      capability_evidence, c4l_receipt, c4m_manifest,
      repair_worker_environment, qualification_worker_environment,
      capability_worker_environment, adapter_worker_environment,
      c4n_capability_worker_environment, repo_root, validation_dir
    )
  }
  evidence
}

mfrmr_gtvu_dispatch_guard <- function(
    evidence, action, callback, ..., authorize = FALSE,
    plan, generator_manifest, c3_manifest, c4e_manifest, c4f_manifest,
    repair_receipt, qualification_receipt, capability_evidence, c4l_receipt,
    c4m_manifest, repair_worker_environment,
    qualification_worker_environment, capability_worker_environment,
    adapter_worker_environment, c4n_capability_worker_environment,
    repo_root = ".", validation_dir = file.path("inst", "validation")) {
  allowed_actions <- c(
    "candidate_execution", "pilot", "confirmation", "negative_control",
    "planned_response", "recovery", "public_promotion"
  )
  if (!is.character(action) || length(action) != 1L || is.na(action) ||
      !action %in% allowed_actions) {
    stop("The Draft.85c4n action is outside the isolation contract.",
         call. = FALSE)
  }
  if (!is.function(callback)) {
    stop("`callback` must be a function.", call. = FALSE)
  }
  if (!is.logical(authorize) || length(authorize) != 1L || is.na(authorize)) {
    stop("`authorize` must be TRUE or FALSE.", call. = FALSE)
  }
  mfrmr_gtvu_assert_evidence(
    evidence, plan, generator_manifest, c3_manifest, c4e_manifest,
    c4f_manifest, repair_receipt, qualification_receipt,
    capability_evidence, c4l_receipt, c4m_manifest,
    repair_worker_environment, qualification_worker_environment,
    capability_worker_environment, adapter_worker_environment,
    c4n_capability_worker_environment, repo_root, validation_dir
  )
  stop(
    "Draft.85c4n qualifies only the non-attempt adapter process; the fit-",
    "capable truth-blind boundary and every execution dispatch remain closed.",
    call. = FALSE
  )
}
