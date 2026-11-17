# Output-specific qualification, separate from the global boundary audit.
mfrm_gpcm_slope_inference_check <- function(fit, covariance, allow_singleton = FALSE) {
  refuse <- function(reason) list(eligible = FALSE, review = reason)
  if (!identical(fit$config$model, "GPCM") || !identical(fit$config$method, "MML")) {
    return(refuse("Relative-slope intervals require a native GPCM MML fit."))
  }
  if (length(mfrmr_mml_additive_boundary_evidence(fit$config)))
    return(refuse("The full model has no finite maximum along a free location or endpoint path. Ordinary slope intervals are unavailable; finite coordinates are optimizer values."))
  if (!is.null(fit$config$gpcm_limit_source))
    return(refuse("Ordinary intervals after a data-dependent limiting-likelihood reduction are not qualified."))
  if (!identical(covariance$status, "ok") || isTRUE(covariance$regularized) ||
      is.null(covariance$solution_information)) {
    return(refuse(trimws(paste("Fresh, unregularized joint MML information is required.",
      covariance$detail %||% ""))))
  }
  spec <- fit$config$gpcm_spec
  tab <- fit$slopes
  slice <- covariance$param_slices[["log_slopes"]]
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
  check$anchor_note <- mfrm_gpcm_anchor_note(fit)
  if (length(check$anchor_note)) check$review <- paste(check$review, check$anchor_note)
  check
}

mfrm_update_slope_readiness_parameters <- function(parameters, slopes) {
  if (!nrow(parameters) || !nrow(slopes) || !"SlopeFacet" %in% names(slopes)) return(parameters)
  index <- rep(NA_integer_, nrow(parameters))
  selected <- which(parameters$ParameterClass == "gpcm_slope")
  index[selected] <- mfrm_match_slope_table(parameters$Facet[selected], parameters$Level[selected], slopes)
  keep <- !is.na(index)
  fields <- intersect(c("PrimaryEstimate", "PrimaryLogEstimate", "ParameterStatus",
    "PrimaryEstimateBasis", "SEEligible", "CIEligible"), names(slopes))
  parameters[keep, fields] <- as.data.frame(slopes)[index[keep], fields, drop = FALSE]
  parameters
}

#' Confidence intervals for native fit coefficients and GPCM slopes
#'
#' @description
#' Compute pointwise Wald intervals for free `coef(object)` coordinates in
#' native MML/CML fits (`parm = NULL`), positive GPCM discriminations and slope
#' contrasts (`parm = "slopes"`), or two-family GPCM step offsets (`parm =
#' "steps"`). Inspect `attr(ci, "diagnostics")` (`CIEligible`,
#' `CoverageQualified`, `InferenceReview`) alongside returned bounds.
#'
#' @param object Native MML or CML [fit_mfrm()] result (JML structural intervals
#'   are unsupported).
#' @param parm `NULL` (free `coef(object)` coordinates), character/integer
#'   subset, `"slopes"` (GPCM discriminations), or `"steps"` (two-family GPCM
#'   within-level step offsets).
#' @param level Confidence level in `(0, 1)` (default `0.95`).
#' @param scale For `parm = "slopes"`: `"relative"` (one-family default,
#'   geometric mean `1`) or `"standardized"` (population SD times slope,
#'   including estimated-SD covariance; required default for two-family fits).
#' @param contrasts Optional named zero-sum contrast matrix across
#'   slope levels and scale (`"ratio"` exponentiating log contrasts or
#'   `"difference"` via delta method).
#' @param contrast_scale Optional named zero-sum contrast matrix across
#'   slope levels and scale (`"ratio"` exponentiating log contrasts or
#'   `"difference"` via delta method).
#' @param method `"model"` (inverse full joint observed information),
#'   `"sandwich"` (Person/cluster marginal-likelihood score sandwich for
#'   one-family GPCM), or experimental `"profile"` (chi-square(1) deviance
#'   profile reoptimizing all nuisance parameters for one `slope`).
#' @param clusters Optional Person-to-Cluster `data.frame` and `G/(G - 1)`
#'   factor (`FALSE` default) for `method = "sandwich"`.
#' @param adjust Optional Person-to-Cluster `data.frame` and `G/(G - 1)`
#'   factor (`FALSE` default) for `method = "sandwich"`.
#' @param simultaneous `"none"` (pointwise default) or `"bonferroni"` across
#'   rows in the current call.
#' @param ... Unused; additional arguments are rejected.
#' @param slope Required target level for `method = "profile"`
#'   (e.g., `"R01"` or named `c(Task = "t1")` in two-family fits) and search
#'   budget list (`maxit = 400`, `max_steps = 8`, `initial_step = 0.5`).
#' @param profile_control Required target level for `method = "profile"`
#'   (e.g., `"R01"` or named `c(Task = "t1")` in two-family fits) and search
#'   budget list (`maxit = 400`, `max_steps = 8`, `initial_step = 0.5`).
#'
#' @details
#' **Free coefficients and GPCM slopes.** Default coefficient intervals use
#' \eqn{\hat b_j \pm z_{(1+\mathrm{level})/2}\sqrt{V_{jj}}} from qualified
#' `vcov(object)`. For `parm = "slopes"`, free log-slope covariance
#' \eqn{V_\eta} from the **full joint** observed information expands via
#' \eqn{J V_\eta J^\top} to `G` sum-zero log slopes with bounds
#' \eqn{\exp(\log \hat a_g \pm z\,\mathrm{SE}(\log \hat a_g))} (requiring
#' `quad_points >= 31`, unit weights, positive unregularized curvature, and no
#' marginal response-dimension rank deficit; dense Hessian allocation respects
#' `options(mfrmr.max_information_bytes = 256 * 1024^2)`).
#'
#' **Two-family and profile checks.** Two-family log-Wald and `"steps"`
#' intervals differentiate the fitted fixed-grid EM or moving-node adaptive
#' marginal objective, verifying SE-scaled score length `\sqrt{g'Vg} <= 0.01`
#' and `2*q - 1` quadrature stability (`CIEligible` vs `CoverageQualified =
#' FALSE`). Profile intervals verify agreement of retained and neutral starts
#' (`<= 1e-5` NLL), positive-definite nuisance Hessians at both quadrature
#' orders, and endpoint LR residuals `<= 1e-4`, storing scans in
#' `attr(ci, "profile")` and Wald comparisons in `attr(ci, "wald")`.
#'
#' @return Numeric `Lower`/`Upper` matrix (class `mfrm_slope_intervals` for
#'   `parm = "slopes"`, or `mfrm_facet_intervals` for two-family `parm =
#'   "steps"`) with `diagnostics`, `checks`, and `method` attributes.
#'
#' @references
#' - Fischer, S. M., & Lewis, M. A. (2021). *Statistics and Computing*, 31, 38.
#'   \doi{10.1007/s11222-021-10012-y}.
#' - Zeileis, A., Koell, S., & Graham, N. (2020). *J. Stat. Softw.*, 95(1),
#'   1--36. \doi{10.18637/jss.v095.i01}.
#' @seealso [mfrmr_output_guide()], [mfrmr_gpcm_scope], [bootstrap_mfrm_gpcm()]
#' @examples
#' # Long-running workflow; run explicitly when needed.
#' # example("confint.mfrm_fit", run.dontrun = TRUE)
#' \dontrun{
#' # Compare intervals for free coefficients and relative discriminations.
#' # Reuse the synthetic GPCM fit; estimation uses 61 quadrature points.
#' # Full regeneration recipe: examples/measurement-fits.R in the package.
#' fit <- readRDS(system.file("examples", "measurement-fits.rds",
#'   package = "mfrmr", mustWork = TRUE))$gpcm
#' # The default matches coef(fit): steps, locations and log slopes.
#' coefficients_ci <- confint(fit, level = 0.95)
#' head(cbind(Estimate = coef(fit), coefficients_ci))
#' attr(coefficients_ci, "diagnostics") # Availability and interpretation
#' # Missing bounds do not erase retained points; report the reason too.
#' # Explicitly request positive relative slopes for rater comparison:
#' intervals <- confint(fit, parm = "slopes", level = 0.95)
#' intervals
#' attr(intervals, "diagnostics")[, c("SlopeFacet", "Estimate",
#'   "CIEligible", "InferenceReview")]
#' # Relative slopes have geometric mean one. A value above one means a
#' # steeper response curve, not greater severity or better rater quality.
#' # Missing bounds need the saved reason; availability is not a coverage test.
#' plot(intervals)
#' file <- tempfile(fileext = ".rds")
#' saveRDS(intervals, file) # Use a lasting path for your analysis
#' saved <- readRDS(file)
#' apa_table(saved) # Reuse the intervals without fitting again
#'
#' # A separate, prespecified profile calculation can be requested with
#' # confint(fit, parm = "slopes", method = "profile", slope = chosen_rater).
#' # Choose chosen_rater from fit$slopes$SlopeFacet; see the profile section.
#' }
#' @export
confint.mfrm_fit <- function(object, parm = NULL, level = .95,
                              scale = c("relative", "standardized"), contrasts = NULL,
                              contrast_scale = c("ratio", "difference"),
                              method = c("model", "sandwich", "profile"), clusters = NULL,
                              adjust = FALSE, simultaneous = c("none", "bonferroni"), ...,
                              slope = NULL, profile_control = list()) {
  rlang::check_dots_empty()
  if (!is.numeric(level) || is.complex(level) || is.object(level) || !is.null(dim(level)) ||
      length(level) != 1L || !is.finite(level) || level <= 0 || level >= 1)
    stop("`level` must be one finite number strictly between zero and one.", call. = FALSE)
  level <- unname(level)
  if (identical(parm, "steps") && mfrm_has_product_slopes(object)) {
    if (!missing(scale) || !missing(contrasts) || !missing(contrast_scale) ||
        !missing(clusters) || !missing(adjust) || !missing(simultaneous) ||
        !missing(slope) || !missing(profile_control) || match.arg(method) != "model")
      stop("Two-family step intervals accept only level and method = 'model'; slope, profile, sandwich and simultaneous options are unavailable.", call. = FALSE)
    return(mfrm_gpcm_step_intervals(object, level))
  }
  if (!identical(parm, "slopes") || inherits(object, c("mfrm_cml_fit", "mfrm_comparison_fit"))) {
    if (!missing(scale) || !missing(contrasts) || !missing(contrast_scale) ||
        !missing(method) || !missing(clusters) || !missing(adjust) ||
        !missing(simultaneous) || !missing(slope) || !missing(profile_control))
      stop("Slope-specific options require parm = 'slopes'. Default intervals use the coef()/vcov() coordinates; use mfrm_facet_intervals() for facet contrasts or sandwich intervals.", call. = FALSE)
    return(mfrm_coefficient_intervals(object, parm, level))
  }
  stop_if_jml_adjustment(object, "confint()")
  product <- mfrm_has_product_slopes(object)
  if (product && missing(scale)) scale <- "standardized"
  scale <- match.arg(scale); contrast_scale <- match.arg(contrast_scale)
  method <- match.arg(method); simultaneous <- match.arg(simultaneous)
  if (inherits(object, "mfrm_imported_fit") || !identical(object$config$model, "GPCM") ||
      !identical(object$config$method, "MML")) {
    stop("Slope intervals require a native GPCM fit with method = 'MML'.", call. = FALSE)
  }
  if (product && (!method %in% c("model", "profile") || scale != "standardized" ||
      !is.null(contrasts) || !is.null(clusters) || !identical(adjust,FALSE))) {
    stop("Two-family intervals currently require method = 'model' or 'profile', scale = 'standardized', and no contrasts or cluster adjustments. The first family has geometric mean one; the second is free on fixed N(0,1).", call. = FALSE)
  }
  if (method == "profile") {
    if ((!product && scale != "relative") || !is.null(contrasts) || !is.null(clusters) ||
        !identical(adjust, FALSE) || simultaneous != "none")
      stop(if (product) "Two-family profile intervals support one explicitly named owner/level, without contrasts or multiplicity adjustment." else
        "Profile intervals currently support one relative slope, without contrasts, sandwich adjustment or multiplicity adjustment.", call. = FALSE)
    return(mfrm_gpcm_profile_interval(object, slope, level, profile_control))
  }
  if (!is.null(slope) || length(profile_control))
    stop("`slope` and `profile_control` require method = 'profile'.", call. = FALSE)
  if (!product && scale == "relative" && is.null(contrasts) && method == "model" &&
      is.null(clusters) && identical(adjust, FALSE) && simultaneous == "none") {
    tab <- compute_mml_structural_parameter_se(object, ci_level = level)$slopes
    out <- mfrm_gpcm_interval_result(tab, level, "Joint-information log-Wald approximation",
      "Relative GPCM slopes (geometric mean one)")
    attr(out, "source") <- mfrm_gpcm_inference_source(object)
    attr(out, "anchor_note") <- mfrm_gpcm_anchor_note(object)
    attr(out, "cautions") <- unique(tab$InferenceCaution[nzchar(tab$InferenceCaution)])
    if (length(attr(out, "cautions"))) warning(paste(attr(out, "cautions"), collapse = " "), call. = FALSE)
    return(out)
  }
  inference <- if (product) mfrm_gpcm_product_inference(object) else
    mfrm_gpcm_inference(object, method, clusters, adjust)
  mfrm_gpcm_intervals_from_inference(object, inference, level, scale, contrasts,
    contrast_scale, method, simultaneous)
}

# Internal consumers share one fresh qualification for this exact calibration.
# Public option validation remains in confint.mfrm_fit().
mfrm_gpcm_intervals_from_inference <- function(object, inference, level = .95,
    scale = "standardized", contrasts = NULL, contrast_scale = "ratio",
    method = "model", simultaneous = "none") {
  stop_if_jml_adjustment(object, "confint()")
  if (inherits(object, "mfrm_imported_fit") || !identical(object$config$model, "GPCM") ||
      !identical(object$config$method, "MML")) {
    stop("Slope intervals require a native GPCM fit with method = 'MML'.", call. = FALSE)
  }
  product <- mfrm_has_product_slopes(object)
  if (!is.null(inference$check$caution)) warning(inference$check$caution, call. = FALSE)
  target <- if (product) mfrm_gpcm_product_slope_targets(object$opt$par, object$config)$components else
    mfrm_gpcm_slope_target(object, scale, contrasts, contrast_scale)
  if (product) {
    # Display labels are not identity keys; separate owner/level columns persist.
    target$labels <- make.unique(paste(target$metadata$Owner, target$metadata$Level, sep=" = "))
    target$scale <- "standardized"
  }
  n <- length(target$value)
  cov <- if (isTRUE(inference$check$eligible)) symmetrize_matrix(
    target$jacobian %*% inference$covariance %*% t(target$jacobian)) else matrix(NA_real_, n, n)
  dimnames(cov) <- list(target$labels, target$labels)
  se <- covariance_diag_se(cov)
  eligible <- isTRUE(inference$check$eligible) & is.finite(se) & se > 0
  critical <- stats::qnorm((1-level)/(2 * if (simultaneous == "bonferroni") n else 1), lower.tail = FALSE)
  low <- target$value - critical * se; high <- target$value + critical * se
  if (target$log_scale) { low <- exp(low); high <- exp(high) }
  eligible <- eligible & is.finite(low) & is.finite(high) & (!target$log_scale | low > 0)
  low[!eligible] <- high[!eligible] <- NA_real_
  p <- 2 * stats::pnorm(-abs(target$value/se))
  if (simultaneous == "bonferroni") p <- pmin(1, n*p)
  p[!eligible | product] <- NA_real_
  review <- rep(inference$check$review, n)
  if (isTRUE(inference$check$eligible)) {
    review[eligible] <- paste("Approximate inference for", target$target,
      "with", method, "covariance; finite-sample coverage is not guaranteed.", inference$check$caution %||% "")
    if (length(inference$check$anchor_note)) {
      review[eligible] <- paste(review[eligible], inference$check$anchor_note)
    }
    review[!eligible] <- "Nonpositive variance or nonrepresentable interval bounds."
  }
  tab <- data.frame(SlopeFacet = target$labels, Estimate = target$estimate,
    SE = ifelse(eligible, if (target$log_scale) target$estimate * se else se, NA_real_),
    LogSE = if (target$log_scale) ifelse(eligible, se, NA_real_) else NA_real_,
    CI_Lower = low, CI_Upper = high, CI_Level = level, CIEligible = eligible,
    SEEligible = eligible, CIUse = ifelse(eligible, if (simultaneous == "none") "approximate_pointwise" else
      "approximate_bonferroni", "unavailable"), PValue = p,
    NullValue = if (product) NA_real_ else if (target$log_scale) 1 else 0, InferenceReview = review)
  if (product) {
    tab$CoverageQualified <- FALSE
    tab$SlopeOwner <- target$metadata$Owner
    tab$SlopeLevel <- target$metadata$Level
    tab$ScaleReference <- target$metadata$ScaleReference
  }
  out <- mfrm_gpcm_interval_result(tab, level,
    paste0(if (product) "Experimental " else "",
      paste(if (method == "model") "Joint-information" else "Cluster-sandwich",
        if (target$log_scale) "log-Wald approximation" else "delta-Wald approximation")),
    target$target, simultaneous, cov)
  attr(out, "settings") <- list(scale = scale, contrasts = target$contrasts,
    contrast_scale = contrast_scale, method = method, clusters = inference$clusters,
    adjustment_factor = inference$adjustment_factor %||% 1,
    covariance_scale = if (target$log_scale) "log" else "identity")
  attr(out, "anchor_note") <- inference$check$anchor_note
  if (product) {
    attr(out, "settings")$two_family <- TRUE
    attr(out, "settings")$integration <- object$config$estimation_control$mml_integration
    attr(out, "settings")$engine <- object$config$estimation_control$mml_engine_used
    attr(out, "scale_note") <- paste0(object$config$slope_facet[1],
      ": geometric mean one; ",object$config$slope_facet[2],
      ": free slopes with ability SD fixed at one. The families have different reference meanings.")
    attr(out, "checks") <- inference$checks
    attr(out, "numerical_checks") <- inference$numerical_checks
    attr(out, "score_rank") <- inference$score_rank
  }
  attr(out, "source") <- mfrm_gpcm_inference_source(object)
  attr(out, "cautions") <- inference$check$caution
  out
}

#' @rdname confint.mfrm_fit
#' @export
confint.mfrm_cml_fit <- function(object, parm = NULL, level = .95, ...) {
  confint.mfrm_fit(object, parm = parm, level = level, ...)
}

#' @rdname confint.mfrm_fit
#' @name confint.mfrm_comparison_fit
#' @aliases confint.mfrm_comparison_fit
#' @usage \method{confint}{mfrm_comparison_fit}(object, parm = NULL, level = 0.95, ...)
#' @rawNamespace S3method(confint,mfrm_comparison_fit,confint.mfrm_cml_fit)
NULL

#' @export
#' @noRd
print.mfrm_slope_intervals <- function(x, digits = max(3L, getOption("digits") - 3L), ...) {
  tab <- attr(x, "diagnostics")
  status <- mfrm_slope_interval_display(tab)
  cat(sprintf("Approximate %g%% interval results: %s\n", 100 * attr(x, "level"), attr(x, "target")))
  print(data.frame(Level = rownames(x), Estimate = tab$Estimate,
    Lower = as.numeric(x[, 1]), Upper = as.numeric(x[, 2]), Status = status),
    row.names = FALSE, digits = digits, ...)
  cat(attr(x, "method"), "\n")
  if (length(attr(x, "anchor_note"))) cat(attr(x, "anchor_note"), "\n")
  if (!is.null(attr(x,"scale_note"))) cat(attr(x,"scale_note"), "\n")
  cat(if (identical(attr(x, "simultaneous"), "bonferroni"))
    "Bonferroni family: all targets requested in this call.\n" else "Pointwise intervals.\n")
  if (!is.null(attr(x, "expected_tail_draws"))) {
    cat("Expected bootstrap draws per tail:", format(attr(x, "expected_tail_draws"), digits = 3), "\n")
    if (attr(x, "expected_tail_draws") < 10) cat("Few tail draws: increase nsim to assess endpoint stability.\n")
  }
  for (caution in attr(x, "cautions")) cat("Caution:", caution, "\n")
  unavailable <- !tab$CIEligible %in% TRUE
  if (any(status == "Incomplete")) cat(
    "Incomplete intervals retain computed bounds; NA is not infinity or a calibrated one-sided interval.\n")
  if (any(status == "Unavailable")) cat("Unavailable intervals:", sum(status == "Unavailable"), "\n")
  if (any(unavailable)) {
    cat("Intervals requiring review:", sum(unavailable), "\n")
    for (reason in unique(tab$InferenceReview[unavailable])) cat("  ", reason, "\n", sep = "")
  }
  invisible(x)
}
