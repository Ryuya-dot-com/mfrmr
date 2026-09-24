# Plot QC pipeline results

Visualizes the output from
[`run_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_qc_pipeline.md)
as either a traffic-light bar chart or a detail panel showing values
versus thresholds.

## Usage

``` r
plot_qc_pipeline(x, type = c("traffic_light", "detail"), draw = TRUE, ...)
```

## Arguments

- x:

  Output from
  [`run_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_qc_pipeline.md).

- type:

  Plot type: `"traffic_light"` (default) or `"detail"`.

- draw:

  If `FALSE`, return plot data invisibly without drawing.

- ...:

  Additional graphical parameters passed to plotting functions.

## Value

Invisible verdicts tibble from the QC pipeline.

## Details

Two plot types are provided for visual triage of QC results:

- **`"traffic_light"`** (default): A horizontal bar chart with one row
  per QC check. Bars are coloured green (Pass), amber (Warn), or red
  (Fail). Provides an at-a-glance summary of the current QC review
  state.

- **`"detail"`**: A panel showing each check's observed value and its
  pass/warn/fail thresholds. Useful for understanding how close a
  borderline result is to the next verdict level.

## Interpretation

The rows are the actual checks returned by
[`run_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_qc_pipeline.md):
convergence, global fit, selected-facet reliability and separation,
element misfit, unexpected responses, category structure, connectivity,
inter-rater agreement, and the functioning/bias screen. Element misfit
uses the configured mean-square band; it is not a ZSTD test. PCA and
displacement are separate diagnostics and are not checks in this
pipeline.

Green (Pass), amber (Warn), and red (Fail) describe the selected
screening rules. Grey (Skip) marks unrequested or unavailable checks;
`AffectsOverall` in the returned data distinguishes their contribution
to the overall result. A missing result is not evidence of acceptable
fit. High rater separation is not high agreement, and no colour
establishes statistical validity or justifies deleting raters or
collapsing categories without further review.

## See also

[`run_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_qc_pipeline.md),
[`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md),
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("study1")
# These observed data trigger a category-support warning: the QC plot
# displays that review requirement; convergence does not remove it.
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 300)
#> Warning: Category support is retained but requires review: at least one fitted or local scope contains an empty or singleton category/transition cell. The fit may be inspected, but category-information strength has not been certified; inspect `fit$data_review$category_support` before inference.
qc <- run_qc_pipeline(fit)
plot_qc_pipeline(qc, draw = FALSE)
# }
```
