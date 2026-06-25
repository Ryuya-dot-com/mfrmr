# Summarize a linking-review object

Summarize a linking-review object

## Usage

``` r
# S3 method for class 'mfrm_linking_review'
summary(object, digits = 3, top_n = 10, ...)
```

## Arguments

- object:

  Output from
  [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md).

- digits:

  Number of digits for printed numeric values.

- top_n:

  Number of top linking-risk rows to keep in the compact summary.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_linking_review`.

## See also

[`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
