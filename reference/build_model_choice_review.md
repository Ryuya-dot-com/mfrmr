# Build a model-choice review across RSM, PCM, and bounded GPCM fits

Build a model-choice review across RSM, PCM, and bounded GPCM fits

## Usage

``` r
build_model_choice_review(
  ...,
  labels = NULL,
  run_weighting_review = NULL,
  theta_range = c(-6, 6),
  theta_points = 61L,
  top_n = 10L,
  warn_constraints = TRUE
)
```

## Arguments

- ...:

  Two or more fitted `mfrm_fit` objects from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- labels:

  Optional labels for the supplied fits. If omitted, names from `...`
  are used when available; otherwise labels are generated from
  model/method combinations.

- run_weighting_review:

  Logical. If `TRUE` and the supplied fits include at least one
  `RSM`/`PCM` reference plus one bounded `GPCM` fit, also run
  [`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
  for the first such pair.

- theta_range, theta_points, top_n:

  Passed to
  [`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
  when `run_weighting_review = TRUE`.

- warn_constraints:

  Passed to
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md).

## Value

An object of class `mfrm_model_choice_review`.

## Details

`build_model_choice_review()` is a user-facing synthesis helper. It does
not estimate new models. It bundles:

- [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  for AIC/BIC/log-likelihood comparison;

- model-role guidance for `RSM`, `PCM`, and bounded `GPCM`;

- downstream-route availability for APA output, score-side export,
  linking, recovery, fair averages, bias screening, and summary-appendix
  handoff;

- report wording templates that avoid treating better bounded-`GPCM` fit
  as an automatic operational-scoring decision;

- [`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
  when bounded `GPCM` is present;

- optionally,
  [`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
  for the first Rasch-family reference versus bounded-`GPCM` pair.

The word "bounded" is intentional: the package implements a bounded GPCM
route, not every possible generalized partial-credit many-facet
extension. The current route uses positive slopes, requires
`slope_facet == step_facet`, identifies slopes on the log scale with
geometric mean 1, and keeps several downstream score-side/reporting
helpers outside the validated boundary.

## See also

[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md),
[`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md),
[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md),
[`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit_rsm <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                    method = "MML", model = "RSM", quad_points = 7)
fit_pcm <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                    method = "MML", model = "PCM", step_facet = "Criterion",
                    quad_points = 7)
review <- build_model_choice_review(RSM = fit_rsm, PCM = fit_pcm)
summary(review)
} # }
```
