# Plot a future arbitrary-facet planning active branch

Plot a future arbitrary-facet planning active branch

## Usage

``` r
# S3 method for class 'mfrm_future_branch_active_branch'
plot(
  x,
  y = NULL,
  type = c("profile_metrics", "load_balance", "coverage", "readiness_tiers",
    "table_rows", "role_tables", "appendix_roles", "appendix_sections",
    "appendix_presets", "selection_handoff_presets", "selection_tables",
    "selection_handoff", "selection_handoff_bundles", "selection_handoff_roles",
    "selection_handoff_role_sections", "selection_bundles", "selection_roles",
    "selection_sections"),
  appendix_preset = c("recommended", "compact", "all", "methods", "results",
    "diagnostics", "reporting"),
  selection_value = c("count", "fraction"),
  draw = TRUE,
  main = NULL,
  palette = NULL,
  label_angle = 45,
  ...
)
```

## Arguments

- x:

  Output from the future-branch active planning scaffold stored in
  `planning_schema$future_branch_active_branch`.

- y:

  Unused placeholder for generic compatibility.

- type:

  Plot type: `"profile_metrics"` for recommended deterministic profile
  values by metric, `"load_balance"` for recommended load/balance values
  by metric, `"coverage"` for recommended coverage/connectivity values
  by metric, `"readiness_tiers"` for counts of structural tiers across
  the current active-branch design grid, `"table_rows"` /
  `"role_tables"` / `"appendix_roles"` for summary-table bundle QC,
  `"appendix_sections"` / `"appendix_presets"` for manuscript-facing
  appendix selection counts, `"selection_handoff_presets"` for
  preset-level appendix handoff counts, `"selection_tables"` for
  appendix-selected future-branch tables ranked by row count within a
  preset, `"selection_handoff"` for section-aware plot-ready appendix
  handoff counts, `"selection_handoff_bundles"` for section-and-bundle
  plot-ready appendix handoff counts, `"selection_handoff_roles"` for
  role-aware plot-ready appendix handoff counts,
  `"selection_handoff_role_sections"` for role-by-section plot-ready
  appendix handoff counts, or `"selection_bundles"` /
  `"selection_roles"` / `"selection_sections"` for preset-filtered
  appendix selection summaries.

- appendix_preset:

  Appendix preset used for `selection_*` plot types.

- selection_value:

  For `selection_*` plot types, whether to plot exact counts (`"count"`)
  or the matching exact fraction (`"fraction"`) when that surface
  exposes one. `selection_tables` remains count-only because it
  represents table row counts rather than a normalized selection
  surface.

- draw:

  If `TRUE`, draw with base graphics; otherwise return plotting data.

- main:

  Optional title override.

- palette:

  Optional named color overrides.

- label_angle:

  Axis-label rotation angle.

- ...:

  Reserved for generic compatibility.

## Value

A plotting-data object of class `mfrm_plot_data`.

## See also

[`summary.mfrm_future_branch_active_branch()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_future_branch_active_branch.md)

## Examples

``` r
if (FALSE) { # \dontrun{
spec <- build_mfrm_sim_spec(
  design = list(person = 16, rater = 3, criterion = 2, assignment = 2),
  assignment = "rotating"
)
active <- spec$planning_schema$future_branch_active_branch
plot(active, type = "readiness_tiers", draw = FALSE)
} # }
```
