# Contract-bound PCM/JML smoke runner for the prospective Rater-anchor stress.
#
# Source the prospective contract and the preceding stress-pilot runner first.
# The default is no execution. Explicit execution is limited to the 12-run
# smoke manifest and cannot launch feasibility or select an anchor percentage.

mfrmr_rasps_specification <- "0.2.3-draft.1"
mfrmr_rasps_contract <- "mfrmr_rater_anchor_sparse_prospective_smoke_v1"
mfrmr_rasps_fingerprint_scope <- "within_run_pairing_and_provenance_only"

mfrmr_rasps_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_rasps_require_support <- function() {
  required <- c(
    "mfrmr_rasp_registry", "mfrmr_rasp_execution_manifest",
    "mfrmr_rasp_validate_manifest", "mfrmr_rass_capture",
    "mfrmr_rass_select_link_persons", "mfrmr_rass_pair_support",
    "mfrmr_rass_readiness", "mfrmr_rass_recovery", "build_mfrm_sim_spec",
    "simulate_mfrm_data", "review_mfrm_anchors", "fit_mfrm"
  )
  source_environment <- environment(mfrmr_rasps_require_support)
  missing <- required[!vapply(
    required, exists, logical(1), envir = source_environment,
    mode = "function", inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Load the prospective contract, stress-pilot helpers, and development ",
      "package before the smoke runner; missing: ",
      paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Package `digest` is required for smoke identities.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_rasps_with_seed <- function(seed, code) {
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (had_seed) old_seed <- get(".Random.seed", envir = .GlobalEnv)
  on.exit({
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv,
                      inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)
  set.seed(as.integer(seed))
  force(code)
}

mfrmr_rasps_generate_complete <- function(data_seed) {
  mfrmr_rasps_require_support()
  spec <- build_mfrm_sim_spec(
    n_person = 160L, n_rater = 16L, n_criterion = 4L,
    raters_per_person = 16L, score_levels = 4L,
    theta_sd = 1, rater_sd = 0.55, criterion_sd = 0.30,
    model = "PCM", step_facet = "Criterion", assignment = "crossed"
  )
  data <- simulate_mfrm_data(sim_spec = spec, seed = as.integer(data_seed))
  truth <- attr(data, "mfrm_truth")
  truth_hash <- digest::digest(list(
    person = truth$person, facets = truth$facets,
    step_table = truth$step_table
  ), algo = "sha256")
  list(data = data, truth = truth, spec = spec, TruthSHA256 = truth_hash)
}

mfrmr_rasps_nested_span_indices <- function(n, count) {
  count <- as.integer(count)
  mfrmr_rasps_assert(
    n == 16L && count %in% c(2L, 4L, 8L),
    "Nested range-spanning selection is frozen for 16 Raters and 2/4/8 anchors."
  )
  base_two <- c(1L, n)
  if (count == 2L) return(base_two)
  base_four <- sort(unique(c(base_two, round(seq(1, n, length.out = 4L)))))
  mfrmr_rasps_assert(length(base_four) == 4L,
                     "The four-Rater nested span is malformed.")
  if (count == 4L) return(base_four)
  additions <- round(1 + (n - 1) * c(1 / 8, 3 / 8, 5 / 8, 7 / 8))
  out <- sort(unique(c(base_four, additions)))
  mfrmr_rasps_assert(length(out) == 8L,
                     "The eight-Rater nested span is malformed.")
  out
}

mfrmr_rasps_external_selection <- function(truth, row) {
  row <- as.list(row)
  if (as.integer(row$AnchorCount) < 1L) {
    return(list(
      estimates = setNames(numeric(), character()),
      selected = character(), CalibrationSHA256 = digest::digest(
        data.frame(Level = character(), ExternalEstimate = numeric()),
        algo = "sha256"
      ),
      SelectionSHA256 = digest::digest(
        data.frame(Level = character(), Selected = logical()),
        algo = "sha256"
      )
    ))
  }
  rater_truth <- truth$facets$Rater
  estimates <- mfrmr_rasps_with_seed(
    row$ExternalSelectionSeed,
    rater_truth + stats::rnorm(
      length(rater_truth), 0, as.numeric(row$SelectionCalibrationSD)
    )
  )
  names(estimates) <- names(rater_truth)
  ordered <- sort(estimates)
  if (identical(row$SelectionRule, "range_spanning")) {
    index <- mfrmr_rasps_nested_span_indices(
      length(ordered), row$AnchorCount
    )
    selected <- names(ordered)[index]
  } else if (identical(row$SelectionRule, "central_cluster")) {
    selected <- names(ordered)[
      order(abs(ordered), names(ordered))[seq_len(row$AnchorCount)]
    ]
  } else {
    stop("Unknown external Rater selection rule: ", row$SelectionRule,
         call. = FALSE)
  }
  table <- data.frame(
    Level = names(estimates), ExternalEstimate = as.numeric(estimates),
    Selected = names(estimates) %in% selected,
    stringsAsFactors = FALSE
  )
  table <- table[order(table$Level), , drop = FALSE]
  list(
    estimates = estimates,
    selected = selected,
    CalibrationSHA256 = digest::digest(
      table[c("Level", "ExternalEstimate")], algo = "sha256"
    ),
    SelectionSHA256 = digest::digest(table, algo = "sha256")
  )
}

mfrmr_rasps_build_anchors <- function(truth, row) {
  row <- as.list(row)
  selection <- mfrmr_rasps_external_selection(truth, row)
  if (length(selection$selected) < 1L) {
    empty <- data.frame(
      Facet = character(), Level = character(), Anchor = numeric(),
      GeneratingTruth = numeric(), AnchorError = numeric(),
      stringsAsFactors = FALSE
    )
    return(list(
      anchors = empty,
      CalibrationSHA256 = selection$CalibrationSHA256,
      SelectionSHA256 = selection$SelectionSHA256,
      SelectionEstimateRMSE = NA_real_,
      SelectionRankSpearman = NA_real_,
      AnchorErrorMean = NA_real_, AnchorErrorRMSE = NA_real_,
      AnchorErrorMaxAbs = NA_real_,
      AnchorSHA256 = digest::digest(empty[c("Facet", "Level", "Anchor")],
                                    algo = "sha256")
    ))
  }
  selected <- selection$selected
  rater_truth <- as.numeric(truth$facets$Rater[selected])
  if (identical(row$ErrorMechanism, "independent_normal")) {
    error <- mfrmr_rasps_with_seed(
      row$ExternalAnchorSeed,
      stats::rnorm(length(selected), 0, as.numeric(row$ErrorSD))
    )
  } else if (identical(row$ErrorMechanism, "systematic_shift")) {
    error <- rep(as.numeric(row$ErrorShift), length(selected))
  } else if (identical(row$ErrorMechanism, "oracle_exact")) {
    error <- rep(0, length(selected))
  } else {
    stop("Unknown external anchor-error mechanism: ", row$ErrorMechanism,
         call. = FALSE)
  }
  anchors <- data.frame(
    Facet = "Rater", Level = selected, Anchor = rater_truth + error,
    GeneratingTruth = rater_truth, AnchorError = error,
    stringsAsFactors = FALSE
  )
  anchors <- anchors[order(anchors$Level), , drop = FALSE]
  row.names(anchors) <- NULL
  list(
    anchors = anchors,
    CalibrationSHA256 = selection$CalibrationSHA256,
    SelectionSHA256 = selection$SelectionSHA256,
    SelectionEstimateRMSE = sqrt(mean(
      (selection$estimates - truth$facets$Rater[names(selection$estimates)])^2
    )),
    SelectionRankSpearman = suppressWarnings(stats::cor(
      selection$estimates, truth$facets$Rater[names(selection$estimates)],
      method = "spearman"
    )),
    AnchorErrorMean = mean(error),
    AnchorErrorRMSE = sqrt(mean(error^2)),
    AnchorErrorMaxAbs = max(abs(error)),
    AnchorSHA256 = digest::digest(
      anchors[c("Facet", "Level", "Anchor")], algo = "sha256"
    )
  )
}

mfrmr_rasps_apply_design <- function(generated, row) {
  row <- as.list(row)
  data <- generated$data
  if (identical(row$AssignmentTopology, "complete")) {
    retained <- data
    link <- unique(as.character(data$Person))
  } else {
    people <- unique(as.character(data$Person))
    link <- mfrmr_rass_select_link_persons(
      generated$truth$person, row$LinkPersons, row$LinkSelection
    )
    person_index <- match(as.character(data$Person), people)
    rater_index <- match(
      as.character(data$Rater), sprintf("R%02d", seq_len(16L))
    )
    assigned <- vapply(seq_len(nrow(data)), function(i) {
      starts <- ((person_index[[i]] - 1L +
                    seq_len(as.integer(row$RatersPerNonlinkPerson)) - 1L) %%
                   16L) + 1L
      rater_index[[i]] %in% starts
    }, logical(1))
    retained <- data[as.character(data$Person) %in% link | assigned,
                     , drop = FALSE]
  }
  row.names(retained) <- NULL
  pair_support <- mfrmr_rass_pair_support(retained)
  list(
    data = retained,
    LinkPersonSHA256 = digest::digest(sort(link), algo = "sha256"),
    DataSHA256 = digest::digest(
      retained[c("Person", "Rater", "Criterion", "Score")],
      algo = "sha256"
    ),
    DesignDensity = nrow(retained) / nrow(data),
    MinCommonPersons = as.integer(pair_support[["MinCommonPersons"]]),
    MedianCommonPersons = as.numeric(pair_support[["MedianCommonPersons"]]),
    ZeroCommonRaterPairs = as.integer(pair_support[["ZeroCommonRaterPairs"]])
  )
}

mfrmr_rasps_empty_result <- function(row, state, error = NA_character_) {
  row <- as.list(row)
  data.frame(
    RunId = as.character(row$RunId),
    DatasetId = as.character(row$DatasetId),
    AnchorSetId = as.character(row$AnchorSetId),
    DesignId = as.character(row$DesignId),
    AnchorConfig = as.character(row$AnchorConfig),
    Replicate = as.integer(row$Replicate),
    RegistrySHA256 = as.character(row$RegistrySHA256),
    DataSeed = as.integer(row$DataSeed),
    ExternalSelectionSeed = as.integer(row$ExternalSelectionSeed),
    ExternalAnchorSeed = as.integer(row$ExternalAnchorSeed),
    AnchorRate = as.numeric(row$AnchorRate),
    AnchorCount = as.integer(row$AnchorCount),
    ErrorMechanism = as.character(row$ErrorMechanism),
    ErrorSD = as.numeric(row$ErrorSD),
    ErrorShift = as.numeric(row$ErrorShift),
    ExpectedRatingAssignments = as.integer(row$ExpectedRatingAssignments),
    AddedAssignmentsAboveSingle = as.integer(row$AddedAssignmentsAboveSingle),
    Executed = TRUE, SupportAuditPassed = FALSE, FitReturned = FALSE,
    InferenceReady = FALSE, StructuralFailure = FALSE,
    FailureStage = as.character(state), FailureCode = as.character(error),
    Warnings = NA_character_, TruthSHA256 = NA_character_,
    DataSHA256 = NA_character_, LinkPersonSHA256 = NA_character_,
    CalibrationSHA256 = NA_character_, SelectionSHA256 = NA_character_,
    AnchorSHA256 = NA_character_,
    SelectionEstimateRMSE = NA_real_, SelectionRankSpearman = NA_real_,
    AnchorErrorMean = NA_real_, AnchorErrorRMSE = NA_real_,
    AnchorErrorMaxAbs = NA_real_,
    Rows = NA_integer_, RealizedRatingAssignments = NA_integer_,
    DesignDensity = NA_real_, MinCommonPersons = NA_integer_,
    MedianCommonPersons = NA_real_, ZeroCommonRaterPairs = NA_integer_,
    AnchorReviewIssueRows = NA_integer_, FitReadiness = NA_character_,
    ReasonCodes = NA_character_, EstimabilityState = NA_character_,
    BoundaryState = NA_character_, NumericalState = NA_character_,
    ConvergenceCode = NA_integer_, ConvergenceStatus = NA_character_,
    TerminalGradientSupNorm = NA_real_, GradientReviewTolerance = NA_real_,
    ExtremeHighN = NA_integer_, ExtremeLowN = NA_integer_,
    ExtremeTotalN = NA_integer_,
    RaterN = 0L, FreeRaterN = 0L, AnchoredRaterN = 0L,
    RaterAbsoluteRMSE = NA_real_, FreeRaterAbsoluteRMSE = NA_real_,
    FreeRaterCenteredRMSE = NA_real_, AnchoredRaterRMSE = NA_real_,
    FreeRaterBias = NA_real_, RaterRankSpearman = NA_real_,
    PersonNAvailable = 0L, PersonAbsoluteRMSE = NA_real_,
    PersonCenteredRMSE = NA_real_, PersonBias = NA_real_,
    PersonRankSpearman = NA_real_, CriterionCenteredRMSE = NA_real_,
    FreeRaterRMSEDeltaVsNone = NA_real_,
    PersonRMSEDeltaVsNone = NA_real_,
    PersonRMSEDeltaVsExact25 = NA_real_, FitElapsedSeconds = NA_real_,
    SmokeOnly = TRUE, FeasibilityExecutionAuthorized = FALSE,
    AppropriateAnchorRateSelected = FALSE,
    BroadSimulationAuthorized = FALSE, ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_rasps_failure_code <- function(error) {
  message <- conditionMessage(error)
  structural_class <- inherits(error, "mfrmr_estimability_error")
  legacy_structural_message <- inherits(error, "simpleError") && any(
    startsWith(
      message,
      c(
        "The estimator-specific constrained design is structurally unidentified ",
        "The constrained design is structurally unidentified "
      )
    )
  )
  structural <- structural_class || legacy_structural_message
  list(
    stage = if (structural) "structural_prefit" else "fit",
    code = if (structural) "structural_identification_failure" else
      paste0("fit_error: ", message),
    structural = structural
  )
}

mfrmr_rasps_run_one <- function(row, generated, designed) {
  row_list <- as.list(row)
  anchor_info <- mfrmr_rasps_build_anchors(generated$truth, row_list)
  anchors <- anchor_info$anchors
  payload <- anchors[c("Facet", "Level", "Anchor")]
  supplied <- if (nrow(payload) > 0L) payload else NULL
  review <- mfrmr_rass_capture(review_mfrm_anchors(
    designed$data, "Person", c("Rater", "Criterion"), "Score",
    anchors = supplied, rating_min = 1L, rating_max = 4L,
    keep_original = TRUE, min_common_anchors = 1L,
    min_obs_per_element = 30L, min_obs_per_category = 10L
  ))
  if (inherits(review$value, "error")) {
    out <- mfrmr_rasps_empty_result(
      row_list, "support_audit", conditionMessage(review$value)
    )
    out$Warnings <- paste(review$warnings, collapse = " | ")
  } else {
    start <- proc.time()
    fitted <- mfrmr_rass_capture(fit_mfrm(
      designed$data, "Person", c("Rater", "Criterion"), "Score",
      rating_min = 1L, rating_max = 4L, keep_original = TRUE,
      model = "PCM", method = "JML", step_facet = "Criterion",
      anchors = supplied, min_common_anchors = 1L, anchor_policy = "warn",
      maxit = as.integer(row_list$Maxit)
    ))
    elapsed <- unname((proc.time() - start)[["elapsed"]])
    warnings <- unique(c(review$warnings, fitted$warnings))
    if (inherits(fitted$value, "error")) {
      failure <- mfrmr_rasps_failure_code(fitted$value)
      out <- mfrmr_rasps_empty_result(
        row_list, failure$stage, failure$code
      )
      out$StructuralFailure <- failure$structural
    } else {
      fit <- fitted$value
      readiness <- mfrmr_rass_readiness(fit)
      fit_summary <- as.data.frame(fit$summary %||% data.frame(),
                                   stringsAsFactors = FALSE)
      take_summary <- function(name, default = NA) {
        if (nrow(fit_summary) == 1L && name %in% names(fit_summary)) {
          fit_summary[[name]][[1L]]
        } else {
          default
        }
      }
      recovery <- mfrmr_rass_recovery(
        fit, generated$truth, as.character(payload$Level)
      )
      stage <- if (readiness$InferenceReady) "none" else "readiness"
      code <- if (readiness$InferenceReady) "none" else readiness$ReasonCodes
      out <- mfrmr_rasps_empty_result(row_list, stage, code)
      out$FitReturned <- TRUE
      out$InferenceReady <- readiness$InferenceReady
      out$FitReadiness <- readiness$FitReadiness
      out$ReasonCodes <- readiness$ReasonCodes
      out$EstimabilityState <- readiness$EstimabilityState
      out$BoundaryState <- readiness$BoundaryState
      out$NumericalState <- readiness$NumericalState
      out$ConvergenceCode <- as.integer(take_summary(
        "ConvergenceCode", NA_integer_
      ))
      out$ConvergenceStatus <- as.character(take_summary(
        "ConvergenceStatus", NA_character_
      ))
      out$TerminalGradientSupNorm <- as.numeric(take_summary(
        "TerminalGradientSupNorm", NA_real_
      ))
      out$GradientReviewTolerance <- as.numeric(take_summary(
        "GradientReviewTolerance", NA_real_
      ))
      out$ExtremeHighN <- as.integer(take_summary("ExtremeHighN", NA_integer_))
      out$ExtremeLowN <- as.integer(take_summary("ExtremeLowN", NA_integer_))
      out$ExtremeTotalN <- out$ExtremeHighN + out$ExtremeLowN
      out[names(recovery)] <- recovery
    }
    out$Warnings <- paste(warnings, collapse = " | ")
    out$FitElapsedSeconds <- elapsed
    out$SupportAuditPassed <- TRUE
    out$AnchorReviewIssueRows <- sum(
      as.numeric(review$value$issue_counts$N %||% 0), na.rm = TRUE
    )
  }
  out$TruthSHA256 <- generated$TruthSHA256
  out$DataSHA256 <- designed$DataSHA256
  out$LinkPersonSHA256 <- designed$LinkPersonSHA256
  out$CalibrationSHA256 <- anchor_info$CalibrationSHA256
  out$SelectionSHA256 <- anchor_info$SelectionSHA256
  out$AnchorSHA256 <- anchor_info$AnchorSHA256
  out$SelectionEstimateRMSE <- anchor_info$SelectionEstimateRMSE
  out$SelectionRankSpearman <- anchor_info$SelectionRankSpearman
  out$AnchorErrorMean <- anchor_info$AnchorErrorMean
  out$AnchorErrorRMSE <- anchor_info$AnchorErrorRMSE
  out$AnchorErrorMaxAbs <- anchor_info$AnchorErrorMaxAbs
  out$Rows <- nrow(designed$data)
  out$RealizedRatingAssignments <- nrow(designed$data) / 4L
  out$DesignDensity <- designed$DesignDensity
  out$MinCommonPersons <- designed$MinCommonPersons
  out$MedianCommonPersons <- designed$MedianCommonPersons
  out$ZeroCommonRaterPairs <- designed$ZeroCommonRaterPairs
  out
}

mfrmr_rasps_add_paired_deltas <- function(results) {
  groups <- split(seq_len(nrow(results)), results$DatasetId)
  for (index in groups) {
    none <- index[results$AnchorConfig[index] == "none"]
    exact <- index[results$AnchorConfig[index] == "exact_25_span"]
    if (length(none) == 1L) {
      results$FreeRaterRMSEDeltaVsNone[index] <-
        results$FreeRaterAbsoluteRMSE[index] -
        results$FreeRaterAbsoluteRMSE[none]
      results$PersonRMSEDeltaVsNone[index] <-
        results$PersonAbsoluteRMSE[index] -
        results$PersonAbsoluteRMSE[none]
    }
    if (length(exact) == 1L) {
      results$PersonRMSEDeltaVsExact25[index] <-
        results$PersonAbsoluteRMSE[index] -
        results$PersonAbsoluteRMSE[exact]
    }
  }
  results
}

mfrmr_rasps_validate_results <- function(registry, manifest, results) {
  mfrmr_rasps_assert(
    is.data.frame(results) && nrow(results) == 12L &&
      identical(results$RunId, manifest$RunId) && all(results$Executed),
    "Smoke results do not cover the exact 12-run manifest."
  )
  identities <- c(
    "TruthSHA256", "DataSHA256", "LinkPersonSHA256",
    "CalibrationSHA256", "SelectionSHA256", "AnchorSHA256"
  )
  mfrmr_rasps_assert(
    all(vapply(results[identities], function(x) all(nchar(x) == 64L),
               logical(1))) &&
      all(results$RegistrySHA256 == registry$RegistrySHA256),
    "Smoke truth, data, selection, anchor, or registry identities are incomplete."
  )
  by_dataset <- split(seq_len(nrow(results)), results$DatasetId)
  by_anchor <- split(seq_len(nrow(results)), results$AnchorSetId)
  mfrmr_rasps_assert(
    all(vapply(by_dataset, function(i) {
      length(unique(results$DataSHA256[i])) == 1L &&
        length(unique(results$TruthSHA256[i])) == 1L
    }, logical(1))) &&
      all(vapply(by_anchor, function(i) {
        length(unique(results$SelectionSHA256[i])) == 1L &&
          length(unique(results$AnchorSHA256[i])) == 1L
      }, logical(1))),
    "Paired response, external-selection, or anchor identities drifted."
  )
  positive <- results$AnchorRate > 0
  mfrmr_rasps_assert(
    length(unique(results$CalibrationSHA256[positive])) == 1L,
    "Positive-rate arms did not share the external calibration identity."
  )
  mfrmr_rasps_assert(
    all(results$Rows == manifest$ExpectedResponseRows) &&
      all(results$RealizedRatingAssignments ==
            manifest$ExpectedRatingAssignments) &&
      all(abs(results$DesignDensity - manifest$ExpectedDensity) < 1e-12),
    "Realized sparse design or resource accounting drifted."
  )
  mfrmr_rasps_assert(
    all(results$SmokeOnly) &&
      all(!results$FeasibilityExecutionAuthorized) &&
      all(!results$AppropriateAnchorRateSelected) &&
      all(!results$BroadSimulationAuthorized) &&
      all(!results$ConfirmationAuthorized),
    "Smoke execution cannot authorize feasibility or select a rate."
  )
  invisible(TRUE)
}

mfrmr_rasps_summary <- function(results) {
  results[c(
    "DesignId", "AnchorConfig", "AnchorRate", "AnchorCount",
    "ExpectedRatingAssignments", "AddedAssignmentsAboveSingle",
    "SelectionEstimateRMSE", "SelectionRankSpearman",
    "AnchorErrorMean", "AnchorErrorRMSE", "AnchorErrorMaxAbs",
    "FitReturned", "InferenceReady", "StructuralFailure", "FailureStage",
    "FailureCode", "ConvergenceCode", "ConvergenceStatus",
    "TerminalGradientSupNorm", "GradientReviewTolerance",
    "ExtremeHighN", "ExtremeLowN", "ExtremeTotalN",
    "FreeRaterAbsoluteRMSE", "PersonAbsoluteRMSE",
    "PersonRankSpearman", "FreeRaterRMSEDeltaVsNone",
    "PersonRMSEDeltaVsNone", "PersonRMSEDeltaVsExact25",
    "FitElapsedSeconds"
  )]
}

mfrmr_run_rater_anchor_sparse_prospective_smoke <- function(
    execute = FALSE, profile = "smoke", progress = interactive()) {
  mfrmr_rasps_require_support()
  mfrmr_rasps_assert(
    identical(profile, "smoke"),
    "This runner is sealed to the 12-run smoke and refuses feasibility."
  )
  registry <- mfrmr_rasp_registry()
  manifest <- mfrmr_rasp_execution_manifest(registry, "smoke")
  if (!isTRUE(execute)) {
    return(list(
      Specification = mfrmr_rasps_specification,
      Contract = mfrmr_rasps_contract,
      FingerprintScope = mfrmr_rasps_fingerprint_scope,
      RegistrySHA256 = registry$RegistrySHA256,
      ManifestSHA256 = mfrmr_rasp_manifest_hash(manifest),
      manifest = manifest, results = data.frame(), summary = data.frame(),
      SmokeExecuted = FALSE, SmokeExecutionContractPassed = NA,
      SmokeScientificReadinessObserved = NA,
      FeasibilityHandoffAuthorized = FALSE,
      FeasibilityExecutionAuthorized = FALSE,
      AppropriateAnchorRateSelected = FALSE,
      BroadSimulationAuthorized = FALSE, ConfirmationAuthorized = FALSE
    ))
  }
  generated <- mfrmr_rasps_generate_complete(unique(manifest$DataSeed))
  rows <- vector("list", nrow(manifest))
  cursor <- 0L
  for (design_id in unique(manifest$DesignId)) {
    design_rows <- manifest[manifest$DesignId == design_id, , drop = FALSE]
    designed <- mfrmr_rasps_apply_design(generated, design_rows[1L, ])
    for (i in seq_len(nrow(design_rows))) {
      cursor <- cursor + 1L
      if (isTRUE(progress)) {
        message("[", cursor, "/", nrow(manifest), "] ",
                design_rows$RunId[[i]])
      }
      rows[[cursor]] <- mfrmr_rasps_run_one(
        design_rows[i, , drop = FALSE], generated, designed
      )
    }
  }
  results <- do.call(rbind, rows)
  row.names(results) <- NULL
  results <- mfrmr_rasps_add_paired_deltas(results)
  mfrmr_rasps_validate_results(registry, manifest, results)
  summary <- mfrmr_rasps_summary(results)
  list(
    Specification = mfrmr_rasps_specification,
    Contract = mfrmr_rasps_contract,
    FingerprintScope = mfrmr_rasps_fingerprint_scope,
    RegistrySHA256 = registry$RegistrySHA256,
    ManifestSHA256 = mfrmr_rasp_manifest_hash(manifest),
    manifest = manifest, results = results, summary = summary,
    SmokeExecuted = TRUE,
    SmokeExecutionContractPassed = all(
      results$Executed & results$SupportAuditPassed & results$FitReturned
    ),
    SmokeScientificReadinessObserved = all(results$InferenceReady),
    FeasibilityHandoffAuthorized = FALSE,
    FeasibilityExecutionAuthorized = FALSE,
    AppropriateAnchorRateSelected = FALSE,
    BroadSimulationAuthorized = FALSE, ConfirmationAuthorized = FALSE
  )
}
