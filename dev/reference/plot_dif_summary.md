# Summary plot of differential functioning effect sizes

Compact effect-size summary for a
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_dff.md)
result. Shows each contrast's signed effect size as a horizontal bar
with a vertical reference at zero and a neutral colour. Residual
comparisons do not provide differential-functioning tests or
classifications.

## Usage

``` r
plot_dif_summary(
  x,
  top_n = 30L,
  sort_by = c("abs_effect", "effect", "classification"),
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE,
  ci_level = NULL,
  effect_thresholds = NULL,
  effect_axis_label = NULL
)
```

## Arguments

- x:

  Output from
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_dff.md).

- top_n:

  Maximum rows shown (default `30`).

- sort_by:

  `"abs_effect"` (default), `"effect"`, or `"classification"`.

- preset:

  Visual preset.

- draw:

  If `TRUE`, print the `ggplot` object.

- ci_level:

  Optional confidence level for approximate normal intervals drawn from
  `Effect +/- z * SE` when finite standard errors are available for
  linked refits. Residual comparisons require `NULL` (default) because
  their interval uncertainty is not established.

- effect_thresholds:

  Optional numeric vector of absolute effect-size guide lines to draw at
  `+/- threshold`. These are display aids, not ETS classification
  boundaries.

- effect_axis_label:

  Optional x-axis label override. When `NULL`, the label is chosen from
  the DFF method.

## Value

Invisibly, a `ggplot` object. The `plot_data(p, "data")` table contains
columns `Pair`, `Effect`, `SE`, `Classification`, `Color`.

## Interpreting output

Bars are anchored at zero. Width corresponds to effect size on the
contrast's native scale. For `method = "residual"`, this is the
observed-minus-expected average difference between groups, in score
units. For `method = "refit"`, this is the subgroup parameter difference
on the fitted logit scale when linking support allows a comparable
contrast. Residual differences do not isolate differential functioning.
Linked refit intervals omit estimated-anchor uncertainty and cross-refit
covariance.

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## Migration in 0.2.4

This renderer is internal. Use the corresponding
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) route in
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_plot_migration.md);
the former exported name is no longer available.

## See also

[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_dff.md),
[plot(x, type =
"heatmap")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_dif.md).
