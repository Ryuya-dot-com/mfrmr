# mfrmr 0.2.3 repository-only MML engine-parity pilot
#
# Prerequisite from the repository root:
#
#   pkgload::load_all(".")
#   source("inst/validation/numerical-stationarity-pilot-0.2.3.R")
#   source("inst/validation/mml-engine-parity-pilot-0.2.3.R")
#   parity <- mfrmr_run_mml_engine_parity_pilot()
#   parity$path_results
#   parity$pairwise_results
#   parity$summary
#
# This runner compares additive RSM/PCM direct, hybrid, and converged-EM plus
# common-direct-polish paths. Raw EM is retained as a diagnostic path but is
# not allowed to satisfy engine parity by its relative-log-likelihood stopping
# rule alone. GPCM, model-estimated interactions, and latent regression are
# explicit fallback/non-parity scope rows. No observed pilot maximum becomes a
# frozen tolerance, and neither selection nor confirmation is authorized.

mfrmr_engine_specification <- "0.2.3-draft.13"
mfrmr_engine_contract <- "mfrmr_mml_engine_common_vector_audit_v1"
mfrmr_engine_dependency_contract <- "mfrmr_mml_canonical_score_audit_v1"
mfrmr_engine_public_engines <- c("direct", "em", "hybrid")
mfrmr_engine_solution_paths <- c(
  "direct", "hybrid", "em_plus_common_direct_polish"
)
mfrmr_engine_all_paths <- c(
  "direct", "hybrid", "em_raw", "em_plus_common_direct_polish"
)
mfrmr_engine_evaluator_identity_tolerance <- 1e-12

mfrmr_engine_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_engine_or <- function(value, fallback) {
  if (is.null(value)) fallback else value
}

mfrmr_engine_vector_fingerprint <- function(value) {
  value <- as.numeric(value)
  mfrmr_engine_assert(
    length(value) > 0L && all(is.finite(value)),
    "Vector fingerprinting requires finite retained coordinates."
  )
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop(
      "The repository-only engine pilot requires the suggested `digest` package.",
      call. = FALSE
    )
  }
  canonical <- paste(sprintf("%.17g", value), collapse = ",")
  digest::digest(canonical, algo = "sha256", serialize = FALSE)
}

mfrmr_engine_require_helpers <- function() {
  definition_env <- environment(mfrmr_engine_require_helpers)
  required <- c(
    "mfrmr_num_contract", "mfrmr_num_namespace", "mfrmr_num_get",
    "mfrmr_num_fixture", "mfrmr_num_fit_context"
  )
  available <- vapply(
    required,
    exists,
    logical(1L),
    envir = definition_env,
    inherits = TRUE
  )
  if (!all(available) ||
      !identical(
        get("mfrmr_num_contract", envir = definition_env, inherits = TRUE),
        mfrmr_engine_dependency_contract
      )) {
    stop(
      paste0(
        "Source numerical-stationarity-pilot-0.2.3.R from the same working ",
        "tree before running the MML engine-parity pilot."
      ),
      call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_engine_get_helper <- function(name) {
  mfrmr_engine_require_helpers()
  get(
    name,
    envir = environment(mfrmr_engine_get_helper),
    inherits = TRUE
  )
}

mfrmr_engine_namespace <- function() {
  namespace <- mfrmr_engine_get_helper("mfrmr_num_namespace")()
  required <- c(
    "run_mfrm_direct_optimization", "resolve_mml_engine_plan",
    "expand_params"
  )
  available <- vapply(
    required,
    exists,
    logical(1L),
    envir = namespace,
    inherits = FALSE
  )
  if (!all(available)) {
    stop(
      "The loaded mfrmr namespace lacks the required engine-audit internals.",
      call. = FALSE
    )
  }
  namespace
}

mfrmr_engine_get <- function(name) {
  get(name, envir = mfrmr_engine_namespace(), inherits = FALSE)
}

mfrmr_engine_plan <- function() {
  data.frame(
    RunId = c("binary_rsm", "binary_pcm", "rsm_core", "pcm_core"),
    ScenarioId = c(
      "NUM-ENGINE-BINARY-RSM", "NUM-ENGINE-BINARY-PCM",
      "NUM-ENGINE-RSM", "NUM-ENGINE-PCM"
    ),
    Model = c("RSM", "PCM", "RSM", "PCM"),
    FixtureId = c(
      "binary_fixed", "binary_fixed",
      "polytomous_fixed", "polytomous_fixed"
    ),
    StepFacet = c(NA, "Item", NA, "Item"),
    QuadPoints = 31L,
    Maxit = 2000L,
    Reltol = 1e-12,
    Optimizer = "L-BFGS-B",
    EvidenceRole = "pilot_only_not_confirmation",
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_engine_scope_registry <- function() {
  resolve <- mfrmr_engine_get("resolve_mml_engine_plan")
  registry <- data.frame(
    ScopeId = c(
      "rsm_direct", "rsm_em", "rsm_hybrid",
      "pcm_direct", "pcm_em", "pcm_hybrid",
      "gpcm_direct", "gpcm_em", "gpcm_hybrid", "rsm_interaction_em",
      "pcm_population_hybrid"
    ),
    Model = c(
      "RSM", "RSM", "RSM", "PCM", "PCM", "PCM",
      "GPCM", "GPCM", "GPCM", "RSM", "PCM"
    ),
    Requested = c(
      "direct", "em", "hybrid", "direct", "em", "hybrid",
      "direct", "em", "hybrid", "em", "hybrid"
    ),
    PopulationActive = c(
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      FALSE, FALSE, FALSE, FALSE, TRUE
    ),
    InteractionActive = c(
      FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      FALSE, FALSE, FALSE, TRUE, FALSE
    ),
    stringsAsFactors = FALSE
  )
  plans <- lapply(seq_len(nrow(registry)), function(index) {
    resolve(
      method = "MML",
      model = registry$Model[index],
      requested = registry$Requested[index],
      population_active = registry$PopulationActive[index],
      interaction_active = registry$InteractionActive[index]
    )
  })
  registry$Used <- vapply(plans, `[[`, character(1L), "Used")
  registry$Fallback <- vapply(plans, function(plan) {
    isTRUE(plan$Fallback)
  }, logical(1L))
  registry$Detail <- vapply(plans, `[[`, character(1L), "Detail")
  registry$ParityScope <-
    registry$Model %in% c("RSM", "PCM") &
    !registry$PopulationActive &
    !registry$InteractionActive &
    !registry$Fallback &
    registry$Used == registry$Requested
  registry$SelectionAuthorized <- FALSE
  registry$ConfirmationAuthorized <- FALSE
  registry
}

mfrmr_engine_fit_args <- function(plan_row, fixture, engine) {
  engine <- as.character(engine)[1L]
  mfrmr_engine_assert(
    engine %in% mfrmr_engine_public_engines,
    "`engine` must be direct, em, or hybrid."
  )
  out <- list(
    data = fixture$data,
    person = "Person",
    facets = "Item",
    score = "Score",
    rating_min = fixture$rating_min,
    rating_max = fixture$rating_max,
    method = "MML",
    model = as.character(plan_row$Model),
    quad_points = as.integer(plan_row$QuadPoints),
    maxit = as.integer(plan_row$Maxit),
    reltol = as.numeric(plan_row$Reltol),
    optimizer = as.character(plan_row$Optimizer),
    mml_engine = engine
  )
  if (!is.na(plan_row$StepFacet) && nzchar(plan_row$StepFacet)) {
    out$step_facet <- as.character(plan_row$StepFacet)
  }
  out
}

mfrmr_engine_capture_fit <- function(args) {
  mfrmr_engine_assert(is.list(args), "`args` must be a fit argument list.")
  warnings <- character(0)
  started <- proc.time()[["elapsed"]]
  fit <- withCallingHandlers(
    suppressMessages(do.call(getExportedValue("mfrmr", "fit_mfrm"), args)),
    warning = function(condition) {
      warnings <<- c(warnings, conditionMessage(condition))
      invokeRestart("muffleWarning")
    }
  )
  elapsed <- proc.time()[["elapsed"]] - started
  list(
    fit = fit,
    elapsed = as.numeric(elapsed),
    warnings = unique(warnings)
  )
}

mfrmr_engine_common_direct_polish <- function(em_fit, plan_row) {
  context <- mfrmr_engine_get_helper("mfrmr_num_fit_context")(em_fit)
  warnings <- character(0)
  started <- proc.time()[["elapsed"]]
  opt <- withCallingHandlers(
    mfrmr_engine_get("run_mfrm_direct_optimization")(
      start = as.numeric(em_fit$opt$par),
      method = "MML",
      idx = context$idx,
      config = context$config,
      sizes = context$sizes,
      quad_points = as.integer(plan_row$QuadPoints),
      maxit = as.integer(plan_row$Maxit),
      reltol = as.numeric(plan_row$Reltol),
      quad = context$quad,
      optimizer = as.character(plan_row$Optimizer),
      suppress_convergence_warning = TRUE
    ),
    warning = function(condition) {
      warnings <<- c(warnings, conditionMessage(condition))
      invokeRestart("muffleWarning")
    }
  )
  elapsed <- proc.time()[["elapsed"]] - started
  list(
    opt = opt,
    start = as.numeric(em_fit$opt$par),
    elapsed = as.numeric(elapsed),
    warnings = unique(warnings),
    source_em_fit = em_fit
  )
}

mfrmr_engine_config_identity <- function(context) {
  config <- context$config
  list(
    model = config$model,
    n_cat = config$n_cat,
    facet_names = config$facet_names,
    step_facet = config$step_facet,
    slope_facet = config$slope_facet,
    interaction_specs = config$interaction_specs,
    gpcm_spec = config$gpcm_spec,
    population_active = isTRUE(config$population_spec$active),
    sizes = context$sizes,
    coordinates = context$coordinates,
    idx = context$idx,
    quad = context$quad
  )
}

mfrmr_engine_contexts_identical <- function(contexts) {
  mfrmr_engine_assert(
    is.list(contexts) &&
      identical(sort(names(contexts)), sort(mfrmr_engine_public_engines)),
    "Evaluator contexts must contain direct, em, and hybrid."
  )
  identities <- lapply(contexts, mfrmr_engine_config_identity)
  all(vapply(
    identities[-1L],
    identical,
    logical(1L),
    identities[[1L]]
  ))
}

mfrmr_engine_expanded_vector <- function(context, par) {
  par <- as.numeric(par)
  mfrmr_engine_assert(
    length(par) == nrow(context$coordinates) && all(is.finite(par)),
    "Expanded-parameter audit requires one complete free vector."
  )
  params <- mfrmr_engine_get("expand_params")(
    par,
    context$sizes,
    context$config
  )
  mfrmr_engine_assert(
    length(params$interactions) == 0L &&
      is.null(params$log_slopes) && is.null(params$slopes),
    "Engine parity currently supports additive equal-slope RSM/PCM only."
  )
  values <- numeric(0)
  labels <- character(0)
  append_values <- function(value, value_labels) {
    value <- as.numeric(value)
    value_labels <- as.character(value_labels)
    mfrmr_engine_assert(
      length(value) == length(value_labels) && all(is.finite(value)) &&
        all(!is.na(value_labels)) && all(nzchar(value_labels)),
      "Expanded-parameter labels and values are incomplete."
    )
    values <<- c(values, value)
    labels <<- c(labels, value_labels)
    invisible(NULL)
  }

  for (facet in names(params$facets)) {
    value <- params$facets[[facet]]
    level <- names(value)
    if (is.null(level) || any(!nzchar(level))) {
      level <- paste0("level_", seq_along(value))
    }
    append_values(value, paste("facet", facet, level, sep = "::"))
  }
  if (!is.null(params$steps)) {
    step_labels <- names(params$steps)
    if (is.null(step_labels) || any(!nzchar(step_labels))) {
      step_labels <- paste0("step_", seq_along(params$steps))
    }
    append_values(params$steps, paste0("shared_step::", step_labels))
  }
  if (!is.null(params$steps_mat)) {
    step_matrix <- as.matrix(params$steps_mat)
    row_labels <- rownames(step_matrix)
    column_labels <- colnames(step_matrix)
    if (is.null(row_labels) || any(!nzchar(row_labels))) {
      row_labels <- paste0("level_", seq_len(nrow(step_matrix)))
    }
    if (is.null(column_labels) || any(!nzchar(column_labels))) {
      column_labels <- paste0("step_", seq_len(ncol(step_matrix)))
    }
    append_values(
      as.vector(t(step_matrix)),
      as.vector(t(outer(
        row_labels,
        column_labels,
        function(row, column) paste("specific_step", row, column, sep = "::")
      )))
    )
  }
  mfrmr_engine_assert(
    length(values) > 0L && !anyDuplicated(labels),
    "Expanded-parameter audit produced no unique coordinates."
  )
  stats::setNames(values, labels)
}

mfrmr_engine_path_row <- function(plan_row, path, opt, context,
                                  elapsed, warnings,
                                  requested_engine, used_engine,
                                  fallback = FALSE,
                                  em_metadata = NULL,
                                  source_em_ready = NA,
                                  starting_par = NULL,
                                  source_em_par = NULL) {
  diagnostics <- opt$optimizer_diagnostics
  par <- as.numeric(opt$par)
  common_objective <- suppressWarnings(as.numeric(context$fn(par))[1L])
  common_score <- suppressWarnings(as.numeric(context$gr(par)))
  native_objective <- suppressWarnings(as.numeric(opt$value)[1L])
  complete <- length(par) == nrow(context$coordinates) &&
    all(is.finite(par)) && is.finite(common_objective) &&
    all(is.finite(common_score)) && is.finite(native_objective)
  em_metadata <- mfrmr_engine_or(em_metadata, list())
  started_from_raw_em <- if (
    !is.null(starting_par) && !is.null(source_em_par)
  ) {
    identical(as.numeric(starting_par), as.numeric(source_em_par))
  } else {
    NA
  }
  data.frame(
    Specification = mfrmr_engine_specification,
    ContractVersion = mfrmr_engine_contract,
    RunId = as.character(plan_row$RunId),
    ScenarioId = as.character(plan_row$ScenarioId),
    Model = as.character(plan_row$Model),
    Path = path,
    RequestedEngine = requested_engine,
    UsedEngine = used_engine,
    Fallback = isTRUE(fallback),
    ParitySolutionPath = path %in% mfrmr_engine_solution_paths,
    QuadPoints = as.integer(plan_row$QuadPoints),
    FreeDimension = length(par),
    RetainedVectorSHA256 = if (complete) {
      mfrmr_engine_vector_fingerprint(par)
    } else {
      NA_character_
    },
    StartingVectorSHA256 = if (!is.null(starting_par)) {
      mfrmr_engine_vector_fingerprint(starting_par)
    } else {
      NA_character_
    },
    SourceEMVectorSHA256 = if (!is.null(source_em_par)) {
      mfrmr_engine_vector_fingerprint(source_em_par)
    } else {
      NA_character_
    },
    StartedFromRawEM = as.logical(started_from_raw_em),
    ExpandedDimension = if (complete) {
      length(mfrmr_engine_expanded_vector(context, par))
    } else {
      NA_integer_
    },
    NativeObjective = native_objective,
    CommonObjective = common_objective,
    NativeCommonObjectiveAbsDifference = if (complete) {
      abs(native_objective - common_objective)
    } else {
      NA_real_
    },
    MaxAbsCommonScore = if (complete) max(abs(common_score)) else NA_real_,
    CommonScoreRMS = if (complete) sqrt(mean(common_score^2)) else NA_real_,
    ConvergenceCode = as.integer(diagnostics$ConvergenceCode),
    ConvergenceStatus = as.character(diagnostics$ConvergenceStatus),
    ConvergenceReason = as.character(diagnostics$ConvergenceReason),
    ConvergenceSeverity = as.character(diagnostics$ConvergenceSeverity),
    InferenceReady = identical(diagnostics$ConvergenceSeverity, "pass"),
    OptimizerMethod = as.character(diagnostics$OptimizerMethod),
    EMIterations = as.integer(mfrmr_engine_or(
      em_metadata$EMIterations,
      NA_integer_
    )),
    EMConverged = as.logical(mfrmr_engine_or(
      em_metadata$EMConverged,
      NA
    )),
    EMRelativeChange = as.numeric(
      mfrmr_engine_or(em_metadata$EMRelativeChange, NA_real_)
    ),
    SourceEMInferenceReady = as.logical(source_em_ready),
    ElapsedSeconds = as.numeric(elapsed),
    WarningCount = length(warnings),
    WarningText = paste(warnings, collapse = " | "),
    ReferenceStatus = if (complete) "review_complete" else "rejected",
    ObjectiveToleranceStatus = "pilot_required",
    ParameterToleranceStatus = "pilot_required",
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_engine_evaluate_vectors <- function(plan_row, contexts, vectors) {
  mfrmr_engine_assert(
    is.list(vectors) &&
      identical(sort(names(vectors)), sort(mfrmr_engine_all_paths)),
    "Common-vector evaluation requires all four declared paths."
  )
  context_identity <- mfrmr_engine_contexts_identical(contexts)
  rows <- list()
  row_index <- 1L
  for (path in names(vectors)) {
    par <- as.numeric(vectors[[path]])
    for (engine in names(contexts)) {
      context <- contexts[[engine]]
      objective <- tryCatch(
        suppressWarnings(as.numeric(context$fn(par))[1L]),
        error = function(condition) NA_real_
      )
      score <- tryCatch(
        suppressWarnings(as.numeric(context$gr(par))),
        error = function(condition) rep(NA_real_, nrow(context$coordinates))
      )
      coordinate <- context$coordinates
      if (length(score) != nrow(coordinate)) {
        score <- rep(NA_real_, nrow(coordinate))
      }
      row <- coordinate[, c(
        "CoordinateIndex", "ParameterClass", "CoordinateLabel",
        "CoordinateSystem"
      )]
      row$Specification <- mfrmr_engine_specification
      row$ContractVersion <- mfrmr_engine_contract
      row$RunId <- as.character(plan_row$RunId)
      row$ScenarioId <- as.character(plan_row$ScenarioId)
      row$Model <- as.character(plan_row$Model)
      row$EvaluatedPath <- path
      row$EvaluatorEngine <- engine
      row$Objective <- objective
      row$Score <- score
      row$ContextStructureIdentical <- context_identity
      row$SelectionAuthorized <- FALSE
      row$ConfirmationAuthorized <- FALSE
      rows[[row_index]] <- row
      row_index <- row_index + 1L
    }
  }
  do.call(rbind, rows)
}

mfrmr_engine_common_vector_summarize <- function(evaluations) {
  required <- c(
    "RunId", "ScenarioId", "Model", "EvaluatedPath", "EvaluatorEngine",
    "CoordinateIndex", "Objective", "Score", "ContextStructureIdentical"
  )
  mfrmr_engine_assert(
    is.data.frame(evaluations) && nrow(evaluations) > 0L &&
      all(required %in% names(evaluations)),
    "`evaluations` does not satisfy the common-vector contract."
  )
  mfrmr_engine_assert(
    all(vapply(
      c("RunId", "ScenarioId", "Model", "EvaluatedPath", "EvaluatorEngine"),
      function(field) {
        value <- as.character(evaluations[[field]])
        all(!is.na(value)) && all(nzchar(value))
      },
      logical(1L)
    )),
    "Common-vector rows require complete identity labels."
  )
  key <- interaction(
    evaluations$RunId,
    evaluations$EvaluatedPath,
    drop = TRUE,
    lex.order = TRUE
  )
  rows <- lapply(split(evaluations, key), function(group) {
    engines <- sort(unique(as.character(group$EvaluatorEngine)))
    coordinates <- sort(unique(as.integer(group$CoordinateIndex)))
    row_key <- paste(group$EvaluatorEngine, group$CoordinateIndex, sep = "|")
    expected_rows <- length(mfrmr_engine_public_engines) * length(coordinates)
    structure_complete <- identical(
      engines,
      sort(mfrmr_engine_public_engines)
    ) && length(coordinates) > 0L && nrow(group) == expected_rows &&
      !anyDuplicated(row_key) &&
      all(group$ContextStructureIdentical %in% TRUE)
    objectives <- vapply(split(group$Objective, group$EvaluatorEngine), function(value) {
      value <- unique(as.numeric(value))
      if (length(value) != 1L || !is.finite(value)) return(NA_real_)
      value
    }, numeric(1L))
    score_ranges <- vapply(
      split(group$Score, as.integer(group$CoordinateIndex)),
      function(value) {
        value <- as.numeric(value)
        if (length(value) != length(mfrmr_engine_public_engines) ||
            any(!is.finite(value))) {
          return(NA_real_)
        }
        diff(range(value))
      },
      numeric(1L)
    )
    complete <- structure_complete &&
      length(objectives) == length(mfrmr_engine_public_engines) &&
      all(is.finite(objectives)) && all(is.finite(score_ranges))
    objective_range <- if (complete) diff(range(objectives)) else NA_real_
    max_score_range <- if (complete) max(score_ranges) else NA_real_
    evaluator_identity <- complete &&
      objective_range <= mfrmr_engine_evaluator_identity_tolerance &&
      max_score_range <= mfrmr_engine_evaluator_identity_tolerance
    data.frame(
      Specification = mfrmr_engine_specification,
      ContractVersion = mfrmr_engine_contract,
      RunId = as.character(group$RunId[1L]),
      ScenarioId = as.character(group$ScenarioId[1L]),
      Model = as.character(group$Model[1L]),
      EvaluatedPath = as.character(group$EvaluatedPath[1L]),
      EvaluatorCount = length(engines),
      CoordinateCount = length(coordinates),
      ObjectiveEvaluatorRange = objective_range,
      MaxScoreEvaluatorRange = max_score_range,
      ContextStructureIdentical = structure_complete,
      CommonEvaluatorIdentityObserved = evaluator_identity,
      ReferenceStatus = if (complete) "review_complete" else "rejected",
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_engine_pairwise_results <- function(plan_row, context, vectors,
                                           path_results,
                                           common_vector_summary) {
  solution_vectors <- vectors[mfrmr_engine_solution_paths]
  pairs <- utils::combn(names(solution_vectors), 2L, simplify = FALSE)
  rows <- lapply(pairs, function(pair) {
    left <- as.numeric(solution_vectors[[pair[1L]]])
    right <- as.numeric(solution_vectors[[pair[2L]]])
    left_expanded <- mfrmr_engine_expanded_vector(context, left)
    right_expanded <- mfrmr_engine_expanded_vector(context, right)
    labels_identical <- identical(names(left_expanded), names(right_expanded))
    left_path <- path_results[path_results$Path == pair[1L], , drop = FALSE]
    right_path <- path_results[path_results$Path == pair[2L], , drop = FALSE]
    common_rows <- common_vector_summary[
      common_vector_summary$EvaluatedPath %in% pair,
      ,
      drop = FALSE
    ]
    complete <- length(left) == length(right) && length(left) > 0L &&
      all(is.finite(left)) && all(is.finite(right)) && labels_identical &&
      nrow(left_path) == 1L && nrow(right_path) == 1L &&
      nrow(common_rows) == 2L &&
      all(common_rows$CommonEvaluatorIdentityObserved %in% TRUE)
    objective_difference <- if (complete) {
      abs(left_path$CommonObjective - right_path$CommonObjective)
    } else {
      NA_real_
    }
    free_difference <- if (complete) max(abs(left - right)) else NA_real_
    free_scaled_difference <- if (complete) {
      max(abs(left - right) / pmax(1, abs(left), abs(right)))
    } else {
      NA_real_
    }
    expanded_difference <- if (complete) {
      max(abs(left_expanded - right_expanded))
    } else {
      NA_real_
    }
    both_ready <- complete &&
      isTRUE(left_path$InferenceReady) && isTRUE(right_path$InferenceReady)
    data.frame(
      Specification = mfrmr_engine_specification,
      ContractVersion = mfrmr_engine_contract,
      RunId = as.character(plan_row$RunId),
      ScenarioId = as.character(plan_row$ScenarioId),
      Model = as.character(plan_row$Model),
      LeftPath = pair[1L],
      RightPath = pair[2L],
      ObjectiveAbsDifference = as.numeric(objective_difference),
      MaxFreeParameterAbsDifference = free_difference,
      MaxFreeParameterScaledDifference = free_scaled_difference,
      MaxExpandedParameterAbsDifference = expanded_difference,
      LeftMaxAbsScore = as.numeric(left_path$MaxAbsCommonScore),
      RightMaxAbsScore = as.numeric(right_path$MaxAbsCommonScore),
      BothInferenceReady = both_ready,
      CommonEvaluatorIdentityObserved = complete,
      ReferenceStatus = if (complete) "review_complete" else "rejected",
      ObjectiveToleranceStatus = "pilot_required",
      ParameterToleranceStatus = "pilot_required",
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_engine_global_summary <- function(path_results, pairwise_results,
                                        common_vector_summary,
                                        fixture_manifest,
                                        scope_registry) {
  required_path <- c(
    "RunId", "Path", "RequestedEngine", "UsedEngine", "Fallback",
    "ParitySolutionPath", "InferenceReady", "ReferenceStatus",
    "NativeCommonObjectiveAbsDifference", "MaxAbsCommonScore",
    "RetainedVectorSHA256", "StartingVectorSHA256",
    "SourceEMVectorSHA256", "StartedFromRawEM",
    "SelectionAuthorized", "ConfirmationAuthorized"
  )
  required_pair <- c(
    "RunId", "LeftPath", "RightPath", "ObjectiveAbsDifference",
    "MaxFreeParameterAbsDifference", "MaxExpandedParameterAbsDifference",
    "BothInferenceReady", "CommonEvaluatorIdentityObserved",
    "ReferenceStatus", "SelectionAuthorized", "ConfirmationAuthorized"
  )
  required_common <- c(
    "RunId", "EvaluatedPath", "CommonEvaluatorIdentityObserved",
    "ReferenceStatus", "ObjectiveEvaluatorRange", "MaxScoreEvaluatorRange",
    "SelectionAuthorized", "ConfirmationAuthorized"
  )
  mfrmr_engine_assert(
    is.data.frame(path_results) && all(required_path %in% names(path_results)),
    "`path_results` is incomplete."
  )
  mfrmr_engine_assert(
    is.data.frame(pairwise_results) &&
      all(required_pair %in% names(pairwise_results)),
    "`pairwise_results` is incomplete."
  )
  mfrmr_engine_assert(
    is.data.frame(common_vector_summary) &&
      all(required_common %in% names(common_vector_summary)),
    "`common_vector_summary` is incomplete."
  )
  mfrmr_engine_assert(
    is.data.frame(fixture_manifest) &&
      all(c("FixtureId", "SHA256") %in% names(fixture_manifest)),
    "`fixture_manifest` is incomplete."
  )
  mfrmr_engine_assert(
    is.data.frame(scope_registry) &&
      all(c("ScopeId", "Used", "Fallback", "ParityScope") %in%
          names(scope_registry)),
    "`scope_registry` is incomplete."
  )

  expected_runs <- mfrmr_engine_plan()$RunId
  expected_path_keys <- as.vector(outer(
    expected_runs,
    mfrmr_engine_all_paths,
    paste,
    sep = "|"
  ))
  path_keys <- paste(path_results$RunId, path_results$Path, sep = "|")
  paths_complete <- nrow(path_results) == length(expected_path_keys) &&
    all(!is.na(path_keys)) &&
    identical(sort(path_keys), sort(expected_path_keys)) &&
    !anyDuplicated(path_keys) &&
    all(path_results$ReferenceStatus %in% "review_complete") &&
    all(is.finite(path_results$NativeCommonObjectiveAbsDifference)) &&
    all(path_results$NativeCommonObjectiveAbsDifference <=
          mfrmr_engine_evaluator_identity_tolerance) &&
    all(is.finite(path_results$MaxAbsCommonScore)) &&
    all(!is.na(path_results$RetainedVectorSHA256)) &&
    all(grepl("^[0-9a-f]{64}$", path_results$RetainedVectorSHA256)) &&
    all(path_results$SelectionAuthorized %in% FALSE) &&
    all(path_results$ConfirmationAuthorized %in% FALSE)

  public_rows <- path_results[path_results$Path %in%
    c("direct", "hybrid", "em_raw"), , drop = FALSE]
  expected_public_used <- c(
    direct = "direct", hybrid = "hybrid", em_raw = "em"
  )
  public_identity_complete <- nrow(public_rows) ==
    length(expected_runs) * length(expected_public_used) &&
    all(public_rows$Fallback %in% FALSE) &&
    all(vapply(seq_len(nrow(public_rows)), function(index) {
      expected <- unname(
        expected_public_used[as.character(public_rows$Path[index])]
      )
      identical(as.character(public_rows$RequestedEngine[index]), expected) &&
        identical(as.character(public_rows$UsedEngine[index]), expected)
    }, logical(1L)))

  mandatory <- path_results[
    path_results$Path %in% mfrmr_engine_solution_paths,
    ,
    drop = FALSE
  ]
  mandatory_ready <- nrow(mandatory) ==
    length(expected_runs) * length(mfrmr_engine_solution_paths) &&
    all(mandatory$ParitySolutionPath %in% TRUE) &&
    all(mandatory$Fallback %in% FALSE) &&
    all(mandatory$InferenceReady %in% TRUE) &&
    all(vapply(seq_len(nrow(mandatory)), function(index) {
      path <- as.character(mandatory$Path[index])
      expected_used <- c(
        direct = "direct",
        hybrid = "hybrid",
        em_plus_common_direct_polish = "em_plus_common_direct_polish"
      )[[path]]
      identical(as.character(mandatory$UsedEngine[index]), expected_used)
    }, logical(1L)))

  em_plus <- path_results[
    path_results$Path == "em_plus_common_direct_polish",
    ,
    drop = FALSE
  ]
  em_start_identity_complete <- nrow(em_plus) == length(expected_runs) &&
    all(em_plus$StartedFromRawEM %in% TRUE) &&
    all(!is.na(em_plus$StartingVectorSHA256)) &&
    all(em_plus$StartingVectorSHA256 == em_plus$SourceEMVectorSHA256)

  solution_pairs <- utils::combn(
    mfrmr_engine_solution_paths,
    2L,
    simplify = FALSE
  )
  pair_labels <- vapply(
    solution_pairs,
    paste,
    character(1L),
    collapse = "|"
  )
  expected_pair_keys <- as.vector(outer(
    expected_runs,
    pair_labels,
    paste,
    sep = "|"
  ))
  pair_keys <- paste(
    pairwise_results$RunId,
    pairwise_results$LeftPath,
    pairwise_results$RightPath,
    sep = "|"
  )
  pairs_complete <- nrow(pairwise_results) == length(expected_pair_keys) &&
    all(!is.na(pair_keys)) &&
    identical(sort(pair_keys), sort(expected_pair_keys)) &&
    !anyDuplicated(pair_keys) &&
    all(pairwise_results$ReferenceStatus %in% "review_complete") &&
    all(pairwise_results$BothInferenceReady %in% TRUE) &&
    all(pairwise_results$CommonEvaluatorIdentityObserved %in% TRUE) &&
    all(is.finite(pairwise_results$ObjectiveAbsDifference)) &&
    all(is.finite(pairwise_results$MaxFreeParameterAbsDifference)) &&
    all(is.finite(pairwise_results$MaxExpandedParameterAbsDifference)) &&
    all(pairwise_results$SelectionAuthorized %in% FALSE) &&
    all(pairwise_results$ConfirmationAuthorized %in% FALSE)

  expected_common_keys <- expected_path_keys
  common_keys <- paste(
    common_vector_summary$RunId,
    common_vector_summary$EvaluatedPath,
    sep = "|"
  )
  common_complete <- nrow(common_vector_summary) ==
    length(expected_common_keys) &&
    identical(sort(common_keys), sort(expected_common_keys)) &&
    !anyDuplicated(common_keys) &&
    all(common_vector_summary$ReferenceStatus %in% "review_complete") &&
    all(common_vector_summary$CommonEvaluatorIdentityObserved %in% TRUE) &&
    all(common_vector_summary$SelectionAuthorized %in% FALSE) &&
    all(common_vector_summary$ConfirmationAuthorized %in% FALSE)

  expected_fixtures <- c("binary_fixed", "polytomous_fixed")
  fixtures_complete <- nrow(fixture_manifest) == 2L &&
    all(!is.na(fixture_manifest$FixtureId)) &&
    identical(
      sort(as.character(fixture_manifest$FixtureId)),
      sort(expected_fixtures)
    ) && !anyDuplicated(fixture_manifest$FixtureId) &&
    all(!is.na(fixture_manifest$SHA256)) &&
    all(grepl("^[0-9a-f]{64}$", fixture_manifest$SHA256))

  expected_scope_ids <- c(
    "rsm_direct", "rsm_em", "rsm_hybrid",
    "pcm_direct", "pcm_em", "pcm_hybrid",
    "gpcm_direct", "gpcm_em", "gpcm_hybrid", "rsm_interaction_em",
    "pcm_population_hybrid"
  )
  scope_identity_complete <- nrow(scope_registry) ==
    length(expected_scope_ids) &&
    identical(
      sort(as.character(scope_registry$ScopeId)),
      sort(expected_scope_ids)
    ) && !anyDuplicated(scope_registry$ScopeId)
  gpcm_scope <- scope_registry[scope_registry$Model == "GPCM", , drop = FALSE]
  gpcm_direct <- gpcm_scope[
    gpcm_scope$Requested == "direct",
    ,
    drop = FALSE
  ]
  gpcm_fallback <- gpcm_scope[
    gpcm_scope$Requested %in% c("em", "hybrid"),
    ,
    drop = FALSE
  ]
  fallback_scope_complete <- scope_identity_complete &&
    nrow(gpcm_scope) == 3L && nrow(gpcm_direct) == 1L &&
    gpcm_direct$Used == "direct" && !gpcm_direct$Fallback &&
    !gpcm_direct$ParityScope && nrow(gpcm_fallback) == 2L &&
    all(gpcm_fallback$Fallback %in% TRUE) &&
    all(gpcm_fallback$Used %in% "direct") &&
    all(gpcm_scope$ParityScope %in% FALSE) &&
    all(scope_registry$ParityScope[
      scope_registry$ScopeId %in% c(
        "rsm_direct", "rsm_em", "rsm_hybrid",
        "pcm_direct", "pcm_em", "pcm_hybrid"
      )
    ] %in% TRUE) &&
    all(scope_registry$Fallback[
      scope_registry$ScopeId %in% c(
        "rsm_interaction_em", "pcm_population_hybrid"
      )
    ] %in% TRUE)

  raw_em <- path_results[path_results$Path == "em_raw", , drop = FALSE]
  data.frame(
    Specification = mfrmr_engine_specification,
    ContractVersion = mfrmr_engine_contract,
    Status = "review",
    FixedRunCount = length(unique(path_results$RunId)),
    FixedFixtureCount = nrow(fixture_manifest),
    FixedFixturesComplete = fixtures_complete,
    AllPathReferencesComplete = paths_complete,
    PublicEngineIdentityComplete = public_identity_complete,
    EMPolishStartIdentityComplete = em_start_identity_complete,
    AllMandatoryPathsInferenceReady = mandatory_ready,
    RawEMInferenceReadyCount = sum(raw_em$InferenceReady %in% TRUE),
    RawEMPathCount = nrow(raw_em),
    AllCommonEvaluatorIdentitiesObserved = common_complete,
    AllPairwiseReferencesComplete = pairs_complete,
    FallbackScopeComplete = fallback_scope_complete,
    MaxObjectiveEvaluatorRange = if (common_complete) {
      max(common_vector_summary$ObjectiveEvaluatorRange)
    } else {
      NA_real_
    },
    MaxScoreEvaluatorRange = if (common_complete) {
      max(common_vector_summary$MaxScoreEvaluatorRange)
    } else {
      NA_real_
    },
    MaxPairwiseObjectiveAbsDifference = if (pairs_complete) {
      max(pairwise_results$ObjectiveAbsDifference)
    } else {
      NA_real_
    },
    MaxPairwiseFreeParameterAbsDifference = if (pairs_complete) {
      max(pairwise_results$MaxFreeParameterAbsDifference)
    } else {
      NA_real_
    },
    MaxPairwiseExpandedParameterAbsDifference = if (pairs_complete) {
      max(pairwise_results$MaxExpandedParameterAbsDifference)
    } else {
      NA_real_
    },
    MaxMandatoryPathScore = if (mandatory_ready) {
      max(mandatory$MaxAbsCommonScore)
    } else {
      NA_real_
    },
    ObjectiveToleranceStatus = "pilot_required",
    ParameterToleranceStatus = "pilot_required",
    GpcmEngineParityStatus = "not_applicable_single_supported_engine",
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_run_mml_engine_parity_pilot <- function() {
  mfrmr_engine_require_helpers()
  mfrmr_engine_namespace()
  plan <- mfrmr_engine_plan()
  fixtures <- list(
    binary_fixed = mfrmr_engine_get_helper("mfrmr_num_fixture")(
      "binary_fixed"
    ),
    polytomous_fixed = mfrmr_engine_get_helper("mfrmr_num_fixture")(
      "polytomous_fixed"
    )
  )
  fixture_manifest <- do.call(rbind, lapply(fixtures, function(fixture) {
    data.frame(
      FixtureId = fixture$fixture_id,
      Seed = fixture$seed,
      Persons = length(fixture$persons),
      Items = length(fixture$items),
      RatingMin = fixture$rating_min,
      RatingMax = fixture$rating_max,
      Rows = nrow(fixture$data),
      SHA256 = fixture$sha256,
      stringsAsFactors = FALSE
    )
  }))

  path_rows <- vector("list", nrow(plan))
  evaluation_rows <- vector("list", nrow(plan))
  common_rows <- vector("list", nrow(plan))
  pair_rows <- vector("list", nrow(plan))
  retained <- vector("list", nrow(plan))
  names(retained) <- plan$RunId

  for (index in seq_len(nrow(plan))) {
    plan_row <- plan[index, , drop = FALSE]
    fixture <- fixtures[[as.character(plan_row$FixtureId)]]
    captures <- lapply(mfrmr_engine_public_engines, function(engine) {
      mfrmr_engine_capture_fit(
        mfrmr_engine_fit_args(plan_row, fixture, engine)
      )
    })
    names(captures) <- mfrmr_engine_public_engines
    fits <- lapply(captures, `[[`, "fit")
    contexts <- lapply(
      fits,
      mfrmr_engine_get_helper("mfrmr_num_fit_context")
    )
    mfrmr_engine_assert(
      mfrmr_engine_contexts_identical(contexts),
      paste0(
        "The ", plan_row$RunId,
        " direct/EM/hybrid evaluator contexts are not structurally identical."
      )
    )

    for (engine in mfrmr_engine_public_engines) {
      fit <- fits[[engine]]
      mfrmr_engine_assert(
        identical(as.character(fit$summary$MMLEngineRequested[1L]), engine) &&
          identical(as.character(fit$summary$MMLEngineUsed[1L]), engine) &&
          !isTRUE(fit$opt$mml_engine$Fallback),
        paste0(
          "The ", plan_row$RunId, " ", engine,
          " fit did not retain the required non-fallback engine identity."
        )
      )
    }

    polish <- mfrmr_engine_common_direct_polish(fits$em, plan_row)
    vectors <- list(
      direct = as.numeric(fits$direct$opt$par),
      hybrid = as.numeric(fits$hybrid$opt$par),
      em_raw = as.numeric(fits$em$opt$par),
      em_plus_common_direct_polish = as.numeric(polish$opt$par)
    )
    retained[[as.character(plan_row$RunId)]] <- vectors

    direct_metadata <- fits$direct$opt$mml_engine
    hybrid_metadata <- fits$hybrid$opt$mml_engine
    em_metadata <- fits$em$opt$mml_engine
    path_rows[[index]] <- rbind(
      mfrmr_engine_path_row(
        plan_row, "direct", fits$direct$opt, contexts$direct,
        captures$direct$elapsed, captures$direct$warnings,
        "direct", "direct", direct_metadata$Fallback,
        em_metadata = direct_metadata
      ),
      mfrmr_engine_path_row(
        plan_row, "hybrid", fits$hybrid$opt, contexts$direct,
        captures$hybrid$elapsed, captures$hybrid$warnings,
        "hybrid", "hybrid", hybrid_metadata$Fallback,
        em_metadata = hybrid_metadata
      ),
      mfrmr_engine_path_row(
        plan_row, "em_raw", fits$em$opt, contexts$direct,
        captures$em$elapsed, captures$em$warnings,
        "em", "em", em_metadata$Fallback,
        em_metadata = em_metadata,
        source_em_ready = fits$em$summary$InferenceReady[1L],
        source_em_par = fits$em$opt$par
      ),
      mfrmr_engine_path_row(
        plan_row, "em_plus_common_direct_polish", polish$opt,
        contexts$direct, polish$elapsed, polish$warnings,
        "em", "em_plus_common_direct_polish", FALSE,
        em_metadata = em_metadata,
        source_em_ready = fits$em$summary$InferenceReady[1L],
        starting_par = polish$start,
        source_em_par = fits$em$opt$par
      )
    )
    path_rows[[index]]$FixtureSHA256 <- fixture$sha256

    evaluation_rows[[index]] <- mfrmr_engine_evaluate_vectors(
      plan_row,
      contexts,
      vectors
    )
    common_rows[[index]] <- mfrmr_engine_common_vector_summarize(
      evaluation_rows[[index]]
    )
    pair_rows[[index]] <- mfrmr_engine_pairwise_results(
      plan_row,
      contexts$direct,
      vectors,
      path_rows[[index]],
      common_rows[[index]]
    )
  }

  path_results <- do.call(rbind, path_rows)
  evaluations <- do.call(rbind, evaluation_rows)
  common_vector_summary <- do.call(rbind, common_rows)
  pairwise_results <- do.call(rbind, pair_rows)
  scope_registry <- mfrmr_engine_scope_registry()
  summary <- mfrmr_engine_global_summary(
    path_results,
    pairwise_results,
    common_vector_summary,
    fixture_manifest,
    scope_registry
  )
  out <- list(
    specification = mfrmr_engine_specification,
    contract_version = mfrmr_engine_contract,
    dependency_contract = mfrmr_engine_dependency_contract,
    status = "review",
    plan = plan,
    fixture_manifest = fixture_manifest,
    scope_registry = scope_registry,
    path_results = path_results,
    common_vector_evaluations = evaluations,
    common_vector_summary = common_vector_summary,
    pairwise_results = pairwise_results,
    retained_vectors = retained,
    summary = summary,
    notes = c(
      "Raw EM is diagnostic and cannot replace the common stationarity gate.",
      "EM-plus-common-direct-polish starts exactly from the converged raw-EM retained vector.",
      "Every retained vector is reevaluated through direct, EM, and hybrid contexts at identical quadrature and constraints.",
      "GPCM, interaction, and latent-regression fallbacks are scope guards, not independent engine evidence.",
      "Observed objective and parameter differences are pilot data; no tolerance is frozen."
    ),
    selection_authorized = FALSE,
    confirmation_authorized = FALSE
  )
  class(out) <- c("mfrmr_mml_engine_parity_pilot", class(out))
  out
}
