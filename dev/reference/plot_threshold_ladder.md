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
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- highlight_disorder:

  Logical. When `TRUE` (default), draw disordered segments with the
  preset's `fail` colour. The number of affected groups is returned in
  the notes, outside the figure.

- preset:

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

- draw:

  If `TRUE`, print the plot. Otherwise return it without drawing.

## Value

A `ggplot` object. Use `plot_data(p, "data")` to access the `Group`,
`Step`, `StepOwner`, `StepIndex`, `Threshold`, and `Disordered` columns
for each ladder row.

## Interpreting output

Each ladder shows centered step offsets for one step-owner level,
including when GPCM slopes belong to a different facet. Slopes do not
duplicate the threshold families. Disorder describes point estimates;
inspect owner-level counts, curves and the rubric before considering
category changes. Missing steps remain unavailable and are not bridged
by connecting lines. No intervals or full ability-axis crossings are
calculated. Save the result of
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) to retain its
model context and interpretation notes. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
for custom graphics or
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md)
to redraw a saved plot payload. The saved
[`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/rating_scale_table.md)
threshold view is also available as a separate plot route.

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

[`category_structure_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/category_structure_report.md),
[`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/category_curves_report.md),
[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)
(`type = "ccc"`).

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot_threshold_ladder", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_operational")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML", quad_points = 7, maxit = 30)
p <- plot(fit, type = "thresholds", draw = FALSE)
head(plot_data(p, "data"))
} # }
```
