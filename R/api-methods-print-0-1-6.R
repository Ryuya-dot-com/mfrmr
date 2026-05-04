# Lightweight print delegates added in 0.1.6 to close the first-use surface.
#
# NEWS 0.1.5 committed to `Status`, `Key warnings`, and `Next actions`
# leading every first-use print, but 13 classes shipped only `summary()`
# methods. Without a matching `print()` S3, typing the object at the R
# console fell back to the default list printer and dumped hundreds of
# rows of raw tables.
#
# Most delegates route `print(x)` through `summary(x)`, so the curated
# first-use output defined in the summary methods becomes the console
# default. `mfrm_apa_outputs` is the exception: its direct print method
# is manuscript-facing, with `qa = TRUE` retaining the summary/checklist
# route.

#' Print an APA reporting bundle
#'
#' @param x Output from [build_apa_outputs()].
#' @param include_notes Logical. If `TRUE`, append `table_figure_notes`
#'   after the manuscript narrative.
#' @param include_captions Logical. If `TRUE`, append
#'   `table_figure_captions` after the manuscript narrative.
#' @param qa Logical. If `TRUE`, print the compact QA summary returned by
#'   `summary(x, ...)` instead of the manuscript narrative. This is the
#'   compatibility route for workflows that previously used bare `apa` as a
#'   completeness check.
#' @param ... Optional arguments passed to `summary(x, ...)` when `qa = TRUE`.
#'   Legacy `top_n` and `preview_chars` arguments also trigger `qa = TRUE`
#'   with a warning, so old QA-preview calls do not silently print narrative
#'   text.
#'
#' @details
#' Typing an `mfrm_apa_outputs` object at the console prints the concise
#' Method / Results draft stored in `x$report_text`. Use `summary(x)` or
#' `print(x, qa = TRUE)` for the structured QA surface with content checks,
#' component counts, and section availability.
#'
#' @examples
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 15)
#' diag <- diagnose_mfrm(fit, residual_pca = "none",
#'                       diagnostic_mode = "legacy")
#' apa <- build_apa_outputs(fit, diag)
#' apa
#' summary(apa)
#' print(apa, qa = TRUE, top_n = 2)
#' @export
print.mfrm_apa_outputs <- function(x,
                                   include_notes = FALSE,
                                   include_captions = FALSE,
                                   qa = FALSE,
                                   ...) {
  dots <- list(...)
  legacy_summary_args <- c("top_n", "preview_chars")
  named_dots <- names(dots)
  legacy_hit <- length(dots) > 0L &&
    !is.null(named_dots) &&
    any(named_dots %in% legacy_summary_args)

  if (isTRUE(qa) || isTRUE(legacy_hit)) {
    if (!isTRUE(qa) && isTRUE(legacy_hit)) {
      warning(
        "`top_n` and `preview_chars` now configure `summary(apa)`. ",
        "Printing the APA QA summary for compatibility; use ",
        "`print(apa, qa = TRUE, ...)` or `summary(apa, ...)` explicitly.",
        call. = FALSE
      )
    }
    print(do.call(summary, c(list(object = x), dots)))
    return(invisible(x))
  }

  if (length(dots) > 0L) {
    labels <- if (!is.null(named_dots) && any(nzchar(named_dots))) {
      paste(named_dots[nzchar(named_dots)], collapse = ", ")
    } else {
      "unnamed arguments"
    }
    warning(
      "Unused argument(s) in `print.mfrm_apa_outputs()`: ",
      labels,
      ". Use `summary(apa, ...)` or `print(apa, qa = TRUE, ...)` for QA options.",
      call. = FALSE
    )
  }
  cat(as.character(x$report_text %||% ""), "\n", sep = "")
  if (isTRUE(include_notes) && length(x$table_figure_notes) > 0) {
    cat("\nTable/Figure notes.\n\n")
    cat(as.character(x$table_figure_notes), "\n", sep = "")
  }
  if (isTRUE(include_captions) && length(x$table_figure_captions) > 0) {
    cat("\nTable/Figure captions.\n\n")
    cat(as.character(x$table_figure_captions), "\n", sep = "")
  }
  invisible(x)
}

#' @export
print.mfrm_bias <- function(x, ...) {
  print(summary(x), ...)
  invisible(x)
}

#' @export
print.mfrm_bundle <- function(x, ...) {
  print(summary(x), ...)
  invisible(x)
}

#' @export
print.mfrm_design_evaluation <- function(x, ...) {
  print(summary(x), ...)
  invisible(x)
}

#' @export
print.mfrm_diagnostics <- function(x, ...) {
  print(summary(x), ...)
  invisible(x)
}

#' @export
print.mfrm_facet_dashboard <- function(x, ...) {
  print(summary(x), ...)
  invisible(x)
}

#' @export
print.mfrm_future_branch_active_branch <- function(x, ...) {
  print(summary(x), ...)
  invisible(x)
}

#' @export
print.mfrm_plausible_values <- function(x, ...) {
  print(summary(x), ...)
  invisible(x)
}

#' @export
print.mfrm_population_prediction <- function(x, ...) {
  print(summary(x), ...)
  invisible(x)
}

#' @export
print.mfrm_reporting_checklist <- function(x, ...) {
  print(summary(x), ...)
  invisible(x)
}

#' @export
print.mfrm_signal_detection <- function(x, ...) {
  print(summary(x), ...)
  invisible(x)
}

#' @export
print.mfrm_threshold_profiles <- function(x, ...) {
  print(summary(x), ...)
  invisible(x)
}

#' @export
print.mfrm_unit_prediction <- function(x, ...) {
  print(summary(x), ...)
  invisible(x)
}
