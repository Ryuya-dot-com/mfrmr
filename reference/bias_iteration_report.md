# Build a bias-iteration report (FACETS Table 9: iteration / convergence trace)

This report is NOT an alias of
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md)
despite the similar name. It focuses on the **recalibration path** of a
bias run: iteration table, convergence summary, and orientation review.
Use this to confirm that the bias recalibration itself converged; use
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md)
to review the ranked flagged cells from the converged run.

## Usage

``` r
bias_iteration_report(
  x,
  diagnostics = NULL,
  facet_a = NULL,
  facet_b = NULL,
  interaction_facets = NULL,
  max_abs = 10,
  omit_extreme = TRUE,
  max_iter = 4,
  tol = 0.001,
  top_n = 10
)
```

## Arguments

- x:

  Output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  or
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  (used when `x` is fit).

- facet_a:

  First facet name (required when `x` is fit and `interaction_facets` is
  not supplied).

- facet_b:

  Second facet name (required when `x` is fit and `interaction_facets`
  is not supplied).

- interaction_facets:

  Character vector of two or more facets.

- max_abs:

  Bound for absolute bias size when estimating from fit.

- omit_extreme:

  Omit extreme-only elements when estimating from fit.

- max_iter:

  Iteration cap for bias estimation when `x` is fit.

- tol:

  Convergence tolerance for bias estimation when `x` is fit.

- top_n:

  Maximum number of iteration rows to keep in preview-oriented
  summaries. The full iteration table is always returned.

## Value

A named list with:

- `table`: iteration history

- `summary`: one-row convergence summary

- `orientation_review`: interaction-facet sign review

- `settings`: resolved reporting options

- `direction_note`: one-line interpretive note describing which
  direction the iteration moved (carried from the bias estimator; empty
  string when the underlying estimator does not emit one)

- `recommended_action`: one-line recommended action label (e.g.
  `"converged"`, `"increase max_iter"`); empty string when the
  underlying estimator does not emit one

## Details

This report focuses on the recalibration path used by
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).
It provides a package-native counterpart to legacy iteration printouts
by exposing the iteration table, convergence summary, and orientation
review in one bundle.

## See also

[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md),
[`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_bias")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
out <- bias_iteration_report(fit, diagnostics = diag, facet_a = "Rater", facet_b = "Criterion")
summary(out)
}
```
