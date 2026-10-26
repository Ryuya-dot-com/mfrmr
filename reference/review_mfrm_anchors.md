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
  category_policy = NULL,
  repeated_ratings = c("review", "independent"),
  centering_scope = c("facet", "remainder", "anchor_origin")
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

  One facet to leave non-centered. Other facets use `centering_scope`,
  as in
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

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

- repeated_ratings:

  Treatment of repeated Person-by-facet cells. `"review"` (default)
  retains the duplicate-cell warning and ordinary MML/JML input-review
  state. Use `"independent"` only to declare that the rows are distinct,
  conditionally independent rating events under the specified model.
  Every row and its weight are retained; this argument does not
  aggregate scores, add a facet, change the likelihood or establish
  independence from the data. Other input, numerical and inference
  checks still apply. The declaration is saved in preparation notes,
  configuration and replay settings. Corrected JML already requires
  conditionally independent repeated ratings; the argument records that
  assumption explicitly there. It is not supported by the two-family
  GPCM route.

- centering_scope:

  `"facet"` (default) centers each declared facet across all its levels,
  including direct anchors and group totals. `"remainder"` reproduces
  the earlier convention that centers only levels outside direct and
  group constraints. For ordinary additive RSM/PCM JML,
  `"anchor_origin"` lets direct or group anchors replace centering on
  their facet; select an unanchored, active `noncenter_facet`. Other
  facets remain centered. This option excludes comparison-only fitting.
  None of these conventions changes the population model or category
  steps. Unsupported specialized routes reject an explicit setting. See
  **Anchors and scale constraints**.

## Value

A list of class `mfrm_anchor_review` with:

- `anchors`: cleaned direct constraints used by estimation

- `group_anchors`: cleaned group-mean constraints used by estimation

- `centering_scope`: the reviewed `"facet"`, `"remainder"` or
  `"anchor_origin"` convention

- `facet_summary`: counts of levels inside/outside declared constraints,
  `Centered` indicating the declared centering constraint, and
  `OriginBasis` describing how the facet's origin is set

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
responsibility. This review has no estimation-method argument. A clean
table can still request an unsupported model combination: in particular,
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
rejects Person direct/group anchors with MML. See the scale-constraint
section of
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
before using partial anchors.

**Anchor types:**

- *Direct anchors* fix individual element measures to specific logit
  values (e.g., Rater R01 anchored at 0.35 logits). Use internal
  coordinates, not values transformed for display with `Umean` or
  `Uscale`.

- *Group anchors* constrain the mean of a set of elements to a target
  value, allowing individual elements to vary freely around that mean.
  The target requires an external justification such as a defensible
  equal-mean or known-scale assumption. The mean is unweighted over
  declared levels, not over rating rows. `GroupValue` repeats one target
  per group. It is not a FACETS per-element contribution: values 0.2 and
  1.0 in a native two-member group translate to 0.6 for both rows. See
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  for group-origin centering and FACETS group 0 / extreme-exclusion
  differences.

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

- `facet_summary`: constraint coverage by facet. `FreeLevels` counts
  levels outside direct and group constraints, not free parameters. A
  group member may still vary, whereas centering removes a degree of
  freedom outside groups.

- `design_checks`: observation counts against the requested screening
  values.

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
ratings <- load_mfrmr_data("example_operational")
# Illustrative external value, not an estimate supplied with this dataset.
anchors <- data.frame(Facet = "Rater", Level = "R01", Anchor = 0.35)
review <- review_mfrm_anchors(
  data = ratings,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  anchors = anchors,
  rating_min = 1, rating_max = 4, category_policy = "preserve"
)
review$anchors                 # Check the retained value and matching ID.
#> # A tibble: 1 × 3
#>   Facet Level Anchor
#>   <chr> <chr>  <dbl>
#> 1 Rater R01     0.35
review$issue_counts
#> # A tibble: 13 × 2
#>    Issue                            N
#>    <chr>                        <int>
#>  1 anchor_schema_mismatch           0
#>  2 group_anchor_schema_mismatch     0
#>  3 unknown_anchor_facets            0
#>  4 unknown_anchor_levels            0
#>  5 invalid_anchor_values            0
#>  6 duplicate_anchors                0
#>  7 unknown_group_facets             0
#>  8 unknown_group_levels             0
#>  9 invalid_group_labels             0
#> 10 duplicate_group_assignments      0
#> 11 missing_group_values             0
#> 12 group_value_conflicts            0
#> 13 overlap_anchor_group             0
review$recommendations         # Explains the selected centering convention.
#> [1] "Package count screen: consider >= 5 directly anchored levels per facet. This does not verify cross-run identity or empirical connectedness. Low-count facets: Rater."                                                         
#> [2] "Package observation-count screen: about 30 observations per element are used for review. Low-observation facets: Person."                                                                                                     
#> [3] "Supply anchors in internal logit coordinates, not Umean/Uscale display units. Use compatible score coding, orientation and reporting scales across linked analyses."                                                          
#> [4] "Current noncenter facet is 'Person'. Other facets sum to zero across all levels, including anchors and group totals. The ungrouped remainder balances those contributions; a single remaining level is fixed by that balance."

# A duplicate is a separate input problem: resolve it before fitting.
duplicate <- rbind(anchors, transform(anchors, Anchor = 0.10))
problem <- review_mfrm_anchors(
  ratings, "Person", c("Rater", "Criterion"), "Score",
  anchors = duplicate
)
problem$issues$duplicate_anchors
#> # A tibble: 1 × 5
#>   Facet Level  Rows DistinctValues Values   
#>   <chr> <chr> <int>          <int> <chr>    
#> 1 Rater R01       2              2 0.35, 0.1
# Normalization retains the last value; it does not decide which is correct.
```
