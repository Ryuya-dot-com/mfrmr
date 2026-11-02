# Plot report/table bundles with ggplot2

Plot report/table bundles with ggplot2

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

A `ggplot` object (invisibly), carrying the underlying `mfrm_plot_data`
payload accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md).

## Details

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) dispatches by
bundle class:

- `mfrm_unexpected` -\> [plot(x, type =
  "unexpected")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)

- `mfrm_fair_average` -\> [plot(x, type =
  "fair_average")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)

- `mfrm_displacement` -\> [plot(x, type =
  "displacement")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)

- `mfrm_interrater` -\> [plot(x, type =
  "agreement")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)

- `mfrm_facets_chisq` -\> [plot(x, type =
  "facets_chisq")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)

- `mfrm_bias_interaction` -\> [plot(x, type =
  "bias")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)

- `mfrm_bias_count` -\> bias-count plots (cell counts / low-count rates)

- `mfrm_fixed_reports` -\> pairwise-contrast diagnostics

- `mfrm_visual_summaries` -\> warning/summary message count plots

- `mfrm_category_structure` -\> category count and boundary plots

- `mfrm_category_curves` -\> overview (default), ogive, CCC / category
  probability / conditional probability, cumulative, total-information,
  and category-specific-information plots

- `mfrm_rating_scale` -\> category-counts/threshold plots

- `mfrm_measurable` -\> measurable-data coverage/count plots

- `mfrm_unexpected_after_bias` -\> post-bias unexpected-response plots

- `mfrm_output_bundle` -\> graph/score output-file diagnostics,
  including `type = "score_se"` when scorefile SE columns are available

- `mfrm_residual_pca` -\> residual PCA scree, parallel-analysis, or
  loadings views via [plot(x, type =
  "residual_pca")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)

- `mfrm_specifications` -\> facet/anchor/convergence plots

- `mfrm_data_quality` -\> dashboard, quality-flag, score-map,
  facet-pattern, and row/category/missing-row plots

- `mfrm_facets_fit_review` -\> FACETS-style df-sensitivity plot

- `mfrm_fit_measures` -\> fit-status counts, Infit/Outfit scatter,
  measure normal bands, and FACETS-style df-sensitivity plots. For
  `type = "measure_ci"`, the caption retains the source interval
  interpretation (including exploratory JML bands); fixed values use
  open diamonds and finite estimates without intervals use crosses.
  `main = ""` omits the title and `show_notes = FALSE` hides the caption
  without removing it from saved data. Changing `ci_level` does not
  change inferential eligibility. See
  [`fit_measures_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_measures_table.md).

- `mfrm_iteration_report` -\> replayed-iteration trajectories

- `mfrm_subset_connectivity` -\> subset-observation/connectivity plots

- `mfrm_facet_statistics` -\> facet statistic profile plots

- `mfrm_export_bundle` / `mfrm_summary_appendix_export` -\> export
  handoff plots (`formats`, `artifact_groups`, `selection_tables`,
  `selection_handoff`, `selection_handoff_bundles`,
  `selection_handoff_roles`, `selection_handoff_role_sections`,
  `selection_bundles`, `selection_roles`, `selection_sections`)

If a class is outside these families, use dedicated plotting helpers or
custom `ggplot2` graphics on component tables.

For `mfrm_category_curves`, pass `preset = "monochrome"` for
grayscale/line-type output. Cumulative `.5` boundary lines are shown
only for interpretable in-range boundaries by default; use
`boundary_status = "all"` to show every finite boundary estimate or
`boundary_status = "none"` / `show_cumulative_boundaries = FALSE` to
suppress those vertical boundary lines. Use
`plot_data(x, component = "plot_long")` on a category-curve bundle when
you want one ggplot2/plotly-friendly table across all curve families.
Keep curve families and groups separate in custom figures. All
category-curve, category-structure, rating-scale, and network bundle
views render natively via `ggplot2`. Step displays use point estimates
and do not turn stored step SEs into crossing, gap or curve intervals.

## Interpreting output

The returned object is a `ggplot` object whose underlying plot payload
and notes remain accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
and
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data_components.md);
set `draw = TRUE` for immediate display.

## Typical workflow

1.  Create bundle output (e.g.,
    [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/unexpected_response_table.md)).

2.  Inspect routing with `summary(bundle)` if needed.

3.  Call `p <- plot(bundle, type = ..., draw = FALSE)` and inspect
    `plot_data(p)` when needed.

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## Network display controls

For subset, design, rater and halo bundles with `type = "network"`, use
`layout` (a two-column coordinate matrix, optionally row-named by all
node IDs, or a function of the displayed igraph), `display_min_weight`
(absolute edge weight for the picture only), and `graphical` (a named
list of plot.igraph arguments, such as vertex.size, vertex.label,
vertex.color, edge.curved). Unnamed vectors and coordinates follow the
returned `nodes` order. All nodes, including isolates, remain. Edge
vectors in `graphical` follow the displayed `edges` order, after any
display filter. The default is a deterministic circle; positions do not
estimate anything. Labels are hidden by default above 80 nodes; set
vertex.label explicitly to override. Supply the same named layout to
compare views. Constructor filters such as `min_weight` change
calculated metrics; `display_min_weight` does not. Returned
`source_edges` retain the calculated graph, `edges` the displayed graph,
and `coordinates` the actual positions. Titles are metadata by default;
add a title explicitly via `graphical`. See [online networks and
reporting
guide](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-networks-and-reporting.html)
for bipartite assignment, directional disagreement and
rater-by-criterion examples inspired by Lamprianou. With
[`rater_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/rater_network_analysis.md)
and `weight_metric = "DirectionalMagnitude"`,
`type = "fit", metric = "SWS"` (or `"PUS"`) shows the published network
inconsistency index. The returned table retains unavailable
rows/statuses; there are no calibrated reference cutoffs. An entirely
unavailable index draws an unavailable message and retains the original
rows/statuses in the returned table, rather than substituting zero. For
signed alpha, `type = "matrix"` returns all eligible signed pair
coefficients before graph filtering, retaining zero and undefined values
separately. Network drawings use magnitude for edge width and dashed
lines for negative agreement. Use
[`plot.mfrm_network_ergm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_rater_network.md)
for ERGM coefficient intervals and simulated GOF.

## See also

[`summary()`](https://rdrr.io/r/base/summary.html), [plot(x, type =
"unexpected")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[plot(x, type =
"fair_average")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[plot(x, type =
"displacement")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("plot.mfrm_bundle", run.dontrun = TRUE)
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
