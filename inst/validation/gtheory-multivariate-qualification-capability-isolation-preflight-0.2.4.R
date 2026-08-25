# Draft.85c4h qualification-refusal capability-isolation preflight.
#
# Repository-internal only. The portable portion seals the runtime, policy,
# schemas, and denial controls. Live execution places the c4g hash-only refusal
# path under a default-deny macOS profile. It performs no repair or backend fit.

mfrmr_gtvo_require_primitives <- function() {
  required <- c(
    "mfrmr_gtvn_hash", "mfrmr_gtvn_assert_request",
    "mfrmr_gtvn_assert_manifest", "mfrmr_gtvm_assert_manifest"
  )
  target <- environment(mfrmr_gtvo_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the Draft.85c4g chain before Draft.85c4h: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtvo_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4h requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvo_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    setequal(names(attributes(object)), c("names", "class"))
}

mfrmr_gtvo_file_hash <- function(path) {
  if (!is.character(path) || length(path) != 1L || is.na(path) ||
      !file.exists(path) || dir.exists(path)) {
    stop("A Draft.85c4h runtime file is missing.", call. = FALSE)
  }
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtvo_function_hash <- function(fun) {
  if (!is.function(fun)) {
    stop("A Draft.85c4h controller function is missing.", call. = FALSE)
  }
  mfrmr_gtvo_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtvo_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtvo_require_primitives", "mfrmr_gtvo_hash",
    "mfrmr_gtvo_exact_object", "mfrmr_gtvo_file_hash",
    "mfrmr_gtvo_function_hash", "mfrmr_gtvo_implementation_identity",
    "mfrmr_gtvo_capability_worker_identity", "mfrmr_gtvo_quote_profile",
    "mfrmr_gtvo_runtime_identity", "mfrmr_gtvo_staging",
    "mfrmr_gtvo_policy_text", "mfrmr_gtvo_policy_audit",
    "mfrmr_gtvo_synthetic_vault",
    "mfrmr_gtvo_worker_result_payload_fields",
    "mfrmr_gtvo_assert_worker_result", "mfrmr_gtvo_invoke",
    "mfrmr_gtvo_live_payload_fields", "mfrmr_gtvo_assert_live_evidence",
    "mfrmr_gtvo_live_preflight", "mfrmr_gtvo_dispatch_guard"
  )
  target <- environment(mfrmr_gtvo_implementation_identity)
  data.frame(
    Function = functions,
    SHA256 = vapply(functions, function(name) {
      if (!exists(name, envir = target, inherits = FALSE)) {
        stop("A Draft.85c4h implementation function is missing: ", name,
             ".", call. = FALSE)
      }
      mfrmr_gtvo_function_hash(get(name, envir = target, inherits = FALSE))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvo_capability_worker_identity <- function(worker_environment) {
  if (!is.environment(worker_environment) ||
      !identical(parent.env(worker_environment), baseenv())) {
    stop("Draft.85c4h requires a worker environment with baseenv() parent.",
         call. = FALSE)
  }
  functions <- c(
    "mfrmr_gtvow_hash", "mfrmr_gtvow_attempt", "mfrmr_gtvow_probe",
    "mfrmr_gtvow_main"
  )
  if (!identical(
    sort(ls(worker_environment, all.names = TRUE), method = "radix"),
    sort(functions, method = "radix")
  ) || !all(vapply(functions, function(name) {
    is.function(get(name, envir = worker_environment, inherits = FALSE))
  }, logical(1L)))) {
    stop("The Draft.85c4h capability-worker namespace was altered.",
         call. = FALSE)
  }
  data.frame(
    Function = functions,
    SHA256 = vapply(functions, function(name) {
      fun <- get(name, envir = worker_environment, inherits = FALSE)
      mfrmr_gtvo_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvo_quote_profile <- function(path) {
  encodeString(normalizePath(path, mustWork = FALSE), quote = "\"")
}

mfrmr_gtvo_runtime_identity <- function(validation_dir = file.path(
    "inst", "validation")) {
  validation_dir <- normalizePath(validation_dir, mustWork = TRUE)
  sandbox_exec <- normalizePath("/usr/bin/sandbox-exec", mustWork = TRUE)
  environment_exec <- normalizePath("/usr/bin/env", mustWork = TRUE)
  r_home <- normalizePath(R.home(), mustWork = TRUE)
  r_exec <- normalizePath(
    file.path(r_home, "bin", "exec", "R"), mustWork = TRUE
  )
  system_profile <- normalizePath(
    "/System/Library/Sandbox/Profiles/system.sb", mustWork = TRUE
  )
  refusal_worker <- normalizePath(file.path(
    validation_dir, "gtheory-multivariate-qualification-worker-0.2.4.R"
  ), mustWork = TRUE)
  capability_worker <- normalizePath(file.path(
    validation_dir,
    "gtheory-multivariate-qualification-capability-worker-0.2.4.R"
  ), mustWork = TRUE)
  digest_path <- normalizePath(find.package("digest"), mustWork = TRUE)
  refusal_hash <- mfrmr_gtvo_file_hash(refusal_worker)
  capability_hash <- mfrmr_gtvo_file_hash(capability_worker)
  if (!identical(
    refusal_hash,
    "a13ef63611a1e96048de3fd5a4b59bf4dddc53d225c6cd3f5808c65876a21daa"
  )) {
    stop("The sealed Draft.85c4g refusal-worker source changed.",
         call. = FALSE)
  }
  if (!identical(
    capability_hash,
    "4387bc63f86cd5c77454e3767077ec11b31603b55733cadcb2805d0bee2ec7c0"
  )) {
    stop("The sealed Draft.85c4h capability-worker source changed.",
         call. = FALSE)
  }
  data.frame(
    OS = Sys.info()[["sysname"]],
    OSRelease = Sys.info()[["release"]],
    OSVersion = Sys.info()[["version"]],
    Machine = Sys.info()[["machine"]],
    RVersion = R.version.string,
    SandboxExecutable = sandbox_exec,
    SandboxExecutableHash = mfrmr_gtvo_file_hash(sandbox_exec),
    EnvironmentExecutable = environment_exec,
    EnvironmentExecutableHash = mfrmr_gtvo_file_hash(environment_exec),
    RHome = r_home,
    RExecutable = r_exec,
    RExecutableHash = mfrmr_gtvo_file_hash(r_exec),
    SystemProfile = system_profile,
    SystemProfileHash = mfrmr_gtvo_file_hash(system_profile),
    ValidationDirectory = validation_dir,
    DigestPath = digest_path,
    DigestVersion = as.character(utils::packageVersion("digest")),
    RefusalWorkerPath = refusal_worker,
    RefusalWorkerHash = refusal_hash,
    CapabilityWorkerPath = capability_worker,
    CapabilityWorkerHash = capability_hash,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvo_staging <- function(root) {
  root <- normalizePath(root, mustWork = TRUE)
  paths <- list(
    Root = root,
    Input = file.path(root, "input"),
    Worker = file.path(root, "worker"),
    Output = file.path(root, "output"),
    Scratch = file.path(root, "scratch"),
    Vault = file.path(root, "vault"),
    ForbiddenOutput = file.path(root, "forbidden-output")
  )
  created <- vapply(paths[-1L], dir.create, logical(1L), recursive = FALSE)
  if (!all(created)) {
    stop("Draft.85c4h could not create exact staging directories.",
         call. = FALSE)
  }
  lapply(paths, normalizePath, mustWork = TRUE)
}

mfrmr_gtvo_policy_text <- function(runtime, staging) {
  if (!is.data.frame(runtime) || nrow(runtime) != 1L) {
    stop("One Draft.85c4h runtime identity is required.", call. = FALSE)
  }
  required_staging <- c(
    "Root", "Input", "Worker", "Output", "Scratch", "Vault",
    "ForbiddenOutput"
  )
  if (!is.list(staging) || !identical(names(staging), required_staging)) {
    stop("The Draft.85c4h staging identity is invalid.", call. = FALSE)
  }
  q <- mfrmr_gtvo_quote_profile
  r_framework <- normalizePath(
    file.path(runtime$RHome[[1L]], "..", "..", ".."), mustWork = TRUE
  )
  lines <- c(
    "(version 1)", "(deny default)", "(import \"system.sb\")",
    "(allow process-fork)",
    "(allow process-exec",
    paste0("  (literal ", q(runtime$EnvironmentExecutable[[1L]]), ")"),
    paste0("  (literal ", q(runtime$RExecutable[[1L]]), ")"),
    "  (literal \"/bin/sh\")",
    "  (literal \"/bin/bash\")",
    "  (literal \"/bin/rm\"))",
    "(allow file-read* file-map-executable",
    paste0("  (subpath ", q(r_framework), ")"),
    "  (subpath \"/bin\")",
    paste0("  (literal ", q(runtime$EnvironmentExecutable[[1L]]), "))"),
    "(allow file-read-metadata file-test-existence",
    "  (subpath \"/Library\")",
    paste0("  (subpath ", q(staging$Root), "))"),
    "(allow file-read*",
    "  (literal \"/private/var/select/sh\")",
    "  (literal \"/bin/sh\")",
    paste0("  (subpath ", q(staging$Input), ")"),
    paste0("  (subpath ", q(staging$Worker), ")"),
    paste0("  (subpath ", q(staging$Output), ")"),
    paste0("  (subpath ", q(staging$Scratch), "))"),
    "(allow file-write*",
    paste0("  (subpath ", q(staging$Output), ")"),
    paste0("  (subpath ", q(staging$Scratch), "))")
  )
  paste(lines, collapse = "\n")
}

mfrmr_gtvo_policy_audit <- function(profile_text, runtime, staging) {
  forbidden <- c(
    staging$Vault, staging$ForbiddenOutput, runtime$ValidationDirectory[[1L]]
  )
  data.frame(
    Rule = c(
      "version_one", "default_deny", "system_profile_import",
      "no_allow_default", "no_network_allow", "no_vault_path",
      "no_forbidden_output_path", "no_repository_path",
      "hash_only_input_allow", "worker_allow", "output_allow",
      "scratch_allow", "sanitized_env_exec_allow", "r_exec_allow"
    ),
    Passed = c(
      grepl("\\(version 1\\)", profile_text),
      grepl("\\(deny default\\)", profile_text),
      grepl("\\(import \\\"system\\.sb\\\"\\)", profile_text),
      !grepl("\\(allow default\\)", profile_text),
      !grepl("allow network", profile_text),
      !grepl(normalizePath(forbidden[[1L]], mustWork = FALSE),
             profile_text, fixed = TRUE),
      !grepl(normalizePath(forbidden[[2L]], mustWork = FALSE),
             profile_text, fixed = TRUE),
      !grepl(normalizePath(forbidden[[3L]], mustWork = TRUE),
             profile_text, fixed = TRUE),
      grepl(normalizePath(staging$Input, mustWork = FALSE),
            profile_text, fixed = TRUE),
      grepl(normalizePath(staging$Worker, mustWork = FALSE),
            profile_text, fixed = TRUE),
      grepl(normalizePath(staging$Output, mustWork = FALSE),
            profile_text, fixed = TRUE),
      grepl(normalizePath(staging$Scratch, mustWork = FALSE),
            profile_text, fixed = TRUE),
      grepl(runtime$EnvironmentExecutable[[1L]], profile_text, fixed = TRUE),
      grepl(runtime$RExecutable[[1L]], profile_text, fixed = TRUE)
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvo_synthetic_vault <- function(request) {
  list(
    Contract = "gtheory_multivariate_c4h_synthetic_denied_vault_v1",
    RequestHash = request$RequestHash,
    SyntheticForbiddenToken = mfrmr_gtvo_hash(list(
      Namespace = "gtheory_multivariate_c4h_denied_token_v1",
      RequestHash = request$RequestHash
    )),
    ContainsPlannedSeed = FALSE,
    ContainsResponse = FALSE,
    ContainsTruth = FALSE
  )
}

mfrmr_gtvo_worker_result_payload_fields <- function() {
  c(
    "Contract", "Mode", "RunToken", "RequestHash",
    "ProtocolManifestHash", "EnvironmentIdentityHash", "EnvironmentNames",
    "EnvironmentNamesHash", "ParentSecretVisible", "ActionSucceeded",
    "ActionMessage", "RefusalReceipt", "RefusalReceiptHash",
    "ControlPassed"
  )
}

mfrmr_gtvo_assert_worker_result <- function(
    result, expected_mode, request, refusal_worker_environment) {
  payload_fields <- mfrmr_gtvo_worker_result_payload_fields()
  suffix_fields <- c(
    "ResultHash", "FullB1ObjectsReceived", "BackendExecutionOccurred",
    "TrustedReceiptProduced", "QualificationWorkerImplemented",
    "QualificationEvidenceReady", "BackendQualificationReady",
    "ExecutionAuthorized", "RecoveryEvidenceReady", "PublicSupportReady"
  )
  if (!mfrmr_gtvo_exact_object(
    result, c(payload_fields, suffix_fields),
    c("mfrmr_gtvo_worker_result", "list")
  )) {
    stop("A typed Draft.85c4h worker result is required.", call. = FALSE)
  }
  negative <- !identical(expected_mode, "normal")
  valid <- identical(
    result$Contract,
    "gtheory_multivariate_qualification_capability_worker_draft85c4h_v1"
  ) && identical(result$Mode, expected_mode) &&
    grepl("^C4H-[0-9a-f]{24}$", result$RunToken) &&
    identical(result$RequestHash, request$RequestHash) &&
    identical(result$ProtocolManifestHash, request$ProtocolManifestHash) &&
    identical(result$EnvironmentIdentityHash,
              request$EnvironmentIdentityHash) &&
    identical(result$EnvironmentNamesHash,
              mfrmr_gtvo_hash(result$EnvironmentNames)) &&
    !isTRUE(result$ParentSecretVisible) &&
    identical(isTRUE(result$ActionSucceeded), !negative) &&
    isTRUE(result$ControlPassed) &&
    identical(result$ResultHash, mfrmr_gtvo_hash(result[payload_fields])) &&
    !isTRUE(result$FullB1ObjectsReceived) &&
    !isTRUE(result$BackendExecutionOccurred) &&
    !isTRUE(result$TrustedReceiptProduced) &&
    !isTRUE(result$QualificationWorkerImplemented) &&
    !isTRUE(result$QualificationEvidenceReady) &&
    !isTRUE(result$BackendQualificationReady) &&
    !isTRUE(result$ExecutionAuthorized) &&
    !isTRUE(result$RecoveryEvidenceReady) &&
    !isTRUE(result$PublicSupportReady)
  if (identical(expected_mode, "normal")) {
    refusal_assert <- get(
      "mfrmr_gtvnw_assert_receipt", envir = refusal_worker_environment,
      inherits = FALSE
    )
    receipt_valid <- tryCatch({
      refusal_assert(result$RefusalReceipt, request)
      TRUE
    }, error = function(condition) FALSE)
    valid <- valid && receipt_valid && identical(
      result$RefusalReceiptHash, result$RefusalReceipt$ReceiptHash
    )
  } else {
    valid <- valid && is.null(result$RefusalReceipt) &&
      is.na(result$RefusalReceiptHash)
  }
  if (!valid) {
    stop("The Draft.85c4h worker result or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvo_invoke <- function(
    runtime, staging, profile_path, capability_worker_path,
    refusal_worker_path, input_path, mode, target, run_token) {
  output_path <- file.path(staging$Output, paste0(mode, ".rds"))
  arguments <- c(
    "-f", shQuote(profile_path),
    shQuote(runtime$EnvironmentExecutable[[1L]]), "-i",
    paste0("R_HOME=", shQuote(runtime$RHome[[1L]])),
    paste0("TMPDIR=", shQuote(staging$Scratch)),
    "PATH=/usr/bin:/bin", "LANG=C", "LC_ALL=C", "TZ=UTC",
    shQuote(runtime$RExecutable[[1L]]), "--vanilla", "--slave",
    paste0("--file=", shQuote(capability_worker_path)), "--args",
    shQuote(mode), shQuote(refusal_worker_path), shQuote(input_path),
    shQuote(output_path), shQuote(target), shQuote(run_token)
  )
  output <- suppressWarnings(system2(
    runtime$SandboxExecutable[[1L]], arguments,
    stdout = TRUE, stderr = TRUE
  ))
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  list(
    Status = as.integer(status), Output = output,
    OutputPath = output_path, OutputExists = file.exists(output_path)
  )
}

mfrmr_gtvo_live_payload_fields <- function() {
  c(
    "Contract", "C4GManifestHash", "ProtocolManifestHash",
    "QualificationPolicyHash", "EnvironmentIdentityHash",
    "BundleRegistryHash", "RefusalWorkerSourceSHA256", "RequestHash",
    "RuntimeIdentity", "RuntimeIdentityHash", "ProfileHash",
    "ProfileSemanticHash", "PolicyAudit", "PolicyAuditHash",
    "ControlRegistry", "ControlRegistryHash", "NormalRefusalReceiptHash",
    "SyntheticVaultHash", "CapabilityWorkerIdentity",
    "CapabilityWorkerIdentityHash", "ImplementationIdentity",
    "ImplementationIdentityHash", "StagingContentRetained",
    "PlannedSeedMaterialIncluded", "FullB1ObjectsIncluded",
    "ReferenceTruthIncluded", "ConQuestRouteIncluded"
  )
}

mfrmr_gtvo_assert_live_evidence <- function(
    evidence, refusal_worker_environment, capability_worker_environment,
    c4g_manifest, protocol_manifest, repo_root = ".") {
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  mfrmr_gtvn_assert_manifest(
    c4g_manifest, refusal_worker_environment, protocol_manifest, repo_root
  )
  payload_fields <- mfrmr_gtvo_live_payload_fields()
  suffix_fields <- c(
    "EvidenceHash", "DefaultDenyProfileReady",
    "SanitizedEnvironmentReady", "HashOnlyInputReadReady",
    "RefusalReceiptWriteReady", "SyntheticVaultReadDenied",
    "SourceTreeReadDenied", "OutsideWriteDenied",
    "ParentEnvironmentSecretAbsent", "UnlistedExecutableDenied",
    "ExternalNetworkPolicyClosed", "ProcessCapabilityIsolationReady",
    "HashOnlyRefusalBoundaryReady", "FreshProcessRefusalObserved",
    "RefusalOnlyWorkerReady", "EnvironmentReadyForBackendQualification",
    "RepairRequired", "QualificationWorkerImplemented",
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
  if (!mfrmr_gtvo_exact_object(
    evidence, c(payload_fields, suffix_fields),
    c("mfrmr_gtvo_live_evidence", "list")
  )) {
    stop("A typed Draft.85c4h live evidence object is required.",
         call. = FALSE)
  }
  controls <- evidence$ControlRegistry
  expected_modes <- c(
    "normal", "probe_vault_read", "probe_source_read",
    "probe_outside_write", "probe_parent_environment",
    "probe_unlisted_exec"
  )
  expected_classes <- c(
    "normal_refusal_receipt", rep("sandbox_operation_denied", 3L),
    "parent_environment_absent", "sandbox_operation_denied"
  )
  exact_controls <- is.data.frame(controls) && nrow(controls) == 6L &&
    identical(controls$ControlOrdinal, 1:6) &&
    identical(controls$Mode, expected_modes) &&
    identical(controls$SandboxExitStatus, rep(0L, 6L)) &&
    all(controls$OutputReceiptExists) &&
    identical(controls$ActionSucceeded, c(TRUE, rep(FALSE, 5L))) &&
    !any(controls$ParentSecretVisible) && all(controls$ControlPassed) &&
    identical(controls$DenialClass, expected_classes) &&
    all(nchar(controls$ActionMessageHash) == 64L) &&
    all(nchar(controls$ResultHash) == 64L)
  ready_flags <- c(
    "DefaultDenyProfileReady", "SanitizedEnvironmentReady",
    "HashOnlyInputReadReady", "RefusalReceiptWriteReady",
    "SyntheticVaultReadDenied", "SourceTreeReadDenied",
    "OutsideWriteDenied", "ParentEnvironmentSecretAbsent",
    "UnlistedExecutableDenied", "ExternalNetworkPolicyClosed",
    "ProcessCapabilityIsolationReady", "HashOnlyRefusalBoundaryReady",
    "FreshProcessRefusalObserved", "RefusalOnlyWorkerReady",
    "RepairRequired", "ExecutionGateClosed"
  )
  closed_flags <- c(
    "EnvironmentReadyForBackendQualification",
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
  request <- c4g_manifest$Request
  mfrmr_gtvn_assert_request(
    request, refusal_worker_environment, protocol_manifest, repo_root
  )
  refusal_receipt <- get(
    "mfrmr_gtvnw_refusal_receipt", envir = refusal_worker_environment,
    inherits = FALSE
  )(request)
  canonical_vault <- mfrmr_gtvo_synthetic_vault(request)
  valid <- identical(
    evidence$Contract,
    "gtheory_multivariate_qualification_capability_draft85c4h_v1"
  ) && identical(
    evidence$C4GManifestHash,
    "c62906de666c4de1f6a00f07009e84fc859165486a859cbb2db406e679be7a97"
  ) && identical(evidence$C4GManifestHash, c4g_manifest$ManifestHash) &&
    identical(evidence$ProtocolManifestHash, request$ProtocolManifestHash) &&
    identical(evidence$QualificationPolicyHash,
              request$QualificationPolicyHash) &&
    identical(evidence$EnvironmentIdentityHash,
              request$EnvironmentIdentityHash) &&
    identical(evidence$BundleRegistryHash, request$BundleRegistryHash) &&
    identical(evidence$RefusalWorkerSourceSHA256,
              request$WorkerSourceSHA256) &&
    identical(evidence$RequestHash, request$RequestHash) &&
    identical(evidence$NormalRefusalReceiptHash,
              refusal_receipt$ReceiptHash) &&
    identical(evidence$RuntimeIdentity$OS, "Darwin") &&
    identical(evidence$RuntimeIdentity$RefusalWorkerHash,
              request$WorkerSourceSHA256) &&
    identical(evidence$RuntimeIdentityHash,
              mfrmr_gtvo_hash(evidence$RuntimeIdentity)) &&
    identical(evidence$PolicyAuditHash,
              mfrmr_gtvo_hash(evidence$PolicyAudit)) &&
    all(evidence$PolicyAudit$Passed) && exact_controls &&
    identical(evidence$ControlRegistryHash, mfrmr_gtvo_hash(controls)) &&
    identical(evidence$SyntheticVaultHash,
              mfrmr_gtvo_hash(canonical_vault)) &&
    identical(evidence$CapabilityWorkerIdentity,
              mfrmr_gtvo_capability_worker_identity(
                capability_worker_environment
              )) &&
    identical(evidence$CapabilityWorkerIdentityHash,
              mfrmr_gtvo_hash(evidence$CapabilityWorkerIdentity)) &&
    identical(evidence$ImplementationIdentity,
              mfrmr_gtvo_implementation_identity()) &&
    identical(evidence$ImplementationIdentityHash,
              mfrmr_gtvo_hash(evidence$ImplementationIdentity)) &&
    identical(evidence$EvidenceHash,
              mfrmr_gtvo_hash(evidence[payload_fields])) &&
    !isTRUE(evidence$StagingContentRetained) &&
    !isTRUE(evidence$PlannedSeedMaterialIncluded) &&
    !isTRUE(evidence$FullB1ObjectsIncluded) &&
    !isTRUE(evidence$ReferenceTruthIncluded) &&
    !isTRUE(evidence$ConQuestRouteIncluded) &&
    all(vapply(ready_flags, function(name) isTRUE(evidence[[name]]),
               logical(1L))) &&
    !any(vapply(closed_flags, function(name) isTRUE(evidence[[name]]),
                logical(1L)))
  if (!valid) {
    stop("The Draft.85c4h live evidence, controls, or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvo_live_preflight <- function(
    refusal_worker_environment, capability_worker_environment,
    c4g_manifest, protocol_manifest, repo_root = ".",
    validation_dir = file.path("inst", "validation"),
    authorize_live_sandbox = FALSE, keep_staging = FALSE) {
  if (!identical(Sys.info()[["sysname"]], "Darwin")) {
    stop("Draft.85c4h live isolation requires macOS.", call. = FALSE)
  }
  if (!isTRUE(authorize_live_sandbox)) {
    stop("Live c4h isolation requires `authorize_live_sandbox=TRUE`.",
         call. = FALSE)
  }
  if (!is.logical(keep_staging) || length(keep_staging) != 1L ||
      is.na(keep_staging)) {
    stop("`keep_staging` must be TRUE or FALSE.", call. = FALSE)
  }
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  validation_dir <- normalizePath(validation_dir, mustWork = TRUE)
  mfrmr_gtvn_assert_manifest(
    c4g_manifest, refusal_worker_environment, protocol_manifest, repo_root
  )
  if (!identical(
    c4g_manifest$ManifestHash,
    "c62906de666c4de1f6a00f07009e84fc859165486a859cbb2db406e679be7a97"
  )) {
    stop("The sealed Draft.85c4g manifest root changed.", call. = FALSE)
  }
  capability_identity <- mfrmr_gtvo_capability_worker_identity(
    capability_worker_environment
  )
  request <- c4g_manifest$Request
  mfrmr_gtvn_assert_request(
    request, refusal_worker_environment, protocol_manifest, repo_root
  )
  runtime <- mfrmr_gtvo_runtime_identity(validation_dir)
  root <- file.path("/private/tmp", paste0("mfrmr-c4h-", substr(
    mfrmr_gtvo_hash(list(
      Namespace = "gtheory_multivariate_c4h_staging_v1",
      C4GManifestHash = c4g_manifest$ManifestHash,
      RequestHash = request$RequestHash,
      RuntimeIdentityHash = mfrmr_gtvo_hash(runtime)
    )), 1L, 16L
  )))
  if (file.exists(root) || dir.exists(root)) {
    stop("The deterministic Draft.85c4h staging path is occupied.",
         call. = FALSE)
  }
  if (!dir.create(root)) {
    stop("Draft.85c4h could not create temporary staging.", call. = FALSE)
  }
  if (!isTRUE(keep_staging)) {
    on.exit(unlink(root, recursive = TRUE), add = TRUE)
  }
  staging <- mfrmr_gtvo_staging(root)
  input_path <- file.path(staging$Input, "refusal-request.rds")
  saveRDS(request, input_path, version = 3L)
  synthetic_vault <- mfrmr_gtvo_synthetic_vault(request)
  vault_path <- file.path(staging$Vault, "synthetic-denied-vault.rds")
  saveRDS(synthetic_vault, vault_path, version = 3L)
  refusal_worker_path <- file.path(staging$Worker, "refusal-worker.R")
  capability_worker_path <- file.path(staging$Worker, "capability-worker.R")
  copied <- c(
    file.copy(runtime$RefusalWorkerPath[[1L]], refusal_worker_path),
    file.copy(runtime$CapabilityWorkerPath[[1L]], capability_worker_path)
  )
  if (!all(copied) || !identical(
    mfrmr_gtvo_file_hash(refusal_worker_path),
    runtime$RefusalWorkerHash[[1L]]
  ) || !identical(
    mfrmr_gtvo_file_hash(capability_worker_path),
    runtime$CapabilityWorkerHash[[1L]]
  )) {
    stop("Draft.85c4h staged worker identity did not match.",
         call. = FALSE)
  }
  source_target <- normalizePath(file.path(
    validation_dir,
    "gtheory-multivariate-qualification-worker-preflight-0.2.4.R"
  ), mustWork = TRUE)
  outside_target <- file.path(staging$ForbiddenOutput, "leak.rds")
  profile_text <- mfrmr_gtvo_policy_text(runtime, staging)
  policy_audit <- mfrmr_gtvo_policy_audit(profile_text, runtime, staging)
  if (!all(policy_audit$Passed)) {
    stop("The Draft.85c4h default-deny policy audit failed.", call. = FALSE)
  }
  profile_path <- file.path(root, "refusal-profile.sb")
  writeLines(profile_text, profile_path, useBytes = TRUE)
  modes <- c(
    "normal", "probe_vault_read", "probe_source_read",
    "probe_outside_write", "probe_parent_environment",
    "probe_unlisted_exec"
  )
  targets <- c(
    "none", vault_path, source_target, outside_target,
    "MFRMR_C4H_PARENT_SECRET", "/bin/cat"
  )
  old_secret <- Sys.getenv("MFRMR_C4H_PARENT_SECRET", unset = NA_character_)
  on.exit({
    if (is.na(old_secret)) Sys.unsetenv("MFRMR_C4H_PARENT_SECRET") else
      Sys.setenv(MFRMR_C4H_PARENT_SECRET = old_secret)
  }, add = TRUE)
  Sys.setenv(MFRMR_C4H_PARENT_SECRET = "synthetic-parent-only-secret")
  rows <- list()
  normal_receipt <- NULL
  for (index in seq_along(modes)) {
    run_token <- paste0("C4H-", substr(mfrmr_gtvo_hash(list(
      Namespace = "gtheory_multivariate_c4h_run_v1",
      RequestHash = request$RequestHash,
      Mode = modes[[index]],
      RuntimeIdentityHash = mfrmr_gtvo_hash(runtime)
    )), 1L, 24L))
    invocation <- mfrmr_gtvo_invoke(
      runtime, staging, profile_path, capability_worker_path,
      refusal_worker_path, input_path, modes[[index]], targets[[index]],
      run_token
    )
    if (invocation$Status != 0L || !invocation$OutputExists) {
      stop(
        "The Draft.85c4h sandbox worker failed for ", modes[[index]],
        ": ", paste(invocation$Output, collapse = " | "), call. = FALSE
      )
    }
    result <- readRDS(invocation$OutputPath)
    mfrmr_gtvo_assert_worker_result(
      result, modes[[index]], request, refusal_worker_environment
    )
    if (identical(modes[[index]], "normal")) {
      normal_receipt <- result$RefusalReceipt
    }
    denial_class <- if (identical(modes[[index]], "normal")) {
      "normal_refusal_receipt"
    } else if (identical(modes[[index]], "probe_parent_environment") &&
               identical(result$ActionMessage,
                         "environment_variable_absent")) {
      "parent_environment_absent"
    } else if (grepl(
      paste0(
        "operation not permitted|permission denied|error in running command|",
        "sandbox_exec_status_[1-9]"
      ),
      result$ActionMessage, ignore.case = TRUE
    )) {
      "sandbox_operation_denied"
    } else {
      "unexpected_failure_class"
    }
    rows[[index]] <- data.frame(
      ControlOrdinal = as.integer(index), Mode = modes[[index]],
      SandboxExitStatus = invocation$Status,
      OutputReceiptExists = invocation$OutputExists,
      ActionSucceeded = result$ActionSucceeded,
      ParentSecretVisible = result$ParentSecretVisible,
      ControlPassed = result$ControlPassed,
      DenialClass = denial_class,
      ActionMessageHash = mfrmr_gtvo_hash(result$ActionMessage),
      ResultHash = result$ResultHash,
      stringsAsFactors = FALSE
    )
  }
  controls <- do.call(rbind, rows)
  row.names(controls) <- NULL
  expected_classes <- c(
    "normal_refusal_receipt", rep("sandbox_operation_denied", 3L),
    "parent_environment_absent", "sandbox_operation_denied"
  )
  if (!identical(controls$DenialClass, expected_classes) ||
      file.exists(outside_target)) {
    stop(
      "A Draft.85c4h denial control failed: ",
      paste(paste0(controls$Mode, "=", controls$DenialClass),
            collapse = ", "),
      if (file.exists(outside_target)) ", outside_file_created" else "",
      ".", call. = FALSE
    )
  }
  profile_semantic <- gsub(
    normalizePath(staging$Root, mustWork = TRUE), "<STAGING_ROOT>",
    profile_text, fixed = TRUE
  )
  implementation <- mfrmr_gtvo_implementation_identity()
  payload <- list(
    Contract = "gtheory_multivariate_qualification_capability_draft85c4h_v1",
    C4GManifestHash = c4g_manifest$ManifestHash,
    ProtocolManifestHash = request$ProtocolManifestHash,
    QualificationPolicyHash = request$QualificationPolicyHash,
    EnvironmentIdentityHash = request$EnvironmentIdentityHash,
    BundleRegistryHash = request$BundleRegistryHash,
    RefusalWorkerSourceSHA256 = request$WorkerSourceSHA256,
    RequestHash = request$RequestHash,
    RuntimeIdentity = runtime,
    RuntimeIdentityHash = mfrmr_gtvo_hash(runtime),
    ProfileHash = mfrmr_gtvo_hash(profile_text),
    ProfileSemanticHash = mfrmr_gtvo_hash(profile_semantic),
    PolicyAudit = policy_audit,
    PolicyAuditHash = mfrmr_gtvo_hash(policy_audit),
    ControlRegistry = controls,
    ControlRegistryHash = mfrmr_gtvo_hash(controls),
    NormalRefusalReceiptHash = normal_receipt$ReceiptHash,
    SyntheticVaultHash = mfrmr_gtvo_hash(synthetic_vault),
    CapabilityWorkerIdentity = capability_identity,
    CapabilityWorkerIdentityHash = mfrmr_gtvo_hash(capability_identity),
    ImplementationIdentity = implementation,
    ImplementationIdentityHash = mfrmr_gtvo_hash(implementation),
    StagingContentRetained = isTRUE(keep_staging),
    PlannedSeedMaterialIncluded = FALSE,
    FullB1ObjectsIncluded = FALSE,
    ReferenceTruthIncluded = FALSE,
    ConQuestRouteIncluded = FALSE
  )
  evidence <- structure(c(payload, list(
    EvidenceHash = mfrmr_gtvo_hash(payload),
    DefaultDenyProfileReady = TRUE,
    SanitizedEnvironmentReady = TRUE,
    HashOnlyInputReadReady = TRUE,
    RefusalReceiptWriteReady = TRUE,
    SyntheticVaultReadDenied = TRUE,
    SourceTreeReadDenied = TRUE,
    OutsideWriteDenied = TRUE,
    ParentEnvironmentSecretAbsent = TRUE,
    UnlistedExecutableDenied = TRUE,
    ExternalNetworkPolicyClosed = TRUE,
    ProcessCapabilityIsolationReady = TRUE,
    HashOnlyRefusalBoundaryReady = TRUE,
    FreshProcessRefusalObserved = TRUE,
    RefusalOnlyWorkerReady = TRUE,
    EnvironmentReadyForBackendQualification = FALSE,
    RepairRequired = TRUE,
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
  )), class = c("mfrmr_gtvo_live_evidence", "list"))
  if (!isTRUE(keep_staging)) {
    mfrmr_gtvo_assert_live_evidence(
      evidence, refusal_worker_environment, capability_worker_environment,
      c4g_manifest, protocol_manifest, repo_root
    )
  }
  evidence
}

mfrmr_gtvo_dispatch_guard <- function(
    evidence, action, callback, ..., authorize = FALSE,
    refusal_worker_environment, capability_worker_environment,
    c4g_manifest, protocol_manifest, repo_root = ".") {
  mfrmr_gtvo_assert_live_evidence(
    evidence, refusal_worker_environment, capability_worker_environment,
    c4g_manifest, protocol_manifest, repo_root
  )
  if (!is.character(action) || length(action) != 1L || is.na(action) ||
      !action %in% c("qualification_worker", "backend_fit", "receipt_trust")) {
    stop("The Draft.85c4h action is outside refusal isolation.",
         call. = FALSE)
  }
  if (!is.function(callback)) {
    stop("`callback` must be a function.", call. = FALSE)
  }
  if (!is.logical(authorize) || length(authorize) != 1L || is.na(authorize)) {
    stop("`authorize` must be TRUE or FALSE.", call. = FALSE)
  }
  stop(
    "Draft.85c4h isolates only refusal; qualification remains closed.",
    call. = FALSE
  )
}
