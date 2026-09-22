gtheory_multivariate_full_qualification_paths <- function() {
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
      "gtheory-multivariate-full-object-qualification-execution-0.2.4.R"
    )
  )
}

gtheory_multivariate_full_qualification_worker_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-multivariate-full-object-qualification-worker-0.2.4.R"
  )
}

gtheory_multivariate_abi_identity_worker_path_c4j <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-multivariate-abi-repair-identity-worker-0.2.4.R"
  )
}

load_gtheory_multivariate_full_qualification <- local({
  environments <- NULL
  function() {
    paths <- gtheory_multivariate_full_qualification_paths()
    qualification_worker <-
      gtheory_multivariate_full_qualification_worker_path()
    repair_worker <- gtheory_multivariate_abi_identity_worker_path_c4j()
    skip_if_not(all(file.exists(c(paths, qualification_worker, repair_worker))),
                "repository-internal validation artifacts are excluded")
    skip_if_not_installed("digest")
    if (is.null(environments)) {
      controller <- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = controller)
      repair_worker_environment <- new.env(parent = baseenv())
      sys.source(repair_worker, envir = repair_worker_environment)
      qualification_worker_environment <- new.env(parent = baseenv())
      sys.source(qualification_worker,
                 envir = qualification_worker_environment)
      environments <<- list(
        controller = controller,
        repair_worker = repair_worker_environment,
        qualification_worker = qualification_worker_environment
      )
    }
    environments
  }
})

gtvq_repo_root <- function() testthat::test_path("..", "..")

gtvq_validation_dir <- function() {
  dirname(gtheory_multivariate_full_qualification_worker_path())
}

skip_if_not_c4j_live <- function() {
  skip_if_not(
    identical(Sys.getenv("MFRMR_RUN_C4J_FULL_QUALIFICATION"), "true"),
    "set MFRMR_RUN_C4J_FULL_QUALIFICATION=true for retained evidence"
  )
  path <- Sys.getenv("MFRMR_C4I_RECEIPT", unset = "")
  skip_if_not(nzchar(path) && file.exists(path),
              "set MFRMR_C4I_RECEIPT to the retained repair receipt")
}

gtvq_objects <- local({
  objects <- NULL
  function(environments) {
    skip_if_not_c4j_live()
    if (is.null(objects)) {
      env <- environments$controller
      identity <- env$mfrmr_gtvl_environment_identity()
      c4e <- env$mfrmr_gtvl_manifest(gtvq_repo_root(), identity)
      c4f <- env$mfrmr_gtvm_manifest(gtvq_repo_root(), c4e)
      repair <- readRDS(Sys.getenv("MFRMR_C4I_RECEIPT"))
      objects <<- list(identity = identity, c4e = c4e, c4f = c4f,
                      repair = repair)
    }
    objects
  }
})

gtvq_live_receipt <- local({
  receipt <- NULL
  function(environments) {
    objects <- gtvq_objects(environments)
    if (is.null(receipt)) {
      receipt <<- environments$controller$mfrmr_gtvq_execute(
        objects$repair, environments$repair_worker, objects$c4e, objects$c4f,
        environments$qualification_worker,
        repo_root = gtvq_repo_root(),
        validation_dir = gtvq_validation_dir(),
        authorize_qualification = TRUE,
        allow_exact_reuse = TRUE
      )
    }
    receipt
  }
})

test_that("Draft.85c4j worker has an exact fifteen-function namespace", {
  environments <- load_gtheory_multivariate_full_qualification()
  worker <- environments$qualification_worker
  identity <- environments$controller$mfrmr_gtvq_worker_identity(worker)
  expect_identical(parent.env(worker), baseenv())
  expect_identical(nrow(identity), 15L)
  expect_identical(anyDuplicated(identity$Function), 0L)
  expect_true(all(grepl("^mfrmr_gtvqw_", identity$Function)))
  expect_true(all(grepl("^[0-9a-f]{64}$", identity$SHA256)))
  worker_text <- paste(readLines(
    gtheory_multivariate_full_qualification_worker_path(), warn = FALSE
  ), collapse = "\n")
  expect_false(grepl("allow_dependency_mismatch_diagnostic\\s*=\\s*TRUE",
                     worker_text))
})

test_that("Draft.85c4j controller has a distinct nineteen-function identity", {
  environments <- load_gtheory_multivariate_full_qualification()
  identity <- environments$controller$mfrmr_gtvq_implementation_identity()
  expect_identical(nrow(identity), 19L)
  expect_identical(anyDuplicated(identity$Function), 0L)
  expect_true(all(grepl("^mfrmr_gtvq_", identity$Function)))
  expect_true(all(grepl("^[0-9a-f]{64}$", identity$SHA256)))
})

test_that("Draft.85c4j requires explicit qualification authority", {
  environments <- load_gtheory_multivariate_full_qualification()
  objects <- gtvq_objects(environments)
  expect_error(
    environments$controller$mfrmr_gtvq_execute(
      objects$repair, environments$repair_worker, objects$c4e, objects$c4f,
      environments$qualification_worker,
      repo_root = gtvq_repo_root(),
      validation_dir = gtvq_validation_dir()
    ),
    "authorize_qualification=TRUE"
  )
})

test_that("Draft.85c4j binds the repaired environment and frozen policy", {
  environments <- load_gtheory_multivariate_full_qualification()
  objects <- gtvq_objects(environments)
  receipt <- gtvq_live_receipt(environments)
  expect_silent(environments$controller$mfrmr_gtvq_assert_receipt(
    receipt, objects$repair, environments$repair_worker, objects$c4e,
    objects$c4f, environments$qualification_worker,
    gtvq_repo_root(), gtvq_validation_dir()
  ))
  expect_identical(receipt$C4IRepairReceiptHash,
                   objects$repair$ReceiptHash)
  expect_identical(receipt$C4FManifestHash, objects$c4f$ManifestHash)
  expect_identical(receipt$C4FPolicyHash,
                   objects$c4f$QualificationPolicyHash)
  expect_identical(receipt$FreshProcessReceipt$PackageRegistry,
                   objects$repair$FreshProcessReceipt$PackageRegistry)
  expect_identical(
    receipt$FreshProcessReceipt$ProcessIdentity$LibraryOrder[[1L]],
    objects$repair$OverlayLibrary
  )
  expect_true(receipt$FreshProcessReceipt$LoadedNamespaceClosureCaptured)
  expect_true(all(c(
    "lme4", "glmmTMB", "TMB", "Matrix", "RcppEigen"
  ) %in% receipt$FreshProcessReceipt$LoadedNamespaceRegistry$Package))
  expect_true(all(file.exists(
    receipt$FreshProcessReceipt$LoadedNativeBinaryRegistry$NativeBinaryPath
  )))
})

test_that("Draft.85c4j receives and revalidates all six complete objects", {
  environments <- load_gtheory_multivariate_full_qualification()
  receipt <- gtvq_live_receipt(environments)
  worker <- receipt$FreshProcessReceipt
  expect_identical(names(worker$FullFitObjects), c(
    "lme4_ml", "lme4_reml", "glmmTMB_ml", "glmmTMB_reml"
  ))
  expect_identical(names(worker$FullParityObjects),
                   c("matched_ml", "matched_reml"))
  for (fit in worker$FullFitObjects) {
    expect_silent(environments$controller$mfrmr_gtvb_assert_fit_integrity(fit))
  }
  expect_true(receipt$FullB1FitObjectsReceived)
  expect_true(receipt$FullB1ParityObjectsReceived)
  expect_true(receipt$FullB1ObjectsRevalidated)
  expect_true(receipt$RouteReceiptsMaterialized)
  expect_true(receipt$PairReceiptsMaterialized)
  expect_true(receipt$AllRouteRevalidatedReceiptsReady)
  expect_true(receipt$AllPairRevalidatedReceiptsReady)
})

test_that("Draft.85c4j passes all four routes without diagnostic override", {
  environments <- load_gtheory_multivariate_full_qualification()
  routes <- gtvq_live_receipt(environments)$FreshProcessReceipt$
    RouteObjectRegistry
  expect_identical(routes$RouteId, c(
    "lme4_ml", "lme4_reml", "glmmTMB_ml", "glmmTMB_reml"
  ))
  expect_true(all(routes$FitIntegrityPassed))
  expect_true(all(routes$PointEstimationGatePassed))
  expect_true(all(routes$BackendRowsMatch))
  expect_true(all(routes$DependencyABIMatch))
  expect_false(any(routes$DiagnosticOverrideUsed))
  expect_identical(routes$WarningCount, rep(0L, 4L))
  expect_identical(routes$FitStatus,
                   rep("identified_point_fit", 4L))
  expect_identical(length(unique(routes$SpecificationHash)), 1L)
})

test_that("Draft.85c4j passes both frozen combined-tolerance comparisons", {
  environments <- load_gtheory_multivariate_full_qualification()
  pairs <- gtvq_live_receipt(environments)$FreshProcessReceipt$
    PairObjectRegistry
  expect_identical(pairs$PairId, c("matched_ml", "matched_reml"))
  expect_true(all(pairs$NumericalParityPassed))
  expect_true(all(pairs$BothPointGatesPassed))
  expect_true(all(pairs$BackendDependencyIdentityPassed))
  expect_true(all(pairs$ExactSpecificationMatch))
  expect_true(all(pairs$ExactSemanticModelMatch))
  expect_lt(max(pairs$MaximumCovarianceAbsoluteDifference), 1e-4)
  expect_lt(max(pairs$MaximumFixedAbsoluteDifference), 1e-4)
  expect_lt(max(pairs$LogLikAbsoluteDifference), 1e-5)
})

test_that("Draft.85c4j separates numerical evidence from process trust", {
  environments <- load_gtheory_multivariate_full_qualification()
  receipt <- gtvq_live_receipt(environments)
  ready <- c(
    "QualificationWorkerImplemented", "FreshProcessQualificationExecuted",
    "FreshProcessVerified", "FreshProcessOutputEmpty",
    "BackendQualificationNumericallyReady",
    "CandidateQualificationEvidenceReady", "ExecutionGateClosed",
    "BackendExecutionOccurred"
  )
  closed <- c(
    "ProcessCapabilityIsolationAssessed", "ProcessCapabilityIsolationReady",
    "TrustedReceiptProduced", "QualificationEvidenceReady",
    "BackendQualificationReady", "OperationallyAdmissible",
    "DiagnosticOverrideAllowed", "PlannedResponseGenerated",
    "RecoveryExecuted", "RecoveryEvidenceReady", "EstimationReady",
    "InferenceReady", "DecisionReady", "PublicSupportReady"
  )
  expect_true(all(vapply(ready, function(name) receipt[[name]], logical(1L))))
  expect_false(any(vapply(closed, function(name) receipt[[name]],
                          logical(1L))))
  expect_false(receipt$FreshProcessReceipt$FreshProcessClaimedByWorker)
  expect_true(receipt$FreshProcessReceipt$WorkerSelfReported)
  expect_false(receipt$ConQuestRouteIncluded)
})

test_that("Draft.85c4j exact reuse preserves the sealed receipt", {
  environments <- load_gtheory_multivariate_full_qualification()
  objects <- gtvq_objects(environments)
  receipt <- gtvq_live_receipt(environments)
  reused <- environments$controller$mfrmr_gtvq_execute(
    objects$repair, environments$repair_worker, objects$c4e, objects$c4f,
    environments$qualification_worker,
    repo_root = gtvq_repo_root(), validation_dir = gtvq_validation_dir(),
    authorize_qualification = TRUE, allow_exact_reuse = TRUE
  )
  expect_identical(reused, receipt)
  expect_identical(reused$ReceiptHash, receipt$ReceiptHash)
})

test_that("Draft.85c4j rejects full-object and receipt tampering", {
  environments <- load_gtheory_multivariate_full_qualification()
  objects <- gtvq_objects(environments)
  receipt <- gtvq_live_receipt(environments)
  arguments <- list(
    repair_receipt = objects$repair,
    repair_worker_environment = environments$repair_worker,
    c4e_manifest = objects$c4e,
    c4f_manifest = objects$c4f,
    worker_environment = environments$qualification_worker,
    repo_root = gtvq_repo_root(),
    validation_dir = gtvq_validation_dir()
  )

  changed <- receipt
  changed$FreshProcessReceipt$FullFitObjects$lme4_ml$InferenceReady <- TRUE
  expect_error(do.call(
    environments$controller$mfrmr_gtvq_assert_receipt,
    c(list(receipt = changed), arguments)
  ), "identity|internally inconsistent|full objects")

  changed <- receipt
  changed$RouteReceipts$lme4_ml$TrustedReceiptReady <- TRUE
  expect_error(do.call(
    environments$controller$mfrmr_gtvq_assert_receipt,
    c(list(receipt = changed), arguments)
  ), "route receipt|readiness")

  changed <- receipt
  changed$ProcessCapabilityIsolationReady <- TRUE
  expect_error(do.call(
    environments$controller$mfrmr_gtvq_assert_receipt,
    c(list(receipt = changed), arguments)
  ), "readiness")
})

test_that("Draft.85c4j keeps capability and promotion dispatch closed", {
  environments <- load_gtheory_multivariate_full_qualification()
  objects <- gtvq_objects(environments)
  receipt <- gtvq_live_receipt(environments)
  called <- FALSE
  callback <- function() {
    called <<- TRUE
    TRUE
  }
  for (action in c(
    "capability_isolation", "receipt_trust", "operational_promotion"
  )) {
    expect_error(environments$controller$mfrmr_gtvq_dispatch_guard(
      receipt, action, callback, authorize = TRUE,
      repair_receipt = objects$repair,
      repair_worker_environment = environments$repair_worker,
      c4e_manifest = objects$c4e, c4f_manifest = objects$c4f,
      worker_environment = environments$qualification_worker,
      repo_root = gtvq_repo_root(), validation_dir = gtvq_validation_dir()
    ), "capability-isolation evidence")
  }
  expect_false(called)
})
