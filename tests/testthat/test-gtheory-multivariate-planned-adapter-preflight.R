gtheory_multivariate_planned_adapter_paths <- function() {
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
      "gtheory-multivariate-planned-adapter-preflight-0.2.4.R"
    )
  )
}

gtheory_multivariate_planned_adapter_worker_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-multivariate-abi-repair-identity-worker-0.2.4.R",
      "gtheory-multivariate-full-object-qualification-worker-0.2.4.R",
      "gtheory-multivariate-full-object-capability-worker-0.2.4.R",
      "gtheory-multivariate-planned-adapter-worker-0.2.4.R"
    )
  )
}

load_gtheory_multivariate_planned_adapter <- local({
  environments <- NULL
  function() {
    paths <- gtheory_multivariate_planned_adapter_paths()
    workers <- gtheory_multivariate_planned_adapter_worker_paths()
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
      environments <<- list(
        controller = controller, repair_worker = repair_worker,
        qualification_worker = qualification_worker,
        capability_worker = capability_worker,
        adapter_worker = adapter_worker
      )
    }
    environments
  }
})

gtvt_repo_root <- function() testthat::test_path("..", "..")

gtvt_validation_dir <- function() {
  dirname(gtheory_multivariate_planned_adapter_worker_paths()[[1L]])
}

skip_if_not_c4m_evidence <- function() {
  skip_if_not(identical(Sys.info()[["sysname"]], "Darwin"),
              "Draft.85c4m consumes macOS c4k/c4l evidence")
  skip_if_not(
    identical(Sys.getenv("MFRMR_RUN_C4M_ADAPTER"), "true"),
    "set MFRMR_RUN_C4M_ADAPTER=true for retained adapter evidence"
  )
  paths <- Sys.getenv(c(
    "MFRMR_C4I_RECEIPT", "MFRMR_C4J_RECEIPT", "MFRMR_C4K_EVIDENCE",
    "MFRMR_C4L_RECEIPT"
  ), unset = "")
  skip_if_not(all(nzchar(paths) & file.exists(paths)),
              "set retained c4i through c4l evidence paths")
}

gtvt_objects <- local({
  objects <- NULL
  function(environments) {
    skip_if_not_c4m_evidence()
    if (is.null(objects)) {
      env <- environments$controller
      plan <- env$mfrmr_gtvd_plan()
      generator <- env$mfrmr_gtve_manifest(plan)
      c3 <- env$mfrmr_gtvf_manifest(
        plan, generator, env$mfrmr_gtvf_environment_snapshot()
      )
      c4e_environment <- env$mfrmr_gtvl_environment_identity()
      c4e <- env$mfrmr_gtvl_manifest(gtvt_repo_root(), c4e_environment)
      c4f <- env$mfrmr_gtvm_manifest(gtvt_repo_root(), c4e)
      objects <<- list(
        plan = plan, generator = generator, c3 = c3,
        c4e_environment = c4e_environment, c4e = c4e, c4f = c4f,
        repair = readRDS(Sys.getenv("MFRMR_C4I_RECEIPT")),
        qualification = readRDS(Sys.getenv("MFRMR_C4J_RECEIPT")),
        capability = readRDS(Sys.getenv("MFRMR_C4K_EVIDENCE")),
        integration = readRDS(Sys.getenv("MFRMR_C4L_RECEIPT"))
      )
    }
    objects
  }
})

gtvt_manifest_args <- function(environments, objects) {
  list(
    plan = objects$plan, generator_manifest = objects$generator,
    c3_manifest = objects$c3, c4e_manifest = objects$c4e,
    c4f_manifest = objects$c4f, repair_receipt = objects$repair,
    qualification_receipt = objects$qualification,
    capability_evidence = objects$capability,
    c4l_receipt = objects$integration,
    repair_worker_environment = environments$repair_worker,
    qualification_worker_environment = environments$qualification_worker,
    capability_worker_environment = environments$capability_worker,
    adapter_worker_environment = environments$adapter_worker,
    repo_root = gtvt_repo_root(), validation_dir = gtvt_validation_dir()
  )
}

gtvt_manifest <- local({
  manifest <- NULL
  function(environments, objects) {
    if (is.null(manifest)) {
      manifest <<- do.call(
        environments$controller$mfrmr_gtvt_manifest,
        gtvt_manifest_args(environments, objects)
      )
    }
    manifest
  }
})

test_that("Draft.85c4m worker has an exact four-function namespace", {
  environments <- load_gtheory_multivariate_planned_adapter()
  env <- environments$controller
  identity <- env$mfrmr_gtvt_worker_identity(environments$adapter_worker)
  audit <- env$mfrmr_gtvt_worker_static_audit(environments$adapter_worker)
  expect_identical(parent.env(environments$adapter_worker), baseenv())
  expect_identical(nrow(identity), 4L)
  expect_identical(anyDuplicated(identity$Function), 0L)
  expect_true(all(grepl("^mfrmr_gtvtw_", identity$Function)))
  expect_true(all(grepl("^[0-9a-f]{64}$", identity$SHA256)))
  expect_identical(nrow(audit), 11L)
  expect_false(any(audit$Present))
  expect_true(all(audit$Passed))
})

test_that("Draft.85c4m controller has a distinct twenty-one-function identity", {
  environments <- load_gtheory_multivariate_planned_adapter()
  identity <- environments$controller$mfrmr_gtvt_implementation_identity()
  expect_identical(nrow(identity), 21L)
  expect_identical(anyDuplicated(identity$Function), 0L)
  expect_true(all(grepl("^mfrmr_gtvt_", identity$Function)))
  expect_true(all(grepl("^[0-9a-f]{64}$", identity$SHA256)))
})

test_that("Draft.85c4m revalidates c1/c2 and the complete c4l lineage", {
  environments <- load_gtheory_multivariate_planned_adapter()
  objects <- gtvt_objects(environments)
  manifest <- gtvt_manifest(environments, objects)
  expect_silent(do.call(
    environments$controller$mfrmr_gtvt_assert_manifest,
    c(list(manifest = manifest), gtvt_manifest_args(environments, objects))
  ))
  expect_s3_class(manifest, "mfrmr_gtvt_manifest")
  expect_identical(manifest$PlanHash, objects$plan$PlanHash)
  expect_identical(
    manifest$GeneratorManifestHash, objects$generator$ManifestHash
  )
  expect_identical(manifest$C3ManifestHash, objects$c3$ManifestHash)
  expect_identical(
    manifest$C4LReceiptHash, objects$integration$ReceiptHash
  )
  expect_identical(
    manifest$WorkerSourceSHA256,
    environments$controller$mfrmr_gtvt_file_hash(
      gtheory_multivariate_planned_adapter_worker_paths()[[4L]]
    )
  )
})

test_that("Draft.85c4m preserves all three opaque c1 lane denominators", {
  environments <- load_gtheory_multivariate_planned_adapter()
  objects <- gtvt_objects(environments)
  manifest <- gtvt_manifest(environments, objects)
  lanes <- manifest$LaneAdapterRegistry
  expect_identical(nrow(lanes), 3L)
  expect_identical(
    lanes$StageId, c("pilot", "confirmation", "negative_control")
  )
  expect_identical(lanes$LaneOpaqueId, objects$plan$StageCatalog$LaneOpaqueId)
  expect_identical(lanes$ExpectedUnits, c(960L, 19200L, 8L))
  expect_identical(lanes$ObservedUnits, lanes$ExpectedUnits)
  expect_true(all(grepl("^C4M-[0-9a-f]{24}$", lanes$OpaqueRequestId)))
  expect_true(all(grepl("^[0-9a-f]{64}$", lanes$RequestHash)))
  expect_true(all(grepl("^[0-9a-f]{64}$", lanes$ReceiptHash)))
  expect_false(any(lanes$StageIdVisibleToWorker))
  expect_true(all(lanes$AdapterReceiptReady))
})

test_that("Draft.85c4m request schema contains only c1 opaque topology", {
  environments <- load_gtheory_multivariate_planned_adapter()
  objects <- gtvt_objects(environments)
  manifest <- gtvt_manifest(environments, objects)
  schema <- manifest$RequestSchema
  expect_identical(
    schema$CandidateUnitSchema$Names,
    c(
      "OpaqueUnitId", "OpaqueDatasetId", "MethodId", "MethodControlHash",
      "CoordinateLayoutId", "CoordinateCount"
    )
  )
  forbidden <- c(
    "StageId", "ScenarioId", "ScenarioOrdinal", "OpaqueScenarioToken",
    "Replicate", "DataSeed", "AssignmentId", "ReferenceId",
    "ExpectedPreFitState", "TruthValue", "RecoveryThreshold"
  )
  request_names <- c(
    schema$PayloadFields, schema$SuffixFields,
    schema$CandidateUnitSchema$Names
  )
  expect_false(any(forbidden %in% request_names))
  expect_identical(
    manifest$RequestSchemaHash,
    environments$controller$mfrmr_gtvt_hash(schema)
  )
  expect_false(manifest$RequestObjectsRetained)
  expect_true(manifest$PlannedUnitTopologyIncluded)
  expect_false(manifest$CandidateDataIncluded)
})

test_that("Draft.85c4m receipts are typed non-attempt transport", {
  environments <- load_gtheory_multivariate_planned_adapter()
  objects <- gtvt_objects(environments)
  manifest <- gtvt_manifest(environments, objects)
  lanes <- manifest$LaneAdapterRegistry
  expect_true(all(lanes$AdapterRequestAccepted))
  expect_false(any(lanes$Attempted))
  expect_false(any(lanes$CandidateDataReceived))
  expect_false(any(lanes$BackendInvoked))
  expect_identical(
    manifest$ReceiptSchema$Contract,
    "gtheory_multivariate_planned_adapter_receipt_draft85c4m_v1"
  )
  expect_true(manifest$RefusalTransportExercised)
  expect_false(manifest$AdapterBackendExecutionOccurred)
  expect_false(manifest$CandidateExecutionOccurred)
})

test_that("Draft.85c4m answers all five payload-access questions narrowly", {
  environments <- load_gtheory_multivariate_planned_adapter()
  objects <- gtvt_objects(environments)
  access <- gtvt_manifest(environments, objects)$AccessQuestionRegistry
  expect_identical(
    access$QuestionId,
    c(
      "scenario_identity", "data_seed", "reference_identity", "truth",
      "accuracy_threshold"
    )
  )
  expect_false(any(access$ForbiddenFieldPresent))
  expect_true(all(access$CanonicalC1HandoffProjection))
  expect_false(any(access$ProtectedMaterialPresent))
  expect_false(any(access$CandidateCanRead))
  expect_true(all(access$ProcessCapabilityRecheckRequired))
})

test_that("Draft.85c4m does not transition the c3 process prerequisite", {
  environments <- load_gtheory_multivariate_planned_adapter()
  objects <- gtvt_objects(environments)
  manifest <- gtvt_manifest(environments, objects)
  audit <- manifest$PrerequisiteProjection
  truth <- audit$PrerequisiteId == "truth_blind_process_boundary"
  expect_false(any(audit$TransitionedByC4M))
  expect_identical(sum(audit$C4MProjectedSatisfied), 2L)
  expect_false(audit$C4MProjectedSatisfied[truth])
  expect_true(audit$AdapterSchemaEvidenceAvailable[truth])
  expect_false(audit$ProcessCapabilityEvidenceAvailable[truth])
  expect_false(any(audit$PartialExecutionAllowed))
  expect_true(manifest$ExactlyZeroC3PrerequisitesTransitioned)
  expect_identical(manifest$C3SatisfiedPrerequisiteCount, 2L)
})

test_that("Draft.85c4m is hash complete and rejects rehashed promotion", {
  environments <- load_gtheory_multivariate_planned_adapter()
  objects <- gtvt_objects(environments)
  manifest <- gtvt_manifest(environments, objects)
  env <- environments$controller
  expect_identical(
    manifest$ManifestHash,
    env$mfrmr_gtvt_hash(manifest[env$mfrmr_gtvt_payload_fields()])
  )
  expect_identical(
    manifest$LaneAdapterRegistryHash,
    env$mfrmr_gtvt_hash(manifest$LaneAdapterRegistry)
  )
  expect_identical(
    manifest$AccessQuestionRegistryHash,
    env$mfrmr_gtvt_hash(manifest$AccessQuestionRegistry)
  )
  expect_identical(
    manifest$PrerequisiteProjectionHash,
    env$mfrmr_gtvt_hash(manifest$PrerequisiteProjection)
  )
  changed <- manifest
  changed$TruthBlindProcessBoundaryReady <- TRUE
  expect_error(do.call(
    env$mfrmr_gtvt_assert_manifest,
    c(list(manifest = changed), gtvt_manifest_args(environments, objects))
  ), "manifest, schema, or readiness")
})

test_that("Draft.85c4m keeps process, execution, and public gates closed", {
  environments <- load_gtheory_multivariate_planned_adapter()
  objects <- gtvt_objects(environments)
  manifest <- gtvt_manifest(environments, objects)
  ready <- c(
    "AdapterWorkerImplemented", "WorkerNamespaceSeparationReady",
    "WorkerStaticForbiddenCallAuditReady", "ThreeLaneOpaqueTransportReady",
    "CandidateColumnAllowlistReady", "ProtectedMaterialExcluded",
    "BackendQualificationBound", "BackendQualificationReady",
    "AdapterRequestSchemaReady", "AdapterReceiptSchemaReady",
    "PayloadTruthBlindReady", "RefusalTransportExercised",
    "ExactlyZeroC3PrerequisitesTransitioned", "ExecutionGateClosed"
  )
  closed <- c(
    "ProcessCapabilityIsolationAssessed", "ProcessCapabilityIsolationReady",
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
  expect_true(all(vapply(ready, function(name) manifest[[name]], logical(1L))))
  expect_false(any(vapply(closed, function(name) manifest[[name]], logical(1L))))
  protected <- c(
    "PlannedSeedMaterialIncluded", "ScenarioIdentityIncluded",
    "ReferenceIdentityIncluded", "ReferenceTruthIncluded",
    "AccuracyThresholdIncluded", "ConQuestRouteIncluded"
  )
  expect_false(any(vapply(
    protected, function(name) manifest[[name]], logical(1L)
  )))
  called <- FALSE
  callback <- function() {
    called <<- TRUE
    TRUE
  }
  expect_error(do.call(
    environments$controller$mfrmr_gtvt_dispatch_guard,
    c(list(
      manifest = manifest, action = "candidate_execution",
      callback = callback, authorize = TRUE
    ), gtvt_manifest_args(environments, objects))
  ), "process isolation and every candidate")
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
  expect_false(any(grepl("Draft\\.85c4m|mfrmr_gtvt[w]?_", public_text)))
})
