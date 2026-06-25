# Analyze practical equivalence within a facet

Analyze practical equivalence within a facet

## Usage

``` r
analyze_facet_equivalence(
  fit,
  diagnostics = NULL,
  facet = NULL,
  equivalence_bound = 0.5,
  ci_level = 0.95,
  conf_level = NULL
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  When `NULL`, diagnostics are computed with `residual_pca = "none"`.

- facet:

  Character scalar naming the non-person facet to evaluate. If `NULL`,
  the function prefers a rater-like facet and otherwise uses the first
  model facet.

- equivalence_bound:

  Practical-equivalence bound in logits. Default `0.5` is a moderate
  bound intended as a starting point, not a universal threshold. The
  TOST/ROPE result depends on both the bound *and* the per-level
  standard errors, so in small or high-variance designs the test may
  fail to reject non-equivalence simply because the SEs are wide. Choose
  `equivalence_bound` based on the smallest difference that would be
  practically meaningful in your assessment context (commonly 0.3 to 0.5
  logits for rater-mediated designs) and check `$summary` for per-level
  SE magnitude before drawing conclusions.

- ci_level:

  Confidence level used for the forest-style interval view. Default
  `0.95`.

- conf_level:

  Deprecated alias for `ci_level`, retained for backward compatibility.
  Supplying a non-`NULL` value overrides `ci_level` and emits a one-time
  deprecation warning. Will be removed in a future release. Default
  `0.95`.

## Value

A named list with class `mfrm_facet_equivalence`.

## Details

This function tests whether facet elements (e.g., raters) are similar
enough to be treated as practically interchangeable, rather than merely
testing whether they differ significantly. This is the key distinction
from a standard chi-square heterogeneity test: absence of evidence for
difference is not evidence of equivalence.

The function uses existing facet estimates and their standard errors
from `diagnostics$measures`; no re-estimation is performed.

The bundle combines four complementary views:

1.  **Fixed chi-square test**: tests \\H_0\\: all element measures are
    equal. A non-significant result is *necessary but not sufficient*
    for interchangeability. It is reported as context, not as direct
    evidence of equivalence.

2.  **Pairwise TOST (Two One-Sided Tests)**: for each pair of elements,
    tests whether the difference falls within
    \\\pm\\`equivalence_bound`. The TOST procedure (Schuirmann, 1987)
    rejects the null hypothesis of *non-equivalence* when both one-sided
    tests are significant at level \\\alpha\\. A pair is declared
    "Equivalent" when the TOST p-value \< 0.05.

3.  **BIC-based Bayes-factor heuristic**: an approximate screening tool
    (not full Bayesian inference) that compares the evidence for a
    common-facet model (all elements equal) against a heterogeneity
    model (elements differ) via \\\mathrm{BF}\_{01} \approx
    \exp((\mathrm{BIC}\_{H_1} - \mathrm{BIC}\_{H_0}) / 2)\\ (Kass &
    Raftery, 1995). Values \> 3 favour the common-facet model; \< 1/3
    favour heterogeneity.

4.  **ROPE-style grand-mean proximity**: the proportion of each
    element's normal-approximation confidence distribution that falls
    within \\\pm\\`equivalence_bound` of the weighted grand mean. This
    is a descriptive proximity summary, not a Bayesian ROPE decision
    rule around a prespecified null value.

**Choosing `equivalence_bound`**: the default of 0.5 logits is a
moderate criterion. For high-stakes certification, 0.3 logits may be
appropriate; for exploratory or low-stakes contexts, 1.0 logits may
suffice. The bound should reflect the smallest difference that would be
practically meaningful in your application.

## What this analysis means

`analyze_facet_equivalence()` is a practical-interchangeability screen.
It asks whether facet levels are close enough, under a user-defined
logit bound, to be treated as practically similar for the current use
case.

## What this analysis does not justify

- A non-significant chi-square result is not evidence of equivalence.

- Forest/ROPE displays are descriptive and do not replace the pairwise
  TOST decision rule.

- The BIC-based Bayes-factor summary is a heuristic screen, not a full
  Bayesian equivalence analysis.

## Interpreting output

Start with `summary$Decision`, which is a conservative summary of the
pairwise TOST results. Then use the remaining tables as context:

- `chi_square`: is there broad heterogeneity in the facet?

- `pairwise`: which specific pairs meet the practical-equivalence bound?

- `rope` / `forest`: how close is each level to the facet grand mean?

Smaller `equivalence_bound` values make the criterion stricter. If the
decision is `"partial_pairwise_equivalence"`, that means some pairwise
contrasts satisfy the practical-equivalence bound but not all of them
do.

## Decision rule

The final `Decision` is a pairwise TOST summary rather than a global
equivalence proof. If all pairwise contrasts satisfy the practical-
equivalence bound, the facet is labeled `"all_pairs_equivalent"`. If at
least one, but not all, pairwise contrasts are equivalent, the facet is
labeled `"partial_pairwise_equivalence"`. If no pairwise contrasts meet
the practical-equivalence bound, the facet is labeled
`"no_pairwise_equivalence_established"`. The chi-square, Bayes-factor,
and grand-mean proximity summaries are reported as descriptive context.

## How to read the main outputs

- `summary`: one-row pairwise-TOST decision summary and aggregate
  context.

- `pairwise`: pair-level TOST detail; use this for the primary
  inferential read.

- `chi_square`: broad heterogeneity screen.

- `rope` / `forest`: level-wise proximity to the weighted grand mean.

## Recommended next step

If the result is borderline or high-stakes, re-run the analysis with a
tighter or looser `equivalence_bound`, then inspect `pairwise` and
[`plot_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facet_equivalence.md)
before deciding how strongly to claim interchangeability.

## Typical workflow

1.  Fit a model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Run `analyze_facet_equivalence()` for the facet you want to screen.

3.  Read `summary` and `chi_square` first.

4.  Use
    [`plot_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facet_equivalence.md)
    to inspect which levels drive the result.

## Output

The returned bundle has class `mfrm_facet_equivalence` and includes:

- `summary`: one-row overview with convergent decision

- `chi_square`: fixed chi-square / separation summary

- `pairwise`: pairwise TOST detail table

- `rope`: element-wise ROPE probabilities around the weighted grand mean

- `forest`: element-wise estimate, confidence interval, and ROPE status

- `settings`: applied facet and threshold settings

## References

Kass, R. E., & Raftery, A. E. (1995). Bayes factors. *Journal of the
American Statistical Association, 90*(430), 773-795.

Schuirmann, D. J. (1987). A comparison of the two one-sided tests
procedure and the power approach for assessing the equivalence of
average bioavailability. *Journal of Pharmacokinetics and
Biopharmaceutics, 15*(6), 657-680.

## See also

[`facets_chisq_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_chisq_table.md),
[`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md),
[`plot_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facet_equivalence.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
eq <- analyze_facet_equivalence(fit, facet = "Rater")
eq$summary[, c("Facet", "Elements", "Decision", "MeanROPE")]
head(eq$pairwise[, c("ElementA", "ElementB", "Equivalent")])
}
```
