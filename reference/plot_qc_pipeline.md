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

## QC checks performed

The pipeline evaluates up to 10 checks (depending on available
diagnostics):

1.  **Convergence**: did the optimizer converge?

2.  **Overall Infit**: global information-weighted mean-square

3.  **Overall Outfit**: global unweighted mean-square

4.  **Misfit rate**: proportion of elements with \\\|\mathrm{ZSTD}\| \>
    2\\

5.  **Category usage**: minimum observations per score category

6.  **Disordered steps**: whether threshold estimates are monotonic

7.  **Separation** (per facet): element discrimination adequacy

8.  **Residual PCA eigenvalue**: first-component eigenvalue (if
    computed)

9.  **Displacement**: maximum absolute displacement across elements

10. **Inter-rater agreement**: minimum pairwise exact agreement

## Interpreting plots

- **Green** (Pass): the check meets the current threshold-profile
  criteria.

- **Amber** (Warn): borderline—monitor but not necessarily
  disqualifying. Review the detail panel to see how close the value is
  to the fail threshold.

- **Red** (Fail): requires investigation before strong operational or
  interpretive claims are made from the current run. Common remedies
  include collapsing categories (for disordered steps), removing outlier
  raters (for misfit), or increasing sample size (for low separation).

- The detail view shows numeric values, making it easy to communicate
  exact results to stakeholders.

## See also

[`run_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_qc_pipeline.md),
[`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md),
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("study1")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
qc <- run_qc_pipeline(fit)
plot_qc_pipeline(qc, draw = FALSE)
} # }
```
