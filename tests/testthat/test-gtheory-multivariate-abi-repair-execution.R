gtheory_multivariate_abi_repair_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-execution-admission-preflight-0.2.4.R",
      paste0(
        "gtheory-multivariate-backend-qualification-admission-",
        "preflight-0.2.4.R"
      ),
      "gtheory-multivariate-abi-repair-execution-0.2.4.R"
    )
  )
}

gtheory_multivariate_abi_repair_worker_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-multivariate-abi-repair-identity-worker-0.2.4.R"
  )
}

load_gtheory_multivariate_abi_repair <- local({
  environments <- NULL
  function() {
    paths <- gtheory_multivariate_abi_repair_paths()
    worker_path <- gtheory_multivariate_abi_repair_worker_path()
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

gtvp_repo_root <- function() {
  testthat::test_path("..", "..")
}

gtvp_validation_dir <- function() {
  dirname(gtheory_multivariate_abi_repair_worker_path())
}

skip_if_not_c4i_live <- function() {
  skip_if_not(
    identical(Sys.getenv("MFRMR_RUN_C4I_ABI_REPAIR"), "true"),
    "set MFRMR_RUN_C4I_ABI_REPAIR=true for retained repair evidence"
  )
  source_dir <- Sys.getenv("MFRMR_C4I_SOURCE_DIR", unset = "")
  skip_if_not(nzchar(source_dir) && dir.exists(source_dir),
              "set MFRMR_C4I_SOURCE_DIR to the pinned source directory")
}

gtvp_objects <- local({
  objects <- NULL
  function(environments) {
    if (is.null(objects)) {
      env <- environments$controller
      identity <- env$mfrmr_gtvl_environment_identity()
      c4e <- env$mfrmr_gtvl_manifest(gtvp_repo_root(), identity)
      objects <<- list(identity = identity, c4e = c4e)
    }
    objects
  }
})

gtvp_live_receipt <- local({
  receipt <- NULL
  function(environments) {
    skip_if_not_c4i_live()
    if (is.null(receipt)) {
      objects <- gtvp_objects(environments)
      receipt <<- environments$controller$mfrmr_gtvp_execute(
        Sys.getenv("MFRMR_C4I_SOURCE_DIR"),
        environments$worker,
        objects$c4e,
        repo_root = gtvp_repo_root(),
        validation_dir = gtvp_validation_dir(),
        authorize_repair = TRUE,
        allow_exact_reuse = TRUE
      )
    }
    receipt
  }
})

test_that("Draft.85c4i identity worker is an exact five-function file", {
  environments <- load_gtheory_multivariate_abi_repair()
  worker <- environments$worker
  expected <- c(
    "mfrmr_gtvpw_hash", "mfrmr_gtvpw_file_hash",
    "mfrmr_gtvpw_exact_object", "mfrmr_gtvpw_package_row",
    "mfrmr_gtvpw_main"
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
    "lme4::lmer|glmmTMB::glmmTMB|install.packages|download.file|ConQuest",
    function_text
  )))
})

test_that("Draft.85c4i pins the exact two CRAN source artifacts", {
  environments <- load_gtheory_multivariate_abi_repair()
  plan <- environments$controller$mfrmr_gtvp_source_plan()
  expect_identical(nrow(plan), 2L)
  expect_identical(plan$SourceOrdinal, 1:2)
  expect_identical(plan$Package, c("TMB", "glmmTMB"))
  expect_identical(plan$Version, c("1.9.25", "1.1.14"))
  expect_identical(plan$Repository, c("CRAN", "CRAN"))
  expect_true(all(grepl(
    "^https://cran[.]r-project[.]org/src/contrib/", plan$CanonicalURL
  )))
  expect_identical(plan$SHA256, c(
    "cf9663b29949cd5eaccb32e11900c9e07caec7d6ac4f17cfd938317dc33acff2",
    "623c81cfe4b3c6825db15d44781eccf7a357cf15b423fe9f00459f52beeffbbd"
  ))
})

test_that("Draft.85c4i detects the broken default Fortran configuration", {
  environments <- load_gtheory_multivariate_abi_repair()
  env <- environments$controller
  toolchain <- env$mfrmr_gtvp_toolchain_identity()
  expect_s3_class(toolchain, "mfrmr_gtvp_toolchain")
  expect_false(toolchain$DefaultRFortranToolchainReady)
  expect_true(toolchain$ToolchainOverrideRequired)
  expect_true(toolchain$ToolchainOverrideReady)
  expect_match(toolchain$DefaultFC, "^/opt/gfortran/bin/gfortran")
  expect_match(toolchain$DefaultFLIBS, "/opt/gfortran")
  expect_true(startsWith(
    toolchain$OverrideGFortran, "/opt/homebrew/Cellar/gcc/"
  ))
  expect_true(file.exists(toolchain$OverrideGFortran))
  expect_identical(nrow(toolchain$RuntimeRegistry), 4L)
  expect_true(all(file.exists(toolchain$RuntimeRegistry$Path)))
  expect_true(all(nchar(toolchain$RuntimeRegistry$SHA256) == 64L))
})

test_that("Draft.85c4i Makevars replaces only the broken Fortran linkage", {
  environments <- load_gtheory_multivariate_abi_repair()
  env <- environments$controller
  toolchain <- env$mfrmr_gtvp_toolchain_identity()
  makevars <- env$mfrmr_gtvp_makevars_text(toolchain)
  audit <- env$mfrmr_gtvp_toolchain_audit(toolchain, makevars)
  expect_identical(nrow(audit), 8L)
  expect_true(all(audit$Passed))
  expect_match(
    makevars, paste0("FC=", toolchain$OverrideGFortran), fixed = TRUE
  )
  expect_match(
    makevars, paste0("F77=", toolchain$OverrideGFortran), fixed = TRUE
  )
  expect_match(makevars, "-lemutls_w -lheapt_w -lgfortran -lquadmath",
               fixed = TRUE)
  expect_false(grepl("/opt/gfortran", makevars, fixed = TRUE))
})

test_that("Draft.85c4i repair requires explicit execution authority", {
  environments <- load_gtheory_multivariate_abi_repair()
  objects <- gtvp_objects(environments)
  expect_error(
    environments$controller$mfrmr_gtvp_execute(
      source_dir = "not-observed",
      worker_environment = environments$worker,
      c4e_manifest = objects$c4e,
      authorize_repair = FALSE
    ),
    "authorize_repair=TRUE"
  )
})

test_that("Draft.85c4i validates pinned sources and the retained receipt", {
  skip_if_not_c4i_live()
  environments <- load_gtheory_multivariate_abi_repair()
  env <- environments$controller
  objects <- gtvp_objects(environments)
  sources <- env$mfrmr_gtvp_source_registry(
    Sys.getenv("MFRMR_C4I_SOURCE_DIR")
  )
  receipt <- gtvp_live_receipt(environments)
  expect_identical(sources, receipt$SourceArtifactRegistry)
  expect_silent(env$mfrmr_gtvp_assert_receipt(
    receipt, environments$worker, objects$c4e, gtvp_repo_root()
  ))
  expect_s3_class(receipt, "mfrmr_gtvp_repair_receipt")
  expect_true(dir.exists(receipt$RepairRoot))
  expect_true(dir.exists(receipt$OverlayLibrary))
  expect_true(file.exists(file.path(
    receipt$RepairRoot, "repair-receipt.rds"
  )))
  expect_true(receipt$ArtifactRetained)
})

test_that("Draft.85c4i records both source builds and diagnostics", {
  environments <- load_gtheory_multivariate_abi_repair()
  receipt <- gtvp_live_receipt(environments)
  build <- receipt$BuildReceiptRegistry
  expect_identical(build$Package, c("TMB", "glmmTMB"))
  expect_identical(build$ExitStatus, c(0L, 0L))
  expect_identical(build$CompilerWarningCount, c(0L, 3L))
  expect_identical(build$WarningClass, c(
    "none", "rcppeigen_unused_but_set_only"
  ))
  expect_true(all(file.exists(build$LogPath)))
  expect_true(all(file.exists(build$InstalledDescriptionPath)))
  expect_true(all(file.exists(build$InstalledDLLPath)))
  expect_true(receipt$BuildDiagnosticsAdmissible)
  expect_false(receipt$SourceBuildWarningFree)
})

test_that("Draft.85c4i fresh process observes the repaired ABI", {
  environments <- load_gtheory_multivariate_abi_repair()
  receipt <- gtvp_live_receipt(environments)
  identity <- receipt$FreshProcessReceipt
  expect_s3_class(identity, "mfrmr_gtvp_identity_receipt")
  expect_identical(receipt$FreshProcessExitStatus, 0L)
  expect_identical(length(receipt$FreshProcessOutput), 0L)
  expect_identical(identity$LibraryOrder[[1L]], receipt$OverlayLibrary)
  expect_identical(
    identity$LoadedGlmmTMBBuildTMBVersion, identity$RuntimeTMBVersion
  )
  expect_identical(identity$RuntimeTMBVersion, "1.9.25")
  expect_identical(identity$GlmmTMBABIVersion, "2")
  expect_true(identity$OverlayLibraryOrderReady)
  expect_true(identity$DependencyABIMatch)
  expect_false(identity$FreshProcessClaimedByWorker)
  expect_false(identity$BackendExecutionOccurred)
  expect_identical(
    identity$PackageRegistry$Package,
    c("lme4", "glmmTMB", "TMB", "Matrix", "RcppEigen")
  )
  expect_true(all(startsWith(
    identity$PackageRegistry$PackagePath[2:3], receipt$OverlayLibrary
  )))
})

test_that("Draft.85c4i advances repair but blocks qualification dispatch", {
  environments <- load_gtheory_multivariate_abi_repair()
  env <- environments$controller
  objects <- gtvp_objects(environments)
  receipt <- gtvp_live_receipt(environments)
  ready <- c(
    "IsolatedLibraryCreated", "PackageSourcesPinned", "SelectedTMBInstalled",
    "GlmmTMBRebuiltAgainstSelectedTMB", "FreshProcessIdentityReobserved",
    "RepairExecuted", "RepairReceiptReady", "ToolchainOverrideReady",
    "BuildDiagnosticsAdmissible", "RepairedEnvironmentABIMatch",
    "RepairedEnvironmentReadyForBackendQualification", "ExecutionGateClosed"
  )
  closed <- c(
    "FourRouteReceiptsCompleted", "RepairProcessCapabilityIsolationReady",
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
  expect_true(all(vapply(ready, function(name) receipt[[name]], logical(1L))))
  expect_false(any(vapply(closed, function(name) receipt[[name]],
                          logical(1L))))
  state <- new.env(parent = emptyenv())
  state$calls <- 0L
  callback <- function(...) {
    state$calls <- state$calls + 1L
    "unreachable"
  }
  for (action in c("qualification_worker", "backend_fit", "receipt_trust")) {
    for (authorize in c(FALSE, TRUE)) {
      expect_error(env$mfrmr_gtvp_dispatch_guard(
        receipt, action, callback, authorize = authorize,
        worker_environment = environments$worker,
        c4e_manifest = objects$c4e, repo_root = gtvp_repo_root()
      ), "qualification remains closed")
    }
  }
  expect_identical(state$calls, 0L)
})

test_that("Draft.85c4i fails closed after mutation and stays internal", {
  environments <- load_gtheory_multivariate_abi_repair()
  env <- environments$controller
  objects <- gtvp_objects(environments)
  receipt <- gtvp_live_receipt(environments)

  changed <- receipt
  changed$BackendQualificationReady <- TRUE
  expect_error(env$mfrmr_gtvp_assert_receipt(
    changed, environments$worker, objects$c4e, gtvp_repo_root()
  ), "repair receipt or readiness")

  changed <- receipt
  changed$FreshProcessReceipt$LoadedGlmmTMBBuildTMBVersion <- "1.9.23"
  expect_error(env$mfrmr_gtvp_assert_receipt(
    changed, environments$worker, objects$c4e, gtvp_repo_root()
  ), "identity receipt or package identity")

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
  expect_false(any(grepl("Draft\\.85c4i|mfrmr_gtvp[w]?_", public_text)))
  expect_false(receipt$ConQuestRouteIncluded)
})
