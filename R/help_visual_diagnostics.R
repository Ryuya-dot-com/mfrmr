#' @section Visual diagnostics map, presets, and missing-interval states:
#' | Question | Primary `plot()` route |
#' | --- | --- |
#' | Shared logit targeting of Persons, facets, and steps | `plot(fit, type = "wright")` |
#' | Expected scores and category probability curves | `plot(fit, type = "pathway")` or `type = "ccc"` |
#' | Model-fit overview and response screens | `plot(fit, type = "qc")`, `"unexpected"`, `"displacement"`, `"marginal_fit"` |
#' | Inter-rater score agreement vs residual structure | `plot(fit, type = "agreement")`, `"residual_pca"`, `"local_dependence"`, `"bias"` |
#' | Connectedness, anchor drift, or group DFF | `plot(result)` on [subset_connectivity_report()], [detect_anchor_drift()], or [analyze_dff()] |
#'
#' **Session defaults and editing.** Set `options(mfrmr.plot_preset =
#' "publication")` (`"standard"`, `"publication"`, `"compact"`, or
#' `"monochrome"`) for a session preset; explicit `preset` overrides the option
#' and `preset = NULL` uses `"standard"`. Every `plot()` method returns a
#' `ggplot` invisibly (`draw = FALSE` suppresses device drawing). Titles and
#' explanatory notes stay outside the canvas by default (`show_title = FALSE`,
#' `show_notes = FALSE`) and remain accessible via `plot_data(p, "title")` and
#' `plot_data(p, "notes")`.
#'
#' **Missing estimates and intervals.** Retain rows with `NA` bounds alongside
#' their `Status`, `CIEligible`, `CoverageQualified`, and `InferenceReview`
#' fields: `fixed` marks constraint-pinned coordinates, `prior_only` marks
#' Persons without observed responses, and `CoverageQualified = FALSE` records
#' unestablished finite-sample nominal coverage rather than numerical failure.
#' See `vignette("mfrmr-visual-diagnostics", package = "mfrmr")`.
#'
#' @aliases mfrmr_visual_diagnostics
#' @rdname plot.mfrm_fit
#' @name mfrmr_visual_diagnostics
NULL

#' @noRd
visual_reporting_template <- function(scope = c("all", "manuscript", "appendix", "diagnostic", "surface")) {
  scope <- match.arg(scope)

  out <- .mfrmr_table_visual_reporting_template_out

  if (identical(scope, "all")) {
    return(out)
  }
  out[out$Scope == scope, , drop = FALSE]
}

#' @noRd
mfrmr_interval_guide <- function(scope = c(
  "all", "visual", "table", "reporting", "fit", "bias", "linking",
  "gpcm", "equivalence", "hierarchical", "shrinkage"
)) {
  scope <- match.arg(scope)

  out <- .mfrmr_table_mfrmr_interval_guide_out

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_1)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_2)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_3)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_4)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_5)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_6)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_7)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_8)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_9)

  out <- rbind(out, .mfrmr_table_mfrmr_interval_guide_data_10)

  if (identical(scope, "all")) {
    return(out)
  }
  out[grepl(paste0("(^|,)", scope, "(,|$)"), out$Scope), , drop = FALSE]
}
