# Build a conditional bias pairwise-contrast report (Table 14 style)

Compare each target element's local measure across pairs of contexts.
With target `Rater` and context `Criterion`, a row compares the same
rater's local severity on two criteria. With target `Criterion` and
context `Rater`, it compares the same criterion's local difficulty
across two raters. The calculation uses conditional bias cells and does
not establish numerical equivalence to FACETS Table 14.

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
  sort_by = c("abs_t", "abs_contrast", "prob"),
  df_method = c("facets", "classical")
)
```

## Arguments

- x:

  Output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md)
  or
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
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

  Facet whose levels supply the two contexts. Must be the other facet in
  a 2-way interaction.

- top_n:

  Maximum number of ranked rows to keep.

- p_max:

  Screening tail-area cutoff. An available row is flagged when
  `abs(t) >= 2` OR `Prob. <= p_max`; this is not a p-value-only test.

- sort_by:

  Ranking key: `"abs_t"`, `"abs_contrast"`, or `"prob"`.

- df_method:

  Pairwise df convention: `"facets"` (modified Rasch-Welch, integer
  part, matching FACETS 4.5.0) or `"classical"` (former continuous df).

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
for 2-way interactions. Rows without available orientation or precision
are retained with missing screening results. `top_n` limits displayed
rows; the summary always describes the complete pairwise family.

## Interpreting output

- `table`: one row per target element and context pair, with `Target`,
  `Context1`, `Context2`, `Local Measure1`, `Local Measure2`,
  `Contrast`, `SE`, `t`, `d.f.`, `Prob.`, `Flag`, and calculation/status
  metadata. The default sort places the largest absolute t first and
  unavailable values last.

- `summary`: full-family `Contrasts`, `ScreenAvailable`,
  `ScreenUnavailable`, `Flagged`, `MeanAbsContrast`, and `MeanAbsT`.
  `Flagged` counts known screen-positive rows and is missing when none
  can be screened. A zero count does not clear unavailable comparisons.

- `orientation_review` carries the same facet-orientation sign review as
  the parent
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md)
  run.

- Flags are unadjusted exploratory screens. This report does not apply
  multiplicity correction or establish the absence of differential bias.

## Typical workflow

1.  Fit and diagnose the model.

2.  Run
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md)
    to get the underlying interaction effects.

3.  Pass that result to `bias_pairwise_report()` with the intended
    target and context facets.

4.  Read `out$summary` for availability and `out$table` for direction,
    magnitude and uncertainty of the local comparisons.

5.  For the ranked flagged-cells view (which (rater, item) pairs have
    the largest local bias), use
    [`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/bias_interaction_report.md)
    on the same
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md)
    output.

## Standard-error caveat

The contrast standard error is computed as
`SE(b_i - b_j) = sqrt(SE_i^2 + SE_j^2)` – the independence approximation
conditional on the calibration. The general variance of a difference
also subtracts `2 * Cov(b_i, b_j)`: a negative covariance increases that
variance, while a positive covariance decreases it. Neither its sign nor
its magnitude is established here. There is no general claim that these
screens are conservative. The cell shifts are estimated separately with
fixed baseline parameters, not by a jointly estimated sum-to-zero bias
model.

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

## Pairwise calculation

For each target element, compare its local measure in two contexts. If
the target has predictor sign `s`, its local measure is
`target + bias/s`; the contrast is Context1 minus Context2. A negatively
oriented rater therefore has local severity `severity - bias`.
`TargetSign` comes from the saved bias result's `orientation_review`.
Missing orientation withholds local measures, contrasts and tail areas;
it is not inferred from a facet name.

`SE1` and `SE2` are conditional cell-information SEs with baseline
calibration held fixed. The contrast SE is `sqrt(SE1^2 + SE2^2)` under
conditional independence of the two cells. Calibration uncertainty and
cross-cell covariance are not propagated. `Target S.E.` describes the
original target estimate separately and is not added to the conditional
local SE; a fixed target can still have uncertain local bias.

The default `df_method = "facets"` uses the modified Rasch-Welch formula
described in the FACETS t-statistics manual (von Davier, 2025). Writing
`v1 = SE1^2`, `v2 = SE2^2` and `n1`, `n2` for weighted counts, its df is
`(v1+v2)^2 * (n1+n2-2) / ((n1+n2+2) * (v1^2/(n1+1)+v2^2/(n2+1)))`. The
tail area uses its integer part, matching executed FACETS 4.5.0
unequal-count examples. Values are stabilized to ten decimal places
before truncation to avoid numerical noise at integer boundaries.
`DFUnrounded` retains the original continuous value.
`df_method = "classical"` retains the former Welch-Satterthwaite
reference with `n1-1`, `n2-1` and no integer truncation. `DFMethod` and
`DFBasis` identify the choice; equal counts alone cannot distinguish the
formulas. `ObsN1` and `ObsN2` are raw row counts. Both weighted counts
must exceed one, both SEs must be positive and finite, and the final df
must be positive. Otherwise the screen remains unavailable. Fractional
weights follow the same rule but are outside the executed comparison.
These are conditional screens, not calibrated fairness tests or general
FACETS equivalence.

## Saved pairwise results

Current tables carry `CalculationVersion = 3`. Recreate older fixed or
pairwise reports using
[`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_fixed_reports.md)
or `bias_pairwise_report()`. If the bias bundle predates baseline-score
corrections or lacks orientation, recreate
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md)
from the saved fit and current diagnostics first. No main calibration
refit is needed. Keep historical values separately; summaries and
fixed-report plots reject older pairwise calculations.

## See also

[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md),
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/bias_interaction_report.md),
[`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_fixed_reports.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("bias_pairwise_report", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_bias.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "bias-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diag <- example_fit$diagnostics
out <- bias_pairwise_report(fit, diagnostics = diag, facet_a = "Rater", facet_b = "Criterion")
s <- summary(out)
s$summary
# Check ScreenUnavailable before reading the known Flagged count.
# Zero flags do not establish equivalence or absence of bias.
head(out$table)
# For target Rater, compare that rater's local severity across criteria.
# Read Context1 minus Context2 and the conditional SE before follow-up.
} # }
```
