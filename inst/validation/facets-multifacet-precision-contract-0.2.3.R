# Repository-only prospective FACETS multifacet and displayed-precision contract.
#
# External runners in this file are dry-run by default and require
# `execute = TRUE` for a licensed FACETS run. No route authorizes an
# equivalence claim. The contract separates facet-dimension growth, level
# growth, row growth, and sparse topology.

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

mfrmr_facets_mfp_write_external_case <- function(design,
                                                  model = c("RSM", "PCM"),
                                                  case_dir) {
  model <- match.arg(model)
  data <- as.data.frame(design$data, stringsAsFactors = FALSE)
  facet_names <- c("Person", as.character(design$facet_names))
  required <- c(facet_names, "Score")
  missing <- setdiff(required, names(data))
  if (length(missing) > 0L) {
    stop("External FACETS case is missing: ", paste(missing, collapse = ", "),
         ".", call. = FALSE)
  }
  if (anyDuplicated(facet_names) ||
      any(!grepl("^[A-Za-z][A-Za-z0-9_.-]*$", facet_names))) {
    stop("External FACETS facet names must be unique simple identifiers.",
         call. = FALSE)
  }
  score_values <- data$Score
  valid_scores <- is.numeric(score_values) && !anyNA(score_values) &&
    all(is.finite(score_values)) && all(score_values == floor(score_values)) &&
    identical(sort(unique(as.numeric(score_values))), as.numeric(0:3))
  if (!valid_scores) {
    stop("External qualification requires observed integer scores 0, 1, 2, 3.",
         call. = FALSE)
  }
  scores <- as.integer(score_values)
  case_dir <- normalizePath(case_dir, winslash = "/", mustWork = FALSE)
  if (dir.exists(case_dir) && length(list.files(case_dir, all.files = TRUE,
                                                no.. = TRUE)) > 0L) {
    stop("External FACETS case directory must be absent or empty: ", case_dir,
         ".", call. = FALSE)
  }
  dir.create(case_dir, recursive = TRUE, showWarnings = FALSE)

  level_maps <- lapply(facet_names, function(facet) {
    values <- unique(as.character(data[[facet]]))
    if (anyNA(values) || any(!nzchar(values)) ||
        any(!grepl("^[A-Za-z0-9_.-]+$", values))) {
      stop("External FACETS level labels must be nonmissing simple identifiers.",
           call. = FALSE)
    }
    stats::setNames(seq_along(values), values)
  })
  names(level_maps) <- facet_names
  encoded <- vapply(facet_names, function(facet) {
    unname(level_maps[[facet]][as.character(data[[facet]])])
  }, integer(nrow(data)))
  data_lines <- apply(cbind(encoded, Score = scores), 1L, paste, collapse = ",")

  data_path <- file.path(case_dir, "facets_data.txt")
  control_path <- file.path(case_dir, "facets_control.txt")
  report_path <- file.path(case_dir, "report.txt")
  score_base <- file.path(case_dir, "score.txt")
  residual_path <- file.path(case_dir, "residuals.txt")
  graph_path <- file.path(case_dir, "graph.txt")
  anchor_path <- file.path(case_dir, "anchor.anc")
  writeLines(data_lines, data_path, useBytes = TRUE)

  model_tokens <- rep("?", length(facet_names))
  if (identical(model, "PCM")) {
    criterion_index <- match("Criterion", facet_names)
    if (is.na(criterion_index)) {
      stop("PCM external qualification requires a Criterion facet.", call. = FALSE)
    }
    model_tokens[criterion_index] <- "#"
  }
  control <- c(
    paste0("Title = mfrmr FACETS multifacet qualification ", model),
    paste0("Facets = ", length(facet_names)),
    "Positive = 1",
    "Noncentered = 1",
    paste0("Models = ", paste(model_tokens, collapse = ","), ",R3"),
    "Umean = 0, 1, 8",
    "Tables = No",
    "CSV = CSV",
    "Heading lines = Yes",
    "QM = Double",
    "Iterations = 0",
    "Convergence = .01, .0001",
    paste0('Scorefiles = "', basename(score_base), '"'),
    paste0('Residualfile = "', basename(residual_path), '"'),
    paste0('Graphfile = "', basename(graph_path), '"'),
    paste0('Anchorfile = "', basename(anchor_path), '"'),
    "Labels ="
  )
  for (facet_index in seq_along(facet_names)) {
    facet <- facet_names[facet_index]
    labels <- names(level_maps[[facet]])
    control <- c(
      control,
      paste0(facet_index, ", ", facet),
      paste0(seq_along(labels), " = ", labels),
      "*"
    )
  }
  control <- c(
    control,
    paste0('Data = "', basename(data_path), '"')
  )
  writeLines(control, control_path, useBytes = TRUE)

  list(
    model = model,
    facet_names = facet_names,
    level_maps = level_maps,
    case_dir = case_dir,
    data_path = data_path,
    control_path = control_path,
    report_path = report_path,
    score_base = score_base,
    residual_path = residual_path,
    graph_path = graph_path,
    anchor_path = anchor_path
  )
}

mfrmr_facets_mfp_external_measure_comparison <- function(fit, external) {
  person <- as.data.frame(fit$facets$person, stringsAsFactors = FALSE)
  person_status <- if ("ParameterStatus" %in% names(person)) {
    as.character(person$ParameterStatus)
  } else rep("estimable", nrow(person))
  internal <- rbind(
    data.frame(
      Facet = "Person", Level = as.character(person$Person),
      Estimate = as.numeric(person$Estimate), Status = person_status,
      stringsAsFactors = FALSE
    ),
    transform(
      as.data.frame(fit$facets$others, stringsAsFactors = FALSE),
      Facet = as.character(Facet), Level = as.character(Level),
      Estimate = as.numeric(Estimate), Status = "estimable"
    )[, c("Facet", "Level", "Estimate", "Status"), drop = FALSE]
  )
  external <- as.data.frame(external, stringsAsFactors = FALSE)
  required <- c("Facet", "Level", "Estimate")
  if (!all(required %in% names(external))) {
    stop("External element comparison requires Facet, Level, and Estimate.",
         call. = FALSE)
  }
  matched <- merge(
    internal, external[, c("Facet", "Level", "Estimate")],
    by = c("Facet", "Level"), suffixes = c("_mfrmr", "_facets")
  )
  matched <- matched[
    matched$Status == "estimable" & is.finite(matched$Estimate_mfrmr) &
      is.finite(matched$Estimate_facets), , drop = FALSE
  ]
  if (nrow(matched) == 0L) {
    return(data.frame(
      Facet = character(0), Level = character(0),
      MfrmrEstimate = numeric(0), FACETSEstimate = numeric(0),
      Difference = numeric(0), AbsoluteDifference = numeric(0),
      stringsAsFactors = FALSE
    ))
  }
  difference <- matched$Estimate_mfrmr - matched$Estimate_facets
  data.frame(
    Facet = as.character(matched$Facet),
    Level = as.character(matched$Level),
    MfrmrEstimate = as.numeric(matched$Estimate_mfrmr),
    FACETSEstimate = as.numeric(matched$Estimate_facets),
    Difference = as.numeric(difference),
    AbsoluteDifference = abs(as.numeric(difference)),
    stringsAsFactors = FALSE
  )
}

mfrmr_facets_mfp_external_measure_metrics <- function(fit, external) {
  comparison <- mfrmr_facets_mfp_external_measure_comparison(fit, external)
  if (nrow(comparison) == 0L) return(data.frame())
  groups <- split(comparison, comparison$Facet)
  do.call(rbind, lapply(names(groups), function(facet) {
    x <- groups[[facet]]
    data.frame(
      Facet = facet,
      Matched = nrow(x),
      MAE = mean(x$AbsoluteDifference),
      MaximumAbsoluteDifference = max(x$AbsoluteDifference),
      MeanDifference = mean(x$Difference),
      stringsAsFactors = FALSE
    )
  }))
}

mfrmr_facets_mfp_fit_telemetry <- function(fit) {
  summary <- as.data.frame(fit$summary, stringsAsFactors = FALSE)
  take <- function(name, default) {
    if (nrow(summary) == 1L && name %in% names(summary)) {
      summary[[name]][1L]
    } else {
      default
    }
  }
  code <- as.integer(take("ConvergenceCode", NA_integer_))
  converged <- isTRUE(as.logical(take("Converged", FALSE)))
  gradient <- as.numeric(take("TerminalGradientSupNorm", NA_real_))
  tolerance <- as.numeric(take("GradientReviewTolerance", NA_real_))
  passed <- !is.na(code) && code == 0L && converged &&
    is.finite(gradient) && gradient >= 0 && is.finite(tolerance) &&
    tolerance > 0 && gradient <= tolerance
  data.frame(
    ConvergenceCode = code,
    EstimationConverged = converged,
    TerminalGradientSupNorm = gradient,
    GradientReviewTolerance = tolerance,
    NumericalGatePassed = passed,
    stringsAsFactors = FALSE
  )
}

mfrmr_facets_mfp_external_coordinate_contract <- function(design, external) {
  data <- as.data.frame(design$data, stringsAsFactors = FALSE)
  facet_names <- c("Person", as.character(design$facet_names))
  expected <- do.call(rbind, lapply(facet_names, function(facet) {
    data.frame(
      Facet = facet,
      Level = unique(as.character(data[[facet]])),
      stringsAsFactors = FALSE
    )
  }))
  observed <- unique(as.data.frame(external, stringsAsFactors = FALSE)[
    , c("Facet", "Level"), drop = FALSE
  ])
  expected_key <- sort(paste(expected$Facet, expected$Level, sep = "::"))
  observed_key <- sort(paste(observed$Facet, observed$Level, sep = "::"))
  duplicate_key_count <- sum(duplicated(paste(
    as.character(external$Facet), as.character(external$Level), sep = "::"
  )))
  list(
    passed = identical(expected_key, observed_key) && duplicate_key_count == 0L,
    expected_coordinates = length(expected_key),
    imported_coordinates = length(observed_key),
    duplicate_keys = duplicate_key_count,
    missing_keys = setdiff(expected_key, observed_key),
    unexpected_keys = setdiff(observed_key, expected_key)
  )
}

mfrmr_facets_mfp_score_files <- function(case_dir) {
  paths <- list.files(
    case_dir, pattern = "^score[.][0-9]+[.]txt$", full.names = TRUE
  )
  indices <- as.integer(sub(
    "^score[.]([0-9]+)[.]txt$", "\\1", basename(paths)
  ))
  paths[order(indices)]
}

mfrmr_facets_mfp_read_anchor_steps <- function(anchor_path, step_level_codes) {
  if (!file.exists(anchor_path)) {
    stop("FACETS anchor output was not found: ", anchor_path, ".",
         call. = FALSE)
  }
  level_names <- names(step_level_codes)
  valid_codes <- is.numeric(step_level_codes) && length(step_level_codes) > 0L &&
    !is.null(level_names) && !anyNA(step_level_codes) &&
    all(is.finite(step_level_codes)) &&
    all(step_level_codes == floor(step_level_codes)) &&
    all(step_level_codes > 0) && !anyDuplicated(step_level_codes) &&
    !anyNA(level_names) && all(nzchar(level_names)) && !anyDuplicated(level_names)
  if (!valid_codes) {
    stop("Step-level codes must be uniquely named positive integers.",
         call. = FALSE)
  }
  step_level_codes <- as.integer(step_level_codes)
  expected_scales <- paste0("RS", step_level_codes)
  lines <- trimws(readLines(anchor_path, warn = FALSE))
  header_pattern <-
    "^Rating \\(or partial credit\\) scale\\s*=\\s*"
  header_positions <- grep(header_pattern, lines)
  scale_ids <- sub(
    ",.*$", "",
    sub(header_pattern, "", lines[header_positions])
  )
  if (anyDuplicated(scale_ids)) {
    stop("FACETS anchor output contains duplicate rating-scale identifiers.",
         call. = FALSE)
  }
  if (!identical(sort(scale_ids), sort(expected_scales))) {
    stop(
      "FACETS anchor scale contract failed: expected ",
      paste(expected_scales, collapse = ", "), "; found ",
      paste(scale_ids, collapse = ", "), ".",
      call. = FALSE
    )
  }
  threshold_pattern <- "^;\\s*Rasch-Andrich Thresholds\\s*="
  rows <- lapply(seq_along(expected_scales), function(i) {
    scale_id <- expected_scales[i]
    header_index <- match(scale_id, scale_ids)
    block_start <- header_positions[header_index] + 1L
    block_end <- if (header_index < length(header_positions)) {
      header_positions[header_index + 1L] - 1L
    } else {
      length(lines)
    }
    threshold_lines <- lines[block_start:block_end]
    threshold_lines <- threshold_lines[grepl(threshold_pattern, threshold_lines)]
    if (length(threshold_lines) != 1L) {
      stop("FACETS anchor scale ", scale_id,
           " must contain exactly one Rasch-Andrich threshold line.",
           call. = FALSE)
    }
    tokens <- trimws(strsplit(
      sub(threshold_pattern, "", threshold_lines), ",", fixed = TRUE
    )[[1L]])
    valid_tokens <- grepl(
      "^[+-]?([0-9]+(\\.[0-9]*)?|\\.[0-9]+)$", tokens
    )
    if (length(tokens) != 4L || !all(valid_tokens)) {
      stop("FACETS anchor scale ", scale_id,
           " must report category 0 plus exactly three numeric thresholds.",
           call. = FALSE)
    }
    values <- as.numeric(tokens)
    if (!isTRUE(values[1L] == 0)) {
      stop("FACETS anchor scale ", scale_id,
           " must use zero as the category-0 placeholder.", call. = FALSE)
    }
    step_tokens <- tokens[-1L]
    resolution <- mfrmr_facets_mfp_display_resolution(
      step_tokens, rep(0, length(step_tokens))
    )
    data.frame(
      StepFacet = level_names[i],
      Step = paste0("Step_", seq_along(step_tokens)),
      Estimate = values[-1L],
      FACETSScale = scale_id,
      ReportedToken = step_tokens,
      ReportedDecimals = resolution$ReportedDecimals,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_facets_mfp_compare_steps <- function(fit, external_steps) {
  internal <- as.data.frame(fit$steps, stringsAsFactors = FALSE)
  external <- as.data.frame(external_steps, stringsAsFactors = FALSE)
  if (!"StepFacet" %in% names(internal)) internal$StepFacet <- "Common"
  required <- c("StepFacet", "Step", "Estimate")
  if (!all(required %in% names(internal)) ||
      !all(required %in% names(external))) {
    stop("Step comparison requires StepFacet, Step, and Estimate columns.",
         call. = FALSE)
  }
  internal_key <- paste(internal$StepFacet, internal$Step, sep = "::")
  external_key <- paste(external$StepFacet, external$Step, sep = "::")
  coordinate_passed <- !anyDuplicated(internal_key) &&
    !anyDuplicated(external_key) &&
    identical(sort(internal_key), sort(external_key))
  finite_passed <- all(is.finite(as.numeric(internal$Estimate))) &&
    all(is.finite(as.numeric(external$Estimate)))
  if (!coordinate_passed || !finite_passed) {
    return(list(
      passed = FALSE,
      expected_coordinates = length(internal_key),
      imported_coordinates = length(external_key),
      matched_coordinates = 0L,
      internal_duplicate_keys = sum(duplicated(internal_key)),
      external_duplicate_keys = sum(duplicated(external_key)),
      missing_keys = setdiff(internal_key, external_key),
      unexpected_keys = setdiff(external_key, internal_key),
      comparison = data.frame()
    ))
  }
  external <- external[match(internal_key, external_key), , drop = FALSE]
  difference <- as.numeric(internal$Estimate) - as.numeric(external$Estimate)
  comparison <- data.frame(
    StepFacet = as.character(internal$StepFacet),
    Step = as.character(internal$Step),
    MfrmrEstimate = as.numeric(internal$Estimate),
    FACETSEstimate = as.numeric(external$Estimate),
    Difference = difference,
    AbsoluteDifference = abs(difference),
    FACETSScale = if ("FACETSScale" %in% names(external)) {
      as.character(external$FACETSScale)
    } else {
      NA_character_
    },
    FACETSReportedToken = if ("ReportedToken" %in% names(external)) {
      as.character(external$ReportedToken)
    } else {
      NA_character_
    },
    stringsAsFactors = FALSE
  )
  list(
    passed = TRUE,
    expected_coordinates = length(internal_key),
    imported_coordinates = length(external_key),
    matched_coordinates = length(internal_key),
    internal_duplicate_keys = 0L,
    external_duplicate_keys = 0L,
    missing_keys = character(0),
    unexpected_keys = character(0),
    comparison = comparison
  )
}

mfrmr_facets_mfp_convergence_contract <- function(
    report_path,
    requested = c(0.01, 0.0001, 0, 0)) {
  empty_result <- function(reported_line = NA_character_) {
    list(
      passed = FALSE, specification_passed = FALSE, achieved = FALSE,
      values = numeric(0), reported_line = reported_line,
      final_iteration = NA_integer_, final_element_score_residual = NA_real_,
      final_element_logit_change = NA_real_, final_step_logit_change = NA_real_
    )
  }
  if (!file.exists(report_path)) {
    return(empty_result())
  }
  lines <- trimws(readLines(report_path, warn = FALSE))
  reported <- lines[grepl("^Convergence\\s*=", lines)]
  if (length(reported) != 1L) {
    return(empty_result(reported))
  }
  rhs <- trimws(sub("^Convergence\\s*=\\s*", "", reported))
  rhs <- trimws(sub(";.*$", "", rhs))
  tokens <- trimws(strsplit(rhs, ",", fixed = TRUE)[[1L]])
  valid_tokens <- grepl(
    "^[+-]?([0-9]+(\\.[0-9]*)?|\\.[0-9]+)$", tokens
  )
  if (length(tokens) != length(requested) || !all(valid_tokens)) {
    return(empty_result(reported))
  }
  values <- as.numeric(tokens)
  specification_passed <- isTRUE(all.equal(
    values, as.numeric(requested), tolerance = 1e-12, check.attributes = FALSE
  ))
  iteration_lines <- lines[grepl("^\\| JMLE", lines)]
  iteration_tokens <- if (length(iteration_lines)) {
    strsplit(trimws(gsub("^\\||\\|$", "", tail(iteration_lines, 1L))),
             "\\s+")[[1L]]
  } else {
    character(0)
  }
  iteration_numeric <- iteration_tokens[-1L]
  valid_iteration <- length(iteration_tokens) == 7L &&
    identical(iteration_tokens[1L], "JMLE") &&
    all(grepl("^[+-]?([0-9]+(\\.[0-9]*)?|\\.[0-9]+)$",
              iteration_numeric))
  final_values <- if (valid_iteration) {
    as.numeric(iteration_numeric)
  } else {
    rep(NA_real_, 6L)
  }
  achieved <- valid_iteration &&
    abs(final_values[2L]) <= requested[1L] &&
    abs(final_values[5L]) <= requested[2L] &&
    (requested[3L] == 0 || abs(final_values[4L]) <= requested[3L]) &&
    (requested[4L] == 0 || abs(final_values[6L]) <= requested[4L])
  list(
    passed = specification_passed && achieved,
    specification_passed = specification_passed,
    achieved = achieved,
    values = values,
    reported_line = reported,
    final_iteration = as.integer(final_values[1L]),
    final_element_score_residual = final_values[2L],
    final_element_logit_change = final_values[5L],
    final_step_logit_change = final_values[6L]
  )
}

mfrmr_facets_mfp_run_process <- function(
    facets_exe, case_dir, control_path, report_path, stdout_path,
    stderr_path, temp_dir) {
  facets_exe <- normalizePath(facets_exe, winslash = "/", mustWork = TRUE)
  case_dir <- normalizePath(case_dir, winslash = "/", mustWork = TRUE)
  if (!identical(.Platform$OS.type, "windows")) {
    old_dir <- getwd()
    on.exit(setwd(old_dir), add = TRUE)
    setwd(case_dir)
    return(system2(
      facets_exe,
      args = c("BATCH=YES", basename(control_path), basename(report_path)),
      stdout = stdout_path,
      stderr = stderr_path,
      env = c(paste0("TEMP=", temp_dir), paste0("TMP=", temp_dir),
              paste0("TMPDIR=", temp_dir))
    ))
  }

  powershell <- Sys.which("powershell")
  if (!nzchar(powershell)) {
    stop("Windows FACETS execution requires PowerShell.", call. = FALSE)
  }
  launcher_path <- file.path(case_dir, "facets_launch.ps1")
  writeLines(c(
    "param($FacetsExe, $CaseDir, $ControlName, $ReportName, $TempDir)",
    "$env:TEMP = $TempDir",
    "$env:TMP = $TempDir",
    "$env:TMPDIR = $TempDir",
    paste(
      "$process = Start-Process -FilePath $FacetsExe",
      "-ArgumentList @('BATCH=YES', $ControlName, $ReportName)",
      "-WorkingDirectory $CaseDir -Wait -PassThru -WindowStyle Hidden"
    ),
    "exit $process.ExitCode"
  ), launcher_path, useBytes = TRUE)
  system2(
    powershell,
    args = c(
      "-NoLogo", "-NoProfile", "-NonInteractive", "-ExecutionPolicy",
      "Bypass", "-File", shQuote(launcher_path), shQuote(facets_exe),
      shQuote(case_dir), shQuote(basename(control_path)),
      shQuote(basename(report_path)), shQuote(temp_dir)
    ),
    stdout = stdout_path,
    stderr = stderr_path
  )
}

mfrmr_facets_mfp_run_case_process <- function(
    facets_exe, case_dir, control_path, report_path, stdout_path,
    stderr_path) {
  temp_dir <- tempfile("mfrmr-facets-work-", tmpdir = tempdir())
  if (!dir.create(temp_dir, recursive = TRUE, showWarnings = FALSE)) {
    stop("Could not create the short FACETS work directory: ", temp_dir, ".",
         call. = FALSE)
  }
  on.exit(unlink(temp_dir, recursive = TRUE, force = TRUE), add = TRUE)
  mfrmr_facets_mfp_run_process(
    facets_exe = facets_exe,
    case_dir = case_dir,
    control_path = control_path,
    report_path = report_path,
    stdout_path = stdout_path,
    stderr_path = stderr_path,
    temp_dir = temp_dir
  )
}

mfrmr_run_facets_mfp_external_pilot <- function(
    facets_exe,
    work_dir,
    execute = FALSE,
    total_facets = 3:5,
    models = c("RSM", "PCM"),
    seed = 451001L,
    maxit = 100L,
    design_builder = NULL,
    retain_fit = FALSE) {
  if (!is.logical(execute) || length(execute) != 1L || is.na(execute)) {
    stop("`execute` must be one nonmissing logical value.", call. = FALSE)
  }
  if (!is.logical(retain_fit) || length(retain_fit) != 1L ||
      is.na(retain_fit)) {
    stop("`retain_fit` must be one nonmissing logical value.", call. = FALSE)
  }
  valid_seed <- is.numeric(seed) && length(seed) == 1L && !is.na(seed) &&
    is.finite(seed) && seed == floor(seed)
  if (!valid_seed) {
    stop("`seed` must be one finite integer.", call. = FALSE)
  }
  seed <- as.integer(seed)
  total_facets <- as.integer(total_facets)
  standard_design <- is.null(design_builder)
  if (!standard_design && !is.function(design_builder)) {
    stop("`design_builder` must be NULL or a function.", call. = FALSE)
  }
  valid_total_facets <- length(total_facets) > 0L && !anyNA(total_facets) &&
    all(is.finite(total_facets)) && all(total_facets == floor(total_facets)) &&
    !anyDuplicated(total_facets)
  if (!valid_total_facets ||
      (standard_design && any(!total_facets %in% 3:5)) ||
      (!standard_design && any(total_facets < 3L))) {
    stop(
      if (standard_design) {
        "External pilot total facets must be selected from 3, 4, and 5."
      } else {
        "Injected pilot designs require unique total-facet counts of at least 3."
      },
      call. = FALSE
    )
  }
  models <- match.arg(models, c("RSM", "PCM"), several.ok = TRUE)
  if (isTRUE(execute) && !file.exists(facets_exe)) {
    stop("FACETS executable was not found: ", facets_exe, ".", call. = FALSE)
  }
  work_dir <- normalizePath(work_dir, winslash = "/", mustWork = FALSE)
  if (dir.exists(work_dir) && length(list.files(work_dir, all.files = TRUE,
                                                no.. = TRUE)) > 0L) {
    stop("External pilot work directory must be absent or empty: ", work_dir,
         ".", call. = FALSE)
  }
  dir.create(work_dir, recursive = TRUE, showWarnings = FALSE)

  manifest_rows <- list()
  metric_rows <- list()
  element_comparison_rows <- list()
  step_comparison_rows <- list()
  fit_rows <- list()
  index <- 0L
  for (total in total_facets) {
    for (model in models) {
      index <- index + 1L
      design_seed <- seed + match(model, c("RSM", "PCM"))
      design <- if (standard_design) {
        mfrmr_facets_mfp_smoke_design(
          total_facets = total, model = model, seed = design_seed
        )
      } else {
        design_builder(
          total_facets = total, model = model, seed = design_seed
        )
      }
      valid_design <- is.list(design) && is.data.frame(design$data) &&
        is.character(design$facet_names) &&
        length(design$facet_names) == total - 1L &&
        identical(as.character(design$model), model) &&
        identical(as.integer(design$total_facets), total) &&
        is.numeric(design$seed) && length(design$seed) == 1L &&
        !is.na(design$seed) && is.finite(design$seed)
      if (!valid_design) {
        stop(
          "Injected FACETS design does not match its requested model, facet ",
          "count, data, or seed contract.", call. = FALSE
        )
      }
      case_dir <- file.path(work_dir, paste0(tolower(model), "-f", total))
      case <- mfrmr_facets_mfp_write_external_case(design, model, case_dir)
      process_status <- NA_integer_
      error <- NA_character_
      warning_text <- character(0)
      metrics <- data.frame()
      element_comparison <- data.frame()
      fit_returned <- FALSE
      mfrmr_error_class <- NA_character_
      mfrmr_convergence_code <- NA_integer_
      mfrmr_estimation_converged <- FALSE
      mfrmr_terminal_gradient_sup_norm <- NA_real_
      mfrmr_gradient_review_tolerance <- NA_real_
      mfrmr_numerical_gate_passed <- FALSE
      expected_coordinates <- sum(vapply(
        c("Person", design$facet_names),
        function(facet) length(unique(as.character(design$data[[facet]]))),
        integer(1)
      ))
      imported_coordinates <- NA_integer_
      matched_coordinates <- NA_integer_
      coordinate_contract_passed <- NA
      expected_step_coordinates <- if (identical(model, "PCM")) {
        3L * length(case$level_maps$Criterion)
      } else {
        3L
      }
      imported_step_coordinates <- NA_integer_
      matched_step_coordinates <- NA_integer_
      step_coordinate_contract_passed <- NA
      step_mae <- NA_real_
      step_maximum_absolute_difference <- NA_real_
      facets_convergence_specification_passed <- NA
      facets_convergence_achieved <- NA
      facets_convergence_contract_passed <- NA
      facets_reported_convergence_score_residual <- NA_real_
      facets_reported_convergence_logit_change <- NA_real_
      facets_final_iteration <- NA_integer_
      facets_final_element_score_residual <- NA_real_
      facets_final_element_logit_change <- NA_real_
      facets_final_step_logit_change <- NA_real_
      if (isTRUE(execute)) {
        stdout_path <- file.path(case_dir, "facets_stdout.txt")
        stderr_path <- file.path(case_dir, "facets_stderr.txt")
        process_status <- tryCatch(
          mfrmr_facets_mfp_run_case_process(
            facets_exe = facets_exe,
            case_dir = case_dir,
            control_path = case$control_path,
            report_path = case$report_path,
            stdout_path = stdout_path,
            stderr_path = stderr_path
          ),
          error = function(e) e
        )
        if (inherits(process_status, "error")) {
          error <- conditionMessage(process_status)
          process_status <- NA_integer_
        } else {
          process_status <- as.integer(process_status)
          if (!identical(process_status, 0L)) {
            error <- paste0("FACETS process returned code ", process_status, ".")
          }
        }
        if (identical(process_status, 0L)) {
          convergence_contract <- mfrmr_facets_mfp_convergence_contract(
            case$report_path
          )
          facets_convergence_specification_passed <-
            isTRUE(convergence_contract$specification_passed)
          facets_convergence_achieved <-
            isTRUE(convergence_contract$achieved)
          facets_convergence_contract_passed <-
            isTRUE(convergence_contract$passed)
          if (length(convergence_contract$values) >= 2L) {
            facets_reported_convergence_score_residual <-
              convergence_contract$values[1L]
            facets_reported_convergence_logit_change <-
              convergence_contract$values[2L]
          }
          facets_final_iteration <- convergence_contract$final_iteration
          facets_final_element_score_residual <-
            convergence_contract$final_element_score_residual
          facets_final_element_logit_change <-
            convergence_contract$final_element_logit_change
          facets_final_step_logit_change <-
            convergence_contract$final_step_logit_change
          if (!facets_convergence_contract_passed) {
            error <- paste0(
              "FACETS convergence contract failed: specification=",
              facets_convergence_specification_passed, ", achieved=",
              facets_convergence_achieved, ", final element score residual=",
              facets_final_element_score_residual, "."
            )
          }
        }
        if (identical(process_status, 0L) &&
            isTRUE(facets_convergence_contract_passed)) {
          score_files <- mfrmr_facets_mfp_score_files(case_dir)
          score_indices <- as.integer(sub(
            "^score[.]([0-9]+)[.]txt$", "\\1", basename(score_files)
          ))
          expected_score_indices <- seq_along(case$facet_names)
          if (!identical(score_indices, expected_score_indices)) {
            error <- paste0(
              "Expected FACETS score files indexed 1--",
              length(case$facet_names), "; found ",
              if (length(score_indices)) {
                paste(score_indices, collapse = ",")
              } else {
                "none"
              }, "."
            )
          } else {
            external <- getExportedValue("mfrmr", "read_facets_fit_table")(
              score_files,
              facet = case$facet_names
            )
            coordinate_contract <- mfrmr_facets_mfp_external_coordinate_contract(
              design, external
            )
            imported_coordinates <- coordinate_contract$imported_coordinates
            coordinate_contract_passed <- isTRUE(coordinate_contract$passed)
            if (!coordinate_contract_passed) {
              error <- paste0(
                "External coordinate contract failed: expected=",
                coordinate_contract$expected_coordinates,
                ", imported=", coordinate_contract$imported_coordinates,
                ", duplicate=", coordinate_contract$duplicate_keys,
                ", missing=", length(coordinate_contract$missing_keys),
                ", unexpected=", length(coordinate_contract$unexpected_keys), "."
              )
            } else {
              args <- list(
                data = design$data, person = "Person",
                facets = design$facet_names, score = "Score",
                rating_min = 0L, rating_max = 3L, model = model,
                method = "JML", maxit = as.integer(maxit)
              )
              if (identical(model, "PCM")) args$step_facet <- "Criterion"
              captured <- mfrmr_facets_mfp_capture(
                do.call(getExportedValue("mfrmr", "fit_mfrm"), args)
              )
              fit_returned <- !is.null(captured$value)
              warning_text <- captured$warnings
              if (is.null(captured$value)) {
                error <- captured$error
                mfrmr_error_class <- paste(captured$error_class, collapse = ";")
              } else {
                if (isTRUE(retain_fit)) fit_rows[[index]] <- captured$value
                telemetry <- mfrmr_facets_mfp_fit_telemetry(captured$value)
                mfrmr_convergence_code <- telemetry$ConvergenceCode
                mfrmr_estimation_converged <- telemetry$EstimationConverged
                mfrmr_terminal_gradient_sup_norm <-
                  telemetry$TerminalGradientSupNorm
                mfrmr_gradient_review_tolerance <-
                  telemetry$GradientReviewTolerance
                mfrmr_numerical_gate_passed <-
                  isTRUE(telemetry$NumericalGatePassed)
                if (!mfrmr_numerical_gate_passed) {
                  error <- paste0(
                    "mfrmr numerical gate failed: code=",
                    mfrmr_convergence_code, ", converged=",
                    mfrmr_estimation_converged, ", terminal gradient=",
                    mfrmr_terminal_gradient_sup_norm, ", tolerance=",
                    mfrmr_gradient_review_tolerance, "."
                  )
                } else {
                  metrics <- mfrmr_facets_mfp_external_measure_metrics(
                    captured$value, external
                  )
                  element_comparison <-
                    mfrmr_facets_mfp_external_measure_comparison(
                      captured$value, external
                    )
                  matched_coordinates <- sum(metrics$Matched)
                  if (nrow(metrics) != total ||
                      matched_coordinates != expected_coordinates ||
                      nrow(element_comparison) != expected_coordinates) {
                    error <- paste0(
                      "Matched-coordinate contract failed: blocks=",
                      nrow(metrics), "/", total, ", coordinates=",
                      matched_coordinates, "/", expected_coordinates, "."
                    )
                    metrics <- data.frame()
                  } else {
                    metrics$Model <- model
                    metrics$BaseSeed <- seed
                    metrics$DesignSeed <- design$seed
                    metrics$TotalFacets <- total
                    metrics$QualificationOnly <- TRUE
                    metrics$ToleranceFrozen <- FALSE
                    element_comparison$Model <- model
                    element_comparison$BaseSeed <- seed
                    element_comparison$DesignSeed <- design$seed
                    element_comparison$TotalFacets <- total
                    element_comparison$QualificationOnly <- TRUE
                    element_comparison$ToleranceFrozen <- FALSE
                    step_codes <- if (identical(model, "PCM")) {
                      case$level_maps$Criterion
                    } else {
                      c(Common = 1L)
                    }
                    captured_steps <- mfrmr_facets_mfp_capture(
                      mfrmr_facets_mfp_read_anchor_steps(
                        case$anchor_path, step_codes
                      )
                    )
                    warning_text <- c(warning_text, captured_steps$warnings)
                    if (is.null(captured_steps$value)) {
                      error <- captured_steps$error
                    } else {
                      step_contract <- mfrmr_facets_mfp_compare_steps(
                        captured$value, captured_steps$value
                      )
                      imported_step_coordinates <-
                        step_contract$imported_coordinates
                      matched_step_coordinates <-
                        step_contract$matched_coordinates
                      step_coordinate_contract_passed <-
                        isTRUE(step_contract$passed)
                      if (!step_coordinate_contract_passed) {
                        error <- paste0(
                          "Step-coordinate contract failed: expected=",
                          step_contract$expected_coordinates,
                          ", imported=", step_contract$imported_coordinates,
                          ", matched=", step_contract$matched_coordinates,
                          ", missing=", length(step_contract$missing_keys),
                          ", unexpected=",
                          length(step_contract$unexpected_keys), "."
                        )
                      } else {
                        step_comparison <- step_contract$comparison
                        step_mae <- mean(step_comparison$AbsoluteDifference)
                        step_maximum_absolute_difference <-
                          max(step_comparison$AbsoluteDifference)
                        step_comparison$Model <- model
                        step_comparison$BaseSeed <- seed
                        step_comparison$DesignSeed <- design$seed
                        step_comparison$TotalFacets <- total
                        step_comparison$QualificationOnly <- TRUE
                        step_comparison$ToleranceFrozen <- FALSE
                        step_comparison_rows[[index]] <- step_comparison
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      comparison_eligible <- isTRUE(facets_convergence_contract_passed) &&
        isTRUE(coordinate_contract_passed) &&
        isTRUE(step_coordinate_contract_passed) && fit_returned &&
        mfrmr_numerical_gate_passed &&
        is.na(error)
      manifest_rows[[index]] <- data.frame(
        Model = model,
        BaseSeed = seed,
        DesignSeed = design$seed,
        TotalFacets = total,
        NonPersonFacets = total - 1L,
        FacetNames = paste(design$facet_names, collapse = ";"),
        Rows = nrow(design$data),
        ExecuteRequested = isTRUE(execute),
        FACETSReturnCode = process_status,
        FACETSReportPresent = file.exists(case$report_path),
        MfrmrFitReturned = fit_returned,
        MfrmrErrorClass = mfrmr_error_class,
        MfrmrConvergenceCode = mfrmr_convergence_code,
        MfrmrEstimationConverged = mfrmr_estimation_converged,
        MfrmrTerminalGradientSupNorm = mfrmr_terminal_gradient_sup_norm,
        MfrmrGradientReviewTolerance = mfrmr_gradient_review_tolerance,
        MfrmrNumericalGatePassed = mfrmr_numerical_gate_passed,
        ExpectedCoordinates = expected_coordinates,
        ImportedCoordinates = imported_coordinates,
        MatchedCoordinates = matched_coordinates,
        CoordinateContractPassed = coordinate_contract_passed,
        ComparedFacetBlocks = nrow(metrics),
        ExpectedStepCoordinates = expected_step_coordinates,
        ImportedStepCoordinates = imported_step_coordinates,
        MatchedStepCoordinates = matched_step_coordinates,
        StepCoordinateContractPassed = step_coordinate_contract_passed,
        StepMAE = step_mae,
        StepMaximumAbsoluteDifference = step_maximum_absolute_difference,
        FACETSConvergenceRequested = "0.01,0.0001,0,0",
        FACETSReportedConvergenceScoreResidual =
          facets_reported_convergence_score_residual,
        FACETSReportedConvergenceLogitChange =
          facets_reported_convergence_logit_change,
        FACETSConvergenceSpecificationPassed =
          facets_convergence_specification_passed,
        FACETSConvergenceAchieved = facets_convergence_achieved,
        FACETSConvergenceContractPassed = facets_convergence_contract_passed,
        FACETSFinalIteration = facets_final_iteration,
        FACETSFinalElementScoreResidual = facets_final_element_score_residual,
        FACETSFinalElementLogitChange = facets_final_element_logit_change,
        FACETSFinalStepLogitChange = facets_final_step_logit_change,
        ComparisonEligible = comparison_eligible,
        Warnings = paste(unique(warning_text), collapse = " | "),
        Error = error,
        QualificationOnly = TRUE,
        ToleranceFrozen = FALSE,
        ConfirmationAuthorized = FALSE,
        EquivalenceClaimAuthorized = FALSE,
        stringsAsFactors = FALSE
      )
      if (comparison_eligible) {
        metric_rows[[index]] <- metrics
        element_comparison_rows[[index]] <- element_comparison
      }
    }
  }
  list(
    manifest = do.call(rbind, manifest_rows),
    metrics = if (length(metric_rows)) do.call(rbind, metric_rows) else data.frame(),
    element_comparisons = if (length(element_comparison_rows)) {
      do.call(rbind, element_comparison_rows)
    } else {
      data.frame()
    },
    step_comparisons = if (length(step_comparison_rows)) {
      do.call(rbind, step_comparison_rows)
    } else {
      data.frame()
    },
    fits = fit_rows,
    work_dir = work_dir,
    executed = isTRUE(execute),
    confirmation_authorized = FALSE,
    equivalence_claim_authorized = FALSE
  )
}

mfrmr_run_facets_mfp_external_multiseed_pilot <- function(
    facets_exe,
    work_dir,
    base_seeds,
    execute = FALSE,
    total_facets = 3:5,
    models = c("RSM", "PCM"),
    maxit = 100L) {
  valid_seeds <- is.numeric(base_seeds) && length(base_seeds) > 0L &&
    !anyNA(base_seeds) && all(is.finite(base_seeds)) &&
    all(base_seeds == floor(base_seeds)) && !anyDuplicated(base_seeds)
  if (!valid_seeds) {
    stop("`base_seeds` must contain unique finite integers.", call. = FALSE)
  }
  base_seeds <- as.integer(base_seeds)
  work_dir <- normalizePath(work_dir, winslash = "/", mustWork = FALSE)
  if (dir.exists(work_dir) && length(list.files(work_dir, all.files = TRUE,
                                                no.. = TRUE)) > 0L) {
    stop("External multiseed work directory must be absent or empty: ",
         work_dir, ".", call. = FALSE)
  }
  dir.create(work_dir, recursive = TRUE, showWarnings = FALSE)
  runs <- lapply(base_seeds, function(base_seed) {
    mfrmr_run_facets_mfp_external_pilot(
      facets_exe = facets_exe,
      work_dir = file.path(work_dir, paste0("seed-", base_seed)),
      execute = execute,
      total_facets = total_facets,
      models = models,
      seed = base_seed,
      maxit = maxit
    )
  })
  bind_component <- function(name) {
    components <- lapply(runs, `[[`, name)
    components <- components[vapply(components, nrow, integer(1)) > 0L]
    if (length(components)) do.call(rbind, components) else data.frame()
  }
  list(
    manifest = bind_component("manifest"),
    metrics = bind_component("metrics"),
    element_comparisons = bind_component("element_comparisons"),
    step_comparisons = bind_component("step_comparisons"),
    work_dir = work_dir,
    base_seeds = base_seeds,
    executed = isTRUE(execute),
    candidate_linked_pilot = TRUE,
    confirmation_authorized = FALSE,
    equivalence_claim_authorized = FALSE
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
    error_class = if (inherits(value, "error")) class(value) else character(0),
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
  cat("External precision qualification: completed for the three-facet core\n")
  cat("Fixed-information 3--5 facet qualification: completed for elements and steps\n")
  cat("Candidate-linked five-seed pilot: completed; confirmation: no\n")
  cat("Multifacet registry executed in FACETS: no\n")
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
        "JML convergence", "Requested precision", "Reported precision",
        "ZSTD threshold", "Scientific equality"
      ),
      Policy = c(
        "Vary total facets 3, 4, and 5 while holding rows and Person exposure fixed.",
        "Vary levels separately from the number of facet dimensions.",
        "Increase Persons and rows in a separate capacity stratum.",
        "Compare distributed, weak-bridge, and disconnected graphs separately.",
        "Verify both the echoed criteria and the final JMLE iteration; return code zero is insufficient.",
        "Request eight decimals for configurable FACETS measure and residual outputs.",
        "Retain exact FACETS numeric tokens and displayed decimal counts.",
        "Use boundary-indeterminate only when the actual ZSTD output remains fixed-precision at |ZSTD| = 2.",
        "Never require file-byte or hidden binary64 equality across machines."
      ),
      stringsAsFactors = FALSE
    ),
    precision_requirements = mfrmr_facets_mfp_precision_requirements(),
    authorization = data.frame(
      FACETSPrecisionQualificationCompleted = TRUE,
      FACETSFixedInformationDimensionQualificationCompleted = TRUE,
      FACETSStepCoordinateQualificationCompleted = TRUE,
      FACETSCandidateLinkedMultiseedPilotCompleted = TRUE,
      FACETSConfirmationDesignFrozen = TRUE,
      FACETSNumericalAcceptanceRuleFrozen = TRUE,
      FACETSConfirmationSemanticRunnerReady = TRUE,
      FACETSPilotExecutionAdapterImplemented = TRUE,
      FACETSStressEnvelopeImplemented = TRUE,
      MfrmrOpenedSeedStressPilotCompleted = TRUE,
      FACETSConfirmationExecutionAdapterImplemented = FALSE,
      FACETSConfirmationExecutionAuthorized = FALSE,
      FACETSStressRegistryExecutionCompleted = TRUE,
      FACETSRegistryExecutionCompleted = FALSE,
      FACETSExecutionAuthorized = FALSE,
      NumericToleranceFrozen = TRUE,
      ReplicationFrozen = TRUE,
      ConfirmationAuthorized = FALSE,
      EquivalenceClaimAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  )
  class(out) <- c("mfrmr_facets_mfp_contract", "list")
  out
}
