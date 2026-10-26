# Describe rater centrality using RSM residuals and rater-specific PCM steps

Place indirect centrality indices alongside their model basis, exposure
and availability. These statistics describe fitted ratings; they do not
classify raters or estimate a centrality parameter.

## Usage

``` r
rater_centrality_table(fit = NULL, threshold_fit = NULL, rater_facet = "Rater")
```

## Arguments

- fit:

  Optional native additive RSM fit from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
  for residual versus expected-score correlations and ordinary
  Infit/Outfit.

- threshold_fit:

  Optional native additive PCM fit with `step_facet` equal to
  `rater_facet`, for the spread of rater-specific step estimates. At
  least one of `fit` and `threshold_fit` must be supplied.

- rater_facet:

  Name of the fitted non-Person rater facet.

## Value

A list containing `table` (one row per rater), `thresholds`
(category-ordered PCM step estimates), `categories` (counts on the
retained roster), `sources` (model settings, estimates and readiness),
`settings` and `notes`. Each index has an availability reason; source
readiness is separate from numerical availability. Save with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) and reopen with
[`base::readRDS()`](https://rdrr.io/r/base/readRDS.html); export the
data frames with
[`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html).
Reopening the result does not recalculate indices. This plain list has
no dedicated [`plot()`](https://rdrr.io/r/graphics/plot.default.html) or
automatic aggregate-report section. For a custom figure, retain each
index's reason and source-status columns; do not mix threshold SD,
residual correlation and fit on one scale. Graph centrality from
[`rater_halo_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_halo_network_analysis.md)
has a different meaning.

## Details

Eckes and Jin (2021, pp. 68-70, 77, 83-85) distinguish RSM
residual-based indices from threshold SD under a rater-specific PCM.
Accordingly, this function never assigns a shared RSM threshold SD to
individual raters or substitutes a criterion-specific PCM for a
rater-specific PCM. Supplying only one model leaves the other indices
unavailable with an explicit reason. Both models must use the same
retained response roster, including row multiplicities, category
mapping, facet signs, centering and anchors. Row order may differ. Each
model's estimator and readiness are retained.

Current support is ordinary JML or MML, unit observation weights,
additive RSM/PCM and no facet shrinkage. Imported fits, interactions,
generalized slope models, corrected JML, testlet and shared-random-rater
models require their own definitions. There is no model fitting,
quadrature or covariance estimation here. RSM response expectations are
evaluated at saved point estimates using the same probability
calculation as
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
MML uses saved Person EAP scores: these are plug-in expectations, not
posterior-integrated or posterior-predictive expectations. Estimation
and assignment effects can affect these indices even without true
centrality.

`ResidualExpectedCorrelation` is the unweighted Pearson correlation of
raw residuals (observed minus expected score) with expected scores
within a rater. More negative correlations are consistent with scores
compressed toward the middle. Standardized residuals are not used. A
correlation requires at least two complete rows with nonconstant
residuals and expected scores. Missing or nonfinite expectations, or a
nonfinite primary Person/facet estimate involved in a row, make that
rater's residual indices unavailable; incomplete subsets are not
silently analyzed. Infit and Outfit additionally require strictly
positive finite response variances in every row. Infit is
`sum(residual^2) / sum(variance)`; Outfit is
`mean(residual^2 / variance)`.

`ThresholdSD` is the sample SD across the complete set of a rater's `m`
adjacent-category step estimates (divisor `m - 1`, explicitly chosen
here; the paper does not specify the divisor). `ThresholdVariance` is
its square. Larger spreads are consistent with centrality and smaller
spreads with extremity. Steps are centered offsets in logits, not
cumulative thresholds; adding the same rater severity/location to each
step leaves their SD unchanged. At least two finite steps are required:
a binary rubric cannot supply this spread. Steps are kept in category
order. Disorder is reported, not repaired by sorting estimates; spread
alone does not establish proper category functioning. `ObservedSD`
describes the fitted internal score coding, with original-category
labels retained in `categories`.

Infit/Outfit are supporting fit descriptions. Low Infit can also reflect
halo, restricted score ranges or other mechanisms. No default .75, -.30
or 1.40 cutoff, combined flag, significance test or confidence interval
is supplied. Threshold uncertainty, sparse exposure, different ability
mixes, criterion mixtures and dependence between ratings affect
interpretation. This function does not implement the Bayesian FM-SC
centrality parameter omega, its uncertainty or ability adjustments, and
does not reproduce FACETS numerical output merely by using related
formulas. The package's `ej2021` example data are synthetic, not the
original TestDaF samples.

In the direct FM-SC model, rater severity shifts category locations
while a positive rater-specific omega multiplies category step offsets.
Omega therefore changes the response model and its ability estimates; it
is not the SD of separately fitted PCM steps or a GPCM discrimination
coefficient. Jin and Wang (2018) introduce this model; Eckes and Jin
(2021, p. 71) give its RSM formulation. They are references for the
distinction, not additional estimation methods available through this
function.

## References

Eckes, T., & Jin, K.-Y. (2021). Measuring rater centrality effects in
writing assessment: A Bayesian facets modeling approach. *Psychological
Test and Assessment Modeling, 63*(1), 65-94. Definitions and actual
analyses: pp. 68-70 and 77; comparisons and limitations: pp. 83-88.
[Full
text](https://www.psychologie-aktuell.com/fileadmin/download/ptam/1-2021/Seiten_aus_PTAM_2021-1_ebook_4.pdf).

Jin, K.-Y., & Wang, W.-C. (2018). A new facets model for rater's
centrality/extremity response style. *Journal of Educational
Measurement, 55*(4), 543-563.
[doi:10.1111/jedm.12191](https://doi.org/10.1111/jedm.12191) . Direct
model, not implemented here.

## See also

[`score_comparison_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_comparison_table.md),
[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md),
[mfrmr_methods_reference](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_methods_reference.md)

## Examples

``` r
ratings <- load_mfrmr_data("example_core")
rsm <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", model = "RSM", maxit = 100)
pcm <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", model = "PCM", step_facet = "Rater",
                maxit = 100)
centrality <- rater_centrality_table(rsm, pcm, rater_facet = "Rater")
centrality$table
#>   Rater RatingRows Persons ObservedSD ResidualExpectedCorrelation     Infit
#> 1   R01        192      48  0.9860363                -0.007414537 1.0505513
#> 2   R02        192      48  0.9141694                -0.069025866 0.9226016
#> 3   R03        192      48  0.9866031                 0.039392151 0.9642962
#> 4   R04        192      48  1.0068347                 0.048523318 1.0365353
#>      Outfit ResidualRows ResidualUnavailableRows ResidualReason FitReason
#> 1 1.0445121          192                       0      available available
#> 2 1.0421576          192                       0      available available
#> 3 0.9698955          192                       0      available available
#> 4 1.0180480          192                       0      available available
#>   ThresholdSD ThresholdVariance ThresholdCount ThresholdsOrdered
#> 1    1.312674          1.723112              3              TRUE
#> 2    1.621624          2.629663              3              TRUE
#> 3    1.309707          1.715332              3              TRUE
#> 4    1.180770          1.394218              3              TRUE
#>   ThresholdReason ResidualMethod ThresholdMethod ResidualSourceStatus
#> 1       available            JML             JML          descriptive
#> 2       available            JML             JML          descriptive
#> 3       available            JML             JML          descriptive
#> 4       available            JML             JML          descriptive
#>   ThresholdSourceStatus
#> 1           descriptive
#> 2           descriptive
#> 3           descriptive
#> 4           descriptive
centrality$thresholds
#>    Rater   Step    Estimate SDDivisor
#> 1    R01 Step_1 -1.18158353         2
#> 2    R01 Step_2 -0.23140496         2
#> 3    R01 Step_3  1.41298849         2
#> 4    R02 Step_1 -1.56502942         2
#> 5    R02 Step_2 -0.10780841         2
#> 6    R02 Step_3  1.67283783         2
#> 7    R03 Step_1 -1.34561209         2
#> 8    R03 Step_2  0.07503695         2
#> 9    R03 Step_3  1.27057514         2
#> 10   R04 Step_1 -1.23992533         2
#> 11   R04 Step_2  0.12888582         2
#> 12   R04 Step_3  1.11103951         2
# Review both SourceStatus columns before interpreting finite indices.
```
