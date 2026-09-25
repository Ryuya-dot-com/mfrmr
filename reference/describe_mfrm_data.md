# Check rating data before fitting an MFRM

Inspect how many rating rows can be used, how often each score category
occurs, and whether facet levels connect through shared persons. This
function prepares descriptive checks; it does not fit a model or change
the data object supplied by the caller. Each row should represent one
rating, and `person`, `facets`, and `score` name its columns.

## Usage

``` r
describe_mfrm_data(
  data,
  person,
  facets,
  score,
  weight = NULL,
  rating_min = NULL,
  rating_max = NULL,
  keep_original = FALSE,
  missing_codes = NULL,
  include_person_facet = FALSE,
  include_agreement = TRUE,
  rater_facet = NULL,
  context_facets = NULL,
  agreement_top_n = NULL,
  expected_design = NULL,
  min_linking_persons = 2L,
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

- weight:

  Optional weight/frequency column name.

- rating_min:

  Optional minimum category value. Supply with `rating_max` to retain
  unused boundary categories in the intended score support.

- rating_max:

  Optional maximum category value. Supply with `rating_min` to retain
  unused boundary categories in the intended score support.

- keep_original:

  Keep original category values. Use this with `rating_min` /
  `rating_max` when the intended scale has unused intermediate
  categories such as `1, 2, 4, 5` on a 1-5 scale. New code can instead
  use `category_policy = "preserve"`.

- missing_codes:

  Optional. `NULL` (default) is a no-op; `TRUE` or `"default"` activates
  the FACETS / SPSS / SAS convention
  (`c("99", "999", "-1", "N", "NA", "n/a", ".", "")`) for the score
  column while preserving person/facet identifiers; supply a character
  vector to apply a custom code set across all model columns.
  Replacement counts are returned in the `missing_recoding` component
  when supported by the calling helper. See
  [`recode_missing_codes()`](https://ryuya-dot-com.github.io/mfrmr/reference/recode_missing_codes.md)
  for the standalone version.

- include_person_facet:

  If `TRUE`, include person-level rows in `facet_level_summary`.

- include_agreement:

  If `TRUE`, include an observed-score agreement bundle
  (summary/pairs/settings) for a selected non-person facet.

- rater_facet:

  Optional facet name used to identify repeated scorers for agreement
  summaries. If `NULL`, a rater-like name such as `Rater`, `Judge`, or
  `Scorer` is inferred. No agreement analysis is run when such a name is
  absent; set this argument explicitly only when another facet genuinely
  represents repeated scorers.

- context_facets:

  Optional facets used to define matched contexts for agreement. If
  `NULL`, all remaining facets (including `Person`) are used.

- agreement_top_n:

  Optional maximum number of agreement pair rows.

- expected_design:

  Optional data frame declaring the planned assignment roster. It must
  contain the columns named by `person` and `facets`, with one row per
  planned Person x facet cell. Extra columns are ignored. When supplied,
  observed cells are compared with the roster so planned omissions can
  be distinguished from cells that were never assigned.

- min_linking_persons:

  Positive integer used as a descriptive sparse-link flag. A facet level
  observed for fewer than this many distinct persons is counted in
  `linkage_summary$SparseLevels`. This is a review threshold, not a
  model-acceptance rule.

- category_policy:

  Optional explicit category choice: `"collapse"` maps gaps in the
  observed categories to consecutive scores; `"preserve"` keeps the
  intended ladder, declared with `rating_min` and `rating_max`. This
  changes the fitted category steps, not just labels. `NULL` (default)
  uses `keep_original`, whose default is `FALSE` (`"collapse"`).
  Supplying both choices is allowed only when they agree. Preservation
  does not estimate unsupported steps: fitting stops if a retained
  internal category has no observations. Use the same policy in
  `describe_mfrm_data()` and
  [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md).

## Value

A list of class `mfrm_data_description` with:

- `overview`: one-row run-level summary including `CategoryPolicy` and
  `ScoreRecoded`. The former records the selected category handling; the
  latter indicates whether original score values actually changed. A
  `"collapse"` policy can leave a contiguous scale unchanged. Inspect
  `score_support$score_map` for the mapping.

- `missing_by_column`: missing counts in selected input columns

- `missing_rate_summary`: per-column missingness rate summary (one row
  per input column, with raw and proportion-of-N columns)

- `score_descriptives`: output from
  [`psych::describe()`](https://rdrr.io/pkg/psych/man/describe.html) for
  score

- `weight_descriptives`: output from
  [`psych::describe()`](https://rdrr.io/pkg/psych/man/describe.html) for
  weight

- `score_distribution`: weighted and raw score frequencies over the
  prepared score support. Unused boundary categories are retained when
  the rating range was supplied explicitly; unused intermediate
  categories require `keep_original = TRUE`.

- `facet_level_summary`: per-level usage and score summaries

- `facet_crosstabs`: pairwise observation-count crosstabs between
  non-person facets (named list keyed `"facetA__facetB"`) for optional
  downstream coverage displays

- `linkage_summary`: person-facet connectivity diagnostics

- `structural_missingness`: declared-design comparison bundle containing
  a one-row summary, missing expected cells, unexpected observed cells,
  per-facet level coverage, and settings

- `design_connectivity`: component counts for each observed Person-facet
  graph and, when declared, each expected Person-facet graph

- `design_components`: component-level counts and facet-level labels;
  person labels are included only when `include_person_facet = TRUE`

- `duplicate_cell_summary`: counts of duplicate Person x facet cells

- `duplicate_cell_detail`: duplicate-cell keys and row counts

- `agreement`: observed-score agreement bundle for the selected scorer
  facet

- `row_retention`: row counts before and after preparation filters

- `preparation_notes`: structured notes for row drops, ID trimming, and
  design conditions detected during preparation

- `missing_recoding`: per-column counts of declared missing-code values
  replaced with `NA` before row filtering

- `score_support`: minimal prepared score-support metadata used by
  `summary(ds)$caveats`

## Details

Set `rating_min` and `rating_max` from the rubric, including categories
nobody received. Use `keep_original = TRUE` to preserve its category
structure in the review. Numeric descriptives of score and weight use
[`psych::describe()`](https://rdrr.io/pkg/psych/man/describe.html).

**Key data-quality checks to perform before fitting:**

- *Sparse categories*: review categories with little weighted support
  because their threshold estimates may be imprecise. Do not collapse
  categories solely from a package warning; also consider the rubric,
  intended score interpretation, and category diagnostics after fitting.

- *Unlinked elements*: inspect `design_connectivity` for the observed
  Person-facet graph. More than one component means that the levels of
  that facet are not connected through shared persons. This
  facet-specific check is conservative and does not by itself prove full
  model identification.

- *Extreme scores*: MML uses a person distribution to obtain posterior
  person scores, including for persons with all-minimum or all-maximum
  scores. Non-person facets remain fixed effects: an extreme rater or
  criterion is not given a prior or automatically shrunk by
  choosing MML. Review the fitted boundary and precision evidence before
  interpretation.

## Interpreting output

Recommended order:

- `overview`: confirms retained ratings (`Observations`), persons,
  facets, and category span. Use `row_retention` to compare input and
  retained `Rows`; `DroppedRows` counts exclusions during preparation.

- `missing_by_column`: counts `NA` values in the input columns. A
  missing score or required identifier excludes that rating row, not
  automatically the person's other ratings. The package does not fill
  missing ratings. When `missing_codes` is supplied, these counts still
  describe the original input; inspect `missing_recoding` and
  `preparation_notes` as well.

- `structural_missingness`: compares observed rating cells with
  `expected_design`, when supplied. Without a declared roster,
  structural missingness is reported as not assessed rather than assumed
  to be zero.

- `score_distribution`: checks sparse/unused score categories. Skew can
  be substantively expected, but weakly supported or unused categories
  need explicit interpretation.

- `facet_level_summary` and `linkage_summary`: checks per-level support,
  shared-person counts, and sparse levels. Use `design_connectivity` for
  the separate graph-component result.

- `agreement`: optional observed agreement summary for the selected
  scorer facet (exact agreement, correlation, and mean differences per
  pair).

`data_review <- describe_mfrm_data(...)` saves all these checks.
`review <- summary(data_review)` provides a compact view; its
missingness table is named `review$missing`, while the original full
table is `data_review$missing_by_column`. Summary previews use
`top_n = 10` by default. Use the original tables to inspect all rows or
categories.

## If the input needs attention

- **Column name not found:** run `names(ratings)` and match spelling,
  spaces, and case in `person`, `facets`, and `score`.

- **Unexpected row loss:** inspect `row_retention`, `missing_by_column`,
  and `preparation_notes`. Resolve unintended missing IDs and invalid
  score text in the input data. For documented score markers such as
  `99` or `.`, use
  [`recode_missing_codes()`](https://ryuya-dot-com.github.io/mfrmr/reference/recode_missing_codes.md)
  with explicit `columns` and `codes`.

- **Repeated person-by-facet cells:** inspect `duplicate_cell_detail`.
  Correct accidental duplicates; include a task or occasion facet when
  ratings represent distinct events in the design.

- **Unused category or disconnected design:** inspect
  `score_distribution` and `design_connectivity`. Review the rubric and
  assignments before changing the model. A retained internal zero-count
  category stops fitting; extra optimizer iterations cannot supply the
  missing category information.

After editing or recoding ratings, rerun this review on the corrected
data and pass that same data to
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
using the same columns, score bounds, and `keep_original` setting. If
you use `missing_codes` within the review instead of recoding first,
supply the same option to the fit: reviewing does not modify the
original data. For CSV import, column mapping, and a complete worked
example, see
[`vignette("mfrmr-workflow", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-workflow.md).

## Typical workflow

1.  Run `data_review <- describe_mfrm_data(...)` on the rating data.

2.  Inspect row retention, category counts, and design connectivity.

3.  Correct input issues, repeat the review, and fit the reviewed data
    with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`summary.mfrm_data_description()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_data_description.md),
[`recode_missing_codes()`](https://ryuya-dot-com.github.io/mfrmr/reference/recode_missing_codes.md),
[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md),
[`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)

## Examples

``` r
library(mfrmr)
toy <- load_mfrmr_data("example_operational")
head(toy)
#>                Study Person Rater    Criterion Score Group
#> 1 OperationalExample   P001   R01     Language     4     A
#> 2 OperationalExample   P001   R01 Organization     2     A
#> 3 OperationalExample   P001   R02      Content     4     A
#> 4 OperationalExample   P001   R02     Language     3     A
#> 5 OperationalExample   P001   R02 Organization     2     A
#> 6 OperationalExample   P002   R01      Content     3     A

# Check the data before fitting; the intended score categories are 1 to 4
data_review <- describe_mfrm_data(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  rating_min = 1,
  rating_max = 4,
  category_policy = "preserve"
)
data_review$row_retention       # Input and retained rows; check DroppedRows
#>                             Stage Rows DroppedRows
#> 1          input_selected_columns  282           0
#> 2 after_missing_and_weight_filter  282           0
#>                            DroppedReason
#> 1                                       
#> 2 missing values or non-positive weights
data_review$missing_by_column   # Missing input values in each model column
#> # A tibble: 4 × 2
#>   Column    Missing
#>   <chr>       <int>
#> 1 Person          0
#> 2 Rater           0
#> 3 Criterion       0
#> 4 Score           0
data_review$score_distribution  # RawN is the number of ratings per category
#> # A tibble: 4 × 4
#>   Score  RawN WeightedN Percent
#>   <int> <int>     <dbl>   <dbl>
#> 1     1    62        62    22.0
#> 2     2    96        96    34.0
#> 3     3    78        78    27.7
#> 4     4    46        46    16.3
data_review$design_connectivity # Components = 1 means connected for that facet
#>      Basis     Facet PersonNodes FacetLevelNodes Edges Components
#> 1 observed     Rater          48               6    96          1
#> 2 observed Criterion          48               3   144          1
#>   LargestComponentPersons LargestComponentLevels LargestComponentPercent
#> 1                      48                      6                     100
#> 2                      48                      3                     100
#>   Connected
#> 1      TRUE
#> 2      TRUE
# Here all 282 rows are retained, and all four categories have observations

# Save a compact summary when you want the overview and review notes
review <- summary(data_review)
review$overview
#>   Observations TotalWeight Persons Facets Categories RatingMin RatingMax
#> 1          282         282      48      2          4         1         4
#>   RatingRangeSource RatingMinSource RatingMaxSource CategoryPolicy ScoreRecoded
#> 1          declared        declared        declared       preserve        FALSE
review$notes
#> [1] "No missing values were detected in selected input columns."                                                                                                  
#> [2] "Structural missingness was not assessed because `expected_design` was not supplied. Absent rows cannot be distinguished from cells that were never assigned."
# For the next fit, use data = toy; data_review is a set of checks, not ratings
```
