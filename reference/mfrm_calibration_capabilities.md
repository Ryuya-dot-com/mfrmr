# Portable fixed-calibration capabilities

Returns the model and estimator combinations supported by the portable
calibration workflow. This matrix concerns saved calibration artifacts;
it does not replace the wider fitted-object capabilities of
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
or
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md).

## Usage

``` r
mfrm_calibration_capabilities()
```

## Value

A data frame with one row per model, estimator, and scoring-basis
combination. `PortableCalibration` is either `"available"` or
`"unavailable"`.

## Examples

``` r
mfrm_calibration_capabilities()
#>          Model Estimator                              ScoringBasis
#> 1          RSM       MML                     fixed standard normal
#> 2          PCM       MML                     fixed standard normal
#> 3      RSM/PCM       MML estimated population or latent regression
#> 4 bounded GPCM       MML             fixed or estimated population
#> 5      RSM/PCM       JML                    post-hoc scoring prior
#> 6 bounded GPCM       JML                    post-hoc scoring prior
#>   PortableCalibration                          AnchorSupport
#> 1           available  stored direct and group facet anchors
#> 2           available  stored direct and group facet anchors
#> 3         unavailable not available for portable calibration
#> 4         unavailable not available for portable calibration
#> 5         unavailable not available for portable calibration
#> 6         unavailable not available for portable calibration
#>                       InteractionSupport
#> 1      stored two-way facet interactions
#> 2      stored two-way facet interactions
#> 3 not available for portable calibration
#> 4 not available for portable calibration
#> 5 not available for portable calibration
#> 6 not available for portable calibration
#>                                                      ExistingAlternative
#> 1                             portable artifact or fitted-object scoring
#> 2                             portable artifact or fitted-object scoring
#> 3             use fitted-object scoring with the fitted population model
#> 4                                 use fitted-object bounded-GPCM scoring
#> 5              use fitted-object scoring with an explicit post-hoc prior
#> 6 use fitted-object bounded-GPCM scoring with an explicit post-hoc prior
#>                                                                                                        Limitation
#> 1 one observed score scale, one latent dimension, known facet levels, and an explicit same-data quadrature review
#> 2 one observed score scale, one latent dimension, known facet levels, and an explicit same-data quadrature review
#> 3                                     population coding and conditional parameters are not stored in the artifact
#> 4                                                          relative-slope ownership is not stored in the artifact
#> 5                                                    source JML Person coordinates are excluded from the artifact
#> 6                                          relative slopes and a JML scoring prior are not stored in the artifact
```
