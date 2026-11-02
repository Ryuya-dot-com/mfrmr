# Compute pairwise weighted Cohen's kappa

Compare observed scores on matched units for every pair of raters, using
quadratic (QWK), linear or unweighted agreement. No model is fitted.

## Usage

``` r
pairwise_kappa_table(
  data,
  rater,
  unit,
  score,
  categories,
  weights = c("quadratic", "linear", "unweighted")
)
```

## Arguments

- data:

  Long-format ratings with at most one row per rater and unit.

- rater:

  Name of the rater identifier column.

- unit:

  Names of columns jointly identifying a rated unit, such as
  `c("Person", "Task")`.

- score:

  Name of the score column. Values may be numeric, character, factor or
  logical, with `NA` for missing scores. Factors use their labels.

- categories:

  Required distinct permitted category values, including unused
  categories, in their substantive order. At least two are required.
  They must have the same numeric/character/logical representation as
  scores. With linear/quadratic weights, numeric values use their actual
  spacing; character/logical values use equally spaced positions in this
  vector. Factor levels never silently determine the order. To treat
  numeric codes as equally spaced ranks, explicitly convert scores and
  categories to character. Choose spacing on substantive grounds.

- weights:

  One of `"quadratic"` (default), `"linear"` or `"unweighted"`.
  Agreement weights are 1 minus squared normalized distance, 1 minus
  normalized absolute distance, or the identity matrix, respectively.

## Value

A plain list with `table` (one row per pair), `counts` (nonzero retained
contingency cells, with category indices), `categories` (indices, values
and weighting positions), `weights` (agreement matrix), `cases`,
`units`, `settings` and `notes`. `Unit` indexes `units`. Save with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) or export data
frames with
[`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html).

## Details

For each pair, both observed and expected agreement use only common
complete units. Expected cell proportions are products of the two
rater-specific margins on this same sample. Kappa is
`(observed - expected)/(1 - expected)`. This complete-case convention
differs from the all-available rater margins in Gwet's incomplete-data
Example 4.1. Different pairs may retain different cohorts; comparing or
averaging their kappas does not establish a panel coefficient. At least
two complete units are required, as in the existing QWK score-comparison
interface.

Computation uses the equivalent disagreement ratio, with distances
rescaled to the categories actually present in each retained pair. The
common scale cancels, avoiding loss of the coefficient when an unused
numeric category is very distant. `ScaledObservedDisagreement` and
`ScaledExpectedDisagreement` retain those ingredients; agreement columns
use the declared full-scale weights. Agreement columns can round to 1 at
extreme relative spacings even when kappa is defined. Negative estimates
remain visible; zero expected disagreement returns `NA` with a status.

Duplicate rater-unit cells are rejected before dropping missing scores.
The case audit distinguishes an absent assignment from an explicit
missing score and retains the union of units assigned to either member
of the pair. No imputation, confidence intervals, tests or quality
cutoffs are supplied. Missingness may affect representativeness.
Agreement does not establish reference accuracy or MFRM rater-severity
homogeneity. Storage of the weight matrix requires space quadratic in
the number of declared categories; these are categorical-score
interfaces, not continuous-score ICCs.

## References

Cohen, J. (1968). Weighted kappa: nominal scale agreement with provision
for scaled disagreement or partial credit. *Psychological Bulletin*, 70,
213-220. [doi:10.1037/h0026256](https://doi.org/10.1037/h0026256) .

Gwet, K. L. *Handbook of Inter-Rater Reliability*, fifth edition, volume
1, chapter 4, pp. 100-110, equations 4.2.4-4.2.6.
<https://www.agreestat.com/assets/cac5-chapter4-excerpt.pdf>

## See also

[`gwet_ac2_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/gwet_ac2_table.md),
[`krippendorff_alpha_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/krippendorff_alpha_table.md),
[`pairwise_icc_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/pairwise_icc_table.md),
[`score_comparison_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/score_comparison_table.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("pairwise_kappa_table", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
data("mfrmr_example_agreement", package = "mfrmr")
ratings <- mfrmr_example_agreement
head(ratings) # One rater's score for one Person-Task response.
pairs <- pairwise_kappa_table(ratings, rater = "Rater",
  unit = c("Person", "Task"), score = "Score", categories = 0:3)
pairs$table
pairs$cases # Included marks the shared nonmissing ratings for each pair.
# R2 gives every response one category more than R1: equal rankings do not
# imply agreement. Do not treat two Tasks by the same Person as one response.
} # }
```
