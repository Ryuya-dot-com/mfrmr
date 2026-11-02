# JML GPCM finite optimizer-sequence and remainder diagnostics
# ==============================================================================
#
# The optimizer supplies only finitely many stage endpoints, not an asymptotic
# parameter path. This file permits an explicitly supplied finite coordinate
# sequence to receive a Euclidean low-rank direction/scale diagnostic, but no
# estimated direction or exponent is eligible for the exact P2b oracle.
#
# A separate analytic extension covers a narrow remainder class after P2c:
# finitely many scaled-logit residual directions multiplied by negative powers
# of distance. Their within-row category contrasts vanish uniformly, so the
# declared response probabilities and log likelihood retain the P2b limit.


mfrmr_jml_gpcm_remainder_stage_matrices <- function(
    directions, n_observations, n_categories) {
  mfrmr_jml_gpcm_lexicographic_stage_matrices(
    directions, n_observations, n_categories
  )
}

mfrmr_jml_gpcm_decaying_logit_remainder <- function(
    parameter_path_result,
    residual_stage_directions = list(),
    residual_decay_exponents = numeric(0),
    max_stages = 2L) {
  path_valid <- is.list(parameter_path_result) && identical(
    as.character(parameter_path_result$contract_version %||% "")[1],
    mfrmr_jml_gpcm_parameter_path_contract_version()
  ) && isTRUE(
    parameter_path_result$parameter_reachable_limit_contract_completed
  ) && isTRUE(parameter_path_result$limit$declared_path_limit_classified)
  limit <- parameter_path_result$limit %||% list()
  path <- limit$path_definition %||% list()
  n_observations <- nrow(path$base_utilities %||% matrix(numeric(0), 0L, 0L))
  n_categories <- ncol(path$base_utilities %||% matrix(numeric(0), 0L, 0L))
  directions <- mfrmr_jml_gpcm_remainder_stage_matrices(
    residual_stage_directions, n_observations, n_categories
  )
  exponents <- tryCatch(
    suppressWarnings(as.numeric(residual_decay_exponents)),
    error = function(e) NULL
  )
  max_stages_value <-
    mfrmr_jml_gpcm_exponential_balance_scalar(max_stages)
  finish <- function(state, evaluated, certified, detail, reason_codes,
                     stage_table = data.frame(), residual_directions = list()) {
    list(
      contract_version =
        mfrmr_jml_gpcm_sequence_remainder_contract_version(),
      state = state,
      evaluated = isTRUE(evaluated),
      source_parameter_path_contract = as.character(
        parameter_path_result$contract_version %||% "missing"
      )[1],
      source_limit_contract = as.character(limit$contract_version %||% "missing")[1],
      scaled_logit_remainder_class =
        "finite_sum_of_fixed_directions_times_negative_power_scales",
      remainder_stages = as.integer(length(residual_directions)),
      residual_decay_exponents = exponents,
      stage_table = stage_table,
      residual_stage_directions = residual_directions,
      within_row_logit_contrast_remainder_vanishes = isTRUE(certified),
      same_row_probability_limits_certified = isTRUE(certified),
      same_joint_log_likelihood_limit_certified = isTRUE(certified),
      log_likelihood_limit = as.numeric(limit$log_likelihood_limit %||% NA_real_),
      exact_ties_preserved_in_limit = isTRUE(certified),
      finite_distance_ties_required = FALSE,
      arbitrary_utility_remainder_classified = FALSE,
      arbitrary_slope_remainder_classified = FALSE,
      arbitrary_logit_remainder_classified = FALSE,
      optimizer_sequence_remainder_certified = FALSE,
      p2b_limit_extended_only_within_declared_remainder_class = isTRUE(certified),
      global_boundary_classified = FALSE,
      readiness_effect = "none_diagnostic_only",
      external_comparison_eligible = FALSE,
      reason_codes = reason_codes,
      detail = detail,
      limitations = paste(
        "The theorem concerns additive perturbations on the already scaled",
        "category logits whose within-row contrasts decay as fixed negative",
        "powers. It does not separately classify utility or slope remainders,",
        "infer a remainder from optimizer points, cover bounded oscillations",
        "or slower divergent terms, prove competitiveness, or classify a",
        "global boundary, MML, uncertainty, readiness, or comparison."
      )
    )
  }
  if (!path_valid) {
    return(finish(
      "not_evaluated_source_path", FALSE, FALSE,
      "A completed reachable-parameter limit classification is required.",
      "decaying_logit_remainder_source_invalid"
    ))
  }
  controls_valid <- is.finite(max_stages_value) && max_stages_value >= 0 &&
    max_stages_value <= 2 &&
    max_stages_value == floor(max_stages_value)
  if (!controls_valid) {
    return(finish(
      "not_evaluated_control", FALSE, FALSE,
      "The remainder stage limit must be a finite nonnegative integer.",
      "decaying_logit_remainder_control_invalid"
    ))
  }
  if (is.null(directions) || is.null(exponents) ||
      length(directions) != length(exponents) ||
      length(directions) > max_stages_value ||
      any(!is.finite(exponents)) || any(exponents <= 0) ||
      (length(exponents) > 1L && any(diff(exponents) <= 0))) {
    return(finish(
      "not_evaluated_remainder_mapping", FALSE, FALSE,
      "Remainder directions and strictly increasing decay exponents were invalid.",
      "decaying_logit_remainder_mapping_invalid"
    ))
  }
  if (length(directions) == 0L) {
    return(finish(
      "no_logit_remainder_limit_unchanged", TRUE, TRUE,
      "No scaled-logit remainder was declared.",
      "decaying_logit_remainder_vacuous"
    ))
  }
  spans <- vapply(directions, function(direction) {
    max(apply(direction, 1L, function(row) max(row) - min(row)))
  }, numeric(1))
  stage_table <- data.frame(
    Stage = seq_along(directions),
    DecayExponent = exponents,
    MaximumWithinRowCoefficientSpan = spans,
    PairwiseContrastLimit = rep(0, length(directions)),
    stringsAsFactors = FALSE
  )
  finish(
    "decaying_scaled_logit_remainder_same_limit", TRUE, TRUE,
    paste(
      "Every within-row scaled-logit residual contrast is bounded by a finite",
      "sum of fixed coefficients times negative powers and converges to zero."
    ),
    "decaying_logit_remainder_same_probability_and_likelihood_limit",
    stage_table = stage_table,
    residual_directions = directions
  )
}

mfrmr_jml_gpcm_parameter_remainder_loglik_at <- function(
    parameter_path_result, remainder_result, distance) {
  valid <- is.list(parameter_path_result) && is.list(remainder_result) &&
    identical(
      as.character(parameter_path_result$contract_version %||% "")[1],
      mfrmr_jml_gpcm_parameter_path_contract_version()
    ) && identical(
      as.character(remainder_result$contract_version %||% "")[1],
      mfrmr_jml_gpcm_sequence_remainder_contract_version()
    ) && isTRUE(parameter_path_result$parameter_reachable_limit_contract_completed) &&
    isTRUE(remainder_result$same_joint_log_likelihood_limit_certified)
  distance_value <-
    mfrmr_jml_gpcm_exponential_balance_scalar(distance)
  if (!valid || !is.finite(distance_value) || distance_value <= 0) {
    return(list(
      valid = FALSE,
      distance = distance_value,
      log_likelihood = NA_real_,
      row_log_probability = numeric(0),
      reason_codes = "parameter_remainder_evaluation_invalid"
    ))
  }
  path <- parameter_path_result$limit$path_definition
  log_slopes <- path$base_log_slopes
  if (nrow(path$slope_stage_rates) > 0L) {
    for (stage in seq_len(nrow(path$slope_stage_rates))) {
      log_slopes <- log_slopes +
        distance_value^path$slope_scale_exponents[stage] *
        path$slope_stage_rates[stage, ]
    }
  }
  utilities <- path$base_utilities
  if (length(path$additive_stage_directions) > 0L) {
    for (stage in seq_along(path$additive_stage_directions)) {
      utilities <- utilities +
        distance_value^path$additive_scale_exponents[stage] *
        path$additive_stage_directions[[stage]]
    }
  }
  logits <- utilities * matrix(
    exp(log_slopes[path$slope_index]),
    nrow = nrow(utilities), ncol = ncol(utilities)
  )
  if (length(remainder_result$residual_stage_directions) > 0L) {
    for (stage in seq_along(remainder_result$residual_stage_directions)) {
      logits <- logits +
        distance_value^(-remainder_result$residual_decay_exponents[stage]) *
        remainder_result$residual_stage_directions[[stage]]
    }
  }
  row_log_probability <- rep(NA_real_, nrow(logits))
  for (observation in seq_len(nrow(logits))) {
    row <- logits[observation, ]
    if (any(!is.finite(row))) next
    maximum <- max(row)
    observed <- path$score_k[observation] + 1L
    row_log_probability[observation] <-
      row[observed] - (maximum + log(sum(exp(row - maximum))))
  }
  effective <- path$weight > 0
  valid_numeric <- all(is.finite(row_log_probability[effective]))
  list(
    valid = isTRUE(valid_numeric),
    distance = distance_value,
    log_likelihood = if (valid_numeric) {
      sum(path$weight[effective] * row_log_probability[effective])
    } else {
      NA_real_
    },
    row_log_probability = row_log_probability,
    reason_codes = if (valid_numeric) {
      "parameter_path_with_decaying_logit_remainder_evaluated"
    } else {
      "parameter_path_with_remainder_nonfinite"
    }
  )
}
