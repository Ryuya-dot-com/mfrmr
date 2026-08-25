# Draft.85c1 multivariate G-theory ADEMP planning prototype.
#
# Repository-internal only. This file seals a prospective design payload and
# produces non-executable candidate-column-allowlist previews. It generates
# no finite response, fits no model, reads no result, and cannot self-issue the
# external freeze anchor required for execution authorization.

mfrmr_gtvd_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtvc_neutral_design",
    "mfrmr_gtvc_assert_design", "mfrmr_gtvc_derivative_design",
    "mfrmr_gtvc_assert_derivative",
    "mfrmr_gtvc_coordinate_layout", "mfrmr_gtvc_matrix_audit",
    "mfrmr_gtvc_bridge_gtvb", "mfrmr_gtvc_assert_bridge",
    "mfrmr_gtvc_covariance_from_gtvb", "mfrmr_gtvc_candidate_stage_valid",
    "mfrmr_gtvc_candidate_receipt", "mfrmr_gtvc_join_reference",
    "mfrmr_gtvc_denominator_audit", "mfrmr_gtvb_backend_binding",
    "mfrmr_gtvb_spec", "mfrmr_gtvb_assert_fit_spec",
    "mfrmr_gtvb_finalize_fit", "mfrmr_gtvb_fit_lme4",
    "mfrmr_gtvb_fit_glmmtmb", "mfrmr_gtvb_assert_fit_integrity"
  )
  prototype_environment <- environment(mfrmr_gtvd_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = prototype_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.81, Draft.85b1, and Draft.85c0 before Draft.85c1: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtvd_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    setequal(names(attributes(object)), c("names", "class"))
}

mfrmr_gtvd_function_hash <- function(fun) {
  if (!is.function(fun)) {
    stop("A Draft.85c1 implementation function could not be resolved.",
         call. = FALSE)
  }
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtvd_plan_payload_fields <- function() {
  c(
    "Contract", "PlanId", "PlanVersion", "ADEMPEstimand",
    "StratumCatalog", "ComponentCatalog", "AimCatalog",
    "ExclusionRegistry", "AssignmentCatalog", "ScenarioRegistry",
    "StructuralDesignPreflight", "C0DerivativeReplayRegistry",
    "ReferenceCatalog",
    "ReferenceCoordinateRegistry", "ReferenceFactorRegistry",
    "ReferenceComponentAudit", "ReferenceBoundaryClassRegistry",
    "FixedMeanRegistry", "MethodRegistry", "PairRegistry", "PairStateAlgebra",
    "MetricRegistry", "MetricNormalizationPolicy",
    "MetricApplicabilityRegistry", "MetricAvailabilityTargetRegistry",
    "BoundaryClassificationRegistry",
    "FailureTaxonomy", "CandidateStateAlgebra", "ReceiptMappingRegistry",
    "StageCatalog",
    "DenominatorRules", "SeedPartitionPolicy",
    "MonteCarloPrecisionPolicy", "BoundaryMetricPolicy",
    "MechanicalToleranceRegistry", "RecoveryThresholdRegistry",
    "ExecutionPrerequisiteRegistry", "CoordinateLayouts",
    "GenerationManifest", "CandidateUnitManifest", "PairUnitManifest",
    "ReferenceJoinMap",
    "ExpectedCounts", "ImplementationIdentity", "ImplementationIdentityHash",
    "C0DerivativeReplayHash", "ReferenceRegistryHash",
    "ScenarioRegistryHash", "StructuralPreflightHash",
    "MethodRegistryHash", "PairRegistryHash", "MetricRegistryHash",
    "MetricApplicabilityRegistryHash",
    "MetricAvailabilityTargetRegistryHash",
    "PlanCoreHash", "GenerationManifestHash", "CandidateUnitManifestHash",
    "PairUnitManifestHash",
    "ReferenceJoinMapHash", "SeedPartitionContentHash"
  )
}

mfrmr_gtvd_plan_suffix_fields <- function() {
  c(
    "PlanHash", "PlanPayloadFields", "ScenarioCount",
    "ExecutableScenarioCount", "NegativeControlCount",
    "PlannedDatasetCount", "PlannedAtomicMethodRows",
    "PlannedPairedRows", "PlannedCoordinateRows", "PlanContentSealed",
    "ADEMPRegistryContentSealed", "MetricDefinitionsContentSealed",
    "SeedPartitionContentSealed", "AtomicManifestDenominatorPlanReady",
    "MetricDenominatorRoutingReady",
    "MonteCarloPrecisionPlanReady", "CandidateHandoffColumnAllowlistReady",
    "ReceiptTupleCatalogReady",
    "ExternalFreezeReceiptRequired",
    "PreOutcomeFreezeExternallyAnchored", "RecoveryDesignFrozen",
    "RecoveryThresholdFrozen", "TruthBlindExecutionBoundaryReady",
    "BackendQualificationReady", "PilotExecutionAuthorized",
    "ConfirmationExecutionAuthorized", "CandidateCompletionSealed",
    "TruthReleaseAuthorized", "DenominatorAccountingReady",
    "PilotEvaluationComplete", "DecisionRuleFrozen",
    "ConfirmationIsolationReady", "GeneratorImplementationReady",
    "RecoveryExecuted",
    "RecoveryEvidenceReady", "EstimatorRecoveryReady", "EstimationReady",
    "InferenceReady", "UncertaintyReady", "CoefficientEligible",
    "DecisionReady", "PublicSupportReady"
  )
}

mfrmr_gtvd_stratum_catalog <- function() {
  data.frame(
    CoordinateLayoutId = c("T2-GLOBAL-3C-R1", "T3-GLOBAL-3C-R1"),
    StratumCount = c(2L, 3L),
    OrderedStrata = c("A|B", "A|B|C"),
    RandomCovarianceCoordinateCount = c(9L, 18L),
    ResidualCoordinateCount = c(1L, 1L),
    DeclaredCoordinateCount = c(10L, 19L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_component_catalog <- function() {
  data.frame(
    ComponentOrdinal = 1:4,
    ComponentId = c("Object", "Rater", "Object:Rater", "Residual"),
    UniverseRole = c(
      "object", "absolute_only", "relative_error", "relative_error"
    ),
    Scope = c("global", "global", "global", "observation"),
    CovarianceStructure = c(
      "unstructured", "unstructured", "unstructured",
      "homoskedastic_independent_scalar"
    ),
    GeneratorSubstreamOrdinal = 1:4,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_aim_catalog <- function() {
  data.frame(
    AimOrdinal = 1:5,
    AimId = c(
      "coordinate_recovery", "total_k_recovery", "readiness_calibration",
      "paired_backend_recovery_loss", "paired_criterion_recovery_loss"
    ),
    Question = c(
      "Can every declared covariance coordinate be recovered without silent reordering?",
      "Does the fitted covariance reproduce the truth-point marginal K?",
      "Do regular, boundary, and structurally unidentified designs receive the declared point-gate state?",
      "How does normalized absolute recovery loss differ between lme4 and glmmTMB within criterion on the same dataset?",
      "How does normalized absolute recovery loss differ between ML and REML within backend on the same dataset?"
    ),
    EvidenceUnit = c(
      "dataset_method_coordinate", "dataset_method", "planned_method_row",
      "complete_dataset_pair", "complete_dataset_pair"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_exclusion_registry <- function() {
  data.frame(
    ExclusionOrdinal = 1:8,
    ExcludedClaim = c(
      "composite_G_or_Phi", "allocation_operator", "interval_or_coverage",
      "local_diagonal_component", "cross_stratum_residual_covariance",
      "missing_response_mechanism", "non_Gaussian_response",
      "public_multivariate_G_theory_support"
    ),
    Disposition = c(
      rep("separate_downstream_gate", 7L), "repository_internal_only"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_assignment_catalog <- function() {
  data.frame(
    AssignmentId = c(
      "A2-BAL", "A2-SPARSE", "A2-UNEQUAL", "A2-ABSENT",
      "A3-BAL", "A3-SPARSE", "A3-UNEQUAL", "A3-ABSENT",
      "A3-NOAC", "A2-NOREP"
    ),
    StratumCount = c(2L, 2L, 2L, 2L, 3L, 3L, 3L, 3L, 3L, 2L),
    ObjectCount = rep(30L, 10L),
    RaterCount = rep(6L, 10L),
    WithinCellReplicates = c(2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 1L),
    AssignmentRule = c(
      "all_objects_by_all_raters_in_all_strata",
      "two_adjacent_cyclic_raters_per_object_shared_across_strata",
      "rater_1_plus_one_cyclic_rater_2_to_6_shared_across_strata",
      "18_AB_plus_6_A_only_plus_6_B_only_all_raters",
      "all_objects_by_all_raters_in_all_strata",
      "two_adjacent_cyclic_raters_per_object_shared_across_strata",
      "rater_1_plus_one_cyclic_rater_2_to_6_shared_across_strata",
      "12_ABC_plus_6_AB_plus_6_AC_plus_6_BC_all_raters",
      "15_AB_plus_15_BC_no_AC_object_overlap_all_raters",
      "all_objects_by_all_raters_in_all_strata_no_replication"
    ),
    ExpectedRows = c(720L, 240L, 240L, 576L, 1080L, 360L, 360L,
                     864L, 720L, 360L),
    StructuralRowAbsence = c(
      FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, TRUE, FALSE
    ),
    MissingResponseMechanism = rep("none_structural_rows_not_generated", 10L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_scenario_registry <- function() {
  tokens <- c(
    "70d46169e23f01d876381369f344726e",
    "2480425a43ba9606b393391019e72be6",
    "686cd5cd7bc4e4b96cf218295552d3e0",
    "34bb4d39e95f6db1d7b38bdc6cdf6242",
    "ead8a46c3e13514b4e9452a8c79fd2f4",
    "5fe23d1f8de128c7dc80382cc36aabe6",
    "162f4c0012afaf7f53e757f2e252a046",
    "69f9061c71647d31ab65cd4492fd4ebd",
    "15467fe2b7da9a9780ea6b75665f1a71",
    "3d6a3926a8fecf8463265ecbc8afd38f",
    "5ab246e2095c0655da2b4a079f8c9cb1",
    "da932b036ff014a89dc41195b6a0305c",
    "eacef5f0efb77771e8d35c562d406889",
    "db4155d3bf8ceca27fadc602719f1669"
  )
  data.frame(
    ScenarioOrdinal = 1:14,
    ScenarioId = c(
      "C1-I2-BAL", "C1-I2-SPARSE", "C1-I2-UNEQUAL", "C1-I2-ABSENT",
      "C1-I3-BAL", "C1-I3-SPARSE", "C1-I3-UNEQUAL", "C1-I3-ABSENT",
      "C1-B2-RANK1", "C1-B2-RESID", "C1-B3-RANK2",
      "C1-B3-SCALED", "C1-N3-NO-AC", "C1-N2-NOREP"
    ),
    OpaqueScenarioToken = tokens,
    ScenarioClass = c(
      rep("regular_interior", 8L), "exact_psd_rank_boundary",
      "residual_operational_boundary", "exact_psd_rank_boundary",
      "scaled_relative_rank_boundary",
      rep("structural_rank_negative_control", 2L)
    ),
    AssignmentId = c(
      "A2-BAL", "A2-SPARSE", "A2-UNEQUAL", "A2-ABSENT",
      "A3-BAL", "A3-SPARSE", "A3-UNEQUAL", "A3-ABSENT",
      "A2-BAL", "A2-BAL", "A3-BAL", "A3-BAL", "A3-NOAC", "A2-NOREP"
    ),
    CoordinateLayoutId = c(
      rep("T2-GLOBAL-3C-R1", 4L), rep("T3-GLOBAL-3C-R1", 4L),
      rep("T2-GLOBAL-3C-R1", 2L), rep("T3-GLOBAL-3C-R1", 3L),
      "T2-GLOBAL-3C-R1"
    ),
    ReferenceId = c(
      rep("REF-T2-INTERIOR", 4L), rep("REF-T3-INTERIOR", 4L),
      "REF-T2-RATER-RANK1", "REF-T2-RESIDUAL-NEAR-ZERO",
      "REF-T3-RATER-RANK2", "REF-T3-INTERACTION-SCALED",
      "REF-T3-INTERIOR", "REF-T2-INTERIOR"
    ),
    ExpectedDerivativeRank = c(
      rep(10L, 4L), rep(19L, 4L), 10L, 10L, 19L, 19L, 17L, 9L
    ),
    ExpectedDerivativeDimension = c(
      rep(10L, 4L), rep(19L, 4L), 10L, 10L, 19L, 19L, 19L, 10L
    ),
    ExpectedPreFitState = c(
      rep("eligible_regular_point_fit", 8L),
      rep("eligible_point_fit_boundary_truth", 4L),
      rep("blocked_structural_covariance_rank", 2L)
    ),
    RecoveryExecutable = c(rep(TRUE, 12L), FALSE, FALSE),
    PilotReplicates = c(rep(20L, 12L), 0L, 0L),
    ConfirmationReplicates = c(rep(400L, 12L), 0L, 0L),
    NegativeControlReplicates = c(rep(0L, 12L), 1L, 1L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_expand_membership <- function(membership, rater_edges,
                                          replicates) {
  rows <- vector("list", nrow(membership))
  for (index in seq_len(nrow(membership))) {
    object <- membership$Object[[index]]
    raters <- rater_edges[[object]]
    rows[[index]] <- expand.grid(
      Replicate = seq_len(replicates), Rater = raters,
      Stratum = membership$Stratum[[index]],
      KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
    )
    rows[[index]]$Object <- object
    rows[[index]] <- rows[[index]][
      c("Object", "Rater", "Stratum", "Replicate")
    ]
  }
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtvd_assignment_rows <- function(assignment_id) {
  catalog <- mfrmr_gtvd_assignment_catalog()
  position <- match(as.character(assignment_id), catalog$AssignmentId)
  if (length(position) != 1L || is.na(position)) {
    stop("Unknown Draft.85c1 assignment identity.", call. = FALSE)
  }
  assignment <- catalog[position, , drop = FALSE]
  strata <- LETTERS[seq_len(assignment$StratumCount[[1L]])]
  objects <- sprintf("O%03d", seq_len(assignment$ObjectCount[[1L]]))
  raters <- sprintf("R%02d", seq_len(assignment$RaterCount[[1L]]))
  full_edges <- stats::setNames(rep(list(raters), length(objects)), objects)
  cyclic_edges <- stats::setNames(lapply(seq_along(objects), function(index) {
    raters[c(((index - 1L) %% length(raters)) + 1L,
             (index %% length(raters)) + 1L)]
  }), objects)
  unequal_edges <- stats::setNames(lapply(seq_along(objects), function(index) {
    c(raters[[1L]], raters[[2L + ((index - 1L) %% (length(raters) - 1L))]])
  }), objects)

  id <- assignment$AssignmentId[[1L]]
  membership <- if (id %in% c("A2-BAL", "A2-NOREP", "A2-SPARSE",
                              "A2-UNEQUAL", "A3-BAL", "A3-SPARSE",
                              "A3-UNEQUAL")) {
    expand.grid(
      Object = objects, Stratum = strata, KEEP.OUT.ATTRS = FALSE,
      stringsAsFactors = FALSE
    )
  } else if (identical(id, "A2-ABSENT")) {
    data.frame(
      Object = c(rep(objects[1:18], each = 2L), objects[19:24],
                 objects[25:30]),
      Stratum = c(rep(c("A", "B"), 18L), rep("A", 6L), rep("B", 6L)),
      stringsAsFactors = FALSE
    )
  } else if (identical(id, "A3-ABSENT")) {
    data.frame(
      Object = c(
        rep(objects[1:12], each = 3L), rep(objects[13:18], each = 2L),
        rep(objects[19:24], each = 2L), rep(objects[25:30], each = 2L)
      ),
      Stratum = c(
        rep(c("A", "B", "C"), 12L), rep(c("A", "B"), 6L),
        rep(c("A", "C"), 6L), rep(c("B", "C"), 6L)
      ), stringsAsFactors = FALSE
    )
  } else if (identical(id, "A3-NOAC")) {
    data.frame(
      Object = c(rep(objects[1:15], each = 2L),
                 rep(objects[16:30], each = 2L)),
      Stratum = c(rep(c("A", "B"), 15L), rep(c("B", "C"), 15L)),
      stringsAsFactors = FALSE
    )
  } else {
    stop("The assignment rule is not implemented.", call. = FALSE)
  }
  edges <- if (grepl("SPARSE$", id)) {
    cyclic_edges
  } else if (grepl("UNEQUAL$", id)) {
    unequal_edges
  } else full_edges
  output <- mfrmr_gtvd_expand_membership(
    membership, edges, assignment$WithinCellReplicates[[1L]]
  )
  output$ObjectRater <- paste(output$Object, output$Rater, sep = "\036")
  output <- output[c(
    "Object", "Rater", "ObjectRater", "Stratum", "Replicate"
  )]
  output$Replicate <- as.integer(output$Replicate)
  output$RowId <- sprintf("row_%06d", seq_len(nrow(output)))
  output <- output[c(
    "RowId", "Stratum", "Object", "Rater", "ObjectRater", "Replicate"
  )]
  row.names(output) <- NULL
  if (!identical(nrow(output), assignment$ExpectedRows[[1L]])) {
    stop("The deterministic assignment row count changed.", call. = FALSE)
  }
  output
}

mfrmr_gtvd_coordinate_layouts <- function() {
  catalogs <- mfrmr_gtvd_stratum_catalog()
  layouts <- lapply(seq_len(nrow(catalogs)), function(index) {
    strata <- strsplit(
      catalogs$OrderedStrata[[index]], "|", fixed = TRUE
    )[[1L]]
    row_id <- paste0("layout_row_", strata)
    group_codes <- matrix(
      1L, nrow = length(strata), ncol = 3L,
      dimnames = list(row_id, c("Object", "Rater", "Object:Rater"))
    )
    fixed <- diag(length(strata))
    dimnames(fixed) <- list(row_id, paste0("Stratum/", strata))
    design <- mfrmr_gtvc_neutral_design(
      row_id, strata, seq_along(strata), group_codes, fixed,
      stats::setNames(rep(0, length(strata)), row_id)
    )
    layout <- mfrmr_gtvc_coordinate_layout(design)
    data.frame(
      CoordinateLayoutId = catalogs$CoordinateLayoutId[[index]],
      StratumCount = catalogs$StratumCount[[index]],
      CoordinateOrdinal = seq_len(nrow(layout)), layout,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, layouts)
  row.names(output) <- NULL
  output
}

mfrmr_gtvd_pair_overlap <- function(rows, strata, group) {
  pairs <- utils::combn(strata, 2L, simplify = FALSE)
  overlaps <- vapply(pairs, function(pair) {
    left <- unique(rows[[group]][rows$Stratum == pair[[1L]]])
    right <- unique(rows[[group]][rows$Stratum == pair[[2L]]])
    length(intersect(left, right))
  }, integer(1L))
  if (length(overlaps) == 0L) 0L else min(overlaps)
}

mfrmr_gtvd_structural_rank <- function(rows, strata,
                                       rank_tolerance = 1e-10) {
  if (!is.data.frame(rows) || nrow(rows) == 0L ||
      !identical(names(rows), c(
        "RowId", "Stratum", "Object", "Rater", "ObjectRater", "Replicate"
      )) || anyNA(rows) || anyDuplicated(rows$RowId)) {
    stop("A canonical Draft.85c1 structural row table is required.",
         call. = FALSE)
  }
  if (!is.numeric(rank_tolerance) || length(rank_tolerance) != 1L ||
      is.na(rank_tolerance) || !is.finite(rank_tolerance) ||
      rank_tolerance <= 0) {
    stop("`rank_tolerance` must be one finite positive number.",
         call. = FALSE)
  }
  stratum_code <- match(rows$Stratum, strata)
  if (anyNA(stratum_code) ||
      !identical(sort(unique(stratum_code)), seq_along(strata))) {
    stop("Structural rows do not use the exact declared strata.",
         call. = FALSE)
  }
  per_component <- length(strata) * (length(strata) + 1L) / 2L
  pair_map <- matrix(NA_integer_, length(strata), length(strata))
  cursor <- 0L
  for (left in seq_along(strata)) {
    for (right in seq.int(left, length(strata))) {
      cursor <- cursor + 1L
      pair_map[left, right] <- cursor
      pair_map[right, left] <- cursor
    }
  }
  cells <- unique(rows[c("Stratum", "Object", "Rater", "ObjectRater")])
  cell_key <- paste(
    rows$Stratum, rows$Object, rows$Rater, rows$ObjectRater, sep = "\036"
  )
  cell_frequency <- table(cell_key)
  observed_keys <- integer()
  for (left_stratum in seq_along(strata)) {
    left_cells <- cells[cells$Stratum == strata[[left_stratum]], , drop = FALSE]
    for (right_stratum in seq.int(left_stratum, length(strata))) {
      right_cells <- cells[
        cells$Stratum == strata[[right_stratum]], , drop = FALSE
      ]
      if (left_stratum == right_stratum) {
        pairs <- which(
          lower.tri(matrix(FALSE, nrow(left_cells), nrow(left_cells))),
          arr.ind = TRUE
        )
        left <- pairs[, 1L]
        right <- pairs[, 2L]
      } else {
        pairs <- expand.grid(
          left = seq_len(nrow(left_cells)),
          right = seq_len(nrow(right_cells)),
          KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
        )
        left <- pairs$left
        right <- pairs$right
      }
      if (length(left) > 0L) {
        bits <- as.integer(
          left_cells$Object[left] == right_cells$Object[right]
        ) + 2L * as.integer(
          left_cells$Rater[left] == right_cells$Rater[right]
        ) + 4L * as.integer(
          left_cells$ObjectRater[left] == right_cells$ObjectRater[right]
        )
        observed_keys <- c(
          observed_keys,
          pair_map[left_stratum, right_stratum] + per_component * bits
        )
      }
      if (left_stratum == right_stratum) {
        pair_code <- pair_map[left_stratum, left_stratum]
        observed_keys <- c(observed_keys, pair_code + per_component * 15L)
        local_keys <- paste(
          left_cells$Stratum, left_cells$Object, left_cells$Rater,
          left_cells$ObjectRater, sep = "\036"
        )
        if (any(cell_frequency[local_keys] > 1L)) {
          observed_keys <- c(
            observed_keys, pair_code + per_component * 7L
          )
        }
      }
    }
  }
  observed_keys <- sort(unique(observed_keys))
  signature <- matrix(
    0, nrow = length(observed_keys), ncol = 3L * per_component + 1L
  )
  for (index in seq_along(observed_keys)) {
    key_zero <- observed_keys[[index]] - 1L
    bit_code <- key_zero %/% per_component
    pair_code <- key_zero %% per_component + 1L
    for (component in seq_len(3L)) {
      component_bit <- bitwShiftL(1L, component - 1L)
      if (bitwAnd(bit_code, component_bit) != 0L) {
        signature[index, (component - 1L) * per_component + pair_code] <- 1
      }
    }
    if (bitwAnd(bit_code, 8L) != 0L) {
      signature[index, ncol(signature)] <- 1
    }
  }
  singular_values <- svd(signature, nu = 0L, nv = 0L)$d
  threshold <- rank_tolerance * max(1, max(singular_values))
  rank <- sum(singular_values > threshold)
  list(
    ParameterCount = as.integer(ncol(signature)),
    StructuralRank = as.integer(rank),
    StructuralRankFull = identical(rank, ncol(signature)),
    SingularValueThreshold = threshold,
    MinimumSingularValue = min(singular_values),
    SignatureCount = as.integer(nrow(signature)),
    ObservedSignatureHash = mfrmr_gta_hash(list(
      ObservedKeys = observed_keys, Signature = signature
    ))
  )
}

mfrmr_gtvd_structural_preflight <- function(scenario_registry) {
  assignments <- mfrmr_gtvd_assignment_catalog()
  layouts <- mfrmr_gtvd_stratum_catalog()
  rows <- lapply(seq_len(nrow(assignments)), function(index) {
    assignment <- assignments[index, , drop = FALSE]
    structural <- mfrmr_gtvd_assignment_rows(assignment$AssignmentId)
    strata <- LETTERS[seq_len(assignment$StratumCount[[1L]])]
    rank <- mfrmr_gtvd_structural_rank(structural, strata)
    scenarios <- scenario_registry[
      scenario_registry$AssignmentId == assignment$AssignmentId, , drop = FALSE
    ]
    expected_ranks <- unique(scenarios$ExpectedDerivativeRank)
    expected_dimensions <- unique(scenarios$ExpectedDerivativeDimension)
    if (length(expected_ranks) != 1L || length(expected_dimensions) != 1L) {
      stop("An assignment maps to incompatible structural expectations.",
           call. = FALSE)
    }
    expected_layout <- layouts$DeclaredCoordinateCount[
      match(scenarios$CoordinateLayoutId[[1L]], layouts$CoordinateLayoutId)
    ]
    data.frame(
      AssignmentId = assignment$AssignmentId,
      StructuralRows = as.integer(nrow(structural)),
      UniqueObjects = as.integer(length(unique(structural$Object))),
      UniqueRaters = as.integer(length(unique(structural$Rater))),
      MinimumObjectPairOverlap = mfrmr_gtvd_pair_overlap(
        structural, strata, "Object"
      ),
      MinimumRaterPairOverlap = mfrmr_gtvd_pair_overlap(
        structural, strata, "Rater"
      ),
      MinimumObjectRaterPairOverlap = mfrmr_gtvd_pair_overlap(
        structural, strata, "ObjectRater"
      ),
      SignatureParameterCount = rank$ParameterCount,
      CompactSignatureRank = rank$StructuralRank,
      ExpectedStructuralRank = expected_ranks,
      CompactSignatureRankMatchesExpectation = identical(
        rank$StructuralRank, expected_ranks
      ),
      LayoutDimensionMatches = identical(
        rank$ParameterCount, as.integer(expected_layout)
      ) && identical(rank$ParameterCount, expected_dimensions),
      SignatureCount = rank$SignatureCount,
      SingularValueThreshold = rank$SingularValueThreshold,
      MinimumSingularValue = rank$MinimumSingularValue,
      StructuralRowsHash = mfrmr_gta_hash(structural),
      ObservedSignatureHash = rank$ObservedSignatureHash,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  if (!all(output$CompactSignatureRankMatchesExpectation) ||
      !all(output$LayoutDimensionMatches)) {
    stop("A Draft.85c1 structural-rank expectation failed.", call. = FALSE)
  }
  output
}

mfrmr_gtvd_c0_structural_design <- function(assignment_id) {
  rows <- mfrmr_gtvd_assignment_rows(assignment_id)
  strata <- sort(unique(rows$Stratum))
  group_codes <- cbind(
    Object = match(rows$Object, unique(rows$Object)),
    Rater = match(rows$Rater, unique(rows$Rater)),
    `Object:Rater` = match(rows$ObjectRater, unique(rows$ObjectRater))
  )
  storage.mode(group_codes) <- "integer"
  rownames(group_codes) <- rows$RowId
  fixed <- matrix(
    0, nrow = nrow(rows), ncol = length(strata),
    dimnames = list(rows$RowId, paste0("Stratum/", strata))
  )
  stratum_code <- match(rows$Stratum, strata)
  fixed[cbind(seq_len(nrow(rows)), stratum_code)] <- 1
  mfrmr_gtvc_neutral_design(
    rows$RowId, strata, stratum_code, group_codes, fixed,
    stats::setNames(rep(0, nrow(rows)), rows$RowId)
  )
}

mfrmr_gtvd_c0_derivative_replay <- function(structural_preflight) {
  assignments <- c("A3-NOAC", "A2-NOREP")
  output <- lapply(assignments, function(assignment_id) {
    design <- mfrmr_gtvd_c0_structural_design(assignment_id)
    derivative <- mfrmr_gtvc_derivative_design(
      design, rank_tolerance = 1e-10, max_k_cells = 6e6
    )
    mfrmr_gtvc_assert_derivative(design, derivative)
    compact <- structural_preflight[
      structural_preflight$AssignmentId == assignment_id, , drop = FALSE
    ]
    data.frame(
      AssignmentId = assignment_id,
      StructuralPlaceholderResponse = TRUE,
      StructuralDesignHash = design$StructuralDesignHash,
      DerivativeResultHash = derivative$ResultHash,
      ParameterCount = derivative$ParameterCount,
      C0DerivativeRank = derivative$StructuralRank,
      CompactSignatureRank = compact$CompactSignatureRank,
      RankReplayMatches = identical(
        derivative$StructuralRank, compact$CompactSignatureRank[[1L]]
      ),
      CovarianceDesignIdentified = derivative$CovarianceDesignIdentified,
      OracleReady = derivative$CovarianceDesignOracleReady,
      RecoveryEvidenceReady = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, output)
  row.names(output) <- NULL
  if (!all(output$RankReplayMatches) || !all(output$OracleReady) ||
      any(output$CovarianceDesignIdentified)) {
    stop("The c0 derivative negative-control replay failed.", call. = FALSE)
  }
  output
}

mfrmr_gtvd_interior_matrices <- function(strata) {
  if (length(strata) == 2L) {
    matrices <- list(
      Object = matrix(c(1, 0.35, 0.35, 0.8), 2L),
      Rater = matrix(c(0.25, 0.08, 0.08, 0.20), 2L),
      `Object:Rater` = matrix(c(0.30, 0.06, 0.06, 0.25), 2L)
    )
  } else if (length(strata) == 3L) {
    matrices <- list(
      Object = matrix(c(
        1, 0.35, 0.20, 0.35, 0.8, 0.25, 0.20, 0.25, 0.9
      ), 3L),
      Rater = matrix(c(
        0.25, 0.08, 0.04, 0.08, 0.20, 0.06, 0.04, 0.06, 0.22
      ), 3L),
      `Object:Rater` = matrix(c(
        0.30, 0.06, 0.03, 0.06, 0.25, 0.05, 0.03, 0.05, 0.28
      ), 3L)
    )
  } else {
    stop("Only the frozen two- and three-stratum layouts are permitted.",
         call. = FALSE)
  }
  lapply(matrices, function(matrix) {
    dimnames(matrix) <- list(strata, strata)
    matrix
  })
}

mfrmr_gtvd_reference_bundle <- function(coordinate_layouts) {
  t2 <- mfrmr_gtvd_interior_matrices(c("A", "B"))
  t3 <- mfrmr_gtvd_interior_matrices(c("A", "B", "C"))
  rank1 <- t2
  vector <- c(0.5, 0.4)
  rank1$Rater <- outer(vector, vector)
  dimnames(rank1$Rater) <- list(c("A", "B"), c("A", "B"))
  residual_boundary <- t2
  rank2 <- t3
  loading <- matrix(c(0.5, 0, 0.35, 0.25, 0.2, 0.3), 3L, byrow = TRUE)
  rank2$Rater <- loading %*% t(loading)
  dimnames(rank2$Rater) <- list(c("A", "B", "C"), c("A", "B", "C"))
  scaled <- t3
  q <- cbind(
    c(1, 1, 1) / sqrt(3), c(1, -1, 0) / sqrt(2),
    c(1, 1, -2) / sqrt(6)
  )
  scaled$`Object:Rater` <- q %*% diag(c(200, 0.15, 1.5e-8)) %*% t(q)
  dimnames(scaled$`Object:Rater`) <- list(
    c("A", "B", "C"), c("A", "B", "C")
  )
  points <- list(
    `REF-T2-INTERIOR` = list(
      Layout = "T2-GLOBAL-3C-R1", Matrices = t2, Residual = 0.25,
      BoundaryClass = "regular_interior", BoundaryComponent = "none"
    ),
    `REF-T3-INTERIOR` = list(
      Layout = "T3-GLOBAL-3C-R1", Matrices = t3, Residual = 0.25,
      BoundaryClass = "regular_interior", BoundaryComponent = "none"
    ),
    `REF-T2-RATER-RANK1` = list(
      Layout = "T2-GLOBAL-3C-R1", Matrices = rank1, Residual = 0.25,
      BoundaryClass = "exact_psd_rank_boundary", BoundaryComponent = "Rater"
    ),
    `REF-T2-RESIDUAL-NEAR-ZERO` = list(
      Layout = "T2-GLOBAL-3C-R1", Matrices = residual_boundary,
      Residual = 5e-9, BoundaryClass = "residual_operational_boundary",
      BoundaryComponent = "Residual"
    ),
    `REF-T3-RATER-RANK2` = list(
      Layout = "T3-GLOBAL-3C-R1", Matrices = rank2, Residual = 0.25,
      BoundaryClass = "exact_psd_rank_boundary", BoundaryComponent = "Rater"
    ),
    `REF-T3-INTERACTION-SCALED` = list(
      Layout = "T3-GLOBAL-3C-R1", Matrices = scaled, Residual = 0.25,
      BoundaryClass = "scaled_relative_rank_boundary",
      BoundaryComponent = "Object:Rater"
    )
  )
  catalog_rows <- list(); coordinate_rows <- list(); factor_rows <- list()
  audit_rows <- list(); boundary_rows <- list()
  for (reference_id in names(points)) {
    point <- points[[reference_id]]
    layout <- coordinate_layouts[
      coordinate_layouts$CoordinateLayoutId == point$Layout, , drop = FALSE
    ]
    component_audits <- lapply(names(point$Matrices), function(component) {
      audit <- mfrmr_gtvc_matrix_audit(
        point$Matrices[[component]], unique(layout$LeftStratum[!is.na(
          layout$LeftStratum
        )]), component, tolerance = 1e-10, boundary_tolerance = 1e-8
      )$Audit
      data.frame(ReferenceId = reference_id, audit, stringsAsFactors = FALSE)
    })
    component_audit <- do.call(rbind, component_audits)
    row.names(component_audit) <- NULL
    audit_rows[[length(audit_rows) + 1L]] <- component_audit
    matrix_truth_class <- ifelse(
      component_audit$MinimumEigenvalue <= 1e-8,
      "absolute_boundary",
      ifelse(
        component_audit$RankDeficient,
        "scaled_relative_rank_boundary", "regular_interior"
      )
    )
    matrix_classification_rule <- ifelse(
      matrix_truth_class == "absolute_boundary",
      "truth_minimum_eigenvalue_le_absolute_boundary_tolerance",
      ifelse(
        matrix_truth_class == "scaled_relative_rank_boundary",
        "truth_effective_rank_less_than_stratum_count_under_relative_rule",
        "truth_finite_PSD_and_neither_absolute_nor_scaled_boundary"
      )
    )
    residual_truth_class <- if (point$Residual <= 1e-8) {
      "absolute_boundary"
    } else {
      "regular_interior"
    }
    boundary_rows[[length(boundary_rows) + 1L]] <- rbind(
      data.frame(
        ReferenceId = reference_id,
        ComponentOrdinal = match(
          component_audit$ComponentId,
          c("Object", "Rater", "Object:Rater", "Residual")
        ),
        ComponentId = component_audit$ComponentId,
        TruthComparisonClass = matrix_truth_class,
        TruthClassPrecedence = match(
          matrix_truth_class,
          c(
            "unavailable_non_psd_or_extraction_failure",
            "absolute_boundary", "scaled_relative_rank_boundary",
            "regular_interior"
          )
        ),
        ClassificationRule = matrix_classification_rule,
        ClassificationAvailable = TRUE,
        PSDRepairAllowed = FALSE,
        stringsAsFactors = FALSE
      ),
      data.frame(
        ReferenceId = reference_id, ComponentOrdinal = 4L,
        ComponentId = "Residual",
        TruthComparisonClass = residual_truth_class,
        TruthClassPrecedence = match(
          residual_truth_class,
          c(
            "unavailable_non_psd_or_extraction_failure",
            "absolute_boundary", "scaled_relative_rank_boundary",
            "regular_interior"
          )
        ),
        ClassificationRule = if (
          identical(residual_truth_class, "absolute_boundary")
        ) {
          "truth_residual_variance_le_absolute_boundary_tolerance"
        } else {
          "truth_finite_residual_variance_above_absolute_boundary_tolerance"
        },
        ClassificationAvailable = TRUE, PSDRepairAllowed = FALSE,
        stringsAsFactors = FALSE
      )
    )
    point_factors <- lapply(names(point$Matrices), function(component) {
      factor <- if (identical(reference_id, "REF-T2-RATER-RANK1") &&
                    identical(component, "Rater")) {
        matrix(c(0.5, 0.4), ncol = 1L)
      } else if (identical(reference_id, "REF-T3-RATER-RANK2") &&
                 identical(component, "Rater")) {
        loading
      } else if (identical(
        reference_id, "REF-T3-INTERACTION-SCALED"
      ) && identical(component, "Object:Rater")) {
        q %*% diag(sqrt(c(200, 0.15, 1.5e-8)))
      } else {
        t(chol(point$Matrices[[component]]))
      }
      reconstruction_error <- max(abs(
        factor %*% t(factor) - point$Matrices[[component]]
      ))
      if (reconstruction_error > 1e-12) {
        stop("A frozen generating factor does not reconstruct its truth.",
             call. = FALSE)
      }
      indices <- expand.grid(
        FactorRowOrdinal = seq_len(nrow(factor)),
        FactorColumnOrdinal = seq_len(ncol(factor)),
        KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
      )
      construction <- if (identical(reference_id, "REF-T2-RATER-RANK1") &&
                          identical(component, "Rater")) {
        "frozen_rank1_loading"
      } else if (identical(reference_id, "REF-T3-RATER-RANK2") &&
                 identical(component, "Rater")) {
        "frozen_rank2_loading"
      } else if (identical(
        reference_id, "REF-T3-INTERACTION-SCALED"
      ) && identical(component, "Object:Rater")) {
        "frozen_orthogonal_scaled_loading"
      } else "stored_lower_cholesky"
      data.frame(
        ReferenceId = reference_id, ComponentId = component,
        FactorRowOrdinal = as.integer(indices$FactorRowOrdinal),
        FactorColumnOrdinal = as.integer(indices$FactorColumnOrdinal),
        FactorRowStratum = rownames(point$Matrices[[component]])[
          indices$FactorRowOrdinal
        ],
        FactorValue = as.numeric(factor),
        FactorConstruction = construction,
        MatrixReconstructionMaximumAbsoluteError = reconstruction_error,
        stringsAsFactors = FALSE
      )
    })
    residual_factor <- data.frame(
      ReferenceId = reference_id, ComponentId = "Residual",
      FactorRowOrdinal = 1L, FactorColumnOrdinal = 1L,
      FactorRowStratum = "Residual",
      FactorValue = sqrt(point$Residual),
      FactorConstruction = "positive_scalar_square_root",
      MatrixReconstructionMaximumAbsoluteError =
        abs(sqrt(point$Residual)^2 - point$Residual),
      stringsAsFactors = FALSE
    )
    point_factor_table <- do.call(rbind, c(point_factors, list(residual_factor)))
    row.names(point_factor_table) <- NULL
    factor_rows[[length(factor_rows) + 1L]] <- point_factor_table
    expected_regular <- !any(component_audit$Boundary) &&
      !any(component_audit$RankDeficient) && point$Residual > 1e-8
    catalog_rows[[length(catalog_rows) + 1L]] <- data.frame(
      ReferenceId = reference_id, CoordinateLayoutId = point$Layout,
      BoundaryClass = point$BoundaryClass,
      BoundaryComponent = point$BoundaryComponent,
      ResidualVariance = point$Residual,
      ExpectedRegularInterior = expected_regular,
      MatrixSetHash = mfrmr_gta_hash(point$Matrices),
      FactorSetHash = mfrmr_gta_hash(point_factor_table),
      MaximumFactorReconstructionError = max(
        point_factor_table$MatrixReconstructionMaximumAbsoluteError
      ),
      stringsAsFactors = FALSE
    )
    truth <- vapply(seq_len(nrow(layout)), function(index) {
      component <- layout$ComponentId[[index]]
      if (identical(component, "Residual")) return(point$Residual)
      point$Matrices[[component]][
        layout$LeftIndex[[index]], layout$RightIndex[[index]]
      ]
    }, numeric(1L))
    coordinate_rows[[length(coordinate_rows) + 1L]] <- data.frame(
      ReferenceId = reference_id,
      CoordinateLayoutId = point$Layout,
      CoordinateOrdinal = layout$CoordinateOrdinal,
      CoordinateId = layout$CoordinateId,
      ComponentId = layout$ComponentId,
      LeftStratum = layout$LeftStratum,
      RightStratum = layout$RightStratum,
      CoordinateType = layout$CoordinateType,
      TruthValue = truth,
      stringsAsFactors = FALSE
    )
  }
  catalog <- do.call(rbind, catalog_rows)
  coordinates <- do.call(rbind, coordinate_rows)
  factors <- do.call(rbind, factor_rows)
  audits <- do.call(rbind, audit_rows)
  boundary_classes <- do.call(rbind, boundary_rows)
  row.names(catalog) <- NULL
  row.names(coordinates) <- NULL
  row.names(factors) <- NULL
  row.names(audits) <- NULL
  row.names(boundary_classes) <- NULL
  list(
    Catalog = catalog, Coordinates = coordinates, Factors = factors,
    Audits = audits, BoundaryClasses = boundary_classes
  )
}

mfrmr_gtvd_fixed_mean_registry <- function() {
  data.frame(
    CoordinateLayoutId = c(
      rep("T2-GLOBAL-3C-R1", 2L), rep("T3-GLOBAL-3C-R1", 3L)
    ),
    Stratum = c("A", "B", "A", "B", "C"),
    Mean = c(0, 0.4, 0, 0.4, 0.8),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_method_registry <- function() {
  registry <- data.frame(
    MethodOrdinal = 1:4,
    MethodId = c("lme4_reml", "glmmtmb_reml", "lme4_ml", "glmmtmb_ml"),
    Backend = c("lme4", "glmmTMB", "lme4", "glmmTMB"),
    Criterion = c("REML", "REML", "ML", "ML"),
    ControlContract = c(
      "Draft85b1_lmerControl_default_no_override",
      "Draft85b1_glmmTMBControl_default_no_override",
      "Draft85b1_lmerControl_default_no_override",
      "Draft85b1_glmmTMBControl_default_no_override"
    ),
    MatrixTolerance = rep(1e-10, 4L),
    BoundaryTolerance = rep(1e-8, 4L),
    CorrelationTolerance = rep(1e-6, 4L),
    SingularTolerance = c(1e-4, NA_real_, 1e-4, NA_real_),
    PairedDatasetRequired = rep(TRUE, 4L),
    DiagnosticOverrideAllowed = rep(FALSE, 4L),
    MatchedBackendQualificationRequired = rep(TRUE, 4L),
    stringsAsFactors = FALSE
  )
  registry$MethodControlHash <- vapply(seq_len(nrow(registry)), function(i) {
    mfrmr_gta_hash(registry[i, names(registry), drop = FALSE])
  }, character(1L))
  registry
}

mfrmr_gtvd_pair_registry <- function() {
  data.frame(
    PairOrdinal = 1:4,
    PairId = c(
      "PAIR-BACKEND-REML", "PAIR-BACKEND-ML",
      "PAIR-CRITERION-LME4", "PAIR-CRITERION-GLMMTMB"
    ),
    PairClass = c(
      "backend_within_criterion", "backend_within_criterion",
      "criterion_within_backend", "criterion_within_backend"
    ),
    LeftMethodId = c(
      "lme4_reml", "lme4_ml", "lme4_ml", "glmmtmb_ml"
    ),
    RightMethodId = c(
      "glmmtmb_reml", "glmmtmb_ml", "lme4_reml", "glmmtmb_reml"
    ),
    ContrastOrientation = rep("left_minus_right", 4L),
    InputCoordinateMetricId = rep(
      "coordinate_normalized_absolute_error", 4L
    ),
    DatasetLossReductionId = rep(
      "equal_weight_all_declared_coordinates_complete_case", 4L
    ),
    PairedOutputMetricId = rep(
      "paired_mean_normalized_absolute_error_difference", 4L
    ),
    PairAvailabilityMetricId = rep(
      "complete_pair_availability_rate", 4L
    ),
    CompletePairRequired = rep(TRUE, 4L),
    PairDenominator = rep(
      "all_planned_dataset_pairs_with_complete_pair_rate_reported", 4L
    ),
    PoolingAllowed = rep(FALSE, 4L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_pair_state_algebra <- function() {
  data.frame(
    StateOrdinal = 1:4,
    LeftDatasetLossAvailable = c(FALSE, FALSE, TRUE, TRUE),
    RightDatasetLossAvailable = c(FALSE, TRUE, FALSE, TRUE),
    PairContrastAvailable = c(FALSE, FALSE, FALSE, TRUE),
    PairContrastRule = c(
      rep("NA_real_no_partial_coordinate_or_one_sided_contrast", 3L),
      "left_dataset_loss_minus_right_dataset_loss"
    ),
    AvailabilityDenominator = rep("all_planned_pair_rows", 4L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_metric_registry <- function() {
  data.frame(
    MetricOrdinal = 1:22,
    MetricId = c(
      "coordinate_signed_error", "coordinate_absolute_error",
      "coordinate_squared_error", "coordinate_relative_error",
      "coordinate_normalized_signed_error",
      "coordinate_normalized_absolute_error",
      "coordinate_normalized_squared_error", "component_coordinate_rmse",
      "total_k_relative_frobenius_error", "minimum_eigenvalue_error",
      "effective_rank_exact_match", "boundary_classification_match",
      "psd_violation_or_extraction_failure_rate", "fit_return_rate",
      "estimate_availability_rate", "point_gate_rate",
      "metric_availability_rate", "false_ready_rate",
      "paired_mean_normalized_absolute_error_difference",
      "complete_pair_availability_rate",
      "expected_prefit_state_exact_match", "unexpected_fit_attempt_rate"
    ),
    MetricLevel = c(
      rep("dataset_method_coordinate", 7L), "scenario_method_component",
      "dataset_method", rep("dataset_method_component", 3L),
      rep("scenario_method", 4L), "target_metric_natural_unit",
      "scenario_method", rep("scenario_pair", 2L),
      rep("scenario_method", 2L)
    ),
    NaturalUnitId = c(
      rep("candidate_coordinate", 7L), "candidate_component",
      "candidate_method", rep("candidate_component", 3L),
      rep("candidate_method", 4L), "target_metric_natural_unit",
      "candidate_method", rep("candidate_pair", 2L),
      rep("candidate_method", 2L)
    ),
    Definition = c(
      "estimate_minus_truth", "absolute_estimate_minus_truth",
      "squared_estimate_minus_truth",
      "estimate_minus_truth_over_truth_only_when_abs_truth_gt_zero_tolerance",
      "estimate_minus_truth_over_registered_truth_side_coordinate_normalizer",
      "absolute_normalized_signed_error", "squared_normalized_signed_error",
      "sqrt_mean_equal_weight_normalized_squared_coordinate_error",
      "frobenius_estimated_K_minus_truth_K_over_frobenius_truth_K",
      "estimated_minimum_eigenvalue_minus_truth_minimum_eigenvalue",
      "estimated_effective_rank_equals_truth_effective_rank",
      "estimated_component_boundary_class_equals_registered_truth_comparison_class",
      "any_extracted_non_PSD_component_or_component_extraction_failure",
      "fit_returned_over_all_planned_rows",
      "estimate_available_over_all_planned_rows",
      "point_gate_passed_over_all_planned_rows",
      "declared_target_metric_natural_unit_available_over_all_planned_units_for_target_metric_and_registered_axes",
      "point_gate_passed_when_truth_is_boundary_or_structurally_blocked",
      "left_minus_right_dataset_mean_normalized_absolute_coordinate_error",
      "both_registered_method_results_metric_available_over_all_planned_pairs",
      "observed_prefit_state_equals_registered_expected_prefit_state",
      "backend_attempted_when_registered_expected_prefit_state_is_blocked"
    ),
    WithinDatasetReduction = c(
      rep("none_atomic_coordinate", 7L),
      "equal_weight_mean_over_component_vech_coordinates_before_across_dataset_mean",
      "one_full_K_scalar", rep("one_scalar_per_component", 3L),
      rep("one_method_state", 4L),
      "one_availability_state_per_target_metric_natural_unit",
      "one_false_ready_state",
      "complete_case_equal_weight_mean_over_all_declared_coordinates_per_method_then_left_minus_right",
      "one_complete_pair_state", "one_exact_prefit_state_match",
      "one_unexpected_attempt_state"
    ),
    AcrossDatasetSummary = c(
      rep("mean_by_stage_scenario_method_component_coordinate", 7L),
      "sqrt_mean_dataset_component_normalized_MSE",
      "mean_by_stage_scenario_method",
      "mean_by_stage_scenario_method_component",
      rep("proportion_by_stage_scenario_method_component", 2L),
      rep("proportion_by_stage_scenario_method", 4L),
      "proportion_by_target_metric_and_all_registered_target_aggregation_axes",
      "proportion_by_stage_scenario_method",
      "mean_by_stage_scenario_pair",
      "proportion_by_stage_scenario_pair",
      rep("proportion_by_stage_scenario_method", 2L)
    ),
    AggregationAxes = c(
      rep("StageId|ScenarioId|MethodId|ComponentId|CoordinateId", 7L),
      "StageId|ScenarioId|MethodId|ComponentId",
      "StageId|ScenarioId|MethodId",
      rep("StageId|ScenarioId|MethodId|ComponentId", 3L),
      rep("StageId|ScenarioId|MethodId", 4L),
      "TargetMetricId|all_axes_in_MetricAvailabilityTargetRegistry.TargetMetricAggregationAxes",
      "StageId|ScenarioId|MethodId",
      rep("StageId|ScenarioId|PairId", 2L),
      rep("StageId|ScenarioId|MethodId", 2L)
    ),
    Denominator = c(
      rep("conditional_on_metric_available_with_metric_availability_rate", 12L),
      rep("all_planned_atomic_method_rows", 4L),
      "all_planned_target_metric_natural_units_for_each_target_metric_and_registered_axes",
      "all_planned_boundary_or_structurally_blocked_atomic_method_rows",
      "complete_pairs_with_complete_pair_availability_rate",
      "all_planned_pair_rows",
      rep("all_planned_negative_control_atomic_method_rows", 2L)
    ),
    AvailabilityCompanionMetricId = c(
      rep("metric_availability_rate", 12L), rep("none", 6L),
      "complete_pair_availability_rate", rep("none", 3L)
    ),
    TargetMetricScope = c(
      rep("none", 16L),
      "registered_stage_scenario_targets_in_MetricAvailabilityTargetRegistry",
      rep("none", 5L)
    ),
    NormalizationPolicyId = c(
      rep("none", 4L), rep("TRUTH-TOTAL-MARGINAL-V1", 4L),
      rep("none", 10L), "TRUTH-TOTAL-MARGINAL-V1", rep("none", 3L)
    ),
    BoundaryScenarioEligible = c(rep(TRUE, 20L), FALSE, FALSE),
    AvailabilityMayBeConditional = c(rep(TRUE, 12L), rep(FALSE, 10L)),
    PrimaryMetric = c(
      FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE,
      TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE
    ),
    PrecisionPolicyId = c(
      rep("MC-RAW-REPORT", 4L), rep("MC-CONTINUOUS-005", 3L),
      "MC-COMPONENT-MSE-005", "MC-CONTINUOUS-005", "MC-RAW-REPORT",
      rep("MC-RATE-400", 8L), "MC-PAIRED-005", "MC-RATE-400",
      rep("DET-STRUCTURAL", 2L)
    ),
    AccuracyThresholdStatus = rep("not_frozen_prospective_gate_required", 22L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_metric_normalization_policy <- function() {
  data.frame(
    NormalizationPolicyId = "TRUTH-TOTAL-MARGINAL-V1",
    ScaleSide = "registered_truth_only_never_estimate",
    TruthTotalVarianceRule =
      "V_s0=Object[s,s]+Rater[s,s]+Object:Rater[s,s]+ResidualVariance",
    NonResidualCoordinateDenominator = "sqrt(V_left0*V_right0)",
    ResidualCoordinateDenominator = "mean(V_s0_over_registered_strata)",
    CoordinateUniverse =
      "all_declared_layout_coordinates_including_Residual[I]",
    DatasetLossReductionId =
      "equal_weight_all_declared_coordinates_complete_case",
    DatasetLossRule =
      "mean_coordinate_normalized_absolute_error_over_declared_layout",
    IncompleteCoordinateAction =
      "dataset_loss_unavailable_no_partial_coordinate_mean",
    PositivityRequirement = "every_V_s0_finite_and_strictly_positive",
    EstimateSideScalingAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_metric_applicability_registry <- function(scenarios, metrics) {
  scenario_stage <- do.call(rbind, lapply(seq_len(nrow(scenarios)), function(i) {
    scenario <- scenarios[i, , drop = FALSE]
    stages <- if (isTRUE(scenario$RecoveryExecutable[[1L]])) {
      c("pilot", "confirmation")
    } else {
      "negative_control"
    }
    data.frame(
      StageId = stages, ScenarioId = scenario$ScenarioId,
      ScenarioClass = scenario$ScenarioClass,
      stringsAsFactors = FALSE
    )
  }))
  pilot_metrics <- c(
    "psd_violation_or_extraction_failure_rate", "fit_return_rate",
    "estimate_availability_rate", "point_gate_rate",
    "metric_availability_rate", "false_ready_rate",
    "complete_pair_availability_rate"
  )
  negative_metrics <- c(
    "false_ready_rate", "expected_prefit_state_exact_match",
    "unexpected_fit_attempt_rate"
  )
  rows <- lapply(seq_len(nrow(scenario_stage)), function(i) {
    cell <- scenario_stage[i, , drop = FALSE]
    applicable <- if (identical(cell$StageId[[1L]], "pilot")) {
      metrics$MetricId %in% pilot_metrics
    } else if (identical(cell$StageId[[1L]], "confirmation")) {
      !metrics$MetricId %in% c(
        "expected_prefit_state_exact_match", "unexpected_fit_attempt_rate"
      )
    } else {
      metrics$MetricId %in% negative_metrics
    }
    regular <- identical(cell$ScenarioClass[[1L]], "regular_interior")
    applicable[metrics$MetricId == "false_ready_rate" & regular] <- FALSE
    data.frame(
      StageId = cell$StageId,
      ScenarioId = cell$ScenarioId,
      ScenarioClass = cell$ScenarioClass,
      MetricId = metrics$MetricId,
      Applicable = applicable,
      MetricUse = ifelse(
        !applicable, "not_applicable",
        if (identical(cell$StageId[[1L]], "pilot")) {
          "feasibility_only_never_threshold_selection"
        } else if (identical(cell$StageId[[1L]], "confirmation")) {
          "confirmation_evaluation_against_independently_prefrozen_rule"
        } else {
          "deterministic_structural_adjudication"
        }
      ),
      NaturalUnitId = ifelse(
        applicable, metrics$NaturalUnitId, "not_applicable"
      ),
      Denominator = ifelse(
        applicable, metrics$Denominator, "not_applicable"
      ),
      PrecisionPolicyId = ifelse(
        !applicable, "not_applicable",
        if (identical(cell$StageId[[1L]], "pilot")) {
          "PILOT-DESCRIPTIVE"
        } else if (identical(cell$StageId[[1L]], "negative_control")) {
          "DET-STRUCTURAL"
        } else {
          metrics$PrecisionPolicyId
        }
      ),
      ThresholdSelectionEligible = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output$ApplicabilityOrdinal <- as.integer(seq_len(nrow(output)))
  output[c(
    "ApplicabilityOrdinal", "StageId", "ScenarioId", "ScenarioClass",
    "MetricId", "Applicable", "MetricUse", "NaturalUnitId", "Denominator",
    "PrecisionPolicyId", "ThresholdSelectionEligible"
  )]
}

mfrmr_gtvd_metric_availability_target_registry <- function(scenarios,
                                                            metrics) {
  targets <- metrics[
    metrics$AvailabilityCompanionMetricId == "metric_availability_rate",
    c("MetricId", "MetricLevel", "NaturalUnitId", "AggregationAxes"),
    drop = FALSE
  ]
  recovery <- scenarios[scenarios$RecoveryExecutable, , drop = FALSE]
  rows <- unlist(lapply(seq_len(nrow(recovery)), function(i) {
    scenario <- recovery[i, , drop = FALSE]
    lapply(c("pilot", "confirmation"), function(stage_id) {
      data.frame(
        StageId = stage_id,
        ScenarioId = scenario$ScenarioId,
        ScenarioClass = scenario$ScenarioClass,
        AvailabilityMetricId = "metric_availability_rate",
        TargetMetricId = targets$MetricId,
        TargetMetricLevel = targets$MetricLevel,
        TargetMetricNaturalUnitType = targets$NaturalUnitId,
        TargetMetricAggregationAxes = targets$AggregationAxes,
        TargetMetricUse = if (identical(stage_id, "pilot")) {
          "confirmation_target_feasibility_only_never_threshold_selection"
        } else {
          "confirmation_metric_availability_companion"
        },
        Denominator =
          "all_planned_target_metric_natural_units_for_stage_scenario_metric",
        ThresholdSelectionEligible = FALSE,
        stringsAsFactors = FALSE
      )
    })
  }), recursive = FALSE)
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output$AvailabilityTargetOrdinal <- as.integer(seq_len(nrow(output)))
  output[c(
    "AvailabilityTargetOrdinal", "StageId", "ScenarioId", "ScenarioClass",
    "AvailabilityMetricId", "TargetMetricId", "TargetMetricLevel",
    "TargetMetricNaturalUnitType", "TargetMetricAggregationAxes",
    "TargetMetricUse", "Denominator",
    "ThresholdSelectionEligible"
  )]
}

mfrmr_gtvd_failure_taxonomy <- function() {
  data.frame(
    FailureOrdinal = 1:9,
    FailureStage = c(
      "none", "upstream_generation", "prefit", "backend_fit", "optimizer",
      "component_extraction", "regularity", "identity", "unrecorded"
    ),
    ReceiptMayRepresentState = c(rep(TRUE, 8L), FALSE),
    PlannedRowRetained = rep(TRUE, 9L),
    ReplacementSeedAllowed = rep(FALSE, 9L),
    Meaning = c(
      "complete_candidate_success", "sealed_dataset_generation_failure",
      "structural_or_incidence_hold_before_backend_attempt",
      "backend_call_did_not_return_a_fit", "optimizer_state_not_acceptable",
      "semantic_covariance_extraction_failed", "boundary_or_regularity_hold",
      "model_data_or_parameter_identity_mismatch",
      "no_receipt_exists_and_completion_must_fail"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_candidate_state_algebra <- function() {
  data.frame(
    StateOrdinal = 1:6,
    HandoffIssued = c(FALSE, TRUE, TRUE, TRUE, TRUE, TRUE),
    Attempted = c(FALSE, FALSE, TRUE, TRUE, TRUE, TRUE),
    FitReturned = c(FALSE, FALSE, FALSE, TRUE, TRUE, TRUE),
    EstimateAvailable = c(FALSE, FALSE, FALSE, FALSE, TRUE, TRUE),
    PointGatePassed = c(FALSE, FALSE, FALSE, FALSE, FALSE, TRUE),
    AllowedFailureStage = c(
      "upstream_generation", "prefit", "backend_fit",
      "optimizer|component_extraction|identity",
      "optimizer|regularity|identity", "none"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_receipt_mapping_registry <- function() {
  data.frame(
    MappingOrdinal = 1:8,
    SourceCondition = c(
      "dataset_generation_failure", "prefit_structural_or_incidence_block",
      "backend_call_error", "backend_returned_extraction_error",
      "b1_optimizer_hold_with_estimate", "b1_regularity_hold_with_estimate",
      "b1_identity_or_dependency_hold_with_estimate",
      "b1_point_estimation_gate_passed"
    ),
    HandoffIssued = c(FALSE, TRUE, rep(TRUE, 6L)),
    Attempted = c(FALSE, FALSE, rep(TRUE, 6L)),
    FitReturned = c(FALSE, FALSE, FALSE, rep(TRUE, 5L)),
    EstimateAvailable = c(FALSE, FALSE, FALSE, FALSE, rep(TRUE, 4L)),
    PointGatePassed = c(rep(FALSE, 7L), TRUE),
    B1NormalizedFitRequired = c(rep(FALSE, 4L), rep(TRUE, 4L)),
    B1PointEstimateAvailableExpected = c(
      rep(NA, 4L), rep(TRUE, 4L)
    ),
    B1PointEstimationGatePassedExpected = c(
      rep(NA, 4L), rep(FALSE, 3L), TRUE
    ),
    B1FitQualificationPolicy = c(
      rep("no_normalized_b1_fit_object", 4L),
      "not_point_estimation_gate_passed_typed_optimizer",
      "not_point_estimation_gate_passed_typed_regularity",
      "not_point_estimation_gate_passed_typed_identity_or_dependency",
      "exact_point_estimation_gate_passed"
    ),
    C0CandidateReceiptAvailable = c(FALSE, FALSE, rep(TRUE, 6L)),
    C0FailureStage = c(
      NA_character_, NA_character_, "backend_fit", "component_extraction",
      "optimizer", "regularity", "identity", "none"
    ),
    FailureCodePolicy = c(
      "sealed_generator_code", "sealed_prefit_code", "caught_backend_code",
      "caught_extraction_code", "exact_b1_fit_qualification",
      "exact_b1_fit_qualification", "exact_b1_dependency_or_identity_code",
      "none"
    ),
    RequiredC1EnvelopeFields = c(
      "ObservedGenerationState|Attempted|FailureStage|FailureCode",
      "ExpectedPreFitState|ObservedPreFitState|Attempted|FailureStage|FailureCode",
      rep("none_c0_candidate_receipt_after_c1_capture", 6L)
    ),
    C1EnvelopeRequired = c(TRUE, TRUE, rep(FALSE, 6L)),
    MappingImplemented = rep(FALSE, 8L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_stage_catalog <- function() {
  data.frame(
    StageOrdinal = 1:3,
    StageId = c("pilot", "confirmation", "negative_control"),
    LaneOpaqueId = c(
      "ec76865f40761f5ed872c970f024c478",
      "0c16778f2fc560733c8186c3f2937185",
      "78d1341a631816861b26fec9b99e7197"
    ),
    ReplicatesPerEligibleScenario = c(20L, 400L, 1L),
    EligibleScenarioCount = c(12L, 12L, 2L),
    Purpose = c(
      "feasibility_schema_pairing_failure_path_runtime_only",
      "untouched_recovery_evaluation_only_after_new_prospective_authorization",
      "deterministic_structural_block_controls"
    ),
    MaySelectAccuracyThreshold = rep(FALSE, 3L),
    MayPoolWithOtherStage = rep(FALSE, 3L),
    ExecutionAuthorized = rep(FALSE, 3L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_denominator_rules <- function() {
  data.frame(
    RuleOrdinal = 1:11,
    RuleId = c(
      "manifest_is_population", "all_method_rows_retained",
      "all_coordinate_rows_retained", "unrecorded_is_not_typed_failure",
      "no_success_only_denominator", "no_replacement_seed",
      "methods_are_paired", "pair_loss_requires_complete_coordinates",
      "stages_never_pool", "rates_use_registered_planned_natural_units",
      "continuous_metrics_report_availability"
    ),
    Requirement = c(
      "the_sealed_candidate_unit_manifest_defines_the_denominator",
      "fit_failure_or_hold_never_deletes_a_planned_method_row",
      "metric_unavailability_never_deletes_a_planned_coordinate",
      "missing_receipt_blocks_completion_and_is_not_imputed",
      "successful_fits_cannot_redefine_the_denominator",
      "a_failed_dataset_is_never_regenerated_with_a_new_seed",
      "four_methods_share_one_dataset_and_are_not_four_replications",
      "both_methods_require_every_declared_coordinate_or_pair_loss_is_unavailable",
      "pilot_confirmation_and_negative_control_summaries_are_separate",
      "each_rate_uses_every_registered_planned_natural_unit_in_its_metric_specific_denominator",
      "conditional_continuous_metrics_always_accompany_availability_rate"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_seed_partition_policy <- function() {
  data.frame(
    StageId = c("pilot", "confirmation", "negative_control"),
    BaseSeed = c(851000000L, 852000000L, 853000000L),
    ScenarioStride = c(1000L, 1000L, 0L),
    SeedFormula = c(
      "BaseSeed+1000*ScenarioOrdinal+Replicate",
      "BaseSeed+1000*ScenarioOrdinal+Replicate",
      "BaseSeed+ScenarioOrdinal"
    ),
    RNGKind = rep("L'Ecuyer-CMRG", 3L),
    NormalKind = rep("Inversion", 3L),
    SampleKind = rep("Rejection", 3L),
    InitializationRule = rep(
      "RNGkind(L'Ecuyer-CMRG,Inversion,Rejection);set.seed(DataSeed)", 3L
    ),
    ComponentSubstreamOrder = rep("Object|Rater|Object:Rater|Residual", 3L),
    InitialStreamOwner = rep("Object", 3L),
    ComponentStartStateRule = rep(
      "Object=initial;each_later_component=parallel::nextRNGSubStream(previous_component_start_state)",
      3L
    ),
    ComponentSubstreamAdvanceCount = rep(
      "Object=0|Rater=1|Object:Rater=2|Residual=3", 3L
    ),
    GroupLatentDrawRule = rep(
      "for_each_sorted_union_group_draw_z~N_r(0,I_r);r=ncol(stored_factor);b=stored_factor%*%z",
      3L
    ),
    FactorColumnDrawOrder = rep("ascending_FactorColumnOrdinal", 3L),
    GroupDrawCountRule = rep(
      "union_group_count_times_stored_factor_column_count", 3L
    ),
    ResidualDrawOrder = rep("canonical_RowId", 3L),
    ResidualDrawCountRule = rep("one_standard_normal_per_structural_row", 3L),
    FixtureRNGStateHash = rep(NA_character_, 3L),
    FixtureRNGStateHashReady = rep(FALSE, 3L),
    AssignmentUsesRandomness = rep(FALSE, 3L),
    EarlyStoppingAllowed = rep(FALSE, 3L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_monte_carlo_precision_policy <- function() {
  data.frame(
    PolicyOrdinal = 1:7,
    PrecisionPolicyId = c(
      "MC-RAW-REPORT", "MC-CONTINUOUS-005", "MC-COMPONENT-MSE-005",
      "MC-PAIRED-005", "MC-RATE-400", "PILOT-DESCRIPTIVE",
      "DET-STRUCTURAL"
    ),
    AppliesInStage = c(rep("confirmation", 5L), "pilot", "negative_control"),
    IndependentUnit = c(
      "independent_dataset", "independent_dataset", "independent_dataset",
      "complete_paired_dataset", "planned_independent_dataset",
      "independent_pilot_dataset", "registered_structural_control"
    ),
    Quantity = c(
      "raw_scale_mean", "dimensionless_dataset_mean",
      "dataset_component_normalized_MSE_underlying_reported_RMSE",
      "left_minus_right_dimensionless_dataset_loss",
      "planned_denominator_rate", "descriptive_feasibility_only",
      "exact_structural_outcome"
    ),
    Formula = c(
      "sd(z)/sqrt(n_available)", "sd(z)/sqrt(n_available)",
      "sd(dataset_component_MSE)/sqrt(n_available)",
      "sd(left_minus_right)/sqrt(n_complete_pairs)",
      "sqrt(p_hat*(1-p_hat)/400)", "report_count_and_rate_no_MC_gate",
      "exact_match_on_each_registered_control"
    ),
    MinimumUsableN = c(2L, 2L, 2L, 2L, 400L, 1L, 1L),
    PlannedN = c(rep(400L, 5L), 20L, 1L),
    MCSELimit = c(NA_real_, 0.05, 0.05, 0.05, 0.025, NA_real_, NA_real_),
    WorstCaseRateMCSE = c(
      rep(NA_real_, 4L), sqrt(0.25 / 400), NA_real_, NA_real_
    ),
    ZeroEventOneSided95Upper = c(
      rep(NA_real_, 4L), 1 - 0.05^(1 / 400), NA_real_, NA_real_
    ),
    PrecisionDecisionRule = c(
      "report_only_no_common_scale_cutoff",
      "MCSE_at_most_0.05_with_n_available_at_least_2",
      "MSE_MCSE_at_most_0.05_RMSE_has_no_separate_gate",
      "paired_MCSE_at_most_0.05_with_complete_pairs_at_least_2",
      "planned_n_400_guarantees_worst_case_MCSE_at_most_0.025",
      "descriptive_only_never_select_threshold_or_promote_recovery",
      "every_registered_structural_control_must_match_exactly"
    ),
    ShortfallAction = c(rep(
      "stop_and_create_new_prospective_plan_version_and_seed_band", 5L
    ),
      "stop_and_revise_feasibility_plan_without_opening_confirmation",
      "stop_structural_gate_no_backend_execution"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_boundary_metric_policy <- function() {
  data.frame(
    PolicyOrdinal = 1:9,
    PolicyId = c(
      "effective_rank", "absolute_boundary", "scaled_boundary",
      "residual_boundary", "no_psd_repair", "boundary_metric_availability",
      "zero_truth_relative_error", "false_ready",
      "scaled_cross_rule_false_ready_stress"
    ),
    Rule = c(
      "eigenvalue_gt_tolerance_times_max_1_and_lambda_max",
      "minimum_eigenvalue_le_boundary_tolerance",
      "rank_loss_under_relative_rule_is_boundary_even_if_absolute_cutoff_passes",
      "residual_variance_le_boundary_tolerance",
      "jitter_and_nearest_PSD_repair_are_prohibited",
      "regular_interior_readiness_is_not_required_to_compute_boundary_metrics",
      "ordinary_relative_error_is_unavailable_when_abs_truth_le_zero_tolerance",
      "point_gate_pass_on_boundary_or_structurally_blocked_truth",
      "c0_scaled_rank_boundary_may_not_trigger_b1_correlation_or_lme4_singularity_rule_and_is_not_an_automatic_hold"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_boundary_classification_registry <- function() {
  data.frame(
    Precedence = 1:4,
    EstimatedClass = c(
      "unavailable_non_psd_or_extraction_failure", "absolute_boundary",
      "scaled_relative_rank_boundary", "regular_interior"
    ),
    MatrixRule = c(
      "estimate_unavailable_or_min_eigenvalue_lt_minus_covariance_psd_tolerance",
      "minimum_eigenvalue_le_absolute_boundary_tolerance",
      "effective_rank_less_than_stratum_count_under_relative_rank_tolerance",
      "finite_PSD_and_neither_absolute_nor_scaled_boundary"
    ),
    ResidualRule = c(
      "estimate_unavailable_or_nonfinite_or_variance_lt_minus_covariance_psd_tolerance",
      "variance_le_absolute_boundary_tolerance",
      "not_applicable_to_scalar_residual",
      "finite_variance_greater_than_absolute_boundary_tolerance"
    ),
    PSDRepairAllowed = rep(FALSE, 4L),
    ClassificationAvailable = c(FALSE, TRUE, TRUE, TRUE),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_mechanical_tolerances <- function() {
  data.frame(
    ToleranceId = c(
      "covariance_psd", "absolute_boundary", "relative_rank",
      "relative_error_zero", "literal_matrix_comparison",
      "b1_correlation_distance_from_one", "b1_lme4_singular_fit"
    ),
    Value = c(1e-10, 1e-8, 1e-10, 1e-12, 1e-12, 1e-6, 1e-4),
    RuleScope = c(
      rep("c0_reference_and_metric", 5L), "b1_both_backends",
      "b1_lme4_only"
    ),
    Purpose = c(
      "reject_materially_indefinite_truth_or_estimate",
      "classify_absolute_component_or_residual_boundary",
      "effective_rank_eigenvalue_rule", "disable_division_by_zero_truth",
      "deterministic_factor_and_matrix_identity",
      "classify_absolute_correlation_at_least_one_minus_tolerance",
      "lme4_isSingular_tolerance"
    ),
    AccuracyAcceptanceThreshold = rep(FALSE, 7L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_recovery_threshold_registry <- function() {
  data.frame(
    ThresholdOrdinal = 1:6,
    CriterionId = c(
      "coordinate_accuracy", "component_rmse", "total_k_accuracy",
      "availability_rate", "false_ready_rate", "paired_method_difference"
    ),
    Direction = c("at_most", "at_most", "at_most", "at_least", "at_most",
                  "equivalence_or_difference_rule_pending"),
    AccuracyThreshold = rep(NA_real_, 6L),
    ThresholdStatus = rep("not_frozen_prospective_gate_required", 6L),
    PilotMaySelect = rep(FALSE, 6L),
    ConfirmationMaySelect = rep(FALSE, 6L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_execution_prerequisites <- function() {
  data.frame(
    PrerequisiteOrdinal = 1:8,
    PrerequisiteId = c(
      "external_freeze_receipt", "clean_source_identity",
      "all_four_matched_backends_qualified", "truth_blind_process_boundary",
      "lane_specific_authority", "candidate_completion_before_truth_release",
      "accuracy_threshold_before_confirmation", "no_diagnostic_override"
    ),
    Requirement = c(
      "independent_timestamped_anchor_binds_plan_source_tree_and_artifact_digest",
      "source_commit_and_tree_are_stable_and_reproducible",
      "lme4_and_glmmTMB_ML_and_REML_all_pass_matched_backend_gate",
      "candidate_executor_cannot_read_scenario_seed_reference_or_threshold_vault",
      "pilot_confirmation_and_negative_lanes_need_separate_authority",
      "every_planned_candidate_receipt_is_sealed_before_reference_join",
      "an_independent_prospective_gate_freezes_accuracy_criteria_without_using_any_pilot_or_confirmation_truth_fit_availability_or_recovery_outcome",
      "diagnostic_override_outputs_never_enter_evidence_denominators"
    ),
    CurrentSatisfied = rep(FALSE, 8L),
    PartialExecutionAllowed = rep(FALSE, 8L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_seed_for <- function(stage_id, scenario_ordinal, replicate,
                                policy) {
  row <- policy[policy$StageId == stage_id, , drop = FALSE]
  if (nrow(row) != 1L) stop("Seed stage identity is not unique.", call. = FALSE)
  if (identical(stage_id, "negative_control")) {
    return(as.integer(row$BaseSeed[[1L]] + scenario_ordinal))
  }
  as.integer(row$BaseSeed[[1L]] +
               row$ScenarioStride[[1L]] * scenario_ordinal + replicate)
}

mfrmr_gtvd_opaque_id <- function(namespace, payload) {
  paste0(namespace, "-", substr(mfrmr_gta_hash(payload), 1L, 24L))
}

mfrmr_gtvd_build_generation_manifest <- function(
    scenarios, structural_preflight, core_hash, seed_policy) {
  rows <- list(); cursor <- 0L
  for (scenario_index in seq_len(nrow(scenarios))) {
    scenario <- scenarios[scenario_index, , drop = FALSE]
    stages <- if (isTRUE(scenario$RecoveryExecutable[[1L]])) {
      list(pilot = scenario$PilotReplicates[[1L]],
           confirmation = scenario$ConfirmationReplicates[[1L]])
    } else {
      list(negative_control = scenario$NegativeControlReplicates[[1L]])
    }
    structural_hash <- structural_preflight$StructuralRowsHash[
      match(scenario$AssignmentId[[1L]], structural_preflight$AssignmentId)
    ]
    for (stage_id in names(stages)) {
      for (replicate in seq_len(stages[[stage_id]])) {
        cursor <- cursor + 1L
        dataset_id <- mfrmr_gtvd_opaque_id("D", list(
          Namespace = "gtheory_multivariate_dataset_draft85c1_v1",
          PlanCoreHash = core_hash,
          OpaqueScenarioToken = scenario$OpaqueScenarioToken[[1L]],
          StageNamespace = stage_id, Replicate = as.integer(replicate)
        ))
        rows[[cursor]] <- data.frame(
          DatasetOrdinal = as.integer(cursor),
          ScenarioOrdinal = scenario$ScenarioOrdinal,
          ScenarioId = scenario$ScenarioId,
          OpaqueDatasetId = dataset_id,
          StageId = stage_id,
          Replicate = as.integer(replicate),
          DataSeed = mfrmr_gtvd_seed_for(
            stage_id, scenario$ScenarioOrdinal[[1L]], replicate, seed_policy
          ),
          AssignmentId = scenario$AssignmentId,
          ReferenceId = scenario$ReferenceId,
          CoordinateLayoutId = scenario$CoordinateLayoutId,
          ExpectedPreFitState = scenario$ExpectedPreFitState,
          StructuralRowsHash = structural_hash,
          stringsAsFactors = FALSE
        )
      }
    }
  }
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtvd_build_candidate_manifest <- function(
    generation_manifest, method_registry, stratum_catalog, core_hash) {
  rows <- vector("list", nrow(generation_manifest))
  for (dataset_index in seq_len(nrow(generation_manifest))) {
    dataset <- generation_manifest[dataset_index, , drop = FALSE]
    coordinate_count <- stratum_catalog$DeclaredCoordinateCount[
      match(dataset$CoordinateLayoutId[[1L]],
            stratum_catalog$CoordinateLayoutId)
    ]
    method_rows <- lapply(seq_len(nrow(method_registry)), function(method_index) {
      method <- method_registry[method_index, , drop = FALSE]
      data.frame(
        DatasetOrdinal = dataset$DatasetOrdinal,
        OpaqueUnitId = mfrmr_gtvd_opaque_id("U", list(
          Namespace = "gtheory_multivariate_candidate_unit_draft85c1_v1",
          PlanCoreHash = core_hash,
          OpaqueDatasetId = dataset$OpaqueDatasetId,
          MethodId = method$MethodId
        )),
        OpaqueDatasetId = dataset$OpaqueDatasetId,
        StageId = dataset$StageId,
        MethodId = method$MethodId,
        MethodControlHash = method$MethodControlHash,
        CoordinateLayoutId = dataset$CoordinateLayoutId,
        CoordinateCount = as.integer(coordinate_count),
        stringsAsFactors = FALSE
      )
    })
    rows[[dataset_index]] <- do.call(rbind, method_rows)
  }
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output$UnitOrdinal <- seq_len(nrow(output))
  output <- output[c(
    "UnitOrdinal", "DatasetOrdinal", "OpaqueUnitId", "OpaqueDatasetId",
    "StageId", "MethodId", "MethodControlHash", "CoordinateLayoutId",
    "CoordinateCount"
  )]
  output$UnitOrdinal <- as.integer(output$UnitOrdinal)
  output
}

mfrmr_gtvd_build_pair_manifest <- function(candidate_manifest, pair_registry,
                                            core_hash) {
  dataset_ordinals <- unique(candidate_manifest$DatasetOrdinal)
  candidate_key <- paste(
    candidate_manifest$DatasetOrdinal, candidate_manifest$MethodId,
    sep = "\036"
  )
  if (anyDuplicated(candidate_key)) {
    stop("Candidate method identities are not unique within dataset.",
         call. = FALSE)
  }
  rows <- lapply(seq_len(nrow(pair_registry)), function(pair_index) {
    pair <- pair_registry[pair_index, , drop = FALSE]
    left <- candidate_manifest[match(
      paste(dataset_ordinals, pair$LeftMethodId, sep = "\036"), candidate_key
    ), , drop = FALSE]
    right <- candidate_manifest[match(
      paste(dataset_ordinals, pair$RightMethodId, sep = "\036"), candidate_key
    ), , drop = FALSE]
    if (anyNA(left$OpaqueUnitId) || anyNA(right$OpaqueUnitId) ||
        !identical(left$OpaqueDatasetId, right$OpaqueDatasetId) ||
        !identical(left$StageId, right$StageId) ||
        !identical(left$CoordinateLayoutId, right$CoordinateLayoutId) ||
        !identical(left$CoordinateCount, right$CoordinateCount)) {
      stop("A registered paired-method unit is incomplete or misbound.",
           call. = FALSE)
    }
    data.frame(
      DatasetOrdinal = as.integer(dataset_ordinals),
      OpaquePairUnitId = vapply(seq_along(dataset_ordinals), function(index) {
        mfrmr_gtvd_opaque_id("P", list(
          Namespace = "gtheory_multivariate_pair_unit_draft85c1_v1",
          PlanCoreHash = core_hash,
          OpaqueDatasetId = left$OpaqueDatasetId[[index]],
          PairId = pair$PairId[[1L]]
        ))
      }, character(1L)),
      OpaqueDatasetId = left$OpaqueDatasetId,
      StageId = left$StageId,
      PairId = pair$PairId[[1L]],
      LeftMethodId = pair$LeftMethodId[[1L]],
      RightMethodId = pair$RightMethodId[[1L]],
      LeftOpaqueUnitId = left$OpaqueUnitId,
      RightOpaqueUnitId = right$OpaqueUnitId,
      CoordinateLayoutId = left$CoordinateLayoutId,
      CoordinateCount = left$CoordinateCount,
      InputCoordinateMetricId = pair$InputCoordinateMetricId[[1L]],
      DatasetLossReductionId = pair$DatasetLossReductionId[[1L]],
      PairedOutputMetricId = pair$PairedOutputMetricId[[1L]],
      PairAvailabilityMetricId = pair$PairAvailabilityMetricId[[1L]],
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  output <- output[order(
    output$DatasetOrdinal,
    match(output$PairId, pair_registry$PairId), method = "radix"
  ), , drop = FALSE]
  row.names(output) <- NULL
  output$PairUnitOrdinal <- as.integer(seq_len(nrow(output)))
  output <- output[c(
    "PairUnitOrdinal", "DatasetOrdinal", "OpaquePairUnitId",
    "OpaqueDatasetId", "StageId", "PairId", "LeftMethodId",
    "RightMethodId", "LeftOpaqueUnitId", "RightOpaqueUnitId",
    "CoordinateLayoutId", "CoordinateCount", "InputCoordinateMetricId",
    "DatasetLossReductionId", "PairedOutputMetricId",
    "PairAvailabilityMetricId"
  )]
  output
}

mfrmr_gtvd_reference_join_map <- function(generation_manifest,
                                           scenarios) {
  position <- match(generation_manifest$ScenarioId, scenarios$ScenarioId)
  output <- data.frame(
    DatasetOrdinal = generation_manifest$DatasetOrdinal,
    OpaqueDatasetId = generation_manifest$OpaqueDatasetId,
    ScenarioId = generation_manifest$ScenarioId,
    ReferenceId = generation_manifest$ReferenceId,
    BoundaryClass = scenarios$ScenarioClass[position],
    ExpectedPreFitState = generation_manifest$ExpectedPreFitState,
    stringsAsFactors = FALSE
  )
  row.names(output) <- NULL
  output
}

mfrmr_gtvd_expected_counts <- function(generation_manifest,
                                       candidate_manifest, pair_manifest) {
  pilot_datasets <- sum(generation_manifest$StageId == "pilot")
  confirmation_datasets <- sum(generation_manifest$StageId == "confirmation")
  negative_datasets <- sum(generation_manifest$StageId == "negative_control")
  pilot_rows <- sum(candidate_manifest$StageId == "pilot")
  confirmation_rows <- sum(candidate_manifest$StageId == "confirmation")
  negative_rows <- sum(candidate_manifest$StageId == "negative_control")
  pilot_pairs <- sum(pair_manifest$StageId == "pilot")
  confirmation_pairs <- sum(pair_manifest$StageId == "confirmation")
  negative_pairs <- sum(pair_manifest$StageId == "negative_control")
  data.frame(
    PilotDatasets = as.integer(pilot_datasets),
    PilotAtomicMethodRows = as.integer(pilot_rows),
    ConfirmationDatasets = as.integer(confirmation_datasets),
    ConfirmationAtomicMethodRows = as.integer(confirmation_rows),
    NegativeControlDatasets = as.integer(negative_datasets),
    NegativeControlAtomicMethodRows = as.integer(negative_rows),
    PilotPairedRows = as.integer(pilot_pairs),
    ConfirmationPairedRows = as.integer(confirmation_pairs),
    NegativeControlPairedRows = as.integer(negative_pairs),
    TotalDatasets = as.integer(nrow(generation_manifest)),
    TotalAtomicMethodRows = as.integer(nrow(candidate_manifest)),
    TotalPairedRows = as.integer(nrow(pair_manifest)),
    TotalCoordinateRows = as.integer(sum(candidate_manifest$CoordinateCount)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_implementation_identity <- function() {
  c1_functions <- c(
    "mfrmr_gtvd_require_primitives", "mfrmr_gtvd_exact_object",
    "mfrmr_gtvd_function_hash", "mfrmr_gtvd_plan_payload_fields",
    "mfrmr_gtvd_plan_suffix_fields", "mfrmr_gtvd_stratum_catalog",
    "mfrmr_gtvd_component_catalog", "mfrmr_gtvd_aim_catalog",
    "mfrmr_gtvd_exclusion_registry", "mfrmr_gtvd_assignment_catalog",
    "mfrmr_gtvd_scenario_registry", "mfrmr_gtvd_expand_membership",
    "mfrmr_gtvd_assignment_rows", "mfrmr_gtvd_coordinate_layouts",
    "mfrmr_gtvd_pair_overlap", "mfrmr_gtvd_structural_rank",
    "mfrmr_gtvd_structural_preflight", "mfrmr_gtvd_c0_structural_design",
    "mfrmr_gtvd_c0_derivative_replay", "mfrmr_gtvd_interior_matrices",
    "mfrmr_gtvd_reference_bundle", "mfrmr_gtvd_fixed_mean_registry",
    "mfrmr_gtvd_method_registry", "mfrmr_gtvd_pair_registry",
    "mfrmr_gtvd_pair_state_algebra", "mfrmr_gtvd_metric_registry",
    "mfrmr_gtvd_metric_normalization_policy",
    "mfrmr_gtvd_metric_applicability_registry",
    "mfrmr_gtvd_metric_availability_target_registry",
    "mfrmr_gtvd_failure_taxonomy", "mfrmr_gtvd_candidate_state_algebra",
    "mfrmr_gtvd_receipt_mapping_registry", "mfrmr_gtvd_stage_catalog",
    "mfrmr_gtvd_denominator_rules", "mfrmr_gtvd_seed_partition_policy",
    "mfrmr_gtvd_monte_carlo_precision_policy",
    "mfrmr_gtvd_boundary_metric_policy",
    "mfrmr_gtvd_boundary_classification_registry",
    "mfrmr_gtvd_mechanical_tolerances",
    "mfrmr_gtvd_recovery_threshold_registry",
    "mfrmr_gtvd_execution_prerequisites", "mfrmr_gtvd_seed_for",
    "mfrmr_gtvd_opaque_id", "mfrmr_gtvd_build_generation_manifest",
    "mfrmr_gtvd_build_candidate_manifest", "mfrmr_gtvd_build_pair_manifest",
    "mfrmr_gtvd_reference_join_map", "mfrmr_gtvd_expected_counts",
    "mfrmr_gtvd_implementation_identity",
    "mfrmr_gtvd_plan_payload_uncached", "mfrmr_gtvd_plan_payload",
    "mfrmr_gtvd_plan", "mfrmr_gtvd_assert_plan",
    "mfrmr_gtvd_freeze_receipt_template",
    "mfrmr_gtvd_assert_freeze_receipt_template",
    "mfrmr_gtvd_candidate_handoff_preview", "mfrmr_gtvd_assert_handoff_preview"
  )
  c0_functions <- c(
    "mfrmr_gtvc_require_primitives", "mfrmr_gtvc_exact_object",
    "mfrmr_gtvc_exact_matrix", "mfrmr_gtvc_design_fields",
    "mfrmr_gtvc_bridge_extension_fields", "mfrmr_gtvc_tolerance",
    "mfrmr_gtvc_codes", "mfrmr_gtvc_neutral_design",
    "mfrmr_gtvc_assert_design", "mfrmr_gtvc_matrix_audit",
    "mfrmr_gtvc_covariance_spec", "mfrmr_gtvc_assert_covariance",
    "mfrmr_gtvc_build_k_pairwise", "mfrmr_gtvc_build_k_z",
    "mfrmr_gtvc_dual_k", "mfrmr_gtvc_coordinate_layout",
    "mfrmr_gtvc_derivative_design", "mfrmr_gtvc_assert_derivative",
    "mfrmr_gtvc_pack_covariance", "mfrmr_gtvc_unpack_covariance",
    "mfrmr_gtvc_population_projection", "mfrmr_gtvc_linear_algebra",
    "mfrmr_gtvc_loglik", "mfrmr_gtvc_expected_information",
    "mfrmr_gtvc_score", "mfrmr_gtvc_core_audit", "mfrmr_gtvc_bridge_gtvb",
    "mfrmr_gtvc_assert_bridge", "mfrmr_gtvc_covariance_from_gtvb",
    "mfrmr_gtvc_compare_fit", "mfrmr_gtvc_candidate_stage_valid",
    "mfrmr_gtvc_candidate_receipt", "mfrmr_gtvc_assert_candidate_receipt",
    "mfrmr_gtvc_join_reference", "mfrmr_gtvc_denominator_audit"
  )
  b1_functions <- c(
    "mfrmr_gtvb_require_primitives", "mfrmr_gtvb_tolerance",
    "mfrmr_gtvb_function_hash", "mfrmr_gtvb_spec_payload_fields",
    "mfrmr_gtvb_fit_payload_fields", "mfrmr_gtvb_exact_object",
    "mfrmr_gtvb_split_members", "mfrmr_gtvb_component_map",
    "mfrmr_gtvb_bind_incidence", "mfrmr_gtvb_effective_member",
    "mfrmr_gtvb_key", "mfrmr_gtvb_group_audit",
    "mfrmr_gtvb_observation_audit", "mfrmr_gtvb_formula",
    "mfrmr_gtvb_backend_binding", "mfrmr_gtvb_covariance_design_audit",
    "mfrmr_gtvb_spec", "mfrmr_gtvb_assert_fit_spec",
    "mfrmr_gtvb_glmmtmb_abi", "mfrmr_gtvb_normalize_matrix",
    "mfrmr_gtvb_extract_covariances", "mfrmr_gtvb_covariance_audit",
    "mfrmr_gtvb_backend_rows_match", "mfrmr_gtvb_lme4_diagnostics",
    "mfrmr_gtvb_glmmtmb_diagnostics", "mfrmr_gtvb_finalize_fit",
    "mfrmr_gtvb_assert_fit_integrity", "mfrmr_gtvb_fit_lme4",
    "mfrmr_gtvb_compare", "mfrmr_gtvb_fit_glmmtmb"
  )
  incidence_functions <- c(
    "mfrmr_gtvi_require_primitives", "mfrmr_gtvi_column",
    "mfrmr_gtvi_positive_integer", "mfrmr_gtvi_ordered_strata",
    "mfrmr_gtvi_condition_scope", "mfrmr_gtvi_score_token",
    "mfrmr_gtvi_components", "mfrmr_gtvi_prepare",
    "mfrmr_gtvi_stratum_audit", "mfrmr_gtvi_object_incidence",
    "mfrmr_gtvi_object_patterns", "mfrmr_gtvi_object_pairs",
    "mfrmr_gtvi_stratum_graph", "mfrmr_gtvi_condition_pairs",
    "mfrmr_gtvi_audit"
  )
  algebra_functions <- c(
    "mfrmr_gtv_require_primitives", "mfrmr_gtv_tolerance",
    "mfrmr_gtv_strata", "mfrmr_gtv_matrix_audit"
  )
  primitive_functions <- "mfrmr_gta_hash"
  function_names <- c(
    c1_functions, c0_functions, b1_functions, incidence_functions,
    algebra_functions, primitive_functions
  )
  layer <- c(
    rep("Draft85c1", length(c1_functions)),
    rep("Draft85c0", length(c0_functions)),
    rep("Draft85b1", length(b1_functions)),
    rep("Draft85a0", length(incidence_functions)),
    rep("Draft85b0", length(algebra_functions)),
    rep("Draft81", length(primitive_functions))
  )
  environment <- environment(mfrmr_gtvd_implementation_identity)
  data.frame(
    Layer = layer, FunctionName = function_names,
    FunctionHash = vapply(function_names, function(name) {
      mfrmr_gtvd_function_hash(get(name, envir = environment, inherits = TRUE))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvd_plan_payload_uncached <- function() {
  mfrmr_gtvd_require_primitives()
  stratum_catalog <- mfrmr_gtvd_stratum_catalog()
  component_catalog <- mfrmr_gtvd_component_catalog()
  aim_catalog <- mfrmr_gtvd_aim_catalog()
  exclusions <- mfrmr_gtvd_exclusion_registry()
  assignments <- mfrmr_gtvd_assignment_catalog()
  scenarios <- mfrmr_gtvd_scenario_registry()
  layouts <- mfrmr_gtvd_coordinate_layouts()
  structural <- mfrmr_gtvd_structural_preflight(scenarios)
  c0_derivative_replay <- mfrmr_gtvd_c0_derivative_replay(structural)
  references <- mfrmr_gtvd_reference_bundle(layouts)
  fixed_means <- mfrmr_gtvd_fixed_mean_registry()
  methods <- mfrmr_gtvd_method_registry()
  pairs <- mfrmr_gtvd_pair_registry()
  pair_states <- mfrmr_gtvd_pair_state_algebra()
  metrics <- mfrmr_gtvd_metric_registry()
  normalization <- mfrmr_gtvd_metric_normalization_policy()
  failures <- mfrmr_gtvd_failure_taxonomy()
  state_algebra <- mfrmr_gtvd_candidate_state_algebra()
  receipt_mapping <- mfrmr_gtvd_receipt_mapping_registry()
  stages <- mfrmr_gtvd_stage_catalog()
  applicability <- mfrmr_gtvd_metric_applicability_registry(
    scenarios, metrics
  )
  availability_targets <- mfrmr_gtvd_metric_availability_target_registry(
    scenarios, metrics
  )
  denominator_rules <- mfrmr_gtvd_denominator_rules()
  seed_policy <- mfrmr_gtvd_seed_partition_policy()
  mc_policy <- mfrmr_gtvd_monte_carlo_precision_policy()
  boundary_policy <- mfrmr_gtvd_boundary_metric_policy()
  boundary_classification <- mfrmr_gtvd_boundary_classification_registry()
  tolerances <- mfrmr_gtvd_mechanical_tolerances()
  thresholds <- mfrmr_gtvd_recovery_threshold_registry()
  prerequisites <- mfrmr_gtvd_execution_prerequisites()
  estimand <- list(
    ResponseModel = "Gaussian_identity_observed_score",
    FixedMeans = "stratum_specific_no_intercept",
    RandomComponents = c("Object", "Rater", "Object:Rater"),
    RandomComponentScope = "global_unstructured_stratum_covariance",
    Residual = "one_common_scalar_independent_across_rows",
    CoordinateOrder = "vech_Object_then_vech_Rater_then_vech_Object:Rater_then_Residual",
    TwoStratumCoordinateCount = 10L,
    ThreeStratumCoordinateCount = 19L,
    StructuralAbsence = "rows_not_generated_not_missing_responses"
  )
  core <- list(
    Contract = "gtheory_multivariate_ademp_plan_draft85c1_v1",
    PlanId = "MFRMR-GT-MV-DRAFT85C1-20260824",
    PlanVersion = "1.0.0",
    ADEMPEstimand = estimand,
    StratumCatalog = stratum_catalog,
    ComponentCatalog = component_catalog,
    AimCatalog = aim_catalog,
    ExclusionRegistry = exclusions,
    AssignmentCatalog = assignments,
    ScenarioRegistry = scenarios,
    StructuralDesignPreflight = structural,
    C0DerivativeReplayRegistry = c0_derivative_replay,
    ReferenceCatalog = references$Catalog,
    ReferenceCoordinateRegistry = references$Coordinates,
    ReferenceFactorRegistry = references$Factors,
    ReferenceComponentAudit = references$Audits,
    ReferenceBoundaryClassRegistry = references$BoundaryClasses,
    FixedMeanRegistry = fixed_means,
    MethodRegistry = methods,
    PairRegistry = pairs,
    PairStateAlgebra = pair_states,
    MetricRegistry = metrics,
    MetricNormalizationPolicy = normalization,
    MetricApplicabilityRegistry = applicability,
    MetricAvailabilityTargetRegistry = availability_targets,
    BoundaryClassificationRegistry = boundary_classification,
    FailureTaxonomy = failures,
    CandidateStateAlgebra = state_algebra,
    ReceiptMappingRegistry = receipt_mapping,
    StageCatalog = stages,
    DenominatorRules = denominator_rules,
    SeedPartitionPolicy = seed_policy,
    MonteCarloPrecisionPolicy = mc_policy,
    BoundaryMetricPolicy = boundary_policy,
    MechanicalToleranceRegistry = tolerances,
    RecoveryThresholdRegistry = thresholds,
    ExecutionPrerequisiteRegistry = prerequisites,
    CoordinateLayouts = layouts
  )
  core_hash <- mfrmr_gta_hash(core)
  implementation <- mfrmr_gtvd_implementation_identity()
  generation <- mfrmr_gtvd_build_generation_manifest(
    scenarios, structural, core_hash, seed_policy
  )
  candidate <- mfrmr_gtvd_build_candidate_manifest(
    generation, methods, stratum_catalog, core_hash
  )
  pair_manifest <- mfrmr_gtvd_build_pair_manifest(candidate, pairs, core_hash)
  reference_join <- mfrmr_gtvd_reference_join_map(generation, scenarios)
  expected_counts <- mfrmr_gtvd_expected_counts(
    generation, candidate, pair_manifest
  )
  payload <- c(core, list(
    GenerationManifest = generation,
    CandidateUnitManifest = candidate,
    PairUnitManifest = pair_manifest,
    ReferenceJoinMap = reference_join,
    ExpectedCounts = expected_counts,
    ImplementationIdentity = implementation,
    ImplementationIdentityHash = mfrmr_gta_hash(implementation),
    C0DerivativeReplayHash = mfrmr_gta_hash(c0_derivative_replay),
    ReferenceRegistryHash = mfrmr_gta_hash(list(
      Catalog = references$Catalog, Coordinates = references$Coordinates,
      Factors = references$Factors, Audits = references$Audits,
      BoundaryClasses = references$BoundaryClasses, FixedMeans = fixed_means
    )),
    ScenarioRegistryHash = mfrmr_gta_hash(scenarios),
    StructuralPreflightHash = mfrmr_gta_hash(structural),
    MethodRegistryHash = mfrmr_gta_hash(methods),
    PairRegistryHash = mfrmr_gta_hash(pairs),
    MetricRegistryHash = mfrmr_gta_hash(metrics),
    MetricApplicabilityRegistryHash = mfrmr_gta_hash(applicability),
    MetricAvailabilityTargetRegistryHash =
      mfrmr_gta_hash(availability_targets),
    PlanCoreHash = core_hash,
    GenerationManifestHash = mfrmr_gta_hash(generation),
    CandidateUnitManifestHash = mfrmr_gta_hash(candidate),
    PairUnitManifestHash = mfrmr_gta_hash(pair_manifest),
    ReferenceJoinMapHash = mfrmr_gta_hash(reference_join),
    SeedPartitionContentHash = mfrmr_gta_hash(
      generation[c("OpaqueDatasetId", "StageId", "Replicate", "DataSeed")]
    )
  ))
  if (!identical(names(payload), mfrmr_gtvd_plan_payload_fields())) {
    stop("The Draft.85c1 plan payload field registry drifted.", call. = FALSE)
  }
  payload
}

# Canonical replay is intentionally uncached. A mutable closure cache could be
# replaced through its exposed function environment and then become a forged
# validation reference. Structural-rank discovery is reduced to the observed
# equality-signature set, so full replay remains inexpensive enough to run on
# every integrity assertion.
mfrmr_gtvd_plan_payload <- function() {
  mfrmr_gtvd_plan_payload_uncached()
}

mfrmr_gtvd_plan <- function() {
  payload <- mfrmr_gtvd_plan_payload()
  counts <- payload$ExpectedCounts[1L, , drop = FALSE]
  structure(c(payload, list(
    PlanHash = mfrmr_gta_hash(payload),
    PlanPayloadFields = names(payload),
    ScenarioCount = as.integer(nrow(payload$ScenarioRegistry)),
    ExecutableScenarioCount = as.integer(sum(
      payload$ScenarioRegistry$RecoveryExecutable
    )),
    NegativeControlCount = as.integer(sum(
      !payload$ScenarioRegistry$RecoveryExecutable
    )),
    PlannedDatasetCount = counts$TotalDatasets[[1L]],
    PlannedAtomicMethodRows = counts$TotalAtomicMethodRows[[1L]],
    PlannedPairedRows = counts$TotalPairedRows[[1L]],
    PlannedCoordinateRows = counts$TotalCoordinateRows[[1L]],
    PlanContentSealed = TRUE,
    ADEMPRegistryContentSealed = TRUE,
    MetricDefinitionsContentSealed = TRUE,
    SeedPartitionContentSealed = TRUE,
    AtomicManifestDenominatorPlanReady = TRUE,
    MetricDenominatorRoutingReady = TRUE,
    MonteCarloPrecisionPlanReady = TRUE,
    CandidateHandoffColumnAllowlistReady = TRUE,
    ReceiptTupleCatalogReady = TRUE,
    ExternalFreezeReceiptRequired = TRUE,
    PreOutcomeFreezeExternallyAnchored = FALSE,
    RecoveryDesignFrozen = FALSE,
    RecoveryThresholdFrozen = FALSE,
    TruthBlindExecutionBoundaryReady = FALSE,
    BackendQualificationReady = FALSE,
    PilotExecutionAuthorized = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    CandidateCompletionSealed = FALSE,
    TruthReleaseAuthorized = FALSE,
    DenominatorAccountingReady = FALSE,
    PilotEvaluationComplete = FALSE,
    DecisionRuleFrozen = FALSE,
    ConfirmationIsolationReady = FALSE,
    GeneratorImplementationReady = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimatorRecoveryReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    UncertaintyReady = FALSE,
    CoefficientEligible = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvd_plan", "list"))
}

mfrmr_gtvd_assert_plan <- function(plan) {
  payload_fields <- mfrmr_gtvd_plan_payload_fields()
  suffix_fields <- mfrmr_gtvd_plan_suffix_fields()
  if (!mfrmr_gtvd_exact_object(
    plan, c(payload_fields, suffix_fields), c("mfrmr_gtvd_plan", "list")
  ) || !identical(plan$PlanPayloadFields, payload_fields)) {
    stop("A canonical sealed Draft.85c1 plan is required.", call. = FALSE)
  }
  core_fields <- payload_fields[
    seq_len(match("CoordinateLayouts", payload_fields))
  ]
  actual_core <- unclass(plan[core_fields])
  actual_reference <- list(
    Catalog = plan$ReferenceCatalog,
    Coordinates = plan$ReferenceCoordinateRegistry,
    Factors = plan$ReferenceFactorRegistry,
    Audits = plan$ReferenceComponentAudit,
    BoundaryClasses = plan$ReferenceBoundaryClassRegistry,
    FixedMeans = plan$FixedMeanRegistry
  )
  exact_hashes <-
    identical(plan$PlanHash, mfrmr_gta_hash(plan[payload_fields])) &&
    identical(plan$ImplementationIdentity,
              mfrmr_gtvd_implementation_identity()) &&
    identical(plan$ImplementationIdentityHash,
              mfrmr_gta_hash(plan$ImplementationIdentity)) &&
    identical(plan$C0DerivativeReplayHash,
              mfrmr_gta_hash(plan$C0DerivativeReplayRegistry)) &&
    identical(plan$ReferenceRegistryHash, mfrmr_gta_hash(actual_reference)) &&
    identical(plan$ScenarioRegistryHash,
              mfrmr_gta_hash(plan$ScenarioRegistry)) &&
    identical(plan$StructuralPreflightHash,
              mfrmr_gta_hash(plan$StructuralDesignPreflight)) &&
    identical(plan$MethodRegistryHash, mfrmr_gta_hash(plan$MethodRegistry)) &&
    identical(plan$PairRegistryHash, mfrmr_gta_hash(plan$PairRegistry)) &&
    identical(plan$MetricRegistryHash, mfrmr_gta_hash(plan$MetricRegistry)) &&
    identical(plan$MetricApplicabilityRegistryHash,
              mfrmr_gta_hash(plan$MetricApplicabilityRegistry)) &&
    identical(plan$MetricAvailabilityTargetRegistryHash,
              mfrmr_gta_hash(plan$MetricAvailabilityTargetRegistry)) &&
    identical(plan$PlanCoreHash, mfrmr_gta_hash(actual_core)) &&
    identical(plan$GenerationManifestHash,
              mfrmr_gta_hash(plan$GenerationManifest)) &&
    identical(plan$CandidateUnitManifestHash,
              mfrmr_gta_hash(plan$CandidateUnitManifest)) &&
    identical(plan$PairUnitManifestHash,
              mfrmr_gta_hash(plan$PairUnitManifest)) &&
    identical(plan$ReferenceJoinMapHash,
              mfrmr_gta_hash(plan$ReferenceJoinMap)) &&
    identical(plan$SeedPartitionContentHash, mfrmr_gta_hash(
      plan$GenerationManifest[
        c("OpaqueDatasetId", "StageId", "Replicate", "DataSeed")
      ]
    ))
  # These literal roots cover the prospective design and every generated
  # manifest. Unlike a closure cache, they cannot be replaced by assigning a
  # forged payload in this function's environment. Implementation identity is
  # intentionally replayed rather than included in the content-only core.
  canonical_hashes <- c(
    PlanCoreHash =
      "c61ddfcf59dec2e169079ad0d9a35ff8281925c105d426919180553794f368b2",
    C0DerivativeReplayHash =
      "ea0bb6a779813a2da68dc174740d11dc436fba81b4f96609a7083661316cd966",
    ReferenceRegistryHash =
      "e0b9918b914eea0bf892bac82982bc9f48c965a0e903292295c40761e4683029",
    ScenarioRegistryHash =
      "62caac834b73b7639a8e03762dbb367d476bbea090efd2af1e4ea0510dfc4ae4",
    StructuralPreflightHash =
      "22ce4e5a8609247de4cb92a5c449d85d09afc250c32ead0e940de369a25ed957",
    MethodRegistryHash =
      "d59f6e4471ec9c0e14320a33ab501c12b7b3974f8f1de5bdc2c0e0f46dea9059",
    PairRegistryHash =
      "6134ec03047df0ef2b8f2b135cdec2959cae69959798e6ef30d60c00d25ecd55",
    MetricRegistryHash =
      "e7bf3d3f35d1866ad2975195e2ea505d80b835f83f117647cc67983756ac15cb",
    MetricApplicabilityRegistryHash =
      "5a8b57a7599ed4012ddc3745869ee3300edda25f6ece12900619d87b46e113b9",
    MetricAvailabilityTargetRegistryHash =
      "0c1a9f3f7b760d8760f4ac582b672c977741643959de8dfca43ed0aecd842588",
    GenerationManifestHash =
      "5c33571ea73e4f4dddfa7e7ada1c6d2371dfb6465f748b1ed68bc16dcf1dd2a6",
    CandidateUnitManifestHash =
      "fd50018230259104f79fe6b59e4dc37e7b3d0da8c7f848b2463891f79ddd07f9",
    PairUnitManifestHash =
      "904f99c73809fc8cf87c70ea6c1761cbee8e8872cbff8eac170215d027aa8a3b",
    ReferenceJoinMapHash =
      "dafd56133fa411398037746ff103bb86ff42ef817c113fe2fdc7b105bd796f6c",
    SeedPartitionContentHash =
      "7c39c3554cc144613c837d7825447870a17afd4039034a2fc63e4e1eec1c72ee"
  )
  exact_canonical_hashes <- all(vapply(
    names(canonical_hashes), function(name) {
      identical(plan[[name]], unname(canonical_hashes[[name]]))
    }, logical(1L)
  ))
  state <- c(
    PlanContentSealed = TRUE,
    ADEMPRegistryContentSealed = TRUE,
    MetricDefinitionsContentSealed = TRUE,
    SeedPartitionContentSealed = TRUE,
    AtomicManifestDenominatorPlanReady = TRUE,
    MetricDenominatorRoutingReady = TRUE,
    MonteCarloPrecisionPlanReady = TRUE,
    CandidateHandoffColumnAllowlistReady = TRUE,
    ReceiptTupleCatalogReady = TRUE,
    ExternalFreezeReceiptRequired = TRUE,
    PreOutcomeFreezeExternallyAnchored = FALSE,
    RecoveryDesignFrozen = FALSE,
    RecoveryThresholdFrozen = FALSE,
    TruthBlindExecutionBoundaryReady = FALSE,
    BackendQualificationReady = FALSE,
    PilotExecutionAuthorized = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    CandidateCompletionSealed = FALSE,
    TruthReleaseAuthorized = FALSE,
    DenominatorAccountingReady = FALSE,
    PilotEvaluationComplete = FALSE,
    DecisionRuleFrozen = FALSE,
    ConfirmationIsolationReady = FALSE,
    GeneratorImplementationReady = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimatorRecoveryReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    UncertaintyReady = FALSE,
    CoefficientEligible = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )
  exact_state <- all(vapply(names(state), function(name) {
    identical(plan[[name]], unname(state[[name]]))
  }, logical(1L)))
  expected_counts <- data.frame(
    PilotDatasets = 240L, PilotAtomicMethodRows = 960L,
    ConfirmationDatasets = 4800L,
    ConfirmationAtomicMethodRows = 19200L,
    NegativeControlDatasets = 2L,
    NegativeControlAtomicMethodRows = 8L,
    PilotPairedRows = 960L, ConfirmationPairedRows = 19200L,
    NegativeControlPairedRows = 8L,
    TotalDatasets = 5042L, TotalAtomicMethodRows = 20168L,
    TotalPairedRows = 20168L, TotalCoordinateRows = 292436L,
    stringsAsFactors = FALSE
  )
  exact_counts <-
    identical(plan$ExpectedCounts, expected_counts) &&
    identical(plan$ScenarioCount, 14L) &&
    identical(plan$ExecutableScenarioCount, 12L) &&
    identical(plan$NegativeControlCount, 2L) &&
    identical(plan$PlannedDatasetCount,
              expected_counts$TotalDatasets[[1L]]) &&
    identical(plan$PlannedAtomicMethodRows,
              expected_counts$TotalAtomicMethodRows[[1L]]) &&
    identical(plan$PlannedPairedRows,
              expected_counts$TotalPairedRows[[1L]]) &&
    identical(plan$PlannedCoordinateRows,
              expected_counts$TotalCoordinateRows[[1L]])
  if (!exact_hashes || !exact_canonical_hashes || !exact_state ||
      !exact_counts) {
    stop("The Draft.85c1 plan content, identity, or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvd_freeze_receipt_template <- function(plan) {
  mfrmr_gtvd_assert_plan(plan)
  payload <- list(
    Contract = "gtheory_multivariate_external_freeze_receipt_template_draft85c1_v1",
    PlanHash = plan$PlanHash,
    PlanCoreHash = plan$PlanCoreHash,
    SourceCommit = NA_character_,
    SourceTreeHash = NA_character_,
    ArtifactSHA256 = NA_character_,
    UTCFreezeTimestamp = NA_character_,
    SignerOrAuthorityId = NA_character_,
    ExternalRecordId = NA_character_,
    ExternalAnchorProvider = NA_character_,
    ExternalAnchorReference = NA_character_
  )
  structure(c(payload, list(
    TemplateHash = mfrmr_gta_hash(payload),
    FreezeReceiptReady = FALSE,
    PreOutcomeFreezeExternallyAnchored = FALSE,
    RecoveryDesignFrozen = FALSE,
    PilotExecutionAuthorized = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvd_freeze_template", "list"))
}

mfrmr_gtvd_assert_freeze_receipt_template <- function(plan, template) {
  mfrmr_gtvd_assert_plan(plan)
  payload_fields <- c(
    "Contract", "PlanHash", "PlanCoreHash", "SourceCommit",
    "SourceTreeHash", "ArtifactSHA256", "UTCFreezeTimestamp",
    "SignerOrAuthorityId", "ExternalRecordId", "ExternalAnchorProvider",
    "ExternalAnchorReference"
  )
  suffix_fields <- c(
    "TemplateHash", "FreezeReceiptReady",
    "PreOutcomeFreezeExternallyAnchored", "RecoveryDesignFrozen",
    "PilotExecutionAuthorized", "ConfirmationExecutionAuthorized",
    "RecoveryExecuted", "RecoveryEvidenceReady", "InferenceReady",
    "DecisionReady", "PublicSupportReady"
  )
  if (!mfrmr_gtvd_exact_object(
    template, c(payload_fields, suffix_fields),
    c("mfrmr_gtvd_freeze_template", "list")
  ) || !identical(template, mfrmr_gtvd_freeze_receipt_template(plan))) {
    stop(
      "The Draft.85c1 external-freeze template or readiness was altered.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtvd_candidate_handoff_preview <- function(plan, stage_id) {
  mfrmr_gtvd_assert_plan(plan)
  stage_id <- as.character(stage_id)
  position <- match(stage_id, plan$StageCatalog$StageId)
  if (length(stage_id) != 1L || is.na(stage_id) || is.na(position)) {
    stop("`stage_id` must identify one frozen Draft.85c1 lane.", call. = FALSE)
  }
  root_units <- plan$CandidateUnitManifest[
    plan$CandidateUnitManifest$StageId == stage_id, , drop = FALSE
  ]
  units <- root_units[c(
    "OpaqueUnitId", "OpaqueDatasetId", "MethodId", "MethodControlHash",
    "CoordinateLayoutId", "CoordinateCount"
  )]
  row.names(units) <- NULL
  forbidden <- c(
    "ScenarioId", "ScenarioOrdinal", "OpaqueScenarioToken", "StageId",
    "Replicate", "DataSeed", "AssignmentId", "ReferenceId",
    "BoundaryClass", "ExpectedPreFitState", "StructuralRowsHash",
    "TruthValue", "GeneratingCovariance", "GeneratingFactor",
    "ReferenceCovarianceHash", "ReferenceFactorRegistry",
    "RecoveryThreshold"
  )
  forbidden_audit <- data.frame(
    ForbiddenField = forbidden,
    PresentInCandidateUnits = forbidden %in% names(units),
    stringsAsFactors = FALSE
  )
  lane_opaque_id <- plan$StageCatalog$LaneOpaqueId[[position]]
  payload <- list(
    Contract = "gtheory_multivariate_candidate_handoff_preview_draft85c1_v1",
    HandoffId = mfrmr_gtvd_opaque_id("H", list(
      Namespace = "gtheory_multivariate_handoff_preview_draft85c1_v1",
      PlanHash = plan$PlanHash, LaneOpaqueId = lane_opaque_id,
      CandidateUnitHash = mfrmr_gta_hash(units)
    )),
    LaneOpaqueId = lane_opaque_id,
    PlanHash = plan$PlanHash,
    CandidateUnits = units,
    CandidateUnitHash = mfrmr_gta_hash(units),
    ExpectedUnits = as.integer(nrow(units)),
    ForbiddenFieldAudit = forbidden_audit,
    DirectTruthColumnsPresent = any(
      forbidden_audit$PresentInCandidateUnits
    ),
    OtherLaneMaterialAbsent = identical(
      sort(unique(root_units$StageId)), stage_id
    )
  )
  structure(c(payload, list(
    HandoffPreviewHash = mfrmr_gta_hash(payload),
    CandidateColumnAllowlistReady = !payload$DirectTruthColumnsPresent &&
      payload$OtherLaneMaterialAbsent,
    PreOutcomeFreezeExternallyAnchored = FALSE,
    TruthBlindExecutionBoundaryReady = FALSE,
    ExecutionAuthorized = FALSE,
    CandidateExecutionOccurred = FALSE,
    CandidateCompletionSealed = FALSE,
    TruthReleaseAuthorized = FALSE,
    DenominatorAccountingReady = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvd_handoff_preview", "list"))
}

mfrmr_gtvd_assert_handoff_preview <- function(plan, handoff) {
  mfrmr_gtvd_assert_plan(plan)
  payload_fields <- c(
    "Contract", "HandoffId", "LaneOpaqueId", "PlanHash", "CandidateUnits",
    "CandidateUnitHash", "ExpectedUnits", "ForbiddenFieldAudit",
    "DirectTruthColumnsPresent", "OtherLaneMaterialAbsent"
  )
  suffix_fields <- c(
    "HandoffPreviewHash", "CandidateColumnAllowlistReady",
    "PreOutcomeFreezeExternallyAnchored", "TruthBlindExecutionBoundaryReady",
    "ExecutionAuthorized", "CandidateExecutionOccurred",
    "CandidateCompletionSealed", "TruthReleaseAuthorized",
    "DenominatorAccountingReady", "RecoveryExecuted", "RecoveryEvidenceReady",
    "EstimationReady", "InferenceReady", "DecisionReady", "PublicSupportReady"
  )
  if (!mfrmr_gtvd_exact_object(
    handoff, c(payload_fields, suffix_fields),
    c("mfrmr_gtvd_handoff_preview", "list")
  )) {
    stop("A canonical Draft.85c1 handoff preview is required.", call. = FALSE)
  }
  position <- match(handoff$LaneOpaqueId, plan$StageCatalog$LaneOpaqueId)
  if (is.na(position)) {
    stop("The handoff lane is not bound to the sealed plan.", call. = FALSE)
  }
  expected <- mfrmr_gtvd_candidate_handoff_preview(
    plan, plan$StageCatalog$StageId[[position]]
  )
  if (!identical(handoff, expected)) {
    stop("The Draft.85c1 handoff preview or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}
