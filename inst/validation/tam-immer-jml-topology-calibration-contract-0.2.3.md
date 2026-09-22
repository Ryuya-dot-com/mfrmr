# Matched-topology TAM/immer/mfrmr JML contract for mfrmr 0.2.3

Status: repository-only Draft.79 topology-feasibility and replicated-pilot
contract, 2026-08-09.

## Purpose

Draft.78 established that total Persons and bridge percentage cannot replace
the absolute number and allocation of common-Person links. Draft.79 holds the
number of eight-Rater bridge Persons at 8, 12, or 24 while varying four
deterministic allocation topologies:

- `path`: adjacent Raters form a path;
- `cycle`: adjacent Raters form a closed cycle;
- `distributed`: a cycle is established first and remaining bridges are spread
  over distinct chords before any edge is repeated; and
- `hub`: every edge is incident to one hub Rater.

The 36-dataset smoke crosses 18 profiles with RSM/PCM once. A separately
guarded 180-dataset pilot repeats the same cells five times. Five replicates
remain feasibility calibration, not coverage, failure-rate, or sample-size
evidence.

## Matched design identity

All matched topology cells have 120 Persons, eight Raters, four Criteria, four
categories, and one Rater per nonbridge Person. Each bridge Person is assigned
to exactly two Raters and contributes all four Criterion ratings before any
planned link loss. Thus matched cells with a given bridge count have the same:

- total Persons and declared facet sizes;
- number of common-Person links;
- mean Person-Rater degree and assignment density; and
- potential response count.

They differ in which Rater pairs share Persons, edge multiplicity, node degree,
cycle structure, and concentration around articulation Raters. Performance
differences remain topology-conditional; the smoke has only one response seed
per cell and cannot rank methods or topologies.

The `REFERENCE_D2` profile retains the Draft.78 cyclic degree-two design. The
`DISCONNECTED_B24` negative control deliberately spends 24 bridge Persons
inside a four-Rater cluster while leaving four Raters isolated. This proves
that a large bridge count does not imply global connectedness.

## Graph vulnerability identity

Assigned and observed graphs are audited separately. In addition to Draft.78
degree, density, workload, component, shared-Person, and weighted Laplacian
fields, Draft.79 records:

- minimum and maximum simple-graph Rater degree;
- cycle rank, `edges - vertices + components`;
- number of articulation Raters;
- number of simple-graph cut edges;
- number of edges for which losing one shared Person disconnects the graph;
- robustness to any one Rater, graph edge, or shared-Person loss;
- maximum shared Persons per edge; and
- coefficient of variation of positive edge weights.

Weighted algebraic connectivity is retained but is not a sufficient robustness
criterion. For example, a hub can have larger algebraic connectivity than a
path while remaining dependent on one articulation Rater. No single graph
summary may be promoted as an adequate-link threshold from this smoke.

## Adversarial single-link loss

At bridge count 12, each topology has a paired `DROP1` profile. Before outcomes
are inspected, the generator removes the second Rater block from the bridge
Person whose loss maximizes graph components and then minimizes weighted
algebraic connectivity. The Person remains singly rated, but no longer links
the two Raters.

The frozen structural expectations are:

| Topology | Assigned state | State after one adversarial link-Person loss |
| --- | --- | --- |
| path | connected | disconnected |
| cycle | connected | connected, but reduced to a vulnerable path |
| distributed | connected | connected, with vulnerability re-audited |
| hub | connected | disconnected |

This is an explicitly adversarial topology control, not MCAR, MAR, or MNAR.
Outcome-dependent missingness is not used to choose the removed link. Later
replicated work must cross these graph structures with stochastic block- and
response-level missingness as separate mechanisms.

## Estimator and boundary rules

Graph-disconnected observed designs must stop at the mfrmr constrained-rank
screen before optimization and retain zero method rows. Connected designs enter
the same nine Draft.75 mfrmr/TAM/immer method identities. A method row is
retained even when its engine returns no finite result.

Natural extreme Persons are expected under one-Rater base exposure. Original
raw JML is estimand-eligible only when the observed sufficient score has no
extreme Person. A finite optimizer trace does not override that rule. Extended
profile, extreme-adjusted, epsilon-adjusted, and classically postscaled modes
remain separate estimator identities. A corrected point is not the maximizer
of the original unadjusted JML likelihood.

TAM/immer iteration counts retain their engine-labelled
iteration-before-ceiling proxy. The smoke raises TAM's ceiling to 800 and the
pilot declares 1,200, but neither ceiling nor `iter < maxiter` proves score-
equation convergence.

Common-surface SE coverage and reported Rasch/FACETS-style facet separation
remain ineligible until their covariance and definition contracts close.
Truth-SD/RMSE recovery separation remains a differently named simulation
diagnostic.

## Checkpoint and completion contract

Every checkpoint binds:

- exact manifest row and tier;
- runner bodies, including topology construction, adversarial loss, graph
  vulnerability, generator, fitter, and metric functions;
- loaded mfrmr, TAM, and immer primary-function identities;
- R version, platform, and RNG contract; and
- serialized result payload hash.

Publication uses verified same-directory temporary writes followed by rename.
Unexpected, stale, mutated, or partial artifacts fail closed. A completion
marker binds the exact ordered checkpoint ledger and aggregate result hash.
Resume must reconstruct the same aggregate without refitting completed cells.

## Pass condition and prohibitions

The smoke or pilot passes its structural contract only when:

- all declared datasets generate and retain their expected order;
- assigned and observed graph connectivity equal the frozen manifest states;
- every connected observed design retains nine planned method rows;
- every disconnected observed design stops as
  `structurally_unidentified` with zero method rows;
- all metric rows retain `EvidenceReady = FALSE`; and
- any checkpointed aggregate and completion marker validate exactly.

Passing authorizes only the matched topology for later calibration. Draft.79
freezes no graph cutoff, bridge minimum, topology preference, estimator or
correction choice, sample-size recommendation, coverage tolerance, rare-
failure rate, public default, release state, candidate, or confirmation seed.
