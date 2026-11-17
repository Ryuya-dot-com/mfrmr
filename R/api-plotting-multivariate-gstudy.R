#' Inspect sources of observed-score variation
#'
#' Plot raw variance components for selected scores or one prespecified weighted
#' score, or inspect the component covariance matrices. Then use [mfrm_d_study()] to assess
#' how changing the measurement conditions affects G, Phi and SEM.
#'
#' @param x A result from [mfrm_g_study()].
#' @param score Original score names in display order. Multiple scores produce
#'   separate component panels. The default selects the first score for
#'   `type = "components"`, or all scores for `type = "covariance"`.
#'   Do not supply both `score` and `weights`.
#' @param weights Optional named numeric vector defining one composite. Name
#'   every score exactly once, with finite weights and at least one nonzero
#'   value. Names determine order. Signed weights permit difference scores;
#'   weights are not normalized. For a saved D-study, use its selected weight
#'   vector, for example `plot(d$gstudy, weights = d$weights)`.
#' @param draw Draw the figure; `FALSE` only returns its data.
#' @param preset Plot style: `"standard"`, `"publication"`, `"compact"`, or
#'   `"monochrome"`. Omission uses the session plot default.
#' @param type `"components"` for variance-component points, or `"covariance"`
#'   for one matrix heatmap per source. With `intervals = TRUE`, covariance
#'   instead displays one signed interval plot for exactly two selected scores.
#'   Covariance plots do not accept `weights`.
#' @param ncol Positive number of panel columns. Defaults to at most two.
#' @param intervals Logical; `FALSE` (default) shows point estimates. `TRUE`
#'   adds component confidence intervals in the same call; also specify
#'   `assumption = "normal"`. Available for complete balanced ANOVA component
#'   plots, including supported nesting. Covariance intervals require an
#'   explicit method and exactly two scores. Explicit `method = "reml_profile"`
#'   also provides variance and two-score covariance intervals for identifiable incomplete sources,
#'   fitting a separate REML model while preserving the original points.
#'   `method = "residual_contrast"` uses retained ratings without likelihood
#'   fitting, but only Residual receives an interval. Other points remain
#'   visible with unavailable intervals and their reasons.
#'   Other methods use saved ANOVA summaries without refitting.
#' @param assumption With `intervals = TRUE`, explicitly specify `"normal"`
#'   for independent normal random effects with constant component variances.
#'   This assumption is not tested.
#' @param level Pointwise confidence level for `intervals = TRUE`, default 0.95.
#' @param method Component interval method passed to
#'   [confint.mfrm_multivariate_gstudy()]. Single-score/composite variances
#'   use `"auto"` or `"mls"` for balanced ANOVA, or explicit experimental
#'   `"reml_profile"` for balanced/identifiable incomplete sources. Profile
#'   intervals have approximate calibration and no accompanying sampling SE.
#'   Covariance intervals require explicit `"gci"`, `"regression_region"` or
#'   `"reml_profile"`; none is an automatic default.
#'   Explicit `"residual_contrast"` also supports incomplete sources for
#'   Residual only: exact normal-model variance limits or conservative
#'   covariance limits. It retains original points and a separate interval
#'   center without supplying the original estimator's sampling SE.
#' @param draws,seed Numerical settings for covariance `method = "gci"`.
#'   Defaults are 20000 pivotal draws and seed 20261016. See the confidence
#'   interval help for requirements and numerical endpoint bands.
#' @param ... Reserved; additional arguments are rejected.
#'
#' @details
#' Plots raw individual-rating variance components in squared score units (or
#' \eqn{w' \Sigma_s w} for composite `weights`, without future-count division).
#' Nonnegative estimates use filled circles; unconstrained negative estimates
#' remain unclipped to the left of zero as open circles, and `ComponentPSD`
#' tracks full-matrix positive semidefiniteness. The last source (`Residual`)
#' combines the highest-order interaction and within-cell error; D-study
#' relative/absolute error instead aggregates across multiple components (see
#' [mfrm_d_study()]).
#'
#' With `intervals = TRUE`, horizontal bars show pointwise intervals from
#' [confint.mfrm_multivariate_gstudy()] (square outlines mark unavailable rows
#' recorded in `unavailable_intervals`; `"reml_profile"` and
#' `"residual_contrast"` retain original points alongside `IntervalCenter`).
#' `type = "covariance"` displays unstandardized variance-covariance heatmaps
#' centered at zero, or a two-score signed interval forest plot when
#' `intervals = TRUE` with an explicit method.
#' @return Invisibly, a `ggplot` object; [plot_data()] extracts `table` (source, display label, selected
#'   estimate, sign status and full component-matrix PSD diagnostic),
#'   `weights`, `score`, `kind`, `source_design`, `source_rows`, axis labels and
#'   notes. `plot`, `panels` and `ncol` describe the view. Component tables include
#'   `Score`; covariance tables include `Row`, `Column` and `Element` (variance
#'   or covariance), with a shared `fill_limits` and `heat_colors` palette.
#'   With intervals, `table` also includes `SE`, `Lower`, `Upper`, `RawLower`,
#'   `RawUpper`, `Level`, `Method`, `IntervalStatus` and `IntervalAvailable`.
#'   `intervals` retains one complete `confint()` table per selected score or
#'   composite, with its assumptions and source context; `unavailable_intervals`
#'   retains rows without a drawable interval. `Status` still describes the
#'   sign of the point estimate.
#'   REML component tables additionally retain `IntervalCenter`, `SEStatus`,
#'   candidate bounds and `Validation`; full numerical profiles are retained
#'   in `intervals`. Saving the plot preserves them for `as_ggplot()` reuse.
#'   Covariance interval plots have `kind = "Covariance"`, one forest panel,
#'   and the original pair in `score`. The full interval table retains covariance
#'   units, assumptions, numerical bands and SE/interval diagnostics.
#'   Save the result with `saveRDS()` for later `as_ggplot()` conversion,
#'   without recalculating intervals, or save the G-study to redraw it.
#' @seealso [mfrm_g_study()], [plot.mfrm_multivariate_d_study()]
#' @md
#' @examples
#' # Optional workflow; run the example explicitly as shown below.
#' # example("plot.mfrm_multivariate_gstudy", run.dontrun = TRUE)
#' \dontrun{
#' tasks <- read.csv(system.file("extdata", "mgenova-table12.csv", package = "mfrmr"))
#' g <- mfrm_g_study(tasks, c("V", "W"), rater = NULL)
#' p <- plot(g, weights = c(V = .5, W = .5), preset = "monochrome",
#'           intervals = TRUE, assumption = "normal")
#' plot_data(p, "table")
#' plot_data(p, "notes")
#' plot(g, score = c("V", "W"))
#' covariance_plot <- plot(g, type = "covariance")
#' plot_data(covariance_plot, "table")
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   as_ggplot(p)
#' }
#' }
#' @export
plot.mfrm_multivariate_gstudy <- function(x, score = NULL, weights = NULL,
                                         draw = TRUE, preset = "standard",
                                         type = c("components", "covariance"),
                                         ncol = NULL, intervals = FALSE,
                                         assumption = NULL, level = .95,
                                         method = "auto", draws = 20000L,
                                         seed = 20261016L, ...) {
  if (missing(preset)) preset <- .mfrm_default_plot_preset()
  rlang::check_dots_empty()
  if (!is.logical(draw) || length(draw) != 1L || is.na(draw))
    stop("`draw` must be TRUE or FALSE.", call. = FALSE)
  style <- resolve_plot_preset(preset)
  type <- match.arg(type)
  if (!is.logical(intervals) || length(intervals) != 1L || is.na(intervals))
    stop("`intervals` must be TRUE or FALSE.", call. = FALSE)
  if (!intervals && (!missing(assumption) || !missing(level) || !missing(method) || !missing(draws) || !missing(seed)))
    stop("`assumption`, `level`, `method`, `draws` and `seed` apply only when `intervals = TRUE`.", call. = FALSE)
  if (intervals && !identical(method,"gci") && (!missing(draws) || !missing(seed)))
    stop("`draws` and `seed` apply only to `method = 'gci'`.", call. = FALSE)
  covariance_intervals <- intervals && type == "covariance"
  if (!is.null(ncol) && (!is.numeric(ncol) || is.object(ncol) || is.complex(ncol) ||
      !is.null(dim(ncol)) || length(ncol) != 1L || !is.finite(ncol) ||
      ncol < 1 || ncol != floor(ncol)))
    stop("`ncol` must be a positive integer.", call. = FALSE)
  scores <- x$design$scores
  components <- x$components
  if (!inherits(x, "mfrm_multivariate_gstudy") || !is.character(scores) ||
      !length(scores) || anyNA(scores) || anyDuplicated(scores) ||
      !is.list(components) || !length(components) || is.null(names(components)) ||
      anyNA(names(components)) || anyDuplicated(names(components)) ||
      any(!nzchar(names(components))) ||
      !all(vapply(components, function(a) is.matrix(a) && is.numeric(a) &&
        !is.complex(a) && identical(dimnames(a), list(scores, scores)) &&
        all(is.finite(a)) && identical(a, t(a)), logical(1)))) {
    stop("The G-study covariance matrices or score identities are incomplete or altered; recreate the result.", call. = FALSE)
  }
  factors <- names(x$design$counts)
  if (!identical(factors[1L], "Person") || !.mfrm_mvgt_valid_facets(factors[-1L]))
    stop("The G-study factor identities are incomplete or altered; recreate the result.", call. = FALSE)
  nesting <- .mfrm_mvgt_nesting(x$design$nesting, factors[-1L])
  if (!identical(names(components), .mfrm_mvgt_sources(factors, nesting)))
    stop("The G-study component identities do not match its design; recreate the result.", call. = FALSE)
  if (!is.null(score) && !is.null(weights))
    stop("Choose either `score` or `weights`, not both.", call. = FALSE)
  if (type == "covariance" && !is.null(weights))
    stop("Covariance plots use original scores; omit `weights`.", call. = FALSE)
  kind <- if (is.null(weights)) "Score" else "Composite"
  if (is.null(weights)) {
    if (is.null(score)) score <- if (type == "covariance") scores else scores[1L]
    if (!is.character(score) || !is.null(dim(score)) || !length(score) ||
        anyNA(score) || anyDuplicated(score) || !all(score %in% scores))
      stop("`score` must name distinct original scores.", call. = FALSE)
    weights <- diag(length(scores))[, match(score, scores), drop = FALSE]
    dimnames(weights) <- list(scores, score)
    title <- paste("Score:", paste(score, collapse = ", "))
  } else {
    if (!is.numeric(weights) || is.object(weights) || is.complex(weights) ||
        !is.null(dim(weights)) || length(weights) != length(scores) ||
        is.null(names(weights)) || anyNA(names(weights)) || anyDuplicated(names(weights)) ||
        !setequal(names(weights), scores) || any(!is.finite(weights)) || !any(weights != 0))
      stop("`weights` must name every score once with finite values and at least one nonzero value; select one vector for the plot.", call. = FALSE)
    weights <- weights[scores]
    score <- "Composite"
    title <- paste("Composite:", paste(names(weights), format(weights, trim = TRUE), sep = " = ", collapse = ", "))
  }
  diagnostics <- x$component_diagnostics
  psd <- diagnostics$PositiveSemidefinite[match(names(components), diagnostics$Source)]
  if (!is.logical(psd) || length(psd) != length(components) || anyNA(psd))
    stop("The G-study component diagnostics are incomplete; recreate the result.", call. = FALSE)
  source_labels <- gsub(":", " x ", names(components), fixed = TRUE)
  highest <- if (is.null(nesting)) paste(factors, collapse = " x ") else
    paste0("Person x ", names(nesting), "(", nesting, ")")
  source_labels[names(components) == "Residual"] <- paste(highest, "+ residual")
  if (covariance_intervals) {
    if (length(score) != 2L)
      stop("Covariance intervals require `score` to select exactly two original scores.",call.=FALSE)
    args <- list(object=x,score=score,assumption=assumption,level=level,method=method)
    if (identical(method,"gci")) args <- c(args,list(draws=draws,seed=seed))
    ci <- list(do.call(confint.mfrm_multivariate_gstudy,args))
    names(ci) <- paste(score,collapse=" / ")
    table <- data.frame(Source=names(components),Estimate=ci[[1]]$Estimate,
      ComponentPSD=psd,Score=names(ci),Panel=1L)
    panels <- data.frame(Panel=1L,Label=names(ci))
    weights <- NULL; kind <- "Covariance"
    type <- "components" # Reuse the component forest; heatmaps cannot show bounds clearly.
  } else if (type == "covariance") {
    table <- do.call(rbind, lapply(seq_along(components), function(i) {
      cells <- expand.grid(Row = score, Column = score, stringsAsFactors = FALSE)
      cells$Source <- names(components)[i]
      cells$Estimate <- as.vector(components[[i]][score, score, drop = FALSE])
      cells$Element <- ifelse(cells$Row == cells$Column, "Variance", "Covariance")
      cells$ComponentPSD <- psd[i]
      cells$Panel <- i
      cells
    }))
    panels <- data.frame(Panel = seq_along(components), Label = source_labels)
    weights <- NULL
  } else {
    if (is.null(dim(weights))) weights <- matrix(weights, ncol = 1L,
      dimnames = list(names(weights), score))
    table <- do.call(rbind, lapply(seq_along(score), function(i) {
      w <- weights[, i]
      scale <- max(abs(w))
      if (!is.finite(scale^2) || scale^2 == 0)
        stop("Composite variances exceed numeric range; rescale the weights.", call. = FALSE)
      w <- w / scale
      values <- vapply(components, function(a) as.numeric(crossprod(w, a %*% w)) * scale^2, numeric(1))
      if (any(!is.finite(values))) stop("Projected variances exceed numeric range; rescale the scores or weights.", call. = FALSE)
      data.frame(Source = names(components), Estimate = unname(values),
        ComponentPSD = psd, Score = score[i], Panel = i, row.names = NULL)
    }))
    panels <- data.frame(Panel = seq_along(score), Label = score)
    if (ncol(weights) == 1L) weights <- weights[, 1L]
  }
  table$Status <- ifelse(table$Estimate < 0, "Negative estimate", "Nonnegative estimate")
  table$Label <- source_labels[match(table$Source, names(components))]
  if (intervals) {
    if (!covariance_intervals) ci <- lapply(score, function(s) {
      if (kind == "Composite") confint.mfrm_multivariate_gstudy(x,
        weights = weights, assumption = assumption, level = level, method=method) else
        confint.mfrm_multivariate_gstudy(x, score = s,
          assumption = assumption, level = level, method=method)
    })
    if (!covariance_intervals) names(ci) <- score
    bounds <- do.call(rbind, lapply(ci, function(z) {
      columns <- intersect(c("SE", "Lower", "Upper", "RawLower", "RawUpper",
        "Level", "Method", "Status", "SEStatus", "IntervalCenter",
        "CandidateLower", "CandidateUpper", "Validation"), names(z))
      z <- z[match(names(components), z$Source), columns]
      names(z)[names(z) == "Status"] <- "IntervalStatus"
      z
    }))
    rownames(bounds) <- NULL
    table <- cbind(table, bounds)
    table$IntervalAvailable <- is.finite(table$Lower) & is.finite(table$Upper)
  }
  ncol <- min(ncol %||% 2L, nrow(panels))
  note <- c("Raw source-model variance components in squared score units; no sampling intervals. Not future mean-score error contributions or percentages.",
    paste0("Residual = ", highest, " + residual: these sources cannot be separated with one observation per person-by-condition cell."),
    "Person variation is not measurement error. Relative error combines person-by-condition interactions and residual; absolute error also includes condition main effects and interactions without Person. Divide components by their applicable future counts before summing; use the D-study SEM plot for error in mean-score units.",
    "Filled circles: nonnegative estimates; open circles: negative estimates. Weights are used as supplied.")
  if (type == "covariance") {
    note[1L] <- "Raw source-model matrices: diagonal variances in squared score units, off-diagonal covariances in products of the two score units. Not correlations or future mean-score error contributions; no sampling intervals."
    note[4L] <- "All panels share a zero-centered color scale. Cell labels are rounded; the table retains exact signed values. Negative covariance can be legitimate; a negative variance is not a population variance. No standardization or matrix repair is performed."
    note <- c(note, "PSD diagnostics refer to each full source matrix, including scores not selected for display. Large covariance alone does not diagnose halo.")
  }
  if (intervals) {
    note[1L] <- sprintf("Raw source-model variance components with %s%% pointwise normal-random-effects intervals in squared score units. Not future mean-score error contributions or percentages.",
      format(100 * level, trim = TRUE))
    note <- c(note,
      if (identical(method, "reml_profile"))
        "Horizontal bars show explicit approximate REML component intervals. Points remain original ANOVA/MINQUE estimates, including negative estimates outside their intervals; IntervalCenter records the separate REML estimate. SE is not supplied by profile inversion. Intervals are not simultaneous across sources or scores." else
      if (identical(method, "residual_contrast"))
        "Only Residual has a residual-contrast interval. Points retain original ANOVA/MINQUE estimates; IntervalCenter records the separate projected estimate. Other sources remain visible without intervals. SE is not supplied for the original estimator." else
        "Horizontal bars show nonnegative-space intervals: approximate Ting MLS for components; chi-square for the combined residual. They are not simultaneous across sources or scores. Negative points are retained even when outside those intervals.",
      "Square outlines mark estimates without intervals; inspect IntervalStatus and unavailable_intervals. No bar does not mean zero uncertainty. Raw endpoints remain in the table.",
      unique(unlist(lapply(ci, attr, which = "notes"), use.names = FALSE)))
  }
  note <- c(note, "Compare magnitudes only for comparable score units. Shared plot scales do not make different score units equivalent.")
  if (covariance_intervals) note <- c(attr(ci[[1]],"notes"),
    "Horizontal bars show signed covariance intervals for the selected pair. Open circles are negative covariance estimates, not invalid variances; square outlines mark unavailable intervals. Inspect IntervalStatus and SEStatus separately.",
    paste0("Residual = ",highest," + residual: these sources cannot be separated with one observation per cell."))
  negative_variance <- table$Estimate < 0
  if (type == "covariance") negative_variance <- negative_variance & table$Element == "Variance"
  if (covariance_intervals) negative_variance[] <- FALSE
  if (any(negative_variance)) note <- c(note,
    "Negative raw estimates are retained; they are not negative population variances. Review the design and component diagnostics.")
  if (any(!psd)) note <- c(note,
    "Non-PSD component covariance matrices are retained; a positive selected variance does not establish matrix validity.")
  labels <- vapply(source_labels, function(s) paste(strwrap(s, width = 28), collapse = "\n"), character(1))
  heat_colors <- if (style$name == "monochrome") c("#303030", "#B8B8B8", "#FFFFFF") else
    c("#B35806", "#F7F7F7", "#2166AC")
  bound <- max(abs(table$Estimate))
  if (bound == 0) bound <- 1
  out <- new_mfrm_plot_data("multivariate_gstudy", list(table = table, score = score,
    plot = type, panels = panels, ncol = ncol,
    heat_colors = heat_colors, fill_limits = c(-bound, bound),
    kind = kind, weights = weights, source_design = x$design[c("method", "counts", "rows",
      "complete", "balanced", "nesting", "score_convention")], source_rows = x$data_usage$counts,
    title = title, notes = data.frame(Type = "note", Text = note, stringsAsFactors = FALSE),
    labels = labels, x_label = if(covariance_intervals) "Covariance (product of score units)" else "Variance (squared score units)",
    preset = style$name))
  if (intervals) {
    out$data$intervals <- ci
    out$data$unavailable_intervals <- table[!table$IntervalAvailable, , drop = FALSE]
  }
  .mfrm_finalize_ggplot(out, draw = draw)
}
