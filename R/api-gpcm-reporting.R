# Saved GPCM inference is displayed and exported without refitting or changing
# the ordinary fit diagnostics. Tables always retain the requested target/method.
mfrm_gpcm_inference_tables <- function(x) {
  if (inherits(x, "mfrm_slope_intervals")) {
    tab <- attr(x, "diagnostics")
    tab <- tab[intersect(c("SlopeFacet", "Estimate", "SE", "LogSE", "CI_Lower", "CI_Upper",
      "NullValue", "PValue", "CIEligible", "InferenceReview"), names(tab))]
    tab$Target <- attr(x, "target"); tab$Method <- attr(x, "method")
    tab$ConfidenceLevel <- paste0(format(100 * attr(x, "level"), trim = TRUE), "%")
    tab$Adjustment <- if (attr(x, "simultaneous") == "none") "Pointwise" else "Bonferroni"
    tables <- list(intervals = tab)
    if (!is.null(attr(x, "availability"))) tables$availability <- attr(x, "availability")
    settings <- attr(x, "settings")
    if (!is.null(settings)) {
      tables$settings <- data.frame(Scale = settings$scale,
        SmallSampleFactor = settings$adjustment_factor %||% NA_real_,
        IndependentClusters = if (is.null(settings$clusters)) NA_integer_ else length(unique(settings$clusters$Cluster)),
        BootstrapSeed = settings$seed %||% NA_integer_)
      if (!is.null(settings$recheck)) tables$settings$Reanalysis <- settings$recheck
      if (!is.null(settings$diagnostic_checks_scope))
        tables$settings$DiagnosticChecksScope <- settings$diagnostic_checks_scope
      if (!is.null(settings$clusters)) tables$clusters <- settings$clusters
      if (!is.null(settings$contrasts)) tables$contrasts <- data.frame(
        Comparison = rownames(settings$contrasts), settings$contrasts, check.names = FALSE)
    }
    return(tables)
  }
  if (inherits(x, "mfrm_curve_intervals")) {
    tab <- x$table
    tab$Target <- x$settings$target; tab$Method <- x$settings$method
    tab$ConfidenceLevel <- paste0(format(100 * x$settings$level, trim = TRUE), "%")
    tab$Adjustment <- if (x$settings$simultaneous == "none") "Pointwise" else "Bonferroni"
    tables <- list(curves = tab, settings = data.frame(
      Covariance = x$settings$method, SmallSampleAdjustment = x$settings$adjust,
      IndependentClusters = if (is.null(x$settings$clusters)) NA_integer_ else length(unique(x$settings$clusters$Cluster))))
    if (!is.null(x$settings$clusters)) tables$clusters <- x$settings$clusters
    return(tables)
  }
  if (inherits(x, "mfrm_gpcm_bootstrap")) {
    tables <- if (is.null(x$test)) mfrm_gpcm_inference_tables(confint(x)) else list(test = x$test)
    tables$trials <- x$trials
    if (!is.null(x$checks)) tables$checks <- x$checks
    if (!is.null(x$source_checks)) tables$source_checks <- x$source_checks
    tables$sampling <- data.frame(Sampling = x$settings$sampling, Seed = x$settings$seed,
      Planned = nrow(x$trials), Available = sum(x$trials$Available))
    if (!is.null(x$settings$recheck)) tables$sampling$Reanalysis <- x$settings$recheck
    if (!is.null(x$settings$diagnostic_checks_scope))
      tables$sampling$DiagnosticChecksScope <- x$settings$diagnostic_checks_scope
    return(tables)
  }
  stop("Supply saved GPCM slope intervals, curve intervals or a GPCM bootstrap result.", call. = FALSE)
}

mfrm_gpcm_results_inputs <- function(fit, intervals) {
  if (is.null(intervals)) return(NULL)
  if (!inherits(fit, "mfrm_fit") || !identical(fit$config$model, "GPCM")) {
    stop("Saved GPCM inference requires its native GPCM fit.", call. = FALSE)
  }
  supported <- c("mfrm_slope_intervals", "mfrm_curve_intervals", "mfrm_gpcm_bootstrap")
  if (inherits(intervals, supported)) intervals <- list(inference = intervals)
  if (!is.list(intervals) || !length(intervals) || is.null(names(intervals)) ||
      anyNA(names(intervals)) || anyDuplicated(tolower(names(intervals))) ||
      any(!grepl("^[A-Za-z][A-Za-z0-9_]*$", names(intervals))) ||
      !all(vapply(intervals, inherits, logical(1), what = supported))) {
    stop("`intervals` must be a saved GPCM result or a named list of saved results; use distinct letter/number/underscore names.", call. = FALSE)
  }
  names(intervals) <- tolower(names(intervals))
  source <- mfrm_gpcm_inference_source(fit)
  for (x in intervals) {
    saved <- if (inherits(x, "mfrm_slope_intervals")) attr(x, "source") else
      if (inherits(x, "mfrm_gpcm_bootstrap")) mfrm_gpcm_inference_source(x$source) else x$source
    if (!identical(source, saved)) stop(
      "Saved GPCM inference must match the fitted parameters, data, population and integration settings. Recompute older intervals without source metadata.", call. = FALSE)
  }
  intervals
}

mfrm_gpcm_results_attach <- function(out, inputs) {
  if (is.null(inputs)) return(out)
  out$gpcm_inference <- inputs
  for (name in names(inputs)) {
    key <- paste0("gpcm_", name)
    tables <- mfrm_gpcm_inference_tables(inputs[[name]])
    names(tables) <- paste(key, names(tables), sep = "_")
    out$tables <- c(out$tables, tables)
    out$components[[key]] <- inputs[[name]]
    out$status <- rbind(out$status, mfrm_results_status_row(key, "review",
      "Saved GPCM inference; target, approximation, multiplicity and unavailable outcomes retained. No automatic rater-quality decision."))
    out$plot_map <- dplyr::bind_rows(out$plot_map, data.frame(Type = key,
      Available = "plots" %in% out$include, RequiredArtifact = FALSE,
      Route = paste0('plot(res, type = "', key, '")'),
      Detail = "Saved GPCM uncertainty; no recalculation or replacement of ordinary fit diagnostics.",
      InterpretationStatus = "approximate_inference", InterpretationReady = FALSE,
      ReadinessRoute = paste0("res$tables$", names(tables)[1])))
  }
  out$table_index <- mfrm_results_table_index(out$tables)
  out$notes <- unique(c(out$notes,
    "GPCM slope/curve uncertainty is separate from Wright/Pathway location and fit displays. Approximate intervals do not classify raters or choose scoring weights."))
  out
}

#' Display saved GPCM intervals and bootstrap results
#'
#' Plot the selected inference result without fitting or recomputing covariance.
#' These plots describe discrimination or specified contrasts, not rater severity,
#' agreement, quality or recommended scoring weights.
#' @param x Saved [confint.mfrm_fit()] or [bootstrap_mfrm_gpcm()] output.
#' @param title,subtitle Optional plot text; NULL removes it. The interval
#'   subtitle defaults to the saved target, method, confidence level and any
#'   saved numerical or bootstrap cautions. Custom text overrides this default, while the
#'   diagnostics remain in the plot data and interval tables.
#' @param reference Optional finite numeric vertical reference. Default NULL;
#'   no quality threshold or scoring-policy cutoff is selected.
#' @param draw TRUE draws the ggplot; FALSE returns it only.
#' @param ... For bootstrap slope results, passed to `confint()` to select its
#'   target and level. Otherwise unused.
#' @details Crosses retain unavailable intervals. Open circles retain intervals
#'   with infinite endpoints; the plot does not replace them with finite bounds.
#'   The accompanying table contains all bounds and failure reasons.
#'   For a bootstrap LRT, a histogram shows resolved null statistics and a line
#'   the observed statistic. The annotation counts every unresolved replicate.
#'
#'   Use [apa_table()] for target-aware tables, [plot_data()] for plotted values,
#'   and [as_ggplot()] for customization. Attach one result or a named list with
#'   `mfrm_results(fit, intervals = list(slopes = ci, curves = curves),
#'   compute = "never")`. Named plot routes become `gpcm_slopes`, `gpcm_curves`,
#'   etc. Exact source matching is required; default fit diagnostics are preserved.
#'   [export_mfrm_results()] saves these tables and plots; replay reloads the
#'   saved RDS, preserving the selected methods without rerunning estimation.
#'   Markdown report summaries include the finite, unbounded and unavailable
#'   interval counts and the saved inference cautions/reasons.
#'
#'   For positive slope or ratio intervals spanning many orders of magnitude,
#'   use `as_ggplot(ci) + ggplot2::scale_x_log10()`. Finite bounds and estimates
#'   must be strictly positive. Keep a linear axis for signed differences.
#'   Changing the axis does not narrow the interval or make it more reliable.
#' @return Invisibly a ggplot, retaining an `mfrm_plot_data` attribute for
#'   [plot_data()]. No fitting or resampling is performed.
#' @examples
#' # ci <- confint(fit, scale = "standardized", method = "sandwich")
#' # plot(ci, title = NULL)
#' # apa_table(ci)
#' # plot_data(ci, "table")
#' @export
plot.mfrm_slope_intervals <- function(x, title = "GPCM slope uncertainty",
    subtitle = paste(attr(x, "target"), attr(x, "method"),
      paste0(100*attr(x, "level"), "%"),
      if (attr(x, "simultaneous") == "none") "pointwise" else "Bonferroni", sep = " | "),
    reference = NULL, draw = TRUE, ...) {
  rlang::check_dots_empty(); .require_mfrmr_ggplot2()
  if (!is.null(reference) && (!is.numeric(reference) || length(reference) != 1L ||
      is.complex(reference) || !is.finite(reference))) stop("`reference` must be NULL or one finite number.", call. = FALSE)
  tab <- mfrm_gpcm_inference_tables(x)$intervals
  tab$Display <- ifelse(is.infinite(tab$CI_Lower) | is.infinite(tab$CI_Upper), "Unbounded",
    ifelse(tab$CIEligible, "Available", "Unavailable"))
  tab$Level <- factor(tab$SlopeFacet, levels = rev(tab$SlopeFacet))
  finite <- tab[tab$Display == "Available", , drop = FALSE]
  if (missing(subtitle) && length(attr(x, "cautions"))) {
    subtitle <- paste(subtitle, paste(attr(x, "cautions"), collapse = " "), sep = "\n")
  }
  if (!is.null(subtitle)) subtitle <- paste(strwrap(subtitle, width = 75), collapse = "\n")
  p <- ggplot2::ggplot(tab, ggplot2::aes(y = .data$Level, x = .data$Estimate)) +
    ggplot2::geom_segment(data = finite, ggplot2::aes(x = .data$CI_Lower,
      xend = .data$CI_Upper, yend = .data$Level), color = "#0072B2", linewidth = .8) +
    ggplot2::geom_point(ggplot2::aes(shape = .data$Display), size = 2.8, color = "#0072B2") +
    ggplot2::scale_shape_manual(values = c(Available = 16, Unavailable = 4, Unbounded = 1)) +
    ggplot2::labs(title = title, subtitle = subtitle, x = attr(x, "target"), y = NULL,
      shape = "Interval", alt = paste("Saved GPCM interval plot;", sum(tab$Display == "Available"),
        "finite intervals,", sum(tab$Display == "Unbounded"), "unbounded,",
        sum(tab$Display == "Unavailable"), "unavailable. Crosses and open circles retain unresolved targets.")) +
    .mfrmr_gg_theme() + ggplot2::theme(plot.subtitle = ggplot2::element_text(size = 9))
  if (!is.null(reference)) p <- p + ggplot2::geom_vline(xintercept = reference, linetype = "dashed", color = "grey40")
  attr(p, "mfrmr_plot_data") <- new_mfrm_plot_data("gpcm_slope_intervals",
    list(table = tab, title = title, subtitle = subtitle, target = attr(x, "target"),
      method = attr(x, "method"), level = attr(x, "level"), adjustment = attr(x, "simultaneous")))
  if (isTRUE(draw)) print(p)
  invisible(p)
}

#' @rdname plot.mfrm_slope_intervals
#' @export
plot.mfrm_gpcm_bootstrap <- function(x, title = "GPCM bootstrap inference",
    subtitle = "Fitted-model parametric bootstrap; unresolved refits retained", draw = TRUE, ...) {
  if (is.null(x$test)) {
    ci <- confint(x, ...)
    if (missing(subtitle)) return(plot(ci, title = title, draw = draw))
    return(plot(ci, title = title, subtitle = subtitle, draw = draw))
  }
  rlang::check_dots_empty(); .require_mfrmr_ggplot2()
  tab <- x$trials
  p <- ggplot2::ggplot(tab[tab$Available, , drop = FALSE], ggplot2::aes(x = .data$LR)) +
    ggplot2::geom_histogram(bins = 25, fill = "#0072B2", color = "white") +
    ggplot2::geom_vline(xintercept = x$test$LR, linetype = "dashed", linewidth = .8) +
    ggplot2::labs(title = title, subtitle = subtitle, x = "Null likelihood-ratio statistic", y = "Replicates",
      caption = paste(sum(tab$Available), "resolved of", nrow(tab), "planned replicates; unresolved:", sum(!tab$Available)),
      alt = "Histogram of resolved PCM-null bootstrap likelihood-ratio statistics with the observed statistic marked. Unresolved replicate counts are retained.") +
    .mfrmr_gg_theme()
  attr(p, "mfrmr_plot_data") <- new_mfrm_plot_data("gpcm_bootstrap_test",
    list(table = tab, test = x$test, title = title, subtitle = subtitle))
  if (isTRUE(draw)) print(p)
  invisible(p)
}

#' @rdname as_ggplot
#' @export
as_ggplot.mfrm_slope_intervals <- function(x, type = NULL, component = NULL, ...) {
  if (!is.null(type) || !is.null(component)) stop("Use plot_data() to select a GPCM inference table.", call. = FALSE)
  plot(x, draw = FALSE, ...)
}

#' @rdname as_ggplot
#' @export
as_ggplot.mfrm_curve_intervals <- as_ggplot.mfrm_slope_intervals

#' @rdname as_ggplot
#' @export
as_ggplot.mfrm_gpcm_bootstrap <- as_ggplot.mfrm_slope_intervals

#' @rdname as_ggplot
#' @export
as_ggplot.mfrm_results <- function(x, type = NULL, component = NULL, ...) {
  if (!is.null(type) && length(type) == 1L && !is.na(type) &&
      tolower(type) %in% paste0("gpcm_", names(x$gpcm_inference))) {
    if (!is.null(component)) stop("Use plot_data() to select a GPCM inference table.", call. = FALSE)
    return(plot(x, type = type, draw = FALSE, ...))
  }
  NextMethod()
}
