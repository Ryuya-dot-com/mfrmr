# Review GPCM-MML sensitivity to the quadrature grid

Refit one bounded GPCM-MML model to the same supplied response data at
two or more Gauss–Hermite quadrature counts. The original fit is reused
at its own quadrature count; all other fits reuse its stored model,
identification, anchor, optimizer, and population settings.

## Usage

``` r
gpcm_mml_quadrature_sensitivity(
  fit,
  data,
  quad_points = c(31L, 41L),
  theta_range = c(-4, 4),
  theta_points = 161L
)
```

## Arguments

- fit:

  A GPCM MML `mfrm_fit` returned by
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- data:

  The original response data.frame used to create `fit`. Prepared
  response rows are compared semantically after refitting; row order may
  differ, but changed observations fail closed.

- quad_points:

  At least two distinct positive integers, including the quadrature
  count stored on `fit`. A common choice is `c(31, 41)`.

- theta_range:

  Two finite values defining the common ability grid used for fitted
  category-probability comparison.

- theta_points:

  Number of common-grid ability points; at least 21.

## Value

An object of class `mfrm_quadrature_sensitivity` containing:

- `summary`: one comparison row per quadrature grid relative to the
  original fit;

- `runs`: likelihood, gradient, curvature, population-scale, and
  readiness details for each fit;

- `slopes`: relative-slope estimates and raw diagnostic SEs;

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
non-Person facet levels on the same theta grid. It therefore exercises
the complete-predictor GPCM slope action, including additive Rater and
Criterion locations. The first version fails closed for fitted facet
interactions rather than approximating their contribution.

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
  method = "MML", model = "GPCM",
  step_facet = "Criterion", slope_facet = "Criterion",
  quad_points = 31
)
sensitivity <- gpcm_mml_quadrature_sensitivity(
  fit, toy, quad_points = c(31, 41)
)
summary(sensitivity)
#> GPCM-MML quadrature sensitivity summary
#>  ReferenceNodes ComparedGrids AllEstimationConverged AllHessiansFullRank
#>              31             2                   TRUE                TRUE
#>  MaxNLLAbsChangePerPerson MaxSlopeAbsChange MaxPopulationSDAbsChange
#>                   0.00022           0.00123                  0.00367
#>  MaxProbabilityAbsChange               StabilityClassification
#>                  0.00045 not_assigned_continuous_evidence_only
#>       ReadinessEffect
#>  none_diagnostic_only
#> 
#> Grid comparisons
#>  ReferenceNodes Nodes IsReference NLLChangePerPerson NLLAbsChangePerPerson
#>              31    31        TRUE            0.00000               0.00000
#>              31    41       FALSE            0.00022               0.00022
#>  SlopeMaxAbsChange RawSlopeSEMaxAbsChange PopulationSDAbsChange
#>            0.00000                  0e+00               0.00000
#>            0.00123                  8e-05               0.00367
#>  RawPopulationSDSEAbsChange ProbabilityMaxAbsChange
#>                     0.00000                 0.00000
#>                     0.00445                 0.00045
# Preserve small numerical differences when preparing the sensitivity table.
apa_table(sensitivity, digits = 5)
#>  ReferenceNodes Nodes IsReference NLLChangePerPerson NLLAbsChangePerPerson
#>              31    31        TRUE            0.00000               0.00000
#>              31    41       FALSE            0.00022               0.00022
#>  SlopeMaxAbsChange RawSlopeSEMaxAbsChange PopulationSDAbsChange
#>            0.00000                  0e+00               0.00000
#>            0.00123                  8e-05               0.00367
#>  RawPopulationSDSEAbsChange ProbabilityMaxAbsChange
#>                     0.00000                 0.00000
#>                     0.00445                 0.00045
# }
```
