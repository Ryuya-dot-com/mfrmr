# mfrmr 0.2.3 common-GHQ information-criterion pilot
#
# This repository-only helper measures numerical integration drift while every
# candidate's retained free-parameter vector is held fixed. It deliberately
# does not refit models, calibrate a release threshold, or authorize
# confirmation. Run it only after loading the development package, for example:
#
#   pkgload::load_all(".")
#   source("inst/validation/ic-integration-pilot-0.2.3.R")
#   pilot <- mfrmr_run_ic_integration_pilot(
#     fits = list(RSM = fit_rsm, PCM = fit_pcm),
#     quad_points = c(7, 15, 31, 61, 91, 121),
#     reference_quad = 121,
#     core_quad_points = c(31, 61, 91, 121)
#   )
#   print(pilot)
#
# The fixed-vector policy isolates evaluation noise. A separate, later pilot
# must assess refit-at-each-grid optimization plus integration sensitivity.

mfrmr_ic_integration_specification <- "0.2.3-draft.5"
mfrmr_ic_integration_contract <- "mfrmr_ic_person_v2"
mfrmr_ic_integration_policy <- "fixed_retained_vector_common_ghq_v1"

mfrmr_ic_integration_internal <- function(name) {
  if (!requireNamespace("mfrmr", quietly = TRUE)) {
    stop(
      "The development package must be loaded before running the IC integration pilot.",
      call. = FALSE
    )
  }
  namespace <- asNamespace("mfrmr")
  if (!exists(name, envir = namespace, inherits = FALSE)) {
    stop(
      "The loaded mfrmr namespace does not provide the required internal `",
      name, "`. Load the current development source tree and retry.",
      call. = FALSE
    )
  }
  get(name, envir = namespace, inherits = FALSE)
}

mfrmr_ic_integration_git_identity <- function(pkg_dir = ".") {
  pkg_dir <- normalizePath(pkg_dir, winslash = "/", mustWork = TRUE)
  old_dir <- getwd()
  on.exit(setwd(old_dir), add = TRUE)
  setwd(pkg_dir)
  commit <- tryCatch(
    system2("git", c("rev-parse", "HEAD"), stdout = TRUE, stderr = FALSE),
    error = function(e) character(0)
  )
  if (length(commit) != 1L || !nzchar(commit)) return("unknown-working-tree")
  dirty <- tryCatch(
    length(system2("git", c("status", "--porcelain"),
                   stdout = TRUE, stderr = FALSE)) > 0L,
    error = function(e) TRUE
  )
  paste0(commit, if (dirty) "+working-tree" else "")
}

mfrmr_ic_integration_validate_grid <- function(quad_points,
                                                reference_quad,
                                                core_quad_points) {
  integer_tolerance <- sqrt(.Machine$double.eps)
  valid_integer <- function(x) {
    is.numeric(x) && length(x) > 0L && all(is.finite(x)) &&
      all(x >= 1) && all(abs(x - round(x)) <= integer_tolerance)
  }
  if (!valid_integer(quad_points)) {
    stop("`quad_points` must contain finite positive integers.", call. = FALSE)
  }
  quad_points <- sort(unique(as.integer(round(quad_points))))
  if (!valid_integer(reference_quad) || length(reference_quad) != 1L) {
    stop("`reference_quad` must be one finite positive integer.", call. = FALSE)
  }
  reference_quad <- as.integer(round(reference_quad))
  if (!reference_quad %in% quad_points) {
    stop("`reference_quad` must be included in `quad_points`.", call. = FALSE)
  }
  if (is.null(core_quad_points)) {
    core_quad_points <- quad_points[quad_points >= 31L]
    if (length(core_quad_points) == 0L) core_quad_points <- reference_quad
  }
  if (!valid_integer(core_quad_points)) {
    stop("`core_quad_points` must contain finite positive integers.",
         call. = FALSE)
  }
  core_quad_points <- sort(unique(as.integer(round(core_quad_points))))
  if (!all(core_quad_points %in% quad_points)) {
    stop("Every `core_quad_points` value must be included in `quad_points`.",
         call. = FALSE)
  }
  if (!reference_quad %in% core_quad_points) {
    stop("`reference_quad` must be included in `core_quad_points`.",
         call. = FALSE)
  }
  list(
    quad_points = quad_points,
    reference_quad = reference_quad,
    core_quad_points = core_quad_points
  )
}

mfrmr_ic_integration_normalize_column <- function(x) {
  if (inherits(x, "POSIXt")) {
    return(format(x, "%Y-%m-%dT%H:%M:%OS6Z", tz = "UTC"))
  }
  if (inherits(x, "Date")) return(format(x, "%Y-%m-%d"))
  if (is.factor(x)) x <- as.character(x)
  if (is.numeric(x)) {
    return(ifelse(is.na(x), "NA", sprintf("%.17g", x)))
  }
  if (is.logical(x)) {
    return(ifelse(is.na(x), "NA", ifelse(x, "TRUE", "FALSE")))
  }
  if (is.character(x)) return(ifelse(is.na(x), "NA", x))
  vapply(x, function(value) {
    paste(capture.output(dput(value)), collapse = "")
  }, character(1))
}

mfrmr_ic_integration_canonical_data <- function(data) {
  if (is.null(data) || !is.data.frame(data)) return(NULL)
  data <- as.data.frame(data, stringsAsFactors = FALSE)
  data <- data[, sort(names(data)), drop = FALSE]
  data[] <- lapply(data, mfrmr_ic_integration_normalize_column)
  if (nrow(data) > 0L && ncol(data) > 0L) {
    ordering <- do.call(
      order,
      c(data, list(na.last = TRUE, method = "radix"))
    )
    data <- data[ordering, , drop = FALSE]
  }
  rownames(data) <- NULL
  data
}

mfrmr_ic_integration_check_common_basis <- function(fits) {
  reference_data <- mfrmr_ic_integration_canonical_data(fits[[1]]$prep$data)
  same_data <- !is.null(reference_data) && all(vapply(fits[-1], function(fit) {
    identical(
      reference_data,
      mfrmr_ic_integration_canonical_data(fit$prep$data)
    )
  }, logical(1)))
  if (!same_data) {
    stop(
      "IC integration candidates must contain the same prepared observations.",
      call. = FALSE
    )
  }

  normalize_signature <- mfrmr_ic_integration_internal(
    "normalize_compare_signature"
  )
  same_component <- mfrmr_ic_integration_internal("same_signature_component")
  signatures <- lapply(fits, normalize_signature)
  components <- c(
    "person", "facets", "score", "rating_min", "rating_max", "score_map",
    "noncenter_facet", "dummy_facets", "positive_facets", "anchors",
    "group_anchors"
  )
  component_checks <- vapply(components, function(component) {
    all(vapply(signatures[-1], function(signature) {
      same_component(signatures[[1]][[component]], signature[[component]])
    }, logical(1)))
  }, logical(1))
  if (!all(component_checks)) {
    stop(
      "IC integration candidates differ in likelihood coding or constraints: ",
      paste(names(component_checks)[!component_checks], collapse = ", "),
      ".",
      call. = FALSE
    )
  }
  component_checks
}

mfrmr_ic_integration_validate_fits <- function(fits,
                                                labels,
                                                quad_points,
                                                require_inference_ready,
                                                require_common_source_quad) {
  extract_contract <- mfrmr_ic_integration_internal(
    "mfrm_extract_fit_ic_contract"
  )
  convergence_state <- mfrmr_ic_integration_internal("mfrm_convergence_state")

  rows <- lapply(seq_along(fits), function(index) {
    fit <- fits[[index]]
    if (!inherits(fit, "mfrm_fit") || inherits(fit, "mfrm_imported_fit")) {
      stop(
        "Candidate `", labels[index],
        "` must be a native `mfrm_fit` with a retained objective and vector.",
        call. = FALSE
      )
    }
    method <- toupper(as.character(fit$config$method)[1])
    if (!identical(method, "MML")) {
      stop("Candidate `", labels[index], "` is not an MML fit.",
           call. = FALSE)
    }
    parameters <- suppressWarnings(as.numeric(fit$opt$par))
    stored_objective <- suppressWarnings(as.numeric(fit$opt$value)[1])
    if (length(parameters) == 0L || any(!is.finite(parameters)) ||
        !is.finite(stored_objective)) {
      stop(
        "Candidate `", labels[index],
        "` lacks a finite retained parameter vector or objective.",
        call. = FALSE
      )
    }
    source_quad <- suppressWarnings(as.integer(
      fit$config$estimation_control$quad_points
    ))
    if (length(source_quad) != 1L || !is.finite(source_quad) ||
        source_quad < 1L || !source_quad %in% quad_points) {
      stop(
        "Candidate `", labels[index],
        "` must have a source quadrature count included in `quad_points`.",
        call. = FALSE
      )
    }
    contract <- extract_contract(fit)
    if (nrow(contract) != 1L ||
        !identical(as.character(contract$ICContractVersion[1]),
                   mfrmr_ic_integration_contract) ||
        !isTRUE(contract$StoredICConsistent[1]) ||
        !isTRUE(contract$ICEligible[1])) {
      stop(
        "Candidate `", labels[index],
        "` does not satisfy the current stored MML IC contract.",
        call. = FALSE
      )
    }
    convergence <- convergence_state(fit)
    inference_ready <- isTRUE(convergence$inference_ready)
    if (isTRUE(require_inference_ready) && !inference_ready) {
      stop(
        "Candidate `", labels[index],
        "` is not inference-ready; integration evidence cannot rescue an ",
        "unresolved retained solution.",
        call. = FALSE
      )
    }
    data.frame(
      Label = labels[index],
      Model = toupper(as.character(fit$config$model)[1]),
      SourceQuadraturePoints = source_quad,
      StoredObjective = stored_objective,
      Npar = length(parameters),
      Persons = as.integer(contract$Persons[1]),
      InferenceReady = inference_ready,
      stringsAsFactors = FALSE
    )
  })
  metadata <- do.call(rbind, rows)
  if (isTRUE(require_common_source_quad) &&
      length(unique(metadata$SourceQuadraturePoints)) != 1L) {
    stop(
      "Candidates were optimized with different source quadrature counts. ",
      "Use a common source grid before the primary integration pilot.",
      call. = FALSE
    )
  }
  metadata
}

mfrmr_ic_integration_evaluate_fit <- function(fit,
                                               label,
                                               quad_points,
                                               objective_tolerance) {
  build_indices <- mfrmr_ic_integration_internal("build_indices")
  build_sizes <- mfrmr_ic_integration_internal("build_param_sizes")
  make_quad <- mfrmr_ic_integration_internal("gauss_hermite_normal")
  objective_function <- mfrmr_ic_integration_internal("mfrm_loglik_mml")
  build_contract <- mfrmr_ic_integration_internal("build_mfrm_ic_contract")

  config <- fit$config
  sizes <- build_sizes(config)
  parameters <- suppressWarnings(as.numeric(fit$opt$par))
  expected_dimension <- sum(unlist(sizes), na.rm = FALSE)
  if (!is.finite(expected_dimension) || expected_dimension != length(parameters)) {
    stop(
      "Candidate `", label,
      "` has an inconsistent free-parameter dimension.",
      call. = FALSE
    )
  }
  indices <- build_indices(
    fit$prep,
    step_facet = config$step_facet,
    slope_facet = config$slope_facet,
    interaction_specs = config$interaction_specs
  )
  source_quad <- as.integer(config$estimation_control$quad_points)
  stored_objective <- as.numeric(fit$opt$value)[1]

  rows <- lapply(quad_points, function(evaluation_quad) {
    evaluation_config <- config
    evaluation_config$estimation_control$quad_points <- evaluation_quad
    quad <- make_quad(evaluation_quad)
    started <- proc.time()[["elapsed"]]
    objective <- objective_function(
      parameters,
      indices,
      evaluation_config,
      sizes,
      quad
    )
    elapsed <- proc.time()[["elapsed"]] - started
    if (!is.finite(objective)) {
      stop(
        "Candidate `", label, "` returned a non-finite objective at q = ",
        evaluation_quad, ".",
        call. = FALSE
      )
    }
    contract <- build_contract(
      loglik = -objective,
      npar = length(parameters),
      prep = fit$prep,
      config = evaluation_config,
      method = "MML"
    )
    if (!isTRUE(contract$ICEligible)) {
      stop(
        "Candidate `", label, "` became IC-ineligible at q = ",
        evaluation_quad, ".",
        call. = FALSE
      )
    }
    source_difference <- if (evaluation_quad == source_quad) {
      objective - stored_objective
    } else {
      NA_real_
    }
    source_consistent <- if (evaluation_quad == source_quad) {
      abs(source_difference) <= objective_tolerance *
        max(1, abs(stored_objective))
    } else {
      NA
    }
    data.frame(
      Label = label,
      Model = toupper(as.character(config$model)[1]),
      EvaluationPolicy = mfrmr_ic_integration_policy,
      SourceQuadraturePoints = source_quad,
      EvaluationQuadraturePoints = evaluation_quad,
      IntegrationEvaluationId = contract$IntegrationEvaluationId,
      ResponseRows = contract$ResponseRows,
      Npar = contract$Npar,
      Persons = contract$Persons,
      LogLik = contract$LogLik,
      Deviance = contract$Deviance,
      AIC = contract$AIC,
      BIC = contract$BIC,
      SABIC = contract$SABIC,
      StoredObjective = stored_objective,
      SourceObjectiveDifference = source_difference,
      SourceObjectiveConsistent = source_consistent,
      ElapsedSeconds = elapsed,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_ic_integration_long_values <- function(evaluations,
                                              reference_quad,
                                              tie_tolerance) {
  criteria <- c("Deviance", "AIC", "BIC", "SABIC")
  rows <- lapply(criteria, function(criterion) {
    data.frame(
      Label = evaluations$Label,
      Model = evaluations$Model,
      EvaluationQuadraturePoints = evaluations$EvaluationQuadraturePoints,
      Criterion = criterion,
      Value = as.numeric(evaluations[[criterion]]),
      stringsAsFactors = FALSE
    )
  })
  values <- do.call(rbind, rows)
  rownames(values) <- NULL

  groups <- split(
    seq_len(nrow(values)),
    interaction(
      values$Criterion,
      values$EvaluationQuadraturePoints,
      drop = TRUE,
      lex.order = TRUE
    )
  )
  values$Delta <- NA_real_
  values$Rank <- NA_integer_
  values$Preferred <- NA_character_
  values$Ordering <- NA_character_
  for (indices in groups) {
    current <- values$Value[indices]
    minimum <- min(current)
    values$Delta[indices] <- current - minimum
    values$Rank[indices] <- rank(current, ties.method = "min")
    preferred <- values$Label[indices][abs(current - minimum) <= tie_tolerance]
    ordering <- values$Label[indices][order(current, values$Label[indices])]
    values$Preferred[indices] <- paste(preferred, collapse = ";")
    values$Ordering[indices] <- paste(ordering, collapse = " < ")
  }

  reference <- values[
    values$EvaluationQuadraturePoints == reference_quad,
    c("Label", "Criterion", "Value", "Delta", "Rank"),
    drop = FALSE
  ]
  names(reference)[3:5] <- c("ReferenceValue", "ReferenceDelta", "ReferenceRank")
  key <- paste(values$Label, values$Criterion, sep = "\r")
  reference_key <- paste(reference$Label, reference$Criterion, sep = "\r")
  matched <- match(key, reference_key)
  values$ReferenceQuadraturePoints <- reference_quad
  values$ReferenceValue <- reference$ReferenceValue[matched]
  values$ReferenceDelta <- reference$ReferenceDelta[matched]
  values$ReferenceRank <- reference$ReferenceRank[matched]
  values$CriterionDrift <- values$Value - values$ReferenceValue
  values$DeltaDrift <- values$Delta - values$ReferenceDelta
  values$RankChange <- values$Rank - values$ReferenceRank
  values
}

mfrmr_ic_integration_pairwise <- function(values,
                                           reference_quad,
                                           tie_tolerance) {
  labels <- unique(values$Label)
  pairs <- utils::combn(labels, 2L, simplify = FALSE)
  criteria <- unique(values$Criterion)
  quadrature <- sort(unique(values$EvaluationQuadraturePoints))
  rows <- list()
  for (criterion in criteria) {
    criterion_values <- values[values$Criterion == criterion, , drop = FALSE]
    for (pair in pairs) {
      first <- pair[1]
      second <- pair[2]
      reference_first <- criterion_values$Value[
        criterion_values$Label == first &
          criterion_values$EvaluationQuadraturePoints == reference_quad
      ]
      reference_second <- criterion_values$Value[
        criterion_values$Label == second &
          criterion_values$EvaluationQuadraturePoints == reference_quad
      ]
      reference_difference <- reference_first - reference_second
      reference_sign <- if (abs(reference_difference) <= tie_tolerance) {
        0L
      } else {
        sign(reference_difference)
      }
      for (evaluation_quad in quadrature) {
        first_value <- criterion_values$Value[
          criterion_values$Label == first &
            criterion_values$EvaluationQuadraturePoints == evaluation_quad
        ]
        second_value <- criterion_values$Value[
          criterion_values$Label == second &
            criterion_values$EvaluationQuadraturePoints == evaluation_quad
        ]
        difference <- first_value - second_value
        current_sign <- if (abs(difference) <= tie_tolerance) 0L else sign(difference)
        gap_drift <- difference - reference_difference
        rows[[length(rows) + 1L]] <- data.frame(
          Criterion = criterion,
          First = first,
          Second = second,
          EvaluationQuadraturePoints = evaluation_quad,
          ReferenceQuadraturePoints = reference_quad,
          Difference = difference,
          ReferenceDifference = reference_difference,
          GapDrift = gap_drift,
          AbsGapDrift = abs(gap_drift),
          DriftToReferenceGapRatio = if (
            abs(reference_difference) > tie_tolerance
          ) {
            abs(gap_drift) / abs(reference_difference)
          } else {
            NA_real_
          },
          OrderingStable = identical(current_sign, reference_sign),
          stringsAsFactors = FALSE
        )
      }
    }
  }
  do.call(rbind, rows)
}

mfrmr_ic_integration_summarize <- function(values,
                                            pairwise,
                                            core_quad_points) {
  scopes <- list(
    full_ladder = sort(unique(values$EvaluationQuadraturePoints)),
    core_ladder = core_quad_points
  )
  rows <- list()
  for (scope in names(scopes)) {
    for (criterion in unique(values$Criterion)) {
      value_rows <- values[
        values$Criterion == criterion &
          values$EvaluationQuadraturePoints %in% scopes[[scope]],
        , drop = FALSE
      ]
      pair_rows <- pairwise[
        pairwise$Criterion == criterion &
          pairwise$EvaluationQuadraturePoints %in% scopes[[scope]],
        , drop = FALSE
      ]
      ratios <- pair_rows$DriftToReferenceGapRatio[
        is.finite(pair_rows$DriftToReferenceGapRatio)
      ]
      rows[[length(rows) + 1L]] <- data.frame(
        Scope = scope,
        Criterion = criterion,
        QuadraturePoints = paste(scopes[[scope]], collapse = ";"),
        MaxAbsCriterionDrift = max(abs(value_rows$CriterionDrift)),
        MaxAbsDeltaDrift = max(abs(value_rows$DeltaDrift)),
        MaxAbsPairwiseGapDrift = max(pair_rows$AbsGapDrift),
        MinAbsReferenceGap = min(abs(pair_rows$ReferenceDifference)),
        MaxGapDriftRatio = if (length(ratios) > 0L) max(ratios) else NA_real_,
        OrderingStable = all(pair_rows$OrderingStable),
        stringsAsFactors = FALSE
      )
    }
  }
  do.call(rbind, rows)
}

mfrmr_ic_integration_gate_rows <- function(summary,
                                            scenario_id,
                                            candidate_commit,
                                            specification) {
  core <- summary[summary$Scope == "core_ladder", , drop = FALSE]
  rows <- lapply(seq_len(nrow(core)), function(index) {
    row <- core[index, , drop = FALSE]
    data.frame(
      Gate = "G3",
      Item = "integration_stability",
      ScenarioId = scenario_id,
      CandidateCommit = candidate_commit,
      SpecId = specification,
      EvidenceRole = "pilot",
      Metric = paste0("max_abs_pairwise_gap_drift_", tolower(row$Criterion)),
      Estimate = row$MaxAbsPairwiseGapDrift,
      Threshold = NA_real_,
      Direction = "lower_is_better",
      MonteCarloSE = NA_real_,
      NumericalSE = row$MaxAbsCriterionDrift,
      ReplicatesPlanned = NA_integer_,
      ReplicatesRetained = NA_integer_,
      FailedReplicates = 0L,
      Status = "review",
      EvidencePath = NA_character_,
      EvidenceHash = NA_character_,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_run_ic_integration_pilot <- function(
    fits,
    labels = names(fits),
    quad_points = c(7L, 15L, 31L, 61L, 91L, 121L),
    reference_quad = max(quad_points),
    core_quad_points = NULL,
    objective_tolerance = 1e-10,
    tie_tolerance = 1e-8,
    require_inference_ready = TRUE,
    require_common_source_quad = TRUE,
    scenario_id = "IC-INTEGRATION-DEVELOPMENT",
    specification = mfrmr_ic_integration_specification,
    candidate_commit = NULL,
    pkg_dir = ".") {
  if (!is.list(fits) || length(fits) < 2L) {
    stop("`fits` must be a list containing at least two candidates.",
         call. = FALSE)
  }
  if (is.null(labels) || length(labels) != length(fits) || anyNA(labels) ||
      any(!nzchar(labels)) || anyDuplicated(labels)) {
    stop("`labels` must contain one unique non-empty label per candidate.",
         call. = FALSE)
  }
  labels <- as.character(labels)
  if (!is.numeric(objective_tolerance) || length(objective_tolerance) != 1L ||
      !is.finite(objective_tolerance) || objective_tolerance <= 0) {
    stop("`objective_tolerance` must be one finite positive number.",
         call. = FALSE)
  }
  if (!is.numeric(tie_tolerance) || length(tie_tolerance) != 1L ||
      !is.finite(tie_tolerance) || tie_tolerance <= 0) {
    stop("`tie_tolerance` must be one finite positive number.",
         call. = FALSE)
  }
  loaded_contract <- mfrmr_ic_integration_internal(
    "mfrm_ic_contract_version"
  )()
  if (!identical(loaded_contract, mfrmr_ic_integration_contract)) {
    stop(
      "The loaded package IC contract is `", loaded_contract,
      "`, but this pilot requires `", mfrmr_ic_integration_contract, "`.",
      call. = FALSE
    )
  }
  grid <- mfrmr_ic_integration_validate_grid(
    quad_points,
    reference_quad,
    core_quad_points
  )
  basis_checks <- mfrmr_ic_integration_check_common_basis(fits)
  fit_metadata <- mfrmr_ic_integration_validate_fits(
    fits = fits,
    labels = labels,
    quad_points = grid$quad_points,
    require_inference_ready = require_inference_ready,
    require_common_source_quad = require_common_source_quad
  )
  evaluations <- do.call(rbind, lapply(seq_along(fits), function(index) {
    mfrmr_ic_integration_evaluate_fit(
      fit = fits[[index]],
      label = labels[index],
      quad_points = grid$quad_points,
      objective_tolerance = objective_tolerance
    )
  }))
  rownames(evaluations) <- NULL
  source_rows <- evaluations[
    evaluations$EvaluationQuadraturePoints ==
      evaluations$SourceQuadraturePoints,
    , drop = FALSE
  ]
  if (nrow(source_rows) != length(fits) ||
      any(!source_rows$SourceObjectiveConsistent)) {
    stop(
      "At least one source-grid reevaluation does not reproduce its retained ",
      "objective within `objective_tolerance`.",
      call. = FALSE
    )
  }
  values <- mfrmr_ic_integration_long_values(
    evaluations,
    reference_quad = grid$reference_quad,
    tie_tolerance = tie_tolerance
  )
  pairwise <- mfrmr_ic_integration_pairwise(
    values,
    reference_quad = grid$reference_quad,
    tie_tolerance = tie_tolerance
  )
  summary <- mfrmr_ic_integration_summarize(
    values,
    pairwise,
    core_quad_points = grid$core_quad_points
  )
  if (is.null(candidate_commit)) {
    candidate_commit <- mfrmr_ic_integration_git_identity(pkg_dir)
  }
  gate_results <- mfrmr_ic_integration_gate_rows(
    summary,
    scenario_id = scenario_id,
    candidate_commit = candidate_commit,
    specification = specification
  )
  core_ordering_stable <- all(summary$OrderingStable[
    summary$Scope == "core_ladder"
  ])
  full_ordering_stable <- all(summary$OrderingStable[
    summary$Scope == "full_ladder"
  ])
  out <- list(
    specification = specification,
    contract_version = loaded_contract,
    evaluation_policy = mfrmr_ic_integration_policy,
    evidence_role = "pilot",
    confirmation_authorized = FALSE,
    candidate_commit = candidate_commit,
    scenario_id = scenario_id,
    quadrature_points = grid$quad_points,
    core_quadrature_points = grid$core_quad_points,
    reference_quadrature_points = grid$reference_quad,
    objective_tolerance = objective_tolerance,
    tie_tolerance = tie_tolerance,
    basis_checks = basis_checks,
    fit_metadata = fit_metadata,
    evaluations = evaluations,
    criterion_values = values,
    pairwise = pairwise,
    summary = summary,
    gate_results = gate_results,
    core_ordering_stable = core_ordering_stable,
    full_ordering_stable = full_ordering_stable,
    status = "review",
    interpretation = if (!core_ordering_stable) {
      "pilot_core_order_change_threshold_unfrozen"
    } else if (!full_ordering_stable) {
      "pilot_core_stable_coarse_grid_order_change_threshold_unfrozen"
    } else {
      "pilot_observed_stable_ordering_threshold_unfrozen"
    }
  )
  class(out) <- c("mfrmr_ic_integration_pilot", class(out))
  out
}

print.mfrmr_ic_integration_pilot <- function(x, digits = 6L, ...) {
  cat("mfrmr 0.2.3 common-GHQ IC integration pilot\n")
  cat("  Specification:", x$specification, "\n")
  cat("  Evaluation policy:", x$evaluation_policy, "\n")
  cat("  Candidates:", paste(x$fit_metadata$Label, collapse = ", "), "\n")
  cat("  GHQ ladder:", paste(x$quadrature_points, collapse = ", "), "\n")
  cat("  Core ladder:", paste(x$core_quadrature_points, collapse = ", "), "\n")
  cat("  Reference q:", x$reference_quadrature_points, "\n")
  cat("  Core ordering stable:", x$core_ordering_stable, "\n")
  cat("  Full-ladder ordering stable:", x$full_ordering_stable, "\n")
  cat("  Status:", x$status, "(", x$interpretation, ")\n", sep = "")
  display <- x$summary[x$summary$Scope == "core_ladder", c(
    "Criterion", "MaxAbsCriterionDrift", "MaxAbsPairwiseGapDrift",
    "MaxGapDriftRatio", "OrderingStable"
  ), drop = FALSE]
  numeric_columns <- vapply(display, is.numeric, logical(1))
  display[numeric_columns] <- lapply(display[numeric_columns], round, digits)
  print(display, row.names = FALSE)
  cat("  Pilot only: thresholds remain unfrozen; confirmation is not authorized.\n")
  invisible(x)
}

mfrmr_write_ic_integration_pilot <- function(
    x,
    output_dir,
    prefix = "ic-integration-pilot-0.2.3",
    overwrite = FALSE) {
  if (!inherits(x, "mfrmr_ic_integration_pilot")) {
    stop("`x` must be an `mfrmr_ic_integration_pilot` object.",
         call. = FALSE)
  }
  if (!is.character(output_dir) || length(output_dir) != 1L ||
      is.na(output_dir) || !nzchar(output_dir)) {
    stop("`output_dir` must be one non-empty path.", call. = FALSE)
  }
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  }
  files <- c(
    evaluations = file.path(output_dir, paste0(prefix, "-evaluations.csv")),
    criterion_values = file.path(output_dir, paste0(prefix, "-criteria.csv")),
    pairwise = file.path(output_dir, paste0(prefix, "-pairwise.csv")),
    summary = file.path(output_dir, paste0(prefix, "-summary.csv")),
    gate_results = file.path(output_dir, paste0(prefix, "-gate-results.csv")),
    manifest = file.path(output_dir, paste0(prefix, "-manifest.csv"))
  )
  if (!isTRUE(overwrite) && any(file.exists(files))) {
    stop(
      "Pilot output already exists. Choose a new `prefix` or set ",
      "`overwrite = TRUE` explicitly.",
      call. = FALSE
    )
  }
  utils::write.csv(x$evaluations, files[["evaluations"]], row.names = FALSE,
                   na = "")
  utils::write.csv(x$criterion_values, files[["criterion_values"]],
                   row.names = FALSE, na = "")
  utils::write.csv(x$pairwise, files[["pairwise"]], row.names = FALSE,
                   na = "")
  utils::write.csv(x$summary, files[["summary"]], row.names = FALSE, na = "")
  detail_files <- files[c("evaluations", "criterion_values", "pairwise", "summary")]
  detail_hashes <- unname(tools::md5sum(detail_files))
  gate_results <- x$gate_results
  gate_results$EvidencePath <- paste(basename(detail_files), collapse = ";")
  gate_results$EvidenceHash <- paste(detail_hashes, collapse = ";")
  utils::write.csv(gate_results, files[["gate_results"]], row.names = FALSE,
                   na = "")
  manifest_files <- files[names(files) != "manifest"]
  manifest <- data.frame(
    File = basename(manifest_files),
    MD5 = unname(tools::md5sum(manifest_files)),
    stringsAsFactors = FALSE
  )
  utils::write.csv(manifest, files[["manifest"]], row.names = FALSE, na = "")
  invisible(files)
}
