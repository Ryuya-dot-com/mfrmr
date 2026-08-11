# Draft.83d2b2b1d replacement resolution-feasibility runner.
#
# Repository-internal only. This runner executes the frozen Draft.83d2b2b1c
# manifest with atomic checkpoints and threshold-free descriptive summaries.
# It does not select a rule, run an inner bootstrap, or support inference.

mfrmr_gtwx_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtw_registry", "mfrmr_gtw_generate",
    "mfrmr_gtd3_prefit_one", "mfrmr_gtwd_diagnostic_pair",
    "mfrmr_gtwf_contract", "mfrmr_gtwf_manifest",
    "mfrmr_gtwf_observable_row", "mfrmr_gtwf_success_row",
    "mfrmr_gtwf_failure_row", "mfrmr_gtwf_authorization"
  )
  runner_environment <- environment(mfrmr_gtwx_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = runner_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the Draft.83d2b2b1c chain before Draft.83d2b2b1d: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwx_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtwx_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwx_backend_control_hashes",
    "mfrmr_gtwx_authorization_reference",
    "mfrmr_gtwx_validate_authorization", "mfrmr_gtwx_contract",
    "mfrmr_gtwx_checkpoint_root", "mfrmr_gtwx_atomic_write",
    "mfrmr_gtwx_route_path", "mfrmr_gtwx_dataset_path",
    "mfrmr_gtwx_safe_read", "mfrmr_gtwx_route_identity",
    "mfrmr_gtwx_route_checkpoint", "mfrmr_gtwx_validate_route",
    "mfrmr_gtwx_dataset_marker", "mfrmr_gtwx_validate_dataset",
    "mfrmr_gtwx_rank_probability", "mfrmr_gtwx_availability_summary",
    "mfrmr_gtwx_spearman_summary", "mfrmr_gtwx_rank_summary",
    "mfrmr_gtwx_summaries", "mfrmr_gtwx_execute"
  )
  runner_environment <- environment(mfrmr_gtwx_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwx_function_hash(get(
      name, envir = runner_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}

mfrmr_gtwx_backend_control_hashes <- function() {
  c(
    lme4_default = mfrmr_gtwx_function_hash(lme4::lmerControl),
    glmmTMB_default = mfrmr_gtwx_function_hash(glmmTMB::glmmTMBControl)
  )
}

mfrmr_gtwx_authorization_reference <- function(
    feasibility_contract = mfrmr_gtwf_contract(),
    manifest = mfrmr_gtwf_manifest(feasibility_contract)) {
  if (!inherits(feasibility_contract, "mfrmr_gtwf_contract") ||
      !inherits(manifest, "mfrmr_gtwf_manifest") ||
      !identical(manifest$FeasibilityContractHash,
                 feasibility_contract$ContractHash)) {
    stop("Authorization-reference inputs do not share one identity.",
         call. = FALSE)
  }
  gates <- data.frame(
    Gate = c(
      "manifest_exact_accounting", "reserved_data_not_generated",
      "runtime_atomic_accounting", "runtime_timing_complete",
      "checkpoint_contract_frozen", "rule_selection_disabled",
      "inner_bootstrap_disabled", "confirmation_disabled"
    ),
    Passed = rep(TRUE, 8L), stringsAsFactors = FALSE
  )
  identity <- list(
    Contract =
      "gtheory_weak_information_feasibility_authorization_draft83d2b2b1c_v1",
    FeasibilityContractHash = feasibility_contract$ContractHash,
    FeasibilityManifestHash = manifest$ManifestHash,
    RuntimeExecutionHash =
      "9099eec3ae54485162b18e3fee14aae4b1d888fe32e2bc0b897fbb1d8105e7eb",
    AuthorizationGates = gates,
    AuthorizedScope =
      "descriptive_resolution_feasibility_no_threshold_no_inner_bootstrap",
    ExecutionMode = "serial_checkpoint_every_method_pair",
    AuthorizedReplicates = c(
      feasibility_contract$FeasibilityReplicateStart,
      feasibility_contract$FeasibilityReplicateEnd
    )
  )
  structure(c(identity, list(
    AuthorizationHash = mfrmr_gta_hash(identity),
    ResolutionFeasibilityAuthorized = TRUE,
    FeasibilityEvidenceReady = FALSE,
    BootstrapOperatingCharacteristicsReady = FALSE,
    CalibrationEvidenceReady = FALSE, ThresholdFrozen = FALSE,
    ConfirmationAuthorized = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtwf_authorization")
}

mfrmr_gtwx_validate_authorization <- function(authorization) {
  identity_names <- c(
    "Contract", "FeasibilityContractHash", "FeasibilityManifestHash",
    "RuntimeExecutionHash", "AuthorizationGates", "AuthorizedScope",
    "ExecutionMode", "AuthorizedReplicates"
  )
  if (!inherits(authorization, "mfrmr_gtwf_authorization") ||
      !all(identity_names %in% names(authorization)) ||
      !is.data.frame(authorization$AuthorizationGates) ||
      !all(authorization$AuthorizationGates$Passed) ||
      !isTRUE(authorization$ResolutionFeasibilityAuthorized) ||
      isTRUE(authorization$FeasibilityEvidenceReady) ||
      isTRUE(authorization$ThresholdFrozen) ||
      isTRUE(authorization$ConfirmationAuthorized) ||
      isTRUE(authorization$InferenceReady) ||
      isTRUE(authorization$DecisionReady)) return(FALSE)
  identity <- unclass(authorization)[identity_names]
  identical(authorization$AuthorizationHash, mfrmr_gta_hash(identity)) &&
    identical(
      authorization$RuntimeExecutionHash,
      "9099eec3ae54485162b18e3fee14aae4b1d888fe32e2bc0b897fbb1d8105e7eb"
    )
}

mfrmr_gtwx_contract <- function(
    feasibility_contract = mfrmr_gtwf_contract(),
    manifest = mfrmr_gtwf_manifest(feasibility_contract),
    authorization = NULL) {
  mfrmr_gtwx_require_primitives()
  if (is.null(authorization)) {
    stop("A separate Draft.83d2b2b1c authorization is required.",
         call. = FALSE)
  }
  expected <- c(
    FeasibilityContractHash =
      "3a005d424d6121d0feda96ac4455e230cb7f4c93d0f152659b27f3ea647d406b",
    FeasibilityManifestHash =
      "bc14c65fb6ccc26c22d60487f4225493cd58735a48a44758d19cbaf739b17242",
    FeasibilityAuthorizationHash =
      "e36e82198763e7a785a840cbd9bc029b658b919f58e14377a24e6ced1ca64e1a"
  )
  if (!inherits(feasibility_contract, "mfrmr_gtwf_contract") ||
      !inherits(manifest, "mfrmr_gtwf_manifest") ||
      !inherits(authorization, "mfrmr_gtwf_authorization") ||
      !identical(manifest$FeasibilityContractHash,
                 feasibility_contract$ContractHash) ||
      !identical(authorization$FeasibilityContractHash,
                 feasibility_contract$ContractHash) ||
      !identical(authorization$FeasibilityManifestHash,
                 manifest$ManifestHash) ||
      !identical(feasibility_contract$ContractHash,
                 unname(expected[["FeasibilityContractHash"]])) ||
      !identical(manifest$ManifestHash,
                 unname(expected[["FeasibilityManifestHash"]])) ||
      !identical(authorization$AuthorizationHash,
                 unname(expected[["FeasibilityAuthorizationHash"]])) ||
      !mfrmr_gtwx_validate_authorization(authorization) ||
      !isTRUE(authorization$ResolutionFeasibilityAuthorized)) {
    stop("The feasibility identities are not jointly authorized.",
         call. = FALSE)
  }
  score_columns <- c(
    TargetFractionTotal = "target_fraction_total",
    TargetToResidualRatio = "target_to_residual_ratio",
    RawLikelihoodDrop = "raw_likelihood_drop_separate_method_likelihood"
  )
  identity <- list(
    Contract = "gtheory_weak_information_feasibility_runner_draft83d2b2b1d_v1",
    ContractArtifact =
      "gtheory-weak-information-feasibility-runner-contract-0.2.3.md",
    FeasibilityContractHash = feasibility_contract$ContractHash,
    FeasibilityManifestHash = manifest$ManifestHash,
    FeasibilityAuthorizationHash = authorization$AuthorizationHash,
    ExpectedUpstreamHashes = expected,
    RegistryHash = feasibility_contract$CalibrationRegistryHash,
    TargetComponent = feasibility_contract$TargetComponent,
    BoundaryTolerance = feasibility_contract$BoundaryTolerance,
    NegativeLikelihoodTolerance =
      feasibility_contract$NegativeLikelihoodTolerance,
    PlannedRows = feasibility_contract$FeasibilityRowCount,
    PlannedDatasets =
      feasibility_contract$FeasibilityIndependentDatasetCount,
    PlannedBackendFits = feasibility_contract$FeasibilityBackendFitCount,
    MethodsPerDataset = feasibility_contract$MethodCount,
    ReplicateBand = c(
      feasibility_contract$FeasibilityReplicateStart,
      feasibility_contract$FeasibilityReplicateEnd
    ),
    RouteCheckpointUnit = "one_method_full_reduced_pair",
    DatasetMarkerUnit = "four_valid_route_checkpoint_hashes",
    MismatchAction = "recompute_or_reject_never_pool",
    AtomicWrite = "same_directory_temporary_rds_then_file_rename",
    ScientificHashExclusions = c(
      "timing", "checkpoint_root", "execution_order", "progress_frequency",
      "computed_or_reused"
    ),
    CommonScores = score_columns,
    RankProbabilityTieWeight = 0.5,
    PrimaryGrouping = "scenario_x_method",
    SpearmanGrouping = "design_x_method_x_score",
    RankProbabilityGrouping = "registered_control_design_x_method_x_score",
    ThresholdSelectionPermitted = FALSE,
    InnerBootstrapPermitted = FALSE,
    EarlyStoppingPermitted = FALSE,
    RIdentity = list(
      Version = R.version.string, Platform = R.version$platform,
      Architecture = R.version$arch
    ),
    PackageVersions = c(
      digest = as.character(utils::packageVersion("digest")),
      lme4 = as.character(utils::packageVersion("lme4")),
      glmmTMB = as.character(utils::packageVersion("glmmTMB")),
      TMB = as.character(utils::packageVersion("TMB")),
      Matrix = as.character(utils::packageVersion("Matrix"))
    ),
    BackendControlHashes = mfrmr_gtwx_backend_control_hashes(),
    UpstreamFunctionHashes = c(
      Generator = mfrmr_gtwx_function_hash(mfrmr_gtw_generate),
      PreFit = mfrmr_gtwx_function_hash(mfrmr_gtd3_prefit_one),
      DiagnosticPair = mfrmr_gtwx_function_hash(mfrmr_gtwd_diagnostic_pair),
      Observable = mfrmr_gtwx_function_hash(mfrmr_gtwf_observable_row),
      SuccessRow = mfrmr_gtwx_function_hash(mfrmr_gtwf_success_row),
      FailureRow = mfrmr_gtwx_function_hash(mfrmr_gtwf_failure_row)
    ),
    RunnerFunctionHashes = mfrmr_gtwx_function_hashes()
  )
  structure(c(identity, list(
    RunnerContractHash = mfrmr_gta_hash(identity),
    ExecutionAuthorized = TRUE,
    FeasibilityEvidenceReady = FALSE,
    BootstrapOperatingCharacteristicsReady = FALSE,
    CalibrationEvidenceReady = FALSE, ThresholdFrozen = FALSE,
    ConfirmationAuthorized = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtwx_contract")
}

mfrmr_gtwx_checkpoint_root <- function(checkpoint_root) {
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

mfrmr_gtwx_route_path <- function(checkpoint_root, route_id) {
  checkpoint_root <- mfrmr_gtwx_checkpoint_root(checkpoint_root)
  file.path(
    checkpoint_root, "routes",
    paste0(mfrmr_gta_hash(as.character(route_id)), ".rds")
  )
}

mfrmr_gtwx_dataset_path <- function(checkpoint_root, dataset_id) {
  checkpoint_root <- mfrmr_gtwx_checkpoint_root(checkpoint_root)
  file.path(
    checkpoint_root, "datasets",
    paste0(mfrmr_gta_hash(as.character(dataset_id)), ".rds")
  )
}

mfrmr_gtwx_atomic_write <- function(object, path) {
  path <- as.character(path)
  if (length(path) != 1L || is.na(path) || !nzchar(path)) {
    stop("Atomic checkpoint path must be one nonempty path.", call. = FALSE)
  }
  directory <- dirname(path)
  if (!dir.exists(directory) &&
      !dir.create(directory, recursive = TRUE, showWarnings = FALSE)) {
    stop("Could not create checkpoint directory.", call. = FALSE)
  }
  temporary <- tempfile("mfrmr-gtwx-", tmpdir = directory, fileext = ".tmp")
  on.exit(if (file.exists(temporary)) unlink(temporary), add = TRUE)
  saveRDS(object, temporary, version = 3L)
  if (!file.rename(temporary, path)) {
    stop("Atomic checkpoint rename failed.", call. = FALSE)
  }
  invisible(path)
}

mfrmr_gtwx_safe_read <- function(path) {
  if (!file.exists(path)) return(NULL)
  tryCatch(readRDS(path), error = function(error) NULL)
}

mfrmr_gtwx_route_identity <- function(contract, route, generation, prefit,
                                       atomic_row) {
  list(
    Contract = "gtheory_weak_information_route_checkpoint_draft83d2b2b1d_v1",
    RunnerContractHash = contract$RunnerContractHash,
    FeasibilityContractHash = contract$FeasibilityContractHash,
    FeasibilityManifestHash = contract$FeasibilityManifestHash,
    FeasibilityAuthorizationHash = contract$FeasibilityAuthorizationHash,
    RouteIdentity = route,
    GeneratorHash = if (is.null(generation)) "none" else
      generation$GeneratorHash,
    AnalysisDataHash = if (is.null(generation)) "none" else
      generation$GeneratorIdentity$AnalysisDataHash,
    PreFitHash = if (is.null(prefit)) "none" else prefit$ResultHash,
    RetainedDataHash = if (is.null(prefit)) "none" else
      prefit$StructuralRankAudit$PreparedData$RetainedDataHash,
    TargetComponent = contract$TargetComponent,
    BoundaryTolerance = contract$BoundaryTolerance,
    NegativeLikelihoodTolerance = contract$NegativeLikelihoodTolerance,
    PairResultHash = atomic_row$PairResultHash[[1L]],
    ObservableHash = atomic_row$ObservableHash[[1L]],
    FailureStage = atomic_row$FailureStage[[1L]],
    FailureMessageDigest = atomic_row$FailureMessageDigest[[1L]],
    AtomicResult = atomic_row
  )
}

mfrmr_gtwx_route_checkpoint <- function(contract, route, generation,
                                         prefit, atomic_row, timing = NULL) {
  if (!inherits(contract, "mfrmr_gtwx_contract") ||
      !is.data.frame(route) || nrow(route) != 1L ||
      !is.data.frame(atomic_row) || nrow(atomic_row) != 1L ||
      !identical(as.character(route$RouteId),
                 as.character(atomic_row$RouteId))) {
    stop("Route checkpoint inputs are invalid.", call. = FALSE)
  }
  identity <- mfrmr_gtwx_route_identity(
    contract, route, generation, prefit, atomic_row
  )
  structure(list(
    Identity = identity,
    RouteResultHash = mfrmr_gta_hash(identity),
    Timing = timing
  ), class = "mfrmr_gtwx_route_checkpoint")
}

mfrmr_gtwx_validate_route <- function(checkpoint, contract, route) {
  reason <- "valid"
  valid <- inherits(checkpoint, "mfrmr_gtwx_route_checkpoint") &&
    is.list(checkpoint$Identity) &&
    is.character(checkpoint$RouteResultHash) &&
    length(checkpoint$RouteResultHash) == 1L
  if (!valid) reason <- "missing_corrupt_or_wrong_class"
  if (valid && !identical(checkpoint$RouteResultHash,
                           mfrmr_gta_hash(checkpoint$Identity))) {
    valid <- FALSE
    reason <- "route_result_hash_mismatch"
  }
  expected_route <- if (is.data.frame(route)) route else NULL
  if (valid && (!inherits(contract, "mfrmr_gtwx_contract") ||
                !is.data.frame(expected_route) || nrow(expected_route) != 1L ||
                !identical(checkpoint$Identity$RunnerContractHash,
                           contract$RunnerContractHash) ||
                !identical(checkpoint$Identity$FeasibilityContractHash,
                           contract$FeasibilityContractHash) ||
                !identical(checkpoint$Identity$FeasibilityManifestHash,
                           contract$FeasibilityManifestHash) ||
                !identical(checkpoint$Identity$FeasibilityAuthorizationHash,
                           contract$FeasibilityAuthorizationHash) ||
                !identical(checkpoint$Identity$RouteIdentity,
                           expected_route))) {
    valid <- FALSE
    reason <- "runner_manifest_or_route_identity_mismatch"
  }
  atomic <- if (valid) checkpoint$Identity$AtomicResult else NULL
  if (valid && (!is.data.frame(atomic) || nrow(atomic) != 1L ||
                !identical(as.character(atomic$RouteId),
                           as.character(route$RouteId)) ||
                !identical(atomic$PairResultHash[[1L]],
                           checkpoint$Identity$PairResultHash) ||
                !identical(atomic$ObservableHash[[1L]],
                           checkpoint$Identity$ObservableHash))) {
    valid <- FALSE
    reason <- "atomic_result_identity_mismatch"
  }
  list(Valid = valid, Reason = reason,
       AtomicResult = if (valid) atomic else NULL,
       RouteResultHash = if (valid) checkpoint$RouteResultHash else "none")
}

mfrmr_gtwx_dataset_marker <- function(contract, dataset_id,
                                       route_checkpoints) {
  hashes <- vapply(route_checkpoints, `[[`, character(1L), "RouteResultHash")
  names(hashes) <- vapply(route_checkpoints, function(checkpoint) {
    checkpoint$Identity$RouteIdentity$RouteId[[1L]]
  }, character(1L))
  hashes <- hashes[order(names(hashes), method = "radix")]
  identity <- list(
    Contract = "gtheory_weak_information_dataset_marker_draft83d2b2b1d_v1",
    RunnerContractHash = contract$RunnerContractHash,
    FeasibilityManifestHash = contract$FeasibilityManifestHash,
    DatasetId = as.character(dataset_id),
    RouteResultHashes = hashes,
    RouteCount = length(hashes),
    CompletionState = "all_registered_method_routes_valid"
  )
  structure(list(
    Identity = identity,
    DatasetMarkerHash = mfrmr_gta_hash(identity)
  ), class = "mfrmr_gtwx_dataset_marker")
}

mfrmr_gtwx_validate_dataset <- function(marker, contract, dataset_id,
                                         route_checkpoints) {
  if (!inherits(marker, "mfrmr_gtwx_dataset_marker") ||
      !is.list(marker$Identity) ||
      !identical(marker$DatasetMarkerHash,
                 mfrmr_gta_hash(marker$Identity))) return(FALSE)
  expected <- mfrmr_gtwx_dataset_marker(
    contract, dataset_id, route_checkpoints
  )
  identical(marker$Identity, expected$Identity) &&
    identical(marker$DatasetMarkerHash, expected$DatasetMarkerHash) &&
    identical(marker$Identity$RouteCount, contract$MethodsPerDataset)
}

mfrmr_gtwx_rank_probability <- function(positive, negative) {
  positive <- positive[is.finite(positive)]
  negative <- negative[is.finite(negative)]
  denominator <- length(positive) * length(negative)
  if (denominator == 0L) {
    return(data.frame(
      PositiveN = length(positive), NegativeN = length(negative),
      PairDenominator = 0L, Wins = 0L, Ties = 0L, Losses = 0L,
      RankProbability = NA_real_, stringsAsFactors = FALSE
    ))
  }
  difference <- outer(positive, negative, "-")
  wins <- sum(difference > 0)
  ties <- sum(difference == 0)
  losses <- sum(difference < 0)
  data.frame(
    PositiveN = length(positive), NegativeN = length(negative),
    PairDenominator = denominator, Wins = wins, Ties = ties, Losses = losses,
    RankProbability = (wins + 0.5 * ties) / denominator,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwx_availability_summary <- function(rows) {
  key <- interaction(rows$ScenarioId, rows$MethodId, drop = TRUE,
                     lex.order = TRUE)
  groups <- split(rows, key)
  out <- lapply(groups, function(group) {
    data.frame(
      ScenarioId = group$ScenarioId[[1L]],
      DesignId = group$DesignId[[1L]],
      VarianceId = group$VarianceId[[1L]],
      TargetVariance = group$TargetVariance[[1L]],
      TruthRegion = group$TruthRegion[[1L]],
      EvaluationRole = group$EvaluationRole[[1L]],
      MethodId = group$MethodId[[1L]], Backend = group$Backend[[1L]],
      Likelihood = group$Likelihood[[1L]], PlannedN = nrow(group),
      PairReturnedN = sum(group$PairReturned %in% TRUE),
      LikelihoodAvailableN = sum(
        group$LikelihoodDiagnosticAvailable %in% TRUE
      ),
      CommonScoreAvailableN = sum(group$FeasibilityScoreAvailable %in% TRUE),
      MaterialNegativeDropN = sum(
        group$PairReturned %in% TRUE &
          !(group$NegativeDropWithinTolerance %in% TRUE)
      ),
      SmallNegativeRetainedN = sum(
        group$FeasibilityScoreAvailable %in% TRUE &
          is.finite(group$RawLikelihoodDrop) & group$RawLikelihoodDrop < 0
      ),
      TargetBoundaryN = sum(group$TargetBoundaryToleranceReached %in% TRUE),
      NuisanceBoundaryN = sum(group$NuisanceBoundaryPresent %in% TRUE),
      TypedFailureN = sum(!(group$PairReturned %in% TRUE)),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, out)
  out$PairReturnedRate <- out$PairReturnedN / out$PlannedN
  out$LikelihoodAvailableRate <- out$LikelihoodAvailableN / out$PlannedN
  out$CommonScoreAvailableRate <- out$CommonScoreAvailableN / out$PlannedN
  out[order(out$ScenarioId, out$MethodId, method = "radix"), , drop = FALSE]
}

mfrmr_gtwx_spearman_summary <- function(rows, score_columns) {
  keys <- expand.grid(
    DesignId = sort(unique(rows$DesignId), method = "radix"),
    MethodId = sort(unique(rows$MethodId), method = "radix"),
    ScoreColumn = names(score_columns), KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  out <- lapply(seq_len(nrow(keys)), function(index) {
    key <- keys[index, , drop = FALSE]
    score_column <- key$ScoreColumn[[1L]]
    selected <- rows$DesignId == key$DesignId[[1L]] &
      rows$MethodId == key$MethodId[[1L]] &
      rows$FeasibilityScoreAvailable %in% TRUE &
      is.finite(rows[[score_column]]) & is.finite(rows$TargetVariance)
    truth <- rows$TargetVariance[selected]
    score <- rows[[score_column]][selected]
    correlation <- if (length(score) > 1L &&
                        length(unique(score)) > 1L &&
                        length(unique(truth)) > 1L) {
      suppressWarnings(stats::cor(truth, score, method = "spearman"))
    } else NA_real_
    data.frame(
      DesignId = key$DesignId[[1L]], MethodId = key$MethodId[[1L]],
      Score = unname(score_columns[[score_column]]),
      AvailableN = length(score),
      DistinctTruthLevels = length(unique(truth)),
      SpearmanRho = correlation, PValue = NA_real_, Interval = "none",
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, out)
}

mfrmr_gtwx_rank_summary <- function(rows, score_columns) {
  control_rows <- rows$EvaluationRole %in% c(
    "negative_control_not_resolved", "positive_control_resolved"
  )
  control_designs <- sort(unique(rows$DesignId[
    control_rows & ave(
      rows$EvaluationRole == "positive_control_resolved", rows$DesignId,
      FUN = any
    ) & ave(
      rows$EvaluationRole == "negative_control_not_resolved", rows$DesignId,
      FUN = any
    )
  ]), method = "radix")
  keys <- expand.grid(
    DesignId = control_designs,
    MethodId = sort(unique(rows$MethodId), method = "radix"),
    ScoreColumn = names(score_columns), KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  if (nrow(keys) == 0L) return(data.frame())
  out <- lapply(seq_len(nrow(keys)), function(index) {
    key <- keys[index, , drop = FALSE]
    score_column <- key$ScoreColumn[[1L]]
    selected <- rows$DesignId == key$DesignId[[1L]] &
      rows$MethodId == key$MethodId[[1L]] &
      rows$FeasibilityScoreAvailable %in% TRUE &
      is.finite(rows[[score_column]])
    positive <- rows[[score_column]][
      selected & rows$EvaluationRole == "positive_control_resolved"
    ]
    negative <- rows[[score_column]][
      selected & rows$EvaluationRole == "negative_control_not_resolved"
    ]
    result <- mfrmr_gtwx_rank_probability(positive, negative)
    cbind(
      data.frame(
        DesignId = key$DesignId[[1L]], MethodId = key$MethodId[[1L]],
        Score = unname(score_columns[[score_column]]),
        PValue = NA_real_, Interval = "none", Threshold = NA_real_,
        stringsAsFactors = FALSE
      ), result, stringsAsFactors = FALSE
    )
  })
  do.call(rbind, out)
}

mfrmr_gtwx_summaries <- function(rows, contract) {
  if (!is.data.frame(rows) || !inherits(contract, "mfrmr_gtwx_contract") ||
      nrow(rows) != contract$PlannedRows || anyDuplicated(rows$RouteId)) {
    stop("Threshold-free summaries require the exact atomic ledger.",
         call. = FALSE)
  }
  score_columns <- contract$CommonScores
  list(
    Availability = mfrmr_gtwx_availability_summary(rows),
    SpearmanOrdering = mfrmr_gtwx_spearman_summary(rows, score_columns),
    RegisteredControlRankProbability = mfrmr_gtwx_rank_summary(
      rows, score_columns
    ),
    ThresholdSelected = FALSE, InnerBootstrapRun = FALSE,
    PValuesAssigned = FALSE, IntervalsAssigned = FALSE
  )
}

mfrmr_gtwx_execute <- function(contract, manifest, authorization,
                                checkpoint_root,
                                progress_every = 25L) {
  if (!inherits(contract, "mfrmr_gtwx_contract") ||
      !inherits(manifest, "mfrmr_gtwf_manifest") ||
      !inherits(authorization, "mfrmr_gtwf_authorization") ||
      !identical(contract$FeasibilityManifestHash, manifest$ManifestHash) ||
      !identical(contract$FeasibilityAuthorizationHash,
                 authorization$AuthorizationHash) ||
      !isTRUE(contract$ExecutionAuthorized) ||
      isTRUE(contract$ThresholdSelectionPermitted) ||
      isTRUE(contract$InnerBootstrapPermitted) ||
      isTRUE(contract$EarlyStoppingPermitted)) {
    stop("The frozen feasibility runner is not authorized.", call. = FALSE)
  }
  checkpoint_root <- mfrmr_gtwx_checkpoint_root(checkpoint_root)
  progress_every <- as.integer(progress_every)
  if (length(progress_every) != 1L || is.na(progress_every) ||
      progress_every < 0L) {
    stop("`progress_every` must be one nonnegative integer.", call. = FALSE)
  }
  rows <- manifest$Rows
  dataset_ids <- unique(rows$DatasetId)
  atomic_rows <- vector("list", nrow(rows))
  route_hashes <- character(nrow(rows))
  marker_hashes <- character(length(dataset_ids))
  timing <- vector("list", nrow(rows))
  reused <- logical(nrow(rows))
  row_cursor <- 0L
  registry <- mfrmr_gtw_registry()

  for (dataset_index in seq_along(dataset_ids)) {
    dataset_id <- dataset_ids[[dataset_index]]
    routes <- rows[rows$DatasetId == dataset_id, , drop = FALSE]
    route_paths <- vapply(routes$RouteId, function(route_id) {
      mfrmr_gtwx_route_path(checkpoint_root, route_id)
    }, character(1L))
    checkpoints <- lapply(route_paths, function(path) {
      mfrmr_gtwx_safe_read(path)
    })
    validations <- lapply(seq_len(nrow(routes)), function(index) {
      mfrmr_gtwx_validate_route(
        checkpoints[[index]], contract, routes[index, , drop = FALSE]
      )
    })
    route_valid <- vapply(validations, `[[`, logical(1L), "Valid")
    initially_valid <- route_valid
    marker_path <- mfrmr_gtwx_dataset_path(checkpoint_root, dataset_id)
    marker <- mfrmr_gtwx_safe_read(marker_path)
    marker_valid <- all(route_valid) && mfrmr_gtwx_validate_dataset(
      marker, contract, dataset_id, checkpoints
    )

    generation <- NULL
    prefit <- NULL
    generation_error <- NULL
    if (!all(route_valid)) {
      generated <- tryCatch({
        generation <- mfrmr_gtw_generate(
          registry, routes$ScenarioId[[1L]], routes$Replicate[[1L]]
        )
        prefit <- mfrmr_gtd3_prefit_one(generation)
        TRUE
      }, error = function(error) error)
      if (inherits(generated, "error")) generation_error <- generated

      for (method_index in which(!route_valid)) {
        route <- routes[method_index, , drop = FALSE]
        pair <- NULL
        pair_error <- generation_error
        clock <- system.time({
          if (is.null(generation_error)) {
            attempted <- tryCatch(
              mfrmr_gtwd_diagnostic_pair(
                generation, prefit, route$MethodId[[1L]],
                target_component = contract$TargetComponent,
                boundary_tolerance = contract$BoundaryTolerance,
                negative_likelihood_tolerance =
                  contract$NegativeLikelihoodTolerance
              ),
              error = function(error) error
            )
            if (inherits(attempted, "error")) pair_error <- attempted else
              pair <- attempted
          }
        }, gcFirst = TRUE)
        if (is.null(pair)) {
          stage <- if (is.null(generation_error)) "diagnostic_pair" else
            "generation_or_prefit"
          atomic <- mfrmr_gtwf_failure_row(
            route, stage, conditionMessage(pair_error)
          )
        } else {
          observable <- mfrmr_gtwf_observable_row(
            route, pair, generation,
            boundary_tolerance = contract$BoundaryTolerance
          )
          atomic <- mfrmr_gtwf_success_row(route, observable)
        }
        route_timing <- data.frame(
          RouteId = route$RouteId[[1L]],
          UserSeconds = unname(clock[["user.self"]]),
          SystemSeconds = unname(clock[["sys.self"]]),
          ElapsedSeconds = unname(clock[["elapsed"]]),
          stringsAsFactors = FALSE
        )
        checkpoint <- mfrmr_gtwx_route_checkpoint(
          contract, route, generation, prefit, atomic, route_timing
        )
        mfrmr_gtwx_atomic_write(checkpoint, route_paths[[method_index]])
        checkpoints[[method_index]] <- checkpoint
        validations[[method_index]] <- mfrmr_gtwx_validate_route(
          checkpoint, contract, route
        )
        route_valid[[method_index]] <- validations[[method_index]]$Valid
      }
    }
    if (!all(route_valid)) {
      stop("A dataset does not have four valid atomic route checkpoints.",
           call. = FALSE)
    }
    if (!marker_valid) {
      marker <- mfrmr_gtwx_dataset_marker(
        contract, dataset_id, checkpoints
      )
      mfrmr_gtwx_atomic_write(marker, marker_path)
      marker_valid <- mfrmr_gtwx_validate_dataset(
        marker, contract, dataset_id, checkpoints
      )
    }
    if (!marker_valid) {
      stop("Dataset completion marker validation failed.", call. = FALSE)
    }

    for (method_index in seq_len(nrow(routes))) {
      row_cursor <- row_cursor + 1L
      validation <- validations[[method_index]]
      atomic_rows[[row_cursor]] <- validation$AtomicResult
      route_hashes[[row_cursor]] <- validation$RouteResultHash
      reused[[row_cursor]] <- isTRUE(initially_valid[[method_index]])
      route_timing <- checkpoints[[method_index]]$Timing
      timing[[row_cursor]] <- if (is.data.frame(route_timing)) route_timing else
        data.frame(
          RouteId = routes$RouteId[[method_index]], UserSeconds = NA_real_,
          SystemSeconds = NA_real_, ElapsedSeconds = NA_real_,
          stringsAsFactors = FALSE
        )
    }
    marker_hashes[[dataset_index]] <- marker$DatasetMarkerHash
    if (progress_every > 0L &&
        (dataset_index %% progress_every == 0L ||
         dataset_index == length(dataset_ids))) {
      message(sprintf(
        "[feasibility dataset %d/%d] %s", dataset_index,
        length(dataset_ids), dataset_id
      ))
    }
  }
  atomic <- do.call(rbind, atomic_rows)
  timing <- do.call(rbind, timing)
  row.names(atomic) <- NULL
  row.names(timing) <- NULL
  expected_order <- match(rows$RouteId, atomic$RouteId)
  if (anyNA(expected_order)) {
    stop("Atomic ledger is missing registered routes.", call. = FALSE)
  }
  atomic <- atomic[expected_order, , drop = FALSE]
  timing <- timing[match(rows$RouteId, timing$RouteId), , drop = FALSE]
  route_hashes <- route_hashes[expected_order]
  reused <- reused[expected_order]
  names(route_hashes) <- atomic$RouteId
  names(marker_hashes) <- dataset_ids

  exact <- nrow(atomic) == contract$PlannedRows &&
    !anyDuplicated(atomic$RouteId) &&
    identical(as.character(atomic$RouteId), as.character(rows$RouteId)) &&
    length(marker_hashes) == contract$PlannedDatasets &&
    all(table(atomic$DatasetId) == contract$MethodsPerDataset) &&
    all(table(atomic$ScenarioId, atomic$MethodId) == 25L)
  if (!exact) stop("Final feasibility accounting is not exact.", call. = FALSE)
  summaries <- mfrmr_gtwx_summaries(atomic, contract)
  scientific_identity <- list(
    Contract = "gtheory_weak_information_feasibility_execution_draft83d2b2b1d_v1",
    RunnerContractHash = contract$RunnerContractHash,
    FeasibilityManifestHash = manifest$ManifestHash,
    FeasibilityAuthorizationHash = authorization$AuthorizationHash,
    AtomicRows = atomic,
    RouteResultHashes = route_hashes,
    DatasetMarkerHashes = marker_hashes,
    ThresholdFreeSummaries = summaries
  )
  structure(c(scientific_identity, list(
    ExecutionHash = mfrmr_gta_hash(scientific_identity),
    RouteTiming = timing, CheckpointReuse = reused,
    CheckpointReuseCount = sum(reused),
    ComputedRouteCount = sum(!reused),
    ExactAccountingPassed = exact,
    PlannedRows = contract$PlannedRows,
    PlannedDatasets = contract$PlannedDatasets,
    PlannedBackendFits = contract$PlannedBackendFits,
    PairReturnCount = sum(atomic$PairReturned %in% TRUE),
    TypedFailureCount = sum(!(atomic$PairReturned %in% TRUE)),
    CommonScoreAvailableCount = sum(
      atomic$FeasibilityScoreAvailable %in% TRUE
    ),
    MaterialNegativeDropCount = sum(
      atomic$PairReturned %in% TRUE &
        !(atomic$NegativeDropWithinTolerance %in% TRUE)
    ),
    TargetBoundaryCount = sum(
      atomic$TargetBoundaryToleranceReached %in% TRUE
    ),
    NuisanceBoundaryCount = sum(atomic$NuisanceBoundaryPresent %in% TRUE),
    FeasibilityEvidenceReady = exact,
    BootstrapOperatingCharacteristicsReady = FALSE,
    CalibrationEvidenceReady = FALSE, ThresholdFrozen = FALSE,
    ConfirmationAuthorized = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtwx_execution")
}
