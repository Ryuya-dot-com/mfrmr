gtheory_lme4_objective_preflight_paths <- function() {
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
      )
    )
  )
}

load_gtheory_lme4_objective_preflight <- function() {
  paths <- gtheory_lme4_objective_preflight_paths()
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

gtheory_lme4_objective_preflight_objects <- function(env) {
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
  preflight <- env$mfrmr_gtwac_contract(ml_coverage)
  list(
    Plan = plan, Design = design, DesignManifest = design_manifest,
    Reference = reference, ReferenceManifest = reference_manifest,
    AuthorizationAudit = authorization_audit, MLCoverage = ml_coverage,
    Preflight = preflight
  )
}

test_that("b1g9 independently identifies lme4 theta-only ML and REML", {
  env <- load_gtheory_lme4_objective_preflight()
  contract <- gtheory_lme4_objective_preflight_objects(env)$Preflight

  expect_identical(
    contract$SupportedStructure,
    paste0(
      "unweighted_zero_offset_independent_random_intercepts_",
      "theta_relative_sd"
    )
  )
  expect_identical(
    contract$MLObjective,
    "minus_two_profiled_ml_loglik_theta_only"
  )
  expect_identical(
    contract$REMLObjective,
    "profiled_reml_criterion_theta_only"
  )
  expect_true(contract$FixedEffectsProfiledOut)
  expect_true(contract$ResidualScaleProfiledOut)
  expect_false(contract$RawMetricPoolingAcrossBackendsAllowed)
  expect_false(contract$GlmmTMBAbsoluteObjectiveComparisonAllowed)
  expect_identical(contract$MLFitCriterionAccessor, "deviance(fit_ml)")
  expect_identical(
    contract$REMLFitCriterionAccessor, "REMLcrit(fit_reml)"
  )
  expect_true(any(grepl("lme4/reference/lmer", contract$Sources$Locator)))
})

test_that("b1g9 dense objectives and gradients agree independently", {
  env <- load_gtheory_lme4_objective_preflight()
  audit <- gtheory_lme4_objective_preflight_objects(env)$Preflight$Audit
  rows <- audit$ModeRows

  expect_identical(rows$Likelihood, c("ML", "REML"))
  expect_identical(rows$ThetaDimension, c(2L, 2L))
  expect_true(all(rows$FixedEffectsProfiledOut))
  expect_true(all(rows$ResidualScaleProfiledOut))
  expect_true(all(rows$RelativeCovarianceCoordinate))
  expect_true(all(is.finite(rows$OracleObjective)))
  expect_true(all(
    rows$ObjectiveAbsoluteDifference <= audit$ObjectiveTolerance
  ))
  expect_true(all(
    rows$GradientMaximumAbsoluteDifference <= audit$GradientTolerance
  ))
  expect_true(all(
    rows$FitOracleAbsoluteDifference <= audit$ObjectiveTolerance
  ))
  expect_true(all(
    rows$LogLikCriterionAbsoluteDifference <= audit$ObjectiveTolerance
  ))
  expect_true(all(
    rows$EvaluationOrderRange <= audit$ObjectiveTolerance
  ))
  expect_true(audit$ObjectiveOracleAgreementReady)
  expect_true(audit$GradientOracleAgreementReady)
  expect_true(audit$FitCriterionIdentityReady)
  expect_true(audit$EvaluationOrderStabilityReady)
})

test_that("b1g9 exact-zero full objectives reduce in both modes", {
  env <- load_gtheory_lme4_objective_preflight()
  audit <- gtheory_lme4_objective_preflight_objects(env)$Preflight$Audit
  rows <- audit$BoundaryRows

  expect_identical(rows$Likelihood, c("ML", "REML"))
  expect_true(all(rows$TargetThetaAtBoundary == 0))
  expect_true(all(rows$SameFixedEffectMatrix))
  expect_true(all(
    rows$DevfunAbsoluteDifference <= audit$BoundaryTolerance
  ))
  expect_true(all(
    rows$OracleAbsoluteDifference <= audit$BoundaryTolerance
  ))
  expect_true(audit$ExactZeroReductionReady)
})

test_that("b1g9 excludes misleading lme4 convenience accessors", {
  env <- load_gtheory_lme4_objective_preflight()
  contract <- gtheory_lme4_objective_preflight_objects(env)$Preflight
  negative <- contract$Audit$ApiNegativeAudit

  expect_true(negative$Devfun2ForcesML)
  expect_false(negative$Devfun2PreservesInputREMLMode)
  expect_false(negative$Devfun2BaselineReproductionPassed)
  expect_true(negative$DevianceMethodForcesML)
  expect_false(negative$DevianceArgumentReturnsREMLCriterion)
  expect_false(negative$Devfun2EligibleForB1g9)
  expect_false(negative$DevianceREMLArgumentEligibleForB1g9)
  expect_true(contract$Audit$Devfun2Excluded)
  expect_true(contract$Audit$DevianceREMLArgumentExcluded)
  expect_false(contract$Devfun2Allowed)
  expect_false(contract$DevianceREMLArgumentAllowed)
})

test_that("b1g9 oracle rejects unsupported coordinates and weights", {
  env <- load_gtheory_lme4_objective_preflight()
  data <- env$mfrmr_gtwac_fixture_data()
  formula <- Score ~ 1 + (1 | Person) + (1 | Rater)
  fit <- lme4::lmer(formula, data = data, REML = FALSE)
  theta <- lme4::getME(fit, "theta")

  expect_error(
    env$mfrmr_gtwac_dense_oracle(fit, c(-0.1, theta[[2L]]), FALSE),
    "finite nonnegative theta"
  )
  expect_error(
    env$mfrmr_gtwac_dense_oracle(fit, theta[[1L]], FALSE),
    "finite nonnegative theta"
  )
  weighted_fit <- lme4::lmer(
    formula, data = data, REML = FALSE,
    weights = seq(0.75, 1.25, length.out = nrow(data))
  )
  expect_false(
    env$mfrmr_gtwac_simple_intercept_structure(weighted_fit)$
      SimpleIndependentRandomIntercepts
  )
  expect_error(
    env$mfrmr_gtwac_dense_oracle(
      weighted_fit, lme4::getME(weighted_fit, "theta"), FALSE
    ),
    "zero-offset unweighted independent random intercepts only"
  )
  offset_fit <- lme4::lmer(
    formula, data = data, REML = FALSE,
    offset = rep(0.1, nrow(data))
  )
  expect_false(
    env$mfrmr_gtwac_simple_intercept_structure(offset_fit)$
      SimpleIndependentRandomIntercepts
  )
  expect_error(
    env$mfrmr_gtwac_dense_oracle(
      offset_fit, lme4::getME(offset_fit, "theta"), FALSE
    ),
    "zero-offset unweighted independent random intercepts only"
  )
})

test_that("b1g9 remains a non-authorizing preflight", {
  env <- load_gtheory_lme4_objective_preflight()
  objects <- gtheory_lme4_objective_preflight_objects(env)
  contract <- objects$Preflight

  expect_identical(
    contract$UpstreamB1g8ContractHash,
    "1216ae3591fc026a61b4fb6581ebe79e33d34e4e2b6bf04a969a4c93c3e06689"
  )
  expect_true(contract$IndependentGaussianOracleReady)
  expect_true(contract$ThetaOnlyMLObjectiveIdentityReady)
  expect_true(contract$ThetaOnlyREMLObjectiveIdentityReady)
  expect_true(contract$ExactZeroReductionReady)
  expect_true(contract$Lme4ObjectivePreflightReady)
  expect_false(contract$Lme4BoxConstrainedReferenceSolverReady)
  expect_false(contract$Lme4BoundaryProfileReady)
  expect_false(contract$NonreservedLme4ReplayAuthorized)
  expect_false(contract$Lme4MLReferenceMechanicsReady)
  expect_false(contract$Lme4REMLReferenceMechanicsReady)
  expect_false(contract$ReferenceMethodCoverageComplete)
  expect_false(contract$CalibrationAuthorizationReady)
  expect_false(contract$CalibrationExecutionAuthorized)
  expect_false(contract$ConfirmationAuthorized)
  expect_false(contract$InferenceReady)

  changed <- objects$MLCoverage
  changed$ContractHash <- paste0("x", substring(changed$ContractHash, 2L))
  expect_error(env$mfrmr_gtwac_contract(changed), "exact non-authorizing b1g8")
})

test_that("b1g9 identities reproduce exactly", {
  env <- load_gtheory_lme4_objective_preflight()
  contract <- gtheory_lme4_objective_preflight_objects(env)$Preflight

  expect_identical(
    contract$Audit$AuditHash,
    "83faaaf570bd814c000924aa21396ade00958fb8134cec553a0eaa985382ca67"
  )
  expect_identical(
    contract$ContractHash,
    "20d6fb656ac2f2996e5881a07729a3e4fb2f417859f90efde7ee72784ba62092"
  )
})
