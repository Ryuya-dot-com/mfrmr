# Draft.83d2b2b1g2 deterministic glmmTMB fixed-coordinate alignment runner.
#
# Repository-internal only. This replays the exact b1g1 covering smoke under a
# new identity; full-manifest execution and all inferential uses remain barred.

mfrmr_gtwsw_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtwy_function_hash",
    "mfrmr_gtwst_start_signature", "mfrmr_gtwsv_contract",
    "mfrmr_gtwsv_execute", "mfrmr_gtwsv_empty_diagnostics",
    "mfrmr_gtwsv_fit_diagnostics"
  )
  audit_environment <- environment(mfrmr_gtwsw_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = audit_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the complete corrected Draft.83d2b2b1g1 chain before b1g2: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwsw_validate_upstream <- function(execution) {
  inherits(execution, "mfrmr_gtwsv_execution") &&
    identical(
      execution$RunnerContractHash,
      "3ae866b7b7179917400e6c5e5b9dd3fcf01b6ff70c6fc914564b80836c83f192"
    ) &&
    identical(
      execution$ExecutionHash,
      "c743de38ec7d5ff6606c5b1df7960caea4bca149b470063e8496db83b5ab439d"
    ) &&
    isTRUE(execution$ExactAccountingPassed) &&
    identical(execution$PlannedPairs, 120L) &&
    identical(execution$PlannedBackendFits, 240L) &&
    identical(execution$PairReturnCount, 116L) &&
    is.data.frame(execution$AtomicRows) &&
    nrow(execution$AtomicRows) == 120L &&
    !anyDuplicated(execution$AtomicRows$StabilizationRouteId) &&
    identical(
      sum(execution$AtomicRows$FullReturned %in% TRUE), 117L
    ) &&
    identical(
      sum(execution$AtomicRows$ReducedReturned %in% TRUE), 119L
    ) &&
    isTRUE(execution$SmokeRunnerMechanicsReady) &&
    !isTRUE(execution$FullExecutionAuthorized) &&
    !isTRUE(execution$NumericalStabilizationReady) &&
    !isTRUE(execution$NumericalSensitivityEvidenceReady) &&
    !isTRUE(execution$CalibrationEvidenceReady) &&
    !isTRUE(execution$ThresholdFrozen) &&
    !isTRUE(execution$InferenceReady) && !isTRUE(execution$DecisionReady)
}

mfrmr_gtwsw_extract_start <- function(fit) {
  if (!inherits(fit, "glmmTMB")) {
    stop("Start extraction requires one glmmTMB fit.", call. = FALSE)
  }
  raw_joint <- as.numeric(fit$obj$env$last.par.best)
  fixed_index <- fit$obj$env$lfixed()
  top <- as.numeric(fit$fit$par)
  if (!is.logical(fixed_index) || length(fixed_index) != length(raw_joint) ||
      sum(fixed_index) != length(top) || !all(is.finite(raw_joint)) ||
      !all(is.finite(top))) {
    stop("The immediate joint-best snapshot is invalid.", call. = FALSE)
  }
  pre_exact <- identical(unname(raw_joint[fixed_index]), unname(top))
  pre_difference <- if (length(top) == 0L) 0 else
    max(abs(raw_joint[fixed_index] - top))
  aligned_joint <- raw_joint
  aligned_joint[fixed_index] <- top
  aligned_exact <- identical(
    unname(aligned_joint[fixed_index]), unname(top)
  )
  if (!aligned_exact) {
    stop("Deterministic fixed-coordinate alignment failed.", call. = FALSE)
  }
  blocks <- fit$obj$env$parList(x = top, par = aligned_joint)
  block_signature <- mfrmr_gtwst_start_signature(blocks)
  identity <- list(
    Contract =
      "glmmtmb_deterministic_fixed_coordinate_alignment_draft83d2b2b1g2_v1",
    AlignmentRule = "aligned_joint[lfixed()] <- fit$fit$par",
    RawJointBestHash = mfrmr_gta_hash(raw_joint),
    AlignedJointBestHash = mfrmr_gta_hash(aligned_joint),
    JointBestHash = mfrmr_gta_hash(aligned_joint),
    JointBestLength = length(aligned_joint),
    FixedIndexHash = mfrmr_gta_hash(fixed_index),
    RawFixedCoordinateHash = mfrmr_gta_hash(raw_joint[fixed_index]),
    AlignedFixedCoordinateHash =
      mfrmr_gta_hash(aligned_joint[fixed_index]),
    TopLevelParameterHash = mfrmr_gta_hash(top),
    PreAlignmentFixedExact = pre_exact,
    PreAlignmentMaximumAbsoluteFixedDifference = pre_difference,
    AlignmentApplied = TRUE,
    AlignedFixedCoordinateExact = aligned_exact,
    FixedCoordinateExact = aligned_exact,
    BlockSignatureHash = block_signature$SignatureHash,
    BlockLengths = block_signature$Blocks$BlockLength,
    BlockHashes = block_signature$Blocks$BlockHash
  )
  structure(c(identity, list(
    SignatureHash = mfrmr_gta_hash(identity),
    StartList = block_signature$Values
  )), class = c(
    "mfrmr_gtwsw_start_signature", "mfrmr_gtwsv_start_signature"
  ))
}

mfrmr_gtwsw_empty_diagnostics <- function() {
  base <- mfrmr_gtwsv_empty_diagnostics_unaligned()
  c(base, list(
    RawJointBestHash = "none", AlignedJointBestHash = "none",
    PreAlignmentFixedExact = FALSE,
    PreAlignmentMaximumAbsoluteFixedDifference = NA_real_,
    AlignmentApplied = FALSE, AlignedFixedCoordinateExact = FALSE
  ))
}

mfrmr_gtwsw_fit_diagnostics <- function(fit, final_signature,
                                          runner_contract) {
  base <- mfrmr_gtwsv_fit_diagnostics_unaligned(
    fit, final_signature, runner_contract
  )
  c(base, list(
    RawJointBestHash = final_signature$RawJointBestHash,
    AlignedJointBestHash = final_signature$AlignedJointBestHash,
    PreAlignmentFixedExact = final_signature$PreAlignmentFixedExact,
    PreAlignmentMaximumAbsoluteFixedDifference =
      final_signature$PreAlignmentMaximumAbsoluteFixedDifference,
    AlignmentApplied = final_signature$AlignmentApplied,
    AlignedFixedCoordinateExact =
      final_signature$AlignedFixedCoordinateExact
  ))
}

mfrmr_gtwsw_runner_environment <- function() {
  mfrmr_gtwsw_require_primitives()
  source_environment <- environment(mfrmr_gtwsw_runner_environment)
  isolated <- new.env(parent = source_environment)
  functions <- c(
    "mfrmr_gtwsv_control", "mfrmr_gtwsv_gradient_summary",
    "mfrmr_gtwsv_richardson", "mfrmr_gtwsv_fit_one",
    "mfrmr_gtwsv_pair_state", "mfrmr_gtwsv_fit_pair",
    "mfrmr_gtwsv_diag_fields", "mfrmr_gtwsv_atomic_row",
    "mfrmr_gtwsv_failure_rows", "mfrmr_gtwsv_base_route",
    "mfrmr_gtwsv_checkpoint_path", "mfrmr_gtwsv_marker_path",
    "mfrmr_gtwsv_checkpoint", "mfrmr_gtwsv_validate_checkpoint",
    "mfrmr_gtwsv_marker", "mfrmr_gtwsv_validate_marker",
    "mfrmr_gtwsv_summaries", "mfrmr_gtwsv_execute"
  )
  for (name in functions) {
    value <- get(name, envir = source_environment, inherits = TRUE)
    environment(value) <- isolated
    assign(name, value, envir = isolated)
  }
  for (name in c(
    "mfrmr_gtwsv_empty_diagnostics", "mfrmr_gtwsv_fit_diagnostics"
  )) {
    value <- get(name, envir = source_environment, inherits = TRUE)
    environment(value) <- isolated
    assign(paste0(name, "_unaligned"), value, envir = isolated)
  }
  replacements <- list(
    mfrmr_gtwsv_extract_start = mfrmr_gtwsw_extract_start,
    mfrmr_gtwsv_empty_diagnostics = mfrmr_gtwsw_empty_diagnostics,
    mfrmr_gtwsv_fit_diagnostics = mfrmr_gtwsw_fit_diagnostics
  )
  for (name in names(replacements)) {
    value <- replacements[[name]]
    environment(value) <- isolated
    assign(name, value, envir = isolated)
  }
  isolated
}

mfrmr_gtwsw_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwsw_validate_upstream", "mfrmr_gtwsw_extract_start",
    "mfrmr_gtwsw_empty_diagnostics", "mfrmr_gtwsw_fit_diagnostics",
    "mfrmr_gtwsw_runner_environment", "mfrmr_gtwsw_contract",
    "mfrmr_gtwsw_execute", "mfrmr_gtwsw_typed_equal",
    "mfrmr_gtwsw_compare"
  )
  audit_environment <- environment(mfrmr_gtwsw_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwy_function_hash(get(
      name, envir = audit_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}

mfrmr_gtwsw_contract <- function(design_contract, design_manifest,
                                   upstream_execution) {
  mfrmr_gtwsw_require_primitives()
  if (!mfrmr_gtwsw_validate_upstream(upstream_execution)) {
    stop("The exact b1g1 negative-result execution is required.",
         call. = FALSE)
  }
  upstream <- mfrmr_gtwsv_contract(design_contract, design_manifest)
  if (!identical(
    upstream$RunnerContractHash,
    "3ae866b7b7179917400e6c5e5b9dd3fcf01b6ff70c6fc914564b80836c83f192"
  ) || !identical(
    as.character(upstream$SmokeIdentity$StabilizationRouteId),
    as.character(upstream_execution$AtomicRows$StabilizationRouteId)
  )) {
    stop("The b1g1 contract or ordered smoke denominator changed.",
         call. = FALSE)
  }
  identity <- list(
    Contract = paste0(
      "gtheory_weak_information_glmmtmb_alignment_",
      "runner_draft83d2b2b1g2_v1"
    ),
    ContractArtifact = paste0(
      "gtheory-weak-information-glmmtmb-alignment-contract-0.2.3.md"
    ),
    UpstreamRunnerContractHash = upstream$RunnerContractHash,
    UpstreamExecutionHash = upstream_execution$ExecutionHash,
    StabilizationContractHash = upstream$StabilizationContractHash,
    StabilizationManifestHash = upstream$StabilizationManifestHash,
    Profiles = upstream$Profiles, SmokeIdentity = upstream$SmokeIdentity,
    SmokePairCount = upstream$SmokePairCount,
    SmokeBackendFitCount = upstream$SmokeBackendFitCount,
    SmokeBaseRouteCount = upstream$SmokeBaseRouteCount,
    SmokeDatasetCount = upstream$SmokeDatasetCount,
    SmokeRowsPerBaseRoute = upstream$SmokeRowsPerBaseRoute,
    SmokeRowsPerDataset = upstream$SmokeRowsPerDataset,
    SmokeSelection = upstream$SmokeSelection,
    TargetComponent = upstream$TargetComponent,
    BoundaryTolerance = upstream$BoundaryTolerance,
    NegativeLikelihoodTolerance = upstream$NegativeLikelihoodTolerance,
    Richardson = upstream$Richardson,
    ParentFailurePolicy = upstream$ParentFailurePolicy,
    AtomicUnit = upstream$AtomicUnit,
    AlignmentRule = "aligned_joint[lfixed()] <- fit$fit$par",
    AlignmentAppliesToEveryReturnedFit = TRUE,
    AlignmentTolerance = "none",
    RandomModeMutationPermitted = FALSE,
    OutcomeDependentSelection = FALSE,
    ComparisonDenominator = 120L,
    ScientificHashExclusions = upstream$ScientificHashExclusions,
    EarlyStoppingPermitted = FALSE, AdaptiveFallbackPermitted = FALSE,
    CalibrationDataGenerationPermitted = FALSE,
    ThresholdSelectionPermitted = FALSE, BootstrapPermitted = FALSE,
    PackageVersions = upstream$PackageVersions,
    UpstreamFunctionHashes = upstream$FunctionHashes,
    FunctionHashes = mfrmr_gtwsw_function_hashes()
  )
  structure(c(identity, list(
    RunnerContractHash = mfrmr_gta_hash(identity),
    RunnerImplemented = TRUE, SmokeExecutionAuthorized = TRUE,
    AlignmentSmokeExecutionAuthorized = TRUE,
    FullExecutionAuthorized = FALSE,
    NumericalStabilizationReady = FALSE,
    NumericalSensitivityEvidenceReady = FALSE,
    CalibrationEvidenceReady = FALSE, ThresholdFrozen = FALSE,
    ConfirmationAuthorized = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )), class = c("mfrmr_gtwsw_contract", "mfrmr_gtwsv_contract"))
}

mfrmr_gtwsw_execute <- function(runner_contract, design_manifest,
                                  checkpoint_root,
                                  progress_every = 1L) {
  if (!inherits(runner_contract, "mfrmr_gtwsw_contract") ||
      !isTRUE(runner_contract$AlignmentSmokeExecutionAuthorized) ||
      isTRUE(runner_contract$FullExecutionAuthorized) ||
      !identical(runner_contract$AlignmentTolerance, "none") ||
      !isTRUE(runner_contract$AlignmentAppliesToEveryReturnedFit) ||
      isTRUE(runner_contract$RandomModeMutationPermitted)) {
    stop("The exact b1g2 alignment smoke is not authorized.", call. = FALSE)
  }
  isolated <- mfrmr_gtwsw_runner_environment()
  underlying <- isolated$mfrmr_gtwsv_execute(
    runner_contract, design_manifest, checkpoint_root, progress_every
  )
  rows <- underlying$AtomicRows
  full_returned <- rows$FullReturned %in% TRUE
  reduced_returned <- rows$ReducedReturned %in% TRUE
  aligned <- all(rows$FullAlignmentApplied[full_returned] %in% TRUE) &&
    all(rows$ReducedAlignmentApplied[reduced_returned] %in% TRUE) &&
    all(rows$FullAlignedFixedCoordinateExact[full_returned] %in% TRUE) &&
    all(rows$ReducedAlignedFixedCoordinateExact[reduced_returned] %in% TRUE)
  if (!aligned) {
    stop("A returned fit lacks exact deterministic alignment.",
         call. = FALSE)
  }
  alignment_summary <- list(
    FullReturnedCount = sum(full_returned),
    ReducedReturnedCount = sum(reduced_returned),
    FullPreAlignmentMismatchCount = sum(
      full_returned & !(rows$FullPreAlignmentFixedExact %in% TRUE)
    ),
    ReducedPreAlignmentMismatchCount = sum(
      reduced_returned & !(rows$ReducedPreAlignmentFixedExact %in% TRUE)
    ),
    FullAlignedExactCount = sum(
      full_returned & rows$FullAlignedFixedCoordinateExact %in% TRUE
    ),
    ReducedAlignedExactCount = sum(
      reduced_returned & rows$ReducedAlignedFixedCoordinateExact %in% TRUE
    ),
    MaximumPreAlignmentFixedDifference = max(c(
      rows$FullPreAlignmentMaximumAbsoluteFixedDifference[full_returned],
      rows$ReducedPreAlignmentMaximumAbsoluteFixedDifference[reduced_returned]
    ), na.rm = TRUE),
    AlignmentRuleSelectedFromObservedDifference = FALSE
  )
  identity <- list(
    Contract = paste0(
      "gtheory_weak_information_glmmtmb_alignment_",
      "smoke_draft83d2b2b1g2_v1"
    ),
    RunnerContractHash = runner_contract$RunnerContractHash,
    UpstreamRunnerContractHash = runner_contract$UpstreamRunnerContractHash,
    UpstreamExecutionHash = runner_contract$UpstreamExecutionHash,
    UnderlyingExecutionHash = underlying$ExecutionHash,
    StabilizationContractHash = runner_contract$StabilizationContractHash,
    StabilizationManifestHash = runner_contract$StabilizationManifestHash,
    AtomicRows = rows,
    BaseRouteCheckpointHashes = underlying$BaseRouteCheckpointHashes,
    DatasetMarkerHashes = underlying$DatasetMarkerHashes,
    Summaries = underlying$Summaries,
    AlignmentSummary = alignment_summary
  )
  structure(c(identity, list(
    ExecutionHash = mfrmr_gta_hash(identity),
    RouteTiming = underlying$RouteTiming,
    CheckpointReuse = underlying$CheckpointReuse,
    CheckpointReuseCount = underlying$CheckpointReuseCount,
    ComputedBaseRouteCount = underlying$ComputedBaseRouteCount,
    ExactAccountingPassed = underlying$ExactAccountingPassed,
    PlannedPairs = underlying$PlannedPairs,
    PlannedBackendFits = underlying$PlannedBackendFits,
    PairReturnCount = underlying$PairReturnCount,
    StartTransferVerifiedCount =
      underlying$StartTransferVerifiedCount,
    AlignmentMechanicsReady = isTRUE(aligned) &&
      isTRUE(underlying$ExactAccountingPassed),
    SmokeRunnerMechanicsReady = underlying$SmokeRunnerMechanicsReady,
    FullExecutionAuthorized = FALSE,
    NumericalStabilizationReady = FALSE,
    NumericalSensitivityEvidenceReady = FALSE,
    CalibrationEvidenceReady = FALSE,
    BootstrapOperatingCharacteristicsReady = FALSE,
    ThresholdFrozen = FALSE, ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = c("mfrmr_gtwsw_execution", "mfrmr_gtwsv_execution"))
}

mfrmr_gtwsw_typed_equal <- function(x, y) {
  mapply(function(left, right) {
    identical(left, right) ||
      (is.na(left) && is.na(right) && identical(typeof(left), typeof(right)))
  }, x, y, USE.NAMES = FALSE)
}

mfrmr_gtwsw_compare <- function(upstream_execution, alignment_execution) {
  if (!mfrmr_gtwsw_validate_upstream(upstream_execution) ||
      !inherits(alignment_execution, "mfrmr_gtwsw_execution") ||
      !isTRUE(alignment_execution$ExactAccountingPassed) ||
      !identical(alignment_execution$UpstreamExecutionHash,
                 upstream_execution$ExecutionHash)) {
    stop("Exact b1g1 and b1g2 executions are required.", call. = FALSE)
  }
  before <- upstream_execution$AtomicRows
  after <- alignment_execution$AtomicRows
  index <- match(before$StabilizationRouteId, after$StabilizationRouteId)
  if (anyNA(index) || nrow(before) != 120L || nrow(after) != 120L ||
      anyDuplicated(after$StabilizationRouteId)) {
    stop("The full 120-row comparison denominator is incomplete.",
         call. = FALSE)
  }
  after <- after[index, , drop = FALSE]
  same_identity <- identical(
    as.character(before$StabilizationRouteId),
    as.character(after$StabilizationRouteId)
  )
  full_both <- before$FullReturned & after$FullReturned
  reduced_both <- before$ReducedReturned & after$ReducedReturned
  drop_equal <- mfrmr_gtwsw_typed_equal(
    before$RawLikelihoodDrop, after$RawLikelihoodDrop
  )
  paired <- data.frame(
    StabilizationRouteId = before$StabilizationRouteId,
    BeforePairReturned = before$PairReturned,
    AfterPairReturned = after$PairReturned,
    BeforeState = before$StabilizationState,
    AfterState = after$StabilizationState,
    StateEqual = before$StabilizationState == after$StabilizationState,
    TypedLikelihoodDropEqual = drop_equal,
    FullTopLevelHashEqual = full_both &
      before$FullTopLevelParameterHash == after$FullTopLevelParameterHash,
    ReducedTopLevelHashEqual = reduced_both &
      before$ReducedTopLevelParameterHash ==
        after$ReducedTopLevelParameterHash,
    stringsAsFactors = FALSE
  )
  summary <- list(
    ComparisonDenominator = nrow(paired),
    OrderedIdentityExact = same_identity,
    PairReturnRecoveredCount = sum(
      !(before$PairReturned %in% TRUE) & after$PairReturned %in% TRUE
    ),
    PairReturnLostCount = sum(
      before$PairReturned %in% TRUE & !(after$PairReturned %in% TRUE)
    ),
    FullReturnRecoveredCount = sum(
      !(before$FullReturned %in% TRUE) & after$FullReturned %in% TRUE
    ),
    FullReturnLostCount = sum(
      before$FullReturned %in% TRUE & !(after$FullReturned %in% TRUE)
    ),
    ReducedReturnRecoveredCount = sum(
      !(before$ReducedReturned %in% TRUE) & after$ReducedReturned %in% TRUE
    ),
    ReducedReturnLostCount = sum(
      before$ReducedReturned %in% TRUE & !(after$ReducedReturned %in% TRUE)
    ),
    StabilizationStateChangedCount = sum(!paired$StateEqual),
    TypedLikelihoodDropMismatchCount = sum(!drop_equal),
    FullCommonReturnedCount = sum(full_both),
    FullTopLevelHashMismatchCount = sum(
      full_both & !paired$FullTopLevelHashEqual
    ),
    ReducedCommonReturnedCount = sum(reduced_both),
    ReducedTopLevelHashMismatchCount = sum(
      reduced_both & !paired$ReducedTopLevelHashEqual
    ),
    CompleteCaseSelectionUsed = FALSE
  )
  identity <- list(
    Contract = paste0(
      "gtheory_weak_information_glmmtmb_alignment_",
      "comparison_draft83d2b2b1g2_v1"
    ),
    UpstreamExecutionHash = upstream_execution$ExecutionHash,
    AlignmentExecutionHash = alignment_execution$ExecutionHash,
    PairedRows = paired, Summary = summary
  )
  structure(c(identity, list(
    ComparisonHash = mfrmr_gta_hash(identity),
    FullDenominatorComparisonReady = same_identity && nrow(paired) == 120L,
    AlignmentMechanicsReady =
      isTRUE(alignment_execution$AlignmentMechanicsReady),
    FullExecutionAuthorized = FALSE,
    NumericalStabilizationReady = FALSE,
    NumericalSensitivityEvidenceReady = FALSE,
    CalibrationEvidenceReady = FALSE, ThresholdFrozen = FALSE,
    InferenceReady = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtwsw_comparison")
}
