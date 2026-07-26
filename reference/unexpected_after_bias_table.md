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

- `gpcm_boundary`: bounded-`GPCM` interpretation guidance when
  applicable

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

Lower after-adjustment counts describe an in-sample change in flags;
they do not show that bias has been removed or establish fairness. For
bounded `GPCM`, both the bias estimate and the post-adjustment
comparison use the fitted slope-aware probability kernel while holding
the other fitted quantities fixed. Read the returned `gpcm_boundary`
before reporting the comparison.

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
# \donttest{
toy <- load_mfrmr_data("example_bias")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
diag <- diagnose_mfrm(fit, residual_pca = "none")
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 2)
t10 <- unexpected_after_bias_table(fit, bias, diagnostics = diag, top_n = 20)
summary(t10)
#> mfrmr Unexpected-after-Bias Summary 
#>   Class: mfrm_unexpected_after_bias
#>   Components: 5
#> 
#> After-bias threshold summary
#>  TotalObservations UnexpectedN UnexpectedPercent LowProbabilityN LargeResidualN
#>                384          20             5.208              20              9
#>    Rule AbsZThreshold ProbThreshold BaselineUnexpectedN AfterBiasUnexpectedN
#>  either             2           0.3                  88                   20
#>  ReducedBy ReducedPercent
#>         68         77.273
#> 
#> After-bias flagged rows: table
#>  Row Rater    Criterion Weight Score Observed Expected Residual StdResidual
#>  343   R01     Accuracy      1     1        1    3.194   -2.194      -3.155
#>  136   R04     Accuracy      1     3        3    1.451    1.549       2.627
#>  279   R02     Accuracy      1     2        2    3.505   -1.505      -2.502
#>  254   R03     Language      1     4        4    2.215    1.785       2.343
#>   31   R02     Accuracy      1     3        3    1.493    1.507       2.476
#>  131   R02 Organization      1     1        1    2.717   -1.717      -2.262
#>  110   R03     Language      1     2        2    3.394   -1.394      -2.171
#>  135   R02     Accuracy      1     4        4    2.471    1.529       1.990
#>  269   R02     Language      1     1        1    2.498   -1.498      -1.950
#>  215   R01     Accuracy      1     2        2    3.361   -1.361      -2.086
#>  ObsProb MostLikely MostLikelyProb CategoryGap Surprise            Direction
#>    0.008          3          0.504           2    2.077  Lower than expected
#>    0.046          1          0.597           2    1.333 Higher than expected
#>    0.051          4          0.559           2    1.290  Lower than expected
#>    0.037          2          0.486           2    1.428 Higher than expected
#>    0.056          1          0.565           2    1.255 Higher than expected
#>    0.048          3          0.487           2    1.319  Lower than expected
#>    0.078          4          0.478           2    1.110  Lower than expected
#>    0.077          2          0.418           2    1.114 Higher than expected
#>    0.088          3          0.421           2    1.057  Lower than expected
#>    0.087          3          0.455           1    1.062  Lower than expected
#>  FlagLowProbability FlagLargeResidual Severity BiasAdjustment
#>                TRUE              TRUE    6.231          0.777
#>                TRUE              TRUE    4.960         -1.102
#>                TRUE              TRUE    4.792          0.247
#>                TRUE              TRUE    4.771          0.155
#>                TRUE              TRUE    4.731          0.247
#>                TRUE              TRUE    4.581         -0.022
#>                TRUE              TRUE    4.281          0.155
#>                TRUE             FALSE    4.104          0.247
#>                TRUE             FALSE    4.008         -0.208
#>                TRUE              TRUE    3.648          0.777
#> 
#> Settings
#>    Setting  Value
#>  abs_z_min      2
#>   prob_max    0.3
#>       rule either
#> 
#> Notes
#>  - Unexpected-response summary after interaction adjustment.
#>  - Bias interaction: Rater x Criterion x c("Rater", "Criterion") x 2 x pairwise
#>  - Person identifiers are suppressed in this summary. Use `include_person =
#>    TRUE` only under appropriate privacy controls.
p_t10 <- plot(t10, draw = FALSE)
p_t10$data$plot
#> [1] "scatter"
# }
```
