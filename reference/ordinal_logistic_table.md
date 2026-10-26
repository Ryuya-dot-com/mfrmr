# Compare ordered responses using cumulative logistic models

Compare two groups at an explicitly supplied numeric matching variable,
using three nested proportional-odds models. This independent-Person
sensitivity analysis does not estimate ability or fit an MFRM.

## Usage

``` r
ordinal_logistic_table(
  data,
  person,
  target,
  score,
  group,
  matching,
  groups,
  categories,
  p_adjust = "holm"
)
```

## Arguments

- data:

  Long-format data with at most one row per Person and target.

- person:

  Name of the independent Person identifier column.

- target:

  Name of the item or other target identifier column.

- score:

  Name of the ordered response column. Numeric, character or factor
  scores are accepted, with order declared through `categories`.

- group:

  Name of the group column. Each Person belongs to one group.

- matching:

  Name of one finite numeric matching column. Values may differ across
  targets. Missing scores or matching values are excluded together from
  all models for the affected target.

- groups:

  Two distinct labels in reference, focal order.

- categories:

  Distinct numeric or character category labels, in increasing response
  order. Factor labels are treated as character. Category spacing has no
  effect. Every declared category must occur in each target's complete
  data; otherwise that target is unavailable. Categories are never
  collapsed.

- p_adjust:

  A [`stats::p.adjust()`](https://rdrr.io/r/stats/p.adjust.html) method,
  default `"holm"`. The DIF comparison family comprises all three tests
  for every observed target, including unavailable tests.
  Proportional-odds diagnostics form a separate family of one test per
  target.

## Value

A plain list containing `table` (three comparisons per target), `models`
(three PO fits and, for ordinal responses, a diagnostic fit),
`coefficients` (available models only), `contrasts`,
`proportional_odds`, `matching`, `cases`, `settings` and `notes`.
`cases$Included` denotes complete rows supplied to eligible models, not
successful estimation or valid DIF inference. Precluded targets retain
their counts and reasons. Save the full result with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) and individual
tables with
[`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html). No
backend model objects or executable environments are retained.

## Details

Requires the optional package ordinal. Maximum likelihood is computed by
[`ordinal::clm()`](https://rdrr.io/pkg/ordinal/man/clm.html) with a
logit link and flexible thresholds. For each target, matching is
centered at its pooled midrange and divided by its half-range:
`z = (matching - Center) / Scale`. Group is coded 0 for reference and 1
for focal. `M1` uses `z`, `M2` uses `z + g`, and `M3` uses `z * g`. All
three use identical complete responses. The model is
`logit Pr(Y <= k) = threshold[k] - linear_predictor`.

`Uniform` compares M2 to M1 (1 df), `Nonuniform` compares M3 to M2 (1
df), and `Joint` compares M3 to M1 (2 df). These are asymptotic
likelihood-ratio tests. A uniform comparison assumes no interaction; its
coefficient must not be interpreted as a constant group difference when
an interaction matters. No automatic selection between these models or
DIF/bias flag is made. `NagelkerkeR2` is
`(1-exp(2*(LL0-LL)/N))/(1-exp(2*LL0/N))`, where LL0 is the
intercept-only multinomial log likelihood. `DeltaNagelkerkeR2` subtracts
the reduced model's value from the full model's value. This is not
explained score variance or McKelvey–Zavoina R-squared; no universal
effect-size cutoff is applied.

`contrasts` gives M3's reference/focal upper-tail odds ratio at the
lower endpoint, midpoint and upper endpoint of the groups' overlapping
matching ranges. Its log is `-(beta_g + beta_z:g * z)`; a value above 1
favors higher reference scores. This applies to each category cut under
proportional odds. These are point estimates, not simultaneous
intervals. Fits use all complete responses, including those outside that
overlap. Range overlap alone does not establish comparable distributions
or adequate local support. Each group must have varying matching values
and their ranges must overlap with positive width. The `matching` table
retains the ranges and transformation.

For three or more categories, `proportional_odds` compares M3 with a
model in which all three slopes may differ across cumulative category
cuts (`clm(y ~ 1, nominal = ~ z * g)`). This global asymptotic LR
diagnostic has `3 * (K - 2)` df. It concerns equality across category
cuts, whereas the nonuniform comparison concerns differences across
matching values. They are different questions. The diagnostic is not
applicable to binary responses. An unavailable or nonsignificant
diagnostic does not certify proportional odds. Its p-value does not
determine availability or change the primary comparisons.

`models` retains convergence codes, warnings, gradient, Hessian and
Newton step diagnostics. A fit is unavailable if the backend reports
nonconvergence or nonunique parameters, any coefficient is
aliased/nonfinite, the Hessian's minimum eigenvalue is at most
`sqrt(.Machine$double.eps) * max(1, max_eigen)`, the maximum absolute
gradient exceeds `1e-6`, or the maximum absolute Newton step exceeds
`1e-4` on the scaled parameterization. Backend warnings also make the
fit unavailable. These conservative numerical checks detect common
separation failures; they are not a general proof of finite ML
existence. Likelihood decreases beyond
`64 * .Machine$double.eps * max(1, abs(LL))` invalidate a comparison;
smaller rounding errors are set to zero. No penalized estimator,
collapsed categories or alternative inference is substituted.

Inference requires independent Persons within each target, a suitable
linear matching relationship, finite identifiable parameters and
adequate data for chi-squared approximations. Sparse categories and
small samples can invalidate those approximations even when numerical
checks pass. Duplicate Person-target rows, including missing-score
duplicates, are rejected before exclusions. Renaming repeated ratings as
Persons does not establish independence. Dependence across targets is
compatible with Holm adjustment of valid individual p-values, but no
dependence within targets is handled here.

Interpreting conditional group association as DIF additionally requires
defensible matching, invariant anchors and comparable rater/task
exposure. Use a justified common rating plan; this interface does not
adjust for plan differences, matching error, clustered ratings or
informative missingness. Total and rest scores need not define the same
comparison. RSM/PCM's adjacent category logits do not generally imply
cumulative proportional odds. Therefore agreement with
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
or
[`mantel_haenszel_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/mantel_haenszel_table.md)
does not by itself establish robustness, and disagreement does not by
itself establish DIF.

## References

Rogers, H. J., & Swaminathan, H. (1993). A comparison of logistic
regression and Mantel-Haenszel procedures for detecting differential
item functioning. *Applied Psychological Measurement, 17*, 105–116.
[doi:10.1177/014662169301700201](https://doi.org/10.1177/014662169301700201)
.

Zumbo, B. D. (1999). *A handbook on the theory and methods of
differential item functioning (DIF): Logistic regression modeling as a
unitary framework for binary and Likert-type (ordinal) item scores*.
Department of National Defense, Ottawa, pp. 23–32. Pseudo-R-squared
definitions and thresholds in that handbook are not interchangeable.

## See also

[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`mantel_haenszel_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/mantel_haenszel_table.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md)

## Examples

``` r
if (requireNamespace("ordinal", quietly = TRUE)) {
  d <- expand.grid(Match = c(-1, 0, 1), Group = c("R", "F"),
                   Score = 0:2, Replicate = 1:5)
  d$Person <- paste0("P", seq_len(nrow(d)))
  d$Item <- "A"
  ol <- ordinal_logistic_table(d, "Person", "Item", "Score", "Group",
                               "Match", c("R", "F"), 0:2)
  ol$table
  ol$proportional_odds
}
#>   Target ChiSquared DF PValue    Status PAdjusted
#> 1      A          0  3      1 available         1
```
