# Connected-assignment TAM/immer/mfrmr JML contract for mfrmr 0.2.3

Status: repository-only Draft.78 structural-feasibility contract,
2026-08-09.

## Purpose

Draft.77 showed that every one-Rater-per-Person profile with more than one
Rater was structurally unidentified. That pilot therefore confounded low
exposure with absence of a common-person link. Draft.78 replaces that alias
with an explicit Person-Rater bridge design before any replicated performance
or sample-size claim is considered.

This is a 36-dataset deterministic RSM/PCM smoke. It is not a correction
selection, coverage study, power study, or confirmation run. Every metric
retains `EvidenceReady = FALSE`.

## Graph identity

The assignment graph has one vertex per declared Rater. Two Raters share an
edge when at least one Person is observed by both. Edge weight is the number of
shared Persons. The runner records, separately before and after response-level
missingness:

- Person-Rater pair count, Person assignment-degree range, and density;
- target and realized bridge-Person counts;
- Rater workload Gini and max/min ratio;
- Rater-graph edges and connected components;
- minimum shared-Person count among present edges; and
- weighted algebraic connectivity, the second-smallest eigenvalue of the
  weighted graph Laplacian.

`RaterGraphConnected = TRUE` is necessary for the current no-anchor common-
scale comparison. Algebraic connectivity is a graded vulnerability diagnostic,
not a universal cutoff and not evidence of adequate precision.

## Constructed bridge rule

The low-exposure base assigns one cyclic Rater to each Person. The first
`floor(Persons * BridgeFraction)` Persons receive the next cyclic Rater as a
second assignment. For `R` Raters, the first `R - 1` such Persons create the
chain of edges needed to span all Raters. Under this deterministic construction:

`expected connected = BaseDegree >= 2 or BridgePersonsTarget >= Raters - 1`.

This rule is construction-specific. It is not a theorem that any arbitrary
set of `R - 1` bridge Persons connects an arbitrary operational design. The
realized graph audit, rather than the target rate, remains authoritative.

The negative controls are:

| Profile | Persons | Raters | Bridge rate | Bridge Persons | Expected components |
| --- | ---: | ---: | ---: | ---: | ---: |
| `BRIDGE_B000` | 120 | 8 | 0% | 0 | 8 |
| `BRIDGE_B005` | 120 | 8 | 5% | 6 | 2 |
| `BRIDGE_P60_B010` | 60 | 8 | 10% | 6 | 2 |

The matched positive controls include 10% of 120 Persons, 20% of 60 Persons,
and 2.5% of 480 Persons. Each supplies 12 bridges and is expected connected.
Thus a bridge percentage cannot be interpreted without its absolute count,
topology, and declared number of Raters.

## Conditional contrasts, not orthogonal effects

For any assignment:

`AssignmentDensity = MeanPersonRaterDegree / Raters`.

Rater count, mean exposure, and density therefore cannot be independently
randomized as three orthogonal main effects. Draft.78 uses two named slices:

1. fixed degree two across 4, 8, and 12 Raters, which changes density and the
   number of Rater parameters; and
2. fixed density one-half using 4/2, 8/4, and 12/6 Rater/degree designs, which
   changes exposure and the number of Rater parameters.

Any difference is a conditional multi-factor contrast. It cannot be labelled
the isolated causal effect of Rater count, density, or observations per Person.
The workload slice holds 8 Raters and base degree two while changing weighted
assignment pressure; realized imbalance remains the reporting variable.

## Missingness boundary

Connected 25% bridge designs are additionally subjected to 30% MCAR,
observed-Rater MAR, and score-dependent MNAR. The assigned graph and the graph
with at least one observed Criterion response per Person-Rater pair are audited
separately. A target-connected design that becomes observed-disconnected is a
structural failure, not a numerical nonconvergence. MNAR performance is a
misspecification result.

## Estimator and metric boundaries

All graph-connected cells enter the same nine Draft.75 modes. Method rows are
retained even when an individual engine/mode returns no finite fit. Disconnected
negative controls must stop at the package's structural-rank screen before
optimization and retain zero mode rows.

Natural all-minimum/all-maximum Persons can occur because the bridge designs
have very low exposure. In such cells, original raw JML remains estimand-
ineligible even if a finite optimizer trace is retained. Adjusted, profile, and
classically postscaled identities stay distinct; a postscaled point estimate is
not the maximizer of the original JML likelihood.

Bias, RMSE, rank recovery, recovery separation, fit return, finite surface,
engine-labelled convergence, and estimand eligibility follow the Draft.76/77
definitions. Common-surface SE coverage and definition-matched reported facet
separation remain withheld. No unchanged native SE vector may be attached to a
postscaled point estimate and called corrected-estimand coverage.

## Pass condition and prohibitions

The smoke passes only if:

- all 36 datasets are generated;
- the six RSM/PCM negative controls are classified
  `structurally_unidentified`;
- all 30 expected-connected datasets retain nine method rows;
- assigned and observed graph connectivity match the frozen expected state;
  and
- all result metrics remain `EvidenceReady = FALSE`.

Passing authorizes only the connected-design topology for a later replicated
pilot. It freezes no bridge cutoff, algebraic-connectivity cutoff, correction,
sample-size recommendation, coverage tolerance, method ranking, release gate,
candidate, or confirmation seed.
