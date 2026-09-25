# Review MML sensitivity to the quadrature grid

Refit one ordered-response MML model to the same supplied response data
at two or more Gauss–Hermite quadrature counts. The original fit is
reused at its own quadrature count; all other fits reuse its stored
model, identification, anchor, interaction, optimizer, and population
settings.

## Usage

``` r
mml_quadrature_sensitivity(
  fit,
  data,
  quad_points = c(31L, 41L),
  theta_range = c(-4, 4),
  theta_points = 161L,
  adaptive_quad_points = NULL
)

gpcm_mml_quadrature_sensitivity(
  fit,
  data,
  quad_points = c(31L, 41L),
  theta_range = c(-4, 4),
  theta_points = 161L,
  adaptive_quad_points = NULL
)
```

## Arguments

- fit:

  An RSM, PCM, or GPCM MML `mfrm_fit` returned by
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
  `gpcm_mml_quadrature_sensitivity()` accepts only GPCM fits.

- data:

  The original response data.frame used to create `fit`. Prepared
  response rows are compared semantically after refitting; row order may
  differ, but changed observations fail closed.

- quad_points:

  At least two distinct positive integers, including the quadrature
  count stored on `fit`. The default `c(31, 41)` is a comparison
  starting point, not a claim that either grid is adequate for the data.
  Refits retain the source fit's fixed or adaptive integration mode.

- theta_range:

  Two finite values defining the common ability grid used for fitted
  category-probability comparison.

- theta_points:

  Number of common-grid ability points; at least 21.

- adaptive_quad_points:

  Optional vector of at least two distinct integer orders \>= 3, for
  example `c(31, 61)`. Adds a per-Person `quadrature_review` at each
  fit's fixed parameters, comparing a fixed-prior grid with
  mode/curvature-adapted grids. This separates integration error from
  parameter changes during refitting. Inspect changes between adaptive
  orders too; neither grid is certified exact.

## Value

An object of class `mfrm_quadrature_sensitivity` containing:

- `summary`: one comparison row per quadrature grid relative to the
  original fit, including likelihood, measurement-coordinate,
  probability, EAP, and posterior-SD changes;

- `quadrature_review`: when requested, unrounded per-Person
  fixed/adaptive log-marginal, EAP and posterior-SD differences,
  adaptive-order changes, mode/curvature and computation status.
  Unavailable rows retain their reason.
  [`summary()`](https://rdrr.io/r/base/summary.html) also supplies a
  compact `quadrature_overview`;

- `runs`: likelihood, gradient, curvature, population-scale, and
  readiness details for each fit;

- `slopes`: relative-slope estimates, raw diagnostic SEs and freshly
  checked 95% model intervals. The summary reports endpoint changes
  among jointly eligible levels and counts changes in interval
  availability;

- `conditions`: warnings and messages emitted by the explicit refits;

- `fits`: the reference and refitted `mfrm_fit` objects;

- `settings` and `notes`: the fixed comparison contract and
  interpretation boundary.

The object supports [`print()`](https://rdrr.io/r/base/print.html),
[`summary()`](https://rdrr.io/r/base/summary.html),
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html), and the
existing
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
list route (for example `apa_table(out)`).

## Details

This is an explicit refit diagnostic: neither
[`summary.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md)
nor
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
invokes it automatically. It reports continuous changes rather than
classifying a fit as quadrature-stable or unstable. In particular, it
does not set a practical cutoff, promote slope standard errors, or
override the fit-readiness record.

The probability comparison evaluates every observed combination of
non-Person facet levels on the same theta grid. It includes fitted
two-way facet interactions and, for GPCM, the complete-predictor slope
action. Same-Person EAP and posterior-SD changes use each fit's
corresponding quadrature count. A one-point grid has no public scoring
route, so those two changes are `NA` when it is the reference.

Explicit intercept-only and covariate population models reuse the
retained person table, factor coding and formula, with design equality
checked by Person. Older fits without that data cannot be replayed.

Raw slope and population-SD standard errors are computed from each local
observed-information Hessian for diagnostic comparison only. The public
parameter-level `SEEligible` state remains unchanged.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(
  toy, "Person", c("Rater", "Criterion"), "Score",
  method = "MML", model = "RSM",
  quad_points = 31
)
sensitivity <- mml_quadrature_sensitivity(
  fit, toy, quad_points = c(31, 41), adaptive_quad_points = c(31, 61)
)
summary(sensitivity)
#> RSM-MML quadrature sensitivity summary
#>  ReferenceNodes ComparedGrids AllEstimationConverged AllHessiansFullRank
#>              31             2                   TRUE                TRUE
#>  MaxNLLAbsChangePerPerson MaxMeasurementParameterAbsChange MaxSlopeAbsChange
#>                   0.00039                          0.00215                NA
#>  MaxPopulationSDAbsChange MaxProbabilityAbsChange MaxEAPAbsChange
#>                         0                 0.00072         0.00756
#>  MaxPosteriorSDAbsChange
#>                  0.01155
#> 
#> Grid comparisons
#>  Model ReferenceNodes Nodes IsReference NLLChangePerPerson
#>    RSM             31    31        TRUE            0.00000
#>    RSM             31    41       FALSE            0.00039
#>  NLLAbsChangePerPerson MeasurementParameterMaxAbsChange SlopeMaxAbsChange
#>                0.00000                          0.00000                NA
#>                0.00039                          0.00215                NA
#>  RawSlopeSEMaxAbsChange SlopeIntervalMaxAbsChange
#>                      NA                        NA
#>                      NA                        NA
#>  SlopeIntervalEligibilityChanged PopulationSDAbsChange
#>                               NA                     0
#>                               NA                     0
#>  RawPopulationSDSEAbsChange ProbabilityMaxAbsChange EAPMaxAbsChange
#>                          NA                 0.00000         0.00000
#>                          NA                 0.00072         0.00756
#>  PosteriorSDMaxAbsChange
#>                  0.00000
#>                  0.01155
#> 
#> Fixed-parameter integration review (adaptive minus fixed)
#>  FixedNodes AdaptiveNodes Persons Unavailable MaxAbsLogMarginalChange
#>          31            31      48           0             0.010239937
#>          41            31      48           0             0.002018021
#>          31            61      48           0             0.010239937
#>          41            61      48           0             0.002018021
#>  MaxAbsEAPChange MaxAbsSDChange
#>      0.009191803    0.015226750
#>      0.002018215    0.003787628
#>      0.009191803    0.015226750
#>      0.002018215    0.003787628
#> Inspect $quadrature_review for adaptive-order changes and unavailable rows.
#> No automatic stability classification or readiness change is applied.
# Preserve small numerical differences when preparing the sensitivity table.
apa_table(sensitivity, digits = 5)
#>  Model ReferenceNodes Nodes IsReference NLLChangePerPerson
#>    RSM             31    31        TRUE            0.00000
#>    RSM             31    41       FALSE            0.00039
#>  NLLAbsChangePerPerson MeasurementParameterMaxAbsChange SlopeMaxAbsChange
#>                0.00000                          0.00000                NA
#>                0.00039                          0.00215                NA
#>  RawSlopeSEMaxAbsChange SlopeIntervalMaxAbsChange
#>                      NA                        NA
#>                      NA                        NA
#>  SlopeIntervalEligibilityChanged PopulationSDAbsChange
#>                               NA                     0
#>                               NA                     0
#>  RawPopulationSDSEAbsChange ProbabilityMaxAbsChange EAPMaxAbsChange
#>                          NA                 0.00000         0.00000
#>                          NA                 0.00072         0.00756
#>  PosteriorSDMaxAbsChange
#>                  0.00000
#>                  0.01155
# }
```
