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
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  for this `fit`. Matching saved diagnostics are reusable; recompute
  them after refitting.

- facets:

  Optional subset of facets.

- totalscore:

  Include all observations for score totals (`TRUE`) or apply legacy
  extreme-row exclusion (`FALSE`).

- umean:

  Additive origin shift for Measure (not fair-score values).

- uscale:

  Multiplicative scale for Measure and measure SEs (not fair scores).

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

  Display adjustment in score units for all-minimum/all-maximum rows;
  default `0` leaves fitted measures unchanged. A positive value
  replaces the displayed `Measure` by inversion of an expected score
  that far from the endpoint. It does not adjust responses, refit the
  model or correct JML bias.

- fair_se:

  Logical. When `TRUE` and `fit` is an MML `GPCM` fit, add structural
  delta-method standard errors and confidence limits for `Fair(M)` /
  `AdjustedAverage` and `Fair(Z)` / `StandardizedAdjustedAverage`.
  Person rows remain `NA` because MML person EAP estimates are not part
  of the structural Hessian. For `RSM`, `PCM`, and `JML` fits this
  option leaves fair-average SE columns unavailable.

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
mean/zero-facet environment. FairM uses mean other-facet measures (and
mean person measure for non-person rows); FairZ uses zero references.
Neither integrates over the observed assignment/person distribution.
FairZ and its historical alias `StandardizedAdjustedAverage` are
expected scores, not z-scores. If a free JML Person measure is infinite,
the mean Person reference is unavailable: non-Person FairM values are
`NA`, with the reason recorded in `FairMReference`. Finite optimizer
traces are not substituted into that mean. FairZ uses a zero Person
reference and does not require this mean.

With `xtreme > 0`, `PrimaryMeasure` retains the fitted measure,
including infinite JML estimates and fixed anchors, on the requested
reporting scale. `MeasureBasis` identifies display-only replacements and
`ExtremeAdjustment` records their amount in score units. The displayed
`Measure` may differ from a fixed anchor; the anchor itself is
unchanged. Measure SEs are unavailable on replaced rows because the
original SE does not describe the display adjustment. Fair-score
calculations do not use the replacement. Recompute older diagnostics and
recreate saved tables from the existing fit before summarizing or
plotting them; no model refit is needed.

`GPCM` fits are supported under a slope-aware element-conditional
construction. For each slope-facet element \\j^\star\\ the per-row
fair-average is the GPCM expected score \$\$\mathrm{FA}\_{p, j^\star} =
\sum_k k \cdot P\_{GPCM}(X = k \mid \theta_p, a\_{j^\star},
\boldsymbol{\delta}\_{j^\star})\$\$ computed at that element's own
discrimination \\a\_{j^\star}\\ and threshold structure. Rows for
non-slope facets (Person, Rater, ...) use the geometric-mean-one slope
by the GPCM identification convention, so those rows remain continuous
with the standard PCM Linacre fair-average and reduce to it exactly when
all slopes equal one. This is an identification-based reporting
convention for the package's `GPCM` route, not a unique
free-discrimination score-side analogue to FACETS fair averages. Do not
report it as FACETS score-side equivalence or as an operational scoring
rule unless that convention is substantively justified.

Standard errors on the fair-average value itself are opt-in for MML
`GPCM` fits via `fair_se = TRUE`. The `Model S.E.`, `ModelBasedSE`,
`Real S.E.`, and `FitAdjustedSE` columns retain the same meaning as for
PCM (scaled facet-measure SEs); fair-average uncertainty is reported
under distinct columns such as `Fair(M) S.E.`, `Fair(M) CI Lower`, and
`AdjustedAverageSE`.

## Interpreting output

- `stacked`: cross-facet table for global comparison.

- `by_facet`: per-facet formatted tables for reporting.

- `raw_by_facet`: unformatted values for custom analyses/plots;
  identifiers use the column `Level`.

- `settings`: scoring-transformation and filtering options used.

Observed-vs-fair gaps also reflect person mix and assignment. They are
descriptive follow-up prompts, not standalone evidence of rater bias.

## Typical workflow

1.  Run `fair_average_table(fit, ...)`.

2.  Inspect `summary(t12)` and `t12$stacked`.

3.  Visualize with
    [`plot_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_fair_average.md).

## Output columns

The `stacked` data.frame contains the following columns, selected by
`reference`, `label_style`, and `fair_se`:

- Facet:

  Facet name for this row.

- Element:

  Element label within the facet.

- Obsvd Average:

  Observed raw-score average.

- Fair(M) Average:

  Model-adjusted reference average on the reported score scale.

- Fair(Z) Average:

  Expected score at a zero reference environment, not a z-score.

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

  Displayed facet measure, transformed by `umean` and `uscale`; may be
  replaced when `xtreme > 0`.

- PrimaryMeasure:

  Original fitted measure on the same reporting scale, including
  infinite JML estimates.

- MeasureBasis, ExtremeAdjustment:

  Whether the displayed measure was replaced and the replacement amount
  in score units.

- FairMReference:

  The mean reference used for FairM, or why that reference is
  unavailable.

- ModelBasedSE, FitAdjustedSE:

  Package-native aliases for `Model S.E.` and `Real S.E.`.

- Infit MnSq, Outfit MnSq:

  Fit statistics for this level.

## Standard-error caveat (read before quoting CIs)

The `Model S.E.`, `ModelBasedSE`, `Real S.E.`, and `FitAdjustedSE`
columns in this table are the **measure-level** standard errors of the
underlying facet element, rescaled by `abs(uscale)` to the reported
Measure units. Fair scores remain on the fitted internal score scale.
They are **not** delta-method standard errors of the fair-average values
themselves. When `fair_se = TRUE`, the distinct `Fair(M) S.E.` /
`Fair(Z) S.E.` columns are computed by propagating the joint covariance
of the relevant facet element, the threshold parameters, and the slope
parameters through the gradient of \\\mathrm{E}\[X \mid \theta_p,
j^\star\]\\. This is a structural covariance calculation: MML person EAP
estimates are conditioned on rather than included in the Hessian, so
person rows receive unavailable fair-average SEs. **Do not use the
measure-level `ModelBasedSE` / `Model S.E.` columns as \\\pm 1.96 \cdot
\mathrm{SE}\\ confidence-interval bounds on the fair-average value.**
`FairCIEligible` is `FALSE` for these diagnostic intervals; numerical
availability (`ok` or `regularized`) does not establish inferential
validity. `FairCIReportingUse` distinguishes diagnostic-only and
unavailable rows. Full-refit coverage remains unverified. For RSM/PCM,
this table does not supply fair-score SEs;
[`plot_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_fair_average.md)
can compute a conditional interval from a fitted model by propagating
only the focal measure SE. Summaries identify `FairMetric`: FairM for
mean/both reference tables, FairZ for zero-reference tables, with
matching score/SE column names. Export `stacked` or the summary's
`summary` / `preview` data.frames with
[`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html).
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)
does not accept this bundle.

## References

- Linacre, J. M. (1989). *Many-Facet Rasch Measurement*. MESA Press.

- Linacre, J. M. (1994). *Many-facet Rasch Measurement* (2nd ed.). MESA
  Press.

- Linacre, J. M. (2026). *A user's guide to FACETS, version 4.5.0*.
  Winsteps.com. (FACETS Table 12 corresponds to the fair-average
  construction implemented here for `RSM` / `PCM` fits; the slope-aware
  element-conditional construction for `GPCM` is documented in this help
  page.)

- Andrich, D. (1978). A rating formulation for ordered response
  categories. *Psychometrika, 43*(4), 561-573.
  [doi:10.1007/BF02293814](https://doi.org/10.1007/BF02293814)

- Masters, G. N. (1982). A Rasch model for partial credit scoring.
  *Psychometrika, 47*(2), 149-174.
  [doi:10.1007/BF02296272](https://doi.org/10.1007/BF02296272)

- Muraki, E. (1992). A generalized partial credit model: Application of
  an EM algorithm. *Applied Psychological Measurement, 16*(2), 159-176.
  (Cited for the `GPCM` slope-aware extension.)

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
[`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md)

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

# Compute diagnostics once for the following checks
diagnostics <- diagnose_mfrm(fit)

# Compare observed person means with model-based scores on a common reference
fair <- fair_average_table(fit, diagnostics = diagnostics, facets = "Person",
                           reference = "mean", label_style = "native")
head(fair$raw_by_facet$Person[, c("Level", "ObservedAverage", "FairM")])
#> # A tibble: 6 × 3
#>   Level ObservedAverage FairM
#>   <chr>           <dbl> <dbl>
#> 1 P045             3.67  3.45
#> 2 P015             3.67  3.44
#> 3 P036             3.33  3.33
#> 4 P030             3.33  3.28
#> 5 P027             3.17  3.16
#> 6 P025             3     3.02
# FairM uses the mean reference for the other facets; it is in score units
# It is a conditional model prediction, not a guarantee of fairness
# }
```
