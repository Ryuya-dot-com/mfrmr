# Prospective Rater-anchor by sparse-design stress contract for mfrmr 0.2.3.
#
# Repository-only: this freezes the expanded PCM/JML design, paired identities,
# resource accounting, performance measures, and decision rules. It runs no
# fit and cannot select an operational Rater-anchor percentage. Source the
# companion canonical-hash helper before using this contract.

mfrmr_rasp_specification <- "0.2.3-draft.1"
mfrmr_rasp_contract <- "mfrmr_rater_anchor_sparse_prospective_contract_v1"

mfrmr_rasp_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_rasp_require_canonical_hash <- function() {
  source_environment <- environment(mfrmr_rasp_require_canonical_hash)
  available <- exists(
    "mfrmr_rash_hash_tables", mode = "function",
    envir = source_environment, inherits = TRUE
  ) && exists(
    "mfrmr_rash_format", envir = source_environment, inherits = TRUE
  )
  mfrmr_rasp_assert(
    available,
    "Source the Rater-anchor canonical-hash helper before this contract."
  )
  invisible(TRUE)
}

mfrmr_rasp_factor_catalog <- function() {
  data.frame(
    FactorId = c(
      "direct_rater_anchor_rate", "anchor_selection", "anchor_error",
      "assignment_topology", "common_link_person_rate",
      "common_link_selection", "raters_per_nonlink_person",
      "person_count", "rater_count", "criterion_count", "category_count",
      "estimator_lane"
    ),
    RegisteredLevels = c(
      "0;0.125;0.25;0.50", "none;range_spanning;central_cluster",
      "none;oracle_exact;normal_sd_0.10;normal_sd_0.25;shift_plus_0.25",
      "complete;single_rater;two_rater_cycle", "0;0.05;0.125;1",
      "none;range_spanning;central_cluster;all", "1;2;16",
      "160", "16", "4", "4", "PCM_JML"
    ),
    Role = c(
      "primary_exposure", "composition_stress", "transport_error_stress",
      "network_structure", "universal_link_resource",
      "link_composition_stress", "repeat_rating_resource",
      rep("fixed_scale", 4L), "fixed_direct_lane"
    ),
    FullFactorial = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_rasp_anchor_registry <- function() {
  data.frame(
    AnchorConfig = c(
      "none", "exact_12_5_span", "exact_25_span", "exact_50_span",
      "normal_sd10_25_span", "normal_sd25_25_span",
      "shifted_plus25_25_span", "exact_25_central"
    ),
    AnchorRate = c(0, 0.125, 0.25, 0.50, 0.25, 0.25, 0.25, 0.25),
    AnchorCount = c(0L, 2L, 4L, 8L, 4L, 4L, 4L, 4L),
    SelectionRule = c(
      "none", "range_spanning", "range_spanning", "range_spanning",
      "range_spanning", "range_spanning", "range_spanning",
      "central_cluster"
    ),
    SelectionSource = c(
      "none", rep("external_calibration_estimate", 7L)
    ),
    SelectionCalibrationSD = c(NA, rep(0.10, 7L)),
    ErrorMechanism = c(
      "none", "oracle_exact", "oracle_exact", "oracle_exact",
      "independent_normal", "independent_normal", "systematic_shift",
      "oracle_exact"
    ),
    ErrorSD = c(NA, 0, 0, 0, 0.10, 0.25, 0, 0),
    ErrorShift = c(NA, 0, 0, 0, 0, 0, 0.25, 0),
    Role = c(
      "unanchored_reference", "low_exact_rate", "primary_exact_candidate",
      "high_exact_sensitivity", "mild_external_error",
      "material_external_error", "directional_transport_error",
      "anchor_composition_negative_control"
    ),
    RateComparisonEligible = c(TRUE, TRUE, TRUE, TRUE, rep(FALSE, 4L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_rasp_design_registry <- function() {
  data.frame(
    DesignId = c(
      "complete", "sparse_link0", "sparse_link05_range",
      "sparse_link125_range", "sparse_link125_central",
      "sparse_pair_cycle", "sparse_pair_link05_range"
    ),
    AssignmentTopology = c(
      "complete", "single_rater", "single_rater", "single_rater",
      "single_rater", "two_rater_cycle", "two_rater_cycle"
    ),
    LinkPersons = c(160L, 0L, 8L, 20L, 20L, 0L, 8L),
    LinkPersonRate = c(1, 0, 0.05, 0.125, 0.125, 0, 0.05),
    LinkSelection = c(
      "all", "none", "range_spanning", "range_spanning",
      "central_cluster", "none", "range_spanning"
    ),
    RatersPerNonlinkPerson = c(16L, 1L, 1L, 1L, 1L, 2L, 2L),
    ExpectedRatingAssignments = c(2560L, 160L, 280L, 460L, 460L, 320L, 432L),
    ExpectedResponseRows = c(10240L, 640L, 1120L, 1840L, 1840L, 1280L, 1728L),
    AddedAssignmentsAboveSingle = c(2400L, 0L, 120L, 300L, 300L, 160L, 272L),
    ExpectedDensity = c(
      1, 0.0625, 0.109375, 0.1796875, 0.1796875, 0.125, 0.16875
    ),
    Role = c(
      "fully_crossed_reference", "disconnected_negative_control",
      "small_representative_universal_link",
      "moderate_representative_universal_link",
      "moderate_range_restricted_universal_link",
      "connected_repeat_rating_without_universal_link",
      "connected_repeat_rating_plus_small_universal_link"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_rasp_metric_registry <- function() {
  data.frame(
    MetricId = c(
      "fit_return_rate", "inference_ready_rate", "structural_failure_rate",
      "metric_availability_rate", "free_rater_absolute_rmse",
      "free_rater_centered_rmse", "free_rater_bias",
      "rater_rank_spearman", "person_absolute_rmse", "person_bias",
      "person_rank_spearman", "criterion_centered_rmse",
      "paired_free_rater_rmse_delta_vs_none",
      "paired_person_rmse_delta_vs_none",
      "paired_person_rmse_delta_vs_exact_25",
      "direct_anchor_units", "added_rating_assignment_units"
    ),
    Family = c(
      rep("execution_readiness", 4L), rep("rater_recovery", 4L),
      rep("person_recovery", 3L), "criterion_recovery",
      rep("paired_contrast", 3L), rep("resource", 2L)
    ),
    Denominator = c(
      rep("all_planned_runs", 4L), rep("value_available_runs", 8L),
      rep("paired_value_available_runs", 3L), rep("declared_manifest", 2L)
    ),
    Direction = c(
      "higher", "higher", "lower", "higher", rep("lower", 3L),
      "higher", "lower", "absolute_lower", "higher", "lower",
      rep("lower", 5L)
    ),
    Primary = c(
      FALSE, TRUE, TRUE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE,
      TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_rasp_decision_registry <- function() {
  data.frame(
    RuleId = c(
      "separate_networks", "exact_denominators", "paired_seed_contrasts",
      "free_rater_only", "error_arm_role", "resource_frontier",
      "feasibility_authority", "confirmation_precision",
      "operational_rate_authority"
    ),
    Stage = c(
      rep("all", 6L), "feasibility", "confirmation", "post_confirmation"
    ),
    FixedRule = c(
      "Never pool assignment designs when ranking anchor rates.",
      "Every planned run remains in fit, readiness, failure, and availability denominators.",
      "Anchor contrasts reuse the same DataSeed and designed response data.",
      "Primary Rater RMSE excludes fixed Raters; anchored values never score themselves.",
      "Only exact range-spanning 0, 12.5, 25, and 50 percent arms compare rates; error and central arms assess robustness.",
      "Report the Pareto set over readiness, recovery, direct anchors, and added ratings; do not scalarize the two resource types.",
      "Ten replicates estimate runtime, failures, and dispersion only and cannot select a percentage.",
      "Freeze a later replicate count so binary-rate MCSE is at most 0.025 and continuous-metric MCSE is metric-specific.",
      "No operational percentage may be selected without confirmation and externally supplied anchor-versus-rating costs."
    ),
    Threshold = c(
      NA, NA, NA, NA, NA, "strict_nondominance", NA,
      "binary_rate_MCSE<=0.025", "confirmation_and_costs_required"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_rasp_precision_plan <- function() {
  data.frame(
    Profile = c("smoke", "feasibility", "confirmation"),
    Replications = c(1L, 10L, NA_integer_),
    Purpose = c(
      "schema_pairing_and_failure_path_only",
      "runtime_failure_and_dispersion_calibration_only",
      "operating_characteristics_after_separate_freeze_and_authorization"
    ),
    BinaryRateMCSETarget = c(NA, NA, 0.025),
    WorstCaseBinaryMinReplications = c(NA_integer_, NA_integer_, 400L),
    ExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_rasp_registry_hash <- function(registry) {
  mfrmr_rasp_require_canonical_hash()
  mfrmr_rash_hash_tables(
    registry[c(
      "FactorCatalog", "AnchorRegistry", "DesignRegistry",
      "MetricRegistry", "DecisionRegistry", "PrecisionPlan"
    )],
    domain = "prospective_registry"
  )
}

mfrmr_rasp_registry <- function() {
  mfrmr_rasp_require_canonical_hash()
  out <- list(
    Specification = mfrmr_rasp_specification,
    Contract = mfrmr_rasp_contract,
    IdentityFormat = mfrmr_rash_format,
    FactorCatalog = mfrmr_rasp_factor_catalog(),
    AnchorRegistry = mfrmr_rasp_anchor_registry(),
    DesignRegistry = mfrmr_rasp_design_registry(),
    MetricRegistry = mfrmr_rasp_metric_registry(),
    DecisionRegistry = mfrmr_rasp_decision_registry(),
    PrecisionPlan = mfrmr_rasp_precision_plan(),
    Model = "PCM",
    Estimator = "JML",
    SimulationExecuted = FALSE,
    SmokeExecutionAuthorized = FALSE,
    FeasibilityExecutionAuthorized = FALSE,
    BroadSimulationAuthorized = FALSE,
    AppropriateAnchorRateSelected = FALSE,
    ConfirmationAuthorized = FALSE,
    FACETSExternalFitsIncluded = FALSE,
    GPCMIncluded = FALSE
  )
  out$RegistrySHA256 <- mfrmr_rasp_registry_hash(out)
  class(out) <- c("mfrmr_rasp_registry", "list")
  mfrmr_rasp_validate_registry(out)
  out
}

mfrmr_rasp_validate_registry <- function(registry) {
  factors <- registry$FactorCatalog
  anchors <- registry$AnchorRegistry
  designs <- registry$DesignRegistry
  metrics <- registry$MetricRegistry
  decisions <- registry$DecisionRegistry
  precision <- registry$PrecisionPlan
  mfrmr_rasp_assert(
    is.data.frame(factors) && nrow(factors) == 12L &&
      !anyDuplicated(factors$FactorId) && all(!factors$FullFactorial),
    "The factor catalog is incomplete or was expanded factorially."
  )
  mfrmr_rasp_assert(
    is.data.frame(anchors) && nrow(anchors) == 8L &&
      !anyDuplicated(anchors$AnchorConfig) &&
      all(anchors$AnchorCount == as.integer(16L * anchors$AnchorRate)) &&
      identical(
        sort(unique(anchors$AnchorRate[anchors$RateComparisonEligible])),
        c(0, 0.125, 0.25, 0.5)
      ) &&
      all(anchors$ErrorMechanism[anchors$RateComparisonEligible] %in%
            c("none", "oracle_exact")) &&
      all(anchors$SelectionSource[anchors$AnchorRate > 0] ==
            "external_calibration_estimate") &&
      all(anchors$SelectionCalibrationSD[anchors$AnchorRate > 0] == 0.10) &&
      is.na(anchors$SelectionCalibrationSD[anchors$AnchorRate == 0]),
    "Anchor counts, rate-comparison arms, or error roles drifted."
  )
  mfrmr_rasp_assert(
    is.data.frame(designs) && nrow(designs) == 7L &&
      !anyDuplicated(designs$DesignId) &&
      all(designs$ExpectedResponseRows ==
            4L * designs$ExpectedRatingAssignments) &&
      all(designs$AddedAssignmentsAboveSingle ==
            designs$ExpectedRatingAssignments - 160L) &&
      all(abs(designs$ExpectedDensity -
                designs$ExpectedRatingAssignments / (160L * 16L)) < 1e-12),
    "Sparse-design resource accounting drifted."
  )
  mfrmr_rasp_assert(
    is.data.frame(metrics) && nrow(metrics) == 17L &&
      !anyDuplicated(metrics$MetricId) &&
      all(c(
        "inference_ready_rate", "free_rater_absolute_rmse",
        "person_absolute_rmse", "direct_anchor_units",
        "added_rating_assignment_units"
      ) %in% metrics$MetricId),
    "The performance-measure registry is incomplete."
  )
  mfrmr_rasp_assert(
    is.data.frame(decisions) && nrow(decisions) == 9L &&
      !anyDuplicated(decisions$RuleId) &&
      any(decisions$RuleId == "resource_frontier") &&
      any(decisions$RuleId == "operational_rate_authority"),
    "The prospective decision rules are incomplete."
  )
  mfrmr_rasp_assert(
    is.data.frame(precision) && nrow(precision) == 3L &&
      precision$Replications[precision$Profile == "feasibility"] == 10L &&
      is.na(precision$Replications[precision$Profile == "confirmation"]) &&
      precision$WorstCaseBinaryMinReplications[
        precision$Profile == "confirmation"
      ] == 400L &&
      all(!precision$ExecutionAuthorized),
    "The staged replication or execution policy drifted."
  )
  authority <- c(
    registry$SimulationExecuted, registry$SmokeExecutionAuthorized,
    registry$FeasibilityExecutionAuthorized,
    registry$BroadSimulationAuthorized,
    registry$AppropriateAnchorRateSelected,
    registry$ConfirmationAuthorized,
    registry$FACETSExternalFitsIncluded, registry$GPCMIncluded
  )
  mfrmr_rasp_assert(
    all(!as.logical(authority)) && identical(registry$Model, "PCM") &&
      identical(registry$Estimator, "JML"),
    "A design contract cannot execute fits, select a rate, or expand lanes."
  )
  mfrmr_rasp_assert(
    identical(registry$RegistrySHA256, mfrmr_rasp_registry_hash(registry)),
    "The prospective registry SHA-256 does not match its payload."
  )
  invisible(TRUE)
}

mfrmr_rasp_execution_manifest <- function(
    registry = mfrmr_rasp_registry(),
    profile = c("smoke", "feasibility")) {
  profile <- match.arg(profile)
  mfrmr_rasp_validate_registry(registry)
  anchors <- registry$AnchorRegistry
  designs <- registry$DesignRegistry
  repetitions <- if (identical(profile, "smoke")) 1L else 10L
  if (identical(profile, "smoke")) {
    anchors <- anchors[anchors$AnchorConfig %in% c(
      "none", "exact_25_span", "normal_sd25_25_span",
      "shifted_plus25_25_span"
    ), , drop = FALSE]
    designs <- designs[designs$DesignId %in% c(
      "complete", "sparse_link05_range", "sparse_pair_cycle"
    ), , drop = FALSE]
  }
  anchor_order <- match(anchors$AnchorConfig,
                        registry$AnchorRegistry$AnchorConfig)
  anchors$AnchorOrder <- anchor_order
  base <- merge(
    data.frame(Replicate = seq_len(repetitions), stringsAsFactors = FALSE),
    designs,
    by = NULL
  )
  out <- merge(base, anchors, by = NULL)
  out$DataSeed <- 616000L + out$Replicate
  selected <- out$AnchorRate > 0
  out$ExternalSelectionSeed <- NA_integer_
  out$ExternalSelectionSeed[selected] <- 816000L + out$Replicate[selected]
  noisy <- out$ErrorMechanism == "independent_normal"
  out$ExternalAnchorSeed <- NA_integer_
  out$ExternalAnchorSeed[noisy] <-
    916000L + out$Replicate[noisy] * 100L + out$AnchorOrder[noisy]
  out$DatasetId <- sprintf(
    "RASP-R%03d-%s", out$Replicate, toupper(out$DesignId)
  )
  out$AnchorSetId <- sprintf(
    "RASP-R%03d-%s", out$Replicate, toupper(out$AnchorConfig)
  )
  out$RunId <- paste(out$DatasetId, toupper(out$AnchorConfig), sep = "/")
  out$Profile <- profile
  out$NPerson <- 160L
  out$NRater <- 16L
  out$NCriterion <- 4L
  out$NCategory <- 4L
  out$Model <- "PCM"
  out$Estimator <- "JML"
  out$Maxit <- 200L
  out$RegistrySHA256 <- registry$RegistrySHA256
  out$ExecutionAuthorized <- FALSE
  out$AppropriateAnchorRateSelected <- FALSE
  out$ConfirmationAuthorized <- FALSE
  out <- out[order(
    out$Replicate,
    match(out$DesignId, registry$DesignRegistry$DesignId),
    match(out$AnchorConfig, registry$AnchorRegistry$AnchorConfig)
  ), , drop = FALSE]
  out$AnchorOrder <- NULL
  row.names(out) <- NULL
  mfrmr_rasp_validate_manifest(registry, out, profile)
  out
}

mfrmr_rasp_validate_manifest <- function(registry, manifest,
                                         profile = unique(manifest$Profile)) {
  profile <- match.arg(profile, c("smoke", "feasibility"))
  expected_rows <- if (identical(profile, "smoke")) 12L else 560L
  expected_anchors <- if (identical(profile, "smoke")) 4L else 8L
  expected_designs <- if (identical(profile, "smoke")) 3L else 7L
  mfrmr_rasp_assert(
    is.data.frame(manifest) && nrow(manifest) == expected_rows &&
      !anyDuplicated(manifest$RunId) &&
      all(manifest$RegistrySHA256 == registry$RegistrySHA256),
    "Manifest size, identities, or registry binding drifted."
  )
  mfrmr_rasp_assert(
    all(table(manifest$DatasetId) == expected_anchors) &&
      all(table(manifest$AnchorSetId) == expected_designs),
    "Datasets or external anchor sets are not reused across paired arms."
  )
  mfrmr_rasp_assert(
    all(manifest$AnchorCount == as.integer(manifest$NRater *
                                             manifest$AnchorRate)) &&
      all(manifest$ExpectedResponseRows ==
            manifest$NCriterion * manifest$ExpectedRatingAssignments),
    "Manifest anchor counts or rating-resource totals drifted."
  )
  noisy <- manifest$ErrorMechanism == "independent_normal"
  selected <- manifest$AnchorRate > 0
  mfrmr_rasp_assert(
    all(!is.na(manifest$ExternalSelectionSeed[selected])) &&
      all(is.na(manifest$ExternalSelectionSeed[!selected])) &&
      !any(manifest$ExternalSelectionSeed[selected] %in% manifest$DataSeed) &&
      all(vapply(
        split(manifest$ExternalSelectionSeed[selected],
              manifest$Replicate[selected]),
        function(x) length(unique(x)) == 1L,
        logical(1)
      )) &&
    all(!is.na(manifest$ExternalAnchorSeed[noisy])) &&
      all(is.na(manifest$ExternalAnchorSeed[!noisy])) &&
      !any(manifest$ExternalAnchorSeed[noisy] %in% manifest$DataSeed) &&
      all(vapply(
        split(manifest$ExternalAnchorSeed[noisy],
              manifest$AnchorSetId[noisy]),
        function(x) length(unique(x)) == 1L,
        logical(1)
      )),
    "External anchor errors are not independent of data or shared by design."
  )
  mfrmr_rasp_assert(
    all(!manifest$ExecutionAuthorized) &&
      all(!manifest$AppropriateAnchorRateSelected) &&
      all(!manifest$ConfirmationAuthorized),
    "A prospective manifest cannot authorize execution or select a rate."
  )
  invisible(TRUE)
}

mfrmr_rasp_manifest_hash <- function(manifest) {
  mfrmr_rasp_assert(
    exists("mfrmr_rash_hash_table", mode = "function", inherits = TRUE),
    "Source the Rater-anchor canonical-hash helper before this contract."
  )
  mfrmr_rash_hash_table(manifest, domain = "prospective_manifest")
}

mfrmr_rasp_result_schema <- function() {
  data.frame(
    RunId = character(), DatasetId = character(), AnchorSetId = character(),
    DesignId = character(), AnchorConfig = character(), Replicate = integer(),
    RegistrySHA256 = character(), Executed = logical(),
    SupportAuditPassed = logical(), FitReturned = logical(),
    InferenceReady = logical(), StructuralFailure = logical(),
    FailureStage = character(), FailureCode = character(),
    FreeRaterAbsoluteRMSE = numeric(), FreeRaterCenteredRMSE = numeric(),
    FreeRaterBias = numeric(), RaterRankSpearman = numeric(),
    PersonAbsoluteRMSE = numeric(), PersonBias = numeric(),
    PersonRankSpearman = numeric(), CriterionCenteredRMSE = numeric(),
    stringsAsFactors = FALSE
  )
}

mfrmr_rasp_empty_results <- function(manifest) {
  out <- manifest[c(
    "RunId", "DatasetId", "AnchorSetId", "DesignId", "AnchorConfig",
    "Replicate", "RegistrySHA256"
  )]
  out$Executed <- FALSE
  out$SupportAuditPassed <- FALSE
  out$FitReturned <- FALSE
  out$InferenceReady <- FALSE
  out$StructuralFailure <- FALSE
  out$FailureStage <- "unrecorded"
  out$FailureCode <- "unrecorded"
  numeric_columns <- c(
    "FreeRaterAbsoluteRMSE", "FreeRaterCenteredRMSE", "FreeRaterBias",
    "RaterRankSpearman", "PersonAbsoluteRMSE", "PersonBias",
    "PersonRankSpearman", "CriterionCenteredRMSE"
  )
  out[numeric_columns] <- NA_real_
  out
}

mfrmr_rasp_denominator_summary <- function(registry, manifest, results) {
  mfrmr_rasp_validate_registry(registry)
  mfrmr_rasp_assert(!anyDuplicated(results$RunId),
                    "Result identities are duplicated.")
  mfrmr_rasp_assert(all(results$RunId %in% manifest$RunId),
                    "Results contain identities outside the manifest.")
  mfrmr_rasp_assert(all(results$RegistrySHA256 == registry$RegistrySHA256),
                    "Results do not carry the frozen registry identity.")
  matched <- match(manifest$RunId, results$RunId)
  recorded <- !is.na(matched)
  observed <- results[stats::na.omit(matched), , drop = FALSE]
  valid_failure <- observed$FailureStage != "unrecorded" &
    observed$FailureCode != "unrecorded"
  data.frame(
    PlannedRuns = nrow(manifest),
    RecordedRuns = sum(recorded),
    UnrecordedRuns = sum(!recorded),
    ExecutedRuns = sum(observed$Executed),
    FitReturnedRuns = sum(observed$FitReturned),
    InferenceReadyRuns = sum(observed$InferenceReady),
    StructuralFailureRuns = sum(observed$StructuralFailure),
    ClassifiedFailureRuns = sum(valid_failure),
    ExactAccountingPassed = all(recorded) &&
      all(observed$Executed | valid_failure),
    AppropriateAnchorRateSelected = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_rasp_preflight <- function(profile = c("smoke", "feasibility")) {
  profile <- match.arg(profile)
  registry <- mfrmr_rasp_registry()
  manifest <- mfrmr_rasp_execution_manifest(registry, profile)
  list(
    Specification = registry$Specification,
    Contract = registry$Contract,
    Profile = profile,
    RegistrySHA256 = registry$RegistrySHA256,
    ManifestSHA256 = mfrmr_rasp_manifest_hash(manifest),
    PlannedRuns = nrow(manifest),
    PlannedUniqueDatasets = length(unique(manifest$DatasetId)),
    PlannedSelectionCalibrations = length(unique(stats::na.omit(
      manifest$ExternalSelectionSeed
    ))),
    PlannedExternalAnchorSets = length(unique(manifest$AnchorSetId)),
    Status = "prospective_manifest_structurally_ready",
    ExecutionAuthorized = FALSE,
    AppropriateAnchorRateSelected = FALSE,
    ConfirmationAuthorized = FALSE
  )
}
