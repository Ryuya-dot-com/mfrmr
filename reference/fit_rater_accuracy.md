# Estimate criterion-referenced rater accuracy from exact matches

Fit a binary many-facet Rasch model to agreement with supplied reference
ratings. Raters are the objects of measurement; higher accuracy logits
indicate a greater probability of matching the reference, after
adjusting for the difficulty facets.

## Usage

``` r
fit_rater_accuracy(
  data,
  rater,
  facets,
  score,
  reference,
  method = c("JML", "MML"),
  maxit = 400,
  reltol = 1e-09,
  quad_points = 31
)
```

## Arguments

- data:

  A data frame with one row per rater and benchmark combination.

- rater:

  Name of the rater identifier column.

- facets:

  Names of one or more difficulty-facet columns. Their joint combination
  identifies a benchmark, for example `c("Essay", "Domain")`. For a
  separate difficulty for every performance-domain combination, supply a
  single preconstructed benchmark identifier instead. These are
  different models; choose the structure substantively.

- score, reference:

  Names of aligned observed and reference rating columns. Both must be
  numeric, or both character/factor category labels. Numeric equality is
  exact; factors are compared by labels. Scores must already be
  categorized. No rounding, averaging or partial credit occurs.

- method:

  Ordinary `"JML"` (default) or `"MML"`; see Details.

- maxit, reltol, quad_points:

  Optimization and quadrature controls passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
  Quadrature applies only to MML.

## Value

A plain list with `table` (rater counts, exact agreement, accuracy,
posterior SD and source status), `difficulty` (facet locations), `cases`
(all input rows, binary matches and missingness), `fit` (native
`mfrm_fit`), `settings` and `notes`. Internal `Person` identifiers in
`fit` refer to raters; `Facet1`, `Facet2`, etc. refer to the requested
difficulty facets. `settings$column_map` records this mapping, also used
by `cases`. Interpret native fit reports by these roles, not their
default examinee/rater labels. `difficulty$Facet` restores the input
facet names. Save the complete result with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html); the data
frames can be exported with
[`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html).
Reading saved output does not refit.

## Details

Following the dichotomous example in Engelhard, Wang and Wind (2018, pp.
42-43), each complete pair becomes `Match = 1` for equality and `0`
otherwise. The additive model is
`logit Pr(Match = 1) = accuracy[rater] - sum(difficulty[facet level])`.
Each difficulty facet is sum-to-zero centered; accuracy locations are
free. There is no free binary threshold. This function reuses the native
RSM estimator on the declared 0/1 scale, with unit weights, no
interactions, anchors, shrinkage or JML correction. It does not
reproduce the paper's interaction tests or its FACETS results.

References are treated as fixed supplied benchmarks. Their quality,
selection and adjudication require substantive justification; their
uncertainty is not estimated. A benchmark must have at most one distinct
nonmissing reference across raters, even on rows with missing observed
scores. Repeated rater-by-benchmark rows are rejected, including
repetitions with a missing score. Choose independent observations and an
appropriate facet structure before fitting. Identifiers must be present
and nonblank. Distinct numeric identifiers that become the same text
label are rejected; provide unambiguous character identifiers instead.
Missing observed/reference ratings are excluded with separate indicators
in `cases`; missing references are never filled from other rows. Both
matches and mismatches must remain. Raters with no retained pairs still
appear in `table` with unavailable estimates.

JML estimates a fixed accuracy location per rater and has the usual
incidental-parameter and sparse-design limitations.
All-match/all-mismatch raters retain primary `Inf`/`-Inf` estimates, not
the finite optimizer proxies. MML instead estimates a normal population
of rater accuracies and returns rater EAPs with `PosteriorSD`. Its
effective population sample size is the number of raters, not the number
of benchmark ratings. Posterior SD conditions on fitted
calibration/population parameters; it is not a frequentist SE or a
confidence interval. Small rater pools and population misspecification
need particular review. No JML SE, interval, significance test or
automatic accuracy cutoff is computed here. MML explicitly uses
`population_formula = ~ 1` to estimate the rater population mean and
variance; it does not use the RSM default fixed N(0,1).

Exact agreement proportions describe the retained benchmark mix.
Accuracy logits adjust for the specified difficulty structure under the
response model, local independence and a connected identifiable design.
They are neither ordinary rater severity nor examinee proficiency.
Binary coding discards the direction and magnitude of disagreements. The
native fit's readiness and estimate-use labels remain visible; finite
numbers do not establish reportability, model fit or transport to other
benchmarks. High separation reliability for these accuracy locations
would describe differences in accuracy, not agreement or differences in
severity.

## References

Engelhard, G., Jr., Wang, J., & Wind, S. A. (2018). A tale of two
models: Psychometric and cognitive perspectives on rater-mediated
assessments using accuracy ratings. *Psychological Test and Assessment
Modeling, 60*(1), 33-52. Equations and binary coding: pp. 42-43.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`score_comparison_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_comparison_table.md),
[`rater_centrality_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_centrality_table.md)

## Examples

``` r
# A small illustrative benchmark exercise, not a validation sample.
d <- expand.grid(Judge = paste0("J", 1:4), Benchmark = paste0("B", 1:6))
d$Reference <- rep(c(1, 2, 3, 1, 2, 3), each = 4)
matched <- c(1,1,0,0, 1,0,1,0, 0,1,0,1,
             1,1,0,0, 0,1,1,0, 0,0,1,1)
d$Rating <- ifelse(matched == 1, d$Reference, (d$Reference %% 3) + 1)
accuracy <- fit_rater_accuracy(d, "Judge", "Benchmark", "Rating", "Reference")
accuracy$table
#>   Rater InputRows RatingRows ExcludedRows Matches ExactAgreement      Accuracy
#> 1    J1         6          6            0       3      0.5000000  1.573963e-16
#> 2    J2         6          6            0       4      0.6666667  6.931472e-01
#> 3    J3         6          6            0       3      0.5000000  1.281556e-16
#> 4    J4         6          6            0       2      0.3333333 -6.931472e-01
#>   PosteriorSD Extreme SourceFitReadiness SourceInferenceReady      EstimateUse
#> 1          NA    none              ready                 TRUE source_fit_ready
#> 2          NA    none              ready                 TRUE source_fit_ready
#> 3          NA    none              ready                 TRUE source_fit_ready
#> 4          NA    none              ready                 TRUE source_fit_ready
accuracy$difficulty
#>       Facet Level    Difficulty
#> 1 Benchmark    B1 -7.089018e-15
#> 2 Benchmark    B2 -7.187996e-15
#> 3 Benchmark    B3 -6.820947e-15
#> 4 Benchmark    B4 -7.089018e-15
#> 5 Benchmark    B5 -7.089018e-15
#> 6 Benchmark    B6  3.527600e-14
# Review SourceFitReadiness and EstimateUse, especially for small samples.
```
