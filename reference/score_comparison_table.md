# Compare aligned scores against reference ratings

Summarize agreement, association and mean differences for two score
sources, with an optional second-reference baseline. Sources can be
human raters, scoring systems or other scoring procedures using the same
rubric. No measurement-model fit is needed for the score comparisons.

## Usage

``` r
score_comparison_table(
  scores,
  reference,
  reference2 = NULL,
  categories,
  score_categories = scores,
  smd = c("pooled", "reference"),
  screen = c("none", "williamson2012"),
  qwk_min = NULL,
  correlation_min = NULL,
  max_degradation = NULL,
  max_abs_smd = NULL,
  fit = NULL,
  diagnostics = NULL,
  rater_facet = NULL,
  rater = NULL
)
```

## Arguments

- scores:

  Numeric scores from the source being evaluated, before rounding.

- reference:

  Numeric reference ratings on the declared categories. A reference is a
  comparison source, not necessarily an error-free criterion.

- reference2:

  Optional second reference rating of each response. Its agreement with
  `reference` supplies the baseline for degradation.

- categories:

  All permitted numeric score categories, in increasing order, including
  categories not observed in this sample.

- score_categories:

  Scores expressed on `categories`. Defaults to `scores`. For continuous
  scores, supply an explicitly categorized vector. No rounding,
  clipping, category inference or averaging is performed.

- smd:

  SMD denominator: `"pooled"` uses the square root of the mean of the
  two sample variances; `"reference"` uses the reference sample SD. Both
  SMDs are returned. SDs use the sample divisor `N - 1`.

- screen:

  `"none"` (default) applies no automatic thresholds. `"williamson2012"`
  selects the automated-scoring examples discussed by Williamson, Xi,
  and Breyer (2012): QWK and correlation \>= .70, agreement degradation
  \<= .10, and absolute SMD \<= .15.

- qwk_min, correlation_min:

  Optional minimum QWK and Pearson correlation.

- max_degradation:

  Optional maximum baseline-minus-score agreement, applied separately to
  QWK and correlation. Negative degradation indicates higher agreement
  of `scores` with `reference` than the baseline.

- max_abs_smd:

  Optional maximum absolute selected SMD. Non-NULL threshold arguments
  override the selected screen. With `screen = "none"`, only explicitly
  supplied thresholds are applied.

- fit:

  Optional native additive RSM/PCM
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  result containing the selected scorer as a rater. This function does
  not fit a model.

- diagnostics:

  Optional matching
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  result, supplying saved Infit/Outfit. No diagnostics are computed
  here.

- rater_facet, rater:

  With `fit`, the explicit facet name and level identifying the scorer
  being evaluated.

## Value

A list with `table` (one comparison row), `criteria` (five statistics,
optional thresholds, availability and reasons), `cases` (row
disposition), `counts` (`scores_reference` and `reference2_reference`
category tables), `settings`, `mfrm` (optional saved source metadata),
and `notes`. Save with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) and reopen with
[`base::readRDS()`](https://rdrr.io/r/base/readRDS.html). Export the
data frames with
[`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html). No
ICC, alpha or AC2 is computed.

## Details

Vectors must already be aligned: one entry per same response in the same
order, on one common rubric/score scale. Match Person, task, criterion
and occasion before calling. Repeated ratings are not collapsed. All
statistics use the same complete cases across supplied vectors,
including `score_categories` and `reference2`. Every row's inclusion and
missing-input flags are retained in `cases`; missingness may affect
representativeness.

QWK is \\1-D_o/D_e\\, where \\D_o\\ is observed mean squared category
disagreement and \\D_e\\ uses independent draws from empirical
marginals. Distances use numeric category values, not their ranks. The
denominator is not MFRM model-implied expected agreement. Constant
identical ratings have undefined QWK. Correlation uses unrounded scores.
SMD is signed `scores` minus `reference`; numerical screens use its
absolute value.

`ReferenceQWK` and `ReferenceCorrelation` compare `reference2` with
`reference`; degradation subtracts the score-reference statistic from
that baseline. These columns are unavailable without a second reference.
`criteria` retains all five statistics, even when no thresholds are
requested. Its status is `"not_requested"` for a finite statistic
without a threshold, `"unavailable"` for an undefined statistic, or
`"within_threshold"` / `"review"` when an inclusive threshold is
applied. No combined approval, significance test or sampling uncertainty
is inferred.

The optional Williamson screen concerns joint human/automated scoring;
it is not a universal standard for all score comparisons. It evaluates
unrounded statistics and does not reproduce the paper's unspecified
rounding convention or operational exceptions. Its overall SMD example
is .15; the subgroup discussion uses .10. The source's p. 8 prose uses
human-SD SMD, whereas p. 12 note 4 uses the pooled formula. The default
follows the formula and retains `SMDReference` for sensitivity review.
Evaluation data/tasks should be separate from model development as
required by the intended use. Construct relevance, reference quality,
external validity, generalizability, subgroup differences and
consequences require additional evidence.

Optional MFRM columns describe **all retained source ratings for the
selected rater**, which need not be the comparison cohort. Source
counts, readiness, model settings and scope are retained separately.
Severity is in logits, oriented so positive values imply lower expected
ratings; its zero is the fitted model reference. Severity and
Infit/Outfit do not measure criterion accuracy and receive no automatic
quality threshold.

## References

Williamson, D. M., Xi, X., & Breyer, F. J. (2012). A framework for
evaluation and use of automated scoring. *Educational Measurement:
Issues and Practice, 31*(1), 2-13.
[doi:10.1111/j.1745-3992.2011.00223.x](https://doi.org/10.1111/j.1745-3992.2011.00223.x)
Especially pp. 7-10 and p. 12, notes 1 and 4.

## See also

[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md),
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md),
[`automated_scoring_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/automated_scoring_table.md)
for the earlier automated-scoring interface.

## Examples

``` r
comparison <- score_comparison_table(
  scores = c(0, 1, 2, 2, 3, 3), reference = c(0, 1, 1, 2, 3, 3),
  categories = 0:3
)
comparison$table
#>   NInput N NExcluded Reference2Supplied MeanScore MeanReference  SDScore
#> 1      6 6         0              FALSE  1.833333      1.666667 1.169045
#>   SDReference       QWK ReferenceQWK QWKDegradation Correlation
#> 1     1.21106 0.9302326           NA             NA   0.9417632
#>   ReferenceCorrelation CorrelationDegradation      SMD SMDBasis SMDPooled
#> 1                   NA                     NA 0.140028   pooled  0.140028
#>   SMDReference MFRMSeverity MFRMInfit MFRMOutfit MFRMRatingRows MFRMWeightSum
#> 1    0.1376205           NA        NA         NA             NA            NA
#>   MFRMFacet MFRMRater MFRMModel MFRMMethod   MFRMStatus    MFRMScope
#> 1      <NA>      <NA>      <NA>       <NA> not_supplied not_supplied
# The automated-scoring screen is an explicit application choice.
auto_comparison <- score_comparison_table(
  scores = c(0.2, 0.9, 1.3, 2.1, 2.7, 2.8),
  reference = c(0, 1, 1, 2, 3, 3), reference2 = c(0, 1, 2, 2, 2, 3),
  categories = 0:3, score_categories = c(0, 1, 1, 2, 3, 3),
  screen = "williamson2012"
)
auto_comparison$criteria
#>                   Metric      Value Operator Threshold Reason Available N
#> 1                    QWK  1.0000000       >=      0.70             TRUE 6
#> 2            Correlation  0.9893211       >=      0.70             TRUE 6
#> 3         QWKDegradation -0.1578947       <=      0.10             TRUE 6
#> 4 CorrelationDegradation -0.1365182       <=      0.10             TRUE 6
#> 5            AbsoluteSMD  0.0000000       <=      0.15             TRUE 6
#>                         Basis           Status
#> 1          categorized_scores within_threshold
#> 2            unrounded_scores within_threshold
#> 3          categorized_scores within_threshold
#> 4            unrounded_scores within_threshold
#> 5 unrounded_scores_smd_pooled within_threshold
```
