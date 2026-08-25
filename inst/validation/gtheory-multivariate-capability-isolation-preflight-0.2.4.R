# Draft.85c4b macOS capability-isolation preflight.
#
# Repository-internal only. The portable portion seals a default-deny policy
# and exact evidence schema. Live execution uses one c2 nonreserved fixture and
# requires explicit opt-in outside a containing sandbox that forbids nested
# sandbox_init. No planned response or estimator is executed.

mfrmr_gtvh_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtvd_plan", "mfrmr_gtvd_assert_plan",
    "mfrmr_gtve_manifest", "mfrmr_gtve_assert_manifest",
    "mfrmr_gtve_generate_fixture", "mfrmr_gtvg_candidate_envelope",
    "mfrmr_gtvg_assert_candidate_envelope", "mfrmr_gtvg_assert_worker_receipt"
  )
  target <- environment(mfrmr_gtvh_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.81 and the Draft.85a0-c4a chain before Draft.85c4b: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtvh_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    setequal(names(attributes(object)), c("names", "class"))
}

mfrmr_gtvh_function_hash <- function(fun) {
  if (!is.function(fun)) {
    stop("A Draft.85c4b controller function is missing.", call. = FALSE)
  }
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtvh_implementation_identity <- function() {
  function_names <- c(
    "mfrmr_gtvh_require_primitives", "mfrmr_gtvh_exact_object",
    "mfrmr_gtvh_function_hash", "mfrmr_gtvh_implementation_identity",
    "mfrmr_gtvh_file_hash", "mfrmr_gtvh_quote_profile",
    "mfrmr_gtvh_runtime_identity", "mfrmr_gtvh_policy_text",
    "mfrmr_gtvh_policy_audit", "mfrmr_gtvh_worker_result_payload_fields",
    "mfrmr_gtvh_assert_worker_result", "mfrmr_gtvh_staging",
    "mfrmr_gtvh_invoke", "mfrmr_gtvh_live_payload_fields",
    "mfrmr_gtvh_assert_live_evidence", "mfrmr_gtvh_live_preflight"
  )
  target <- environment(mfrmr_gtvh_implementation_identity)
  data.frame(
    Function = function_names,
    SHA256 = vapply(function_names, function(name) {
      if (!exists(name, envir = target, inherits = TRUE)) {
        stop("A Draft.85c4b implementation function is missing: ", name, ".",
             call. = FALSE)
      }
      mfrmr_gtvh_function_hash(get(name, envir = target, inherits = TRUE))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvh_file_hash <- function(path) {
  path <- normalizePath(path, mustWork = TRUE)
  size <- file.info(path)$size
  connection <- file(path, open = "rb")
  on.exit(close(connection), add = TRUE)
  mfrmr_gta_hash(readBin(connection, what = "raw", n = size))
}

mfrmr_gtvh_quote_profile <- function(path) {
  encodeString(normalizePath(path, mustWork = FALSE), quote = "\"")
}

mfrmr_gtvh_runtime_identity <- function(validation_dir = file.path(
    "inst", "validation")) {
  validation_dir <- normalizePath(validation_dir, mustWork = TRUE)
  sandbox_exec <- normalizePath("/usr/bin/sandbox-exec", mustWork = TRUE)
  environment_exec <- normalizePath("/usr/bin/env", mustWork = TRUE)
  r_home <- normalizePath(R.home(), mustWork = TRUE)
  r_exec <- normalizePath(file.path(r_home, "bin", "exec", "R"),
                          mustWork = TRUE)
  system_profile <- normalizePath(
    "/System/Library/Sandbox/Profiles/system.sb", mustWork = TRUE
  )
  candidate_worker <- normalizePath(file.path(
    validation_dir,
    "gtheory-multivariate-candidate-receipt-worker-0.2.4.R"
  ), mustWork = TRUE)
  capability_worker <- normalizePath(file.path(
    validation_dir, "gtheory-multivariate-capability-worker-0.2.4.R"
  ), mustWork = TRUE)
  digest_path <- normalizePath(find.package("digest"), mustWork = TRUE)
  data.frame(
    OS = Sys.info()[["sysname"]],
    OSRelease = Sys.info()[["release"]],
    OSVersion = Sys.info()[["version"]],
    Machine = Sys.info()[["machine"]],
    RVersion = R.version.string,
    SandboxExecutable = sandbox_exec,
    SandboxExecutableHash = mfrmr_gtvh_file_hash(sandbox_exec),
    EnvironmentExecutable = environment_exec,
    EnvironmentExecutableHash = mfrmr_gtvh_file_hash(environment_exec),
    RHome = r_home,
    RExecutable = r_exec,
    RExecutableHash = mfrmr_gtvh_file_hash(r_exec),
    SystemProfile = system_profile,
    SystemProfileHash = mfrmr_gtvh_file_hash(system_profile),
    ValidationDirectory = validation_dir,
    DigestPath = digest_path,
    DigestVersion = as.character(utils::packageVersion("digest")),
    CandidateWorkerPath = candidate_worker,
    CandidateWorkerHash = mfrmr_gtvh_file_hash(candidate_worker),
    CapabilityWorkerPath = capability_worker,
    CapabilityWorkerHash = mfrmr_gtvh_file_hash(capability_worker),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvh_policy_text <- function(runtime, staging) {
  if (!is.data.frame(runtime) || nrow(runtime) != 1L) {
    stop("One Draft.85c4b runtime identity is required.", call. = FALSE)
  }
  required_staging <- c(
    "Root", "Input", "Worker", "Output", "Scratch", "Vault",
    "ForbiddenOutput"
  )
  if (!is.list(staging) || !identical(names(staging), required_staging)) {
    stop("The Draft.85c4b staging identity is invalid.", call. = FALSE)
  }
  q <- mfrmr_gtvh_quote_profile
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

mfrmr_gtvh_policy_audit <- function(profile_text, runtime, staging) {
  forbidden_literals <- c(
    staging$Vault, staging$ForbiddenOutput, runtime$ValidationDirectory[[1L]]
  )
  data.frame(
    Rule = c(
      "version_one", "default_deny", "system_profile_import",
      "no_allow_default", "no_network_allow", "no_vault_path",
      "no_forbidden_output_path", "no_repository_path",
      "candidate_input_allow", "worker_allow", "output_allow",
      "scratch_allow", "sanitized_env_exec_allow", "r_exec_allow"
    ),
    Passed = c(
      grepl("\\(version 1\\)", profile_text),
      grepl("\\(deny default\\)", profile_text),
      grepl("\\(import \\\"system\\.sb\\\"\\)", profile_text),
      !grepl("\\(allow default\\)", profile_text),
      !grepl("allow network", profile_text),
      !grepl(normalizePath(forbidden_literals[[1L]], mustWork = FALSE),
             profile_text, fixed = TRUE),
      !grepl(normalizePath(forbidden_literals[[2L]], mustWork = FALSE),
             profile_text, fixed = TRUE),
      !grepl(normalizePath(forbidden_literals[[3L]], mustWork = TRUE),
             profile_text, fixed = TRUE),
      grepl(normalizePath(staging$Input, mustWork = FALSE), profile_text,
            fixed = TRUE),
      grepl(normalizePath(staging$Worker, mustWork = FALSE), profile_text,
            fixed = TRUE),
      grepl(normalizePath(staging$Output, mustWork = FALSE), profile_text,
            fixed = TRUE),
      grepl(normalizePath(staging$Scratch, mustWork = FALSE), profile_text,
            fixed = TRUE),
      grepl(runtime$EnvironmentExecutable[[1L]], profile_text, fixed = TRUE),
      grepl(runtime$RExecutable[[1L]], profile_text, fixed = TRUE)
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvh_worker_result_payload_fields <- function() {
  c(
    "Contract", "Mode", "RunToken", "OpaqueCandidateId", "EnvelopeHash",
    "CandidateDataHash", "EnvironmentNames", "EnvironmentNamesHash",
    "ParentSecretVisible", "ActionSucceeded", "ActionMessage",
    "CandidateReceipt", "CandidateReceiptHash", "ControlPassed"
  )
}

mfrmr_gtvh_assert_worker_result <- function(result, expected_mode,
                                             envelope) {
  payload_fields <- mfrmr_gtvh_worker_result_payload_fields()
  suffix_fields <- c(
    "ResultHash", "BackendExecutionOccurred", "PlannedResponseGenerated",
    "RecoveryExecuted", "RecoveryEvidenceReady", "EstimationReady",
    "InferenceReady", "DecisionReady", "PublicSupportReady"
  )
  if (!mfrmr_gtvh_exact_object(
    result, c(payload_fields, suffix_fields),
    c("mfrmr_gtvh_worker_result", "list")
  )) {
    stop("A typed Draft.85c4b worker result is required.", call. = FALSE)
  }
  negative <- !identical(expected_mode, "normal")
  valid <-
    identical(result$Contract,
              "gtheory_multivariate_capability_worker_draft85c4b_v1") &&
    identical(result$Mode, expected_mode) &&
    grepl("^C4B-[0-9a-f]{24}$", result$RunToken) &&
    identical(result$OpaqueCandidateId, envelope$OpaqueCandidateId) &&
    identical(result$EnvelopeHash, envelope$EnvelopeHash) &&
    identical(result$CandidateDataHash, envelope$CandidateDataHash) &&
    identical(
      result$EnvironmentNamesHash, mfrmr_gta_hash(result$EnvironmentNames)
    ) &&
    !isTRUE(result$ParentSecretVisible) &&
    identical(isTRUE(result$ActionSucceeded), !negative) &&
    isTRUE(result$ControlPassed) &&
    identical(
      result$ResultHash, mfrmr_gta_hash(result[payload_fields])
    ) &&
    !isTRUE(result$BackendExecutionOccurred) &&
    !isTRUE(result$PlannedResponseGenerated) &&
    !isTRUE(result$RecoveryExecuted) &&
    !isTRUE(result$RecoveryEvidenceReady) &&
    !isTRUE(result$EstimationReady) && !isTRUE(result$InferenceReady) &&
    !isTRUE(result$DecisionReady) && !isTRUE(result$PublicSupportReady)
  if (identical(expected_mode, "normal")) {
    valid <- valid && inherits(
      result$CandidateReceipt, "mfrmr_gtvg_candidate_receipt"
    ) && identical(
      result$CandidateReceiptHash, result$CandidateReceipt$ReceiptHash
    )
  } else {
    valid <- valid && is.null(result$CandidateReceipt) &&
      is.na(result$CandidateReceiptHash)
  }
  if (!valid) {
    stop("The Draft.85c4b worker result or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvh_staging <- function(root) {
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
  for (path in paths[-1L]) dir.create(path, recursive = FALSE)
  lapply(paths, normalizePath, mustWork = TRUE)
}

mfrmr_gtvh_invoke <- function(
    runtime, staging, profile_path, capability_worker_path,
    candidate_worker_path, input_path, mode, target, run_token) {
  output_path <- file.path(staging$Output, paste0(mode, ".rds"))
  arguments <- c(
    "-f", shQuote(profile_path),
    shQuote(runtime$EnvironmentExecutable[[1L]]), "-i",
    paste0("R_HOME=", shQuote(runtime$RHome[[1L]])),
    paste0("TMPDIR=", shQuote(staging$Scratch)),
    "PATH=/usr/bin:/bin", "LANG=C", "LC_ALL=C", "TZ=UTC",
    shQuote(runtime$RExecutable[[1L]]), "--vanilla", "--slave",
    paste0("--file=", shQuote(capability_worker_path)), "--args",
    shQuote(mode), shQuote(candidate_worker_path), shQuote(input_path),
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

mfrmr_gtvh_live_payload_fields <- function() {
  c(
    "Contract", "PlanHash", "GeneratorManifestHash", "FixtureOrdinal",
    "OpaqueCandidateId", "EnvelopeHash", "CandidateDataHash",
    "RuntimeIdentity", "RuntimeIdentityHash", "ProfileHash",
    "ProfileSemanticHash", "PolicyAudit", "PolicyAuditHash",
    "ControlRegistry", "ControlRegistryHash", "NormalCandidateReceiptHash",
    "ReferenceVaultHash", "ImplementationIdentity",
    "ImplementationIdentityHash",
    "StagingContentRetained", "PlannedSeedMaterialIncluded",
    "ReferenceVaultContentIncluded"
  )
}

mfrmr_gtvh_assert_live_evidence <- function(evidence, worker_environment) {
  payload_fields <- mfrmr_gtvh_live_payload_fields()
  suffix_fields <- c(
    "EvidenceHash", "DefaultDenyProfileReady",
    "SanitizedEnvironmentReady", "CandidateInputReadReady",
    "CandidateReceiptWriteReady", "ReferenceVaultReadDenied",
    "SourceTreeReadDenied", "OutsideWriteDenied",
    "ParentEnvironmentSecretAbsent", "UnlistedExecutableDenied",
    "ExternalNetworkPolicyClosed", "ProcessCapabilityIsolationReady",
    "TruthBlindProcessBoundaryReady", "BackendQualificationReady",
    "PilotExecutionAuthorized", "ConfirmationExecutionAuthorized",
    "BackendExecutionOccurred", "PlannedResponseGenerated",
    "RecoveryExecuted", "RecoveryEvidenceReady", "EstimationReady",
    "InferenceReady", "DecisionReady", "PublicSupportReady"
  )
  if (!mfrmr_gtvh_exact_object(
    evidence, c(payload_fields, suffix_fields),
    c("mfrmr_gtvh_live_evidence", "list")
  )) {
    stop("A typed Draft.85c4b live evidence object is required.",
         call. = FALSE)
  }
  controls <- evidence$ControlRegistry
  expected_modes <- c(
    "normal", "probe_vault_read", "probe_source_read",
    "probe_outside_write", "probe_parent_environment",
    "probe_unlisted_exec"
  )
  expected_classes <- c(
    "normal_candidate_receipt", rep("sandbox_operation_denied", 3L),
    "parent_environment_absent", "sandbox_operation_denied"
  )
  exact_controls <- is.data.frame(controls) && nrow(controls) == 6L &&
    identical(controls$ControlOrdinal, 1:6) &&
    identical(controls$Mode, expected_modes) &&
    identical(controls$SandboxExitStatus, rep(0L, 6L)) &&
    all(controls$OutputReceiptExists) &&
    identical(controls$ActionSucceeded,
              c(TRUE, rep(FALSE, 5L))) &&
    !any(controls$ParentSecretVisible) && all(controls$ControlPassed) &&
    identical(controls$DenialClass, expected_classes) &&
    all(nchar(controls$ActionMessageHash) == 64L) &&
    all(nchar(controls$ResultHash) == 64L)
  ready_flags <- c(
    "DefaultDenyProfileReady", "SanitizedEnvironmentReady",
    "CandidateInputReadReady", "CandidateReceiptWriteReady",
    "ReferenceVaultReadDenied", "SourceTreeReadDenied",
    "OutsideWriteDenied", "ParentEnvironmentSecretAbsent",
    "UnlistedExecutableDenied", "ExternalNetworkPolicyClosed",
    "ProcessCapabilityIsolationReady", "TruthBlindProcessBoundaryReady"
  )
  closed_flags <- c(
    "BackendQualificationReady", "PilotExecutionAuthorized",
    "ConfirmationExecutionAuthorized", "BackendExecutionOccurred",
    "PlannedResponseGenerated", "RecoveryExecuted", "RecoveryEvidenceReady",
    "EstimationReady", "InferenceReady", "DecisionReady",
    "PublicSupportReady"
  )
  canonical_plan <- mfrmr_gtvd_plan()
  canonical_generator <- mfrmr_gtve_manifest(canonical_plan)
  canonical_generation <- mfrmr_gtve_generate_fixture(
    canonical_generator$FixtureRegistry$FixtureId[[1L]], canonical_plan,
    canonical_generator$FixtureRegistry
  )
  canonical_envelope <- mfrmr_gtvg_candidate_envelope(
    canonical_generation, canonical_plan, canonical_generator$FixtureRegistry,
    upstream_validated = TRUE
  )
  canonical_receipt <- mfrmr_gtvg_worker_receipt(
    canonical_envelope, worker_environment
  )
  canonical_vault <- list(
    FixtureId = canonical_generation$Identity$FixtureId,
    ScenarioId = canonical_generation$Identity$ScenarioId,
    ReferenceId = canonical_generation$Identity$ReferenceId,
    FixtureSeed = canonical_generation$Identity$FixtureSeed,
    TruthAudit = canonical_generation$TruthAudit
  )
  valid <-
    identical(evidence$Contract,
              "gtheory_multivariate_capability_isolation_draft85c4b_v1") &&
    identical(evidence$FixtureOrdinal, 1L) &&
    identical(evidence$PlanHash, canonical_plan$PlanHash) &&
    identical(evidence$GeneratorManifestHash,
              canonical_generator$ManifestHash) &&
    identical(evidence$OpaqueCandidateId,
              canonical_envelope$OpaqueCandidateId) &&
    identical(evidence$EnvelopeHash, canonical_envelope$EnvelopeHash) &&
    identical(evidence$CandidateDataHash,
              canonical_envelope$CandidateDataHash) &&
    identical(evidence$NormalCandidateReceiptHash,
              canonical_receipt$ReceiptHash) &&
    identical(evidence$RuntimeIdentity$OS, "Darwin") &&
    identical(evidence$RuntimeIdentityHash,
              mfrmr_gta_hash(evidence$RuntimeIdentity)) &&
    identical(evidence$PolicyAuditHash,
              mfrmr_gta_hash(evidence$PolicyAudit)) &&
    all(evidence$PolicyAudit$Passed) && exact_controls &&
    identical(evidence$ControlRegistryHash, mfrmr_gta_hash(controls)) &&
    is.character(evidence$ReferenceVaultHash) &&
    length(evidence$ReferenceVaultHash) == 1L &&
    !is.na(evidence$ReferenceVaultHash) &&
    nchar(evidence$ReferenceVaultHash) == 64L &&
    identical(evidence$ReferenceVaultHash,
              mfrmr_gta_hash(canonical_vault)) &&
    identical(evidence$ImplementationIdentity,
              mfrmr_gtvh_implementation_identity()) &&
    identical(evidence$ImplementationIdentityHash,
              mfrmr_gta_hash(evidence$ImplementationIdentity)) &&
    identical(evidence$EvidenceHash,
              mfrmr_gta_hash(evidence[payload_fields])) &&
    !isTRUE(evidence$StagingContentRetained) &&
    !isTRUE(evidence$PlannedSeedMaterialIncluded) &&
    !isTRUE(evidence$ReferenceVaultContentIncluded) &&
    all(vapply(ready_flags, function(name) isTRUE(evidence[[name]]),
               logical(1L))) &&
    !any(vapply(closed_flags, function(name) isTRUE(evidence[[name]]),
                logical(1L)))
  if (!valid) {
    stop("The Draft.85c4b live evidence, controls, or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvh_live_preflight <- function(
    worker_environment, validation_dir = file.path("inst", "validation"),
    authorize_live_sandbox = FALSE, keep_staging = FALSE,
    plan = mfrmr_gtvd_plan(), generator_manifest = mfrmr_gtve_manifest(plan)) {
  if (!identical(Sys.info()[["sysname"]], "Darwin")) {
    stop("Draft.85c4b live isolation requires macOS.", call. = FALSE)
  }
  if (!isTRUE(authorize_live_sandbox)) {
    stop("Live capability isolation requires `authorize_live_sandbox=TRUE`.",
         call. = FALSE)
  }
  if (!is.logical(keep_staging) || length(keep_staging) != 1L ||
      is.na(keep_staging)) {
    stop("`keep_staging` must be TRUE or FALSE.", call. = FALSE)
  }
  mfrmr_gtvd_assert_plan(plan)
  mfrmr_gtve_assert_manifest(
    generator_manifest, plan, generator_manifest$FixtureRegistry
  )
  runtime <- mfrmr_gtvh_runtime_identity(validation_dir)
  root <- file.path("/private/tmp", paste0("mfrmr-c4b-", substr(
    mfrmr_gta_hash(list(
      Namespace = "gtheory_multivariate_capability_staging_draft85c4b_v1",
      PlanHash = plan$PlanHash,
      GeneratorManifestHash = generator_manifest$ManifestHash,
      RuntimeIdentityHash = mfrmr_gta_hash(runtime)
    )), 1L, 16L
  )))
  if (file.exists(root) || dir.exists(root)) {
    stop("The deterministic Draft.85c4b staging path is occupied.",
         call. = FALSE)
  }
  dir.create(root)
  if (!isTRUE(keep_staging)) on.exit(unlink(root, recursive = TRUE), add = TRUE)
  staging <- mfrmr_gtvh_staging(root)
  generation <- mfrmr_gtve_generate_fixture(
    generator_manifest$FixtureRegistry$FixtureId[[1L]], plan,
    generator_manifest$FixtureRegistry
  )
  envelope <- mfrmr_gtvg_candidate_envelope(
    generation, plan, generator_manifest$FixtureRegistry,
    upstream_validated = TRUE
  )
  mfrmr_gtvg_assert_candidate_envelope(envelope)
  input_path <- file.path(staging$Input, "candidate-envelope.rds")
  saveRDS(envelope, input_path, version = 3L)
  vault_path <- file.path(staging$Vault, "reference-vault.rds")
  reference_vault <- list(
    FixtureId = generation$Identity$FixtureId,
    ScenarioId = generation$Identity$ScenarioId,
    ReferenceId = generation$Identity$ReferenceId,
    FixtureSeed = generation$Identity$FixtureSeed,
    TruthAudit = generation$TruthAudit
  )
  saveRDS(reference_vault, vault_path, version = 3L)
  candidate_worker_path <- file.path(staging$Worker, "candidate-worker.R")
  capability_worker_path <- file.path(staging$Worker, "capability-worker.R")
  file.copy(runtime$CandidateWorkerPath[[1L]], candidate_worker_path)
  file.copy(runtime$CapabilityWorkerPath[[1L]], capability_worker_path)
  source_target <- normalizePath(file.path(
    validation_dir, "gtheory-multivariate-ademp-plan-prototype-0.2.4.R"
  ), mustWork = TRUE)
  outside_target <- file.path(staging$ForbiddenOutput, "leak.rds")
  profile_text <- mfrmr_gtvh_policy_text(runtime, staging)
  policy_audit <- mfrmr_gtvh_policy_audit(profile_text, runtime, staging)
  if (!all(policy_audit$Passed)) {
    stop("The Draft.85c4b default-deny policy audit failed.", call. = FALSE)
  }
  profile_path <- file.path(root, "candidate-profile.sb")
  writeLines(profile_text, profile_path, useBytes = TRUE)
  modes <- c(
    "normal", "probe_vault_read", "probe_source_read",
    "probe_outside_write", "probe_parent_environment",
    "probe_unlisted_exec"
  )
  targets <- c(
    "", vault_path, source_target, outside_target,
    "MFRMR_C4B_PARENT_SECRET", "/bin/cat"
  )
  old_secret <- Sys.getenv("MFRMR_C4B_PARENT_SECRET", unset = NA_character_)
  on.exit({
    if (is.na(old_secret)) Sys.unsetenv("MFRMR_C4B_PARENT_SECRET") else
      Sys.setenv(MFRMR_C4B_PARENT_SECRET = old_secret)
  }, add = TRUE)
  Sys.setenv(MFRMR_C4B_PARENT_SECRET = "synthetic-parent-only-secret")
  result_rows <- list()
  normal_receipt <- NULL
  for (index in seq_along(modes)) {
    run_token <- paste0("C4B-", substr(mfrmr_gta_hash(list(
      Namespace = "gtheory_multivariate_capability_run_draft85c4b_v1",
      EnvelopeHash = envelope$EnvelopeHash, Mode = modes[[index]],
      RuntimeHash = mfrmr_gta_hash(runtime)
    )), 1L, 24L))
    invocation <- mfrmr_gtvh_invoke(
      runtime, staging, profile_path, capability_worker_path,
      candidate_worker_path, input_path, modes[[index]], targets[[index]],
      run_token
    )
    if (invocation$Status != 0L || !invocation$OutputExists) {
      stop(
        "The Draft.85c4b sandbox worker failed for ", modes[[index]],
        ": ", paste(invocation$Output, collapse = " | "), call. = FALSE
      )
    }
    result <- readRDS(invocation$OutputPath)
    mfrmr_gtvh_assert_worker_result(result, modes[[index]], envelope)
    if (identical(modes[[index]], "normal")) {
      normal_receipt <- result$CandidateReceipt
      mfrmr_gtvg_assert_worker_receipt(
        normal_receipt, envelope, worker_environment
      )
    }
    denial_class <- if (identical(modes[[index]], "normal")) {
      "normal_candidate_receipt"
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
    result_rows[[index]] <- data.frame(
      ControlOrdinal = as.integer(index), Mode = modes[[index]],
      SandboxExitStatus = invocation$Status,
      OutputReceiptExists = invocation$OutputExists,
      ActionSucceeded = result$ActionSucceeded,
      ParentSecretVisible = result$ParentSecretVisible,
      ControlPassed = result$ControlPassed,
      DenialClass = denial_class,
      ActionMessageHash = mfrmr_gta_hash(result$ActionMessage),
      ResultHash = result$ResultHash,
      stringsAsFactors = FALSE
    )
  }
  controls <- do.call(rbind, result_rows)
  row.names(controls) <- NULL
  expected_classes <- c(
    "normal_candidate_receipt", rep("sandbox_operation_denied", 3L),
    "parent_environment_absent", "sandbox_operation_denied"
  )
  if (!identical(controls$DenialClass, expected_classes) ||
      file.exists(outside_target)) {
    stop(
      "A Draft.85c4b denial control did not fail for the expected reason: ",
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
  implementation <- mfrmr_gtvh_implementation_identity()
  payload <- list(
    Contract = "gtheory_multivariate_capability_isolation_draft85c4b_v1",
    PlanHash = plan$PlanHash,
    GeneratorManifestHash = generator_manifest$ManifestHash,
    FixtureOrdinal = 1L,
    OpaqueCandidateId = envelope$OpaqueCandidateId,
    EnvelopeHash = envelope$EnvelopeHash,
    CandidateDataHash = envelope$CandidateDataHash,
    RuntimeIdentity = runtime,
    RuntimeIdentityHash = mfrmr_gta_hash(runtime),
    ProfileHash = mfrmr_gta_hash(profile_text),
    ProfileSemanticHash = mfrmr_gta_hash(profile_semantic),
    PolicyAudit = policy_audit,
    PolicyAuditHash = mfrmr_gta_hash(policy_audit),
    ControlRegistry = controls,
    ControlRegistryHash = mfrmr_gta_hash(controls),
    NormalCandidateReceiptHash = normal_receipt$ReceiptHash,
    ReferenceVaultHash = mfrmr_gta_hash(reference_vault),
    ImplementationIdentity = implementation,
    ImplementationIdentityHash = mfrmr_gta_hash(implementation),
    StagingContentRetained = isTRUE(keep_staging),
    PlannedSeedMaterialIncluded = FALSE,
    ReferenceVaultContentIncluded = FALSE
  )
  evidence <- structure(c(payload, list(
    EvidenceHash = mfrmr_gta_hash(payload),
    DefaultDenyProfileReady = TRUE,
    SanitizedEnvironmentReady = TRUE,
    CandidateInputReadReady = TRUE,
    CandidateReceiptWriteReady = TRUE,
    ReferenceVaultReadDenied = TRUE,
    SourceTreeReadDenied = TRUE,
    OutsideWriteDenied = TRUE,
    ParentEnvironmentSecretAbsent = TRUE,
    UnlistedExecutableDenied = TRUE,
    ExternalNetworkPolicyClosed = TRUE,
    ProcessCapabilityIsolationReady = TRUE,
    TruthBlindProcessBoundaryReady = TRUE,
    BackendQualificationReady = FALSE,
    PilotExecutionAuthorized = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    BackendExecutionOccurred = FALSE,
    PlannedResponseGenerated = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvh_live_evidence", "list"))
  if (!isTRUE(keep_staging)) {
    mfrmr_gtvh_assert_live_evidence(evidence, worker_environment)
  }
  evidence
}
