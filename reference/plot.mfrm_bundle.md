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

- `mfrm_unexpected` -\> [plot(x, type =
  "unexpected")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

- `mfrm_fair_average` -\> [plot(x, type =
  "fair_average")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

- `mfrm_displacement` -\> [plot(x, type =
  "displacement")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

- `mfrm_interrater` -\> [plot(x, type =
  "agreement")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

- `mfrm_facets_chisq` -\> [plot(x, type =
  "facets_chisq")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

- `mfrm_bias_interaction` -\> [plot(x, type =
  "bias")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

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
  loadings views via [plot(x, type =
  "residual_pca")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

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
  [`fit_measures_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_measures_table.md).

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
Keep curve families and groups separate in custom figures. Automatic
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
conversion supports rating-scale counts/thresholds and
category-structure counts; it is unavailable for category-curve bundles
and category-structure boundary views. Step displays use point estimates
and do not turn stored step SEs into crossing, gap or curve intervals.

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
add a title explicitly via `graphical`. See
[`vignette("mfrmr-networks-and-reporting")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-networks-and-reporting.md)
for bipartite assignment, directional disagreement and
rater-by-criterion examples inspired by Lamprianou. With
[`rater_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_network_analysis.md)
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
[`plot.mfrm_network_ergm()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_network_ergm.md)
for ERGM coefficient intervals and simulated GOF.

## Session plot defaults

Set `options(mfrmr.plot_preset = "publication")` to choose a session
default for plotting functions that expose the common `preset` argument.
The supported values are `"standard"`, `"publication"`, `"compact"` and
`"monochrome"`. Precedence is an explicit call argument, then the
session option, then `"standard"`. For example, `preset = "standard"`
overrides a session set to `"monochrome"`. Explicit `preset = NULL`
retains the earlier package-default behavior; it does not read the
session option. Invalid session values cause an error only when that
option is needed.

The category-curve, data-quality, fit-review, connectivity and network
routes of [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for
report bundles use the same option through `...`. Plots without a common
`preset` argument, including extended-model plots with their own
`palette` controls, keep their own settings. This option selects a
preset, not a universal theme or a guarantee that all renderers
implement every appearance control identically.

New plot payloads retain the resolved preset for supported saved-data
rendering. Converting an existing payload with
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
uses its saved appearance, even after the session option changes. A call
that creates a new plot from a fit or statistical result uses the
current default. For a reproducible script, supply `preset` explicitly
or set the option in that script. Saving only the fitted model does not
save a session option. No global ggplot theme is changed.

Restore previous settings with
`old <- options(mfrmr.plot_preset = "monochrome")` followed by
`options(old)`. Use `options(mfrmr.plot_preset = NULL)` to remove the
option. The preset changes appearance, not estimates, confidence levels
or diagnostic thresholds.

## See also

[`summary()`](https://rdrr.io/r/base/summary.html), [plot(x, type =
"unexpected")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[plot(x, type =
"fair_average")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[plot(x, type =
"displacement")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

## Examples

``` r
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
```
