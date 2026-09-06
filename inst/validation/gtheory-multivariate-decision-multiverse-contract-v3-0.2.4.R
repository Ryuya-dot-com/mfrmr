# Internal D-SIM-0 v3 bounded decision-multiverse contract.
#
# Source the v1 and v2 decision contracts plus the multivariate c1 ADEMP plan
# first. V3 retains v2 as reference profile P0, preregisters a deterministic
# policy-profile generator, and separates decision families, data-generating
# worlds, and analysis routes. It generates no data and authorizes no fit.

mfrmr_gtds_v3_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtds_v2_contract",
    "mfrmr_gtds_v2_validate_contract", "mfrmr_gtvd_plan"
  )
  function_environment <- environment(mfrmr_gtds_v3_require_primitives)
  available <- vapply(required, function(id) {
    exists(id, envir = function_environment, mode = "function",
           inherits = TRUE)
  }, logical(1L))
  if (!all(available)) {
    stop("Source the D-SIM-0 v2 contract and c1 ADEMP plan before v3.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds_v3_decision_family_registry <- function() {
  data.frame(
    DecisionFamilyOrdinal = 1:2,
    DecisionFamilyId = c("ABS-PHI", "REL-G"),
    DecisionPurpose = c(
      "absolute_score_dependability_not_cut_score_classification",
      "relative_rank_order_dependability"
    ),
    Coefficient = c("Phi", "G"),
    ReferenceTargetValue = c(0.80, NA_real_),
    ReferenceTargetStatus = c(
      "provisional_v2_reference_owner_confirmation_pending",
      "owner_definition_pending"
    ),
    CrossFamilyPoolingAllowed = FALSE,
    CrossFamilyVotingAllowed = FALSE,
    OwnerEnablementStatus = "pending",
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v3_axis_registry <- function() {
  data.frame(
    AxisOrdinal = c(rep(1L, 3L), rep(2L, 3L), rep(3L, 3L),
                    rep(4L, 2L), rep(5L, 2L)),
    AxisId = c(
      rep("TargetPolicy", 3L), rep("WeightPolicy", 3L),
      rep("RaterSharing", 3L), rep("CostModel", 2L),
      rep("Comparator", 2L)
    ),
    LevelOrdinal = c(1:3, 1:3, 1:3, 1:2, 1:2),
    LevelId = c(
      "reference", "lower", "higher",
      "equal_common_unit", "owner_fixed", "external_standardized",
      "common", "partial_one_common_rater", "independent",
      "rating_event_only", "rating_event_plus_rater_overhead",
      "all_strata_threshold", "status_quo_operational"
    ),
    Meaning = c(
      "owner-frozen reference target for this decision family",
      "owner-frozen lower policy target; no post-result calibration",
      "owner-frozen higher policy target; no post-result calibration",
      "equal weights on same-direction common-unit fixed strata",
      "owner-supplied nonnegative fixed weights summing to one",
      "equal weights after an externally frozen scale transformation",
      "the same prospective rater identities appear in every stratum",
      "one prospective rater identity is common to every stratum",
      "prospective rater identities are disjoint across strata",
      "strata times raters times repeats rating events per object",
      "rating events plus an owner-frozen cost per unique rater",
      "every separate-univariate stratum coefficient meets its target",
      "a frozen current operational allocation/action rule"
    ),
    OwnerInputRequired = c(
      TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, FALSE, FALSE,
      FALSE, TRUE, FALSE, TRUE
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v3_axis_levels <- function(axis_registry =
                                        mfrmr_gtds_v3_axis_registry()) {
  split(
    axis_registry$LevelId,
    factor(axis_registry$AxisId,
           levels = unique(axis_registry$AxisId))
  )
}

mfrmr_gtds_v3_profile_grid <- function(axis_registry =
                                         mfrmr_gtds_v3_axis_registry()) {
  levels <- mfrmr_gtds_v3_axis_levels(axis_registry)
  grid <- expand.grid(
    levels, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  grid$ProfileSignature <- do.call(
    paste, c(grid[names(levels)], sep = "|")
  )
  grid
}

mfrmr_gtds_v3_pair_tokens <- function(profile, axis_ids) {
  unlist(lapply(seq_len(length(axis_ids) - 1L), function(left) {
    vapply((left + 1L):length(axis_ids), function(right) {
      paste(
        axis_ids[[left]], profile[[axis_ids[[left]]]],
        axis_ids[[right]], profile[[axis_ids[[right]]]], sep = "="
      )
    }, character(1L))
  }), use.names = FALSE)
}

mfrmr_gtds_v3_sentinel_profile_registry <- function(
    decision_family_id,
    axis_registry = mfrmr_gtds_v3_axis_registry(), cap = 12L) {
  decision_family_id <- as.character(decision_family_id)
  known_families <- mfrmr_gtds_v3_decision_family_registry()$DecisionFamilyId
  if (length(decision_family_id) != 1L ||
      !decision_family_id %in% known_families) {
    stop("`decision_family_id` must be ABS-PHI or REL-G.", call. = FALSE)
  }
  cap <- as.integer(cap)
  if (length(cap) != 1L || is.na(cap) || cap < 1L) {
    stop("`cap` must be one positive integer.", call. = FALSE)
  }
  grid <- mfrmr_gtds_v3_profile_grid(axis_registry)
  axis_ids <- unique(axis_registry$AxisId)
  tokens <- lapply(seq_len(nrow(grid)), function(index) {
    mfrmr_gtds_v3_pair_tokens(grid[index, , drop = FALSE], axis_ids)
  })
  universe <- sort(unique(unlist(tokens)), method = "radix")
  anchor <- which(
    grid$TargetPolicy == "reference" &
      grid$WeightPolicy == "equal_common_unit" &
      grid$RaterSharing == "common" &
      grid$CostModel == "rating_event_only" &
      grid$Comparator == "all_strata_threshold"
  )
  if (length(anchor) != 1L) {
    stop("The policy grid has no unique reference anchor.", call. = FALSE)
  }
  selected <- anchor
  uncovered <- setdiff(universe, tokens[[anchor]])
  while (length(uncovered) > 0L && length(selected) < cap) {
    candidates <- setdiff(seq_len(nrow(grid)), selected)
    scores <- vapply(candidates, function(index) {
      sum(tokens[[index]] %in% uncovered)
    }, integer(1L))
    best_score <- max(scores)
    tied <- candidates[scores == best_score]
    best <- tied[order(grid$ProfileSignature[tied], method = "radix")][[1L]]
    selected <- c(selected, best)
    uncovered <- setdiff(uncovered, tokens[[best]])
  }
  profiles <- grid[selected, , drop = FALSE]
  profiles$DecisionFamilyId <- decision_family_id
  profiles$ProfileOrdinal <- seq_len(nrow(profiles))
  profiles$ProfileId <- sprintf(
    "%s-P%02d", decision_family_id, profiles$ProfileOrdinal - 1L
  )
  profiles$ReferenceProfile <- profiles$ProfileOrdinal == 1L
  profiles$OwnerInputsComplete <- FALSE
  profiles$DecisionBearing <- FALSE
  profiles$PairwiseCoverageComplete <- length(uncovered) == 0L
  profiles$CoveredPairCount <- length(universe) - length(uncovered)
  profiles$DeclaredPairCount <- length(universe)
  profiles <- profiles[c(
    "DecisionFamilyId", "ProfileOrdinal", "ProfileId", "ReferenceProfile",
    "TargetPolicy", "WeightPolicy", "RaterSharing", "CostModel",
    "Comparator", "ProfileSignature", "OwnerInputsComplete",
    "DecisionBearing", "PairwiseCoverageComplete", "CoveredPairCount",
    "DeclaredPairCount"
  )]
  attr(profiles, "UncoveredPairTokens") <- uncovered
  profiles
}

mfrmr_gtds_v3_all_sentinel_profiles <- function(cap = 12L) {
  families <- mfrmr_gtds_v3_decision_family_registry()$DecisionFamilyId
  do.call(rbind, lapply(families, function(family) {
    mfrmr_gtds_v3_sentinel_profile_registry(family, cap = cap)
  }))
}

mfrmr_gtds_v3_decision_profile_registry <- function(
    decision_family_id,
    axis_registry = mfrmr_gtds_v3_axis_registry(), sentinel_cap = 12L) {
  decision_family_id <- as.character(decision_family_id)
  known_families <- mfrmr_gtds_v3_decision_family_registry()$DecisionFamilyId
  if (length(decision_family_id) != 1L ||
      !decision_family_id %in% known_families) {
    stop("`decision_family_id` must be ABS-PHI or REL-G.", call. = FALSE)
  }
  grid <- mfrmr_gtds_v3_profile_grid(axis_registry)
  anchor_signature <- paste(
    "reference", "equal_common_unit", "common", "rating_event_only",
    "all_strata_threshold", sep = "|"
  )
  anchor <- which(grid$ProfileSignature == anchor_signature)
  if (length(anchor) != 1L) {
    stop("The policy grid has no unique reference anchor.", call. = FALSE)
  }
  remaining <- setdiff(seq_len(nrow(grid)), anchor)
  order_index <- c(
    anchor,
    remaining[order(grid$ProfileSignature[remaining], method = "radix")]
  )
  profiles <- grid[order_index, , drop = FALSE]
  sentinels <- mfrmr_gtds_v3_sentinel_profile_registry(
    decision_family_id, axis_registry, sentinel_cap
  )
  profiles$DecisionFamilyId <- decision_family_id
  profiles$ProfileOrdinal <- seq_len(nrow(profiles))
  profiles$ProfileId <- sprintf(
    "%s-P%03d", decision_family_id, profiles$ProfileOrdinal - 1L
  )
  profiles$ReferenceProfile <- profiles$ProfileSignature == anchor_signature
  profiles$SentinelProfile <-
    profiles$ProfileSignature %in% sentinels$ProfileSignature
  profiles$DecisionBearing <- TRUE
  profiles$OwnerInputsComplete <- FALSE
  profiles$FullEnumerationComplete <-
    nrow(profiles) == nrow(grid) &&
    setequal(profiles$ProfileSignature, grid$ProfileSignature)
  profiles$DeclaredProfileCount <- nrow(grid)
  profiles[c(
    "DecisionFamilyId", "ProfileOrdinal", "ProfileId", "ReferenceProfile",
    "SentinelProfile", "DecisionBearing", "TargetPolicy", "WeightPolicy",
    "RaterSharing", "CostModel", "Comparator", "ProfileSignature",
    "OwnerInputsComplete", "FullEnumerationComplete",
    "DeclaredProfileCount"
  )]
}

mfrmr_gtds_v3_all_decision_profiles <- function(sentinel_cap = 12L) {
  families <- mfrmr_gtds_v3_decision_family_registry()$DecisionFamilyId
  do.call(rbind, lapply(families, function(family) {
    mfrmr_gtds_v3_decision_profile_registry(
      family, sentinel_cap = sentinel_cap
    )
  }))
}

mfrmr_gtds_v3_world_registry <- function(plan = mfrmr_gtvd_plan()) {
  scenarios <- plan$ScenarioRegistry
  if (!is.data.frame(scenarios) ||
      !all(c("ScenarioId", "ScenarioClass") %in% names(scenarios))) {
    stop("The c1 plan has no usable scenario registry.", call. = FALSE)
  }
  role <- ifelse(
    scenarios$ScenarioClass == "regular_interior",
    "primary_decision_stress",
    ifelse(
      scenarios$ScenarioClass == "structural_rank_negative_control",
      "structural_negative_control", "safety_boundary_only"
    )
  )
  data.frame(
    WorldOrdinal = seq_len(nrow(scenarios)),
    WorldId = scenarios$ScenarioId,
    ScenarioClass = scenarios$ScenarioClass,
    DecisionEvidenceRole = role,
    CountsAsIndependentDatasetOnlyAfterGeneration = TRUE,
    PlannedResponseGenerated = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v3_analysis_route_registry <- function() {
  data.frame(
    RouteOrdinal = 1:7,
    RouteId = c(
      "mv_reml_glmmtmb", "mv_reml_lme4", "mv_ml_glmmtmb",
      "mv_ml_lme4", "uv_reml_glmmtmb", "uv_reml_lme4",
      "naive_pooling_negative_control"
    ),
    EstimandGroup = c(
      "multivariate_reml", "multivariate_reml", "multivariate_ml",
      "multivariate_ml", "separate_univariate_reml",
      "separate_univariate_reml", "naive_pooling"
    ),
    Backend = c(
      "glmmTMB", "lme4", "glmmTMB", "lme4", "glmmTMB", "lme4",
      "implementation_to_be_frozen"
    ),
    EvidenceRole = c(
      "primary_candidate_implementation",
      "design_restricted_sensitivity_only", "estimator_sensitivity",
      "design_restricted_estimator_sensitivity",
      "decision_comparator_implementation", "comparator_parity",
      "negative_control_only"
    ),
    GeneralMultivariateGTheoryEligible = c(
      TRUE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE
    ),
    CorrelatedResidualCapable = c(
      TRUE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE
    ),
    NativeLevelOneCorrelatedResidualApi = FALSE,
    ResidualRepresentation = c(
      "observation_event_random_effect_block_plus_suppressed_dispersion",
      "one_scale_times_known_diagonal_inverse_weights",
      "observation_event_random_effect_block_plus_suppressed_dispersion",
      "one_scale_times_known_diagonal_inverse_weights",
      "separate_stratum_residual_no_cross_stratum_block",
      "separate_stratum_residual_no_cross_stratum_block",
      "not_applicable_negative_control"
    ),
    EligibilityCondition = c(
      paste(
        "primary only after every random and residual covariance block is",
        "matched to the declared sharing design and redundant dispersion is",
        "excluded"
      ),
      paste(
        "restricted sensitivity only when every random-effect block maps to",
        "lme4's supported us, diag, cs, or ar1 structures and the level-1",
        "residual needs no estimated cross-stratum covariance beyond one",
        "scale times known diagonal weights;",
        "never the general multivariate primary route"
      ),
      paste(
        "ML sensitivity after the same covariance-design and residual",
        "identity gates as the REML glmmTMB route"
      ),
      paste(
        "restricted ML sensitivity only under the same random-block and",
        "diagonal level-1 residual limitations as the REML lme4 route;",
        "never evidence of general multivariate support"
      ),
      "separate-stratum comparator; does not recover cross-stratum covariance",
      "backend parity for the separate-stratum comparator only",
      "deliberately invalid pooled-score comparator"
    ),
    LiteratureZoteroItemKey = c(
      rep("2BQX642B", 4L), rep("SNCXIENG", 2L), "2BQX642B"
    ),
    CountsAsIndependentEstimandVote = FALSE,
    PublicSupportReady = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v3_covariance_design_registry <- function() {
  data.frame(
    DesignOrdinal = 1:4,
    DesignId = c(
      "disjoint_conditions_by_stratum",
      "identical_conditions_scored_across_strata",
      "partial_or_mixed_condition_sharing",
      "current_c1_matched_backend_overlap"
    ),
    CanonicalAnalogue = c(
      "p_dot_cross_i_prime", "p_dot_cross_i_dot",
      "explicit_overlap_extension", "not_a_complete_mg_design"
    ),
    PersonOrObjectBlock = c(
      "unstructured_across_strata", "unstructured_across_strata",
      "unstructured_across_strata", "unstructured_across_strata"
    ),
    ConditionBlock = c(
      "diagonal_across_disjoint_conditions",
      "unstructured_across_shared_conditions",
      "explicit_block_mask_from_canonical_incidence",
      "all_nonresidual_components_unstructured_across_strata"
    ),
    ResidualBlock = c(
      "diagonal_for_distinct_observation_events",
      "unstructured_when_one_event_yields_multiple_stratum_scores",
      "explicit_event_identity_required_no_automatic_interpolation",
      "one_common_scalar_homoskedastic_independent_across_rows"
    ),
    GeneralPrimaryBackend = c(
      "glmmTMB", "glmmTMB", "custom_glmmTMB_or_new_contract",
      "matched_lme4_glmmTMB_overlap_only"
    ),
    Lme4GeneralRouteAllowed = FALSE,
    RepresentedByCurrentC1 = c(FALSE, FALSE, FALSE, TRUE),
    CurrentBindingStatus = c(
      rep("pending_before_DSIM1", 3L),
      "implemented_candidate_requires_operational_design_match"
    ),
    LiteratureZoteroItemKey = "2BQX642B",
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v3_observation_event_design_candidate <- function() {
  data.frame(
    StratumCount = c(2L, 3L),
    ConditionSetRelationship = NA_character_,
    ObservationEventRelationship = NA_character_,
    ConditionIncidenceIdentity = "",
    ObservationEventMapIdentity = "",
    OwnerConfirmed = FALSE,
    EvidenceIdentity = "",
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v3_random_block_mapping_candidate <- function() {
  do.call(rbind, lapply(c(2L, 3L), function(stratum_count) {
    data.frame(
      StratumCount = stratum_count,
      ComponentId = c("Object", "Rater", "Object:Rater"),
      StructureClass = NA_character_,
      MappingIdentity = "",
      MethodologistConfirmed = FALSE,
      EvidenceIdentity = "",
      stringsAsFactors = FALSE
    )
  }))
}

mfrmr_gtds_v3_validate_covariance_binding <- function(
    observation_events, random_blocks, require_complete = FALSE) {
  event_names <- c(
    "StratumCount", "ConditionSetRelationship",
    "ObservationEventRelationship", "ConditionIncidenceIdentity",
    "ObservationEventMapIdentity", "OwnerConfirmed", "EvidenceIdentity"
  )
  random_names <- c(
    "StratumCount", "ComponentId", "StructureClass", "MappingIdentity",
    "MethodologistConfirmed", "EvidenceIdentity"
  )
  allowed_conditions <- c(
    "disjoint_by_stratum", "identical_shared_across_strata",
    "partial_or_mixed_explicit_incidence"
  )
  allowed_events <- c(
    "distinct_event_per_stratum_score",
    "one_event_yields_multiple_stratum_scores",
    "mixed_explicit_event_map"
  )
  allowed_structures <- c(
    "unstructured", "diagonal", "compound_symmetric", "ar1",
    "explicit_mask_or_other"
  )
  expected_random <- do.call(rbind, lapply(c(2L, 3L), function(count) {
    data.frame(
      StratumCount = count,
      ComponentId = c("Object", "Rater", "Object:Rater"),
      stringsAsFactors = FALSE
    )
  }))
  structural <- is.data.frame(observation_events) &&
    identical(names(observation_events), event_names) &&
    identical(observation_events$StratumCount, c(2L, 3L)) &&
    is.character(observation_events$ConditionSetRelationship) &&
    is.character(observation_events$ObservationEventRelationship) &&
    is.character(observation_events$ConditionIncidenceIdentity) &&
    is.character(observation_events$ObservationEventMapIdentity) &&
    is.logical(observation_events$OwnerConfirmed) &&
    is.character(observation_events$EvidenceIdentity) &&
    all(is.na(observation_events$ConditionSetRelationship) |
          observation_events$ConditionSetRelationship %in%
            allowed_conditions) &&
    all(is.na(observation_events$ObservationEventRelationship) |
          observation_events$ObservationEventRelationship %in%
            allowed_events) &&
    is.data.frame(random_blocks) &&
    identical(names(random_blocks), random_names) &&
    identical(random_blocks$StratumCount, expected_random$StratumCount) &&
    identical(random_blocks$ComponentId, expected_random$ComponentId) &&
    is.character(random_blocks$StructureClass) &&
    is.character(random_blocks$MappingIdentity) &&
    is.logical(random_blocks$MethodologistConfirmed) &&
    is.character(random_blocks$EvidenceIdentity) &&
    all(is.na(random_blocks$StructureClass) |
          random_blocks$StructureClass %in% allowed_structures)
  if (!structural) {
    stop("The observation-event covariance binding is malformed.",
         call. = FALSE)
  }
  if (!isTRUE(require_complete)) return(invisible(TRUE))
  complete <- !anyNA(observation_events$ConditionSetRelationship) &&
    !anyNA(observation_events$ObservationEventRelationship) &&
    all(nzchar(observation_events$ConditionIncidenceIdentity)) &&
    all(nzchar(observation_events$ObservationEventMapIdentity)) &&
    all(observation_events$OwnerConfirmed) &&
    all(nzchar(observation_events$EvidenceIdentity)) &&
    !anyNA(random_blocks$StructureClass) &&
    all(nzchar(random_blocks$MappingIdentity)) &&
    all(random_blocks$MethodologistConfirmed) &&
    all(nzchar(random_blocks$EvidenceIdentity))
  if (!complete) {
    stop("The observation-event covariance binding is incomplete.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds_v3_backend_design_qualification <- function(
    observation_events, random_blocks,
    routes = mfrmr_gtds_v3_analysis_route_registry()) {
  mfrmr_gtds_v3_validate_covariance_binding(
    observation_events, random_blocks, require_complete = TRUE
  )
  supported_random <- c(
    "unstructured", "diagonal", "compound_symmetric", "ar1"
  )
  rows <- list()
  index <- 0L
  for (event_row in seq_len(nrow(observation_events))) {
    event <- observation_events[event_row, , drop = FALSE]
    blocks <- random_blocks[
      random_blocks$StratumCount == event$StratumCount, , drop = FALSE
    ]
    random_supported <- all(blocks$StructureClass %in% supported_random)
    condition_block <- switch(
      event$ConditionSetRelationship,
      disjoint_by_stratum = "diagonal_across_strata",
      identical_shared_across_strata = "unstructured_across_strata",
      partial_or_mixed_explicit_incidence =
        "explicit_incidence_mask_required"
    )
    residual_block <- switch(
      event$ObservationEventRelationship,
      distinct_event_per_stratum_score = "diagonal_across_strata",
      one_event_yields_multiple_stratum_scores =
        "unstructured_across_strata",
      mixed_explicit_event_map = "explicit_event_mask_required"
    )
    canonical_design <- if (
      event$ConditionSetRelationship == "disjoint_by_stratum" &&
        event$ObservationEventRelationship ==
          "distinct_event_per_stratum_score"
    ) {
      "disjoint_conditions_by_stratum"
    } else if (
      event$ConditionSetRelationship ==
        "identical_shared_across_strata" &&
        event$ObservationEventRelationship ==
          "one_event_yields_multiple_stratum_scores"
    ) {
      "identical_conditions_scored_across_strata"
    } else if (
      event$ConditionSetRelationship ==
        "partial_or_mixed_explicit_incidence" &&
        event$ObservationEventRelationship == "mixed_explicit_event_map"
    ) {
      "partial_or_mixed_condition_sharing"
    } else {
      "explicit_hybrid_design"
    }
    for (route_row in seq_len(nrow(routes))) {
      route <- routes[route_row, , drop = FALSE]
      multivariate_route <- route$RouteId %in% c(
        "mv_reml_glmmtmb", "mv_ml_glmmtmb",
        "mv_reml_lme4", "mv_ml_lme4"
      )
      custom_required <- !random_supported ||
        residual_block == "explicit_event_mask_required" ||
        condition_block == "explicit_incidence_mask_required"
      glmmtmb_route <- route$RouteId %in%
        c("mv_reml_glmmtmb", "mv_ml_glmmtmb")
      lme4_route <- route$RouteId %in%
        c("mv_reml_lme4", "mv_ml_lme4")
      eligible <- multivariate_route && !custom_required && (
        glmmtmb_route ||
          (lme4_route && residual_block == "diagonal_across_strata")
      )
      eligibility_status <- if (!multivariate_route) {
        "not_general_multivariate_route"
      } else if (custom_required) {
        "custom_contract_required"
      } else if (lme4_route &&
                 residual_block != "diagonal_across_strata") {
        "ineligible_correlated_level1_residual"
      } else if (eligible) {
        "conditional_candidate_design_identity_complete"
      } else {
        "ineligible"
      }
      residual_representation <- if (glmmtmb_route &&
          residual_block == "diagonal_across_strata") {
        paste(
          "diagonal_observation_event_random_effect_block_plus",
          "suppressed_dispersion", sep = "_"
        )
      } else if (glmmtmb_route &&
                 residual_block == "unstructured_across_strata") {
        paste(
          "unstructured_observation_event_random_effect_block_plus",
          "suppressed_dispersion", sep = "_"
        )
      } else if (lme4_route &&
                 residual_block == "diagonal_across_strata") {
        "one_scale_times_known_diagonal_inverse_weights"
      } else if (lme4_route &&
                 residual_block == "unstructured_across_strata") {
        "unsupported_cross_stratum_level1_residual"
      } else if (multivariate_route && custom_required) {
        "custom_contract_required"
      } else {
        "not_applicable"
      }
      index <- index + 1L
      rows[[index]] <- data.frame(
        StratumCount = event$StratumCount,
        CanonicalDesignClass = canonical_design,
        ConditionBlock = condition_block,
        ResidualBlock = residual_block,
        RouteId = route$RouteId,
        Backend = route$Backend,
        RandomBlocksSupported = random_supported,
        BackendDesignEligible = eligible,
        EligibilityStatus = eligibility_status,
        ResidualRepresentation = residual_representation,
        ConditionIncidenceIdentity = event$ConditionIncidenceIdentity,
        ObservationEventMapIdentity = event$ObservationEventMapIdentity,
        ExecutionAllowed = FALSE,
        stringsAsFactors = FALSE
      )
    }
  }
  do.call(rbind, rows)
}

mfrmr_gtds_v3_weight_policy_registry <- function() {
  data.frame(
    WeightTypeOrdinal = 1:3,
    WeightType = c(
      "nominal_owner_fixed", "effective_component_contribution",
      "data_driven_optimized"
    ),
    Meaning = c(
      "external substantive importance fixed before outcomes",
      "realized variance-covariance contribution under fixed nominal weights",
      "weights selected from observed or simulated outcomes to optimize an index"
    ),
    DecisionBearingAllowed = c(TRUE, FALSE, FALSE),
    DiagnosticReportingAllowed = c(TRUE, TRUE, TRUE),
    RequiredTreatment = c(
      "retain exact owner identity order and external evidence",
      "label diagnostic and never substitute for nominal policy weights",
      "report only as exploratory sensitivity under a new selection contract"
    ),
    LiteratureZoteroItemKey = c("2BQX642B", "SNCXIENG", "2BQX642B"),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v3_measurement_layer_registry <- function() {
  data.frame(
    LayerOrdinal = 1:4,
    LayerId = c(
      "response_family", "observed_facet", "fixed_multivariate_stratum",
      "irt_latent_dimension"
    ),
    Defines = c(
      "probability kernel and observed response scale",
      "observed rater item task or occasion incidence and effects",
      "named subscale or outcome with cross-stratum covariance components",
      "person ability vector with an explicit loading or discrimination map"
    ),
    CurrentV3Role = c(
      "Gaussian continuous decision-simulation layer only",
      "random measurement conditions and prospective sharing operators",
      "fixed strata combined by externally identified nominal weights",
      "not fitted or inferred by D-SIM-0 v3"
    ),
    MustNotBeInferredFrom = c(
      "category count facet count or latent dimension count",
      "latent dimension count or multivariate outcome count",
      "number of observed facets or IRT integration dimension",
      "facet count subscale count random-effect rank or the word multidimensional"
    ),
    ConflationProhibited = TRUE,
    LiteratureZoteroItemKey = c(
      "5ECJR6HJ", "NBA428KJ", "2BQX642B", "38TX837G"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v3_complementary_diagnostic_registry <- function() {
  data.frame(
    MethodOrdinal = 1:2,
    MethodId = c("multivariate_g_theory", "many_facet_rasch_diagnostic"),
    PrimaryQuestion = c(
      "which variance covariance and design components govern dependability",
      "which individual raters or other facet levels show severity misfit bias or centrality"
    ),
    SubstitutesForOtherMethod = FALSE,
    CountsAsDecisionVote = FALSE,
    ConnectivityGateRequired = c(TRUE, TRUE),
    CurrentDecisionRole = c(
      "registered G and Phi decision evidence",
      "nondecision complementary diagnostic only"
    ),
    CurrentExecutionStatus = c(
      "technical_contract_only", "diagnostic_contract_not_yet_frozen"
    ),
    LiteratureZoteroItemKey = c("NBA428KJ", "NBA428KJ"),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v3_signoff_requirements <- function() {
  data.frame(
    RequirementOrdinal = seq_len(13L),
    RequirementId = c(
      "named_owner", "decision_family_enablement", "family_targets",
      "weight_inputs", "score_scale_inputs", "rater_sharing_topology",
      "observation_event_covariance_design", "cost_inputs",
      "status_quo_comparator", "allocation_feasibility",
      "profile_generation_rule", "robustness_action_rule", "external_anchor"
    ),
    RequiredConfirmation = c(
      "A named practical owner accepts the multiverse and its consequences.",
      "ABS-PHI and REL-G are enabled or disabled separately without pooling.",
      "Lower, reference, and higher targets are fixed for each enabled family.",
      "Every enabled fixed-weight policy has an external weight identity.",
      "Common-unit or externally standardized scale identities are fixed.",
      "Common, one-common-rater, and independent sharing are all feasible.",
      paste(
        "Condition incidence, observation-event linkage, and every random",
        "block mapping are externally identified and methodologist-confirmed."
      ),
      "Unique-rater overhead and rating-event costs are fixed before outcomes.",
      "The current operational allocation/action comparator is frozen.",
      "Every retained allocation is operationally feasible for its profile.",
      paste(
        "All 108 profiles per family are decision-bearing; the 11-profile",
        "pairwise set is nondecision smoke/parity evidence only."
      ),
      "Robust, conditional, and unsupported action rules are accepted.",
      "The unchanged contract hash is bound to an external decision anchor."
    ),
    Confirmed = FALSE,
    Evidence = "",
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v3_owner_input_schema <- function() {
  data.frame(
    InputOrdinal = seq_len(13L),
    InputId = c(
      "decision_family_enablement", "target_triplets",
      "absolute_reference_target", "common_unit_scale_identity",
      "owner_fixed_weight_vectors", "external_standardization_identity",
      "rater_sharing_feasibility", "partial_sharing_topology",
      "observation_event_covariance_design", "rater_overhead_cost",
      "status_quo_comparator",
      "candidate_allocation_feasibility", "action_mapping"
    ),
    RequiredType = c(
      "logical_by_family", "numeric_triplet_by_enabled_family",
      "numeric_scalar", "external_identity_by_stratum_count",
      "numeric_vector_by_family_and_stratum_count",
      "external_identity_by_family_and_stratum_count",
      "logical_by_sharing_level", "external_operational_identity",
      "event_incidence_plus_component_mapping_by_stratum_count",
      "nonnegative_numeric_plus_unit", "external_policy_identity",
      "logical_by_stratum_count_and_allocation", "external_policy_identity"
    ),
    Constraint = c(
      "ABS-PHI and REL-G are separate; at least one is enabled",
      "0 <= lower < reference < higher <= 1 for each enabled family",
      "ABS-PHI reference is 0.80; changing it requires a new contract version",
      "same direction and common interpretable units are externally identified",
      "nonnegative fixed weights sum to one in exact stratum order",
      "transformation is external, frozen, and does not use simulation outcomes",
      "common, one-common-rater, and independent are each accepted or v3 is regenerated",
      "one rater identity is common to every stratum and all others are disjoint",
      paste(
        "condition sets, observation events, and Object/Rater/Object:Rater",
        "structures are fixed before outcomes; explicit masks require a new",
        "custom route contract"
      ),
      "unique-rater overhead is fixed before outcomes in declared cost units",
      "current allocation and action rule are fixed before outcomes",
      "every retained 2/3/4-rater by 1/2-repeat allocation is feasible",
      "build, integrate, park, kill consequences are externally identified"
    ),
    OwnerInputPresent = FALSE,
    EvidenceIdentity = "",
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v3_owner_decision_brief_schema <- function() {
  input_schema <- mfrmr_gtds_v3_owner_input_schema()
  data.frame(
    InputOrdinal = input_schema$InputOrdinal,
    InputId = input_schema$InputId,
    DecisionQuestion = c(
      "Which of ABS-PHI and REL-G has a named operational use and consequence?",
      "What lower, reference, and higher target is defensible for each enabled family?",
      "Is 0.80 accepted as the ABS-PHI reference action benchmark, not a universal threshold?",
      "What external scale identity establishes common direction and interpretable units for S2 and S3?",
      "What exact nonnegative weight vector applies to every enabled family at S2 and S3?",
      "What frozen external transformation defines each standardized-score policy?",
      "Can common, one-common-rater, and independent sharing each be operated as declared?",
      "What roster identity proves one rater is common to every stratum and all others are disjoint?",
      paste(
        "For S2 and S3, which condition incidence and observation-event map",
        "produce the declared covariance blocks, and how does each random",
        "block map to a supported structure?"
      ),
      "What cost unit and nonnegative unique-rater overhead govern allocation choice?",
      "What current allocation and action rule form the frozen status-quo comparator?",
      "Are all twelve S2/S3 by allocation coordinates operationally feasible?",
      "What build, integrate, park, or kill consequence follows each robustness class?"
    ),
    RequiredEvidence = c(
      "named use case, decision owner, affected workflow, and consequence identity",
      "policy or domain rationale fixed independently of simulation outcomes",
      "owner statement distinguishing dependability from cut-score classification",
      "instrument/version identity and evidence of direction and unit comparability",
      "policy/version identity with exact stratum order and weights summing to one",
      "transformation/version identity frozen outside the simulation results",
      "staffing, roster, or scheduling evidence for every sharing mode",
      "prospective roster/topology identity showing the declared overlap pattern",
      paste(
        "instrument/event-map identity plus methodologist-confirmed Object,",
        "Rater, and Object:Rater structure mappings for S2 and S3"
      ),
      "cost ledger/version with rating-event unit and unique-rater overhead",
      "current allocation identifier and current action-rule identifier for S2 and S3",
      "feasibility evidence for every retained allocation coordinate",
      "decision policy/version mapping robust, conditional, and unsupported to actions"
    ),
    StopIfUnresolved = c(
      "No decision family may enter D-SIM-1 without an owner-linked use.",
      "Targets cannot be estimated or tuned from simulated outcomes.",
      "Changing 0.80 requires a new contract version before execution.",
      "Common-unit profiles are uninterpretable without external scale identity.",
      "Owner-weighted profiles are undefined without exact frozen vectors.",
      "Standardized profiles are undefined without an external transformation.",
      "If any declared mode is infeasible, revise the profile universe before signing.",
      "Partial-sharing projections stop without a verifiable topology.",
      paste(
        "D-SIM-1 stops if event linkage is unknown, residual dispersion is",
        "duplicated, or any random block needs an undeclared custom mask."
      ),
      "Cost-optimal actions are undefined without a frozen cost unit and overhead.",
      "Status-quo comparisons stop without an externally frozen comparator.",
      "The current 108-profile contract stops if any retained allocation is infeasible.",
      "Simulation evidence cannot authorize development without frozen consequences."
    ),
    NextOwnerAction = c(
      "name the owner and enable or disable each family with evidence",
      "enter and confirm each ordered target triplet",
      "confirm the prefilled 0.80 reference or issue a new contract",
      "identify and confirm the S2 and S3 common-unit scales",
      "enter and confirm every enabled-family weight vector",
      "identify and confirm each external transformation",
      "confirm all three sharing modes with operational evidence",
      "identify and confirm the one-common-rater topology",
      paste(
        "bind the S2/S3 condition and event maps, then obtain independent",
        "methodologist confirmation of all random-block mappings"
      ),
      "enter the overhead and identify the cost unit",
      "identify and confirm the current allocation and action rule",
      "confirm feasibility for all twelve allocation rows",
      "map all three robustness classes to frozen actions"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v3_adjudication_routing_schema <- function() {
  data.frame(
    InputOrdinal = seq_len(13L),
    InputId = c(
      "decision_family_enablement", "target_triplets",
      "absolute_reference_target", "common_unit_scale_identity",
      "owner_fixed_weight_vectors", "external_standardization_identity",
      "rater_sharing_feasibility", "partial_sharing_topology",
      "observation_event_covariance_design", "rater_overhead_cost",
      "status_quo_comparator", "candidate_allocation_feasibility",
      "action_mapping"
    ),
    PhaseOrdinal = c(1L, rep(2L, 5L), rep(3L, 3L), rep(4L, 3L), 5L),
    PhaseId = c(
      "scope_and_use", rep("estimand_and_scale", 5L),
      rep("measurement_and_design", 3L),
      rep("operations_and_comparator", 3L), "consequence_policy"
    ),
    DecisionAuthorityRole = c(
      "practical_decision_owner", "practical_decision_owner",
      "practical_decision_owner", "instrument_owner",
      "practical_decision_owner", "instrument_owner",
      "operational_resource_owner", "operational_resource_owner",
      "shared_practical_owner_and_independent_methodologist",
      "operational_cost_owner", "practical_decision_owner",
      "operational_resource_owner", "practical_decision_owner"
    ),
    EvidenceProviderRole = c(
      "workflow_custodian", "policy_domain_custodian",
      "policy_domain_custodian", "instrument_version_custodian",
      "policy_domain_custodian", "transformation_version_custodian",
      "staffing_and_schedule_custodian", "roster_custodian",
      "instrument_event_map_and_design_custodians",
      "cost_ledger_custodian", "current_workflow_custodian",
      "staffing_and_schedule_custodian", "decision_policy_custodian"
    ),
    RequiredConfirmationRole = c(
      rep("practical_owner", 8L),
      "practical_owner_plus_independent_methodologist",
      rep("practical_owner", 4L)
    ),
    BlockingDependencyInputIds = c(
      "", "decision_family_enablement", "decision_family_enablement", "",
      "decision_family_enablement", "decision_family_enablement",
      "", "", "", "", "", "", ""
    ),
    RecommendedPredecessorInputIds = c(
      "", "decision_family_enablement", "decision_family_enablement",
      "decision_family_enablement",
      "decision_family_enablement;common_unit_scale_identity",
      "decision_family_enablement;common_unit_scale_identity",
      "decision_family_enablement", "rater_sharing_feasibility",
      "rater_sharing_feasibility;partial_sharing_topology",
      "rater_sharing_feasibility", "decision_family_enablement",
      "rater_sharing_feasibility;rater_overhead_cost",
      paste(
        "target_triplets;rater_overhead_cost;status_quo_comparator;",
        "candidate_allocation_feasibility", sep = ""
      )
    ),
    ResolutionIfUnsupported = c(
      "disable_unowned_family_or_stop_if_no_family_remains",
      "disable_affected_family_or_issue_v4_without_outcome_tuning",
      "disable_abs_phi_or_issue_v4_if_reference_differs_from_0.80",
      "issue_v4_to_remove_common_unit_dependent_profiles_or_stop",
      "issue_v4_to_remove_owner_weighted_profiles_or_stop",
      "issue_v4_to_remove_standardized_profiles_or_stop",
      "issue_v4_to_remove_infeasible_sharing_modes_or_stop",
      "issue_v4_to_remove_partial_sharing_or_stop",
      "bind_supported_design_or_issue_custom_route_contract",
      "issue_v4_to_remove_cost_based_actions_or_stop",
      "freeze_external_comparator_or_stop",
      "issue_v4_to_remove_infeasible_allocations_or_stop",
      "freeze_consequences_or_stop_without_simulation"
    ),
    DownstreamEffect = c(
      "defines_enabled_estimands_and_conditional_owner_inputs",
      "defines_family_specific_decision_regions",
      "fixes_abs_phi_reference_action_benchmark",
      "determines_interpretability_of_cross_stratum_composites",
      "defines_owner_weighted_composite_estimands",
      "defines_standardized_composite_estimands",
      "defines_admissible_rater_sharing_profiles",
      "identifies_partial_sharing_incidence_topology",
      "determines_covariance_blocks_and_backend_design_eligibility",
      "defines_allocation_cost_comparisons",
      "defines_external_status_quo_contrast",
      "defines_admissible_allocation_coordinates",
      "maps_multiverse_robustness_classes_to_actions"
    ),
    OutcomeDataMayResolve = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v3_owner_input_candidate <- function(
    contract = mfrmr_gtds_v3_contract()) {
  mfrmr_gtds_v3_validate_contract(contract)
  families <- contract$DecisionFamilyRegistry$DecisionFamilyId
  stratum_counts <- c(2L, 3L)
  target_registry <- expand.grid(
    DecisionFamilyId = families,
    TargetPolicy = c("lower", "reference", "higher"),
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  target_registry$TargetValue <- NA_real_
  target_registry$TargetValue[
    target_registry$DecisionFamilyId == "ABS-PHI" &
      target_registry$TargetPolicy == "reference"
  ] <- 0.80
  target_registry$OwnerConfirmed <- FALSE
  target_registry$EvidenceIdentity <- ""
  weight_registry <- do.call(rbind, lapply(families, function(family) {
    do.call(rbind, lapply(stratum_counts, function(stratum_count) {
      data.frame(
        DecisionFamilyId = family, StratumCount = stratum_count,
        Stratum = LETTERS[seq_len(stratum_count)], Weight = NA_real_,
        OwnerConfirmed = FALSE, EvidenceIdentity = "",
        stringsAsFactors = FALSE
      )
    }))
  }))
  standardization_registry <- expand.grid(
    DecisionFamilyId = families, StratumCount = stratum_counts,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  standardization_registry$TransformationIdentity <- ""
  standardization_registry$OwnerConfirmed <- FALSE
  standardization_registry$EvidenceIdentity <- ""
  allocation_registry <- do.call(rbind, lapply(stratum_counts, function(count) {
    rows <- mfrmr_gtds_v2_allocation_registry(count)
    data.frame(
      StratumCount = count, AllocationId = rows$AllocationId,
      OperationallyFeasible = NA, OwnerConfirmed = FALSE,
      EvidenceIdentity = "", stringsAsFactors = FALSE
    )
  }))
  payload <- list(
    PacketVersion = "mfrmr-gtheory-multivariate-owner-input-v3-v2",
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    FamilyEnablementRegistry = data.frame(
      DecisionFamilyId = families, Enabled = NA,
      OwnerConfirmed = FALSE, EvidenceIdentity = "",
      stringsAsFactors = FALSE
    ),
    TargetRegistry = target_registry,
    CommonUnitScaleRegistry = data.frame(
      StratumCount = stratum_counts, Compatible = NA,
      ScaleIdentity = "", OwnerConfirmed = FALSE, EvidenceIdentity = "",
      stringsAsFactors = FALSE
    ),
    OwnerFixedWeightRegistry = weight_registry,
    StandardizationRegistry = standardization_registry,
    SharingFeasibilityRegistry = data.frame(
      RaterSharing = c(
        "common", "partial_one_common_rater", "independent"
      ),
      OperationallyFeasible = NA, OwnerConfirmed = FALSE,
      EvidenceIdentity = "", stringsAsFactors = FALSE
    ),
    PartialSharingTopology = data.frame(
      TopologyId = "one_rater_common_to_every_stratum_others_disjoint",
      OperationallyFeasible = NA, OwnerConfirmed = FALSE,
      EvidenceIdentity = "", stringsAsFactors = FALSE
    ),
    ObservationEventDesignRegistry =
      mfrmr_gtds_v3_observation_event_design_candidate(),
    RandomBlockMappingRegistry =
      mfrmr_gtds_v3_random_block_mapping_candidate(),
    CostRegistry = data.frame(
      RatingEventUnitCost = 1, UniqueRaterOverhead = NA_real_,
      CostUnitIdentity = "", OwnerConfirmed = FALSE,
      EvidenceIdentity = "", stringsAsFactors = FALSE
    ),
    StatusQuoRegistry = data.frame(
      StratumCount = stratum_counts, ComparatorEnabled = NA,
      CurrentAllocationIdentity = "", CurrentActionRuleIdentity = "",
      OwnerConfirmed = FALSE, EvidenceIdentity = "",
      stringsAsFactors = FALSE
    ),
    AllocationFeasibilityRegistry = allocation_registry,
    ActionMappingRegistry = data.frame(
      RobustnessClass = c("robust", "conditional", "unsupported"),
      Action = NA_character_, OwnerConfirmed = FALSE,
      EvidenceIdentity = "", stringsAsFactors = FALSE
    ),
    PacketStatus = "candidate_incomplete", PacketReady = FALSE
  )
  payload$PacketHash <- mfrmr_gta_hash(payload)
  class(payload) <- c("mfrmr_gtds_v3_owner_input", "list")
  payload
}

mfrmr_gtds_v3_owner_packet_hash_valid <- function(packet) {
  if (!inherits(packet, "mfrmr_gtds_v3_owner_input") ||
      length(packet$PacketHash) != 1L || is.na(packet$PacketHash) ||
      !is.character(packet$PacketHash) ||
      !grepl("^[0-9a-f]{64}$", packet$PacketHash)) {
    return(FALSE)
  }
  stored_hash <- packet$PacketHash
  payload <- unclass(packet)
  payload$PacketHash <- NULL
  identical(stored_hash, mfrmr_gta_hash(payload))
}

mfrmr_gtds_v3_owner_completion_registry <- function(packet, contract) {
  family <- packet$FamilyEnablementRegistry
  targets <- packet$TargetRegistry
  scales <- packet$CommonUnitScaleRegistry
  weights <- packet$OwnerFixedWeightRegistry
  standardized <- packet$StandardizationRegistry
  sharing <- packet$SharingFeasibilityRegistry
  topology <- packet$PartialSharingTopology
  observation_events <- packet$ObservationEventDesignRegistry
  random_blocks <- packet$RandomBlockMappingRegistry
  cost <- packet$CostRegistry
  status_quo <- packet$StatusQuoRegistry
  allocations <- packet$AllocationFeasibilityRegistry
  actions <- packet$ActionMappingRegistry
  family_values_ready <- !anyNA(family$Enabled) && any(family$Enabled)
  enabled_families <- if (family_values_ready) {
    family$DecisionFamilyId[family$Enabled]
  } else character()
  confirmed_evidence_missing <- function(rows) {
    sum(!rows$OwnerConfirmed) + sum(!nzchar(rows$EvidenceIdentity))
  }
  family_ready <- family_values_ready && all(family$OwnerConfirmed) &&
    all(nzchar(family$EvidenceIdentity))
  family_missing <- sum(is.na(family$Enabled)) +
    sum(!family$OwnerConfirmed) + sum(!nzchar(family$EvidenceIdentity)) +
    as.integer(!any(family$Enabled %in% TRUE))

  target_checks <- lapply(enabled_families, function(id) {
    rows <- targets[targets$DecisionFamilyId == id, , drop = FALSE]
    values <- rows$TargetValue[match(
      c("lower", "reference", "higher"), rows$TargetPolicy
    )]
    numeric_missing <- sum(!is.finite(values) | values < 0 | values > 1)
    order_missing <- as.integer(
      !all(is.finite(values)) ||
        !(values[[1L]] < values[[2L]] && values[[2L]] < values[[3L]])
    )
    list(
      Ready = numeric_missing == 0L && order_missing == 0L &&
        all(rows$OwnerConfirmed) && all(nzchar(rows$EvidenceIdentity)),
      Missing = numeric_missing + order_missing +
        confirmed_evidence_missing(rows)
    )
  })
  target_ready <- family_values_ready &&
    all(vapply(target_checks, function(value) isTRUE(value[["Ready"]]),
               logical(1L)))
  target_missing <- if (!family_values_ready) 1L else sum(vapply(
    target_checks, function(value) as.integer(value[["Missing"]]), integer(1L)
  ))
  absolute_row <- targets[
    targets$DecisionFamilyId == "ABS-PHI" &
      targets$TargetPolicy == "reference", , drop = FALSE
  ]
  absolute_required <- family_values_ready && "ABS-PHI" %in% enabled_families
  absolute_ready <- family_values_ready && (!absolute_required || (
    length(absolute_row$TargetValue) == 1L &&
      is.finite(absolute_row$TargetValue) &&
      abs(absolute_row$TargetValue - 0.80) <= 1e-12 &&
      absolute_row$OwnerConfirmed && nzchar(absolute_row$EvidenceIdentity)
  ))
  absolute_missing <- if (!family_values_ready) 1L else if (
    !absolute_required
  ) 0L else {
    as.integer(!is.finite(absolute_row$TargetValue) ||
                 abs(absolute_row$TargetValue - 0.80) > 1e-12) +
      confirmed_evidence_missing(absolute_row)
  }

  scale_ready <- all(scales$Compatible %in% TRUE) &&
    all(scales$OwnerConfirmed) && all(nzchar(scales$ScaleIdentity)) &&
    all(nzchar(scales$EvidenceIdentity))
  scale_missing <- sum(!scales$Compatible %in% TRUE) +
    sum(!nzchar(scales$ScaleIdentity)) + confirmed_evidence_missing(scales)

  weight_checks <- unlist(lapply(enabled_families, function(id) {
    vapply(c(2L, 3L), function(count) {
      rows <- weights[
        weights$DecisionFamilyId == id & weights$StratumCount == count,
        , drop = FALSE
      ]
      invalid <- sum(!is.finite(rows$Weight) | rows$Weight < 0)
      sum_invalid <- as.integer(
        !all(is.finite(rows$Weight)) || abs(sum(rows$Weight) - 1) > 1e-12
      )
      invalid + sum_invalid + confirmed_evidence_missing(rows)
    }, integer(1L))
  }), use.names = FALSE)
  weight_missing <- if (!family_values_ready) 1L else sum(weight_checks)
  weight_ready <- family_values_ready && weight_missing == 0L

  standardization_rows <- standardized[
    standardized$DecisionFamilyId %in% enabled_families, , drop = FALSE
  ]
  standardization_missing <- if (!family_values_ready) 1L else {
    sum(!nzchar(standardization_rows$TransformationIdentity)) +
      confirmed_evidence_missing(standardization_rows)
  }
  standardization_ready <- family_values_ready &&
    nrow(standardization_rows) == 2L * length(enabled_families) &&
    standardization_missing == 0L

  sharing_missing <- sum(!sharing$OperationallyFeasible %in% TRUE) +
    confirmed_evidence_missing(sharing)
  sharing_ready <- sharing_missing == 0L
  topology_missing <- sum(!topology$OperationallyFeasible %in% TRUE) +
    confirmed_evidence_missing(topology)
  topology_ready <- topology_missing == 0L
  event_binding_ready <- isTRUE(tryCatch({
    mfrmr_gtds_v3_validate_covariance_binding(
      observation_events, random_blocks, require_complete = TRUE
    )
    TRUE
  }, error = function(error) FALSE))
  event_binding_missing <-
    sum(is.na(observation_events$ConditionSetRelationship)) +
    sum(is.na(observation_events$ObservationEventRelationship)) +
    sum(!nzchar(observation_events$ConditionIncidenceIdentity)) +
    sum(!nzchar(observation_events$ObservationEventMapIdentity)) +
    sum(!observation_events$OwnerConfirmed %in% TRUE) +
    sum(!nzchar(observation_events$EvidenceIdentity)) +
    sum(is.na(random_blocks$StructureClass)) +
    sum(!nzchar(random_blocks$MappingIdentity)) +
    sum(!random_blocks$MethodologistConfirmed %in% TRUE) +
    sum(!nzchar(random_blocks$EvidenceIdentity))
  cost_missing <- as.integer(
    !is.finite(cost$UniqueRaterOverhead) || cost$UniqueRaterOverhead < 0
  ) + as.integer(cost$RatingEventUnitCost != 1) +
    sum(!nzchar(cost$CostUnitIdentity)) + confirmed_evidence_missing(cost)
  cost_ready <- cost_missing == 0L
  status_missing <- sum(!status_quo$ComparatorEnabled %in% TRUE) +
    sum(!nzchar(status_quo$CurrentAllocationIdentity)) +
    sum(!nzchar(status_quo$CurrentActionRuleIdentity)) +
    confirmed_evidence_missing(status_quo)
  status_ready <- status_missing == 0L
  allocation_missing <-
    sum(!allocations$OperationallyFeasible %in% TRUE) +
    confirmed_evidence_missing(allocations)
  allocation_ready <- allocation_missing == 0L
  action_missing <- sum(is.na(actions$Action) | !actions$Action %in%
                          c("build", "integrate", "park", "kill")) +
    confirmed_evidence_missing(actions)
  action_ready <- action_missing == 0L

  ready <- c(
    family_ready, target_ready, absolute_ready, scale_ready, weight_ready,
    standardization_ready, sharing_ready, topology_ready,
    event_binding_ready, cost_ready, status_ready, allocation_ready,
    action_ready
  )
  missing <- as.integer(c(
    family_missing, target_missing, absolute_missing, scale_missing,
    weight_missing, standardization_missing, sharing_missing,
    topology_missing, event_binding_missing, cost_missing, status_missing,
    allocation_missing, action_missing
  ))
  missing[!ready & missing == 0L] <- 1L
  schema <- contract$OwnerDecisionBriefSchema
  family_blocked <- !family_values_ready & schema$InputId %in% c(
    "target_triplets", "absolute_reference_target",
    "owner_fixed_weight_vectors", "external_standardization_identity"
  )
  data.frame(
    InputOrdinal = schema$InputOrdinal,
    InputId = schema$InputId,
    CurrentState = ifelse(
      ready, "ready",
      ifelse(family_blocked, "blocked_by_family_enablement",
             "owner_input_missing_or_invalid")
    ),
    MissingCount = missing,
    Ready = ready,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v3_owner_decision_brief <- function(
    packet, contract = mfrmr_gtds_v3_contract()) {
  mfrmr_gtds_v3_validate_owner_input(
    packet, contract, require_complete = FALSE
  )
  completion <- mfrmr_gtds_v3_owner_completion_registry(packet, contract)
  schema <- contract$OwnerDecisionBriefSchema
  if (!identical(completion$InputId, schema$InputId)) {
    stop("The owner decision brief schema is misaligned.", call. = FALSE)
  }
  all_inputs_ready <- all(completion$Ready)
  packet_finalized <- isTRUE(packet$PacketReady) &&
    identical(packet$PacketStatus, "owner_input_complete_unanchored")
  brief_status <- if (!all_inputs_ready) {
    "owner_decisions_pending"
  } else if (!packet_finalized) {
    "owner_inputs_complete_finalize_packet"
  } else {
    "owner_inputs_complete_packet_finalized_unanchored"
  }
  data.frame(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    PacketHash = packet$PacketHash,
    schema,
    CurrentState = completion$CurrentState,
    MissingCount = completion$MissingCount,
    Ready = completion$Ready,
    PacketStatus = packet$PacketStatus,
    PacketReady = packet$PacketReady,
    BriefStatus = brief_status,
    SimulationExecutionAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v3_adjudication_plan <- function(
    packet, contract = mfrmr_gtds_v3_contract()) {
  mfrmr_gtds_v3_validate_owner_input(
    packet, contract, require_complete = FALSE
  )
  completion <- mfrmr_gtds_v3_owner_completion_registry(packet, contract)
  routing <- contract$AdjudicationRoutingSchema
  input_schema <- contract$OwnerInputSchema
  brief_schema <- contract$OwnerDecisionBriefSchema
  if (!identical(routing$InputId, completion$InputId) ||
      !identical(input_schema$InputId, completion$InputId) ||
      !identical(brief_schema$InputId, completion$InputId)) {
    stop("The adjudication routing schemas are misaligned.", call. = FALSE)
  }
  owner_rows <- data.frame(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    PacketHash = packet$PacketHash,
    WorkOrdinal = seq_len(13L),
    WorkLayer = "owner_decision",
    ParentInputId = routing$InputId,
    SubtaskId = routing$InputId,
    PhaseOrdinal = routing$PhaseOrdinal,
    PhaseId = routing$PhaseId,
    DecisionAuthorityRole = routing$DecisionAuthorityRole,
    EvidenceProviderRole = routing$EvidenceProviderRole,
    RequiredConfirmationRole = routing$RequiredConfirmationRole,
    BlockingDependencyInputIds = routing$BlockingDependencyInputIds,
    RecommendedPredecessorInputIds =
      routing$RecommendedPredecessorInputIds,
    RequiredEvidence = brief_schema$RequiredEvidence,
    AdmissibleAnswerOrStructure = paste(
      input_schema$RequiredType, input_schema$Constraint, sep = " | "
    ),
    ResolutionIfUnsupported = routing$ResolutionIfUnsupported,
    DownstreamEffect = routing$DownstreamEffect,
    CurrentState = completion$CurrentState,
    MissingCount = completion$MissingCount,
    Ready = completion$Ready,
    OutcomeDataMayResolve = routing$OutcomeDataMayResolve,
    ExecutionAllowed = FALSE,
    stringsAsFactors = FALSE
  )

  events <- packet$ObservationEventDesignRegistry
  event_missing <-
    as.integer(is.na(events$ConditionSetRelationship)) +
    as.integer(is.na(events$ObservationEventRelationship)) +
    as.integer(!nzchar(events$ConditionIncidenceIdentity)) +
    as.integer(!nzchar(events$ObservationEventMapIdentity)) +
    as.integer(!events$OwnerConfirmed %in% TRUE) +
    as.integer(!nzchar(events$EvidenceIdentity))
  event_rows <- data.frame(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    PacketHash = packet$PacketHash,
    WorkOrdinal = 13L + seq_len(nrow(events)),
    WorkLayer = "observation_event_binding",
    ParentInputId = "observation_event_covariance_design",
    SubtaskId = paste0("observation_event_s", events$StratumCount),
    PhaseOrdinal = 3L,
    PhaseId = "measurement_and_design",
    DecisionAuthorityRole = "practical_decision_owner",
    EvidenceProviderRole = "instrument_event_map_custodian",
    RequiredConfirmationRole = "practical_owner",
    BlockingDependencyInputIds = "",
    RecommendedPredecessorInputIds =
      "rater_sharing_feasibility;partial_sharing_topology",
    RequiredEvidence = paste(
      "versioned condition-incidence and observation-event maps for",
      paste0("S", events$StratumCount)
    ),
    AdmissibleAnswerOrStructure = paste(
      "condition={disjoint_by_stratum,identical_shared_across_strata,",
      "partial_or_mixed_explicit_incidence};event={",
      "distinct_event_per_stratum_score,",
      "one_event_yields_multiple_stratum_scores,",
      "mixed_explicit_event_map}", sep = ""
    ),
    ResolutionIfUnsupported =
      "supply_explicit_incidence_and_event_map_then_issue_custom_contract",
    DownstreamEffect =
      "determines_condition_and_level1_residual_blocks_by_stratum_count",
    CurrentState = ifelse(event_missing == 0L, "ready", "evidence_pending"),
    MissingCount = event_missing,
    Ready = event_missing == 0L,
    OutcomeDataMayResolve = FALSE,
    ExecutionAllowed = FALSE,
    stringsAsFactors = FALSE
  )

  blocks <- packet$RandomBlockMappingRegistry
  block_missing <-
    as.integer(is.na(blocks$StructureClass)) +
    as.integer(!nzchar(blocks$MappingIdentity)) +
    as.integer(!blocks$MethodologistConfirmed %in% TRUE) +
    as.integer(!nzchar(blocks$EvidenceIdentity))
  block_rows <- data.frame(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    PacketHash = packet$PacketHash,
    WorkOrdinal = 15L + seq_len(nrow(blocks)),
    WorkLayer = "random_block_binding",
    ParentInputId = "observation_event_covariance_design",
    SubtaskId = paste0(
      "random_block_s", blocks$StratumCount, "_",
      gsub(":", "_by_", tolower(blocks$ComponentId), fixed = TRUE)
    ),
    PhaseOrdinal = 3L,
    PhaseId = "measurement_and_design",
    DecisionAuthorityRole = "independent_measurement_methodologist",
    EvidenceProviderRole = "measurement_design_custodian",
    RequiredConfirmationRole = "independent_methodologist",
    BlockingDependencyInputIds = "",
    RecommendedPredecessorInputIds =
      "observation_event_covariance_design",
    RequiredEvidence = paste(
      "versioned design-to-covariance mapping for",
      paste0("S", blocks$StratumCount, " ", blocks$ComponentId)
    ),
    AdmissibleAnswerOrStructure = paste(
      "{unstructured,diagonal,compound_symmetric,ar1,",
      "explicit_mask_or_other}", sep = ""
    ),
    ResolutionIfUnsupported =
      "classify_as_explicit_mask_or_other_and_issue_custom_contract",
    DownstreamEffect =
      "determines_random_block_support_and_backend_design_eligibility",
    CurrentState = ifelse(block_missing == 0L, "ready", "evidence_pending"),
    MissingCount = block_missing,
    Ready = block_missing == 0L,
    OutcomeDataMayResolve = FALSE,
    ExecutionAllowed = FALSE,
    stringsAsFactors = FALSE
  )
  result <- rbind(owner_rows, event_rows, block_rows)
  rownames(result) <- NULL
  result
}

mfrmr_gtds_v3_validate_owner_input <- function(
    packet, contract = mfrmr_gtds_v3_contract(), require_complete = FALSE) {
  mfrmr_gtds_v3_validate_contract(contract)
  if (!inherits(packet, "mfrmr_gtds_v3_owner_input")) {
    stop("`packet` must be a D-SIM-0 v3 owner-input packet.", call. = FALSE)
  }
  require_complete <- isTRUE(require_complete)
  families <- contract$DecisionFamilyRegistry$DecisionFamilyId
  family <- packet$FamilyEnablementRegistry
  targets <- packet$TargetRegistry
  scales <- packet$CommonUnitScaleRegistry
  weights <- packet$OwnerFixedWeightRegistry
  standardized <- packet$StandardizationRegistry
  sharing <- packet$SharingFeasibilityRegistry
  observation_events <- packet$ObservationEventDesignRegistry
  random_blocks <- packet$RandomBlockMappingRegistry
  allocations <- packet$AllocationFeasibilityRegistry
  actions <- packet$ActionMappingRegistry
  expected_target <- expand.grid(
    DecisionFamilyId = families,
    TargetPolicy = c("lower", "reference", "higher"),
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  expected_weights <- do.call(rbind, lapply(families, function(id) {
    do.call(rbind, lapply(c(2L, 3L), function(count) {
      data.frame(
        DecisionFamilyId = id, StratumCount = count,
        Stratum = LETTERS[seq_len(count)], stringsAsFactors = FALSE
      )
    }))
  }))
  expected_standardized <- expand.grid(
    DecisionFamilyId = families, StratumCount = c(2L, 3L),
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  expected_allocations <- do.call(rbind, lapply(c(2L, 3L), function(count) {
    data.frame(
      StratumCount = count,
      AllocationId = mfrmr_gtds_v2_allocation_registry(count)$AllocationId,
      stringsAsFactors = FALSE
    )
  }))
  same_columns <- function(data, expected_names) {
    is.data.frame(data) && identical(names(data), expected_names)
  }
  same_keys <- function(data, expected, keys) {
    nrow(data) == nrow(expected) && all(vapply(
      keys, function(key) identical(data[[key]], expected[[key]]),
      logical(1L)
    ))
  }
  logical_columns <- function(data, columns) {
    all(vapply(columns, function(column) is.logical(data[[column]]),
               logical(1L)))
  }
  character_columns <- function(data, columns) {
    all(vapply(columns, function(column) is.character(data[[column]]),
               logical(1L)))
  }
  covariance_binding_structural <- isTRUE(tryCatch({
    mfrmr_gtds_v3_validate_covariance_binding(
      observation_events, random_blocks, require_complete = FALSE
    )
    TRUE
  }, error = function(error) FALSE))
  expected_packet_names <- c(
    "PacketVersion", "ContractId", "ContractHash",
    "FamilyEnablementRegistry", "TargetRegistry",
    "CommonUnitScaleRegistry", "OwnerFixedWeightRegistry",
    "StandardizationRegistry", "SharingFeasibilityRegistry",
    "PartialSharingTopology", "ObservationEventDesignRegistry",
    "RandomBlockMappingRegistry", "CostRegistry", "StatusQuoRegistry",
    "AllocationFeasibilityRegistry", "ActionMappingRegistry",
    "PacketStatus", "PacketReady", "PacketHash"
  )
  schema_ready <- identical(names(packet), expected_packet_names) &&
    same_columns(family, c(
      "DecisionFamilyId", "Enabled", "OwnerConfirmed", "EvidenceIdentity"
    )) &&
    same_columns(targets, c(
      "DecisionFamilyId", "TargetPolicy", "TargetValue",
      "OwnerConfirmed", "EvidenceIdentity"
    )) &&
    same_columns(scales, c(
      "StratumCount", "Compatible", "ScaleIdentity", "OwnerConfirmed",
      "EvidenceIdentity"
    )) &&
    same_columns(weights, c(
      "DecisionFamilyId", "StratumCount", "Stratum", "Weight",
      "OwnerConfirmed", "EvidenceIdentity"
    )) &&
    same_columns(standardized, c(
      "DecisionFamilyId", "StratumCount", "TransformationIdentity",
      "OwnerConfirmed", "EvidenceIdentity"
    )) &&
    same_columns(sharing, c(
      "RaterSharing", "OperationallyFeasible", "OwnerConfirmed",
      "EvidenceIdentity"
    )) &&
    same_columns(packet$PartialSharingTopology, c(
      "TopologyId", "OperationallyFeasible", "OwnerConfirmed",
      "EvidenceIdentity"
    )) &&
    same_columns(packet$CostRegistry, c(
      "RatingEventUnitCost", "UniqueRaterOverhead", "CostUnitIdentity",
      "OwnerConfirmed", "EvidenceIdentity"
    )) &&
    same_columns(packet$StatusQuoRegistry, c(
      "StratumCount", "ComparatorEnabled", "CurrentAllocationIdentity",
      "CurrentActionRuleIdentity", "OwnerConfirmed", "EvidenceIdentity"
    )) &&
    same_columns(allocations, c(
      "StratumCount", "AllocationId", "OperationallyFeasible",
      "OwnerConfirmed", "EvidenceIdentity"
    )) &&
    same_columns(actions, c(
      "RobustnessClass", "Action", "OwnerConfirmed", "EvidenceIdentity"
    ))
  type_ready <- schema_ready && covariance_binding_structural &&
    logical_columns(family, c("Enabled", "OwnerConfirmed")) &&
    character_columns(family, c("DecisionFamilyId", "EvidenceIdentity")) &&
    is.numeric(targets$TargetValue) &&
    logical_columns(targets, "OwnerConfirmed") &&
    character_columns(targets, c(
      "DecisionFamilyId", "TargetPolicy", "EvidenceIdentity"
    )) &&
    logical_columns(scales, c("Compatible", "OwnerConfirmed")) &&
    character_columns(scales, c("ScaleIdentity", "EvidenceIdentity")) &&
    is.numeric(weights$Weight) &&
    logical_columns(weights, "OwnerConfirmed") &&
    character_columns(weights, c(
      "DecisionFamilyId", "Stratum", "EvidenceIdentity"
    )) &&
    logical_columns(standardized, "OwnerConfirmed") &&
    character_columns(standardized, c(
      "DecisionFamilyId", "TransformationIdentity", "EvidenceIdentity"
    )) &&
    logical_columns(sharing, c("OperationallyFeasible", "OwnerConfirmed")) &&
    character_columns(sharing, c("RaterSharing", "EvidenceIdentity")) &&
    logical_columns(packet$PartialSharingTopology,
                    c("OperationallyFeasible", "OwnerConfirmed")) &&
    character_columns(packet$PartialSharingTopology,
                      c("TopologyId", "EvidenceIdentity")) &&
    is.numeric(packet$CostRegistry$RatingEventUnitCost) &&
    is.numeric(packet$CostRegistry$UniqueRaterOverhead) &&
    logical_columns(packet$CostRegistry, "OwnerConfirmed") &&
    character_columns(packet$CostRegistry,
                      c("CostUnitIdentity", "EvidenceIdentity")) &&
    logical_columns(packet$StatusQuoRegistry,
                    c("ComparatorEnabled", "OwnerConfirmed")) &&
    character_columns(packet$StatusQuoRegistry, c(
      "CurrentAllocationIdentity", "CurrentActionRuleIdentity",
      "EvidenceIdentity"
    )) &&
    logical_columns(allocations,
                    c("OperationallyFeasible", "OwnerConfirmed")) &&
    character_columns(allocations, c("AllocationId", "EvidenceIdentity")) &&
    logical_columns(actions, "OwnerConfirmed") &&
    character_columns(actions,
                      c("RobustnessClass", "Action", "EvidenceIdentity")) &&
    is.character(packet$PacketStatus) && length(packet$PacketStatus) == 1L &&
    is.logical(packet$PacketReady) && length(packet$PacketReady) == 1L
  structural <- type_ready &&
    identical(packet$PacketVersion,
              "mfrmr-gtheory-multivariate-owner-input-v3-v2") &&
    identical(packet$ContractId, contract$ContractId) &&
    identical(packet$ContractHash, contract$ContractHash) &&
    identical(family$DecisionFamilyId, families) &&
    same_keys(targets, expected_target,
              c("DecisionFamilyId", "TargetPolicy")) &&
    identical(scales$StratumCount, c(2L, 3L)) && nrow(scales) == 2L &&
    same_keys(weights, expected_weights,
              c("DecisionFamilyId", "StratumCount", "Stratum")) &&
    same_keys(standardized, expected_standardized,
              c("DecisionFamilyId", "StratumCount")) &&
    identical(sharing$RaterSharing,
              c("common", "partial_one_common_rater", "independent")) &&
    identical(
      packet$PartialSharingTopology$TopologyId,
      "one_rater_common_to_every_stratum_others_disjoint"
    ) &&
    nrow(packet$CostRegistry) == 1L &&
    identical(packet$StatusQuoRegistry$StratumCount, c(2L, 3L)) &&
    same_keys(allocations, expected_allocations,
              c("StratumCount", "AllocationId")) &&
    identical(actions$RobustnessClass,
              c("robust", "conditional", "unsupported")) &&
    mfrmr_gtds_v3_owner_packet_hash_valid(packet)
  if (!structural) {
    stop("The v3 owner-input packet is malformed or hash-altered.",
         call. = FALSE)
  }
  if (!require_complete) return(invisible(TRUE))

  completion <- mfrmr_gtds_v3_owner_completion_registry(packet, contract)
  ready <- all(completion$Ready) && isTRUE(packet$PacketReady) &&
    identical(packet$PacketStatus, "owner_input_complete_unanchored")
  if (!ready) {
    stop("The v3 owner-input packet is incomplete or not owner-confirmed.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds_v3_finalize_owner_input <- function(
    packet, contract = mfrmr_gtds_v3_contract()) {
  if (!inherits(packet, "mfrmr_gtds_v3_owner_input")) {
    stop("`packet` must be a D-SIM-0 v3 owner-input packet.", call. = FALSE)
  }
  packet$PacketStatus <- "owner_input_complete_unanchored"
  packet$PacketReady <- TRUE
  payload <- unclass(packet)
  payload$PacketHash <- NULL
  packet$PacketHash <- mfrmr_gta_hash(payload)
  mfrmr_gtds_v3_validate_owner_input(
    packet, contract, require_complete = TRUE
  )
  packet
}

mfrmr_gtds_v3_implementation_identity <- function() {
  function_names <- c(
    "mfrmr_gtds_v3_require_primitives",
    "mfrmr_gtds_v3_decision_family_registry",
    "mfrmr_gtds_v3_axis_registry", "mfrmr_gtds_v3_axis_levels",
    "mfrmr_gtds_v3_profile_grid", "mfrmr_gtds_v3_pair_tokens",
    "mfrmr_gtds_v3_sentinel_profile_registry",
    "mfrmr_gtds_v3_all_sentinel_profiles",
    "mfrmr_gtds_v3_decision_profile_registry",
    "mfrmr_gtds_v3_all_decision_profiles",
    "mfrmr_gtds_v3_world_registry",
    "mfrmr_gtds_v3_analysis_route_registry",
    "mfrmr_gtds_v3_covariance_design_registry",
    "mfrmr_gtds_v3_observation_event_design_candidate",
    "mfrmr_gtds_v3_random_block_mapping_candidate",
    "mfrmr_gtds_v3_validate_covariance_binding",
    "mfrmr_gtds_v3_backend_design_qualification",
    "mfrmr_gtds_v3_weight_policy_registry",
    "mfrmr_gtds_v3_measurement_layer_registry",
    "mfrmr_gtds_v3_complementary_diagnostic_registry",
    "mfrmr_gtds_v3_signoff_requirements",
    "mfrmr_gtds_v3_owner_input_schema",
    "mfrmr_gtds_v3_owner_decision_brief_schema",
    "mfrmr_gtds_v3_adjudication_routing_schema",
    "mfrmr_gtds_v3_owner_input_candidate",
    "mfrmr_gtds_v3_owner_packet_hash_valid",
    "mfrmr_gtds_v3_owner_completion_registry",
    "mfrmr_gtds_v3_owner_decision_brief",
    "mfrmr_gtds_v3_adjudication_plan",
    "mfrmr_gtds_v3_validate_owner_input",
    "mfrmr_gtds_v3_finalize_owner_input",
    "mfrmr_gtds_v3_implementation_identity", "mfrmr_gtds_v3_contract",
    "mfrmr_gtds_v3_validate_contract",
    "mfrmr_gtds_v3_signoff_candidate",
    "mfrmr_gtds_v3_validate_signed_receipt"
  )
  target <- environment(mfrmr_gtds_v3_implementation_identity)
  data.frame(
    Function = function_names,
    SHA256 = vapply(function_names, function(name) {
      if (!exists(name, envir = target, inherits = FALSE)) {
        stop("A D-SIM-0 v3 implementation function is missing: ", name,
             ".", call. = FALSE)
      }
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gta_hash(list(
        Formals = paste(deparse(formals(fun), width.cutoff = 500L),
                        collapse = "\n"),
        Body = paste(deparse(body(fun), width.cutoff = 500L),
                     collapse = "\n")
      ))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds_v3_contract <- function(
    v2_contract = mfrmr_gtds_v2_contract(), plan = mfrmr_gtvd_plan()) {
  mfrmr_gtds_v3_require_primitives()
  mfrmr_gtds_v2_validate_contract(v2_contract)
  payload <- list(
    ContractVersion = "mfrmr-gtheory-multivariate-dsim0-multiverse-v3",
    ContractId = "MFRMR-GTHEORY-MV-DSIM0-MULTIVERSE-V3",
    SupersedesAsActiveProposal = "MFRMR-GTHEORY-MV-DSIM0-PHI-V2",
    ReferenceProfileContractId = v2_contract$ContractId,
    ReferenceProfileContractHash = v2_contract$ContractHash,
    StageId = "D-SIM-0",
    Status = "technical_bounded_multiverse_ready_owner_inputs_pending",
    MultiversePurpose = paste(
      "preregister admissible decision policies and structural uncertainty",
      "without treating one operational profile as universal"
    ),
    MaximumSentinelProfilesPerDecisionFamily = 12L,
    FullCartesianProfilesPerDecisionFamily = 108L,
    DecisionProfilesPerDecisionFamily = 108L,
    DecisionProfileRule = paste(
      "exhaustively enumerate the full Cartesian policy grid; no",
      "decision-bearing profile is selected or discarded"
    ),
    SentinelSelectionAlgorithm = paste(
      "include the reference anchor, then greedily maximize uncovered",
      "axis-level pairs; break ties by radix profile signature"
    ),
    SentinelPurpose =
      "nondecision smoke, implementation parity, and schema coverage only",
    FullProfileEnumerationRequired = TRUE,
    SentinelProfilesDecisionBearing = FALSE,
    ProfileSelectionUsesOutcomes = FALSE,
    AllEligibleProfilesReported = TRUE,
    ProfileWeightsAllowedWithoutExternalOwnerWeights = FALSE,
    MajorityVoteAcrossProfilesAllowed = FALSE,
    PoolingAcrossDecisionFamiliesAllowed = FALSE,
    ProfilesCountAsIndependentReplicates = FALSE,
    ProjectionRowsCountAsIndependentDatasets = FALSE,
    AnalysisImplementationsCountAsIndependentVotes = FALSE,
    CovarianceDesignBindingRequiredBeforeDsim1 = TRUE,
    CovarianceDesignBindingReady = FALSE,
    CovarianceBindingSchemaReady = TRUE,
    BackendDesignQualificationReady = TRUE,
    BackendQualificationExecutionAllowed = FALSE,
    CurrentC1CovarianceClaim = "matched_backend_overlap_only",
    EffectiveWeightsDiagnosticOnly = TRUE,
    DataDrivenWeightsDecisionBearing = FALSE,
    FacetCountDefinesLatentDimension = FALSE,
    MfrmDiagnosticCountsAsDecisionVote = FALSE,
    PrimaryDatasetMetric = "unsafe_or_unresolved_rate",
    CrossProfileSummaries = c(
      "robust_action_all_eligible_profiles_agree",
      "conditional_action_profile_boundary",
      "worst_case_unsafe_or_unresolved_rate", "maximum_decision_regret",
      "action_switching_assumption_distance", "allocation_pareto_frontier"
    ),
    RobustActionRule = paste(
      "all eligible profiles within one enabled decision family are",
      "decision-complete and return the same action"
    ),
    ConditionalActionRule = paste(
      "two or more eligible profiles within one family return different",
      "actions; report the switching assumptions without majority voting"
    ),
    UnsupportedActionRule = paste(
      "required profiles are unresolved, owner inputs are incomplete, or",
      "Monte Carlo precision cannot support the frozen action"
    ),
    ProfileChangeAfterPilotInvalidatesConfirmation = TRUE,
    OwnerInputPacketRequired = TRUE,
    OwnerInputPacketSchemaVersion =
      "mfrmr-gtheory-multivariate-owner-input-v3-v2",
    OwnerInputPacketValidatorReady = TRUE,
    OwnerDecisionBriefSchemaReady = TRUE,
    AdjudicationRoutingSchemaReady = TRUE,
    AdjudicationExecutionAllowed = FALSE,
    OwnerInputPacketReady = FALSE,
    OwnerInputPacketHash = NA_character_,
    OwnerSignoffReady = FALSE,
    Dsim0Satisfied = FALSE,
    SimulationExecutionAllowed = FALSE,
    PlannedSeedAccessAllowed = FALSE,
    PublicSupportReady = FALSE,
    ClaimCeiling = "technical_bounded_decision_multiverse_only"
  )
  payload$DecisionFamilyRegistry <-
    mfrmr_gtds_v3_decision_family_registry()
  payload$AxisRegistry <- mfrmr_gtds_v3_axis_registry()
  payload$ProfileRegistry <- mfrmr_gtds_v3_all_decision_profiles(
    payload$MaximumSentinelProfilesPerDecisionFamily
  )
  payload$SentinelProfileRegistry <- mfrmr_gtds_v3_all_sentinel_profiles(
    payload$MaximumSentinelProfilesPerDecisionFamily
  )
  payload$WorldRegistry <- mfrmr_gtds_v3_world_registry(plan)
  payload$AnalysisRouteRegistry <-
    mfrmr_gtds_v3_analysis_route_registry()
  payload$CovarianceDesignRegistry <-
    mfrmr_gtds_v3_covariance_design_registry()
  payload$ObservationEventDesignSchema <-
    mfrmr_gtds_v3_observation_event_design_candidate()
  payload$RandomBlockMappingSchema <-
    mfrmr_gtds_v3_random_block_mapping_candidate()
  payload$WeightPolicyRegistry <-
    mfrmr_gtds_v3_weight_policy_registry()
  payload$MeasurementLayerRegistry <-
    mfrmr_gtds_v3_measurement_layer_registry()
  payload$ComplementaryDiagnosticRegistry <-
    mfrmr_gtds_v3_complementary_diagnostic_registry()
  payload$OwnerInputSchema <- mfrmr_gtds_v3_owner_input_schema()
  payload$OwnerDecisionBriefSchema <-
    mfrmr_gtds_v3_owner_decision_brief_schema()
  payload$AdjudicationRoutingSchema <-
    mfrmr_gtds_v3_adjudication_routing_schema()
  payload$SignoffRequirements <- mfrmr_gtds_v3_signoff_requirements()
  payload$PlanScenarioRegistryHash <- plan$ScenarioRegistryHash
  payload$ImplementationIdentity <- mfrmr_gtds_v3_implementation_identity()
  payload$ImplementationIdentityHash <-
    mfrmr_gta_hash(payload$ImplementationIdentity)
  payload$ContractHash <- mfrmr_gta_hash(payload)
  class(payload) <- c("mfrmr_gtds_v3_contract", "list")
  payload
}

mfrmr_gtds_v3_validate_contract <- function(
    contract = mfrmr_gtds_v3_contract()) {
  if (!inherits(contract, "mfrmr_gtds_v3_contract")) {
    stop("`contract` must be a D-SIM-0 v3 multiverse contract.",
         call. = FALSE)
  }
  stored_hash <- contract$ContractHash
  payload <- unclass(contract)
  payload$ContractHash <- NULL
  families <- contract$DecisionFamilyRegistry
  profiles <- contract$ProfileRegistry
  profile_counts <- table(profiles$DecisionFamilyId)
  sentinels <- contract$SentinelProfileRegistry
  sentinel_counts <- table(sentinels$DecisionFamilyId)
  pairwise_ready <- vapply(
    split(sentinels, sentinels$DecisionFamilyId),
    function(rows) {
      all(rows$PairwiseCoverageComplete) &&
        identical(unique(rows$CoveredPairCount), 67L) &&
        identical(unique(rows$DeclaredPairCount), 67L) &&
        all(!rows$DecisionBearing) &&
        sum(rows$ReferenceProfile) == 1L &&
        rows$ProfileOrdinal[rows$ReferenceProfile] == 1L
    },
    logical(1L)
  )
  full_signatures <-
    mfrmr_gtds_v3_profile_grid(contract$AxisRegistry)$ProfileSignature
  enumeration_ready <- vapply(
    split(profiles, profiles$DecisionFamilyId),
    function(rows) {
      family_sentinels <- sentinels$ProfileSignature[
        sentinels$DecisionFamilyId == unique(rows$DecisionFamilyId)
      ]
      all(rows$FullEnumerationComplete) &&
        identical(unique(rows$DeclaredProfileCount), 108L) &&
        all(rows$DecisionBearing) && all(!rows$OwnerInputsComplete) &&
        setequal(rows$ProfileSignature, full_signatures) &&
        sum(rows$ReferenceProfile) == 1L &&
        rows$ProfileOrdinal[rows$ReferenceProfile] == 1L &&
        sum(rows$SentinelProfile) == 11L &&
        setequal(rows$ProfileSignature[rows$SentinelProfile],
                 family_sentinels)
    },
    logical(1L)
  )
  worlds <- table(contract$WorldRegistry$DecisionEvidenceRole)
  routes <- contract$AnalysisRouteRegistry
  covariance_designs <- contract$CovarianceDesignRegistry
  observation_event_schema <- contract$ObservationEventDesignSchema
  random_block_schema <- contract$RandomBlockMappingSchema
  adjudication_routing <- contract$AdjudicationRoutingSchema
  covariance_binding_schema_ready <- isTRUE(tryCatch({
    mfrmr_gtds_v3_validate_covariance_binding(
      observation_event_schema, random_block_schema,
      require_complete = FALSE
    )
    TRUE
  }, error = function(error) FALSE))
  weight_policies <- contract$WeightPolicyRegistry
  measurement_layers <- contract$MeasurementLayerRegistry
  complementary <- contract$ComplementaryDiagnosticRegistry
  implementation <- mfrmr_gtds_v3_implementation_identity()
  ready <- identical(contract$ContractId,
                     "MFRMR-GTHEORY-MV-DSIM0-MULTIVERSE-V3") &&
    identical(contract$ReferenceProfileContractId,
              "MFRMR-GTHEORY-MV-DSIM0-PHI-V2") &&
    identical(contract$MaximumSentinelProfilesPerDecisionFamily, 12L) &&
    identical(contract$FullCartesianProfilesPerDecisionFamily, 108L) &&
    identical(contract$DecisionProfilesPerDecisionFamily, 108L) &&
    identical(families$DecisionFamilyId, c("ABS-PHI", "REL-G")) &&
    all(!families$CrossFamilyPoolingAllowed) &&
    all(!families$CrossFamilyVotingAllowed) &&
    identical(as.integer(profile_counts), c(108L, 108L)) &&
    identical(as.integer(sentinel_counts), c(11L, 11L)) &&
    all(enumeration_ready) &&
    all(pairwise_ready) &&
    identical(nrow(contract$AxisRegistry), 13L) &&
    identical(nrow(contract$WorldRegistry), 14L) &&
    identical(unname(as.integer(worlds[c(
      "primary_decision_stress", "safety_boundary_only",
      "structural_negative_control"
    )])), c(8L, 4L, 2L)) &&
    identical(nrow(routes), 7L) &&
    identical(
      routes$EvidenceRole[routes$RouteId == "mv_reml_glmmtmb"],
      "primary_candidate_implementation"
    ) &&
    identical(
      routes$EvidenceRole[routes$RouteId == "mv_reml_lme4"],
      "design_restricted_sensitivity_only"
    ) &&
    all(routes$GeneralMultivariateGTheoryEligible ==
          routes$RouteId %in% c("mv_reml_glmmtmb", "mv_ml_glmmtmb")) &&
    all(routes$CorrelatedResidualCapable ==
          routes$RouteId %in% c("mv_reml_glmmtmb", "mv_ml_glmmtmb")) &&
    all(!routes$NativeLevelOneCorrelatedResidualApi) &&
    all(routes$ResidualRepresentation[
      routes$RouteId %in% c("mv_reml_glmmtmb", "mv_ml_glmmtmb")
    ] ==
      "observation_event_random_effect_block_plus_suppressed_dispersion") &&
    all(routes$ResidualRepresentation[
      routes$RouteId %in% c("mv_reml_lme4", "mv_ml_lme4")
    ] == "one_scale_times_known_diagonal_inverse_weights") &&
    all(nzchar(routes$EligibilityCondition)) &&
    all(!routes$CountsAsIndependentEstimandVote) &&
    all(!routes$PublicSupportReady) &&
    identical(nrow(covariance_designs), 4L) &&
    all(!covariance_designs$Lme4GeneralRouteAllowed) &&
    identical(sum(covariance_designs$RepresentedByCurrentC1), 1L) &&
    identical(
      covariance_designs$DesignId[
        covariance_designs$RepresentedByCurrentC1
      ],
      "current_c1_matched_backend_overlap"
    ) &&
    all(covariance_designs$CurrentBindingStatus[1:3] ==
          "pending_before_DSIM1") &&
    identical(
      covariance_designs$CurrentBindingStatus[[4L]],
      "implemented_candidate_requires_operational_design_match"
    ) &&
    covariance_binding_schema_ready &&
    identical(observation_event_schema$StratumCount, c(2L, 3L)) &&
    all(is.na(observation_event_schema$ConditionSetRelationship)) &&
    all(is.na(observation_event_schema$ObservationEventRelationship)) &&
    identical(nrow(random_block_schema), 6L) &&
    all(is.na(random_block_schema$StructureClass)) &&
    identical(nrow(weight_policies), 3L) &&
    identical(weight_policies$DecisionBearingAllowed,
              c(TRUE, FALSE, FALSE)) &&
    identical(nrow(measurement_layers), 4L) &&
    all(measurement_layers$ConflationProhibited) &&
    identical(nrow(complementary), 2L) &&
    all(!complementary$SubstitutesForOtherMethod) &&
    all(!complementary$CountsAsDecisionVote) &&
    identical(nrow(contract$OwnerInputSchema), 13L) &&
    all(!contract$OwnerInputSchema$OwnerInputPresent) &&
    all(!nzchar(contract$OwnerInputSchema$EvidenceIdentity)) &&
    isTRUE(contract$OwnerDecisionBriefSchemaReady) &&
    identical(nrow(contract$OwnerDecisionBriefSchema), 13L) &&
    identical(contract$OwnerDecisionBriefSchema$InputId,
              contract$OwnerInputSchema$InputId) &&
    all(nzchar(contract$OwnerDecisionBriefSchema$DecisionQuestion)) &&
    all(nzchar(contract$OwnerDecisionBriefSchema$RequiredEvidence)) &&
    all(nzchar(contract$OwnerDecisionBriefSchema$StopIfUnresolved)) &&
    all(nzchar(contract$OwnerDecisionBriefSchema$NextOwnerAction)) &&
    isTRUE(contract$AdjudicationRoutingSchemaReady) &&
    !isTRUE(contract$AdjudicationExecutionAllowed) &&
    identical(adjudication_routing,
              mfrmr_gtds_v3_adjudication_routing_schema()) &&
    identical(nrow(adjudication_routing), 13L) &&
    identical(adjudication_routing$InputId,
              contract$OwnerInputSchema$InputId) &&
    identical(adjudication_routing$PhaseOrdinal,
              c(1L, rep(2L, 5L), rep(3L, 3L), rep(4L, 3L), 5L)) &&
    all(nzchar(adjudication_routing$DecisionAuthorityRole)) &&
    all(nzchar(adjudication_routing$EvidenceProviderRole)) &&
    all(nzchar(adjudication_routing$RequiredConfirmationRole)) &&
    all(nzchar(adjudication_routing$ResolutionIfUnsupported)) &&
    all(nzchar(adjudication_routing$DownstreamEffect)) &&
    all(!adjudication_routing$OutcomeDataMayResolve) &&
    identical(nrow(contract$SignoffRequirements), 13L) &&
    all(!contract$SignoffRequirements$Confirmed) &&
    all(!nzchar(contract$SignoffRequirements$Evidence)) &&
    identical(contract$ImplementationIdentity, implementation) &&
    identical(contract$ImplementationIdentityHash,
              mfrmr_gta_hash(implementation)) &&
    isTRUE(contract$FullProfileEnumerationRequired) &&
    !isTRUE(contract$SentinelProfilesDecisionBearing) &&
    !isTRUE(contract$ProfileSelectionUsesOutcomes) &&
    isTRUE(contract$AllEligibleProfilesReported) &&
    !isTRUE(contract$ProfileWeightsAllowedWithoutExternalOwnerWeights) &&
    !isTRUE(contract$MajorityVoteAcrossProfilesAllowed) &&
    !isTRUE(contract$PoolingAcrossDecisionFamiliesAllowed) &&
    !isTRUE(contract$ProfilesCountAsIndependentReplicates) &&
    !isTRUE(contract$ProjectionRowsCountAsIndependentDatasets) &&
    !isTRUE(contract$AnalysisImplementationsCountAsIndependentVotes) &&
    isTRUE(contract$CovarianceDesignBindingRequiredBeforeDsim1) &&
    !isTRUE(contract$CovarianceDesignBindingReady) &&
    isTRUE(contract$CovarianceBindingSchemaReady) &&
    isTRUE(contract$BackendDesignQualificationReady) &&
    !isTRUE(contract$BackendQualificationExecutionAllowed) &&
    identical(contract$CurrentC1CovarianceClaim,
              "matched_backend_overlap_only") &&
    isTRUE(contract$EffectiveWeightsDiagnosticOnly) &&
    !isTRUE(contract$DataDrivenWeightsDecisionBearing) &&
    !isTRUE(contract$FacetCountDefinesLatentDimension) &&
    !isTRUE(contract$MfrmDiagnosticCountsAsDecisionVote) &&
    isTRUE(contract$ProfileChangeAfterPilotInvalidatesConfirmation) &&
    isTRUE(contract$OwnerInputPacketRequired) &&
    identical(
      contract$OwnerInputPacketSchemaVersion,
      "mfrmr-gtheory-multivariate-owner-input-v3-v2"
    ) &&
    isTRUE(contract$OwnerInputPacketValidatorReady) &&
    !isTRUE(contract$OwnerInputPacketReady) &&
    is.na(contract$OwnerInputPacketHash) &&
    !isTRUE(contract$OwnerSignoffReady) &&
    !isTRUE(contract$Dsim0Satisfied) &&
    !isTRUE(contract$SimulationExecutionAllowed) &&
    !isTRUE(contract$PlannedSeedAccessAllowed) &&
    !isTRUE(contract$PublicSupportReady) &&
    identical(stored_hash, mfrmr_gta_hash(payload))
  if (!ready) {
    stop("The D-SIM-0 v3 multiverse contract is incomplete or was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds_v3_signoff_candidate <- function(
    contract = mfrmr_gtds_v3_contract()) {
  mfrmr_gtds_v3_validate_contract(contract)
  payload <- list(
    ReceiptVersion = "mfrmr-gtheory-multivariate-dsim0-v3-signoff-v2",
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    SignerId = NA_character_,
    SignerRole = "mfrmr_practical_multiverse_owner",
    SignedAtUtc = NA_character_,
    ExternalDecisionAnchorType = NA_character_,
    ExternalDecisionAnchor = NA_character_,
    OwnerInputPacketHash = NA_character_,
    OwnerInputPacketExternalAnchor = NA_character_,
    Requirements = contract$SignoffRequirements,
    ReceiptStatus = "candidate_unsigned", Dsim0Satisfied = FALSE
  )
  payload$ReceiptHash <- mfrmr_gta_hash(payload)
  class(payload) <- c("mfrmr_gtds_v3_signoff", "list")
  payload
}

mfrmr_gtds_v3_validate_signed_receipt <- function(
    receipt, owner_input_packet,
    contract = mfrmr_gtds_v3_contract()) {
  mfrmr_gtds_v3_validate_contract(contract)
  mfrmr_gtds_v3_validate_owner_input(
    owner_input_packet, contract, require_complete = TRUE
  )
  if (!inherits(receipt, "mfrmr_gtds_v3_signoff")) {
    stop("`receipt` must be a D-SIM-0 v3 sign-off receipt.", call. = FALSE)
  }
  stored_hash <- receipt$ReceiptHash
  payload <- unclass(receipt)
  payload$ReceiptHash <- NULL
  timestamp_shape_ready <- length(receipt$SignedAtUtc) == 1L &&
    !is.na(receipt$SignedAtUtc) &&
    grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$",
          receipt$SignedAtUtc)
  parsed_timestamp <- if (timestamp_shape_ready) suppressWarnings(as.POSIXct(
    receipt$SignedAtUtc, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"
  )) else as.POSIXct(NA)
  timestamp_ready <- timestamp_shape_ready && !is.na(parsed_timestamp) &&
    identical(
      format(parsed_timestamp, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
      receipt$SignedAtUtc
    )
  allowed_anchor_types <- c(
    "git_commit_plus_remote_url", "osf_registration",
    "timestamped_signed_record"
  )
  hash_ready <- function(value) {
    length(value) == 1L && !is.na(value) &&
      grepl("^[0-9a-f]{64}$", value)
  }
  ready <- identical(
      receipt$ReceiptVersion,
      "mfrmr-gtheory-multivariate-dsim0-v3-signoff-v2"
    ) &&
    identical(receipt$ContractId, contract$ContractId) &&
    identical(receipt$ContractHash, contract$ContractHash) &&
    length(receipt$SignerId) == 1L && !is.na(receipt$SignerId) &&
    nzchar(receipt$SignerId) &&
    identical(receipt$SignerRole, "mfrmr_practical_multiverse_owner") &&
    timestamp_ready &&
    length(receipt$ExternalDecisionAnchorType) == 1L &&
    !is.na(receipt$ExternalDecisionAnchorType) &&
    receipt$ExternalDecisionAnchorType %in% allowed_anchor_types &&
    length(receipt$ExternalDecisionAnchor) == 1L &&
    !is.na(receipt$ExternalDecisionAnchor) &&
    nzchar(receipt$ExternalDecisionAnchor) &&
    hash_ready(receipt$OwnerInputPacketHash) &&
    identical(receipt$OwnerInputPacketHash,
              owner_input_packet$PacketHash) &&
    length(receipt$OwnerInputPacketExternalAnchor) == 1L &&
    !is.na(receipt$OwnerInputPacketExternalAnchor) &&
    nzchar(receipt$OwnerInputPacketExternalAnchor) &&
    identical(receipt$Requirements$RequirementId,
              contract$SignoffRequirements$RequirementId) &&
    identical(receipt$Requirements$RequiredConfirmation,
              contract$SignoffRequirements$RequiredConfirmation) &&
    all(receipt$Requirements$Confirmed) &&
    all(nzchar(receipt$Requirements$Evidence)) &&
    identical(receipt$ReceiptStatus, "owner_signed_externally_anchored") &&
    isTRUE(receipt$Dsim0Satisfied) &&
    identical(stored_hash, mfrmr_gta_hash(payload))
  if (!ready) {
    stop("The D-SIM-0 v3 sign-off receipt is unsigned or invalid.",
         call. = FALSE)
  }
  invisible(TRUE)
}
