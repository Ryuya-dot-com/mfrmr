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

[`gwet_ac2_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/gwet_ac2_table.md),
[`krippendorff_alpha_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/krippendorff_alpha_table.md),
[`pairwise_icc_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/pairwise_icc_table.md),
[`score_comparison_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_comparison_table.md)

## Examples

``` r
data("mfrmr_example_agreement", package = "mfrmr")
ratings <- mfrmr_example_agreement
head(ratings) # One rater's score for one Person-Task response.
#>   Person Task Rater Score
#> 1    P01   T1    R1     0
#> 2    P01   T2    R1     1
#> 3    P02   T1    R1     2
#> 4    P02   T2    R1     0
#> 5    P03   T1    R1     1
#> 6    P03   T2    R1     2
pairs <- pairwise_kappa_table(ratings, rater = "Rater",
  unit = c("Person", "Task"), score = "Score", categories = 0:3)
pairs$table
#>   Pair Rater1 Rater2  N CandidateUnits ExcludedUnits     Kappa    Status
#> 1    1     R1     R2 12             12             0 0.5714286 available
#> 2    2     R1     R3 10             12             2 0.8333333 available
#> 3    3     R2     R3 10             12             2 0.4545455 available
#>   Weighting ObservedAgreement ExpectedAgreement ScaledObservedDisagreement
#> 1 quadratic         0.8888889         0.7407407                  0.1111111
#> 2 quadratic         0.9777778         0.8666667                  0.0500000
#> 3 quadratic         0.8666667         0.7555556                  0.1333333
#>   ScaledExpectedDisagreement
#> 1                  0.2592593
#> 2                  0.3000000
#> 3                  0.2444444
pairs$cases # Included marks the shared nonmissing ratings for each pair.
#>    Pair Rater1 Rater2 Unit Row1 Row2 Score1 Score2 Assigned1 Assigned2 Missing1
#> 1     1     R1     R2    1    1   13      0      1      TRUE      TRUE    FALSE
#> 2     1     R1     R2    2    2   14      1      2      TRUE      TRUE    FALSE
#> 3     1     R1     R2    3    3   15      2      3      TRUE      TRUE    FALSE
#> 4     1     R1     R2    4    4   16      0      1      TRUE      TRUE    FALSE
#> 5     1     R1     R2    5    5   17      1      2      TRUE      TRUE    FALSE
#> 6     1     R1     R2    6    6   18      2      3      TRUE      TRUE    FALSE
#> 7     1     R1     R2    7    7   19      0      1      TRUE      TRUE    FALSE
#> 8     1     R1     R2    8    8   20      1      2      TRUE      TRUE    FALSE
#> 9     1     R1     R2    9    9   21      2      3      TRUE      TRUE    FALSE
#> 10    1     R1     R2   10   10   22      0      1      TRUE      TRUE    FALSE
#> 11    1     R1     R2   11   11   23      1      2      TRUE      TRUE    FALSE
#> 12    1     R1     R2   12   12   24      2      3      TRUE      TRUE    FALSE
#> 13    2     R1     R3    1    1   25      0      0      TRUE      TRUE    FALSE
#> 14    2     R1     R3    2    2   26      1      1      TRUE      TRUE    FALSE
#> 15    2     R1     R3    3    3   27      2      1      TRUE      TRUE    FALSE
#> 16    2     R1     R3    4    4   NA      0     NA      TRUE     FALSE    FALSE
#> 17    2     R1     R3    5    5   28      1      1      TRUE      TRUE    FALSE
#> 18    2     R1     R3    6    6   29      2      2      TRUE      TRUE    FALSE
#> 19    2     R1     R3    7    7   30      0      0      TRUE      TRUE    FALSE
#> 20    2     R1     R3    8    8   31      1      2      TRUE      TRUE    FALSE
#> 21    2     R1     R3    9    9   32      2      2      TRUE      TRUE    FALSE
#> 22    2     R1     R3   10   10   33      0      0      TRUE      TRUE    FALSE
#> 23    2     R1     R3   11   11   34      1      1      TRUE      TRUE    FALSE
#> 24    2     R1     R3   12   12   35      2     NA      TRUE      TRUE    FALSE
#> 25    3     R2     R3    1   13   25      1      0      TRUE      TRUE    FALSE
#> 26    3     R2     R3    2   14   26      2      1      TRUE      TRUE    FALSE
#> 27    3     R2     R3    3   15   27      3      1      TRUE      TRUE    FALSE
#> 28    3     R2     R3    4   16   NA      1     NA      TRUE     FALSE    FALSE
#> 29    3     R2     R3    5   17   28      2      1      TRUE      TRUE    FALSE
#> 30    3     R2     R3    6   18   29      3      2      TRUE      TRUE    FALSE
#> 31    3     R2     R3    7   19   30      1      0      TRUE      TRUE    FALSE
#> 32    3     R2     R3    8   20   31      2      2      TRUE      TRUE    FALSE
#> 33    3     R2     R3    9   21   32      3      2      TRUE      TRUE    FALSE
#> 34    3     R2     R3   10   22   33      1      0      TRUE      TRUE    FALSE
#> 35    3     R2     R3   11   23   34      2      1      TRUE      TRUE    FALSE
#> 36    3     R2     R3   12   24   35      3     NA      TRUE      TRUE    FALSE
#>    Missing2 Included
#> 1     FALSE     TRUE
#> 2     FALSE     TRUE
#> 3     FALSE     TRUE
#> 4     FALSE     TRUE
#> 5     FALSE     TRUE
#> 6     FALSE     TRUE
#> 7     FALSE     TRUE
#> 8     FALSE     TRUE
#> 9     FALSE     TRUE
#> 10    FALSE     TRUE
#> 11    FALSE     TRUE
#> 12    FALSE     TRUE
#> 13    FALSE     TRUE
#> 14    FALSE     TRUE
#> 15    FALSE     TRUE
#> 16    FALSE    FALSE
#> 17    FALSE     TRUE
#> 18    FALSE     TRUE
#> 19    FALSE     TRUE
#> 20    FALSE     TRUE
#> 21    FALSE     TRUE
#> 22    FALSE     TRUE
#> 23    FALSE     TRUE
#> 24     TRUE    FALSE
#> 25    FALSE     TRUE
#> 26    FALSE     TRUE
#> 27    FALSE     TRUE
#> 28    FALSE    FALSE
#> 29    FALSE     TRUE
#> 30    FALSE     TRUE
#> 31    FALSE     TRUE
#> 32    FALSE     TRUE
#> 33    FALSE     TRUE
#> 34    FALSE     TRUE
#> 35    FALSE     TRUE
#> 36     TRUE    FALSE
# R2 gives every response one category more than R1: equal rankings do not
# imply agreement. Do not treat two Tasks by the same Person as one response.
```
