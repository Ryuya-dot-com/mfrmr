# Plot fair-average diagnostics using base R

Plot fair-average diagnostics using base R

## Usage

``` r
plot_fair_average(
  x,
  diagnostics = NULL,
  facet = NULL,
  metric = c("AdjustedAverage", "StandardizedAdjustedAverage", "FairM", "FairZ"),
  plot_type = c("difference", "scatter"),
  top_n = 40,
  show_ci = FALSE,
  ci_level = 0.95,
  draw = TRUE,
  preset = c("standard", "publication", "compact", "monochrome"),
  ...
)
```

## Arguments

- x:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  or
  [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  when `x` is `mfrm_fit`.

- facet:

  Optional facet name for level-wise lollipop plots.

- metric:

  Adjusted-score metric. Accepts legacy names (`"FairM"`, `"FairZ"`) and
  package-native names (`"AdjustedAverage"`,
  `"StandardizedAdjustedAverage"`).

- plot_type:

  `"difference"` or `"scatter"`.

- top_n:

  Maximum levels shown for `"difference"` plot.

- show_ci:

  Logical. When `TRUE`, draw approximate confidence-interval whiskers on
  the fair metric using a delta-method propagation from the logit
  `Measure` standard error to the observed-score scale. The derivative
  equals the implied score variance `Var(X | Measure)`, so the
  fair-scale standard error is `Var(X) * ModelSE`. CI bounds are clipped
  to the rating range. Rows where the score variance is effectively zero
  (levels whose measure sits near the rating boundary, so the
  delta-method approximation becomes uninformative) are drawn with an
  open circle and excluded from the whiskers; the excluded count is
  reported in the subtitle. For bounded `GPCM` fits, this option
  requests `fair_average_table(fair_se = TRUE)` when `x` is a fit object
  and uses the structural delta-method fair-average CI columns when they
  are available. If `x` is a precomputed fair-average bundle without
  those columns, the plot records an unavailable-CI note.

- ci_level:

  Confidence level used when `show_ci = TRUE`; default `0.95`. The
  returned plot-data object gains `CI_Lower`, `CI_Upper`, and `CI_Level`
  columns for downstream reuse.

- draw:

  If `TRUE`, draw with base graphics.

- preset:

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

- ...:

  Additional arguments passed to
  [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
  when `x` is `mfrm_fit`.

## Value

A plotting-data object of class `mfrm_plot_data`. With `draw = FALSE`,
the returned plot data includes `title`, `subtitle`, `legend`,
`reference_lines`, and the stacked fair-average data.

## Details

Fair-average plots compare observed scoring tendency against model-based
fair metrics.

**FairM** is the model-predicted mean score for each element, adjusting
for the ability distribution of persons actually encountered. It
answers: "What average score would this rater/criterion produce if all
raters/criteria saw the same mix of persons?"

**FairZ** standardises FairM to a z-score across elements within each
facet, making it easier to compare relative severity across facets with
different raw-score scales.

Use FairM when the raw-score metric is meaningful (e.g., reporting
average ratings on the original 1–4 scale). Use FairZ when comparing
standardised severity ranks across facets.

## Plot types

- `"difference"` (default):

  Lollipop chart showing the gap between observed and fair-average score
  for each element. X-axis: Observed - Fair metric. Y-axis: element
  labels. Points colored teal (lenient, gap \>= 0) or orange (severe,
  gap \< 0). Ordered by absolute gap.

- `"scatter"`:

  Scatter plot of fair metric (x) vs observed average (y) with an
  identity line. Points colored by facet. Useful for checking overall
  alignment between observed and model-adjusted scores.

## Interpreting output

Difference plot: ranked element-level gaps (`Observed - Fair`), useful
for triage of potentially lenient/severe levels.

Scatter plot: global agreement pattern relative to the identity line.

Larger absolute gaps suggest stronger divergence between observed and
model-adjusted scoring.

## Typical workflow

1.  Start with `plot_type = "difference"` to find largest discrepancies.

2.  Use `plot_type = "scatter"` to check overall alignment pattern.

3.  Follow up with facet-level diagnostics for flagged levels.

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).

## See also

[`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md),
[`plot_unexpected()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_unexpected.md),
[`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md),
[`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
if (FALSE) { # interactive()
toy_full <- load_mfrmr_data("example_core")
toy_people <- unique(toy_full$Person)[1:12]
toy <- toy_full[toy_full$Person %in% toy_people, , drop = FALSE]
fit <- suppressWarnings(
  fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
)
p <- plot_fair_average(fit, metric = "AdjustedAverage", draw = FALSE)
if (interactive()) {
  plot_fair_average(fit, metric = "AdjustedAverage", plot_type = "difference")
}
}
```
