# Facet-quality dashboard for facet-level screening

Build a compact dashboard for one facet at a time, combining facet
severity, misfit, central-tendency screening, and optional bias counts.

## Usage

``` r
facet_quality_dashboard(
  fit,
  diagnostics = NULL,
  facet = NULL,
  bias_results = NULL,
  severity_warn = 1,
  misfit_warn = NULL,
  central_tendency_max = 0.25,
  bias_count_warn = 1L,
  bias_abs_t_warn = 2,
  bias_abs_size_warn = 0.5,
  bias_p_max = 0.05
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- facet:

  Optional facet name. When `NULL`, the function tries to infer a
  rater-like facet and otherwise falls back to the first modeled facet.

- bias_results:

  Optional output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  or a named list of such outputs. Non-matching bundles are skipped
  quietly.

- severity_warn:

  Absolute estimate cutoff used to flag severity outliers.

- misfit_warn:

  Mean-square cutoff used to flag misfit. Values above this cutoff or
  below its reciprocal are flagged.

- central_tendency_max:

  Absolute estimate cutoff used to flag central tendency. Levels near
  zero are marked.

- bias_count_warn:

  Minimum flagged-bias row count required to flag a level.

- bias_abs_t_warn:

  Absolute `t` cutoff used when deriving bias-row flags from a raw bias
  bundle.

- bias_abs_size_warn:

  Absolute bias-size cutoff used when deriving bias-row flags from a raw
  bias bundle.

- bias_p_max:

  Probability cutoff used when deriving bias-row flags from a raw bias
  bundle.

## Value

An object of class `mfrm_facet_dashboard` (also inheriting from
`mfrm_bundle` and `list`). The object summarizes one target facet:
`overview` reports the facet-level screening totals, `summary` provides
aggregate estimates and flag counts, `detail` contains one row per facet
level with the computed screening indicators, `ranked` orders levels by
review priority, `flagged` keeps only levels requiring follow-up,
`bias_sources` records which bias-result bundles contributed to the
counts, `settings` stores the resolved thresholds, and `notes` gives
short interpretation messages about how to read the dashboard.

## Details

The dashboard screens individual facet elements across four
complementary criteria:

- **Severity**: elements with \\\|\mathrm{Estimate}\| \>\\
  `severity_warn` logits are flagged as unusually harsh or lenient.

- **Misfit**: elements with Infit or Outfit MnSq outside the configured
  heuristic review band are flagged. The band defaults to the package
  pair returned by
  [`mfrm_misfit_thresholds()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_misfit_thresholds.md)
  (Linacre 0.5-1.5); pass `misfit_warn = 1.5` to keep the older
  symmetric \\\[1/\\`misfit_warn`\\,\\\\`misfit_warn`\\\]\\ form
  (0.67-1.5).

- **Central tendency**: elements with \\\|\mathrm{Estimate}\| \<\\
  `central_tendency_max` logits are flagged. Near-zero estimates may
  indicate a rater who avoids extreme categories, producing artificially
  narrow score ranges.

- **Bias**: elements involved in \\\ge\\ `bias_count_warn`
  screen-positive interaction cells (from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md))
  are flagged.

A **flag density** score counts how many of the four criteria each
element triggers. Elements flagged on multiple criteria warrant priority
review and may motivate training or a documented data-quality review;
the dashboard does not justify automatic row, person, or rater
exclusion.

Default thresholds are screening heuristics. Prespecify and justify any
application-specific alternatives rather than treating them as universal
validity or acceptance criteria.

## Output

The returned object is a bundle-like list with class
`mfrm_facet_dashboard` and components:

- `facet`: character scalar naming the dashboard's target facet

- `facet_source`: character scalar describing whether the target facet
  was inferred from the fit configuration or supplied explicitly

- `overview`: one-row structural overview

- `summary`: one-row screening summary

- `detail`: level-level detail table

- `ranked`: detail ordered by flag density / severity

- `flagged`: flagged levels only

- `bias_sources`: per-bundle bias aggregation metadata

- `settings`: resolved threshold settings

- `notes`: short interpretation notes

- `diagnostics`: the `mfrm_diagnostics` bundle the dashboard was built
  from (echoed for downstream helpers that need to traverse the same
  diagnostics object)

- `bias_results`: the `mfrm_bias` bundle (or list of bundles) when
  `bias_results` was supplied; `NULL` otherwise

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
toy <- toy[toy$Person %in% unique(toy$Person)[1:8], ]
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
dash <- facet_quality_dashboard(fit, diagnostics = diag)
summary(dash)
#> mfrmr Facet Quality Dashboard Summary
#> 
#> Overview
#>  Facet FacetSource Levels FlaggedLevels BiasSourceBundles
#>  Rater    inferred      4             2                 0
#> 
#> Summary
#>  Facet Levels MeanEstimate   SD MinEstimate MaxEstimate MeanInfit MeanOutfit
#>  Rater      4            0 0.26      -0.322       0.315     0.997      0.978
#>  SeverityFlagged MisfitFlagged CentralTendencyFlagged BiasFlagged AnyFlagged
#>                0             0                      2           0          2
#>  BiasRows
#>         0
#> 
#> Flagged levels
#>  Facet Level Estimate N.x    SE ModelSE RealSE                     SE_Method
#>  Rater   R01    0.003  32 0.252   0.252  0.289 Observation-table information
#>  Rater   R02    0.003  32 0.252   0.252  0.252 Observation-table information
#>  Converged InferenceReady ConvergenceSeverity PrecisionTier
#>       TRUE           TRUE                pass   exploratory
#>       TRUE           TRUE                pass   exploratory
#>  SupportsFormalInference          SEUse
#>                    FALSE screening_only
#>                    FALSE screening_only
#>                                                CIBasis          CIUse N.y Infit
#>  Normal interval from exploratory observation-table SE screening_only  32 1.321
#>  Normal interval from exploratory observation-table SE screening_only  32 0.943
#>  Outfit InfitZSTD OutfitZSTD DF_Infit DF_Outfit N.x.x ObservedAverage
#>   1.277     0.937      1.101   15.765        32    32            2.75
#>   0.912    -0.046     -0.278   15.765        32    32            2.75
#>  ExpectedAverage Bias MeanResidual MeanStdResidual MeanAbsStdResidual  ChiSq
#>             2.75    0            0          -0.026              0.922 40.856
#>             2.75    0            0           0.011              0.779 29.192
#>  ChiDf  ChiP SE_Residual t_Residual p_Residual SE_StdResidual t_StdResidual
#>     31 0.111       0.124          0          1          0.177        -0.149
#>     31 0.559       0.124          0          1          0.177         0.063
#>  p_StdResidual DF PTMEA N.y.y CI_Lower CI_Upper CI_Level            CI_Method
#>          0.882 31 0.609    32    -0.49    0.497     0.95 Normal approximation
#>          0.950 31 0.667    32    -0.49    0.497     0.95 Normal approximation
#>  CIEligible                              CILabel  N AbsEstimate SeverityFlag
#>       FALSE Approximate interval; screening only 32       0.003        FALSE
#>       FALSE Approximate interval; screening only 32       0.003        FALSE
#>  MisfitFlag CentralTendencyFlag BiasCount BiasSources BiasFlag FlagCount
#>       FALSE                TRUE         0           0    FALSE         1
#>       FALSE                TRUE         0           0    FALSE         1
#>  AnyFlag FlagLabel .AbsEstimate
#>     TRUE   central        0.003
#>     TRUE   central        0.003
#> 
#> Settings
#>               Setting    Value
#>                 facet    Rater
#>          facet_source inferred
#>         severity_warn        1
#>           misfit_warn      1.5
#>  central_tendency_max     0.25
#>       bias_count_warn        1
#>       bias_abs_t_warn        2
#>    bias_abs_size_warn      0.5
#>            bias_p_max     0.05
#>   bias_source_bundles        0
#> 
#> Notes
#>  - Dashboard constructed successfully.
# }
```
