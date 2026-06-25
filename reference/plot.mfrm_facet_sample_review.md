# Plot a facet sample-size review

Per-level observation counts rendered as a horizontal bar chart coloured
by the Linacre sample-size band assigned in
[`facet_small_sample_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_small_sample_review.md).
Vertical dashed lines mark the sparse / marginal / standard thresholds
so reviewers see where every facet level sits relative to the Linacre
(1994) guidance.

## Usage

``` r
# S3 method for class 'mfrm_facet_sample_review'
plot(
  x,
  top_n = NULL,
  preset = c("standard", "publication", "compact", "monochrome"),
  ...
)
```

## Arguments

- x:

  An `mfrm_facet_sample_review` object.

- top_n:

  Optional integer; trim the y-axis to the `top_n` smallest level counts
  per facet. `NULL` (default) keeps all.

- preset:

  One of `"standard"`, `"publication"`, `"compact"`, `"monochrome"`.

- ...:

  Reserved.

## Value

Invisibly, the data.frame used for the plot.

## See also

[`facet_small_sample_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_small_sample_review.md).
