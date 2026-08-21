# Summarize a DIF/bias screening simulation

Summarize a DIF/bias screening simulation

## Usage

``` r
# S3 method for class 'mfrm_signal_detection'
summary(object, digits = 3, ...)
```

## Arguments

- object:

  Output from
  [`evaluate_mfrm_signal_detection()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_signal_detection.md).

- digits:

  Number of digits used in numeric summaries.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_signal_detection` with:

- `overview`: run-level overview

- `detection_summary`: aggregated detection rates by design, with
  design-variable alias columns when applicable

- `ademp`: simulation-study metadata carried forward from the original
  object

- `facet_names`: public facet labels carried from the simulation
  specification

- `design_variable_aliases`: accepted public aliases for design
  variables

- `design_descriptor`: role-based design-variable metadata

- `planning_scope`: explicit record of the current planning contract

- `planning_constraints`: explicit record of mutable/locked design
  variables

- `planning_schema`: structured planning metadata

- `structural_design_review`: deterministic structural review of the
  named-facet design grid; it reports design bookkeeping rather than
  signal-detection performance

- `gpcm_boundary`: bounded-`GPCM` caveat row when present

- `notes`: short interpretation notes, including the bias-side screening
  caveat

## See also

[`evaluate_mfrm_signal_detection()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_signal_detection.md),
[plot.mfrm_signal_detection](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_signal_detection.md)

## Examples

``` r
# \donttest{
sig_eval <- suppressWarnings(evaluate_mfrm_signal_detection(
  n_person = 8,
  n_rater = 2,
  n_criterion = 2,
  raters_per_person = 1,
  reps = 1,
  maxit = 30,
  bias_max_iter = 1,
  seed = 123
))
summary(sig_eval)
#> mfrmr Signal Detection Summary
#> 
#> Overview
#>  Designs Replications SuccessfulRuns ConvergedRuns MeanElapsedSec
#>        1            1              0             0          0.316
#> 
#> Detection summary (preview)
#>  design_id n_person n_rater n_criterion raters_per_person DIFTargetLevel
#>        S01        8       2           2                 1            C02
#>  BiasTargetRater BiasTargetCriterion Reps ConvergenceRate McseConvergenceRate
#>              R02                 C02    1               0                  NA
#>  DIFPower McseDIFPower DIFClassificationPower McseDIFClassificationPower
#>         0           NA                      0                         NA
#>  MeanTargetContrast McseTargetContrast MeanTargetContrastAbs
#>                 NaN                 NA                   NaN
#>  McseTargetContrastAbs DIFFalsePositiveRate McseDIFFalsePositiveRate
#>                     NA                  NaN                       NA
#>  BiasScreenRate McseBiasScreenRate MeanTargetBias McseTargetBias
#>               0                 NA            NaN             NA
#>  MeanAbsTargetBias McseAbsTargetBias MeanTargetBiasT McseTargetBiasT
#>                NaN                NA             NaN              NA
#>  BiasScreenMetricAvailabilityRate McseBiasScreenMetricAvailabilityRate
#>                                 0                                   NA
#>  BiasScreenFalsePositiveRate McseBiasScreenFalsePositiveRate MeanElapsedSec
#>                          NaN                              NA          0.316
#>  McseElapsedSec
#>              NA
#> 
#> Structural design review
#>  review_available n_designs recommended_design_id   view  mode surface
#>             FALSE         0                  <NA> public brief  digest
#>  table_component RecommendedAppendixTables CompactAppendixTables NumericTables
#>             grid                         4                     3             6
#>  AnyNumericTable
#>             TRUE
#> 
#> ADEMP metadata
#>  - aims
#>  - data_generating_mechanism
#>  - estimands
#>  - methods
#>  - performance_measures
#> 
#> Notes
#>  - Some design conditions did not converge in every replication.
#>  - Some design conditions showed DIF power below 0.80.
#>  - Some design conditions showed bias-screen hit rates below 0.80.
#>  - Some design conditions did not yield usable bias-screening t/p metrics in every replication.
#>  - Bias-side rates are screening summaries derived from `estimate_bias()` output and should not be interpreted as formal power or alpha-calibrated false-positive rates.
#>  - MCSE columns summarize finite-replication uncertainty around the reported means and rates.
#>  - Planning helpers vary one person count and two named non-person facet roles (Rater and Criterion). Estimation may contain additional facets, but planning and forecasting are limited to this role-based design.
#>  - Current scalar-argument planning paths allow `n_person`, `n_rater`, `n_criterion`, and `raters_per_person` to vary subject to `raters_per_person <= n_rater`.
#>  - Named-facet structural design metadata for person count, non-person facet counts, and assignments per person. These deterministic design summaries do not establish arbitrary-facet simulation support or parameter-recovery performance.
#>  - The structural design review reports deterministic bookkeeping and conservative design guidance, not DIF/bias detection power.
# }
```
