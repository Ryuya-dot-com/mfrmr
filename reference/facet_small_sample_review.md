# Review rating counts for each facet level

Reports per-level observation counts, SE, and fit statistics for every
level of every facet in a fitted MFRM model, and classifies each level
as `"sparse"`, `"marginal"`, `"standard"`, or `"strong"` using
configurable count bands. These labels identify levels to inspect; they
do not establish measurement precision or sample adequacy.

## Usage

``` r
facet_small_sample_review(
  fit,
  diagnostics = NULL,
  thresholds = c(sparse = 10, marginal = 30, standard = 50)
)

# S3 method for class 'mfrm_facet_sample_review'
plot(
  x,
  top_n = NULL,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE,
  ...
)
```

## Arguments

- fit:

  An `mfrm_fit` from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  output from the same `fit`. When supplied, per-level `Infit` and
  `Outfit` are added. `Estimate` and `SE` come from the fitted facet
  tables; unavailable SEs remain missing.

- thresholds:

  Named numeric vector of count bands. Defaults are
  `c(sparse = 10, marginal = 30, standard = 50)`. Supply exactly these
  three names with finite, positive values satisfying
  `sparse < marginal < standard`; their order in the vector is
  immaterial. The defaults are package screening choices, not precision
  thresholds.

- x:

  An `mfrm_facet_sample_review` object.

- top_n:

  Optional integer; trim the y-axis to the `top_n` smallest level counts
  per facet. `NULL` (default) keeps all.

- preset:

  One of `"standard"`, `"publication"`, `"compact"`, `"monochrome"`.

- draw:

  Logical; print the `ggplot` figure when `TRUE`.

- ...:

  Reserved.

## Value

A list of class `mfrm_facet_sample_review` with:

- `table`: one row per `(Facet, Level)` with `N`, `Estimate`, `SE`,
  `Infit`, `Outfit`, and `SampleCategory`. Added columns give `Ratings`,
  `Persons`, per-person rating counts, observed/declared category
  counts, `DataBasis` and `RatingCountBand`.

- `summary`: counts of levels in each sample-size category, by facet.

- `facet_summary`: count range and lowest count band per facet.

- `crossings`: per-level observed/retained counts of other facet levels.

- `categories`: per-level original-score counts, including unused
  categories.

- `thresholds`: the applied count bands.

- `notes`: count definition and interpretation limits, also shown by
  [`print()`](https://rdrr.io/r/base/print.html) and
  [`summary()`](https://rdrr.io/r/base/summary.html).

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
extracts the plotted table, thresholds, and interpretation `notes`.

## Details

`N` counts retained rating rows for a level in `fit$prep$data`, without
summing observation weights. For a rater it counts ratings, not distinct
examinees; for a person it counts that person's ratings. Repeated or
dependent ratings need not supply independent information. Review the
counts alongside targeting, connectedness, category use, the estimation
method, and available uncertainty estimates before drawing conclusions.
`Ratings` repeats `N` with an explicit unit; `Persons` counts distinct
recorded Person IDs. `MinRatingsPerPerson`, `MedianRatingsPerPerson`,
and `MaxRatingsPerPerson` describe each person's retained rows at that
level. `crossings` counts the observed levels of each other facet
separately; `categories` reports every declared score, including zero
counts. Missing stored category coding produces unavailable counts, not
zeros. These are descriptive counts, not effective sample sizes or rank
checks.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot a
facet sample-size review

Per-level observation counts rendered as a horizontal bar chart coloured
by the count band assigned in `facet_small_sample_review()`. Vertical
dashed lines mark the sparse / marginal / standard thresholds so
reviewers see where every facet level sits relative to the selected
screening thresholds. Counts and colours do not establish measurement
precision.

## Interpreting output

With the default thresholds, the four labels mean only `N < 10`,
`10 <= N < 30`, `30 <= N < 50`, and `N >= 50`, respectively.
`WorstCategory` is the lowest count band represented within a facet.
Neither `"standard"` nor `"strong"` guarantees narrow intervals, correct
coverage, good targeting, or suitability for publication. Do not pool or
discard levels solely because of a count label. The existing
`SampleCategory` and threshold names remain for compatibility. Console
and plot labels use numeric rating-count bands. `DataBasis` identifies
full-model data or the retained data of a limiting-likelihood fit.
Location `Estimate`/`SE` values come from the fitted facet tables, not
slope estimates. If full-model optimization was skipped, `EstimateBasis`
marks neutral reference values that must not be interpreted as
estimates.

Linacre (1994) relates Rasch item/person precision to sample size under
targeting and model assumptions. Those guidelines do not establish a
precision guarantee for these raw many-facet rating counts. Jones and
Wind (2018) study repeated ratings in incomplete designs and highlight
examinee precision. Integrating over a population distribution in MML
does not remove uncertainty in individual person scores. Interpret `SE`
according to the fitted estimator; this count review adds no interval
qualification or hierarchical model.

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

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## References

Linacre, J. M. (1994). Sample size and item calibration stability.
*Rasch Measurement Transactions, 7*(4), 328.
<https://rasch.org/rmt/rmt74m.htm>

Jones, E., & Wind, S. A. (2018). Using repeated ratings to improve
measurement precision in incomplete rating designs. *Journal of Applied
Measurement, 19*(2), 148-161. PMID: 29894984.

## See also

[`detect_facet_nesting()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_facet_nesting.md),
[`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md),
[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md),
[`compute_facet_design_effect()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md),
[mfrm_report_checklist](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md).

`facet_small_sample_review()`.

## Examples

``` r
toy <- load_mfrmr_data("example_operational")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML", quad_points = 7, maxit = 30)
review <- facet_small_sample_review(fit)
summary(review)
#> mfrm_facet_sample_review
#> 
#> Ratings count retained rows without weighting; Persons count distinct recorded Person IDs, not effective sample sizes.
#> Ratings per Person refer only to the named facet level. Crossing counts describe other facets separately, not joint connectivity or identification.
#> Category counts include unused declared categories. Counts, count bands and numerical convergence do not establish precision or interval coverage.
#> N counts retained rating rows per level, not distinct persons, weight sums, or effective sample sizes.
#> Count bands are screening labels; they do not establish precision, interval coverage, or targeting. 
#> 
#> Per-facet summary:
#>      Facet Levels MinN MedianN MaxN LowestRatingCountBand MinPersons
#>  Criterion      3   94      94   94         Ratings >= 50         48
#>     Person     48    5       6    6          Ratings < 10          1
#>      Rater      6   38      47   56    30 <= Ratings < 50         13
#>  MedianPersons MaxPersons
#>             48         48
#>              1          1
#>             16         19
#> 
#> Rating-count bands by facet (not precision grades):
#>      Facet Ratings < 10 10 <= Ratings < 30 30 <= Ratings < 50 Ratings >= 50
#>  Criterion            0                  0                  0             3
#>     Person           48                  0                  0             0
#>      Rater            0                  0                  4             2
#> 
#> Levels below the first threshold (rating rows < 10 ):
#>   Facet Level N Persons     Estimate        SE RatingCountBand
#>  Person  P001 5       1  0.223718682 0.4819485    Ratings < 10
#>  Person  P002 6       1  0.710546034 0.5769040    Ratings < 10
#>  Person  P003 6       1  0.025175839 0.3014112    Ratings < 10
#>  Person  P004 6       1  0.145307072 0.4063532    Ratings < 10
#>  Person  P005 6       1 -0.067924339 0.3332531    Ratings < 10
#>  Person  P006 5       1  0.707205764 0.5929125    Ratings < 10
#>  Person  P007 6       1 -1.041529288 0.3853554    Ratings < 10
#>  Person  P008 6       1 -0.227807377 0.4706276    Ratings < 10
#>  Person  P009 6       1 -0.513303518 0.5768065    Ratings < 10
#>  Person  P010 6       1 -0.067924339 0.3332531    Ratings < 10
#>  Person  P011 5       1 -0.113435183 0.4089420    Ratings < 10
#>  Person  P012 6       1 -0.300788956 0.5137565    Ratings < 10
#>  Person  P013 6       1  0.898236466 0.4992476    Ratings < 10
#>  Person  P014 6       1 -1.261998891 0.4297367    Ratings < 10
#>  Person  P015 6       1  1.445528324 0.5390337    Ratings < 10
#>  Person  P016 6       1 -1.261998891 0.4297367    Ratings < 10
#>  Person  P017 6       1 -0.615422601 0.5815007    Ratings < 10
#>  Person  P018 6       1 -0.300788956 0.5137565    Ratings < 10
#>  Person  P019 6       1  0.593800118 0.5814638    Ratings < 10
#>  Person  P020 6       1 -0.106698851 0.3699661    Ratings < 10
#>  Person  P021 6       1  0.286716989 0.5061980    Ratings < 10
#>  Person  P022 6       1 -0.002887683 0.2942347    Ratings < 10
#>  Person  P023 6       1 -1.134035661 0.4247138    Ratings < 10
#>  Person  P024 5       1  0.078177406 0.3906326    Ratings < 10
#>  Person  P025 6       1  0.896552902 0.4926192    Ratings < 10
#>  Person  P026 6       1 -0.106698851 0.3699661    Ratings < 10
#>  Person  P027 6       1  1.076228538 0.3585948    Ratings < 10
#>  Person  P028 5       1 -0.154080721 0.4367810    Ratings < 10
#>  Person  P029 6       1 -1.371387690 0.5135878    Ratings < 10
#>  Person  P030 6       1  1.164752547 0.3353590    Ratings < 10
#>  Person  P031 6       1  0.224679916 0.4679431    Ratings < 10
#>  Person  P032 6       1 -1.708566428 0.6302426    Ratings < 10
#>  Person  P033 6       1 -1.371387690 0.5135878    Ratings < 10
#>  Person  P034 6       1  0.508330362 0.5763367    Ratings < 10
#>  Person  P035 6       1  0.224679916 0.4679431    Ratings < 10
#>  Person  P036 6       1  1.202260432 0.3420540    Ratings < 10
#>  Person  P037 6       1 -1.318970599 0.4942716    Ratings < 10
#>  Person  P038 6       1  0.119411998 0.3830059    Ratings < 10
#>  Person  P039 5       1 -0.325465141 0.5354351    Ratings < 10
#>  Person  P040 6       1 -1.318970599 0.4942716    Ratings < 10
#>  Person  P041 6       1 -1.115802396 0.4328999    Ratings < 10
#>  Person  P042 6       1 -0.272258812 0.4992877    Ratings < 10
#>  Person  P043 6       1 -0.405495533 0.5562532    Ratings < 10
#>  Person  P044 6       1 -0.735556497 0.5634513    Ratings < 10
#>  Person  P045 6       1  1.425164270 0.5323968    Ratings < 10
#>  Person  P046 6       1 -0.405495533 0.5562532    Ratings < 10
#>  Person  P047 6       1 -1.153353508 0.3744804    Ratings < 10
#>  Person  P048 6       1  0.066129149 0.3368592    Ratings < 10

# Custom thresholds (e.g. a stricter protocol).
strict <- facet_small_sample_review(
  fit,
  thresholds = c(sparse = 15, marginal = 40, standard = 100)
)
strict$facet_summary
#>       Facet Levels MinN MedianN MaxN WorstCategory LowestRatingCountBand
#> 1 Criterion      3   94      94   94      standard   40 <= Ratings < 100
#> 2    Person     48    5       6    6        sparse          Ratings < 15
#> 3     Rater      6   38      47   56      marginal    15 <= Ratings < 40
#>   MinPersons MedianPersons MaxPersons
#> 1         48            48         48
#> 2          1             1          1
#> 3         13            16         19
```
