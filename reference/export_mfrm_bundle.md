# Export an analysis bundle for sharing or archiving

Export an analysis bundle for sharing or archiving

## Usage

``` r
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
  `"both"` when visual summaries are requested).

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

- summary_tables:

  Optional manuscript-summary bundle input. Can be
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  output, any object supported by
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md),
  or a named list of such objects. When `NULL` and `"summary_tables"` is
  requested in `include`, a default set is built from `fit`,
  `diagnostics`,
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
  and
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).
  Recovery-validation summaries can be supplied here to co-locate
  release-review appendix tables with a fit-based export bundle.

- output_dir:

  Directory where files will be written.

- prefix:

  File-name prefix.

- include:

  Components to export. Supported values are `"core_tables"`,
  `"checklist"`, `"dashboard"`, `"apa"`, `"anchors"`, `"manifest"`,
  `"visual_summaries"`, `"predictions"`, `"summary_tables"`, `"script"`,
  and `"html"`.

- facet:

  Optional facet for
  [`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md).

- include_person_anchors:

  If `TRUE`, include person measures in the exported anchor table.

- overwrite:

  If `FALSE`, refuse to overwrite existing files.

- zip_bundle:

  If `TRUE`, attempt to zip the written files into a single archive
  using [`utils::zip()`](https://rdrr.io/r/utils/zip.html). This is
  best-effort and may depend on the local R installation.

- zip_name:

  Optional zip-file name. Defaults to `"{prefix}_bundle.zip"`.

- data:

  Optional original analysis data frame. When supplied,
  `export_mfrm_bundle()` co-locates a CSV copy of the data alongside the
  replay script and updates the script's
  [`read.csv()`](https://rdrr.io/r/utils/read.table.html) path to point
  at it. The manifest's `input_hash` row for `data` is also computed
  against the user's untouched input so the recorded fingerprint matches
  what the replay script will load. Default `NULL` falls back to the
  legacy `your_data.csv` placeholder path.

## Value

A named list with class `mfrm_export_bundle`.

## Details

This function is the package-native counterpart to the app's download
bundle. It reuses existing `mfrmr` helpers instead of reimplementing
estimation or diagnostics. It is also the one-call fit-level HTML route:
when `diagnostics = NULL`, the exporter computes the diagnostics it
needs, then writes the requested CSV/text/replay artifacts and a
lightweight HTML page from the fitted object. Use
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
and
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
first when you want to inspect a results object before writing files;
use `export_mfrm_bundle()` when the goal is a project-folder bundle from
`fit`.

## Choosing exports

The `include` argument lets you assemble a bundle for different
audiences:

- `"core_tables"` for analysts who mainly want CSV output.

- `"manifest"` for a compact analysis record.

- `"script"` for reproducibility and reruns. For latent-regression fits,
  this also writes the fit-level replay person-data sidecar when
  available.

- `"html"` for a light, shareable summary page. When replay sidecars are
  present, the HTML shows an artifact index for them rather than
  embedding the raw person-level replay table.

- `"summary_tables"` for manuscript-facing CSV exports of validated
  [`summary()`](https://rdrr.io/r/base/summary.html) surfaces and their
  compact indexes.

- `"visual_summaries"` when you want warning maps or residual PCA
  summaries to travel with the bundle.

## Recommended presets

Common starting points are:

- minimal tables: `include = c("core_tables", "manifest")`

- reporting bundle:
  `include = c("core_tables", "checklist", "dashboard", "summary_tables", "html")`

- archival bundle:
  `include = c("core_tables", "manifest", "script", "visual_summaries", "html")`

## Written outputs

Depending on `include`, the exporter can write:

- core CSV tables via
  [`export_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm.md)

- checklist CSVs via
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)

- facet-dashboard CSVs via
  [`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md)

- APA text files via
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)

- manuscript-summary CSVs via
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)

- anchor CSV via
  [`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md)

- manifest CSV/TXT via
  [`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_manifest.md)

- visual warning/summary artifacts via
  [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)

- prediction/forecast CSVs via
  [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md),
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md),
  and
  [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)

- a package-native replay script via
  [`build_mfrm_replay_script()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_replay_script.md)

- for latent-regression fits, a replay-side person-data CSV paired with
  the replay script

- a lightweight HTML report that bundles the exported tables/text and,
  for replay sidecars, an artifact summary instead of raw person-level
  rows

For latent-regression fits, prediction-side artifacts can carry the
fitted population-model scoring basis when you explicitly supply the
corresponding prediction objects.
[`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
remains the scenario-level forecast helper, whereas
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
and
[`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)
are the scoring layer. To keep exports and replay scripts practical,
large future-planning schemas from scenario-level population predictions
are not flattened into `*_population_prediction_settings.csv` or ADeMP
CSVs; the compact simulation specification files carry the
replay-relevant settings instead.

For bounded `GPCM`, this exporter is available as a caveated partial
bundle over supported diagnostics, report text, visual summaries,
manifests, and replay scripts. The returned object and manifest include
`gpcm_boundary`. Package-native bounded-`GPCM` scorefile export is
available with caveats, while full FACETS-style score-side contract
review and design forecasting remain outside this bundle contract.

## Interpreting output

The returned object reports both high-level bundle status and the exact
files written. In practice, `bundle$summary` is the direct status check,
while `bundle$written_files` is the file inventory to inspect or hand
off to other tools.

## Typical workflow

1.  Fit a model and compute diagnostics once.

2.  Decide whether the audience needs tables only, or also a manifest,
    replay script, and HTML summary.

3.  Call `export_mfrm_bundle()` with a dedicated output directory.

4.  Inspect `bundle$written_files` or open the generated HTML file.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md),
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md),
[`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_manifest.md),
[`build_mfrm_replay_script()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_replay_script.md),
[`export_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
bundle <- export_mfrm_bundle(
  fit,
  diagnostics = diag,
  output_dir = tempdir(),
  prefix = "mfrmr_bundle_example",
  include = c("core_tables", "manifest", "script", "html"),
  overwrite = TRUE
)
bundle$summary[, c("FilesWritten", "HtmlWritten", "ScriptWritten")]
head(bundle$written_files)
}
```
