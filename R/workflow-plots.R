# ==============================================================================
# Publication-Ready Color-Vision-Safe ggplot2 Visualizations for `tidymfrm`
# Supports Okabe-Ito, Viridis, and Strict Monochrome + Redundant Shape/Linetype
# ==============================================================================

.tidymfrm_theme <- function(base_size = 11) {
  ggplot2::theme_bw(base_size = base_size) +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(fill = "#FFFFFF", colour = NA),
      plot.background = ggplot2::element_rect(fill = "#FFFFFF", colour = NA),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(colour = "#EBEBEB", linewidth = 0.35),
      strip.background = ggplot2::element_rect(fill = "#F5F5F5", colour = "#CCCCCC"),
      strip.text = ggplot2::element_text(face = "bold", colour = "#222222"),
      legend.background = ggplot2::element_rect(fill = "#FFFFFF", colour = NA),
      legend.key = ggplot2::element_rect(fill = "#FFFFFF", colour = NA),
      legend.position = "bottom",
      plot.margin = ggplot2::margin(8, 10, 8, 8)
    )
}

.tidymfrm_palette <- function(n, palette = c("okabe_ito", "viridis", "monochrome")) {
  palette <- match.arg(palette)
  if (n <= 0L) return(character(0))
  if (identical(palette, "monochrome")) {
    if (n == 1L) return("#222222")
    return(grDevices::gray(seq(0.12, 0.65, length.out = n)))
  }
  if (identical(palette, "viridis")) {
    if (n == 1L) return("#21918C")
    return(grDevices::hcl.colors(n, palette = "viridis", rev = FALSE))
  }
  oi <- c(
    "#0072B2", "#D55E00", "#009E73", "#CC79A7",
    "#E69F00", "#56B4E9", "#000000", "#F0E442"
  )
  if (n <= length(oi)) oi[seq_len(n)] else grDevices::colorRampPalette(oi)(n)
}

.tidymfrm_shapes <- function(n) {
  sh <- c(16L, 17L, 15L, 18L, 3L, 4L, 8L, 1L, 2L, 0L)
  rep(sh, length.out = max(1L, n))[seq_len(n)]
}

.tidymfrm_linetypes <- function(n) {
  lt <- c("solid", "dashed", "dotdash", "twodash", "longdash", "dotted")
  rep(lt, length.out = max(1L, n))[seq_len(n)]
}

.tidymfrm_flag_styles <- function(palette = c("okabe_ito", "viridis", "monochrome")) {
  palette <- match.arg(palette)
  lvls <- c(
    "Acceptable",
    "Markedly Severe",
    "Markedly Lenient",
    "Outside MnSq (ZSTD Unavailable)",
    "Below Lower Fit Bound",
    "Misfit (Unpredictable)",
    "Review required"
  )
  cols <- if (identical(palette, "monochrome")) {
    c("#333333", "#111111", "#666666", "#444444", "#777777", "#000000", "#555555")
  } else if (identical(palette, "viridis")) {
    grDevices::hcl.colors(7L, palette = "viridis")
  } else {
    c("#0072B2", "#E69F00", "#56B4E9", "#CC79A7", "#009E73", "#D55E00", "#666666")
  }
  list(
    colours = stats::setNames(cols, lvls),
    shapes = stats::setNames(c(16L, 17L, 15L, 3L, 18L, 8L, 4L), lvls),
    linetypes = stats::setNames(c("solid", "dashed", "dotdash", "dotted", "twodash", "longdash", "dotted"), lvls)
  )
}

.tidymfrm_plot_raters <- function(raters_df, mnsq_range = c(0.70, 1.30), zstd_limit = 2.0,
                                  fit_method = NULL, reference_bands = NULL,
                                  palette = "okabe_ito", base_size = 11, method_label = NULL) {
  mnsq_range <- .mfrm_validate_mnsq_range(mnsq_range)
  if (!is.numeric(zstd_limit) || is.factor(zstd_limit) || length(zstd_limit) != 1L ||
      !is.finite(zstd_limit) || zstd_limit < 0) {
    stop("`zstd_limit` must be a single finite nonnegative number.", call. = FALSE)
  }
  zstd_limit <- as.double(zstd_limit)
  ref_list <- .mfrm_normalize_ref_bands(reference_bands)
  if (identical(fit_method, "both")) {
    return(.mfrm_gg_pathway(raters_df, mnsq_range = mnsq_range, palette = palette,
                            base_size = base_size, fit_statistic = "infit",
                            fit_method = "both", reference_bands = reference_bands,
                            method_label = method_label))
  }
  fm <- if (!is.null(fit_method)) {
    .mfrm_resolve_fit_method(raters_df, method_label, fit_method)
  } else if ("FitBasis" %in% names(raters_df) && length(raters_df$FitBasis) > 0L && !is.na(raters_df$FitBasis[1L])) {
    raters_df$FitBasis[1L]
  } else {
    "plugin"
  }
  use_post <- identical(fm, "posterior")
  x_col <- if (use_post) "PostInfitMnSq" else "InfitMnSq"
  z_col <- if (use_post) "PostInfitZSTD" else "InfitZSTD"
  was_review <- ("DiagnosticFlag" %in% names(raters_df)) & !is.na(raters_df$DiagnosticFlag) &
    (raters_df$DiagnosticFlag == "Review required")
  raters_cls <- .mfrm_classify_raters(
    raters_df,
    fit_method_resolved = fm,
    mnsq_range = mnsq_range,
    zstd_limit = zstd_limit,
    ready = !all(was_review) || !length(was_review)
  )
  if (any(was_review)) raters_cls$DiagnosticFlag[was_review] <- "Review required"
  df <- raters_cls[is.finite(raters_cls$Estimate) & is.finite(raters_cls[[x_col]]), , drop = FALSE]
  if (!nrow(df)) return(.mfrm_empty_mnsq_plot(df, raters_cls$Level, "Infit"))
  df$PlotInfit <- df[[x_col]]
  zv_plot <- if (z_col %in% names(df)) df[[z_col]] else rep(NA_real_, nrow(df))
  df$RealLow <- df$Estimate - 1.96 * df$RealSE
  df$RealHigh <- df$Estimate + 1.96 * df$RealSE

  eb_shrunk <- "MLEEstimate" %in% names(df)
  unavailable <- df$DiagnosticFlag == "Review required" | eb_shrunk
  df$RealLow[unavailable] <- df$RealHigh[unavailable] <- NA_real_

  st <- .tidymfrm_flag_styles(palette = palette)

  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$PlotInfit, y = .data$Estimate)) +
    ggplot2::geom_vline(xintercept = 1.0, linetype = "solid", colour = "#999999", linewidth = 0.35) +
    ggplot2::geom_vline(xintercept = mnsq_range, linetype = "dashed", colour = "#666666", linewidth = 0.4) +
    ggplot2::geom_hline(yintercept = 0.0, linetype = "dotted", colour = "#888888", linewidth = 0.35)
  for (rb in ref_list) {
    p <- p + ggplot2::geom_vline(xintercept = rb, linetype = "dotdash", colour = "#888888", linewidth = 0.35)
  }
  p <- p +
    ggplot2::geom_errorbar(
      ggplot2::aes(ymin = .data$RealLow, ymax = .data$RealHigh,
                   colour = .data$DiagnosticFlag, linetype = .data$DiagnosticFlag),
      width = 0.0, linewidth = 0.55, alpha = 0.8, na.rm = TRUE
    ) +
    ggplot2::geom_point(
      ggplot2::aes(colour = .data$DiagnosticFlag, shape = .data$DiagnosticFlag),
      size = 3.0
    ) +
    ggplot2::geom_text(
      ggplot2::aes(label = .data$Level),
      nudge_y = 0.04 * (if (nrow(df)) max(diff(range(df$Estimate)), 0.5) else 0.5),
      size = 3.0, colour = "#222222", check_overlap = TRUE
    ) +
    ggplot2::scale_colour_manual(values = st$colours, name = "Diagnostic Status") +
    ggplot2::scale_shape_manual(values = st$shapes, name = "Diagnostic Status") +
    ggplot2::scale_linetype_manual(values = st$linetypes, name = "Diagnostic Status") +
    ggplot2::labs(
      x = if (use_post) "Posterior Infit Mean-Square (MnSq; TAM Basis)" else "Plug-in Infit Mean-Square (MnSq)",
      y = "Rater Severity (Logits; 95% Real-SE CI)"
    ) +
    .tidymfrm_theme(base_size = base_size)

  ref_note <- if (length(ref_list)) {
    paste("Dot-dash lines mark secondary reference bounds:",
          paste(vapply(ref_list, function(r) sprintf("[%.2f, %.2f]", r[1L], r[2L]), character(1)), collapse = ", "))
  }
  attr(p, "mfrm_notes") <- c(
    sprintf("Fit basis: %s. Dashed vertical lines indicate Infit MnSq screening bounds [%.2f, %.2f] (joint workflow flags also require |ZSTD| >= %.1f).",
            if (use_post) "Posterior-integrated (TAM::msq.itemfit)" else "Plug-in", mnsq_range[1L], mnsq_range[2L], zstd_limit),
    ref_note,
    "Status is redundantly encoded via colour, point shape, and error-bar linetype. RealSE intervals use plug-in Infit MnSq.",
    if (any(!is.finite(raters_cls[[x_col]])))
      paste("Raters omitted because Infit MnSq is unavailable:", paste(raters_cls$Level[!is.finite(raters_cls[[x_col]])], collapse = ", ")),
    if (any(!is.finite(zv_plot))) "Raters with unavailable ZSTD (NA) outside MnSq bounds are marked 'Outside MnSq (ZSTD Unavailable)' rather than satisfying joint MnSq + ZSTD screening.",
    if (eb_shrunk) "Intervals unavailable: empirical_bayes_facet_shrinkage.",
    unique(df$InferenceReason[nzchar(df$InferenceReason)])
  )
  p
}

.tidymfrm_plot_dstudy <- function(gt, palette = "okabe_ito", base_size = 11) {
  ds <- as.data.frame(gt$d_study)
  facet_cols <- gt$facets
  fixed <- character()
  primary_f <- facet_cols[1L]
  secondary_f <- if (length(facet_cols) >= 2L) facet_cols[2L] else NULL
  if (length(facet_cols) >= 3L) {
    for (fc3 in facet_cols[-c(1L, 2L)]) {
      u3 <- sort(unique(ds[[fc3]]))
      count <- u3[ceiling(length(u3) / 2)]
      ds <- ds[ds[[fc3]] == count, , drop = FALSE]
      fixed <- c(fixed, paste(fc3, "=", count))
    }
  }

  grp_chr <- if (!is.null(secondary_f)) paste0(secondary_f, " = ", ds[[secondary_f]]) else "Single-facet design"
  long_df <- rbind(
    data.frame(PrimaryN = ds[[primary_f]], SecondaryGroup = grp_chr,
               Metric = "G (Relative)", Coefficient = ds$G, stringsAsFactors = FALSE),
    data.frame(PrimaryN = ds[[primary_f]], SecondaryGroup = grp_chr,
               Metric = "Phi (Absolute)", Coefficient = ds$Phi, stringsAsFactors = FALSE)
  )
  grp_lvls <- unique(long_df$SecondaryGroup)
  long_df$SecondaryGroup <- factor(long_df$SecondaryGroup, levels = grp_lvls)
  cols <- stats::setNames(.tidymfrm_palette(length(grp_lvls), palette = palette), grp_lvls)
  shapes <- stats::setNames(.tidymfrm_shapes(length(grp_lvls)), grp_lvls)
  targets <- unname(gt$targets[c("G", "Phi")])

  p <- ggplot2::ggplot(
    long_df,
    ggplot2::aes(
      x = .data$PrimaryN,
      y = .data$Coefficient,
      colour = .data$SecondaryGroup,
      shape = .data$SecondaryGroup,
      linetype = .data$Metric
    )
  ) +
    ggplot2::geom_hline(yintercept = targets[1L], linetype = "dotted", colour = "#666666", linewidth = 0.45) +
    ggplot2::geom_line(linewidth = 0.8, na.rm = TRUE) +
    ggplot2::geom_point(size = 2.4, na.rm = TRUE) +
    ggplot2::scale_colour_manual(values = cols, name = if (!is.null(secondary_f)) secondary_f else "Design") +
    ggplot2::scale_shape_manual(values = shapes, name = if (!is.null(secondary_f)) secondary_f else "Design") +
    ggplot2::scale_linetype_manual(values = c("G (Relative)" = "solid", "Phi (Absolute)" = "dashed"), name = "Coefficient") +
    ggplot2::scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, by = 0.2)) +
    ggplot2::labs(
      x = sprintf("Sample Size for %s", primary_f),
      y = "Generalizability / Dependability"
    ) +
    .tidymfrm_theme(base_size = base_size)

  if (targets[1L] != targets[2L]) p <- p + ggplot2::geom_hline(
    yintercept = targets[2L], linetype = "dotdash", colour = "#666666", linewidth = 0.45)
  attr(p, "mfrm_notes") <- c(
    "G-Study and D-Study coefficients operate on the observed score scale (Brennan, 2001).",
    if (targets[1L] == targets[2L]) sprintf("Dotted line marks the shared G and Phi target %.2f.", targets[1L]) else
      sprintf("Dotted line marks G target %.2f. Dot-dash line marks Phi target %.2f.", targets[1L], targets[2L]),
    if (length(fixed)) paste("Displayed slice fixes", paste(fixed, collapse = ", ")),
    if (anyNA(ds$G) || anyNA(ds$Phi)) paste("Unavailable in this slice:",
      paste(unique(c(ds$GStatus[is.na(ds$G)], ds$PhiStatus[is.na(ds$Phi)])), collapse = ", "))
  )
  p
}

.mfrm_plot_context_curves <- function(fit, newdata, palette, base_size) {
  facets <- fit$encoding$base_facets
  if (is.null(newdata)) newdata <- fit$encoding$retained_data[1L, facets, drop = FALSE]
  if (!is.data.frame(newdata) || !nrow(newdata) || !all(facets %in% names(newdata))) {
    stop("Provide one row per rating context in newdata with every model facet column.", call. = FALSE)
  }
  contexts <- unique(newdata[facets])
  held <- fit$steps$Supported & !fit$steps$Identified
  omitted <- unique(fit$steps$ScaleLevel[held])
  note <- if (length(omitted)) paste("Unidentified step thresholds withheld for", paste(omitted, collapse = ", "))
  if (length(omitted)) {
    owner <- if (fit$encoding$model_code == 1L) contexts[[fit$step_facet]] else rep("Common", nrow(contexts))
    contexts <- contexts[!owner %in% omitted, , drop = FALSE]
    if (!nrow(contexts)) {
      p <- ggplot2::ggplot() + ggplot2::theme_void()
      attr(p, "mfrm_notes") <- note
      return(p)
    }
  }
  labels <- make.unique(vapply(seq_len(nrow(contexts)), function(i) {
    paste(paste(facets, vapply(contexts, function(col) as.character(col[i]), character(1))), collapse = " / ")
  }, character(1)))
  theta <- seq(-4, 4, length.out = 121L)
  index <- rep(seq_len(nrow(contexts)), each = length(theta))
  nd <- contexts[index, , drop = FALSE]
  ability <- rep(theta, times = nrow(contexts))
  probs <- stats::predict(fit, newdata = nd, type = "probs", theta = ability)
  df <- data.frame(theta = ability, ContextID = index,
                   RatingContext = factor(labels[index], levels = labels),
                   Category = rep(colnames(probs), each = nrow(probs)),
                   Probability = as.vector(probs))
  df$Category <- factor(df$Category, levels = colnames(probs))
  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$theta, y = .data$Probability, colour = .data$Category,
                                       linetype = .data$Category)) +
    ggplot2::geom_line(linewidth = .8) +
    ggplot2::facet_wrap(~ RatingContext, labeller = ggplot2::label_wrap_gen(width = 28)) +
    ggplot2::scale_colour_manual(values = .tidymfrm_palette(ncol(probs), palette)) +
    ggplot2::scale_linetype_manual(values = .tidymfrm_linetypes(ncol(probs))) +
    ggplot2::scale_y_continuous(limits = c(0, 1)) +
    ggplot2::labs(x = "Person ability (logits)", y = "Category probability") +
    .tidymfrm_theme(base_size)
  check <- summary(fit)$readiness
  attr(p, "mfrm_notes") <- c(
    note, "Curves use fitted steps, facet locations and all discrimination families for the stated rating contexts.",
    "These are conditional point predictions. Contexts can differ in severity, thresholds and discrimination.",
    if (!check$ready) paste("Review calibration:", paste(check$reason_codes, collapse = ", "))
  )
  p
}

#' Plot End-to-End Many-Facet Measurement, Generalizability, and Rater Diagnostics
#'
#' Produces clean, publication-ready, color-vision-safe `ggplot2` figures from a
#' [mfrm_analysis()] workflow object. Every multi-group aesthetic pairs `colour`
#' (`"okabe_ito"`, `"viridis"`, or `"monochrome"`) with distinct point `shape`
#' and `linetype` encodings. By default, plot titles and footnotes are omitted
#' from the canvas and stored in `attr(p, "mfrm_notes")`.
#'
#' @param x A `tidymfrm` object.
#' @param type Plot type:
#'   - `"pathway"`: Facet measures against `Infit` or `Outfit`. Pass
#'     `fit_statistic = "both"` for separate panels and `facet = "Rater"` to select raters.
#'   - `"wright"`: Leftward person histogram, density or frequency stars, facet locations
#'     and steps. Pass `person_display = "stars", persons_per_star = 3, yardstick = 2`
#'     for two rows per logit. The right-hand Fair average ruler accepts a `reference_plan`.
#'     See [plot.mfrm_fit()] for its reference conditions and bin boundaries.
#'   - `"raters"`: Rater severity vs `Infit MnSq` diagnostic map with 95% `Real SE` intervals.
#'   - `"steps"` / `"category_curves"`: Category characteristic curves (CCCs) and Andrich step thresholds.
#'   - `"dstudy"`: D-Study generalizability (\eqn{G}) and dependability (\eqn{\Phi}{Phi}) curves across sample sizes.
#'   - `"dstudy_frontier"`: Best point projection achievable at or below each evaluated rating count, with separate G and Phi targets.
#'   - `"gstudy"`: Observed-plan coefficients by subscore and for the weighted composite.
#'   - `"persons"`: Person logit ability vs rubric-scale `Fair(M)` with 95% `Real SE` intervals and cut-score lines.
#'   - `"person_fit"`: Person `Infit MnSq` vs `Outfit MnSq` scatter with `ZSTD` screening contours.
#'   - `"residual_qq"`: Normal Q-Q plot of standardized Pearson observation residuals.
#'   - `"slopes"`: Forest plot of GPCM discrimination slopes (`model = "GPCM"`).
#'   - `"drift"`: Dynamic Markov rater severity trajectories across rating waves (`occasion`).
#'   - `"qc"`: Four-panel model quality-control summary.
#'   - `"dashboard"`: Four-panel workflow overview combining `"wright"`, `"raters"`, `"steps"`, and `"dstudy"` (or `"persons"`).
#' @param palette Color palette: `"okabe_ito"` (default), `"viridis"`, or `"monochrome"`
#'   (strict `R == G == B` grayscale with distinct shapes and linetypes).
#' @param base_size Base font size in pts (default `11`).
#' @param draw Logical; if `TRUE` (default), renders on the active graphics device;
#'   if `FALSE`, returns the `ggplot` (or dashboard) without drawing.
#' @param ... Additional arguments passed to underlying [graphics::plot()] methods.
#' @param interactive Return an optional Plotly widget for Wright maps, category curves, rater/pathway and fit-sensitivity plots.
#' @param newdata For a Wright map supply one calibrated context for adjacent-category crossings. For `type = "category_curves"` or `"steps"`, a data frame with
#'   all model facet columns and one row per rating context. With GPCM, the
#'   default is the first retained context. Predictions span ability -4 to 4.
#' @return An interactive call returns a Plotly widget. Static calls return a `ggplot` object (with `attr(, "mfrm_notes")`), or for `type = "dashboard"`,
#'   a `tidymfrm_dashboard` named list of four `ggplot` panels.
#' @examples
#' # Saved JML calibration of example_core; see fit_mfrm() for estimation.
#' saved <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
#' ratings <- load_mfrmr_data(saved$dataset)
#' wf <- mfrm_workflow(ratings, "Person", c("Rater", "Criterion"), "Score",
#'                     fit = saved$fit) |>
#'   step_mfrm_diagnose()
#' p_wright <- plot(wf, type = "wright", palette = "okabe_ito", draw = FALSE)
#' p_vir <- plot(wf, type = "raters", palette = "viridis", draw = FALSE)
#' p_mono <- plot(wf, type = "steps", palette = "monochrome", draw = FALSE)
#' attr(p_wright, "mfrm_notes")
#' @export
plot.tidymfrm <- function(x,
                          type = c("wright", "raters", "steps", "category_curves", "dstudy", "persons",
                                   "person_fit", "residual_qq", "slopes", "drift", "qc", "dashboard",
                                   "dstudy_frontier", "gstudy", "pathway", "fit_sensitivity", "cut_sensitivity"),
                          palette = c("okabe_ito", "viridis", "monochrome"),
                          base_size = 11,
                          draw = TRUE,
                          ..., newdata = NULL, interactive = FALSE) {
  x <- .tidymfrm_refresh(x)
  type <- match.arg(type)
  palette <- match.arg(palette)
  dots <- list(...)
  if (isTRUE(interactive) && !type %in% .mfrm_interactive_types)
    stop("Interactive plots support: ", paste(.mfrm_interactive_types, collapse = ", "), ".", call. = FALSE)

  if (type == "dashboard") {
    if (is.null(x$fit)) stop("Run `step_mfrm_measure()` before plotting a dashboard.", call. = FALSE)
    p1 <- plot.tidymfrm(x, type = "wright", palette = palette, base_size = base_size * 0.9, draw = FALSE)
    p2 <- plot.tidymfrm(x, type = "raters", palette = palette, base_size = base_size * 0.9, draw = FALSE)
    p3 <- plot.tidymfrm(x, type = "steps", palette = palette, base_size = base_size * 0.9, draw = FALSE)
    p4 <- if (!is.null(x$gtheory)) {
      plot.tidymfrm(x, type = "dstudy", palette = palette, base_size = base_size * 0.9, draw = FALSE)
    } else {
      plot.tidymfrm(x, type = "persons", palette = palette, base_size = base_size * 0.9, draw = FALSE)
    }
    dash <- structure(
      list(wright = p1, raters = p2, steps = p3, fourth = p4),
      class = "tidymfrm_dashboard"
    )
    if (isTRUE(draw)) print(dash)
    return(invisible(dash))
  }

  p <- switch(
    type,
    pathway = {
      if (is.null(x$fit)) stop("Run step_mfrm_measure() before plotting a pathway.", call. = FALSE)
      pw_args <- c(list(x = x$fit, type = "pathway", palette = palette, base_size = base_size), dots)
      if (is.null(pw_args$fit_method) && !is.null(x$diagnostics$fit_method)) {
        pw_args$fit_method <- x$diagnostics$fit_method
      }
      if (is.null(pw_args$mnsq_range) && !is.null(x$diagnostics$mnsq_range)) {
        pw_args$mnsq_range <- x$diagnostics$mnsq_range
      }
      do.call(graphics::plot, pw_args)
    },
    wright = {
      if (is.null(x$fit)) stop("Run `step_mfrm_measure()` before `type = 'wright'`.", call. = FALSE)
      graphics::plot(x$fit, type = "wright", palette = palette, base_size = base_size, newdata = newdata, ...)
    },
    raters = {
      if (!is.null(x$diagnostics$raters)) {
        .tidymfrm_plot_raters(
          x$diagnostics$raters,
          mnsq_range = dots$mnsq_range %||% x$diagnostics$mnsq_range,
          zstd_limit = dots$zstd_limit %||% x$diagnostics$zstd_limit %||% 2.0,
          fit_method = dots$fit_method, method_label = x$fit$method,
          reference_bands = dots$reference_bands,
          palette = palette,
          base_size = base_size
        )
      } else if (!is.null(x$fit)) {
        graphics::plot(x$fit, type = "raters", facet = x$spec$rater_facet,
                       palette = palette, base_size = base_size, ...)
      } else {
        stop("Run `step_mfrm_measure()` before `type = 'raters'`.", call. = FALSE)
      }
    },
    fit_sensitivity = {
      if (is.null(x$fit)) stop("Run `step_mfrm_measure()` before `type = 'fit_sensitivity'`.", call. = FALSE)
      f_use <- if ("facet" %in% names(dots)) dots$facet else x$spec$rater_facet
      fc_use <- x$fit$facets
      if (!is.null(f_use)) fc_use <- fc_use[fc_use$Facet %in% f_use, , drop = FALSE]
      .mfrm_gg_fit_sensitivity(
        fc_use,
        mnsq_range = dots$mnsq_range %||% x$diagnostics$mnsq_range %||% c(0.70, 1.30),
        zstd_limit = dots$zstd_limit %||% x$diagnostics$zstd_limit %||% 2.0,
        fit_statistic = dots$fit_statistic %||% "infit",
        fit_method = dots$fit_method %||% "auto",
        half_widths = dots$half_widths %||% seq(0.15, 0.55, by = 0.01),
        palette = palette,
        base_size = base_size,
        method_label = x$fit$method
      )
    },
    cut_sensitivity = {
      if (is.null(x$fit)) stop("Run `step_mfrm_measure()` before `type = 'cut_sensitivity'`.", call. = FALSE)
      def_cuts <- if (!is.null(x$diagnostics$decisions)) x$diagnostics$decisions$CutFairM else NULL
      .mfrm_gg_cut_sensitivity(
        x$fit,
        cut_scores = dots$cut_scores %||% def_cuts,
        cut_grid = dots$cut_grid,
        palette = palette,
        base_size = base_size
      )
    },
    steps = ,
    category_curves = {
      if (is.null(x$fit)) stop("Run `step_mfrm_measure()` before `type = 'steps'`.", call. = FALSE)
      if (identical(x$fit$model, "GPCM") || !is.null(newdata)) {
        .mfrm_plot_context_curves(x$fit, newdata = newdata, palette = palette, base_size = base_size)
      } else graphics::plot(x$fit, type = "category_curves", palette = palette, base_size = base_size, ...)
    },
    person_fit = ,
    residual_qq = ,
    slopes = ,
    qc = {
      if (is.null(x$fit)) stop("Run `step_mfrm_measure()` before plotting.", call. = FALSE)
      graphics::plot(x$fit, type = type, palette = palette, base_size = base_size, ...)
    },
    drift = {
      dr <- x[["drift"]]
      if (is.null(dr)) {
        msg <- x[["drift_reason"]] %||% "Supply `occasion` in `mfrm_analysis()` / `step_mfrm_measure()` before `type = 'drift'`."
        stop(msg, call. = FALSE)
      }
      graphics::plot(dr, palette = palette, base_size = base_size, ...)
    },
    dstudy = {
      if (is.null(x$gtheory)) stop("Run `step_mfrm_gtheory()` before `type = 'dstudy'`.", call. = FALSE)
      .tidymfrm_plot_dstudy(x$gtheory, palette = palette, base_size = base_size)
    },
    dstudy_frontier = {
      if (is.null(x$gtheory)) stop("Run step_mfrm_gtheory() before plotting D-Study plans.", call. = FALSE)
      .tidymfrm_plot_frontier(x$gtheory, palette, base_size)
    },
    gstudy = {
      if (is.null(x$gtheory)) stop("Run step_mfrm_gtheory() before plotting G-Study coefficients.", call. = FALSE)
      .tidymfrm_plot_gstudy(x$gtheory, palette, base_size)
    },
    persons = {
      if (is.null(x$fit)) stop("Run `step_mfrm_measure()` before `type = 'persons'`.", call. = FALSE)
      p_per <- graphics::plot(x$fit, type = "persons", palette = palette, base_size = base_size, ...)
      cuts <- if (!is.null(x$diagnostics$decisions)) x$diagnostics$decisions$CutFairM else NULL
      if (!is.null(cuts) && length(cuts) >= 1L) {
        p_per <- p_per + ggplot2::geom_hline(
          yintercept = as.numeric(cuts),
          linetype = "dashed", colour = "#555555", linewidth = 0.45
        )
      }
      p_per
    }
  )
  if (isTRUE(interactive)) return(.mfrm_plotly(p, type))
  if (isTRUE(draw)) print(p)
  if (isTRUE(draw)) invisible(p) else p
}

#' @export
print.tidymfrm_dashboard <- function(x, ...) {
  grid::grid.newpage()
  vp_layout <- grid::grid.layout(nrow = 2L, ncol = 2L)
  grid::pushViewport(grid::viewport(layout = vp_layout))
  positions <- list(c(1L, 1L), c(1L, 2L), c(2L, 1L), c(2L, 2L))
  for (i in seq_along(x)) {
    pos <- positions[[i]]
    print(x[[i]], vp = grid::viewport(layout.pos.row = pos[1L], layout.pos.col = pos[2L]))
  }
  grid::popViewport()
  invisible(x)
}
