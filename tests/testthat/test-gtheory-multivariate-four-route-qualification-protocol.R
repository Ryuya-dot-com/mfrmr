gtheory_multivariate_four_route_protocol_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-execution-admission-preflight-0.2.4.R",
      paste0(
        "gtheory-multivariate-backend-qualification-admission-",
        "preflight-0.2.4.R"
      ),
      "gtheory-multivariate-four-route-qualification-protocol-0.2.4.R"
    )
  )
}

load_gtheory_multivariate_four_route_protocol <- local({
  environment <- NULL
  function() {
    paths <- gtheory_multivariate_four_route_protocol_paths()
    skip_if_not(all(file.exists(paths)),
                "repository-internal validation artifacts are excluded")
    skip_if_not_installed("digest")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = environment)
    }
    environment
  }
})

gtvm_repo_root <- function() {
  testthat::test_path("..", "..")
}

gtvm_objects <- local({
  objects <- NULL
  function(env) {
    if (is.null(objects)) {
      environment <- env$mfrmr_gtvl_environment_identity()
      c4e <- env$mfrmr_gtvl_manifest(gtvm_repo_root(), environment)
      manifest <- env$mfrmr_gtvm_manifest(gtvm_repo_root(), c4e)
      objects <<- list(
        environment = environment, c4e = c4e, manifest = manifest
      )
    }
    objects
  }
})

gtvm_token <- function(env, label) {
  env$mfrmr_gtvm_hash(list(Token = label))
}

gtvm_candidate <- function(env, route_id, overrides = list()) {
  objects <- gtvm_objects(env)
  criterion <- if (grepl("reml$", route_id)) "REML" else "ML"
  arguments <- list(
    route_id = route_id,
    environment_identity_hash = objects$c4e$CurrentEnvironmentIdentityHash,
    process_identity_hash = gtvm_token(env, paste0("process/", route_id)),
    worker_source_sha256 = gtvm_token(env, "worker/source"),
    specification_hash = gtvm_token(env, paste0("spec/", criterion)),
    semantic_model_hash = gtvm_token(env, paste0("semantic/", criterion)),
    fit_result_hash = gtvm_token(env, paste0("fit/", route_id)),
    fit_status = "identified_point_fit",
    fit_returned = TRUE,
    fit_integrity_passed = TRUE,
    point_estimation_gate_passed = TRUE,
    backend_rows_match = TRUE,
    dependency_abi_match = TRUE,
    fresh_process = TRUE,
    diagnostic_override_used = FALSE,
    warning_count = 0L,
    error_class = NA_character_
  )
  arguments[names(overrides)] <- overrides
  do.call(env$mfrmr_gtvm_route_candidate_receipt, arguments)
}

test_that("Draft.85c4f owns a distinct sixteen-function namespace", {
  env <- load_gtheory_multivariate_four_route_protocol()
  identity <- env$mfrmr_gtvm_implementation_identity()
  expect_identical(nrow(identity), 16L)
  expect_identical(anyDuplicated(identity$Function), 0L)
  expect_true(all(grepl("^mfrmr_gtvm_", identity$Function)))
  expect_true(all(nchar(identity$SHA256) == 64L))
})

test_that("Draft.85c4f freezes four routes, two pairs, and b1 tolerances", {
  env <- load_gtheory_multivariate_four_route_protocol()
  policy <- env$mfrmr_gtvm_qualification_policy()
  expect_silent(env$mfrmr_gtvm_assert_policy(policy))
  expect_s3_class(policy, "mfrmr_gtvm_policy")
  expect_identical(policy$RouteRegistry$RouteId, c(
    "lme4_ml", "lme4_reml", "glmmTMB_ml", "glmmTMB_reml"
  ))
  expect_identical(policy$PairRegistry$PairId,
                   c("matched_ml", "matched_reml"))
  expect_identical(policy$ToleranceRegistry$ToleranceId, c(
    "covariance_absolute", "covariance_relative",
    "fixed_absolute", "loglik_absolute"
  ))
  expect_identical(policy$ToleranceRegistry$Value,
                   c(1e-4, 1e-4, 1e-4, 1e-5))
  expect_true(policy$FullB1FitObjectsRequired)
  expect_true(policy$FullB1ParityObjectRequired)
  expect_false(policy$SummaryOnlyReceiptSufficient)
  expect_false(policy$PartialRouteQualificationAllowed)
  expect_false(policy$DiagnosticOverrideAllowed)
  expect_false(policy$OutcomeIndependentThresholdClaimed)
  expect_false(policy$TrustedWorkerImplemented)
})

test_that("Draft.85c4f templates contain no manufactured evidence", {
  env <- load_gtheory_multivariate_four_route_protocol()
  objects <- gtvm_objects(env)
  policy <- objects$manifest$QualificationPolicy
  routes <- env$mfrmr_gtvm_route_receipt_template(
    objects$c4e$CurrentEnvironmentIdentityHash, policy
  )
  pairs <- env$mfrmr_gtvm_pair_receipt_template(
    objects$c4e$CurrentEnvironmentIdentityHash, policy
  )
  expect_identical(routes$RouteOrdinal, 1:4)
  expect_true(all(is.na(routes$ProcessIdentityHash)))
  expect_true(all(is.na(routes$FitResultHash)))
  expect_false(any(routes$CandidateReceiptReady))
  expect_false(any(routes$TrustedReceiptReady))
  expect_false(any(routes$OperationallyAdmissible))
  expect_identical(pairs$PairOrdinal, 1:2)
  expect_true(all(is.na(pairs$ParityResultHash)))
  expect_false(any(pairs$CandidatePairReady))
  expect_false(any(pairs$TrustedPairReady))
  expect_false(any(pairs$OperationallyAdmissible))
})

test_that("Draft.85c4f candidate route readiness remains untrusted", {
  env <- load_gtheory_multivariate_four_route_protocol()
  receipt <- gtvm_candidate(env, "lme4_ml")
  expect_silent(env$mfrmr_gtvm_assert_route_candidate(receipt))
  expect_s3_class(receipt, "mfrmr_gtvm_route_candidate")
  expect_true(receipt$CandidateReceiptReady)
  expect_true(receipt$SelfReportedSummary)
  expect_false(receipt$FullB1ObjectsRevalidated)
  expect_false(receipt$TrustedReceiptReady)
  expect_false(receipt$OperationallyAdmissible)
  expect_false(receipt$BackendQualificationReady)
  expect_false(receipt$ExecutionAuthorized)
  expect_false(receipt$RecoveryEvidenceReady)
  expect_false(receipt$PublicSupportReady)
})

test_that("Draft.85c4f candidate route controls fail independently", {
  env <- load_gtheory_multivariate_four_route_protocol()
  controls <- list(
    gtvm_candidate(env, "glmmTMB_ml", list(
      diagnostic_override_used = TRUE
    )),
    gtvm_candidate(env, "glmmTMB_ml", list(warning_count = 1L)),
    gtvm_candidate(env, "glmmTMB_ml", list(
      dependency_abi_match = FALSE
    )),
    gtvm_candidate(env, "glmmTMB_ml", list(fresh_process = FALSE)),
    gtvm_candidate(env, "glmmTMB_ml", list(
      fit_status = "optimizer_warning"
    )),
    gtvm_candidate(env, "glmmTMB_ml", list(
      fit_returned = FALSE, error_class = "backend_error"
    ))
  )
  for (receipt in controls) {
    expect_silent(env$mfrmr_gtvm_assert_route_candidate(receipt))
    expect_false(receipt$CandidateReceiptReady)
    expect_false(receipt$TrustedReceiptReady)
    expect_false(receipt$OperationallyAdmissible)
  }
})

test_that("Draft.85c4f matched pair can be candidate-ready but not trusted", {
  env <- load_gtheory_multivariate_four_route_protocol()
  lme4 <- gtvm_candidate(env, "lme4_reml")
  glmmtmb <- gtvm_candidate(env, "glmmTMB_reml")
  pair <- env$mfrmr_gtvm_pair_candidate_receipt(
    "REML", lme4, glmmtmb, gtvm_token(env, "parity/REML"),
    numerical_parity_passed = TRUE,
    both_point_gates_passed = TRUE,
    backend_dependency_identity_passed = TRUE,
    exact_specification_match = TRUE,
    exact_semantic_model_match = TRUE
  )
  expect_silent(env$mfrmr_gtvm_assert_pair_candidate(pair))
  expect_s3_class(pair, "mfrmr_gtvm_pair_candidate")
  expect_true(pair$RouteIdentitiesMatch)
  expect_true(pair$CandidatePairReady)
  expect_true(pair$SelfReportedSummary)
  expect_false(pair$FullB1ObjectsRevalidated)
  expect_false(pair$TrustedPairReady)
  expect_false(pair$OperationallyAdmissible)
  expect_false(pair$BackendQualificationReady)
  expect_false(pair$ExecutionAuthorized)
  expect_false(pair$RecoveryEvidenceReady)
  expect_false(pair$PublicSupportReady)
})

test_that("Draft.85c4f rejects mixed pairs and rehashed trust mutation", {
  env <- load_gtheory_multivariate_four_route_protocol()
  lme4_ml <- gtvm_candidate(env, "lme4_ml")
  glmmtmb_reml <- gtvm_candidate(env, "glmmTMB_reml")
  expect_error(env$mfrmr_gtvm_pair_candidate_receipt(
    "ML", lme4_ml, glmmtmb_reml, gtvm_token(env, "mixed"),
    TRUE, TRUE, TRUE, TRUE, TRUE
  ), "pair routes do not match")

  changed <- lme4_ml
  changed$TrustedReceiptReady <- TRUE
  expect_error(env$mfrmr_gtvm_assert_route_candidate(changed),
               "candidate or trust state was altered")

  changed <- lme4_ml
  changed$FitReturned <- FALSE
  payload_fields <- names(changed)[seq_len(match("ErrorClass", names(changed)))]
  changed$ReceiptPayloadHash <- env$mfrmr_gtvm_hash(changed[payload_fields])
  expect_error(env$mfrmr_gtvm_assert_route_candidate(changed),
               "candidate or trust state was altered")
})

test_that("Draft.85c4f seals protocol readiness without qualification", {
  env <- load_gtheory_multivariate_four_route_protocol()
  objects <- gtvm_objects(env)
  manifest <- objects$manifest
  expect_silent(env$mfrmr_gtvm_assert_manifest(
    manifest, gtvm_repo_root(), objects$c4e
  ))
  expect_s3_class(manifest, "mfrmr_gtvm_manifest")
  expect_identical(manifest$C4EManifestHash, objects$c4e$ManifestHash)
  expect_true(manifest$QualificationPolicyReady)
  expect_true(manifest$ReceiptSchemaReady)
  expect_true(manifest$CandidateReceiptEvaluatorReady)
  expect_identical(
    manifest$EnvironmentReadyForBackendQualification,
    objects$c4e$EnvironmentReadyForBackendQualification
  )
  expect_true(manifest$RepairRequired)
  expect_false(manifest$TrustedWorkerImplemented)
  expect_false(manifest$RouteReceiptsMaterialized)
  expect_false(manifest$PairReceiptsMaterialized)
  expect_false(manifest$QualificationEvidenceReady)
  expect_false(manifest$BackendQualificationAdmissionReady)
  expect_false(manifest$BackendQualificationReady)
  expect_false(manifest$DiagnosticOverrideAllowed)
  expect_true(manifest$ExecutionGateClosed)
})

test_that("Draft.85c4f blocks worker, fit, and promotion callbacks", {
  env <- load_gtheory_multivariate_four_route_protocol()
  objects <- gtvm_objects(env)
  state <- new.env(parent = emptyenv())
  state$calls <- 0L
  callback <- function(...) {
    state$calls <- state$calls + 1L
    "unreachable"
  }
  for (action in c("trusted_worker", "backend_fit", "receipt_promotion")) {
    for (authorize in c(FALSE, TRUE)) {
      expect_error(env$mfrmr_gtvm_dispatch_guard(
        objects$manifest, action, callback, authorize = authorize,
        repo_root = gtvm_repo_root(), c4e_manifest = objects$c4e
      ), "no trusted worker or receipts")
    }
  }
  expect_error(env$mfrmr_gtvm_dispatch_guard(
    objects$manifest, "ConQuest", callback, authorize = TRUE,
    repo_root = gtvm_repo_root(), c4e_manifest = objects$c4e
  ), "outside the protocol")
  expect_identical(state$calls, 0L)
})

test_that("Draft.85c4f remains internal and opens no execution material", {
  env <- load_gtheory_multivariate_four_route_protocol()
  manifest <- gtvm_objects(env)$manifest
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
    "install.packages|remotes::|pak::|glmmTMB::glmmTMB|lme4::lmer|system2\\(",
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
  expect_false(any(grepl("Draft\\.85c4f|mfrmr_gtvm_", public_text)))
})
