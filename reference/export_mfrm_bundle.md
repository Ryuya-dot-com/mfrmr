# Build a reproducibility manifest for an MFRM analysis

Build a reproducibility manifest for an MFRM analysis

Build a package-native replay script for an MFRM analysis

Export a fit-level analysis archive

## Usage

``` r
build_mfrm_manifest(
  fit,
  diagnostics = NULL,
  bias_results = NULL,
  population_prediction = NULL,
  unit_prediction = NULL,
  plausible_values = NULL,
  include_person_anchors = FALSE,
  data = NULL
)

build_mfrm_replay_script(
  fit,
  diagnostics = NULL,
  bias_results = NULL,
  population_prediction = NULL,
  unit_prediction = NULL,
  plausible_values = NULL,
  data_file = "your_data.csv",
  fit_person_data_file = NULL,
  script_mode = c("auto", "fit", "facets"),
  include_bundle = FALSE,
  bundle_dir = "analysis_bundle",
  bundle_prefix = "mfrmr_replay"
)

export_mfrm_bundle(
  fit,
  diagnostics = NULL,
  bias_results = NULL,
  population_prediction = NULL,
  unit_prediction = NULL,
  plausible_values = NULL,
  summary_tables = NULL,
  output_dir = ".",
  prefix = "mfrmr_bundle",
  include = c("core_tables", "checklist", "dashboard", "apa", "anchors", "manifest",
    "visual_summaries", "predictions", "summary_tables", "script", "html"),
  facet = NULL,
  include_person_anchors = FALSE,
  overwrite = FALSE,
  acknowledge_sensitive = FALSE,
  zip_bundle = FALSE,
  zip_name = NULL,
  data = NULL
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  or
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  When `NULL`, diagnostics are reused from
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
  when available, otherwise computed with `residual_pca = "none"` (or
  `"both"` when visual summaries are requested). Must match this fitted
  analysis; see
  [mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)
  for migration of saved diagnostics.

- bias_results:

  Optional output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  or a named list of bias bundles.

- population_prediction:

  Optional output from
  [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md).

- unit_prediction:

  Optional output from
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md).

- plausible_values:

  Optional output from
  [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md).

- include_person_anchors:

  If `TRUE`, include person measures in the exported anchor table.

- data:

  Optional original analysis data frame. When supplied,
  `export_mfrm_bundle()` co-locates a CSV copy of the data alongside the
  replay script and updates the script's
  [`read.csv()`](https://rdrr.io/r/utils/read.table.html) path to point
  at it. The manifest's `input_summary` row for `data` describes the
  user's untouched input structure; it is not a byte-level equality
  claim about the CSV replay representation. Default `NULL` falls back
  to the legacy `your_data.csv` placeholder path.

- data_file:

  Path to the analysis data file used in the generated script.

- fit_person_data_file:

  Optional CSV filename to read for the fit-level latent-regression
  replay person table. When `NULL`, the replay script embeds that table
  inline. `export_mfrm_bundle()` uses this to keep replay scripts
  portable while avoiding large inline literals.

- script_mode:

  One of `"auto"`, `"fit"`, or `"facets"`. `"auto"` uses
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
  when the input object came from that workflow.

- include_bundle:

  If `TRUE`, append an `export_mfrm_bundle()` call to the generated
  script.

- bundle_dir:

  Output directory used when `include_bundle = TRUE`.

- bundle_prefix:

  Prefix used by the generated bundle exporter call.

- summary_tables:

  Optional manuscript-summary bundle input. Can be
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  output, any object supported by
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md),
  or a named list of such objects. When `NULL` and `"summary_tables"` is
  requested in `include`, a default set is built from `fit`,
  `diagnostics`,
  [mfrm_report_checklist](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md),
  and
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).
  Compatible precomputed recovery-evidence summaries can be supplied
  here to co-locate their appendix tables with a fit-based export
  bundle.

- output_dir:

  Directory where files will be written.

- prefix:

  File-name prefix.

- include:

  Components to export. Supported values are `"core_tables"`,
  `"checklist"`, `"dashboard"`, `"apa"`, `"anchors"`, `"manifest"`,
  `"visual_summaries"`, `"predictions"`, `"summary_tables"`, `"script"`,
  and `"html"`. By default, export all listed components except
  predictions when no prediction or plausible-value object is supplied.
  Explicitly requesting `"predictions"` requires at least one such
  object.

- facet:

  Optional facet for
  [`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md).

- overwrite:

  If `FALSE`, refuse to overwrite existing files.

- acknowledge_sensitive:

  Logical; set to `TRUE` only after acknowledging that the archive can
  contain direct person identifiers, person-level estimates, original
  labels, replay data, and local paths. This suppresses the privacy
  warning; it does not deidentify any file.

- zip_bundle:

  If `TRUE`, attempt to zip the written files into a single archive
  using [`utils::zip()`](https://rdrr.io/r/utils/zip.html). This is
  best-effort and may depend on the local R installation.

- zip_name:

  Optional zip-file name. Defaults to `"{prefix}_bundle.zip"`.

## Value

A named list with class `mfrm_manifest`.

A named list with class `mfrm_replay_script`.

A named list with class `mfrm_export_bundle`.

## Details

This helper creates a compact package-native analysis record. It
summarizes analysis settings, source columns, anchoring information, and
which downstream outputs are currently available.

This helper builds a reproducible script from `mfrmr`'s installed API.
The generated script assumes the user has the package installed and
provides a data file at `data_file`.

Anchor and group-anchor constraints are embedded directly from the
fitted object's stored configuration, so the script can replay anchored
analyses without manual table reconstruction. The script retains
`centering_scope`; a native fit saved before this setting was recorded
uses `"remainder"`. Running it performs a new fit under that convention,
not a conversion of the saved object. To adopt whole-facet centering,
review the generated call and change it to `"facet"`, preserving the
intended population, uncentered facet, rubric and step/slope owners.
Recheck the resulting constraints and readiness. Use
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html)/[`readRDS()`](https://rdrr.io/r/base/readRDS.html)
to reopen an unchanged fit, or the replay from
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
to reopen a saved results bundle without refitting.

Adjustments made with
[`apply_empirical_bayes_shrinkage()`](https://ryuya-dot-com.github.io/mfrmr/reference/apply_empirical_bayes_shrinkage.md)
are replayed after fitting, using the most recently recorded prior and
Person settings. The original fitting settings remain separate so that
attaching diagnostic SEs and then applying shrinkage is reproduced in
the same order. For a workflow object with a post-fit adjustment,
`"auto"` selects `"fit"` mode; an explicit `"facets"` request is refused
because it cannot retain that operation order. Older shrinkage results
without complete settings must first be refreshed with
[`apply_empirical_bayes_shrinkage()`](https://ryuya-dot-com.github.io/mfrmr/reference/apply_empirical_bayes_shrinkage.md).
Manually edited SEs or other table edits require their own reproducible
editing steps.

When the supplied fit uses the latent-regression `MML` branch, the
generated fit-mode script also carries the stored replay-ready person
table together with the corresponding `population_formula` / `person_id`
/ `population_policy` arguments needed to recreate the population model.
By default that replay-ready table is embedded inline; when
`fit_person_data_file` is supplied, the generated script reads it from
that sidecar CSV relative to the replay script location.

For `GPCM`, replay scripts are available with an explicit
`gpcm_boundary` table. The generated script records `step_facet` and
`slope_facet` settings, but full FACETS score-side contract review
remains outside this replay contract. Role-based design forecasting is
available through
[`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
as a separate caveated helper route.

Write selected CSV/text/script/HTML artifacts from a fitted analysis.
With `diagnostics = NULL`, compute the diagnostics needed for the
export. To inspect results before writing files, use
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
and
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md).

The returned `written_files` and optional ZIP include only files written
by this call. With `overwrite = TRUE`, the ZIP is built afresh and
checked before replacing an existing archive; obsolete members are not
retained. If ZIP creation fails, any older ZIP remains in place but is
not counted as a new output: `summary$ZipWritten` is zero and `notes`
explains the failure. Unrequested loose files in the folder are left in
place.

Every bundle is an analysis archive, not a deidentified or automatically
shareable package. Core tables, anchors, predictions, replay sidecars,
scripts, and HTML can contain identifying or study-sensitive
information. Review and transform every file under the applicable
data-handling policy before sharing it.

## When to use this

Use this machine-readable record to document settings and available
outputs. See "Choose a save or export route" in `export_mfrm_bundle()`
for saving results, writing files or generating a refitting script.
Review exported artifacts for person-level or sensitive data before
sharing.

Use this recipe to refit from `data_file` with the installed package.
For reopening saved results or writing an analysis folder, see "Choose a
save or export route" in `export_mfrm_bundle()`.

## Output

The returned bundle has class `mfrm_manifest` and includes:

- `summary`: one-row analysis overview

- `readiness`, `readiness_components`, and `readiness_parameters`: the
  fitted model's recorded numerical checks and restrictions on
  inference, overall and by component or parameter

- `environment`: package/R/platform metadata

- `model_settings`: key-value model settings table

- `source_columns`: key-value data-column table

- `estimation_control`: key-value optimizer settings table

- `anchor_summary`: facet-level anchor summary. `model_settings`
  separately records `centering_scope` and `noncenter_facet`; missing
  convention metadata in a native fit retains the legacy `"remainder"`
  interpretation

- `anchors`: machine-readable anchor table

- `hierarchical_review`: retained traceability table for hierarchical /
  small-sample design flags

- `missing_recoding`: retained traceability table for missing-code
  recoding

- `shrinkage_review`: retained traceability table for shrinkage settings

- `available_outputs`: availability table for
  diagnostics/bias/PCA/prediction outputs

- `dependencies`, `input_summary`, and `session_info`: reproducibility
  metadata tables. `input_summary` records object structure and does not
  claim byte-for-byte identity across platforms or serialization formats

- `settings`: manifest build settings

## Interpreting output

Read `summary` to identify the analysis, then `available_outputs` for
existing diagnostics/bias/PCA/predictions and `anchors` for fixed
constraints. `model_settings`, `source_columns` and `estimation_control`
support the methods write-up.

`Converged` records the optimizer return-code decision; `InferenceReady`
records whether the fit passes the additional numerical checks required
for inference. They need not agree; passing these checks does not
establish model fit or the statistical adequacy of every interval
method. The `readiness` tables preserve these checks for the original
fitted model, including the check-format version and reason codes.
Re-running the analysis must repeat the checks using the new fit; the
saved records do not certify it. Active latent-regression fits also
record their population-model provenance there, including the fitted
scoring basis, stored `population_formula`, and person-level data
requirements used by the fitted population model. When categorical
background variables are expanded through
[`stats::model.matrix()`](https://rdrr.io/r/stats/model.matrix.html),
`population_xlevel_variables` and `population_contrast_variables`
identify the variables whose fitted coding must be preserved for
replay/scoring.

The returned object contains:

- `summary`: a one-row overview of the chosen replay mode and whether
  bundle export was included

- `script`: the generated R code as a single string

- `source_readiness`, `source_readiness_components`, and
  `source_readiness_parameters`: readiness provenance from the source
  fit

- `anchors` and `group_anchors`: the exact stored constraints that were
  embedded into the script

The source readiness row is not copied into the replayed fit. The
generated script recomputes readiness and warns when its fit-level
decision fields do not match the source record. Identifier columns are
read as text, preserving leading zeros and literal `"NA"` labels.
Original column names and factor coding in exported person-level
background data are retained. Stored diagnostic settings are replayed as
well; older diagnostic objects may not retain interaction selection or
PCA limits, so rerun
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
before exporting them when those settings matter.

## Typical workflow

Build from a fit and reuse its diagnostics. To control residual PCA,
call
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
first. `export_mfrm_bundle()` writes the manifest and selected analysis
files to disk.

For `GPCM` fits, the manifest is available with an explicit
`gpcm_boundary` table. It records supported direct diagnostics/reporting
surfaces while keeping full FACETS score-side contract review blocked
and routing design forecasting through its separate caveated capability
row.

1.  Finalize a fit and diagnostics object.

2.  Generate the replay script with the path you want users to read
    from.

3.  Write `replay$script` to disk, or let `export_mfrm_bundle()` do it
    for you.

4.  Rerun the script in a fresh R session to confirm reproducibility.

## Saved-result reuse

Supplied screening results must match this analysis; older ones without
identity metadata are refused. See "Saved-result reuse" in
`export_mfrm_bundle()` for calibration checks, separate scenario
forecasts and recreating compatible results without refitting.

Supplied screening results must match this analysis; older ones without
identity metadata are refused. See "Saved-result reuse" in
`export_mfrm_bundle()` for calibration checks, separate scenario
forecasts and recreating compatible results without refitting.

Supplied screening results must describe this fitted analysis. Results
from another fit or older results without identity metadata are refused.
See
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)
to recreate them from the saved fit and matching diagnostics without
refitting the model. Supplied unit scores, plausible values and
fit-derived forecasts must also match this calibration. A forecast
created with `sim_spec` remains a separate scenario; its source is
recorded without asserting a match to the fit.

## Mode guide

- `"auto"` is the safest default and follows the structure of the
  supplied object.

- `"fit"` is useful when you want a minimal script centered on
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- `"facets"` is useful when you want to preserve the higher-level
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
  workflow, including stored column mapping.

## Choose a save or export route

- **Reopen without refitting:**
  [`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) /
  [`base::readRDS()`](https://rdrr.io/r/base/readRDS.html) preserves an
  R object. For an existing
  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
  bundle,
  [`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
  includes the RDS and a reload script by default.

- **Write tables or an analysis folder:**
  [`export_mfrm_tables()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_tables.md)
  writes core CSVs without automatic diagnostics. `export_mfrm_bundle()`
  writes the selected artifacts below; `build_mfrm_manifest()` records
  settings and available outputs.

- **Rerun the analysis:** `build_mfrm_replay_script()` generates R code
  for a new fit. The `"script"` component here writes that recipe, not
  the fitted R object. Generating the script does not execute it.

## Recommended presets

Common starting points are:

- minimal tables: `include = c("core_tables", "manifest")`

- reporting bundle:
  `include = c("core_tables", "checklist", "dashboard", "summary_tables", "html")`

- archival bundle:
  `include = c("core_tables", "manifest", "script", "visual_summaries", "html")`

## Written outputs

`include` selects these components:

- `"core_tables"`: CSVs from
  [`export_mfrm_tables()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_tables.md).

- `"checklist"`: CSVs from
  [mfrm_report_checklist](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md).

- `"dashboard"`:
  [`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md)
  tables and interpretation notes. CSV/HTML retain screening settings;
  HTML shows every level's estimates and unavailable diagnostics, while
  CSV retains full detail.

- `"apa"`: text from
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).

- `"summary_tables"`: manuscript CSVs and indexes from
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md).

- `"anchors"`: CSV from
  [`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md).

- `"manifest"`: CSV/TXT from `build_mfrm_manifest()`.

- `"visual_summaries"`: warnings/residual PCA summaries from
  [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md).

- `"predictions"`: CSVs for supplied
  [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md),
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
  or
  [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)
  results.

- `"script"`: code from `build_mfrm_replay_script()` and, when
  available, the latent-regression replay person-data CSV.

- `"html"`: exported tables/text and a replay-sidecar artifact index;
  raw person-level replay rows are not embedded. This is not
  deidentification.

Readiness CSVs preserve source-fit checks, latent-regression exports
retain replay `sim_spec` metadata when predictions are supplied, and
`GPCM` bundles record `gpcm_boundary`. Supplied diagnostics, screening
tables, unit scores, and plausible values must match `fit`'s calibration
identity; inspect `bundle$summary` and `bundle$written_files`.

## See also

`export_mfrm_bundle()`, `build_mfrm_replay_script()`,
[`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md),
[mfrm_report_checklist](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)

`build_mfrm_manifest()`, `export_mfrm_bundle()`,
[`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md),
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md),
`build_mfrm_manifest()`, `build_mfrm_replay_script()`,
[`export_mfrm_tables()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_tables.md),
[mfrm_report_checklist](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md),
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
# example("build_mfrm_manifest", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diag <- example_fit$diagnostics
manifest <- build_mfrm_manifest(fit, diagnostics = diag)
manifest$summary[, c("Model", "Method", "Observations", "Facets")]
manifest$available_outputs[, c("Component", "Available")]
} # }
# Optional workflow; run the example explicitly as shown below.
# example("build_mfrm_replay_script", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
library(mfrmr)
# Saved synthetic MML/RSM analysis of example_operational.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
fit <- example_fit$fit
replay <- build_mfrm_replay_script(fit, data_file = "your_data.csv")
replay$summary[, c("ScriptMode", "ResidualPCA", "BiasPairs")]
cat(substr(replay$script, 1, 120))
} # }
# Optional workflow; run the example explicitly as shown below.
# example("export_mfrm_bundle", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diag <- example_fit$diagnostics
bundle <- export_mfrm_bundle(
  fit,
  diagnostics = diag,
  output_dir = tempdir(),
  prefix = "mfrmr_bundle_example",
  include = c("core_tables", "manifest", "script", "html"),
  overwrite = TRUE,
  acknowledge_sensitive = TRUE
)
bundle$summary[, c("FilesWritten", "HtmlWritten", "ScriptWritten")]
head(data.frame(
  Component = bundle$written_files$Component,
  File = basename(bundle$written_files$Path)
))
# Full paths and data-handling notes remain in bundle$written_files.
} # }
```
