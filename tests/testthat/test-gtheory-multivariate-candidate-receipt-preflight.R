gtheory_multivariate_candidate_receipt_paths <- function() {
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
      "gtheory-multivariate-candidate-receipt-preflight-0.2.4.R"
    )
  )
}

gtheory_multivariate_candidate_worker_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-multivariate-candidate-receipt-worker-0.2.4.R"
  )
}

load_gtheory_multivariate_candidate_receipt <- local({
  environments <- NULL
  function() {
    paths <- gtheory_multivariate_candidate_receipt_paths()
    worker_path <- gtheory_multivariate_candidate_worker_path()
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

gtvg_objects <- local({
  objects <- NULL
  function(environments) {
    if (is.null(objects)) {
      env <- environments$controller
      plan <- env$mfrmr_gtvd_plan()
      generator <- env$mfrmr_gtve_manifest(plan)
      manifest <- env$mfrmr_gtvg_manifest(
        environments$worker, plan, generator
      )
      first_generation <- env$mfrmr_gtve_generate_fixture(
        generator$FixtureRegistry$FixtureId[[1L]], plan,
        generator$FixtureRegistry
      )
      first_envelope <- env$mfrmr_gtvg_candidate_envelope(
        first_generation, plan, generator$FixtureRegistry,
        upstream_validated = TRUE
      )
      first_receipt <- env$mfrmr_gtvg_worker_receipt(
        first_envelope, environments$worker
      )
      objects <<- list(
        plan = plan, generator = generator, manifest = manifest,
        first_generation = first_generation,
        first_envelope = first_envelope, first_receipt = first_receipt
      )
    }
    objects
  }
})

test_that("Draft.85c4a worker namespace contains only four candidate functions", {
  environments <- load_gtheory_multivariate_candidate_receipt()
  env <- environments$controller
  worker <- environments$worker
  identity <- env$mfrmr_gtvg_worker_identity(worker)

  expect_identical(parent.env(worker), baseenv())
  expect_identical(
    sort(ls(worker, all.names = TRUE)),
    sort(env$mfrmr_gtvg_worker_functions())
  )
  expect_identical(nrow(identity), 4L)
  expect_true(all(nchar(identity$SHA256) == 64L))
  expect_false(any(grepl("^mfrmr_gtvd_|^mfrmr_gtve_",
                         ls(worker, all.names = TRUE))))
  expect_false(any(grepl(
    "truth|reference|seed|scenario", ls(worker, all.names = TRUE),
    ignore.case = TRUE
  )))
})

test_that("Draft.85c4a envelope contains the exact candidate payload", {
  environments <- load_gtheory_multivariate_candidate_receipt()
  env <- environments$controller
  objects <- gtvg_objects(environments)
  envelope <- objects$first_envelope

  expect_silent(env$mfrmr_gtvg_assert_candidate_envelope(envelope))
  expect_s3_class(envelope, "mfrmr_gtvg_candidate_envelope")
  expect_identical(
    names(envelope$CandidateData),
    c("RowId", "Stratum", "Object", "Rater", "ObjectRater", "Replicate",
      "Score")
  )
  expect_identical(envelope$CandidateData,
                   objects$first_generation$CandidateData)
  expect_identical(envelope$ExpectedRows,
                   as.integer(nrow(envelope$CandidateData)))
  expect_true(envelope$CandidatePayloadOnly)
  expect_false(envelope$BackendExecutionAuthorized)
  expect_false(envelope$RecoveryDenominatorEligible)
  expect_false(envelope$PublicSupportReady)
  expect_true(grepl("^C4A-[0-9a-f]{24}$", envelope$OpaqueCandidateId))
  expect_false(any(c(
    "FixtureId", "ScenarioId", "AssignmentId", "ReferenceId", "FixtureSeed",
    "TruthAudit", "FixedMean", "ObjectEffect", "RaterEffect",
    "ObjectRaterEffect", "ResidualEffect"
  ) %in% names(envelope)))
})

test_that("Draft.85c4a worker returns a typed non-attempt receipt", {
  environments <- load_gtheory_multivariate_candidate_receipt()
  env <- environments$controller
  objects <- gtvg_objects(environments)
  receipt <- objects$first_receipt
  envelope <- objects$first_envelope

  expect_silent(env$mfrmr_gtvg_assert_worker_receipt(
    receipt, envelope, environments$worker
  ))
  expect_s3_class(receipt, "mfrmr_gtvg_candidate_receipt")
  expect_identical(receipt$OpaqueCandidateId, envelope$OpaqueCandidateId)
  expect_identical(receipt$CandidateDataHash, envelope$CandidateDataHash)
  expect_identical(receipt$ObservedRows, envelope$ExpectedRows)
  expect_false(receipt$Attempted)
  expect_false(receipt$FitReturned)
  expect_false(receipt$EstimateAvailable)
  expect_false(receipt$PointGatePassed)
  expect_identical(
    receipt$FailureStage, "backend_not_invoked_fixture_schema_preflight"
  )
  expect_identical(
    receipt$FailureCode, "C4A-CANDIDATE-RECEIPT-SCHEMA-ONLY"
  )
  expect_false(receipt$BackendExecutionOccurred)
  expect_false(receipt$PlannedResponseGenerated)
  expect_false(receipt$RecoveryExecuted)
  expect_false(receipt$RecoveryEvidenceReady)
  expect_false(receipt$EstimationReady)
  expect_false(receipt$InferenceReady)
  expect_false(receipt$DecisionReady)
  expect_false(receipt$PublicSupportReady)
})

test_that("Draft.85c4a covers all fixtures without retaining the vault", {
  environments <- load_gtheory_multivariate_candidate_receipt()
  objects <- gtvg_objects(environments)
  manifest <- objects$manifest
  registry <- manifest$CandidateReceiptRegistry

  expect_identical(nrow(registry), 12L)
  expect_identical(registry$CandidateOrdinal, 1:12)
  expect_identical(
    registry$ExpectedRows, objects$generator$FixtureRegistry$ExpectedRows
  )
  expect_identical(anyDuplicated(registry$OpaqueCandidateId), 0L)
  expect_true(all(nchar(registry$CandidateDataHash) == 64L))
  expect_true(all(nchar(registry$EnvelopeHash) == 64L))
  expect_true(all(nchar(registry$ReceiptHash) == 64L))
  expect_false(any(registry$Attempted))
  expect_false(any(registry$FitReturned))
  expect_false(any(registry$EstimateAvailable))
  expect_false(any(registry$PointGatePassed))
  expect_true(all(registry$FailureCode ==
                    "C4A-CANDIDATE-RECEIPT-SCHEMA-ONLY"))
  expect_identical(manifest$ReferenceVaultRows, 12L)
  expect_false(manifest$ReferenceVaultContentRetained)
  expect_true(nchar(manifest$ReferenceVaultHash) == 64L)
  expect_false(any(c(
    "FixtureId", "ScenarioId", "ReferenceId", "FixtureSeed", "TruthAuditHash"
  ) %in% names(registry)))
})

test_that("Draft.85c4a rejects unknown and self-consistently rehashed input", {
  environments <- load_gtheory_multivariate_candidate_receipt()
  env <- environments$controller
  objects <- gtvg_objects(environments)
  envelope <- objects$first_envelope
  worker_receive <- environments$worker$mfrmr_gtvgw_receive

  changed <- envelope
  changed$TruthAudit <- objects$first_generation$TruthAudit
  expect_error(worker_receive(changed), "typed Draft.85c4a")

  changed <- envelope
  changed$CandidateData$Score[[1L]] <-
    changed$CandidateData$Score[[1L]] + 1
  changed$CandidateDataHash <- env$mfrmr_gta_hash(changed$CandidateData)
  changed$EnvelopeHash <- env$mfrmr_gta_hash(unclass(changed[1:7]))
  expect_error(worker_receive(changed), "schema or identity")

  changed <- envelope
  changed$BackendExecutionAuthorized <- TRUE
  expect_error(worker_receive(changed), "schema or identity")
})

test_that("Draft.85c4a rejects receipt and namespace mutation", {
  environments <- load_gtheory_multivariate_candidate_receipt()
  env <- environments$controller
  objects <- gtvg_objects(environments)

  changed_receipt <- objects$first_receipt
  changed_receipt$Attempted <- TRUE
  expect_error(env$mfrmr_gtvg_assert_worker_receipt(
    changed_receipt, objects$first_envelope, environments$worker
  ), "receipt was altered")

  changed_worker <- new.env(parent = baseenv())
  for (name in ls(environments$worker, all.names = TRUE)) {
    assign(name, get(name, envir = environments$worker, inherits = FALSE),
           envir = changed_worker)
  }
  changed_worker$TruthAudit <- data.frame(x = 1)
  expect_error(
    env$mfrmr_gtvg_worker_identity(changed_worker),
    "missing or additional bindings"
  )
})

test_that("Draft.85c4a seals only namespace and payload separation", {
  environments <- load_gtheory_multivariate_candidate_receipt()
  env <- environments$controller
  objects <- gtvg_objects(environments)
  manifest <- objects$manifest

  expect_silent(env$mfrmr_gtvg_assert_manifest(
    manifest, environments$worker, objects$plan, objects$generator
  ))
  expect_s3_class(manifest, "mfrmr_gtvg_manifest")
  expect_identical(manifest$CandidateCount, 12L)
  expect_true(manifest$CandidateEnvelopeSchemaReady)
  expect_true(manifest$CandidateReceiptSchemaReady)
  expect_true(manifest$WorkerNamespaceSeparationReady)
  expect_true(manifest$CandidatePayloadAllowlistReady)
  expect_true(manifest$ReferenceVaultContentExcluded)
  expect_false(manifest$ProcessCapabilityIsolationReady)
  expect_false(manifest$TruthBlindProcessBoundaryReady)
  expect_false(manifest$BackendQualificationReady)
  expect_false(manifest$PilotExecutionAuthorized)
  expect_false(manifest$ConfirmationExecutionAuthorized)
  expect_false(manifest$BackendExecutionOccurred)
  expect_false(manifest$PlannedResponseGenerated)
  expect_false(manifest$RecoveryExecuted)
  expect_false(manifest$RecoveryEvidenceReady)
  expect_false(manifest$EstimationReady)
  expect_false(manifest$InferenceReady)
  expect_false(manifest$DecisionReady)
  expect_false(manifest$PublicSupportReady)

  changed <- manifest
  changed$TruthBlindProcessBoundaryReady <- TRUE
  expect_error(env$mfrmr_gtvg_assert_manifest(
    changed, environments$worker, objects$plan, objects$generator
  ), "manifest, receipt, namespace, or readiness")
})

test_that("Draft.85c4a carries no plan seed or backend estimate", {
  environments <- load_gtheory_multivariate_candidate_receipt()
  objects <- gtvg_objects(environments)
  manifest <- objects$manifest
  recursive_names <- function(value) {
    own <- names(value)
    children <- if (is.list(value)) {
      unlist(lapply(value, recursive_names), use.names = FALSE)
    } else character()
    c(own, children)
  }
  all_names <- recursive_names(unclass(manifest))
  expect_false(any(c(
    "DataSeed", "FixtureSeed", "CandidateData", "TruthAudit", "ScenarioId",
    "ReferenceId", "Estimate", "StandardError", "LogLik"
  ) %in% all_names))
  numeric_values <- suppressWarnings(as.numeric(unlist(
    manifest, recursive = TRUE, use.names = FALSE
  )))
  numeric_values <- numeric_values[is.finite(numeric_values)]
  expect_false(any(numeric_values >= 851000000 & numeric_values <= 854999999))
  expect_false(any(manifest$CandidateReceiptRegistry$Attempted))
  expect_false(manifest$BackendExecutionOccurred)
})

test_that("Draft.85c4a remains internal and avoids estimator calls", {
  environments <- load_gtheory_multivariate_candidate_receipt()
  env <- environments$controller
  objects <- gtvg_objects(environments)
  identities <- rbind(
    objects$manifest$WorkerIdentity,
    objects$manifest$ControllerIdentity
  )
  function_text <- vapply(identities$Function, function(name) {
    target <- if (grepl("^mfrmr_gtvgw_", name)) {
      environments$worker
    } else {
      env
    }
    paste(deparse(body(get(name, envir = target, inherits = FALSE))),
          collapse = "\n")
  }, character(1L))
  expect_false(any(grepl(
    "glmmTMB::glmmTMB|lme4::lmer|system2\\(|ConQuest",
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
  expect_false(any(grepl("Draft\\.85c4a|mfrmr_gtvg[w]?_", public_text)))
})
