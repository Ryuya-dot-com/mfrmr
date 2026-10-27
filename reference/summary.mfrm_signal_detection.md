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

  Number of digits used when printing numeric summaries.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_signal_detection` with:

- `overview`: run-level overview

- `detection_summary`: full-precision rates by design, with
  design-variable aliases when applicable. `DIF*`, `DIFClass*` and
  `BiasScreen*` columns retain `Planned`, `Available`, `Unavailable`,
  `Positive`, `MCLower`, `MCUpper`, `AllTrialsLower` and
  `AllTrialsUpper` for target outcomes. Monte Carlo bounds are exact 95%
  binomial intervals conditional on availability; all-trial bounds
  describe unresolved outcomes, not confidence intervals.
  `DIFNonTarget*`/`BiasNonTarget*` retain summed `Planned` and
  `Available` cell counts and `AvailableReps`, the number of trials
  contributing a non-target proportion. Those proportions receive equal
  weight across contributing trials, even with unequal cell counts;
  their MCSE is the sample SD of the proportions divided by the square
  root of `AvailableReps`. `TargetContrastAvailable`,
  `TargetContrastAbsAvailable`, `TargetBiasAvailable` and
  `TargetBiasTAvailable` are denominators for the corresponding finite
  point summaries. All-missing means return `NA`.

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

- `gpcm_boundary`: `GPCM` caveat row when present

- `notes`: short interpretation notes, including the bias-side screening
  caveat

## See also

[`evaluate_mfrm_signal_detection()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_signal_detection.md),
[plot.mfrm_signal_detection](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_signal_detection.md)

## Examples

``` r
# One saved replication illustrates output structure, not precise rates.
# Regeneration recipe: examples/simulation-results.R in the package.
saved <- readRDS(system.file("examples", "simulation-signal-detection.rds",
  package = "mfrmr", mustWork = TRUE))
# Inspect saved$generation_warnings and the result's run/status tables.
sig_eval <- saved$result
summary(sig_eval)
#> mfrmr Signal Detection Summary
#> 
#> Overview
#>  Designs Replications SuccessfulRuns ConvergedRuns MeanElapsedSec
#>        1            1              1             0          0.345
#> 
#> Detection summary (preview)
#>  design_id n_person n_rater n_criterion raters_per_person DIFTargetLevel
#>        S01        8       2           2                 2            C02
#>  BiasTargetRater BiasTargetCriterion Reps ConvergenceRate McseConvergenceRate
#>              R02                 C02    1               0                  NA
#>  DIFPower McseDIFPower DIFClassificationPower McseDIFClassificationPower
#>        NA           NA                     NA                         NA
#>  MeanTargetContrast McseTargetContrast TargetContrastAvailable
#>                  NA                 NA                       0
#>  TargetContrastAbsAvailable MeanTargetContrastAbs McseTargetContrastAbs
#>                           0                    NA                    NA
#>  McseDIFFalsePositiveRate DIFFalsePositiveRate BiasScreenRate
#>                        NA                   NA              0
#>  McseBiasScreenRate TargetBiasAvailable TargetBiasTAvailable MeanTargetBias
#>                  NA                   1                    1          0.156
#>  McseTargetBias MeanAbsTargetBias McseAbsTargetBias MeanTargetBiasT
#>              NA             0.156                NA           0.278
#>  McseTargetBiasT BiasScreenMetricAvailabilityRate
#>               NA                                1
#>  McseBiasScreenMetricAvailabilityRate McseBiasScreenFalsePositiveRate
#>                                    NA                              NA
#>  BiasScreenFalsePositiveRate DIFNonTargetAvailableReps DIFNonTargetPlanned
#>                            0                         0                   1
#>  DIFNonTargetAvailable BiasNonTargetAvailableReps BiasNonTargetPlanned
#>                      0                          1                    3
#>  BiasNonTargetAvailable MeanElapsedSec McseElapsedSec DIFPlanned DIFAvailable
#>                       3          0.345             NA          1            0
#>  DIFUnavailable DIFPositive DIFMCLower DIFMCUpper DIFAllTrialsLower
#>               1           0         NA         NA                 0
#>  DIFAllTrialsUpper DIFClassPlanned DIFClassAvailable DIFClassUnavailable
#>                  1               1                 0                   1
#>  DIFClassPositive DIFClassMCLower DIFClassMCUpper DIFClassAllTrialsLower
#>                 0              NA              NA                      0
#>  DIFClassAllTrialsUpper BiasScreenPlanned BiasScreenAvailable
#>                       1                 1                   1
#>  BiasScreenUnavailable BiasScreenPositive BiasScreenMCLower BiasScreenMCUpper
#>                      0                  0                 0             0.975
#>  BiasScreenAllTrialsLower BiasScreenAllTrialsUpper
#>                         0                        0
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
#>  - DIF detection rates are unavailable. Missing test statistics and descriptive residual differences are not negative screening outcomes.
#>  - DIF contrasts are reference minus focal: residual means are in score units; refit means require documented common-scale comparability. Neither is automatically the injected linear-predictor shift.
#>  - Bias-side rates are screening summaries derived from `estimate_bias()` output and should not be interpreted as formal power or alpha-calibrated false-positive rates.
#>  - Target rates condition on available screens. Planned/available counts, exact 95% Monte Carlo bounds and all-trial unresolved-outcome bounds are retained; these do not establish general diagnostic accuracy.
#>  - Non-target rates average within-replication proportions over available cells; they are not the probability of any false flag across a family.
#>  - MCSE columns summarize finite-replication uncertainty around the reported means and rates.
#>  - Planning helpers vary one person count and two named non-person facet roles (Rater and Criterion). Estimation may contain additional facets, but planning and forecasting are limited to this role-based design.
#>  - Current scalar-argument planning paths allow `n_person`, `n_rater`, `n_criterion`, and `raters_per_person` to vary subject to `raters_per_person <= n_rater`.
#>  - Named-facet structural design metadata for person count, non-person facet counts, and assignments per person. These deterministic design summaries do not establish arbitrary-facet simulation support or parameter-recovery performance.
#>  - The structural design review reports deterministic bookkeeping and conservative design guidance, not DIF/bias detection power.
```
