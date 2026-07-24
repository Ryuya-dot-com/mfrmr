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
toy <- load_mfrmr_data("example_operational")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML", quad_points = 7, maxit = 30)
review <- facet_small_sample_review(fit)
summary(review)
#> mfrm_facet_sample_review
#> 
#> Per-facet summary:
#>      Facet Levels MinN MedianN MaxN WorstCategory
#>  Criterion      3   94      94   94        strong
#>     Person     48    5       6    6        sparse
#>      Rater      6   38      47   56        strong
#> 
#> Sample-size category counts by facet:
#>      Facet sparse marginal standard strong
#>  Criterion      0        0        0      3
#>     Person     48        0        0      0
#>      Rater      0        0        4      2
#> 
#> Sparse levels (n < 10 ):
#>   Facet Level N     Estimate        SE SampleCategory
#>  Person  P001 5  0.223718682 0.4819485         sparse
#>  Person  P002 6  0.710546034 0.5769040         sparse
#>  Person  P003 6  0.025175839 0.3014112         sparse
#>  Person  P004 6  0.145307072 0.4063532         sparse
#>  Person  P005 6 -0.067924339 0.3332531         sparse
#>  Person  P006 5  0.707205764 0.5929125         sparse
#>  Person  P007 6 -1.041529288 0.3853554         sparse
#>  Person  P008 6 -0.227807377 0.4706276         sparse
#>  Person  P009 6 -0.513303518 0.5768065         sparse
#>  Person  P010 6 -0.067924339 0.3332531         sparse
#>  Person  P011 5 -0.113435183 0.4089420         sparse
#>  Person  P012 6 -0.300788956 0.5137565         sparse
#>  Person  P013 6  0.898236466 0.4992476         sparse
#>  Person  P014 6 -1.261998891 0.4297367         sparse
#>  Person  P015 6  1.445528324 0.5390337         sparse
#>  Person  P016 6 -1.261998891 0.4297367         sparse
#>  Person  P017 6 -0.615422601 0.5815007         sparse
#>  Person  P018 6 -0.300788956 0.5137565         sparse
#>  Person  P019 6  0.593800118 0.5814638         sparse
#>  Person  P020 6 -0.106698851 0.3699661         sparse
#>  Person  P021 6  0.286716989 0.5061980         sparse
#>  Person  P022 6 -0.002887683 0.2942347         sparse
#>  Person  P023 6 -1.134035661 0.4247138         sparse
#>  Person  P024 5  0.078177406 0.3906326         sparse
#>  Person  P025 6  0.896552902 0.4926192         sparse
#>  Person  P026 6 -0.106698851 0.3699661         sparse
#>  Person  P027 6  1.076228538 0.3585948         sparse
#>  Person  P028 5 -0.154080721 0.4367810         sparse
#>  Person  P029 6 -1.371387690 0.5135878         sparse
#>  Person  P030 6  1.164752547 0.3353590         sparse
#>  Person  P031 6  0.224679916 0.4679431         sparse
#>  Person  P032 6 -1.708566428 0.6302426         sparse
#>  Person  P033 6 -1.371387690 0.5135878         sparse
#>  Person  P034 6  0.508330362 0.5763367         sparse
#>  Person  P035 6  0.224679916 0.4679431         sparse
#>  Person  P036 6  1.202260432 0.3420540         sparse
#>  Person  P037 6 -1.318970599 0.4942716         sparse
#>  Person  P038 6  0.119411998 0.3830059         sparse
#>  Person  P039 5 -0.325465141 0.5354351         sparse
#>  Person  P040 6 -1.318970599 0.4942716         sparse
#>  Person  P041 6 -1.115802396 0.4328999         sparse
#>  Person  P042 6 -0.272258812 0.4992877         sparse
#>  Person  P043 6 -0.405495533 0.5562532         sparse
#>  Person  P044 6 -0.735556497 0.5634513         sparse
#>  Person  P045 6  1.425164270 0.5323968         sparse
#>  Person  P046 6 -0.405495533 0.5562532         sparse
#>  Person  P047 6 -1.153353508 0.3744804         sparse
#>  Person  P048 6  0.066129149 0.3368592         sparse

# Custom thresholds (e.g. a stricter protocol).
strict <- facet_small_sample_review(
  fit,
  thresholds = c(sparse = 15, marginal = 40, standard = 100)
)
strict$facet_summary
#>       Facet Levels MinN MedianN MaxN WorstCategory
#> 1 Criterion      3   94      94   94      standard
#> 2    Person     48    5       6    6        sparse
#> 3     Rater      6   38      47   56      standard
```
