# JML GPCM global finite-attainment and non-attainment adjudication
# ==============================================================================
#
# P2e classifies a likelihood limit only after taking a further subsequence in
# the exact finite-dimensional response-contrast image. P2f separates two
# global consequences which require different evidence.
#
# First, every finite conditional response probability is strictly below one,
# so the weighted joint log likelihood is strictly below its universal upper
# bound zero. A parameter-reachable divergent path whose analytic limit is
# exactly zero therefore proves that the global supremum is zero and is not
# attained at any finite parameter vector.
#
# More generally, a free extreme-Person direction or a certified global
# additive recession cone gives a strict likelihood improvement from every
# finite point. This also proves that no finite JMLE exists, without identifying
# the value of the global supremum.
#
# In the other direction, continuity gives finite attainment if a finite point
# lies strictly above a verified upper bound for the likelihood limsup of every
# parameter sequence escaping every bounded set. P2e supplies subsequence
# classification, but it does not enumerate or bound the complete boundary
# envelope. The executable implication below therefore keeps a caller-declared
# envelope conditional and never promotes it to a production certificate.


mfrmr_jml_gpcm_reachable_supremum_zero <- function(parameter_path) {
  path_object <- if (is.list(parameter_path)) parameter_path else list()
  limit_object <- if (is.list(path_object$limit)) {
    path_object$limit
  } else {
    list()
  }
  path_definition <- if (is.list(limit_object$path_definition)) {
    limit_object$path_definition
  } else {
    list()
  }
  finish <- function(state, evaluated, certified, detail, reason_codes,
                     limit = NA_real_, divergent_stages = 0L) {
    list(
      contract_version =
        mfrmr_jml_gpcm_global_existence_contract_version(),
      estimator_identity = "unpenalized_fixed_effects_jml_no_finite_box",
      objective_identity = "identified_conditional_joint_log_likelihood",
      state = state,
      evaluated = isTRUE(evaluated),
      source_parameter_path_contract = as.character(
        path_object$contract_version %||% "missing"
      )[1],
      source_parameter_path_contract_matches = identical(
        as.character(path_object$contract_version %||% "")[1],
        mfrmr_jml_gpcm_parameter_path_contract_version()
      ),
      parameter_path_reachability_certified = isTRUE(
        path_object$declared_parameter_path_reachability_certified
      ),
      parameter_path_limit_classified = isTRUE(
        path_object$declared_path_limit_classified
      ),
      divergent_parameter_stages = as.integer(divergent_stages),
      path_escapes_every_bounded_parameter_set = isTRUE(divergent_stages > 0L),
      universal_finite_log_likelihood_upper_bound = 0,
      finite_parameter_log_likelihood_strictly_below_zero = TRUE,
      path_log_likelihood_limit = as.numeric(limit),
      path_reaches_universal_upper_bound = isTRUE(certified),
      global_boundary_competitiveness_certified = isTRUE(certified),
      global_supremum_value_classified = isTRUE(certified),
      global_log_likelihood_supremum = if (isTRUE(certified)) 0 else NA_real_,
      global_supremum_attained_on_declared_boundary = isTRUE(certified),
      global_supremum_attained_at_finite_parameter = FALSE,
      finite_jmle_existence_classified = isTRUE(certified),
      finite_jmle_existence_certified = FALSE,
      finite_jmle_nonexistence_certified = isTRUE(certified),
      global_boundary_classified = isTRUE(certified),
      global_boundary_presence_certified = isTRUE(certified),
      global_boundary_absence_certified = FALSE,
      standard_error_eligible = FALSE,
      confidence_interval_eligible = FALSE,
      external_comparison_eligible = FALSE,
      readiness_effect = "none_diagnostic_only",
      reason_codes = reason_codes,
      detail = detail,
      limitations = paste(
        "This adjudicator uses only an already completed, parameter-reachable",
        "reachable parameter path. A limit below zero does not classify the global supremum.",
        "The result does not apply to MML and does not create uncertainty,",
        "readiness, recovery, simulation, or external-comparison eligibility."
      )
    )
  }

  source_valid <- is.list(parameter_path) && identical(
    as.character(path_object$contract_version %||% "")[1],
    mfrmr_jml_gpcm_parameter_path_contract_version()
  )
  if (!source_valid) {
    return(finish(
      "not_evaluated_source_contract", FALSE, FALSE,
      "A current reachable parameter-path result is required.",
      "global_existence_parameter_path_source_invalid"
    ))
  }
  reachable <- isTRUE(
    path_object$declared_parameter_path_reachability_certified
  ) && isTRUE(path_object$parameter_reachable_limit_contract_completed)
  classified <- isTRUE(path_object$declared_path_limit_classified) &&
    isTRUE(limit_object$declared_path_limit_classified)
  if (!reachable || !classified) {
    return(finish(
      "not_evaluated_parameter_path", FALSE, FALSE,
      "The parameter path was not both reachable and limit-classified.",
      "global_existence_parameter_path_incomplete"
    ))
  }
  slope_stages <- suppressWarnings(as.integer(
    limit_object$slope_stages %||% 0L
  )[1])
  additive_stages <- suppressWarnings(as.integer(
    limit_object$additive_stages %||% 0L
  )[1])
  if (!is.finite(slope_stages) || !is.finite(additive_stages) ||
      slope_stages < 0L || additive_stages < 0L) {
    return(finish(
      "not_evaluated_parameter_path", FALSE, FALSE,
      "The divergent-stage count for the parameter path was malformed.",
      "global_existence_parameter_path_stage_invalid"
    ))
  }
  divergent_stages <- slope_stages + additive_stages
  limit <- mfrmr_jml_gpcm_exponential_balance_scalar(
    path_object$log_likelihood_limit
  )
  observations <- suppressWarnings(as.integer(
    limit_object$observations %||% 0L
  )[1])
  categories <- suppressWarnings(as.integer(
    limit_object$categories %||% 0L
  )[1])
  weights <- tryCatch(
    suppressWarnings(as.numeric(
      path_definition$weight
    )),
    error = function(e) numeric(0)
  )
  finite_response_scope <- is.finite(observations) && observations >= 1L &&
    is.finite(categories) && categories >= 2L &&
    length(weights) == observations && all(is.finite(weights)) &&
    all(weights >= 0) && any(weights > 0)
  if (!is.finite(limit) || !finite_response_scope) {
    return(finish(
      "not_evaluated_parameter_path", FALSE, FALSE,
      "The classified path lacked a finite limit or valid positive-weight response scope.",
      "global_existence_parameter_path_limit_invalid",
      limit = limit, divergent_stages = divergent_stages
    ))
  }
  if (divergent_stages < 1L) {
    return(finish(
      "bounded_parameter_path_not_global_boundary", TRUE, FALSE,
      "A path with no divergent parameter stage cannot establish non-attainment.",
      "global_existence_parameter_path_not_divergent",
      limit = limit, divergent_stages = divergent_stages
    ))
  }
  if (limit != 0) {
    return(finish(
      "reachable_boundary_below_universal_supremum", TRUE, FALSE,
      paste(
        "The reachable divergent path has a classified limit below the",
        "universal upper bound zero, so another finite or boundary point may",
        "still dominate it."
      ),
      "reachable_path_does_not_reach_universal_upper_bound",
      limit = limit, divergent_stages = divergent_stages
    ))
  }
  finish(
    "global_supremum_zero_finite_jmle_nonexistence_certified", TRUE, TRUE,
    paste(
      "The parameter-reachable divergent path attains the universal",
      "conditional log-likelihood upper bound zero in the limit. Every finite",
      "GPCM parameter vector gives strictly positive probability to at least",
      "two categories on each effective row, hence a strictly negative joint",
      "log likelihood, so the supremum is not attained finitely."
    ),
    paste(
      "parameter_reachable_divergent_path",
      "global_log_likelihood_supremum_zero",
      "finite_jmle_nonexistence_certified",
      sep = ";"
    ),
    limit = limit, divergent_stages = divergent_stages
  )
}

mfrmr_jml_gpcm_finite_attainment_gap_theorem <- function(
    finite_log_likelihood,
    boundary_limsup_upper_bound,
    complete_boundary_envelope_declared = FALSE) {
  finite_value <- mfrmr_jml_gpcm_exponential_balance_scalar(
    finite_log_likelihood
  )
  boundary_value <- mfrmr_jml_gpcm_exponential_balance_scalar(
    boundary_limsup_upper_bound
  )
  complete_declared <- identical(complete_boundary_envelope_declared, TRUE)
  valid <- is.finite(finite_value) && !is.na(boundary_value) &&
    boundary_value <= 0 && finite_value < 0
  strict_gap <- valid && finite_value > boundary_value
  conditions <- valid && complete_declared && strict_gap
  list(
    contract_version = mfrmr_jml_gpcm_global_existence_contract_version(),
    estimator_identity = "unpenalized_fixed_effects_jml_no_finite_box",
    objective_identity = "identified_conditional_joint_log_likelihood",
    state = if (!valid) {
      "not_evaluated_boundary_gap_inputs"
    } else if (!complete_declared) {
      "boundary_envelope_incomplete_global_existence_open"
    } else if (!strict_gap) {
      "no_strict_boundary_gap_global_existence_open"
    } else {
      "conditional_finite_attainment_from_declared_complete_boundary_gap"
    },
    evaluated = isTRUE(valid),
    finite_log_likelihood = as.numeric(finite_value),
    boundary_limsup_upper_bound = as.numeric(boundary_value),
    strict_finite_over_boundary_gap = isTRUE(strict_gap),
    complete_boundary_envelope_declared_by_caller = isTRUE(complete_declared),
    complete_boundary_envelope_independently_certified = FALSE,
    objective_continuity_on_finite_parameter_space = TRUE,
    closed_finite_parameter_space = TRUE,
    compact_upper_level_set_follows_conditionally = isTRUE(conditions),
    finite_attainment_follows_conditionally = isTRUE(conditions),
    global_finite_jmle_existence_certified = FALSE,
    global_boundary_absence_certified = FALSE,
    production_decision_eligible = FALSE,
    external_comparison_eligible = FALSE,
    readiness_effect = "none_diagnostic_only",
    reason_codes = if (!valid) {
      "finite_attainment_gap_inputs_invalid"
    } else if (!complete_declared) {
      "complete_boundary_envelope_not_declared"
    } else if (!strict_gap) {
      "strict_finite_over_boundary_gap_absent"
    } else {
      "finite_attainment_implication_conditions_declared"
    },
    detail = if (isTRUE(conditions)) {
      paste(
        "Conditionally on the declared bound covering the limsup of every",
        "parameter sequence escaping every bounded set, the upper level set",
        "through the finite point is bounded. Continuity makes it closed, so",
        "Weierstrass gives a finite global maximizer."
      )
    } else {
      "The strict complete-boundary gap conditions for finite attainment were not supplied."
    },
    limitations = paste(
      "The further-subsequence analysis classifies finite limits but does not enumerate the",
      "complete boundary envelope. Caller declaration of completeness is not",
      "an independent certificate, so this implication cannot promote a fit",
      "to finite-JMLE existence, readiness, inference, or comparison."
    )
  )
}
