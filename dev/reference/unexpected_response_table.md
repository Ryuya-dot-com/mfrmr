# Build an unexpected-response screening report

Build an unexpected-response screening report

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
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md).

- abs_z_min:

  Absolute standardized-residual cutoff.

- prob_max:

  Maximum observed-category probability cutoff.

- top_n:

  Maximum number of ranked rows to return in `table`. Summary counts and
  percentages always use all flagged observations.

- rule:

  `"residual"` (default) uses only the absolute residual cutoff;
  `"either"` and `"both"` also use the category-probability cutoff.

## Value

A named list with:

- `table`: flagged response rows

- `summary`: one-row overview

- `thresholds`: applied thresholds

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

## Interpreting output

- `summary`: prevalence of unexpected responses under current
  thresholds, before limiting the displayed rows with `top_n`.

- `table`: ranked row-level diagnostics for case review.

- `thresholds`: active cutoffs and flagging rule.

Compare results across `rule = "either"` and `rule = "both"` to assess
how conservative your screening should be.

## Typical workflow

1.  Start with the default residual screen. Category probability is an
    optional case-review aid, not a tail probability or calibrated
    false-alarm rate.

2.  Re-run with `rule = "both"` for strict subset.

3.  Inspect top rows and visualize with [plot(x, type =
    "unexpected")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md).

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-visual-diagnostics.md).

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

  "either" or "both".

## Saved-result reuse

The returned `fit_identity` records the fitted analysis for reuse with
reports and exports. Recreate older results from the saved fit and
matching diagnostics using the original screening options; no model
refit is needed. See
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_compatibility_layer.md)
for migration instructions.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md),
[`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/displacement_table.md),
[`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fair_average_table.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
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
```
