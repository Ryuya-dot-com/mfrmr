# Build a precision review report

Build a precision review report

## Usage

``` r
precision_review_report(fit, diagnostics = NULL)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional matching output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  Recompute it after refitting; mismatched or outdated readiness records
  are rejected.

## Value

A named list with:

- `profile`: one-row precision overview

- `checks`: package-native precision review checks

- `fit_separation_basis`: source-grounded fit/separation reporting
  boundary

- `approximation_notes`: detailed method notes

- `settings`: resolved model and method labels

## Details

This helper summarizes how `mfrmr` derived SE, CI, and reliability
values for the current run. It also includes a source-grounded
fit/separation basis table so users can keep mean-square fit, ZSTD
standardization, Rasch/FACETS-style separation, and package QC
thresholds in distinct reporting categories.

## What this review means

`precision_review_report()` is a structured prerequisite review for
precision claims. It tells you how the package derived uncertainty
summaries for the current run and how cautiously those summaries should
be written up.

## What this review does not justify

- It does not, by itself, validate the measurement model or substantive
  conclusions.

- A favorable precision tier does not override convergence, fit,
  linking, or design problems elsewhere in the analysis.

- Fit and separation rows in this report are reporting/validation
  boundaries, not standalone success criteria.

## Interpreting output

- `profile`: one-row overview of the active precision tier and
  recommended use.

- `checks`: package-native review checks for SE ordering, reliability
  ordering, coverage of sample/population summaries, and SE source
  labels.

- `fit_separation_basis`: source-grounded boundary table for fit and
  separation reporting.

- `approximation_notes`: method notes copied from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

## Recommended next step

Use the `profile$PrecisionTier` and `checks` table to decide whether SE,
CI, and reliability language can be phrased as model-based, should be
qualified as hybrid, or should remain exploratory in the final report.

## Typical workflow

1.  Run
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    for the fitted model.

2.  Build `precision_review_report(fit, diagnostics = diag)`.

3.  Use [`summary()`](https://rdrr.io/r/base/summary.html) to see
    whether the run supports model-based reporting language or should
    remain in exploratory/screening mode.

Regularized or fallback SEs remain diagnostic only. Numerical
convergence does not establish inferential support. Older reports
without the recorded regularization distinction must be recreated with
`precision_review_report(fit)`; the existing fit can be reused without
refitting.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`facet_statistics_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_statistics_report.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)

## Examples

``` r
# \donttest{
# Load the package and example ratings
library(mfrmr)
toy <- load_mfrmr_data("example_operational")

# Fit the model
fit <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM"
)

# Review support for standard errors, intervals, and reliability summaries
diagnostics <- diagnose_mfrm(fit)
precision <- precision_review_report(fit, diagnostics = diagnostics)
review <- summary(precision)
review$checks # Check statuses and reasons before making precision claims
#>                      Check Status
#> 1           Precision tier   pass
#> 2    Optimizer convergence   pass
#> 3     ModelSE availability   pass
#> 4 Fit-adjusted SE ordering   pass
#> 5     Reliability ordering   pass
#> 6 Facet precision coverage   pass
#> 7         SE source labels   pass
#>                                                                                                                                                                                                    Detail
#> 1 Uncertainty is conditional on the fitted model. Person posterior SDs condition on the fitted calibration; facet standard errors use observed information. Review interval assumptions before reporting.
#> 2                                                                                                              Numerical convergence checks passed; this alone does not establish valid SEs or intervals.
#> 3                                                                                                                                               Finite standard errors were available for 100.0% of rows.
#> 4                                                                                                              Among available pairs, fit-adjusted SEs were at least as large as their unadjusted values.
#> 5                                                                                                     Among available pairs, fit-adjusted reliability values were not larger than the model-based values.
#> 6                                                                                                                    Each facet had sample/population summaries for both model and fit-adjusted SE modes.
#> 7                                                                                                                     Person uncertainty uses posterior SDs; facet uncertainty uses observed information.
# }
```
