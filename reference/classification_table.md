# Evaluate classification accuracy, consistency and conditional precision

Evaluate a fixed future rating plan under an ordinary RSM/PCM
calibration. Lee-style recursion gives the exact finite summed-score
distribution; the Rudner comparison uses a normal approximation to an ML
ability estimate.

## Usage

``` r
classification_table(
  fit,
  rating_plan,
  cut_scores,
  score_cuts,
  theta,
  theta_weights = NULL,
  operational_cuts = cut_scores,
  facets = NULL,
  readiness_policy = c("error", "review")
)
```

## Arguments

- fit:

  A native ordinary RSM/PCM
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  result (MML or JML), without interactions, random effects or a JML
  correction.

- rating_plan:

  Data frame with one row per future rating and exactly the calibrated
  facet identifier columns. All levels must be known. Duplicate complete
  facet cells, missing identifiers, score columns and observation
  weights are not supported. Each row contributes one rating.

- cut_scores:

  Finite, strictly increasing true-ability category cuts on the
  calibration scale. Optional names label the cuts.

- score_cuts:

  Nondecreasing integer cuts on the sum of **model category indices**,
  each rating scored `0, ..., K-1`. One cut per `cut_scores`. Values
  from zero through the maximum possible sum plus one are allowed.
  Repeated cuts retain empty categories; zero and maximum-plus-one
  retain unreachable edge categories. These are explicit operational
  decisions, not automatically rounded expected scores or sums of
  original labels.

- theta:

  Finite numeric vector of true-ability points to evaluate. Supply a
  grid around the cuts to inspect conditional precision there. Fitted
  EAPs are not automatically substituted for true abilities.

- theta_weights:

  Optional nonnegative population point/quadrature weights corresponding
  to `theta`, with at least one positive entry. Weights are normalized
  and retained. Density values alone are generally insufficient on an
  unequally spaced grid. No default population is used.

- operational_cuts:

  Strictly increasing ability-estimate decision cuts for the Rudner
  approximation, one per true cut. Defaults to `cut_scores`.

- facets:

  Optional character vector mapping calibrated facet names to
  `rating_plan` columns, as in
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md).

- readiness_policy:

  `"error"` requires a ready source calibration. `"review"` permits a
  nonready but valid source and retains its assessment in `source`; it
  does not establish statistical adequacy. Invalid retained parameters
  cannot be overridden.

## Value

A plain list. `table` contains conditional indices, expected sum,
information, SEM and availability for each point/method. `SourceStatus`
in `table`, `probabilities`, `scores`, `cuts`, `marginal` and
`classification_matrix` preserves the separate calibration assessment,
including in CSV exports. `Status`, where present, describes numerical
availability; an available row with `SourceStatus = "review_only"` still
needs source review. Inspect `source$reason_codes` for the reasons.
`probabilities` contains operational category probabilities; `scores`
contains the exact summed-score probability mass. `cuts` reports both
cut scales and SEM at true and operational ability cuts. `marginal` and
`classification_matrix` are empty unless population weights are
supplied. Any unavailable point with positive weight makes its method's
marginal results unavailable; such points are never dropped or
renormalized away. `population` retains input points and raw/normalized
weights. `rating_plan`, `calibration` (offsets, cumulative thresholds
and category map), `source`, `settings` and `notes` retain the
calculation's conditions. A source review status applies to the entire
result, including numerically available rows. Save with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) or export
tables with
[`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html). A
table CSV alone does not retain the plan, cut definitions, population
distribution and notes; keep the full result for reproducible reuse.
Reading saved output does not refit or recalculate anything.

## Details

Both methods are returned. For an operational decision based on the
declared category-score sum, report the `lee_sum` row. For a decision
based on an ML ability estimate, `rudner_normal` is an approximate
comparison, subject to the limitations below. It does not evaluate an
EAP/MAP decision rule. The rows need not describe the same decision;
compare their accuracy as competing calculations only after matching the
actual operational rules. `Status = "available"` means the calculation
succeeded, not that the normal approximation or the fitted model is
accurate for the intended population.

Categories are numbered from 1. Values equal to a cut enter the higher
category: lower endpoints are inclusive, upper endpoints exclusive. The
top category includes the maximum possible sum. True categories use
`cut_scores`; operational categories use `score_cuts` for `lee_sum` and
`operational_cuts` for `rudner_normal`. These can describe different
rules. Expected sums at ability cuts are reported for inspection, never
rounded into a decision rule. In an ordinary fixed-plan Rasch model the
ML score equation is `S = E(S | theta)`. A matched sum cut therefore
requires the actual ML decision mapping, including ties and
extreme-score policy. EAP/MAP decisions do not automatically share that
mapping.

With conditional operational category probabilities `p[h]` and true
category `H(theta)`, accuracy is `p[H(theta)]`; consistency is
`sum(p^2)`. Consistency concerns two conditionally independent
repetitions with the **same** calibrated plan. Overclassification and
underclassification sum probabilities above and below the true category.
Population versions are weighted averages over the supplied true-ability
distribution. The joint matrix contains population joint probabilities,
not row-normalized error rates. Accuracy need not exceed consistency in
a multicategory decision. With two categories, marginal
overclassification is the joint probability of a true fail and an
observed pass; underclassification is the joint probability of a true
pass and an observed fail. Divide each by its true category's population
probability for the error rate conditional on that category. A zero
denominator makes that conditional rate undefined. Conditioning instead
on the observed pass/fail category uses its column sum in the joint
matrix and answers how often that reported decision is wrong.

Information sums conditional category-score variances over the plan.
`SEM = 1/sqrt(Information)` is a conditional **ability-scale** SEM with
calibration fixed, not a posterior SD, sum-score SEM or an SE
propagating facet estimation uncertainty. `rudner_normal` assumes an ML
estimator's sampling distribution is normal with mean `theta` and this
SEM. Short plans, extremes, estimator bias and model misfit can
invalidate that approximation. Zero numerical information gives infinite
SEM and makes Rudner results unavailable; Lee probabilities can remain
available. Arithmetic overflow or unresolved probability mass causes an
error. Narrow normal-probability bands use direct integration when
subtraction of cumulative probabilities would lose precision. Finite
precision does not guarantee relative accuracy in vanishing tails.

Local independence is assumed even when rows share a task or rater.
Calibration, cuts and the plan are held fixed. There is no uncertainty
interval, quality threshold, automatic cut selection, random-rater/task
generalization, retake policy, or propagation of calibration/population
estimation error. Model-based accuracy is not observed reference
agreement. This is also distinct from posterior ability-band
probabilities in
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md).
Passing calibration checks does not validate the future plan or the
normal approximation.

## References

Rudner, L. M. (2001). Computing the expected proportions of
misclassified examinees. *Practical Assessment, Research, and
Evaluation, 7*, Article 14.
[doi:10.7275/an9m-2035](https://doi.org/10.7275/an9m-2035) .

Rudner, L. M. (2005). Expected classification accuracy. *Practical
Assessment, Research, and Evaluation, 10*, Article 13.
[doi:10.7275/56a5-6b14](https://doi.org/10.7275/56a5-6b14) .

Lee, W.-C. (2010). Classification consistency and accuracy for complex
assessments using item response theory. *Journal of Educational
Measurement, 47*(1), 1-17.
[doi:10.1111/j.1745-3984.2009.00096.x](https://doi.org/10.1111/j.1745-3984.2009.00096.x)
.

Wyse, A. E., & Hao, S. (2012). An evaluation of item response theory
classification accuracy and consistency indices. *Applied Psychological
Measurement, 36*(7), 602-624.
[doi:10.1177/0146621612451522](https://doi.org/10.1177/0146621612451522)
.

Lathrop, Q. N., & Cheng, Y. (2013). Two approaches to estimation of
classification accuracy rate under item response theory. *Applied
Psychological Measurement, 37*(3), 226-241.
[doi:10.1177/0146621612471888](https://doi.org/10.1177/0146621612471888)
.

## See also

[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md),
[`score_comparison_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_comparison_table.md)

## Examples

``` r
ratings <- load_mfrmr_data("example_operational")
fit <- fit_mfrm(ratings, person = "Person", facets = c("Rater", "Criterion"),
  score = "Score", method = "MML", model = "RSM",
  rating_min = 1, rating_max = 4, category_policy = "preserve")
# The planned roster includes the intended ratings even if scores are missing.
data("mfrmr_example_operational_design", package = "mfrmr")
rating_plan <- subset(mfrmr_example_operational_design, Person == "P001",
  select = c("Rater", "Criterion"))
rating_plan # Six ratings: two raters, each scoring three criteria.
#>   Rater    Criterion
#> 1   R01      Content
#> 2   R01     Language
#> 3   R01 Organization
#> 4   R02      Content
#> 5   R02     Language
#> 6   R02 Organization
# Illustrative rules: ability at least 0 logits; original-score sum at least 18.
# score_cuts uses 0:3 category indices, not the original 1:4 score labels:
# subtract 1 for each of the six ratings, so 18 - 6 = 12.
# These are different decision rules, not automatically equivalent cutoffs.
result <- classification_table(fit, rating_plan,
  cut_scores = 0, score_cuts = 12, theta = c(-0.5, 0, 0.5))
result$table
#>   Point Theta TrueCategory        Method  Accuracy Consistency
#> 1     1  -0.5            1       lee_sum 0.9033270   0.8253454
#> 2     1  -0.5            1 rudner_normal 0.8505279   0.7457396
#> 3     2   0.0            2       lee_sum 0.4008877   0.5196465
#> 4     2   0.0            2 rudner_normal 0.5000000   0.5000000
#> 5     3   0.5            2       lee_sum 0.7790621   0.6557513
#> 6     3   0.5            2 rudner_normal 0.8308507   0.7189244
#>   Overclassification Underclassification ExpectedSum Information       SEM
#> 1         0.09667296           0.0000000    8.798214    4.315591 0.4813709
#> 2         0.14947214           0.0000000    8.798214    4.315591 0.4813709
#> 3         0.00000000           0.5991123   10.955735    4.229732 0.4862320
#> 4         0.00000000           0.5000000   10.955735    4.229732 0.4862320
#> 5         0.00000000           0.2209379   12.947095    3.667473 0.5221755
#> 6         0.00000000           0.1691493   12.947095    3.667473 0.5221755
#>      Status SourceStatus
#> 1 available        ready
#> 2 available        ready
#> 3 available        ready
#> 4 available        ready
#> 5 available        ready
#> 6 available        ready
result$cuts
#>    Cut TrueCut OperationalAbilityCut ScoreCut ExpectedSumAtTrueCut
#> 1 Cut1       0                     0       12             10.95574
#>   InformationAtTrueCut SEMAtTrueCut ExpectedSumAtOperationalCut
#> 1             4.229732     0.486232                    10.95574
#>   InformationAtOperationalCut SEMAtOperationalCut SourceStatus
#> 1                    4.229732            0.486232        ready
result$settings$calibration # These probabilities hold calibration fixed.
#> [1] "fixed_point_estimates"
# No population average is inferred from this three-point inspection grid.
```
