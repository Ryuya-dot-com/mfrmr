# Fit the same MFRM to every completed rating data set

Fit a separate MFRM to each completed version of the ratings reviewed by
[`mfrm_response_imputations()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md).
All fits use the same model and measurement scale so eligible estimates
can be combined with
[`pool_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/pool_mfrm_imputed.md).
Failed fits and their messages are retained for review.

## Usage

``` r
fit_mfrm_imputed(x, model = c("RSM", "PCM"), step_facet = NULL, ...)

# S3 method for class 'mfrm_imputed_fits'
print(x, ...)

# S3 method for class 'mfrm_imputed_fits'
summary(object, ...)
```

## Arguments

- x:

  An
  [`mfrm_response_imputations()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md)
  object.

- model:

  `"RSM"` or `"PCM"`.

- step_facet:

  Required for PCM: the facet with separate step parameters.

- ...:

  Shared
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  arguments, such as `quad_points`, `anchors`, `facet_interactions` or
  optimizer controls. They must be named. Data columns, category scale
  and MML identification are set by this workflow. Observation weights,
  latent regression, shrinkage, checkpointing and adaptive integration
  are not supported by this workflow.

- object:

  An object returned by `fit_mfrm_imputed()`.

## Value

An `mfrm_imputed_fits` object with the `imputations` review, all `fits`
(including `NULL` for failures), `analysis_summary` recording every
fit's status, error and warnings, and common `settings`. Use
[`pool_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/pool_mfrm_imputed.md)
for eligible non-person facet targets.

## Details

Every fit uses the same original category ladder, facet levels, anchors
and other supplied constraints, with fixed-standard-normal person MML
identification. `keep_original = TRUE` prevents per-completion category
collapsing. An unsupported category contrast, insufficient observed
information or failed optimization is retained as a failed or ineligible
analysis; subsequent pooling requires every imputation to qualify.

A common coordinate system does not establish model adequacy. Review the
imputation model, rating design and numerical integration. The fit
objects retain conditional person scores for individual review; those
EAPs and posterior SDs are not ordinary complete-data parameter
estimates and standard errors for Rubin pooling.

## See also

[`mfrm_response_imputations()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md),
[`pool_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/pool_mfrm_imputed.md)
