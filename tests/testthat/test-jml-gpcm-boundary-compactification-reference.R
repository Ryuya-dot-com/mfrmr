

test_that("nonzero sum-zero rates receive canonical primary roles", {
  partition <- .mfrmr_research$mfrmr_jml_gpcm_rate_role_partition(c(3, -1, -2))
  expect_identical(
    partition$state, "nonzero_sum_zero_primary_rate_partitioned"
  )
  expect_true(partition$valid_direction)
  expect_true(partition$sum_zero)
  expect_identical(partition$roles, c("P", "L", "D"))
  expect_identical(partition$role_signature, "PLD")
  expect_identical(partition$positive_indices, 1L)
  expect_identical(partition$leading_negative_indices, 2L)
  expect_identical(partition$deeper_negative_indices, 3L)
  expect_length(partition$zero_indices, 0L)
  expect_equal(partition$canonical_equivalent_rates, c(3, -1, -2))
  expect_true(partition$canonical_equivalent_sum_zero)
  expect_false(partition$secondary_hierarchy_required)

  with_zero <-
    .mfrmr_research$mfrmr_jml_gpcm_rate_role_partition(c(1, -1, 0))
  expect_identical(with_zero$roles, c("P", "L", "Z"))
  expect_true(with_zero$secondary_hierarchy_required)
  expect_identical(with_zero$zero_indices, 3L)

  permutation <- c(3L, 1L, 2L)
  permuted <- .mfrmr_research$mfrmr_jml_gpcm_rate_role_partition(
    c(3, -1, -2)[permutation]
  )
  expect_identical(permuted$roles, partition$roles[permutation])
  expect_equal(
    permuted$canonical_equivalent_rates,
    partition$canonical_equivalent_rates[permutation]
  )
  expect_true(permuted$canonical_equivalent_sum_zero)

  zero <- .mfrmr_research$mfrmr_jml_gpcm_rate_role_partition(c(0, 0, 0))
  expect_identical(zero$state, "all_zero_primary_slope_rate")
  expect_false(zero$valid_direction)
  expect_true(zero$all_zero_primary_slope_rate)
  expect_identical(zero$roles, rep("Z", 3L))
  expect_true(zero$secondary_hierarchy_required)

  invalid <- .mfrmr_research$mfrmr_jml_gpcm_rate_role_partition(c(1, 0, -0.5))
  expect_identical(invalid$state, "invalid_rate_vector")
  expect_false(invalid$sum_zero)
  expect_false(invalid$valid_direction)
})

test_that("combined directions separate slope-primary and additive-primary sectors", {
  joint <- .mfrmr_research$mfrmr_jml_gpcm_compactify_direction(
    additive_displacement = c(2, -1),
    expanded_log_slope_displacement = c(3, -1, -2)
  )
  expect_identical(
    joint$state, "nonzero_slope_primary_direction_partitioned"
  )
  expect_true(joint$valid_direction)
  expect_equal(joint$normalized_norm, 1, tolerance = 1e-14)
  expect_false(joint$slope_primary_zero)
  expect_identical(joint$rate_partition$roles, c("P", "L", "D"))
  expect_false(joint$secondary_hierarchy_required)

  additive <- .mfrmr_research$mfrmr_jml_gpcm_compactify_direction(
    additive_displacement = c(1, -1),
    expanded_log_slope_displacement = c(0, 0, 0)
  )
  expect_identical(
    additive$state, "additive_primary_zero_slope_rate"
  )
  expect_true(additive$valid_direction)
  expect_true(additive$slope_primary_zero)
  expect_true(additive$secondary_hierarchy_required)
  expect_identical(additive$rate_partition$roles, rep("Z", 3L))

  malformed <- .mfrmr_research$mfrmr_jml_gpcm_compactify_direction(
    1, c(1, 0, 0)
  )
  expect_identical(malformed$state, "invalid_direction")
  expect_false(malformed$valid_direction)
})

test_that("nonconvergent normalized rates reduce to distinct subsequences", {
  rate_a <- c(1, -1, 0)
  rate_b <- c(0, 1, -1)
  indices <- seq_len(12L)
  directions <- t(vapply(indices, function(index) {
    rate <- if (index %% 2L == 1L) rate_a else rate_b
    compact <- .mfrmr_research$mfrmr_jml_gpcm_compactify_direction(
      numeric(0), index * rate
    )
    compact$normalized_expanded_log_slopes
  }, numeric(3)))

  expect_gt(min(sqrt(rowSums(diff(directions)^2))), 0.5)
  expect_equal(
    directions[indices %% 2L == 1L, , drop = FALSE],
    matrix(rate_a / sqrt(2), nrow = 6L, ncol = 3L, byrow = TRUE),
    tolerance = 1e-14
  )
  expect_equal(
    directions[indices %% 2L == 0L, , drop = FALSE],
    matrix(rate_b / sqrt(2), nrow = 6L, ncol = 3L, byrow = TRUE),
    tolerance = 1e-14
  )
  expect_false(isTRUE(all(diff(directions) == 0)))
})

test_that("a zero primary rate can carry a divergent secondary hierarchy", {
  primary <- c(1, -1, 0)
  secondary <- c(-0.5, -0.5, 1)
  distances <- c(1e2, 1e4, 1e6)
  paths <- t(vapply(distances, function(distance) {
    distance * primary + sqrt(distance) * secondary
  }, numeric(3)))
  primary_scaled <- paths / distances
  residuals <- paths - outer(distances, primary)
  residual_norms <- sqrt(rowSums(residuals^2))
  residual_directions <- residuals / residual_norms
  classified <-
    .mfrmr_research$mfrmr_jml_gpcm_rate_role_partition(primary)

  expect_equal(rowSums(paths), rep(0, length(distances)), tolerance = 1e-10)
  expect_lt(
    max(abs(primary_scaled[nrow(primary_scaled), ] - primary)),
    max(abs(primary_scaled[1, ] - primary))
  )
  expect_gt(min(diff(residual_norms)), 0)
  expect_equal(
    residual_directions,
    matrix(
      secondary / sqrt(sum(secondary^2)),
      nrow = length(distances), ncol = 3L, byrow = TRUE
    ),
    tolerance = 1e-12
  )
  expect_identical(classified$roles, c("P", "L", "Z"))
  expect_true(classified$secondary_hierarchy_required)
})
