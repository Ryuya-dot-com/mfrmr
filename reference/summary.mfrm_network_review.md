# Summarize an MFRM network review

Summarize an MFRM network review

## Usage

``` r
# S3 method for class 'mfrm_network_review'
summary(object, digits = 3, top_n = 10, ...)
```

## Arguments

- object:

  Output from
  [`build_mfrm_network_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_network_review.md).

- digits:

  Number of digits for printed numeric values.

- top_n:

  Number of central/cut/bridge rows to keep in the compact summary.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_network_review`.

## See also

[`build_mfrm_network_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_network_review.md)
