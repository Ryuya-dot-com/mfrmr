# Export an mfrm_results analysis archive

Write an existing
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
object and its selected outputs to an analysis folder. Exporting does
not rerun or validate the analysis, and the folder is not deidentified
or automatically shareable.

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
  `"html"`, `"rds"`, `"replay"`, and `"manifest"`. `"replay"` always
  includes `"rds"` to reload the complete saved result. Add `"report"`
  to write
  [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
  tables plus Markdown and HTML; add `"plots"` to write available plot
  routes as PNG files with separate title/notes CSV files, or use
  `"all"`.

- preset:

  Optional reader-facing analysis-archive preset. `"starter"` adds the
  report and plot routes to the default files and writes `index.html`
  with the default Wright map for ordinary models, or the available
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

- a replay `.R` script that reloads the complete exported result;

- optional PNG figures and matching `_plot_{type}_notes.csv` files. Each
  CSV retains
  [`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
  notes and their source-specific columns, with suggested titles
  identified by `Type = "title"`. Titles and explanatory notes remain
  outside the image; the starter index links each PNG to its CSV. A
  multi-plot `fit` bundle produces one PNG/CSV pair per member, named
  `_plot_fit_wright_map`, `_plot_fit_pathway_map` and
  `_plot_fit_category_characteristic_curves`, rather than one combined
  PNG;

- a written-files manifest and compact export summary.

Replay reloads the complete RDS for every supported result type without
refitting, rescoring or resampling; source-session variables are
unnecessary. Run `source("path/to/prefix_replay.R", chdir = TRUE)` using
the exported path, or run the script from its folder.
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
instead supplies a refitting script;
[`export_mfrm_tables()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_tables.md)
exports only core fit tables.

CSV files use UTF-8. With base R, import using
`read.csv(path, encoding = "UTF-8", check.names = FALSE)` to preserve
user names across locales.

Stored prediction settings, unavailable rows, numerical checks and
interval meanings travel with the result. A bootstrap interval may have
infinite endpoints; exports retain them instead of substituting finite
ordinary intervals.

All presets retain potentially sensitive study information as described
by `acknowledge_sensitive`. The manifest labels files for review, but
supplies no redaction or sharing certification. Apply the study's
data-governance process before moving files outside the approved
analysis environment.

Plotting is optional because it can be slow or require richer graphics
devices. Failures go to `plot_errors` without stopping the export. The
`"starter"` preset includes the model-appropriate figures described
under `preset`. For ordinary models, its Infit pathway uses a bounded
selection of Person rows for focused review alongside the Wright map.

With `overwrite = TRUE`, a requested ZIP is rebuilt from files written
by this call; members from an older archive are not retained. ZIP
command or content-check failure leaves any older ZIP in place, sets
`ZipWritten` to `FALSE`, and explains the failure in `zip_note`. That
older archive is not listed as a new output. Unrequested loose files in
`output_dir` are neither deleted nor included. The on-disk file manifest
and export summary describe the non-ZIP artifacts, including any
plot-error CSV; the returned `written_files` and `summary` additionally
record a successful ZIP.

## See also

[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
[`launch_mfrmr_viewer()`](https://ryuya-dot-com.github.io/mfrmr/reference/launch_mfrmr_viewer.md),
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md),
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("export_mfrm_results", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Load the package and example ratings
library(mfrmr)
ratings <- load_mfrmr_data("example_operational")

# Fit these ratings; replace the data-loading line for your own analysis
fit <- fit_mfrm(
  data = ratings,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  rating_min = 1, rating_max = 4, category_policy = "preserve",
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
exported$plot_errors
# Full paths remain in exported$written_files$Path.
# Open index.html in output_dir to read the report.
} # }
```
