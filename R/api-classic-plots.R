# Classic Rasch/IRT plot front doors for 0.2.0.

validate_theta_grid_args <- function(theta_range, theta_points) {
  theta_range <- as.numeric(theta_range)
  if (length(theta_range) != 2L || !all(is.finite(theta_range)) ||
      theta_range[1] >= theta_range[2]) {
    stop("`theta_range` must be a numeric length-2 vector with increasing values.",
         call. = FALSE)
  }
  theta_points <- max(51L, as.integer(theta_points))
  list(theta_range = theta_range, theta_points = theta_points)
}

mfrm_design_expected_curve <- function(fit,
                                       theta_range = c(-6, 6),
                                       theta_points = 201L) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an `mfrm_fit` object.", call. = FALSE)
  }
  grid <- validate_theta_grid_args(theta_range, theta_points)
  theta_grid <- seq(grid$theta_range[1], grid$theta_range[2],
                    length.out = grid$theta_points)
  model <- as.character(fit$config$model %||% NA_character_)
  step_structure <- information_build_step_structure(fit, model)
  categories <- step_structure$categories
  category_vec <- matrix(categories, ncol = 1)

  facet_tbl <- as.data.frame(fit$facets$others %||% data.frame(),
                             stringsAsFactors = FALSE)
  if (nrow(facet_tbl) == 0L || !all(c("Facet", "Level", "Estimate") %in% names(facet_tbl))) {
    stop("Facet estimates are required for classic curve computation.",
         call. = FALSE)
  }
  facet_tbl <- facet_tbl[is.finite(facet_tbl$Estimate), , drop = FALSE]
  obs_df <- as.data.frame(fit$prep$data %||% data.frame(),
                          stringsAsFactors = FALSE)
  if (nrow(obs_df) == 0L) {
    stop("Prepared observation data are required for classic curve computation.",
         call. = FALSE)
  }
  facet_names <- as.character(fit$config$facet_names %||% unique(as.character(facet_tbl$Facet)))
  facet_names <- facet_names[facet_names %in% names(obs_df)]
  if (length(facet_names) == 0L) {
    stop("Facet columns were not found in the prepared response data.",
         call. = FALSE)
  }
  facet_signs <- fit$config$facet_signs %||%
    stats::setNames(rep(-1, length(facet_names)), facet_names)
  facet_signs <- facet_signs[facet_names]
  facet_signs[!is.finite(facet_signs)] <- -1

  obs_weights <- suppressWarnings(as.numeric(obs_df$Weight %||% rep(1, nrow(obs_df))))
  obs_weights[!is.finite(obs_weights)] <- 0
  design_cells <- obs_df[, facet_names, drop = FALSE]
  design_cells$Exposure <- obs_weights
  design_cells <- design_cells |>
    dplyr::group_by(dplyr::across(dplyr::all_of(facet_names))) |>
    dplyr::summarize(Exposure = sum(.data$Exposure, na.rm = TRUE), .groups = "drop") |>
    as.data.frame(stringsAsFactors = FALSE)

  est_key <- paste(facet_tbl$Facet, facet_tbl$Level, sep = "||")
  est_lookup <- stats::setNames(facet_tbl$Estimate, est_key)
  cell_offset <- numeric(nrow(design_cells))
  cell_ok <- design_cells$Exposure > 0
  for (facet in facet_names) {
    keys <- paste(facet, design_cells[[facet]], sep = "||")
    est_vals <- suppressWarnings(as.numeric(est_lookup[keys]))
    sign_val <- suppressWarnings(as.numeric(facet_signs[[facet]]))
    if (!is.finite(sign_val)) sign_val <- -1
    cell_ok <- cell_ok & is.finite(est_vals)
    cell_offset <- cell_offset + sign_val * est_vals
  }

  cell_step_idx <- NULL
  cell_slope_idx <- NULL
  if (identical(step_structure$kind, "step_facet_specific") ||
      identical(step_structure$kind, "step_and_slope_specific")) {
    step_facet <- step_structure$step_facet
    if (!step_facet %in% names(design_cells)) {
      stop("Step facet column was not found in the observed design cells.",
           call. = FALSE)
    }
    cell_step_idx <- match(as.character(design_cells[[step_facet]]),
                           step_structure$step_levels)
    cell_ok <- cell_ok & is.finite(cell_step_idx)
  }
  if (identical(step_structure$kind, "step_and_slope_specific")) {
    slope_facet <- step_structure$slope_facet
    if (!slope_facet %in% names(design_cells)) {
      stop("GPCM slope facet column was not found in the observed design cells.",
           call. = FALSE)
    }
    cell_slope_idx <- match(as.character(design_cells[[slope_facet]]),
                            step_structure$slope_levels)
    cell_ok <- cell_ok & is.finite(cell_slope_idx)
  }
  design_cells <- design_cells[cell_ok, , drop = FALSE]
  cell_offset <- cell_offset[cell_ok]
  if (!is.null(cell_step_idx)) cell_step_idx <- cell_step_idx[cell_ok]
  if (!is.null(cell_slope_idx)) cell_slope_idx <- cell_slope_idx[cell_ok]
  if (nrow(design_cells) == 0L) {
    stop("No valid observed design cells were available for classic curve computation.",
         call. = FALSE)
  }

  compute_cell_expected <- function(offset, step_idx = NULL, slope_idx = NULL) {
    eta <- theta_grid + offset
    probs <- if (identical(step_structure$kind, "common")) {
      step_structure$compute(eta)
    } else if (identical(step_structure$kind, "step_facet_specific")) {
      step_structure$compute(eta, rep(step_idx, length(eta)))
    } else {
      step_structure$compute(eta, rep(step_idx, length(eta)),
                             rep(slope_idx, length(eta)))
    }
    as.vector(probs %*% category_vec) + as.numeric(fit$prep$rating_min %||% 0)
  }

  expected_mat <- if (is.null(cell_step_idx)) {
    vapply(cell_offset, compute_cell_expected, numeric(length(theta_grid)))
  } else if (is.null(cell_slope_idx)) {
    vapply(seq_along(cell_offset), function(i) {
      compute_cell_expected(cell_offset[i], cell_step_idx[i])
    }, numeric(length(theta_grid)))
  } else {
    vapply(seq_along(cell_offset), function(i) {
      compute_cell_expected(cell_offset[i], cell_step_idx[i], cell_slope_idx[i])
    }, numeric(length(theta_grid)))
  }
  if (!is.matrix(expected_mat)) expected_mat <- matrix(expected_mat, ncol = 1L)
  exposure <- suppressWarnings(as.numeric(design_cells$Exposure))
  total_exposure <- sum(exposure, na.rm = TRUE)
  expected_total <- as.vector(expected_mat %*% exposure)
  data.frame(
    Theta = theta_grid,
    ExpectedTotalScore = expected_total,
    ExpectedMeanScore = expected_total / total_exposure,
    Exposure = total_exposure,
    stringsAsFactors = FALSE
  )
}

#' Plot expected score curves
#'
#' Draws model-implied expected score curves across theta for the active
#' rating-scale / partial-credit curve groups. This is the user-facing classic
#' expected-score front door; the underlying coordinates are the same scale
#' curves returned by [category_curves_report()].
#'
#' @details
#' For each curve group and theta grid point, the expected score is
#' \deqn{E[X \mid \theta] = \sum_k x_k P(X = x_k \mid \theta).}
#' This is the model-implied expected category score, not an empirical fit
#' smoother.
#'
#' @param fit An `mfrm_fit` object.
#' @param curve_group Optional curve group label to retain.
#' @param theta_range Numeric length-2 theta range.
#' @param theta_points Number of theta grid points.
#' @param draw If `TRUE`, draw with base graphics.
#' @return An `mfrm_plot_data` object with an `expected` data frame.
#' @seealso [category_curves_report()], [plot_test_characteristic_curve()],
#'   [plot_cumulative_category_curve()]
#' @examples
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 25)
#' p <- plot_expected_score_curve(fit, draw = FALSE)
#' head(p$data$expected)
#' @export
plot_expected_score_curve <- function(fit,
                                      curve_group = NULL,
                                      theta_range = c(-6, 6),
                                      theta_points = 241L,
                                      draw = TRUE) {
  grid <- validate_theta_grid_args(theta_range, theta_points)
  curves <- category_curves_report(
    fit,
    theta_range = grid$theta_range,
    theta_points = grid$theta_points
  )
  expected <- as.data.frame(curves$expected_ogive, stringsAsFactors = FALSE)
  if (!is.null(curve_group)) {
    curve_group <- as.character(curve_group)
    expected <- expected[as.character(expected$CurveGroup) %in% curve_group, , drop = FALSE]
  }
  if (nrow(expected) == 0L) {
    stop("No expected-score curve rows remain after filtering.", call. = FALSE)
  }
  title <- "Expected score curve"
  subtitle <- "Model-implied expected score across theta by curve group"
  if (isTRUE(draw)) {
    groups <- unique(as.character(expected$CurveGroup))
    graphics::plot(NA, NA,
                   xlim = range(expected$Theta, finite = TRUE),
                   ylim = range(expected$ExpectedScore, finite = TRUE),
                   xlab = expression(theta), ylab = "Expected score",
                   main = title)
    graphics::abline(v = 0, lty = 2, col = "grey70")
    cols <- grDevices::hcl.colors(length(groups), "Dark 3")
    for (i in seq_along(groups)) {
      sub <- expected[as.character(expected$CurveGroup) == groups[i], , drop = FALSE]
      graphics::lines(sub$Theta, sub$ExpectedScore, col = cols[i], lwd = 2)
    }
    graphics::legend("topleft", legend = groups, col = cols, lty = 1, lwd = 2,
                     bty = "n", cex = 0.8)
  }
  invisible(new_mfrm_plot_data(
    "expected_score_curve",
    list(
      expected = expected,
      title = title,
      subtitle = subtitle,
      reference_lines = new_reference_lines("v", 0, "Centered theta reference",
                                            "dashed", "reference")
    )
  ))
}

#' Plot a design-weighted test characteristic curve
#'
#' Computes the expected total and mean score over the observed many-facet
#' design while varying the person measure theta. Unlike
#' [plot_expected_score_curve()], this summarizes the realized design as a
#' whole rather than one threshold/criterion curve group.
#'
#' @details
#' For each observed design cell `d`, the helper computes
#' \eqn{E_d[X \mid \theta]} from the fitted rating-scale, partial-credit, or
#' bounded GPCM structure, then aggregates with the observed exposure weight
#' \eqn{w_d}:
#' \deqn{TCC(\theta) = \sum_d w_d E_d[X \mid \theta].}
#' `ExpectedMeanScore` divides this total by \eqn{\sum_d w_d}.
#'
#' @inheritParams plot_expected_score_curve
#' @return An `mfrm_plot_data` object with a `tcc` data frame.
#' @examples
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 25)
#' tcc <- plot_test_characteristic_curve(fit, draw = FALSE)
#' head(tcc$data$tcc)
#' @export
plot_test_characteristic_curve <- function(fit,
                                           theta_range = c(-6, 6),
                                           theta_points = 201L,
                                           draw = TRUE) {
  tcc <- mfrm_design_expected_curve(
    fit,
    theta_range = theta_range,
    theta_points = theta_points
  )
  title <- "Test characteristic curve"
  subtitle <- "Design-weighted expected total and mean score across theta"
  if (isTRUE(draw)) {
    graphics::plot(tcc$Theta, tcc$ExpectedTotalScore, type = "l", lwd = 2,
                   xlab = expression(theta), ylab = "Expected total score",
                   main = title)
    graphics::abline(v = 0, lty = 2, col = "grey70")
  }
  invisible(new_mfrm_plot_data(
    "test_characteristic_curve",
    list(
      tcc = tcc,
      title = title,
      subtitle = subtitle,
      reference_lines = new_reference_lines("v", 0, "Centered theta reference",
                                            "dashed", "reference")
    )
  ))
}

#' Plot cumulative category curves
#'
#' Draws \eqn{P(X \ge k)} curves across theta for ordered response categories.
#' These are cumulative ordered-category curves, not mirt's empirical plot and
#' not an S-X2 item-fit test.
#'
#' @details
#' For each non-minimum category threshold \eqn{k}, the displayed curve is
#' \deqn{P(X \ge k \mid \theta) = \sum_{x_j \ge k} P(X = x_j \mid \theta).}
#'
#' @inheritParams plot_expected_score_curve
#' @return An `mfrm_plot_data` object with a `cumulative` data frame.
#' @examples
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 25)
#' cc <- plot_cumulative_category_curve(fit, draw = FALSE)
#' head(cc$data$cumulative)
#' @export
plot_cumulative_category_curve <- function(fit,
                                           curve_group = NULL,
                                           theta_range = c(-6, 6),
                                           theta_points = 241L,
                                           draw = TRUE) {
  grid <- validate_theta_grid_args(theta_range, theta_points)
  curves <- category_curves_report(
    fit,
    theta_range = grid$theta_range,
    theta_points = grid$theta_points
  )
  prob <- as.data.frame(curves$probabilities, stringsAsFactors = FALSE)
  if (!is.null(curve_group)) {
    curve_group <- as.character(curve_group)
    prob <- prob[as.character(prob$CurveGroup) %in% curve_group, , drop = FALSE]
  }
  if (nrow(prob) == 0L) {
    stop("No category-probability rows remain after filtering.", call. = FALSE)
  }
  prob$CategoryValue <- suppressWarnings(as.numeric(as.character(prob$Category)))
  if (!all(is.finite(prob$CategoryValue))) {
    prob$CategoryValue <- as.integer(factor(prob$Category)) - 1L
  }
  cumulative <- prob |>
    dplyr::group_by(.data$CurveGroup, .data$Theta) |>
    dplyr::mutate(CumulativeProbability = vapply(.data$CategoryValue, function(k) {
      sum(.data$Probability[.data$CategoryValue >= k], na.rm = TRUE)
    }, numeric(1))) |>
    dplyr::ungroup() |>
    dplyr::filter(.data$CategoryValue > min(.data$CategoryValue, na.rm = TRUE)) |>
    as.data.frame(stringsAsFactors = FALSE)

  title <- "Cumulative category curve"
  subtitle <- "Ordered-category cumulative probabilities P(X >= k)"
  if (isTRUE(draw)) {
    groups <- unique(paste(cumulative$CurveGroup, cumulative$Category, sep = " / "))
    graphics::plot(NA, NA,
                   xlim = range(cumulative$Theta, finite = TRUE),
                   ylim = c(0, 1),
                   xlab = expression(theta), ylab = "Cumulative probability",
                   main = title)
    graphics::abline(v = 0, lty = 2, col = "grey70")
    cols <- grDevices::hcl.colors(length(groups), "Dark 3")
    for (i in seq_along(groups)) {
      parts <- strsplit(groups[i], " / ", fixed = TRUE)[[1]]
      sub <- cumulative[as.character(cumulative$CurveGroup) == parts[1] &
                          as.character(cumulative$Category) == parts[2], , drop = FALSE]
      graphics::lines(sub$Theta, sub$CumulativeProbability, col = cols[i], lwd = 2)
    }
  }
  invisible(new_mfrm_plot_data(
    "cumulative_category_curve",
    list(
      cumulative = cumulative,
      title = title,
      subtitle = subtitle,
      reference_lines = new_reference_lines("v", 0, "Centered theta reference",
                                            "dashed", "reference")
    )
  ))
}

#' Plot a KIDMAP-style person-fit screen
#'
#' Convenience wrapper around [plot_person_fit()] using the classic KIDMAP-style
#' naming that many Rasch users recognize. The returned payload is identical to
#' [plot_person_fit()].
#'
#' @param fit An `mfrm_fit` object.
#' @param diagnostics Optional [diagnose_mfrm()] output.
#' @param ... Passed to [plot_person_fit()].
#' @return An `mfrm_plot_data` object.
#' @examples
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 25)
#' km <- plot_kidmap(fit, draw = FALSE)
#' head(km$data$data)
#' @export
plot_kidmap <- function(fit, diagnostics = NULL, ...) {
  out <- plot_person_fit(fit, diagnostics = diagnostics, ...)
  out$name <- "kidmap_person_fit"
  out$data$plot_name <- "kidmap_person_fit"
  out$data$plot <- "kidmap_person_fit"
  out$data$title <- "KIDMAP-style person fit"
  out
}
