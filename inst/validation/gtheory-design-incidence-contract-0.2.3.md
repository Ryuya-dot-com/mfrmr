# Draft.83a G-theory observed-design incidence audit contract

Status: repository-only design-audit prototype contract, 2026-08-09.

Draft.83a is the first part of the broader Draft.83 unbalanced/nested G-theory
gate. It operates on a Draft.81 typed design and observed score rows before any
Draft.83 estimator or D-study allocation operator is allowed to run. It is not
an exported API and does not change `mfrm_generalizability()` or
`mfrm_d_study()`.

## Why this gate is separate

A finite `lmer()` or `glmmTMB()` result does not establish that:

- object and facet islands are linked;
- every declared component has usable incidence variation;
- a highest-order interaction is distinct from within-cell residual error;
- an observed unbalanced allocation defines a future D-study allocation; or
- omitted outcomes satisfy the missingness assumptions used for estimation.

Draft.83a therefore records observed-design facts without fitting a mixed
model. `IncidenceScreenPassed` is only a necessary structural screen for the
narrow diagnostics implemented here. It is not variance-component
identifiability, estimation eligibility, inference readiness, or decision
readiness.

Connectivity is necessary but not sufficient for an identified G-study.

## Canonical row and missingness identity

The audit requires the typed score, object, random-facet, and fixed-facet
columns. Scores must already be numeric; labels are never silently coerced.
Rows with a missing/nonfinite score or a missing/empty facet identity are
omitted from incidence calculations and counted separately.

Each result stores:

- input, retained, and omitted row counts;
- missing-score, nonfinite-score, missing-facet-row, and missing-facet-cell
  counts;
- declared raw factor levels, including unused factor levels, and the number
  left with no retained row after omission;
- a separate declared-level identity hash so unused levels cannot disappear
  without changing the audit identity;
- a row-order-invariant hash of the canonical input values and score states;
- a row-order-invariant retained-data hash; and
- a row-order-invariant omission-pattern hash that does not use raw row
  numbers.

The declared mechanism is exactly one of `complete`, `MCAR`, `MAR_covariate`,
`MNAR_sensitivity`, or `unknown`. This is provenance, not an empirical test of
the mechanism. A `complete` declaration with omitted rows is a conflict;
omissions under `unknown` remain a concern. Even a consistent `MAR_covariate`
declaration does not prove ignorability.

## Conditional identities for nested factors

For a declared edge such as `Site > Rater`, the observed Rater node is keyed by
its ancestry and raw label, for example `Site=S1/Rater=R1`. Reusing `R1` in a
different Site therefore does not create a false bridge. The nesting table
retains:

- parent levels;
- raw child labels;
- conditional parent-child levels;
- raw child labels shared across parents; and
- the minimum, median, and maximum observed child count per parent.

Raw-label reuse is not treated as a nesting violation. The conditional
identity is the computational unit. Draft.83a does not infer an unobserved
nested population or its future allocation.

## Connectivity and workload

The audit builds a privacy-preserving graph summary from observed effective
factor levels. It stores global node/edge/component counts and, for every pair
of factors:

- observed and Cartesian-potential incidence edges;
- incidence density;
- bipartite connected-component count;
- minimum and maximum degree on both sides; and
- degree coefficient of variation on both sides.

A disconnected object-by-facet graph is a concern unless that pair is related
by the declared nesting graph. Multiple components for a declared nested
parent-child pair are expected and remain visible rather than being
misclassified as a broken crossing.

The workload table stores, per factor, declared raw levels, retained raw
levels, zero-retained raw levels, observed conditional levels, and the minimum,
median, mean, maximum, standard deviation, and coefficient of variation of row
counts. A declared level with no retained row is a visible concern rather than
being dropped by refactoring. These quantities describe observed load; they do
not substitute for an allocation operator and do not establish representative
sampling.

## Full-cell replication

Full object-by-facet cell counts are classified as:

- complete with one row per cell;
- partial with one row per observed cell;
- complete with equal replication; or
- unequal/partial replication.

The audit separately records whether every observed cell is replicated,
whether only some cells are replicated, and whether the typed
`cell_replication` declaration matches the observed data. When a highest-order
component is explicitly fitted, lack of replication in every observed cell
blocks a claim that it is separated from ordinary residual error.

For crossed designs, potential cells and coverage use the Cartesian product of
observed effective levels. For nested designs, that product contains
structurally impossible combinations. Draft.83a therefore reports the
Cartesian count descriptively but sets structural potential cells and coverage
to missing with
`nested_structural_potential_requires_allocation_contract`. It does not invent
a denominator from the observed median conditional count.

## Component rank audit and its limit

For ordinary crossed components, Draft.83a constructs sum-to-zero main-effect
and pure-interaction contrast blocks. It reports the block rank and the rank
increment after all other declared component blocks are retained. For a
nested grouping component, it uses the conditional grouping identity and the
expected increment beyond the closest represented parent grouping.

The result distinguishes:

- `fixed_equivalent_full_increment`;
- `fixed_equivalent_partial_increment`;
- `fixed_equivalent_zero_increment`; and
- `fixed_equivalent_nested_hierarchy_absorbed`.

The last state is expected when, for example, the fixed-equivalent dummy block
for `Site:Rater` contains the `Site` column space. It is not evidence that the
random `Site` variance is unidentifiable. Conversely, a full fixed-equivalent
increment does not prove variance-component identifiability. That requires a
later covariance-design/information-rank and estimator-behavior audit.

The full fixed-equivalent model rank and residual degrees of freedom are also
retained. A configurable matrix-cell ceiling fails to a typed
`not_evaluated_capacity` state; exceeding it cannot silently pass.

## Readiness boundary

Every Draft.83a result has:

```text
EstimationEligibility = not_adjudicated_draft83a
CoefficientEligible   = FALSE
DecisionReady          = FALSE
```

`IncidenceScreenPassed=TRUE` means only that this audit found no declared-row,
connectivity, replication-metadata, crossed fixed-equivalent-rank, or residual-
contrast concern. It does not override Draft.81 `DStudyEligible`, choose REML
or ML, validate a missingness model, form G/Phi/SEM, or authorize reporting.

## Frozen fixtures and next steps

The test set freezes complete p x r x i, sparse-connected p x i,
disconnected-island p x i, nested Site/Rater with reused raw child labels,
replicated saturated p x i, missing-row, row-order replay, nonnumeric score,
and rank-capacity controls.

Draft.83b must define component-specific allocation operators and structural
potential-cell semantics. Draft.83c must fit unbalanced/nested designs with
backend-specific covariance-design, information, boundary, and convergence
diagnostics. Draft.83d must perform recovery, coefficient-denominator, and
zero-false-ready validation across sparsity, workload imbalance, missingness,
and disconnection. Interval and multivariate work remain later gates.
