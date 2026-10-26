# Compute observed-score ICCs for each rater pair

Compare each pair on its common, complete units using a two-way ANOVA
ICC. No MFRM fit, mixed-model estimation or extra package is required.

## Usage

``` r
pairwise_icc_table(
  data,
  rater,
  unit,
  score,
  model = c("mixed", "random"),
  definition = c("agreement", "consistency"),
  type = c("single", "average")
)
```

## Arguments

- data:

  Long-format data with at most one row per rater and unit.

- rater:

  Name of the rater identifier column.

- unit:

  Names of columns jointly identifying a rated unit, for example
  `c("Person", "Task", "Criterion")`. These columns match observations;
  they are not separately estimated variance components.

- score:

  Name of a numeric score column. Scores must share a meaningful
  interval scale. Numeric ordinal category codes do not establish that
  assumption. Factors/characters are not silently converted to scores.

- model:

  `"mixed"` (default) describes the selected raters. `"random"` assumes
  raters were sampled from a population to which results may generalize.
  Two-way point formulas are identical; their interpretation differs.
  Choosing `"random"` does not establish random sampling.

- definition:

  `"agreement"` (default) includes systematic rater offsets;
  `"consistency"` removes their contribution.

- type:

  `"single"` (default) concerns one rating; `"average"` concerns the
  unweighted mean of the two ratings, not a mean over the full panel.

## Value

A plain list containing `table` (one row per rater pair), `anova`
(scaled ANOVA ingredients), `cases` (one row per pair and union of
assigned units, with input-row references and inclusion flags), `units`
(the unique input unit keys in input-column order), `settings` and
`notes`. `Unit` in `cases` is a row index into `units`. Units assigned
to neither member of a pair are outside that pair's audit.
`Missing1`/`Missing2` indicate explicit missing-score rows;
`Assigned1`/`Assigned2` also distinguish absent assignments. Save with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) and export data
frames with
[`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html).
Reading saved output performs no calculation.

## Details

All observed rater identifiers are paired. Each pair uses only units
with two nonmissing scores. Other raters' missing scores do not exclude
a unit for that pair. Missing-score rows and absent assignments are
distinguished in `cases`. Duplicate rater-unit cells (including
missing-score duplicates) are rejected rather than averaged. Identifiers
must be nonmissing and nonblank. There is no imputation or observation
weighting. Pairs with fewer than two complete units remain in `table`
with an unavailable ICC.

Let R, C and E be the unit, rater and residual ANOVA mean squares on a
complete n-by-2 matrix. Following Koo and Li (2016, Table 3), the
numerator is R-E. The single-rating denominator is R+E for consistency,
or R+E+2(C-E)/n for absolute agreement. The average-rating denominator
is R for consistency, or R+(C-E)/n for agreement. `Form` records
ICC(C,1), ICC(A,1), ICC(C,2) or ICC(A,2); interpret these together with
`Model`. ICC(A,2) denotes an average of two ratings, not Shrout–Fleiss
ICC(2,1). One-way ICCs are not computed.

Negative estimates are retained. A nonpositive denominator makes `ICC`
unavailable and sets `Status = "nonpositive_denominator"`; `RawICC`
retains the algebraic ratio when finite so it cannot masquerade as a
valid reliability estimate. An entirely constant matrix is undefined,
not 1. Internally scores are shifted and scaled to avoid
overflow/underflow. `anova` records scaled mean squares, the
offset/scale, numerator and denominator, so the calculation can be
reconstructed. These scaled mean squares are not variances in the
original score units.

Results describe each pair's retained unit mix. Different pairs can have
different units and score ranges; their ICCs cannot automatically rank
rater quality and should not be averaged into a panel ICC. Restricted
unit variability can lower ICC without larger absolute disagreement.
Inference requires a suitable sampling design and assumptions about
errors and dependence. Treating several tasks from one person as
separate units does not make them independent. No confidence intervals,
hypothesis tests, quality bands or rater-training decisions are
supplied. This is distinct from the component variance shares in
[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md),
MFRM separation reliability and the fitted expected agreement in
[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md).

## References

Koo, T. K., & Li, M. Y. (2016). A guideline of selecting and reporting
intraclass correlation coefficients for reliability research. *Journal
of Chiropractic Medicine, 15*(2), 155-163.
[doi:10.1016/j.jcm.2016.02.012](https://doi.org/10.1016/j.jcm.2016.02.012)
. Table 3; see also the 2017 erratum,
[doi:10.1016/j.jcm.2017.10.001](https://doi.org/10.1016/j.jcm.2017.10.001)
, correcting the one-way ICC(1,1) formula.

## See also

[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md),
[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md),
[`krippendorff_alpha_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/krippendorff_alpha_table.md),
[`score_comparison_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_comparison_table.md)

## Examples

``` r
data("mfrmr_example_agreement", package = "mfrmr")
ratings <- mfrmr_example_agreement
absolute <- pairwise_icc_table(ratings, rater = "Rater",
  unit = c("Person", "Task"), score = "Score", definition = "agreement")
consistent <- pairwise_icc_table(ratings, rater = "Rater",
  unit = c("Person", "Task"), score = "Score", definition = "consistency")
absolute$table
#>   Pair Rater1 Rater2  N CandidateUnits ExcludedUnits       ICC    RawICC
#> 1    1     R1     R2 12             12             0 0.5925926 0.5925926
#> 2    2     R1     R3 10             12             2 0.8474576 0.8474576
#> 3    3     R2     R3 10             12             2 0.4807692 0.4807692
#>      Status         Model Definition   Type     Form
#> 1 available two_way_mixed  agreement single ICC(A,1)
#> 2 available two_way_mixed  agreement single ICC(A,1)
#> 3 available two_way_mixed  agreement single ICC(A,1)
consistent$table
#>   Pair Rater1 Rater2  N CandidateUnits ExcludedUnits       ICC    RawICC
#> 1    1     R1     R2 12             12             0 1.0000000 1.0000000
#> 2    2     R1     R3 10             12             2 0.8333333 0.8333333
#> 3    3     R2     R3 10             12             2 0.8333333 0.8333333
#>      Status         Model  Definition   Type     Form
#> 1 available two_way_mixed consistency single ICC(C,1)
#> 2 available two_way_mixed consistency single ICC(C,1)
#> 3 available two_way_mixed consistency single ICC(C,1)
# R1/R2 have perfect consistency, but R2's one-category offset reduces agreement.
# These ICCs treat 0--3 as numeric scores; justify equal score intervals.
```
