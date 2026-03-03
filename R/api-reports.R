#' Build a specification summary report (preferred alias)
#'
#' @param fit Output from [fit_mfrm()].
#' @param title Optional analysis title.
#' @param data_file Optional data-file label (for reporting only).
#' @param output_file Optional output-file label (for reporting only).
#' @param include_fixed If `TRUE`, include a FACETS-style fixed-width text block.
#' @details
#' `summary(out)` is supported through `summary()`.
#' `plot(out)` is dispatched through `plot()` for class
#' `mfrm_specifications` (`type = "facet_elements"`,
#' `"anchor_constraints"`, `"convergence"`).
#'
#' @section Interpreting output:
#' - `header` / `data_spec`: run identity and model settings.
#' - `facet_labels`: facet sizes and labels.
#' - `convergence_control`: optimizer configuration and status.
#'
#' @section Typical workflow:
#' 1. Generate `specifications_report(fit)`.
#' 2. Verify model settings and convergence metadata.
#' 3. Use as Table 1-style documentation in reports.
#' @return A named list with specification-report components. Class:
#'   `mfrm_specifications`.
#' @seealso [fit_mfrm()], [data_quality_report()], [estimation_iteration_report()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' out <- specifications_report(fit, title = "Toy run")
#' summary(out)
#' p_spec <- plot(out, draw = FALSE)
#' class(p_spec)
#' @export
specifications_report <- function(fit,
                                  title = NULL,
                                  data_file = NULL,
                                  output_file = NULL,
                                  include_fixed = FALSE) {
  out <- with_legacy_name_warning_suppressed(
    table1_specifications(
      fit = fit,
      title = title,
      data_file = data_file,
      output_file = output_file,
      include_fixed = include_fixed
    )
  )
  as_mfrm_bundle(out, "mfrm_specifications")
}

#' Build a data quality summary report (preferred alias)
#'
#' @param fit Output from [fit_mfrm()].
#' @param data Optional raw data frame used for row-level audit.
#' @param person Optional person column name in `data`.
#' @param facets Optional facet column names in `data`.
#' @param score Optional score column name in `data`.
#' @param weight Optional weight column name in `data`.
#' @param include_fixed If `TRUE`, include a FACETS-style fixed-width text block.
#' @details
#' `summary(out)` is supported through `summary()`.
#' `plot(out)` is dispatched through `plot()` for class
#' `mfrm_data_quality` (`type = "row_audit"`, `"category_counts"`,
#' `"missing_rows"`).
#'
#' @section Interpreting output:
#' - `summary`: retained/dropped row overview.
#' - `row_audit`: reason-level breakdown for data issues.
#' - `category_counts`: post-filter category usage.
#' - `unknown_elements`: facet levels in raw data but not in fitted design.
#'
#' @section Typical workflow:
#' 1. Run `data_quality_report(...)` with raw data.
#' 2. Check row-audit and missing/unknown element sections.
#' 3. Resolve issues before final estimation/reporting.
#' @return A named list with data-quality report components. Class:
#'   `mfrm_data_quality`.
#' @seealso [fit_mfrm()], [describe_mfrm_data()], [specifications_report()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' out <- data_quality_report(
#'   fit, data = toy, person = "Person",
#'   facets = c("Rater", "Criterion"), score = "Score"
#' )
#' summary(out)
#' p_dq <- plot(out, draw = FALSE)
#' class(p_dq)
#' @export
data_quality_report <- function(fit,
                                data = NULL,
                                person = NULL,
                                facets = NULL,
                                score = NULL,
                                weight = NULL,
                                include_fixed = FALSE) {
  out <- with_legacy_name_warning_suppressed(
    table2_data_summary(
      fit = fit,
      data = data,
      person = person,
      facets = facets,
      score = score,
      weight = weight,
      include_fixed = include_fixed
    )
  )
  as_mfrm_bundle(out, "mfrm_data_quality")
}

#' Build an estimation-iteration report (preferred alias)
#'
#' @param fit Output from [fit_mfrm()].
#' @param max_iter Maximum replay iterations (excluding optional initial row).
#' @param reltol Stopping tolerance for replayed max-logit change.
#' @param include_prox If `TRUE`, include an initial pseudo-row labeled `PROX`.
#' @param include_fixed If `TRUE`, include a FACETS-style fixed-width text block.
#' @details
#' `summary(out)` is supported through `summary()`.
#' `plot(out)` is dispatched through `plot()` for class
#' `mfrm_iteration_report` (`type = "residual"`, `"logit_change"`,
#' `"objective"`).
#'
#' @section Interpreting output:
#' - `iterations`: trajectory of convergence indicators by iteration.
#' - `summary`: final status and stopping diagnostics.
#' - optional `PROX` row: pseudo-initial reference point when enabled.
#'
#' @section Typical workflow:
#' 1. Run `estimation_iteration_report(fit)`.
#' 2. Inspect plateau/stability patterns in summary/plot.
#' 3. Adjust optimization settings if convergence looks weak.
#' @return A named list with iteration-report components. Class:
#'   `mfrm_iteration_report`.
#' @seealso [fit_mfrm()], [specifications_report()], [data_quality_report()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' out <- estimation_iteration_report(fit, max_iter = 5)
#' summary(out)
#' p_iter <- plot(out, draw = FALSE)
#' class(p_iter)
#' @export
estimation_iteration_report <- function(fit,
                                        max_iter = 20,
                                        reltol = NULL,
                                        include_prox = TRUE,
                                        include_fixed = FALSE) {
  out <- with_legacy_name_warning_suppressed(
    table3_iteration_report(
      fit = fit,
      max_iter = max_iter,
      reltol = reltol,
      include_prox = include_prox,
      include_fixed = include_fixed
    )
  )
  as_mfrm_bundle(out, "mfrm_iteration_report")
}

#' Build a subset connectivity report (preferred alias)
#'
#' @param fit Output from [fit_mfrm()].
#' @param diagnostics Optional output from [diagnose_mfrm()].
#' @param top_n_subsets Optional maximum number of subset rows to keep.
#' @param min_observations Minimum observations required to keep a subset row.
#' @details
#' `summary(out)` is supported through `summary()`.
#' `plot(out)` is dispatched through `plot()` for class
#' `mfrm_subset_connectivity` (`type = "subset_observations"`,
#' `"facet_levels"`).
#'
#' @section Interpreting output:
#' - `summary`: number and size of connected subsets.
#' - subset table: whether data are fragmented into disconnected components.
#' - facet-level columns: where connectivity bottlenecks occur.
#'
#' @section Typical workflow:
#' 1. Run `subset_connectivity_report(fit)`.
#' 2. Confirm near-single-subset structure when possible.
#' 3. Use results to justify linking/anchoring strategy.
#' @return A named list with subset-connectivity components. Class:
#'   `mfrm_subset_connectivity`.
#' @seealso [diagnose_mfrm()], [measurable_summary_table()], [data_quality_report()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' out <- subset_connectivity_report(fit)
#' summary(out)
#' p_sub <- plot(out, draw = FALSE)
#' class(p_sub)
#' @export
subset_connectivity_report <- function(fit,
                                       diagnostics = NULL,
                                       top_n_subsets = NULL,
                                       min_observations = 0) {
  out <- with_legacy_name_warning_suppressed(
    table6_subsets_listing(
      fit = fit,
      diagnostics = diagnostics,
      top_n_subsets = top_n_subsets,
      min_observations = min_observations
    )
  )
  as_mfrm_bundle(out, "mfrm_subset_connectivity")
}

#' Build a facet statistics report (preferred alias)
#'
#' @param fit Output from [fit_mfrm()].
#' @param diagnostics Optional output from [diagnose_mfrm()].
#' @param metrics Numeric columns in `diagnostics$measures` to summarize.
#' @param ruler_width Width of the fixed-width ruler used for `M/S/Q/X` marks.
#' @details
#' `summary(out)` is supported through `summary()`.
#' `plot(out)` is dispatched through `plot()` for class
#' `mfrm_facet_statistics` (`type = "means"`, `"sds"`, `"ranges"`).
#'
#' @section Interpreting output:
#' - facet-level means/SD/ranges of selected metrics (`Estimate`, fit indices, `SE`).
#' - fixed-width ruler rows (`M/S/Q/X`) for FACETS-like profile scanning.
#'
#' @section Typical workflow:
#' 1. Run `facet_statistics_report(fit)`.
#' 2. Inspect summary/ranges for anomalous facets.
#' 3. Cross-check flagged facets with fit and chi-square diagnostics.
#' @return A named list with facet-statistics components. Class:
#'   `mfrm_facet_statistics`.
#' @seealso [diagnose_mfrm()], [summary.mfrm_fit()], [plot_facets_chisq()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' out <- facet_statistics_report(fit)
#' summary(out)
#' p_fs <- plot(out, draw = FALSE)
#' class(p_fs)
#' @export
facet_statistics_report <- function(fit,
                                    diagnostics = NULL,
                                    metrics = c("Estimate", "Infit", "Outfit", "SE"),
                                    ruler_width = 41) {
  out <- with_legacy_name_warning_suppressed(
    table6_2_facet_statistics(
      fit = fit,
      diagnostics = diagnostics,
      metrics = metrics,
      ruler_width = ruler_width
    )
  )
  as_mfrm_bundle(out, "mfrm_facet_statistics")
}

#' Build a category structure report (preferred alias)
#'
#' @param fit Output from [fit_mfrm()].
#' @param diagnostics Optional output from [diagnose_mfrm()].
#' @param theta_range Theta/logit range used to derive transition points.
#' @param theta_points Number of grid points used for transition-point search.
#' @param drop_unused If `TRUE`, remove zero-count categories from outputs.
#' @param include_fixed If `TRUE`, include a FACETS-style fixed-width text block.
#' @param fixed_max_rows Maximum rows per fixed-width section.
#'
#' @details
#' Preferred high-level API for category-structure diagnostics.
#' This wraps the legacy Table 8 bar/transition export and returns a stable
#' bundle interface for reporting and plotting.
#'
#' @section Interpreting output:
#' Key components include:
#' - category usage/fit table (count, expected, infit/outfit, ZSTD)
#' - threshold ordering and adjacent threshold gaps
#' - category transition-point table on the requested theta grid
#'
#' Practical read order:
#' 1. `summary(out)` for compact warnings and threshold ordering.
#' 2. `out$category_table` for sparse/misfitting categories.
#' 3. `out$transition_points` to inspect crossing structure.
#' 4. `plot(out)` for quick visual check.
#'
#' @section Typical workflow:
#' 1. [fit_mfrm()] -> model.
#' 2. [diagnose_mfrm()] -> residual/fit diagnostics (optional argument here).
#' 3. `category_structure_report()` -> category health snapshot.
#' 4. `summary()` and `plot()` for report-ready interpretation.
#' @return A named list with category-structure components. Class:
#'   `mfrm_category_structure`.
#' @seealso [rating_scale_table()], [category_curves_report()], [plot.mfrm_fit()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' out <- category_structure_report(fit)
#' summary(out)
#' names(out)
#' p_cs <- plot(out, draw = FALSE)
#' class(p_cs)
#' @export
category_structure_report <- function(fit,
                                      diagnostics = NULL,
                                      theta_range = c(-6, 6),
                                      theta_points = 241,
                                      drop_unused = FALSE,
                                      include_fixed = FALSE,
                                      fixed_max_rows = 200) {
  out <- with_legacy_name_warning_suppressed(
    table8_barchart_export(
      fit = fit,
      diagnostics = diagnostics,
      theta_range = theta_range,
      theta_points = theta_points,
      drop_unused = drop_unused,
      include_fixed = include_fixed,
      fixed_max_rows = fixed_max_rows
    )
  )
  as_mfrm_bundle(out, "mfrm_category_structure")
}

#' Build a category curve export bundle (preferred alias)
#'
#' @param fit Output from [fit_mfrm()].
#' @param theta_range Theta/logit range for curve coordinates.
#' @param theta_points Number of points on the theta grid.
#' @param digits Rounding digits for numeric graph output.
#' @param include_fixed If `TRUE`, include a FACETS-style fixed-width text block.
#' @param fixed_max_rows Maximum rows shown in fixed-width graph tables.
#'
#' @details
#' Preferred high-level API for category-probability curve exports.
#' Returns tidy curve coordinates and summary metadata for quick
#' plotting/report integration without calling low-level helpers directly.
#'
#' @section Interpreting output:
#' Use this report to inspect:
#' - where each category has highest probability across theta
#' - whether adjacent categories cross in expected order
#' - whether probability bands look compressed (often sparse categories)
#'
#' Recommended read order:
#' 1. `summary(out)` for compact diagnostics.
#' 2. `out$curve_points` (or equivalent curve table) for downstream graphics.
#' 3. `plot(out)` for a default visual check.
#'
#' @section Typical workflow:
#' 1. Fit model with [fit_mfrm()].
#' 2. Run `category_curves_report()` with suitable `theta_points`.
#' 3. Use `summary()` and `plot()`; export tables for manuscripts/dashboard use.
#' @return A named list with category-curve components. Class:
#'   `mfrm_category_curves`.
#' @seealso [category_structure_report()], [rating_scale_table()], [plot.mfrm_fit()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' out <- category_curves_report(fit, theta_points = 101)
#' summary(out)
#' names(out)
#' p_cc <- plot(out, draw = FALSE)
#' class(p_cc)
#' @export
category_curves_report <- function(fit,
                                   theta_range = c(-6, 6),
                                   theta_points = 241,
                                   digits = 4,
                                   include_fixed = FALSE,
                                   fixed_max_rows = 400) {
  out <- with_legacy_name_warning_suppressed(
    table8_curves_export(
      fit = fit,
      theta_range = theta_range,
      theta_points = theta_points,
      digits = digits,
      include_fixed = include_fixed,
      fixed_max_rows = fixed_max_rows
    )
  )
  as_mfrm_bundle(out, "mfrm_category_curves")
}

#' Build a bias-interaction plot-data bundle (preferred alias)
#'
#' @param x Output from [estimate_bias()] or [fit_mfrm()].
#' @param diagnostics Optional output from [diagnose_mfrm()] (used when `x` is fit).
#' @param facet_a First facet name (required when `x` is fit and
#'   `interaction_facets` is not supplied).
#' @param facet_b Second facet name (required when `x` is fit and
#'   `interaction_facets` is not supplied).
#' @param interaction_facets Character vector of two or more facets.
#' @param max_abs Bound for absolute bias size when estimating from fit.
#' @param omit_extreme Omit extreme-only elements when estimating from fit.
#' @param max_iter Iteration cap for bias estimation when `x` is fit.
#' @param tol Convergence tolerance for bias estimation when `x` is fit.
#' @param top_n Maximum number of ranked rows to keep.
#' @param abs_t_warn Warning cutoff for absolute t statistics.
#' @param abs_bias_warn Warning cutoff for absolute bias size.
#' @param p_max Warning cutoff for p-values.
#' @param sort_by Ranking key: `"abs_t"`, `"abs_bias"`, or `"prob"`.
#'
#' @details
#' Preferred bundle API for interaction-bias diagnostics. The function can:
#' - use a precomputed bias object from [estimate_bias()], or
#' - estimate internally from `mfrm_fit` + facet specification.
#'
#' @section Interpreting output:
#' Focus on ranked rows where multiple criteria converge:
#' - large absolute t statistic
#' - large absolute bias size
#' - small p-value
#'
#' The bundle is optimized for downstream `summary()` and
#' [plot_bias_interaction()] views.
#'
#' @section Typical workflow:
#' 1. Run [estimate_bias()] (or provide `mfrm_fit` here).
#' 2. Build `bias_interaction_report(...)`.
#' 3. Review `summary(out)` and visualize with [plot_bias_interaction()].
#' @return A named list with bias-interaction plotting/report components. Class:
#'   `mfrm_bias_interaction`.
#' @seealso [estimate_bias()], [build_fixed_reports()], [plot_bias_interaction()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' diag <- diagnose_mfrm(fit, residual_pca = "none")
#' bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 2)
#' out <- bias_interaction_report(bias, top_n = 10)
#' summary(out)
#' p_bi <- plot(out, draw = FALSE)
#' class(p_bi)
#' @export
bias_interaction_report <- function(x,
                                    diagnostics = NULL,
                                    facet_a = NULL,
                                    facet_b = NULL,
                                    interaction_facets = NULL,
                                    max_abs = 10,
                                    omit_extreme = TRUE,
                                    max_iter = 4,
                                    tol = 1e-3,
                                    top_n = 50,
                                    abs_t_warn = 2,
                                    abs_bias_warn = 0.5,
                                    p_max = 0.05,
                                    sort_by = c("abs_t", "abs_bias", "prob")) {
  out <- with_legacy_name_warning_suppressed(
    table13_bias_plot_export(
      x = x,
      diagnostics = diagnostics,
      facet_a = facet_a,
      facet_b = facet_b,
      interaction_facets = interaction_facets,
      max_abs = max_abs,
      omit_extreme = omit_extreme,
      max_iter = max_iter,
      tol = tol,
      top_n = top_n,
      abs_t_warn = abs_t_warn,
      abs_bias_warn = abs_bias_warn,
      p_max = p_max,
      sort_by = sort_by
    )
  )
  as_mfrm_bundle(out, "mfrm_bias_interaction")
}

#' Plot bias interaction diagnostics (preferred alias)
#'
#' @inheritParams bias_interaction_report
#' @param plot Plot type: `"scatter"`, `"ranked"`, `"abs_t_hist"`,
#'   or `"facet_profile"`.
#' @param main Optional plot title override.
#' @param palette Optional named color overrides (`normal`, `flag`, `hist`,
#'   `profile`).
#' @param label_angle Label angle hint for ranked/profile labels.
#' @param draw If `TRUE`, draw with base graphics.
#'
#' @details
#' Visualization front-end for [bias_interaction_report()] with multiple views.
#'
#' @section Plot types:
#' \describe{
#'   \item{`"scatter"` (default)}{Scatter plot of bias size (x) vs
#'     t-statistic (y).  Points colored by flag status.  Dashed reference
#'     lines at `abs_bias_warn` and `abs_t_warn`.  Use for overall triage
#'     of interaction effects.}
#'   \item{`"ranked"`}{Ranked bar chart of top `top_n` interactions sorted
#'     by `sort_by` criterion (absolute t, absolute bias, or probability).
#'     Bars colored red for flagged cells.}
#'   \item{`"abs_t_hist"`}{Histogram of absolute t-statistics across all
#'     interaction cells.  Dashed reference line at `abs_t_warn`.  Use for
#'     assessing the overall distribution of interaction effect sizes.}
#'   \item{`"facet_profile"`}{Per-facet-level aggregation showing mean
#'     absolute bias and flag rate.  Useful for identifying which
#'     individual facet levels drive systematic interaction patterns.}
#' }
#'
#' @section Interpreting output:
#' Start with `"scatter"` or `"ranked"` for triage, then confirm pattern shape
#' using `"abs_t_hist"` and `"facet_profile"`.
#'
#' Consistent flags across multiple views are stronger evidence of systematic
#' interaction bias than a single extreme row.
#'
#' @section Typical workflow:
#' 1. Estimate bias with [estimate_bias()] or pass `mfrm_fit` directly.
#' 2. Plot with `plot = "ranked"` for top interactions.
#' 3. Cross-check using `plot = "scatter"` and `plot = "facet_profile"`.
#' @return A plotting-data object of class `mfrm_plot_data`.
#' @seealso [bias_interaction_report()], [estimate_bias()], [plot_displacement()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' p <- plot_bias_interaction(
#'   fit,
#'   diagnostics = diagnose_mfrm(fit, residual_pca = "none"),
#'   facet_a = "Rater",
#'   facet_b = "Criterion",
#'   draw = FALSE
#' )
#' @export
plot_bias_interaction <- function(x,
                                  plot = c("scatter", "ranked", "abs_t_hist", "facet_profile"),
                                  diagnostics = NULL,
                                  facet_a = NULL,
                                  facet_b = NULL,
                                  interaction_facets = NULL,
                                  top_n = 40,
                                  abs_t_warn = 2,
                                  abs_bias_warn = 0.5,
                                  p_max = 0.05,
                                  sort_by = c("abs_t", "abs_bias", "prob"),
                                  main = NULL,
                                  palette = NULL,
                                  label_angle = 45,
                                  draw = TRUE) {
  with_legacy_name_warning_suppressed(
    plot_table13_bias(
      x = x,
      plot = plot,
      diagnostics = diagnostics,
      facet_a = facet_a,
      facet_b = facet_b,
      interaction_facets = interaction_facets,
      top_n = top_n,
      abs_t_warn = abs_t_warn,
      abs_bias_warn = abs_bias_warn,
      p_max = p_max,
      sort_by = sort_by,
      main = main,
      palette = palette,
      label_angle = label_angle,
      draw = draw
    )
  )
}

#' Build APA text outputs from model results
#'
#' @param fit Output from [fit_mfrm()].
#' @param diagnostics Output from [diagnose_mfrm()].
#' @param bias_results Optional output from [estimate_bias()].
#' @param context Optional named list for report context.
#' @param whexact Use exact ZSTD transformation.
#'
#' @details
#' `context` is an optional named list for narrative customization.
#' Frequently used fields include:
#' - `assessment`, `setting`, `scale_desc`
#' - `rater_training`, `raters_per_response`
#' - `rater_facet` (used for targeted reliability note text)
#' - `line_width` (optional text wrapping width for `report_text`; default = 92)
#'
#' Output text includes residual PCA interpretation if PCA diagnostics are
#' available in `diagnostics`.
#'
#' By default, `report_text` includes:
#' - model/data design summary (N, facet counts, scale range)
#' - optimization/convergence metrics (`Converged`, `Iterations`, `LogLik`, `AIC`, `BIC`)
#' - anchor/constraint summary (`noncenter_facet`, anchored levels, group anchors, dummy facets)
#' - category/threshold diagnostics (including disordered-step details when present)
#' - overall fit, misfit count, and top misfit levels
#' - facet reliability/separation, residual PCA summary, and bias-screen counts
#'
#' @section Interpreting output:
#' - `report_text`: manuscript-ready narrative core.
#' - `table_figure_notes`: reusable note blocks for table/figure appendices.
#' - `table_figure_captions`: caption candidates aligned to generated outputs.
#'
#' @section Typical workflow:
#' 1. Build diagnostics (and optional bias results).
#' 2. Run `build_apa_outputs(...)`.
#' 3. Check `summary(apa)` for completeness.
#' 4. Insert `apa$report_text` and note/caption fields into manuscript drafts.
#'
#' @section Context template:
#' A minimal `context` list can include fields such as:
#' - `assessment`: name of the assessment task
#' - `setting`: administration context
#' - `scale_desc`: short description of the score scale
#' - `rater_facet`: rater facet label used in narrative reliability text
#'
#' @return
#' An object of class `mfrm_apa_outputs` with:
#' - `report_text`: APA-style Method/Results prose
#' - `table_figure_notes`: consolidated notes for tables/visuals
#' - `table_figure_captions`: caption-ready labels without figure numbering
#'
#' @seealso [build_visual_summaries()], [estimate_bias()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' diag <- diagnose_mfrm(fit, residual_pca = "both")
#' apa <- build_apa_outputs(
#'   fit,
#'   diag,
#'   context = list(
#'     assessment = "Toy writing task",
#'     setting = "Demonstration dataset",
#'     scale_desc = "0-2 rating scale",
#'     rater_facet = "Rater"
#'   )
#' )
#' names(apa)
#' class(apa)
#' s_apa <- summary(apa)
#' s_apa$overview
#' cat(apa$report_text)
#' @export
build_apa_outputs <- function(fit,
                              diagnostics,
                              bias_results = NULL,
                              context = list(),
                              whexact = FALSE) {
  report_text <- build_apa_report_text(
    res = fit,
    diagnostics = diagnostics,
    bias_results = bias_results,
    context = context,
    whexact = whexact
  )

  out <- list(
    report_text = structure(
      as.character(report_text),
      class = c("mfrm_apa_text", "character")
    ),
    table_figure_notes = build_apa_table_figure_notes(
      res = fit,
      diagnostics = diagnostics,
      bias_results = bias_results,
      context = context,
      whexact = whexact
    ),
    table_figure_captions = build_apa_table_figure_captions(
      res = fit,
      diagnostics = diagnostics,
      bias_results = bias_results,
      context = context
    )
  )
  class(out) <- c("mfrm_apa_outputs", "list")
  out
}

#' Print APA narrative text with preserved line breaks
#'
#' @param x Character text object from `build_apa_outputs()$report_text`.
#' @param ... Reserved for generic compatibility.
#'
#' @details
#' Prints APA narrative text with preserved paragraph breaks using `cat()`.
#' This is preferred over bare `print()` when you want readable multi-line
#' report output in the console.
#'
#' @section Interpreting output:
#' The printed text is the same content stored in
#' `build_apa_outputs(...)$report_text`, but with explicit paragraph breaks.
#'
#' @section Typical workflow:
#' 1. Generate `apa <- build_apa_outputs(...)`.
#' 2. Print readable narrative with `apa$report_text`.
#' 3. Use `summary(apa)` to check completeness before manuscript use.
#'
#' @return The input object (invisibly).
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' diag <- diagnose_mfrm(fit, residual_pca = "both")
#' apa <- build_apa_outputs(fit, diag)
#' apa$report_text
#' @export
print.mfrm_apa_text <- function(x, ...) {
  cat(as.character(x), "\n", sep = "")
  invisible(x)
}

#' Summarize APA report-output bundles
#'
#' @param object Output from [build_apa_outputs()].
#' @param top_n Maximum non-empty lines shown in each component preview.
#' @param preview_chars Maximum characters shown in each preview cell.
#' @param ... Reserved for generic compatibility.
#'
#' @details
#' This summary is a diagnostics layer for APA text products, not a replacement
#' for the full narrative.
#'
#' It reports component completeness, line/character volume, and a compact
#' preview for quick QA before manuscript insertion.
#'
#' @section Interpreting output:
#' - `overview`: total coverage across standard text components.
#' - `components`: per-component density and mention checks
#'   (including residual-PCA mentions).
#' - `preview`: first non-empty lines for fast visual review.
#'
#' @section Typical workflow:
#' 1. Build outputs via [build_apa_outputs()].
#' 2. Run `summary(apa)` to screen for empty/short components.
#' 3. Use `apa$report_text`, `apa$table_figure_notes`,
#'    and `apa$table_figure_captions` directly for final text.
#'
#' @return An object of class `summary.mfrm_apa_outputs`.
#' @seealso [build_apa_outputs()], [summary()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' diag <- diagnose_mfrm(fit, residual_pca = "both")
#' apa <- build_apa_outputs(fit, diag)
#' summary(apa)
#' @export
summary.mfrm_apa_outputs <- function(object, top_n = 3, preview_chars = 160, ...) {
  if (!inherits(object, "mfrm_apa_outputs")) {
    stop("`object` must be an mfrm_apa_outputs object from build_apa_outputs().", call. = FALSE)
  }

  top_n <- max(1L, as.integer(top_n))
  preview_chars <- max(40L, as.integer(preview_chars))

  text_line_count <- function(text) {
    if (!nzchar(text)) return(0L)
    length(strsplit(text, "\n", fixed = TRUE)[[1]])
  }
  nonempty_line_count <- function(text) {
    if (!nzchar(text)) return(0L)
    lines <- strsplit(text, "\n", fixed = TRUE)[[1]]
    sum(nzchar(trimws(lines)))
  }
  text_preview <- function(text, top_n, preview_chars) {
    if (!nzchar(text)) return("")
    lines <- strsplit(text, "\n", fixed = TRUE)[[1]]
    lines <- trimws(lines)
    lines <- lines[nzchar(lines)]
    if (length(lines) == 0) return("")
    pv <- paste(utils::head(lines, n = top_n), collapse = " | ")
    if (nchar(pv) > preview_chars) {
      pv <- paste0(substr(pv, 1, preview_chars - 3), "...")
    }
    pv
  }

  components <- c("report_text", "table_figure_notes", "table_figure_captions")
  stats_tbl <- do.call(
    rbind,
    lapply(components, function(comp) {
      text_vec <- as.character(object[[comp]] %||% character(0))
      text <- paste(text_vec, collapse = "\n")
      data.frame(
        Component = comp,
        NonEmpty = nzchar(trimws(text)),
        Characters = nchar(text),
        Lines = text_line_count(text),
        NonEmptyLines = nonempty_line_count(text),
        ResidualPCA_Mentions = stringr::str_count(
          text,
          stringr::regex("Residual\\s*PCA", ignore_case = TRUE)
        ),
        stringsAsFactors = FALSE
      )
    })
  )

  preview_tbl <- do.call(
    rbind,
    lapply(components, function(comp) {
      text_vec <- as.character(object[[comp]] %||% character(0))
      text <- paste(text_vec, collapse = "\n")
      data.frame(
        Component = comp,
        Preview = text_preview(text, top_n = top_n, preview_chars = preview_chars),
        stringsAsFactors = FALSE
      )
    })
  )

  overview <- data.frame(
    Components = nrow(stats_tbl),
    NonEmptyComponents = sum(stats_tbl$NonEmpty),
    TotalCharacters = sum(stats_tbl$Characters),
    TotalNonEmptyLines = sum(stats_tbl$NonEmptyLines),
    stringsAsFactors = FALSE
  )

  empty_components <- stats_tbl$Component[!stats_tbl$NonEmpty]
  notes <- if (length(empty_components) == 0) {
    c(
      "All standard APA text components are populated.",
      "Use object fields directly for full text; summary provides compact diagnostics."
    )
  } else {
    c(
      paste0("Empty components: ", paste(empty_components, collapse = ", "), "."),
      "Use object fields directly for full text; summary provides compact diagnostics."
    )
  }

  out <- list(
    overview = overview,
    components = stats_tbl,
    preview = preview_tbl,
    notes = notes,
    top_n = top_n,
    preview_chars = preview_chars
  )
  class(out) <- "summary.mfrm_apa_outputs"
  out
}

#' @export
print.summary.mfrm_apa_outputs <- function(x, ...) {
  cat("mfrmr APA Outputs Summary\n")

  if (!is.null(x$overview) && nrow(x$overview) > 0) {
    cat("\nOverview\n")
    print(round_numeric_df(as.data.frame(x$overview), digits = 0), row.names = FALSE)
  }
  if (!is.null(x$components) && nrow(x$components) > 0) {
    cat("\nComponent stats\n")
    print(round_numeric_df(as.data.frame(x$components), digits = 0), row.names = FALSE)
  }
  if (!is.null(x$preview) && nrow(x$preview) > 0) {
    cat("\nPreview\n")
    print(as.data.frame(x$preview), row.names = FALSE)
  }
  if (length(x$notes) > 0) {
    cat("\nNotes\n")
    cat(" - ", x$notes, "\n", sep = "")
  }
  invisible(x)
}

#' Build APA-style table output using base R structures
#'
#' @param x A data.frame, `mfrm_fit`, diagnostics list, or bias-result list.
#' @param which Optional table selector when `x` has multiple tables.
#' @param diagnostics Optional diagnostics from [diagnose_mfrm()] (used when
#'   `x` is `mfrm_fit` and `which` targets diagnostics tables).
#' @param digits Number of rounding digits for numeric columns.
#' @param caption Optional caption text.
#' @param note Optional note text.
#' @param branch Output branch:
#'   `"apa"` for manuscript-oriented labels, `"facets"` for FACETS-aligned labels.
#'
#' @details
#' This helper avoids styling dependencies and returns a reproducible base
#' `data.frame` plus metadata.
#'
#' Supported `which` values:
#' - For `mfrm_fit`: `"summary"`, `"person"`, `"facets"`, `"steps"`
#' - For diagnostics list: `"overall_fit"`, `"measures"`, `"fit"`,
#'   `"reliability"`, `"facets_chisq"`, `"bias"`, `"interactions"`,
#'   `"interrater_summary"`, `"interrater_pairs"`, `"obs"`
#' - For bias-result list: `"table"`, `"summary"`, `"chi_sq"`
#'
#' @section Interpreting output:
#' - `table`: plain data.frame ready for export or further formatting.
#' - `which`: source component that produced the table.
#' - `caption`/`note`: manuscript-oriented metadata stored with the table.
#'
#' @section Typical workflow:
#' 1. Build table object with `apa_table(...)`.
#' 2. Inspect quickly with `summary(tbl)`.
#' 3. Render base preview via `plot(tbl, ...)` or export `tbl$table`.
#'
#' @return A list of class `apa_table` with fields:
#' - `table` (`data.frame`)
#' - `which`
#' - `caption`
#' - `note`
#' - `digits`
#' - `branch`, `style`
#' @seealso [fit_mfrm()], [diagnose_mfrm()], [build_apa_outputs()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' tbl <- apa_table(fit, which = "summary", caption = "Model summary", note = "Toy example")
#' tbl_facets <- apa_table(fit, which = "summary", branch = "facets")
#' summary(tbl)
#' p <- plot(tbl, draw = FALSE)
#' p_facets <- plot(tbl_facets, type = "numeric_profile", draw = FALSE)
#' if (interactive()) {
#'   plot(
#'     tbl,
#'     type = "numeric_profile",
#'     main = "APA Table Numeric Profile (Customized)",
#'     palette = c(numeric_profile = "#2b8cbe", grid = "#d9d9d9"),
#'     label_angle = 45
#'   )
#' }
#' class(tbl)
#' @export
apa_table <- function(x,
                      which = NULL,
                      diagnostics = NULL,
                      digits = 2,
                      caption = NULL,
                      note = NULL,
                      branch = c("apa", "facets")) {
  branch <- match.arg(tolower(as.character(branch[1])), c("apa", "facets"))
  style <- ifelse(branch == "facets", "facets_manual", "apa")
  digits <- max(0L, as.integer(digits))
  table_out <- NULL
  source_type <- "data.frame"

  if (is.data.frame(x)) {
    table_out <- x
    source_type <- "data.frame"
  } else if (inherits(x, "mfrm_fit")) {
    source_type <- "mfrm_fit"
    opts <- c("summary", "person", "facets", "steps")
    diag_opts <- c(
      "overall_fit",
      "measures",
      "fit",
      "reliability",
      "facets_chisq",
      "bias",
      "interactions",
      "interrater_summary",
      "interrater_pairs",
      "obs"
    )
    if (is.null(which)) which <- "summary"
    which <- tolower(as.character(which[1]))

    if (which %in% opts) {
      table_out <- switch(
        which,
        summary = x$summary,
        person = x$facets$person,
        facets = x$facets$others,
        steps = x$steps
      )
    } else if (which %in% diag_opts) {
      if (is.null(diagnostics)) {
        diagnostics <- diagnose_mfrm(x, residual_pca = "none")
      }
      if (which == "interrater_summary") {
        table_out <- diagnostics$interrater$summary
      } else if (which == "interrater_pairs") {
        table_out <- diagnostics$interrater$pairs
      } else {
        table_out <- diagnostics[[which]]
      }
    } else {
      stop("Unsupported `which` for mfrm_fit. Use one of: ", paste(c(opts, diag_opts), collapse = ", "))
    }
  } else if (is.list(x) && !is.null(names(x))) {
    source_type <- "list"
    candidate <- names(x)
    if (is.null(which)) {
      pref <- c(
        "summary", "table", "overall_fit", "measures", "fit", "reliability", "facets_chisq",
        "bias", "interactions", "interrater_summary", "interrater_pairs", "obs", "chi_sq"
      )
      hit <- pref[pref %in% candidate]
      if (length(hit) == 0) {
        stop("Could not infer `which` from list input. Please specify `which`.")
      }
      which <- hit[1]
    }
    which <- as.character(which[1])
    if (!which %in% names(x)) {
      stop("Requested `which` not found in list input.")
    }
    table_out <- x[[which]]
  } else {
    stop("`x` must be a data.frame, mfrm_fit, or named list.")
  }

  if (is.null(table_out)) {
    table_out <- data.frame()
  }
  table_out <- as.data.frame(table_out, stringsAsFactors = FALSE)
  if (nrow(table_out) > 0) {
    num_cols <- vapply(table_out, is.numeric, logical(1))
    table_out[num_cols] <- lapply(table_out[num_cols], round, digits = digits)
  }

  out <- list(
    table = table_out,
    which = if (is.null(which)) source_type else as.character(which),
    caption = if (is.null(caption)) {
      if (branch == "facets") {
        paste0("FACETS-aligned table: ", if (is.null(which)) source_type else as.character(which))
      } else {
        ""
      }
    } else {
      as.character(caption)
    },
    note = if (is.null(note)) "" else as.character(note),
    digits = digits,
    branch = branch,
    style = style
  )
  class(out) <- c(paste0("apa_table_", branch), "apa_table", class(out))
  out
}

#' @export
print.apa_table <- function(x, ...) {
  if (!is.null(x$caption) && nzchar(x$caption)) {
    cat(x$caption, "\n", sep = "")
  }
  if (is.data.frame(x$table) && nrow(x$table) > 0) {
    print(x$table, row.names = FALSE)
  } else {
    cat("<empty table>\n")
  }
  if (!is.null(x$note) && nzchar(x$note)) {
    cat("Note. ", x$note, "\n", sep = "")
  }
  invisible(x)
}

#' Summarize an APA/FACETS table object
#'
#' @param object Output from [apa_table()].
#' @param digits Number of digits used for numeric summaries.
#' @param top_n Maximum numeric columns shown in `numeric_profile`.
#' @param ... Reserved for generic compatibility.
#'
#' @details
#' Compact summary helper for QA of table payloads before manuscript export.
#'
#' @section Interpreting output:
#' - `overview`: table size/composition and missingness.
#' - `numeric_profile`: quick distribution summary of numeric columns.
#' - `caption`/`note`: text metadata readiness.
#'
#' @section Typical workflow:
#' 1. Build table with [apa_table()].
#' 2. Run `summary(tbl)` and inspect `overview`.
#' 3. Use [plot.apa_table()] for quick numeric checks if needed.
#'
#' @return An object of class `summary.apa_table`.
#' @seealso [apa_table()], [plot()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' tbl <- apa_table(fit, which = "summary")
#' summary(tbl)
#' @export
summary.apa_table <- function(object, digits = 3, top_n = 8, ...) {
  digits <- max(0L, as.integer(digits))
  top_n <- max(1L, as.integer(top_n))
  tbl <- as.data.frame(object$table %||% data.frame(), stringsAsFactors = FALSE)

  num_cols <- names(tbl)[vapply(tbl, is.numeric, logical(1))]
  numeric_profile <- data.frame()
  if (length(num_cols) > 0) {
    numeric_profile <- do.call(
      rbind,
      lapply(num_cols, function(nm) {
        vals <- suppressWarnings(as.numeric(tbl[[nm]]))
        vals <- vals[is.finite(vals)]
        data.frame(
          Column = nm,
          N = length(vals),
          Mean = if (length(vals) > 0) mean(vals) else NA_real_,
          SD = if (length(vals) > 1) stats::sd(vals) else NA_real_,
          Min = if (length(vals) > 0) min(vals) else NA_real_,
          Max = if (length(vals) > 0) max(vals) else NA_real_,
          stringsAsFactors = FALSE
        )
      })
    )
    numeric_profile <- numeric_profile |>
      dplyr::arrange(dplyr::desc(.data$SD), .data$Column) |>
      dplyr::slice_head(n = top_n)
  }

  overview <- data.frame(
    Branch = as.character(object$branch %||% "apa"),
    Style = as.character(object$style %||% "apa"),
    Which = as.character(object$which %||% ""),
    Rows = nrow(tbl),
    Columns = ncol(tbl),
    NumericColumns = length(num_cols),
    MissingValues = sum(is.na(tbl)),
    stringsAsFactors = FALSE
  )

  out <- list(
    overview = overview,
    numeric_profile = numeric_profile,
    caption = as.character(object$caption %||% ""),
    note = as.character(object$note %||% ""),
    digits = digits
  )
  class(out) <- "summary.apa_table"
  out
}

#' @export
print.summary.apa_table <- function(x, ...) {
  digits <- as.integer(x$digits %||% 3L)
  if (!is.finite(digits)) digits <- 3L

  cat("APA Table Summary\n")
  if (!is.null(x$overview) && nrow(x$overview) > 0) {
    print(round_numeric_df(as.data.frame(x$overview), digits = digits), row.names = FALSE)
  }
  if (!is.null(x$caption) && nzchar(x$caption)) {
    cat("\nCaption\n")
    cat(" - ", x$caption, "\n", sep = "")
  }
  if (!is.null(x$note) && nzchar(x$note)) {
    cat("\nNote\n")
    cat(" - ", x$note, "\n", sep = "")
  }
  if (!is.null(x$numeric_profile) && nrow(x$numeric_profile) > 0) {
    cat("\nNumeric profile\n")
    print(round_numeric_df(as.data.frame(x$numeric_profile), digits = digits), row.names = FALSE)
  }
  invisible(x)
}

#' Plot an APA/FACETS table object using base R
#'
#' @param x Output from [apa_table()].
#' @param y Reserved for generic compatibility.
#' @param type Plot type: `"numeric_profile"` (column means) or
#'   `"first_numeric"` (distribution of the first numeric column).
#' @param main Optional title override.
#' @param palette Optional named color overrides.
#' @param label_angle Axis-label rotation angle for bar-type plots.
#' @param draw If `TRUE`, draw using base graphics.
#' @param ... Reserved for generic compatibility.
#'
#' @details
#' Quick visualization helper for numeric columns in [apa_table()] output.
#' It is intended for table QA and exploratory checks, not final publication
#' graphics.
#'
#' @section Interpreting output:
#' - `"numeric_profile"`: compares column means to spot scale/centering mismatches.
#' - `"first_numeric"`: checks distribution shape of the first numeric column.
#'
#' @section Typical workflow:
#' 1. Build table with [apa_table()].
#' 2. Run `summary(tbl)` for metadata.
#' 3. Use `plot(tbl, type = "numeric_profile")` for quick numeric QC.
#'
#' @return A plotting-data object of class `mfrm_plot_data`.
#' @seealso [apa_table()], [summary()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' tbl <- apa_table(fit, which = "summary")
#' p <- plot(tbl, draw = FALSE)
#' p2 <- plot(tbl, type = "first_numeric", draw = FALSE)
#' if (interactive()) {
#'   plot(
#'     tbl,
#'     type = "numeric_profile",
#'     main = "APA Numeric Profile (Customized)",
#'     palette = c(numeric_profile = "#2b8cbe", grid = "#d9d9d9"),
#'     label_angle = 45
#'   )
#' }
#' @export
plot.apa_table <- function(x,
                           y = NULL,
                           type = c("numeric_profile", "first_numeric"),
                           main = NULL,
                           palette = NULL,
                           label_angle = 45,
                           draw = TRUE,
                           ...) {
  type <- match.arg(tolower(as.character(type[1])), c("numeric_profile", "first_numeric"))
  tbl <- as.data.frame(x$table %||% data.frame(), stringsAsFactors = FALSE)
  if (nrow(tbl) == 0) {
    stop("`x$table` is empty.")
  }
  num_cols <- names(tbl)[vapply(tbl, is.numeric, logical(1))]
  if (length(num_cols) == 0) {
    stop("`x$table` has no numeric columns to plot.")
  }
  pal <- resolve_palette(
    palette = palette,
    defaults = c(
      numeric_profile = "#1f78b4",
      first_numeric = "#33a02c",
      grid = "#ececec"
    )
  )

  if (type == "numeric_profile") {
    vals <- vapply(num_cols, function(nm) {
      v <- suppressWarnings(as.numeric(tbl[[nm]]))
      mean(v[is.finite(v)])
    }, numeric(1))
    ord <- order(abs(vals), decreasing = TRUE, na.last = NA)
    vals <- vals[ord]
    labels <- num_cols[ord]
    if (isTRUE(draw)) {
      barplot_rot45(
        height = vals,
        labels = labels,
        col = pal["numeric_profile"],
        main = if (is.null(main)) "APA table numeric profile (column means)" else as.character(main[1]),
        ylab = "Mean",
        label_angle = label_angle,
        mar_bottom = 8.8
      )
      graphics::abline(h = 0, col = pal["grid"], lty = 2)
    }
    out <- new_mfrm_plot_data(
      "apa_table",
      list(plot = "numeric_profile", column = labels, mean = vals)
    )
    return(invisible(out))
  }

  nm <- num_cols[1]
  vals <- suppressWarnings(as.numeric(tbl[[nm]]))
  vals <- vals[is.finite(vals)]
  if (length(vals) == 0) {
    stop("First numeric column does not contain finite values.")
  }
  if (isTRUE(draw)) {
    graphics::hist(
      x = vals,
      breaks = "FD",
      col = pal["first_numeric"],
      border = "white",
      main = if (is.null(main)) paste0("Distribution of ", nm) else as.character(main[1]),
      xlab = nm,
      ylab = "Count"
    )
  }
  out <- new_mfrm_plot_data(
    "apa_table",
    list(plot = "first_numeric", column = nm, values = vals)
  )
  invisible(out)
}

#' List literature-based warning threshold profiles
#'
#' @return An object of class `mfrm_threshold_profiles` with
#'   `profiles` (`strict`, `standard`, `lenient`) and `pca_reference_bands`.
#' @details
#' Use this function to inspect available profile presets before calling
#' [build_visual_summaries()].
#'
#' `profiles` contains thresholds used by warning logic
#' (sample size, fit ratios, PCA cutoffs, etc.).
#' `pca_reference_bands` contains literature-oriented descriptive bands used in
#' summary text.
#'
#' @section Interpreting output:
#' - `profiles`: numeric threshold presets (`strict`, `standard`, `lenient`).
#' - `pca_reference_bands`: narrative reference bands for PCA interpretation.
#'
#' @section Typical workflow:
#' 1. Review presets with `mfrm_threshold_profiles()`.
#' 2. Pick a default profile for project policy.
#' 3. Override only selected fields in [build_visual_summaries()] when needed.
#'
#' @seealso [build_visual_summaries()]
#' @examples
#' profiles <- mfrm_threshold_profiles()
#' names(profiles)
#' names(profiles$profiles)
#' class(profiles)
#' s_profiles <- summary(profiles)
#' s_profiles$overview
#' @export
mfrm_threshold_profiles <- function() {
  out <- warning_threshold_profiles()
  class(out) <- c("mfrm_threshold_profiles", "list")
  out
}

#' Summarize threshold-profile presets for visual warning logic
#'
#' @param object Output from [mfrm_threshold_profiles()].
#' @param digits Number of digits used for numeric summaries.
#' @param ... Reserved for generic compatibility.
#'
#' @details
#' Summarizes available warning presets and their PCA reference bands used by
#' [build_visual_summaries()].
#'
#' @section Interpreting output:
#' - `thresholds`: raw preset values by profile (`strict`, `standard`, `lenient`).
#' - `threshold_ranges`: per-threshold span across profiles (sensitivity to profile choice).
#' - `pca_reference`: literature bands used for PCA narrative labeling.
#'
#' Larger `Span` in `threshold_ranges` indicates settings that most change
#' warning behavior between strict and lenient modes.
#'
#' @section Typical workflow:
#' 1. Inspect `summary(mfrm_threshold_profiles())`.
#' 2. Choose profile (`strict` / `standard` / `lenient`) for project policy.
#' 3. Override selected thresholds in [build_visual_summaries()] only when justified.
#'
#' @return An object of class `summary.mfrm_threshold_profiles`.
#' @seealso [mfrm_threshold_profiles()], [build_visual_summaries()]
#' @examples
#' profiles <- mfrm_threshold_profiles()
#' summary(profiles)
#' @export
summary.mfrm_threshold_profiles <- function(object, digits = 3, ...) {
  if (!inherits(object, "mfrm_threshold_profiles")) {
    stop("`object` must be an mfrm_threshold_profiles object from mfrm_threshold_profiles().", call. = FALSE)
  }
  digits <- max(0L, as.integer(digits))

  profiles <- object$profiles %||% list()
  profile_names <- names(profiles)
  if (is.null(profile_names)) profile_names <- character(0)

  threshold_names <- sort(unique(unlist(lapply(profiles, names), use.names = FALSE)))
  thresholds_tbl <- if (length(threshold_names) == 0) {
    data.frame()
  } else {
    tbl <- data.frame(Threshold = threshold_names, stringsAsFactors = FALSE)
    for (nm in profile_names) {
      vals <- vapply(
        threshold_names,
        function(key) {
          val <- profiles[[nm]][[key]]
          val <- suppressWarnings(as.numeric(val))
          ifelse(length(val) == 0, NA_real_, val[1])
        },
        numeric(1)
      )
      tbl[[nm]] <- vals
    }
    tbl
  }

  thresholds_range_tbl <- data.frame()
  if (nrow(thresholds_tbl) > 0 && length(profile_names) > 0) {
    mat <- as.matrix(thresholds_tbl[, profile_names, drop = FALSE])
    suppressWarnings(storage.mode(mat) <- "numeric")
    row_stats <- t(apply(mat, 1, function(v) {
      vv <- suppressWarnings(as.numeric(v))
      vv <- vv[is.finite(vv)]
      if (length(vv) == 0) return(c(Min = NA_real_, Median = NA_real_, Max = NA_real_, Span = NA_real_))
      c(
        Min = min(vv),
        Median = stats::median(vv),
        Max = max(vv),
        Span = max(vv) - min(vv)
      )
    }))
    thresholds_range_tbl <- data.frame(
      Threshold = thresholds_tbl$Threshold,
      row_stats,
      stringsAsFactors = FALSE
    )
  }

  band_tbl <- data.frame()
  bands <- object$pca_reference_bands %||% list()
  if (length(bands) > 0) {
    band_rows <- lapply(names(bands), function(band_name) {
      vals <- bands[[band_name]]
      if (is.null(vals) || length(vals) == 0) return(NULL)
      keys <- names(vals)
      if (is.null(keys) || length(keys) != length(vals)) {
        keys <- paste0("value_", seq_along(vals))
      }
      data.frame(
        Band = band_name,
        Key = as.character(keys),
        Value = suppressWarnings(as.numeric(vals)),
        stringsAsFactors = FALSE
      )
    })
    band_rows <- Filter(Negate(is.null), band_rows)
    if (length(band_rows) > 0) {
      band_tbl <- do.call(rbind, band_rows)
    }
  }

  overview <- data.frame(
    Profiles = length(profile_names),
    ThresholdCount = nrow(thresholds_tbl),
    PCAReferenceCount = nrow(band_tbl),
    DefaultProfile = if ("standard" %in% profile_names) "standard" else ifelse(length(profile_names) > 0, profile_names[1], ""),
    stringsAsFactors = FALSE
  )

  notes <- c(
    "Profiles tune warning strictness for build_visual_summaries().",
    "Use `thresholds` in build_visual_summaries() to override selected values."
  )
  required_profiles <- c("strict", "standard", "lenient")
  missing_profiles <- setdiff(required_profiles, profile_names)
  if (length(missing_profiles) > 0) {
    notes <- c(notes, paste0("Missing presets: ", paste(missing_profiles, collapse = ", "), "."))
  }

  out <- list(
    overview = overview,
    thresholds = thresholds_tbl,
    threshold_ranges = thresholds_range_tbl,
    pca_reference = band_tbl,
    notes = notes,
    digits = digits
  )
  class(out) <- "summary.mfrm_threshold_profiles"
  out
}

#' @export
print.summary.mfrm_threshold_profiles <- function(x, ...) {
  digits <- as.integer(x$digits %||% 3L)
  if (!is.finite(digits)) digits <- 3L

  cat("mfrmr Threshold Profile Summary\n")

  if (!is.null(x$overview) && nrow(x$overview) > 0) {
    cat("\nOverview\n")
    print(as.data.frame(x$overview), row.names = FALSE)
  }
  if (!is.null(x$thresholds) && nrow(x$thresholds) > 0) {
    cat("\nProfile thresholds\n")
    print(round_numeric_df(as.data.frame(x$thresholds), digits = digits), row.names = FALSE)
  }
  if (!is.null(x$threshold_ranges) && nrow(x$threshold_ranges) > 0) {
    cat("\nThreshold ranges across profiles\n")
    print(round_numeric_df(as.data.frame(x$threshold_ranges), digits = digits), row.names = FALSE)
  }
  if (!is.null(x$pca_reference) && nrow(x$pca_reference) > 0) {
    cat("\nPCA reference bands\n")
    print(round_numeric_df(as.data.frame(x$pca_reference), digits = digits), row.names = FALSE)
  }
  if (length(x$notes) > 0) {
    cat("\nNotes\n")
    cat(" - ", x$notes, "\n", sep = "")
  }
  invisible(x)
}

#' Build warning and narrative summaries for visual outputs
#'
#' @param fit Output from [fit_mfrm()].
#' @param diagnostics Output from [diagnose_mfrm()].
#' @param threshold_profile Threshold profile name (`strict`, `standard`, `lenient`).
#' @param thresholds Optional named overrides for profile thresholds.
#' @param summary_options Summary options for `build_visual_summary_map()`.
#' @param whexact Use exact ZSTD transformation.
#' @param branch Output branch:
#'   `"facets"` adds FACETS crosswalk metadata for manual-aligned reporting;
#'   `"original"` keeps package-native summary output.
#'
#' @details
#' This function returns visual-keyed text maps
#' to support dashboard/report rendering without hard-coding narrative strings
#' in UI code.
#'
#' `thresholds` can override any profile field by name. Common overrides:
#' - `n_obs_min`, `n_person_min`
#' - `misfit_ratio_warn`, `zstd2_ratio_warn`, `zstd3_ratio_warn`
#' - `pca_first_eigen_warn`, `pca_first_prop_warn`
#'
#' `summary_options` supports:
#' - `detail`: `"standard"` or `"detailed"`
#' - `max_facet_ranges`: max facet-range snippets shown in visual summaries
#' - `top_misfit_n`: number of top misfit entries included
#'
#' @section Interpreting output:
#' - `warning_map`: rule-triggered warning text by visual key.
#' - `summary_map`: descriptive narrative text by visual key.
#' - `warning_counts` / `summary_counts`: message-count tables for QA checks.
#'
#' @section Typical workflow:
#' 1. inspect defaults with [mfrm_threshold_profiles()]
#' 2. choose `threshold_profile` (`strict` / `standard` / `lenient`)
#' 3. optionally override selected fields via `thresholds`
#' 4. pass result maps to report/dashboard rendering logic
#'
#' @return
#' An object of class `mfrm_visual_summaries` with:
#' - `warning_map`: visual-level warning text vectors
#' - `summary_map`: visual-level descriptive text vectors
#' - `warning_counts`, `summary_counts`: message counts by visual key
#' - `crosswalk`: FACETS-reference mapping for main visual keys
#' - `branch`, `style`, `threshold_profile`: branch metadata
#'
#' @seealso [mfrm_threshold_profiles()], [build_apa_outputs()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' diag <- diagnose_mfrm(fit, residual_pca = "both")
#' vis <- build_visual_summaries(fit, diag, threshold_profile = "strict")
#' vis2 <- build_visual_summaries(
#'   fit,
#'   diag,
#'   threshold_profile = "standard",
#'   thresholds = c(misfit_ratio_warn = 0.20, pca_first_eigen_warn = 2.0),
#'   summary_options = list(detail = "detailed", top_misfit_n = 5)
#' )
#' vis_facets <- build_visual_summaries(fit, diag, branch = "facets")
#' vis_facets$branch
#' summary(vis)
#' p <- plot(vis, type = "comparison", draw = FALSE)
#' p2 <- plot(vis, type = "warning_counts", draw = FALSE)
#' if (interactive()) {
#'   plot(
#'     vis,
#'     type = "comparison",
#'     draw = TRUE,
#'     main = "Warning vs Summary Counts (Customized)",
#'     palette = c(warning = "#cb181d", summary = "#3182bd"),
#'     label_angle = 45
#'   )
#' }
#' @export
build_visual_summaries <- function(fit,
                                   diagnostics,
                                   threshold_profile = "standard",
                                   thresholds = NULL,
                                   summary_options = NULL,
                                   whexact = FALSE,
                                   branch = c("original", "facets")) {
  branch <- match.arg(tolower(as.character(branch[1])), c("original", "facets"))
  style <- ifelse(branch == "facets", "facets_manual", "original")

  warning_map <- build_visual_warning_map(
    res = fit,
    diagnostics = diagnostics,
    whexact = whexact,
    thresholds = thresholds,
    threshold_profile = threshold_profile
  )
  summary_map <- build_visual_summary_map(
    res = fit,
    diagnostics = diagnostics,
    whexact = whexact,
    options = summary_options,
    thresholds = thresholds,
    threshold_profile = threshold_profile
  )

  count_map_messages <- function(x) {
    if (is.null(x) || length(x) == 0) return(0L)
    vals <- unlist(x, use.names = FALSE)
    vals <- trimws(as.character(vals))
    sum(nzchar(vals))
  }
  to_count_table <- function(x) {
    keys <- names(x)
    if (is.null(keys) || length(keys) == 0) {
      return(tibble::tibble(Visual = character(0), Messages = integer(0)))
    }
    tibble::tibble(
      Visual = keys,
      Messages = vapply(x, count_map_messages, integer(1))
    ) |>
      dplyr::arrange(dplyr::desc(.data$Messages), .data$Visual)
  }

  crosswalk <- tibble::tibble(
    Visual = c(
      "unexpected",
      "fair_average",
      "displacement",
      "interrater",
      "facets_chisq",
      "residual_pca_overall",
      "residual_pca_by_facet"
    ),
    FACETS = c(
      "Table 4 / Table 10",
      "Table 12",
      "Table 9",
      "Inter-rater outputs",
      "Facet fixed/random chi-square",
      "Residual PCA (overall)",
      "Residual PCA (by facet)"
    )
  )

  out <- list(
    warning_map = warning_map,
    summary_map = summary_map,
    warning_counts = to_count_table(warning_map),
    summary_counts = to_count_table(summary_map),
    crosswalk = crosswalk,
    branch = branch,
    style = style,
    threshold_profile = as.character(threshold_profile[1])
  )
  out <- as_mfrm_bundle(out, "mfrm_visual_summaries")
  class(out) <- unique(c(paste0("mfrm_visual_summaries_", branch), class(out)))
  out
}

resolve_facets_contract_path <- function(contract_file = NULL) {
  if (!is.null(contract_file)) {
    path <- as.character(contract_file[1])
    if (file.exists(path)) return(path)
    stop("`contract_file` does not exist: ", path)
  }

  installed <- system.file("references", "facets_column_contract.csv", package = "mfrmr")
  if (nzchar(installed) && file.exists(installed)) return(installed)

  source_path <- file.path("inst", "references", "facets_column_contract.csv")
  if (file.exists(source_path)) return(source_path)

  stop(
    "Could not locate `facets_column_contract.csv`.\n",
    "Set `contract_file` explicitly or ensure the package was installed with `inst/references`."
  )
}

read_facets_contract <- function(contract_file = NULL, branch = c("facets", "original")) {
  branch <- match.arg(tolower(as.character(branch[1])), c("facets", "original"))
  path <- resolve_facets_contract_path(contract_file)
  contract <- utils::read.csv(path, stringsAsFactors = FALSE)
  need <- c("table_id", "function_name", "object_id", "component", "required_columns")
  if (!all(need %in% names(contract))) {
    stop("FACETS contract file is missing required columns: ", paste(setdiff(need, names(contract)), collapse = ", "))
  }

  # Original branch uses compact Table 11 column names.
  if (identical(branch, "original")) {
    idx <- contract$object_id == "t11" & contract$component == "table"
    contract$required_columns[idx] <- "Count|BiasSize|SE|LowCountFlag"
  }

  list(path = path, contract = contract)
}

split_contract_tokens <- function(required_columns) {
  vals <- strsplit(as.character(required_columns[1]), "|", fixed = TRUE)[[1]]
  vals <- trimws(vals)
  vals[nzchar(vals)]
}

contract_token_present <- function(token, columns) {
  token <- as.character(token[1])
  if (!nzchar(token)) return(TRUE)
  if (endsWith(token, "*")) {
    prefix <- substr(token, 1L, nchar(token) - 1L)
    return(any(startsWith(columns, prefix)))
  }
  token %in% columns
}

make_metric_row <- function(table_id, check, pass, actual = NA_real_, expected = NA_real_, note = "") {
  data.frame(
    Table = as.character(table_id),
    Check = as.character(check),
    Pass = if (is.na(pass)) NA else as.logical(pass),
    Actual = as.character(actual),
    Expected = as.character(expected),
    Note = as.character(note),
    stringsAsFactors = FALSE
  )
}

safe_num <- function(x) suppressWarnings(as.numeric(x))

build_parity_metric_audit <- function(outputs, tol = 1e-8) {
  rows <- list()

  add_row <- function(table_id, check, pass, actual = NA_real_, expected = NA_real_, note = "") {
    rows[[length(rows) + 1L]] <<- make_metric_row(table_id, check, pass, actual, expected, note)
  }

  t4 <- outputs$t4
  if (!is.null(t4) && is.data.frame(t4$summary) && nrow(t4$summary) > 0) {
    s4 <- t4$summary[1, , drop = FALSE]
    total <- safe_num(s4$TotalObservations)
    unexpected_n <- safe_num(s4$UnexpectedN)
    pct <- safe_num(s4$UnexpectedPercent)
    calc <- if (is.finite(total) && total > 0) 100 * unexpected_n / total else NA_real_
    pass <- if (is.finite(calc) && is.finite(pct)) abs(calc - pct) <= 1e-6 else NA
    add_row("T4", "UnexpectedPercent consistency", pass, pct, calc)
  }

  t10 <- outputs$t10
  if (!is.null(t10) && is.data.frame(t10$summary) && nrow(t10$summary) > 0) {
    s10 <- t10$summary[1, , drop = FALSE]
    baseline <- safe_num(s10$BaselineUnexpectedN)
    after <- safe_num(s10$AfterBiasUnexpectedN)
    reduced <- safe_num(s10$ReducedBy)
    reduced_pct <- safe_num(s10$ReducedPercent)
    calc_reduced <- if (all(is.finite(c(baseline, after)))) baseline - after else NA_real_
    calc_pct <- if (is.finite(baseline) && baseline > 0 && is.finite(reduced)) 100 * reduced / baseline else NA_real_
    pass_reduced <- if (is.finite(calc_reduced) && is.finite(reduced)) abs(calc_reduced - reduced) <= tol else NA
    pass_pct <- if (is.finite(calc_pct) && is.finite(reduced_pct)) abs(calc_pct - reduced_pct) <= 1e-6 else NA
    add_row("T10", "ReducedBy consistency", pass_reduced, reduced, calc_reduced)
    add_row("T10", "ReducedPercent consistency", pass_pct, reduced_pct, calc_pct)
  }

  t11 <- outputs$t11
  if (!is.null(t11) && is.data.frame(t11$summary) && nrow(t11$summary) > 0) {
    s11 <- t11$summary[1, , drop = FALSE]
    cells <- safe_num(s11$Cells)
    low <- safe_num(s11$LowCountCells)
    low_pct <- safe_num(s11$LowCountPercent)
    calc <- if (is.finite(cells) && cells > 0 && is.finite(low)) 100 * low / cells else NA_real_
    pass <- if (is.finite(calc) && is.finite(low_pct)) abs(calc - low_pct) <= 1e-6 else NA
    add_row("T11", "LowCountPercent consistency", pass, low_pct, calc)
  }

  t7a <- outputs$t7agree
  if (!is.null(t7a) && is.data.frame(t7a$summary) && nrow(t7a$summary) > 0) {
    s <- t7a$summary[1, , drop = FALSE]
    exact <- safe_num(s$ExactAgreement)
    expected_exact <- safe_num(s$ExpectedExactAgreement)
    adjacent <- safe_num(s$AdjacentAgreement)
    in_range <- function(v) is.finite(v) && v >= -tol && v <= 1 + tol
    add_row("T7", "ExactAgreement range", in_range(exact), exact, "[0,1]")
    add_row("T7", "ExpectedExactAgreement range", in_range(expected_exact), expected_exact, "[0,1]")
    add_row("T7", "AdjacentAgreement range", in_range(adjacent), adjacent, "[0,1]")
  }

  t7c <- outputs$t7chisq
  if (!is.null(t7c) && is.data.frame(t7c$table) && nrow(t7c$table) > 0) {
    fp <- safe_num(t7c$table$FixedProb)
    rp <- safe_num(t7c$table$RandomProb)
    in_unit <- function(v) {
      vals <- v[is.finite(v)]
      if (length(vals) == 0) return(NA)
      all(vals >= -tol & vals <= 1 + tol)
    }
    add_row("T7", "FixedProb range", in_unit(fp), "all", "[0,1]")
    add_row("T7", "RandomProb range", in_unit(rp), "all", "[0,1]")
  }

  disp <- outputs$disp
  if (!is.null(disp) && is.data.frame(disp$summary) && nrow(disp$summary) > 0) {
    s <- disp$summary[1, , drop = FALSE]
    levels_n <- safe_num(s$Levels)
    anchored <- safe_num(s$AnchoredLevels)
    flagged <- safe_num(s$FlaggedLevels)
    flagged_anch <- safe_num(s$FlaggedAnchoredLevels)
    pass1 <- if (all(is.finite(c(levels_n, anchored)))) anchored <= levels_n + tol else NA
    pass2 <- if (all(is.finite(c(levels_n, flagged)))) flagged <= levels_n + tol else NA
    pass3 <- if (all(is.finite(c(anchored, flagged_anch)))) flagged_anch <= anchored + tol else NA
    add_row("T9", "AnchoredLevels <= Levels", pass1, anchored, levels_n)
    add_row("T9", "FlaggedLevels <= Levels", pass2, flagged, levels_n)
    add_row("T9", "FlaggedAnchoredLevels <= AnchoredLevels", pass3, flagged_anch, anchored)
  }

  t81 <- outputs$t81
  if (!is.null(t81) && is.data.frame(t81$summary) && nrow(t81$summary) > 0) {
    s <- t81$summary[1, , drop = FALSE]
    cats <- safe_num(s$Categories)
    used <- safe_num(s$UsedCategories)
    pass_used <- if (all(is.finite(c(cats, used)))) used <= cats + tol else NA
    add_row("T8.1", "UsedCategories <= Categories", pass_used, used, cats)

    tt <- t81$threshold_table
    if (is.data.frame(tt) && nrow(tt) > 1 && "GapFromPrev" %in% names(tt)) {
      gaps <- safe_num(tt$GapFromPrev)
      monotonic_calc <- !any(gaps[is.finite(gaps)] < -tol)
      monotonic_flag <- isTRUE(s$ThresholdMonotonic)
      add_row("T8.1", "ThresholdMonotonic consistency", monotonic_flag == monotonic_calc, monotonic_flag, monotonic_calc)
    }
  }

  if (length(rows) == 0) {
    return(data.frame(
      Table = character(0),
      Check = character(0),
      Pass = logical(0),
      Actual = character(0),
      Expected = character(0),
      Note = character(0),
      stringsAsFactors = FALSE
    ))
  }
  dplyr::bind_rows(rows)
}

#' Build a FACETS parity report (column + metric contracts)
#'
#' @param fit Output from [fit_mfrm()].
#' @param diagnostics Optional output from [diagnose_mfrm()]. If omitted,
#'   diagnostics are computed internally with `residual_pca = "none"`.
#' @param bias_results Optional output from [estimate_bias()]. If omitted and
#'   at least two facets exist, a 2-way bias run is computed internally.
#' @param branch Contract branch. `"facets"` checks FACETS-style columns.
#'   `"original"` adapts branch-sensitive contracts (currently Table 11) to the
#'   package's compact naming.
#' @param contract_file Optional path to a custom contract CSV.
#' @param include_metrics If `TRUE`, run additional numerical consistency checks.
#' @param top_n_missing Number of lowest-coverage contract rows to keep in
#'   `missing_preview`.
#'
#' @details
#' This function compares produced report components to a contract specification
#' (`inst/references/facets_column_contract.csv`) and returns:
#' - column-level coverage per contract row
#' - table-level coverage summaries
#' - optional metric-level consistency checks
#'
#' Coverage interpretation in `overall`:
#' - `MeanColumnCoverage` and `MinColumnCoverage` are computed across all
#'   contract rows (unavailable rows count as 0 coverage).
#' - `MeanColumnCoverageAvailable` and `MinColumnCoverageAvailable` summarize
#'   only rows whose source component is available.
#'
#' `summary(out)` is supported through `summary()`.
#' `plot(out)` is dispatched through `plot()` for class
#' `mfrm_parity_report` (`type = "column_coverage"`, `"table_coverage"`,
#' `"metric_status"`, `"metric_by_table"`).
#'
#' @section Interpreting output:
#' - `overall`: high-level contract coverage and metric-check pass rates.
#' - `column_summary` / `column_audit`: where schema mismatches occur.
#' - `metric_summary` / `metric_audit`: numerical consistency checks.
#' - `missing_preview`: quickest path to unresolved parity gaps.
#'
#' @section Typical workflow:
#' 1. Run `facets_parity_report(fit, branch = "facets")`.
#' 2. Inspect `summary(parity)` and `missing_preview`.
#' 3. Patch upstream table builders, then rerun parity report.
#'
#' @return
#' An object of class `mfrm_parity_report` with:
#' - `overall`: one-row overall parity summary
#' - `column_summary`: coverage summary by table ID
#' - `column_audit`: row-level contract audit
#' - `missing_preview`: lowest-coverage rows
#' - `metric_summary`: one-row metric-check summary
#' - `metric_by_table`: metric-check summary by table ID
#' - `metric_audit`: row-level metric checks
#' - `settings`: branch/contract metadata
#'
#' @seealso [fit_mfrm()], [diagnose_mfrm()], [build_fixed_reports()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
#' diag <- diagnose_mfrm(fit, residual_pca = "none")
#' parity <- facets_parity_report(fit, diagnostics = diag, branch = "facets")
#' summary(parity)
#' p <- plot(parity, draw = FALSE)
#' @export
facets_parity_report <- function(fit,
                                 diagnostics = NULL,
                                 bias_results = NULL,
                                 branch = c("facets", "original"),
                                 contract_file = NULL,
                                 include_metrics = TRUE,
                                 top_n_missing = 15L) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().")
  }
  branch <- match.arg(tolower(as.character(branch[1])), c("facets", "original"))
  include_metrics <- isTRUE(include_metrics)
  top_n_missing <- max(1L, as.integer(top_n_missing))

  if (is.null(diagnostics)) {
    diagnostics <- diagnose_mfrm(fit, residual_pca = "none")
  }

  facet_names <- as.character(fit$config$facet_names %||% character(0))
  if (is.null(bias_results) && length(facet_names) >= 2) {
    bias_results <- estimate_bias(
      fit = fit,
      diagnostics = diagnostics,
      facet_a = facet_names[1],
      facet_b = facet_names[2],
      max_iter = 2
    )
  }

  contract_info <- read_facets_contract(contract_file = contract_file, branch = branch)
  contract <- as.data.frame(contract_info$contract, stringsAsFactors = FALSE)

  # --- Facet-aware token filtering ---
  # The contract CSV is written for the reference data (Person, Rater, Task,

  # Criterion).  When the model has fewer facets, tokens that reference
  # non-existent facets should be excluded from coverage calculations.
  # Derive the set of "reference facets" from the contract's Table 5/subsets
  # row (tokens minus standard structural columns), then subtract the model's
  # actual facets to get the excluded set.
  model_facet_set <- c("Person", as.character(facet_names))
  subsets_row <- contract[contract$object_id == "t5" &
                            contract$component == "subsets", , drop = FALSE]
  if (nrow(subsets_row) > 0) {
    subsets_tokens <- split_contract_tokens(subsets_row$required_columns[1])
    structural_cols <- c("Subset", "Observations", "ObservationPercent")
    reference_facets <- setdiff(subsets_tokens, structural_cols)
  } else {
    reference_facets <- model_facet_set
  }
  excluded_facet_tokens <- setdiff(reference_facets, model_facet_set)

  outputs <- list(
    t1 = specifications_report(fit),
    t2 = data_quality_report(
      fit = fit,
      data = fit$prep$data,
      person = fit$config$person_col,
      facets = fit$config$facet_names,
      score = fit$config$score_col,
      weight = fit$config$weight_col
    ),
    t3 = estimation_iteration_report(fit, max_iter = 5),
    t4 = unexpected_response_table(fit, diagnostics = diagnostics, top_n = 50),
    t5 = measurable_summary_table(fit, diagnostics = diagnostics),
    t6 = subset_connectivity_report(fit, diagnostics = diagnostics),
    t62 = facet_statistics_report(fit, diagnostics = diagnostics),
    t7chisq = facets_chisq_table(fit, diagnostics = diagnostics),
    t7agree = interrater_agreement_table(fit, diagnostics = diagnostics),
    t81 = rating_scale_table(fit, diagnostics = diagnostics),
    t8bar = category_structure_report(fit, diagnostics = diagnostics),
    t8curves = category_curves_report(fit, theta_points = 101),
    out = facets_output_file_bundle(fit, diagnostics = diagnostics, include = c("graph", "score"), theta_points = 81),
    t12 = fair_average_table(fit, diagnostics = diagnostics),
    disp = displacement_table(fit, diagnostics = diagnostics)
  )
  if (!is.null(bias_results) && is.data.frame(bias_results$table) && nrow(bias_results$table) > 0) {
    outputs$t10 <- unexpected_after_bias_table(fit, bias_results, diagnostics = diagnostics, top_n = 50)
    outputs$t11 <- bias_count_table(bias_results, branch = branch)
    outputs$t13 <- bias_interaction_report(bias_results)
    outputs$t14 <- build_fixed_reports(bias_results, branch = branch)
  } else {
    outputs$t10 <- NULL
    outputs$t11 <- NULL
    outputs$t13 <- NULL
    outputs$t14 <- NULL
  }

  audit_rows <- lapply(seq_len(nrow(contract)), function(i) {
    row <- contract[i, , drop = FALSE]
    tokens <- split_contract_tokens(row$required_columns)
    # Exclude tokens for facets not in the current model
    tokens <- tokens[!tokens %in% excluded_facet_tokens]
    obj <- outputs[[row$object_id]]
    if (is.null(obj)) {
      return(data.frame(
        table_id = row$table_id,
        function_name = row$function_name,
        object_id = row$object_id,
        component = row$component,
        required_n = length(tokens),
        present_n = NA_integer_,
        coverage = NA_real_,
        available = FALSE,
        full_match = FALSE,
        status = "missing_object",
        missing = paste(tokens, collapse = " | "),
        stringsAsFactors = FALSE
      ))
    }
    comp <- obj[[row$component]]
    if (!is.data.frame(comp)) {
      return(data.frame(
        table_id = row$table_id,
        function_name = row$function_name,
        object_id = row$object_id,
        component = row$component,
        required_n = length(tokens),
        present_n = NA_integer_,
        coverage = NA_real_,
        available = FALSE,
        full_match = FALSE,
        status = "missing_component",
        missing = paste(tokens, collapse = " | "),
        stringsAsFactors = FALSE
      ))
    }
    cols <- names(comp)
    present <- vapply(tokens, contract_token_present, logical(1), columns = cols)
    missing <- tokens[!present]
    cov <- if (length(tokens) == 0) 1 else sum(present) / length(tokens)
    data.frame(
      table_id = row$table_id,
      function_name = row$function_name,
      object_id = row$object_id,
      component = row$component,
      required_n = length(tokens),
      present_n = sum(present),
      coverage = cov,
      available = TRUE,
      full_match = isTRUE(all(present)),
      status = if (isTRUE(all(present))) "match" else "partial",
      missing = paste(missing, collapse = " | "),
      stringsAsFactors = FALSE
    )
  })
  column_audit <- dplyr::bind_rows(audit_rows)

  summarize_coverage <- function(v, fn) {
    vals <- suppressWarnings(as.numeric(v))
    vals <- vals[is.finite(vals)]
    if (length(vals) == 0) return(NA_real_)
    fn(vals)
  }

  # Contract-level coverage should treat unavailable rows as zero coverage.
  # This avoids reporting perfect mean/min coverage when some contract rows
  # are entirely missing from available outputs.
  contract_coverage_values <- ifelse(
    column_audit$available %in% TRUE,
    suppressWarnings(as.numeric(column_audit$coverage)),
    0
  )
  contract_coverage_values[!is.finite(contract_coverage_values)] <- 0

  column_summary <- column_audit |>
    dplyr::group_by(.data$table_id, .data$function_name) |>
    dplyr::summarize(
      Components = dplyr::n(),
      Available = sum(.data$available, na.rm = TRUE),
      FullMatch = sum(.data$full_match, na.rm = TRUE),
      MeanCoverage = summarize_coverage(.data$coverage, mean),
      MinCoverage = summarize_coverage(.data$coverage, min),
      .groups = "drop"
    ) |>
    dplyr::arrange(.data$table_id, .data$function_name)

  missing_preview <- column_audit |>
    dplyr::filter(!.data$full_match | !.data$available) |>
    dplyr::arrange(.data$coverage, .data$table_id, .data$component) |>
    dplyr::slice_head(n = top_n_missing)

  metric_audit <- if (isTRUE(include_metrics)) {
    build_parity_metric_audit(outputs = outputs)
  } else {
    data.frame(
      Table = character(0),
      Check = character(0),
      Pass = logical(0),
      Actual = character(0),
      Expected = character(0),
      Note = character(0),
      stringsAsFactors = FALSE
    )
  }

  metric_summary <- if (nrow(metric_audit) == 0) {
    data.frame(
      Checks = 0L,
      Evaluated = 0L,
      Passed = 0L,
      Failed = 0L,
      PassRate = NA_real_,
      stringsAsFactors = FALSE
    )
  } else {
    ev <- metric_audit$Pass[!is.na(metric_audit$Pass)]
    data.frame(
      Checks = nrow(metric_audit),
      Evaluated = length(ev),
      Passed = sum(ev %in% TRUE),
      Failed = sum(ev %in% FALSE),
      PassRate = if (length(ev) > 0) sum(ev %in% TRUE) / length(ev) else NA_real_,
      stringsAsFactors = FALSE
    )
  }

  metric_by_table <- if (nrow(metric_audit) == 0) {
    data.frame(
      Table = character(0),
      Checks = integer(0),
      Evaluated = integer(0),
      Passed = integer(0),
      Failed = integer(0),
      PassRate = numeric(0),
      stringsAsFactors = FALSE
    )
  } else {
    metric_audit |>
      dplyr::group_by(.data$Table) |>
      dplyr::summarize(
        Checks = dplyr::n(),
        Evaluated = sum(!is.na(.data$Pass)),
        Passed = sum(.data$Pass %in% TRUE, na.rm = TRUE),
        Failed = sum(.data$Pass %in% FALSE, na.rm = TRUE),
        PassRate = ifelse(sum(!is.na(.data$Pass)) > 0, sum(.data$Pass %in% TRUE, na.rm = TRUE) / sum(!is.na(.data$Pass)), NA_real_),
        .groups = "drop"
      ) |>
      dplyr::arrange(.data$Table)
  }

  mean_cov_all <- summarize_coverage(contract_coverage_values, mean)
  min_cov_all <- summarize_coverage(contract_coverage_values, min)
  mean_cov_available <- summarize_coverage(column_audit$coverage, mean)
  min_cov_available <- summarize_coverage(column_audit$coverage, min)
  contract_rows <- nrow(column_audit)
  mismatches <- sum(!column_audit$full_match, na.rm = TRUE)
  overall <- data.frame(
    Branch = branch,
    ContractRows = contract_rows,
    AvailableRows = sum(column_audit$available, na.rm = TRUE),
    FullMatchRows = sum(column_audit$full_match, na.rm = TRUE),
    ColumnMismatches = mismatches,
    ColumnMismatchRate = if (contract_rows > 0) mismatches / contract_rows else NA_real_,
    MeanColumnCoverage = mean_cov_all,
    MinColumnCoverage = min_cov_all,
    MeanColumnCoverageAvailable = mean_cov_available,
    MinColumnCoverageAvailable = min_cov_available,
    MetricChecks = metric_summary$Checks[1],
    MetricEvaluated = metric_summary$Evaluated[1],
    MetricFailed = metric_summary$Failed[1],
    MetricPassRate = metric_summary$PassRate[1],
    stringsAsFactors = FALSE
  )

  out <- list(
    overall = overall,
    column_summary = as.data.frame(column_summary, stringsAsFactors = FALSE),
    column_audit = as.data.frame(column_audit, stringsAsFactors = FALSE),
    missing_preview = as.data.frame(missing_preview, stringsAsFactors = FALSE),
    metric_summary = metric_summary,
    metric_by_table = as.data.frame(metric_by_table, stringsAsFactors = FALSE),
    metric_audit = as.data.frame(metric_audit, stringsAsFactors = FALSE),
    settings = list(
      branch = branch,
      contract_path = contract_info$path,
      include_metrics = include_metrics,
      top_n_missing = top_n_missing,
      bias_included = !is.null(outputs$t10)
    )
  )
  as_mfrm_bundle(out, "mfrm_parity_report")
}

# ============================================================================
# DIF Report
# ============================================================================

#' Generate DIF interpretation report
#'
#' Produces APA-style narrative text interpreting the results of a DIF
#' analysis or DIF interaction table. The report summarises the number
#' of facet levels classified as negligible (A), moderate (B), and large
#' (C) DIF, lists the specific levels with large DIF and their
#' direction, and includes a caveat about the distinction between
#' construct-relevant variation and measurement bias.
#'
#' @param dif_result Output from [analyze_dif()] (class `mfrm_dif`)
#'   or [dif_interaction_table()] (class `mfrm_dif_interaction`).
#' @param ... Currently unused; reserved for future extensions.
#'
#' @details
#' When `dif_result` is an `mfrm_dif` object, the report is based on
#' the pairwise DIF contrasts in `$dif_table`. When it is an
#' `mfrm_dif_interaction` object, the report uses the cell-level
#' statistics and flags from `$table`.
#'
#' Effect-size classification follows the ETS DIF guidelines:
#' A (negligible, < 0.43 logits), B (moderate, 0.43--0.64 logits),
#' C (large, >= 0.64 logits).
#'
#' @section Interpreting output:
#' - `$narrative`: character scalar with the full narrative text.
#' - `$counts`: named integer vector of A/B/C counts.
#' - `$large_dif`: tibble of levels flagged as large (C) DIF.
#' - `$config`: analysis configuration inherited from the input.
#'
#' @section Typical workflow:
#' 1. Run [analyze_dif()] or [dif_interaction_table()].
#' 2. Pass the result to `dif_report()`.
#' 3. Print the report or extract `$narrative` for inclusion in a
#'    manuscript.
#'
#' @return Object of class `mfrm_dif_report` with `narrative`,
#'   `counts`, `large_dif`, and `config`.
#'
#' @seealso [analyze_dif()], [dif_interaction_table()],
#'   [plot_dif_heatmap()], [build_apa_outputs()]
#' @examples
#' set.seed(42)
#' toy <- expand.grid(
#'   Person = paste0("P", 1:8),
#'   Rater = paste0("R", 1:3),
#'   Criterion = c("Content", "Organization"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- sample(0:2, nrow(toy), replace = TRUE)
#' toy$Group <- ifelse(as.integer(factor(toy$Person)) <= 4, "A", "B")
#'
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                  method = "JML", model = "RSM", maxit = 25)
#' diag <- diagnose_mfrm(fit, residual_pca = "none")
#' dif <- analyze_dif(fit, diag, facet = "Rater", group = "Group", data = toy)
#' rpt <- dif_report(dif)
#' cat(rpt$narrative)
#' @export
dif_report <- function(dif_result, ...) {
  if (inherits(dif_result, "mfrm_dif")) {
    .dif_report_from_dif(dif_result)
  } else if (inherits(dif_result, "mfrm_dif_interaction")) {
    .dif_report_from_interaction(dif_result)
  } else {
    stop("`dif_result` must be an `mfrm_dif` or `mfrm_dif_interaction` object.",
         call. = FALSE)
  }
}

# Internal: generate report from mfrm_dif
.dif_report_from_dif <- function(dif_result) {
  cfg <- dif_result$config
  dt <- dif_result$dif_table

  facet_name <- cfg$facet
  group_name <- cfg$group
  method_label <- cfg$method %||% "refit"

  n_a <- sum(dt$ETS == "A", na.rm = TRUE)
  n_b <- sum(dt$ETS == "B", na.rm = TRUE)
  n_c <- sum(dt$ETS == "C", na.rm = TRUE)
  n_total <- n_a + n_b + n_c
  n_na <- sum(is.na(dt$ETS))

  counts <- c(A = n_a, B = n_b, C = n_c, NA_count = n_na, Total = n_total)

  # Large DIF levels

  large_dif <- dt[!is.na(dt$ETS) & dt$ETS == "C", , drop = FALSE]

  # Build narrative
  lines <- character()
  lines <- c(lines, paste0(
    "Differential functioning analysis was conducted for the ",
    facet_name, " facet across levels of ", group_name,
    " using the ", method_label, " method. "
  ))
  lines <- c(lines, paste0(
    "A total of ", n_total, " pairwise facet-level comparisons were evaluated. "
  ))
  lines <- c(lines, paste0(
    "Following ETS DIF classification guidelines, ",
    n_a, " comparison(s) showed negligible DIF (Category A), ",
    n_b, " showed moderate DIF (Category B), and ",
    n_c, " showed large DIF (Category C). "
  ))
  if (n_na > 0) {
    lines <- c(lines, paste0(
      n_na, " comparison(s) could not be classified due to insufficient ",
      "data or estimation failures. "
    ))
  }

  if (n_c > 0) {
    large_levels <- unique(as.character(large_dif$Level))
    lines <- c(lines, paste0(
      "\nThe following ", facet_name, " level(s) exhibited large DIF (Category C): ",
      paste(large_levels, collapse = ", "), ". "
    ))
    for (lev in large_levels) {
      lev_rows <- large_dif[large_dif$Level == lev, , drop = FALSE]
      for (r in seq_len(nrow(lev_rows))) {
        direction <- if (is.finite(lev_rows$Contrast[r]) && lev_rows$Contrast[r] > 0) {
          "higher"
        } else if (is.finite(lev_rows$Contrast[r]) && lev_rows$Contrast[r] < 0) {
          "lower"
        } else {
          "different"
        }
        lines <- c(lines, paste0(
          "  - ", lev, ": ",
          lev_rows$Group1[r], " vs ", lev_rows$Group2[r],
          " (contrast = ", sprintf("%.3f", lev_rows$Contrast[r]),
          " logits; ", lev_rows$Group1[r], " was ", direction, "). "
        ))
      }
    }
  } else {
    lines <- c(lines,
      "\nNo facet levels showed large DIF, suggesting measurement equivalence across groups. "
    )
  }

  lines <- c(lines, paste0(
    "\nNote: The presence of DIF does not necessarily indicate measurement ",
    "bias. Differential functioning may reflect construct-relevant variation ",
    "(e.g., true group differences in the attribute being measured) rather ",
    "than unwanted measurement bias. Substantive review is recommended to ",
    "distinguish between these possibilities (cf. Eckes, 2011; McNamara & ",
    "Knoch, 2012)."
  ))

  narrative <- paste(lines, collapse = "")

  out <- list(
    narrative = narrative,
    counts = counts,
    large_dif = tibble::as_tibble(large_dif),
    config = cfg
  )
  class(out) <- c("mfrm_dif_report", class(out))
  out
}

# Internal: generate report from mfrm_dif_interaction
.dif_report_from_interaction <- function(dif_result) {
  cfg <- dif_result$config
  int_tbl <- dif_result$table

  facet_name <- cfg$facet
  group_name <- cfg$group

  n_total <- nrow(int_tbl)
  n_sparse <- sum(int_tbl$sparse, na.rm = TRUE)
  n_flag_t <- sum(int_tbl$flag_t == TRUE, na.rm = TRUE)
  n_flag_bias <- sum(int_tbl$flag_bias == TRUE, na.rm = TRUE)

  counts <- c(
    Total = n_total, Sparse = n_sparse,
    Flag_t = n_flag_t, Flag_bias = n_flag_bias
  )

  flagged_rows <- int_tbl[
    (!is.na(int_tbl$flag_t) & int_tbl$flag_t) |
    (!is.na(int_tbl$flag_bias) & int_tbl$flag_bias), , drop = FALSE
  ]

  lines <- character()
  lines <- c(lines, paste0(
    "A DIF interaction analysis was conducted for the ",
    facet_name, " facet across levels of ", group_name,
    " using model-based residuals. "
  ))
  lines <- c(lines, paste0(
    "A total of ", n_total, " facet-level x group cells were examined. "
  ))
  if (n_sparse > 0) {
    lines <- c(lines, paste0(
      n_sparse, " cell(s) had fewer than ", cfg$min_obs,
      " observations and were flagged as sparse. "
    ))
  }
  lines <- c(lines, paste0(
    n_flag_t, " cell(s) exceeded the |t| > ", cfg$abs_t_warn,
    " threshold, and ", n_flag_bias,
    " cell(s) exceeded the |Obs-Exp average| > ", cfg$abs_bias_warn,
    " logit threshold. "
  ))

  if (nrow(flagged_rows) > 0) {
    lines <- c(lines, "\nFlagged cells:")
    for (r in seq_len(nrow(flagged_rows))) {
      lines <- c(lines, paste0(
        "  - ", flagged_rows$Level[r], " x ", flagged_rows$GroupValue[r],
        ": Obs-Exp Avg = ", sprintf("%.3f", flagged_rows$ObsExpAvg[r]),
        ", t = ", sprintf("%.2f", flagged_rows$t[r]),
        " (N = ", flagged_rows$N[r], "). "
      ))
    }
  } else {
    lines <- c(lines,
      "\nNo cells were flagged, suggesting consistent functioning across groups. "
    )
  }

  lines <- c(lines, paste0(
    "\nNote: The presence of differential functioning does not necessarily ",
    "indicate measurement bias. Substantive review is recommended to ",
    "distinguish between construct-relevant variation and unwanted bias ",
    "(cf. Eckes, 2011; McNamara & Knoch, 2012)."
  ))

  narrative <- paste(lines, collapse = "")

  out <- list(
    narrative = narrative,
    counts = counts,
    large_dif = tibble::as_tibble(flagged_rows),
    config = cfg
  )
  class(out) <- c("mfrm_dif_report", class(out))
  out
}

#' @export
print.mfrm_dif_report <- function(x, ...) {
  cat("--- DIF Interpretation Report ---\n\n")
  cat(x$narrative, "\n")
  invisible(x)
}

#' @export
summary.mfrm_dif_report <- function(object, ...) {
  out <- list(
    narrative = object$narrative,
    counts = object$counts,
    large_dif = object$large_dif,
    config = object$config
  )
  class(out) <- "summary.mfrm_dif_report"
  out
}

#' @export
print.summary.mfrm_dif_report <- function(x, ...) {
  cat("--- DIF Report Summary ---\n")
  cat("Facet:", x$config$facet, " | Group:", x$config$group, "\n\n")
  cat("Classification counts:\n")
  print(x$counts)
  cat("\n")
  if (nrow(x$large_dif) > 0) {
    cat("Flagged levels:\n")
    print(as.data.frame(x$large_dif), row.names = FALSE, digits = 3)
  } else {
    cat("No levels flagged.\n")
  }
  invisible(x)
}

# ---- Phase 5: QC Pipeline ------------------------------------------------

#' Run automated quality control pipeline
#'
#' Integrates convergence, model fit, reliability, separation, element misfit,
#' unexpected responses, category structure, connectivity, inter-rater agreement,
#' and DIF/bias into a single pass/warn/fail report.
#'
#' @param fit Output from [fit_mfrm()].
#' @param diagnostics Output from [diagnose_mfrm()]. Computed automatically if NULL.
#' @param threshold_profile Threshold preset: `"strict"`, `"standard"` (default),
#'   or `"lenient"`.
#' @param thresholds Named list to override individual thresholds.
#' @param rater_facet Character name of the rater facet for inter-rater check
#'   (auto-detected if NULL).
#' @param include_bias If `TRUE` and bias available in diagnostics, check DIF/bias.
#' @param bias_results Optional pre-computed bias results from [estimate_bias()].
#'
#' @details
#' The pipeline evaluates 10 quality checks and assigns a verdict
#' (Pass / Warn / Fail) to each.  The overall status is the most severe
#' verdict across all checks.  Diagnostics are computed automatically via
#' [diagnose_mfrm()] if not supplied.
#'
#' Three threshold presets are available via `threshold_profile`:
#'
#' | Aspect            | strict  | standard | lenient |
#' | :---------------- | :------ | :------- | :------ |
#' | Global fit warn   | 1.3     | 1.5      | 1.7     |
#' | Global fit fail   | 1.5     | 2.0      | 2.5     |
#' | Reliability pass  | 0.90    | 0.80     | 0.70    |
#' | Separation pass   | 3.0     | 2.0      | 1.5     |
#' | Misfit warn (pct) | 3       | 5        | 10      |
#' | Unexpected fail   | 3       | 5        | 10      |
#' | Min cat count     | 15      | 10       | 5       |
#' | Agreement pass    | 60      | 50       | 40      |
#' | Bias fail (pct)   | 5       | 10       | 15      |
#'
#' Individual thresholds can be overridden via the `thresholds` argument
#' (a named list keyed by the internal threshold names shown above).
#'
#' @section QC checks:
#' The 10 checks are:
#' \enumerate{
#'   \item **Convergence**: Did the model converge?
#'   \item **Global fit**: Infit/Outfit MnSq within acceptable bounds.
#'   \item **Reliability**: Minimum non-person facet reliability.
#'   \item **Separation**: Minimum non-person facet separation index.
#'   \item **Element misfit**: Percentage of elements with Infit/Outfit
#'         outside the acceptable range.
#'   \item **Unexpected responses**: Percentage of observations with
#'         large standardized residuals.
#'   \item **Category structure**: Minimum category count and threshold
#'         ordering.
#'   \item **Connectivity**: All observations in a single connected subset.
#'   \item **Inter-rater agreement**: Exact agreement percentage for the
#'         rater facet (if applicable).
#'   \item **DIF/Bias**: Percentage of flagged bias interactions (if
#'         bias results are available).
#' }
#'
#' @section Interpreting output:
#' - `$overall`: character string `"Pass"`, `"Warn"`, or `"Fail"`.
#' - `$verdicts`: tibble with columns `Check`, `Verdict`, `Value`, and
#'   `Threshold` for each of the 10 checks.
#' - `$details`: character vector of human-readable detail strings.
#' - `$raw_details`: named list of per-check numeric details for
#'   programmatic access.
#' - `$recommendations`: character vector of actionable suggestions for
#'   checks that did not pass.
#' - `$config`: records the threshold profile and effective thresholds.
#'
#' @section Typical workflow:
#' 1. Fit a model: `fit <- fit_mfrm(...)`.
#' 2. Optionally compute diagnostics and bias:
#'    `diag <- diagnose_mfrm(fit)`;
#'    `bias <- estimate_bias(fit, diag, ...)`.
#' 3. Run the pipeline: `qc <- run_qc_pipeline(fit, diag, bias_results = bias)`.
#' 4. Check `qc$overall` for the headline verdict.
#' 5. Review `qc$verdicts` for per-check details.
#' 6. Follow `qc$recommendations` for remediation.
#' 7. Visualize with [plot_qc_pipeline()].
#'
#' @return Object of class `mfrm_qc_pipeline` with verdicts, overall status,
#'   details, and recommendations.
#'
#' @seealso [diagnose_mfrm()], [estimate_bias()],
#'   [mfrm_threshold_profiles()], [plot_qc_pipeline()],
#'   [plot_qc_dashboard()], [build_visual_summaries()]
#' @examples
#' toy <- load_mfrmr_data("study1")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 25)
#' qc <- run_qc_pipeline(fit)
#' qc
#' summary(qc)
#' qc$verdicts
#' @export
run_qc_pipeline <- function(fit,
                            diagnostics = NULL,
                            threshold_profile = "standard",
                            thresholds = NULL,
                            rater_facet = NULL,
                            include_bias = TRUE,
                            bias_results = NULL) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm(). ",
         "Got: ", paste(class(fit), collapse = "/"), ".", call. = FALSE)
  }

  # -- compute diagnostics if needed --
  if (is.null(diagnostics)) {
    diagnostics <- diagnose_mfrm(fit, residual_pca = "none")
  }

  # -- resolve threshold profile --
  threshold_profile <- match.arg(tolower(threshold_profile),
                                 c("strict", "standard", "lenient"))

  defaults_standard <- list(
    global_fit_warn = 1.5,
    global_fit_fail = 2.0,
    global_fit_low  = 0.5,
    reliability_pass = 0.80,
    reliability_warn = 0.50,
    separation_pass = 2.0,
    separation_warn = 1.0,
    misfit_warn_pct = 5,
    misfit_fail_pct = 15,
    misfit_high = 1.5,
    misfit_low  = 0.5,
    unexpected_warn_pct = 2,
    unexpected_fail_pct = 5,
    min_cat_count = 10,
    agreement_pass_pct = 50,
    agreement_warn_pct = 30,
    bias_warn_pct = 0,
    bias_fail_pct = 10
  )

  defaults_strict <- modifyList(defaults_standard, list(
    global_fit_warn = 1.3,
    global_fit_fail = 1.5,
    reliability_pass = 0.90,
    reliability_warn = 0.70,
    separation_pass = 3.0,
    separation_warn = 2.0,
    misfit_warn_pct = 3,
    misfit_fail_pct = 10,
    unexpected_warn_pct = 1,
    unexpected_fail_pct = 3,
    min_cat_count = 15,
    agreement_pass_pct = 60,
    agreement_warn_pct = 40,
    bias_warn_pct = 0,
    bias_fail_pct = 5
  ))

  defaults_lenient <- modifyList(defaults_standard, list(
    global_fit_warn = 1.7,
    global_fit_fail = 2.5,
    global_fit_low  = 0.3,
    reliability_pass = 0.70,
    reliability_warn = 0.40,
    separation_pass = 1.5,
    separation_warn = 0.5,
    misfit_warn_pct = 10,
    misfit_fail_pct = 25,
    misfit_high = 2.0,
    misfit_low  = 0.3,
    unexpected_warn_pct = 5,
    unexpected_fail_pct = 10,
    min_cat_count = 5,
    agreement_pass_pct = 40,
    agreement_warn_pct = 20,
    bias_warn_pct = 5,
    bias_fail_pct = 15
  ))

  defaults <- switch(threshold_profile,
                     strict   = defaults_strict,
                     lenient  = defaults_lenient,
                     defaults_standard)

  effective_thresholds <- modifyList(defaults, thresholds %||% list())
  thr <- effective_thresholds

  # -- helpers --
  fmt_pct <- function(x) {
    if (is.na(x)) return("NA")
    sprintf("%.1f%%", x)
  }
  fmt_num <- function(x, digits = 2) {
    if (is.na(x)) return("NA")
    formatC(x, format = "f", digits = digits)
  }

  verdicts <- character(10)
  values   <- character(10)
  thresh   <- character(10)

  details  <- character(10)
  raw_details <- list()
  recommendations <- character(0)

  # ---- Check 1: Convergence ----
  converged <- isTRUE(fit$summary$Converged)
  verdicts[1] <- if (converged) "Pass" else "Fail"
  values[1]   <- if (converged) "TRUE" else "FALSE"
  thresh[1]   <- "Converged = TRUE"
  details[1]  <- if (converged) "Model converged" else "Model did NOT converge"
  raw_details$convergence <- list(converged = converged,
                                  iterations = fit$summary$Iterations)
  if (!converged) {
    recommendations <- c(recommendations,
                         "Model did not converge. Consider increasing maxit, simplifying the model, or checking data quality.")
  }

  # ---- Check 2: Global Fit ----
  infit_global  <- as.numeric(diagnostics$overall_fit$Infit[1])
  outfit_global <- as.numeric(diagnostics$overall_fit$Outfit[1])
  if (is.na(infit_global))  infit_global  <- 1.0
  if (is.na(outfit_global)) outfit_global <- 1.0

  gf_max <- max(infit_global, outfit_global, na.rm = TRUE)
  gf_min <- min(infit_global, outfit_global, na.rm = TRUE)

  if (gf_max > thr$global_fit_fail || gf_min < thr$global_fit_low) {
    verdicts[2] <- "Fail"
  } else if (gf_max > thr$global_fit_warn) {
    verdicts[2] <- "Warn"
  } else if (gf_min < thr$global_fit_low) {
    verdicts[2] <- "Warn"
  } else {
    verdicts[2] <- "Pass"
  }
  values[2]  <- sprintf("Infit=%.2f, Outfit=%.2f", infit_global, outfit_global)
  thresh[2]  <- sprintf("[%.2f, %.2f]", thr$global_fit_low, thr$global_fit_warn)
  details[2] <- sprintf("Global Infit=%.3f, Outfit=%.3f", infit_global, outfit_global)
  raw_details$global_fit <- list(infit = infit_global, outfit = outfit_global)
  if (verdicts[2] != "Pass") {
    recommendations <- c(recommendations,
                         "Global fit indices outside acceptable range. Investigate element-level misfit.")
  }

  # ---- Check 3: Reliability ----
  rel_tbl <- diagnostics$reliability
  if (!is.null(rel_tbl) && nrow(rel_tbl) > 0 && "Facet" %in% names(rel_tbl)) {
    rel_non_person <- rel_tbl[rel_tbl$Facet != "Person", , drop = FALSE]
    if (nrow(rel_non_person) > 0 && "Reliability" %in% names(rel_non_person)) {
      min_rel <- min(rel_non_person$Reliability, na.rm = TRUE)
    } else {
      min_rel <- NA_real_
    }
  } else {
    min_rel <- NA_real_
  }

  if (is.na(min_rel) || !is.finite(min_rel)) {
    verdicts[3] <- "Warn"
    values[3]   <- "NA"
    details[3]  <- "Reliability could not be computed"
  } else if (min_rel >= thr$reliability_pass) {
    verdicts[3] <- "Pass"
    values[3]   <- fmt_num(min_rel)
    details[3]  <- sprintf("Min non-person reliability = %.3f", min_rel)
  } else if (min_rel >= thr$reliability_warn) {
    verdicts[3] <- "Warn"
    values[3]   <- fmt_num(min_rel)
    details[3]  <- sprintf("Min non-person reliability = %.3f (below %.2f)", min_rel, thr$reliability_pass)
  } else {
    verdicts[3] <- "Fail"
    values[3]   <- fmt_num(min_rel)
    details[3]  <- sprintf("Min non-person reliability = %.3f (below %.2f)", min_rel, thr$reliability_warn)
  }
  thresh[3] <- sprintf("Pass>=%.2f, Warn>=%.2f", thr$reliability_pass, thr$reliability_warn)
  raw_details$reliability <- list(min_reliability = min_rel, table = rel_tbl)
  if (verdicts[3] == "Fail") {
    recommendations <- c(recommendations,
                         "Low facet reliability. Consider increasing sample size or reducing measurement noise.")
  }

  # ---- Check 4: Separation ----
  if (!is.null(rel_tbl) && nrow(rel_tbl) > 0 && "Facet" %in% names(rel_tbl)) {
    sep_non_person <- rel_tbl[rel_tbl$Facet != "Person", , drop = FALSE]
    if (nrow(sep_non_person) > 0 && "Separation" %in% names(sep_non_person)) {
      min_sep <- min(sep_non_person$Separation, na.rm = TRUE)
    } else {
      min_sep <- NA_real_
    }
  } else {
    min_sep <- NA_real_
  }

  if (is.na(min_sep) || !is.finite(min_sep)) {
    verdicts[4] <- "Warn"
    values[4]   <- "NA"
    details[4]  <- "Separation could not be computed"
  } else if (min_sep >= thr$separation_pass) {
    verdicts[4] <- "Pass"
    values[4]   <- fmt_num(min_sep)
    details[4]  <- sprintf("Min non-person separation = %.3f", min_sep)
  } else if (min_sep >= thr$separation_warn) {
    verdicts[4] <- "Warn"
    values[4]   <- fmt_num(min_sep)
    details[4]  <- sprintf("Min non-person separation = %.3f (below %.2f)", min_sep, thr$separation_pass)
  } else {
    verdicts[4] <- "Fail"
    values[4]   <- fmt_num(min_sep)
    details[4]  <- sprintf("Min non-person separation = %.3f (below %.2f)", min_sep, thr$separation_warn)
  }
  thresh[4] <- sprintf("Pass>=%.2f, Warn>=%.2f", thr$separation_pass, thr$separation_warn)
  raw_details$separation <- list(min_separation = min_sep)
  if (verdicts[4] == "Fail") {
    recommendations <- c(recommendations,
                         "Low facet separation. Elements may not be distinguishable. Review facet design.")
  }

  # ---- Check 5: Element Misfit ----
  fit_tbl <- diagnostics$fit
  if (!is.null(fit_tbl) && nrow(fit_tbl) > 0 &&
      all(c("Infit", "Outfit") %in% names(fit_tbl))) {
    n_elements <- nrow(fit_tbl)
    flagged <- (fit_tbl$Infit > thr$misfit_high | fit_tbl$Outfit > thr$misfit_high |
                  fit_tbl$Infit < thr$misfit_low | fit_tbl$Outfit < thr$misfit_low)
    flagged[is.na(flagged)] <- FALSE
    n_flagged <- sum(flagged)
    misfit_pct <- 100 * n_flagged / n_elements
  } else {
    n_elements <- 0
    n_flagged  <- 0
    misfit_pct <- 0
  }

  if (misfit_pct <= thr$misfit_warn_pct) {
    verdicts[5] <- "Pass"
  } else if (misfit_pct <= thr$misfit_fail_pct) {
    verdicts[5] <- "Warn"
  } else {
    verdicts[5] <- "Fail"
  }
  values[5]  <- sprintf("%d/%d (%.1f%%)", n_flagged, n_elements, misfit_pct)
  thresh[5]  <- sprintf("Pass<=%.0f%%, Fail>%.0f%%", thr$misfit_warn_pct, thr$misfit_fail_pct)
  details[5] <- sprintf("%d of %d elements misfitting (%.1f%%)", n_flagged, n_elements, misfit_pct)
  raw_details$element_misfit <- list(n_flagged = n_flagged, n_elements = n_elements,
                                     misfit_pct = misfit_pct)
  if (verdicts[5] != "Pass") {
    recommendations <- c(recommendations,
                         "Excessive element misfit detected. Review individual element fit statistics.")
  }

  # ---- Check 6: Unexpected Responses ----
  unexp_pct <- 0
  if (!is.null(diagnostics$unexpected$summary) &&
      "UnexpectedPercent" %in% names(diagnostics$unexpected$summary)) {
    unexp_pct <- as.numeric(diagnostics$unexpected$summary$UnexpectedPercent[1])
  }
  if (is.na(unexp_pct)) unexp_pct <- 0

  if (unexp_pct <= thr$unexpected_warn_pct) {
    verdicts[6] <- "Pass"
  } else if (unexp_pct <= thr$unexpected_fail_pct) {
    verdicts[6] <- "Warn"
  } else {
    verdicts[6] <- "Fail"
  }
  values[6]  <- fmt_pct(unexp_pct)
  thresh[6]  <- sprintf("Pass<=%.0f%%, Fail>%.0f%%", thr$unexpected_warn_pct, thr$unexpected_fail_pct)
  details[6] <- sprintf("%.1f%% unexpected responses", unexp_pct)
  raw_details$unexpected <- list(unexpected_pct = unexp_pct)
  if (verdicts[6] != "Pass") {
    recommendations <- c(recommendations,
                         "High unexpected response rate. Inspect unexpected_response_table() for patterns.")
  }

  # ---- Check 7: Category Structure ----
  step_est <- suppressWarnings(as.numeric(fit$steps$Estimate))
  ordered_steps <- if (length(step_est) > 1) {
    all(diff(step_est) > -sqrt(.Machine$double.eps), na.rm = TRUE)
  } else {
    TRUE
  }

  min_cat_count <- NA_real_
  tryCatch({
    rs <- rating_scale_table(fit, diagnostics)
    if (!is.null(rs$summary) && "MinCategoryCount" %in% names(rs$summary)) {
      min_cat_count <- as.numeric(rs$summary$MinCategoryCount[1])
    }
  }, error = function(e) NULL)

  cat_count_ok <- is.na(min_cat_count) || min_cat_count >= thr$min_cat_count

  if (ordered_steps && cat_count_ok) {
    verdicts[7] <- "Pass"
    details[7]  <- "Thresholds ordered"
    if (!is.na(min_cat_count)) {
      details[7] <- sprintf("Thresholds ordered, min category count = %d", as.integer(min_cat_count))
    }
  } else if (!ordered_steps && cat_count_ok) {
    verdicts[7] <- "Warn"
    details[7]  <- "Thresholds disordered"
  } else if (ordered_steps && !cat_count_ok) {
    verdicts[7] <- "Warn"
    details[7]  <- sprintf("Thresholds ordered but min category count = %d (< %d)",
                           as.integer(min_cat_count), as.integer(thr$min_cat_count))
  } else {
    verdicts[7] <- "Fail"
    details[7]  <- sprintf("Thresholds disordered, min category count = %d (< %d)",
                           as.integer(min_cat_count), as.integer(thr$min_cat_count))
  }
  values[7] <- sprintf("Ordered=%s, MinCount=%s",
                        if (ordered_steps) "Yes" else "No",
                        if (is.na(min_cat_count)) "NA" else as.character(as.integer(min_cat_count)))
  thresh[7] <- sprintf("Ordered + count>=%d", as.integer(thr$min_cat_count))
  raw_details$category_structure <- list(ordered = ordered_steps,
                                          min_cat_count = min_cat_count)
  if (verdicts[7] != "Pass") {
    recommendations <- c(recommendations,
                         "Category structure issues. Consider collapsing rating scale categories.")
  }

  # ---- Check 8: Connectivity ----
  n_subsets <- 1L
  if (!is.null(diagnostics$subsets$summary) && nrow(diagnostics$subsets$summary) > 0) {
    n_subsets <- nrow(diagnostics$subsets$summary)
  }

  if (n_subsets == 1L) {
    verdicts[8] <- "Pass"
  } else if (n_subsets == 2L) {
    verdicts[8] <- "Warn"
  } else {
    verdicts[8] <- "Fail"
  }
  values[8]  <- as.character(n_subsets)
  thresh[8]  <- "Pass=1, Warn=2, Fail>=3"
  details[8] <- sprintf("%d disjoint subset(s)", n_subsets)
  raw_details$connectivity <- list(n_subsets = n_subsets)
  if (n_subsets > 1L) {
    recommendations <- c(recommendations,
                         sprintf("Data has %d disjoint subsets. Measures are not directly comparable across subsets.", n_subsets))
  }

  # ---- Check 9: Inter-rater Agreement ----
  detected_rater <- rater_facet
  if (is.null(detected_rater)) {
    detected_rater <- infer_default_rater_facet(fit$config$facet_names)
  }

  ira_pct <- NA_real_
  ira_available <- FALSE
  tryCatch({
    if (!is.null(detected_rater) && detected_rater %in% fit$config$facet_names) {
      ira <- interrater_agreement_table(fit, diagnostics, rater_facet = detected_rater)
      if (!is.null(ira$summary) && nrow(ira$summary) > 0 &&
          "ExactAgreement" %in% names(ira$summary)) {
        ira_pct <- as.numeric(ira$summary$ExactAgreement[1]) * 100
        ira_available <- TRUE
      }
    }
  }, error = function(e) NULL)

  if (!ira_available || is.na(ira_pct)) {
    verdicts[9] <- "Skip"
    values[9]   <- "NA"
    details[9]  <- "No rater facet available or inter-rater agreement could not be computed"
    thresh[9]   <- sprintf("Pass>=%.0f%%, Warn>=%.0f%%",
                           thr$agreement_pass_pct, thr$agreement_warn_pct)
  } else {
    if (ira_pct >= thr$agreement_pass_pct) {
      verdicts[9] <- "Pass"
    } else if (ira_pct >= thr$agreement_warn_pct) {
      verdicts[9] <- "Warn"
    } else {
      verdicts[9] <- "Fail"
    }
    values[9]  <- fmt_pct(ira_pct)
    thresh[9]  <- sprintf("Pass>=%.0f%%, Warn>=%.0f%%",
                          thr$agreement_pass_pct, thr$agreement_warn_pct)
    details[9] <- sprintf("Exact agreement = %.1f%%", ira_pct)
  }
  raw_details$interrater <- list(exact_agreement_pct = ira_pct,
                                  rater_facet = detected_rater)
  if (verdicts[9] == "Fail") {
    recommendations <- c(recommendations,
                         "Low inter-rater agreement. Consider rater training or calibration.")
  }

  # ---- Check 10: DIF/Bias ----
  bias_pct <- NA_real_
  bias_available <- FALSE

  if (isTRUE(include_bias)) {
    tryCatch({
      br <- bias_results
      if (is.null(br) && !is.null(diagnostics$interactions) &&
          is.data.frame(diagnostics$interactions) &&
          nrow(diagnostics$interactions) > 0) {
        # Use interaction table from diagnostics as proxy
        if (all(c("t_Residual") %in% names(diagnostics$interactions))) {
          t_vals <- suppressWarnings(as.numeric(diagnostics$interactions$t_Residual))
          t_vals <- t_vals[is.finite(t_vals)]
          if (length(t_vals) > 0) {
            n_sig <- sum(abs(t_vals) > 2)
            bias_pct <- 100 * n_sig / length(t_vals)
            bias_available <- TRUE
          }
        }
      }
      if (!bias_available && !is.null(br)) {
        # Use pre-computed bias_results
        bias_tbl_src <- NULL
        if (is.data.frame(br)) {
          bias_tbl_src <- br
        } else if (is.list(br) && !is.null(br$table) && is.data.frame(br$table)) {
          bias_tbl_src <- br$table
        } else if (is.list(br) && !is.null(br$bias_table) && is.data.frame(br$bias_table)) {
          bias_tbl_src <- br$bias_table
        }
        if (!is.null(bias_tbl_src)) {
          t_col <- intersect(c("t_Residual", "t", "t.value", "Bias t"), names(bias_tbl_src))
          if (length(t_col) > 0) {
            t_vals <- suppressWarnings(as.numeric(bias_tbl_src[[t_col[1]]]))
            t_vals <- t_vals[is.finite(t_vals)]
            if (length(t_vals) > 0) {
              n_sig <- sum(abs(t_vals) > 2)
              bias_pct <- 100 * n_sig / length(t_vals)
              bias_available <- TRUE
            }
          }
        }
      }
    }, error = function(e) NULL)
  }

  if (!bias_available || is.na(bias_pct)) {
    verdicts[10] <- "Skip"
    values[10]   <- "NA"
    details[10]  <- "DIF/Bias check not available"
    thresh[10]   <- sprintf("Pass<=%.0f%%, Fail>%.0f%%", thr$bias_warn_pct, thr$bias_fail_pct)
  } else {
    if (bias_pct <= thr$bias_warn_pct) {
      verdicts[10] <- "Pass"
    } else if (bias_pct <= thr$bias_fail_pct) {
      verdicts[10] <- "Warn"
    } else {
      verdicts[10] <- "Fail"
    }
    values[10]  <- fmt_pct(bias_pct)
    thresh[10]  <- sprintf("Pass<=%.0f%%, Fail>%.0f%%", thr$bias_warn_pct, thr$bias_fail_pct)
    details[10] <- sprintf("%.1f%% of interactions with |t| > 2", bias_pct)
  }
  raw_details$bias <- list(bias_pct = bias_pct, available = bias_available)
  if (isTRUE(verdicts[10] == "Fail")) {
    recommendations <- c(recommendations,
                         "Significant DIF/bias detected. Investigate interaction patterns with estimate_bias().")
  }

  # -- build verdicts tibble --
  verdicts_tbl <- tibble::tibble(
    Check     = c("Convergence", "Global Fit", "Reliability", "Separation",
                  "Element Misfit", "Unexpected Responses", "Category Structure",
                  "Connectivity", "Inter-rater Agreement", "DIF/Bias"),
    Verdict   = verdicts,
    Value     = values,
    Threshold = thresh,
    Detail    = details
  )

  # -- overall verdict --
  active_verdicts <- verdicts[verdicts != "Skip"]
  if (any(active_verdicts == "Fail")) {
    overall <- "Fail"
  } else if (any(active_verdicts == "Warn")) {
    overall <- "Warn"
  } else {
    overall <- "Pass"
  }

  out <- list(
    verdicts = verdicts_tbl,
    overall  = overall,
    details  = raw_details,
    recommendations = recommendations,
    config   = list(threshold_profile = threshold_profile,
                    thresholds = effective_thresholds)
  )
  class(out) <- c("mfrm_qc_pipeline", "list")
  out
}

#' @export
print.mfrm_qc_pipeline <- function(x, ...) {
  cat("--- QC Pipeline ---\n")
  cat("Overall:", x$overall, "\n\n")
  vt <- x$verdicts
  markers <- ifelse(vt$Verdict == "Pass", "[PASS]",
                    ifelse(vt$Verdict == "Warn", "[WARN]",
                           ifelse(vt$Verdict == "Fail", "[FAIL]", "[SKIP]")))
  for (i in seq_len(nrow(vt))) {
    cat(sprintf("  %s %-25s %s\n", markers[i], vt$Check[i], vt$Detail[i]))
  }
  if (length(x$recommendations) > 0) {
    cat("\nRecommendations:\n")
    for (r in x$recommendations) cat("  -", r, "\n")
  }
  invisible(x)
}

#' @export
summary.mfrm_qc_pipeline <- function(object, ...) {
  out <- list(
    verdicts = object$verdicts,
    overall  = object$overall,
    recommendations = object$recommendations,
    pass_count = sum(object$verdicts$Verdict == "Pass"),
    warn_count = sum(object$verdicts$Verdict == "Warn"),
    fail_count = sum(object$verdicts$Verdict == "Fail"),
    skip_count = sum(object$verdicts$Verdict == "Skip")
  )
  class(out) <- "summary.mfrm_qc_pipeline"
  out
}

#' @export
print.summary.mfrm_qc_pipeline <- function(x, ...) {
  cat("--- QC Pipeline Summary ---\n")
  cat("Overall:", x$overall, "\n")
  cat(sprintf("Pass: %d | Warn: %d | Fail: %d | Skip: %d\n\n",
              x$pass_count, x$warn_count, x$fail_count, x$skip_count))
  print(as.data.frame(x$verdicts), row.names = FALSE)
  if (length(x$recommendations) > 0) {
    cat("\nRecommendations:\n")
    for (r in x$recommendations) cat("  -", r, "\n")
  }
  invisible(x)
}
