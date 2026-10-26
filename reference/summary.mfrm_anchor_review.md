# Summarize an anchor-review object

Summarize an anchor-review object

## Usage

``` r
# S3 method for class 'mfrm_anchor_review'
summary(object, digits = 3, top_n = 10, ...)
```

## Arguments

- object:

  Output from
  [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md).

- digits:

  Number of digits for numeric rounding.

- top_n:

  Maximum rows shown in issue previews.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_anchor_review`.

## Details

This summary provides a compact pre-estimation review of anchor and
group-anchor specifications.

## Interpreting output

Recommended order:

- `issue_counts`: primary triage table (non-zero issues first).

- `facet_summary`: anchored/grouped/free-level balance by facet.

- `level_observation_summary` and `category_counts`: sparse-cell
  diagnostics.

- `recommendations`: concrete remediation suggestions.

If `issue_counts` is non-empty, treat anchor constraints as provisional
and resolve issues before final estimation.

## Typical workflow

1.  Run
    [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)
    with intended anchors/group anchors.

2.  Review `summary(review)` and recommendations.

3.  Revise anchor tables, then call
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

## See also

[`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
review <- review_mfrm_anchors(toy, "Person", c("Rater", "Criterion"), "Score")
summary(review)
#> mfrm Anchor Review Summary
#> 
#> Facet summary
#>      Facet Levels AnchoredLevels GroupedLevels GroupCount ConstrainedLevels
#>     Person     48              0             0          0                 0
#>      Rater      4              0             0          0                 0
#>  Criterion      4              0             0          0                 0
#>  OverlapLevels FreeLevels Noncenter DummyFacet Centered      OriginBasis
#>              0         48      TRUE      FALSE    FALSE estimated_origin
#>              0          4     FALSE      FALSE     TRUE         zero_sum
#>              0          4     FALSE      FALSE     TRUE         zero_sum
#> 
#> Level observation summary
#>      Facet Levels MinObsPerLevel MedianObsPerLevel RecommendedMinObs PassMinObs
#>  Criterion      4            192               192                30       TRUE
#>     Person     48             16                16                30      FALSE
#>      Rater      4            192               192                30       TRUE
#> 
#> Category counts
#>  Category RawN WeightedN RecommendedMinObs PassMinObs
#>         1  139       139                10       TRUE
#>         2  241       241                10       TRUE
#>         3  252       252                10       TRUE
#>         4  136       136                10       TRUE
#> 
#> Recommendations
#>  - Package observation-count screen: about 30 observations per element are used for review. Low-observation facets: Person.
#>  - Supply anchors in internal logit coordinates, not Umean/Uscale display units. Use compatible score coding, orientation and reporting scales across linked analyses.
#>  - Current noncenter facet is 'Person'. Other facets sum to zero across all levels, including anchors and group totals. The ungrouped remainder balances those contributions; a single remaining level is fixed by that balance.
#> 
#> Notes
#>  - No anchor-table issue rows were detected.
```
