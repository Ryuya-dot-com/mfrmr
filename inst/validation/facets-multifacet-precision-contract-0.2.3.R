# Repository-only prospective FACETS multifacet and displayed-precision contract.
#
# This file does not execute FACETS and does not authorize an equivalence
# claim. It separates facet-dimension growth, level growth, row growth, and
# sparse topology before a licensed external run is attempted.

mfrmr_facets_mfp_contract_id <- "mfrmr_facets_multifacet_precision_v1"

mfrmr_facets_mfp_or <- function(x, y) {
  if (is.null(x) || length(x) == 0L) y else x
}

mfrmr_facets_mfp_registry <- function() {
  scenarios <- data.frame(
    ScenarioId = c(
      "MF-DIM-F3-FIXED-INFO",
      "MF-DIM-F4-FIXED-INFO",
      "MF-DIM-F5-FIXED-INFO",
      "MF-LEVEL-F5",
      "MF-LARGE-F5",
      "MF-SPARSE-DISTRIBUTED-F5",
      "MF-SPARSE-WEAK-BRIDGE-F5",
      "MF-DISCONNECTED-F5"
    ),
    TotalFacets = c(3L, 4L, 5L, 5L, 5L, 5L, 5L, 5L),
    NonPersonFacets = c(2L, 3L, 4L, 4L, 4L, 4L, 4L, 4L),
    FacetNames = c(
      "Rater;Criterion",
      "Rater;Task;Criterion",
      "Rater;Task;Occasion;Criterion",
      "Rater;Task;Occasion;Criterion",
      "Rater;Task;Occasion;Criterion",
      "Rater;Task;Occasion;Criterion",
      "Rater;Task;Occasion;Criterion",
      "Rater;Task;Occasion;Criterion"
    ),
    LevelCounts = c(
      "8;6", "8;4;6", "8;4;3;6", "20;8;4;10",
      "20;8;4;10", "20;8;4;10", "20;8;4;10", "20;8;4;10"
    ),
    Persons = c(300L, 300L, 300L, 300L, 1000L, 1000L, 1000L, 1000L),
    TargetRows = c(7200L, 7200L, 7200L, 12000L, 40000L, 20000L, 20000L, 20000L),
    InformationRegime = c(
      "fixed_rows_and_person_exposure",
      "fixed_rows_and_person_exposure",
      "fixed_rows_and_person_exposure",
      "level_growth_fixed_persons",
      "person_and_row_growth",
      "large_sparse_distributed",
      "large_sparse_weak_bridge",
      "large_disconnected_negative_control"
    ),
    Topology = c(
      "balanced_rotation", "balanced_rotation", "balanced_rotation",
      "balanced_rotation", "balanced_rotation", "distributed_connected",
      "two_blocks_few_link_persons", "two_disconnected_components"
    ),
    ComparisonRole = c(
      rep("dimension_growth", 3L), "level_growth", "capacity_growth",
      "sparse_recovery", "weak_link_review", "false_ready_negative_control"
    ),
    ExternalDisposition = c(
      rep("eligible_after_contract_checks", 6L),
      "review_only_until_information_rule_frozen",
      "ineligible_numeric_negative_control"
    ),
    stringsAsFactors = FALSE
  )
  out <- merge(
    scenarios,
    data.frame(Model = c("RSM", "PCM"), stringsAsFactors = FALSE),
    all = TRUE
  )
  out <- out[order(match(out$ScenarioId, scenarios$ScenarioId), out$Model), , drop = FALSE]
  rownames(out) <- NULL
  out$StepFacet <- ifelse(out$Model == "PCM", "Criterion", "Common")
  out$Method <- "JML"
  out$FACETSExecutionRequired <- TRUE
  out$CandidateLinkedRequired <- TRUE
  out$DisjointConfirmationSeedsRequired <- TRUE
  out$ReplicationState <- "must_be_frozen_by_EXT-FACETS-MCSE"
  out$ScientificByteEqualityRequired <- FALSE
  out$RequestedMeasureDecimals <- 8L
  out$RequestedResidualDecimals <- 8L
  out$HighPrecisionOutputRequired <- TRUE
  out$ActualPrecisionProbeRequired <- TRUE
  out$MetricSpecificPrecisionRequired <- TRUE
  out$ReportedNumericTokensRequired <- TRUE
  out$ZSTDDisplayEqualityPolicy <- "display_boundary_indeterminate"
  out$FixedPrecisionFallback <- "retain_raw_token_and_boundary_indeterminate"
  out
}

mfrmr_facets_mfp_validate_registry <- function(registry = mfrmr_facets_mfp_registry()) {
  required <- c(
    "ScenarioId", "Model", "TotalFacets", "NonPersonFacets", "FacetNames",
    "LevelCounts", "Persons", "TargetRows", "InformationRegime", "Topology",
    "ComparisonRole", "ExternalDisposition", "StepFacet", "Method",
    "FACETSExecutionRequired", "CandidateLinkedRequired",
    "DisjointConfirmationSeedsRequired", "ReplicationState",
    "ScientificByteEqualityRequired", "RequestedMeasureDecimals",
    "RequestedResidualDecimals", "HighPrecisionOutputRequired",
    "ActualPrecisionProbeRequired", "MetricSpecificPrecisionRequired",
    "ReportedNumericTokensRequired", "ZSTDDisplayEqualityPolicy",
    "FixedPrecisionFallback"
  )
  missing <- setdiff(required, names(registry))
  if (length(missing) > 0L) {
    stop("FACETS multifacet registry is missing: ", paste(missing, collapse = ", "),
         ".", call. = FALSE)
  }
  key <- paste(registry$ScenarioId, registry$Model, sep = "::")
  checks <- c(
    nrow(registry) == 16L,
    !anyDuplicated(key),
    identical(sort(unique(registry$Model)), c("PCM", "RSM")),
    identical(sort(unique(registry$TotalFacets)), 3:5),
    all(registry$NonPersonFacets == registry$TotalFacets - 1L),
    all(registry$Method == "JML"),
    all(registry$StepFacet[registry$Model == "PCM"] == "Criterion"),
    all(registry$FACETSExecutionRequired),
    all(registry$CandidateLinkedRequired),
    all(registry$DisjointConfirmationSeedsRequired),
    all(!registry$ScientificByteEqualityRequired),
    all(registry$RequestedMeasureDecimals == 8L),
    all(registry$RequestedResidualDecimals == 8L),
    all(registry$HighPrecisionOutputRequired),
    all(registry$ActualPrecisionProbeRequired),
    all(registry$MetricSpecificPrecisionRequired),
    all(registry$ReportedNumericTokensRequired),
    all(registry$ZSTDDisplayEqualityPolicy == "display_boundary_indeterminate"),
    all(registry$FixedPrecisionFallback ==
          "retain_raw_token_and_boundary_indeterminate")
  )
  if (!all(checks)) {
    stop("FACETS multifacet registry failed its structural contract.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_facets_mfp_precision_requirements <- function() {
  data.frame(
    Metric = c(
      "Measure", "SE", "InfitMnSq", "OutfitMnSq", "InfitZSTD",
      "OutfitZSTD", "DF"
    ),
    RequestedDecimalsWhereConfigurable = c(
      8L, 8L, NA_integer_, NA_integer_, NA_integer_, NA_integer_, NA_integer_
    ),
    ConfigurationRoute = c(
      "Udecim=8", "Udecim=8",
      rep("no_documented_Udecim_control_probe_actual_output", 5L)
    ),
    ActualReportedDecimalsRequired = TRUE,
    BoundaryFallback = c(
      rep("not_applicable", 4L),
      "display_equality_indeterminate",
      "display_equality_indeterminate",
      "not_applicable"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_facets_mfp_precision_review <- function(facets_table) {
  x <- as.data.frame(facets_table, stringsAsFactors = FALSE)
  required <- c(
    "Facet", "Level", "InfitZSTDRaw", "OutfitZSTDRaw",
    "InfitZSTDReportedDecimals", "OutfitZSTDReportedDecimals",
    "ZSTDDisplayFlagState", "SourcePrecisionStatus"
  )
  missing <- setdiff(required, names(x))
  if (length(missing) > 0L) {
    stop(
      "FACETS precision review requires token-preserving import columns: ",
      paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }
  reported <- as.character(x$SourcePrecisionStatus) == "reported_tokens_retained"
  boundary <- as.character(x$ZSTDDisplayFlagState) ==
    "display_boundary_indeterminate"
  invalid <- as.character(x$ZSTDDisplayFlagState) == "invalid_reported_token"
  classifiable <- as.character(x$ZSTDDisplayFlagState) %in% c(
    "display_below_threshold", "display_above_threshold"
  )
  data.frame(
    Rows = nrow(x),
    ReportedTokenRows = sum(reported, na.rm = TRUE),
    NumericOnlyRows = sum(!reported, na.rm = TRUE),
    ZSTDBoundaryRows = sum(boundary, na.rm = TRUE),
    InvalidTokenRows = sum(invalid, na.rm = TRUE),
    ThresholdClassifiableRows = sum(reported & classifiable, na.rm = TRUE),
    ThresholdAgreementEligible = all(reported) && all(classifiable),
    HiddenValueEqualityClaimAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_facets_mfp_display_resolution <- function(reported_token, mfrmr_value) {
  token <- trimws(as.character(reported_token))
  value <- suppressWarnings(as.numeric(token))
  valid <- !is.na(token) & grepl(
    "^[+-]?([0-9]+(\\.[0-9]*)?|\\.[0-9]+)$",
    token
  ) & is.finite(value)
  decimals <- rep(NA_integer_, length(token))
  has_decimal <- valid & grepl(".", token, fixed = TRUE)
  decimals[valid & !has_decimal] <- 0L
  decimals[has_decimal] <- nchar(sub("^[^.]*\\.", "", token[has_decimal]))
  unit <- ifelse(valid, 10^(-decimals), NA_real_)
  mfrmr_value <- suppressWarnings(as.numeric(mfrmr_value))
  if (length(mfrmr_value) != length(token)) {
    stop("`reported_token` and `mfrmr_value` must have equal lengths.", call. = FALSE)
  }
  difference <- abs(mfrmr_value - value)
  finite_pair <- valid & is.finite(mfrmr_value)
  status <- rep("not_comparable", length(token))
  status[finite_pair & difference <= unit] <- "within_one_displayed_unit"
  status[finite_pair & difference > unit] <- "outside_one_displayed_unit"
  data.frame(
    ReportedToken = token,
    ReportedValue = value,
    ReportedDecimals = decimals,
    DisplayedUnit = unit,
    MFRMRValue = mfrmr_value,
    AbsoluteDifference = difference,
    DifferenceInDisplayedUnits = difference / unit,
    DisplayResolutionStatus = status,
    RoundingRuleAssumed = FALSE,
    HiddenValueEqualityClaimAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_facets_mfp_smoke_design <- function(total_facets = 3L,
                                           model = c("RSM", "PCM"),
                                           seed = 451001L) {
  model <- match.arg(model)
  total_facets <- as.integer(total_facets)
  if (!total_facets %in% 3:5) {
    stop("`total_facets` must be 3, 4, or 5 including Person.", call. = FALSE)
  }
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (had_seed) old_seed <- get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  on.exit({
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)
  set.seed(seed)
  persons <- sprintf("P%03d", seq_len(40L))
  facet_levels <- list(
    Rater = sprintf("R%02d", seq_len(4L)),
    Task = sprintf("T%02d", seq_len(3L)),
    Occasion = sprintf("O%02d", seq_len(2L)),
    Criterion = sprintf("C%02d", seq_len(4L))
  )
  facet_names <- switch(
    as.character(total_facets),
    `3` = c("Rater", "Criterion"),
    `4` = c("Rater", "Task", "Criterion"),
    `5` = c("Rater", "Task", "Occasion", "Criterion")
  )
  # Sixteen rows exhaust the 4 x 4 Rater-by-Criterion pairs once per Person.
  # Added Task/Occasion facets are assigned within those same rows so that
  # facet-dimension growth is not confounded with duplicated cells or more
  # Person exposure.
  rows_per_person <- 16L
  grid <- expand.grid(
    PersonIndex = seq_along(persons),
    Slot = 0:(rows_per_person - 1L),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  grid$Person <- persons[grid$PersonIndex]
  grid$Rater <- facet_levels$Rater[
    ((grid$PersonIndex + grid$Slot %/% 4L - 2L) %% length(facet_levels$Rater)) + 1L
  ]
  grid$Criterion <- facet_levels$Criterion[
    (grid$Slot %% length(facet_levels$Criterion)) + 1L
  ]
  if ("Task" %in% facet_names) {
    grid$Task <- facet_levels$Task[
      ((grid$PersonIndex + grid$Slot %/% 4L - 2L) %% length(facet_levels$Task)) + 1L
    ]
  }
  if ("Occasion" %in% facet_names) {
    grid$Occasion <- facet_levels$Occasion[
      ((grid$PersonIndex + grid$Slot %/% 12L - 2L) %% length(facet_levels$Occasion)) + 1L
    ]
  }
  truth <- list(
    Person = stats::setNames(stats::rnorm(length(persons), 0, 0.9), persons),
    Rater = stats::setNames(seq(-0.45, 0.45, length.out = 4L), facet_levels$Rater),
    Task = stats::setNames(seq(-0.25, 0.25, length.out = 3L), facet_levels$Task),
    Occasion = stats::setNames(c(-0.15, 0.15), facet_levels$Occasion),
    Criterion = stats::setNames(seq(-0.35, 0.35, length.out = 4L), facet_levels$Criterion)
  )
  eta <- truth$Person[grid$Person]
  for (facet in facet_names) eta <- eta - truth[[facet]][grid[[facet]]]
  base_steps <- c(-0.8, 0, 0.8)
  pcm_shift <- stats::setNames(seq(-0.18, 0.18, length.out = 4L), facet_levels$Criterion)
  probs <- matrix(NA_real_, nrow(grid), 4L)
  for (i in seq_len(nrow(grid))) {
    steps <- if (identical(model, "RSM")) {
      base_steps
    } else {
      centered <- base_steps + c(-1, 0, 1) * pcm_shift[grid$Criterion[i]]
      centered - mean(centered)
    }
    log_num <- 0:3 * eta[i] - c(0, cumsum(steps))
    log_num <- log_num - max(log_num)
    probs[i, ] <- exp(log_num) / sum(exp(log_num))
  }
  u <- stats::runif(nrow(grid))
  grid$Score <- vapply(seq_len(nrow(grid)), function(i) {
    which(u[i] <= cumsum(probs[i, ]))[1L] - 1L
  }, integer(1))
  data <- grid[, c("Person", facet_names, "Score"), drop = FALSE]
  truth$Steps <- if (identical(model, "RSM")) {
    data.frame(
      Step = paste0("Step_", seq_along(base_steps)),
      Estimate = base_steps,
      stringsAsFactors = FALSE
    )
  } else {
    do.call(rbind, lapply(facet_levels$Criterion, function(level) {
      centered <- base_steps + c(-1, 0, 1) * pcm_shift[level]
      centered <- centered - mean(centered)
      data.frame(
        StepFacet = level,
        Step = paste0("Step_", seq_along(centered)),
        Estimate = centered,
        stringsAsFactors = FALSE
      )
    }))
  }
  list(
    data = data,
    truth = truth,
    facet_names = facet_names,
    model = model,
    total_facets = total_facets,
    seed = as.integer(seed)
  )
}

mfrmr_facets_mfp_recovery <- function(fit, design) {
  person <- as.data.frame(fit$facets$person, stringsAsFactors = FALSE)
  person_id <- as.character(person$Person)
  person_truth <- as.numeric(design$truth$Person[person_id])
  person_estimate <- as.numeric(person$Estimate)
  person_ok <- is.finite(person_truth) & is.finite(person_estimate)
  person_rmse <- if (any(person_ok)) {
    sqrt(mean((person_estimate[person_ok] - person_truth[person_ok])^2))
  } else NA_real_

  others <- as.data.frame(fit$facets$others, stringsAsFactors = FALSE)
  facet_rmse <- stats::setNames(rep(NA_real_, 4L),
                                c("Rater", "Task", "Occasion", "Criterion"))
  for (facet in intersect(design$facet_names, names(facet_rmse))) {
    rows <- others$Facet == facet
    estimate <- as.numeric(others$Estimate[rows])
    truth <- as.numeric(design$truth[[facet]][as.character(others$Level[rows])])
    ok <- is.finite(estimate) & is.finite(truth)
    if (any(ok)) facet_rmse[facet] <- sqrt(mean((estimate[ok] - truth[ok])^2))
  }

  fitted_steps <- as.data.frame(fit$steps, stringsAsFactors = FALSE)
  truth_steps <- as.data.frame(design$truth$Steps, stringsAsFactors = FALSE)
  step_key <- function(x) {
    owner <- if ("StepFacet" %in% names(x)) as.character(x$StepFacet) else "Common"
    paste(owner, as.character(x$Step), sep = "::")
  }
  matched <- match(step_key(fitted_steps), step_key(truth_steps))
  step_estimate <- as.numeric(fitted_steps$Estimate)
  step_truth <- as.numeric(truth_steps$Estimate[matched])
  step_ok <- is.finite(step_estimate) & is.finite(step_truth)
  step_rmse <- if (any(step_ok)) {
    sqrt(mean((step_estimate[step_ok] - step_truth[step_ok])^2))
  } else NA_real_

  c(
    PersonRMSE = person_rmse,
    RaterRMSE = unname(facet_rmse["Rater"]),
    TaskRMSE = unname(facet_rmse["Task"]),
    OccasionRMSE = unname(facet_rmse["Occasion"]),
    CriterionRMSE = unname(facet_rmse["Criterion"]),
    StepRMSE = step_rmse
  )
}

mfrmr_facets_mfp_capture <- function(expr) {
  warnings <- character(0)
  value <- tryCatch(
    withCallingHandlers(
      expr,
      warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(e) e
  )
  list(
    value = if (inherits(value, "error")) NULL else value,
    error = if (inherits(value, "error")) conditionMessage(value) else NA_character_,
    warnings = unique(warnings)
  )
}

mfrmr_run_facets_mfp_internal_smoke <- function(maxit = 100L,
                                                 seed = 451001L) {
  fit_fun <- getExportedValue("mfrmr", "fit_mfrm")
  rows <- list()
  index <- 0L
  for (total_facets in 3:5) {
    for (model in c("RSM", "PCM")) {
      index <- index + 1L
      design <- mfrmr_facets_mfp_smoke_design(
        total_facets = total_facets,
        model = model,
        seed = as.integer(seed + match(model, c("RSM", "PCM")))
      )
      args <- list(
        data = design$data,
        person = "Person",
        facets = design$facet_names,
        score = "Score",
        rating_min = 0L,
        rating_max = 3L,
        model = model,
        method = "JML",
        maxit = as.integer(maxit)
      )
      if (identical(model, "PCM")) args$step_facet <- "Criterion"
      captured <- mfrmr_facets_mfp_capture(do.call(fit_fun, args))
      fit <- captured$value
      recovery <- if (is.null(fit)) {
        stats::setNames(rep(NA_real_, 6L), c(
          "PersonRMSE", "RaterRMSE", "TaskRMSE", "OccasionRMSE",
          "CriterionRMSE", "StepRMSE"
        ))
      } else {
        mfrmr_facets_mfp_recovery(fit, design)
      }
      summary_row <- if (is.null(fit)) data.frame() else {
        as.data.frame(fit$summary, stringsAsFactors = FALSE)
      }
      take <- function(name, default = NA) {
        if (nrow(summary_row) == 1L && name %in% names(summary_row)) {
          summary_row[[name]][1L]
        } else default
      }
      rows[[index]] <- data.frame(
        Model = model,
        TotalFacets = total_facets,
        NonPersonFacets = total_facets - 1L,
        FacetNames = paste(design$facet_names, collapse = ";"),
        Rows = nrow(design$data),
        FitReturned = !is.null(fit),
        EstimationConverged = isTRUE(take("Converged", FALSE)),
        InferenceReady = isTRUE(take("InferenceReady", FALSE)),
        FitReadiness = as.character(take("FitReadiness", NA_character_)),
        LogLik = as.numeric(take("LogLik", NA_real_)),
        PersonRMSE = unname(recovery["PersonRMSE"]),
        RaterRMSE = unname(recovery["RaterRMSE"]),
        TaskRMSE = unname(recovery["TaskRMSE"]),
        OccasionRMSE = unname(recovery["OccasionRMSE"]),
        CriterionRMSE = unname(recovery["CriterionRMSE"]),
        StepRMSE = unname(recovery["StepRMSE"]),
        WarningCount = length(captured$warnings),
        Warnings = paste(captured$warnings, collapse = " | "),
        Error = captured$error,
        ExternalFACETSCompared = FALSE,
        PromotionAuthorized = FALSE,
        stringsAsFactors = FALSE
      )
    }
  }
  result <- do.call(rbind, rows)
  attr(result, "contract_id") <- mfrmr_facets_mfp_contract_id
  result
}

print.mfrmr_facets_mfp_contract <- function(x, ...) {
  cat("FACETS multifacet and displayed-precision contract\n")
  cat("Rows:", nrow(x$registry), "\n")
  cat("FACETS executed: no\n")
  cat("Scientific byte equality required: no\n")
  invisible(x)
}

mfrmr_facets_mfp_contract <- function() {
  registry <- mfrmr_facets_mfp_registry()
  mfrmr_facets_mfp_validate_registry(registry)
  out <- list(
    contract_id = mfrmr_facets_mfp_contract_id,
    registry = registry,
    decisions = data.frame(
      Area = c(
        "Facet count", "Facet levels", "Large data", "Sparse topology",
        "Requested precision", "Reported precision", "ZSTD threshold",
        "Scientific equality"
      ),
      Policy = c(
        "Vary total facets 3, 4, and 5 while holding rows and Person exposure fixed.",
        "Vary levels separately from the number of facet dimensions.",
        "Increase Persons and rows in a separate capacity stratum.",
        "Compare distributed, weak-bridge, and disconnected graphs separately.",
        "Request eight decimals for configurable FACETS measure and residual outputs.",
        "Retain exact FACETS numeric tokens and displayed decimal counts.",
        "Use boundary-indeterminate only when the actual ZSTD output remains fixed-precision at |ZSTD| = 2.",
        "Never require file-byte or hidden binary64 equality across machines."
      ),
      stringsAsFactors = FALSE
    ),
    precision_requirements = mfrmr_facets_mfp_precision_requirements(),
    authorization = data.frame(
      FACETSExecutionAuthorized = FALSE,
      NumericToleranceFrozen = FALSE,
      ReplicationFrozen = FALSE,
      ConfirmationAuthorized = FALSE,
      EquivalenceClaimAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  )
  class(out) <- c("mfrmr_facets_mfp_contract", "list")
  out
}
