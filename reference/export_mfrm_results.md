# Export an mfrm_results analysis archive

`export_mfrm_results()` writes the contents of an existing
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
object to a compact analysis folder. It is a results-download helper for
the comprehensive first-screen workflow, not a new estimation,
diagnostics, or validation step. The folder is not deidentified or
automatically shareable.

## Usage

``` r
export_mfrm_results(
  x,
  output_dir = ".",
  prefix = "mfrmr_results",
  include = "default",
  preset = NULL,
  overwrite = FALSE,
  acknowledge_sensitive = FALSE,
  zip_bundle = FALSE,
  zip_name = NULL,
  plot_width = 1200,
  plot_height = 900,
  plot_res = 144
)
```

## Arguments

- x:

  An
  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
  object.

- output_dir:

  Directory where files should be written.

- prefix:

  File-name prefix. Non-alphanumeric characters are converted to
  underscores.

- include:

  Export components. `"default"` expands to `"summary"`, `"tables"`,
  `"html"`, `"rds"`, `"replay"`, and `"manifest"`. Add `"report"` to
  write
  [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
  tables plus Markdown and HTML; add `"plots"` to write available plot
  routes as PNG files, or use `"all"`.

- preset:

  Optional reader-facing analysis-archive preset. `"starter"` adds the
  report and plot routes to the default files and writes `index.html`
  with the required Wright map embedded at the start of the reading
  flow.

- overwrite:

  Logical; if `FALSE`, existing files stop the export.

- acknowledge_sensitive:

  Logical; set to `TRUE` only after acknowledging that every preset can
  contain direct person identifiers, person-level results, original
  labels, local paths, and a complete result object. This suppresses the
  privacy warning; it does not deidentify any file.

- zip_bundle:

  Logical; if `TRUE`, create a best-effort zip archive of the written
  files.

- zip_name:

  Optional zip file name. When omitted, `{prefix}_mfrm_results.zip` is
  used.

- plot_width, plot_height, plot_res:

  PNG device settings used when `include` contains `"plots"`.

## Value

An `mfrm_results_export` object with `summary`, `written_files`,
`plot_errors`, and zip status fields.

## Details

The helper writes:

- summary CSVs from `summary(x)` such as overview, status, triage, plot
  routes, next actions, mapping, and replay-code lines;

- collected `x$tables` as CSV files;

- optional report artifacts from `mfrm_report(x)`, including
  report-index, evidence-summary, and reporting-template CSVs plus
  Markdown and HTML;

- a lightweight HTML report equivalent to
  `mfrm_results(x, output = "html")` for the already-created object;

- an `.rds` copy of the `mfrm_results` object;

- a replay `.R` script from `x$input$reproducible_code`;

- a written-files manifest and compact export summary.

All presets, including `"starter"`, are analysis archives. In
particular, the default `.rds` file retains the complete result object,
and CSV, HTML, plot, and replay artifacts can retain direct identifiers
or other sensitive study information. The manifest labels each file for
review, but the helper does not pseudonymize, redact, or certify an
export for sharing. Apply the study's data-governance process before
moving the files outside the approved analysis environment.

Plot export is intentionally optional because some plot routes can be
comparatively slow or require richer graphics devices. Plot failures are
recorded in the returned `plot_errors` table rather than stopping the
export. The `"starter"` preset is the recommended reader-oriented
analysis archive because it always requests the Wright map in addition
to the result summary, report, replay script, and manifest. Its Infit
pathway includes a bounded selection of person rows so person fit can be
reviewed without replacing the required Wright-map first screen.

## See also

[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
[`launch_mfrmr_viewer()`](https://ryuya-dot-com.github.io/mfrmr/reference/launch_mfrmr_viewer.md),
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md),
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
toy_small <- toy[toy$Person %in% unique(toy$Person)[1:6], , drop = FALSE]
fit <- fit_mfrm(toy_small, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
res <- mfrm_results(fit, include = c("fit", "diagnostics", "tables"))

exported <- export_mfrm_results(
  res,
  output_dir = tempdir(),
  prefix = "mfrmr_results_example",
  preset = "starter",
  overwrite = TRUE
)
#> Warning: This export is an analysis archive, not a deidentified or automatically shareable package. It can contain direct person identifiers, person-level estimates, original facet labels, local file paths, and a complete RDS result object. Review and transform every file under the applicable data-handling policy before sharing it. Set `acknowledge_sensitive = TRUE` only to acknowledge this risk; that setting does not deidentify the export.
exported$summary[, c("FilesWritten", "CsvWritten", "HtmlWritten")]
#>   FilesWritten CsvWritten HtmlWritten
#> 1          142        129           3
# }
```
