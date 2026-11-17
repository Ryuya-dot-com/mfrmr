# Build a manuscript-oriented table bundle from `summary()` outputs

Build a manuscript-oriented table bundle from
[`summary()`](https://rdrr.io/r/base/summary.html) outputs

Summarize report/table bundles in a user-friendly format

Plot report/table bundles with ggplot2

## Usage

``` r
build_summary_table_bundle(
  x,
  which = NULL,
  appendix_preset = NULL,
  include_empty = FALSE,
  digits = 3,
  top_n = 10,
  preview_chars = 160
)

# S3 method for class 'mfrm_bundle'
summary(object, digits = 3, top_n = 10, include_person = FALSE, ...)

# S3 method for class 'mfrm_bundle'
plot(x, y = NULL, type = NULL, ...)

# S3 method for class 'mfrm_summary_table_bundle'
summary(object, digits = 3, top_n = 8, ...)

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

  A bundle object returned by mfrmr table/report helpers.

- which:

  For `build_summary_table_bundle()`: Optional character vector
  selecting a subset of named tables.

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Optional
  table selector used for numeric plot types.

- appendix_preset:

  For `build_summary_table_bundle()`: Optional appendix-oriented table
  preset: `"all"`, `"recommended"`, `"compact"`, `"methods"`,
  `"results"`, `"diagnostics"`, or `"reporting"`. Cannot be combined
  with `which`. Section-aware presets keep returned tables whose bundle
  catalog maps to the requested appendix section.

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Appendix
  preset used for `selection_*` plot types.

- include_empty:

  If `TRUE`, retain empty tables in the returned bundle.

- digits:

  Number of digits for printed numeric values.

- top_n:

  Number of preview rows shown from the main table component.

- preview_chars:

  Character cap forwarded to
  [`summary.mfrm_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  when `x` is a raw APA-output object.

- object:

  Output from `build_summary_table_bundle()`.

- include_person:

  If `TRUE`, person-level identifiers may appear in supported summary
  and preview tables. The default suppresses identifier columns,
  person-facet level labels, and ConQuest case labels from the returned
  summary object and its console output. This does not alter the source
  bundle.

- ...:

  Reserved for generic compatibility.

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

- selection_value:

  For `selection_*` plot types, whether to plot exact counts (`"count"`)
  or the corresponding exact fraction (`"fraction"`) when that surface
  exposes one.

- main:

  Optional title override.

- palette:

  Optional named color overrides.

- label_angle:

  Axis-label rotation angle for bar-type plots.

- draw:

  If `TRUE`, display the returned ggplot.

## Value

An object of class `mfrm_summary_table_bundle` with:

- `overview`

- `table_index`

- `plot_index`

- `tables`

- `appendix_preset`

- `notes`

- `source_class`

- `summary_class`

An object of class `summary.mfrm_bundle`.

A `ggplot` object (invisibly), carrying the underlying `mfrm_plot_data`
payload accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).

For [`summary()`](https://rdrr.io/r/base/summary.html): An object of
class `summary.mfrm_summary_table_bundle`.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object carrying its saved plot payload accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).

## Details

Collects named data frames from supported `mfrmr` objects or their
[`summary()`](https://rdrr.io/r/base/summary.html) outputs into
`tables`, indexed by `table_index` (dimensions, appendix roles,
descriptions) and `plot_index` (numeric views). G-study, D-study,
D-study comparison, residual-network, and
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
inputs retain complete signed/unavailable evidence rows without `top_n`
truncation, while fit, diagnostics, recovery, calibration, and
model-choice summaries preserve their role-classified caveat,
`reading_order`, `population_coding`, and df-sensitivity tables for
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
and
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md).

This method provides a compact summary for bundle-like outputs (for
example: unexpected-response, fair-average, chi-square, and category
report objects). It extracts:

- object class and available components

- one-row summary table when available

- preview rows from the main data component

- resolved settings/options

Branch-aware summaries are provided for:

- `mfrm_bias_count` (`branch = "original"` / `"facets"`)

- `mfrm_fixed_reports` (`branch = "original"` / `"facets"`)

- `mfrm_visual_summaries` (`branch = "original"` / `"facets"`)

Additional class-aware summaries are provided for:

- `mfrm_unexpected`, `mfrm_fair_average`, `mfrm_displacement`

- `mfrm_interrater`, `mfrm_facets_chisq`, `mfrm_bias_interaction`

- `mfrm_rating_scale`, `mfrm_category_structure`, `mfrm_category_curves`

- `mfrm_measurable`, `mfrm_unexpected_after_bias`, `mfrm_output_bundle`

- `mfrm_residual_pca`, `mfrm_specifications`, `mfrm_data_quality`,
  `mfrm_fit_measures`

- `mfrm_iteration_report`, `mfrm_subset_connectivity`,
  `mfrm_facet_statistics`

- `mfrm_facets_contract_review`, `mfrm_facets_fit_review`,
  `mfrm_facets_fit_df_guide`, `mfrm_reference_benchmark`

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) dispatches by
bundle class:

- `mfrm_unexpected` -\> [plot(x, type =
  "unexpected")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

- `mfrm_fair_average` -\> [plot(x, type =
  "fair_average")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

- `mfrm_displacement` -\> [plot(x, type =
  "displacement")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

- `mfrm_interrater` -\> [plot(x, type =
  "agreement")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

- `mfrm_facets_chisq` -\> [plot(x, type =
  "facets_chisq")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

- `mfrm_bias_interaction` -\> [plot(x, type =
  "bias")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

- `mfrm_bias_count` -\> bias-count plots (cell counts / low-count rates)

- `mfrm_fixed_reports` -\> pairwise-contrast diagnostics

- `mfrm_visual_summaries` -\> warning/summary message count plots

- `mfrm_category_structure` -\> category count and boundary plots

- `mfrm_category_curves` -\> overview (default), ogive, CCC / category
  probability / conditional probability, cumulative, total-information,
  and category-specific-information plots

- `mfrm_rating_scale` -\> category-counts/threshold plots

- `mfrm_measurable` -\> measurable-data coverage/count plots

- `mfrm_unexpected_after_bias` -\> post-bias unexpected-response plots

- `mfrm_output_bundle` -\> graph/score output-file diagnostics,
  including `type = "score_se"` when scorefile SE columns are available

- `mfrm_residual_pca` -\> residual PCA scree, parallel-analysis, or
  loadings views via [plot(x, type =
  "residual_pca")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

- `mfrm_specifications` -\> facet/anchor/convergence plots

- `mfrm_data_quality` -\> dashboard, quality-flag, score-map,
  facet-pattern, and row/category/missing-row plots

- `mfrm_facets_fit_review` -\> FACETS-style df-sensitivity plot

- `mfrm_fit_measures` -\> fit-status counts, Infit/Outfit scatter,
  measure normal bands, and FACETS-style df-sensitivity plots. For
  `type = "measure_ci"`, the caption retains the source interval
  interpretation (including exploratory JML bands); fixed values use
  open diamonds and finite estimates without intervals use crosses.
  `main = ""` omits the title and `show_notes = FALSE` hides the caption
  without removing it from saved data. Changing `ci_level` does not
  change inferential eligibility. See
  [`fit_measures_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_measures_table.md).

- `mfrm_iteration_report` -\> replayed-iteration trajectories

- `mfrm_subset_connectivity` -\> subset-observation/connectivity plots

- `mfrm_facet_statistics` -\> facet statistic profile plots

- `mfrm_export_bundle` / `mfrm_summary_appendix_export` -\> export
  handoff plots (`formats`, `artifact_groups`, `selection_tables`,
  `selection_handoff`, `selection_handoff_bundles`,
  `selection_handoff_roles`, `selection_handoff_role_sections`,
  `selection_bundles`, `selection_roles`, `selection_sections`)

If a class is outside these families, use dedicated plotting helpers or
custom `ggplot2` graphics on component tables.

For `mfrm_category_curves`, pass `preset = "monochrome"` for
grayscale/line-type output. Cumulative `.5` boundary lines are shown
only for interpretable in-range boundaries by default; use
`boundary_status = "all"` to show every finite boundary estimate or
`boundary_status = "none"` / `show_cumulative_boundaries = FALSE` to
suppress those vertical boundary lines. Use
`plot_data(x, component = "plot_long")` on a category-curve bundle when
you want one ggplot2/plotly-friendly table across all curve families.
Keep curve families and groups separate in custom figures. All
category-curve, category-structure, rating-scale, and network bundle
views render natively via `ggplot2`. Step displays use point estimates
and do not turn stored step SEs into crossing, gap or curve intervals.

[`summary()`](https://rdrr.io/r/base/summary.html) method: Summarize a
summary-table bundle for manuscript QC

For [`summary()`](https://rdrr.io/r/base/summary.html): Review
returned-table coverage, dimensions, roles and numeric content before
plotting or export.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot a
summary-table bundle for manuscript QC

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html):
Table-count views describe reporting coverage, not study sample sizes.
`selection_*` views use appendix selections already retained in the
bundle; `"selection_handoff_role_sections"` groups them by reporting
role and appendix section. Numeric views pass the selected table through
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
and
[`plot.apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
for exploratory checks. See `type` for each view and `selection_value`
for counts versus fractions.

## Interpreting output

- `overview`: class, component count, and selected preview component.

- `summary`: one-row aggregate block when supplied by the bundle.

- `preview`: first `top_n` rows from the main table-like component.

- `settings`: resolved option values if available.

- `validation_scope`: package-generated versus independently supplied
  evidence scope when summarizing `mfrm_reference_benchmark`.

- `conquest_command_scope`: ConQuest command-template scope when
  summarizing `mfrm_conquest_overlap_bundle`.

- `conquest_output_contract`: requested ConQuest outputs and review
  handoff when summarizing `mfrm_conquest_overlap_bundle`.

- `mfrmr_fit_status`: actual optimizer controls, MML engine, convergence
  evidence, and inference-readiness state for an
  `mfrm_conquest_overlap_bundle`.

- `normalization_scope`: extracted-table normalization scope when
  summarizing `mfrm_conquest_overlap_tables`.

- `review_scope`: supplied-table review scope when summarizing
  `mfrm_conquest_overlap_review`.

- `conquest_overlap_checks` / `population_policy_checks`: specialized
  benchmark check previews when summarizing `mfrm_reference_benchmark`.

The returned object is a `ggplot` object whose underlying plot payload
and notes remain accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
and
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md);
set `draw = TRUE` for immediate display.

For [`summary()`](https://rdrr.io/r/base/summary.html):

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

- When workflow appendix tables are present,
  `selection_handoff_table_summary`, `selection_handoff_preset_summary`,
  `selection_handoff_bundle_summary`, `selection_handoff_role_summary`
  and `selection_handoff_role_section_summary` describe export
  selections by table, preset, bundle-by-section, reporting role and
  role-by-section, respectively.

- `selection_summary`, `selection_table_summary`,
  `selection_table_preset_summary`, `selection_role_summary`,
  `selection_section_summary` and `selection_catalog` describe the
  preset-filtered selections from those workflow tables.

- `reporting_map`: where to go next for plotting, APA formatting, and
  export.

- `notes`: carried forward source-level caveats from the originating
  summary.

## Typical workflow

1.  Generate a bundle table/report helper output.

2.  Run `summary(bundle)` for compact QA.

3.  Drill into specific components via `$` and visualize with
    `plot(bundle, ...)`.

&nbsp;

1.  Create bundle output (e.g.,
    [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md)).

2.  Inspect routing with `summary(bundle)` if needed.

3.  Call `p <- plot(bundle, type = ..., draw = FALSE)` and inspect
    `plot_data(p)` when needed.

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## Network display controls

For subset, design, rater and halo bundles with `type = "network"`, use
`layout` (a two-column coordinate matrix, optionally row-named by all
node IDs, or a function of the displayed igraph), `display_min_weight`
(absolute edge weight for the picture only), and `graphical` for
supported compatibility controls: `vertex.label` and the first positive
`vertex.size` value. Other igraph styling controls are not applied by
the ggplot renderer; customize the returned ggplot instead. Unnamed
vectors and coordinates follow the returned `nodes` order. All nodes,
including isolates, remain. The default layout is a deterministic
circle; positions do not estimate anything. Labels are hidden by default
above 80 nodes; set vertex.label explicitly to override. Supply the same
named layout to compare views. Constructor filters such as `min_weight`
change calculated metrics; `display_min_weight` does not. Returned
`source_edges` retain the calculated graph, `edges` the displayed graph,
and `coordinates` the actual positions. Titles are metadata by default;
add displayed text with
[`ggplot2::labs()`](https://ggplot2.tidyverse.org/reference/labs.html).
See [online networks and reporting
guide](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-networks-and-reporting.html)
for bipartite assignment, directional disagreement and
rater-by-criterion examples inspired by Lamprianou. With
[`rater_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_network_analysis.md)
and `weight_metric = "DirectionalMagnitude"`,
`type = "fit", metric = "SWS"` (or `"PUS"`) shows the published network
inconsistency index. The returned table retains unavailable
rows/statuses; there are no calibrated reference cutoffs. An entirely
unavailable index draws an unavailable message and retains the original
rows/statuses in the returned table, rather than substituting zero. For
signed alpha, `type = "matrix"` returns all eligible signed pair
coefficients before graph filtering, retaining zero and undefined values
separately. Network drawings use magnitude for edge width and dashed
lines for negative agreement. Use
[`plot.mfrm_network_ergm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_rater_network.md)
for ERGM coefficient intervals and simulated GOF.

## See also

[`base::summary()`](https://rdrr.io/r/base/summary.html),
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
[mfrm_report_checklist](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md),
[`build_model_choice_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_model_choice_review.md),
[`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)

[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
[`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html)

[`summary()`](https://rdrr.io/r/base/summary.html), [plot(x, type =
"unexpected")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[plot(x, type =
"fair_average")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[plot(x, type =
"displacement")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

`build_summary_table_bundle()`,
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html)

`build_summary_table_bundle()`,
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
[`plot.apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
# example("build_summary_table_bundle", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
bundle <- build_summary_table_bundle(fit)
bundle$table_index
summary(bundle)$role_summary

} # }
# Long-running workflow; run explicitly when needed.
# example("summary.mfrm_bundle", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy_full <- load_mfrmr_data("example_core")
toy_people <- unique(toy_full$Person)[1:12]
toy <- toy_full[toy_full$Person %in% toy_people, , drop = FALSE]
fit <- suppressWarnings(
  fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
)
t4 <- unexpected_response_table(fit, abs_z_min = 1.5, prob_max = 0.4, top_n = 5)
summary(t4)
diag <- diagnose_mfrm(fit, residual_pca = "none")
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 2)
t11 <- bias_count_table(bias, branch = "facets")
summary(t11)
} # }
# Long-running workflow; run explicitly when needed.
# example("plot.mfrm_bundle", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy_full <- load_mfrmr_data("example_core")
toy_people <- unique(toy_full$Person)[1:12]
toy <- toy_full[toy_full$Person %in% toy_people, , drop = FALSE]
fit <- suppressWarnings(
  fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
)
t4 <- unexpected_response_table(fit, abs_z_min = 1.5, prob_max = 0.4, top_n = 5)
p <- plot(t4, draw = FALSE)
vis <- build_visual_summaries(fit, diagnose_mfrm(fit, residual_pca = "none"))
p_vis <- plot(vis, type = "comparison", draw = FALSE)
spec <- mfrm_report(type = "specifications", fit)
p_spec <- plot(spec, type = "facet_elements", draw = FALSE)
if (interactive()) {
  plot(
    t4,
    type = "severity",
    draw = TRUE,
    main = "Unexpected Response Severity (Customized)",
    palette = c(higher = "#d95f02", lower = "#1b9e77", bar = "#2b8cbe"),
    label_angle = 45
  )
  plot(
    vis,
    type = "comparison",
    draw = TRUE,
    main = "Warning vs Summary Counts (Customized)",
    palette = c(warning = "#cb181d", summary = "#3182bd"),
    label_angle = 45
  )
}
} # }
# Optional workflow; run the example explicitly as shown below.
# example("summary.mfrm_summary_table_bundle", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
bundle <- build_summary_table_bundle(fit)
summary(bundle)
} # }
# Optional workflow; run the example explicitly as shown below.
# example("plot.mfrm_summary_table_bundle", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
bundle <- build_summary_table_bundle(fit)
plot(bundle, draw = FALSE)
plot(bundle, type = "numeric_profile", which = "facet_overview", draw = FALSE)
} # }
```
