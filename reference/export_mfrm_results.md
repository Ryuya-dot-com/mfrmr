# Export a lightweight mfrm_results archive

`export_mfrm_results()` writes the contents of an existing
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
object to a small shareable folder. It is a results-download helper for
the comprehensive first-screen workflow, not a new estimation,
diagnostics, or validation step.

## Usage

``` r
export_mfrm_results(
  x,
  output_dir = ".",
  prefix = "mfrmr_results",
  include = "default",
  overwrite = FALSE,
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

- overwrite:

  Logical; if `FALSE`, existing files stop the export.

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

- a replay `.R` scaffold from `x$input$reproducible_code`;

- a written-files manifest and compact export summary.

Plot export is intentionally optional because some plot routes can be
comparatively slow or require richer graphics devices. Plot failures are
recorded in the returned `plot_errors` table rather than stopping the
export.

## See also

[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
[`launch_mfrmr_viewer()`](https://ryuya-dot-com.github.io/mfrmr/reference/launch_mfrmr_viewer.md),
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md),
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
toy_small <- toy[toy$Person %in% unique(toy$Person)[1:6], , drop = FALSE]
fit <- fit_mfrm(toy_small, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
res <- mfrm_results(fit, include = c("fit", "diagnostics", "tables"))

exported <- export_mfrm_results(
  res,
  output_dir = tempdir(),
  prefix = "mfrmr_results_example",
  overwrite = TRUE
)
exported$summary[, c("FilesWritten", "CsvWritten", "HtmlWritten")]
} # }
```
