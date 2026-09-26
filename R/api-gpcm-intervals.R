# Output-specific qualification, separate from the global boundary audit.
mfrm_gpcm_slope_inference_check <- function(fit, covariance, allow_singleton = FALSE) {
  refuse <- function(reason) list(eligible = FALSE, review = reason)
  if (!identical(fit$config$model, "GPCM") || !identical(fit$config$method, "MML")) {
    return(refuse("Relative-slope intervals require a native GPCM MML fit."))
  }
  if (!identical(covariance$status, "ok") || isTRUE(covariance$regularized) ||
      is.null(covariance$solution_information)) {
    return(refuse(trimws(paste("Fresh, unregularized joint MML information is required.",
      covariance$detail %||% ""))))
  }
  spec <- fit$config$gpcm_spec
  tab <- fit$slopes
  slice <- covariance$param_slices$log_slopes
  if (!isTRUE(spec$active) || !identical(spec$identification, "sum_to_zero_log_slopes") ||
      !identical(spec$scale_reference, "geometric_mean_one") ||
      !identical(spec$slope_facet, fit$config$slope_facet) ||
      !identical(spec$step_facet, fit$config$step_facet) ||
      !identical(as.character(spec$levels),
        as.character(fit$config$facet_levels[[fit$config$slope_facet]])) ||
      length(spec$levels) < 2L || length(slice) != length(spec$levels) - 1L ||
      !identical(as.character(tab$SlopeFacet), as.character(spec$levels))) {
    return(refuse("The free geometric-mean-one slope coordinates and their level order must match the fit."))
  }
  expanded <- expand_gpcm_log_slopes(fit$opt$par[slice], spec)
  if (!isTRUE(all.equal(as.numeric(tab$LogEstimate), expanded$log_slopes, tolerance = 1e-10)) ||
      !isTRUE(all.equal(as.numeric(tab$Estimate), expanded$slopes, tolerance = 1e-10))) {
    return(refuse("The slope table does not match the retained parameter vector."))
  }
  check <- tryCatch(mfrm_ic_fit_check(fit, mfrm_extract_fit_ic_contract(fit),
    information = covariance$solution_information, allow_singleton = allow_singleton),
    error = function(e) refuse(paste("The MML solution check is unavailable:", conditionMessage(e))))
  if (isTRUE(check$eligible) && !isTRUE(allow_singleton)) check$review <- paste(
    "Pointwise log-Wald approximation from the inverse full joint MML information.",
    "Relative slopes have geometric mean one. Assess starting-value and quadrature sensitivity;",
    "small samples and model misspecification can affect coverage.", check$caution %||% ""
  )
  check
}

mfrm_update_slope_readiness_parameters <- function(parameters, slopes) {
  if (!nrow(parameters) || !nrow(slopes) || !"SlopeFacet" %in% names(slopes)) return(parameters)
  index <- match(as.character(parameters$Level), as.character(slopes$SlopeFacet))
  keep <- parameters$ParameterClass == "gpcm_slope" & !is.na(index)
  fields <- intersect(c("PrimaryEstimate", "PrimaryLogEstimate", "ParameterStatus",
    "PrimaryEstimateBasis", "SEEligible", "CIEligible"), names(slopes))
  parameters[keep, fields] <- as.data.frame(slopes)[index[keep], fields, drop = FALSE]
  parameters
}

#' Approximate confidence intervals and comparisons for GPCM slopes
#'
#' Compute confidence intervals for relative or standardized discriminations
#' and specified slope comparisons in a native GPCM MML fit, without refitting.
#' The default is a pointwise model-based interval for each relative slope.
#' A relative slope above one
#' means a steeper response curve than the geometric-average slope; it is
#' not a measure of rater agreement or a recommended scoring weight.
#'
#' @param object A GPCM MML result from [fit_mfrm()].
#' @param parm Must be `"slopes"`; other parameter families are not included.
#' @param level Nominal confidence level strictly between zero and one.
#' @param scale `"relative"` (default) keeps geometric mean one. `"standardized"`
#'   reports population-SD times slope, including uncertainty in estimated SD.
#'   With covariates, this SD is the residual population SD.
#' @param contrasts Optional numeric matrix: one named comparison per row,
#'   all slope levels as named columns, finite nonzero rows summing to zero.
#'   For A versus B use coefficients 1 and -1, and zero for other levels.
#' @param contrast_scale `"ratio"` exponentiates log-slope contrasts (A/B);
#'   `"difference"` contrasts positive slopes (A-B) by the delta method.
#' @param method `"model"` uses joint observed information; `"sandwich"` uses
#'   Person marginal-likelihood scores, optionally grouped into larger clusters.
#' @param clusters Optional data frame mapping each fitted `Person` once to a
#'   nonmissing `Cluster`, as in [mfrm_facet_intervals()]. Persons are independent
#'   units by default. Shared random effects across clusters are not supported.
#' @param adjust For sandwich covariance only, multiply by G/(G-1) for G clusters;
#'   default FALSE. This is not a small-sample accuracy guarantee.
#' @param simultaneous `"none"` (default) gives pointwise intervals;
#'   `"bonferroni"` adjusts for all rows requested in this call. It does not
#'   adjust for other analyses or post-selection of targets.
#' @param ... Unused.
#' @return A matrix of class `mfrm_slope_intervals` with columns `Lower` and
#'   `Upper`, named by slope level. Printing shows estimates, bounds and any
#'   unavailability reasons without displaying internal diagnostic fields.
#'   Attributes `level`, `method`, `target`, and `diagnostics` describe the
#'   result. The diagnostics table includes estimates, log-scale and positive-
#'   scale SEs, `CIEligible`, `CIUse`, and an `InferenceReview` explaining
#'   availability. Unavailable intervals have missing bounds.
#' @details
#' Relative slopes have geometric mean one. If \eqn{\eta} denotes the
#' G-1 free log-slope coordinates and \eqn{J} expands them to G sum-zero
#' log slopes, their covariance is \eqn{J V_{\eta} J^T}. Here
#' \eqn{V_{\eta}} is the slope block of the inverse **full joint** observed
#' information, including estimated population parameters, rather than the
#' inverse of the slope information block alone. Each interval is
#' \eqn{\exp(\log(a_g) \mathbin{\pm} z SE(\log(a_g)))}.
#'
#' The current likelihood, gradient and joint information must pass the
#' MML solution checks. The fit also needs supported score categories,
#' consistent likelihood metadata, unit observation weights, and at least
#' 31 quadrature points. Regularized, singular, nonconverged or mismatched
#' results do not receive intervals. Positive curvature is a local check,
#' not a proof of a global maximum or accurate integration. Use
#' [mml_quadrature_sensitivity()] and different starts for consequential results.
#' A positive but ill-conditioned information matrix can be used with a warning
#' when two refined numerical Hessians agree, inversion without regularization
#' is accurate and a curvature-scaled gradient is small. Failure of any check
#' keeps inference unavailable. Passing these numerical checks does not resolve
#' weak information in the data: an interval may still be extremely wide or
#' unreliable near a boundary. Warnings are saved in the `cautions` attribute
#' and `InferenceReview`, and follow printing, default plot subtitles and reports.
#'
#' Model intervals are asymptotic. Standardized slopes use the full Jacobian
#' for `log(slope) + log(sigma2)/2`, including cross-covariances. Ratio contrasts
#' cancel a common population scale. Difference contrasts use the full joint
#' positive-slope covariance. Extra output includes `PValue` for zero log contrast
#' (ratio one) or difference zero; Bonferroni applies to these p-values too.
#' Containment of one for an individual relative slope is not a pairwise test.
#' The matched [compare_mfrm()] LRT tests all relative slopes equal jointly.
#'
#' Sandwich inference concerns the working model's limiting parameter; it
#' does not correct bias, informative assignment or a wrong population model.
#' It needs many independent clusters. Rank-deficient cluster scores withhold
#' intervals. Scores aggregate complete Person response vectors, including
#' population-parameter derivatives and the fitted quadrature method.
#' Small, incomplete correctly specified samples already showed undercoverage
#' and extremely wide model intervals; see the GPCM scope vignette. The added
#' methods do not imply universal finite-sample coverage. For an explicit
#' model-based refit alternative use [bootstrap_mfrm_gpcm()].
#' Reanalysis of saved fits also evaluates standardized slope differences;
#' it must not be confused with the earlier relative-difference evidence or
#' with refitting all datasets under the current estimator. See the GPCM scope
#' vignette for these distinct targets and the observed limits of approximation.
#'
#' Joint-information calculation is shared with IC/LRT qualification. Option
#' `mfrmr.max_information_bytes` (default 256 MiB) budgets eight dense p-by-p
#' matrices before allocation, or twenty when weak-information refinement is
#' needed. The extra budget is checked before refinement. This workspace estimate excludes response data,
#' quadrature and other allocations and is not a process memory guarantee.
#' A budget refusal retains unavailable results and a reason. There is no
#' separate 80-parameter inference cutoff. Computation still grows with p.
#'
#' [diagnose_mfrm()] returns the default relative/model 95% calculation in
#' `parameter_uncertainty$slopes`; `fit_mfrm(attach_diagnostics = TRUE)`
#' attaches it to `fit$slopes`. `CIEligible` is output-specific and does not
#' promote the fit's global boundary certificate or other parameter intervals.
#' This method recomputes uncertainty for saved fits; it does not trust old
#' interval flags or alter the supplied object.
#' @references Zeileis, A. (2006). Object-Oriented Computation of Sandwich
#'   Estimators. Journal of Statistical Software, 16(9), 1--16.
#'   \doi{10.18637/jss.v016.i09}.
#'
#'   Zeileis, A., Koll, S., and Graham, N. (2020). Various Versatile Variances:
#'   An Object-Oriented Implementation of Clustered Covariances in R.
#'   Journal of Statistical Software, 95(1), 1--36. \doi{10.18637/jss.v095.i01}.
#' @seealso [gpcm_capability_matrix()], [build_weighting_review()]
#' @examples
#' # After fitting a GPCM with method = "MML":
#' # intervals <- confint(fit, parm = "slopes", level = 0.95)
#' # attr(intervals, "diagnostics")[, c("SlopeFacet", "Estimate",
#' #   "CIEligible", "InferenceReview")]
#' @export
confint.mfrm_fit <- function(object, parm = "slopes", level = .95,
                              scale = c("relative", "standardized"), contrasts = NULL,
                              contrast_scale = c("ratio", "difference"),
                              method = c("model", "sandwich"), clusters = NULL,
                              adjust = FALSE, simultaneous = c("none", "bonferroni"), ...) {
  rlang::check_dots_empty()
  scale <- match.arg(scale); contrast_scale <- match.arg(contrast_scale)
  method <- match.arg(method); simultaneous <- match.arg(simultaneous)
  if (!identical(parm, "slopes")) stop("Use parm = 'slopes'; this method supplies GPCM slope intervals and comparisons.", call. = FALSE)
  if (!is.numeric(level) || is.complex(level) || length(level) != 1L || !is.finite(level) || level <= 0 || level >= 1) {
    stop("`level` must be one finite number strictly between zero and one.", call. = FALSE)
  }
  if (inherits(object, "mfrm_imported_fit") || !identical(object$config$model, "GPCM") ||
      !identical(object$config$method, "MML")) {
    stop("Slope intervals require a native GPCM fit with method = 'MML'.", call. = FALSE)
  }
  if (scale == "relative" && is.null(contrasts) && method == "model" &&
      is.null(clusters) && identical(adjust, FALSE) && simultaneous == "none") {
    tab <- compute_mml_structural_parameter_se(object, ci_level = level)$slopes
    out <- mfrm_gpcm_interval_result(tab, level, "Joint-information log-Wald approximation",
      "Relative GPCM slopes (geometric mean one)")
    attr(out, "source") <- mfrm_gpcm_inference_source(object)
    attr(out, "cautions") <- unique(tab$InferenceCaution[nzchar(tab$InferenceCaution)])
    if (length(attr(out, "cautions"))) warning(paste(attr(out, "cautions"), collapse = " "), call. = FALSE)
    return(out)
  }
  inference <- mfrm_gpcm_inference(object, method, clusters, adjust)
  if (!is.null(inference$check$caution)) warning(inference$check$caution, call. = FALSE)
  target <- mfrm_gpcm_slope_target(object, scale, contrasts, contrast_scale)
  n <- length(target$value)
  cov <- if (isTRUE(inference$check$eligible)) symmetrize_matrix(
    target$jacobian %*% inference$covariance %*% t(target$jacobian)) else matrix(NA_real_, n, n)
  dimnames(cov) <- list(target$labels, target$labels)
  se <- covariance_diag_se(cov)
  eligible <- isTRUE(inference$check$eligible) & is.finite(se) & se > 0
  critical <- stats::qnorm(1 - (1-level)/(2 * if (simultaneous == "bonferroni") n else 1))
  low <- target$value - critical * se; high <- target$value + critical * se
  if (target$log_scale) { low <- exp(low); high <- exp(high) }
  eligible <- eligible & is.finite(low) & is.finite(high) & (!target$log_scale | low > 0)
  low[!eligible] <- high[!eligible] <- NA_real_
  p <- 2 * stats::pnorm(-abs(target$value/se))
  if (simultaneous == "bonferroni") p <- pmin(1, n*p)
  p[!eligible] <- NA_real_
  review <- rep(inference$check$review, n)
  if (isTRUE(inference$check$eligible)) {
    review[eligible] <- paste("Approximate inference for", target$target,
      "with", method, "covariance; finite-sample coverage is not guaranteed.", inference$check$caution %||% "")
    review[!eligible] <- "Nonpositive variance or nonrepresentable interval bounds."
  }
  tab <- data.frame(SlopeFacet = target$labels, Estimate = target$estimate,
    SE = ifelse(eligible, if (target$log_scale) target$estimate * se else se, NA_real_),
    LogSE = if (target$log_scale) ifelse(eligible, se, NA_real_) else NA_real_,
    CI_Lower = low, CI_Upper = high, CI_Level = level, CIEligible = eligible,
    SEEligible = eligible, CIUse = ifelse(eligible, if (simultaneous == "none") "approximate_pointwise" else
      "approximate_bonferroni", "unavailable"), PValue = p,
    NullValue = if (target$log_scale) 1 else 0, InferenceReview = review)
  out <- mfrm_gpcm_interval_result(tab, level,
    paste(if (method == "model") "Joint-information" else "Cluster-sandwich",
      if (target$log_scale) "log-Wald approximation" else "delta-Wald approximation"),
    target$target, simultaneous, cov)
  attr(out, "settings") <- list(scale = scale, contrasts = target$contrasts,
    contrast_scale = contrast_scale, method = method, clusters = inference$clusters,
    adjustment_factor = inference$adjustment_factor %||% 1,
    covariance_scale = if (target$log_scale) "log" else "identity")
  attr(out, "source") <- mfrm_gpcm_inference_source(object)
  attr(out, "cautions") <- inference$check$caution
  out
}

#' @export
#' @noRd
print.mfrm_slope_intervals <- function(x, digits = max(3L, getOption("digits") - 3L), ...) {
  tab <- attr(x, "diagnostics")
  cat(sprintf("Approximate %g%% intervals: %s\n", 100 * attr(x, "level"), attr(x, "target")))
  print(data.frame(Level = rownames(x), Estimate = tab$Estimate,
    Lower = as.numeric(x[, 1]), Upper = as.numeric(x[, 2])),
    row.names = FALSE, digits = digits, ...)
  cat(attr(x, "method"), "\n")
  cat(if (identical(attr(x, "simultaneous"), "bonferroni"))
    "Bonferroni family: all targets requested in this call.\n" else "Pointwise intervals.\n")
  if (!is.null(attr(x, "expected_tail_draws"))) {
    cat("Expected bootstrap draws per tail:", format(attr(x, "expected_tail_draws"), digits = 3), "\n")
    if (attr(x, "expected_tail_draws") < 10) cat("Few tail draws: increase nsim to assess endpoint stability.\n")
  }
  for (caution in attr(x, "cautions")) cat("Caution:", caution, "\n")
  unavailable <- !tab$CIEligible
  if (any(unavailable)) {
    cat("Unavailable intervals:", sum(unavailable), "\n")
    for (reason in unique(tab$InferenceReview[unavailable])) cat("  ", reason, "\n", sep = "")
  }
  invisible(x)
}
