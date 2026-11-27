# ==============================================================================
# Unified Color-Vision-Safe ggplot2 `plot()` Methods for `mfrmr`
# Supports Okabe-Ito, Viridis, and Strict Monochrome + Redundant Shape/Linetype
# ==============================================================================

.mfrm_gg_theme <- function(base_size = 11) {
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

.mfrm_cvd_palette <- function(n, palette = c("okabe_ito", "viridis", "monochrome")) {
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

.mfrm_cvd_shapes <- function(n) {
  sh <- c(16L, 17L, 15L, 18L, 3L, 4L, 8L, 1L, 2L, 0L)
  rep(sh, length.out = max(1L, n))[seq_len(n)]
}

.mfrm_cvd_linetypes <- function(n) {
  lt <- c("solid", "dashed", "dotdash", "twodash", "longdash", "dotted")
  rep(lt, length.out = max(1L, n))[seq_len(n)]
}

.mfrm_wright_yardstick <- function(yardstick) {
  if (is.null(yardstick)) return(NULL)
  if (is.numeric(yardstick)) yardstick <- list(lines = yardstick)
  if (!is.list(yardstick) || is.null(names(yardstick)) || anyDuplicated(names(yardstick)) ||
      !all(names(yardstick) %in% c("lines", "range")))
    stop("Use yardstick = lines per logit, or list(lines = ..., range = c(low, high)).", call. = FALSE)
  lines <- yardstick[["lines"]]
  if (!is.numeric(lines) || length(lines) != 1L || !is.finite(lines) || lines <= 0 || !is.finite(1 / lines))
    stop("Yardstick lines must be a finite positive number of rows per logit.", call. = FALSE)
  window <- yardstick[["range"]]
  if (!is.null(window) && (!is.numeric(window) || length(window) != 2L ||
      any(!is.finite(window)) || window[1] >= window[2]))
    stop("Supply an increasing finite pair for the yardstick range.", call. = FALSE)
  list(lines = lines, range = window)
}

.mfrm_wright_bins <- function(pt, binwidth, lines) {
  if (!is.null(lines)) {
    # Assign half-row ties to the higher ruler mark, including negative measures.
    row <- floor(pt * lines + 0.5)
    limits <- range(row)
    if (!is.finite(diff(limits)) || diff(limits) > 10000 || any(abs(limits) >= 2^52))
      stop("Choose fewer yardstick lines per logit for this range.", call. = FALSE)
    centers <- seq(limits[1], limits[2])
    return(data.frame(Lower = (centers - 0.5) / lines, Upper = (centers + 0.5) / lines,
      Count = tabulate(as.integer(row - limits[1] + 1), length(centers)), Center = centers / lines))
  }
  breaks <- "Sturges"
  if (!is.null(binwidth)) {
    first <- floor(min(pt) / binwidth)
    last <- max(first + 1, ceiling(max(pt) / binwidth))
    if (!is.finite(last - first) || last <= first || last - first > 10000 ||
        any(abs(c(first, last)) >= 2^52))
      stop("Choose a larger binwidth for the observed ability range.", call. = FALSE)
    breaks <- seq(first, last) * binwidth
  }
  h <- graphics::hist(pt, breaks = breaks, plot = FALSE)
  data.frame(Lower = head(h$breaks, -1L), Upper = tail(h$breaks, -1L), Count = h$counts, Center = h$mids)
}

.mfrm_wright_fair_ticks <- function(fit, y, reference_plan) {
  if (!is.null(reference_plan)) reference_plan <- mfrm_fair_reference_plan(fit, reference_plan)
  ready <- .mfrm_readiness(fit)
  if (!ready$ready)
    return(list(note = paste("Fair average withheld:", paste(ready$reason_codes, collapse = ", "))))
  enc <- fit$encoding
  if (is.null(reference_plan)) {
    # Stored person Fair(M) uses the original calibration even if facet estimates were shrunk later.
    curve <- .mfrm_person_fair_curve(fit, fit$facets$MLEEstimate %||% fit$facets$Estimate)
    totals <- rowsum(enc$weight, enc$step_group0 + 1L, reorder = FALSE)
    mix <- numeric(nrow(fit$step_cumulative))
    mix[as.integer(rownames(totals))] <- totals[, 1L] / sum(totals)
    names(mix) <- enc$step_owners
    score <- function(th) curve(th, mix)
    pooled <- length(mix) > 1L
    label <- if (pooled) "Fair average\n(pooled mix)" else "Fair average"
    reference <- if (pooled) "Rating-weighted step-group mix" else "Person Fair(M)"
    note <- "Fair average is the expected rating at this person ability with facets at their calibration means."
    if (pooled) note <- paste(note, "Step-group weights are pooled across ratings. Individual Fair(M) can differ when assignments differ.")
    if (length(enc$slope_facets)) note <- paste(note, "Discrimination is set to its observation-weighted geometric mean.")
  } else {
    score <- function(th) .mfrm_reference_expected(fit, reference_plan, th)
    label <- "Fair average\n(reference plan)"
    reference <- "Specified reference plan"
    note <- "Fair average is the weighted expected rating under the same specified reference plan at every person ability."
  }
  limits <- vapply(y, score, numeric(1))
  if (any(!is.finite(limits)) || limits[1] >= limits[2])
    return(list(note = "Fair average unavailable: no resolvable score variation in the displayed logit range."))
  scores <- unique(round(pretty(limits, n = 5), 2))
  scores <- scores[scores > limits[1] & scores < limits[2]]
  if (!length(scores))
    return(list(note = "No interior fair-average tick at hundredth-of-a-point resolution in the displayed range."))
  theta <- vapply(scores, function(v) stats::uniroot(function(th) score(th) - v, y,
    f.lower = limits[1] - v, f.upper = limits[2] - v, tol = 1e-9)$root, numeric(1))
  # A very wide window can compress several score labels into a single printed line.
  keep <- 1L
  for (i in seq_along(theta)[-1L])
    if (theta[i] - theta[tail(keep, 1L)] >= .06 * diff(y)) keep <- c(keep, i)
  ticks <- data.frame(FairAverage = scores[keep], Logit = theta[keep], Reference = reference)
  if (is.null(reference_plan)) attr(ticks, "step_weights") <- mix else attr(ticks, "reference_plan") <- reference_plan
  list(ticks = ticks, label = label, note = note)
}

.mfrm_gg_wright <- function(fit, palette, base_size, person_display = "histogram",
                            binwidth = NULL, newdata = NULL, persons_per_star = NULL, yardstick = NULL,
                            fair_average = TRUE, reference_plan = NULL) {
  person_display <- match.arg(person_display, c("histogram", "density", "stars"))
  ruler <- .mfrm_wright_yardstick(yardstick)
  if (!is.logical(fair_average) || length(fair_average) != 1L || is.na(fair_average))
    stop("fair_average must be TRUE or FALSE.", call. = FALSE)
  if (!fair_average && !is.null(reference_plan))
    stop("Use fair_average = TRUE to display a reference_plan.", call. = FALSE)
  stars <- person_display == "stars"
  if (!is.null(persons_per_star) && (!stars || !is.numeric(persons_per_star) ||
      length(persons_per_star) != 1L || !is.finite(persons_per_star) || persons_per_star < 1 ||
      persons_per_star != floor(persons_per_star)))
    stop("Use a positive whole persons_per_star with person_display = 'stars'.", call. = FALSE)
  persons_per_star <- persons_per_star %||% 3L
  if (!is.null(binwidth) && (!is.numeric(binwidth) || length(binwidth) != 1L ||
      !is.finite(binwidth) || binwidth <= 0 || person_display == "density" || !is.null(ruler)))
    stop("Use a finite positive binwidth for counts, or choose yardstick lines per logit.", call. = FALSE)
  pt <- fit$person$Estimate[is.finite(fit$person$Estimate)]
  fc <- fit$facets[is.finite(fit$facets$Estimate), , drop = FALSE]
  st <- fit$steps[fit$steps$Supported & fit$steps$Identified & is.finite(fit$steps$Estimate), , drop = FALSE]
  enc <- fit$encoding
  step_title <- "Step offsets"
  notes <- "Step offsets are adjacent-category parameters relative to the element location."
  if (!is.null(newdata)) {
    if (!is.data.frame(newdata) || nrow(newdata) != 1L || !all(enc$base_facets %in% names(newdata)))
      stop("Supply one row with all fitted facets for Wright map crossings.", call. = FALSE)
    context <- newdata[enc$base_facets]
    offset <- stats::predict(fit, newdata = context, type = "link", theta = 0)
    if (enc$model_code == 1L)
      st <- st[st$ScaleLevel == as.character(context[[enc$step_facet]]), , drop = FALSE]
    divisor <- 1
    if (isTRUE(enc$slope_formula == 1L)) {
      for (facet in enc$slope_facets) {
        sl <- fit$slopes[fit$slopes$Facet == facet, ]
        divisor <- divisor * sl$Estimate[match(as.character(context[[facet]]), sl$Level)]
      }
    }
    st$Estimate <- (st$Estimate - offset) / divisor
    step_title <- "Ability crossings"
    notes <- paste("Adjacent categories have equal probability at the displayed ability for",
                   paste(names(context), vapply(context, as.character, character(1)), sep = " = ", collapse = ", "))
    readiness <- .mfrm_readiness(fit)
    if (!readiness$ready) {
      st <- st[FALSE, ]
      notes <- c(notes, paste("Crossings withheld:", paste(readiness$reason_codes, collapse = ", ")))
    }
  }
  levels <- unique(as.character(fc$Facet))
  points <- data.frame(Panel = fc$Facet, Element = fc$Level, Label = as.character(fc$Level), Logit = fc$Estimate,
                       XPos = match(fc$Facet, levels) + 1L)
  if (nrow(st)) {
    label <- if (enc$model_code == 1L) paste(st$ScaleLevel, st$Step, sep = ":") else st$Step
    transition <- paste(st$FromCategory, "to", st$ToCategory)
    if (enc$model_code == 1L && is.null(newdata)) transition <- paste(st$ScaleLevel, transition)
    points <- rbind(points, data.frame(Panel = step_title, Element = label, Label = transition, Logit = st$Estimate,
                                       XPos = length(levels) + 2L))
    levels <- c(levels, step_title)
  }
  colours <- .mfrm_cvd_palette(length(levels) + 1L, palette)
  p <- ggplot2::ggplot() + ggplot2::geom_hline(yintercept = 0, linetype = "dashed", colour = "grey65", linewidth = .35)
  right <- 1.42
  span <- 0.94
  axis_x <- 1
  axis_labels <- if (stars) "+Person" else "Person"
  person_label <- sprintf("Person ability (N = %d)", length(pt))
  if (length(pt) && person_display != "density") {
    bins <- .mfrm_wright_bins(pt, binwidth, ruler$lines)
    width <- format(signif(bins$Upper[1] - bins$Lower[1], 4))
    peak <- max(bins$Count)
    bins$Left <- right - span * bins$Count / peak
    if (!stars) {
      p <- p + ggplot2::geom_rect(data = bins, ggplot2::aes(ymin = .data$Lower, ymax = .data$Upper,
        xmin = .data$Left), xmax = right, fill = colours[1L], colour = "white", linewidth = 0.3)
      ticks <- unique(c(0, if (peak >= 4) floor(peak / 2), peak))
      axis_x <- right - span * ticks / peak
      axis_labels <- as.character(ticks)
      person_label <- sprintf("Person count (N = %d; bin width %s logits)", length(pt), width)
    } else {
      marks <- bins[bins$Count > 0, ]
      whole <- marks$Count %/% persons_per_star
      remainder <- marks$Count %% persons_per_star
      # Reserve the same remainder column on every row so the star tallies align on the right.
      rest <- ifelse(remainder > 0, paste0("+", remainder), "")
      tally <- if (max(whole) > 12L) {
        notes <- c(notes, "Large tallies use a multiplier (e.g., 20 x *).")
        ifelse(whole > 0, paste(whole, "x *"), "")
      } else {
        strrep("*", as.integer(whole))
      }
      marks$Mark <- paste0(tally, " ", rest, strrep("\u00a0", max(nchar(rest)) - nchar(rest)))
      p <- p + ggplot2::geom_text(data = marks, ggplot2::aes(y = .data$Center, label = .data$Mark),
        x = right - .035, colour = colours[1L], family = "mono", fontface = "bold", size = 3.6, hjust = 1)
      axis_x <- right - .2
      person_label <- sprintf("N = %d; * = %s %s; +n = remainder; bin width %s logits",
        length(pt), format(persons_per_star), if (persons_per_star == 1) "person" else "persons", width)
    }
  } else if (length(unique(pt)) >= 2L) {
    den <- stats::density(pt)
    area <- data.frame(Logit = c(den$x[1], den$x, tail(den$x, 1)), Density = c(0, den$y, 0))
    area$XPos <- right - span * area$Density / max(den$y)
    p <- p + ggplot2::geom_polygon(data = area, ggplot2::aes(x = .data$XPos, y = .data$Logit),
                                   fill = colours[1L], alpha = .45)
    axis_x <- c(right, right - span)
    axis_labels <- format(signif(c(0, max(den$y)), 3))
    person_label <- sprintf("Person density (N = %d; bandwidth %s logits)", length(pt), format(signif(den$bw, 3)))
  } else if (length(pt)) {
    p <- p + ggplot2::annotate("point", x = 1, y = pt[1L], colour = colours[1L])
    notes <- c(notes, "Density requires distinct abilities. A point marks the common estimate.")
  }
  y <- ruler$range
  if (is.null(y)) {
    plotted <- c(0, points$Logit, pt)
    if (length(pt) && person_display != "density") plotted <- c(plotted, bins$Lower, bins$Upper)
    if (person_display == "density" && length(unique(pt)) >= 2L) plotted <- c(plotted, den$x)
    y <- range(plotted, finite = TRUE)
  }
  if (!is.null(ruler)) {
    bounds <- c(ceiling(y[1] * ruler$lines), floor(y[2] * ruler$lines))
    if (!is.finite(diff(bounds)) || diff(bounds) > 10000 || any(abs(bounds) >= 2^52))
      stop("Choose fewer yardstick lines per logit or a narrower range.", call. = FALSE)
    ticks <- if (bounds[1] <= bounds[2]) seq(bounds[1], bounds[2]) / ruler$lines else numeric()
    p <- p + ggplot2::annotate("segment", x = right, xend = right, y = y[1], yend = y[2],
      colour = "grey45", linewidth = .35)
    if (length(ticks)) p <- p + ggplot2::annotate("segment", x = right, xend = right + .055,
      y = ticks, yend = ticks, colour = "grey45", linewidth = .35)
    notes <- c(notes, sprintf("Yardstick: %s rows per logit. Facet and step points retain their fitted positions.",
                              format(ruler$lines)))
    if (!is.null(ruler$range)) {
      p <- p + ggplot2::coord_cartesian(ylim = y, expand = FALSE)
      notes <- c(notes, sprintf("Display window [%s, %s] logits; %d finite person estimates outside. N includes all bins.",
        format(y[1]), format(y[2]), sum(pt < y[1] | pt > y[2])))
    }
  }
  if (nrow(points)) {
    labels <- points[points$Logit >= y[1] & points$Logit <= y[2], , drop = FALSE]
    labels$LabelY <- labels$Logit
    gap <- .055 * diff(y)
    for (rows in split(seq_len(nrow(labels)), labels$Panel)) {
      if (length(rows) < 2L || gap == 0 || (length(rows) - 1L) * gap > diff(y)) next
      i <- rows[order(labels$Logit[rows])]
      spacing <- (seq_along(i) - 1L) * gap
      # Fit ordered label positions with minimum spacing; dots stay at their measured logits.
      packed <- stats::isoreg(labels$Logit[i] - spacing)$yf
      labels$LabelY[i] <- pmax(y[1], pmin(y[2] - max(spacing), packed)) + spacing
    }
    shifted <- labels[abs(labels$LabelY - labels$Logit) > gap / 10, , drop = FALSE]
    if (nrow(shifted)) p <- p + ggplot2::geom_segment(data = shifted, ggplot2::aes(
      x = .data$XPos, xend = .data$XPos + .085, y = .data$Logit, yend = .data$LabelY),
      colour = "grey65", linewidth = .3)
    p <- p + ggplot2::geom_point(data = points, ggplot2::aes(x = .data$XPos, y = .data$Logit,
      colour = .data$Panel, shape = .data$Panel), size = 2.7) +
      ggplot2::geom_text(data = labels, ggplot2::aes(x = .data$XPos + .095, y = .data$LabelY,
        label = .data$Label), hjust = 0, size = 3, check_overlap = TRUE)
  }
  panel_labels <- levels
  if (stars || !is.null(ruler)) {
    facets <- unique(as.character(fc$Facet))
    panel_labels[seq_along(facets)] <- paste0(ifelse(enc$facet_signs[match(facets, enc$facets)] < 0, "-", "+"), facets)
  }
  columns <- seq_along(levels) + 1L
  fair <- if (fair_average) .mfrm_wright_fair_ticks(fit, y, reference_plan)
  if (!is.null(fair$ticks)) {
    x <- length(levels) + 2L
    ink <- if (palette == "monochrome") "#373737" else "#285C62"
    p <- p + ggplot2::annotate("segment", x = x, xend = x, y = y[1], yend = y[2],
        colour = "grey78", linewidth = .4) +
      ggplot2::geom_segment(data = fair$ticks, ggplot2::aes(y = .data$Logit, yend = .data$Logit),
        x = x - .06, xend = x + .06, colour = ink, linewidth = .6) +
      ggplot2::geom_text(data = fair$ticks, ggplot2::aes(y = .data$Logit, label = format(.data$FairAverage, trim = TRUE, nsmall = 1)),
        x = x + .10, hjust = 0, fontface = "bold", colour = ink, size = 3.3)
    columns <- c(columns, x)
    panel_labels <- c(panel_labels, fair$label)
  }
  p <- p + ggplot2::scale_x_continuous(breaks = c(axis_x, columns),
      labels = c(axis_labels, panel_labels), limits = c(.4, max(1.5, columns + .7))) +
    ggplot2::scale_colour_manual(values = stats::setNames(colours[-1], levels), guide = "none") +
    ggplot2::scale_shape_manual(values = stats::setNames(.mfrm_cvd_shapes(length(levels)), levels), guide = "none") +
    ggplot2::labs(x = person_label, y = "Logits") + .mfrm_gg_theme(base_size)
  p <- p + ggplot2::theme(panel.grid.major.x = ggplot2::element_blank())
  attr(p, "mfrm_fair_average") <- fair$ticks
  attr(p, "mfrm_notes") <- c(notes, fair$note, sprintf("Distribution of finite %s person estimates (%d of %d).",
      fit$score_method, length(pt), nrow(fit$person)))
  p
}

.mfrm_normalize_ref_bands <- function(reference_bands) {
  if (is.null(reference_bands)) return(list())
  if (is.numeric(reference_bands) && !is.list(reference_bands)) {
    return(list(.mfrm_validate_mnsq_range(reference_bands, "`reference_bands`")))
  }
  if (!is.list(reference_bands)) {
    stop("`reference_bands` must be a length-2 numeric vector or a list of length-2 numeric vectors.", call. = FALSE)
  }
  lapply(reference_bands, .mfrm_validate_mnsq_range, label = "`reference_bands`")
}

.mfrm_empty_mnsq_plot <- function(data, levels, statistics) {
  p <- ggplot2::ggplot(data) + ggplot2::theme_void()
  attr(p, "mfrm_notes") <- paste("No elements have both a finite measure and a finite",
    paste(statistics, collapse = " or "), "MnSq on the selected basis. Elements:", paste(unique(levels), collapse = ", "))
  p
}

.mfrm_gg_pathway <- function(facets_df, mnsq_range = c(0.70, 1.30), palette = "okabe_ito", base_size = 11,
                             fit_statistic = c("infit", "outfit", "both"),
                             fit_method = c("auto", "posterior", "plugin", "both"),
                             zstd_limit = NULL,
                             reference_bands = NULL,
                             method_label = NULL) {
  fit_statistic <- match.arg(fit_statistic)
  fit_method <- match.arg(fit_method)
  mnsq_range <- .mfrm_validate_mnsq_range(mnsq_range)
  ref_list <- .mfrm_normalize_ref_bands(reference_bands)
  if (!is.null(zstd_limit)) {
    if (!is.numeric(zstd_limit) || is.factor(zstd_limit) || length(zstd_limit) != 1L ||
        !is.finite(zstd_limit) || zstd_limit < 0) {
      stop("`zstd_limit` must be a single finite nonnegative number.", call. = FALSE)
    }
    zstd_limit <- as.double(zstd_limit)
  }
  statistics <- if (fit_statistic == "both") c("Infit", "Outfit") else tools::toTitleCase(fit_statistic)

  if (identical(fit_method, "both")) {
    has_post <- "PostInfitMnSq" %in% names(facets_df) &&
      (identical(method_label, "MML") || any(is.finite(facets_df$PostInfitMnSq)))
    if (!has_post) {
      stop("`fit_method = 'both'` requires an MML calibration with posterior-integrated fit indices.", call. = FALSE)
    }
    df_list <- lapply(statistics, function(statistic) {
      v_plug <- facets_df[[paste0(statistic, "MnSq")]]
      v_post <- facets_df[[paste0("Post", statistic, "MnSq")]]
      keep <- is.finite(facets_df$Estimate) & (is.finite(v_plug) | is.finite(v_post))
      sub_f <- facets_df[keep, , drop = FALSE]
      sub_f$FitBasis <- NULL
      rbind(
        data.frame(sub_f, FitMnSq = v_post[keep], Statistic = rep(statistic, sum(keep)),
                   FitBasis = rep("Posterior (TAM)", sum(keep)), stringsAsFactors = FALSE),
        data.frame(sub_f, FitMnSq = v_plug[keep], Statistic = rep(statistic, sum(keep)),
                   FitBasis = rep("Plug-in", sum(keep)), stringsAsFactors = FALSE)
      )
    })
    df <- do.call(rbind, df_list)
    df <- df[is.finite(df$FitMnSq), , drop = FALSE]
    if (!nrow(df)) return(.mfrm_empty_mnsq_plot(df, facets_df$Level, statistics))
    se_use <- if ("RealSE" %in% names(df)) df$RealSE else df$ModelSE
    df$Low <- df$Estimate - 1.96 * se_use
    df$High <- df$Estimate + 1.96 * se_use
    basis_lvls <- c("Posterior (TAM)", "Plug-in")
    df$FitBasis <- factor(df$FitBasis, levels = basis_lvls)
    cols <- stats::setNames(.mfrm_cvd_palette(2L, palette), basis_lvls)
    shapes <- stats::setNames(c(16L, 17L), basis_lvls)
    ltypes <- stats::setNames(c("solid", "dashed"), basis_lvls)

    seg_list <- lapply(statistics, function(statistic) {
      v_plug <- facets_df[[paste0(statistic, "MnSq")]]
      v_post <- facets_df[[paste0("Post", statistic, "MnSq")]]
      ok <- is.finite(facets_df$Estimate) & is.finite(v_plug) & is.finite(v_post)
      if (!any(ok)) return(NULL)
      data.frame(Facet = facets_df$Facet[ok], Level = facets_df$Level[ok],
                 Estimate = facets_df$Estimate[ok], X0 = v_plug[ok], X1 = v_post[ok],
                 Statistic = statistic, stringsAsFactors = FALSE)
    })
    seg_df <- do.call(rbind, Filter(Negate(is.null), seg_list))

    p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$FitMnSq, y = .data$Estimate)) +
      ggplot2::geom_vline(xintercept = 1.0, linetype = "solid", colour = "#999999", linewidth = 0.35) +
      ggplot2::geom_vline(xintercept = mnsq_range, linetype = "dashed", colour = "#666666", linewidth = 0.4) +
      ggplot2::geom_hline(yintercept = 0.0, linetype = "dotted", colour = "#888888", linewidth = 0.35)
    for (rb in ref_list) {
      p <- p + ggplot2::geom_vline(xintercept = rb, linetype = "dotdash", colour = "#888888", linewidth = 0.35)
    }
    if (!is.null(seg_df) && nrow(seg_df) > 0L) {
      p <- p + ggplot2::geom_segment(
        data = seg_df,
        ggplot2::aes(x = .data$X0, xend = .data$X1, y = .data$Estimate, yend = .data$Estimate),
        colour = "#888888", linewidth = 0.45, inherit.aes = FALSE
      )
    }
    label_rows <- df[!duplicated(df[c("Facet", "Level", "Statistic")]), , drop = FALSE]
    p <- p +
      ggplot2::geom_errorbar(
        data = label_rows,
        ggplot2::aes(ymin = .data$Low, ymax = .data$High, colour = .data$FitBasis, linetype = .data$FitBasis),
        width = 0.0, linewidth = 0.5, alpha = 0.75, na.rm = TRUE
      ) +
      ggplot2::geom_point(ggplot2::aes(colour = .data$FitBasis, shape = .data$FitBasis), size = 2.9) +
      ggplot2::geom_text(
        data = label_rows,
        ggplot2::aes(label = .data$Level),
        nudge_y = 0.04 * if (nrow(df)) max(diff(range(df$Estimate)), 0.5) else 0.5,
        size = 2.9, colour = "#222222", check_overlap = TRUE
      ) +
      ggplot2::scale_colour_manual(values = cols, drop = FALSE, name = "Fit Basis") +
      ggplot2::scale_shape_manual(values = shapes, drop = FALSE, name = "Fit Basis") +
      ggplot2::scale_linetype_manual(values = ltypes, drop = FALSE, name = "Fit Basis") +
      ggplot2::labs(x = if (length(statistics) == 1L) paste(statistics, "Mean-Square (MnSq)") else "Mean-Square (MnSq)",
                    y = "Measure (Logits)") +
      .mfrm_gg_theme(base_size = base_size)
    if (fit_statistic == "both" && nrow(df)) {
      p <- p + ggplot2::facet_grid(Facet ~ Statistic)
    } else if (length(unique(df$Facet)) > 1L) {
      p <- p + ggplot2::facet_wrap(~ Facet)
    }
    ref_note <- if (length(ref_list)) {
      paste("Dot-dash lines mark secondary reference bounds:",
            paste(vapply(ref_list, function(r) sprintf("[%.2f, %.2f]", r[1L], r[2L]), character(1)), collapse = ", "))
    }
    attr(p, "mfrm_notes") <- c(
      sprintf("Dashed vertical lines mark primary MnSq bounds [%.2f, %.2f].", mnsq_range[1L], mnsq_range[2L]),
      ref_note,
      "Horizontal segments connect each element's point-estimate plug-in MnSq and MML posterior-integrated (TAM) MnSq."
    )
    return(p)
  }

  fm <- .mfrm_resolve_fit_method(facets_df, method_label, fit_method)
  use_post <- identical(fm, "posterior")
  df <- do.call(rbind, lapply(statistics, function(statistic) {
    m_col <- paste0(if (use_post) "Post" else "", statistic, "MnSq")
    z_col <- paste0(if (use_post) "Post" else "", statistic, "ZSTD")
    vals <- facets_df[[m_col]]
    zvals <- if (z_col %in% names(facets_df)) facets_df[[z_col]] else rep(NA_real_, nrow(facets_df))
    keep <- is.finite(facets_df$Estimate) & is.finite(vals)
    data.frame(facets_df[keep, , drop = FALSE],
               FitMnSq = vals[keep], FitZSTD = zvals[keep], Statistic = rep(statistic, sum(keep)))
  }))
  if (!nrow(df)) return(.mfrm_empty_mnsq_plot(df, facets_df$Level, statistics))
  df$FitBasis <- fm
  se_use <- if ("RealSE" %in% names(df)) df$RealSE else df$ModelSE
  df$Low <- df$Estimate - 1.96 * se_use
  df$High <- df$Estimate + 1.96 * se_use

  if (is.null(zstd_limit)) {
    df$FitBand <- ifelse(
      df$FitMnSq > mnsq_range[2L], "Above Upper Bound (MnSq > Upper)",
      ifelse(df$FitMnSq < mnsq_range[1L], "Below Lower Bound (MnSq < Lower)", "Within Bounds")
    )
    bands <- c("Within Bounds", "Below Lower Bound (MnSq < Lower)", "Above Upper Bound (MnSq > Upper)")
    leg_title <- "MnSq Band (No ZSTD Filter)"
    shapes <- stats::setNames(c(16L, 15L, 17L), bands)
    ltypes <- stats::setNames(c("solid", "dashed", "dotdash"), bands)
  } else {
    z_fin <- is.finite(df$FitZSTD)
    z_pass <- z_fin & (abs(df$FitZSTD) >= zstd_limit)
    out_mnsq <- df$FitMnSq < mnsq_range[1L] | df$FitMnSq > mnsq_range[2L]
    df$FitBand <- ifelse(
      df$FitMnSq > mnsq_range[2L] & z_pass, "Misfit (Unpredictable)",
      ifelse(df$FitMnSq < mnsq_range[1L] & z_pass, "Below Lower Fit Bound",
             ifelse(out_mnsq & !z_fin, "Outside MnSq (ZSTD Unavailable)",
                    ifelse(out_mnsq, "Outside MnSq (|ZSTD| < Limit)", "Acceptable")))
    )
    if (any(!z_fin)) {
      bands <- c("Acceptable", "Outside MnSq (|ZSTD| < Limit)", "Outside MnSq (ZSTD Unavailable)",
                 "Below Lower Fit Bound", "Misfit (Unpredictable)")
      shapes <- stats::setNames(c(16L, 1L, 3L, 15L, 17L), bands)
      ltypes <- stats::setNames(c("solid", "dotted", "twodash", "dashed", "dotdash"), bands)
    } else {
      bands <- c("Acceptable", "Outside MnSq (|ZSTD| < Limit)", "Below Lower Fit Bound", "Misfit (Unpredictable)")
      shapes <- stats::setNames(c(16L, 1L, 15L, 17L), bands)
      ltypes <- stats::setNames(c("solid", "dotted", "dashed", "dotdash"), bands)
    }
    leg_title <- "Fit Screening (MnSq + ZSTD)"
  }
  df$FitBand <- factor(df$FitBand, levels = bands)
  cols <- stats::setNames(.mfrm_cvd_palette(length(bands), palette), bands)

  basis_tag <- if (use_post) "Posterior (TAM Basis)" else "Plug-in"
  x_lbl <- if (length(statistics) == 1L) {
    sprintf("%s Mean-Square (MnSq; %s)", statistics, basis_tag)
  } else {
    sprintf("Mean-Square (MnSq; %s)", basis_tag)
  }

  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$FitMnSq, y = .data$Estimate)) +
    ggplot2::geom_vline(xintercept = 1.0, linetype = "solid", colour = "#999999", linewidth = 0.35) +
    ggplot2::geom_vline(xintercept = mnsq_range, linetype = "dashed", colour = "#666666", linewidth = 0.4) +
    ggplot2::geom_hline(yintercept = 0.0, linetype = "dotted", colour = "#888888", linewidth = 0.35)
  for (rb in ref_list) {
    p <- p + ggplot2::geom_vline(xintercept = rb, linetype = "dotdash", colour = "#888888", linewidth = 0.35)
  }
  p <- p +
    ggplot2::geom_errorbar(
      ggplot2::aes(ymin = .data$Low, ymax = .data$High, colour = .data$FitBand, linetype = .data$FitBand),
      width = 0.0, linewidth = 0.55, alpha = 0.8, na.rm = TRUE
    ) +
    ggplot2::geom_point(
      ggplot2::aes(colour = .data$FitBand, shape = .data$FitBand),
      size = 2.9
    ) +
    ggplot2::geom_text(
      ggplot2::aes(label = .data$Level),
      nudge_y = 0.04 * if (nrow(df)) max(diff(range(df$Estimate)), 0.5) else 0.5,
      size = 2.9, colour = "#222222", check_overlap = TRUE
    ) +
    ggplot2::scale_colour_manual(values = cols, drop = FALSE, name = leg_title) +
    ggplot2::scale_shape_manual(values = shapes, drop = FALSE, name = leg_title) +
    ggplot2::scale_linetype_manual(values = ltypes, drop = FALSE, name = leg_title) +
    ggplot2::labs(x = x_lbl, y = "Measure (Logits)") +
    .mfrm_gg_theme(base_size = base_size)
  if (fit_statistic == "both" && nrow(df)) {
    p <- p + ggplot2::facet_grid(Facet ~ Statistic)
  } else if (length(unique(df$Facet)) > 1L) {
    p <- p + ggplot2::facet_wrap(~ Facet)
  }
  ref_note <- if (length(ref_list)) {
    paste("Dot-dash lines mark secondary reference bounds:",
          paste(vapply(ref_list, function(r) sprintf("[%.2f, %.2f]", r[1L], r[2L]), character(1)), collapse = ", "))
  }
  z_note <- if (is.null(zstd_limit)) {
    "Pathway bands classify by MnSq bounds alone; pass `zstd_limit = 2.0` (or use `plot(wf, type = 'raters')`) to apply the joint MnSq + ZSTD workflow rule."
  } else {
    sprintf("Joint screening rule requires MnSq outside [%.2f, %.2f] and |ZSTD| >= %.1f.", mnsq_range[1L], mnsq_range[2L], zstd_limit)
  }
  z_na_note <- if (!is.null(zstd_limit) && any(!is.finite(df$FitZSTD))) {
    "Elements with unavailable ZSTD (NA) outside MnSq bounds are marked 'Outside MnSq (ZSTD Unavailable)' rather than satisfying the joint MnSq + ZSTD rule."
  }
  attr(p, "mfrm_notes") <- c(
    sprintf("Fit basis: %s. Dashed vertical reference lines mark MnSq bounds [%.2f, %.2f].", basis_tag, mnsq_range[1L], mnsq_range[2L]),
    ref_note,
    z_note,
    z_na_note,
    "Error bars show normal 95% Real-SE intervals (plug-in Infit basis) when available."
  )
  p
}

.mfrm_gg_fit_sensitivity <- function(facets_df, mnsq_range = c(0.70, 1.30), zstd_limit = 2.0,
                                     fit_statistic = c("infit", "outfit"),
                                     fit_method = c("auto", "posterior", "plugin", "both"),
                                     half_widths = seq(0.15, 0.55, by = 0.01),
                                     palette = "okabe_ito", base_size = 11,
                                     method_label = NULL) {
  fit_statistic <- match.arg(fit_statistic)
  fit_method <- match.arg(fit_method)
  mnsq_range <- .mfrm_validate_mnsq_range(mnsq_range)
  if (!is.numeric(zstd_limit) || is.factor(zstd_limit) || length(zstd_limit) != 1L ||
      !is.finite(zstd_limit) || zstd_limit < 0) {
    stop("`zstd_limit` must be a single finite nonnegative number.", call. = FALSE)
  }
  if (!is.numeric(half_widths) || is.factor(half_widths) || length(half_widths) < 2L ||
      any(!is.finite(half_widths)) || any(half_widths <= 0 | half_widths >= 1)) {
    stop("`half_widths` must be finite numbers strictly between 0 and 1 (for symmetric bounds `[1 - d, 1 + d]`).",
         call. = FALSE)
  }
  half_widths <- sort(unique(as.double(half_widths)))
  stat_nm <- tools::toTitleCase(fit_statistic)
  has_post <- (paste0("Post", stat_nm, "MnSq") %in% names(facets_df)) &&
    (identical(method_label, "MML") || any(is.finite(facets_df[[paste0("Post", stat_nm, "MnSq")]])))

  bases <- if (identical(fit_method, "both")) {
    if (!has_post) stop("`fit_method = 'both'` requires an MML calibration with posterior-integrated fit indices.", call. = FALSE)
    c("Posterior (TAM)", "Plug-in")
  } else if (identical(fit_method, "auto") && (is.null(method_label) || identical(method_label, "MML")) && has_post) {
    c("Posterior (TAM)", "Plug-in")
  } else {
    fm <- .mfrm_resolve_fit_method(facets_df, method_label, fit_method)
    if (identical(fm, "posterior")) "Posterior (TAM)" else "Plug-in"
  }

  rule_lvls <- c("Above Upper (MnSq + |ZSTD|)", "Below Lower (MnSq + |ZSTD|)", "Total Outside (MnSq only)")
  rows <- list()
  for (b_lbl in bases) {
    use_p <- identical(b_lbl, "Posterior (TAM)")
    m_vec <- facets_df[[paste0(if (use_p) "Post" else "", stat_nm, "MnSq")]]
    z_col <- paste0(if (use_p) "Post" else "", stat_nm, "ZSTD")
    z_vec <- if (z_col %in% names(facets_df)) facets_df[[z_col]] else rep(NA_real_, length(m_vec))
    ok <- is.finite(m_vec)
    m_v <- m_vec[ok]
    z_v <- z_vec[ok]
    z_cond <- ifelse(is.finite(z_v), abs(z_v) >= zstd_limit, NA)
    n_tot <- length(m_v)
    n_missing <- sum(!ok)
    for (d in half_widths) {
      lo <- 1.0 - d
      hi <- 1.0 + d
      n_hi_z <- sum((m_v > hi) & z_cond)
      n_lo_z <- sum((m_v < lo) & z_cond)
      n_any  <- sum(m_v < lo | m_v > hi)
      n_hi_na <- sum((m_v > hi) & !is.finite(z_v))
      n_lo_na <- sum((m_v < lo) & !is.finite(z_v))
      rows[[length(rows) + 1L]] <- data.frame(
        HalfWidth = rep(d, 3L),
        LowerBound = rep(lo, 3L),
        UpperBound = rep(hi, 3L),
        FitBasis = rep(b_lbl, 3L),
        RuleDirection = rule_lvls,
        FlaggedCount = if (n_tot) c(n_hi_z, n_lo_z, n_any) else rep(NA_integer_, 3L),
        UnavailableMnSqCount = rep(n_missing, 3L),
        UnresolvedZSTDCount = c(n_hi_na, n_lo_na, 0L),
        TotalElements = rep(n_tot, 3L),
        stringsAsFactors = FALSE
      )
    }
  }
  sens_df <- do.call(rbind, rows)
  has_counts <- any(is.finite(sens_df$FlaggedCount))
  sens_df$FitBasis <- factor(sens_df$FitBasis, levels = bases)
  sens_df$RuleDirection <- factor(sens_df$RuleDirection, levels = rule_lvls)

  anchors <- sens_df[round(sens_df$HalfWidth, 4) %in% round(c(0.20, 0.30, 0.40, 0.50), 4), , drop = FALSE]
  cols <- stats::setNames(.mfrm_cvd_palette(3L, palette), rule_lvls)
  ltypes <- stats::setNames(c("solid", "dashed", "dotdash"), rule_lvls)
  shapes <- stats::setNames(c(17L, 15L, 16L), rule_lvls)
  active_hw <- if (abs((mnsq_range[1L] + mnsq_range[2L]) / 2 - 1.0) < 1e-6) (mnsq_range[2L] - 1.0) else NULL

  p <- ggplot2::ggplot(sens_df, ggplot2::aes(
    x = .data$HalfWidth, y = .data$FlaggedCount,
    colour = .data$RuleDirection, linetype = .data$RuleDirection
  )) +
    ggplot2::geom_vline(xintercept = c(0.20, 0.50), linetype = "dotted", colour = "#888888", linewidth = 0.35) +
    ggplot2::geom_step(linewidth = 0.75, direction = "hv", na.rm = TRUE)
  if (!is.null(active_hw)) {
    p <- p + ggplot2::geom_vline(xintercept = active_hw, linetype = "dashed", colour = "#555555", linewidth = 0.45)
  }
  if (nrow(anchors) > 0L) {
    p <- p + ggplot2::geom_point(
      data = anchors,
      ggplot2::aes(shape = .data$RuleDirection),
      size = 2.4,
      na.rm = TRUE
    )
  }
  p <- p +
    ggplot2::scale_colour_manual(values = cols, drop = FALSE, name = "Screening Rule") +
    ggplot2::scale_linetype_manual(values = ltypes, drop = FALSE, name = "Screening Rule") +
    ggplot2::scale_shape_manual(values = shapes, drop = FALSE, name = "Screening Rule") +
    ggplot2::scale_y_continuous(
      limits = if (!has_counts) c(0, 1),
      breaks = if (has_counts) function(lim) unique(floor(pretty(c(0, max(1, lim[2L])))))
    ) +
    ggplot2::labs(
      x = sprintf("Symmetric %s MnSq Half-Width d around 1.00 (Bounds [1 - d, 1 + d])", stat_nm),
      y = "Flagged Element Count"
    ) +
    .mfrm_gg_theme(base_size = base_size)
  if (length(bases) > 1L) {
    p <- p + ggplot2::facet_wrap(~ FitBasis)
  }
  attr(p, "sensitivity_table") <- sens_df
  attr(p, "mfrm_notes") <- c(
    sprintf("Evaluates symmetric %s MnSq intervals [1 - d, 1 + d] with |ZSTD| >= %.1f.", stat_nm, zstd_limit),
    "Reference half-widths mark d = 0.20 ([0.80, 1.20]), d = 0.30 ([0.70, 1.30]), and d = 0.50 ([0.50, 1.50]).",
    if (any(sens_df$UnavailableMnSqCount > 0L))
      "Counts cover elements with finite MnSq. UnavailableMnSqCount gives the number excluded.",
    if (any(sens_df$UnresolvedZSTDCount > 0L))
      "Joint MnSq + |ZSTD| counts are NA where an element outside [1 - d, 1 + d] has unavailable ZSTD (see `UnresolvedZSTDCount` in `sensitivity_table`).",
    "Select screening bounds from substantive stakes and rating design prior to inspection; do not tune thresholds post hoc to suppress flags."
  )
  p
}

.mfrm_gg_cut_sensitivity <- function(fit_obj, cut_scores = NULL, cut_grid = NULL,
                                     palette = "okabe_ito", base_size = 11) {
  rmin <- fit_obj$rating_min
  rmax <- fit_obj$rating_max
  span <- rmax - rmin
  if (is.null(cut_grid)) {
    lo <- rmin + 0.04 * span
    hi <- rmax - 0.04 * span
    cut_grid <- seq(lo, hi, length.out = 41L)
    if (!is.null(cut_scores)) {
      valid_cs <- as.double(cut_scores[is.finite(cut_scores) & cut_scores > rmin & cut_scores < rmax])
      cut_grid <- sort(unique(c(cut_grid, valid_cs)))
    }
  } else {
    if (!is.numeric(cut_grid) || is.factor(cut_grid) || length(cut_grid) < 1L || any(!is.finite(cut_grid))) {
      stop("`cut_grid` must be a non-empty finite numeric vector of candidate Fair(M) cutoffs.", call. = FALSE)
    }
    cut_grid <- sort(unique(as.double(cut_grid)))
  }
  readiness <- summary(fit_obj)$readiness
  dec <- as.data.frame(.tidymfrm_cut_decisions(fit_obj, cut_grid, readiness = readiness))

  p1_lbl <- "1. Pass Rate (%)"
  p2_lbl <- "2. Borderline Count (90% Interval Straddling Cut)"
  s_lvls <- c("Pass Rate (Fair(M) >= Cut)", "Borderline (ModelSE)", "Borderline (RealSE)")
  long_df <- rbind(
    data.frame(Panel = p1_lbl, CutFairM = dec$CutFairM, Series = s_lvls[1L],
               Value = dec$PassRatePct, stringsAsFactors = FALSE),
    data.frame(Panel = p2_lbl, CutFairM = dec$CutFairM, Series = s_lvls[2L],
               Value = as.double(dec$Borderline90_ModelSE), stringsAsFactors = FALSE),
    data.frame(Panel = p2_lbl, CutFairM = dec$CutFairM, Series = s_lvls[3L],
               Value = as.double(dec$Borderline90_RealSE), stringsAsFactors = FALSE)
  )
  long_df$Panel <- factor(long_df$Panel, levels = c(p1_lbl, p2_lbl))
  long_df$Series <- factor(long_df$Series, levels = s_lvls)

  cols <- stats::setNames(.mfrm_cvd_palette(3L, palette), s_lvls)
  ltypes <- stats::setNames(c("solid", "dashed", "dotdash"), s_lvls)
  shapes <- stats::setNames(c(16L, 17L, 15L), s_lvls)

  mark_idx <- unique(round(seq(1, nrow(dec), length.out = min(7L, nrow(dec)))))
  mark_cuts <- dec$CutFairM[mark_idx]
  pts_df <- long_df[long_df$CutFairM %in% mark_cuts & is.finite(long_df$Value), , drop = FALSE]

  p <- ggplot2::ggplot(long_df, ggplot2::aes(
    x = .data$CutFairM, y = .data$Value,
    colour = .data$Series, linetype = .data$Series
  )) +
    ggplot2::geom_line(linewidth = 0.8, na.rm = TRUE)
  if (nrow(pts_df) > 0L) {
    p <- p + ggplot2::geom_point(
      data = pts_df,
      ggplot2::aes(shape = .data$Series),
      size = 2.3, na.rm = TRUE
    )
  }
  if (!is.null(cut_scores) && any(is.finite(cut_scores))) {
    p <- p + ggplot2::geom_vline(
      xintercept = as.double(cut_scores[is.finite(cut_scores)]),
      linetype = "dashed", colour = "#555555", linewidth = 0.45
    )
  }
  p <- p +
    ggplot2::facet_wrap(~ Panel, ncol = 1L, scales = "free_y") +
    ggplot2::scale_colour_manual(values = cols, drop = FALSE, name = "Decision Metric") +
    ggplot2::scale_linetype_manual(values = ltypes, drop = FALSE, name = "Decision Metric") +
    ggplot2::scale_shape_manual(values = shapes, drop = FALSE, name = "Decision Metric") +
    ggplot2::labs(x = "Candidate Fair(M) Cutoff (Rubric Scale)", y = "Percentage / Examinee Count") +
    .mfrm_gg_theme(base_size = base_size)

  attr(p, "cut_table") <- dec
  attr(p, "mfrm_notes") <- c(
    "Pass rate is descriptive (Fair(M) >= Cut). Borderline counts tally examinees with 0.05 < P(theta > theta_cut) < 0.95 under conditional normal ModelSE vs RealSE.",
    if (!is.null(cut_scores) && any(is.finite(cut_scores)))
      sprintf("Vertical dashed lines mark declared Fair(M) cutoffs: %s.",
              paste(format(cut_scores[is.finite(cut_scores)], trim = TRUE), collapse = ", ")),
    if (!readiness$ready)
      paste("Borderline interval counts withheld:", paste(readiness$reason_codes, collapse = "; "))
  )
  p
}

.mfrm_gg_ccc <- function(step_cum, steps_df, rating_min, step_cat_min, step_cat_max,
                         slopes_df = NULL, step_facet = NULL, slope_formula = 0L,
                         palette = "okabe_ito", base_size = 11) {
  C <- ncol(step_cum)
  n_sg <- nrow(step_cum)
  sg_names <- unique(steps_df$ScaleLevel)
  if (length(sg_names) != n_sg) sg_names <- paste0("Group_", seq_len(n_sg))
  cat_labels <- as.character(rating_min + seq(0L, C - 1L))
  theta_grid <- seq(-4.5, 4.5, length.out = 121L)

  rows <- vector("list", n_sg)
  for (g in seq_len(n_sg)) {
    a_g <- 1.0
    if (!is.null(slopes_df) && nrow(slopes_df) > 0L && !is.null(step_facet)) {
      sl_hit <- slopes_df[slopes_df$Facet == step_facet & slopes_df$Level == sg_names[g], , drop = FALSE]
      if (nrow(sl_hit) == 1L && is.finite(sl_hit$Estimate[1L])) a_g <- sl_hit$Estimate[1L]
    }
    ev <- .mfrm_eval_row_predictions(
      eta_vec = theta_grid,
      step_cum = step_cum,
      step_group0 = rep(g - 1L, length(theta_grid)),
      step_cat_min = step_cat_min,
      step_cat_max = step_cat_max,
      rating_min = rating_min,
      alpha_vec = if (!is.null(slopes_df) && nrow(slopes_df) > 0L) rep(a_g, length(theta_grid)) else NULL,
      theta_vec = theta_grid,
      base_eta_vec = numeric(length(theta_grid)),
      slope_formula = slope_formula
    )
    df_g <- expand.grid(ThetaIdx = seq_along(theta_grid), CatIdx = seq_len(C), KEEP.OUT.ATTRS = FALSE)
    df_g$ScaleGroup <- sg_names[g]
    df_g$LinearMeasure <- theta_grid[df_g$ThetaIdx]
    df_g$Category <- factor(cat_labels[df_g$CatIdx], levels = cat_labels)
    df_g$Probability <- as.numeric(ev$probs)
    rows[[g]] <- df_g
  }
  ccc_df <- do.call(rbind, rows)
  # Subsample points along theta so distinct point shapes reinforce linetypes
  pts_df <- ccc_df[ccc_df$ThetaIdx %in% seq(1L, length(theta_grid), by = 15L), , drop = FALSE]

  cols <- stats::setNames(.mfrm_cvd_palette(C, palette), cat_labels)
  ltypes <- stats::setNames(.mfrm_cvd_linetypes(C), cat_labels)
  shapes <- stats::setNames(.mfrm_cvd_shapes(C), cat_labels)

  st_lines <- steps_df[is.finite(steps_df$Estimate), , drop = FALSE]
  st_lines$ScaleGroup <- st_lines$ScaleLevel

  p <- ggplot2::ggplot(
    ccc_df,
    ggplot2::aes(x = .data$LinearMeasure, y = .data$Probability,
                 colour = .data$Category, linetype = .data$Category)
  ) +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::geom_point(
      data = pts_df,
      ggplot2::aes(shape = .data$Category),
      size = 2.0
    ) +
    ggplot2::geom_vline(
      data = st_lines,
      ggplot2::aes(xintercept = .data$Estimate),
      linetype = "dotted", colour = "#666666", linewidth = 0.4
    ) +
    ggplot2::scale_colour_manual(values = cols, name = "Category") +
    ggplot2::scale_linetype_manual(values = ltypes, name = "Category") +
    ggplot2::scale_shape_manual(values = shapes, name = "Category") +
    ggplot2::scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, by = 0.25)) +
    ggplot2::labs(x = "Latent Measure Relative to Element Location (Logits)",
                  y = "Category Response Probability") +
    .mfrm_gg_theme(base_size = base_size)
  if (n_sg > 1L) p <- p + ggplot2::facet_wrap(~ ScaleGroup)
  attr(p, "mfrm_notes") <- "Categories are redundantly encoded by colour, linetype, and marker shape."
  p
}

.mfrm_gg_person_fit <- function(fit_obj, palette = "okabe_ito", base_size = 11, pfi = NULL) {
  if (is.null(pfi)) pfi <- compute_person_fit_indices(fit_obj)
  df <- as.data.frame(pfi)
  df <- df[is.finite(df$OutfitMnSq) & is.finite(df$ReportValue), , drop = FALSE]
  lvls <- c("Not flagged", "Outfit > 1.50", "Person-fit flag", "Both flagged")
  st_chr <- ifelse(df$OutfitMnSq > 1.50 & df$ReportFlag, "Both flagged",
    ifelse(df$ReportFlag, "Person-fit flag", ifelse(df$OutfitMnSq > 1.50, "Outfit > 1.50", "Not flagged")))
  df$Status <- factor(st_chr, levels = lvls)
  cols <- stats::setNames(.mfrm_cvd_palette(4L, palette), lvls)
  shapes <- stats::setNames(c(16L, 17L, 15L, 8L), lvls)
  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$OutfitMnSq, y = .data$ReportValue)) +
    ggplot2::geom_vline(xintercept = 1.50, linetype = "dashed", colour = "#666666", linewidth = 0.45) +
    ggplot2::geom_hline(yintercept = c(-1, 1) * stats::qnorm(.975), linetype = "dotdash", colour = "#666666", linewidth = 0.45) +
    ggplot2::geom_point(ggplot2::aes(colour = .data$Status, shape = .data$Status), size = 2.6, alpha = 0.9) +
    ggplot2::scale_colour_manual(values = cols, drop = FALSE, name = "Person Fit") +
    ggplot2::scale_shape_manual(values = shapes, drop = FALSE, name = "Person Fit") +
    ggplot2::labs(x = "Person Outfit Mean-Square (MnSq)", y = "Reported person-fit index (lz* or lz)") +
    .mfrm_gg_theme(base_size = base_size)
  attr(p, "mfrm_notes") <- c(
    "Uses the same ReportIndex, ReportValue and two-sided normal-reference flags as summary(compute_person_fit_indices(fit)).",
    "These screening cutoffs do not provide calibrated false-positive rates. Outfit > 1.50 is shown separately.",
    unique(pfi$ReportCaveat))
  p
}

.mfrm_gg_residual_qq <- function(fit_obj, palette = "okabe_ito", base_size = 11) {
  z_vec <- stats::residuals(fit_obj, type = "pearson")
  z_vec <- sort(z_vec[is.finite(z_vec)])
  n <- length(z_vec)
  if (n < 2L) stop("Insufficient finite standardized residuals for Q-Q plot.", call. = FALSE)
  pp <- (seq_len(n) - 0.5) / n
  theo <- stats::qnorm(pp)
  se_env <- sqrt(pp * (1.0 - pp) / n) / pmax(1e-8, stats::dnorm(theo))
  lvls <- c("|z| < 2.0", "|z| >= 2.0")
  df <- data.frame(
    Theoretical = theo,
    Observed = z_vec,
    EnvLow = theo - 1.96 * se_env,
    EnvHigh = theo + 1.96 * se_env,
    Band = factor(ifelse(abs(z_vec) >= 2.0, "|z| >= 2.0", "|z| < 2.0"), levels = lvls)
  )
  cols <- stats::setNames(.mfrm_cvd_palette(2L, palette), lvls)
  shapes <- stats::setNames(c(16L, 17L), lvls)

  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$Theoretical, y = .data$Observed)) +
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = .data$EnvLow, ymax = .data$EnvHigh),
      fill = "#CCCCCC", alpha = 0.28, colour = "#888888", linetype = "dotted", linewidth = 0.35
    ) +
    ggplot2::geom_abline(intercept = 0.0, slope = 1.0, linetype = "dashed", colour = "#555555", linewidth = 0.45) +
    ggplot2::geom_point(ggplot2::aes(colour = .data$Band, shape = .data$Band), size = 1.9, alpha = 0.85) +
    ggplot2::scale_colour_manual(values = cols, drop = FALSE, name = "Residual Tail") +
    ggplot2::scale_shape_manual(values = shapes, drop = FALSE, name = "Residual Tail") +
    ggplot2::labs(x = "Theoretical Standard Normal Quantiles", y = "Standardized Response Residuals (z)") +
    .mfrm_gg_theme(base_size = base_size)
  attr(p, "mfrm_notes") <- "Dotted band shows pointwise 95% normal order-statistic reference envelope; colour and shape distinguish |z| >= 2.0."
  p
}

.mfrm_gg_slopes <- function(slopes_df, palette = "okabe_ito", base_size = 11, intervals = NULL) {
  if (is.null(slopes_df) || nrow(slopes_df) == 0L) {
    stop("`type = 'slopes'` requires a fitted GMFRM (`model = 'GPCM'`) with estimated discrimination parameters.", call. = FALSE)
  }
  keep <- is.finite(slopes_df$Estimate)
  df <- slopes_df[keep, , drop = FALSE]
  df$Low <- if (is.null(intervals)) pmax(0.0, df$Estimate - 1.96 * df$ModelSE) else intervals[keep, 1L]
  df$High <- if (is.null(intervals)) df$Estimate + 1.96 * df$ModelSE else intervals[keep, 2L]
  lvls <- c("Low (< 0.80)", "Moderate (0.80 - 1.25)", "High (> 1.25)")
  df$Band <- factor(
    ifelse(df$Estimate < 0.80, "Low (< 0.80)", ifelse(df$Estimate > 1.25, "High (> 1.25)", "Moderate (0.80 - 1.25)")),
    levels = lvls
  )
  df$Elem <- factor(df$Level, levels = rev(unique(df$Level)))
  cols <- stats::setNames(.mfrm_cvd_palette(3L, palette), lvls)
  shapes <- stats::setNames(c(15L, 16L, 17L), lvls)
  ltypes <- stats::setNames(c("dashed", "solid", "dotdash"), lvls)

  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$Estimate, y = .data$Elem)) +
    ggplot2::geom_vline(xintercept = 1.0, linetype = "dotted", colour = "#666666", linewidth = 0.45) +
    ggplot2::geom_errorbar(
      ggplot2::aes(xmin = .data$Low, xmax = .data$High, colour = .data$Band, linetype = .data$Band),
      orientation = "y", width = 0.0, linewidth = 0.6
    ) +
    ggplot2::geom_point(ggplot2::aes(colour = .data$Band, shape = .data$Band), size = 2.8) +
    ggplot2::scale_colour_manual(values = cols, drop = FALSE, name = "Discrimination") +
    ggplot2::scale_shape_manual(values = shapes, drop = FALSE, name = "Discrimination") +
    ggplot2::scale_linetype_manual(values = ltypes, drop = FALSE, name = "Discrimination") +
    ggplot2::labs(x = "Discrimination Parameter Alpha (95% Model-SE CI)", y = NULL) +
    .mfrm_gg_theme(base_size = base_size)
  if (length(unique(df$Facet)) > 1L) p <- p + ggplot2::facet_wrap(~ Facet, scales = "free_y")
  attr(p, "mfrm_notes") <- "Reference line at alpha = 1.0 denotes equal-slope Rasch discrimination; colour, shape, and linetype encode discrimination band."
  p
}

.mfrm_gg_qc <- function(fit_obj, palette = "okabe_ito", base_size = 11) {
  fc <- fit_obj$facets[is.finite(fit_obj$facets$InfitMnSq), , drop = FALSE]
  pt <- fit_obj$person[is.finite(fit_obj$person$InfitMnSq), , drop = FALSE]
  st <- fit_obj$steps[is.finite(fit_obj$steps$Estimate), , drop = FALSE]
  zr <- stats::residuals(fit_obj, type = "pearson")
  zr <- zr[is.finite(zr)]

  lvls <- c("Within Reference", "Flagged")
  d1 <- data.frame(
    Panel = "1. Facet Infit MnSq",
    X = seq_len(nrow(fc)),
    Y = fc$InfitMnSq,
    Status = ifelse(fc$InfitMnSq < 0.70 | fc$InfitMnSq > 1.30, "Flagged", "Within Reference"),
    stringsAsFactors = FALSE
  )
  d2 <- data.frame(
    Panel = "2. Person Outfit MnSq",
    X = pt$Estimate,
    Y = pt$OutfitMnSq,
    Status = ifelse(pt$OutfitMnSq > 1.50, "Flagged", "Within Reference"),
    stringsAsFactors = FALSE
  )
  d3 <- if (nrow(st) > 0L) {
    dis_vec <- ave(st$Estimate, st$ScaleLevel, FUN = function(v) {
      if (length(v) < 2L) FALSE else c(FALSE, diff(v) < 0)
    })
    data.frame(
      Panel = "3. Step Thresholds (Logits)",
      X = seq_len(nrow(st)),
      Y = st$Estimate,
      Status = ifelse(dis_vec > 0, "Flagged", "Within Reference"),
      stringsAsFactors = FALSE
    )
  } else {
    data.frame(Panel = character(0), X = numeric(0), Y = numeric(0), Status = character(0))
  }
  pp <- (seq_along(zr) - 0.5) / max(1L, length(zr))
  d4 <- data.frame(
    Panel = "4. Residual Q-Q",
    X = stats::qnorm(pp),
    Y = sort(zr),
    Status = ifelse(abs(sort(zr)) >= 2.0, "Flagged", "Within Reference"),
    stringsAsFactors = FALSE
  )
  all_qc <- rbind(d1, d2, d3, d4)
  all_qc$Status <- factor(all_qc$Status, levels = lvls)
  all_qc$Panel <- factor(all_qc$Panel, levels = unique(all_qc$Panel))
  cols <- stats::setNames(.mfrm_cvd_palette(2L, palette), lvls)
  shapes <- stats::setNames(c(16L, 17L), lvls)

  p <- ggplot2::ggplot(all_qc, ggplot2::aes(x = .data$X, y = .data$Y)) +
    ggplot2::geom_point(ggplot2::aes(colour = .data$Status, shape = .data$Status), size = 2.0, alpha = 0.85) +
    ggplot2::facet_wrap(~ Panel, scales = "free") +
    ggplot2::scale_colour_manual(values = cols, drop = FALSE, name = "QC Screening") +
    ggplot2::scale_shape_manual(values = shapes, drop = FALSE, name = "QC Screening") +
    ggplot2::labs(x = "Index / Latent Scale / Quantile", y = "Diagnostic Statistic") +
    .mfrm_gg_theme(base_size = base_size)
  attr(p, "mfrm_notes") <- "Four-panel quality-control summary; screening status is encoded by colour and point shape."
  p
}

#' Plot Many-Facet Rasch Models and Diagnostics with Color-Vision-Safe ggplot2
#'
#' Unified `ggplot2` visualization entry point for fitted MFRM models, G-Studies,
#' D-Studies, pairwise bias analyses, DFF screens, test information curves, and
#' rater drift trajectories. Every plot supports `"okabe_ito"`, `"viridis"`, and
#' strict `"monochrome"` (`R == G == B`) palettes paired with distinct point
#' `shape` and `linetype` encodings.
#'
#' @param x A fitted `mfrm_fit`, `mfrm_gtheory`, `mfrm_bias`, `mfrm_dff`,
#'   `mfrm_information`, or `mfrm_drift` object.
#' @param type Plot type (`"wright"`, `"pathway"`, `"steps"`, `"persons"`, `"raters"`, etc.).
#' @param palette Color palette: `"okabe_ito"` (default), `"viridis"`, or `"monochrome"`.
#' @param facet Optional facet name to filter `"pathway"` or `"raters"`.
#' @param base_size Base font size in pts (default `11`).
#' @param ... For Wright maps choose `person_display` ("histogram", "density", or "stars"),
#'   `persons_per_star` (default 3 in star mode), `binwidth`, or `yardstick`
#'   (rows per logit or a list with lines and range). Bars extend left from zero.
#'   The right-hand Fair average ruler uses the pooled step-group mix. Supply
#'   `reference_plan` as in [fair_average_table()] for a specified common panel
#'   or `fair_average = FALSE` to hide it. See `attr(p, "mfrm_fair_average")` for tick values.
#' @param interactive Return a Plotly widget for a Wright map, category curves, rater/pathway or fit-sensitivity plot.
#' @param fit_statistic Mean-square statistic displayed on the pathway plot.
#'   Use `"both"` to display Infit and Outfit in separate panels.
#' @return A ggplot or, with `interactive = TRUE`, a Plotly widget with interpretation notes in `attr(p, "mfrm_notes")`.
#' @export
plot.mfrm_fit <- function(x, type = c("wright", "pathway", "steps", "category_curves", "persons", "raters",
    "person_fit", "residual_qq", "slopes", "qc", "fit_sensitivity", "cut_sensitivity"),
    palette = c("okabe_ito", "viridis", "monochrome"), facet = NULL,
    base_size = 11, ..., fit_statistic = c("infit", "outfit", "both"), interactive = FALSE) {
    .mfrm_validate_fit(x)
    type <- match.arg(type)
    palette <- match.arg(palette)
    if (isTRUE(interactive)) {
        if (!type %in% .mfrm_interactive_types)
            stop("Interactive plots support: ", paste(.mfrm_interactive_types, collapse = ", "), ".", call. = FALSE)
        p <- plot.mfrm_fit(x, type, palette, facet, base_size, ..., fit_statistic = match.arg(fit_statistic))
        return(.mfrm_plotly(p, type))
    }
    dots <- list(...)
    interval_ready <- TRUE
    plot_notes <- character()
    if (type %in% c("wright", "qc", "steps", "category_curves")) {
        x <- .mfrm_refresh_steps(x)
        held <- x$steps$Supported & !x$steps$Identified
        withheld_groups <- unique(x$steps$ScaleLevel[held])
        if (length(withheld_groups)) {
            plot_notes <- paste("Unidentified step thresholds withheld for",
                                    paste(withheld_groups, collapse = ", "))
        }
    }
    if (type %in% c("pathway", "raters", "persons", "slopes")) {
        readiness <- .mfrm_readiness(x)
        interval_ready <- readiness$ready
        if (!interval_ready) {
            plot_notes <- paste0("Intervals unavailable: ", paste(readiness$reason_codes, collapse = ", "),
                ". Points are descriptive estimates requiring review.")
            for (component in c("person", "facets", "slopes")) {
                if (is.data.frame(x[[component]]))
                  for (se in intersect(c("ModelSE", "RealSE"), names(x[[component]]))) x[[component]][[se]] <- NA_real_
            }
        }
    }
    with_plot_notes <- function(p) {
        attr(p, "mfrm_notes") <- c(attr(p, "mfrm_notes"), plot_notes)
        p
    }
    if (identical(type, "wright")) {
        return(with_plot_notes(.mfrm_gg_wright(x, palette, base_size,
            dots$person_display %||% "histogram", dots$binwidth, dots$newdata, dots$persons_per_star, dots$yardstick,
            dots$fair_average %||% TRUE, dots$reference_plan)))
    }
    if (type %in% c("pathway", "raters")) {
        fc <- x$facets
        if ("MLEEstimate" %in% names(fc)) {
            fc$ModelSE <- fc$RealSE <- NA_real_
            if (interval_ready)
                plot_notes <- c(plot_notes, "Intervals unavailable: empirical_bayes_facet_shrinkage.")
        }
        if (identical(type, "raters") && is.null(facet)) {
            hit <- grep("rater|judge|examiner|marker|grader", unique(fc$Facet), ignore.case = TRUE, value = TRUE)
            facet <- if (length(hit) > 0L)
                hit[1L]
            else unique(fc$Facet)[1L]
        }
        if (!is.null(facet))
            fc <- fc[fc$Facet %in% facet, , drop = FALSE]
        return(with_plot_notes(.mfrm_gg_pathway(
            fc,
            mnsq_range = dots$mnsq_range %||% c(0.70, 1.30),
            palette = palette,
            base_size = base_size,
            fit_statistic = match.arg(fit_statistic),
            fit_method = dots$fit_method %||% "auto",
            zstd_limit = dots$zstd_limit,
            reference_bands = dots$reference_bands,
            method_label = x$method
        )))
    }
    if (identical(type, "fit_sensitivity")) {
        fc <- x$facets
        if (!is.null(facet))
            fc <- fc[fc$Facet %in% facet, , drop = FALSE]
        fs_arg <- if (missing(fit_statistic)) "infit" else match.arg(fit_statistic[1L], c("infit", "outfit"))
        return(.mfrm_gg_fit_sensitivity(
            fc,
            mnsq_range = dots$mnsq_range %||% c(0.70, 1.30),
            zstd_limit = dots$zstd_limit %||% 2.0,
            fit_statistic = fs_arg,
            fit_method = dots$fit_method %||% "auto",
            half_widths = dots$half_widths %||% seq(0.15, 0.55, by = 0.01),
            palette = palette,
            base_size = base_size,
            method_label = x$method
        ))
    }
    if (identical(type, "cut_sensitivity")) {
        return(.mfrm_gg_cut_sensitivity(
            x,
            cut_scores = dots$cut_scores,
            cut_grid = dots$cut_grid,
            palette = palette,
            base_size = base_size
        ))
    }
    if (type %in% c("steps", "category_curves")) {
        if (!is.null(dots$newdata)) return(.mfrm_plot_context_curves(x, dots$newdata, palette, base_size))
        owners <- x$encoding$step_owners
        keep <- !owners %in% withheld_groups
        if (!any(keep)) return(with_plot_notes(ggplot2::ggplot() + ggplot2::theme_void()))
        p <- .mfrm_gg_ccc(x$step_cumulative[keep, , drop = FALSE],
            x$steps[x$steps$ScaleLevel %in% owners[keep], , drop = FALSE], x$rating_min,
            x$encoding$step_cat_min[keep], x$encoding$step_cat_max[keep],
            slopes_df = x$slopes, step_facet = x$encoding$step_facet, slope_formula = x$encoding$slope_formula %||%
                0L, palette = palette, base_size = base_size)
        return(with_plot_notes(p))
    }
    if (identical(type, "person_fit")) {
        return(.mfrm_gg_person_fit(x, palette = palette, base_size = base_size))
    }
    if (identical(type, "residual_qq")) {
        return(.mfrm_gg_residual_qq(x, palette = palette, base_size = base_size))
    }
    if (identical(type, "slopes")) {
        ci <- if (interval_ready)
            stats::confint(x, component = "slopes")
        else matrix(NA_real_, NROW(x$slopes), 2L)
        return(with_plot_notes(.mfrm_gg_slopes(x$slopes, palette = palette, base_size = base_size, intervals = ci)))
    }
    if (identical(type, "qc")) {
        return(with_plot_notes(.mfrm_gg_qc(x, palette = palette, base_size = base_size)))
    }
    pt <- x$person[is.finite(x$person$Estimate) & is.finite(x$person$FairM), , drop = FALSE]
    pt$Low <- pt$Estimate - 1.96 * pt$RealSE
    pt$High <- pt$Estimate + 1.96 * pt$RealSE
    pt$Band <- factor(ifelse(is.finite(pt$InfitMnSq) & pt$InfitMnSq > 1.3, "Infit MnSq > 1.30", "Infit MnSq <= 1.30"),
        levels = c("Infit MnSq <= 1.30", "Infit MnSq > 1.30"))
    cols <- stats::setNames(.mfrm_cvd_palette(2L, palette), levels(pt$Band))
    p <- ggplot2::ggplot(pt, ggplot2::aes(x = .data$Estimate, y = .data$FairM)) + ggplot2::geom_errorbar(ggplot2::aes(xmin = .data$Low,
        xmax = .data$High, colour = .data$Band, linetype = .data$Band), orientation = "y", width = 0, alpha = 0.65,
        linewidth = 0.45) + ggplot2::geom_point(ggplot2::aes(colour = .data$Band, shape = .data$Band), size = 2.3) +
        ggplot2::scale_colour_manual(values = cols, drop = FALSE, name = "Person Fit") + ggplot2::scale_shape_manual(values = c(`Infit MnSq <= 1.30` = 16L,
        `Infit MnSq > 1.30` = 17L), drop = FALSE, name = "Person Fit") + ggplot2::scale_linetype_manual(values = c(`Infit MnSq <= 1.30` = "solid",
        `Infit MnSq > 1.30` = "dashed"), drop = FALSE, name = "Person Fit") + ggplot2::labs(x = "Person Ability (Logits; 95% Real-SE CI)",
        y = "Fair Average Score Fair(M)") + .mfrm_gg_theme(base_size = base_size)
    if (!is.null(dots$cut_scores) && any(is.finite(dots$cut_scores))) {
        p <- p + ggplot2::geom_hline(
            yintercept = as.double(dots$cut_scores[is.finite(dots$cut_scores)]),
            linetype = "dashed", colour = "#555555", linewidth = 0.45
        )
    }
    attr(p, "mfrm_notes") <- "Person fit status is encoded via colour, point shape, and interval linetype."
    with_plot_notes(p)
}

#' @rdname plot.mfrm_fit
#' @export

#' @rdname plot.mfrm_fit
#' @export
plot.mfrm_diagnostics <- function(x,
                                  facet = NULL,
                                  palette = c("okabe_ito", "viridis", "monochrome"),
                                  base_size = 11,
                                  ..., type = c("pathway", "residual_pca", "fit_sensitivity")) {
  palette <- match.arg(palette)
  type <- match.arg(type)
  dots <- list(...)
  if (type == "residual_pca") {
    if (length(facet) > 1L) stop("Choose one facet for the residual PCA plot.", call. = FALSE)
    result <- if (is.null(facet)) x$residual_pca_overall else x$residual_pca_by_facet[[facet]]
    if (is.null(result)) stop("Request residual PCA in diagnose_mfrm() for the plotted grouping.", call. = FALSE)
    if (!is.null(result$error)) stop(result$error, call. = FALSE)
    loadings <- as.matrix(result$pca$loadings)
    d <- data.frame(Level = rownames(loadings), Loading = loadings[, 1L])
    d$Level <- stats::reorder(d$Level, d$Loading)
    p <- ggplot2::ggplot(d, ggplot2::aes(x = .data$Loading, y = .data$Level)) +
      ggplot2::geom_vline(xintercept = 0, color = "grey65") +
      ggplot2::geom_point(shape = 16, color = .mfrm_cvd_palette(1L, palette), size = 2.8) +
      ggplot2::labs(x = "Loading on first residual contrast", y = facet) +
      .mfrm_gg_theme(base_size = base_size)
    overlap <- crossprod(is.finite(as.matrix(result$residual_matrix)) * 1L)
    attr(p, "mfrm_notes") <- c(
      sprintf("First contrast eigenvalue: %.2f. Pairwise shared persons: %d\u2013%d.",
              result$pca$values[1L], min(overlap[upper.tri(overlap)]), max(overlap[upper.tri(overlap)])),
      "Exploratory PCA of averaged standardized residuals. Contrast signs are arbitrary.",
      result$warning
    )
    return(p)
  }
  readiness <- .mfrm_readiness(x$fit)
  ms <- as.data.frame(x$measures)
  if ("Infit" %in% names(ms) && !"InfitMnSq" %in% names(ms)) ms$InfitMnSq <- ms$Infit
  if ("Outfit" %in% names(ms) && !"OutfitMnSq" %in% names(ms)) ms$OutfitMnSq <- ms$Outfit
  if ("PostInfit" %in% names(ms) && !"PostInfitMnSq" %in% names(ms)) ms$PostInfitMnSq <- ms$PostInfit
  if ("PostOutfit" %in% names(ms) && !"PostOutfitMnSq" %in% names(ms)) ms$PostOutfitMnSq <- ms$PostOutfit
  ms <- ms[ms$Facet != "Person", , drop = FALSE]
  if (!is.null(facet)) ms <- ms[ms$Facet %in% facet, , drop = FALSE]
  if (identical(type, "fit_sensitivity")) {
    return(.mfrm_gg_fit_sensitivity(
      ms,
      mnsq_range = dots$mnsq_range %||% x$mnsq_range %||% c(0.70, 1.30),
      zstd_limit = dots$zstd_limit %||% 2.0,
      fit_statistic = dots$fit_statistic %||% "infit",
      fit_method = dots$fit_method %||% x$fit_method %||% "auto",
      half_widths = dots$half_widths %||% seq(0.15, 0.55, by = 0.01),
      palette = palette,
      base_size = base_size,
      method_label = x$fit$method
    ))
  }
  eb_shrunk <- "MLEEstimate" %in% names(x$fit$facets)
  if (!readiness$ready || eb_shrunk) ms$ModelSE <- ms$RealSE <- NA_real_
  p <- .mfrm_gg_pathway(
    ms,
    mnsq_range = dots$mnsq_range %||% x$mnsq_range %||% c(0.70, 1.30),
    palette = palette,
    base_size = base_size,
    fit_statistic = dots$fit_statistic %||% "infit",
    fit_method = dots$fit_method %||% x$fit_method %||% "auto",
    zstd_limit = dots$zstd_limit,
    reference_bands = dots$reference_bands,
    method_label = x$fit$method
  )
  if (!readiness$ready) attr(p, "mfrm_notes") <- c(attr(p, "mfrm_notes"),
    paste("Intervals unavailable:", paste(readiness$reason_codes, collapse = "; ")))
  else if (eb_shrunk) attr(p, "mfrm_notes") <- c(attr(p, "mfrm_notes"),
    "Intervals unavailable: empirical_bayes_facet_shrinkage.")
  p
}

#' @rdname plot.mfrm_fit
#' @export
.mfrm_gstudy_plot_henderson <- function(x,
                                   type = c("dstudy", "variance"),
                                   palette = c("okabe_ito", "viridis", "monochrome"),
                                   base_size = 11,
                                   ...) {
  x <- .mfrm_refresh_gstudy(x)
  type <- match.arg(type)
  palette <- match.arg(palette)
  if (identical(type, "variance")) {
    vc <- x$variance_components
    vc$CompOrder <- factor(vc$Component, levels = rev(vc$Component))
    vc$Role <- factor(ifelse(vc$ContainsPerson, "Universe / Relative", "Facet Main / Absolute"),
                      levels = c("Universe / Relative", "Facet Main / Absolute"))
    cols <- stats::setNames(.mfrm_cvd_palette(2L, palette), levels(vc$Role))
    p <- ggplot2::ggplot(vc, ggplot2::aes(x = .data$PercentVariance, y = .data$CompOrder)) +
      ggplot2::geom_segment(
        ggplot2::aes(x = 0, xend = .data$PercentVariance, y = .data$CompOrder, yend = .data$CompOrder,
                     colour = .data$Role, linetype = .data$Role),
        linewidth = 0.8
      ) +
      ggplot2::geom_point(ggplot2::aes(colour = .data$Role, shape = .data$Role), size = 3.0) +
      ggplot2::scale_colour_manual(values = cols, drop = FALSE, name = "Variance Role") +
      ggplot2::scale_shape_manual(values = c(16L, 17L), drop = FALSE, name = "Variance Role") +
      ggplot2::scale_linetype_manual(values = c("solid", "dashed"), drop = FALSE, name = "Variance Role") +
      ggplot2::labs(x = "Percentage of Total Variance (%)", y = NULL) +
      .mfrm_gg_theme(base_size = base_size)
    attr(p, "mfrm_notes") <- "G-Study variance components estimated via Henderson Method 1 (urGENOVA)."
    return(p)
  }

  ds <- as.data.frame(x$d_study)
  f_cols <- x$facets
  p_f <- f_cols[1L]
  s_f <- if (length(f_cols) >= 2L) f_cols[2L] else NULL
  if (length(f_cols) >= 3L) {
    for (fc3 in f_cols[-c(1L, 2L)]) {
      u3 <- sort(unique(ds[[fc3]]))
      ds <- ds[ds[[fc3]] == u3[ceiling(length(u3) / 2)], , drop = FALSE]
    }
  }
  grp <- if (!is.null(s_f)) paste0(s_f, " = ", ds[[s_f]]) else "Design"
  long_df <- rbind(
    data.frame(PrimaryN = ds[[p_f]], Group = grp, Metric = "G (Relative)", Coef = ds$G, stringsAsFactors = FALSE),
    data.frame(PrimaryN = ds[[p_f]], Group = grp, Metric = "Phi (Absolute)", Coef = ds$Phi, stringsAsFactors = FALSE)
  )
  grp_lv <- unique(long_df$Group)
  long_df$Group <- factor(long_df$Group, levels = grp_lv)
  cols <- stats::setNames(.mfrm_cvd_palette(length(grp_lv), palette), grp_lv)
  shapes <- stats::setNames(.mfrm_cvd_shapes(length(grp_lv)), grp_lv)

  p <- ggplot2::ggplot(
    long_df,
    ggplot2::aes(x = .data$PrimaryN, y = .data$Coef,
                 colour = .data$Group, shape = .data$Group, linetype = .data$Metric)
  ) +
    ggplot2::geom_hline(yintercept = 0.80, linetype = "dotted", colour = "#666666", linewidth = 0.45) +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::geom_point(size = 2.5) +
    ggplot2::scale_colour_manual(values = cols, name = if (!is.null(s_f)) s_f else "Design") +
    ggplot2::scale_shape_manual(values = shapes, name = if (!is.null(s_f)) s_f else "Design") +
    ggplot2::scale_linetype_manual(values = c("G (Relative)" = "solid", "Phi (Absolute)" = "dashed"), name = "Index") +
    ggplot2::scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, by = 0.2)) +
    ggplot2::labs(x = sprintf("Planned Sample Size (%s)", p_f), y = "Generalizability / Dependability") +
    .mfrm_gg_theme(base_size = base_size)
  attr(p, "mfrm_notes") <- c("Secondary facet count is encoded by colour + point shape; G vs Phi by linetype.",
    unique(c(ds$GStatus[is.na(ds$G)], ds$PhiStatus[is.na(ds$Phi)])))
  p
}

#' @rdname plot.mfrm_fit
#' @export
plot.mfrm_bias <- function(x,
                           type = c("forest", "pairwise"),
                           top_n = 20L,
                           palette = c("okabe_ito", "viridis", "monochrome"),
                           base_size = 11,
                           ...) {
  type <- match.arg(type)
  palette <- match.arg(palette)
  if (identical(type, "pairwise") && is.data.frame(x$pairwise) && nrow(x$pairwise) > 0L) {
    df <- x$pairwise
    df <- df[order(-abs(df$t)), , drop = FALSE]
    df <- utils::head(df, as.integer(top_n))
    df$Label <- paste0(df$TargetLevel, ": ", df$Context1, " - ", df$Context2)
    df$Label <- factor(df$Label, levels = rev(unique(df$Label)))
    crit <- stats::qt(0.975, df = pmax(1, df$df))
    df$Low <- df$Contrast - crit * df$ContrastSE
    df$High <- df$Contrast + crit * df$ContrastSE
    df$Status <- factor(ifelse(is.na(df$pAdj), "Unavailable", ifelse(df$pAdj < 0.05, "Adjusted p < .05", "Not Flagged")),
                        levels = c("Not Flagged", "Adjusted p < .05", "Unavailable"))
    cols <- stats::setNames(.mfrm_cvd_palette(3L, palette), levels(df$Status))
    p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$Contrast, y = .data$Label)) +
      ggplot2::geom_vline(xintercept = 0, linetype = "dotted", colour = "#666666") +
      ggplot2::geom_errorbar(
        ggplot2::aes(xmin = .data$Low, xmax = .data$High, colour = .data$Status, linetype = .data$Status),
        orientation = "y", width = 0.0, linewidth = 0.6, na.rm = TRUE
      ) +
      ggplot2::geom_point(ggplot2::aes(colour = .data$Status, shape = .data$Status), size = 2.8) +
      ggplot2::scale_colour_manual(values = cols, drop = FALSE, name = "Pairwise Bias") +
      ggplot2::scale_shape_manual(values = c(16L, 17L, 4L), drop = FALSE, name = "Pairwise Bias") +
      ggplot2::scale_linetype_manual(values = c("solid", "dashed", "dotted"), drop = FALSE, name = "Pairwise Bias") +
      ggplot2::labs(x = "Pairwise Bias Contrast (Logits; 95% Welch CI)", y = NULL) +
      .mfrm_gg_theme(base_size = base_size)
    attr(p, "mfrm_notes") <- c(sprintf("Degrees of freedom convention: %s.", x$test_label %||% x$df_method), unique(df$InferenceReason[nzchar(df$InferenceReason)]))
    return(p)
  }

  tb <- as.data.frame(x$table)
  est_col <- intersect(c("BiasSize", "Estimate", "Bias"), names(tb))[1L]
  se_col <- intersect(c("BiasSE", "ModelSE", "SE"), names(tb))[1L]
  tb$Est <- tb[[est_col]]
  tb$SE <- tb[[se_col]]
  tb <- tb[is.finite(tb$Est), , drop = FALSE]
  tb <- tb[order(-abs(tb$Est / pmax(1e-8, tb$SE))), , drop = FALSE]
  tb <- utils::head(tb, as.integer(top_n))
  tb$Cell <- paste0(tb$LevelA, " x ", tb$LevelB)
  tb$Cell <- factor(tb$Cell, levels = rev(unique(tb$Cell)))
  tb$Low <- tb$Est - 1.96 * tb$SE
  tb$High <- tb$Est + 1.96 * tb$SE
  p_col <- intersect(c("pAdj", "pValue"), names(tb))[1L]
  tb$Status <- factor(ifelse(is.na(tb[[p_col]]), "Unavailable", ifelse(tb[[p_col]] < 0.05, "Flagged (p < .05)", "Not Flagged")),
                      levels = c("Not Flagged", "Flagged (p < .05)", "Unavailable"))
  cols <- stats::setNames(.mfrm_cvd_palette(3L, palette), levels(tb$Status))

  p <- ggplot2::ggplot(tb, ggplot2::aes(x = .data$Est, y = .data$Cell)) +
    ggplot2::geom_vline(xintercept = 0, linetype = "dotted", colour = "#666666") +
    ggplot2::geom_errorbar(
      ggplot2::aes(xmin = .data$Low, xmax = .data$High, colour = .data$Status, linetype = .data$Status),
      orientation = "y", width = 0.0, linewidth = 0.6, na.rm = TRUE
    ) +
    ggplot2::geom_point(ggplot2::aes(colour = .data$Status, shape = .data$Status), size = 2.8) +
    ggplot2::scale_colour_manual(values = cols, drop = FALSE, name = "Interaction Cell") +
    ggplot2::scale_shape_manual(values = c(16L, 17L, 4L), drop = FALSE, name = "Interaction Cell") +
    ggplot2::scale_linetype_manual(values = c("solid", "dashed", "dotted"), drop = FALSE, name = "Interaction Cell") +
    ggplot2::labs(x = "Local Bias / Interaction Estimate (Logits; 95% CI)", y = NULL) +
    .mfrm_gg_theme(base_size = base_size)
  attr(p, "mfrm_notes") <- c("Cells ordered by absolute standardized bias; colour, shape, and linetype encode screening status.", unique(tb$InferenceReason[nzchar(tb$InferenceReason)]))
  p
}

#' @rdname plot.mfrm_fit
#' @export
plot.mfrm_dff <- function(x,
                          top_n = 25L,
                          palette = c("okabe_ito", "viridis", "monochrome"),
                          base_size = 11,
                          ...) {
  palette <- match.arg(palette)
  tb <- as.data.frame(x$table)
  c_col <- intersect(c("Contrast", "Delta", "Estimate"), names(tb))[1L]
  s_col <- intersect(c("SandwichSE", "SE", "ModelSE"), names(tb))
  se_vec <- tb[[s_col[1L]]]
  if (all(is.na(se_vec)) && length(s_col) >= 2L) se_vec <- tb[[s_col[2L]]]
  tb$Est <- tb[[c_col]]
  tb$SE_use <- se_vec
  tb <- utils::head(tb[order(-abs(tb$Est)), , drop = FALSE], as.integer(top_n))
  lv_col <- intersect(c("Level", "Element"), names(tb))[1L]
  tb$Elem <- factor(tb[[lv_col]], levels = rev(unique(tb[[lv_col]])))
  tb$Low <- tb$Est - 1.96 * tb$SE_use
  tb$High <- tb$Est + 1.96 * tb$SE_use
  flag_v <- if ("Flagged" %in% names(tb)) tb$Flagged else ifelse(is.na(tb$pAdj), NA, tb$pAdj < 0.05)
  tb$Status <- factor(ifelse(is.na(flag_v), "Unavailable", ifelse(flag_v, "Flagged DFF (p_adj < .05)", "No Flag")),
                      levels = c("No Flag", "Flagged DFF (p_adj < .05)", "Unavailable"))
  cols <- stats::setNames(.mfrm_cvd_palette(3L, palette), levels(tb$Status))

  p <- ggplot2::ggplot(tb, ggplot2::aes(x = .data$Est, y = .data$Elem)) +
    ggplot2::geom_vline(xintercept = 0, linetype = "dotted", colour = "#666666") +
    ggplot2::geom_errorbar(
      ggplot2::aes(xmin = .data$Low, xmax = .data$High, colour = .data$Status, linetype = .data$Status),
      orientation = "y", width = 0.0, linewidth = 0.6
    ) +
    ggplot2::geom_point(ggplot2::aes(colour = .data$Status, shape = .data$Status), size = 2.8) +
    ggplot2::scale_colour_manual(values = cols, drop = FALSE, name = "DFF Status") +
    ggplot2::scale_shape_manual(values = c(16L, 17L, 4L), drop = FALSE, name = "DFF Status") +
    ggplot2::scale_linetype_manual(values = c("solid", "dashed", "dotted"), drop = FALSE, name = "DFF Status") +
    ggplot2::labs(x = sprintf("DFF Contrast (%s - %s)", x$focal %||% "Focal", x$reference %||% "Reference"),
                  y = x$facet %||% "Element") +
    .mfrm_gg_theme(base_size = base_size)
  attr(p, "mfrm_notes") <- c(sprintf("DFF method: %s.", x$method), unique(tb$InferenceReason[nzchar(tb$InferenceReason)]))
  p
}

#' @rdname plot.mfrm_fit
#' @export
plot.mfrm_information <- function(x,
                                  type = c("information", "ccc"),
                                  palette = c("okabe_ito", "viridis", "monochrome"),
                                  base_size = 11,
                                  ...) {
  type <- match.arg(type)
  palette <- match.arg(palette)
  if (identical(type, "ccc") && !is.null(x$category_curves)) {
    cc <- x$category_curves
    cats <- unique(cc$Category)
    cc$Category <- factor(cc$Category, levels = cats)
    cols <- stats::setNames(.mfrm_cvd_palette(length(cats), palette), cats)
    ltypes <- stats::setNames(.mfrm_cvd_linetypes(length(cats)), cats)
    shapes <- stats::setNames(.mfrm_cvd_shapes(length(cats)), cats)
    pts <- cc[seq(1L, nrow(cc), by = 15L), , drop = FALSE]
    p <- ggplot2::ggplot(cc, ggplot2::aes(x = .data$Theta, y = .data$Probability,
                                          colour = .data$Category, linetype = .data$Category)) +
      ggplot2::geom_line(linewidth = 0.8) +
      ggplot2::geom_point(data = pts, ggplot2::aes(shape = .data$Category), size = 2.0) +
      ggplot2::scale_colour_manual(values = cols, name = "Category") +
      ggplot2::scale_linetype_manual(values = ltypes, name = "Category") +
      ggplot2::scale_shape_manual(values = shapes, name = "Category") +
      ggplot2::labs(x = "Latent Ability Theta (Logits)", y = "Category Probability") +
      .mfrm_gg_theme(base_size = base_size)
    if (length(unique(cc$ScaleLevel)) > 1L) p <- p + ggplot2::facet_wrap(~ ScaleLevel)
    return(p)
  }

  ti <- x$test_information %||% x$total
  th_c <- intersect(c("Theta", "theta"), names(ti))[1L]
  in_c <- intersect(c("Information", "information", "TotalInformation"), names(ti))[1L]
  se_c <- intersect(c("SE", "se", "ConditionalSE"), names(ti))[1L]
  df_l <- rbind(
    data.frame(Theta = ti[[th_c]], Value = ti[[in_c]], Curve = "Test Information I(theta)", stringsAsFactors = FALSE),
    data.frame(Theta = ti[[th_c]], Value = ti[[se_c]], Curve = "Conditional SE(theta)", stringsAsFactors = FALSE)
  )
  df_l <- df_l[is.finite(df_l$Value), , drop = FALSE]
  df_l$Curve <- factor(df_l$Curve, levels = c("Test Information I(theta)", "Conditional SE(theta)"))
  cols <- stats::setNames(.mfrm_cvd_palette(2L, palette), levels(df_l$Curve))
  pts <- df_l[seq(1L, nrow(df_l), by = 18L), , drop = FALSE]
  p <- ggplot2::ggplot(df_l, ggplot2::aes(x = .data$Theta, y = .data$Value,
                                          colour = .data$Curve, linetype = .data$Curve)) +
    ggplot2::geom_line(linewidth = 0.85) +
    ggplot2::geom_point(data = pts, ggplot2::aes(shape = .data$Curve), size = 2.2) +
    ggplot2::scale_colour_manual(values = cols, name = NULL) +
    ggplot2::scale_linetype_manual(values = c("solid", "dashed"), name = NULL) +
    ggplot2::scale_shape_manual(values = c(16L, 17L), name = NULL) +
    ggplot2::facet_wrap(~ Curve, ncol = 1, scales = "free_y") +
    ggplot2::labs(x = "Person ability (logits)", y = NULL) +
    .mfrm_gg_theme(base_size = base_size)
  attr(p, "mfrm_notes") <- c("Test information and conditional SE use separate vertical scales.",
                             if (!is.null(x$exposure_basis)) paste("Exposure basis:", x$exposure_basis),
                             x$notes)
  p
}

#' @rdname plot.mfrm_fit
#' @export
plot.mfrm_drift <- function(x,
                            type = c("trajectory", "contrasts"),
                            palette = c("okabe_ito", "viridis", "monochrome"),
                            base_size = 11,
                            ...) {
  type <- match.arg(type)
  palette <- match.arg(palette)
  x <- .drift_refresh_object(x)
  ready <- isTRUE(x$checks$NumericalReady) && isTRUE(x$checks$InformationPositive)
  if (identical(type, "contrasts")) {
    ci <- confint.mfrm_drift(x, parm = "contrasts")
    sev_post <- as.data.frame(x, component = "severity")
    sev_post <- sev_post[sev_post$WaveIndex > 1L, , drop = FALSE]
    raters <- unique(as.character(ci$Rater))
    times <- unique(as.character(ci$Time))
    base_lbl <- if (nrow(ci) > 0L) ci$Baseline[1L] else "Baseline"
    ci$RaterF <- factor(ci$Rater, levels = raters)
    ci$TimeF <- factor(ci$Time, levels = times)
    ci$FlaggedDrift <- sev_post$FlaggedDrift
    cols <- stats::setNames(.mfrm_cvd_palette(length(raters), palette), raters)
    shapes <- stats::setNames(.mfrm_cvd_shapes(length(raters)), raters)
    ltypes <- stats::setNames(.mfrm_cvd_linetypes(length(raters)), raters)
    dodge <- ggplot2::position_dodge(width = 0.35)
    p <- ggplot2::ggplot(
      ci,
      ggplot2::aes(x = .data$TimeF, y = .data$Estimate, group = .data$RaterF,
                   colour = .data$RaterF, linetype = .data$RaterF, shape = .data$RaterF)
    ) +
      ggplot2::geom_hline(yintercept = 0, linetype = "dotted", colour = "#666666")
    if (any(is.finite(ci$Lower) & is.finite(ci$Upper))) {
      p <- p + ggplot2::geom_errorbar(
        ggplot2::aes(ymin = .data$Lower, ymax = .data$Upper),
        width = 0.0, linewidth = 0.6, position = dodge, na.rm = TRUE
      )
    }
    if (length(times) >= 2L) {
      p <- p + ggplot2::geom_line(linewidth = 0.75, position = dodge)
    }
    p <- p +
      ggplot2::geom_point(size = 2.6, position = dodge) +
      ggplot2::scale_colour_manual(values = cols, name = "Rater") +
      ggplot2::scale_linetype_manual(values = ltypes, name = "Rater") +
      ggplot2::scale_shape_manual(values = shapes, name = "Rater") +
      ggplot2::labs(x = sprintf("Occasion / Wave (vs. %s)", base_lbl),
                    y = sprintf("Severity Change from %s (Logits)", base_lbl)) +
      .mfrm_gg_theme(base_size = base_size)
    has_bars <- any(is.finite(ci$Lower) & is.finite(ci$Upper))
    attr(p, "mfrm_notes") <- c(
      sprintf("Contrasts show rater severity changes relative to baseline wave '%s'.", base_lbl),
      if (!ready) {
        "Numerical readiness check failed; contrast intervals are withheld."
      } else if (has_bars) {
        "Error bars show 95% total-SE intervals."
      } else {
        "Total standard errors are unavailable; contrast intervals are withheld."
      },
      if (identical(x$settings$drift_mode, "static")) "Static drift mode constrains all wave contrasts to zero."
    )
    return(p)
  }

  sev <- as.data.frame(x, component = "severity")
  r_col <- intersect(c("Rater", "rater"), names(sev))[1L]
  t_col <- intersect(c("Time", "Wave", "time"), names(sev))[1L]
  e_col <- intersect(c("Estimate", "Severity", "estimate"), names(sev))[1L]
  s_col <- intersect(c("SE", "TotalSE", "se"), names(sev))[1L]
  raters <- unique(as.character(sev[[r_col]]))
  times <- unique(as.character(sev[[t_col]]))
  sev$RaterF <- factor(sev[[r_col]], levels = raters)
  sev$TimeF <- factor(sev[[t_col]], levels = times)
  sev$Est <- sev[[e_col]]
  sev$SE_u <- if (!is.na(s_col)) sev[[s_col]] else 0.0

  cols <- stats::setNames(.mfrm_cvd_palette(length(raters), palette), raters)
  shapes <- stats::setNames(.mfrm_cvd_shapes(length(raters)), raters)
  ltypes <- stats::setNames(.mfrm_cvd_linetypes(length(raters)), raters)

  p <- ggplot2::ggplot(
    sev,
    ggplot2::aes(x = .data$TimeF, y = .data$Est, group = .data$RaterF,
                 colour = .data$RaterF, linetype = .data$RaterF, shape = .data$RaterF)
  ) +
    ggplot2::geom_hline(yintercept = 0, linetype = "dotted", colour = "#888888") +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::geom_point(size = 2.6) +
    ggplot2::scale_colour_manual(values = cols, name = "Rater") +
    ggplot2::scale_linetype_manual(values = ltypes, name = "Rater") +
    ggplot2::scale_shape_manual(values = shapes, name = "Rater") +
    ggplot2::labs(x = "Occasion / Wave", y = "Dynamic Rater Severity (Logits)") +
    .mfrm_gg_theme(base_size = base_size)
  attr(p, "mfrm_notes") <- c(
    "Each rater trajectory is encoded simultaneously by colour, linetype, and marker shape.",
    if (!ready) "Numerical readiness check failed; inspect checks before interpreting trajectories."
  )
  p
}

#' @rdname plot.mfrm_fit
#' @export

#' @rdname plot.mfrm_fit
#' @export
.mfrm_gstudy_plot_moments <- function(x,
                                          palette = c("okabe_ito", "viridis", "monochrome"),
                                          base_size = 11,
                                          ...) {
  palette <- match.arg(palette)
  srcs <- names(x$components)
  rows <- lapply(srcs, function(nm) {
    mat <- as.matrix(x$components[[nm]])
    sc <- colnames(mat) %||% paste0("Score", seq_len(ncol(mat)))
    data.frame(Source = nm, Score = sc, Variance = pmax(0.0, diag(mat)), stringsAsFactors = FALSE)
  })
  df <- do.call(rbind, rows)
  sc_lvls <- unique(df$Score)
  df$Source <- factor(df$Source, levels = rev(srcs))
  df$Score <- factor(df$Score, levels = sc_lvls)
  cols <- stats::setNames(.mfrm_cvd_palette(length(sc_lvls), palette), sc_lvls)
  shapes <- stats::setNames(.mfrm_cvd_shapes(length(sc_lvls)), sc_lvls)

  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$Variance, y = .data$Source,
                                        colour = .data$Score, shape = .data$Score)) +
    ggplot2::geom_vline(xintercept = 0, linetype = "dotted", colour = "#888888") +
    ggplot2::geom_point(size = 3.0, position = ggplot2::position_dodge(width = 0.45)) +
    ggplot2::scale_colour_manual(values = cols, name = "Score") +
    ggplot2::scale_shape_manual(values = shapes, name = "Score") +
    ggplot2::labs(x = "Estimated Variance Component (Nonnegative-Clipped)", y = "Source of Variation") +
    .mfrm_gg_theme(base_size = base_size)
  attr(p, "mfrm_notes") <- "Diagonal variance components from multivariate G-Study."
  p
}

#' @rdname plot.mfrm_fit
#' @export
plot.mfrm_multivariate_d_study <- function(x,
                                           palette = c("okabe_ito", "viridis", "monochrome"),
                                           base_size = 11,
                                           ...) {
  palette <- match.arg(palette)
  cf <- x$coefficients
  cf <- cf[is.finite(cf$G) | is.finite(cf$Phi), , drop = FALSE]
  scen <- paste0("S", cf$Scenario)
  df_l <- rbind(
    data.frame(Scenario = scen, Score = cf$Score, Metric = "G (Relative)", Value = cf$G, stringsAsFactors = FALSE),
    data.frame(Scenario = scen, Score = cf$Score, Metric = "Phi (Absolute)", Value = cf$Phi, stringsAsFactors = FALSE)
  )
  df_l <- df_l[is.finite(df_l$Value), , drop = FALSE]
  df_l$Scenario <- factor(df_l$Scenario, levels = unique(scen))
  df_l$Metric <- factor(df_l$Metric, levels = c("G (Relative)", "Phi (Absolute)"))
  cols <- stats::setNames(.mfrm_cvd_palette(2L, palette), levels(df_l$Metric))

  p <- ggplot2::ggplot(df_l, ggplot2::aes(x = .data$Scenario, y = .data$Value,
                                          group = .data$Metric, colour = .data$Metric,
                                          linetype = .data$Metric, shape = .data$Metric)) +
    ggplot2::geom_hline(yintercept = 0.80, linetype = "dotted", colour = "#666666") +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::geom_point(size = 2.7) +
    ggplot2::scale_colour_manual(values = cols, name = "Coefficient") +
    ggplot2::scale_linetype_manual(values = c("solid", "dashed"), name = "Coefficient") +
    ggplot2::scale_shape_manual(values = c(16L, 17L), name = "Coefficient") +
    ggplot2::facet_wrap(~ Score) +
    ggplot2::coord_cartesian(ylim = c(0, 1)) +
    ggplot2::labs(x = "D-Study Scenario", y = "Generalizability / Dependability") +
    .mfrm_gg_theme(base_size = base_size)
  attr(p, "mfrm_notes") <- "Projected G and Phi across candidate D-Study scenarios."
  p
}
