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
  agreement_top_n = NULL
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
  (`c("99", "999", "-1", "N", "NA", "n/a", ".", "")`); supply a
  character vector for a custom code set. Replacement counts are
  returned in the `missing_recoding` component when supported by the
  calling helper. See
  [`recode_missing_codes()`](https://ryuya-dot-com.github.io/mfrmr/reference/recode_missing_codes.md)
  for the standalone version.

- include_person_facet:

  If `TRUE`, include person-level rows in `facet_level_summary`.

- include_agreement:

  If `TRUE`, include an observed-score inter-rater agreement bundle
  (summary/pairs/settings) in the output.

- rater_facet:

  Optional rater facet name used for agreement summaries. If `NULL`,
  inferred from facet names.

- context_facets:

  Optional facets used to define matched contexts for agreement. If
  `NULL`, all remaining facets (including `Person`) are used.

- agreement_top_n:

  Optional maximum number of agreement pair rows.

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
  non-person facets (named list keyed `"facetA__facetB"`); used by
  `summary(ds)$design_links` to flag sparse / disconnected facet-pair
  coverage

- `linkage_summary`: person-facet connectivity diagnostics

- `agreement`: observed-score inter-rater agreement bundle

- `row_retention`: row counts before and after preparation filters

- `preparation_notes`: structured notes for row drops, ID trimming, and
  design conditions detected during preparation

- `score_support`: minimal prepared score-support metadata used by
  `summary(ds)$caveats`

## Details

This function provides a compact descriptive bundle similar to the
pre-fit summaries commonly checked in TAM workflows: sample size, score
distribution, per-facet coverage, and linkage counts.
[`psych::describe()`](https://rdrr.io/pkg/psych/man/describe.html) is
used for numeric descriptives of score and weight.

**Key data-quality checks to perform before fitting:**

- *Sparse categories*: any score category with fewer than 10 weighted
  observations may produce unstable threshold estimates (Linacre, 2002).
  Consider collapsing adjacent categories.

- *Unlinked elements*: if a facet level has zero overlap with one or
  more levels of another facet, the design is disconnected and
  parameters cannot be placed on a common scale. Check `linkage_summary`
  for low connectivity.

- *Extreme scores*: persons or facet levels with all-minimum or
  all-maximum scores yield infinite logit estimates under JML; they are
  handled via Bayesian shrinkage under MML.

## Interpreting output

Recommended order:

- `overview`: confirms sample size, facet count, and category span. The
  `MinWeightedN` column shows the smallest weighted observation count
  across all facet levels; values below 30 may lead to unstable
  parameter estimates.

- `missing_by_column`: identifies immediate data-quality risks. Any
  non-zero count warrants investigation before fitting.

- `score_distribution`: checks sparse/unused score categories. Balanced
  usage across categories is ideal; heavily skewed distributions may
  compress the measurement range.

- `facet_level_summary` and `linkage_summary`: checks per-level support
  and person-facet connectivity. Low linkage ratios indicate sparse or
  disconnected design blocks.

- `agreement`: optional observed inter-rater consistency summary (exact
  agreement, correlation, mean differences per rater pair).

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
