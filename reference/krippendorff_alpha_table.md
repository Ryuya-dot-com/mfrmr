# Compute Krippendorff's alpha across raters

Estimate observed-score agreement across two or more raters, allowing
unequal numbers of ratings per unit. This is Krippendorff's agreement
coefficient, not Cronbach's internal-consistency alpha or MFRM
separation reliability. No measurement-model fitting is performed.

## Usage

``` r
krippendorff_alpha_table(
  data,
  rater,
  unit,
  score,
  level = c("nominal", "ordinal", "interval", "ratio"),
  categories = NULL
)
```

## Arguments

- data:

  Long-format data with at most one row per rater and unit.

- rater:

  Name of the rater identifier column.

- unit:

  Names of columns jointly identifying a rated unit, for example
  `c("Person", "Task")`. They match observations, not variance
  components.

- score:

  Name of the score column. Missing scores are `NA`. Nominal/ordinal
  scores may be numeric, character, factor or logical; factors compare
  by labels. Interval/ratio scores must be finite numeric values, and
  ratio scores must be nonnegative with a meaningful zero.

- level:

  Measurement level: `"nominal"` (default), `"ordinal"`, `"interval"` or
  `"ratio"`. Choose on substantive grounds; numeric category codes alone
  do not establish an interval or ratio scale.

- categories:

  For ordinal scores, the required distinct category values in their
  substantive order. Factor levels and numeric spacing never silently
  set this order. For nominal scores, optional permitted values; if
  `NULL`, observed nonmissing values are used. Values must have the same
  numeric/character/logical representation as `score` (factors use
  labels). Unused categories are allowed. Leave `NULL` for
  interval/ratio scores.

## Value

A plain list with `table` (alpha, observed/expected disagreement,
availability and sample counts), `counts` (category values, nonmissing
and pairable counts, plus ordinal positions), `cases` (input rows and
exclusion reasons), `unit_summary` (assignment counts and unit
disagreements), `units` (unique input unit keys), `settings` and
`notes`. `Unit` indexes rows of `units`. Save with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html); export data
frames with
[`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html).
Reopening the saved list performs no calculation.

## Details

The coefficient is \\1-D_o/D_e\\. Only units with at least two
nonmissing scores contribute to either disagreement. A unit with m
ratings contributes its ordered rating pairs divided by m-1 to the
coincidence counts, hence contributes m pairable ratings overall. Units
are not equally weighted when m differs. The expected disagreement draws
two distinct observations without replacement from the pooled pairable
ratings, with denominator n(n-1), where n is the number of pairable
ratings. This is not Cohen's kappa chance model or MFRM model-implied
expected agreement.

The squared difference function is 0/1 mismatch for nominal scores,
frequency-based rank distance for ordinal scores, squared numeric
difference for interval scores, and \\((c-k)/(c+k))^2\\ for ratio scores
(0 when both values are zero). Ordinal positions use cumulative
pairable-category counts minus half the category count, divided by n.
The squared difference between these positions is proportional to
Krippendorff's ordinal distance. It is not quadratic weighting of
category numbers or equally spaced category ranks. Unused ranks and
singleton-only categories do not alter pairable distances.

Interval distances are calculated after subtracting `score_offset`,
dividing by `score_half_range`, and dividing by 2, using only pairable
values to set the offset and half-range. Constant pairable values map to
zero. This avoids squaring very large or tiny raw scores. The common
normalization leaves alpha unchanged; reported disagreements are on this
normalized scale, not original squared score units. Ordinal positions
are similarly normalized by n. Nominal and ratio disagreements use their
stated distance directly. Computation avoids a dense
category-by-category matrix. Ratio computation still requires quadratic
time in the number of distinct pairable values.

No rows are imputed and repeated rater-unit cells are rejected,
including repetitions with missing scores. All input rows remain in
`cases`. `unit_summary` distinguishes missing scores on assigned rows
from absent assignments relative to the observed rater roster. Units
with no input rows at all are unknown to the function. Missingness and
selective assignment may affect representativeness; numerical handling
does not correct that bias.

Negative estimates are retained. With no pairable ratings or zero
expected disagreement, alpha is unavailable with a reason rather than
set to 0 or 1. A finite coefficient describes this pooled rating sample,
not each rater's accuracy against a reference or a guarantee of
interchangeable ratings. There are no confidence intervals, tests,
quality cutoffs or bootstrap claims. Dependencies among several tasks
from one person require attention in any subsequent sampling inference.
Circular, bipolar and custom metrics are not implemented.

## References

Krippendorff, K. (2011; literature updated 2013). *Computing
Krippendorff's Alpha-Reliability*. Sections A-E, pp. 1-10.
<https://www.asc.upenn.edu/krippendorffs-alpha-reliability>

## See also

[`pairwise_icc_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/pairwise_icc_table.md),
[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md),
[`score_comparison_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_comparison_table.md)

## Examples

``` r
data("mfrmr_example_agreement", package = "mfrmr")
ratings <- mfrmr_example_agreement
agreement <- krippendorff_alpha_table(ratings, rater = "Rater",
  unit = c("Person", "Task"), score = "Score", level = "ordinal", categories = 0:3)
agreement$table
#>       Alpha   Level    Status ObservedDisagreement ExpectedDisagreement Raters
#> 1 0.5666233 ordinal available           0.06785569            0.1565744      3
#>   Units PairableUnits PairableRatings NonmissingRatings MissingScores
#> 1    12            12              34                34             1
#>   SingletonUnits UnratedUnits
#> 1              0            0
agreement$unit_summary # Each response needs at least two observed ratings.
#>    Unit AssignedRows NonmissingRatings MissingScores AbsentAssignments Included
#> 1     1            3                 3             0                 0     TRUE
#> 2     2            3                 3             0                 0     TRUE
#> 3     3            3                 3             0                 0     TRUE
#> 4     4            2                 2             0                 1     TRUE
#> 5     5            3                 3             0                 0     TRUE
#> 6     6            3                 3             0                 0     TRUE
#> 7     7            3                 3             0                 0     TRUE
#> 8     8            3                 3             0                 0     TRUE
#> 9     9            3                 3             0                 0     TRUE
#> 10   10            3                 3             0                 0     TRUE
#> 11   11            3                 3             0                 0     TRUE
#> 12   12            3                 2             1                 0     TRUE
#>    ObservedDisagreement
#> 1            0.05204729
#> 2            0.07626874
#> 3            0.15844867
#> 4            0.07807093
#> 5            0.07626874
#> 6            0.03243945
#> 7            0.05204729
#> 8            0.07626874
#> 9            0.03243945
#> 10           0.05204729
#> 11           0.07626874
#> 12           0.04865917
agreement$notes
#> [1] "Krippendorff's alpha measures pooled observed-score agreement, not Cronbach's alpha, MFRM separation reliability or criterion-referenced rater accuracy."
#> [2] "Only pairable ratings contribute to observed and expected disagreement; unequal rating counts weight units differently."                                 
#> [3] "Missingness and selective assignment may affect representativeness; no imputation or automatic correction is made."                                      
#> [4] "No confidence intervals, tests or quality cutoffs are supplied; negative estimates are retained."                                                        
#> [5] "Ordinal distances use pairable-category frequencies, not equally spaced ranks or QWK weights."                                                           
# Ordinal alpha uses category ordering; it is not quadratic weighted kappa.
```
