# List literature-based warning threshold profiles

List literature-based warning threshold profiles

## Usage

``` r
mfrm_threshold_profiles()

# S3 method for class 'mfrm_threshold_profiles'
summary(object, digits = 3, ...)
```

## Arguments

- object:

  Output from `mfrm_threshold_profiles()`.

- digits:

  Number of digits used for numeric summaries.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `mfrm_threshold_profiles` with `profiles` (`strict`,
`standard`, `lenient`) and `pca_reference_bands`.

For [`summary()`](https://rdrr.io/r/base/summary.html): An object of
class `summary.mfrm_threshold_profiles`.

## Details

Use this function to inspect available profile presets before calling
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_visual_summaries.md).

`profiles` contains thresholds used by warning logic (sample size, fit
ratios, PCA cutoffs, etc.). `pca_reference_bands` contains uncalibrated
descriptive references used in summary text; these are not
dimensionality-test critical values.

[`summary()`](https://rdrr.io/r/base/summary.html) method: Summarize
threshold-profile presets for visual warning logic

For [`summary()`](https://rdrr.io/r/base/summary.html): Summarizes
available warning presets and their PCA reference bands used by
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_visual_summaries.md).

## Interpreting output

- `profiles`: numeric threshold presets (`strict`, `standard`,
  `lenient`).

- `pca_reference_bands`: narrative reference bands for PCA
  interpretation.

For [`summary()`](https://rdrr.io/r/base/summary.html):

- `thresholds`: raw preset values by profile (`strict`, `standard`,
  `lenient`).

- `threshold_ranges`: per-threshold span across profiles (sensitivity to
  profile choice).

- `pca_reference`: literature bands used for PCA narrative labeling.

Larger `Span` in `threshold_ranges` indicates settings that most change
warning behavior between strict and lenient modes.

## Typical workflow

1.  Review presets with `mfrm_threshold_profiles()`.

2.  Pick a default profile for project policy.

3.  Override only selected fields in
    [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_visual_summaries.md)
    when needed.

For [`summary()`](https://rdrr.io/r/base/summary.html):

1.  Inspect `summary(mfrm_threshold_profiles())`.

2.  Choose profile (`strict` / `standard` / `lenient`) for project
    policy.

3.  Override selected thresholds in
    [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_visual_summaries.md)
    only when justified.

## See also

[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_visual_summaries.md)

`mfrm_threshold_profiles()`,
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_visual_summaries.md)

## Examples

``` r
profiles <- mfrm_threshold_profiles()
s_profiles <- summary(profiles)
s_profiles$overview
#>   Profiles ThresholdCount PCAReferenceCount DefaultProfile
#> 1        3             11                 7       standard
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("summary.mfrm_threshold_profiles", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
profiles <- mfrm_threshold_profiles()
summary(profiles)
} # }
```
