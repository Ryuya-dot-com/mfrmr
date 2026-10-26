# Summarize posterior unit scoring output

Summarize posterior unit scoring output

## Usage

``` r
# S3 method for class 'mfrm_unit_prediction'
summary(object, digits = 3, ...)
```

## Arguments

- object:

  Output from
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md).

- digits:

  Number of digits used in numeric summaries. Decision probabilities,
  cut boundaries and scoring priors are not rounded.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_unit_prediction` with:

- `estimates`: posterior summaries by person

- `decisions`: unrounded conditional probabilities, when requested

- `row_review`: row-preparation review

- `population_review`: optional person-level omission review for
  latent-regression scoring

- `settings`: scoring settings

- `notes`: interpretation notes

## See also

[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
for an executable scoring and reporting example;
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)
