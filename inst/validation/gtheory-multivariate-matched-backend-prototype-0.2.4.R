# Draft.85b1 matched multivariate Gaussian covariance prototype.
#
# Repository-internal only. Source Draft.81, Draft.85a0, and Draft.85b0 first.
# The prototype binds a typed component map and exact observation-link identity
# to a narrow lme4/glmmTMB random-slope overlap. It computes no interval or
# operational coefficient and never marks a result inference- or decision-ready.

mfrmr_gtvb_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtvi_prepare", "mfrmr_gtvi_audit",
    "mfrmr_gtvi_positive_integer", "mfrmr_gtv_matrix_audit"
  )
  prototype_environment <- environment(mfrmr_gtvb_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = prototype_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.81, Draft.85a0, and Draft.85b0 before Draft.85b1: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtvb_tolerance <- function(value, argument, positive = FALSE) {
  value <- suppressWarnings(as.numeric(value))
  valid <- length(value) == 1L && !is.na(value) && is.finite(value) &&
    if (isTRUE(positive)) value > 0 else value >= 0
  if (!valid) {
    stop(argument, " must be one finite ",
         if (isTRUE(positive)) "positive" else "nonnegative", " number.",
         call. = FALSE)
  }
  value
}

mfrmr_gtvb_function_hash <- function(fun) {
  if (!is.function(fun)) {
    stop("A backend function identity could not be resolved.", call. = FALSE)
  }
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtvb_spec_payload_fields <- function() {
  c(
    "Contract", "IncidenceAuditHash", "RetainedDataHash", "Strata",
    "ComponentMap", "ComponentGroupPairAudit", "ComponentGroupCounts",
    "ObservationLinkColumns", "ObservationPairAudit", "ObservationKeyHash",
    "RowBindingHash", "BackendRowIdHash", "BackendResponseHash",
    "BackendDataHash", "FixedDesignHash", "FixedDesignColumns",
    "RandomDesignBlockHashes", "ComponentPairAuditHash",
    "DuplicateWithinStratumObservationKeys",
    "MaximumWithinStratumObservationMultiplicity", "MinimumSharedGroups",
    "FormulaCanonical", "RandomCoefficientCount", "CovarianceDesignAudit",
    "CovarianceDesignHash", "RankTolerance", "MaxCovarianceDesignCells",
    "RetainedRows", "ResidualContract", "Issues"
  )
}

mfrmr_gtvb_fit_payload_fields <- function() {
  c(
    "Contract", "SpecificationHash", "IncidenceAuditHash",
    "RetainedDataHash", "RowBindingHash", "BackendRowIdHash",
    "BackendResponseHash", "BackendDataHash", "ComponentPairAuditHash",
    "EstimatorIdentity", "FixedEffectsByStratum", "ComponentCovariances",
    "ComponentMatrixAudit", "RawBackendParameters", "LikelihoodIdentity",
    "FitDiagnostics", "BackendRowsMatch", "FitQualification"
  )
}

mfrmr_gtvb_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    identical(sort(names(attributes(object))), c("class", "names"))
}

mfrmr_gtvb_split_members <- function(value) {
  value <- as.character(value)
  if (length(value) != 1L || is.na(value)) {
    stop("Every component needs one member specification.", call. = FALSE)
  }
  if (!nzchar(value)) return(character())
  members <- trimws(strsplit(value, ":", fixed = TRUE)[[1L]])
  if (any(!nzchar(members)) || anyDuplicated(members)) {
    stop("Component members must be unique nonempty identities.",
         call. = FALSE)
  }
  members
}

mfrmr_gtvb_component_map <- function(
    component_map, object_col, condition_cols, condition_scope) {
  required <- c(
    "ComponentId", "UniverseRole", "Members", "CovarianceStructure"
  )
  if (!is.data.frame(component_map) || nrow(component_map) < 2L ||
      !all(required %in% names(component_map))) {
    stop("`component_map` must contain ComponentId, UniverseRole, Members, ",
         "and CovarianceStructure.", call. = FALSE)
  }
  map <- component_map[required]
  for (column in required) map[[column]] <- as.character(map[[column]])
  if (anyNA(map) || any(!nzchar(map$ComponentId)) ||
      anyDuplicated(map$ComponentId)) {
    stop("Component identities must be complete and unique.", call. = FALSE)
  }
  allowed_roles <- c("object", "relative_error", "absolute_only")
  if (any(!map$UniverseRole %in% allowed_roles)) {
    stop("Component universe roles are invalid.", call. = FALSE)
  }
  residual <- map$ComponentId == "Residual"
  if (sum(residual) != 1L) {
    stop("The matched overlap requires exactly one Residual component.",
         call. = FALSE)
  }
  members <- lapply(map$Members, mfrmr_gtvb_split_members)
  if (length(members[[which(residual)]]) != 0L ||
      !identical(map$UniverseRole[[which(residual)]], "relative_error") ||
      !identical(
        map$CovarianceStructure[[which(residual)]],
        "homoskedastic_independent"
      )) {
    stop("Residual must have no members, relative_error role, and ",
         "homoskedastic_independent covariance.", call. = FALSE)
  }
  nonresidual <- which(!residual)
  if (any(map$CovarianceStructure[nonresidual] != "unstructured")) {
    stop("Every non-residual Draft.85b1 component must use unstructured ",
         "stratum covariance.", call. = FALSE)
  }
  declared <- c(object_col, condition_cols)
  for (index in nonresidual) {
    if (length(members[[index]]) == 0L ||
        any(!members[[index]] %in% declared)) {
      stop("Every non-residual component must use declared object/condition ",
           "members.", call. = FALSE)
    }
    canonical <- declared[declared %in% members[[index]]]
    if (!identical(members[[index]], canonical) ||
        !identical(map$ComponentId[[index]], paste(canonical, collapse = ":"))) {
      stop("ComponentId and Members must follow declared semantic order.",
           call. = FALSE)
    }
  }
  object_rows <- which(map$UniverseRole == "object")
  if (length(object_rows) != 1L ||
      !identical(members[[object_rows]], object_col) ||
      !identical(map$ComponentId[[object_rows]], object_col)) {
    stop("The map needs exactly one object component containing only `object_col`.",
         call. = FALSE)
  }
  if (!any(map$UniverseRole == "relative_error")) {
    stop("At least one relative-error component is required.", call. = FALSE)
  }
  expected_roles <- vapply(seq_len(nrow(map)), function(index) {
    if (residual[[index]]) return("relative_error")
    if (identical(members[[index]], object_col)) return("object")
    if (object_col %in% members[[index]]) {
      "relative_error"
    } else {
      "absolute_only"
    }
  }, character(1L))
  if (!identical(map$UniverseRole, expected_roles)) {
    stop("UniverseRole must be object for the object effect, relative_error ",
         "for object-containing interactions and Residual, and absolute_only ",
         "for condition-only effects.", call. = FALSE)
  }
  order_key <- vapply(seq_len(nrow(map)), function(index) {
    if (residual[[index]]) return("999999/Residual")
    member_index <- match(members[[index]], declared)
    paste0(
      sprintf("%03d", length(member_index)), "/",
      paste(sprintf("%03d", member_index), collapse = ".")
    )
  }, character(1L))
  canonical_order <- order(order_key, method = "radix")
  map <- map[canonical_order, , drop = FALSE]
  members <- members[canonical_order]
  residual <- map$ComponentId == "Residual"
  nonresidual <- which(!residual)
  row.names(map) <- NULL
  local_members <- vapply(members, function(component_members) {
    any(component_members %in%
          names(condition_scope)[condition_scope == "stratum_local"])
  }, logical(1L))
  map$MemberList <- I(members)
  map$BackendGroup <- NA_character_
  map$BackendGroup[nonresidual] <- sprintf(
    ".gtvb_group_%03d", seq_along(nonresidual)
  )
  map$MatchedBackendStatus <- ifelse(
    residual, "homoskedastic_independent_residual",
    ifelse(local_members,
           "blocked_stratum_local_unstructured_covariance",
           "candidate_global_unstructured_covariance")
  )
  map$IdentityScope <- ifelse(
    residual, "observation_residual",
    ifelse(local_members, "contains_stratum_local_identity", "global_identity")
  )
  map$PairingType <- ifelse(
    residual, "none_iid_residual",
    ifelse(map$ComponentId == object_col,
           "globally_linked_object", "component_joint_group_key")
  )
  map
}

mfrmr_gtvb_bind_incidence <- function(data, incidence_audit) {
  if (!inherits(incidence_audit, "mfrmr_gtvi_audit")) {
    stop("`incidence_audit` must be a Draft.85b0 audit.", call. = FALSE)
  }
  required_identity <- c(
    "ObjectColumn", "StratumColumn", "ScoreColumn", "Strata",
    "ConditionColumns", "ConditionScope", "Missingness"
  )
  if (!all(required_identity %in% names(incidence_audit))) {
    stop("The incidence audit predates the Draft.85b1 semantic-column identity.",
         call. = FALSE)
  }
  replay <- mfrmr_gtvi_audit(
    data = data,
    object_col = incidence_audit$ObjectColumn,
    stratum_col = incidence_audit$StratumColumn,
    score_col = incidence_audit$ScoreColumn,
    condition_cols = incidence_audit$ConditionColumns,
    condition_scope = incidence_audit$ConditionScope,
    strata = incidence_audit$Strata,
    missingness = incidence_audit$Missingness,
    min_objects_per_stratum = incidence_audit$MinimumObjectsPerStratum,
    min_shared_objects = incidence_audit$MinimumSharedObjects,
    min_shared_conditions = incidence_audit$MinimumSharedConditions
  )
  if (!identical(replay$AuditHash, incidence_audit$AuditHash)) {
    stop("The Draft.85b0 incidence identity does not replay exactly.",
         call. = FALSE)
  }
  prepared <- mfrmr_gtvi_prepare(
    data = data,
    object_col = incidence_audit$ObjectColumn,
    stratum_col = incidence_audit$StratumColumn,
    score_col = incidence_audit$ScoreColumn,
    condition_cols = incidence_audit$ConditionColumns,
    condition_scope = incidence_audit$ConditionScope,
    strata = incidence_audit$Strata,
    missingness = incidence_audit$Missingness
  )
  expected <- c(
    CanonicalInputHash = prepared$CanonicalInputHash,
    RetainedDataHash = prepared$RetainedDataHash,
    OmissionPatternHash = prepared$OmissionPatternHash
  )
  observed <- c(
    CanonicalInputHash = incidence_audit$CanonicalInputHash,
    RetainedDataHash = incidence_audit$RetainedDataHash,
    OmissionPatternHash = incidence_audit$OmissionPatternHash
  )
  if (!identical(expected, observed)) {
    stop("The data or omission pattern do not match the Draft.85b0 audit.",
         call. = FALSE)
  }
  identifier_values <- c(
    list(prepared$Data$Object, prepared$Data$Stratum),
    unname(prepared$Data[prepared$ConditionColumns])
  )
  has_reserved_delimiter <- any(vapply(identifier_values, function(value) {
    value <- as.character(value)
    any(grepl("\034", value, fixed = TRUE) |
          grepl("\035", value, fixed = TRUE) |
          grepl("\036", value, fixed = TRUE))
  }, logical(1L)))
  if (has_reserved_delimiter) {
    stop("Identifier values contain a reserved tuple delimiter.", call. = FALSE)
  }
  prepared
}

mfrmr_gtvb_effective_member <- function(prepared, member) {
  if (identical(member, prepared$ObjectColumn)) {
    return(prepared$Data$Object)
  }
  value <- prepared$Data[[member]]
  if (identical(prepared$ConditionScope[[member]], "stratum_local")) {
    value <- paste(prepared$Data$Stratum, value, sep = "\034")
  }
  value
}

mfrmr_gtvb_key <- function(values) {
  if (length(values) == 1L) return(as.character(values[[1L]]))
  do.call(paste, c(lapply(values, as.character), list(sep = "\035")))
}

mfrmr_gtvb_group_audit <- function(prepared, component_map,
                                    min_shared_groups) {
  pairs <- utils::combn(prepared$Strata, 2L, simplify = FALSE)
  rows <- list()
  cursor <- 0L
  nonresidual <- which(component_map$ComponentId != "Residual")
  grouping <- vector("list", nrow(component_map))
  names(grouping) <- component_map$ComponentId
  for (index in nonresidual) {
    members <- component_map$MemberList[[index]]
    key <- mfrmr_gtvb_key(lapply(
      members, function(member) mfrmr_gtvb_effective_member(prepared, member)
    ))
    grouping[[index]] <- key
    for (pair in pairs) {
      left <- unique(key[prepared$Data$Stratum == pair[[1L]]])
      right <- unique(key[prepared$Data$Stratum == pair[[2L]]])
      shared <- length(intersect(left, right))
      left_counts <- table(key[prepared$Data$Stratum == pair[[1L]]])
      right_counts <- table(key[prepared$Data$Stratum == pair[[2L]]])
      shared_ids <- intersect(names(left_counts), names(right_counts))
      cross_row_pairs <- sum(
        left_counts[shared_ids] * right_counts[shared_ids]
      )
      cursor <- cursor + 1L
      rows[[cursor]] <- data.frame(
        ComponentId = component_map$ComponentId[[index]],
        Members = component_map$Members[[index]],
        LeftStratum = pair[[1L]], RightStratum = pair[[2L]],
        LeftGroups = length(left), RightGroups = length(right),
        SharedGroups = shared,
        CrossStratumRowPairs = as.numeric(cross_row_pairs),
        LeftWithinGroupRowPairs = sum(left_counts * (left_counts - 1) / 2),
        RightWithinGroupRowPairs = sum(right_counts * (right_counts - 1) / 2),
        DirectUnstructuredOverlapEligible = shared >= min_shared_groups,
        stringsAsFactors = FALSE
      )
    }
  }
  list(
    GroupKeys = grouping,
    PairAudit = do.call(rbind, rows),
    GroupCounts = stats::setNames(vapply(
      grouping[nonresidual], function(value) length(unique(value)), integer(1L)
    ), component_map$ComponentId[nonresidual])
  )
}

mfrmr_gtvb_observation_audit <- function(prepared, observation_link_cols) {
  observation_link_cols <- as.character(observation_link_cols)
  if (length(observation_link_cols) == 0L || anyNA(observation_link_cols) ||
      any(!nzchar(observation_link_cols)) ||
      anyDuplicated(observation_link_cols) ||
      any(!observation_link_cols %in% prepared$ConditionColumns)) {
    stop("`observation_link_cols` must be a nonempty unique subset of ",
         "condition columns.", call. = FALSE)
  }
  values <- c(
    list(mfrmr_gtvb_effective_member(prepared, prepared$ObjectColumn)),
    lapply(observation_link_cols, function(member) {
      mfrmr_gtvb_effective_member(prepared, member)
    })
  )
  key <- mfrmr_gtvb_key(values)
  within_key <- paste(prepared$Data$Stratum, key, sep = "\036")
  counts <- table(within_key)
  pairs <- utils::combn(prepared$Strata, 2L, simplify = FALSE)
  pair_rows <- lapply(pairs, function(pair) {
    left <- unique(key[prepared$Data$Stratum == pair[[1L]]])
    right <- unique(key[prepared$Data$Stratum == pair[[2L]]])
    data.frame(
      LeftStratum = pair[[1L]], RightStratum = pair[[2L]],
      LeftObservationLinks = length(left), RightObservationLinks = length(right),
      SharedObservationLinks = length(intersect(left, right)),
      stringsAsFactors = FALSE
    )
  })
  list(
    Columns = observation_link_cols,
    ObservationKey = key,
    WithinStratumKey = within_key,
    PairAudit = do.call(rbind, pair_rows),
    DuplicateWithinStratumKeys = sum(counts > 1L),
    MaximumWithinStratumMultiplicity = if (length(counts) > 0L) {
      max(counts)
    } else NA_integer_,
    UniqueWithinStratum = !any(counts > 1L),
    ObservationKeyHash = mfrmr_gta_hash(data.frame(
      Stratum = prepared$Data$Stratum, ObservationKey = key,
      stringsAsFactors = FALSE
    ))
  )
}

mfrmr_gtvb_formula <- function(component_map) {
  groups <- component_map$BackendGroup[
    component_map$ComponentId != "Residual"
  ]
  random <- paste0("us(0 + .gtvb_stratum | ", groups, ")")
  stats::as.formula(paste(
    ".gtvb_score ~ 0 + .gtvb_stratum +",
    paste(random, collapse = " + ")
  ))
}

mfrmr_gtvb_backend_binding <- function(backend_data, component_map) {
  nonresidual <- which(component_map$ComponentId != "Residual")
  group_columns <- component_map$BackendGroup[nonresidual]
  required <- c(".gtvb_score", ".gtvb_stratum", group_columns)
  row_id <- row.names(backend_data)
  exact_data_attributes <- identical(
    sort(names(attributes(backend_data))), c("class", "names", "row.names")
  )
  valid_columns <- is.data.frame(backend_data) &&
    identical(names(backend_data), required) && exact_data_attributes &&
    is.numeric(backend_data$.gtvb_score) &&
    is.factor(backend_data$.gtvb_stratum) &&
    !is.ordered(backend_data$.gtvb_stratum) &&
    all(vapply(group_columns, function(group) {
      is.factor(backend_data[[group]]) && !is.ordered(backend_data[[group]])
    }, logical(1L)))
  if (!valid_columns ||
      is.null(row_id) || anyNA(row_id) || any(!nzchar(row_id)) ||
      anyDuplicated(row_id) || anyNA(backend_data[required])) {
    stop("The matched-backend data binding is malformed.", call. = FALSE)
  }
  row_data <- data.frame(
    RowId = row_id,
    Score = sprintf("%.17g", as.numeric(backend_data$.gtvb_score)),
    Stratum = as.character(backend_data$.gtvb_stratum),
    stringsAsFactors = FALSE
  )
  for (group in group_columns) {
    row_data[[group]] <- as.character(backend_data[[group]])
  }
  binding <- list(
    RowData = row_data,
    ColumnSchema = lapply(backend_data, function(column) list(
      Type = typeof(column), Class = class(column),
      Ordered = is.ordered(column), Levels = levels(column),
      Contrasts = attr(column, "contrasts", exact = TRUE),
      AttributeNames = sort(names(attributes(column)))
    )),
    StratumLevels = levels(backend_data$.gtvb_stratum),
    GroupLevels = stats::setNames(
      lapply(group_columns, function(group) levels(backend_data[[group]])),
      component_map$ComponentId[nonresidual]
    )
  )
  list(
    Binding = binding,
    BackendRowIdHash = mfrmr_gta_hash(row_id),
    BackendResponseHash = mfrmr_gta_hash(stats::setNames(
      as.numeric(backend_data$.gtvb_score), row_id
    )),
    BackendDataHash = mfrmr_gta_hash(binding)
  )
}

mfrmr_gtvb_covariance_design_audit <- function(
    backend_data, component_map, strata, rank_tolerance,
    max_covariance_design_cells) {
  n <- nrow(backend_data)
  nonresidual <- which(component_map$ComponentId != "Residual")
  per_component <- length(strata) * (length(strata) + 1L) / 2L
  parameter_count <- length(nonresidual) * per_component + 1L
  vech_rows <- n * (n + 1) / 2
  matrix_cells <- vech_rows * parameter_count
  labels <- character()
  for (index in nonresidual) {
    for (left in seq_along(strata)) {
      for (right in seq.int(left, length(strata))) {
        labels <- c(labels, paste0(
          component_map$ComponentId[[index]], "[", strata[[left]], ",",
          strata[[right]], "]"
        ))
      }
    }
  }
  labels <- c(labels, "Residual[I]")
  if (matrix_cells > max_covariance_design_cells) {
    return(list(
      CapacityStatus = "not_evaluated_capacity",
      VechRows = vech_rows, ParameterCount = parameter_count,
      MatrixCells = matrix_cells, StructuralRank = NA_integer_,
      StructuralRankFull = FALSE, ParameterLabels = labels,
      CrossproductHash = NA_character_
    ))
  }
  lower <- lower.tri(matrix(0, n, n), diag = TRUE)
  design <- matrix(0, nrow = vech_rows, ncol = parameter_count)
  column <- 0L
  stratum_index <- as.integer(backend_data$.gtvb_stratum)
  for (index in nonresidual) {
    group <- as.integer(backend_data[[component_map$BackendGroup[[index]]]])
    same_group <- outer(group, group, FUN = "==")
    for (left in seq_along(strata)) {
      for (right in seq.int(left, length(strata))) {
        column <- column + 1L
        indicator <- outer(
          stratum_index == left, stratum_index == right, FUN = "&"
        )
        if (left != right) {
          indicator <- indicator | outer(
            stratum_index == right, stratum_index == left, FUN = "&"
          )
        }
        design[, column] <- as.numeric((same_group & indicator)[lower])
      }
    }
  }
  column <- column + 1L
  design[, column] <- as.numeric(diag(n)[lower])
  colnames(design) <- labels
  crossproduct <- crossprod(design)
  eigenvalues <- eigen(
    (crossproduct + t(crossproduct)) / 2,
    symmetric = TRUE, only.values = TRUE
  )$values
  threshold <- rank_tolerance^2 * max(1, max(eigenvalues))
  rank <- sum(eigenvalues > threshold)
  list(
    CapacityStatus = "evaluated",
    VechRows = vech_rows, ParameterCount = parameter_count,
    MatrixCells = matrix_cells, StructuralRank = as.integer(rank),
    StructuralRankFull = identical(as.integer(rank), as.integer(parameter_count)),
    ParameterLabels = labels, MinimumDesignGramEigenvalue = min(eigenvalues),
    MaximumDesignGramEigenvalue = max(eigenvalues), RankThreshold = threshold,
    CrossproductHash = mfrmr_gta_hash(crossproduct)
  )
}

mfrmr_gtvb_spec <- function(
    data, incidence_audit, component_map, observation_link_cols,
    min_shared_groups = 2L, rank_tolerance = 1e-10,
    max_covariance_design_cells = 5e6) {
  mfrmr_gtvb_require_primitives()
  min_shared_groups <- mfrmr_gtvi_positive_integer(
    min_shared_groups, "`min_shared_groups`"
  )
  rank_tolerance <- mfrmr_gtvb_tolerance(
    rank_tolerance, "`rank_tolerance`", positive = TRUE
  )
  max_covariance_design_cells <- mfrmr_gtvi_positive_integer(
    max_covariance_design_cells, "`max_covariance_design_cells`"
  )
  prepared <- mfrmr_gtvb_bind_incidence(data, incidence_audit)
  component_map <- mfrmr_gtvb_component_map(
    component_map,
    object_col = prepared$ObjectColumn,
    condition_cols = prepared$ConditionColumns,
    condition_scope = prepared$ConditionScope
  )
  groups <- mfrmr_gtvb_group_audit(
    prepared, component_map, min_shared_groups
  )
  observation <- mfrmr_gtvb_observation_audit(
    prepared, observation_link_cols
  )
  backend_data <- data.frame(
    .gtvb_score = as.numeric(prepared$Data$Score),
    .gtvb_stratum = factor(
      prepared$Data$Stratum, levels = prepared$Strata, ordered = FALSE
    ),
    stringsAsFactors = FALSE
  )
  nonresidual <- which(component_map$ComponentId != "Residual")
  for (index in nonresidual) {
    backend_data[[component_map$BackendGroup[[index]]]] <- factor(
      groups$GroupKeys[[component_map$ComponentId[[index]]]]
    )
  }
  row.names(backend_data) <- sprintf("gtvb_row_%08d", seq_len(nrow(backend_data)))
  backend_binding <- mfrmr_gtvb_backend_binding(
    backend_data, component_map
  )
  row_binding <- data.frame(
    Stratum = as.character(backend_data$.gtvb_stratum),
    ObservationKey = observation$ObservationKey,
    Score = sprintf("%.17g", backend_data$.gtvb_score),
    stringsAsFactors = FALSE
  )
  for (index in nonresidual) {
    row_binding[[component_map$BackendGroup[[index]]]] <-
      as.character(backend_data[[component_map$BackendGroup[[index]]]])
  }
  row_binding_hash <- mfrmr_gta_hash(row_binding)
  fixed_design <- stats::model.matrix(
    ~ 0 + .gtvb_stratum, data = backend_data
  )
  fixed_design_hash <- mfrmr_gta_hash(list(
    Strata = prepared$Strata,
    ColumnNames = colnames(fixed_design),
    Matrix = matrix(
      as.numeric(fixed_design), nrow(fixed_design), ncol(fixed_design)
    )
  ))
  random_design_hashes <- stats::setNames(vapply(
    nonresidual, function(index) {
      group <- component_map$BackendGroup[[index]]
      mfrmr_gta_hash(list(
        Strata = prepared$Strata,
        Group = as.character(backend_data[[group]])
      ))
    }, character(1L)
  ), component_map$ComponentId[nonresidual])
  formula <- mfrmr_gtvb_formula(component_map)
  random_coefficient_count <- length(prepared$Strata) *
    sum(groups$GroupCounts)
  covariance_design <- mfrmr_gtvb_covariance_design_audit(
    backend_data, component_map, prepared$Strata, rank_tolerance,
    max_covariance_design_cells
  )

  issues <- character()
  if (!isTRUE(incidence_audit$IncidenceReady)) {
    issues <- c(issues, "draft85b0_incidence_not_ready")
  }
  if (incidence_audit$MissingScoreRows > 0L) {
    issues <- c(issues, "missing_scores_outside_draft85b1_matched_point_overlap")
  }
  local <- component_map$MatchedBackendStatus ==
    "blocked_stratum_local_unstructured_covariance"
  if (any(local)) {
    issues <- c(issues, paste0(
      "stratum_local_unstructured_component_not_in_matched_overlap:",
      paste(component_map$ComponentId[local], collapse = ",")
    ))
  }
  failed_groups <- groups$PairAudit[
    !groups$PairAudit$DirectUnstructuredOverlapEligible, , drop = FALSE
  ]
  if (nrow(failed_groups) > 0L) {
    issues <- c(issues, paste0(
      "insufficient_direct_component_group_overlap:",
      paste(paste(
        failed_groups$ComponentId, failed_groups$LeftStratum,
        failed_groups$RightStratum, sep = ":"
      ), collapse = ",")
    ))
  }
  if (!isTRUE(observation$UniqueWithinStratum)) {
    issues <- c(issues, "ambiguous_observation_pair_identity")
  }
  if (random_coefficient_count >= nrow(backend_data)) {
    issues <- c(issues, "random_coefficient_count_not_below_retained_rows")
  }
  if (!identical(covariance_design$CapacityStatus, "evaluated")) {
    issues <- c(issues, "covariance_design_rank_not_evaluated_capacity")
  } else if (!isTRUE(covariance_design$StructuralRankFull)) {
    issues <- c(issues, "covariance_design_rank_deficient")
  }
  issues <- unique(issues)
  payload <- list(
    Contract = "gtheory_multivariate_matched_spec_draft85b1_v1",
    IncidenceAuditHash = incidence_audit$AuditHash,
    RetainedDataHash = prepared$RetainedDataHash,
    Strata = prepared$Strata,
    ComponentMap = component_map,
    ComponentGroupPairAudit = groups$PairAudit,
    ComponentGroupCounts = groups$GroupCounts,
    ObservationLinkColumns = observation$Columns,
    ObservationPairAudit = observation$PairAudit,
    ObservationKeyHash = observation$ObservationKeyHash,
    RowBindingHash = row_binding_hash,
    BackendRowIdHash = backend_binding$BackendRowIdHash,
    BackendResponseHash = backend_binding$BackendResponseHash,
    BackendDataHash = backend_binding$BackendDataHash,
    FixedDesignHash = fixed_design_hash,
    FixedDesignColumns = colnames(fixed_design),
    RandomDesignBlockHashes = random_design_hashes,
    ComponentPairAuditHash = mfrmr_gta_hash(groups$PairAudit),
    DuplicateWithinStratumObservationKeys =
      observation$DuplicateWithinStratumKeys,
    MaximumWithinStratumObservationMultiplicity =
      observation$MaximumWithinStratumMultiplicity,
    MinimumSharedGroups = min_shared_groups,
    FormulaCanonical = paste(deparse(formula, width.cutoff = 500L),
                             collapse = " "),
    RandomCoefficientCount = random_coefficient_count,
    CovarianceDesignAudit = covariance_design,
    CovarianceDesignHash = mfrmr_gta_hash(covariance_design),
    RankTolerance = rank_tolerance,
    MaxCovarianceDesignCells = max_covariance_design_cells,
    RetainedRows = nrow(backend_data),
    ResidualContract = "homoskedastic_independent_common_variance",
    Issues = issues
  )
  structure(c(payload, list(
    SpecificationHash = mfrmr_gta_hash(payload),
    SpecificationPayloadFields = names(payload),
    BackendData = backend_data,
    SpecReady = length(issues) == 0L,
    PointFitEligible = length(issues) == 0L,
    ComponentMapReady = TRUE,
    PairIdentityReady = isTRUE(observation$UniqueWithinStratum),
    DirectCovarianceSupportReady = nrow(failed_groups) == 0L && !any(local),
    CovarianceDesignRankReady = isTRUE(covariance_design$StructuralRankFull),
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtvb_spec")
}

mfrmr_gtvb_assert_fit_spec <- function(spec) {
  payload_fields <- mfrmr_gtvb_spec_payload_fields()
  suffix_fields <- c(
    "SpecificationHash", "SpecificationPayloadFields", "BackendData",
    "SpecReady", "PointFitEligible",
    "ComponentMapReady", "PairIdentityReady",
    "DirectCovarianceSupportReady", "CovarianceDesignRankReady",
    "EstimationReady", "InferenceReady", "CoefficientEligible",
    "DecisionReady"
  )
  if (!mfrmr_gtvb_exact_object(
    spec, c(payload_fields, suffix_fields), "mfrmr_gtvb_spec"
  ) || !identical(spec$SpecificationPayloadFields, payload_fields)) {
    stop("`spec` must be a Draft.85b1 matched-backend specification.",
         call. = FALSE)
  }
  expected_formula <- mfrmr_gtvb_formula(spec$ComponentMap)
  expected_formula_canonical <- paste(
    deparse(expected_formula, width.cutoff = 500L), collapse = " "
  )
  expected_ready <- length(spec$Issues) == 0L
  expected_pair_ready <-
    identical(spec$DuplicateWithinStratumObservationKeys, 0L)
  expected_direct_ready <-
    !any(spec$ComponentMap$MatchedBackendStatus ==
           "blocked_stratum_local_unstructured_covariance") &&
    all(spec$ComponentGroupPairAudit$DirectUnstructuredOverlapEligible)
  expected_rank_ready <-
    isTRUE(spec$CovarianceDesignAudit$StructuralRankFull)
  base_integrity <-
    identical(mfrmr_gta_hash(spec[payload_fields]), spec$SpecificationHash) &&
    identical(spec$FormulaCanonical, expected_formula_canonical) &&
    identical(spec$SpecReady, expected_ready) &&
    identical(spec$PointFitEligible, expected_ready) &&
    isTRUE(spec$ComponentMapReady) &&
    identical(spec$PairIdentityReady, expected_pair_ready) &&
    identical(spec$DirectCovarianceSupportReady, expected_direct_ready) &&
    identical(spec$CovarianceDesignRankReady, expected_rank_ready) &&
    identical(spec$EstimationReady, FALSE) &&
    identical(spec$InferenceReady, FALSE) &&
    identical(spec$CoefficientEligible, FALSE) &&
    identical(spec$DecisionReady, FALSE)
  if (!base_integrity) {
    stop("The matched-backend specification identity was altered.",
         call. = FALSE)
  }
  binding <- mfrmr_gtvb_backend_binding(
    spec$BackendData, spec$ComponentMap
  )
  expected <- c(
    BackendRowIdHash = spec$BackendRowIdHash,
    BackendResponseHash = spec$BackendResponseHash,
    BackendDataHash = spec$BackendDataHash
  )
  observed <- c(
    BackendRowIdHash = binding$BackendRowIdHash,
    BackendResponseHash = binding$BackendResponseHash,
    BackendDataHash = binding$BackendDataHash
  )
  if (!identical(expected, observed)) {
    stop("The matched-backend data changed after specification binding.",
         call. = FALSE)
  }
  fixed_design <- stats::model.matrix(
    ~ 0 + .gtvb_stratum, data = spec$BackendData
  )
  current_fixed_hash <- mfrmr_gta_hash(list(
    Strata = spec$Strata, ColumnNames = colnames(fixed_design),
    Matrix = matrix(
      as.numeric(fixed_design), nrow(fixed_design), ncol(fixed_design)
    )
  ))
  nonresidual <- which(spec$ComponentMap$ComponentId != "Residual")
  current_random_hashes <- stats::setNames(vapply(
    nonresidual, function(index) {
      group <- spec$ComponentMap$BackendGroup[[index]]
      mfrmr_gta_hash(list(
        Strata = spec$Strata,
        Group = as.character(spec$BackendData[[group]])
      ))
    }, character(1L)
  ), spec$ComponentMap$ComponentId[nonresidual])
  current_covariance_design <- mfrmr_gtvb_covariance_design_audit(
    spec$BackendData, spec$ComponentMap, spec$Strata, spec$RankTolerance,
    spec$MaxCovarianceDesignCells
  )
  if (!identical(colnames(fixed_design), spec$FixedDesignColumns) ||
      !identical(current_fixed_hash, spec$FixedDesignHash) ||
      !identical(current_random_hashes, spec$RandomDesignBlockHashes) ||
      !identical(
        mfrmr_gta_hash(current_covariance_design), spec$CovarianceDesignHash
      )) {
    stop("The matched-backend design changed after specification binding.",
         call. = FALSE)
  }
  if (!isTRUE(spec$PointFitEligible)) {
    stop("Point fitting is blocked by the Draft.85b1 specification: ",
         paste(spec$Issues, collapse = "; "), ".", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvb_glmmtmb_abi <- function() {
  namespace <- suppressWarnings(asNamespace("glmmTMB"))
  build <- as.character(get(".TMB.build.version", envir = namespace))
  runtime <- as.character(utils::packageVersion("TMB"))
  list(
    BuildTMBVersion = build,
    RuntimeTMBVersion = runtime,
    ABIVersion = as.character(get("get_abi_version", envir = namespace)()),
    VersionMatch = identical(build, runtime)
  )
}

mfrmr_gtvb_normalize_matrix <- function(
    matrix, strata, matrix_id, tolerance, backend_names = strata) {
  matrix <- as.matrix(matrix)
  if (!is.numeric(matrix) ||
      !identical(dim(matrix), c(length(strata), length(strata)))) {
    stop("Backend covariance block `", matrix_id,
         "` does not match the declared stratum dimension.", call. = FALSE)
  }
  raw_dimnames <- dimnames(matrix)
  valid_names <- length(raw_dimnames) == 2L &&
    !is.null(raw_dimnames[[1L]]) && !is.null(raw_dimnames[[2L]]) &&
    !anyDuplicated(raw_dimnames[[1L]]) && !anyDuplicated(raw_dimnames[[2L]]) &&
    setequal(raw_dimnames[[1L]], backend_names) &&
    setequal(raw_dimnames[[2L]], backend_names)
  if (!isTRUE(valid_names)) {
    stop("Backend covariance block `", matrix_id,
         "` does not preserve the declared stratum coefficient names.",
         call. = FALSE)
  }
  matrix <- matrix[
    match(backend_names, raw_dimnames[[1L]]),
    match(backend_names, raw_dimnames[[2L]]),
    drop = FALSE
  ]
  dimnames(matrix) <- list(strata, strata)
  mfrmr_gtv_matrix_audit(
    matrix, strata, matrix_id, tolerance = tolerance
  )$Matrix
}

mfrmr_gtvb_extract_covariances <- function(
    fit, spec, backend, matrix_tolerance) {
  strata <- spec$Strata
  map <- spec$ComponentMap
  nonresidual <- which(map$ComponentId != "Residual")
  output <- vector("list", nrow(map))
  names(output) <- map$ComponentId
  if (identical(backend, "lme4")) {
    variance <- lme4::VarCorr(fit)
    for (index in nonresidual) {
      group <- map$BackendGroup[[index]]
      if (!group %in% names(variance)) {
        stop("lme4 omitted covariance block `", group, "`.", call. = FALSE)
      }
      output[[index]] <- mfrmr_gtvb_normalize_matrix(
        variance[[group]], strata, paste0("Covariance/", map$ComponentId[[index]]),
        matrix_tolerance, spec$FixedDesignColumns
      )
    }
    residual_variance <- as.numeric(stats::sigma(fit))^2
  } else {
    variance <- glmmTMB::VarCorr(fit)
    if (length(variance$zi) > 0L || length(variance$disp) > 0L) {
      stop("The matched overlap excludes zi/disp random-effect blocks.",
           call. = FALSE)
    }
    conditional <- variance$cond
    for (index in nonresidual) {
      group <- map$BackendGroup[[index]]
      if (!group %in% names(conditional)) {
        stop("glmmTMB omitted covariance block `", group, "`.", call. = FALSE)
      }
      output[[index]] <- mfrmr_gtvb_normalize_matrix(
        conditional[[group]], strata,
        paste0("Covariance/", map$ComponentId[[index]]), matrix_tolerance,
        spec$FixedDesignColumns
      )
    }
    residual_variance <- as.numeric(stats::sigma(fit))^2
  }
  if (length(residual_variance) != 1L || !is.finite(residual_variance) ||
      residual_variance < 0) {
    stop("The backend residual variance is invalid.", call. = FALSE)
  }
  residual <- diag(residual_variance, length(strata))
  dimnames(residual) <- list(strata, strata)
  output[[which(map$ComponentId == "Residual")]] <-
    mfrmr_gtvb_normalize_matrix(
      residual, strata, "Covariance/Residual", matrix_tolerance
    )
  output[map$ComponentId]
}

mfrmr_gtvb_covariance_audit <- function(
    covariance, component_map, tolerance, boundary_tolerance,
    correlation_tolerance) {
  rows <- lapply(seq_along(covariance), function(index) {
    matrix <- covariance[[index]]
    eigenvalues <- eigen(
      (matrix + t(matrix)) / 2, symmetric = TRUE, only.values = TRUE
    )$values
    diagonal <- diag(matrix)
    correlation <- if (all(diagonal > tolerance)) {
      stats::cov2cor(matrix)
    } else {
      matrix(NA_real_, nrow(matrix), ncol(matrix))
    }
    off_diagonal <- correlation[lower.tri(correlation)]
    maximum_correlation <- if (
      length(off_diagonal) > 0L && all(is.finite(off_diagonal))
    ) max(abs(off_diagonal)) else NA_real_
    residual <- identical(component_map$ComponentId[[index]], "Residual")
    boundary <- any(diagonal <= boundary_tolerance) ||
      min(eigenvalues) <= boundary_tolerance ||
      (!residual && is.finite(maximum_correlation) &&
         maximum_correlation >= 1 - correlation_tolerance)
    data.frame(
      ComponentId = component_map$ComponentId[[index]],
      UniverseRole = component_map$UniverseRole[[index]],
      Dimension = nrow(matrix), MinimumVariance = min(diagonal),
      MaximumVariance = max(diagonal), MinimumEigenvalue = min(eigenvalues),
      MaximumEigenvalue = max(eigenvalues),
      EffectiveRank = sum(eigenvalues > tolerance * max(1, max(eigenvalues))),
      MaximumAbsoluteCorrelation = maximum_correlation,
      BoundaryOrRankDeficient = boundary,
      MatrixHash = mfrmr_gta_hash(matrix), stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gtvb_backend_rows_match <- function(fit, spec) {
  frame <- stats::model.frame(fit)
  response <- stats::model.response(frame)
  identical(row.names(frame), row.names(spec$BackendData)) &&
    identical(as.numeric(response), as.numeric(spec$BackendData$.gtvb_score)) &&
    identical(as.integer(stats::nobs(fit)), nrow(spec$BackendData))
}

mfrmr_gtvb_lme4_diagnostics <- function(
    fit, warnings, messages, covariance_audit, singular_tolerance) {
  opt_code <- suppressWarnings(as.integer(fit@optinfo$conv$opt))
  if (length(opt_code) == 0L || is.na(opt_code)) opt_code <- NA_integer_
  convergence_messages <- fit@optinfo$conv$lme4$messages
  if (is.null(convergence_messages)) convergence_messages <- character()
  gradient <- fit@optinfo$derivs$gradient
  maximum_gradient <- if (length(gradient) > 0L && all(is.finite(gradient))) {
    max(abs(gradient))
  } else NA_real_
  hessian <- fit@optinfo$derivs$Hessian
  minimum_hessian <- if (is.matrix(hessian) && all(is.finite(hessian))) {
    min(eigen((hessian + t(hessian)) / 2, symmetric = TRUE,
              only.values = TRUE)$values)
  } else NA_real_
  singular <- isTRUE(lme4::isSingular(fit, tol = singular_tolerance))
  boundary <- any(covariance_audit$BoundaryOrRankDeficient)
  status <- if (is.na(opt_code) || opt_code != 0L ||
                length(convergence_messages) > 0L) {
    if (singular || boundary) {
      "optimizer_warning_with_boundary_covariance"
    } else {
      "optimizer_or_convergence_warning"
    }
  } else if (singular || boundary) {
    "boundary_or_singular_covariance"
  } else {
    "identified_point_fit"
  }
  data.frame(
    FitStatus = status, OptimizerCode = opt_code, Singular = singular,
    PositiveDefiniteHessian = is.finite(minimum_hessian) && minimum_hessian > 0,
    MaximumAbsoluteGradient = maximum_gradient,
    MinimumHessianEigenvalue = minimum_hessian,
    BoundaryComponentCount = sum(covariance_audit$BoundaryOrRankDeficient),
    WarningCount = length(warnings), MessageCount = length(messages),
    ConvergenceMessageCount = length(convergence_messages),
    Warnings = paste(warnings, collapse = " | "),
    Messages = paste(messages, collapse = " | "),
    ConvergenceMessages = paste(convergence_messages, collapse = " | "),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvb_glmmtmb_diagnostics <- function(
    fit, warnings, messages, covariance_audit, abi) {
  convergence <- suppressWarnings(as.integer(fit$fit$convergence[[1L]]))
  if (length(convergence) == 0L || is.na(convergence)) convergence <- NA_integer_
  gradient <- suppressWarnings(as.numeric(fit$sdr$gradient.fixed))
  maximum_gradient <- if (length(gradient) > 0L && all(is.finite(gradient))) {
    max(abs(gradient))
  } else NA_real_
  pd_hessian <- fit$sdr$pdHess
  if (length(pd_hessian) != 1L || is.na(pd_hessian)) pd_hessian <- NA
  boundary <- any(covariance_audit$BoundaryOrRankDeficient)
  status <- if (!isTRUE(abi$VersionMatch)) {
    "backend_dependency_version_mismatch"
  } else if (is.na(convergence) || convergence != 0L) {
    "optimizer_or_convergence_warning"
  } else if (!isTRUE(pd_hessian)) {
    "nonpositive_or_unavailable_hessian"
  } else if (boundary) {
    "boundary_or_singular_covariance"
  } else {
    "identified_point_fit"
  }
  data.frame(
    FitStatus = status, OptimizerCode = convergence,
    OptimizerMessage = paste(as.character(fit$fit$message), collapse = " | "),
    PositiveDefiniteHessian = pd_hessian,
    MaximumAbsoluteGradient = maximum_gradient,
    BoundaryComponentCount = sum(covariance_audit$BoundaryOrRankDeficient),
    BackendDependencyVersionMatch = isTRUE(abi$VersionMatch),
    BuildTMBVersion = abi$BuildTMBVersion,
    RuntimeTMBVersion = abi$RuntimeTMBVersion,
    WarningCount = length(warnings), MessageCount = length(messages),
    Warnings = paste(warnings, collapse = " | "),
    Messages = paste(messages, collapse = " | "), stringsAsFactors = FALSE
  )
}

mfrmr_gtvb_finalize_fit <- function(
    spec, fit, backend, reml, warnings, messages,
    matrix_tolerance, boundary_tolerance, correlation_tolerance,
    singular_tolerance = NA_real_, abi = NULL) {
  covariance <- mfrmr_gtvb_extract_covariances(
    fit, spec, backend, matrix_tolerance
  )
  component_audit <- mfrmr_gtvb_covariance_audit(
    covariance, spec$ComponentMap, matrix_tolerance,
    boundary_tolerance, correlation_tolerance
  )
  raw_fixed <- if (identical(backend, "lme4")) {
    lme4::fixef(fit)
  } else {
    glmmTMB::fixef(fit)$cond
  }
  fixed <- stats::setNames(as.numeric(raw_fixed), names(raw_fixed))
  if (length(fixed) != length(spec$Strata) || any(!is.finite(fixed)) ||
      is.null(names(fixed)) || anyDuplicated(names(fixed)) ||
      !setequal(names(fixed), spec$FixedDesignColumns)) {
    stop("Backend fixed stratum means are malformed.", call. = FALSE)
  }
  fixed <- fixed[match(spec$FixedDesignColumns, names(fixed))]
  names(fixed) <- spec$Strata
  rows_match <- mfrmr_gtvb_backend_rows_match(fit, spec)
  diagnostics <- if (identical(backend, "lme4")) {
    mfrmr_gtvb_lme4_diagnostics(
      fit, warnings, messages, component_audit, singular_tolerance
    )
  } else {
    mfrmr_gtvb_glmmtmb_diagnostics(
      fit, warnings, messages, component_audit, abi
    )
  }
  likelihood <- stats::logLik(fit)
  method <- if (isTRUE(reml)) "REML" else "ML"
  expected_covariance_parameters <-
    sum(spec$ComponentMap$ComponentId != "Residual") *
      length(spec$Strata) * (length(spec$Strata) + 1) / 2 + 1L
  raw_parameters <- if (identical(backend, "lme4")) {
    c(lme4::getME(fit, "theta"), lme4::fixef(fit), sigma = stats::sigma(fit))
  } else {
    stats::setNames(as.numeric(fit$fit$par), names(fit$fit$par))
  }
  identity <- list(
    Backend = backend,
    BackendVersion = as.character(utils::packageVersion(backend)),
    Method = method,
    FormulaCanonical = spec$FormulaCanonical,
    Response = "Gaussian_identity_observed_score",
    FixedEffects = "stratum_specific_means_no_intercept",
    RandomEffects = "global_component_unstructured_stratum_covariances",
    Residual = spec$ResidualContract,
    ZeroInflation = if (identical(backend, "glmmTMB")) "~0" else "absent",
    Dispersion = if (identical(backend, "glmmTMB")) "~1" else "sigma2_I",
    ExpectedCovarianceParameterCount = expected_covariance_parameters,
    RowBindingHash = spec$RowBindingHash,
    BackendRowIdHash = spec$BackendRowIdHash,
    BackendResponseHash = spec$BackendResponseHash,
    BackendDataHash = spec$BackendDataHash,
    FixedDesignHash = spec$FixedDesignHash,
    RandomDesignBlockHashes = spec$RandomDesignBlockHashes,
    BackendFunctionHashes = if (identical(backend, "lme4")) c(
      lmer = mfrmr_gtvb_function_hash(lme4::lmer),
      VarCorr = mfrmr_gtvb_function_hash(
        getFromNamespace("VarCorr.merMod", "lme4")
      ),
      isSingular = mfrmr_gtvb_function_hash(lme4::isSingular)
    ) else c(
      glmmTMB = mfrmr_gtvb_function_hash(glmmTMB::glmmTMB),
      VarCorr = mfrmr_gtvb_function_hash(
        getFromNamespace("VarCorr.glmmTMB", "glmmTMB")
      )
    )
  )
  if (!is.null(abi)) identity$DependencyABI <- abi
  semantic_model_identity <- list(
    Method = identity$Method,
    FormulaCanonical = identity$FormulaCanonical,
    Response = identity$Response,
    FixedEffects = identity$FixedEffects,
    RandomEffects = identity$RandomEffects,
    Residual = identity$Residual,
    ExpectedCovarianceParameterCount =
      identity$ExpectedCovarianceParameterCount,
    RowBindingHash = identity$RowBindingHash,
    BackendDataHash = identity$BackendDataHash,
    FixedDesignHash = identity$FixedDesignHash,
    RandomDesignBlockHashes = identity$RandomDesignBlockHashes
  )
  identity$SemanticModelHash <- mfrmr_gta_hash(semantic_model_identity)
  fit_qualification <- if (!rows_match) {
    "backend_row_binding_mismatch"
  } else if (!identical(diagnostics$FitStatus, "identified_point_fit")) {
    paste0(backend, "_", diagnostics$FitStatus)
  } else {
    "point_estimation_gate_passed"
  }
  payload <- list(
    Contract = "gtheory_multivariate_backend_fit_draft85b1_v1",
    SpecificationHash = spec$SpecificationHash,
    IncidenceAuditHash = spec$IncidenceAuditHash,
    RetainedDataHash = spec$RetainedDataHash,
    RowBindingHash = spec$RowBindingHash,
    BackendRowIdHash = spec$BackendRowIdHash,
    BackendResponseHash = spec$BackendResponseHash,
    BackendDataHash = spec$BackendDataHash,
    ComponentPairAuditHash = spec$ComponentPairAuditHash,
    EstimatorIdentity = identity,
    FixedEffectsByStratum = fixed,
    ComponentCovariances = covariance,
    ComponentMatrixAudit = component_audit,
    RawBackendParameters = raw_parameters,
    LikelihoodIdentity = list(
      Value = as.numeric(likelihood),
      DegreesFreedom = as.integer(attr(likelihood, "df")),
      Observations = as.integer(stats::nobs(fit)), Criterion = method,
      ConstantContract = "backend_reported_full_Gaussian_logLik"
    ),
    FitDiagnostics = diagnostics,
    BackendRowsMatch = rows_match,
    FitQualification = fit_qualification
  )
  structure(c(payload, list(
    ResultHash = mfrmr_gta_hash(payload),
    ResultPayloadFields = names(payload),
    Spec = spec,
    PointEstimateAvailable = TRUE,
    PointEstimationGatePassed = identical(
      fit_qualification, "point_estimation_gate_passed"
    ),
    EstimationReady = FALSE, RecoveryReady = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE, PublicSupportReady = FALSE
  )), class = c(paste0("mfrmr_gtvb_", backend, "_fit"),
                "mfrmr_gtvb_fit", "list"))
}

mfrmr_gtvb_assert_fit_integrity <- function(fit) {
  payload_fields <- mfrmr_gtvb_fit_payload_fields()
  suffix_fields <- c(
    "ResultHash", "ResultPayloadFields", "Spec",
    "PointEstimateAvailable", "PointEstimationGatePassed",
    "EstimationReady", "RecoveryReady", "InferenceReady",
    "CoefficientEligible", "DecisionReady", "PublicSupportReady"
  )
  backend <- fit$EstimatorIdentity$Backend
  expected_class <- if (is.character(backend) && length(backend) == 1L &&
                        backend %in% c("lme4", "glmmTMB")) {
    c(paste0("mfrmr_gtvb_", backend, "_fit"), "mfrmr_gtvb_fit", "list")
  } else character()
  if (length(expected_class) == 0L || !mfrmr_gtvb_exact_object(
    fit, c(payload_fields, suffix_fields), expected_class
  ) || !identical(fit$ResultPayloadFields, payload_fields) ||
      !identical(mfrmr_gta_hash(fit[payload_fields]), fit$ResultHash)) {
    stop("The Draft.85b1 backend-fit identity was altered.", call. = FALSE)
  }
  mfrmr_gtvb_assert_fit_spec(fit$Spec)
  expected_component_order <- fit$Spec$ComponentMap$ComponentId
  expected_qualification <- if (!isTRUE(fit$BackendRowsMatch)) {
    "backend_row_binding_mismatch"
  } else if (!identical(
    fit$FitDiagnostics$FitStatus, "identified_point_fit"
  )) {
    paste0(backend, "_", fit$FitDiagnostics$FitStatus)
  } else {
    "point_estimation_gate_passed"
  }
  expected_gate <- identical(
    expected_qualification, "point_estimation_gate_passed"
  )
  valid <-
    identical(fit$SpecificationHash, fit$Spec$SpecificationHash) &&
    identical(names(fit$ComponentCovariances), expected_component_order) &&
    identical(names(fit$FixedEffectsByStratum), fit$Spec$Strata) &&
    all(is.finite(fit$FixedEffectsByStratum)) &&
    identical(fit$FitQualification, expected_qualification) &&
    identical(fit$PointEstimationGatePassed, expected_gate) &&
    identical(
      fit$LikelihoodIdentity$Criterion, fit$EstimatorIdentity$Method
    ) &&
    identical(
      fit$LikelihoodIdentity$Observations,
      as.integer(nrow(fit$Spec$BackendData))
    ) &&
    identical(fit$PointEstimateAvailable, TRUE) &&
    identical(fit$EstimationReady, FALSE) &&
    identical(fit$RecoveryReady, FALSE) &&
    identical(fit$InferenceReady, FALSE) &&
    identical(fit$CoefficientEligible, FALSE) &&
    identical(fit$DecisionReady, FALSE) &&
    identical(fit$PublicSupportReady, FALSE)
  if (!valid) {
    stop("The Draft.85b1 backend-fit contract is internally inconsistent.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvb_fit_lme4 <- function(
    spec, reml = TRUE, matrix_tolerance = 1e-10,
    boundary_tolerance = 1e-8, correlation_tolerance = 1e-6,
    singular_tolerance = 1e-4) {
  mfrmr_gtvb_assert_fit_spec(spec)
  if (!requireNamespace("lme4", quietly = TRUE)) {
    stop("Draft.85b1 requires the suggested `lme4` package.", call. = FALSE)
  }
  matrix_tolerance <- mfrmr_gtvb_tolerance(
    matrix_tolerance, "`matrix_tolerance`", positive = TRUE
  )
  boundary_tolerance <- mfrmr_gtvb_tolerance(
    boundary_tolerance, "`boundary_tolerance`"
  )
  correlation_tolerance <- mfrmr_gtvb_tolerance(
    correlation_tolerance, "`correlation_tolerance`", positive = TRUE
  )
  singular_tolerance <- mfrmr_gtvb_tolerance(
    singular_tolerance, "`singular_tolerance`", positive = TRUE
  )
  warnings <- character(); messages <- character()
  fit_formula <- mfrmr_gtvb_formula(spec$ComponentMap)
  fit <- tryCatch(withCallingHandlers(
    lme4::lmer(
      fit_formula, data = spec$BackendData, REML = isTRUE(reml),
      control = lme4::lmerControl(), na.action = stats::na.fail
    ),
    warning = function(warning) {
      warnings <<- c(warnings, conditionMessage(warning))
      invokeRestart("muffleWarning")
    },
    message = function(message) {
      messages <<- c(messages, conditionMessage(message))
      invokeRestart("muffleMessage")
    }
  ), error = function(error) error)
  if (inherits(fit, "error")) {
    stop("lme4::lmer failed: ", conditionMessage(fit), call. = FALSE)
  }
  mfrmr_gtvb_finalize_fit(
    spec, fit, "lme4", reml, warnings, messages, matrix_tolerance,
    boundary_tolerance, correlation_tolerance, singular_tolerance
  )
}

mfrmr_gtvb_compare <- function(
    lme4_fit, glmmtmb_fit, absolute_tolerance = 1e-4,
    relative_tolerance = 1e-4, loglik_tolerance = 1e-5,
    fixed_tolerance = 1e-4) {
  if (!inherits(lme4_fit, "mfrmr_gtvb_lme4_fit")) {
    stop("`lme4_fit` must be a Draft.85b1 lme4 fit.", call. = FALSE)
  }
  if (!inherits(glmmtmb_fit, "mfrmr_gtvb_glmmTMB_fit")) {
    stop("`glmmtmb_fit` must be a Draft.85b1 glmmTMB fit.", call. = FALSE)
  }
  tolerances <- c(
    Absolute = mfrmr_gtvb_tolerance(
      absolute_tolerance, "`absolute_tolerance`"
    ),
    Relative = mfrmr_gtvb_tolerance(
      relative_tolerance, "`relative_tolerance`"
    ),
    LogLik = mfrmr_gtvb_tolerance(
      loglik_tolerance, "`loglik_tolerance`"
    ),
    Fixed = mfrmr_gtvb_tolerance(
      fixed_tolerance, "`fixed_tolerance`"
    )
  )
  identity_fields <- c(
    "SpecificationHash", "IncidenceAuditHash", "RetainedDataHash",
    "RowBindingHash", "BackendRowIdHash", "BackendResponseHash",
    "BackendDataHash", "ComponentPairAuditHash"
  )
  identity_match <- vapply(identity_fields, function(field) {
    identical(lme4_fit[[field]], glmmtmb_fit[[field]])
  }, logical(1L))
  if (!all(identity_match)) {
    stop("Backend fits do not share the exact specification, incidence, row, ",
         "and component-pair identity.", call. = FALSE)
  }
  if (!identical(
    lme4_fit$EstimatorIdentity$SemanticModelHash,
    glmmtmb_fit$EstimatorIdentity$SemanticModelHash
  )) {
    stop("Backend fits do not share the matched Gaussian semantic model.",
         call. = FALSE)
  }
  mfrmr_gtvb_assert_fit_integrity(lme4_fit)
  mfrmr_gtvb_assert_fit_integrity(glmmtmb_fit)
  component_ids <- names(lme4_fit$ComponentCovariances)
  if (!identical(component_ids, names(glmmtmb_fit$ComponentCovariances))) {
    stop("Backend component covariance identities do not match.",
         call. = FALSE)
  }
  covariance_rows <- list(); cursor <- 0L
  for (component_id in component_ids) {
    left <- lme4_fit$ComponentCovariances[[component_id]]
    right <- glmmtmb_fit$ComponentCovariances[[component_id]]
    if (!identical(dimnames(left), dimnames(right))) {
      stop("Backend covariance stratum order does not match.", call. = FALSE)
    }
    positions <- which(lower.tri(left, diag = TRUE), arr.ind = TRUE)
    for (row in seq_len(nrow(positions))) {
      i <- positions[row, 1L]; j <- positions[row, 2L]
      lme4_value <- left[i, j]; glmmtmb_value <- right[i, j]
      difference <- abs(lme4_value - glmmtmb_value)
      scale <- max(abs(lme4_value), abs(glmmtmb_value),
                   .Machine$double.eps)
      cursor <- cursor + 1L
      covariance_rows[[cursor]] <- data.frame(
        ComponentId = component_id,
        LeftStratum = rownames(left)[[i]],
        RightStratum = colnames(left)[[j]],
        Lme4Estimate = lme4_value, GlmmTMBEstimate = glmmtmb_value,
        AbsoluteDifference = difference, RelativeDifference = difference / scale,
        WithinTolerance = difference <= tolerances[["Absolute"]] +
          tolerances[["Relative"]] * scale,
        stringsAsFactors = FALSE
      )
    }
  }
  covariance_comparison <- do.call(rbind, covariance_rows)
  fixed_difference <- abs(
    lme4_fit$FixedEffectsByStratum - glmmtmb_fit$FixedEffectsByStratum
  )
  fixed_comparison <- data.frame(
    Stratum = names(lme4_fit$FixedEffectsByStratum),
    Lme4Estimate = as.numeric(lme4_fit$FixedEffectsByStratum),
    GlmmTMBEstimate = as.numeric(glmmtmb_fit$FixedEffectsByStratum),
    AbsoluteDifference = as.numeric(fixed_difference),
    WithinTolerance = as.numeric(fixed_difference) <= tolerances[["Fixed"]],
    stringsAsFactors = FALSE
  )
  lme4_likelihood <- lme4_fit$LikelihoodIdentity
  glmmtmb_likelihood <- glmmtmb_fit$LikelihoodIdentity
  likelihood_difference <- abs(
    lme4_likelihood$Value - glmmtmb_likelihood$Value
  )
  likelihood_comparison <- data.frame(
    Criterion = lme4_likelihood$Criterion,
    Lme4LogLik = lme4_likelihood$Value,
    GlmmTMBLogLik = glmmtmb_likelihood$Value,
    AbsoluteDifference = likelihood_difference,
    DegreesFreedomMatch = identical(
      lme4_likelihood$DegreesFreedom, glmmtmb_likelihood$DegreesFreedom
    ),
    ObservationsMatch = identical(
      lme4_likelihood$Observations, glmmtmb_likelihood$Observations
    ),
    WithinTolerance = likelihood_difference <= tolerances[["LogLik"]] &&
      identical(lme4_likelihood$DegreesFreedom,
                glmmtmb_likelihood$DegreesFreedom) &&
      identical(lme4_likelihood$Observations,
                glmmtmb_likelihood$Observations),
    stringsAsFactors = FALSE
  )
  numerical_parity <- all(covariance_comparison$WithinTolerance) &&
    all(fixed_comparison$WithinTolerance) &&
    isTRUE(likelihood_comparison$WithinTolerance)
  both_point_gates <- isTRUE(lme4_fit$PointEstimationGatePassed) &&
    isTRUE(glmmtmb_fit$PointEstimationGatePassed)
  payload <- list(
    Contract = "gtheory_multivariate_matched_parity_draft85b1_v1",
    SpecificationHash = lme4_fit$SpecificationHash,
    IncidenceAuditHash = lme4_fit$IncidenceAuditHash,
    RetainedDataHash = lme4_fit$RetainedDataHash,
    RowBindingHash = lme4_fit$RowBindingHash,
    ComponentPairAuditHash = lme4_fit$ComponentPairAuditHash,
    SemanticModelHash = lme4_fit$EstimatorIdentity$SemanticModelHash,
    Method = lme4_fit$EstimatorIdentity$Method,
    Lme4FitHash = lme4_fit$ResultHash,
    GlmmTMBFitHash = glmmtmb_fit$ResultHash,
    Tolerances = tolerances,
    CovarianceComparison = covariance_comparison,
    FixedEffectComparison = fixed_comparison,
    LikelihoodComparison = likelihood_comparison,
    NumericalParityPassed = numerical_parity,
    BothPointEstimationGatesPassed = both_point_gates,
    BackendDependencyIdentityPassed = isTRUE(
      glmmtmb_fit$FitDiagnostics$BackendDependencyVersionMatch
    ),
    MatchedBackendPointReady = numerical_parity && both_point_gates
  )
  structure(c(payload, list(
    ResultHash = mfrmr_gta_hash(payload),
    EstimationReady = FALSE, RecoveryReady = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE, PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvb_parity", "list"))
}

mfrmr_gtvb_fit_glmmtmb <- function(
    spec, reml = TRUE, matrix_tolerance = 1e-10,
    boundary_tolerance = 1e-8, correlation_tolerance = 1e-6,
    allow_dependency_mismatch_diagnostic = FALSE) {
  mfrmr_gtvb_assert_fit_spec(spec)
  if (!suppressWarnings(requireNamespace("glmmTMB", quietly = TRUE)) ||
      !requireNamespace("TMB", quietly = TRUE)) {
    stop("Draft.85b1 requires the suggested `glmmTMB` and `TMB` packages.",
         call. = FALSE)
  }
  matrix_tolerance <- mfrmr_gtvb_tolerance(
    matrix_tolerance, "`matrix_tolerance`", positive = TRUE
  )
  boundary_tolerance <- mfrmr_gtvb_tolerance(
    boundary_tolerance, "`boundary_tolerance`"
  )
  correlation_tolerance <- mfrmr_gtvb_tolerance(
    correlation_tolerance, "`correlation_tolerance`", positive = TRUE
  )
  if (length(allow_dependency_mismatch_diagnostic) != 1L ||
      is.na(allow_dependency_mismatch_diagnostic) ||
      !is.logical(allow_dependency_mismatch_diagnostic)) {
    stop("`allow_dependency_mismatch_diagnostic` must be TRUE or FALSE.",
         call. = FALSE)
  }
  abi <- mfrmr_gtvb_glmmtmb_abi()
  abi$DiagnosticOverride <- isTRUE(allow_dependency_mismatch_diagnostic)
  if (!isTRUE(abi$VersionMatch) && !isTRUE(abi$DiagnosticOverride)) {
    stop(
      "glmmTMB/TMB build-runtime dependency mismatch; point fitting is ",
      "blocked. Set `allow_dependency_mismatch_diagnostic = TRUE` only for ",
      "an explicitly non-ready diagnostic comparison.", call. = FALSE
    )
  }
  warnings <- character(); messages <- character()
  fit_formula <- mfrmr_gtvb_formula(spec$ComponentMap)
  fit <- tryCatch(withCallingHandlers(
    glmmTMB::glmmTMB(
      formula = fit_formula, data = spec$BackendData,
      family = stats::gaussian(link = "identity"),
      ziformula = ~ 0, dispformula = ~ 1, REML = isTRUE(reml),
      control = glmmTMB::glmmTMBControl(), na.action = stats::na.fail
    ),
    warning = function(warning) {
      warnings <<- c(warnings, conditionMessage(warning))
      invokeRestart("muffleWarning")
    },
    message = function(message) {
      messages <<- c(messages, conditionMessage(message))
      invokeRestart("muffleMessage")
    }
  ), error = function(error) error)
  if (inherits(fit, "error")) {
    stop("glmmTMB::glmmTMB failed: ", conditionMessage(fit), call. = FALSE)
  }
  mfrmr_gtvb_finalize_fit(
    spec, fit, "glmmTMB", reml, warnings, messages, matrix_tolerance,
    boundary_tolerance, correlation_tolerance, abi = abi
  )
}
