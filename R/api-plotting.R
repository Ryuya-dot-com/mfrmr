# Plot helpers for `plot.mfrm_fit()`.
step_index_from_label <- function(step_labels) {
  step_labels <- as.character(step_labels)
  idx <- suppressWarnings(as.integer(gsub("[^0-9]+", "", step_labels)))
  if (all(is.na(idx))) return(seq_along(step_labels))
  if (any(is.na(idx))) {
    fill_start <- max(idx, na.rm = TRUE)
    idx[is.na(idx)] <- fill_start + seq_len(sum(is.na(idx)))
  }
  idx
}

build_step_curve_spec <- function(x) {
  step_tbl <- x$steps
  if (is.null(step_tbl) || nrow(step_tbl) == 0 || !"Estimate" %in% names(step_tbl)) {
    stop("Step estimates are required for pathway/CCC plots.")
  }
  step_tbl <- tibble::as_tibble(step_tbl)

  model <- toupper(as.character(x$config$model[1]))
  rating_min <- suppressWarnings(min(as.numeric(x$prep$data$Score), na.rm = TRUE))
  if (!is.finite(rating_min)) rating_min <- 0

  n_cat <- suppressWarnings(as.integer(x$config$n_cat[1]))
  if (!is.finite(n_cat) || n_cat < 2) {
    n_cat <- max(2L, nrow(step_tbl) + 1L)
  }
  categories <- rating_min + 0:(n_cat - 1L)

  groups <- list()
  step_points <- tibble::tibble()

  if (model == "RSM") {
    if (!"Step" %in% names(step_tbl)) {
      step_tbl$Step <- paste0("Step_", seq_len(nrow(step_tbl)))
    }
    ord <- order(step_index_from_label(step_tbl$Step))
    tau <- as.numeric(step_tbl$Estimate[ord])
    groups[["Common"]] <- list(name = "Common", step_cum = c(0, cumsum(tau)), tau = tau)
    step_points <- tibble::tibble(
      CurveGroup = "Common",
      Step = as.character(step_tbl$Step[ord]),
      StepIndex = seq_along(tau),
      Threshold = tau
    )
  } else {
    if (!all(c("StepFacet", "Step", "Estimate") %in% names(step_tbl))) {
      stop("PCM step table must include StepFacet, Step, and Estimate columns.")
    }
    step_facet <- as.character(x$config$step_facet[1])
    ordered_levels <- x$prep$levels[[step_facet]]
    if (is.null(ordered_levels)) {
      ordered_levels <- unique(as.character(step_tbl$StepFacet))
    }
    for (lvl in ordered_levels) {
      sub <- step_tbl[as.character(step_tbl$StepFacet) == as.character(lvl), , drop = FALSE]
      if (nrow(sub) == 0) next
      ord <- order(step_index_from_label(sub$Step))
      tau <- as.numeric(sub$Estimate[ord])
      groups[[as.character(lvl)]] <- list(
        name = as.character(lvl),
        step_cum = c(0, cumsum(tau)),
        tau = tau
      )
      step_points <- dplyr::bind_rows(
        step_points,
        tibble::tibble(
          CurveGroup = as.character(lvl),
          Step = as.character(sub$Step[ord]),
          StepIndex = seq_along(tau),
          Threshold = tau
        )
      )
    }
  }

  if (length(groups) == 0) stop("No step groups available for pathway/CCC plots.")

  list(
    model = model,
    categories = categories,
    rating_min = rating_min,
    n_cat = n_cat,
    groups = groups,
    step_points = step_points
  )
}

build_curve_tables <- function(curve_spec, theta_grid) {
  prob_tables <- list()
  exp_tables <- list()
  idx_prob <- 1L
  idx_exp <- 1L
  for (g in names(curve_spec$groups)) {
    grp <- curve_spec$groups[[g]]
    probs <- category_prob_rsm(theta_grid, grp$step_cum)
    k_vals <- as.numeric(curve_spec$categories)
    expected <- as.numeric(probs %*% matrix(k_vals, ncol = 1))
    exp_tables[[idx_exp]] <- tibble::tibble(
      Theta = theta_grid,
      ExpectedScore = expected,
      CurveGroup = grp$name
    )
    idx_exp <- idx_exp + 1L
    for (k in seq_len(ncol(probs))) {
      prob_tables[[idx_prob]] <- tibble::tibble(
        Theta = theta_grid,
        Probability = probs[, k],
        Category = as.character(curve_spec$categories[k]),
        CurveGroup = grp$name
      )
      idx_prob <- idx_prob + 1L
    }
  }
  list(
    probabilities = dplyr::bind_rows(prob_tables),
    expected = dplyr::bind_rows(exp_tables)
  )
}

compute_se_for_plot <- function(x, ci_level = 0.95) {
  tryCatch({
    obs_df <- compute_obs_table(x)
    facet_cols <- x$config$source_columns$facets
    if (is.null(facet_cols) || length(facet_cols) == 0) {
      facet_cols <- x$config$facet_names
    }
    se_tbl <- calc_facet_se(obs_df, facet_cols)
    z <- stats::qnorm(1 - (1 - ci_level) / 2)
    se_tbl$CI_Lower <- -z * se_tbl$SE
    se_tbl$CI_Upper <- z * se_tbl$SE
    se_tbl$CI_Level <- ci_level
    as.data.frame(se_tbl, stringsAsFactors = FALSE)
  }, error = function(e) NULL)
}

build_wright_map_data <- function(x, top_n = 30L, se_tbl = NULL) {
  person_tbl <- tibble::as_tibble(x$facets$person)
  person_tbl <- person_tbl[is.finite(person_tbl$Estimate), , drop = FALSE]
  if (nrow(person_tbl) == 0) stop("Person estimates are not available for Wright map.")

  facet_tbl <- tibble::as_tibble(x$facets$others)
  if (!all(c("Facet", "Level", "Estimate") %in% names(facet_tbl))) {
    stop("Facet-level estimates are not available for Wright map.")
  }
  facet_tbl <- facet_tbl[is.finite(facet_tbl$Estimate), , drop = FALSE]

  step_points <- tryCatch(build_step_curve_spec(x)$step_points, error = function(e) tibble::tibble())
  step_tbl <- if (nrow(step_points) > 0) {
    tibble::tibble(
      PlotType = "Step threshold",
      Group = if ("CurveGroup" %in% names(step_points)) paste0("Step:", step_points$CurveGroup) else "Step",
      Label = step_points$Step,
      Estimate = step_points$Threshold
    )
  } else {
    tibble::tibble()
  }

  facet_pts <- facet_tbl |>
    dplyr::transmute(
      PlotType = "Facet level",
      Group = .data$Facet,
      Label = .data$Level,
      Estimate = .data$Estimate
    )
  if (!is.null(se_tbl) && is.data.frame(se_tbl) && nrow(se_tbl) > 0 &&
      all(c("Facet", "Level", "SE") %in% names(se_tbl))) {
    se_join <- se_tbl[, intersect(c("Facet", "Level", "SE", "CI_Lower", "CI_Upper"), names(se_tbl)), drop = FALSE]
    se_join$Level <- as.character(se_join$Level)
    facet_pts$Group <- as.character(facet_pts$Group)
    facet_pts$Label <- as.character(facet_pts$Label)
    facet_pts <- merge(facet_pts, se_join,
                       by.x = c("Group", "Label"), by.y = c("Facet", "Level"),
                       all.x = TRUE, sort = FALSE)
  }
  point_tbl <- dplyr::bind_rows(facet_pts, step_tbl)
  if (nrow(point_tbl) == 0) stop("No facet/step locations available for Wright map.")

  if (nrow(point_tbl) > top_n) {
    point_tbl <- point_tbl |>
      dplyr::mutate(.Abs = abs(.data$Estimate)) |>
      dplyr::arrange(dplyr::desc(.data$.Abs)) |>
      dplyr::slice_head(n = top_n) |>
      dplyr::select(-.data$.Abs)
  }

  group_levels <- unique(point_tbl$Group)
  point_tbl <- point_tbl |>
    dplyr::mutate(Group = factor(.data$Group, levels = group_levels)) |>
    dplyr::group_by(.data$Group) |>
    dplyr::arrange(.data$Estimate, .by_group = TRUE) |>
    dplyr::mutate(
      XBase = as.numeric(.data$Group),
      X = if (dplyr::n() == 1) .data$XBase else .data$XBase + seq(-0.18, 0.18, length.out = dplyr::n())
    ) |>
    dplyr::ungroup()

  list(
    title = "Wright Map",
    person = person_tbl,
    locations = point_tbl,
    group_levels = group_levels
  )
}

draw_wright_map <- function(plot_data,
                            title = NULL,
                            palette = NULL,
                            label_angle = 45,
                            show_ci = FALSE,
                            ci_level = 0.95) {
  pal <- resolve_palette(
    palette = palette,
    defaults = c(
      facet_level = "#1b9e77",
      step_threshold = "#d95f02",
      person_hist = "gray80",
      grid = "#ececec"
    )
  )
  old_par <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(old_par), add = TRUE)
  graphics::layout(matrix(c(1, 2), nrow = 1), widths = c(1.05, 2.35))
  graphics::par(mgp = c(2.6, 0.85, 0))

  graphics::par(mar = c(5.2, 5, 3.2, 1))
  graphics::hist(
    x = plot_data$person$Estimate,
    breaks = "FD",
    main = "Person distribution",
    xlab = "Logit scale",
    ylab = "Count",
    col = pal["person_hist"],
    border = "white"
  )

  loc <- plot_data$locations
  xr <- c(0.5, length(plot_data$group_levels) + 0.5)
  yr <- range(c(loc$Estimate, plot_data$person$Estimate), finite = TRUE)
  if (!all(is.finite(yr)) || diff(yr) <= sqrt(.Machine$double.eps)) {
    center <- mean(c(loc$Estimate, plot_data$person$Estimate), na.rm = TRUE)
    yr <- center + c(-0.5, 0.5)
  }
  graphics::par(mar = c(8.8, 5.2, 3.2, 1.2))
  graphics::plot(
    x = loc$X,
    y = loc$Estimate,
    type = "n",
    xlim = xr,
    ylim = yr,
    xaxt = "n",
    xlab = "",
    ylab = "Logit scale",
    main = if (is.null(title)) "Facet and step locations" else as.character(title[1])
  )
  pretty_y <- pretty(yr, n = 6)
  graphics::abline(h = pretty_y, col = pal["grid"], lty = 1)
  x_at <- seq_along(plot_data$group_levels)
  x_lab <- truncate_axis_label(plot_data$group_levels, width = 16L)
  draw_rotated_x_labels(
    at = x_at,
    labels = x_lab,
    srt = label_angle,
    cex = 0.82,
    line_offset = 0.085
  )
  cols <- ifelse(loc$PlotType == "Step threshold", pal["step_threshold"], pal["facet_level"])
  pch <- ifelse(loc$PlotType == "Step threshold", 17, 16)
  if (isTRUE(show_ci) && "SE" %in% names(loc)) {
    z <- stats::qnorm(1 - (1 - ci_level) / 2)
    ci_ok <- is.finite(loc$SE) & loc$SE > 0
    if (any(ci_ok)) {
      ci_lo <- loc$Estimate[ci_ok] - z * loc$SE[ci_ok]
      ci_hi <- loc$Estimate[ci_ok] + z * loc$SE[ci_ok]
      graphics::arrows(
        x0 = loc$X[ci_ok], y0 = ci_lo,
        x1 = loc$X[ci_ok], y1 = ci_hi,
        angle = 90, code = 3, length = 0.04,
        col = grDevices::adjustcolor(cols[ci_ok], alpha.f = 0.6), lwd = 1.2
      )
    }
  }
  graphics::points(loc$X, loc$Estimate, pch = pch, col = cols)
  graphics::legend(
    "topleft",
    legend = c("Facet level", "Step threshold"),
    pch = c(16, 17),
    col = c(pal["facet_level"], pal["step_threshold"]),
    bty = "n",
    cex = 0.9
  )
}

build_pathway_map_data <- function(x, theta_range = c(-6, 6), theta_points = 241L) {
  curve_spec <- build_step_curve_spec(x)
  theta_grid <- seq(theta_range[1], theta_range[2], length.out = theta_points)
  curve_tbl <- build_curve_tables(curve_spec, theta_grid)
  step_df <- curve_spec$step_points |>
    dplyr::mutate(PathY = curve_spec$rating_min + .data$StepIndex - 0.5)
  list(
    title = "Pathway Map (Expected Score by Theta)",
    expected = curve_tbl$expected,
    steps = step_df
  )
}

draw_pathway_map <- function(plot_data, title = NULL, palette = NULL) {
  exp_df <- plot_data$expected
  groups <- unique(exp_df$CurveGroup)
  defaults <- stats::setNames(grDevices::hcl.colors(max(3L, length(groups)), "Dark 3")[seq_along(groups)], groups)
  cols <- resolve_palette(palette = palette, defaults = defaults)
  graphics::plot(
    x = range(exp_df$Theta, finite = TRUE),
    y = range(exp_df$ExpectedScore, finite = TRUE),
    type = "n",
    xlab = "Theta / Logit",
    ylab = "Expected score",
    main = if (is.null(title)) plot_data$title else as.character(title[1])
  )
  for (i in seq_along(groups)) {
    sub <- exp_df[exp_df$CurveGroup == groups[i], , drop = FALSE]
    graphics::lines(sub$Theta, sub$ExpectedScore, col = cols[groups[i]], lwd = 2)
  }
  if (nrow(plot_data$steps) > 0) {
    step_groups <- as.character(plot_data$steps$CurveGroup)
    step_cols <- cols[step_groups]
    graphics::points(plot_data$steps$Threshold, plot_data$steps$PathY, pch = 18, col = step_cols)
  }
  graphics::legend("topleft", legend = groups, col = cols[groups], lty = 1, lwd = 2, bty = "n")
}

build_ccc_data <- function(x, theta_range = c(-6, 6), theta_points = 241L) {
  curve_spec <- build_step_curve_spec(x)
  theta_grid <- seq(theta_range[1], theta_range[2], length.out = theta_points)
  prob_df <- build_curve_tables(curve_spec, theta_grid)$probabilities
  list(
    title = "Category Characteristic Curves",
    probabilities = prob_df
  )
}

draw_ccc <- function(plot_data, title = NULL, palette = NULL) {
  prob_df <- plot_data$probabilities
  traces <- unique(paste(prob_df$CurveGroup, prob_df$Category, sep = " | Cat "))
  defaults <- stats::setNames(grDevices::hcl.colors(max(3L, length(traces)), "Dark 3")[seq_along(traces)], traces)
  cols <- resolve_palette(palette = palette, defaults = defaults)
  graphics::plot(
    x = range(prob_df$Theta, finite = TRUE),
    y = c(0, 1),
    type = "n",
    xlab = "Theta / Logit",
    ylab = "Probability",
    main = if (is.null(title)) plot_data$title else as.character(title[1])
  )
  for (i in seq_along(traces)) {
    parts <- strsplit(traces[i], " \\| Cat ", fixed = FALSE)[[1]]
    sub <- prob_df[prob_df$CurveGroup == parts[1] & prob_df$Category == parts[2], , drop = FALSE]
    graphics::lines(sub$Theta, sub$Probability, col = cols[traces[i]], lwd = 1.5)
  }
}

draw_person_plot <- function(person_tbl, bins, title = "Person measure distribution", palette = NULL) {
  pal <- resolve_palette(palette = palette, defaults = c(person_hist = "#2C7FB8"))
  graphics::hist(
    x = person_tbl$Estimate,
    breaks = bins,
    main = title,
    xlab = "Person estimate",
    ylab = "Count",
    col = pal["person_hist"],
    border = "white"
  )
}

draw_step_plot <- function(step_tbl,
                           title = "Step parameter estimates",
                           palette = NULL,
                           label_angle = 45) {
  pal <- resolve_palette(
    palette = palette,
    defaults = c(
      step_line = "#1B9E77",
      grid = "#ececec"
    )
  )
  x_idx <- step_index_from_label(step_tbl$Step)
  ord <- order(x_idx)
  step_tbl <- step_tbl[ord, , drop = FALSE]
  old_mar <- graphics::par("mar")
  on.exit(graphics::par(mar = old_mar), add = TRUE)
  mar <- old_mar
  mar[1] <- max(mar[1], 8.6)
  graphics::par(mar = mar)
  graphics::plot(
    x = seq_len(nrow(step_tbl)),
    y = step_tbl$Estimate,
    type = "b",
    pch = 16,
    xaxt = "n",
    xlab = "",
    ylab = "Estimate",
    main = title,
    col = pal["step_line"]
  )
  graphics::abline(h = pretty(step_tbl$Estimate, n = 5), col = pal["grid"], lty = 1)
  draw_rotated_x_labels(
    at = seq_len(nrow(step_tbl)),
    labels = truncate_axis_label(step_tbl$Step, width = 16L),
    srt = label_angle,
    cex = 0.84,
    line_offset = 0.085
  )
}

draw_facet_plot <- function(facet_tbl, title, palette = NULL,
                            show_ci = FALSE, ci_level = 0.95) {
  pal <- resolve_palette(palette = palette, defaults = c(facet_bar = "gray70"))
  labels <- paste0(facet_tbl$Facet, ": ", facet_tbl$Level)
  mids <- graphics::barplot(
    height = facet_tbl$Estimate,
    names.arg = labels,
    horiz = TRUE,
    las = 1,
    main = title,
    xlab = "Estimate",
    col = pal["facet_bar"],
    border = "white"
  )
  graphics::abline(v = 0, lty = 2, col = "gray40")
  if (isTRUE(show_ci) && "SE" %in% names(facet_tbl)) {
    z <- stats::qnorm(1 - (1 - ci_level) / 2)
    ci_ok <- is.finite(facet_tbl$SE) & facet_tbl$SE > 0
    if (any(ci_ok)) {
      ci_lo <- facet_tbl$Estimate[ci_ok] - z * facet_tbl$SE[ci_ok]
      ci_hi <- facet_tbl$Estimate[ci_ok] + z * facet_tbl$SE[ci_ok]
      graphics::arrows(
        x0 = ci_lo, y0 = mids[ci_ok],
        x1 = ci_hi, y1 = mids[ci_ok],
        angle = 90, code = 3, length = 0.04,
        col = "gray30", lwd = 1.2
      )
    }
  }
}

new_mfrm_plot_data <- function(name, data) {
  out <- list(name = name, data = data)
  class(out) <- c("mfrm_plot_data", class(out))
  out
}

truncate_axis_label <- function(x, width = 28L) {
  x <- as.character(x)
  width <- max(8L, as.integer(width))
  ifelse(nchar(x) > width, paste0(substr(x, 1, width - 3L), "..."), x)
}

draw_rotated_x_labels <- function(at,
                                  labels,
                                  srt = 45,
                                  cex = 0.85,
                                  line_offset = 0.08) {
  at <- as.numeric(at)
  labels <- as.character(labels)
  ok <- is.finite(at) & nzchar(labels)
  if (!any(ok)) return(invisible(NULL))

  at <- at[ok]
  labels <- labels[ok]
  graphics::axis(side = 1, at = at, labels = FALSE, tck = -0.02)

  usr <- graphics::par("usr")
  y <- usr[3] - line_offset * diff(usr[3:4])
  graphics::text(
    x = at,
    y = y,
    labels = labels,
    srt = srt,
    adj = 1,
    xpd = NA,
    cex = cex
  )
  invisible(NULL)
}

resolve_palette <- function(palette = NULL, defaults = character(0)) {
  defaults <- stats::setNames(as.character(defaults), names(defaults))
  if (length(defaults) == 0) return(defaults)
  if (is.null(palette) || length(palette) == 0) return(defaults)

  palette <- stats::setNames(as.character(palette), names(palette))
  nm <- names(palette)
  if (is.null(nm) || any(!nzchar(nm))) {
    take <- seq_len(min(length(defaults), length(palette)))
    defaults[take] <- palette[take]
    return(defaults)
  }
  hit <- intersect(names(defaults), nm)
  if (length(hit) > 0) defaults[hit] <- palette[hit]
  defaults
}

barplot_rot45 <- function(height,
                          labels,
                          col,
                          border = "white",
                          main = NULL,
                          ylab = NULL,
                          label_angle = 45,
                          label_cex = 0.84,
                          mar_bottom = 8.2,
                          label_width = 22L,
                          add_grid = FALSE,
                          ...) {
  old_mar <- graphics::par("mar")
  on.exit(graphics::par(mar = old_mar), add = TRUE)
  mar <- old_mar
  mar[1] <- max(mar[1], mar_bottom)
  graphics::par(mar = mar)

  mids <- graphics::barplot(
    height = height,
    names.arg = FALSE,
    col = col,
    border = border,
    main = main,
    ylab = ylab,
    ...
  )
  if (isTRUE(add_grid)) {
    ylim <- graphics::par("usr")[3:4]
    graphics::abline(h = pretty(ylim, n = 5), col = "#ececec", lty = 1)
  }
  draw_rotated_x_labels(
    at = mids,
    labels = truncate_axis_label(labels, width = label_width),
    srt = label_angle,
    cex = label_cex,
    line_offset = 0.085
  )
  invisible(mids)
}

stack_fair_raw_tables <- function(raw_by_facet) {
  if (is.null(raw_by_facet) || length(raw_by_facet) == 0) return(data.frame())
  out <- lapply(names(raw_by_facet), function(facet) {
    df <- raw_by_facet[[facet]]
    if (is.null(df) || nrow(df) == 0) return(NULL)
    df <- as.data.frame(df, stringsAsFactors = FALSE)
    df$Facet <- facet
    df
  })
  out <- out[!vapply(out, is.null, logical(1))]
  if (length(out) == 0) data.frame() else dplyr::bind_rows(out)
}

resolve_unexpected_bundle <- function(x,
                                      diagnostics = NULL,
                                      abs_z_min = 2,
                                      prob_max = 0.30,
                                      top_n = 100,
                                      rule = "either") {
  if (inherits(x, "mfrm_fit")) {
    return(unexpected_response_table(
      fit = x,
      diagnostics = diagnostics,
      abs_z_min = abs_z_min,
      prob_max = prob_max,
      top_n = top_n,
      rule = rule
    ))
  }
  if (is.list(x) && all(c("table", "summary", "thresholds") %in% names(x))) {
    return(x)
  }
  stop("`x` must be an mfrm_fit object or output from unexpected_response_table().")
}

resolve_fair_bundle <- function(x,
                                diagnostics = NULL,
                                facets = NULL,
                                totalscore = TRUE,
                                umean = 0,
                                uscale = 1,
                                udecimals = 2,
                                omit_unobserved = FALSE,
                                xtreme = 0) {
  if (inherits(x, "mfrm_fit")) {
    return(fair_average_table(
      fit = x,
      diagnostics = diagnostics,
      facets = facets,
      totalscore = totalscore,
      umean = umean,
      uscale = uscale,
      udecimals = udecimals,
      omit_unobserved = omit_unobserved,
      xtreme = xtreme
    ))
  }
  if (is.list(x) && all(c("raw_by_facet", "by_facet", "stacked") %in% names(x))) {
    return(x)
  }
  stop("`x` must be an mfrm_fit object or output from fair_average_table().")
}

resolve_displacement_bundle <- function(x,
                                        diagnostics = NULL,
                                        facets = NULL,
                                        anchored_only = FALSE,
                                        abs_displacement_warn = 0.5,
                                        abs_t_warn = 2,
                                        top_n = NULL) {
  if (inherits(x, "mfrm_fit")) {
    return(displacement_table(
      fit = x,
      diagnostics = diagnostics,
      facets = facets,
      anchored_only = anchored_only,
      abs_displacement_warn = abs_displacement_warn,
      abs_t_warn = abs_t_warn,
      top_n = top_n
    ))
  }
  if (is.list(x) && all(c("table", "summary", "thresholds") %in% names(x))) {
    return(x)
  }
  stop("`x` must be an mfrm_fit object or output from displacement_table().")
}

resolve_interrater_bundle <- function(x,
                                      diagnostics = NULL,
                                      rater_facet = NULL,
                                      context_facets = NULL,
                                      exact_warn = 0.50,
                                      corr_warn = 0.30,
                                      top_n = NULL) {
  if (inherits(x, "mfrm_fit")) {
    return(interrater_agreement_table(
      fit = x,
      diagnostics = diagnostics,
      rater_facet = rater_facet,
      context_facets = context_facets,
      exact_warn = exact_warn,
      corr_warn = corr_warn,
      top_n = top_n
    ))
  }
  if (is.list(x) && all(c("summary", "pairs", "settings") %in% names(x))) {
    return(x)
  }
  stop("`x` must be an mfrm_fit object or output from interrater_agreement_table().")
}

resolve_facets_chisq_bundle <- function(x,
                                        diagnostics = NULL,
                                        fixed_p_max = 0.05,
                                        random_p_max = 0.05,
                                        top_n = NULL) {
  if (inherits(x, "mfrm_fit")) {
    return(facets_chisq_table(
      fit = x,
      diagnostics = diagnostics,
      fixed_p_max = fixed_p_max,
      random_p_max = random_p_max,
      top_n = top_n
    ))
  }
  if (is.list(x) && all(c("table", "summary", "thresholds") %in% names(x))) {
    return(x)
  }
  stop("`x` must be an mfrm_fit object or output from facets_chisq_table().")
}

#' Plot unexpected responses using base R
#'
#' @param x Output from [fit_mfrm()] or [unexpected_response_table()].
#' @param diagnostics Optional output from [diagnose_mfrm()] when `x` is `mfrm_fit`.
#' @param abs_z_min Absolute standardized-residual cutoff.
#' @param prob_max Maximum observed-category probability cutoff.
#' @param top_n Maximum rows used from the unexpected table.
#' @param rule Flagging rule (`"either"` or `"both"`).
#' @param plot_type `"scatter"` or `"severity"`.
#' @param main Optional custom plot title.
#' @param palette Optional named color overrides (`higher`, `lower`, `bar`).
#' @param label_angle X-axis label angle for `"severity"` bar plot.
#' @param draw If `TRUE`, draw with base graphics.
#'
#' @details
#' This helper visualizes flagged observations from [unexpected_response_table()]:
#' - `"scatter"`: standardized residual vs `-log10(P_obs)`
#' - `"severity"`: ranked severity index bar chart
#'
#' It accepts either a fitted object (builds the unexpected table internally)
#' or an existing unexpected-response bundle.
#'
#' @section Plot types:
#' \describe{
#'   \item{`"scatter"` (default)}{X-axis: standardized residual.
#'     Y-axis: `-log10(P_obs)` (negative log of observed-category
#'     probability).  Points colored by direction (higher/lower than
#'     expected).  Dashed lines mark `abs_z_min` and `prob_max`
#'     thresholds.  Use for global pattern detection.}
#'   \item{`"severity"`}{Ranked bar chart of the composite severity index
#'     for the `top_n` most unexpected responses.  Use for QC triage
#'     and case-level prioritization.}
#' }
#'
#' @section Interpreting output:
#' Scatter plot: farther from zero on x-axis = larger residual mismatch;
#' higher y-axis = lower observed-category probability.
#'
#' Severity plot: focuses on the most extreme observations for targeted
#' case review.
#'
#' @section Typical workflow:
#' 1. Fit model and run [diagnose_mfrm()].
#' 2. Start with `"scatter"` to assess global unexpected pattern.
#' 3. Switch to `"severity"` for case prioritization.
#'
#' @return A plotting-data object of class `mfrm_plot_data`.
#' @seealso [unexpected_response_table()], [plot_fair_average()], [plot_displacement()], [plot_qc_dashboard()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' p <- plot_unexpected(fit, abs_z_min = 1.5, prob_max = 0.4, top_n = 10, draw = FALSE)
#' if (interactive()) {
#'   plot_unexpected(
#'     fit,
#'     abs_z_min = 1.5,
#'     prob_max = 0.4,
#'     top_n = 10,
#'     plot_type = "severity",
#'     main = "Unexpected Response Severity (Customized)",
#'     palette = c(higher = "#d95f02", lower = "#1b9e77", bar = "#2b8cbe"),
#'     label_angle = 45
#'   )
#' }
#' @export
plot_unexpected <- function(x,
                            diagnostics = NULL,
                            abs_z_min = 2,
                            prob_max = 0.30,
                            top_n = 100,
                            rule = c("either", "both"),
                            plot_type = c("scatter", "severity"),
                            main = NULL,
                            palette = NULL,
                            label_angle = 45,
                            draw = TRUE) {
  rule <- match.arg(tolower(rule), c("either", "both"))
  plot_type <- match.arg(tolower(plot_type), c("scatter", "severity"))
  top_n <- max(1L, as.integer(top_n))
  pal <- resolve_palette(
    palette = palette,
    defaults = c(
      higher = "#d95f02",
      lower = "#1b9e77",
      bar = "#1f78b4"
    )
  )

  bundle <- resolve_unexpected_bundle(
    x = x,
    diagnostics = diagnostics,
    abs_z_min = abs_z_min,
    prob_max = prob_max,
    top_n = top_n,
    rule = rule
  )
  tbl <- as.data.frame(bundle$table, stringsAsFactors = FALSE)
  if (nrow(tbl) == 0) {
    stop("No unexpected responses were flagged under the current thresholds.")
  }
  tbl <- tbl[seq_len(min(nrow(tbl), top_n)), , drop = FALSE]

  if (isTRUE(draw)) {
    if (plot_type == "scatter") {
      x_vals <- suppressWarnings(as.numeric(tbl$StdResidual))
      y_vals <- -log10(pmax(suppressWarnings(as.numeric(tbl$ObsProb)), .Machine$double.xmin))
      dirs <- as.character(tbl$Direction)
      cols <- ifelse(dirs == "Higher than expected", pal["higher"], pal["lower"])
      cols[!is.finite(x_vals) | !is.finite(y_vals)] <- "gray60"
      graphics::plot(
        x = x_vals,
        y = y_vals,
        xlab = "Standardized residual",
        ylab = expression(-log[10](P[obs])),
        main = if (is.null(main)) "Unexpected responses" else as.character(main[1]),
        pch = 16,
        col = cols
      )
      graphics::abline(v = c(-abs_z_min, abs_z_min), lty = 2, col = "gray45")
      graphics::abline(h = -log10(prob_max), lty = 2, col = "gray45")
      graphics::legend(
        "topleft",
        legend = c("Higher than expected", "Lower than expected"),
        col = c(pal["higher"], pal["lower"]),
        pch = 16,
        bty = "n",
        cex = 0.85
      )
    } else {
      sev <- suppressWarnings(as.numeric(tbl$Severity))
      ord <- order(sev, decreasing = TRUE, na.last = NA)
      use <- ord[seq_len(min(length(ord), top_n))]
      sev <- sev[use]
      labels <- if ("Row" %in% names(tbl)) {
        paste0("Row ", tbl$Row[use])
      } else {
        paste0("Case ", seq_along(use))
      }
      barplot_rot45(
        height = sev,
        labels = labels,
        col = pal["bar"],
        main = if (is.null(main)) "Unexpected response severity" else as.character(main[1]),
        ylab = "Severity index",
        label_angle = label_angle,
        mar_bottom = 8.2
      )
    }
  }

  out <- new_mfrm_plot_data(
    "unexpected",
    list(
      plot = plot_type,
      table = tbl,
      summary = bundle$summary,
      thresholds = bundle$thresholds
    )
  )
  invisible(out)
}

#' Plot fair-average diagnostics using base R
#'
#' @param x Output from [fit_mfrm()] or [fair_average_table()].
#' @param diagnostics Optional output from [diagnose_mfrm()] when `x` is `mfrm_fit`.
#' @param facet Optional facet name for level-wise lollipop plots.
#' @param metric Fair-average metric (`"FairM"` or `"FairZ"`).
#' @param plot_type `"difference"` or `"scatter"`.
#' @param top_n Maximum levels shown for `"difference"` plot.
#' @param draw If `TRUE`, draw with base graphics.
#' @param ... Additional arguments passed to [fair_average_table()] when `x` is `mfrm_fit`.
#'
#' @details
#' Fair-average plots compare observed scoring tendency against model-based
#' fair metrics.
#'
#' @section Plot types:
#' \describe{
#'   \item{`"difference"` (default)}{Lollipop chart showing the gap between
#'     observed and fair-average score for each element.  X-axis:
#'     Observed - Fair metric.  Y-axis: element labels.  Points colored
#'     teal (lenient, gap >= 0) or orange (severe, gap < 0).  Ordered by
#'     absolute gap.}
#'   \item{`"scatter"`}{Scatter plot of fair metric (x) vs observed average
#'     (y) with an identity line.  Points colored by facet.  Useful for
#'     checking overall alignment between observed and model-adjusted
#'     scores.}
#' }
#'
#' @section Interpreting output:
#' Difference plot: ranked element-level gaps (`Observed - Fair`), useful
#' for triage of potentially lenient/severe levels.
#'
#' Scatter plot: global agreement pattern relative to the identity line.
#'
#' Larger absolute gaps suggest stronger divergence between observed and
#' model-adjusted scoring.
#'
#' @section Typical workflow:
#' 1. Start with `plot_type = "difference"` to find largest discrepancies.
#' 2. Use `plot_type = "scatter"` to check overall alignment pattern.
#' 3. Follow up with facet-level diagnostics for flagged levels.
#'
#' @return A plotting-data object of class `mfrm_plot_data`.
#' @seealso [fair_average_table()], [plot_unexpected()], [plot_displacement()], [plot_qc_dashboard()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' p <- plot_fair_average(fit, metric = "FairM", draw = FALSE)
#' if (interactive()) {
#'   plot_fair_average(fit, metric = "FairM", plot_type = "difference")
#' }
#' @export
plot_fair_average <- function(x,
                              diagnostics = NULL,
                              facet = NULL,
                              metric = c("FairM", "FairZ"),
                              plot_type = c("difference", "scatter"),
                              top_n = 40,
                              draw = TRUE,
                              ...) {
  metric <- match.arg(metric, c("FairM", "FairZ"))
  plot_type <- match.arg(tolower(plot_type), c("difference", "scatter"))
  top_n <- max(1L, as.integer(top_n))

  bundle <- if (inherits(x, "mfrm_fit")) {
    fair_average_table(x, diagnostics = diagnostics, ...)
  } else {
    resolve_fair_bundle(x)
  }

  fair_df <- stack_fair_raw_tables(bundle$raw_by_facet)
  if (nrow(fair_df) == 0) stop("No fair-average data available.")
  needed <- c("Facet", "Level", "ObservedAverage", "FairM", "FairZ")
  if (!all(needed %in% names(fair_df))) {
    stop("Fair-average table does not include required columns.")
  }
  fair_df <- fair_df[is.finite(fair_df$ObservedAverage) & is.finite(fair_df[[metric]]), , drop = FALSE]
  if (nrow(fair_df) == 0) stop("No finite fair-average rows available.")

  if (!is.null(facet)) {
    fair_df <- fair_df[as.character(fair_df$Facet) == as.character(facet[1]), , drop = FALSE]
    if (nrow(fair_df) == 0) stop("Requested `facet` was not found in fair-average output.")
  }
  fair_df$Gap <- fair_df$ObservedAverage - fair_df[[metric]]

  if (isTRUE(draw)) {
    if (plot_type == "difference") {
      ord <- order(abs(fair_df$Gap), decreasing = TRUE, na.last = NA)
      use <- ord[seq_len(min(length(ord), top_n))]
      sub <- fair_df[use, , drop = FALSE]
      y <- seq_len(nrow(sub))
      lbl <- paste0(sub$Facet, ":", sub$Level)
      lbl <- truncate_axis_label(lbl, width = 26L)
      graphics::plot(
        x = sub$Gap,
        y = y,
        type = "n",
        xlab = paste0("Observed - ", metric),
        ylab = "",
        yaxt = "n",
        main = paste0("Fair-average gaps (", metric, ")")
      )
      graphics::segments(x0 = 0, y0 = y, x1 = sub$Gap, y1 = y, col = "gray55")
      cols <- ifelse(sub$Gap >= 0, "#1b9e77", "#d95f02")
      graphics::points(sub$Gap, y, pch = 16, col = cols)
      graphics::axis(side = 2, at = y, labels = lbl, las = 2, cex.axis = 0.75)
      graphics::abline(v = 0, lty = 2, col = "gray40")
    } else {
      fac <- as.character(fair_df$Facet)
      fac_levels <- unique(fac)
      col_idx <- match(fac, fac_levels)
      cols <- grDevices::hcl.colors(length(fac_levels), "Dark 3")[col_idx]
      graphics::plot(
        x = fair_df[[metric]],
        y = fair_df$ObservedAverage,
        xlab = metric,
        ylab = "Observed average",
        main = paste0("Observed vs ", metric),
        pch = 16,
        col = cols
      )
      lims <- range(c(fair_df[[metric]], fair_df$ObservedAverage), finite = TRUE)
      graphics::abline(a = 0, b = 1, lty = 2, col = "gray45")
      graphics::legend("topleft", legend = fac_levels, col = grDevices::hcl.colors(length(fac_levels), "Dark 3"), pch = 16, bty = "n", cex = 0.85)
      graphics::segments(x0 = lims[1], y0 = lims[1], x1 = lims[2], y1 = lims[2], col = "gray70", lty = 3)
    }
  }

  out <- new_mfrm_plot_data(
    "fair_average",
    list(
      plot = plot_type,
      metric = metric,
      data = fair_df,
      settings = bundle$settings
    )
  )
  invisible(out)
}

#' Plot displacement diagnostics using base R
#'
#' @param x Output from [fit_mfrm()] or [displacement_table()].
#' @param diagnostics Optional output from [diagnose_mfrm()] when `x` is `mfrm_fit`.
#' @param anchored_only Keep only anchored/group-anchored levels.
#' @param facets Optional subset of facets.
#' @param plot_type `"lollipop"` or `"hist"`.
#' @param top_n Maximum levels shown in `"lollipop"` mode.
#' @param draw If `TRUE`, draw with base graphics.
#' @param ... Additional arguments passed to [displacement_table()] when `x` is `mfrm_fit`.
#'
#' @details
#' Displacement plots focus on anchor stability and estimate movement.
#'
#' @section Plot types:
#' \describe{
#'   \item{`"lollipop"` (default)}{Dot-and-line chart of displacement values.
#'     X-axis: displacement (logits).  Y-axis: element labels.  Points
#'     colored red when flagged.  Dashed lines at +/- threshold.  Ordered
#'     by absolute displacement.}
#'   \item{`"hist"`}{Histogram of displacement values with Freedman-Diaconis
#'     breaks.  Dashed reference lines at +/- threshold.  Use for
#'     inspecting the overall distribution shape.}
#' }
#'
#' @section Interpreting output:
#' Lollipop: top absolute displacement levels; flagged points indicate
#' larger movement from anchor expectations.
#'
#' Histogram: overall displacement distribution and threshold lines.
#'
#' Use `anchored_only = TRUE` when your main question is anchor robustness.
#'
#' @section Typical workflow:
#' 1. Run with `plot_type = "lollipop"` and `anchored_only = TRUE`.
#' 2. Inspect distribution with `plot_type = "hist"`.
#' 3. Drill into flagged rows via [displacement_table()].
#'
#' @return A plotting-data object of class `mfrm_plot_data`.
#' @seealso [displacement_table()], [plot_unexpected()], [plot_fair_average()], [plot_qc_dashboard()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' p <- plot_displacement(fit, anchored_only = FALSE, draw = FALSE)
#' if (interactive()) {
#'   plot_displacement(fit, anchored_only = FALSE, plot_type = "lollipop")
#' }
#' @export
plot_displacement <- function(x,
                              diagnostics = NULL,
                              anchored_only = FALSE,
                              facets = NULL,
                              plot_type = c("lollipop", "hist"),
                              top_n = 40,
                              draw = TRUE,
                              ...) {
  plot_type <- match.arg(tolower(plot_type), c("lollipop", "hist"))
  top_n <- max(1L, as.integer(top_n))

  bundle <- if (inherits(x, "mfrm_fit")) {
    displacement_table(
      fit = x,
      diagnostics = diagnostics,
      facets = facets,
      anchored_only = anchored_only,
      ...
    )
  } else {
    resolve_displacement_bundle(x)
  }

  tbl <- as.data.frame(bundle$table, stringsAsFactors = FALSE)
  if (nrow(tbl) == 0) stop("No displacement rows available.")
  tbl <- tbl[is.finite(tbl$Displacement), , drop = FALSE]
  if (nrow(tbl) == 0) stop("No finite displacement values available.")

  if (!is.null(facets)) {
    tbl <- tbl[as.character(tbl$Facet) %in% as.character(facets), , drop = FALSE]
  }
  if (isTRUE(anchored_only) && "AnchorType" %in% names(tbl)) {
    tbl <- tbl[tbl$AnchorType %in% c("Anchor", "Group"), , drop = FALSE]
  }
  if (nrow(tbl) == 0) stop("No rows left after filtering.")

  if (isTRUE(draw)) {
    if (plot_type == "lollipop") {
      ord <- order(abs(tbl$Displacement), decreasing = TRUE, na.last = NA)
      use <- ord[seq_len(min(length(ord), top_n))]
      sub <- tbl[use, , drop = FALSE]
      y <- seq_len(nrow(sub))
      lbl <- truncate_axis_label(paste0(sub$Facet, ":", sub$Level), width = 26L)
      cols <- ifelse(isTRUE(sub$Flag), "#d73027", "#1b9e77")
      graphics::plot(
        x = sub$Displacement,
        y = y,
        type = "n",
        xlab = "Displacement (logit)",
        ylab = "",
        yaxt = "n",
        main = "Displacement diagnostics"
      )
      graphics::segments(0, y, sub$Displacement, y, col = "gray60")
      graphics::points(sub$Displacement, y, pch = 16, col = cols)
      graphics::axis(side = 2, at = y, labels = lbl, las = 2, cex.axis = 0.75)
      d_thr <- as.numeric(bundle$thresholds$abs_displacement_warn %||% 0.5)
      graphics::abline(v = c(-d_thr, 0, d_thr), lty = c(2, 1, 2), col = c("gray45", "gray30", "gray45"))
    } else {
      vals <- suppressWarnings(as.numeric(tbl$Displacement))
      graphics::hist(
        x = vals,
        breaks = "FD",
        col = "#9ecae1",
        border = "white",
        main = "Displacement distribution",
        xlab = "Displacement (logit)"
      )
      d_thr <- as.numeric(bundle$thresholds$abs_displacement_warn %||% 0.5)
      graphics::abline(v = c(-d_thr, d_thr), lty = 2, col = "gray45")
    }
  }

  out <- new_mfrm_plot_data(
    "displacement",
    list(
      plot = plot_type,
      table = tbl,
      summary = bundle$summary,
      thresholds = bundle$thresholds
    )
  )
  invisible(out)
}

#' Plot inter-rater agreement diagnostics using base R
#'
#' @param x Output from [fit_mfrm()] or [interrater_agreement_table()].
#' @param diagnostics Optional output from [diagnose_mfrm()] when `x` is `mfrm_fit`.
#' @param rater_facet Name of the rater facet when `x` is `mfrm_fit`.
#' @param context_facets Optional context facets when `x` is `mfrm_fit`.
#' @param exact_warn Warning threshold for exact agreement.
#' @param corr_warn Warning threshold for pairwise correlation.
#' @param plot_type `"exact"`, `"corr"`, or `"difference"`.
#' @param top_n Maximum pairs displayed for bar-style plots.
#' @param main Optional custom plot title.
#' @param palette Optional named color overrides (`ok`, `flag`, `expected`).
#' @param label_angle X-axis label angle for bar-style plots.
#' @param draw If `TRUE`, draw with base graphics.
#'
#' @details
#' Inter-rater agreement plots summarize pairwise consistency for a chosen
#' rater facet under matched contexts.
#'
#' @section Plot types:
#' \describe{
#'   \item{`"exact"` (default)}{Bar chart of exact agreement proportion by
#'     rater pair.  Expected agreement overlaid as connected circles.
#'     Horizontal reference line at `exact_warn`.  Bars colored red when
#'     flagged.}
#'   \item{`"corr"`}{Bar chart of pairwise Pearson correlation by rater
#'     pair.  Reference line at `corr_warn`.  Ordered by correlation
#'     (lowest first).}
#'   \item{`"difference"`}{Scatter plot.  X-axis: mean signed score
#'     difference (Rater1 - Rater2).  Y-axis: mean absolute difference.
#'     Points colored by flag status.  Vertical reference at 0.}
#' }
#'
#' @section Interpreting output:
#' Pairs below `exact_warn` and/or `corr_warn` should be prioritized for
#' calibration review.
#'
#' @section Typical workflow:
#' 1. Select rater facet and run `"exact"` view.
#' 2. Confirm with `"corr"` view.
#' 3. Use `"difference"` to inspect directional disagreement.
#'
#' @return A plotting-data object of class `mfrm_plot_data`.
#' @seealso [interrater_agreement_table()], [plot_facets_chisq()], [plot_qc_dashboard()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' p <- plot_interrater_agreement(fit, rater_facet = "Rater", draw = FALSE)
#' if (interactive()) {
#'   plot_interrater_agreement(
#'     fit,
#'     rater_facet = "Rater",
#'     draw = TRUE,
#'     plot_type = "exact",
#'     main = "Inter-rater Agreement (Customized)",
#'     palette = c(ok = "#2b8cbe", flag = "#cb181d"),
#'     label_angle = 45
#'   )
#' }
#' @export
plot_interrater_agreement <- function(x,
                                      diagnostics = NULL,
                                      rater_facet = NULL,
                                      context_facets = NULL,
                                      exact_warn = 0.50,
                                      corr_warn = 0.30,
                                      plot_type = c("exact", "corr", "difference"),
                                      top_n = 20,
                                      main = NULL,
                                      palette = NULL,
                                      label_angle = 45,
                                      draw = TRUE) {
  plot_type <- match.arg(tolower(plot_type), c("exact", "corr", "difference"))
  top_n <- max(1L, as.integer(top_n))
  pal <- resolve_palette(
    palette = palette,
    defaults = c(
      ok = "#2b8cbe",
      flag = "#cb181d",
      expected = "#08519c"
    )
  )

  bundle <- resolve_interrater_bundle(
    x = x,
    diagnostics = diagnostics,
    rater_facet = rater_facet,
    context_facets = context_facets,
    exact_warn = exact_warn,
    corr_warn = corr_warn,
    top_n = NULL
  )

  tbl <- as.data.frame(bundle$pairs, stringsAsFactors = FALSE)
  if (nrow(tbl) == 0) stop("No inter-rater pair rows are available.")
  if (!all(c("Rater1", "Rater2", "Exact", "Corr", "MeanDiff", "MAD") %in% names(tbl))) {
    stop("Inter-rater table does not include required columns.")
  }

  ord_exact <- order(tbl$Exact, na.last = NA)
  use <- ord_exact[seq_len(min(length(ord_exact), top_n))]
  sub <- tbl[use, , drop = FALSE]
  labels <- truncate_axis_label(paste0(sub$Rater1, " | ", sub$Rater2), width = 28L)
  cols <- if ("Flag" %in% names(sub)) ifelse(sub$Flag, pal["flag"], pal["ok"]) else pal["ok"]

  if (isTRUE(draw)) {
    if (plot_type == "exact") {
      bp <- barplot_rot45(
        height = suppressWarnings(as.numeric(sub$Exact)),
        labels = labels,
        col = cols,
        main = if (is.null(main)) "Inter-rater exact agreement" else as.character(main[1]),
        ylab = "Exact agreement",
        label_angle = label_angle,
        mar_bottom = 8.2
      )
      exp_vals <- suppressWarnings(as.numeric(sub$ExpectedExact))
      if (any(is.finite(exp_vals))) {
        graphics::points(bp, exp_vals, pch = 21, bg = "white", col = pal["expected"])
        graphics::lines(bp, exp_vals, col = pal["expected"], lwd = 1.3)
      }
      graphics::abline(h = exact_warn, lty = 2, col = "gray45")
    } else if (plot_type == "corr") {
      corr_ord <- order(tbl$Corr, na.last = NA)
      use_corr <- corr_ord[seq_len(min(length(corr_ord), top_n))]
      sub_corr <- tbl[use_corr, , drop = FALSE]
      lbl_corr <- truncate_axis_label(paste0(sub_corr$Rater1, " | ", sub_corr$Rater2), width = 28L)
      col_corr <- if ("Flag" %in% names(sub_corr)) ifelse(sub_corr$Flag, pal["flag"], pal["ok"]) else pal["ok"]
      barplot_rot45(
        height = suppressWarnings(as.numeric(sub_corr$Corr)),
        labels = lbl_corr,
        col = col_corr,
        main = if (is.null(main)) "Inter-rater correlation" else as.character(main[1]),
        ylab = "Correlation",
        label_angle = label_angle,
        mar_bottom = 8.2
      )
      graphics::abline(h = corr_warn, lty = 2, col = "gray45")
    } else {
      graphics::plot(
        x = suppressWarnings(as.numeric(tbl$MeanDiff)),
        y = suppressWarnings(as.numeric(tbl$MAD)),
        pch = 16,
        col = if ("Flag" %in% names(tbl)) ifelse(tbl$Flag, pal["flag"], pal["ok"]) else pal["ok"],
        xlab = "Mean score difference (Rater1 - Rater2)",
        ylab = "Mean absolute difference",
        main = if (is.null(main)) "Inter-rater difference profile" else as.character(main[1])
      )
      graphics::abline(v = 0, lty = 2, col = "gray45")
    }
  }

  out <- new_mfrm_plot_data(
    "interrater",
    list(
      plot = plot_type,
      pairs = tbl,
      summary = bundle$summary,
      settings = bundle$settings
    )
  )
  invisible(out)
}

#' Plot FACETS-style facet chi-square diagnostics using base R
#'
#' @param x Output from [fit_mfrm()] or [facets_chisq_table()].
#' @param diagnostics Optional output from [diagnose_mfrm()] when `x` is `mfrm_fit`.
#' @param fixed_p_max Warning cutoff for fixed-effect chi-square p-values.
#' @param random_p_max Warning cutoff for random-effect chi-square p-values.
#' @param plot_type `"fixed"`, `"random"`, or `"variance"`.
#' @param main Optional custom plot title.
#' @param palette Optional named color overrides (`fixed_ok`, `fixed_flag`,
#' `random_ok`, `random_flag`, `variance`).
#' @param label_angle X-axis label angle for bar-style plots.
#' @param draw If `TRUE`, draw with base graphics.
#'
#' @details
#' Facet chi-square plots provide facet-level global fit diagnostics using
#' fixed/random chi-square summaries and random-variance magnitudes.
#'
#' @section Plot types:
#' \describe{
#'   \item{`"fixed"` (default)}{Bar chart of fixed-effect chi-square by
#'     facet.  Bars colored red when the null hypothesis (all elements
#'     equal) is rejected at `fixed_p_max`.}
#'   \item{`"random"`}{Bar chart of random-effect chi-square by facet.
#'     Bars colored red when rejected at `random_p_max`.}
#'   \item{`"variance"`}{Bar chart of estimated random variance by facet.
#'     Reference line at 0.  Larger variance indicates greater
#'     heterogeneity among elements.}
#' }
#'
#' @section Interpreting output:
#' Colored flags reflect configured p-value thresholds (`fixed_p_max`,
#' `random_p_max`) when available.
#'
#' @section Typical workflow:
#' 1. Review `"fixed"` and `"random"` panels for flagged facets.
#' 2. Check `"variance"` to contextualize heterogeneity.
#' 3. Cross-check with inter-rater and element-level fit diagnostics.
#'
#' @return A plotting-data object of class `mfrm_plot_data`.
#' @seealso [facets_chisq_table()], [plot_interrater_agreement()], [plot_qc_dashboard()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' p <- plot_facets_chisq(fit, draw = FALSE)
#' if (interactive()) {
#'   plot_facets_chisq(
#'     fit,
#'     draw = TRUE,
#'     plot_type = "fixed",
#'     main = "Facet Chi-square (Customized)",
#'     palette = c(fixed_ok = "#2b8cbe", fixed_flag = "#cb181d"),
#'     label_angle = 45
#'   )
#' }
#' @export
plot_facets_chisq <- function(x,
                              diagnostics = NULL,
                              fixed_p_max = 0.05,
                              random_p_max = 0.05,
                              plot_type = c("fixed", "random", "variance"),
                              main = NULL,
                              palette = NULL,
                              label_angle = 45,
                              draw = TRUE) {
  plot_type <- match.arg(tolower(plot_type), c("fixed", "random", "variance"))
  pal <- resolve_palette(
    palette = palette,
    defaults = c(
      fixed_ok = "#2b8cbe",
      fixed_flag = "#cb181d",
      random_ok = "#31a354",
      random_flag = "#cb181d",
      variance = "#9ecae1"
    )
  )
  bundle <- resolve_facets_chisq_bundle(
    x = x,
    diagnostics = diagnostics,
    fixed_p_max = fixed_p_max,
    random_p_max = random_p_max
  )

  tbl <- as.data.frame(bundle$table, stringsAsFactors = FALSE)
  if (nrow(tbl) == 0) stop("No facet chi-square rows are available.")
  if (!all(c("Facet", "FixedChiSq", "RandomChiSq", "RandomVar") %in% names(tbl))) {
    stop("Facet chi-square table does not include required columns.")
  }

  if (isTRUE(draw)) {
    facet_labels <- truncate_axis_label(as.character(tbl$Facet), width = 20L)
    if (plot_type == "fixed") {
      ord <- order(tbl$FixedChiSq, decreasing = TRUE, na.last = NA)
      sub <- tbl[ord, , drop = FALSE]
      col_fixed <- if ("FixedFlag" %in% names(sub)) ifelse(sub$FixedFlag, pal["fixed_flag"], pal["fixed_ok"]) else pal["fixed_ok"]
      barplot_rot45(
        height = suppressWarnings(as.numeric(sub$FixedChiSq)),
        labels = truncate_axis_label(as.character(sub$Facet), width = 20L),
        col = col_fixed,
        main = if (is.null(main)) "Facet fixed-effect chi-square" else as.character(main[1]),
        ylab = expression(chi^2),
        label_angle = label_angle,
        mar_bottom = 8.2
      )
    } else if (plot_type == "random") {
      ord <- order(tbl$RandomChiSq, decreasing = TRUE, na.last = NA)
      sub <- tbl[ord, , drop = FALSE]
      col_random <- if ("RandomFlag" %in% names(sub)) ifelse(sub$RandomFlag, pal["random_flag"], pal["random_ok"]) else pal["random_ok"]
      barplot_rot45(
        height = suppressWarnings(as.numeric(sub$RandomChiSq)),
        labels = truncate_axis_label(as.character(sub$Facet), width = 20L),
        col = col_random,
        main = if (is.null(main)) "Facet random-effect chi-square" else as.character(main[1]),
        ylab = expression(chi^2),
        label_angle = label_angle,
        mar_bottom = 8.2
      )
    } else {
      vals <- suppressWarnings(as.numeric(tbl$RandomVar))
      barplot_rot45(
        height = vals,
        labels = facet_labels,
        col = pal["variance"],
        main = if (is.null(main)) "Facet random variance" else as.character(main[1]),
        ylab = "Variance",
        label_angle = label_angle,
        mar_bottom = 8.2
      )
      graphics::abline(h = 0, lty = 2, col = "gray45")
    }
  }

  out <- new_mfrm_plot_data(
    "facets_chisq",
    list(
      plot = plot_type,
      table = tbl,
      summary = bundle$summary,
      thresholds = bundle$thresholds
    )
  )
  invisible(out)
}

#' Plot a base-R QC dashboard
#'
#' @param fit Output from [fit_mfrm()].
#' @param diagnostics Optional output from [diagnose_mfrm()].
#' @param threshold_profile Threshold profile name (`strict`, `standard`, `lenient`).
#' @param thresholds Optional named threshold overrides.
#' @param abs_z_min Absolute standardized-residual cutoff for unexpected panel.
#' @param prob_max Maximum observed-category probability cutoff for unexpected panel.
#' @param rater_facet Optional rater facet used in inter-rater panel.
#' @param interrater_exact_warn Warning threshold for inter-rater exact agreement.
#' @param interrater_corr_warn Warning threshold for inter-rater correlation.
#' @param fixed_p_max Warning cutoff for fixed-effect facet chi-square p-values.
#' @param random_p_max Warning cutoff for random-effect facet chi-square p-values.
#' @param top_n Maximum elements displayed in displacement panel.
#' @param draw If `TRUE`, draw with base graphics.
#'
#' @details
#' The dashboard draws nine QC panels:
#' - observed vs expected category counts
#' - infit vs outfit scatter
#' - |ZSTD| histogram
#' - unexpected-response scatter
#' - fair-average gap by facet
#' - displacement lollipop (largest absolute values)
#' - inter-rater exact agreement by pair
#' - facet fixed-effect chi-square by facet
#' - separation reliability by facet
#'
#' `threshold_profile` controls warning overlays used in applicable panels.
#' Use `thresholds` to override any profile value with named entries.
#'
#' @section Plot types:
#' This function draws a fixed 3x3 panel grid (no `plot_type` argument).
#' For individual panel control, use the dedicated helpers:
#' [plot_unexpected()], [plot_fair_average()], [plot_displacement()],
#' [plot_interrater_agreement()], [plot_facets_chisq()].
#'
#' @section Interpreting output:
#' Recommended panel order for fast review:
#' 1. category counts and infit/outfit scatter (global health)
#' 2. unexpected responses and displacement (element-level outliers)
#' 3. inter-rater and facet chi-square panels (facet-level comparability)
#' 4. reliability panel (precision/separation context)
#'
#' Treat this dashboard as a screening layer; follow up with dedicated helpers
#' (`plot_unexpected()`, `plot_displacement()`, `plot_interrater_agreement()`,
#' `plot_facets_chisq()`) for detailed diagnosis.
#'
#' @section Typical workflow:
#' 1. Fit and diagnose model.
#' 2. Run `plot_qc_dashboard()` for one-page triage.
#' 3. Drill into flagged panels using dedicated functions.
#'
#' @return A plotting-data object of class `mfrm_plot_data`.
#' @seealso [plot_unexpected()], [plot_fair_average()], [plot_displacement()], [plot_interrater_agreement()], [plot_facets_chisq()], [build_visual_summaries()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' qc <- plot_qc_dashboard(fit, draw = FALSE)
#' if (interactive()) {
#'   plot_qc_dashboard(fit, rater_facet = "Rater")
#' }
#' @export
plot_qc_dashboard <- function(fit,
                              diagnostics = NULL,
                              threshold_profile = "standard",
                              thresholds = NULL,
                              abs_z_min = 2,
                              prob_max = 0.30,
                              rater_facet = NULL,
                              interrater_exact_warn = 0.50,
                              interrater_corr_warn = 0.30,
                              fixed_p_max = 0.05,
                              random_p_max = 0.05,
                              top_n = 20,
                              draw = TRUE) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().")
  }
  top_n <- max(5L, as.integer(top_n))
  if (is.null(diagnostics)) {
    diagnostics <- diagnose_mfrm(fit, residual_pca = "none")
  }
  if (is.null(diagnostics$obs) || nrow(diagnostics$obs) == 0) {
    stop("`diagnostics$obs` is empty. Run diagnose_mfrm() first.")
  }

  resolved <- resolve_warning_thresholds(thresholds = thresholds, threshold_profile = threshold_profile)
  cat_tbl <- calc_category_stats(diagnostics$obs, res = fit, whexact = FALSE)
  fit_tbl <- as.data.frame(diagnostics$fit, stringsAsFactors = FALSE)
  zstd <- if (nrow(fit_tbl) > 0) {
    pmax(abs(suppressWarnings(as.numeric(fit_tbl$InfitZSTD))), abs(suppressWarnings(as.numeric(fit_tbl$OutfitZSTD))), na.rm = TRUE)
  } else {
    numeric(0)
  }
  zstd <- zstd[is.finite(zstd)]

  unexpected <- unexpected_response_table(
    fit = fit,
    diagnostics = diagnostics,
    abs_z_min = abs_z_min,
    prob_max = prob_max,
    top_n = max(top_n, 20),
    rule = "either"
  )
  fair <- fair_average_table(fit = fit, diagnostics = diagnostics)
  fair_df <- stack_fair_raw_tables(fair$raw_by_facet)
  fair_gap <- if (nrow(fair_df) > 0 && all(c("ObservedAverage", "FairM") %in% names(fair_df))) {
    fair_df$ObservedAverage - fair_df$FairM
  } else {
    numeric(0)
  }
  disp <- displacement_table(
    fit = fit,
    diagnostics = diagnostics,
    anchored_only = FALSE
  )
  disp_tbl <- as.data.frame(disp$table, stringsAsFactors = FALSE)
  interrater <- interrater_agreement_table(
    fit = fit,
    diagnostics = diagnostics,
    rater_facet = rater_facet,
    exact_warn = interrater_exact_warn,
    corr_warn = interrater_corr_warn,
    top_n = max(top_n, 20)
  )
  inter_tbl <- as.data.frame(interrater$pairs, stringsAsFactors = FALSE)
  fchi <- facets_chisq_table(
    fit = fit,
    diagnostics = diagnostics,
    fixed_p_max = fixed_p_max,
    random_p_max = random_p_max
  )
  fchi_tbl <- as.data.frame(fchi$table, stringsAsFactors = FALSE)
  rel_tbl <- as.data.frame(diagnostics$reliability, stringsAsFactors = FALSE)

  if (isTRUE(draw)) {
    old_par <- graphics::par(no.readonly = TRUE)
    on.exit(graphics::par(old_par), add = TRUE)
    graphics::par(mfrow = c(3, 3), mar = c(4, 4, 3, 1))

    # 1) Category counts
    if (nrow(cat_tbl) > 0) {
      cat_lbl <- as.character(cat_tbl$Category)
      obs_ct <- suppressWarnings(as.numeric(cat_tbl$Count))
      exp_ct <- suppressWarnings(as.numeric(cat_tbl$ExpectedCount))
      bp <- barplot_rot45(
        height = obs_ct,
        labels = cat_lbl,
        col = "#9ecae1",
        main = "QC: Category counts",
        ylab = "Count",
        label_angle = 45,
        mar_bottom = 6.4,
        label_cex = 0.72,
        label_width = 14L
      )
      if (all(is.finite(exp_ct))) {
        graphics::points(bp, exp_ct, pch = 21, bg = "white", col = "#08519c")
        graphics::lines(bp, exp_ct, col = "#08519c", lwd = 1.5)
      }
    } else {
      graphics::plot.new()
      graphics::title(main = "QC: Category counts")
      graphics::text(0.5, 0.5, "No data")
    }

    # 2) Infit/Outfit scatter
    if (nrow(fit_tbl) > 0) {
      infit <- suppressWarnings(as.numeric(fit_tbl$Infit))
      outfit <- suppressWarnings(as.numeric(fit_tbl$Outfit))
      ok <- is.finite(infit) & is.finite(outfit)
      graphics::plot(
        x = infit[ok],
        y = outfit[ok],
        pch = 16,
        col = "#2c7fb8",
        xlab = "Infit MnSq",
        ylab = "Outfit MnSq",
        main = "QC: Infit vs Outfit"
      )
      graphics::abline(v = c(0.5, 1, 1.5), h = c(0.5, 1, 1.5), lty = c(2, 1, 2), col = "gray50")
    } else {
      graphics::plot.new()
      graphics::title(main = "QC: Infit vs Outfit")
      graphics::text(0.5, 0.5, "No data")
    }

    # 3) |ZSTD| histogram
    if (length(zstd) > 0) {
      graphics::hist(
        x = zstd,
        breaks = "FD",
        col = "#c7e9c0",
        border = "white",
        main = "QC: |ZSTD| distribution",
        xlab = "|ZSTD|"
      )
      graphics::abline(v = c(2, 3), lty = 2, col = "gray45")
    } else {
      graphics::plot.new()
      graphics::title(main = "QC: |ZSTD| distribution")
      graphics::text(0.5, 0.5, "No data")
    }

    # 4) Unexpected response scatter
    if (nrow(unexpected$table) > 0) {
      ut <- unexpected$table
      x_u <- suppressWarnings(as.numeric(ut$StdResidual))
      y_u <- -log10(pmax(suppressWarnings(as.numeric(ut$ObsProb)), .Machine$double.xmin))
      graphics::plot(
        x = x_u,
        y = y_u,
        pch = 16,
        col = "#756bb1",
        xlab = "Std residual",
        ylab = expression(-log[10](P[obs])),
        main = "QC: Unexpected responses"
      )
      graphics::abline(v = c(-abs_z_min, abs_z_min), h = -log10(prob_max), lty = 2, col = "gray45")
    } else {
      graphics::plot.new()
      graphics::title(main = "QC: Unexpected responses")
      graphics::text(0.5, 0.5, "No flagged rows")
    }

    # 5) Fair-average gap
    if (length(fair_gap) > 0) {
      fac <- as.character(fair_df$Facet)
      split_gap <- split(fair_gap, fac)
      old_mar <- graphics::par("mar")
      mar <- old_mar
      mar[1] <- max(mar[1], 6.4)
      graphics::par(mar = mar)
      graphics::boxplot(
        split_gap,
        xaxt = "n",
        col = "#fdd0a2",
        main = "QC: Observed - Fair(M)",
        ylab = "Gap"
      )
      draw_rotated_x_labels(
        at = seq_along(split_gap),
        labels = truncate_axis_label(names(split_gap), width = 14L),
        srt = 45,
        cex = 0.72,
        line_offset = 0.085
      )
      graphics::mtext("Facet", side = 1, line = 4.8, cex = 0.82)
      graphics::par(mar = old_mar)
      graphics::abline(h = 0, lty = 2, col = "gray45")
    } else {
      graphics::plot.new()
      graphics::title(main = "QC: Observed - Fair(M)")
      graphics::text(0.5, 0.5, "No data")
    }

    # 6) Displacement lollipop
    if (nrow(disp_tbl) > 0 && all(c("Facet", "Level", "Displacement") %in% names(disp_tbl))) {
      ord <- order(abs(suppressWarnings(as.numeric(disp_tbl$Displacement))), decreasing = TRUE, na.last = NA)
      use <- ord[seq_len(min(length(ord), top_n))]
      sub <- disp_tbl[use, , drop = FALSE]
      y <- seq_len(nrow(sub))
      lbl <- truncate_axis_label(paste0(sub$Facet, ":", sub$Level), width = 24L)
      disp_vals <- suppressWarnings(as.numeric(sub$Displacement))
      cols <- if ("Flag" %in% names(sub)) ifelse(as.logical(sub$Flag), "#cb181d", "#238b45") else "#238b45"
      graphics::plot(
        x = disp_vals,
        y = y,
        type = "n",
        xlab = "Displacement",
        ylab = "",
        yaxt = "n",
        main = "QC: Displacement"
      )
      graphics::segments(0, y, disp_vals, y, col = "gray60")
      graphics::points(disp_vals, y, pch = 16, col = cols)
      graphics::axis(side = 2, at = y, labels = lbl, las = 2, cex.axis = 0.7)
      d_thr <- as.numeric(disp$thresholds$abs_displacement_warn %||% 0.5)
      graphics::abline(v = c(-d_thr, 0, d_thr), lty = c(2, 1, 2), col = c("gray45", "gray30", "gray45"))
    } else {
      graphics::plot.new()
      graphics::title(main = "QC: Displacement")
      graphics::text(0.5, 0.5, "No data")
    }

    # 7) Inter-rater exact agreement
    if (nrow(inter_tbl) > 0 && all(c("Rater1", "Rater2", "Exact") %in% names(inter_tbl))) {
      ord <- order(suppressWarnings(as.numeric(inter_tbl$Exact)), na.last = NA)
      use <- ord[seq_len(min(length(ord), top_n))]
      sub <- inter_tbl[use, , drop = FALSE]
      pair_lbl <- truncate_axis_label(paste0(sub$Rater1, " | ", sub$Rater2), width = 20L)
      cols <- if ("Flag" %in% names(sub)) ifelse(as.logical(sub$Flag), "#cb181d", "#2b8cbe") else "#2b8cbe"
      bp <- barplot_rot45(
        height = suppressWarnings(as.numeric(sub$Exact)),
        labels = pair_lbl,
        col = cols,
        main = "QC: Inter-rater exact",
        ylab = "Exact agreement",
        label_angle = 45,
        mar_bottom = 6.4,
        label_cex = 0.72,
        label_width = 14L
      )
      exp_vals <- suppressWarnings(as.numeric(sub$ExpectedExact))
      if (any(is.finite(exp_vals))) {
        graphics::points(bp, exp_vals, pch = 21, bg = "white", col = "#08519c")
        graphics::lines(bp, exp_vals, col = "#08519c", lwd = 1.3)
      }
      graphics::abline(h = interrater_exact_warn, lty = 2, col = "gray45")
    } else {
      graphics::plot.new()
      graphics::title(main = "QC: Inter-rater exact")
      graphics::text(0.5, 0.5, "No data")
    }

    # 8) Facet fixed-effect chi-square
    if (nrow(fchi_tbl) > 0 && all(c("Facet", "FixedChiSq") %in% names(fchi_tbl))) {
      ord <- order(suppressWarnings(as.numeric(fchi_tbl$FixedChiSq)), decreasing = TRUE, na.last = NA)
      sub <- fchi_tbl[ord, , drop = FALSE]
      labels <- truncate_axis_label(as.character(sub$Facet), width = 20L)
      cols <- if ("FixedFlag" %in% names(sub)) ifelse(as.logical(sub$FixedFlag), "#cb181d", "#31a354") else "#31a354"
      barplot_rot45(
        height = suppressWarnings(as.numeric(sub$FixedChiSq)),
        labels = labels,
        col = cols,
        main = "QC: Facet fixed chi-square",
        ylab = expression(chi^2),
        label_angle = 45,
        mar_bottom = 6.4,
        label_cex = 0.72,
        label_width = 14L
      )
    } else {
      graphics::plot.new()
      graphics::title(main = "QC: Facet fixed chi-square")
      graphics::text(0.5, 0.5, "No data")
    }

    # 9) Separation reliability
    if (nrow(rel_tbl) > 0 && all(c("Facet", "Separation") %in% names(rel_tbl))) {
      ord <- order(suppressWarnings(as.numeric(rel_tbl$Separation)), decreasing = TRUE, na.last = NA)
      sub <- rel_tbl[ord, , drop = FALSE]
      barplot_rot45(
        height = suppressWarnings(as.numeric(sub$Separation)),
        labels = truncate_axis_label(as.character(sub$Facet), width = 20L),
        col = "#9e9ac8",
        main = "QC: Separation by facet",
        ylab = "Separation",
        label_angle = 45,
        mar_bottom = 6.4,
        label_cex = 0.72,
        label_width = 14L
      )
      graphics::abline(h = 1, lty = 2, col = "gray45")
    } else {
      graphics::plot.new()
      graphics::title(main = "QC: Separation by facet")
      graphics::text(0.5, 0.5, "No data")
    }
  }

  out <- new_mfrm_plot_data(
    "qc_dashboard",
    list(
      threshold_profile = resolved$profile_name,
      thresholds = resolved$thresholds,
      category_stats = cat_tbl,
      fit = fit_tbl,
      zstd = zstd,
      unexpected = unexpected,
      fair_average = fair,
      displacement = disp,
      interrater = interrater,
      facets_chisq = fchi,
      reliability = rel_tbl
    )
  )
  invisible(out)
}

#' Plot an `mfrm_fit` object
#'
#' @param x Output from [fit_mfrm()].
#' @param type Plot type.
#' If omitted (`NULL`), returns a bundle with Wright map, Pathway map,
#' and category characteristic curves.
#' Single-plot options are `"facet"`, `"person"`, `"step"`, `"wright"`,
#' `"pathway"`, and `"ccc"`.
#' @param facet Optional facet name when `type = "facet"`.
#' @param top_n Maximum number of facet levels shown for `type = "facet"`.
#' @param theta_range Theta/logit plotting range for pathway and CCC plots.
#' @param theta_points Number of grid points for pathway and CCC curves.
#' @param title Optional custom title for the selected plot.
#' @param palette Optional named color overrides.
#' Supported names include `facet_level`, `step_threshold`, `person_hist`,
#' `step_line`, `facet_bar`, and `grid`.
#' @param label_angle X-axis label angle for categorical axes.
#' @param show_ci If `TRUE`, draws confidence-interval whiskers on
#'   Wright map facet/step locations and facet bar plots.
#'   Requires SE information computed from the observation table.
#' @param ci_level Confidence level for whiskers (default 0.95).
#' @param draw If `TRUE`, draws with base graphics.
#' @param ... Reserved for generic compatibility.
#'
#' @details
#' `plot(fit)` returns a named list with three plotting-data objects:
#' - `wright_map`
#' - `pathway_map`
#' - `category_characteristic_curves`
#'
#' Palette behavior:
#' - For `"wright"`/bundle Wright panel, use named keys such as
#'   `facet_level`, `step_threshold`, `person_hist`, `grid`.
#' - For `"step"`, use `step_line` (and optionally `grid`).
#' - For `"person"`, use `person_hist`.
#' - For `"pathway"` and `"ccc"`, unnamed or named vectors are matched to
#'   detected curve groups in plotting order.
#'
#' If `draw = TRUE`, base R graphics are produced.
#'
#' @section Interpreting output:
#' - bundle mode (`type = NULL`) returns all three core plotting payloads.
#' - single mode (`type = "facet"`, `"person"`, `"step"`, `"wright"`,
#'   `"pathway"`, `"ccc"`) returns one plotting payload.
#'
#' @section Typical workflow:
#' 1. Run `plot(fit, draw = FALSE)` to collect reusable plot data.
#' 2. Switch to one panel with `type = ...` for focused review.
#' 3. Set `draw = TRUE` with palette options for direct base-R rendering.
#'
#' @return
#' If `type` is `NULL`, a named list (`mfrm_plot_bundle`) containing plotting data.
#' Otherwise, a single plotting-data object (`mfrm_plot_data`).
#' @seealso [fit_mfrm()], [summary.mfrm_fit()], [plot_residual_pca()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' maps <- plot(fit, draw = FALSE)
#' p1 <- plot(fit, type = "wright", draw = FALSE)
#' p2 <- plot(fit, type = "pathway", draw = FALSE)
#' p3 <- plot(fit, type = "ccc", draw = FALSE)
#' if (interactive()) {
#'   plot(
#'     fit,
#'     type = "wright",
#'     title = "Customized Wright Map",
#'     palette = c(facet_level = "#1f78b4", step_threshold = "#d95f02"),
#'     label_angle = 45
#'   )
#'   plot(
#'     fit,
#'     type = "step",
#'     title = "Customized Step Parameters",
#'     palette = c(step_line = "#008b8b"),
#'     label_angle = 45
#'   )
#'   plot(
#'     fit,
#'     type = "pathway",
#'     title = "Customized Pathway Map",
#'     palette = c("#1f78b4")
#'   )
#'   plot(
#'     fit,
#'     type = "ccc",
#'     title = "Customized Category Characteristic Curves",
#'     palette = c("#1b9e77", "#d95f02", "#7570b3")
#'   )
#' }
#' @export
plot.mfrm_fit <- function(x,
                          type = NULL,
                          facet = NULL,
                          top_n = 30,
                          theta_range = c(-6, 6),
                          theta_points = 241,
                          title = NULL,
                          palette = NULL,
                          label_angle = 45,
                          show_ci = FALSE,
                          ci_level = 0.95,
                          draw = TRUE,
                          ...) {
  if (!inherits(x, "mfrm_fit")) {
    stop("`x` must be an mfrm_fit object from fit_mfrm().")
  }
  top_n <- max(1L, as.integer(top_n))
  theta_points <- max(51L, as.integer(theta_points))
  theta_range <- as.numeric(theta_range)
  if (length(theta_range) != 2 || !all(is.finite(theta_range)) || theta_range[1] >= theta_range[2]) {
    stop("`theta_range` must be a numeric length-2 vector with increasing values.")
  }

  as_plot_data <- function(name, data) {
    out <- list(name = name, data = data)
    class(out) <- c("mfrm_plot_data", class(out))
    out
  }

  se_tbl_ci <- if (isTRUE(show_ci)) compute_se_for_plot(x, ci_level = ci_level) else NULL

  default_bundle <- missing(type) || is.null(type)
  if (default_bundle || tolower(as.character(type[1])) %in% c("bundle", "all", "default")) {
    out <- list(
      wright_map = as_plot_data("wright_map", build_wright_map_data(x, top_n = top_n, se_tbl = se_tbl_ci)),
      pathway_map = as_plot_data("pathway_map", build_pathway_map_data(x, theta_range = theta_range, theta_points = theta_points)),
      category_characteristic_curves = as_plot_data("category_characteristic_curves", build_ccc_data(x, theta_range = theta_range, theta_points = theta_points))
    )
    class(out) <- c("mfrm_plot_bundle", class(out))
    if (isTRUE(draw)) {
      draw_wright_map(out$wright_map$data, title = title, palette = palette, label_angle = label_angle,
                      show_ci = show_ci, ci_level = ci_level)
      draw_pathway_map(out$pathway_map$data, title = title, palette = palette)
      draw_ccc(out$category_characteristic_curves$data, title = title, palette = palette)
    }
    return(invisible(out))
  }

  type <- match.arg(tolower(as.character(type[1])), c("facet", "person", "step", "wright", "pathway", "ccc"))

  if (type == "wright") {
    out <- as_plot_data("wright_map", build_wright_map_data(x, top_n = top_n, se_tbl = se_tbl_ci))
    if (isTRUE(draw)) draw_wright_map(out$data, title = title, palette = palette, label_angle = label_angle,
                                       show_ci = show_ci, ci_level = ci_level)
    return(invisible(out))
  }
  if (type == "pathway") {
    out <- as_plot_data("pathway_map", build_pathway_map_data(x, theta_range = theta_range, theta_points = theta_points))
    if (isTRUE(draw)) draw_pathway_map(out$data, title = title, palette = palette)
    return(invisible(out))
  }
  if (type == "ccc") {
    out <- as_plot_data("category_characteristic_curves", build_ccc_data(x, theta_range = theta_range, theta_points = theta_points))
    if (isTRUE(draw)) draw_ccc(out$data, title = title, palette = palette)
    return(invisible(out))
  }
  if (type == "person") {
    person_tbl <- tibble::as_tibble(x$facets$person)
    person_tbl <- person_tbl[is.finite(person_tbl$Estimate), , drop = FALSE]
    if (nrow(person_tbl) == 0) stop("No finite person estimates available for plotting.")
    bins <- max(10L, min(35L, as.integer(round(sqrt(nrow(person_tbl))))))
    this_title <- if (is.null(title)) "Person measure distribution" else as.character(title[1])
    out <- as_plot_data("person", list(person = person_tbl, bins = bins, title = this_title))
    if (isTRUE(draw)) draw_person_plot(person_tbl, bins = bins, title = this_title, palette = palette)
    return(invisible(out))
  }
  if (type == "step") {
    step_tbl <- tibble::as_tibble(x$steps)
    if (nrow(step_tbl) == 0 || !all(c("Step", "Estimate") %in% names(step_tbl))) {
      stop("Step estimates are not available in this fit object.")
    }
    this_title <- if (is.null(title)) "Step parameter estimates" else as.character(title[1])
    out <- as_plot_data("step", list(steps = step_tbl, title = this_title))
    if (isTRUE(draw)) draw_step_plot(step_tbl, title = this_title, palette = palette, label_angle = label_angle)
    return(invisible(out))
  }

  facet_tbl <- tibble::as_tibble(x$facets$others)
  if (nrow(facet_tbl) == 0 || !all(c("Facet", "Level", "Estimate") %in% names(facet_tbl))) {
    stop("Facet-level estimates are not available in this fit object.")
  }
  if (!is.null(facet)) {
    facet_tbl <- dplyr::filter(facet_tbl, .data$Facet == as.character(facet[1]))
    if (nrow(facet_tbl) == 0) stop("Requested `facet` not found in facet-level estimates.")
  }
  if (isTRUE(show_ci) && !is.null(se_tbl_ci) && is.data.frame(se_tbl_ci) &&
      nrow(se_tbl_ci) > 0 && all(c("Facet", "Level", "SE") %in% names(se_tbl_ci))) {
    se_join <- se_tbl_ci[, intersect(c("Facet", "Level", "SE"), names(se_tbl_ci)), drop = FALSE]
    se_join$Level <- as.character(se_join$Level)
    facet_tbl$Level <- as.character(facet_tbl$Level)
    facet_tbl <- merge(facet_tbl, se_join, by = c("Facet", "Level"), all.x = TRUE, sort = FALSE)
    facet_tbl <- tibble::as_tibble(facet_tbl)
  }
  facet_tbl <- dplyr::arrange(facet_tbl, .data$Estimate)
  if (nrow(facet_tbl) > top_n) {
    facet_tbl <- facet_tbl |>
      dplyr::mutate(AbsEstimate = abs(.data$Estimate)) |>
      dplyr::arrange(dplyr::desc(.data$AbsEstimate)) |>
      dplyr::slice_head(n = top_n) |>
      dplyr::arrange(.data$Estimate) |>
      dplyr::select(-.data$AbsEstimate)
  }
  facet_title <- if (is.null(facet)) "Facet-level estimates" else paste0("Facet-level estimates: ", as.character(facet[1]))
  if (!is.null(title)) facet_title <- as.character(title[1])
  out <- as_plot_data("facet", list(facets = facet_tbl, title = facet_title))
  if (isTRUE(draw)) draw_facet_plot(facet_tbl, title = facet_title, palette = palette,
                                     show_ci = show_ci, ci_level = ci_level)
  invisible(out)
}

# ---- Bubble Chart ----

resolve_bubble_measures <- function(x, diagnostics = NULL) {
  if (inherits(x, "mfrm_diagnostics") ||
      (is.list(x) && "measures" %in% names(x) && is.data.frame(x$measures))) {
    return(as.data.frame(x$measures, stringsAsFactors = FALSE))
  }
  if (inherits(x, "mfrm_fit")) {
    if (is.null(diagnostics)) {
      diagnostics <- diagnose_mfrm(x, residual_pca = "none")
    }
    return(as.data.frame(diagnostics$measures, stringsAsFactors = FALSE))
  }
  stop("`x` must be an mfrm_fit object or output from diagnose_mfrm().")
}

#' Bubble chart of measure estimates and fit statistics
#'
#' Produces a Rasch-convention bubble chart where each element is a circle
#' positioned at its measure estimate (x) and fit mean-square (y).
#' Bubble radius reflects measurement precision or sample size.
#'
#' @param x Output from \code{\link{fit_mfrm}} or \code{\link{diagnose_mfrm}}.
#' @param diagnostics Optional output from \code{\link{diagnose_mfrm}} when
#'   \code{x} is an \code{mfrm_fit} object. If omitted, diagnostics are
#'   computed automatically.
#' @param fit_stat Fit statistic for the y-axis: \code{"Infit"} (default) or
#'   \code{"Outfit"}.
#' @param bubble_size Variable controlling bubble radius: \code{"SE"} (default),
#'   \code{"N"} (observation count), or \code{"equal"} (uniform size).
#' @param facets Character vector of facets to include. \code{NULL} (default)
#'   includes all non-person facets.
#' @param fit_range Numeric length-2 vector defining the acceptable fit range
#'   shown as a shaded band (default \code{c(0.5, 1.5)}).
#' @param top_n Maximum number of elements to plot (default 60).
#' @param main Optional custom plot title.
#' @param palette Optional named colour vector keyed by facet name.
#' @param draw If \code{TRUE} (default), render the plot using base graphics.
#'
#' @section Interpreting the plot:
#' Points near the horizontal reference line at 1.0 fit the model well.
#' Points above 1.5 show underfit (unpredictable response patterns).
#' Points below 0.5 show overfit (Guttman-like patterns).
#'
#' @return Invisibly, an object of class \code{mfrm_plot_data}.
#' @seealso \code{\link{diagnose_mfrm}}, \code{\link{plot_unexpected}},
#'   \code{\link{plot_fair_average}}
#' @export
plot_bubble <- function(x,
                        diagnostics = NULL,
                        fit_stat = c("Infit", "Outfit"),
                        bubble_size = c("SE", "N", "equal"),
                        facets = NULL,
                        fit_range = c(0.5, 1.5),
                        top_n = 60,
                        main = NULL,
                        palette = NULL,
                        draw = TRUE) {
  fit_stat <- match.arg(fit_stat)
  bubble_size <- match.arg(bubble_size)
  top_n <- max(1L, as.integer(top_n))

  measures <- resolve_bubble_measures(x, diagnostics)
  measures <- measures[measures$Facet != "Person", , drop = FALSE]
  if (!is.null(facets)) {
    measures <- measures[measures$Facet %in% as.character(facets), , drop = FALSE]
  }
  if (nrow(measures) == 0) stop("No measures available for bubble chart.")

  needed <- c("Facet", "Level", "Estimate", fit_stat)
  missing_cols <- setdiff(needed, names(measures))
  if (length(missing_cols) > 0) {
    stop("Missing columns in measures: ", paste(missing_cols, collapse = ", "))
  }

  ok <- is.finite(measures$Estimate) & is.finite(measures[[fit_stat]])
  measures <- measures[ok, , drop = FALSE]
  if (nrow(measures) == 0) stop("No finite measure/fit values for bubble chart.")

  if (nrow(measures) > top_n) {
    measures <- measures[order(abs(measures[[fit_stat]] - 1), decreasing = TRUE), ]
    measures <- measures[seq_len(top_n), , drop = FALSE]
  }

  radius <- switch(bubble_size,
    SE = {
      se_vals <- if ("SE" %in% names(measures)) measures$SE else rep(0.1, nrow(measures))
      se_vals[!is.finite(se_vals)] <- stats::median(se_vals[is.finite(se_vals)], na.rm = TRUE)
      se_vals / max(se_vals, na.rm = TRUE) * 0.15
    },
    N = {
      n_vals <- if ("N" %in% names(measures)) measures$N else rep(1, nrow(measures))
      n_vals[!is.finite(n_vals)] <- 1
      sqrt(n_vals) / max(sqrt(n_vals), na.rm = TRUE) * 0.15
    },
    equal = rep(0.08, nrow(measures))
  )

  unique_facets <- unique(measures$Facet)
  default_cols <- stats::setNames(
    grDevices::hcl.colors(max(3L, length(unique_facets)), "Dark 3")[seq_along(unique_facets)],
    unique_facets
  )
  cols <- resolve_palette(palette = palette, defaults = default_cols)
  point_cols <- cols[as.character(measures$Facet)]

  if (isTRUE(draw)) {
    xr <- range(measures$Estimate, na.rm = TRUE)
    xr <- xr + diff(xr) * c(-0.15, 0.15)
    yr <- range(c(measures[[fit_stat]], fit_range), na.rm = TRUE)
    yr <- yr + diff(yr) * c(-0.1, 0.1)

    graphics::plot(
      x = measures$Estimate, y = measures[[fit_stat]], type = "n",
      xlim = xr, ylim = yr,
      xlab = "Measure (logits)",
      ylab = paste0(fit_stat, " Mean Square"),
      main = if (is.null(main)) paste0("Bubble Chart: ", fit_stat) else as.character(main[1])
    )
    graphics::rect(
      xleft = xr[1] - 1, ybottom = fit_range[1],
      xright = xr[2] + 1, ytop = fit_range[2],
      col = grDevices::adjustcolor("#d9f0d3", alpha.f = 0.4), border = NA
    )
    graphics::abline(h = 1, lty = 2, col = "gray40", lwd = 1.5)
    graphics::abline(h = fit_range, lty = 3, col = "gray60")
    graphics::symbols(
      x = measures$Estimate, y = measures[[fit_stat]],
      circles = radius, inches = FALSE, add = TRUE,
      fg = point_cols,
      bg = grDevices::adjustcolor(point_cols, alpha.f = 0.45)
    )
    graphics::legend(
      "topleft", legend = unique_facets,
      col = cols[unique_facets], pch = 16, bty = "n", cex = 0.85
    )
  }

  out <- new_mfrm_plot_data(
    "bubble",
    list(fit_stat = fit_stat, bubble_size = bubble_size,
         fit_range = fit_range, table = measures, radius = radius)
  )
  invisible(out)
}

# ---- CSV Export ----

#' Export MFRM results to CSV files
#'
#' Writes tidy CSV files suitable for import into spreadsheet software or
#' further analysis in other tools.
#'
#' @param fit Output from \code{\link{fit_mfrm}}.
#' @param diagnostics Optional output from \code{\link{diagnose_mfrm}}.
#'   When provided, enriches facet estimates with SE, fit statistics, and
#'   writes the full measures table.
#' @param output_dir Directory for CSV files. Created if it does not exist.
#' @param prefix Filename prefix (default \code{"mfrm"}).
#' @param tables Character vector of tables to export. Any subset of
#'   \code{"person"}, \code{"facets"}, \code{"summary"}, \code{"steps"},
#'   \code{"measures"}. Default exports all available tables.
#' @param overwrite If \code{FALSE} (default), refuse to overwrite existing
#'   files.
#'
#' @section Exported files:
#' \describe{
#'   \item{\code{{prefix}_person_estimates.csv}}{Person ID, Estimate, SD.}
#'   \item{\code{{prefix}_facet_estimates.csv}}{Facet, Level, Estimate,
#'     and optionally SE, Infit, Outfit, PTMEA when diagnostics supplied.}
#'   \item{\code{{prefix}_fit_summary.csv}}{One-row model summary.}
#'   \item{\code{{prefix}_step_parameters.csv}}{Step/threshold parameters.}
#'   \item{\code{{prefix}_measures.csv}}{Full measures table (requires
#'     diagnostics).}
#' }
#'
#' @return Invisibly, a data.frame listing written files with columns
#'   \code{Table} and \code{Path}.
#' @seealso \code{\link{fit_mfrm}}, \code{\link{diagnose_mfrm}},
#'   \code{\link{as.data.frame.mfrm_fit}}
#' @export
export_mfrm <- function(fit,
                        diagnostics = NULL,
                        output_dir = ".",
                        prefix = "mfrm",
                        tables = c("person", "facets", "summary", "steps", "measures"),
                        overwrite = FALSE) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().")
  }
  tables <- unique(tolower(as.character(tables)))
  allowed <- c("person", "facets", "summary", "steps", "measures")
  bad <- setdiff(tables, allowed)
  if (length(bad) > 0) {
    stop("Unknown table names: ", paste(bad, collapse = ", "),
         ". Allowed: ", paste(allowed, collapse = ", "))
  }
  prefix <- as.character(prefix[1])
  if (!nzchar(prefix)) prefix <- "mfrm"
  overwrite <- isTRUE(overwrite)
  output_dir <- as.character(output_dir[1])

  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  }
  if (!dir.exists(output_dir)) {
    stop("Could not create output directory: ", output_dir)
  }

  written <- data.frame(Table = character(0), Path = character(0),
                        stringsAsFactors = FALSE)

  write_one <- function(df, filename, table_name) {
    path <- file.path(output_dir, filename)
    if (file.exists(path) && !overwrite) {
      stop("File already exists: ", path, ". Set overwrite = TRUE to replace.")
    }
    utils::write.csv(df, file = path, row.names = FALSE, na = "")
    written <<- rbind(written, data.frame(Table = table_name, Path = path,
                                          stringsAsFactors = FALSE))
  }

  if ("person" %in% tables) {
    person_df <- as.data.frame(fit$facets$person, stringsAsFactors = FALSE)
    write_one(person_df, paste0(prefix, "_person_estimates.csv"), "person")
  }

  if ("facets" %in% tables) {
    facet_df <- as.data.frame(fit$facets$others, stringsAsFactors = FALSE)
    if (!is.null(diagnostics) && !is.null(diagnostics$measures)) {
      enrich_cols <- intersect(c("SE", "Infit", "Outfit", "PTMEA", "N"),
                               names(diagnostics$measures))
      if (length(enrich_cols) > 0) {
        enrich <- diagnostics$measures[diagnostics$measures$Facet != "Person",
                                       c("Facet", "Level", enrich_cols), drop = FALSE]
        enrich <- as.data.frame(enrich, stringsAsFactors = FALSE)
        enrich$Level <- as.character(enrich$Level)
        facet_df$Level <- as.character(facet_df$Level)
        facet_df <- merge(facet_df, enrich, by = c("Facet", "Level"), all.x = TRUE)
      }
    }
    write_one(facet_df, paste0(prefix, "_facet_estimates.csv"), "facets")
  }

  if ("summary" %in% tables) {
    summary_df <- as.data.frame(fit$summary, stringsAsFactors = FALSE)
    write_one(summary_df, paste0(prefix, "_fit_summary.csv"), "summary")
  }

  if ("steps" %in% tables) {
    step_df <- as.data.frame(fit$steps, stringsAsFactors = FALSE)
    if (nrow(step_df) > 0) {
      write_one(step_df, paste0(prefix, "_step_parameters.csv"), "steps")
    }
  }

  if ("measures" %in% tables && !is.null(diagnostics) && !is.null(diagnostics$measures)) {
    measures_df <- as.data.frame(diagnostics$measures, stringsAsFactors = FALSE)
    write_one(measures_df, paste0(prefix, "_measures.csv"), "measures")
  }

  invisible(written)
}

#' Convert mfrm_fit to a tidy data.frame
#'
#' Returns all facet-level estimates (person and others) in a single
#' tidy data.frame. Useful for quick interactive export:
#' \code{write.csv(as.data.frame(fit), "results.csv")}.
#'
#' @param x An \code{mfrm_fit} object from \code{\link{fit_mfrm}}.
#' @param row.names Ignored (included for S3 generic compatibility).
#' @param optional Ignored (included for S3 generic compatibility).
#' @param ... Additional arguments (ignored).
#'
#' @return A data.frame with columns \code{Facet}, \code{Level},
#'   \code{Estimate}.
#' @seealso \code{\link{fit_mfrm}}, \code{\link{export_mfrm}}
#' @export
as.data.frame.mfrm_fit <- function(x, row.names = NULL, optional = FALSE, ...) {
  person_df <- data.frame(
    Facet = "Person",
    Level = as.character(x$facets$person$Person),
    Estimate = x$facets$person$Estimate,
    stringsAsFactors = FALSE
  )
  facet_df <- as.data.frame(
    x$facets$others[, c("Facet", "Level", "Estimate")],
    stringsAsFactors = FALSE
  )
  facet_df$Level <- as.character(facet_df$Level)
  rbind(person_df, facet_df)
}

#' @export
print.mfrm_plot_bundle <- function(x, ...) {
  cat("mfrm plot bundle\n")
  cat("  - wright_map\n")
  cat("  - pathway_map\n")
  cat("  - category_characteristic_curves\n")
  cat("Use `$` to access each plotting-data object.\n")
  invisible(x)
}

#' @export
print.mfrm_fit <- function(x, ...) {
  if (is.list(x) && !is.null(x$summary) && nrow(x$summary) > 0) {
    cat("mfrm_fit object\n")
    print(x$summary)
  } else {
    cat("mfrm_fit object (empty summary)\n")
  }
  invisible(x)
}

# ============================================================================
# Anchor Drift & Equating Chain Plots (Phase 4)
# ============================================================================

# --- Internal plot helpers (not exported) ------------------------------------

.plot_drift_dot <- function(dt, config, draw = TRUE, ...) {
  if (!draw) return(invisible(dt))

  opar <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(opar))

  # Order by absolute drift
  dt <- dt |> dplyr::arrange(abs(.data$Drift))
  labels <- paste0(dt$Facet, ":", dt$Level)
  n <- nrow(dt)

  max_abs <- max(abs(dt$Drift), na.rm = TRUE) * 1.2

  graphics::par(mar = c(4, 8, 3, 1))
  graphics::plot(dt$Drift, seq_len(n), xlim = c(-max_abs, max_abs),
                 yaxt = "n", xlab = "Drift (logits)", ylab = "",
                 main = "Anchor Drift", pch = 19,
                 col = ifelse(dt$Flag, "red", "steelblue"), ...)
  graphics::axis(2, at = seq_len(n), labels = labels, las = 1, cex.axis = 0.7)
  graphics::abline(v = 0, lty = 2, col = "gray50")
  graphics::abline(v = c(-config$drift_threshold, config$drift_threshold),
                   lty = 3, col = "red")

  invisible(dt)
}

.plot_drift_heatmap <- function(dt, config, draw = TRUE, ...) {
  # Pivot to wave x element matrix
  dt_wide <- dt |>
    dplyr::mutate(Element = paste0(.data$Facet, ":", .data$Level)) |>
    dplyr::select("Element", "Wave", "Drift")

  mat <- tryCatch({
    tidyr::pivot_wider(dt_wide, names_from = "Wave",
                        values_from = "Drift") |>
      tibble::column_to_rownames("Element") |>
      as.matrix()
  }, error = function(e) NULL)

  if (is.null(mat) || nrow(mat) == 0) {
    if (draw) message("Insufficient data for heatmap.")
    return(invisible(NULL))
  }

  if (!draw) return(invisible(mat))

  max_abs <- max(abs(mat), na.rm = TRUE)
  n_colors <- 21
  breaks <- seq(-max_abs, max_abs, length.out = n_colors + 1)
  blues <- grDevices::colorRampPalette(c("blue", "white", "red"))(n_colors)

  opar <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(opar))
  graphics::par(mar = c(5, 8, 3, 2))

  graphics::image(t(mat[nrow(mat):1, , drop = FALSE]),
                  axes = FALSE, col = blues, breaks = breaks,
                  main = "Anchor Drift Heatmap", ...)
  graphics::axis(1, at = seq(0, 1, length.out = ncol(mat)),
                 labels = colnames(mat), las = 2, cex.axis = 0.8)
  graphics::axis(2, at = seq(0, 1, length.out = nrow(mat)),
                 labels = rev(rownames(mat)), las = 1, cex.axis = 0.7)

  invisible(mat)
}

.plot_equating_chain <- function(x, draw = TRUE, ...) {
  cum <- x$cumulative
  if (!draw) return(invisible(cum))

  opar <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(opar))
  graphics::par(mar = c(5, 4, 3, 1))

  n <- nrow(cum)
  graphics::plot(seq_len(n), cum$Cumulative_Offset, type = "b",
                 pch = 19, col = "steelblue", lwd = 2,
                 xaxt = "n", xlab = "", ylab = "Cumulative Offset (logits)",
                 main = "Equating Chain", ...)
  graphics::axis(1, at = seq_len(n), labels = cum$Wave, las = 2, cex.axis = 0.8)
  graphics::abline(h = 0, lty = 2, col = "gray50")

  # Add link quality annotations
  links <- x$links
  for (i in seq_len(nrow(links))) {
    mid_x <- i + 0.5
    mid_y <- (cum$Cumulative_Offset[i] + cum$Cumulative_Offset[i + 1]) / 2
    graphics::text(mid_x, mid_y, sprintf("n=%d", links$N_Common[i]),
                   cex = 0.7, col = "gray40")
  }

  invisible(cum)
}

# --- Exported plot function --------------------------------------------------

#' Plot anchor drift or equating chain
#'
#' Creates base-R plots for inspecting anchor drift across calibration waves
#' or visualising the cumulative offset in an equating chain.
#'
#' @param x An `mfrm_anchor_drift` or `mfrm_equating_chain` object.
#' @param type Plot type: `"drift"` (dot plot of element drift),
#'   `"chain"` (cumulative offset line plot), or `"heatmap"`
#'   (wave-by-element drift heatmap).
#' @param facet Optional character vector to filter drift plots to specific
#'   facets.
#' @param draw If `FALSE`, return the plot data invisibly without drawing.
#' @param ... Additional graphical parameters passed to base plotting
#'   functions.
#'
#' @details
#' Three plot types are supported:
#'
#' - **`"drift"`** (for `mfrm_anchor_drift` objects): A dot plot of each
#'   element's drift value, grouped by facet.  Horizontal reference lines
#'   mark the drift threshold.  Red points indicate flagged elements.
#' - **`"heatmap"`** (for `mfrm_anchor_drift` objects): A wave-by-element
#'   heat matrix showing drift magnitude.  Darker cells represent larger
#'   absolute drift.  Useful for spotting systematic patterns (e.g., all
#'   criteria shifting in the same direction).
#' - **`"chain"`** (for `mfrm_equating_chain` objects): A line plot of
#'   cumulative offsets across the equating chain.  A flat line indicates
#'   a stable scale; steep segments suggest large between-wave shifts.
#'
#' @section Interpreting plots:
#' - In drift and heatmap plots, red or dark-shaded elements are flagged
#'   for exceeding the drift and/or SE ratio thresholds.  These elements
#'   may warrant investigation (e.g., rater re-training, item revision).
#' - In chain plots, uneven spacing between waves suggests differential
#'   difficulty shifts.  The \eqn{y}-axis shows logit-scale offsets.
#'
#' @return Invisible `mfrm_plot_data` object containing the plot data.
#'
#' @seealso [detect_anchor_drift()], [build_equating_chain()],
#'   [plot_dif_heatmap()], [plot_bubble()]
#' @export
#' @examples
#' d1 <- load_mfrmr_data("study1")
#' d2 <- load_mfrmr_data("study2")
#' fit1 <- fit_mfrm(d1, "Person", c("Rater", "Criterion"), "Score",
#'                  method = "JML", maxit = 25)
#' fit2 <- fit_mfrm(d2, "Person", c("Rater", "Criterion"), "Score",
#'                  method = "JML", maxit = 25)
#' drift <- detect_anchor_drift(list(W1 = fit1, W2 = fit2))
#' plot_anchor_drift(drift, type = "drift", draw = FALSE)
#' chain <- build_equating_chain(list(F1 = fit1, F2 = fit2))
#' plot_anchor_drift(chain, type = "chain", draw = FALSE)
plot_anchor_drift <- function(x, type = c("drift", "chain", "heatmap"),
                              facet = NULL, draw = TRUE, ...) {
  type <- match.arg(type)

  # Handle equating chain objects
  if (inherits(x, "mfrm_equating_chain")) {
    if (type == "chain") {
      return(.plot_equating_chain(x, draw = draw, ...))
    }
  }

  # Handle anchor drift objects
  if (inherits(x, "mfrm_anchor_drift")) {
    dt <- x$drift_table
    if (!is.null(facet)) dt <- dt |> dplyr::filter(.data$Facet %in% facet)

    if (nrow(dt) == 0) {
      if (draw) message("No drift data to plot.")
      return(invisible(NULL))
    }

    if (type == "drift") {
      return(.plot_drift_dot(dt, x$config, draw = draw, ...))
    } else if (type == "heatmap") {
      return(.plot_drift_heatmap(dt, x$config, draw = draw, ...))
    }
  }

  stop("Unsupported object class or plot type combination.", call. = FALSE)
}

# ============================================================================
# QC Pipeline Plot (Phase 5)
# ============================================================================

#' Plot QC pipeline results
#'
#' Visualizes the output from [run_qc_pipeline()] as either a traffic-light
#' bar chart or a detail panel showing values versus thresholds.
#'
#' @param x Output from [run_qc_pipeline()].
#' @param type Plot type: `"traffic_light"` (default) or `"detail"`.
#' @param draw If `FALSE`, return plot data invisibly without drawing.
#' @param ... Additional graphical parameters passed to plotting functions.
#'
#' @details
#' Two plot types are provided for visual triage of QC results:
#'
#' - **`"traffic_light"`** (default): A horizontal bar chart with one row
#'   per QC check.  Bars are coloured green (Pass), amber (Warn), or red
#'   (Fail).  Provides an at-a-glance summary of overall model quality.
#' - **`"detail"`**: A panel showing each check's observed value and its
#'   pass/warn/fail thresholds.  Useful for understanding how close a
#'   borderline result is to the next verdict level.
#'
#' @section Interpreting plots:
#' - Green bars indicate checks that meet the threshold profile criteria.
#' - Amber bars signal areas that may need attention but are not critical.
#' - Red bars require investigation before the calibration is used
#'   operationally.
#' - The detail view shows numeric values, making it easy to communicate
#'   exact results to stakeholders.
#'
#' @return Invisible verdicts tibble from the QC pipeline.
#'
#' @seealso [run_qc_pipeline()], [plot_qc_dashboard()],
#'   [build_visual_summaries()]
#' @examples
#' toy <- load_mfrmr_data("study1")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 25)
#' qc <- run_qc_pipeline(fit)
#' plot_qc_pipeline(qc, draw = FALSE)
#' @export
plot_qc_pipeline <- function(x, type = c("traffic_light", "detail"),
                             draw = TRUE, ...) {
  type <- match.arg(type)
  stopifnot(inherits(x, "mfrm_qc_pipeline"))

  vt <- x$verdicts
  if (!draw) return(invisible(vt))

  n <- nrow(vt)
  cols <- ifelse(vt$Verdict == "Pass", "#2ca02c",
                 ifelse(vt$Verdict == "Warn", "#ff7f0e",
                        ifelse(vt$Verdict == "Fail", "#d62728", "#999999")))

  opar <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(opar))

  if (type == "traffic_light") {
    graphics::par(mar = c(3, 14, 3, 4))

    graphics::plot(NULL, xlim = c(0, 1), ylim = c(0.5, n + 0.5),
                   xaxt = "n", yaxt = "n", xlab = "", ylab = "",
                   main = paste("QC Pipeline:", x$overall), ...)

    for (i in seq_len(n)) {
      graphics::rect(0, i - 0.4, 1, i + 0.4, col = cols[i], border = NA)
      graphics::text(0.5, i, vt$Verdict[i], col = "white", font = 2, cex = 0.9)
    }

    graphics::axis(2, at = seq_len(n), labels = vt$Check,
                   las = 1, cex.axis = 0.8, tick = FALSE)

    for (i in seq_len(n)) {
      graphics::mtext(vt$Value[i], side = 4, at = i,
                      las = 1, cex = 0.6, line = 0.5)
    }
  } else {
    # detail view: show check names with verdict + value text
    graphics::par(mar = c(3, 14, 3, 8))

    graphics::plot(NULL, xlim = c(0, 1), ylim = c(0.5, n + 0.5),
                   xaxt = "n", yaxt = "n", xlab = "", ylab = "",
                   main = paste("QC Pipeline Detail:", x$overall), ...)

    for (i in seq_len(n)) {
      graphics::rect(0, i - 0.4, 0.15, i + 0.4, col = cols[i], border = NA)
      graphics::text(0.075, i, substr(vt$Verdict[i], 1, 1),
                     col = "white", font = 2, cex = 0.8)
      graphics::text(0.2, i, vt$Detail[i], adj = 0, cex = 0.7)
    }

    graphics::axis(2, at = seq_len(n), labels = vt$Check,
                   las = 1, cex.axis = 0.8, tick = FALSE)
  }

  invisible(vt)
}
