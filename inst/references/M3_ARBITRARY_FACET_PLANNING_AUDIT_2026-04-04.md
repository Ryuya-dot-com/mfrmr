# M3 Arbitrary-Facet Planning Audit (2026-04-04)

## Aim

Record the source-backed boundary between:

- the `mfrmr` estimation core, which already supports arbitrary facet counts in
  ordered many-facet fitting, and
- the current simulation/planning layer, which still uses a role-based design
  contract with one person dimension and exactly two non-person roles
  (`rater`-like and `criterion`-like).

## Source-backed comparison point

Official FACETS and ConQuest materials describe flexible many-facet model
specification at the estimation level. In other words, the commercial
comparison point is not inherently limited to the package's current planning
schema.

- FACETS model-specification materials describe flexible many-facet designs and
  adjustments around raters, criteria, tasks, and related facets.
- ConQuest documentation describes model statements and automatic design-matrix
  construction, including many-facet and latent-regression settings.
- TAM documentation also exposes multi-facet fitting at the estimation level.

These sources justify a conservative distinction:

1. It is defensible for `mfrmr` to support arbitrary facets in estimation.
2. It is not defensible to imply that the current planning layer is already a
   fully arbitrary-facet planner when it still varies `n_person`, `n_rater`,
   `n_criterion`, and `raters_per_person` under a two-role descriptor.

## Current package decision

The package should expose the planning boundary explicitly instead of leaving it
implicit in prose or error messages.

The adopted contract is:

- `planner_contract = "role_based_two_non_person_facets"`
- `supports_arbitrary_facet_planning = FALSE`
- `supports_arbitrary_facet_estimation = TRUE`

This contract should travel with:

- `mfrm_sim_spec`
- `mfrm_design_evaluation`
- `summary.mfrm_design_evaluation`
- `plot.mfrm_design_evaluation(..., draw = FALSE)`
- `mfrm_design_recommendation`
- `mfrm_signal_detection`
- `summary.mfrm_signal_detection`
- `plot.mfrm_signal_detection(..., draw = FALSE)`
- `mfrm_population_prediction`
- `summary.mfrm_population_prediction`

In addition, planner-facing objects should expose spec-dependent mutability
constraints directly, because current assignment/profile/skeleton/threshold
contracts do not allow every design variable to vary in every scenario. The
implemented companion contract is `planning_constraints`, which records:

- mutable design variables
- locked design variables
- lock reasons
- the basic feasibility rule `raters_per_person <= n_rater`

To reduce drift between these parallel metadata objects, the package now also
exposes a combined `planning_schema` contract. It bundles:

- the current planner boundary (`planning_scope`)
- the role/axis descriptor (`design_descriptor`)
- the current mutable vs locked status (`planning_constraints`)
- a `facet_manifest` that lists the exposed facet labels, planning-count
  aliases, and which facets are current planner roles versus only future
  arbitrary-facet branch candidates
- a schema-only `future_facet_table` that maps those facets onto the future
  facet-count axes and stable future facet keys a later arbitrary-facet
  parser can consume
- a matching `future_design_template` that rewrites the current design into
  that same future-branch `design$facets(named counts)` stub
- a nested `future_branch_schema` that bundles that facet table, design stub,
  and assignment-axis metadata into one schema-only branch contract

This does not make the planner more general. It makes the current two-role
schema easier to consume consistently while the arbitrary-facet branch is still
separate.

The same metadata now also records:

- `future_planner_contract = "arbitrary_facet_planning_scaffold"`
- `future_planner_stage = "schema_only"`

This is deliberate. It gives downstream code a machine-readable hook for the
next planner branch while still marking the current package state as
non-arbitrary-facet at the planning layer.

The current package state also fixes a conservative future input stub:

- `future_branch_input_contract = "design$facets(named counts)"`

This is still schema-only. It does not mean the current planner can vary an
arbitrary number of non-person facets. What it now does mean is that the
current planner can already accept `design$facets(...)` for the currently
exposed facet keys and translate those keys back into the existing two-role
count variables. The same schema now also exposes the current design in that
same nested shape, so future-branch code can start from a machine-readable
stub instead of re-deriving it. That bundled stub now lives both as separate
fields and as a nested `future_branch_schema`, so future code can depend on a
single object rather than assembling it ad hoc.

The current parser path now also consumes that nested `future_branch_schema`
directly when `design$facets(...)` is supplied. This still maps back into the
current two-role planner counts, but it means the schema-only arbitrary-facet
branch already has one authoritative normalization contract.

That nested branch contract now also carries a dedicated `design_schema`
object. This is the first branch-specific object that goes beyond descriptive
metadata: it explicitly defines the future branch's facet axes, assignment
axis, accepted input keys, canonical design variables, and default nested
design stub. The current planner still maps back into two-role counts, but the
future branch no longer needs to infer its own schema from scattered fields.

The package now also has a schema-only internal grid builder that consumes
that `design_schema` object directly. It can already form canonical, public,
and branch-facing design grids from nested `design$facets(...)` input without
activating any arbitrary-facet planner logic. This keeps branch scaffolding
moving forward while preserving the current two-role public scope.

That same schema-only branch now also carries a preview contract. When a
simulation specification has concrete default counts, `planning_schema`
includes `future_branch_preview`, and the nested `future_branch_schema`
includes `preview`, each exposing the canonical/public/branch-facing default
grid implied by the current design. When only facet names are known, the
preview stays explicitly unavailable rather than inventing placeholder counts.

The same branch metadata now also carries `future_branch_grid_semantics`.
This is still schema-only, but it matters because future branch code no longer
needs to infer:

- which columns define the canonical design grid
- which columns define the public alias grid
- which columns define the branch-facing nested grid
- which feasibility rule is currently binding

from scattered helper logic. Those semantics now live beside the preview and
the nested `design_schema` as one explicit branch contract.

The same scaffolding now also exposes `future_branch_grid_contract`. This is
still not an active arbitrary-facet planner. It is the schema-only object that
actually bundles:

- the default nested design
- the materialized default branch grid when counts are available
- the nested `design_schema`
- the matching `grid_semantics`

so future branch code can depend on one object instead of stitching preview,
schema, and semantics back together.

The next low-risk refinement is now also in place: a matching internal
materializer can resolve that branch-grid contract directly from a live
planning object, a `planning_schema`, a `sim_spec`, or the contract object
itself. This does not widen scope, but it removes another source of ad hoc
fallback logic because branch code can now ask for one materialized
schema-only grid regardless of which current object happened to hold the
metadata.

That same branch path now also has a dedicated `future_branch_grid_bundle`.
This is still internal and still schema-only. The point is narrower: future
branch code no longer has to choose between "materialized grid" and
"grid-contract metadata" as separate inputs. The bundle carries:

- the canonical/public/branch-facing grid when it is available
- the underlying `grid_contract`
- the nested `design_schema`
- the matching `grid_semantics`

in one branch-side object.

The next refinement is also in place now: the package can materialize that
bundle directly from a live planning object, `planning_schema`, `sim_spec`, or
nested future-branch metadata, and branch code can request one specific grid
view (`canonical`, `public`, or `branch`) from the same helper path. This is
still not a live arbitrary-facet planner. It is an internal contract cleanup
that removes another layer of object-specific dispatch before actual branch
logic is written.

The next useful cut is also now in place: a matching internal grid-context
helper summarizes the materialized bundle into axis-level metadata. Future
branch code can now ask, from one object:

- which canonical design variables vary
- which canonical design variables are fixed
- what fixed values the non-varying axes carry
- which input keys correspond to the varying axes

This still does not activate arbitrary-facet planning. It just means the
future branch no longer needs to rediscover its own active design axes from
the raw canonical grid every time a helper needs that information.

That same context now also travels with the object graph itself. The nested
`future_branch_schema` carries `grid_context`, and the exposed
`planning_schema` carries `future_branch_grid_context`, so future branch code
can consume preview, contract, bundle, and axis context from one stable
metadata tree instead of resolving the context ad hoc from raw objects.

The first schema-only branch-side consumers are now also in place:
`future_branch_grid_summary` and `future_branch_grid_recommendation`. These do
not activate arbitrary-facet planning and do not compute any performance
criterion. Their scope is narrower and deliberate:

- summarize the currently materialized schema-only branch grid
- expose how many design rows exist and which axes vary or stay fixed
- return one deterministic lexicographic baseline pick from that grid

This is the right next step because it proves the future-branch object graph
is already useful to downstream code, while still avoiding any claim that the
package can yet optimize arbitrary-facet plans.

That branch-side consumer set now also includes a schema-only table contract
and a draw-free plotting payload. These still do not optimize anything. Their
purpose is narrower:

- expose canonical/public/branch table views with the deterministic baseline
  row marked
- expose a stable plotting payload with resolved x/group axes, fixed-axis
  subtitle text, and the baseline row marker

This matters because future arbitrary-facet branch code can now depend on the
same object graph not only for metadata and normalization, but also for the
first table/plot surfaces that branch-side summaries will eventually need.

The next schema-only consumer cut is now also in place: a branch-side report
bundle. This still does not activate arbitrary-facet planning or compute any
performance criterion. Its scope is narrower:

- bundle the current schema-only branch summary
- bundle the deterministic baseline recommendation
- bundle canonical/public/branch table views
- bundle canonical/public/branch draw-free plot payloads

This matters because future branch code can now consume one internal report
contract instead of assembling separate summary, table, and plot helpers by
hand. The contract now also travels with `future_branch_schema` and the
exposed `planning_schema`, so the object graph already supports a minimal
branch-side reporting layer before any live arbitrary-facet optimization is
opened.

That branch-side reporting layer now also has a compact report summary. This
is still schema-only and still non-optimizing. Its purpose is narrower:

- report whether the current branch-side report bundle is available
- expose the current number of design rows and the deterministic baseline id
- expose which table views and plot views are populated
- expose one component index that lists summary/recommendation/table/plot
  components in a compact form

This matters because future branch code can now discover the shape of the
branch-side reporting surface from one summary contract instead of inspecting
the raw report bundle directly. The same summary now travels with both
`future_branch_schema` and the exposed `planning_schema`.

That same reporting layer now also has a compact overview table. This is
still schema-only and still non-optimizing. Its purpose is narrower:

- expose a one-row metrics table with report availability, design count,
  baseline id, and available table/plot view counts
- expose an axis-overview table that classifies each design axis as varying,
  fixed, or unavailable
- preserve the compact component index from the report summary so branch-side
  code can still discover the report surface from one object

This matters because future branch code can now read compact metrics and
axis-state summaries from one overview contract instead of unpacking the raw
bundle and report summary separately. The same overview now travels with both
`future_branch_schema` and the exposed `planning_schema`.

That same overview layer now also has explicit overview-view consumers. This
is still schema-only and still non-optimizing. Its purpose is narrower:

- expose just the one-row metrics table when branch-side code only needs
  report availability and baseline design metadata
- expose just the axis-overview table when branch-side code only needs
  varying/fixed axis state
- expose just the compact component index when branch-side code only needs to
  discover which summary/table/plot surfaces are populated

This matters because future branch code can now request one overview surface
at a time from a single contract instead of unpacking the full overview
object for every internal reporting operation.

That same overview layer now also has a compact report catalog. This is still
schema-only and still non-optimizing. Its purpose is narrower:

- enumerate the currently exposed overview surfaces
- report whether each surface is currently available
- record the current row count and baseline design id for each surface
- bundle the already-computed overview views under one catalog contract

This matters because future branch code can now discover and select overview
surfaces from one compact catalog instead of reopening the overview contract
just to enumerate what is available.

That same report layer now also has a compact report digest. This is still
schema-only and still non-optimizing. Its purpose is narrower:

- expose the current baseline design id and design-count headline in one place
- record which overview surfaces are currently available
- summarize which canonical design axes are varying and which are fixed
- give branch-side code one headline contract before it reopens overview or
  catalog objects

This matters because future branch code can now read the current reporting
state from one digest contract before it decides whether it needs the fuller
overview or catalog surfaces.

That same report layer now also has a unified report-surface registry. This is
still schema-only and still non-optimizing. Its purpose is narrower:

- enumerate the currently exposed compact report surfaces
- bundle `digest`, `catalog`, and compact overview surfaces under one contract
- let branch-side code request one named surface from one operation
- avoid reopening multiple schema-only helper objects just to switch surfaces

This matters because future branch code can now choose one compact report
surface from one registry contract instead of stitching together digest,
catalog, and overview-view helpers by hand.

That same report layer now also has a compact report panel. This is still
schema-only and still non-optimizing. Its purpose is narrower:

- return one selected compact report surface
- keep the one-row digest headline alongside that selected surface
- preserve the shared surface index for branch-side navigation
- let branch-side code consume one surface without reopening both registry and
  digest objects

This matters because future branch code can now treat one selected report
surface as the primary payload while still carrying the headline metadata and
surface index needed for compact navigation.

That direct future-branch reporting surface now also carries the same
preset-aware appendix selection summaries used by the manuscript appendix
export bridge. This is still deterministic and still non-optimizing. Its
purpose is narrower:

- expose selected-table coverage by preset at the branch object itself
- expose the same coverage broken out by reporting role and manuscript section
- let direct branch-side plotting switch over those selection surfaces without
  writing export artifacts first

This matters because the future arbitrary-facet branch now has a more
symmetrical public reporting contract: direct `summary()` / `plot()` can read
the same appendix-preset coverage that `export_summary_appendix()` later
writes out, instead of forcing branch-side review to reconstruct those
surfaces indirectly.

That symmetry now extends to the summary-table bundle bridge itself. When
future-branch active objects are routed through `build_summary_table_bundle()`,
the resulting bundle now carries the appendix/selection metadata tables as
named workflow surfaces instead of dropping them:

- `future_branch_appendix_presets`
- `future_branch_appendix_roles`
- `future_branch_appendix_sections`
- `future_branch_selection_summary`
- `future_branch_selection_roles`
- `future_branch_selection_sections`
- `future_branch_selection_catalog`
- `future_branch_reporting_map`

These bundle-only metadata tables are intentionally marked workflow-only in
the appendix role registry, so manuscript-facing `recommended` and `compact`
presets continue to focus on the structural branch tables while full
summary/export handoffs still preserve the richer routing metadata.

The direct future-branch summary surface now reuses that finalized bundle as
its own naming reference. This means:

- `table_index` now uses the same `future_branch_*` table names as the bundle
- `table_catalog` and appendix-routing summaries are aligned to that same
  finalized bundle surface
- `plot_index` advertises not only bundle-routed appendix plots, but also
  branch-native deterministic plot routes such as `profile_metrics`,
  `load_balance`, `coverage`, `readiness_tiers`, and the preset-aware
  `selection_*` plots

This matters because branch-side review no longer has to translate between a
direct summary naming layer and a later bundle/export naming layer. The same
`future_branch_*` contract now flows through direct summary, table bundle, and
appendix export.

That same report layer now also has a combined report operation. This remains
schema-only, but it is the first helper in this branch that exposes the main
compact report surfaces from one contract:

- one-row digest headline metadata
- compact metrics / axis / component tables
- the shared surface registry
- one selected compact report surface

This matters because future branch code no longer has to choose between the
panel-oriented path and the overview-oriented path. It can now read both from
one internal operation object before arbitrary-facet planning is activated.

That same report layer now also has a lightweight report snapshot. This is
still schema-only, but unlike the combined operation object it intentionally
does not carry the deeper nested panel / registry graph:

- one-row digest headline metadata
- compact overview tables
- the selected compact report surface
- headline vectors for available surfaces and fixed/varying axes

This matters because future branch code now has two distinct contracts:
`report_operation` for internal navigation across the full compact report
layer, and `report_snapshot` for compact consumption when it only needs the
headline state and selected payload.

That same report layer now also has a selected-surface report brief. This is
still schema-only, but it is narrower than `report_snapshot` and is intended
for branch-side consumers that only need one headline table, one selected
surface, and the compact surface index:

- one-row headline table
- one selected compact report surface
- compact surface index

This matters because future branch code now has a third contract:
`report_brief` for very lightweight consumption when it does not need the
broader snapshot tables or the deeper operation graph.

That same report layer now also has a mode-based report consumer and mode
registry. This remains schema-only, but it means future branch code can ask
for one of the three report weights from one dispatcher:

- `brief`
- `snapshot`
- `operation`

This matters because branch-side code no longer needs to encode its own
dispatch rule over the compact report layer. The schema now exposes both the
available modes and one default consumer payload.

That same branch now also has an internal pilot object. This remains
schema-only and deterministic, but it is the first place where one materialized
grid view, one draw-free plot payload, and one selected report consumer are
bundled together from the future-branch contract.

This matters because the branch is no longer only exposing isolated schema
components. It now exposes one active scaffold object that consumes the current
grid and report contracts together, without yet claiming a performance-based
arbitrary-facet planner.

That pilot layer now also has compact pilot-level consumers:

- `pilot_summary`
- `pilot_table`
- `pilot_plot`

This matters because branch-side code no longer has to unpack the raw pilot
object to read the headline state, a selected table, or the draw-free plot
payload from the active scaffold.

Those pilot-level consumers are now also bundled into one active-branch
object. This remains schema-only and deterministic, but it gives the future
branch one minimal object that already behaves like a tiny planner branch:

- pilot summary
- selected table component
- draw-free plot payload

This matters because the future arbitrary-facet branch can now be consumed as
one active object rather than only as separate pilot helper calls.

That active branch now also carries a deterministic design profile. This is
still not a psychometric performance layer. It only exposes quantities that
follow directly from the current branch counts:

- total observations
- observations per person
- observations per criterion
- expected observations per rater
- assignment fraction

This matters because the active branch can now support conservative planning
bookkeeping before any performance-based arbitrary-facet simulation study is
validated.

That deterministic profile now also distinguishes metric basis explicitly:

- exact count identities
- balanced-load expectations
- density ratios

This matters because the future branch object no longer treats all profile
numbers as the same kind of evidence. The contract now says which metrics are
exact identities, which ones are balanced-load expectations, and which ones
are density ratios.

The future active branch now also has a working public-style summary/plot
surface with default-path cache reuse behind it. That matters because
`build_mfrm_sim_spec()` no longer needs to rebuild the same nested
schema-only report contracts repeatedly just to expose the active-branch
summary/table/plot consumer. The public deterministic branch surface is now
fast enough to use as a real review layer instead of only as a theoretical
schema object.
algebraic identities and which are only expectations under balanced assignment.

That deterministic layer now also has an active-branch overview contract. This
bundles:

- one compact headline table
- the metric registry
- the metric-summary table

This matters because branch-side code can now read the active scaffold in one
overview object without unpacking the profile and active-branch layers by hand.

That same deterministic layer now also has explicit load/balance diagnostics.
These do not claim psychometric precision and do not activate arbitrary-facet
planning. Their scope is narrower:

- retain balanced-load quantities only as expectations
- expose integer observation-load floor/ceiling/remainder summaries as exact
  combinatorial facts
- expose a compact indicator for whether the current observation count is
  perfectly divisible across raters

This matters because branch-side code can now distinguish mathematically exact
integer-balance summaries from balanced-assignment expectations without
re-deriving those distinctions from the raw design grid.

The same active deterministic layer now also has explicit
coverage/connectivity diagnostics. These remain purely combinatorial:

- `person_criterion_cells` and `criterion_replications_per_person` are exact
  scored-cell identities
- `rater_pair_overlap_per_cell` and `total_rater_pair_overlaps` count exact
  pair overlaps implied by the current design row
- `pair_coverage_fraction_per_cell` is an exact ratio over available rater
  pairs and is set to `0` when no rater-pair structure exists
- `redundant_scoring` is a compact exact indicator that more than one rater is
  assigned to each scored cell

This still does not activate arbitrary-facet planning. It gives branch-side
code a conservative way to reason about observation coverage and overlap
structure before any psychometric performance layer is introduced.

On top of that exact-count layer, the branch now exposes deterministic
guardrail classifications. These are still not psychometric performance
metrics. They simply classify the current design row into exact regimes such
as:

- `single_rater`, `partial_overlap`, or `fully_crossed` linking
- `no_pair_coverage`, `partial_pair_coverage`, or `full_pair_coverage`
- `integer_balanced` or `integer_unbalanced`
- `single_rater_only` or `redundant`

This matters because branch-side code can now consume one conservative design
regime surface without re-deriving those exact classifications from the lower-
level coverage and load/balance tables.

The next layer now also exposes deterministic structural-readiness summaries.
These are still not psychometric estimates. They simply report exact indicator
flags such as:

- whether multi-rater cells exist at all
- whether any within-cell rater-pair overlap exists
- whether the total observation count is integer-balanced across raters
- whether full pair coverage is present

and one exact structural tier derived from those flags. This gives branch-side
code a conservative precondition surface that is still rooted entirely in exact
design identities and classifications.

That readiness surface now feeds one conservative structural recommendation.
This still does not estimate reliability, separation, RMSE, or any other
performance quantity. It only ranks designs by:

1. exact structural tier
2. total observation count
3. remaining canonical count variables

This matters because branch-side code can now pick one minimally complex
design from the strongest exact structural tier without pretending that the
choice is psychometrically optimal.

The same schema should also drive planner-facing inputs. In the current
package state, forecast helpers, simulation-spec override helpers, manual
simulation-spec creation, and the direct simulation path now accept structured
`design = ...` inputs whose names can be:

- canonical variables such as `n_person`
- public aliases such as `n_judge` or `judge_per_person`
- role keywords such as `person`, `rater`, `criterion`, and `assignment`
- a nested schema-only future-branch stub such as
  `design = list(facets = c(person = 30, judge = 4, task = 3), assignment = 2)`

This still does not enlarge model scope. It reduces avoidable switching
between the planner's public metadata surface and its input surface.

The same input contract now also reaches the repeated-planning entry points:
`evaluate_mfrm_design()` and `evaluate_mfrm_signal_detection()` can accept
vector-valued `design = ...` grids using the same canonical names, aliases, or
role keywords. This means the current two-role planner is still limited in
scope, but its input surface is now materially more consistent across spec
creation, one-shot simulation, forecasting, and repeated design studies.

The future arbitrary-facet branch now also exposes a first compact public
surface rather than only nested schema metadata:

- `summary(planning_schema$future_branch_active_branch)` now reports
  deterministic profile, load/balance, coverage, guardrail, readiness, and
  conservative recommendation tables
- `plot(planning_schema$future_branch_active_branch, draw = FALSE)` now
  returns draw-free payloads for deterministic profile/load/coverage and
  readiness-tier views

This still does not activate psychometric arbitrary-facet planning. The new
surface is a deterministic planning-summary bridge over the existing active
scaffold.

That bridge now also reaches the current public planning summaries:

- `summary(evaluate_mfrm_design(...))`
- `summary(evaluate_mfrm_signal_detection(...))`
- `summary(predict_mfrm_population(...))`

Each now carries `future_branch_active_summary`, and the corresponding print
methods expose the deterministic overview/readiness/recommendation section
inline. This matters because users no longer need to inspect
`planning_schema$future_branch_active_branch` manually just to see the current
future-branch scaffold.

Planner internals should also consume the same descriptor contract instead of
repeating hard-coded canonical vectors. In the current package state, design
summary, recommendation, and plotting paths now derive grouping / ordering /
varying-variable choices from the shared role descriptor helpers rather than
from duplicated `c("n_person", "n_rater", "n_criterion", "raters_per_person")`
blocks.

## Practical implication

This change does not enlarge model scope. It makes existing scope visible and
machine-readable, reducing the risk that downstream helpers or user code treat
the current planner as if it were already arbitrary-facet.

## References

- FACETS overview: https://www.winsteps.com/facets.htm
- FACETS model specification: https://www.winsteps.com/facetman64/models.htm
- FACETS manual: https://www.winsteps.com/ARM/Facets-Manual.pdf
- ACER ConQuest manual: https://conquestmanual.acer.org/conquestManual.pdf
- TAM `tam.mml`: https://search.r-project.org/CRAN/refmans/TAM/html/tam.mml.html
- The future arbitrary-facet active branch is no longer confined to internal summary/plot helpers. It now enters the public reporting bridge through `build_summary_table_bundle()`, `apa_table(summary(active_branch), ...)`, and `export_summary_appendix(active_branch, ...)`, with the same `future_branch_*` table naming contract used when the scaffold is embedded in planning summaries.
- The future arbitrary-facet active branch also has explicit appendix-preset semantics. `recommended` selects structural overview/profile/readiness/recommendation tables, `compact` tightens to overview/readiness/recommendation, and detailed load/coverage/guardrail tables remain available in full exports rather than being silently mixed into conservative presets.
- The future arbitrary-facet active branch now also exposes those manuscript-routing surfaces directly at the branch level. `summary(active_branch)` carries `table_catalog`, `reporting_map`, appendix-presets, and appendix-section summaries, while `plot(active_branch, type = "appendix_sections"/"appendix_presets")` reuses the same conservative summary-table-bundle plotting contract.
- That direct branch-level reporting surface is now also appendix-role aware. `summary(active_branch)` exposes `appendix_role_summary`, and `plot(active_branch, type = "appendix_roles")` reuses the same conservative role-based appendix-routing contract as the summary-table bundle.
- The same direct branch-level reporting surface is now also table-aware. `summary(active_branch)` exposes `selection_table_summary`, `build_summary_table_bundle(active_branch)` materializes `future_branch_selection_tables`, and `plot(active_branch, type = "selection_tables", appendix_preset = ...)` surfaces the selected appendix tables themselves rather than only bundle/role/section totals.
- That direct branch-level reporting surface now also has a bundle-aware handoff layer. `summary(active_branch)` exposes `selection_handoff_bundle_summary`, `build_summary_table_bundle(active_branch)` materializes `future_branch_selection_handoff_bundles`, and `plot(active_branch, type = "selection_handoff_bundles", appendix_preset = ...)` shows plot-ready appendix handoff counts and fractions at the `Preset x AppendixSection x Bundle` level without introducing model-based heuristics.
