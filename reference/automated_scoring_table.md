# Automated-scoring compatibility interface for score comparisons

Prefer
[`score_comparison_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_comparison_table.md)
for new analyses. This earlier interface retains its argument names,
automated/human output columns and default Williamson (2012) numerical
screen. The generic interface uses score/reference names and applies no
thresholds unless requested.

## Usage

``` r
automated_scoring_table(
  automated,
  human,
  human_reference = NULL,
  categories,
  automated_categories = automated,
  smd = c("pooled", "human"),
  qwk_min = 0.7,
  correlation_min = 0.7,
  max_degradation = 0.1,
  max_abs_smd = 0.15,
  fit = NULL,
  diagnostics = NULL,
  rater_facet = NULL,
  automated_rater = NULL
)
```

## Arguments

- automated, human, human_reference:

  Earlier names for `scores`, `reference`, and `reference2` in
  [`score_comparison_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_comparison_table.md).

- categories:

  Declared numeric score categories in increasing order.

- automated_categories:

  Earlier name for `score_categories`.

- smd:

  `"pooled"` or `"human"`; the latter maps to `"reference"`.

- qwk_min, correlation_min, max_degradation, max_abs_smd:

  Numerical screen limits; see
  [`score_comparison_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_comparison_table.md).
  These defaults retain the earlier automated-scoring examples and are
  not universal acceptance criteria.

- fit, diagnostics, rater_facet:

  Optional saved MFRM source and rater facet; see
  [`score_comparison_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_comparison_table.md).

- automated_rater:

  Earlier name for `rater`.

## Value

The same list structure as
[`score_comparison_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_comparison_table.md),
retaining the earlier automated/human column and category-table names.
Saved results created through the earlier interface can still be read
directly.

## See also

[`score_comparison_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_comparison_table.md)
