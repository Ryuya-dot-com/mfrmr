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
the imported EAP estimates. Person `Extreme` flags use observed
responses and each item's fitted category support, including unobserved
categories. `NObserved` counts responses used for this check.
`ResponseStatus` distinguishes observed, entirely missing, and
unavailable response information. Entirely missing or unverifiable rows
have `Extreme = NA`; finite posterior scores do not imply nonextreme
data. Re-import older TAM objects to recover these flags; saved imported
objects without the source responses cannot reconstruct them.

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
if (requireNamespace("TAM", quietly = TRUE)) {
  response_matrix <- matrix(sample(0:3, 60, replace = TRUE), nrow = 20)
  colnames(response_matrix) <- paste0("Item", seq_len(ncol(response_matrix)))
  fit <- TAM::tam.mml(resp = response_matrix, irtmodel = "PCM")
  imported <- import_tam_fit(fit, model = "PCM")
  imported$summary
}
#> ....................................................
#> Processing Data      2026-10-27 13:32:58.37419 
#>     * Response Data: 20 Persons and  3 Items 
#>     * Numerical integration with 21 nodes
#>     * Created Design Matrices   ( 2026-10-27 13:32:58.375401 )
#>     * Calculated Sufficient Statistics   ( 2026-10-27 13:32:58.376473 )
#> ....................................................
#> Iteration 1     2026-10-27 13:32:58.377672
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 174.8739
#>   Maximum item intercept parameter change: 0.81675
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.166609
#> ....................................................
#> Iteration 2     2026-10-27 13:32:58.379194
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 168.7498 | Absolute change: 6.1241 | Relative change: 0.03629098
#>   Maximum item intercept parameter change: 0.159987
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.230348
#> ....................................................
#> Iteration 3     2026-10-27 13:32:58.379703
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 166.8102 | Absolute change: 1.9396 | Relative change: 0.0116274
#>   Maximum item intercept parameter change: 0.093208
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.133636
#> ....................................................
#> Iteration 4     2026-10-27 13:32:58.380172
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 165.6773 | Absolute change: 1.1329 | Relative change: 0.00683812
#>   Maximum item intercept parameter change: 0.063102
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.084584
#> ....................................................
#> Iteration 5     2026-10-27 13:32:58.380648
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 164.9617 | Absolute change: 0.7156 | Relative change: 0.00433773
#>   Maximum item intercept parameter change: 0.045334
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.057606
#> ....................................................
#> Iteration 6     2026-10-27 13:32:58.381099
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 164.4812 | Absolute change: 0.4805 | Relative change: 0.0029215
#>   Maximum item intercept parameter change: 0.032153
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.041472
#> ....................................................
#> Iteration 7     2026-10-27 13:32:58.381551
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 164.1433 | Absolute change: 0.3379 | Relative change: 0.00205853
#>   Maximum item intercept parameter change: 0.025284
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.031124
#> ....................................................
#> Iteration 8     2026-10-27 13:32:58.382
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 163.8966 | Absolute change: 0.2467 | Relative change: 0.00150522
#>   Maximum item intercept parameter change: 0.020316
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.024168
#> ....................................................
#> Iteration 9     2026-10-27 13:32:58.382445
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 163.7108 | Absolute change: 0.1858 | Relative change: 0.00113519
#>   Maximum item intercept parameter change: 0.017122
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.0193
#> ....................................................
#> Iteration 10     2026-10-27 13:32:58.382905
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 163.5668 | Absolute change: 0.1439 | Relative change: 0.00087993
#>   Maximum item intercept parameter change: 0.014514
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.015794
#> ....................................................
#> Iteration 11     2026-10-27 13:32:58.383361
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 163.4522 | Absolute change: 0.1146 | Relative change: 0.00070108
#>   Maximum item intercept parameter change: 0.011953
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.013232
#> ....................................................
#> Iteration 12     2026-10-27 13:32:58.383823
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 163.3584 | Absolute change: 0.0938 | Relative change: 0.00057432
#>   Maximum item intercept parameter change: 0.011053
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.011328
#> ....................................................
#> Iteration 13     2026-10-27 13:32:58.384268
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 163.2789 | Absolute change: 0.0795 | Relative change: 0.00048672
#>   Maximum item intercept parameter change: 0.008958
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.009938
#> ....................................................
#> Iteration 14     2026-10-27 13:32:58.384727
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 163.2092 | Absolute change: 0.0697 | Relative change: 0.00042725
#>   Maximum item intercept parameter change: 0.008147
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.008923
#> ....................................................
#> Iteration 15     2026-10-27 13:32:58.385155
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 163.1454 | Absolute change: 0.0639 | Relative change: 0.0003914
#>   Maximum item intercept parameter change: 0.007625
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.008223
#> ....................................................
#> Iteration 16     2026-10-27 13:32:58.38561
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 163.0839 | Absolute change: 0.0614 | Relative change: 0.0003766
#>   Maximum item intercept parameter change: 0.007373
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.007795
#> ....................................................
#> Iteration 17     2026-10-27 13:32:58.38605
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 163.0214 | Absolute change: 0.0625 | Relative change: 0.00038362
#>   Maximum item intercept parameter change: 0.007234
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.007625
#> ....................................................
#> Iteration 18     2026-10-27 13:32:58.386492
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 162.9533 | Absolute change: 0.0681 | Relative change: 0.00041779
#>   Maximum item intercept parameter change: 0.007363
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.007726
#> ....................................................
#> Iteration 19     2026-10-27 13:32:58.386919
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 162.873 | Absolute change: 0.0803 | Relative change: 0.00049283
#>   Maximum item intercept parameter change: 0.007784
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.008152
#> ....................................................
#> Iteration 20     2026-10-27 13:32:58.38734
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 162.7687 | Absolute change: 0.1043 | Relative change: 0.000641
#>   Maximum item intercept parameter change: 0.008635
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.009023
#> ....................................................
#> Iteration 21     2026-10-27 13:32:58.387778
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 162.6153 | Absolute change: 0.1534 | Relative change: 0.00094354
#>   Maximum item intercept parameter change: 0.010125
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.010585
#> ....................................................
#> Iteration 22     2026-10-27 13:32:58.388207
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 162.3497 | Absolute change: 0.2656 | Relative change: 0.00163576
#>   Maximum item intercept parameter change: 0.013183
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.013342
#> ....................................................
#> Iteration 23     2026-10-27 13:32:58.388672
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 161.7721 | Absolute change: 0.5776 | Relative change: 0.00357023
#>   Maximum item intercept parameter change: 0.018421
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.018355
#> ....................................................
#> Iteration 24     2026-10-27 13:32:58.389109
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 160.0212 | Absolute change: 1.751 | Relative change: 0.01094209
#>   Maximum item intercept parameter change: 0.027649
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.027081
#> ....................................................
#> Iteration 25     2026-10-27 13:32:58.389547
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 151.8892 | Absolute change: 8.132 | Relative change: 0.053539
#>   Maximum item intercept parameter change: 0.032823
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.030413
#> ....................................................
#> Iteration 26     2026-10-27 13:32:58.38999
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 107.4521 | Absolute change: 44.4371 | Relative change: 0.4135527
#>   Maximum item intercept parameter change: 0.011218
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.002618
#> ....................................................
#> Iteration 27     2026-10-27 13:32:58.390414
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 81.7316 | Absolute change: 25.7205 | Relative change: 0.3146947
#>   Maximum item intercept parameter change: 0.00114
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 28     2026-10-27 13:32:58.39086
#> E Step
#> M Step Intercepts   |--
#>   Deviance = 81.7316 | Absolute change: 0 | Relative change: 1.2e-07
#>   Maximum item intercept parameter change: 0.000308
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 29     2026-10-27 13:32:58.391207
#> E Step
#> M Step Intercepts   |--
#>   Deviance = 81.7316 | Absolute change: 0 | Relative change: 1e-08
#>   Maximum item intercept parameter change: 0.000177
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 30     2026-10-27 13:32:58.391554
#> E Step
#> M Step Intercepts   |-
#>   Deviance = 81.7316 | Absolute change: 0 | Relative change: 0
#>   Maximum item intercept parameter change: 9.7e-05
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Item Parameters
#>   xsi.index  xsi.label     est
#> 1         1 Item1_Cat1 -0.4054
#> 2         2 Item1_Cat2 -0.0001
#> 3         3 Item1_Cat3  0.4055
#> 4         4 Item2_Cat1 -0.4055
#> 5         5 Item2_Cat2 -0.1541
#> 6         6 Item2_Cat3  0.8472
#> 7         7 Item3_Cat1  0.0000
#> 8         8 Item3_Cat2  0.4055
#> 9         9 Item3_Cat3  0.0000
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
#> Start:  2026-10-27 13:32:58.373783
#> End:  2026-10-27 13:32:58.395094 
#> Time difference of 0.02131081 secs
#> 
#>   Model Method Source  N Persons Facets Categories    LogLik      AIC      BIC
#> 1   PCM    MML    TAM 20      20      1         NA -40.86579 101.7316 111.6889
#>        ICContractVersion ICEligible ICSelectable                    ICStatus
#> 1 external_native_tam_v1      FALSE        FALSE imported_native_descriptive
#>   NativeDeviance NativeLogLik NativeNpar NativeICSampleSize NativeAIC NativeBIC
#> 1       81.73158    -40.86579         10                 20  101.7316  111.6889
#>   NativeABIC     NativeAICFormula          NativeBICFormula
#> 1   78.85476 tam_deviance_plus_2k tam_deviance_plus_log_n_k
#>                           NativeABICFormula NativeAICFormulaVerified
#> 1 tam_deviance_plus_log_n_minus_2_over_24_k                     TRUE
#>   NativeBICFormulaVerified NativeABICFormulaVerified
#> 1                     TRUE                      TRUE
#>   NativeLogLikDevianceConsistent NativePersonCountConsistent Converged
#> 1                           TRUE                        TRUE      TRUE
#>                               ConvergenceStatus Iterations IterationCeiling
#> 1 imported_tam_stopped_before_iteration_ceiling         30             1000
```
