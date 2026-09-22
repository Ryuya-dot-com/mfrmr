# D-SIM-3 v4 exploratory execution-contract record

Status: execution denominator and seed identities frozen; subsequent qualification no-go, execution closed
Date: 2026-08-30
Contract: `MFRMR-GTHEORY-MV-DSIM3-EXPLORATORY-EXECUTION-V1`
Parent coverage contract hash: `39b4b542f3afe617cc8f2912a23aa4211790460c8765d4ad38f9cd95575c508f`
Parent coverage manifest hash: `4c6958f00aac7598d777387ec113cd43474031430492e83e6183d19dcedf7197`
Contract hash: `1e26cdf45218c7a28a260e519a376346d99d76a69772382ef5b0787e130f8b85`
Unopened plan hash: `b91ab4229203efc15a3ca9421256d81ae7331143e42f845b5c6a879575552de7`

## Purpose

This contract turns the completed 21-cell coverage manifest into an explicit
exploratory denominator without generating a response. It separates four
units that must not be conflated:

1. a seeded dataset attempt;
2. a route unit that refers to that dataset;
3. an `ABS-PHI` or `REL-G` projection; and
4. a route-estimand coordinate.

The contract is package-capability infrastructure. It does not require an
operational owner, a user's action consequence, an external freeze receipt, or
a substantive target. Those are study-level concerns, not prerequisites for
testing whether package implementations honor their declared design grammar.

## Breadth-first exploratory budget

Each of the 21 frozen design cells receives exactly two distinct exploratory
dataset identities, producing 42 planned dataset attempts. Two replicates are
enough to traverse each stochastic profile more than once while remaining far
below a Monte Carlo operating-characteristic study. They cannot estimate bias,
coverage, or a success probability and cannot select a confirmation threshold.

| Unit | Planned count | Interpretation |
|---|---:|---|
| scenario design cells | 21 | frozen by the coverage manifest |
| dataset attempts | 42 | two seeds per scenario |
| route units | 210 | five shared-dataset route rows per dataset |
| dataset-estimand units | 84 | G and Phi; not independent datasets |
| route-estimand coordinates | 420 | two nonvoting coordinates per route unit |
| control definitions | 3 | retained without random generation |

No successful subset may redefine any denominator. Failed generations, prefit
rejections, unavailable metrics, timeouts, and memory-limit states remain in
their registered populations. A failed dataset receives no replacement seed.
An exact same-seed replay may diagnose integrity but cannot replace its
original receipt.

## Route disposition before qualification

The 210 route units retain the coverage manifest's current representability
status:

| Disposition | Count | Current meaning |
|---|---:|---|
| qualification candidate | 50 | 42 separate-univariate plus 8 restricted-lme4 units; adapter qualification still required |
| negative-control prefit rejection | 40 | naive pooling must be rejected without a backend call |
| frozen not applicable | 8 | multivariate routes on the one-stratum closure cell |
| blocked by unimplemented/custom contract | 112 | linked, explicit-mask, or otherwise unimplemented covariance representation |

All 210 remain in the route denominator. None currently permits a backend
call. The 50 candidates may become executable only after their generator,
adapter, terminal-receipt, and resource-enforcement contracts are qualified.
The other 160 rows must retain their frozen no-call disposition rather than be
silently dropped.

## Seed namespace

The prospective exploratory band is `DSIM3-EXPLORATORY-855`:

```text
DataSeed = 855000000 + 1000 * ScenarioOrdinal + Replicate
```

The 42 identities range from `855001001` through `855021002`. They are unique
and disjoint from the historical 851 pilot, 852 confirmation, 853 structural-
control, and 854 nonreserved-fixture bands. The plan records the integers but
does not call `RNGkind()`, `set.seed()`, or any generator. Future confirmation
seed identity remains unassigned.

## Terminal and resource containment

Thirteen typed states distinguish dataset completion/failure/resource limits,
route dependency/prefit/fit/metric outcomes, complete nonpromoting units, and
the invalid unrecorded state. Every valid state remains in its registered
denominator. `unrecorded_invalid` blocks completion and cannot be imputed as a
failure.

The frozen envelope uses one worker at a time, positive wall-time and peak-RSS
ceilings for generation, fit, metric, dataset pipeline, and the complete run.
These are containment limits, not statistical acceptance thresholds. An
exceedance is terminal and never triggers a replacement attempt. Enforcement
is not yet qualified, so the limits themselves do not authorize execution.

## Readiness boundary

The contract and unopened plan are complete, but all of the following remain
false: RNG-stream access, response generation, backend calls, fits, exploratory
results, accuracy-threshold selection, simulation validation, reference
validation, inference, decision, and public support. Feature maturity remains
`specified`.

The subsequent pre-execution audit completed without opening any 855 stream.
It found 18/37 reusable generator primitives, but no exact complete-profile,
candidate-route, generic terminal-receipt, or resource-enforcement binding.
The subsequent shared compiler now qualifies typed design semantics for 21/21
profiles across nine axes. A second shared layer qualifies 84/84 PSD component
covariance/factor bindings and 21/21 response-kernel contracts. Generic
stochastic response generation subsequently qualified on 21 nonreserved shadow
fixtures. Route/receipt adapters and resource enforcement remain open. Partial
reserved execution and scenario-specific patches remain prohibited.
