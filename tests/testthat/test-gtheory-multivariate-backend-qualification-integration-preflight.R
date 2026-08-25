gtheory_multivariate_backend_integration_paths <- function() {
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
      )
    )
  )
}

gtheory_multivariate_backend_integration_worker_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-multivariate-abi-repair-identity-worker-0.2.4.R",
      "gtheory-multivariate-full-object-qualification-worker-0.2.4.R",
      "gtheory-multivariate-full-object-capability-worker-0.2.4.R"
    )
  )
}

load_gtheory_multivariate_backend_integration <- local({
  environments <- NULL
  function() {
    paths <- gtheory_multivariate_backend_integration_paths()
    workers <- gtheory_multivariate_backend_integration_worker_paths()
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

gtvs_repo_root <- function() testthat::test_path("..", "..")

gtvs_validation_dir <- function() {
  dirname(gtheory_multivariate_backend_integration_worker_paths()[[1L]])
}

skip_if_not_c4l_evidence <- function() {
  skip_if_not(identical(Sys.info()[["sysname"]], "Darwin"),
              "Draft.85c4l consumes macOS c4k evidence")
  skip_if_not(
    identical(Sys.getenv("MFRMR_RUN_C4L_INTEGRATION"), "true"),
    "set MFRMR_RUN_C4L_INTEGRATION=true for retained integration evidence"
  )
  paths <- Sys.getenv(c(
    "MFRMR_C4I_RECEIPT", "MFRMR_C4J_RECEIPT", "MFRMR_C4K_EVIDENCE"
  ), unset = "")
  skip_if_not(all(nzchar(paths) & file.exists(paths)),
              "set retained c4i, c4j, and c4k evidence paths")
}

gtvs_objects <- local({
  objects <- NULL
  function(environments) {
    skip_if_not_c4l_evidence()
    if (is.null(objects)) {
      env <- environments$controller
      plan <- env$mfrmr_gtvd_plan()
      generator <- env$mfrmr_gtve_manifest(plan)
      c3_environment <- env$mfrmr_gtvf_environment_snapshot()
      c3 <- env$mfrmr_gtvf_manifest(plan, generator, c3_environment)
      c4e_environment <- env$mfrmr_gtvl_environment_identity()
      c4e <- env$mfrmr_gtvl_manifest(gtvs_repo_root(), c4e_environment)
      c4f <- env$mfrmr_gtvm_manifest(gtvs_repo_root(), c4e)
      objects <<- list(
        plan = plan, generator = generator, c3_environment = c3_environment,
        c3 = c3, c4e_environment = c4e_environment, c4e = c4e, c4f = c4f,
        repair = readRDS(Sys.getenv("MFRMR_C4I_RECEIPT")),
        qualification = readRDS(Sys.getenv("MFRMR_C4J_RECEIPT")),
        capability = readRDS(Sys.getenv("MFRMR_C4K_EVIDENCE"))
      )
    }
    objects
  }
})

gtvs_receipt_args <- function(environments, objects) {
  list(
    c3_manifest = objects$c3, c4e_manifest = objects$c4e,
    c4f_manifest = objects$c4f, repair_receipt = objects$repair,
    qualification_receipt = objects$qualification,
    capability_evidence = objects$capability,
    repair_worker_environment = environments$repair_worker,
    qualification_worker_environment = environments$qualification_worker,
    capability_worker_environment = environments$capability_worker,
    repo_root = gtvs_repo_root(), validation_dir = gtvs_validation_dir()
  )
}

gtvs_receipt <- local({
  receipt <- NULL
  function(environments, objects) {
    if (is.null(receipt)) {
      receipt <<- do.call(
        environments$controller$mfrmr_gtvs_integration_receipt,
        gtvs_receipt_args(environments, objects)
      )
    }
    receipt
  }
})

test_that("Draft.85c4l has an exact thirteen-function identity", {
  environments <- load_gtheory_multivariate_backend_integration()
  identity <- environments$controller$mfrmr_gtvs_implementation_identity()
  expect_identical(nrow(identity), 13L)
  expect_identical(anyDuplicated(identity$Function), 0L)
  expect_true(all(grepl("^mfrmr_gtvs_", identity$Function)))
  expect_true(all(grepl("^[0-9a-f]{64}$", identity$SHA256)))
})

test_that("Draft.85c4l revalidates the entire c3-to-c4k parent chain", {
  environments <- load_gtheory_multivariate_backend_integration()
  objects <- gtvs_objects(environments)
  receipt <- gtvs_receipt(environments, objects)
  expect_silent(do.call(
    environments$controller$mfrmr_gtvs_assert_receipt,
    c(list(receipt = receipt), gtvs_receipt_args(environments, objects))
  ))
  expect_s3_class(receipt, "mfrmr_gtvs_receipt")
  expect_identical(receipt$C3ManifestHash, objects$c3$ManifestHash)
  expect_identical(receipt$C4EManifestHash, objects$c4e$ManifestHash)
  expect_identical(receipt$C4IRepairReceiptHash, objects$repair$ReceiptHash)
  expect_identical(
    receipt$C4JQualificationReceiptHash, objects$qualification$ReceiptHash
  )
  expect_identical(receipt$C4KEvidenceHash, objects$capability$EvidenceHash)
})

test_that("Draft.85c4l completes exactly the six c4e repair rows", {
  environments <- load_gtheory_multivariate_backend_integration()
  objects <- gtvs_objects(environments)
  receipt <- gtvs_receipt(environments, objects)
  registry <- receipt$RepairCompletionRegistry
  expect_identical(nrow(registry), 6L)
  expect_identical(registry$StepId, objects$c4e$RepairPlan$StepId)
  expect_true(all(registry$EvidenceReady))
  expect_false(any(registry$OriginalLibraryMutated))
  expect_true(all(grepl("^[0-9a-f]{64}$", registry$EvidenceHash)))
  expect_true(receipt$RepairPlanCompleted)
})

test_that("Draft.85c4l fills four trusted route receipts without drift", {
  environments <- load_gtheory_multivariate_backend_integration()
  objects <- gtvs_objects(environments)
  receipt <- gtvs_receipt(environments, objects)
  routes <- receipt$QualificationRouteRegistry
  expect_identical(nrow(routes), 4L)
  expect_identical(
    routes$RouteId, c("lme4_ml", "lme4_reml", "glmmTMB_ml", "glmmTMB_reml")
  )
  expect_identical(
    routes$TrustedQualificationReceiptHash,
    objects$capability$TrustedRouteRegistry$RevalidatedRouteReceiptHash
  )
  expect_identical(
    routes$SandboxFitObjectHash,
    objects$capability$TrustedRouteRegistry$SandboxFitObjectHash
  )
  expect_identical(
    routes$SemanticModelHash,
    vapply(
      objects$qualification$RouteReceipts,
      function(route) route$SemanticModelHash, character(1L), USE.NAMES = FALSE
    )
  )
  expect_true(all(routes$FreshProcess))
  expect_true(all(routes$DependencyABIMatch))
  expect_false(any(routes$DiagnosticOverrideUsed))
  expect_true(all(routes$FullB1ObjectRevalidated))
  expect_true(all(routes$ProcessCapabilityIsolationReady))
  expect_true(all(routes$ReceiptReady))
})

test_that("Draft.85c4l retains both trusted matched-pair receipts", {
  environments <- load_gtheory_multivariate_backend_integration()
  objects <- gtvs_objects(environments)
  receipt <- gtvs_receipt(environments, objects)
  pairs <- receipt$QualifiedPairRegistry
  expect_identical(nrow(pairs), 2L)
  expect_identical(pairs$PairId, c("matched_ml", "matched_reml"))
  expect_identical(
    pairs$TrustedPairReceiptHash,
    objects$capability$TrustedPairRegistry$RevalidatedPairReceiptHash
  )
  expect_identical(
    pairs$SandboxParityObjectHash,
    objects$capability$TrustedPairRegistry$SandboxParityObjectHash
  )
  expect_true(all(pairs$NumericalParityPassed))
  expect_true(all(pairs$BothPointGatesPassed))
  expect_true(all(pairs$BackendDependencyIdentityPassed))
  expect_true(all(pairs$ExactSpecificationMatch))
  expect_true(all(pairs$ExactSemanticModelMatch))
  expect_identical(
    pairs$MaximumCovarianceAbsoluteDifference,
    vapply(
      objects$qualification$PairReceipts,
      function(pair) pair$MaximumCovarianceAbsoluteDifference,
      numeric(1L), USE.NAMES = FALSE
    )
  )
  expect_identical(
    pairs$LogLikAbsoluteDifference,
    vapply(
      objects$qualification$PairReceipts,
      function(pair) pair$LogLikAbsoluteDifference,
      numeric(1L), USE.NAMES = FALSE
    )
  )
  expect_true(all(pairs$PairReady))
})

test_that("Draft.85c4l transitions exactly one c3 prerequisite", {
  environments <- load_gtheory_multivariate_backend_integration()
  objects <- gtvs_objects(environments)
  receipt <- gtvs_receipt(environments, objects)
  audit <- receipt$PrerequisiteProjection
  changed <- audit$TransitionedByIntegration
  expect_identical(sum(changed), 1L)
  expect_identical(
    audit$PrerequisiteId[changed], "all_four_matched_backends_qualified"
  )
  expect_false(audit$PriorSatisfied[changed])
  expect_true(audit$ProjectedSatisfied[changed])
  expect_identical(sum(audit$PriorSatisfied), 1L)
  expect_identical(sum(audit$ProjectedSatisfied), 2L)
  expect_true(audit$ProjectedSatisfied[
    audit$PrerequisiteId == "no_diagnostic_override"
  ])
  expect_false(any(audit$PartialExecutionAllowed))
})

test_that("Draft.85c4l opens backend admission but no study lane", {
  environments <- load_gtheory_multivariate_backend_integration()
  objects <- gtvs_objects(environments)
  receipt <- gtvs_receipt(environments, objects)
  ready <- c(
    "HistoricalC3ManifestPreserved", "HistoricalC4EManifestPreserved",
    "RepairPlanCompleted", "AllRouteReceiptsReady", "AllPairReceiptsReady",
    "BackendQualificationAdmissionReady", "BackendQualificationReady",
    "ExactlyOneC3PrerequisiteTransitioned", "IntegrationReceiptReady",
    "QualificationBackendExecutionObserved", "ExecutionGateClosed"
  )
  closed <- c(
    "AllExecutionPrerequisitesReady", "StudyOperationallyAdmissible",
    "DiagnosticOverrideAllowed", "PilotExecutionAuthorized",
    "ConfirmationExecutionAuthorized", "NegativeControlExecutionAuthorized",
    "PlannedStudyBackendExecutionOccurred", "PlannedResponseGenerated",
    "RecoveryExecuted", "RecoveryEvidenceReady", "EstimationReady",
    "InferenceReady", "DecisionReady", "PublicSupportReady"
  )
  expect_true(all(vapply(ready, function(name) receipt[[name]], logical(1L))))
  expect_false(any(vapply(closed, function(name) receipt[[name]], logical(1L))))
  expect_identical(receipt$C3SatisfiedPrerequisiteCount, 2L)
  expect_false(receipt$HistoricalObjectsMutated)
  expect_false(receipt$PlannedSeedMaterialIncluded)
  expect_false(receipt$ReferenceTruthIncluded)
  expect_false(receipt$ConQuestRouteIncluded)
})

test_that("Draft.85c4l receipt is deterministic and hash complete", {
  environments <- load_gtheory_multivariate_backend_integration()
  objects <- gtvs_objects(environments)
  receipt <- gtvs_receipt(environments, objects)
  env <- environments$controller
  expect_identical(
    receipt$ReceiptHash,
    env$mfrmr_gtvs_hash(receipt[env$mfrmr_gtvs_payload_fields()])
  )
  expect_identical(
    receipt$RepairCompletionRegistryHash,
    env$mfrmr_gtvs_hash(receipt$RepairCompletionRegistry)
  )
  expect_identical(
    receipt$QualificationRouteRegistryHash,
    env$mfrmr_gtvs_hash(receipt$QualificationRouteRegistry)
  )
  expect_identical(
    receipt$QualifiedPairRegistryHash,
    env$mfrmr_gtvs_hash(receipt$QualifiedPairRegistry)
  )
  expect_identical(
    receipt$PrerequisiteProjectionHash,
    env$mfrmr_gtvs_hash(receipt$PrerequisiteProjection)
  )
})

test_that("Draft.85c4l rejects a rehashed readiness escalation", {
  environments <- load_gtheory_multivariate_backend_integration()
  objects <- gtvs_objects(environments)
  receipt <- gtvs_receipt(environments, objects)
  changed <- receipt
  changed$PrerequisiteProjection$ProjectedSatisfied[[1L]] <- TRUE
  changed$PrerequisiteProjectionHash <- environments$controller$mfrmr_gtvs_hash(
    changed$PrerequisiteProjection
  )
  changed$ReceiptHash <- environments$controller$mfrmr_gtvs_hash(
    changed[environments$controller$mfrmr_gtvs_payload_fields()]
  )
  expect_error(do.call(
    environments$controller$mfrmr_gtvs_assert_receipt,
    c(list(receipt = changed), gtvs_receipt_args(environments, objects))
  ), "integration receipt or readiness")
})

test_that("Draft.85c4l keeps dispatch and public package surfaces closed", {
  environments <- load_gtheory_multivariate_backend_integration()
  objects <- gtvs_objects(environments)
  receipt <- gtvs_receipt(environments, objects)
  called <- FALSE
  callback <- function() {
    called <<- TRUE
    TRUE
  }
  expect_error(do.call(
    environments$controller$mfrmr_gtvs_dispatch_guard,
    c(list(
      receipt = receipt, action = "pilot", callback = callback,
      authorize = TRUE
    ), gtvs_receipt_args(environments, objects))
  ), "all planned study, recovery, decision, and public dispatch remains closed")
  expect_false(called)
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
  expect_false(any(grepl("Draft\\.85c4l|mfrmr_gtvs_", public_text)))
})
