# Build an unexpected-after-adjustment screening report

Build an unexpected-after-adjustment screening report

## Usage

``` r
unexpected_after_bias_table(
  fit,
  bias_results,
  diagnostics = NULL,
  abs_z_min = 2,
  prob_max = 0.3,
  top_n = 100,
  rule = c("either", "both")
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- bias_results:

  Output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  for baseline comparison.

- abs_z_min:

  Absolute standardized-residual cutoff.

- prob_max:

  Maximum observed-category probability cutoff.

- top_n:

  Maximum number of rows to return.

- rule:

  Flagging rule: `"either"` or `"both"`.

## Value

A named list with:

- `table`: unexpected responses after bias adjustment

- `summary`: one-row summary (includes baseline-vs-after counts)

- `thresholds`: applied thresholds

- `facets`: analyzed bias facet pair

## Details

This helper recomputes expected values and residuals after interaction
adjustments from
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
have been introduced.

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

Large reductions indicate bias terms explain part of prior
unexpectedness; persistent unexpected rows indicate remaining model-data
mismatch.

## Typical workflow

1.  Run
    [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md)
    as baseline.

2.  Estimate bias via
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

3.  Run `unexpected_after_bias_table(...)` and compare reductions.

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).

## Output columns

The `table` data.frame has the same structure as
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md)
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

## See also

[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
[`bias_count_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_count_table.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_bias")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 2)
t10 <- unexpected_after_bias_table(fit, bias, diagnostics = diag, top_n = 20)
summary(t10)
p_t10 <- plot(t10, draw = FALSE)
p_t10$data$plot
}
```
