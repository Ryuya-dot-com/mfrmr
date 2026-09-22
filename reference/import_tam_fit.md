# Import a `TAM` fit to an mfrmr-compatible bundle

Extracts item / step / person parameters from a unidimensional
[`TAM::tam.mml()`](https://rdrr.io/pkg/TAM/man/tam.mml.html) or
[`TAM::tam.mml.mfr()`](https://rdrr.io/pkg/TAM/man/tam.mml.html) fit.
Difficulties and absolute adjacent-category thresholds are derived from
the source category logits, rather than inferred from coefficient names.
Source slopes and scale identification are retained.

## Usage

``` r
import_tam_fit(
  fit,
  model = c("RSM", "PCM", "GPCM"),
  item_facet = "Item",
  compute_fit = FALSE
)
```

## Arguments

- fit:

  An object returned by
  [`TAM::tam.mml()`](https://rdrr.io/pkg/TAM/man/tam.mml.html) or
  [`TAM::tam.mml.mfr()`](https://rdrr.io/pkg/TAM/man/tam.mml.html).

- model:

  Declared response model: `"RSM"`, `"PCM"`, or `"GPCM"`. Non-unit
  source slopes require `"GPCM"`; import does not reconstruct all source
  constraints or certify equivalence to a native mfrmr model.

- item_facet:

  Name to assign to the item facet for the single-facet path. Ignored
  when the input is a multi-facet `tam.mml.mfr` fit, whose combined
  response conditions are labelled `"DesignCell"`.

- compute_fit:

  Logical. When `TRUE`, run
  [`TAM::msq.itemfit()`](https://rdrr.io/pkg/TAM/man/msq.itemfit.html)
  and
  [`TAM::tam.personfit()`](https://rdrr.io/pkg/TAM/man/tam.personfit.html)
  to populate Infit / Outfit columns on the returned facet tables, plus
  build a measurement-side `mfrm_diagnostics` bundle. Default `FALSE`.

## Value

An `mfrm_imported_fit` object. Slots mirror
[`import_mirt_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_mirt_fit.md),
with explicit TAM-native IC provenance in `summary` and `source`.

## Details

Each item difficulty is the mean of its absolute adjacent-category
thresholds. Positive constant adjacent-category slopes are required. For
multi-facet fits, each returned difficulty combines all facet effects
for that response condition. Separate facet coordinates are not
reconstructed; the original coefficient table remains in
`source$native_parameters`.

A transformed item SE is retained only when the location is a scalar
multiple of one source coefficient and its slope is fixed. Otherwise it
is missing: marginal coefficient SEs cannot replace the required joint
covariance. Persons retain source EAP and conditional posterior SD. Item
fit is averaged over source posteriors;
[`TAM::tam.personfit()`](https://rdrr.io/pkg/TAM/man/tam.personfit.html)
uses WLE scores. `FitBasis` records this distinction without replacing
the imported EAP estimates.

The public imported-fit surface is deliberately unidimensional and
MML-only. A `tam.jml` object is not silently relabelled as MML, and a
TAM fit with `ndim > 1` is rejected rather than flattened into one mfrmr
scale. Keep multidimensional TAM fits in a separate validation workflow.

TAM-native AIC, BIC, and adjusted BIC are retained as explicitly named
`Native*` fields. Compatibility `AIC` and `BIC` columns still mirror the
native TAM values, but the imported object has
`ICStatus = "imported_native_descriptive"`, `ICEligible = FALSE`, and
cannot enter
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
as a current mfrmr IC contract. In particular, TAM's native `aBIC` is
not relabelled as the package's Sclove `SABIC`. The source metadata also
retains the TAM version, dimension count, iterations, and iteration
ceiling used for the conservative imported convergence status.

## Imported uncertainty

Imported SEs retain the source package's interpretation. The
measurement-side diagnostics do not reconstruct the joint parameter
covariance, so joint facet chi-square statistics, degrees of freedom and
p-values are unavailable. Posterior SDs do not supply sampling SEs for
separation reliability. Other separation summaries require valid SEs for
every finite estimate and remain descriptive. Imported Wright maps show
points only: source uncertainty conventions do not establish one common
confidence-interval calculation. Re-import older saved bundles from the
existing source-package fit to update difficulties, thresholds and
uncertainty labels. The mirt and TAM importers accept
`compute_fit = TRUE` when source fit statistics are needed; no model
re-estimation is required.

## Scope

Use [`summary()`](https://rdrr.io/r/base/summary.html) for source-scale
tables and [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for
a point-only Wright map. Available source fit statistics remain in the
facet and diagnostic tables. Native model curves, comprehensive
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
reports, response-level diagnostics,
[`run_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_qc_pipeline.md),
bias/DIF analysis, anchoring and portable calibration are unavailable
for imported bundles. This is a one-way fitted-object import of the
documented fields.

## See also

[`import_mirt_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_mirt_fit.md),
[`import_erm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_erm_fit.md)

## Examples

``` r
# \donttest{
if (requireNamespace("TAM", quietly = TRUE)) {
  response_matrix <- matrix(sample(0:3, 60, replace = TRUE), nrow = 20)
  colnames(response_matrix) <- paste0("Item", seq_len(ncol(response_matrix)))
  fit <- TAM::tam.mml(resp = response_matrix, irtmodel = "PCM")
  imported <- import_tam_fit(fit, model = "PCM")
  imported$summary
}
#> ....................................................
#> Processing Data      2026-09-22 11:46:21.667642 
#>     * Response Data: 20 Persons and  3 Items 
#>     * Numerical integration with 21 nodes
#>     * Created Design Matrices   ( 2026-09-22 11:46:21.668845 )
#>     * Calculated Sufficient Statistics   ( 2026-09-22 11:46:21.669927 )
#> ....................................................
#> Iteration 1     2026-09-22 11:46:21.671098
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 166.0006
#>   Maximum item intercept parameter change: 0.825458
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.170222
#> ....................................................
#> Iteration 2     2026-09-22 11:46:21.672625
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 159.9523 | Absolute change: 6.0483 | Relative change: 0.0378131
#>   Maximum item intercept parameter change: 0.740951
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.197607
#> ....................................................
#> Iteration 3     2026-09-22 11:46:21.673144
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 156.8726 | Absolute change: 3.0798 | Relative change: 0.01963247
#>   Maximum item intercept parameter change: 0.329582
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.146256
#> ....................................................
#> Iteration 4     2026-09-22 11:46:21.673652
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 155.2944 | Absolute change: 1.5781 | Relative change: 0.01016214
#>   Maximum item intercept parameter change: 0.127433
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.091922
#> ....................................................
#> Iteration 5     2026-09-22 11:46:21.67412
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 154.4537 | Absolute change: 0.8407 | Relative change: 0.00544295
#>   Maximum item intercept parameter change: 0.07696
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.062858
#> ....................................................
#> Iteration 6     2026-09-22 11:46:21.674601
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 153.8951 | Absolute change: 0.5586 | Relative change: 0.00362978
#>   Maximum item intercept parameter change: 0.051295
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.045048
#> ....................................................
#> Iteration 7     2026-09-22 11:46:21.675061
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 153.4999 | Absolute change: 0.3953 | Relative change: 0.00257495
#>   Maximum item intercept parameter change: 0.037085
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.033731
#> ....................................................
#> Iteration 8     2026-09-22 11:46:21.675524
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 153.2079 | Absolute change: 0.292 | Relative change: 0.0019059
#>   Maximum item intercept parameter change: 0.031884
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.026121
#> ....................................................
#> Iteration 9     2026-09-22 11:46:21.675969
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 152.9841 | Absolute change: 0.2238 | Relative change: 0.00146308
#>   Maximum item intercept parameter change: 0.023112
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.020888
#> ....................................................
#> Iteration 10     2026-09-22 11:46:21.67642
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 152.808 | Absolute change: 0.1761 | Relative change: 0.00115219
#>   Maximum item intercept parameter change: 0.020885
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.017098
#> ....................................................
#> Iteration 11     2026-09-22 11:46:21.676871
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 152.6645 | Absolute change: 0.1435 | Relative change: 0.00094019
#>   Maximum item intercept parameter change: 0.016319
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.014397
#> ....................................................
#> Iteration 12     2026-09-22 11:46:21.677345
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 152.5437 | Absolute change: 0.1207 | Relative change: 0.00079152
#>   Maximum item intercept parameter change: 0.014476
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.012415
#> ....................................................
#> Iteration 13     2026-09-22 11:46:21.677792
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 152.4376 | Absolute change: 0.1062 | Relative change: 0.0006964
#>   Maximum item intercept parameter change: 0.013316
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.011036
#> ....................................................
#> Iteration 14     2026-09-22 11:46:21.678256
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 152.3395 | Absolute change: 0.0981 | Relative change: 0.00064378
#>   Maximum item intercept parameter change: 0.011908
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.010121
#> ....................................................
#> Iteration 15     2026-09-22 11:46:21.678701
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 152.2431 | Absolute change: 0.0963 | Relative change: 0.00063284
#>   Maximum item intercept parameter change: 0.012422
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.009618
#> ....................................................
#> Iteration 16     2026-09-22 11:46:21.679136
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 152.1411 | Absolute change: 0.102 | Relative change: 0.00067075
#>   Maximum item intercept parameter change: 0.011445
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.009528
#> ....................................................
#> Iteration 17     2026-09-22 11:46:21.679592
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 152.0226 | Absolute change: 0.1185 | Relative change: 0.00077931
#>   Maximum item intercept parameter change: 0.011984
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.009901
#> ....................................................
#> Iteration 18     2026-09-22 11:46:21.680021
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 151.8682 | Absolute change: 0.1544 | Relative change: 0.00101693
#>   Maximum item intercept parameter change: 0.013343
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.010899
#> ....................................................
#> Iteration 19     2026-09-22 11:46:21.680481
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 151.6341 | Absolute change: 0.234 | Relative change: 0.00154344
#>   Maximum item intercept parameter change: 0.01599
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.012874
#> ....................................................
#> Iteration 20     2026-09-22 11:46:21.680914
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 151.199 | Absolute change: 0.4351 | Relative change: 0.00287775
#>   Maximum item intercept parameter change: 0.020984
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.016585
#> ....................................................
#> Iteration 21     2026-09-22 11:46:21.681363
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 150.1157 | Absolute change: 1.0834 | Relative change: 0.00721686
#>   Maximum item intercept parameter change: 0.030472
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.023463
#> ....................................................
#> Iteration 22     2026-09-22 11:46:21.681797
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 146.0336 | Absolute change: 4.082 | Relative change: 0.02795263
#>   Maximum item intercept parameter change: 0.043674
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.032382
#> ....................................................
#> Iteration 23     2026-09-22 11:46:21.682257
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 124.7457 | Absolute change: 21.2879 | Relative change: 0.1706508
#>   Maximum item intercept parameter change: 0.02252
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.014031
#> ....................................................
#> Iteration 24     2026-09-22 11:46:21.682695
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 70.539 | Absolute change: 54.2067 | Relative change: 0.7684648
#>   Maximum item intercept parameter change: 0.004438
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 25     2026-09-22 11:46:21.683126
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 70.5388 | Absolute change: 2e-04 | Relative change: 2.97e-06
#>   Maximum item intercept parameter change: 0.004757
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 26     2026-09-22 11:46:21.683587
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 70.5387 | Absolute change: 1e-04 | Relative change: 1.2e-06
#>   Maximum item intercept parameter change: 0.002646
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 27     2026-09-22 11:46:21.684021
#> E Step
#> M Step Intercepts   |---
#>   Deviance = 70.5386 | Absolute change: 0 | Relative change: 5.4e-07
#>   Maximum item intercept parameter change: 0.002382
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 28     2026-09-22 11:46:21.684425
#> E Step
#> M Step Intercepts   |---
#>   Deviance = 70.5386 | Absolute change: 0 | Relative change: 3.1e-07
#>   Maximum item intercept parameter change: 0.001668
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 29     2026-09-22 11:46:21.684815
#> E Step
#> M Step Intercepts   |---
#>   Deviance = 70.5386 | Absolute change: 0 | Relative change: 1.9e-07
#>   Maximum item intercept parameter change: 0.001401
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 30     2026-09-22 11:46:21.685229
#> E Step
#> M Step Intercepts   |--
#>   Deviance = 70.5386 | Absolute change: 0 | Relative change: 1.1e-07
#>   Maximum item intercept parameter change: 0.001011
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 31     2026-09-22 11:46:21.685584
#> E Step
#> M Step Intercepts   |---
#>   Deviance = 70.5386 | Absolute change: 0 | Relative change: 7e-08
#>   Maximum item intercept parameter change: 0.00082
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 32     2026-09-22 11:46:21.685974
#> E Step
#> M Step Intercepts   |--
#>   Deviance = 70.5386 | Absolute change: 0 | Relative change: 4e-08
#>   Maximum item intercept parameter change: 0.000588
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 33     2026-09-22 11:46:21.686342
#> E Step
#> M Step Intercepts   |---
#>   Deviance = 70.5386 | Absolute change: 0 | Relative change: 2e-08
#>   Maximum item intercept parameter change: 0.000489
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 34     2026-09-22 11:46:21.686739
#> E Step
#> M Step Intercepts   |--
#>   Deviance = 70.5386 | Absolute change: 0 | Relative change: 1e-08
#>   Maximum item intercept parameter change: 0.000361
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 35     2026-09-22 11:46:21.687101
#> E Step
#> M Step Intercepts   |--
#>   Deviance = 70.5386 | Absolute change: 0 | Relative change: 1e-08
#>   Maximum item intercept parameter change: 0.000264
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 36     2026-09-22 11:46:21.687476
#> E Step
#> M Step Intercepts   |--
#>   Deviance = 70.5386 | Absolute change: 0 | Relative change: 0
#>   Maximum item intercept parameter change: 0.00023
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 37     2026-09-22 11:46:21.687817
#> E Step
#> M Step Intercepts   |--
#>   Deviance = 70.5386 | Absolute change: 0 | Relative change: 0
#>   Maximum item intercept parameter change: 0.00016
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 38     2026-09-22 11:46:21.688159
#> E Step
#> M Step Intercepts   |--
#>   Deviance = 70.5386 | Absolute change: 0 | Relative change: 0
#>   Maximum item intercept parameter change: 0.000131
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 39     2026-09-22 11:46:21.688528
#> E Step
#> M Step Intercepts   |--
#>   Deviance = 70.5386 | Absolute change: 0 | Relative change: 0
#>   Maximum item intercept parameter change: 9.2e-05
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Item Parameters
#>   xsi.index  xsi.label     est
#> 1         1 Item1_Cat1 -1.2528
#> 2         2 Item1_Cat2  0.3365
#> 3         3 Item1_Cat3 -0.1823
#> 4         4 Item2_Cat1 -0.2876
#> 5         5 Item2_Cat2  1.3861
#> 6         6 Item2_Cat3 -0.6930
#> 7         7 Item3_Cat1 -0.5878
#> 8         8 Item3_Cat2  0.5878
#> 9         9 Item3_Cat3  1.6094
#> ...................................
#> Regression Coefficients
#>      [,1]
#> [1,]    0
#> 
#> Variance:
#>       [,1]
#> [1,] 0.001
#> 
#> 
#> EAP Reliability:
#> [1] 0
#> 
#> -----------------------------
#> Start:  2026-09-22 11:46:21.66722
#> End:  2026-09-22 11:46:21.691752 
#> Time difference of 0.02453279 secs
#> 
#>   Model Method Source  N Persons Facets Categories    LogLik      AIC      BIC
#> 1   PCM    MML    TAM 20      20      1         NA -35.26929 90.53859 100.4959
#>        ICContractVersion ICEligible ICSelectable                    ICStatus
#> 1 external_native_tam_v1      FALSE        FALSE imported_native_descriptive
#>   NativeDeviance NativeLogLik NativeNpar NativeICSampleSize NativeAIC NativeBIC
#> 1       70.53859    -35.26929         10                 20  90.53859  100.4959
#>   NativeABIC     NativeAICFormula          NativeBICFormula
#> 1   67.66177 tam_deviance_plus_2k tam_deviance_plus_log_n_k
#>                           NativeABICFormula NativeAICFormulaVerified
#> 1 tam_deviance_plus_log_n_minus_2_over_24_k                     TRUE
#>   NativeBICFormulaVerified NativeABICFormulaVerified
#> 1                     TRUE                      TRUE
#>   NativeLogLikDevianceConsistent NativePersonCountConsistent Converged
#> 1                           TRUE                        TRUE      TRUE
#>                               ConvergenceStatus Iterations IterationCeiling
#> 1 imported_tam_stopped_before_iteration_ceiling         39             1000
# }
```
