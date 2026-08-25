gtheory_multivariate_c4o_paths <- function() {
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
      ),
      "gtheory-multivariate-fit-candidate-envelope-preflight-0.2.4.R"
    )
  )
}

gtheory_multivariate_c4o_worker_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-multivariate-abi-repair-identity-worker-0.2.4.R",
      "gtheory-multivariate-full-object-qualification-worker-0.2.4.R",
      "gtheory-multivariate-full-object-capability-worker-0.2.4.R",
      "gtheory-multivariate-planned-adapter-worker-0.2.4.R",
      "gtheory-multivariate-planned-adapter-capability-worker-0.2.4.R",
      "gtheory-multivariate-fit-candidate-envelope-worker-0.2.4.R"
    )
  )
}

load_gtheory_multivariate_c4o <- local({
  environments <- NULL
  function() {
    paths <- gtheory_multivariate_c4o_paths()
    workers <- gtheory_multivariate_c4o_worker_paths()
    skip_if_not(all(file.exists(c(paths, workers))),
                "repository-internal validation artifacts are excluded")
    skip_if_not_installed("digest")
    if (is.null(environments)) {
      controller <- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = controller)
      loaded_workers <- lapply(workers, function(path) {
        environment <- new.env(parent = baseenv())
        sys.source(path, envir = environment)
        environment
      })
      environments <<- list(
        controller = controller,
        repair_worker = loaded_workers[[1L]],
        qualification_worker = loaded_workers[[2L]],
        capability_worker = loaded_workers[[3L]],
        adapter_worker = loaded_workers[[4L]],
        c4n_capability_worker = loaded_workers[[5L]],
        contract_worker = loaded_workers[[6L]]
      )
    }
    environments
  }
})

gtvv_repo_root <- function() testthat::test_path("..", "..")

gtvv_validation_dir <- function() {
  dirname(gtheory_multivariate_c4o_worker_paths()[[1L]])
}

skip_if_not_c4o_evidence <- function() {
  skip_if_not(
    identical(Sys.getenv("MFRMR_RUN_C4O_CONTRACT"), "true"),
    "set MFRMR_RUN_C4O_CONTRACT=true for the retained c4o chain"
  )
  paths <- Sys.getenv(c(
    "MFRMR_C4I_RECEIPT", "MFRMR_C4J_RECEIPT", "MFRMR_C4K_EVIDENCE",
    "MFRMR_C4L_RECEIPT", "MFRMR_C4M_MANIFEST", "MFRMR_C4N_EVIDENCE"
  ), unset = "")
  skip_if_not(all(nzchar(paths) & file.exists(paths)),
              "set retained c4i through c4n evidence paths")
}

gtvv_objects <- local({
  objects <- NULL
  function(environments) {
    skip_if_not_c4o_evidence()
    if (is.null(objects)) {
      env <- environments$controller
      plan <- env$mfrmr_gtvd_plan()
      generator <- env$mfrmr_gtve_manifest(plan)
      c3 <- env$mfrmr_gtvf_manifest(
        plan, generator, env$mfrmr_gtvf_environment_snapshot()
      )
      c4e_environment <- env$mfrmr_gtvl_environment_identity()
      c4e <- env$mfrmr_gtvl_manifest(gtvv_repo_root(), c4e_environment)
      c4f <- env$mfrmr_gtvm_manifest(gtvv_repo_root(), c4e)
      objects <<- list(
        plan = plan, generator = generator, c3 = c3,
        c4e_environment = c4e_environment, c4e = c4e, c4f = c4f,
        repair = readRDS(Sys.getenv("MFRMR_C4I_RECEIPT")),
        qualification = readRDS(Sys.getenv("MFRMR_C4J_RECEIPT")),
        capability = readRDS(Sys.getenv("MFRMR_C4K_EVIDENCE")),
        integration = readRDS(Sys.getenv("MFRMR_C4L_RECEIPT")),
        adapter = readRDS(Sys.getenv("MFRMR_C4M_MANIFEST")),
        adapter_capability = readRDS(Sys.getenv("MFRMR_C4N_EVIDENCE"))
      )
    }
    objects
  }
})

gtvv_manifest_args <- function(environments, objects) {
  list(
    plan = objects$plan, generator_manifest = objects$generator,
    c3_manifest = objects$c3, c4e_manifest = objects$c4e,
    c4f_manifest = objects$c4f, repair_receipt = objects$repair,
    qualification_receipt = objects$qualification,
    capability_evidence = objects$capability,
    c4l_receipt = objects$integration, c4m_manifest = objects$adapter,
    c4n_evidence = objects$adapter_capability,
    repair_worker_environment = environments$repair_worker,
    qualification_worker_environment = environments$qualification_worker,
    capability_worker_environment = environments$capability_worker,
    adapter_worker_environment = environments$adapter_worker,
    c4n_capability_worker_environment = environments$c4n_capability_worker,
    contract_worker_environment = environments$contract_worker,
    repo_root = gtvv_repo_root(), validation_dir = gtvv_validation_dir()
  )
}

gtvv_manifest <- local({
  manifest <- NULL
  function(environments, objects) {
    if (is.null(manifest)) {
      manifest <<- do.call(
        environments$controller$mfrmr_gtvv_manifest,
        gtvv_manifest_args(environments, objects)
      )
      output <- Sys.getenv("MFRMR_C4O_MANIFEST_PATH", unset = "")
      if (nzchar(output)) saveRDS(manifest, output, version = 3L)
    }
    manifest
  }
})

test_that("Draft.85c4o contract worker has an exact five-function namespace", {
  environments <- load_gtheory_multivariate_c4o()
  env <- environments$controller
  identity <- env$mfrmr_gtvv_worker_identity(environments$contract_worker)
  audit <- env$mfrmr_gtvv_worker_static_audit(environments$contract_worker)
  expect_identical(parent.env(environments$contract_worker), baseenv())
  expect_identical(nrow(identity), 5L)
  expect_identical(anyDuplicated(identity$Function), 0L)
  expect_true(all(grepl("^mfrmr_gtvvw_", identity$Function)))
  expect_true(all(grepl("^[0-9a-f]{64}$", identity$SHA256)))
  expect_identical(nrow(audit), 13L)
  expect_false(any(audit$Present))
  expect_true(all(audit$Passed))
})

test_that("Draft.85c4o controller has a distinct twenty-five-function identity", {
  environments <- load_gtheory_multivariate_c4o()
  identity <- environments$controller$mfrmr_gtvv_implementation_identity()
  expect_identical(nrow(identity), 25L)
  expect_identical(anyDuplicated(identity$Function), 0L)
  expect_true(all(grepl("^mfrmr_gtvv_", identity$Function)))
  expect_true(all(grepl("^[0-9a-f]{64}$", identity$SHA256)))
})

test_that("Draft.85c4o revalidates c4n and the complete parent chain", {
  environments <- load_gtheory_multivariate_c4o()
  objects <- gtvv_objects(environments)
  manifest <- gtvv_manifest(environments, objects)
  expect_silent(do.call(
    environments$controller$mfrmr_gtvv_assert_manifest,
    c(list(manifest = manifest), gtvv_manifest_args(environments, objects))
  ))
  expect_s3_class(manifest, "mfrmr_gtvv_manifest")
  expect_identical(manifest$PlanHash, objects$plan$PlanHash)
  expect_identical(
    manifest$C4NEvidenceHash, objects$adapter_capability$EvidenceHash
  )
  expect_identical(
    manifest$C4LReceiptHash, objects$integration$ReceiptHash
  )
  expect_identical(
    manifest$CandidateUnitManifestHash,
    objects$plan$CandidateUnitManifestHash
  )
})

test_that("Draft.85c4o releases an exact observation-linked candidate table", {
  environments <- load_gtheory_multivariate_c4o()
  objects <- gtvv_objects(environments)
  manifest <- gtvv_manifest(environments, objects)
  expect_identical(
    manifest$CandidateDataSchema$Names,
    c(
      "RowId", "Stratum", "Object", "Rater", "ObjectRater",
      "ObservationLink", "Score"
    )
  )
  expect_identical(manifest$ReleaseAudit$OriginalColumnCount, 7L)
  expect_identical(manifest$ReleaseAudit$ReleasedColumnCount, 7L)
  expect_identical(manifest$ReleaseAudit$RemovedColumn, "Replicate")
  expect_identical(manifest$ReleaseAudit$AddedColumn, "ObservationLink")
  expect_true(manifest$ReleaseAudit$ObservationLinkUniqueWithinStratum)
  expect_gt(manifest$ReleaseAudit$CandidateRows, 0L)
  expect_false(manifest$ReleaseAudit$ProtectedSourceContentRetained)
  expect_true(manifest$CandidateReleaseTransformReady)
  expect_true(manifest$CandidateDataObservationLinkSchemaReady)
  expect_true(manifest$RawWithinCellReplicateRemoved)
  expect_true(manifest$ObservationLinkPairIdentityReady)
  expect_false(manifest$PlannedReplicateIdentityIncluded)
  expect_false(manifest$WithinCellReplicateOrdinalIncluded)
  expect_true(manifest$ObservationLinkIncluded)
  env <- environments$controller
  generation <- env$mfrmr_gtve_generate_fixture(
    objects$generator$FixtureRegistry$FixtureId[[1L]], objects$plan,
    objects$generator$FixtureRegistry
  )
  envelope <- env$mfrmr_gtvv_candidate_release(
    generation, "lme4_reml", objects$plan, objects$generator,
    objects$integration
  )
  receive <- get(
    "mfrmr_gtvvw_receive", envir = environments$contract_worker,
    inherits = FALSE
  )
  changed_id <- envelope
  changed_id$OpaqueExerciseId <- "C4O-000000000000000000000000"
  changed_id$EnvelopeHash <- env$mfrmr_gtvv_hash(changed_id[seq_len(19L)])
  expect_error(receive(changed_id), "candidate envelope was altered")
  changed_group <- envelope
  changed_group$CandidateData$ObjectRater[[1L]] <- "INVALID-GROUP"
  changed_group$CandidateDataHash <- env$mfrmr_gtvv_hash(
    changed_group$CandidateData
  )
  changed_group$OpaqueExerciseId <- paste0("C4O-", substr(env$mfrmr_gtvv_hash(
    list(
      Namespace =
        "gtheory_multivariate_fit_candidate_exercise_draft85c4o_v1",
      CandidateDataHash = changed_group$CandidateDataHash,
      CandidateSchemaHash = changed_group$CandidateSchemaHash,
      MethodId = changed_group$MethodId,
      MethodControlHash = changed_group$MethodControlHash,
      BackendQualificationReceiptHash =
        changed_group$BackendQualificationReceiptHash
    )
  ), 1L, 24L))
  changed_group$EnvelopeHash <- env$mfrmr_gtvv_hash(
    changed_group[seq_len(19L)]
  )
  expect_error(receive(changed_group), "candidate envelope was altered")
  changed_link <- envelope
  changed_link$CandidateData$ObservationLink[[2L]] <-
    changed_link$CandidateData$ObservationLink[[1L]]
  changed_link$CandidateDataHash <- env$mfrmr_gtvv_hash(
    changed_link$CandidateData
  )
  changed_link$OpaqueExerciseId <- paste0("C4O-", substr(env$mfrmr_gtvv_hash(
    list(
      Namespace =
        "gtheory_multivariate_fit_candidate_exercise_draft85c4o_v1",
      CandidateDataHash = changed_link$CandidateDataHash,
      CandidateSchemaHash = changed_link$CandidateSchemaHash,
      MethodId = changed_link$MethodId,
      MethodControlHash = changed_link$MethodControlHash,
      BackendQualificationReceiptHash =
        changed_link$BackendQualificationReceiptHash
    )
  ), 1L, 24L))
  changed_link$EnvelopeHash <- env$mfrmr_gtvv_hash(
    changed_link[seq_len(19L)]
  )
  expect_error(receive(changed_link), "candidate envelope was altered")
})

test_that("Draft.85c4o binds all four qualified routes without fitting", {
  environments <- load_gtheory_multivariate_c4o()
  objects <- gtvv_objects(environments)
  manifest <- gtvv_manifest(environments, objects)
  exercise <- manifest$RouteExerciseRegistry
  routes <- manifest$RouteContractRegistry
  expect_identical(nrow(exercise), 4L)
  expect_identical(
    exercise$MethodId,
    c("lme4_reml", "glmmtmb_reml", "lme4_ml", "glmmtmb_ml")
  )
  expect_identical(
    exercise$QualificationRouteId,
    c("lme4_reml", "glmmTMB_reml", "lme4_ml", "glmmTMB_ml")
  )
  expect_true(all(exercise$EnvelopeAccepted))
  expect_false(any(exercise$Attempted))
  expect_false(any(exercise$BackendInvoked))
  expect_false(any(exercise$FitReturned))
  expect_false(any(exercise$FitCapableWorkerImplemented))
  expect_true(all(routes$QualifiedProcessCapabilityIsolationReady))
  expect_true(all(routes$RouteReceiptReady))
  expect_true(all(routes$CandidateFitContractMayInvokeBackend))
  expect_false(any(routes$FitCapableWorkerImplementedInC4O))
})

test_that("Draft.85c4o reuses the c1 denominator exactly", {
  environments <- load_gtheory_multivariate_c4o()
  objects <- gtvv_objects(environments)
  topology <- gtvv_manifest(environments, objects)$PlannedTopologyRegistry
  expect_identical(
    topology$StageId, c("pilot", "confirmation", "negative_control")
  )
  expect_identical(topology$PlannedDatasetCount, c(240L, 4800L, 2L))
  expect_identical(topology$PlannedMethodUnitCount, c(960L, 19200L, 8L))
  expect_identical(
    topology$PlannedMethodUnitCount, topology$C4MExpectedUnits
  )
  expect_true(all(topology$FourRoutesPerDataset))
  expect_false(any(topology$SecondDenominatorCreated))
  expect_identical(sum(topology$PlannedDatasetCount), 5042L)
  expect_identical(sum(topology$PlannedMethodUnitCount), 20168L)
})

test_that("Draft.85c4o separates authorities and excludes protected fields", {
  environments <- load_gtheory_multivariate_c4o()
  objects <- gtvv_objects(environments)
  manifest <- gtvv_manifest(environments, objects)
  access <- manifest$AccessQuestionRegistry
  authority <- manifest$AuthoritySeparationRegistry
  expect_false(any(access$ForbiddenFieldPresent))
  expect_false(any(access$CandidateContractCanRead))
  expect_false(any(access$ProtectedMaterialPresent))
  expect_true(all(access$FitWorkerCapabilityRecheckRequired))
  candidate <- authority$AuthorityId == "candidate_fit_contract"
  expect_false(authority$ProtectedMaterialMayBeRead[candidate])
  expect_true(authority$CandidateDataMayBeRead[candidate])
  expect_true(authority$BackendContractMayBeInvoked[candidate])
  expect_false(authority$ImplementedInC4O[candidate])
  expect_false(any(authority$ProcessCapabilityIsolationAssessed))
  expect_true(manifest$AuthoritySeparationContractReady)
  expect_true(manifest$ProtectedMaterialExcluded)
})

test_that("Draft.85c4o does not transition the c3 truth-blind prerequisite", {
  environments <- load_gtheory_multivariate_c4o()
  objects <- gtvv_objects(environments)
  manifest <- gtvv_manifest(environments, objects)
  audit <- manifest$PrerequisiteProjection
  truth <- audit$PrerequisiteId == "truth_blind_process_boundary"
  expect_false(any(audit$TransitionedByC4O))
  expect_identical(sum(audit$C4OProjectedSatisfied), 2L)
  expect_false(audit$C4OProjectedSatisfied[truth])
  expect_true(audit$FitCandidateEnvelopeContractEvidenceAvailable[truth])
  expect_false(audit$FitCapableWorkerEvidenceAvailable[truth])
  expect_false(audit$FitCapableProcessIsolationEvidenceAvailable[truth])
  expect_true(manifest$ExactlyZeroC3PrerequisitesTransitioned)
  expect_identical(manifest$C3SatisfiedPrerequisiteCount, 2L)
  expect_false(manifest$TruthBlindProcessBoundaryReady)
})

test_that("Draft.85c4o is hash complete and rejects rehashed promotion", {
  environments <- load_gtheory_multivariate_c4o()
  objects <- gtvv_objects(environments)
  manifest <- gtvv_manifest(environments, objects)
  env <- environments$controller
  expect_identical(
    manifest$ManifestHash,
    env$mfrmr_gtvv_hash(manifest[env$mfrmr_gtvv_payload_fields()])
  )
  expect_identical(
    manifest$RouteExerciseRegistryHash,
    env$mfrmr_gtvv_hash(manifest$RouteExerciseRegistry)
  )
  expect_identical(
    manifest$PlannedTopologyRegistryHash,
    env$mfrmr_gtvv_hash(manifest$PlannedTopologyRegistry)
  )
  changed <- manifest
  changed$FitCapableWorkerImplemented <- TRUE
  expect_error(do.call(
    env$mfrmr_gtvv_assert_manifest,
    c(list(manifest = changed), gtvv_manifest_args(environments, objects))
  ), "manifest, contract, or readiness")
})

test_that("Draft.85c4o keeps worker, execution, and public gates closed", {
  environments <- load_gtheory_multivariate_c4o()
  objects <- gtvv_objects(environments)
  manifest <- gtvv_manifest(environments, objects)
  ready <- c(
    "ContractWorkerImplemented", "WorkerNamespaceSeparationReady",
    "WorkerStaticNoExecutionAuditReady", "CandidateReleaseTransformReady",
    "CandidateDataObservationLinkSchemaReady",
    "RawWithinCellReplicateRemoved", "ObservationLinkPairIdentityReady",
    "FourRouteEnvelopeContractReady", "FourRouteReceiptContractReady",
    "BackendQualificationBound", "BackendQualificationReady",
    "PlannedDenominatorTopologyBound", "SecondDenominatorAbsent",
    "AuthoritySeparationContractReady", "ProtectedMaterialExcluded",
    "PayloadTruthBlindReady", "C4NNonAttemptAdapterCapabilityReady",
    "ExactlyZeroC3PrerequisitesTransitioned", "ExecutionGateClosed"
  )
  closed <- c(
    "FitCapableWorkerImplemented",
    "FitCapableProcessCapabilityIsolationReady",
    "TruthBlindProcessBoundaryReady", "PlannedExecutionIsolationReady",
    "AllExecutionPrerequisitesReady", "ExternalFreezeReady",
    "CleanSourceIdentityReady", "IndependentAccuracyRuleReady",
    "PilotExecutionAuthorized", "ConfirmationExecutionAuthorized",
    "NegativeControlExecutionAuthorized", "BackendExecutionOccurred",
    "CandidateExecutionOccurred", "CandidateCompletionSealed",
    "TruthReleaseAuthorized", "DenominatorAccountingReady",
    "PlannedResponseGenerated", "RecoveryExecuted", "RecoveryEvidenceReady",
    "EstimationReady", "InferenceReady", "DecisionReady",
    "PublicSupportReady"
  )
  expect_true(all(vapply(ready, function(name) manifest[[name]], logical(1L))))
  expect_false(any(vapply(closed, function(name) manifest[[name]], logical(1L))))
  protected <- c(
    "ExerciseEnvelopeObjectsRetained", "ExerciseCandidateDataRetained",
    "ProtectedSourceAuditContentRetained", "PlannedCandidateDataIncluded",
    "PlannedReplicateIdentityIncluded", "WithinCellReplicateOrdinalIncluded",
    "ScenarioIdentityIncluded",
    "PlannedSeedMaterialIncluded", "ReferenceIdentityIncluded",
    "ReferenceTruthIncluded", "AccuracyThresholdIncluded",
    "ConQuestRouteIncluded"
  )
  expect_false(any(vapply(
    protected, function(name) manifest[[name]], logical(1L)
  )))
  expect_true(manifest$ObservationLinkIncluded)
  called <- FALSE
  callback <- function() {
    called <<- TRUE
    TRUE
  }
  expect_error(do.call(
    environments$controller$mfrmr_gtvv_dispatch_guard,
    c(list(
      manifest = manifest, action = "fit_worker", callback = callback,
      authorize = TRUE
    ), gtvv_manifest_args(environments, objects))
  ), "fit-capable worker, its capability isolation")
  expect_false(called)
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
  expect_false(any(grepl("Draft\\.85c4o|mfrmr_gtvv[w]?_", public_text)))
})
