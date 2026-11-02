# Review and normalize anchor/group-anchor tables

Review and normalize anchor/group-anchor tables

## Usage

``` r
review_mfrm_anchors(
  data,
  person = NULL,
  facets = NULL,
  score = NULL,
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
  centering_scope = c("facet", "remainder", "anchor_origin"),
  spec = NULL
)

# S3 method for class 'mfrm_anchor_review'
summary(object, digits = 3, top_n = 10, ...)

# S3 method for class 'mfrm_anchor_review'
plot(
  x,
  y = NULL,
  type = c("issue_counts", "facet_constraints", "level_observations"),
  main = NULL,
  palette = NULL,
  label_angle = 45,
  draw = TRUE,
  ...
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
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- dummy_facets:

  Facets to fix at zero.

- category_policy:

  Optional explicit category choice: `"collapse"` or `"preserve"`
  (`NULL` uses `keep_original`).

- repeated_ratings:

  Treatment of repeated Person-by-facet cells: `"review"` (default) or
  `"independent"`.

- centering_scope:

  Facet-centering convention: `"facet"` (default), `"remainder"`, or
  `"anchor_origin"` (see
  [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm_technical_details.md)).

- spec:

  Optional named `list` of shared model-specification settings (the same
  33-key `spec` accepted by
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/describe_mfrm_data.md),
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md),
  and
  [`export_mfrm_model()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/export_mfrm_model.md)).
  Explicit top-level arguments override matching entries in `spec`.

- object:

  Output from `review_mfrm_anchors()`.

- digits:

  Number of digits for numeric rounding.

- top_n:

  Maximum rows shown in issue previews.

- ...:

  Reserved for generic compatibility.

- x:

  Output from `review_mfrm_anchors()`.

- y:

  Reserved for generic compatibility.

- type:

  Plot type: `"issue_counts"`, `"facet_constraints"`, or
  `"level_observations"`.

- main:

  Optional title override.

- palette:

  Optional named colors.

- label_angle:

  X-axis label angle for bar plots.

- draw:

  If `TRUE`, print the `ggplot` figure on the active graphics device.

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

For [`summary()`](https://rdrr.io/r/base/summary.html): An object of
class `summary.mfrm_anchor_review`.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): A `ggplot`
object (invisibly), with underlying plot tables accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md).

## Details

This helper reviews computational constraints. A *direct anchor* fixes
an individual parameter to a supplied value. A *group anchor* constrains
the mean of declared elements to a supplied target. A *common-element
link* is different: it is observed overlap among administrations or
subsets. Direct or group constraints can transfer coordinates from a
defensible reference, but they do not manufacture empirical overlap.

This function applies the same preprocessing and key-resolution rules as
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md),
but returns a review object so constraints can be checked *before*
estimation. Running the review first helps avoid estimation failures
caused by misspecified or data-incompatible anchors. It does not inspect
source-fit readiness or establish that labels denote the same invariant
elements across runs. Those substantive checks remain the caller's
responsibility. This review has no estimation-method argument. A clean
table can still request an unsupported model combination: in particular,
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)
rejects Person direct/group anchors with MML. See the scale-constraint
section of
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)
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
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)
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

[`summary()`](https://rdrr.io/r/base/summary.html) method: Summarize an
anchor-review object

For [`summary()`](https://rdrr.io/r/base/summary.html): This summary
provides a compact pre-estimation review of anchor and group-anchor
specifications.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot an
anchor-review object

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): `ggplot2`
visualization helper for anchor-review outputs.

## Interpreting output

- `issue_counts`/`issues`: concrete data or specification problems.

- `facet_summary`: constraint coverage by facet. `FreeLevels` counts
  levels outside direct and group constraints, not free parameters. A
  group member may still vary, whereas centering removes a degree of
  freedom outside groups.

- `design_checks`: observation counts against the requested screening
  values.

- `recommendations`: action items before estimation.

For [`summary()`](https://rdrr.io/r/base/summary.html):

Recommended order:

- `issue_counts`: primary triage table (non-zero issues first).

- `facet_summary`: anchored/grouped/free-level balance by facet.

- `level_observation_summary` and `category_counts`: sparse-cell
  diagnostics.

- `recommendations`: concrete remediation suggestions.

If `issue_counts` is non-empty, treat anchor constraints as provisional
and resolve issues before final estimation.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html):

- `"issue_counts"`: volume of each issue class.

- `"facet_constraints"`: anchored/grouped/free mix by facet.

- `"level_observations"`: observation support across levels.

## Typical workflow

1.  Build candidate anchors (e.g., with
    [`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/make_anchor_table.md)).

2.  Run `review_mfrm_anchors(...)`.

3.  Resolve issues, then fit with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

For [`summary()`](https://rdrr.io/r/base/summary.html):

1.  Run `review_mfrm_anchors()` with intended anchors/group anchors.

2.  Review `summary(review)` and recommendations.

3.  Revise anchor tables, then call
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html):

1.  Run `review_mfrm_anchors()`.

2.  Start with `plot(review, type = "issue_counts")`.

3.  Inspect constraint and support plots before fitting.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md),
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/describe_mfrm_data.md),
[`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/make_anchor_table.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_linking_and_dff.md)

`review_mfrm_anchors()`,
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)

`review_mfrm_anchors()`,
[`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/make_anchor_table.md),
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("review_mfrm_anchors", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
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
review$issue_counts
review$recommendations         # Explains the selected centering convention.

# A duplicate is a separate input problem: resolve it before fitting.
duplicate <- rbind(anchors, transform(anchors, Anchor = 0.10))
problem <- review_mfrm_anchors(
  ratings, "Person", c("Rater", "Criterion"), "Score",
  anchors = duplicate
)
problem$issues$duplicate_anchors
# Normalization retains the last value; it does not decide which is correct.
} # }
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("summary.mfrm_anchor_review", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
review <- review_mfrm_anchors(toy, "Person", c("Rater", "Criterion"), "Score")
summary(review)
} # }
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot.mfrm_anchor_review", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
review <- review_mfrm_anchors(toy, "Person", c("Rater", "Criterion"), "Score")
p <- plot(review, draw = FALSE)
} # }
```
