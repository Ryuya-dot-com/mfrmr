# Plot inter-rater agreement diagnostics using base R

Plot inter-rater agreement diagnostics using base R

## Usage

``` r
plot_interrater_agreement(
  x,
  diagnostics = NULL,
  rater_facet = NULL,
  context_facets = NULL,
  exact_warn = 0.5,
  corr_warn = 0.3,
  plot_type = c("exact", "corr", "difference"),
  top_n = 20,
  main = NULL,
  palette = NULL,
  label_angle = 45,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE
)
```

## Arguments

- x:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  or
  [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  when `x` is `mfrm_fit`.

- rater_facet:

  Name of the rater facet when `x` is `mfrm_fit`.

- context_facets:

  Optional context facets when `x` is `mfrm_fit`.

- exact_warn:

  Warning threshold for exact agreement.

- corr_warn:

  Warning threshold for pairwise correlation.

- plot_type:

  `"exact"`, `"corr"`, or `"difference"`.

- top_n:

  Maximum pairs displayed for bar-style plots.

- main:

  Optional custom plot title.

- palette:

  Optional named color overrides (`ok`, `flag`, `expected`).

- label_angle:

  X-axis label angle for bar-style plots.

- preset:

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

- draw:

  If `TRUE`, draw with base graphics.

## Value

A plotting-data object of class `mfrm_plot_data`.

## Details

Inter-rater agreement plots summarize pairwise consistency for a chosen
rater facet. Agreement statistics are computed over observations that
share the same person and context-facet levels, ensuring that
comparisons reflect identical rating targets.

**Exact agreement** is the proportion of matched observations where both
raters assigned the same category score. The **expected agreement** line
shows the proportion expected by chance given each rater's marginal
category distribution, providing a baseline.

**Pairwise correlation** is the Pearson correlation between scores
assigned by each rater pair on matched observations.

The **difference plot** decomposes disagreement into systematic bias
(mean signed difference on x-axis: positive = Rater 1 more severe) and
total inconsistency (mean absolute difference on y-axis). Points near
the origin indicate both low bias and low inconsistency.

The `context_facets` parameter specifies which facets define "the same
rating target" (e.g., Criterion). When `NULL`, all non-rater facets are
used as context.

## Plot types

- `"exact"` (default):

  Bar chart of exact agreement proportion by rater pair. Expected
  agreement overlaid as connected circles. Horizontal reference line at
  `exact_warn`. Bars colored red when observed agreement falls below the
  warning threshold.

- `"corr"`:

  Bar chart of pairwise Pearson correlation by rater pair. Reference
  line at `corr_warn`. Ordered by correlation (lowest first). Low
  correlations suggest inconsistent rank ordering of persons between
  raters.

- `"difference"`:

  Scatter plot. X-axis: mean signed score difference (Rater 1 \\-\\
  Rater 2); positive values indicate Rater 1 is more severe. Y-axis:
  mean absolute difference (overall disagreement magnitude). Points
  colored red when flagged. Vertical reference at 0.

## Interpreting output

Pairs below `exact_warn` and/or `corr_warn` should be prioritized for
rater calibration review. On the difference plot, points far from the
origin along the x-axis indicate systematic bias; points high on the
y-axis indicate large inconsistency regardless of direction.

## Typical workflow

1.  Select rater facet and run `"exact"` view.

2.  Confirm with `"corr"` view.

3.  Use `"difference"` to inspect directional disagreement.

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).

## See also

[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md),
[`plot_facets_chisq()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facets_chisq.md),
[`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
p <- plot_interrater_agreement(fit, rater_facet = "Rater", draw = FALSE)
if (interactive()) {
  plot_interrater_agreement(
    fit,
    rater_facet = "Rater",
    draw = TRUE,
    plot_type = "exact",
    main = "Inter-rater Agreement (Customized)",
    palette = c(ok = "#2b8cbe", flag = "#cb181d"),
    label_angle = 45,
    preset = "publication"
  )
}
} # }
```
