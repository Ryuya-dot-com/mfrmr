gtheory_multivariate_admission_paths <- function() {
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
      "gtheory-multivariate-execution-admission-preflight-0.2.4.R"
    )
  )
}

load_gtheory_multivariate_admission <- local({
  validation_environment <- NULL
  function() {
    paths <- gtheory_multivariate_admission_paths()
    skip_if_not(all(file.exists(paths)),
                "repository-internal validation artifacts are excluded")
    skip_if_not_installed("digest")
    if (is.null(validation_environment)) {
      validation_environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = validation_environment)
    }
    validation_environment
  }
})

gtvf_objects <- local({
  objects <- NULL
  function(env) {
    if (is.null(objects)) {
      plan <- env$mfrmr_gtvd_plan()
      generator <- env$mfrmr_gtve_manifest(plan)
      environment <- env$mfrmr_gtvf_environment_snapshot()
      manifest <- env$mfrmr_gtvf_manifest(plan, generator, environment)
      objects <<- list(
        plan = plan, generator = generator, environment = environment,
        manifest = manifest
      )
    }
    objects
  }
})

test_that("Draft.85c3 records the backend environment without fitting", {
  env <- load_gtheory_multivariate_admission()
  objects <- gtvf_objects(env)
  snapshot <- objects$environment

  expect_silent(env$mfrmr_gtvf_assert_environment_snapshot(snapshot))
  expect_s3_class(snapshot, "mfrmr_gtvf_environment")
  expect_identical(
    snapshot$RequiredBackendRoutes,
    c("lme4_ml", "lme4_reml", "glmmTMB_ml", "glmmTMB_reml")
  )
  expect_false(snapshot$ConQuestRouteIncluded)
  expect_identical(
    snapshot$DependencyABIMatch,
    snapshot$RequiredPackagesAvailable &&
      !is.na(snapshot$GlmmTMBBuildTMBVersion) &&
      identical(snapshot$GlmmTMBBuildTMBVersion, snapshot$TMBVersion)
  )
  expect_identical(
    snapshot$EnvironmentReadyForBackendQualification,
    snapshot$RequiredPackagesAvailable && snapshot$DependencyABIMatch
  )
  expect_false(snapshot$DiagnosticOverrideAllowed)
  expect_false(snapshot$BackendQualificationReady)
  expect_false(snapshot$PilotExecutionAuthorized)
  expect_false(snapshot$ConfirmationExecutionAuthorized)
  expect_false(snapshot$RecoveryExecuted)
  expect_false(snapshot$PublicSupportReady)
})

test_that("Draft.85c3 distinguishes package presence from ABI agreement", {
  env <- load_gtheory_multivariate_admission()
  values <- list(
    RVersion = "R synthetic", Platform = "synthetic-platform",
    Lme4Available = TRUE, Lme4Version = "2.0.6",
    GlmmTMBAvailable = TRUE, GlmmTMBVersion = "1.1.14",
    TMBAvailable = TRUE, TMBVersion = "1.9.25",
    GlmmTMBBuildTMBVersion = "1.9.25"
  )
  matched <- env$mfrmr_gtvf_environment_snapshot(values)
  expect_true(matched$RequiredPackagesAvailable)
  expect_true(matched$DependencyABIMatch)
  expect_true(matched$EnvironmentReadyForBackendQualification)
  expect_false(matched$BackendQualificationReady)

  values$GlmmTMBBuildTMBVersion <- "1.9.23"
  mismatched <- env$mfrmr_gtvf_environment_snapshot(values)
  expect_true(mismatched$RequiredPackagesAvailable)
  expect_false(mismatched$DependencyABIMatch)
  expect_false(mismatched$EnvironmentReadyForBackendQualification)
  expect_false(mismatched$BackendQualificationReady)

  values$GlmmTMBAvailable <- FALSE
  expect_error(
    env$mfrmr_gtvf_environment_snapshot(values),
    "availability and version identity disagree"
  )
})

test_that("Draft.85c3 leaves external evidence as typed empty templates", {
  env <- load_gtheory_multivariate_admission()
  objects <- gtvf_objects(env)
  plan <- objects$plan
  manifest <- objects$manifest

  freeze <- manifest$FreezeReceiptTemplate
  accuracy <- manifest$AccuracyRuleTemplate
  isolation <- manifest$IsolationTemplate
  authorities <- manifest$AuthorityTemplates
  expect_silent(env$mfrmr_gtvd_assert_freeze_receipt_template(plan, freeze))
  expect_silent(env$mfrmr_gtvf_assert_accuracy_rule_template(accuracy, plan))
  expect_silent(env$mfrmr_gtvf_assert_isolation_template(isolation, plan))
  expect_false(freeze$FreezeReceiptReady)
  expect_true(all(is.na(accuracy$CriterionTable$AccuracyThreshold)))
  expect_false(accuracy$IndependentAccuracyRuleReady)
  expect_false(accuracy$PilotOutcomeConsulted)
  expect_false(accuracy$ConfirmationOutcomeConsulted)
  expect_false(isolation$TruthBlindProcessBoundaryReady)
  expect_true(isolation$TruthReleaseRequiresCompleteReceipts)
  expect_identical(authorities$StageId,
                   c("pilot", "confirmation", "negative_control"))
  expect_true(all(is.na(authorities$AuthorityTokenSHA256)))
  expect_false(any(authorities$AuthorityReady))
  expect_false(any(authorities$ExecutionAuthorized))
})

test_that("Draft.85c3 audits every c1 prerequisite independently", {
  env <- load_gtheory_multivariate_admission()
  objects <- gtvf_objects(env)
  audit <- objects$manifest$PrerequisiteAudit

  expect_identical(nrow(audit), 8L)
  expect_identical(
    audit$PrerequisiteId,
    objects$plan$ExecutionPrerequisiteRegistry$PrerequisiteId
  )
  expect_identical(audit$PartialExecutionAllowed, rep(FALSE, 8L))
  expect_identical(which(audit$CurrentSatisfied), 8L)
  expect_identical(
    audit$EvidenceState[[3L]],
    if (objects$environment$EnvironmentReadyForBackendQualification) {
      "environment_only_no_four_route_fit_receipts"
    } else {
      "backend_environment_or_dependency_abi_not_ready"
    }
  )
  expect_identical(
    audit$EvidenceState[[7L]],
    "independent_numeric_accuracy_rule_not_supplied"
  )
})

test_that("Draft.85c3 seals a closed admission manifest", {
  env <- load_gtheory_multivariate_admission()
  objects <- gtvf_objects(env)
  manifest <- objects$manifest

  expect_silent(env$mfrmr_gtvf_assert_manifest(
    manifest, objects$plan, objects$generator, objects$environment
  ))
  expect_s3_class(manifest, "mfrmr_gtvf_manifest")
  expect_identical(manifest$PlanHash, objects$plan$PlanHash)
  expect_identical(
    manifest$GeneratorManifestHash, objects$generator$ManifestHash
  )
  expect_true(manifest$PlanIdentityReady)
  expect_true(manifest$GeneratorPreflightReady)
  expect_false(manifest$ExternalFreezeReady)
  expect_false(manifest$CleanSourceIdentityReady)
  expect_false(manifest$IndependentAccuracyRuleReady)
  expect_false(manifest$TruthBlindProcessBoundaryReady)
  expect_false(manifest$BackendQualificationReady)
  expect_false(manifest$PilotExecutionAuthorized)
  expect_false(manifest$ConfirmationExecutionAuthorized)
  expect_false(manifest$NegativeControlExecutionAuthorized)
  expect_true(manifest$ExecutionGateClosed)
  expect_false(manifest$BackendExecutionOccurred)
  expect_false(manifest$PlannedResponseGenerated)
  expect_false(manifest$RecoveryExecuted)
  expect_false(manifest$RecoveryEvidenceReady)
  expect_false(manifest$EstimationReady)
  expect_false(manifest$InferenceReady)
  expect_false(manifest$DecisionReady)
  expect_false(manifest$PublicSupportReady)
})

test_that("Draft.85c3 rejects rehashed readiness and evidence mutation", {
  env <- load_gtheory_multivariate_admission()
  objects <- gtvf_objects(env)
  manifest <- objects$manifest

  changed <- manifest
  changed$PilotExecutionAuthorized <- TRUE
  expect_error(env$mfrmr_gtvf_assert_manifest(
    changed, objects$plan, objects$generator, objects$environment
  ), "admission manifest")

  changed <- manifest
  changed$AuthorityTemplates$AuthorityReady[[1L]] <- TRUE
  changed$AuthorityTemplates$ExecutionAuthorized[[1L]] <- TRUE
  changed$PolicyHash <- env$mfrmr_gta_hash(unclass(changed[seq_len(13L)]))
  expect_error(env$mfrmr_gtvf_assert_manifest(
    changed, objects$plan, objects$generator, objects$environment
  ), "admission manifest")

  changed <- manifest
  changed$EnvironmentSnapshot$DependencyABIMatch <- TRUE
  changed$EnvironmentSnapshot$SnapshotHash <- env$mfrmr_gta_hash(
    changed$EnvironmentSnapshot[seq_len(14L)]
  )
  expect_error(env$mfrmr_gtvf_assert_manifest(
    changed, objects$plan, objects$generator, objects$environment
  ), "admission manifest")
})

test_that("Draft.85c3 blocks callbacks before every planned dispatch", {
  env <- load_gtheory_multivariate_admission()
  objects <- gtvf_objects(env)
  called <- 0L
  callback <- function() {
    called <<- called + 1L
    "unexpected"
  }

  expect_error(env$mfrmr_gtvf_dispatch_guard(
    objects$manifest, "pilot", "lme4_ml", callback,
    authorize = TRUE, plan = objects$plan,
    generator_manifest = objects$generator,
    current_environment = objects$environment
  ), "blocked before response generation")
  expect_identical(called, 0L)
  expect_error(env$mfrmr_gtvf_dispatch_guard(
    objects$manifest, "confirmation", "glmmTMB_reml", callback,
    authorize = FALSE, plan = objects$plan,
    generator_manifest = objects$generator,
    current_environment = objects$environment
  ), "blocked before response generation")
  expect_identical(called, 0L)
  expect_error(env$mfrmr_gtvf_dispatch_guard(
    objects$manifest, "negative_control", "ConQuest", callback,
    authorize = TRUE, plan = objects$plan,
    generator_manifest = objects$generator,
    current_environment = objects$environment
  ), "outside the Draft.85c3 estimand")
  expect_identical(called, 0L)
})

test_that("Draft.85c3 carries no planned seed or outcome payload", {
  env <- load_gtheory_multivariate_admission()
  objects <- gtvf_objects(env)
  manifest <- objects$manifest
  recursive_names <- function(value) {
    own <- names(value)
    children <- if (is.list(value)) {
      unlist(lapply(value, recursive_names), use.names = FALSE)
    } else character()
    c(own, children)
  }
  all_names <- recursive_names(unclass(manifest))
  forbidden <- c(
    "DataSeed", "FixtureSeed", "CandidateData", "TruthAudit", "Score",
    "ReferenceId", "ScenarioId", "RecoveryResult"
  )
  expect_false(any(forbidden %in% all_names))
  expect_false(manifest$PlannedSeedMaterialIncluded)
  numeric_values <- suppressWarnings(as.numeric(unlist(
    manifest, recursive = TRUE, use.names = FALSE
  )))
  numeric_values <- numeric_values[is.finite(numeric_values)]
  expect_false(any(numeric_values >= 851000000 & numeric_values <= 853999999))
  expect_false(manifest$ConQuestRouteIncluded)
})

test_that("Draft.85c3 implementation and public boundaries stay closed", {
  env <- load_gtheory_multivariate_admission()
  objects <- gtvf_objects(env)
  implementation <- objects$manifest$ImplementationIdentity
  expect_identical(nrow(implementation), 16L)
  expect_false(anyDuplicated(implementation$Function) > 0L)
  expect_true(all(nchar(implementation$SHA256) == 64L))
  function_text <- vapply(implementation$Function, function(name) {
    paste(deparse(body(get(name, envir = env))), collapse = "\n")
  }, character(1L))
  expect_false(any(grepl("glmmTMB::glmmTMB|lme4::lmer|system2\\(",
                         function_text)))

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
  expect_false(any(grepl("Draft\\.85c3|mfrmr_gtvf_", public_text)))
})
