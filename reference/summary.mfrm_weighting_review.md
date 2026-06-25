# Summarize a weighting-review object

Summarize a weighting-review object

## Usage

``` r
# S3 method for class 'mfrm_weighting_review'
summary(object, digits = 3, top_n = 10, ...)
```

## Arguments

- object:

  Output from
  [`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md).

- digits:

  Number of digits for printed numeric values.

- top_n:

  Number of top rows to retain in compact summary tables.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_weighting_review`.

## See also

[`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
