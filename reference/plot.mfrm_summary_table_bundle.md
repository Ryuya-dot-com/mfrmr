# Plot a summary-table bundle for manuscript QC

Plot a summary-table bundle for manuscript QC

## Usage

``` r
# S3 method for class 'mfrm_summary_table_bundle'
plot(
  x,
  y = NULL,
  type = c("table_rows", "role_tables", "appendix_roles", "appendix_sections",
    "appendix_presets", "selection_handoff_presets", "selection_tables",
    "selection_handoff", "selection_handoff_bundles", "selection_handoff_roles",
    "selection_handoff_role_sections", "selection_bundles", "selection_roles",
    "selection_sections", "numeric_profile", "first_numeric"),
  which = NULL,
  selection_value = c("count", "fraction"),
  appendix_preset = c("recommended", "compact", "all", "methods", "results",
    "diagnostics", "reporting"),
  main = NULL,
  palette = NULL,
  label_angle = 45,
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  Output from
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md).

- y:

  Reserved for generic compatibility.

- type:

  Plot type: `"table_rows"` for returned-table sizes, `"role_tables"`
  for returned-table counts by reporting role, `"appendix_roles"` for
  returned-table counts by reporting role under the bundle's
  appendix-routing contract, `"appendix_sections"` for returned-table
  counts by manuscript-facing appendix section, `"appendix_presets"` for
  conservative appendix-preset counts, `"selection_handoff_presets"` for
  workflow-only preset-level appendix handoff counts,
  `"selection_tables"` / `"selection_handoff"` /
  `"selection_handoff_bundles"` / `"selection_handoff_roles"` /
  `"selection_bundles"` / `"selection_roles"` / `"selection_sections"`
  for workflow-only appendix selection surfaces when present in the
  bundle, `"numeric_profile"` for column means from a selected numeric
  table, or `"first_numeric"` for the distribution of the first numeric
  column in a selected table.

- which:

  Optional table selector used for numeric plot types.

- selection_value:

  For `selection_*` plot types, whether to plot exact counts (`"count"`)
  or the corresponding exact fraction (`"fraction"`) when that surface
  exposes one.

- appendix_preset:

  Appendix preset used for `selection_*` plot types.

- main:

  Optional title override.

- palette:

  Optional named color overrides.

- label_angle:

  Axis-label rotation angle for bar-type plots.

- draw:

  If `TRUE`, draw using base graphics.

- ...:

  Reserved for generic compatibility.

## Value

A plotting-data object of class `mfrm_plot_data`.

## Details

This helper keeps summary-bundle plotting conservative. It either
visualizes the bundle's own bundle-level indexes (`"table_rows"`,
`"role_tables"`, `"appendix_roles"`, `"appendix_sections"`,
`"appendix_presets"`) or routes a selected table through
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
and
[`plot.apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.apa_table.md)
for numeric QC.

## Interpreting output

- `"table_rows"`: compares returned table sizes to show where reporting
  mass sits.

- `"role_tables"`: shows how many returned tables belong to each
  reporting role.

- `"appendix_roles"`: shows how returned tables contribute to
  conservative appendix routing by reporting role.

- `"appendix_sections"`: shows how returned tables are distributed
  across methods/results/diagnostics/reporting sections.

- `"appendix_presets"`: shows how many tables the current bundle
  contributes to the conservative appendix presets.

- `"selection_handoff_presets"`: shows plot-ready appendix handoff
  counts by preset for workflow-only appendix routing surfaces in the
  bundle.

- `"selection_tables"` / `"selection_handoff"` /
  `"selection_handoff_bundles"` / `"selection_handoff_roles"` /
  `"selection_handoff_role_sections"` / `"selection_bundles"` /
  `"selection_roles"` / `"selection_sections"`: show workflow-only
  appendix selection surfaces already materialized inside the bundle.

- `"numeric_profile"` / `"first_numeric"`: reuse the same numeric QC
  logic as
  [`plot.apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.apa_table.md)
  but start from a summary-table bundle.

## See also

[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md),
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
[`plot.apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.apa_table.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", maxit = 30
)
bundle <- build_summary_table_bundle(fit)
plot(bundle, draw = FALSE)
plot(bundle, type = "numeric_profile", which = "facet_overview", draw = FALSE)
} # }
```
