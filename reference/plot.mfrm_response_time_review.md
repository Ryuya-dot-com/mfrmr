# Plot a saved response-time review

Plot a saved response-time review

## Usage

``` r
# S3 method for class 'mfrm_response_time_review'
plot(x, type = c("distribution", "person", "facet", "score"), ...)
```

## Arguments

- x:

  A `mfrm_response_time_review` object.

- type:

  Plot type: `"distribution"`, `"person"`, `"facet"`, or `"score"`.

- ...:

  View-specific controls from
  [`plot_response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_response_time_review.md).

## Value

The existing response-time plot payload. These are descriptive timing
summaries.

## See also

[`response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/response_time_review.md),
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_plot_migration.md)
