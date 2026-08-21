# Import a `TAM` fit to an mfrmr-compatible bundle

Extracts item / step / person parameters from a unidimensional
[`TAM::tam.mml()`](https://rdrr.io/pkg/TAM/man/tam.mml.html) or
[`TAM::tam.mml.mfr()`](https://rdrr.io/pkg/TAM/man/tam.mml.html) fit.
The multi-facet `tam.mml.mfr()` path is detected automatically and each
non-person facet is mapped onto a row of `fit$facets$others` so
downstream MFRM helpers (e.g.
[`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md))
work on the imported object.

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

  Same as
  [`import_mirt_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_mirt_fit.md).

- item_facet:

  Name to assign to the item facet for the single-facet path. Ignored
  when the input is a multi-facet `tam.mml.mfr` fit (the original facet
  names are preserved).

- compute_fit:

  Logical. When `TRUE`, run
  [`TAM::tam.fit()`](https://rdrr.io/pkg/TAM/man/tam.fit.html) and
  [`TAM::tam.personfit()`](https://rdrr.io/pkg/TAM/man/tam.personfit.html)
  to populate Infit / Outfit columns on the returned facet tables, plus
  build a measurement-side `mfrm_diagnostics` bundle. Default `FALSE`.

## Value

An `mfrm_imported_fit` object. Slots mirror
[`import_mirt_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_mirt_fit.md),
with explicit TAM-native IC provenance in `summary` and `source`.

## Details

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
#> Processing Data      2026-08-21 09:34:27.236267 
#>     * Response Data: 20 Persons and  3 Items 
#>     * Numerical integration with 21 nodes
#>     * Created Design Matrices   ( 2026-08-21 09:34:27.237639 )
#>     * Calculated Sufficient Statistics   ( 2026-08-21 09:34:27.238893 )
#> ....................................................
#> Iteration 1     2026-08-21 09:34:27.240293
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 175.2548
#>   Maximum item intercept parameter change: 0.770547
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.195811
#> ....................................................
#> Iteration 2     2026-08-21 09:34:27.242223
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 163.8545 | Absolute change: 11.4003 | Relative change: 0.06957589
#>   Maximum item intercept parameter change: 0.696752
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.230473
#> ....................................................
#> Iteration 3     2026-08-21 09:34:27.242927
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 158.9694 | Absolute change: 4.8851 | Relative change: 0.03072975
#>   Maximum item intercept parameter change: 0.217405
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.163033
#> ....................................................
#> Iteration 4     2026-08-21 09:34:27.243571
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 156.6606 | Absolute change: 2.3088 | Relative change: 0.01473787
#>   Maximum item intercept parameter change: 0.212178
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.091324
#> ....................................................
#> Iteration 5     2026-08-21 09:34:27.244235
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 155.3618 | Absolute change: 1.2988 | Relative change: 0.00835969
#>   Maximum item intercept parameter change: 0.094986
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.060463
#> ....................................................
#> Iteration 6     2026-08-21 09:34:27.2449
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 154.5303 | Absolute change: 0.8315 | Relative change: 0.00538101
#>   Maximum item intercept parameter change: 0.089347
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.040974
#> ....................................................
#> Iteration 7     2026-08-21 09:34:27.245527
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 153.9685 | Absolute change: 0.5618 | Relative change: 0.00364861
#>   Maximum item intercept parameter change: 0.041476
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.03019
#> ....................................................
#> Iteration 8     2026-08-21 09:34:27.24618
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 153.5539 | Absolute change: 0.4146 | Relative change: 0.00269999
#>   Maximum item intercept parameter change: 0.043938
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.023071
#> ....................................................
#> Iteration 9     2026-08-21 09:34:27.246823
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 153.228 | Absolute change: 0.3259 | Relative change: 0.00212675
#>   Maximum item intercept parameter change: 0.023481
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.018865
#> ....................................................
#> Iteration 10     2026-08-21 09:34:27.247458
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 152.9437 | Absolute change: 0.2844 | Relative change: 0.00185932
#>   Maximum item intercept parameter change: 0.02665
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.016243
#> ....................................................
#> Iteration 11     2026-08-21 09:34:27.248121
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 152.668 | Absolute change: 0.2757 | Relative change: 0.00180591
#>   Maximum item intercept parameter change: 0.03145
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.015111
#> ....................................................
#> Iteration 12     2026-08-21 09:34:27.248783
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 152.3521 | Absolute change: 0.3158 | Relative change: 0.00207296
#>   Maximum item intercept parameter change: 0.020589
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.015261
#> ....................................................
#> Iteration 13     2026-08-21 09:34:27.249403
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 151.9164 | Absolute change: 0.4357 | Relative change: 0.00286801
#>   Maximum item intercept parameter change: 0.02326
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.01697
#> ....................................................
#> Iteration 14     2026-08-21 09:34:27.250052
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 151.1173 | Absolute change: 0.7991 | Relative change: 0.00528804
#>   Maximum item intercept parameter change: 0.02899
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.021201
#> ....................................................
#> Iteration 15     2026-08-21 09:34:27.250673
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 148.9526 | Absolute change: 2.1648 | Relative change: 0.01453324
#>   Maximum item intercept parameter change: 0.042219
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.029136
#> ....................................................
#> Iteration 16     2026-08-21 09:34:27.251331
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 139.4337 | Absolute change: 9.5188 | Relative change: 0.06826791
#>   Maximum item intercept parameter change: 0.040732
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.029469
#> ....................................................
#> Iteration 17     2026-08-21 09:34:27.251997
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 87.9931 | Absolute change: 51.4406 | Relative change: 0.5845982
#>   Maximum item intercept parameter change: 0.014508
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0.001404
#> ....................................................
#> Iteration 18     2026-08-21 09:34:27.252629
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 70.4494 | Absolute change: 17.5437 | Relative change: 0.2490263
#>   Maximum item intercept parameter change: 0.006957
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 19     2026-08-21 09:34:27.253286
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 70.4488 | Absolute change: 5e-04 | Relative change: 7.65e-06
#>   Maximum item intercept parameter change: 0.003176
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 20     2026-08-21 09:34:27.253953
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 70.4487 | Absolute change: 1e-04 | Relative change: 1.62e-06
#>   Maximum item intercept parameter change: 0.002584
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 21     2026-08-21 09:34:27.254573
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 70.4487 | Absolute change: 0 | Relative change: 6.6e-07
#>   Maximum item intercept parameter change: 0.002088
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 22     2026-08-21 09:34:27.255237
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 70.4486 | Absolute change: 0 | Relative change: 4.1e-07
#>   Maximum item intercept parameter change: 0.001623
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 23     2026-08-21 09:34:27.255898
#> E Step
#> M Step Intercepts   |---
#>   Deviance = 70.4486 | Absolute change: 0 | Relative change: 2.6e-07
#>   Maximum item intercept parameter change: 0.001536
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 24     2026-08-21 09:34:27.256465
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 70.4486 | Absolute change: 0 | Relative change: 1.9e-07
#>   Maximum item intercept parameter change: 0.001023
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 25     2026-08-21 09:34:27.257105
#> E Step
#> M Step Intercepts   |--
#>   Deviance = 70.4486 | Absolute change: 0 | Relative change: 1e-07
#>   Maximum item intercept parameter change: 0.000981
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 26     2026-08-21 09:34:27.257604
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 70.4486 | Absolute change: 0 | Relative change: 7e-08
#>   Maximum item intercept parameter change: 0.00067
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 27     2026-08-21 09:34:27.258262
#> E Step
#> M Step Intercepts   |--
#>   Deviance = 70.4486 | Absolute change: 0 | Relative change: 5e-08
#>   Maximum item intercept parameter change: 0.000663
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 28     2026-08-21 09:34:27.258776
#> E Step
#> M Step Intercepts   |----
#>   Deviance = 70.4486 | Absolute change: 0 | Relative change: 3e-08
#>   Maximum item intercept parameter change: 0.000452
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 29     2026-08-21 09:34:27.259394
#> E Step
#> M Step Intercepts   |--
#>   Deviance = 70.4486 | Absolute change: 0 | Relative change: 2e-08
#>   Maximum item intercept parameter change: 0.000448
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 30     2026-08-21 09:34:27.259914
#> E Step
#> M Step Intercepts   |---
#>   Deviance = 70.4486 | Absolute change: 0 | Relative change: 1e-08
#>   Maximum item intercept parameter change: 0.00033
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 31     2026-08-21 09:34:27.260479
#> E Step
#> M Step Intercepts   |--
#>   Deviance = 70.4486 | Absolute change: 0 | Relative change: 1e-08
#>   Maximum item intercept parameter change: 0.000283
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 32     2026-08-21 09:34:27.260994
#> E Step
#> M Step Intercepts   |--
#>   Deviance = 70.4486 | Absolute change: 0 | Relative change: 1e-08
#>   Maximum item intercept parameter change: 0.000175
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 33     2026-08-21 09:34:27.261486
#> E Step
#> M Step Intercepts   |--
#>   Deviance = 70.4486 | Absolute change: 0 | Relative change: 0
#>   Maximum item intercept parameter change: 0.000223
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 34     2026-08-21 09:34:27.262028
#> E Step
#> M Step Intercepts   |--
#>   Deviance = 70.4486 | Absolute change: 0 | Relative change: 0
#>   Maximum item intercept parameter change: 0.000124
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 35     2026-08-21 09:34:27.262521
#> E Step
#> M Step Intercepts   |--
#>   Deviance = 70.4486 | Absolute change: 0 | Relative change: 0
#>   Maximum item intercept parameter change: 0.000137
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Iteration 36     2026-08-21 09:34:27.263052
#> E Step
#> M Step Intercepts   |-
#>   Deviance = 70.4486 | Absolute change: 0 | Relative change: 0
#>   Maximum item intercept parameter change: 9.2e-05
#>   Maximum item slope parameter change: 0
#>   Maximum regression parameter change: 0
#>   Maximum variance parameter change: 0
#> ....................................................
#> Item Parameters
#>   xsi.index  xsi.label     est
#> 1         1 Item1_Cat1  0.8109
#> 2         2 Item1_Cat2 -0.4055
#> 3         3 Item1_Cat3  1.7918
#> 4         4 Item2_Cat1  0.2877
#> 5         5 Item2_Cat2 -0.2877
#> 6         6 Item2_Cat3 -0.8109
#> 7         7 Item3_Cat1  0.3365
#> 8         8 Item3_Cat2  0.9160
#> 9         9 Item3_Cat3 -1.0984
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
#> Start:  2026-08-21 09:34:27.235805
#> End:  2026-08-21 09:34:27.267175 
#> Time difference of 0.03136969 secs
#> 
#>   Model Method Source  N Persons Facets Categories    LogLik      AIC      BIC
#> 1   PCM    MML    TAM 20      20      1         NA -35.22429 90.44858 100.4059
#>        ICContractVersion ICEligible ICSelectable                    ICStatus
#> 1 external_native_tam_v1      FALSE        FALSE imported_native_descriptive
#>   NativeDeviance NativeLogLik NativeNpar NativeICSampleSize NativeAIC NativeBIC
#> 1       70.44858    -35.22429         10                 20  90.44858  100.4059
#>   NativeABIC     NativeAICFormula          NativeBICFormula
#> 1   67.57175 tam_deviance_plus_2k tam_deviance_plus_log_n_k
#>                           NativeABICFormula NativeAICFormulaVerified
#> 1 tam_deviance_plus_log_n_minus_2_over_24_k                     TRUE
#>   NativeBICFormulaVerified NativeABICFormulaVerified
#> 1                     TRUE                      TRUE
#>   NativeLogLikDevianceConsistent NativePersonCountConsistent Converged
#> 1                           TRUE                        TRUE      TRUE
#>                               ConvergenceStatus Iterations IterationCeiling
#> 1 imported_tam_stopped_before_iteration_ceiling         36             1000
# }
```
