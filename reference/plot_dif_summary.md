# Summary plot of differential functioning effect sizes

Compact effect-size summary for a
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
/
[`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
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
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  or
  [`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md).

- top_n:

  Maximum rows shown (default `30`).

- sort_by:

  `"abs_effect"` (default), `"effect"`, or `"classification"`.

- preset:

  Visual preset.

- draw:

  If `TRUE`, draw with base graphics.

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

An `mfrm_plot_data` object whose `data` slot contains columns `Pair`,
`Effect`, `SE`, `Classification`, `Color`.

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

[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md).

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_bias")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 300)
diag <- diagnose_mfrm(fit, residual_pca = "none")
dff <- analyze_dff(fit, diagnostics = diag,
                   facet = "Rater", group = "Group", data = toy)
unique(dff$dif_table$ClassificationSystem)
#> [1] "descriptive"
p <- plot_dif_summary(dff, draw = FALSE)
head(p$data$data)
#>          Pair      Effect SE CI_Lower CI_Upper    Classification
#> 1 R01 | A | B  0.16845853 NA       NA       NA Residual contrast
#> 2 R02 | A | B -0.13221860 NA       NA       NA Residual contrast
#> 3 R03 | A | B -0.11261117 NA       NA       NA Residual contrast
#> 4 R04 | A | B  0.07637118 NA       NA       NA Residual contrast
#>   ClassificationSystem   Color
#> 1          descriptive #6b7280
#> 2          descriptive #6b7280
#> 3          descriptive #6b7280
#> 4          descriptive #6b7280
# }
```
