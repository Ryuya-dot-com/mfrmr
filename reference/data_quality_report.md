# Build a data quality summary report (preferred alias)

Build a data quality summary report (preferred alias)

## Usage

``` r
data_quality_report(
  fit,
  data = NULL,
  person = NULL,
  facets = NULL,
  score = NULL,
  weight = NULL,
  min_category_count = 10,
  dominant_category_cutoff = 0.95,
  include_fixed = FALSE
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- data:

  Optional raw data frame used for row-level review.

- person:

  Optional person column name in `data`.

- facets:

  Optional facet column names in `data`.

- score:

  Optional score column name in `data`.

- weight:

  Optional weight column name in `data`.

- min_category_count:

  Minimum raw or weighted count used to label a non-zero facet-level
  score category as sparse. Default `10`.

- dominant_category_cutoff:

  Proportion in `(0, 1]` used to flag a facet level whose responses are
  dominated by one score category. Default `0.95`.

- include_fixed:

  If `TRUE`, include a legacy-compatible fixed-width text block.

## Value

A named list with data-quality report components. Class:
`mfrm_data_quality`.

## Details

`summary(out)` is supported through
[`summary()`](https://rdrr.io/r/base/summary.html). `plot(out)` is
dispatched through
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) for class
`mfrm_data_quality` (`type = "dashboard"`, `"quality_flags"`,
`"row_review"`, `"category_counts"`, `"score_support"`,
`"facet_category_usage"`, `"facet_response_patterns"`, `"score_map"`,
`"missing_rows"`).

## Interpreting output

- `summary`: retained/dropped row overview.

- `quality_overview`: area-level QC status for rows, score support,
  facet-category use, and design matching.

- `quality_flags`: prioritized QC flags with counts and recommended next
  actions. This is not an item/person/rater table.

- `row_review`: reason-level breakdown for data issues.

- `category_counts`: post-filter category usage, including retained
  zero-count score-support categories.

- `score_support_review`: quick view of zero-count boundary/intermediate
  categories and their threshold-functioning caveats.

- `category_usage_by_facet`: facet-level category counts over the
  retained score support.

- `category_usage_summary`: per-facet-level zero/sparse category
  summary.

- `facet_response_patterns`: facet-level response-pattern summaries,
  including single-category and dominant-category use.

- `caveats`: user-facing score-support warnings, including cases where
  non-consecutive original labels such as `1, 2, 4, 5` were recoded
  because `keep_original = FALSE`.

- `score_map`: original-to-internal score mapping used when labels are
  recoded.

- `unknown_elements`: facet levels in raw data but not in fitted design.

## Typical workflow

1.  Run `data_quality_report(...)` with raw data.

2.  Check `summary(out)` and `plot(out, type = "dashboard")`, then
    inspect `quality_flags`, score-support, score-map,
    facet-response-pattern, and missing/unknown element sections as
    needed.

3.  Resolve missing values, score-support gaps, and sparse categories
    before final estimation/reporting.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md),
[`specifications_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/specifications_report.md),
[mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)

## Examples

``` r
toy <- load_mfrmr_data("example_operational")
fit <- fit_mfrm(
  toy, "Person", c("Rater", "Criterion"), "Score",
  method = "MML", quad_points = 7, maxit = 30
)
out <- data_quality_report(
  fit,
  data = toy, person = "Person",
  facets = c("Rater", "Criterion"), score = "Score"
)
summary(out)
#> mfrmr Data Quality Summary 
#>   Class: mfrm_data_quality
#>   Components: 14
#> 
#> Data quality overview
#>  TotalLinesInData TotalDataLines TotalNonBlankResponsesFound MissingScoreRows
#>               282            282                         282                0
#>  MissingFacetRows MissingPersonRows InvalidWeightRows OutOfRangeScoreRows
#>                 0                 0                 0                   0
#>  ValidResponsesUsedForEstimation ZeroCountScoreCategories
#>                              282                        0
#>  IntermediateZeroCountScoreCategories FacetLevelsWithZeroCategories
#>                                     0                             0
#>  FacetLevelsWithIntermediateZeroCategories FacetLevelsWithSparseCategories
#>                                          0                               6
#>  FacetLevelsWithSingleCategoryUse FacetLevelsWithDominantCategoryUse
#>                                 0                                  0
#>  FacetLevelsWithBoundaryOnlyUse ScoreSupportCaveats
#>                               0                   0
#> 
#> Review rows: quality_flags
#>                Area Severity                                  Flag Count
#>  Facet category use   review Facet levels have sparse category use     6
#>          Unit PercentOfData
#>  facet levels            NA
#>                                                               Action
#>  Interpret category-functioning evidence for these levels as sparse.
#> 
#> Settings
#>                   Setting Value
#>        min_category_count    10
#>  dominant_category_cutoff  0.95
#> 
#> Notes
#>  - Data quality summary for missingness, row status, score support, and
#>    category usage.
#>  - QC overview: 0 high-priority area(s), 1 review area(s).
#>  - Priority QC flags: 1 flag(s), including 0 high-severity flag(s).
#>  - Facet-level category use: 0 level(s) have zero-count categories; 0 have
#>    zero-count intermediate categories; 6 have sparse non-zero categories.
p_dq <- plot(out, draw = FALSE)
p_dq$data$plot
#> [1] "dashboard"
```
