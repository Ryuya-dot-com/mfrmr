# ==============================================================================
# Secondary visualization helpers
# ==============================================================================
#
# Four helpers grouped here for follow-up review after the primary
# Wright / pathway / CCC / fit / dashboard layer:
#
# - plot_local_dependence_heatmap: pairwise standardized residuals
#   between facet levels (Q3-style heatmap).
# - plot_reliability_snapshot: facet x separation / strata /
#   reliability bar overview.
# - plot_residual_matrix: person x facet-level standardized residuals
#   for follow-up after the Guttman scalogram.
# - plot_shrinkage_funnel: empirical-Bayes shrinkage caterpillar /
#   funnel display.
#
# Each helper follows the mfrmr plot contract: accept an `mfrm_fit`
# (or related class), resolve a preset via resolve_plot_preset() +
# apply_plot_preset(), and return an mfrm_plot_data object that
# downstream code can re-render or export.
# ==============================================================================


#' Pairwise standardized-residual heatmap for local-dependence review
#'
#' Builds an N x N heatmap of pairwise standardized residuals between
#' facet levels, computed from the diagnostics observation table.
#' Cells with large absolute values flag pairs of facet elements (e.g.
#' two raters, two items) whose residuals co-move more than the
#' main-effects MFRM expects. Residuals are averaged within each Person
#' and facet level before correlation. This is a Q3-style screen, distinct
#' from raw-residual Yen Q3; no fixed correlation cutoff establishes local
#' independence for this standardized, aggregated index.
#'
#' This helper complements [plot(x, type = "marginal_pairwise")][plot.mfrm_fit]: the marginal
#' version uses posterior-integrated agreement residuals on a
#' top-N pair list, while this view shows every pair on a shared color
#' scale so an analyst can scan for diagonal blocks or hotspots.
#'
#' @param fit An `mfrm_fit` from [fit_mfrm()].
#' @param diagnostics Optional [diagnose_mfrm()] output. Computed
#'   on demand when omitted.
#' @param facet Facet whose levels are placed on both axes (default
#'   `"Rater"`).
#' @param min_pairs Minimum number of persons with finite aggregated residuals
#'   at both levels; an integer of at least three. Unavailable pairs remain
#'   in the table with their overlap count and reason, and appear as `NA`
#'   in the matrix.
#' @param preset Visual preset.
#' @param draw If `TRUE`, print the `ggplot` object.
#'
#' @return Invisibly, a `ggplot` object. `plot_data(p)` bundles the symmetric
#'   residual `matrix`, one row per unordered pair in `pairs`, and the
#'   minimum overlap `min_pairs`. Interpretation notes are available through
#'   `plot_data(p, "notes")`. Save the complete payload with [base::saveRDS()];
#'   [as_ggplot()] converts its saved matrix without recalculating residuals.
#' @seealso [plot(x, type = "marginal_pairwise")][plot.mfrm_fit], [plot(x, type = "qc")][plot.mfrm_fit],
#'   [mfrmr_visual_diagnostics]
#' @examples
#' # Supplementary workflow: run explicitly to keep routine checks brief.
#' # example("plot_local_dependence_heatmap", run.dontrun = TRUE)
#' \dontrun{
#' # Saved synthetic JML/RSM analysis of example_core.
#' # For your own data, fit a model first; see ?fit_mfrm.
#' example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
#' fit <- example_fit$fit
#' p <- plot(fit, type = "local_dependence", draw = FALSE)
#' dim(plot_data(p, "matrix"))
#' # Inspect large absolute correlations alongside shared-person counts.
#' # Unavailable pairs are not evidence of local independence.
#' }
#' @section Session plot defaults:
#' See [mfrmr_visual_diagnostics] for `options(mfrmr.plot_preset)`, argument
#' precedence, and appearance when saving or reusing a plot.
#' @keywords internal
#' @section Migration in 0.2.4:
#' This renderer is internal. Use the corresponding `plot()` route in
#' [mfrmr_plot_migration]; the former exported name is no longer available.
plot_local_dependence_heatmap <- function(fit,
                                          diagnostics = NULL,
                                          facet = "Rater",
                                          min_pairs = 5L,
                                          preset = c("standard", "publication", "compact", "monochrome"),
                                          draw = TRUE) {
  if (missing(preset)) preset <- .mfrm_default_plot_preset()
  style <- resolve_plot_preset(preset)
  associations <- .mfrm_residual_associations(fit, diagnostics, facet, min_pairs)
  mat <- associations$matrix
  pairs_df <- associations$pairs
  rater_cols <- colnames(mat)

  out <- new_mfrm_plot_data(
    "local_dependence_heatmap",
    list(
      matrix = mat,
      pairs = pairs_df,
      facet = facet,
      min_pairs = as.integer(min_pairs),
      title = sprintf("Pairwise residual correlation (Q3 view): %s", facet),
      subtitle = sprintf("%d of %d unique pairs available; at least %d shared persons required",
                         sum(is.finite(pairs_df$ResidualCor)), nrow(pairs_df), min_pairs),
      caption = paste("Standardized residuals are averaged without weighting within Person/facet-level cells; correlations use shared Persons.",
        "This is a Q3-style screen, not raw-residual Yen Q3 or a calibrated test of local independence.",
        "Unavailable pairs are NA, not zero; inspect the pair table for overlap counts and reasons."),
      preset = style$name
    )
  )
  .mfrm_finalize_ggplot(out, draw = draw)
}


#' Facet reliability and separation snapshot bar plot
#'
#' Compact facet-level visual of the Wright & Masters (1982)
#' separation, strata, and reliability indices that
#' [diagnose_mfrm()] computes. Helpful as a single small figure for
#' "are persons / raters / criteria distinguishable?" review.
#' These are Rasch/FACETS-style separation indices on the fitted logit
#' scale, not ICCs; use [compute_facet_icc()] for the complementary
#' observed-score variance-share view.
#'
#' @details
#' High Person separation reliability indicates distinguishable abilities.
#' High rater separation reliability indicates distinguishable severities,
#' **not agreement** between raters. If raters should be interchangeable,
#' reliable severity differences merit review. Low rater separation reliability
#' can also reflect imprecise estimates and does not establish agreement.
#' The index does not test every rater pair or measure the practical size of
#' severity differences. Examine estimated severities and their uncertainty,
#' and use [interrater_agreement_table()] for observed agreement.
#'
#' The separation-reliability formula is shared across facets, but the facet's
#' role changes its interpretation. Person separation reliability is analogous
#' to test reliability, not numerically identical to Cronbach's alpha; MML
#' Person rows using EAP/posterior SD also have the limitations described in
#' [mfrmr-package]. No universal adequate/strong reference lines are drawn.
#' Reliability, separation and Strata use approximate marginal-SE variance
#' subtraction and do not propagate covariance among estimates, even when
#' the SEs come from joint information. Model and fit-adjusted indices are
#' not confidence limits; Strata does not identify actual groups.
#' Ordinary JML uses exploratory location precision; these indices are
#' screening summaries, not structural confidence intervals. Corrected-JML
#' `RootSE` is not an input to these indices. Corrected JML and two-family
#' GPCM are unavailable here, including when diagnostics are supplied.
#' The returned plot retains interpretation notes for saved reuse.
#'
#' @param fit An `mfrm_fit` from [fit_mfrm()].
#' @param diagnostics Optional [diagnose_mfrm()] output. Computed on
#'   demand when omitted.
#' @param metric `"reliability"` (default), `"separation"`, or
#'   `"strata"`.
#' @param preset Visual preset.
#' @param draw If `TRUE`, print the `ggplot` object.
#'
#' @return Invisibly, a `ggplot` object. `plot_data(p, "table")` is a tidy
#'   `Facet`, `Metric`, `Value` data frame. When present in the supplied
#'   diagnostics, precision tier, reliability use/basis, formal-inference flag
#'   and model-summary notes are retained alongside each plotted value.
#' @seealso [diagnose_mfrm()], [mfrmr_visual_diagnostics]
#' @examples
#' # Supplementary workflow: run explicitly to keep routine checks brief.
#' # example("plot_reliability_snapshot", run.dontrun = TRUE)
#' \dontrun{
#' # Saved synthetic JML/RSM analysis of example_core.
#' # For your own data, fit a model first; see ?fit_mfrm.
#' example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
#' fit <- example_fit$fit
#' p <- plot(fit, type = "reliability", draw = FALSE)
#' plot_data(p, "table")
#' # High Person value: distinguishable abilities.
#' # High rater value: distinguishable severities, not agreement.
#' # Low rater value: not proof of agreement; inspect estimation precision.
#' plot_data(p, "notes")
#' }
#' @references
#' Linacre, J. M. Facets documentation, \emph{Reliability - separation - strata}.
#' \url{https://www.winsteps.com/facetman/reliability.htm}
#' @section Session plot defaults:
#' See [mfrmr_visual_diagnostics] for `options(mfrmr.plot_preset)`, argument
#' precedence, and appearance when saving or reusing a plot.
#' @keywords internal
#' @section Migration in 0.2.4:
#' This renderer is internal. Use the corresponding `plot()` route in
#' [mfrmr_plot_migration]; the former exported name is no longer available.
plot_reliability_snapshot <- function(fit,
                                      diagnostics = NULL,
                                      metric = c("reliability", "separation", "strata"),
                                      preset = c("standard", "publication", "compact", "monochrome"),
                                      draw = TRUE) {
  if (missing(preset)) preset <- .mfrm_default_plot_preset()
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().", call. = FALSE)
  }
  stop_if_product_slopes(fit, "plot(x, type = \"reliability\")")
  metric <- match.arg(metric)
  style <- resolve_plot_preset(preset)
  if (is.null(diagnostics)) {
    diagnostics <- suppressMessages(diagnose_mfrm(fit, residual_pca = "none",
                                                   diagnostic_mode = "legacy"))
  }
  rel <- as.data.frame(diagnostics$reliability %||% data.frame(),
                        stringsAsFactors = FALSE)
  if (nrow(rel) == 0L || !"Facet" %in% names(rel)) {
    stop("`diagnostics$reliability` is empty or missing the Facet column.",
         call. = FALSE)
  }
  metric_col <- switch(metric,
    reliability = if ("Reliability" %in% names(rel)) "Reliability" else NA_character_,
    separation = if ("Separation" %in% names(rel)) "Separation" else NA_character_,
    strata = if ("Strata" %in% names(rel)) "Strata" else NA_character_
  )
  if (is.na(metric_col)) {
    stop("Diagnostics$reliability does not include the requested metric column: ",
         metric, ".", call. = FALSE)
  }
  vals <- suppressWarnings(as.numeric(rel[[metric_col]]))
  ok <- is.finite(vals)
  rel <- rel[ok, , drop = FALSE]
  vals <- vals[ok]
  if (length(vals) == 0L) {
    stop("No finite values for the requested metric.", call. = FALSE)
  }
  ord <- order(vals, decreasing = TRUE)
  rel <- rel[ord, , drop = FALSE]
  vals <- vals[ord]
  payload <- data.frame(
    Facet = as.character(rel$Facet),
    Metric = metric,
    Value = vals,
    stringsAsFactors = FALSE
  )
  precision <- intersect(c("PrecisionTier", "ReliabilityUse", "ReliabilityBasis",
    "SupportsFormalInference", "ModelSummaryNote"), names(rel))
  payload[precision] <- rel[precision]
  caption <- paste("Raters: severity differences, not agreement.",
                   "Persons: ability differences.", sep = "\n")
  notes <- mfrm_separation_interpretation()
  if (isTRUE(fit$config$method %in% c("JML", "JMLE"))) {
    notes <- paste(notes, "Ordinary JML uses exploratory location precision; these indices are screening summaries, not structural confidence intervals.")
  }

  out <- new_mfrm_plot_data(
    "reliability_snapshot",
    list(
      table = payload,
      metric = metric,
      title = sprintf("Facet %s snapshot", metric),
      subtitle = paste0("Sorted by ", metric_col, "; N facet rows = ",
                         nrow(payload)),
      caption = caption,
      notes = data.frame(Type = "interpretation", Text = notes),
      preset = style$name,
      reference_lines = NULL
    )
  )
  .mfrm_finalize_ggplot(out, draw = draw)
}


#' Person x facet-level standardized-residual matrix
#'
#' Visualizes the person x element matrix of standardized residuals
#' from [diagnose_mfrm()] as a heatmap. Complements
#' [plot(x, type = "guttman")][plot.mfrm_fit] (which shows raw responses) by exposing
#' the residual structure directly: large positive cells show
#' under-prediction, negative cells over-prediction.
#'
#' @param fit An `mfrm_fit` from [fit_mfrm()].
#' @param diagnostics Optional [diagnose_mfrm()] output. Computed on
#'   demand when omitted.
#' @param facet Facet whose levels become the column axis (default
#'   `"Rater"`).
#' @param top_n_persons Cap on the number of rows. Defaults to 40
#'   to keep the figure legible; persons are kept by largest absolute
#'   residual mean.
#' @param preset Visual preset.
#' @param draw If `TRUE`, print the `ggplot` object.
#'
#' @return Invisibly, a `ggplot` object. `plot_data(p)` bundles the residual
#'   `matrix` (rows = Person, columns = facet level) and the long-form
#'   `obs` table.
#' @seealso [plot(x, type = "guttman")][plot.mfrm_fit], [plot(x, type = "unexpected")][plot.mfrm_fit],
#'   [mfrmr_visual_diagnostics]
#' @examples
#' # Supplementary workflow: run explicitly to keep routine checks brief.
#' # example("plot_residual_matrix", run.dontrun = TRUE)
#' \dontrun{
#' # Saved synthetic JML/RSM analysis of example_core.
#' # For your own data, fit a model first; see ?fit_mfrm.
#' example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
#' fit <- example_fit$fit
#' p <- plot(fit, type = "residual_matrix", top_n_persons = 12, draw = FALSE)
#' dim(plot_data(p, "matrix"))
#' # Look for: |residual| > 2 or > 3 crosses conventional two- or
#' #   three-standard-deviation review bands; these are heuristic screens,
#' #   not calibrated 5% or 1% tests (Wright & Linacre 1994). Repeated
#' #   high-magnitude cells at one facet level warrant pattern review but
#' #   do not by themselves establish scoring drift.
#' }
#' @section Session plot defaults:
#' See [mfrmr_visual_diagnostics] for `options(mfrmr.plot_preset)`, argument
#' precedence, and appearance when saving or reusing a plot.
#' @keywords internal
#' @section Migration in 0.2.4:
#' This renderer is internal. Use the corresponding `plot()` route in
#' [mfrmr_plot_migration]; the former exported name is no longer available.
plot_residual_matrix <- function(fit,
                                 diagnostics = NULL,
                                 facet = "Rater",
                                 top_n_persons = 40L,
                                 preset = c("standard", "publication", "compact", "monochrome"),
                                 draw = TRUE) {
  if (missing(preset)) preset <- .mfrm_default_plot_preset()
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().", call. = FALSE)
  }
  facet <- as.character(facet[1])
  facet_names <- as.character(fit$config$facet_names %||% character(0))
  if (!facet %in% facet_names) {
    stop("`facet` must be one of: ", paste(facet_names, collapse = ", "), ".",
         call. = FALSE)
  }
  style <- resolve_plot_preset(preset)
  obs <- if (is.null(diagnostics)) {
    compute_obs_table(.mfrm_validate_diagnostic_fit(fit))
  } else diagnostics$obs
  obs <- as.data.frame(obs %||% data.frame(), stringsAsFactors = FALSE)
  needed <- c("Person", facet, "StdResidual")
  missing <- setdiff(needed, names(obs))
  if (length(missing) > 0L) {
    stop("`diagnostics$obs` is missing required columns: ",
         paste(missing, collapse = ", "), ".",
         call. = FALSE)
  }
  obs$Person <- as.character(obs$Person)
  obs[[facet]] <- as.character(obs[[facet]])
  obs$StdResidual <- suppressWarnings(as.numeric(obs$StdResidual))

  agg <- stats::aggregate(
    obs$StdResidual,
    by = list(Person = obs$Person, Level = obs[[facet]]),
    FUN = function(z) mean(z, na.rm = TRUE)
  )
  names(agg)[3] <- "StdResidual"

  person_priority <- stats::aggregate(
    abs(agg$StdResidual),
    by = list(Person = agg$Person),
    FUN = function(z) mean(z, na.rm = TRUE)
  )
  names(person_priority)[2] <- "AbsMean"
  person_priority <- person_priority[order(person_priority$AbsMean,
                                            decreasing = TRUE), , drop = FALSE]
  cap <- max(1L, as.integer(top_n_persons))
  if (nrow(person_priority) > cap) {
    person_priority <- person_priority[seq_len(cap), , drop = FALSE]
  }
  agg <- agg[agg$Person %in% person_priority$Person, , drop = FALSE]

  persons <- as.character(person_priority$Person)
  levels_x <- sort(unique(as.character(agg$Level)))
  mat <- matrix(NA_real_, nrow = length(persons), ncol = length(levels_x),
                 dimnames = list(persons, levels_x))
  ix <- match(agg$Person, persons)
  jx <- match(agg$Level, levels_x)
  ok <- is.finite(ix) & is.finite(jx)
  mat[cbind(ix[ok], jx[ok])] <- agg$StdResidual[ok]

  out <- new_mfrm_plot_data(
    "residual_matrix",
    list(
      matrix = mat,
      obs = agg,
      facet = facet,
      title = sprintf("Standardized residual matrix (Person x %s)", facet),
      subtitle = sprintf("Top %d person(s) by mean |StdResidual|",
                          length(persons)),
      preset = style$name,
      reference_lines = new_reference_lines(
        "h", 0, "Zero residual", "dashed", "reference"
      )
    )
  )
  .mfrm_finalize_ggplot(out, draw = draw)
}


#' Empirical-Bayes shrinkage funnel / caterpillar
#'
#' Visualizes empirical-Bayes shrinkage by drawing one row per facet
#' level with the raw (pre-shrinkage) and shrunken estimates plus the
#' shrinkage factor. Rows are ordered by absolute shrinkage so the
#' levels that move most under the prior appear at the top.
#'
#' Requires a fit produced via [apply_empirical_bayes_shrinkage()] or
#' a `fit_mfrm(..., facet_shrinkage = "empirical_bayes")` run, so that
#' `fit$facets$others` carries `Estimate`, `ShrunkEstimate`, and
#' `ShrinkageFactor` columns.
#'
#' @param fit An `mfrm_fit` augmented with empirical-Bayes shrinkage.
#' @param facet Facet to draw (default: first non-person facet with
#'   shrinkage columns present).
#' @param top_n Maximum number of rows to draw (default 30).
#' @param preset Visual preset.
#' @param show_ci Logical. When `TRUE`, draw descriptive normal bands from
#'   raw and plug-in shrunken SEs. These omit prior-variance uncertainty and
#'   cross-level covariance; zero width after full pooling is not perfect precision.
#' @param ci_level Nominal normal-band level when `show_ci = TRUE`; default
#'   0.95. This does not assert repeated-sampling coverage.
#' @param draw If `TRUE`, print the `ggplot` object.
#'
#' @return Invisibly, a `ggplot` object. `plot_data(p, "table")` is the long
#'   `Level`, `RawEstimate`, `ShrunkEstimate`, `ShrinkageFactor` table.
#'   When `show_ci = TRUE`, the table also includes `RawCI_Lower`,
#'   `RawCI_Upper`, `ShrunkCI_Lower`, `ShrunkCI_Upper`, and `CI_Level`.
#' @seealso [apply_empirical_bayes_shrinkage()],
#'   [mfrmr_visual_diagnostics]
#' @examples
#' # Supplementary workflow: run explicitly to keep routine checks brief.
#' # example("plot_shrinkage_funnel", run.dontrun = TRUE)
#' \dontrun{
#' # Saved synthetic JML/RSM analysis of example_core.
#' # For your own data, fit a model first; see ?fit_mfrm.
#' example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
#' fit <- example_fit$fit
#' fit_eb <- apply_empirical_bayes_shrinkage(fit)
#' p <- plot(fit_eb, type = "shrinkage", view = "funnel", draw = FALSE)
#' head(plot_data(p, "table"))
#' # Look for: short segments (Raw and Shrunken close together) =
#' #   little pooling. Long segments fanning toward the centre = the
#' #   prior pulled the estimate strongly; this is most pronounced for
#' #   small-N levels. ShrinkageFactor near 1 means most of the
#' #   movement was driven by the prior rather than the data.
#' }
#' @section Session plot defaults:
#' See [mfrmr_visual_diagnostics] for `options(mfrmr.plot_preset)`, argument
#' precedence, and appearance when saving or reusing a plot.
#' @keywords internal
#' @section Migration in 0.2.4:
#' This renderer is internal. Use the corresponding `plot()` route in
#' [mfrmr_plot_migration]; the former exported name is no longer available.
plot_shrinkage_funnel <- function(fit,
                                  facet = NULL,
                                  top_n = 30L,
                                  preset = c("standard", "publication", "compact", "monochrome"),
                                  show_ci = FALSE,
                                  ci_level = 0.95,
                                  draw = TRUE) {
  if (missing(preset)) preset <- .mfrm_default_plot_preset()
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().", call. = FALSE)
  }
  validate_shrinkage_output(fit)
  if (isTRUE(show_ci)) {
    ci_level <- .validate_shrinkage_ci_level(ci_level)
  }
  others <- as.data.frame(fit$facets$others %||% data.frame(),
                           stringsAsFactors = FALSE)
  needed <- c("Facet", "Level", "Estimate", "ShrunkEstimate", "ShrinkageFactor")
  missing <- setdiff(needed, names(others))
  if (length(missing) > 0L) {
    stop("This fit does not carry empirical-Bayes shrinkage columns. ",
         "Run apply_empirical_bayes_shrinkage(fit) first. Missing: ",
         paste(missing, collapse = ", "), ".", call. = FALSE)
  }
  if (is.null(facet)) {
    facet <- as.character(others$Facet[1])
  }
  facet <- as.character(facet[1])
  others <- others[as.character(others$Facet) == facet, , drop = FALSE]
  if (nrow(others) == 0L) {
    stop("No rows in fit$facets$others for facet '", facet, "'.",
         call. = FALSE)
  }
  others$Estimate <- suppressWarnings(as.numeric(others$Estimate))
  others$ShrunkEstimate <- suppressWarnings(as.numeric(others$ShrunkEstimate))
  others$ShrinkageFactor <- suppressWarnings(as.numeric(others$ShrinkageFactor))
  se_col <- if ("ModelSE" %in% names(others)) {
    "ModelSE"
  } else if ("SE" %in% names(others)) {
    "SE"
  } else {
    NA_character_
  }
  others$SE <- if (!is.na(se_col)) {
    suppressWarnings(as.numeric(others[[se_col]]))
  } else {
    rep(NA_real_, nrow(others))
  }
  others$ShrunkSE <- if ("ShrunkSE" %in% names(others)) {
    suppressWarnings(as.numeric(others$ShrunkSE))
  } else {
    rep(NA_real_, nrow(others))
  }
  others <- others[is.finite(others$Estimate) &
                     is.finite(others$ShrunkEstimate), , drop = FALSE]
  if (nrow(others) == 0L) {
    stop("No rows had finite Estimate / ShrunkEstimate for facet '", facet, "'.",
         call. = FALSE)
  }
  ord <- order(abs(others$Estimate - others$ShrunkEstimate),
                decreasing = TRUE)
  others <- others[ord, , drop = FALSE]
  cap <- max(1L, as.integer(top_n))
  if (nrow(others) > cap) {
    others <- others[seq_len(cap), , drop = FALSE]
  }
  payload <- data.frame(
    Facet = as.character(others$Facet),
    Level = as.character(others$Level),
    RawEstimate = others$Estimate,
    SE = others$SE,
    ShrunkEstimate = others$ShrunkEstimate,
    ShrunkSE = others$ShrunkSE,
    ShrinkageFactor = others$ShrinkageFactor,
    Movement = others$ShrunkEstimate - others$Estimate,
    stringsAsFactors = FALSE
  )
  payload <- payload[order(payload$RawEstimate), , drop = FALSE]
  payload$RowOrder <- seq_len(nrow(payload))
  payload$SupportsFormalInference <- rep(FALSE, nrow(payload))
  payload$Interpretation <- rep(shrinkage_interpretation(), nrow(payload))
  if (isTRUE(show_ci)) {
    payload <- .add_shrinkage_ci_columns(
      payload,
      ci_level = ci_level,
      raw_estimate_col = "RawEstimate",
      raw_se_col = "SE",
      raw_prefix = "Raw",
      shrunk_estimate_col = "ShrunkEstimate",
      shrunk_se_col = "ShrunkSE",
      shrunk_prefix = "Shrunk"
    )
  }

  style <- resolve_plot_preset(preset)

  legend_label <- c("Raw estimate", "Shrunken estimate",
                    "Shrinkage movement", "Zero shrinkage target")
  legend_role <- c("location", "location", "movement", "reference")
  legend_aesthetic <- c("point", "point", "line", "line")
  legend_value <- c(style$accent_primary, style$accent_tertiary,
                    style$neutral, style$grid)
  if (isTRUE(show_ci)) {
    legend_label <- c(legend_label, sprintf("%g%% plug-in band",
                                            round(100 * ci_level)))
    legend_role <- c(legend_role, "interval")
    legend_aesthetic <- c(legend_aesthetic, "line")
    legend_value <- c(legend_value, style$accent_primary)
  }
  out <- new_mfrm_plot_data(
    "shrinkage_funnel",
    list(
      table = payload,
      facet = facet,
      interpretation = shrinkage_interpretation(),
      show_ci = isTRUE(show_ci),
      ci_level = if (isTRUE(show_ci)) ci_level else NA_real_,
      title = sprintf("Empirical-Bayes shrinkage funnel: %s", facet),
      subtitle = sprintf("%d level(s); rows ordered by raw estimate",
                          nrow(payload)),
      preset = style$name,
      legend = new_plot_legend(
        label = legend_label,
        role = legend_role,
        aesthetic = legend_aesthetic,
        value = legend_value
      ),
      reference_lines = new_reference_lines(
        "v", 0, "Zero shrinkage target", "dashed", "reference"
      )
    )
  )
  .mfrm_finalize_ggplot(out, draw = draw)
}
