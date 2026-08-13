# Rater-anchor proportion by sparse-link stress pilot for mfrmr 0.2.3.
#
# This repository-only pilot uses PCM/JML, the direct FACETS-adjacent lane.
# It separates the proportion of Rater levels fixed to known values from the
# proportion of Persons used as a common linking set. It estimates no stable
# operating characteristic and cannot choose an operational anchor rate.

mfrmr_rass_specification <- "0.2.3-draft.1"
mfrmr_rass_contract <- "mfrmr_rater_anchor_sparse_stress_pilot_v1"

mfrmr_rass_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_rass_require_support <- function() {
  required <- c(
    "build_mfrm_sim_spec", "simulate_mfrm_data", "review_mfrm_anchors",
    "fit_mfrm"
  )
  missing <- required[!vapply(required, exists, logical(1), mode = "function")]
  if (length(missing) > 0L) {
    stop(
      "Load the development package before running the Rater-anchor stress; missing: ",
      paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Package `digest` is required for stress identities.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_rass_design_registry <- function() {
  data.frame(
    DesignId = c(
      "complete", "sparse_link0", "sparse_link2_range",
      "sparse_link10_range", "sparse_link10_central",
      "sparse_pair_cycle", "sparse_pair_link10_range"
    ),
    LinkPersons = c(80L, 0L, 2L, 10L, 10L, 0L, 10L),
    LinkSelection = c(
      "all", "none", "range_spanning", "range_spanning", "central_cluster",
      "none", "range_spanning"
    ),
    RatersPerNonlinkPerson = c(8L, 1L, 1L, 1L, 1L, 2L, 2L),
    ExpectedDensity = c(
      1, 0.125, 0.146875, 0.234375, 0.234375, 0.25, 0.34375
    ),
    ExpectedMinCommonPersons = c(80L, 0L, 2L, 10L, 10L, 0L, 10L),
    Role = c(
      "fully_crossed_reference", "disconnected_person_rater_negative_control",
      "weak_common_person_link", "moderate_representative_common_link",
      "moderate_range_restricted_common_link",
      "two_rater_connected_cycle_without_universal_link",
      "two_rater_cycle_plus_moderate_universal_link"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_rass_anchor_registry <- function() {
  data.frame(
    AnchorConfig = c(
      "none", "exact_12_5_central", "exact_25_span", "exact_50_span",
      "exact_75_span", "exact_25_central", "shifted_25_span"
    ),
    AnchorRate = c(0, 0.125, 0.25, 0.50, 0.75, 0.25, 0.25),
    AnchorCount = c(0L, 1L, 2L, 4L, 6L, 2L, 2L),
    SelectionRule = c(
      "none", "central_cluster", "range_spanning", "range_spanning",
      "range_spanning", "central_cluster", "range_spanning"
    ),
    AnchorValueShift = c(0, 0, 0, 0, 0, 0, 0.25),
    AnchorQuality = c(
      "none", rep("exact_generating_value", 5L), "systematic_plus_0.25_logit"
    ),
    PrimaryContrast = c(
      "unanchored_reference", "minimum_count", "moderate_exact",
      "high_exact", "saturation_stress", "representativeness_stress",
      "misspecification_stress"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_rass_manifest <- function(profile = c("smoke", "pilot")) {
  profile <- match.arg(profile)
  designs <- mfrmr_rass_design_registry()
  anchors <- mfrmr_rass_anchor_registry()
  seeds <- if (identical(profile, "smoke")) 615001L else 615001:615003
  if (identical(profile, "smoke")) {
    designs <- designs[designs$DesignId %in%
                         c(
                           "complete", "sparse_link2_range",
                           "sparse_pair_link10_range"
                         ), , drop = FALSE]
    anchors <- anchors[anchors$AnchorConfig %in%
                         c("none", "exact_25_span", "shifted_25_span"),
                       , drop = FALSE]
  }
  out <- merge(
    merge(data.frame(Seed = seeds), designs, by = NULL),
    anchors,
    by = NULL
  )
  out <- out[order(
    out$Seed, match(out$DesignId, designs$DesignId),
    match(out$AnchorConfig, anchors$AnchorConfig)
  ), , drop = FALSE]
  row.names(out) <- NULL
  out$Profile <- profile
  out$ScenarioId <- sprintf(
    "RASS-%d-%s-%s", out$Seed, toupper(out$DesignId),
    toupper(out$AnchorConfig)
  )
  out$NPerson <- 80L
  out$NRater <- 8L
  out$NCriterion <- 4L
  out$NCategory <- 4L
  out$Model <- "PCM"
  out$Estimator <- "JML"
  out$Maxit <- 120L
  out$MinCommonAnchorsReview <- 1L
  out$CalibrationOnly <- TRUE
  out$AppropriateAnchorRateSelected <- FALSE
  out$BroadSimulationAuthorized <- FALSE
  out$ConfirmationAuthorized <- FALSE
  out
}

mfrmr_rass_capture <- function(expr) {
  warnings <- character(0)
  value <- withCallingHandlers(
    tryCatch(expr, error = function(e) e),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  list(value = value, warnings = unique(warnings))
}

mfrmr_rass_generate_complete <- function(seed) {
  mfrmr_rass_require_support()
  spec <- build_mfrm_sim_spec(
    n_person = 80L, n_rater = 8L, n_criterion = 4L,
    raters_per_person = 8L, score_levels = 4L,
    theta_sd = 1, rater_sd = 0.55, criterion_sd = 0.30,
    model = "PCM", step_facet = "Criterion", assignment = "crossed"
  )
  data <- simulate_mfrm_data(sim_spec = spec, seed = as.integer(seed))
  truth <- attr(data, "mfrm_truth")
  truth_hash <- digest::digest(list(
    person = truth$person, facets = truth$facets,
    step_table = truth$step_table
  ), algo = "sha256")
  list(data = data, truth = truth, spec = spec, TruthSHA256 = truth_hash)
}

mfrmr_rass_select_levels <- function(values, count, rule) {
  values <- sort(values)
  count <- as.integer(count)
  if (count < 1L) return(character(0))
  if (identical(rule, "central_cluster")) {
    return(names(values)[order(abs(values), names(values))[seq_len(count)]])
  }
  if (!identical(rule, "range_spanning")) {
    stop("Unknown level selection rule: ", rule, call. = FALSE)
  }
  index <- unique(round(seq(1, length(values), length.out = count)))
  if (length(index) != count) {
    stop("Range-spanning selection did not return the declared count.",
         call. = FALSE)
  }
  names(values)[index]
}

mfrmr_rass_select_link_persons <- function(truth_person, count, rule) {
  count <- as.integer(count)
  if (count < 1L || identical(rule, "none")) return(character(0))
  if (identical(rule, "all")) return(names(truth_person))
  ordered <- sort(truth_person)
  if (identical(rule, "central_cluster")) {
    return(names(ordered)[order(abs(ordered), names(ordered))[seq_len(count)]])
  }
  if (!identical(rule, "range_spanning")) {
    stop("Unknown link-Person selection rule: ", rule, call. = FALSE)
  }
  candidates <- round(seq(1, length(ordered), length.out = count + 2L))
  candidates <- candidates[seq_len(count) + 1L]
  names(ordered)[candidates]
}

mfrmr_rass_pair_support <- function(data) {
  person_rater <- unique(data[c("Person", "Rater")])
  raters <- sort(unique(as.character(person_rater$Rater)))
  pairs <- utils::combn(raters, 2L, simplify = FALSE)
  common <- vapply(pairs, function(pair) {
    length(intersect(
      as.character(person_rater$Person[person_rater$Rater == pair[[1L]]]),
      as.character(person_rater$Person[person_rater$Rater == pair[[2L]]])
    ))
  }, integer(1))
  c(
    MinCommonPersons = min(common),
    MedianCommonPersons = stats::median(common),
    ZeroCommonRaterPairs = sum(common == 0L)
  )
}

mfrmr_rass_apply_design <- function(generated, design_row) {
  data <- generated$data
  design <- as.list(design_row)
  if (identical(design$DesignId, "complete")) {
    retained <- data
    link <- unique(as.character(data$Person))
  } else {
    people <- unique(as.character(data$Person))
    link <- mfrmr_rass_select_link_persons(
      generated$truth$person, design$LinkPersons, design$LinkSelection
    )
    person_index <- match(as.character(data$Person), people)
    rater_index <- match(as.character(data$Rater), sprintf("R%02d", 1:8))
    assigned <- vapply(seq_len(nrow(data)), function(i) {
      starts <- ((person_index[[i]] - 1L +
                    seq_len(as.integer(design$RatersPerNonlinkPerson)) - 1L) %%
                   8L) + 1L
      rater_index[[i]] %in% starts
    }, logical(1))
    keep <- as.character(data$Person) %in% link |
      assigned
    retained <- data[keep, , drop = FALSE]
  }
  row.names(retained) <- NULL
  support <- mfrmr_rass_pair_support(retained)
  density <- nrow(retained) / nrow(data)
  data_hash <- digest::digest(
    retained[c("Person", "Rater", "Criterion", "Score")],
    algo = "sha256"
  )
  list(
    data = retained, link_persons = link,
    DesignDensity = density,
    PlannedMissingRate = 1 - density,
    MinCommonPersons = as.integer(support[["MinCommonPersons"]]),
    MedianCommonPersons = as.numeric(support[["MedianCommonPersons"]]),
    ZeroCommonRaterPairs = as.integer(support[["ZeroCommonRaterPairs"]]),
    DataSHA256 = data_hash
  )
}

mfrmr_rass_build_anchors <- function(truth, anchor_row) {
  anchor <- as.list(anchor_row)
  if (as.integer(anchor$AnchorCount) < 1L) return(data.frame())
  rater_truth <- truth$facets$Rater
  selected <- mfrmr_rass_select_levels(
    rater_truth, anchor$AnchorCount, anchor$SelectionRule
  )
  data.frame(
    Facet = "Rater",
    Level = selected,
    Anchor = as.numeric(rater_truth[selected]) +
      as.numeric(anchor$AnchorValueShift),
    GeneratingTruth = as.numeric(rater_truth[selected]),
    AnchorError = as.numeric(anchor$AnchorValueShift),
    stringsAsFactors = FALSE
  )
}

mfrmr_rass_readiness <- function(fit) {
  readiness <- as.data.frame(fit$readiness$fit %||% data.frame(),
                             stringsAsFactors = FALSE)
  summary <- as.data.frame(fit$summary %||% data.frame(),
                           stringsAsFactors = FALSE)
  take <- function(name, default = NA) {
    if (nrow(readiness) == 1L && name %in% names(readiness)) {
      return(readiness[[name]][[1L]])
    }
    if (nrow(summary) == 1L && name %in% names(summary)) {
      return(summary[[name]][[1L]])
    }
    default
  }
  list(
    FitReadiness = as.character(take("FitReadiness", "legacy_unknown")),
    InferenceReady = isTRUE(as.logical(take("InferenceReady", FALSE))),
    ReasonCodes = as.character(take("ReasonCodes", "legacy_contract_missing")),
    EstimabilityState = as.character(take("EstimabilityState", NA_character_)),
    BoundaryState = as.character(take("BoundaryState", NA_character_)),
    NumericalState = as.character(take("NumericalState", NA_character_))
  )
}

mfrmr_rass_rmse <- function(estimate, truth, center = FALSE) {
  ok <- is.finite(estimate) & is.finite(truth)
  estimate <- estimate[ok]
  truth <- truth[ok]
  if (length(estimate) < 1L) return(NA_real_)
  if (isTRUE(center)) {
    estimate <- estimate - mean(estimate)
    truth <- truth - mean(truth)
  }
  sqrt(mean((estimate - truth)^2))
}

mfrmr_rass_recovery <- function(fit, truth, anchor_levels) {
  others <- as.data.frame(fit$facets$others %||% data.frame(),
                          stringsAsFactors = FALSE)
  rater <- others[others$Facet == "Rater", c("Level", "Estimate"),
                  drop = FALSE]
  rater$Truth <- as.numeric(truth$facets$Rater[as.character(rater$Level)])
  rater$Anchored <- as.character(rater$Level) %in% anchor_levels
  free <- !rater$Anchored
  rater_error <- rater$Estimate - rater$Truth

  person <- as.data.frame(fit$facets$person %||% data.frame(),
                           stringsAsFactors = FALSE)
  status_ok <- if ("ParameterStatus" %in% names(person)) {
    as.character(person$ParameterStatus) == "estimable"
  } else {
    rep(TRUE, nrow(person))
  }
  person$Truth <- as.numeric(truth$person[as.character(person$Person)])
  person_ok <- status_ok & is.finite(person$Estimate) & is.finite(person$Truth)

  criterion <- others[
    others$Facet == "Criterion", c("Level", "Estimate"), drop = FALSE
  ]
  criterion$Truth <- as.numeric(
    truth$facets$Criterion[as.character(criterion$Level)]
  )

  data.frame(
    RaterN = nrow(rater),
    FreeRaterN = sum(free),
    AnchoredRaterN = sum(rater$Anchored),
    RaterAbsoluteRMSE = mfrmr_rass_rmse(rater$Estimate, rater$Truth),
    FreeRaterAbsoluteRMSE = mfrmr_rass_rmse(
      rater$Estimate[free], rater$Truth[free]
    ),
    FreeRaterCenteredRMSE = mfrmr_rass_rmse(
      rater$Estimate[free], rater$Truth[free], center = TRUE
    ),
    AnchoredRaterRMSE = mfrmr_rass_rmse(
      rater$Estimate[rater$Anchored], rater$Truth[rater$Anchored]
    ),
    FreeRaterBias = if (any(free)) mean(rater_error[free]) else NA_real_,
    RaterRankSpearman = suppressWarnings(stats::cor(
      rater$Estimate, rater$Truth, method = "spearman"
    )),
    PersonNAvailable = sum(person_ok),
    PersonAbsoluteRMSE = mfrmr_rass_rmse(
      person$Estimate[person_ok], person$Truth[person_ok]
    ),
    PersonCenteredRMSE = mfrmr_rass_rmse(
      person$Estimate[person_ok], person$Truth[person_ok], center = TRUE
    ),
    PersonBias = if (any(person_ok)) {
      mean(person$Estimate[person_ok] - person$Truth[person_ok])
    } else NA_real_,
    PersonRankSpearman = suppressWarnings(stats::cor(
      person$Estimate[person_ok], person$Truth[person_ok], method = "spearman"
    )),
    CriterionCenteredRMSE = mfrmr_rass_rmse(
      criterion$Estimate, criterion$Truth, center = TRUE
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_rass_empty_result <- function(row, state, error = NA_character_) {
  data.frame(
    ScenarioId = as.character(row$ScenarioId),
    Seed = as.integer(row$Seed),
    DesignId = as.character(row$DesignId),
    LinkPersons = as.integer(row$LinkPersons),
    LinkSelection = as.character(row$LinkSelection),
    AnchorConfig = as.character(row$AnchorConfig),
    AnchorRate = as.numeric(row$AnchorRate),
    AnchorCount = as.integer(row$AnchorCount),
    AnchorQuality = as.character(row$AnchorQuality),
    Executed = TRUE,
    FitReturned = FALSE,
    RunState = as.character(state),
    Error = as.character(error),
    Warnings = NA_character_,
    TruthSHA256 = NA_character_,
    DataSHA256 = NA_character_,
    AnchorSHA256 = NA_character_,
    Rows = NA_integer_,
    DesignDensity = NA_real_,
    PlannedMissingRate = NA_real_,
    MinCommonPersons = NA_integer_,
    MedianCommonPersons = NA_real_,
    ZeroCommonRaterPairs = NA_integer_,
    AnchorReviewIssueRows = NA_integer_,
    FitReadiness = NA_character_,
    InferenceReady = FALSE,
    ReasonCodes = NA_character_,
    EstimabilityState = NA_character_,
    BoundaryState = NA_character_,
    NumericalState = NA_character_,
    RaterN = 0L, FreeRaterN = 0L, AnchoredRaterN = 0L,
    RaterAbsoluteRMSE = NA_real_,
    FreeRaterAbsoluteRMSE = NA_real_,
    FreeRaterCenteredRMSE = NA_real_,
    AnchoredRaterRMSE = NA_real_,
    FreeRaterBias = NA_real_,
    RaterRankSpearman = NA_real_,
    PersonNAvailable = 0L,
    PersonAbsoluteRMSE = NA_real_,
    PersonCenteredRMSE = NA_real_,
    PersonBias = NA_real_,
    PersonRankSpearman = NA_real_,
    CriterionCenteredRMSE = NA_real_,
    FreeRaterRMSEDeltaVsNone = NA_real_,
    PersonRMSEDeltaVsNone = NA_real_,
    FitElapsedSeconds = NA_real_,
    CalibrationOnly = TRUE,
    AppropriateAnchorRateSelected = FALSE,
    BroadSimulationAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_rass_run_one <- function(row, generated, designed) {
  row <- as.list(row)
  anchors <- mfrmr_rass_build_anchors(generated$truth, row)
  anchor_payload <- if (nrow(anchors) > 0L) {
    anchors[c("Facet", "Level", "Anchor")]
  } else {
    data.frame(Facet = character(), Level = character(), Anchor = numeric())
  }
  anchor_hash <- digest::digest(anchor_payload, algo = "sha256")
  review <- mfrmr_rass_capture(review_mfrm_anchors(
    designed$data, "Person", c("Rater", "Criterion"), "Score",
    anchors = if (nrow(anchor_payload) > 0L) anchor_payload else NULL,
    rating_min = 1L, rating_max = 4L, keep_original = TRUE,
    min_common_anchors = 1L, min_obs_per_element = 30L,
    min_obs_per_category = 10L
  ))
  if (inherits(review$value, "error")) {
    out <- mfrmr_rass_empty_result(
      row, "anchor_review_failed", conditionMessage(review$value)
    )
    out$TruthSHA256 <- generated$TruthSHA256
    out$DataSHA256 <- designed$DataSHA256
    out$AnchorSHA256 <- anchor_hash
    return(out)
  }
  issue_rows <- sum(as.numeric(review$value$issue_counts$N %||% 0), na.rm = TRUE)
  start <- proc.time()
  fitted <- mfrmr_rass_capture(fit_mfrm(
    designed$data, "Person", c("Rater", "Criterion"), "Score",
    rating_min = 1L, rating_max = 4L, keep_original = TRUE,
    model = "PCM", method = "JML", step_facet = "Criterion",
    anchors = if (nrow(anchor_payload) > 0L) anchor_payload else NULL,
    min_common_anchors = 1L, anchor_policy = "warn",
    maxit = as.integer(row$Maxit)
  ))
  elapsed <- unname((proc.time() - start)[["elapsed"]])
  warnings <- unique(c(review$warnings, fitted$warnings))
  if (inherits(fitted$value, "error")) {
    out <- mfrmr_rass_empty_result(
      row, "fit_failed", conditionMessage(fitted$value)
    )
  } else {
    fit <- fitted$value
    readiness <- mfrmr_rass_readiness(fit)
    recovery <- mfrmr_rass_recovery(
      fit, generated$truth, as.character(anchor_payload$Level)
    )
    out <- mfrmr_rass_empty_result(row, "fit_retained")
    out$FitReturned <- TRUE
    out$FitReadiness <- readiness$FitReadiness
    out$InferenceReady <- readiness$InferenceReady
    out$ReasonCodes <- readiness$ReasonCodes
    out$EstimabilityState <- readiness$EstimabilityState
    out$BoundaryState <- readiness$BoundaryState
    out$NumericalState <- readiness$NumericalState
    out[names(recovery)] <- recovery
  }
  out$Warnings <- paste(warnings, collapse = " | ")
  out$TruthSHA256 <- generated$TruthSHA256
  out$DataSHA256 <- designed$DataSHA256
  out$AnchorSHA256 <- anchor_hash
  out$Rows <- nrow(designed$data)
  out$DesignDensity <- designed$DesignDensity
  out$PlannedMissingRate <- designed$PlannedMissingRate
  out$MinCommonPersons <- designed$MinCommonPersons
  out$MedianCommonPersons <- designed$MedianCommonPersons
  out$ZeroCommonRaterPairs <- designed$ZeroCommonRaterPairs
  out$AnchorReviewIssueRows <- as.integer(issue_rows)
  out$FitElapsedSeconds <- elapsed
  out
}

mfrmr_rass_add_paired_deltas <- function(results) {
  groups <- split(seq_len(nrow(results)), interaction(
    results$Seed, results$DesignId, drop = TRUE
  ))
  for (index in groups) {
    baseline <- index[results$AnchorConfig[index] == "none"]
    if (length(baseline) != 1L) next
    results$FreeRaterRMSEDeltaVsNone[index] <-
      results$FreeRaterAbsoluteRMSE[index] -
      results$FreeRaterAbsoluteRMSE[baseline]
    results$PersonRMSEDeltaVsNone[index] <-
      results$PersonAbsoluteRMSE[index] -
      results$PersonAbsoluteRMSE[baseline]
  }
  results
}

mfrmr_rass_validate_results <- function(results, manifest) {
  mfrmr_rass_assert(
    is.data.frame(results) && nrow(results) == nrow(manifest) &&
      identical(as.character(results$ScenarioId), as.character(manifest$ScenarioId)),
    "Stress results do not cover the exact declared manifest."
  )
  mfrmr_rass_assert(
    all(results$Executed) && all(results$Rows > 0L) &&
      all(nchar(results$TruthSHA256) == 64L) &&
      all(nchar(results$DataSHA256) == 64L) &&
      all(nchar(results$AnchorSHA256) == 64L),
    "Execution, data, truth, or anchor identities are incomplete."
  )
  truth_groups <- split(results$TruthSHA256, results$Seed)
  data_groups <- split(results$DataSHA256, interaction(
    results$Seed, results$DesignId, drop = TRUE
  ))
  mfrmr_rass_assert(
    all(vapply(truth_groups, function(x) length(unique(x)) == 1L, logical(1))) &&
      all(vapply(data_groups, function(x) length(unique(x)) == 1L, logical(1))),
    "Paired anchor comparisons did not preserve common truth or response data."
  )
  mfrmr_rass_assert(
    all(abs(results$DesignDensity - manifest$ExpectedDensity) < 1e-12) &&
      all(results$MinCommonPersons == manifest$ExpectedMinCommonPersons),
    "Realized sparse density or common-Person support drifted."
  )
  mfrmr_rass_assert(
    all(results$CalibrationOnly) &&
      all(!results$AppropriateAnchorRateSelected) &&
      all(!results$BroadSimulationAuthorized) &&
      all(!results$ConfirmationAuthorized),
    "A three-seed stress pilot cannot select an anchor rate or authorize confirmation."
  )
  invisible(TRUE)
}

mfrmr_rass_summary <- function(results) {
  groups <- split(seq_len(nrow(results)), interaction(
    results$DesignId, results$AnchorConfig, drop = TRUE
  ))
  rows <- lapply(groups, function(index) {
    data <- results[index, , drop = FALSE]
    finite_mean <- function(x) {
      x <- x[is.finite(x)]
      if (length(x) > 0L) mean(x) else NA_real_
    }
    data.frame(
      DesignId = data$DesignId[[1L]],
      AnchorConfig = data$AnchorConfig[[1L]],
      AnchorRate = data$AnchorRate[[1L]],
      Planned = nrow(data),
      FitReturned = sum(data$FitReturned),
      InferenceReady = sum(data$InferenceReady),
      MeanFreeRaterAbsoluteRMSE = finite_mean(data$FreeRaterAbsoluteRMSE),
      MeanPersonAbsoluteRMSE = finite_mean(data$PersonAbsoluteRMSE),
      MeanRaterRankSpearman = finite_mean(data$RaterRankSpearman),
      MeanFreeRaterRMSEDeltaVsNone = finite_mean(
        data$FreeRaterRMSEDeltaVsNone
      ),
      MeanPersonRMSEDeltaVsNone = finite_mean(data$PersonRMSEDeltaVsNone),
      MeanElapsedSeconds = finite_mean(data$FitElapsedSeconds),
      AppropriateAnchorRateSelected = FALSE,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  designs <- mfrmr_rass_design_registry()$DesignId
  anchors <- mfrmr_rass_anchor_registry()$AnchorConfig
  out <- out[order(
    match(out$DesignId, designs), match(out$AnchorConfig, anchors)
  ), , drop = FALSE]
  row.names(out) <- NULL
  out
}

mfrmr_rass_evidence_hash <- function(results) {
  mfrmr_rass_require_support()
  payload <- results[, setdiff(names(results), "FitElapsedSeconds"), drop = FALSE]
  digest::digest(payload, algo = "sha256")
}

mfrmr_rass_summary_hash <- function(summary) {
  mfrmr_rass_require_support()
  payload <- summary[, setdiff(names(summary), "MeanElapsedSeconds"), drop = FALSE]
  digest::digest(payload, algo = "sha256")
}

mfrmr_run_rater_anchor_sparse_stress <- function(
    profile = c("smoke", "pilot"), execute = TRUE, progress = interactive()) {
  profile <- match.arg(profile)
  manifest <- mfrmr_rass_manifest(profile)
  if (!isTRUE(execute)) {
    return(list(
      Specification = mfrmr_rass_specification,
      Contract = mfrmr_rass_contract,
      manifest = manifest, results = data.frame(), summary = data.frame(),
      CalibrationOnly = TRUE,
      AppropriateAnchorRateSelected = FALSE,
      BroadSimulationAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ))
  }
  rows <- vector("list", nrow(manifest))
  cursor <- 0L
  for (seed in unique(manifest$Seed)) {
    generated <- mfrmr_rass_generate_complete(seed)
    seed_rows <- manifest[manifest$Seed == seed, , drop = FALSE]
    for (design_id in unique(seed_rows$DesignId)) {
      design_row <- seed_rows[seed_rows$DesignId == design_id, , drop = FALSE]
      designed <- mfrmr_rass_apply_design(generated, design_row[1L, ])
      for (i in seq_len(nrow(design_row))) {
        cursor <- cursor + 1L
        if (isTRUE(progress)) {
          message("[", cursor, "/", nrow(manifest), "] ",
                  design_row$ScenarioId[[i]])
        }
        rows[[cursor]] <- mfrmr_rass_run_one(
          design_row[i, , drop = FALSE], generated, designed
        )
      }
    }
  }
  results <- do.call(rbind, rows)
  row.names(results) <- NULL
  results <- mfrmr_rass_add_paired_deltas(results)
  mfrmr_rass_validate_results(results, manifest)
  summary <- mfrmr_rass_summary(results)
  list(
    Specification = mfrmr_rass_specification,
    Contract = mfrmr_rass_contract,
    manifest = manifest,
    results = results,
    summary = summary,
    EvidenceSHA256 = mfrmr_rass_evidence_hash(results),
    SummarySHA256 = mfrmr_rass_summary_hash(summary),
    CalibrationOnly = TRUE,
    AppropriateAnchorRateSelected = FALSE,
    BroadSimulationAuthorized = FALSE,
    ConfirmationAuthorized = FALSE
  )
}
