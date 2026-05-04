# Empirical fit plots and TAM-style fit p-value tables

mfrm_two_sided_z_p <- function(z) {
  z <- suppressWarnings(as.numeric(z))
  out <- rep(NA_real_, length(z))
  ok <- is.finite(z)
  out[ok] <- 2 * stats::pnorm(-abs(z[ok]))
  out
}

mfrm_adjust_p <- function(p, method) {
  p <- suppressWarnings(as.numeric(p))
  out <- rep(NA_real_, length(p))
  ok <- is.finite(p) & p >= 0 & p <= 1
  if (any(ok)) {
    out[ok] <- stats::p.adjust(p[ok], method = method)
  }
  out
}

mfrm_fit_p_source <- function(fit, diagnostics, scope) {
  if (identical(scope, "element")) {
    tbl <- as.data.frame(diagnostics$fit %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(tbl) == 0L) return(tbl)
    tbl$Scope <- "element"
    tbl$parameter <- paste(as.character(tbl$Facet), as.character(tbl$Level), sep = ":")
    return(tbl)
  }

  if (identical(scope, "person")) {
    tbl <- as.data.frame(diagnostics$measures %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(tbl) == 0L || !"Facet" %in% names(tbl)) return(data.frame())
    tbl <- tbl[as.character(tbl$Facet) == "Person", , drop = FALSE]
    if (nrow(tbl) == 0L) return(tbl)
    tbl$Scope <- "person"
    tbl$parameter <- as.character(tbl$Level)
    return(tbl)
  }

  if (identical(scope, "category")) {
    rst <- rating_scale_table(fit, diagnostics = diagnostics)
    tbl <- as.data.frame(rst$category_table %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(tbl) == 0L) return(tbl)
    tbl$Facet <- "Category"
    tbl$Level <- as.character(tbl$Category)
    tbl$N <- suppressWarnings(as.numeric(tbl$Count))
    tbl$Scope <- "category"
    tbl$parameter <- paste0("Category:", tbl$Level)
    return(tbl)
  }

  data.frame()
}

#' TAM-style Infit / Outfit p-value table
#'
#' Builds a compact fit table with TAM-style columns for mfrmr element,
#' person, or score-category fit statistics. The output keeps the familiar
#' `Outfit`, `Outfit_t`, `Outfit_p`, `Infit`, `Infit_t`, and `Infit_p`
#' layout, while also adding p-value adjustment columns and the active
#' `MisfitDirection` label used elsewhere in mfrmr.
#'
#' @param fit Output from [fit_mfrm()].
#' @param diagnostics Optional output from [diagnose_mfrm()]. When omitted,
#'   diagnostics are computed with `residual_pca = "none"`.
#' @param scope Which fit surface to report: `"element"` (default; facet
#'   levels from `diagnostics$fit`), `"person"` (person rows from
#'   `diagnostics$measures`), or `"category"` (score categories from
#'   [rating_scale_table()]).
#' @param p_adjust P-value adjustment method passed to [stats::p.adjust()].
#'   Default `"holm"` mirrors the common TAM summary handoff.
#' @param alpha Significance level used for logical p-value flags.
#' @param lower,upper Optional MnSq screening band. `NULL` uses the active
#'   [mfrm_misfit_thresholds()] options.
#'
#' @details
#' `fit_p_table()` is intentionally a reporting and screening table, not a new
#' model-fit estimator. `Infit_t` and `Outfit_t` are mfrmr's existing
#' standardized fit transformations (`InfitZSTD`, `OutfitZSTD`), and p-values
#' are two-sided normal-tail approximations,
#' \eqn{2\Phi(-|ZSTD|)}. TAM's simulation-based MML item-fit route can use
#' different null approximations; use this table as a transparent mfrmr-native
#' handoff for manuscripts and appendices.
#'
#' @return A data frame with TAM-style fit columns plus mfrmr screening columns:
#' `Scope`, `parameter`, `Facet`, `Level`, `N`, `Outfit`, `Outfit_t`,
#' `Outfit_p`, `Outfit_p_adj`, `Infit`, `Infit_t`, `Infit_p`, `Infit_p_adj`,
#' `MisfitDirection`, `MnSqFlag`, `PFlag`, and `PAdjustMethod`. When
#' `p_adjust = "holm"`, compatibility aliases `Outfit_pholm` and
#' `Infit_pholm` are also included.
#'
#' @seealso [diagnose_mfrm()], [plot_empirical_fit()], [plot_person_fit()]
#' @examples
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 25)
#' diag <- diagnose_mfrm(fit, residual_pca = "none")
#' tab <- fit_p_table(fit, diagnostics = diag)
#' head(tab[, c("parameter", "Outfit", "Outfit_p", "Outfit_p_adj",
#'              "Infit", "Infit_p", "Infit_p_adj", "MisfitDirection")])
#' fit_p_table(fit, diagnostics = diag, scope = "person")[1:3, ]
#' @export
fit_p_table <- function(fit,
                        diagnostics = NULL,
                        scope = c("element", "person", "category"),
                        p_adjust = "holm",
                        alpha = 0.05,
                        lower = NULL,
                        upper = NULL) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().", call. = FALSE)
  }
  scope <- match.arg(scope)
  p_adjust <- .validate_p_adjust_method(p_adjust)
  alpha <- suppressWarnings(as.numeric(alpha[1]))
  if (!is.finite(alpha) || alpha <= 0 || alpha >= 1) {
    stop("`alpha` must be a single number in (0, 1).", call. = FALSE)
  }
  if (is.null(diagnostics)) {
    diagnostics <- diagnose_mfrm(fit, residual_pca = "none")
  }

  band <- mfrm_misfit_thresholds(lower = lower, upper = upper)
  lower <- as.numeric(band["lower"])
  upper <- as.numeric(band["upper"])

  tbl <- mfrm_fit_p_source(fit, diagnostics, scope)
  if (nrow(tbl) == 0L) {
    return(data.frame())
  }

  for (nm in c("Facet", "Level", "parameter", "Scope")) {
    if (!nm %in% names(tbl)) tbl[[nm]] <- NA_character_
  }
  for (nm in c("N", "Infit", "Outfit", "InfitZSTD", "OutfitZSTD", "DF_Infit", "DF_Outfit")) {
    if (!nm %in% names(tbl)) tbl[[nm]] <- NA_real_
    tbl[[nm]] <- suppressWarnings(as.numeric(tbl[[nm]]))
  }

  missing_infit_z <- !is.finite(tbl$InfitZSTD) & is.finite(tbl$Infit) & is.finite(tbl$DF_Infit)
  if (any(missing_infit_z)) {
    tbl$InfitZSTD[missing_infit_z] <- zstd_from_mnsq(
      tbl$Infit[missing_infit_z],
      tbl$DF_Infit[missing_infit_z]
    )
  }
  missing_outfit_z <- !is.finite(tbl$OutfitZSTD) & is.finite(tbl$Outfit) & is.finite(tbl$DF_Outfit)
  if (any(missing_outfit_z)) {
    tbl$OutfitZSTD[missing_outfit_z] <- zstd_from_mnsq(
      tbl$Outfit[missing_outfit_z],
      tbl$DF_Outfit[missing_outfit_z]
    )
  }

  infit_p <- mfrm_two_sided_z_p(tbl$InfitZSTD)
  outfit_p <- mfrm_two_sided_z_p(tbl$OutfitZSTD)
  infit_p_adj <- mfrm_adjust_p(infit_p, p_adjust)
  outfit_p_adj <- mfrm_adjust_p(outfit_p, p_adjust)
  direction <- mfrm_classify_mnsq_direction(
    tbl$Infit,
    tbl$Outfit,
    lower = lower,
    upper = upper
  )
  mnsq_flag <- direction %in% c("underfit", "overfit", "mixed")
  p_flag <- (is.finite(infit_p_adj) & infit_p_adj <= alpha) |
    (is.finite(outfit_p_adj) & outfit_p_adj <= alpha)

  out <- data.frame(
    Scope = as.character(tbl$Scope),
    parameter = as.character(tbl$parameter),
    Facet = as.character(tbl$Facet),
    Level = as.character(tbl$Level),
    N = tbl$N,
    Outfit = tbl$Outfit,
    Outfit_t = tbl$OutfitZSTD,
    Outfit_p = outfit_p,
    Outfit_p_adj = outfit_p_adj,
    Infit = tbl$Infit,
    Infit_t = tbl$InfitZSTD,
    Infit_p = infit_p,
    Infit_p_adj = infit_p_adj,
    MisfitDirection = direction,
    MnSqFlag = mnsq_flag,
    PFlag = p_flag,
    Alpha = alpha,
    PAdjustMethod = p_adjust,
    stringsAsFactors = FALSE
  )
  if (identical(p_adjust, "holm")) {
    out$Outfit_pholm <- out$Outfit_p_adj
    out$Infit_pholm <- out$Infit_p_adj
  }
  ord_metric <- pmax(
    ifelse(is.finite(out$Outfit_t), abs(out$Outfit_t), 0),
    ifelse(is.finite(out$Infit_t), abs(out$Infit_t), 0),
    na.rm = TRUE
  )
  out[order(out$PFlag, out$MnSqFlag, ord_metric, decreasing = TRUE), , drop = FALSE]
}

mfrm_resolve_empirical_target <- function(fit, diagnostics, facet, level) {
  facet_names <- c("Person", as.character(fit$config$facet_names %||% character(0)))
  facet_names <- unique(facet_names[!is.na(facet_names) & nzchar(facet_names)])
  if (length(facet_names) == 0L) {
    stop("`fit` does not expose any facet names.", call. = FALSE)
  }

  if (is.null(facet) || !nzchar(as.character(facet[1]))) {
    non_person <- setdiff(facet_names, "Person")
    facet <- if (length(non_person) > 0L) non_person[1] else facet_names[1]
  } else {
    facet <- as.character(facet[1])
  }
  if (!facet %in% facet_names) {
    stop("`facet` must be one of: ", paste(facet_names, collapse = ", "), ".",
         call. = FALSE)
  }

  obs <- as.data.frame(diagnostics$obs %||% data.frame(), stringsAsFactors = FALSE)
  if (!facet %in% names(obs)) {
    stop("`diagnostics$obs` does not include facet column `", facet, "`.",
         call. = FALSE)
  }
  levels_available <- unique(as.character(obs[[facet]]))
  levels_available <- levels_available[!is.na(levels_available) & nzchar(levels_available)]
  if (length(levels_available) == 0L) {
    stop("No observed levels are available for facet `", facet, "`.",
         call. = FALSE)
  }

  if (is.null(level) || !nzchar(as.character(level[1]))) {
    fit_tbl <- as.data.frame(diagnostics$fit %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(fit_tbl) > 0L && all(c("Facet", "Level", "Infit", "Outfit") %in% names(fit_tbl))) {
      fit_sub <- fit_tbl[as.character(fit_tbl$Facet) == facet, , drop = FALSE]
      if (nrow(fit_sub) > 0L) {
        infit <- suppressWarnings(as.numeric(fit_sub$Infit))
        outfit <- suppressWarnings(as.numeric(fit_sub$Outfit))
        score <- pmax(
          ifelse(is.finite(infit), abs(log(pmax(infit, 1e-6))), 0),
          ifelse(is.finite(outfit), abs(log(pmax(outfit, 1e-6))), 0),
          na.rm = TRUE
        )
        level <- as.character(fit_sub$Level[which.max(score)])
      }
    }
    if (is.null(level) || !nzchar(as.character(level[1]))) {
      level <- levels_available[1]
    }
  } else {
    level <- as.character(level[1])
  }
  if (!level %in% levels_available) {
    stop("`level` must be an observed level of `", facet, "`. Available examples: ",
         paste(utils::head(levels_available, 8), collapse = ", "), ".",
         call. = FALSE)
  }

  list(facet = facet, level = level)
}

mfrm_empirical_bin_ids <- function(theta, bins) {
  theta <- suppressWarnings(as.numeric(theta))
  bins <- max(1L, as.integer(bins[1]))
  out <- rep(NA_integer_, length(theta))
  ok <- is.finite(theta)
  n_ok <- sum(ok)
  if (n_ok == 0L) return(out)
  bins <- min(bins, n_ok)
  ord <- which(ok)[order(theta[ok])]
  out[ord] <- pmax(1L, ceiling(seq_along(ord) * bins / n_ok))
  out
}

mfrm_empirical_fit_bins <- function(df, bins, min_bin_n) {
  df$.Bin <- mfrm_empirical_bin_ids(df$PersonMeasure, bins)
  df <- df[is.finite(df$.Bin), , drop = FALSE]
  if (nrow(df) == 0L) return(data.frame())
  min_bin_n <- max(1L, as.integer(min_bin_n[1]))
  split_df <- split(df, df$.Bin)
  rows <- lapply(split_df, function(d) {
    w <- d$.Weight
    obs <- d$.ObservedMetric
    exp <- d$.ExpectedMetric
    total_w <- sum(w, na.rm = TRUE)
    se <- if (is.finite(total_w) && total_w > 0) {
      sqrt(sum((w^2) * d$.ExpectedVar, na.rm = TRUE)) / total_w
    } else {
      NA_real_
    }
    observed <- weighted_mean(obs, w)
    expected <- weighted_mean(exp, w)
    data.frame(
      Bin = as.integer(d$.Bin[1]),
      Rows = nrow(d),
      N = total_w,
      ThetaMin = min(d$PersonMeasure, na.rm = TRUE),
      ThetaMax = max(d$PersonMeasure, na.rm = TRUE),
      MeanPersonMeasure = weighted_mean(d$PersonMeasure, w),
      Observed = observed,
      Expected = expected,
      Residual = observed - expected,
      SE = se,
      StdResidual = if (is.finite(se) && se > 0) (observed - expected) / se else NA_real_,
      LowN = is.finite(total_w) && total_w < min_bin_n,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out[order(out$Bin), , drop = FALSE]
}

#' mirt-style empirical fit plot for an MFRM facet level
#'
#' Plots observed response behavior against model-expected behavior across
#' person-measure bins for one facet level. This gives a mirt-inspired
#' empirical fit view for many-facet models: points show empirical bin means
#' (or empirical category proportions), and the line shows the corresponding
#' fitted-model expectation in the same bins.
#'
#' @param fit Output from [fit_mfrm()].
#' @param diagnostics Optional output from [diagnose_mfrm()]. When omitted,
#'   diagnostics are computed with `residual_pca = "none"`.
#' @param facet Facet to inspect. `NULL` uses the first non-person facet.
#' @param level Level within `facet`. `NULL` chooses the most extreme
#'   element-level MnSq row within the selected facet, falling back to the
#'   first observed level.
#' @param category Optional score category. When `NULL`, the plot compares
#'   observed and expected mean score. When supplied, the plot compares the
#'   observed category proportion with the fitted category probability.
#' @param bins Number of approximately equal-count person-measure bins.
#' @param min_bin_n Minimum weighted bin size flagged in the returned table.
#' @param draw If `TRUE`, draw with base graphics.
#' @param preset Visual preset.
#' @param main Optional plot title.
#'
#' @details
#' This is a descriptive empirical overlay, not mirt's `S_X2` test and not a
#' replacement for strict marginal diagnostics. It is designed for the common
#' research workflow: identify a level with [fit_p_table()],
#' [plot_bubble()], or `summary(diagnose_mfrm(...))`, then inspect where the
#' observed response curve departs from the fitted model across the person
#' measure scale.
#'
#' @return An `mfrm_plot_data` object. The `bin_table` / `data` slot contains
#' `Bin`, `N`, `MeanPersonMeasure`, `Observed`, `Expected`, `Residual`, `SE`,
#' `StdResidual`, and `LowN`; `raw_table` contains the filtered row-level
#' metrics used to build the bins.
#'
#' @seealso [fit_p_table()], [plot_bubble()], [plot_person_fit()],
#'   [plot_qc_dashboard()]
#' @examples
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 25)
#' diag <- diagnose_mfrm(fit, residual_pca = "none")
#' p <- plot_empirical_fit(fit, diagnostics = diag,
#'                         facet = "Rater", bins = 5, draw = FALSE)
#' p$data$target
#' p$data$bin_table
#' p_cat <- plot_empirical_fit(fit, diagnostics = diag,
#'                             facet = "Rater", category = 4,
#'                             bins = 5, draw = FALSE)
#' p_cat$data$metric
#' @export
plot_empirical_fit <- function(fit,
                               diagnostics = NULL,
                               facet = NULL,
                               level = NULL,
                               category = NULL,
                               bins = 10L,
                               min_bin_n = 5L,
                               draw = TRUE,
                               preset = c("standard", "publication", "compact"),
                               main = NULL) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().", call. = FALSE)
  }
  if (is.null(diagnostics)) {
    diagnostics <- diagnose_mfrm(fit, residual_pca = "none")
  }
  if (is.null(diagnostics$obs) || nrow(diagnostics$obs) == 0L) {
    stop("`diagnostics$obs` is empty. Run diagnose_mfrm() first.",
         call. = FALSE)
  }
  bins <- suppressWarnings(as.integer(bins[1]))
  if (!is.finite(bins) || bins < 1L) {
    stop("`bins` must be a positive integer.", call. = FALSE)
  }
  min_bin_n <- suppressWarnings(as.integer(min_bin_n[1]))
  if (!is.finite(min_bin_n) || min_bin_n < 1L) {
    stop("`min_bin_n` must be a positive integer.", call. = FALSE)
  }
  style <- resolve_plot_preset(preset)
  target <- mfrm_resolve_empirical_target(fit, diagnostics, facet, level)
  obs <- as.data.frame(diagnostics$obs, stringsAsFactors = FALSE)
  obs$.RowId <- seq_len(nrow(obs))
  obs <- obs[as.character(obs[[target$facet]]) == target$level, , drop = FALSE]
  if (nrow(obs) == 0L) {
    stop("No observations remain for the selected facet level.", call. = FALSE)
  }
  needed <- c("Person", "PersonMeasure", "Observed", "Expected", "Var")
  missing_cols <- setdiff(needed, names(obs))
  if (length(missing_cols) > 0L) {
    stop("`diagnostics$obs` is missing required columns: ",
         paste(missing_cols, collapse = ", "), ".", call. = FALSE)
  }

  obs$.Weight <- get_weights(obs)
  metric <- "mean_score"
  category_value <- NA_real_
  if (is.null(category)) {
    obs$.ObservedMetric <- suppressWarnings(as.numeric(obs$Observed))
    obs$.ExpectedMetric <- suppressWarnings(as.numeric(obs$Expected))
    obs$.ExpectedVar <- pmax(suppressWarnings(as.numeric(obs$Var)), 0)
    ylab <- "Mean score"
  } else {
    category_value <- suppressWarnings(as.numeric(category[1]))
    if (!is.finite(category_value) ||
        category_value != as.integer(category_value) ||
        category_value < fit$prep$rating_min ||
        category_value > fit$prep$rating_max) {
      stop("`category` must be an integer score category in the fitted rating range [",
           fit$prep$rating_min, ", ", fit$prep$rating_max, "].",
           call. = FALSE)
    }
    probs <- compute_prob_matrix(fit)
    if (nrow(probs) != nrow(diagnostics$obs)) {
      stop("Could not align fitted category probabilities with diagnostics rows.",
           call. = FALSE)
    }
    col_idx <- as.integer(category_value - fit$prep$rating_min + 1)
    p_cat <- probs[obs$.RowId, col_idx]
    obs$.ObservedMetric <- as.numeric(suppressWarnings(as.numeric(obs$Observed)) == category_value)
    obs$.ExpectedMetric <- p_cat
    obs$.ExpectedVar <- pmax(p_cat * (1 - p_cat), 0)
    metric <- "category_probability"
    ylab <- paste0("Pr(score = ", category_value, ")")
  }

  ok <- is.finite(obs$PersonMeasure) &
    is.finite(obs$.ObservedMetric) &
    is.finite(obs$.ExpectedMetric) &
    is.finite(obs$.Weight) &
    obs$.Weight > 0
  obs <- obs[ok, , drop = FALSE]
  if (nrow(obs) == 0L) {
    stop("No finite observations remain for empirical fit plotting.",
         call. = FALSE)
  }

  bin_tbl <- mfrm_empirical_fit_bins(obs, bins = bins, min_bin_n = min_bin_n)
  if (nrow(bin_tbl) == 0L) {
    stop("Could not form empirical fit bins.", call. = FALSE)
  }

  fit_tab <- fit_p_table(fit, diagnostics = diagnostics, scope = "element")
  fit_row <- fit_tab[
    as.character(fit_tab$Facet) == target$facet &
      as.character(fit_tab$Level) == target$level,
    ,
    drop = FALSE
  ]
  if (nrow(fit_row) > 1L) fit_row <- fit_row[1, , drop = FALSE]

  plot_title <- if (!is.null(main) && nzchar(as.character(main[1]))) {
    as.character(main[1])
  } else {
    paste0("Empirical fit: ", target$facet, ":", target$level)
  }
  plot_subtitle <- if (identical(metric, "mean_score")) {
    "Observed bin mean score vs fitted expected score"
  } else {
    paste0("Observed bin proportion vs fitted category probability (category ", category_value, ")")
  }

  if (isTRUE(draw)) {
    apply_plot_preset(style)
    ylim <- range(
      c(bin_tbl$Observed, bin_tbl$Expected,
        bin_tbl$Observed - 1.96 * bin_tbl$SE,
        bin_tbl$Observed + 1.96 * bin_tbl$SE),
      finite = TRUE
    )
    if (!all(is.finite(ylim)) || diff(ylim) == 0) {
      ylim <- range(c(bin_tbl$Observed, bin_tbl$Expected, 0, 1), finite = TRUE)
    }
    graphics::plot(
      x = bin_tbl$MeanPersonMeasure,
      y = bin_tbl$Observed,
      pch = 21,
      bg = style$accent_primary,
      col = "white",
      xlab = "Person measure (logit)",
      ylab = ylab,
      main = plot_title,
      ylim = ylim
    )
    graphics::title(sub = plot_subtitle, line = 2.2, cex.sub = 0.9)
    graphics::lines(
      x = bin_tbl$MeanPersonMeasure,
      y = bin_tbl$Expected,
      col = style$fail,
      lwd = 2
    )
    ci_ok <- is.finite(bin_tbl$SE) & bin_tbl$SE > 0
    if (any(ci_ok)) {
      graphics::arrows(
        x0 = bin_tbl$MeanPersonMeasure[ci_ok],
        y0 = bin_tbl$Observed[ci_ok] - 1.96 * bin_tbl$SE[ci_ok],
        x1 = bin_tbl$MeanPersonMeasure[ci_ok],
        y1 = bin_tbl$Observed[ci_ok] + 1.96 * bin_tbl$SE[ci_ok],
        length = 0.03,
        angle = 90,
        code = 3,
        col = grDevices::adjustcolor(style$neutral, alpha.f = 0.65)
      )
    }
    graphics::legend(
      "topleft",
      legend = c("Observed bins", "Model expected"),
      pch = c(21, NA),
      pt.bg = c(style$accent_primary, NA),
      lty = c(NA, 1),
      col = c(style$accent_primary, style$fail),
      bty = "n",
      cex = 0.85
    )
  }

  raw_keep <- unique(intersect(
    c("Person", target$facet, "PersonMeasure", "Observed", "Expected",
      ".ObservedMetric", ".ExpectedMetric", ".ExpectedVar", ".Weight"),
    names(obs)
  ))
  raw_tbl <- obs[, raw_keep, drop = FALSE]
  names(raw_tbl) <- sub("^\\.", "", names(raw_tbl))

  out <- new_mfrm_plot_data(
    "empirical_fit",
    list(
      data = bin_tbl,
      bin_table = bin_tbl,
      raw_table = raw_tbl,
      fit_table = fit_row,
      target = data.frame(
        Facet = target$facet,
        Level = target$level,
        Category = category_value,
        stringsAsFactors = FALSE
      ),
      metric = metric,
      title = plot_title,
      subtitle = plot_subtitle,
      legend = new_plot_legend(
        label = c("Observed bins", "Model expected"),
        role = c("empirical", "model"),
        aesthetic = c("point", "line"),
        value = c(style$accent_primary, style$fail)
      ),
      reference_lines = new_reference_lines(),
      preset = style$name
    )
  )
  invisible(out)
}
