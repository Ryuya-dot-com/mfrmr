gtheory_multivariate_isolation_integration_paths <- function() {
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
      "gtheory-multivariate-candidate-receipt-preflight-0.2.4.R",
      "gtheory-multivariate-capability-isolation-preflight-0.2.4.R",
      "gtheory-multivariate-isolation-integration-preflight-0.2.4.R"
    )
  )
}

gtheory_multivariate_isolation_integration_worker_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-multivariate-candidate-receipt-worker-0.2.4.R",
      "gtheory-multivariate-capability-worker-0.2.4.R"
    )
  )
}

load_gtheory_multivariate_isolation_integration <- local({
  environments <- NULL
  function() {
    paths <- gtheory_multivariate_isolation_integration_paths()
    worker_paths <- gtheory_multivariate_isolation_integration_worker_paths()
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
        controller = controller,
        candidate_worker = candidate_worker,
        capability_worker = capability_worker
      )
    }
    environments
  }
})

skip_if_not_c4c_macos <- function() {
  skip_if_not(identical(Sys.info()[["sysname"]], "Darwin"),
              "Draft.85c4c isolation integration is macOS-specific")
}

skip_if_not_c4c_live <- function() {
  skip_if_not_c4c_macos()
  skip_if_not(
    identical(Sys.getenv("MFRMR_RUN_C4B_MACOS_SANDBOX"), "true"),
    "set MFRMR_RUN_C4B_MACOS_SANDBOX=true for live c4b/c4c evidence"
  )
}

gtvj_static_objects <- local({
  objects <- NULL
  function(environments) {
    if (is.null(objects)) {
      env <- environments$controller
      plan <- env$mfrmr_gtvd_plan()
      generator <- env$mfrmr_gtve_manifest(plan)
      environment <- env$mfrmr_gtvf_environment_snapshot()
      c3 <- env$mfrmr_gtvf_manifest(plan, generator, environment)
      c4a <- env$mfrmr_gtvg_manifest(
        environments$candidate_worker, plan, generator
      )
      objects <<- list(
        plan = plan, generator = generator, environment = environment,
        c3 = c3, c4a = c4a
      )
    }
    objects
  }
})

gtvj_live_objects <- local({
  objects <- NULL
  function(environments) {
    skip_if_not_c4c_live()
    if (is.null(objects)) {
      env <- environments$controller
      static <- gtvj_static_objects(environments)
      validation_dir <- dirname(
        gtheory_multivariate_isolation_integration_worker_paths()[[1L]]
      )
      c4b <- env$mfrmr_gtvh_live_preflight(
        environments$candidate_worker,
        validation_dir = validation_dir,
        authorize_live_sandbox = TRUE,
        keep_staging = FALSE,
        plan = static$plan,
        generator_manifest = static$generator
      )
      receipt <- env$mfrmr_gtvj_isolation_receipt(
        environments$candidate_worker, c4b, static$plan, static$generator,
        static$environment, static$c3, static$c4a
      )
      manifest <- env$mfrmr_gtvj_manifest(
        environments$candidate_worker, c4b, static$plan, static$generator,
        static$environment, static$c3, static$c4a
      )
      objects <<- c(static, list(
        c4b = c4b, receipt = receipt, manifest = manifest
      ))
    }
    objects
  }
})

test_that("Draft.85c4c has a closed internal implementation identity", {
  environments <- load_gtheory_multivariate_isolation_integration()
  env <- environments$controller
  identity <- env$mfrmr_gtvj_implementation_identity()
  expect_identical(nrow(identity), 12L)
  expect_identical(anyDuplicated(identity$Function), 0L)
  expect_true(all(nchar(identity$SHA256) == 64L))
  expect_true(all(grepl("^mfrmr_gtvj_", identity$Function)))
})

test_that("Draft.85c4c preserves the historical c3 and c4a states", {
  environments <- load_gtheory_multivariate_isolation_integration()
  objects <- gtvj_static_objects(environments)
  expect_false(objects$c3$TruthBlindProcessBoundaryReady)
  expect_true(objects$c3$ExecutionGateClosed)
  expect_true(all(is.na(unlist(objects$c3$IsolationTemplate[c(
    "CandidateCanReadScenarioIdentity", "CandidateCanReadDataSeed",
    "CandidateCanReadReferenceIdentity", "CandidateCanReadTruth",
    "CandidateCanReadAccuracyThreshold"
  )], use.names = FALSE))))
  expect_false(objects$c4a$TruthBlindProcessBoundaryReady)
  expect_false(objects$c4a$ProcessCapabilityIsolationReady)
  expect_false(objects$c4a$BackendExecutionOccurred)
})

test_that("Draft.85c4c rejects a missing live capability receipt", {
  skip_if_not_c4c_macos()
  environments <- load_gtheory_multivariate_isolation_integration()
  env <- environments$controller
  objects <- gtvj_static_objects(environments)
  expect_error(env$mfrmr_gtvj_isolation_receipt(
    environments$candidate_worker, NULL, objects$plan, objects$generator,
    objects$environment, objects$c3, objects$c4a
  ), "typed Draft.85c4b live evidence")
})

test_that("Draft.85c4c answers all five c3 access questions for the fixture", {
  environments <- load_gtheory_multivariate_isolation_integration()
  objects <- gtvj_live_objects(environments)
  access <- objects$receipt$AccessQuestionRegistry
  expect_identical(access$QuestionOrdinal, 1:5)
  expect_identical(access$QuestionId, c(
    "scenario_identity", "data_seed", "reference_identity", "truth",
    "accuracy_threshold"
  ))
  expect_identical(access$C3Field, c(
    "CandidateCanReadScenarioIdentity", "CandidateCanReadDataSeed",
    "CandidateCanReadReferenceIdentity", "CandidateCanReadTruth",
    "CandidateCanReadAccuracyThreshold"
  ))
  expect_identical(access$FixtureMaterialPresent,
                   c(TRUE, TRUE, TRUE, TRUE, FALSE))
  expect_false(any(access$PlannedMaterialPresent))
  expect_true(all(access$EvidenceControlPassed))
  expect_false(any(access$CandidateCanRead))
  expect_true(all(access$PlannedExecutionRecheckRequired))
})

test_that("Draft.85c4c binds executor, schemas, and both vault identities", {
  environments <- load_gtheory_multivariate_isolation_integration()
  env <- environments$controller
  objects <- gtvj_live_objects(environments)
  receipt <- objects$receipt
  expect_silent(env$mfrmr_gtvj_assert_isolation_receipt(
    receipt, environments$candidate_worker, objects$c4b, objects$plan,
    objects$generator, objects$environment, objects$c3, objects$c4a
  ))
  expect_s3_class(receipt, "mfrmr_gtvj_isolation_receipt")
  expect_identical(receipt$ReferenceVaultSHA256,
                   objects$c4b$ReferenceVaultHash)
  expect_identical(receipt$RegistryReferenceVaultSHA256,
                   objects$c4a$ReferenceVaultHash)
  expect_identical(
    receipt$CandidateExecutorSHA256,
    env$mfrmr_gta_hash(receipt$CandidateExecutorComponents)
  )
  expect_identical(
    receipt$CandidateInputSchemaSHA256,
    env$mfrmr_gta_hash(receipt$CandidateInputSchema)
  )
  expect_identical(
    receipt$CandidateReceiptSchemaSHA256,
    env$mfrmr_gta_hash(receipt$CandidateReceiptSchema)
  )
  expect_match(receipt$IsolationAuditId, "^C4C-[0-9a-f]{24}$")
})

test_that("Draft.85c4c separates fixture isolation from planned readiness", {
  environments <- load_gtheory_multivariate_isolation_integration()
  env <- environments$controller
  objects <- gtvj_live_objects(environments)
  receipt <- objects$receipt
  manifest <- objects$manifest
  expect_silent(env$mfrmr_gtvj_assert_manifest(
    manifest, environments$candidate_worker, objects$c4b, objects$plan,
    objects$generator, objects$environment, objects$c3, objects$c4a
  ))
  expect_true(receipt$FixtureAccessQuestionsReady)
  expect_true(receipt$ProcessCapabilityIsolationReady)
  expect_true(receipt$FixtureTruthBlindProcessBoundaryReady)
  expect_false(receipt$PlannedExecutionIsolationReady)
  expect_false(receipt$ConfirmationThresholdMaterialized)
  expect_true(receipt$ConfirmationIsolationRecheckRequired)
  expect_true(manifest$C3IsolationQuestionIntegrationReady)
  expect_true(manifest$ProcessCapabilityIsolationReady)
  expect_true(manifest$FixtureTruthBlindProcessBoundaryReady)
  expect_false(manifest$TruthBlindProcessBoundaryReady)
  expect_false(manifest$PlannedExecutionIsolationReady)
  expect_true(manifest$ConfirmationIsolationRecheckRequired)
  expect_false(manifest$CandidateCompletionSealed)
  expect_false(manifest$TruthReleaseAuthorized)
  expect_false(manifest$PlannedSeedMaterialIncluded)
  expect_true(manifest$ExecutionGateClosed)
})

test_that("Draft.85c4c records fixture evidence without satisfying c3", {
  environments <- load_gtheory_multivariate_isolation_integration()
  objects <- gtvj_live_objects(environments)
  audit <- objects$manifest$PrerequisiteAudit
  row <- match("truth_blind_process_boundary", audit$PrerequisiteId)
  expect_identical(nrow(audit), 8L)
  expect_false(audit$CurrentSatisfied[[row]])
  expect_true(audit$FixtureEvidenceAvailable[[row]])
  expect_identical(which(audit$CurrentSatisfied), 8L)
  expect_identical(which(audit$FixtureEvidenceAvailable), row)
  expect_identical(
    audit$EvidenceState[[row]],
    "fixture_only_runtime_bound_isolation_requires_planned_successor"
  )
  expect_false(objects$manifest$C3HistoricalManifestModified)
  expect_identical(
    objects$manifest$HistoricalC3ManifestHash, objects$c3$ManifestHash
  )
})

test_that("Draft.85c4c rejects rehashed vault, receipt, and manifest changes", {
  environments <- load_gtheory_multivariate_isolation_integration()
  env <- environments$controller
  objects <- gtvj_live_objects(environments)

  changed_evidence <- objects$c4b
  changed_evidence$ReferenceVaultHash <- paste(rep("0", 64L), collapse = "")
  changed_evidence$EvidenceHash <- env$mfrmr_gta_hash(
    changed_evidence[env$mfrmr_gtvh_live_payload_fields()]
  )
  expect_error(env$mfrmr_gtvj_isolation_receipt(
    environments$candidate_worker, changed_evidence, objects$plan,
    objects$generator, objects$environment, objects$c3, objects$c4a
  ), "live evidence, controls, or readiness")

  changed_receipt <- objects$receipt
  changed_receipt$AccessQuestionRegistry$CandidateCanRead[[1L]] <- TRUE
  changed_receipt$AccessQuestionRegistryHash <- env$mfrmr_gta_hash(
    changed_receipt$AccessQuestionRegistry
  )
  expect_error(env$mfrmr_gtvj_assert_isolation_receipt(
    changed_receipt, environments$candidate_worker, objects$c4b,
    objects$plan, objects$generator, objects$environment, objects$c3,
    objects$c4a
  ), "isolation receipt or readiness")

  changed_manifest <- objects$manifest
  changed_manifest$PilotExecutionAuthorized <- TRUE
  expect_error(env$mfrmr_gtvj_assert_manifest(
    changed_manifest, environments$candidate_worker, objects$c4b,
    objects$plan, objects$generator, objects$environment, objects$c3,
    objects$c4a
  ), "integration manifest or readiness")
})

test_that("Draft.85c4c dispatch remains unreachable", {
  environments <- load_gtheory_multivariate_isolation_integration()
  env <- environments$controller
  objects <- gtvj_live_objects(environments)
  state <- new.env(parent = emptyenv())
  state$calls <- 0L
  callback <- function(...) {
    state$calls <- state$calls + 1L
    "unreachable"
  }
  for (authorize in c(FALSE, TRUE)) {
    expect_error(env$mfrmr_gtvj_dispatch_guard(
      objects$manifest, environments$candidate_worker, objects$c4b, callback,
      authorize = authorize, plan = objects$plan,
      generator_manifest = objects$generator,
      environment_snapshot = objects$environment,
      c3_manifest = objects$c3, c4a_manifest = objects$c4a
    ), "execution remains closed")
  }
  expect_identical(state$calls, 0L)
})

test_that("Draft.85c4c remains internal and opens no planned material", {
  environments <- load_gtheory_multivariate_isolation_integration()
  env <- environments$controller
  function_text <- vapply(
    env$mfrmr_gtvj_implementation_identity()$Function,
    function(name) paste(deparse(body(get(name, envir = env))), collapse = "\n"),
    character(1L)
  )
  expect_false(any(grepl("lme4::|glmmTMB::|ConQuest", function_text)))

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
  expect_false(any(grepl("Draft\\.85c4c|mfrmr_gtvj_", public_text)))
})
