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
```

## Arguments

- x:

  An `mfrm_fit`, `mfrm_diagnostics`, `mfrm_precision_review`,
  `mfrm_fit_measures`, `mfrm_facets_fit_review`,
  `mfrm_person_fit_indices`, `mfrm_data_description`,
  `mfrm_reporting_checklist`, `mfrm_apa_outputs`,
  `mfrm_design_evaluation`, `mfrm_signal_detection`,
  `mfrm_recovery_simulation`, `mfrm_recovery_assessment`,
  `mfrm_population_prediction`, `mfrm_future_branch_active_branch`,
  `mfrm_facets_run`, `mfrm_bias`, `mfrm_anchor_review`,
  `mfrm_linking_review`, `mfrm_misfit_casebook`,
  `mfrm_model_choice_review`, `mfrm_weighting_review`,
  `mfrm_unit_prediction`, or `mfrm_plausible_values` object, one of
  their [`summary()`](https://rdrr.io/r/base/summary.html) outputs, or a
  `summary.mfrmr_recovery_validation` object from the packaged
  validation protocol.

- which:

  Optional character vector selecting a subset of named tables.

- appendix_preset:

  Optional appendix-oriented table preset: `"all"`, `"recommended"`,
  `"compact"`, `"methods"`, `"results"`, `"diagnostics"`, or
  `"reporting"`. Cannot be combined with `which`. Section-aware presets
  keep returned tables whose bundle catalog maps to the requested
  appendix section.

- include_empty:

  If `TRUE`, retain empty tables in the returned bundle.

- digits:

  Digits forwarded when
  [`summary()`](https://rdrr.io/r/base/summary.html) must be computed
  from a raw object.

- top_n:

  Row cap forwarded to compact
  [`summary()`](https://rdrr.io/r/base/summary.html) methods when `x` is
  a raw object.

- preview_chars:

  Character cap forwarded to
  [`summary.mfrm_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_apa_outputs.md)
  when `x` is a raw APA-output object.

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

## Details

This helper turns the package's compact summary objects into a
reproducible table bundle for manuscript drafting, appendix handoff, or
downstream formatting. It does not replace
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md);
instead, it provides a consistent bridge from
[`summary()`](https://rdrr.io/r/base/summary.html) to named `data.frame`
components that can later be rendered with
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
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

## Supported inputs

- [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  or `summary(fit)`

- [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  or `summary(diag)`

- [`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md)
  or `summary(precision_review)`

- [`fit_measures_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_measures_table.md)
  or `summary(fit_measures)`

- [`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md)
  or `summary(facets_fit_review)`

- [`compute_person_fit_indices()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_person_fit_indices.md)
  or `summary(person_fit)`

- [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
  or `summary(ds)`

- [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  or `summary(chk)`

- [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  or `summary(apa)`

- [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md)
  or `summary(sim_eval)`

- [`evaluate_mfrm_signal_detection()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_signal_detection.md)
  or `summary(sig_eval)`

- [`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md)
  or `summary(rec)`

- [`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md)
  or `summary(rec_assessment)`

- `summary(validation)` from `recovery-validation.R`

- [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
  or `summary(pred)`

- `planning_schema$future_branch_active_branch` or `summary(...)`

- [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
  or `summary(out)`

- [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  or `summary(bias)`

- [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)
  or `summary(review)`

- [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
  or `summary(review)`

- [`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md)
  or `summary(casebook)`

- [`build_model_choice_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_model_choice_review.md)
  or `summary(review)`

- [`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
  or `summary(review)`

- [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
  or `summary(pred_units)`

- [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)
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
  without treating them as recovery or release gates.

- recovery-validation summaries expose `condition_reporting_notes`
  before `condition_summary` so GPCM generator stress and sparse score
  support are not mistaken for recovery-metric failures.

- precision-review summaries expose `fit_separation_basis` so fit, ZSTD,
  separation/reliability/strata, and QC thresholds remain separate
  reporting surfaces rather than implicit validation gates.

- fit-measure and FACETS fit-review summaries expose df/ZSTD sensitivity
  tables under precision-review roles, keeping MnSq status, ZSTD
  standardization, and external FACETS matching distinct in appendix
  handoffs.

- latent-regression fit summaries expose `population_coding` in the
  methods appendix role so categorical levels, contrasts, and encoded
  columns can be documented with the coefficient table.

- model-choice-review summaries expose `comparison_table`,
  `model_roles`, `downstream_routes`, and `report_templates` so RSM/PCM
  versus bounded `GPCM` comparisons remain tied to their
  equal-weighting, sensitivity, and reporting-boundary roles.

## Typical workflow

1.  Build a compact object with `summary(...)`.

2.  Convert it with `build_summary_table_bundle(...)`.

3.  Use `bundle$tables[[...]]` directly, or hand a selected table to
    [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
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
    `condition_summary` when bounded `GPCM` generator stress is part of
    the plan.

## See also

[`summary()`](https://rdrr.io/r/base/summary.html),
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md),
[`build_model_choice_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_model_choice_review.md),
[`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", maxit = 30
)
bundle <- build_summary_table_bundle(fit)
bundle$table_index
summary(bundle)$role_summary
} # }

# Recovery-validation output can be converted to appendix-ready tables.
if (FALSE) { # \dontrun{
source(system.file("validation", "recovery-validation.R", package = "mfrmr"))
validation <- mfrmr_run_recovery_validation(
  case_ids = c("gpcm_slope_profile", "gpcm_high_dispersion_sparse"),
  quick = TRUE,
  seed = 20260525
)
validation_bundle <- build_summary_table_bundle(summary(validation))
validation_bundle$tables$reading_order
validation_bundle$tables$topline_release_decision
validation_bundle$tables$condition_reporting_notes
validation_bundle$tables$condition_summary
validation_bundle$tables$diagnostic_reporting_notes
} # }
```
