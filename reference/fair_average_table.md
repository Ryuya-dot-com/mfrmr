# Build an adjusted-score reference table bundle

Build an adjusted-score reference table bundle

## Usage

``` r
fair_average_table(
  fit,
  diagnostics = NULL,
  facets = NULL,
  totalscore = TRUE,
  umean = 0,
  uscale = 1,
  udecimals = 2,
  reference = c("both", "mean", "zero"),
  label_style = c("both", "native", "legacy"),
  omit_unobserved = FALSE,
  xtreme = 0,
  fair_se = FALSE,
  ci_level = 0.95
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- facets:

  Optional subset of facets.

- totalscore:

  Include all observations for score totals (`TRUE`) or apply legacy
  extreme-row exclusion (`FALSE`).

- umean:

  Additive score-to-report origin shift.

- uscale:

  Multiplicative score-to-report scale.

- udecimals:

  Rounding digits used in formatted output.

- reference:

  Which adjusted-score reference to keep in formatted outputs: `"both"`
  (default), `"mean"`, or `"zero"`.

- label_style:

  Column-label style for formatted outputs: `"both"` (default),
  `"native"`, or `"legacy"`.

- omit_unobserved:

  If `TRUE`, remove unobserved levels.

- xtreme:

  Extreme-score adjustment amount.

- fair_se:

  Logical. When `TRUE` and `fit` is an MML bounded-`GPCM` fit, add
  structural delta-method standard errors and confidence limits for
  `Fair(M)` / `AdjustedAverage` and `Fair(Z)` /
  `StandardizedAdjustedAverage`. Person rows remain `NA` because MML
  person EAP estimates are not part of the structural Hessian. For
  `RSM`, `PCM`, and `JML` fits this option leaves fair-average SE
  columns unavailable.

- ci_level:

  Confidence level used when `fair_se = TRUE`; default `0.95`.

## Value

A named list with:

- `by_facet`: named list of formatted data.frames

- `stacked`: one stacked data.frame across facets

- `raw_by_facet`: unformatted component tables

- `settings`: resolved options

## Details

This function wraps the package's adjusted-score calculations and
returns both facet-wise and stacked tables. Historical display columns
such as `Fair(M) Average` and `Fair(Z) Average` are retained for
compatibility, and package-native aliases such as `AdjustedAverage`,
`StandardizedAdjustedAverage`, `ModelBasedSE`, and `FitAdjustedSE` are
appended to the formatted outputs.

For the Rasch-family `RSM` / `PCM` branch, these tables follow the
standard FACETS Linacre construction: fair averages are
Rasch-measure-to-score transformations evaluated in a standardized
mean/zero-facet environment.

Bounded `GPCM` fits are supported under a slope-aware
element-conditional construction. For each slope-facet element
\\j^\star\\ the per-row fair-average is the GPCM expected score
\$\$\mathrm{FA}\_{p, j^\star} = \sum_k k \cdot P\_{GPCM}(X = k \mid
\theta_p, a\_{j^\star}, \boldsymbol{\delta}\_{j^\star})\$\$ computed at
that element's own discrimination \\a\_{j^\star}\\ and threshold
structure. Rows for non-slope facets (Person, Rater, ...) use the
geometric-mean-one slope by the GPCM identification convention, so those
rows remain continuous with the standard PCM Linacre fair-average and
reduce to it exactly when all slopes equal one. This is an
identification-based reporting convention for the package's bounded
`GPCM` route, not a unique free-discrimination score-side analogue to
FACETS fair averages. Do not report it as FACETS score-side equivalence
or as an operational scoring rule unless that convention is
substantively justified.

Standard errors on the fair-average value itself are opt-in for MML
bounded `GPCM` fits via `fair_se = TRUE`. The original `SE`,
`Model S.E.`, `ModelBasedSE`, `Real S.E.`, and `FitAdjustedSE` columns
retain the same meaning as for PCM (scaled facet-measure SEs);
fair-average uncertainty is reported under distinct columns such as
`Fair(M) S.E.`, `Fair(M) CI Lower`, and `AdjustedAverageSE`.

## Interpreting output

- `stacked`: cross-facet table for global comparison.

- `by_facet`: per-facet formatted tables for reporting.

- `raw_by_facet`: unformatted values for custom analyses/plots.

- `settings`: scoring-transformation and filtering options used.

Larger observed-vs-fair gaps can indicate systematic scoring tendencies
by specific facet levels.

## Typical workflow

1.  Run `fair_average_table(fit, ...)`.

2.  Inspect `summary(t12)` and `t12$stacked`.

3.  Visualize with
    [`plot_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_fair_average.md).

## Output columns

The `stacked` data.frame contains:

- Facet:

  Facet name for this row.

- Level:

  Element label within the facet.

- Obsvd Average:

  Observed raw-score average.

- Fair(M) Average:

  Model-adjusted reference average on the reported score scale.

- Fair(Z) Average:

  Standardized adjusted reference average.

- ObservedAverage, AdjustedAverage, StandardizedAdjustedAverage:

  Package-native aliases for the three average columns above.

- AdjustedAverageSE, AdjustedAverageCI_Lower, AdjustedAverageCI_Upper:

  Optional structural delta-method uncertainty for `AdjustedAverage`
  when `fair_se = TRUE` and available.

- StandardizedAdjustedAverageSE, StandardizedAdjustedAverageCI_Lower,
  StandardizedAdjustedAverageCI_Upper:

  Optional structural delta-method uncertainty for
  `StandardizedAdjustedAverage` when `fair_se = TRUE` and available.

- Measure:

  Estimated logit measure for this level.

- SE:

  Compatibility alias for the model-based standard error.

- ModelBasedSE, FitAdjustedSE:

  Package-native aliases for `Model S.E.` and `Real S.E.`.

- Infit MnSq, Outfit MnSq:

  Fit statistics for this level.

## Standard-error caveat (read before quoting CIs)

The `SE`, `Model S.E.`, `ModelBasedSE`, `Real S.E.`, and `FitAdjustedSE`
columns in this table are the **measure-level** standard errors of the
underlying facet element (the same SE that would appear in
`summary(fit)$facets`), rescaled by the fair-average score scale factor
so the units line up with the reported `Fair(M) Average` /
`Fair(Z) Average` columns. They are **not** delta-method standard errors
of the fair-average values themselves. When `fair_se = TRUE`, the
distinct `Fair(M) S.E.` / `Fair(Z) S.E.` columns are computed by
propagating the joint covariance of the relevant facet element, the
threshold parameters, and the slope parameters through the gradient of
\\\mathrm{E}\[X \mid \theta_p, j^\star\]\\. This is a structural
covariance calculation: MML person EAP estimates are conditioned on
rather than included in the Hessian, so person rows receive unavailable
fair-average SEs. **Do not use the measure-level `SE` / `Model S.E.`
columns as \\\pm 1.96 \cdot \mathrm{SE}\\ confidence-interval bounds on
the fair-average value.**

## References

- Linacre, J. M. (1989). *Many-Facet Rasch Measurement*. MESA Press.

- Linacre, J. M. (1994). *Many-facet Rasch Measurement* (2nd ed.). MESA
  Press.

- Linacre, J. M. (2026). *A user's guide to FACETS, version 4.5.0*.
  Winsteps.com. <https://www.winsteps.com/facets.htm> (FACETS Table 12
  corresponds to the fair-average construction implemented here for
  `RSM` / `PCM` fits; the slope-aware element-conditional construction
  for bounded `GPCM` is documented in this help page.)

- Andrich, D. (1978). A rating formulation for ordered response
  categories. *Psychometrika, 43*(4), 561-573.
  [doi:10.1007/BF02293814](https://doi.org/10.1007/BF02293814)

- Masters, G. N. (1982). A Rasch model for partial credit scoring.
  *Psychometrika, 47*(2), 149-174.
  [doi:10.1007/BF02296272](https://doi.org/10.1007/BF02296272)

- Muraki, E. (1992). A generalized partial credit model: Application of
  an EM algorithm. *Applied Psychological Measurement, 16*(2), 159-176.
  (Cited for the bounded `GPCM` slope-aware extension.)

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
[`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
t12 <- fair_average_table(fit, udecimals = 2)
t12_native <- fair_average_table(fit, reference = "mean", label_style = "native")
summary(t12)
p_t12 <- plot(t12, draw = FALSE)
p_t12$data$plot
} # }
```
