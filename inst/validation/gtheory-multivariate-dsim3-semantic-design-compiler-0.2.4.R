# Internal D-SIM-3 shared semantic design compiler.
#
# This first shared-substrate layer compiles every frozen profile into typed
# object, stratum, condition, assignment, observation-event, and missingness
# identities. It uses no RNG, generates no response, calls no backend, and
# does not qualify covariance or response-distribution generation.

mfrmr_gtds3c_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds3_manifest",
    "mfrmr_gtds3_assert_manifest", "mfrmr_gtds3e_plan",
    "mfrmr_gtds3e_assert_plan", "mfrmr_gtds3q_manifest",
    "mfrmr_gtds3q_assert_manifest"
  )
  target <- environment(mfrmr_gtds3c_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the D-SIM-3 coverage, execution, and qualification chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3c_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3c_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM3-SEMANTIC-DESIGN-COMPILER-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-30",
    ParentQualificationContractId =
      "MFRMR-GTHEORY-MV-DSIM3-PREEXEC-QUALIFICATION-V1",
    ParentQualificationContractHash =
      "00cf1c34c0d3e70e4b2896b365f5592e04b00ef63bc6dede35d9bfc3bd94f762",
    ParentQualificationManifestHash =
      "05d5bf2bfb0942ddb728aff31dce69de7298065081f3f268e18943074cd96755",
    ParentQualificationRecord = paste0(
      "gtheory-multivariate-dsim3-preexecution-qualification-record-",
      "0.2.4.md"
    )
  )
}

mfrmr_gtds3c_semantic_rules <- function() {
  data.frame(
    RuleOrdinal = 1:22,
    AxisId = c(
      rep("stratum_count", 3L), rep("condition_sharing", 3L),
      rep("observation_event", 3L), rep("crossing", 3L),
      rep("balance", 3L), rep("missingness", 4L),
      "object_count", "rater_count", "repeat_count"
    ),
    LevelId = c(
      "one", "two", "three",
      "disjoint", "identical", "partial_explicit",
      "distinct", "one_event_multiple_scores", "mixed_explicit",
      "fully_crossed", "nested", "partially_crossed",
      "balanced", "moderately_unbalanced", "severely_unbalanced",
      "none", "mcar_10", "mcar_30", "structural",
      "positive_integer_from_frozen_level",
      "ratings_per_object_stratum_before_repeat_and_missingness",
      "positive_integer_from_frozen_level"
    ),
    CompilerRule = c(
      "ordered_strata_S1", "ordered_strata_S1_to_S2",
      "ordered_strata_S1_to_S3",
      "condition_ids_are_stratum_local",
      "condition_ids_are_shared_for_the_same_assignment",
      "lower_half_base_conditions_shared_remainder_stratum_local",
      "event_id_is_distinct_for_each_stratum_score",
      "event_id_links_same_object_slot_repeat_across_observed_strata",
      "lower_half_slots_linked_remainder_distinct",
      "all_declared_conditions_per_object_stratum",
      "condition_slots_are_nested_within_object",
      "cyclic_half_pool_connected_incomplete_assignment",
      "all_registered_objects_in_each_stratum",
      "stratum_exposure_fractions_from_one_to_point_eight",
      "stratum_exposure_fractions_from_one_to_point_five",
      "all_scheduled_rows_observed",
      "fixed_outcome_blind_rank_mask_at_point_one",
      "fixed_outcome_blind_rank_mask_at_point_three",
      "last_condition_slot_omitted_for_even_objects",
      "one_global_registered_object_universe",
      "one_declared_information_count_not_a_global_pool_size",
      "replications_per_scheduled_object_condition_cell"
    ),
    StochasticOperationRequired = FALSE,
    ScenarioSpecificPatchAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3c_contract <- function() {
  mfrmr_gtds3c_require_primitives()
  qualification <- mfrmr_gtds3q_manifest()
  identity <- mfrmr_gtds3c_identity()
  compiled_axes <- c(
    "stratum_count", "condition_sharing", "observation_event",
    "crossing", "balance", "missingness", "object_count",
    "rater_count", "repeat_count"
  )
  payload <- c(identity, list(
    ParentExecutionPlanHash = qualification$ParentExecutionPlanHash,
    ExpectedProfileCount = 21L,
    CompiledAxisIds = compiled_axes,
    DeferredGeneratorAxisIds = c(
      "variance_regime", "cross_stratum_covariance",
      "response_distribution"
    ),
    SemanticRuleRegistry = mfrmr_gtds3c_semantic_rules(),
    ObjectIdentityRole = "one_global_object_universe_shared_by_strata",
    RaterCountRole = paste(
      "ratings_per_object_stratum_before_repeat_and_missingness",
      "not_global_unique_rater_count", sep = "_"
    ),
    BalanceRole = "stratum_specific_object_exposure",
    CrossingRole = "object_by_condition_assignment_within_stratum",
    MissingnessRole = paste(
      "outcome_blind_scheduled_observation_mask",
      "not_stochastic_mcar_generation", sep = "_"
    ),
    CanonicalOrdering = paste(
      "stratum_ordinal", "object_ordinal", "rater_slot_ordinal",
      "repeat_ordinal", sep = ">"
    ),
    ScenarioSpecificBranchCount = 0L,
    AllProfilesMustCompile = TRUE,
    CompilerMayUseRng = FALSE,
    CompilerMayGenerateResponses = FALSE,
    CompilerMayCallBackend = FALSE,
    StochasticMissingnessQualified = FALSE,
    CovarianceGeneratorQualified = FALSE,
    ResponseDistributionGeneratorQualified = FALSE,
    RouteAdapterQualified = FALSE,
    TerminalReceiptAdapterQualified = FALSE,
    ResourceControllerQualified = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3c_hash(payload)
  )), class = c("mfrmr_gtds3c_contract", "list"))
}

mfrmr_gtds3c_validate_contract <- function(
    contract = mfrmr_gtds3c_contract()) {
  mfrmr_gtds3c_require_primitives()
  qualification <- mfrmr_gtds3q_manifest()
  mfrmr_gtds3q_assert_manifest(qualification)
  canonical <- mfrmr_gtds3c_contract()
  valid <- inherits(contract, "mfrmr_gtds3c_contract") &&
    identical(contract, canonical) &&
    identical(
      contract$ParentQualificationContractHash,
      qualification$Contract$ContractHash
    ) && identical(
      contract$ParentQualificationManifestHash,
      qualification$ManifestHash
    ) && identical(contract$ExpectedProfileCount, 21L) &&
    identical(length(contract$CompiledAxisIds), 9L) &&
    identical(length(contract$DeferredGeneratorAxisIds), 3L) &&
    identical(nrow(contract$SemanticRuleRegistry), 22L) &&
    identical(contract$ScenarioSpecificBranchCount, 0L) &&
    isTRUE(contract$AllProfilesMustCompile) &&
    all(!contract$SemanticRuleRegistry$StochasticOperationRequired) &&
    all(!contract$SemanticRuleRegistry$ScenarioSpecificPatchAllowed) &&
    !isTRUE(contract$CompilerMayUseRng) &&
    !isTRUE(contract$CompilerMayGenerateResponses) &&
    !isTRUE(contract$CompilerMayCallBackend) &&
    !isTRUE(contract$StochasticMissingnessQualified) &&
    !isTRUE(contract$CovarianceGeneratorQualified) &&
    !isTRUE(contract$ResponseDistributionGeneratorQualified) &&
    !isTRUE(contract$RouteAdapterQualified) &&
    !isTRUE(contract$TerminalReceiptAdapterQualified) &&
    !isTRUE(contract$ResourceControllerQualified) &&
    !isTRUE(contract$ExploratoryExecutionAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The D-SIM-3 semantic design-compiler contract is invalid.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3c_profile <- function(scenario_id, coverage) {
  scenario_id <- as.character(scenario_id)
  if (length(scenario_id) != 1L || is.na(scenario_id) ||
      !scenario_id %in% coverage$ScenarioRegistry$ScenarioId) {
    stop("`scenario_id` must identify one frozen D-SIM-3 profile.",
         call. = FALSE)
  }
  scenario <- coverage$ScenarioRegistry[
    coverage$ScenarioRegistry$ScenarioId == scenario_id, , drop = FALSE
  ]
  profile <- unlist(
    scenario[coverage$Contract$DatasetAxisIds], use.names = TRUE
  )
  list(Scenario = scenario, Profile = profile)
}

mfrmr_gtds3c_positive_level <- function(profile, axis_id) {
  value <- suppressWarnings(as.integer(profile[[axis_id]]))
  if (length(value) != 1L || is.na(value) || value < 1L ||
      !identical(as.character(value), profile[[axis_id]])) {
    stop("The frozen `", axis_id, "` level is not a positive integer.",
         call. = FALSE)
  }
  value
}

mfrmr_gtds3c_strata <- function(profile) {
  count <- match(profile[["stratum_count"]], c("one", "two", "three"))
  if (is.na(count)) {
    stop("The stratum-count level is not compiled.", call. = FALSE)
  }
  data.frame(
    StratumOrdinal = seq_len(count), Stratum = paste0("S", seq_len(count)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3c_objects <- function(profile) {
  count <- mfrmr_gtds3c_positive_level(profile, "object_count")
  width <- max(4L, nchar(as.character(count)))
  data.frame(
    ObjectOrdinal = seq_len(count),
    ObjectId = sprintf(paste0("O%0", width, "d"), seq_len(count)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3c_balance_fractions <- function(balance, stratum_count) {
  if (identical(balance, "balanced") || stratum_count == 1L) {
    return(rep(1, stratum_count))
  }
  endpoint <- switch(
    balance, moderately_unbalanced = 0.8, severely_unbalanced = 0.5,
    stop("The balance level is not compiled.", call. = FALSE)
  )
  seq(1, endpoint, length.out = stratum_count)
}

mfrmr_gtds3c_object_strata <- function(profile, strata, objects) {
  fractions <- mfrmr_gtds3c_balance_fractions(
    profile[["balance"]], nrow(strata)
  )
  counts <- pmax(2L, as.integer(floor(nrow(objects) * fractions + 1e-12)))
  counts[[1L]] <- nrow(objects)
  rows <- lapply(seq_len(nrow(strata)), function(index) {
    data.frame(
      StratumOrdinal = strata$StratumOrdinal[[index]],
      Stratum = strata$Stratum[[index]],
      ObjectOrdinal = objects$ObjectOrdinal[seq_len(counts[[index]])],
      ObjectId = objects$ObjectId[seq_len(counts[[index]])],
      TargetExposureFraction = fractions[[index]],
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3c_assignment_rows <- function(
    scenario_id, profile, object_strata) {
  rater_count <- mfrmr_gtds3c_positive_level(profile, "rater_count")
  repeat_count <- mfrmr_gtds3c_positive_level(profile, "repeat_count")
  base_index <- rep(
    seq_len(nrow(object_strata)), each = rater_count * repeat_count
  )
  rows <- object_strata[base_index, c(
    "StratumOrdinal", "Stratum", "ObjectOrdinal", "ObjectId"
  )]
  rows$RaterSlotOrdinal <- rep(
    rep(seq_len(rater_count), each = repeat_count),
    times = nrow(object_strata)
  )
  rows$RepeatOrdinal <- rep(
    seq_len(repeat_count), times = nrow(object_strata) * rater_count
  )
  crossing <- profile[["crossing"]]
  if (identical(crossing, "fully_crossed")) {
    pool_size <- rater_count
    base_ordinal <- rows$RaterSlotOrdinal
    raw_id <- sprintf("R%03d", base_ordinal)
  } else if (identical(crossing, "partially_crossed")) {
    pool_size <- 2L * rater_count
    base_ordinal <- (
      rows$ObjectOrdinal + rows$RaterSlotOrdinal - 2L
    ) %% pool_size + 1L
    raw_id <- sprintf("R%03d", base_ordinal)
  } else if (identical(crossing, "nested")) {
    pool_size <- rater_count
    base_ordinal <- rows$RaterSlotOrdinal
    raw_id <- paste0(
      rows$ObjectId, "/", sprintf("R%03d", base_ordinal)
    )
  } else {
    stop("The crossing level is not compiled.", call. = FALSE)
  }
  rows$RaterBaseOrdinal <- as.integer(base_ordinal)
  rows$RaterRawId <- raw_id
  sharing <- profile[["condition_sharing"]]
  shared_cut <- ceiling(pool_size / 2)
  if (identical(sharing, "identical")) {
    shared <- rep(TRUE, nrow(rows))
  } else if (identical(sharing, "disjoint")) {
    shared <- rep(FALSE, nrow(rows))
  } else if (identical(sharing, "partial_explicit")) {
    shared <- rows$RaterBaseOrdinal <= shared_cut
  } else {
    stop("The condition-sharing level is not compiled.", call. = FALSE)
  }
  rows$ConditionSharedAcrossStrata <- shared
  rows$ConditionId <- ifelse(
    shared, rows$RaterRawId, paste(rows$Stratum, rows$RaterRawId, sep = "/")
  )
  rows$AssignmentOrdinal <- seq_len(nrow(rows))
  rows$RowId <- sprintf("%s-R%08d", scenario_id, rows$AssignmentOrdinal)
  rows$ConditionPoolSize <- pool_size
  rows[c(
    "AssignmentOrdinal", "RowId", "StratumOrdinal", "Stratum",
    "ObjectOrdinal", "ObjectId", "RaterSlotOrdinal", "RaterBaseOrdinal",
    "RaterRawId", "ConditionId", "ConditionSharedAcrossStrata",
    "ConditionPoolSize", "RepeatOrdinal"
  )]
}

mfrmr_gtds3c_eventize <- function(scenario_id, profile, assignments) {
  relationship <- profile[["observation_event"]]
  rater_count <- mfrmr_gtds3c_positive_level(profile, "rater_count")
  link_cut <- floor(rater_count / 2)
  if (identical(relationship, "distinct")) {
    linked <- rep(FALSE, nrow(assignments))
    prefix <- "D"
  } else if (identical(relationship, "one_event_multiple_scores")) {
    linked <- rep(TRUE, nrow(assignments))
    prefix <- "L"
  } else if (identical(relationship, "mixed_explicit")) {
    linked <- assignments$RaterSlotOrdinal <= link_cut
    prefix <- ifelse(linked, "M-L", "M-D")
  } else {
    stop("The observation-event level is not compiled.", call. = FALSE)
  }
  linked_id <- paste(
    "EV", prefix, scenario_id, assignments$ObjectId,
    sprintf("C%03d", assignments$RaterSlotOrdinal),
    sprintf("P%02d", assignments$RepeatOrdinal), sep = "/"
  )
  distinct_id <- paste(
    "EV", prefix, scenario_id, assignments$Stratum, assignments$ObjectId,
    sprintf("C%03d", assignments$RaterSlotOrdinal),
    sprintf("P%02d", assignments$RepeatOrdinal), sep = "/"
  )
  assignments$EventLinkedAcrossStrata <- linked
  assignments$EventId <- ifelse(linked, linked_id, distinct_id)
  assignments$ScoreChannel <- paste0("Score/", assignments$Stratum)
  assignments
}

mfrmr_gtds3c_mcar_mask <- function(assignments, rate, scenario_ordinal) {
  target <- as.integer(floor(nrow(assignments) * rate + 1e-12))
  if (target == 0L) return(rep(FALSE, nrow(assignments)))
  modulus <- 2147483647
  key <- (
    assignments$AssignmentOrdinal * 48271 + scenario_ordinal * 104729
  ) %% modulus
  if (anyDuplicated(key)) {
    stop("The deterministic missingness rank contains a collision.",
         call. = FALSE)
  }
  omitted <- rep(FALSE, nrow(assignments))
  omitted[order(key, assignments$AssignmentOrdinal, method = "radix")[
    seq_len(target)
  ]] <- TRUE
  cell <- paste(assignments$Stratum, assignments$ObjectId, sep = "\036")
  empty <- names(which(tapply(!omitted, cell, sum) == 0L))
  for (empty_cell in empty) {
    restore <- which(cell == empty_cell & omitted)
    restore <- restore[order(key[restore], decreasing = TRUE,
                             method = "radix")][[1L]]
    omitted[[restore]] <- FALSE
    retained_by_cell <- tapply(!omitted, cell, sum)
    candidates <- which(
      !omitted & retained_by_cell[cell] > 1L &
        seq_along(omitted) != restore
    )
    if (length(candidates) == 0L) {
      stop("The deterministic missingness mask cannot preserve cell support.",
           call. = FALSE)
    }
    replacement <- candidates[order(
      key[candidates], assignments$AssignmentOrdinal[candidates],
      method = "radix"
    )][[1L]]
    omitted[[replacement]] <- TRUE
  }
  if (sum(omitted) != target) {
    stop("The deterministic missingness mask changed its denominator.",
         call. = FALSE)
  }
  omitted
}

mfrmr_gtds3c_apply_missingness <- function(
    profile, assignments, scenario_ordinal) {
  missingness <- profile[["missingness"]]
  if (identical(missingness, "none")) {
    omitted <- rep(FALSE, nrow(assignments))
    disposition <- rep("scheduled_observed", nrow(assignments))
  } else if (missingness %in% c("mcar_10", "mcar_30")) {
    rate <- if (missingness == "mcar_10") 0.10 else 0.30
    omitted <- mfrmr_gtds3c_mcar_mask(assignments, rate, scenario_ordinal)
    disposition <- ifelse(
      omitted, paste0("fixed_audit_mask_", missingness),
      "scheduled_observed"
    )
  } else if (identical(missingness, "structural")) {
    rater_count <- mfrmr_gtds3c_positive_level(profile, "rater_count")
    omitted <- assignments$RaterSlotOrdinal == rater_count &
      assignments$ObjectOrdinal %% 2L == 0L
    disposition <- ifelse(
      omitted, "design_induced_structural_absence", "scheduled_observed"
    )
  } else {
    stop("The missingness level is not compiled.", call. = FALSE)
  }
  assignments$ResponseScheduled <- !omitted
  assignments$MissingnessDisposition <- disposition
  assignments$ResponseGenerated <- FALSE
  assignments
}

mfrmr_gtds3c_pair_audit <- function(assignments, strata, value_col,
                                     audit_prefix) {
  pairs <- if (nrow(strata) == 1L) {
    list(c(strata$Stratum[[1L]], strata$Stratum[[1L]]))
  } else {
    utils::combn(strata$Stratum, 2L, simplify = FALSE)
  }
  rows <- lapply(seq_along(pairs), function(index) {
    pair <- pairs[[index]]
    left <- unique(assignments[
      assignments$Stratum == pair[[1L]],
      c("ObjectId", "RaterSlotOrdinal", "RepeatOrdinal", value_col),
      drop = FALSE
    ])
    right <- unique(assignments[
      assignments$Stratum == pair[[2L]],
      c("ObjectId", "RaterSlotOrdinal", "RepeatOrdinal", value_col),
      drop = FALSE
    ])
    if (pair[[1L]] == pair[[2L]]) {
      matched <- nrow(left)
      compared <- nrow(left)
    } else {
      joined <- merge(
        left, right,
        by = c("ObjectId", "RaterSlotOrdinal", "RepeatOrdinal"),
        suffixes = c("Left", "Right"), sort = FALSE
      )
      compared <- nrow(joined)
      matched <- sum(joined[[paste0(value_col, "Left")]] ==
                       joined[[paste0(value_col, "Right")]])
    }
    data.frame(
      PairOrdinal = index,
      LeftStratum = pair[[1L]], RightStratum = pair[[2L]],
      ComparedBindings = as.integer(compared),
      SharedBindings = as.integer(matched),
      DistinctBindings = as.integer(compared - matched),
      AuditRole = audit_prefix,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gtds3c_condition_semantics <- function(profile, audit) {
  if (profile[["stratum_count"]] == "one") return(TRUE)
  sharing <- profile[["condition_sharing"]]
  if (sharing == "identical") return(all(audit$DistinctBindings == 0L))
  if (sharing == "disjoint") return(all(audit$SharedBindings == 0L))
  all(audit$SharedBindings > 0L & audit$DistinctBindings > 0L)
}

mfrmr_gtds3c_event_semantics <- function(profile, audit) {
  if (profile[["stratum_count"]] == "one") return(TRUE)
  relationship <- profile[["observation_event"]]
  if (relationship == "distinct") return(all(audit$SharedBindings == 0L))
  if (relationship == "one_event_multiple_scores") {
    return(all(audit$DistinctBindings == 0L))
  }
  all(audit$SharedBindings > 0L & audit$DistinctBindings > 0L)
}

mfrmr_gtds3c_crossing_semantics <- function(profile, assignments) {
  rater_count <- mfrmr_gtds3c_positive_level(profile, "rater_count")
  cell <- paste(assignments$Stratum, assignments$ObjectId, sep = "\036")
  unique_slots <- tapply(assignments$RaterSlotOrdinal, cell, function(x) {
    length(unique(x))
  })
  if (!all(unique_slots == rater_count)) return(FALSE)
  crossing <- profile[["crossing"]]
  if (crossing == "fully_crossed") {
    return(all(assignments$ConditionPoolSize == rater_count))
  }
  if (crossing == "partially_crossed") {
    pools <- unique(assignments[c(
      "ObjectId", "RaterBaseOrdinal", "ConditionPoolSize"
    )])
    return(
      all(pools$ConditionPoolSize == 2L * rater_count) &&
        length(unique(pools$RaterBaseOrdinal)) == 2L * rater_count
    )
  }
  raw_objects <- split(assignments$ObjectId, assignments$RaterRawId)
  all(vapply(raw_objects, function(x) length(unique(x)) == 1L, logical(1L)))
}

mfrmr_gtds3c_compile_profile <- function(
    scenario_id, contract = mfrmr_gtds3c_contract(),
    coverage = mfrmr_gtds3_manifest(), validate = TRUE) {
  if (isTRUE(validate)) {
    mfrmr_gtds3c_validate_contract(contract)
    mfrmr_gtds3_assert_manifest(coverage)
  } else if (!inherits(contract, "mfrmr_gtds3c_contract") ||
             !identical(
               contract$ContractHash,
               "67cb6077c0b0fb083362c0b7bae498be6695e61a0f84d1636f992479ef79f666"
             ) || !inherits(coverage, "mfrmr_gtds3_manifest") ||
             !identical(
               coverage$ManifestHash,
               "4c6958f00aac7598d777387ec113cd43474031430492e83e6183d19dcedf7197"
             )) {
    stop("Validated D-SIM-3 compiler and coverage identities are required.",
         call. = FALSE)
  }
  selected <- mfrmr_gtds3c_profile(scenario_id, coverage)
  scenario <- selected$Scenario
  profile <- selected$Profile
  strata <- mfrmr_gtds3c_strata(profile)
  objects <- mfrmr_gtds3c_objects(profile)
  object_strata <- mfrmr_gtds3c_object_strata(profile, strata, objects)
  assignments <- mfrmr_gtds3c_assignment_rows(
    scenario_id, profile, object_strata
  )
  assignments <- mfrmr_gtds3c_eventize(
    scenario_id, profile, assignments
  )
  assignments <- mfrmr_gtds3c_apply_missingness(
    profile, assignments, scenario$ScenarioOrdinal[[1L]]
  )
  condition_audit <- mfrmr_gtds3c_pair_audit(
    assignments, strata, "ConditionId", "condition_identity"
  )
  event_audit <- mfrmr_gtds3c_pair_audit(
    assignments, strata, "EventId", "observation_event_identity"
  )
  object_counts <- table(factor(
    object_strata$Stratum, levels = strata$Stratum
  ))
  expected_fractions <- mfrmr_gtds3c_balance_fractions(
    profile[["balance"]], nrow(strata)
  )
  expected_counts <- pmax(
    2L, as.integer(floor(nrow(objects) * expected_fractions + 1e-12))
  )
  expected_counts[[1L]] <- nrow(objects)
  cell <- paste(assignments$Stratum, assignments$ObjectId, sep = "\036")
  retained_by_cell <- tapply(assignments$ResponseScheduled, cell, sum)
  balance_ready <- identical(as.integer(object_counts), expected_counts)
  condition_ready <- mfrmr_gtds3c_condition_semantics(
    profile, condition_audit
  )
  event_ready <- mfrmr_gtds3c_event_semantics(profile, event_audit)
  crossing_ready <- mfrmr_gtds3c_crossing_semantics(profile, assignments)
  missingness_ready <- all(retained_by_cell > 0L)
  compiled_ready <- all(c(
    balance_ready, condition_ready, event_ready, crossing_ready,
    missingness_ready
  ))
  profile_frame <- as.data.frame(
    as.list(profile), stringsAsFactors = FALSE, check.names = FALSE
  )
  summary <- list(
    ScenarioId = scenario_id,
    ScenarioHash = scenario$ScenarioHash[[1L]],
    ProfileSignature = scenario$ProfileSignature[[1L]],
    StratumCount = nrow(strata),
    ObjectCount = nrow(objects),
    RatingsPerObjectStratum =
      mfrmr_gtds3c_positive_level(profile, "rater_count"),
    RepeatCount = mfrmr_gtds3c_positive_level(profile, "repeat_count"),
    PlannedRowCount = nrow(assignments),
    ScheduledObservationRowCount = sum(assignments$ResponseScheduled),
    OmittedRowCount = sum(!assignments$ResponseScheduled),
    ConditionIdentityCount = length(unique(assignments$ConditionId)),
    EventIdentityCount = length(unique(assignments$EventId)),
    ConditionSharingQualified = condition_ready,
    ObservationEventQualified = event_ready,
    CrossingQualified = crossing_ready,
    BalanceQualified = balance_ready,
    MissingnessMaskQualified = missingness_ready,
    TypedDesignCompilerQualified = compiled_ready,
    StochasticMissingnessGenerationQualified = FALSE,
    CovarianceGeneratorQualified = FALSE,
    ResponseDistributionGeneratorQualified = FALSE,
    GeneratorSemanticsQualified = FALSE,
    RngStreamOpened = FALSE,
    ResponseGenerated = FALSE,
    BackendCallMade = FALSE,
    FitExecuted = FALSE,
    StratumRegistryHash = mfrmr_gtds3c_hash(strata),
    ObjectRegistryHash = mfrmr_gtds3c_hash(objects),
    ObjectStratumRegistryHash = mfrmr_gtds3c_hash(object_strata),
    AssignmentRegistryHash = mfrmr_gtds3c_hash(assignments),
    ConditionAuditHash = mfrmr_gtds3c_hash(condition_audit),
    EventAuditHash = mfrmr_gtds3c_hash(event_audit)
  )
  payload <- list(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    ScenarioId = scenario_id,
    Profile = profile_frame,
    StratumRegistry = strata,
    ObjectRegistry = objects,
    ObjectStratumRegistry = object_strata,
    AssignmentRegistry = assignments,
    ConditionPairAudit = condition_audit,
    EventPairAudit = event_audit,
    Summary = summary
  )
  structure(c(payload, list(
    CompilationHash = mfrmr_gtds3c_hash(payload)
  )), class = c("mfrmr_gtds3c_compilation", "list"))
}

mfrmr_gtds3c_compilation_fields <- function() {
  c(
    "ContractId", "ContractHash", "ScenarioId", "Profile",
    "StratumRegistry", "ObjectRegistry", "ObjectStratumRegistry",
    "AssignmentRegistry", "ConditionPairAudit", "EventPairAudit", "Summary"
  )
}

mfrmr_gtds3c_assert_compilation <- function(
    compilation, contract = mfrmr_gtds3c_contract(),
    coverage = mfrmr_gtds3_manifest(), validate = TRUE, replay = TRUE) {
  fields <- mfrmr_gtds3c_compilation_fields()
  if (!inherits(compilation, "mfrmr_gtds3c_compilation") ||
      !identical(names(compilation), c(fields, "CompilationHash"))) {
    stop("A typed D-SIM-3 semantic design compilation is required.",
         call. = FALSE)
  }
  if (isTRUE(validate)) {
    mfrmr_gtds3c_validate_contract(contract)
    mfrmr_gtds3_assert_manifest(coverage)
  }
  scenario <- coverage$ScenarioRegistry[
    coverage$ScenarioRegistry$ScenarioId == compilation$ScenarioId,
    , drop = FALSE
  ]
  canonical_match <- !isTRUE(replay) || identical(
    compilation,
    mfrmr_gtds3c_compile_profile(
      compilation$ScenarioId, contract, coverage, validate = FALSE
    )
  )
  assignments <- compilation$AssignmentRegistry
  summary <- compilation$Summary
  cell <- paste(assignments$Stratum, assignments$ObjectId, sep = "\036")
  valid <- canonical_match && nrow(scenario) == 1L &&
    identical(compilation$ContractId, contract$ContractId) &&
    identical(compilation$ContractHash, contract$ContractHash) &&
    identical(
      compilation$CompilationHash,
      mfrmr_gtds3c_hash(compilation[fields])
    ) && identical(names(compilation$Profile), coverage$Contract$DatasetAxisIds) &&
    identical(summary$ScenarioHash, scenario$ScenarioHash[[1L]]) &&
    identical(summary$ProfileSignature, scenario$ProfileSignature[[1L]]) &&
    identical(nrow(assignments), summary$PlannedRowCount) &&
    identical(sum(assignments$ResponseScheduled),
              summary$ScheduledObservationRowCount) &&
    identical(sum(!assignments$ResponseScheduled), summary$OmittedRowCount) &&
    !anyDuplicated(assignments$RowId) &&
    all(!is.na(assignments$ConditionId)) &&
    all(nzchar(assignments$ConditionId)) &&
    all(!is.na(assignments$EventId)) && all(nzchar(assignments$EventId)) &&
    all(tapply(assignments$ResponseScheduled, cell, sum) > 0L) &&
    isTRUE(summary$ConditionSharingQualified) &&
    isTRUE(summary$ObservationEventQualified) &&
    isTRUE(summary$CrossingQualified) && isTRUE(summary$BalanceQualified) &&
    isTRUE(summary$MissingnessMaskQualified) &&
    isTRUE(summary$TypedDesignCompilerQualified) &&
    !isTRUE(summary$StochasticMissingnessGenerationQualified) &&
    !isTRUE(summary$CovarianceGeneratorQualified) &&
    !isTRUE(summary$ResponseDistributionGeneratorQualified) &&
    !isTRUE(summary$GeneratorSemanticsQualified) &&
    !isTRUE(summary$RngStreamOpened) && !isTRUE(summary$ResponseGenerated) &&
    !isTRUE(summary$BackendCallMade) && !isTRUE(summary$FitExecuted) &&
    identical(summary$StratumRegistryHash,
              mfrmr_gtds3c_hash(compilation$StratumRegistry)) &&
    identical(summary$ObjectRegistryHash,
              mfrmr_gtds3c_hash(compilation$ObjectRegistry)) &&
    identical(summary$ObjectStratumRegistryHash,
              mfrmr_gtds3c_hash(compilation$ObjectStratumRegistry)) &&
    identical(summary$AssignmentRegistryHash,
              mfrmr_gtds3c_hash(assignments)) &&
    identical(summary$ConditionAuditHash,
              mfrmr_gtds3c_hash(compilation$ConditionPairAudit)) &&
    identical(summary$EventAuditHash,
              mfrmr_gtds3c_hash(compilation$EventPairAudit))
  if (!valid) {
    stop("The D-SIM-3 semantic design compilation was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3c_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds3c_require_primitives", "mfrmr_gtds3c_hash",
    "mfrmr_gtds3c_identity", "mfrmr_gtds3c_semantic_rules",
    "mfrmr_gtds3c_contract", "mfrmr_gtds3c_validate_contract",
    "mfrmr_gtds3c_profile", "mfrmr_gtds3c_positive_level",
    "mfrmr_gtds3c_strata", "mfrmr_gtds3c_objects",
    "mfrmr_gtds3c_balance_fractions", "mfrmr_gtds3c_object_strata",
    "mfrmr_gtds3c_assignment_rows", "mfrmr_gtds3c_eventize",
    "mfrmr_gtds3c_mcar_mask", "mfrmr_gtds3c_apply_missingness",
    "mfrmr_gtds3c_pair_audit", "mfrmr_gtds3c_condition_semantics",
    "mfrmr_gtds3c_event_semantics", "mfrmr_gtds3c_crossing_semantics",
    "mfrmr_gtds3c_compile_profile", "mfrmr_gtds3c_compilation_fields",
    "mfrmr_gtds3c_assert_compilation",
    "mfrmr_gtds3c_implementation_identity", "mfrmr_gtds3c_manifest_fields",
    "mfrmr_gtds3c_manifest", "mfrmr_gtds3c_assert_manifest"
  )
  target <- environment(mfrmr_gtds3c_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions), FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds3c_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)), stringsAsFactors = FALSE
  )
}

mfrmr_gtds3c_manifest_fields <- function() {
  c(
    "Contract", "ParentQualificationManifestHash",
    "ProfileCompilationRegistry", "ImplementationIdentity", "Summary"
  )
}

mfrmr_gtds3c_manifest <- function(
    contract = mfrmr_gtds3c_contract(),
    coverage = mfrmr_gtds3_manifest()) {
  mfrmr_gtds3c_validate_contract(contract)
  mfrmr_gtds3_assert_manifest(coverage)
  rows <- lapply(coverage$ScenarioRegistry$ScenarioId, function(scenario_id) {
    compilation <- mfrmr_gtds3c_compile_profile(
      scenario_id, contract, coverage, validate = FALSE
    )
    mfrmr_gtds3c_assert_compilation(
      compilation, contract, coverage, validate = FALSE, replay = FALSE
    )
    summary <- compilation$Summary
    data.frame(
      CompilationOrdinal = match(
        scenario_id, coverage$ScenarioRegistry$ScenarioId
      ),
      ScenarioId = scenario_id,
      ScenarioHash = summary$ScenarioHash,
      ProfileSignature = summary$ProfileSignature,
      StratumCount = summary$StratumCount,
      ObjectCount = summary$ObjectCount,
      RatingsPerObjectStratum = summary$RatingsPerObjectStratum,
      RepeatCount = summary$RepeatCount,
      PlannedRowCount = summary$PlannedRowCount,
      ScheduledObservationRowCount = summary$ScheduledObservationRowCount,
      OmittedRowCount = summary$OmittedRowCount,
      ConditionIdentityCount = summary$ConditionIdentityCount,
      EventIdentityCount = summary$EventIdentityCount,
      ConditionSharingQualified = summary$ConditionSharingQualified,
      ObservationEventQualified = summary$ObservationEventQualified,
      CrossingQualified = summary$CrossingQualified,
      BalanceQualified = summary$BalanceQualified,
      MissingnessMaskQualified = summary$MissingnessMaskQualified,
      TypedDesignCompilerQualified = summary$TypedDesignCompilerQualified,
      StochasticMissingnessGenerationQualified = FALSE,
      CovarianceGeneratorQualified = FALSE,
      ResponseDistributionGeneratorQualified = FALSE,
      GeneratorSemanticsQualified = FALSE,
      RngStreamOpened = FALSE, ResponseGenerated = FALSE,
      BackendCallMade = FALSE, FitExecuted = FALSE,
      CompilationHash = compilation$CompilationHash,
      stringsAsFactors = FALSE
    )
  })
  registry <- do.call(rbind, rows)
  row.names(registry) <- NULL
  implementation <- mfrmr_gtds3c_implementation_identity()
  summary <- list(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    ParentQualificationManifestHash =
      contract$ParentQualificationManifestHash,
    ProfileCompilationCount = nrow(registry),
    QualifiedTypedDesignProfileCount =
      sum(registry$TypedDesignCompilerQualified),
    CompiledAxisCount = length(contract$CompiledAxisIds),
    DeferredGeneratorAxisCount = length(contract$DeferredGeneratorAxisIds),
    PlannedStructuralRowCount = sum(registry$PlannedRowCount),
    ScheduledObservationRowCount =
      sum(registry$ScheduledObservationRowCount),
    OmittedObservationRowCount = sum(registry$OmittedRowCount),
    ScenarioSpecificBranchCount = contract$ScenarioSpecificBranchCount,
    SharedCompilerQualified = all(registry$TypedDesignCompilerQualified),
    StochasticMissingnessGenerationQualified = FALSE,
    GeneratorSemanticsQualifiedProfileCount = 0L,
    CovarianceGeneratorQualified = FALSE,
    ResponseDistributionGeneratorQualified = FALSE,
    RouteAdapterQualified = FALSE,
    TerminalReceiptAdapterQualified = FALSE,
    ResourceControllerQualified = FALSE,
    RngStreamOpened = FALSE, ResponseGenerated = FALSE,
    BackendCallMade = FALSE, FitExecuted = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE,
    FeatureMaturity = "specified",
    NextAction = paste(
      "implement and deterministically qualify the shared covariance-regime",
      "and response-distribution binding over the 21 compiled profile",
      "identities without opening 855"
    )
  )
  payload <- list(
    Contract = contract,
    ParentQualificationManifestHash =
      contract$ParentQualificationManifestHash,
    ProfileCompilationRegistry = registry,
    ImplementationIdentity = implementation,
    Summary = summary
  )
  structure(c(payload, list(
    ManifestHash = mfrmr_gtds3c_hash(payload)
  )), class = c("mfrmr_gtds3c_manifest", "list"))
}

mfrmr_gtds3c_assert_manifest <- function(manifest) {
  fields <- mfrmr_gtds3c_manifest_fields()
  if (!inherits(manifest, "mfrmr_gtds3c_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed D-SIM-3 semantic design-compiler manifest is required.",
         call. = FALSE)
  }
  mfrmr_gtds3c_validate_contract(manifest$Contract)
  registry <- manifest$ProfileCompilationRegistry
  valid <- identical(
    manifest$ManifestHash, mfrmr_gtds3c_hash(manifest[fields])
  ) && identical(
    manifest$ImplementationIdentity, mfrmr_gtds3c_implementation_identity()
  ) && identical(
    manifest$ParentQualificationManifestHash,
    manifest$Contract$ParentQualificationManifestHash
  ) && identical(nrow(registry), 21L) &&
    identical(registry$ScenarioId, sprintf("D3-S%03d", 1:21)) &&
    !anyDuplicated(registry$CompilationHash) &&
    all(registry$ConditionSharingQualified) &&
    all(registry$ObservationEventQualified) &&
    all(registry$CrossingQualified) && all(registry$BalanceQualified) &&
    all(registry$MissingnessMaskQualified) &&
    all(registry$TypedDesignCompilerQualified) &&
    all(!registry$StochasticMissingnessGenerationQualified) &&
    all(!registry$CovarianceGeneratorQualified) &&
    all(!registry$ResponseDistributionGeneratorQualified) &&
    all(!registry$GeneratorSemanticsQualified) &&
    all(!registry$RngStreamOpened) && all(!registry$ResponseGenerated) &&
    all(!registry$BackendCallMade) && all(!registry$FitExecuted) &&
    identical(manifest$Summary$ProfileCompilationCount, 21L) &&
    identical(manifest$Summary$QualifiedTypedDesignProfileCount, 21L) &&
    identical(manifest$Summary$CompiledAxisCount, 9L) &&
    identical(manifest$Summary$DeferredGeneratorAxisCount, 3L) &&
    identical(manifest$Summary$ScenarioSpecificBranchCount, 0L) &&
    isTRUE(manifest$Summary$SharedCompilerQualified) &&
    identical(
      manifest$Summary$GeneratorSemanticsQualifiedProfileCount, 0L
    ) && !isTRUE(manifest$Summary$CovarianceGeneratorQualified) &&
    !isTRUE(manifest$Summary$ResponseDistributionGeneratorQualified) &&
    !isTRUE(manifest$Summary$RouteAdapterQualified) &&
    !isTRUE(manifest$Summary$TerminalReceiptAdapterQualified) &&
    !isTRUE(manifest$Summary$ResourceControllerQualified) &&
    !isTRUE(manifest$Summary$RngStreamOpened) &&
    !isTRUE(manifest$Summary$ResponseGenerated) &&
    !isTRUE(manifest$Summary$BackendCallMade) &&
    !isTRUE(manifest$Summary$FitExecuted) &&
    !isTRUE(manifest$Summary$ExploratoryExecutionAllowed) &&
    !isTRUE(manifest$Summary$SimulationValidationReady) &&
    !isTRUE(manifest$Summary$PublicSupportReady) &&
    identical(manifest$Summary$FeatureMaturity, "specified")
  if (!valid) {
    stop("The D-SIM-3 semantic design-compiler manifest was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}
