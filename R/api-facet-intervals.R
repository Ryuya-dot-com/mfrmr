#' Pointwise intervals for fixed facet estimates and contrasts
#'
#' Compare ordinary observed-information intervals with a sandwich covariance
#' that treats a person's complete response vector, or an explicitly declared
#' larger cluster, as the independent sampling unit. Estimates are not refitted.
#'
#' @param fit An inference-ready RSM/PCM MML fit from [fit_mfrm()], using a
#'   fixed standard-normal person distribution, fixed quadrature and unit
#'   observation weights.
#' @param facet A non-person facet, for example `"Rater"`.
#' @param contrasts Optional numeric matrix with distinct target row names
#'   and columns named by every level of `facet`. Columns are aligned by name.
#'   A row with coefficients `c(1, -1, 0)` estimates the first level minus the
#'   second. By default, each level is reported.
#' @param method `"model"` (default) uses ordinary observed information;
#'   `"sandwich"` uses independent-cluster marginal-likelihood scores.
#' @param clusters For sandwich inference, an optional data frame with exactly
#'   one row per fitted person and complete `Person` and `Cluster` identifiers.
#'   Without it, persons are the independent units. A larger cluster could be
#'   a school or clinic if different schools or clinics are independent.
#'   A person cannot be split across clusters. Supply original person labels,
#'   even when the input person column has another name.
#' @param adjust Logical; with `method = "sandwich"`, optionally multiply
#'   the covariance by `G/(G-1)`, where `G` is the cluster count. Default `FALSE`.
#'   This scaling does not guarantee small-sample coverage.
#' @param level Pointwise confidence level, strictly between zero and one.
#'
#' @return An `mfrm_facet_intervals` object with `table`, selected target
#'   `covariance`, `model_covariance`, free-parameter `parameter_covariance`,
#'   `model_parameter_covariance`, `person_scores`, `cluster_scores`, the
#'   `clusters` mapping, exact `contrasts`, `settings`, and source `fit`.
#'   The model-based SE and interval remain alongside the selected method.
#'   Score rows are derivatives of a person's marginal log likelihood, not
#'   observed category scores or ability estimates. Scores are absent for
#'   `method = "model"`.
#'
#' @details For cluster score `s_g` and observed negative-log-likelihood
#'   Hessian `H`, the unadjusted sandwich is
#'   `solve(H) %*% sum_g(s_g %*% t(s_g)) %*% solve(H)`.
#'   Scores aggregate all responses of a person before forming the outer
#'   products; grouping individual rating rows would be a different and
#'   incorrect calculation for this marginal likelihood. The full covariance
#'   is transformed through the fitted constraints and requested contrasts.
#'   Both methods use normal critical values. No automatic method selection,
#'   multiplicity adjustment or significance flag is supplied.
#'
#'   The sandwich requires many independent sampling units and appropriate
#'   regularity. It permits dependence within the declared unit but does not
#'   establish independence between units. A small number of units can give
#'   poor intervals even with nonsingular covariance. If their scores do not
#'   span the free-parameter space, sandwich intervals are unavailable; point
#'   estimates and the reason remain. Singular/regularized observed information
#'   or an ineligible source fit causes an error. Targets fixed by constraints
#'   have no inferential interval. Known anchors exclude anchor uncertainty.
#'
#' @section What robustness means here:
#'   Under model misspecification, the sandwich describes sampling variation
#'   around the working model's limiting parameter (its pseudo-true target).
#'   That target need not equal the generating rater severity or criterion
#'   difficulty. Changing the SE does not correct a biased estimate, informative
#'   assignment, unmodeled population differences or MNAR nonresponse. Check
#'   the model and assignment before interpreting a severity contrast.
#'
#'   These intervals condition on the observed fixed facet levels. They do not
#'   generalize to replacement raters sampled from a rater population. They
#'   are not multiway crossed-cluster, G/D-study, variance-boundary, EAP or
#'   multiple-imputation intervals. Shared random rater/task effects spanning
#'   the declared clusters violate this one-way independence assumption.
#'   Numerical success is not a general coverage or rater-diagnosis guarantee.
#'   Review quadrature sensitivity separately; the helper reuses the fitted grid.
#'
#' @section Bounded evaluation:
#'   A 1,600-dataset RSM/PCM comparison used 80/320 independent persons, three
#'   fixed raters and two criteria. In its combined skewed-ability/sparse-design
#'   scenario, sandwich coverage of generating contrasts ranged from 87.0 to
#'   95.5 percent despite all intervals being available. Coverage of the
#'   independently calculated working-model targets ranged from 93.0 to 97.5
#'   percent. These are ranges across conditions/contrasts, not uncertainty
#'   bounds or universal operating characteristics. At 200 datasets per
#'   condition, MCSE near 95 percent is about 1.54 percentage points.
#'   See \code{vignette("mfrmr-facet-intervals", package = "mfrmr")} for the
#'   design, interpretation and a complete rater-feedback example.
#'
#' @references Zeileis, A. (2006). Object-oriented computation of sandwich
#'   estimators. *Journal of Statistical Software*, 16(9), 1--16.
#'   \doi{10.18637/jss.v016.i09}.
#'   Zeileis, A., Koell, S. and Graham, N. (2020). Various versatile variances:
#'   An object-oriented implementation of clustered covariances in R.
#'   *Journal of Statistical Software*, 95(1), 1--36.
#'   \doi{10.18637/jss.v095.i01}.
#' @seealso [analyze_facet_equivalence()], [pool_mfrm_imputed()],
#'   [plot.mfrm_facet_intervals()]
#' @examples
#' ratings <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score")
#' intervals <- mfrm_facet_intervals(fit, "Rater", method = "sandwich")
#' summary(intervals)
#' plot(intervals)
#' @export
mfrm_facet_intervals <- function(fit, facet, contrasts = NULL,
                                 method = c("model", "sandwich"),
                                 clusters = NULL, adjust = FALSE, level = .95) {
  method <- match.arg(method)
  if (!inherits(fit, "mfrm_fit") || !identical(fit$config$method, "MML") ||
      !fit$config$model %in% c("RSM", "PCM") ||
      isTRUE(fit$config$population_spec$active) || mfrmr_adaptive_integration(fit$config) ||
      any(!is.finite(fit$prep$data$Weight)) || any(fit$prep$data$Weight != 1) ||
      !mfrm_inference_ready(fit)) {
    stop("Use an inference-ready RSM/PCM MML fit with unit weights, fixed quadrature and a fixed standard-normal person distribution.", call. = FALSE)
  }
  if (!is.logical(adjust) || length(adjust) != 1L || is.na(adjust) ||
      !is.numeric(level) || is.complex(level) || length(level) != 1L ||
      !is.finite(level) || level <= 0 || level >= 1) {
    stop("Supply a logical `adjust` and 0 < level < 1.", call. = FALSE)
  }
  if (method == "model" && (!is.null(clusters) || adjust)) {
    stop("`clusters` and `adjust` apply only to method = 'sandwich'.", call. = FALSE)
  }
  target <- mfrm_facet_contrasts(fit, facet, contrasts)
  information <- compute_mml_parameter_covariance(fit)
  if (!identical(information$status, "ok") || is.null(information$cov) ||
      any(!is.finite(information$cov)) ||
      is.null(tryCatch(chol(information$cov), error = function(e) NULL))) {
    stop("Unregularized positive-definite observed information is required.", call. = FALSE)
  }
  model_cov <- information$cov
  cov <- model_cov
  person_scores <- cluster_scores <- NULL
  nclusters <- rank <- NA_integer_
  factor <- 1
  if (method == "sandwich") {
    person_scores <- mfrm_person_likelihood_scores(fit)
    ids <- rownames(person_scores)
    if (is.null(clusters)) clusters <- data.frame(Person = ids, Cluster = ids)
    if (!is.data.frame(clusters) || anyDuplicated(names(clusters)) ||
        !all(c("Person", "Cluster") %in% names(clusters)) ||
        nrow(clusters) != length(ids) || anyNA(clusters[c("Person", "Cluster")]) ||
        anyDuplicated(as.character(clusters$Person)) ||
        !setequal(as.character(clusters$Person), ids) ||
        any(!nzchar(trimws(as.character(clusters$Cluster))))) {
      stop("`clusters` must map every fitted Person exactly once to one nonmissing Cluster.", call. = FALSE)
    }
    clusters <- data.frame(Person = ids,
      Cluster = as.character(clusters$Cluster[match(ids, as.character(clusters$Person))]))
    cluster_scores <- rowsum(person_scores, clusters$Cluster, reorder = FALSE)
    nclusters <- nrow(cluster_scores)
    if (nclusters < 2L) stop("Sandwich inference needs at least two independent clusters.", call. = FALSE)
    scale <- sqrt(colSums(cluster_scores^2))
    nonzero <- scale > 0
    rank <- if (!any(nonzero)) 0L else
      qr(sweep(cluster_scores[, nonzero, drop = FALSE], 2, scale[nonzero], "/"), tol = 1e-10)$rank
    factor <- if (adjust) nclusters / (nclusters - 1) else 1
    cov <- symmetrize_matrix(model_cov %*% crossprod(cluster_scores) %*% model_cov) * factor
    if (any(!is.finite(cov))) stop("The sandwich covariance is not finite.", call. = FALSE)
  }
  slice <- information$param_slices[[facet]]
  transform <- function(v) symmetrize_matrix(
    target$jacobian %*% v[slice, slice, drop = FALSE] %*% t(target$jacobian))
  selected_cov <- transform(cov)
  model_target_cov <- transform(model_cov)
  estimate <- drop(target$contrasts %*%
    expand_params(fit$opt$par, information$sizes, fit$config)$facets[[facet]])
  estimate[target$fixed] <- target$constant[target$fixed]
  se <- covariance_diag_se(selected_cov)
  model_se <- covariance_diag_se(model_target_cov)
  status <- rep("available", length(estimate))
  if (method == "sandwich" && rank < ncol(cluster_scores)) status[] <- "insufficient_cluster_rank"
  status[!is.finite(se) | se <= 0] <- "nonpositive_variance"
  status[target$fixed] <- "fixed"
  se[!status %in% c("available", "fixed")] <- NA_real_
  critical <- stats::qnorm(1 - (1 - level) / 2)
  margin <- critical * se
  margin[target$fixed] <- NA_real_
  model_margin <- critical * model_se
  model_margin[target$fixed] <- NA_real_
  tab <- data.frame(Target = rownames(target$contrasts), Estimate = estimate,
    SE = se, Lower = estimate - margin, Upper = estimate + margin,
    ModelSE = model_se, ModelLower = estimate - model_margin,
    ModelUpper = estimate + model_margin, Status = status, row.names = NULL)
  out <- list(table = tab, covariance = selected_cov, model_covariance = model_target_cov,
    parameter_covariance = cov, model_parameter_covariance = model_cov,
    person_scores = person_scores, cluster_scores = cluster_scores, clusters = clusters,
    contrasts = target$contrasts,
    settings = list(facet = facet, method = method, level = level, adjust = adjust,
      adjustment_factor = factor, persons = fit$prep$n_person, clusters = nclusters,
      cluster_score_rank = rank, free_parameters = length(fit$opt$par),
      reference = "pointwise normal", quad_points = fit$config$estimation_control$quad_points),
    fit = fit)
  class(out) <- "mfrm_facet_intervals"
  out
}

mfrm_facet_contrasts <- function(fit, facet, contrasts) {
  if (!is.character(facet) || length(facet) != 1L || is.na(facet) ||
      !facet %in% fit$config$facet_names) {
    stop("`facet` must name a non-person model facet.", call. = FALSE)
  }
  spec <- fit$config$facet_specs[[facet]]
  labels <- as.character(spec$levels)
  if (is.null(contrasts)) {
    contrasts <- diag(length(labels))
    dimnames(contrasts) <- list(labels, labels)
  }
  if (!is.matrix(contrasts) || !is.numeric(contrasts) || is.complex(contrasts) ||
      !nrow(contrasts) || ncol(contrasts) != length(labels) || any(!is.finite(contrasts)) ||
      is.null(colnames(contrasts)) || anyDuplicated(colnames(contrasts)) ||
      !setequal(colnames(contrasts), labels) || is.null(rownames(contrasts)) ||
      anyNA(rownames(contrasts)) || any(!nzchar(rownames(contrasts))) ||
      anyDuplicated(rownames(contrasts)) || any(rowSums(abs(contrasts)) == 0)) {
    stop("`contrasts` must have distinct target row names, all facet-level column names, and finite nonzero coefficient rows.", call. = FALSE)
  }
  contrasts <- contrasts[, labels, drop = FALSE]
  jac <- contrasts %*% constraint_jacobian(spec)
  list(labels = labels, contrasts = contrasts, jacobian = jac,
    fixed = if (ncol(jac)) rowSums(abs(jac)) == 0 else rep(TRUE, nrow(jac)),
    constant = drop(contrasts %*% expand_facet_with_constraints(numeric(spec$n_params), spec)))
}

# Reuse posterior moments and the same constraint projections as the likelihood
# gradient. The loop is over Persons after one joint quadrature calculation.
mfrm_person_likelihood_scores <- function(fit) {
  config <- fit$config
  sizes <- build_param_sizes(config)
  params <- expand_params(fit$opt$par, sizes, config)
  idx <- build_indices(fit$prep, step_facet = config$step_facet,
    interaction_specs = config$interaction_specs)
  quad <- gauss_hermite_normal(config$estimation_control$quad_points)
  bundle <- mfrm_mml_logprob_bundle(idx, config, quad, params,
    compute_base_eta(idx, params, config), include_probs = TRUE)
  posterior <- mfrm_mml_posterior_bundle(bundle)
  expected <- mfrm_mml_expected_category_bundle(bundle, posterior, include_p_geq = TRUE)
  residual <- idx$score_k - expected$expected_k
  step_residual <- expected$p_geq - outer(idx$score_k, seq_len(config$n_cat - 1L), ">=")
  rows <- split(seq_along(idx$person), factor(idx$person, levels = seq_len(config$n_person)))
  scores <- t(vapply(rows, function(at) {
    facet_scores <- unlist(lapply(config$facet_names, function(facet) {
      expanded <- numeric(length(params$facets[[facet]]))
      sums <- rowsum(matrix(residual[at], ncol = 1), idx$facets[[facet]][at], reorder = FALSE)
      expanded[as.integer(rownames(sums))] <- sums[, 1] * config$facet_signs[[facet]]
      constraint_grad_project(expanded, config$facet_specs[[facet]])
    }))
    sub_idx <- list(interactions = lapply(idx$interactions, `[`, at))
    interaction_scores <- compute_interaction_gradient_free(residual[at], sub_idx, config)
    if (config$model == "RSM") {
      step_scores <- colSums(step_residual[at, , drop = FALSE])
    } else {
      step_scores <- matrix(0, nrow(params$steps_mat), ncol(params$steps_mat))
      sums <- rowsum(step_residual[at, , drop = FALSE], idx$step_idx[at], reorder = FALSE)
      step_scores[as.integer(rownames(sums)), ] <- sums
    }
    c(facet_scores, interaction_scores, project_typed_step_gradient(step_scores, config))
  }, numeric(length(fit$opt$par))))
  dimnames(scores) <- list(fit$prep$levels$Person, mfrm_checkpoint_parameter_names(sizes))
  aggregate_gradient <- mfrm_grad_mml(fit$opt$par, idx, config, sizes, quad)
  if (any(!is.finite(scores)) ||
      max(abs(colSums(scores) + aggregate_gradient)) > 1e-8 * max(1, max(colSums(abs(scores))))) {
    stop("Person likelihood scores do not reproduce the fitted objective gradient.", call. = FALSE)
  }
  scores
}

#' @rdname mfrm_facet_intervals
#' @param x,object An object returned by `mfrm_facet_intervals()`.
#' @param ... Unused by print and summary methods.
#' @export
print.mfrm_facet_intervals <- function(x, ...) {
  cat(x$settings$facet, "intervals:", x$settings$method, "covariance\n")
  if (x$settings$method == "sandwich") cat(x$settings$clusters,
    "declared independent clusters;", x$settings$persons, "persons\n")
  print(x$table, row.names = FALSE)
  cat("Pointwise normal intervals; changing covariance does not correct biased estimates.\n")
  invisible(x)
}

#' @rdname mfrm_facet_intervals
#' @export
summary.mfrm_facet_intervals <- function(object, ...) object$table
