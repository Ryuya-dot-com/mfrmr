# Export manuscript appendix tables from validated summary surfaces

Export manuscript appendix tables from validated summary surfaces

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

This helper is the narrow public bridge from validated
[`summary()`](https://rdrr.io/r/base/summary.html) surfaces to
manuscript appendix artifacts. It accepts the same reporting objects
that
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
supports, exports their table bundles as CSV, and optionally assembles a
lightweight HTML appendix page.

Fit-level caveats are exported through the `analysis_caveats` role, and
pre-fit score-support caveats are exported through the
`score_category_caveats` role. Both roles are classified as diagnostics,
so they remain available under `"recommended"` and `"diagnostics"`
presets when the source summary contains caveat rows.

Precision-review summaries keep `fit_separation_basis` in the exported
precision-review role so fit, ZSTD, separation/reliability/strata, and
package QC thresholds can be reported without turning them into release
or recovery success gates. Fit-measure and FACETS fit-review summaries
keep df/ZSTD sensitivity and optional external FACETS matching tables in
the same precision-review lane.

Parameter-recovery studies can be exported by passing
[`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md)
or
[`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md)
output directly. The exported bundle keeps the ADEMP-style simulation
basis, recovery metrics, replication status, adequacy checklist,
thresholds, and next actions in separate appendix-ready tables.

Recovery-validation summaries from the packaged validation protocol can
be exported by passing `summary(validation)`, including top-line release
decisions, condition notes, diagnostic notes, and domain decisions.

Unlike
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md),
this helper does not require a fitted model. It is intended for the
stage where compact reporting summaries already exist and the task is to
hand off appendix-ready tables, catalogs, and reporting maps.

## Typical workflow

1.  Build `summary(...)` objects from fit, diagnostics, data
    description, reporting checklist, or APA outputs.

2.  Call `export_summary_appendix(...)` on one object or a named list.

3.  Hand off the written CSV/HTML appendix artifacts to manuscript or QA
    workflows.

## See also

[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md),
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md),
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
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
