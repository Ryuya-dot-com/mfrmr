# Plot RSM/PCM threshold ladders with disorder highlighting

Renders the Rasch-Andrich threshold structure as a vertical ladder per
step-facet level. Each tick is a `tau_k`; lines connecting adjacent
thresholds are coloured to make disordered crossings
(`tau_{k+1} < tau_k`) visually obvious. For RSM there is one ladder; for
PCM (and GPCM) there is one ladder per `step_facet` level.

## Usage

``` r
plot_threshold_ladder(
  fit,
  highlight_disorder = TRUE,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE
)
```

## Arguments

- fit:

  An `mfrm_fit` from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- highlight_disorder:

  Logical. When `TRUE` (default), draw disordered segments with the
  preset's `fail` colour and add a subtitle counting the disordered
  groups.

- preset:

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

- draw:

  If `TRUE`, draw with base graphics.

## Value

An `mfrm_plot_data` object with a `data` slot containing columns
`Group`, `Step`, `Threshold`, `Disordered` for each ladder row.

## Interpreting output

Within each ladder, thresholds should ascend monotonically. A disordered
crossing (highlighted in the fail colour) suggests that the
corresponding category is rarely the most likely response over any logit
interval, and is a common trigger for category-collapsing decisions.

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

[`category_structure_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_structure_report.md),
[`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md),
[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
(`type = "ccc"`).

## Examples

``` r
toy <- load_mfrmr_data("example_operational")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML", quad_points = 7, maxit = 30)
p <- plot_threshold_ladder(fit, draw = FALSE)
head(p$data$data)
#>    Group  Step Threshold Disordered
#> 1 Common tau_1 -1.206865      FALSE
#> 2 Common tau_2  0.166140      FALSE
#> 3 Common tau_3  1.040725      FALSE
```
