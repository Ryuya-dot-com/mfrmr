# List literature-informed and package-defined screening profiles

Returns the lower / upper bounds that mfrmr screens treat as the
heuristic mean-square (Infit / Outfit MnSq) review band when flagging
element-level misfit. Defaults use the published 0.5-1.5 interval as a
screening convention; both ends can be overridden via R options. The
interval is not a universal acceptance rule or an automatic exclusion
rule. Low mean squares describe low residual variability rather than
poor rater quality.
[`fit_measures_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_measures_table.md)
uses this mean-square screen by default; ZSTD-only evidence is separate
unless its combined rule is requested. Compare declared bands against
known simulation truth with
[`mfrm_screening_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_screening_performance.md).

## Usage

``` r
mfrm_threshold_profiles()

# S3 method for class 'mfrm_threshold_profiles'
summary(object, digits = 3, ...)

mfrm_misfit_thresholds(lower = NULL, upper = NULL)
```

## Arguments

- object:

  Output from `mfrm_threshold_profiles()`.

- digits:

  Number of digits used for numeric summaries.

- ...:

  Reserved for generic compatibility.

- lower:

  Optional lower bound. When `NULL` (default), the active option /
  package default is used.

- upper:

  Optional upper bound.

## Value

An object of class `mfrm_threshold_profiles` with `profiles` (`strict`,
`standard`, `lenient`) and `pca_reference_bands`.

For [`summary()`](https://rdrr.io/r/base/summary.html): An object of
class `summary.mfrm_threshold_profiles`.

A named numeric vector `c(lower = ..., upper = ...)` with
`lower < upper`.

## Details

Use this function to inspect available profile presets before calling
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md).

`profiles` contains thresholds used by warning logic (sample size, fit
ratios, PCA cutoffs, etc.). `pca_reference_bands` contains uncalibrated
descriptive references used in summary text; these are not
dimensionality-test critical values.

[`summary()`](https://rdrr.io/r/base/summary.html) method: Summarize
threshold-profile presets for visual warning logic

For [`summary()`](https://rdrr.io/r/base/summary.html): Summarizes
available warning presets and their PCA reference bands used by
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md).

Helpers that consume the band include
[`summary.mfrm_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
(`misfit_flagged` block and `key_warnings` auto-flag),
[`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md)
(the new `element_fit` source family), the bias / misfit narrative
inside
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
and
[`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md)
when `misfit_warn = NULL`. Setting the options once at the top of an
analysis script therefore changes every downstream screen at once.

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

`Span` describes the numeric range of each threshold across presets.
Thresholds use different units and rules, so spans cannot rank their
effects on flags; compare actual outputs under the selected presets.

## Typical workflow

1.  Review presets with `mfrm_threshold_profiles()`.

2.  Pick a default profile for project policy.

3.  Override only selected fields in
    [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)
    when needed.

For [`summary()`](https://rdrr.io/r/base/summary.html):

1.  Inspect `summary(mfrm_threshold_profiles())`.

2.  Choose profile (`strict` / `standard` / `lenient`) for project
    policy.

3.  Override selected thresholds in
    [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)
    only when justified.

## Configuration

Two scalar R options drive the band:

- `mfrmr.misfit_lower`:

  Lower review bound. Default `0.5`.

- `mfrmr.misfit_upper`:

  Upper review bound. Default `1.5`.

Pass scalar arguments to override the options for a single call, e.g.
`mfrm_misfit_thresholds(lower = 0.7, upper = 1.3)` for the tighter Bond
& Fox (2015) reporting band.

## See also

[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)

`mfrm_threshold_profiles()`,
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)

[`summary.mfrm_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md),
[`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md)

## Examples

``` r
profiles <- mfrm_threshold_profiles()
s_profiles <- summary(profiles)
s_profiles$overview
#>   Profiles ThresholdCount PCAReferenceCount DefaultProfile
#> 1        3             11                 7       standard
# Optional workflow; run the example explicitly as shown below.
# example("summary.mfrm_threshold_profiles", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
profiles <- mfrm_threshold_profiles()
summary(profiles)
} # }
mfrm_misfit_thresholds()
#> lower upper 
#>   0.5   1.5 
old <- options(mfrmr.misfit_lower = 0.7, mfrmr.misfit_upper = 1.3)
mfrm_misfit_thresholds()
#> lower upper 
#>   0.7   1.3 
options(old)
```
