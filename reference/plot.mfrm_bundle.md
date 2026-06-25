# Plot report/table bundles with base R defaults

Plot report/table bundles with base R defaults

## Usage

``` r
# S3 method for class 'mfrm_bundle'
plot(x, y = NULL, type = NULL, ...)
```

## Arguments

- x:

  A bundle object returned by mfrmr table/report helpers.

- y:

  Reserved for generic compatibility.

- type:

  Optional plot type. Available values depend on bundle class.

- ...:

  Additional arguments forwarded to class-specific plotters.

## Value

A plotting-data object of class `mfrm_plot_data`.

## Details

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) dispatches by
bundle class:

- `mfrm_unexpected` -\>
  [`plot_unexpected()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_unexpected.md)

- `mfrm_fair_average` -\>
  [`plot_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_fair_average.md)

- `mfrm_displacement` -\>
  [`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md)

- `mfrm_interrater` -\>
  [`plot_interrater_agreement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_interrater_agreement.md)

- `mfrm_facets_chisq` -\>
  [`plot_facets_chisq()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facets_chisq.md)

- `mfrm_bias_interaction` -\>
  [`plot_bias_interaction()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bias_interaction.md)

- `mfrm_bias_count` -\> bias-count plots (cell counts / low-count rates)

- `mfrm_fixed_reports` -\> pairwise-contrast diagnostics

- `mfrm_visual_summaries` -\> warning/summary message count plots

- `mfrm_category_structure` -\> default base-R category plots

- `mfrm_category_curves` -\> overview (default), ogive, CCC / category
  probability / conditional probability, cumulative, total-information,
  and category-specific-information plots

- `mfrm_rating_scale` -\> category-counts/threshold plots

- `mfrm_measurable` -\> measurable-data coverage/count plots

- `mfrm_unexpected_after_bias` -\> post-bias unexpected-response plots

- `mfrm_output_bundle` -\> graph/score output-file diagnostics,
  including `type = "score_se"` when scorefile SE columns are available

- `mfrm_residual_pca` -\> residual PCA scree, parallel-analysis, or
  loadings views via
  [`plot_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_pca.md)

- `mfrm_specifications` -\> facet/anchor/convergence plots

- `mfrm_data_quality` -\> dashboard, quality-flag, score-map,
  facet-pattern, and row/category/missing-row plots

- `mfrm_facets_fit_review` -\> FACETS-style df-sensitivity plot

- `mfrm_fit_measures` -\> fit-status counts, Infit/Outfit scatter,
  measure intervals, and FACETS-style df-sensitivity plots

- `mfrm_iteration_report` -\> replayed-iteration trajectories

- `mfrm_subset_connectivity` -\> subset-observation/connectivity plots

- `mfrm_facet_statistics` -\> facet statistic profile plots

- `mfrm_export_bundle` / `mfrm_summary_appendix_export` -\> export
  handoff plots (`formats`, `artifact_groups`, `selection_tables`,
  `selection_handoff`, `selection_handoff_bundles`,
  `selection_handoff_roles`, `selection_handoff_role_sections`,
  `selection_bundles`, `selection_roles`, `selection_sections`)

If a class is outside these families, use dedicated plotting helpers or
custom base R graphics on component tables.

For `mfrm_category_curves`, pass `preset = "monochrome"` for
grayscale/line-type output. Cumulative `.5` boundary lines are shown
only for interpretable in-range boundaries by default; use
`boundary_status = "all"` to show every finite boundary estimate or
`boundary_status = "none"` / `show_cumulative_boundaries = FALSE` to
suppress those vertical boundary lines. Use
`plot_data(x, component = "plot_long")` on a category-curve bundle when
you want one ggplot2/plotly-friendly table across all curve families.

## Interpreting output

The returned object is plotting data (`mfrm_plot_data`) that captures
the selected route and reusable data; set `draw = TRUE` for immediate
base graphics.

## Typical workflow

1.  Create bundle output (e.g.,
    [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md)).

2.  Inspect routing with `summary(bundle)` if needed.

3.  Call `plot(bundle, type = ..., draw = FALSE)` to obtain reusable
    plot data.

## See also

[`summary()`](https://rdrr.io/r/base/summary.html),
[`plot_unexpected()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_unexpected.md),
[`plot_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_fair_average.md),
[`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy_full <- load_mfrmr_data("example_core")
toy_people <- unique(toy_full$Person)[1:12]
toy <- toy_full[toy_full$Person %in% toy_people, , drop = FALSE]
fit <- suppressWarnings(
  fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
)
t4 <- unexpected_response_table(fit, abs_z_min = 1.5, prob_max = 0.4, top_n = 5)
p <- plot(t4, draw = FALSE)
vis <- build_visual_summaries(fit, diagnose_mfrm(fit, residual_pca = "none"))
p_vis <- plot(vis, type = "comparison", draw = FALSE)
spec <- specifications_report(fit)
p_spec <- plot(spec, type = "facet_elements", draw = FALSE)
if (interactive()) {
  plot(
    t4,
    type = "severity",
    draw = TRUE,
    main = "Unexpected Response Severity (Customized)",
    palette = c(higher = "#d95f02", lower = "#1b9e77", bar = "#2b8cbe"),
    label_angle = 45
  )
  plot(
    vis,
    type = "comparison",
    draw = TRUE,
    main = "Warning vs Summary Counts (Customized)",
    palette = c(warning = "#cb181d", summary = "#3182bd"),
    label_angle = 45
  )
}
} # }
```
