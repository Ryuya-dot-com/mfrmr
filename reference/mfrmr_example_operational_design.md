# Planned assignment roster for the operational example

A score-free roster declaring all Person x Rater x Criterion cells
planned for `mfrmr_example_operational`. Pass it to the
`expected_design` argument of
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
to distinguish the six expected-but-unobserved cells from combinations
that were never assigned.

## Format

A data.frame with 288 rows and 5 columns:

- Study:

  Example dataset label (`"OperationalExample"`).

- Person:

  Person/respondent identifier.

- Rater:

  Planned rater identifier.

- Criterion:

  Planned criterion label.

- Group:

  Balanced grouping label (`"A"` / `"B"`).

## Source

Synthetic assignment roster generated with the operational example by
`data-raw/make-operational-example.R`. It contains no empirical records
and no fabricated scores.

## Details

The roster contains 288 planned cells. The observed
`mfrmr_example_operational` table contains 282 rows, so an explicit
design comparison identifies six planned omissions. Extra roster columns
such as `Study` and `Group` are ignored unless they are named as model
facets.

## Examples

``` r
data("mfrmr_example_operational", package = "mfrmr")
data("mfrmr_example_operational_design", package = "mfrmr")
review <- describe_mfrm_data(
  mfrmr_example_operational,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  expected_design = mfrmr_example_operational_design
)
summary(review)$structural_missingness
#>     Status ExpectedCells ObservedCells MatchedCells MissingExpectedCells
#> 1 declared           288           282          282                    6
#>   UnexpectedObservedCells CoverageRate ExpectedOnlyPersons UnexpectedPersons
#> 1                       0    0.9791667                   0                 0
```
