gtheory_multivariate_full_capability_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-incidence-preflight-0.2.4.R",
      "gtheory-multivariate-matched-backend-prototype-0.2.4.R",
      "gtheory-multivariate-execution-admission-preflight-0.2.4.R",
      paste0(
        "gtheory-multivariate-backend-qualification-admission-",
        "preflight-0.2.4.R"
      ),
      "gtheory-multivariate-four-route-qualification-protocol-0.2.4.R",
      "gtheory-multivariate-abi-repair-execution-0.2.4.R",
      "gtheory-multivariate-full-object-qualification-execution-0.2.4.R",
      paste0(
        "gtheory-multivariate-full-object-capability-isolation-",
        "preflight-0.2.4.R"
      )
    )
  )
}

gtheory_multivariate_full_capability_worker_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-multivariate-abi-repair-identity-worker-0.2.4.R",
      "gtheory-multivariate-full-object-qualification-worker-0.2.4.R",
      "gtheory-multivariate-full-object-capability-worker-0.2.4.R"
    )
  )
}

load_gtheory_multivariate_full_capability <- local({
  environments <- NULL
  function() {
    paths <- gtheory_multivariate_full_capability_paths()
    workers <- gtheory_multivariate_full_capability_worker_paths()
    skip_if_not(all(file.exists(c(paths, workers))),
                "repository-internal validation artifacts are excluded")
    skip_if_not_installed("digest")
    if (is.null(environments)) {
      controller <- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = controller)
      repair_worker <- new.env(parent = baseenv())
      sys.source(workers[[1L]], envir = repair_worker)
      qualification_worker <- new.env(parent = baseenv())
      sys.source(workers[[2L]], envir = qualification_worker)
      capability_worker <- new.env(parent = baseenv())
      sys.source(workers[[3L]], envir = capability_worker)
      environments <<- list(
        controller = controller, repair_worker = repair_worker,
        qualification_worker = qualification_worker,
        capability_worker = capability_worker
      )
    }
    environments
  }
})

gtvr_repo_root <- function() testthat::test_path("..", "..")

gtvr_validation_dir <- function() {
  dirname(gtheory_multivariate_full_capability_worker_paths()[[1L]])
}

skip_if_not_c4k_macos <- function() {
  skip_if_not(identical(Sys.info()[["sysname"]], "Darwin"),
              "Draft.85c4k capability isolation is macOS-specific")
}

skip_if_not_c4k_live <- function() {
  skip_if_not_c4k_macos()
  skip_if_not(
    identical(Sys.getenv("MFRMR_RUN_C4K_MACOS_SANDBOX"), "true"),
    "set MFRMR_RUN_C4K_MACOS_SANDBOX=true for live sandbox evidence"
  )
  path <- Sys.getenv("MFRMR_C4I_RECEIPT", unset = "")
  skip_if_not(nzchar(path) && file.exists(path),
              "set MFRMR_C4I_RECEIPT to the retained repair receipt")
}

gtvr_objects <- local({
  objects <- NULL
  function(environments) {
    skip_if_not_c4k_live()
    if (is.null(objects)) {
      env <- environments$controller
      identity <- env$mfrmr_gtvl_environment_identity()
      c4e <- env$mfrmr_gtvl_manifest(gtvr_repo_root(), identity)
      c4f <- env$mfrmr_gtvm_manifest(gtvr_repo_root(), c4e)
      repair <- readRDS(Sys.getenv("MFRMR_C4I_RECEIPT"))
      qualification <- env$mfrmr_gtvq_execute(
        repair, environments$repair_worker, c4e, c4f,
        environments$qualification_worker,
        repo_root = gtvr_repo_root(), validation_dir = gtvr_validation_dir(),
        authorize_qualification = TRUE, allow_exact_reuse = TRUE
      )
      objects <<- list(
        identity = identity, c4e = c4e, c4f = c4f, repair = repair,
        qualification = qualification
      )
    }
    objects
  }
})

gtvr_live_evidence <- local({
  evidence <- NULL
  function(environments) {
    objects <- gtvr_objects(environments)
    if (is.null(evidence)) {
      observed <- environments$controller$mfrmr_gtvr_live_preflight(
        objects$qualification, objects$repair,
        environments$repair_worker, objects$c4e, objects$c4f,
        environments$qualification_worker, environments$capability_worker,
        repo_root = gtvr_repo_root(), validation_dir = gtvr_validation_dir(),
        authorize_live_sandbox = TRUE,
        keep_staging = identical(
          Sys.getenv("MFRMR_C4K_KEEP_STAGING"), "true"
        )
      )
      retained_path <- Sys.getenv("MFRMR_C4K_EVIDENCE_PATH", unset = "")
      if (nzchar(retained_path)) saveRDS(observed, retained_path, version = 3L)
      evidence <<- observed
    }
    evidence
  }
})

test_that("Draft.85c4k capability wrapper is an exact five-function file", {
  environments <- load_gtheory_multivariate_full_capability()
  worker <- environments$capability_worker
  identity <- environments$controller$mfrmr_gtvr_capability_worker_identity(
    worker
  )
  expect_identical(parent.env(worker), baseenv())
  expect_identical(nrow(identity), 5L)
  expect_identical(anyDuplicated(identity$Function), 0L)
  expect_true(all(grepl("^mfrmr_gtvrw_", identity$Function)))
  expect_true(all(grepl("^[0-9a-f]{64}$", identity$SHA256)))
})

test_that("Draft.85c4k controller has a distinct twenty-three-function identity", {
  environments <- load_gtheory_multivariate_full_capability()
  identity <- environments$controller$mfrmr_gtvr_implementation_identity()
  expect_identical(nrow(identity), 23L)
  expect_identical(anyDuplicated(identity$Function), 0L)
  expect_true(all(grepl("^mfrmr_gtvr_", identity$Function)))
  expect_true(all(grepl("^[0-9a-f]{64}$", identity$SHA256)))
})

test_that("Draft.85c4k binds the exact runtime and loaded closure", {
  skip_if_not_c4k_macos()
  environments <- load_gtheory_multivariate_full_capability()
  objects <- gtvr_objects(environments)
  runtime <- environments$controller$mfrmr_gtvr_runtime_identity(
    objects$qualification, objects$repair, gtvr_validation_dir()
  )
  expect_s3_class(runtime, "mfrmr_gtvr_runtime")
  expect_identical(runtime$OS, "Darwin")
  expect_identical(runtime$RuntimeLocale, "C.UTF-8")
  expect_true(file.exists(runtime$SandboxExecutable))
  expect_true(file.exists(runtime$EnvironmentExecutable))
  expect_true(file.exists(runtime$RExecutable))
  expect_true(file.exists(runtime$SystemProfile))
  expect_identical(runtime$QualificationWorkerHash,
                   objects$qualification$WorkerSourceSHA256)
  expect_identical(length(runtime$PackageReadPaths), 38L)
  expect_true(length(runtime$ExternalNativeReadPaths) > 0L)
  expect_true(all(file.exists(runtime$LinkedRuntimeRegistry$LinkPath)))
})

test_that("Draft.85c4k policy is exact-read default-deny", {
  skip_if_not_c4k_macos()
  environments <- load_gtheory_multivariate_full_capability()
  env <- environments$controller
  objects <- gtvr_objects(environments)
  runtime <- env$mfrmr_gtvr_runtime_identity(
    objects$qualification, objects$repair, gtvr_validation_dir()
  )
  root <- tempfile("mfrmr-c4k-policy-", tmpdir = "/private/tmp")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  staging <- env$mfrmr_gtvr_staging(root)
  profile <- env$mfrmr_gtvr_policy_text(runtime, staging)
  audit <- env$mfrmr_gtvr_policy_audit(profile, runtime, staging)
  expect_identical(nrow(audit), 22L)
  expect_true(all(audit$Passed))
  expect_match(profile, "\\(deny default\\)")
  expect_false(grepl("\\(allow default\\)", profile))
  expect_false(grepl("allow network", profile))
  expect_false(grepl(staging$Vault, profile, fixed = TRUE))
  expect_false(grepl(staging$ForbiddenOutput, profile, fixed = TRUE))
  expect_false(grepl(staging$DeniedRoot, profile, fixed = TRUE))
  expect_true(startsWith(
    staging$RuntimeLibrary,
    paste0(staging$AllowedRoot, .Platform$file.sep)
  ))
  expect_false(grepl(runtime$ValidationDirectory, profile, fixed = TRUE))
  expect_true(all(vapply(runtime$PackageReadPaths, grepl, logical(1L),
                         x = profile, fixed = TRUE)))
})

test_that("Draft.85c4k policy audit catches relaxation and protected paths", {
  skip_if_not_c4k_macos()
  environments <- load_gtheory_multivariate_full_capability()
  env <- environments$controller
  objects <- gtvr_objects(environments)
  runtime <- env$mfrmr_gtvr_runtime_identity(
    objects$qualification, objects$repair, gtvr_validation_dir()
  )
  root <- tempfile("mfrmr-c4k-policy-negative-", tmpdir = "/private/tmp")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  staging <- env$mfrmr_gtvr_staging(root)
  profile <- env$mfrmr_gtvr_policy_text(runtime, staging)
  relaxed <- sub("\\(deny default\\)", "(allow default)", profile)
  audit <- env$mfrmr_gtvr_policy_audit(relaxed, runtime, staging)
  expect_false(audit$Passed[audit$Rule == "default_deny"])
  expect_false(audit$Passed[audit$Rule == "no_allow_default"])
  networked <- paste(profile, "(allow network*)", sep = "\n")
  expect_false(env$mfrmr_gtvr_policy_audit(
    networked, runtime, staging
  )$Passed[5L])
  leaked <- paste(profile, staging$Vault, sep = "\n")
  expect_false(env$mfrmr_gtvr_policy_audit(
    leaked, runtime, staging
  )$Passed[6L])
  repo_leaked <- paste(profile, runtime$ValidationDirectory, sep = "\n")
  expect_false(env$mfrmr_gtvr_policy_audit(
    repo_leaked, runtime, staging
  )$Passed[9L])
})

test_that("Draft.85c4k live runner requires explicit authorization", {
  skip_if_not_c4k_macos()
  environments <- load_gtheory_multivariate_full_capability()
  objects <- gtvr_objects(environments)
  expect_error(environments$controller$mfrmr_gtvr_live_preflight(
    objects$qualification, objects$repair, environments$repair_worker,
    objects$c4e, objects$c4f, environments$qualification_worker,
    environments$capability_worker, repo_root = gtvr_repo_root(),
    validation_dir = gtvr_validation_dir()
  ), "authorize_live_sandbox=TRUE")
})

test_that("Draft.85c4k live sandbox passes normal and five denial controls", {
  environments <- load_gtheory_multivariate_full_capability()
  objects <- gtvr_objects(environments)
  evidence <- gtvr_live_evidence(environments)
  expect_silent(environments$controller$mfrmr_gtvr_assert_live_evidence(
    evidence, objects$qualification, objects$repair,
    environments$repair_worker, objects$c4e, objects$c4f,
    environments$qualification_worker, environments$capability_worker,
    gtvr_repo_root(), gtvr_validation_dir()
  ))
  expect_s3_class(evidence, "mfrmr_gtvr_live_evidence")
  expect_identical(evidence$ControlRegistry$Mode, c(
    "normal", "probe_vault_read", "probe_source_read",
    "probe_outside_write", "probe_parent_environment",
    "probe_unlisted_exec"
  ))
  expect_identical(evidence$ControlRegistry$DenialClass, c(
    "normal_full_qualification", rep("sandbox_operation_denied", 3L),
    "parent_environment_absent", "sandbox_operation_denied"
  ))
  expect_identical(evidence$ControlRegistry$ActionSucceeded,
                   c(TRUE, rep(FALSE, 5L)))
  expect_true(all(evidence$ControlRegistry$ControlPassed))
  expect_true(all(evidence$ControlRegistry$SandboxProcessOutputEmpty))
  expect_false(any(evidence$ControlRegistry$ParentSecretVisible))
})

test_that("Draft.85c4k promotes backend qualification but no study lane", {
  environments <- load_gtheory_multivariate_full_capability()
  evidence <- gtvr_live_evidence(environments)
  ready <- c(
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
  closed <- c(
    "DiagnosticOverrideAllowed", "PlannedExecutionAuthorized",
    "PlannedResponseGenerated", "RecoveryExecuted", "RecoveryEvidenceReady",
    "EstimationReady", "InferenceReady", "DecisionReady",
    "PublicSupportReady"
  )
  expect_true(all(vapply(ready, function(name) evidence[[name]], logical(1L))))
  expect_false(any(vapply(closed, function(name) evidence[[name]],
                          logical(1L))))
  expect_true(all(evidence$TrustedRouteRegistry$TrustedReceiptReady))
  expect_true(all(evidence$TrustedPairRegistry$TrustedPairReady))
  expect_false(evidence$StagingContentRetained)
  expect_false(evidence$PlannedSeedMaterialIncluded)
  expect_false(evidence$ReferenceTruthIncluded)
  expect_false(evidence$ConQuestRouteIncluded)
})

test_that("Draft.85c4k evidence rejects mutation and keeps dispatch closed", {
  environments <- load_gtheory_multivariate_full_capability()
  objects <- gtvr_objects(environments)
  evidence <- gtvr_live_evidence(environments)
  args <- list(
    qualification_receipt = objects$qualification,
    repair_receipt = objects$repair,
    repair_worker_environment = environments$repair_worker,
    c4e_manifest = objects$c4e, c4f_manifest = objects$c4f,
    qualification_worker_environment = environments$qualification_worker,
    capability_worker_environment = environments$capability_worker,
    repo_root = gtvr_repo_root(), validation_dir = gtvr_validation_dir()
  )
  changed <- evidence
  changed$PublicSupportReady <- TRUE
  expect_error(do.call(
    environments$controller$mfrmr_gtvr_assert_live_evidence,
    c(list(evidence = changed), args)
  ), "live evidence, controls, or readiness")
  changed <- evidence
  changed$TrustedRouteRegistry$TrustedReceiptReady[[1L]] <- FALSE
  changed$TrustedRouteRegistryHash <- environments$controller$mfrmr_gtvr_hash(
    changed$TrustedRouteRegistry
  )
  changed$EvidenceHash <- environments$controller$mfrmr_gtvr_hash(
    changed[environments$controller$mfrmr_gtvr_live_payload_fields()]
  )
  expect_error(do.call(
    environments$controller$mfrmr_gtvr_assert_live_evidence,
    c(list(evidence = changed), args)
  ), "live evidence, controls, or readiness")
  called <- FALSE
  callback <- function() {
    called <<- TRUE
    TRUE
  }
  for (action in c(
    "planned_response", "recovery_analysis", "public_promotion"
  )) {
    expect_error(do.call(
      environments$controller$mfrmr_gtvr_dispatch_guard,
      c(list(
        evidence = evidence, action = action, callback = callback,
        authorize = TRUE
      ), args)
    ), "planned execution remains closed")
  }
  expect_false(called)
})

test_that("Draft.85c4k remains absent from public package surfaces", {
  environments <- load_gtheory_multivariate_full_capability()
  evidence <- gtvr_live_evidence(environments)
  expect_false(evidence$PublicSupportReady)
  public_paths <- testthat::test_path(
    "..", "..", c("R", "man", "vignettes", "NEWS.md", "ROADMAP.md")
  )
  public_files <- unlist(lapply(public_paths, function(path) {
    if (dir.exists(path)) list.files(path, recursive = TRUE, full.names = TRUE)
    else path[file.exists(path)]
  }), use.names = FALSE)
  public_files <- public_files[!dir.exists(public_files)]
  public_files <- public_files[grepl(
    "\\.(R|Rd|Rmd|md)$", public_files, ignore.case = FALSE
  )]
  public_text <- unlist(lapply(public_files, function(path) {
    readLines(path, warn = FALSE, encoding = "UTF-8")
  }), use.names = FALSE)
  expect_false(any(grepl("Draft\\.85c4k|mfrmr_gtvr[w]?_", public_text)))
})
