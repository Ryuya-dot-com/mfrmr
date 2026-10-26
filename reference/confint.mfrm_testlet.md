# Explicit normal-approximation intervals for testlet calibration

Explicit normal-approximation intervals for testlet calibration

## Usage

``` r
# S3 method for class 'mfrm_testlet'
confint(object, parm = "calibration", level = 0.95, ...)
```

## Arguments

- object:

  A result from
  [`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md).

- parm:

  `"calibration"` returns all fixed-facet and step intervals. Variance
  components and Person abilities are not included.

- level:

  Nominal confidence level between zero and one; default 0.95.

- ...:

  Unused.

## Value

A matrix with `Lower` and `Upper`, one row per fixed-facet level or
step, and attributes `level`, `method`, `target`, `note`, `checks` and
`diagnostics`. `attr(ci, "diagnostics")` retains each estimate, SE,
`IntervalStatus`, `CIEligible` and plain-language `InferenceReview`;
`checks` retains the source checks without recomputing them. Save the
whole object with [`saveRDS()`](https://rdrr.io/r/base/readRDS.html);
for CSV, export the diagnostics table to retain reasons.

## Details

The explicit request computes estimate plus/minus a normal quantile
times the saved observed-information SE. It needs no fitting, scoring or
live optimizer and does not change the source fit. Nominal finite-sample
coverage is not established. Estimated variance boundaries, unresolved
numerical/information checks and invalid SEs retain missing bounds. No
regular variance interval, simultaneous comparison or automatic rater
classification is supplied. Default fit tables, summaries and plots omit
these bounds. Use `summary(fit, calibration_intervals = "normal")`,
`plot(fit, intervals = "normal")`, or
`mfrm_results(fit, calibration_intervals = "normal")` to select the same
approximation in those outputs; their level arguments retain its nominal
interpretation.
[`predict.mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict.mfrm_testlet.md)
supplies the separate conditional Person-scoring intervals.

## Reading missing bounds

`estimated_variance_boundary` means an estimated variance is at zero;
regular normal inference is withheld even when a point is retained.
`numerical_review_failed` means numerical readiness or positive
information has not been established; `InferenceReview` retains all
detected reasons, including any simultaneous boundary. Increasing
iterations alone does not repair a variance-boundary restriction.
Inspect `attr(ci, "checks")` first. `invalid_estimate_or_se` and
`nonfinite_bounds` identify row-specific calculation failures. Missing
bounds are neither zero uncertainty nor infinite endpoints. Retaining a
point does not certify its reliability. Default calibration tables also
distinguish `not_requested` from `unsupported_target` (population
SDs/variances). `CIEligible` is true only for a returned normal
interval; it is not a coverage guarantee.

## See also

[`confint.mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_random_rater.md),
[`mfrmr_interval_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_interval_guide.md)
