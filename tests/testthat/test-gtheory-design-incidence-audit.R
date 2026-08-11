gtheory_design_incidence_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-design-incidence-audit-0.2.3.R"
    )
  )
}

load_gtheory_design_incidence_audit <- function() {
  paths <- gtheory_design_incidence_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  skip_if_not_installed("digest")
  if (!requireNamespace("reformulas", quietly = TRUE) &&
      !requireNamespace("lme4", quietly = TRUE)) {
    skip("Draft.81 formula parser requires reformulas or lme4")
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gti_pxi_spec <- function(env, cell_replication = FALSE,
                         saturated = FALSE) {
  formula <- if (saturated) {
    Score ~ 1 + (1 | Person) + (1 | Item) + (1 | Person:Item)
  } else {
    Score ~ 1 + (1 | Person) + (1 | Item)
  }
  env$mfrmr_gta_spec(
    formula, object = "Person", facets = "Item",
    residual_scale_by = "Item", cell_replication = cell_replication
  )
}

test_that("Draft.83a audits a complete crossed design without claiming inference", {
  env <- load_gtheory_design_incidence_audit()
  spec <- env$mfrmr_gta_fixture("pxrxi")$spec
  data <- expand.grid(
    Person = paste0("P", seq_len(4L)),
    Rater = paste0("R", seq_len(3L)),
    Item = paste0("I", seq_len(2L)),
    stringsAsFactors = FALSE
  )
  data$Score <- seq_len(nrow(data)) / 10

  audit <- env$mfrmr_gti_audit(spec, data)

  expect_true(audit$IncidenceScreenPassed)
  expect_identical(audit$AuditState, "audit_complete")
  expect_identical(audit$MissingnessStatus, "no_rows_omitted")
  expect_true(audit$GlobalConnectivity$IsConnected)
  expect_true(all(audit$PairwiseConnectivity$IsConnected))
  expect_equal(audit$PairwiseConnectivity$IncidenceDensity, rep(1, 3))
  expect_identical(audit$CellAudit$ReplicationState,
                   "complete_one_per_cell")
  expect_equal(audit$CellAudit$CellCoverage, 1)
  expect_equal(audit$FullModelRank, 18L)
  expect_equal(audit$ResidualDegreesFreedom, 6L)
  expect_true(all(
    audit$ComponentRankAudit$FixedEquivalentStatus ==
      "fixed_equivalent_full_increment"
  ))
  expect_identical(audit$EstimationEligibility,
                   "not_adjudicated_draft83a")
  expect_false(audit$CoefficientEligible)
  expect_false(audit$DecisionReady)
  expect_match(audit$AuditHash, "^[0-9a-f]{64}$")
})

test_that("Draft.83a distinguishes sparse connected incidence from completeness", {
  env <- load_gtheory_design_incidence_audit()
  spec <- gti_pxi_spec(env)
  data <- data.frame(
    Person = c("P1", "P1", "P2", "P2", "P3", "P3", "P4", "P4"),
    Item = c("I1", "I2", "I2", "I3", "I3", "I4", "I4", "I1"),
    Score = c(1, 2, 2, 3, 3, 4, 4, 1),
    stringsAsFactors = FALSE
  )

  audit <- env$mfrmr_gti_audit(spec, data)

  expect_true(audit$IncidenceScreenPassed)
  expect_true(audit$PairwiseConnectivity$IsConnected)
  expect_equal(audit$PairwiseConnectivity$IncidenceDensity, 0.5)
  expect_identical(audit$CellAudit$ReplicationState,
                   "partial_one_per_observed_cell")
  expect_equal(audit$CellAudit$CellCoverage, 0.5)
  expect_equal(audit$ResidualDegreesFreedom, 1L)
  expect_false(audit$DecisionReady)
})

test_that("Draft.83a exposes disconnected object-facet islands", {
  env <- load_gtheory_design_incidence_audit()
  spec <- gti_pxi_spec(env)
  data <- data.frame(
    Person = rep(paste0("P", seq_len(4L)), each = 2L),
    Item = c("I1", "I2", "I1", "I2", "I3", "I4", "I3", "I4"),
    Score = seq_len(8L),
    stringsAsFactors = FALSE
  )

  audit <- env$mfrmr_gti_audit(spec, data)

  expect_false(audit$IncidenceScreenPassed)
  expect_equal(audit$PairwiseConnectivity$ConnectedComponents, 2L)
  expect_true("non_nested_object_facet_disconnected:Item" %in%
                audit$Issues)
  expect_true(any(grepl("fixed_equivalent_rank_deficiency", audit$Issues)))
  expect_identical(audit$AuditState,
                   "audit_complete_with_design_concerns")
})

test_that("Draft.83a gives nested child levels conditional identities", {
  env <- load_gtheory_design_incidence_audit()
  spec <- env$mfrmr_gta_spec(
    Score ~ 1 + (1 | Person) + (1 | Site/Rater),
    object = "Person", facets = c("Site", "Rater"),
    nesting = data.frame(Parent = "Site", Child = "Rater"),
    residual_scale_by = c("Site", "Rater")
  )
  data <- expand.grid(
    Person = paste0("P", seq_len(3L)),
    Site = paste0("S", seq_len(2L)),
    Rater = paste0("R", seq_len(2L)),
    stringsAsFactors = FALSE
  )
  data$Score <- seq_len(nrow(data))

  audit <- env$mfrmr_gti_audit(spec, data)

  expect_true(audit$IncidenceScreenPassed)
  expect_equal(audit$NestingAudit$ConditionalChildLevels, 4L)
  expect_equal(audit$NestingAudit$SharedRawChildLabels, 2L)
  expect_identical(
    audit$NestingAudit$LabelScopeStatus,
    "raw_child_labels_reused_conditional_identity_applied"
  )
  nested_pair <- audit$PairwiseConnectivity[
    audit$PairwiseConnectivity$PairId == "Site:Rater", , drop = FALSE
  ]
  expect_equal(nested_pair$ConnectedComponents, 2L)
  expect_false(nested_pair$IsConnected)
  expect_false(any(grepl("disconnected:Rater", audit$Issues)))
  expect_true(is.na(audit$CellAudit$PotentialCells))
  expect_identical(
    audit$CellAudit$PotentialCellBasis,
    "nested_structural_potential_requires_allocation_contract"
  )
  site_rank <- audit$ComponentRankAudit[
    audit$ComponentRankAudit$ComponentId == "Site", , drop = FALSE
  ]
  expect_identical(
    site_rank$FixedEquivalentStatus,
    "fixed_equivalent_nested_hierarchy_absorbed"
  )
  expect_false(spec$DStudyEligible)
  expect_false(audit$DecisionReady)
})

test_that("Draft.83a separates observed replication from declared metadata", {
  env <- load_gtheory_design_incidence_audit()
  base <- expand.grid(
    Person = paste0("P", seq_len(3L)),
    Item = paste0("I", seq_len(3L)),
    Replicate = seq_len(2L),
    stringsAsFactors = FALSE
  )
  base$Score <- seq_len(nrow(base)) / 10
  data <- base[c("Person", "Item", "Score")]

  mismatch <- env$mfrmr_gti_audit(gti_pxi_spec(env), data)
  expect_true("cell_replication_metadata_mismatch" %in% mismatch$Issues)
  expect_identical(mismatch$CellAudit$ReplicationState,
                   "complete_equal_replication")
  expect_identical(
    mismatch$CellAudit$HighestInteractionResidualState,
    "within_cell_replication_available"
  )

  saturated <- env$mfrmr_gti_audit(
    gti_pxi_spec(env, cell_replication = TRUE, saturated = TRUE), data
  )
  expect_true(saturated$IncidenceScreenPassed)
  expect_false("highest_order_residual_not_separable" %in%
                 saturated$Issues)
  expect_equal(saturated$ResidualDegreesFreedom, 9L)
  expect_false(saturated$DecisionReady)
})

test_that("Draft.83a hashes retained rows and omission patterns canonically", {
  env <- load_gtheory_design_incidence_audit()
  spec <- gti_pxi_spec(env)
  data <- expand.grid(
    Person = paste0("P", seq_len(3L)),
    Item = paste0("I", seq_len(3L)),
    stringsAsFactors = FALSE
  )
  data$Score <- seq_len(nrow(data))
  data$Score[[2L]] <- NA_real_
  data$Item[[8L]] <- NA_character_

  complete_conflict <- env$mfrmr_gti_audit(
    spec, data, missingness = "complete"
  )
  mar <- env$mfrmr_gti_audit(
    spec, data, missingness = "MAR_covariate"
  )
  replay <- env$mfrmr_gti_audit(
    spec, data[rev(seq_len(nrow(data))), ], missingness = "MAR_covariate"
  )

  expect_equal(mar$InputRows, 9L)
  expect_equal(mar$RetainedRows, 7L)
  expect_equal(mar$OmittedRows, 2L)
  expect_equal(mar$MissingScoreRows, 1L)
  expect_equal(mar$MissingFacetRows, 1L)
  expect_identical(complete_conflict$MissingnessStatus,
                   "declaration_conflict")
  expect_true("declared_complete_but_rows_omitted" %in%
                complete_conflict$Issues)
  expect_identical(mar$MissingnessStatus,
                   "omissions_declared_MAR_covariate")
  expect_identical(replay$CanonicalInputHash, mar$CanonicalInputHash)
  expect_identical(replay$RetainedDataHash, mar$RetainedDataHash)
  expect_identical(replay$OmissionPatternHash, mar$OmissionPatternHash)
  expect_identical(replay$AuditHash, mar$AuditHash)

  isolated_data <- data.frame(
    Person = factor(c("P1", "P1", "P2", "P2", "P3"),
                    levels = c("P1", "P2", "P3", "P4")),
    Item = c("I1", "I2", "I1", "I2", "I1"),
    Score = c(1, 2, 2, 3, NA_real_),
    stringsAsFactors = FALSE
  )
  isolated <- env$mfrmr_gti_audit(
    spec, isolated_data, missingness = "MAR_covariate"
  )
  person_load <- isolated$Workload[
    isolated$Workload$Factor == "Person", , drop = FALSE
  ]
  expect_equal(person_load$DeclaredRawLevels, 4L)
  expect_equal(person_load$ZeroRetainedRawLevels, 2L)
  expect_true("declared_levels_without_retained_rows:Person" %in%
                isolated$Issues)
  expect_false(isolated$IncidenceScreenPassed)
})

test_that("Draft.83a fails closed on input type and rank capacity", {
  env <- load_gtheory_design_incidence_audit()
  spec <- gti_pxi_spec(env)
  data <- data.frame(
    Person = c("P1", "P1", "P2", "P2"),
    Item = c("I1", "I2", "I1", "I2"),
    Score = seq_len(4L),
    stringsAsFactors = FALSE
  )
  labelled <- data
  labelled$Score <- as.character(labelled$Score)

  expect_error(env$mfrmr_gti_audit(spec, labelled),
               "must be numeric")
  limited <- env$mfrmr_gti_audit(spec, data, max_matrix_cells = 2)
  expect_identical(limited$RankCapacityStatus,
                   "not_evaluated_capacity")
  expect_identical(limited$AuditState,
                   "audit_not_evaluated_capacity")
  expect_true("rank_audit_not_evaluated_capacity" %in% limited$Issues)
  expect_false(limited$IncidenceScreenPassed)
  expect_false(limited$CoefficientEligible)
  expect_false(limited$DecisionReady)
})
