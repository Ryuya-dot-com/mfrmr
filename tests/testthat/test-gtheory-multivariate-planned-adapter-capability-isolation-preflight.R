gtheory_multivariate_c4n_paths <- function() {
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
      ),
      paste0(
        "gtheory-multivariate-backend-qualification-integration-",
        "preflight-0.2.4.R"
      ),
      "gtheory-multivariate-planned-adapter-preflight-0.2.4.R",
      paste0(
        "gtheory-multivariate-planned-adapter-capability-isolation-",
        "preflight-0.2.4.R"
      )
    )
  )
}

gtheory_multivariate_c4n_worker_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-multivariate-abi-repair-identity-worker-0.2.4.R",
      "gtheory-multivariate-full-object-qualification-worker-0.2.4.R",
      "gtheory-multivariate-full-object-capability-worker-0.2.4.R",
      "gtheory-multivariate-planned-adapter-worker-0.2.4.R",
      "gtheory-multivariate-planned-adapter-capability-worker-0.2.4.R"
    )
  )
}

load_gtheory_multivariate_c4n <- local({
  environments <- NULL
  function() {
    paths <- gtheory_multivariate_c4n_paths()
    workers <- gtheory_multivariate_c4n_worker_paths()
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
      adapter_worker <- new.env(parent = baseenv())
      sys.source(workers[[4L]], envir = adapter_worker)
      c4n_capability_worker <- new.env(parent = baseenv())
      sys.source(workers[[5L]], envir = c4n_capability_worker)
      environments <<- list(
        controller = controller, repair_worker = repair_worker,
        qualification_worker = qualification_worker,
        capability_worker = capability_worker,
        adapter_worker = adapter_worker,
        c4n_capability_worker = c4n_capability_worker
      )
    }
    environments
  }
})

gtvu_repo_root <- function() testthat::test_path("..", "..")

gtvu_validation_dir <- function() {
  dirname(gtheory_multivariate_c4n_worker_paths()[[1L]])
}

skip_if_not_c4n_evidence <- function() {
  skip_if_not(identical(Sys.info()[["sysname"]], "Darwin"),
              "Draft.85c4n live isolation requires macOS")
  skip_if_not(
    identical(Sys.getenv("MFRMR_RUN_C4N_MACOS_SANDBOX"), "true"),
    "set MFRMR_RUN_C4N_MACOS_SANDBOX=true for live c4n isolation"
  )
  paths <- Sys.getenv(c(
    "MFRMR_C4I_RECEIPT", "MFRMR_C4J_RECEIPT", "MFRMR_C4K_EVIDENCE",
    "MFRMR_C4L_RECEIPT", "MFRMR_C4M_MANIFEST"
  ), unset = "")
  skip_if_not(all(nzchar(paths) & file.exists(paths)),
              "set retained c4i through c4m evidence paths")
}

gtvu_objects <- local({
  objects <- NULL
  function(environments) {
    skip_if_not_c4n_evidence()
    if (is.null(objects)) {
      env <- environments$controller
      plan <- env$mfrmr_gtvd_plan()
      generator <- env$mfrmr_gtve_manifest(plan)
      c3 <- env$mfrmr_gtvf_manifest(
        plan, generator, env$mfrmr_gtvf_environment_snapshot()
      )
      c4e_environment <- env$mfrmr_gtvl_environment_identity()
      c4e <- env$mfrmr_gtvl_manifest(gtvu_repo_root(), c4e_environment)
      c4f <- env$mfrmr_gtvm_manifest(gtvu_repo_root(), c4e)
      objects <<- list(
        plan = plan, generator = generator, c3 = c3,
        c4e_environment = c4e_environment, c4e = c4e, c4f = c4f,
        repair = readRDS(Sys.getenv("MFRMR_C4I_RECEIPT")),
        qualification = readRDS(Sys.getenv("MFRMR_C4J_RECEIPT")),
        capability = readRDS(Sys.getenv("MFRMR_C4K_EVIDENCE")),
        integration = readRDS(Sys.getenv("MFRMR_C4L_RECEIPT")),
        adapter = readRDS(Sys.getenv("MFRMR_C4M_MANIFEST"))
      )
    }
    objects
  }
})

gtvu_evidence_args <- function(environments, objects) {
  list(
    plan = objects$plan, generator_manifest = objects$generator,
    c3_manifest = objects$c3, c4e_manifest = objects$c4e,
    c4f_manifest = objects$c4f, repair_receipt = objects$repair,
    qualification_receipt = objects$qualification,
    capability_evidence = objects$capability,
    c4l_receipt = objects$integration, c4m_manifest = objects$adapter,
    repair_worker_environment = environments$repair_worker,
    qualification_worker_environment = environments$qualification_worker,
    capability_worker_environment = environments$capability_worker,
    adapter_worker_environment = environments$adapter_worker,
    c4n_capability_worker_environment = environments$c4n_capability_worker,
    repo_root = gtvu_repo_root(), validation_dir = gtvu_validation_dir()
  )
}

gtvu_evidence <- local({
  evidence <- NULL
  function(environments, objects) {
    if (is.null(evidence)) {
      evidence_path <- Sys.getenv("MFRMR_C4N_EVIDENCE_PATH", unset = "")
      if (nzchar(evidence_path) && file.exists(evidence_path)) {
        evidence <<- readRDS(evidence_path)
      } else {
        evidence <<- do.call(
          environments$controller$mfrmr_gtvu_live_preflight,
          c(gtvu_evidence_args(environments, objects), list(
            authorize_live_sandbox = TRUE, keep_staging = FALSE
          ))
        )
        if (nzchar(evidence_path)) {
          saveRDS(evidence, evidence_path, version = 3L)
        }
      }
    }
    evidence
  }
})

test_that("Draft.85c4n wrapper has an exact five-function namespace", {
  environments <- load_gtheory_multivariate_c4n()
  identity <- environments$controller$mfrmr_gtvu_capability_worker_identity(
    environments$c4n_capability_worker
  )
  expect_identical(parent.env(environments$c4n_capability_worker), baseenv())
  expect_identical(nrow(identity), 5L)
  expect_identical(anyDuplicated(identity$Function), 0L)
  expect_true(all(grepl("^mfrmr_gtvuw_", identity$Function)))
  expect_true(all(grepl("^[0-9a-f]{64}$", identity$SHA256)))
})

test_that("Draft.85c4n controller has a distinct twenty-two-function identity", {
  environments <- load_gtheory_multivariate_c4n()
  identity <- environments$controller$mfrmr_gtvu_implementation_identity()
  expect_identical(nrow(identity), 22L)
  expect_identical(anyDuplicated(identity$Function), 0L)
  expect_true(all(grepl("^mfrmr_gtvu_", identity$Function)))
  expect_true(all(grepl("^[0-9a-f]{64}$", identity$SHA256)))
})

test_that("Draft.85c4n revalidates c4m and its complete lineage", {
  environments <- load_gtheory_multivariate_c4n()
  objects <- gtvu_objects(environments)
  evidence <- gtvu_evidence(environments, objects)
  expect_silent(do.call(
    environments$controller$mfrmr_gtvu_assert_evidence,
    c(list(evidence = evidence), gtvu_evidence_args(environments, objects))
  ))
  expect_s3_class(evidence, "mfrmr_gtvu_evidence")
  expect_identical(evidence$PlanHash, objects$plan$PlanHash)
  expect_identical(
    evidence$C4MManifestHash, objects$adapter$ManifestHash
  )
  expect_identical(
    evidence$C4LReceiptHash, objects$integration$ReceiptHash
  )
})

test_that("Draft.85c4n runs three normal receipts and six denial controls", {
  environments <- load_gtheory_multivariate_c4n()
  objects <- gtvu_objects(environments)
  evidence <- gtvu_evidence(environments, objects)
  controls <- evidence$ControlRegistry
  expect_identical(nrow(controls), 9L)
  expect_identical(controls$SandboxExitStatus, rep(0L, 9L))
  expect_true(all(controls$SandboxProcessOutputEmpty))
  expect_true(all(controls$OutputReceiptExists))
  expect_identical(
    controls$ActionSucceeded, c(rep(TRUE, 3L), rep(FALSE, 6L))
  )
  expect_false(any(controls$ParentSecretVisible))
  expect_true(all(controls$ControlPassed))
  expect_identical(
    controls$DenialClass,
    c(
      rep("normal_adapter_receipt", 3L),
      rep("sandbox_operation_denied", 3L),
      "parent_environment_absent",
      rep("sandbox_operation_denied", 2L)
    )
  )
})

test_that("Draft.85c4n fresh-process receipts preserve all denominators", {
  environments <- load_gtheory_multivariate_c4n()
  objects <- gtvu_objects(environments)
  receipts <- gtvu_evidence(environments, objects)$NormalReceiptRegistry
  expect_identical(nrow(receipts), 3L)
  expect_identical(
    receipts$StageId, c("pilot", "confirmation", "negative_control")
  )
  expect_identical(receipts$ExpectedUnits, c(960L, 19200L, 8L))
  expect_identical(receipts$ObservedUnits, receipts$ExpectedUnits)
  expect_true(all(receipts$ExactCanonicalReceipt))
  expect_true(all(grepl("^[0-9a-f]{64}$", receipts$RequestHash)))
  expect_true(all(grepl("^[0-9a-f]{64}$", receipts$ReceiptHash)))
})

test_that("Draft.85c4n binds runtime and audits default deny", {
  environments <- load_gtheory_multivariate_c4n()
  objects <- gtvu_objects(environments)
  evidence <- gtvu_evidence(environments, objects)
  runtime <- evidence$RuntimeIdentity
  expect_identical(runtime$OS, "Darwin")
  expect_identical(runtime$RuntimeLocale, "C.UTF-8")
  expect_identical(
    runtime$AdapterWorkerHash, objects$adapter$WorkerSourceSHA256
  )
  expect_identical(nrow(evidence$StagedRuntimeRegistry), 1L)
  expect_identical(evidence$StagedRuntimeRegistry$Package, "digest")
  expect_identical(nrow(evidence$PolicyAudit), 21L)
  expect_true(all(evidence$PolicyAudit$Passed))
  expect_true(evidence$DefaultDenyProfileReady)
  expect_true(evidence$SanitizedEnvironmentReady)
  expect_true(evidence$ExactDigestRuntimeReady)
})

test_that("Draft.85c4n qualifies only the non-attempt adapter process", {
  environments <- load_gtheory_multivariate_c4n()
  objects <- gtvu_objects(environments)
  evidence <- gtvu_evidence(environments, objects)
  audit <- evidence$PrerequisiteProjection
  truth <- audit$PrerequisiteId == "truth_blind_process_boundary"
  expect_false(any(audit$TransitionedByC4N))
  expect_identical(sum(audit$C4NProjectedSatisfied), 2L)
  expect_false(audit$C4NProjectedSatisfied[truth])
  expect_true(audit$AdapterSchemaEvidenceAvailable[truth])
  expect_true(audit$PlannedAdapterCapabilityEvidenceAvailable[truth])
  expect_false(audit$FitCapableTruthBlindBoundaryEvidenceAvailable[truth])
  expect_true(evidence$PlannedAdapterProcessCapabilityIsolationReady)
  expect_true(evidence$ProcessCapabilityIsolationReady)
  expect_false(evidence$TruthBlindProcessBoundaryReady)
  expect_true(evidence$ExactlyZeroC3PrerequisitesTransitioned)
  expect_identical(evidence$C3SatisfiedPrerequisiteCount, 2L)
})

test_that("Draft.85c4n evidence is hash complete and rejects promotion", {
  environments <- load_gtheory_multivariate_c4n()
  objects <- gtvu_objects(environments)
  evidence <- gtvu_evidence(environments, objects)
  env <- environments$controller
  expect_identical(
    evidence$EvidenceHash,
    env$mfrmr_gtvu_hash(evidence[env$mfrmr_gtvu_payload_fields()])
  )
  expect_identical(
    evidence$ControlResultsHash, env$mfrmr_gtvu_hash(evidence$ControlResults)
  )
  expect_identical(
    evidence$NormalReceiptRegistryHash,
    env$mfrmr_gtvu_hash(evidence$NormalReceiptRegistry)
  )
  changed <- evidence
  changed$TruthBlindProcessBoundaryReady <- TRUE
  expect_error(do.call(
    env$mfrmr_gtvu_assert_evidence,
    c(list(evidence = changed), gtvu_evidence_args(environments, objects))
  ), "evidence, controls, or readiness")
})

test_that("Draft.85c4n keeps execution and public gates closed", {
  environments <- load_gtheory_multivariate_c4n()
  objects <- gtvu_objects(environments)
  evidence <- gtvu_evidence(environments, objects)
  ready <- c(
    "DefaultDenyProfileReady", "SanitizedEnvironmentReady",
    "ExactDigestRuntimeReady", "ThreeLaneFreshProcessReceiptsReady",
    "SyntheticProtectedVaultReadDenied", "RepositoryReadDenied",
    "OutsideWriteDenied", "ParentEnvironmentSecretAbsent",
    "UnlistedExecutableDenied", "ExternalNetworkDenied",
    "PayloadTruthBlindReady", "BackendQualificationReady",
    "PlannedAdapterProcessCapabilityIsolationReady",
    "ProcessCapabilityIsolationReady", "ExactlyZeroC3PrerequisitesTransitioned",
    "ExecutionGateClosed"
  )
  closed <- c(
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
  expect_true(all(vapply(ready, function(name) evidence[[name]], logical(1L))))
  expect_false(any(vapply(closed, function(name) evidence[[name]], logical(1L))))
  called <- FALSE
  callback <- function() {
    called <<- TRUE
    TRUE
  }
  expect_error(do.call(
    environments$controller$mfrmr_gtvu_dispatch_guard,
    c(list(
      evidence = evidence, action = "pilot", callback = callback,
      authorize = TRUE
    ), gtvu_evidence_args(environments, objects))
  ), "fit-capable truth-blind boundary")
  expect_false(called)
})

test_that("Draft.85c4n remains absent from public surfaces", {
  load_gtheory_multivariate_c4n()
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
  expect_false(any(grepl("Draft\\.85c4n|mfrmr_gtvu[w]?_", public_text)))
})
