# Build a bias pairwise-contrast report (FACETS Table 14: pairwise contrasts)

Build a pairwise contrast table that, for a chosen target facet (e.g.
raters), compares each pair of target-facet levels while holding a
context facet (e.g. items / criteria) constant. This is the FACETS Table
14 view: it answers "is rater A consistently more severe than rater B on
the same items?" rather than "which (rater, item) cell has the largest
local bias?" – the latter is covered by
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md).

## Usage

``` r
bias_pairwise_report(
  x,
  diagnostics = NULL,
  facet_a = NULL,
  facet_b = NULL,
  interaction_facets = NULL,
  max_abs = 10,
  omit_extreme = TRUE,
  max_iter = 4,
  tol = 0.001,
  target_facet = NULL,
  context_facet = NULL,
  top_n = 50,
  p_max = 0.05,
  sort_by = c("abs_t", "abs_contrast", "prob")
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

- target_facet:

  Facet whose local contrasts should be compared across the paired
  context facet. Defaults to the first interaction facet.

- context_facet:

  Optional facet to condition on. Defaults to the other facet in a 2-way
  interaction.

- top_n:

  Maximum number of ranked rows to keep.

- p_max:

  Flagging cutoff for pairwise p-values.

- sort_by:

  Ranking key: `"abs_t"`, `"abs_bias"`, or `"prob"`.

## Value

A named list with:

- `table`: pairwise contrast rows

- `summary`: one-row contrast summary

- `orientation_review`: interaction-facet sign review

- `settings`: resolved reporting options

- `direction_note`: one-line interpretive note describing the dominant
  pairwise-contrast direction (carried from the underlying bias
  estimator; empty string when not applicable)

- `recommended_action`: one-line recommended-action label (e.g. routing
  the user to follow-up review of the largest flagged pairs); empty
  string when the underlying estimator does not emit one

## Details

This helper exposes the pairwise contrast table that was previously only
reachable through fixed-width output generation. It is available only
for 2-way interactions. The pairwise contrast statistic uses a
Welch/Satterthwaite approximation and is labeled as a Rasch-Welch
comparison in the output metadata.

## Interpreting output

- `table`: one row per ordered (target_level_1, target_level_2) pair,
  with `Bias_diff`, `SE_diff`, `t_diff`, `df_diff`, `p_diff`, and the
  underlying per-level bias rows. Rows are sorted so that the
  largest-magnitude `|t_diff|` rises to the top.

- `summary`: one-row screening summary with `MaxAbsBiasDiff`, `MaxAbsT`,
  `Significant` (count of flagged pairs at `p_max`),
  `BonferroniSignificant`, and `HolmSignificant`.

- `orientation_review` carries the same facet-orientation sign review as
  the parent
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  run.

- The SE caveat below applies: read `Significant` /
  `BonferroniSignificant` as a screening triage, not as formal
  inferential tests.

## Typical workflow

1.  Fit and diagnose the model.

2.  Run
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
    to get the underlying interaction effects.

3.  Pass that result to `bias_pairwise_report()` for the rater-pair
    contrast table.

4.  Use `summary(out)$MaxAbsT` and the top rows of `out$table` to flag
    rater-pair systematic differences for follow-up review.

5.  For the ranked flagged-cells view (which (rater, item) pairs have
    the largest local bias), use
    [`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md)
    on the same
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
    output.

## Standard-error caveat

The contrast standard error is computed as
`SE(b_i - b_j) = sqrt(SE_i^2 + SE_j^2)` – the independence
approximation. For same-facet bias values that share a sum-to-zero
identification, `Cov(b_i, b_j) < 0`, so the true contrast variance is
`SE_i^2 + SE_j^2 - 2 * Cov(b_i, b_j)`, which is **smaller** than the
reported value. The reported t-statistics and p-values are therefore
conservative for same-facet contrasts (the true significance is higher
than reported). For across-facet contrasts the covariance term is
approximately zero and the approximation is appropriate. Use the report
as a screening / triage table; for inferential claims that hinge on a
marginally-significant same-facet contrast, follow up with a contrast
that uses the full parameter covariance.

## References

- Linacre, J. M. (1989). *Many-Facet Rasch Measurement*. MESA Press.

- Eckes, T. (2005). Examining rater effects in TestDaF writing and
  speaking performance assessments: A many-facet Rasch analysis.
  *Language Assessment Quarterly, 2*(3), 197-221.

- Myford, C. M., & Wolfe, E. W. (2003). Detecting and measuring rater
  effects using many-facet Rasch measurement: Part I. *Journal of
  Applied Measurement, 4*(4), 386-422.

- Myford, C. M., & Wolfe, E. W. (2004). Detecting and measuring rater
  effects using many-facet Rasch measurement: Part II. *Journal of
  Applied Measurement, 5*(2), 189-227.

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
out <- bias_pairwise_report(fit, diagnostics = diag, facet_a = "Rater", facet_b = "Criterion")
s <- summary(out)
s$summary
# Look for: `MaxAbsBiasDiff` < ~0.5 logits and `Significant = 0` mean
#   no rater pair contrasts above the screen. The `BonferroniSignificant`
#   / `HolmSignificant` columns count pairs that survive multiple-
#   testing correction; both being 0 is a stronger "no rater-pair
#   inconsistency" signal than the raw screen-positive count alone.
head(out$table)
# Look for: top rows with `|t_diff|` > 2 and |Bias_diff| > 0.5 logits
#   warrant content-review of the two raters' scoring conventions on
#   the conditioning context facet (e.g. compare their item-level
#   marks for systematic strictness/leniency patterns).
}
```
