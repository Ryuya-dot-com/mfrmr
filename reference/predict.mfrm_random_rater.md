# Predict category probabilities for observed or replacement raters

Evaluate a shared-rater RSM at explicitly supplied ability values.

## Usage

``` r
# S3 method for class 'mfrm_random_rater'
predict(
  object,
  newdata,
  ability,
  rater = c("observed", "new"),
  quad_points = 41L,
  ...
)
```

## Arguments

- object:

  A result from
  [`fit_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md).

- newdata:

  Data frame with the fitted rater column and every fixed-facet column.
  Observed-rater labels must be known; replacement-rater labels must be
  new. Fixed-facet levels must always be known.

- ability:

  A finite numeric value for all rows, one value per row, or the name of
  a numeric column of `newdata`. These are specified abilities on the
  fitted logit scale (mean ability zero, Rasch slope one), not estimated
  person scores. A value of one is one logit, not one population SD.

- rater:

  `"observed"` uses the approximate conditional distribution of an
  observed rater given the calibration responses. `"new"` integrates a
  replacement rater from the estimated population distribution. The
  target is explicit; an unfamiliar label is never silently treated as
  observed.

- quad_points:

  Normal quadrature points for the prediction integral, from 7 to 121;
  default 41. Compare orders when needed.

- ...:

  Unused.

## Value

A list with `probabilities` (rows by categories), `expected_scores`,
`newdata`, `ability`, `settings` and matching `source` metadata for
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md).
No model is refitted. Save this list together with the fitted model and
prediction inputs.

## Details

Predictions condition on estimated calibration and supplied ability.
They do not propagate calibration-estimation uncertainty or uncertainty
about ability. Observed-rater integration uses the conditional Laplace
mean/mode and covariance, not the calibration-adjusted prediction SE.
New-rater integration uses the population SD: substituting severity zero
generally produces different probabilities.

Rows are marginal probabilities for individual future ratings, not a
joint distribution or an interval for their average. Ratings with the
same new rater ID share one random severity in the model; multiplying
these row probabilities would discard that dependence. This function
does not score latent abilities from responses or impute missing
assigned scores. Use
[`score_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_random_rater.md)
for conditional Person scoring from a complete joint response roster.
