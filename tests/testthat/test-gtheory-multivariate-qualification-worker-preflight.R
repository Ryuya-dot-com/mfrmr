gtheory_multivariate_qualification_worker_paths <- function() {
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
      "gtheory-multivariate-qualification-worker-preflight-0.2.4.R"
    )
  )
}

gtheory_multivariate_qualification_worker_file <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-multivariate-qualification-worker-0.2.4.R"
  )
}

load_gtheory_multivariate_qualification_worker <- local({
  environments <- NULL
  function() {
    paths <- gtheory_multivariate_qualification_worker_paths()
    worker_path <- gtheory_multivariate_qualification_worker_file()
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

gtvn_repo_root <- function() {
  testthat::test_path("..", "..")
}

gtvn_objects <- local({
  objects <- NULL
  function(environments) {
    if (is.null(objects)) {
      env <- environments$controller
      environment <- env$mfrmr_gtvl_environment_identity()
      c4e <- env$mfrmr_gtvl_manifest(gtvn_repo_root(), environment)
      protocol <- env$mfrmr_gtvm_manifest(gtvn_repo_root(), c4e)
      request <- env$mfrmr_gtvn_request(
        environments$worker, protocol, gtvn_repo_root()
      )
      evidence <- env$mfrmr_gtvn_process_preflight(
        environments$worker, protocol, gtvn_repo_root()
      )
      manifest <- env$mfrmr_gtvn_manifest(
        environments$worker, protocol, gtvn_repo_root(), evidence
      )
      objects <<- list(
        environment = environment, c4e = c4e, protocol = protocol,
        request = request, evidence = evidence, manifest = manifest
      )
    }
    objects
  }
})

test_that("Draft.85c4g worker is a seven-function refusal-only file", {
  environments <- load_gtheory_multivariate_qualification_worker()
  worker <- environments$worker
  expect_identical(parent.env(worker), baseenv())
  expect_identical(sort(ls(worker, all.names = TRUE)), sort(c(
    "mfrmr_gtvnw_hash", "mfrmr_gtvnw_exact_object", "mfrmr_gtvnw_sha256",
    "mfrmr_gtvnw_assert_request", "mfrmr_gtvnw_refusal_receipt",
    "mfrmr_gtvnw_assert_receipt", "mfrmr_gtvnw_main"
  )))
  expect_true(all(vapply(ls(worker, all.names = TRUE), function(name) {
    is.function(get(name, envir = worker, inherits = FALSE))
  }, logical(1L))))
  function_text <- vapply(ls(worker, all.names = TRUE), function(name) {
    paste(deparse(body(get(name, envir = worker))), collapse = "\n")
  }, character(1L))
  expect_false(any(grepl(
    "lme4::|glmmTMB::|install.packages|remotes::|pak::|system2\\(",
    function_text
  )))
})

test_that("Draft.85c4g inventories the exact future worker bundle", {
  environments <- load_gtheory_multivariate_qualification_worker()
  env <- environments$controller
  registry <- env$mfrmr_gtvn_bundle_registry(gtvn_repo_root())
  expect_identical(nrow(registry), 8L)
  expect_identical(registry$BundleOrdinal, 1:8)
  expect_identical(registry$Path, env$mfrmr_gtvn_bundle_paths())
  expect_identical(anyDuplicated(registry$Path), 0L)
  expect_identical(anyDuplicated(registry$Role), 0L)
  expect_true(all(registry$Bytes > 0))
  expect_true(all(nchar(registry$SHA256) == 64L))
  expect_identical(registry$Role[[8L]], "refusal_worker")
})

test_that("Draft.85c4g request contains hashes but no execution material", {
  environments <- load_gtheory_multivariate_qualification_worker()
  env <- environments$controller
  objects <- gtvn_objects(environments)
  request <- objects$request
  expect_silent(env$mfrmr_gtvn_assert_request(
    request, environments$worker, objects$protocol, gtvn_repo_root()
  ))
  expect_s3_class(request, "mfrmr_gtvn_request")
  expect_identical(request$Mode, "environment_refusal_preflight")
  expect_identical(request$RequiredRoutes, c(
    "lme4_ml", "lme4_reml", "glmmTMB_ml", "glmmTMB_reml"
  ))
  expect_false(request$EnvironmentReadyForBackendQualification)
  expect_false(request$BackendExecutionAuthorized)
  expect_false(request$PlannedSeedMaterialIncluded)
  expect_false(request$ConQuestRouteIncluded)
  expect_false(any(c(
    "Specification", "BackendData", "Score", "DataSeed", "FixtureSeed",
    "CandidateData", "TruthAudit"
  ) %in% names(request)))
})

test_that("Draft.85c4g worker rejects rehashed readiness mutation", {
  environments <- load_gtheory_multivariate_qualification_worker()
  env <- environments$controller
  objects <- gtvn_objects(environments)
  changed <- objects$request
  changed$EnvironmentReadyForBackendQualification <- TRUE
  payload_fields <- names(changed)[seq_len(match(
    "ConQuestRouteIncluded", names(changed)
  ))]
  changed$RequestHash <- env$mfrmr_gtvn_hash(changed[payload_fields])
  expect_error(
    environments$worker$mfrmr_gtvnw_assert_request(changed),
    "request or execution state was altered"
  )

  changed <- objects$request
  changed$BackendExecutionAuthorized <- TRUE
  changed$RequestHash <- env$mfrmr_gtvn_hash(changed[payload_fields])
  expect_error(
    environments$worker$mfrmr_gtvnw_assert_request(changed),
    "request or execution state was altered"
  )
})

test_that("Draft.85c4g direct receipt remains a typed non-attempt", {
  environments <- load_gtheory_multivariate_qualification_worker()
  objects <- gtvn_objects(environments)
  receipt <- environments$worker$mfrmr_gtvnw_refusal_receipt(objects$request)
  expect_silent(environments$worker$mfrmr_gtvnw_assert_receipt(
    receipt, objects$request
  ))
  expect_s3_class(receipt, "mfrmr_gtvn_refusal_receipt")
  expect_identical(
    receipt$Disposition, "environment_not_ready_no_backend_attempt"
  )
  expect_false(receipt$FullB1ObjectsReceived)
  expect_false(receipt$BackendAttempted)
  expect_false(receipt$DiagnosticOverrideUsed)
  expect_false(receipt$TrustedReceiptProduced)
  expect_true(receipt$RefusalReceiptReady)
  expect_false(receipt$FreshProcessClaimedByWorker)
  expect_false(receipt$QualificationEvidenceReady)
  expect_false(receipt$BackendQualificationReady)
  expect_false(receipt$ExecutionAuthorized)
})

test_that("Draft.85c4g observes refusal in a fresh R process", {
  environments <- load_gtheory_multivariate_qualification_worker()
  env <- environments$controller
  objects <- gtvn_objects(environments)
  evidence <- objects$evidence
  expect_silent(env$mfrmr_gtvn_assert_process_evidence(
    evidence, environments$worker, objects$protocol, gtvn_repo_root()
  ))
  expect_s3_class(evidence, "mfrmr_gtvn_process_evidence")
  expect_identical(evidence$WorkerExitStatus, 0L)
  expect_identical(length(evidence$WorkerOutput), 0L)
  expect_true(evidence$RefusalOnlyWorkerReady)
  expect_true(evidence$FreshProcessRefusalObserved)
  expect_false(evidence$ProcessCapabilityIsolationReady)
  expect_false(evidence$QualificationWorkerImplemented)
  expect_false(evidence$FullB1ObjectsReceived)
  expect_false(evidence$BackendExecutionOccurred)
  expect_false(evidence$TrustedReceiptProduced)
  expect_false(evidence$QualificationEvidenceReady)
  expect_false(evidence$BackendQualificationReady)
})

test_that("Draft.85c4g manifest distinguishes refusal worker from qualification", {
  environments <- load_gtheory_multivariate_qualification_worker()
  env <- environments$controller
  objects <- gtvn_objects(environments)
  manifest <- objects$manifest
  expect_silent(env$mfrmr_gtvn_assert_manifest(
    manifest, environments$worker, objects$protocol, gtvn_repo_root()
  ))
  expect_s3_class(manifest, "mfrmr_gtvn_manifest")
  expect_identical(
    manifest$ProtocolManifestHash,
    "89044060c10c55321e61d2214fc85484aca30c4eafc413f67fc26f00edc6d1fb"
  )
  expect_identical(
    manifest$BundleRegistryHash,
    "897579b6991f354d459725e64758edc011e1baf7f6ebbbcf1256f4a0c67911da"
  )
  expect_identical(
    manifest$Request$WorkerSourceSHA256,
    "a13ef63611a1e96048de3fd5a4b59bf4dddc53d225c6cd3f5808c65876a21daa"
  )
  expect_true(manifest$WorkerBundleRegistryReady)
  expect_true(manifest$RequestSchemaReady)
  expect_true(manifest$RefusalOnlyWorkerReady)
  expect_true(manifest$FreshProcessRefusalObserved)
  expect_false(manifest$EnvironmentReadyForBackendQualification)
  expect_true(manifest$RepairRequired)
  expect_false(manifest$ProcessCapabilityIsolationReady)
  expect_false(manifest$QualificationWorkerImplemented)
  expect_false(manifest$RouteReceiptsMaterialized)
  expect_false(manifest$PairReceiptsMaterialized)
  expect_false(manifest$TrustedReceiptProduced)
  expect_false(manifest$QualificationEvidenceReady)
  expect_false(manifest$BackendQualificationReady)
  expect_true(manifest$ExecutionGateClosed)
})

test_that("Draft.85c4g rejects evidence and manifest promotion", {
  environments <- load_gtheory_multivariate_qualification_worker()
  env <- environments$controller
  objects <- gtvn_objects(environments)
  changed <- objects$evidence
  changed$QualificationWorkerImplemented <- TRUE
  expect_error(env$mfrmr_gtvn_assert_process_evidence(
    changed, environments$worker, objects$protocol, gtvn_repo_root()
  ), "process evidence or readiness was altered")

  changed <- objects$manifest
  changed$BackendQualificationReady <- TRUE
  expect_error(env$mfrmr_gtvn_assert_manifest(
    changed, environments$worker, objects$protocol, gtvn_repo_root()
  ), "worker manifest or readiness was altered")
})

test_that("Draft.85c4g blocks qualification, fit, and trust callbacks", {
  environments <- load_gtheory_multivariate_qualification_worker()
  env <- environments$controller
  objects <- gtvn_objects(environments)
  state <- new.env(parent = emptyenv())
  state$calls <- 0L
  callback <- function(...) {
    state$calls <- state$calls + 1L
    "unreachable"
  }
  for (action in c("qualification_worker", "backend_fit", "receipt_trust")) {
    for (authorize in c(FALSE, TRUE)) {
      expect_error(env$mfrmr_gtvn_dispatch_guard(
        objects$manifest, action, callback, authorize = authorize,
        worker_environment = environments$worker,
        protocol_manifest = objects$protocol, repo_root = gtvn_repo_root()
      ), "only a refusal worker")
    }
  }
  expect_error(env$mfrmr_gtvn_dispatch_guard(
    objects$manifest, "ConQuest", callback, authorize = TRUE,
    worker_environment = environments$worker,
    protocol_manifest = objects$protocol, repo_root = gtvn_repo_root()
  ), "outside the worker preflight")
  expect_identical(state$calls, 0L)
})

test_that("Draft.85c4g remains internal and estimator-free", {
  environments <- load_gtheory_multivariate_qualification_worker()
  env <- environments$controller
  manifest <- gtvn_objects(environments)$manifest
  closed <- c(
    "PilotExecutionAuthorized", "ConfirmationExecutionAuthorized",
    "NegativeControlExecutionAuthorized", "BackendExecutionOccurred",
    "PlannedResponseGenerated", "RecoveryExecuted", "RecoveryEvidenceReady",
    "EstimationReady", "InferenceReady", "DecisionReady",
    "PublicSupportReady"
  )
  expect_false(any(vapply(closed, function(name) manifest[[name]],
                          logical(1L))))
  function_text <- vapply(
    manifest$ImplementationIdentity$Function,
    function(name) paste(
      deparse(body(get(name, envir = env))), collapse = "\n"
    ), character(1L)
  )
  expect_false(any(grepl(
    "install.packages|remotes::|pak::|glmmTMB::glmmTMB|lme4::lmer",
    function_text
  )))

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
  expect_false(any(grepl("Draft\\.85c4g|mfrmr_gtvn", public_text)))
})
