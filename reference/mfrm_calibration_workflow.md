# Review and plot portable fixed-calibration scores

These methods provide the first review surface for the result returned
by `score_mfrm_calibration()`.
[`print()`](https://rdrr.io/r/base/print.html) gives a compact batch
disposition, [`summary()`](https://rdrr.io/r/base/summary.html) exposes
readable score and review tables, and
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) shows
conditional score uncertainty or numerical review quantities without
refitting a model.

Manage a fail-closed, versioned portable calibration lifecycle (`draft`
-\> `"validated"` -\> `"frozen"` -\> `"superseded"` / `"retired"`) for
scoring new response rows without training data or an executable fit
object. Only a `"frozen"` artifact can be passed to
`score_mfrm_calibration()`.

[`print()`](https://rdrr.io/r/base/print.html) gives a compact lifecycle
and scope overview. [`summary()`](https://rdrr.io/r/base/summary.html)
returns the same identifiers together with coordinate and anchor counts
and the structured validation refusals, if any. Both methods inspect the
stored artifact and do not refit a model or consult training responses.

## Usage

``` r
# S3 method for class 'mfrm_calibration_score'
summary(object, digits = 3L, ...)

# S3 method for class 'mfrm_calibration_score'
print(x, ...)

# S3 method for class 'summary.mfrm_calibration_score'
print(x, ...)

# S3 method for class 'mfrm_calibration_score'
plot(
  x,
  type = c("interval", "precision", "edge_mass"),
  top_n = 40L,
  sort_by = c("estimate", "sd", "person"),
  label_review = TRUE,
  main = NULL,
  draw = TRUE,
  preset = c("standard", "publication", "compact", "monochrome"),
  ...
)

extract_mfrm_calibration(
  fit,
  calibration_id = NULL,
  source_fit_id = NULL,
  created_at_utc = NULL,
  scoring_quad_points = 31L,
  quadrature_review = NULL
)

review_mfrm_calibration(calibration)

# S3 method for class 'mfrm_calibration'
update(object, status, record_id = NULL, at_utc = NULL, ...)

save_mfrm_calibration(calibration, file, overwrite = FALSE)

load_mfrm_calibration(file)

score_mfrm_calibration(
  calibration,
  new_data,
  person = NULL,
  facets = NULL,
  score = NULL,
  weight = NULL,
  interval_level = 0.95,
  missing_response = "error",
  event_id = NULL,
  adaptive_quad_points = NULL,
  scoring_prior = NULL,
  cut_scores = NULL
)

# S3 method for class 'mfrm_calibration'
summary(object, ...)

# S3 method for class 'mfrm_calibration'
print(x, ...)

# S3 method for class 'summary.mfrm_calibration'
print(x, ...)
```

## Arguments

- object:

  An `mfrm_calibration` returned by the portable calibration workflow.

- digits:

  Number of decimal places in the summary.

- ...:

  Reserved for generic compatibility.

- x:

  An `mfrm_calibration` returned by the portable calibration workflow.

- type:

  One of `"interval"`, `"precision"`, or `"edge_mass"`.

- top_n:

  Maximum number of scored Persons shown. Review rows are selected first
  when truncation is necessary. Use `Inf` to show all.

- sort_by:

  Selection priority after review rows: absolute estimate, posterior SD,
  or Person identifier.

- label_review:

  Whether review points are labelled in the precision and edge-mass
  views. Interval plots always label the displayed Persons.

- main:

  Optional plot title.

- draw:

  If `TRUE`, print the `ggplot` figure on the active graphics device.
  The `ggplot` object is returned invisibly in either case.

- preset:

  Visual preset: `"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`.

- fit:

  Eligible `mfrm_fit` from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- calibration_id:

  Optional identifiers and RFC3339 UTC timestamp.

- source_fit_id:

  Optional identifiers and RFC3339 UTC timestamp.

- created_at_utc:

  Optional identifiers and RFC3339 UTC timestamp.

- scoring_quad_points:

  Quadrature order (`>= 2`, default `31`) stored for artifact scoring
  (inherits fixed vs adaptive mode from `fit`).

- quadrature_review:

  Required `mfrm_quadrature_sensitivity` object for RSM/PCM MML (`fit`
  must be its highest-grid fit); optional for GPCM MML.

- calibration:

  An `mfrm_calibration` object (`object` in
  [`update()`](https://rdrr.io/r/stats/update.html),
  [`summary()`](https://rdrr.io/r/base/summary.html),
  [`print()`](https://rdrr.io/r/base/print.html), or
  `mfrm_calibration_score` in score methods).

- status:

  Target lifecycle state in
  [`update()`](https://rdrr.io/r/stats/update.html) (`"validated"`,
  `"frozen"`, `"superseded"`, `"retired"`), optional RFC3339 timestamp,
  and distinct terminal `record_id`.

- record_id:

  Target lifecycle state in
  [`update()`](https://rdrr.io/r/stats/update.html) (`"validated"`,
  `"frozen"`, `"superseded"`, `"retired"`), optional RFC3339 timestamp,
  and distinct terminal `record_id`.

- at_utc:

  Target lifecycle state in
  [`update()`](https://rdrr.io/r/stats/update.html) (`"validated"`,
  `"frozen"`, `"superseded"`, `"retired"`), optional RFC3339 timestamp,
  and distinct terminal `record_id`.

- file:

  `.rds` file path and replacement logical.

- overwrite:

  `.rds` file path and replacement logical.

- new_data:

  New-Person response `data.frame` and optional column/facet mappings
  (`event_id` distinguishes repeated events where supported).

- person:

  New-Person response `data.frame` and optional column/facet mappings
  (`event_id` distinguishes repeated events where supported).

- facets:

  New-Person response `data.frame` and optional column/facet mappings
  (`event_id` distinguishes repeated events where supported).

- score:

  New-Person response `data.frame` and optional column/facet mappings
  (`event_id` distinguishes repeated events where supported).

- weight:

  New-Person response `data.frame` and optional column/facet mappings
  (`event_id` distinguishes repeated events where supported).

- interval_level:

  Central posterior interval level in `(0, 1)` and missing-score policy
  (`"error"` or `"omit"`).

- missing_response:

  Central posterior interval level in `(0, 1)` and missing-score policy
  (`"error"` or `"omit"`).

- event_id:

  New-Person response `data.frame` and optional column/facet mappings
  (`event_id` distinguishes repeated events where supported).

- adaptive_quad_points:

  Optional adaptive reference orders (`>= 2` integers `>= 3`), shared
  normal prior override `list(mean = ..., sd = ...)`, and strictly
  increasing ability `cut_scores` (unit-weight continuous-posterior
  RSM/PCM only).

- scoring_prior:

  Optional adaptive reference orders (`>= 2` integers `>= 3`), shared
  normal prior override `list(mean = ..., sd = ...)`, and strictly
  increasing ability `cut_scores` (unit-weight continuous-posterior
  RSM/PCM only).

- cut_scores:

  Optional adaptive reference orders (`>= 2` integers `>= 3`), shared
  normal prior override `list(mean = ..., sd = ...)`, and strictly
  increasing ability `cut_scores` (unit-weight continuous-posterior
  RSM/PCM only).

## Value

[`print()`](https://rdrr.io/r/base/print.html) returns its input
invisibly. [`summary()`](https://rdrr.io/r/base/summary.html) returns a
`summary.mfrm_calibration_score` containing `overview`, `estimates`,
`review`, `row_review`, `settings`, and `notes`. When adaptive
integration was requested and scored rows exist, it also retains
unrounded `quadrature_review` and a compact `quadrature_overview`. When
cut scores were requested, `decisions` preserves every probability, cut
boundary and actual scoring prior without rounding; unavailable Persons
remain in that table with `NA` probabilities.
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) returns a
`ggplot` object (invisibly) whose underlying payload (accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md))
retains the selected plotting table, selection accounting, unplotted
Person dispositions, interpretation guidance, and plotting settings.

`extract_mfrm_calibration()`,
[`update()`](https://rdrr.io/r/stats/update.html), and
`load_mfrm_calibration()` return `mfrm_calibration`;
`review_mfrm_calibration()` returns a refusal `data.frame` (`0` rows
when valid); `save_mfrm_calibration()` invisibly returns the path;
`score_mfrm_calibration()` returns `mfrm_calibration_score`
(`estimates`, `decisions`, `quadrature_review`, row/Person
dispositions).

[`summary()`](https://rdrr.io/r/base/summary.html) returns a
`summary.mfrm_calibration`.
[`print()`](https://rdrr.io/r/base/print.html) returns its input
invisibly.

## Details

The default interval plot shows posterior EAP estimates and central
intervals. `type = "precision"` plots the number of valid response rows
against posterior SD. `type = "edge_mass"` compares posterior mass on
the two outer quadrature nodes with the recorded review threshold.
Review dispositions are highlighted in every view.

These are score-batch review displays, not calibration-fit diagnostics.
Posterior SDs and intervals are conditional on the frozen point
calibration and the actual scoring prior. They exclude
calibration-parameter uncertainty. For GPCM or an explicitly supplied
scoring prior, summaries and plot data retain both original and actual
prior values without rounding, the per-Person integration checks, and
(for GPCM) the source decision recorded at extraction. These records
describe conditional scoring, not a new evaluation of the training fit
or the suitability of its population for another cohort.
`summary(x)$settings$score_integration_review` compares the reported
EAP/SD with higher-order adaptive references. The separate
`quadrature_review` compares adaptive and fixed grids; for an adaptive
scorer, that fixed grid did not produce the reported scores. Printing
distinguishes the two checks. Persons with no valid responses have no
score coordinate and are retained in `summary(x)$review` and in the plot
payload's `unplotted_dispositions` component.

The summary object retains every returned score and review disposition.
Its estimates table preserves the available estimate and uncertainty
basis columns, calibration identifiers, scoring algorithm and requested
interval level when extracted or written to CSV. The interval level is
not rounded. Older score results recover these fields from their
recorded settings when re-summarized. Saved grid-based intervals retain
their original endpoints; printed results and interval plots explain
that their posterior mass can differ from the requested level. Its print
method shows at most ten rows from each table so routine console output
stays compact. Plots distinguish scored and review states by shape as
well as colour. `plot(x)` returns a `ggplot` object directly;
`as_ggplot(p)` and `as_ggplot(p, component = "data")` preserve the same
selected view, saved bounds, review symbols and unplotted dispositions
for both `ggplot` and legacy `mfrm_plot_data` objects. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
to extract other components. Changing the interval level requires an
explicit scoring call; conversion does not recompute intervals. Notes
remain in the returned object and are not automatically drawn.

**Supported formats and source checks.**

- **Format 1**: ordinary RSM/PCM MML (`N(0, 1)` prior, retaining anchors
  and two-way interactions; requires `quadrature_review` from
  [`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)
  with `fit` equal to the highest-grid fit).

- **Format 2**: one-family GPCM MML (unit weights, no
  anchors/interactions, intercept-only normal population; checks local
  likelihood, gradient, unregularized Hessian, and source/batch
  integration).

- **Format 3 / Format 4**: unit-weight unanchored RSM/PCM JML (format 3)
  and shared-owner GPCM JML (format 4, checking positive-definite joint
  curvature with reciprocal condition `> 1e-10`), scored under a
  post-hoc `N(0, 1)` reference prior.

- **Format 5**: experimental corrected GPCM JML
  (`jml_correction_order`), checking mean-equation residual `<= 1e-7`
  and Newton step `<= 1e-5`.

- **Formats 6 & 7**: experimental two-family GPCM MML (`N(0, 1)` prior,
  two slope owners, plus extended named
  `slope_reference`/`noncenter_facet` roles in format 7;
  `row_dispositions$ObservedContext` flags novel facet combinations).

New v2 artifacts invert the continuous posterior CDF for equal-tail
intervals while retaining stored quadrature for EAP and `SD`
(conditional on the frozen point calibration and prior, excluding
calibration/anchor uncertainty; Bock & Mislevy, 1982,
[doi:10.1177/014662168200600405](https://doi.org/10.1177/014662168200600405)
; Muraki, 1992,
[doi:10.1177/014662169201600206](https://doi.org/10.1177/014662169201600206)
). See `mfrmr_output_guide("calibration_capabilities")`.

A calibration artifact intentionally has no
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method. Its
coordinate table mixes facet, step, and interaction parameter roles, and
the artifact does not contain calibration-parameter uncertainty. Plot
returned score batches with mfrm_calibration_score_methods instead;
inspect `calibration$parameters$coordinates` when auditing stored point
coordinates.

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## See also

mfrm_calibration_workflow,
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md),
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md),
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md),
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md),
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md),
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md),
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
for conditional-decision interpretation

[`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md),
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)

mfrm_calibration_workflow, mfrm_calibration_score_methods

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("mfrm_calibration_score_methods", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
dat <- load_mfrmr_data("example_core")
ids <- unique(dat$Person)
training <- dat[dat$Person %in% ids[1:18], , drop = FALSE]
fit <- fit_mfrm(
  training, "Person", c("Rater", "Criterion"), "Score",
  model = "RSM", method = "MML", quad_points = 31
)
q_review <- mml_quadrature_sensitivity(
  fit, training, quad_points = c(31, 61), theta_points = 41
)
summary(q_review) # Inspect movement; these grids are not universal cutoffs.
fit <- q_review$fits$q61
calibration <- update(status = "frozen", 
  update(status = "validated", extract_mfrm_calibration(
    fit, quadrature_review = q_review, scoring_quad_points = 121
  ))
)
new_rows <- dat[dat$Person %in% ids[19:20], , drop = FALSE]
scores <- score_mfrm_calibration(calibration, new_rows,
  cut_scores = c(Basic = -0.5, Advanced = 0.8))
summary(scores)
apa_table(scores, which = "decisions")
build_summary_table_bundle(scores)$table_index
plot(scores, type = "interval", draw = FALSE)
plot(scores, type = "edge_mass", draw = FALSE)
} # }
```
