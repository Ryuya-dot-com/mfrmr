# Compare binary responses between matched groups

Compute a Mantel–Haenszel (MH) odds ratio for each declared target, with
conditional exact or asymptotic inference. Matching strata are supplied
explicitly; this function does not estimate ability or fit an MFRM.

## Usage

``` r
mantel_haenszel_table(
  data,
  person,
  target,
  score,
  group,
  strata,
  groups,
  inference = c("exact", "asymptotic"),
  correct = TRUE,
  conf_level = 0.95,
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

  Name of a numeric column containing only 0, 1 or missing values. No
  automatic dichotomization or category recoding is performed.

- group:

  Name of the group column. Each Person must belong to one group.

- strata:

  Names of one or more columns jointly defining exact matching strata,
  for example `c("Total", "Plan")`. Numeric values are not binned.
  Strata can differ across targets. Missing strata exclude that
  response.

- groups:

  Two distinct group labels in reference, focal order. Data containing
  other groups are rejected rather than silently filtered.

- inference:

  `"exact"` (default) uses the conditional distribution given each
  stratum's margins. `"asymptotic"` uses the MH chi-squared
  approximation.

- correct:

  Logical; request the continuity correction convention of
  [`stats::mantelhaen.test()`](https://rdrr.io/r/stats/mantelhaen.test.html)
  for asymptotic inference. Ignored for exact inference; the resolved
  setting is saved. This does not correct for repeated ratings, matching
  errors or multiple testing.

- conf_level:

  Confidence level strictly between 0 and 1. Intervals are pointwise,
  not simultaneous across targets.

- p_adjust:

  A [`stats::p.adjust()`](https://rdrr.io/r/stats/p.adjust.html) method,
  default `"holm"`. The family includes every observed target, including
  targets with unavailable tests.

## Value

A plain list with `table` (one row per target), `strata` (2-by-2 counts
and stratum odds ratios), `cases` (input-row inclusion audit),
`matching` (unique complete stratum keys), `settings` and `notes`.
`Stratum` indexes rows of `matching`. `Included` means inclusion in the
conditional calculation, not proven substantive comparability.
`PAdjusted` uses the family specified above; interval endpoints are not
multiplicity-adjusted. Numerical availability does not certify a DIF
inference. Save with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) and export each
data frame with
[`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html);
reading these outputs performs no calculation.

## Details

An odds ratio above 1 means higher odds of score 1 in the reference
group. `MHOddsRatio` is always sum(A*D/N)/sum(B*C/N), with reference
successes A, reference failures B, focal successes C and focal failures
D. No .5 is added to zero cells. Zero and infinite estimates are
retained.

`OddsRatio` and its interval follow the selected inference: conditional
maximum likelihood and an exact equal-tail interval for `"exact"`, or
the MH estimate and a large-sample log-odds interval for `"asymptotic"`.
Exact two-sided p-values sum null probabilities no greater than the
observed statistic's probability, as in
[`stats::mantelhaen.test()`](https://rdrr.io/r/stats/mantelhaen.test.html).
They need not invert the equal-tail interval. Asymptotic boundary
estimates can have an unavailable interval even when the test and point
estimate are available. No method is substituted automatically.
Computation failures and warnings remain visible in `Status`/`Message`.
Exact refers to the conditional distribution; numerical inversion uses
the standard R routine's root-finding precision. Its asymptotic
continuity correction subtracts .5 only when the absolute count contrast
is at least .5. Exact p-values exceeding 1 by at most 64 machine
epsilons from rounding are returned as 1; larger violations remain
unavailable. Asymptotic count products use double precision to avoid
integer overflow in large strata. This preserves the MH formulas and
does not change the independent-Person or large-sample assumptions.

A stratum contributes information only when both groups and both score
categories occur. Other strata are retained with their counts and a
reason but contribute neither odds-ratio terms nor inference. This also
removes empty and singleton strata before calling the standard R
calculation. A single informative stratum is supported. `cases` retains
every input row, distinguishing missing responses/matching from
uninformative strata. Duplicate Person-target cells, including
missing-score duplicates, are rejected. Multiple targets may use the
same Persons; dependence across targets does not invalidate Holm
adjustment of valid individual p-values.

The inferential model requires independent Persons within each target
and a common conditional odds ratio across its strata. Small cells alone
do not invalidate the exact conditional calculation, but exact inference
does not establish these assumptions. The separate stratum odds ratios
help reveal opposing effects that a common MH effect can conceal; no
test of homogeneity, power guarantee, ETS label or automatic DIF/bias
flag is given. The number of independent Persons is not the number of
rating rows.

Interpreting conditional association as DIF additionally requires
adequate matching and comparable exposure. With a common binary Rasch
item set and invariant other items, the total including the studied item
eliminates the group ability distribution from that item's conditional
response. A rest score generally does not have this property. Totals
from different rater/task plans are not automatically comparable: supply
justified joint strata or restrict to a defensible common plan. Strata
without group overlap are visibly excluded. The function verifies data
structure, not the validity of a matching variable, invariance of other
items, absence of informative missingness, or independence beyond the
supplied Person IDs.

A rater scoring several criteria for the same Person produces repeated
Person-rater observations and cannot be pooled through this interface.
Renaming those observations as new Persons does not establish
independence. This is a separate conditional association analysis, not a
new `method` for
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md).
Residual and linked-refit contrasts have different targets; their
agreement does not certify robustness or fairness.

## References

Holland, P. W., & Thayer, D. T. (1986). *Differential item functioning
and the Mantel-Haenszel procedure*. ETS Research Report RR-86-31, pp.
7–18.
[doi:10.1002/j.2330-8516.1986.tb00186.x](https://doi.org/10.1002/j.2330-8516.1986.tb00186.x)
. See
[`stats::mantelhaen.test()`](https://rdrr.io/r/stats/mantelhaen.test.html)
for the numerical inference conventions.

## See also

[`ordinal_logistic_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/ordinal_logistic_table.md),
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md)

## Examples

``` r
# One binary target per Person; both groups share two declared strata.
d <- data.frame(Person = paste0("P", 1:16), Item = "A",
  Group = rep(c("Reference", "Focal"), each = 8),
  Matching = rep(rep(c("Low", "High"), each = 4), 2),
  Score = c(0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1))
mh <- mantel_haenszel_table(d, "Person", "Item", "Score", "Group",
                           "Matching", c("Reference", "Focal"))
mh$table
#>   Target Reference Focal NReference NFocal InputRows CompleteRows ExcludedRows
#> 1      A Reference Focal          8      8        16           16            0
#>   InformativeStrata MHOddsRatio OddsRatio     Lower    Upper ConfidenceLevel
#> 1                 2           3  2.601683 0.2547306 38.55288            0.95
#>    EstimateMethod ChiSquared DF   PValue    Status IntervalStatus Message
#> 1 conditional_mle         NA NA 0.622449 available      available        
#>   PAdjusted
#> 1  0.622449
mh$strata
#>   Target Stratum ReferenceSuccess ReferenceFailure FocalSuccess FocalFailure N
#> 1      A       1                3                1            2            2 8
#> 2      A       2                2                2            1            3 8
#>   OddsRatio Informative      Reason
#> 1         3        TRUE informative
#> 2         3        TRUE informative
```
