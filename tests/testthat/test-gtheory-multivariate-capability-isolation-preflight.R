gtheory_multivariate_capability_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-incidence-preflight-0.2.4.R",
      "gtheory-multivariate-matched-backend-prototype-0.2.4.R",
      "gtheory-multivariate-k-oracle-prototype-0.2.4.R",
      "gtheory-multivariate-ademp-plan-prototype-0.2.4.R",
      "gtheory-multivariate-generator-preflight-0.2.4.R",
      "gtheory-multivariate-candidate-receipt-preflight-0.2.4.R",
      "gtheory-multivariate-capability-isolation-preflight-0.2.4.R"
    )
  )
}

gtheory_multivariate_capability_worker_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-multivariate-candidate-receipt-worker-0.2.4.R",
      "gtheory-multivariate-capability-worker-0.2.4.R"
    )
  )
}

load_gtheory_multivariate_capability <- local({
  environments <- NULL
  function() {
    paths <- gtheory_multivariate_capability_paths()
    worker_paths <- gtheory_multivariate_capability_worker_paths()
    skip_if_not(all(file.exists(c(paths, worker_paths))),
                "repository-internal validation artifacts are excluded")
    skip_if_not_installed("digest")
    if (is.null(environments)) {
      controller <- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = controller)
      candidate_worker <- new.env(parent = baseenv())
      sys.source(worker_paths[[1L]], envir = candidate_worker)
      capability_worker <- new.env(parent = baseenv())
      sys.source(worker_paths[[2L]], envir = capability_worker)
      environments <<- list(
        controller = controller, candidate_worker = candidate_worker,
        capability_worker = capability_worker
      )
    }
    environments
  }
})

skip_if_not_c4b_macos <- function() {
  skip_if_not(identical(Sys.info()[["sysname"]], "Darwin"),
              "Draft.85c4b capability isolation is macOS-specific")
}

skip_if_not_c4b_live <- function() {
  skip_if_not_c4b_macos()
  skip_if_not(
    identical(Sys.getenv("MFRMR_RUN_C4B_MACOS_SANDBOX"), "true"),
    "set MFRMR_RUN_C4B_MACOS_SANDBOX=true for live sandbox evidence"
  )
}

gtvh_runtime <- local({
  runtime <- NULL
  function(env) {
    if (is.null(runtime)) {
      validation_dir <- dirname(
        gtheory_multivariate_capability_worker_paths()[[1L]]
      )
      runtime <<- env$mfrmr_gtvh_runtime_identity(validation_dir)
    }
    runtime
  }
})

gtvh_core_objects <- local({
  objects <- NULL
  function(env) {
    if (is.null(objects)) {
      plan <- env$mfrmr_gtvd_plan()
      generator <- env$mfrmr_gtve_manifest(plan)
      objects <<- list(plan = plan, generator = generator)
    }
    objects
  }
})

gtvh_live_evidence <- local({
  evidence <- NULL
  function(environments) {
    skip_if_not_c4b_live()
    if (is.null(evidence)) {
      env <- environments$controller
      objects <- gtvh_core_objects(env)
      evidence <<- env$mfrmr_gtvh_live_preflight(
        environments$candidate_worker,
        validation_dir = dirname(
          gtheory_multivariate_capability_worker_paths()[[1L]]
        ),
        authorize_live_sandbox = TRUE,
        keep_staging = FALSE,
        plan = objects$plan,
        generator_manifest = objects$generator
      )
    }
    evidence
  }
})

test_that("Draft.85c4b capability worker is a four-function standalone file", {
  environments <- load_gtheory_multivariate_capability()
  worker <- environments$capability_worker
  expect_identical(parent.env(worker), baseenv())
  expect_identical(
    sort(ls(worker, all.names = TRUE)),
    sort(c(
      "mfrmr_gtvhw_hash", "mfrmr_gtvhw_attempt", "mfrmr_gtvhw_probe",
      "mfrmr_gtvhw_main"
    ))
  )
  expect_true(all(vapply(
    ls(worker, all.names = TRUE), function(name) {
      is.function(get(name, envir = worker, inherits = FALSE))
    }, logical(1L)
  )))
  function_text <- vapply(ls(worker, all.names = TRUE), function(name) {
    paste(deparse(body(get(name, envir = worker, inherits = FALSE))),
          collapse = "\n")
  }, character(1L))
  expect_false(any(grepl("lme4::|glmmTMB::|ConQuest", function_text)))
})

test_that("Draft.85c4b binds the exact local sandbox and R runtime", {
  skip_if_not_c4b_macos()
  environments <- load_gtheory_multivariate_capability()
  env <- environments$controller
  runtime <- gtvh_runtime(env)

  expect_identical(nrow(runtime), 1L)
  expect_identical(runtime$OS, "Darwin")
  expect_true(file.exists(runtime$SandboxExecutable))
  expect_true(file.exists(runtime$EnvironmentExecutable))
  expect_true(file.exists(runtime$RExecutable))
  expect_true(file.exists(runtime$SystemProfile))
  expect_true(dir.exists(runtime$ValidationDirectory))
  expect_true(dir.exists(runtime$DigestPath))
  expect_true(file.exists(runtime$CandidateWorkerPath))
  expect_true(file.exists(runtime$CapabilityWorkerPath))
  hash_columns <- grep("Hash$", names(runtime), value = TRUE)
  expect_true(all(vapply(runtime[hash_columns], function(value) {
    is.character(value) && length(value) == 1L && nchar(value) == 64L
  }, logical(1L))))
  expect_identical(
    runtime$CapabilityWorkerHash,
    env$mfrmr_gtvh_file_hash(runtime$CapabilityWorkerPath)
  )
})

test_that("Draft.85c4b policy is default-deny and excludes protected paths", {
  skip_if_not_c4b_macos()
  environments <- load_gtheory_multivariate_capability()
  env <- environments$controller
  runtime <- gtvh_runtime(env)
  root <- tempfile("mfrmr-c4b-policy-", tmpdir = "/private/tmp")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  staging <- env$mfrmr_gtvh_staging(root)
  profile <- env$mfrmr_gtvh_policy_text(runtime, staging)
  audit <- env$mfrmr_gtvh_policy_audit(profile, runtime, staging)

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

test_that("Draft.85c4b policy audit detects relaxed or leaked profiles", {
  skip_if_not_c4b_macos()
  environments <- load_gtheory_multivariate_capability()
  env <- environments$controller
  runtime <- gtvh_runtime(env)
  root <- tempfile("mfrmr-c4b-policy-negative-", tmpdir = "/private/tmp")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  staging <- env$mfrmr_gtvh_staging(root)
  profile <- env$mfrmr_gtvh_policy_text(runtime, staging)

  relaxed <- sub("\\(deny default\\)", "(allow default)", profile)
  audit <- env$mfrmr_gtvh_policy_audit(relaxed, runtime, staging)
  expect_false(audit$Passed[audit$Rule == "default_deny"])
  expect_false(audit$Passed[audit$Rule == "no_allow_default"])

  networked <- paste(profile, "(allow network*)", sep = "\n")
  audit <- env$mfrmr_gtvh_policy_audit(networked, runtime, staging)
  expect_false(audit$Passed[audit$Rule == "no_network_allow"])

  leaked <- paste(profile, staging$Vault, sep = "\n")
  audit <- env$mfrmr_gtvh_policy_audit(leaked, runtime, staging)
  expect_false(audit$Passed[audit$Rule == "no_vault_path"])

  source_leaked <- paste(profile, runtime$ValidationDirectory, sep = "\n")
  audit <- env$mfrmr_gtvh_policy_audit(source_leaked, runtime, staging)
  expect_false(audit$Passed[audit$Rule == "no_repository_path"])
})

test_that("Draft.85c4b live runner requires explicit authorization", {
  skip_if_not_c4b_macos()
  environments <- load_gtheory_multivariate_capability()
  env <- environments$controller
  expect_error(
    env$mfrmr_gtvh_live_preflight(
      environments$candidate_worker, authorize_live_sandbox = FALSE
    ),
    "authorize_live_sandbox=TRUE"
  )
})

test_that("Draft.85c4b live sandbox passes all six capability controls", {
  environments <- load_gtheory_multivariate_capability()
  env <- environments$controller
  evidence <- gtvh_live_evidence(environments)

  expect_silent(env$mfrmr_gtvh_assert_live_evidence(
    evidence, environments$candidate_worker
  ))
  expect_s3_class(evidence, "mfrmr_gtvh_live_evidence")
  expect_identical(
    evidence$ControlRegistry$Mode,
    c(
      "normal", "probe_vault_read", "probe_source_read",
      "probe_outside_write", "probe_parent_environment",
      "probe_unlisted_exec"
    )
  )
  expect_identical(
    evidence$ControlRegistry$DenialClass,
    c(
      "normal_candidate_receipt", rep("sandbox_operation_denied", 3L),
      "parent_environment_absent", "sandbox_operation_denied"
    )
  )
  expect_identical(
    evidence$ControlRegistry$ActionSucceeded,
    c(TRUE, rep(FALSE, 5L))
  )
  expect_true(all(evidence$ControlRegistry$ControlPassed))
  expect_false(any(evidence$ControlRegistry$ParentSecretVisible))
  expect_identical(evidence$ControlRegistry$SandboxExitStatus, rep(0L, 6L))
})

test_that("Draft.85c4b promotes only the exact capability boundary", {
  environments <- load_gtheory_multivariate_capability()
  evidence <- gtvh_live_evidence(environments)

  expect_true(evidence$DefaultDenyProfileReady)
  expect_true(evidence$SanitizedEnvironmentReady)
  expect_true(evidence$CandidateInputReadReady)
  expect_true(evidence$CandidateReceiptWriteReady)
  expect_true(evidence$ReferenceVaultReadDenied)
  expect_true(evidence$SourceTreeReadDenied)
  expect_true(evidence$OutsideWriteDenied)
  expect_true(evidence$ParentEnvironmentSecretAbsent)
  expect_true(evidence$UnlistedExecutableDenied)
  expect_true(evidence$ExternalNetworkPolicyClosed)
  expect_true(evidence$ProcessCapabilityIsolationReady)
  expect_true(evidence$TruthBlindProcessBoundaryReady)
  expect_false(evidence$BackendQualificationReady)
  expect_false(evidence$PilotExecutionAuthorized)
  expect_false(evidence$ConfirmationExecutionAuthorized)
  expect_false(evidence$BackendExecutionOccurred)
  expect_false(evidence$PlannedResponseGenerated)
  expect_false(evidence$RecoveryExecuted)
  expect_false(evidence$RecoveryEvidenceReady)
  expect_false(evidence$EstimationReady)
  expect_false(evidence$InferenceReady)
  expect_false(evidence$DecisionReady)
  expect_false(evidence$PublicSupportReady)
  expect_false(evidence$StagingContentRetained)
  expect_false(evidence$PlannedSeedMaterialIncluded)
  expect_false(evidence$ReferenceVaultContentIncluded)
  expect_true(nchar(evidence$ReferenceVaultHash) == 64L)
})

test_that("Draft.85c4b evidence fails closed after mutation", {
  environments <- load_gtheory_multivariate_capability()
  env <- environments$controller
  evidence <- gtvh_live_evidence(environments)

  changed <- evidence
  changed$PilotExecutionAuthorized <- TRUE
  expect_error(env$mfrmr_gtvh_assert_live_evidence(
    changed, environments$candidate_worker
  ),
               "live evidence, controls, or readiness")

  changed <- evidence
  changed$ControlRegistry$ActionSucceeded[[2L]] <- TRUE
  changed$ControlRegistryHash <- env$mfrmr_gta_hash(changed$ControlRegistry)
  changed$EvidenceHash <- env$mfrmr_gta_hash(
    changed[env$mfrmr_gtvh_live_payload_fields()]
  )
  expect_error(env$mfrmr_gtvh_assert_live_evidence(
    changed, environments$candidate_worker
  ),
               "live evidence, controls, or readiness")

  changed <- evidence
  changed$PolicyAudit$Passed[[1L]] <- FALSE
  changed$PolicyAuditHash <- env$mfrmr_gta_hash(changed$PolicyAudit)
  changed$EvidenceHash <- env$mfrmr_gta_hash(
    changed[env$mfrmr_gtvh_live_payload_fields()]
  )
  expect_error(env$mfrmr_gtvh_assert_live_evidence(
    changed, environments$candidate_worker
  ),
               "live evidence, controls, or readiness")

  changed <- evidence
  changed$ReferenceVaultHash <- paste(rep("0", 64L), collapse = "")
  changed$EvidenceHash <- env$mfrmr_gta_hash(
    changed[env$mfrmr_gtvh_live_payload_fields()]
  )
  expect_error(env$mfrmr_gtvh_assert_live_evidence(
    changed, environments$candidate_worker
  ), "live evidence, controls, or readiness")
})

test_that("Draft.85c4b remains internal and contains no planned seed", {
  environments <- load_gtheory_multivariate_capability()
  evidence <- gtvh_live_evidence(environments)
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
    "ReferenceId", "Estimate", "LogLik"
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
  expect_false(any(grepl("Draft\\.85c4b|mfrmr_gtvh[w]?_", public_text)))
})
