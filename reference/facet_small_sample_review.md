# Review per-facet-level sample adequacy

Reports per-level observation counts, SE, and fit statistics for every
level of every facet in a fitted MFRM model, and classifies each level
as `"sparse"`, `"marginal"`, `"standard"`, or `"strong"` against the
Linacre sample-size bands.

## Usage

``` r
facet_small_sample_review(
  fit,
  diagnostics = NULL,
  thresholds = c(sparse = 10, marginal = 30, standard = 50)
)
```

## Arguments

- fit:

  An `mfrm_fit` from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  output. When supplied, per-level `Infit`, `Outfit`, and `ModelSE` are
  added to the report.

- thresholds:

  Named numeric vector of count bands. Defaults are
  `c(sparse = 10, marginal = 30, standard = 50)`. These are adapted from
  Linacre (1994): the 30-level band preserves Linacre's approximately
  `+-1.0 logit at 95% CI` line, while the `sparse < 10` floor and the
  `standard = 50` watermark are mfrmr-specific screening choices below
  Linacre's 30-examinee minimum and between Linacre's 30 and 100
  thresholds.

## Value

A list of class `mfrm_facet_sample_review` with:

- `table`: one row per `(Facet, Level)` with `N`, `Estimate`, `SE`,
  `Infit`, `Outfit`, and `SampleCategory`.

- `summary`: counts of levels in each sample-size category, by facet.

- `facet_summary`: smallest observed level count per facet.

- `thresholds`: the applied count bands.

## Details

In mfrmr every facet is a fixed effect (see
[`?fit_mfrm`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
"Fixed effects assumption"), so a level with very few ratings
contributes an estimate with wide SE but no shrinkage toward the facet
mean. This helper surfaces those levels up front so users can decide
whether to drop them, pool them, or move to a hierarchical model outside
mfrmr.

## Interpreting output

- `"sparse"` (n \< 10): level-level estimate is unstable; SE will be
  wide; consider combining with adjacent levels or treating as
  exploratory only.

- `"marginal"` (10 \<= n \< 30): below Linacre (1994) 95% CI +-1.0 logit
  threshold; usable as screening only.

- `"standard"` (30 \<= n \< 50): meets baseline stability; reasonable
  for publication if fit statistics are acceptable.

- `"strong"` (n \>= 50): well-targeted; facet estimate is robust.

Because mfrmr has no shrinkage by default, sparse and marginal levels do
not "borrow strength" from other levels. Jones and Wind (2018) report
that rater estimates are particularly sensitive to thin linking; the
`Facet = "Person"` row is usually less of a concern because the person
prior integrates out the uncertainty.

## Typical workflow

1.  Fit with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md);
    optionally also produce `diagnostics` with
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    if you want per-level Infit/Outfit.

2.  Call `facet_small_sample_review(fit, diagnostics)`.

3.  Read the `facet_summary` first: it highlights the worst level per
    facet. The `summary` table gives counts in each band.

4.  If any facet is flagged as sparse or marginal, discuss it in the
    Methods section;
    [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
    already adds a sentence about the band when
    `fit$summary$FacetSampleSizeFlag` is set.

## References

Linacre, J. M. (2026). *A User's Guide to FACETS, Version 4.5.0*.
Winsteps.com. <https://www.winsteps.com/facets.htm>

Linacre, J. M. (1994). Sample size and item calibration stability.
*Rasch Measurement Transactions, 7*(4), 328.
<https://www.rasch.org/rmt/rmt74m.htm>

Jones, E., & Wind, S. A. (2018). Using repeated ratings to improve
measurement precision in incomplete rating designs. *Journal of Applied
Measurement, 19*(2), 148-161.

## See also

[`detect_facet_nesting()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_facet_nesting.md),
[`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md),
[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md),
[`compute_facet_design_effect()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_design_effect.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md).

## Examples

``` r
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
review <- facet_small_sample_review(fit)
summary(review)
#> mfrm_facet_sample_review
#> 
#> Per-facet summary:
#>      Facet Levels MinN MedianN MaxN WorstCategory
#>  Criterion      4  192     192  192        strong
#>     Person     48   16      16   16      marginal
#>      Rater      4  192     192  192        strong
#> 
#> Sample-size category counts by facet:
#>      Facet sparse marginal standard strong
#>  Criterion      0        0        0      4
#>     Person      0       48        0      0
#>      Rater      0        0        0      4

# Custom thresholds (e.g. a stricter protocol).
strict <- facet_small_sample_review(
  fit,
  thresholds = c(sparse = 15, marginal = 40, standard = 100)
)
strict$facet_summary
#>       Facet Levels MinN MedianN MaxN WorstCategory
#> 1 Criterion      4  192     192  192        strong
#> 2    Person     48   16      16   16      marginal
#> 3     Rater      4  192     192  192        strong
```
