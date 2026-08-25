gtheory_multivariate_backend_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-incidence-preflight-0.2.4.R",
      "gtheory-multivariate-matched-backend-prototype-0.2.4.R"
    )
  )
}

load_gtheory_multivariate_backend <- function(require_backends = FALSE) {
  paths <- gtheory_multivariate_backend_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  skip_if_not_installed("digest")
  if (isTRUE(require_backends)) {
    skip_if_not_installed("lme4")
    suppressWarnings(skip_if_not_installed("glmmTMB"))
    skip_if_not_installed("TMB")
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtvb_component_map <- function() {
  data.frame(
    ComponentId = c("Residual", "Object:Rater", "Rater", "Object"),
    UniverseRole = c(
      "relative_error", "relative_error", "absolute_only", "object"
    ),
    Members = c("", "Object:Rater", "Rater", "Object"),
    CovarianceStructure = c(
      "homoskedastic_independent", rep("unstructured", 3L)
    ),
    stringsAsFactors = FALSE
  )
}

gtvb_mvnorm <- function(n, covariance) {
  matrix(stats::rnorm(n * nrow(covariance)), n, nrow(covariance)) %*%
    chol(covariance)
}

gtvb_fixture <- function(seed = 85021L, boundary = FALSE) {
  set.seed(seed)
  objects <- paste0("P", seq_len(24L))
  raters <- paste0("R", seq_len(5L))
  items <- paste0("I", seq_len(2L))
  strata <- c("A", "B")
  data <- expand.grid(
    Object = objects, Rater = raters, Item = items, Stratum = strata,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  object_effect <- gtvb_mvnorm(
    length(objects), matrix(c(1.0, 0.35, 0.35, 0.8), 2L)
  )
  rater_effect <- if (isTRUE(boundary)) {
    matrix(0, length(raters), 2L)
  } else {
    gtvb_mvnorm(
      length(raters), matrix(c(0.25, 0.08, 0.08, 0.20), 2L)
    )
  }
  object_rater_effect <- if (isTRUE(boundary)) {
    matrix(0, length(objects) * length(raters), 2L)
  } else {
    gtvb_mvnorm(
      length(objects) * length(raters),
      matrix(c(0.30, 0.06, 0.06, 0.25), 2L)
    )
  }
  object_index <- match(data$Object, objects)
  rater_index <- match(data$Rater, raters)
  stratum_index <- match(data$Stratum, strata)
  object_rater_index <- (object_index - 1L) * length(raters) + rater_index
  data$Score <- c(A = 0, B = 0.4)[data$Stratum] +
    object_effect[cbind(object_index, stratum_index)] +
    rater_effect[cbind(rater_index, stratum_index)] +
    object_rater_effect[cbind(object_rater_index, stratum_index)] +
    stats::rnorm(nrow(data), sd = 0.5)
  data
}

gtvb_incidence <- function(env, data, rater_scope = "global",
                           missingness = "complete") {
  env$mfrmr_gtvi_audit(
    data, object_col = "Object", stratum_col = "Stratum",
    score_col = "Score", condition_cols = c("Rater", "Item"),
    condition_scope = c(Rater = rater_scope, Item = "global"),
    strata = c("A", "B"), missingness = missingness
  )
}

gtvb_spec <- function(env, data, incidence = gtvb_incidence(env, data),
                      observation_link_cols = c("Rater", "Item")) {
  env$mfrmr_gtvb_spec(
    data, incidence, gtvb_component_map(), observation_link_cols,
    max_covariance_design_cells = 2e6
  )
}

test_that("Draft.85b1 binds canonical components, rows, and covariance rank", {
  env <- load_gtheory_multivariate_backend()
  data <- gtvb_fixture()
  incidence <- gtvb_incidence(env, data)
  spec <- gtvb_spec(env, data, incidence)

  expect_s3_class(spec, "mfrmr_gtvb_spec")
  expect_true(spec$SpecReady)
  expect_true(spec$PointFitEligible)
  expect_true(spec$ComponentMapReady)
  expect_true(spec$PairIdentityReady)
  expect_true(spec$DirectCovarianceSupportReady)
  expect_true(spec$CovarianceDesignRankReady)
  expect_identical(
    spec$ComponentMap$ComponentId,
    c("Object", "Rater", "Object:Rater", "Residual")
  )
  expect_identical(
    spec$ComponentMap$UniverseRole,
    c("object", "absolute_only", "relative_error", "relative_error")
  )
  expect_match(spec$FormulaCanonical, "us\\(0 \\+ \\.gtvb_stratum")
  expect_identical(spec$ResidualContract,
                   "homoskedastic_independent_common_variance")
  expect_equal(spec$CovarianceDesignAudit$ParameterCount, 10L)
  expect_equal(spec$CovarianceDesignAudit$StructuralRank, 10L)
  expect_equal(spec$RandomCoefficientCount, 298L)
  expect_lt(spec$RandomCoefficientCount, spec$RetainedRows)
  expect_true(all(grepl(
    "^[0-9a-f]{64}$",
    c(
      spec$SpecificationHash, spec$RowBindingHash, spec$FixedDesignHash,
      spec$BackendRowIdHash, spec$BackendResponseHash, spec$BackendDataHash,
      spec$RandomDesignBlockHashes, spec$ComponentPairAuditHash,
      spec$CovarianceDesignHash
    )
  )))
  expected_matrix <- matrix(c(2, 0.3, 0.3, 1), 2L)
  dimnames(expected_matrix) <- list(
    spec$FixedDesignColumns, spec$FixedDesignColumns
  )
  reversed_matrix <- expected_matrix[2:1, 2:1, drop = FALSE]
  normalized_matrix <- env$mfrmr_gtvb_normalize_matrix(
    reversed_matrix, spec$Strata, "test/reordered", 1e-10,
    spec$FixedDesignColumns
  )
  expect_equal(unname(normalized_matrix), unname(expected_matrix))
  expect_identical(dimnames(normalized_matrix), list(spec$Strata, spec$Strata))
  dimnames(reversed_matrix) <- list(c("bad-A", "bad-B"), c("bad-A", "bad-B"))
  expect_error(
    env$mfrmr_gtvb_normalize_matrix(
      reversed_matrix, spec$Strata, "test/malformed", 1e-10,
      spec$FixedDesignColumns
    ),
    "coefficient names"
  )
  expect_false(spec$EstimationReady)
  expect_false(spec$InferenceReady)
  expect_false(spec$CoefficientEligible)
  expect_false(spec$DecisionReady)

  expect_silent(env$mfrmr_gtvb_assert_fit_spec(spec))
  extra_spec <- spec
  extra_spec$UnhashedExtra <- TRUE
  expect_error(env$mfrmr_gtvb_assert_fit_spec(extra_spec), "specification")
  attributed_spec <- spec
  attr(attributed_spec, "unhashed") <- TRUE
  expect_error(env$mfrmr_gtvb_assert_fit_spec(attributed_spec), "specification")
  untyped_spec <- spec
  untyped_spec$EstimationReady <- NA
  expect_error(env$mfrmr_gtvb_assert_fit_spec(untyped_spec), "identity")
  extra_backend <- spec
  extra_backend$BackendData$UnboundExtra <- 1
  expect_error(env$mfrmr_gtvb_assert_fit_spec(extra_backend), "malformed")
  ordered_backend <- spec
  ordered_backend$BackendData$.gtvb_stratum <- ordered(
    ordered_backend$BackendData$.gtvb_stratum
  )
  expect_error(env$mfrmr_gtvb_assert_fit_spec(ordered_backend), "malformed")
})

test_that("Draft.85b1 replays row order and the complete incidence identity", {
  env <- load_gtheory_multivariate_backend()
  data <- gtvb_fixture()
  incidence <- gtvb_incidence(env, data)
  first <- gtvb_spec(env, data, incidence)
  reversed <- data[rev(seq_len(nrow(data))), , drop = FALSE]
  replay_incidence <- gtvb_incidence(env, reversed)
  replay <- gtvb_spec(env, reversed, replay_incidence)

  expect_identical(first$SpecificationHash, replay$SpecificationHash)
  expect_identical(first$RowBindingHash, replay$RowBindingHash)
  expect_identical(first$FixedDesignHash, replay$FixedDesignHash)
  expect_identical(
    first$RandomDesignBlockHashes, replay$RandomDesignBlockHashes
  )
  expect_identical(first$CovarianceDesignHash, replay$CovarianceDesignHash)

  mutated <- incidence
  mutated$ConditionScope[["Rater"]] <- "stratum_local"
  expect_error(
    env$mfrmr_gtvb_spec(
      data, mutated, gtvb_component_map(), c("Rater", "Item")
    ),
    "does not replay exactly"
  )

  changed <- data
  changed$Score[[1L]] <- changed$Score[[1L]] + 0.01
  expect_error(
    env$mfrmr_gtvb_spec(
      changed, incidence, gtvb_component_map(), c("Rater", "Item")
    ),
    "does not replay exactly|do not match"
  )
})

test_that("Draft.85b1 rejects role aliases and unsupported residual structure", {
  env <- load_gtheory_multivariate_backend()
  data <- gtvb_fixture()
  incidence <- gtvb_incidence(env, data)

  wrong_role <- gtvb_component_map()
  wrong_role$UniverseRole[wrong_role$ComponentId == "Rater"] <-
    "relative_error"
  expect_error(
    env$mfrmr_gtvb_spec(
      data, incidence, wrong_role, c("Rater", "Item")
    ),
    "UniverseRole"
  )

  wrong_order <- gtvb_component_map()
  row <- which(wrong_order$ComponentId == "Object:Rater")
  wrong_order$ComponentId[[row]] <- "Rater:Object"
  wrong_order$Members[[row]] <- "Rater:Object"
  expect_error(
    env$mfrmr_gtvb_spec(
      data, incidence, wrong_order, c("Rater", "Item")
    ),
    "declared semantic order"
  )

  residual <- gtvb_component_map()
  residual$CovarianceStructure[residual$ComponentId == "Residual"] <-
    "unstructured"
  expect_error(
    env$mfrmr_gtvb_spec(
      data, incidence, residual, c("Rater", "Item")
    ),
    "homoskedastic_independent"
  )
})

test_that("Draft.85b1 distinguishes local scope and joint component support", {
  env <- load_gtheory_multivariate_backend()
  data <- gtvb_fixture()
  local_incidence <- gtvb_incidence(env, data, rater_scope = "stratum_local")
  expect_true(local_incidence$IncidenceReady)
  local <- gtvb_spec(env, data, local_incidence)
  expect_false(local$SpecReady)
  expect_false(local$DirectCovarianceSupportReady)
  expect_true(any(grepl(
    "stratum_local_unstructured_component_not_in_matched_overlap",
    local$Issues, fixed = TRUE
  )))
  expect_error(env$mfrmr_gtvb_fit_lme4(local), "blocked")
  false_eligible <- local
  false_eligible$PointFitEligible <- TRUE
  expect_error(
    env$mfrmr_gtvb_assert_fit_spec(false_eligible), "identity was altered"
  )

  assignment <- data.frame(
    Object = paste0("P", seq_len(4L)),
    A = paste0("R", seq_len(4L)),
    B = paste0("R", c(2L, 3L, 4L, 1L)),
    stringsAsFactors = FALSE
  )
  joint_disjoint <- do.call(rbind, lapply(c("A", "B"), function(stratum) {
    rows <- data.frame(
      Object = rep(assignment$Object, each = 2L),
      Rater = rep(assignment[[stratum]], each = 2L),
      Item = rep(c("I1", "I2"), times = 4L),
      Stratum = stratum, stringsAsFactors = FALSE
    )
    rows$Score <- seq_len(nrow(rows)) / 10
    rows
  }))
  joint_incidence <- gtvb_incidence(env, joint_disjoint)
  expect_true(joint_incidence$IncidenceReady)
  joint <- gtvb_spec(env, joint_disjoint, joint_incidence)
  interaction <- joint$ComponentGroupPairAudit[
    joint$ComponentGroupPairAudit$ComponentId == "Object:Rater",
    , drop = FALSE
  ]
  expect_equal(interaction$SharedGroups, 0L)
  expect_false(interaction$DirectUnstructuredOverlapEligible)
  expect_false(joint$SpecReady)
  expect_true(any(grepl(
    "insufficient_direct_component_group_overlap:Object:Rater:A:B",
    joint$Issues, fixed = TRUE
  )))
})

test_that("Draft.85b1 never invents observation pairs or missing responses", {
  env <- load_gtheory_multivariate_backend()
  data <- gtvb_fixture()
  incidence <- gtvb_incidence(env, data)
  ambiguous <- gtvb_spec(
    env, data, incidence, observation_link_cols = "Rater"
  )
  expect_false(ambiguous$PairIdentityReady)
  expect_false(ambiguous$SpecReady)
  expect_gt(ambiguous$DuplicateWithinStratumObservationKeys, 0L)
  expect_true("ambiguous_observation_pair_identity" %in% ambiguous$Issues)

  missing <- data
  missing$Score[[1L]] <- NA_real_
  missing_incidence <- gtvb_incidence(
    env, missing, missingness = "MAR_covariate"
  )
  expect_true(missing_incidence$IncidenceReady)
  missing_spec <- gtvb_spec(env, missing, missing_incidence)
  expect_false(missing_spec$SpecReady)
  expect_true(
    "missing_scores_outside_draft85b1_matched_point_overlap" %in%
      missing_spec$Issues
  )

  delimiter <- data
  delimiter$Rater[[1L]] <- paste0("R", "\034", "1")
  delimiter_incidence <- gtvb_incidence(env, delimiter)
  expect_error(
    gtvb_spec(env, delimiter, delimiter_incidence),
    "reserved tuple delimiter"
  )
})

test_that("Draft.85b1 matches covariance point estimates under ML and REML", {
  env <- load_gtheory_multivariate_backend(require_backends = TRUE)
  data <- gtvb_fixture()
  spec <- gtvb_spec(env, data)
  fits <- lapply(c(TRUE, FALSE), function(reml) {
    lme4_fit <- env$mfrmr_gtvb_fit_lme4(spec, reml = reml)
    glmmtmb_fit <- env$mfrmr_gtvb_fit_glmmtmb(
      spec, reml = reml, allow_dependency_mismatch_diagnostic = TRUE
    )
    list(
      Lme4 = lme4_fit, GlmmTMB = glmmtmb_fit,
      Parity = env$mfrmr_gtvb_compare(lme4_fit, glmmtmb_fit)
    )
  })

  expect_equal(
    vapply(fits, function(x) x$Lme4$EstimatorIdentity$Method, character(1L)),
    c("REML", "ML")
  )
  expect_true(all(vapply(
    fits, function(x) x$Lme4$PointEstimationGatePassed, logical(1L)
  )))
  expect_true(all(vapply(
    fits, function(x) x$Parity$NumericalParityPassed, logical(1L)
  )))
  expect_true(all(vapply(
    fits, function(x) x$Parity$LikelihoodComparison$WithinTolerance,
    logical(1L)
  )))
  expect_lt(max(vapply(
    fits, function(x) max(x$Parity$CovarianceComparison$AbsoluteDifference),
    numeric(1L)
  )), 1e-4)
  expect_lt(max(vapply(
    fits, function(x) max(x$Parity$FixedEffectComparison$AbsoluteDifference),
    numeric(1L)
  )), 1e-4)
  expect_lt(max(vapply(
    fits, function(x) x$Parity$LikelihoodComparison$AbsoluteDifference,
    numeric(1L)
  )), 1e-5)
  expect_true(all(vapply(
    fits, function(x) x$Lme4$BackendRowsMatch && x$GlmmTMB$BackendRowsMatch,
    logical(1L)
  )))

  for (fit in fits) {
    abi_match <- fit$GlmmTMB$EstimatorIdentity$DependencyABI$VersionMatch
    expect_identical(
      fit$GlmmTMB$PointEstimationGatePassed,
      isTRUE(abi_match) &&
        identical(fit$GlmmTMB$FitDiagnostics$FitStatus,
                  "identified_point_fit")
    )
    expect_identical(
      fit$Parity$MatchedBackendPointReady,
      fit$Parity$NumericalParityPassed &&
        fit$Parity$BothPointEstimationGatesPassed
    )
    expect_false(fit$Parity$EstimationReady)
    expect_false(fit$Parity$RecoveryReady)
    expect_false(fit$Parity$InferenceReady)
    expect_false(fit$Parity$CoefficientEligible)
    expect_false(fit$Parity$DecisionReady)
    expect_false(fit$Parity$PublicSupportReady)
  }

  altered_gate <- fits[[1L]]$Lme4
  altered_gate$PointEstimationGatePassed <-
    !altered_gate$PointEstimationGatePassed
  expect_error(
    env$mfrmr_gtvb_compare(altered_gate, fits[[1L]]$GlmmTMB),
    "identity|internally inconsistent"
  )
  extra_fit <- fits[[1L]]$Lme4
  extra_fit$UnhashedExtra <- TRUE
  expect_error(
    env$mfrmr_gtvb_compare(extra_fit, fits[[1L]]$GlmmTMB),
    "identity"
  )
  untyped_fit <- fits[[1L]]$Lme4
  untyped_fit$InferenceReady <- 0L
  expect_error(
    env$mfrmr_gtvb_compare(untyped_fit, fits[[1L]]$GlmmTMB),
    "internally inconsistent"
  )
})

test_that("Draft.85b1 separates numerical parity from ABI and model identity", {
  env <- load_gtheory_multivariate_backend(require_backends = TRUE)
  data <- gtvb_fixture()
  spec <- gtvb_spec(env, data)
  lme4_reml <- env$mfrmr_gtvb_fit_lme4(spec, reml = TRUE)
  glmmtmb_reml <- env$mfrmr_gtvb_fit_glmmtmb(
    spec, reml = TRUE, allow_dependency_mismatch_diagnostic = TRUE
  )
  strict <- env$mfrmr_gtvb_compare(
    lme4_reml, glmmtmb_reml, absolute_tolerance = 0,
    relative_tolerance = 0, loglik_tolerance = 0, fixed_tolerance = 0
  )

  expect_false(strict$NumericalParityPassed)
  expect_false(strict$MatchedBackendPointReady)
  expect_true(any(!strict$CovarianceComparison$WithinTolerance))

  abi <- glmmtmb_reml$EstimatorIdentity$DependencyABI
  expect_identical(
    abi$VersionMatch,
    identical(abi$BuildTMBVersion, abi$RuntimeTMBVersion)
  )
  expect_match(abi$ABIVersion, "^[0-9]+$")
  expect_identical(abi$DiagnosticOverride, TRUE)
  expect_identical(
    strict$BackendDependencyIdentityPassed, isTRUE(abi$VersionMatch)
  )
  if (!isTRUE(abi$VersionMatch)) {
    expect_error(
      env$mfrmr_gtvb_fit_glmmtmb(spec, reml = TRUE),
      "dependency mismatch"
    )
  }

  glmmtmb_ml <- env$mfrmr_gtvb_fit_glmmtmb(
    spec, reml = FALSE, allow_dependency_mismatch_diagnostic = TRUE
  )
  expect_error(
    env$mfrmr_gtvb_compare(lme4_reml, glmmtmb_ml),
    "matched Gaussian semantic model"
  )
})

test_that("Draft.85b1 retains singular covariance as a non-ready point fit", {
  env <- load_gtheory_multivariate_backend(require_backends = TRUE)
  data <- gtvb_fixture(boundary = TRUE)
  spec <- gtvb_spec(env, data)
  fit <- env$mfrmr_gtvb_fit_lme4(spec, reml = TRUE)

  expect_true(fit$PointEstimateAvailable)
  expect_false(fit$PointEstimationGatePassed)
  expect_true(any(fit$ComponentMatrixAudit$BoundaryOrRankDeficient))
  expect_true(fit$FitDiagnostics$FitStatus %in% c(
    "optimizer_warning_with_boundary_covariance",
    "boundary_or_singular_covariance"
  ))
  expect_false(fit$EstimationReady)
  expect_false(fit$InferenceReady)
  expect_false(fit$DecisionReady)
})
