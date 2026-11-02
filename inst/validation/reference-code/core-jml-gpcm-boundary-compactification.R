# JML GPCM boundary compactification and primary-rate hierarchy
# ==============================================================================
#
# An arbitrary unbounded sequence in the finite-dimensional identified JML
# parameter space need not have a globally convergent normalized direction.
# The unit sphere is compact, however, so it always has a subsequence whose
# normalized additive and expanded sum-zero log-slope displacement converges.
# A nonzero limiting log-slope direction has a finite asymptotic role pattern:
# positive (P), zero (Z), leading negative (L), or deeper negative (D).
#
# This is a scope theorem, not a boundary-likelihood certificate. Zero primary
# slope rates can carry a slower divergent scale, and the all-zero primary
# slope sector can do the same. Repeating the argument may therefore require a
# secondary hierarchy which this audit deliberately does not classify.


mfrmr_jml_gpcm_rate_role_partition <- function(
    expanded_rates,
    zero_tolerance = 1e-10) {
  rates <- suppressWarnings(as.numeric(expanded_rates))
  tolerance <- suppressWarnings(as.numeric(zero_tolerance)[1])
  valid_tolerance <- length(tolerance) == 1L && is.finite(tolerance) &&
    tolerance >= 0
  finite_input <- length(rates) >= 2L && all(is.finite(rates))
  input_scale <- if (finite_input) max(1, max(abs(rates))) else NA_real_
  sum_zero_residual <- if (finite_input) sum(rates) else NA_real_
  sum_zero <- valid_tolerance && finite_input &&
    abs(sum_zero_residual) <= tolerance * input_scale * length(rates)
  magnitude <- if (finite_input) max(abs(rates)) else NA_real_
  all_zero <- valid_tolerance && finite_input &&
    is.finite(magnitude) && magnitude <= tolerance
  normalized <- if (finite_input && is.finite(magnitude) && magnitude > 0) {
    rates / magnitude
  } else {
    rep(NA_real_, length(rates))
  }
  roles <- rep("invalid", length(rates))
  canonical <- rep(NA_real_, length(rates))
  state <- "invalid_rate_vector"
  valid_direction <- FALSE

  if (valid_tolerance && finite_input && sum_zero && all_zero) {
    roles[] <- "Z"
    canonical[] <- 0
    state <- "all_zero_primary_slope_rate"
  } else if (valid_tolerance && finite_input && sum_zero &&
             is.finite(magnitude) && magnitude > tolerance) {
    positive <- normalized > tolerance
    negative <- normalized < -tolerance
    zero <- !(positive | negative)
    if (any(positive) && any(negative)) {
      leading_value <- max(normalized[negative])
      leading <- negative &
        abs(normalized - leading_value) <= tolerance
      deeper <- negative & !leading
      roles[positive] <- "P"
      roles[zero] <- "Z"
      roles[leading] <- "L"
      roles[deeper] <- "D"
      canonical[positive] <-
        (sum(leading) + 2 * sum(deeper)) / sum(positive)
      canonical[zero] <- 0
      canonical[leading] <- -1
      canonical[deeper] <- -2
      valid_direction <- TRUE
      state <- "nonzero_sum_zero_primary_rate_partitioned"
    }
  }

  list(
    state = state,
    valid_direction = isTRUE(valid_direction),
    finite_input = isTRUE(finite_input),
    sum_zero = isTRUE(sum_zero),
    sum_zero_residual = as.numeric(sum_zero_residual),
    all_zero_primary_slope_rate = isTRUE(all_zero) && isTRUE(sum_zero),
    expanded_rates = rates,
    normalized_rates = normalized,
    roles = roles,
    role_signature = paste(roles, collapse = ""),
    positive_indices = which(roles == "P"),
    zero_indices = which(roles == "Z"),
    leading_negative_indices = which(roles == "L"),
    deeper_negative_indices = which(roles == "D"),
    canonical_equivalent_rates = canonical,
    canonical_equivalent_sum_zero = all(is.finite(canonical)) &&
      abs(sum(canonical)) <= tolerance * max(1, length(canonical)),
    secondary_hierarchy_required = isTRUE(sum_zero) &&
      (isTRUE(all_zero) || any(roles == "Z")),
    zero_tolerance = tolerance,
    criterion_frozen_for_scientific_claims = FALSE
  )
}

mfrmr_jml_gpcm_compactify_direction <- function(
    additive_displacement,
    expanded_log_slope_displacement,
    zero_tolerance = 1e-10) {
  additive <- suppressWarnings(as.numeric(additive_displacement))
  slopes <- suppressWarnings(as.numeric(expanded_log_slope_displacement))
  tolerance <- suppressWarnings(as.numeric(zero_tolerance)[1])
  finite_input <- length(slopes) >= 2L &&
    all(is.finite(additive)) && all(is.finite(slopes)) &&
    is.finite(tolerance) && tolerance >= 0
  combined <- c(additive, slopes)
  scale <- if (finite_input && length(combined) > 0L) {
    max(abs(combined))
  } else {
    NA_real_
  }
  norm <- if (is.finite(scale) && scale > 0) {
    scale * sqrt(sum((combined / scale)^2))
  } else {
    NA_real_
  }
  valid <- finite_input && is.finite(norm) && norm > 0 &&
    abs(sum(slopes)) <= tolerance * max(1, max(abs(slopes))) *
      length(slopes)
  normalized_additive <- if (valid) additive / norm else rep(NA_real_, length(additive))
  normalized_slopes <- if (valid) slopes / norm else rep(NA_real_, length(slopes))
  rate_partition <- mfrmr_jml_gpcm_rate_role_partition(
    normalized_slopes, zero_tolerance = tolerance
  )
  slope_primary_zero <- valid &&
    max(abs(normalized_slopes)) <= tolerance
  state <- if (!valid) {
    "invalid_direction"
  } else if (slope_primary_zero) {
    "additive_primary_zero_slope_rate"
  } else if (isTRUE(rate_partition$valid_direction)) {
    "nonzero_slope_primary_direction_partitioned"
  } else {
    "indeterminate_primary_direction"
  }
  list(
    state = state,
    valid_direction = isTRUE(valid),
    coordinate_system =
      "free_additive_plus_expanded_sum_zero_log_slope_euclidean",
    combined_norm = as.numeric(norm),
    normalized_additive = normalized_additive,
    normalized_expanded_log_slopes = normalized_slopes,
    normalized_norm = if (valid) {
      sqrt(sum(normalized_additive^2) + sum(normalized_slopes^2))
    } else {
      NA_real_
    },
    slope_primary_zero = isTRUE(slope_primary_zero),
    rate_partition = rate_partition,
    secondary_hierarchy_required = isTRUE(valid) &&
      (isTRUE(slope_primary_zero) ||
         isTRUE(rate_partition$secondary_hierarchy_required)),
    zero_tolerance = tolerance,
    criterion_frozen_for_scientific_claims = FALSE
  )
}
