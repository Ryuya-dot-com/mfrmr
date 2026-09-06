# Internal D-SIM-3 v4 outcome-blind coverage manifest.
#
# This file selects dataset-generating scenarios from the v4 axes without
# generating responses. Estimands and analysis routes are projections over a
# dataset, not additional independent datasets. No RNG stream or fit is used.

mfrmr_gtds3_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds_v4_contract",
    "mfrmr_gtds_v4_validate_contract", "mfrmr_gtds2_contract"
  )
  target <- environment(mfrmr_gtds3_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the v4 and D-SIM-2 contracts before D-SIM-3: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM3-COVERAGE-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-30",
    ParentDsim2ContractId = "MFRMR-GTHEORY-MV-DSIM2-PLUMBING-V1",
    ParentDsim2ContractHash =
      "5202fcbe1975c3fc898f557b06c50f6fdcbb1cd248b745eb4500d42b163d960b",
    ParentDsim2ObservedRunHash =
      "ff30e8e4ea321b18476eb031f4d43ccd3029f9f286c1b362ff656dad4bb658bc",
    ParentDsim2Record =
      "gtheory-multivariate-dsim2-plumbing-smoke-record-0.2.4.md"
  )
}

mfrmr_gtds3_dataset_axis_registry <- function(v4 = mfrmr_gtds_v4_contract()) {
  v4$MultiverseAxes[!v4$MultiverseAxes$AxisId %in% c(
    "estimand", "analysis_route"
  ), , drop = FALSE]
}

mfrmr_gtds3_anchor_profile <- function() {
  c(
    stratum_count = "two",
    condition_sharing = "identical",
    observation_event = "distinct",
    crossing = "fully_crossed",
    balance = "balanced",
    missingness = "none",
    object_count = "200",
    rater_count = "4",
    repeat_count = "2",
    variance_regime = "regular_interior",
    cross_stratum_covariance = "positive_psd",
    response_distribution = "gaussian"
  )
}

mfrmr_gtds3_closure_profile <- function() {
  profile <- mfrmr_gtds3_anchor_profile()
  profile[["stratum_count"]] <- "one"
  profile[["cross_stratum_covariance"]] <- "zero"
  profile
}

mfrmr_gtds3_contract <- function() {
  mfrmr_gtds3_require_primitives()
  v4 <- mfrmr_gtds_v4_contract()
  identity <- mfrmr_gtds3_identity()
  dataset_axes <- unique(mfrmr_gtds3_dataset_axis_registry(v4)$AxisId)
  payload <- c(identity, list(
    ParentV4ContractHash = v4$ContractHash,
    DatasetAxisIds = dataset_axes,
    ProjectedAxisIds = c("estimand", "analysis_route"),
    AnchorProfile = mfrmr_gtds3_anchor_profile(),
    ClosureProfile = mfrmr_gtds3_closure_profile(),
    SelectionRule = "frozen_outcome_blind_21_scenario_feasible_pair_cover",
    PairwiseScope = "feasible_dataset_axis_level_pairs_only",
    ClosureCrossingRule =
      "one_stratum_is_one_fixed_closure_profile_not_a_stress_factor",
    MandatoryCoverageRoles = c(
      "all", "pairwise", "targeted", "boundary", "closure",
      "negative_control"
    ),
    CanonicalDatasetScenarioCount = 21L,
    MaximumDatasetScenarioCount = 64L,
    ScenarioRowsAreGeneratedDatasets = FALSE,
    EstimandsAreDatasetReplicates = FALSE,
    AnalysisRoutesAreDatasetReplicates = FALSE,
    OutcomeDataAvailableToSelector = FALSE,
    ResponseGenerationAllowed = FALSE,
    RngAccessAllowed = FALSE,
    FitExecutionAllowed = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3_hash(payload)
  )), class = c("mfrmr_gtds3_contract", "list"))
}

mfrmr_gtds3_validate_contract <- function(
    contract = mfrmr_gtds3_contract()) {
  mfrmr_gtds3_require_primitives()
  v4 <- mfrmr_gtds_v4_contract()
  mfrmr_gtds_v4_validate_contract(v4)
  parent <- mfrmr_gtds2_contract()
  canonical <- mfrmr_gtds3_contract()
  valid <- inherits(contract, "mfrmr_gtds3_contract") &&
    identical(contract, canonical) &&
    identical(parent$ContractId, contract$ParentDsim2ContractId) &&
    identical(parent$ContractHash, contract$ParentDsim2ContractHash) &&
    identical(contract$ParentV4ContractHash, v4$ContractHash) &&
    identical(length(contract$DatasetAxisIds), 12L) &&
    identical(contract$ProjectedAxisIds, c("estimand", "analysis_route")) &&
    identical(contract$CanonicalDatasetScenarioCount, 21L) &&
    identical(contract$MaximumDatasetScenarioCount, 64L) &&
    !isTRUE(contract$ScenarioRowsAreGeneratedDatasets) &&
    !isTRUE(contract$EstimandsAreDatasetReplicates) &&
    !isTRUE(contract$AnalysisRoutesAreDatasetReplicates) &&
    !isTRUE(contract$OutcomeDataAvailableToSelector) &&
    !isTRUE(contract$ResponseGenerationAllowed) &&
    !isTRUE(contract$RngAccessAllowed) &&
    !isTRUE(contract$FitExecutionAllowed) &&
    !isTRUE(contract$ExploratoryExecutionAllowed) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The D-SIM-3 coverage contract is invalid or altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3_profile_signature <- function(profile, axis_ids) {
  profile <- as.character(profile[axis_ids])
  paste(paste(axis_ids, profile, sep = "="), collapse = "|")
}

mfrmr_gtds3_pair_token <- function(
    left_axis, left_level, right_axis, right_level, axis_ids) {
  order <- match(c(left_axis, right_axis), axis_ids)
  if (anyNA(order) || left_axis == right_axis) {
    stop("A D-SIM-3 pair needs two known distinct axes.", call. = FALSE)
  }
  if (order[[1L]] > order[[2L]]) {
    temporary_axis <- left_axis; temporary_level <- left_level
    left_axis <- right_axis; left_level <- right_level
    right_axis <- temporary_axis; right_level <- temporary_level
  }
  paste0(
    left_axis, "=", left_level, "||", right_axis, "=", right_level
  )
}

mfrmr_gtds3_profile_pair_tokens <- function(profile, axis_ids) {
  pairs <- utils::combn(axis_ids, 2L, simplify = FALSE)
  vapply(pairs, function(pair) {
    mfrmr_gtds3_pair_token(
      pair[[1L]], profile[[pair[[1L]]]],
      pair[[2L]], profile[[pair[[2L]]]], axis_ids
    )
  }, character(1L))
}

mfrmr_gtds3_profile_validity <- function(profile, contract) {
  axis_ids <- contract$DatasetAxisIds
  if (!identical(names(profile), axis_ids) || anyNA(profile) ||
      any(!nzchar(profile))) {
    return(list(Valid = FALSE, Reason = "malformed_profile"))
  }
  if (identical(profile[["stratum_count"]], "one") &&
      !identical(profile, contract$ClosureProfile)) {
    return(list(
      Valid = FALSE,
      Reason = "one_stratum_reserved_for_fixed_univariate_closure"
    ))
  }
  list(Valid = TRUE, Reason = "")
}

mfrmr_gtds3_pair_universe_registry <- function(contract) {
  mfrmr_gtds3_validate_contract(contract)
  v4 <- mfrmr_gtds_v4_contract()
  axes <- mfrmr_gtds3_dataset_axis_registry(v4)
  levels <- split(
    axes$LevelId,
    factor(axes$AxisId, levels = contract$DatasetAxisIds)
  )
  axis_pairs <- utils::combn(contract$DatasetAxisIds, 2L, simplify = FALSE)
  rows <- list(); ordinal <- 0L
  for (pair in axis_pairs) {
    combinations <- expand.grid(
      LeftLevel = levels[[pair[[1L]]]],
      RightLevel = levels[[pair[[2L]]]],
      KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
    )
    for (index in seq_len(nrow(combinations))) {
      ordinal <- ordinal + 1L
      requested <- c(
        stats::setNames(combinations$LeftLevel[[index]], pair[[1L]]),
        stats::setNames(combinations$RightLevel[[index]], pair[[2L]])
      )
      requests_univariate_closure <-
        "stratum_count" %in% names(requested) &&
        identical(requested[["stratum_count"]], "one")
      profile <- if (requests_univariate_closure) {
        contract$ClosureProfile
      } else {
        contract$AnchorProfile
      }
      profile[names(requested)] <- requested
      validity <- mfrmr_gtds3_profile_validity(profile, contract)
      rows[[ordinal]] <- data.frame(
        PairOrdinal = ordinal,
        LeftAxis = pair[[1L]], LeftLevel = combinations$LeftLevel[[index]],
        RightAxis = pair[[2L]], RightLevel = combinations$RightLevel[[index]],
        PairToken = mfrmr_gtds3_pair_token(
          pair[[1L]], combinations$LeftLevel[[index]],
          pair[[2L]], combinations$RightLevel[[index]],
          contract$DatasetAxisIds
        ),
        Feasible = validity$Valid,
        ExclusionReason = validity$Reason,
        CompletionSignature = if (validity$Valid) {
          mfrmr_gtds3_profile_signature(profile, contract$DatasetAxisIds)
        } else "",
        stringsAsFactors = FALSE
      )
    }
  }
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3_frozen_profile_registry <- function() {
  structure(list(
    stratum_count = c(
      "two", "one", "three", "two", "three", "three", "three",
      "two", "two", "two", "three", "two", "two", "three", "two",
      "two", "two", "two", "two", "two", "two"
    ),
    condition_sharing = c(
      "identical", "identical", "disjoint", "partial_explicit",
      "disjoint", "identical", "partial_explicit", "identical",
      "partial_explicit", "disjoint", "identical", "disjoint",
      "partial_explicit", "disjoint", "partial_explicit", "identical",
      "disjoint", "partial_explicit", "partial_explicit", "identical",
      "identical"
    ),
    observation_event = c(
      "distinct", "distinct", "distinct", "mixed_explicit",
      "one_event_multiple_scores", "mixed_explicit",
      "one_event_multiple_scores", "mixed_explicit",
      "one_event_multiple_scores", "mixed_explicit", "distinct",
      "distinct", "distinct", "one_event_multiple_scores",
      "one_event_multiple_scores", "one_event_multiple_scores",
      "mixed_explicit", "distinct", "mixed_explicit", "mixed_explicit",
      "distinct"
    ),
    crossing = c(
      "fully_crossed", "fully_crossed", "nested", "partially_crossed",
      "fully_crossed", "nested", "partially_crossed", "fully_crossed",
      "partially_crossed", "nested", "fully_crossed",
      "partially_crossed", "nested", "nested", "fully_crossed",
      "partially_crossed", "nested", "fully_crossed", "fully_crossed",
      "fully_crossed", "fully_crossed"
    ),
    balance = c(
      "balanced", "balanced", "moderately_unbalanced",
      "severely_unbalanced", "severely_unbalanced", "balanced",
      "moderately_unbalanced", "moderately_unbalanced", "balanced",
      "severely_unbalanced", "severely_unbalanced", "balanced",
      "moderately_unbalanced", "moderately_unbalanced",
      "severely_unbalanced", "balanced", "balanced", "balanced",
      "moderately_unbalanced", "moderately_unbalanced",
      "severely_unbalanced"
    ),
    missingness = c(
      "none", "none", "mcar_10", "mcar_30", "structural", "structural",
      "mcar_30", "mcar_10", "none", "none", "mcar_30", "mcar_10",
      "structural", "none", "mcar_10", "structural", "mcar_30",
      "mcar_10", "none", "structural", "structural"
    ),
    object_count = c(
      "200", "200", "1000", "50", "50", "1000", "200", "200",
      "1000", "50", "1000", "50", "200", "200", "200", "50",
      "1000", "1000", "50", "200", "200"
    ),
    rater_count = c(
      "4", "4", "2", "8", "2", "8", "4", "8", "2", "4", "2",
      "4", "4", "8", "2", "4", "4", "8", "2", "8", "2"
    ),
    repeat_count = c(
      "2", "2", "1", "1", "2", "2", "2", "1", "1", "1", "2",
      "2", "1", "2", "2", "2", "2", "2", "2", "2", "2"
    ),
    variance_regime = c(
      "regular_interior", "regular_interior", "near_zero_component",
      "dominant_component", "near_singular_covariance",
      "dominant_component", "regular_interior",
      "near_singular_covariance", "near_zero_component",
      "regular_interior", "near_zero_component",
      "near_singular_covariance", "dominant_component",
      "dominant_component", "dominant_component", "near_zero_component",
      "near_singular_covariance", "regular_interior",
      "near_singular_covariance", "near_zero_component",
      "regular_interior"
    ),
    cross_stratum_covariance = c(
      "positive_psd", "zero", "negative_psd", "zero", "positive_psd",
      "negative_psd", "negative_psd", "positive_psd", "positive_psd",
      "negative_psd", "zero", "zero", "zero", "positive_psd",
      "negative_psd", "zero", "positive_psd", "negative_psd",
      "negative_psd", "positive_psd", "positive_psd"
    ),
    response_distribution = c(
      "gaussian", "gaussian", "heavy_tailed", "ordinal_aggregate",
      "ordinal_aggregate", "gaussian", "heavy_tailed", "heavy_tailed",
      "gaussian", "ordinal_aggregate", "ordinal_aggregate", "gaussian",
      "heavy_tailed", "ordinal_aggregate", "heavy_tailed", "heavy_tailed",
      "gaussian", "ordinal_aggregate", "heavy_tailed", "gaussian",
      "gaussian"
    )
  ), class = "data.frame", row.names = c(NA, -21L))
}

mfrmr_gtds3_select_scenarios <- function(contract, axes, pair_universe) {
  feasible_tokens <- sort(unique(
    pair_universe$PairToken[pair_universe$Feasible]
  ), method = "radix")
  anchor_signature <- mfrmr_gtds3_profile_signature(
    contract$AnchorProfile, contract$DatasetAxisIds
  )
  scenarios <- mfrmr_gtds3_frozen_profile_registry()
  if (!identical(names(scenarios), contract$DatasetAxisIds) ||
      !identical(nrow(scenarios), contract$CanonicalDatasetScenarioCount)) {
    stop("The frozen D-SIM-3 profile registry has the wrong shape.",
         call. = FALSE)
  }
  profiles <- lapply(seq_len(nrow(scenarios)), function(index) {
    unlist(scenarios[index, contract$DatasetAxisIds, drop = FALSE],
           use.names = TRUE)
  })
  valid_levels <- paste(axes$AxisId, axes$LevelId, sep = "\036")
  profile_levels <- unlist(lapply(profiles, function(profile) {
    paste(names(profile), profile, sep = "\036")
  }), use.names = FALSE)
  valid_profiles <- vapply(profiles, function(profile) {
    mfrmr_gtds3_profile_validity(profile, contract)$Valid
  }, logical(1L))
  if (!all(profile_levels %in% valid_levels) || !all(valid_profiles) ||
      !identical(profiles[[1L]], contract$AnchorProfile) ||
      !identical(profiles[[2L]], contract$ClosureProfile)) {
    stop("The frozen D-SIM-3 profiles violate the coverage contract.",
         call. = FALSE)
  }
  selected_signatures <- vapply(profiles, function(profile) {
    mfrmr_gtds3_profile_signature(profile, contract$DatasetAxisIds)
  }, character(1L))
  if (anyDuplicated(selected_signatures)) {
    stop("The frozen D-SIM-3 profile registry contains duplicates.",
         call. = FALSE)
  }
  selected_tokens <- lapply(profiles, function(profile) {
    mfrmr_gtds3_profile_pair_tokens(profile, contract$DatasetAxisIds)
  })
  covered <- sort(unique(unlist(selected_tokens)), method = "radix")
  uncovered <- setdiff(feasible_tokens, covered)
  scenarios$ProfileSignature <- selected_signatures
  scenarios$DeviationFromAnchorCount <- vapply(
    profiles, function(profile) {
      as.integer(sum(profile != contract$AnchorProfile))
    }, integer(1L)
  )
  scenarios$ScenarioOrdinal <- seq_len(nrow(scenarios))
  scenarios$ScenarioId <- sprintf("D3-S%03d", scenarios$ScenarioOrdinal)
  role <- vapply(seq_len(nrow(scenarios)), function(index) {
    profile <- scenarios[index, contract$DatasetAxisIds, drop = FALSE]
    if (scenarios$ProfileSignature[[index]] == anchor_signature) {
      return("full_anchor")
    }
    if (profile$stratum_count[[1L]] == "one") return("closure")
    profile_roles <- axes$CoverageRole[match(
      paste(names(profile), unlist(profile), sep = "\036"),
      paste(axes$AxisId, axes$LevelId, sep = "\036")
    )]
    if ("boundary" %in% profile_roles) return("boundary")
    if ("targeted" %in% profile_roles) return("targeted_structural")
    "pairwise_stress"
  }, character(1L))
  scenarios$ScenarioRole <- role
  scenarios$GeneratedDatasetCount <- 0L
  scenarios$ResponseGenerated <- FALSE
  scenarios$RngStreamOpened <- FALSE
  scenarios$ExecutionSelected <- FALSE
  scenarios$ScenarioHash <- vapply(seq_len(nrow(scenarios)), function(index) {
    mfrmr_gtds3_hash(list(
      ScenarioId = scenarios$ScenarioId[[index]],
      Profile = scenarios[index, contract$DatasetAxisIds, drop = FALSE],
      ScenarioRole = scenarios$ScenarioRole[[index]]
    ))
  }, character(1L))
  scenarios <- scenarios[c(
    "ScenarioOrdinal", "ScenarioId", "ScenarioRole",
    contract$DatasetAxisIds, "ProfileSignature", "DeviationFromAnchorCount",
    "GeneratedDatasetCount", "ResponseGenerated", "RngStreamOpened",
    "ExecutionSelected", "ScenarioHash"
  )]
  list(
    Scenarios = scenarios,
    FeasiblePairTokens = feasible_tokens,
    UncoveredPairTokens = uncovered
  )
}

mfrmr_gtds3_estimand_projection <- function(scenarios, v4) {
  estimands <- v4$Estimands$EstimandId
  output <- expand.grid(
    ScenarioId = scenarios$ScenarioId,
    EstimandId = estimands,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  output$ProjectionOrdinal <- seq_len(nrow(output))
  output$SharesGeneratedDatasetAcrossEstimands <- TRUE
  output$CrossEstimandVotingAllowed <- FALSE
  output$ExecutionSelected <- FALSE
  output <- output[c(
    "ProjectionOrdinal", "ScenarioId", "EstimandId",
    "SharesGeneratedDatasetAcrossEstimands", "CrossEstimandVotingAllowed",
    "ExecutionSelected"
  )]
  output
}

mfrmr_gtds3_route_status <- function(profile, route_id) {
  if (identical(profile[["stratum_count"]], "one")) {
    if (identical(route_id, "separate_univariate")) {
      return("univariate_closure_comparator")
    }
    return("not_applicable_univariate_closure")
  }
  if (identical(route_id, "naive_pooling_negative_control")) {
    return("deliberately_invalid_negative_control")
  }
  if (identical(route_id, "separate_univariate")) {
    return("nonpooling_comparator")
  }
  explicit <- profile[["condition_sharing"]] == "partial_explicit" ||
    profile[["observation_event"]] == "mixed_explicit" ||
    profile[["crossing"]] == "partially_crossed"
  if (identical(route_id, "multivariate_lme4_restricted")) {
    if (profile[["observation_event"]] == "distinct" && !explicit) {
      return("conditionally_representable_diagonal_residual")
    }
    return("requires_design_specific_or_custom_contract")
  }
  if (explicit) return("requires_custom_covariance_contract")
  if (profile[["observation_event"]] == "one_event_multiple_scores") {
    return("conditional_linked_event_contract_not_implemented")
  }
  "conditionally_representable_not_implemented"
}

mfrmr_gtds3_route_projection <- function(scenarios, v4, contract) {
  routes <- v4$MultiverseAxes[
    v4$MultiverseAxes$AxisId == "analysis_route", , drop = FALSE
  ]
  grid <- expand.grid(
    ScenarioOrdinal = scenarios$ScenarioOrdinal,
    RouteOrdinal = routes$LevelOrdinal,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  grid$ScenarioId <- scenarios$ScenarioId[grid$ScenarioOrdinal]
  grid$RouteId <- routes$LevelId[grid$RouteOrdinal]
  grid$CoverageRole <- routes$CoverageRole[grid$RouteOrdinal]
  grid$QualificationStatus <- vapply(seq_len(nrow(grid)), function(index) {
    profile <- unlist(
      scenarios[grid$ScenarioOrdinal[[index]], contract$DatasetAxisIds,
                drop = FALSE],
      use.names = TRUE
    )
    mfrmr_gtds3_route_status(profile, grid$RouteId[[index]])
  }, character(1L))
  grid$SharesGeneratedDatasetAcrossRoutes <- TRUE
  grid$CountsAsIndependentDataset <- FALSE
  grid$ExecutionSelected <- FALSE
  grid$ResponseGenerated <- FALSE
  grid[c(
    "ScenarioOrdinal", "ScenarioId", "RouteOrdinal", "RouteId",
    "CoverageRole", "QualificationStatus",
    "SharesGeneratedDatasetAcrossRoutes", "CountsAsIndependentDataset",
    "ExecutionSelected", "ResponseGenerated"
  )]
}

mfrmr_gtds3_control_registry <- function(scenarios) {
  anchor <- scenarios$ScenarioId[scenarios$ScenarioRole == "full_anchor"]
  data.frame(
    ControlOrdinal = 1:3,
    ControlId = c(
      "NC-NAIVE-POOLING", "NC-DISCONNECTED-INCIDENCE",
      "NC-INDEFINITE-COVARIANCE"
    ),
    ControlType = c(
      "invalid_analysis_route", "structural_nonidentification",
      "non_psd_covariance"
    ),
    ScenarioId = c(anchor[[1L]], "", ""),
    ReferenceDesignId = c(
      "", "S2-DISCONNECTED-NEGATIVE", "D-SIM-1-INDEFINITE-PSD-CONTROL"
    ),
    ExpectedDisposition = c(
      "reject_as_estimand_invalid", "reject_before_fit",
      "reject_before_fit"
    ),
    ResponseGenerationRequired = FALSE,
    ExecutionSelected = FALSE,
    PublicSupportReady = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3_pair_coverage <- function(
    pair_universe, scenarios, contract) {
  feasible <- pair_universe[pair_universe$Feasible, , drop = FALSE]
  scenario_tokens <- lapply(seq_len(nrow(scenarios)), function(index) {
    profile <- unlist(
      scenarios[index, contract$DatasetAxisIds, drop = FALSE],
      use.names = TRUE
    )
    mfrmr_gtds3_profile_pair_tokens(profile, contract$DatasetAxisIds)
  })
  feasible$CoveredByScenarioCount <- vapply(feasible$PairToken, function(token) {
    sum(vapply(scenario_tokens, function(tokens) token %in% tokens,
               logical(1L)))
  }, integer(1L))
  feasible$CoveredByScenarioIds <- vapply(feasible$PairToken, function(token) {
    paste(scenarios$ScenarioId[vapply(
      scenario_tokens, function(tokens) token %in% tokens, logical(1L)
    )], collapse = ";")
  }, character(1L))
  feasible$Covered <- feasible$CoveredByScenarioCount > 0L
  feasible
}

mfrmr_gtds3_level_coverage <- function(
    scenarios, estimands, routes, axes, contract) {
  rows <- lapply(seq_len(nrow(axes)), function(index) {
    axis <- axes$AxisId[[index]]; level <- axes$LevelId[[index]]
    if (axis %in% contract$DatasetAxisIds) {
      ids <- scenarios$ScenarioId[scenarios[[axis]] == level]
      source <- "dataset_scenario"
    } else if (axis == "estimand") {
      ids <- estimands$ScenarioId[estimands$EstimandId == level]
      source <- "estimand_projection"
    } else {
      ids <- routes$ScenarioId[routes$RouteId == level]
      source <- "route_projection"
    }
    data.frame(
      AxisOrdinal = axes$AxisOrdinal[[index]], AxisId = axis,
      LevelOrdinal = axes$LevelOrdinal[[index]], LevelId = level,
      CoverageRole = axes$CoverageRole[[index]], CoverageSource = source,
      CoveringRowCount = as.integer(length(ids)),
      CoveringScenarioIds = paste(unique(ids), collapse = ";"),
      Covered = length(ids) > 0L,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gtds3_role_coverage <- function(level_coverage) {
  roles <- c("all", "pairwise", "targeted", "boundary", "closure",
             "negative_control")
  rows <- lapply(seq_along(roles), function(index) {
    subset <- level_coverage$CoverageRole == roles[[index]]
    data.frame(
      RoleOrdinal = index, CoverageRole = roles[[index]],
      DeclaredLevelCount = as.integer(sum(subset)),
      CoveredLevelCount = as.integer(sum(level_coverage$Covered[subset])),
      Complete = sum(subset) > 0L && all(level_coverage$Covered[subset]),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gtds3_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds3_require_primitives", "mfrmr_gtds3_hash",
    "mfrmr_gtds3_identity", "mfrmr_gtds3_dataset_axis_registry",
    "mfrmr_gtds3_anchor_profile", "mfrmr_gtds3_closure_profile",
    "mfrmr_gtds3_contract", "mfrmr_gtds3_validate_contract",
    "mfrmr_gtds3_profile_signature", "mfrmr_gtds3_pair_token",
    "mfrmr_gtds3_profile_pair_tokens", "mfrmr_gtds3_profile_validity",
    "mfrmr_gtds3_pair_universe_registry",
    "mfrmr_gtds3_frozen_profile_registry",
    "mfrmr_gtds3_select_scenarios", "mfrmr_gtds3_estimand_projection",
    "mfrmr_gtds3_route_status", "mfrmr_gtds3_route_projection",
    "mfrmr_gtds3_control_registry", "mfrmr_gtds3_pair_coverage",
    "mfrmr_gtds3_level_coverage", "mfrmr_gtds3_role_coverage",
    "mfrmr_gtds3_implementation_identity", "mfrmr_gtds3_payload_fields",
    "mfrmr_gtds3_assert_manifest", "mfrmr_gtds3_manifest"
  )
  target <- environment(mfrmr_gtds3_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions), FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds3_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3_payload_fields <- function() {
  c(
    "Contract", "ScenarioRegistry", "EstimandProjectionRegistry",
    "RouteProjectionRegistry", "NegativeControlRegistry",
    "LevelCoverageRegistry", "FeasiblePairCoverageRegistry",
    "ExcludedPairRegistry", "RoleCoverageRegistry",
    "ImplementationIdentity", "Summary"
  )
}

mfrmr_gtds3_assert_manifest <- function(manifest) {
  fields <- mfrmr_gtds3_payload_fields()
  if (!inherits(manifest, "mfrmr_gtds3_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed D-SIM-3 coverage manifest is required.", call. = FALSE)
  }
  mfrmr_gtds3_validate_contract(manifest$Contract)
  false_flags <- c(
    "ResponseGenerated", "RngStreamOpened", "FitExecuted",
    "ExploratoryExecutionAllowed", "SimulationValidationReady",
    "ReferenceValidationReady", "InferenceReady", "DecisionReady",
    "PublicSupportReady"
  )
  frozen_profiles <- mfrmr_gtds3_frozen_profile_registry()
  scenario_ids <- sprintf(
    "D3-S%03d", seq_len(manifest$Contract$CanonicalDatasetScenarioCount)
  )
  valid <- identical(
    manifest$ManifestHash, mfrmr_gtds3_hash(manifest[fields])
  ) && identical(
    manifest$ImplementationIdentity, mfrmr_gtds3_implementation_identity()
  ) && identical(
    nrow(manifest$ScenarioRegistry),
    manifest$Contract$CanonicalDatasetScenarioCount
  ) && nrow(manifest$ScenarioRegistry) <=
    manifest$Contract$MaximumDatasetScenarioCount &&
    identical(manifest$ScenarioRegistry$ScenarioId, scenario_ids) &&
    identical(
      manifest$ScenarioRegistry[manifest$Contract$DatasetAxisIds],
      frozen_profiles
    ) &&
    !anyDuplicated(manifest$ScenarioRegistry$ScenarioId) &&
    !anyDuplicated(manifest$ScenarioRegistry$ProfileSignature) &&
    all(manifest$ScenarioRegistry$GeneratedDatasetCount == 0L) &&
    all(!manifest$ScenarioRegistry$ResponseGenerated) &&
    all(!manifest$ScenarioRegistry$RngStreamOpened) &&
    all(!manifest$ScenarioRegistry$ExecutionSelected) &&
    all(manifest$LevelCoverageRegistry$Covered) &&
    all(manifest$FeasiblePairCoverageRegistry$Covered) &&
    nrow(manifest$ExcludedPairRegistry) > 0L &&
    all(nzchar(manifest$ExcludedPairRegistry$ExclusionReason)) &&
    all(manifest$RoleCoverageRegistry$Complete) &&
    all(manifest$EstimandProjectionRegistry$SharesGeneratedDatasetAcrossEstimands) &&
    all(!manifest$EstimandProjectionRegistry$CrossEstimandVotingAllowed) &&
    all(!manifest$EstimandProjectionRegistry$ExecutionSelected) &&
    all(manifest$RouteProjectionRegistry$SharesGeneratedDatasetAcrossRoutes) &&
    all(!manifest$RouteProjectionRegistry$CountsAsIndependentDataset) &&
    all(!manifest$RouteProjectionRegistry$ExecutionSelected) &&
    all(!manifest$NegativeControlRegistry$ExecutionSelected) &&
    identical(
      manifest$NegativeControlRegistry$ControlId,
      c("NC-NAIVE-POOLING", "NC-DISCONNECTED-INCIDENCE",
        "NC-INDEFINITE-COVARIANCE")
    ) &&
    all(table(manifest$EstimandProjectionRegistry$ScenarioId) == 2L) &&
    all(table(manifest$RouteProjectionRegistry$ScenarioId) == 5L) &&
    identical(manifest$Summary$DeclaredLevelCount, 44L) &&
    identical(manifest$Summary$CoveredLevelCount, 44L) &&
    identical(manifest$Summary$DatasetScenarioCount, 21L) &&
    identical(manifest$Summary$GeneratedDatasetCount, 0L) &&
    identical(manifest$Summary$FeasiblePairCount, 603L) &&
    identical(manifest$Summary$CoveredFeasiblePairCount, 603L) &&
    identical(manifest$Summary$ExcludedStructuralPairCount, 23L) &&
    identical(manifest$Summary$FeatureMaturity, "specified") &&
    isTRUE(manifest$Summary$Dsim3CoverageManifestSatisfied) &&
    isTRUE(manifest$Summary$Dsim3ExecutionContractAllowed) &&
    !any(vapply(false_flags, function(name) {
      isTRUE(manifest$Summary[[name]])
    }, logical(1L)))
  if (!valid) {
    stop("The D-SIM-3 coverage manifest or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3_manifest <- function(contract = mfrmr_gtds3_contract()) {
  mfrmr_gtds3_validate_contract(contract)
  v4 <- mfrmr_gtds_v4_contract()
  axes <- v4$MultiverseAxes
  dataset_axes <- mfrmr_gtds3_dataset_axis_registry(v4)
  pairs <- mfrmr_gtds3_pair_universe_registry(contract)
  selection <- mfrmr_gtds3_select_scenarios(contract, dataset_axes, pairs)
  if (length(selection$UncoveredPairTokens) > 0L) {
    stop("The D-SIM-3 scenario cap leaves feasible pairs uncovered.",
         call. = FALSE)
  }
  scenarios <- selection$Scenarios
  estimands <- mfrmr_gtds3_estimand_projection(scenarios, v4)
  routes <- mfrmr_gtds3_route_projection(scenarios, v4, contract)
  controls <- mfrmr_gtds3_control_registry(scenarios)
  pair_coverage <- mfrmr_gtds3_pair_coverage(pairs, scenarios, contract)
  excluded <- pairs[!pairs$Feasible, , drop = FALSE]
  level_coverage <- mfrmr_gtds3_level_coverage(
    scenarios, estimands, routes, axes, contract
  )
  role_coverage <- mfrmr_gtds3_role_coverage(level_coverage)
  implementation <- mfrmr_gtds3_implementation_identity()
  summary <- list(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    DatasetAxisCount = length(contract$DatasetAxisIds),
    ProjectedAxisCount = length(contract$ProjectedAxisIds),
    DeclaredLevelCount = nrow(axes),
    CoveredLevelCount = sum(level_coverage$Covered),
    DatasetScenarioCount = nrow(scenarios),
    GeneratedDatasetCount = 0L,
    EstimandProjectionCount = nrow(estimands),
    RouteProjectionCount = nrow(routes),
    FeasiblePairCount = nrow(pair_coverage),
    CoveredFeasiblePairCount = sum(pair_coverage$Covered),
    ExcludedStructuralPairCount = nrow(excluded),
    NegativeControlCount = nrow(controls),
    Dsim3CoverageManifestSatisfied =
      all(level_coverage$Covered) && all(pair_coverage$Covered) &&
      all(role_coverage$Complete),
    Dsim3ExecutionContractAllowed = TRUE,
    FeatureMaturity = "specified",
    ResponseGenerated = FALSE,
    RngStreamOpened = FALSE,
    FitExecuted = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationReady = FALSE,
    ReferenceValidationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE,
    NextAction = paste(
      "freeze a separate D-SIM-3 exploratory execution contract with",
      "nonreserved seed namespace, replication budget, terminal accounting,",
      "and resource limits before generating any multiverse response"
    )
  )
  payload <- list(
    Contract = contract, ScenarioRegistry = scenarios,
    EstimandProjectionRegistry = estimands,
    RouteProjectionRegistry = routes,
    NegativeControlRegistry = controls,
    LevelCoverageRegistry = level_coverage,
    FeasiblePairCoverageRegistry = pair_coverage,
    ExcludedPairRegistry = excluded,
    RoleCoverageRegistry = role_coverage,
    ImplementationIdentity = implementation, Summary = summary
  )
  manifest <- structure(c(payload, list(
    ManifestHash = mfrmr_gtds3_hash(payload)
  )), class = c("mfrmr_gtds3_manifest", "list"))
  mfrmr_gtds3_assert_manifest(manifest)
  manifest
}
