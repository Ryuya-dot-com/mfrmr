# Build a manuscript-oriented table bundle from `summary()` outputs

Build a manuscript-oriented table bundle from
[`summary()`](https://rdrr.io/r/base/summary.html) outputs

## Usage

``` r
build_summary_table_bundle(
  x,
  which = NULL,
  appendix_preset = NULL,
  include_empty = FALSE,
  digits = 3,
  top_n = 10,
  preview_chars = 160
)

# S3 method for class 'mfrm_summary_table_bundle'
summary(object, digits = 3, top_n = 8, ...)

# S3 method for class 'mfrm_summary_table_bundle'
plot(
  x,
  y = NULL,
  type = c("table_rows", "role_tables", "appendix_roles", "appendix_sections",
    "appendix_presets", "selection_handoff_presets", "selection_tables",
    "selection_handoff", "selection_handoff_bundles", "selection_handoff_roles",
    "selection_handoff_role_sections", "selection_bundles", "selection_roles",
    "selection_sections", "numeric_profile", "first_numeric"),
  which = NULL,
  selection_value = c("count", "fraction"),
  appendix_preset = c("recommended", "compact", "all", "methods", "results",
    "diagnostics", "reporting"),
  main = NULL,
  palette = NULL,
  label_angle = 45,
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  For `build_summary_table_bundle()`: An `mfrm_fit`, `mfrm_diagnostics`,
  `mfrm_precision_review`, `mfrm_fit_measures`,
  `mfrm_facets_fit_review`, `mfrm_person_fit_indices`,
  `mfrm_data_description`, `mfrm_reporting_checklist`,
  `mfrm_apa_outputs`, `mfrm_design_evaluation`, `mfrm_signal_detection`,
  `mfrm_recovery_simulation`, `mfrm_recovery_assessment`,
  `mfrm_population_prediction`, `mfrm_facets_run`, `mfrm_bias`,
  `mfrm_anchor_review`, `mfrm_linking_review`, `mfrm_misfit_casebook`,
  `mfrm_model_choice_review`, `mfrm_weighting_review`,
  `mfrm_calibration_score`, `mfrm_unit_prediction`, or
  `mfrm_plausible_values` object, one of their
  [`summary()`](https://rdrr.io/r/base/summary.html) outputs, or a
  compatible precomputed recovery-evidence summary.

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Output
  from `build_summary_table_bundle()`.

- which:

  For `build_summary_table_bundle()`: Optional character vector
  selecting a subset of named tables.

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Optional
  table selector used for numeric plot types.

- appendix_preset:

  For `build_summary_table_bundle()`: Optional appendix-oriented table
  preset: `"all"`, `"recommended"`, `"compact"`, `"methods"`,
  `"results"`, `"diagnostics"`, or `"reporting"`. Cannot be combined
  with `which`. Section-aware presets keep returned tables whose bundle
  catalog maps to the requested appendix section.

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Appendix
  preset used for `selection_*` plot types.

- include_empty:

  If `TRUE`, retain empty tables in the returned bundle.

- digits:

  For `build_summary_table_bundle()`: Digits forwarded when
  [`summary()`](https://rdrr.io/r/base/summary.html) must be computed
  from a raw object.

  For [`summary()`](https://rdrr.io/r/base/summary.html): Number of
  digits used for numeric summaries.

- top_n:

  For `build_summary_table_bundle()`: Row cap forwarded to compact
  [`summary()`](https://rdrr.io/r/base/summary.html) methods when `x` is
  a raw object.

  For [`summary()`](https://rdrr.io/r/base/summary.html): Maximum number
  of table-profile rows to keep.

- preview_chars:

  Character cap forwarded to
  [`summary.mfrm_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_apa_outputs.md)
  when `x` is a raw APA-output object.

- object:

  Output from `build_summary_table_bundle()`.

- ...:

  Reserved for generic compatibility.

- y:

  Reserved for generic compatibility.

- type:

  Plot type: `"table_rows"` for returned-table sizes, `"role_tables"`
  for returned-table counts by reporting role, `"appendix_roles"` for
  returned-table counts by reporting role under the bundle's
  appendix-routing contract, `"appendix_sections"` for returned-table
  counts by manuscript-facing appendix section, `"appendix_presets"` for
  conservative appendix-preset counts, `"selection_handoff_presets"` for
  workflow-only preset-level appendix handoff counts,
  `"selection_tables"` / `"selection_handoff"` /
  `"selection_handoff_bundles"` / `"selection_handoff_roles"` /
  `"selection_bundles"` / `"selection_roles"` / `"selection_sections"`
  for workflow-only appendix selection surfaces when present in the
  bundle, `"numeric_profile"` for column means from a selected numeric
  table, or `"first_numeric"` for the distribution of the first numeric
  column in a selected table.

- selection_value:

  For `selection_*` plot types, whether to plot exact counts (`"count"`)
  or the corresponding exact fraction (`"fraction"`) when that surface
  exposes one.

- main:

  Optional title override.

- palette:

  Optional named color overrides.

- label_angle:

  Axis-label rotation angle for bar-type plots.

- draw:

  If `TRUE`, draw using base graphics.

## Value

An object of class `mfrm_summary_table_bundle` with:

- `overview`

- `table_index`

- `plot_index`

- `tables`

- `appendix_preset`

- `notes`

- `source_class`

- `summary_class`

For [`summary()`](https://rdrr.io/r/base/summary.html): An object of
class `summary.mfrm_summary_table_bundle`.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object carrying its saved plot payload accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md).

## Details

This helper turns the package's compact summary objects into a
reproducible table bundle for manuscript drafting, appendix handoff, or
downstream formatting. It does not replace
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/apa_table.md);
instead, it provides a consistent bridge from
[`summary()`](https://rdrr.io/r/base/summary.html) to named `data.frame`
components that can later be rendered with
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/apa_table.md)
or exported directly.

The public entry point validates `x` and the summary-object contract up
front, so malformed summaries fail with a package-level message instead
of falling through to opaque downstream errors.

The function first normalizes `x` through the corresponding
[`summary()`](https://rdrr.io/r/base/summary.html) method when needed,
then records a `table_index` describing every available table and
returns the selected tables in `tables`. Optional appendix presets can
be applied at bundle-construction time when you want a conservative
manuscript-facing subset before plotting or export.

[`summary()`](https://rdrr.io/r/base/summary.html) method: Summarize a
summary-table bundle for manuscript QC

For [`summary()`](https://rdrr.io/r/base/summary.html): This summary is
designed to answer a manuscript-facing question: which reporting tables
are available, how large are they, which roles do they serve, and which
of them contain numeric content suitable for quick plotting or appendix
export.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot a
summary-table bundle for manuscript QC

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): This
helper keeps summary-bundle plotting conservative. It either visualizes
the bundle's own bundle-level indexes (`"table_rows"`, `"role_tables"`,
`"appendix_roles"`, `"appendix_sections"`, `"appendix_presets"`) or
routes a selected table through
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/apa_table.md)
and
[`plot.apa_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/apa_table.md)
for numeric QC.

## Supported inputs

- [`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_g_study.md),
  [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_d_study.md),
  [`mfrm_multivariate_d_compare()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_multivariate_d_compare.md),
  [`mfrm_residual_network()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_residual_network.md)
  or their
  [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_report.md)
  objects; supply saved intervals to
  [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_report.md)
  first. These routes retain all evidence tables, including signed
  estimates, settings and unavailable states, without `top_n`
  truncation.

- [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)
  or `summary(fit)`

- [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
  or `summary(diag)`

- [`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/precision_review_report.md)
  or `summary(precision_review)`

- [`fit_measures_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_measures_table.md)
  or `summary(fit_measures)`

- [`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/facets_fit_review.md)
  or `summary(facets_fit_review)`

- [`compute_person_fit_indices()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/compute_person_fit_indices.md)
  or `summary(person_fit)`

- [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/describe_mfrm_data.md)
  or `summary(ds)`

- [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/reporting_checklist.md)
  or `summary(chk)`

- [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_apa_outputs.md)
  or `summary(apa)`

- [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/evaluate_mfrm_design.md)
  or `summary(sim_eval)`

- [`evaluate_mfrm_signal_detection()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/evaluate_mfrm_signal_detection.md)
  or `summary(sig_eval)`

- [`simulate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/simulate_mfrm_recovery.md)
  or `summary(rec)`

- [`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/assess_mfrm_recovery.md)
  or `summary(rec_assessment)`

- a compatible precomputed recovery-evidence summary

- [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/predict_mfrm_population.md)
  or `summary(pred)`

- the `structural_design_review` component of a design or prediction
  summary

- [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/run_mfrm_facets.md)
  or `summary(out)`

- [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md)
  or `summary(bias)`

- [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/review_mfrm_anchors.md)
  or `summary(review)`

- [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_linking_review.md)
  or `summary(review)`

- [`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_misfit_casebook.md)
  or `summary(casebook)`

- [`build_model_choice_review()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_model_choice_review.md)
  or `summary(review)`

- [`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_weighting_review.md)
  or `summary(review)`

- [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/predict_mfrm_units.md)
  or `summary(pred_units)`

- [`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_calibration_workflow.md)
  or `summary(scores)`; includes all review dispositions and unrounded
  conditional decisions when requested

- [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/sample_mfrm_plausible_values.md)
  or `summary(pv)`

## Interpreting output

- `overview`: one-row metadata about the source summary and table
  counts.

- `table_index`: table names, dimensions, roles, and manuscript-oriented
  descriptions.

- `plot_index`: which returned tables contain numeric content and which
  bundle-level plot types can use them directly.

- `tables`: named `data.frame` objects ready for formatting or export.

- `appendix_preset`: active appendix subset mode (`"none"` when not
  used).

- `notes`: short guidance about omitted empty tables or source-level
  caveats.

- fit-level caveats use the `analysis_caveats` role; pre-fit data
  score-support caveats use the `score_category_caveats` role. Both
  roles are classified as diagnostics and stay in `recommended` appendix
  subsets.

- recovery-assessment and recovery-validation summaries expose
  `diagnostic_reporting_notes` before `diagnostic_review` or
  `diagnostic_oc_summary` so fit/separation caveats can be reported
  without treating them as direct evidence of parameter recovery.

- recovery-validation summaries expose `condition_reporting_notes`
  before `condition_summary` so GPCM generator stress and sparse score
  support are not mistaken for recovery-metric failures.

- precision-review summaries expose `fit_separation_basis` so fit, ZSTD,
  separation/reliability/strata, and QC thresholds remain distinct forms
  of evidence rather than interchangeable summaries.

- fit-measure and FACETS fit-review summaries expose df/ZSTD sensitivity
  tables under precision-review roles, keeping MnSq status, ZSTD
  standardization, and external FACETS matching distinct in appendix
  handoffs.

- latent-regression fit summaries expose `population_coding` in the
  methods appendix role so categorical levels, contrasts, and encoded
  columns can be documented with the coefficient table.

- model-choice-review summaries expose `comparison_table`,
  `comparison_warnings`, `model_roles`, `downstream_routes`, and
  `report_templates` so RSM/PCM versus `GPCM` comparisons remain tied to
  their same-basis limits, equal-weighting, sensitivity, and
  reporting-boundary roles.

For [`summary()`](https://rdrr.io/r/base/summary.html):

- `overview`: source class, returned-table count, note count, and
  whether a numeric table is available for plotting.

- `role_summary`: counts and total size by reporting role.

- `table_catalog`: complete returned-table registry with plot/export
  bridges.

- `table_profile`: table-level dimensions, numeric-column counts, and
  missing values for the largest returned tables.

- `plot_index`: which returned tables are plot-ready and which
  bundle-level numeric QC routes they support.

- `appendix_presets`: conservative `all` / `recommended` / `compact`
  plus section-aware `methods` / `results` / `diagnostics` / `reporting`
  appendix-export presets derived from table roles.

- `appendix_role_summary`: counts of returned tables by reporting role
  under the same conservative appendix routing used by the bundle
  catalog.

- `appendix_section_summary`: counts of returned tables by
  manuscript-facing appendix section.

- `selection_handoff_table_summary`: workflow-only table-level appendix
  handoff crosswalk when present in the bundle.

- `selection_handoff_preset_summary`: workflow-only appendix handoff
  overview aggregated at the preset level when present in the bundle.

- `selection_handoff_bundle_summary`: workflow-only appendix handoff
  overview aggregated at the bundle-by-section level when present in the
  bundle.

- `selection_handoff_role_summary`: workflow-only appendix handoff
  overview aggregated at the reporting-role level when present in the
  bundle.

- `selection_handoff_role_section_summary`: workflow-only appendix
  handoff overview aggregated at the reporting-role by appendix-section
  level when present in the bundle.

- `selection_summary`, `selection_table_summary`,
  `selection_table_preset_summary`, `selection_role_summary`,
  `selection_section_summary`, and `selection_catalog`: preset-filtered
  appendix selection surfaces when workflow-only handoff tables are
  embedded in the bundle.

- `reporting_map`: where to go next for plotting, APA formatting, and
  export.

- `notes`: carried forward source-level caveats from the originating
  summary.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html):

- `"table_rows"`: compares returned table sizes to show where reporting
  mass sits.

- `"role_tables"`: shows how many returned tables belong to each
  reporting role.

- `"appendix_roles"`: shows how returned tables contribute to
  conservative appendix routing by reporting role.

- `"appendix_sections"`: shows how returned tables are distributed
  across methods/results/diagnostics/reporting sections.

- `"appendix_presets"`: shows how many tables the current bundle
  contributes to the conservative appendix presets.

- `"selection_handoff_presets"`: shows plot-ready appendix handoff
  counts by preset for workflow-only appendix routing surfaces in the
  bundle.

- `"selection_tables"` / `"selection_handoff"` /
  `"selection_handoff_bundles"` / `"selection_handoff_roles"` /
  `"selection_handoff_role_sections"` / `"selection_bundles"` /
  `"selection_roles"` / `"selection_sections"`: show workflow-only
  appendix selection surfaces already materialized inside the bundle.

- `"numeric_profile"` / `"first_numeric"`: reuse the same numeric QC
  logic as
  [`plot.apa_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/apa_table.md)
  but start from a summary-table bundle.

## Typical workflow

1.  Build a compact object with `summary(...)`.

2.  Convert it with `build_summary_table_bundle(...)`.

3.  Use `bundle$tables[[...]]` directly, or hand a selected table to
    [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/apa_table.md)
    for formatted manuscript output.

4.  If you want a manuscript appendix subset up front, use a preset such
    as `appendix_preset = "recommended"`, `"compact"`, or
    `"diagnostics"`.

5.  For recovery-assessment or recovery-validation summaries, inspect
    `bundle$tables$reading_order` first when it is available.

6.  For recovery-assessment or recovery-validation summaries with
    retained diagnostics, read `diagnostic_reporting_notes` before the
    raw `diagnostic_review` or `diagnostic_oc_summary`. Read
    `condition_reporting_notes` before `condition_review` or
    `condition_summary` when `GPCM` generator stress is part of the
    plan.

For [`summary()`](https://rdrr.io/r/base/summary.html):

1.  Build `bundle <- build_summary_table_bundle(summary(...))`.

2.  Run `summary(bundle)` to see reporting coverage.

3.  Use `plot(bundle, type = "table_rows")` or
    `plot(bundle, type = "numeric_profile", which = ...)` for quick QC.

## See also

[`base::summary()`](https://rdrr.io/r/base/summary.html),
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/apa_table.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/reporting_checklist.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_apa_outputs.md),
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/compare_mfrm.md),
[`build_model_choice_review()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_model_choice_review.md),
[`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_weighting_review.md)

`build_summary_table_bundle()`,
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/apa_table.md),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html)

`build_summary_table_bundle()`,
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/apa_table.md),
[`plot.apa_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/apa_table.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("build_summary_table_bundle", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
bundle <- build_summary_table_bundle(fit)
bundle$table_index
summary(bundle)$role_summary

} # }
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("summary.mfrm_summary_table_bundle", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
bundle <- build_summary_table_bundle(fit)
summary(bundle)
} # }
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot.mfrm_summary_table_bundle", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
bundle <- build_summary_table_bundle(fit)
plot(bundle, draw = FALSE)
plot(bundle, type = "numeric_profile", which = "facet_overview", draw = FALSE)
} # }
```
