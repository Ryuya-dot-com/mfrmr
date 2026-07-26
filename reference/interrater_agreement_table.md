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

  Optional maximum number of pair rows to keep.

## Value

A named list with:

- `summary`: one-row inter-rater summary

- `pairs`: pair-level agreement table

- `settings`: applied options and thresholds

## Details

This helper computes pairwise rater agreement on matched contexts and
returns both a pair-level table and a one-row summary. The output is
package-native and does not require knowledge of legacy report
numbering. When fitted category probabilities are available, expected
exact agreement for a matched context is the model-implied quantity
\\\sum_k P\_{r1}(X=k)P\_{r2}(X=k)\\. It is not a marginal-frequency
chance agreement statistic. Observed exact agreement uses equality of
the package's observed score categories. The current function does not
translate category positions across multiple independent scales, apply
an agreement-based SE inflation, or establish numerical equivalence with
FACETS Table 7.

## Interpreting output

- `summary`: overall agreement level, number/share of flagged pairs.

- `pairs`: pairwise exact agreement, correlation, and direction/size
  gaps.

- `settings`: applied facet matching and warning thresholds.

Pairs flagged by both low exact agreement and low correlation generally
deserve highest calibration priority.

## Typical workflow

1.  Run with explicit `rater_facet` (and `context_facets` if needed).

2.  Review `summary(ir)` and top flagged rows in `ir$pairs`.

3.  Visualize with
    [`plot_interrater_agreement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_interrater_agreement.md).

## Output columns

The `pairs` data.frame contains:

- Rater1, Rater2:

  Rater pair identifiers.

- N:

  Number of matched-context observations for this pair.

- Exact:

  Proportion of exact score agreements.

- ExpectedExact:

  Model-implied expected exact agreement from the two raters' fitted
  category-probability vectors. `NA` when those probabilities are
  unavailable.

- Adjacent:

  Proportion of adjacent (+/- 1 category) agreements.

- MeanDiff:

  Signed mean score difference (Rater1 - Rater2).

- MAD:

  Mean absolute score difference.

- Corr:

  Pearson correlation between paired scores.

- Flag:

  Logical; `TRUE` when Exact \< `exact_warn` or Corr \< `corr_warn`.

- OpportunityCount, ExactCount, ExpectedExactCount, AdjacentCount:

  Raw counts behind the agreement proportions.

The `summary` data.frame contains:

- RaterFacet:

  Name of the rater facet analyzed.

- TotalPairs:

  Number of rater pairs evaluated.

- ExactAgreement:

  Mean exact agreement across all pairs.

- AgreementMinusExpected:

  Observed exact agreement minus expected exact agreement.

- MeanCorr:

  Mean pairwise correlation.

- FlaggedPairs, FlaggedShare:

  Count and proportion of flagged pairs.

- RaterSeparation, RaterReliability:

  Severity-spread indices for the rater facet, reported separately from
  agreement.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`facets_chisq_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_chisq_table.md),
[`plot_interrater_agreement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_interrater_agreement.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
ir <- interrater_agreement_table(fit, rater_facet = "Rater")
# One-row overview: ExactAgreement, ExpectedExactAgreement, MeanCorr,
# RaterSeparation, and RaterReliability are the headline reportable
# statistics.
ir$summary
#>   RaterFacet Raters Pairs Contexts TotalPairs OpportunityCount ExactAgreements
#> 1      Rater      4     6      192       1152             1152             417
#>   ExpectedAgreements ExactAgreement ExpectedExactAgreement
#> 1           431.5792      0.3619792              0.3746347
#>   AgreementMinusExpected AdjacentAgreements AdjacentAgreement MeanAbsDiff
#> 1            -0.01265554                956         0.8298611   0.8255208
#>    MeanCorr RaterSeparation RaterStrata RaterReliability RaterRealSeparation
#> 1 0.3781067        3.052963    4.403951        0.9031062             3.01671
#>   RaterRealReliability FlaggedPairs FlaggedShare
#> 1            0.9009954            6            1
# Per-pair detail (Rater1 vs Rater2 with Exact, Adjacent, Corr, MAD).
head(ir$pairs)
#>   Rater1 Rater2   N OpportunityCount ExactCount ExpectedExactCount
#> 1    R01    R03 192              192         66           72.15929
#> 2    R01    R04 192              192         67           70.96800
#> 3    R02    R04 192              192         69           69.44126
#> 4    R02    R03 192              192         71           71.03851
#> 5    R01    R02 192              192         71           73.95176
#> 6    R03    R04 192              192         73           74.02036
#>   AdjacentCount     Exact ExpectedExact  Adjacent    MeanDiff       MAD
#> 1           158 0.3437500     0.3758297 0.8229167  0.21354167 0.8489583
#> 2           152 0.3489583     0.3696250 0.7916667  0.29166667 0.8854167
#> 3           153 0.3593750     0.3616732 0.7968750  0.36458333 0.8645833
#> 4           158 0.3697917     0.3699922 0.8229167  0.28645833 0.8177083
#> 5           172 0.3697917     0.3851654 0.8958333 -0.07291667 0.7500000
#> 6           163 0.3802083     0.3855227 0.8489583  0.07812500 0.7864583
#>        Corr      Pair      ExactGap LowExactFlag LowCorrFlag Flag
#> 1 0.3696655 R01 | R03 -0.0320796527         TRUE       FALSE TRUE
#> 2 0.3313368 R01 | R04 -0.0206666586         TRUE       FALSE TRUE
#> 3 0.3377719 R02 | R04 -0.0022982178         TRUE       FALSE TRUE
#> 4 0.3723625 R02 | R03 -0.0002005704         TRUE       FALSE TRUE
#> 5 0.4366188 R01 | R02 -0.0153737478         TRUE       FALSE TRUE
#> 6 0.4208851 R03 | R04 -0.0053143712         TRUE       FALSE TRUE
p_ir <- plot(ir, draw = FALSE)
p_ir$data$plot
#> [1] "exact"
# }
```
