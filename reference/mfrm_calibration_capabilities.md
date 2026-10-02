# Portable fixed-calibration capabilities

Returns the model and estimator combinations supported by the portable
calibration workflow. This matrix concerns saved calibration artifacts;
it does not replace the wider fitted-object capabilities of
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
or
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md).
For JML fits, fitted-object scoring is post-hoc EAP with a
standard-normal reference prior by default, or an explicit
`scoring_prior`. It is not ML/WLE scoring or a population distribution
estimated by JML. Portable extraction supports RSM/PCM and shared-owner
GPCM JML within their distinct source-check scopes. No artifact stores
training Person estimates.

## Usage

``` r
mfrm_calibration_capabilities()
```

## Value

A data frame with one row per model, estimator, and scoring-basis
combination. `PortableCalibration` is either `"available"` or
`"unavailable"`; the listed scope and source checks still apply.

## Examples

``` r
mfrm_calibration_capabilities()
#>                 Model     Estimator                              ScoringBasis
#> 1                 RSM           MML                     fixed standard normal
#> 2                 PCM           MML                     fixed standard normal
#> 3             RSM/PCM           MML estimated population or latent regression
#> 4                GPCM           MML    frozen estimated intercept-only normal
#> 5             RSM/PCM           JML        post-hoc standard normal reference
#> 6                GPCM           JML        post-hoc standard normal reference
#> 7                GPCM Corrected JML        post-hoc standard normal reference
#> 8 GPCM (two families)           MML                     fixed standard normal
#>   PortableCalibration                          AnchorSupport
#> 1           available  stored direct and group facet anchors
#> 2           available  stored direct and group facet anchors
#> 3         unavailable not available for portable calibration
#> 4           available                          not supported
#> 5           available                          not supported
#> 6           available                          not supported
#> 7           available                          not supported
#> 8           available                          not supported
#>                       InteractionSupport
#> 1      stored two-way facet interactions
#> 2      stored two-way facet interactions
#> 3 not available for portable calibration
#> 4                          not supported
#> 5                          not supported
#> 6                          not supported
#> 7                          not supported
#> 8                          not supported
#>                                                                 ExistingAlternative
#> 1                                        portable artifact or fitted-object scoring
#> 2                                        portable artifact or fitted-object scoring
#> 3                        use fitted-object scoring with the fitted population model
#> 4                       conditional portable artifact or fitted-object GPCM scoring
#> 5                       portable artifact or fitted-object post-hoc EAP; not ML/WLE
#> 6           conditional portable artifact or fitted-object post-hoc EAP; not ML/WLE
#> 7 experimental corrected calibration with post-hoc EAP; not corrected Person ML/WLE
#> 8                 experimental two-family conditional artifact or fitted-object EAP
#>                                                                                                                                                                                                                                  Limitation
#> 1                                                                                                                           one observed score scale, one latent dimension, known facet levels, and an explicit same-data quadrature review
#> 2                                                                                                                           one observed score scale, one latent dimension, known facet levels, and an explicit same-data quadrature review
#> 3                                                                                                                                                               population coding and conditional parameters are not stored in the artifact
#> 4                                                                                                                              passing conditional source checks; known levels, unit weights, no anchors, interactions or latent regression
#> 5                                                                                                                   finite identified RSM/PCM JML source; unit weights, no anchors or interactions; reference prior is not estimated by JML
#> 6                                                                                                                  shared owners, unit weights, no anchors/interactions; passing local JML checks; incomplete global audits remain recorded
#> 7                                                                              shared owners; explicit correction order; passing adjusted-equation/root checks; residual calibration bias may remain; no calibration uncertainty propagated
#> 8 two ordered slope owners, second-owner steps, fixed N(0,1), known levels, unit weights and passing source/batch checks; no prior override or repeated-event extension; calibration uncertainty and population transport are not qualified
```
