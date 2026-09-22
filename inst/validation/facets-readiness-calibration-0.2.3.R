# Repository-only, opened-seed calibration of JML numerical-readiness scales.
#
# This runner reuses the FACETS stress designs and mfrmr retained-point audits.
# It does not run FACETS, select a threshold, alter fit readiness, open a
# confirmation seed, or authorize a replacement claim.

mfrmr_facets_mrc_contract_id <-
  "mfrmr_facets_jml_readiness_calibration_v1"

mfrmr_facets_mrc_require_support <- function() {
  required <- c(
    "mfrmr_facets_mfx_allowed_pilot_seeds",
    "mfrmr_facets_mfs_registry",
    "mfrmr_facets_mfs_design",
    "mfrmr_facets_mfs_fit_mfrmr",
    "mfrmr_facets_mfs_jml_stationarity_audit",
    "mfrmr_facets_mfs_jml_context",
    "mfrmr_facets_mfs_boundary_coordinate_map",
    "mfrmr_facets_mfs_matrix_free_displacement_audit",
    "mfrmr_facets_mfs_bind_rows",
    "mfrmr_facets_mfs_collapse_messages",
    "mfrmr_facets_mfp_capture",
    "mfrmr_facets_mfp_person_status"
  )
  support_env <- environment()
  missing <- required[!vapply(
    required, exists, logical(1), envir = support_env,
    mode = "function", inherits = TRUE
  )]
  if (length(missing)) {
    stop(
      "Readiness-calibration support is missing: source the precision ",
      "contract, pilot adapter, and stress envelope first (",
      paste(missing, collapse = ", "), ").",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_facets_mrc_registry <- function() {
  mfrmr_facets_mrc_require_support()
  scenarios <- mfrmr_facets_mfs_registry()
  grid <- expand.grid(
    BaseSeed = mfrmr_facets_mfx_allowed_pilot_seeds(),
    Model = c("RSM", "PCM"),
    ScenarioId = scenarios$ScenarioId,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  scenario_columns <- setdiff(names(scenarios), "ScenarioId")
  matched <- match(grid$ScenarioId, scenarios$ScenarioId)
  out <- cbind(grid, scenarios[matched, scenario_columns, drop = FALSE])
  out$DesignSeed <- out$BaseSeed + match(out$Model, c("RSM", "PCM"))
  out$CalibrationRole <- "opened_pilot_descriptive_only"
  out$FACETSRunRequired <- FALSE
  out$ThresholdSelectionAuthorized <- FALSE
  out$ReadinessChangeAuthorized <- FALSE
  out$ConfirmationAuthorized <- FALSE
  out$FACETSReplacementClaimAuthorized <- FALSE
  out
}

mfrmr_facets_mrc_validate_request <- function(
    base_seeds = mfrmr_facets_mfx_allowed_pilot_seeds(),
    scenario_ids = mfrmr_facets_mfs_registry()$ScenarioId,
    models = c("RSM", "PCM"), maxit = 800L) {
  mfrmr_facets_mrc_require_support()
  allowed_seeds <- mfrmr_facets_mfx_allowed_pilot_seeds()
  valid_seeds <- is.numeric(base_seeds) && length(base_seeds) > 0L &&
    !anyNA(base_seeds) && all(is.finite(base_seeds)) &&
    all(base_seeds == floor(base_seeds)) &&
    all(base_seeds %in% allowed_seeds) && !anyDuplicated(base_seeds)
  registry <- mfrmr_facets_mfs_registry()
  valid_scenarios <- is.character(scenario_ids) && length(scenario_ids) > 0L &&
    !anyNA(scenario_ids) && all(scenario_ids %in% registry$ScenarioId) &&
    !anyDuplicated(scenario_ids)
  valid_models <- is.character(models) && length(models) > 0L &&
    !anyNA(models) && all(models %in% c("RSM", "PCM")) &&
    !anyDuplicated(models)
  valid_maxit <- is.numeric(maxit) && length(maxit) == 1L &&
    !is.na(maxit) && is.finite(maxit) && maxit == floor(maxit) && maxit >= 1L
  if (!valid_seeds) {
    stop(
      "`base_seeds` must be unique already-open pilot seeds; confirmation ",
      "seeds are not permitted.", call. = FALSE
    )
  }
  if (!valid_scenarios) {
    stop("`scenario_ids` must be unique registered stress scenarios.",
         call. = FALSE)
  }
  if (!valid_models) {
    stop("`models` must contain unique values from RSM and PCM.",
         call. = FALSE)
  }
  if (!valid_maxit) {
    stop("`maxit` must be one positive finite integer.", call. = FALSE)
  }
  list(
    base_seeds = as.integer(base_seeds),
    scenarios = registry[match(scenario_ids, registry$ScenarioId), , drop = FALSE],
    models = models,
    maxit = as.integer(maxit)
  )
}

mfrmr_facets_mrc_interior_residual <- function(stationarity, fit) {
  if (!inherits(stationarity, "mfrmr_facets_mfs_stationarity_audit")) {
    stop("`stationarity` must be a retained-point stationarity audit.",
         call. = FALSE)
  }
  residuals <- as.data.frame(
    stationarity$expanded_element_residuals,
    stringsAsFactors = FALSE
  )
  required <- c(
    "ParameterBlock", "ParameterId", "ScoreResidual", "MeanScoreResidual"
  )
  if (!all(required %in% names(residuals)) || !nrow(residuals)) {
    stop("The stationarity audit has no complete element residual table.",
         call. = FALSE)
  }
  person <- as.data.frame(fit$facets$person, stringsAsFactors = FALSE)
  person_status <- mfrmr_facets_mfp_person_status(person)
  status_by_id <- stats::setNames(person_status, as.character(person$Person))
  person_rows <- residuals$ParameterBlock == "Person"
  matched_status <- status_by_id[as.character(residuals$ParameterId)]
  unknown_person <- person_rows & is.na(matched_status)
  if (any(unknown_person)) {
    stop("Person residuals could not be aligned with boundary status.",
         call. = FALSE)
  }
  keep <- !person_rows | matched_status == "estimable"
  kept <- residuals[keep, , drop = FALSE]
  if (!nrow(kept) || any(!is.finite(kept$ScoreResidual)) ||
      any(!is.finite(kept$MeanScoreResidual))) {
    stop("Interior element residuals are empty or non-finite.", call. = FALSE)
  }
  data.frame(
    AllElementCoordinates = nrow(residuals),
    InteriorElementCoordinates = nrow(kept),
    BoundaryPersonCoordinatesExcluded = sum(!keep),
    InteriorScoreResidualSupNorm = max(abs(kept$ScoreResidual)),
    InteriorMeanScoreResidualSupNorm = max(abs(kept$MeanScoreResidual)),
    stringsAsFactors = FALSE
  )
}

mfrmr_facets_mrc_classify <- function(
    expected_state, fit_returned, typed_structural_rejection,
    estimation_converged, stationarity_returned, boundary_map_certified,
    displacement_converged, boundary_person_count) {
  expected_negative <- identical(
    expected_state, "must_not_be_comparison_eligible"
  )
  if (expected_negative && !fit_returned && typed_structural_rejection) {
    return("structurally_unidentified_negative_control")
  }
  if (expected_negative && fit_returned) {
    return("negative_control_false_ready")
  }
  if (!fit_returned) return("fit_error")
  if (!estimation_converged) return("optimizer_review")
  if (!stationarity_returned) return("stationarity_audit_error")
  if (!boundary_map_certified) return("boundary_map_review")
  if (!displacement_converged) return("displacement_audit_review")
  if (boundary_person_count > 0L) {
    return("boundary_conditioned_pilot_observation")
  }
  "interior_pilot_observation"
}

mfrmr_facets_mrc_finite_max <- function(x) {
  x <- as.numeric(x)
  x <- x[is.finite(x)]
  if (length(x)) max(x) else NA_real_
}

mfrmr_facets_mrc_summarize <- function(cases) {
  cases <- as.data.frame(cases, stringsAsFactors = FALSE)
  if (!nrow(cases)) return(data.frame())
  groups <- split(
    cases,
    interaction(cases$ScenarioId, cases$Model, drop = TRUE, lex.order = TRUE)
  )
  out <- do.call(rbind, lapply(groups, function(x) {
    data.frame(
      ScenarioId = x$ScenarioId[1L],
      Model = x$Model[1L],
      Cases = nrow(x),
      FitReturnedCases = sum(x$FitReturned %in% TRUE),
      EstimationConvergedCases = sum(x$EstimationConverged %in% TRUE),
      RawGradientGatePassedCases = sum(x$RawGradientGatePassed %in% TRUE),
      RawGradientReplicationStableCases = sum(
        x$RawGradientGateStableAcrossReplication %in% TRUE
      ),
      RawGradientGateChangedByReplicationCases = sum(
        x$RawGradientGateChangedByReplication %in% TRUE
      ),
      BoundaryCases = sum(x$KnownBoundaryPersonCount > 0L, na.rm = TRUE),
      DisplacementConvergedCases = sum(x$DisplacementConverged %in% TRUE),
      CompleteDiagnosticCases = sum(x$CompleteDiagnosticCase %in% TRUE),
      MaximumRawGradient = mfrmr_facets_mrc_finite_max(
        x$TerminalGradientSupNorm
      ),
      MaximumInteriorMeanScoreResidual = mfrmr_facets_mrc_finite_max(
        x$InteriorMeanScoreResidualSupNorm
      ),
      MaximumBoundaryConditionedDisplacement = mfrmr_facets_mrc_finite_max(
        x$BoundaryConditionedParameterChangeSupNorm
      ),
      MaximumRelativeObjectiveImprovement = mfrmr_facets_mrc_finite_max(
        x$BoundaryConditionedRelativeObjectiveImprovement
      ),
      ThresholdSelected = FALSE,
      ReadinessChanged = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  }))
  row.names(out) <- NULL
  out
}

mfrmr_run_facets_mrc_calibration <- function(
    base_seeds = mfrmr_facets_mfx_allowed_pilot_seeds(),
    scenario_ids = mfrmr_facets_mfs_registry()$ScenarioId,
    models = c("RSM", "PCM"), maxit = 800L, execute = FALSE,
    max_numeric_probes = 4L, direction_step = 1e-3,
    residual_tolerance = 1e-8, max_audit_iterations = 500L,
    retain_fits = FALSE) {
  request <- mfrmr_facets_mrc_validate_request(
    base_seeds, scenario_ids, models, maxit
  )
  logical_controls <- c(execute, retain_fits)
  valid_logical <- is.logical(logical_controls) &&
    length(logical_controls) == 2L && !anyNA(logical_controls)
  numeric_controls <- c(
    max_numeric_probes, direction_step, residual_tolerance,
    max_audit_iterations
  )
  valid_numeric <- is.numeric(numeric_controls) &&
    length(numeric_controls) == 4L && all(is.finite(numeric_controls)) &&
    max_numeric_probes == floor(max_numeric_probes) &&
    max_numeric_probes >= 1L && direction_step > 0 &&
    residual_tolerance > 0 &&
    max_audit_iterations == floor(max_audit_iterations) &&
    max_audit_iterations >= 1L
  if (!valid_logical || !valid_numeric) {
    stop("Readiness-calibration execution controls are invalid.", call. = FALSE)
  }
  registry <- mfrmr_facets_mrc_registry()
  registry <- registry[
    registry$BaseSeed %in% request$base_seeds &
      registry$ScenarioId %in% request$scenarios$ScenarioId &
      registry$Model %in% request$models, , drop = FALSE
  ]
  registry <- registry[order(
    match(registry$BaseSeed, request$base_seeds),
    match(registry$ScenarioId, request$scenarios$ScenarioId),
    match(registry$Model, request$models)
  ), , drop = FALSE]
  row.names(registry) <- NULL
  if (!isTRUE(execute)) {
    registry$PilotObservationState <- "not_run"
    registry$CompleteDiagnosticCase <- FALSE
    out <- list(
      contract_id = mfrmr_facets_mrc_contract_id,
      cases = registry,
      summary = data.frame(),
      fits = list(),
      executed = FALSE,
      threshold_selected = FALSE,
      readiness_changed = FALSE,
      confirmation_authorized = FALSE,
      facets_replacement_claim_authorized = FALSE
    )
    class(out) <- c("mfrmr_facets_mrc_result", "list")
    return(out)
  }

  case_rows <- vector("list", nrow(registry))
  fits <- list()
  for (i in seq_len(nrow(registry))) {
    row <- registry[i, , drop = FALSE]
    design <- mfrmr_facets_mfs_design(
      row$ScenarioId, row$Model, row$DesignSeed
    )
    fit_result <- mfrmr_facets_mfs_fit_mfrmr(
      design, maxit = request$maxit
    )
    fit <- fit_result$fit
    typed_structural <- !fit_result$fit_returned && isTRUE(grepl(
      "(^|;)mfrmr_estimability_error($|;)", fit_result$error_class,
      perl = TRUE
    ))

    stationarity_capture <- list(
      value = NULL, error = NA_character_, error_class = character(0),
      warnings = character(0)
    )
    boundary_capture <- stationarity_capture
    displacement_capture <- stationarity_capture
    interior_residual <- data.frame(
      AllElementCoordinates = NA_integer_,
      InteriorElementCoordinates = NA_integer_,
      BoundaryPersonCoordinatesExcluded = NA_integer_,
      InteriorScoreResidualSupNorm = NA_real_,
      InteriorMeanScoreResidualSupNorm = NA_real_
    )
    if (fit_result$fit_returned) {
      stationarity_capture <- mfrmr_facets_mfp_capture(
        mfrmr_facets_mfs_jml_stationarity_audit(
          fit, max_numeric_probes = as.integer(max_numeric_probes)
        )
      )
      boundary_capture <- mfrmr_facets_mfp_capture({
        context <- mfrmr_facets_mfs_jml_context(fit)
        mfrmr_facets_mfs_boundary_coordinate_map(context)
      })
      displacement_capture <- mfrmr_facets_mfp_capture(
        mfrmr_facets_mfs_matrix_free_displacement_audit(
          fit,
          direction_step = direction_step,
          residual_tolerance = residual_tolerance,
          max_iterations = as.integer(max_audit_iterations),
          condition_on_known_person_boundaries = TRUE
        )
      )
      if (!is.null(stationarity_capture$value)) {
        interior_residual <- mfrmr_facets_mrc_interior_residual(
          stationarity_capture$value, fit
        )
      }
      if (isTRUE(retain_fits)) {
        fits[[paste(row$BaseSeed, row$ScenarioId, row$Model, sep = "::")]] <- fit
      }
    }

    stationarity <- stationarity_capture$value
    stationarity_returned <- !is.null(stationarity)
    stationarity_summary <- if (is.null(stationarity)) {
      data.frame()
    } else {
      stationarity$summary
    }
    boundary_map <- boundary_capture$value
    boundary_returned <- !is.null(boundary_map)
    displacement <- displacement_capture$value
    displacement_returned <- !is.null(displacement)
    displacement_summary <- if (is.null(displacement)) {
      data.frame()
    } else {
      displacement$summary
    }
    take <- function(x, name, default) {
      if (is.data.frame(x) && nrow(x) == 1L && name %in% names(x)) {
        x[[name]][1L]
      } else {
        default
      }
    }
    boundary_certified <- boundary_returned && isTRUE(boundary_map$certified)
    boundary_certified_reported <- if (boundary_returned) {
      isTRUE(boundary_map$certified)
    } else {
      NA
    }
    boundary_count <- if (boundary_returned) {
      length(boundary_map$boundary_persons)
    } else {
      NA_integer_
    }
    displacement_converged <- displacement_returned && isTRUE(take(
      displacement_summary, "Converged", FALSE
    ))
    displacement_converged_reported <- if (displacement_returned) {
      displacement_converged
    } else {
      NA
    }
    raw_gate_stable <- if (stationarity_returned) {
      as.logical(take(
        stationarity_summary,
        "RawGradientGateStableAcrossRequestedReplication", NA
      ))
    } else {
      NA
    }
    state <- mfrmr_facets_mrc_classify(
      expected_state = row$ExpectedState,
      fit_returned = fit_result$fit_returned,
      typed_structural_rejection = typed_structural,
      estimation_converged = fit_result$estimation_converged,
      stationarity_returned = stationarity_returned,
      boundary_map_certified = boundary_certified,
      displacement_converged = displacement_converged,
      boundary_person_count = if (is.na(boundary_count)) 0L else boundary_count
    )
    complete_case <- state %in% c(
      "structurally_unidentified_negative_control",
      "boundary_conditioned_pilot_observation",
      "interior_pilot_observation"
    )
    errors <- c(
      fit_result$error,
      stationarity_capture$error,
      boundary_capture$error,
      displacement_capture$error
    )
    warnings <- c(
      fit_result$warnings,
      stationarity_capture$warnings,
      boundary_capture$warnings,
      displacement_capture$warnings
    )
    case_rows[[i]] <- data.frame(
      registry[i, , drop = FALSE],
      Rows = nrow(design$data),
      FitReturned = fit_result$fit_returned,
      TypedStructuralRejection = typed_structural,
      ErrorClass = fit_result$error_class,
      ConvergenceCode = fit_result$convergence_code,
      EstimationConverged = fit_result$estimation_converged,
      TerminalGradientSupNorm = fit_result$terminal_gradient,
      GradientReviewTolerance = fit_result$gradient_tolerance,
      RawGradientGatePassed = fit_result$numerical_gate_passed,
      StationarityAuditReturned = stationarity_returned,
      ObjectiveReconstructionAgrees = as.logical(take(
        stationarity_summary, "ObjectiveReconstructionAgrees", NA
      )),
      NumericGradientAgrees = as.logical(take(
        stationarity_summary, "NumericGradientAgrees", NA
      )),
      ReplicationTransportAgrees = as.logical(take(
        stationarity_summary, "ReplicationTransportAgrees", NA
      )),
      RawGradientGateStableAcrossReplication = raw_gate_stable,
      RawGradientGateChangedByReplication = if (is.na(raw_gate_stable)) {
        NA
      } else {
        !raw_gate_stable
      },
      WorstExpandedMeanScoreResidual = as.numeric(take(
        stationarity_summary, "WorstExpandedMeanScoreResidual", NA_real_
      )),
      interior_residual,
      BoundaryAuditReturned = boundary_returned,
      BoundaryMapStatus = if (!boundary_returned) {
        NA_character_
      } else {
        boundary_map$status
      },
      BoundaryMapCertified = boundary_certified_reported,
      KnownBoundaryPersonCount = boundary_count,
      DisplacementAuditReturned = displacement_returned,
      DisplacementStatus = as.character(take(
        displacement_summary, "Status", NA_character_
      )),
      DisplacementConverged = displacement_converged_reported,
      BoundaryConditionedParameterChangeSupNorm = as.numeric(take(
        displacement_summary, "ParameterChangeSupNorm", NA_real_
      )),
      BoundaryConditionedRelativeObjectiveImprovement = as.numeric(take(
        displacement_summary, "RelativeObjectiveImprovement", NA_real_
      )),
      DisplacementExplicitRelativeResidual = as.numeric(take(
        displacement_summary, "ExplicitRelativeResidual", NA_real_
      )),
      PilotObservationState = state,
      CompleteDiagnosticCase = complete_case,
      ThresholdSelected = FALSE,
      ReadinessChanged = FALSE,
      Warnings = mfrmr_facets_mfs_collapse_messages(warnings),
      Error = mfrmr_facets_mfs_collapse_messages(errors),
      stringsAsFactors = FALSE
    )
  }
  cases <- mfrmr_facets_mfs_bind_rows(case_rows)
  out <- list(
    contract_id = mfrmr_facets_mrc_contract_id,
    cases = cases,
    summary = mfrmr_facets_mrc_summarize(cases),
    fits = fits,
    executed = TRUE,
    threshold_selected = FALSE,
    readiness_changed = FALSE,
    confirmation_authorized = FALSE,
    facets_replacement_claim_authorized = FALSE
  )
  class(out) <- c("mfrmr_facets_mrc_result", "list")
  out
}

print.mfrmr_facets_mrc_result <- function(x, ...) {
  cat("FACETS stress-design JML readiness calibration\n")
  cat("Executed:", if (isTRUE(x$executed)) "yes" else "no", "\n")
  cat("Cases:", nrow(x$cases), "\n")
  cat("Threshold selected: no; readiness changed: no\n")
  cat("Confirmation authorized: no; FACETS replacement claim: no\n")
  invisible(x)
}
