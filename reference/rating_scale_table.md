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
  category table; `summary` and `caveats` still retain the omitted
  score-support warning.

## Value

A named list with:

- `category_table`: category-level counts, expected counts, fit, and
  ZSTD

- `threshold_table`: model step/threshold estimates

- `summary`: one-row summary (usage and threshold monotonicity)

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

  Observed count and percentage of total.

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

  Step label (e.g., "1-2", "2-3").

- Estimate:

  Estimated threshold/step difficulty (logits).

- StepFacet:

  Threshold family identifier when the fit uses facet-specific threshold
  sets.

- GapFromPrev:

  Difference from the previous threshold within the same `StepFacet`
  when thresholds are facet-specific. Gaps below 1.4 logits may indicate
  category underuse; gaps above 5.0 may indicate wide unused regions
  (Linacre, 2002).

- ThresholdMonotonic:

  Logical flag repeated within each threshold set. For PCM fits, read
  this within `StepFacet`, not as a pooled item-bank verdict.

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
  (Source for the 0.5-1.5 mean-square acceptance band and the
  threshold-gap heuristics used in `summary(t8)$summary`.)

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
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
t8 <- rating_scale_table(fit)
summary(t8)
summary(t8)$summary
p_t8 <- plot(t8, draw = FALSE)
p_t8$data$plot
}
```
