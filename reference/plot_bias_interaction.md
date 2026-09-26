# Plot bias interaction diagnostics (preferred alias)

Plot bias interaction diagnostics (preferred alias)

## Usage

``` r
plot_bias_interaction(
  x,
  plot = c("scatter", "ranked", "heatmap", "abs_t_hist", "facet_profile"),
  diagnostics = NULL,
  facet_a = NULL,
  facet_b = NULL,
  interaction_facets = NULL,
  top_n = 40,
  abs_t_warn = 2,
  abs_bias_warn = 0.5,
  p_max = 0.05,
  sort_by = c("abs_t", "abs_bias", "prob"),
  show_ci = FALSE,
  ci_level = 0.95,
  main = NULL,
  palette = NULL,
  label_angle = 45,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE,
  title = NULL
)
```

## Arguments

- x:

  Output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  or
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- plot:

  Plot type: `"scatter"`, `"ranked"`, `"heatmap"`, `"abs_t_hist"`, or
  `"facet_profile"`.

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  (used when `x` is fit).

- facet_a:

  First facet name (required when `x` is fit and `interaction_facets` is
  not supplied).

- facet_b:

  Second facet name (required when `x` is fit and `interaction_facets`
  is not supplied).

- interaction_facets:

  Character vector of two or more facets.

- top_n:

  Maximum number of ranked rows to keep.

- abs_t_warn:

  Warning cutoff for absolute t statistics.

- abs_bias_warn:

  Warning cutoff for absolute bias size.

- p_max:

  Warning cutoff for p-values.

- sort_by:

  Ranking key: `"abs_t"`, `"abs_bias"`, or `"prob"`.

- show_ci:

  Logical. When `TRUE` and `plot` is `"scatter"` or `"ranked"`, draw
  confidence-interval whiskers for `Bias Size`. `GPCM` rows use the
  conditional profile-likelihood limits returned by
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  when available; otherwise the interval uses the per-cell standard
  error from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).
  Ignored for `"heatmap"`, `"abs_t_hist"`, and `"facet_profile"`.

- ci_level:

  Confidence level used when `show_ci = TRUE`; default `0.95`. The
  returned plot-data object gains `CI_Lower` / `CI_Upper` / `CI_Level`
  columns on the `ranked_table` and `scatter_data` elements for
  downstream reuse.

- main:

  Compatibility title argument. Omitted or `NULL` keeps the default
  title. Existing calls remain supported without a deprecation warning.
  For new code, prefer `title`; do not supply both arguments.

- palette:

  Optional named color overrides (`normal`, `flag`, `hist`, `profile`).

- label_angle:

  Label angle hint for ranked/profile labels.

- preset:

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

- draw:

  If `TRUE`, draw with base graphics.

- title:

  Plot title. Omit it to keep the default, supply one character string
  to replace it, or use `NULL` (or `""`) to suppress it. This changes
  only the heading; numerical results, reference lines, subtitles and
  interpretation notes remain. Both `main` and `title` explicitly
  supplied is an error, even if equal or `NULL`. Positional legacy
  arguments retain their order; use the exact name `title`.

## Value

A plotting-data object of class `mfrm_plot_data`.

## Details

Visualization front-end for
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md)
with multiple views. With `draw = FALSE`, the returned plot data include
`plot_long`, `plot_annotations`, `flag_summary`, and `plot_settings` in
addition to the view-specific `ranked_table`, `scatter_data`,
`facet_profile`, and heatmap components. Use these fields when
rebuilding the same screening view in ggplot2, plotly, Quarto, or a
dashboard.

## Plot types

- `"scatter"` (default):

  Scatter plot of bias size (x) vs screening t-statistic (y). Points
  colored by flag status. Dashed reference lines at `abs_bias_warn` and
  `abs_t_warn`. Use for overall triage of interaction effects.

- `"ranked"`:

  Ranked bar chart of top `top_n` interactions sorted by `sort_by`
  criterion (absolute t, absolute bias, or probability). Bars colored
  red for flagged cells.

- `"heatmap"`:

  Facet A by facet B matrix of signed bias size. Cells retain reusable
  matrix and flag tables for dashboards. This is a Table 13 follow-up
  display: it supports pattern recognition but does not turn screening
  rows into confirmatory tests.

- `"abs_t_hist"`:

  Histogram of absolute screening t-statistics across all interaction
  cells. Dashed reference line at `abs_t_warn`. Use for assessing the
  overall distribution of interaction effect sizes.

- `"facet_profile"`:

  Per-facet-level aggregation showing mean absolute bias and flag rate.
  Useful for identifying which individual facet levels drive systematic
  interaction patterns.

## Interpreting output

Start with `"scatter"` or `"ranked"` for triage, then confirm pattern
shape using `"abs_t_hist"` and `"facet_profile"`.

Consistent flags across multiple views are stronger screening signals of
systematic interaction bias than a single extreme row, but they do not
by themselves establish formal inferential evidence.

## Typical workflow

1.  Estimate bias with
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
    or pass `mfrm_fit` directly.

2.  Plot with `plot = "ranked"` for top interactions.

3.  Cross-check using `plot = "scatter"` and `plot = "facet_profile"`.

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

[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_bias")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 300)
p <- plot_bias_interaction(
  fit,
  diagnostics = diagnose_mfrm(fit, residual_pca = "none"),
  facet_a = "Rater",
  facet_b = "Criterion",
  preset = "publication",
  draw = FALSE
)
# }
```
