# Summarize a summary-table bundle for manuscript QC

Summarize a summary-table bundle for manuscript QC

## Usage

``` r
# S3 method for class 'mfrm_summary_table_bundle'
summary(object, digits = 3, top_n = 8, ...)
```

## Arguments

- object:

  Output from
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md).

- digits:

  Number of digits used for numeric summaries.

- top_n:

  Maximum number of table-profile rows to keep.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_summary_table_bundle`.

## Details

This summary is designed to answer a manuscript-facing question: which
reporting tables are available, how large are they, which roles do they
serve, and which of them contain numeric content suitable for quick
plotting or appendix export.

## Interpreting output

- `overview`: source class, returned-table count, note count, and
  whether a numeric table is available for plotting.

- `role_summary`: counts and total size by reporting role.

- `table_catalog`: complete returned-table registry with plot/export
  bridges.

- `table_profile`: table-level dimensions, numeric-column counts, and
  missing values for the largest returned tables.

- `plot_index`: which returned tables are plot-ready and which
  bundle-level numeric QC routes they support.

- `appendix_presets`: conservative `all` / `recommended` / `compact`
  plus section-aware `methods` / `results` / `diagnostics` / `reporting`
  appendix-export presets derived from table roles.

- `appendix_role_summary`: counts of returned tables by reporting role
  under the same conservative appendix routing used by the bundle
  catalog.

- `appendix_section_summary`: counts of returned tables by
  manuscript-facing appendix section.

- `selection_handoff_table_summary`: workflow-only table-level appendix
  handoff crosswalk when present in the bundle.

- `selection_handoff_preset_summary`: workflow-only appendix handoff
  overview aggregated at the preset level when present in the bundle.

- `selection_handoff_bundle_summary`: workflow-only appendix handoff
  overview aggregated at the bundle-by-section level when present in the
  bundle.

- `selection_handoff_role_summary`: workflow-only appendix handoff
  overview aggregated at the reporting-role level when present in the
  bundle.

- `selection_handoff_role_section_summary`: workflow-only appendix
  handoff overview aggregated at the reporting-role by appendix-section
  level when present in the bundle.

- `selection_summary`, `selection_table_summary`,
  `selection_table_preset_summary`, `selection_role_summary`,
  `selection_section_summary`, and `selection_catalog`: preset-filtered
  appendix selection surfaces when workflow-only handoff tables are
  embedded in the bundle.

- `reporting_map`: where to go next for plotting, APA formatting, and
  export.

- `notes`: carried forward source-level caveats from the originating
  summary.

## Typical workflow

1.  Build `bundle <- build_summary_table_bundle(summary(...))`.

2.  Run `summary(bundle)` to see reporting coverage.

3.  Use `plot(bundle, type = "table_rows")` or
    `plot(bundle, type = "numeric_profile", which = ...)` for quick QC.

## See also

[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md),
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", maxit = 30
)
bundle <- build_summary_table_bundle(fit)
summary(bundle)
} # }
```
