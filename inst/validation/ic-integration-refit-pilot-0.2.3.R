# mfrmr 0.2.3 refit-at-grid IC integration pilot
#
# Source the fixed-vector evaluator and deterministic matrix helpers first:
#
#   pkgload::load_all(".")
#   source("inst/validation/ic-integration-pilot-0.2.3.R")
#   source("inst/validation/ic-integration-pilot-matrix-0.2.3.R")
#   source("inst/validation/ic-integration-refit-pilot-0.2.3.R")
#   refit <- mfrmr_run_ic_integration_refit_pilot(
#     "IC-WIDE-LATENT-NEAR-TIE"
#   )
#   print(refit)
#   refit_matrix <- mfrmr_run_ic_integration_refit_matrix(progress = TRUE)
#   print(refit_matrix)
#
# Every grid point starts from the package's ordinary deterministic initial
# vector. The runner then evaluates every retained solution at one common
# reference grid. This separates native refit-plus-integration movement from
# parameter-solution movement under a common likelihood evaluation.

mfrmr_ic_refit_policy <- "independent_refit_then_common_ghq_v1"

mfrmr_ic_refit_or <- function(x, fallback) {
  if (is.null(x) || length(x) == 0L) fallback else x
}

mfrmr_ic_refit_sign <- function(value, tolerance) {
  if (!is.finite(value)) return(NA_integer_)
  if (abs(value) <= tolerance) 0L else as.integer(sign(value))
}

mfrmr_ic_refit_preferred <- function(first,
                                     second,
                                     labels,
                                     tolerance) {
  difference <- first - second
  if (abs(difference) <= tolerance) paste(labels, collapse = ";") else
    if (difference < 0) labels[1] else labels[2]
}

mfrmr_ic_refit_summarize <- function(pairwise,
                                     fit_drift,
                                     core_quad_points) {
  scopes <- list(
    full_ladder = sort(unique(pairwise$SourceQuadraturePoints)),
    core_ladder = core_quad_points
  )
  rows <- list()
  for (scope in names(scopes)) {
    q_values <- scopes[[scope]]
    for (criterion in unique(pairwise$Criterion)) {
      pair_rows <- pairwise[
        pairwise$Criterion == criterion &
          pairwise$SourceQuadraturePoints %in% q_values,
        , drop = FALSE
      ]
      fit_rows <- fit_drift[
        fit_drift$SourceQuadraturePoints %in% q_values,
        , drop = FALSE
      ]
      rows[[length(rows) + 1L]] <- data.frame(
        Scope = scope,
        Criterion = criterion,
        QuadraturePoints = paste(q_values, collapse = ";"),
        MaxAbsNativeGapDrift = max(abs(pair_rows$NativeGapDrift)),
        MaxAbsCommonGapDrift = max(abs(pair_rows$CommonReferenceGapDrift)),
        NativeOrderingStable = all(pair_rows$NativeOrderingStable),
        CommonOrderingStable = all(pair_rows$CommonOrderingStable),
        MaxAbsParameterDrift = max(fit_rows$MaxAbsParameterDrift),
        MaxRMSParameterDrift = max(fit_rows$RMSParameterDrift),
        MaxCommonReferenceDevianceExcess = max(
          abs(fit_rows$CommonReferenceDevianceExcess)
        ),
        stringsAsFactors = FALSE
      )
    }
  }
  do.call(rbind, rows)
}

mfrmr_run_ic_integration_refit_pilot <- function(
    scenario_id = "IC-WIDE-LATENT-NEAR-TIE",
    quad_points = c(7L, 15L, 31L, 61L, 91L, 121L),
    reference_quad = 121L,
    core_quad_points = c(31L, 61L, 91L, 121L),
    maxit = 1000L,
    reltol = 1e-10,
    objective_tolerance = 1e-10,
    tie_tolerance = 1e-8,
    pkg_dir = ".") {
  required_functions <- c(
    "mfrmr_ic_integration_validate_grid",
    "mfrmr_ic_integration_evaluate_fit",
    "mfrmr_ic_integration_git_identity",
    "mfrmr_ic_matrix_registry",
    "mfrmr_ic_matrix_build_scenario",
    "mfrmr_ic_matrix_fit_scenario"
  )
  missing_functions <- required_functions[!vapply(
    required_functions,
    exists,
    logical(1),
    mode = "function"
  )]
  if (length(missing_functions) > 0L) {
    stop(
      "Source the fixed-vector and matrix pilot helpers first; missing: ",
      paste(missing_functions, collapse = ", "), ".",
      call. = FALSE
    )
  }
  grid <- mfrmr_ic_integration_validate_grid(
    quad_points = quad_points,
    reference_quad = reference_quad,
    core_quad_points = core_quad_points
  )
  registry <- mfrmr_ic_matrix_registry()
  registry <- registry[registry$ScenarioId == scenario_id, , drop = FALSE]
  if (nrow(registry) != 1L) {
    stop("`scenario_id` must identify one registered matrix scenario.",
         call. = FALSE)
  }
  built <- mfrmr_ic_matrix_build_scenario(
    scenario_id = scenario_id,
    seed = registry$Seed[1]
  )
  if (length(built$candidates) != 2L) {
    stop("The first refit pilot contract requires exactly two candidates.",
         call. = FALSE)
  }

  labels <- names(built$candidates)
  evaluation_rows <- list()
  warning_rows <- list()
  parameter_vectors <- list()
  fit_metadata <- list()

  for (source_quad in grid$quad_points) {
    fitted <- mfrmr_ic_matrix_fit_scenario(
      built = built,
      source_quad = source_quad,
      maxit = maxit,
      reltol = reltol
    )
    if (nrow(fitted$warnings) > 0L) {
      warnings <- fitted$warnings
      warnings$ScenarioId <- scenario_id
      warnings$SourceQuadraturePoints <- source_quad
      warning_rows[[as.character(source_quad)]] <- warnings[, c(
        "ScenarioId", "SourceQuadraturePoints", "Candidate", "Warning"
      ), drop = FALSE]
    }
    for (label in labels) {
      fit <- fitted$fits[[label]]
      convergence <- mfrmr_ic_integration_internal("mfrm_convergence_state")(fit)
      if (!isTRUE(convergence$inference_ready)) {
        stop(
          "Refit `", label, "` at q = ", source_quad,
          " is not inference-ready.",
          call. = FALSE
        )
      }
      evaluation_grid <- sort(unique(c(source_quad, grid$reference_quad)))
      evaluated <- mfrmr_ic_integration_evaluate_fit(
        fit = fit,
        label = label,
        quad_points = evaluation_grid,
        objective_tolerance = objective_tolerance
      )
      source_row <- evaluated[
        evaluated$EvaluationQuadraturePoints == source_quad,
        , drop = FALSE
      ]
      if (nrow(source_row) != 1L ||
          !isTRUE(source_row$SourceObjectiveConsistent[1])) {
        stop(
          "Refit `", label, "` at q = ", source_quad,
          " did not reproduce its source objective.",
          call. = FALSE
        )
      }
      common_row <- evaluated[
        evaluated$EvaluationQuadraturePoints == grid$reference_quad,
        , drop = FALSE
      ]
      if (nrow(common_row) != 1L) {
        stop("Common-reference evaluation did not return exactly one row.",
             call. = FALSE)
      }
      evaluation_rows[[paste(source_quad, label, sep = "::")]] <- data.frame(
        ScenarioId = scenario_id,
        Candidate = label,
        Model = source_row$Model,
        SourceQuadraturePoints = source_quad,
        ReferenceQuadraturePoints = grid$reference_quad,
        Npar = source_row$Npar,
        Persons = source_row$Persons,
        NativeLogLik = source_row$LogLik,
        NativeDeviance = source_row$Deviance,
        NativeAIC = source_row$AIC,
        NativeBIC = source_row$BIC,
        NativeSABIC = source_row$SABIC,
        CommonReferenceLogLik = common_row$LogLik,
        CommonReferenceDeviance = common_row$Deviance,
        CommonReferenceAIC = common_row$AIC,
        CommonReferenceBIC = common_row$BIC,
        CommonReferenceSABIC = common_row$SABIC,
        NativeToCommonDevianceShift =
          common_row$Deviance - source_row$Deviance,
        SourceObjectiveDifference = source_row$SourceObjectiveDifference,
        InferenceReady = TRUE,
        stringsAsFactors = FALSE
      )
      parameter_vectors[[paste(source_quad, label, sep = "::")]] <-
        as.numeric(fit$opt$par)
      fit_metadata[[paste(source_quad, label, sep = "::")]] <- data.frame(
        ScenarioId = scenario_id,
        Candidate = label,
        SourceQuadraturePoints = source_quad,
        Optimizer = as.character(
          mfrmr_ic_refit_or(
            fit$config$estimation_control$optimizer_used,
            NA_character_
          )
        ),
        Iterations = suppressWarnings(as.integer(
          mfrmr_ic_refit_or(fit$opt$counts[["function"]], NA_integer_)
        )),
        stringsAsFactors = FALSE
      )
    }
  }

  evaluations <- do.call(rbind, evaluation_rows)
  rownames(evaluations) <- NULL
  metadata <- do.call(rbind, fit_metadata)
  rownames(metadata) <- NULL
  warnings <- if (length(warning_rows) > 0L) {
    do.call(rbind, warning_rows)
  } else {
    data.frame(
      ScenarioId = character(), SourceQuadraturePoints = integer(),
      Candidate = character(), Warning = character(),
      stringsAsFactors = FALSE
    )
  }

  fit_drift_rows <- list()
  for (label in labels) {
    reference_key <- paste(grid$reference_quad, label, sep = "::")
    reference_parameters <- parameter_vectors[[reference_key]]
    reference_deviance <- evaluations$CommonReferenceDeviance[
      evaluations$Candidate == label &
        evaluations$SourceQuadraturePoints == grid$reference_quad
    ]
    for (source_quad in grid$quad_points) {
      key <- paste(source_quad, label, sep = "::")
      parameters <- parameter_vectors[[key]]
      if (length(parameters) != length(reference_parameters)) {
        stop("Free-parameter dimension changed across refits for `", label,
             "`.", call. = FALSE)
      }
      difference <- parameters - reference_parameters
      row <- evaluations[
        evaluations$Candidate == label &
          evaluations$SourceQuadraturePoints == source_quad,
        , drop = FALSE
      ]
      fit_drift_rows[[key]] <- data.frame(
        ScenarioId = scenario_id,
        Candidate = label,
        SourceQuadraturePoints = source_quad,
        ReferenceQuadraturePoints = grid$reference_quad,
        MaxAbsParameterDrift = max(abs(difference)),
        RMSParameterDrift = sqrt(mean(difference^2)),
        CommonReferenceDevianceExcess =
          row$CommonReferenceDeviance - reference_deviance,
        NativeToCommonDevianceShift = row$NativeToCommonDevianceShift,
        stringsAsFactors = FALSE
      )
    }
  }
  fit_drift <- do.call(rbind, fit_drift_rows)
  rownames(fit_drift) <- NULL

  criteria <- c("Deviance", "AIC", "BIC", "SABIC")
  pair_rows <- list()
  for (criterion in criteria) {
    native_field <- paste0("Native", criterion)
    common_field <- paste0("CommonReference", criterion)
    reference_rows <- evaluations[
      evaluations$SourceQuadraturePoints == grid$reference_quad,
      , drop = FALSE
    ]
    reference_first <- reference_rows[[native_field]][
      reference_rows$Candidate == labels[1]
    ]
    reference_second <- reference_rows[[native_field]][
      reference_rows$Candidate == labels[2]
    ]
    reference_gap <- reference_first - reference_second
    reference_sign <- mfrmr_ic_refit_sign(reference_gap, tie_tolerance)
    for (source_quad in grid$quad_points) {
      current <- evaluations[
        evaluations$SourceQuadraturePoints == source_quad,
        , drop = FALSE
      ]
      native_first <- current[[native_field]][current$Candidate == labels[1]]
      native_second <- current[[native_field]][current$Candidate == labels[2]]
      common_first <- current[[common_field]][current$Candidate == labels[1]]
      common_second <- current[[common_field]][current$Candidate == labels[2]]
      native_gap <- native_first - native_second
      common_gap <- common_first - common_second
      pair_rows[[length(pair_rows) + 1L]] <- data.frame(
        ScenarioId = scenario_id,
        Criterion = criterion,
        First = labels[1],
        Second = labels[2],
        SourceQuadraturePoints = source_quad,
        ReferenceQuadraturePoints = grid$reference_quad,
        NativeGap = native_gap,
        CommonReferenceGap = common_gap,
        ReferenceFitGap = reference_gap,
        NativeGapDrift = native_gap - reference_gap,
        CommonReferenceGapDrift = common_gap - reference_gap,
        NativeOrderingStable = identical(
          mfrmr_ic_refit_sign(native_gap, tie_tolerance), reference_sign
        ),
        CommonOrderingStable = identical(
          mfrmr_ic_refit_sign(common_gap, tie_tolerance), reference_sign
        ),
        NativePreferred = mfrmr_ic_refit_preferred(
          native_first, native_second, labels, tie_tolerance
        ),
        CommonReferencePreferred = mfrmr_ic_refit_preferred(
          common_first, common_second, labels, tie_tolerance
        ),
        ReferencePreferred = mfrmr_ic_refit_preferred(
          reference_first, reference_second, labels, tie_tolerance
        ),
        stringsAsFactors = FALSE
      )
    }
  }
  pairwise <- do.call(rbind, pair_rows)
  summary <- mfrmr_ic_refit_summarize(
    pairwise = pairwise,
    fit_drift = fit_drift,
    core_quad_points = grid$core_quad_points
  )
  core <- summary[summary$Scope == "core_ladder", , drop = FALSE]
  full <- summary[summary$Scope == "full_ladder", , drop = FALSE]
  core_stable <- all(core$NativeOrderingStable & core$CommonOrderingStable)
  full_stable <- all(full$NativeOrderingStable & full$CommonOrderingStable)

  out <- list(
    specification = mfrmr_ic_integration_specification,
    evidence_role = "pilot",
    confirmation_authorized = FALSE,
    policy = mfrmr_ic_refit_policy,
    scenario_id = scenario_id,
    candidate_commit = mfrmr_ic_integration_git_identity(pkg_dir),
    quadrature_points = grid$quad_points,
    core_quadrature_points = grid$core_quad_points,
    reference_quadrature_points = grid$reference_quad,
    maxit = maxit,
    reltol = reltol,
    evaluations = evaluations,
    fit_drift = fit_drift,
    pairwise = pairwise,
    summary = summary,
    metadata = metadata,
    warnings = warnings,
    core_ordering_stable = core_stable,
    full_ordering_stable = full_stable,
    status = "review",
    interpretation = if (!core_stable) {
      "refit_core_order_change_threshold_unfrozen"
    } else if (!full_stable) {
      "refit_core_stable_coarse_grid_order_change_threshold_unfrozen"
    } else {
      "refit_ordering_stable_threshold_unfrozen"
    }
  )
  class(out) <- c("mfrmr_ic_integration_refit_pilot", class(out))
  out
}

print.mfrmr_ic_integration_refit_pilot <- function(x, digits = 6L, ...) {
  cat("mfrmr 0.2.3 refit-at-grid IC integration pilot\n")
  cat("  Specification:", x$specification, "\n")
  cat("  Scenario:", x$scenario_id, "\n")
  cat("  Policy:", x$policy, "\n")
  cat("  GHQ ladder:", paste(x$quadrature_points, collapse = ", "), "\n")
  cat("  Reference q:", x$reference_quadrature_points, "\n")
  cat("  Core ordering stable:", x$core_ordering_stable, "\n")
  cat("  Full-ladder ordering stable:", x$full_ordering_stable, "\n")
  cat("  Status:", x$status, "(", x$interpretation, ")\n", sep = "")
  display <- x$summary[x$summary$Scope == "core_ladder", c(
    "Criterion", "MaxAbsNativeGapDrift", "MaxAbsCommonGapDrift",
    "NativeOrderingStable", "CommonOrderingStable",
    "MaxAbsParameterDrift", "MaxCommonReferenceDevianceExcess"
  ), drop = FALSE]
  numeric_columns <- vapply(display, is.numeric, logical(1))
  display[numeric_columns] <- lapply(display[numeric_columns], round, digits)
  print(display, row.names = FALSE)
  cat("  Pilot only: refit tolerances remain unfrozen.\n")
  invisible(x)
}

mfrmr_ic_refit_matrix_summarize <- function(pilot, scenario) {
  core <- pilot$summary[pilot$summary$Scope == "core_ladder", , drop = FALSE]
  full <- pilot$summary[pilot$summary$Scope == "full_ladder", , drop = FALSE]
  data.frame(
    ScenarioId = pilot$scenario_id,
    StressRole = scenario$StressRole,
    MaxCoreNativeGapDrift = max(core$MaxAbsNativeGapDrift),
    MaxCoreCommonGapDrift = max(core$MaxAbsCommonGapDrift),
    MaxCoreParameterDrift = max(core$MaxAbsParameterDrift),
    MaxCoreCommonReferenceDevianceExcess = max(
      core$MaxCommonReferenceDevianceExcess
    ),
    CoreNativeOrderingStable = all(core$NativeOrderingStable),
    CoreCommonOrderingStable = all(core$CommonOrderingStable),
    MaxFullNativeGapDrift = max(full$MaxAbsNativeGapDrift),
    FullNativeOrderingStable = all(full$NativeOrderingStable),
    FullCommonOrderingStable = all(full$CommonOrderingStable),
    CapturedWarnings = nrow(pilot$warnings),
    EvidenceStatus = "review",
    stringsAsFactors = FALSE
  )
}

mfrmr_run_ic_integration_refit_matrix <- function(
    scenarios = mfrmr_ic_matrix_registry()$ScenarioId,
    quad_points = c(7L, 15L, 31L, 61L, 91L, 121L),
    reference_quad = 121L,
    core_quad_points = c(31L, 61L, 91L, 121L),
    maxit = 1000L,
    reltol = 1e-10,
    objective_tolerance = 1e-10,
    tie_tolerance = 1e-8,
    fail_fast = FALSE,
    progress = interactive(),
    pkg_dir = ".") {
  if (!exists("mfrmr_ic_matrix_registry", mode = "function")) {
    stop(
      "Source the fixed-vector and matrix pilot helpers first.",
      call. = FALSE
    )
  }
  registry <- mfrmr_ic_matrix_registry()
  unknown <- setdiff(scenarios, registry$ScenarioId)
  if (length(unknown) > 0L) {
    stop("Unknown refit scenario(s): ", paste(unknown, collapse = ", "),
         call. = FALSE)
  }
  registry <- registry[match(scenarios, registry$ScenarioId), , drop = FALSE]
  pilots <- list()
  aggregate <- list()
  warnings <- list()
  failures <- list()

  for (index in seq_len(nrow(registry))) {
    scenario <- registry[index, , drop = FALSE]
    scenario_id <- scenario$ScenarioId
    if (isTRUE(progress)) {
      cat("Refitting", scenario_id, "(", index, "of", nrow(registry), ")\n")
    }
    result <- tryCatch(
      mfrmr_run_ic_integration_refit_pilot(
        scenario_id = scenario_id,
        quad_points = quad_points,
        reference_quad = reference_quad,
        core_quad_points = core_quad_points,
        maxit = maxit,
        reltol = reltol,
        objective_tolerance = objective_tolerance,
        tie_tolerance = tie_tolerance,
        pkg_dir = pkg_dir
      ),
      error = function(error) error
    )
    if (inherits(result, "error")) {
      failures[[scenario_id]] <- data.frame(
        ScenarioId = scenario_id,
        Error = conditionMessage(result),
        EvidenceStatus = "concern",
        stringsAsFactors = FALSE
      )
      if (isTRUE(fail_fast)) stop(result)
      next
    }
    pilots[[scenario_id]] <- result
    warnings[[scenario_id]] <- result$warnings
    aggregate[[scenario_id]] <- mfrmr_ic_refit_matrix_summarize(
      result, scenario
    )
  }

  bind_or_empty <- function(rows, columns) {
    if (length(rows) > 0L) {
      out <- do.call(rbind, rows)
      rownames(out) <- NULL
      return(out)
    }
    as.data.frame(setNames(replicate(
      length(columns), character(0), simplify = FALSE
    ), columns), stringsAsFactors = FALSE)
  }
  aggregate_table <- bind_or_empty(aggregate, "ScenarioId")
  warning_table <- bind_or_empty(
    warnings,
    c("ScenarioId", "SourceQuadraturePoints", "Candidate", "Warning")
  )
  failure_table <- bind_or_empty(
    failures,
    c("ScenarioId", "Error", "EvidenceStatus")
  )
  out <- list(
    specification = mfrmr_ic_integration_specification,
    evidence_role = "pilot",
    confirmation_authorized = FALSE,
    policy = mfrmr_ic_refit_policy,
    registry = registry,
    quadrature_points = quad_points,
    core_quadrature_points = core_quad_points,
    reference_quadrature_points = reference_quad,
    pilots = pilots,
    aggregate = aggregate_table,
    warnings = warning_table,
    failures = failure_table,
    status = if (nrow(failure_table) > 0L) "concern" else "review"
  )
  class(out) <- c("mfrmr_ic_integration_refit_matrix", class(out))
  out
}

print.mfrmr_ic_integration_refit_matrix <- function(x, digits = 6L, ...) {
  cat("mfrmr 0.2.3 refit-at-grid IC integration matrix\n")
  cat("  Specification:", x$specification, "\n")
  cat("  Scenarios retained:", nrow(x$aggregate), "of", nrow(x$registry), "\n")
  cat("  Failed scenarios:", nrow(x$failures), "\n")
  cat("  Status:", x$status, "\n")
  if (nrow(x$aggregate) > 0L) {
    display <- x$aggregate[, c(
      "ScenarioId", "MaxCoreNativeGapDrift", "MaxCoreCommonGapDrift",
      "MaxCoreParameterDrift", "MaxCoreCommonReferenceDevianceExcess",
      "CoreNativeOrderingStable", "FullNativeOrderingStable"
    ), drop = FALSE]
    numeric_columns <- vapply(display, is.numeric, logical(1))
    display[numeric_columns] <- lapply(display[numeric_columns], round, digits)
    print(display, row.names = FALSE)
  }
  if (nrow(x$failures) > 0L) print(x$failures, row.names = FALSE)
  cat("  Pilot only: refit tolerances remain unfrozen.\n")
  invisible(x)
}
