# Internal D-SIM-1 v4 deterministic qualification.
#
# Source the design-algebra hash primitive, Draft.85a0 algebra, Draft.85b0
# incidence audit, and the D-SIM-0 v4 capability contract first.  This suite
# uses deterministic structural fixtures only: it generates no stochastic
# response, fits no model, opens no planned seed, and promotes no public claim.

mfrmr_gtds1_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtv_matrix_audit", "mfrmr_gtv_spec",
    "mfrmr_gtv_composite", "mfrmr_gtv_fixture",
    "mfrmr_gtvi_audit", "mfrmr_gtds_v4_contract",
    "mfrmr_gtds_v4_validate_contract", "mfrmr_gtds_v4_hash"
  )
  function_environment <- environment(mfrmr_gtds1_require_primitives)
  available <- vapply(required, function(id) {
    exists(id, envir = function_environment, mode = "function",
           inherits = TRUE)
  }, logical(1L))
  if (!all(available)) {
    stop(
      "Source the algebra, incidence, and D-SIM-0 v4 contracts before D-SIM-1.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds1_identity <- function() {
  list(
    QualificationId = "MFRMR-GTHEORY-MV-DSIM1-DETERMINISTIC-V1",
    QualificationVersion = "1.0.0",
    QualificationDate = "2026-08-30",
    ParentContractId = "MFRMR-GTHEORY-MV-DSIM0-CAPABILITY-V4",
    ParentContractHash =
      "9b68d194e13625ec73992f314a9494e29c36f77838e0da19a15020f2af74a214"
  )
}

mfrmr_gtds1_design_registry <- function() {
  data.frame(
    DesignOrdinal = 1:5,
    DesignId = c(
      "U1-CLOSURE", "S2-DISJOINT-DISTINCT", "S2-SHARED-LINKED",
      "S3-PARTIAL-MIXED", "S2-DISCONNECTED-NEGATIVE"
    ),
    StratumCount = c(1L, 2L, 2L, 3L, 2L),
    DesignRole = c(
      "univariate_closure", "supported_anchor", "linked_residual_target",
      "explicit_mask_target", "structural_negative_control"
    ),
    ConditionSharing = c(
      "not_applicable", "disjoint_by_stratum",
      "identical_shared_across_strata", "partial_explicit_incidence",
      "disjoint_by_stratum"
    ),
    ObservationEventRelationship = c(
      "distinct_event_per_stratum_score",
      "distinct_event_per_stratum_score",
      "one_event_yields_multiple_stratum_scores",
      "mixed_explicit_event_map",
      "distinct_event_per_stratum_score"
    ),
    Crossing = c(
      "fully_crossed", "fully_crossed", "fully_crossed",
      "partially_crossed", "disconnected"
    ),
    ObjectIncidence = c(
      "single_stratum", "complete_link", "complete_link", "complete_link",
      "disconnected_by_stratum"
    ),
    RandomBlockStructure = c(
      "univariate", "supported_standard_blocks", "supported_standard_blocks",
      "explicit_mask", "not_identified"
    ),
    ResidualBlock = c(
      "scalar", "diagonal_distinct_events",
      "unstructured_linked_event_scores", "explicit_event_mask",
      "not_identified"
    ),
    ExpectedQualification = c(
      "univariate_formula_only", "standard_routes_conditionally_eligible",
      "glmmTMB_conditional_lme4_ineligible",
      "custom_contract_required", "reject_structural_nonidentification"
    ),
    PackageSupportReady = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds1_validate_design_registry <- function(
    designs = mfrmr_gtds1_design_registry()) {
  expected_names <- c(
    "DesignOrdinal", "DesignId", "StratumCount", "DesignRole",
    "ConditionSharing", "ObservationEventRelationship", "Crossing",
    "ObjectIncidence", "RandomBlockStructure", "ResidualBlock",
    "ExpectedQualification", "PackageSupportReady"
  )
  valid <- is.data.frame(designs) &&
    identical(names(designs), expected_names) &&
    identical(designs$DesignOrdinal, 1:5) &&
    identical(designs$DesignId, c(
      "U1-CLOSURE", "S2-DISJOINT-DISTINCT", "S2-SHARED-LINKED",
      "S3-PARTIAL-MIXED", "S2-DISCONNECTED-NEGATIVE"
    )) &&
    identical(designs$StratumCount, c(1L, 2L, 2L, 3L, 2L)) &&
    !anyDuplicated(designs$DesignId) &&
    all(nzchar(designs$DesignRole)) &&
    all(nzchar(designs$ConditionSharing)) &&
    all(nzchar(designs$ObservationEventRelationship)) &&
    all(nzchar(designs$Crossing)) &&
    all(nzchar(designs$ObjectIncidence)) &&
    all(nzchar(designs$RandomBlockStructure)) &&
    all(nzchar(designs$ResidualBlock)) &&
    all(nzchar(designs$ExpectedQualification)) &&
    all(!designs$PackageSupportReady)
  if (!valid) {
    stop("The D-SIM-1 canonical design registry is invalid.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds1_route_registry <- function() {
  data.frame(
    RouteOrdinal = 1:4,
    RouteId = c(
      "public_univariate_formula", "mv_reml_glmmtmb",
      "mv_reml_lme4", "custom_covariance_contract"
    ),
    RouteRole = c(
      "closure_or_nonpooling_comparator", "conditional_general_candidate",
      "design_restricted_sensitivity", "explicit_mask_extension"
    ),
    EstimatedLinkedLevelOneResidual = c(FALSE, TRUE, FALSE, TRUE),
    SupportsExplicitCovarianceMask = c(FALSE, FALSE, FALSE, TRUE),
    IndependentEstimandVote = FALSE,
    ExecutionAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds1_expected_route_registry <- function() {
  design_id <- rep(mfrmr_gtds1_design_registry()$DesignId, each = 4L)
  route_id <- rep(mfrmr_gtds1_route_registry()$RouteId, times = 5L)
  status <- c(
    "eligible_closure_oracle", "not_applicable_univariate",
    "not_applicable_univariate", "not_required",
    "comparator_only", "conditional_candidate", "conditional_sensitivity",
    "not_required",
    "comparator_only", "conditional_candidate",
    "ineligible_correlated_level1_residual", "not_required",
    "comparator_only", "ineligible_custom_mask", "ineligible_custom_mask",
    "required",
    rep("structural_negative_control_rejected", 4L)
  )
  data.frame(
    DesignId = design_id,
    RouteId = route_id,
    ExpectedStatus = status,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds1_qualify_routes <- function(
    designs = mfrmr_gtds1_design_registry(),
    routes = mfrmr_gtds1_route_registry()) {
  mfrmr_gtds1_validate_design_registry(designs)
  if (!is.data.frame(routes) ||
      !identical(routes$RouteId, mfrmr_gtds1_route_registry()$RouteId) ||
      any(routes$ExecutionAllowed)) {
    stop("The D-SIM-1 route registry is invalid.", call. = FALSE)
  }
  rows <- vector("list", nrow(designs) * nrow(routes))
  cursor <- 0L
  for (design_index in seq_len(nrow(designs))) {
    design <- designs[design_index, , drop = FALSE]
    for (route_index in seq_len(nrow(routes))) {
      route <- routes[route_index, , drop = FALSE]
      cursor <- cursor + 1L
      status <- reason <- NA_character_
      if (design$DesignRole == "structural_negative_control") {
        status <- "structural_negative_control_rejected"
        reason <- "object incidence is disconnected and covariance is unidentified"
      } else if (route$RouteId == "public_univariate_formula") {
        status <- if (design$StratumCount == 1L) {
          "eligible_closure_oracle"
        } else {
          "comparator_only"
        }
        reason <- if (design$StratumCount == 1L) {
          "one-stratum reduction target"
        } else {
          "separate coefficients do not estimate cross-stratum covariance"
        }
      } else if (design$StratumCount == 1L) {
        status <- if (route$RouteId == "custom_covariance_contract") {
          "not_required"
        } else {
          "not_applicable_univariate"
        }
        reason <- "multivariate route is unnecessary for one stratum"
      } else if (route$RouteId == "custom_covariance_contract") {
        status <- if (design$RandomBlockStructure == "explicit_mask" ||
                         design$ResidualBlock == "explicit_event_mask") {
          "required"
        } else {
          "not_required"
        }
        reason <- if (status == "required") {
          "explicit incidence or event mask is outside standard route grammar"
        } else {
          "standard route grammar is sufficient for this deterministic design"
        }
      } else if (route$RouteId == "mv_reml_glmmtmb") {
        status <- if (design$RandomBlockStructure == "explicit_mask") {
          "ineligible_custom_mask"
        } else {
          "conditional_candidate"
        }
        reason <- if (status == "conditional_candidate") {
          "standard random blocks and diagonal or linked event residual representation"
        } else {
          "explicit covariance mask requires a separate contract"
        }
      } else if (route$RouteId == "mv_reml_lme4") {
        status <- if (design$RandomBlockStructure == "explicit_mask") {
          "ineligible_custom_mask"
        } else if (design$ObservationEventRelationship ==
                   "one_event_yields_multiple_stratum_scores") {
          "ineligible_correlated_level1_residual"
        } else {
          "conditional_sensitivity"
        }
        reason <- switch(
          status,
          conditional_sensitivity =
            "supported random blocks and diagonal distinct-event residual",
          ineligible_correlated_level1_residual =
            "linked scores require estimated cross-stratum level-one residual covariance",
          ineligible_custom_mask =
            "explicit covariance mask requires a separate contract"
        )
      }
      rows[[cursor]] <- data.frame(
        DesignId = design$DesignId,
        RouteId = route$RouteId,
        QualificationStatus = status,
        QualificationReason = reason,
        ExecutionAllowed = FALSE,
        PublicSupportReady = FALSE,
        stringsAsFactors = FALSE
      )
    }
  }
  do.call(rbind, rows)
}

mfrmr_gtds1_scalar <- function(value, stratum = "S") {
  matrix(value, 1L, 1L, dimnames = list(stratum, stratum))
}

mfrmr_gtds1_univariate_closure_oracle <- function() {
  stratum <- "S"
  map <- data.frame(
    ComponentId = c("Person", "Item", "Residual"),
    UniverseRole = c("object", "absolute_only", "relative_error"),
    stringsAsFactors = FALSE
  )
  covariance <- list(
    Person = mfrmr_gtds1_scalar(1.2),
    Item = mfrmr_gtds1_scalar(0.3),
    Residual = mfrmr_gtds1_scalar(0.6)
  )
  item_allocation <- data.frame(
    Stratum = stratum, ConditionId = c("I1", "I2"), Weight = 0.5,
    stringsAsFactors = FALSE
  )
  residual_allocation <- data.frame(
    Stratum = stratum, ConditionId = paste0("O", 1:4), Weight = 0.25,
    stringsAsFactors = FALSE
  )
  spec <- mfrmr_gtv_spec(
    stratum, map, covariance,
    list(
      Person = mfrmr_gtv_unscaled_operator(stratum, "Person"),
      Item = mfrmr_gtv_overlap_operator(item_allocation, stratum, "Item"),
      Residual = mfrmr_gtv_overlap_operator(
        residual_allocation, stratum, "Residual"
      )
    )
  )
  result <- mfrmr_gtv_composite(spec, c(S = 1))
  independent <- c(
    UniverseVariance = 1.2,
    RelativeErrorVariance = 0.6 / 4,
    AbsoluteErrorVariance = 0.6 / 4 + 0.3 / 2,
    G = 1.2 / (1.2 + 0.6 / 4),
    Phi = 1.2 / (1.2 + 0.6 / 4 + 0.3 / 2)
  )
  actual <- c(
    UniverseVariance = result$UniverseVariance,
    RelativeErrorVariance = result$RelativeErrorVariance,
    AbsoluteErrorVariance = result$AbsoluteErrorVariance,
    G = result$G,
    Phi = result$Phi
  )
  checks <- data.frame(
    CheckId = names(independent),
    Expected = as.numeric(independent),
    Actual = as.numeric(actual),
    AbsoluteError = abs(as.numeric(actual - independent)),
    Tolerance = 1e-10,
    stringsAsFactors = FALSE
  )
  checks$Pass <- checks$AbsoluteError <= checks$Tolerance
  list(Specification = spec, Result = result, Checks = checks)
}

mfrmr_gtds1_label_invariance_oracle <- function() {
  original <- mfrmr_gtv_fixture("partial")
  original_result <- mfrmr_gtv_composite(
    original, c(A = 0.6, B = 0.4)
  )
  order <- rev(original$Strata)
  permuted_covariances <- lapply(
    original$ComponentCovariances,
    function(value) value[order, order, drop = FALSE]
  )
  permuted_operators <- lapply(
    original$AllocationOperators,
    function(value) value[order, order, drop = FALSE]
  )
  permuted <- mfrmr_gtv_spec(
    order, original$ComponentMap, permuted_covariances, permuted_operators
  )
  permuted_result <- mfrmr_gtv_composite(
    permuted, c(B = 0.4, A = 0.6)
  )
  checks <- data.frame(
    CheckId = c("UniverseVariance", "RelativeErrorVariance",
                "AbsoluteErrorVariance", "G", "Phi"),
    Original = c(
      original_result$UniverseVariance,
      original_result$RelativeErrorVariance,
      original_result$AbsoluteErrorVariance,
      original_result$G, original_result$Phi
    ),
    Relabeled = c(
      permuted_result$UniverseVariance,
      permuted_result$RelativeErrorVariance,
      permuted_result$AbsoluteErrorVariance,
      permuted_result$G, permuted_result$Phi
    ),
    Tolerance = 1e-10,
    stringsAsFactors = FALSE
  )
  checks$AbsoluteError <- abs(checks$Original - checks$Relabeled)
  checks$Pass <- checks$AbsoluteError <= checks$Tolerance
  checks
}

mfrmr_gtds1_psd_oracle <- function() {
  strata <- c("A", "B")
  valid <- matrix(
    c(1, 1, 1, 1), 2L, 2L, dimnames = list(strata, strata)
  )
  invalid <- matrix(
    c(1, 1.2, 1.2, 1), 2L, 2L, dimnames = list(strata, strata)
  )
  valid_audit <- mfrmr_gtv_matrix_audit(
    valid, strata, "near-singular-valid", tolerance = 1e-10
  )
  invalid_rejected <- tryCatch({
    mfrmr_gtv_matrix_audit(
      invalid, strata, "indefinite-negative-control", tolerance = 1e-10
    )
    FALSE
  }, error = function(error) {
    grepl("not positive semidefinite", conditionMessage(error), fixed = TRUE)
  })
  data.frame(
    CheckId = c("rank_deficient_psd_accepted", "indefinite_rejected"),
    Pass = c(
      isTRUE(valid_audit$Audit$PositiveSemidefinite) &&
        isTRUE(valid_audit$Audit$RankDeficient),
      invalid_rejected
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds1_fixture_rows <- function(
    objects, strata, raters, items = c("I1", "I2")) {
  rows <- list()
  cursor <- 0L
  for (stratum in strata) {
    values <- expand.grid(
      Object = objects[[stratum]], Rater = raters[[stratum]], Item = items,
      stringsAsFactors = FALSE
    )
    values$Stratum <- stratum
    values$Score <- seq_len(nrow(values)) / 100
    cursor <- cursor + 1L
    rows[[cursor]] <- values[c("Object", "Stratum", "Rater", "Item", "Score")]
  }
  do.call(rbind, rows)
}

mfrmr_gtds1_incidence_fixture <- function(design_id) {
  design_id <- as.character(design_id)
  if (length(design_id) != 1L || !design_id %in%
      mfrmr_gtds1_design_registry()$DesignId[-1L]) {
    stop("Unknown multistratum D-SIM-1 incidence fixture.", call. = FALSE)
  }
  if (design_id == "S3-PARTIAL-MIXED") {
    strata <- c("A", "B", "C")
    objects <- stats::setNames(rep(list(paste0("P", 1:4)), 3L), strata)
    raters <- list(
      A = c("R1", "R2", "R3"),
      B = c("R2", "R3", "R4"),
      C = c("R3", "R4", "R5")
    )
    scope <- c(Rater = "global", Item = "global")
    minimum_shared_conditions <- 1L
  } else if (design_id == "S2-DISCONNECTED-NEGATIVE") {
    strata <- c("A", "B")
    objects <- list(A = c("P1", "P2"), B = c("P3", "P4"))
    raters <- list(A = c("R1", "R2"), B = c("R1", "R2"))
    scope <- c(Rater = "stratum_local", Item = "stratum_local")
    minimum_shared_conditions <- 2L
  } else {
    strata <- c("A", "B")
    objects <- list(A = paste0("P", 1:4), B = paste0("P", 1:4))
    raters <- list(A = c("R1", "R2"), B = c("R1", "R2"))
    if (design_id == "S2-DISJOINT-DISTINCT") {
      scope <- c(Rater = "stratum_local", Item = "stratum_local")
    } else {
      scope <- c(Rater = "global", Item = "global")
    }
    minimum_shared_conditions <- 2L
  }
  data <- mfrmr_gtds1_fixture_rows(objects, strata, raters)
  list(
    Data = data, Strata = strata, ConditionScope = scope,
    MinimumSharedConditions = minimum_shared_conditions
  )
}

mfrmr_gtds1_incidence_oracle <- function() {
  ids <- mfrmr_gtds1_design_registry()$DesignId[-1L]
  expected_ready <- c(TRUE, TRUE, TRUE, FALSE)
  rows <- lapply(seq_along(ids), function(index) {
    fixture <- mfrmr_gtds1_incidence_fixture(ids[[index]])
    audit <- mfrmr_gtvi_audit(
      fixture$Data, "Object", "Stratum", "Score", c("Rater", "Item"),
      fixture$ConditionScope, fixture$Strata, missingness = "complete",
      min_objects_per_stratum = 2L, min_shared_objects = 2L,
      min_shared_conditions = fixture$MinimumSharedConditions
    )
    data.frame(
      DesignId = ids[[index]],
      ExpectedIncidenceReady = expected_ready[[index]],
      ActualIncidenceReady = audit$IncidenceReady,
      SharingStates = paste(
        sort(unique(audit$ConditionPairAudit$SharingState), method = "radix"),
        collapse = ";"
      ),
      IssueCount = length(audit$Issues),
      AuditHash = audit$AuditHash,
      Pass = identical(audit$IncidenceReady, expected_ready[[index]]),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gtds1_observation_event_map <- function(design_id) {
  design_id <- as.character(design_id)
  if (design_id == "S2-DISJOINT-DISTINCT") {
    map <- expand.grid(
      Unit = 1:4, Stratum = c("A", "B"), stringsAsFactors = FALSE
    )
    map$EventId <- paste(map$Stratum, map$Unit, sep = "/")
  } else if (design_id == "S2-SHARED-LINKED") {
    map <- expand.grid(
      Unit = 1:4, Stratum = c("A", "B"), stringsAsFactors = FALSE
    )
    map$EventId <- paste0("E", map$Unit)
  } else if (design_id == "S3-PARTIAL-MIXED") {
    map <- expand.grid(
      Unit = 1:4, Stratum = c("A", "B", "C"), stringsAsFactors = FALSE
    )
    map$EventId <- ifelse(
      map$Unit <= 2L & map$Stratum %in% c("A", "B"),
      paste0("AB/E", map$Unit),
      paste(map$Stratum, map$Unit, sep = "/")
    )
  } else {
    stop("No canonical event map is registered for this design.",
         call. = FALSE)
  }
  map$ScoreChannel <- paste0("Score/", map$Stratum)
  map[c("EventId", "Stratum", "ScoreChannel")]
}

mfrmr_gtds1_classify_observation_events <- function(map) {
  required <- c("EventId", "Stratum", "ScoreChannel")
  if (!is.data.frame(map) || !identical(names(map), required) ||
      nrow(map) == 0L || anyNA(map) ||
      any(!nzchar(as.character(map$EventId))) ||
      any(!nzchar(as.character(map$Stratum))) ||
      any(!nzchar(as.character(map$ScoreChannel))) ||
      anyDuplicated(paste(map$EventId, map$Stratum, sep = "\r"))) {
    stop("The observation-event map is malformed.", call. = FALSE)
  }
  span <- vapply(split(map$Stratum, map$EventId), function(value) {
    length(unique(value))
  }, integer(1L))
  stratum_count <- length(unique(map$Stratum))
  if (all(span == 1L)) {
    "distinct_event_per_stratum_score"
  } else if (all(span == stratum_count)) {
    "one_event_yields_multiple_stratum_scores"
  } else {
    "mixed_explicit_event_map"
  }
}

mfrmr_gtds1_observation_event_oracle <- function() {
  ids <- c(
    "S2-DISJOINT-DISTINCT", "S2-SHARED-LINKED", "S3-PARTIAL-MIXED"
  )
  designs <- mfrmr_gtds1_design_registry()
  rows <- lapply(ids, function(id) {
    map <- mfrmr_gtds1_observation_event_map(id)
    expected <- designs$ObservationEventRelationship[designs$DesignId == id]
    actual <- mfrmr_gtds1_classify_observation_events(map)
    data.frame(
      DesignId = id, ExpectedRelationship = expected,
      ActualRelationship = actual, EventMapHash = mfrmr_gta_hash(map),
      Pass = identical(actual, expected), stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gtds1_route_oracle <- function() {
  actual <- mfrmr_gtds1_qualify_routes()
  expected <- mfrmr_gtds1_expected_route_registry()
  joined <- merge(
    expected, actual, by = c("DesignId", "RouteId"), sort = FALSE
  )
  key_order <- paste(expected$DesignId, expected$RouteId, sep = "\r")
  joined <- joined[match(
    key_order, paste(joined$DesignId, joined$RouteId, sep = "\r")
  ), , drop = FALSE]
  row.names(joined) <- NULL
  joined$Pass <- joined$ExpectedStatus == joined$QualificationStatus &
    !joined$ExecutionAllowed & !joined$PublicSupportReady
  joined
}

mfrmr_gtds1_run <- function(contract = mfrmr_gtds_v4_contract()) {
  mfrmr_gtds1_require_primitives()
  mfrmr_gtds_v4_validate_contract(contract)
  identity <- mfrmr_gtds1_identity()
  if (!identical(contract$ContractId, identity$ParentContractId) ||
      !identical(contract$ContractHash, identity$ParentContractHash)) {
    stop("D-SIM-1 is not bound to the expected D-SIM-0 v4 contract.",
         call. = FALSE)
  }
  mfrmr_gtds1_validate_design_registry()
  closure <- mfrmr_gtds1_univariate_closure_oracle()
  invariance <- mfrmr_gtds1_label_invariance_oracle()
  psd <- mfrmr_gtds1_psd_oracle()
  incidence <- mfrmr_gtds1_incidence_oracle()
  events <- mfrmr_gtds1_observation_event_oracle()
  routes <- mfrmr_gtds1_route_oracle()
  criteria <- data.frame(
    CriterionId = c(
      "deterministic_algebra", "univariate_closure", "label_invariance",
      "psd_validity", "incidence_identity", "observation_event_identity",
      "backend_eligibility"
    ),
    Pass = c(
      all(closure$Checks$Pass),
      all(closure$Checks$Pass[c(2L, 3L, 4L, 5L)]),
      all(invariance$Pass), all(psd$Pass), all(incidence$Pass),
      all(events$Pass), all(routes$Pass)
    ),
    EvidenceRows = c(
      nrow(closure$Checks), 4L, nrow(invariance), nrow(psd),
      nrow(incidence), nrow(events), nrow(routes)
    ),
    stringsAsFactors = FALSE
  )
  evidence <- list(
    UnivariateClosure = closure$Checks,
    LabelInvariance = invariance,
    Psd = psd,
    Incidence = incidence,
    ObservationEvents = events,
    RouteQualification = routes
  )
  qualification_hash <- mfrmr_gtds_v4_hash(list(
    Identity = identity,
    Designs = mfrmr_gtds1_design_registry(),
    Routes = mfrmr_gtds1_route_registry(),
    Criteria = criteria,
    Evidence = evidence
  ))
  satisfied <- all(criteria$Pass)
  summary <- data.frame(
    QualificationId = identity$QualificationId,
    ParentContractHash = identity$ParentContractHash,
    QualificationHash = qualification_hash,
    GateStatus = if (satisfied) {
      "dsim1_deterministic_oracles_complete_dsim2_allowed"
    } else {
      "dsim1_deterministic_oracles_failed"
    },
    CanonicalDesignCount = nrow(mfrmr_gtds1_design_registry()),
    CriterionCount = nrow(criteria),
    PassedCriterionCount = sum(criteria$Pass),
    UniqueEvidenceRowCount = sum(vapply(evidence, nrow, integer(1L))),
    CriterionEvidenceAssignmentCount = sum(criteria$EvidenceRows),
    Dsim1Satisfied = satisfied,
    Dsim2Allowed = satisfied,
    DeterministicFixtureConstructed = TRUE,
    StochasticResponseGenerated = FALSE,
    FitExecuted = FALSE,
    PlannedSeedAccessAllowed = FALSE,
    ExploratorySimulationAllowed = FALSE,
    ConfirmationSimulationAllowed = FALSE,
    PublicSupportReady = FALSE,
    NextAction = if (satisfied) {
      paste(
        "run D-SIM-2 with one nonreserved deterministic fixture through",
        "generator, fit, metric, and terminal-state plumbing without planned seeds"
      )
    } else {
      "repair failed deterministic criteria before any D-SIM-2 work"
    },
    stringsAsFactors = FALSE
  )
  result <- list(
    Summary = summary, Criteria = criteria,
    Designs = mfrmr_gtds1_design_registry(),
    Routes = mfrmr_gtds1_route_registry(), Evidence = evidence
  )
  class(result) <- c("mfrmr_gtds1_qualification", "list")
  result
}
