# Export manuscript appendix tables from documented summary surfaces

Export manuscript appendix tables from documented summary surfaces

## Usage

``` r
export_summary_appendix(
  x,
  output_dir = ".",
  prefix = "mfrmr_appendix",
  include_html = TRUE,
  preset = c("all", "recommended", "compact", "methods", "results", "diagnostics",
    "reporting"),
  overwrite = FALSE,
  zip_bundle = FALSE,
  zip_name = NULL,
  digits = 3,
  top_n = 10,
  preview_chars = 160
)
```

## Arguments

- x:

  A supported [`summary()`](https://rdrr.io/r/base/summary.html) source,
  a prebuilt
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  result, or a named list of such objects.

- output_dir:

  Directory where files will be written.

- prefix:

  File-name prefix for written artifacts.

- include_html:

  If `TRUE`, also write a lightweight HTML appendix page.

- preset:

  Appendix table-selection preset: `"all"` keeps every returned summary
  table, `"recommended"` keeps manuscript-facing summary tables while
  dropping bridge-only or preview-only surfaces, and `"compact"` keeps a
  smaller reviewer-facing subset. Section-aware presets `"methods"`,
  `"results"`, `"diagnostics"`, and `"reporting"` keep only the returned
  tables classified to those appendix sections in the summary-table
  catalog.

- overwrite:

  If `FALSE`, refuse to overwrite existing files.

- zip_bundle:

  If `TRUE`, attempt to zip the written appendix artifacts.

- zip_name:

  Optional zip-file name. Defaults to `"{prefix}_appendix.zip"`.

- digits:

  Digits forwarded when raw objects must be normalized through
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md).

- top_n:

  Row cap forwarded when raw objects must be normalized through
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md).

- preview_chars:

  Character cap forwarded when APA-output summaries must be normalized
  through
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md).

## Value

A named list of class `mfrm_summary_appendix_export` with:

- `summary`

- `written_files`

- `selection_summary`

- `selection_table_summary`

- `selection_section_table_summary`

- `selection_handoff_table_summary`

- `selection_handoff_preset_summary`

- `selection_handoff_summary`

- `selection_handoff_bundle_summary`

- `selection_handoff_role_summary`

- `selection_handoff_role_section_summary`

- `selection_role_summary`

- `selection_section_summary`

- `selection_catalog`

- `settings`

- `notes`

## Details

Export the tables selected by
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
as CSV and optional HTML. Pass a supported object, its summary, a
prebuilt bundle or a named list; a fitted model is not required. Presets
select from tables already available in the source, not additional
analyses.

Inspect `written_files` for the actual file paths. An analysis table
whose name conflicts with bundle metadata (for example, `overview`) is
retained with a `table_` prefix, with a numeric suffix if needed for
uniqueness. Metadata keeps its existing filename; the analysis table is
also retained in HTML. Summary rounding follows `digits`; retain the
source R object for full-precision reuse. ZIP archives contain only
files written by this call. With `overwrite = TRUE` an existing ZIP is
replaced after the new archive is built and checked; obsolete members
are not carried forward. If ZIP creation fails, any older ZIP is
retained, `summary$ZipWritten` is zero and `notes` explains the failure.
Other files in the destination folder are left in place.

## Retained reporting evidence

`analysis_caveats` and `score_category_caveats` remain in
`"recommended"` and `"diagnostics"` selections when supplied.
Precision-review tables retain `fit_separation_basis`; fit-measure and
FACETS review tables retain df/ZSTD sensitivity and optional external
matching. These distinguish fit, ZSTD, separation/reliability/strata and
review thresholds from recovery criteria; see
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
for roles and reading order.

[`simulate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_recovery.md)
and
[`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_recovery.md)
outputs retain the ADEMP simulation basis, recovery metrics, replication
status, adequacy checklist, thresholds and next actions as separate
tables. Compatible precomputed recovery summaries retain case and domain
assessments plus condition and diagnostic notes. Review those notes
before using the exported tables in a manuscript.

## See also

[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md),
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md),
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
# example("export_summary_appendix", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diag <- example_fit$diagnostics
appendix <- export_summary_appendix(
  list(fit = fit, diagnostics = diag),
  output_dir = tempdir(),
  prefix = "mfrmr_appendix_example",
  include_html = TRUE,
  overwrite = TRUE
)
appendix$summary
} # }
```
