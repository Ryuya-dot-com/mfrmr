# Build a facet statistics report (preferred alias)

Build a facet statistics report (preferred alias)

## Usage

``` r
facet_statistics_report(
  fit,
  diagnostics = NULL,
  metrics = c("Estimate", "Infit", "Outfit", "SE"),
  ruler_width = 41,
  distribution_basis = c("both", "sample", "population"),
  se_mode = c("both", "model", "fit_adjusted")
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- metrics:

  Numeric columns in `diagnostics$measures` to summarize.

- ruler_width:

  Width of the fixed-width ruler used for `M/S/Q/X` marks.

- distribution_basis:

  Which distribution basis to keep in the appended precision summary:
  `"both"` (default), `"sample"`, or `"population"`.

- se_mode:

  Which standard-error mode to keep in the appended precision summary:
  `"both"` (default), `"model"`, or `"fit_adjusted"`.

## Value

A named list with facet-statistics components. Class:
`mfrm_facet_statistics`.

## Details

`summary(out)` is supported through
[`summary()`](https://rdrr.io/r/base/summary.html). `plot(out)` is
dispatched through
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) for class
`mfrm_facet_statistics` (`type = "means"`, `"sds"`, `"ranges"`).

## Interpreting output

- facet-level means/SD/ranges of selected metrics (`Estimate`, fit
  indices, `SE`).

- fixed-width ruler rows (`M/S/Q/X`) for compact profile scanning.

## Typical workflow

1.  Run `facet_statistics_report(fit)`.

2.  Inspect summary/ranges for anomalous facets.

3.  Cross-check flagged facets with fit and chi-square diagnostics. The
    returned bundle now includes:

- `precision_summary`: facet precision/separation indices by
  `DistributionBasis` and `SEMode`

- `variability_tests`: fixed/random variability tests by facet

- `se_modes`: compact list of available SE modes by facet

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`summary.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md),
[`plot_facets_chisq()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facets_chisq.md),
[mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
out <- facet_statistics_report(fit)
summary(out)
#> mfrmr Facet Profile Summary 
#>   Class: mfrm_facet_statistics
#>   Components: 6
#> 
#> Facet-profile overview
#>  Facets Rows Metrics PrecisionRows VariabilityRows
#>       3   12       4            12               3
#> 
#> Facet-profile rows: precision_summary
#>      Facet Levels DistributionBasis       SEMode SEColumn ObservedMean
#>  Criterion      4        population fit_adjusted   RealSE        0.000
#>  Criterion      4        population        model  ModelSE        0.000
#>  Criterion      4            sample fit_adjusted   RealSE        0.000
#>  Criterion      4            sample        model  ModelSE        0.000
#>     Person     48        population fit_adjusted   RealSE        0.001
#>     Person     48        population        model  ModelSE        0.001
#>     Person     48            sample fit_adjusted   RealSE        0.001
#>     Person     48            sample        model  ModelSE        0.001
#>      Rater      4        population fit_adjusted   RealSE        0.000
#>      Rater      4        population        model  ModelSE        0.000
#>  ObservedSD  RMSE TrueSD ObservedVariance ErrorVariance TrueVariance Separation
#>       0.249 0.099  0.229            0.062         0.010        0.052      2.316
#>       0.249 0.097  0.229            0.062         0.010        0.053      2.353
#>       0.288 0.099  0.270            0.083         0.010        0.073      2.736
#>       0.288 0.097  0.271            0.083         0.010        0.073      2.777
#>       1.088 0.365  1.025            1.184         0.133        1.051      2.809
#>       1.088 0.347  1.031            1.184         0.120        1.064      2.975
#>       1.099 0.365  1.037            1.209         0.133        1.076      2.843
#>       1.099 0.347  1.043            1.209         0.120        1.089      3.010
#>       0.271 0.099  0.253            0.074         0.010        0.064      2.564
#>       0.271 0.097  0.253            0.074         0.010        0.064      2.596
#>  Strata Reliability SEAvailable MeanSE MedianSE MeanInfit MeanOutfit FixedChiSq
#>   3.421       0.843           4  0.099    0.098     0.994      1.019     25.914
#>   3.470       0.847           4  0.097    0.097     0.994      1.019     25.914
#>   3.981       0.882           4  0.099    0.098     0.994      1.019     25.914
#>   4.037       0.885           4  0.097    0.097     0.994      1.019     25.914
#>   4.079       0.888          48  0.360    0.349     1.000      1.019    384.088
#>   4.300       0.898          48  0.344    0.330     1.000      1.019    384.088
#>   4.123       0.890          48  0.360    0.349     1.000      1.019    384.088
#>   4.346       0.901          48  0.344    0.330     1.000      1.019    384.088
#>   3.752       0.868           4  0.099    0.099     0.994      1.019     30.901
#>   3.795       0.871           4  0.097    0.097     0.994      1.019     30.901
#>  FixedDF FixedProb RandomVar RandomChiSq RandomDF RandomProb
#>        3         0     0.073       2.997        2      0.223
#>        3         0     0.073       2.997        2      0.223
#>        3         0     0.073       2.997        2      0.223
#>        3         0     0.073       2.997        2      0.223
#>       47         0     1.089      45.462       46      0.495
#>       47         0     1.089      45.462       46      0.495
#>       47         0     1.089      45.462       46      0.495
#>       47         0     1.089      45.462       46      0.495
#>        3         0     0.089       2.999        2      0.223
#>        3         0     0.089       2.999        2      0.223
#> 
#> Settings
#>             Setting                           Value
#>             metrics     Estimate, Infit, Outfit, SE
#>         ruler_width                              41
#>       marker_legend mean, +/-1 SD, +/-2 SD, +/-3 SD
#>  distribution_basis                            both
#>             se_mode                            both
#> 
#> Notes
#>  - Facet profile summary including distribution basis, SE mode, and variability
#>    tests.
p_fs <- plot(out, draw = FALSE)
p_fs$data$plot
#> [1] "means"
# }
```
