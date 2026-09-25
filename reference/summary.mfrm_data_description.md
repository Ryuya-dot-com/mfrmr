# Summarize a data-description object

Read a compact summary of the checks from
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
before fitting a model. Save it with `review <- summary(data_review)`
and select the tables you need with `$`, as in the example.

## Usage

``` r
# S3 method for class 'mfrm_data_description'
summary(object, digits = 3, top_n = 10, ...)
```

## Arguments

- object:

  Output from
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md).

- digits:

  Number of digits for numeric rounding.

- top_n:

  Maximum rows shown in preview blocks.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_data_description`.

- `overview`: design/sample counts

- `missing`: top columns by missingness

- `score_distribution`: compact score-usage table, including zero-count
  categories retained by the prepared score support

- `facet_overview`: facet-level coverage summary

- `structural_missingness`: declared assignment coverage summary; status
  is `"not_declared"` when no assignment roster was supplied

- `structural_level_coverage`: expected versus observed level counts

- `design_connectivity`: Person-facet component counts for observed and
  declared-expected designs

- `design_components`: component sizes and facet-level labels; person
  labels are suppressed unless explicitly requested in
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)

- `linkage_summary`: sparse-support and shared-person counts by facet

- `duplicate_cell_summary`: aggregate duplicate-cell counts

- `agreement`: selected-facet agreement summary when available

- `agreement_settings`: selected scorer facet, matching context, and
  status

- `row_retention`: row counts before and after preparation filters

- `preparation_notes`: structured preparation notes retained from
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)

- `reporting_map`: manuscript-oriented guide to what is covered here
  versus which companion outputs should be consulted

- `caveats`: structured warning/review rows for score-support issues;
  `print(summary(ds))` shows a compact `Caveats` block when rows are
  present

- `notes`: plain-language explanations of missingness, preparation,
  score support, and design-review findings

## Details

`data_review` holds the complete data checks; `review` holds summary
tables and notes. Neither object contains model estimates. The default
`top_n = 10` limits the missing-column and score-distribution previews;
use `data_review$missing_by_column` and `data_review$score_distribution`
to see the complete tables.

## Interpreting output

Recommended read order:

- `overview`: retained ratings (`Observations`), persons, facets, and
  categories. Compare input and retained `Rows` in `row_retention` and
  investigate unexpected `DroppedRows`. `CategoryPolicy` and
  `ScoreRecoded` distinguish the selected policy from actual changes to
  score values. Older results without the policy record report
  `"not_recorded"`; an absent map gives `NA` for recoding.

- `missing`: input `NA` counts by column. This table is named
  `missing_by_column` in the original `data_review` object. Declared
  missing-code replacements and invalid score text can cause additional
  row loss; inspect `data_review$missing_recoding` and
  `preparation_notes`.

- `score_distribution`: category usage balance.

- `notes` / printed `Caveats`: retained zero-count score categories and
  related score-support caveats. With `keep_original = TRUE`, a retained
  unused internal category stops fitting; review the data and rubric
  first.

- `facet_overview`: coverage per facet (minimum/maximum weighted
  counts).

- `agreement`: observed-score agreement for the selected scorer facet
  (when available).

- `design_connectivity`: check for more than one observed component
  before comparing facet levels. `structural_missingness` reports
  planned omissions only when an assignment roster was supplied;
  `not_declared` does not mean that no ratings are missing.

Very low `MinWeightedN` in `facet_overview` is a practical warning for
unstable downstream facet estimates.

## Typical workflow

1.  Run
    [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
    on raw long-format data.

2.  Inspect `review <- summary(data_review)` before model fitting.

3.  Correct input issues and repeat the review, then pass the corrected
    rating data to
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    with the same preparation settings.

## See also

[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md),
[`summary.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md)

## Examples

``` r
library(mfrmr)
ratings <- load_mfrmr_data("example_operational")

# Demonstrate two missing scores in a copy of the example data
ratings$Score[1:2] <- NA
data_review <- describe_mfrm_data(
  data = ratings,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  rating_min = 1,
  rating_max = 4,
  category_policy = "preserve"
)
review <- summary(data_review)
review$row_retention # 282 input rows, 280 retained rows
#>                             Stage Rows DroppedRows
#> 1          input_selected_columns  282           0
#> 2 after_missing_and_weight_filter  280           2
#>                            DroppedReason
#> 1                                       
#> 2 missing values or non-positive weights
review$missing       # Score has 2 missing input values
#>      Column Missing
#> 1     Score       2
#> 2 Criterion       0
#> 3    Person       0
#> 4     Rater       0
review$overview      # Counts describe the retained ratings
#>   Observations TotalWeight Persons Facets Categories RatingMin RatingMax
#> 1          280         280      48      2          4         1         4
#>   RatingRangeSource RatingMinSource RatingMaxSource CategoryPolicy ScoreRecoded
#> 1          declared        declared        declared       preserve        FALSE
review$notes         # Explanations to read before fitting
#> [1] "Missing values were detected in one or more input columns."                                                                                                                                               
#> [2] "Structural missingness was not assessed because `expected_design` was not supplied. Absent rows cannot be distinguished from cells that were never assigned."                                             
#> [3] "Dropped 2 row(s) with missing values or non-positive weights before estimation. Pass `missing_codes = ...` to recode user-specified missing markers, or pre-process upstream if you need to keep the row."

# The original description retains the full missingness table
data_review$missing_by_column
#> # A tibble: 4 × 2
#>   Column    Missing
#>   <chr>       <int>
#> 1 Person          0
#> 2 Rater           0
#> 3 Criterion       0
#> 4 Score           2
# Investigate missingness before using ratings in fit_mfrm()
```
