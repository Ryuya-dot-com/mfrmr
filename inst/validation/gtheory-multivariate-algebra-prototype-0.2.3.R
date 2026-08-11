# Future Draft.85a0 multivariate G-theory algebra preflight.
#
# Repository-internal only. This file accepts supplied component covariance
# matrices and explicit prospective allocation weights. It fits no model,
# estimates no covariance, and never marks a composite coefficient ready.

mfrmr_gtv_require_primitives <- function() {
  if (!exists("mfrmr_gta_hash", mode = "function", inherits = TRUE)) {
    stop("Source Draft.81 before the multivariate algebra preflight.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtv_tolerance <- function(tolerance) {
  tolerance <- as.numeric(tolerance)
  if (length(tolerance) != 1L || !is.finite(tolerance) || tolerance < 0) {
    stop("`tolerance` must be one finite non-negative number.", call. = FALSE)
  }
  tolerance
}

mfrmr_gtv_strata <- function(strata) {
  strata <- as.character(strata)
  if (length(strata) == 0L || anyNA(strata) || any(!nzchar(strata)) ||
      anyDuplicated(strata)) {
    stop("`strata` must be a non-empty ordered set of unique labels.",
         call. = FALSE)
  }
  strata
}

mfrmr_gtv_matrix_audit <- function(
    matrix, strata, matrix_id, tolerance = 1e-10,
    require_nonnegative_entries = FALSE, require_positive_diagonal = FALSE) {
  strata <- mfrmr_gtv_strata(strata)
  tolerance <- mfrmr_gtv_tolerance(tolerance)
  matrix_id <- as.character(matrix_id)
  if (length(matrix_id) != 1L || !nzchar(matrix_id)) {
    stop("`matrix_id` must be one non-empty label.", call. = FALSE)
  }
  if (!is.matrix(matrix) || !is.numeric(matrix) ||
      !identical(dim(matrix), c(length(strata), length(strata)))) {
    stop("Matrix `", matrix_id, "` has the wrong numeric dimensions.",
         call. = FALSE)
  }
  if (!identical(rownames(matrix), strata) ||
      !identical(colnames(matrix), strata)) {
    stop("Matrix `", matrix_id, "` does not preserve exact stratum order.",
         call. = FALSE)
  }
  if (any(!is.finite(matrix))) {
    stop("Matrix `", matrix_id, "` contains a non-finite entry.",
         call. = FALSE)
  }
  asymmetry <- max(abs(matrix - t(matrix)))
  if (asymmetry > tolerance) {
    stop("Matrix `", matrix_id, "` is asymmetric beyond tolerance.",
         call. = FALSE)
  }
  symmetric <- (matrix + t(matrix)) / 2
  if (isTRUE(require_nonnegative_entries) && any(symmetric < -tolerance)) {
    stop("Operator `", matrix_id, "` contains a negative overlap.",
         call. = FALSE)
  }
  if (isTRUE(require_positive_diagonal) &&
      any(diag(symmetric) <= tolerance)) {
    stop("Operator `", matrix_id, "` needs positive diagonal concentration.",
         call. = FALSE)
  }
  eigenvalues <- eigen(symmetric, symmetric = TRUE, only.values = TRUE)$values
  minimum <- min(eigenvalues)
  psd <- minimum >= -tolerance
  if (!psd) {
    stop("Matrix `", matrix_id, "` is not positive semidefinite.",
         call. = FALSE)
  }
  scale <- max(1, max(abs(eigenvalues)))
  effective_rank <- sum(eigenvalues > tolerance * scale)
  list(
    Matrix = symmetric,
    Audit = data.frame(
      MatrixId = matrix_id, Dimension = length(strata),
      MaximumAsymmetry = asymmetry, MinimumEigenvalue = minimum,
      MaximumEigenvalue = max(eigenvalues), PositiveSemidefinite = psd,
      EffectiveRank = effective_rank,
      RankDeficient = effective_rank < length(strata),
      Tolerance = tolerance, stringsAsFactors = FALSE
    )
  )
}

mfrmr_gtv_overlap_operator <- function(
    allocation, strata, component_id, tolerance = 1e-10) {
  mfrmr_gtv_require_primitives()
  strata <- mfrmr_gtv_strata(strata)
  tolerance <- mfrmr_gtv_tolerance(tolerance)
  component_id <- as.character(component_id)
  required <- c("Stratum", "ConditionId", "Weight")
  if (!is.data.frame(allocation) || !all(required %in% names(allocation))) {
    stop("Allocation requires Stratum, ConditionId, and Weight columns.",
         call. = FALSE)
  }
  allocation <- allocation[required]
  allocation$Stratum <- as.character(allocation$Stratum)
  allocation$ConditionId <- as.character(allocation$ConditionId)
  allocation$Weight <- as.numeric(allocation$Weight)
  if (nrow(allocation) == 0L || anyNA(allocation) ||
      any(!allocation$Stratum %in% strata) ||
      any(!nzchar(allocation$ConditionId)) ||
      any(!is.finite(allocation$Weight)) || any(allocation$Weight <= 0)) {
    stop("Allocation rows must have known strata and positive finite weights.",
         call. = FALSE)
  }
  if (anyDuplicated(paste(allocation$Stratum, allocation$ConditionId,
                          sep = "\r"))) {
    stop("Allocation has duplicate Stratum/ConditionId rows.", call. = FALSE)
  }
  sums <- vapply(strata, function(stratum) {
    sum(allocation$Weight[allocation$Stratum == stratum])
  }, numeric(1L))
  counts <- vapply(strata, function(stratum) {
    sum(allocation$Stratum == stratum)
  }, integer(1L))
  if (any(counts == 0L) || any(abs(sums - 1) > tolerance)) {
    stop("Each stratum must have positive weights summing exactly to one.",
         call. = FALSE)
  }
  condition_ids <- sort(unique(allocation$ConditionId), method = "radix")
  weights <- matrix(
    0, nrow = length(strata), ncol = length(condition_ids),
    dimnames = list(strata, condition_ids)
  )
  weights[cbind(
    match(allocation$Stratum, strata),
    match(allocation$ConditionId, condition_ids)
  )] <- allocation$Weight
  operator <- weights %*% t(weights)
  audited <- mfrmr_gtv_matrix_audit(
    operator, strata, paste0("Operator/", component_id), tolerance,
    require_nonnegative_entries = TRUE, require_positive_diagonal = TRUE
  )
  shared_count <- outer(
    seq_along(strata), seq_along(strata),
    Vectorize(function(left, right) {
      sum(weights[left, ] > 0 & weights[right, ] > 0)
    })
  )
  dimnames(shared_count) <- list(strata, strata)
  result <- list(
    ComponentId = component_id,
    OperatorType = "explicit_weight_gram",
    Matrix = audited$Matrix,
    WeightMatrix = weights,
    SharedConditionCount = shared_count,
    Audit = audited$Audit,
    AllocationHash = mfrmr_gta_hash(allocation[order(
      match(allocation$Stratum, strata), allocation$ConditionId
    ), , drop = FALSE]),
    DecisionReady = FALSE
  )
  class(result) <- c("mfrmr_gtv_operator", "list")
  result
}

mfrmr_gtv_unscaled_operator <- function(
    strata, component_id = "Object", tolerance = 1e-10) {
  strata <- mfrmr_gtv_strata(strata)
  matrix <- base::matrix(
    1, nrow = length(strata), ncol = length(strata),
    dimnames = list(strata, strata)
  )
  audited <- mfrmr_gtv_matrix_audit(
    matrix, strata, paste0("Operator/", component_id), tolerance,
    require_nonnegative_entries = TRUE, require_positive_diagonal = TRUE
  )
  result <- list(
    ComponentId = component_id, OperatorType = "unscaled_common_object",
    Matrix = audited$Matrix, WeightMatrix = NULL,
    SharedConditionCount = NULL, Audit = audited$Audit,
    AllocationHash = NA_character_, DecisionReady = FALSE
  )
  class(result) <- c("mfrmr_gtv_operator", "list")
  result
}

mfrmr_gtv_operator_matrix <- function(operator) {
  if (inherits(operator, "mfrmr_gtv_operator")) operator$Matrix else operator
}

mfrmr_gtv_sum_matrices <- function(matrices, strata) {
  output <- matrix(
    0, nrow = length(strata), ncol = length(strata),
    dimnames = list(strata, strata)
  )
  for (matrix in matrices) output <- output + matrix
  output
}

mfrmr_gtv_spec <- function(
    strata, component_map, component_covariances, allocation_operators,
    tolerance = 1e-10) {
  mfrmr_gtv_require_primitives()
  strata <- mfrmr_gtv_strata(strata)
  tolerance <- mfrmr_gtv_tolerance(tolerance)
  required <- c("ComponentId", "UniverseRole")
  if (!is.data.frame(component_map) || !all(required %in% names(component_map))) {
    stop("Component map requires ComponentId and UniverseRole.", call. = FALSE)
  }
  component_map <- component_map[required]
  component_map$ComponentId <- as.character(component_map$ComponentId)
  component_map$UniverseRole <- as.character(component_map$UniverseRole)
  roles <- c("object", "relative_error", "absolute_only")
  if (nrow(component_map) == 0L || anyNA(component_map) ||
      any(!nzchar(component_map$ComponentId)) ||
      anyDuplicated(component_map$ComponentId) ||
      any(!component_map$UniverseRole %in% roles) ||
      sum(component_map$UniverseRole == "object") != 1L ||
      !any(component_map$UniverseRole == "relative_error")) {
    stop("Component roles need one object and at least one relative-error row.",
         call. = FALSE)
  }
  ids <- component_map$ComponentId
  if (!is.list(component_covariances) ||
      !identical(sort(names(component_covariances)), sort(ids)) ||
      !is.list(allocation_operators) ||
      !identical(sort(names(allocation_operators)), sort(ids))) {
    stop("Covariance and operator lists must match every component exactly.",
         call. = FALSE)
  }
  covariances <- vector("list", length(ids)); names(covariances) <- ids
  operators <- vector("list", length(ids)); names(operators) <- ids
  contributions <- vector("list", length(ids)); names(contributions) <- ids
  audits <- list()
  for (id in ids) {
    covariance_audit <- mfrmr_gtv_matrix_audit(
      component_covariances[[id]], strata, paste0("Covariance/", id), tolerance
    )
    operator_audit <- mfrmr_gtv_matrix_audit(
      mfrmr_gtv_operator_matrix(allocation_operators[[id]]), strata,
      paste0("Operator/", id), tolerance,
      require_nonnegative_entries = TRUE, require_positive_diagonal = TRUE
    )
    role <- component_map$UniverseRole[component_map$ComponentId == id]
    if (role == "object" &&
        max(abs(operator_audit$Matrix - 1)) > tolerance) {
      stop("The object covariance must use an unscaled all-ones operator.",
           call. = FALSE)
    }
    covariances[[id]] <- covariance_audit$Matrix
    operators[[id]] <- operator_audit$Matrix
    contributions[[id]] <- covariance_audit$Matrix * operator_audit$Matrix
    contribution_audit <- mfrmr_gtv_matrix_audit(
      contributions[[id]], strata, paste0("Contribution/", id), tolerance
    )
    audits[[length(audits) + 1L]] <- covariance_audit$Audit
    audits[[length(audits) + 1L]] <- operator_audit$Audit
    audits[[length(audits) + 1L]] <- contribution_audit$Audit
  }
  object_ids <- ids[component_map$UniverseRole == "object"]
  relative_ids <- ids[component_map$UniverseRole == "relative_error"]
  absolute_ids <- ids[component_map$UniverseRole == "absolute_only"]
  sigma_p <- mfrmr_gtv_sum_matrices(contributions[object_ids], strata)
  sigma_delta <- mfrmr_gtv_sum_matrices(contributions[relative_ids], strata)
  sigma_absolute <- sigma_delta +
    mfrmr_gtv_sum_matrices(contributions[absolute_ids], strata)
  totals <- list(
    SigmaP = sigma_p, SigmaRelativeError = sigma_delta,
    SigmaAbsoluteError = sigma_absolute
  )
  for (id in names(totals)) {
    audit <- mfrmr_gtv_matrix_audit(totals[[id]], strata, id, tolerance)
    totals[[id]] <- audit$Matrix
    audits[[length(audits) + 1L]] <- audit$Audit
  }
  result <- list(
    ContractVersion = "mfrmr-gtheory-multivariate-algebra-draft85a0-v1",
    Strata = strata, ComponentMap = component_map,
    ComponentCovariances = covariances, AllocationOperators = operators,
    ComponentContributions = contributions,
    SigmaP = totals$SigmaP,
    SigmaRelativeError = totals$SigmaRelativeError,
    SigmaAbsoluteError = totals$SigmaAbsoluteError,
    MatrixAudit = do.call(rbind, audits), Tolerance = tolerance,
    SpecificationHash = NA_character_, AlgebraReady = TRUE,
    EstimationReady = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )
  result$SpecificationHash <- mfrmr_gta_hash(list(
    ContractVersion = result$ContractVersion, Strata = strata,
    ComponentMap = component_map, ComponentCovariances = covariances,
    AllocationOperators = operators, Tolerance = tolerance
  ))
  class(result) <- c("mfrmr_gtv_spec", "list")
  result
}

mfrmr_gtv_quadratic <- function(matrix, weights) {
  as.numeric(crossprod(weights, matrix %*% weights))
}

mfrmr_gtv_composite <- function(
    spec, weights, weight_id = "Composite1",
    weight_policy = c("nonnegative_sum_one", "nonzero_linear_contrast"),
    tolerance = spec$Tolerance) {
  if (!inherits(spec, "mfrmr_gtv_spec")) {
    stop("`spec` must be a multivariate algebra specification.", call. = FALSE)
  }
  weight_policy <- match.arg(weight_policy)
  tolerance <- mfrmr_gtv_tolerance(tolerance)
  weight_names <- names(weights)
  weights <- as.numeric(weights)
  names(weights) <- weight_names
  if (length(weights) != length(spec$Strata) || any(!is.finite(weights)) ||
      !setequal(names(weights), spec$Strata)) {
    stop("Weights must be a finite named vector for every stratum.",
         call. = FALSE)
  }
  weights <- weights[spec$Strata]
  if (weight_policy == "nonnegative_sum_one") {
    if (any(weights < -tolerance) || abs(sum(weights) - 1) > tolerance) {
      stop("Composite weights must be nonnegative and sum to one.",
           call. = FALSE)
    }
  } else if (sum(weights^2) <= tolerance^2) {
    stop("Linear-contrast weights cannot all be zero.", call. = FALSE)
  }
  universe <- mfrmr_gtv_quadratic(spec$SigmaP, weights)
  relative <- mfrmr_gtv_quadratic(spec$SigmaRelativeError, weights)
  absolute <- mfrmr_gtv_quadratic(spec$SigmaAbsoluteError, weights)
  if (min(c(universe, relative, absolute)) < -tolerance) {
    stop("A quadratic variance contribution is negative beyond tolerance.",
         call. = FALSE)
  }
  g <- if (universe > tolerance && universe + relative > tolerance) {
    universe / (universe + relative)
  } else NA_real_
  phi <- if (universe > tolerance && universe + absolute > tolerance) {
    universe / (universe + absolute)
  } else NA_real_
  contributions <- data.frame(
    ComponentId = spec$ComponentMap$ComponentId,
    UniverseRole = spec$ComponentMap$UniverseRole,
    QuadraticContribution = vapply(
      spec$ComponentMap$ComponentId,
      function(id) mfrmr_gtv_quadratic(
        spec$ComponentContributions[[id]], weights
      ),
      numeric(1L)
    ),
    stringsAsFactors = FALSE
  )
  result <- list(
    WeightId = as.character(weight_id), WeightPolicy = weight_policy,
    Strata = spec$Strata, Weights = weights,
    UniverseVariance = universe, RelativeErrorVariance = relative,
    AbsoluteErrorVariance = absolute, G = g, Phi = phi,
    ComponentContributions = contributions,
    SpecificationHash = spec$SpecificationHash,
    ResultHash = mfrmr_gta_hash(list(
      SpecificationHash = spec$SpecificationHash, WeightId = weight_id,
      WeightPolicy = weight_policy, Weights = weights,
      UniverseVariance = universe, RelativeErrorVariance = relative,
      AbsoluteErrorVariance = absolute, G = g, Phi = phi,
      ComponentContributions = contributions
    )),
    AlgebraReady = is.finite(g) && is.finite(phi),
    EstimationReady = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )
  class(result) <- c("mfrmr_gtv_composite", "list")
  result
}

mfrmr_gtv_fixture_allocation <- function(sharing, component_id) {
  sharing <- match.arg(sharing, c("common", "partial", "independent"))
  conditions <- switch(
    sharing,
    common = list(A = c("R1", "R2"), B = c("R1", "R2")),
    partial = list(A = c("R1", "R2"), B = c("R2", "R3")),
    independent = list(A = c("R1", "R2"), B = c("R3", "R4"))
  )
  allocation <- do.call(rbind, lapply(names(conditions), function(stratum) {
    ids <- conditions[[stratum]]
    data.frame(
      Stratum = stratum, ConditionId = ids,
      Weight = rep(1 / length(ids), length(ids)), stringsAsFactors = FALSE
    )
  }))
  mfrmr_gtv_overlap_operator(allocation, c("A", "B"), component_id)
}

mfrmr_gtv_fixture <- function(
    sharing = c("common", "partial", "independent")) {
  sharing <- match.arg(sharing)
  strata <- c("A", "B")
  named_matrix <- function(values) {
    matrix(values, 2L, 2L, byrow = TRUE,
           dimnames = list(strata, strata))
  }
  component_map <- data.frame(
    ComponentId = c("Person", "Person:Rater", "Rater", "Residual"),
    UniverseRole = c(
      "object", "relative_error", "absolute_only", "relative_error"
    ),
    stringsAsFactors = FALSE
  )
  covariance <- list(
    Person = named_matrix(c(1.0, 0.4, 0.4, 0.8)),
    `Person:Rater` = named_matrix(c(0.6, 0.3, 0.3, 0.5)),
    Rater = named_matrix(c(0.2, 0.1, 0.1, 0.3)),
    Residual = named_matrix(c(0.4, 0.0, 0.0, 0.5))
  )
  residual_allocation <- data.frame(
    Stratum = rep(strata, each = 2L),
    ConditionId = c("A1", "A2", "B1", "B2"), Weight = 0.5,
    stringsAsFactors = FALSE
  )
  shared_operator <- mfrmr_gtv_fixture_allocation(sharing, "Rater")
  operators <- list(
    Person = mfrmr_gtv_unscaled_operator(strata, "Person"),
    `Person:Rater` = shared_operator,
    Rater = shared_operator,
    Residual = mfrmr_gtv_overlap_operator(
      residual_allocation, strata, "Residual"
    )
  )
  mfrmr_gtv_spec(strata, component_map, covariance, operators)
}
