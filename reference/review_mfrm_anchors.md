# Review and normalize anchor/group-anchor tables

Review and normalize anchor/group-anchor tables

## Usage

``` r
review_mfrm_anchors(
  data,
  person,
  facets,
  score,
  anchors = NULL,
  group_anchors = NULL,
  weight = NULL,
  rating_min = NULL,
  rating_max = NULL,
  keep_original = FALSE,
  missing_codes = NULL,
  min_common_anchors = 5L,
  min_obs_per_element = 30,
  min_obs_per_category = 10,
  noncenter_facet = "Person",
  dummy_facets = NULL,
  category_policy = NULL
)
```

## Arguments

- data:

  A data.frame in long format (one row per rating event).

- person:

  Column name for person IDs.

- facets:

  Character vector of facet column names.

- score:

  Column name for observed score.

- anchors:

  Optional direct-anchor table (Facet, Level, Anchor). Retained values
  are fixed during estimation.

- group_anchors:

  Optional group-anchor table (Facet, Level, Group, GroupValue) defining
  group-mean constraints.

- weight:

  Optional weight/frequency column name.

- rating_min:

  Optional minimum category value.

- rating_max:

  Optional maximum category value.

- keep_original:

  Keep original category values. New code can instead use
  `category_policy = "preserve"`.

- missing_codes:

  Optional. `NULL` (default) is a no-op; `TRUE` or `"default"` converts
  the FACETS / SPSS / SAS sentinel set to `NA` on the score column
  before review while preserving person and facet identifiers. Supply a
  character vector to apply a custom code set across the person, facet,
  and score columns.

- min_common_anchors:

  Minimum directly anchored levels per non-Person facet used in the
  package count recommendation (default `5`). The function cannot verify
  that those levels have invariant cross-run identity.

- min_obs_per_element:

  Minimum weighted observations per facet level used in recommendations
  (default `30`).

- min_obs_per_category:

  Minimum weighted observations per score category used in
  recommendations (default `10`).

- noncenter_facet:

  One facet to leave non-centered.

- dummy_facets:

  Facets to fix at zero.

- category_policy:

  Optional explicit category choice: `"collapse"` maps gaps in the
  observed categories to consecutive scores; `"preserve"` keeps the
  intended ladder, declared with `rating_min` and `rating_max`. This
  changes the fitted category steps, not just labels. `NULL` (default)
  uses `keep_original`, whose default is `FALSE` (`"collapse"`).
  Supplying both choices is allowed only when they agree. Preservation
  does not estimate unsupported steps: fitting stops if a retained
  internal category has no observations. Use the same policy in
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
  and `review_mfrm_anchors()`.

## Value

A list of class `mfrm_anchor_review` with:

- `anchors`: cleaned direct constraints used by estimation

- `group_anchors`: cleaned group-mean constraints used by estimation

- `facet_summary`: counts of levels, constrained levels, and free levels

- `design_checks`: observation-count checks by level/category

- `thresholds`: active threshold settings used for recommendations

- `issue_counts`: issue-type counts

- `issues`: list of issue tables

- `recommendations`: package-native anchor guidance strings

## Details

This helper reviews computational constraints. A *direct anchor* fixes
an individual parameter to a supplied value. A *group anchor* constrains
the mean of declared elements to a supplied target. A *common-element
link* is different: it is observed overlap among administrations or
subsets. Direct or group constraints can transfer coordinates from a
defensible reference, but they do not manufacture empirical overlap.

This function applies the same preprocessing and key-resolution rules as
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
but returns a review object so constraints can be checked *before*
estimation. Running the review first helps avoid estimation failures
caused by misspecified or data-incompatible anchors. It does not inspect
source-fit readiness or establish that labels denote the same invariant
elements across runs. Those substantive checks remain the caller's
responsibility.

**Anchor types:**

- *Direct anchors* fix individual element measures to specific logit
  values (e.g., Rater R1 anchored at 0.35 logits).

- *Group anchors* constrain the mean of a set of elements to a target
  value, allowing individual elements to vary freely around that mean.
  The target requires an external justification such as a defensible
  equal-mean or known-scale assumption.

- When both types include the same element, both constraints are
  retained: the direct anchor fixes that element and the group
  constraint still fixes the declared group mean. Incompatible
  combinations are rejected by the constraint/estimability checks.

**Design checks** report whether each observed facet level has at least
`min_obs_per_element` weighted observations (default 30) and each score
category has at least `min_obs_per_category` (default 10). These
user-configurable counts are package screening recommendations, not
universal adequacy thresholds and not tests of connectedness or
invariance.

## Interpreting output

- `issue_counts`/`issues`: concrete data or specification problems.

- `facet_summary`: constraint coverage by facet.

- `design_checks`: whether anchor targets have enough observations.

- `recommendations`: action items before estimation.

## Typical workflow

1.  Build candidate anchors (e.g., with
    [`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md)).

2.  Run `review_mfrm_anchors(...)`.

3.  Resolve issues, then fit with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md),
[`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")

anchors <- data.frame(
  Facet = c("Rater", "Rater"),
  Level = c("R1", "R1"),
  Anchor = c(0, 0.1),
  stringsAsFactors = FALSE
)
review <- review_mfrm_anchors(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  anchors = anchors
)
review$issue_counts
#> # A tibble: 13 × 2
#>    Issue                            N
#>    <chr>                        <int>
#>  1 anchor_schema_mismatch           0
#>  2 group_anchor_schema_mismatch     0
#>  3 unknown_anchor_facets            0
#>  4 unknown_anchor_levels            2
#>  5 invalid_anchor_values            0
#>  6 duplicate_anchors                0
#>  7 unknown_group_facets             0
#>  8 unknown_group_levels             0
#>  9 invalid_group_labels             0
#> 10 duplicate_group_assignments      0
#> 11 missing_group_values             0
#> 12 group_value_conflicts            0
#> 13 overlap_anchor_group             0
summary(review)
#> mfrm Anchor Review Summary
#> 
#> Issue counts
#>                  Issue N
#>  unknown_anchor_levels 2
#> 
#> Facet summary
#>      Facet Levels AnchoredLevels GroupedLevels GroupCount ConstrainedLevels
#>     Person     48              0             0          0                 0
#>      Rater      4              0             0          0                 0
#>  Criterion      4              0             0          0                 0
#>  OverlapLevels FreeLevels Noncenter DummyFacet
#>              0         48      TRUE      FALSE
#>              0          4     FALSE      FALSE
#>              0          4     FALSE      FALSE
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
#>  - For linked analyses, keep Umean/Uscale from the source calibration so reporting origin and scaling stay consistent.
#>  - Current noncenter facet is 'Person'. Other facets are centered unless constrained by anchors/group anchors.
#> 
#> Notes
#>  - Anchor-review issues were detected. Review issue counts and recommendations.
p_review <- plot(review, draw = FALSE)
p_review$data$plot
#> [1] "issue_counts"
```
