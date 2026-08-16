# Run-once ASP-G4M tranche-A live execution and retained numeric reconstruction.
#
# This file contains no top-level execution. Its positive path requires the G4L
# issuer, consumes that authority in the current process, runs a data-free
# sentinel in the exact incomplete staging root, generates all 90 datasets
# while the final target is absent, promotes the staging root once, and then
# executes the frozen 190-attempt plan without retry or result-driven ordering.

mfrmr_cq_ag4m_specification <-
  "0.2.3-conquest-adversarial-simulation-tranche-a-live-execution-v1"
mfrmr_cq_ag4m_contract <- paste0(
  "mfrmr_conquest_adversarial_simulation_tranche_a_",
  "live_execution_and_retained_reconstruction_v1"
)

mfrmr_cq_ag4m_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_ag4m_absent_path <- function(path) {
  path <- as.character(path)[1L]
  mfrmr_cq_ag4m_assert(
    !is.na(path) && nzchar(path), "G4M requires one nonempty output path."
  )
  parent <- normalizePath(dirname(path), winslash = "/", mustWork = TRUE)
  file.path(parent, basename(path))
}

mfrmr_cq_ag4m_contract_files <- function() {
  c(
    "conquest-semantic-runtime-preflight-0.2.3.R",
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-adversarial-simulation-program-0.2.3.R",
    "conquest-adversarial-simulation-template-contract-0.2.3.R",
    "conquest-adversarial-simulation-dgp-oracle-contract-0.2.3.R",
    "conquest-adversarial-simulation-smoke-authorization-0.2.3.R",
    "conquest-adversarial-simulation-smoke-execution-0.2.3.R",
    "conquest-adversarial-simulation-calibration-freeze-0.2.3.R",
    "conquest-adversarial-simulation-engine-mechanics-authorization-0.2.3.R",
    "conquest-adversarial-simulation-engine-mechanics-harness-0.2.3.R",
    "conquest-adversarial-simulation-post-mechanics-calibration-review-0.2.3.R",
    paste0(
      "conquest-adversarial-simulation-diagnostic-numeric-",
      "eligibility-addendum-0.2.3.R"
    ),
    "conquest-adversarial-simulation-tranche-a-authorization-review-0.2.3.R",
    "conquest-adversarial-simulation-calibration-harness-0.2.3.R",
    paste0(
      "conquest-adversarial-simulation-calibration-harness-engine-",
      "adapters-0.2.3.R"
    ),
    paste0(
      "conquest-adversarial-simulation-calibration-harness-",
      "finalization-0.2.3.R"
    ),
    paste0(
      "conquest-adversarial-simulation-tranche-a-live-",
      "authorization-0.2.3.R"
    )
  )
}

mfrmr_cq_ag4m_source_contracts <- function(source_root, target) {
  root <- normalizePath(source_root, winslash = "/", mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  paths <- file.path(validation, mfrmr_cq_ag4m_contract_files())
  mfrmr_cq_ag4m_assert(
    is.environment(target) && all(file.exists(paths)),
    "G4M requires the complete exact predecessor source set."
  )
  for (path in paths) sys.source(path, envir = target)
  invisible(paths)
}

mfrmr_cq_ag4m_require_contracts <- function() {
  target <- environment(mfrmr_cq_ag4m_require_contracts)
  required <- c(
    "mfrmr_cq_atla_issue", "mfrmr_cq_atla_review",
    "mfrmr_cq_ach_consume_authorization", "mfrmr_cq_ach_fresh_sentinel",
    "mfrmr_cq_ach_dataset_generation_authority",
    "mfrmr_cq_ach_generate_dataset", "mfrmr_cq_ach_adapter_plan",
    "mfrmr_cq_ach_generation_journal_template",
    "mfrmr_cq_ach_attempt_journal_template", "mfrmr_cq_ach_outcome_template",
    "mfrmr_cq_ach_representation_bridge_audit",
    "mfrmr_cq_ach_expected_artifact_registry",
    "mfrmr_cq_ach_artifact_inventory", "mfrmr_cq_ach_resource_state",
    "mfrmr_cq_ach_resource_controller", "mfrmr_cq_ach_execute",
    "mfrmr_cq_ach_readiness_evidence",
    "mfrmr_cq_ach_apply_diagnostic_eligibility",
    "mfrmr_cq_ach_finalize_outcomes", "mfrmr_cq_ach_metric_summary",
    "mfrmr_cq_ach_review_execution", "mfrmr_cq_ado_truth",
    "mfrmr_cq_ado_direct_probability", "mfrmr_cq_ado_person_integral",
    "mfrmr_cq_ameh_response_layout", "mfrmr_cq_ameh_write_csv",
    "mfrmr_cq_ameh_retained_bytes"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- exists(
    "mfrmr_cq_atla_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_atla_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_adversarial_simulation_tranche_a_live_authorization_freeze_v1"
  )
  mfrmr_cq_ag4m_assert(
    all(available) && identity,
    "Source the complete G4L and G4C-P4 contracts before G4M."
  )
  invisible(TRUE)
}

mfrmr_cq_ag4m_scalar_reduction_registry <- function() {
  data.frame(
    SummaryId = c(
      "ASP-PROBABILITY-TRUTH-ERROR",
      "ASP-CONTINUOUS-TARGET-ORACLE-ERROR",
      "ASP-PARAMETER-BIAS", "ASP-PARAMETER-RMSE",
      "ASP-CROSS-ENGINE-COORDINATE-DIFFERENCE",
      "ASP-QUADRATURE-SENSITIVITY",
      "ASP-REPRESENTATION-INVARIANCE",
      "ASP-ELAPSED-RUNTIME", "ASP-RETAINED-STORAGE"
    ),
    Measure = c(
      "maximum_absolute_probability_error_on_frozen_grid",
      "absolute_reported_to_continuous_deviance_difference",
      "mean_signed_full_coordinate_error",
      "full_coordinate_root_mean_square_error",
      "maximum_absolute_full_coordinate_difference",
      "maximum_absolute_full_coordinate_difference",
      "maximum_absolute_full_coordinate_difference",
      "elapsed_seconds", "retained_bytes"
    ),
    RetainedCompanionDetail = c(
      "every_theta_rater_criterion_category_probability",
      "continuous_deviance_and_declared_error_bound",
      "every_full_coordinate_signed_error",
      "every_full_coordinate_signed_error",
      "every_common_full_coordinate_difference",
      "every_common_full_coordinate_and_separate_deviance_difference",
      "every_common_full_coordinate_and_separate_deviance_difference",
      "one_row_per_attempt", "one_row_per_registered_artifact"
    ),
    ThresholdApplied = FALSE,
    ConfirmationUsePermitted = FALSE,
    PublicClaimPermitted = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ag4m_detail_template <- function() {
  data.frame(
    SummaryId = character(0), UnitId = character(0), Stratum = character(0),
    Measure = character(0), DetailId = character(0),
    Estimate = numeric(0), Reference = numeric(0), Difference = numeric(0),
    AbsoluteDifference = numeric(0), Value = numeric(0),
    ObservationState = character(0), IncludeInMetricSummary = logical(0),
    ThresholdApplied = logical(0), ConfirmationUsePermitted = logical(0),
    PublicClaimPermitted = logical(0), stringsAsFactors = FALSE
  )
}

mfrmr_cq_ag4m_detail_row <- function(
    summary_id, unit_id, stratum, measure, detail_id,
    estimate = NA_real_, reference = NA_real_, difference = NA_real_,
    value = NA_real_, state = "observed", include = FALSE) {
  difference <- as.numeric(difference)[1L]
  data.frame(
    SummaryId = as.character(summary_id)[1L],
    UnitId = as.character(unit_id)[1L],
    Stratum = as.character(stratum)[1L],
    Measure = as.character(measure)[1L],
    DetailId = as.character(detail_id)[1L],
    Estimate = as.numeric(estimate)[1L],
    Reference = as.numeric(reference)[1L],
    Difference = difference,
    AbsoluteDifference = if (is.finite(difference)) abs(difference) else NA_real_,
    Value = as.numeric(value)[1L],
    ObservationState = as.character(state)[1L],
    IncludeInMetricSummary = isTRUE(include),
    ThresholdApplied = FALSE,
    ConfirmationUsePermitted = FALSE,
    PublicClaimPermitted = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ag4m_rbind <- function(rows, template) {
  rows <- Filter(Negate(is.null), rows)
  if (length(rows) == 0L) return(template)
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_cq_ag4m_full_coordinate_names <- function(family) {
  family <- toupper(as.character(family)[1L])
  base <- c(
    "Population::Intercept", "Population::X", "Population::Variance",
    paste0("Rater::R", 1:4), paste0("Criterion::C", 1:3)
  )
  step <- if (family == "RSM") {
    paste0("Step::Shared::S", 1:3)
  } else {
    unlist(lapply(paste0("C", 1:3), function(criterion) {
      paste0("Step::", criterion, "::S", 1:3)
    }), use.names = FALSE)
  }
  c(base, step)
}

mfrmr_cq_ag4m_truth_coordinates <- function(profile_id, family) {
  truth <- mfrmr_cq_ado_truth(profile_id, family)
  value <- c(
    truth$PopulationIntercept, truth$PopulationSlope,
    truth$PopulationVariance, truth$Rater[paste0("R", 1:4)],
    truth$Criterion[paste0("C", 1:3)],
    if (truth$Family == "RSM") {
      truth$Steps[paste0("S", 1:3)]
    } else {
      unlist(lapply(paste0("C", 1:3), function(criterion) {
        truth$Steps[criterion, paste0("S", 1:3)]
      }), use.names = FALSE)
    }
  )
  names(value) <- mfrmr_cq_ag4m_full_coordinate_names(family)
  mfrmr_cq_ag4m_assert(
    all(is.finite(value)), "The G4M truth coordinate vector is incomplete."
  )
  value
}

mfrmr_cq_ag4m_read_csv <- function(path) {
  utils::read.csv(
    path, stringsAsFactors = FALSE, check.names = FALSE, na.strings = ""
  )
}

mfrmr_cq_ag4m_mfrmr_coordinates <- function(root, arm) {
  run_dir <- file.path(root, arm$RunDirectory)
  prefix <- arm$Prefix
  population <- mfrmr_cq_ag4m_read_csv(file.path(
    run_dir, paste0(prefix, "_mfrmr_population.csv")
  ))
  facet <- mfrmr_cq_ag4m_read_csv(file.path(
    run_dir, paste0(prefix, "_mfrmr_facets.csv")
  ))
  step <- mfrmr_cq_ag4m_read_csv(file.path(
    run_dir, paste0(prefix, "_mfrmr_steps.csv")
  ))
  summary <- mfrmr_cq_ag4m_read_csv(file.path(
    run_dir, paste0(prefix, "_mfrmr_summary.csv")
  ))
  pop <- stats::setNames(
    as.numeric(population$Estimate), as.character(population$Parameter)
  )
  facet_key <- paste(facet$Facet, facet$Level, sep = "::")
  facet_value <- stats::setNames(as.numeric(facet$Estimate), facet_key)
  value <- c(
    "Population::Intercept" = unname(pop["(Intercept)"]),
    "Population::X" = unname(pop["X"]),
    "Population::Variance" = unname(pop["sigma2"]),
    stats::setNames(
      unname(facet_value[
        paste("Rater", paste0("R", 1:4), sep = "::")
      ]),
      paste0("Rater::R", 1:4)
    ),
    stats::setNames(
      unname(facet_value[
        paste("Criterion", paste0("C", 1:3), sep = "::")
      ]),
      paste0("Criterion::C", 1:3)
    )
  )
  if (arm$Family == "RSM") {
    step_value <- stats::setNames(as.numeric(step$Estimate), step$Step)
    value <- c(value, stats::setNames(
      unname(step_value[paste0("Step_", 1:3)]),
      paste0("Step::Shared::S", 1:3)
    ))
  } else {
    key <- paste(step$StepFacet, step$Step, sep = "::")
    step_value <- stats::setNames(as.numeric(step$Estimate), key)
    expanded <- unlist(lapply(paste0("C", 1:3), function(criterion) {
      stats::setNames(
        unname(step_value[
          paste(criterion, paste0("Step_", 1:3), sep = "::")
        ]),
        paste0("Step::", criterion, "::S", 1:3)
      )
    }), use.names = TRUE)
    value <- c(value, expanded)
  }
  value <- value[mfrmr_cq_ag4m_full_coordinate_names(arm$Family)]
  deviance <- as.numeric(summary$Deviance[1L])
  mfrmr_cq_ag4m_assert(
    length(value) == length(mfrmr_cq_ag4m_full_coordinate_names(arm$Family)) &&
      all(is.finite(value)) && is.finite(deviance),
    paste0("The retained mfrmr coordinates are incomplete for `", arm$RunId, "`.")
  )
  list(coordinates = value, deviance = deviance)
}

mfrmr_cq_ag4m_conquest_coordinates_from_tables <- function(
    parameter, regression, covariance, history, family) {
  family <- toupper(as.character(family)[1L])
  label <- trimws(as.character(parameter$Label))
  estimate <- as.numeric(parameter$Estimate)
  extract <- function(pattern) estimate[grepl(pattern, label, perl = TRUE)]
  rater <- extract("^rater R[1-3]$")
  criterion <- extract("^criterion C[1-2]$")
  mfrmr_cq_ag4m_assert(
    length(rater) == 3L && length(criterion) == 2L,
    "The ConQuest facet export does not have the frozen free-coordinate shape."
  )
  rater <- c(rater, -sum(rater))
  criterion <- c(criterion, -sum(criterion))
  names(rater) <- paste0("Rater::R", 1:4)
  names(criterion) <- paste0("Criterion::C", 1:3)
  if (family == "RSM") {
    step <- extract("^category [12]$")
    mfrmr_cq_ag4m_assert(
      length(step) == 2L,
      "The ConQuest RSM step export does not have two free coordinates."
    )
    step <- c(step, -sum(step))
    names(step) <- paste0("Step::Shared::S", 1:3)
  } else {
    step <- unlist(lapply(paste0("C", 1:3), function(current) {
      selected <- extract(paste0("^criterion ", current, " category [12]$"))
      mfrmr_cq_ag4m_assert(
        length(selected) == 2L,
        paste0("The ConQuest PCM step export is incomplete for `", current, "`.")
      )
      stats::setNames(
        c(selected, -sum(selected)), paste0("Step::", current, "::S", 1:3)
      )
    }), use.names = TRUE)
  }
  value <- c(
    "Population::Intercept" = as.numeric(regression$Estimate[1L]),
    "Population::X" = as.numeric(regression$Estimate[2L]),
    "Population::Variance" = as.numeric(covariance$Covariance[1L]),
    rater, criterion, step
  )
  value <- value[mfrmr_cq_ag4m_full_coordinate_names(family)]
  deviance <- as.numeric(utils::tail(history$LogLikelihood, 1L))
  mfrmr_cq_ag4m_assert(
    all(is.finite(value)) && is.finite(deviance),
    "The retained ConQuest numeric export is incomplete or nonfinite."
  )
  list(coordinates = value, deviance = deviance)
}

mfrmr_cq_ag4m_conquest_coordinates <- function(root, arm) {
  run_dir <- file.path(root, arm$RunDirectory)
  prefix <- arm$Prefix
  read <- function(suffix) mfrmr_cq_ag4m_read_csv(
    file.path(run_dir, paste0(prefix, suffix))
  )
  mfrmr_cq_ag4m_conquest_coordinates_from_tables(
    read("_conquest_parameters.csv"),
    read("_conquest_reg_coefficients.csv"),
    read("_conquest_covariance.csv"),
    read("_conquest_history.csv"), arm$Family
  )
}

mfrmr_cq_ag4m_fit_coordinates <- function(root, arm) {
  if (arm$Engine == "mfrmr") {
    mfrmr_cq_ag4m_mfrmr_coordinates(root, arm)
  } else {
    mfrmr_cq_ag4m_conquest_coordinates(root, arm)
  }
}

mfrmr_cq_ag4m_coordinate_truth <- function(coordinate, profile_id, family) {
  truth <- mfrmr_cq_ado_truth(profile_id, family)
  truth$PopulationIntercept <- unname(coordinate["Population::Intercept"])
  truth$PopulationSlope <- unname(coordinate["Population::X"])
  truth$PopulationVariance <- unname(coordinate["Population::Variance"])
  truth$Rater <- stats::setNames(
    unname(coordinate[paste0("Rater::R", 1:4)]), paste0("R", 1:4)
  )
  truth$Criterion <- stats::setNames(
    unname(coordinate[paste0("Criterion::C", 1:3)]), paste0("C", 1:3)
  )
  if (family == "RSM") {
    truth$Steps <- stats::setNames(
      unname(coordinate[paste0("Step::Shared::S", 1:3)]), paste0("S", 1:3)
    )
  } else {
    truth$Steps <- t(vapply(paste0("C", 1:3), function(criterion) {
      unname(coordinate[paste0("Step::", criterion, "::S", 1:3)])
    }, numeric(3L)))
    rownames(truth$Steps) <- paste0("C", 1:3)
    colnames(truth$Steps) <- paste0("S", 1:3)
  }
  truth
}

mfrmr_cq_ag4m_stratum <- function(arm, include_engine = TRUE,
                                   include_nodes = TRUE) {
  value <- c(as.character(arm$ScenarioClassId), as.character(arm$Family))
  if (include_engine) value <- c(value, as.character(arm$Engine))
  if (include_nodes) value <- c(value, paste0("q", arm$Nodes))
  paste(value, collapse = "::")
}

mfrmr_cq_ag4m_probability_detail <- function(arm, fitted, profile_id) {
  truth <- mfrmr_cq_ado_truth(profile_id, arm$Family)
  fitted_truth <- mfrmr_cq_ag4m_coordinate_truth(
    fitted$coordinates, profile_id, arm$Family
  )
  grid <- expand.grid(
    Theta = c(-4, -2, -0.5, 0, 1, 3, 4),
    Rater = paste0("R", 1:4), Criterion = paste0("C", 1:3),
    Category = 0:3, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  difference <- vapply(seq_len(nrow(grid)), function(index) {
    fitted_probability <- mfrmr_cq_ado_direct_probability(
      fitted_truth, grid$Theta[index], grid$Rater[index], grid$Criterion[index]
    )[grid$Category[index] + 1L]
    truth_probability <- mfrmr_cq_ado_direct_probability(
      truth, grid$Theta[index], grid$Rater[index], grid$Criterion[index]
    )[grid$Category[index] + 1L]
    fitted_probability - truth_probability
  }, numeric(1L))
  unit <- sprintf("attempt:%03d", arm$AttemptOrder)
  stratum <- mfrmr_cq_ag4m_stratum(arm)
  detail <- lapply(seq_len(nrow(grid)), function(index) {
    mfrmr_cq_ag4m_detail_row(
      "ASP-PROBABILITY-TRUTH-ERROR", unit, stratum,
      "probability_cell_difference",
      paste(
        paste0("theta=", grid$Theta[index]), grid$Rater[index],
        grid$Criterion[index], paste0("category=", grid$Category[index]),
        sep = "::"
      ),
      difference = difference[index]
    )
  })
  detail[[length(detail) + 1L]] <- mfrmr_cq_ag4m_detail_row(
    "ASP-PROBABILITY-TRUTH-ERROR", unit, stratum,
    "maximum_absolute_probability_error_on_frozen_grid", "scalar_reduction",
    value = max(abs(difference)), include = TRUE
  )
  mfrmr_cq_ag4m_rbind(detail, mfrmr_cq_ag4m_detail_template())
}

mfrmr_cq_ag4m_continuous_detail <- function(
    root, arm, fitted, profile_id, response_data) {
  unit <- sprintf("attempt:%03d", arm$AttemptOrder)
  stratum <- mfrmr_cq_ag4m_stratum(arm)
  result <- tryCatch({
    input <- mfrmr_cq_ach_dataset_input(
      list(response_data = response_data),
      arm$DatasetId, arm$RepresentationId
    )$long
    input <- input[!is.na(input$Response), , drop = FALSE]
    fitted_truth <- mfrmr_cq_ag4m_coordinate_truth(
      fitted$coordinates, profile_id, arm$Family
    )
    by_person <- split(input, input$Person)
    detail <- do.call(rbind, lapply(by_person, function(person_data) {
      mfrmr_cq_ado_person_integral(person_data, fitted_truth, "direct")
    }))
    rownames(detail) <- NULL
    valid <- nrow(detail) == 48L &&
      all(detail$LeftMessage == "OK") && all(detail$RightMessage == "OK") &&
      all(detail$ModeInterior) && all(is.finite(detail$LogLikelihood)) &&
      all(is.finite(detail$TotalLogErrorBound))
    mfrmr_cq_ag4m_assert(
      valid, "The G4M fitted-coordinate continuous oracle did not converge."
    )
    continuous_deviance <- -2 * sum(detail$LogLikelihood)
    declared_bound <- 2 * sum(detail$TotalLogErrorBound)
    list(
      continuous_deviance = continuous_deviance,
      declared_bound = declared_bound,
      difference = fitted$deviance - continuous_deviance
    )
  }, error = function(error) error)
  if (inherits(result, "error")) {
    return(mfrmr_cq_ag4m_detail_row(
      "ASP-CONTINUOUS-TARGET-ORACLE-ERROR", unit, stratum,
      "continuous_oracle_unavailable", "metric_unavailable",
      state = paste0("blocked:", conditionMessage(result))
    ))
  }
  rbind(
    mfrmr_cq_ag4m_detail_row(
      "ASP-CONTINUOUS-TARGET-ORACLE-ERROR", unit, stratum,
      "absolute_reported_to_continuous_deviance_difference",
      "scalar_reduction", estimate = fitted$deviance,
      reference = result$continuous_deviance, difference = result$difference,
      value = abs(result$difference), include = TRUE
    ),
    mfrmr_cq_ag4m_detail_row(
      "ASP-CONTINUOUS-TARGET-ORACLE-ERROR", unit, stratum,
      "declared_continuous_deviance_error_bound", "oracle_error_bound",
      value = result$declared_bound
    )
  )
}

mfrmr_cq_ag4m_truth_recovery_detail <- function(
    arm, fitted, profile_id) {
  truth <- mfrmr_cq_ag4m_truth_coordinates(profile_id, arm$Family)
  difference <- fitted$coordinates[names(truth)] - truth
  unit <- sprintf("attempt:%03d", arm$AttemptOrder)
  stratum <- mfrmr_cq_ag4m_stratum(arm)
  coordinate_rows <- lapply(names(difference), function(coordinate) {
    rbind(
      mfrmr_cq_ag4m_detail_row(
        "ASP-PARAMETER-BIAS", unit, stratum, "full_coordinate_signed_error",
        coordinate, estimate = fitted$coordinates[coordinate],
        reference = truth[coordinate], difference = difference[coordinate]
      ),
      mfrmr_cq_ag4m_detail_row(
        "ASP-PARAMETER-RMSE", unit, stratum, "full_coordinate_signed_error",
        coordinate, estimate = fitted$coordinates[coordinate],
        reference = truth[coordinate], difference = difference[coordinate]
      )
    )
  })
  rbind(
    mfrmr_cq_ag4m_rbind(coordinate_rows, mfrmr_cq_ag4m_detail_template()),
    mfrmr_cq_ag4m_detail_row(
      "ASP-PARAMETER-BIAS", unit, stratum,
      "mean_signed_full_coordinate_error", "scalar_reduction",
      value = mean(difference), include = TRUE
    ),
    mfrmr_cq_ag4m_detail_row(
      "ASP-PARAMETER-RMSE", unit, stratum,
      "full_coordinate_root_mean_square_error", "scalar_reduction",
      value = sqrt(mean(difference^2)), include = TRUE
    )
  )
}

mfrmr_cq_ag4m_pair_detail <- function(
    summary_id, pair_id, left_arm, right_arm, left, right, stratum) {
  common <- intersect(names(left$coordinates), names(right$coordinates))
  mfrmr_cq_ag4m_assert(
    length(common) > 0L && setequal(common, names(left$coordinates)) &&
      setequal(common, names(right$coordinates)),
    paste0("G4M pair `", pair_id, "` has mismatched coordinate identities.")
  )
  difference <- left$coordinates[common] - right$coordinates[common]
  rows <- lapply(common, function(coordinate) {
    mfrmr_cq_ag4m_detail_row(
      summary_id, pair_id, stratum, "full_coordinate_difference", coordinate,
      estimate = left$coordinates[coordinate],
      reference = right$coordinates[coordinate],
      difference = difference[coordinate]
    )
  })
  if (summary_id %in% c(
      "ASP-QUADRATURE-SENSITIVITY", "ASP-REPRESENTATION-INVARIANCE")) {
    rows[[length(rows) + 1L]] <- mfrmr_cq_ag4m_detail_row(
      summary_id, pair_id, stratum, "separate_deviance_difference", "deviance",
      estimate = left$deviance, reference = right$deviance,
      difference = left$deviance - right$deviance
    )
  }
  rows[[length(rows) + 1L]] <- mfrmr_cq_ag4m_detail_row(
    summary_id, pair_id, stratum,
    "maximum_absolute_full_coordinate_difference", "scalar_reduction",
    value = max(abs(difference)), include = TRUE
  )
  mfrmr_cq_ag4m_rbind(rows, mfrmr_cq_ag4m_detail_template())
}

mfrmr_cq_ag4m_numeric_evidence <- function(
    root, plan, outcome, diagnostic_eligibility, response_data,
    dataset_manifest) {
  eligible <- diagnostic_eligibility$AttemptOrder[
    diagnostic_eligibility$DiagnosticNumericEligible
  ]
  attempt <- plan[plan$AttemptCap == 1L, , drop = FALSE]
  fitted <- list()
  for (order in eligible) {
    arm <- attempt[attempt$AttemptOrder == order, , drop = FALSE]
    fitted[[as.character(order)]] <- tryCatch(
      mfrmr_cq_ag4m_fit_coordinates(root, arm),
      error = function(error) error
    )
  }
  detail <- list()
  append_detail <- function(value) {
    detail[[length(detail) + 1L]] <<- value
  }
  primary <- attempt$PrimaryAnalysisRole & attempt$AttemptOrder %in% eligible
  for (index in which(primary)) {
    arm <- attempt[index, , drop = FALSE]
    current <- fitted[[as.character(arm$AttemptOrder)]]
    if (inherits(current, "error")) next
    manifest <- dataset_manifest[
      dataset_manifest$DatasetId == arm$DatasetId, , drop = FALSE
    ]
    mfrmr_cq_ag4m_assert(
      nrow(manifest) == 1L,
      "G4M numeric reconstruction requires one dataset manifest row."
    )
    append_detail(mfrmr_cq_ag4m_probability_detail(
      arm, current, manifest$ProfileId
    ))
    append_detail(mfrmr_cq_ag4m_continuous_detail(
      root, arm, current, manifest$ProfileId, response_data
    ))
    append_detail(mfrmr_cq_ag4m_truth_recovery_detail(
      arm, current, manifest$ProfileId
    ))
  }
  pair_specs <- list(
    list(
      summary = "ASP-CROSS-ENGINE-COORDINATE-DIFFERENCE",
      field = "CrossEnginePairId", engine = FALSE, nodes = TRUE
    ),
    list(
      summary = "ASP-QUADRATURE-SENSITIVITY",
      field = "QuadraturePairId", engine = TRUE, nodes = FALSE
    ),
    list(
      summary = "ASP-REPRESENTATION-INVARIANCE",
      field = "RepresentationPairId", engine = FALSE, nodes = FALSE
    )
  )
  for (spec in pair_specs) {
    ids <- unique(stats::na.omit(attempt[[spec$field]]))
    for (pair_id in ids) {
      rows <- attempt[
        !is.na(attempt[[spec$field]]) & attempt[[spec$field]] == pair_id,
        , drop = FALSE
      ]
      if (nrow(rows) != 2L || !all(rows$AttemptOrder %in% eligible)) next
      left <- fitted[[as.character(rows$AttemptOrder[1L])]]
      right <- fitted[[as.character(rows$AttemptOrder[2L])]]
      if (inherits(left, "error") || inherits(right, "error")) next
      append_detail(mfrmr_cq_ag4m_pair_detail(
        spec$summary, pair_id, rows[1L, , drop = FALSE],
        rows[2L, , drop = FALSE], left, right,
        mfrmr_cq_ag4m_stratum(
          rows[1L, , drop = FALSE], spec$engine, spec$nodes
        )
      ))
    }
  }
  attempted <- attempt[attempt$AttemptOrder %in%
                         outcome$AttemptOrder[outcome$Attempted], , drop = FALSE]
  journal <- mfrmr_cq_ag4m_read_csv(file.path(root, "attempt_journal.csv"))
  for (index in seq_len(nrow(attempted))) {
    arm <- attempted[index, , drop = FALSE]
    elapsed <- journal$ElapsedSeconds[
      journal$AttemptOrder == arm$AttemptOrder
    ]
    append_detail(mfrmr_cq_ag4m_detail_row(
      "ASP-ELAPSED-RUNTIME", sprintf("attempt:%03d", arm$AttemptOrder),
      mfrmr_cq_ag4m_stratum(arm), "elapsed_seconds", "attempt_elapsed",
      value = elapsed, include = is.finite(elapsed)
    ))
  }
  artifact <- mfrmr_cq_ach_expected_artifact_registry(plan)
  for (index in seq_len(nrow(artifact))) {
    path <- file.path(root, artifact$RelativePath[index])
    bytes <- if (file.exists(path)) as.numeric(file.info(path)$size) else 0
    stratum <- paste(
      artifact$Engine[index], ifelse(is.na(artifact$Nodes[index]), "sentinel",
                                     paste0("q", artifact$Nodes[index])),
      artifact$ArtifactKind[index], sep = "::"
    )
    append_detail(mfrmr_cq_ag4m_detail_row(
      "ASP-RETAINED-STORAGE", artifact$RelativePath[index], stratum,
      "retained_bytes", "registered_artifact", value = bytes, include = TRUE
    ))
  }
  detail <- mfrmr_cq_ag4m_rbind(detail, mfrmr_cq_ag4m_detail_template())
  observations <- detail[
    detail$IncludeInMetricSummary & detail$ObservationState == "observed" &
      is.finite(detail$Value),
    c("SummaryId", "UnitId", "Stratum", "Value"), drop = FALSE
  ]
  mfrmr_cq_ag4m_assert(
    !anyDuplicated(paste(observations$SummaryId, observations$UnitId, sep = "\r")) &&
      !any(detail$ThresholdApplied) &&
      !any(detail$ConfirmationUsePermitted) &&
      !any(detail$PublicClaimPermitted),
    "G4M numeric evidence duplicated a scalar unit or crossed its use boundary."
  )
  list(detail = detail, observations = observations)
}

mfrmr_cq_ag4m_authority_snapshot <- function(authorization) {
  schema <- mfrmr_cq_ach_authorization_schema()
  value <- lapply(schema$Field, function(field) {
    get(field, envir = authorization, inherits = FALSE)
  })
  names(value) <- schema$Field
  as.data.frame(value, stringsAsFactors = FALSE, optional = TRUE)
}

mfrmr_cq_ag4m_generation <- function(
    run_authorization, sentinel_token, calibration_output_dir) {
  registry <- mfrmr_cq_acf_seed_registry()
  allocation <- registry[registry$Tranche == "A", , drop = FALSE]
  allocation <- allocation[
    order(allocation$ArmIndex, allocation$Replicate), , drop = FALSE
  ]
  rownames(allocation) <- NULL
  plan <- mfrmr_cq_ach_adapter_plan()
  journal <- mfrmr_cq_ach_generation_journal_template(plan)
  generated <- vector("list", nrow(allocation))
  for (index in seq_len(nrow(allocation))) {
    authority <- mfrmr_cq_ach_dataset_generation_authority(
      run_authorization, allocation[index, , drop = FALSE], sentinel_token,
      calibration_output_dir
    )
    journal$GenerationStarted[index] <- TRUE
    generated[[index]] <- mfrmr_cq_ach_generate_dataset(
      allocation[index, , drop = FALSE], authority, calibration_output_dir
    )
    journal$Generated[index] <- TRUE
    journal$StructuralDispositionObserved[index] <-
      generated[[index]]$structural_disposition$ObservedDisposition
    journal$TerminalCode[index] <- if (
      generated[[index]]$structural_disposition$ObservedDisposition ==
        "reject_before_numeric_comparison"
    ) "expected_structural_rejection" else "generated_and_retained"
  }
  bind <- function(name) {
    value <- do.call(rbind, lapply(generated, `[[`, name))
    rownames(value) <- NULL
    value
  }
  manifest <- bind("dataset_manifest")
  response <- bind("response_data")
  truth <- bind("truth_registry")
  disposition <- bind("structural_disposition")
  bridge <- mfrmr_cq_ach_representation_bridge_audit(response, manifest)
  paired <- unique(bridge$DatasetId)
  journal$RepresentationBridgePassed[journal$DatasetId %in% paired] <-
    vapply(journal$DatasetId[journal$DatasetId %in% paired], function(id) {
      all(bridge$Passed[bridge$DatasetId == id])
    }, logical(1L))
  mfrmr_cq_ag4m_assert(
    nrow(manifest) == 90L && nrow(truth) == 90L &&
      nrow(disposition) == 90L && nrow(bridge) == 40L &&
      all(journal$Generated) && all(disposition$DispositionMatchesExpected) &&
      all(bridge$Passed),
    "G4M generation or semantic bridge accounting failed."
  )
  list(
    dataset_manifest = manifest, response_data = response,
    truth_registry = truth, structural_disposition = disposition,
    generation_journal = journal, representation_bridge = bridge
  )
}

mfrmr_cq_ag4m_execution_summary <- function(
    journal, outcome, resource, retained_review_complete = FALSE,
    numeric_agreement_inspected = FALSE) {
  data.frame(
    Specification = mfrmr_cq_ag4m_specification,
    ContractVersion = mfrmr_cq_ag4m_contract,
    Status = if (retained_review_complete) {
      "ASP_G4M_tranche_A_execution_retained_review_complete_exploratory_only"
    } else {
      "ASP_G4M_tranche_A_execution_in_progress_or_review_pending"
    },
    RetainedDatasets = length(unique(outcome$DatasetId)),
    RetainedOutcomeRows = nrow(outcome),
    RetainedAttemptRows = nrow(journal),
    FitAttempts = sum(journal$Started),
    Q61FitAttempts = sum(journal$Started & journal$Nodes == 61L),
    Q121FitAttempts = sum(journal$Started & journal$Nodes == 121L),
    ConQuestFitAttempts = sum(journal$Started & journal$Engine == "ConQuest"),
    MfrmrFitAttempts = sum(journal$Started & journal$Engine == "mfrmr"),
    GlobalAbortTriggered = isTRUE(resource$GlobalAbortTriggered),
    GlobalAbortReason = as.character(resource$GlobalAbortReason),
    RetainedReviewComplete = isTRUE(retained_review_complete),
    NumericAgreementInspected = isTRUE(numeric_agreement_inspected),
    ThresholdSelected = FALSE,
    ConfirmationUseAuthorized = FALSE,
    EvidencePromotionAuthorized = FALSE,
    PublicClaimAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ag4m_write_csv <- function(value, path) {
  mfrmr_cq_ameh_write_csv(value, path)
}

mfrmr_cq_ag4m_prepare_staging <- function(
    staging_root, target, authorization, generated, sentinel_token,
    phase_start) {
  plan <- mfrmr_cq_ach_adapter_plan()
  journal <- mfrmr_cq_ach_attempt_journal_template(plan)
  outcome <- mfrmr_cq_ach_outcome_template(plan)
  resource <- mfrmr_cq_ach_resource_state()
  resource$ElapsedSeconds <- proc.time()[["elapsed"]] - phase_start
  registry <- mfrmr_cq_ach_expected_artifact_registry(plan)
  inventory <- mfrmr_cq_ach_artifact_inventory(plan = plan)$registry
  summary <- mfrmr_cq_ag4m_execution_summary(journal, outcome, resource)
  root_table <- list(
    dataset_manifest = generated$dataset_manifest,
    response_data = generated$response_data,
    truth_registry = generated$truth_registry,
    structural_disposition = generated$structural_disposition,
    generation_journal = generated$generation_journal,
    execution_plan = plan,
    attempt_journal = journal,
    engine_outcome = outcome,
    representation_bridge = generated$representation_bridge,
    resource_summary = resource,
    artifact_inventory = inventory,
    execution_summary = summary
  )
  for (name in names(root_table)) {
    mfrmr_cq_ag4m_write_csv(
      root_table[[name]], file.path(staging_root, paste0(name, ".csv"))
    )
  }
  mfrmr_cq_ag4m_write_csv(
    mfrmr_cq_ag4m_authority_snapshot(authorization),
    file.path(staging_root, "authority_snapshot.csv")
  )
  mfrmr_cq_ag4m_write_csv(
    mfrmr_cq_ameh_response_layout(), file.path(staging_root, "response_layout.csv")
  )
  mfrmr_cq_ag4m_write_csv(
    registry, file.path(staging_root, "expected_artifact_registry.csv")
  )
  tables <- list(response_data = generated$response_data)
  attempt <- plan[plan$AttemptCap == 1L, , drop = FALSE]
  for (index in seq_len(nrow(attempt))) {
    arm <- attempt[index, , drop = FALSE]
    run_dir <- file.path(staging_root, arm$RunDirectory)
    mfrmr_cq_ag4m_assert(
      dir.create(run_dir, recursive = TRUE, showWarnings = FALSE),
      paste0("Could not create G4M run directory `", arm$RunId, "`.")
    )
    input <- mfrmr_cq_ach_dataset_input(
      tables, arm$DatasetId, arm$RepresentationId
    )
    if (arm$Engine == "mfrmr") {
      mfrmr_cq_ag4m_write_csv(input$long, file.path(staging_root, arm$LongFile))
      mfrmr_cq_ag4m_write_csv(
        input$person, file.path(staging_root, arm$PersonDataFile)
      )
    } else {
      mfrmr_cq_ag4m_write_csv(input$wide, file.path(staging_root, arm$WideFile))
      writeLines(
        mfrmr_cq_ach_conquest_command(arm$Prefix, arm$Family, arm$Nodes),
        file.path(staging_root, arm$CommandFile), useBytes = TRUE
      )
    }
  }
  mfrmr_cq_ag4m_assert(
    !file.exists(target) && file.rename(staging_root, target),
    "G4M could not promote the complete staging bundle to its final target."
  )
  normalizePath(target, winslash = "/", mustWork = TRUE)
}

mfrmr_cq_ag4m_execute_attempts <- function(root, sentinel_token, phase_start) {
  plan <- mfrmr_cq_ach_adapter_plan()
  journal <- mfrmr_cq_ach_attempt_journal_template(plan)
  outcome <- mfrmr_cq_ach_outcome_template(plan)
  resource <- mfrmr_cq_ach_resource_state()
  attempt <- plan[plan$AttemptCap == 1L, , drop = FALSE]
  for (order in seq_len(nrow(attempt))) {
    arm <- attempt[attempt$AttemptOrder == order, , drop = FALSE]
    resource$ElapsedSeconds <- proc.time()[["elapsed"]] - phase_start
    resource$RetainedBytes <- mfrmr_cq_ameh_retained_bytes(root)
    admission <- mfrmr_cq_ach_resource_controller(resource, arm)
    if (!isTRUE(admission$AttemptPermitted)) {
      resource$GlobalAbortTriggered <- TRUE
      resource$GlobalAbortReason <- admission$GlobalAbortReason
      break
    }
    row <- match(order, journal$AttemptOrder)
    journal$AttemptCount[row] <- 1L
    journal$Started[row] <- TRUE
    mfrmr_cq_ag4m_write_csv(
      journal, file.path(root, "attempt_journal.csv")
    )
    executed <- mfrmr_cq_ach_execute(
      root, arm, resource, sentinel_token,
      executable_path = mfrmr_cq_acf_conquest_path,
      per_fit_timeout_seconds = 600L, authorize = TRUE
    )
    mfrmr_cq_ag4m_assert(
      isTRUE(executed$attempted),
      "G4M controller returned an unattempted row after positive admission."
    )
    result <- executed$result
    journal$Completed[row] <- TRUE
    journal$ElapsedSeconds[row] <- result$elapsed_seconds
    journal$TerminalCode[row] <- result$terminal_code
    journal$SecondaryCode[row] <- result$secondary_code
    journal$ParseableResult[row] <- result$parseable
    journal$ObservedFreeDimension[row] <- result$observed_dimension
    journal$ModelIdentityMatch[row] <- result$model_identity_match
    journal$RegisteredFailureCount[row] <- result$registered_failure_count
    journal$ExitStatus[row] <- result$exit_status
    journal$TerminalMarkerObserved[row] <- result$terminal_marker
    journal$InferenceReady[row] <- result$inference_ready
    outcome_row <- match(
      journal$ScheduledOutcomeOrder[row], outcome$ScheduledOutcomeOrder
    )
    outcome$Attempted[outcome_row] <- TRUE
    outcome$TerminalCode[outcome_row] <- result$terminal_code
    outcome$SecondaryCode[outcome_row] <- result$secondary_code
    outcome$ParseableResult[outcome_row] <- result$parseable
    outcome$ModelIdentityMatch[outcome_row] <- result$model_identity_match
    outcome$InferenceReady[outcome_row] <- result$inference_ready
    resource <- executed$resource_state
    resource$ElapsedSeconds <- proc.time()[["elapsed"]] - phase_start
    resource$RetainedBytes <- mfrmr_cq_ameh_retained_bytes(root)
    continuation <- mfrmr_cq_ach_resource_controller(
      resource, terminal_code = result$terminal_code
    )
    if (order < nrow(attempt) && isTRUE(continuation$StopLaterAttempts)) {
      resource$GlobalAbortTriggered <- TRUE
      resource$GlobalAbortReason <- continuation$GlobalAbortReason
    }
    mfrmr_cq_ag4m_write_csv(journal, file.path(root, "attempt_journal.csv"))
    mfrmr_cq_ag4m_write_csv(outcome, file.path(root, "engine_outcome.csv"))
    mfrmr_cq_ag4m_write_csv(resource, file.path(root, "resource_summary.csv"))
    if (isTRUE(resource$GlobalAbortTriggered)) break
  }
  list(plan = plan, journal = journal, outcome = outcome, resource = resource)
}

mfrmr_cq_ag4m_finalize <- function(
    root, execution, generated, authorization) {
  plan <- execution$plan
  pre <- mfrmr_cq_ach_finalize_outcomes(
    plan, execution$journal, execution$outcome,
    global_abort_triggered = isTRUE(execution$resource$GlobalAbortTriggered),
    global_abort_reason = execution$resource$GlobalAbortReason
  )
  inventory <- mfrmr_cq_ach_artifact_inventory(root, plan)
  readiness <- mfrmr_cq_ach_readiness_evidence(root, plan, pre$journal)
  applied <- mfrmr_cq_ach_apply_diagnostic_eligibility(
    plan, pre$journal, inventory, generated$representation_bridge, readiness
  )
  final <- mfrmr_cq_ach_finalize_outcomes(
    plan, applied$journal, pre$outcome, applied$diagnostic_eligibility,
    global_abort_triggered = isTRUE(execution$resource$GlobalAbortTriggered),
    global_abort_reason = execution$resource$GlobalAbortReason
  )
  mfrmr_cq_ag4m_write_csv(final$journal, file.path(root, "attempt_journal.csv"))
  mfrmr_cq_ag4m_write_csv(final$outcome, file.path(root, "engine_outcome.csv"))
  evidence <- mfrmr_cq_ag4m_numeric_evidence(
    root, plan, final$outcome, applied$diagnostic_eligibility,
    generated$response_data, generated$dataset_manifest
  )
  metric <- mfrmr_cq_ach_metric_summary(
    plan, final$outcome, applied$diagnostic_eligibility,
    evidence$observations
  )
  execution$resource$ElapsedSeconds <- max(
    execution$resource$ElapsedSeconds,
    sum(final$journal$ElapsedSeconds, na.rm = TRUE)
  )
  execution$resource$RetainedBytes <- mfrmr_cq_ameh_retained_bytes(root)
  table <- list(
    diagnostic_eligibility = applied$diagnostic_eligibility,
    metric_summary = metric,
    resource_summary = execution$resource,
    artifact_inventory = inventory$registry,
    execution_summary = mfrmr_cq_ag4m_execution_summary(
      final$journal, final$outcome, execution$resource,
      retained_review_complete = FALSE,
      numeric_agreement_inspected = TRUE
    )
  )
  for (name in names(table)) {
    mfrmr_cq_ag4m_write_csv(
      table[[name]], file.path(root, paste0(name, ".csv"))
    )
  }
  mfrmr_cq_ag4m_write_csv(
    evidence$detail, file.path(root, "numeric_observation_detail.csv")
  )
  mfrmr_cq_ag4m_write_csv(
    mfrmr_cq_ag4m_authority_snapshot(authorization),
    file.path(root, "authority_snapshot.csv")
  )
  list(final = final, eligibility = applied$diagnostic_eligibility,
       evidence = evidence, metric = metric, resource = execution$resource)
}

mfrmr_cq_ag4m_same_detail <- function(left, right, tolerance = 1e-12) {
  if (!is.data.frame(left) || !is.data.frame(right) ||
      nrow(left) != nrow(right) || !setequal(names(left), names(right))) {
    return(FALSE)
  }
  right <- right[, names(left), drop = FALSE]
  numeric <- names(left)[vapply(left, is.numeric, logical(1L))]
  other <- setdiff(names(left), numeric)
  other_equal <- all(vapply(other, function(field) {
    x <- as.character(left[[field]]); x[is.na(x)] <- "<NA>"
    y <- as.character(right[[field]]); y[is.na(y)] <- "<NA>"
    identical(x, y)
  }, logical(1L)))
  numeric_equal <- all(vapply(numeric, function(field) {
    x <- as.numeric(left[[field]]); y <- as.numeric(right[[field]])
    identical(is.na(x), is.na(y)) &&
      all(abs(x[!is.na(x)] - y[!is.na(y)]) <= tolerance)
  }, logical(1L)))
  other_equal && numeric_equal
}

mfrmr_cq_ag4m_review <- function(output_dir) {
  mfrmr_cq_ag4m_require_contracts()
  root <- normalizePath(output_dir, winslash = "/", mustWork = TRUE)
  p4 <- mfrmr_cq_ach_review_execution(root)
  detail_path <- file.path(root, "numeric_observation_detail.csv")
  retained_detail <- if (file.exists(detail_path)) {
    mfrmr_cq_ag4m_read_csv(detail_path)
  } else {
    NULL
  }
  reconstructed <- tryCatch(
    mfrmr_cq_ag4m_numeric_evidence(
      root, p4$tables$execution_plan, p4$tables$engine_outcome,
      p4$tables$diagnostic_eligibility, p4$tables$response_data,
      p4$tables$dataset_manifest
    ),
    error = function(error) NULL
  )
  detail_reconstructed <- !is.null(retained_detail) &&
    !is.null(reconstructed) &&
    mfrmr_cq_ag4m_same_detail(retained_detail, reconstructed$detail)
  complete <- isTRUE(p4$retained_execution_review_complete) &&
    detail_reconstructed
  list(
    specification = mfrmr_cq_ag4m_specification,
    contract_version = mfrmr_cq_ag4m_contract,
    status = if (complete) {
      "ASP_G4M_tranche_A_execution_retained_review_complete_exploratory_only"
    } else {
      "ASP_G4M_tranche_A_execution_retained_review_hold"
    },
    output_dir = root,
    p4_review = p4,
    retained_numeric_detail_reconstructed = detail_reconstructed,
    retained_execution_review_complete = complete,
    rerun_authorized = FALSE,
    threshold_selected = FALSE,
    confirmation_use_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}

mfrmr_cq_ag4m_dry_run_review <- function(
    g4x_output_dir, calibration_output_dir,
    smoke_output_dir = file.path(
      dirname(g4x_output_dir), mfrmr_cq_ase_output_basename
    ),
    run_date = Sys.Date(), worktree_clean_attested = FALSE) {
  mfrmr_cq_ag4m_require_contracts()
  calibration_output_dir <- mfrmr_cq_ag4m_absent_path(calibration_output_dir)
  g4l <- mfrmr_cq_atla_review(
    g4x_output_dir, calibration_output_dir, smoke_output_dir,
    authorization_date = run_date,
    worktree_clean = worktree_clean_attested,
    ordinary_tests_external_runtime_free = TRUE
  )
  ready <- isTRUE(g4l$authorization_issue_ready) &&
    !file.exists(calibration_output_dir) &&
    !file.exists(paste0(calibration_output_dir, ".incomplete"))
  list(
    specification = mfrmr_cq_ag4m_specification,
    contract_version = mfrmr_cq_ag4m_contract,
    status = if (ready) {
      "ASP_G4M_same_process_execution_ready_explicit_opt_in_required"
    } else {
      "ASP_G4M_same_process_execution_blocked"
    },
    g4l_review = g4l,
    execution_ready = ready,
    positive_authorization_issued = FALSE,
    authorization_consumed = FALSE,
    sentinel_attempted = FALSE,
    responses_generated = FALSE,
    fit_attempts = 0L,
    ConQuest_execution_attempted = FALSE,
    numeric_agreement_inspected = FALSE,
    threshold_selected = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}

mfrmr_cq_ag4m_execute <- function(
    g4x_output_dir,
    calibration_output_dir,
    smoke_output_dir = file.path(
      dirname(g4x_output_dir), mfrmr_cq_ase_output_basename
    ),
    run_date = Sys.Date(), authorize = FALSE) {
  mfrmr_cq_ag4m_assert(
    identical(authorize, TRUE),
    "G4M live execution is held without explicit run-once authorization."
  )
  mfrmr_cq_ag4m_require_contracts()
  phase_start <- proc.time()[["elapsed"]]
  target <- mfrmr_cq_ag4m_absent_path(calibration_output_dir)
  staging <- paste0(target, ".incomplete")
  mfrmr_cq_ag4m_assert(
    !file.exists(target) && !dir.exists(target) &&
      !file.exists(staging) && !dir.exists(staging),
    "G4M requires absent final and incomplete output targets."
  )
  authorization <- mfrmr_cq_atla_issue(
    g4x_output_dir, target, smoke_output_dir,
    authorization_date = run_date,
    ordinary_tests_external_runtime_free = TRUE,
    authorize = TRUE
  )
  mfrmr_cq_ach_consume_authorization(
    authorization, target, authorize = TRUE
  )
  mfrmr_cq_ag4m_assert(
    dir.create(staging, recursive = TRUE, showWarnings = FALSE),
    "G4M could not create its exact incomplete staging root."
  )
  writeLines("quit;", file.path(staging, "runtime_sentinel.cqc"), useBytes = TRUE)
  sentinel <- mfrmr_cq_ach_fresh_sentinel(
    staging, target, mfrmr_cq_acf_conquest_path, run_date,
    timeout = 30L, authorize = TRUE
  )
  generated <- mfrmr_cq_ag4m_generation(
    authorization, sentinel, target
  )
  root <- mfrmr_cq_ag4m_prepare_staging(
    staging, target, authorization, generated, sentinel, phase_start
  )
  execution <- mfrmr_cq_ag4m_execute_attempts(root, sentinel, phase_start)
  finalized <- mfrmr_cq_ag4m_finalize(
    root, execution, generated, authorization
  )
  review <- mfrmr_cq_ag4m_review(root)
  summary <- mfrmr_cq_ag4m_execution_summary(
    finalized$final$journal, finalized$final$outcome, finalized$resource,
    retained_review_complete = review$retained_execution_review_complete,
    numeric_agreement_inspected = TRUE
  )
  mfrmr_cq_ag4m_write_csv(summary, file.path(root, "execution_summary.csv"))
  review <- mfrmr_cq_ag4m_review(root)
  list(
    authorization_consumed = isTRUE(authorization$Consumed),
    output_dir = root,
    finalization = finalized,
    review = review,
    rerun_authorized = FALSE,
    confirmation_use_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
