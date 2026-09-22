gtheory_glmmtmb_parity_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-design-incidence-audit-0.2.3.R",
      "gtheory-balanced-estimation-prototype-0.2.3.R",
      "gtheory-covariance-information-audit-0.2.3.R",
      "gtheory-glmmtmb-parity-prototype-0.2.3.R"
    )
  )
}

load_gtheory_glmmtmb_parity <- function() {
  paths <- gtheory_glmmtmb_parity_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  skip_if_not_installed("digest")
  skip_if_not_installed("lme4")
  skip_if_not_installed("glmmTMB")
  skip_if_not_installed("TMB")
  if (!requireNamespace("reformulas", quietly = TRUE) &&
      !requireNamespace("lme4", quietly = TRUE)) {
    skip("Draft.81 formula parser requires reformulas or lme4")
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtm_fit_pair <- function(env, fixture, reml = TRUE) {
  audit <- env$mfrmr_gti_audit(fixture$Spec, fixture$Data)
  lme4_fit <- env$mfrmr_gtc_lme4(
    fixture$Spec, fixture$Data, audit, reml = reml
  )
  glmmtmb_fit <- env$mfrmr_gtm_fit(
    fixture$Spec, fixture$Data, audit, reml = reml
  )
  list(
    Audit = audit,
    Lme4 = lme4_fit,
    GlmmTMB = glmmtmb_fit,
    Parity = env$mfrmr_gtm_compare(lme4_fit, glmmtmb_fit)
  )
}

gtm_nested_fixture <- function(env) {
  spec <- env$mfrmr_gta_spec(
    Score ~ 1 + (1 | Person) + (1 | Site/Rater),
    object = "Person", facets = c("Site", "Rater"),
    nesting = data.frame(Parent = "Site", Child = "Rater"),
    residual_scale_by = c("Site", "Rater")
  )
  set.seed(8302L)
  data <- expand.grid(
    Person = factor(paste0("P", seq_len(24L))),
    Site = factor(paste0("S", seq_len(4L))),
    Rater = factor(paste0("R", seq_len(3L))),
    KEEP.OUT.ATTRS = FALSE
  )
  person_effect <- stats::rnorm(24L, 0, 1)
  site_effect <- stats::rnorm(4L, 0, 0.5)
  rater_effect <- matrix(stats::rnorm(12L, 0, 0.4), 4L, 3L)
  residual <- stats::rnorm(nrow(data), 0, 0.7)
  data$Score <- person_effect[as.integer(data$Person)] +
    site_effect[as.integer(data$Site)] +
    rater_effect[cbind(as.integer(data$Site), as.integer(data$Rater))] +
    residual
  list(Spec = spec, Data = data)
}

test_that("Draft.83c2 matches p x i under both ML and REML", {
  env <- load_gtheory_glmmtmb_parity()
  fixture <- env$mfrmr_gte_fixture("pxi", "interior")
  fits <- lapply(c(TRUE, FALSE), function(reml) {
    gtm_fit_pair(env, fixture, reml = reml)
  })

  expect_equal(
    vapply(fits, function(x) x$GlmmTMB$EstimatorIdentity$Method,
           character(1L)),
    c("REML", "ML")
  )
  expect_true(all(vapply(
    fits, function(x) x$Audit$IncidenceScreenPassed, logical(1L)
  )))
  expect_true(all(vapply(
    fits, function(x) x$Lme4$EstimationGatePassed, logical(1L)
  )))
  expect_true(all(vapply(
    fits, function(x) x$GlmmTMB$EstimationGatePassed, logical(1L)
  )))
  expect_true(all(vapply(
    fits, function(x) x$Parity$NumericalParityPassed, logical(1L)
  )))
  expect_true(all(vapply(
    fits, function(x) x$Parity$MatchedOverlapPassed, logical(1L)
  )))
  expect_true(all(vapply(
    fits, function(x) x$Parity$LikelihoodComparison$WithinTolerance,
    logical(1L)
  )))
  expect_lt(max(vapply(
    fits, function(x) max(x$Parity$ComponentComparison$AbsoluteDifference),
    numeric(1L)
  )), 5e-6)
  expect_lt(max(vapply(
    fits, function(x) x$Parity$LikelihoodComparison$AbsoluteDifference,
    numeric(1L)
  )), 1e-8)
  expect_true(all(vapply(
    fits, function(x) !x$Parity$InferenceReady, logical(1L)
  )))
  expect_true(all(vapply(
    fits, function(x) !x$Parity$CoefficientEligible, logical(1L)
  )))
  expect_true(all(vapply(
    fits, function(x) !x$Parity$DecisionReady, logical(1L)
  )))
})

test_that("Draft.83c2 matches every typed p x r x i component", {
  env <- load_gtheory_glmmtmb_parity()
  fixture <- env$mfrmr_gte_fixture("pxrxi", "interior")
  pair <- gtm_fit_pair(env, fixture, reml = TRUE)

  expect_s3_class(pair$GlmmTMB, "mfrmr_gtm_fit")
  expect_s3_class(pair$Parity, "mfrmr_gtm_parity")
  expect_equal(
    pair$Parity$ComponentComparison$ComponentId,
    fixture$Spec$EffectMap$ComponentId
  )
  expect_true(all(pair$Parity$ComponentComparison$WithinTolerance))
  expect_lt(
    max(pair$Parity$ComponentComparison$AbsoluteDifference), 2e-5
  )
  expect_lt(pair$Parity$LikelihoodComparison$AbsoluteDifference, 1e-7)
  expect_lt(pair$Parity$InterceptComparison$AbsoluteDifference, 1e-8)
  expect_identical(pair$Parity$BoundaryComparisonStatus, "both_interior")
  expect_true(pair$Parity$NumericalParityPassed)
  expect_true(pair$Parity$BothPointEstimationGatesPassed)
  expect_true(pair$Parity$MatchedOverlapPassed)
  expect_identical(
    pair$GlmmTMB$CovarianceDesignHash,
    pair$Lme4$CovarianceDesignHash
  )
  expect_identical(
    pair$GlmmTMB$RetainedDataHash,
    pair$Lme4$RetainedDataHash
  )
  expect_match(pair$Parity$ResultHash, "^[0-9a-f]{64}$")
})

test_that("Draft.83c2 canonicalizes nested backend grouping labels", {
  env <- load_gtheory_glmmtmb_parity()
  fixture <- gtm_nested_fixture(env)
  pair <- gtm_fit_pair(env, fixture, reml = TRUE)

  expect_true(pair$Audit$IncidenceScreenPassed)
  expect_false(fixture$Spec$DStudyEligible)
  expect_equal(
    pair$GlmmTMB$Components$ComponentId,
    c("Person", "Site", "Site:Rater", "Residual")
  )
  expect_equal(
    pair$GlmmTMB$Components$GroupingLevels,
    c(Person = 24L, Site = 4L, `Site:Rater` = 12L, Residual = 288L),
    ignore_attr = TRUE
  )
  expect_true(pair$Lme4$EstimationGatePassed)
  expect_true(pair$GlmmTMB$EstimationGatePassed)
  expect_true(pair$Parity$NumericalParityPassed)
  expect_true(pair$Parity$MatchedOverlapPassed)
  expect_lt(
    max(pair$Parity$ComponentComparison$AbsoluteDifference), 2e-5
  )
  expect_lt(pair$Parity$LikelihoodComparison$AbsoluteDifference, 1e-7)
  expect_false(pair$Parity$CoefficientEligible)
  expect_false(pair$Parity$DecisionReady)
})

test_that("Draft.83c2 does not equate pdHess with an interior fit", {
  env <- load_gtheory_glmmtmb_parity()
  fixture <- env$mfrmr_gte_fixture("pxi", "negative_raw")
  pair <- gtm_fit_pair(env, fixture, reml = TRUE)

  expect_identical(pair$Lme4$FitQualification, "boundary_nonregular")
  expect_identical(pair$GlmmTMB$FitQualification, "boundary_nonregular")
  expect_true(pair$GlmmTMB$FitDiagnostics$PositiveDefiniteHessian)
  expect_equal(pair$GlmmTMB$FitDiagnostics$OptimizerCode, 0L)
  expect_identical(
    pair$GlmmTMB$FitDiagnostics$FitStatus,
    "boundary_tolerance_reached"
  )
  expect_equal(pair$GlmmTMB$FitDiagnostics$BoundaryComponentCount, 1L)
  item <- pair$GlmmTMB$Components[
    pair$GlmmTMB$Components$ComponentId == "Item", , drop = FALSE
  ]
  expect_lt(item$Estimate, 1e-8)
  expect_identical(
    item$BoundaryState,
    "near_zero_at_declared_backend_tolerance"
  )
  expect_false(pair$GlmmTMB$ExpectedInformation$RegularInterior)
  expect_true(pair$GlmmTMB$SelectedInformation$InformationRankFull)
  expect_identical(
    pair$Parity$BoundaryComparisonStatus,
    "both_detect_boundary_at_backend_tolerance"
  )
  expect_false(pair$Parity$NumericalParityPassed)
  expect_false(pair$Parity$BothPointEstimationGatesPassed)
  expect_false(pair$Parity$MatchedOverlapPassed)
  expect_gt(pair$Parity$LikelihoodComparison$AbsoluteDifference, 0.1)
  expect_false(pair$Parity$InferenceReady)
  expect_false(pair$Parity$CoefficientEligible)
  expect_false(pair$Parity$DecisionReady)
})

test_that("Draft.83c2 freezes backend and control identities", {
  env <- load_gtheory_glmmtmb_parity()
  fixture <- env$mfrmr_gte_fixture("pxi", "interior")
  pair <- gtm_fit_pair(env, fixture, reml = TRUE)
  identity <- pair$GlmmTMB$EstimatorIdentity

  expect_identical(identity$Backend, "glmmTMB")
  expect_identical(
    identity$BackendVersion,
    as.character(utils::packageVersion("glmmTMB"))
  )
  expect_identical(
    identity$TMBVersion,
    as.character(utils::packageVersion("TMB"))
  )
  expect_identical(identity$FamilyName, "gaussian")
  expect_identical(identity$Link, "identity")
  expect_identical(identity$ZeroInflationFormula, "~0")
  expect_identical(identity$DispersionFormula, "~1")
  expect_identical(identity$Control$Optimizer, "stats::nlminb_default")
  expect_true(identity$Control$EigenvalueCheck)
  expect_identical(identity$Control$RankCheck, "adjust")
  expect_identical(identity$Control$ConvergenceCheck, "warning")
  expect_true(all(grepl(
    "^[0-9a-f]{64}$", identity$BackendFunctionHashes
  )))
  expect_true(all(grepl(
    "^[0-9a-f]{64}$",
    c(
      identity$Control$OptimizerFunctionHash,
      identity$Control$OptimizerControlHash,
      identity$Control$OptimizerArgumentsHash,
      identity$Control$ParallelHash,
      identity$Control$StartMethodHash
    )
  )))
  expect_equal(pair$GlmmTMB$LikelihoodIdentity$Observations,
               nrow(fixture$Data))
  expect_identical(
    pair$GlmmTMB$LikelihoodIdentity$ConstantContract,
    "backend_reported_full_Gaussian_logLik"
  )
  expect_match(pair$GlmmTMB$ResultHash, "^[0-9a-f]{64}$")
})

test_that("Draft.83c2 makes parity tolerance and model identity explicit", {
  env <- load_gtheory_glmmtmb_parity()
  fixture <- env$mfrmr_gte_fixture("pxrxi", "interior")
  audit <- env$mfrmr_gti_audit(fixture$Spec, fixture$Data)
  lme4_reml <- env$mfrmr_gtc_lme4(
    fixture$Spec, fixture$Data, audit, reml = TRUE
  )
  glmmtmb_reml <- env$mfrmr_gtm_fit(
    fixture$Spec, fixture$Data, audit, reml = TRUE
  )
  strict <- env$mfrmr_gtm_compare(
    lme4_reml, glmmtmb_reml,
    absolute_tolerance = 0, relative_tolerance = 0,
    loglik_tolerance = 0, intercept_tolerance = 0
  )

  expect_false(strict$NumericalParityPassed)
  expect_false(strict$MatchedOverlapPassed)
  expect_equal(strict$Tolerances, rep(0, 4), ignore_attr = TRUE)
  expect_true(any(!strict$ComponentComparison$WithinTolerance))
  expect_false(strict$LikelihoodComparison$WithinTolerance)
  expect_match(strict$ResultHash, "^[0-9a-f]{64}$")

  glmmtmb_ml <- env$mfrmr_gtm_fit(
    fixture$Spec, fixture$Data, audit, reml = FALSE
  )
  expect_error(
    env$mfrmr_gtm_compare(lme4_reml, glmmtmb_ml),
    "matched Gaussian model contract"
  )

  changed <- fixture$Data
  changed$Score[[1L]] <- changed$Score[[1L]] + 0.01
  changed_audit <- env$mfrmr_gti_audit(fixture$Spec, changed)
  changed_fit <- env$mfrmr_gtm_fit(
    fixture$Spec, changed, changed_audit, reml = TRUE
  )
  expect_error(
    env$mfrmr_gtm_compare(lme4_reml, changed_fit),
    "exact design/audit/retained-row"
  )
})

test_that("Draft.83c2 replays row order without changing fit identity", {
  env <- load_gtheory_glmmtmb_parity()
  fixture <- env$mfrmr_gte_fixture("pxi", "interior")
  first_audit <- env$mfrmr_gti_audit(fixture$Spec, fixture$Data)
  first <- env$mfrmr_gtm_fit(
    fixture$Spec, fixture$Data, first_audit, reml = TRUE
  )
  replay_data <- fixture$Data[rev(seq_len(nrow(fixture$Data))), , drop = FALSE]
  replay_audit <- env$mfrmr_gti_audit(fixture$Spec, replay_data)
  replay <- env$mfrmr_gtm_fit(
    fixture$Spec, replay_data, replay_audit, reml = TRUE
  )

  expect_identical(first_audit$AuditHash, replay_audit$AuditHash)
  expect_identical(first$RetainedDataHash, replay$RetainedDataHash)
  expect_identical(first$CovarianceDesignHash, replay$CovarianceDesignHash)
  expect_identical(first$Components, replay$Components)
  expect_identical(first$FitDiagnostics, replay$FitDiagnostics)
  expect_identical(first$ResultHash, replay$ResultHash)
  expect_false(first$InferenceReady)
  expect_false(first$CoefficientEligible)
  expect_false(first$DecisionReady)
})

test_that("Draft.83c2 fails closed on capacity and malformed calls", {
  env <- load_gtheory_glmmtmb_parity()
  fixture <- env$mfrmr_gte_fixture("pxi", "interior")
  audit <- env$mfrmr_gti_audit(fixture$Spec, fixture$Data)

  expect_error(
    env$mfrmr_gtm_fit(
      fixture$Spec, fixture$Data, audit,
      max_matrix_cells = 1
    ),
    "covariance audit hit capacity"
  )
  expect_error(
    env$mfrmr_gtm_fit(
      fixture$Spec, fixture$Data, audit,
      boundary_tolerance = -1
    ),
    "finite nonnegative"
  )
  glmmtmb_fit <- env$mfrmr_gtm_fit(
    fixture$Spec, fixture$Data, audit
  )
  expect_error(
    env$mfrmr_gtm_compare(glmmtmb_fit, glmmtmb_fit),
    "Draft.83c1 lme4 fit"
  )
  lme4_fit <- env$mfrmr_gtc_lme4(
    fixture$Spec, fixture$Data, audit
  )
  expect_error(
    env$mfrmr_gtm_compare(
      lme4_fit, glmmtmb_fit, loglik_tolerance = -1
    ),
    "finite nonnegative"
  )
})
