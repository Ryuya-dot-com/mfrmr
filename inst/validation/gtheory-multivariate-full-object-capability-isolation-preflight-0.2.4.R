# Draft.85c4k full-object qualification capability isolation.
#
# Repository-internal only. The portable layer seals the runtime, exact loaded
# package/native closure, default-deny profile, result schemas, and promotion
# semantics. Live macOS execution reruns the complete Draft.85c4j worker and
# five denial controls under that profile.

mfrmr_gtvr_require_primitives <- function() {
  required <- c(
    "mfrmr_gtvq_assert_receipt", "mfrmr_gtvq_assert_worker_receipt",
    "mfrmr_gtvq_hash", "mfrmr_gtvq_worker_identity"
  )
  target <- environment(mfrmr_gtvr_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the Draft.85c4j chain before Draft.85c4k: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtvr_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4k requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvr_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    identical(sort(names(attributes(object))), c("class", "names"))
}

mfrmr_gtvr_file_hash <- function(path) {
  if (!is.character(path) || length(path) != 1L || is.na(path) ||
      !file.exists(path) || dir.exists(path)) {
    stop("A Draft.85c4k runtime file is missing.", call. = FALSE)
  }
  digest::digest(
    file = normalizePath(path, mustWork = TRUE), algo = "sha256",
    serialize = FALSE
  )
}

mfrmr_gtvr_function_hash <- function(fun) {
  if (!is.function(fun)) {
    stop("A Draft.85c4k implementation function is missing.", call. = FALSE)
  }
  mfrmr_gtvr_hash(list(
    Formals = paste(deparse(formals(fun), width.cutoff = 500L),
                    collapse = "\n"),
    Body = paste(deparse(body(fun), width.cutoff = 500L), collapse = "\n")
  ))
}

mfrmr_gtvr_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtvr_require_primitives", "mfrmr_gtvr_hash",
    "mfrmr_gtvr_exact_object", "mfrmr_gtvr_file_hash",
    "mfrmr_gtvr_function_hash", "mfrmr_gtvr_implementation_identity",
    "mfrmr_gtvr_capability_worker_identity", "mfrmr_gtvr_quote_profile",
    "mfrmr_gtvr_runtime_identity", "mfrmr_gtvr_staging",
    "mfrmr_gtvr_capability_request",
    "mfrmr_gtvr_policy_text", "mfrmr_gtvr_policy_audit",
    "mfrmr_gtvr_synthetic_vault", "mfrmr_gtvr_worker_payload_fields",
    "mfrmr_gtvr_assert_worker_result", "mfrmr_gtvr_invoke",
    "mfrmr_gtvr_trusted_route_registry",
    "mfrmr_gtvr_trusted_pair_registry", "mfrmr_gtvr_live_payload_fields",
    "mfrmr_gtvr_assert_live_evidence", "mfrmr_gtvr_live_preflight",
    "mfrmr_gtvr_dispatch_guard"
  )
  target <- environment(mfrmr_gtvr_implementation_identity)
  data.frame(
    Function = functions,
    SHA256 = vapply(functions, function(name) {
      if (!exists(name, envir = target, inherits = FALSE)) {
        stop("A Draft.85c4k function is missing: ", name, ".",
             call. = FALSE)
      }
      mfrmr_gtvr_function_hash(get(name, envir = target, inherits = FALSE))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvr_capability_worker_identity <- function(worker_environment) {
  functions <- c(
    "mfrmr_gtvrw_hash", "mfrmr_gtvrw_attempt", "mfrmr_gtvrw_probe",
    "mfrmr_gtvrw_run_qualification", "mfrmr_gtvrw_main"
  )
  if (!is.environment(worker_environment) ||
      !identical(parent.env(worker_environment), baseenv()) ||
      !identical(
        sort(ls(worker_environment, all.names = TRUE), method = "radix"),
        sort(functions, method = "radix")
      ) || !all(vapply(functions, function(name) {
        is.function(get(name, envir = worker_environment, inherits = FALSE))
      }, logical(1L)))) {
    stop("The Draft.85c4k capability-worker namespace was altered.",
         call. = FALSE)
  }
  data.frame(
    Function = functions,
    SHA256 = vapply(functions, function(name) {
      mfrmr_gtvr_function_hash(get(
        name, envir = worker_environment, inherits = FALSE
      ))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvr_quote_profile <- function(path) {
  encodeString(normalizePath(path, mustWork = FALSE), quote = "\"")
}

mfrmr_gtvr_runtime_identity <- function(
    qualification_receipt, repair_receipt,
    validation_dir = file.path("inst", "validation")) {
  validation_dir <- normalizePath(validation_dir, mustWork = TRUE)
  sandbox_exec <- normalizePath("/usr/bin/sandbox-exec", mustWork = TRUE)
  environment_exec <- normalizePath("/usr/bin/env", mustWork = TRUE)
  r_home <- normalizePath(R.home(), mustWork = TRUE)
  r_exec <- normalizePath(file.path(r_home, "bin", "exec", "R"),
                          mustWork = TRUE)
  system_profile <- normalizePath(
    "/System/Library/Sandbox/Profiles/system.sb", mustWork = TRUE
  )
  qualification_worker <- normalizePath(file.path(
    validation_dir,
    "gtheory-multivariate-full-object-qualification-worker-0.2.4.R"
  ), mustWork = TRUE)
  capability_worker <- normalizePath(file.path(
    validation_dir,
    "gtheory-multivariate-full-object-capability-worker-0.2.4.R"
  ), mustWork = TRUE)
  qualification_hash <- mfrmr_gtvr_file_hash(qualification_worker)
  capability_hash <- mfrmr_gtvr_file_hash(capability_worker)
  if (!identical(
    qualification_hash, qualification_receipt$WorkerSourceSHA256
  ) || !identical(
    qualification_hash,
    "45d4ff14ba7db53d53a92652f45ef18fad7934c6ca1ac17b3bf5d5daef9898fb"
  )) {
    stop("The sealed Draft.85c4j qualification worker changed.",
         call. = FALSE)
  }
  if (!identical(
    capability_hash,
    "c6ac70e1ae5fe81a7228937b3d5dda014f5ab71c82ed00c41673d56eebe66fb2"
  )) {
    stop("The sealed Draft.85c4k capability worker changed.",
         call. = FALSE)
  }
  link_paths <- c(
    "/opt/homebrew/opt/gcc/lib/gcc/current/libgfortran.5.dylib",
    "/opt/homebrew/opt/gcc/lib/gcc/current/libquadmath.0.dylib"
  )
  if (!all(file.exists(link_paths))) {
    stop("The Draft.85c4k linked Fortran runtime is incomplete.",
         call. = FALSE)
  }
  linked_runtime <- data.frame(
    Runtime = c("libgfortran.dylib", "libquadmath.dylib"),
    LinkPath = link_paths,
    ResolvedPath = vapply(link_paths, normalizePath, character(1L),
                          mustWork = TRUE),
    SHA256 = vapply(link_paths, mfrmr_gtvr_file_hash, character(1L)),
    stringsAsFactors = FALSE
  )
  expected_runtime <- repair_receipt$ToolchainIdentity$RuntimeRegistry
  matched <- match(linked_runtime$Runtime, expected_runtime$Runtime)
  if (anyNA(matched) || !identical(
    linked_runtime$SHA256, expected_runtime$SHA256[matched]
  )) {
    stop("The Draft.85c4k linked runtime identity changed.", call. = FALSE)
  }
  namespaces <- qualification_receipt$FreshProcessReceipt$
    LoadedNamespaceRegistry
  native <- qualification_receipt$FreshProcessReceipt$
    LoadedNativeBinaryRegistry
  package_paths <- sort(unique(namespaces$PackagePath), method = "radix")
  external_native_paths <- sort(unique(c(
    dirname(linked_runtime$LinkPath), dirname(linked_runtime$ResolvedPath),
    dirname(native$NativeBinaryPath[
      !vapply(native$NativeBinaryPath, function(path) {
        any(startsWith(
          path, paste0(package_paths, .Platform$file.sep)
        ))
      }, logical(1L))
    ])
  )), method = "radix")
  traversal_sources <- c(
    package_paths, external_native_paths, linked_runtime$LinkPath,
    linked_runtime$ResolvedPath
  )
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
    Contract = "gtheory_multivariate_c4k_runtime_identity_v1",
    OS = Sys.info()[["sysname"]],
    OSRelease = Sys.info()[["release"]],
    OSVersion = Sys.info()[["version"]],
    Machine = Sys.info()[["machine"]],
    RVersion = R.version.string,
    RuntimeLocale = "C.UTF-8",
    SandboxExecutable = sandbox_exec,
    SandboxExecutableHash = mfrmr_gtvr_file_hash(sandbox_exec),
    EnvironmentExecutable = environment_exec,
    EnvironmentExecutableHash = mfrmr_gtvr_file_hash(environment_exec),
    RHome = r_home,
    RExecutable = r_exec,
    RExecutableHash = mfrmr_gtvr_file_hash(r_exec),
    SystemProfile = system_profile,
    SystemProfileHash = mfrmr_gtvr_file_hash(system_profile),
    ValidationDirectory = validation_dir,
    QualificationWorkerPath = qualification_worker,
    QualificationWorkerHash = qualification_hash,
    CapabilityWorkerPath = capability_worker,
    CapabilityWorkerHash = capability_hash,
    NamespaceRegistryHash =
      qualification_receipt$FreshProcessReceipt$LoadedNamespaceRegistryHash,
    NativeBinaryRegistryHash = qualification_receipt$FreshProcessReceipt$
      LoadedNativeBinaryRegistryHash,
    PackageReadPaths = package_paths,
    PackageReadPathsHash = mfrmr_gtvr_hash(package_paths),
    TraversalReadPaths = traversal_paths,
    TraversalReadPathsHash = mfrmr_gtvr_hash(traversal_paths),
    ExternalNativeReadPaths = external_native_paths,
    ExternalNativeReadPathsHash = mfrmr_gtvr_hash(external_native_paths),
    LinkedRuntimeRegistry = linked_runtime,
    LinkedRuntimeRegistryHash = mfrmr_gtvr_hash(linked_runtime)
  )
  structure(c(payload, list(
    RuntimeIdentityHash = mfrmr_gtvr_hash(payload)
  )), class = c("mfrmr_gtvr_runtime", "list"))
}

mfrmr_gtvr_staging <- function(root) {
  root <- normalizePath(root, mustWork = TRUE)
  paths <- list(
    Root = root,
    AllowedRoot = file.path(root, "allowed"),
    DeniedRoot = file.path(root, "denied")
  )
  if (!all(vapply(paths[-1L], dir.create, logical(1L), recursive = FALSE))) {
    stop("Draft.85c4k could not create exact staging directories.",
         call. = FALSE)
  }
  paths <- c(paths, list(
    Input = file.path(paths$AllowedRoot, "input"),
    Worker = file.path(paths$AllowedRoot, "worker"),
    Source = file.path(paths$AllowedRoot, "source"),
    RuntimeLibrary = file.path(paths$AllowedRoot, "runtime-library"),
    Output = file.path(paths$AllowedRoot, "output"),
    Scratch = file.path(paths$AllowedRoot, "scratch"),
    Vault = file.path(paths$DeniedRoot, "vault"),
    ForbiddenOutput = file.path(paths$DeniedRoot, "forbidden-output")
  ))
  children <- setdiff(names(paths), c("Root", "AllowedRoot", "DeniedRoot"))
  if (!all(vapply(paths[children], dir.create, logical(1L),
                  recursive = FALSE))) {
    stop("Draft.85c4k could not create staging children.", call. = FALSE)
  }
  lapply(paths, normalizePath, mustWork = TRUE)
}

mfrmr_gtvr_capability_request <- function(request, staging) {
  required_staging <- c(
    "Root", "AllowedRoot", "DeniedRoot", "Input", "Worker", "Source",
    "RuntimeLibrary", "Output", "Scratch", "Vault", "ForbiddenOutput"
  )
  if (!inherits(request, "mfrmr_gtvqw_request") ||
      !is.list(staging) || !identical(names(staging), required_staging)) {
    stop("A qualification request and exact c4k staging are required.",
         call. = FALSE)
  }
  payload <- request[setdiff(names(request), "RequestHash")]
  payload$RepairRoot <- staging$AllowedRoot
  payload$OverlayLibrary <- staging$RuntimeLibrary
  structure(c(payload, list(
    RequestHash = mfrmr_gtvr_hash(payload)
  )), class = c("mfrmr_gtvqw_request", "list"))
}

mfrmr_gtvr_policy_text <- function(runtime, staging) {
  if (!inherits(runtime, "mfrmr_gtvr_runtime")) {
    stop("A typed Draft.85c4k runtime identity is required.", call. = FALSE)
  }
  required_staging <- c(
    "Root", "AllowedRoot", "DeniedRoot", "Input", "Worker", "Source",
    "RuntimeLibrary", "Output", "Scratch", "Vault", "ForbiddenOutput"
  )
  if (!is.list(staging) || !identical(names(staging), required_staging)) {
    stop("The Draft.85c4k staging identity is invalid.", call. = FALSE)
  }
  q <- mfrmr_gtvr_quote_profile
  r_framework <- normalizePath(
    file.path(runtime$RHome, "..", "..", ".."), mustWork = TRUE
  )
  package_rules <- paste0("  (subpath ", vapply(
    runtime$PackageReadPaths, q, character(1L)
  ), ")")
  native_rules <- paste0("  (subpath ", vapply(
    runtime$ExternalNativeReadPaths, q, character(1L)
  ), ")")
  traversal_rules <- paste0("  (literal ", vapply(
    runtime$TraversalReadPaths, q, character(1L)
  ), ")")
  metadata_roots <- c("/Library", "/private/tmp", "/opt/homebrew")
  metadata_rules <- paste0("  (subpath ", vapply(
    metadata_roots, q, character(1L)
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
    "  (subpath \"/System/Library\")",
    package_rules, native_rules, ")",
    "(allow file-read-metadata file-test-existence",
    metadata_rules,
    paste0("  (subpath ", q(staging$AllowedRoot), "))"),
    "(allow file-read*",
    "  (literal \"/private/var/select/sh\")",
    "  (literal \"/bin/sh\")",
    traversal_rules,
    paste0("  (literal ", q(staging$Root), ")"),
    paste0("  (subpath ", q(staging$AllowedRoot), "))"),
    "(allow file-write*",
    paste0("  (subpath ", q(staging$Output), ")"),
    paste0("  (subpath ", q(staging$Scratch), "))")
  )
  paste(lines, collapse = "\n")
}

mfrmr_gtvr_policy_audit <- function(profile_text, runtime, staging) {
  q <- mfrmr_gtvr_quote_profile
  package_rules <- paste0("(subpath ", vapply(
    runtime$PackageReadPaths, q, character(1L)
  ), ")")
  data.frame(
    Rule = c(
      "version_one", "default_deny", "system_profile_import",
      "no_allow_default", "no_network_allow", "no_vault_path",
      "no_forbidden_output_path", "no_denied_root_path",
      "no_repository_path", "all_runtime_traversal_literals",
      "root_traversal_literal_read",
      "allowed_root_read", "input_allow",
      "worker_allow", "staged_source_allow", "runtime_library_allow",
      "output_allow", "scratch_allow", "sanitized_env_exec_allow",
      "r_exec_allow", "all_package_paths_exact",
      "external_native_paths_bound"
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
      startsWith(staging$Source, paste0(
        staging$AllowedRoot, .Platform$file.sep
      )),
      startsWith(staging$RuntimeLibrary, paste0(
        staging$AllowedRoot, .Platform$file.sep
      )),
      grepl(staging$Output, profile_text, fixed = TRUE),
      grepl(staging$Scratch, profile_text, fixed = TRUE),
      grepl(runtime$EnvironmentExecutable, profile_text, fixed = TRUE),
      grepl(runtime$RExecutable, profile_text, fixed = TRUE),
      all(vapply(package_rules, grepl, logical(1L), x = profile_text,
                 fixed = TRUE)),
      all(vapply(runtime$ExternalNativeReadPaths, function(path) {
        grepl(normalizePath(path, mustWork = TRUE), profile_text,
              fixed = TRUE)
      }, logical(1L)))
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvr_synthetic_vault <- function(request) {
  list(
    Contract = "gtheory_multivariate_c4k_synthetic_denied_vault_v1",
    RequestHash = request$RequestHash,
    SyntheticForbiddenToken = mfrmr_gtvr_hash(list(
      Namespace = "gtheory_multivariate_c4k_denied_token_v1",
      RequestHash = request$RequestHash
    )),
    ContainsPlannedSeed = FALSE,
    ContainsResponse = FALSE,
    ContainsTruth = FALSE
  )
}

mfrmr_gtvr_worker_payload_fields <- function() {
  c(
    "Contract", "Mode", "RunToken", "RequestHash", "WorkerSourceSHA256",
    "SourceRegistryHash", "EnvironmentNames", "EnvironmentNamesHash",
    "ParentSecretVisible", "ActionSucceeded", "ActionMessage",
    "QualificationExitStatus", "QualificationProcessOutput",
    "QualificationReceipt", "QualificationReceiptHash", "ControlPassed"
  )
}

mfrmr_gtvr_assert_worker_result <- function(
    result, expected_mode, qualification_receipt, capability_request,
    repair_receipt, qualification_worker_environment) {
  payload_fields <- mfrmr_gtvr_worker_payload_fields()
  suffix_fields <- c(
    "ResultHash", "WorkerSelfReported", "ProcessCapabilityIsolationReady",
    "TrustedReceiptProduced", "QualificationEvidenceReady",
    "BackendQualificationReady", "PlannedExecutionAuthorized",
    "RecoveryEvidenceReady", "EstimationReady", "InferenceReady",
    "DecisionReady", "PublicSupportReady"
  )
  if (!mfrmr_gtvr_exact_object(
    result, c(payload_fields, suffix_fields),
    c("mfrmr_gtvrw_result", "list")
  )) {
    stop("A typed Draft.85c4k worker result is required.", call. = FALSE)
  }
  request <- capability_request
  candidate_request <- qualification_receipt$Request
  request_common <- setdiff(
    names(candidate_request), c("RepairRoot", "OverlayLibrary", "RequestHash")
  )
  negative <- !identical(expected_mode, "normal")
  valid <- identical(
    result$Contract,
    "gtheory_multivariate_full_object_capability_worker_draft85c4k_v1"
  ) && identical(result$Mode, expected_mode) &&
    grepl("^C4K-[0-9a-f]{24}$", result$RunToken) &&
    identical(result$RequestHash, request$RequestHash) &&
    identical(result$WorkerSourceSHA256, request$WorkerSourceSHA256) &&
    identical(result$SourceRegistryHash, request$SourceRegistryHash) &&
    identical(request[request_common], candidate_request[request_common]) &&
    identical(request$RepairRoot, dirname(request$OverlayLibrary)) &&
    identical(
      request$RequestHash,
      mfrmr_gtvr_hash(request[setdiff(names(request), "RequestHash")])
    ) &&
    identical(result$EnvironmentNamesHash,
              mfrmr_gtvr_hash(result$EnvironmentNames)) &&
    !isTRUE(result$ParentSecretVisible) &&
    identical(isTRUE(result$ActionSucceeded), !negative) &&
    isTRUE(result$ControlPassed) &&
    identical(result$ResultHash, mfrmr_gtvr_hash(result[payload_fields])) &&
    isTRUE(result$WorkerSelfReported) &&
    !any(vapply(result[c(
      "ProcessCapabilityIsolationReady", "TrustedReceiptProduced",
      "QualificationEvidenceReady", "BackendQualificationReady",
      "PlannedExecutionAuthorized", "RecoveryEvidenceReady",
      "EstimationReady", "InferenceReady", "DecisionReady",
      "PublicSupportReady"
    )], isTRUE, logical(1L)))
  if (!negative) {
    capability_repair <- repair_receipt
    capability_repair$RepairRoot <- request$RepairRoot
    capability_repair$OverlayLibrary <- request$OverlayLibrary
    inner_valid <- tryCatch({
      mfrmr_gtvq_assert_worker_receipt(
        result$QualificationReceipt, request, capability_repair,
        qualification_worker_environment, controller_process_id = Sys.getpid()
      )
      TRUE
    }, error = function(condition) FALSE)
    candidate <- qualification_receipt$FreshProcessReceipt
    divergent <- c(
      "RequestHash", "ProcessIdentity", "ProcessIdentityHash", "ReceiptHash"
    )
    stable_fields <- setdiff(names(candidate), divergent)
    exact_numerical_identity <- inner_valid && identical(
      result$QualificationReceipt[stable_fields], candidate[stable_fields]
    ) && !identical(
      result$QualificationReceipt$ProcessIdentity$ProcessId,
      candidate$ProcessIdentity$ProcessId
    )
    valid <- valid && exact_numerical_identity &&
      identical(result$QualificationExitStatus, 0L) &&
      length(result$QualificationProcessOutput) == 0L &&
      identical(result$QualificationReceiptHash,
                result$QualificationReceipt$ReceiptHash)
  } else {
    valid <- valid && is.na(result$QualificationExitStatus) &&
      length(result$QualificationProcessOutput) == 0L &&
      is.null(result$QualificationReceipt) &&
      is.na(result$QualificationReceiptHash)
  }
  if (!valid) {
    stop("The Draft.85c4k worker result or qualification identity changed.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvr_invoke <- function(
    runtime, staging, profile_path, capability_worker_path,
    qualification_worker_path, request_path, source_dir, overlay, mode,
    target, run_token, library_order) {
  output_path <- file.path(staging$Output, paste0(mode, ".rds"))
  arguments <- c(
    "-f", shQuote(profile_path),
    shQuote(runtime$EnvironmentExecutable), "-i",
    paste0("R_HOME=", shQuote(runtime$RHome)),
    paste0("R_LIBS_USER=", shQuote(library_order)),
    paste0("TMPDIR=", shQuote(staging$Scratch)),
    "PATH=/usr/bin:/bin",
    paste0("LANG=", runtime$RuntimeLocale),
    paste0("LC_ALL=", runtime$RuntimeLocale), "TZ=UTC",
    shQuote(runtime$RExecutable), "--vanilla", "--slave",
    paste0("--file=", shQuote(capability_worker_path)), "--args",
    shQuote(mode), shQuote(qualification_worker_path), shQuote(request_path),
    shQuote(source_dir), shQuote(overlay), shQuote(output_path),
    shQuote(target), shQuote(run_token), shQuote(runtime$RExecutable)
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

mfrmr_gtvr_trusted_route_registry <- function(
    qualification_receipt, sandbox_receipt, profile_semantic_hash) {
  policy <- mfrmr_gtvm_qualification_policy()
  data.frame(
    RouteOrdinal = policy$RouteRegistry$RouteOrdinal,
    RouteId = policy$RouteRegistry$RouteId,
    RevalidatedRouteReceiptHash = vapply(
      qualification_receipt$RouteReceipts,
      function(item) item$ReceiptHash, character(1L)
    ),
    SandboxFitObjectHash = sandbox_receipt$RouteObjectRegistry$
      FullFitObjectHash,
    CapabilityProfileSemanticHash = rep(profile_semantic_hash, 4L),
    FullB1ObjectRevalidated = rep(TRUE, 4L),
    ProcessCapabilityIsolationReady = rep(TRUE, 4L),
    TrustedReceiptReady = rep(TRUE, 4L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvr_trusted_pair_registry <- function(
    qualification_receipt, sandbox_receipt, profile_semantic_hash) {
  policy <- mfrmr_gtvm_qualification_policy()
  data.frame(
    PairOrdinal = policy$PairRegistry$PairOrdinal,
    PairId = policy$PairRegistry$PairId,
    RevalidatedPairReceiptHash = vapply(
      qualification_receipt$PairReceipts,
      function(item) item$ReceiptHash, character(1L)
    ),
    SandboxParityObjectHash = sandbox_receipt$PairObjectRegistry$
      FullParityObjectHash,
    CapabilityProfileSemanticHash = rep(profile_semantic_hash, 2L),
    FullB1ObjectRevalidated = rep(TRUE, 2L),
    ProcessCapabilityIsolationReady = rep(TRUE, 2L),
    TrustedPairReady = rep(TRUE, 2L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvr_live_payload_fields <- function() {
  c(
    "Contract", "C4JQualificationReceiptHash", "C4IRepairReceiptHash",
    "C4FPolicyHash", "CandidateRequestHash", "CapabilityRequest",
    "CapabilityRequestHash", "WorkerSourceSHA256",
    "SourceRegistryHash", "RuntimeIdentity", "RuntimeIdentityHash",
    "StagedRuntimeRegistry", "StagedRuntimeRegistryHash",
    "ProfileHash", "ProfileSemanticHash", "PolicyAudit", "PolicyAuditHash",
    "ControlRegistry", "ControlRegistryHash", "ControlResults",
    "ControlResultsHash", "NormalQualificationReceiptHash",
    "TrustedRouteRegistry", "TrustedRouteRegistryHash",
    "TrustedPairRegistry", "TrustedPairRegistryHash", "SyntheticVaultHash",
    "CapabilityWorkerIdentity", "CapabilityWorkerIdentityHash",
    "ImplementationIdentity", "ImplementationIdentityHash",
    "StagingContentRetained", "PlannedSeedMaterialIncluded",
    "ReferenceTruthIncluded", "ConQuestRouteIncluded"
  )
}

mfrmr_gtvr_assert_live_evidence <- function(
    evidence, qualification_receipt, repair_receipt,
    repair_worker_environment, c4e_manifest, c4f_manifest,
    qualification_worker_environment, capability_worker_environment,
    repo_root = ".", validation_dir = file.path("inst", "validation")) {
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  validation_dir <- normalizePath(validation_dir, mustWork = TRUE)
  mfrmr_gtvq_assert_receipt(
    qualification_receipt, repair_receipt, repair_worker_environment,
    c4e_manifest, c4f_manifest, qualification_worker_environment,
    repo_root, validation_dir
  )
  payload_fields <- mfrmr_gtvr_live_payload_fields()
  suffix_fields <- c(
    "EvidenceHash", "DefaultDenyProfileReady",
    "SanitizedEnvironmentReady", "ExactNamespaceReadAllowlistReady",
    "ExactNativeReadAllowlistReady", "StagedSourceReadReady",
    "QualificationReceiptWriteReady", "SyntheticVaultReadDenied",
    "RepositoryReadDenied", "OutsideWriteDenied",
    "ParentEnvironmentSecretAbsent", "UnlistedExecutableDenied",
    "ExternalNetworkPolicyClosed", "ProcessCapabilityIsolationReady",
    "FullObjectQualificationBoundaryReady", "FreshProcessQualificationObserved",
    "QualificationWorkerImplemented", "FullB1ObjectsReceived",
    "RouteReceiptsMaterialized", "PairReceiptsMaterialized",
    "TrustedReceiptProduced", "QualificationEvidenceReady",
    "BackendQualificationReady", "OperationallyAdmissible",
    "DiagnosticOverrideAllowed", "PlannedExecutionAuthorized",
    "ExecutionGateClosed", "BackendExecutionOccurred",
    "PlannedResponseGenerated", "RecoveryExecuted", "RecoveryEvidenceReady",
    "EstimationReady", "InferenceReady", "DecisionReady",
    "PublicSupportReady"
  )
  if (!mfrmr_gtvr_exact_object(
    evidence, c(payload_fields, suffix_fields),
    c("mfrmr_gtvr_live_evidence", "list")
  )) {
    stop("A typed Draft.85c4k live evidence object is required.",
         call. = FALSE)
  }
  runtime <- mfrmr_gtvr_runtime_identity(
    qualification_receipt, repair_receipt, validation_dir
  )
  capability_request <- evidence$CapabilityRequest
  candidate_request <- qualification_receipt$Request
  request_fields <- setdiff(
    names(candidate_request), c("RepairRoot", "OverlayLibrary", "RequestHash")
  )
  capability_request_valid <- mfrmr_gtvr_exact_object(
    capability_request, names(candidate_request), class(candidate_request)
  ) && identical(
    capability_request[request_fields], candidate_request[request_fields]
  ) && identical(
    capability_request$RepairRoot,
    dirname(capability_request$OverlayLibrary)
  ) && identical(
    capability_request$RequestHash,
    mfrmr_gtvr_hash(capability_request[
      setdiff(names(capability_request), "RequestHash")
    ])
  )
  namespaces <- qualification_receipt$FreshProcessReceipt$
    LoadedNamespaceRegistry
  staged_runtime <- data.frame(
    PackageOrdinal = seq_len(nrow(namespaces)),
    Package = namespaces$Package,
    LinkPath = file.path(
      capability_request$OverlayLibrary, namespaces$Package
    ),
    ResolvedPath = namespaces$PackagePath,
    DescriptionSHA256 = namespaces$DescriptionSHA256,
    stringsAsFactors = FALSE
  )
  controls <- evidence$ControlRegistry
  expected_modes <- c(
    "normal", "probe_vault_read", "probe_source_read",
    "probe_outside_write", "probe_parent_environment",
    "probe_unlisted_exec"
  )
  expected_classes <- c(
    "normal_full_qualification", rep("sandbox_operation_denied", 3L),
    "parent_environment_absent", "sandbox_operation_denied"
  )
  exact_controls <- is.data.frame(controls) && nrow(controls) == 6L &&
    identical(controls$ControlOrdinal, 1:6) &&
    identical(controls$Mode, expected_modes) &&
    identical(controls$SandboxExitStatus, rep(0L, 6L)) &&
    all(controls$SandboxProcessOutputEmpty) &&
    all(controls$OutputReceiptExists) &&
    identical(controls$ActionSucceeded, c(TRUE, rep(FALSE, 5L))) &&
    !any(controls$ParentSecretVisible) && all(controls$ControlPassed) &&
    identical(controls$DenialClass, expected_classes) &&
    all(nchar(controls$ActionMessageHash) == 64L) &&
    all(nchar(controls$ResultHash) == 64L)
  if (!is.list(evidence$ControlResults) ||
      !identical(names(evidence$ControlResults), expected_modes)) {
    stop("The Draft.85c4k control-result registry was altered.",
         call. = FALSE)
  }
  for (index in seq_along(expected_modes)) {
    mfrmr_gtvr_assert_worker_result(
      evidence$ControlResults[[index]], expected_modes[[index]],
      qualification_receipt, capability_request, repair_receipt,
      qualification_worker_environment
    )
  }
  normal_receipt <- evidence$ControlResults$normal$QualificationReceipt
  trusted_routes <- mfrmr_gtvr_trusted_route_registry(
    qualification_receipt, normal_receipt, evidence$ProfileSemanticHash
  )
  trusted_pairs <- mfrmr_gtvr_trusted_pair_registry(
    qualification_receipt, normal_receipt, evidence$ProfileSemanticHash
  )
  implementation <- mfrmr_gtvr_implementation_identity()
  capability_identity <- mfrmr_gtvr_capability_worker_identity(
    capability_worker_environment
  )
  ready_flags <- c(
    "DefaultDenyProfileReady", "SanitizedEnvironmentReady",
    "ExactNamespaceReadAllowlistReady", "ExactNativeReadAllowlistReady",
    "StagedSourceReadReady", "QualificationReceiptWriteReady",
    "SyntheticVaultReadDenied", "RepositoryReadDenied",
    "OutsideWriteDenied", "ParentEnvironmentSecretAbsent",
    "UnlistedExecutableDenied", "ExternalNetworkPolicyClosed",
    "ProcessCapabilityIsolationReady", "FullObjectQualificationBoundaryReady",
    "FreshProcessQualificationObserved", "QualificationWorkerImplemented",
    "FullB1ObjectsReceived", "RouteReceiptsMaterialized",
    "PairReceiptsMaterialized", "TrustedReceiptProduced",
    "QualificationEvidenceReady", "BackendQualificationReady",
    "OperationallyAdmissible", "ExecutionGateClosed",
    "BackendExecutionOccurred"
  )
  closed_flags <- c(
    "DiagnosticOverrideAllowed", "PlannedExecutionAuthorized",
    "PlannedResponseGenerated", "RecoveryExecuted", "RecoveryEvidenceReady",
    "EstimationReady", "InferenceReady", "DecisionReady",
    "PublicSupportReady"
  )
  valid <- identical(
    evidence$Contract,
    "gtheory_multivariate_full_object_capability_draft85c4k_v1"
  ) && identical(evidence$C4JQualificationReceiptHash,
                 qualification_receipt$ReceiptHash) &&
    identical(evidence$C4IRepairReceiptHash, repair_receipt$ReceiptHash) &&
    identical(evidence$C4FPolicyHash,
              qualification_receipt$C4FPolicyHash) &&
    identical(evidence$CandidateRequestHash,
              qualification_receipt$RequestHash) &&
    capability_request_valid &&
    identical(evidence$CapabilityRequestHash,
              capability_request$RequestHash) &&
    identical(evidence$WorkerSourceSHA256,
              qualification_receipt$WorkerSourceSHA256) &&
    identical(evidence$SourceRegistryHash,
              qualification_receipt$SourceRegistryHash) &&
    identical(evidence$RuntimeIdentity, runtime) &&
    identical(evidence$RuntimeIdentityHash, runtime$RuntimeIdentityHash) &&
    identical(evidence$StagedRuntimeRegistry, staged_runtime) &&
    identical(evidence$StagedRuntimeRegistryHash,
              mfrmr_gtvr_hash(staged_runtime)) &&
    identical(evidence$PolicyAuditHash,
              mfrmr_gtvr_hash(evidence$PolicyAudit)) &&
    all(evidence$PolicyAudit$Passed) && exact_controls &&
    identical(evidence$ControlRegistryHash, mfrmr_gtvr_hash(controls)) &&
    identical(evidence$ControlResultsHash,
              mfrmr_gtvr_hash(evidence$ControlResults)) &&
    identical(evidence$NormalQualificationReceiptHash,
              normal_receipt$ReceiptHash) &&
    identical(evidence$TrustedRouteRegistry, trusted_routes) &&
    identical(evidence$TrustedRouteRegistryHash,
              mfrmr_gtvr_hash(trusted_routes)) &&
    identical(evidence$TrustedPairRegistry, trusted_pairs) &&
    identical(evidence$TrustedPairRegistryHash,
              mfrmr_gtvr_hash(trusted_pairs)) &&
    all(trusted_routes$TrustedReceiptReady) &&
    all(trusted_pairs$TrustedPairReady) &&
    identical(evidence$CapabilityWorkerIdentity, capability_identity) &&
    identical(evidence$CapabilityWorkerIdentityHash,
              mfrmr_gtvr_hash(capability_identity)) &&
    identical(evidence$ImplementationIdentity, implementation) &&
    identical(evidence$ImplementationIdentityHash,
              mfrmr_gtvr_hash(implementation)) &&
    identical(evidence$EvidenceHash,
              mfrmr_gtvr_hash(evidence[payload_fields])) &&
    !isTRUE(evidence$StagingContentRetained) &&
    !isTRUE(evidence$PlannedSeedMaterialIncluded) &&
    !isTRUE(evidence$ReferenceTruthIncluded) &&
    !isTRUE(evidence$ConQuestRouteIncluded) &&
    all(vapply(ready_flags, function(name) isTRUE(evidence[[name]]),
               logical(1L))) &&
    !any(vapply(closed_flags, function(name) isTRUE(evidence[[name]]),
                logical(1L)))
  if (!valid) {
    stop("The Draft.85c4k live evidence, controls, or readiness changed.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvr_live_preflight <- function(
    qualification_receipt, repair_receipt, repair_worker_environment,
    c4e_manifest, c4f_manifest, qualification_worker_environment,
    capability_worker_environment, repo_root = ".",
    validation_dir = file.path("inst", "validation"),
    authorize_live_sandbox = FALSE, keep_staging = FALSE) {
  if (!identical(Sys.info()[["sysname"]], "Darwin")) {
    stop("Draft.85c4k live isolation requires macOS.", call. = FALSE)
  }
  if (!isTRUE(authorize_live_sandbox)) {
    stop("Live c4k isolation requires `authorize_live_sandbox=TRUE`.",
         call. = FALSE)
  }
  if (!is.logical(keep_staging) || length(keep_staging) != 1L ||
      is.na(keep_staging)) {
    stop("`keep_staging` must be TRUE or FALSE.", call. = FALSE)
  }
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  validation_dir <- normalizePath(validation_dir, mustWork = TRUE)
  mfrmr_gtvq_assert_receipt(
    qualification_receipt, repair_receipt, repair_worker_environment,
    c4e_manifest, c4f_manifest, qualification_worker_environment,
    repo_root, validation_dir
  )
  runtime <- mfrmr_gtvr_runtime_identity(
    qualification_receipt, repair_receipt, validation_dir
  )
  capability_identity <- mfrmr_gtvr_capability_worker_identity(
    capability_worker_environment
  )
  root <- file.path("/private/tmp", paste0("mfrmr-c4k-", substr(
    mfrmr_gtvr_hash(list(
      Namespace = "gtheory_multivariate_c4k_staging_v1",
      C4JReceiptHash = qualification_receipt$ReceiptHash,
      RuntimeIdentityHash = runtime$RuntimeIdentityHash
    )), 1L, 16L
  )))
  if (file.exists(root) || dir.exists(root)) {
    stop("The deterministic Draft.85c4k staging path is occupied.",
         call. = FALSE)
  }
  if (!dir.create(root)) {
    stop("Draft.85c4k could not create temporary staging.", call. = FALSE)
  }
  if (!isTRUE(keep_staging)) {
    on.exit(unlink(root, recursive = TRUE), add = TRUE)
  }
  staging <- mfrmr_gtvr_staging(root)
  namespaces <- qualification_receipt$FreshProcessReceipt$
    LoadedNamespaceRegistry
  link_paths <- file.path(staging$RuntimeLibrary, namespaces$Package)
  links_created <- file.symlink(namespaces$PackagePath, link_paths)
  staged_runtime <- data.frame(
    PackageOrdinal = seq_len(nrow(namespaces)),
    Package = namespaces$Package,
    LinkPath = link_paths,
    ResolvedPath = vapply(
      link_paths, normalizePath, character(1L), mustWork = TRUE
    ),
    DescriptionSHA256 = vapply(link_paths, function(path) {
      mfrmr_gtvr_file_hash(file.path(path, "DESCRIPTION"))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
  row.names(staged_runtime) <- NULL
  if (!all(links_created) || !identical(
    staged_runtime$ResolvedPath, namespaces$PackagePath
  ) || !identical(
    staged_runtime$DescriptionSHA256, namespaces$DescriptionSHA256
  )) {
    stop("The Draft.85c4k staged runtime closure changed.", call. = FALSE)
  }
  candidate_request <- qualification_receipt$Request
  request <- mfrmr_gtvr_capability_request(candidate_request, staging)
  request_path <- file.path(staging$Input, "qualification-request.rds")
  saveRDS(request, request_path, version = 3L)
  synthetic_vault <- mfrmr_gtvr_synthetic_vault(request)
  vault_path <- file.path(staging$Vault, "synthetic-denied-vault.rds")
  saveRDS(synthetic_vault, vault_path, version = 3L)
  qualification_worker_path <- file.path(
    staging$Worker, "qualification-worker.R"
  )
  capability_worker_path <- file.path(
    staging$Worker, "capability-worker.R"
  )
  copied_workers <- c(
    file.copy(runtime$QualificationWorkerPath, qualification_worker_path),
    file.copy(runtime$CapabilityWorkerPath, capability_worker_path)
  )
  source_registry <- qualification_receipt$SourceRegistry
  copied_sources <- file.copy(
    file.path(validation_dir, source_registry$FileName),
    file.path(staging$Source, source_registry$FileName)
  )
  staged_registry <- mfrmr_gtvq_source_registry(staging$Source)
  if (!all(c(copied_workers, copied_sources)) ||
      !identical(mfrmr_gtvr_file_hash(qualification_worker_path),
                 runtime$QualificationWorkerHash) ||
      !identical(mfrmr_gtvr_file_hash(capability_worker_path),
                 runtime$CapabilityWorkerHash) ||
      !identical(staged_registry, source_registry)) {
    stop("The Draft.85c4k staged identity did not match.", call. = FALSE)
  }
  repository_target <- normalizePath(file.path(
    validation_dir,
    "gtheory-multivariate-full-object-capability-isolation-preflight-0.2.4.R"
  ), mustWork = TRUE)
  outside_target <- file.path(staging$ForbiddenOutput, "leak.rds")
  profile_text <- mfrmr_gtvr_policy_text(runtime, staging)
  policy_audit <- mfrmr_gtvr_policy_audit(profile_text, runtime, staging)
  if (!all(policy_audit$Passed)) {
    stop("The Draft.85c4k default-deny policy audit failed.", call. = FALSE)
  }
  profile_path <- file.path(root, "qualification-profile.sb")
  writeLines(profile_text, profile_path, useBytes = TRUE)
  modes <- c(
    "normal", "probe_vault_read", "probe_source_read",
    "probe_outside_write", "probe_parent_environment",
    "probe_unlisted_exec"
  )
  targets <- c(
    "none", vault_path, repository_target, outside_target,
    "MFRMR_C4K_PARENT_SECRET", "/bin/cat"
  )
  old_secret <- Sys.getenv("MFRMR_C4K_PARENT_SECRET", unset = NA_character_)
  on.exit({
    if (is.na(old_secret)) Sys.unsetenv("MFRMR_C4K_PARENT_SECRET") else
      Sys.setenv(MFRMR_C4K_PARENT_SECRET = old_secret)
  }, add = TRUE)
  Sys.setenv(MFRMR_C4K_PARENT_SECRET = "synthetic-parent-only-secret")
  library_order <- staging$RuntimeLibrary
  rows <- list()
  results <- list()
  for (index in seq_along(modes)) {
    run_token <- paste0("C4K-", substr(mfrmr_gtvr_hash(list(
      Namespace = "gtheory_multivariate_c4k_run_v1",
      RequestHash = request$RequestHash, Mode = modes[[index]],
      RuntimeIdentityHash = runtime$RuntimeIdentityHash
    )), 1L, 24L))
    invocation <- mfrmr_gtvr_invoke(
      runtime, staging, profile_path, capability_worker_path,
      qualification_worker_path, request_path, staging$Source,
      staging$RuntimeLibrary, modes[[index]], targets[[index]],
      run_token, library_order
    )
    if (invocation$Status != 0L || !invocation$OutputExists) {
      stop(
        "The Draft.85c4k sandbox worker failed for ", modes[[index]],
        ": ", paste(invocation$Output, collapse = " | "), call. = FALSE
      )
    }
    result <- readRDS(invocation$OutputPath)
    mfrmr_gtvr_assert_worker_result(
      result, modes[[index]], qualification_receipt, request, repair_receipt,
      qualification_worker_environment
    )
    results[[modes[[index]]]] <- result
    denial_class <- if (identical(modes[[index]], "normal")) {
      "normal_full_qualification"
    } else if (identical(modes[[index]], "probe_parent_environment") &&
               identical(result$ActionMessage,
                         "environment_variable_absent")) {
      "parent_environment_absent"
    } else if (grepl(
      paste0(
        "operation not permitted|permission denied|error in running command|",
        "sandbox_exec_status_[1-9]"
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
      ActionMessageHash = mfrmr_gtvr_hash(result$ActionMessage),
      ResultHash = result$ResultHash,
      stringsAsFactors = FALSE
    )
  }
  controls <- do.call(rbind, rows)
  row.names(controls) <- NULL
  expected_classes <- c(
    "normal_full_qualification", rep("sandbox_operation_denied", 3L),
    "parent_environment_absent", "sandbox_operation_denied"
  )
  if (!identical(controls$DenialClass, expected_classes) ||
      file.exists(outside_target)) {
    stop(
      "A Draft.85c4k denial control failed: ",
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
  normal_receipt <- results$normal$QualificationReceipt
  trusted_routes <- mfrmr_gtvr_trusted_route_registry(
    qualification_receipt, normal_receipt,
    mfrmr_gtvr_hash(profile_semantic)
  )
  trusted_pairs <- mfrmr_gtvr_trusted_pair_registry(
    qualification_receipt, normal_receipt,
    mfrmr_gtvr_hash(profile_semantic)
  )
  implementation <- mfrmr_gtvr_implementation_identity()
  payload <- list(
    Contract = "gtheory_multivariate_full_object_capability_draft85c4k_v1",
    C4JQualificationReceiptHash = qualification_receipt$ReceiptHash,
    C4IRepairReceiptHash = repair_receipt$ReceiptHash,
    C4FPolicyHash = qualification_receipt$C4FPolicyHash,
    CandidateRequestHash = candidate_request$RequestHash,
    CapabilityRequest = request,
    CapabilityRequestHash = request$RequestHash,
    WorkerSourceSHA256 = qualification_receipt$WorkerSourceSHA256,
    SourceRegistryHash = qualification_receipt$SourceRegistryHash,
    RuntimeIdentity = runtime,
    RuntimeIdentityHash = runtime$RuntimeIdentityHash,
    StagedRuntimeRegistry = staged_runtime,
    StagedRuntimeRegistryHash = mfrmr_gtvr_hash(staged_runtime),
    ProfileHash = mfrmr_gtvr_hash(profile_text),
    ProfileSemanticHash = mfrmr_gtvr_hash(profile_semantic),
    PolicyAudit = policy_audit,
    PolicyAuditHash = mfrmr_gtvr_hash(policy_audit),
    ControlRegistry = controls,
    ControlRegistryHash = mfrmr_gtvr_hash(controls),
    ControlResults = results,
    ControlResultsHash = mfrmr_gtvr_hash(results),
    NormalQualificationReceiptHash = normal_receipt$ReceiptHash,
    TrustedRouteRegistry = trusted_routes,
    TrustedRouteRegistryHash = mfrmr_gtvr_hash(trusted_routes),
    TrustedPairRegistry = trusted_pairs,
    TrustedPairRegistryHash = mfrmr_gtvr_hash(trusted_pairs),
    SyntheticVaultHash = mfrmr_gtvr_hash(synthetic_vault),
    CapabilityWorkerIdentity = capability_identity,
    CapabilityWorkerIdentityHash = mfrmr_gtvr_hash(capability_identity),
    ImplementationIdentity = implementation,
    ImplementationIdentityHash = mfrmr_gtvr_hash(implementation),
    StagingContentRetained = isTRUE(keep_staging),
    PlannedSeedMaterialIncluded = FALSE,
    ReferenceTruthIncluded = FALSE,
    ConQuestRouteIncluded = FALSE
  )
  evidence <- structure(c(payload, list(
    EvidenceHash = mfrmr_gtvr_hash(payload),
    DefaultDenyProfileReady = TRUE,
    SanitizedEnvironmentReady = TRUE,
    ExactNamespaceReadAllowlistReady = TRUE,
    ExactNativeReadAllowlistReady = TRUE,
    StagedSourceReadReady = TRUE,
    QualificationReceiptWriteReady = TRUE,
    SyntheticVaultReadDenied = TRUE,
    RepositoryReadDenied = TRUE,
    OutsideWriteDenied = TRUE,
    ParentEnvironmentSecretAbsent = TRUE,
    UnlistedExecutableDenied = TRUE,
    ExternalNetworkPolicyClosed = TRUE,
    ProcessCapabilityIsolationReady = TRUE,
    FullObjectQualificationBoundaryReady = TRUE,
    FreshProcessQualificationObserved = TRUE,
    QualificationWorkerImplemented = TRUE,
    FullB1ObjectsReceived = TRUE,
    RouteReceiptsMaterialized = TRUE,
    PairReceiptsMaterialized = TRUE,
    TrustedReceiptProduced = TRUE,
    QualificationEvidenceReady = TRUE,
    BackendQualificationReady = TRUE,
    OperationallyAdmissible = TRUE,
    DiagnosticOverrideAllowed = FALSE,
    PlannedExecutionAuthorized = FALSE,
    ExecutionGateClosed = TRUE,
    BackendExecutionOccurred = TRUE,
    PlannedResponseGenerated = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvr_live_evidence", "list"))
  if (isTRUE(keep_staging)) {
    saveRDS(
      evidence, file.path(staging$Output, "retained-capability-evidence.rds"),
      version = 3L
    )
  } else {
    mfrmr_gtvr_assert_live_evidence(
      evidence, qualification_receipt, repair_receipt,
      repair_worker_environment, c4e_manifest, c4f_manifest,
      qualification_worker_environment, capability_worker_environment,
      repo_root, validation_dir
    )
  }
  evidence
}

mfrmr_gtvr_dispatch_guard <- function(
    evidence, action, callback, ..., authorize = FALSE,
    qualification_receipt, repair_receipt, repair_worker_environment,
    c4e_manifest, c4f_manifest, qualification_worker_environment,
    capability_worker_environment, repo_root = ".",
    validation_dir = file.path("inst", "validation")) {
  mfrmr_gtvr_assert_live_evidence(
    evidence, qualification_receipt, repair_receipt,
    repair_worker_environment, c4e_manifest, c4f_manifest,
    qualification_worker_environment, capability_worker_environment,
    repo_root, validation_dir
  )
  if (!is.character(action) || length(action) != 1L || is.na(action) ||
      !action %in% c(
        "planned_response", "recovery_analysis", "public_promotion"
      )) {
    stop("The Draft.85c4k action is outside capability qualification.",
         call. = FALSE)
  }
  if (!is.function(callback)) stop("`callback` must be a function.",
                                   call. = FALSE)
  if (!is.logical(authorize) || length(authorize) != 1L || is.na(authorize)) {
    stop("`authorize` must be TRUE or FALSE.", call. = FALSE)
  }
  stop(
    "Draft.85c4k qualifies only the backend worker; planned execution ",
    "remains closed.", call. = FALSE
  )
}
