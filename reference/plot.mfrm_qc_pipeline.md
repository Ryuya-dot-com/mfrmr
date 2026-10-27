# Plot a saved QC pipeline

Display the checks already returned by
[`run_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_qc_pipeline.md).
Use the colored verdicts for triage, then read the returned detail for
the reason and next review.

## Usage

``` r
# S3 method for class 'mfrm_qc_pipeline'
plot(x, type = c("traffic_light", "detail"), draw = TRUE, ...)
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

  Additional base-graphics arguments for the selected view.

## Value

Invisible verdicts tibble from the QC pipeline.

## Details

Two plot types are provided for visual triage of QC results:

- **`"traffic_light"`** (default): A horizontal bar chart with one row
  per QC check. Bars are coloured green (Pass), amber (Warn), or red
  (Fail). Provides an at-a-glance summary of the current QC review
  state.

- **`"detail"`**: A panel showing the saved `Detail` text beside each
  verdict. Read this explanation and the returned table to understand
  why a check was flagged or unavailable.

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
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_plot_migration.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("plot.mfrm_qc_pipeline", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
ratings <- load_mfrmr_data("study1")
# These observed data trigger a category-support warning: the QC plot
# displays that review requirement; convergence does not remove it.
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 300)
qc <- run_qc_pipeline(fit)
verdicts <- plot(qc, draw = FALSE)
head(verdicts)
} # }
```
