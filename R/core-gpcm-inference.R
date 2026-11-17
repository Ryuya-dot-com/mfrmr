# Conditional responses share the fitted free coordinates with inference.
# Prediction may combine known levels absent from the estimation design; it
# does not add such crossings to the fitted slope design or certify inference.
mfrm_gpcm_response_evaluator <- function(prep, config, newdata) {
  if (identical(config$estimation_control$optimization_status, "not_run_boundary"))
    stop("The full model was not optimized because no finite maximum exists. Its neutral reference values cannot supply fitted curves. Use fit$point_limit$fit, when available, for retained rating contexts.", call. = FALSE)
  if (length(mfrmr_mml_additive_boundary_evidence(config)))
    stop("The full model has no finite maximum along a free location or endpoint path. Optimizer values cannot supply fitted curves. Use a separately supported limiting fit when available.", call. = FALSE)
  facets <- config$facet_names
  required <- c("Theta", facets)
  if ("Theta" %in% facets || !is.data.frame(newdata) || !nrow(newdata) ||
      anyDuplicated(names(newdata)) || !all(required %in% names(newdata)) ||
      !is.numeric(newdata$Theta) || is.complex(newdata$Theta) || any(!is.finite(newdata$Theta))) {
    stop("`newdata` needs finite numeric Theta and every non-Person facet column; Theta is reserved for ability.", call. = FALSE)
  }
  newdata <- as.data.frame(newdata[required], check.names = FALSE)
  query <- prep
  query$data <- data.frame(Person = factor(rep(prep$levels$Person[1], nrow(newdata)),
    levels = prep$levels$Person), score_k = 0L, Weight = 1)
  for (facet in facets) {
    values <- as.character(newdata[[facet]])
    if (anyNA(values) || any(!values %in% prep$levels[[facet]])) {
      stop("Unknown or missing level in facet ", facet, "; levels must be present in the fit.", call. = FALSE)
    }
    query$data[[facet]] <- factor(values, levels = prep$levels[[facet]])
  }
  key <- function(data) do.call(paste, c(unname(lapply(data[facets], as.integer)), sep = ":"))
  contexts <- data.frame(InputRow = seq_len(nrow(newdata)),
    ObservedContext = key(query$data) %in% key(prep$data))
  # Location and interaction indices need no fitted crossing index: prediction
  # slopes are assembled from the fitted component levels below.
  idx <- build_indices(query, config$step_facet, interaction_specs = config$interaction_specs)
  sizes <- build_param_sizes(config)
  evaluate <- function(par) {
    if (length(par) != sum(unlist(sizes)) || any(!is.finite(par))) stop("Invalid parameter vector.")
    params <- expand_params(par, sizes, config)
    components <- setNames(lapply(config$slope_facet, function(owner) {
      values <- if (length(config$slope_facet) == 1L) params$slopes else
        params$slope_components[[owner]]$Slope
      unname(values[idx$facets[[owner]]])
    }), config$slope_facet)
    slope <- Reduce(`*`, components)
    if (any(!is.finite(slope) | slope <= 0)) stop("Predicted slopes must be finite and positive.")
    cumulative <- t(apply(params$steps_mat, 1L, function(s) c(0, cumsum(s))))
    predictor_offset <- compute_base_eta(idx, params, config)
    bundle <- mfrm_jml_probability_bundle(
      eta = newdata$Theta + predictor_offset,
      score_k = rep(0L, nrow(newdata)), model = "GPCM", step_cum = cumulative,
      criterion_idx = idx$step_idx, slopes = slope, slope_idx = seq_len(nrow(newdata)),
      include_log_probs = TRUE)
    if (any(!is.finite(bundle$log_probs))) stop("Predicted log probabilities are not finite.")
    colnames(bundle$probs) <- colnames(bundle$log_probs) <- as.character(seq_len(config$n_cat) - 1L)
    variance <- mfrm_category_variance(bundle$probs)
    list(probabilities = bundle$probs, log_probabilities = bundle$log_probs,
      slope_components = components, effective_slope = slope, variance = variance,
      predictor_offset = predictor_offset, step_cum = cumulative[idx$step_idx, , drop = FALSE],
      information = slope^2 * variance)
  }
  list(newdata = newdata, contexts = contexts, evaluate = evaluate)
}

mfrm_gpcm_anchor_note <- function(fit) {
  if (!nrow(mfrmr_calibration_extract_anchors(fit))) return(NULL)
  paste("Conditional on supplied anchors and group means;",
    "uncertainty in their source calibration is not propagated.")
}

# Joint information and transformations shared by slope/curve inference.
mfrm_gpcm_inference_source <- function(fit) {
  out <- list(signature = normalize_compare_signature(fit), parameters = fit$opt$par,
    objective = fit$opt$value, convergence = fit$opt$convergence,
    data = fit$prep$data, levels = fit$prep$levels,
    population = mfrm_population_design(fit),
    integration = fit$config$estimation_control[c("quad_points", "mml_integration")])
  if (identical(fit$config$gpcm_limit_source$kind,"global_endpoint"))
    out$limiting_source <- fit$config$gpcm_limit_source
  out
}

mfrm_gpcm_inference <- function(fit, method = "model", clusters = NULL, adjust = FALSE) {
  if (!inherits(fit, "mfrm_fit") || inherits(fit, "mfrm_imported_fit") ||
      !identical(fit$config$model, "GPCM") || !identical(fit$config$method, "MML")) {
    stop("Supply a native GPCM MML fit.", call. = FALSE)
  }
  method <- match.arg(method, c("model", "sandwich"))
  if (!is.logical(adjust) || length(adjust) != 1L || is.na(adjust)) stop("`adjust` must be TRUE or FALSE.", call. = FALSE)
  if (method == "model" && (!is.null(clusters) || adjust)) stop("`clusters` and `adjust` require method = 'sandwich'.", call. = FALSE)
  if (mfrm_has_product_slopes(fit) || !is.null(fit$config$gpcm_limit_source)) {
    if (method != "model" || !is.null(clusters) || adjust) {
      stop("Two-family curves do not yet support covariance methods or uncertainty adjustments.", call. = FALSE)
    }
    return(list(covariance = NULL, information = NULL, method = method, clusters = NULL,
      check = list(eligible = FALSE, review = paste(
        if (!is.null(fit$config$gpcm_limit_source))
          "Limiting-likelihood fitted values; ordinary intervals after a data-dependent reduction are not qualified." else
          "Provisional two-family fitted values; curve intervals are not available.",
        "Numerical convergence does not establish identification or inferential reliability."))))
  }
  information <- compute_mml_parameter_covariance(fit)
  check <- mfrm_gpcm_slope_inference_check(fit, information)
  out <- list(covariance = information$cov, information = information, check = check,
              method = method, clusters = NULL, person_scores = NULL, cluster_scores = NULL)
  if (isTRUE(check$eligible) && method == "sandwich") {
    scores <- mfrm_mml_person_scores_numeric(fit)
    sandwich <- mfrm_cluster_sandwich(information$cov, scores, clusters, adjust)
    out$covariance <- sandwich$covariance
    out$person_scores <- scores
    out$cluster_scores <- sandwich$cluster_scores
    out$clusters <- sandwich$clusters
    out$cluster_rank <- sandwich$rank
    out$adjustment_factor <- sandwich$factor
    if (sandwich$rank < ncol(scores)) {
      out$check <- list(eligible = FALSE,
        review = "Independent-cluster scores do not span the free parameters; sandwich intervals are unavailable.")
    } else out$check$review <- paste(
      "Independent-cluster sandwich approximation for the working-model target.",
      "It requires many independent clusters and does not correct biased estimates or selective assignment.")
  }
  out$check$anchor_note <- mfrm_gpcm_anchor_note(fit)
  if (length(out$check$anchor_note) && method == "sandwich" && isTRUE(check$eligible)) {
    out$check$review <- paste(out$check$review, out$check$anchor_note)
  }
  out
}

mfrm_mml_person_scores_numeric <- function(fit, relative_step = 1e-5) {
  config <- fit$config
  sizes <- build_param_sizes(config)
  idx <- build_indices(fit$prep, config$step_facet, config$slope_facet, config$interaction_specs,
                       gpcm_spec = config$gpcm_spec)
  quad <- gauss_hermite_normal(config$estimation_control$quad_points)
  marginal <- function(par) {
    params <- expand_params(par, sizes, config)
    bundle <- mfrm_mml_logprob_bundle(idx, config, quad, params, compute_base_eta(idx, params, config))
    person <- mfrm_mml_person_bundle(bundle$log_prob_mat, bundle$person_int, bundle$quad_basis)
    person$log_marginal[match(seq_len(config$n_person), person$person_ids)]
  }
  jac <- mfrmr_numeric_transformation_jacobian(marginal, fit$opt$par, relative_step = relative_step)
  if (!jac$valid) stop("Person marginal-likelihood derivatives are unavailable.", call. = FALSE)
  scores <- jac$jacobian
  cache <- make_param_cache(sizes, config, idx, is_mml = TRUE)
  ev <- make_mfrm_direct_evaluator("MML", cache, idx, config, sizes, quad)
  if (max(abs(colSums(scores) + ev$gradient(fit$opt$par))) >
      1e-6 * max(1, max(colSums(abs(scores))))) {
    stop("Person likelihood scores do not reproduce the fitted objective gradient.", call. = FALSE)
  }
  dimnames(scores) <- list(fit$prep$levels$Person, mfrm_checkpoint_parameter_names(sizes))
  scores
}

mfrm_sandwich_clusters <- function(ids, clusters) {
  if (is.null(clusters)) clusters <- data.frame(Person = ids, Cluster = ids)
  if (!is.data.frame(clusters) || anyDuplicated(names(clusters)) ||
      !all(c("Person", "Cluster") %in% names(clusters)) || nrow(clusters) != length(ids) ||
      anyNA(clusters[c("Person", "Cluster")]) || anyDuplicated(as.character(clusters$Person)) ||
      !setequal(as.character(clusters$Person), ids) ||
      any(!nzchar(trimws(as.character(clusters$Cluster))))) {
    stop("`clusters` must map every fitted Person exactly once to one nonmissing Cluster.", call. = FALSE)
  }
  clusters <- data.frame(Person = ids, Cluster = as.character(clusters$Cluster[match(ids, clusters$Person)]))
  if (length(unique(clusters$Cluster)) < 2L)
    stop("Sandwich inference needs at least two independent clusters.", call. = FALSE)
  clusters
}

mfrm_cluster_sandwich <- function(bread, scores, clusters, adjust) {
  clusters <- mfrm_sandwich_clusters(rownames(scores), clusters)
  cluster_scores <- rowsum(scores, clusters$Cluster, reorder = FALSE)
  n <- nrow(cluster_scores)
  scale <- sqrt(colSums(cluster_scores^2))
  nonzero <- scale > 0
  rank <- if (!any(nonzero)) 0L else qr(sweep(cluster_scores[, nonzero, drop = FALSE],
    2, scale[nonzero], "/"), tol = 1e-10)$rank
  factor <- if (adjust) n/(n-1) else 1
  covariance <- symmetrize_matrix(bread %*% crossprod(cluster_scores) %*% bread) * factor
  if (any(!is.finite(covariance))) stop("The sandwich covariance is not finite.", call. = FALSE)
  list(covariance = covariance, cluster_scores = cluster_scores, clusters = clusters,
       rank = rank, factor = factor)
}

mfrm_gpcm_slope_target <- function(fit, scale, contrasts, contrast_scale) {
  labels <- as.character(fit$config$gpcm_spec$levels)
  sizes <- build_param_sizes(fit$config)
  slices <- build_param_slices(sizes)
  par <- fit$opt$par
  jac <- matrix(0, length(labels), length(par))
  jac[, slices[["log_slopes"]]] <- sum_zero_jacobian(length(labels))
  if (scale == "standardized" && length(slices[["log_sigma2"]])) jac[, slices[["log_sigma2"]]] <- .5
  log_estimate <- drop(jac %*% par)
  if (is.null(contrasts)) {
    coefficients <- diag(length(labels)); dimnames(coefficients) <- list(labels, labels)
  } else {
    coefficients <- contrasts
    if (!is.matrix(coefficients) || !is.numeric(coefficients) || is.complex(coefficients) ||
        !nrow(coefficients) || ncol(coefficients) != length(labels) || any(!is.finite(coefficients)) ||
        is.null(colnames(coefficients)) || anyDuplicated(colnames(coefficients)) ||
        !setequal(colnames(coefficients), labels) || is.null(rownames(coefficients)) ||
        anyNA(rownames(coefficients)) || any(!nzchar(rownames(coefficients))) || anyDuplicated(rownames(coefficients)) ||
        any(rowSums(abs(coefficients)) == 0) || any(abs(rowSums(coefficients)) > 1e-10)) {
      stop("`contrasts` needs distinct target row names, every slope-level column, and finite nonzero rows summing to zero.", call. = FALSE)
    }
    coefficients <- coefficients[, labels, drop = FALSE]
  }
  log_scale <- is.null(contrasts) || contrast_scale == "ratio"
  if (log_scale) {
    estimate <- drop(coefficients %*% log_estimate)
    jac <- coefficients %*% jac
  } else {
    estimate <- drop(coefficients %*% exp(log_estimate))
    jac <- coefficients %*% (exp(log_estimate) * jac)
  }
  list(value = estimate, estimate = if (log_scale) exp(estimate) else estimate,
    jacobian = jac, labels = rownames(coefficients), log_scale = log_scale,
    contrasts = coefficients, scale = scale,
    target = paste(if (is.null(contrasts)) paste(scale, "GPCM slopes") else
      paste(scale, "GPCM slope", if (log_scale) "ratios" else "differences")))
}

# Internal reuse accepts an already qualified covariance for this same fit.
# The public confint() route always performs a fresh qualification.
mfrm_gpcm_step_source <- function(fit) {
  list(calibration = mfrm_gpcm_inference_source(fit), steps = fit$steps,
    constraints = mfrmr_step_specs(fit$config), limiting_source = fit$config$gpcm_limit_source,
    converged = fit$summary$Converged, optimizer_review = fit$opt$optimizer_diagnostics)
}

mfrm_gpcm_step_intervals <- function(fit, level = .95, inference = NULL) {
  if (!inherits(fit, "mfrm_fit") || inherits(fit, "mfrm_imported_fit") ||
      !mfrm_has_product_slopes(fit) || !identical(fit$config$method, "MML"))
    stop("Step intervals require a native two-family GPCM MML fit.", call. = FALSE)
  cfg <- fit$config
  if (!identical(mfrmr_step_specs(cfg), mfrmr_default_step_specs(cfg)))
    stop("Two-family step intervals require the fitted unanchored sum-zero step constraints.", call. = FALSE)
  sizes <- build_param_sizes(cfg)
  expected <- build_step_table(cfg, fit$prep, expand_params(fit$opt$par, sizes, cfg))
  if (!isTRUE(all.equal(fit$steps[c("StepFacet", "Step", "Estimate")], expected,
      tolerance = 1e-10, check.attributes = FALSE)))
    stop("Saved steps must match the fitted two-family parameters and level order.", call. = FALSE)
  if (is.null(inference)) inference <- mfrm_gpcm_product_inference(fit)
  n <- nrow(expected)
  labels <- make.unique(paste(cfg$step_facet, expected$StepFacet, expected$Step, sep = " = "))
  J <- matrix(0, n, length(fit$opt$par),
    dimnames = list(labels, mfrm_checkpoint_parameter_names(sizes)))
  slice <- build_param_slices(sizes)$steps
  if (length(slice)) J[, slice] <- as.matrix(mfrmr_step_jacobian_sparse(cfg, sizes)$jacobian)
  fixed <- rowSums(abs(J)) == 0
  V <- inference$covariance
  covariance <- if (isTRUE(inference$check$eligible))
    symmetrize_matrix(J %*% V %*% t(J)) else matrix(NA_real_, n, n)
  covariance[fixed, ] <- covariance[, fixed] <- 0
  dimnames(covariance) <- list(labels, labels)
  se <- covariance_diag_se(covariance)
  eligible <- isTRUE(inference$check$eligible) & is.finite(se) & se > 0 & !fixed
  estimate <- expected$Estimate
  point <- mfrm_gmfrm_point_review(fit$prep, cfg, fit$opt)$overview
  no_maximum <- identical(point$Status, "finite_maximum_absent")
  if (no_maximum) estimate[!fixed] <- NA_real_
  lower <- estimate - stats::qnorm((1 + level) / 2) * se
  upper <- estimate + stats::qnorm((1 + level) / 2) * se
  eligible <- eligible & is.finite(lower) & is.finite(upper) & !no_maximum
  status <- ifelse(fixed, "fixed", ifelse(eligible, "available",
    if (isTRUE(inference$check$eligible)) "nonpositive_variance_or_nonfinite_bounds" else "numerical_review_failed"))
  if (no_maximum) status[!fixed] <- "finite_maximum_absent"
  lower[!eligible] <- upper[!eligible] <- NA_real_
  se[!eligible & !fixed] <- NA_real_
  review <- rep(inference$check$review, n)
  review[fixed] <- "Constraint-fixed step; SE is zero by construction, not empirical precision. No inferential interval."
  review[status == "nonpositive_variance_or_nonfinite_bounds"] <- "The target requires finite positive variance and finite normal bounds."
  caution <- unique(c(inference$check$caution,
    "Experimental two-family step intervals: offsets sum to zero within each step-owner level; they are not category boundaries including facet locations. Sampling coverage is unqualified."))
  tab <- data.frame(Target = labels, StepOwner = cfg$step_facet,
    StepLevel = expected$StepFacet, Step = expected$Step, Estimate = estimate,
    OptimizerEstimate = expected$Estimate, PointEstimateStatus = point$Status,
    SE = se, Lower = lower, Upper = upper, Status = status,
    SEEligible = eligible, CIEligible = eligible, CoverageQualified = FALSE,
    CIUse = ifelse(fixed, "fixed_by_constraint", ifelse(eligible, "approximate_pointwise", "unavailable")),
    ScaleReference = "within_level_sum_zero_fixed_N01", InferenceReview = review)
  out <- structure(list(table = tab, covariance = covariance, model_covariance = covariance,
    parameter_covariance = V, model_parameter_covariance = V,
    contrasts = diag(1, n, n, names = FALSE), target_jacobian = J,
    settings = list(facet = cfg$step_facet, target = "category_step_offsets",
      procedure = "gmfrm_step_model_v1", method = "model", level = level,
      two_family = TRUE, scale = "fixed_standard_normal", location_reference = "within_level_sum_zero",
      integration = if (mfrmr_adaptive_integration(cfg)) "adaptive" else "fixed",
      quad_points = cfg$estimation_control$quad_points),
    checks = inference$checks, numerical_checks = inference$numerical_checks,
    score_rank = inference$score_rank, cautions = caution, source = mfrm_gpcm_step_source(fit),
    fit = fit), class = "mfrm_facet_intervals")
  dimnames(out$contrasts) <- list(labels, labels)
  if (!is.null(inference$check$caution)) warning(inference$check$caution, call. = FALSE)
  out
}

mfrm_gpcm_interval_result <- function(tab, level, method, target, simultaneous = "none", covariance = NULL) {
  bounds <- as.matrix(tab[c("CI_Lower", "CI_Upper")])
  dimnames(bounds) <- list(as.character(tab$SlopeFacet), c("Lower", "Upper"))
  structure(bounds, level = level, method = method, target = target,
    simultaneous = simultaneous, diagnostics = tab, covariance = covariance,
    class = c("mfrm_slope_intervals", "matrix", "array"))
}
