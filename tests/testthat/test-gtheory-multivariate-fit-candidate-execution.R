gtheory_multivariate_c4p_paths <- function() {
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
      "gtheory-multivariate-fit-candidate-envelope-preflight-0.2.4.R",
      "gtheory-multivariate-fit-candidate-execution-0.2.4.R"
    )
  )
}

gtheory_multivariate_c4p_worker_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-multivariate-fit-candidate-worker-0.2.4.R"
  )
}

load_gtheory_multivariate_c4p <- local({
  environments <- NULL
  function() {
    paths <- gtheory_multivariate_c4p_paths()
    worker_path <- gtheory_multivariate_c4p_worker_path()
    skip_if_not(all(file.exists(c(paths, worker_path))),
                "repository-internal validation artifacts are excluded")
    skip_if_not_installed("digest")
    if (is.null(environments)) {
      controller <- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = controller)
      worker <- new.env(parent = baseenv())
      sys.source(worker_path, envir = worker)
      environments <<- list(controller = controller, worker = worker)
    }
    environments
  }
})

skip_if_not_c4p_evidence <- function() {
  skip_if_not(
    identical(Sys.getenv("MFRMR_RUN_C4P_FIT"), "true"),
    "set MFRMR_RUN_C4P_FIT=true for the nonreserved four-route fit"
  )
  paths <- Sys.getenv(c(
    "MFRMR_C4I_RECEIPT", "MFRMR_C4L_RECEIPT", "MFRMR_C4O_MANIFEST"
  ), unset = "")
  skip_if_not(all(nzchar(paths) & file.exists(paths)),
              "set retained c4i, c4l, and revised c4o evidence paths")
}

gtvw_validation_dir <- function() {
  dirname(gtheory_multivariate_c4p_worker_path())
}

gtvw_objects <- local({
  objects <- NULL
  function(environments) {
    skip_if_not_c4p_evidence()
    if (is.null(objects)) {
      env <- environments$controller
      plan <- env$mfrmr_gtvd_plan()
      objects <<- list(
        plan = plan, generator = env$mfrmr_gtve_manifest(plan),
        repair = readRDS(Sys.getenv("MFRMR_C4I_RECEIPT")),
        integration = readRDS(Sys.getenv("MFRMR_C4L_RECEIPT")),
        envelope = readRDS(Sys.getenv("MFRMR_C4O_MANIFEST"))
      )
    }
    objects
  }
})

gtvw_manifest <- local({
  manifest <- NULL
  function(environments, objects) {
    if (is.null(manifest)) {
      manifest <<- environments$controller$mfrmr_gtvw_manifest(
        objects$plan, objects$generator, objects$envelope,
        objects$integration, objects$repair, environments$worker,
        gtvw_validation_dir(), allow_exact_reuse = TRUE
      )
      path <- Sys.getenv("MFRMR_C4P_MANIFEST_PATH", unset = "")
      if (nzchar(path)) saveRDS(manifest, path, version = 3L)
    }
    manifest
  }
})

test_that("Draft.85c4p worker and controller namespaces are exact", {
  environments <- load_gtheory_multivariate_c4p()
  worker <- environments$controller$mfrmr_gtvw_worker_identity(
    environments$worker
  )
  controller <- environments$controller$mfrmr_gtvw_implementation_identity()
  expect_identical(parent.env(environments$worker), baseenv())
  expect_identical(nrow(worker), 12L)
  expect_identical(nrow(controller), 15L)
  expect_identical(anyDuplicated(worker$Function), 0L)
  expect_identical(anyDuplicated(controller$Function), 0L)
  expect_true(all(grepl("^[0-9a-f]{64}$", worker$SHA256)))
  expect_true(all(grepl("^[0-9a-f]{64}$", controller$SHA256)))
})

test_that("Draft.85c4p consumes the revised observation-link c4o contract", {
  environments <- load_gtheory_multivariate_c4p()
  objects <- gtvw_objects(environments)
  expect_true(objects$envelope$CandidateDataObservationLinkSchemaReady)
  expect_true(objects$envelope$ObservationLinkPairIdentityReady)
  expect_true(objects$envelope$RawWithinCellReplicateRemoved)
  expect_false(objects$envelope$FitCapableWorkerImplemented)
  expect_identical(objects$envelope$C4LReceiptHash,
                   objects$integration$ReceiptHash)
  expect_identical(objects$integration$C4IRepairReceiptHash,
                   objects$repair$ReceiptHash)
})

test_that("Draft.85c4p executes all four qualified routes", {
  environments <- load_gtheory_multivariate_c4p()
  objects <- gtvw_objects(environments)
  manifest <- gtvw_manifest(environments, objects)
  environments$controller$mfrmr_gtvw_assert_manifest(manifest)
  routes <- manifest$RouteExecutionRegistry
  expect_s3_class(manifest, "mfrmr_gtvw_manifest")
  expect_identical(routes$MethodId, c(
    "lme4_reml", "glmmtmb_reml", "lme4_ml", "glmmtmb_ml"
  ))
  expect_identical(routes$QualificationRouteId, c(
    "lme4_reml", "glmmTMB_reml", "lme4_ml", "glmmTMB_ml"
  ))
  expect_true(all(routes$Attempted))
  expect_true(all(routes$BackendInvoked))
  expect_true(all(routes$FitReturned))
  expect_true(all(routes$PointEstimationGatePassed))
  expect_true(all(routes$FitStatus == "identified_point_fit"))
})

test_that("Draft.85c4p extracts the complete c1 coordinate layout", {
  environments <- load_gtheory_multivariate_c4p()
  objects <- gtvw_objects(environments)
  manifest <- gtvw_manifest(environments, objects)
  coordinates <- manifest$CoordinateEstimateRegistry
  expect_identical(nrow(coordinates), 40L)
  counts <- table(coordinates$MethodId)
  expect_identical(as.integer(counts), rep(10L, 4L))
  expect_identical(names(counts), c(
    "glmmtmb_ml", "glmmtmb_reml", "lme4_ml", "lme4_reml"
  ))
  expected_ids <- objects$plan$CoordinateLayouts$CoordinateId[
    objects$plan$CoordinateLayouts$CoordinateLayoutId == "T2-GLOBAL-3C-R1"
  ]
  for (method in objects$plan$MethodRegistry$MethodId) {
    expect_identical(
      coordinates$CoordinateId[coordinates$MethodId == method], expected_ids
    )
  }
  expect_true(all(is.finite(coordinates$Estimate)))
})

test_that("Draft.85c4p preserves backend parity in distinct fresh processes", {
  environments <- load_gtheory_multivariate_c4p()
  objects <- gtvw_objects(environments)
  manifest <- gtvw_manifest(environments, objects)
  parity <- manifest$BackendParityRegistry
  process <- manifest$ProcessRegistry
  expect_identical(parity$PairId, c("matched_reml", "matched_ml"))
  expect_true(all(parity$NumericalParityPassed))
  expect_true(all(parity$BothPointEstimationGatesPassed))
  expect_true(all(parity$MatchedBackendPointReady))
  expect_identical(nrow(process), 4L)
  expect_identical(anyDuplicated(process$ProcessId), 0L)
  expect_true(all(process$ProcessId != Sys.getpid()))
  expect_true(all(process$ExitStatus == 0L))
})

test_that("Draft.85c4p manifest is hash complete and fail closed", {
  environments <- load_gtheory_multivariate_c4p()
  objects <- gtvw_objects(environments)
  manifest <- gtvw_manifest(environments, objects)
  env <- environments$controller
  expect_identical(
    manifest$ManifestHash,
    env$mfrmr_gtvw_hash(manifest[env$mfrmr_gtvw_payload_fields()])
  )
  changed <- manifest
  changed$TruthBlindProcessBoundaryReady <- TRUE
  expect_error(env$mfrmr_gtvw_assert_manifest(changed),
               "manifest or readiness was altered")
  changed_hash <- manifest
  changed_hash$RouteExecutionRegistry$FitReturned[[1L]] <- FALSE
  changed_hash$RouteExecutionRegistryHash <- env$mfrmr_gtvw_hash(
    changed_hash$RouteExecutionRegistry
  )
  changed_hash$ManifestHash <- env$mfrmr_gtvw_hash(
    changed_hash[env$mfrmr_gtvw_payload_fields()]
  )
  expect_error(env$mfrmr_gtvw_assert_manifest(changed_hash),
               "manifest or readiness was altered")
})

test_that("Draft.85c4p keeps c3, planned, recovery, and public gates closed", {
  environments <- load_gtheory_multivariate_c4p()
  objects <- gtvw_objects(environments)
  manifest <- gtvw_manifest(environments, objects)
  audit <- manifest$PrerequisiteProjection
  truth <- audit$PrerequisiteId == "truth_blind_process_boundary"
  expect_false(any(audit$TransitionedByC4P))
  expect_identical(sum(audit$C4PProjectedSatisfied), 2L)
  expect_true(audit$FitCapableWorkerEvidenceAvailable[truth])
  expect_false(audit$FitCapableProcessIsolationEvidenceAvailable[truth])
  expect_false(manifest$TruthBlindProcessBoundaryReady)
  expect_false(manifest$PlannedExecutionOccurred)
  expect_false(manifest$RecoveryEvidenceReady)
  expect_false(manifest$PublicSupportReady)
  called <- FALSE
  callback <- function() { called <<- TRUE; TRUE }
  expect_error(env <- environments$controller$mfrmr_gtvw_dispatch_guard(
    manifest, "pilot", callback, authorize = TRUE
  ), "nonreserved fit execution only")
  expect_false(called)
})

test_that("Draft.85c4p remains absent from public surfaces", {
  public_text <- unlist(lapply(c(
    list.files(testthat::test_path("..", "..", "R"), recursive = TRUE,
               full.names = TRUE),
    list.files(testthat::test_path("..", "..", "man"), recursive = TRUE,
               full.names = TRUE),
    list.files(testthat::test_path("..", "..", "vignettes"), recursive = TRUE,
               full.names = TRUE),
    testthat::test_path("..", "..", "NEWS.md"),
    testthat::test_path("..", "..", "ROADMAP.md")
  ), function(path) {
    if (file.exists(path) && !dir.exists(path) &&
        grepl("\\.(R|Rd|Rmd|md)$", path)) {
      readLines(path, warn = FALSE, encoding = "UTF-8")
    } else character()
  }), use.names = FALSE)
  expect_false(any(grepl("Draft\\.85c4p|mfrmr_gtvw[w]?_", public_text)))
})
