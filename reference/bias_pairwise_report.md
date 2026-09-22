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
# \donttest{
toy <- load_mfrmr_data("example_bias")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
diag <- diagnose_mfrm(fit, residual_pca = "none")
out <- bias_pairwise_report(fit, diagnostics = diag, facet_a = "Rater", facet_b = "Criterion")
s <- summary(out)
s$summary
#>   TargetFacet ContextFacet Contrasts Flagged MeanAbsContrast MeanAbsT MixedSign
#> 1       Rater    Criterion        24       6       0.5123773 1.185078     FALSE
# Look for: `MaxAbsBiasDiff` < ~0.5 logits and `Significant = 0` mean
#   no rater pair contrasts above the screen. The `BonferroniSignificant`
#   / `HolmSignificant` columns count pairs that survive multiple-
#   testing correction; both being 0 is a stronger "no rater-pair
#   inconsistency" signal than the raw screen-positive count alone.
head(out$table)
#>    Target Target N Target Measure Target S.E. Context1 Context1 N
#> 21    R04        4      0.6750870   0.1474998 Accuracy          1
#> 20    R04        4      0.6750870   0.1474998 Accuracy          1
#> 3     R01        1     -0.8667174   0.1520705 Accuracy          1
#> 19    R04        4      0.6750870   0.1474998 Accuracy          1
#> 1     R01        1     -0.8667174   0.1520705 Accuracy          1
#> 2     R01        1     -0.8667174   0.1520705 Accuracy          1
#>    Local Measure1       SE1 Obs-Exp Avg1 Count1 ObsN1     Context2 Context2 N
#> 21    -0.42701557 0.3641703 1.089553e-06     24    24 Organization          4
#> 20    -0.42701557 0.3641703 1.089553e-06     24    24     Language          3
#> 3     -0.08973921 0.3436801 2.183428e-06     24    24 Organization          4
#> 19    -0.42701557 0.3641703 1.089553e-06     24    24      Content          2
#> 1     -0.08973921 0.3436801 2.183428e-06     24    24      Content          2
#> 2     -0.08973921 0.3436801 2.183428e-06     24    24     Language          3
#>    Local Measure2       SE2  Obs-Exp Avg2 Count2 ObsN2   Contrast        SE
#> 21      1.3582187 0.3338509  7.031888e-06     24    24 -1.7852343 0.4478437
#> 20      0.9087957 0.3313442 -7.940558e-06     24    24 -1.3358113 0.4459782
#> 3      -1.2288403 0.3302885 -1.723957e-07     24    24  1.1391011 0.4253888
#> 19      0.7391378 0.3289915  8.007103e-06     24    24 -1.1661534 0.4442330
#> 1      -1.1441336 0.3374455 -8.662764e-07     24    24  1.0543944 0.4309694
#> 2      -1.0504354 0.3436804 -7.536498e-07     24    24  0.9606962 0.4358685
#>            t     d.f.        Prob. InferenceTier SupportsFormalInference
#> 21 -3.986289 45.49345 0.0002406443     screening                   FALSE
#> 20 -2.995239 45.40177 0.0044300030     screening                   FALSE
#> 3   2.677788 45.88585 0.0102481613     screening                   FALSE
#> 19 -2.625094 45.30823 0.0117696837     screening                   FALSE
#> 1   2.446564 45.97597 0.0183059804     screening                   FALSE
#> 2   2.204096 46.00000 0.0325602852     screening                   FALSE
#>    FormalInferenceEligible PrimaryReportingEligible   ReportingUse
#> 21                   FALSE                    FALSE screening_only
#> 20                   FALSE                    FALSE screening_only
#> 3                    FALSE                    FALSE screening_only
#> 19                   FALSE                    FALSE screening_only
#> 1                    FALSE                    FALSE screening_only
#> 2                    FALSE                    FALSE screening_only
#>                                                                                        ContrastBasis
#> 21 difference between local target measures across contexts (target term cancels to a bias contrast)
#> 20 difference between local target measures across contexts (target term cancels to a bias contrast)
#> 3  difference between local target measures across contexts (target term cancels to a bias contrast)
#> 19 difference between local target measures across contexts (target term cancels to a bias contrast)
#> 1  difference between local target measures across contexts (target term cancels to a bias contrast)
#> 2  difference between local target measures across contexts (target term cancels to a bias contrast)
#>                                           SEBasis
#> 21 combined context-specific bias standard errors
#> 20 combined context-specific bias standard errors
#> 3  combined context-specific bias standard errors
#> 19 combined context-specific bias standard errors
#> 1  combined context-specific bias standard errors
#> 2  combined context-specific bias standard errors
#>                     StatisticLabel   ProbabilityMetric
#> 21 Bias-contrast Welch screening t screening tail area
#> 20 Bias-contrast Welch screening t screening tail area
#> 3  Bias-contrast Welch screening t screening tail area
#> 19 Bias-contrast Welch screening t screening tail area
#> 1  Bias-contrast Welch screening t screening tail area
#> 2  Bias-contrast Welch screening t screening tail area
#>                              DFBasis     AbsT AbsContrast Flag
#> 21 Welch-Satterthwaite approximation 3.986289   1.7852343 TRUE
#> 20 Welch-Satterthwaite approximation 2.995239   1.3358113 TRUE
#> 3  Welch-Satterthwaite approximation 2.677788   1.1391011 TRUE
#> 19 Welch-Satterthwaite approximation 2.625094   1.1661534 TRUE
#> 1  Welch-Satterthwaite approximation 2.446564   1.0543944 TRUE
#> 2  Welch-Satterthwaite approximation 2.204096   0.9606962 TRUE
# Look for: top rows with `|t_diff|` > 2 and |Bias_diff| > 0.5 logits
#   warrant content-review of the two raters' scoring conventions on
#   the conditioning context facet (e.g. compare their item-level
#   marks for systematic strictness/leniency patterns).
# }
```
