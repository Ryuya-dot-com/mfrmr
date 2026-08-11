# Draft.83d2b1 atomic G-theory ADEMP fit execution record

Date: 2026-08-09
Scope: repository-only one-replicate atomic point-fit execution
Result: atomic accounting passed; near-boundary zero-false-ready gate failed

## Outcome

All 89 Draft.83d1 planned fit units received one atomic result. The 12 units
blocked by Draft.83d2b0 were recorded as typed `pre_fit` failures without a
backend call. All 77 structurally eligible units were attempted and returned a
balanced-MoM, lme4, or glmmTMB point result.

The deterministic execution identity was reproduced in two fresh R processes:

`1b0fa928f1aba1a9ac09bc3ec1c790f7fb94911a92cc6ea13ee7ad92d4884d49`.

The two observed aggregate adapter runtimes were 25.721 and 26.255 seconds.
Runtime is deliberately excluded from the execution hash.

## Recorded environment

| Dependency | Version |
| --- | --- |
| R | 4.6.1 (2026-06-24) |
| lme4 | 2.0.6 |
| glmmTMB | 1.1.14 |
| TMB | 1.9.23 |
| digest | 0.6.39 |

## Atomic accounting

| Quantity | Result |
| --- | ---: |
| planned units | 89 |
| pre-fit eligible | 77 |
| fit attempts | 77 |
| fits returned | 77 |
| optimizer/computational completion | 77 |
| point gates passed | 57 |
| typed failures | 32 |
| unrecorded units | 0 |
| exact accounting | passed |
| zero false-ready | **failed** |

Every failed point gate has one typed failure stage/code. No successful-only
pooling or denominator deletion occurred.

## Results by method

| Method | Attempted | Returned | Point gate passed |
| --- | ---: | ---: | ---: |
| balanced MoM | 1 | 1 | 1 |
| lme4 REML | 19 | 19 | 14 |
| lme4 ML | 19 | 19 | 13 |
| glmmTMB REML | 19 | 19 | 15 |
| glmmTMB ML | 19 | 19 | 14 |

The balanced MoM result contains one finite negative raw Criterion component.
It is retained as unconstrained moment output; it is not clipped to zero or
mislabelled as a likelihood boundary. `OptimizerConverged=TRUE` for this row
means deterministic equation completion, not iterative optimization.

## Failure decomposition

| Failure stage | Count |
| --- | ---: |
| pre-fit structural block | 12 |
| returned fit at boundary or lme4 singularity | 15 |
| returned fit with unavailable/nonpositive/rank-deficient local curvature | 5 |
| total | 32 |

The pre-fit rows are exactly the four registered ML/REML x backend units for
each of `GT-SPARSE-CYCLE-LOW`, `GT-NEG-DISCONNECTED`, and
`GT-NEG-ALIASED`.

Returned-fit failures also remain visible:

- all four likelihood routes fail regularity in `GT-EXACT-N030`;
- the two lme4 routes fail local curvature in `GT-EXACT-N300`;
- all four `GT-EXACT-R02-C02` routes fail either regularity or local curvature;
- the two ML routes fail regularity in `GT-BOUNDED-K03-ENDHI`;
- all four routes fail regularity in `GT-LD-RHO050`; and
- all four exact-zero boundary routes fail regularity or local curvature.

These are one generated replicate and are not method-performance rates.

## Retained near-boundary concern

All four routes for `GT-BOUNDARY-NEARZERO` pass the current point gate. Their
Rater variance estimates are:

| Method | Estimate |
| --- | ---: |
| lme4 REML | 0.0051726 |
| glmmTMB REML | 0.0051785 |
| lme4 ML | 0.0038897 |
| glmmTMB ML | 0.0038856 |

The nominal generating Rater variance is `1e-10`, but that truth is not an
observable fitting diagnostic. Each route has optimizer completion, a finite
component vector, no component below the current absolute `1e-8` tolerance,
and positive/full-rank registered local curvature. Consequently the current
gate produces four false-ready rows and
`ZeroFalseReadyPassed=FALSE`.

This concern is retained rather than repaired post hoc. Increasing the
absolute boundary tolerance after observing these estimates, or checking the
simulation truth inside the fitting gate, would invalidate the negative
control. The next calibration must pre-register an observable weak-information
rule, include genuinely small but estimable positive controls, and report its
false-positive/false-negative behavior.

## Test evidence

Six focused tests contain 58 evaluated expectations and one explicit skip for
the resource-tier 89-unit rerun. They verify curvature classification,
backend non-entry for blocked rows, negative raw MoM retention, four passing
interior N=100 routes, identity failure, and the opt-in full-smoke assertions.
The full 89-unit runner was executed separately twice for this record and
reproduced the same execution hash and counts.

## Artifact identities

| Artifact | SHA-256 |
| --- | --- |
| `gtheory-ademp-fit-prototype-0.2.3.R` | `72fd22bf280666358f3a112d6788bf36bf3b4400c9032e78937bbf2d3a0d866d` |
| `gtheory-ademp-fit-contract-0.2.3.md` | `e46f0c5afce2a4f0eff2eace3f8f722bfc0eaa1791dd8c316fe3297d9e4c8956` |
| `test-gtheory-ademp-fit-prototype.R` | `0597e8339389ab1a0af3a6f282baac43644ef66e375e1b5db227fe2b4b36c85d` |

The record's own hash is omitted because recording it would change the file.

## Readiness and next gate

Atomic completion is true, but recovery promotion is blocked by the
near-boundary result and by the absence of replicated recovery metrics. The
runner retains `RecoveryEvidenceReady=FALSE`, `InferenceReady=FALSE`,
`CoefficientEligible=FALSE`, and `DecisionReady=FALSE`.

The next slice must be a pre-registered weak-information calibration, not
effect extraction alone. It should compare observable component-scale and
curvature/uncertainty diagnostics over zero, near-zero, small-positive, and
ordinary-positive variance cells, across level counts, observations per
level, sparse topology, and workload imbalance. Only after its operating
characteristics are frozen should Draft.83d2 add centered effect recovery and
the broader ADEMP pilot. Draft.84 remains the interval gate.
