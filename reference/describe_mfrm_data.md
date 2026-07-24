# Summarize MFRM input data (TAM-style descriptive snapshot)

Summarize MFRM input data (TAM-style descriptive snapshot)

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
  min_linking_persons = 2L
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
  categories such as `1, 2, 4, 5` on a 1-5 scale.

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

## Value

A list of class `mfrm_data_description` with:

- `overview`: one-row run-level summary

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

This function provides a compact descriptive bundle similar to the
pre-fit summaries commonly checked in TAM workflows: sample size, score
distribution, per-facet coverage, and linkage counts.
[`psych::describe()`](https://rdrr.io/pkg/psych/man/describe.html) is
used for numeric descriptives of score and weight.

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

- *Extreme scores*: persons or facet levels with all-minimum or
  all-maximum scores yield infinite logit estimates under JML; they are
  handled via Bayesian shrinkage under MML.

## Interpreting output

Recommended order:

- `overview`: confirms sample size, facet count, and category span.

- `missing_by_column`: identifies immediate data-quality risks.
  Understand why values are missing and whether the fitted missing-data
  handling matches the study design.

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

## Typical workflow

1.  Run `describe_mfrm_data()` on long-format input.

2.  Review `summary(ds)` and `plot(ds, ...)`.

3.  Resolve missingness/sparsity issues before
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
ds <- describe_mfrm_data(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score"
)
s_ds <- summary(ds)
s_ds$overview
#>   Observations TotalWeight Persons Facets Categories RatingMin RatingMax
#> 1          768         768      48      2          4         1         4
#>   RatingRangeSource RatingMinSource RatingMaxSource
#> 1          observed        observed        observed
p_ds <- plot(ds, draw = FALSE)
p_ds$data$plot
#> [1] "score_distribution"
```
