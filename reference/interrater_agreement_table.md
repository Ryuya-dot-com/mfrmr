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
numbering.

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

  Expected exact agreement under chance.

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
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
ir <- interrater_agreement_table(fit, rater_facet = "Rater")
# One-row overview: ExactAgreement, ExpectedExactAgreement, MeanCorr,
# RaterSeparation, and RaterReliability are the headline reportable
# statistics.
ir$summary
# Per-pair detail (Rater1 vs Rater2 with Exact, Adjacent, Corr, MAD).
head(ir$pairs)
p_ir <- plot(ir, draw = FALSE)
p_ir$data$plot
}
```
