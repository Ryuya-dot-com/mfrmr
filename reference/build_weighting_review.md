# Build a weighting-policy review between Rasch-family and GPCM fits

Build a weighting-policy review between Rasch-family and GPCM fits

## Usage

``` r
build_weighting_review(
  rasch_fit,
  gpcm_fit,
  theta_range = c(-6, 6),
  theta_points = 101L,
  top_n = 10L,
  nested = FALSE
)
```

## Arguments

- rasch_fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  using `model = "RSM"` or `"PCM"`.

- gpcm_fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  using `model = "GPCM"`.

- theta_range:

  Numeric vector of length 2 passed to
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
  for the information-redistribution comparison.

- theta_points:

  Integer number of theta grid points passed to
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md).

- top_n:

  Maximum number of rows to keep in compact summary outputs.

- nested:

  Request the PCM/GPCM equal-slope likelihood-ratio test. Default
  `FALSE`. Requires matched MML fits and the checks in
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md).

## Value

An object of class `mfrm_weighting_review`.

## Details

`build_weighting_review()` is an operational model-choice review helper.
It is designed for the common question:

- what changes when a Rasch-family equal-weighting model is replaced
  with a `GPCM` that allows discrimination-based reweighting?

The helper does not estimate a new model. Instead, it synthesizes four
package-native evidence sources:

- [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  for same-data model comparison

- the non-person facet measures from each fit

- the `GPCM` slope table

- [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
  for design-weighted information redistribution

The result is intended for substantive review, not for automatic model
selection. In particular, a better-fitting `GPCM` should not by itself
be interpreted as a reason to discard an equal-weighting Rasch-family
route. The fitted GPCM contains one slope for every level of one
designated facet, not one common slope and not simultaneous
criterion-by-rater slope blocks. The overview records the slope owner,
step owner, level count, free relative slope contrasts, and whether the
supplied reference is the exact unit-slope PCM response-kernel
reduction. MML information-criterion ranking requires the likelihood and
local-solution checks in
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md).
With `nested = TRUE`, a PCM/GPCM asymptotic chi-square LRT additionally
requires matching population, step and facet settings and G-1 free slope
contrasts. The returned `comparison_contract` records the comparison and
test status; observed changes in scores and information need substantive
interpretation. A JML log-likelihood increase is not promoted to
automatic PCM-versus-GPCM model selection because it is unpenalized and
the GPCM contains additional slope parameters. FACETS may serve as a
direct comparator for the PCM/JML side only; its post-fit discrimination
statistic is not a jointly estimated free-slope GPCM counterpart.

## Recommended input route

1.  Fit an equal-weighting reference model with `model = "RSM"` or
    `"PCM"`.

2.  Fit a `GPCM` on the same prepared response data.

3.  Run `build_weighting_review(rasch_fit, gpcm_fit)`.

4.  Read `summary(review)` before deciding whether the
    discrimination-based reweighting is substantively acceptable.

## What the returned tables mean

- `model_comparison`: same-data model-comparison bundle from
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md).
  AIC/Person-BIC/SABIC ranking is available only when `ICComparable` is
  true. Inspect `$lrt` and `$comparison_basis$lrt_reason` for a
  requested test.

- `comparison_contract`: one-row evidence-tier table stating whether
  formal model selection is available, how any observed log-likelihood
  difference may be read, and the bounded role of FACETS in a JML
  review.

- `facet_shift`: how non-person facet estimates move under `GPCM`.

- `slope_profile`: which `slope_facet` levels are upweighted or
  downweighted.

- `information_redistribution`: within-facet information-share changes
  between the Rasch-family fit and `GPCM`.

- `top_reweighted_levels`: compact triage table for the strongest
  slope-facet-level redistribution signals.

## GPCM boundary

This helper is available only for the current `GPCM` branch. It requires
`slope_facet == step_facet` even though MML fitting permits separate
owners, and should be read as an operational weighting-policy review,
not as a formal validity adjudication.

## See also

[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md),
[`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md),
[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("build_weighting_review", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
rasch_fit <- fit_mfrm(
  toy,
  "Person",
  c("Rater", "Criterion"),
  "Score",
  method = "MML",
  model = "RSM",
  quad_points = 9
)
gpcm_fit <- fit_mfrm(
  toy,
  "Person",
  c("Rater", "Criterion"),
  "Score",
  method = "MML",
  model = "GPCM",
  step_facet = "Criterion",
  slope_facet = "Criterion",
  quad_points = 9
)
review <- build_weighting_review(rasch_fit, gpcm_fit, theta_points = 41)
summary(review)
review$top_reweighted_levels
} # }
```
