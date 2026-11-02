

test_that("negative-power scaled-logit remainders retain the P2c limit", {
  skip_if_not_installed("lpSolve")
  fit <- fit_jml_gpcm_sequence_remainder_fixture()
  path <- .mfrmr_research$mfrmr_jml_gpcm_fit_parameter_hierarchy_limit(fit)
  expect_true(path$parameter_reachable_limit_contract_completed)

  base_utilities <- path$limit$path_definition$base_utilities
  n_observations <- nrow(base_utilities)
  n_categories <- ncol(base_utilities)
  primary <- matrix(0, n_observations, n_categories)
  primary[, 1L] <- 1
  primary[, 2L] <- -1
  secondary <- matrix(0, n_observations, n_categories)
  secondary[, n_categories] <- 0.5

  result <- .mfrmr_research$mfrmr_jml_gpcm_decaying_logit_remainder(
    path,
    residual_stage_directions = list(primary, secondary),
    residual_decay_exponents = c(0.5, 1.5)
  )

  expect_identical(
    result$state, "decaying_scaled_logit_remainder_same_limit"
  )
  expect_true(result$evaluated)
  expect_identical(result$remainder_stages, 2L)
  expect_equal(
    result$log_likelihood_limit, path$log_likelihood_limit,
    tolerance = 0
  )
  expect_true(result$within_row_logit_contrast_remainder_vanishes)
  expect_true(result$same_row_probability_limits_certified)
  expect_true(result$same_joint_log_likelihood_limit_certified)
  expect_true(result$p2b_limit_extended_only_within_declared_remainder_class)
  expect_false(result$finite_distance_ties_required)
  expect_false(result$arbitrary_utility_remainder_classified)
  expect_false(result$arbitrary_slope_remainder_classified)
  expect_false(result$arbitrary_logit_remainder_classified)
  expect_false(result$optimizer_sequence_remainder_certified)
  expect_false(result$global_boundary_classified)
  expect_false(result$external_comparison_eligible)
  expect_identical(result$readiness_effect, "none_diagnostic_only")

  distances <- c(1, 4, 16, 64, 256)
  differences <- vapply(distances, function(distance) {
    declared <- .mfrmr_research$mfrmr_jml_gpcm_parameter_hierarchy_loglik_at(
      path, distance
    )
    remainder <-
      .mfrmr_research$mfrmr_jml_gpcm_parameter_remainder_loglik_at(
        path, result, distance
      )
    expect_true(declared$valid)
    expect_true(remainder$valid)
    max(abs(
      declared$row_log_probability - remainder$row_log_probability
    ))
  }, numeric(1))
  expect_true(all(diff(differences) < 0))
  expect_lt(tail(differences, 1L), head(differences, 1L) / 10)
})

test_that("remainder theorem inputs and scopes fail closed", {
  skip_if_not_installed("lpSolve")
  fit <- fit_jml_gpcm_sequence_remainder_fixture()
  path <- .mfrmr_research$mfrmr_jml_gpcm_fit_parameter_hierarchy_limit(fit)
  dimensions <- dim(path$limit$path_definition$base_utilities)
  direction <- matrix(0, dimensions[1], dimensions[2])

  invalid_source <- path
  invalid_source$contract_version <- "legacy"
  expect_identical(
    .mfrmr_research$mfrmr_jml_gpcm_decaying_logit_remainder(
      invalid_source, list(direction), 1
    )$state,
    "not_evaluated_source_path"
  )
  expect_identical(
    .mfrmr_research$mfrmr_jml_gpcm_decaying_logit_remainder(
      path, list(direction), 0
    )$state,
    "not_evaluated_remainder_mapping"
  )
  expect_identical(
    .mfrmr_research$mfrmr_jml_gpcm_decaying_logit_remainder(
      path, list(direction, direction), c(1, 0.5)
    )$state,
    "not_evaluated_remainder_mapping"
  )
  expect_identical(
    .mfrmr_research$mfrmr_jml_gpcm_decaying_logit_remainder(
      path, list(matrix(0, 1L, 1L)), 1
    )$state,
    "not_evaluated_remainder_mapping"
  )
  expect_identical(
    .mfrmr_research$mfrmr_jml_gpcm_decaying_logit_remainder(
      path, list(direction), 1, max_stages = -1L
    )$state,
    "not_evaluated_control"
  )
  expect_identical(
    .mfrmr_research$mfrmr_jml_gpcm_decaying_logit_remainder(
      path, list(direction), 1, max_stages = 3L
    )$state,
    "not_evaluated_control"
  )

  invalid_evaluation <-
    .mfrmr_research$mfrmr_jml_gpcm_parameter_remainder_loglik_at(
      path,
      .mfrmr_research$mfrmr_jml_gpcm_decaying_logit_remainder(
        path, list(direction), 1
      ),
      0
    )
  expect_false(invalid_evaluation$valid)
})
