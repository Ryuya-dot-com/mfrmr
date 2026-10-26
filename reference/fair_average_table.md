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
  ci_level = 0.95,
  xtreme_method = c("display", "facets"),
  reference_plan = NULL
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

  Include all observations for score totals (`TRUE`) or apply
  extreme-row exclusion (`FALSE`). In ordinary additive RSM/PCM JML,
  finite direct anchors remain eligible even with
  all-minimum/all-maximum responses, under both `xtreme_method`
  conventions.

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

  Nonnegative correction smaller than the score range for
  all-minimum/all-maximum rows. Default `0` leaves measures unchanged.
  Its units depend on `xtreme_method`; no responses or primary estimates
  are changed, and this does not correct JML bias.

- fair_se:

  Logical. When `TRUE` and `fit` is an MML `GPCM` fit, add structural
  delta-method standard errors and confidence limits for `Fair(M)` /
  `AdjustedAverage` and `Fair(Z)` / `StandardizedAdjustedAverage`.
  Person rows remain `NA` because MML person EAP estimates are not part
  of the structural Hessian. For `RSM`, `PCM`, and `JML` fits this
  option leaves fair-average SE columns unavailable.

- ci_level:

  Confidence level used when `fair_se = TRUE`; default `0.95`.

- xtreme_method:

  `"display"` (default) retains the historical average-score display
  adjustment. `"facets"` uses conditional total-score extrapolation for
  ordinary additive RSM/PCM JML, without group-mean anchors. Supply
  `xtreme = .3` explicitly to use the usual FACETS main correction.

- reference_plan:

  Optional data frame of non-Person facet columns, using the fitted
  facet names, and an optional positive `Weight` column. For ordinary
  additive RSM/PCM JML, adds `reference_scores`: each Person's expected
  average on this same plan, using its fitted facet locations and scale
  profiles. Weights are normalized to sum to one. This distinct target
  does not replace FairM/FairZ or their administered PCM scale mixture.
  Primary estimates are used, irrespective of display/extrapolation
  settings. Scores use internal score units, unaffected by `umean` or
  `uscale`. The result retains the fit for
  [`confint.mfrm_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fair_average.md).
  For an explicit `mfrm_jeffreys_fit`, this argument is required and the
  result contains only common-plan `reference_scores`, the plan, fit and
  estimator identity. Other arguments beyond `fit` and `reference_plan`
  are refused: ordinary FairM/FairZ diagnostics do not apply. Inspect
  `summary(result)`; use `plot(confint(result, ...))` for supported
  interval plots. Direct FairM/FairZ plotting is unavailable for this
  result.

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

`RSM` fair scores use the shared scale. `PCM` retains each observation's
step profile, converts the reference predictor to an expected score,
then averages with rating weights. Averaging thresholds before
conversion is not equivalent. FairM replaces other element locations by
their means; FairZ replaces them by zero. The PCM scale exposure is
retained, so fair scores can still depend on which scales were
administered. The Person reference excludes nonfinite primary estimates
and records eligible/excluded counts. With no finite Person reference,
non-Person FairM is unavailable. FairZ does not need a Person mean.
Neither target integrates over Person ability; these are expected
scores, not z-scores.

With `xtreme > 0`, `PrimaryMeasure` retains the fitted measure,
including infinite JML estimates and fixed anchors, on the requested
reporting scale. Fixed anchors retain their measure in both columns.
With `xtreme_method = "display"`, an expected average that is `xtreme`
from the endpoint is inverted. Measure SEs are unavailable on replaced
rows and fair-score calculations do not use that replacement. For
ordinary additive RSM/PCM JML, a directly anchored element is not
classified as an unanchored extreme for row exclusion. Its observations
remain eligible when `totalscore = FALSE`, unless another unanchored
extreme element requires their exclusion. This rule also preserves the
PCM scale mixture used in fair scores and does not depend on the display
adjustment. Recreate older affected fair-score tables and plots from the
saved fit and matching diagnostics; refitting the calibration is
unnecessary.

With `xtreme_method = "facets"`, the weighted total is moved inward by
`xtreme` times the smallest positive weight among that element's
eligible observations. Responses involving another unanchored extreme
element are excluded. The resulting weighted score equation is solved
using the actual administered calibration and PCM scales. Its reciprocal
square-root conditional information supplies the reporting SE. The
replacement enters that element's FairM/FairZ, while reference locations
retain their original basis. `ExtremeAdjustment` records a
weighted-total correction in this mode, versus an average-score
correction in `"display"` mode. `MeasureBasis` and `MeasureSEBasis`
identify the reported quantities. These are finite reporting values and
conditional SEs at an adjusted total, not finite MLEs or SEs for the
original extreme response pattern. Fair-score intervals remain
unavailable when `xtreme > 0`.

Binary unit/replication-weight examples and a fixed-scale PCM kernel
were checked against FACETS 4.5.0. This is not whole-program
equivalence: partial anchor examples can leave native score residuals
and shifted final measures, which this conditional calculation does not
reproduce. Group-mean anchors, fitted interactions, corrected JML, MML
and GPCM are outside this route. Recompute older diagnostics and
recreate saved tables from the existing fit before summarizing or
plotting them; no model refit is needed. With an extreme fixed Person
plus an informative interior Person anchor, matched RSM/PCM examples
also agree for conditional fair scores at the reported native
calibration. Main estimates can still differ and native iteration limits
or nonzero free-element score residuals must not be interpreted as
calibration agreement.

`GPCM` fits are supported under a slope-aware element-conditional
construction. For each slope-facet element \\j^\star\\ the per-row
fair-average is the GPCM expected score \$\$\mathrm{FA}\_{p, j^\star} =
\sum_k k \cdot P\_{GPCM}(X = k \mid \theta_p, a\_{j^\star},
\boldsymbol{\delta}\_{j^\star})\$\$ computed at that element's own
discrimination \\a\_{j^\star}\\ and threshold structure. Rows for
non-slope facets (Person, Rater, ...) use the geometric-mean-one slope
by the GPCM identification convention and average the threshold profiles
before score conversion. At unit slope the conversion reduces to the PCM
kernel, but this aggregation need not equal PCM's average of
administered-scale expectations for non-step-facet rows. This is an
identification-based reporting convention for the package's `GPCM`
route, not a unique free-discrimination score-side analogue to FACETS
fair averages. Do not report it as FACETS score-side equivalence or as
an operational scoring rule unless that convention is substantively
justified.

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
Ordinary additive RSM/PCM JML tables also retain `PTMEAExpected` and its
availability metadata when present in the matching diagnostics. This is
a conditional reference for observed `PtMea Corr`, not an inferential
cutoff; see
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
for its finite-count correction and weighting basis.

## Typical workflow

1.  Run `fair_average_table(fit, ...)`.

2.  Inspect `summary(t12)` and `t12$stacked`.

3.  Visualize with [plot(x, type =
    "fair_average")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md).

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

- MeasureSEBasis:

  In `raw_by_facet`, distinguishes conditional information at a
  corrected total from fitted-measure uncertainty.

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
this table does not supply fair-score SEs; [plot(x, type =
"fair_average")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
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
  Winsteps.com. (FACETS Table 7 corresponds to the fair-average
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

# For an ordinary JML fit, request total-score extrapolation explicitly
jml <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML")
extreme_report <- fair_average_table(jml, xtreme = .3, xtreme_method = "facets")
head(extreme_report$raw_by_facet$Person[, c("Level", "PrimaryMeasure",
     "Measure", "MeasureBasis", "ModelSE", "MeasureSEBasis")])
#> # A tibble: 6 × 6
#>   Level PrimaryMeasure Measure MeasureBasis    ModelSE MeasureSEBasis           
#>   <chr>          <dbl>   <dbl> <chr>             <dbl> <chr>                    
#> 1 P015            2.37    2.37 Fitted estimate   0.764 Fitted measure or unavai…
#> 2 P045            2.26    2.26 Fitted estimate   0.769 Fitted measure or unavai…
#> 3 P036            1.65    1.65 Fitted estimate   0.585 Fitted measure or unavai…
#> 4 P030            1.59    1.59 Fitted estimate   0.584 Fitted measure or unavai…
#> 5 P027            1.44    1.44 Fitted estimate   0.548 Fitted measure or unavai…
#> 6 P013            1.16    1.16 Fitted estimate   0.555 Fitted measure or unavai…
# ModelSE describes the adjusted total when MeasureBasis says extrapolation
```
