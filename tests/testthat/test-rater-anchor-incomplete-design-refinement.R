rater_anchor_incomplete_design_refinement_paths <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  c(
    refinement = file.path(
      validation, "rater-anchor-incomplete-design-refinement-0.2.4.R"
    ),
    record = file.path(
      validation,
      "rater-anchor-incomplete-design-refinement-record-0.2.4.md"
    ),
    frozen = file.path(
      validation, "rater-anchor-sparse-prospective-contract-0.2.3.R"
    )
  )
}

rater_anchor_incomplete_design_refinement_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    path <- rater_anchor_incomplete_design_refinement_paths()[["refinement"]]
    testthat::skip_if_not(file.exists(path))
    value <<- new.env(parent = globalenv())
    sys.source(path, envir = value)
    value
  }
})

test_that("McEwen source identity and denominators are explicit", {
  env <- rater_anchor_incomplete_design_refinement_environment()
  registry <- env$mfrmr_raid_registry()
  source <- registry$Source

  expect_s3_class(registry, "mfrmr_raid_registry")
  expect_identical(source$Year, 2018L)
  expect_identical(source$SourceType, "doctoral_dissertation")
  expect_identical(source$ZoteroItemKey, "5VIBC8I2")
  expect_identical(source$ZoteroAttachmentKey, "FQ3CGTFU")
  expect_identical(source$IncompleteDesignCount, 20L)
  expect_identical(source$RaterOrderCount, 4L)
  expect_identical(source$IncompleteAnalysisCount, 80L)
  expect_identical(source$TotalAnalysisCount, 84L)
})

test_that("source catalog preserves all 20 incomplete designs", {
  env <- rater_anchor_incomplete_design_refinement_environment()
  designs <- env$mfrmr_raid_registry()$SourceDesigns

  expect_identical(nrow(designs), 20L)
  expect_identical(anyDuplicated(designs$DesignId), 0L)
  expect_identical(sum(designs$CoverageBalanced), 16L)
  expect_identical(sum(!designs$CoverageBalanced), 4L)
  expect_equal(
    sort(unique(designs$RaterCoverage[designs$CoverageBalanced])),
    c(0.25, 0.50, 0.75)
  )
  expect_identical(
    sort(unique(designs$RepetitionSize[designs$CoverageBalanced])),
    c(4L, 6L, 8L)
  )
  expect_setequal(
    unique(designs$Structure[designs$CoverageBalanced]),
    c(
      "Ring", "Kite", "Box", "Trapezoids", "Hexagon", "Unique",
      "Fully-linked"
    )
  )
  expect_setequal(
    designs$DesignId[!designs$CoverageBalanced],
    c("StringOfPearls", "AllforOne", "OneforAll", "Wind6x8x.5")
  )
  expect_identical(
    designs$DesignId[designs$CriticalLinkLossStress], "StringOfPearls"
  )
  expect_true(all(!designs$ExecutionAuthorized))
})

test_that("four Rater orders remain paired design perturbations", {
  env <- rater_anchor_incomplete_design_refinement_environment()
  orders <- env$mfrmr_raid_registry()$RaterOrders
  parsed <- lapply(
    strsplit(orders$Permutation, ";", fixed = TRUE), as.integer
  )

  expect_identical(nrow(orders), 4L)
  expect_identical(orders$RaterOrderId, paste0("RO", 1:4))
  expect_true(all(vapply(
    parsed, function(x) identical(sort(x), 1:8), logical(1)
  )))
  expect_identical(which(orders$UsesFullyCrossedSeverity), 4L)
  expect_true(all(orders$PairAcrossDesigns))
  expect_true(all(!orders$ExecutionAuthorized))
})

test_that("gap audit separates supported partial and missing evidence", {
  env <- rater_anchor_incomplete_design_refinement_environment()
  requirements <- env$mfrmr_raid_registry()$Requirements

  expect_identical(nrow(requirements), 10L)
  expect_identical(
    requirements$Current0_2_3Coverage[
      requirements$RequirementId == "direct_anchor_link_separation"
    ],
    "supported"
  )
  expect_identical(
    sum(requirements$Current0_2_3Coverage == "supported"), 1L
  )
  expect_identical(
    sum(requirements$Current0_2_3Coverage == "partial"), 3L
  )
  expect_identical(
    sum(requirements$Current0_2_3Coverage == "missing"), 6L
  )
  expect_true(all(c(
    "rater_coverage_gradient", "cost_matched_link_structure",
    "repetition_size", "rater_assignment_order", "critical_link_loss",
    "dual_graph_projection"
  ) %in% requirements$RequirementId[
    requirements$Current0_2_3Coverage == "missing"
  ]))
})

test_that("successor contrasts and metrics cover substantive design use", {
  env <- rater_anchor_incomplete_design_refinement_environment()
  registry <- env$mfrmr_raid_registry()

  expect_identical(nrow(registry$Contrasts), 8L)
  expect_true(all(registry$Contrasts$SuccessorManifestRequired))
  expect_true(all(!registry$Contrasts$ExecutionAuthorized))
  expect_identical(nrow(registry$Metrics), 21L)
  expect_true(all(c(
    "rater_graph_link_width_cv", "object_graph_articulation_points",
    "person_rank_spearman", "person_matched_rank_nri1",
    "person_correct_top_n", "person_cut_score_classification",
    "reference_relative_mad", "observed_adjusted_difference"
  ) %in% registry$Metrics$MetricId))
  expect_true(all(registry$Metrics$Required))
  expect_true(all(!registry$Metrics$ExecutionAuthorized))
})

test_that("refinement keeps scenario layers and authority separate", {
  env <- rater_anchor_incomplete_design_refinement_environment()
  registry <- env$mfrmr_raid_registry()
  preflight <- env$mfrmr_raid_preflight()

  expect_identical(registry$CurrentTypedAnchorScenarioCount, 9L)
  expect_identical(
    registry$CurrentProspectiveAnchorConfigurationCount, 8L
  )
  expect_identical(registry$CurrentProspectiveNetworkScenarioCount, 7L)
  expect_identical(preflight$SourceIncompleteDesigns, 20L)
  expect_identical(preflight$SourceRaterOrders, 4L)
  expect_identical(preflight$SourceIncompleteAnalyses, 80L)
  expect_identical(preflight$SourceTotalAnalyses, 84L)
  expect_identical(preflight$RequiredSuccessorContrasts, 8L)
  expect_identical(
    preflight$Status,
    "literature_refinement_structurally_ready_execution_closed"
  )
  expect_false(preflight$Frozen0_2_3ContractMutated)
  expect_false(preflight$SimulationExecuted)
  expect_false(preflight$SuccessorExecutionAuthorized)
  expect_false(preflight$AppropriateAnchorRateSelected)
  expect_false(preflight$PublicApiChanged)
})

test_that("the frozen 0.2.3 prospective contract remains unchanged", {
  paths <- rater_anchor_incomplete_design_refinement_paths()
  skip_if_not(file.exists(paths[["frozen"]]))
  skip_if_not_installed("digest")
  frozen <- new.env(parent = globalenv())
  sys.source(paths[["frozen"]], envir = frozen)
  registry <- frozen$mfrmr_rasp_registry()
  manifest <- frozen$mfrmr_rasp_execution_manifest(
    registry, "feasibility"
  )

  expect_identical(nrow(registry$AnchorRegistry), 8L)
  expect_identical(nrow(registry$DesignRegistry), 7L)
  expect_identical(nrow(manifest), 560L)
  expect_false(registry$FeasibilityExecutionAuthorized)
  expect_false(registry$AppropriateAnchorRateSelected)
})

test_that("record documents evidence limits and non-additive counts", {
  path <- rater_anchor_incomplete_design_refinement_paths()[["record"]]
  skip_if_not(file.exists(path))
  record <- paste(
    readLines(path, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )

  expect_match(record, "20 incomplete designs by four Rater orders", fixed = TRUE)
  expect_match(record, "remains **nine**", fixed = TRUE)
  expect_match(record, "not 80 additional anchor", fixed = TRUE)
  expect_match(record, "single, small real-data set", fixed = TRUE)
  expect_match(record, "Frozen0_2_3ContractMutated = FALSE", fixed = TRUE)
  expect_match(record, "SuccessorExecutionAuthorized = FALSE", fixed = TRUE)
  expect_match(record, "AppropriateAnchorRateSelected = FALSE", fixed = TRUE)
})
