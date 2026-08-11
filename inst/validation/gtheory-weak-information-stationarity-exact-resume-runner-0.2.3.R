# Draft.83d2b2b1g13 exact-resume stationarity-calibration runner.
#
# Repository-internal only. This file implements content-addressed atomic
# accounting and a nonreserved mechanics fixture. It does not authorize or
# execute calibration replicates 201--300.

mfrmr_gtwag_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtwaa_manifest_hash_valid",
    "mfrmr_gtwaa_profile_registry", "mfrmr_gtwaa_select_profile",
    "mfrmr_gtwaa_candidate_state", "mfrmr_gtwae_policy",
    "mfrmr_gtwae_cell_summary", "mfrmr_gtwaf_function_hashes"
  )
  runner_environment <- environment(mfrmr_gtwag_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = runner_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the b1g12 chain before b1g13 exact-resume mechanics: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwag_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtwag_policy <- function() {
  identity <- list(
    Contract = "stationarity_exact_resume_policy_draft83d2b2b1g13_v1",
    AtomicUnit = paste0(
      "one_dataset_method_all_backend_profiles_both_model_roles_",
      "and_references"
    ),
    ModelRoles = c("full", "reduced"),
    MethodsPerDataset = 4L,
    CandidateRulesPerModelRole = 24L,
    CandidateDecisionsPerAtomicUnit = 48L,
    PlannedCalibrationAtomicUnits = 12000L,
    PlannedCalibrationDatasetMarkers = 3000L,
    PlannedCalibrationCandidateFitRows = 108000L,
    PlannedCalibrationCandidateDecisionRows = 576000L,
    PlannedCalibrationReferenceRows = 24000L,
    FixtureReplicates = c(901L, 902L),
    FixtureAtomicUnits = 8L,
    FixtureDatasetMarkers = 2L,
    FixtureCandidateFitRows = 72L,
    FixtureCandidateDecisionRows = 384L,
    FixtureReferenceRows = 16L,
    AtomicWrite = "same_directory_temporary_rds_then_file_rename",
    CheckpointMismatchAction = "recompute_never_pool",
    DatasetCompletionRule = "four_valid_method_checkpoint_hashes",
    PartialRunCompletionClaimAllowed = FALSE,
    FailedFitRowsRetained = TRUE,
    FailedReferenceRowsRetained = TRUE,
    TimingInScientificHash = FALSE,
    ReuseStateInScientificHash = FALSE,
    EarlyStoppingPermitted = FALSE,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    PolicyHash = mfrmr_gta_hash(identity), PolicyFrozen = TRUE
  )), class = "mfrmr_gtwag_policy")
}

mfrmr_gtwag_policy_hash_valid <- function(policy) {
  if (!inherits(policy, "mfrmr_gtwag_policy") ||
      !isTRUE(policy$PolicyFrozen) || is.null(policy$PolicyHash)) return(FALSE)
  identity <- unclass(policy)
  identity$PolicyHash <- NULL
  identity$PolicyFrozen <- NULL
  identical(policy$PolicyHash, mfrmr_gta_hash(identity))
}

mfrmr_gtwag_source_registry <- function() {
  data.frame(
    SourceId = c(
      "morris_white_crowther_2019", "r_saveRDS_current",
      "r_file_rename_current", "lme4_convergence_current",
      "glmmtmb_troubleshooting_current"
    ),
    Locator = c(
      "https://doi.org/10.1002/sim.8086",
      "https://stat.ethz.ch/R-manual/R-devel/library/base/html/readRDS.html",
      "https://stat.ethz.ch/R-manual/R-devel/library/base/html/files.html",
      "https://lme4.github.io/lme4/reference/convergence.html",
      paste0(
        "https://glmmtmb.github.io/glmmTMB/articles/",
        "troubleshooting.html"
      )
    ),
    ContractRole = c(
      "ADEMP denominators and complete method-failure accounting",
      "versioned checkpoint serialization",
      "same-filesystem atomic rename primitive",
      "optimizer completion and numerical diagnostics remain separate",
      "nonfinite and convergence states remain visible"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwag_contract <- function(boundary_contract, authorization_audit,
                                  sealed_manifest) {
  mfrmr_gtwag_require_primitives()
  if (!inherits(boundary_contract, "mfrmr_gtwaf_contract") ||
      !identical(
        boundary_contract$ContractHash,
        "53a36d72388eb8b4e096ef817aaf94959aa1b3fd3257190cf5c0a8164383d9da"
      ) || !isTRUE(boundary_contract$ProductionBoundaryProbeReady) ||
      isTRUE(boundary_contract$CalibrationExecutionAuthorized)) {
    stop("The exact non-authorizing b1g12 contract is required.",
         call. = FALSE)
  }
  if (!inherits(authorization_audit, "mfrmr_gtwaa_contract") ||
      !inherits(sealed_manifest, "mfrmr_gtwaa_manifest") ||
      !mfrmr_gtwaa_manifest_hash_valid(sealed_manifest) ||
      !identical(
        authorization_audit$AuthorizationAuditHash,
        "b293987e768ec0e998d3224a6df0689f0ab8b6f2268704ef422e333865d82765"
      ) || !identical(
        sealed_manifest$ManifestHash,
        "7cce9d42faccfbbdf928c9ec4978fef25c50aa562750141fbab45a53b75885f8"
      ) || isTRUE(sealed_manifest$ExecutionAuthorized) ||
      isTRUE(sealed_manifest$ResultsViewed)) {
    stop("The exact sealed non-authorizing b1g7 manifest is required.",
         call. = FALSE)
  }
  acceptance <- mfrmr_gtwae_policy()
  profiles <- mfrmr_gtwaa_profile_registry()
  policy <- mfrmr_gtwag_policy()
  expected <- c(
    AtomicUnits = sealed_manifest$BaseMethodUnitCount,
    DatasetMarkers = sealed_manifest$IndependentDatasetCount,
    CandidateFitRows = sealed_manifest$CorrectedCandidateFitCount,
    CandidateDecisionRows = sealed_manifest$BaseMethodUnitCount *
      policy$CandidateDecisionsPerAtomicUnit,
    ReferenceRows = sealed_manifest$ReferenceProblemCount
  )
  required <- c(
    AtomicUnits = policy$PlannedCalibrationAtomicUnits,
    DatasetMarkers = policy$PlannedCalibrationDatasetMarkers,
    CandidateFitRows = policy$PlannedCalibrationCandidateFitRows,
    CandidateDecisionRows = policy$PlannedCalibrationCandidateDecisionRows,
    ReferenceRows = policy$PlannedCalibrationReferenceRows
  )
  if (!identical(expected, required) ||
      !identical(nrow(acceptance$CandidateGrid), 24L) ||
      !identical(nrow(acceptance$ReferenceReceipts), 4L)) {
    stop("The b1g13 workload or acceptance denominator changed.",
         call. = FALSE)
  }
  identity <- list(
    Contract = "stationarity_exact_resume_runner_draft83d2b2b1g13_v1",
    UpstreamB1g12ContractHash = boundary_contract$ContractHash,
    UpstreamB1g7AuditHash = authorization_audit$AuthorizationAuditHash,
    SealedCalibrationManifestHash = sealed_manifest$ManifestHash,
    AcceptancePolicyHash = acceptance$PolicyHash,
    ReferenceReceiptHash = acceptance$ReferenceReceiptHash,
    ReferenceReceipts = acceptance$ReferenceReceipts,
    Profiles = profiles,
    ProfileRegistryHash = mfrmr_gta_hash(profiles),
    CandidateGrid = acceptance$CandidateGrid,
    CandidateGridHash = mfrmr_gta_hash(acceptance$CandidateGrid),
    ExpectedCalibrationCounts = expected,
    Policy = policy,
    Sources = mfrmr_gtwag_source_registry(),
    FunctionHashes = mfrmr_gtwag_function_hashes()
  )
  structure(c(identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    ExactResumeRunnerImplemented = TRUE,
    RunnerImplementationReady = TRUE,
    AtomicCheckpointSchemaReady = TRUE,
    CompleteFailureAccountingRequired = TRUE,
    ProductionBoundaryProbeReady = TRUE,
    AcceptancePolicyFrozen = TRUE,
    ReferenceMethodCoverageComplete = TRUE,
    ProductionEvaluatorAdaptersFrozen = FALSE,
    ReservedRunManifestFrozen = FALSE,
    CalibrationAuthorizationReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE, CalibrationResultsViewed = FALSE,
    StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    ConfirmationAuthorized = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtwag_contract")
}

mfrmr_gtwag_sealed_units <- function(contract, sealed_manifest) {
  if (!inherits(contract, "mfrmr_gtwag_contract") ||
      !inherits(sealed_manifest, "mfrmr_gtwaa_manifest") ||
      !mfrmr_gtwaa_manifest_hash_valid(sealed_manifest) ||
      !identical(
        contract$SealedCalibrationManifestHash, sealed_manifest$ManifestHash
      )) {
    stop("The exact b1g13 contract and sealed manifest are required.",
         call. = FALSE)
  }
  rows <- sealed_manifest$Rows
  units <- data.frame(
    AtomicUnitId = paste(rows$DatasetId, rows$MethodId, sep = "::"),
    DatasetId = rows$DatasetId, ScenarioId = rows$ScenarioId,
    Replicate = as.integer(rows$Replicate), MethodId = rows$MethodId,
    Backend = rows$Backend, Likelihood = rows$Likelihood,
    ExpectedCandidateFitRows = as.integer(rows$CorrectedCandidateFitCount),
    ExpectedCandidateDecisionRows =
      contract$Policy$CandidateDecisionsPerAtomicUnit,
    ExpectedReferenceRows = as.integer(rows$ReferenceProblemCount),
    CalibrationUse = TRUE, MechanicsFixture = FALSE,
    ExecutionAuthorized = FALSE, stringsAsFactors = FALSE
  )
  units$AtomicUnitIdentityHash <- vapply(seq_len(nrow(units)), function(index) {
    mfrmr_gta_hash(units[index, setdiff(
      names(units), "AtomicUnitIdentityHash"
    ), drop = FALSE])
  }, character(1L))
  expected <- contract$ExpectedCalibrationCounts
  exact <- nrow(units) == expected[["AtomicUnits"]] &&
    length(unique(units$DatasetId)) == expected[["DatasetMarkers"]] &&
    sum(units$ExpectedCandidateFitRows) == expected[["CandidateFitRows"]] &&
    sum(units$ExpectedCandidateDecisionRows) ==
      expected[["CandidateDecisionRows"]] &&
    sum(units$ExpectedReferenceRows) == expected[["ReferenceRows"]] &&
    !anyDuplicated(units$AtomicUnitId) &&
    all(table(units$DatasetId) == contract$Policy$MethodsPerDataset) &&
    setequal(unique(units$MethodId),
             contract$ReferenceReceipts$MethodId)
  if (!exact) stop("The sealed atomic-unit accounting is not exact.",
                   call. = FALSE)
  units
}

mfrmr_gtwag_fixture_units <- function(contract) {
  if (!inherits(contract, "mfrmr_gtwag_contract")) {
    stop("The b1g13 runner contract is required.", call. = FALSE)
  }
  lanes <- unique(contract$ReferenceReceipts[c("MethodId", "Backend")])
  lanes$Likelihood <- ifelse(grepl("_reml$", lanes$MethodId), "REML", "ML")
  rows <- do.call(rbind, lapply(contract$Policy$FixtureReplicates, function(rep) {
    dataset_id <- sprintf("GT-WI-RUNNER-MECHANICS/R%04d", rep)
    data.frame(
      AtomicUnitId = paste(dataset_id, lanes$MethodId, sep = "::"),
      DatasetId = dataset_id,
      ScenarioId = "GT-WI-RUNNER-MECHANICS",
      Replicate = as.integer(rep), MethodId = lanes$MethodId,
      Backend = lanes$Backend, Likelihood = lanes$Likelihood,
      stringsAsFactors = FALSE
    )
  }))
  profile_counts <- table(contract$Profiles$Backend)
  rows$ExpectedCandidateFitRows <-
    2L * as.integer(profile_counts[rows$Backend])
  rows$ExpectedCandidateDecisionRows <-
    contract$Policy$CandidateDecisionsPerAtomicUnit
  rows$ExpectedReferenceRows <- 2L
  rows$CalibrationUse <- FALSE
  rows$MechanicsFixture <- TRUE
  rows$ExecutionAuthorized <- TRUE
  rows$AtomicUnitIdentityHash <- vapply(seq_len(nrow(rows)), function(index) {
    mfrmr_gta_hash(rows[index, setdiff(
      names(rows), "AtomicUnitIdentityHash"
    ), drop = FALSE])
  }, character(1L))
  row.names(rows) <- NULL
  rows
}

mfrmr_gtwag_fixture_manifest <- function(contract) {
  units <- mfrmr_gtwag_fixture_units(contract)
  identity <- list(
    Contract = "stationarity_exact_resume_fixture_manifest_b1g13_v1",
    RunnerContractHash = contract$ContractHash,
    ExecutionMode = "nonreserved_deterministic_mechanics_only",
    Units = units,
    CandidateEvaluatorHash =
      mfrmr_gtwag_function_hash(mfrmr_gtwag_fixture_candidate_evaluator),
    ReferenceEvaluatorHash =
      mfrmr_gtwag_function_hash(mfrmr_gtwag_fixture_reference_evaluator),
    Replicates = sort(unique(units$Replicate)),
    ReservedCalibrationUse = FALSE,
    ConfirmationUse = FALSE
  )
  structure(c(identity, list(
    ManifestHash = mfrmr_gta_hash(identity),
    AtomicUnitCount = nrow(units),
    DatasetCount = length(unique(units$DatasetId)),
    CandidateFitRowCount = sum(units$ExpectedCandidateFitRows),
    CandidateDecisionRowCount = sum(units$ExpectedCandidateDecisionRows),
    ReferenceRowCount = sum(units$ExpectedReferenceRows),
    ExecutionAuthorized = TRUE,
    CalibrationExecutionAuthorized = FALSE,
    DataGenerated = FALSE, ResultsViewed = FALSE
  )), class = "mfrmr_gtwag_manifest")
}

mfrmr_gtwag_manifest_hash_valid <- function(manifest) {
  fields <- c(
    "Contract", "RunnerContractHash", "ExecutionMode", "Units",
    "CandidateEvaluatorHash", "ReferenceEvaluatorHash", "Replicates",
    "ReservedCalibrationUse", "ConfirmationUse"
  )
  inherits(manifest, "mfrmr_gtwag_manifest") &&
    all(fields %in% names(manifest)) &&
    identical(manifest$ManifestHash, mfrmr_gta_hash(manifest[fields]))
}

mfrmr_gtwag_expected_candidate_rows <- function(contract, unit) {
  profiles <- contract$Profiles[
    contract$Profiles$Backend == unit$Backend[[1L]], , drop = FALSE
  ]
  rows <- do.call(rbind, lapply(contract$Policy$ModelRoles, function(role) {
    data.frame(
      AtomicUnitId = unit$AtomicUnitId[[1L]],
      ObservationId = paste(unit$AtomicUnitId[[1L]], role, sep = "::"),
      ScenarioId = unit$ScenarioId[[1L]],
      MethodId = unit$MethodId[[1L]], ModelRole = role,
      ProfileId = profiles$ProfileId,
      ProfilePriority = profiles$ProfilePriority,
      stringsAsFactors = FALSE
    )
  }))
  rows$CandidateFitId <- paste(
    rows$AtomicUnitId, rows$ModelRole, rows$ProfileId, sep = "::"
  )
  row.names(rows) <- NULL
  rows
}

mfrmr_gtwag_failure_candidate_rows <- function(contract, unit, stage,
                                                message) {
  rows <- mfrmr_gtwag_expected_candidate_rows(contract, unit)
  rows$FitReturned <- FALSE
  rows$Objective <- NA_real_
  rows$objective_parameter_relative_max <- NA_real_
  rows$lme4_minimum_gradient_max <- NA_real_
  rows$newton_decrement <- NA_real_
  rows$CurvatureState <- "not_evaluable"
  rows$BoundaryProbeState <- ifelse(
    rows$ModelRole == "full", "not_evaluable", "not_run"
  )
  rows$BoundaryProbeHash <- "none"
  rows$FailureStage <- as.character(stage)
  rows$FailureMessageDigest <- mfrmr_gta_hash(as.character(message))
  rows
}

mfrmr_gtwag_failure_reference_rows <- function(unit, stage, message) {
  data.frame(
    AtomicUnitId = unit$AtomicUnitId[[1L]],
    ObservationId = paste(
      unit$AtomicUnitId[[1L]], c("full", "reduced"), sep = "::"
    ),
    ScenarioId = unit$ScenarioId[[1L]], MethodId = unit$MethodId[[1L]],
    ModelRole = c("full", "reduced"),
    ReferenceState = "not_evaluable",
    ReferenceSidecarHash = "none",
    FailureStage = as.character(stage),
    FailureMessageDigest = mfrmr_gta_hash(as.character(message)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwag_fixture_candidate_evaluator <- function(contract, unit) {
  rows <- mfrmr_gtwag_expected_candidate_rows(contract, unit)
  method_index <- match(
    unit$MethodId[[1L]], contract$ReferenceReceipts$MethodId
  )
  role_index <- match(rows$ModelRole, contract$Policy$ModelRoles)
  rows$FitReturned <- TRUE
  rows$Objective <- method_index / 10 + role_index / 100 +
    rows$ProfilePriority / 1000
  score_base <- if (unit$Replicate[[1L]] == 901L) 5e-8 else 5e-4
  rows$objective_parameter_relative_max <-
    score_base * rows$ProfilePriority
  rows$lme4_minimum_gradient_max <-
    score_base * (rows$ProfilePriority + 1) / 2
  rows$newton_decrement <-
    score_base * (rows$ProfilePriority + 2) / 3
  rows$CurvatureState <- "positive_definite_factorable"
  full_state <- c(
    glmmTMB_ml = "finite_interior_supported",
    glmmTMB_reml = "boundary_limit_supported",
    lme4_ml = "boundary_probe_inconclusive",
    lme4_reml = "not_evaluable"
  )[[unit$MethodId[[1L]]]]
  rows$BoundaryProbeState <- ifelse(
    rows$ModelRole == "full", full_state, "not_run"
  )
  rows$BoundaryProbeHash <- ifelse(
    rows$ModelRole == "full",
    mfrmr_gta_hash(list(
      Contract = "b1g13_nonreserved_boundary_fixture",
      MethodId = unit$MethodId[[1L]], State = full_state,
      ProductionProbeContractHash = contract$UpstreamB1g12ContractHash
    )),
    "not_applicable"
  )
  failed <- unit$Replicate[[1L]] == 902L &
    rows$ModelRole == "full" & rows$ProfilePriority ==
      max(rows$ProfilePriority)
  rows$FitReturned[failed] <- FALSE
  rows$Objective[failed] <- NA_real_
  score_columns <- c(
    "objective_parameter_relative_max", "lme4_minimum_gradient_max",
    "newton_decrement"
  )
  rows[failed, score_columns] <- NA_real_
  rows$CurvatureState[failed] <- "not_evaluable"
  rows$BoundaryProbeState[failed] <- "not_evaluable"
  rows$BoundaryProbeHash[failed] <- "none"
  rows$FailureStage <- ifelse(failed, "fixture_profile_failure", "none")
  rows$FailureMessageDigest <- ifelse(
    failed, mfrmr_gta_hash("intentional nonreserved profile failure"), "none"
  )
  rows
}

mfrmr_gtwag_fixture_reference_evaluator <- function(contract, unit) {
  full_states <- c(
    glmmTMB_ml = "finite_local_minimum",
    glmmTMB_reml = "boundary_limit",
    lme4_ml = "finite_nonstationary",
    lme4_reml = "reference_unresolved"
  )
  reduced_states <- c(
    glmmTMB_ml = "finite_box_local_minimum",
    glmmTMB_reml = "finite_nonstationary",
    lme4_ml = "finite_stationary_flat",
    lme4_reml = "not_evaluable"
  )
  states <- c(
    full_states[[unit$MethodId[[1L]]]],
    reduced_states[[unit$MethodId[[1L]]]]
  )
  data.frame(
    AtomicUnitId = unit$AtomicUnitId[[1L]],
    ObservationId = paste(
      unit$AtomicUnitId[[1L]], c("full", "reduced"), sep = "::"
    ),
    ScenarioId = unit$ScenarioId[[1L]], MethodId = unit$MethodId[[1L]],
    ModelRole = c("full", "reduced"), ReferenceState = states,
    ReferenceSidecarHash = vapply(states, function(state) {
      mfrmr_gta_hash(list(
        Contract = "b1g13_nonreserved_reference_fixture",
        MethodId = unit$MethodId[[1L]], State = state,
        ReferenceReceiptHash = contract$ReferenceReceiptHash
      ))
    }, character(1L)),
    FailureStage = ifelse(
      states %in% c("reference_unresolved", "not_evaluable"),
      "fixture_reference_unresolved", "none"
    ),
    FailureMessageDigest = ifelse(
      states %in% c("reference_unresolved", "not_evaluable"),
      mfrmr_gta_hash("intentional nonreserved reference unresolved"), "none"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwag_validate_candidate_rows <- function(rows, contract, unit) {
  expected <- mfrmr_gtwag_expected_candidate_rows(contract, unit)
  required <- c(
    names(expected), "FitReturned", "Objective",
    "objective_parameter_relative_max", "lme4_minimum_gradient_max",
    "newton_decrement", "CurvatureState", "BoundaryProbeState",
    "BoundaryProbeHash", "FailureStage", "FailureMessageDigest"
  )
  valid <- is.data.frame(rows) && all(required %in% names(rows)) &&
    nrow(rows) == nrow(expected) && !anyDuplicated(rows$CandidateFitId) &&
    identical(rows[names(expected)], expected) &&
    is.logical(rows$FitReturned) && !anyNA(rows$FitReturned) &&
    is.numeric(rows$Objective) &&
    all(vapply(rows[c(
      "objective_parameter_relative_max", "lme4_minimum_gradient_max",
      "newton_decrement"
    )], is.numeric, logical(1L))) &&
    all(rows$CurvatureState %in% c(
      "positive_definite_factorable", "spectral_positive_not_factorable",
      "near_singular_or_semidefinite", "indefinite", "not_evaluable"
    )) && all(rows$BoundaryProbeState %in% c(
      "finite_interior_supported", "boundary_limit_supported",
      "boundary_probe_inconclusive", "not_run", "not_evaluable"
    )) && all(nzchar(rows$BoundaryProbeHash)) &&
    all(nzchar(rows$FailureStage)) && all(nzchar(rows$FailureMessageDigest))
  if (valid) {
    returned <- rows$FitReturned
    valid <- all(is.finite(rows$Objective[returned])) &&
      all(!is.finite(rows$Objective[!returned])) &&
      all(rows$FailureStage[returned] == "none") &&
      all(rows$FailureMessageDigest[returned] == "none")
  }
  valid
}

mfrmr_gtwag_validate_reference_rows <- function(rows, unit) {
  allowed <- c(
    "finite_local_minimum", "finite_box_local_minimum",
    "finite_stationary_flat", "finite_nonstationary",
    "finite_saddle_or_max", "boundary_limit", "reference_unresolved",
    "not_evaluable"
  )
  required <- c(
    "AtomicUnitId", "ObservationId", "ScenarioId", "MethodId",
    "ModelRole", "ReferenceState", "ReferenceSidecarHash", "FailureStage",
    "FailureMessageDigest"
  )
  is.data.frame(rows) && all(required %in% names(rows)) && nrow(rows) == 2L &&
    identical(rows$AtomicUnitId, rep(unit$AtomicUnitId[[1L]], 2L)) &&
    identical(rows$ObservationId, paste(
      unit$AtomicUnitId[[1L]], c("full", "reduced"), sep = "::"
    )) && identical(rows$ScenarioId, rep(unit$ScenarioId[[1L]], 2L)) &&
    identical(rows$MethodId, rep(unit$MethodId[[1L]], 2L)) &&
    identical(rows$ModelRole, c("full", "reduced")) &&
    all(rows$ReferenceState %in% allowed) &&
    all(nzchar(rows$ReferenceSidecarHash)) &&
    all(nzchar(rows$FailureStage)) && all(nzchar(rows$FailureMessageDigest))
}

mfrmr_gtwag_candidate_decisions <- function(candidate_rows, contract, unit) {
  outputs <- lapply(contract$Policy$ModelRoles, function(role) {
    role_rows <- candidate_rows[
      candidate_rows$ModelRole == role, , drop = FALSE
    ]
    selection <- mfrmr_gtwaa_select_profile(
      role_rows, unit$Backend[[1L]], contract$Profiles
    )
    selected <- role_rows[
      role_rows$ProfileId == selection$SelectedProfileId, , drop = FALSE
    ]
    grid <- contract$CandidateGrid
    states <- lapply(seq_len(nrow(grid)), function(index) {
      candidate <- grid[index, , drop = FALSE]
      if (nrow(selected) == 0L) {
        score <- NA_real_
        curvature <- "not_evaluable"
        boundary <- if (role == "full") "not_evaluable" else "not_run"
        boundary_hash <- "none"
      } else {
        score <- selected[[candidate$ScoreId[[1L]]]][[1L]]
        curvature <- selected$CurvatureState[[1L]]
        boundary <- selected$BoundaryProbeState[[1L]]
        boundary_hash <- selected$BoundaryProbeHash[[1L]]
      }
      state <- mfrmr_gtwaa_candidate_state(
        score, candidate$EligibleUpper[[1L]],
        candidate$IneligibleLower[[1L]], curvature, boundary
      )
      data.frame(
        ObservationId = paste(unit$AtomicUnitId[[1L]], role, sep = "::"),
        ScenarioId = unit$ScenarioId[[1L]],
        MethodId = unit$MethodId[[1L]], ModelRole = role,
        CandidateId = candidate$CandidateId[[1L]],
        CandidateState = state$ApplicationState,
        FirstOrderState = state$FirstOrderState,
        CurvatureState = state$CurvatureState,
        BoundaryProbeState = state$BoundaryProbeState,
        BoundaryProbeHash = boundary_hash,
        SelectedProfileId = selection$SelectedProfileId,
        SelectedObjective = selection$SelectedObjective,
        AvailableProfileCount = selection$AvailableProfileCount,
        PlannedProfileCount = selection$PlannedProfileCount,
        MetricUsedToSelectProfile = selection$MetricUsedToSelectProfile,
        GeneratingTruthUsed = FALSE, stringsAsFactors = FALSE
      )
    })
    do.call(rbind, states)
  })
  rows <- do.call(rbind, outputs)
  row.names(rows) <- NULL
  if (nrow(rows) != unit$ExpectedCandidateDecisionRows[[1L]] ||
      anyDuplicated(rows[c("ObservationId", "CandidateId")]) ||
      !setequal(rows$CandidateId, contract$CandidateGrid$CandidateId) ||
      any(rows$GeneratingTruthUsed) || any(rows$MetricUsedToSelectProfile)) {
    stop("The candidate-decision expansion is incomplete.", call. = FALSE)
  }
  rows
}

mfrmr_gtwag_evaluate_unit <- function(contract, run_manifest, unit,
                                       candidate_evaluator,
                                       reference_evaluator) {
  candidate <- tryCatch(
    candidate_evaluator(contract, unit), error = function(error) error
  )
  if (inherits(candidate, "error")) {
    candidate <- mfrmr_gtwag_failure_candidate_rows(
      contract, unit, "candidate_evaluator", conditionMessage(candidate)
    )
  } else if (!mfrmr_gtwag_validate_candidate_rows(
    candidate, contract, unit
  )) {
    candidate <- mfrmr_gtwag_failure_candidate_rows(
      contract, unit, "candidate_schema", "malformed candidate ledger"
    )
  }
  reference <- tryCatch(
    reference_evaluator(contract, unit), error = function(error) error
  )
  if (inherits(reference, "error")) {
    reference <- mfrmr_gtwag_failure_reference_rows(
      unit, "reference_evaluator", conditionMessage(reference)
    )
  } else if (!mfrmr_gtwag_validate_reference_rows(reference, unit)) {
    reference <- mfrmr_gtwag_failure_reference_rows(
      unit, "reference_schema", "malformed reference ledger"
    )
  }
  decisions <- mfrmr_gtwag_candidate_decisions(candidate, contract, unit)
  identity <- list(
    Contract = "stationarity_atomic_bundle_b1g13_v1",
    RunnerContractHash = contract$ContractHash,
    RunManifestHash = run_manifest$ManifestHash,
    AtomicUnitIdentity = unit,
    CandidateFits = candidate,
    CandidateFitHash = mfrmr_gta_hash(candidate),
    CandidateDecisions = decisions,
    CandidateDecisionHash = mfrmr_gta_hash(decisions),
    References = reference,
    ReferenceHash = mfrmr_gta_hash(reference)
  )
  structure(c(identity, list(
    BundleHash = mfrmr_gta_hash(identity),
    CandidateFitFailureCount = sum(!candidate$FitReturned),
    ReferenceUnresolvedCount = sum(reference$ReferenceState %in%
      c("reference_unresolved", "not_evaluable"))
  )), class = "mfrmr_gtwag_bundle")
}

mfrmr_gtwag_bundle_hash_valid <- function(bundle, contract, run_manifest,
                                           unit) {
  fields <- c(
    "Contract", "RunnerContractHash", "RunManifestHash",
    "AtomicUnitIdentity", "CandidateFits", "CandidateFitHash",
    "CandidateDecisions", "CandidateDecisionHash", "References",
    "ReferenceHash"
  )
  inherits(bundle, "mfrmr_gtwag_bundle") &&
    all(fields %in% names(bundle)) &&
    identical(bundle$RunnerContractHash, contract$ContractHash) &&
    identical(bundle$RunManifestHash, run_manifest$ManifestHash) &&
    identical(bundle$AtomicUnitIdentity, unit) &&
    identical(bundle$CandidateFitHash,
              mfrmr_gta_hash(bundle$CandidateFits)) &&
    identical(bundle$CandidateDecisionHash,
              mfrmr_gta_hash(bundle$CandidateDecisions)) &&
    identical(bundle$ReferenceHash, mfrmr_gta_hash(bundle$References)) &&
    identical(bundle$BundleHash, mfrmr_gta_hash(bundle[fields])) &&
    mfrmr_gtwag_validate_candidate_rows(bundle$CandidateFits, contract, unit) &&
    mfrmr_gtwag_validate_reference_rows(bundle$References, unit) &&
    identical(nrow(bundle$CandidateDecisions),
              unit$ExpectedCandidateDecisionRows[[1L]]) &&
    !anyDuplicated(bundle$CandidateDecisions[c(
      "ObservationId", "CandidateId"
    )])
}

mfrmr_gtwag_checkpoint_root <- function(checkpoint_root) {
  checkpoint_root <- as.character(checkpoint_root)
  if (length(checkpoint_root) != 1L || is.na(checkpoint_root) ||
      !nzchar(checkpoint_root)) {
    stop("`checkpoint_root` must be one explicit nonempty path.",
         call. = FALSE)
  }
  expanded <- path.expand(checkpoint_root)
  if (expanded %in% c("/", path.expand("~"))) {
    stop("A filesystem root or home directory cannot be a checkpoint root.",
         call. = FALSE)
  }
  expanded
}

mfrmr_gtwag_checkpoint_path <- function(checkpoint_root, atomic_unit_id) {
  file.path(
    mfrmr_gtwag_checkpoint_root(checkpoint_root), "units",
    paste0(mfrmr_gta_hash(as.character(atomic_unit_id)), ".rds")
  )
}

mfrmr_gtwag_marker_path <- function(checkpoint_root, dataset_id) {
  file.path(
    mfrmr_gtwag_checkpoint_root(checkpoint_root), "datasets",
    paste0(mfrmr_gta_hash(as.character(dataset_id)), ".rds")
  )
}

mfrmr_gtwag_atomic_write <- function(object, path) {
  path <- as.character(path)
  if (length(path) != 1L || is.na(path) || !nzchar(path)) {
    stop("Atomic checkpoint path must be one nonempty path.", call. = FALSE)
  }
  directory <- dirname(path)
  if (!dir.exists(directory) &&
      !dir.create(directory, recursive = TRUE, showWarnings = FALSE)) {
    stop("Could not create checkpoint directory.", call. = FALSE)
  }
  temporary <- tempfile("mfrmr-gtwag-", tmpdir = directory, fileext = ".tmp")
  on.exit(if (file.exists(temporary)) unlink(temporary), add = TRUE)
  saveRDS(object, temporary, version = 3L)
  if (!file.rename(temporary, path)) {
    stop("Atomic checkpoint rename failed.", call. = FALSE)
  }
  invisible(path)
}

mfrmr_gtwag_safe_read <- function(path) {
  if (!file.exists(path)) return(NULL)
  tryCatch(readRDS(path), error = function(error) NULL)
}

mfrmr_gtwag_checkpoint <- function(contract, run_manifest, unit, bundle,
                                    timing = NULL) {
  if (!mfrmr_gtwag_bundle_hash_valid(
    bundle, contract, run_manifest, unit
  )) {
    stop("A valid atomic bundle is required.", call. = FALSE)
  }
  identity <- list(
    Contract = "stationarity_atomic_checkpoint_b1g13_v1",
    RunnerContractHash = contract$ContractHash,
    RunManifestHash = run_manifest$ManifestHash,
    AtomicUnitIdentityHash = unit$AtomicUnitIdentityHash[[1L]],
    BundleHash = bundle$BundleHash,
    Bundle = bundle
  )
  structure(list(
    Identity = identity, CheckpointHash = mfrmr_gta_hash(identity),
    Timing = timing
  ), class = "mfrmr_gtwag_checkpoint")
}

mfrmr_gtwag_validate_checkpoint <- function(checkpoint, contract,
                                             run_manifest, unit) {
  valid <- inherits(checkpoint, "mfrmr_gtwag_checkpoint") &&
    is.list(checkpoint$Identity) &&
    identical(checkpoint$CheckpointHash,
              mfrmr_gta_hash(checkpoint$Identity)) &&
    identical(checkpoint$Identity$RunnerContractHash,
              contract$ContractHash) &&
    identical(checkpoint$Identity$RunManifestHash,
              run_manifest$ManifestHash) &&
    identical(checkpoint$Identity$AtomicUnitIdentityHash,
              unit$AtomicUnitIdentityHash[[1L]]) &&
    identical(checkpoint$Identity$BundleHash,
              checkpoint$Identity$Bundle$BundleHash)
  if (!valid) return(FALSE)
  mfrmr_gtwag_bundle_hash_valid(
    checkpoint$Identity$Bundle, contract, run_manifest, unit
  )
}

mfrmr_gtwag_dataset_marker <- function(contract, run_manifest, dataset_id,
                                        checkpoints) {
  hashes <- vapply(checkpoints, `[[`, character(1L), "CheckpointHash")
  names(hashes) <- vapply(checkpoints, function(checkpoint) {
    checkpoint$Identity$Bundle$AtomicUnitIdentity$MethodId[[1L]]
  }, character(1L))
  hashes <- hashes[order(names(hashes), method = "radix")]
  identity <- list(
    Contract = "stationarity_dataset_marker_b1g13_v1",
    RunnerContractHash = contract$ContractHash,
    RunManifestHash = run_manifest$ManifestHash,
    DatasetId = as.character(dataset_id),
    UnitCheckpointHashes = hashes,
    MethodCount = length(hashes),
    CompletionState = "all_four_registered_method_units_valid"
  )
  structure(list(
    Identity = identity, DatasetMarkerHash = mfrmr_gta_hash(identity)
  ), class = "mfrmr_gtwag_dataset_marker")
}

mfrmr_gtwag_validate_marker <- function(marker, contract, run_manifest,
                                         dataset_id, checkpoints) {
  if (!inherits(marker, "mfrmr_gtwag_dataset_marker") ||
      !identical(marker$DatasetMarkerHash, mfrmr_gta_hash(marker$Identity)) ||
      length(checkpoints) != contract$Policy$MethodsPerDataset) return(FALSE)
  expected <- mfrmr_gtwag_dataset_marker(
    contract, run_manifest, dataset_id, checkpoints
  )
  identical(marker, expected)
}

mfrmr_gtwag_acceptance_ledger <- function(candidate_decisions, references) {
  reference <- references[c("ObservationId", "ReferenceState")]
  if (anyDuplicated(reference$ObservationId)) {
    stop("Reference observations must be unique.", call. = FALSE)
  }
  index <- match(candidate_decisions$ObservationId, reference$ObservationId)
  if (anyNA(index)) stop("Candidate decisions lack reference observations.",
                         call. = FALSE)
  data.frame(
    ObservationId = candidate_decisions$ObservationId,
    ScenarioId = candidate_decisions$ScenarioId,
    MethodId = candidate_decisions$MethodId,
    ModelRole = candidate_decisions$ModelRole,
    CandidateId = candidate_decisions$CandidateId,
    CandidateState = candidate_decisions$CandidateState,
    ReferenceState = reference$ReferenceState[index],
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwag_progress <- function(contract, run_manifest, checkpoints,
                                  checkpoint_valid, reused, computed,
                                  complete, marker_hashes = character()) {
  valid_checkpoints <- checkpoints[checkpoint_valid]
  checkpoint_hashes <- if (length(valid_checkpoints) == 0L) character() else
    vapply(valid_checkpoints, `[[`, character(1L), "CheckpointHash")
  names(checkpoint_hashes) <- run_manifest$Units$AtomicUnitId[checkpoint_valid]
  checkpoint_hashes <- checkpoint_hashes[
    order(names(checkpoint_hashes), method = "radix")
  ]
  progress_identity <- list(
    Contract = "stationarity_runner_progress_b1g13_v1",
    RunnerContractHash = contract$ContractHash,
    RunManifestHash = run_manifest$ManifestHash,
    ValidCheckpointHashes = checkpoint_hashes,
    DatasetMarkerHashes = marker_hashes,
    Complete = complete
  )
  structure(c(progress_identity, list(
    ProgressHash = mfrmr_gta_hash(progress_identity),
    ValidCheckpointCount = sum(checkpoint_valid),
    ReusedUnitCount = reused, ComputedUnitCount = computed,
    PlannedAtomicUnitCount = run_manifest$AtomicUnitCount,
    CompletionClaim = if (complete) "complete" else
      "partial_checkpoint_set_not_evidence",
    CalibrationEvidenceReady = FALSE,
    StationarityThresholdFrozen = FALSE,
    ConfirmationAuthorized = FALSE, InferenceReady = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwag_progress")
}

mfrmr_gtwag_execute <- function(
    contract, run_manifest, checkpoint_root,
    candidate_evaluator = mfrmr_gtwag_fixture_candidate_evaluator,
    reference_evaluator = mfrmr_gtwag_fixture_reference_evaluator,
    interrupt_after_new_units = Inf) {
  if (!inherits(contract, "mfrmr_gtwag_contract") ||
      !mfrmr_gtwag_manifest_hash_valid(run_manifest) ||
      !identical(run_manifest$RunnerContractHash, contract$ContractHash) ||
      !isTRUE(run_manifest$ExecutionAuthorized) ||
      isTRUE(run_manifest$CalibrationExecutionAuthorized) ||
      isTRUE(run_manifest$ReservedCalibrationUse) ||
      any(run_manifest$Replicates %in% 201:300) ||
      !identical(
        mfrmr_gtwag_function_hash(candidate_evaluator),
        run_manifest$CandidateEvaluatorHash
      ) || !identical(
        mfrmr_gtwag_function_hash(reference_evaluator),
        run_manifest$ReferenceEvaluatorHash
      )) {
    stop("Only the exact nonreserved b1g13 mechanics run is authorized.",
         call. = FALSE)
  }
  interrupt_after_new_units <- as.numeric(interrupt_after_new_units)
  if (length(interrupt_after_new_units) != 1L ||
      is.na(interrupt_after_new_units) || interrupt_after_new_units < 0) {
    stop("`interrupt_after_new_units` must be one nonnegative value.",
         call. = FALSE)
  }
  checkpoint_root <- mfrmr_gtwag_checkpoint_root(checkpoint_root)
  units <- run_manifest$Units
  checkpoints <- vector("list", nrow(units))
  checkpoint_valid <- logical(nrow(units))
  reused <- 0L
  computed <- 0L
  interrupted <- FALSE

  for (index in seq_len(nrow(units))) {
    unit <- units[index, , drop = FALSE]
    path <- mfrmr_gtwag_checkpoint_path(
      checkpoint_root, unit$AtomicUnitId[[1L]]
    )
    checkpoint <- mfrmr_gtwag_safe_read(path)
    valid <- mfrmr_gtwag_validate_checkpoint(
      checkpoint, contract, run_manifest, unit
    )
    if (valid) {
      checkpoints[[index]] <- checkpoint
      checkpoint_valid[[index]] <- TRUE
      reused <- reused + 1L
      next
    }
    if (computed >= interrupt_after_new_units) {
      interrupted <- TRUE
      break
    }
    clock <- system.time({
      bundle <- mfrmr_gtwag_evaluate_unit(
        contract, run_manifest, unit,
        candidate_evaluator, reference_evaluator
      )
    }, gcFirst = TRUE)
    timing <- data.frame(
      AtomicUnitId = unit$AtomicUnitId[[1L]],
      UserSeconds = unname(clock[["user.self"]]),
      SystemSeconds = unname(clock[["sys.self"]]),
      ElapsedSeconds = unname(clock[["elapsed"]]),
      stringsAsFactors = FALSE
    )
    checkpoint <- mfrmr_gtwag_checkpoint(
      contract, run_manifest, unit, bundle, timing
    )
    mfrmr_gtwag_atomic_write(checkpoint, path)
    checkpoint <- mfrmr_gtwag_safe_read(path)
    valid <- mfrmr_gtwag_validate_checkpoint(
      checkpoint, contract, run_manifest, unit
    )
    if (!valid) stop("A newly written checkpoint failed validation.",
                     call. = FALSE)
    checkpoints[[index]] <- checkpoint
    checkpoint_valid[[index]] <- TRUE
    computed <- computed + 1L
  }

  if (interrupted || !all(checkpoint_valid)) {
    return(mfrmr_gtwag_progress(
      contract, run_manifest, checkpoints, checkpoint_valid,
      reused, computed, FALSE
    ))
  }

  dataset_ids <- unique(units$DatasetId)
  marker_hashes <- character(length(dataset_ids))
  names(marker_hashes) <- dataset_ids
  for (dataset_id in dataset_ids) {
    indices <- which(units$DatasetId == dataset_id)
    dataset_checkpoints <- checkpoints[indices]
    marker_path <- mfrmr_gtwag_marker_path(checkpoint_root, dataset_id)
    marker <- mfrmr_gtwag_safe_read(marker_path)
    if (!mfrmr_gtwag_validate_marker(
      marker, contract, run_manifest, dataset_id, dataset_checkpoints
    )) {
      marker <- mfrmr_gtwag_dataset_marker(
        contract, run_manifest, dataset_id, dataset_checkpoints
      )
      mfrmr_gtwag_atomic_write(marker, marker_path)
    }
    marker <- mfrmr_gtwag_safe_read(marker_path)
    if (!mfrmr_gtwag_validate_marker(
      marker, contract, run_manifest, dataset_id, dataset_checkpoints
    )) stop("A dataset marker failed validation.", call. = FALSE)
    marker_hashes[[dataset_id]] <- marker$DatasetMarkerHash
  }

  bundles <- lapply(checkpoints, function(checkpoint) {
    checkpoint$Identity$Bundle
  })
  candidate_fits <- do.call(rbind, lapply(bundles, `[[`, "CandidateFits"))
  candidate_decisions <- do.call(
    rbind, lapply(bundles, `[[`, "CandidateDecisions")
  )
  references <- do.call(rbind, lapply(bundles, `[[`, "References"))
  row.names(candidate_fits) <- NULL
  row.names(candidate_decisions) <- NULL
  row.names(references) <- NULL
  exact <- nrow(candidate_fits) == run_manifest$CandidateFitRowCount &&
    nrow(candidate_decisions) == run_manifest$CandidateDecisionRowCount &&
    nrow(references) == run_manifest$ReferenceRowCount &&
    !anyDuplicated(candidate_fits$CandidateFitId) &&
    !anyDuplicated(candidate_decisions[c("ObservationId", "CandidateId")]) &&
    !anyDuplicated(references$ObservationId) &&
    length(marker_hashes) == run_manifest$DatasetCount
  if (!exact) stop("The completed b1g13 ledger is not exact.", call. = FALSE)
  ledger <- mfrmr_gtwag_acceptance_ledger(candidate_decisions, references)
  cell_summary <- mfrmr_gtwae_cell_summary(ledger)
  checkpoint_hashes <- vapply(
    checkpoints, `[[`, character(1L), "CheckpointHash"
  )
  names(checkpoint_hashes) <- units$AtomicUnitId
  identity <- list(
    Contract = "stationarity_fixture_execution_b1g13_v1",
    RunnerContractHash = contract$ContractHash,
    RunManifestHash = run_manifest$ManifestHash,
    CandidateFits = candidate_fits,
    CandidateDecisions = candidate_decisions,
    References = references,
    AcceptanceLedger = ledger,
    AcceptanceCellSummary = cell_summary,
    UnitCheckpointHashes = checkpoint_hashes,
    DatasetMarkerHashes = marker_hashes
  )
  structure(c(identity, list(
    ExecutionHash = mfrmr_gta_hash(identity),
    ExactAccountingPassed = TRUE,
    ValidCheckpointCount = length(checkpoints),
    ReusedUnitCount = reused, ComputedUnitCount = computed,
    CandidateFitFailureCount = sum(!candidate_fits$FitReturned),
    ReferenceUnresolvedCount = sum(references$ReferenceState %in%
      c("reference_unresolved", "not_evaluable")),
    Complete = TRUE, CompletionClaim = "complete_nonreserved_mechanics",
    RunnerImplementationReady = TRUE,
    CalibrationEvidenceReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    StationarityThresholdFrozen = FALSE,
    ConfirmationAuthorized = FALSE, InferenceReady = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwag_execution")
}

mfrmr_gtwag_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwag_source_registry", "mfrmr_gtwag_policy",
    "mfrmr_gtwag_policy_hash_valid", "mfrmr_gtwag_contract",
    "mfrmr_gtwag_sealed_units", "mfrmr_gtwag_fixture_units",
    "mfrmr_gtwag_fixture_manifest", "mfrmr_gtwag_manifest_hash_valid",
    "mfrmr_gtwag_expected_candidate_rows",
    "mfrmr_gtwag_failure_candidate_rows",
    "mfrmr_gtwag_failure_reference_rows",
    "mfrmr_gtwag_fixture_candidate_evaluator",
    "mfrmr_gtwag_fixture_reference_evaluator",
    "mfrmr_gtwag_validate_candidate_rows",
    "mfrmr_gtwag_validate_reference_rows",
    "mfrmr_gtwag_candidate_decisions", "mfrmr_gtwag_evaluate_unit",
    "mfrmr_gtwag_bundle_hash_valid", "mfrmr_gtwag_checkpoint_root",
    "mfrmr_gtwag_checkpoint_path", "mfrmr_gtwag_marker_path",
    "mfrmr_gtwag_atomic_write", "mfrmr_gtwag_safe_read",
    "mfrmr_gtwag_checkpoint", "mfrmr_gtwag_validate_checkpoint",
    "mfrmr_gtwag_dataset_marker", "mfrmr_gtwag_validate_marker",
    "mfrmr_gtwag_acceptance_ledger", "mfrmr_gtwag_progress",
    "mfrmr_gtwag_execute"
  )
  runner_environment <- environment(mfrmr_gtwag_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwag_function_hash(get(
      name, envir = runner_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}
