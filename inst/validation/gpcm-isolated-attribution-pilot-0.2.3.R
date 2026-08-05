# Repository-only isolated-attribution pilot for bounded GPCM in mfrmr 0.2.3.
#
# The pairwise covering grid finds mixed stress failures.  This companion
# runner changes one data-generating/design axis at a time around a fixed
# reference cell and sends each retained dataset through four analysis routes:
# GPCM-JML, GPCM-MML, PCM-JML, and PCM-MML.  It is calibration instrumentation,
# not confirmation, causal identification, or external-software evidence.

mfrmr_gpcm_attribution_or <- function(x, y) {
  if (is.null(x) || length(x) == 0L) y else x
}

mfrmr_gpcm_attribution_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "gpcm-isolated-attribution-pilot-0\\.2\\.3\\.R$",
    files
  )]
  if (length(hit) == 0L) NA_character_ else {
    dirname(normalizePath(hit[length(hit)], winslash = "/", mustWork = FALSE))
  }
})

mfrmr_gpcm_attribution_require_covering <- function() {
  target_env <- environment(mfrmr_gpcm_attribution_require_covering)
  required <- c(
    "mfrmr_gpcm_stress_build", "mfrmr_gpcm_stress_transform",
    "mfrmr_gpcm_stress_support", "mfrmr_gpcm_stress_capture",
    "mfrmr_gpcm_stress_fun"
  )
  if (all(vapply(required, exists, logical(1), envir = target_env,
                 mode = "function", inherits = TRUE))) {
    return(invisible(TRUE))
  }
  candidates <- c(
    if (!is.na(mfrmr_gpcm_attribution_source_dir)) {
      file.path(
        mfrmr_gpcm_attribution_source_dir,
        "gpcm-stress-covering-grid-0.2.3.R"
      )
    } else character(0),
    file.path("inst", "validation", "gpcm-stress-covering-grid-0.2.3.R"),
    "gpcm-stress-covering-grid-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) {
    stop("Cannot locate gpcm-stress-covering-grid-0.2.3.R.", call. = FALSE)
  }
  sys.source(path, envir = target_env)
  if (!all(vapply(required, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    stop("The GPCM covering-grid helpers did not load completely.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gpcm_attribution_axes <- function() {
  c(
    "SlopeLevels", "SlopeSpread", "Categories", "CategoryPrevalence",
    "RaterPanel", "Assignment", "Missingness", "CellStructure",
    "Interaction", "Diagnostic", "SampleSize"
  )
}

mfrmr_gpcm_attribution_reference <- function() {
  data.frame(
    SlopeLevels = "four",
    SlopeSpread = "mild",
    Categories = "K5",
    CategoryPrevalence = "balanced",
    RaterPanel = "R6",
    Assignment = "complete",
    Missingness = "none",
    CellStructure = "unique",
    Interaction = "none",
    Diagnostic = "null",
    SampleSize = "standard",
    stringsAsFactors = FALSE
  )
}

mfrmr_gpcm_attribution_arms <- function() {
  axes <- mfrmr_gpcm_attribution_axes()
  reference <- mfrmr_gpcm_attribution_reference()
  changes <- data.frame(
    ArmId = c(
      "reference",
      "slope_levels_one", "slope_levels_two", "slope_levels_twelve",
      "slope_unit", "slope_strong", "slope_near_zero_high",
      "categories_k2", "categories_k3", "categories_k7",
      "category_rare_interior", "category_dominant_middle",
      "category_floor", "category_ceiling", "category_internal_zero",
      "category_boundary_zero",
      "raters_2", "raters_3", "raters_12",
      "assignment_sparse_connected", "assignment_weak_bridge",
      "assignment_zero_shared", "assignment_routed",
      "assignment_disconnected",
      "missing_mcar", "missing_person", "missing_rater",
      "missing_outcome",
      "cells_repeated", "cells_occasion", "cells_unequal_weights",
      "cells_zero_weights",
      "interaction_person_rater", "interaction_slope_correlated",
      "interaction_slope_orthogonal",
      "diagnostic_local_dependence", "diagnostic_bias",
      "diagnostic_rater_drift",
      "sample_small", "sample_target_sparse"
    ),
    ChangedAxis = c(
      NA,
      rep("SlopeLevels", 3L), rep("SlopeSpread", 3L),
      rep("Categories", 3L), rep("CategoryPrevalence", 6L),
      rep("RaterPanel", 3L), rep("Assignment", 5L),
      rep("Missingness", 4L), rep("CellStructure", 4L),
      rep("Interaction", 3L), rep("Diagnostic", 3L),
      rep("SampleSize", 2L)
    ),
    ChangedLevel = c(
      NA,
      "one", "two", "twelve", "unit", "strong", "near_zero_high",
      "K2", "K3", "K7", "rare_interior", "dominant_middle",
      "floor", "ceiling", "internal_zero", "boundary_zero",
      "R2", "R3", "R12", "sparse_connected", "weak_bridge",
      "zero_shared", "routed", "disconnected", "mcar", "person",
      "rater", "outcome", "repeated", "occasion", "unequal_weights",
      "zero_weights", "person_rater", "slope_correlated",
      "slope_orthogonal", "local_dependence", "bias", "rater_drift",
      "small", "target_sparse"
    ),
    AttributionClass = c(
      "reference",
      "known_generator_gap", "dimension_change", "dimension_change",
      rep("coordinate_preserving", 3L),
      rep("dimension_change", 3L),
      rep("support_perturbation", 6L),
      rep("partial_coordinate_change", 3L),
      "support_perturbation", "weak_identification", "negative_control",
      "targeting_confound", "negative_control",
      rep("observation_selection", 4L),
      "within_cell_dependence", "explicit_occasion",
      "estimand_change", "support_perturbation",
      rep("unmodelled_interaction", 3L),
      rep("diagnostic_signal", 3L),
      rep("sample_size_change", 2L)
    ),
    stringsAsFactors = FALSE
  )
  values <- reference[rep(1L, nrow(changes)), axes, drop = FALSE]
  for (i in seq_len(nrow(changes))) {
    axis <- changes$ChangedAxis[i]
    if (!is.na(axis)) values[[axis]][i] <- changes$ChangedLevel[i]
  }
  out <- cbind(changes, values)
  out$ExpectedFitState <- "review_recovery"
  out$ExpectedFitState[out$ArmId %in% c(
    "slope_levels_one", "category_internal_zero", "assignment_zero_shared",
    "assignment_disconnected"
  )] <- "must_not_be_false_ready"
  out$Executable <- out$ArmId != "slope_levels_one"
  out$ExecutionReason <- ifelse(
    out$Executable,
    "supported_current_single_scale_generator",
    paste0(
      "known_gap_current_simulator_requires_two_slope_levels_and_",
      "gpcm_step_facet_equals_slope_facet"
    )
  )
  out$ChangedAxisCount <- vapply(seq_len(nrow(out)), function(i) {
    sum(vapply(axes, function(axis) {
      !identical(as.character(out[[axis]][i]),
                 as.character(reference[[axis]][1L]))
    }, logical(1)))
  }, integer(1))
  out
}

mfrmr_gpcm_attribution_routes <- function() {
  data.frame(
    Route = c("GPCM_JML", "GPCM_MML", "PCM_JML", "PCM_MML"),
    FitModel = c("GPCM", "GPCM", "PCM", "PCM"),
    FitMethod = c("JML", "MML", "JML", "MML"),
    PersonEstimand = c(
      "joint_fixed_person", "marginal_eap_person",
      "joint_fixed_person_lower_model", "marginal_eap_person_lower_model"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gpcm_attribution_manifest <- function(
    profile = c("smoke", "pilot"), reps = NULL) {
  profile <- match.arg(profile)
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Package `digest` is required for attribution manifests.",
         call. = FALSE)
  }
  arms <- mfrmr_gpcm_attribution_arms()
  routes <- mfrmr_gpcm_attribution_routes()
  reps <- as.integer(mfrmr_gpcm_attribution_or(
    reps, if (identical(profile, "smoke")) 1L else 5L
  ))
  if (length(reps) != 1L || is.na(reps) || reps < 1L) {
    stop("`reps` must be one positive integer.", call. = FALSE)
  }
  arm_rep <- merge(
    arms,
    data.frame(Replicate = seq_len(reps), stringsAsFactors = FALSE),
    all = TRUE
  )
  out <- merge(arm_rep, routes, all = TRUE)
  out <- out[order(out$Replicate, match(out$ArmId, arms$ArmId),
                   match(out$Route, routes$Route)), , drop = FALSE]
  row.names(out) <- NULL
  out$Profile <- profile
  out$Phase <- profile
  seed_start <- if (identical(profile, "smoke")) 340000L else 440000L
  out$Seed <- seed_start + out$Replicate
  out$ReservedConfirmationSeedStart <- 940000L
  out$ConfirmationAuthorized <- FALSE
  out$ConfirmationEvidence <- FALSE
  out$DataCellId <- sprintf(
    "ATTR-%s-R%03d", toupper(out$ArmId), out$Replicate
  )
  out$BaselineDataCellId <- sprintf(
    "ATTR-REFERENCE-R%03d", out$Replicate
  )
  out$ScenarioId <- paste(out$DataCellId, out$Route, sep = "-")
  out$NSlopeLevels <- c(one = 1L, two = 2L, four = 4L, twelve = 12L)[
    out$SlopeLevels
  ]
  out$NCategories <- c(K2 = 2L, K3 = 3L, K5 = 5L, K7 = 7L)[
    out$Categories
  ]
  out$NRaters <- c(R2 = 2L, R3 = 3L, R6 = 6L, R12 = 12L)[
    out$RaterPanel
  ]
  out$PlannedNPersons <- c(
    small = 24L, standard = 120L, target_sparse = 600L
  )[out$SampleSize]
  out$NPersons <- if (identical(profile, "smoke")) {
    pmin(out$PlannedNPersons, 24L)
  } else {
    out$PlannedNPersons
  }
  out$SmokeScaleOverride <- out$NPersons != out$PlannedNPersons
  out$TruthRecoveryEligible <- out$FitModel == "GPCM"
  out$LowerModelTruthEligible <- out$FitModel == "PCM" &
    out$SlopeSpread == "unit"
  out$AnalysisRole <- ifelse(
    out$FitModel == "GPCM", "generating_model_route",
    ifelse(out$LowerModelTruthEligible,
           "exact_equal_slope_reduction", "misspecified_lower_model_reference")
  )
  out$NumericExternalEligible <- FALSE
  out$ExternalIneligibilityReason <- paste0(
    "isolated_internal_attribution_only_external_normalizer_not_matched"
  )
  out$ThresholdStatus <- "pilot_required_not_frozen"
  out$ReleaseUse <- "calibration_only"
  out$PersonCoordinateCommon <- out$ChangedAxis != "SampleSize" |
    is.na(out$ChangedAxis)
  out$RaterCoordinateCommon <- out$ChangedAxis != "RaterPanel" |
    is.na(out$ChangedAxis)
  out$CriterionCoordinateCommon <- out$ChangedAxis != "SlopeLevels" |
    is.na(out$ChangedAxis)
  out$StepCoordinateCommon <- !(out$ChangedAxis %in% c(
    "SlopeLevels", "Categories"
  )) | is.na(out$ChangedAxis)
  out$SlopeCoordinateCommon <- out$ChangedAxis != "SlopeLevels" |
    is.na(out$ChangedAxis)
  manifest_for_hash <- out
  manifest_for_hash$ManifestHash <- NULL
  hash <- digest::digest(
    manifest_for_hash, algo = "sha256", serialize = TRUE
  )
  out$ManifestHash <- hash
  out
}

mfrmr_gpcm_attribution_manifest_audit <- function(manifest) {
  axes <- mfrmr_gpcm_attribution_axes()
  arms <- unique(manifest[c("ArmId", "ChangedAxis", "ChangedLevel",
                            "ChangedAxisCount")])
  route_counts <- table(manifest$DataCellId)
  seed_counts <- vapply(split(manifest$Seed, manifest$DataCellId),
                        function(x) length(unique(x)), integer(1))
  route_sets <- vapply(split(manifest$Route, manifest$DataCellId), function(x) {
    identical(sort(unique(x)), sort(mfrmr_gpcm_attribution_routes()$Route))
  }, logical(1))
  reference <- mfrmr_gpcm_attribution_reference()
  axis_errors <- vapply(seq_len(nrow(arms)), function(i) {
    arm <- manifest[manifest$ArmId == arms$ArmId[i], , drop = FALSE][1L, ]
    observed <- sum(vapply(axes, function(axis) {
      !identical(as.character(arm[[axis]]),
                 as.character(reference[[axis]][1L]))
    }, logical(1)))
    expected <- if (identical(arm$ArmId, "reference")) 0L else 1L
    observed != expected || observed != arm$ChangedAxisCount
  }, logical(1))
  data.frame(
    Arms = nrow(arms),
    Rows = nrow(manifest),
    Replicates = length(unique(manifest$Replicate)),
    FourRoutesPerDataCell = all(route_counts == 4L),
    CompleteRouteSetPerDataCell = all(route_sets),
    OneSeedPerDataCell = all(seed_counts == 1L),
    OneAxisChangePerChallenge = !any(axis_errors),
    KnownOneLevelGap = all(!manifest$Executable[
      manifest$ArmId == "slope_levels_one"
    ]),
    ConfirmationSeparated = max(manifest$Seed) <
      min(manifest$ReservedConfirmationSeedStart),
    ConfirmationAuthorized = any(manifest$ConfirmationAuthorized),
    NumericExternalEligibleRows = sum(manifest$NumericExternalEligible),
    FrozenThresholdRows = sum(manifest$ThresholdStatus == "frozen_numeric"),
    stringsAsFactors = FALSE
  )
}

mfrmr_gpcm_attribution_safe_cor <- function(x, y) {
  if (length(x) < 3L || stats::sd(x) == 0 || stats::sd(y) == 0) {
    return(NA_real_)
  }
  suppressWarnings(stats::cor(x, y))
}

mfrmr_gpcm_attribution_metrics <- function(estimate, truth, center = TRUE) {
  ok <- is.finite(estimate) & is.finite(truth)
  estimate <- as.numeric(estimate[ok])
  truth <- as.numeric(truth[ok])
  if (length(estimate) == 0L) {
    return(c(N = 0, RMSE = NA, MAE = NA, Correlation = NA, MaxAbs = NA))
  }
  if (isTRUE(center)) {
    estimate <- estimate - mean(estimate)
    truth <- truth - mean(truth)
  }
  error <- estimate - truth
  c(
    N = length(error),
    RMSE = sqrt(mean(error^2)),
    MAE = mean(abs(error)),
    Correlation = mfrmr_gpcm_attribution_safe_cor(estimate, truth),
    MaxAbs = max(abs(error))
  )
}

mfrmr_gpcm_attribution_named_metrics <- function(fit_values, truth_values) {
  common <- intersect(names(fit_values), names(truth_values))
  mfrmr_gpcm_attribution_metrics(
    fit_values[common], truth_values[common], center = TRUE
  )
}

mfrmr_gpcm_attribution_recovery <- function(fit, truth) {
  empty <- c(N = 0, RMSE = NA, MAE = NA, Correlation = NA, MaxAbs = NA)
  person <- empty
  person_extreme <- NA_integer_
  person_table <- as.data.frame(
    mfrmr_gpcm_attribution_or(fit$facets$person, data.frame()),
    stringsAsFactors = FALSE
  )
  if (nrow(person_table) > 0L && "Person" %in% names(person_table)) {
    value_col <- if ("PrimaryEstimate" %in% names(person_table)) {
      "PrimaryEstimate"
    } else {
      "Estimate"
    }
    fit_person <- stats::setNames(person_table[[value_col]], person_table$Person)
    person <- mfrmr_gpcm_attribution_named_metrics(fit_person, truth$person)
    if ("ResponseExtreme" %in% names(person_table)) {
      person_extreme <- sum(person_table$ResponseExtreme != "none", na.rm = TRUE)
    }
  }
  others <- as.data.frame(
    mfrmr_gpcm_attribution_or(fit$facets$others, data.frame()),
    stringsAsFactors = FALSE
  )
  facet_metric <- function(name) {
    if (nrow(others) == 0L || !all(c("Facet", "Level", "Estimate") %in%
                                   names(others)) ||
        is.null(truth$facets[[name]])) return(empty)
    rows <- others$Facet == name
    fit_values <- stats::setNames(others$Estimate[rows], others$Level[rows])
    mfrmr_gpcm_attribution_named_metrics(fit_values, truth$facets[[name]])
  }
  rater <- facet_metric("Rater")
  criterion <- facet_metric("Criterion")

  step <- empty
  step_contrasts <- 0L
  fit_step <- as.data.frame(
    mfrmr_gpcm_attribution_or(fit$steps, data.frame()),
    stringsAsFactors = FALSE
  )
  truth_step <- as.data.frame(
    mfrmr_gpcm_attribution_or(truth$step_table, data.frame()),
    stringsAsFactors = FALSE
  )
  if (nrow(fit_step) > 0L && nrow(truth_step) > 0L &&
      all(c("StepFacet", "Step", "Estimate") %in% names(fit_step)) &&
      all(c("StepFacet", "StepIndex", "Estimate") %in% names(truth_step))) {
    truth_step$Step <- if ("Step" %in% names(truth_step)) {
      as.character(truth_step$Step)
    } else {
      paste0("Step_", truth_step$StepIndex)
    }
    fit_step$Step <- as.character(fit_step$Step)
    joined <- merge(
      fit_step[, c("StepFacet", "Step", "Estimate")],
      truth_step[, c("StepFacet", "Step", "Estimate")],
      by = c("StepFacet", "Step"),
      suffixes = c(".Fit", ".Truth")
    )
    groups <- split(seq_len(nrow(joined)), joined$StepFacet)
    keep <- unlist(lapply(groups, function(index) {
      if (length(index) < 2L) integer(0) else index
    }), use.names = FALSE)
    step_contrasts <- sum(pmax(0L, lengths(groups) - 1L))
    if (length(keep) > 0L) {
      estimate <- joined$Estimate.Fit
      truth_value <- joined$Estimate.Truth
      for (index in groups) {
        estimate[index] <- estimate[index] - mean(estimate[index])
        truth_value[index] <- truth_value[index] - mean(truth_value[index])
      }
      step <- mfrmr_gpcm_attribution_metrics(
        estimate[keep], truth_value[keep], center = FALSE
      )
    }
  }

  slope <- empty
  slope_primary_eligible <- FALSE
  fit_slope <- as.data.frame(
    mfrmr_gpcm_attribution_or(fit$slopes, data.frame()),
    stringsAsFactors = FALSE
  )
  truth_slope <- as.data.frame(
    mfrmr_gpcm_attribution_or(truth$slope_table, data.frame()),
    stringsAsFactors = FALSE
  )
  if (nrow(fit_slope) > 0L && nrow(truth_slope) > 0L &&
      all(c("SlopeFacet", "OptimizerEstimate") %in% names(fit_slope)) &&
      all(c("SlopeFacet", "Estimate") %in% names(truth_slope))) {
    joined <- merge(
      fit_slope[, c("SlopeFacet", "OptimizerEstimate")],
      truth_slope[, c("SlopeFacet", "Estimate")],
      by = "SlopeFacet", suffixes = c(".Fit", ".Truth")
    )
    ok <- joined$OptimizerEstimate > 0 & joined$Estimate > 0
    slope <- mfrmr_gpcm_attribution_metrics(
      log(joined$OptimizerEstimate[ok]), log(joined$Estimate[ok]),
      center = TRUE
    )
    if ("ComparisonEligibility" %in% names(fit_slope)) {
      slope_primary_eligible <- nrow(fit_slope) > 0L &&
        all(fit_slope$ComparisonEligibility == "eligible")
    }
  }
  list(
    Person = person, PersonExtremeN = person_extreme,
    Rater = rater, Criterion = criterion,
    Step = step, StepContrastN = step_contrasts,
    SlopeOptimizer = slope,
    SlopePrimaryMetricEligible = slope_primary_eligible
  )
}

mfrmr_gpcm_attribution_empty_result <- function(row, run_state,
                                                  error = NA_character_) {
  data.frame(
    ScenarioId = as.character(row$ScenarioId),
    DataCellId = as.character(row$DataCellId),
    BaselineDataCellId = as.character(row$BaselineDataCellId),
    ArmId = as.character(row$ArmId),
    ChangedAxis = as.character(row$ChangedAxis),
    ChangedLevel = as.character(row$ChangedLevel),
    AttributionClass = as.character(row$AttributionClass),
    Profile = as.character(row$Profile),
    Replicate = as.integer(row$Replicate),
    Seed = as.integer(row$Seed),
    Route = as.character(row$Route),
    FitModel = as.character(row$FitModel),
    FitMethod = as.character(row$FitMethod),
    PersonEstimand = as.character(row$PersonEstimand),
    AnalysisRole = as.character(row$AnalysisRole),
    Executed = FALSE,
    GenerationSucceeded = FALSE,
    FitSucceeded = FALSE,
    RunState = run_state,
    Error = error,
    Warnings = NA_character_,
    RuntimeSeconds = NA_real_,
    Rows = NA_integer_, PositiveWeightRows = NA_integer_,
    Persons = NA_integer_, Raters = NA_integer_, Criteria = NA_integer_,
    ObservedCategories = NA_integer_, ZeroCategories = NA_integer_,
    MinCategoryCount = NA_integer_, MaxCategoryFraction = NA_real_,
    NormalizedCategoryEntropy = NA_real_, MinCommonPersons = NA_integer_,
    ZeroCommonRaterPairs = NA_integer_, ExactCellDuplicates = NA_integer_,
    DistinguishedCellDuplicates = NA_integer_,
    RetainedDataHash = NA_character_,
    FitReadiness = NA_character_, InferenceReady = FALSE,
    ReadinessReasons = NA_character_, BoundaryState = NA_character_,
    LogLik = NA_real_, Deviance = NA_real_,
    PersonN = 0L, PersonRMSE = NA_real_, PersonMAE = NA_real_,
    PersonCorrelation = NA_real_, PersonMaxAbs = NA_real_,
    PersonExtremeN = NA_integer_,
    RaterN = 0L, RaterRMSE = NA_real_, RaterMAE = NA_real_,
    RaterCorrelation = NA_real_, RaterMaxAbs = NA_real_,
    CriterionN = 0L, CriterionRMSE = NA_real_, CriterionMAE = NA_real_,
    CriterionCorrelation = NA_real_, CriterionMaxAbs = NA_real_,
    StepN = 0L, StepRMSE = NA_real_, StepMAE = NA_real_,
    StepCorrelation = NA_real_, StepMaxAbs = NA_real_,
    StepContrastN = 0L,
    SlopeOptimizerN = 0L, SlopeOptimizerLogRMSE = NA_real_,
    SlopeOptimizerLogMAE = NA_real_, SlopeOptimizerLogCorrelation = NA_real_,
    SlopeOptimizerLogMaxAbs = NA_real_,
    SlopePrimaryMetricEligible = FALSE,
    PCAState = "not_run", PCAFirstEigenvalue = NA_real_,
    FalseReady = FALSE,
    PairedDataIdentity = NA, PairIdentityViolation = NA,
    NumericExternalEligible = FALSE,
    ThresholdStatus = as.character(row$ThresholdStatus),
    ReleaseUse = as.character(row$ReleaseUse),
    ManifestHash = as.character(row$ManifestHash),
    stringsAsFactors = FALSE
  )
}

mfrmr_gpcm_attribution_run_one <- function(
    row, run_pca = FALSE, maxit = NULL, quad_points = 7L) {
  mfrmr_gpcm_attribution_require_covering()
  if (!isTRUE(as.logical(row$Executable))) {
    return(mfrmr_gpcm_attribution_empty_result(
      row, "not_executed_known_gap", as.character(row$ExecutionReason)
    ))
  }
  generated <- mfrmr_gpcm_stress_capture(mfrmr_gpcm_stress_build(row))
  if (inherits(generated$value, "error")) {
    return(mfrmr_gpcm_attribution_empty_result(
      row, "generation_failed", conditionMessage(generated$value)
    ))
  }
  transformed <- mfrmr_gpcm_stress_capture(
    mfrmr_gpcm_stress_transform(generated$value, row)
  )
  if (inherits(transformed$value, "error")) {
    return(mfrmr_gpcm_attribution_empty_result(
      row, "transformation_failed", conditionMessage(transformed$value)
    ))
  }
  retained <- transformed$value
  data <- retained$data
  support <- mfrmr_gpcm_stress_support(data, as.integer(row$NCategories))
  facets <- c("Rater", "Criterion", intersect("Occasion", names(data)))
  fit_args <- list(
    data = data, person = "Person", facets = facets, score = "Score",
    model = as.character(row$FitModel), method = as.character(row$FitMethod),
    step_facet = "Criterion", rating_min = 1L,
    rating_max = as.integer(row$NCategories),
    maxit = as.integer(mfrmr_gpcm_attribution_or(
      maxit, if (identical(row$Profile, "smoke")) 60L else 180L
    ))
  )
  if (identical(row$FitModel, "GPCM")) fit_args$slope_facet <- "Criterion"
  if ("Weight" %in% names(data)) fit_args$weight <- "Weight"
  if (identical(row$FitMethod, "MML")) {
    fit_args$quad_points <- as.integer(quad_points)
  }
  start <- proc.time()[["elapsed"]]
  fitted <- mfrmr_gpcm_stress_capture(
    do.call(mfrmr_gpcm_stress_fun("fit_mfrm"), fit_args)
  )
  elapsed <- proc.time()[["elapsed"]] - start
  warnings <- unique(c(generated$warnings, transformed$warnings,
                       fitted$warnings))
  if (inherits(fitted$value, "error")) {
    state <- if (identical(row$ExpectedFitState,
                           "must_not_be_false_ready")) {
      "expected_fail_closed"
    } else {
      "fit_failed"
    }
    out <- mfrmr_gpcm_attribution_empty_result(
      row, state, conditionMessage(fitted$value)
    )
    out$Executed <- TRUE
    out$GenerationSucceeded <- TRUE
    out$RuntimeSeconds <- elapsed
    out$Warnings <- paste(warnings, collapse = " | ")
    out[names(support)] <- support
    return(out)
  }
  fit <- fitted$value
  summary <- as.data.frame(
    mfrmr_gpcm_attribution_or(fit$summary, data.frame()),
    stringsAsFactors = FALSE
  )
  scalar <- function(name, default = NA) {
    if (nrow(summary) == 1L && name %in% names(summary)) summary[[name]][1L]
    else default
  }
  recovery <- mfrmr_gpcm_attribution_recovery(fit, retained$truth)
  out <- mfrmr_gpcm_attribution_empty_result(row, "fitted")
  out$Executed <- TRUE
  out$GenerationSucceeded <- TRUE
  out$FitSucceeded <- TRUE
  out$RuntimeSeconds <- elapsed
  out$Warnings <- paste(warnings, collapse = " | ")
  out[names(support)] <- support
  out$FitReadiness <- as.character(scalar("FitReadiness", "legacy_unknown"))
  out$InferenceReady <- isTRUE(scalar("InferenceReady", FALSE))
  out$ReadinessReasons <- as.character(scalar(
    "ReadinessReasonCodes", scalar("BoundaryReasonCodes", "")
  ))
  out$BoundaryState <- as.character(scalar("BoundaryState", NA_character_))
  out$LogLik <- as.numeric(scalar("LogLik", NA_real_))
  out$Deviance <- as.numeric(scalar("Deviance", NA_real_))
  assign_metric <- function(prefix, metric) {
    out[[paste0(prefix, "N")]] <<- as.integer(metric[["N"]])
    out[[paste0(prefix, "RMSE")]] <<- as.numeric(metric[["RMSE"]])
    out[[paste0(prefix, "MAE")]] <<- as.numeric(metric[["MAE"]])
    out[[paste0(prefix, "Correlation")]] <<-
      as.numeric(metric[["Correlation"]])
    out[[paste0(prefix, "MaxAbs")]] <<- as.numeric(metric[["MaxAbs"]])
  }
  assign_metric("Person", recovery$Person)
  assign_metric("Rater", recovery$Rater)
  assign_metric("Criterion", recovery$Criterion)
  assign_metric("Step", recovery$Step)
  out$PersonExtremeN <- recovery$PersonExtremeN
  out$StepContrastN <- recovery$StepContrastN
  out$SlopeOptimizerN <- as.integer(recovery$SlopeOptimizer[["N"]])
  out$SlopeOptimizerLogRMSE <- recovery$SlopeOptimizer[["RMSE"]]
  out$SlopeOptimizerLogMAE <- recovery$SlopeOptimizer[["MAE"]]
  out$SlopeOptimizerLogCorrelation <-
    recovery$SlopeOptimizer[["Correlation"]]
  out$SlopeOptimizerLogMaxAbs <- recovery$SlopeOptimizer[["MaxAbs"]]
  out$SlopePrimaryMetricEligible <- recovery$SlopePrimaryMetricEligible
  out$FalseReady <- identical(row$ExpectedFitState,
                               "must_not_be_false_ready") &&
    (isTRUE(out$InferenceReady) || identical(out$FitReadiness, "ready"))
  if (isTRUE(run_pca)) {
    pca <- mfrmr_gpcm_stress_capture(
      mfrmr_gpcm_stress_fun("analyze_residual_pca")(
        fit, mode = "overall", parallel = FALSE
      )
    )
    warnings <- unique(c(warnings, pca$warnings))
    if (inherits(pca$value, "error")) {
      out$PCAState <- "failed"
    } else {
      out$PCAState <- "available_exploratory"
      table <- as.data.frame(mfrmr_gpcm_attribution_or(
        pca$value$overall_table, data.frame()
      ))
      if (nrow(table) > 0L && "Eigenvalue" %in% names(table)) {
        out$PCAFirstEigenvalue <- as.numeric(table$Eigenvalue[1L])
      }
    }
    out$Warnings <- paste(warnings, collapse = " | ")
  }
  out
}

mfrmr_gpcm_attribution_bind <- function(rows) {
  if (length(rows) == 0L) return(data.frame())
  all_names <- unique(unlist(lapply(rows, names), use.names = FALSE))
  rows <- lapply(rows, function(x) {
    missing <- setdiff(all_names, names(x))
    for (name in missing) x[[name]] <- NA
    x[, all_names, drop = FALSE]
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_gpcm_attribution_pair_audit <- function(results) {
  groups <- split(seq_len(nrow(results)), results$DataCellId)
  for (index in groups) {
    successful <- index[results$GenerationSucceeded[index] &
                          !is.na(results$RetainedDataHash[index])]
    complete <- length(successful) == 4L &&
      length(unique(results$Route[successful])) == 4L
    same_hash <- length(successful) > 0L &&
      length(unique(results$RetainedDataHash[successful])) == 1L
    valid <- complete && same_hash
    violation <- length(successful) > 1L && !same_hash
    results$PairedDataIdentity[index] <- valid
    results$PairIdentityViolation[index] <- violation
  }
  results
}

mfrmr_gpcm_attribution_contrasts <- function(results, manifest) {
  challenge <- results[results$ArmId != "reference", , drop = FALSE]
  reference <- results[results$ArmId == "reference", , drop = FALSE]
  by <- c("Profile", "Replicate", "Seed", "Route", "FitModel", "FitMethod")
  keep_metric <- c(
    "ScenarioId", "DataCellId", "ArmId", "ChangedAxis", "ChangedLevel",
    "AttributionClass", "Executed", "GenerationSucceeded", "FitSucceeded",
    "RunState", "FitReadiness", "InferenceReady", "RuntimeSeconds", "Rows",
    "Persons", "Raters", "Criteria", "ObservedCategories", "ZeroCategories",
    "MinCommonPersons", "RetainedDataHash", "PersonRMSE", "RaterRMSE",
    "CriterionRMSE", "StepRMSE", "SlopeOptimizerLogRMSE",
    "SlopePrimaryMetricEligible", "FalseReady", "PairedDataIdentity"
  )
  challenge <- challenge[, unique(c(by, keep_metric)), drop = FALSE]
  reference <- reference[, unique(c(by, keep_metric)), drop = FALSE]
  out <- merge(challenge, reference, by = by, suffixes = c(".Arm", ".Reference"))
  metric_names <- c(
    "RuntimeSeconds", "Rows", "Persons", "Raters", "Criteria",
    "ObservedCategories", "ZeroCategories", "MinCommonPersons",
    "PersonRMSE", "RaterRMSE", "CriterionRMSE", "StepRMSE",
    "SlopeOptimizerLogRMSE"
  )
  for (name in metric_names) {
    out[[paste0(name, "Delta")]] <-
      out[[paste0(name, ".Arm")]] - out[[paste0(name, ".Reference")]]
  }
  out$RuntimeRatio <- out$RuntimeSeconds.Arm / out$RuntimeSeconds.Reference
  arm_coordinates <- unique(manifest[c(
    "ArmId", "PersonCoordinateCommon", "RaterCoordinateCommon",
    "CriterionCoordinateCommon", "StepCoordinateCommon",
    "SlopeCoordinateCommon"
  )])
  out <- merge(out, arm_coordinates, by.x = "ArmId.Arm", by.y = "ArmId",
               all.x = TRUE)
  out$ExecutionPairComplete <- out$Executed.Arm & out$Executed.Reference
  out$FitPairComplete <- out$FitSucceeded.Arm & out$FitSucceeded.Reference
  out$SeedPaired <- TRUE
  out$DescriptiveAttributionEligible <- out$ExecutionPairComplete &
    out$PairedDataIdentity.Arm & out$PairedDataIdentity.Reference &
    !out$FalseReady.Arm & !out$FalseReady.Reference
  out$RecoveryClaimEligible <- FALSE
  out$Interpretation <- paste0(
    "one_manifest_axis_perturbation_with_common_seed;_",
    "not_a_causal_or_external_equivalence_claim"
  )
  out
}

mfrmr_run_gpcm_isolated_attribution_pilot <- function(
    profile = c("smoke", "pilot"), arms = NULL, routes = NULL, reps = NULL,
    run_pca = FALSE, maxit = NULL, quad_points = 7L, dry_run = FALSE,
    progress = interactive(), output_dir = NULL,
    authorize_full_pilot = FALSE) {
  profile <- match.arg(profile)
  mfrmr_gpcm_attribution_require_covering()
  manifest <- mfrmr_gpcm_attribution_manifest(profile, reps = reps)
  audit <- mfrmr_gpcm_attribution_manifest_audit(manifest)
  if (!is.null(arms)) manifest <- manifest[manifest$ArmId %in% arms, , drop = FALSE]
  if (!is.null(routes)) manifest <- manifest[manifest$Route %in% routes, , drop = FALSE]
  row.names(manifest) <- NULL
  if (nrow(manifest) == 0L) stop("No attribution rows selected.", call. = FALSE)
  if (identical(profile, "pilot") && is.null(arms) && is.null(routes) &&
      !isTRUE(dry_run) && !isTRUE(authorize_full_pilot)) {
    stop(
      paste0(
        "The full replicated pilot is resource-significant and remains ",
        "calibration-only. Inspect the dry-run manifest, select arms/routes, ",
        "or set `authorize_full_pilot = TRUE` explicitly."
      ),
      call. = FALSE
    )
  }
  if (isTRUE(dry_run)) {
    return(structure(
      list(
        manifest = manifest, manifest_audit = audit,
        results = data.frame(), contrasts = data.frame(),
        confirmation_authorized = FALSE,
        interpretation = "calibration_only_no_rows_executed"
      ),
      class = "mfrmr_gpcm_isolated_attribution"
    ))
  }
  rows <- vector("list", nrow(manifest))
  for (i in seq_len(nrow(manifest))) {
    if (isTRUE(progress)) {
      message(sprintf("[%d/%d] %s", i, nrow(manifest),
                      manifest$ScenarioId[i]))
    }
    rows[[i]] <- mfrmr_gpcm_attribution_run_one(
      manifest[i, , drop = FALSE], run_pca = run_pca,
      maxit = maxit, quad_points = quad_points
    )
  }
  results <- mfrmr_gpcm_attribution_pair_audit(
    mfrmr_gpcm_attribution_bind(rows)
  )
  contrasts <- mfrmr_gpcm_attribution_contrasts(results, manifest)
  summary <- data.frame(
    Profile = profile,
    SelectedRows = nrow(manifest),
    DataCells = length(unique(manifest$DataCellId)),
    ExecutedRows = sum(results$Executed),
    FitSucceededRows = sum(results$FitSucceeded),
    ExpectedFailClosedRows = sum(results$RunState == "expected_fail_closed"),
    FalseReadyRows = sum(results$FalseReady, na.rm = TRUE),
    PairIdentityViolations = sum(results$PairIdentityViolation, na.rm = TRUE),
    PrimarySlopeEligibleRows = sum(
      results$SlopePrimaryMetricEligible, na.rm = TRUE
    ),
    NumericExternalEligibleRows = 0L,
    ThresholdStatus = "pilot_required_not_frozen",
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  out <- structure(
    list(
      manifest = manifest, manifest_audit = audit, results = results,
      contrasts = contrasts, summary = summary,
      confirmation_authorized = FALSE,
      interpretation = paste0(
        "paired_internal_calibration_only;_optimizer_slope_metrics_are_",
        "diagnostic_traces;_no_causal_or_external_equivalence_claim"
      ),
      session_info = utils::sessionInfo()
    ),
    class = "mfrmr_gpcm_isolated_attribution"
  )
  if (!is.null(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
    utils::write.csv(manifest, file.path(output_dir, "scenario-manifest.csv"),
                     row.names = FALSE, na = "")
    utils::write.csv(audit, file.path(output_dir, "manifest-audit.csv"),
                     row.names = FALSE, na = "")
    utils::write.csv(results, file.path(output_dir, "run-results.csv"),
                     row.names = FALSE, na = "")
    utils::write.csv(contrasts, file.path(output_dir, "paired-contrasts.csv"),
                     row.names = FALSE, na = "")
    utils::write.csv(summary, file.path(output_dir, "summary.csv"),
                     row.names = FALSE, na = "")
    saveRDS(out, file.path(output_dir,
                           "gpcm-isolated-attribution-pilot.rds"))
  }
  out
}

mfrmr_summarize_gpcm_isolated_attribution <- function(x) {
  if (!inherits(x, "mfrmr_gpcm_isolated_attribution")) {
    stop("`x` must be an isolated-attribution pilot result.", call. = FALSE)
  }
  list(
    summary = x$summary,
    manifest_audit = x$manifest_audit,
    run_states = if (nrow(x$results) > 0L) {
      as.data.frame(table(x$results$Route, x$results$RunState),
                    stringsAsFactors = FALSE)
    } else data.frame(),
    readiness = if (nrow(x$results) > 0L) {
      as.data.frame(table(x$results$Route, x$results$FitReadiness,
                          useNA = "ifany"), stringsAsFactors = FALSE)
    } else data.frame(),
    interpretation = x$interpretation
  )
}
