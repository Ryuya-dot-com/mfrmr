# Review and plot portable fixed-calibration scores

These methods provide the first review surface for the result returned
by
[`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_calibration_workflow.md).
[`print()`](https://rdrr.io/r/base/print.html) gives a compact batch
disposition, [`summary()`](https://rdrr.io/r/base/summary.html) exposes
readable score and review tables, and
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) shows
conditional score uncertainty or numerical review quantities without
refitting a model.

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
```

## Arguments

- object, x:

  An `mfrm_calibration_score` returned by
  [`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_calibration_workflow.md).

- digits:

  Number of decimal places in the summary.

- ...:

  Reserved for generic compatibility.

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
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md))
retains the selected plotting table, selection accounting, unplotted
Person dispositions, interpretation guidance, and plotting settings.

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
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
to extract other components. Changing the interval level requires an
explicit scoring call; conversion does not recompute intervals. Notes
remain in the returned object and are not automatically drawn.

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## See also

[mfrm_calibration_workflow](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_calibration_workflow.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_output_guide.md),
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md),
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data_components.md),
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md),
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/apa_table.md),
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_summary_table_bundle.md),
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/export_summary_appendix.md),
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/predict_mfrm_units.md)
for conditional-decision interpretation

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
