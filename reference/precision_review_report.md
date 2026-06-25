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

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

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
thresholds in separate reporting lanes.

## What this review means

`precision_review_report()` is a reporting gatekeeper for precision
claims. It tells you how the package derived uncertainty summaries for
the current run and how cautiously those summaries should be written up.

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

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`facet_statistics_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_statistics_report.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
out <- precision_review_report(fit, diagnostics = diag)
summary(out)
}
```
