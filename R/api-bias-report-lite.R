#' Extract Structured Bias Interaction and Pairwise Tables
#'
#' Extracts pairwise within-target bias contrasts (`type = "bias_pairwise"`) or
#' ranked interaction cells (`type = "bias_interaction"`) from an [estimate_bias()]
#' result or [fit_mfrm()] object. Use [render_mfrm_report()] for an analysis
#' report with individual rater feedback.
#'
#' @param x An `mfrm_bias` object from [estimate_bias()] or an `mfrm_fit` object.
#' @param type `"bias_pairwise"`, `"bias_interaction"`, or `"bias_iterations"`.
#' @param diagnostics Optional `mfrm_diagnostics` when `x` is an `mfrm_fit`.
#' @param facet_a,facet_b Optional facet names when `x` is an `mfrm_fit`.
#' @param target_facet,context_facet Target and context facet names for `"bias_pairwise"`.
#' @param top_n Maximum rows retained in summary previews (default `50`).
#' @param p_max Screening p-value threshold for `Flag` (default `0.05`).
#' @param sort_by `"abs_t"`, `"abs_contrast"`, or `"prob"`.
#' @param df_method `"facets"` or `"classical"`.
#' @param ... Additional arguments forwarded to [estimate_bias()] when `x` is an `mfrm_fit`.
#' @return A list bundle with `$table` and `$summary`.
#' @export
mfrm_report <- function(x,
                        type = c("bias_pairwise", "bias_interaction", "bias_iterations"),
                        diagnostics = NULL,
                        facet_a = NULL,
                        facet_b = NULL,
                        target_facet = NULL,
                        context_facet = NULL,
                        top_n = 50,
                        p_max = 0.05,
                        sort_by = c("abs_t", "abs_contrast", "prob"),
                        df_method = c("facets", "classical"),
                        ...) {
  type <- match.arg(type)
  sort_by <- match.arg(sort_by)
  df_method <- match.arg(df_method)

  bias_obj <- if (inherits(x, "mfrm_bias")) {
    x
  } else if (inherits(x, "mfrm_fit")) {
    if (is.null(diagnostics)) diagnostics <- diagnose_mfrm(x)
    estimate_bias(x, diagnostics = diagnostics, facet_a = facet_a, facet_b = facet_b, ...)
  } else {
    stop("`x` must be an `mfrm_bias` or `mfrm_fit` object. For workflow reporting, see `render_mfrm_report()`.", call. = FALSE)
  }

  if (identical(type, "bias_iterations")) {
    iter_tbl <- as.data.frame(bias_obj$iteration %||% data.frame(), stringsAsFactors = FALSE)
    return(as_mfrm_bundle(list(table = iter_tbl, summary = bias_obj$summary), "mfrm_bias_iteration"))
  }

  if (identical(type, "bias_interaction")) {
    tbl <- as.data.frame(bias_obj$table %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(tbl) > top_n) tbl <- utils::head(tbl, top_n)
    return(as_mfrm_bundle(list(table = tbl, summary = bias_obj$summary), "mfrm_bias_interaction_report"))
  }

  facets_pair <- as.character(bias_obj$interaction_facets %||% c(bias_obj$facet_a, bias_obj$facet_b))
  if (length(facets_pair) != 2L) {
    stop("`mfrm_report(..., type = 'bias_pairwise')` requires a 2-way bias interaction.", call. = FALSE)
  }
  if (is.null(target_facet)) target_facet <- facets_pair[1L]
  target_facet <- as.character(target_facet[1L])
  if (is.null(context_facet)) context_facet <- setdiff(facets_pair, target_facet)[1L]
  context_facet <- as.character(context_facet[1L])

  pair_tbl <- as.data.frame(
    calc_bias_pairwise(
      bias_obj$table,
      target_facet = target_facet,
      context_facet = context_facet,
      orientation_review = bias_obj$orientation_review,
      df_method = df_method
    ),
    stringsAsFactors = FALSE
  )
  if (nrow(pair_tbl) > 0L) {
    pair_tbl$AbsT <- abs(suppressWarnings(as.numeric(pair_tbl$t)))
    pair_tbl$AbsContrast <- abs(suppressWarnings(as.numeric(pair_tbl$Contrast)))
    pair_tbl$Flag <- with(pair_tbl, ifelse(
      ScreenStatus == "available_conditional",
      AbsT >= 2 | `Prob.` <= p_max,
      NA
    ))
    ord <- switch(
      sort_by,
      abs_t = order(pair_tbl$AbsT, decreasing = TRUE, na.last = TRUE),
      abs_contrast = order(pair_tbl$AbsContrast, decreasing = TRUE, na.last = TRUE),
      prob = order(pair_tbl$`Prob.`, decreasing = FALSE, na.last = TRUE)
    )
    if (length(ord) > 0L) pair_tbl <- pair_tbl[ord, , drop = FALSE]
  }
  as_mfrm_bundle(
    list(
      table = pair_tbl,
      summary = data.frame(
        TargetFacet = target_facet,
        ContextFacet = context_facet,
        TotalPairs = nrow(pair_tbl),
        FlaggedPairs = sum(pair_tbl$Flag, na.rm = TRUE),
        stringsAsFactors = FALSE
      )
    ),
    "mfrm_bias_pairwise_report"
  )
}
