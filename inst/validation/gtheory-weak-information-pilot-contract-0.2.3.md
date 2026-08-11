# Draft.83d2b2b0 replicated G-theory weak-information pilot contract

Status: repository-only replication, precision, candidate-rule, and execution-
authorization contract, 2026-08-09.

Draft.83d2b2b0 converts the Draft.83d2b2a one-replicate concern into a staged
simulation plan. It does not estimate operating characteristics, select a
threshold, or authorize confirmation. Its primary purpose is to prevent the
already viewed covering smoke, feasibility data, calibration data, and future
confirmation data from being silently pooled.

## Independent unit and method pairing

One independent Monte Carlo unit is one `ScenarioId x Replicate` generated
dataset. The four lme4/glmmTMB ML/REML routes share that dataset and therefore
form paired method results; they are not four independent datasets.

Primary false-ready, false-block, and indeterminate rates must be reported for
each scenario x method cell. Pooling Persons, Rater levels, allocation
topologies, variance regions, likelihoods, or backends is prohibited for the
primary operating-characteristic denominator. Pooled summaries may be shown
only as labelled secondary descriptions.

The generator uses
`ScenarioSeedStart + Replicate - 1`. Scenario starts are separated by 1,000,
and every registered replicate is below 1,000. Methods are paired by receiving
the same generated table, not by being assigned adjacent pseudo-random seeds.

## Frozen phase and seed bands

| Phase | Replicates/cell | Replicate IDs | Cells | Fits | Worst-case cell x method Bernoulli MCSE | Authorization |
| --- | ---: | --- | ---: | ---: | ---: | --- |
| schema smoke | 2 | 2--3 | 3 | 24 | 0.354 | authorized; schema only |
| feasibility pilot | 25 | 101--125 | 30 | 3,000 | 0.100 | authorized after this contract |
| calibration pilot | 100 | 201--300 | 30 | 12,000 | 0.050 | not yet authorized |
| confirmation | 200 | 501--700 | 30 | 24,000 | 0.035 | sealed |

The schema cells are baseline complete exact zero, numerical near zero, and
variance-0.12 reference. They test execution, replay, aggregation, and failure
accounting only. They cannot select or reject a diagnostic rule.

The 25-replicate feasibility phase checks diagnostic availability, numerical
failure, empirical overlap, runtime, and storage. Its maximum cell x method
MCSE of 0.10 is intentionally too coarse for a final rule. It cannot freeze a
threshold.

Only after a separate feasibility record may a new specification identity
authorize the 100-replicate calibration phase. Under 100 independent
replicates, the worst-case Bernoulli MCSE is 0.05. If zero false-ready events
are observed in a cell, its one-sided 95% exact binomial upper bound is about
0.0295; zero observed events must not be described as a zero population error
rate.

Confirmation remains unavailable until one rule family, its numerical
cutpoints, indeterminate zone, failure behavior, backend scope, and hashes are
frozen. Merely constructing the confirmation manifest does not authorize data
generation. Any view of confirmation results before that freeze invalidates
confirmation.

## Three-state rule plus computational failure

Every candidate application rule returns exactly one of:

- `not_resolved`;
- `indeterminate`;
- `resolved`; or
- `not_evaluable` when the required fit or diagnostic is unavailable.

`not_evaluable` is not silently recoded as `not_resolved`; doing so would hide
computational failures. For negative controls, only `resolved` is false ready.
For positive controls, `not_resolved` is false block; `indeterminate` and
`not_evaluable` have separate denominators. Transition cells have no required
binary truth label.

## Frozen candidate architecture

Four rule families are registered before feasibility data are generated:

1. target fraction of total fitted variance with a lower/upper zone;
2. target-to-residual variance ratio with a lower/upper zone;
3. target-to-residual ratio plus backend-specific target relative uncertainty;
4. full-versus-reduced likelihood drop plus target relative uncertainty.

The first two observables are already available. The latter two require an
enriched diagnostic refit. They may not borrow the whole-model minimum
curvature eigenvalue as if it were the target component's standard error.

Backend coordinates remain distinct:

- lme4 supplies named relative-SD `theta` coordinates and a profiled-deviance
  Hessian; any local target uncertainty is explicitly profiled and does not
  include full residual-scale uncertainty; and
- glmmTMB supplies formula-ordered log-SD coordinates and a joint fixed-
  coordinate covariance; its uncertainty cannot be relabelled as the lme4
  quantity merely because both are numeric.

A reduced likelihood diagnostic must refit the same retained rows, fixed
effects, backend, and ML/REML identity after removing only the target random
component. The raw likelihood drop is a diagnostic score. No ordinary
one-degree chi-square p-value is attached because the zero-variance null lies
on a boundary and the multi-component finite-sample law is not assumed.

Backend and ML/REML differences are validation diagnostics. A primary
single-fit application rule cannot require an unrequested second backend and
still be described as a single-fit rule.

## Candidate selection order

The calibration pilot may compare only the registered score grids and rule
families. Selection is lexicographic:

1. require zero observed negative-control `resolved` rows;
2. minimize the corresponding one-sided exact-binomial upper bounds;
3. minimize positive-control `not_resolved` rows;
4. minimize positive-control `indeterminate` rows;
5. minimize `not_evaluable` rows; and
6. use lower rule complexity as a deterministic tie-break.

This ordering prevents the trivial always-`not_resolved` rule from winning on
false readiness alone. It does not guarantee that any candidate is adequate.
If no candidate satisfies the frozen order with acceptable positive-control
behavior, the result is a completed negative pilot and confirmation remains
unauthorized.

## Current schema result

The 24-unit schema manifest contains six independent datasets. All 24 backend
fits were attempted and returned, atomic accounting passed, and 16 existing
whole-model point gates passed. Exact-zero gates passed for both schema
replicates on all four routes; near-zero and positive-reference cells each
passed one replicate and failed one across all four routes. These viewed schema
results further illustrate instability but are not feasibility or calibration
evidence.

The plan, schema manifest, and schema execution identities are recorded in the
companion record. The feasibility seeds 101--125, calibration seeds 201--300,
and confirmation seeds 501--700 were not generated for this slice.

`ThresholdFrozen`, `CalibrationEvidenceReady`, `ConfirmationAuthorized`,
`ConfirmationViewed`, `RecoveryEvidenceReady`, `InferenceReady`,
`CoefficientEligible`, and `DecisionReady` remain false.
