# Build an unexpected-after-adjustment screening report

Build an unexpected-after-adjustment screening report

## Usage

``` r
unexpected_after_bias_table(
  fit,
  bias_results,
  diagnostics = NULL,
  abs_z_min = 3,
  prob_max = 0.3,
  top_n = 100,
  rule = c("residual", "either", "both")
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- bias_results:

  Output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
  for baseline comparison.

- abs_z_min:

  Absolute standardized-residual cutoff.

- prob_max:

  Maximum observed-category probability cutoff.

- top_n:

  Maximum number of ranked rows to return in `table`. Summary counts,
  percentages, and before/after comparisons use all flagged
  observations, regardless of this display limit.

- rule:

  `"residual"` (default), `"either"`, or `"both"`; see
  [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/unexpected_response_table.md)
  for the same baseline/after-bias rule.

## Value

A named list with:

- `table`: unexpected responses after bias adjustment

- `summary`: one-row summary (includes baseline-vs-after counts)

- `thresholds`: applied thresholds

- `facets`: analyzed bias facet pair

- `gpcm_boundary`: `GPCM` interpretation guidance when applicable

## Details

This helper recomputes expected values and residuals after interaction
adjustments from
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md)
have been introduced. Screening coverage is retained separately before
and after adjustment. Reduction counts, percentages and the comparison
plot are unavailable if either screen leaves responses unclassified.
Recreate older saved results with the original settings; the MFRM fit
does not need re-estimation.

`summary(t10)` is supported through
[`summary()`](https://rdrr.io/r/base/summary.html). `plot(t10)` is
dispatched through
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) for class
`mfrm_unexpected_after_bias` (`type = "scatter"`, `"severity"`,
`"comparison"`).

## Interpreting output

- `summary`: before/after unexpected counts and reduction metrics.

- `table`: residual unexpected responses after bias adjustment.

- `thresholds`: screening settings used in this comparison.

Lower after-adjustment counts describe an in-sample change in flags;
they do not show that bias has been removed or establish fairness. For
`GPCM`, both the bias estimate and the post-adjustment comparison use
the fitted slope-aware probability kernel while holding the other fitted
quantities fixed. Read the returned `gpcm_boundary` before reporting the
comparison.

## Typical workflow

1.  Run
    [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/unexpected_response_table.md)
    as baseline.

2.  Estimate bias via
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md).

3.  Run `unexpected_after_bias_table(...)` and compare reductions.

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-visual-diagnostics.md).

## Output columns

The `table` data.frame has the same structure as
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/unexpected_response_table.md)
output, with an additional `BiasAdjustment` column showing the bias
correction applied to each observation's expected value.

The `summary` data.frame contains:

- TotalObservations:

  Total observations analyzed.

- BaselineUnexpectedN:

  Unexpected count before bias adjustment.

- AfterBiasUnexpectedN:

  Unexpected count after adjustment.

- ReducedBy, ReducedPercent:

  Reduction in unexpected count.

## Saved-result reuse

The returned `fit_identity` records the fitted analysis for reuse with
reports and exports. Recreate older results from the saved fit and
matching diagnostics using the original screening options; no model
refit is needed. See
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_compatibility_layer.md)
for migration instructions.

## See also

[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md),
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/unexpected_response_table.md),
[`bias_count_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/bias_count_table.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("unexpected_after_bias_table", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_bias.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "bias-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diag <- example_fit$diagnostics
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 2)
t10 <- unexpected_after_bias_table(fit, bias, diagnostics = diag, top_n = 20)
summary(t10)
p_t10 <- plot(t10, draw = FALSE)
p_t10$data$plot
} # }
```
