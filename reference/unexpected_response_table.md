# Build an unexpected-response screening report

Build an unexpected-response screening report

## Usage

``` r
unexpected_response_table(
  fit,
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

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- abs_z_min:

  Absolute standardized-residual cutoff.

- prob_max:

  Maximum observed-category probability cutoff.

- top_n:

  Maximum number of rows to return.

- rule:

  Flagging rule: `"either"` (default) or `"both"`.

## Value

A named list with:

- `table`: flagged response rows

- `summary`: one-row overview

- `thresholds`: applied thresholds

## Details

A response is flagged as unexpected when:

- `rule = "either"`: `|StdResidual| >= abs_z_min` OR
  `ObsProb <= prob_max`

- `rule = "both"`: both conditions must be met.

The table includes row-level observed/expected values, residuals,
observed-category probability, most-likely category, and a composite
severity score for sorting.

## Interpreting output

- `summary`: prevalence of unexpected responses under current
  thresholds.

- `table`: ranked row-level diagnostics for case review.

- `thresholds`: active cutoffs and flagging rule.

Compare results across `rule = "either"` and `rule = "both"` to assess
how conservative your screening should be.

## Typical workflow

1.  Start with `rule = "either"` for broad screening.

2.  Re-run with `rule = "both"` for strict subset.

3.  Inspect top rows and visualize with
    [`plot_unexpected()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_unexpected.md).

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).

## Output columns

The `table` data.frame contains:

- Row:

  Original row index in the prepared data.

- Person:

  Person identifier (plus one column per facet).

- Score:

  Observed score category.

- Observed, Expected:

  Observed and model-expected score values.

- Residual, StdResidual:

  Raw and standardized residuals.

- ObsProb:

  Probability of the observed category under the model.

- MostLikely, MostLikelyProb:

  Most probable category and its probability.

- Severity:

  Composite severity index (higher = more unexpected).

- Direction:

  "Higher than expected" or "Lower than expected".

- FlagLowProbability, FlagLargeResidual:

  Logical flags for each criterion.

The `summary` data.frame contains:

- TotalObservations:

  Total observations analyzed.

- UnexpectedN, UnexpectedPercent:

  Count and share of flagged rows.

- AbsZThreshold, ProbThreshold:

  Applied cutoff values.

- Rule:

  "either" or "both".

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md),
[`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# \donttest{
toy_full <- load_mfrmr_data("example_core")
toy_people <- unique(toy_full$Person)[1:12]
toy <- toy_full[toy_full$Person %in% toy_people, , drop = FALSE]
fit <- suppressWarnings(
  fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
)
t4 <- unexpected_response_table(fit, abs_z_min = 1.5, prob_max = 0.4, top_n = 5)
summary(t4)
#> mfrmr Unexpected Response Summary 
#>   Class: mfrm_unexpected
#>   Components: 3
#> 
#> Threshold summary
#>  TotalObservations UnexpectedN UnexpectedPercent LowProbabilityN LargeResidualN
#>                192           5             2.604               5              5
#>    Rule AbsZThreshold ProbThreshold
#>  either           1.5           0.4
#> 
#> Flagged responses: table
#>  Row Rater    Criterion Weight Score Observed Expected Residual StdResidual
#>  160   R02     Accuracy      1     1        1    3.071   -2.071      -2.816
#>  130   R03     Language      1     1        1    2.966   -1.966      -2.602
#>   55   R01 Organization      1     1        1    2.937   -1.937      -2.548
#>   48   R04      Content      1     1        1    2.697   -1.697      -2.142
#>  181   R04     Accuracy      1     1        1    2.660   -1.660      -2.087
#>  ObsProb MostLikely MostLikelyProb CategoryGap Surprise           Direction
#>    0.020          3          0.513           2    1.704 Lower than expected
#>    0.029          3          0.515           2    1.538 Lower than expected
#>    0.032          3          0.514           2    1.496 Lower than expected
#>    0.066          3          0.478           2    1.181 Lower than expected
#>    0.073          3          0.469           2    1.139 Lower than expected
#>  FlagLowProbability FlagLargeResidual Severity
#>                TRUE              TRUE    5.519
#>                TRUE              TRUE    5.139
#>                TRUE              TRUE    5.045
#>                TRUE              TRUE    4.323
#>                TRUE              TRUE    4.226
#> 
#> Settings
#>    Setting  Value
#>  abs_z_min    1.5
#>   prob_max    0.4
#>       rule either
#> 
#> Notes
#>  - Unexpected-response summary for quick residual screening.
#>  - Person identifiers are suppressed in this summary. Use `include_person =
#>    TRUE` only under appropriate privacy controls.
p_t4 <- plot(t4, draw = FALSE)
p_t4$data$plot
#> [1] "scatter"
# }
```
