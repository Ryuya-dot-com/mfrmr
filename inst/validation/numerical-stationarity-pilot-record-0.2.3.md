# mfrmr 0.2.3 numerical-stationarity pilot record

## Decision boundary

This is a `0.2.3-draft.12` M2 pilot and structural-regression record. It is not
a release-candidate result and does not freeze `NUM-SCORE-TOL`, authorize
confirmation, authorize model selection, or establish cross-engine solution
agreement.

The pilot checks the derivative of the package's retained marginal objective
with an independently implemented central-difference algorithm. It does not
independently reimplement the marginal likelihood itself; external objective
and parameter agreement remain separate gates.

## Identity

| Field | Value |
| --- | --- |
| Specification | `0.2.3-draft.12` |
| Contract | `mfrmr_mml_canonical_score_audit_v1` |
| Runner | `numerical-stationarity-pilot-0.2.3.R` |
| Run date | 2026-07-28 |
| Repository baseline | `10cf3e8e8ff0` plus the uncommitted draft.12 working-tree changes |
| Branch | `agent/refine-0.2.3-roadmap` |
| DESCRIPTION during development | `0.2.2` (the submitted 0.2.2 release remains isolated) |
| R | R 4.6.1, `aarch64-apple-darwin23` |
| Fixture hashing | digest 0.6.39, SHA-256 |
| Evidence status | `review` |
| Score-tolerance status | `pilot_required` |
| Engine-parity status | `not_run` |
| Selection/confirmation authorized | No / No |

Because the working tree is not a frozen candidate, the baseline commit is
context only. M3 must replace it with one exact source/tarball manifest before
candidate-linked evidence is run.

## Fixed design

All fits use direct MML, L-BFGS-B, q=31, `maxit = 2000`, and
`reltol = 1e-12`. The numerical reference uses three-point central differences
at relative steps `1e-4`, `3e-5` (primary), and `1e-5`.

| Run | Model | Fixture | Free coordinates | Audited points |
| --- | --- | --- | ---: | --- |
| `binary_rsm` | RSM | `binary_fixed` | 3 | retained solution; deterministic probe |
| `binary_pcm` | PCM | `binary_fixed` | 3 | retained solution; deterministic probe |
| `rsm_core` | RSM | `polytomous_fixed` | 5 | retained solution; deterministic probe |
| `pcm_core` | PCM | `polytomous_fixed` | 11 | retained solution; deterministic probe |
| `gpcm_core` | GPCM | `polytomous_fixed` | 14 | retained solution; high-dispersion probe |

The nonzero-score probes prevent a near-zero retained gradient from hiding a
derivative mismatch.

### Fixture identity

| Fixture | Seed | Persons | Items | Scores | Rows | SHA-256 |
| --- | ---: | ---: | ---: | --- | ---: | --- |
| `binary_fixed` | 20260741 | 60 | 4 | 0--1 | 240 | `acde9c859ad63d8b1b0736f19ae5869c72384734133eafb7602382d97b9b0f21` |
| `polytomous_fixed` | 20260742 | 60 | 4 | 0--3 | 240 | `383979d685be5719d2844476eeb1126dd586d070c7a1926199ac31f89867ae1e` |

Every declared category occurs for every item. Fixture generation preserves
the caller's RNG state.

## Canonical free-score results

`Max abs score` is the largest absolute analytic objective derivative at the
audited point. `Max abs difference` compares it with the primary central
difference. `Max step range` is the largest range of the numeric derivative
over the three reference steps for any coordinate. All source fits reported
`InferenceReady = TRUE`, but that package state does not replace this audit.

| Run | Point | Max abs score | Max abs difference | Max scaled difference | Max step range |
| --- | --- | ---: | ---: | ---: | ---: |
| `binary_rsm` | retained | 6.7907e-8 | 2.4454e-9 | 2.4454e-9 | 1.2648e-8 |
| `binary_rsm` | probe | 9.2456e-1 | 1.7555e-9 | 1.7555e-9 | 1.0658e-8 |
| `binary_pcm` | retained | 6.7907e-8 | 2.4454e-9 | 2.4454e-9 | 1.2648e-8 |
| `binary_pcm` | probe | 9.2456e-1 | 1.7555e-9 | 1.7555e-9 | 1.0658e-8 |
| `rsm_core` | retained | 3.1179e-5 | 2.1579e-9 | 2.1579e-9 | 4.1211e-8 |
| `rsm_core` | probe | 3.5295e+0 | 3.5546e-9 | 1.8977e-9 | 3.1548e-8 |
| `pcm_core` | retained | 3.9877e-5 | 3.6040e-9 | 3.6040e-9 | 3.9790e-8 |
| `pcm_core` | probe | 2.8499e+0 | 3.2395e-9 | 3.2395e-9 | 3.8938e-8 |
| `gpcm_core` | retained | 9.5003e-6 | 3.8881e-9 | 3.8881e-9 | 2.1600e-8 |
| `gpcm_core` | high-dispersion probe | 1.6685e+1 | 6.9089e-9 | 6.9089e-9 | 6.9065e-8 |

The observed maximums are calibration inputs, not acceptance thresholds.
Freezing a threshold directly from these maxima without expanding the pilot
grid and recording a margin rule would be post-result tuning.

## GPCM coordinate and Jacobian audit

The existing bounded-scope GPCM implementation has no optimizer box bounds.
For `J` slope levels it uses free coordinates `u[1:(J-1)]`, expands

`log(a) = (u[1], ..., u[J-1], -sum(u))`,

and sets `a = exp(log(a))`. Thus all slopes are positive and their geometric
mean is one. The expanded-log Jacobian is `[I; -1']`; the positive-slope
Jacobian is `diag(a) [I; -1']`. This is a transformed-coordinate stationarity
contract, not a projected-gradient contract.

| Point | Free/expanded slopes | Min slope | Max slope | Geometric-mean residual | Max log-Jacobian difference | Max slope-Jacobian difference |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| retained | 3 / 4 | 0.84158 | 1.27793 | 3.47e-17 | 1.00e-12 | 3.33e-11 |
| high-dispersion probe | 3 / 4 | 0.45227 | 2.21108 | 2.78e-17 | 1.40e-10 | 3.00e-10 |

The high-dispersion point exercises a materially wider positive-slope range,
but it is not yet a frozen near-boundary grid. That grid and its acceptance
rule remain M2 work.

## Exact reductions

| Reduction | Log-probability max difference | Probability max difference | Objective difference | Common-score max difference | Free dimensions |
| --- | ---: | ---: | ---: | ---: | --- |
| binary RSM = binary PCM | 0 | 0 | 0 | 0 | 3 / 3 |
| unit-slope GPCM = PCM | 0 | 0 | 0 | 4.4131e-15 | 11 / 14; 11 common coordinates |

For the second row, the three additional GPCM free log-slope coordinates are
zero, so all four expanded slopes equal one. These exact regression checks
cover the log-probability matrix, probability matrix, objective, and common
analytic derivative coordinates under one identification.

## Fail-closed checks

The repository test file `test-numerical-stationarity-pilot.R` passed 104
expectations in the targeted run. It covers:

- fixed plan, fixture hashes, category support, and no source-time fitting;
- canonical free-coordinate labels and an independent quadratic derivative;
- missing, duplicate, and non-finite central-difference rows;
- the analytic and numeric GPCM log/slope Jacobians;
- exact binary and unit-slope reductions; and
- global rejection of incomplete score, Jacobian, reduction, or fixture
  evidence.

## Line drawn for 0.2.3

Draft.12 takes the following into the 0.2.3 development baseline:

- the repository-only five-run score pilot and immutable fixture identities;
- the canonical identified-free-coordinate score record;
- the corrected transformed-GPCM coordinate/Jacobian description; and
- exact binary/unit-slope probability, objective, and score regressions with
  fail-closed tests.

The following remain unresolved M2 work and cannot be presented as release
evidence yet:

- expanded model/parameter-class and near-boundary pilot cells, followed by a
  reviewed frozen absolute/scaled `NUM-SCORE-TOL`;
- direct, hybrid, and EM-plus-polish evaluation at common retained vectors,
  with frozen objective and transformed-parameter tolerances;
- negative iteration-ceiling/readiness propagation checks under the frozen
  rerun policy;
- disjoint confirmation fixtures/seeds tied to one M3 candidate; and
- independent-platform and external-engine replication where required by G5.

No 0.2.2 source package, submitted tarball, or CRAN release assertion is
changed by this repository-only draft.12 record.
