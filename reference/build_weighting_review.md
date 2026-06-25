# Build a weighting-policy review between Rasch-family and bounded GPCM fits

Build a weighting-policy review between Rasch-family and bounded GPCM
fits

## Usage

``` r
build_weighting_review(
  rasch_fit,
  gpcm_fit,
  theta_range = c(-6, 6),
  theta_points = 101L,
  top_n = 10L
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
  using bounded `model = "GPCM"`.

- theta_range:

  Numeric vector of length 2 passed to
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
  for the information-redistribution comparison.

- theta_points:

  Integer number of theta grid points passed to
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md).

- top_n:

  Maximum number of rows to keep in compact summary outputs.

## Value

An object of class `mfrm_weighting_review`.

## Details

`build_weighting_review()` is an operational model-choice review helper.
It is designed for the common question:

- what changes when a Rasch-family equal-weighting model is replaced
  with a bounded `GPCM` that allows discrimination-based reweighting?

The helper does not estimate a new model. Instead, it synthesizes four
package-native evidence sources:

- [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  for same-data model comparison

- the non-person facet measures from each fit

- the bounded `GPCM` slope table

- [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
  for design-weighted information redistribution

The result is intended for substantive review, not for automatic model
selection. In particular, a better-fitting `GPCM` should not by itself
be interpreted as a reason to discard an equal-weighting Rasch-family
route.

## Recommended input route

1.  Fit an equal-weighting reference model with `model = "RSM"` or
    `"PCM"`.

2.  Fit a bounded `GPCM` on the same prepared response data.

3.  Run `build_weighting_review(rasch_fit, gpcm_fit)`.

4.  Read `summary(review)` before deciding whether the
    discrimination-based reweighting is substantively acceptable.

## What the returned tables mean

- `model_comparison`: same-data model-comparison bundle from
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md).

- `facet_shift`: how non-person facet estimates move under bounded
  `GPCM`.

- `slope_profile`: which `slope_facet` levels are upweighted or
  downweighted.

- `information_redistribution`: within-facet information-share changes
  between the Rasch-family fit and bounded `GPCM`.

- `top_reweighted_levels`: compact triage table for the strongest
  slope-facet-level redistribution signals.

## GPCM boundary

This helper is available only for the current bounded `GPCM` branch. It
requires the package's existing `slope_facet == step_facet` contract and
should be read as an operational weighting-policy review, not as a
formal validity adjudication.

## See also

[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md),
[`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md),
[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)

## Examples

``` r
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
