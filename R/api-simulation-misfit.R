mfrm_simulation_misfit_columns <- function() {
  c(
    "MeanZSTDMisfitRate", "McseZSTDMisfitRate",
    "MeanMnSqMisfitRate", "McseMnSqMisfitRate",
    "MeanUnderfitRate", "McseUnderfitRate",
    "MeanOverfitRate", "McseOverfitRate",
    "MeanMixedMisfitRate", "McseMixedMisfitRate",
    "MeanInBandRate", "McseInBandRate",
    "MeanMisfitClassified"
  )
}

mfrm_simulation_misfit_empty <- function() {
  out <- tibble::tibble(
    Facet = character(0),
    Reps = integer(0),
    MeanZSTDMisfitRate = numeric(0),
    McseZSTDMisfitRate = numeric(0),
    MeanMnSqMisfitRate = numeric(0),
    McseMnSqMisfitRate = numeric(0),
    MeanUnderfitRate = numeric(0),
    McseUnderfitRate = numeric(0),
    MeanOverfitRate = numeric(0),
    McseOverfitRate = numeric(0),
    MeanMixedMisfitRate = numeric(0),
    McseMixedMisfitRate = numeric(0),
    MeanInBandRate = numeric(0),
    McseInBandRate = numeric(0),
    MeanMisfitClassified = numeric(0)
  )
  class(out) <- c("mfrm_simulation_misfit_summary", class(out))
  out
}

mfrm_simulation_misfit_source <- function(x) {
  if (inherits(x, "mfrm_design_evaluation")) {
    aliases <- simulation_object_design_variable_aliases(x)
    descriptor <- simulation_object_design_descriptor(x)
    tbl <- tibble::as_tibble(x$results)
    for (nm in c("MisfitRate", "MnSqMisfitRate", "UnderfitRate",
                 "OverfitRate", "MixedMisfitRate", "InBandRate",
                 "MisfitClassified")) {
      if (!nm %in% names(tbl)) tbl[[nm]] <- NA_real_
    }
    return(list(
      table = tbl,
      source = "results",
      design_variable_aliases = aliases,
      design_descriptor = descriptor
    ))
  }
  if (inherits(x, "summary.mfrm_design_evaluation")) {
    aliases <- x$design_variable_aliases %||% character(0)
    descriptor <- x$design_descriptor %||% NULL
    tbl <- tibble::as_tibble(x$design_summary)
    return(list(
      table = tbl,
      source = "design_summary",
      design_variable_aliases = aliases,
      design_descriptor = descriptor
    ))
  }
  if (inherits(x, "mfrm_simulation_misfit_summary")) {
    return(list(
      table = tibble::as_tibble(x),
      source = "misfit_summary",
      design_variable_aliases = attr(x, "design_variable_aliases") %||% character(0),
      design_descriptor = attr(x, "design_descriptor") %||% NULL
    ))
  }
  if (is.data.frame(x)) {
    return(list(
      table = tibble::as_tibble(x),
      source = "data_frame",
      design_variable_aliases = character(0),
      design_descriptor = NULL
    ))
  }
  stop("`x` must be output from evaluate_mfrm_design(), summary(), or summarize_simulation_misfit().",
       call. = FALSE)
}

mfrm_resolve_simulation_misfit_by <- function(by, aliases, descriptor, available) {
  if (is.null(by)) {
    out <- c("design_id", "Facet", simulation_design_canonical_variables(descriptor))
    return(unique(out[out %in% available]))
  }
  vals <- unique(as.character(by))
  vals <- vals[!is.na(vals) & nzchar(vals)]
  if (length(vals) == 0L) {
    return(character(0))
  }
  out <- character(0)
  for (val in vals) {
    if (identical(tolower(val), "facet") && "Facet" %in% available) {
      out <- c(out, "Facet")
    } else if (val %in% available) {
      out <- c(out, val)
    } else {
      resolved <- simulation_resolve_design_variable(
        val,
        aliases,
        "by",
        descriptor = descriptor
      )
      if (resolved %in% available) out <- c(out, resolved)
    }
  }
  unique(out)
}

mfrm_weighted_mean <- function(x, w) {
  x <- suppressWarnings(as.numeric(x))
  w <- suppressWarnings(as.numeric(w))
  ok <- is.finite(x) & is.finite(w) & w > 0
  if (!any(ok)) return(NA_real_)
  stats::weighted.mean(x[ok], w[ok])
}

mfrm_weighted_mcse <- function(x, w) {
  x <- suppressWarnings(as.numeric(x))
  w <- suppressWarnings(as.numeric(w))
  ok <- is.finite(x) & is.finite(w) & w > 0
  if (!any(ok)) return(NA_real_)
  sqrt(sum((w[ok] * x[ok])^2)) / sum(w[ok])
}

mfrm_summarize_design_summary_misfit <- function(tbl, group_vars) {
  if (!"MeanZSTDMisfitRate" %in% names(tbl) && "MeanMisfitRate" %in% names(tbl)) {
    tbl$MeanZSTDMisfitRate <- tbl$MeanMisfitRate
  }
  if (!"McseZSTDMisfitRate" %in% names(tbl) && "McseMisfitRate" %in% names(tbl)) {
    tbl$McseZSTDMisfitRate <- tbl$McseMisfitRate
  }
  for (nm in mfrm_simulation_misfit_columns()) {
    if (!nm %in% names(tbl)) tbl[[nm]] <- NA_real_
  }
  if (!"Reps" %in% names(tbl)) tbl$Reps <- NA_real_
  if (length(group_vars) == 0L) {
    tbl$.All <- "All conditions"
    group_vars <- ".All"
  }
  out <- tbl |>
    dplyr::group_by(dplyr::across(dplyr::all_of(group_vars))) |>
    dplyr::summarize(
      Reps = sum(.data$Reps, na.rm = TRUE),
      MeanZSTDMisfitRate = mfrm_weighted_mean(.data$MeanZSTDMisfitRate, .data$Reps),
      McseZSTDMisfitRate = mfrm_weighted_mcse(.data$McseZSTDMisfitRate, .data$Reps),
      MeanMnSqMisfitRate = mfrm_weighted_mean(.data$MeanMnSqMisfitRate, .data$Reps),
      McseMnSqMisfitRate = mfrm_weighted_mcse(.data$McseMnSqMisfitRate, .data$Reps),
      MeanUnderfitRate = mfrm_weighted_mean(.data$MeanUnderfitRate, .data$Reps),
      McseUnderfitRate = mfrm_weighted_mcse(.data$McseUnderfitRate, .data$Reps),
      MeanOverfitRate = mfrm_weighted_mean(.data$MeanOverfitRate, .data$Reps),
      McseOverfitRate = mfrm_weighted_mcse(.data$McseOverfitRate, .data$Reps),
      MeanMixedMisfitRate = mfrm_weighted_mean(.data$MeanMixedMisfitRate, .data$Reps),
      McseMixedMisfitRate = mfrm_weighted_mcse(.data$McseMixedMisfitRate, .data$Reps),
      MeanInBandRate = mfrm_weighted_mean(.data$MeanInBandRate, .data$Reps),
      McseInBandRate = mfrm_weighted_mcse(.data$McseInBandRate, .data$Reps),
      MeanMisfitClassified = mfrm_weighted_mean(.data$MeanMisfitClassified, .data$Reps),
      .groups = "drop"
    )
  if (".All" %in% names(out)) out <- dplyr::select(out, -dplyr::all_of(".All"))
  out
}

mfrm_summarize_raw_results_misfit <- function(tbl, group_vars) {
  for (nm in c("MisfitRate", "MnSqMisfitRate", "UnderfitRate", "OverfitRate",
               "MixedMisfitRate", "InBandRate", "MisfitClassified")) {
    if (!nm %in% names(tbl)) tbl[[nm]] <- NA_real_
  }
  if (length(group_vars) == 0L) {
    tbl$.All <- "All conditions"
    group_vars <- ".All"
  }
  out <- tbl |>
    dplyr::group_by(dplyr::across(dplyr::all_of(group_vars))) |>
    dplyr::summarize(
      Reps = dplyr::n(),
      MeanZSTDMisfitRate = mean(.data$MisfitRate, na.rm = TRUE),
      McseZSTDMisfitRate = simulation_mcse_mean(.data$MisfitRate),
      MeanMnSqMisfitRate = mean(.data$MnSqMisfitRate, na.rm = TRUE),
      McseMnSqMisfitRate = simulation_mcse_mean(.data$MnSqMisfitRate),
      MeanUnderfitRate = mean(.data$UnderfitRate, na.rm = TRUE),
      McseUnderfitRate = simulation_mcse_mean(.data$UnderfitRate),
      MeanOverfitRate = mean(.data$OverfitRate, na.rm = TRUE),
      McseOverfitRate = simulation_mcse_mean(.data$OverfitRate),
      MeanMixedMisfitRate = mean(.data$MixedMisfitRate, na.rm = TRUE),
      McseMixedMisfitRate = simulation_mcse_mean(.data$MixedMisfitRate),
      MeanInBandRate = mean(.data$InBandRate, na.rm = TRUE),
      McseInBandRate = simulation_mcse_mean(.data$InBandRate),
      MeanMisfitClassified = mean(.data$MisfitClassified, na.rm = TRUE),
      .groups = "drop"
    )
  if (".All" %in% names(out)) out <- dplyr::select(out, -dplyr::all_of(".All"))
  out
}

#' Summarize simulation misfit rates by direction
#'
#' Extract or aggregate the directional misfit rates from
#' [evaluate_mfrm_design()]. Unlike the legacy `MeanMisfitRate` column, which
#' reports the proportion of levels with \eqn{|ZSTD| > 2}, this helper separates
#' MnSq-band directions: underfit, overfit, mixed, and in-band.
#'
#' @param x Output from [evaluate_mfrm_design()], its `summary()`, or a data
#'   frame with the same columns.
#' @param by Optional grouping variables. `NULL` keeps the design-by-facet
#'   grouping. Public design-variable aliases and the keyword `facet` are
#'   accepted when available.
#' @param digits Optional number of digits for numeric columns. `NULL` leaves
#'   values unrounded.
#'
#' @return A data frame of class `mfrm_simulation_misfit_summary`.
#' @seealso [evaluate_mfrm_design()], [plot_simulation_misfit_rates()],
#'   [fit_direction_summary()]
#' @examples
#' \donttest{
#' sim_eval <- suppressWarnings(evaluate_mfrm_design(
#'   n_person = 20,
#'   n_rater = 3,
#'   n_criterion = 2,
#'   raters_per_person = 2,
#'   reps = 1,
#'   maxit = 10,
#'   seed = 42
#' ))
#' summarize_simulation_misfit(sim_eval)
#' }
#' @export
summarize_simulation_misfit <- function(x, by = NULL, digits = NULL) {
  src <- mfrm_simulation_misfit_source(x)
  tbl <- src$table
  if (!is.data.frame(tbl) || nrow(tbl) == 0L) {
    out <- mfrm_simulation_misfit_empty()
    attr(out, "design_variable_aliases") <- src$design_variable_aliases
    attr(out, "design_descriptor") <- src$design_descriptor
    attr(out, "source") <- src$source
    return(out)
  }
  group_vars <- mfrm_resolve_simulation_misfit_by(
    by = by,
    aliases = src$design_variable_aliases,
    descriptor = src$design_descriptor,
    available = names(tbl)
  )
  out <- if (identical(src$source, "results")) {
    mfrm_summarize_raw_results_misfit(tbl, group_vars)
  } else if (identical(src$source, "design_summary") ||
             identical(src$source, "misfit_summary")) {
    mfrm_summarize_design_summary_misfit(tbl, group_vars)
  } else if ("MisfitRate" %in% names(tbl) || "MnSqMisfitRate" %in% names(tbl)) {
    mfrm_summarize_raw_results_misfit(tbl, group_vars)
  } else {
    mfrm_summarize_design_summary_misfit(tbl, group_vars)
  }
  if (!is.null(digits)) {
    digits <- max(0L, as.integer(digits[1]))
    num_cols <- vapply(out, is.numeric, logical(1))
    out[num_cols] <- lapply(out[num_cols], round, digits = digits)
  }
  class(out) <- c("mfrm_simulation_misfit_summary", class(out))
  attr(out, "design_variable_aliases") <- src$design_variable_aliases
  attr(out, "design_descriptor") <- src$design_descriptor
  attr(out, "source") <- src$source
  out
}

mfrm_simulation_misfit_long <- function(tbl,
                                        directions = c("underfit", "overfit", "mixed", "in_band")) {
  directions <- unique(as.character(directions))
  directions <- directions[directions %in% c("underfit", "overfit", "mixed", "in_band", "mnsq_any", "zstd_any")]
  if (length(directions) == 0L) {
    stop("`directions` must include at least one recognized direction.", call. = FALSE)
  }
  cols <- c(
    underfit = "MeanUnderfitRate",
    overfit = "MeanOverfitRate",
    mixed = "MeanMixedMisfitRate",
    in_band = "MeanInBandRate",
    mnsq_any = "MeanMnSqMisfitRate",
    zstd_any = "MeanZSTDMisfitRate"
  )
  pieces <- lapply(directions, function(direction) {
    col <- unname(cols[[direction]])
    out <- tbl
    out$Direction <- direction
    out$Rate <- if (col %in% names(out)) suppressWarnings(as.numeric(out[[col]])) else NA_real_
    out
  })
  dplyr::bind_rows(pieces)
}

#' Plot simulation underfit and overfit rates
#'
#' Plot directional misfit rates from [summarize_simulation_misfit()]. With
#' `draw = FALSE`, the function returns a tidy plotting payload for custom
#' graphics.
#'
#' @param x Output from [evaluate_mfrm_design()], `summary()`, or
#'   [summarize_simulation_misfit()].
#' @param facet Optional facet filter.
#' @param x_var Design variable for the x-axis. When `NULL`, the first varying
#'   design variable is used; if none varies, `Facet` is used.
#' @param group_var Optional design variable used in labels.
#' @param directions Direction rates to include. Use `mnsq_any` for all
#'   MnSq-band flags and `zstd_any` for the legacy \eqn{|ZSTD| > 2} rate.
#' @param draw If `TRUE`, draw a stacked base-R bar chart.
#'
#' @return An `mfrm_plot_data` object.
#' @seealso [summarize_simulation_misfit()], [evaluate_mfrm_design()],
#'   [plot_fit_direction_summary()]
#' @examples
#' \donttest{
#' sim_eval <- suppressWarnings(evaluate_mfrm_design(
#'   n_person = c(20, 30),
#'   n_rater = 3,
#'   n_criterion = 2,
#'   raters_per_person = 2,
#'   reps = 1,
#'   maxit = 10,
#'   seed = 42
#' ))
#' plot_simulation_misfit_rates(sim_eval, draw = FALSE)
#' }
#' @export
plot_simulation_misfit_rates <- function(x,
                                         facet = NULL,
                                         x_var = NULL,
                                         group_var = NULL,
                                         directions = c("underfit", "overfit", "mixed"),
                                         draw = TRUE) {
  if (inherits(x, "mfrm_simulation_misfit_summary")) {
    sum_tbl <- x
    aliases <- attr(x, "design_variable_aliases") %||% character(0)
    descriptor <- attr(x, "design_descriptor") %||% NULL
  } else {
    sum_tbl <- summarize_simulation_misfit(x)
    aliases <- attr(sum_tbl, "design_variable_aliases") %||% character(0)
    descriptor <- attr(sum_tbl, "design_descriptor") %||% NULL
  }
  sum_tbl <- tibble::as_tibble(sum_tbl)
  if (!is.null(facet) && "Facet" %in% names(sum_tbl)) {
    facet <- as.character(facet[1])
    sum_tbl <- sum_tbl[as.character(sum_tbl$Facet) == facet, , drop = FALSE]
  }
  if (nrow(sum_tbl) == 0L) {
    stop("No simulation misfit rows are available for plotting.", call. = FALSE)
  }

  design_vars <- simulation_design_canonical_variables(descriptor)
  available_design_vars <- design_vars[design_vars %in% names(sum_tbl)]
  if (is.null(x_var)) {
    varying <- available_design_vars[
      vapply(sum_tbl[available_design_vars], function(col) length(unique(col)) > 1L, logical(1))
    ]
    x_var <- if (length(varying) > 0L) varying[1] else if ("Facet" %in% names(sum_tbl)) "Facet" else names(sum_tbl)[1]
  } else if (!identical(tolower(as.character(x_var[1])), "facet")) {
    x_var <- simulation_resolve_design_variable(x_var, aliases, "x_var", descriptor = descriptor)
  } else {
    x_var <- "Facet"
  }
  if (!x_var %in% names(sum_tbl)) {
    stop("`x_var` is not present in the simulation misfit summary.", call. = FALSE)
  }
  if (!is.null(group_var)) {
    if (identical(tolower(as.character(group_var[1])), "facet")) {
      group_var <- "Facet"
    } else {
      group_var <- simulation_resolve_design_variable(group_var, aliases, "group_var", descriptor = descriptor)
    }
    if (!group_var %in% names(sum_tbl)) {
      stop("`group_var` is not present in the simulation misfit summary.", call. = FALSE)
    }
  }

  long_tbl <- mfrm_simulation_misfit_long(sum_tbl, directions = directions)
  long_tbl$Panel <- as.character(long_tbl[[x_var]])
  if (!is.null(group_var)) {
    long_tbl$Panel <- paste(long_tbl$Panel, long_tbl[[group_var]], sep = " | ")
  } else if (!identical(x_var, "Facet") && "Facet" %in% names(long_tbl)) {
    long_tbl$Panel <- paste(long_tbl$Panel, long_tbl$Facet, sep = " | ")
  }

  if (isTRUE(draw)) {
    panels <- unique(as.character(long_tbl$Panel))
    dirs <- unique(as.character(long_tbl$Direction))
    mat <- matrix(0, nrow = length(dirs), ncol = length(panels),
                  dimnames = list(dirs, panels))
    for (i in seq_len(nrow(long_tbl))) {
      mat[as.character(long_tbl$Direction[i]), as.character(long_tbl$Panel[i])] <- long_tbl$Rate[i]
    }
    pal <- c(
      underfit = "#C43C39",
      overfit = "#2C7BB6",
      mixed = "#8E5EA2",
      in_band = "#74A57F",
      mnsq_any = "#6B7280",
      zstd_any = "#F59E0B"
    )
    graphics::barplot(
      mat,
      beside = FALSE,
      col = unname(pal[rownames(mat)]),
      las = 2,
      ylim = c(0, 1),
      ylab = "Mean proportion",
      main = "Simulation misfit direction rates"
    )
    graphics::legend("topright", legend = rownames(mat), fill = unname(pal[rownames(mat)]), bty = "n")
  }

  out <- new_mfrm_plot_data(
    "simulation_misfit_rates",
    list(
      data = long_tbl,
      summary = sum_tbl,
      directions = unique(as.character(long_tbl$Direction)),
      x_var = x_var,
      group_var = group_var,
      title = "Simulation misfit direction rates"
    )
  )
  invisible(out)
}
