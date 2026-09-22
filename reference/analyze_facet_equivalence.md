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
  Requires an inference-ready MML fit with unregularized
  observed-information covariance and estimable contrasts.

- diagnostics:

  Optional matching output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  Supplied diagnostics must retain all target-facet levels, model-based
  SEs and ordinary-inference eligibility. Estimates and covariance are
  always taken from `fit`; supplying diagnostics cannot override its
  restrictions.

- facet:

  Character scalar naming a non-person facet. When `NULL`, a rater-like
  facet is preferred, otherwise the first model facet is used.

- equivalence_bound:

  Positive practical-equivalence bound in logits. The default `0.5` is
  not a universal threshold. Choose the smallest practically meaningful
  difference for the intended use before inspecting the equivalence
  results.

- ci_level:

  Confidence level for level and grand-mean-deviation intervals (default
  `0.95`). Pairwise TOST always uses alpha 0.05 and 90% intervals.

- conf_level:

  Deprecated alias for `ci_level`; when supplied it takes precedence and
  emits a lifecycle deprecation warning.

## Value

A named list with class `mfrm_facet_equivalence`.

## Details

Pair differences use the full constrained covariance from the MML
observed information: \\\mathrm{Var}(A-B) = \mathrm{Var}(A) +
\mathrm{Var}(B) - 2\mathrm{Cov}(A,B)\\. No model is refitted. JML,
inference-ineligible fits, missing or regularized covariance, and
singular contrast covariance stop with an error. Levels with fixed or
unavailable contrasts are not silently dropped. Known anchors are
treated as fixed; their uncertainty is excluded. Non-unit observation
weights are inference-ineligible, including weights normalized to mean
one. Older bundles must retain the current readiness contract as well as
the covariance basis before they can be displayed.

The heterogeneity table uses a joint Wald chi-square test of equality of
the facet levels. Non-significant heterogeneity is neither necessary nor
sufficient for practical equivalence. `FixedChiSq`, `FixedDF`, and
`FixedProb` retain their column names but use this joint contrast test.
Separation and reliability remain descriptive summaries.

`GrandMean` is the equally weighted mean of the facet estimates. For
each deviation from that mean, uncertainty includes the covariance with
the estimated mean. `ROPEPct` is the mass of its normal confidence
distribution inside the practical bound; it is descriptive, not a
Bayesian posterior probability or a separate equivalence decision.

The former BIC/Bayes-factor heuristic is unavailable: a Wald statistic
is not a fitted likelihood comparison. For compatibility, `BF01` is `NA`
and `BF01Label` states why no value is supplied.

## What this analysis means

The analysis asks whether differences between facet levels fall within a
prespecified practical bound under the fitted model. These are
asymptotic normal-approximation tests; numerical eligibility does not
establish finite-sample coverage or adequacy of the rating design.

## What this analysis does not justify

A non-significant difference is not evidence of equivalence. Pairwise
conclusions are unadjusted for multiplicity: selecting some positive
pairs does not provide family-wise error control for that selected set.
Estimated linking or anchor uncertainty, population transport, and model
misspecification require separate evaluation.

## Decision rule

Each pair uses two one-sided normal tests at alpha 0.05. `Equivalent` is
true when both tests reject non-equivalence, equivalently when its 90%
interval lies strictly inside the bound. `Decision` summarizes all pairs
as `"all_pairs_equivalent"`, `"partial_pairwise_equivalence"`, or
`"no_pairwise_equivalence_established"`. No pair may be omitted from the
all-pairs summary. Heterogeneity and ROPE summaries do not change this
rule.

## Interpreting output

Start with `summary$Decision` and examine the corresponding `pairwise`
differences, SEs and intervals. A negative result can reflect
imprecision or a material difference. `chi_square` addresses exact
equality, while `rope` and `forest` describe proximity to the facet
mean.

## How to read the main outputs

- `summary`: pairwise decision, covariance basis and multiplicity
  convention.

- `pairwise`: differences, covariance-aware SEs, 90% intervals and TOST
  tests.

- `chi_square`: joint Wald heterogeneity test and descriptive
  separation.

- `rope` / `forest`: `Measure`, marginal `SE` and `CI_Lower`/`CI_Upper`,
  plus `Deviation`, `DeviationSE` and
  `DeviationCI_Lower`/`DeviationCI_Upper` for proximity to the equally
  weighted facet mean.

## Recommended next step

Review numerical integration and the model's uncertainty assumptions
before interpreting a borderline result. Sensitivity to another
practical bound should be reported transparently, without selecting a
bound to obtain a desired decision.

## Typical workflow

1.  Fit and review an MML model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Prespecify the practical bound and run
    `analyze_facet_equivalence()`.

3.  Read `summary` and `pairwise`.

4.  Use
    [`plot_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facet_equivalence.md)
    for descriptive grand-mean proximity.

## Output

A bundle with `summary`, `chi_square`, `pairwise`, `rope`, `forest`, and
`settings`. Older bundles without the current inference/covariance basis
must be recomputed before using
[`summary()`](https://rdrr.io/r/base/summary.html),
[`print()`](https://rdrr.io/r/base/print.html), or plotting.

## References

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
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML", quad_points = 31, maxit = 150)
eq <- analyze_facet_equivalence(fit, facet = "Rater")
eq$summary[, c("Facet", "Elements", "Decision", "MeanROPE")]
#>   Facet Elements                     Decision MeanROPE
#> 1 Rater        4 partial_pairwise_equivalence 99.42802
head(eq$pairwise[, c("ElementA", "ElementB", "Equivalent")])
#>   ElementA ElementB Equivalent
#> 1      R01      R02       TRUE
#> 2      R01      R03      FALSE
#> 3      R01      R04      FALSE
#> 4      R02      R03      FALSE
#> 5      R02      R04      FALSE
#> 6      R03      R04       TRUE
# }
```
