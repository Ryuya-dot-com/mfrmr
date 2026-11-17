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
  Must match this fitted analysis; see
  [mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)
  for migration of saved diagnostics.

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

`summary` describes the retained analysis; it is not a sample-size
adequacy decision. `LargestSubsetPct` concerns rating rows, not
independent Persons or the proportion of planned assignments completed.
A connected design alone does not establish parameter precision or
identify every model term.

`facet_coverage` summarizes the supplied diagnostic rows. `MeanSE` is
the unweighted mean of available element SEs, not the SE of the facet
mean or the RMS error used for separation reliability. For MML Persons
these SEs are posterior SDs. Means omit missing values separately for
each column; they can describe different subsets of levels. An
all-missing mean is `NaN`, not zero error. Inspect
`diagnostics$measures` for missing values and their reasons before
comparing facets; see
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

`category_stats` describes observed category usage and plug-in
expectations. It does not certify category adequacy. See
[`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md)
for the meaning of expected counts, residual summaries and step offsets.

## Typical workflow

1.  Run `measurable_summary_table(fit)`.

2.  Check `summary(t5)` for subset/connectivity warnings.

3.  Use `plot(t5, ...)` to inspect facet/category/subset views.

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).

## Output columns

The `summary` data.frame (one row) contains:

- Observations, TotalWeight:

  Retained rating-row count and summed response weight, respectively.
  Neither is an independent-Person count.

- Persons, Facets, Categories:

  Retained Persons, non-Person facets and declared score categories
  (including unused categories).

- ConnectedSubsets:

  Number of connected subsets.

- LargestSubsetObs, LargestSubsetPct:

  Rows in the largest connected subset and
  `100 * LargestSubsetObs / Observations`.

The `facet_coverage` data.frame contains:

- Facet:

  Facet name.

- Levels:

  Number of diagnostic rows, including levels with missing SEs.

- MeanSE:

  Arithmetic mean of available element SEs; see interpretation above.

- MeanInfit, MeanOutfit:

  Unweighted means of available level-specific mean squares, not pooled
  response-level Infit/Outfit.

- MinEstimate, MaxEstimate:

  Native-scale measure range, omitting missing values but retaining
  infinite estimates.

The `category_stats` data.frame contains:

- Category:

  Score category value.

- Count, Percent:

  Sum of response weights for the category and its percentage of total
  weight; raw counts with unit weights.

- Infit, Outfit:

  Descriptive category residual mean squares.

- InfitZSTD, OutfitZSTD:

  Unavailable (NA); conditioning on the observed category does not
  preserve a universal unit-residual reference.

- ExpectedCount, DiffCount, LowCount:

  Plug-in expected weighted count, observed minus expected count, and
  `Count < 10` review flag. This cutoff is not a universal minimum
  independent sample size.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md),
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
# example("measurable_summary_table", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
t5 <- measurable_summary_table(fit)
summary(t5)
p_t5 <- plot(t5, draw = FALSE)
plot_data(p_t5, "plot")
} # }
```
