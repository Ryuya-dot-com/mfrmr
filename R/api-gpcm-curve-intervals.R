#' Uncertainty in GPCM category probabilities and information curves
#'
#' Evaluate specified rating contexts at known ability values and propagate the
#' full calibration covariance to category probabilities or per-rating Fisher
#' information. This is uncertainty in a fitted curve, not a Person score interval.
#'
#' @param fit An eligible native GPCM MML fit.
#' @param newdata Data frame with each fitted non-Person facet and a numeric
#'   `Theta` column. Each row is one rating context at one known ability value.
#'   Use original facet labels. Unknown levels and missing inputs are refused.
#' @param type `"probability"` (one row per category) or `"information"`
#'   (one row per supplied context/ability). Information is per rating, not a
#'   sum over all observed exposures as in [compute_information()].
#' @param method,clusters,adjust,level,simultaneous As in [confint.mfrm_fit()].
#' @param x A saved `mfrm_curve_intervals` result.
#' @param title,subtitle Optional plot text; NULL removes it.
#' @param palette Optional vector of colors, one per category/series. Line
#'   types distinguish series in addition to color. The default is colorblind friendly.
#' @param draw Draw the ggplot immediately? Default TRUE; FALSE returns it only.
#' @param caption Optional plot caption. If omitted, unavailable intervals are
#'   counted and explained. NULL removes the caption without removing markers
#'   or the reasons in the saved table.
#' @param ... Unused.
#'
#' @details The complete GPCM predictor, including fitted facet interactions,
#'   is evaluated from the free parameter vector. A central-difference Jacobian
#'   propagates the full joint covariance. Probability limits use a logit delta
#'   approximation; information limits use a log delta approximation for
#'   `slope^2 * Var(category | Theta, context)`. Bounds respect their support.
#'   Rounded probabilities zero/one and nonpositive information keep the point
#'   but have unavailable intervals. The supplied Theta values are fixed on
#'   the fitted native scale; their estimation uncertainty is not included.
#'   Estimated population parameters enter the joint covariance as nuisance
#'   parameters, not as a request to transform or integrate the Theta grid.
#'
#'   Bonferroni applies to the finite collection of all output rows in this
#'   call, not to the continuous curve between them. Ribbons connect grid-point
#'   intervals for display. Sandwich interpretation and independence assumptions
#'   are those of [confint.mfrm_fit()]. These are asymptotic approximations;
#'   numerical agreement does not establish sampling coverage.
#'   A reanalysis of saved correctly specified GPCM fits found substantial
#'   undercoverage for probability intervals in small incomplete designs,
#'   including Bonferroni-adjusted finite-grid families. Adjustment cannot
#'   repair inaccurate marginal approximations. Refitting every dataset in the
#'   affected unequal-rater-slope condition with the updated optimizer left
#'   its interval results unchanged. See the GPCM scope vignette
#'   for the evaluated grid, denominators and source limitations; an available
#'   interval is not a finite-sample coverage certification.
#'   Printing and the default plot subtitle identify the approximation.
#'   Custom plot text may omit that description; retain the method and its
#'   limitations in the figure legend or accompanying report.
#'   Crosses mark retained estimates whose intervals are unavailable. Ribbons
#'   stop at unavailable grid points; a missing ribbon does not mean zero
#'   uncertainty. Consult the table's `InferenceReview` for each reason.
#'
#' @return A `mfrm_curve_intervals` list with `table`, `settings`, and the exact
#'   `newdata`. Its plot method returns a ggplot with the plotted data available
#'   in `plot$data`; titles can be omitted and the plot can be customized.
#' @seealso [confint.mfrm_fit()], [category_curves_report()], [compute_information()]
#' @details A numerically verified but ill-conditioned information inverse can
#'   supply intervals with a warning, as described in [confint.mfrm_fit()].
#'   The warning is saved in `cautions` and the table's `InferenceReview`, and
#'   appears in printing and the default plot subtitle. A custom subtitle,
#'   including NULL, changes the display without removing saved diagnostics.
#' @examples
#' # After fitting a GPCM:
#' # grid <- expand.grid(Theta = seq(-3, 3, length.out = 41),
#' #                     Rater = "R01", Criterion = "C01")
#' # curves <- mfrm_curve_intervals(fit, grid)
#' # plot(curves, title = NULL, subtitle = NULL)
#' @export
mfrm_curve_intervals <- function(fit, newdata, type = c("probability", "information"),
    method = c("model", "sandwich"), clusters = NULL, adjust = FALSE,
    level = .95, simultaneous = c("none", "bonferroni")) {
  type <- match.arg(type); method <- match.arg(method); simultaneous <- match.arg(simultaneous)
  mfrm_random_rater_interval_level(level)
  inference <- mfrm_gpcm_inference(fit, method, clusters, adjust)
  if (!is.null(inference$check$caution)) warning(inference$check$caution, call. = FALSE)
  facets <- fit$config$facet_names
  required <- c("Theta", facets)
  if ("Theta" %in% facets || !is.data.frame(newdata) || !nrow(newdata) ||
      anyDuplicated(names(newdata)) || !all(required %in% names(newdata)) ||
      !is.numeric(newdata$Theta) || is.complex(newdata$Theta) || any(!is.finite(newdata$Theta))) {
    stop("`newdata` needs finite numeric Theta and every non-Person facet column; Theta is reserved for ability.", call. = FALSE)
  }
  newdata <- as.data.frame(newdata[required])
  prep <- fit$prep
  prep$data <- data.frame(Person = factor(rep(fit$prep$levels$Person[1], nrow(newdata)),
    levels = fit$prep$levels$Person), score_k = 0L, Weight = 1)
  for (facet in facets) {
    values <- as.character(newdata[[facet]])
    if (anyNA(values) || any(!values %in% fit$prep$levels[[facet]])) {
      stop("Unknown or missing level in facet ", facet, ".", call. = FALSE)
    }
    prep$data[[facet]] <- factor(values, levels = fit$prep$levels[[facet]])
  }
  config <- fit$config; sizes <- build_param_sizes(config)
  idx <- build_indices(prep, config$step_facet, config$slope_facet, config$interaction_specs)
  evaluate <- function(par) {
    params <- expand_params(par, sizes, config)
    cum <- t(apply(params$steps_mat, 1L, function(x) c(0, cumsum(x))))
    p <- category_prob_gpcm(newdata$Theta + compute_base_eta(idx, params, config),
      cum, idx$step_idx, params$slopes, idx$slope_idx)
    if (type == "probability") return(as.vector(t(p)))
    k <- seq_len(ncol(p))-1L
    variance <- drop(p %*% k^2) - drop(p %*% k)^2
    pmax(0, variance) * params$slopes[idx$slope_idx]^2
  }
  estimate <- evaluate(fit$opt$par)
  n <- length(estimate)
  se <- rep(NA_real_, n)
  reason <- rep(if (isTRUE(inference$check$eligible))
    paste("Approximate calibration uncertainty at fixed ability and rating context; finite-sample coverage is not guaranteed.",
      inference$check$caution %||% "")
    else inference$check$review, n)
  if (isTRUE(inference$check$eligible)) {
    jac <- mfrmr_numeric_transformation_jacobian(evaluate, fit$opt$par, relative_step = 1e-5)
    if (jac$valid) {
      variance <- rowSums((jac$jacobian %*% inference$covariance) * jac$jacobian)
      se <- ifelse(variance >= 0, sqrt(pmax(0, variance)), NA_real_)
    } else reason[] <- "The curve derivative could not be evaluated."
  }
  transform <- if (type == "probability") stats::qlogis else log
  inverse <- if (type == "probability") stats::plogis else exp
  interior <- is.finite(estimate) & estimate > 0 & (type != "probability" | estimate < 1)
  link_se <- se / if (type == "probability") (estimate * (1-estimate)) else estimate
  critical <- stats::qnorm(1-(1-level)/(2 * if (simultaneous == "bonferroni") n else 1))
  low <- high <- rep(NA_real_, n)
  usable <- interior & is.finite(link_se) & link_se > 0 & isTRUE(inference$check$eligible)
  low[usable] <- inverse(transform(estimate[usable]) - critical*link_se[usable])
  high[usable] <- inverse(transform(estimate[usable]) + critical*link_se[usable])
  usable <- usable & is.finite(low) & is.finite(high)
  low[!usable] <- high[!usable] <- NA_real_
  reason[!interior] <- "The fitted curve is at a numerical support boundary; an interval is unavailable."
  reason[interior & !usable & isTRUE(inference$check$eligible)] <- "Nonpositive variance, unavailable derivative or nonrepresentable interval."
  k <- if (type == "probability") fit$config$n_cat else 1L
  tab <- newdata[rep(seq_len(nrow(newdata)), each = k), , drop = FALSE]
  tab$InputRow <- rep(seq_len(nrow(newdata)), each = k)
  tab$Category <- if (type == "probability") rep(fit$prep$score_map$OriginalScore[
    match(seq_len(k)-1L+fit$prep$rating_min, fit$prep$score_map$InternalScore)], nrow(newdata)) else NA_real_
  tab$Estimate <- estimate; tab$SE <- se; tab$Lower <- low; tab$Upper <- high
  tab$CIEligible <- usable; tab$InferenceReview <- reason
  rownames(tab) <- NULL
  structure(list(table = tab, newdata = newdata, cautions = inference$check$caution,
    source = mfrm_gpcm_inference_source(fit),
    settings = list(type = type, method = method, clusters = inference$clusters,
      adjust = adjust, level = level, simultaneous = simultaneous, facets = facets,
      target = "Calibration uncertainty at fixed native-scale ability and rating context")),
    class = "mfrm_curve_intervals")
}

#' @rdname mfrm_curve_intervals
#' @export
print.mfrm_curve_intervals <- function(x, ...) {
  cat("GPCM", x$settings$type, "curve intervals:", x$settings$method, "covariance\n")
  print(x$table[setdiff(names(x$table), "InferenceReview")], row.names = FALSE)
  cat("Available:", sum(x$table$CIEligible), "of", nrow(x$table),
    "; fixed ability values, calibration uncertainty only.\n")
  cat("Approximate intervals; numerical availability does not establish nominal coverage.\n")
  for (reason in unique(x$table$InferenceReview[!x$table$CIEligible])) {
    cat("  ", reason, "\n", sep = "")
  }
  for (caution in x$cautions) cat("Caution:", caution, "\n")
  invisible(x)
}

#' @rdname mfrm_curve_intervals
#' @export
plot.mfrm_curve_intervals <- function(x, title = "GPCM curve uncertainty",
    subtitle = paste("Approximate calibration intervals; fixed ability", x$settings$method,
      paste0(100*x$settings$level, "%"),
      if (x$settings$simultaneous == "none") "pointwise" else "Bonferroni grid points", sep = " | "),
    palette = NULL, draw = TRUE, caption = NULL, ...) {
  rlang::check_dots_empty()
  if (missing(subtitle) && length(x$cautions)) subtitle <- paste(subtitle,
    paste(x$cautions, collapse = " "), sep = "\n")
  if (!requireNamespace("ggplot2", quietly = TRUE)) stop("Install ggplot2 to plot curve intervals.", call. = FALSE)
  tab <- x$table
  if (missing(caption) && any(!tab$CIEligible)) caption <- paste(
    "Intervals unavailable at", sum(!tab$CIEligible), "of", nrow(tab),
    "points. Crosses mark retained estimates; see the result table for reasons.")
  if (!is.null(subtitle)) subtitle <- paste(strwrap(subtitle, width = 75), collapse = "\n")
  if (!is.null(caption)) caption <- paste(strwrap(caption, width = 85), collapse = "\n")
  tab$Context <- apply(tab[x$settings$facets], 1L, function(z)
    paste(paste(x$settings$facets, z, sep = " = "), collapse = ", "))
  tab$Series <- if (x$settings$type == "probability") factor(tab$Category) else factor("Information")
  # Keep a ribbon from bridging over an unavailable point in a series.
  index <- order(tab$Context, tab$Series, tab$Theta, tab$InputRow)
  tab$IntervalGroup <- integer(nrow(tab))
  tab$IntervalGroup[index] <- cumsum(!tab$CIEligible[index])
  tab$IntervalGroup <- interaction(tab$Context, tab$Series, tab$IntervalGroup, drop = TRUE)
  if (is.null(palette)) palette <- rep(c("#0072B2", "#D55E00", "#009E73", "#CC79A7", "#E69F00", "#000000"),
    length.out = nlevels(tab$Series))
  if (!is.character(palette) || length(palette) < nlevels(tab$Series) || anyNA(palette)) stop("Supply one color per series.", call. = FALSE)
  p <- ggplot2::ggplot(tab, ggplot2::aes(x = .data$Theta, y = .data$Estimate,
    color = .data$Series, fill = .data$Series, linetype = .data$Series, group = .data$Series)) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = .data$Lower, ymax = .data$Upper,
      group = .data$IntervalGroup), alpha = .15, color = NA, na.rm = TRUE,
      show.legend = any(tab$CIEligible)) + ggplot2::geom_line(linewidth = .7) +
    ggplot2::facet_wrap(~Context) + ggplot2::scale_color_manual(values = palette) +
    ggplot2::scale_fill_manual(values = palette) +
    ggplot2::scale_linetype_manual(values = rep(c("solid", "dashed", "dotted", "dotdash", "longdash", "twodash"), length.out = nlevels(tab$Series))) +
    ggplot2::labs(title = title, subtitle = subtitle, caption = caption, x = "Ability (native scale)",
      y = if (x$settings$type == "probability") "Category probability" else "Information per rating",
      color = if (x$settings$type == "probability") "Category" else "Series",
      fill = if (x$settings$type == "probability") "Category" else "Series",
      linetype = if (x$settings$type == "probability") "Category" else "Series",
      alt = paste("GPCM", x$settings$type, "curves with", 100*x$settings$level,
        "percent", if (x$settings$simultaneous == "none") "pointwise" else "Bonferroni-adjusted",
        "intervals;", sum(!tab$CIEligible), "unavailable grid-point intervals.",
        "Crosses mark estimates without intervals; ribbons do not bridge unavailable points.")) +
    ggplot2::theme_minimal() + ggplot2::theme(plot.subtitle = ggplot2::element_text(size = 9))
  if (any(!tab$CIEligible)) p <- p +
    ggplot2::geom_point(data = tab[!tab$CIEligible, , drop = FALSE],
      ggplot2::aes(shape = "Unavailable"), color = "#333333", size = 2.5,
      show.legend = c(shape = TRUE, color = FALSE, fill = FALSE, linetype = FALSE)) +
    ggplot2::scale_shape_manual(values = c(Unavailable = 4), name = "Interval")
  attr(p, "mfrmr_plot_data") <- new_mfrm_plot_data("gpcm_curve_intervals",
    list(table = tab, settings = x$settings, title = title, subtitle = subtitle, caption = caption))
  if (isTRUE(draw)) print(p)
  invisible(p)
}
