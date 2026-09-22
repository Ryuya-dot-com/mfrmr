gtheory_multivariate_qualification_capability_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-execution-admission-preflight-0.2.4.R",
      paste0(
        "gtheory-multivariate-backend-qualification-admission-",
        "preflight-0.2.4.R"
      ),
      "gtheory-multivariate-four-route-qualification-protocol-0.2.4.R",
      "gtheory-multivariate-qualification-worker-preflight-0.2.4.R",
      paste0(
        "gtheory-multivariate-qualification-capability-isolation-",
        "preflight-0.2.4.R"
      )
    )
  )
}

gtheory_multivariate_qualification_capability_worker_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-multivariate-qualification-worker-0.2.4.R",
      "gtheory-multivariate-qualification-capability-worker-0.2.4.R"
    )
  )
}

load_gtheory_multivariate_qualification_capability <- local({
  environments <- NULL
  function() {
    paths <- gtheory_multivariate_qualification_capability_paths()
    worker_paths <- gtheory_multivariate_qualification_capability_worker_paths()
    skip_if_not(all(file.exists(c(paths, worker_paths))),
                "repository-internal validation artifacts are excluded")
    skip_if_not_installed("digest")
    if (is.null(environments)) {
      controller <- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = controller)
      refusal_worker <- new.env(parent = baseenv())
      sys.source(worker_paths[[1L]], envir = refusal_worker)
      capability_worker <- new.env(parent = baseenv())
      sys.source(worker_paths[[2L]], envir = capability_worker)
      environments <<- list(
        controller = controller,
        refusal_worker = refusal_worker,
        capability_worker = capability_worker
      )
    }
    environments
  }
})

gtvo_repo_root <- function() {
  testthat::test_path("..", "..")
}

gtvo_validation_dir <- function() {
  dirname(gtheory_multivariate_qualification_capability_worker_paths()[[1L]])
}

skip_if_not_c4h_macos <- function() {
  skip_if_not(identical(Sys.info()[["sysname"]], "Darwin"),
              "Draft.85c4h capability isolation is macOS-specific")
}

skip_if_not_c4h_live <- function() {
  skip_if_not_c4h_macos()
  skip_if_not(
    identical(Sys.getenv("MFRMR_RUN_C4H_MACOS_SANDBOX"), "true"),
    "set MFRMR_RUN_C4H_MACOS_SANDBOX=true for live sandbox evidence"
  )
}

gtvo_objects <- local({
  objects <- NULL
  function(environments) {
    if (is.null(objects)) {
      env <- environments$controller
      environment <- env$mfrmr_gtvl_environment_identity()
      c4e <- env$mfrmr_gtvl_manifest(gtvo_repo_root(), environment)
      protocol <- env$mfrmr_gtvm_manifest(gtvo_repo_root(), c4e)
      process <- env$mfrmr_gtvn_process_preflight(
        environments$refusal_worker, protocol, gtvo_repo_root()
      )
      c4g <- env$mfrmr_gtvn_manifest(
        environments$refusal_worker, protocol, gtvo_repo_root(), process
      )
      objects <<- list(
        environment = environment, c4e = c4e, protocol = protocol,
        process = process, c4g = c4g
      )
    }
    objects
  }
})

gtvo_runtime <- local({
  runtime <- NULL
  function(env) {
    if (is.null(runtime)) {
      runtime <<- env$mfrmr_gtvo_runtime_identity(gtvo_validation_dir())
    }
    runtime
  }
})

gtvo_live_evidence <- local({
  evidence <- NULL
  function(environments) {
    skip_if_not_c4h_live()
    if (is.null(evidence)) {
      env <- environments$controller
      objects <- gtvo_objects(environments)
      evidence <<- env$mfrmr_gtvo_live_preflight(
        environments$refusal_worker,
        environments$capability_worker,
        objects$c4g,
        objects$protocol,
        repo_root = gtvo_repo_root(),
        validation_dir = gtvo_validation_dir(),
        authorize_live_sandbox = TRUE,
        keep_staging = FALSE
      )
    }
    evidence
  }
})

test_that("Draft.85c4h capability wrapper is an exact four-function file", {
  environments <- load_gtheory_multivariate_qualification_capability()
  worker <- environments$capability_worker
  expected <- c(
    "mfrmr_gtvow_hash", "mfrmr_gtvow_attempt", "mfrmr_gtvow_probe",
    "mfrmr_gtvow_main"
  )
  expect_identical(parent.env(worker), baseenv())
  expect_identical(
    sort(ls(worker, all.names = TRUE), method = "radix"),
    sort(expected, method = "radix")
  )
  expect_true(all(vapply(expected, function(name) {
    is.function(get(name, envir = worker, inherits = FALSE))
  }, logical(1L))))
  function_text <- vapply(expected, function(name) {
    paste(deparse(body(get(name, envir = worker))), collapse = "\n")
  }, character(1L))
  expect_false(any(grepl(
    "lme4::|glmmTMB::|install.packages|remotes::|pak::|ConQuest",
    function_text
  )))
})

test_that("Draft.85c4h binds c4g and retains a hash-only request", {
  environments <- load_gtheory_multivariate_qualification_capability()
  env <- environments$controller
  objects <- gtvo_objects(environments)
  expect_identical(
    objects$c4g$ManifestHash,
    "c62906de666c4de1f6a00f07009e84fc859165486a859cbb2db406e679be7a97"
  )
  expect_silent(env$mfrmr_gtvn_assert_request(
    objects$c4g$Request, environments$refusal_worker,
    objects$protocol, gtvo_repo_root()
  ))
  expect_false(objects$c4g$Request$EnvironmentReadyForBackendQualification)
  expect_false(objects$c4g$Request$BackendExecutionAuthorized)
  expect_false(objects$c4g$Request$PlannedSeedMaterialIncluded)
  expect_false(any(c(
    "Specification", "BackendData", "Score", "DataSeed", "FixtureSeed",
    "CandidateData", "TruthAudit", "Reference"
  ) %in% names(objects$c4g$Request)))
})

test_that("Draft.85c4h binds the exact local sandbox and worker runtime", {
  skip_if_not_c4h_macos()
  environments <- load_gtheory_multivariate_qualification_capability()
  env <- environments$controller
  runtime <- gtvo_runtime(env)
  expect_identical(nrow(runtime), 1L)
  expect_identical(runtime$OS, "Darwin")
  expect_true(file.exists(runtime$SandboxExecutable))
  expect_true(file.exists(runtime$EnvironmentExecutable))
  expect_true(file.exists(runtime$RExecutable))
  expect_true(file.exists(runtime$SystemProfile))
  expect_true(dir.exists(runtime$DigestPath))
  expect_true(file.exists(runtime$RefusalWorkerPath))
  expect_true(file.exists(runtime$CapabilityWorkerPath))
  expect_identical(
    runtime$RefusalWorkerHash,
    "a13ef63611a1e96048de3fd5a4b59bf4dddc53d225c6cd3f5808c65876a21daa"
  )
  expect_identical(
    runtime$CapabilityWorkerHash,
    "4387bc63f86cd5c77454e3767077ec11b31603b55733cadcb2805d0bee2ec7c0"
  )
  hash_columns <- grep("Hash$", names(runtime), value = TRUE)
  expect_true(all(vapply(runtime[hash_columns], function(value) {
    is.character(value) && length(value) == 1L && nchar(value) == 64L
  }, logical(1L))))
})

test_that("Draft.85c4h policy is default-deny and excludes protected paths", {
  skip_if_not_c4h_macos()
  environments <- load_gtheory_multivariate_qualification_capability()
  env <- environments$controller
  runtime <- gtvo_runtime(env)
  root <- tempfile("mfrmr-c4h-policy-", tmpdir = "/private/tmp")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  staging <- env$mfrmr_gtvo_staging(root)
  profile <- env$mfrmr_gtvo_policy_text(runtime, staging)
  audit <- env$mfrmr_gtvo_policy_audit(profile, runtime, staging)
  expect_identical(nrow(audit), 14L)
  expect_true(all(audit$Passed))
  expect_match(profile, "\\(deny default\\)")
  expect_false(grepl("\\(allow default\\)", profile))
  expect_false(grepl("allow network", profile))
  expect_false(grepl(staging$Vault, profile, fixed = TRUE))
  expect_false(grepl(staging$ForbiddenOutput, profile, fixed = TRUE))
  expect_false(grepl(runtime$ValidationDirectory, profile, fixed = TRUE))
  expect_true(grepl(staging$Input, profile, fixed = TRUE))
  expect_true(grepl(staging$Worker, profile, fixed = TRUE))
  expect_true(grepl(staging$Output, profile, fixed = TRUE))
  expect_true(grepl(staging$Scratch, profile, fixed = TRUE))
})

test_that("Draft.85c4h policy audit detects relaxation and path leakage", {
  skip_if_not_c4h_macos()
  environments <- load_gtheory_multivariate_qualification_capability()
  env <- environments$controller
  runtime <- gtvo_runtime(env)
  root <- tempfile("mfrmr-c4h-policy-negative-", tmpdir = "/private/tmp")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  staging <- env$mfrmr_gtvo_staging(root)
  profile <- env$mfrmr_gtvo_policy_text(runtime, staging)

  relaxed <- sub("\\(deny default\\)", "(allow default)", profile)
  audit <- env$mfrmr_gtvo_policy_audit(relaxed, runtime, staging)
  expect_false(audit$Passed[audit$Rule == "default_deny"])
  expect_false(audit$Passed[audit$Rule == "no_allow_default"])

  networked <- paste(profile, "(allow network*)", sep = "\n")
  audit <- env$mfrmr_gtvo_policy_audit(networked, runtime, staging)
  expect_false(audit$Passed[audit$Rule == "no_network_allow"])

  leaked <- paste(profile, staging$Vault, sep = "\n")
  audit <- env$mfrmr_gtvo_policy_audit(leaked, runtime, staging)
  expect_false(audit$Passed[audit$Rule == "no_vault_path"])

  source_leaked <- paste(profile, runtime$ValidationDirectory, sep = "\n")
  audit <- env$mfrmr_gtvo_policy_audit(source_leaked, runtime, staging)
  expect_false(audit$Passed[audit$Rule == "no_repository_path"])
})

test_that("Draft.85c4h live runner requires explicit authorization", {
  skip_if_not_c4h_macos()
  environments <- load_gtheory_multivariate_qualification_capability()
  objects <- gtvo_objects(environments)
  expect_error(
    environments$controller$mfrmr_gtvo_live_preflight(
      environments$refusal_worker,
      environments$capability_worker,
      objects$c4g,
      objects$protocol,
      repo_root = gtvo_repo_root(),
      authorize_live_sandbox = FALSE
    ),
    "authorize_live_sandbox=TRUE"
  )
})

test_that("Draft.85c4h live sandbox passes all six controls", {
  environments <- load_gtheory_multivariate_qualification_capability()
  env <- environments$controller
  objects <- gtvo_objects(environments)
  evidence <- gtvo_live_evidence(environments)
  expect_silent(env$mfrmr_gtvo_assert_live_evidence(
    evidence, environments$refusal_worker, environments$capability_worker,
    objects$c4g, objects$protocol, gtvo_repo_root()
  ))
  expect_s3_class(evidence, "mfrmr_gtvo_live_evidence")
  expect_identical(evidence$ControlRegistry$Mode, c(
    "normal", "probe_vault_read", "probe_source_read",
    "probe_outside_write", "probe_parent_environment",
    "probe_unlisted_exec"
  ))
  expect_identical(evidence$ControlRegistry$DenialClass, c(
    "normal_refusal_receipt", rep("sandbox_operation_denied", 3L),
    "parent_environment_absent", "sandbox_operation_denied"
  ))
  expect_identical(
    evidence$ControlRegistry$ActionSucceeded,
    c(TRUE, rep(FALSE, 5L))
  )
  expect_true(all(evidence$ControlRegistry$ControlPassed))
  expect_false(any(evidence$ControlRegistry$ParentSecretVisible))
  expect_identical(evidence$ControlRegistry$SandboxExitStatus, rep(0L, 6L))
})

test_that("Draft.85c4h promotes only hash-only refusal isolation", {
  environments <- load_gtheory_multivariate_qualification_capability()
  env <- environments$controller
  objects <- gtvo_objects(environments)
  evidence <- gtvo_live_evidence(environments)
  ready <- c(
    "DefaultDenyProfileReady", "SanitizedEnvironmentReady",
    "HashOnlyInputReadReady", "RefusalReceiptWriteReady",
    "SyntheticVaultReadDenied", "SourceTreeReadDenied",
    "OutsideWriteDenied", "ParentEnvironmentSecretAbsent",
    "UnlistedExecutableDenied", "ExternalNetworkPolicyClosed",
    "ProcessCapabilityIsolationReady", "HashOnlyRefusalBoundaryReady",
    "FreshProcessRefusalObserved", "RefusalOnlyWorkerReady",
    "RepairRequired", "ExecutionGateClosed"
  )
  closed <- c(
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
  expect_true(all(vapply(ready, function(name) evidence[[name]], logical(1L))))
  expect_false(any(vapply(closed, function(name) evidence[[name]],
                          logical(1L))))
  expect_false(evidence$StagingContentRetained)
  expect_false(evidence$PlannedSeedMaterialIncluded)
  expect_false(evidence$FullB1ObjectsIncluded)
  expect_false(evidence$ReferenceTruthIncluded)
  expect_false(evidence$ConQuestRouteIncluded)

  state <- new.env(parent = emptyenv())
  state$calls <- 0L
  callback <- function(...) {
    state$calls <- state$calls + 1L
    "unreachable"
  }
  for (action in c("qualification_worker", "backend_fit", "receipt_trust")) {
    for (authorize in c(FALSE, TRUE)) {
      expect_error(env$mfrmr_gtvo_dispatch_guard(
        evidence, action, callback, authorize = authorize,
        refusal_worker_environment = environments$refusal_worker,
        capability_worker_environment = environments$capability_worker,
        c4g_manifest = objects$c4g,
        protocol_manifest = objects$protocol,
        repo_root = gtvo_repo_root()
      ), "qualification remains closed")
    }
  }
  expect_identical(state$calls, 0L)
})

test_that("Draft.85c4h evidence fails closed after mutation", {
  environments <- load_gtheory_multivariate_qualification_capability()
  env <- environments$controller
  objects <- gtvo_objects(environments)
  evidence <- gtvo_live_evidence(environments)

  changed <- evidence
  changed$BackendQualificationReady <- TRUE
  expect_error(env$mfrmr_gtvo_assert_live_evidence(
    changed, environments$refusal_worker, environments$capability_worker,
    objects$c4g, objects$protocol, gtvo_repo_root()
  ), "live evidence, controls, or readiness")

  changed <- evidence
  changed$ControlRegistry$ActionSucceeded[[2L]] <- TRUE
  changed$ControlRegistryHash <- env$mfrmr_gtvo_hash(changed$ControlRegistry)
  changed$EvidenceHash <- env$mfrmr_gtvo_hash(
    changed[env$mfrmr_gtvo_live_payload_fields()]
  )
  expect_error(env$mfrmr_gtvo_assert_live_evidence(
    changed, environments$refusal_worker, environments$capability_worker,
    objects$c4g, objects$protocol, gtvo_repo_root()
  ), "live evidence, controls, or readiness")

  changed <- evidence
  changed$PolicyAudit$Passed[[1L]] <- FALSE
  changed$PolicyAuditHash <- env$mfrmr_gtvo_hash(changed$PolicyAudit)
  changed$EvidenceHash <- env$mfrmr_gtvo_hash(
    changed[env$mfrmr_gtvo_live_payload_fields()]
  )
  expect_error(env$mfrmr_gtvo_assert_live_evidence(
    changed, environments$refusal_worker, environments$capability_worker,
    objects$c4g, objects$protocol, gtvo_repo_root()
  ), "live evidence, controls, or readiness")
})

test_that("Draft.85c4h remains internal and contains no execution material", {
  environments <- load_gtheory_multivariate_qualification_capability()
  evidence <- gtvo_live_evidence(environments)
  recursive_names <- function(value) {
    own <- names(value)
    children <- if (is.list(value)) {
      unlist(lapply(value, recursive_names), use.names = FALSE)
    } else character()
    c(own, children)
  }
  all_names <- recursive_names(unclass(evidence))
  expect_false(any(c(
    "DataSeed", "FixtureSeed", "CandidateData", "TruthAudit", "ScenarioId",
    "ReferenceId", "Specification", "BackendData", "Estimate", "LogLik"
  ) %in% all_names))
  numeric_values <- suppressWarnings(as.numeric(unlist(
    evidence, recursive = TRUE, use.names = FALSE
  )))
  numeric_values <- numeric_values[is.finite(numeric_values)]
  expect_false(any(numeric_values >= 851000000 & numeric_values <= 854999999))

  public_paths <- testthat::test_path(
    "..", "..", c("R", "man", "vignettes", "NEWS.md", "ROADMAP.md")
  )
  public_files <- unlist(lapply(public_paths, function(path) {
    if (dir.exists(path)) list.files(path, recursive = TRUE, full.names = TRUE)
    else path[file.exists(path)]
  }), use.names = FALSE)
  public_files <- public_files[!dir.exists(public_files)]
  public_files <- public_files[grepl(
    "\\.(R|Rd|Rmd|md)$|(^|/)(NEWS|ROADMAP)\\.md$", public_files
  )]
  public_text <- unlist(lapply(public_files, function(path) {
    readLines(path, warn = FALSE, encoding = "UTF-8")
  }), use.names = FALSE)
  expect_false(any(grepl("Draft\\.85c4h|mfrmr_gtvo[w]?_", public_text)))
})
