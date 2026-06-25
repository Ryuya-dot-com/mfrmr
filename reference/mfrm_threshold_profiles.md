# List literature-based warning threshold profiles

List literature-based warning threshold profiles

## Usage

``` r
mfrm_threshold_profiles()
```

## Value

An object of class `mfrm_threshold_profiles` with `profiles` (`strict`,
`standard`, `lenient`) and `pca_reference_bands`.

## Details

Use this function to inspect available profile presets before calling
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md).

`profiles` contains thresholds used by warning logic (sample size, fit
ratios, PCA cutoffs, etc.). `pca_reference_bands` contains
literature-oriented descriptive bands used in summary text.

## Interpreting output

- `profiles`: numeric threshold presets (`strict`, `standard`,
  `lenient`).

- `pca_reference_bands`: narrative reference bands for PCA
  interpretation.

## Typical workflow

1.  Review presets with `mfrm_threshold_profiles()`.

2.  Pick a default profile for project policy.

3.  Override only selected fields in
    [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)
    when needed.

## See also

[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)

## Examples

``` r
profiles <- mfrm_threshold_profiles()
s_profiles <- summary(profiles)
s_profiles$overview
#>   Profiles ThresholdCount PCAReferenceCount DefaultProfile
#> 1        3             11                 7       standard
```
