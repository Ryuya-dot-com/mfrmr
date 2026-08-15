# Repository-only candidate-004 rank-hold adjudication contract.
#
# This contract inspects already-retained fit audit layers without refitting.
# It distinguishes additive constrained-design rank, retained-point marginal
# score rank, fitted-information diagnostics, and global/continuous MML
# identification. Local rank cannot clear the fit-level global hold.

mfrmr_cq_p2c4rh_specification <-
  "0.2.3-conquest-p2-candidate-004-rank-hold-contract-v1"
mfrmr_cq_p2c4rh_contract <-
  "mfrmr_conquest_p2_candidate_004_rank_hold_contract_v1"

mfrmr_cq_p2c4rh_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2c4rh_require_contracts <- function() {
  target <- environment(mfrmr_cq_p2c4rh_require_contracts)
  ready <- exists(
    "mfrmr_cq_p2c4no_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_p2c4no_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_p2_candidate_004_numerical_observation_v1"
  ) && exists(
    "mfrmr_cq_p2c4nr_plan", envir = target, mode = "function",
    inherits = TRUE
  ) && exists(
    "mfrmr_cq_p2c4po_review", envir = target, mode = "function",
    inherits = TRUE
  )
  mfrmr_cq_p2c4rh_assert(
    ready, "Source the exact candidate-004 numerical and preflight observations first."
  )
  invisible(TRUE)
}

mfrmr_cq_p2c4rh_layer_registry <- function() {
  data.frame(
    Layer = c(
      "additive_constrained_design",
      "nonlinear_parameter_transformation",
      "observed_pattern_score_span",
      "retained_solution_information",
      "fixed_quadrature_local_estimability",
      "continuous_integral_identification",
      "global_marginal_identification",
      "weak_information_classification",
      "fit_readiness"
    ),
    RequiredEvidence = c(
      "full_column_rank_at_1e-12_1e-10_1e-8_and_no_zero_coordinate",
      "analytic_and_numeric_log_sigma2_maps_full_rank_diagnostic_only",
      "unit_weight_positive_pattern_score_subset_spans_all_free_coordinates",
      "finite_full_positive_rank_ladder_diagnostic_only",
      "local_full_rank_sufficient_for_implemented_fixed_quadrature_model",
      "not_classified_by_retained_local_diagnostics",
      "not_classified_by_retained_local_diagnostics",
      "not_classified_without_prospectively_calibrated_rule",
      "retain_not_evaluated_and_inference_ready_false"
    ),
    PassCanClearFitHold = c(rep(FALSE, 8L), FALSE),
    ExpectedState = c(
      "identified", "evaluated_diagnostic_only",
      "observed_pattern_full_column_rank", "evaluated_diagnostic_only",
      "locally_full_rank_sufficient", "not_classified",
      "not_classified", "not_classified", "not_evaluated"
    ),
    EvidencePromotionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4rh_plan <- function() {
  mfrmr_cq_p2c4rh_require_contracts()
  out <- mfrmr_cq_p2c4nr_plan()[, c(
    "ExecutionOrder", "RunId", "Family", "Nodes", "ExpectedFreeDimension"
  )]
  out$ExpectedAdditiveDimension <- ifelse(out$Family == "RSM", 9L, 13L)
  out$ExpectedNonlinearBlock <- "log_sigma2"
  out$ReadOnlySavedFitInspection <- TRUE
  out$NewFitAuthorized <- FALSE
  out$ReadinessRewriteAuthorized <- FALSE
  mfrmr_cq_p2c4rh_assert(
    nrow(out) == 4L &&
      identical(out$ExpectedFreeDimension, c(10L, 10L, 14L, 14L)) &&
      identical(out$ExpectedAdditiveDimension, c(9L, 9L, 13L, 13L)) &&
      all(out$ReadOnlySavedFitInspection) && !any(out$NewFitAuthorized) &&
      !any(out$ReadinessRewriteAuthorized),
    "The rank-hold inspection plan is incomplete or widened."
  )
  out
}

mfrmr_cq_p2c4rh_fit_path <- function(root, run_id) {
  file.path(root, paste0(run_id, "_fit.rds"))
}

mfrmr_cq_p2c4rh_inspect_fit <- function(fit, arm) {
  audit <- fit$data_review$estimability %||% list()
  readiness <- as.data.frame(audit$readiness %||% data.frame(),
                             stringsAsFactors = FALSE)
  propagated <- as.data.frame(fit$readiness$fit %||% data.frame(),
                              stringsAsFactors = FALSE)
  design <- audit$design %||% list()
  transform <- audit$nonlinear_transformation %||% list()
  observed <- audit$mml_observed_pattern_score %||% list()
  information <- audit$fitted_information %||% list()
  local <- audit$nonlinear_local_estimability %||% list()
  design_ladder <- as.data.frame(design$tolerance_ranks %||% data.frame())
  score_ladder <- as.data.frame(observed$rank_ladder %||% data.frame())
  information_ladder <- as.data.frame(
    information$rank_ladder %||% data.frame()
  )
  transformation_blocks <- as.data.frame(
    transform$block_summary %||% data.frame()
  )
  additive_full <- nrow(design_ladder) == 3L &&
    identical(as.numeric(design_ladder$Tolerance), c(1e-12, 1e-10, 1e-8)) &&
    all(design_ladder$Rank == arm$ExpectedAdditiveDimension) &&
    all(design_ladder$Nullity == 0L) &&
    identical(as.integer(design$rank), arm$ExpectedAdditiveDimension) &&
    identical(as.integer(design$nullity), 0L) &&
    identical(as.character(design$state), "identified") &&
    !isTRUE(design$tolerance_sensitive)
  transform_ready <- identical(as.character(transform$status),
                               "evaluated_diagnostic_only") &&
    identical(as.character(transform$nonlinear_blocks), "log_sigma2") &&
    isTRUE(transform$parameterization_only) &&
    !isTRUE(transform$likelihood_jacobian_evaluated) &&
    !isTRUE(transform$structural_identification_classified) &&
    nrow(transformation_blocks) == 1L &&
    identical(as.integer(transformation_blocks$FreeCoordinates), 1L) &&
    isTRUE(transformation_blocks$LogFullColumnRank) &&
    isTRUE(transformation_blocks$NaturalFullColumnRank)
  score_full <- identical(
    as.character(observed$status),
    "evaluated_observed_pattern_diagnostic_only"
  ) && isTRUE(observed$attempted) && isTRUE(observed$unit_row_weights_observed) &&
    isTRUE(observed$finite_parameter_vector_observed) &&
    isTRUE(observed$observed_patterns_only) &&
    !isTRUE(observed$all_possible_response_patterns_evaluated) &&
    identical(as.integer(observed$person_rows), 48L) &&
    identical(as.integer(observed$free_dimension), arm$ExpectedFreeDimension) &&
    identical(as.integer(observed$score_rank), arm$ExpectedFreeDimension) &&
    identical(as.integer(observed$score_nullity), 0L) &&
    identical(
      as.character(observed$score_rank_state),
      "observed_pattern_full_column_rank"
    ) && nrow(score_ladder) == 3L &&
    all(score_ladder$Rank == arm$ExpectedFreeDimension) &&
    all(score_ladder$Nullity == 0L) &&
    !isTRUE(observed$tolerance_sensitive) &&
    !isTRUE(observed$structural_identification_classified)
  information_ready <- identical(
    as.character(information$status), "evaluated_diagnostic_only"
  ) && isTRUE(information$attempted) &&
    identical(as.integer(information$free_dimension), arm$ExpectedFreeDimension) &&
    nrow(information_ladder) == 3L &&
    all(information_ladder$PositiveRank == arm$ExpectedFreeDimension) &&
    all(information_ladder$NegativeCount == 0L) &&
    all(information_ladder$NearZeroCount == 0L) &&
    !isTRUE(information$weak_information_classified)
  local_full <- identical(
    as.character(local$state), "locally_full_rank_sufficient"
  ) && isTRUE(local$parameter_map_complete) &&
    isTRUE(local$local_first_order_classified) &&
    isTRUE(local$local_full_rank_sufficient) &&
    !isTRUE(local$local_first_order_rank_deficient) &&
    !isTRUE(local$local_nonidentifiability_established) &&
    identical(as.integer(local$local_rank), arm$ExpectedFreeDimension) &&
    identical(as.integer(local$local_nullity), 0L) &&
    !isTRUE(local$tolerance_sensitive)
  global_open <- !isTRUE(local$global_identification_classified) &&
    !isTRUE(local$continuous_integral_identification_classified) &&
    !isTRUE(local$weak_information_classified) &&
    identical(as.character(local$readiness_effect), "none_local_property_only")
  stored_hold <- nrow(readiness) == 1L && nrow(propagated) == 1L &&
    identical(as.character(readiness$EstimabilityState), "identified") &&
    !isTRUE(readiness$Complete) &&
    identical(as.character(readiness$ReasonCodes),
              "design_rank_not_evaluated") &&
    identical(as.character(propagated$EstimabilityState), "not_evaluated") &&
    identical(as.character(propagated$FitReadiness), "review") &&
    !isTRUE(propagated$InferenceReady) &&
    identical(as.character(propagated$ReasonCodes),
              "design_rank_not_evaluated")
  data.frame(
    RunId = arm$RunId, Family = arm$Family, Nodes = arm$Nodes,
    AdditiveRank = as.integer(design$rank),
    AdditiveDimension = arm$ExpectedAdditiveDimension,
    AdditiveNullity = as.integer(design$nullity),
    AdditiveToleranceSensitive = isTRUE(design$tolerance_sensitive),
    AdditiveSmallestSingularValue = as.numeric(design$smallest_singular_value),
    AdditiveConditionIndex = as.numeric(design$condition_index),
    ObservedPatternScoreRank = as.integer(observed$score_rank),
    FullFreeDimension = arm$ExpectedFreeDimension,
    ObservedPatternScoreNullity = as.integer(observed$score_nullity),
    ObservedPatternToleranceSensitive = isTRUE(observed$tolerance_sensitive),
    NonlinearBlock = as.character(transform$nonlinear_blocks),
    LocalState = as.character(local$state),
    GlobalIdentificationClassified =
      isTRUE(local$global_identification_classified),
    ContinuousIntegralIdentificationClassified =
      isTRUE(local$continuous_integral_identification_classified),
    WeakInformationClassified = isTRUE(local$weak_information_classified),
    PropagatedEstimabilityState = as.character(propagated$EstimabilityState),
    PropagatedFitReadiness = as.character(propagated$FitReadiness),
    PropagatedInferenceReady = isTRUE(propagated$InferenceReady),
    AdditiveLayerPass = additive_full,
    TransformationLayerPass = transform_ready,
    ObservedPatternLayerPass = score_full,
    FittedInformationLayerPass = information_ready,
    LocalLayerPass = local_full,
    GlobalHoldCorrectlyRetained = global_open && stored_hold,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4rh_review <- function(mfrmr_root) {
  mfrmr_cq_p2c4rh_require_contracts()
  prior <- mfrmr_cq_p2c4no_review()
  mfrmr_cq_p2c4rh_assert(
    isTRUE(prior$same_author_numeric_core_passed) &&
      !isTRUE(prior$mfrmr_inference_ready),
    "The bounded candidate-004 numerical observation is unavailable."
  )
  root <- normalizePath(mfrmr_root, winslash = "/", mustWork = TRUE)
  plan <- mfrmr_cq_p2c4rh_plan()
  paths <- mfrmr_cq_p2c4rh_fit_path(root, plan$RunId)
  mfrmr_cq_p2c4rh_assert(
    all(file.exists(paths)), "A retained candidate-004 fit is unavailable."
  )
  rows <- do.call(rbind, lapply(seq_len(nrow(plan)), function(index) {
    fit <- readRDS(paths[index])
    mfrmr_cq_p2c4rh_inspect_fit(fit, plan[index, , drop = FALSE])
  }))
  rownames(rows) <- NULL
  complete_local <- nrow(rows) == 4L &&
    all(rows$AdditiveLayerPass) && all(rows$TransformationLayerPass) &&
    all(rows$ObservedPatternLayerPass) &&
    all(rows$FittedInformationLayerPass) && all(rows$LocalLayerPass)
  hold_correct <- complete_local && all(rows$GlobalHoldCorrectlyRetained) &&
    !any(rows$GlobalIdentificationClassified) &&
    !any(rows$ContinuousIntegralIdentificationClassified) &&
    !any(rows$WeakInformationClassified) &&
    all(rows$PropagatedEstimabilityState == "not_evaluated") &&
    all(rows$PropagatedFitReadiness == "review") &&
    !any(rows$PropagatedInferenceReady)
  list(
    specification = mfrmr_cq_p2c4rh_specification,
    contract_version = mfrmr_cq_p2c4rh_contract,
    status = if (complete_local && hold_correct) {
      "candidate_004_local_full_rank_global_nonlinear_identification_open"
    } else {
      "candidate_004_rank_hold_review_failed_or_inconsistent"
    },
    layer_registry = mfrmr_cq_p2c4rh_layer_registry(),
    arm_review = rows,
    all_additive_designs_full_rank = all(rows$AdditiveLayerPass),
    all_observed_pattern_scores_full_rank = all(rows$ObservedPatternLayerPass),
    all_fixed_quadrature_local_states_full_rank = all(rows$LocalLayerPass),
    global_marginal_identification_classified = FALSE,
    continuous_integral_identification_classified = FALSE,
    weak_information_classified = FALSE,
    design_rank_hold_resolved = FALSE,
    mfrmr_inference_ready = FALSE,
    existing_fit_readiness_rewritten = FALSE,
    new_fit_attempted = FALSE,
    independent_comprehensive_review_passed = FALSE,
    evidence_promotion_authorized = FALSE,
    wider_execution_authorized = FALSE,
    P3_execution_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
