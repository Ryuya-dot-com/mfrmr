# Build a rating-scale diagnostics report

Build a rating-scale diagnostics report

## Usage

``` r
rating_scale_table(
  fit,
  diagnostics = NULL,
  whexact = FALSE,
  drop_unused = FALSE
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- whexact:

  Use exact ZSTD transformation for category fit.

- drop_unused:

  If `TRUE`, remove categories with zero count from the displayed
  category table. Usage totals still cover the full declared scale;
  unavailable counts remain visible, and score-support caveats are
  retained.

## Value

A named list with:

- `category_table`: category-level counts, expected counts, fit, and
  ZSTD

- `threshold_table`: model step/threshold estimates

- `summary`: one-row summary with available/unavailable category counts
  and adjacent-threshold comparisons. Category-fit means identify their
  available denominators and describe displayed rows. Missing fit
  statistics/flags stay `NA`, including unused categories with no
  estimable category fit.

- `category_usage`: counts across the full scale, before `drop_unused`

- `threshold_coverage`: available, unavailable and decreasing
  adjacent-pair counts; `NotApplicable` distinguishes binary scales from
  missing estimates

- `caveats`: structured score-support warning/review rows

- `diagnostic_mode`: character scalar carried from
  `diagnostics$diagnostic_mode` (`"legacy"`, `"both"`, or
  `"marginal_fit"`); used by downstream reporting helpers to pick the
  correct expected-count basis

- `marginal_fit`: list bundle from `diagnostics$marginal_fit` when
  strict marginal fit was computed, otherwise `NULL`. Carries the raw
  OverallRMSD / OverallMaxAbsStdResidual / per-cell tables that feed the
  `MarginalOverallRMSD` columns in `summary`.

## Details

This helper provides category usage/fit statistics and threshold
summaries for reviewing score-category functioning. The category usage
portion is a global observed-score screen. In PCM fits with a
`step_facet`, threshold diagnostics should be interpreted within each
`StepFacet` rather than as one pooled whole-scale verdict.

Typical checks:

- sparse category usage (`Count`, `ExpectedCount`)

- category fit (`Infit`, `Outfit`, `ZStd`)

- threshold ordering within each `StepFacet`
  (`threshold_table$Estimate`, `GapFromPrev`)

## Interpreting output

Start with `summary`:

- `UsedCategories` close to total `Categories` suggests that most score
  categories are represented in the observed data.

- very small `MinCategoryCount` indicates potential instability.

- `ThresholdMonotonic = FALSE` indicates disordered thresholds within at
  least one threshold set. In PCM fits, inspect `threshold_table` by
  `StepFacet` before drawing scale-wide conclusions.

Then inspect:

- `category_table` for global category-level misfit/sparsity.

- `threshold_table` for adjacent-step gaps and ordering within each
  `StepFacet`.

For MML step uncertainty, inspect
`diagnostics$parameter_uncertainty$steps` from
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
A bare fit supplies point estimates to `threshold_table`; passing
separate diagnostics here does not attach their SEs or intervals to that
table. Check `SE_Status` and, when present, `CIEligible` / `CIUse`
before reporting intervals. Retain `StepFacet` for PCM threshold
families. A facet-location SE is not a step SE.

## Typical workflow

1.  Fit model:
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Build diagnostics:
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

3.  Run `rating_scale_table()` and review
    [`summary()`](https://rdrr.io/r/base/summary.html).

4.  Use [`plot()`](https://rdrr.io/r/graphics/plot.default.html) to
    visualize category profile quickly.

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).

## Output columns

The `category_table` data.frame contains:

- Category:

  Score category value.

- Count, Percent:

  Observed count and percentage of total. With observation weights,
  counts are sums of weights, not independent sample sizes. Missing or
  invalid scores/weights make the usage counts unavailable.

- AvgPersonMeasure:

  Mean person measure for respondents in this category.

- Infit, Outfit:

  Category-level fit statistics.

- InfitZSTD, OutfitZSTD:

  Standardized fit values.

- ExpectedCount, DiffCount:

  Expected count and observed-expected difference.

- LowCount:

  Logical; `TRUE` if count is below minimum threshold.

- InfitFlag, OutfitFlag, ZSTDFlag:

  Fit-based warning flags.

- ZeroCount, UnusedCategoryType, WeaklyIdentified, CategoryCaveat:

  Structured score-support caveats for retained zero-count categories.

The `threshold_table` data.frame contains:

- Step:

  Step label (e.g., `Step_1`, `Step_2`). Use `LowerCategory` and
  `UpperCategory` to identify the corresponding score transition.

- Estimate:

  Estimated threshold/step difficulty (logits).

- StepFacet:

  Threshold family identifier when the fit uses facet-specific threshold
  sets.

- GapFromPrev:

  Difference between adjacent numbered thresholds within the same
  `StepFacet`. Missing thresholds are not skipped to form a gap. No
  automatic category-merging rule is applied.

- ThresholdMonotonic:

  Logical flag repeated within each threshold set. `FALSE` records at
  least one decreasing adjacent pair; `TRUE` requires every expected
  pair to be available and nondecreasing, allowing numerical differences
  up to `sqrt(.Machine$double.eps)`. Equal thresholds meet this
  descriptive condition. Otherwise the flag is `NA`. A binary scale has
  only one threshold and no applicable ordering comparison. This is a
  statement about point estimates, not a test of category adequacy.

- LowerCategory, UpperCategory, WeaklyIdentified, ThresholdCaveat:

  Adjacent score-category support metadata. Thresholds adjacent to
  retained zero-count categories are flagged for cautious
  interpretation.

## References

- Andrich, D. (1978). *A rating formulation for ordered response
  categories*. Psychometrika, 43(4), 561-573.
  [doi:10.1007/BF02293814](https://doi.org/10.1007/BF02293814)

- Masters, G. N. (1982). *A Rasch model for partial credit scoring*.
  Psychometrika, 47(2), 149-174.
  [doi:10.1007/BF02296272](https://doi.org/10.1007/BF02296272)

- Linacre, J. M. (2002). What do Infit and Outfit, mean-square and
  standardized mean? *Rasch Measurement Transactions, 16*(2), 878.
  (Source for the 0.5-1.5 mean-square heuristic review interval; this is
  not a source for threshold-gap rules.)

- Wind, S. A. (2023). *Detecting rating scale malfunctioning with the
  partial credit model and generalized partial credit model*.
  Educational and Psychological Measurement, 83(5), 953-983.
  [doi:10.1177/00131644221116292](https://doi.org/10.1177/00131644221116292)
  (Recent simulation evidence on PCM- and GPCM-based rating-scale
  diagnostics; useful for interpreting the `summary(t8)$summary` flags
  in the bounded `GPCM` route.)

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`measurable_summary_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/measurable_summary_table.md),
[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# \donttest{
# Load the package and example ratings
library(mfrmr)
toy <- load_mfrmr_data("example_operational")

# Fit the model
fit <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM"
)

# Review category use and the fitted transitions between scores
categories <- rating_scale_table(fit)
review <- summary(categories)
review$summary
#>   Categories DisplayedCategories AvailableCategoryCounts
#> 1          4                   4                       4
#>   UnavailableCategoryCounts UsedCategories UnusedScoreCategories
#> 1                         0              4                      
#>   WeaklyIdentifiedThresholds MinCategoryCount MaxCategoryCount
#> 1                          0               46               96
#>   MeanCategoryInfit AvailableCategoryInfit MeanCategoryOutfit
#> 1          1.079498                      4          0.9991048
#>   AvailableCategoryOutfit ThresholdMonotonic ThresholdComparisons
#> 1                       4               TRUE                    2
#>   AvailableThresholdComparisons UnavailableThresholdComparisons
#> 1                             2                               0
#>   ThresholdOrderNotApplicable DiagnosticMode
#> 1                       FALSE           both
#>                                     ExpectedCountBasis MarginalFitAvailable
#> 1 legacy_plugin + latent_integrated_first_order_counts                 TRUE
#>   MarginalOverallRMSD MarginalMaxAbsStdResidual MarginalFlaggedCategories
#> 1         0.006236843                 0.4330932                         0
#>   MarginalClassifiedCategories MarginalUnclassifiedCategories
#> 1                            4                              0

# Bars show observed counts; the line shows model-expected counts
# Recreate saved tables with the original fit and diagnostics after updating.
plot(categories)

# }
```
