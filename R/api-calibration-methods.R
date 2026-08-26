# Reader-facing methods for portable fixed-calibration score batches.

mfrmr_validate_calibration_score <- function(x, arg = "x") {
  if (!inherits(x, "mfrm_calibration_score")) {
    stop(
      "`", arg, "` must be output from score_mfrm_calibration().",
      call. = FALSE
    )
  }
  required <- c("estimates", "row_review", "person_dispositions", "settings")
  missing <- setdiff(required, names(x))
  if (length(missing) > 0L ||
      !is.data.frame(x$estimates) ||
      !is.data.frame(x$row_review) ||
      !is.data.frame(x$person_dispositions) ||
      !is.list(x$settings)) {
    stop(
      "`", arg, "` is not a complete portable calibration score result.",
      call. = FALSE
    )
  }
  invisible(x)
}

mfrmr_calibration_score_digits <- function(digits) {
  if (!is.numeric(digits) || length(digits) != 1L ||
      !is.finite(digits) || digits < 0 || digits != floor(digits)) {
    stop("`digits` must be one non-negative integer.", call. = FALSE)
  }
  as.integer(digits)
}

mfrmr_calibration_score_overview <- function(x) {
  dispositions <- as.data.frame(
    x$person_dispositions, stringsAsFactors = FALSE
  )
  row_review <- as.data.frame(x$row_review, stringsAsFactors = FALSE)
  row_value <- function(name, default = 0L) {
    if (!name %in% names(row_review) || nrow(row_review) == 0L) return(default)
    value <- suppressWarnings(as.numeric(row_review[[name]][1L]))
    if (!is.finite(value)) default else value
  }
  disposition <- as.character(dispositions$Disposition %||% character(0))
  data.frame(
    CalibrationId = as.character(
      x$settings$calibration_id %||% NA_character_
    ),
    Model = as.character(x$settings$family %||% NA_character_),
    Estimator = as.character(x$settings$estimator %||% NA_character_),
    ScoringBasis = as.character(
      x$settings$scoring_basis %||% NA_character_
    ),
    IntervalLevel = suppressWarnings(as.numeric(
      x$settings$interval_level %||% NA_real_
    )),
    Persons = as.integer(nrow(dispositions)),
    Scored = as.integer(sum(disposition %in% c("scored", "scored_review"))),
    Review = as.integer(sum(disposition == "scored_review")),
    NotScored = as.integer(sum(disposition == "not_scored")),
    InputRows = as.integer(row_value("InputRows")),
    ScoredRows = as.integer(row_value("ScoredRows")),
    OmittedRows = as.integer(row_value("OmittedRows")),
    stringsAsFactors = FALSE
  )
}

#' Review and plot portable fixed-calibration scores
#'
#' These methods provide the first review surface for the result returned by
#' [score_mfrm_calibration()]. `print()` gives a compact batch disposition,
#' `summary()` exposes readable score and review tables, and `plot()` shows
#' conditional score uncertainty or numerical review quantities without
#' refitting a model.
#'
#' The default interval plot shows posterior EAP estimates and central
#' intervals. `type = "precision"` plots the number of valid response rows
#' against posterior SD. `type = "edge_mass"` compares posterior mass on the
#' two outer quadrature nodes with the recorded review threshold. Review
#' dispositions are highlighted in every view.
#'
#' These are score-batch review displays, not calibration-fit diagnostics.
#' Posterior SDs and intervals are conditional on the frozen point calibration
#' and its recorded prior. They exclude calibration-parameter uncertainty.
#' Persons with no valid responses have no score coordinate and are retained
#' in `summary(x)$review` and in the plot payload's
#' `unplotted_dispositions` component.
#'
#' @param object,x An `mfrm_calibration_score` returned by
#'   [score_mfrm_calibration()].
#' @param digits Number of decimal places in the summary.
#' @param type One of `"interval"`, `"precision"`, or `"edge_mass"`.
#' @param top_n Maximum number of scored Persons shown. Review rows are
#'   selected first when truncation is necessary. Use `Inf` to show all.
#' @param sort_by Selection priority after review rows: absolute estimate,
#'   posterior SD, or Person identifier.
#' @param label_review Whether review points are labelled in the precision and
#'   edge-mass views. Interval plots always label the displayed Persons.
#' @param main Optional plot title.
#' @param draw If `TRUE`, draw with base R graphics. The returned
#'   `mfrm_plot_data` is available invisibly in either case.
#' @param preset Visual preset: `"standard"`, `"publication"`, `"compact"`,
#'   or `"monochrome"`.
#' @param ... Reserved for generic compatibility.
#'
#' @return `print()` returns its input invisibly. `summary()` returns a
#'   `summary.mfrm_calibration_score` containing
#'   `overview`, `estimates`, `review`, `row_review`, `settings`, and `notes`.
#'   `plot()` returns an `mfrm_plot_data` with the selected plotting table,
#'   selection accounting, unplotted Person dispositions, interpretation
#'   guidance, and plotting settings.
#'
#' @seealso [mfrm_calibration_workflow], [mfrm_calibration_capabilities],
#'   [plot_data()], [plot_data_components()], [as_ggplot()]
#' @name mfrm_calibration_score_methods
#'
#' @examples
#' \donttest{
#' dat <- load_mfrmr_data("example_core")
#' ids <- unique(dat$Person)
#' training <- dat[dat$Person %in% ids[1:18], , drop = FALSE]
#' fit <- fit_mfrm(
#'   training, "Person", c("Rater", "Criterion"), "Score",
#'   model = "RSM", method = "MML", quad_points = 5, maxit = 20
#' )
#' calibration <- freeze_mfrm_calibration(
#'   validate_mfrm_calibration(extract_mfrm_calibration(fit))
#' )
#' new_rows <- dat[dat$Person %in% ids[19:20], , drop = FALSE]
#' scores <- score_mfrm_calibration(calibration, new_rows)
#' summary(scores)
#' plot(scores, type = "interval")
#' plot(scores, type = "edge_mass", draw = FALSE)
#' }
NULL

#' @rdname mfrm_calibration_score_methods
#' @method summary mfrm_calibration_score
#' @export
summary.mfrm_calibration_score <- function(object, digits = 3L, ...) {
  mfrmr_validate_calibration_score(object, "object")
  digits <- mfrmr_calibration_score_digits(digits)

  estimates <- as.data.frame(object$estimates, stringsAsFactors = FALSE)
  estimate_columns <- intersect(
    c(
      "Person", "Estimate", "SD", "Lower", "Upper", "Observations",
      "WeightedN", "Disposition", "ReasonCodes", "ReadinessStatus"
    ),
    names(estimates)
  )
  estimates <- estimates[, estimate_columns, drop = FALSE]

  dispositions <- as.data.frame(
    object$person_dispositions, stringsAsFactors = FALSE
  )
  review <- dispositions[
    as.character(dispositions$Disposition) != "scored",
    ,
    drop = FALSE
  ]
  review_columns <- intersect(
    c(
      "Person", "Disposition", "ReasonCodes", "ValidResponses",
      "OmittedResponses", "EndpointStatus", "VerySparsePattern",
      "QuadratureEdgeMass", "QuadratureEdgeThreshold", "ReadinessStatus",
      "AdministrationCompleteness"
    ),
    names(review)
  )
  review <- review[, review_columns, drop = FALSE]

  round_numeric <- function(data) {
    numeric_columns <- vapply(data, is.double, logical(1))
    data[numeric_columns] <- lapply(
      data[numeric_columns], round, digits = digits
    )
    data
  }

  out <- list(
    overview = round_numeric(mfrmr_calibration_score_overview(object)),
    estimates = round_numeric(estimates),
    review = round_numeric(review),
    row_review = round_numeric(as.data.frame(
      object$row_review, stringsAsFactors = FALSE
    )),
    settings = list(
      calibration_id = object$settings$calibration_id,
      family = object$settings$family,
      estimator = object$settings$estimator,
      scoring_basis = object$settings$scoring_basis,
      scoring_algorithm = object$settings$scoring_algorithm,
      quadrature_order = object$settings$quadrature_order,
      interval_level = object$settings$interval_level,
      uncertainty_basis = if (nrow(estimates) > 0L &&
          "UncertaintyBasis" %in% names(object$estimates)) {
        unique(as.character(object$estimates$UncertaintyBasis))
      } else {
        "conditional_on_frozen_point_calibration"
      }
    ),
    notes = object$notes %||% character(0),
    digits = digits
  )
  class(out) <- c("summary.mfrm_calibration_score", "list")
  out
}

#' @rdname mfrm_calibration_score_methods
#' @method print mfrm_calibration_score
#' @export
print.mfrm_calibration_score <- function(x, ...) {
  summary_object <- summary.mfrm_calibration_score(x)
  overview <- summary_object$overview[1L, , drop = FALSE]
  cat("<mfrm_calibration_score>\n")
  cat("  Calibration: ", overview$CalibrationId, "\n", sep = "")
  cat(
    "  Model / estimator: ", overview$Model, " / ", overview$Estimator,
    "\n", sep = ""
  )
  cat(
    "  Persons: ", overview$Scored, " scored (", overview$Review,
    " requiring review); ", overview$NotScored, " not scored\n", sep = ""
  )
  cat(
    "  Rows: ", overview$ScoredRows, " scored; ", overview$OmittedRows,
    " omitted\n", sep = ""
  )
  cat(
    "  Intervals: conditional on frozen point calibration; calibration-",
    "parameter uncertainty excluded\n", sep = ""
  )
  cat("Use `summary(x)` for review tables and `plot(x)` for score intervals.\n")
  invisible(x)
}

#' @rdname mfrm_calibration_score_methods
#' @method print summary.mfrm_calibration_score
#' @export
print.summary.mfrm_calibration_score <- function(x, ...) {
  if (!inherits(x, "summary.mfrm_calibration_score")) {
    stop(
      "`x` must be output from summary() on a portable calibration score.",
      call. = FALSE
    )
  }
  overview <- x$overview[1L, , drop = FALSE]
  cat("mfrmr Portable Calibration Score Summary\n")
  cat(
    "  Calibration: ", overview$CalibrationId, "\n",
    "  Model / estimator: ", overview$Model, " / ", overview$Estimator, "\n",
    "  Persons: ", overview$Scored, " scored (", overview$Review,
    " requiring review); ", overview$NotScored, " not scored\n",
    sep = ""
  )
  if (nrow(x$estimates) > 0L) {
    cat("\nPosterior estimates (first 10)\n")
    print(utils::head(x$estimates, 10L), row.names = FALSE)
  }
  if (nrow(x$review) > 0L) {
    cat("\nPersons requiring review or not scored\n")
    print(x$review, row.names = FALSE)
  }
  if (nrow(x$row_review) > 0L) {
    cat("\nResponse-row disposition\n")
    print(x$row_review, row.names = FALSE)
  }
  cat(
    "\nInterpretation boundary\n",
    "  Posterior SDs and intervals are conditional on the frozen point ",
    "calibration and exclude calibration-parameter uncertainty.\n",
    sep = ""
  )
  invisible(x)
}

mfrmr_calibration_score_top_n <- function(top_n) {
  if (is.numeric(top_n) && length(top_n) == 1L && is.infinite(top_n) &&
      top_n > 0) {
    return(Inf)
  }
  if (!is.numeric(top_n) || length(top_n) != 1L || !is.finite(top_n) ||
      top_n < 1 || top_n != floor(top_n)) {
    stop("`top_n` must be one positive integer or `Inf`.", call. = FALSE)
  }
  as.integer(top_n)
}

mfrmr_calibration_score_plot_table <- function(x, top_n, sort_by) {
  estimates <- as.data.frame(x$estimates, stringsAsFactors = FALSE)
  required <- c(
    "Person", "Estimate", "SD", "Lower", "Upper", "Observations",
    "Disposition", "ReasonCodes", "ReadinessStatus"
  )
  missing <- setdiff(required, names(estimates))
  if (length(missing) > 0L) {
    stop(
      "The score result is missing plot field(s): ",
      paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }
  if (nrow(estimates) == 0L) {
    stop(
      "No scored Person coordinate is available to plot; inspect ",
      "`summary(x)$review`.",
      call. = FALSE
    )
  }
  numeric_fields <- c("Estimate", "SD", "Lower", "Upper", "Observations")
  estimates[numeric_fields] <- lapply(
    estimates[numeric_fields], function(value) suppressWarnings(as.numeric(value))
  )
  if (any(!is.finite(as.matrix(estimates[numeric_fields])))) {
    stop("The score result contains non-finite plot coordinates.", call. = FALSE)
  }

  dispositions <- as.data.frame(
    x$person_dispositions, stringsAsFactors = FALSE
  )
  disposition_index <- match(estimates$Person, dispositions$Person)
  for (field in c(
    "EndpointStatus", "VerySparsePattern", "QuadratureEdgeMass",
    "QuadratureEdgeThreshold", "AdministrationCompleteness"
  )) {
    estimates[[field]] <- if (field %in% names(dispositions)) {
      dispositions[[field]][disposition_index]
    } else {
      NA
    }
  }
  estimates$QuadratureEdgeMass <- suppressWarnings(as.numeric(
    estimates$QuadratureEdgeMass
  ))
  estimates$QuadratureEdgeThreshold <- suppressWarnings(as.numeric(
    estimates$QuadratureEdgeThreshold
  ))
  estimates$ReviewFlag <- as.character(estimates$Disposition) != "scored" |
    as.character(estimates$ReadinessStatus) != "conditional_score_ready"
  estimates$ReviewLabel <- ifelse(
    estimates$ReviewFlag, as.character(estimates$Person), ""
  )

  priority <- switch(
    sort_by,
    estimate = -abs(estimates$Estimate),
    sd = -estimates$SD,
    person = xtfrm(as.character(estimates$Person))
  )
  selection_order <- order(!estimates$ReviewFlag, priority, method = "radix")
  selected <- if (is.infinite(top_n) || nrow(estimates) <= top_n) {
    seq_len(nrow(estimates))
  } else {
    selection_order[seq_len(top_n)]
  }
  estimates$Selected <- seq_len(nrow(estimates)) %in% selected
  selected_table <- estimates[selected, , drop = FALSE]
  display_order <- order(
    selected_table$Estimate, as.character(selected_table$Person),
    method = "radix"
  )
  selected_table <- selected_table[display_order, , drop = FALSE]
  selected_table$DisplayOrder <- seq_len(nrow(selected_table))

  list(full = estimates, selected = selected_table)
}

#' @rdname mfrm_calibration_score_methods
#' @method plot mfrm_calibration_score
#' @export
plot.mfrm_calibration_score <- function(
    x,
    type = c("interval", "precision", "edge_mass"),
    top_n = 40L,
    sort_by = c("estimate", "sd", "person"),
    label_review = TRUE,
    main = NULL,
    draw = TRUE,
    preset = c("standard", "publication", "compact", "monochrome"),
    ...) {
  mfrmr_validate_calibration_score(x)
  type <- match.arg(type)
  sort_by <- match.arg(sort_by)
  top_n <- mfrmr_calibration_score_top_n(top_n)
  if (!is.logical(label_review) || length(label_review) != 1L ||
      is.na(label_review)) {
    stop("`label_review` must be `TRUE` or `FALSE`.", call. = FALSE)
  }
  if (!is.logical(draw) || length(draw) != 1L || is.na(draw)) {
    stop("`draw` must be `TRUE` or `FALSE`.", call. = FALSE)
  }
  style <- resolve_plot_preset(preset)
  tables <- mfrmr_calibration_score_plot_table(x, top_n, sort_by)
  plotted <- tables$selected
  full <- tables$full
  dispositions <- as.data.frame(
    x$person_dispositions, stringsAsFactors = FALSE
  )
  not_scored <- dispositions[
    as.character(dispositions$Disposition) == "not_scored",
    ,
    drop = FALSE
  ]
  review_available <- sum(full$ReviewFlag)
  review_plotted <- sum(plotted$ReviewFlag)
  title <- as.character(main %||% switch(
    type,
    interval = "Portable calibration score intervals",
    precision = "Conditional score precision",
    edge_mass = "Quadrature edge-mass review"
  ))
  subtitle <- paste0(
    nrow(plotted), " of ", nrow(full), " scored Persons shown; ",
    review_plotted, " review disposition(s) shown"
  )
  uncertainty_note <- paste(
    "Posterior uncertainty is conditional on the frozen point calibration",
    "and excludes calibration-parameter uncertainty."
  )
  selection_summary <- data.frame(
    ScoredPersons = as.integer(nrow(full)),
    PlottedPersons = as.integer(nrow(plotted)),
    OmittedFromPlot = as.integer(nrow(full) - nrow(plotted)),
    ReviewPersonsAvailable = as.integer(review_available),
    ReviewPersonsPlotted = as.integer(review_plotted),
    NotScoredPersons = as.integer(nrow(not_scored)),
    ReviewRowsPrioritized = TRUE,
    SelectionPriority = sort_by,
    stringsAsFactors = FALSE
  )
  legend <- new_plot_legend(
    label = c("Scored", "Review"),
    role = c("conditional score ready", "inspect disposition and reason codes"),
    aesthetic = c("color", "color"),
    value = c(style$accent_primary, style$warn)
  )
  edge_threshold <- unique(plotted$QuadratureEdgeThreshold[
    is.finite(plotted$QuadratureEdgeThreshold)
  ])
  reference_lines <- switch(
    type,
    interval = new_reference_lines(
      axis = "v", value = 0, label = "Prior mean / scale origin",
      linetype = "dashed", role = "reference"
    ),
    precision = new_reference_lines(),
    edge_mass = if (length(edge_threshold) > 0L) {
      new_reference_lines(
        axis = "h", value = edge_threshold[1L],
        label = "Recorded edge-mass review threshold",
        linetype = "dashed", role = "review threshold"
      )
    } else {
      new_reference_lines()
    }
  )

  if (isTRUE(draw)) {
    apply_plot_preset(style)
    point_color <- ifelse(
      plotted$ReviewFlag, style$warn, style$accent_primary
    )
    point_shape <- ifelse(plotted$ReviewFlag, 17L, 16L)
    if (identical(type, "interval")) {
      x_range <- range(c(plotted$Lower, plotted$Upper, 0), finite = TRUE)
      if (diff(x_range) <= 0) x_range <- x_range + c(-0.5, 0.5)
      old_mar <- graphics::par("mar")
      on.exit(graphics::par(mar = old_mar), add = TRUE)
      graphics::par(mar = c(5.2, 8.2, 4.2, 1.5))
      graphics::plot(
        plotted$Estimate, plotted$DisplayOrder,
        xlim = x_range, ylim = c(0.5, nrow(plotted) + 0.5),
        yaxt = "n", ylab = "", xlab = "Posterior EAP (logits)",
        main = title, pch = point_shape, col = point_color
      )
      graphics::abline(v = 0, lty = 2, col = style$neutral)
      graphics::segments(
        plotted$Lower, plotted$DisplayOrder,
        plotted$Upper, plotted$DisplayOrder,
        col = point_color, lwd = 1.5
      )
      graphics::points(
        plotted$Estimate, plotted$DisplayOrder,
        pch = point_shape, col = point_color
      )
      graphics::axis(
        2, at = plotted$DisplayOrder, labels = plotted$Person,
        las = 1, cex.axis = style$axis_cex
      )
    } else if (identical(type, "precision")) {
      x_range <- range(plotted$Observations, finite = TRUE)
      if (diff(x_range) <= 0) {
        padding <- max(1, abs(x_range[1L]) * 0.06)
        x_range <- x_range + c(-padding, padding)
      }
      y_range <- range(plotted$SD, finite = TRUE)
      if (diff(y_range) <= 0) y_range <- y_range + c(-0.05, 0.05)
      y_padding <- max(diff(y_range) * 0.14, 0.01)
      y_range <- y_range + c(-y_padding * 0.2, y_padding)
      graphics::plot(
        plotted$Observations, plotted$SD,
        xlim = x_range, ylim = y_range,
        xlab = "Valid response rows", ylab = "Posterior SD (logits)",
        main = title, pch = point_shape, col = point_color
      )
      if (isTRUE(label_review) && any(plotted$ReviewFlag)) {
        review_index <- which(plotted$ReviewFlag)
        label_position <- rep(c(2L, 4L, 3L), length.out = length(review_index))
        for (i in seq_along(review_index)) {
          row <- review_index[i]
          graphics::text(
            plotted$Observations[row], plotted$SD[row],
            labels = plotted$Person[row],
            pos = label_position[i], cex = 0.75, col = style$warn
          )
        }
      }
    } else {
      edge_mass <- plotted$QuadratureEdgeMass
      edge_mass[!is.finite(edge_mass)] <- NA_real_
      maximum <- max(c(edge_mass, edge_threshold, 0), na.rm = TRUE)
      if (!is.finite(maximum) || maximum <= 0) maximum <- 1
      graphics::plot(
        plotted$Estimate, edge_mass,
        ylim = c(0, maximum * 1.08),
        xlab = "Posterior EAP (logits)",
        ylab = "Posterior mass at outer quadrature nodes",
        main = title, pch = point_shape, col = point_color
      )
      if (length(edge_threshold) > 0L) {
        graphics::abline(h = edge_threshold[1L], lty = 2, col = style$warn)
      }
      if (isTRUE(label_review) && any(plotted$ReviewFlag)) {
        graphics::text(
          plotted$Estimate[plotted$ReviewFlag],
          edge_mass[plotted$ReviewFlag],
          labels = plotted$Person[plotted$ReviewFlag],
          pos = 3, cex = 0.75, col = style$warn
        )
      }
    }
    graphics::legend(
      "topleft", legend = c("Scored", "Review"),
      pch = c(16L, 17L), col = c(style$accent_primary, style$warn),
      bty = "o", bg = style$background, box.col = style$background,
      cex = 0.78
    )
    graphics::mtext(subtitle, side = 3, line = 0.25, cex = 0.72)
    graphics::mtext(uncertainty_note, side = 1, line = 3.8, cex = 0.72)
  }

  interpretation <- data.frame(
    Topic = c(
      "Review color", "Not scored", "Interval basis", "Use boundary"
    ),
    Guidance = c(
      "Inspect ReasonCodes before using a highlighted score in a decision.",
      "Persons without a score coordinate remain in unplotted_dispositions.",
      uncertainty_note,
      "This display reviews a score batch; it does not establish calibration fit or validity."
    ),
    stringsAsFactors = FALSE
  )
  out <- new_mfrm_plot_data(
    paste0("calibration_score_", type),
    list(
      data = plotted,
      selection_summary = selection_summary,
      unplotted_dispositions = not_scored,
      interpretation = interpretation,
      settings = list(
        type = type,
        top_n = top_n,
        sort_by = sort_by,
        label_review = label_review,
        interval_level = x$settings$interval_level,
        uncertainty_basis = "conditional_on_frozen_point_calibration",
        calibration_id = x$settings$calibration_id,
        preset = style$name
      ),
      title = title,
      subtitle = subtitle,
      caption = uncertainty_note,
      legend = legend,
      reference_lines = reference_lines
    )
  )
  invisible(out)
}
