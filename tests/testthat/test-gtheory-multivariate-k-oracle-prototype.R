gtheory_multivariate_k_oracle_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-incidence-preflight-0.2.4.R",
      "gtheory-multivariate-matched-backend-prototype-0.2.4.R",
      "gtheory-multivariate-k-oracle-prototype-0.2.4.R"
    )
  )
}

load_gtheory_multivariate_k_oracle <- function(require_lme4 = FALSE) {
  paths <- gtheory_multivariate_k_oracle_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  skip_if_not_installed("digest")
  if (isTRUE(require_lme4)) skip_if_not_installed("lme4")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtvc_component_map <- function() {
  data.frame(
    ComponentId = c("Residual", "Object:Rater", "Rater", "Object"),
    UniverseRole = c(
      "relative_error", "relative_error", "absolute_only", "object"
    ),
    Members = c("", "Object:Rater", "Rater", "Object"),
    CovarianceStructure = c(
      "homoskedastic_independent", rep("unstructured", 3L)
    ), stringsAsFactors = FALSE
  )
}

gtvc_data <- function(strata = c("A", "B"), objects = 12L,
                      raters = 4L, items = 2L) {
  data <- expand.grid(
    Object = paste0("P", seq_len(objects)),
    Rater = paste0("R", seq_len(raters)),
    Item = paste0("I", seq_len(items)), Stratum = strata,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  object_index <- match(data$Object, unique(data$Object))
  rater_index <- match(data$Rater, unique(data$Rater))
  item_index <- match(data$Item, unique(data$Item))
  stratum_index <- match(data$Stratum, strata)
  data$Score <- sin(object_index / 3) + cos(rater_index / 2) +
    item_index / 20 + (stratum_index - 1) * 0.4
  data
}

gtvc_spec <- function(env, data, strata = unique(data$Stratum)) {
  incidence <- env$mfrmr_gtvi_audit(
    data, object_col = "Object", stratum_col = "Stratum",
    score_col = "Score", condition_cols = c("Rater", "Item"),
    condition_scope = c(Rater = "global", Item = "global"),
    strata = strata, missingness = "complete"
  )
  env$mfrmr_gtvb_spec(
    data, incidence, gtvc_component_map(), c("Rater", "Item"),
    max_covariance_design_cells = 2e6
  )
}

gtvc_truth_matrices <- function(strata) {
  if (length(strata) == 2L) {
    values <- list(
      Object = matrix(c(1, 0.35, 0.35, 0.8), 2L),
      Rater = matrix(c(0.25, 0.08, 0.08, 0.20), 2L),
      `Object:Rater` = matrix(c(0.30, 0.06, 0.06, 0.25), 2L)
    )
  } else {
    values <- list(
      Object = matrix(c(
        1, 0.35, 0.20, 0.35, 0.8, 0.25, 0.20, 0.25, 0.9
      ), 3L),
      Rater = matrix(c(
        0.25, 0.08, 0.04, 0.08, 0.20, 0.06, 0.04, 0.06, 0.22
      ), 3L),
      `Object:Rater` = matrix(c(
        0.30, 0.06, 0.03, 0.06, 0.25, 0.05, 0.03, 0.05, 0.28
      ), 3L)
    )
  }
  lapply(values, function(matrix) {
    dimnames(matrix) <- list(strata, strata)
    matrix
  })
}

gtvc_covariance <- function(env, design, matrices = gtvc_truth_matrices(
                              design$Strata)) {
  env$mfrmr_gtvc_covariance_spec(design, matrices, residual_variance = 0.25)
}

gtvc_mvnorm <- function(n, covariance) {
  matrix(stats::rnorm(n * nrow(covariance)), n, nrow(covariance)) %*%
    chol(covariance)
}

gtvc_backend_data <- function(seed = 85031L) {
  set.seed(seed)
  data <- expand.grid(
    Object = paste0("P", seq_len(24L)),
    Rater = paste0("R", seq_len(5L)), Item = paste0("I", seq_len(2L)),
    Stratum = c("A", "B"), KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  object_effect <- gtvc_mvnorm(
    24L, matrix(c(1, 0.35, 0.35, 0.8), 2L)
  )
  rater_effect <- gtvc_mvnorm(
    5L, matrix(c(0.25, 0.08, 0.08, 0.20), 2L)
  )
  interaction_effect <- gtvc_mvnorm(
    120L, matrix(c(0.30, 0.06, 0.06, 0.25), 2L)
  )
  object_index <- match(data$Object, unique(data$Object))
  rater_index <- match(data$Rater, unique(data$Rater))
  stratum_index <- match(data$Stratum, c("A", "B"))
  interaction_index <- (object_index - 1L) * 5L + rater_index
  data$Score <- c(0, 0.4)[stratum_index] +
    object_effect[cbind(object_index, stratum_index)] +
    rater_effect[cbind(rater_index, stratum_index)] +
    interaction_effect[cbind(interaction_index, stratum_index)] +
    stats::rnorm(nrow(data), sd = 0.5)
  data
}

test_that("Draft.85c0 literal microcase separates K construction from rank", {
  env <- load_gtheory_multivariate_k_oracle()
  row_id <- c("row-A", "row-B")
  group <- matrix(1L, 2L, 1L, dimnames = list(row_id, "Component"))
  fixed <- diag(2L)
  dimnames(fixed) <- list(row_id, c("Stratum/A", "Stratum/B"))
  design <- env$mfrmr_gtvc_neutral_design(
    row_id, c("A", "B"), c(1L, 2L), group, fixed,
    stats::setNames(c(0, 1), row_id)
  )
  gamma <- matrix(c(2, 0.5, 0.5, 3), 2L,
                  dimnames = list(c("A", "B"), c("A", "B")))
  covariance <- env$mfrmr_gtvc_covariance_spec(
    design, list(Component = gamma), 0.25
  )
  dual <- env$mfrmr_gtvc_dual_k(design, covariance)
  derivative <- env$mfrmr_gtvc_derivative_design(design)
  projection <- env$mfrmr_gtvc_population_projection(
    design, covariance, derivative
  )

  expect_equal(
    dual$Pairwise$K,
    matrix(c(2.25, 0.5, 0.5, 3.25), 2L,
           dimnames = list(row_id, row_id))
  )
  expect_equal(dual$MaximumAbsoluteDifference, 0)
  expect_true(dual$DualConstructionPassed)
  expect_equal(derivative$ParameterCount, 4L)
  expect_equal(derivative$StructuralRank, 3L)
  expect_false(derivative$CovarianceDesignIdentified)
  expect_false(projection$PopulationMapRoundTripPassed)
  expect_true(env$mfrmr_gtvc_core_audit()$OracleIndependenceReady)
  expect_false(design$TruthFieldsPresent)
  expect_false(dual$RecoveryEvidenceReady)
})

test_that("Draft.85c0 bridge replays b1 designs but keeps response separate", {
  env <- load_gtheory_multivariate_k_oracle()
  data <- gtvc_data()
  first_spec <- gtvc_spec(env, data, c("A", "B"))
  first <- env$mfrmr_gtvc_bridge_gtvb(first_spec)

  expect_true(first$B1BridgeReady)
  expect_true(first$OracleIndependenceReady)
  expect_true(first$Bridge$SourceDesignHashesMatch)
  expect_true(first$Bridge$KDesignBindingPassed)
  expect_identical(
    first$KDerivative$CoordinateTable$CoordinateId,
    first_spec$CovarianceDesignAudit$ParameterLabels
  )
  expect_identical(
    first$KDerivative$CrossproductHash,
    first_spec$CovarianceDesignAudit$CrossproductHash
  )
  expect_equal(first$KDerivative$StructuralRank, 10L)

  changed <- data
  changed$Score <- changed$Score + 0.125
  changed_bridge <- env$mfrmr_gtvc_bridge_gtvb(
    gtvc_spec(env, changed, c("A", "B"))
  )
  expect_identical(
    changed_bridge$StructuralDesignHash, first$StructuralDesignHash
  )
  expect_identical(
    changed_bridge$KDerivative$KDesignHash,
    first$KDerivative$KDesignHash
  )
  expect_false(identical(changed_bridge$ResponseHash, first$ResponseHash))
  expect_false(identical(
    changed_bridge$NeutralDesignHash, first$NeutralDesignHash
  ))

  changed_backend <- first_spec
  changed_backend$BackendData$.gtvb_score[[1L]] <-
    changed_backend$BackendData$.gtvb_score[[1L]] + 0.1
  expect_error(
    env$mfrmr_gtvc_bridge_gtvb(changed_backend),
    "changed after specification binding"
  )
  extra_backend <- first_spec
  extra_backend$BackendData$UnboundExtra <- 1
  expect_error(env$mfrmr_gtvc_bridge_gtvb(extra_backend), "malformed")
  ordered_backend <- first_spec
  ordered_backend$BackendData$.gtvb_stratum <- ordered(
    ordered_backend$BackendData$.gtvb_stratum
  )
  expect_error(env$mfrmr_gtvc_bridge_gtvb(ordered_backend), "malformed")
  altered_spec <- first_spec
  altered_spec$RowBindingHash <- paste0("altered-", altered_spec$RowBindingHash)
  expect_error(env$mfrmr_gtvc_bridge_gtvb(altered_spec), "identity was altered")
  extra_spec <- first_spec
  extra_spec$UnhashedExtra <- TRUE
  expect_error(env$mfrmr_gtvc_bridge_gtvb(extra_spec), "specification")
})

test_that("Draft.85c0 population map and information pass for two and three strata", {
  env <- load_gtheory_multivariate_k_oracle()
  cases <- list(
    T2 = list(strata = c("A", "B"), objects = 12L, raters = 4L),
    T3 = list(strata = c("A", "B", "C"), objects = 10L, raters = 4L)
  )
  results <- lapply(cases, function(case) {
    spec <- gtvc_spec(
      env, gtvc_data(case$strata, case$objects, case$raters, 2L),
      case$strata
    )
    bridge <- env$mfrmr_gtvc_bridge_gtvb(spec)
    covariance <- gtvc_covariance(env, bridge)
    projection <- env$mfrmr_gtvc_population_projection(
      bridge, covariance, bridge$KDerivative
    )
    information <- env$mfrmr_gtvc_expected_information(
      bridge, covariance, bridge$KDerivative
    )
    list(
      Bridge = bridge, Covariance = covariance,
      Dual = env$mfrmr_gtvc_dual_k(bridge, covariance),
      Projection = projection, Information = information
    )
  })

  expect_identical(
    vapply(results, function(x) x$Bridge$KDerivative$ParameterCount,
           integer(1L)),
    c(T2 = 10L, T3 = 19L)
  )
  expect_true(all(vapply(
    results, function(x) x$Dual$DualConstructionPassed, logical(1L)
  )))
  expect_true(all(vapply(
    results, function(x) x$Projection$PopulationMapRoundTripPassed,
    logical(1L)
  )))
  expect_lt(max(vapply(
    results,
    function(x) x$Projection$MaximumCoordinateRoundTripError,
    numeric(1L)
  )), 1e-9)
  expect_lt(max(vapply(
    results, function(x) x$Projection$MaximumKRoundTripError, numeric(1L)
  )), 1e-10)
  expect_true(all(vapply(
    results,
    function(x) x$Information$MLExpectedInformationFullRank,
    logical(1L)
  )))
  expect_true(all(vapply(
    results,
    function(x) x$Information$REMLExpectedInformationFullRank,
    logical(1L)
  )))
  expect_true(all(vapply(
    results, function(x) x$Covariance$RegularInteriorReady, logical(1L)
  )))
  expect_false(any(vapply(
    results, function(x) x$Information$PrecisionEvidenceReady, logical(1L)
  )))
  expect_false(any(vapply(
    results, function(x) x$Projection$RecoveryEvidenceReady, logical(1L)
  )))

  for (result in results) {
    algebra <- env$mfrmr_gtvc_linear_algebra(
      result$Bridge, result$Covariance
    )
    x <- result$Bridge$FixedDesign
    inverse <- algebra$Inverse
    projection <- inverse - inverse %*% x %*%
      solve(algebra$FixedInformation, crossprod(x, inverse))
    direct_information <- function(weight) {
      derivative <- result$Bridge$KDerivative$DerivativeMatrices
      matrix(vapply(seq_along(derivative), function(left) {
        vapply(seq_along(derivative), function(right) {
          0.5 * sum(diag(
            weight %*% derivative[[left]] %*% weight %*%
              derivative[[right]]
          ))
        }, numeric(1L))
      }, numeric(length(derivative))), nrow = length(derivative))
    }
    expect_equal(
      unname(result$Information$MLInformation),
      direct_information(inverse), tolerance = 1e-10
    )
    expect_equal(
      unname(result$Information$REMLInformation),
      direct_information(projection), tolerance = 1e-10
    )
    expect_equal(
      result$Information$MLInformation,
      t(result$Information$MLInformation), tolerance = 1e-12
    )
    expect_equal(
      result$Information$REMLInformation,
      t(result$Information$REMLInformation), tolerance = 1e-12
    )
  }

  t3_coordinates <- env$mfrmr_gtvc_pack_covariance(
    results$T3$Bridge, results$T3$Covariance
  )
  ab <- match("Object[A,B]", names(t3_coordinates))
  ac <- match("Object[A,C]", names(t3_coordinates))
  swapped_coordinates <- t3_coordinates
  swapped_coordinates[c(ab, ac)] <- t3_coordinates[c(ac, ab)]
  swapped_covariance <- env$mfrmr_gtvc_unpack_covariance(
    results$T3$Bridge, swapped_coordinates
  )
  expect_gt(max(abs(
    env$mfrmr_gtvc_build_k_pairwise(
      results$T3$Bridge, swapped_covariance
    )$K - results$T3$Dual$Pairwise$K
  )), 0)
})

test_that("Draft.85c0 analytic K scores match central finite differences", {
  env <- load_gtheory_multivariate_k_oracle()
  bridge <- env$mfrmr_gtvc_bridge_gtvb(
    gtvc_spec(env, gtvc_data(), c("A", "B"))
  )
  covariance <- gtvc_covariance(env, bridge)
  coordinates <- env$mfrmr_gtvc_pack_covariance(bridge, covariance)
  step <- 1e-6
  for (method in c("ML", "REML")) {
    analytic <- env$mfrmr_gtvc_score(
      bridge, covariance, method, bridge$KDerivative
    )$Score
    numeric_score <- vapply(seq_along(coordinates), function(index) {
      plus <- coordinates; minus <- coordinates
      plus[[index]] <- plus[[index]] + step
      minus[[index]] <- minus[[index]] - step
      plus_covariance <- env$mfrmr_gtvc_unpack_covariance(bridge, plus)
      minus_covariance <- env$mfrmr_gtvc_unpack_covariance(bridge, minus)
      (
        env$mfrmr_gtvc_loglik(bridge, plus_covariance, method)$LogLik -
          env$mfrmr_gtvc_loglik(bridge, minus_covariance, method)$LogLik
      ) / (2 * step)
    }, numeric(1L))
    expect_equal(as.numeric(analytic), numeric_score, tolerance = 1e-4)
  }
})

test_that("Draft.85c0 preserves boundary and malformed covariance states", {
  env <- load_gtheory_multivariate_k_oracle()
  bridge <- env$mfrmr_gtvc_bridge_gtvb(
    gtvc_spec(env, gtvc_data(), c("A", "B"))
  )
  matrices <- gtvc_truth_matrices(bridge$Strata)

  reordered <- matrices[c("Rater", "Object", "Object:Rater")]
  expect_error(
    env$mfrmr_gtvc_covariance_spec(bridge, reordered, 0.25),
    "names and order"
  )
  asymmetric <- matrices
  asymmetric$Rater[1, 2] <- asymmetric$Rater[1, 2] + 0.1
  expect_error(
    env$mfrmr_gtvc_covariance_spec(bridge, asymmetric, 0.25),
    "asymmetric"
  )
  indefinite <- matrices
  indefinite$Rater <- matrix(
    c(1, 2, 2, 1), 2L, dimnames = list(bridge$Strata, bridge$Strata)
  )
  expect_error(
    env$mfrmr_gtvc_covariance_spec(bridge, indefinite, 0.25),
    "indefinite"
  )
  rank_one <- matrices
  rank_one$Rater <- outer(c(0.5, 0.4), c(0.5, 0.4))
  dimnames(rank_one$Rater) <- list(bridge$Strata, bridge$Strata)
  boundary <- env$mfrmr_gtvc_covariance_spec(bridge, rank_one, 0.25)
  projection <- env$mfrmr_gtvc_population_projection(
    bridge, boundary, bridge$KDerivative
  )
  objective <- env$mfrmr_gtvc_loglik(bridge, boundary, "REML")
  expect_false(boundary$RegularInteriorReady)
  expect_true(env$mfrmr_gtvc_build_k_pairwise(
    bridge, boundary
  )$KPositiveDefinite)
  expect_true(projection$PopulationMapRoundTripPassed)
  expect_true(objective$ObjectiveOracleReady)
  expect_false(objective$RegularInteriorReady)
  expect_false(projection$RecoveryEvidenceReady)

  scaled <- matrices
  scaled$Rater <- diag(c(1e4, 5e-7))
  dimnames(scaled$Rater) <- list(bridge$Strata, bridge$Strata)
  scaled_boundary <- env$mfrmr_gtvc_covariance_spec(
    bridge, scaled, 0.25, tolerance = 1e-10, boundary_tolerance = 1e-8
  )
  scaled_rater <- scaled_boundary$ComponentAudit[
    scaled_boundary$ComponentAudit$ComponentId == "Rater", , drop = FALSE
  ]
  scaled_information <- env$mfrmr_gtvc_expected_information(
    bridge, scaled_boundary, bridge$KDerivative
  )
  expect_gt(scaled_rater$MinimumEigenvalue, 1e-8)
  expect_equal(scaled_rater$EffectiveRank, 1L)
  expect_true(scaled_rater$RankDeficient)
  expect_true(scaled_rater$Boundary)
  expect_false(scaled_boundary$RegularInteriorReady)
  expect_true(scaled_information$LocalExpectedInformationComputed)
  expect_false(scaled_information$LocalExpectedInformationReady)

  scaled_control <- matrices
  scaled_control$Rater <- diag(c(1e4, 2e-6))
  dimnames(scaled_control$Rater) <- list(bridge$Strata, bridge$Strata)
  control <- env$mfrmr_gtvc_covariance_spec(
    bridge, scaled_control, 0.25,
    tolerance = 1e-10, boundary_tolerance = 1e-8
  )
  control_rater <- control$ComponentAudit[
    control$ComponentAudit$ComponentId == "Rater", , drop = FALSE
  ]
  expect_equal(control_rater$EffectiveRank, 2L)
  expect_false(control_rater$Boundary)

  coarse_derivative <- env$mfrmr_gtvc_derivative_design(
    bridge, rank_tolerance = 0.5
  )
  coarse_information <- env$mfrmr_gtvc_expected_information(
    bridge, gtvc_covariance(env, bridge), coarse_derivative
  )
  expect_false(coarse_derivative$CovarianceDesignIdentified)
  expect_true(coarse_information$LocalExpectedInformationComputed)
  expect_false(coarse_information$LocalExpectedInformationReady)

  small_residual <- env$mfrmr_gtvc_covariance_spec(
    bridge, matrices, residual_variance = 1e-9,
    tolerance = 1e-10, boundary_tolerance = 1e-8
  )
  small_residual_information <- env$mfrmr_gtvc_expected_information(
    bridge, small_residual, bridge$KDerivative
  )
  expect_false(small_residual$RegularInteriorReady)
  expect_true(small_residual_information$LocalExpectedInformationComputed)
  expect_false(small_residual_information$LocalExpectedInformationReady)
  expect_error(
    env$mfrmr_gtvc_covariance_spec(bridge, matrices, residual_variance = 0),
    "finite positive"
  )
})

test_that("Draft.85c0 structural subsets and row permutations never impute", {
  env <- load_gtheory_multivariate_k_oracle()
  bridge <- env$mfrmr_gtvc_bridge_gtvb(
    gtvc_spec(env, gtvc_data(), c("A", "B"))
  )
  covariance <- gtvc_covariance(env, bridge)
  full_k <- env$mfrmr_gtvc_build_k_pairwise(bridge, covariance)$K
  keep <- seq(1L, bridge$RowCount, by = 3L)
  subset_design <- env$mfrmr_gtvc_neutral_design(
    bridge$RowId[keep], bridge$Strata, bridge$StratumCode[keep],
    bridge$ComponentGroupCode[keep, , drop = FALSE],
    bridge$FixedDesign[keep, , drop = FALSE],
    stats::setNames(bridge$Response[keep], bridge$RowId[keep])
  )
  subset_covariance <- gtvc_covariance(env, subset_design)
  expect_equal(
    env$mfrmr_gtvc_build_k_pairwise(subset_design, subset_covariance)$K,
    full_k[keep, keep, drop = FALSE]
  )

  permutation <- rev(seq_len(bridge$RowCount))
  permuted_design <- env$mfrmr_gtvc_neutral_design(
    bridge$RowId[permutation], bridge$Strata,
    bridge$StratumCode[permutation],
    bridge$ComponentGroupCode[permutation, , drop = FALSE],
    bridge$FixedDesign[permutation, , drop = FALSE],
    stats::setNames(bridge$Response[permutation], bridge$RowId[permutation])
  )
  permuted_covariance <- gtvc_covariance(env, permuted_design)
  expect_equal(
    env$mfrmr_gtvc_build_k_pairwise(
      permuted_design, permuted_covariance
    )$K,
    full_k[permutation, permutation, drop = FALSE]
  )
  missing_response <- stats::setNames(bridge$Response, bridge$RowId)
  missing_response[[1L]] <- NA_real_
  expect_error(
    env$mfrmr_gtvc_neutral_design(
      bridge$RowId, bridge$Strata, bridge$StratumCode,
      bridge$ComponentGroupCode, bridge$FixedDesign, missing_response
    ),
    "finite"
  )
})

test_that("Draft.85c0 metric mechanics retain failures and detect swaps", {
  env <- load_gtheory_multivariate_k_oracle()
  bridge <- env$mfrmr_gtvc_bridge_gtvb(
    gtvc_spec(env, gtvc_data(), c("A", "B"))
  )
  reference <- gtvc_covariance(env, bridge)
  exact_receipt <- env$mfrmr_gtvc_candidate_receipt(
    "D001", "exact", bridge, reference,
    fit_returned = TRUE, point_gate_passed = TRUE,
    failure_stage = "none", failure_code = "none"
  )
  exact <- env$mfrmr_gtvc_join_reference(
    bridge, exact_receipt, reference
  )
  expect_true(exact$MetricAvailable)
  expect_true(all(exact$CoordinateMetrics$AbsoluteDeterministicError == 0))
  expect_equal(exact$MaximumAbsoluteKError, 0)
  expect_true(exact$ReferenceJoinIntegrityReady)
  expect_false(exact$RecoveryDenominatorReady)

  swapped_matrices <- reference$ComponentCovariances
  temporary <- swapped_matrices$Object
  swapped_matrices$Object <- swapped_matrices$Rater
  swapped_matrices$Rater <- temporary
  swapped <- env$mfrmr_gtvc_covariance_spec(
    bridge, swapped_matrices, reference$ResidualVariance
  )
  swapped_receipt <- env$mfrmr_gtvc_candidate_receipt(
    "D001", "swapped", bridge, swapped,
    fit_returned = TRUE, point_gate_passed = FALSE,
    failure_stage = "regularity", failure_code = "synthetic_swap"
  )
  swapped_ledger <- env$mfrmr_gtvc_join_reference(
    bridge, swapped_receipt, reference
  )
  expect_gt(max(
    swapped_ledger$CoordinateMetrics$AbsoluteDeterministicError
  ), 0)
  expect_gt(swapped_ledger$MaximumAbsoluteKError, 0)

  failure_receipt <- env$mfrmr_gtvc_candidate_receipt(
    "D001", "failed", bridge, estimate_covariance = NULL,
    fit_returned = FALSE, point_gate_passed = FALSE,
    failure_stage = "backend_fit", failure_code = "synthetic_failure"
  )
  failure <- env$mfrmr_gtvc_join_reference(
    bridge, failure_receipt, reference
  )
  expect_true(all(failure$CoordinateMetrics$Planned))
  expect_false(any(failure$CoordinateMetrics$FitReturned))
  expect_false(any(failure$CoordinateMetrics$MetricAvailable))
  expect_equal(nrow(failure$CoordinateMetrics), 10L)
  expect_false(failure$RecoveryDenominatorReady)
  expect_false(failure$RecoveryEvidenceReady)
  expect_error(
    env$mfrmr_gtvc_candidate_receipt(
      "D001", "impossible", bridge,
      estimate_covariance = NULL, fit_returned = FALSE,
      point_gate_passed = TRUE,
      failure_stage = "none", failure_code = "none"
    ),
    "allowed monotone"
  )
  expect_error(
    env$mfrmr_gtvc_candidate_receipt(
      "D001", "wrong-stage-000", bridge,
      estimate_covariance = NULL, fit_returned = FALSE,
      point_gate_passed = FALSE, failure_stage = "regularity",
      failure_code = "wrong_stage"
    ),
    "allowed monotone"
  )
  expect_error(
    env$mfrmr_gtvc_candidate_receipt(
      "D001", "wrong-stage-110", bridge, reference,
      fit_returned = TRUE, point_gate_passed = FALSE,
      failure_stage = "component_extraction", failure_code = "wrong_stage"
    ),
    "allowed monotone"
  )

  registry <- data.frame(
    DatasetId = rep("D001", 3L),
    MethodId = c("exact", "swapped", "failed"),
    stringsAsFactors = FALSE
  )
  denominator <- env$mfrmr_gtvc_denominator_audit(
    registry, list(exact_receipt, swapped_receipt, failure_receipt), bridge
  )
  expect_true(denominator$AtomicRegistryMatchReady)
  expect_false(denominator$DenominatorAccountingReady)
  missing_denominator <- env$mfrmr_gtvc_denominator_audit(
    registry, list(exact_receipt, failure_receipt), bridge
  )
  expect_false(missing_denominator$AtomicRegistryMatchReady)
  expect_false(missing_denominator$DenominatorAccountingReady)
  expect_error(
    env$mfrmr_gtvc_denominator_audit(
      registry, list(exact_receipt, exact_receipt, failure_receipt), bridge
    ),
    "must be unique"
  )

  contaminated <- exact_receipt
  contaminated$ReferenceCovariance <- reference
  expect_error(
    env$mfrmr_gtvc_join_reference(bridge, contaminated, reference),
    "sealed|candidate receipt"
  )
  untyped_receipt <- exact_receipt
  untyped_receipt$RecoveryEvidenceReady <- NA
  expect_error(
    env$mfrmr_gtvc_join_reference(bridge, untyped_receipt, reference),
    "sealed-state schema"
  )
})

test_that("Draft.85c0 rejects stale hashes, truth attributes, and false readiness", {
  env <- load_gtheory_multivariate_k_oracle()
  bridge <- env$mfrmr_gtvc_bridge_gtvb(
    gtvc_spec(env, gtvc_data(), c("A", "B"))
  )
  covariance <- gtvc_covariance(env, bridge)

  changed_response <- bridge
  changed_response$Response[[1L]] <- changed_response$Response[[1L]] + 0.1
  expect_error(
    env$mfrmr_gtvc_build_k_pairwise(changed_response, covariance),
    "identity or exact payload schema was altered"
  )
  leaked_truth <- bridge
  attr(leaked_truth, "truth") <- list(boundary = FALSE)
  expect_error(
    env$mfrmr_gtvc_build_k_pairwise(leaked_truth, covariance),
    "ready Draft.85c0 neutral design"
  )
  changed_covariance <- covariance
  changed_covariance$ComponentCovariances$Object[1, 1] <-
    changed_covariance$ComponentCovariances$Object[1, 1] + 0.1
  expect_error(
    env$mfrmr_gtvc_build_k_pairwise(bridge, changed_covariance),
    "not bound"
  )
  false_ready <- covariance
  false_ready$RecoveryEvidenceReady <- TRUE
  expect_error(
    env$mfrmr_gtvc_build_k_pairwise(bridge, false_ready),
    "not bound"
  )
  untyped_covariance <- covariance
  untyped_covariance$InferenceReady <- 0L
  expect_error(
    env$mfrmr_gtvc_build_k_pairwise(bridge, untyped_covariance),
    "not bound"
  )
  unknown_design <- bridge
  unknown_design$BackendFit <- list(truth = "hidden")
  expect_error(
    env$mfrmr_gtvc_build_k_pairwise(unknown_design, covariance),
    "ready Draft.85c0 neutral design"
  )
  unknown_covariance <- covariance
  unknown_covariance$GeneratingCovariance <- covariance
  expect_error(
    env$mfrmr_gtvc_build_k_pairwise(bridge, unknown_covariance),
    "not bound"
  )
  false_design_ready <- bridge
  false_design_ready$EstimationReady <- TRUE
  expect_error(
    env$mfrmr_gtvc_build_k_pairwise(false_design_ready, covariance),
    "identity or exact payload schema"
  )
  stale_derivative <- bridge$KDerivative
  stale_derivative$ResultHash <- paste0("stale-", stale_derivative$ResultHash)
  expect_error(
    env$mfrmr_gtvc_population_projection(
      bridge, covariance, stale_derivative
    ),
    "unavailable or mismatched"
  )
  false_derivative_ready <- bridge$KDerivative
  false_derivative_ready$EstimationReady <- TRUE
  expect_error(
    env$mfrmr_gtvc_score(
      bridge, covariance, "REML", false_derivative_ready
    ),
    "unavailable or mismatched"
  )
  untyped_derivative <- bridge$KDerivative
  untyped_derivative$DecisionReady <- NA
  expect_error(
    env$mfrmr_gtvc_score(bridge, covariance, "REML", untyped_derivative),
    "unavailable or mismatched"
  )
  capacity_blocked <- env$mfrmr_gtvc_derivative_design(
    bridge, max_k_cells = 1
  )
  expect_identical(capacity_blocked$CapacityStatus, "not_evaluated_capacity")
  expect_false(capacity_blocked$CovarianceDesignOracleReady)
  expect_error(
    env$mfrmr_gtvc_population_projection(
      bridge, covariance, capacity_blocked
    ),
    "not_evaluated_capacity"
  )
  altered_bridge <- bridge
  altered_bridge$OracleIndependence$FunctionAudit$Function[[1L]] <- "altered"
  expect_error(env$mfrmr_gtvc_assert_bridge(altered_bridge), "identity")
  false_bridge_ready <- bridge
  false_bridge_ready$RecoveryEvidenceReady <- TRUE
  expect_error(env$mfrmr_gtvc_assert_bridge(false_bridge_ready), "identity|schema")
  untyped_bridge <- bridge
  untyped_bridge$DecisionReady <- NA
  expect_error(env$mfrmr_gtvc_assert_bridge(untyped_bridge), "identity|schema")
  untyped_independence <- bridge
  untyped_independence$OracleIndependence$DecisionReady <- 0L
  expect_error(
    env$mfrmr_gtvc_assert_bridge(untyped_independence), "identity|schema"
  )
})

test_that("Draft.85c0 independently reproduces lme4 ML and REML objectives", {
  env <- load_gtheory_multivariate_k_oracle(require_lme4 = TRUE)
  spec <- gtvc_spec(env, gtvc_backend_data(), c("A", "B"))
  bridge <- env$mfrmr_gtvc_bridge_gtvb(spec)
  runs <- lapply(c(TRUE, FALSE), function(reml) {
    fit <- env$mfrmr_gtvb_fit_lme4(spec, reml = reml)
    list(Fit = fit, Comparison = env$mfrmr_gtvc_compare_fit(bridge, fit))
  })
  comparisons <- lapply(runs, `[[`, "Comparison")

  expect_identical(
    vapply(comparisons, function(x) x$Method, character(1L)),
    c("REML", "ML")
  )
  expect_true(all(vapply(
    comparisons, function(x) x$SemanticIdentityMatched, logical(1L)
  )))
  expect_true(all(vapply(
    comparisons,
    function(x) x$DeterministicObjectiveBindingPassed, logical(1L)
  )))
  expect_lt(max(vapply(
    comparisons, function(x) x$LogLikAbsoluteDifference, numeric(1L)
  )), 1e-8)
  expect_lt(max(vapply(
    comparisons,
    function(x) x$FixedEffectMaximumAbsoluteDifference, numeric(1L)
  )), 1e-8)
  expect_true(all(vapply(
    comparisons,
    function(x) is.finite(x$MaximumAbsoluteKCoordinateScore), logical(1L)
  )))
  expect_false(any(vapply(
    comparisons, function(x) x$EstimatorRecoveryReady, logical(1L)
  )))
  expect_false(any(vapply(
    comparisons, function(x) x$InferenceReady, logical(1L)
  )))
  expect_false(any(vapply(
    comparisons, function(x) x$PublicSupportReady, logical(1L)
  )))

  fit_mutations <- list(
    component_order = function(fit) {
      fit$ComponentCovariances <- fit$ComponentCovariances[
        rev(names(fit$ComponentCovariances))
      ]
      fit
    },
    fixed_names = function(fit) {
      names(fit$FixedEffectsByStratum) <- rev(names(fit$FixedEffectsByStratum))
      fit
    },
    criterion = function(fit) {
      fit$LikelihoodIdentity$Criterion <- "ML"
      fit
    },
    observations = function(fit) {
      fit$LikelihoodIdentity$Observations <-
        fit$LikelihoodIdentity$Observations - 1L
      fit
    },
    point_gate = function(fit) {
      fit$PointEstimationGatePassed <- !fit$PointEstimationGatePassed
      fit
    },
    extra_field = function(fit) {
      fit$UnhashedExtra <- TRUE
      fit
    }
  )
  for (mutate_fit in fit_mutations) {
    expect_error(
      env$mfrmr_gtvc_compare_fit(bridge, mutate_fit(runs[[1L]]$Fit)),
      "identity|contract|internally inconsistent"
    )
  }
})
