#' Pointwise intervals for fixed facet estimates and contrasts
#'
#' Describe uncertainty about a fixed facet estimate, such as rater severity,
#' or a specified difference between two raters. Start from a supported fitted
#' model; the point estimates stay the same when you change the interval method.
#'
#' Compare ordinary observed-information intervals with a sandwich covariance
#' that treats a person's complete response vector, or an explicitly declared
#' larger cluster, as the independent sampling unit. Estimates are not refitted.
#'
#' @param fit An inference-ready RSM/PCM MML fit from [fit_mfrm()], using a
#'   fixed standard-normal person distribution, fixed quadrature and unit
#'   observation weights. Experimental two-family GPCM MML also supports
#'   `method = "model"` with fixed-grid EM or direct adaptive integration;
#'   see "Two-family location targets" below. Experimental direct MML native
#'   locations additionally support estimated intercept-only normal RSM/PCM
#'   and one-family GPCM with fixed N(0,1) or an estimated intercept-only normal
#'   population, using fixed or adaptive integration; see "Native locations"
#'   below for their scope and separate numerical checks.
#' @param facet A non-person facet, for example `"Rater"`.
#' @param contrasts Optional numeric matrix with distinct target row names
#'   and columns named by every level of `facet`. Columns are aligned by name.
#'   A row with coefficients `c(1, -1, 0)` estimates the first level minus the
#'   second. By default, each level is reported.
#' @param method `"model"` (default) uses ordinary observed information;
#'   `"sandwich"` uses independent-cluster marginal-likelihood scores.
#'   The experimental native-location and two-family extensions support only
#'   `"model"`; sandwich support remains limited to the ordinary fixed-population
#'   RSM/PCM route.
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
#'   When weak information passes numerical refinement, `cautions` and
#'   `information_review` retain the warning and checks. `InferenceCaution`
#'   also accompanies the interval table when applicable.
#'   Two-family results additionally retain `checks`, `numerical_checks`,
#'   `score_rank`, source identity, scale references and interval refusal reasons.
#'   Their table includes `CIEligible`; failed numerical checks leave bounds
#'   and SEs missing while preserving the fitted point estimates.
#'   Native-location results retain checks, numerical comparisons, full and
#'   target covariance, target Jacobian and source identity, without an
#'   empirical Person-score rank requirement.
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
#'   estimates and the reason remain. For ordinary fixed-population RSM/PCM, singular/regularized observed information
#'   or an ineligible source fit causes an error. Targets fixed by constraints
#'   have no inferential interval. Known anchors exclude anchor uncertainty.
#'   An ill-conditioned but numerically verified unregularized inverse can be
#'   used with a warning. Successful inversion does not establish reliable
#'   normal intervals. Review interval width, boundary proximity and quadrature
#'   sensitivity; changing to sandwich covariance does not remove this concern.
#'
#' @section Native locations:
#'   For estimated intercept-only normal RSM/PCM and one-family GPCM MML,
#'   `method = "model"` supplies experimental pointwise normal intervals for
#'   locations or contrasts on the model's native ability scale. One-family
#'   GPCM also admits the explicit fixed-N(0,1) restriction
#'   (`gpcm_mml_identification = "fixed_standard_normal"`). Shared or separate
#'   slope/step owners are supported, with geometric-mean-one relative slopes.
#'   Use direct MML, fixed or adaptive integration, unit weights, additive
#'   centered facets and centered steps. Anchors, interactions, latent regression
#'   and sandwich covariance are unavailable in this added route.
#'
#'   The covariance transforms the inverse full joint marginal information,
#'   including all estimated population, slope and step coordinates. A
#'   location-only inverse or independent printed SEs cannot replace it.
#'   The source, category support, local solution and unregularized information
#'   must pass checks; covariance and score changes are also checked at a finer
#'   integration order at the same fitted parameter vector. This model-information
#'   procedure has no empirical Person-score rank requirement.
#'   A numerical refusal preserves the native point and its reason with
#'   unavailable SE/bounds. Constraint-fixed targets have no inferential interval.
#'
#'   These numerical checks do not establish sampling coverage, global
#'   identification or robustness to misspecification. Native locations are
#'   not divided by the estimated population SD; standardized targets would
#'   additionally need that SD's uncertainty and cross-covariances. A location
#'   difference need not produce a uniform rating difference with unequal slopes
#'   or steps. The calculation does not refit or change the saved fit/readiness.
#'   Save and attach `ci` with `mfrm_results(fit, intervals = list(locations = ci),
#'   compute = "never")`; select `plot(res, type = "facet_locations")` for
#'   RSM/PCM or `"gpcm_locations"` for one-family GPCM. Reports and exports retain
#'   the native scale, experimental status and unavailable outputs.
#'
#' @section Two-family location targets:
#'   For native two-family GPCM MML, select either modeled non-Person facet.
#'   The first slope owner's locations sum to zero; the second owner's locations
#'   are uncentered on the fixed N(0,1) ability scale. These locations are measured
#'   before multiplication by both slope components. Increasing a location
#'   lowers expected ratings when ability, slopes and other effects stay fixed.
#'   A contrast between actual raters need not imply a uniform difference in
#'   expected ratings: their slopes and category-step offsets may also differ.
#'   Neither zero nor a location difference defines rater quality or accuracy.
#'
#'   Let `J` expand the free location coordinates under their fitted constraints
#'   and `C` be the requested contrast matrix. The target covariance is
#'   `C J V J' C'`, where `V` is the location block extracted *after inverting
#'   the full joint marginal information*. Slopes, steps and the other facet
#'   remain estimated nuisance parameters. Inverting a location-only Hessian,
#'   adding independent printed SEs, or using the EM conditional-objective
#'   Hessian would omit their joint estimation uncertainty.
#'
#'   The source fit must pass the same identity, category support, local score
#'   rank, stationarity, full-information and finer-quadrature checks used for
#'   experimental two-family slope intervals in [confint.mfrm_fit()]. The full
#'   covariance is checked, but passing these numerical checks does not establish
#'   repeated-sample coverage for locations or contrasts. Evidence for component
#'   slope intervals does not qualify these different targets. These are
#'   experimental pointwise normal approximations, with no sandwich, profile,
#'   multiplicity or automatic significance decision. A failed check retains
#'   estimates and reasons with unavailable intervals, even if the coarse-grid
#'   information could be inverted. Constraint-fixed targets have no interval.
#'   The calculation does not refit or change quadrature in the saved fit.
#'
#'   For example, use `ci <- mfrm_facet_intervals(fit, "Rater")`, or supply a
#'   named zero-sum row of `contrasts` for a difference. Plot and save `ci`
#'   directly, or attach it with
#'   `mfrm_results(fit, intervals = list(locations = ci))` and select
#'   `plot(res, type = "gpcm_locations")`. The model must actually contain the
#'   specified facet. Location intervals do not add category-step/curve bands,
#'   Person uncertainty, Wright maps or tests of rater competence. Individual
#'   two-family rater sheets currently display component-slope intervals only;
#'   use the analyst report for these location and contrast results.
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
#'   For the RSM/PCM route, a 1,600-dataset comparison used 80/320 independent persons, three
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
#' @section Save, display and report the selected intervals:
#'   Use [plot()], [as_ggplot()] and [plot_data()] to display or extract the
#'   saved result, and [apa_table()] for tables. Set `title = NULL`,
#'   `subtitle = NULL` or `caption = NULL` in the plot to omit that text.
#'   For RSM/PCM, attach one result or a named list to [mfrm_results()], for example
#'   `mfrm_results(fit, intervals = list(raters = intervals),
#'   include = c("fit", "plots"), compute = "never")`.
#'   The route `plot(res, type = "facet_raters")` shows the selected intervals.
#'   For two-family GPCM, the corresponding plot type is `"gpcm_raters"`.
#'   [mfrm_report()] and [export_mfrm_results()] retain the method, level,
#'   contrast coefficients, cluster mapping and unavailable outcomes.
#'   The source fit must match; replay reloads the saved results without
#'   refitting or recomputing covariance. These intervals do not replace
#'   uncertainty in ordinary Wright maps, fit diagnostics or Person scores.
#'
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
  stop_if_jml_adjustment(fit, "mfrm_facet_intervals()")
  product <- mfrm_has_product_slopes(fit)
  native <- !product && (isTRUE(fit$config$population_spec$active) ||
    identical(fit$config$model, "GPCM"))
  method <- match.arg(method)
  if (!product && !native && (!inherits(fit, "mfrm_fit") || !identical(fit$config$method, "MML") ||
      !fit$config$model %in% c("RSM", "PCM") ||
      isTRUE(fit$config$population_spec$active) || mfrmr_adaptive_integration(fit$config) ||
      any(!is.finite(fit$prep$data$Weight)) || any(fit$prep$data$Weight != 1) ||
      !mfrm_inference_ready(fit))) {
    stop("Use an inference-ready RSM/PCM MML fit with unit weights, fixed quadrature and a fixed standard-normal person distribution.", call. = FALSE)
  }
  if (!is.logical(adjust) || length(adjust) != 1L || is.na(adjust) ||
      !is.numeric(level) || is.complex(level) || is.object(level) || !is.null(dim(level)) || length(level) != 1L ||
      !is.finite(level) || level <= 0 || level >= 1) {
    stop("Supply a logical `adjust` and 0 < level < 1.", call. = FALSE)
  }
  level <- unname(level)
  if (method == "model" && (!is.null(clusters) || adjust)) {
    stop("`clusters` and `adjust` apply only to method = 'sandwich'.", call. = FALSE)
  }
  if (product && (method != "model" || !inherits(fit, "mfrm_fit") ||
      inherits(fit, "mfrm_imported_fit") || !identical(fit$config$method, "MML"))) {
    stop("Two-family location intervals require native MML and method = 'model'; sandwich intervals are unavailable.", call. = FALSE)
  }
  if (native && method != "model") {
    stop("Native population/one-family GPCM location intervals require method = 'model'; sandwich intervals are unavailable.", call. = FALSE)
  }
  params <- if (native) mfrm_native_location_source(fit) else NULL
  target <- mfrm_facet_contrasts(fit, facet, contrasts)
  sizes <- build_param_sizes(fit$config)
  if (!native) params <- expand_params(fit$opt$par, sizes, fit$config)
  estimate <- drop(target$contrasts %*% params$facets[[facet]])
  estimate[target$fixed] <- target$constant[target$fixed]
  if (native && any(!is.finite(estimate)))
    stop("Native contrast estimates must be finite; rescale excessively large coefficients.", call. = FALSE)
  if (product) {
    expected <- build_other_facet_table(fit$config, fit$prep, params)
    keys <- c("Facet", "Level", "Estimate")
    if (!isTRUE(all.equal(fit$facets$others[keys], expected[keys],
        tolerance = 1e-10, check.attributes = FALSE)))
      stop("Saved locations must match the fitted two-family parameters.", call. = FALSE)
    inference <- mfrm_gpcm_product_inference(fit)
    information <- inference$information
    model_cov <- inference$covariance
    if (is.null(model_cov)) model_cov <- matrix(NA_real_, length(fit$opt$par), length(fit$opt$par))
  } else if (native) {
    inference <- mfrm_native_location_inference(fit)
    information <- inference$information
    model_cov <- inference$covariance
  } else {
    information <- compute_mml_parameter_covariance(fit)
    if (!identical(information$status, "ok") || is.null(information$cov) ||
      any(!is.finite(information$cov)) ||
      is.null(tryCatch(chol(information$cov), error = function(e) NULL))) {
      stop("Unregularized positive-definite observed information is required.", call. = FALSE)
    }
    model_cov <- information$cov
  }
  cov <- model_cov
  person_scores <- cluster_scores <- NULL
  nclusters <- rank <- NA_integer_
  factor <- 1
  if (method == "sandwich") {
    person_scores <- mfrm_person_likelihood_scores(fit)
    sandwich <- mfrm_cluster_sandwich(model_cov, person_scores, clusters, adjust)
    clusters <- sandwich$clusters; cluster_scores <- sandwich$cluster_scores
    nclusters <- nrow(cluster_scores); rank <- sandwich$rank
    factor <- sandwich$factor; cov <- sandwich$covariance
  }
  slice <- build_param_slices(sizes)[[facet]]
  transform <- function(v) {
    z <- if (is.null(v)) matrix(NA_real_, nrow(target$contrasts), nrow(target$contrasts)) else
      symmetrize_matrix(target$jacobian %*% v[slice, slice, drop = FALSE] %*% t(target$jacobian))
    z[target$fixed, ] <- 0; z[, target$fixed] <- 0
    z
  }
  selected_cov <- transform(cov)
  model_target_cov <- transform(model_cov)
  se <- covariance_diag_se(selected_cov)
  model_se <- covariance_diag_se(model_target_cov)
  status <- rep("available", length(estimate))
  if ((product || native) && !isTRUE(inference$check$eligible)) status[] <- "numerical_review_failed"
  if (method == "sandwich" && rank < ncol(cluster_scores)) status[] <- "insufficient_cluster_rank"
  status[status != "numerical_review_failed" & (!is.finite(se) | se <= 0)] <- "nonpositive_variance"
  status[target$fixed] <- "fixed"
  se[!status %in% c("available", "fixed")] <- NA_real_
  critical <- stats::qnorm((1 - level) / 2, lower.tail = FALSE)
  margin <- critical * se
  margin[target$fixed] <- NA_real_
  model_margin <- critical * model_se
  model_margin[target$fixed] <- NA_real_
  tab <- data.frame(Target = rownames(target$contrasts), Estimate = estimate,
    SE = se, Lower = estimate - margin, Upper = estimate + margin,
    ModelSE = model_se, ModelLower = estimate - model_margin,
    ModelUpper = estimate + model_margin, Status = status, row.names = NULL)
  if (native) {
    invalid <- status == "available" & (!is.finite(tab$Lower) | !is.finite(tab$Upper))
    status[invalid] <- "nonfinite_bounds"
    tab$Status <- status
    tab[!status %in% c("available", "fixed"),
      c("SE", "Lower", "Upper", "ModelSE", "ModelLower", "ModelUpper")] <- NA_real_
  }
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
  out$cautions <- mfrm_mml_information_caution(information)
  out$information_review <- information$solution_information$inverse_review
  if (product) {
    out$source <- mfrm_gpcm_inference_source(fit)
    out$settings$two_family <- TRUE
    out$settings$scale <- "fixed_standard_normal"
    out$settings$location_reference <- if (facet == fit$config$slope_facet[1L])
      "sum_to_zero_across_levels" else "uncentered_on_fixed_N01"
    out$settings$integration <- if (mfrmr_adaptive_integration(fit$config)) "adaptive" else "fixed"
    out$checks <- inference$checks
    out$numerical_checks <- inference$numerical_checks
    out$score_rank <- inference$score_rank
    out$table$CIEligible <- status == "available"
    out$table$ScaleReference <- out$settings$location_reference
    out$table$InferenceReview <- inference$check$review
    out$cautions <- unique(c(out$cautions, inference$check$caution,
      "Experimental two-family location intervals: sampling coverage is not qualified. Location differences do not imply uniform differences in expected ratings when slopes or category steps differ."))
  }
  if (native) {
    out$settings$procedure <- "mml_native_location_model_v1"
    out$settings$scale <- "native_ability"
    out$settings$location_reference <- "sum_to_zero_across_levels"
    out$settings$integration <- if (mfrmr_adaptive_integration(fit$config)) "adaptive" else "fixed"
    out$settings$comparison_quad_points <- 2 * out$settings$quad_points - 1
    out$settings$population <- if (isTRUE(fit$config$population_spec$active))
      "estimated_intercept_normal" else "fixed_standard_normal"
    out$settings$slope_owner <- fit$config$slope_facet %||% NA_character_
    out$settings$step_owner <- fit$config$step_facet %||% "shared"
    out$source <- mfrm_native_location_identity(fit)
    out$checks <- inference$checks
    out$numerical_checks <- inference$numerical_checks
    out$comparison_information_review <- inference$comparison_information_review
    out$target_jacobian <- matrix(0, nrow(target$contrasts), length(fit$opt$par),
      dimnames = list(rownames(target$contrasts), mfrm_checkpoint_parameter_names(sizes)))
    out$target_jacobian[, slice] <- target$jacobian
    out$population <- data.frame(Mean = if (is.null(params$population)) 0 else
      unname(params$population$coefficients), Variance = params$population$sigma2 %||% 1)
    out$table$CIEligible <- status == "available"
    out$table$ScaleReference <- "native ability units; centered facet locations"
    out$table$InferenceReview <- inference$check$review
    out$table$InferenceReview[status == "fixed"] <- "Constraint-fixed native target; no inferential interval."
    out$table$InferenceReview[status %in% c("nonpositive_variance", "nonfinite_bounds")] <-
      "The target requires finite positive variance and finite normal bounds."
    out$cautions <- unique(c(out$cautions, inference$check$caution,
      "Experimental native location intervals: sampling coverage is not qualified. Native ability units are not standardized by the fitted population SD; unequal slopes or steps can make expected-rating differences vary with ability."))
  }
  if (length(out$cautions)) {
    out$table$InferenceCaution <- paste(out$cautions, collapse = " ")
    warning(paste(out$cautions, collapse = " "), call. = FALSE)
  }
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
  print(x$table[setdiff(names(x$table), "InferenceCaution")], row.names = FALSE)
  for (caution in x$cautions) print_wrapped_line(paste0("Caution: ", caution))
  cat("Pointwise normal intervals; changing covariance does not correct biased estimates.\n")
  invisible(x)
}

#' @rdname mfrm_facet_intervals
#' @export
summary.mfrm_facet_intervals <- function(object, ...) object$table

# Tables share the same saved values across APA output, reports and exports.
mfrm_facet_interval_tables <- function(x) {
  tab <- x$table
  tab$Facet <- x$settings$facet
  tab$Method <- x$settings$method
  tab$ConfidenceLevel <- paste0(format(100 * x$settings$level, trim = TRUE), "%")
  tab$Adjustment <- "Pointwise"
  settings <- as.data.frame(x$settings, stringsAsFactors = FALSE)
  settings$ConfidenceLevel <- paste0(format(100 * settings$level, trim = TRUE), "%")
  settings$level <- NULL
  tables <- list(intervals = tab,
    settings = settings,
    contrasts = data.frame(Comparison = rownames(x$contrasts),
      x$contrasts, row.names = NULL, check.names = FALSE))
  for (name in c("checks", "numerical_checks", "score_rank", "population", "comparison_information_review")) {
    if (!is.null(x[[name]])) tables[[name]] <- x[[name]]
  }
  if (!is.null(x$clusters)) tables$clusters <- x$clusters
  if (!is.null(x$information_review)) tables$information_review <- x$information_review
  if (!is.null(x$target_jacobian)) tables$target_jacobian <- data.frame(
    Target = rownames(x$target_jacobian), x$target_jacobian, row.names = NULL, check.names = FALSE)
  tables
}

mfrm_facet_results_inputs <- function(fit, intervals) {
  if (is.null(intervals)) return(NULL)
  if (!inherits(fit, "mfrm_fit") || inherits(fit, "mfrm_imported_fit") ||
      !fit$config$model %in% c("RSM", "PCM")) {
    stop("Saved fixed-facet intervals require their native RSM/PCM fit.", call. = FALSE)
  }
  if (inherits(intervals, "mfrm_facet_intervals")) intervals <- list(inference = intervals)
  if (!is.list(intervals) || !length(intervals) || is.null(names(intervals)) ||
      anyNA(names(intervals)) || anyDuplicated(tolower(names(intervals))) ||
      any(!grepl("^[A-Za-z][A-Za-z0-9_]*$", names(intervals))) ||
      !all(vapply(intervals, inherits, logical(1), what = "mfrm_facet_intervals"))) {
    stop("`intervals` must be saved fixed-facet intervals or a named list of them; use distinct letter/number/underscore names.", call. = FALSE)
  }
  names(intervals) <- tolower(names(intervals))
  # The existing signature also describes ordinary native RSM/PCM fits.
  source <- mfrm_gpcm_inference_source(fit)
  for (x in intervals) {
    if (is.null(x$fit) || !identical(source, mfrm_gpcm_inference_source(x$fit))) {
      stop("Saved fixed-facet intervals must match the fitted parameters, data, constraints, population and integration settings.", call. = FALSE)
    }
    if (identical(x$settings$procedure, "mml_native_location_model_v1") &&
        !identical(mfrm_native_location_identity(fit), x$source)) {
      stop("Saved native location intervals must match the source coordinates, tables and qualification metadata.", call. = FALSE)
    }
  }
  intervals
}

mfrm_facet_results_attach <- function(out, inputs) {
  if (is.null(inputs)) return(out)
  out$facet_intervals <- inputs
  for (name in names(inputs)) {
    key <- paste0("facet_", name)
    tables <- mfrm_facet_interval_tables(inputs[[name]])
    names(tables) <- paste(key, names(tables), sep = "_")
    out$tables <- c(out$tables, tables)
    out$components[[key]] <- inputs[[name]]
    out$status <- rbind(out$status, mfrm_results_status_row(key, "review",
      "Saved fixed-facet pointwise intervals; method, confidence level, contrasts and unavailable outcomes retained. No automatic rater-quality decision."))
    out$plot_map <- dplyr::bind_rows(out$plot_map, data.frame(Type = key,
      Available = "plots" %in% out$include, RequiredArtifact = FALSE,
      Route = paste0('plot(res, type = "', key, '")'),
      Detail = "Saved fixed-facet uncertainty; no refitting or covariance calculation.",
      InterpretationStatus = "approximate_inference", InterpretationReady = FALSE,
      ReadinessRoute = paste0("res$tables$", names(tables)[1])))
  }
  out$table_index <- mfrm_results_table_index(out$tables)
  out$notes <- unique(c(out$notes,
    unlist(lapply(inputs, `[[`, "cautions"), use.names = FALSE),
    "Fixed-facet pointwise intervals condition on the observed facet levels. Sandwich covariance does not correct biased estimates or imply rater quality."))
  out
}
