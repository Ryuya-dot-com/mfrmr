# Synthetic ratings illustrating agreement, offsets and missing scores

Ready-to-load data from the rating-agreement tutorial. Six Persons
complete two Tasks, with up to three Raters on each response. Load with
`data("mfrmr_example_agreement", package = "mfrmr")`.

## Format

A data frame with 35 rows and four columns: `Person`, `Task`, `Rater`,
and `Score`. Each row is one rater's rating of one Person's response to
one Task. Scores use the declared categories 0–3.

## Source

Existing data from the rating-agreement tutorial. The deterministic
construction is retained in `data-raw/make-teaching-data.R` in the
source repository.

## Details

Rater R2 always scores one category above R1, so their rankings agree
but their scores differ. R3 has two deliberately different scores, one
missing score (P06/T2) and one absent row (P02/T2). There are 34
observed scores. Missing ratings are not zero scores; an absent row
alone does not identify whether a rating was planned. Use
`unit = c("Person", "Task")` to match responses. `unit = "Person"` would
mix two different responses.

These are constructed teaching data, not empirical records, expert
standards or evidence of a method's performance in a population.

## See also

[`pairwise_kappa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/pairwise_kappa_table.md),
[`krippendorff_alpha_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/krippendorff_alpha_table.md),
[`gwet_ac2_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/gwet_ac2_table.md),
[`pairwise_icc_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/pairwise_icc_table.md),
[`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md)

## Examples

``` r
data("mfrmr_example_agreement", package = "mfrmr")
ratings <- mfrmr_example_agreement
head(ratings)
#>   Person Task Rater Score
#> 1    P01   T1    R1     0
#> 2    P01   T2    R1     1
#> 3    P02   T1    R1     2
#> 4    P02   T2    R1     0
#> 5    P03   T1    R1     1
#> 6    P03   T2    R1     2
with(ratings, table(Rater, Score, useNA = "ifany"))
#>      Score
#> Rater 0 1 2 3 <NA>
#>    R1 4 4 4 0    0
#>    R2 0 4 4 4    0
#>    R3 3 4 3 0    1
agreement <- pairwise_kappa_table(ratings, rater = "Rater",
  unit = c("Person", "Task"), score = "Score", categories = 0:3)
agreement$table
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
# Each pair uses its own shared responses; inspect its denominator as well.
```
