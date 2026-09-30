# Saved GPCM inference is displayed and exported without refitting or changing
# the ordinary fit diagnostics. Tables always retain the requested target/method.
mfrm_gpcm_inference_tables <- function(x) {
  if (inherits(x, "mfrm_slope_intervals")) {
    tab <- attr(x, "diagnostics")
    tab <- tab[intersect(c("SlopeFacet", "SlopeOwner", "SlopeLevel", "ScaleReference", "Estimate", "SE", "LogSE", "CI_Lower", "CI_Upper",
      "NullValue", "PValue", "CIEligible", "InferenceReview"), names(tab))]
    tab$Target <- attr(x, "target"); tab$Method <- attr(x, "method")
    tab$ConfidenceLevel <- paste0(format(100 * attr(x, "level"), trim = TRUE), "%")
    tab$Adjustment <- if (attr(x, "simultaneous") == "none") "Pointwise" else "Bonferroni"
    tables <- list(intervals = tab)
    for (name in c("checks", "numerical_checks", "score_rank")) {
      if (!is.null(attr(x,name))) tables[[name]] <- attr(x,name)
    }
    profile <- attr(x, "profile")
    if (!is.null(profile)) {
      tables$profile <- profile$profile
      tables$profile_endpoints <- profile$endpoints
      tables$wald <- attr(x, "wald")
      tables$profile_checks <- do.call(rbind, lapply(names(profile$attempts), function(key)
        do.call(rbind, lapply(names(profile$attempts[[key]]), function(start)
          cbind(LogSlope = as.numeric(key), Start = start,
            profile$attempts[[key]][[start]]$check)))))
      rownames(tables$profile_checks) <- NULL
    }
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
      if (!is.null(profile)) {
        tables$settings$Slope <- unname(settings$slope)
        if (length(names(settings$slope))) tables$settings$SlopeOwner <- names(settings$slope)
        tables$settings$QuadratureOrder <- settings$quad_points
        tables$settings$ComparisonOrder <- settings$comparison_quad_points
        tables$settings$MaxIterations <- settings$maxit
        tables$settings$MaxSearchSteps <- settings$max_steps
        tables$settings$InitialLogSlopeStep <- settings$initial_step
        tables$settings$ElapsedSeconds <- profile$elapsed
      }
    }
    return(tables)
  }
  if (inherits(x, "mfrm_curve_intervals")) {
    tab <- x$table
    tab$Target <- x$settings$target
    tab$Method <- if (isTRUE(x$settings$point_only)) "Fitted values only" else x$settings$method
    tab$ConfidenceLevel <- if (isTRUE(x$settings$point_only)) "Not available" else
      paste0(format(100 * x$settings$level, trim = TRUE), "%")
    tab$Adjustment <- if (isTRUE(x$settings$point_only)) "Not applicable" else
      if (x$settings$simultaneous == "none") "Pointwise" else "Bonferroni"
    tables <- list(curves = tab, settings = data.frame(
      Covariance = if (isTRUE(x$settings$point_only)) "Not available" else x$settings$method,
      SmallSampleAdjustment = x$settings$adjust,
      IndependentClusters = if (is.null(x$settings$clusters)) NA_integer_ else length(unique(x$settings$clusters$Cluster))))
    if (!is.null(x$settings$clusters)) tables$clusters <- x$settings$clusters
    if (!is.null(x$contexts)) tables$contexts <- x$contexts
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
    point_only <- inherits(inputs[[name]], "mfrm_curve_intervals") && isTRUE(inputs[[name]]$settings$point_only)
    key <- paste0("gpcm_", name)
    tables <- mfrm_gpcm_inference_tables(inputs[[name]])
    names(tables) <- paste(key, names(tables), sep = "_")
    out$tables <- c(out$tables, tables)
    out$components[[key]] <- inputs[[name]]
    out$status <- rbind(out$status, mfrm_results_status_row(key, "review",
      if (point_only) "Saved provisional fitted curves; calibration intervals are unavailable." else
        "Saved GPCM inference; target, approximation, multiplicity and unavailable outcomes retained. No automatic rater-quality decision."))
    out$plot_map <- dplyr::bind_rows(out$plot_map, data.frame(Type = key,
      Available = "plots" %in% out$include, RequiredArtifact = FALSE,
      Route = paste0('plot(res, type = "', key, '")'),
      Detail = if (point_only) "Saved provisional fitted curves without intervals; no recalculation." else
        "Saved GPCM uncertainty; no recalculation or replacement of ordinary fit diagnostics.",
      InterpretationStatus = if (point_only) "provisional_fitted_values" else "approximate_inference", InterpretationReady = FALSE,
      ReadinessRoute = paste0("res$tables$", names(tables)[1])))
  }
  out$table_index <- mfrm_results_table_index(out$tables)
  out$notes <- unique(c(out$notes,
    if (mfrm_has_product_slopes(out$fit)) "Two-family curves remain provisional without intervals; separately requested slope intervals use an experimental approximation with saved numerical checks. No automatic rater-quality decision is supported." else
    "GPCM slope/curve uncertainty is separate from Wright/Pathway location and fit displays. Approximate intervals do not classify raters or choose scoring weights."))
  out
}

# Keep the ordinary fit-report templates from recommending unsupported outputs.
mfrm_gpcm_product_report <- function(x, style) {
  adaptive <- mfrmr_adaptive_integration(x$fit$config)
  numerical <- isTRUE(x$fit$summary$Converged) &&
    identical(x$fit$opt$optimizer_diagnostics$ConvergenceSeverity, "pass")
  intervals <- Filter(function(z) inherits(z,"mfrm_slope_intervals"),x$gpcm_inference %||% list())
  n_intervals <- sum(vapply(intervals,function(z) sum(attr(z,"diagnostics")$CIEligible),integer(1)))
  interval_note <- if (adaptive) {
    "Component-slope and curve intervals are unavailable for adaptive two-family fitting. Fixed-grid EM interval checks do not qualify this integration method."
  } else if (length(intervals)) paste(n_intervals,
    "experimental slope intervals are available; inspect the saved checks and unavailable rows. Curve intervals remain unavailable.") else
    "No slope intervals were attached. Curve intervals are unavailable. Use confint(fit) for the separately checked experimental slope approximation."
  first_screen <- data.frame(
    Area = c("Overall", "Numerical fit", "Calibration intervals", "Other outputs"),
    Status = c("review", if (numerical) "ok" else "review", if (n_intervals) "caveat" else "unavailable", "unavailable"),
    Readiness = c("Provisional analysis", "Numerical only", "Output-specific checks", "Not supported"),
    MainIssue = c("This report retains numerical estimates, conditional curves and explicitly attached experimental slope intervals.",
      if (adaptive) {
        if (numerical) "Direct adaptive MML met its optimizer and gradient checks." else
          "Direct adaptive MML did not pass its numerical convergence checks."
      } else if (numerical) "The per-Person marginal-score stopping rule was met." else
        "EM stopped without meeting the per-Person marginal-score tolerance.",
      interval_note,
      "Ordinary diagnostics, Wright/Pathway maps, model ranking and new-person scoring are unavailable."),
    NextAction = c("Read the model settings and numerical status before the saved curves.",
      if (numerical) "Convergence does not establish identification, model adequacy or inferential reliability." else
        "Review the stopping result and retain this fit as numerically unresolved.",
      "Retain unavailable bounds and labels for contexts not observed together.",
      "Do not infer support for these outputs from the one-family GPCM workflow."),
    PrimaryRoute = c("report$tables$fit_summary_settings_overview", "report$tables$fit_summary_readiness",
      "report$tables", "gpcm_capability_matrix()"))
  selected <- c("fit_summary_overview", "fit_summary_settings_overview", "fit_summary_readiness",
    "fit_summary_decision", "fit_summary_slope_overview", "fit_summary_caveats")
  tables <- c(x$tables[intersect(selected, names(x$tables))],
    list(slope_estimates = x$fit$slopes),
    x$tables[startsWith(names(x$tables), "gpcm_") | startsWith(names(x$tables), "response_")])
  if (!is.null(x$response_diagnostics)) {
    first_screen <- rbind(first_screen, data.frame(Area = "Response residuals", Status = "caveat",
      Readiness = "Descriptive only",
      MainIssue = "Saved same-data posterior predictive residuals integrate ability with calibration fixed; no expectation-one reference or fit cutoffs.",
      NextAction = "Review unavailable rows and integration differences before inspecting grouped summaries.",
      PrimaryRoute = "report$tables$response_diagnostic_settings"))
  }
  fit <- x$fit
  settings <- data.frame(Setting = c("Model", "Estimation", "Ability population",
    "First slope facet (geometric mean one)", "Second slope facet (free slopes)",
    "Step facet", "Quadrature points", "EM iterations", "Numerically converged",
    "Maximum per-Person marginal score", "Stopping tolerance"),
    Value = c("Two-family GPCM", "MML with generalized EM", "Fixed standard normal",
      fit$config$slope_facet, fit$config$step_facet,
      fit$config$estimation_control$quad_points, fit$summary$EMIterations,
      fit$summary$Converged, fit$summary$TerminalGradientSupNorm,
      fit$summary$GradientReviewTolerance))
  slope_values <- data.frame(Facet = fit$slopes$SlopeOwner, Level = fit$slopes$SlopeFacet,
    FittedSlope = fit$slopes$OptimizerEstimate, Interval = "See attached slope-interval tables, if requested")
  tables <- c(list(model_settings = settings, fitted_slopes = slope_values), tables)
  out <- structure(list(title = "mfrmr Two-family GPCM Report", style = style,
    source_include = x$include, decision = x$tables$fit_summary_decision,
    fit_readiness = x$fit_readiness, fit_readiness_components = x$fit_readiness_components,
    first_screen = first_screen,
    report_index = data.frame(Area = names(tables), PrimaryTable = paste0("report$tables$", names(tables))),
    template_index = data.frame(),
    claim_readiness = data.frame(Claim = "Formal inference, model adequacy and general coverage", Readiness = "Not established"),
    tables = tables, source = x), class = "mfrm_report")
  out$markdown <- paste(c(paste0("# ", out$title),
    "This report retains provisional numerical results. Report style does not qualify estimates or supply unavailable analyses.",
    mfrm_report_markdown_table(first_screen),
    "## Provisional GPCM analysis",
    interval_note,
    "Calibration intervals are unavailable for the response curves. Experimental slope intervals do not establish general coverage. Numerical convergence and curve shape do not qualify rater-quality decisions.",
    "The two fitted slopes multiply each other and the complete adjacent-category predictor. A large slope is not evidence of assessor competence or scoring accuracy.",
    unlist(lapply(c("model_settings", "fitted_slopes", names(tables)[grepl("^gpcm_.*_(curves|contexts|intervals|profile_endpoints)$", names(tables))],
      intersect(c("response_diagnostic_settings", "response_measures"), names(tables))),
      function(name) {
        tab <- tables[[name]]
        if (endsWith(name, "profile_endpoints")) tab$Status <- NULL
        c(paste0("## ", gsub("_", " ", name)), mfrm_report_markdown_table(tab),
          if (nrow(tab) > 20) "First 20 rows shown; all rows remain in report$tables and CSV exports.")
      })),
    "Complete numerical settings, source checks and unavailable primary estimates remain in report$tables and the saved source result."), collapse = "\n\n")
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
#' @param type For saved slope intervals, `"interval"` displays bounds;
#'   `"profile"` displays saved likelihood evaluations and the same-target Wald
#'   limits. The default is `"profile"` for saved profile calculations and
#'   `"interval"` otherwise. This never initiates profiling.
#' @param caption For saved slope intervals, optional caption. NULL removes it.
#'   Two-family intervals state the distinct family references by default.
#'   Profile plots supply a
#'   default explanation of line styles and missing coordinates when omitted.
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
    reference = NULL, draw = TRUE, ..., type = c("interval", "profile"), caption = NULL) {
  rlang::check_dots_empty(); .require_mfrmr_ggplot2()
  if (missing(type) && !is.null(attr(x, "profile"))) type <- "profile"
  type <- match.arg(type)
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
  if (type != "profile" && missing(caption) && !is.null(attr(x,"scale_note"))) {
    caption <- paste(strwrap(attr(x,"scale_note"),width=80),collapse="\n")
  }
  if (type == "profile") {
    saved <- attr(x, "profile")
    if (is.null(saved)) stop("type = 'profile' requires saved method = 'profile' intervals.", call. = FALSE)
    if (!is.null(reference) && reference <= 0) stop("A profile reference must be positive on the log axis.", call. = FALSE)
    tab <- saved$profile
    tab$Display <- ifelse(tab$Passed, "Passed", "Unresolved")
    tab$Segment <- cumsum(!tab$Passed)
    visible <- is.finite(tab$Slope) & tab$Slope > 0 & is.finite(tab$LR)
    if (missing(caption)) caption <- paste(
      "Dashed: likelihood-ratio cutoff. Dotted: Wald limits. Crosses: unresolved points.",
      sum(!visible), "evaluations without a plotting coordinate remain in the saved tables.",
      attr(x, "scale_note") %||% "")
    if (!is.null(caption)) caption <- paste(strwrap(caption, width = 80), collapse = "\n")
    wald <- attr(x, "wald")
    payload <- new_mfrm_plot_data("gpcm_slope_profile",
      list(table = tab, endpoints = saved$endpoints, wald = wald, title = title,
        subtitle = subtitle, caption = caption, reference = reference,
        target = attr(x, "target"), slope_metadata = attr(x, "diagnostics"),
        x_label = if ("SlopeOwner" %in% names(attr(x, "diagnostics"))) "Component discrimination (log scale)" else "Relative discrimination (log scale)",
        level = attr(x, "level"), cutoff = saved$cutoff))
    p <- mfrm_gg_gpcm_profile(payload)
    if (isTRUE(draw)) print(p)
    return(invisible(p))
  }
  p <- ggplot2::ggplot(tab, ggplot2::aes(y = .data$Level, x = .data$Estimate)) +
    ggplot2::geom_segment(data = finite, ggplot2::aes(x = .data$CI_Lower,
      xend = .data$CI_Upper, yend = .data$Level), color = "#0072B2", linewidth = .8) +
    ggplot2::geom_point(ggplot2::aes(shape = .data$Display), size = 2.8, color = "#0072B2") +
    ggplot2::scale_shape_manual(values = c(Available = 16, Unavailable = 4, Unbounded = 1)) +
    ggplot2::labs(title = title, subtitle = subtitle, caption = caption, x = attr(x, "target"), y = NULL,
      shape = "Interval", alt = paste("Saved GPCM interval plot;", sum(tab$Display == "Available"),
        "finite intervals,", sum(tab$Display == "Unbounded"), "unbounded,",
        sum(tab$Display == "Unavailable"), "unavailable. Crosses and open circles retain unresolved targets.")) +
    .mfrmr_gg_theme() + ggplot2::theme(plot.subtitle = ggplot2::element_text(size = 9))
  if (!is.null(reference)) p <- p + ggplot2::geom_vline(xintercept = reference, linetype = "dashed", color = "grey40")
  attr(p, "mfrmr_plot_data") <- new_mfrm_plot_data("gpcm_slope_intervals",
    list(table = tab, title = title, subtitle = subtitle, caption = caption, target = attr(x, "target"),
      method = attr(x, "method"), level = attr(x, "level"), adjustment = attr(x, "simultaneous"),
      checks = attr(x, "checks"), numerical_checks = attr(x, "numerical_checks"),
      score_rank = attr(x, "score_rank")))
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
  if (inherits(x, "mfrm_slope_intervals") && length(type) == 1L && type %in% c("interval", "profile") && is.null(component))
    return(plot(x, type = type, draw = FALSE, ...))
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


mfrm_gg_gpcm_profile <- function(x) {
  .require_mfrmr_ggplot2()
  d <- x$data; tab <- d$table
  visible <- is.finite(tab$Slope) & tab$Slope > 0 & is.finite(tab$LR)
  p <- ggplot2::ggplot(tab[visible, ], ggplot2::aes(x = .data$Slope, y = .data$LR)) +
    ggplot2::geom_line(data = tab[visible & tab$Passed, ],
      ggplot2::aes(group = .data$Segment), color = "#0072B2") +
    ggplot2::geom_point(ggplot2::aes(shape = .data$Display), size = 2, color = "#0072B2") +
    ggplot2::scale_shape_manual(values = c(Passed = 16, Unresolved = 4)) +
    ggplot2::geom_hline(yintercept = d$cutoff, linetype = "dashed") +
    ggplot2::geom_vline(xintercept = unlist(d$wald[c("Lower", "Upper")]), linetype = "dotted") +
    ggplot2::scale_x_log10() +
    ggplot2::labs(title = d$title, subtitle = d$subtitle, caption = d$caption,
      x = d$x_label %||% "Relative discrimination (log scale)", y = "Twice the log-likelihood loss", shape = "Numerical check",
      alt = "Saved local slope profile. Dashed horizontal cutoff and dotted Wald limits; unresolved points use crosses. Gaps are not interpolated.") +
    .mfrmr_gg_theme() + ggplot2::theme(plot.subtitle = ggplot2::element_text(size = 9))
  if (!is.null(d$reference)) p <- p + ggplot2::geom_vline(xintercept = d$reference, linetype = "dotdash")
  attr(p, "mfrmr_plot_data") <- x
  p
}
