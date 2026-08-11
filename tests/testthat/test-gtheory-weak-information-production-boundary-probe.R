gtheory_production_boundary_probe_paths <- function() {
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
      "gtheory-weak-information-lme4-reference-coverage-0.2.3.R",
      paste0(
        "gtheory-weak-information-stationarity-acceptance-policy-",
        "0.2.3.R"
      ),
      "gtheory-weak-information-production-boundary-probe-0.2.3.R"
    )
  )
}

load_gtheory_production_boundary_probe <- function() {
  paths <- gtheory_production_boundary_probe_paths()
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

gtheory_production_boundary_probe_objects <- function(env) {
  plan <- env$mfrmr_gtwp_plan()
  design <- env$mfrmr_gtwsz_contract(plan)
  design_manifest <- env$mfrmr_gtwsz_manifest(design, plan)
  reference <- env$mfrmr_gtwta_contract(design)
  reference_manifest <- env$mfrmr_gtwta_manifest(reference)
  authorization_audit <- env$mfrmr_gtwaa_contract(
    design, design_manifest, reference, reference_manifest
  )
  ml_coverage <- env$mfrmr_gtwab_contract(authorization_audit, reference)
  objective_preflight <- env$mfrmr_gtwac_contract(ml_coverage)
  lme4_coverage <- env$mfrmr_gtwad_contract(objective_preflight)
  acceptance <- env$mfrmr_gtwae_contract(lme4_coverage)
  probe <- env$mfrmr_gtwaf_contract(acceptance)
  list(
    Plan = plan, Design = design, Acceptance = acceptance, Probe = probe
  )
}

test_that("b1g12 freezes backend-coordinate and endpoint contracts", {
  env <- load_gtheory_production_boundary_probe()
  policy <- env$mfrmr_gtwaf_policy()

  expect_identical(
    policy$Lme4Coordinate,
    "nonnegative_relative_standard_deviation_theta"
  )
  expect_identical(
    policy$GlmmTMBCoordinate,
    "unconstrained_log_standard_deviation"
  )
  expect_identical(
    policy$Lme4ThetaFractions,
    c(1, 0.75, 0.5, 0.25, 0.1, 0.025, 0)
  )
  expect_identical(policy$GlmmTMBLogSdOffsets, c(0, 4, 8, 12, 16, 20))
  expect_true(policy$NuisanceReoptimizationRequired)
  expect_true(policy$EndpointReductionRequired)
  expect_true(policy$ReducedObjectiveRequired)
  expect_false(policy$FirstOrderBoundarySufficiencyClaim)
  expect_false(policy$GeneratingTruthUsed)
  expect_false(policy$CandidateCutoffUsed)
  expect_false(policy$CalibrationResponsesUsed)
  expect_true(env$mfrmr_gtwaf_policy_hash_valid(policy))
})

test_that("b1g12 analytic controls recover four distinct probe states", {
  env <- load_gtheory_production_boundary_probe()
  audit <- env$mfrmr_gtwaf_analytic_audit()
  rows <- audit$Rows

  expect_identical(nrow(rows), 7L)
  expect_true(all(rows$StateMatched))
  expect_true(all(rows$Available))
  expect_true(all(!rows$FirstOrderBoundarySufficiencyClaim))
  expect_true(all(!rows$GeneratingTruthUsed))
  expect_true(audit$AnalyticStateRecoveryReady)
  expect_true(audit$CoordinateEndpointsReady)
  expect_true(audit$TruthBlindReady)
  expect_identical(audit$ThetaBoundaryEndpoint, 0)
  expect_identical(audit$LogSdBoundaryEndpoint, -21)
  expect_identical(audit$FailureState, "not_evaluable")
  expect_identical(audit$FailureApplicationState, "not_evaluable")
  expect_setequal(
    unique(rows$State),
    c(
      "boundary_limit_supported", "finite_interior_supported",
      "boundary_probe_inconclusive"
    )
  )
})

test_that("b1g12 requires monotone material direction and endpoint match", {
  env <- load_gtheory_production_boundary_probe()
  boundary <- env$mfrmr_gtwaf_probe(
    function(value) value[[1L]]^2 + (value[[2L]] - 2)^2,
    c(0.5, 0), 1L, 0, "theta", c(0, -Inf)
  )
  interior <- env$mfrmr_gtwaf_probe(
    function(value) (value[[1L]] - 1)^2 + (value[[2L]] - 2)^2,
    c(1, 0), 1L, 1, "theta", c(0, -Inf)
  )
  mismatch <- env$mfrmr_gtwaf_probe(
    function(value) value[[1L]]^2 + (value[[2L]] - 2)^2,
    c(0.5, 0), 1L, 1, "theta", c(0, -Inf)
  )

  expect_identical(boundary$State, "boundary_limit_supported")
  expect_identical(boundary$ApplicationState, "boundary_handoff")
  expect_true(boundary$MonotoneImprovementTowardBoundary)
  expect_true(boundary$MaterialImprovementTowardBoundary)
  expect_true(boundary$ReducedEndpointMatched)
  expect_true(env$mfrmr_gtwaf_probe_hash_valid(boundary))
  expect_identical(interior$State, "finite_interior_supported")
  expect_identical(
    interior$ApplicationState, "continue_first_order_curvature"
  )
  expect_true(interior$MonotoneWorseningTowardBoundary)
  expect_true(interior$MaterialWorseningTowardBoundary)
  expect_identical(mismatch$State, "boundary_probe_inconclusive")
  expect_identical(mismatch$ApplicationState, "indeterminate")
  expect_false(mismatch$ReducedEndpointMatched)
})

test_that("b1g12 fails closed on invalid coordinates and reduced endpoints", {
  env <- load_gtheory_production_boundary_probe()
  fn <- function(value) sum(value^2)

  expect_error(
    env$mfrmr_gtwaf_probe(fn, c(1, 1), 0L, 0, "theta", c(0, 0)),
    "valid target"
  )
  expect_error(
    env$mfrmr_gtwaf_probe(fn, c(1, 1), 1L, NA, "theta", c(0, 0)),
    "finite reduced-model"
  )
  expect_error(
    env$mfrmr_gtwaf_probe(fn, c(1, 1), 1L, 0, "theta", c(-Inf, 0)),
    "exact-zero lower"
  )
  expect_error(
    env$mfrmr_gtwaf_probe(fn, c(1, 1), 1L, 0, "log_sd", c(0, -Inf)),
    "must not have a finite lower"
  )
  expect_error(
    env$mfrmr_gtwaf_probe(fn, c(1, 1), 1L, 0, "theta", c(0, 0, 0)),
    "scalar or match"
  )
  mutated_policy <- env$mfrmr_gtwaf_policy()
  mutated_policy$SolverFactr <- mutated_policy$SolverFactr * 2
  expect_false(env$mfrmr_gtwaf_policy_hash_valid(mutated_policy))
  expect_error(
    env$mfrmr_gtwaf_probe(
      fn, c(1, 1), 1L, 0, "theta", c(0, 0), mutated_policy
    ),
    "frozen b1g12 policy"
  )
  reduced <- env$mfrmr_gtwaf_not_applicable()
  expect_identical(reduced$State, "not_applicable")
  expect_identical(reduced$ApplicationState, "not_applicable")
  expect_false(reduced$FirstOrderBoundarySufficiencyClaim)
  expect_true(env$mfrmr_gtwaf_probe_hash_valid(reduced))
  expect_error(env$mfrmr_gtwaf_not_applicable("full"), "Only a reduced")
})

test_that("b1g12 lme4 ML and REML probes reach exact reduced endpoints", {
  env <- load_gtheory_production_boundary_probe()
  data <- env$mfrmr_gtwac_fixture_data()
  full_formula <- Score ~ 1 + (1 | Person) + (1 | Rater)
  reduced_formula <- Score ~ 1 + (1 | Person)

  for (reml in c(FALSE, TRUE)) {
    full <- env$mfrmr_gtwad_fit_objective(full_formula, data, reml)
    reduced <- env$mfrmr_gtwad_fit_objective(reduced_formula, data, reml)
    probe <- env$mfrmr_gtwaf_probe_lme4(full, reduced, "Rater")

    expect_identical(probe$Backend, "lme4")
    expect_identical(probe$Coordinate, "theta")
    expect_true(probe$Available)
    expect_true(probe$ReducedEndpointMatched)
    expect_lte(
      probe$ReducedEndpointAbsoluteDifference,
      probe$ReducedEndpointTolerance
    )
    expect_identical(tail(probe$Rows$TargetValue, 1L), 0)
    expect_true(env$mfrmr_gtwaf_probe_hash_valid(probe))
    expect_false(probe$FirstOrderBoundarySufficiencyClaim)
    expect_false(probe$GeneratingTruthUsed)
    expect_identical(any(probe$Rows$FallbackAttempted), isTRUE(reml))
    expect_true(all(
      !probe$Rows$FallbackAttempted | probe$Rows$FallbackReturned
    ))
  }
})

test_that("b1g12 glmmTMB ML and REML probes approach reduced endpoints", {
  env <- load_gtheory_production_boundary_probe()
  data <- env$mfrmr_gtwac_fixture_data()
  full_formula <- Score ~ 1 + (1 | Person) + (1 | Rater)
  reduced_formula <- Score ~ 1 + (1 | Person)

  for (reml in c(FALSE, TRUE)) {
    full <- env$mfrmr_gtwta_fit_objective(full_formula, data, reml)
    reduced <- env$mfrmr_gtwta_fit_objective(reduced_formula, data, reml)
    probe <- env$mfrmr_gtwaf_probe_glmmtmb(full, reduced, "Rater")

    expect_identical(probe$Backend, "glmmTMB")
    expect_identical(probe$Coordinate, "log_sd")
    expect_true(probe$Available)
    expect_true(probe$ReducedEndpointMatched)
    expect_lte(
      probe$ReducedEndpointAbsoluteDifference,
      probe$ReducedEndpointTolerance
    )
    expect_equal(
      probe$InitialTargetValue - tail(probe$Rows$TargetValue, 1L), 20,
      tolerance = 1e-12
    )
    expect_true(env$mfrmr_gtwaf_probe_hash_valid(probe))
    expect_false(probe$FirstOrderBoundarySufficiencyClaim)
    expect_false(probe$GeneratingTruthUsed)
  }
})

test_that("b1g12 contract advances only production probe readiness", {
  env <- load_gtheory_production_boundary_probe()
  objects <- gtheory_production_boundary_probe_objects(env)
  contract <- objects$Probe

  expect_identical(
    contract$UpstreamB1g11ContractHash,
    "1dcc877da78d3975271b33629b3d67bd9f0f48d675fb1ed62e5704baa46b8b1a"
  )
  expect_true(contract$ProductionBoundaryProbeReady)
  expect_true(contract$BackendCoordinateTranslationReady)
  expect_true(contract$ReducedEndpointMatchRequired)
  expect_true(contract$NuisanceReoptimizationRequired)
  expect_true(contract$InconclusiveStateRetained)
  expect_true(contract$NonEvaluableStateRetained)
  expect_false(contract$FirstOrderBoundarySufficiencyClaim)
  expect_true(contract$AcceptancePolicyFrozen)
  expect_true(contract$ReferenceMethodCoverageComplete)
  expect_false(contract$RunnerImplementationReady)
  expect_false(contract$CalibrationAuthorizationReady)
  expect_false(contract$CalibrationExecutionAuthorized)
  expect_false(contract$CalibrationDataGenerated)
  expect_false(contract$CalibrationResultsViewed)
  expect_false(contract$StationarityThresholdFrozen)
  expect_false(contract$StationarityCriterionReady)
  expect_false(contract$ConfirmationAuthorized)
  expect_false(contract$InferenceReady)
  expect_false(contract$CoefficientEligible)
  expect_false(contract$DecisionReady)
  expect_true(any(grepl("isSingular", contract$Sources$Locator)))
  expect_true(any(grepl("troubleshooting", contract$Sources$Locator)))

  mutation <- objects$Acceptance
  mutation$ContractHash <- paste0("x", substring(
    mutation$ContractHash, 2L
  ))
  expect_error(
    env$mfrmr_gtwaf_contract(mutation), "exact non-authorizing b1g11"
  )
})

test_that("b1g12 function identities are complete and reproducible", {
  env <- load_gtheory_production_boundary_probe()
  hashes <- env$mfrmr_gtwaf_function_hashes()
  contract <- gtheory_production_boundary_probe_objects(env)$Probe

  expect_identical(length(hashes), 13L)
  expect_equal(anyDuplicated(names(hashes)), 0L)
  expect_true(all(nchar(hashes) == 64L))
  expect_identical(contract$FunctionHashes, hashes)
  expect_identical(contract$Policy$PolicyHash, env$mfrmr_gtwaf_policy()$PolicyHash)
  expect_identical(
    contract$AnalyticAuditHash,
    env$mfrmr_gtwaf_analytic_audit()$AuditHash
  )
})
