# M3 Summary / Reporting Audit (2026-04-06)

## Aim

Check whether the package's `summary()` methods already collect the core
information needed for manuscript reporting, and identify which reporting
domains still require companion outputs rather than one monolithic summary.

## Comparison point

Official FACETS and ConQuest materials separate reporting into multiple
surfaces rather than one omnibus printout:

- run/model specification
- sample/design structure
- fit and reliability diagnostics
- category functioning
- bias / interaction results
- formatted export or manuscript text

This means a defensible `mfrmr` contract is not "everything must live in one
summary object", but rather:

1. `summary()` should be comprehensive within each object's scope.
2. `summary()` should explicitly tell users which companion outputs complete
   the manuscript package.

## Current package state

### `summary.mfrm_fit`

Now covers:

- model / method / convergence
- fit-level information criteria
- population-model basis and coefficients
- facet, person, step, and slope overviews
- estimation settings that matter for manuscript interpretation
- a `reporting_map` that points users to the remaining companion outputs

This is an appropriate run-level entry point for the methods/results narrative.

### `summary.mfrm_diagnostics`

Now covers:

- overall fit
- precision basis and precision audit
- reliability / separation
- largest misfit rows
- flag counts
- a `reporting_map` that distinguishes what is covered here from what still
  belongs to residual-PCA, unexpected-response, displacement, subset, and
  manuscript-export outputs

This is an appropriate diagnostic entry point for fit/reliability reporting.

### `summary.mfrm_data_description`

Now covers:

- design/sample counts
- missingness
- score usage
- facet coverage
- agreement summary when available
- a `reporting_map` pointing to diagnostics for inferential fit/reliability

This is an appropriate data-structure entry point for the methods section.

### `summary.mfrm_apa_outputs`

Already covers:

- component completeness
- section coverage
- draft-contract checks
- compact text previews

This remains a draft/export completeness summary, not an inferential summary.

### `summary.mfrm_reporting_checklist`

Now covers:

- overall counts of available vs draft-ready reporting items
- section-level coverage
- priority/severity counts
- compact action rows showing what still blocks manuscript drafting

This is now the most direct summary surface for "what remains to be written or
generated?" while still remaining separate from inferential adequacy.

## Boundary that remains appropriate

The following should still stay outside one omnibus `summary(fit)` printout:

- category-functioning tables and plots
- unexpected-response and displacement listings
- bias / DIF / interaction tables
- subset-connectivity detail
- draft manuscript text

Those domains already have dedicated outputs, and keeping them separate is
closer to FACETS/ConQuest-style reporting than collapsing them into one
overloaded summary object.

## Practical conclusion

The package is now in a better state for manuscript reporting because the main
summary objects are:

- internally more comprehensive, and
- explicit about what they do **not** cover.

The next useful refinement is not "make `summary()` even bigger" by default,
but to expose optional summary-to-table and summary-to-plot bridges so users
can materialize the companion reporting tables and QC views more directly when
writing manuscripts.

That bridge is now stronger for the future arbitrary-facet planning branch as
well. Direct `summary(active_branch)` exposes both aggregated
`selection_table_summary` and preset-specific `selection_table_preset_summary`,
while `build_summary_table_bundle(active_branch)` materializes the matching
workflow-only `future_branch_selection_table_presets` surface for appendix
preset review without promoting it into conservative manuscript presets.

It now also exposes a section-aware `selection_handoff_summary`, so the future
branch can show not just which tables survive each preset, but which
methods/results/diagnostics/reporting section they feed. The matching
workflow-only `future_branch_selection_handoff` bundle table keeps that
handoff contract visible without forcing it into compact appendix presets.

## Follow-up now implemented for arbitrary-facet planning

The direct future arbitrary-facet active-branch summary now exposes the same
appendix-selection surfaces used by `export_summary_appendix()`:

- `selection_summary`
- `selection_role_summary`
- `selection_section_summary`
- `selection_catalog`

This means the future-branch scaffold no longer needs to route through export
objects just to inspect preset-aware appendix coverage.

Its direct `plot()` surface is now aligned to that same contract via:

- `type = "selection_bundles"`
- `type = "selection_roles"`
- `type = "selection_sections"`
- `appendix_preset = "all" / "recommended" / "compact" / "methods" /
  "results" / "diagnostics" / "reporting"`

So the package now supports a more symmetric manuscript workflow:

1. `summary(active_branch)` to inspect structural and appendix-selection
   coverage.
2. `plot(active_branch, type = ..., appendix_preset = ...)` to inspect the
   same selection surfaces visually.
3. `build_summary_table_bundle(active_branch)` and
   `export_summary_appendix(active_branch, ...)` when manuscript artifacts
   should actually be materialized.

That bundle bridge now also materializes the future-branch appendix/selection
metadata tables themselves:

- `future_branch_appendix_presets`
- `future_branch_appendix_roles`
- `future_branch_appendix_sections`
- `future_branch_selection_summary`
- `future_branch_selection_roles`
- `future_branch_selection_sections`
- `future_branch_selection_catalog`
- `future_branch_reporting_map`

These are intentionally classified as workflow-only surfaces in the appendix
role registry, so they stay available in full bundle/export handoffs without
silently leaking into the conservative `recommended` or `compact` presets.

The direct future-branch summary now uses that same finalized bundle surface
as the source of truth for its own `table_index`, `plot_index`, and
`table_catalog`. Its `plot_index` is also augmented with branch-native plot
routes such as:

- `profile_metrics`
- `load_balance`
- `coverage`
- `readiness_tiers`
- `selection_bundles`
- `selection_roles`
- `selection_sections`

So the direct future-branch object now reports not only which tables exist,
but also which branch-native plot surfaces are attached to those tables under
the same `future_branch_*` naming contract used by the summary-table bundle.

## Follow-up now implemented

`build_summary_table_bundle()` now provides that bridge for the validated core
summary surfaces:

- `summary(fit)`
- `summary(diagnose_mfrm(...))`
- `summary(describe_mfrm_data(...))`
- `summary(reporting_checklist(...))`
- `summary(build_apa_outputs(...))`

This keeps the package aligned with FACETS/ConQuest-style separation of
reporting layers while still giving manuscript workflows a direct path from
compact `summary()` objects to named tables.

That bridge is now no longer table-only. `mfrm_summary_table_bundle` also has:

- `summary(bundle)` for role-level and numeric-content coverage
- `summary(bundle)$table_catalog` for a complete returned-table registry with
  APA/export/plot bridges
- `plot(bundle, type = "table_rows")` for table-mass checks
- `plot(bundle, type = "numeric_profile" / "first_numeric")` for numeric QC
  routed through the same conservative logic used by `plot(apa_table(...))`

It now also has an export-side continuation:

- `export_mfrm_bundle(..., include = "summary_tables")`
- `export_summary_appendix(...)`

which writes bundle-level indexes and selected manuscript tables to disk, and
can include them in the lightweight HTML bundle or a narrow appendix-only HTML
handoff.

`summary(bundle)` now also carries a `reporting_map`, so the bundle summary
itself tells users how to move from compact manuscript-ready tables to quick
plots, APA formatting, and export handoff.

The narrow appendix bridge is now explicit: users no longer need to route
everything through a fit-based bundle just to export validated summary tables.

That appendix bridge is now also role-aware rather than all-or-nothing:

- `summary(bundle)$table_catalog` now records `RecommendedAppendix`,
  `CompactAppendix`, `PreferredAppendixOrder`, and `AppendixRationale`
- `summary(bundle)$appendix_presets` now exposes conservative `all`,
  `recommended`, and `compact` appendix routes
- `export_summary_appendix(..., preset = "recommended" / "compact")` now
  records `selection_summary` and `selection_catalog`, so appendix exports
  explicitly document what was selected and what was left out

This matters because manuscript appendix handoff is not the same task as
workflow QA. Bundle-level `reporting_map` surfaces still travel with the
export object, but source-level bridge-only or preview-only tables can now be
excluded by a public preset while remaining visible in the selection catalog.

That selection contract now starts earlier in the workflow as well:

- `build_summary_table_bundle(..., appendix_preset = "recommended" /
  "compact")` applies the same conservative appendix routes at bundle
  construction time
- `summary(bundle)` carries the active `AppendixPreset` in `overview`
- `plot(bundle, type = "role_tables")` and
  `plot(bundle, type = "appendix_presets")` let users inspect role coverage
  and appendix-route size before any APA or export handoff

This is a better manuscript-facing contract than making appendix selection a
purely export-time decision, because the same conservative subset can now be
reviewed through summary, plot, and export surfaces without changing object
classes mid-workflow.

That contract is now also section-aware rather than only route-aware:

- `summary(bundle)$table_catalog` now records `AppendixSection`
- `summary(bundle)$appendix_section_summary` now reports methods/results/
  diagnostics/reporting coverage directly
- `plot(bundle, type = "appendix_sections")` now visualizes that section
  coverage without leaving the bundle-level summary surface
- `build_summary_table_bundle(..., appendix_preset = "methods" / "results" /
  "diagnostics" / "reporting")` now applies manuscript-section subsets at
  bundle construction time
- `export_summary_appendix(..., preset = "methods" / "results" /
  "diagnostics" / "reporting")` now carries the same section-aware selection
  contract into the appendix export object

This matters because manuscript appendix review is not only about how much to
show, but also about which section of the paper a table actually supports. A
compact bundle can now answer both questions before export.

The export-side objects themselves now have a cleaner summary contract:

- `summary(export_mfrm_bundle(...))` foregrounds written-file inventory and
  bundle settings rather than falling back to a generic bundle preview
- `summary(export_summary_appendix(...))` does the same for appendix-only
  handoff objects
- summary-table export writing now treats `overview` and `reporting_map` as
  dedicated summary surfaces, so they are emitted once rather than duplicated
  through the raw table loop

Those export-side summaries now also expose:

- `format_summary` for file-type counts
- `artifact_catalog` for component-by-component handoff inventory
- `reporting_map` for the next bridge (`HTML`, appendix CSVs, replay/archive)

so the export objects themselves can serve as compact handoff summaries rather
than only as opaque file-write results.

The same layer now has a conservative plot bridge as well:

- `plot(export_mfrm_bundle(...), type = "formats", draw = FALSE)`
- `plot(export_mfrm_bundle(...), type = "artifact_groups", draw = FALSE)`
- `plot(export_summary_appendix(...), type = "formats", draw = FALSE)`

That appendix-export bridge is now more explicit about manuscript routing:

- `summary(export_summary_appendix(...))` now exposes
  `selection_role_summary` and `selection_section_summary`
- `plot(export_summary_appendix(...), type = "selection_sections",
  draw = FALSE)` now visualizes manuscript-section coverage directly
- `plot(export_summary_appendix(...), type = "selection_roles", draw = FALSE)`
  remains available for role coverage within the selected appendix subset

These plots stay at the export-contract level. They visualize file-type and
artifact-group counts, not psychometric content, which keeps them theoretically
clean while still making handoff state easier to inspect.

That same summary-to-table bridge now extends to the validated planning
surfaces as well:

- `summary(evaluate_mfrm_design(...))`
- `summary(evaluate_mfrm_signal_detection(...))`
- `summary(predict_mfrm_population(...))`

Each of those summaries now embeds a compact deterministic future arbitrary-
facet planning section under `future_branch_active_summary`, and
`build_summary_table_bundle()` can materialize both the ordinary planning
tables and the embedded future-branch structural tables from the same summary
contract.

This matters because the package no longer forces a split between "current
planning result summary" and "future arbitrary-facet structural scaffold" at
the public-summary layer. Users can now review current Monte Carlo / forecast
outputs together with the conservative future-branch scaffold before moving to
APA or export handoff.

## Sources

- FACETS Manual: reporting surfaces for measures, fit, categories, and bias
- ACER ConQuest Manual: separation of model specification, diagnostics, and
  reporting tables
- `mfrmr` internal reporting helpers:
  - `reporting_checklist()`
  - `build_apa_outputs()`
  - `category_structure_report()`
  - `category_curves_report()`
  - `unexpected_response_table()`
  - `displacement_table()`
- `summary -> table -> APA/export` now also covers the future arbitrary-facet active branch itself. `build_summary_table_bundle()` accepts both `planning_schema$future_branch_active_branch` and `summary.mfrm_future_branch_active_branch`, preserving the `future_branch_*` table names already used by planning summaries, and `apa_table()` accepts the summary form directly.
- `export_summary_appendix()` was tightened to normalize single classed summary/report objects before generic named-list handling. This closes a real gap where direct future-branch active objects were previously misread as collections and could not be exported cleanly.
- Appendix preset semantics now explicitly cover the future arbitrary-facet active branch. `recommended` retains the structural overview/profile/readiness/recommendation surfaces, while `compact` keeps only the most conservative structural core and leaves detailed load/coverage/guardrail diagnostics to full exports.
- The future arbitrary-facet active branch no longer needs `build_summary_table_bundle()` as an intermediate just to review manuscript-facing routing metadata. `summary(active_branch)` now carries the same `table_catalog`, `reporting_map`, appendix-presets, appendix-section summaries, and `plot(active_branch, type = "appendix_sections"/"appendix_presets")` surfaces directly.
- The same bridge is now role-aware at the appendix-routing layer. `summary.mfrm_summary_table_bundle()` and `summary(active_branch)` both expose `appendix_role_summary`, and `plot(..., type = "appendix_roles")` now shows how conservative appendix routing changes table counts by reporting role before export.
- That direct future-branch bridge is now table-aware as well. `summary(active_branch)` exposes `selection_table_summary`, `build_summary_table_bundle(active_branch)` materializes `future_branch_selection_tables`, and `plot(active_branch, type = "selection_tables", appendix_preset = ...)` lets users inspect which selected appendix tables remain and how large they are before export.
- The appendix-export bridge now matches that same table-level selection surface. `export_summary_appendix()` writes `appendix_selection_table_summary`, `summary(export_summary_appendix(...))` exposes it directly, and `plot(export_summary_appendix(...), type = "selection_tables")` lets export-side QC stay aligned with the branch-side appendix-selection contract.
- That section-aware future-branch handoff surface now reaches the export bridge too. `export_summary_appendix()` writes `appendix_selection_handoff_summary`, `summary(export_summary_appendix(...))` prints it directly, and both `plot(export_summary_appendix(...), type = "selection_handoff")` and `plot(active_branch, type = "selection_handoff")` now expose plot-ready handoff counts by manuscript appendix section.
- The summary-table bundle layer now understands those same workflow-only appendix selection surfaces. `summary(build_summary_table_bundle(active_branch))` exposes `selection_table_summary`, `selection_handoff_summary`, `selection_role_summary`, and `selection_section_summary`, and `plot.mfrm_summary_table_bundle()` now supports preset-filtered `selection_tables`, `selection_handoff`, `selection_roles`, and `selection_sections` views.
- A preset-level handoff overview now sits above that section-aware surface. Direct future-branch summaries, summary-table bundles, and appendix exports all expose `selection_handoff_preset_summary`, and `plot(..., type = "selection_handoff_presets")` now shows plot-ready appendix handoff counts aggregated at the preset level before dropping to section-specific review.
- That handoff surface is now role-aware as well. Direct future-branch summaries, summary-table bundles, and appendix exports all expose `selection_handoff_role_summary`, and `plot(..., type = "selection_handoff_roles")` now shows plot-ready appendix handoff counts by reporting role before manuscript/export handoff.
- That same handoff surface now has a role-by-section crosswalk. Direct future-branch summaries, summary-table bundles, and appendix exports all expose `selection_handoff_role_section_summary`, and `plot(..., type = "selection_handoff_role_sections")` shows plot-ready appendix handoff counts at the `AppendixSection x Role` level without widening the mathematical scope beyond exact selection-catalog aggregation.
- That exact handoff layer now also has a table-level crosswalk. Direct future-branch summaries, summary-table bundles, and appendix exports all expose `selection_handoff_table_summary`, preserving `Preset x AppendixSection x Role x Bundle x Table` routing metadata for manuscript appendix handoff while staying entirely inside the already-materialized selection catalog.
- That same exact handoff layer now also has a bundle-aware aggregation.
  Direct future-branch summaries, summary-table bundles, and appendix exports
  all expose `selection_handoff_bundle_summary`, and
  `plot(..., type = "selection_handoff_bundles")` now shows plot-ready
  appendix handoff counts and fractions at the `Preset x AppendixSection x
  Bundle` level before dropping to the table-level crosswalk.
- Those workflow-only appendix-selection surfaces now also expose exact ratio
  columns alongside raw counts. `SelectionFraction`, `PlotReadyFraction`, and
  `NumericFraction` are computed only from already-materialized selection
  catalogs, so the added density stays strictly combinatorial and does not
  introduce performance heuristics.
- The matching plot surfaces now read those exact ratios directly.
  `plot.mfrm_summary_table_bundle()`,
  `plot.mfrm_future_branch_active_branch()`, and
  `plot(export_summary_appendix(...), type = "selection_*")` now accept
  `selection_value = "count"` / `"fraction"` wherever the underlying
  selection table exposes a mathematically exact ratio. The only deliberate
  exception is `selection_tables`, which remains count-only because it plots
  raw table row counts rather than a normalized selection surface.
- The direct future-branch summary is now closer to the summary-table-bundle surface as well. `summary(active_branch)` exposes `role_summary`, `table_profile`, and overview-level counts for appendix-ready and numeric tables, so branch-side review no longer has to route through `build_summary_table_bundle()` just to inspect table shape and reporting-role coverage.
