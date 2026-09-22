gtheory_glmmtmb_ml_reference_coverage_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-balanced-estimation-prototype-0.2.3.R",
      "gtheory-design-incidence-audit-0.2.3.R",
      "gtheory-covariance-information-audit-0.2.3.R",
      "gtheory-glmmtmb-parity-prototype-0.2.3.R",
      "gtheory-ademp-registry-prototype-0.2.3.R",
      "gtheory-ademp-generator-prototype-0.2.3.R",
      "gtheory-ademp-prefit-prototype-0.2.3.R",
      "gtheory-ademp-fit-prototype-0.2.3.R",
      "gtheory-weak-information-calibration-prototype-0.2.3.R",
      "gtheory-weak-information-pilot-prototype-0.2.3.R",
      "gtheory-weak-information-diagnostic-refit-prototype-0.2.3.R",
      "gtheory-weak-information-bootstrap-prototype-0.2.3.R",
      "gtheory-weak-information-feasibility-prototype-0.2.3.R",
      "gtheory-weak-information-feasibility-runner-0.2.3.R",
      "gtheory-weak-information-numerical-sensitivity-0.2.3.R",
      "gtheory-weak-information-typed-replay-0.2.3.R",
      "gtheory-weak-information-glmmtmb-stabilization-prototype-0.2.3.R",
      paste0(
        "gtheory-weak-information-glmmtmb-stationarity-",
        "instrumentation-0.2.3.R"
      ),
      paste0(
        "gtheory-weak-information-glmmtmb-stationarity-calibration-",
        "design-0.2.3.R"
      ),
      paste0(
        "gtheory-weak-information-glmmtmb-stationarity-reference-",
        "calibration-0.2.3.R"
      ),
      paste0(
        "gtheory-weak-information-stationarity-calibration-",
        "authorization-audit-0.2.3.R"
      ),
      "gtheory-weak-information-glmmtmb-ml-reference-coverage-0.2.3.R"
    )
  )
}

load_gtheory_glmmtmb_ml_reference_coverage <- function() {
  paths <- gtheory_glmmtmb_ml_reference_coverage_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  for (package in c(
    "digest", "lme4", "glmmTMB", "TMB", "minqa", "nloptr", "numDeriv"
  )) {
    skip_if_not_installed(package)
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtheory_glmmtmb_ml_reference_coverage_objects <- function(env) {
  plan <- env$mfrmr_gtwp_plan()
  design <- env$mfrmr_gtwsz_contract(plan)
  design_manifest <- env$mfrmr_gtwsz_manifest(design, plan)
  reference <- env$mfrmr_gtwta_contract(design)
  reference_manifest <- env$mfrmr_gtwta_manifest(reference)
  audit <- env$mfrmr_gtwaa_contract(
    design, design_manifest, reference, reference_manifest
  )
  coverage <- env$mfrmr_gtwab_contract(audit, reference)
  manifest <- env$mfrmr_gtwab_manifest(coverage)
  list(
    Plan = plan, Design = design, DesignManifest = design_manifest,
    Reference = reference, ReferenceManifest = reference_manifest,
    Audit = audit, Coverage = coverage, Manifest = manifest
  )
}

test_that("b1g8 freezes a distinct glmmTMB ML objective identity", {
  env <- load_gtheory_glmmtmb_ml_reference_coverage()
  objects <- gtheory_glmmtmb_ml_reference_coverage_objects(env)
  contract <- objects$Coverage

  expect_identical(contract$Backend, "glmmTMB")
  expect_identical(contract$MethodId, "glmmTMB_ml")
  expect_identical(contract$Likelihood, "ML")
  expect_identical(contract$GlmmTMBREMLArgument, FALSE)
  expect_true(contract$B1g6MechanicsBound)
  expect_true(contract$MLObjectiveIdentityFrozen)
  expect_true(contract$NonreservedMLReplayAuthorized)
  expect_false(contract$NonreservedMLReplayReady)
  expect_false(contract$CalibrationAuthorizationReady)
  expect_false(contract$CalibrationExecutionAuthorized)
  expect_false(contract$ConfirmationReplicatesMayBeRead)
  expect_false(contract$InferenceReady)
  expect_identical(
    contract$TolerancePolicyHash,
    env$mfrmr_gta_hash(objects$Reference$TolerancePolicy)
  )
  expect_true(any(grepl(
    "glmmtmb.*reference/glmmTMB.html", contract$Sources$Locator,
    ignore.case = TRUE
  )))
})

test_that("b1g8 manifest cannot collide with a reserved phase", {
  env <- load_gtheory_glmmtmb_ml_reference_coverage()
  objects <- gtheory_glmmtmb_ml_reference_coverage_objects(env)
  contract <- objects$Coverage
  manifest <- objects$Manifest

  expect_identical(manifest$DatasetCount, 2L)
  expect_identical(manifest$ObjectiveCount, 4L)
  expect_identical(manifest$PlannedSolverRunCount, 36L)
  expect_true(all(manifest$Rows$MethodId == "glmmTMB_ml"))
  expect_true(all(manifest$Rows$Likelihood == "ML"))
  expect_false(any(manifest$Rows$GlmmTMBREMLArgument))
  expect_setequal(manifest$Rows$Replicate, c(901L, 902L))
  expect_false(any(
    manifest$Rows$Replicate %in% contract$ReservedReplicates
  ))
  expect_equal(anyDuplicated(manifest$Rows$RouteId), 0L)
  expect_true(env$mfrmr_gtwab_manifest_hash_valid(manifest))
  expect_true(manifest$ExecutionAuthorized)
  expect_false(manifest$CalibrationUse)
  expect_false(manifest$DataGenerated)
  expect_false(manifest$ResultsViewed)

  changed <- manifest
  changed$Rows$GlmmTMBREMLArgument[[1L]] <- TRUE
  expect_false(env$mfrmr_gtwab_manifest_hash_valid(changed))
})

test_that("b1g8 coverage accounting remains method-specific", {
  env <- load_gtheory_glmmtmb_ml_reference_coverage()
  before <- env$mfrmr_gtwab_coverage_ledger(FALSE)
  after <- env$mfrmr_gtwab_coverage_ledger(TRUE)

  expect_identical(sum(before$ReferenceMechanicsReady), 1L)
  expect_identical(sum(after$ReferenceMechanicsReady), 2L)
  expect_true(after$ReferenceMechanicsReady[
    after$MethodId == "glmmTMB_ml"
  ])
  expect_true(after$ReferenceMechanicsReady[
    after$MethodId == "glmmTMB_reml"
  ])
  expect_false(any(after$ReferenceMechanicsReady[after$Backend == "lme4"]))
  expect_false(any(after$CalibrationExecutionAuthorized))
})

test_that("retained b1g8 ML replay validates when available", {
  path <- Sys.getenv(
    "MFRMR_GTHEORY_GLMMTMB_ML_REFERENCE_REPLAY_RDS",
    "/private/tmp/mfrmr-gtwab-ml-reference-replay-v1.rds"
  )
  skip_if_not(file.exists(path), "retained b1g8 ML replay is unavailable")
  env <- load_gtheory_glmmtmb_ml_reference_coverage()
  execution <- readRDS(path)

  expect_true(env$mfrmr_gtwab_execution_hash_valid(execution))
  expect_true(execution$ExactAccountingPassed)
  expect_identical(execution$FitReturnCount, 4L)
  expect_identical(execution$ReferenceResolvedCount, 4L)
  expect_identical(execution$ConsensusPassCount, 4L)
  expect_identical(execution$DerivativeAgreementPassCount, 4L)
  expect_identical(execution$BoundaryProfilePassCount, 2L)
  expect_true(execution$SidecarValidationPassed)
  expect_true(execution$NonreservedMLReplayReady)
  expect_true(execution$GlmmTMBMethodCoverageReady)
  expect_identical(execution$ReferenceReadyMethodCount, 2L)
  expect_false(execution$ReferenceMethodCoverageComplete)
  expect_false(execution$CalibrationAuthorizationReady)
  expect_false(execution$CalibrationExecutionAuthorized)
  expect_false(execution$InferenceReady)
  expect_true(all(execution$Rows$Likelihood == "ML"))
  expect_false(any(execution$Rows$GlmmTMBREMLArgument))
  expect_true(all(
    execution$Rows$ReferenceState == "finite_local_minimum"
  ))
  expect_true(all(
    execution$Rows$CurvatureState == "positive_definite"
  ))
  expect_true(all(vapply(execution$Sidecars, function(sidecar) {
    identical(sidecar$FitCallIdentity$Backend, "glmmTMB") &&
      identical(sidecar$FitCallIdentity$Likelihood, "ML") &&
      identical(sidecar$FitCallIdentity$REML, FALSE) &&
      identical(sidecar$InnerMethod, "newton") &&
      identical(sidecar$InnerControl, list(maxit = 1000, trace = FALSE)) &&
      isTRUE(sidecar$ResetRandomStartBeforeEveryEvaluation)
  }, logical(1L))))
  full_sidecars <- execution$Sidecars[execution$Rows$ModelRole == "full"]
  expect_true(all(vapply(full_sidecars, function(sidecar) {
    nrow(sidecar$BoundaryProfile) == 6L &&
      all(sidecar$BoundaryProfile$Returned) &&
      all(sidecar$BoundaryProfile$NuisanceStationarityPassed)
  }, logical(1L))))

  changed <- execution
  changed$Rows$Likelihood[[1L]] <- "REML"
  expect_false(env$mfrmr_gtwab_execution_hash_valid(changed))
})

test_that("b1g8 uses the b1g6 data but a distinct likelihood surface", {
  ml_path <- Sys.getenv(
    "MFRMR_GTHEORY_GLMMTMB_ML_REFERENCE_REPLAY_RDS",
    "/private/tmp/mfrmr-gtwab-ml-reference-replay-v1.rds"
  )
  reml_path <- Sys.getenv(
    "MFRMR_GTHEORY_GLMMTMB_REFERENCE_REPLAY_RDS",
    "/private/tmp/mfrmr-gtwta-reference-replay-v4.rds"
  )
  skip_if_not(all(file.exists(c(ml_path, reml_path))),
              "paired ML/REML reference replays are unavailable")
  ml <- readRDS(ml_path)
  reml <- readRDS(reml_path)

  expect_identical(ml$GeneratorHashes, reml$GeneratorHashes)
  key_ml <- paste(ml$Rows$DatasetId, ml$Rows$ModelRole)
  key_reml <- paste(reml$Rows$DatasetId, reml$Rows$ModelRole)
  expect_setequal(key_ml, key_reml)
  reml_objective <- reml$Rows$PolishedObjective[match(key_ml, key_reml)]
  expect_true(all(is.finite(reml_objective)))
  expect_true(all(abs(
    ml$Rows$PolishedObjective - reml_objective
  ) > 1e-3))
})

test_that("b1g8 identities are reproducible", {
  env <- load_gtheory_glmmtmb_ml_reference_coverage()
  objects <- gtheory_glmmtmb_ml_reference_coverage_objects(env)

  expect_identical(
    objects$Coverage$ContractHash,
    "1216ae3591fc026a61b4fb6581ebe79e33d34e4e2b6bf04a969a4c93c3e06689"
  )
  expect_identical(
    objects$Manifest$ManifestHash,
    "2974db4aefd07636d286b8227edb6dd50b481764e9dd7060296bd379a2688434"
  )
  path <- Sys.getenv(
    "MFRMR_GTHEORY_GLMMTMB_ML_REFERENCE_REPLAY_RDS",
    "/private/tmp/mfrmr-gtwab-ml-reference-replay-v1.rds"
  )
  if (file.exists(path)) {
    expect_identical(
      readRDS(path)$ExecutionHash,
      "46ea4be751a3c54904bac28da31f15e5e05f347b9e8f10a1194887f55557807d"
    )
  }
})
