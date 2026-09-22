# Draft.83d2b0 scalable G-theory ADEMP pre-fit prototype.
#
# Repository-internal only. This file derives exact covariance-component rank
# from observed factor-equality signatures, adjudicates pre-fit blockers, and
# binds the result to the Draft.83d1 manifest. It runs no backend fit.

mfrmr_gtd3_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gta_split_facets", "mfrmr_gti_audit",
    "mfrmr_gti_prepare", "mfrmr_gti_effective_values",
    "mfrmr_gtc_matrix_rank", "mfrmr_gtc_component_status",
    "mfrmr_gtd_registry",
    "mfrmr_gtd_execution_manifest", "mfrmr_gtd2_generate"
  )
  prototype_environment <- environment(mfrmr_gtd3_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = prototype_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.81, Draft.83a/c1, Draft.83d1, and Draft.83d2a ",
      "before Draft.83d2b0: ", paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtd3_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtd3_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtd3_missingness", "mfrmr_gtd3_mask_members",
    "mfrmr_gtd3_subset_masks", "mfrmr_gtd3_same_counts",
    "mfrmr_gtd3_equality_patterns", "mfrmr_gtd3_null_space",
    "mfrmr_gtd3_structural_rank",
    "mfrmr_gtd3_classify_issues", "mfrmr_gtd3_prefit_one",
    "mfrmr_gtd3_prefit_registry"
  )
  environment <- environment(mfrmr_gtd3_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtd3_function_hash(get(name, envir = environment, inherits = TRUE))
  }, character(1L)), functions)
}

mfrmr_gtd3_missingness <- function(mechanism) {
  map <- c(
    none = "complete", MCAR = "MCAR",
    MAR_rater_load = "MAR_covariate",
    MNAR_score = "MNAR_sensitivity", unknown = "unknown"
  )
  mechanism <- as.character(mechanism)
  if (length(mechanism) != 1L || !mechanism %in% names(map)) {
    stop("The generator missingness mechanism has no Draft.83a mapping.",
         call. = FALSE)
  }
  unname(map[[mechanism]])
}

mfrmr_gtd3_mask_members <- function(mask, factors) {
  mask <- as.integer(mask)
  bits <- bitwAnd(mask, bitwShiftL(1L, seq_along(factors) - 1L)) != 0L
  factors[bits]
}

mfrmr_gtd3_subset_masks <- function(positions) {
  positions <- as.integer(positions)
  if (length(positions) == 0L) return(0L)
  local <- 0:(2^length(positions) - 1L)
  vapply(local, function(mask) {
    selected <- positions[
      bitwAnd(mask, bitwShiftL(1L, seq_along(positions) - 1L)) != 0L
    ]
    if (length(selected) == 0L) return(0L)
    sum(bitwShiftL(1L, selected - 1L))
  }, integer(1L))
}

mfrmr_gtd3_same_counts <- function(effective, factors) {
  factor_count <- length(factors)
  if (factor_count < 1L || factor_count > 20L) {
    stop("The scalable rank audit requires 1--20 effective factors.",
         call. = FALSE)
  }
  masks <- 0:(2^factor_count - 1L)
  output <- vector("list", length(masks))
  for (mask in masks) {
    members <- mfrmr_gtd3_mask_members(mask, factors)
    if (length(members) == 0L) {
      output[[mask + 1L]] <- rep.int(nrow(effective), nrow(effective))
    } else {
      key <- mfrmr_gti_key(effective, members)
      frequency <- table(key)
      output[[mask + 1L]] <- as.integer(frequency[key])
    }
  }
  output
}

mfrmr_gtd3_equality_patterns <- function(effective, factors) {
  if (!is.data.frame(effective) || nrow(effective) == 0L ||
      !all(factors %in% names(effective))) {
    stop("`effective` must contain nonempty effective factor identities.",
         call. = FALSE)
  }
  factor_count <- length(factors)
  masks <- 0:(2^factor_count - 1L)
  full_mask <- 2^factor_count - 1L
  same_counts <- mfrmr_gtd3_same_counts(effective, factors)
  rows <- lapply(masks, function(equal_mask) {
    equal_positions <- which(
      bitwAnd(equal_mask, bitwShiftL(1L, seq_len(factor_count) - 1L)) != 0L
    )
    different_positions <- setdiff(seq_len(factor_count), equal_positions)
    if (length(different_positions) == 0L) {
      witness <- same_counts[[full_mask + 1L]] - 1L
    } else {
      witness <- numeric(nrow(effective))
      additions <- mfrmr_gtd3_subset_masks(different_positions)
      for (addition in additions) {
        union_mask <- bitwOr(equal_mask, addition)
        sign <- if (sum(
          bitwAnd(addition, bitwShiftL(
            1L, different_positions - 1L
          )) != 0L
        ) %% 2L == 0L) 1 else -1
        witness <- witness + sign * same_counts[[union_mask + 1L]]
      }
    }
    equal <- mfrmr_gtd3_mask_members(equal_mask, factors)
    different <- setdiff(factors, equal)
    data.frame(
      EqualityMask = as.integer(equal_mask),
      EqualFactors = if (length(equal) == 0L) "<none>" else
        paste(equal, collapse = ":"),
      DifferentFactors = if (length(different) == 0L) "<none>" else
        paste(different, collapse = ":"),
      OffDiagonalPairExists = any(witness > 0.5),
      MaximumWitnessCount = max(witness),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gtd3_null_space <- function(x, component_ids, tolerance,
                                  prefix = "S") {
  rank <- mfrmr_gtc_matrix_rank(x, tolerance)$Rank
  if (rank >= ncol(x)) {
    return(data.frame(
      NullVector = character(), ComponentId = character(),
      Loading = numeric(), stringsAsFactors = FALSE
    ))
  }
  decomposition <- qr(t(x), tol = tolerance, LAPACK = FALSE)
  basis <- qr.Q(decomposition, complete = TRUE)
  vectors <- basis[, seq.int(rank + 1L, ncol(x)), drop = FALSE]
  rows <- lapply(seq_len(ncol(vectors)), function(index) {
    direction <- vectors[, index]
    direction <- direction / max(abs(direction))
    data.frame(
      NullVector = paste0(prefix, index), ComponentId = component_ids,
      Loading = as.numeric(direction), stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gtd3_structural_rank <- function(
    spec, data, missingness, rank_tolerance = 1e-9) {
  mfrmr_gtd3_require_primitives()
  rank_tolerance <- as.numeric(rank_tolerance)
  if (length(rank_tolerance) != 1L || !is.finite(rank_tolerance) ||
      rank_tolerance <= 0) {
    stop("`rank_tolerance` must be one finite positive number.",
         call. = FALSE)
  }
  prepared <- mfrmr_gti_prepare(spec, data, missingness)
  if (prepared$RetainedRows == 0L) {
    stop("Scalable covariance rank requires at least one retained row.",
         call. = FALSE)
  }
  factors <- prepared$Factors
  effective <- mfrmr_gti_effective_values(
    prepared$Data, factors, spec$NestingGraph
  )
  patterns <- mfrmr_gtd3_equality_patterns(effective, factors)
  component_ids <- spec$EffectMap$ComponentId
  component_members <- lapply(
    spec$EffectMap$Members, mfrmr_gta_split_facets
  )

  diagonal <- stats::setNames(rep(1, length(component_ids)), component_ids)
  signatures <- list(diagonal)
  signature_labels <- "diagonal"
  possible <- patterns[patterns$OffDiagonalPairExists, , drop = FALSE]
  if (nrow(possible) > 0L) {
    for (index in seq_len(nrow(possible))) {
      equal <- mfrmr_gtd3_mask_members(
        possible$EqualityMask[[index]], factors
      )
      signature <- vapply(seq_along(component_ids), function(component_index) {
        if (component_ids[[component_index]] == "Residual") return(0)
        as.numeric(all(component_members[[component_index]] %in% equal))
      }, numeric(1L))
      names(signature) <- component_ids
      signatures[[length(signatures) + 1L]] <- signature
      signature_labels <- c(
        signature_labels,
        paste0("off_diagonal_equal_", possible$EqualFactors[[index]])
      )
    }
  }
  signature_matrix <- do.call(rbind, signatures)
  signature_key <- apply(signature_matrix, 1L, paste, collapse = "\r")
  keep <- !duplicated(signature_key)
  signature_matrix <- signature_matrix[keep, , drop = FALSE]
  signature_labels <- signature_labels[keep]
  row.names(signature_matrix) <- signature_labels

  rank <- mfrmr_gtc_matrix_rank(signature_matrix, rank_tolerance)
  null_space <- mfrmr_gtd3_null_space(
    signature_matrix, component_ids, rank_tolerance, prefix = "S"
  )
  rank_full <- identical(rank$Rank, length(component_ids))
  grouping_levels <- vapply(seq_along(component_ids), function(index) {
    if (component_ids[[index]] == "Residual") return(prepared$RetainedRows)
    length(unique(mfrmr_gti_key(effective, component_members[[index]])))
  }, integer(1L))
  component_audit <- spec$EffectMap
  component_audit$GroupingLevels <- grouping_levels
  component_audit$StructuralStatus <- mfrmr_gtc_component_status(
    component_ids, null_space, rank_tolerance, rank_full,
    c("structurally_independent", "structurally_confounded")
  )
  payload <- list(
    Contract = "gtheory_ademp_scalable_rank_draft83d2b0_v1",
    DesignHash = spec$DesignHash,
    RetainedDataHash = prepared$RetainedDataHash,
    MissingnessMechanism = missingness,
    RetainedRows = prepared$RetainedRows,
    Factors = factors,
    ComponentIds = component_ids,
    EqualityPatterns = patterns,
    SignatureLabels = signature_labels,
    SignatureMatrix = signature_matrix,
    StructuralRank = rank$Rank,
    StructuralDimension = length(component_ids),
    StructuralRankFull = rank_full,
    StructuralThreshold = rank$Threshold,
    StructuralSingularValues = rank$SingularValues,
    NullSpace = null_space,
    ComponentAudit = component_audit,
    RankTolerance = rank_tolerance
  )
  structure(c(payload, list(
    ResultHash = mfrmr_gta_hash(payload),
    PreparedData = prepared,
    EstimationReady = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtd3_structural_rank")
}

mfrmr_gtd3_classify_issues <- function(issues) {
  issues <- unique(as.character(issues))
  issues <- issues[nzchar(issues)]
  if (length(issues) == 0L) {
    return(data.frame(
      Issue = character(), IssueClass = character(), Blocking = logical(),
      stringsAsFactors = FALSE
    ))
  }
  classify <- function(issue) {
    if (grepl(
      "^(no_retained_rows|insufficient_observed_levels:|non_nested_object_)",
      issue
    ) || issue %in% c(
      "highest_order_residual_not_separable",
      "partial_full_cell_replication", "cell_replication_metadata_mismatch",
      "declared_complete_but_rows_omitted"
    )) return(c("blocking_observed_design", "TRUE"))
    if (grepl("^fixed_equivalent_rank_deficiency:", issue) ||
        issue == "no_fixed_equivalent_residual_df") {
      return(c("diagnostic_not_covariance_rank", "FALSE"))
    }
    if (issue == "rank_audit_not_evaluated_capacity") {
      return(c("capacity_superseded_by_scalable_rank", "FALSE"))
    }
    if (grepl("^declared_levels_without_retained_rows:", issue)) {
      return(c("metric_availability_limited", "FALSE"))
    }
    if (issue == "unknown_missingness_with_omissions") {
      return(c("missingness_sensitivity", "FALSE"))
    }
    c("unclassified_fail_closed", "TRUE")
  }
  classified <- lapply(issues, classify)
  data.frame(
    Issue = issues,
    IssueClass = vapply(classified, `[[`, character(1L), 1L),
    Blocking = vapply(classified, function(x) identical(x[[2L]], "TRUE"),
                      logical(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtd3_prefit_one <- function(
    generation, diagnostic_rank_max_cells = 1e5,
    rank_tolerance = 1e-9) {
  if (!inherits(generation, "mfrmr_gtd2_generation")) {
    stop("`generation` must be a Draft.83d2a generation result.",
         call. = FALSE)
  }
  if (!identical(generation$GenerationState, "generated_not_fitted")) {
    stop("Pre-fit adjudication requires an executable generated scenario.",
         call. = FALSE)
  }
  missingness <- mfrmr_gtd3_missingness(
    generation$Scenario$MissingnessMechanism[[1L]]
  )
  incidence <- mfrmr_gti_audit(
    generation$Spec, generation$AnalysisData, missingness = missingness,
    rank_tolerance = rank_tolerance,
    max_matrix_cells = diagnostic_rank_max_cells
  )
  issues <- mfrmr_gtd3_classify_issues(incidence$Issues)
  structural <- mfrmr_gtd3_structural_rank(
    generation$Spec, generation$AnalysisData, missingness,
    rank_tolerance = rank_tolerance
  )
  blocking_incidence <- any(issues$Blocking)
  state <- if (blocking_incidence) {
    "blocked_observed_design"
  } else if (!structural$StructuralRankFull) {
    "blocked_structural_covariance_confounding"
  } else {
    "eligible_point_fit_information_pending"
  }
  negative_control <- identical(
    generation$Scenario$Lane[[1L]], "identification_negative_control"
  )
  payload <- list(
    Contract = "gtheory_ademp_prefit_draft83d2b0_v1",
    RegistryHash = generation$RegistryHash,
    ScenarioId = generation$ScenarioId,
    Replicate = generation$Replicate,
    GeneratorHash = generation$GeneratorHash,
    DesignHash = generation$Spec$DesignHash,
    AnalysisDataHash = generation$GeneratorIdentity$AnalysisDataHash,
    MissingnessMechanism = missingness,
    IncidenceAuditHash = incidence$AuditHash,
    IncidenceIssues = issues,
    ScalableStructuralRankHash = structural$ResultHash,
    StructuralRank = structural$StructuralRank,
    StructuralDimension = structural$StructuralDimension,
    StructuralRankFull = structural$StructuralRankFull,
    PreFitState = state,
    PreFitEligible = identical(
      state, "eligible_point_fit_information_pending"
    ),
    NegativeControlBlockSatisfied = !negative_control || !identical(
      state, "eligible_point_fit_information_pending"
    ),
    DiagnosticRankMaxCells = diagnostic_rank_max_cells,
    RankTolerance = rank_tolerance
  )
  structure(c(payload, list(
    ResultHash = mfrmr_gta_hash(payload),
    IncidenceAudit = incidence, StructuralRankAudit = structural,
    FitAttempted = FALSE, EstimationReady = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtd3_prefit")
}

mfrmr_gtd3_prefit_registry <- function(
    registry = mfrmr_gtd_registry(), diagnostic_rank_max_cells = 1e5,
    rank_tolerance = 1e-9) {
  mfrmr_gtd3_require_primitives()
  manifest <- mfrmr_gtd_execution_manifest(registry)
  scenario_ids <- registry$Scenarios$ScenarioId[
    registry$Scenarios$ExecutionEligibility == "executable_smoke"
  ]
  generations <- lapply(scenario_ids, function(scenario_id) {
    mfrmr_gtd2_generate(registry, scenario_id, replicate = 1L)
  })
  names(generations) <- scenario_ids
  prefit <- lapply(generations, mfrmr_gtd3_prefit_one,
                   diagnostic_rank_max_cells = diagnostic_rank_max_cells,
                   rank_tolerance = rank_tolerance)
  names(prefit) <- scenario_ids
  summary <- do.call(rbind, lapply(prefit, function(result) {
    data.frame(
      ScenarioId = result$ScenarioId, Replicate = result$Replicate,
      GeneratorHash = result$GeneratorHash,
      IncidenceAuditHash = result$IncidenceAuditHash,
      StructuralRankHash = result$ScalableStructuralRankHash,
      RetainedRows = result$StructuralRankAudit$RetainedRows,
      IncidenceIssueCount = nrow(result$IncidenceIssues),
      BlockingIncidenceIssueCount = sum(result$IncidenceIssues$Blocking),
      StructuralRank = result$StructuralRank,
      StructuralDimension = result$StructuralDimension,
      StructuralRankFull = result$StructuralRankFull,
      PreFitState = result$PreFitState,
      PreFitEligible = result$PreFitEligible,
      NegativeControlBlockSatisfied = result$NegativeControlBlockSatisfied,
      PreFitHash = result$ResultHash,
      stringsAsFactors = FALSE
    )
  }))
  row.names(summary) <- NULL
  position <- match(manifest$ScenarioId, summary$ScenarioId)
  plan <- cbind(
    manifest,
    summary[position, c(
      "GeneratorHash", "IncidenceAuditHash", "StructuralRankHash",
      "PreFitState", "PreFitEligible"
    ), drop = FALSE]
  )
  row.names(plan) <- NULL
  plan$MethodEligibilityState <- ifelse(
    plan$PreFitEligible,
    "eligible_adapter_pending_execution",
    plan$PreFitState
  )
  plan$FitAttemptAuthorized <- FALSE
  plan$AtomicResultRecorded <- FALSE
  identity <- list(
    Contract = "gtheory_ademp_prefit_registry_draft83d2b0_v1",
    RegistryHash = registry$RegistryHash,
    DiagnosticRankMaxCells = diagnostic_rank_max_cells,
    RankTolerance = rank_tolerance,
    FunctionHashes = mfrmr_gtd3_function_hashes(),
    ScenarioSummary = summary,
    ManifestPlan = plan
  )
  structure(c(identity, list(
    PreFitResults = prefit,
    PreFitPlanHash = mfrmr_gta_hash(identity),
    GeneratedScenarioCount = length(generations),
    EligibleScenarioCount = sum(summary$PreFitEligible),
    BlockedScenarioCount = sum(!summary$PreFitEligible),
    PlannedFitUnits = nrow(plan),
    EligibleFitUnits = sum(plan$PreFitEligible),
    FitAttempted = FALSE, RecoveryEvidenceReady = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtd3_prefit_registry")
}
