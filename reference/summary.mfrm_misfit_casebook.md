# Summarize a misfit-casebook object

Summarize a misfit-casebook object

## Usage

``` r
# S3 method for class 'mfrm_misfit_casebook'
summary(object, digits = 3, top_n = 10, ...)
```

## Arguments

- object:

  Output from
  [`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md).

- digits:

  Number of digits for printed numeric values.

- top_n:

  Number of top case rows to keep in the compact summary.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_misfit_casebook`.

## See also

[`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md)
