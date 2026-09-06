gtheory_multivariate_c4p_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-decision-simulation-contract-0.2.4.R",
      "gtheory-multivariate-decision-simulation-contract-v2-0.2.4.R",
      "gtheory-multivariate-incidence-preflight-0.2.4.R",
      "gtheory-multivariate-matched-backend-prototype-0.2.4.R",
      "gtheory-multivariate-k-oracle-prototype-0.2.4.R",
      "gtheory-multivariate-ademp-plan-prototype-0.2.4.R",
      "gtheory-multivariate-decision-multiverse-contract-v3-0.2.4.R",
      "gtheory-multivariate-generator-preflight-0.2.4.R",
      "gtheory-multivariate-fit-candidate-envelope-preflight-0.2.4.R",
      "gtheory-multivariate-fit-candidate-execution-0.2.4.R"
    )
  )
}

gtheory_multivariate_c4p_worker_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-multivariate-fit-candidate-worker-0.2.4.R"
  )
}

load_gtheory_multivariate_c4p <- local({
  environments <- NULL
  function() {
    paths <- gtheory_multivariate_c4p_paths()
    worker_path <- gtheory_multivariate_c4p_worker_path()
    skip_if_not(all(file.exists(c(paths, worker_path))),
                "repository-internal validation artifacts are excluded")
    skip_if_not_installed("digest")
    if (is.null(environments)) {
      controller <- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = controller)
      worker <- new.env(parent = baseenv())
      sys.source(worker_path, envir = worker)
      environments <<- list(controller = controller, worker = worker)
    }
    environments
  }
})

gtheory_multiverse_v3_contract <- local({
  contract <- NULL
  function(environments) {
    if (is.null(contract)) {
      contract <<- environments$controller$mfrmr_gtds_v3_contract()
    }
    contract
  }
})

gtheory_multiverse_v3_complete_owner_fixture <- function(env, contract) {
  packet <- env$mfrmr_gtds_v3_owner_input_candidate(contract)
  packet$FamilyEnablementRegistry$Enabled <- TRUE
  packet$FamilyEnablementRegistry$OwnerConfirmed <- TRUE
  packet$FamilyEnablementRegistry$EvidenceIdentity <- "test-fixture-family"

  packet$TargetRegistry$TargetValue <- unname(c(
    lower = 0.70, reference = 0.80, higher = 0.90
  )[packet$TargetRegistry$TargetPolicy])
  packet$TargetRegistry$OwnerConfirmed <- TRUE
  packet$TargetRegistry$EvidenceIdentity <- "test-fixture-target"

  packet$CommonUnitScaleRegistry$Compatible <- TRUE
  packet$CommonUnitScaleRegistry$ScaleIdentity <- paste0(
    "test-fixture-common-unit-S",
    packet$CommonUnitScaleRegistry$StratumCount
  )
  packet$CommonUnitScaleRegistry$OwnerConfirmed <- TRUE
  packet$CommonUnitScaleRegistry$EvidenceIdentity <-
    "test-fixture-scale-evidence"

  packet$OwnerFixedWeightRegistry$Weight <-
    1 / packet$OwnerFixedWeightRegistry$StratumCount
  packet$OwnerFixedWeightRegistry$OwnerConfirmed <- TRUE
  packet$OwnerFixedWeightRegistry$EvidenceIdentity <-
    "test-fixture-owner-weight"

  packet$StandardizationRegistry$TransformationIdentity <- paste0(
    "test-fixture-transform-",
    packet$StandardizationRegistry$DecisionFamilyId, "-S",
    packet$StandardizationRegistry$StratumCount
  )
  packet$StandardizationRegistry$OwnerConfirmed <- TRUE
  packet$StandardizationRegistry$EvidenceIdentity <-
    "test-fixture-transform-evidence"

  packet$SharingFeasibilityRegistry$OperationallyFeasible <- TRUE
  packet$SharingFeasibilityRegistry$OwnerConfirmed <- TRUE
  packet$SharingFeasibilityRegistry$EvidenceIdentity <-
    "test-fixture-sharing"
  packet$PartialSharingTopology$OperationallyFeasible <- TRUE
  packet$PartialSharingTopology$OwnerConfirmed <- TRUE
  packet$PartialSharingTopology$EvidenceIdentity <-
    "test-fixture-partial-topology"

  packet$ObservationEventDesignRegistry$ConditionSetRelationship <-
    "disjoint_by_stratum"
  packet$ObservationEventDesignRegistry$ObservationEventRelationship <-
    "distinct_event_per_stratum_score"
  packet$ObservationEventDesignRegistry$ConditionIncidenceIdentity <-
    paste0(
      "test-fixture-condition-incidence-S",
      packet$ObservationEventDesignRegistry$StratumCount
    )
  packet$ObservationEventDesignRegistry$ObservationEventMapIdentity <-
    paste0(
      "test-fixture-event-map-S",
      packet$ObservationEventDesignRegistry$StratumCount
    )
  packet$ObservationEventDesignRegistry$OwnerConfirmed <- TRUE
  packet$ObservationEventDesignRegistry$EvidenceIdentity <-
    "test-fixture-event-evidence"
  packet$RandomBlockMappingRegistry$StructureClass <- "unstructured"
  packet$RandomBlockMappingRegistry$MappingIdentity <- paste0(
    "test-fixture-random-map-S",
    packet$RandomBlockMappingRegistry$StratumCount, "-",
    packet$RandomBlockMappingRegistry$ComponentId
  )
  packet$RandomBlockMappingRegistry$MethodologistConfirmed <- TRUE
  packet$RandomBlockMappingRegistry$EvidenceIdentity <-
    "test-fixture-random-map-evidence"

  packet$CostRegistry$UniqueRaterOverhead <- 1
  packet$CostRegistry$CostUnitIdentity <- "test-fixture-cost-unit"
  packet$CostRegistry$OwnerConfirmed <- TRUE
  packet$CostRegistry$EvidenceIdentity <- "test-fixture-cost"

  packet$StatusQuoRegistry$ComparatorEnabled <- TRUE
  packet$StatusQuoRegistry$CurrentAllocationIdentity <- paste0(
    "test-fixture-current-allocation-S",
    packet$StatusQuoRegistry$StratumCount
  )
  packet$StatusQuoRegistry$CurrentActionRuleIdentity <-
    "test-fixture-current-action-rule"
  packet$StatusQuoRegistry$OwnerConfirmed <- TRUE
  packet$StatusQuoRegistry$EvidenceIdentity <- "test-fixture-status-quo"

  packet$AllocationFeasibilityRegistry$OperationallyFeasible <- TRUE
  packet$AllocationFeasibilityRegistry$OwnerConfirmed <- TRUE
  packet$AllocationFeasibilityRegistry$EvidenceIdentity <-
    "test-fixture-allocation"

  packet$ActionMappingRegistry$Action <- c("build", "park", "kill")
  packet$ActionMappingRegistry$OwnerConfirmed <- TRUE
  packet$ActionMappingRegistry$EvidenceIdentity <-
    "test-fixture-action-mapping"
  env$mfrmr_gtds_v3_finalize_owner_input(packet, contract)
}

skip_if_not_c4p_evidence <- function() {
  skip_if_not(
    identical(Sys.getenv("MFRMR_RUN_C4P_FIT"), "true"),
    "set MFRMR_RUN_C4P_FIT=true for the nonreserved four-route fit"
  )
  paths <- Sys.getenv(c(
    "MFRMR_C4I_RECEIPT", "MFRMR_C4L_RECEIPT", "MFRMR_C4O_MANIFEST"
  ), unset = "")
  skip_if_not(all(nzchar(paths) & file.exists(paths)),
              "set retained c4i, c4l, and revised c4o evidence paths")
}

gtvw_validation_dir <- function() {
  dirname(gtheory_multivariate_c4p_worker_path())
}

gtvw_objects <- local({
  objects <- NULL
  function(environments) {
    skip_if_not_c4p_evidence()
    if (is.null(objects)) {
      env <- environments$controller
      plan <- env$mfrmr_gtvd_plan()
      objects <<- list(
        plan = plan, generator = env$mfrmr_gtve_manifest(plan),
        repair = readRDS(Sys.getenv("MFRMR_C4I_RECEIPT")),
        integration = readRDS(Sys.getenv("MFRMR_C4L_RECEIPT")),
        envelope = readRDS(Sys.getenv("MFRMR_C4O_MANIFEST"))
      )
    }
    objects
  }
})

gtvw_manifest <- local({
  manifest <- NULL
  function(environments, objects) {
    if (is.null(manifest)) {
      manifest <<- environments$controller$mfrmr_gtvw_manifest(
        objects$plan, objects$generator, objects$envelope,
        objects$integration, objects$repair, environments$worker,
        gtvw_validation_dir(), allow_exact_reuse = TRUE
      )
      path <- Sys.getenv("MFRMR_C4P_MANIFEST_PATH", unset = "")
      if (nzchar(path)) saveRDS(manifest, path, version = 3L)
    }
    manifest
  }
})

test_that("Draft.85c4p worker and controller namespaces are exact", {
  environments <- load_gtheory_multivariate_c4p()
  worker <- environments$controller$mfrmr_gtvw_worker_identity(
    environments$worker
  )
  controller <- environments$controller$mfrmr_gtvw_implementation_identity()
  expect_identical(parent.env(environments$worker), baseenv())
  expect_identical(nrow(worker), 12L)
  expect_identical(nrow(controller), 15L)
  expect_identical(anyDuplicated(worker$Function), 0L)
  expect_identical(anyDuplicated(controller$Function), 0L)
  expect_true(all(grepl("^[0-9a-f]{64}$", worker$SHA256)))
  expect_true(all(grepl("^[0-9a-f]{64}$", controller$SHA256)))
})

test_that("Draft.85c4p consumes the revised observation-link c4o contract", {
  environments <- load_gtheory_multivariate_c4p()
  objects <- gtvw_objects(environments)
  expect_true(objects$envelope$CandidateDataObservationLinkSchemaReady)
  expect_true(objects$envelope$ObservationLinkPairIdentityReady)
  expect_true(objects$envelope$RawWithinCellReplicateRemoved)
  expect_false(objects$envelope$FitCapableWorkerImplemented)
  expect_identical(objects$envelope$C4LReceiptHash,
                   objects$integration$ReceiptHash)
  expect_identical(objects$integration$C4IRepairReceiptHash,
                   objects$repair$ReceiptHash)
})

test_that("Draft.85c4p executes all four qualified routes", {
  environments <- load_gtheory_multivariate_c4p()
  objects <- gtvw_objects(environments)
  manifest <- gtvw_manifest(environments, objects)
  environments$controller$mfrmr_gtvw_assert_manifest(manifest)
  routes <- manifest$RouteExecutionRegistry
  expect_s3_class(manifest, "mfrmr_gtvw_manifest")
  expect_identical(routes$MethodId, c(
    "lme4_reml", "glmmtmb_reml", "lme4_ml", "glmmtmb_ml"
  ))
  expect_identical(routes$QualificationRouteId, c(
    "lme4_reml", "glmmTMB_reml", "lme4_ml", "glmmTMB_ml"
  ))
  expect_true(all(routes$Attempted))
  expect_true(all(routes$BackendInvoked))
  expect_true(all(routes$FitReturned))
  expect_true(all(routes$PointEstimationGatePassed))
  expect_true(all(routes$FitStatus == "identified_point_fit"))
})

test_that("Draft.85c4p extracts the complete c1 coordinate layout", {
  environments <- load_gtheory_multivariate_c4p()
  objects <- gtvw_objects(environments)
  manifest <- gtvw_manifest(environments, objects)
  coordinates <- manifest$CoordinateEstimateRegistry
  expect_identical(nrow(coordinates), 40L)
  counts <- table(coordinates$MethodId)
  expect_identical(as.integer(counts), rep(10L, 4L))
  expect_identical(names(counts), c(
    "glmmtmb_ml", "glmmtmb_reml", "lme4_ml", "lme4_reml"
  ))
  expected_ids <- objects$plan$CoordinateLayouts$CoordinateId[
    objects$plan$CoordinateLayouts$CoordinateLayoutId == "T2-GLOBAL-3C-R1"
  ]
  for (method in objects$plan$MethodRegistry$MethodId) {
    expect_identical(
      coordinates$CoordinateId[coordinates$MethodId == method], expected_ids
    )
  }
  expect_true(all(is.finite(coordinates$Estimate)))
})

test_that("Draft.85c4p preserves backend parity in distinct fresh processes", {
  environments <- load_gtheory_multivariate_c4p()
  objects <- gtvw_objects(environments)
  manifest <- gtvw_manifest(environments, objects)
  parity <- manifest$BackendParityRegistry
  process <- manifest$ProcessRegistry
  expect_identical(parity$PairId, c("matched_reml", "matched_ml"))
  expect_true(all(parity$NumericalParityPassed))
  expect_true(all(parity$BothPointEstimationGatesPassed))
  expect_true(all(parity$MatchedBackendPointReady))
  expect_identical(nrow(process), 4L)
  expect_identical(anyDuplicated(process$ProcessId), 0L)
  expect_true(all(process$ProcessId != Sys.getpid()))
  expect_true(all(process$ExitStatus == 0L))
})

test_that("Draft.85c4p manifest is hash complete and fail closed", {
  environments <- load_gtheory_multivariate_c4p()
  objects <- gtvw_objects(environments)
  manifest <- gtvw_manifest(environments, objects)
  env <- environments$controller
  expect_identical(
    manifest$ManifestHash,
    env$mfrmr_gtvw_hash(manifest[env$mfrmr_gtvw_payload_fields()])
  )
  changed <- manifest
  changed$TruthBlindProcessBoundaryReady <- TRUE
  expect_error(env$mfrmr_gtvw_assert_manifest(changed),
               "manifest or readiness was altered")
  changed_hash <- manifest
  changed_hash$RouteExecutionRegistry$FitReturned[[1L]] <- FALSE
  changed_hash$RouteExecutionRegistryHash <- env$mfrmr_gtvw_hash(
    changed_hash$RouteExecutionRegistry
  )
  changed_hash$ManifestHash <- env$mfrmr_gtvw_hash(
    changed_hash[env$mfrmr_gtvw_payload_fields()]
  )
  expect_error(env$mfrmr_gtvw_assert_manifest(changed_hash),
               "manifest or readiness was altered")
})

test_that("Draft.85c4p keeps c3, planned, recovery, and public gates closed", {
  environments <- load_gtheory_multivariate_c4p()
  objects <- gtvw_objects(environments)
  manifest <- gtvw_manifest(environments, objects)
  audit <- manifest$PrerequisiteProjection
  truth <- audit$PrerequisiteId == "truth_blind_process_boundary"
  expect_false(any(audit$TransitionedByC4P))
  expect_identical(sum(audit$C4PProjectedSatisfied), 2L)
  expect_true(audit$FitCapableWorkerEvidenceAvailable[truth])
  expect_false(audit$FitCapableProcessIsolationEvidenceAvailable[truth])
  expect_false(manifest$TruthBlindProcessBoundaryReady)
  expect_false(manifest$PlannedExecutionOccurred)
  expect_false(manifest$RecoveryEvidenceReady)
  expect_false(manifest$PublicSupportReady)
  called <- FALSE
  callback <- function() { called <<- TRUE; TRUE }
  expect_error(env <- environments$controller$mfrmr_gtvw_dispatch_guard(
    manifest, "pilot", callback, authorize = TRUE
  ), "nonreserved fit execution only")
  expect_false(called)
})

test_that("Draft.85c4p remains absent from public surfaces", {
  public_text <- unlist(lapply(c(
    list.files(testthat::test_path("..", "..", "R"), recursive = TRUE,
               full.names = TRUE),
    list.files(testthat::test_path("..", "..", "man"), recursive = TRUE,
               full.names = TRUE),
    list.files(testthat::test_path("..", "..", "vignettes"), recursive = TRUE,
               full.names = TRUE),
    testthat::test_path("..", "..", "NEWS.md"),
    testthat::test_path("..", "..", "ROADMAP.md")
  ), function(path) {
    if (file.exists(path) && !dir.exists(path) &&
        grepl("\\.(R|Rd|Rmd|md)$", path)) {
      readLines(path, warn = FALSE, encoding = "UTF-8")
    } else character()
  }), use.names = FALSE)
  expect_false(any(grepl(
    "Draft\\.85c4p|mfrmr_gtvw[w]?_|mfrmr_gtds_", public_text
  )))
})

test_that("multivariate G-theory current-state ledger supersedes the record queue", {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  ledger_path <- file.path(
    validation, "gtheory-multivariate-current-state-ledger-0.2.4.csv"
  )
  skip_if_not(file.exists(ledger_path),
              "repository-internal validation artifacts are excluded")
  ledger <- utils::read.csv(
    ledger_path, stringsAsFactors = FALSE, check.names = FALSE
  )
  required <- c(
    "ledger_order", "control_id", "control_kind", "control_name",
    "counts_toward_execution_gate", "satisfied", "current_stage",
    "current_state", "current_evidence", "lineage_records",
    "historical_or_nonpromoting_evidence", "blocking_condition",
    "next_action", "portfolio_priority", "execution_allowed",
    "claim_ceiling", "public_support"
  )
  expect_identical(names(ledger), required)
  expect_identical(nrow(ledger), 13L)
  expect_identical(ledger$ledger_order, seq_len(13L))
  expect_identical(anyDuplicated(ledger$control_id), 0L)
  expect_true(all(!is.na(ledger$current_state) & nzchar(ledger$current_state)))
  expect_true(all(!is.na(ledger$next_action) & nzchar(ledger$next_action)))
  expect_false(any(ledger$execution_allowed))
  expect_false(any(ledger$public_support))

  prerequisites <- ledger[ledger$control_kind == "execution_prerequisite", ]
  expect_identical(nrow(prerequisites), 8L)
  expect_true(all(prerequisites$counts_toward_execution_gate))
  expect_identical(sum(prerequisites$satisfied), 2L)
  expect_setequal(
    prerequisites$control_id[prerequisites$satisfied], c("P3", "P8")
  )
  truth_blind <- prerequisites[prerequisites$control_id == "P4", ]
  expect_identical(truth_blind$current_stage, "Draft.85c4p")
  expect_identical(
    truth_blind$current_state, "blocked_fit_process_isolation_missing"
  )
  expect_match(truth_blind$next_action, "Defer c4q", fixed = TRUE)

  active <- ledger$portfolio_priority == "active_now"
  expect_identical(sum(active), 1L)
  expect_identical(ledger$control_id[active], "D0")
  expect_true(ledger$satisfied[active])
  expect_identical(
    ledger$current_stage[active],
    "D-SIM-4-worker-qualification-v1"
  )
  expect_identical(
    ledger$current_state[active],
    "dsim4_worker_qualified_static_reconciliation_passed_dsim5_closed"
  )
  expect_match(ledger$current_evidence[active],
               "14 axes and 44 levels", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "passes 7/7 deterministic criteria", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "21 outcome-blind cells", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "42 dataset attempts", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "47/47 separate-univariate G/Phi truth coefficients",
               fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "51/51 shadow fits", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "42/42 datasets and 50/50 candidate routes", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "92/92 exact terminal receipts", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "98/100 metrics", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "D3-S012 replicate 2", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "21 singular/convergence-message calls", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "92/92 exact terminal requests", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "289 total", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "reuses one stochastic core with zero copies", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "42/42 exact 856 requests", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "21/21 nonreserved profiles", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "5/5 frozen artifact identities", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "8/8 current environment identities", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "289/289 request/qualified-path joins", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "10/10 readiness gates", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "184 of 188 planned", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "ABS-PHI RMSE 0.05240607", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "REL-G RMSE 0.05008863", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "maximum absolute error 0.3240437", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "40/40 within-backend parity", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "passes 8/8 scientific criteria", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "closes 14/14 requirements", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "six profiles covering all four scenario roles", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "all 37 dataset-axis levels", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "15,000 outer attempts and 995,000 inner bootstrap attempts",
               fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "95% full-refit parametric-bootstrap percentile interval",
               fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "passes 10/10 qualification gates", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "2,022,500 backend calls", fixed = TRUE)
  expect_match(ledger$current_evidence[active],
               "199 route-level bootstrap attempts, 398 refits, and 796",
               fixed = TRUE)
  expect_match(ledger$blocking_condition[active],
               "no shardable launch input", fixed = TRUE)
  expect_match(ledger$next_action[active],
               "Package the exact reconciled requests into restartable shards",
               fixed = TRUE)
  expect_identical(
    ledger$claim_ceiling[active],
    "descriptive_recovery_evidence_only_nonconfirmatory"
  )
  expect_match(ledger$historical_or_nonpromoting_evidence[active],
               "owner packet", fixed = TRUE)
  expect_match(ledger$historical_or_nonpromoting_evidence[active],
               "0/14 frozen requirements is historical", fixed = TRUE)
  expect_match(ledger$historical_or_nonpromoting_evidence[active],
               "worker qualification are contract/mechanics evidence",
               fixed = TRUE)
  expect_false(ledger$execution_allowed[active])

  record_paths <- list.files(
    validation,
    pattern = "^gtheory-multivariate-.*-record-0[.]2[.][34][.]md$",
    full.names = TRUE
  )
  listed <- unique(Filter(
    nzchar,
    unlist(strsplit(ledger$lineage_records, ";", fixed = TRUE))
  ))
  expect_setequal(listed, basename(record_paths))
})

test_that("D-SIM-0 is deterministic, bounded, and execution closed", {
  environments <- load_gtheory_multivariate_c4p()
  env <- environments$controller
  contract <- env$mfrmr_gtds_contract()
  expect_invisible(env$mfrmr_gtds_validate_contract(contract))
  expect_identical(contract$PrimaryCoefficient, "Phi")
  expect_identical(contract$SecondarySensitivity, "G")
  expect_identical(contract$PrimaryTarget, 0.80)
  expect_false(contract$OwnerSignoffReady)
  expect_false(contract$SimulationExecutionAllowed)
  expect_false(contract$PlannedSeedAccessAllowed)
  expect_false(contract$PublicSupportReady)
  expect_identical(vapply(
    contract$AllocationRegistry, nrow, integer(1L)
  ), c(S2 = 6L, S3 = 6L))
  weight_sums <- tapply(
    contract$WeightRegistry$Weight,
    contract$WeightRegistry$StratumCount,
    sum
  )
  expect_equal(as.numeric(weight_sums), c(1, 1), tolerance = 1e-12)
  changed <- contract
  changed$PrimaryTarget <- 0.75
  expect_error(env$mfrmr_gtds_validate_contract(changed), "altered")
})

test_that("D-SIM-0 chooses one minimum-cost allocation with a fixed tie break", {
  environments <- load_gtheory_multivariate_c4p()
  env <- environments$controller
  projection <- env$mfrmr_gtds_projection(
    c(0.70, 0.78, 0.82, 0.80, 0.86, 0.90), 2L
  )
  choice <- env$mfrmr_gtds_select_allocation(projection, 2L)
  expect_identical(choice$SelectionStatus, "selected")
  expect_identical(choice$AllocationId, "A03_R4_K1")
  expect_identical(choice$CostPerObject, 8L)
  expect_identical(choice$RatersPerObject, 4L)

  none <- env$mfrmr_gtds_select_allocation(
    env$mfrmr_gtds_projection(rep(0.79, 6L), 2L), 2L
  )
  expect_identical(none$SelectionStatus, "no_allocation_meets_target")
  expect_true(is.na(none$AllocationId))
})

test_that("D-SIM-0 classifies decision errors rather than recovery rows", {
  environments <- load_gtheory_multivariate_c4p()
  env <- environments$controller
  truth <- env$mfrmr_gtds_projection(
    c(0.70, 0.78, 0.82, 0.80, 0.86, 0.90), 2L
  )
  exact <- env$mfrmr_gtds_classify_decision(
    truth, env$mfrmr_gtds_projection(
      c(0.68, 0.77, 0.81, 0.79, 0.85, 0.89), 2L
    ), 2L
  )
  expect_identical(exact$DecisionStatus, "exact_allocation_agreement")
  expect_true(exact$OracleMinimumCostAllocationAgreement)

  false_safe <- env$mfrmr_gtds_classify_decision(
    truth, env$mfrmr_gtds_projection(
      c(0.81, 0.79, 0.78, 0.77, 0.76, 0.75), 2L
    ), 2L
  )
  expect_identical(false_safe$DecisionStatus, "false_safe")
  expect_true(false_safe$FalseSafeAllocation)
  expect_equal(false_safe$CoefficientShortfall, 0.10)

  false_conservative <- env$mfrmr_gtds_classify_decision(
    truth, env$mfrmr_gtds_projection(rep(0.79, 6L), 2L), 2L
  )
  expect_identical(false_conservative$DecisionStatus, "false_conservative")
  expect_true(false_conservative$FalseConservativeAllocation)

  safe_regret <- env$mfrmr_gtds_classify_decision(
    truth, env$mfrmr_gtds_projection(
      c(0.70, 0.70, 0.70, 0.70, 0.81, 0.82), 2L
    ), 2L
  )
  expect_identical(safe_regret$DecisionStatus, "safe_cost_regret")
  expect_identical(safe_regret$SafeCostRegret, 4L)

  no_feasible_truth <- env$mfrmr_gtds_projection(rep(0.79, 6L), 2L)
  neither <- env$mfrmr_gtds_classify_decision(
    no_feasible_truth, env$mfrmr_gtds_projection(rep(0.75, 6L), 2L), 2L
  )
  expect_identical(neither$DecisionStatus, "exact_no_feasible_allocation")
  expect_true(neither$OracleMinimumCostAllocationAgreement)
  expect_identical(neither$SafeCostRegret, 0L)

  malformed <- truth[-1L, ]
  expect_error(env$mfrmr_gtds_select_allocation(malformed, 2L),
               "exact six-allocation")
})

test_that("D-SIM-0 v2 closes the audited estimand and denominator gaps", {
  environments <- load_gtheory_multivariate_c4p()
  env <- environments$controller
  contract <- env$mfrmr_gtds_v2_contract()
  expect_invisible(env$mfrmr_gtds_v2_validate_contract(contract))
  expect_identical(
    contract$PrimaryDecision,
    "absolute_composite_score_dependability_not_cut_score_classification"
  )
  expect_identical(contract$DecisionTolerance, 1e-12)
  expect_identical(contract$PrimaryMetric, "unsafe_or_unresolved_rate")
  expect_identical(
    contract$CurrentComparator,
    "separate_univariate_all_strata_threshold"
  )
  expect_identical(
    contract$ComponentOperatorRegistry$OffDiagonalOperatorFormula,
    c("1", "1 / n_rater", "1 / n_rater", "0")
  )
  expect_false(contract$OwnerSignoffReady)
  expect_false(contract$Dsim0Satisfied)
  expect_false(contract$SimulationExecutionAllowed)
  expect_false(contract$PlannedSeedAccessAllowed)
  expect_false(contract$PublicSupportReady)
  expect_true(all(!contract$SignoffRequirements$Confirmed))

  changed <- contract
  changed$DecisionTolerance <- 0
  expect_error(env$mfrmr_gtds_v2_validate_contract(changed), "altered")
  candidate <- env$mfrmr_gtds_v2_signoff_candidate(contract)
  expect_error(
    env$mfrmr_gtds_v2_validate_signed_receipt(candidate, contract),
    "unsigned or invalid"
  )
  signed_fixture <- candidate
  signed_fixture$SignerId <- "TEST-FIXTURE-NOT-AUTHORIZATION"
  signed_fixture$SignedAtUtc <- "2026-08-29T00:00:00Z"
  signed_fixture$ExternalDecisionAnchorType <- "timestamped_signed_record"
  signed_fixture$ExternalDecisionAnchor <- "TEST-FIXTURE-ANCHOR"
  signed_fixture$Requirements$Confirmed <- TRUE
  signed_fixture$Requirements$Evidence <- "test fixture only"
  signed_fixture$ReceiptStatus <- "owner_signed_externally_anchored"
  signed_fixture$Dsim0Satisfied <- TRUE
  signed_payload <- unclass(signed_fixture)
  signed_payload$ReceiptHash <- NULL
  signed_fixture$ReceiptHash <- env$mfrmr_gta_hash(signed_payload)
  expect_invisible(
    env$mfrmr_gtds_v2_validate_signed_receipt(signed_fixture, contract)
  )
})

test_that("D-SIM-0 v2 repository sign-off packet stays unsigned and bound", {
  environments <- load_gtheory_multivariate_c4p()
  env <- environments$controller
  contract <- env$mfrmr_gtds_v2_contract()
  path <- file.path(
    gtvw_validation_dir(),
    "gtheory-multivariate-decision-simulation-signoff-candidate-0.2.4.csv"
  )
  skip_if_not(file.exists(path),
              "repository-internal validation artifacts are excluded")
  packet <- utils::read.csv(
    path, stringsAsFactors = FALSE, check.names = FALSE, na.strings = NULL
  )
  expect_identical(nrow(packet), 10L)
  expect_identical(packet$RequirementOrdinal, seq_len(10L))
  expect_identical(
    packet$RequirementId, contract$SignoffRequirements$RequirementId
  )
  expect_identical(
    packet$RequiredConfirmation,
    contract$SignoffRequirements$RequiredConfirmation
  )
  expect_true(all(packet$ContractId == contract$ContractId))
  expect_true(all(packet$ContractHash == contract$ContractHash))
  expect_true(all(!packet$Confirmed))
  expect_true(all(is.na(packet$Evidence)))
  expect_true(all(is.na(packet$SignerId)))
  expect_true(all(is.na(packet$SignedAtUtc)))
  expect_true(all(is.na(packet$ExternalDecisionAnchor)))
  expect_true(all(packet$ReceiptStatus == "candidate_unsigned"))
})

test_that("D-SIM-0 v2 uses one tolerance for target and false-safe decisions", {
  environments <- load_gtheory_multivariate_c4p()
  env <- environments$controller
  contract <- env$mfrmr_gtds_v2_contract()
  at_mathematical_target <- 1.2 / 1.5
  expect_true(at_mathematical_target < 0.80)
  projection <- env$mfrmr_gtds_v2_projection(
    c(at_mathematical_target, rep(0.70, 5L)), 2L
  )
  choice <- env$mfrmr_gtds_v2_select_allocation(
    projection, 2L, contract
  )
  expect_identical(choice$AllocationId, "A01_R2_K1")

  within_tolerance <- 0.80 - contract$DecisionTolerance / 2
  below_tolerance <- 0.80 - contract$DecisionTolerance * 2
  expect_true(env$mfrmr_gtds_v2_meets_target(within_tolerance, contract))
  expect_false(env$mfrmr_gtds_v2_meets_target(below_tolerance, contract))

  truth <- env$mfrmr_gtds_v2_projection(
    c(within_tolerance, rep(0.70, 5L)), 2L
  )
  estimate <- env$mfrmr_gtds_v2_projection(
    c(0.81, rep(0.70, 5L)), 2L
  )
  safe <- env$mfrmr_gtds_v2_classify_decision(
    truth, estimate, 2L, contract
  )
  expect_false(safe$FalseSafeAllocation)

  unsafe_truth <- env$mfrmr_gtds_v2_projection(
    c(below_tolerance, rep(0.70, 5L)), 2L
  )
  unsafe <- env$mfrmr_gtds_v2_classify_decision(
    unsafe_truth, estimate, 2L, contract
  )
  expect_true(unsafe$FalseSafeAllocation)
  expect_true(unsafe$UnsafeOrUnresolved)
})

test_that("D-SIM-0 v2 comparator never averages stratum coefficients", {
  environments <- load_gtheory_multivariate_c4p()
  env <- environments$controller
  values <- matrix(c(
    0.90, 0.70,
    0.80, 0.80,
    0.85, 0.85,
    0.90, 0.90,
    0.92, 0.92,
    0.94, 0.94
  ), nrow = 6L, byrow = TRUE)
  projection <- env$mfrmr_gtds_v2_univariate_projection(values, 2L)
  choice <- env$mfrmr_gtds_v2_select_univariate_comparator(projection, 2L)
  expect_equal(mean(values[1L, ]), 0.80)
  expect_identical(choice$AllocationId, "A02_R3_K1")
  expect_identical(choice$CostPerObject, 6L)

  three <- matrix(0.81, nrow = 6L, ncol = 3L)
  three[1L, 3L] <- 0.79
  choice_three <- env$mfrmr_gtds_v2_select_univariate_comparator(
    env$mfrmr_gtds_v2_univariate_projection(three, 3L), 3L
  )
  expect_identical(choice_three$AllocationId, "A02_R3_K1")
  expect_identical(choice_three$CostPerObject, 9L)
})

test_that("D-SIM-0 v2 counts every unresolved attempt against primary safety", {
  environments <- load_gtheory_multivariate_c4p()
  env <- environments$controller
  truth <- env$mfrmr_gtds_v2_projection(
    c(0.70, 0.78, 0.82, 0.80, 0.86, 0.90), 2L
  )
  exact <- env$mfrmr_gtds_v2_classify_attempt(
    truth,
    env$mfrmr_gtds_v2_projection(
      c(0.68, 0.77, 0.81, 0.79, 0.85, 0.89), 2L
    ), 2L
  )
  false_safe <- env$mfrmr_gtds_v2_classify_attempt(
    truth,
    env$mfrmr_gtds_v2_projection(
      c(0.81, 0.79, 0.78, 0.77, 0.76, 0.75), 2L
    ), 2L
  )
  fit_failure <- env$mfrmr_gtds_v2_classify_attempt(
    truth, stratum_count = 2L, terminal_status = "fit_failure"
  )
  indeterminate <- env$mfrmr_gtds_v2_classify_attempt(
    truth, stratum_count = 2L, terminal_status = "indeterminate"
  )
  summary <- env$mfrmr_gtds_v2_summarize_attempts(list(
    exact, false_safe, fit_failure, indeterminate
  ))
  expect_identical(summary$AllAttemptCount, 4L)
  expect_identical(summary$DecisionCompleteCount, 2L)
  expect_identical(summary$UnsafeOrUnresolvedCount, 3L)
  expect_equal(summary$UnsafeOrUnresolvedRate, 0.75)
  expect_identical(summary$FalseSafeCount, 1L)
  expect_equal(summary$FalseSafeRateAmongDecisionComplete, 0.50)
  expect_identical(summary$FitFailureCount, 1L)
  expect_identical(summary$IndeterminateCount, 1L)

  mixed_contract <- exact
  mixed_contract$ContractHash <- paste0("different-", exact$ContractHash)
  expect_error(
    env$mfrmr_gtds_v2_summarize_attempts(list(exact, mixed_contract)),
    "one identical contract hash"
  )
})

test_that("D-SIM-0 v2 selection is exhaustive for both stratum counts", {
  environments <- load_gtheory_multivariate_c4p()
  env <- environments$controller
  contract <- env$mfrmr_gtds_v2_contract()
  patterns <- expand.grid(rep(list(c(FALSE, TRUE)), 6L))
  for (stratum_count in c(2L, 3L)) {
    registry <- env$mfrmr_gtds_v2_allocation_registry(stratum_count)
    for (index in seq_len(nrow(patterns))) {
      eligible <- as.logical(patterns[index, ])
      projection <- env$mfrmr_gtds_v2_projection(
        ifelse(eligible, 0.80, 0.79), stratum_count
      )
      observed <- env$mfrmr_gtds_v2_select_allocation(
        projection, stratum_count, contract
      )
      candidates <- registry[eligible, , drop = FALSE]
      expected <- if (nrow(candidates) == 0L) NA_character_ else {
        candidates$AllocationId[order(
          candidates$CostPerObject, -candidates$RatersPerObject,
          candidates$ReplicatesPerObjectRater, candidates$AllocationId,
          method = "radix"
        )[[1L]]]
      }
      expect_identical(observed$AllocationId, expected)
    }
  }
})

test_that("D-SIM-0 v3 bounds a two-family multiverse without pooling", {
  environments <- load_gtheory_multivariate_c4p()
  env <- environments$controller
  contract <- gtheory_multiverse_v3_contract(environments)
  expect_invisible(env$mfrmr_gtds_v3_validate_contract(contract))
  expect_identical(
    contract$DecisionFamilyRegistry$DecisionFamilyId,
    c("ABS-PHI", "REL-G")
  )
  expect_identical(
    contract$DecisionFamilyRegistry$Coefficient, c("Phi", "G")
  )
  expect_true(all(!contract$DecisionFamilyRegistry$CrossFamilyPoolingAllowed))
  expect_true(all(!contract$DecisionFamilyRegistry$CrossFamilyVotingAllowed))
  expect_identical(
    contract$ReferenceProfileContractId,
    "MFRMR-GTHEORY-MV-DSIM0-PHI-V2"
  )
  expect_identical(
    contract$ReferenceProfileContractHash,
    env$mfrmr_gtds_v2_contract()$ContractHash
  )
  profile_counts <- table(contract$ProfileRegistry$DecisionFamilyId)
  sentinel_counts <- table(contract$SentinelProfileRegistry$DecisionFamilyId)
  expect_identical(as.integer(profile_counts), c(108L, 108L))
  expect_identical(names(profile_counts), c("ABS-PHI", "REL-G"))
  expect_identical(as.integer(sentinel_counts), c(11L, 11L))
  expect_identical(names(sentinel_counts), c("ABS-PHI", "REL-G"))
  expect_true(all(contract$ProfileRegistry$DecisionBearing))
  expect_true(all(contract$ProfileRegistry$FullEnumerationComplete))
  expect_true(all(!contract$ProfileRegistry$OwnerInputsComplete))
  expect_true(all(!contract$SentinelProfileRegistry$DecisionBearing))
  expect_true(contract$FullProfileEnumerationRequired)
  expect_false(contract$SentinelProfilesDecisionBearing)
  expect_false(contract$ProfileSelectionUsesOutcomes)
  expect_false(contract$MajorityVoteAcrossProfilesAllowed)
  expect_false(contract$ProfilesCountAsIndependentReplicates)
  expect_false(contract$ProjectionRowsCountAsIndependentDatasets)
  expect_identical(
    contract$ImplementationIdentity,
    env$mfrmr_gtds_v3_implementation_identity()
  )
  expect_identical(
    contract$ImplementationIdentityHash,
    env$mfrmr_gta_hash(contract$ImplementationIdentity)
  )
})

test_that("D-SIM-0 v3 exhausts decisions and pairwise-covers sentinels", {
  environments <- load_gtheory_multivariate_c4p()
  env <- environments$controller
  contract <- gtheory_multiverse_v3_contract(environments)
  axis_ids <- unique(contract$AxisRegistry$AxisId)
  full_grid <- env$mfrmr_gtds_v3_profile_grid(contract$AxisRegistry)
  full_tokens <- sort(unique(unlist(lapply(
    seq_len(nrow(full_grid)), function(index) {
      env$mfrmr_gtds_v3_pair_tokens(
        full_grid[index, , drop = FALSE], axis_ids
      )
    }
  ))), method = "radix")
  expect_identical(length(full_tokens), 67L)
  for (family in contract$DecisionFamilyRegistry$DecisionFamilyId) {
    profiles <- contract$ProfileRegistry[
      contract$ProfileRegistry$DecisionFamilyId == family, , drop = FALSE
    ]
    expect_identical(nrow(profiles), 108L)
    expect_setequal(profiles$ProfileSignature, full_grid$ProfileSignature)
    expect_true(all(profiles$DecisionBearing))
    expect_identical(sum(profiles$SentinelProfile), 11L)

    sentinels <- contract$SentinelProfileRegistry[
      contract$SentinelProfileRegistry$DecisionFamilyId == family,
      , drop = FALSE
    ]
    covered <- sort(unique(unlist(lapply(
      seq_len(nrow(sentinels)), function(index) {
        env$mfrmr_gtds_v3_pair_tokens(
          sentinels[index, , drop = FALSE], axis_ids
        )
      }
    ))), method = "radix")
    expect_setequal(covered, full_tokens)
    expect_lte(
      nrow(sentinels), contract$MaximumSentinelProfilesPerDecisionFamily
    )
    expect_true(all(!sentinels$DecisionBearing))
    expect_setequal(
      profiles$ProfileSignature[profiles$SentinelProfile],
      sentinels$ProfileSignature
    )
    anchor <- sentinels[sentinels$ReferenceProfile, , drop = FALSE]
    expect_identical(anchor$ProfileId, paste0(family, "-P00"))
    expect_identical(
      anchor$ProfileSignature,
      paste(
        "reference", "equal_common_unit", "common", "rating_event_only",
        "all_strata_threshold", sep = "|"
      )
    )
  }
})

test_that("D-SIM-0 v3 separates worlds, projections, and route parity", {
  environments <- load_gtheory_multivariate_c4p()
  contract <- gtheory_multiverse_v3_contract(environments)
  roles <- table(contract$WorldRegistry$DecisionEvidenceRole)
  expect_identical(
    unname(as.integer(roles[c(
      "primary_decision_stress", "safety_boundary_only",
      "structural_negative_control"
    )])), c(8L, 4L, 2L)
  )
  expect_true(all(!contract$WorldRegistry$PlannedResponseGenerated))
  routes <- contract$AnalysisRouteRegistry
  expect_identical(nrow(routes), 7L)
  expect_identical(sum(routes$EstimandGroup == "multivariate_reml"), 2L)
  expect_identical(
    sum(routes$EstimandGroup == "separate_univariate_reml"), 2L
  )
  expect_identical(
    routes$EvidenceRole[routes$RouteId == "mv_reml_glmmtmb"],
    "primary_candidate_implementation"
  )
  expect_identical(
    routes$EvidenceRole[routes$RouteId == "mv_reml_lme4"],
    "design_restricted_sensitivity_only"
  )
  expect_setequal(
    routes$RouteId[routes$GeneralMultivariateGTheoryEligible],
    c("mv_reml_glmmtmb", "mv_ml_glmmtmb")
  )
  expect_setequal(
    routes$RouteId[routes$CorrelatedResidualCapable],
    c("mv_reml_glmmtmb", "mv_ml_glmmtmb")
  )
  expect_true(all(!routes$NativeLevelOneCorrelatedResidualApi))
  expect_true(all(
    routes$ResidualRepresentation[
      routes$RouteId %in% c("mv_reml_glmmtmb", "mv_ml_glmmtmb")
    ] ==
      "observation_event_random_effect_block_plus_suppressed_dispersion"
  ))
  expect_true(all(
    routes$ResidualRepresentation[
      routes$RouteId %in% c("mv_reml_lme4", "mv_ml_lme4")
    ] == "one_scale_times_known_diagonal_inverse_weights"
  ))
  lme4_eligibility <- routes$EligibilityCondition[
    routes$RouteId == "mv_reml_lme4"
  ]
  expect_match(lme4_eligibility, "us, diag, cs, or ar1", fixed = TRUE)
  expect_match(
    lme4_eligibility,
    "one scale times known diagonal weights",
    fixed = TRUE
  )
  expect_true(all(!routes$CountsAsIndependentEstimandVote))
  expect_true(all(!routes$PublicSupportReady))

  expect_identical(nrow(contract$CovarianceDesignRegistry), 4L)
  expect_true(all(!contract$CovarianceDesignRegistry$Lme4GeneralRouteAllowed))
  expect_true(all(
    contract$CovarianceDesignRegistry$CurrentBindingStatus[1:3] ==
      "pending_before_DSIM1"
  ))
  expect_identical(
    contract$CovarianceDesignRegistry$DesignId[
      contract$CovarianceDesignRegistry$RepresentedByCurrentC1
    ],
    "current_c1_matched_backend_overlap"
  )
  expect_identical(
    contract$CovarianceDesignRegistry$CurrentBindingStatus[[4L]],
    "implemented_candidate_requires_operational_design_match"
  )
  expect_identical(
    contract$WeightPolicyRegistry$DecisionBearingAllowed,
    c(TRUE, FALSE, FALSE)
  )
  expect_true(all(contract$MeasurementLayerRegistry$ConflationProhibited))
  expect_true(all(
    !contract$ComplementaryDiagnosticRegistry$SubstitutesForOtherMethod
  ))
  expect_true(all(
    !contract$ComplementaryDiagnosticRegistry$CountsAsDecisionVote
  ))
  expect_true(contract$CovarianceDesignBindingRequiredBeforeDsim1)
  expect_false(contract$CovarianceDesignBindingReady)
  expect_true(contract$CovarianceBindingSchemaReady)
  expect_true(contract$BackendDesignQualificationReady)
  expect_false(contract$BackendQualificationExecutionAllowed)
  expect_true(contract$AdjudicationRoutingSchemaReady)
  expect_false(contract$AdjudicationExecutionAllowed)
  expect_identical(nrow(contract$AdjudicationRoutingSchema), 13L)
  expect_identical(
    contract$AdjudicationRoutingSchema$InputId,
    contract$OwnerInputSchema$InputId
  )
  expect_true(all(
    !contract$AdjudicationRoutingSchema$OutcomeDataMayResolve
  ))
  expect_identical(
    contract$CurrentC1CovarianceClaim, "matched_backend_overlap_only"
  )
  expect_true(contract$EffectiveWeightsDiagnosticOnly)
  expect_false(contract$DataDrivenWeightsDecisionBearing)
  expect_false(contract$FacetCountDefinesLatentDimension)
  expect_false(contract$MfrmDiagnosticCountsAsDecisionVote)
})

test_that("D-SIM-0 v3 derives backend eligibility from event identity", {
  environments <- load_gtheory_multivariate_c4p()
  env <- environments$controller
  events <- env$mfrmr_gtds_v3_observation_event_design_candidate()
  blocks <- env$mfrmr_gtds_v3_random_block_mapping_candidate()
  expect_invisible(
    env$mfrmr_gtds_v3_validate_covariance_binding(events, blocks)
  )
  expect_error(
    env$mfrmr_gtds_v3_validate_covariance_binding(
      events, blocks, require_complete = TRUE
    ),
    "incomplete"
  )

  events$ConditionSetRelationship <- "disjoint_by_stratum"
  events$ObservationEventRelationship <-
    "distinct_event_per_stratum_score"
  events$ConditionIncidenceIdentity <- paste0(
    "test-condition-incidence-S", events$StratumCount
  )
  events$ObservationEventMapIdentity <- paste0(
    "test-event-map-S", events$StratumCount
  )
  events$OwnerConfirmed <- TRUE
  events$EvidenceIdentity <- "test-event-evidence"
  blocks$StructureClass <- "unstructured"
  blocks$MappingIdentity <- paste0(
    "test-random-map-S", blocks$StratumCount, "-", blocks$ComponentId
  )
  blocks$MethodologistConfirmed <- TRUE
  blocks$EvidenceIdentity <- "test-random-evidence"
  expect_invisible(
    env$mfrmr_gtds_v3_validate_covariance_binding(
      events, blocks, require_complete = TRUE
    )
  )

  distinct <- env$mfrmr_gtds_v3_backend_design_qualification(
    events, blocks
  )
  expect_identical(nrow(distinct), 14L)
  expect_true(all(!distinct$ExecutionAllowed))
  expect_setequal(
    distinct$RouteId[distinct$BackendDesignEligible],
    c(
      "mv_reml_glmmtmb", "mv_ml_glmmtmb",
      "mv_reml_lme4", "mv_ml_lme4"
    )
  )
  expect_true(all(
    distinct$ResidualBlock == "diagonal_across_strata"
  ))

  shared <- events
  shared$ObservationEventRelationship <-
    "one_event_yields_multiple_stratum_scores"
  linked <- env$mfrmr_gtds_v3_backend_design_qualification(shared, blocks)
  expect_setequal(
    linked$RouteId[linked$BackendDesignEligible],
    c("mv_reml_glmmtmb", "mv_ml_glmmtmb")
  )
  expect_true(all(
    linked$EligibilityStatus[
      linked$RouteId %in% c("mv_reml_lme4", "mv_ml_lme4")
    ] == "ineligible_correlated_level1_residual"
  ))

  explicit_event <- events
  explicit_event$ObservationEventRelationship <- "mixed_explicit_event_map"
  custom_event <- env$mfrmr_gtds_v3_backend_design_qualification(
    explicit_event, blocks
  )
  expect_false(any(custom_event$BackendDesignEligible))
  expect_true(all(
    custom_event$EligibilityStatus[
      custom_event$RouteId %in% c(
        "mv_reml_glmmtmb", "mv_ml_glmmtmb",
        "mv_reml_lme4", "mv_ml_lme4"
      )
    ] == "custom_contract_required"
  ))

  explicit_block <- blocks
  explicit_block$StructureClass[
    explicit_block$ComponentId == "Object:Rater"
  ] <- "explicit_mask_or_other"
  custom_block <- env$mfrmr_gtds_v3_backend_design_qualification(
    events, explicit_block
  )
  expect_false(any(custom_block$BackendDesignEligible))

  malformed <- events
  malformed$ObservationEventRelationship[[1L]] <- "convenient_guess"
  expect_error(
    env$mfrmr_gtds_v3_validate_covariance_binding(malformed, blocks),
    "malformed"
  )
})

test_that("D-SIM-0 v3 routes adjudication without outcome evidence", {
  environments <- load_gtheory_multivariate_c4p()
  env <- environments$controller
  contract <- gtheory_multiverse_v3_contract(environments)
  candidate <- env$mfrmr_gtds_v3_owner_input_candidate(contract)
  plan <- env$mfrmr_gtds_v3_adjudication_plan(candidate, contract)

  expect_identical(nrow(plan), 21L)
  expect_identical(plan$WorkOrdinal, seq_len(21L))
  expect_identical(
    as.integer(table(plan$WorkLayer)[c(
      "owner_decision", "observation_event_binding",
      "random_block_binding"
    )]),
    c(13L, 2L, 6L)
  )
  expect_identical(
    sort(unique(plan$WorkLayer)),
    c("observation_event_binding", "owner_decision",
      "random_block_binding")
  )
  expect_true(all(plan$ContractHash == contract$ContractHash))
  expect_true(all(plan$PacketHash == candidate$PacketHash))
  expect_true(all(!plan$Ready))
  expect_true(all(plan$MissingCount > 0L))
  expect_true(all(!plan$OutcomeDataMayResolve))
  expect_true(all(!plan$ExecutionAllowed))

  owner_rows <- plan$WorkLayer == "owner_decision"
  expect_identical(
    plan$SubtaskId[owner_rows], contract$OwnerInputSchema$InputId
  )
  expect_identical(
    plan$BlockingDependencyInputIds[
      plan$SubtaskId == "target_triplets"
    ],
    "decision_family_enablement"
  )
  expect_match(
    plan$RecommendedPredecessorInputIds[
      plan$SubtaskId == "action_mapping"
    ],
    "candidate_allocation_feasibility", fixed = TRUE
  )
  event_rows <- plan$WorkLayer == "observation_event_binding"
  random_rows <- plan$WorkLayer == "random_block_binding"
  expect_identical(plan$MissingCount[event_rows], rep(6L, 2L))
  expect_identical(plan$MissingCount[random_rows], rep(4L, 6L))
  expect_true(all(
    plan$RequiredConfirmationRole[event_rows] == "practical_owner"
  ))
  expect_true(all(
    plan$RequiredConfirmationRole[random_rows] ==
      "independent_methodologist"
  ))
  expect_true(all(
    plan$ResolutionIfUnsupported[random_rows] ==
      "classify_as_explicit_mask_or_other_and_issue_custom_contract"
  ))

  complete <- gtheory_multiverse_v3_complete_owner_fixture(env, contract)
  complete_plan <- env$mfrmr_gtds_v3_adjudication_plan(complete, contract)
  expect_true(all(complete_plan$Ready))
  expect_true(all(complete_plan$MissingCount == 0L))
  expect_true(all(!complete_plan$OutcomeDataMayResolve))
  expect_true(all(!complete_plan$ExecutionAllowed))
})

test_that("D-SIM-0 v3 requires a hashed owner-input packet before signing", {
  environments <- load_gtheory_multivariate_c4p()
  env <- environments$controller
  contract <- gtheory_multiverse_v3_contract(environments)
  expect_true(contract$OwnerInputPacketRequired)
  expect_false(contract$OwnerInputPacketReady)
  expect_true(is.na(contract$OwnerInputPacketHash))
  expect_identical(nrow(contract$OwnerInputSchema), 13L)
  expect_true(contract$OwnerDecisionBriefSchemaReady)
  expect_identical(nrow(contract$OwnerDecisionBriefSchema), 13L)
  expect_true(all(!contract$OwnerInputSchema$OwnerInputPresent))
  expect_true(all(!contract$SignoffRequirements$Confirmed))

  owner_candidate <- env$mfrmr_gtds_v3_owner_input_candidate(contract)
  expect_invisible(
    env$mfrmr_gtds_v3_validate_owner_input(owner_candidate, contract)
  )
  expect_error(
    env$mfrmr_gtds_v3_validate_owner_input(
      owner_candidate, contract, require_complete = TRUE
    ),
    "incomplete or not owner-confirmed"
  )
  candidate_brief <- env$mfrmr_gtds_v3_owner_decision_brief(
    owner_candidate, contract
  )
  expect_identical(nrow(candidate_brief), 13L)
  expect_identical(
    candidate_brief$InputId, contract$OwnerInputSchema$InputId
  )
  expect_true(all(!candidate_brief$Ready))
  expect_true(all(candidate_brief$MissingCount > 0L))
  expect_identical(
    candidate_brief$CurrentState[c(2L, 3L, 5L, 6L)],
    rep("blocked_by_family_enablement", 4L)
  )
  expect_true(all(candidate_brief$BriefStatus == "owner_decisions_pending"))
  expect_true(all(!candidate_brief$SimulationExecutionAllowed))
  owner_fixture <- gtheory_multiverse_v3_complete_owner_fixture(
    env, contract
  )
  expect_invisible(
    env$mfrmr_gtds_v3_validate_owner_input(
      owner_fixture, contract, require_complete = TRUE
    )
  )
  complete_brief <- env$mfrmr_gtds_v3_owner_decision_brief(
    owner_fixture, contract
  )
  expect_true(all(complete_brief$Ready))
  expect_true(all(complete_brief$MissingCount == 0L))
  expect_true(all(complete_brief$PacketReady))
  expect_true(all(
    complete_brief$BriefStatus ==
      "owner_inputs_complete_packet_finalized_unanchored"
  ))
  expect_true(all(!complete_brief$SimulationExecutionAllowed))

  candidate <- env$mfrmr_gtds_v3_signoff_candidate(contract)
  expect_error(
    env$mfrmr_gtds_v3_validate_signed_receipt(
      candidate, owner_candidate, contract
    ),
    "incomplete or not owner-confirmed"
  )
  signed_fixture <- candidate
  signed_fixture$SignerId <- "TEST-FIXTURE-NOT-AUTHORIZATION"
  signed_fixture$SignedAtUtc <- "2026-08-29T00:00:00Z"
  signed_fixture$ExternalDecisionAnchorType <- "timestamped_signed_record"
  signed_fixture$ExternalDecisionAnchor <- "TEST-FIXTURE-ANCHOR"
  signed_fixture$OwnerInputPacketHash <- owner_fixture$PacketHash
  signed_fixture$OwnerInputPacketExternalAnchor <-
    "TEST-FIXTURE-OWNER-INPUT-ANCHOR"
  signed_fixture$Requirements$Confirmed <- TRUE
  signed_fixture$Requirements$Evidence <- "test fixture only"
  signed_fixture$ReceiptStatus <- "owner_signed_externally_anchored"
  signed_fixture$Dsim0Satisfied <- TRUE
  signed_payload <- unclass(signed_fixture)
  signed_payload$ReceiptHash <- NULL
  signed_fixture$ReceiptHash <- env$mfrmr_gta_hash(signed_payload)
  expect_invisible(
    env$mfrmr_gtds_v3_validate_signed_receipt(
      signed_fixture, owner_fixture, contract
    )
  )

  altered_owner <- owner_fixture
  altered_owner$CostRegistry$UniqueRaterOverhead <- 2
  expect_error(
    env$mfrmr_gtds_v3_validate_signed_receipt(
      signed_fixture, altered_owner, contract
    ),
    "malformed or hash-altered"
  )

  changed <- contract
  changed$MajorityVoteAcrossProfilesAllowed <- TRUE
  expect_error(env$mfrmr_gtds_v3_validate_contract(changed), "altered")
})

test_that("D-SIM-0 v3 repository packets remain empty and hash bound", {
  environments <- load_gtheory_multivariate_c4p()
  contract <- gtheory_multiverse_v3_contract(environments)
  validation <- gtvw_validation_dir()
  input_path <- file.path(
    validation,
    "gtheory-multivariate-decision-multiverse-owner-input-candidate-0.2.4.csv"
  )
  signoff_path <- file.path(
    validation,
    "gtheory-multivariate-decision-multiverse-signoff-candidate-0.2.4.csv"
  )
  brief_path <- file.path(
    validation,
    "gtheory-multivariate-decision-multiverse-owner-decision-brief-0.2.4.csv"
  )
  binding_path <- file.path(
    validation,
    "gtheory-multivariate-covariance-binding-candidate-0.2.4.csv"
  )
  adjudication_path <- file.path(
    validation,
    "gtheory-multivariate-decision-multiverse-adjudication-plan-0.2.4.csv"
  )
  phase1_path <- file.path(
    validation,
    "gtheory-multivariate-phase1-owner-response-candidate-0.2.4.csv"
  )
  phase1_dossier_path <- file.path(
    validation,
    "gtheory-multivariate-phase1-scope-use-evidence-dossier-0.2.4.md"
  )
  skip_if_not(all(file.exists(c(
    input_path, signoff_path, brief_path, binding_path, adjudication_path,
    phase1_path, phase1_dossier_path
  ))),
              "repository-internal validation artifacts are excluded")
  inputs <- utils::read.csv(
    input_path, stringsAsFactors = FALSE, check.names = FALSE,
    na.strings = NULL
  )
  signoff <- utils::read.csv(
    signoff_path, stringsAsFactors = FALSE, check.names = FALSE,
    na.strings = NULL
  )
  brief <- utils::read.csv(
    brief_path, stringsAsFactors = FALSE, check.names = FALSE,
    na.strings = NULL
  )
  binding <- utils::read.csv(
    binding_path, stringsAsFactors = FALSE, check.names = FALSE,
    na.strings = NULL
  )
  adjudication <- utils::read.csv(
    adjudication_path, stringsAsFactors = FALSE, check.names = FALSE,
    na.strings = NULL
  )
  phase1 <- utils::read.csv(
    phase1_path, stringsAsFactors = FALSE, check.names = FALSE,
    na.strings = NULL
  )
  expect_identical(nrow(inputs), 13L)
  expect_identical(inputs$InputOrdinal, seq_len(13L))
  expect_identical(inputs$InputId, contract$OwnerInputSchema$InputId)
  expect_identical(inputs$RequiredType,
                   contract$OwnerInputSchema$RequiredType)
  expect_identical(inputs$Constraint, contract$OwnerInputSchema$Constraint)
  expect_true(all(inputs$ContractHash == contract$ContractHash))
  expect_true(all(!inputs$OwnerInputPresent))
  expect_true(all(is.na(inputs$EvidenceIdentity)))
  expect_true(all(is.na(inputs$ValueReference)))
  expect_true(all(inputs$PacketStatus == "candidate_incomplete"))

  expect_identical(nrow(binding), 8L)
  expect_identical(binding$BindingOrdinal, seq_len(8L))
  expect_identical(
    binding$BindingLayer,
    c(rep("observation_event", 2L), rep("random_block", 6L))
  )
  expect_true(all(binding$ContractHash == contract$ContractHash))
  expect_true(all(!binding$Confirmed))
  expect_true(all(!binding$Ready))
  expect_true(all(!binding$ExecutionAllowed))
  expect_true(all(is.na(binding$EvidenceIdentity)))
  expect_true(all(is.na(binding$ConditionSetRelationship)))
  expect_true(all(is.na(binding$ObservationEventRelationship)))
  expect_true(all(is.na(binding$StructureClass)))

  owner_candidate <-
    environments$controller$mfrmr_gtds_v3_owner_input_candidate(contract)
  expect_identical(nrow(phase1), 2L)
  expect_identical(
    phase1$DecisionFamilyId,
    contract$DecisionFamilyRegistry$DecisionFamilyId
  )
  expect_true(all(phase1$ContractHash == contract$ContractHash))
  expect_true(all(
    phase1$OwnerInputPacketCandidateHash == owner_candidate$PacketHash
  ))
  expect_true(all(nzchar(phase1$RepositoryCandidateUse)))
  expect_true(all(is.na(phase1$Enabled)))
  expect_true(all(is.na(phase1$NamedOperationalUse)))
  expect_true(all(is.na(phase1$DecisionOwnerId)))
  expect_true(all(is.na(phase1$AffectedWorkflowIdentity)))
  expect_true(all(is.na(phase1$ConsequenceIdentity)))
  expect_true(all(is.na(phase1$ExternalEvidenceAnchor)))
  expect_true(all(!phase1$OwnerConfirmed))
  expect_true(all(!phase1$Ready))
  expect_true(all(!phase1$OwnerEnablementMayBeInferred))
  expect_true(all(!phase1$SimulationExecutionAllowed))
  phase1_dossier <- readLines(phase1_dossier_path, warn = FALSE)
  expect_true(any(grepl(
    "Public API availability does not imply operational need.",
    phase1_dossier, fixed = TRUE
  )))
  expect_true(any(grepl(
    "enablement values must remain missing.",
    phase1_dossier, fixed = TRUE
  )))
  expected_adjudication <-
    environments$controller$mfrmr_gtds_v3_adjudication_plan(
      owner_candidate, contract
    )
  expect_identical(nrow(adjudication), 21L)
  expect_identical(adjudication$WorkOrdinal, seq_len(21L))
  expect_identical(adjudication$WorkLayer,
                   expected_adjudication$WorkLayer)
  expect_identical(adjudication$SubtaskId,
                   expected_adjudication$SubtaskId)
  expect_identical(adjudication$MissingCount,
                   expected_adjudication$MissingCount)
  expect_true(all(adjudication$ContractHash == contract$ContractHash))
  expect_true(all(adjudication$PacketHash == owner_candidate$PacketHash))
  expect_true(all(!adjudication$Ready))
  expect_true(all(!adjudication$OutcomeDataMayResolve))
  expect_true(all(!adjudication$ExecutionAllowed))
  expect_identical(nrow(brief), 13L)
  expect_identical(brief$InputOrdinal, seq_len(13L))
  expect_identical(brief$InputId,
                   contract$OwnerDecisionBriefSchema$InputId)
  expect_identical(
    brief$DecisionQuestion,
    contract$OwnerDecisionBriefSchema$DecisionQuestion
  )
  expect_identical(
    brief$RequiredEvidence,
    contract$OwnerDecisionBriefSchema$RequiredEvidence
  )
  expect_identical(
    brief$StopIfUnresolved,
    contract$OwnerDecisionBriefSchema$StopIfUnresolved
  )
  expect_true(all(brief$ContractHash == contract$ContractHash))
  expect_true(all(brief$PacketHash == owner_candidate$PacketHash))
  expect_true(all(!brief$Ready))
  expect_true(all(brief$MissingCount > 0L))
  expect_true(all(brief$BriefStatus == "owner_decisions_pending"))
  expect_true(all(!brief$SimulationExecutionAllowed))

  expect_identical(nrow(signoff), 13L)
  expect_identical(signoff$RequirementOrdinal, seq_len(13L))
  expect_identical(
    signoff$RequirementId, contract$SignoffRequirements$RequirementId
  )
  expect_identical(
    signoff$RequiredConfirmation,
    contract$SignoffRequirements$RequiredConfirmation
  )
  expect_true(all(signoff$ContractHash == contract$ContractHash))
  expect_true(all(!signoff$Confirmed))
  expect_true(all(is.na(signoff$Evidence)))
  expect_true(all(is.na(signoff$SignerId)))
  expect_true(all(is.na(signoff$OwnerInputPacketHash)))
  expect_true(all(is.na(signoff$ExternalDecisionAnchor)))
  expect_true(all(signoff$ReceiptStatus == "candidate_unsigned"))
})
