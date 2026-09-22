# Draft.85b0 multivariate G-theory long-form incidence preflight.
#
# Repository-internal only. Source the Draft.81 design/algebra prototype first.
# This file audits semantic links needed by a future covariance estimator. It
# fits no model, estimates no covariance, computes no coefficient, and never
# marks a result estimation-, inference-, or decision-ready.

mfrmr_gtvi_require_primitives <- function() {
  required <- c("mfrmr_gta_hash")
  prototype_environment <- environment(mfrmr_gtvi_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = prototype_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the Draft.81 design/algebra prototype before Draft.85b0: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtvi_column <- function(value, argument) {
  value <- as.character(value)
  if (length(value) != 1L || is.na(value) || !nzchar(value)) {
    stop(argument, " must name one nonempty column.", call. = FALSE)
  }
  value
}

mfrmr_gtvi_positive_integer <- function(value, argument) {
  numeric_value <- suppressWarnings(as.numeric(value))
  integer_value <- suppressWarnings(as.integer(value))
  if (length(value) != 1L || is.na(numeric_value) ||
      !is.finite(numeric_value) || numeric_value < 1 ||
      numeric_value != integer_value) {
    stop(argument, " must be one positive integer.", call. = FALSE)
  }
  integer_value
}

mfrmr_gtvi_ordered_strata <- function(strata) {
  strata <- as.character(strata)
  if (length(strata) < 2L || anyNA(strata) || any(!nzchar(strata)) ||
      anyDuplicated(strata)) {
    stop(
      "`strata` must contain at least two ordered, unique, nonempty labels.",
      call. = FALSE
    )
  }
  strata
}

mfrmr_gtvi_condition_scope <- function(condition_cols, condition_scope) {
  condition_cols <- as.character(condition_cols)
  if (length(condition_cols) == 0L || anyNA(condition_cols) ||
      any(!nzchar(condition_cols)) || anyDuplicated(condition_cols)) {
    stop("`condition_cols` must name at least one unique condition facet.",
         call. = FALSE)
  }
  if (is.null(names(condition_scope)) ||
      !setequal(names(condition_scope), condition_cols)) {
    stop(
      "`condition_scope` must be named exactly by `condition_cols`.",
      call. = FALSE
    )
  }
  condition_scope <- as.character(condition_scope[condition_cols])
  names(condition_scope) <- condition_cols
  allowed <- c("global", "stratum_local")
  if (anyNA(condition_scope) || any(!condition_scope %in% allowed)) {
    stop("Each condition scope must be `global` or `stratum_local`.",
         call. = FALSE)
  }
  condition_scope
}

mfrmr_gtvi_score_token <- function(score) {
  out <- rep.int("NA", length(score))
  finite <- is.finite(score)
  out[finite] <- sprintf("%.17g", score[finite])
  out
}

mfrmr_gtvi_components <- function(nodes, edges) {
  nodes <- unique(as.character(nodes))
  adjacency <- stats::setNames(vector("list", length(nodes)), nodes)
  if (nrow(edges) > 0L) {
    for (index in seq_len(nrow(edges))) {
      left <- as.character(edges[index, 1L])
      right <- as.character(edges[index, 2L])
      adjacency[[left]] <- union(adjacency[[left]], right)
      adjacency[[right]] <- union(adjacency[[right]], left)
    }
  }
  membership <- stats::setNames(rep.int(NA_integer_, length(nodes)), nodes)
  component <- 0L
  for (start in nodes) {
    if (!is.na(membership[[start]])) next
    component <- component + 1L
    membership[[start]] <- component
    frontier <- start
    while (length(frontier) > 0L) {
      current <- frontier[[1L]]
      frontier <- frontier[-1L]
      neighbours <- adjacency[[current]]
      unseen <- neighbours[is.na(membership[neighbours])]
      if (length(unseen) > 0L) {
        membership[unseen] <- component
        frontier <- union(frontier, unseen)
      }
    }
  }
  list(Count = component, Membership = membership)
}

mfrmr_gtvi_prepare <- function(
    data, object_col, stratum_col, score_col, condition_cols,
    condition_scope, strata, missingness) {
  mfrmr_gtvi_require_primitives()
  if (!is.data.frame(data) || nrow(data) == 0L) {
    stop("`data` must be a nonempty long-form data frame.", call. = FALSE)
  }
  object_col <- mfrmr_gtvi_column(object_col, "`object_col`")
  stratum_col <- mfrmr_gtvi_column(stratum_col, "`stratum_col`")
  score_col <- mfrmr_gtvi_column(score_col, "`score_col`")
  strata <- mfrmr_gtvi_ordered_strata(strata)
  condition_scope <- mfrmr_gtvi_condition_scope(
    condition_cols, condition_scope
  )
  condition_cols <- names(condition_scope)
  semantic_cols <- c(object_col, stratum_col, score_col, condition_cols)
  if (anyDuplicated(semantic_cols)) {
    stop("Object, stratum, score, and condition columns must be distinct.",
         call. = FALSE)
  }
  absent <- setdiff(semantic_cols, names(data))
  if (length(absent) > 0L) {
    stop("The long-form data are missing columns: ",
         paste(absent, collapse = ", "), ".", call. = FALSE)
  }
  missingness <- as.character(missingness)
  allowed_missingness <- c(
    "complete", "MCAR", "MAR_covariate", "MNAR_sensitivity", "unknown"
  )
  if (length(missingness) != 1L || is.na(missingness) ||
      !missingness %in% allowed_missingness) {
    stop("`missingness` is not a recognized mechanism.", call. = FALSE)
  }
  if (!is.numeric(data[[score_col]])) {
    stop("The observed score must be numeric; labels are not coerced.",
         call. = FALSE)
  }

  identifiers <- c(object_col, stratum_col, condition_cols)
  identifier_data <- lapply(data[identifiers], as.character)
  bad_identifier <- vapply(identifier_data, function(value) {
    any(is.na(value) | !nzchar(value))
  }, logical(1L))
  if (any(bad_identifier)) {
    stop("Object, stratum, and condition identities must be nonmissing.",
         call. = FALSE)
  }
  stratum_value <- identifier_data[[stratum_col]]
  unknown_strata <- setdiff(unique(stratum_value), strata)
  if (length(unknown_strata) > 0L) {
    stop("Observed strata are outside the declared order: ",
         paste(sort(unknown_strata, method = "radix"), collapse = ", "),
         ".", call. = FALSE)
  }
  score <- data[[score_col]]
  if (any(is.nan(score) | is.infinite(score))) {
    stop("Observed scores must be finite or missing; Inf and NaN are invalid.",
         call. = FALSE)
  }
  retained <- !is.na(score)
  canonical <- data.frame(
    Object = identifier_data[[object_col]],
    Stratum = stratum_value,
    lapply(identifier_data[condition_cols], identity),
    Score = mfrmr_gtvi_score_token(score),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  names(canonical)[seq.int(3L, 2L + length(condition_cols))] <- condition_cols
  ordering <- c(
    list(match(canonical$Stratum, strata), canonical$Object),
    lapply(canonical[condition_cols], as.character),
    list(canonical$Score, method = "radix")
  )
  canonical <- canonical[do.call(order, ordering), , drop = FALSE]
  row.names(canonical) <- NULL
  retained_data <- canonical[canonical$Score != "NA", , drop = FALSE]
  row.names(retained_data) <- NULL

  effective_conditions <- retained_data[condition_cols]
  for (facet in condition_cols) {
    if (identical(condition_scope[[facet]], "stratum_local")) {
      effective_conditions[[facet]] <- paste(
        retained_data$Stratum, retained_data[[facet]], sep = "\034"
      )
    }
  }
  list(
    Data = retained_data,
    EffectiveConditions = effective_conditions,
    ObjectColumn = object_col,
    StratumColumn = stratum_col,
    ScoreColumn = score_col,
    Strata = strata,
    ConditionColumns = condition_cols,
    ConditionScope = condition_scope,
    Missingness = missingness,
    InputRows = nrow(data),
    RetainedRows = sum(retained),
    MissingScoreRows = sum(!retained),
    CanonicalInputHash = mfrmr_gta_hash(canonical),
    RetainedDataHash = mfrmr_gta_hash(retained_data),
    OmissionPatternHash = mfrmr_gta_hash(canonical[canonical$Score == "NA",
                                                     , drop = FALSE])
  )
}

mfrmr_gtvi_stratum_audit <- function(prepared) {
  rows <- lapply(prepared$Strata, function(stratum) {
    index <- prepared$Data$Stratum == stratum
    objects <- unique(prepared$Data$Object[index])
    counts <- table(prepared$Data$Object[index])
    data.frame(
      Stratum = stratum,
      RetainedRows = sum(index),
      ObservedObjects = length(objects),
      ObjectObservationMin = if (length(counts) > 0L) min(counts) else NA_integer_,
      ObjectObservationMedian = if (length(counts) > 0L) {
        stats::median(counts)
      } else NA_real_,
      ObjectObservationMax = if (length(counts) > 0L) max(counts) else NA_integer_,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gtvi_object_incidence <- function(prepared) {
  objects <- sort(unique(prepared$Data$Object), method = "radix")
  incidence <- matrix(
    FALSE, nrow = length(objects), ncol = length(prepared$Strata),
    dimnames = list(objects, prepared$Strata)
  )
  if (nrow(prepared$Data) > 0L) {
    incidence[cbind(
      match(prepared$Data$Object, objects),
      match(prepared$Data$Stratum, prepared$Strata)
    )] <- TRUE
  }
  incidence
}

mfrmr_gtvi_object_patterns <- function(incidence) {
  if (nrow(incidence) == 0L) {
    return(data.frame(
      Pattern = character(), ObjectCount = integer(),
      stringsAsFactors = FALSE
    ))
  }
  patterns <- apply(incidence, 1L, function(row) {
    observed <- colnames(incidence)[row]
    if (length(observed) == 0L) "<NONE>" else paste(observed, collapse = "|")
  })
  counts <- table(patterns)
  data.frame(
    Pattern = names(counts), ObjectCount = as.integer(counts),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvi_object_pairs <- function(incidence, min_shared_objects) {
  pairs <- utils::combn(colnames(incidence), 2L, simplify = FALSE)
  rows <- lapply(pairs, function(pair) {
    left <- incidence[, pair[[1L]]]
    right <- incidence[, pair[[2L]]]
    left_count <- sum(left)
    right_count <- sum(right)
    shared <- sum(left & right)
    union_count <- sum(left | right)
    data.frame(
      LeftStratum = pair[[1L]], RightStratum = pair[[2L]],
      LeftObjects = left_count, RightObjects = right_count,
      SharedObjects = shared, UnionObjects = union_count,
      Jaccard = if (union_count > 0L) shared / union_count else NA_real_,
      LeftOverlap = if (left_count > 0L) shared / left_count else NA_real_,
      RightOverlap = if (right_count > 0L) shared / right_count else NA_real_,
      DirectCovarianceOverlapEligible = shared >= min_shared_objects,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gtvi_stratum_graph <- function(strata, object_pairs) {
  eligible <- object_pairs$DirectCovarianceOverlapEligible
  edges <- if (any(eligible)) {
    as.matrix(object_pairs[eligible, c("LeftStratum", "RightStratum"),
                           drop = FALSE])
  } else {
    matrix(character(), ncol = 2L)
  }
  graph <- mfrmr_gtvi_components(strata, edges)
  data.frame(
    Strata = length(strata), EligibleEdges = nrow(edges),
    PotentialEdges = nrow(object_pairs), ConnectedComponents = graph$Count,
    Connected = identical(graph$Count, 1L),
    CompletePairwiseOverlap = all(eligible), stringsAsFactors = FALSE
  )
}

mfrmr_gtvi_condition_pairs <- function(prepared, min_shared_conditions) {
  stratum_pairs <- utils::combn(prepared$Strata, 2L, simplify = FALSE)
  rows <- list()
  cursor <- 0L
  for (facet in prepared$ConditionColumns) {
    for (pair in stratum_pairs) {
      left <- unique(prepared$EffectiveConditions[[facet]][
        prepared$Data$Stratum == pair[[1L]]
      ])
      right <- unique(prepared$EffectiveConditions[[facet]][
        prepared$Data$Stratum == pair[[2L]]
      ])
      shared <- intersect(left, right)
      sharing <- if (identical(prepared$ConditionScope[[facet]],
                               "stratum_local")) {
        "structurally_disjoint_by_scope"
      } else if (length(shared) == 0L) {
        "observed_disjoint"
      } else if (setequal(left, right)) {
        "observed_common"
      } else {
        "observed_partial"
      }
      cursor <- cursor + 1L
      rows[[cursor]] <- data.frame(
        Facet = facet, Scope = prepared$ConditionScope[[facet]],
        CrossStratumCovarianceTarget = if (identical(
          prepared$ConditionScope[[facet]], "global"
        )) "candidate_if_direct_overlap" else "structural_zero_by_scope",
        LeftStratum = pair[[1L]], RightStratum = pair[[2L]],
        LeftLevels = length(left), RightLevels = length(right),
        SharedLevels = length(shared), SharingState = sharing,
        DirectComponentCovarianceOverlapEligible =
          length(shared) >= min_shared_conditions,
        stringsAsFactors = FALSE
      )
    }
  }
  do.call(rbind, rows)
}

mfrmr_gtvi_audit <- function(
    data, object_col, stratum_col, score_col, condition_cols,
    condition_scope, strata, missingness = "unknown",
    min_objects_per_stratum = 2L, min_shared_objects = 2L,
    min_shared_conditions = 2L) {
  min_objects_per_stratum <- mfrmr_gtvi_positive_integer(
    min_objects_per_stratum, "`min_objects_per_stratum`"
  )
  min_shared_objects <- mfrmr_gtvi_positive_integer(
    min_shared_objects, "`min_shared_objects`"
  )
  min_shared_conditions <- mfrmr_gtvi_positive_integer(
    min_shared_conditions, "`min_shared_conditions`"
  )
  prepared <- mfrmr_gtvi_prepare(
    data = data, object_col = object_col, stratum_col = stratum_col,
    score_col = score_col, condition_cols = condition_cols,
    condition_scope = condition_scope, strata = strata,
    missingness = missingness
  )
  stratum_audit <- mfrmr_gtvi_stratum_audit(prepared)
  object_incidence <- mfrmr_gtvi_object_incidence(prepared)
  object_patterns <- mfrmr_gtvi_object_patterns(object_incidence)
  object_pairs <- mfrmr_gtvi_object_pairs(
    object_incidence, min_shared_objects
  )
  stratum_graph <- mfrmr_gtvi_stratum_graph(
    prepared$Strata, object_pairs
  )
  condition_pairs <- mfrmr_gtvi_condition_pairs(
    prepared, min_shared_conditions
  )

  issues <- character()
  if (prepared$RetainedRows == 0L) issues <- c(issues, "no_retained_rows")
  absent_strata <- stratum_audit$Stratum[stratum_audit$RetainedRows == 0L]
  if (length(absent_strata) > 0L) {
    issues <- c(issues, paste0(
      "declared_strata_without_retained_rows:",
      paste(absent_strata, collapse = ",")
    ))
  }
  small_strata <- stratum_audit$Stratum[
    stratum_audit$ObservedObjects < min_objects_per_stratum
  ]
  if (length(small_strata) > 0L) {
    issues <- c(issues, paste0(
      "insufficient_objects_by_stratum:", paste(small_strata, collapse = ",")
    ))
  }
  if (prepared$MissingScoreRows > 0L &&
      identical(prepared$Missingness, "complete")) {
    issues <- c(issues, "declared_complete_but_scores_missing")
  }
  if (prepared$MissingScoreRows > 0L &&
      identical(prepared$Missingness, "unknown")) {
    issues <- c(issues, "unknown_missingness_with_score_omissions")
  }
  if (!isTRUE(stratum_graph$Connected)) {
    issues <- c(issues, "object_overlap_graph_disconnected")
  }
  if (!isTRUE(stratum_graph$CompletePairwiseOverlap)) {
    failed <- object_pairs[!object_pairs$DirectCovarianceOverlapEligible,
                           , drop = FALSE]
    issues <- c(issues, paste0(
      "insufficient_direct_object_overlap:",
      paste(paste(failed$LeftStratum, failed$RightStratum, sep = ":"),
            collapse = ",")
    ))
  }
  condition_failures <- condition_pairs[
    condition_pairs$Scope == "global" &
      !condition_pairs$DirectComponentCovarianceOverlapEligible,
    , drop = FALSE
  ]
  if (nrow(condition_failures) > 0L) {
    issues <- c(issues, paste0(
      "insufficient_shared_global_conditions:",
      paste(paste(
        condition_failures$Facet, condition_failures$LeftStratum,
        condition_failures$RightStratum, sep = ":"
      ), collapse = ",")
    ))
  }
  issues <- unique(issues)
  incidence_ready <- length(issues) == 0L
  identity <- list(
    Contract = "gtheory_multivariate_incidence_draft85b0_v1",
    ObjectColumn = prepared$ObjectColumn,
    StratumColumn = prepared$StratumColumn,
    ScoreColumn = prepared$ScoreColumn,
    Strata = prepared$Strata,
    ConditionColumns = prepared$ConditionColumns,
    ConditionScope = prepared$ConditionScope,
    Missingness = prepared$Missingness,
    MinimumObjectsPerStratum = min_objects_per_stratum,
    MinimumSharedObjects = min_shared_objects,
    MinimumSharedConditions = min_shared_conditions,
    CanonicalInputHash = prepared$CanonicalInputHash,
    RetainedDataHash = prepared$RetainedDataHash,
    OmissionPatternHash = prepared$OmissionPatternHash,
    StratumAudit = stratum_audit,
    ObjectPatternAudit = object_patterns,
    ObjectPairAudit = object_pairs,
    StratumGraphAudit = stratum_graph,
    ConditionPairAudit = condition_pairs,
    Issues = issues
  )
  structure(c(identity, list(
    InputRows = prepared$InputRows,
    RetainedRows = prepared$RetainedRows,
    MissingScoreRows = prepared$MissingScoreRows,
    ObjectStratumIncidence = object_incidence,
    IncidenceReady = incidence_ready,
    AuditState = if (incidence_ready) {
      "incidence_ready_for_matched_backend_preflight"
    } else {
      "incidence_blocked"
    },
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    CoefficientEligible = FALSE,
    DecisionReady = FALSE,
    AuditHash = mfrmr_gta_hash(identity)
  )), class = "mfrmr_gtvi_audit")
}
