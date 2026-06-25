# Summarize threshold-profile presets for visual warning logic

Summarize threshold-profile presets for visual warning logic

## Usage

``` r
# S3 method for class 'mfrm_threshold_profiles'
summary(object, digits = 3, ...)
```

## Arguments

- object:

  Output from
  [`mfrm_threshold_profiles()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_threshold_profiles.md).

- digits:

  Number of digits used for numeric summaries.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_threshold_profiles`.

## Details

Summarizes available warning presets and their PCA reference bands used
by
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md).

## Interpreting output

- `thresholds`: raw preset values by profile (`strict`, `standard`,
  `lenient`).

- `threshold_ranges`: per-threshold span across profiles (sensitivity to
  profile choice).

- `pca_reference`: literature bands used for PCA narrative labeling.

Larger `Span` in `threshold_ranges` indicates settings that most change
warning behavior between strict and lenient modes.

## Typical workflow

1.  Inspect `summary(mfrm_threshold_profiles())`.

2.  Choose profile (`strict` / `standard` / `lenient`) for project
    policy.

3.  Override selected thresholds in
    [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)
    only when justified.

## See also

[`mfrm_threshold_profiles()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_threshold_profiles.md),
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)

## Examples

``` r
profiles <- mfrm_threshold_profiles()
summary(profiles)
#> mfrmr Threshold Profile Summary
#> 
#> Overview
#>  Profiles ThresholdCount PCAReferenceCount DefaultProfile
#>         3             11                 7       standard
#> 
#> Profile thresholds
#>               Threshold strict standard lenient
#>        expected_var_min   0.30    2e-01    0.10
#>             low_cat_min  15.00    1e+01    5.00
#>        min_facet_levels   4.00    3e+00    2.00
#>       misfit_ratio_warn   0.08    1e-01    0.15
#>  missing_fit_ratio_warn   0.15    2e-01    0.30
#>               n_obs_min 200.00    1e+02   60.00
#>            n_person_min  50.00    3e+01   20.00
#>    pca_first_eigen_warn   1.50    2e+00    3.00
#>     pca_first_prop_warn   0.10    1e-01    0.20
#>        zstd2_ratio_warn   0.08    1e-01    0.15
#>        zstd3_ratio_warn   0.03    5e-02    0.08
#> 
#> Threshold ranges across profiles
#>               Threshold   Min Median    Max   Span
#>        expected_var_min  0.10  2e-01   0.30   0.20
#>             low_cat_min  5.00  1e+01  15.00  10.00
#>        min_facet_levels  2.00  3e+00   4.00   2.00
#>       misfit_ratio_warn  0.08  1e-01   0.15   0.07
#>  missing_fit_ratio_warn  0.15  2e-01   0.30   0.15
#>               n_obs_min 60.00  1e+02 200.00 140.00
#>            n_person_min 20.00  3e+01  50.00  30.00
#>    pca_first_eigen_warn  1.50  2e+00   3.00   1.50
#>     pca_first_prop_warn  0.10  1e-01   0.20   0.10
#>        zstd2_ratio_warn  0.08  1e-01   0.15   0.07
#>        zstd3_ratio_warn  0.03  5e-02   0.08   0.05
#> 
#> PCA reference bands
#>        Band              Key Value
#>  eigenvalue critical_minimum  1.40
#>  eigenvalue          caution  1.50
#>  eigenvalue           common  2.00
#>  eigenvalue           strong  3.00
#>  proportion            minor  0.05
#>  proportion          caution  0.10
#>  proportion           strong  0.20
#> 
#> Notes
#>  - Profiles tune warning strictness for build_visual_summaries().Use `thresholds` in build_visual_summaries() to override selected values.
```
