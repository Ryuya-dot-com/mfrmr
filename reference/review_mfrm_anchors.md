# Review and normalize anchor/group-anchor tables

Review and normalize anchor/group-anchor tables

Build a candidate direct-anchor table from fitted estimates

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

make_anchor_table(
  fit,
  facets = NULL,
  include_person = FALSE,
  digits = NULL,
  readiness_policy = c("error", "review")
)
```

## Arguments

- data:

  A data.frame in long format (one row per rating event).

- person:

  Column name for person IDs.

- facets:

  Optional subset of facets to include.

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

  Optional explicit category choice: `"collapse"` or `"preserve"`
  (`NULL` uses `keep_original`).

- repeated_ratings:

  Treatment of repeated Person-by-facet cells: `"review"` (default) or
  `"independent"`. The latter declares distinct, conditionally
  independent rating events; it does not establish independence from the
  data or increase the number of independent Persons. See
  [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md)
  for estimator-specific restrictions.

- centering_scope:

  Facet-centering convention: `"facet"` (default), `"remainder"`, or
  `"anchor_origin"` (see
  [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md)).

- spec:

  Optional named `list` of shared model-specification settings (the same
  model-specification `spec` accepted by
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md),
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
  and
  [`export_mfrm_model()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_model.md)).
  Explicit top-level arguments override matching entries in `spec`.

- object:

  Output from `review_mfrm_anchors()`.

- digits:

  `NULL` (default) preserves the fitted numeric values. A nonnegative
  integer explicitly rounds them for display or external use.

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

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- include_person:

  Include person estimates as candidate anchors. Use only when cross-run
  person identity and the intended longitudinal constraint are
  substantively justified. Fixed Person values are supported only by a
  receiving JML fit; MML rejects Person anchors.

- readiness_policy:

  How a source fit that is not inference-ready is handled. `"error"`
  (default) refuses anchor export or reuse. `"review"` permits explicit
  review-only extraction; those values must not be used as operational
  anchors.

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
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).

A data.frame with `Facet`, `Level`, and `Anchor`.

## Details

Check candidate direct/group constraints against the receiving data
before estimation, using the preprocessing and key-resolution rules of
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
Such constraints can transfer coordinates from a defensible reference;
they do not create the observed overlap required for a common-element
link. The review does not verify source-fit readiness or invariant
cross-run meaning of element labels.

There is no estimation-method argument: even a clean review can request
an unsupported model combination. In particular, MML rejects Person
direct/group anchors. See the scale-constraint section of
[fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md)
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

[`summary()`](https://rdrr.io/r/base/summary.html) method: Summarize an
anchor-review object

For [`summary()`](https://rdrr.io/r/base/summary.html): Compact
constraint coverage, support counts and recommendations; follow
"Reviewing constraints before fitting" for reading order.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot an
anchor-review object

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Start with
`"issue_counts"` for counts by issue class. `"facet_constraints"` shows
anchored, grouped and free levels; `"level_observations"` shows
observation support. Interpret these alongside the constraint
definitions and screening limits above, before fitting.

Convert fitted estimates to candidate direct constraints in the
`Facet`/`Level`/`Anchor` schema. `Anchor` is the internal, untransformed
location; fixing it in a new fit does not propagate source uncertainty.
Thresholds, GPCM slopes, model settings and source SEs are excluded; use
[`extract_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
for a complete saved calibration.

Export is refused unless the source fit is inference-ready under the
current contract. `readiness_policy = "review"` allows inspection, not
approval for reuse. Check cross-run element identity, substantive
invariance and observed connectedness separately, then use
`review_mfrm_anchors()` on the receiving data. That review checks
constraints and data support, not source-fit quality or invariance.

Keep `digits = NULL` for recalibration. Rounding individual anchors can
break their joint sum or group-mean constraint, even at six decimal
places. Explicitly rounded values are different constraints and must be
reviewed before reuse; the fitter does not silently recenter supplied
anchors.

## Reviewing constraints before fitting

Start with `summary(review)$issue_counts`, inspect the full `issues` and
`recommendations`, and resolve their stated problems before fitting.
`facet_summary` describes constraint coverage: `FreeLevels` counts
levels outside direct and group constraints, not free parameters. Group
members can vary, while centering removes a degree of freedom outside
groups. `design_checks` records support checks; the summary's
`level_observation_summary` and `category_counts` show support relative
to the requested screening counts.

Build candidates with `make_anchor_table()` when appropriate, revise
them after review, then pass the intended constraints to
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

## Using the candidates

`Facet` names the facet, `Level` its element, and `Anchor` the fixed
value (rounded only when `digits` is supplied). After reviewing the
reference fit and receiving data, pass selected rows to
`fit_mfrm(..., anchors = ...)`.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md),
`make_anchor_table()`,
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)

`review_mfrm_anchors()`,
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)

`review_mfrm_anchors()`, `make_anchor_table()`,
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
`review_mfrm_anchors()`

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
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
# Optional workflow; run the example explicitly as shown below.
# example("summary.mfrm_anchor_review", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
review <- review_mfrm_anchors(toy, "Person", c("Rater", "Criterion"), "Score")
summary(review)
} # }
# Optional workflow; run the example explicitly as shown below.
# example("plot.mfrm_anchor_review", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
review <- review_mfrm_anchors(toy, "Person", c("Rater", "Criterion"), "Score")
p <- plot(review, draw = FALSE)
} # }
# Optional workflow; run the example explicitly as shown below.
# example("make_anchor_table", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
ratings <- load_mfrmr_data("example_operational")
fit <- fit_mfrm(
  ratings, "Person", c("Rater", "Criterion"), "Score",
  method = "MML", rating_min = 1, rating_max = 4,
  category_policy = "preserve"
)
# Select a facet deliberately; matching labels alone do not prove invariance.
anchors_tbl <- make_anchor_table(fit, facets = "Rater")
anchors_tbl
} # }
```
