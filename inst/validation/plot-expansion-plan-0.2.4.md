# Question-led visualization expansion — 2026-09-10

Status: source audit and implementation plan, followed by the
[first graph repair](equating-graph-record-0.2.4.md) on 2026-09-10. That repair
covers isolated/empty waves, pair-specific screening and identity, returned
notes and display controls in the existing bipartite view. The subsequent
[topology follow-up](equating-topology-record-0.2.4.md) adds the compact
administration-link view and single-element graph deletion audit. The
[conditional offset follow-up](offset-sensitivity-record-0.2.4.md) now recomputes
screened linking offsets while holding source estimates and SEs fixed. Full
model refits, uncertainty calculations and the other proposed views remain
future work.
The [paired-model follow-up](plot-comparison-record-0.2.4.md) now adds Wright
distribution/location comparisons and CCC overlays/differences for two fits,
using recorded compatible bases and explicit step-group selection.
The initial audit below is preserved as historical evidence.

## User decision and existing foundation

The priority question is: **which administrations are connected by which
anchors, and which comparisons become vulnerable if an anchor is unavailable
or excluded?** For example, two forms may share several linking elements while
a third form depends on one element. A common-element count alone obscures
that dependency.

The package already extends beyond Wright/CCC displays:

| Question | Existing route | Proposed improvement |
| --- | --- | --- |
| Who observed whom, and where is the design fragile? | `subset_connectivity_report()`, `mfrm_network_analysis()`, `build_mfrm_network_review()`; network, matrix, centrality and facet summaries | Link graph selection to the incidence matrix and cut-node/edge tables; disclose the graph definition and filters |
| Which administrations share linking elements? | `build_equating_chain()` and `plot(chain, type = "graph")` / `type = "links"` | Isolated waves and pair-specific screening are now retained; dense displays still need panels or larger devices |
| What changes when one anchor is removed? | `type = "anchor_removal"` returns graph deletion results; `type = "offset_sensitivity"` recomputes conditional linking offsets | Full refits and uncertainty need a specified intervention; topology holds screening fixed, while conditional offset sensitivity reruns it |
| Where do estimation methods disagree? | Aligned estimate, difference and uncertainty tables from existing comparisons | A difference-versus-mean view alongside identity-line scatterplots; align scale, estimand and estimator conventions first |
| Where is there residual structure? | Residual matrices, local-dependence heatmaps, residual PCA, rater and halo networks | Coordinated clustered matrix/network views using a named residual statistic and explicit edge-selection rule |
| Are changes over time or subgroup differences consequential? | `plot_rater_trajectory()`, `plot_anchor_drift()`, fit/SE and facet-equivalence displays | Linked trajectory and interval views; retain common-scale conditions and supported uncertainty, rather than unexplained control limits |

This adopts useful visual forms from graph analysis, method-comparison studies,
quality monitoring and uncertainty reporting. It does not require adding a new
estimator or dependency for each visual form. Existing tables and optional
`igraph` should be reused first; external renderers can consume returned data.

## Keep the network definitions distinct

1. **Observed design network:** person/facet levels joined by co-observation.
   Edge weights count observations. Components, articulation points and bridges
   describe the chosen graph, not parameter precision or rater quality.
2. **Common-element linking network:** administrations joined by reviewed
   comparisons; a companion administration-by-element view explains their
   support. Common element identities are candidate linking evidence, not proof
   that parameters were fixed to externally calibrated anchor values.
3. **Declared anchor/constraint network:** an explicit view of supplied fixed
   values and group constraints. This needs verified anchor provenance and
   parameter identities. A group-mean constraint must not be displayed as
   independent fixed values for every member.
4. **Residual or score-relation network:** edges represent an explicitly named
   association statistic. Such edges do not establish assignment connectedness,
   a causal relation, or common-scale equivalence.

Graph connectedness is one piece of a model-specific design audit. Parameter
identification, scale/category compatibility, anchor drift, and estimation
uncertainty still need their own checks. Neither a high centrality score nor
a visually dense graph licenses substantive inference.

## Confirmed limitations before the first repair

At the initial audit, `plot.mfrm_equating_chain(type = "graph")` constructed its
edges from the common-element `element_detail` table. That source:

- does not transfer `Retained` or `Flag` to its edge table;
- constructs wave vertices from observed edges instead of the full declared
  wave set, so isolated waves disappear;
- errors when there are no common-element rows, rather than showing the
  disconnected administrations;
- uses adjacent links produced by `build_equating_chain()`; the graph must not
  be presented as an exhaustive all-pairs link assessment;
- derives anchor IDs and link endpoints from concatenated display strings,
  which needs review for label collisions and delimiters;
- has not inherited the new fit-family title/note controls or returned notes
  contract. Those controls must not yet be advertised for this graph route.

The [read-only probe](plot-expansion-0.2.4/probe.R) constructed an explicit
three-wave chain with one excluded common element in A–B and no B–C support.
The audited graph returned only two waves and two edges, without retained/flag
columns. A zero-common-element case raised the graph-input error. These are
synthetic graph-contract checks, not empirical psychometric results. See the
[observations](plot-expansion-0.2.4/probe.csv) and
[execution log](plot-expansion-0.2.4/probe.log).

The separate public design-network route was also exercised using the archived
PCM interaction rendering fixture. It returned 68 nodes, 376 edges and one
graph component, and exposed reusable node/edge tables through `draw = FALSE`.
That is a functionality check; the fixture remains review-only and the graph
summary does not establish identification or inferential readiness. The
[summary](plot-expansion-0.2.4/design-network-summary.csv) preserves the output.

## Implementation order and acceptance criteria

**First: repair the existing anchor graph, before adding more graph metrics.**
Retain every declared wave, including isolated vertices and zero-link cases.
Carry a stable node identity and the source link ID, candidate/retention status,
common-element count and review reason. Preserve enough pair-specific detail
that joining edges cannot turn an excluded comparison into a supported path.
Use an administration-to-administration view for actual reviewed links and a
bipartite companion for element membership. Initially label this as screened
common-element linking, rather than an inventory of supplied fixed anchors.

Acceptance examples must cover a connected chain, one critical shared element,
a disconnected wave, no shared elements, mixed retained/excluded elements,
repeated display names, and link-like punctuation in names. Declared and drawn
node counts must agree; table and figure statuses must agree. The draw-free
node/edge/notes payload must remain available independently of drawing.
Apply the established colour/greyscale and title/note conventions here as well.

**Second: connect topology to anchor-removal sensitivity.** A cheap deletion
audit can identify which waves disconnect when an element or reviewed link is
removed. Label this as a graph calculation. A separate calculation must rerun
the specified linking or fitting procedure before displaying changes in
offsets, facet estimates, Person measures or SEs. Do not infer those changes
from betweenness or common-element counts. Same-data repeated refits also need
appropriate uncertainty accounting.

Progress: `type = "links"` and `type = "anchor_removal"` now provide the
recorded-wave summary, lost direct links, newly disconnected wave pairs and
before/after component memberships. Unknown retention is kept explicit and
existing disconnections are excluded from newly lost pairs. Retention decisions
are held fixed in that graph audit. The conditional offset view now reruns
screening and offsets on fixed source estimates/SEs, with numerical failures,
missing cumulative comparisons and changed contributors exposed. Full source
model refits and uncertainty calculations remain outstanding; distinguish
common-element alignment from actual fixed-anchor constraint changes.

**Third: extend the other views around existing validation questions.**
Prioritize difference-versus-mean plots for matched TAM/mfrmr comparisons and
residual-structure views that point to concrete follow-up cells. New graph
selection, confidence bands, control limits or decision thresholds require an
explicit statistical basis. Large ornamental graphs and duplicated analysis
engines are not prerequisites for these improvements.

For each added view, documentation should connect the question, data/edge
definition, visual encoding, numerical result and permitted interpretation.
Keep explanations and warnings accessible in returned tables when users omit
figure annotations. None of these visualization additions resolves the
outstanding statistical release conditions by itself.

## Wright-map and CCC comparison views: JLTA slide review

On 2026-09-10, the user supplied `2026JLTA_2026903.pdf`, pages 13–14,
from `Manuscript_RMAL_Paper1/JLTA`. Both pages were rendered and visually
inspected, alongside the related `internal/tools/plot_story_revised_figures.py`
and `plot_observed_category_curves.py` scripts in that manuscript project.
This section records a proposed extension; no comparison API is implemented
by this review.

Follow-up implementation: `plot_compare_mfrm(reference, comparison, ...)`
now supplies both `type = "wright"` and `type = "ccc"`, each with comparison
and difference views. It reuses native tables, curve calculations, comparison
signatures and optional ggplot2. The initial scope requires matching recorded
centering, anchors, orientation, category coding, estimator and coordinate
basis; no automatic alignment is performed. Category panels are automatic for
monochrome or more than five categories. Original/internal category identities,
unavailable location differences, source readiness and selected/unselected
groups remain explicit in the payload. Source fits are not refitted and no
difference SE/CI is inferred. External-software adapters, automatic scale
transformations, difference uncertainty and pagination remain separate work.
The proposed forms and review rationale below are retained for context.

The Wright map on page 13 places person distributions, rater/criterion points
and category steps on a shared vertical scale. RSM and PCM occupy adjacent
positions; software implementations use panels with common limits. The person
violins convey distribution shape compactly, while point shapes and horizontal
position provide distinctions beyond colour. This is useful for comparing
fitted distributions across models, although identical distributions can
conceal different estimates for individual persons or facet levels.

The CCC on page 14 maps category to colour, model to solid/dashed lines, and
software to panels. Its PCM comparison is explicitly Purposefulness. The
related script selects the PCM facet with the greatest probability spread
across the four implementations; this is a selected diagnostic view, not a
display of every PCM facet or a general demonstration of model equivalence.
The overlapping 22 curves and bright yellow lines on white make local
differences difficult to read. The related scripts use a fixed four-program,
11-category design, which should not become a package restriction.

Planned additions, reusing existing draw-free tables and optional ggplot2:

| User question | Display and implementation boundary |
| --- | --- |
| Do models give similar overall locations and distributions? | A Wright comparison with adjacent distributions, point/interval layers and shared limits; permit histogram or raw-point alternatives when a density estimate is unsuitable |
| Which matched levels actually change? | A companion signed-difference view joined by facet/level identity, preserving unmatched and excluded rows; distribution overlap is insufficient |
| Do category probabilities differ across models? | CCC overlays for explicitly selected corresponding curve groups; keep category encodings consistent and reserve line type for model in this view |
| Where are small probability differences? | A zero-centred probability-difference panel using the same predictor grid, category mapping and reference profile; return the signed differences and maximum absolute difference with the location/category where it occurs |

For monochrome or many categories, prefer category panels with model line
types and visible category labels. Do not try to distinguish 11 categories
and two models solely by the six existing line patterns. Colour mode should
retain direct labels/panel identity and adequate line contrast; green or yellow
is not itself a sufficient accessibility criterion. Keep a consistent category
mapping across Wright steps and CCCs, and label steps as actual adjacent
transitions (for example, `0 -> 1`), rather than implying that a step location
is an expected score.

Scale alignment must be explicit and returned with the comparison. The
related Wright script applies median offsets by model, facet and program
relative to Python; such display alignment is not a validated transformation
of an entire fitted model. The package must not silently reproduce it as a
general linking procedure. Compare compatible origins, units, facet signs,
categories and curve conditioning; retain GPCM slopes and distinguish
model comparisons from software comparisons. A statement such as “6–7 points
at the reference profile” must use the expected-score calculation under the
stated profile, rather than being read from adjacent step locations alone.

The existing Wright `locations` and `person` tables, CCC `probabilities` and
`curve_basis` tables, and shared expected-score calculation provide the
starting point. Verify identity/scale contracts for the selected route, then
add a reusable comparison view without duplicating the probability engine. Preserve
title/note controls, returned interpretation notes and source readiness.
Acceptance examples should include unequal category counts, nonzero score
origins, long labels, missing matched levels, a one-person distribution,
multiple PCM groups and GPCM slopes. Use explicit selection/pagination for
dense panels and do not silently omit groups. The first implementation target
is a paired-model Wright display and selected-group CCC with a difference
panel; external-software adapters follow verified input contracts.

## Fair Scores and refit uncertainty: 2026-09-10 follow-up

The [Fair Score follow-up](fair-score-refit-record-0.2.4.md) extends the existing
fair-average plot API with Measure-to-Fair-Score points, grayscale encodings
and returned notes. It also corrects FairZ semantics and conditional-interval
calculation/labels. This makes the transformation reviewable but does not
validate the underlying fitted model or its uncertainty.

The [full-refit protocol](fair-score-refit-protocol-0.2.4.md) now controls the
next inference work: fixed-reference FairZ confirmation, reestimated-reference
FairM and Person intervals, then paired anchor/model interventions under a
common scale. DRF/interactions and the distinct GPCM/JML estimators need their
own conditions. The initial 40-dataset pilot is a numerical/execution check;
it does not close these coverage or release gates.

## Sources and reproducibility

- [Epskamp et al., qgraph](https://www.jstatsoft.org/article/view/v048i04):
  psychometric covariance, loading and other relationship matrices can be
  visualized as networks. This motivates visual reuse, not causal claims.
- [Facets connectedness documentation](https://www.winsteps.com/facetman/subset-connectedness.htm):
  rating design, constraints and ambiguous parameter comparisons must be
  considered together; graph appearance alone is insufficient.
- [Bland and Altman, method comparison](https://pubmed.ncbi.nlm.nih.gov/2868172/):
  graphical agreement assessment motivates a difference-versus-mean companion
  for already aligned estimator outputs. Automatic clinical agreement limits
  are not being imported into the psychometric workflow.

Run `Rscript inst/validation/plot-expansion-0.2.4/probe.R` from the package root
to reproduce the diagnostic observations; results are written under `tempdir()`.
The archive also records [source hashes](plot-expansion-0.2.4/source-md5.csv).
The probe archive preserves the pre-repair observations and hashes; replaying
it on the repaired source now produces different results. See the separate
repair record for current-source evidence. Neither record claims a package
release or new statistical validation.
