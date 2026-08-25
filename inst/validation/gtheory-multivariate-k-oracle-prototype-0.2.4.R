# Draft.85c0 independent multivariate G-theory K-matrix oracle.
#
# Repository-internal only. The statistical core consumes neutral integer
# codes and never calls the Draft.85b1 parser, lme4, or glmmTMB.

mfrmr_gtvc_require_primitives <- function() {
  if (!exists("mfrmr_gta_hash", mode = "function", inherits = TRUE)) {
    stop("Source the Draft.81 hash primitive before Draft.85c0.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvc_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    setequal(names(attributes(object)), c("names", "class"))
}

mfrmr_gtvc_exact_matrix <- function(matrix) {
  is.matrix(matrix) &&
    setequal(names(attributes(matrix)), c("dim", "dimnames"))
}

mfrmr_gtvc_design_fields <- function() {
  c(
    "Contract", "RowId", "Strata", "StratumCode", "ComponentIds",
    "ComponentGroupCode", "RowCount", "FixedDesignHash", "GroupCodeHash",
    "FixedDesign", "Response", "ResponseNames", "ResponseHash",
    "TruthFieldsPresent", "StructuralDesignHash", "NeutralDesignHash",
    "OracleSpecificationReady", "NeutralPayloadSchemaReady",
    "RecoveryDesignFrozen", "EstimationReady", "InferenceReady",
    "CoefficientEligible", "DecisionReady", "PublicSupportReady"
  )
}

mfrmr_gtvc_bridge_extension_fields <- function() {
  c(
    "Bridge", "BridgeHash", "KDerivative", "OracleIndependence",
    "B1BridgeReady", "OracleIndependenceReady", "RecoveryEvidenceReady"
  )
}

mfrmr_gtvc_tolerance <- function(value, argument, positive = FALSE) {
  value <- suppressWarnings(as.numeric(value))
  valid <- length(value) == 1L && !is.na(value) && is.finite(value) &&
    if (isTRUE(positive)) value > 0 else value >= 0
  if (!valid) {
    stop(argument, " must be one finite ",
         if (isTRUE(positive)) "positive" else "nonnegative",
         " number.", call. = FALSE)
  }
  value
}

mfrmr_gtvc_codes <- function(value, argument, n) {
  if (!(is.numeric(value) || is.integer(value)) || length(value) != n ||
      anyNA(value) || any(!is.finite(value)) ||
      any(value != floor(value)) || any(value < 1)) {
    stop(argument, " must contain one positive integer code per row.",
         call. = FALSE)
  }
  as.integer(value)
}

mfrmr_gtvc_neutral_design <- function(
    row_id, strata, stratum_code, component_group_code,
    fixed_design, response) {
  mfrmr_gtvc_require_primitives()
  row_id <- unname(as.character(row_id))
  strata <- unname(as.character(strata))
  n <- length(row_id)
  if (n == 0L || anyNA(row_id) || any(!nzchar(row_id)) ||
      anyDuplicated(row_id)) {
    stop("`row_id` must be a nonempty unique row identity.", call. = FALSE)
  }
  if (length(strata) < 2L || anyNA(strata) || any(!nzchar(strata)) ||
      anyDuplicated(strata)) {
    stop("`strata` must be an ordered set of at least two labels.",
         call. = FALSE)
  }
  stratum_code <- mfrmr_gtvc_codes(stratum_code, "`stratum_code`", n)
  if (any(stratum_code > length(strata)) ||
      !identical(sort(unique(stratum_code)), seq_along(strata))) {
    stop("Every declared stratum must have a valid observed integer code.",
         call. = FALSE)
  }
  component_group_code <- as.matrix(component_group_code)
  component_ids <- colnames(component_group_code)
  if (ncol(component_group_code) == 0L || nrow(component_group_code) != n ||
      is.null(component_ids) || anyNA(component_ids) ||
      any(!nzchar(component_ids)) || anyDuplicated(component_ids) ||
      "Residual" %in% component_ids) {
    stop("`component_group_code` needs named non-residual component columns.",
         call. = FALSE)
  }
  normalized_groups <- matrix(
    0L, nrow = n, ncol = ncol(component_group_code),
    dimnames = list(row_id, component_ids)
  )
  for (column in seq_along(component_ids)) {
    normalized_groups[, column] <- mfrmr_gtvc_codes(
      component_group_code[, column],
      paste0("`component_group_code[, ", column, "]`"), n
    )
  }
  if (!identical(rownames(component_group_code), row_id)) {
    stop("Component group-code rows must match `row_id` exactly.",
         call. = FALSE)
  }
  fixed_design <- as.matrix(fixed_design)
  expected_fixed_names <- paste0("Stratum/", strata)
  if (!is.numeric(fixed_design) ||
      !identical(dim(fixed_design), c(n, length(strata))) ||
      !identical(rownames(fixed_design), row_id) ||
      !identical(colnames(fixed_design), expected_fixed_names) ||
      any(!is.finite(fixed_design))) {
    stop("`fixed_design` must be the exact named neutral stratum design.",
         call. = FALSE)
  }
  expected_fixed <- matrix(
    0, nrow = n, ncol = length(strata),
    dimnames = list(row_id, expected_fixed_names)
  )
  expected_fixed[cbind(seq_len(n), stratum_code)] <- 1
  if (!identical(unname(fixed_design), unname(expected_fixed))) {
    stop("`fixed_design` must be one-hot for the declared stratum codes.",
         call. = FALSE)
  }
  if (!is.numeric(response) || length(response) != n ||
      anyNA(response) || any(!is.finite(response)) ||
      !identical(names(response), row_id)) {
    stop("`response` must be finite and bound to every exact `row_id`.",
         call. = FALSE)
  }
  structural_payload <- list(
    Contract = "gtheory_multivariate_neutral_design_draft85c0_v1",
    RowId = row_id, Strata = strata, StratumCode = stratum_code,
    ComponentIds = component_ids,
    ComponentGroupCode = normalized_groups,
    RowCount = n,
    FixedDesignHash = mfrmr_gta_hash(fixed_design),
    GroupCodeHash = mfrmr_gta_hash(normalized_groups)
  )
  payload <- c(structural_payload, list(
    FixedDesign = fixed_design, Response = as.numeric(response),
    ResponseNames = names(response),
    ResponseHash = mfrmr_gta_hash(stats::setNames(response, row_id)),
    TruthFieldsPresent = FALSE
  ))
  structure(c(payload, list(
    StructuralDesignHash = mfrmr_gta_hash(structural_payload),
    NeutralDesignHash = mfrmr_gta_hash(payload),
    OracleSpecificationReady = TRUE,
    NeutralPayloadSchemaReady = TRUE,
    RecoveryDesignFrozen = FALSE,
    EstimationReady = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvc_design", "list"))
}

mfrmr_gtvc_assert_design <- function(design) {
  base_fields <- mfrmr_gtvc_design_fields()
  base_class <- c("mfrmr_gtvc_design", "list")
  bridge_class <- c("mfrmr_gtvc_bridge", "mfrmr_gtvc_design", "list")
  exact_base <- mfrmr_gtvc_exact_object(design, base_fields, base_class)
  exact_bridge <- mfrmr_gtvc_exact_object(
    design, c(base_fields, mfrmr_gtvc_bridge_extension_fields()), bridge_class
  )
  if ((!exact_base && !exact_bridge) ||
      !identical(design$OracleSpecificationReady, TRUE) ||
      !identical(design$NeutralPayloadSchemaReady, TRUE)) {
    stop("`design` must be a ready Draft.85c0 neutral design.",
         call. = FALSE)
  }
  structural_payload <- list(
    Contract = design$Contract, RowId = design$RowId,
    Strata = design$Strata, StratumCode = design$StratumCode,
    ComponentIds = design$ComponentIds,
    ComponentGroupCode = design$ComponentGroupCode,
    RowCount = design$RowCount,
    FixedDesignHash = design$FixedDesignHash,
    GroupCodeHash = design$GroupCodeHash
  )
  payload <- c(structural_payload, list(
    FixedDesign = design$FixedDesign, Response = design$Response,
    ResponseNames = design$ResponseNames,
    ResponseHash = design$ResponseHash,
    TruthFieldsPresent = design$TruthFieldsPresent
  ))
  integrity <-
    identical(mfrmr_gta_hash(structural_payload),
              design$StructuralDesignHash) &&
    identical(mfrmr_gta_hash(payload), design$NeutralDesignHash) &&
    identical(mfrmr_gta_hash(design$FixedDesign),
              design$FixedDesignHash) &&
    identical(mfrmr_gta_hash(design$ComponentGroupCode),
              design$GroupCodeHash) &&
    identical(
      mfrmr_gta_hash(stats::setNames(
        design$Response, design$ResponseNames
      )),
      design$ResponseHash
    ) && identical(design$TruthFieldsPresent, FALSE) &&
    mfrmr_gtvc_exact_matrix(design$FixedDesign) &&
    mfrmr_gtvc_exact_matrix(design$ComponentGroupCode) &&
    is.null(attributes(design$RowId)) &&
    is.null(attributes(design$Strata)) &&
    is.null(attributes(design$StratumCode)) &&
    is.null(attributes(design$ComponentIds)) &&
    is.null(attributes(design$Response)) &&
    is.null(attributes(design$ResponseNames)) &&
    identical(design$RecoveryDesignFrozen, FALSE) &&
    identical(design$EstimationReady, FALSE) &&
    identical(design$InferenceReady, FALSE) &&
    identical(design$CoefficientEligible, FALSE) &&
    identical(design$DecisionReady, FALSE) &&
    identical(design$PublicSupportReady, FALSE)
  if (exact_bridge) {
    bridge_fields <- c(
      "Contract", "SourceSpecificationHash", "SourceIncidenceAuditHash",
      "SourceRowBindingHash", "SourceBackendRowIdHash",
      "SourceBackendResponseHash", "SourceBackendDataHash",
      "SourceFixedDesignHash", "SourceRandomDesignBlockHashes",
      "SourceCovarianceDesignHash", "NeutralDesignHash",
      "StructuralDesignHash", "NeutralKDerivativeHash",
      "SourceDesignHashesMatch", "KDesignBindingPassed",
      "OracleIndependenceAuditHash"
    )
    independence_fields <- c(
      "Contract", "FunctionAudit", "OracleIndependenceReady", "AuditHash",
      "RecoveryEvidenceReady", "EstimationReady", "InferenceReady",
      "CoefficientEligible", "DecisionReady", "PublicSupportReady"
    )
    function_audit_fields <- c(
      "Function", "ForbiddenDependencyCount", "ForbiddenDependencies",
      "FunctionHash"
    )
    bridge_schema <- is.list(design$Bridge) &&
      identical(names(design$Bridge), bridge_fields) &&
      identical(names(attributes(design$Bridge)), "names")
    independence_schema <- mfrmr_gtvc_exact_object(
      design$OracleIndependence, independence_fields,
      c("mfrmr_gtvc_independence", "list")
    ) && is.data.frame(design$OracleIndependence$FunctionAudit) &&
      identical(
        names(design$OracleIndependence$FunctionAudit), function_audit_fields
      ) && setequal(
        names(attributes(design$OracleIndependence$FunctionAudit)),
        c("names", "row.names", "class")
      )
    bridge_integrity <- bridge_schema && independence_schema &&
      identical(mfrmr_gta_hash(design$Bridge), design$BridgeHash) &&
      identical(design$Bridge$NeutralDesignHash, design$NeutralDesignHash) &&
      identical(
        design$Bridge$StructuralDesignHash, design$StructuralDesignHash
      ) && identical(
        design$Bridge$NeutralKDerivativeHash, design$KDerivative$ResultHash
      ) && identical(
        design$Bridge$OracleIndependenceAuditHash,
        design$OracleIndependence$AuditHash
      ) && identical(
        mfrmr_gta_hash(design$OracleIndependence$FunctionAudit),
        design$OracleIndependence$AuditHash
      ) && identical(design$B1BridgeReady, TRUE) &&
      identical(design$OracleIndependenceReady, TRUE) &&
      identical(design$OracleIndependence$OracleIndependenceReady, TRUE) &&
      identical(design$RecoveryEvidenceReady, FALSE) &&
      identical(design$OracleIndependence$RecoveryEvidenceReady, FALSE) &&
      identical(design$OracleIndependence$EstimationReady, FALSE) &&
      identical(design$OracleIndependence$InferenceReady, FALSE) &&
      identical(design$OracleIndependence$CoefficientEligible, FALSE) &&
      identical(design$OracleIndependence$DecisionReady, FALSE) &&
      identical(design$OracleIndependence$PublicSupportReady, FALSE)
    integrity <- integrity && bridge_integrity
  }
  if (!integrity) {
    stop("The neutral design identity or exact payload schema was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvc_matrix_audit <- function(
    matrix, strata, matrix_id, tolerance, boundary_tolerance) {
  matrix <- as.matrix(matrix)
  if (!is.numeric(matrix) ||
      !identical(dim(matrix), c(length(strata), length(strata))) ||
      !identical(rownames(matrix), strata) ||
      !identical(colnames(matrix), strata) || any(!is.finite(matrix))) {
    stop("Covariance `", matrix_id,
         "` must preserve exact finite stratum dimensions and names.",
         call. = FALSE)
  }
  asymmetry <- max(abs(matrix - t(matrix)))
  if (asymmetry > tolerance) {
    stop("Covariance `", matrix_id, "` is asymmetric.", call. = FALSE)
  }
  matrix <- (matrix + t(matrix)) / 2
  eigenvalues <- eigen(matrix, symmetric = TRUE, only.values = TRUE)$values
  if (min(eigenvalues) < -tolerance) {
    stop("Covariance `", matrix_id,
         "` is indefinite; PSD repair is prohibited.", call. = FALSE)
  }
  scale <- max(1, max(eigenvalues))
  effective_rank <- sum(eigenvalues > tolerance * scale)
  rank_deficient <- effective_rank < length(strata)
  list(
    Matrix = matrix,
    Audit = data.frame(
      ComponentId = matrix_id, MinimumEigenvalue = min(eigenvalues),
      MaximumEigenvalue = max(eigenvalues),
      EffectiveRank = effective_rank,
      RankDeficient = rank_deficient,
      Boundary = rank_deficient || min(eigenvalues) <= boundary_tolerance,
      MaximumAsymmetry = asymmetry,
      MatrixHash = mfrmr_gta_hash(matrix), stringsAsFactors = FALSE
    )
  )
}

mfrmr_gtvc_covariance_spec <- function(
    design, component_covariances, residual_variance,
    tolerance = 1e-10, boundary_tolerance = 1e-8) {
  mfrmr_gtvc_assert_design(design)
  tolerance <- mfrmr_gtvc_tolerance(
    tolerance, "`tolerance`", positive = TRUE
  )
  boundary_tolerance <- mfrmr_gtvc_tolerance(
    boundary_tolerance, "`boundary_tolerance`"
  )
  if (!is.list(component_covariances) ||
      !identical(names(component_covariances), design$ComponentIds)) {
    stop("Component covariance names and order must match the neutral design ",
         "exactly; automatic truth/estimate reordering is prohibited.",
         call. = FALSE)
  }
  residual_variance <- suppressWarnings(as.numeric(residual_variance))
  if (length(residual_variance) != 1L || is.na(residual_variance) ||
      !is.finite(residual_variance) || residual_variance <= 0) {
    stop("`residual_variance` must be one finite positive value.",
         call. = FALSE)
  }
  normalized <- vector("list", length(design$ComponentIds))
  names(normalized) <- design$ComponentIds
  audits <- vector("list", length(normalized))
  for (index in seq_along(normalized)) {
    audit <- mfrmr_gtvc_matrix_audit(
      component_covariances[[index]], design$Strata,
      design$ComponentIds[[index]], tolerance, boundary_tolerance
    )
    normalized[[index]] <- audit$Matrix
    audits[[index]] <- audit$Audit
  }
  component_audit <- do.call(rbind, audits)
  payload <- list(
    Contract = "gtheory_multivariate_covariance_point_draft85c0_v1",
    StructuralDesignHash = design$StructuralDesignHash,
    ComponentCovariances = normalized,
    ResidualVariance = residual_variance,
    ComponentAudit = component_audit,
    Tolerance = tolerance, BoundaryTolerance = boundary_tolerance,
    RegularInterior = !any(component_audit$Boundary) &&
      !any(component_audit$RankDeficient) &&
      residual_variance > boundary_tolerance
  )
  structure(c(payload, list(
    CovariancePointHash = mfrmr_gta_hash(payload),
    SuppliedCovarianceReady = TRUE,
    RegularInteriorReady = payload$RegularInterior,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvc_covariance", "list"))
}

mfrmr_gtvc_assert_covariance <- function(design, covariance) {
  mfrmr_gtvc_assert_design(design)
  payload_fields <- c(
    "Contract", "StructuralDesignHash", "ComponentCovariances",
    "ResidualVariance", "ComponentAudit", "Tolerance", "BoundaryTolerance",
    "RegularInterior"
  )
  suffix_fields <- c(
    "CovariancePointHash", "SuppliedCovarianceReady",
    "RegularInteriorReady", "RecoveryEvidenceReady", "EstimationReady",
    "InferenceReady", "CoefficientEligible", "DecisionReady",
    "PublicSupportReady"
  )
  exact_schema <- mfrmr_gtvc_exact_object(
    covariance, c(payload_fields, suffix_fields),
    c("mfrmr_gtvc_covariance", "list")
  )
  exact_component_list <- is.list(covariance$ComponentCovariances) &&
    identical(names(covariance$ComponentCovariances), design$ComponentIds) &&
    identical(names(attributes(covariance$ComponentCovariances)), "names") &&
    all(vapply(
      covariance$ComponentCovariances, mfrmr_gtvc_exact_matrix, logical(1L)
    ))
  audit_columns <- c(
    "ComponentId", "MinimumEigenvalue", "MaximumEigenvalue", "EffectiveRank",
    "RankDeficient", "Boundary", "MaximumAsymmetry", "MatrixHash"
  )
  exact_audit <- is.data.frame(covariance$ComponentAudit) &&
    identical(names(covariance$ComponentAudit), audit_columns) &&
    setequal(
      names(attributes(covariance$ComponentAudit)),
      c("names", "row.names", "class")
    ) && identical(
      as.character(covariance$ComponentAudit$ComponentId),
      design$ComponentIds
    )
  if (!exact_schema || !exact_component_list || !exact_audit) {
    stop("The covariance point is not bound to the neutral design.",
         call. = FALSE)
  }
  payload <- list(
    Contract = covariance$Contract,
    StructuralDesignHash = covariance$StructuralDesignHash,
    ComponentCovariances = covariance$ComponentCovariances,
    ResidualVariance = covariance$ResidualVariance,
    ComponentAudit = covariance$ComponentAudit,
    Tolerance = covariance$Tolerance,
    BoundaryTolerance = covariance$BoundaryTolerance,
    RegularInterior = covariance$RegularInterior
  )
  replay <- lapply(seq_along(design$ComponentIds), function(index) {
    mfrmr_gtvc_matrix_audit(
      covariance$ComponentCovariances[[index]], design$Strata,
      design$ComponentIds[[index]], covariance$Tolerance,
      covariance$BoundaryTolerance
    )
  })
  replay_matrices <- stats::setNames(
    lapply(replay, `[[`, "Matrix"), design$ComponentIds
  )
  replay_audit <- do.call(rbind, lapply(replay, `[[`, "Audit"))
  replay_regular <- !any(replay_audit$Boundary) &&
    !any(replay_audit$RankDeficient) &&
    covariance$ResidualVariance > covariance$BoundaryTolerance
  if (!identical(covariance$StructuralDesignHash,
                 design$StructuralDesignHash) ||
      !identical(covariance$SuppliedCovarianceReady, TRUE) ||
      !identical(mfrmr_gta_hash(payload), covariance$CovariancePointHash) ||
      !identical(replay_matrices, covariance$ComponentCovariances) ||
      !identical(replay_audit, covariance$ComponentAudit) ||
      !identical(replay_regular, covariance$RegularInterior) ||
      !identical(covariance$RegularInteriorReady,
                 covariance$RegularInterior) ||
      !identical(covariance$RecoveryEvidenceReady, FALSE) ||
      !identical(covariance$EstimationReady, FALSE) ||
      !identical(covariance$InferenceReady, FALSE) ||
      !identical(covariance$CoefficientEligible, FALSE) ||
      !identical(covariance$DecisionReady, FALSE) ||
      !identical(covariance$PublicSupportReady, FALSE)) {
    stop("The covariance point is not bound to the neutral design.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvc_build_k_pairwise <- function(design, covariance) {
  mfrmr_gtvc_assert_covariance(design, covariance)
  n <- design$RowCount
  k <- matrix(0, n, n, dimnames = list(design$RowId, design$RowId))
  for (left in seq_len(n)) {
    for (right in seq_len(left)) {
      value <- if (left == right) covariance$ResidualVariance else 0
      for (component in seq_along(design$ComponentIds)) {
        if (design$ComponentGroupCode[left, component] ==
            design$ComponentGroupCode[right, component]) {
          value <- value + covariance$ComponentCovariances[[component]][
            design$StratumCode[[left]], design$StratumCode[[right]]
          ]
        }
      }
      k[left, right] <- value
      k[right, left] <- value
    }
  }
  eigenvalues <- eigen(k, symmetric = TRUE, only.values = TRUE)$values
  structure(list(
    Contract = "gtheory_multivariate_pairwise_k_draft85c0_v1",
    StructuralDesignHash = design$StructuralDesignHash,
    NeutralDesignHash = design$NeutralDesignHash,
    CovariancePointHash = covariance$CovariancePointHash,
    K = k, KHash = mfrmr_gta_hash(k),
    MinimumEigenvalue = min(eigenvalues),
    KPositiveDefinite = min(eigenvalues) > covariance$Tolerance,
    KMatrixConstructible = TRUE,
    IndependentKOracleReady = TRUE,
    RegularInteriorReady = covariance$RegularInteriorReady,
    RecoveryEvidenceReady = FALSE, EstimationReady = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE, PublicSupportReady = FALSE
  ), class = c("mfrmr_gtvc_k", "list"))
}

mfrmr_gtvc_build_k_z <- function(design, covariance) {
  mfrmr_gtvc_assert_covariance(design, covariance)
  n <- design$RowCount
  strata_count <- length(design$Strata)
  total <- matrix(0, n, n)
  for (component in seq_along(design$ComponentIds)) {
    code <- design$ComponentGroupCode[, component]
    levels <- sort(unique(code))
    group_index <- match(code, levels)
    z <- matrix(0, nrow = n, ncol = length(levels) * strata_count)
    column <- (group_index - 1L) * strata_count + design$StratumCode
    z[cbind(seq_len(n), column)] <- 1
    block <- kronecker(
      diag(length(levels)), covariance$ComponentCovariances[[component]]
    )
    total <- total + z %*% block %*% t(z)
  }
  total <- total + diag(covariance$ResidualVariance, n)
  dimnames(total) <- list(design$RowId, design$RowId)
  total
}

mfrmr_gtvc_dual_k <- function(
    design, covariance, comparison_tolerance = 1e-12) {
  comparison_tolerance <- mfrmr_gtvc_tolerance(
    comparison_tolerance, "`comparison_tolerance`"
  )
  pairwise <- mfrmr_gtvc_build_k_pairwise(design, covariance)
  z_matrix <- mfrmr_gtvc_build_k_z(design, covariance)
  maximum_difference <- max(abs(pairwise$K - z_matrix))
  payload <- list(
    Contract = "gtheory_multivariate_dual_k_draft85c0_v1",
    StructuralDesignHash = design$StructuralDesignHash,
    CovariancePointHash = covariance$CovariancePointHash,
    PairwiseKHash = pairwise$KHash,
    ZKHash = mfrmr_gta_hash(z_matrix),
    MaximumAbsoluteDifference = maximum_difference,
    ComparisonTolerance = comparison_tolerance,
    DualConstructionPassed = maximum_difference <= comparison_tolerance
  )
  structure(c(payload, list(
    ResultHash = mfrmr_gta_hash(payload), Pairwise = pairwise,
    ZMatrix = z_matrix,
    OracleMechanicsReady = payload$DualConstructionPassed,
    RecoveryEvidenceReady = FALSE, EstimationReady = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE, PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvc_dual_k", "list"))
}

mfrmr_gtvc_coordinate_layout <- function(design) {
  mfrmr_gtvc_assert_design(design)
  rows <- list(); cursor <- 0L
  for (component in design$ComponentIds) {
    for (left in seq_along(design$Strata)) {
      for (right in seq.int(left, length(design$Strata))) {
        cursor <- cursor + 1L
        rows[[cursor]] <- data.frame(
          CoordinateId = paste0(
            component, "[", design$Strata[[left]], ",",
            design$Strata[[right]], "]"
          ),
          ComponentId = component, LeftIndex = left, RightIndex = right,
          LeftStratum = design$Strata[[left]],
          RightStratum = design$Strata[[right]],
          CoordinateType = if (left == right) "variance" else "covariance",
          stringsAsFactors = FALSE
        )
      }
    }
  }
  cursor <- cursor + 1L
  rows[[cursor]] <- data.frame(
    CoordinateId = "Residual[I]", ComponentId = "Residual",
    LeftIndex = NA_integer_, RightIndex = NA_integer_,
    LeftStratum = NA_character_, RightStratum = NA_character_,
    CoordinateType = "residual_variance", stringsAsFactors = FALSE
  )
  do.call(rbind, rows)
}

mfrmr_gtvc_derivative_design <- function(
    design, rank_tolerance = 1e-10, max_k_cells = 5e7) {
  mfrmr_gtvc_assert_design(design)
  rank_tolerance <- mfrmr_gtvc_tolerance(
    rank_tolerance, "`rank_tolerance`", positive = TRUE
  )
  max_k_cells <- suppressWarnings(as.numeric(max_k_cells))
  if (length(max_k_cells) != 1L || is.na(max_k_cells) ||
      !is.finite(max_k_cells) || max_k_cells < 1 ||
      max_k_cells != floor(max_k_cells)) {
    stop("`max_k_cells` must be one finite positive integer.", call. = FALSE)
  }
  layout <- mfrmr_gtvc_coordinate_layout(design)
  n <- design$RowCount
  parameter_count <- nrow(layout)
  vech_rows <- n * (n + 1) / 2
  matrix_cells <- vech_rows * parameter_count
  if (matrix_cells > max_k_cells) {
    payload <- list(
      Contract = "gtheory_multivariate_k_derivative_draft85c0_v1",
      StructuralDesignHash = design$StructuralDesignHash,
      CoordinateTable = layout, ParameterCount = parameter_count,
      VechRows = vech_rows, MatrixCells = matrix_cells,
      CapacityStatus = "not_evaluated_capacity",
      StructuralRank = NA_integer_, CovarianceDesignIdentified = FALSE,
      CoordinateTableHash = mfrmr_gta_hash(layout),
      RankTolerance = rank_tolerance
    )
    return(structure(c(payload, list(
      ResultHash = mfrmr_gta_hash(payload),
      ResultPayloadFields = names(payload),
      DesignMatrix = NULL, DerivativeMatrices = list(),
      CovarianceDesignOracleReady = FALSE,
      RecoveryEvidenceReady = FALSE, EstimationReady = FALSE,
      InferenceReady = FALSE, CoefficientEligible = FALSE,
      DecisionReady = FALSE, PublicSupportReady = FALSE
    )), class = c("mfrmr_gtvc_derivative", "list")))
  }
  lower <- lower.tri(matrix(0, n, n), diag = TRUE)
  design_matrix <- matrix(0, nrow = vech_rows, ncol = parameter_count)
  derivative_matrices <- vector("list", parameter_count)
  names(derivative_matrices) <- layout$CoordinateId
  for (coordinate in seq_len(parameter_count - 1L)) {
    component <- match(
      layout$ComponentId[[coordinate]], design$ComponentIds
    )
    left_stratum <- layout$LeftIndex[[coordinate]]
    right_stratum <- layout$RightIndex[[coordinate]]
    derivative <- matrix(0, n, n)
    for (left_row in seq_len(n)) {
      for (right_row in seq_len(left_row)) {
        same_group <- design$ComponentGroupCode[left_row, component] ==
          design$ComponentGroupCode[right_row, component]
        matches_strata <-
          design$StratumCode[[left_row]] == left_stratum &&
          design$StratumCode[[right_row]] == right_stratum
        if (left_stratum != right_stratum) {
          matches_strata <- matches_strata ||
            (design$StratumCode[[left_row]] == right_stratum &&
             design$StratumCode[[right_row]] == left_stratum)
        }
        if (same_group && matches_strata) {
          derivative[left_row, right_row] <- 1
          derivative[right_row, left_row] <- 1
        }
      }
    }
    dimnames(derivative) <- list(design$RowId, design$RowId)
    derivative_matrices[[coordinate]] <- derivative
    design_matrix[, coordinate] <- derivative[lower]
  }
  residual_index <- parameter_count
  residual <- diag(n)
  dimnames(residual) <- list(design$RowId, design$RowId)
  derivative_matrices[[residual_index]] <- residual
  design_matrix[, residual_index] <- residual[lower]
  colnames(design_matrix) <- layout$CoordinateId
  crossproduct <- crossprod(design_matrix)
  gram_eigen <- eigen(
    (crossproduct + t(crossproduct)) / 2,
    symmetric = TRUE, only.values = TRUE
  )$values
  gram_threshold <- rank_tolerance^2 * max(1, max(gram_eigen))
  gram_rank <- sum(gram_eigen > gram_threshold)
  singular_values <- svd(design_matrix, nu = 0L, nv = 0L)$d
  svd_threshold <- rank_tolerance * max(1, max(singular_values))
  svd_rank <- sum(singular_values > svd_threshold)
  structural_rank <- as.integer(min(gram_rank, svd_rank))
  identified <- identical(structural_rank, as.integer(parameter_count))
  payload <- list(
    Contract = "gtheory_multivariate_k_derivative_draft85c0_v1",
    StructuralDesignHash = design$StructuralDesignHash,
    CoordinateTable = layout, ParameterCount = parameter_count,
    VechRows = vech_rows, MatrixCells = matrix_cells,
    CapacityStatus = "evaluated",
    StructuralRank = structural_rank, GramRank = as.integer(gram_rank),
    SvdRank = as.integer(svd_rank),
    CovarianceDesignIdentified = identified,
    MinimumGramEigenvalue = min(gram_eigen),
    MaximumGramEigenvalue = max(gram_eigen),
    GramRankThreshold = gram_threshold, SvdRankThreshold = svd_threshold,
    CoordinateTableHash = mfrmr_gta_hash(layout),
    KMatrixHashes = vapply(
      derivative_matrices, mfrmr_gta_hash, character(1L)
    ),
    KDesignHash = mfrmr_gta_hash(design_matrix),
    CrossproductHash = mfrmr_gta_hash(crossproduct),
    RankTolerance = rank_tolerance
  )
  structure(c(payload, list(
    ResultHash = mfrmr_gta_hash(payload),
    ResultPayloadFields = names(payload),
    DesignMatrix = design_matrix,
    DerivativeMatrices = derivative_matrices,
    CovarianceDesignOracleReady = TRUE,
    RecoveryEvidenceReady = FALSE, EstimationReady = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE, PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvc_derivative", "list"))
}

mfrmr_gtvc_assert_derivative <- function(design, derivative) {
  mfrmr_gtvc_assert_design(design)
  common_payload <- c(
    "Contract", "StructuralDesignHash", "CoordinateTable", "ParameterCount",
    "VechRows", "MatrixCells", "CapacityStatus", "StructuralRank"
  )
  evaluated_payload <- c(
    common_payload, "GramRank", "SvdRank", "CovarianceDesignIdentified",
    "MinimumGramEigenvalue", "MaximumGramEigenvalue", "GramRankThreshold",
    "SvdRankThreshold", "CoordinateTableHash", "KMatrixHashes",
    "KDesignHash", "CrossproductHash", "RankTolerance"
  )
  blocked_payload <- c(
    common_payload, "CovarianceDesignIdentified", "CoordinateTableHash",
    "RankTolerance"
  )
  suffix_fields <- c(
    "ResultHash", "ResultPayloadFields", "DesignMatrix",
    "DerivativeMatrices", "CovarianceDesignOracleReady",
    "RecoveryEvidenceReady", "EstimationReady", "InferenceReady",
    "CoefficientEligible", "DecisionReady", "PublicSupportReady"
  )
  payload_fields <- if (identical(derivative$CapacityStatus, "evaluated")) {
    evaluated_payload
  } else if (identical(
    derivative$CapacityStatus, "not_evaluated_capacity"
  )) {
    blocked_payload
  } else character()
  exact_schema <- length(payload_fields) > 0L && mfrmr_gtvc_exact_object(
    derivative, c(payload_fields, suffix_fields),
    c("mfrmr_gtvc_derivative", "list")
  ) && identical(derivative$ResultPayloadFields, payload_fields)
  coordinate_columns <- c(
    "CoordinateId", "ComponentId", "LeftIndex", "RightIndex",
    "LeftStratum", "RightStratum", "CoordinateType"
  )
  exact_coordinates <- is.data.frame(derivative$CoordinateTable) &&
    identical(names(derivative$CoordinateTable), coordinate_columns) &&
    setequal(
      names(attributes(derivative$CoordinateTable)),
      c("names", "row.names", "class")
    )
  if (!exact_schema || !exact_coordinates) {
    stop("The K-coordinate derivative design is unavailable or mismatched.",
         call. = FALSE)
  }
  if (!identical(derivative$CapacityStatus, "evaluated") ||
      !identical(derivative$CovarianceDesignOracleReady, TRUE)) {
    stop("The K-coordinate derivative design is unavailable or mismatched: ",
         as.character(derivative$CapacityStatus), ".", call. = FALSE)
  }
  matrix_names <- derivative$CoordinateTable$CoordinateId
  exact_derivative_list <- is.list(derivative$DerivativeMatrices) &&
    identical(names(derivative$DerivativeMatrices), matrix_names) &&
    identical(names(attributes(derivative$DerivativeMatrices)), "names") &&
    all(vapply(
      derivative$DerivativeMatrices, mfrmr_gtvc_exact_matrix, logical(1L)
    ))
  exact_design_matrix <- mfrmr_gtvc_exact_matrix(derivative$DesignMatrix) &&
    identical(colnames(derivative$DesignMatrix), matrix_names)
  payload_integrity <- identical(
    mfrmr_gta_hash(derivative[payload_fields]), derivative$ResultHash
  )
  current_k_hashes <- vapply(
    derivative$DerivativeMatrices, mfrmr_gta_hash, character(1L)
  )
  current_crossproduct <- crossprod(derivative$DesignMatrix)
  integrity <-
    exact_derivative_list && exact_design_matrix &&
    identical(current_k_hashes, derivative$KMatrixHashes) &&
    identical(mfrmr_gta_hash(derivative$DesignMatrix),
              derivative$KDesignHash) &&
    identical(mfrmr_gta_hash(current_crossproduct),
              derivative$CrossproductHash) &&
    identical(mfrmr_gta_hash(derivative$CoordinateTable),
              derivative$CoordinateTableHash) && payload_integrity &&
    identical(
      derivative$CovarianceDesignIdentified,
      identical(
        derivative$StructuralRank, as.integer(derivative$ParameterCount)
      )
    ) &&
    identical(derivative$RecoveryEvidenceReady, FALSE) &&
    identical(derivative$EstimationReady, FALSE) &&
    identical(derivative$InferenceReady, FALSE) &&
    identical(derivative$CoefficientEligible, FALSE) &&
    identical(derivative$DecisionReady, FALSE) &&
    identical(derivative$PublicSupportReady, FALSE)
  if (!identical(derivative$StructuralDesignHash,
                 design$StructuralDesignHash) ||
      !integrity) {
    stop("The K-coordinate derivative design is unavailable or mismatched.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvc_pack_covariance <- function(design, covariance) {
  mfrmr_gtvc_assert_covariance(design, covariance)
  layout <- mfrmr_gtvc_coordinate_layout(design)
  value <- numeric(nrow(layout))
  for (index in seq_len(nrow(layout) - 1L)) {
    component <- match(layout$ComponentId[[index]], design$ComponentIds)
    value[[index]] <- covariance$ComponentCovariances[[component]][
      layout$LeftIndex[[index]], layout$RightIndex[[index]]
    ]
  }
  value[[length(value)]] <- covariance$ResidualVariance
  stats::setNames(value, layout$CoordinateId)
}

mfrmr_gtvc_unpack_covariance <- function(
    design, coordinates, tolerance = 1e-10, boundary_tolerance = 1e-8) {
  mfrmr_gtvc_assert_design(design)
  layout <- mfrmr_gtvc_coordinate_layout(design)
  if (!is.numeric(coordinates) || anyNA(coordinates) ||
      any(!is.finite(coordinates)) ||
      !identical(names(coordinates), layout$CoordinateId)) {
    stop("Covariance coordinates must preserve exact identity and order.",
         call. = FALSE)
  }
  matrices <- lapply(design$ComponentIds, function(component) {
    matrix(
      0, length(design$Strata), length(design$Strata),
      dimnames = list(design$Strata, design$Strata)
    )
  })
  names(matrices) <- design$ComponentIds
  for (index in seq_len(nrow(layout) - 1L)) {
    component <- layout$ComponentId[[index]]
    left <- layout$LeftIndex[[index]]
    right <- layout$RightIndex[[index]]
    matrices[[component]][left, right] <- coordinates[[index]]
    matrices[[component]][right, left] <- coordinates[[index]]
  }
  mfrmr_gtvc_covariance_spec(
    design, matrices, coordinates[[nrow(layout)]],
    tolerance = tolerance, boundary_tolerance = boundary_tolerance
  )
}

mfrmr_gtvc_population_projection <- function(
    design, covariance, derivative = mfrmr_gtvc_derivative_design(design),
    projection_tolerance = 1e-9) {
  mfrmr_gtvc_assert_covariance(design, covariance)
  mfrmr_gtvc_assert_derivative(design, derivative)
  projection_tolerance <- mfrmr_gtvc_tolerance(
    projection_tolerance, "`projection_tolerance`", positive = TRUE
  )
  dual <- mfrmr_gtvc_dual_k(design, covariance)
  lower <- lower.tri(dual$Pairwise$K, diag = TRUE)
  available <- isTRUE(derivative$CovarianceDesignIdentified)
  estimate <- if (available) {
    qr.solve(
      derivative$DesignMatrix, dual$Pairwise$K[lower],
      tol = derivative$RankTolerance
    )
  } else {
    rep(NA_real_, derivative$ParameterCount)
  }
  names(estimate) <- derivative$CoordinateTable$CoordinateId
  target <- mfrmr_gtvc_pack_covariance(design, covariance)
  coordinate_error <- estimate - target
  reconstructed_error <- if (available) {
    max(abs(
      as.numeric(derivative$DesignMatrix %*% estimate) -
        dual$Pairwise$K[lower]
    ))
  } else NA_real_
  maximum_coordinate_error <- if (available) {
    max(abs(coordinate_error))
  } else NA_real_
  passed <- available && isTRUE(dual$DualConstructionPassed) &&
    maximum_coordinate_error <= projection_tolerance &&
    reconstructed_error <= projection_tolerance
  comparison <- data.frame(
    CoordinateId = names(target), Supplied = as.numeric(target),
    Projected = as.numeric(estimate),
    RoundTripError = as.numeric(coordinate_error),
    stringsAsFactors = FALSE
  )
  payload <- list(
    Contract = "gtheory_multivariate_population_projection_draft85c0_v1",
    StructuralDesignHash = design$StructuralDesignHash,
    CovariancePointHash = covariance$CovariancePointHash,
    KDerivativeHash = derivative$ResultHash,
    DualKHash = dual$ResultHash,
    CoordinateComparison = comparison,
    MaximumCoordinateRoundTripError = maximum_coordinate_error,
    MaximumKRoundTripError = reconstructed_error,
    ProjectionTolerance = projection_tolerance,
    PopulationMapRoundTripPassed = passed,
    RegularInteriorReady = covariance$RegularInteriorReady
  )
  structure(c(payload, list(
    ResultHash = mfrmr_gta_hash(payload),
    PopulationRoundTripMechanicsReady = passed,
    RecoveryDesignFrozen = FALSE, RecoveryThresholdFrozen = FALSE,
    RecoveryExecuted = FALSE, RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvc_projection", "list"))
}

mfrmr_gtvc_linear_algebra <- function(design, covariance) {
  mfrmr_gtvc_assert_covariance(design, covariance)
  k <- mfrmr_gtvc_build_k_pairwise(design, covariance)
  cholesky <- tryCatch(chol(k$K), error = function(error) error)
  if (inherits(cholesky, "error")) {
    stop("The supplied total K matrix is not positive definite: ",
         conditionMessage(cholesky), call. = FALSE)
  }
  inverse <- chol2inv(cholesky)
  x <- design$FixedDesign
  xt_inverse_x <- crossprod(x, inverse %*% x)
  fixed_cholesky <- tryCatch(
    chol(xt_inverse_x), error = function(error) error
  )
  if (inherits(fixed_cholesky, "error")) {
    stop("The fixed-effect information is not positive definite.",
         call. = FALSE)
  }
  list(
    K = k,
    Cholesky = cholesky,
    Inverse = inverse,
    FixedInformation = xt_inverse_x,
    FixedCholesky = fixed_cholesky,
    LogDeterminantK = 2 * sum(log(diag(cholesky))),
    LogDeterminantFixedInformation =
      2 * sum(log(diag(fixed_cholesky)))
  )
}

mfrmr_gtvc_loglik <- function(design, covariance, method = c("ML", "REML")) {
  method <- match.arg(method)
  algebra <- mfrmr_gtvc_linear_algebra(design, covariance)
  x <- design$FixedDesign
  y <- design$Response
  beta <- solve(
    algebra$FixedInformation,
    crossprod(x, algebra$Inverse %*% y)
  )
  residual <- y - as.numeric(x %*% beta)
  quadratic <- as.numeric(crossprod(
    residual, algebra$Inverse %*% residual
  ))
  n <- design$RowCount
  p <- ncol(x)
  log_likelihood <- if (identical(method, "ML")) {
    -0.5 * (
      n * log(2 * pi) + algebra$LogDeterminantK + quadratic
    )
  } else {
    -0.5 * (
      (n - p) * log(2 * pi) + algebra$LogDeterminantK +
        algebra$LogDeterminantFixedInformation + quadratic
    )
  }
  names(beta) <- colnames(x)
  payload <- list(
    Contract = "gtheory_multivariate_objective_draft85c0_v1",
    StructuralDesignHash = design$StructuralDesignHash,
    NeutralDesignHash = design$NeutralDesignHash,
    ResponseHash = design$ResponseHash,
    CovariancePointHash = covariance$CovariancePointHash,
    Method = method, LogLik = log_likelihood,
    LogDeterminantK = algebra$LogDeterminantK,
    LogDeterminantFixedInformation =
      algebra$LogDeterminantFixedInformation,
    Quadratic = quadratic, FixedEffects = beta,
    Observations = n, FixedEffectCount = p,
    KHash = algebra$K$KHash,
    RegularInteriorReady = covariance$RegularInteriorReady
  )
  structure(c(payload, list(
    ResultHash = mfrmr_gta_hash(payload),
    ObjectiveOracleReady = is.finite(log_likelihood),
    RecoveryEvidenceReady = FALSE, EstimationReady = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE, PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvc_objective", "list"))
}

mfrmr_gtvc_expected_information <- function(
    design, covariance,
    derivative = mfrmr_gtvc_derivative_design(design),
    rank_tolerance = 1e-9) {
  mfrmr_gtvc_assert_derivative(design, derivative)
  rank_tolerance <- mfrmr_gtvc_tolerance(
    rank_tolerance, "`rank_tolerance`", positive = TRUE
  )
  algebra <- mfrmr_gtvc_linear_algebra(design, covariance)
  inverse <- algebra$Inverse
  x <- design$FixedDesign
  projection <- inverse - inverse %*% x %*%
    solve(algebra$FixedInformation, crossprod(x, inverse))
  q <- derivative$ParameterCount
  information_for <- function(weight) {
    transformed <- lapply(
      derivative$DerivativeMatrices,
      function(k) weight %*% k
    )
    information <- matrix(0, q, q)
    for (left in seq_len(q)) {
      for (right in seq_len(left)) {
        value <- 0.5 * sum(t(transformed[[left]]) * transformed[[right]])
        information[left, right] <- value
        information[right, left] <- value
      }
    }
    dimnames(information) <- list(
      derivative$CoordinateTable$CoordinateId,
      derivative$CoordinateTable$CoordinateId
    )
    eigenvalues <- eigen(
      (information + t(information)) / 2,
      symmetric = TRUE, only.values = TRUE
    )$values
    threshold <- rank_tolerance * max(1, max(eigenvalues))
    rank <- sum(eigenvalues > threshold)
    positive <- eigenvalues[eigenvalues > threshold]
    list(
      Matrix = information, Eigenvalues = eigenvalues,
      Rank = as.integer(rank), Threshold = threshold,
      ConditionNumber = if (length(positive) > 0L) {
        max(positive) / min(positive)
      } else Inf
    )
  }
  ml <- information_for(inverse)
  reml <- information_for(projection)
  full <- derivative$ParameterCount
  payload <- list(
    Contract = "gtheory_multivariate_expected_information_draft85c0_v1",
    StructuralDesignHash = design$StructuralDesignHash,
    CovariancePointHash = covariance$CovariancePointHash,
    KDerivativeHash = derivative$ResultHash,
    ParameterCount = full,
    MLRank = ml$Rank, REMLRank = reml$Rank,
    MLConditionNumber = ml$ConditionNumber,
    REMLConditionNumber = reml$ConditionNumber,
    MLMinimumEigenvalue = min(ml$Eigenvalues),
    REMLMinimumEigenvalue = min(reml$Eigenvalues),
    RankTolerance = rank_tolerance,
    MLInformationHash = mfrmr_gta_hash(ml$Matrix),
    REMLInformationHash = mfrmr_gta_hash(reml$Matrix),
    CovarianceDesignIdentified = derivative$CovarianceDesignIdentified,
    MLExpectedInformationFullRank = identical(ml$Rank, as.integer(full)),
    REMLExpectedInformationFullRank = identical(reml$Rank, as.integer(full)),
    RegularInteriorReady = covariance$RegularInteriorReady
  )
  structure(c(payload, list(
    ResultHash = mfrmr_gta_hash(payload),
    MLInformation = ml$Matrix, REMLInformation = reml$Matrix,
    LocalExpectedInformationComputed = TRUE,
    LocalExpectedInformationReady =
      isTRUE(payload$CovarianceDesignIdentified) &&
      isTRUE(payload$RegularInteriorReady) &&
      isTRUE(payload$MLExpectedInformationFullRank) &&
      isTRUE(payload$REMLExpectedInformationFullRank),
    PrecisionEvidenceReady = FALSE, UncertaintyReady = FALSE,
    RecoveryEvidenceReady = FALSE, EstimationReady = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE, PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvc_information", "list"))
}

mfrmr_gtvc_score <- function(
    design, covariance, method = c("ML", "REML"),
    derivative = mfrmr_gtvc_derivative_design(design)) {
  method <- match.arg(method)
  mfrmr_gtvc_assert_derivative(design, derivative)
  objective <- mfrmr_gtvc_loglik(design, covariance, method)
  algebra <- mfrmr_gtvc_linear_algebra(design, covariance)
  x <- design$FixedDesign
  y <- design$Response
  projection <- algebra$Inverse - algebra$Inverse %*% x %*%
    solve(algebra$FixedInformation, crossprod(x, algebra$Inverse))
  q_vector <- as.numeric(projection %*% y)
  trace_weight <- if (identical(method, "ML")) {
    algebra$Inverse
  } else {
    projection
  }
  score <- vapply(derivative$DerivativeMatrices, function(k) {
    0.5 * (
      as.numeric(crossprod(q_vector, k %*% q_vector)) -
        sum(t(trace_weight) * k)
    )
  }, numeric(1L))
  score <- stats::setNames(score, derivative$CoordinateTable$CoordinateId)
  payload <- list(
    Contract = "gtheory_multivariate_k_score_draft85c0_v1",
    ObjectiveHash = objective$ResultHash,
    KDerivativeHash = derivative$ResultHash,
    Method = method, Score = score,
    MaximumAbsoluteScore = max(abs(score)),
    ScoreFinite = all(is.finite(score))
  )
  structure(c(payload, list(
    ResultHash = mfrmr_gta_hash(payload),
    KCoordinateScoreReady = payload$ScoreFinite,
    RecoveryEvidenceReady = FALSE, EstimationReady = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE, PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvc_score", "list"))
}

mfrmr_gtvc_core_audit <- function() {
  core_functions <- c(
    "mfrmr_gtvc_exact_object", "mfrmr_gtvc_exact_matrix",
    "mfrmr_gtvc_design_fields", "mfrmr_gtvc_bridge_extension_fields",
    "mfrmr_gtvc_tolerance", "mfrmr_gtvc_codes",
    "mfrmr_gtvc_neutral_design", "mfrmr_gtvc_assert_design",
    "mfrmr_gtvc_matrix_audit",
    "mfrmr_gtvc_covariance_spec", "mfrmr_gtvc_assert_covariance",
    "mfrmr_gtvc_build_k_pairwise", "mfrmr_gtvc_build_k_z",
    "mfrmr_gtvc_dual_k",
    "mfrmr_gtvc_coordinate_layout", "mfrmr_gtvc_derivative_design",
    "mfrmr_gtvc_assert_derivative",
    "mfrmr_gtvc_pack_covariance", "mfrmr_gtvc_unpack_covariance",
    "mfrmr_gtvc_population_projection",
    "mfrmr_gtvc_linear_algebra", "mfrmr_gtvc_loglik",
    "mfrmr_gtvc_expected_information", "mfrmr_gtvc_score",
    "mfrmr_gtvc_candidate_stage_valid", "mfrmr_gtvc_candidate_receipt",
    "mfrmr_gtvc_assert_candidate_receipt",
    "mfrmr_gtvc_join_reference", "mfrmr_gtvc_denominator_audit"
  )
  forbidden <- c(
    "mfrmr_gtvb_", "lme4::", "glmmTMB::", "model.matrix",
    "reformulas", "VarCorr"
  )
  rows <- lapply(core_functions, function(function_name) {
    fun <- get(function_name, mode = "function", inherits = TRUE)
    body_text <- paste(deparse(body(fun), width.cutoff = 500L), collapse = "\n")
    hits <- forbidden[vapply(
      forbidden, grepl, logical(1L), x = body_text, fixed = TRUE
    )]
    data.frame(
      Function = function_name,
      ForbiddenDependencyCount = length(hits),
      ForbiddenDependencies = paste(hits, collapse = ","),
      FunctionHash = mfrmr_gta_hash(list(
        Formals = formals(fun), Body = body(fun)
      )),
      stringsAsFactors = FALSE
    )
  })
  audit <- do.call(rbind, rows)
  structure(list(
    Contract = "gtheory_multivariate_oracle_independence_draft85c0_v1",
    FunctionAudit = audit,
    OracleIndependenceReady = all(audit$ForbiddenDependencyCount == 0L),
    AuditHash = mfrmr_gta_hash(audit),
    RecoveryEvidenceReady = FALSE, EstimationReady = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE, PublicSupportReady = FALSE
  ), class = c("mfrmr_gtvc_independence", "list"))
}

mfrmr_gtvc_bridge_gtvb <- function(spec, max_k_cells = 5e7) {
  if (!inherits(spec, "mfrmr_gtvb_spec") ||
      !isTRUE(spec$PointFitEligible)) {
    stop("`spec` must be a point-fit-eligible Draft.85b1 specification.",
         call. = FALSE)
  }
  mfrmr_gtvb_assert_fit_spec(spec)
  nonresidual <- which(spec$ComponentMap$ComponentId != "Residual")
  component_ids <- spec$ComponentMap$ComponentId[nonresidual]
  row_id <- row.names(spec$BackendData)
  stratum_code <- as.integer(spec$BackendData$.gtvb_stratum)
  group_codes <- matrix(
    0L, nrow = nrow(spec$BackendData), ncol = length(component_ids),
    dimnames = list(row_id, component_ids)
  )
  replay_random_hashes <- character(length(component_ids))
  names(replay_random_hashes) <- component_ids
  semantic_groups <- vector("list", length(component_ids))
  names(semantic_groups) <- component_ids
  for (index in seq_along(component_ids)) {
    group <- spec$ComponentMap$BackendGroup[[nonresidual[[index]]]]
    semantic_group <- as.character(spec$BackendData[[group]])
    semantic_groups[[index]] <- semantic_group
    canonical_levels <- sort(unique(semantic_group), method = "radix")
    group_codes[, index] <- match(semantic_group, canonical_levels)
    replay_random_hashes[[index]] <- mfrmr_gta_hash(list(
      Strata = spec$Strata, Group = semantic_group
    ))
  }
  fixed <- matrix(
    0, nrow = nrow(spec$BackendData), ncol = length(spec$Strata),
    dimnames = list(row_id, paste0("Stratum/", spec$Strata))
  )
  fixed[cbind(seq_len(nrow(fixed)), stratum_code)] <- 1
  response <- stats::setNames(spec$BackendData$.gtvb_score, row_id)
  source_binding <- mfrmr_gtvb_backend_binding(
    spec$BackendData, spec$ComponentMap
  )
  backend_row_id_hash <- source_binding$BackendRowIdHash
  backend_response_hash <- source_binding$BackendResponseHash
  backend_data_hash <- source_binding$BackendDataHash
  neutral <- mfrmr_gtvc_neutral_design(
    row_id = row_id, strata = spec$Strata, stratum_code = stratum_code,
    component_group_code = group_codes, fixed_design = fixed,
    response = response
  )
  replay_fixed_hash <- mfrmr_gta_hash(list(
    Strata = spec$Strata, ColumnNames = spec$FixedDesignColumns,
    Matrix = matrix(as.numeric(fixed), nrow(fixed), ncol(fixed))
  ))
  fixed_design_hash_match <- identical(
    replay_fixed_hash, spec$FixedDesignHash
  )
  random_design_hashes_match <- identical(
    replay_random_hashes, spec$RandomDesignBlockHashes
  )
  source_design_hashes_match <-
    fixed_design_hash_match && random_design_hashes_match &&
    identical(backend_row_id_hash, spec$BackendRowIdHash) &&
    identical(backend_response_hash, spec$BackendResponseHash) &&
    identical(backend_data_hash, spec$BackendDataHash)
  derivative <- mfrmr_gtvc_derivative_design(
    neutral, rank_tolerance = spec$RankTolerance,
    max_k_cells = max_k_cells
  )
  k_design_match <-
    identical(derivative$CapacityStatus, "evaluated") &&
    identical(
      derivative$CoordinateTable$CoordinateId,
      spec$CovarianceDesignAudit$ParameterLabels
    ) &&
    identical(
      derivative$CrossproductHash,
      spec$CovarianceDesignAudit$CrossproductHash
    ) &&
    identical(
      derivative$StructuralRank,
      spec$CovarianceDesignAudit$StructuralRank
    )
  independence <- mfrmr_gtvc_core_audit()
  if (!source_design_hashes_match || !k_design_match ||
      !isTRUE(independence$OracleIndependenceReady)) {
    failed <- c(
      if (!fixed_design_hash_match) "fixed_design_hash" else NULL,
      if (!random_design_hashes_match) "random_design_hashes" else NULL,
      if (!identical(backend_row_id_hash, spec$BackendRowIdHash)) {
        "backend_row_id_hash"
      } else NULL,
      if (!identical(backend_response_hash, spec$BackendResponseHash)) {
        "backend_response_hash"
      } else NULL,
      if (!identical(backend_data_hash, spec$BackendDataHash)) {
        "backend_data_hash"
      } else NULL,
      if (!k_design_match) "k_design_binding" else NULL,
      if (!isTRUE(independence$OracleIndependenceReady)) {
        "oracle_independence"
      } else NULL
    )
    stop("The Draft.85b1-to-neutral bridge failed: ",
         paste(failed, collapse = ", "), ".", call. = FALSE)
  }
  bridge_payload <- list(
    Contract = "gtheory_multivariate_b1_bridge_draft85c0_v1",
    SourceSpecificationHash = spec$SpecificationHash,
    SourceIncidenceAuditHash = spec$IncidenceAuditHash,
    SourceRowBindingHash = spec$RowBindingHash,
    SourceBackendRowIdHash = spec$BackendRowIdHash,
    SourceBackendResponseHash = spec$BackendResponseHash,
    SourceBackendDataHash = spec$BackendDataHash,
    SourceFixedDesignHash = spec$FixedDesignHash,
    SourceRandomDesignBlockHashes = spec$RandomDesignBlockHashes,
    SourceCovarianceDesignHash = spec$CovarianceDesignHash,
    NeutralDesignHash = neutral$NeutralDesignHash,
    StructuralDesignHash = neutral$StructuralDesignHash,
    NeutralKDerivativeHash = derivative$ResultHash,
    SourceDesignHashesMatch = source_design_hashes_match,
    KDesignBindingPassed = k_design_match,
    OracleIndependenceAuditHash = independence$AuditHash
  )
  result <- unclass(neutral)
  result$Bridge <- bridge_payload
  result$BridgeHash <- mfrmr_gta_hash(bridge_payload)
  result$KDerivative <- derivative
  result$OracleIndependence <- independence
  result$B1BridgeReady <- TRUE
  result$OracleIndependenceReady <- TRUE
  result$RecoveryEvidenceReady <- FALSE
  result$EstimationReady <- FALSE
  result$InferenceReady <- FALSE
  result$CoefficientEligible <- FALSE
  result$DecisionReady <- FALSE
  result$PublicSupportReady <- FALSE
  structure(
    result,
    class = c("mfrmr_gtvc_bridge", "mfrmr_gtvc_design", "list")
  )
}

mfrmr_gtvc_assert_bridge <- function(bridge) {
  mfrmr_gtvc_assert_design(bridge)
  current_independence <- mfrmr_gtvc_core_audit()
  if (!inherits(bridge, "mfrmr_gtvc_bridge") ||
      !identical(bridge$B1BridgeReady, TRUE) ||
      !identical(bridge$OracleIndependenceReady, TRUE) ||
      !identical(bridge$Bridge$SourceDesignHashesMatch, TRUE) ||
      !identical(bridge$Bridge$KDesignBindingPassed, TRUE) ||
      !identical(mfrmr_gta_hash(bridge$Bridge), bridge$BridgeHash) ||
      !identical(
        bridge$Bridge$NeutralDesignHash, bridge$NeutralDesignHash
      ) ||
      !identical(
        bridge$Bridge$StructuralDesignHash, bridge$StructuralDesignHash
      ) ||
      !identical(
        bridge$Bridge$NeutralKDerivativeHash,
        bridge$KDerivative$ResultHash
      ) ||
      !identical(
        bridge$Bridge$OracleIndependenceAuditHash,
        bridge$OracleIndependence$AuditHash
      ) || !identical(
        bridge$OracleIndependence$AuditHash,
        current_independence$AuditHash
      ) || !identical(
        bridge$OracleIndependence$OracleIndependenceReady, TRUE
      ) || !identical(current_independence$OracleIndependenceReady, TRUE) ||
      !identical(bridge$RecoveryEvidenceReady, FALSE) ||
      !identical(bridge$EstimationReady, FALSE) ||
      !identical(bridge$InferenceReady, FALSE) ||
      !identical(bridge$CoefficientEligible, FALSE) ||
      !identical(bridge$DecisionReady, FALSE) ||
      !identical(bridge$PublicSupportReady, FALSE)) {
    stop("The Draft.85b1-to-neutral bridge identity was altered.",
         call. = FALSE)
  }
  mfrmr_gtvc_assert_derivative(bridge, bridge$KDerivative)
  invisible(TRUE)
}

mfrmr_gtvc_covariance_from_gtvb <- function(bridge, fit) {
  mfrmr_gtvc_assert_bridge(bridge)
  mfrmr_gtvb_assert_fit_integrity(fit)
  if (!inherits(fit, "mfrmr_gtvb_fit") ||
      !identical(
        bridge$Bridge$SourceSpecificationHash, fit$SpecificationHash
      )) {
    stop("The Draft.85b1 fit and neutral bridge identities do not match.",
         call. = FALSE)
  }
  expected_component_order <- c(bridge$ComponentIds, "Residual")
  if (!identical(
    names(fit$ComponentCovariances), expected_component_order
  )) {
    stop("The fitted component covariance order does not match exactly.",
         call. = FALSE)
  }
  component_covariances <- fit$ComponentCovariances[bridge$ComponentIds]
  if (!identical(names(component_covariances), bridge$ComponentIds)) {
    stop("The fitted component covariance identity is incomplete.",
         call. = FALSE)
  }
  residual <- fit$ComponentCovariances[["Residual"]]
  if (!is.matrix(residual) ||
      !identical(dimnames(residual), list(bridge$Strata, bridge$Strata)) ||
      max(abs(residual[row(residual) != col(residual)])) > 1e-10 ||
      max(abs(diag(residual) - diag(residual)[[1L]])) > 1e-10) {
    stop("The fitted residual does not match sigma^2 I.", call. = FALSE)
  }
  mfrmr_gtvc_covariance_spec(
    bridge, component_covariances, diag(residual)[[1L]]
  )
}

mfrmr_gtvc_compare_fit <- function(
    bridge, fit, objective_tolerance = 1e-8,
    fixed_tolerance = 1e-8) {
  objective_tolerance <- mfrmr_gtvc_tolerance(
    objective_tolerance, "`objective_tolerance`"
  )
  fixed_tolerance <- mfrmr_gtvc_tolerance(
    fixed_tolerance, "`fixed_tolerance`"
  )
  covariance <- mfrmr_gtvc_covariance_from_gtvb(bridge, fit)
  method <- fit$EstimatorIdentity$Method
  if (!method %in% c("ML", "REML")) {
    stop("The fitted criterion is outside the Draft.85c0 objective oracle.",
         call. = FALSE)
  }
  objective <- mfrmr_gtvc_loglik(bridge, covariance, method)
  score <- mfrmr_gtvc_score(
    bridge, covariance, method, derivative = bridge$KDerivative
  )
  if (!identical(names(fit$FixedEffectsByStratum), bridge$Strata) ||
      any(!is.finite(fit$FixedEffectsByStratum))) {
    stop("The fitted fixed-effect names/order are not exact.", call. = FALSE)
  }
  oracle_fixed <- stats::setNames(
    as.numeric(objective$FixedEffects), bridge$Strata
  )
  fixed_difference <- max(abs(
    oracle_fixed - fit$FixedEffectsByStratum
  ))
  likelihood_difference <- abs(
    objective$LogLik - fit$LikelihoodIdentity$Value
  )
  identity_match <-
    identical(bridge$Bridge$SourceRowBindingHash, fit$RowBindingHash) &&
    identical(
      bridge$Bridge$SourceFixedDesignHash,
      fit$EstimatorIdentity$FixedDesignHash
    ) &&
    identical(
      bridge$Bridge$SourceRandomDesignBlockHashes,
      fit$EstimatorIdentity$RandomDesignBlockHashes
    )
  passed <- identity_match &&
    likelihood_difference <= objective_tolerance &&
    fixed_difference <= fixed_tolerance
  payload <- list(
    Contract = "gtheory_multivariate_fit_objective_binding_draft85c0_v1",
    BridgeHash = bridge$BridgeHash,
    BackendFitHash = fit$ResultHash,
    CovariancePointHash = covariance$CovariancePointHash,
    OracleObjectiveHash = objective$ResultHash,
    OracleScoreHash = score$ResultHash,
    Method = method, Backend = fit$EstimatorIdentity$Backend,
    SemanticIdentityMatched = identity_match,
    BackendLogLik = fit$LikelihoodIdentity$Value,
    OracleLogLik = objective$LogLik,
    LogLikAbsoluteDifference = likelihood_difference,
    FixedEffectMaximumAbsoluteDifference = fixed_difference,
    MaximumAbsoluteKCoordinateScore = score$MaximumAbsoluteScore,
    ObjectiveTolerance = objective_tolerance,
    FixedTolerance = fixed_tolerance,
    DeterministicObjectiveBindingPassed = passed,
    BackendPointEstimationGatePassed = fit$PointEstimationGatePassed,
    RegularInteriorReady = covariance$RegularInteriorReady
  )
  structure(c(payload, list(
    ResultHash = mfrmr_gta_hash(payload),
    IndependentLikelihoodOracleReady = passed,
    EstimatorRecoveryReady = FALSE, RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE, InferenceReady = FALSE,
    UncertaintyReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE, PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvc_fit_comparison", "list"))
}

mfrmr_gtvc_candidate_stage_valid <- function(
    fit_returned, estimate_available, point_gate_passed,
    failure_stage, failure_code) {
  state <- paste0(
    as.integer(isTRUE(fit_returned)),
    as.integer(isTRUE(estimate_available)),
    as.integer(isTRUE(point_gate_passed))
  )
  stage_valid <- switch(
    state,
    `000` = identical(failure_stage, "backend_fit"),
    `100` = failure_stage %in% c(
      "optimizer", "component_extraction", "identity"
    ),
    `110` = failure_stage %in% c("optimizer", "regularity", "identity"),
    `111` = identical(failure_stage, "none"),
    FALSE
  )
  code_valid <- identical(failure_code, "none") ==
    identical(failure_stage, "none")
  isTRUE(stage_valid) && isTRUE(code_valid)
}

mfrmr_gtvc_candidate_receipt <- function(
    dataset_id, method_id, design, estimate_covariance = NULL,
    fit_returned = !is.null(estimate_covariance),
    point_gate_passed = FALSE, failure_stage, failure_code) {
  mfrmr_gtvc_assert_design(design)
  dataset_id <- as.character(dataset_id)
  method_id <- as.character(method_id)
  if (length(dataset_id) != 1L || is.na(dataset_id) || !nzchar(dataset_id) ||
      length(method_id) != 1L || is.na(method_id) || !nzchar(method_id) ||
      length(fit_returned) != 1L || is.na(fit_returned) ||
      !is.logical(fit_returned) || length(point_gate_passed) != 1L ||
      is.na(point_gate_passed) || !is.logical(point_gate_passed)) {
    stop("Candidate identity and state flags must be complete scalars.",
         call. = FALSE)
  }
  failure_stage <- as.character(failure_stage)
  failure_code <- as.character(failure_code)
  allowed_stages <- c(
    "none", "backend_fit", "optimizer", "component_extraction",
    "regularity", "identity"
  )
  if (length(failure_stage) != 1L || is.na(failure_stage) ||
      !failure_stage %in% allowed_stages || length(failure_code) != 1L ||
      is.na(failure_code) || !nzchar(failure_code)) {
    stop("Candidate failure stage and code must be complete and typed.",
         call. = FALSE)
  }
  estimate_available <- inherits(
    estimate_covariance, "mfrmr_gtvc_covariance"
  )
  if (!is.null(estimate_covariance) && !estimate_available) {
    stop("`estimate_covariance` must be a bound covariance point or NULL.",
         call. = FALSE)
  }
  if (estimate_available) {
    mfrmr_gtvc_assert_covariance(design, estimate_covariance)
  }
  if (!mfrmr_gtvc_candidate_stage_valid(
    fit_returned, estimate_available, point_gate_passed,
    failure_stage, failure_code
  )) {
    stop("Candidate stage flags do not match an allowed monotone tuple.",
         call. = FALSE)
  }
  payload <- list(
    Contract = "gtheory_multivariate_candidate_receipt_draft85c0_v1",
    DatasetId = dataset_id, MethodId = method_id,
    StructuralDesignHash = design$StructuralDesignHash,
    NeutralDesignHash = design$NeutralDesignHash,
    FitReturned = isTRUE(fit_returned),
    EstimateAvailable = isTRUE(estimate_available),
    PointGatePassed = isTRUE(point_gate_passed),
    FailureStage = failure_stage, FailureCode = failure_code,
    EstimateCovarianceHash = if (estimate_available) {
      estimate_covariance$CovariancePointHash
    } else NA_character_
  )
  structure(c(payload, list(
    CandidateReceiptHash = mfrmr_gta_hash(payload),
    EstimateCovariance = if (estimate_available) estimate_covariance else NULL,
    CandidateStateSealed = TRUE,
    CandidateStageTupleReady = TRUE,
    RecoveryMetricSchemaReady = FALSE,
    RecoveryThresholdFrozen = FALSE, RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE, EstimatorRecoveryReady = FALSE,
    EstimationReady = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvc_candidate_receipt", "list"))
}

mfrmr_gtvc_assert_candidate_receipt <- function(design, receipt) {
  mfrmr_gtvc_assert_design(design)
  payload_fields <- c(
    "Contract", "DatasetId", "MethodId", "StructuralDesignHash",
    "NeutralDesignHash", "FitReturned", "EstimateAvailable",
    "PointGatePassed", "FailureStage", "FailureCode",
    "EstimateCovarianceHash"
  )
  suffix_fields <- c(
    "CandidateReceiptHash", "EstimateCovariance", "CandidateStateSealed",
    "CandidateStageTupleReady", "RecoveryMetricSchemaReady",
    "RecoveryThresholdFrozen", "RecoveryExecuted", "RecoveryEvidenceReady",
    "EstimatorRecoveryReady", "EstimationReady", "InferenceReady",
    "CoefficientEligible", "DecisionReady", "PublicSupportReady"
  )
  if (!mfrmr_gtvc_exact_object(
    receipt, c(payload_fields, suffix_fields),
    c("mfrmr_gtvc_candidate_receipt", "list")
  )) {
    stop("A sealed Draft.85c0 candidate receipt is required.", call. = FALSE)
  }
  estimate_integrity <- if (identical(receipt$EstimateAvailable, TRUE)) {
    mfrmr_gtvc_assert_covariance(design, receipt$EstimateCovariance)
    identical(
      receipt$EstimateCovarianceHash,
      receipt$EstimateCovariance$CovariancePointHash
    )
  } else {
    is.null(receipt$EstimateCovariance) &&
      is.na(receipt$EstimateCovarianceHash)
  }
  valid <-
    identical(receipt$StructuralDesignHash, design$StructuralDesignHash) &&
    identical(receipt$NeutralDesignHash, design$NeutralDesignHash) &&
    identical(
      mfrmr_gta_hash(receipt[payload_fields]), receipt$CandidateReceiptHash
    ) &&
    identical(receipt$CandidateStateSealed, TRUE) &&
    identical(receipt$CandidateStageTupleReady, TRUE) && estimate_integrity &&
    mfrmr_gtvc_candidate_stage_valid(
      receipt$FitReturned, receipt$EstimateAvailable,
      receipt$PointGatePassed, receipt$FailureStage, receipt$FailureCode
    ) &&
    identical(receipt$RecoveryMetricSchemaReady, FALSE) &&
    identical(receipt$RecoveryThresholdFrozen, FALSE) &&
    identical(receipt$RecoveryExecuted, FALSE) &&
    identical(receipt$RecoveryEvidenceReady, FALSE) &&
    identical(receipt$EstimationReady, FALSE) &&
    identical(receipt$InferenceReady, FALSE) &&
    identical(receipt$CoefficientEligible, FALSE) &&
    identical(receipt$DecisionReady, FALSE) &&
    identical(receipt$PublicSupportReady, FALSE)
  if (!valid) {
    stop("The candidate receipt or exact sealed-state schema was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvc_join_reference <- function(
    design, candidate_receipt, reference_covariance,
    zero_tolerance = 1e-12) {
  mfrmr_gtvc_assert_candidate_receipt(design, candidate_receipt)
  candidate_hash_before <- candidate_receipt$CandidateReceiptHash
  mfrmr_gtvc_assert_covariance(design, reference_covariance)
  zero_tolerance <- mfrmr_gtvc_tolerance(
    zero_tolerance, "`zero_tolerance`", positive = TRUE
  )
  reference <- mfrmr_gtvc_pack_covariance(design, reference_covariance)
  metric_available <- isTRUE(candidate_receipt$EstimateAvailable)
  estimate <- if (metric_available) {
    mfrmr_gtvc_pack_covariance(
      design, candidate_receipt$EstimateCovariance
    )
  } else {
    stats::setNames(rep(NA_real_, length(reference)), names(reference))
  }
  if (!identical(names(estimate), names(reference))) {
    stop("Estimate/reference coordinate identities cannot be reordered.",
         call. = FALSE)
  }
  signed_error <- estimate - reference
  relative_available <- metric_available & abs(reference) > zero_tolerance
  coordinate_metrics <- data.frame(
    DatasetId = candidate_receipt$DatasetId,
    MethodId = candidate_receipt$MethodId,
    CoordinateId = names(reference), Planned = TRUE,
    FitReturned = candidate_receipt$FitReturned,
    PointGatePassed = candidate_receipt$PointGatePassed,
    MetricAvailable = metric_available,
    Reference = as.numeric(reference), Estimate = as.numeric(estimate),
    SignedDeterministicError = as.numeric(signed_error),
    AbsoluteDeterministicError = abs(as.numeric(signed_error)),
    SquaredDeterministicError = as.numeric(signed_error)^2,
    RelativeErrorAvailable = relative_available,
    RelativeDeterministicError = ifelse(
      relative_available, as.numeric(signed_error / reference), NA_real_
    ), stringsAsFactors = FALSE
  )
  k_error <- if (metric_available) {
    reference_k <- mfrmr_gtvc_build_k_pairwise(
      design, reference_covariance
    )$K
    estimate_k <- mfrmr_gtvc_build_k_pairwise(
      design, candidate_receipt$EstimateCovariance
    )$K
    max(abs(estimate_k - reference_k))
  } else NA_real_
  mfrmr_gtvc_assert_candidate_receipt(design, candidate_receipt)
  candidate_hash_after <- candidate_receipt$CandidateReceiptHash
  payload <- list(
    Contract = "gtheory_multivariate_metric_ledger_draft85c0_v1",
    DatasetId = candidate_receipt$DatasetId,
    MethodId = candidate_receipt$MethodId,
    StructuralDesignHash = design$StructuralDesignHash,
    CandidateReceiptHash = candidate_receipt$CandidateReceiptHash,
    CandidateStateHashBeforeReferenceJoin = candidate_hash_before,
    CandidateStateHashAfterReferenceJoin = candidate_hash_after,
    ReferenceCovarianceHash = reference_covariance$CovariancePointHash,
    CoordinateMetrics = coordinate_metrics,
    MaximumAbsoluteKError = k_error,
    Planned = TRUE, FitReturned = candidate_receipt$FitReturned,
    PointGatePassed = candidate_receipt$PointGatePassed,
    MetricAvailable = metric_available
  )
  structure(c(payload, list(
    ResultHash = mfrmr_gta_hash(payload),
    ReferenceJoinIntegrityReady = identical(
      payload$CandidateStateHashBeforeReferenceJoin,
      payload$CandidateStateHashAfterReferenceJoin
    ),
    RecoveryMetricSchemaReady = TRUE,
    RecoveryDenominatorReady = FALSE,
    RecoveryThresholdFrozen = FALSE, RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE, EstimatorRecoveryReady = FALSE,
    EstimationReady = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvc_metric_ledger", "list"))
}

mfrmr_gtvc_denominator_audit <- function(
    planned_registry, candidate_receipts, design) {
  mfrmr_gtvc_assert_design(design)
  required <- c("DatasetId", "MethodId")
  if (!is.data.frame(planned_registry) || nrow(planned_registry) == 0L ||
      !all(required %in% names(planned_registry))) {
    stop("`planned_registry` needs DatasetId and MethodId rows.",
         call. = FALSE)
  }
  registry <- planned_registry[required]
  registry$DatasetId <- as.character(registry$DatasetId)
  registry$MethodId <- as.character(registry$MethodId)
  if (anyNA(registry) || any(!nzchar(registry$DatasetId)) ||
      any(!nzchar(registry$MethodId))) {
    stop("Planned registry identities must be complete.", call. = FALSE)
  }
  registry_key <- paste(registry$DatasetId, registry$MethodId, sep = "\036")
  if (anyDuplicated(registry_key)) {
    stop("Planned registry identities must be unique.", call. = FALSE)
  }
  if (!is.list(candidate_receipts)) {
    stop("`candidate_receipts` must be a list.", call. = FALSE)
  }
  receipt_key <- vapply(candidate_receipts, function(receipt) {
    mfrmr_gtvc_assert_candidate_receipt(design, receipt)
    paste(receipt$DatasetId, receipt$MethodId, sep = "\036")
  }, character(1L))
  if (anyDuplicated(receipt_key)) {
    stop("Candidate receipt identities must be unique.", call. = FALSE)
  }
  missing <- setdiff(registry_key, receipt_key)
  extra <- setdiff(receipt_key, registry_key)
  exact <- length(missing) == 0L && length(extra) == 0L &&
    length(receipt_key) == length(registry_key)
  ordered_hashes <- if (exact) {
    vapply(
      candidate_receipts[match(registry_key, receipt_key)],
      function(receipt) receipt$CandidateReceiptHash, character(1L)
    )
  } else character()
  payload <- list(
    Contract = "gtheory_multivariate_denominator_audit_draft85c0_v1",
    StructuralDesignHash = design$StructuralDesignHash,
    Registry = registry,
    RegistryHash = mfrmr_gta_hash(registry),
    PlannedRows = nrow(registry), ReceivedRows = length(receipt_key),
    MissingKeys = missing, ExtraKeys = extra,
    OrderedCandidateReceiptHashes = ordered_hashes,
    ExactAtomicAccounting = exact
  )
  structure(c(payload, list(
    ResultHash = mfrmr_gta_hash(payload),
    AtomicRegistryMatchReady = exact,
    DenominatorAccountingReady = FALSE,
    RecoveryDesignFrozen = FALSE, RecoveryThresholdFrozen = FALSE,
    RecoveryExecuted = FALSE, RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvc_denominator_audit", "list"))
}
