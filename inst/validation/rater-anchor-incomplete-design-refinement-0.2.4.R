# McEwen-informed incomplete-rating-design refinement for mfrmr 0.2.4.
#
# Repository-only: this preserves the source design inventory and identifies
# evidence dimensions that are absent from the frozen 0.2.3 Rater-anchor
# prospective contract. It does not mutate that contract or authorize fits.

mfrmr_raid_specification <- "0.2.4-draft.1"
mfrmr_raid_contract <-
  "mfrmr_rater_anchor_incomplete_design_refinement_v1"

mfrmr_raid_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_raid_source_registry <- function() {
  data.frame(
    SourceId = "MCEWEN-2018-DISSERTATION",
    Author = "Mary R. McEwen",
    Title = paste(
      "The Effects of Incomplete Rating Designs on Results from",
      "Many-Facets-Rasch Model Analyses"
    ),
    Year = 2018L,
    SourceType = "doctoral_dissertation",
    Institution = "Brigham Young University",
    RepositorySeries = "All Theses and Dissertations",
    RepositoryNumber = "6689",
    RepositoryURL = "https://scholarsarchive.byu.edu/etd/6689",
    ZoteroItemKey = "5VIBC8I2",
    ZoteroAttachmentKey = "FQ3CGTFU",
    ZoteroCitationKey = "mcewenEffectsIncompleteRating",
    ObjectCount = 24L,
    RaterCount = 8L,
    IncompleteDesignCount = 20L,
    RaterOrderCount = 4L,
    IncompleteAnalysisCount = 80L,
    FullyCrossedReferenceAnalysisCount = 4L,
    TotalAnalysisCount = 84L,
    stringsAsFactors = FALSE
  )
}

mfrmr_raid_source_design_registry <- function() {
  design_id <- c(
    "8x8x.25-4",
    "4x8x.5-2", "4x8x.5-3", "4x8x.5-4",
    "6x8x.5-2", "6x8x.5-3", "6x8x.5-5", "6x8x.5-12",
    "8x8x.5-2", "8x8x.5-3", "8x8x.5-5", "8x8x.5-54",
    "8x8x.5-66", "8x8x.5-97",
    "8x8x.75-3", "8x8x.75-4",
    "StringOfPearls", "AllforOne", "OneforAll", "Wind6x8x.5"
  )
  coverage <- c(
    0.25,
    rep(0.50, 13L),
    0.75, 0.75,
    rep(NA_real_, 4L)
  )
  repetition_size <- c(
    8L,
    4L, 4L, 4L,
    6L, 6L, 6L, 6L,
    8L, 8L, 8L, 8L, 8L, 8L,
    8L, 8L,
    8L, 8L, 8L, 6L
  )
  structure <- c(
    "Ring",
    "Kite", "Box", "Trapezoids",
    "Kite", "Box", "Hexagon", "Fully-linked",
    "Kite", "Box", "Hexagon", "Unique", "Fully-linked",
    "Fully-linked", "Fully-linked", "Fully-linked",
    "String", "Common-rater bridge", "Common-object bridge",
    "Constant-rater bridge"
  )
  raters_per_object <- c(
    2L,
    rep(4L, 13L),
    6L, 6L,
    NA_integer_, 2L, NA_integer_, 4L
  )
  data.frame(
    DesignId = design_id,
    CoverageBalanced = c(rep(TRUE, 16L), rep(FALSE, 4L)),
    RaterCoverage = coverage,
    RatersPerObject = raters_per_object,
    RepetitionSize = repetition_size,
    Structure = structure,
    CriticalLinkLossStress = design_id == "StringOfPearls",
    BridgeType = c(
      rep("distributed", 16L),
      "minimal_chain", "one_common_rater", "common_objects_all_raters",
      "two_constant_raters"
    ),
    SourceCatalogOnly = TRUE,
    ExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_raid_rater_order_registry <- function() {
  data.frame(
    RaterOrderId = paste0("RO", 1:4),
    Permutation = c(
      "1;2;3;4;5;6;7;8",
      "5;7;4;8;3;1;6;2",
      "3;6;8;5;1;4;2;7",
      "7;8;2;4;6;3;5;1"
    ),
    Construction = c(
      "canonical",
      "column_and_neighbour_reassignment",
      "column_and_neighbour_reassignment",
      "fully_crossed_severity_order"
    ),
    UsesFullyCrossedSeverity = c(FALSE, FALSE, FALSE, TRUE),
    PairAcrossDesigns = TRUE,
    ExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_raid_requirement_registry <- function() {
  data.frame(
    RequirementId = c(
      "direct_anchor_link_separation",
      "rater_coverage_gradient",
      "cost_matched_link_structure",
      "repetition_size",
      "rater_assignment_order",
      "critical_link_loss",
      "asymmetric_bridge_direction",
      "dual_graph_projection",
      "relative_decision_metrics",
      "fully_crossed_reference_comparison"
    ),
    McEwenBasis = c(
      "Linking design and fixed Rater coordinates are different resources.",
      "Coverage had the largest and most consistent effect.",
      "Connected designs at equal coverage differed by link distribution.",
      "Repetition size changes link redundancy and direct-link breadth.",
      "Specific Rater assignment mattered most for sparse designs.",
      "The StringOfPearls perturbation removed one critical link.",
      "OneforAll and AllforOne test opposite bridge directions.",
      "Rater-centric and object-centric graphs reveal different weaknesses.",
      "Rank, top-n, and cut-score stability can diverge from recovery.",
      "Incomplete-design results require a fully crossed reference target."
    ),
    Current0_2_3Coverage = c(
      "supported",
      "missing",
      "missing",
      "missing",
      "missing",
      "missing",
      "partial",
      "missing",
      "partial",
      "partial"
    ),
    SuccessorDisposition = c(
      "retain_without_conflation",
      "add_coverage_ladder",
      "add_equal_cost_topology_pairs",
      "add_matched_repetition_contrast",
      "pair_all_selected_designs_by_order",
      "add_predeclared_edge_loss_pair",
      "add_common_rater_and_common_object_pair",
      "audit_both_incidence_projections",
      "add_rank_top_n_and_cut_score_outcomes",
      "retain_truth_and_fully_crossed_reference_targets"
    ),
    ExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_raid_contrast_registry <- function() {
  data.frame(
    ContrastId = c(
      "coverage_ladder",
      "equal_cost_topology",
      "repetition_4_6_8",
      "rater_order_pairing",
      "critical_edge_loss",
      "bridge_direction",
      "constant_rater_bridge",
      "dual_projection_decision_audit"
    ),
    SourceElements = c(
      "25%;50%;75%;fully_crossed",
      "Kite;Box;Hexagon;Fully-linked",
      "repetition_size_4;6;8",
      "RO1;RO2;RO3;RO4",
      "8x8x.25-4;StringOfPearls",
      "OneforAll;AllforOne",
      "Wind6x8x.5;matched_50_percent_design",
      "rater_graph;object_graph;rank;top_n;cut_score"
    ),
    IsolationRule = c(
      "hold scale and outcome use fixed while varying coverage",
      "hold rating assignments and coverage fixed while varying structure",
      "hold coverage structure and Rater order fixed",
      "reuse the same responses and design template",
      "remove only the predeclared critical assignment edge",
      "hold total rating resource as close as design arithmetic permits",
      "compare against an equal-coverage distributed-link design",
      "report structural and substantive outcomes without scalarization"
    ),
    SuccessorManifestRequired = TRUE,
    ExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_raid_metric_registry <- function() {
  metric_id <- c(
    "rating_assignment_count", "assignment_density",
    "rater_graph_components", "rater_graph_missing_pairs",
    "rater_graph_min_common_objects", "rater_graph_median_common_objects",
    "rater_graph_link_width_cv", "rater_graph_articulation_points",
    "object_graph_components", "object_graph_articulation_points",
    "fit_return_rate", "inference_ready_rate",
    "free_rater_absolute_rmse", "person_absolute_rmse",
    "person_rank_spearman", "person_matched_rank_nri1",
    "person_matched_rank_nri3", "person_correct_top_n",
    "person_cut_score_classification", "reference_relative_mad",
    "observed_adjusted_difference"
  )
  data.frame(
    MetricId = metric_id,
    Family = c(
      rep("resource", 2L), rep("rater_graph", 6L),
      rep("object_graph", 2L), rep("execution", 2L),
      rep("recovery", 2L), rep("relative_decision", 5L),
      rep("reference_comparison", 2L)
    ),
    Required = TRUE,
    ExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_raid_registry <- function() {
  out <- list(
    Specification = mfrmr_raid_specification,
    Contract = mfrmr_raid_contract,
    Source = mfrmr_raid_source_registry(),
    SourceDesigns = mfrmr_raid_source_design_registry(),
    RaterOrders = mfrmr_raid_rater_order_registry(),
    Requirements = mfrmr_raid_requirement_registry(),
    Contrasts = mfrmr_raid_contrast_registry(),
    Metrics = mfrmr_raid_metric_registry(),
    CurrentTypedAnchorScenarioCount = 9L,
    CurrentProspectiveAnchorConfigurationCount = 8L,
    CurrentProspectiveNetworkScenarioCount = 7L,
    Frozen0_2_3ContractMutated = FALSE,
    SourceDesignsAdoptedAsSuccessorManifest = FALSE,
    SimulationExecuted = FALSE,
    SuccessorExecutionAuthorized = FALSE,
    AppropriateAnchorRateSelected = FALSE,
    PublicApiChanged = FALSE
  )
  class(out) <- c("mfrmr_raid_registry", "list")
  mfrmr_raid_validate_registry(out)
  out
}

mfrmr_raid_validate_registry <- function(registry) {
  source <- registry$Source
  designs <- registry$SourceDesigns
  orders <- registry$RaterOrders
  requirements <- registry$Requirements
  contrasts <- registry$Contrasts
  metrics <- registry$Metrics

  mfrmr_raid_assert(
    is.data.frame(source) && nrow(source) == 1L &&
      source$Year == 2018L && source$ObjectCount == 24L &&
      source$RaterCount == 8L && source$IncompleteDesignCount == 20L &&
      source$RaterOrderCount == 4L &&
      source$IncompleteAnalysisCount == 80L &&
      source$TotalAnalysisCount == 84L,
    "The McEwen source identity or study denominator drifted."
  )
  mfrmr_raid_assert(
    is.data.frame(designs) && nrow(designs) == 20L &&
      !anyDuplicated(designs$DesignId) &&
      sum(designs$CoverageBalanced) == 16L &&
      sum(!designs$CoverageBalanced) == 4L &&
      identical(
        sort(unique(designs$RaterCoverage[designs$CoverageBalanced])),
        c(0.25, 0.50, 0.75)
      ) &&
      identical(
        sort(unique(designs$RepetitionSize[designs$CoverageBalanced])),
        c(4L, 6L, 8L)
      ) &&
      all(designs$RatersPerObject[designs$CoverageBalanced] ==
            as.integer(8L * designs$RaterCoverage[designs$CoverageBalanced])) &&
      setequal(
        unique(designs$Structure[designs$CoverageBalanced]),
        c(
          "Ring", "Kite", "Box", "Trapezoids", "Hexagon", "Unique",
          "Fully-linked"
        )
      ) &&
      setequal(
        designs$DesignId[!designs$CoverageBalanced],
        c("StringOfPearls", "AllforOne", "OneforAll", "Wind6x8x.5")
      ) &&
      sum(designs$CriticalLinkLossStress) == 1L &&
      all(designs$SourceCatalogOnly) &&
      all(!designs$ExecutionAuthorized),
    "The 20-design McEwen source catalog drifted."
  )
  order_values <- lapply(
    strsplit(orders$Permutation, ";", fixed = TRUE),
    function(x) as.integer(x)
  )
  order_matrix <- do.call(rbind, order_values)
  mfrmr_raid_assert(
    is.data.frame(orders) && nrow(orders) == 4L &&
      !anyDuplicated(orders$RaterOrderId) &&
      all(vapply(
        order_values, function(x) identical(sort(x), 1:8), logical(1)
      )) &&
      all(apply(
        order_matrix[1:3, , drop = FALSE], 2L,
        function(x) length(unique(x)) == 3L
      )) &&
      identical(which(orders$UsesFullyCrossedSeverity), 4L) &&
      all(orders$PairAcrossDesigns) && all(!orders$ExecutionAuthorized),
    "The four McEwen Rater-order profiles drifted."
  )
  mfrmr_raid_assert(
    is.data.frame(requirements) && nrow(requirements) == 10L &&
      !anyDuplicated(requirements$RequirementId) &&
      identical(
        sort(unique(requirements$Current0_2_3Coverage)),
        c("missing", "partial", "supported")
      ) &&
      sum(requirements$Current0_2_3Coverage == "supported") == 1L &&
      sum(requirements$Current0_2_3Coverage == "partial") == 3L &&
      sum(requirements$Current0_2_3Coverage == "missing") == 6L &&
      all(!requirements$ExecutionAuthorized),
    "The literature-to-current-contract gap audit drifted."
  )
  mfrmr_raid_assert(
    is.data.frame(contrasts) && nrow(contrasts) == 8L &&
      !anyDuplicated(contrasts$ContrastId) &&
      all(contrasts$SuccessorManifestRequired) &&
      all(!contrasts$ExecutionAuthorized),
    "The McEwen-informed successor contrasts drifted."
  )
  mfrmr_raid_assert(
    is.data.frame(metrics) && nrow(metrics) == 21L &&
      !anyDuplicated(metrics$MetricId) &&
      all(c(
        "rater_graph_link_width_cv", "object_graph_articulation_points",
        "person_rank_spearman", "person_matched_rank_nri1",
        "person_correct_top_n", "person_cut_score_classification",
        "reference_relative_mad", "observed_adjusted_difference"
      ) %in% metrics$MetricId) &&
      all(metrics$Required) && all(!metrics$ExecutionAuthorized),
    "The McEwen-informed metric registry drifted."
  )
  authority <- c(
    registry$Frozen0_2_3ContractMutated,
    registry$SourceDesignsAdoptedAsSuccessorManifest,
    registry$SimulationExecuted,
    registry$SuccessorExecutionAuthorized,
    registry$AppropriateAnchorRateSelected,
    registry$PublicApiChanged
  )
  mfrmr_raid_assert(
    all(!as.logical(authority)) &&
      registry$CurrentTypedAnchorScenarioCount == 9L &&
      registry$CurrentProspectiveAnchorConfigurationCount == 8L &&
      registry$CurrentProspectiveNetworkScenarioCount == 7L,
    "The refinement audit cannot mutate contracts, execute, or select a rate."
  )
  invisible(TRUE)
}

mfrmr_raid_preflight <- function() {
  registry <- mfrmr_raid_registry()
  list(
    Specification = registry$Specification,
    Contract = registry$Contract,
    Status = "literature_refinement_structurally_ready_execution_closed",
    CurrentTypedAnchorScenarios = registry$CurrentTypedAnchorScenarioCount,
    CurrentAnchorConfigurations =
      registry$CurrentProspectiveAnchorConfigurationCount,
    CurrentNetworkScenarios = registry$CurrentProspectiveNetworkScenarioCount,
    SourceIncompleteDesigns = nrow(registry$SourceDesigns),
    SourceRaterOrders = nrow(registry$RaterOrders),
    SourceIncompleteAnalyses = registry$Source$IncompleteAnalysisCount,
    SourceTotalAnalyses = registry$Source$TotalAnalysisCount,
    RequiredSuccessorContrasts = nrow(registry$Contrasts),
    Frozen0_2_3ContractMutated = FALSE,
    SimulationExecuted = FALSE,
    SuccessorExecutionAuthorized = FALSE,
    AppropriateAnchorRateSelected = FALSE,
    PublicApiChanged = FALSE
  )
}
