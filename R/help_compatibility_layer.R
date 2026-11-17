#' @section Saved-analysis refresh and compatibility surface:
#' Installing an update does not recalculate saved objects on disk. Check
#' `summary(fit)$decision` first: if an early saved fit lacks current
#' terminal-gradient or category-support checks, refit from the original data
#' and settings; otherwise regenerate affected [diagnose_mfrm()],
#' [compare_mfrm()], [analyze_dff()], [estimate_bias()],
#' [compute_facet_icc()], or [predict_mfrm_units()] outputs from the saved fit
#' before rebuilding reports or CSV exports. Saved `0.2.x` G-Study/D-Study and
#' plot payloads (`mfrm_plot_data`) work directly with `summary()`, `plot()`,
#' [plot_data()], and [as_ggplot()].
#'
#' Legacy FACETS-oriented wrappers ([run_mfrm_facets()], [build_fixed_reports()],
#' [facets_output_file_bundle()], [write_mfrm_residual_file()],
#' [write_mfrm_subset_file()]) are presentation and handoff contracts, not claims
#' of FACETS, ConQuest, or SPSS numerical equivalence.
#'
#' @aliases mfrmr_compatibility_layer
#' @rdname mfrmr_api_migration_030
#' @name mfrmr_compatibility_layer
NULL

#' @param scope Which alias surface to return in `compatibility_alias_table()`:
#'   `"all"`, `"functions"`, `"arguments"`, `"fields"`, `"columns"`, or
#'   `"plot_metrics"`.
#' @return `compatibility_alias_table()` returns a `data.frame` with columns
#'   `Alias`, `PreferredName`, `Surface`, `Lifecycle` (`"retained_alias"` or
#'   `"removed_export"`), `RetainedFor`, `RemovalPlan`, and `Notes`.
#' @examples
#' compatibility_alias_table("functions")
#' @rdname mfrmr_api_migration_030
#' @export
compatibility_alias_table <- function(scope = c("all", "functions", "arguments", "fields", "columns", "plot_metrics")) {
  scope <- match.arg(scope)

  out <- .mfrmr_table_compatibility_alias_table_out

  if (identical(scope, "all")) {
    return(out)
  }

  scope_map <- c(
    functions = "function",
    arguments = "argument",
    fields = "field",
    columns = "column",
    plot_metrics = "plot_metric"
  )
  out[out$Surface %in% scope_map[[scope]], , drop = FALSE]
}

#' @noRd
anchor_review <- function(x, required = TRUE) {
  required <- isTRUE(required)

  if (inherits(x, "mfrm_anchor_review")) {
    return(x)
  }
  if (!is.list(x)) {
    stop("`x` must be an `mfrm_fit`, anchor-review object, or compatible list.", call. = FALSE)
  }

  config <- x$config %||% x
  out <- config$anchor_review
  if (is.null(out)) {
    if (!required) return(NULL)
    stop(
      "No anchor-review component was found. Use `fit$config$anchor_review`, ",
      "or run `review_mfrm_anchors()`.",
      call. = FALSE
    )
  }
  out
}

#' @noRd
precision_review <- function(x, required = TRUE) {
  required <- isTRUE(required)

  if (inherits(x, "mfrm_precision_review")) {
    validate_precision_review_profile(x$profile)
    return(x)
  }
  if (!is.list(x)) {
    stop("`x` must be an `mfrm_diagnostics`, precision-review object, or compatible list.", call. = FALSE)
  }
  validate_diagnostics_precision(x)

  out <- x$precision_review
  if (is.null(out)) {
    if (!required) return(NULL)
    stop(
      "No precision-review component was found. Run `diagnose_mfrm()` and use ",
      "`diagnostics$precision_review`.",
      call. = FALSE
    )
  }
  out
}
