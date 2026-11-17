# Build an unexpected-response screening report

Build an unexpected-response screening report

Build an unexpected-after-adjustment screening report

## Usage

``` r
unexpected_response_table(
  fit,
  diagnostics = NULL,
  abs_z_min = 3,
  prob_max = 0.3,
  top_n = 100,
  rule = c("residual", "either", "both")
)

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
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
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
  `unexpected_response_table()` for the same baseline/after-bias rule.

- bias_results:

  Output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

## Value

A named list with:

- `table`: flagged response rows

- `summary`: one-row overview

- `thresholds`: applied thresholds

A named list with:

- `table`: unexpected responses after bias adjustment

- `summary`: one-row summary (includes baseline-vs-after counts)

- `thresholds`: applied thresholds

- `facets`: analyzed bias facet pair

- `gpcm_boundary`: `GPCM` interpretation guidance when applicable

## Details

The default is the FACETS Table 4 absolute residual rule, with cutoff 3.
A response is flagged as unexpected when:

- `rule = "residual"`: `|StdResidual| >= abs_z_min`.

- `rule = "either"`: `|StdResidual| >= abs_z_min` OR
  `ObsProb <= prob_max`

- `rule = "both"`: both conditions must be met.

Missing inputs preserve an unavailable rule outcome unless the other
condition determines the result (for example, a true condition suffices
for `either`). Summaries retain evaluated and unavailable counts; the
full-sample percentage is withheld if any outcome is unavailable.

The table includes row-level observed/expected values, residuals,
observed-category probability, most-likely category, and a composite
severity score for sorting.

This helper recomputes expected values and residuals after interaction
adjustments from
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
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

- `summary`: prevalence of unexpected responses under current
  thresholds, before limiting the displayed rows with `top_n`.

- `table`: ranked row-level diagnostics for case review.

- `thresholds`: active cutoffs and flagging rule.

Compare results across `rule = "either"` and `rule = "both"` to assess
how conservative your screening should be.

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

1.  Start with the default residual screen. Category probability is an
    optional case-review aid, not a tail probability or calibrated
    false-alarm rate.

2.  Re-run with `rule = "both"` for strict subset.

3.  Inspect top rows and visualize with [plot(x, type =
    "unexpected")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md).

&nbsp;

1.  Run `unexpected_response_table()` as baseline.

2.  Estimate bias via
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

3.  Run `unexpected_after_bias_table(...)` and compare reductions.

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
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

  Most probable category and its probability. Tied modes give
  `MostLikely = NA`; `MostLikelyCount` records their number, and
  CategoryGap uses the nearest tied mode.

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

  Known flagged count and full-sample percentage. The percentage is
  unavailable when any rule outcome is unknown; the count is unavailable
  when no response can be evaluated.

- EvaluatedObservations, UnavailableObservations:

  Responses whose rule outcome is determined or unavailable.

- AbsZThreshold, ProbThreshold:

  Applied cutoff values.

- Rule:

  "residual", "either", or "both".

The `table` data.frame has the same structure as
`unexpected_response_table()` output, with an additional
`BiasAdjustment` column showing the bias correction applied to each
observation's expected value.

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
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)
for migration instructions.

The returned `fit_identity` records the fitted analysis for reuse with
reports and exports. Recreate older results from the saved fit and
matching diagnostics using the original screening options; no model
refit is needed. See
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)
for migration instructions.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md),
[`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
`unexpected_response_table()`,
[`bias_count_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
# example("unexpected_response_table", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
library(mfrmr)
# Saved synthetic MML/RSM analysis of example_operational.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
fit <- example_fit$fit
diagnostics <- example_fit$diagnostics
unexpected <- unexpected_response_table(
  fit, diagnostics = diagnostics, abs_z_min = 1.5, prob_max = 0.4, top_n = 5
)
unexpected$summary # Counts and percentages for all flagged observations
unexpected$table   # Only the five highest-ranked cases
plot(unexpected)
# The rule is exploratory: inspect the scoring context before changing a rating
} # }
# Optional workflow; run the example explicitly as shown below.
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
plot_data(p_t10, "plot")
} # }
```
