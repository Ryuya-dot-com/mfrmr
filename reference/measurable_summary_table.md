# Build a measurable-data summary

Build a measurable-data summary

## Usage

``` r
measurable_summary_table(fit, diagnostics = NULL)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

## Value

A named list with:

- `summary`: one-row measurable-data summary

- `facet_coverage`: per-facet coverage summary

- `category_stats`: category-level usage/fit summary

- `subsets`: subset summary table (when available)

## Details

This helper consolidates measurable-data diagnostics into a dedicated
report bundle: run-level summary, facet coverage, category usage, and
subset (connected-component) information.

`summary(t5)` is supported through
[`summary()`](https://rdrr.io/r/base/summary.html). `plot(t5)` is
dispatched through
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) for class
`mfrm_measurable` (`type = "facet_coverage"`, `"category_counts"`,
`"subset_observations"`).

## Interpreting output

- `summary`: overall measurable design status.

- `facet_coverage`: spread/precision by facet.

- `category_stats`: category usage and fit context.

- `subsets`: connectivity diagnostics (fragmented subsets reduce
  comparability).

## Typical workflow

1.  Run `measurable_summary_table(fit)`.

2.  Check `summary(t5)` for subset/connectivity warnings.

3.  Use `plot(t5, ...)` to inspect facet/category/subset views.

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).

## Output columns

The `summary` data.frame (one row) contains:

- Observations, TotalWeight:

  Total observations and summed weight.

- Persons, Facets, Categories:

  Design dimensions.

- ConnectedSubsets:

  Number of connected subsets.

- LargestSubsetObs, LargestSubsetPct:

  Largest subset coverage.

The `facet_coverage` data.frame contains:

- Facet:

  Facet name.

- Levels:

  Number of estimated levels.

- MeanSE:

  Mean standard error across levels.

- MeanInfit, MeanOutfit:

  Mean fit statistics across levels.

- MinEstimate, MaxEstimate:

  Measure range for this facet.

The `category_stats` data.frame contains:

- Category:

  Score category value.

- Count, Percent:

  Observed count and percentage.

- Infit, Outfit, InfitZSTD, OutfitZSTD:

  Category-level fit.

- ExpectedCount, DiffCount, LowCount:

  Expected-observed comparison and low-count flag.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md),
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
t5 <- measurable_summary_table(fit)
summary(t5)
p_t5 <- plot(t5, draw = FALSE)
p_t5$data$plot
}
```
