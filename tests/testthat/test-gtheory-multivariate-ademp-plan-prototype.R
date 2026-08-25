gtheory_multivariate_ademp_plan_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-incidence-preflight-0.2.4.R",
      "gtheory-multivariate-matched-backend-prototype-0.2.4.R",
      "gtheory-multivariate-k-oracle-prototype-0.2.4.R",
      "gtheory-multivariate-ademp-plan-prototype-0.2.4.R"
    )
  )
}

load_gtheory_multivariate_ademp_plan <- local({
  validation_environment <- NULL
  function() {
    paths <- gtheory_multivariate_ademp_plan_paths()
    skip_if_not(all(file.exists(paths)),
                "repository-internal validation artifacts are excluded")
    skip_if_not_installed("digest")
    if (is.null(validation_environment)) {
      validation_environment <<- new.env(parent = globalenv())
      for (path in paths) {
        sys.source(path, envir = validation_environment)
      }
    }
    validation_environment
  }
})

gtvd_canonical_plan <- local({
  canonical_plan <- NULL
  function(env) {
    if (is.null(canonical_plan)) {
      canonical_plan <<- env$mfrmr_gtvd_plan()
    }
    canonical_plan
  }
})

gtvd_c0_structural_design <- function(env, assignment_id) {
  rows <- env$mfrmr_gtvd_assignment_rows(assignment_id)
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
  env$mfrmr_gtvc_neutral_design(
    rows$RowId, strata, stratum_code, group_codes, fixed,
    stats::setNames(rep(0, nrow(rows)), rows$RowId)
  )
}

test_that("Draft.85c1 seals the exact 14-scenario covering registry", {
  env <- load_gtheory_multivariate_ademp_plan()
  plan <- gtvd_canonical_plan(env)

  expect_silent(env$mfrmr_gtvd_assert_plan(plan))
  expect_s3_class(plan, "mfrmr_gtvd_plan")
  expect_identical(plan$ScenarioCount, 14L)
  expect_identical(plan$ExecutableScenarioCount, 12L)
  expect_identical(plan$NegativeControlCount, 2L)
  expect_equal(
    as.integer(table(plan$ScenarioRegistry$ScenarioClass)),
    c(2L, 8L, 1L, 1L, 2L)
  )
  expect_identical(
    plan$ScenarioRegistry$ScenarioId,
    c(
      "C1-I2-BAL", "C1-I2-SPARSE", "C1-I2-UNEQUAL", "C1-I2-ABSENT",
      "C1-I3-BAL", "C1-I3-SPARSE", "C1-I3-UNEQUAL", "C1-I3-ABSENT",
      "C1-B2-RANK1", "C1-B2-RESID", "C1-B3-RANK2",
      "C1-B3-SCALED", "C1-N3-NO-AC", "C1-N2-NOREP"
    )
  )
  expect_identical(
    plan$ScenarioRegistry$ExpectedDerivativeRank,
    c(rep(10L, 4L), rep(19L, 4L), 10L, 10L, 19L, 19L, 17L, 9L)
  )
  expect_true(all(nchar(plan$ScenarioRegistry$OpaqueScenarioToken) == 32L))
  expect_false(anyDuplicated(plan$ScenarioRegistry$OpaqueScenarioToken) > 0L)
  expect_true(all(
    plan$StructuralDesignPreflight$CompactSignatureRankMatchesExpectation
  ))
  expect_true(all(plan$StructuralDesignPreflight$LayoutDimensionMatches))
  expect_identical(
    plan$StructuralDesignPreflight$CompactSignatureRank,
    c(10L, 10L, 10L, 10L, 19L, 19L, 19L, 19L, 17L, 9L)
  )
  expect_identical(
    plan$StructuralDesignPreflight$StructuralRows,
    plan$AssignmentCatalog$ExpectedRows
  )
  expect_true(plan$PlanContentSealed)
  expect_true(plan$ADEMPRegistryContentSealed)
  expect_false(plan$RecoveryDesignFrozen)
  expect_false(plan$RecoveryThresholdFrozen)
})

test_that("Draft.85c1 deterministic assignments retain intended incidence", {
  env <- load_gtheory_multivariate_ademp_plan()
  plan <- gtvd_canonical_plan(env)
  for (assignment_id in plan$AssignmentCatalog$AssignmentId) {
    first <- env$mfrmr_gtvd_assignment_rows(assignment_id)
    second <- env$mfrmr_gtvd_assignment_rows(assignment_id)
    expected <- plan$AssignmentCatalog$ExpectedRows[
      match(assignment_id, plan$AssignmentCatalog$AssignmentId)
    ]
    expect_identical(nrow(first), expected)
    expect_identical(first, second)
    expect_identical(
      names(first),
      c("RowId", "Stratum", "Object", "Rater", "ObjectRater", "Replicate")
    )
    expect_false(anyNA(first))
    expect_identical(anyDuplicated(first$RowId), 0L)
  }

  sparse <- env$mfrmr_gtvd_assignment_rows("A3-SPARSE")
  sparse_edges <- unique(sparse[c("Object", "Rater")])
  expect_true(all(table(sparse_edges$Object) == 2L))
  unequal <- env$mfrmr_gtvd_assignment_rows("A3-UNEQUAL")
  expect_true(all(unique(unequal$Object) %in%
                    unique(unequal$Object[unequal$Rater == "R01"])))
  absent2 <- unique(env$mfrmr_gtvd_assignment_rows("A2-ABSENT")[
    c("Object", "Stratum")
  ])
  expect_identical(as.integer(table(table(absent2$Object))), c(12L, 18L))
  absent3 <- unique(env$mfrmr_gtvd_assignment_rows("A3-ABSENT")[
    c("Object", "Stratum")
  ])
  expect_identical(as.integer(table(table(absent3$Object))), c(18L, 12L))
  no_ac <- env$mfrmr_gtvd_assignment_rows("A3-NOAC")
  objects_a <- unique(no_ac$Object[no_ac$Stratum == "A"])
  objects_c <- unique(no_ac$Object[no_ac$Stratum == "C"])
  expect_length(intersect(objects_a, objects_c), 0L)
  no_rep <- env$mfrmr_gtvd_assignment_rows("A2-NOREP")
  expect_identical(unique(no_rep$Replicate), 1L)
  expect_identical(
    plan$StructuralDesignPreflight$MinimumObjectPairOverlap[
      plan$StructuralDesignPreflight$AssignmentId == "A3-NOAC"
    ], 0L
  )

  replay <- plan$C0DerivativeReplayRegistry
  expect_identical(replay$AssignmentId, c("A3-NOAC", "A2-NOREP"))
  expect_identical(replay$ParameterCount, c(19L, 10L))
  expect_identical(replay$C0DerivativeRank, c(17L, 9L))
  expect_identical(replay$CompactSignatureRank, c(17L, 9L))
  expect_true(all(replay$RankReplayMatches))
  expect_true(all(replay$OracleReady))
  expect_false(any(replay$CovarianceDesignIdentified))
  expect_false(any(replay$RecoveryEvidenceReady))
})

test_that("Draft.85c1 references preserve c0 coordinates and boundary rules", {
  env <- load_gtheory_multivariate_ademp_plan()
  plan <- gtvd_canonical_plan(env)
  layout_counts <- table(plan$CoordinateLayouts$CoordinateLayoutId)
  expect_identical(unname(as.integer(layout_counts)), c(10L, 19L))
  expect_identical(
    plan$CoordinateLayouts$CoordinateId[
      plan$CoordinateLayouts$CoordinateLayoutId == "T2-GLOBAL-3C-R1"
    ],
    c(
      "Object[A,A]", "Object[A,B]", "Object[B,B]", "Rater[A,A]",
      "Rater[A,B]", "Rater[B,B]", "Object:Rater[A,A]",
      "Object:Rater[A,B]", "Object:Rater[B,B]", "Residual[I]"
    )
  )
  expected_reference_rows <- c(10L, 19L, 10L, 10L, 19L, 19L)
  expect_identical(
    as.integer(table(factor(
      plan$ReferenceCoordinateRegistry$ReferenceId,
      levels = plan$ReferenceCatalog$ReferenceId
    ))), expected_reference_rows
  )
  expect_false(anyDuplicated(paste(
    plan$ReferenceCoordinateRegistry$ReferenceId,
    plan$ReferenceCoordinateRegistry$CoordinateId
  )) > 0L)
  interior <- plan$ReferenceCatalog$BoundaryClass == "regular_interior"
  expect_true(all(plan$ReferenceCatalog$ExpectedRegularInterior[interior]))
  expect_true(all(!plan$ReferenceCatalog$ExpectedRegularInterior[!interior]))

  scaled <- plan$ReferenceComponentAudit[
    plan$ReferenceComponentAudit$ReferenceId ==
      "REF-T3-INTERACTION-SCALED" &
      plan$ReferenceComponentAudit$ComponentId == "Object:Rater", , drop = FALSE
  ]
  expect_gt(scaled$MinimumEigenvalue, 1e-8)
  expect_lt(scaled$MinimumEigenvalue, 1e-10 * scaled$MaximumEigenvalue)
  expect_identical(scaled$EffectiveRank, 2L)
  expect_true(scaled$RankDeficient)
  expect_true(scaled$Boundary)

  rank1 <- plan$ReferenceComponentAudit[
    plan$ReferenceComponentAudit$ReferenceId == "REF-T2-RATER-RANK1" &
      plan$ReferenceComponentAudit$ComponentId == "Rater", , drop = FALSE
  ]
  rank2 <- plan$ReferenceComponentAudit[
    plan$ReferenceComponentAudit$ReferenceId == "REF-T3-RATER-RANK2" &
      plan$ReferenceComponentAudit$ComponentId == "Rater", , drop = FALSE
  ]
  expect_identical(rank1$EffectiveRank, 1L)
  expect_identical(rank2$EffectiveRank, 2L)
  expect_true(rank1$Boundary)
  expect_true(rank2$Boundary)
  expect_true(all(plan$ReferenceComponentAudit$MaximumAsymmetry == 0))
  expect_lte(max(
    plan$ReferenceFactorRegistry$MatrixReconstructionMaximumAbsoluteError
  ), 1e-12)
  for (reference_id in plan$ReferenceCatalog$ReferenceId) {
    reference <- plan$ReferenceCatalog[
      plan$ReferenceCatalog$ReferenceId == reference_id, , drop = FALSE
    ]
    layout <- plan$CoordinateLayouts[
      plan$CoordinateLayouts$CoordinateLayoutId ==
        reference$CoordinateLayoutId, , drop = FALSE
    ]
    strata <- unique(layout$LeftStratum[!is.na(layout$LeftStratum)])
    coordinates <- plan$ReferenceCoordinateRegistry[
      plan$ReferenceCoordinateRegistry$ReferenceId == reference_id,
      , drop = FALSE
    ]
    for (component in c("Object", "Rater", "Object:Rater")) {
      component_coordinates <- coordinates[
        coordinates$ComponentId == component, , drop = FALSE
      ]
      truth <- matrix(0, length(strata), length(strata))
      for (index in seq_len(nrow(component_coordinates))) {
        left <- match(component_coordinates$LeftStratum[[index]], strata)
        right <- match(component_coordinates$RightStratum[[index]], strata)
        truth[left, right] <- component_coordinates$TruthValue[[index]]
        truth[right, left] <- component_coordinates$TruthValue[[index]]
      }
      factors <- plan$ReferenceFactorRegistry[
        plan$ReferenceFactorRegistry$ReferenceId == reference_id &
          plan$ReferenceFactorRegistry$ComponentId == component,
        , drop = FALSE
      ]
      loading <- matrix(
        0, nrow = max(factors$FactorRowOrdinal),
        ncol = max(factors$FactorColumnOrdinal)
      )
      loading[cbind(
        factors$FactorRowOrdinal, factors$FactorColumnOrdinal
      )] <- factors$FactorValue
      expect_equal(loading %*% t(loading), truth, tolerance = 1e-12)
    }
    residual <- plan$ReferenceFactorRegistry[
      plan$ReferenceFactorRegistry$ReferenceId == reference_id &
        plan$ReferenceFactorRegistry$ComponentId == "Residual",
      , drop = FALSE
    ]
    expect_equal(
      residual$FactorValue^2, reference$ResidualVariance, tolerance = 1e-15
    )
  }
  expect_true("frozen_rank1_loading" %in%
                plan$ReferenceFactorRegistry$FactorConstruction)
  expect_true("frozen_rank2_loading" %in%
                plan$ReferenceFactorRegistry$FactorConstruction)
  expect_true("frozen_orthogonal_scaled_loading" %in%
                plan$ReferenceFactorRegistry$FactorConstruction)
})

test_that("Draft.85c1 freezes disjoint seeds and exact atomic denominators", {
  env <- load_gtheory_multivariate_ademp_plan()
  plan <- gtvd_canonical_plan(env)
  counts <- plan$ExpectedCounts

  expect_identical(counts$PilotDatasets, 240L)
  expect_identical(counts$PilotAtomicMethodRows, 960L)
  expect_identical(counts$ConfirmationDatasets, 4800L)
  expect_identical(counts$ConfirmationAtomicMethodRows, 19200L)
  expect_identical(counts$NegativeControlDatasets, 2L)
  expect_identical(counts$NegativeControlAtomicMethodRows, 8L)
  expect_identical(counts$PilotPairedRows, 960L)
  expect_identical(counts$ConfirmationPairedRows, 19200L)
  expect_identical(counts$NegativeControlPairedRows, 8L)
  expect_identical(counts$TotalDatasets, 5042L)
  expect_identical(counts$TotalAtomicMethodRows, 20168L)
  expect_identical(counts$TotalPairedRows, 20168L)
  expect_identical(counts$TotalCoordinateRows, 292436L)
  expect_identical(plan$PlannedDatasetCount, 5042L)
  expect_identical(plan$PlannedAtomicMethodRows, 20168L)
  expect_identical(plan$PlannedPairedRows, 20168L)
  expect_identical(plan$PlannedCoordinateRows, 292436L)

  generation <- plan$GenerationManifest
  candidate <- plan$CandidateUnitManifest
  pairs <- plan$PairUnitManifest
  expect_identical(anyDuplicated(generation$OpaqueDatasetId), 0L)
  expect_identical(anyDuplicated(generation$DataSeed), 0L)
  expect_identical(anyDuplicated(candidate$OpaqueUnitId), 0L)
  expect_identical(anyDuplicated(pairs$OpaquePairUnitId), 0L)
  expect_true(all(table(candidate$OpaqueDatasetId) == 4L))
  expect_true(all(table(candidate$DatasetOrdinal) == 4L))
  expect_true(all(table(pairs$OpaqueDatasetId) == 4L))
  expect_true(all(table(pairs$DatasetOrdinal) == 4L))
  expect_false("DataSeed" %in% names(candidate))
  expect_false("ReferenceId" %in% names(candidate))
  expect_false("ScenarioId" %in% names(candidate))
  expect_false("BoundaryClass" %in% names(candidate))
  expect_identical(
    sort(unique(candidate$MethodId)), sort(plan$MethodRegistry$MethodId)
  )
  candidate_by_id <- match(
    c(pairs$LeftOpaqueUnitId, pairs$RightOpaqueUnitId),
    candidate$OpaqueUnitId
  )
  expect_false(anyNA(candidate_by_id))
  expect_identical(
    candidate$OpaqueDatasetId[candidate_by_id],
    rep(pairs$OpaqueDatasetId, 2L)
  )
  expect_identical(
    pairs$PairId,
    rep(plan$PairRegistry$PairId, times = nrow(generation))
  )
  declared_count <- plan$StratumCatalog$DeclaredCoordinateCount[
    match(pairs$CoordinateLayoutId,
          plan$StratumCatalog$CoordinateLayoutId)
  ]
  expect_identical(pairs$CoordinateCount, declared_count)
  expect_identical(
    pairs$InputCoordinateMetricId,
    plan$PairRegistry$InputCoordinateMetricId[
      match(pairs$PairId, plan$PairRegistry$PairId)
    ]
  )
  expect_identical(
    pairs$PairedOutputMetricId,
    plan$PairRegistry$PairedOutputMetricId[
      match(pairs$PairId, plan$PairRegistry$PairId)
    ]
  )
  expect_identical(
    pairs$PairAvailabilityMetricId,
    plan$PairRegistry$PairAvailabilityMetricId[
      match(pairs$PairId, plan$PairRegistry$PairId)
    ]
  )
  stage_seeds <- split(generation$DataSeed, generation$StageId)
  expect_length(intersect(stage_seeds$pilot, stage_seeds$confirmation), 0L)
  expect_length(intersect(stage_seeds$pilot, stage_seeds$negative_control), 0L)
  expect_length(
    intersect(stage_seeds$confirmation, stage_seeds$negative_control), 0L
  )
  expect_true(all(plan$SeedPartitionPolicy$RNGKind == "L'Ecuyer-CMRG"))
  expect_true(all(plan$SeedPartitionPolicy$NormalKind == "Inversion"))
  expect_true(all(plan$SeedPartitionPolicy$SampleKind == "Rejection"))
  expect_true(all(
    plan$SeedPartitionPolicy$InitialStreamOwner == "Object"
  ))
  expect_true(all(grepl(
    "parallel::nextRNGSubStream", 
    plan$SeedPartitionPolicy$ComponentStartStateRule,
    fixed = TRUE
  )))
  expect_true(all(grepl(
    "r=ncol(stored_factor)",
    plan$SeedPartitionPolicy$GroupLatentDrawRule,
    fixed = TRUE
  )))
  expect_true(all(is.na(plan$SeedPartitionPolicy$FixtureRNGStateHash)))
  expect_false(any(plan$SeedPartitionPolicy$FixtureRNGStateHashReady))
  expect_true(plan$SeedPartitionContentSealed)
  expect_true(plan$AtomicManifestDenominatorPlanReady)
  expect_true(plan$MetricDenominatorRoutingReady)
  expect_false(plan$GeneratorImplementationReady)
  expect_false(plan$RecoveryExecuted)
})

test_that("Draft.85c1 handoff previews enforce a direct-column allowlist", {
  env <- load_gtheory_multivariate_ademp_plan()
  plan <- gtvd_canonical_plan(env)
  expected <- c(pilot = 960L, confirmation = 19200L, negative_control = 8L)
  lane_ids <- character()
  for (stage in names(expected)) {
    handoff <- env$mfrmr_gtvd_candidate_handoff_preview(plan, stage)
    expect_silent(env$mfrmr_gtvd_assert_handoff_preview(plan, handoff))
    expect_identical(handoff$ExpectedUnits, expected[[stage]])
    expect_identical(
      names(handoff$CandidateUnits),
      c(
        "OpaqueUnitId", "OpaqueDatasetId", "MethodId", "MethodControlHash",
        "CoordinateLayoutId", "CoordinateCount"
      )
    )
    expect_false(any(handoff$ForbiddenFieldAudit$PresentInCandidateUnits))
    expect_false(handoff$DirectTruthColumnsPresent)
    expect_true(handoff$OtherLaneMaterialAbsent)
    expect_true(handoff$CandidateColumnAllowlistReady)
    expect_false(handoff$PreOutcomeFreezeExternallyAnchored)
    expect_false(handoff$TruthBlindExecutionBoundaryReady)
    expect_false(handoff$ExecutionAuthorized)
    expect_false(handoff$CandidateExecutionOccurred)
    expect_false(handoff$CandidateCompletionSealed)
    expect_false(handoff$TruthReleaseAuthorized)
    expect_false(handoff$DenominatorAccountingReady)
    expect_false(handoff$RecoveryEvidenceReady)
    lane_ids <- c(lane_ids, handoff$LaneOpaqueId)
  }
  expect_identical(anyDuplicated(lane_ids), 0L)
  expect_true(plan$CandidateHandoffColumnAllowlistReady)
  pilot_handoff <- env$mfrmr_gtvd_candidate_handoff_preview(plan, "pilot")
  same_process_join_probe <- merge(
    pilot_handoff$CandidateUnits[c("OpaqueDatasetId")],
    plan$ReferenceJoinMap[c("OpaqueDatasetId", "ReferenceId")],
    by = "OpaqueDatasetId", all.x = TRUE
  )
  expect_false(anyNA(same_process_join_probe$ReferenceId))
  expect_false(pilot_handoff$TruthBlindExecutionBoundaryReady)
  expect_error(
    env$mfrmr_gtvd_candidate_handoff_preview(plan, "unknown"),
    "frozen Draft.85c1 lane"
  )

  changed <- env$mfrmr_gtvd_candidate_handoff_preview(plan, "pilot")
  changed$CandidateUnits$ScenarioId <- "C1-I2-BAL"
  expect_error(
    env$mfrmr_gtvd_assert_handoff_preview(plan, changed), "altered"
  )
  changed <- env$mfrmr_gtvd_candidate_handoff_preview(plan, "pilot")
  changed$ExecutionAuthorized <- TRUE
  expect_error(
    env$mfrmr_gtvd_assert_handoff_preview(plan, changed), "altered"
  )
  changed <- env$mfrmr_gtvd_candidate_handoff_preview(plan, "pilot")
  attr(changed, "approval") <- TRUE
  expect_error(
    env$mfrmr_gtvd_assert_handoff_preview(plan, changed), "canonical"
  )
})

test_that("Draft.85c1 distinguishes content hash from external freeze time", {
  env <- load_gtheory_multivariate_ademp_plan()
  plan <- gtvd_canonical_plan(env)
  template <- env$mfrmr_gtvd_freeze_receipt_template(plan)

  expect_silent(env$mfrmr_gtvd_assert_freeze_receipt_template(plan, template))
  expect_true(plan$ExternalFreezeReceiptRequired)
  expect_false(plan$PreOutcomeFreezeExternallyAnchored)
  expect_false(template$FreezeReceiptReady)
  expect_false(template$PreOutcomeFreezeExternallyAnchored)
  expect_false(template$RecoveryDesignFrozen)
  expect_false(template$PilotExecutionAuthorized)
  expect_false(template$ConfirmationExecutionAuthorized)
  expect_true(all(vapply(
    template[c(
      "SourceCommit", "SourceTreeHash", "ArtifactSHA256",
      "UTCFreezeTimestamp", "SignerOrAuthorityId", "ExternalRecordId",
      "ExternalAnchorProvider", "ExternalAnchorReference"
    )], function(value) length(value) == 1L && is.na(value), logical(1L)
  )))

  forged <- template
  forged$FreezeReceiptReady <- TRUE
  expect_error(
    env$mfrmr_gtvd_assert_freeze_receipt_template(plan, forged), "altered"
  )
  filled <- template
  filled$SourceCommit <- paste(rep("a", 40L), collapse = "")
  filled$ArtifactSHA256 <- paste(rep("b", 64L), collapse = "")
  filled$TemplateHash <- env$mfrmr_gta_hash(filled[
    seq_len(match("ExternalAnchorReference", names(filled)))
  ])
  expect_error(
    env$mfrmr_gtvd_assert_freeze_receipt_template(plan, filled), "altered"
  )
})

test_that("Draft.85c1 plan replay rejects rehashed semantic mutation", {
  env <- load_gtheory_multivariate_ademp_plan()
  plan <- gtvd_canonical_plan(env)

  plan_environment <- environment(env$mfrmr_gtvd_plan_payload)
  expect_false(exists(
    "canonical_payload", envir = plan_environment, inherits = FALSE
  ))
  expect_false("canonical_payload" %in%
                 all.names(body(env$mfrmr_gtvd_plan_payload)))
  assign("canonical_payload", plan, envir = plan_environment)
  expect_silent(env$mfrmr_gtvd_assert_plan(plan))
  rm("canonical_payload", envir = plan_environment)

  changed <- plan
  changed$ScenarioRegistry$ReferenceId[[1L]] <- "REF-T2-RATER-RANK1"
  changed$ScenarioRegistryHash <- env$mfrmr_gta_hash(changed$ScenarioRegistry)
  changed$PlanHash <- env$mfrmr_gta_hash(
    changed[env$mfrmr_gtvd_plan_payload_fields()]
  )
  expect_error(env$mfrmr_gtvd_assert_plan(changed), "altered")

  changed <- plan
  changed$GenerationManifest$DataSeed[[1L]] <-
    changed$GenerationManifest$DataSeed[[1L]] + 1L
  changed$GenerationManifestHash <- env$mfrmr_gta_hash(
    changed$GenerationManifest
  )
  changed$SeedPartitionContentHash <- env$mfrmr_gta_hash(
    changed$GenerationManifest[c(
      "OpaqueDatasetId", "StageId", "Replicate", "DataSeed"
    )]
  )
  changed$PlanHash <- env$mfrmr_gta_hash(
    changed[env$mfrmr_gtvd_plan_payload_fields()]
  )
  expect_error(env$mfrmr_gtvd_assert_plan(changed), "altered")

  changed <- plan
  changed$PilotExecutionAuthorized <- TRUE
  expect_error(env$mfrmr_gtvd_assert_plan(changed), "altered")
  changed <- plan
  changed$UnexpectedField <- TRUE
  expect_error(env$mfrmr_gtvd_assert_plan(changed), "canonical")
  changed <- plan
  attr(changed, "approval") <- TRUE
  expect_error(env$mfrmr_gtvd_assert_plan(changed), "canonical")

  changed <- plan
  changed$ScenarioRegistry$ScenarioId[[1L]] <- "tampered"
  fresh <- env$mfrmr_gtvd_plan()
  expect_identical(fresh$ScenarioRegistry$ScenarioId[[1L]], "C1-I2-BAL")
  expect_silent(env$mfrmr_gtvd_assert_plan(fresh))
})

test_that("Draft.85c1 methods remain paired and execution fails closed", {
  env <- load_gtheory_multivariate_ademp_plan()
  plan <- gtvd_canonical_plan(env)
  methods <- plan$MethodRegistry

  expect_identical(
    methods$MethodId,
    c("lme4_reml", "glmmtmb_reml", "lme4_ml", "glmmtmb_ml")
  )
  expect_identical(as.integer(table(methods$Backend)), c(2L, 2L))
  expect_identical(as.integer(table(methods$Criterion)), c(2L, 2L))
  expect_true(all(methods$PairedDatasetRequired))
  expect_true(all(methods$MatchedBackendQualificationRequired))
  expect_false(any(methods$DiagnosticOverrideAllowed))
  expect_true(all(methods$MatrixTolerance == 1e-10))
  expect_true(all(methods$BoundaryTolerance == 1e-8))
  expect_true(all(methods$CorrelationTolerance == 1e-6))
  expect_identical(methods$SingularTolerance,
                   c(1e-4, NA_real_, 1e-4, NA_real_))
  expect_identical(
    plan$PairRegistry$PairId,
    c(
      "PAIR-BACKEND-REML", "PAIR-BACKEND-ML",
      "PAIR-CRITERION-LME4", "PAIR-CRITERION-GLMMTMB"
    )
  )
  expect_true(all(plan$PairRegistry$CompletePairRequired))
  expect_false(any(plan$PairRegistry$PoolingAllowed))
  expect_true(all(grepl(
    "recovery_loss", plan$AimCatalog$AimId[4:5], fixed = TRUE
  )))
  expect_false(any(grepl(
    "agreement", plan$AimCatalog$AimId[4:5], fixed = TRUE
  )))
  expect_identical(
    plan$ScenarioRegistry$ExpectedPreFitState[
      plan$ScenarioRegistry$ScenarioId == "C1-B3-SCALED"
    ],
    "eligible_point_fit_boundary_truth"
  )
  scaled_coordinates <- plan$ReferenceCoordinateRegistry[
    plan$ReferenceCoordinateRegistry$ReferenceId ==
      "REF-T3-INTERACTION-SCALED" &
      plan$ReferenceCoordinateRegistry$ComponentId == "Object:Rater",
    , drop = FALSE
  ]
  scaled_matrix <- matrix(0, 3L, 3L)
  strata <- c("A", "B", "C")
  for (index in seq_len(nrow(scaled_coordinates))) {
    left <- match(scaled_coordinates$LeftStratum[[index]], strata)
    right <- match(scaled_coordinates$RightStratum[[index]], strata)
    scaled_matrix[left, right] <- scaled_coordinates$TruthValue[[index]]
    scaled_matrix[right, left] <- scaled_coordinates$TruthValue[[index]]
  }
  maximum_correlation <- max(abs(stats::cov2cor(scaled_matrix)[
    upper.tri(scaled_matrix)
  ]))
  expect_lt(maximum_correlation, 1 - methods$CorrelationTolerance[[1L]])
  expect_true(any(
    plan$BoundaryMetricPolicy$PolicyId ==
      "scaled_cross_rule_false_ready_stress"
  ))
  expect_false("c0_oracle" %in% methods$MethodId)
  expect_false(any(plan$ExecutionPrerequisiteRegistry$CurrentSatisfied))
  expect_false(any(plan$ExecutionPrerequisiteRegistry$PartialExecutionAllowed))
  expect_false(any(plan$StageCatalog$ExecutionAuthorized))
  expect_false(plan$BackendQualificationReady)
  expect_false(plan$PilotExecutionAuthorized)
  expect_false(plan$ConfirmationExecutionAuthorized)
  expect_false(plan$CandidateCompletionSealed)
  expect_false(plan$TruthReleaseAuthorized)
  expect_false(plan$DenominatorAccountingReady)
  expect_false(plan$PilotEvaluationComplete)
  expect_false(plan$DecisionRuleFrozen)
  expect_false(plan$ConfirmationIsolationReady)
  expect_false(plan$TruthBlindExecutionBoundaryReady)
  expect_false(plan$InferenceReady)
  expect_false(plan$DecisionReady)
  expect_false(plan$PublicSupportReady)
})

test_that("Draft.85c1 maps every expressible outcome to the c0 state algebra", {
  env <- load_gtheory_multivariate_ademp_plan()
  plan <- gtvd_canonical_plan(env)
  mapping <- plan$ReceiptMappingRegistry

  c0_rows <- mapping[mapping$C0CandidateReceiptAvailable, , drop = FALSE]
  valid <- vapply(seq_len(nrow(c0_rows)), function(index) {
    stage <- c0_rows$C0FailureStage[[index]]
    env$mfrmr_gtvc_candidate_stage_valid(
      c0_rows$FitReturned[[index]],
      c0_rows$EstimateAvailable[[index]],
      c0_rows$PointGatePassed[[index]],
      stage,
      if (identical(stage, "none")) "none" else "typed_failure"
    )
  }, logical(1L))
  expect_true(all(valid))
  c1_only <- mapping[!mapping$C0CandidateReceiptAvailable, , drop = FALSE]
  expect_identical(
    c1_only$SourceCondition,
    c("dataset_generation_failure",
      "prefit_structural_or_incidence_block")
  )
  expect_true(all(c1_only$C1EnvelopeRequired))
  expect_true(all(is.na(c1_only$C0FailureStage)))
  expect_true(all(grepl(
    "Observed", c1_only$RequiredC1EnvelopeFields, fixed = TRUE
  )))
  expect_identical(
    mapping$B1NormalizedFitRequired,
    c(rep(FALSE, 4L), rep(TRUE, 4L))
  )
  expect_true(all(mapping$B1PointEstimateAvailableExpected[5:8]))
  expect_identical(
    mapping$B1PointEstimationGatePassedExpected[5:8],
    c(FALSE, FALSE, FALSE, TRUE)
  )
  expect_false(any(mapping$MappingImplemented))
  expect_true(plan$ReceiptTupleCatalogReady)
  expect_false(plan$CandidateCompletionSealed)
})

test_that("Draft.85c1 binds c0/b1 prototype functions and selected dependencies", {
  env <- load_gtheory_multivariate_ademp_plan()
  plan <- gtvd_canonical_plan(env)
  identity <- plan$ImplementationIdentity
  environment_functions <- function(prefix) {
    candidates <- ls(envir = env, pattern = paste0("^", prefix))
    sort(candidates[vapply(candidates, function(name) {
      is.function(get(name, envir = env, inherits = FALSE))
    }, logical(1L))])
  }
  expect_identical(
    sort(identity$FunctionName[identity$Layer == "Draft85c1"]),
    environment_functions("mfrmr_gtvd_")
  )
  expect_identical(
    sort(identity$FunctionName[identity$Layer == "Draft85c0"]),
    environment_functions("mfrmr_gtvc_")
  )
  expect_identical(
    sort(identity$FunctionName[identity$Layer == "Draft85b1"]),
    environment_functions("mfrmr_gtvb_")
  )
  expect_identical(anyDuplicated(identity$FunctionName), 0L)
  expect_identical(
    plan$ImplementationIdentityHash, env$mfrmr_gta_hash(identity)
  )
  expect_identical(
    identity$FunctionHash,
    unname(vapply(identity$FunctionName, function(name) {
      env$mfrmr_gtvd_function_hash(get(name, envir = env, inherits = TRUE))
    }, character(1L)))
  )
  original_derivative <- get(
    "mfrmr_gtvc_derivative_design", envir = env, inherits = FALSE
  )
  on.exit(assign(
    "mfrmr_gtvc_derivative_design", original_derivative, envir = env
  ), add = TRUE)
  assign(
    "mfrmr_gtvc_derivative_design",
    function(...) stop("adversarial replacement", call. = FALSE),
    envir = env
  )
  expect_error(env$mfrmr_gtvd_assert_plan(plan), "altered")
  assign("mfrmr_gtvc_derivative_design", original_derivative, envir = env)
  expect_silent(env$mfrmr_gtvd_assert_plan(plan))
})

test_that("Draft.85c1 freezes precision but not invented accuracy cutoffs", {
  env <- load_gtheory_multivariate_ademp_plan()
  plan <- gtvd_canonical_plan(env)
  precision <- plan$MonteCarloPrecisionPolicy

  rate_policy <- precision[
    precision$PrecisionPolicyId == "MC-RATE-400", , drop = FALSE
  ]
  rate_mcse <- rate_policy$WorstCaseRateMCSE
  zero_upper <- rate_policy$ZeroEventOneSided95Upper
  expect_equal(rate_mcse, 0.025, tolerance = 1e-15)
  expect_equal(zero_upper, 1 - 0.05^(1 / 400), tolerance = 1e-15)
  expect_true(zero_upper > 0.0074 && zero_upper < 0.0075)
  expect_identical(rate_policy$PlannedN, 400L)
  expect_identical(rate_policy$IndependentUnit,
                   "planned_independent_dataset")
  expect_true(all(plan$MetricRegistry$PrecisionPolicyId %in%
                    precision$PrecisionPolicyId))
  expect_false(any(
    plan$MetricRegistry$PrimaryMetric &
      plan$MetricRegistry$PrecisionPolicyId == "MC-RAW-REPORT"
  ))
  component_rmse <- plan$MetricRegistry[
    plan$MetricRegistry$MetricId == "component_coordinate_rmse",
    , drop = FALSE
  ]
  expect_identical(
    component_rmse$WithinDatasetReduction,
    "equal_weight_mean_over_component_vech_coordinates_before_across_dataset_mean"
  )
  expect_identical(component_rmse$PrecisionPolicyId,
                   "MC-COMPONENT-MSE-005")
  component_boundary <- plan$MetricRegistry$MetricId %in% c(
    "minimum_eigenvalue_error", "effective_rank_exact_match",
    "boundary_classification_match"
  )
  expect_true(all(
    plan$MetricRegistry$MetricLevel[component_boundary] ==
      "dataset_method_component"
  ))
  psd_rate <- plan$MetricRegistry[
    plan$MetricRegistry$MetricId ==
      "psd_violation_or_extraction_failure_rate", , drop = FALSE
  ]
  expect_identical(psd_rate$Denominator,
                   "all_planned_atomic_method_rows")
  expect_true("metric_availability_rate" %in%
                plan$MetricRegistry$MetricId)
  expect_true("complete_pair_availability_rate" %in%
                plan$MetricRegistry$MetricId)
  expect_true("paired_mean_normalized_absolute_error_difference" %in%
                plan$MetricRegistry$MetricId)
  expect_true(plan$MonteCarloPrecisionPlanReady)
  expect_true(plan$MetricDefinitionsContentSealed)
  expect_true(all(is.na(
    plan$RecoveryThresholdRegistry$AccuracyThreshold
  )))
  expect_true(all(
    plan$RecoveryThresholdRegistry$ThresholdStatus ==
      "not_frozen_prospective_gate_required"
  ))
  expect_false(any(plan$RecoveryThresholdRegistry$PilotMaySelect))
  expect_false(any(plan$RecoveryThresholdRegistry$ConfirmationMaySelect))
  expect_false(plan$RecoveryThresholdFrozen)
  expect_true("coordinate_normalized_signed_error" %in%
                plan$MetricRegistry$MetricId)
  expect_true("false_ready_rate" %in% plan$MetricRegistry$MetricId)
  expect_true(all(plan$MetricRegistry$BoundaryScenarioEligible[1:20]))
  expect_false(any(plan$MetricRegistry$BoundaryScenarioEligible[21:22]))
  expect_true(all(plan$MetricRegistry$AccuracyThresholdStatus ==
                    "not_frozen_prospective_gate_required"))
  expect_true("composite_G_or_Phi" %in%
                plan$ExclusionRegistry$ExcludedClaim)
  expect_true("interval_or_coverage" %in%
                plan$ExclusionRegistry$ExcludedClaim)
  expect_true("missing_response_mechanism" %in%
                plan$ExclusionRegistry$ExcludedClaim)
})

test_that("Draft.85c1 seals normalizers, pair foreign keys, and applicability", {
  env <- load_gtheory_multivariate_ademp_plan()
  plan <- gtvd_canonical_plan(env)
  metrics <- plan$MetricRegistry
  pairs <- plan$PairRegistry
  normalizer <- plan$MetricNormalizationPolicy

  expect_identical(
    normalizer$ScaleSide, "registered_truth_only_never_estimate"
  )
  expect_identical(
    normalizer$NonResidualCoordinateDenominator,
    "sqrt(V_left0*V_right0)"
  )
  expect_identical(
    normalizer$ResidualCoordinateDenominator,
    "mean(V_s0_over_registered_strata)"
  )
  expect_true(grepl(
    "including_Residual[I]", normalizer$CoordinateUniverse, fixed = TRUE
  ))
  expect_false(normalizer$EstimateSideScalingAllowed)
  expect_true(all(pairs$InputCoordinateMetricId %in% metrics$MetricId))
  expect_true(all(pairs$PairedOutputMetricId %in% metrics$MetricId))
  expect_true(all(pairs$PairAvailabilityMetricId %in% metrics$MetricId))
  expect_true(all(
    pairs$DatasetLossReductionId == normalizer$DatasetLossReductionId
  ))
  expect_identical(
    plan$PairStateAlgebra$PairContrastAvailable,
    c(FALSE, FALSE, FALSE, TRUE)
  )
  expect_identical(
    plan$PairStateAlgebra$PairContrastRule[[4L]],
    "left_dataset_loss_minus_right_dataset_loss"
  )
  expect_true(all(
    plan$PairStateAlgebra$AvailabilityDenominator == "all_planned_pair_rows"
  ))

  applicability <- plan$MetricApplicabilityRegistry
  expect_identical(nrow(applicability), 572L)
  expect_identical(anyDuplicated(paste(
    applicability$StageId, applicability$ScenarioId,
    applicability$MetricId, sep = "\036"
  )), 0L)
  expect_false(any(applicability$ThresholdSelectionEligible))
  applicable <- applicability[applicability$Applicable, , drop = FALSE]
  expect_true(all(
    applicable$PrecisionPolicyId %in%
      plan$MonteCarloPrecisionPolicy$PrecisionPolicyId
  ))
  negative <- applicability[
    applicability$StageId == "negative_control" & applicability$Applicable,
    , drop = FALSE
  ]
  expect_identical(
    sort(unique(negative$MetricId)),
    sort(c(
      "false_ready_rate", "expected_prefit_state_exact_match",
      "unexpected_fit_attempt_rate"
    ))
  )
  expect_true(all(negative$PrecisionPolicyId == "DET-STRUCTURAL"))
  pilot <- applicability[
    applicability$StageId == "pilot" & applicability$Applicable,
    , drop = FALSE
  ]
  expect_true(all(
    pilot$MetricUse == "feasibility_only_never_threshold_selection"
  ))
  expect_true(all(pilot$PrecisionPolicyId == "PILOT-DESCRIPTIVE"))
  expect_false("coordinate_normalized_absolute_error" %in% pilot$MetricId)
  confirmation_boundary <- applicability[
    applicability$StageId == "confirmation" &
      applicability$ScenarioClass != "regular_interior" &
      applicability$MetricId == "false_ready_rate", , drop = FALSE
  ]
  expect_true(all(confirmation_boundary$Applicable))
  availability <- metrics[
    metrics$MetricId == "metric_availability_rate", , drop = FALSE
  ]
  expect_true(grepl(
    "TargetMetricAggregationAxes", availability$AggregationAxes, fixed = TRUE
  ))
  expect_identical(
    availability$MetricLevel, "target_metric_natural_unit"
  )
  expect_identical(
    availability$WithinDatasetReduction,
    "one_availability_state_per_target_metric_natural_unit"
  )
  expect_identical(
    availability$AcrossDatasetSummary,
    "proportion_by_target_metric_and_all_registered_target_aggregation_axes"
  )
  expect_identical(
    plan$BoundaryClassificationRegistry$EstimatedClass,
    c(
      "unavailable_non_psd_or_extraction_failure", "absolute_boundary",
      "scaled_relative_rank_boundary", "regular_interior"
    )
  )
  expect_identical(plan$BoundaryClassificationRegistry$Precedence, 1:4)
  expect_false(any(plan$BoundaryClassificationRegistry$PSDRepairAllowed))

  truth_classes <- plan$ReferenceBoundaryClassRegistry
  expect_identical(nrow(truth_classes), 24L)
  expect_identical(anyDuplicated(paste(
    truth_classes$ReferenceId, truth_classes$ComponentId, sep = "\036"
  )), 0L)
  expect_true(all(
    truth_classes$TruthComparisonClass %in%
      plan$BoundaryClassificationRegistry$EstimatedClass
  ))
  nonregular_truth <- truth_classes[
    truth_classes$TruthComparisonClass != "regular_interior",
    c("ReferenceId", "ComponentId", "TruthComparisonClass"), drop = FALSE
  ]
  row.names(nonregular_truth) <- NULL
  expect_identical(
    nonregular_truth,
    data.frame(
      ReferenceId = c(
        "REF-T2-RATER-RANK1", "REF-T2-RESIDUAL-NEAR-ZERO",
        "REF-T3-RATER-RANK2", "REF-T3-INTERACTION-SCALED"
      ),
      ComponentId = c("Rater", "Residual", "Rater", "Object:Rater"),
      TruthComparisonClass = c(
        "absolute_boundary", "absolute_boundary", "absolute_boundary",
        "scaled_relative_rank_boundary"
      ),
      stringsAsFactors = FALSE
    )
  )

  availability_targets <- plan$MetricAvailabilityTargetRegistry
  expect_identical(nrow(availability_targets), 288L)
  expect_identical(anyDuplicated(paste(
    availability_targets$StageId, availability_targets$ScenarioId,
    availability_targets$TargetMetricId, sep = "\036"
  )), 0L)
  expect_identical(
    unname(as.integer(table(availability_targets$StageId))), c(144L, 144L)
  )
  expect_true(all(
    table(
      availability_targets$StageId,
      availability_targets$ScenarioId
    ) == 12L
  ))
  expect_true(all(
    availability_targets$TargetMetricId %in%
      metrics$MetricId[
        metrics$AvailabilityCompanionMetricId == "metric_availability_rate"
      ]
  ))
  expect_true(all(
    availability_targets$TargetMetricNaturalUnitType %in%
      metrics$NaturalUnitId
  ))
  coordinate_targets <- availability_targets[
    availability_targets$TargetMetricNaturalUnitType ==
      "candidate_coordinate", , drop = FALSE
  ]
  component_targets <- availability_targets[
    availability_targets$TargetMetricNaturalUnitType ==
      "candidate_component", , drop = FALSE
  ]
  method_targets <- availability_targets[
    availability_targets$TargetMetricNaturalUnitType ==
      "candidate_method", , drop = FALSE
  ]
  expect_true(all(grepl(
    "ComponentId|CoordinateId", coordinate_targets$TargetMetricAggregationAxes,
    fixed = TRUE
  )))
  expect_true(all(grepl(
    "ComponentId", component_targets$TargetMetricAggregationAxes, fixed = TRUE
  )))
  expect_false(any(grepl(
    "ComponentId|CoordinateId", method_targets$TargetMetricAggregationAxes,
    fixed = TRUE
  )))
  expect_true(all(
    availability_targets$TargetMetricUse[
      availability_targets$StageId == "pilot"
    ] ==
      "confirmation_target_feasibility_only_never_threshold_selection"
  ))
  expect_false(any(availability_targets$ThresholdSelectionEligible))
  expect_true(
    "rates_use_registered_planned_natural_units" %in%
      plan$DenominatorRules$RuleId
  )
})

test_that("Draft.85c1 record hashes exactly match the replayed plan", {
  env <- load_gtheory_multivariate_ademp_plan()
  plan <- gtvd_canonical_plan(env)
  record <- readLines(testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-multivariate-ademp-plan-record-0.2.4.md"
  ), warn = FALSE)
  tokens <- strsplit(trimws(record), "[[:space:]]+")
  hash_rows <- vapply(tokens, function(value) {
    length(value) == 2L && grepl("^[0-9a-f]{64}$", value[[2L]])
  }, logical(1L))
  recorded <- stats::setNames(
    vapply(tokens[hash_rows], `[[`, character(1L), 2L),
    vapply(tokens[hash_rows], `[[`, character(1L), 1L)
  )
  hash_names <- c(
    "PlanHash", "PlanCoreHash", "ImplementationIdentityHash",
    "C0DerivativeReplayHash", "ReferenceRegistryHash",
    "ScenarioRegistryHash", "StructuralPreflightHash",
    "MethodRegistryHash", "PairRegistryHash", "MetricRegistryHash",
    "MetricApplicabilityRegistryHash",
    "MetricAvailabilityTargetRegistryHash", "GenerationManifestHash",
    "CandidateUnitManifestHash", "PairUnitManifestHash",
    "ReferenceJoinMapHash", "SeedPartitionContentHash"
  )
  expect_true(all(hash_names %in% names(recorded)))
  expect_identical(
    unname(recorded[hash_names]),
    unname(unlist(plan[hash_names], use.names = FALSE))
  )
})

test_that("Draft.85c1 remains isolated from the public package surface", {
  root <- testthat::test_path("..", "..")
  rbuildignore <- readLines(file.path(root, ".Rbuildignore"), warn = FALSE)
  expect_true(any(grepl("inst/validation", rbuildignore, fixed = TRUE)))
  expect_true(any(grepl("test-gtheory-", rbuildignore, fixed = TRUE)))

  public_paths <- c(
    list.files(file.path(root, "R"), full.names = TRUE),
    list.files(file.path(root, "man"), full.names = TRUE),
    list.files(file.path(root, "vignettes"), full.names = TRUE),
    file.path(
      root,
      c(
        "NEWS.md", "ROADMAP.md", "README.md", "DESCRIPTION", "NAMESPACE",
        "CITATION.cff", "_pkgdown.yml"
      )
    )
  )
  public_paths <- public_paths[file.exists(public_paths)]
  public_paths <- public_paths[!file.info(public_paths)$isdir]
  leaked <- vapply(public_paths, function(path) {
    any(grepl(
      paste(
        "Draft\\.85c1", "gtheory_multivariate_ademp_plan_draft85c1",
        "mfrmr_gtvd", sep = "|"
      ),
      readLines(path, warn = FALSE)
    ))
  }, logical(1L))
  expect_false(any(leaked))
})
