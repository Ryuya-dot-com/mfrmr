# Draft.83c1 G-theory covariance-design, expected-information, and lme4 audit.
#
# Repository-internal only. Source the Draft.81 typed-design and Draft.83a
# incidence prototypes first. This file does not compute an interval or a
# D-study coefficient and never marks a result decision-ready.

mfrmr_gtc_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gta_split_facets",
    "mfrmr_gta_component_id", "mfrmr_gti_prepare",
    "mfrmr_gti_effective_values", "mfrmr_gti_key"
  )
  prototype_environment <- environment(mfrmr_gtc_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = prototype_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the Draft.81 and Draft.83a prototypes before Draft.83c1: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtc_validate_tolerance <- function(x, argument, positive = TRUE) {
  x <- as.numeric(x)
  valid <- length(x) == 1L && is.finite(x) &&
    if (positive) x > 0 else x >= 0
  if (!valid) {
    stop(argument, " must be one finite ",
         if (positive) "positive" else "nonnegative", " number.",
         call. = FALSE)
  }
  x
}

mfrmr_gtc_function_hash <- function(fun) {
  if (!is.function(fun)) {
    stop("A backend function identity could not be resolved.", call. = FALSE)
  }
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtc_bind_incidence <- function(spec, data, incidence_audit,
                                      missingness) {
  mfrmr_gtc_require_primitives()
  if (!inherits(spec, "mfrmr_gta_spec")) {
    stop("`spec` must be a Draft.81 typed design.", call. = FALSE)
  }
  if (!inherits(incidence_audit, "mfrmr_gti_audit")) {
    stop("`incidence_audit` must be a Draft.83a audit.", call. = FALSE)
  }
  if (!identical(spec$DesignHash, incidence_audit$DesignHash)) {
    stop("The incidence audit belongs to a different typed design.",
         call. = FALSE)
  }
  prepared <- mfrmr_gti_prepare(spec, data, missingness)
  expected <- c(
    DeclaredLevelHash = prepared$DeclaredLevelHash,
    CanonicalInputHash = prepared$CanonicalInputHash,
    RetainedDataHash = prepared$RetainedDataHash,
    OmissionPatternHash = prepared$OmissionPatternHash
  )
  observed <- c(
    DeclaredLevelHash = incidence_audit$DeclaredLevelHash,
    CanonicalInputHash = incidence_audit$CanonicalInputHash,
    RetainedDataHash = incidence_audit$RetainedDataHash,
    OmissionPatternHash = incidence_audit$OmissionPatternHash
  )
  if (!identical(expected, observed)) {
    stop(
      "The data, declared levels, or omission pattern do not match the ",
      "Draft.83a incidence audit.", call. = FALSE
    )
  }
  if (!identical(as.character(missingness),
                 incidence_audit$MissingnessMechanism)) {
    stop("The declared missingness mechanism differs from the incidence audit.",
         call. = FALSE)
  }
  prepared
}

mfrmr_gtc_group_key <- function(effect_row, effective, spec) {
  members <- mfrmr_gta_split_facets(effect_row$Members)
  if (length(members) == 0L || any(!members %in% names(effective))) {
    stop("A non-residual component has an unresolved grouping identity.",
         call. = FALSE)
  }
  mfrmr_gti_key(effective, members)
}

mfrmr_gtc_derivative_matrices <- function(spec, prepared) {
  n <- nrow(prepared$Data)
  if (n == 0L) {
    stop("Covariance-design auditing requires at least one retained row.",
         call. = FALSE)
  }
  effective <- mfrmr_gti_effective_values(
    prepared$Data, prepared$Factors, spec$NestingGraph
  )
  component_ids <- spec$EffectMap$ComponentId
  matrices <- vector("list", length(component_ids))
  names(matrices) <- component_ids
  grouping_levels <- integer(length(component_ids))
  group_min <- integer(length(component_ids))
  group_median <- numeric(length(component_ids))
  group_max <- integer(length(component_ids))
  for (index in seq_along(component_ids)) {
    component_id <- component_ids[[index]]
    if (identical(component_id, "Residual")) {
      matrices[[index]] <- diag(n)
      grouping_levels[[index]] <- n
      group_min[[index]] <- 1L
      group_median[[index]] <- 1
      group_max[[index]] <- 1L
      next
    }
    key <- mfrmr_gtc_group_key(spec$EffectMap[index, , drop = FALSE],
                               effective, spec)
    grouping <- factor(key)
    grouping_index <- as.integer(grouping)
    matrices[[index]] <- outer(
      grouping_index, grouping_index, FUN = "=="
    ) * 1
    counts <- table(grouping)
    grouping_levels[[index]] <- length(counts)
    group_min[[index]] <- min(counts)
    group_median[[index]] <- stats::median(counts)
    group_max[[index]] <- max(counts)
  }
  list(
    Matrices = matrices,
    EffectiveValues = effective,
    Grouping = data.frame(
      ComponentId = component_ids,
      GroupingLevels = grouping_levels,
      GroupObservationMin = group_min,
      GroupObservationMedian = group_median,
      GroupObservationMax = group_max,
      stringsAsFactors = FALSE
    )
  )
}

mfrmr_gtc_matrix_rank <- function(x, tolerance) {
  singular <- svd(x, nu = 0L, nv = min(nrow(x), ncol(x)))$d
  scale <- if (length(singular) == 0L) 0 else max(singular)
  threshold <- tolerance * max(1, scale)
  list(
    Rank = as.integer(sum(singular > threshold)),
    SingularValues = singular,
    Threshold = threshold
  )
}

mfrmr_gtc_null_space <- function(x, component_ids, tolerance,
                                  prefix = "N") {
  decomposition <- eigen(crossprod(x), symmetric = TRUE)
  singular <- sqrt(pmax(decomposition$values, 0))
  scale <- if (length(singular) == 0L) 0 else max(singular)
  rank <- sum(singular > tolerance * max(1, scale))
  if (rank >= ncol(x)) {
    return(data.frame(
      NullVector = character(), ComponentId = character(),
      Loading = numeric(), stringsAsFactors = FALSE
    ))
  }
  keep <- singular <= tolerance * max(1, scale)
  vectors <- decomposition$vectors[, keep, drop = FALSE]
  rows <- lapply(seq_len(ncol(vectors)), function(index) {
    direction <- vectors[, index]
    direction <- direction / max(abs(direction))
    data.frame(
      NullVector = paste0(prefix, index),
      ComponentId = component_ids,
      Loading = as.numeric(direction),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gtc_component_status <- function(component_ids, null_space,
                                        tolerance, identified, labels) {
  status <- rep.int(labels[[1L]], length(component_ids))
  if (!identified && nrow(null_space) > 0L) {
    involved <- vapply(component_ids, function(component_id) {
      any(abs(null_space$Loading[
        null_space$ComponentId == component_id
      ]) > sqrt(tolerance))
    }, logical(1L))
    status[involved] <- labels[[2L]]
  }
  status
}

mfrmr_gtc_covariance_design <- function(
    spec, data, incidence_audit,
    missingness = incidence_audit$MissingnessMechanism,
    rank_tolerance = 1e-9, max_matrix_cells = 5e6) {
  rank_tolerance <- mfrmr_gtc_validate_tolerance(
    rank_tolerance, "`rank_tolerance`"
  )
  max_matrix_cells <- mfrmr_gtc_validate_tolerance(
    max_matrix_cells, "`max_matrix_cells`"
  )
  prepared <- mfrmr_gtc_bind_incidence(
    spec, data, incidence_audit, missingness
  )
  component_ids <- spec$EffectMap$ComponentId
  n <- prepared$RetainedRows
  vech_rows <- n * (n + 1) / 2
  matrix_cells <- vech_rows * length(component_ids)
  if (matrix_cells > max_matrix_cells) {
    payload <- list(
      Contract = "gtheory_covariance_design_draft83c1_v1",
      DesignHash = spec$DesignHash,
      IncidenceAuditHash = incidence_audit$AuditHash,
      RetainedDataHash = prepared$RetainedDataHash,
      ComponentIds = component_ids,
      RetainedRows = n,
      VechRows = vech_rows,
      MatrixCells = matrix_cells,
      RankTolerance = rank_tolerance,
      MaxMatrixCells = max_matrix_cells,
      CapacityStatus = "not_evaluated_capacity"
    )
    return(structure(c(payload, list(
      ComponentAudit = data.frame(
        ComponentId = component_ids,
        StructuralStatus = "not_evaluated_capacity",
        stringsAsFactors = FALSE
      ),
      StructuralRank = NA_integer_, StructuralRankFull = FALSE,
      NullSpace = data.frame(), DerivativeMatrices = NULL,
      PreparedData = prepared, ResultHash = mfrmr_gta_hash(payload),
      EstimationEligibility = "not_adjudicated_capacity",
      CoefficientEligible = FALSE, DecisionReady = FALSE
    )), class = "mfrmr_gtc_covariance_design"))
  }

  derivatives <- mfrmr_gtc_derivative_matrices(spec, prepared)
  lower <- lower.tri(matrix(0, n, n), diag = TRUE)
  design <- do.call(cbind, lapply(derivatives$Matrices, function(x) x[lower]))
  colnames(design) <- component_ids
  rank <- mfrmr_gtc_matrix_rank(design, rank_tolerance)
  null_space <- mfrmr_gtc_null_space(
    design, component_ids, rank_tolerance, prefix = "C"
  )
  rank_full <- identical(rank$Rank, length(component_ids))
  component_audit <- merge(
    spec$EffectMap[c("ComponentId", "Members")], derivatives$Grouping,
    by = "ComponentId", sort = FALSE
  )
  component_audit <- component_audit[
    match(component_ids, component_audit$ComponentId), , drop = FALSE
  ]
  component_audit$DerivativeRank <- vapply(
    derivatives$Matrices,
    function(x) mfrmr_gtc_matrix_rank(x, rank_tolerance)$Rank,
    integer(1L)
  )
  component_audit$DerivativeHash <- vapply(
    derivatives$Matrices, mfrmr_gta_hash, character(1L)
  )
  component_audit$StructuralStatus <- mfrmr_gtc_component_status(
    component_ids, null_space, rank_tolerance, rank_full,
    c("structurally_independent", "structurally_confounded")
  )
  row.names(component_audit) <- NULL
  payload <- list(
    Contract = "gtheory_covariance_design_draft83c1_v1",
    DesignHash = spec$DesignHash,
    IncidenceAuditHash = incidence_audit$AuditHash,
    RetainedDataHash = prepared$RetainedDataHash,
    ComponentAudit = component_audit,
    RetainedRows = n,
    VechRows = vech_rows,
    MatrixCells = matrix_cells,
    CovarianceDesignHash = mfrmr_gta_hash(design),
    StructuralRank = rank$Rank,
    StructuralDimension = length(component_ids),
    StructuralRankFull = rank_full,
    StructuralThreshold = rank$Threshold,
    StructuralSingularValues = rank$SingularValues,
    NullSpace = null_space,
    RankTolerance = rank_tolerance,
    MaxMatrixCells = max_matrix_cells,
    CapacityStatus = "evaluated"
  )
  structure(c(payload, list(
    DerivativeMatrices = derivatives$Matrices,
    PreparedData = prepared,
    ResultHash = mfrmr_gta_hash(payload),
    EstimationEligibility = if (rank_full) {
      "structural_covariance_screen_passed_information_pending"
    } else {
      "structural_covariance_confounding"
    },
    CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtc_covariance_design")
}

mfrmr_gtc_variance_point <- function(variance_point, component_ids) {
  if (!is.numeric(variance_point) || is.null(names(variance_point)) ||
      anyNA(names(variance_point)) || any(!nzchar(names(variance_point))) ||
      anyDuplicated(names(variance_point))) {
    stop("`variance_point` must be a uniquely named numeric vector.",
         call. = FALSE)
  }
  if (!setequal(names(variance_point), component_ids)) {
    stop("The variance point must match every covariance component exactly.",
         call. = FALSE)
  }
  out <- as.numeric(variance_point[component_ids])
  names(out) <- component_ids
  if (anyNA(out) || any(!is.finite(out)) || any(out < 0)) {
    stop("Variance coordinates must be finite and nonnegative.",
         call. = FALSE)
  }
  out
}

mfrmr_gtc_information_null <- function(information, component_ids,
                                        tolerance, prefix) {
  decomposition <- eigen(
    (information + t(information)) / 2, symmetric = TRUE
  )
  threshold <- tolerance * max(1, max(abs(decomposition$values)))
  keep <- decomposition$values <= threshold
  if (!any(keep)) {
    return(data.frame(
      NullVector = character(), ComponentId = character(),
      Loading = numeric(), stringsAsFactors = FALSE
    ))
  }
  vectors <- decomposition$vectors[, keep, drop = FALSE]
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

mfrmr_gtc_information <- function(
    covariance_design, variance_point, rank_tolerance = 1e-9,
    boundary_tolerance = 1e-10, pd_tolerance = 1e-10) {
  if (!inherits(covariance_design, "mfrmr_gtc_covariance_design")) {
    stop("`covariance_design` must be a Draft.83c1 covariance audit.",
         call. = FALSE)
  }
  if (!identical(covariance_design$CapacityStatus, "evaluated")) {
    stop("Expected information requires an evaluated covariance design.",
         call. = FALSE)
  }
  rank_tolerance <- mfrmr_gtc_validate_tolerance(
    rank_tolerance, "`rank_tolerance`"
  )
  boundary_tolerance <- mfrmr_gtc_validate_tolerance(
    boundary_tolerance, "`boundary_tolerance`", positive = FALSE
  )
  pd_tolerance <- mfrmr_gtc_validate_tolerance(
    pd_tolerance, "`pd_tolerance`"
  )
  component_ids <- covariance_design$ComponentAudit$ComponentId
  variance_point <- mfrmr_gtc_variance_point(
    variance_point, component_ids
  )
  matrices <- covariance_design$DerivativeMatrices
  v <- Reduce(`+`, Map(function(weight, matrix) weight * matrix,
                       variance_point, matrices))
  v <- (v + t(v)) / 2
  v_eigen <- eigen(v, symmetric = TRUE, only.values = TRUE)$values
  pd_threshold <- pd_tolerance * max(1, max(abs(v_eigen)))
  if (min(v_eigen) <= pd_threshold) {
    stop("The declared variance point does not produce a positive-definite V.",
         call. = FALSE)
  }
  v_inverse <- chol2inv(chol(v))
  n <- nrow(v)
  x <- matrix(1, n, 1L)
  xtvix <- as.numeric(crossprod(x, v_inverse %*% x))
  if (!is.finite(xtvix) || xtvix <= 0) {
    stop("The intercept information is not positive.", call. = FALSE)
  }
  p <- v_inverse - v_inverse %*% x %*% t(x) %*% v_inverse / xtvix
  operators <- list(ML = v_inverse, REML = p)
  information_matrices <- list()
  summaries <- list()
  null_spaces <- list()
  component_rows <- list()
  for (method in names(operators)) {
    operator <- operators[[method]]
    information <- matrix(
      0, length(component_ids), length(component_ids),
      dimnames = list(component_ids, component_ids)
    )
    for (left in seq_along(component_ids)) {
      for (right in seq.int(left, length(component_ids))) {
        value <- 0.5 * sum(
          (operator %*% matrices[[left]]) *
            t(operator %*% matrices[[right]])
        )
        information[left, right] <- value
        information[right, left] <- value
      }
    }
    information <- (information + t(information)) / 2
    values <- eigen(information, symmetric = TRUE, only.values = TRUE)$values
    threshold <- rank_tolerance * max(1, max(abs(values)))
    rank <- as.integer(sum(values > threshold))
    full <- identical(rank, length(component_ids))
    positive <- values[values > threshold]
    condition <- if (length(positive) == 0L) Inf else
      max(positive) / min(positive)
    null_space <- mfrmr_gtc_information_null(
      information, component_ids, rank_tolerance,
      prefix = paste0(substr(method, 1L, 1L), "I")
    )
    summaries[[method]] <- data.frame(
      Method = method, InformationRank = rank,
      InformationDimension = length(component_ids),
      InformationRankFull = full,
      MinimumEigenvalue = min(values),
      MaximumEigenvalue = max(values),
      PositiveConditionNumber = condition,
      InformationThreshold = threshold,
      stringsAsFactors = FALSE
    )
    component_rows[[method]] <- data.frame(
      Method = method,
      ComponentId = component_ids,
      InformationStatus = mfrmr_gtc_component_status(
        component_ids, null_space, rank_tolerance, full,
        c("locally_informative", "locally_information_confounded")
      ),
      stringsAsFactors = FALSE
    )
    information_matrices[[method]] <- information
    null_spaces[[method]] <- null_space
  }
  summary <- do.call(rbind, summaries)
  row.names(summary) <- NULL
  component_audit <- do.call(rbind, component_rows)
  row.names(component_audit) <- NULL
  regular_interior <- all(variance_point > boundary_tolerance)
  payload <- list(
    Contract = "gtheory_expected_information_draft83c1_v1",
    CovarianceDesignHash = covariance_design$ResultHash,
    VariancePoint = variance_point,
    VariancePointHash = mfrmr_gta_hash(variance_point),
    RegularInterior = regular_interior,
    BoundaryTolerance = boundary_tolerance,
    PositiveDefiniteThreshold = pd_threshold,
    MinimumVarianceCovarianceEigenvalue = min(v_eigen),
    InformationSummary = summary,
    ComponentAudit = component_audit,
    InformationHashes = vapply(
      information_matrices, mfrmr_gta_hash, character(1L)
    ),
    NullSpaces = null_spaces,
    RankTolerance = rank_tolerance
  )
  structure(c(payload, list(
    InformationMatrices = information_matrices,
    ResultHash = mfrmr_gta_hash(payload),
    InformationScreenPassed = covariance_design$StructuralRankFull &&
      all(summary$InformationRankFull),
    RegularityScreenPassed = regular_interior,
    InferenceReady = FALSE,
    CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtc_information")
}

mfrmr_gtc_lme4_diagnostics <- function(fit, warnings, messages,
                                        zero_components,
                                        singular_tolerance) {
  optinfo <- fit@optinfo
  opt_code <- optinfo$conv$opt
  if (is.null(opt_code) || length(opt_code) == 0L) opt_code <- 0L
  opt_code <- as.integer(opt_code[[1L]])
  convergence_messages <- as.character(unlist(
    optinfo$conv$lme4$messages, use.names = FALSE
  ))
  convergence_messages <- convergence_messages[nzchar(convergence_messages)]
  nonboundary_messages <- convergence_messages[!grepl(
    "boundary|singular", convergence_messages, ignore.case = TRUE
  )]
  gradient <- suppressWarnings(as.numeric(optinfo$derivs$gradient))
  max_gradient <- if (length(gradient) > 0L && all(is.finite(gradient))) {
    max(abs(gradient))
  } else NA_real_
  hessian <- optinfo$derivs$Hessian
  minimum_hessian_eigenvalue <- if (is.matrix(hessian) &&
                                      all(is.finite(hessian))) {
    min(eigen((hessian + t(hessian)) / 2, symmetric = TRUE,
              only.values = TRUE)$values)
  } else NA_real_
  singular <- tryCatch(
    isTRUE(lme4::isSingular(fit, tol = singular_tolerance)),
    error = function(error) NA
  )
  optimizer_warning <- opt_code != 0L || length(nonboundary_messages) > 0L
  status <- if (optimizer_warning) {
    "optimizer_warning"
  } else if (isTRUE(singular) || any(zero_components)) {
    "boundary_or_singular"
  } else if (is.na(singular)) {
    "singularity_check_unavailable"
  } else {
    "identified"
  }
  data.frame(
    FitStatus = status,
    OptimizerCode = opt_code,
    Singular = singular,
    SingularTolerance = singular_tolerance,
    ZeroComponentCount = sum(zero_components),
    MaximumAbsoluteGradient = max_gradient,
    MinimumHessianEigenvalue = minimum_hessian_eigenvalue,
    WarningCount = length(warnings),
    MessageCount = length(messages),
    ConvergenceMessageCount = length(convergence_messages),
    Warnings = paste(warnings, collapse = " | "),
    Messages = paste(messages, collapse = " | "),
    ConvergenceMessages = paste(convergence_messages, collapse = " | "),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtc_lme4 <- function(
    spec, data, incidence_audit,
    missingness = incidence_audit$MissingnessMechanism,
    reml = TRUE, rank_tolerance = 1e-9,
    zero_tolerance = 1e-10, singular_tolerance = 1e-4,
    max_matrix_cells = 5e6) {
  if (!requireNamespace("lme4", quietly = TRUE)) {
    stop("Draft.83c1 lme4 estimation requires the suggested `lme4` package.",
         call. = FALSE)
  }
  zero_tolerance <- mfrmr_gtc_validate_tolerance(
    zero_tolerance, "`zero_tolerance`", positive = FALSE
  )
  singular_tolerance <- mfrmr_gtc_validate_tolerance(
    singular_tolerance, "`singular_tolerance`", positive = FALSE
  )
  covariance_design <- mfrmr_gtc_covariance_design(
    spec, data, incidence_audit, missingness = missingness,
    rank_tolerance = rank_tolerance,
    max_matrix_cells = max_matrix_cells
  )
  if (!identical(covariance_design$CapacityStatus, "evaluated")) {
    stop("lme4 fitting is blocked because the covariance audit hit capacity.",
         call. = FALSE)
  }
  prepared <- covariance_design$PreparedData
  formula <- stats::as.formula(spec$FormulaCanonical)
  control <- lme4::lmerControl()
  warnings <- character()
  messages <- character()
  fit <- tryCatch(
    withCallingHandlers(
      lme4::lmer(
        formula, data = prepared$Data, REML = isTRUE(reml),
        control = control
      ),
      warning = function(warning) {
        warnings <<- c(warnings, conditionMessage(warning))
        invokeRestart("muffleWarning")
      },
      message = function(message) {
        messages <<- c(messages, conditionMessage(message))
        invokeRestart("muffleMessage")
      }
    ),
    error = function(error) error
  )
  if (inherits(fit, "error")) {
    stop("lme4::lmer failed: ", conditionMessage(fit), call. = FALSE)
  }
  vc <- as.data.frame(lme4::VarCorr(fit))
  vc <- vc[is.na(vc$var2), c("grp", "vcov"), drop = FALSE]
  declared <- c(spec$ObjectFacet, spec$RandomFacets, spec$FixedFacets)
  component_id <- vapply(as.character(vc$grp), function(group) {
    if (identical(group, "Residual")) return("Residual")
    mfrmr_gta_component_id(
      strsplit(group, ":", fixed = TRUE)[[1L]], declared
    )
  }, character(1L))
  if (anyDuplicated(component_id)) {
    stop("lme4 returned duplicate semantic variance components.",
         call. = FALSE)
  }
  estimate <- stats::setNames(as.numeric(vc$vcov), component_id)
  required_ids <- spec$EffectMap$ComponentId
  if (!setequal(names(estimate), required_ids)) {
    stop(
      "lme4 variance-component identities do not match the typed effect map.",
      call. = FALSE
    )
  }
  estimate <- estimate[required_ids]
  zero_components <- estimate <= zero_tolerance
  components <- merge(
    spec$EffectMap,
    covariance_design$ComponentAudit[
      c("ComponentId", "GroupingLevels", "StructuralStatus")
    ],
    by = "ComponentId", sort = FALSE
  )
  components <- components[
    match(required_ids, components$ComponentId), , drop = FALSE
  ]
  components$Estimate <- as.numeric(estimate)
  components$EstimatorFamily <- if (isTRUE(reml)) {
    "lme4_reml"
  } else {
    "lme4_ml"
  }
  components$ConstraintIdentity <- "nonnegative_variance_parameterization"
  components$BoundaryState <- ifelse(
    zero_components, "constrained_zero_boundary", "interior_constrained"
  )
  components$InferenceStatus <- "point_only_no_interval"
  row.names(components) <- NULL
  diagnostics <- mfrmr_gtc_lme4_diagnostics(
    fit, warnings, messages, zero_components, singular_tolerance
  )
  information <- mfrmr_gtc_information(
    covariance_design, estimate, rank_tolerance = rank_tolerance,
    boundary_tolerance = zero_tolerance
  )
  selected_method <- if (isTRUE(reml)) "REML" else "ML"
  selected_information <- information$InformationSummary[
    information$InformationSummary$Method == selected_method, , drop = FALSE
  ]
  fit_qualification <- if (!incidence_audit$IncidenceScreenPassed) {
    "incidence_screen_failed"
  } else if (!covariance_design$StructuralRankFull) {
    "structural_covariance_confounding"
  } else if (!selected_information$InformationRankFull) {
    paste0(tolower(selected_method), "_information_rank_deficient")
  } else if (!information$RegularInterior) {
    "boundary_nonregular"
  } else if (!identical(diagnostics$FitStatus, "identified")) {
    paste0("lme4_", diagnostics$FitStatus)
  } else {
    "point_estimation_gate_passed"
  }
  varcorr_method <- getFromNamespace("VarCorr.merMod", "lme4")
  control_identity <- list(
    Optimizer = as.character(control$optimizer),
    RestartEdge = isTRUE(control$restart_edge),
    BoundaryTolerance = as.numeric(control$boundary.tol),
    CalculateDerivatives = if (is.null(control$calc.derivs)) {
      "backend_default_null"
    } else {
      isTRUE(control$calc.derivs)
    },
    UseLastParameters = isTRUE(control$use.last.params),
    CheckControlHash = mfrmr_gta_hash(control$checkControl),
    CheckConvergenceHash = mfrmr_gta_hash(control$checkConv),
    OptimizerControlHash = mfrmr_gta_hash(control$optCtrl)
  )
  backend_function_hashes <- c(
    lmer = mfrmr_gtc_function_hash(lme4::lmer),
    VarCorrMerMod = mfrmr_gtc_function_hash(varcorr_method),
    isSingular = mfrmr_gtc_function_hash(lme4::isSingular),
    lmerControl = mfrmr_gtc_function_hash(lme4::lmerControl)
  )
  estimator_identity <- list(
    Family = if (isTRUE(reml)) "lme4_reml" else "lme4_ml",
    Backend = "lme4",
    BackendVersion = as.character(utils::packageVersion("lme4")),
    Method = selected_method,
    Constraints = "variance_components_nonnegative",
    FormulaCanonical = paste(deparse(formula, width.cutoff = 500L),
                             collapse = " "),
    Response = "Gaussian_observed_score",
    RowContract = "draft83a_retained_rows_exact",
    RandomEffects = "independent_exchangeable_random_intercepts",
    FixedEffects = "intercept_only",
    Control = control_identity,
    BackendFunctionHashes = backend_function_hashes,
    Interval = "none"
  )
  payload <- list(
    Contract = "gtheory_lme4_fit_draft83c1_v1",
    DesignHash = spec$DesignHash,
    IncidenceAuditHash = incidence_audit$AuditHash,
    RetainedDataHash = prepared$RetainedDataHash,
    CovarianceDesignHash = covariance_design$ResultHash,
    ExpectedInformationHash = information$ResultHash,
    EstimatorIdentity = estimator_identity,
    Components = components,
    FitDiagnostics = diagnostics,
    SelectedInformation = selected_information,
    FitQualification = fit_qualification
  )
  structure(c(payload, list(
    ResultHash = mfrmr_gta_hash(payload),
    Spec = spec,
    PreparedData = prepared,
    BackendFit = fit,
    CovarianceDesign = covariance_design,
    ExpectedInformation = information,
    PointEstimateAvailable = TRUE,
    EstimationGatePassed = identical(
      fit_qualification, "point_estimation_gate_passed"
    ),
    InferenceReady = FALSE,
    CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtc_lme4_fit")
}
