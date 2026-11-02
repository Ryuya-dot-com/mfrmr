# Two-dimensional subgroup scatterplot with marginal histograms for DFF/DIF results.

plot_dif_scatter <- function(x,
                             metric = c("auto", "contrast", "obs_exp", "t"),
                             marginal = c("auto", "histogram", "none"),
                             top_n = Inf,
                             sort_by = c("abs_effect", "effect", "classification"),
                             groups = NULL,
                             show_labels = TRUE,
                             effect_thresholds = NULL,
                             preset = .mfrm_default_plot_preset(),
                             title = NULL,
                             main = NULL,
                             show_title = FALSE,
                             show_notes = FALSE,
                             draw = TRUE) {
  title <- .mfrm_plot_title_alias(main, title, missing(main), missing(title))
  if (missing(preset)) preset <- .mfrm_default_plot_preset()
  if (!inherits(x, c("mfrm_dff", "mfrm_dif"))) {
    stop("`x` must be output from analyze_dff().", call. = FALSE)
  }
  validate_dff_residual_output(x)
  metric <- match.arg(metric)
  marginal <- .mfrmr_resolve_marginal_arg(marginal)
  sort_by <- match.arg(sort_by)
  if (!identical(top_n, Inf)) {
    top_n <- .validate_dff_count_arg(top_n, "top_n")
  }
  effect_thresholds <- .validate_dff_threshold_vector(effect_thresholds, "effect_thresholds")
  for (flag in c("show_labels", "show_title", "show_notes", "draw")) {
    val <- get(flag)
    if (!is.logical(val) || length(val) != 1L || is.na(val)) {
      stop("`", flag, "` must be TRUE or FALSE.", call. = FALSE)
    }
  }
  style <- resolve_plot_preset(preset)
  tbl <- as.data.frame(x$dif_table, stringsAsFactors = FALSE)
  if (nrow(tbl) == 0L) {
    stop("Empty differential-functioning table.", call. = FALSE)
  }
  method <- as.character(x$config$method %||% unique(as.character(tbl$Method))[1L] %||% "refit")[1L]
  resolved_metric <- if (identical(metric, "auto")) {
    if (identical(method, "residual")) "obs_exp" else "contrast"
  } else {
    metric
  }
  if (identical(method, "residual") && identical(resolved_metric, "contrast")) {
    stop("Subgroup location scatterplots (`metric = \"contrast\"`) require `analyze_dff(..., method = \"refit\")`.", call. = FALSE)
  }
  if (!identical(method, "residual") && resolved_metric %in% c("obs_exp", "t") && is.null(x$cell_table)) {
    stop("Residual cell metrics (`obs_exp`, `t`) require `analyze_dff(..., method = \"residual\")`.", call. = FALSE)
  }

  if (!is.null(groups)) {
    if (!is.character(groups) || length(groups) != 2L || anyNA(groups) || !all(nzchar(groups))) {
      stop("`groups` must be NULL or a character vector of two subgroup names.", call. = FALSE)
    }
    keep_pair <- (tbl$Group1 == groups[1L] & tbl$Group2 == groups[2L]) |
      (tbl$Group1 == groups[2L] & tbl$Group2 == groups[1L])
    tbl <- tbl[keep_pair, , drop = FALSE]
    if (nrow(tbl) == 0L) {
      stop("Requested `groups` pair was not found in `x$dif_table`.", call. = FALSE)
    }
  }

  pairs <- tbl
  tbl$.PlotRow <- seq_len(nrow(tbl))

  if (identical(resolved_metric, "contrast")) {
    if (!all(c("Estimate1", "Estimate2") %in% names(tbl))) {
      stop("Refit DFF table is missing `Estimate1` and `Estimate2` columns.", call. = FALSE)
    }
    e1 <- suppressWarnings(as.numeric(tbl$Estimate1))
    e2 <- suppressWarnings(as.numeric(tbl$Estimate2))
    fixed_row <- (tbl[["Fixed1"]] %in% TRUE) | (tbl[["Fixed2"]] %in% TRUE) |
      (tbl[["ComparisonStatus"]] %in% "fixed_target") |
      (tbl[["Classification"]] %in% "Fixed target; no comparison")
    contrast_num <- suppressWarnings(as.numeric(tbl$Contrast))
    comparable <- !fixed_row & is.finite(e1) & is.finite(e2) & is.finite(contrast_num)
    pairs$PlotStatus <- ifelse(
      fixed_row,
      "Fixed target; no comparison",
      ifelse(comparable, "Not selected by top_n", "Contrast unavailable")
    )
    tbl$X <- ifelse(comparable, e1, NA_real_)
    tbl$Y <- ifelse(comparable, e2, NA_real_)
    tbl$Effect <- ifelse(comparable, contrast_num, NA_real_)
    n_fixed <- sum(fixed_row, na.rm = TRUE)
    unit_label <- "logits"
    base_xlab <- "Subgroup location"
    plot_title_default <- "Subgroup location scatterplot"
  } else {
    cells <- as.data.frame(x$cell_table %||% data.frame(), stringsAsFactors = FALSE)
    col_val <- if (identical(resolved_metric, "obs_exp")) "ObsExpAvg" else "StdResidual"
    if (!all(c("Level", "GroupValue", col_val) %in% names(cells))) {
      stop("`x$cell_table` lacks required subgroup residual columns.", call. = FALSE)
    }
    key_cell <- paste(cells$Level, cells$GroupValue, sep = "\r")
    val_vec <- suppressWarnings(as.numeric(cells[[col_val]]))
    sparse_vec <- if ("sparse" %in% names(cells)) cells$sparse %in% TRUE else rep(FALSE, nrow(cells))
    val_vec[sparse_vec] <- NA_real_
    idx1 <- match(paste(tbl$Level, tbl$Group1, sep = "\r"), key_cell)
    idx2 <- match(paste(tbl$Level, tbl$Group2, sep = "\r"), key_cell)
    v1 <- ifelse(is.na(idx1), NA_real_, val_vec[idx1])
    v2 <- ifelse(is.na(idx2), NA_real_, val_vec[idx2])
    comparable <- is.finite(v1) & is.finite(v2) & !(tbl[["sparse"]] %in% TRUE)
    pairs$PlotStatus <- ifelse(comparable, "Not selected by top_n", "Residual unavailable")
    tbl$X <- ifelse(comparable, v1, NA_real_)
    tbl$Y <- ifelse(comparable, v2, NA_real_)
    tbl$Effect <- ifelse(comparable, v1 - v2, NA_real_)
    n_fixed <- 0L
    unit_label <- if (identical(resolved_metric, "obs_exp")) "score units" else "standardized units"
    base_xlab <- if (identical(resolved_metric, "obs_exp")) "Mean observed - expected" else "Scaled cell residual"
    plot_title_default <- "Subgroup residual scatterplot"
  }

  sub <- tbl[is.finite(tbl$X) & is.finite(tbl$Y), , drop = FALSE]
  if (nrow(sub) == 0L) {
    stop("No finite comparable subgroup pairs to plot.", call. = FALSE)
  }

  sub$Classification <- if ("Classification" %in% names(sub)) {
    as.character(sub$Classification)
  } else if ("ETS" %in% names(sub)) {
    as.character(sub$ETS)
  } else {
    NA_character_
  }
  ord <- switch(
    sort_by,
    abs_effect = order(-abs(sub$Effect), na.last = TRUE),
    effect = order(sub$Effect, na.last = TRUE),
    classification = order(sub$Classification, -abs(sub$Effect), na.last = TRUE)
  )
  sub <- sub[ord, , drop = FALSE]
  if (is.finite(top_n) && nrow(sub) > top_n) {
    sub <- sub[seq_len(top_n), , drop = FALSE]
  }
  pairs$PlotStatus[sub$.PlotRow] <- "Displayed"

  unique_pairs <- unique(sub[, intersect(c("Group1", "Group2"), names(sub)), drop = FALSE])
  if (nrow(unique_pairs) == 1L && all(c("Group1", "Group2") %in% names(unique_pairs))) {
    xlab <- sprintf("%s: %s (%s)", base_xlab, unique_pairs$Group1[1L], unit_label)
    ylab <- sprintf("%s: %s (%s)", base_xlab, unique_pairs$Group2[1L], unit_label)
    sub$Label <- as.character(sub$Level)
  } else {
    xlab <- sprintf("%s: Group 1 (%s)", base_xlab, unit_label)
    ylab <- sprintf("%s: Group 2 (%s)", base_xlab, unit_label)
    pair_cols <- intersect(c("Level", "Group1", "Group2"), names(sub))
    sub$Label <- if (length(pair_cols)) do.call(paste, c(sub[pair_cols], sep = " | ")) else as.character(seq_len(nrow(sub)))
  }

  class_colors <- c(
    A = style$accent_primary,
    B = style$warn,
    C = style$fail,
    Negligible = style$accent_primary,
    Moderate = style$warn,
    Large = style$fail,
    Descriptive = style$accent_primary
  )
  sub$ClassLabel <- ifelse(
    is.na(sub$Classification) | !nzchar(sub$Classification),
    "Unclassified",
    as.character(sub$Classification)
  )
  sub$Color <- unname(class_colors[sub$ClassLabel])
  sub$Color[is.na(sub$Color)] <- style$accent_primary

  hist_info <- .mfrmr_compute_marginal_bins(
    x = sub$X,
    y = sub$Y,
    marginal = marginal,
    min_n = 8L,
    single_panel = TRUE
  )

  classification_system <- unique(as.character(sub$ClassificationSystem %||% NA_character_))
  classification_system <- classification_system[!is.na(classification_system)][1L] %||% NA_character_

  payload_df <- data.frame(
    Level = as.character(sub$Level %||% sub$Label),
    Group1 = as.character(sub$Group1 %||% NA_character_),
    Group2 = as.character(sub$Group2 %||% NA_character_),
    Label = as.character(sub$Label),
    X = as.numeric(sub$X),
    Y = as.numeric(sub$Y),
    Effect = as.numeric(sub$Effect),
    SE = if ("SE" %in% names(sub)) suppressWarnings(as.numeric(sub$SE)) else NA_real_,
    Classification = as.character(sub$Classification),
    ClassLabel = as.character(sub$ClassLabel),
    ClassificationSystem = if ("ClassificationSystem" %in% names(sub)) as.character(sub$ClassificationSystem) else NA_character_,
    ScaleLinkStatus = if ("ScaleLinkStatus" %in% names(sub)) as.character(sub$ScaleLinkStatus) else NA_character_,
    Color = as.character(sub$Color),
    stringsAsFactors = FALSE
  )

  note_text <- if (identical(method, "residual")) {
    "Subgroup residual averages are descriptive screening summaries; equality line does not establish measurement invariance, and no confidence interval is provided."
  } else {
    paste0(
      "Subgroup locations condition on the estimated linking anchors; check ScaleLinkStatus before substantive comparison.",
      if (n_fixed > 0L) paste0(" ", n_fixed, " fixed-target row(s) have no contrast and are omitted; equal anchors do not establish invariance.") else ""
    )
  }
  notes_df <- data.frame(Type = "Interpretation", Text = note_text, stringsAsFactors = FALSE)
  if (is.list(x$comparison_review) && is.character(x$comparison_review$summary_note) &&
      nzchar(x$comparison_review$summary_note[1L])) {
    notes_df <- rbind(
      notes_df,
      data.frame(Type = "comparison_review", Text = x$comparison_review$summary_note[1L], stringsAsFactors = FALSE)
    )
  }

  out <- new_mfrm_plot_data(
    "dif_scatter",
    list(
      data = payload_df,
      table = payload_df,
      pairs = pairs,
      cases = x$cases,
      analysis_config = x$config,
      comparison_review = x$comparison_review,
      marginal_histograms = hist_info,
      retention_note = sprintf(
        "%d of %d source comparisons displayed; %d omitted as fixed/unavailable and %d not selected by top_n.",
        nrow(payload_df),
        nrow(pairs),
        sum(!pairs$PlotStatus %in% c("Displayed", "Not selected by top_n")),
        sum(pairs$PlotStatus == "Not selected by top_n")
      ),
      notes = notes_df,
      metric = resolved_metric,
      method = method,
      xlab = xlab,
      ylab = ylab,
      title = if (!is.null(title) && nzchar(title)) title else plot_title_default,
      subtitle = sprintf("%d comparable subgroup pairs shown", nrow(payload_df)),
      display = list(
        show_title = show_title,
        show_notes = show_notes,
        show_labels = show_labels,
        marginal = marginal
      ),
      settings = list(
        metric = resolved_metric,
        marginal = marginal,
        effect_thresholds = effect_thresholds,
        sort_by = sort_by,
        top_n = top_n,
        show_labels = show_labels
      ),
      interpretation_guide = .dff_interpretation_guide(
        metric = if (identical(resolved_metric, "contrast")) "summary" else resolved_metric,
        method = method,
        classification_system = classification_system,
        effect_thresholds = effect_thresholds
      ),
      gpcm_boundary = x$gpcm_boundary %||% data.frame(),
      legend = new_plot_legend(
        label = unique(payload_df$ClassLabel),
        role = rep("classification", length(unique(payload_df$ClassLabel))),
        aesthetic = rep("point", length(unique(payload_df$ClassLabel))),
        value = unique(payload_df$Color)
      ),
      reference_lines = new_reference_lines("diag", 1, "Equality (Group 1 = Group 2)", "dashed", "reference"),
      preset = style$name
    )
  )

  .mfrm_finalize_ggplot(out, draw = draw, builder = .mfrmr_gg_dif_scatter)
}

.mfrmr_gg_dif_scatter <- function(x) {
  payload <- x$data
  df <- as.data.frame(payload$data %||% data.frame(), stringsAsFactors = FALSE)
  style <- resolve_plot_preset(payload$preset %||% "standard")
  if (nrow(df) == 0L || !all(c("X", "Y") %in% names(df))) {
    p <- .mfrmr_empty_ggplot("No finite subgroup pairs available.", payload = payload, preset = style$name)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }
  df <- df[is.finite(df$X) & is.finite(df$Y), , drop = FALSE]
  if (nrow(df) == 0L) {
    p <- .mfrmr_empty_ggplot("No finite subgroup pairs available.", payload = payload, preset = style$name)
    attr(p, "mfrmr_plot_data") <- x
    return(p)
  }

  thresholds <- suppressWarnings(as.numeric(payload$settings$effect_thresholds %||% numeric()))
  thresholds <- thresholds[is.finite(thresholds) & thresholds > 0]
  rng <- range(c(df$X, df$Y), finite = TRUE)
  pad <- max(0.08, 0.12 * diff(rng))
  if (!is.finite(pad) || pad <= 0) pad <- 0.25
  lims <- rng + c(-pad, pad)

  class_levels <- unique(as.character(df$ClassLabel %||% "Unclassified"))
  color_map <- stats::setNames(
    as.character(df$Color[match(class_levels, df$ClassLabel)]),
    class_levels
  )
  color_map[is.na(color_map)] <- style$accent_primary
  shape_pool <- c(16, 17, 15, 18, 21, 24)
  shape_map <- stats::setNames(rep(shape_pool, length.out = length(class_levels)), class_levels)
  df$ClassFactor <- factor(df$ClassLabel, levels = class_levels)

  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$X, y = .data$Y)) +
    ggplot2::geom_abline(
      slope = 1,
      intercept = 0,
      linetype = "dashed",
      colour = style$ref_line,
      linewidth = 0.5
    )

  if (length(thresholds) > 0L) {
    for (thr in thresholds) {
      p <- p +
        ggplot2::geom_abline(
          slope = 1,
          intercept = thr,
          linetype = "dotted",
          colour = style$warn,
          linewidth = 0.42
        ) +
        ggplot2::geom_abline(
          slope = 1,
          intercept = -thr,
          linetype = "dotted",
          colour = style$warn,
          linewidth = 0.42
        )
    }
  }

  p <- p +
    ggplot2::geom_point(
      ggplot2::aes(colour = .data$ClassFactor, shape = .data$ClassFactor),
      size = 2.7,
      alpha = 0.88
    ) +
    ggplot2::scale_colour_manual(values = color_map, name = "Classification") +
    ggplot2::scale_shape_manual(values = shape_map, name = "Classification") +
    ggplot2::coord_equal(xlim = lims, ylim = lims, expand = FALSE) +
    .mfrmr_gg_theme_styled(style$name)

  if (length(class_levels) <= 1L && identical(class_levels, "Unclassified")) {
    p <- p + ggplot2::guides(colour = "none", shape = "none")
  }

  show_labels <- isTRUE(payload$display$show_labels %||% payload$settings$show_labels %||% TRUE)
  if (show_labels && "Label" %in% names(df) && nrow(df) <= 60L) {
    p <- p + ggplot2::geom_text(
      ggplot2::aes(label = .data$Label),
      vjust = -0.85,
      size = 2.8,
      colour = style$foreground,
      check_overlap = TRUE,
      show.legend = FALSE
    )
  }

  p <- .mfrmr_gg_labs(p, payload, x = payload$xlab, y = payload$ylab)
  p <- .mfrmr_attach_marginal_histograms(
    p,
    x = df$X,
    y = df$Y,
    marginal = payload$display$marginal %||% payload$settings$marginal %||% "auto",
    preset = style$name,
    hist_info = payload$marginal_histograms
  )
  attr(p, "mfrmr_plot_data") <- x
  p
}
