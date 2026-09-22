gtheory_lme4_reference_coverage_paths <- function() {
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
      "gtheory-weak-information-glmmtmb-ml-reference-coverage-0.2.3.R",
      paste0(
        "gtheory-weak-information-lme4-objective-reference-",
        "preflight-0.2.3.R"
      ),
      "gtheory-weak-information-lme4-reference-coverage-0.2.3.R"
    )
  )
}

load_gtheory_lme4_reference_coverage <- function() {
  paths <- gtheory_lme4_reference_coverage_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  for (package in c(
    "digest", "lme4", "Matrix", "glmmTMB", "TMB", "minqa", "nloptr",
    "numDeriv"
  )) {
    skip_if_not_installed(package)
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtheory_lme4_reference_coverage_objects <- function(env) {
  plan <- env$mfrmr_gtwp_plan()
  design <- env$mfrmr_gtwsz_contract(plan)
  design_manifest <- env$mfrmr_gtwsz_manifest(design, plan)
  reference <- env$mfrmr_gtwta_contract(design)
  reference_manifest <- env$mfrmr_gtwta_manifest(reference)
  authorization_audit <- env$mfrmr_gtwaa_contract(
    design, design_manifest, reference, reference_manifest
  )
  ml_coverage <- env$mfrmr_gtwab_contract(
    authorization_audit, reference
  )
  objective_preflight <- env$mfrmr_gtwac_contract(ml_coverage)
  coverage <- env$mfrmr_gtwad_contract(objective_preflight)
  manifest <- env$mfrmr_gtwad_manifest(coverage)
  list(
    Plan = plan, Design = design, DesignManifest = design_manifest,
    Reference = reference, ReferenceManifest = reference_manifest,
    AuthorizationAudit = authorization_audit, MLCoverage = ml_coverage,
    ObjectivePreflight = objective_preflight,
    Coverage = coverage, Manifest = manifest
  )
}

test_that("b1g10 freezes a box-constrained lme4 policy", {
  env <- load_gtheory_lme4_reference_coverage()
  contract <- gtheory_lme4_reference_coverage_objects(env)$Coverage
  policy <- contract$Policy

  expect_identical(contract$Backend, "lme4")
  expect_identical(contract$MethodIds, c("lme4_ml", "lme4_reml"))
  expect_identical(contract$Likelihoods, c("ML", "REML"))
  expect_identical(
    contract$Coordinate,
    "nonnegative_relative_standard_deviation_theta"
  )
  expect_identical(
    policy$SolverAlgorithms, c("nlminb", "L-BFGS-B", "bobyqa")
  )
  expect_identical(
    policy$BoundaryThetaFractions,
    c(1, 0.75, 0.5, 0.25, 0.1, 0.025, 0)
  )
  expect_false(contract$FirstOrderBoundarySufficiencyClaim)
  expect_false(policy$BoundaryFirstOrderSufficiencyClaim)
  expect_true(contract$BoxConstrainedSolverReady)
  expect_true(contract$BoundaryProfileMechanicsReady)
  expect_true(contract$NonreservedLme4ReplayAuthorized)
  expect_false(contract$NonreservedLme4ReplayReady)
  expect_false(contract$CalibrationAuthorizationReady)
  expect_false(contract$CalibrationExecutionAuthorized)
  expect_false(contract$InferenceReady)
})

test_that("b1g10 analytic fixtures distinguish boundary mechanisms", {
  env <- load_gtheory_lme4_reference_coverage()
  audit <- gtheory_lme4_reference_coverage_objects(env)$Coverage$Audit
  rows <- audit$Rows

  expect_identical(
    rows$Fixture,
    c("interior", "active_linear", "active_even", "boundary_escape")
  )
  expect_true(all(rows$ConsensusPassed))
  expect_true(all(rows$DerivativeAgreementPassed))
  expect_true(all(rows$RawKKTPassed))
  expect_true(all(rows$KKTPassed))
  expect_true(all(rows$FreeCurvatureState == "positive_definite"))
  expect_identical(rows$ActiveCount, c(0L, 1L, 1L, 0L))
  expect_true(all(rows$ParameterMaximumAbsoluteDifference <= 1e-5))
  expect_true(all(rows$StateMatched))
  expect_true(all(rows$ActiveSetMatched))
  expect_true(audit$AnalyticFixtureReady)
  expect_true(audit$BoundaryProfileMechanicsReady)
  expect_true(all(diff(audit$ProfileRows$Objective) >= 0))
  expect_identical(tail(audit$ProfileRows$TargetTheta, 1L), 0)
})

test_that("b1g10 sparse oracle reduces exactly to the dense oracle", {
  env <- load_gtheory_lme4_reference_coverage()
  data <- env$mfrmr_gtwac_fixture_data()
  formula <- Score ~ 1 + (1 | Person) + (1 | Rater)

  for (reml in c(FALSE, TRUE)) {
    fit <- lme4::lmer(formula, data = data, REML = reml)
    theta <- pmax(0.2, lme4::getME(fit, "theta") * c(0.9, 1.1))
    dense <- env$mfrmr_gtwac_dense_oracle(fit, theta, reml)
    sparse <- env$mfrmr_gtwad_sparse_oracle(fit, theta, reml)

    expect_true(dense$Available)
    expect_true(sparse$Available)
    expect_equal(sparse$Objective, dense$Objective, tolerance = 1e-10)
    expect_equal(sparse$Gradient, dense$Gradient, tolerance = 1e-10)
    expect_true(sparse$SparseCholesky)
    expect_true(sparse$FixedEffectsProfiledOut)
    expect_true(sparse$ResidualScaleProfiledOut)
  }
})

test_that("b1g10 keeps raw and curvature-scaled KKT evidence separate", {
  env <- load_gtheory_lme4_reference_coverage()
  policy <- env$mfrmr_gtwad_policy()
  parameter <- c(1, 1)
  gradient <- c(2e-5, 0)
  hessian <- diag(c(100, 1))
  audit <- env$mfrmr_gtwad_kkt_audit(
    parameter, gradient, hessian, c(0, 0), policy
  )

  expect_false(audit$FreeRawFirstOrderPassed)
  expect_true(audit$FreeCurvatureScaledFirstOrderPassed)
  expect_true(audit$FreeFirstOrderPassed)
  expect_false(audit$RawKKTPassed)
  expect_true(audit$KKTPassed)
  expect_false(audit$BoundaryFirstOrderSufficiencyClaim)
})

test_that("b1g10 manifest has exact nonreserved accounting", {
  env <- load_gtheory_lme4_reference_coverage()
  objects <- gtheory_lme4_reference_coverage_objects(env)
  contract <- objects$Coverage
  manifest <- objects$Manifest

  expect_identical(manifest$DatasetCount, 2L)
  expect_identical(manifest$MethodRouteCount, 4L)
  expect_identical(manifest$ObjectiveCount, 8L)
  expect_identical(manifest$PlannedObjectiveSolverRunCount, 72L)
  expect_identical(manifest$PlannedProfileSolverRunCount, 84L)
  expect_setequal(manifest$Rows$MethodId, c("lme4_ml", "lme4_reml"))
  expect_setequal(manifest$Rows$Replicate, c(901L, 902L))
  expect_false(any(manifest$Rows$Replicate %in% contract$ReservedReplicates))
  expect_equal(anyDuplicated(manifest$Rows$RouteId), 0L)
  expect_true(env$mfrmr_gtwad_manifest_hash_valid(manifest))
  expect_true(manifest$ExecutionAuthorized)
  expect_false(manifest$CalibrationUse)

  changed <- manifest
  changed$Rows$REMLArgument[[1L]] <- TRUE
  expect_false(env$mfrmr_gtwad_manifest_hash_valid(changed))
})

test_that("retained b1g10 lme4 replay closes all four method lanes", {
  path <- Sys.getenv(
    "MFRMR_GTHEORY_LME4_REFERENCE_REPLAY_RDS",
    "/private/tmp/mfrmr-gtwad-lme4-reference-replay-v4.rds"
  )
  skip_if_not(file.exists(path), "retained b1g10 replay is unavailable")
  env <- load_gtheory_lme4_reference_coverage()
  execution <- readRDS(path)

  expect_true(env$mfrmr_gtwad_execution_hash_valid(execution))
  expect_true(execution$ExactAccountingPassed)
  expect_identical(execution$FitReturnCount, 8L)
  expect_identical(execution$ReferenceResolvedCount, 8L)
  expect_identical(execution$ConsensusPassCount, 8L)
  expect_identical(execution$DerivativeAgreementPassCount, 8L)
  expect_identical(execution$RawKKTPassCount, 8L)
  expect_identical(execution$KKTPassCount, 8L)
  expect_identical(execution$BoundaryProfilePassCount, 4L)
  expect_true(execution$SidecarValidationPassed)
  expect_true(execution$NonreservedLme4ReplayReady)
  expect_true(execution$Lme4MLReferenceMechanicsReady)
  expect_true(execution$Lme4REMLReferenceMechanicsReady)
  expect_identical(execution$ReferenceReadyMethodCount, 4L)
  expect_true(execution$ReferenceMethodCoverageComplete)
  expect_false(execution$CalibrationAuthorizationReady)
  expect_false(execution$CalibrationExecutionAuthorized)
  expect_false(execution$InferenceReady)
  expect_true(all(execution$Rows$ReferenceState ==
                    "finite_box_local_minimum"))
  expect_true(all(execution$Rows$IndependentOracleAvailable))
  expect_true(all(execution$Rows$IndependentOracleObjectivePassed))
  expect_true(all(execution$Rows$IndependentOracleGradientPassed))
  expect_true(all(execution$Rows$RawKKTPassed))
  expect_true(all(execution$Rows$FreeCurvatureState == "positive_definite"))
  expect_true(all(
    execution$Rows$IndependentOracleObjectiveAbsoluteDifference < 1e-9
  ))
})

test_that("b1g10 profiles retain nuisance and reduced-model evidence", {
  path <- Sys.getenv(
    "MFRMR_GTHEORY_LME4_REFERENCE_REPLAY_RDS",
    "/private/tmp/mfrmr-gtwad-lme4-reference-replay-v4.rds"
  )
  skip_if_not(file.exists(path), "retained b1g10 replay is unavailable")
  execution <- readRDS(path)
  full <- which(execution$Rows$ModelRole == "full")

  expect_identical(length(full), 4L)
  expect_true(all(
    execution$Rows$BoundaryState[full] == "finite_interior_supported"
  ))
  expect_true(all(execution$Rows$BoundaryReducedObjectiveMatched[full]))
  expect_true(all(
    execution$Rows$BoundaryReducedObjectiveDifference[full] < 1e-9
  ))
  for (index in full) {
    profile <- execution$Sidecars[[index]]$BoundaryProfile
    expect_identical(nrow(profile), 7L)
    expect_identical(profile$Fraction, c(1, 0.75, 0.5, 0.25, 0.1, 0.025, 0))
    expect_true(all(profile$Returned))
    expect_true(all(profile$ConsensusPassed))
    expect_true(all(profile$NuisanceKKTPassed))
    expect_true(all(profile$NuisanceNewtonDecrementPassed))
    expect_true(all(profile$NuisanceCurvatureState == "positive_definite"))
    expect_true(all(diff(profile$Objective) >= -1e-8))
    expect_identical(tail(profile$TargetTheta, 1L), 0)
  }
})

test_that("b1g10 rejects unsupported oracle inputs and upstream mutation", {
  env <- load_gtheory_lme4_reference_coverage()
  objects <- gtheory_lme4_reference_coverage_objects(env)
  data <- env$mfrmr_gtwac_fixture_data()
  formula <- Score ~ 1 + (1 | Person) + (1 | Rater)
  weighted <- lme4::lmer(
    formula, data = data, REML = FALSE,
    weights = seq(0.75, 1.25, length.out = nrow(data))
  )

  expect_error(
    env$mfrmr_gtwad_sparse_oracle(
      weighted, lme4::getME(weighted, "theta"), FALSE
    ),
    "zero-offset unweighted independent random intercepts only"
  )
  changed <- objects$ObjectivePreflight
  changed$ContractHash <- paste0("x", substring(changed$ContractHash, 2L))
  expect_error(
    env$mfrmr_gtwad_contract(changed), "exact non-authorizing b1g9"
  )
})

test_that("b1g10 identities and complete replay reproduce exactly", {
  env <- load_gtheory_lme4_reference_coverage()
  objects <- gtheory_lme4_reference_coverage_objects(env)

  expect_identical(
    objects$Coverage$Audit$AuditHash,
    "ec331fe2856fb42014c3bf1939079c90f195f2cfb9dcbcb195af55cc96599c0a"
  )
  expect_identical(
    objects$Coverage$Policy$PolicyHash,
    "9e0031e200739c66bf2510c56068bbf4f3e1f9075669167becced7ec7f158a82"
  )
  expect_identical(
    objects$Coverage$ContractHash,
    "419fbf43fd1b86ab494aa96224916c0bfa9c1e1ef2668f8877d9d39659bcc7e0"
  )
  expect_identical(
    objects$Manifest$ManifestHash,
    "f26d4a2fe5670d9b9395f97669f0ef368f9c5067580394ff5b20acccf5e8580b"
  )
  primary_path <- Sys.getenv(
    "MFRMR_GTHEORY_LME4_REFERENCE_REPLAY_RDS",
    "/private/tmp/mfrmr-gtwad-lme4-reference-replay-v4.rds"
  )
  repeat_path <- Sys.getenv(
    "MFRMR_GTHEORY_LME4_REFERENCE_REPEAT_RDS",
    "/private/tmp/mfrmr-gtwad-lme4-reference-replay-v5.rds"
  )
  skip_if_not(all(file.exists(c(primary_path, repeat_path))),
              "paired b1g10 replays are unavailable")
  primary <- readRDS(primary_path)
  repeated <- readRDS(repeat_path)
  expect_identical(
    primary$ExecutionHash,
    "b84c1d53f8653bb5329a0a165e2249b36e5d12e10c26099ab15cbdfac4281e8a"
  )
  expect_identical(repeated$Rows, primary$Rows)
  expect_identical(repeated$SidecarHashes, primary$SidecarHashes)
  expect_identical(repeated$ExecutionHash, primary$ExecutionHash)
})
