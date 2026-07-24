# Summarize a data-description object

Summarize a data-description object

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

## Details

This summary is intended as a compact pre-fit quality snapshot for
manuscripts and analysis logs.

## Interpreting output

Recommended read order:

- `overview`: sample size, persons/facets/categories.

- `missing`: missingness hotspots by selected input columns.

- `score_distribution`: category usage balance.

- `notes` / printed `Caveats`: retained zero-count score categories and
  related score-support caveats; intermediate unused categories should
  be treated as threshold-functioning warnings before model fitting.

- `facet_overview`: coverage per facet (minimum/maximum weighted
  counts).

- `agreement`: observed-score agreement for the selected scorer facet
  (when available).

Very low `MinWeightedN` in `facet_overview` is a practical warning for
unstable downstream facet estimates.

## Typical workflow

1.  Run
    [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
    on raw long-format data.

2.  Inspect `summary(ds)` before model fitting.

3.  Resolve sparse/missing issues, then run
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

## See also

[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md),
[`summary.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
ds <- describe_mfrm_data(toy, "Person", c("Rater", "Criterion"), "Score")
summary(ds)
#> mfrm Data Description Summary
#> 
#> Overview
#>  Observations TotalWeight Persons Facets Categories RatingMin RatingMax
#>           768         768      48      2          4         1         4
#>  RatingRangeSource RatingMinSource RatingMaxSource
#>           observed        observed        observed
#> 
#> Missing by column
#>     Column Missing
#>  Criterion       0
#>     Person       0
#>      Rater       0
#>      Score       0
#> 
#> Planned assignment coverage
#>        Status ExpectedCells ObservedCells MatchedCells MissingExpectedCells
#>  not_declared            NA           768           NA                   NA
#>  UnexpectedObservedCells CoverageRate ExpectedOnlyPersons UnexpectedPersons
#>                       NA           NA                  NA                NA
#> 
#> Person-facet connectivity
#>     Basis     Facet PersonNodes FacetLevelNodes Edges Components
#>  observed     Rater          48               4   192          1
#>  observed Criterion          48               4   192          1
#>  LargestComponentPersons LargestComponentLevels LargestComponentPercent
#>                       48                      4                     100
#>                       48                      4                     100
#>  Connected
#>       TRUE
#>       TRUE
#> 
#> Facet linkage support
#>      Facet Levels Persons MinPersonsPerLevel MedianPersonsPerLevel
#>      Rater      4      48                 48                    48
#>  Criterion      4      48                 48                    48
#>  MinLevelsPerPerson MedianLevelsPerPerson LinkingPersons LinkingPersonRate
#>                   4                     4             48                 1
#>                   4                     4             48                 1
#>  SingleLevelPersons SparseLevels SparseLevelThreshold
#>                   0            0                    2
#>                   0            0                    2
#> 
#> Score distribution
#>  Score RawN WeightedN Percent
#>      1  139       139  18.099
#>      2  241       241  31.380
#>      3  252       252  32.812
#>      4  136       136  17.708
#> 
#> Facet coverage
#>      Facet Levels TotalWeightedN MeanWeightedN MinWeightedN MaxWeightedN
#>  Criterion      4            768           192          192          192
#>      Rater      4            768           192          192          192
#> 
#> Observed agreement by Rater
#>  RaterFacet Raters Pairs Contexts TotalPairs OpportunityCount ExactAgreements
#>       Rater      4     6      192       1152             1152             417
#>  ExpectedAgreements ExactAgreement ExpectedExactAgreement
#>                  NA          0.362                     NA
#>  AgreementMinusExpected AdjacentAgreements AdjacentAgreement MeanAbsDiff
#>                      NA                956              0.83       0.826
#>  MeanCorr
#>     0.378
#> 
#> Paper reporting map
#>                                 Area  CoveredHere
#>               Sample / design counts          yes
#>                   Missingness review          yes
#>          Planned assignment coverage not declared
#>            Person-facet connectivity          yes
#>  Score usage / category distribution          yes
#>                       Facet coverage          yes
#>                Rater-facet agreement          yes
#>     Fit / reliability / residual PCA           no
#>                                                 CompanionOutput
#>                                summary(describe_mfrm_data(...))
#>                                summary(describe_mfrm_data(...))
#>       data_review$structural_missingness$missing_expected_cells
#>                                   data_review$design_components
#>                                summary(describe_mfrm_data(...))
#>                                summary(describe_mfrm_data(...))
#>  summary(describe_mfrm_data(...)) / plot_interrater_agreement()
#>                                     summary(diagnose_mfrm(fit))
#> 
#> Notes
#>  - No missing values were detected in selected input columns.
#>  - Structural missingness was not assessed because `expected_design` was not supplied. Absent rows cannot be distinguished from cells that were never assigned.
```
