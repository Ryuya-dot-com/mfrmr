gtheory_multivariate_backend_qualification_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-execution-admission-preflight-0.2.4.R",
      paste0(
        "gtheory-multivariate-backend-qualification-admission-",
        "preflight-0.2.4.R"
      )
    )
  )
}

load_gtheory_multivariate_backend_qualification <- local({
  environment <- NULL
  function() {
    paths <- gtheory_multivariate_backend_qualification_paths()
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

gtvl_repo_root <- function() {
  testthat::test_path("..", "..")
}

gtvl_objects <- local({
  objects <- NULL
  function(env) {
    if (is.null(objects)) {
      c3 <- env$mfrmr_gtvf_environment_snapshot()
      packages <- env$mfrmr_gtvl_package_registry()
      environment <- env$mfrmr_gtvl_environment_identity(c3, packages)
      manifest <- env$mfrmr_gtvl_manifest(
        gtvl_repo_root(), environment
      )
      objects <<- list(
        c3 = c3, packages = packages, environment = environment,
        manifest = manifest
      )
    }
    objects
  }
})

test_that("Draft.85c4e owns a distinct fifteen-function namespace", {
  env <- load_gtheory_multivariate_backend_qualification()
  identity <- env$mfrmr_gtvl_implementation_identity()
  expect_identical(nrow(identity), 15L)
  expect_identical(anyDuplicated(identity$Function), 0L)
  expect_true(all(grepl("^mfrmr_gtvl_", identity$Function)))
  expect_true(all(nchar(identity$SHA256) == 64L))
})

test_that("Draft.85c4e binds package descriptions and native binaries", {
  env <- load_gtheory_multivariate_backend_qualification()
  registry <- gtvl_objects(env)$packages
  expect_silent(env$mfrmr_gtvl_assert_package_registry(registry))
  expect_identical(registry$PackageOrdinal, 1:3)
  expect_identical(registry$Package, c("lme4", "glmmTMB", "TMB"))
  expect_true(all(registry$Available))
  expect_true(all(file.exists(registry$DescriptionPath)))
  expect_true(all(file.exists(registry$NativeDLLPath)))
  expect_true(all(nchar(registry$DescriptionSHA256) == 64L))
  expect_true(all(nchar(registry$NativeDLLSHA256) == 64L))
  expect_false(anyDuplicated(registry$NativeDLLPath) > 0L)
})

test_that("Draft.85c4e separates package presence, ABI, and eligibility", {
  env <- load_gtheory_multivariate_backend_qualification()
  objects <- gtvl_objects(env)
  identity <- objects$environment
  expect_silent(env$mfrmr_gtvl_assert_environment_identity(identity))
  expect_s3_class(identity, "mfrmr_gtvl_environment")
  expect_identical(
    identity$RequiredPackagesAvailable,
    objects$c3$RequiredPackagesAvailable
  )
  expect_identical(identity$DependencyABIMatch,
                   objects$c3$DependencyABIMatch)
  expect_true(identity$BuildIdentityMatchesLoadedNamespace)
  expect_true(identity$NativeBinaryIdentityReady)
  expect_identical(
    identity$QualificationEnvironmentEligible,
    identity$RequiredPackagesAvailable && identity$DependencyABIMatch &&
      identity$BuildIdentityMatchesLoadedNamespace &&
      identity$NativeBinaryIdentityReady &&
      !is.na(identity$GlmmTMBABIVersion)
  )
  expect_false(identity$DiagnosticOverrideAllowed)
  expect_identical(identity$RepairRequired,
                   !identity$QualificationEnvironmentEligible)
  expect_false(identity$RepairExecuted)
  expect_false(identity$BackendExecutionOccurred)
})

test_that("Draft.85c4e repair plan is declarative and entirely incomplete", {
  env <- load_gtheory_multivariate_backend_qualification()
  plan <- env$mfrmr_gtvl_repair_plan(gtvl_objects(env)$environment)
  expect_identical(plan$StepOrdinal, 1:6)
  expect_identical(plan$StepId, c(
    "isolated_library_created", "package_sources_pinned",
    "selected_tmb_installed", "glmmtmb_rebuilt_against_selected_tmb",
    "fresh_process_identity_reobserved", "four_route_receipts_completed"
  ))
  expect_identical(anyDuplicated(plan$RequiredEvidence), 0L)
  expect_false(any(plan$CurrentSatisfied))
  expect_false(any(plan$MutatingActionExecuted))
})

test_that("Draft.85c4e exposes four empty qualification receipt lanes", {
  env <- load_gtheory_multivariate_backend_qualification()
  identity <- gtvl_objects(env)$environment
  routes <- env$mfrmr_gtvl_route_registry(identity)
  receipts <- env$mfrmr_gtvl_qualification_receipt_template(
    identity, routes
  )
  expect_identical(routes$RouteOrdinal, 1:4)
  expect_identical(routes$RouteId, c(
    "lme4_ml", "lme4_reml", "glmmTMB_ml", "glmmTMB_reml"
  ))
  expect_identical(routes$Criterion, c("ML", "REML", "ML", "REML"))
  expect_identical(routes$RequiresSharedABIMatch,
                   c(FALSE, FALSE, TRUE, TRUE))
  expect_false(any(routes$RouteReceiptReady))
  expect_true(all(is.na(receipts$QualificationReceiptId)))
  expect_true(all(is.na(receipts$FitSpecificationHash)))
  expect_true(all(is.na(receipts$FitResultHash)))
  expect_false(any(receipts$FreshProcess))
  expect_true(all(is.na(receipts$DiagnosticOverrideUsed)))
  expect_false(any(receipts$ReceiptReady))
})

test_that("Draft.85c4e seals current environment and closed readiness", {
  env <- load_gtheory_multivariate_backend_qualification()
  objects <- gtvl_objects(env)
  manifest <- objects$manifest
  expect_silent(env$mfrmr_gtvl_assert_manifest(
    manifest, gtvl_repo_root(), objects$environment
  ))
  expect_s3_class(manifest, "mfrmr_gtvl_manifest")
  expect_true(manifest$SourceFreezeAdmissionBound)
  expect_true(manifest$EnvironmentIdentityMatchesCurrentProcess)
  expect_identical(
    manifest$EnvironmentReadyForBackendQualification,
    objects$environment$QualificationEnvironmentEligible
  )
  expect_true(manifest$RepairPlanConstructed)
  expect_false(manifest$RepairExecuted)
  expect_false(manifest$AllRouteReceiptsReady)
  expect_false(manifest$BackendQualificationAdmissionReady)
  expect_false(manifest$BackendQualificationReady)
  expect_false(manifest$DiagnosticOverrideAllowed)
  expect_true(manifest$ExecutionGateClosed)
  expect_false(manifest$CleanSourceIdentityReady)
  expect_false(manifest$ExternalFreezeReady)
  expect_false(manifest$PlannedSeedMaterialIncluded)
  expect_false(manifest$ConQuestRouteIncluded)
})

test_that("Draft.85c4e refuses synthetic ABI-match promotion", {
  env <- load_gtheory_multivariate_backend_qualification()
  objects <- gtvl_objects(env)
  values <- unclass(objects$c3[c(
    "RVersion", "Platform", "Lme4Available", "Lme4Version",
    "GlmmTMBAvailable", "GlmmTMBVersion", "TMBAvailable", "TMBVersion",
    "GlmmTMBBuildTMBVersion"
  )])
  values$GlmmTMBBuildTMBVersion <- values$TMBVersion
  synthetic_c3 <- env$mfrmr_gtvf_environment_snapshot(values)
  synthetic <- env$mfrmr_gtvl_environment_identity(
    synthetic_c3, objects$packages
  )
  expect_false(synthetic$BuildIdentityMatchesLoadedNamespace)
  expect_false(synthetic$QualificationEnvironmentEligible)
  manifest <- env$mfrmr_gtvl_manifest(gtvl_repo_root(), synthetic)
  expect_false(manifest$CandidateEnvironmentEligible)
  expect_false(manifest$EnvironmentIdentityMatchesCurrentProcess)
  expect_false(manifest$EnvironmentReadyForBackendQualification)
  expect_false(manifest$AllRouteReceiptsReady)
  expect_false(manifest$BackendQualificationAdmissionReady)
  expect_false(manifest$BackendQualificationReady)
  expect_true(manifest$ExecutionGateClosed)
})

test_that("Draft.85c4e rejects binary and manifest mutation", {
  env <- load_gtheory_multivariate_backend_qualification()
  objects <- gtvl_objects(env)
  changed_registry <- objects$packages
  changed_registry$NativeDLLSHA256[[1L]] <- paste(rep("0", 64L), collapse = "")
  expect_error(
    env$mfrmr_gtvl_assert_package_registry(changed_registry),
    "package/native identity was altered"
  )

  changed <- objects$manifest
  changed$BackendQualificationReady <- TRUE
  expect_error(env$mfrmr_gtvl_assert_manifest(
    changed, gtvl_repo_root(), objects$environment
  ), "qualification manifest or readiness was altered")

  changed <- objects$manifest
  changed$UpstreamRootRegistry$SHA256[[2L]] <- paste(
    rep("f", 64L), collapse = ""
  )
  changed$UpstreamRootRegistryHash <- env$mfrmr_gtvl_hash(
    changed$UpstreamRootRegistry
  )
  expect_error(env$mfrmr_gtvl_assert_manifest(
    changed, gtvl_repo_root(), objects$environment
  ), "qualification manifest or readiness was altered")
})

test_that("Draft.85c4e blocks repair and fit callbacks", {
  env <- load_gtheory_multivariate_backend_qualification()
  objects <- gtvl_objects(env)
  state <- new.env(parent = emptyenv())
  state$calls <- 0L
  callback <- function(...) {
    state$calls <- state$calls + 1L
    "unreachable"
  }
  for (action in c("environment_repair", "route_qualification")) {
    for (authorize in c(FALSE, TRUE)) {
      expect_error(env$mfrmr_gtvl_dispatch_guard(
        objects$manifest, action, callback, authorize = authorize,
        repo_root = gtvl_repo_root(),
        environment_identity = objects$environment
      ), "cannot repair or fit a backend")
    }
  }
  expect_error(env$mfrmr_gtvl_dispatch_guard(
    objects$manifest, "ConQuest", callback, authorize = TRUE,
    repo_root = gtvl_repo_root(),
    environment_identity = objects$environment
  ), "outside the admission contract")
  expect_identical(state$calls, 0L)
})

test_that("Draft.85c4e remains internal and carries no execution material", {
  env <- load_gtheory_multivariate_backend_qualification()
  manifest <- gtvl_objects(env)$manifest
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
  all_names <- unique(unlist(lapply(
    unclass(manifest), function(value) {
      if (is.list(value)) names(unlist(value, recursive = TRUE)) else ""
    }
  ), use.names = FALSE))
  expect_false(any(c(
    "DataSeed", "FixtureSeed", "CandidateData", "TruthAudit", "Score"
  ) %in% all_names))

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
  expect_false(any(grepl("Draft\\.85c4e|mfrmr_gtvl_", public_text)))
})
