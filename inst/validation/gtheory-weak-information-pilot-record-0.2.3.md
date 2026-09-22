# Draft.83d2b2b0 replicated G-theory weak-information pilot-plan record

Date: 2026-08-09
Scope: repository-only replication/precision plan and schema execution
Result: phase, seed, denominator, candidate, and authorization contracts pass;
no feasibility/calibration/confirmation result was generated

## Outcome

Draft.83d2b2b0 freezes four nonoverlapping replicate bands and makes the
scenario x replicate dataset, rather than a backend route or Person row, the
independent Monte Carlo unit. All four likelihood routes remain paired within
each generated dataset.

The deterministic pilot-plan identity is:

`427addf42c73047e184857f52e9aa126e6d5eb346ab105827d14b3affef38cbd`.

The calibration and confirmation manifests can be audited without generating
their data, but the execution function rejects both. The feasibility manifest
is authorized for the next slice; none of its 750 datasets has been generated
for this record.

## Recorded environment

| Dependency | Version |
| --- | --- |
| R | 4.6.1 (2026-06-24) |
| testthat | 3.3.2 |
| digest | 0.6.39 |
| lme4 | 2.0.6 |
| glmmTMB | 1.1.14 |
| TMB | 1.9.23 |
| Matrix | 1.7.6 |
| Platform | aarch64-apple-darwin23; Darwin 25.5.0 arm64 |

## Frozen phases and manifest identities

| Phase | Replicate IDs | Independent datasets | Fits | Worst-case cell x method MCSE | Execution state | Manifest identity |
| --- | --- | ---: | ---: | ---: | --- | --- |
| schema smoke | 2--3 | 6 | 24 | 0.354 | executed, schema only | `8962be56cad3f4a3bc3e77a1ee2a5621857900e9d554ac099dfbaf4c26651a72` |
| feasibility pilot | 101--125 | 750 | 3,000 | 0.100 | authorized, not run | `ba2beeffee6128b6d920a2c3ad52f2ab1065e3263f380fa7cbfa186b1cadf8ef` |
| calibration pilot | 201--300 | 3,000 | 12,000 | 0.050 | not authorized | `85d3ee963e93adfcc1d0bf505b1c34b1486f3eebfc605cf687a8e79240431676` |
| confirmation | 501--700 | 6,000 | 24,000 | 0.035 | sealed | `7a7e9cca9065f088a93b6c2b16cdaa3340209db9e5b3aa0160a0b227b3d3af3b` |

All replicate IDs are below the 1,000-seed spacing between scenario starts.
Dataset seeds are unique across phases and scenarios, while all four methods
within a dataset share its exact generated table.

The MCSE figures are worst-case Bernoulli standard errors at probability 0.5
for one scenario x method cell. They do not improve by pretending that four
paired methods or multiple design strata are independent replications.

## Candidate architecture

Six truth-blind scores and four rule families are registered. Target fraction,
target-to-residual ratio, backend difference, and ML/REML difference are
available from Draft.83d2b2a. Backend-specific target relative uncertainty and
the full-versus-reduced likelihood drop require a new enriched diagnostic
refit.

The backend-coordinate audit found:

- lme4 exposes named relative-SD `theta` coordinates and a profiled-deviance
  Hessian; and
- glmmTMB exposes formula-ordered log-SD `theta` coordinates and a joint fixed-
  coordinate covariance.

These are recorded as backend-specific diagnostics. Neither is relabelled as a
common component standard error, and the whole-model minimum curvature is not
substituted for target uncertainty.

No selected rule family, lower cutpoint, or upper cutpoint exists. The fixed
state space is `not_resolved`, `indeterminate`, `resolved`, and
`not_evaluable`. Computational non-evaluation retains its own denominator.

If calibration later observes zero false-ready events among 100 independent
replicates in one cell, the one-sided 95% exact-binomial upper bound is
0.029513. The record therefore prohibits the phrase “zero error rate” based on
zero observed events.

## Schema execution

The schema execution identity is:

`463a188717f389858635c5447d2c750b32920b5d370d3fbb39cbada43ed9780c`.

| Quantity | Result |
| --- | ---: |
| planned/attempted/returned fits | 24 / 24 / 24 |
| independent datasets | 6 |
| existing point-gate passes | 16 |
| atomic accounting | passed |
| feasibility evidence | false |
| calibration evidence | false |

Across both schema replicates, every exact-zero route passed the existing
whole-model gate. For numerical-near-zero and variance-0.12 reference cells,
one replicate passed and one failed on every method. These viewed results are
additional schema counterexamples only. They cannot enter the reserved
feasibility or calibration denominators.

## Test evidence

Six focused tests and 79 expectations pass without warning, skip, failure, or
error. They verify phase sizes and MCSE values, plan and manifest identities,
nonoverlapping seeds, method pairing, candidate non-selection, both score
directions, four-state accounting, exact-binomial upper bounds, the complete
24-fit schema execution, and fail-closed calibration/confirmation execution.

## Artifact identities

| Artifact | SHA-256 |
| --- | --- |
| `gtheory-weak-information-pilot-prototype-0.2.3.R` | `7b3bcf2f5e804007b27f65f58686d0ec134dcb79fc06d97ce2a382c4567b6b39` |
| `gtheory-weak-information-pilot-contract-0.2.3.md` | `025a62521e728c56044ee4b598a0cfafe7915e55791e4560aee0d35bd6515d44` |
| `test-gtheory-weak-information-pilot-prototype.R` | `27ef61125142c5b3da949ea9ab1c88d29723b3ba46b95de94acca1d9e80c2889` |

The record's own hash is omitted because recording it would change the file.

## Readiness and next gate

`FeasibilityEvidenceReady`, `CalibrationEvidenceReady`, `ThresholdFrozen`,
`ConfirmationAuthorized`, `ConfirmationViewed`, `RecoveryEvidenceReady`,
`InferenceReady`, `CoefficientEligible`, and `DecisionReady` remain false.

Draft.83d2b2b1 must implement the enriched backend-specific diagnostic refits
and execute the 25-replicate feasibility phase. It must report all 3,000
atomic rows, all 750 independent datasets, runtime/storage, missing diagnostic
rates, target/nuisance failure decomposition, and empirical score overlap. It
may reject candidate architectures or revise a future calibration plan under a
new specification identity, but it cannot select a final threshold or view
calibration/confirmation data.
