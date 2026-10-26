# Export fitted MFRM tables to CSV files

Writes tidy CSV files suitable for import into spreadsheet software or
further analysis in other tools. This is the CSV-only route from a
fitted model. It does not run diagnostics, save a complete R object, or
create a replay script. Use
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
to archive an existing results object and reload it without refitting,
or
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
for a fit-level collection with an optional refitting script. In 0.2.4
this replaces `export_mfrm()`; arguments, CSV filenames and the returned
file table are unchanged. Enriched facet CSVs now also retain the
diagnostic availability and uncertainty fields.

## Usage

``` r
export_mfrm_tables(
  fit,
  diagnostics = NULL,
  output_dir = ".",
  prefix = "mfrm",
  tables = c("person", "facets", "summary", "steps", "measures"),
  overwrite = FALSE,
  acknowledge_sensitive = FALSE
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  When provided, enriches facet estimates with SE, fit statistics, their
  calculation/availability fields and reasons, and writes the full
  measures table. Must belong to the same `fit`; mismatched or outdated
  diagnostics are rejected before creating files.

- output_dir:

  Directory for CSV files. Created if it does not exist.

- prefix:

  Filename prefix (default `"mfrm"`).

- tables:

  Character vector of tables to export. Any subset of `"person"`,
  `"facets"`, `"summary"`, `"steps"`, `"measures"`. Default exports all
  available tables.

- overwrite:

  If `FALSE` (default), refuse to overwrite existing files.

- acknowledge_sensitive:

  Logical; set to `TRUE` only after acknowledging that these tables can
  contain direct person identifiers, person-level estimates, and
  original facet labels. This suppresses the privacy warning; it does
  not deidentify any file.

## Value

Invisibly, a data.frame listing written files, their paths, and explicit
privacy/data-handling metadata. `Deidentified` and
`ShareableWithoutReview` are always `FALSE`.

## Exported files

- `{prefix}_person_estimates.csv`:

  Person ID, Estimate, SD.

- `{prefix}_facet_estimates.csv`:

  Facet, Level, Estimate, and optionally SE, Infit, Outfit, PTMEA and
  their qualification fields when diagnostics are supplied.

- `{prefix}_fit_summary.csv`:

  One-row model summary.

- `{prefix}_step_parameters.csv`:

  Step/threshold parameters.

- `{prefix}_measures.csv`:

  Full measures table (requires diagnostics).

## Interpreting output

The returned data.frame tells you exactly which files were written and
where. This is convenient for scripted pipelines where the output
directory is created on the fly. The files are analysis tables, not a
deidentified sharing package; review each file under the applicable
data-handling policy before sharing it. In enriched facet tables, read
`SE_Method`, `SEUse`, `CIUse`, `InferenceReady` and
`SupportsFormalInference` with the SE. Read `FitStatus` and `FitReason`
with Infit/Outfit. A finite value does not imply valid formal inference.
These columns preserve the matching diagnostics' qualifications; the
export does not compute a new SE or confidence interval. Missing fields
in an older diagnostic result are not filled with assumed approval.

## Typical workflow

1.  Fit a model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Optionally compute diagnostics with
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    when you want enriched facet or measures exports.

3.  Call `export_mfrm_tables(...)` and inspect the returned `Path`
    column.

## See also

[`fit_mfrm`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`as.data.frame.mfrm_fit`](https://ryuya-dot-com.github.io/mfrmr/reference/as.data.frame.mfrm_fit.md),
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md),
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)

## Examples

``` r
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

# Compute diagnostics once for the following checks
diagnostics <- diagnose_mfrm(fit)

# Use a new temporary folder for this example; choose a permanent one for your work
output_dir <- tempfile("mfrmr-tables-")
files <- export_mfrm_tables(
  fit,
  diagnostics = diagnostics,
  output_dir = output_dir,
  acknowledge_sensitive = TRUE # Synthetic data; exported tables retain person IDs
)

# Preview filenames; full paths remain in files$Path
data.frame(Table = files$Table, File = basename(files$Path))
#>      Table                      File
#> 1   person mfrm_person_estimates.csv
#> 2   facets  mfrm_facet_estimates.csv
#> 3  summary      mfrm_fit_summary.csv
#> 4    steps  mfrm_step_parameters.csv
#> 5 measures         mfrm_measures.csv
# Open a path from files$Path in a spreadsheet app or with read.csv()
```
