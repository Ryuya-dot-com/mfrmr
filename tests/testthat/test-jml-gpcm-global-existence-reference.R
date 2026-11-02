
global_existence_person_direction <- function(fit, levels, signs) {
  scope <- fit$config$boundary_audit$gpcm_parameter_path_reachability
  direction <- rep(0, scope$additive_free_coordinates)
  for (i in seq_along(levels)) {
    keep <- scope$coordinate_map$Block == "Person" &
      scope$coordinate_map$Level == levels[i]
    direction[keep] <- signs[i]
  }
  direction
}


test_that("a reachable divergent zero-limit path proves finite JMLE nonexistence", {
  skip_if_not_installed("lpSolve")
  fit <- fit_jml_gpcm_global_existence_fixture("all_extreme")
  direction <- global_existence_person_direction(
    fit, c("P1", "P2"), c(-1, 1)
  )
  path <- .mfrmr_research$mfrmr_jml_gpcm_fit_parameter_hierarchy_limit(
    fit,
    additive_coordinate_directions = list(direction),
    additive_scale_exponents = 1,
    slope_stage_rates = NULL,
    slope_scale_exponents = numeric(0)
  )
  adjudicated <- .mfrmr_research$mfrmr_jml_gpcm_reachable_supremum_zero(path)

  expect_true(path$declared_parameter_path_reachability_certified)
  expect_identical(path$log_likelihood_limit, 0)
  expect_identical(
    adjudicated$contract_version,
    "mfrmr-jml-gpcm-global-existence-0.2.3-v1"
  )
  expect_identical(
    adjudicated$state,
    "global_supremum_zero_finite_jmle_nonexistence_certified"
  )
  expect_true(adjudicated$evaluated)
  expect_true(adjudicated$source_parameter_path_contract_matches)
  expect_true(adjudicated$parameter_path_reachability_certified)
  expect_true(adjudicated$parameter_path_limit_classified)
  expect_identical(adjudicated$divergent_parameter_stages, 1L)
  expect_true(adjudicated$path_escapes_every_bounded_parameter_set)
  expect_identical(adjudicated$universal_finite_log_likelihood_upper_bound, 0)
  expect_true(adjudicated$finite_parameter_log_likelihood_strictly_below_zero)
  expect_identical(adjudicated$path_log_likelihood_limit, 0)
  expect_true(adjudicated$path_reaches_universal_upper_bound)
  expect_true(adjudicated$global_boundary_competitiveness_certified)
  expect_true(adjudicated$global_supremum_value_classified)
  expect_identical(adjudicated$global_log_likelihood_supremum, 0)
  expect_true(adjudicated$global_supremum_attained_on_declared_boundary)
  expect_false(adjudicated$global_supremum_attained_at_finite_parameter)
  expect_true(adjudicated$finite_jmle_existence_classified)
  expect_false(adjudicated$finite_jmle_existence_certified)
  expect_true(adjudicated$finite_jmle_nonexistence_certified)
  expect_true(adjudicated$global_boundary_classified)
  expect_true(adjudicated$global_boundary_presence_certified)
  expect_false(adjudicated$global_boundary_absence_certified)
  expect_false(adjudicated$standard_error_eligible)
  expect_false(adjudicated$confidence_interval_eligible)
  expect_false(adjudicated$external_comparison_eligible)
  expect_identical(adjudicated$readiness_effect, "none_diagnostic_only")

  finite <- vapply(c(1, 2, 4, 8), function(distance) {
    .mfrmr_research$mfrmr_jml_gpcm_parameter_hierarchy_loglik_at(
      path, distance
    )$log_likelihood
  }, numeric(1))
  expect_true(all(is.finite(finite)))
  expect_true(all(finite < 0))
  expect_gt(min(diff(finite)), 0)
  expect_lt(abs(tail(finite, 1)), abs(finite[1]))
})

test_that("a reachable boundary below zero does not classify the global supremum", {
  skip_if_not_installed("lpSolve")
  fit <- fit_jml_gpcm_global_existence_fixture("one_extreme")
  direction <- global_existence_person_direction(fit, "P1", -1)
  path <- .mfrmr_research$mfrmr_jml_gpcm_fit_parameter_hierarchy_limit(
    fit,
    additive_coordinate_directions = list(direction),
    additive_scale_exponents = 1,
    slope_stage_rates = NULL,
    slope_scale_exponents = numeric(0)
  )
  adjudicated <- .mfrmr_research$mfrmr_jml_gpcm_reachable_supremum_zero(path)

  expect_true(path$declared_parameter_path_reachability_certified)
  expect_true(is.finite(path$log_likelihood_limit))
  expect_lt(path$log_likelihood_limit, 0)
  expect_identical(
    adjudicated$state, "reachable_boundary_below_universal_supremum"
  )
  expect_true(adjudicated$evaluated)
  expect_false(adjudicated$path_reaches_universal_upper_bound)
  expect_false(adjudicated$global_supremum_value_classified)
  expect_true(is.na(adjudicated$global_log_likelihood_supremum))
  expect_false(adjudicated$finite_jmle_existence_classified)
  expect_false(adjudicated$finite_jmle_nonexistence_certified)
  expect_false(adjudicated$global_boundary_classified)
})

test_that("bounded and malformed P2c paths fail closed", {
  skip_if_not_installed("lpSolve")
  fit <- fit_jml_gpcm_global_existence_fixture("crossed")
  bounded <- .mfrmr_research$mfrmr_jml_gpcm_fit_parameter_hierarchy_limit(
    fit,
    additive_coordinate_directions = list(),
    additive_scale_exponents = numeric(0),
    slope_stage_rates = NULL,
    slope_scale_exponents = numeric(0)
  )
  bounded_result <- .mfrmr_research$mfrmr_jml_gpcm_reachable_supremum_zero(bounded)
  expect_identical(
    bounded_result$state, "bounded_parameter_path_not_global_boundary"
  )
  expect_true(bounded_result$evaluated)
  expect_identical(bounded_result$divergent_parameter_stages, 0L)
  expect_false(bounded_result$path_escapes_every_bounded_parameter_set)
  expect_false(bounded_result$finite_jmle_nonexistence_certified)

  malformed <- .mfrmr_research$mfrmr_jml_gpcm_reachable_supremum_zero(list())
  expect_identical(malformed$state, "not_evaluated_source_contract")
  expect_false(malformed$evaluated)
  expect_false(malformed$source_parameter_path_contract_matches)
  atomic <- .mfrmr_research$mfrmr_jml_gpcm_reachable_supremum_zero(1)
  expect_identical(atomic$state, "not_evaluated_source_contract")
  expect_false(atomic$evaluated)

  incomplete <- bounded
  incomplete$declared_parameter_path_reachability_certified <- FALSE
  incomplete_result <-
    .mfrmr_research$mfrmr_jml_gpcm_reachable_supremum_zero(incomplete)
  expect_identical(incomplete_result$state, "not_evaluated_parameter_path")
  expect_false(incomplete_result$evaluated)
  expect_false(incomplete_result$finite_jmle_nonexistence_certified)
})

test_that("the finite-attainment implication requires a strict complete-boundary gap", {
  conditional <- .mfrmr_research$mfrmr_jml_gpcm_finite_attainment_gap_theorem(
    finite_log_likelihood = -5,
    boundary_limsup_upper_bound = -6,
    complete_boundary_envelope_declared = TRUE
  )
  expect_identical(
    conditional$state,
    "conditional_finite_attainment_from_declared_complete_boundary_gap"
  )
  expect_true(conditional$evaluated)
  expect_true(conditional$strict_finite_over_boundary_gap)
  expect_true(conditional$complete_boundary_envelope_declared_by_caller)
  expect_false(conditional$complete_boundary_envelope_independently_certified)
  expect_true(conditional$objective_continuity_on_finite_parameter_space)
  expect_true(conditional$closed_finite_parameter_space)
  expect_true(conditional$compact_upper_level_set_follows_conditionally)
  expect_true(conditional$finite_attainment_follows_conditionally)
  expect_false(conditional$global_finite_jmle_existence_certified)
  expect_false(conditional$global_boundary_absence_certified)
  expect_false(conditional$production_decision_eligible)
  expect_false(conditional$external_comparison_eligible)
  expect_identical(conditional$readiness_effect, "none_diagnostic_only")

  incomplete <- .mfrmr_research$mfrmr_jml_gpcm_finite_attainment_gap_theorem(
    -5, -6, FALSE
  )
  expect_identical(
    incomplete$state, "boundary_envelope_incomplete_global_existence_open"
  )
  expect_true(incomplete$strict_finite_over_boundary_gap)
  expect_false(incomplete$finite_attainment_follows_conditionally)

  no_gap <- .mfrmr_research$mfrmr_jml_gpcm_finite_attainment_gap_theorem(
    -6, -6, TRUE
  )
  expect_identical(
    no_gap$state, "no_strict_boundary_gap_global_existence_open"
  )
  expect_false(no_gap$strict_finite_over_boundary_gap)
  expect_false(no_gap$finite_attainment_follows_conditionally)

  invalid <- .mfrmr_research$mfrmr_jml_gpcm_finite_attainment_gap_theorem(
    Inf, -6, TRUE
  )
  expect_identical(invalid$state, "not_evaluated_boundary_gap_inputs")
  expect_false(invalid$evaluated)
  expect_false(invalid$global_finite_jmle_existence_certified)
})
