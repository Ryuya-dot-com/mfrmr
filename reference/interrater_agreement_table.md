# Build an inter-rater agreement report

Build an inter-rater agreement report

## Usage

``` r
interrater_agreement_table(
  fit,
  diagnostics = NULL,
  rater_facet = NULL,
  context_facets = NULL,
  exact_warn = 0.5,
  corr_warn = 0.3,
  include_precision = TRUE,
  top_n = NULL
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- rater_facet:

  Name of the rater facet. If `NULL`, inferred from facet names.

- context_facets:

  Optional context facets used to match observations for agreement. If
  `NULL`, all remaining facets (including `Person`) are used.

- exact_warn:

  Warning threshold for exact agreement.

- corr_warn:

  Warning threshold for pairwise correlation.

- include_precision:

  If `TRUE`, append rater severity spread indices from the facet
  precision summary when available.

- top_n:

  Optional maximum number of pair rows to keep, after ordering by flag,
  exact agreement and correlation. The summary still describes all
  candidate pairs. Leave `NULL` to retain the complete pair audit.

## Value

An `mfrm_interrater` bundle (a named list) with:

- `summary`: one-row inter-rater summary

- `pairs`: pair-level agreement table

- `notes`: interpretation and availability qualifications

- `settings`: applied options and thresholds

Use `summary(ir)` or `ir$summary` to inspect a result and `plot(ir)` for
its saved agreement figure. Save the full bundle with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) and reopen with
[`base::readRDS()`](https://rdrr.io/r/base/readRDS.html); export
`ir$pairs` and `ir$summary` separately with
[`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html).
Reopening performs no fitting.
`plot(ir, type = "agreement", metric = "correlation")` selects the
correlation view; `metric = "difference"` selects observed-score gaps.
These plots retain the saved flag thresholds. Changing them requires
recreating this result from the existing fit, not fitting a new model.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
converts a saved plot payload without recomputation.

## Details

This helper computes pairwise rater agreement on matched contexts and
returns both a pair-level table and a one-row summary. The output is
package-native and does not require knowledge of legacy report
numbering. When fitted category probabilities are available, expected
exact agreement for a matched context is the model-implied quantity
\\\sum_k P\_{r1}(X=k)P\_{r2}(X=k)\\. It is not a marginal-frequency
chance agreement statistic. This product assumes conditional
independence at the saved Person point score and fitted structural
parameters. MML uses the saved EAP: it does not integrate either the
product or its factors over the Person posterior. Calibration and
population uncertainty are not propagated. Nonfinite primary
Person/facet/step estimates or unavailable GPCM slopes withhold the
affected expectations; finite internal optimizer proxies are not
substituted and limiting boundary probabilities are not calculated here.
`ExpectedReason` records unavailable primary estimates, repeated
ratings, unavailable probabilities or absent matched scores. Observed
exact agreement uses equality of the package's observed score
categories. Repeated ratings in a rater/context cell are averaged using
observation weights; comparisons then describe those means, and expected
exact agreement is withheld for the repeated cells. The current function
does not translate category positions across multiple independent
scales, apply an agreement-based SE inflation, or establish numerical
equivalence with FACETS Table 7. For two-way observed-score ICCs without
an MFRM fit, use
[`pairwise_icc_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/pairwise_icc_table.md).
That function requires one rating per rater/unit and an explicit choice
of agreement/consistency and single/average ratings. The raw-score
kappa, alpha and AC2 helpers also reject repeated rater-unit cells; they
do not inherit this function's averaging convention. See
[mfrmr_methods_reference](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_methods_reference.md)
for choosing among these targets.

Within a pair, every matched context with two finite scores contributes
one opportunity, after any within-cell averaging. Observation weights
affect that averaging, not the weight assigned to the resulting context.
Overall exact/adjacent agreement divides the corresponding counts by the
total opportunities across pairs. A context with finite compared scores
from m judges contributes m(m-1)/2 opportunities, so this is not equal
weighting of distinct contexts or independent evidence from that many
people. Pairwise correlation is computed from the matched scores, and
`MeanCorr` weights each available correlation by its pair's
matched-context count. It is not a panel ICC.

## Interpreting output

- `summary`: overall agreement level, number/share of flagged pairs.

- `pairs`: pairwise exact agreement, correlation, and direction/size
  gaps.

- `settings`: applied facet matching and warning thresholds.

Flags indicate configured review thresholds, not rater quality, fairness
or an automatic training priority. A missing rule remains unavailable; a
known cutoff crossing still flags the pair. Overall flag rates require
complete classification. Expected agreement is withheld if any matched
context lacks valid category probabilities; availability counts are
retained. Recreate older agreement/network results from the existing fit
and matching diagnostics with the original settings, then regenerate
plots and exports.

## Typical workflow

1.  Run with explicit `rater_facet` (and `context_facets` if needed).

2.  Review `summary(ir)` and top flagged rows in `ir$pairs`.

3.  Visualize with [plot(x, type =
    "agreement")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md).

## Output columns

The `pairs` data.frame contains:

- Rater1, Rater2:

  Rater pair identifiers.

- N, OpportunityCount:

  Number of matched contexts with two finite scores for this pair, after
  any repeated-cell averaging.

- Exact:

  Proportion of exact score agreements.

- ExpectedExact:

  Model-implied expected exact agreement from the two raters' fitted
  category-probability vectors. `NA` when those probabilities are
  unavailable.

- Adjacent:

  Proportion whose absolute compared-score difference is at most 1,
  including exact agreements.

- MeanDiff:

  Signed mean score difference (Rater1 - Rater2).

- MAD:

  Mean absolute score difference.

- Corr:

  Pearson correlation between paired scores.

- Flag:

  Logical; `TRUE` when Exact \< `exact_warn` or Corr \< `corr_warn`.

- ExactCount, AdjacentCount:

  Observed counts behind the proportions.

- ExpectedExactCount:

  Sum of model-implied exact-agreement probabilities over matched
  contexts; it may be fractional. Unavailable if any such context lacks
  valid probabilities.

- ExpectedAvailableContexts, ExpectedUnavailableContexts:

  Counts of matched contexts with and without valid fitted
  probabilities.

- ExpectedReason:

  `available`, or semicolon-separated reasons:
  `primary_estimate_unavailable`, `repeated_ratings`,
  `fitted_probabilities_unavailable`, or `no_matched_scores`.

The `summary` data.frame contains:

- RaterFacet:

  Name of the rater facet analyzed.

- Pairs, AvailablePairs, UnavailablePairs:

  All candidate rater pairs, those with matched scores, and those
  without.

- TotalPairs, OpportunityCount:

  Total matched-context opportunities across rater pairs, not the number
  of distinct people or contexts.

- Contexts:

  Distinct contexts with at least two finite compared scores.

- ExactAgreement:

  Exact agreements divided by all matched-context opportunities.

- AgreementMinusExpected:

  Observed exact agreement minus expected exact agreement.

- MeanCorr:

  Mean available pairwise correlation weighted by each pair's
  matched-context count; unavailable correlations are excluded.

- FlaggedPairs, FlaggedShare:

  Known flagged pairs and their share of all pairs; the share is
  unavailable if classification is incomplete.

- ClassifiedPairs, UnclassifiedPairs:

  Available and unavailable combined flag decisions. Correlation
  availability is recorded separately.

- RaterSeparation, RaterReliability:

  Severity-spread indices for the rater facet, reported separately from
  agreement.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`facets_chisq_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_chisq_table.md),
[plot(x, type =
"agreement")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[`pairwise_icc_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/pairwise_icc_table.md),
[`pairwise_kappa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/pairwise_kappa_table.md),
[`gwet_ac2_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/gwet_ac2_table.md),
[`krippendorff_alpha_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/krippendorff_alpha_table.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
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

# Compare ratings of the same person on the same criterion
agreement <- interrater_agreement_table(fit, rater_facet = "Rater")
agreement$summary
#>   RaterFacet Raters Pairs AvailablePairs UnavailablePairs CorrelationPairs
#> 1      Rater      6    15              6                9                6
#>   UnavailableCorrelationPairs RepeatedCells ExpectedAvailableContexts
#> 1                           9             0                       138
#>   ExpectedUnavailableContexts ExpectedReason Contexts TotalPairs
#> 1                           0      available      138        138
#>   OpportunityCount ExactAgreements ExpectedAgreements ExactAgreement
#> 1              138              54           48.40589      0.3913043
#>   ExpectedExactAgreement AgreementMinusExpected AdjacentAgreements
#> 1              0.3507673             0.04053701                118
#>   AdjacentAgreement MeanAbsDiff  MeanCorr RaterSeparation RaterStrata
#> 1         0.8550725   0.7826087 0.4008957        1.448979    2.265305
#>   RaterReliability RaterRealSeparation RaterRealReliability ClassifiedPairs
#> 1        0.6773715            1.447168            0.6768246               6
#>   UnclassifiedPairs FlaggedPairs FlaggedShare
#> 1                 9            5           NA
agreement$pairs[, c("Rater1", "Rater2", "N", "Exact", "Corr", "MeanDiff")]
#>    Rater1 Rater2  N     Exact      Corr   MeanDiff
#> 1     R05    R06 20 0.3000000 0.5959734  0.2500000
#> 2     R02    R03 26 0.3076923 0.3100620  0.4615385
#> 3     R01    R06 18 0.3333333 0.3823268  0.3333333
#> 4     R02    R01 28 0.3571429 0.2761502 -0.2857143
#> 5     R03    R04 23 0.4347826 0.2891677  0.1304348
#> 6     R04    R05 23 0.6086957 0.6120686  0.0000000
#> 7     R02    R04  0        NA        NA         NA
#> 8     R02    R05  0        NA        NA         NA
#> 9     R02    R06  0        NA        NA         NA
#> 10    R01    R03  0        NA        NA         NA
#> 11    R01    R04  0        NA        NA         NA
#> 12    R01    R05  0        NA        NA         NA
#> 13    R03    R05  0        NA        NA         NA
#> 14    R03    R06  0        NA        NA         NA
#> 15    R04    R06  0        NA        NA         NA
# N is the number of matched ratings; Exact is the fraction with identical scores
# MeanDiff = Rater1 minus Rater2: positive means Rater1 assigned higher scores
# These observed-score comparisons are distinct from fitted rater severity
```
