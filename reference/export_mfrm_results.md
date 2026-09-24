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
  with the required Wright map for ordinary models, or the available
  model-specific figures for testlet and random-rater results.

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

- collected `x$tables` as CSV files (tables with no columns are omitted;
  zero-row tables with defined columns retain their headers);

- optional report artifacts from `mfrm_report(x)`, including
  report-index, evidence-summary, and reporting-template CSVs plus
  Markdown and HTML;

- a lightweight HTML report equivalent to
  `mfrm_results(x, output = "html")` for the already-created object;

- an `.rds` copy of the `mfrm_results` object;

- a replay `.R` script from `x$input$reproducible_code`;

- a written-files manifest and compact export summary.

For testlet, random-rater and ordinary results with saved posterior
response diagnostics, replay reloads the exported RDS without refitting,
rescoring or resampling. Requesting `"replay"` also includes `"rds"`.
Run the script from the exported folder. Stored prediction settings,
unavailable rows, numerical checks and interval meanings travel with the
result. A bootstrap interval may have infinite endpoints; exports retain
them instead of substituting finite ordinary intervals.

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
analysis archive because, for ordinary models, it requests the Wright
map in addition to the result summary, report, replay script, and
manifest. Its Infit pathway includes a bounded selection of person rows
so person fit can be reviewed without replacing the required Wright-map
first screen.

## See also

[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
[`launch_mfrmr_viewer()`](https://ryuya-dot-com.github.io/mfrmr/reference/launch_mfrmr_viewer.md),
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md),
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)

## Examples

``` r
# \donttest{
# Load the package and example ratings
library(mfrmr)
toy <- load_mfrmr_data("example_operational")

# Fit the model
fit <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM"
)

res <- mfrm_results(fit)

# Create a new temporary folder for this example's files
# For your own analysis, use a permanent folder you can write to
output_dir <- tempfile("mfrmr-example-")
exported <- export_mfrm_results(
  res,
  output_dir = output_dir,
  preset = "starter",
  acknowledge_sensitive = TRUE # These data are synthetic; exports retain IDs
)

# Preview filenames and check whether any plots could not be exported
head(data.frame(
  Component = exported$written_files$Component,
  File = basename(exported$written_files$Path)
))
#>                          Component
#> 1                 summary_overview
#> 2                 summary_decision
#> 3                   summary_status
#> 4            summary_fit_readiness
#> 5 summary_fit_readiness_components
#> 6 summary_fit_readiness_parameters
#>                                                 File
#> 1                 mfrmr_results_summary_overview.csv
#> 2                 mfrmr_results_summary_decision.csv
#> 3                   mfrmr_results_summary_status.csv
#> 4            mfrmr_results_summary_fit_readiness.csv
#> 5 mfrmr_results_summary_fit_readiness_components.csv
#> 6 mfrmr_results_summary_fit_readiness_parameters.csv
exported$plot_errors
#> [1] Plot  Error
#> <0 rows> (or 0-length row.names)
# Full paths remain in exported$written_files$Path.
# Open index.html in output_dir to read the report.
# }
```
