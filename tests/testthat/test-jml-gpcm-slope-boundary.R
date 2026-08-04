make_gpcm_slope_boundary_fixture <- function(reverse = FALSE) {
  cells <- expand.grid(
    Person = c("P1", "P2"),
    Criterion = c("C1", "C2"),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  cells$Score <- c(0L, 1L, 1L, 0L)
  data <- cells[rep(seq_len(nrow(cells)), each = 3L), , drop = FALSE]
  if (isTRUE(reverse)) data <- data[nrow(data):1L, , drop = FALSE]
  rownames(data) <- NULL
  data
}

fit_gpcm_slope_boundary_fixture <- function(anchored = TRUE,
                                             reverse = FALSE) {
  anchors <- if (isTRUE(anchored)) {
    data.frame(
      Facet = "Person",
      Level = c("P1", "P2"),
      Anchor = c(-1, 1),
      stringsAsFactors = FALSE
    )
  } else {
    NULL
  }
  suppressWarnings(fit_mfrm(
    make_gpcm_slope_boundary_fixture(reverse),
    person = "Person",
    facets = "Criterion",
    score = "Score",
    model = "GPCM",
    method = "JML",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    anchors = anchors,
    rating_min = 0,
    rating_max = 1,
    maxit = 300,
    reltol = 1e-12
  ))
}

gpcm_slope_boundary_problem <- function(fit) {
  config <- fit$config
  sizes <- mfrmr:::build_param_sizes(config)
  idx <- mfrmr:::build_indices(
    fit$prep,
    step_facet = config$step_facet,
    slope_facet = config$slope_facet,
    interaction_specs = config$interaction_specs
  )
  list(
    config = config,
    sizes = sizes,
    idx = idx,
    slices = mfrmr:::build_param_slices(sizes)
  )
}

test_that("GPCM slope-only monotone boundary path is certified", {
  fit <- fit_gpcm_slope_boundary_fixture()
  audit <- fit$config$boundary_audit$gpcm_slope_boundary

  expect_identical(audit$state, "certified_monotone_boundary_path")
  expect_true(isTRUE(audit$complete))
  expect_true(isTRUE(audit$scope_complete))
  expect_false(isTRUE(audit$structural_identification_complete))
  expect_lt(abs(audit$likelihood_difference), 1e-10)

  certified <- audit$certificates[audit$certificates$Certified, , drop = FALSE]
  expect_identical(nrow(certified), 1L)
  expect_identical(certified$PositiveLevel, "C1")
  expect_identical(certified$NegativeLevel, "C2")
  expect_equal(certified$DirectionSum, 0)
  expect_gte(certified$BoundaryImprovement, 0)
  expect_gt(certified$StrictRows, 0L)

  targets <- audit$target_status[match(
    c("C1", "C2"), audit$target_status$Level
  ), , drop = FALSE]
  expect_identical(
    targets$CandidateStatus,
    c("boundary_path_high", "boundary_path_low")
  )
  expanded <- audit$direction_loadings[
    audit$direction_loadings$CoordinateType == "expanded_log_slope",
    , drop = FALSE
  ]
  expect_equal(sum(expanded$Loading), 0)
  expect_setequal(expanded$Loading, c(-1, 1))

  # WP4 has not promoted this internal certificate to public primary values.
  expect_true(all(is.finite(fit$slopes$LogEstimate)))
  expect_true(all(is.finite(fit$slopes$Estimate)))
  expect_identical(fit$readiness$fit$BoundaryState, "not_evaluated")
  expect_identical(fit$readiness$fit$FitReadiness, "review")
  expect_false(fit$readiness$fit$InferenceReady)
  expect_match(
    fit$readiness$fit$ReasonCodes,
    "boundary_candidate_not_propagated",
    fixed = TRUE
  )
})

test_that("GPCM slope certificate agrees with an objective path oracle", {
  fit <- fit_gpcm_slope_boundary_fixture()
  audit <- fit$config$boundary_audit$gpcm_slope_boundary
  certificate <- audit$certificates[
    audit$certificates$Certified, , drop = FALSE
  ]
  problem <- gpcm_slope_boundary_problem(fit)
  slope_levels <- fit$config$gpcm_spec$levels
  expanded_direction <- rep(0, length(slope_levels))
  expanded_direction[certificate$PositiveIndex] <- 1
  expanded_direction[certificate$NegativeIndex] <- -1
  free_direction <- expanded_direction[seq_len(length(slope_levels) - 1L)]

  path_t <- c(0, 0.25, 0.5, 1, 2, 4, 8, 16)
  path_log_likelihood <- vapply(path_t, function(distance) {
    par <- fit$opt$par
    par[problem$slices$log_slopes] <-
      par[problem$slices$log_slopes] + distance * free_direction
    -mfrmr:::mfrm_loglik_jml(
      par, problem$idx, problem$config, problem$sizes
    )
  }, numeric(1))

  expect_equal(sum(expanded_direction), 0)
  expect_gte(min(diff(path_log_likelihood)), -1e-10)
  expect_gt(path_log_likelihood[length(path_log_likelihood)],
            path_log_likelihood[1])
  expect_equal(
    path_log_likelihood[1], certificate$CurrentLogLikelihood,
    tolerance = 1e-10
  )
  expect_equal(
    path_log_likelihood[length(path_log_likelihood)],
    certificate$BoundaryLogLikelihood,
    tolerance = 1e-8
  )
})

test_that("GPCM slope boundary result is invariant to retained row order", {
  forward <- fit_gpcm_slope_boundary_fixture()
  reversed <- fit_gpcm_slope_boundary_fixture(reverse = TRUE)
  audit_forward <- forward$config$boundary_audit$gpcm_slope_boundary
  audit_reversed <- reversed$config$boundary_audit$gpcm_slope_boundary

  expect_identical(audit_reversed$state, audit_forward$state)
  forward_targets <- audit_forward$target_status[
    order(audit_forward$target_status$Level), , drop = FALSE
  ]
  reversed_targets <- audit_reversed$target_status[
    order(audit_reversed$target_status$Level), , drop = FALSE
  ]
  expect_identical(
    reversed_targets$CandidateStatus,
    forward_targets$CandidateStatus
  )
  forward_pairs <- audit_forward$certificates[
    order(audit_forward$certificates$PositiveLevel,
          audit_forward$certificates$NegativeLevel), , drop = FALSE
  ]
  reversed_pairs <- audit_reversed$certificates[
    order(audit_reversed$certificates$PositiveLevel,
          audit_reversed$certificates$NegativeLevel), , drop = FALSE
  ]
  expect_identical(reversed_pairs$Certified, forward_pairs$Certified)
  expect_equal(
    reversed_pairs$BoundaryImprovement,
    forward_pairs$BoundaryImprovement,
    tolerance = 1e-10
  )
})

test_that("GPCM slope audit fails closed on limits and is not reused for MML", {
  fit <- fit_gpcm_slope_boundary_fixture()
  problem <- gpcm_slope_boundary_problem(fit)
  limited <- mfrmr:::audit_mfrm_jml_gpcm_slope_boundary(
    prep = fit$prep,
    idx = problem$idx,
    config = problem$config,
    sizes = problem$sizes,
    par = fit$opt$par,
    max_direction_pairs = 0L
  )
  expect_identical(limited$state, "not_evaluated_size_limit")
  expect_false(isTRUE(limited$complete))
  expect_false(isTRUE(limited$scope_complete))
  expect_true(all(
    limited$target_status$CandidateStatus == "not_evaluated_size_limit"
  ))

  invalid_control <- mfrmr:::audit_mfrm_jml_gpcm_slope_boundary(
    prep = fit$prep,
    idx = problem$idx,
    config = problem$config,
    sizes = problem$sizes,
    par = fit$opt$par,
    support_tolerance = NA_real_
  )
  expect_identical(invalid_control$state, "not_evaluated_control")
  expect_false(isTRUE(invalid_control$complete))
  expect_false(isTRUE(invalid_control$scope_complete))

  mml_config <- problem$config
  mml_config$method <- "MML"
  mml <- mfrmr:::audit_mfrm_jml_gpcm_slope_boundary(
    prep = fit$prep,
    idx = problem$idx,
    config = mml_config,
    sizes = problem$sizes,
    par = fit$opt$par
  )
  expect_identical(mml$state, "not_applicable_mml")
  expect_true(isTRUE(mml$complete))
  expect_false(isTRUE(mml$scope_complete))
  expect_false(isTRUE(mml$structural_identification_complete))
})

test_that("none-certified slope-only paths do not imply finite joint GPCM", {
  fit <- fit_gpcm_slope_boundary_fixture(anchored = FALSE)
  audit <- fit$config$boundary_audit$gpcm_slope_boundary
  problem <- gpcm_slope_boundary_problem(fit)

  expect_identical(audit$state, "none_certified")
  expect_true(isTRUE(audit$scope_complete))
  expect_false(isTRUE(audit$structural_identification_complete))
  expect_match(audit$limitations, "does not establish finite GPCM slopes")
  expect_true(all(
    audit$target_status$CandidateStatus ==
      "none_certified_in_slope_only_paths"
  ))

  # At the retained symmetric point all base utilities are tied, so the
  # slope-only audit correctly has no strict ray. Moving Person coordinates
  # jointly exposes an improving nonlinear path. This adversarial control
  # prevents a scoped negative certificate from becoming a finite-MLE claim.
  path_t <- c(0, 0.1, 0.25, 0.5, 1, 2, 4, 8)
  joint_path_log_likelihood <- vapply(path_t, function(distance) {
    par <- fit$opt$par
    par[problem$slices$theta] <- c(-distance, distance)
    par[problem$slices$log_slopes] <- distance
    -mfrmr:::mfrm_loglik_jml(
      par, problem$idx, problem$config, problem$sizes
    )
  }, numeric(1))
  expect_gte(min(diff(joint_path_log_likelihood)), -1e-10)
  expect_gt(
    joint_path_log_likelihood[length(joint_path_log_likelihood)],
    joint_path_log_likelihood[1]
  )
})
