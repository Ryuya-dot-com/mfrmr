# mfrmr 0.2.3 GPCM score v4 confirmation result record

Status: one authorized fresh-process confirmation was consumed without retry
on 2026-08-11. The confirmation is rejected. The immutable artifact is
`validation-results/gpcm-score-v4-confirmation-source-bound/gpcm-score-v4-confirmation.rds`,
SHA-256
`f6683b41e84cf705f95b2bb1a2853f7dfa8da9ba6434ff1b116f7e88128a4887`.

## Provenance

| Component | SHA-256 |
|---|---|
| Runner | `53de91632f368bc404ff064b7819d820ee7f592db74b286071a70b8f88715c1a` |
| Authorization source | `677a21bd6d6c8fe6a735c137e6e7acfa8f43dce343594283ca5ec6c39d6402e2` |
| Prospectively sealed validator | `7646c8cfb042942c5bbc00454410e3f5528a370e057478e1c8e16a96acadcaf9` |
| Retrospective audit | `9b54fcabc4ece772bdcc587488ef4e3f043f4209b77f1c2d2ba26df2dec96c09` |
| Runner identity | `14bccb69494f98798abf3dd23dbf51ea18107d19d251e9df2dad29011400be2f` |
| Six-scenario manifest | `04efdbcb857f6bd99ee4295e560594e6e1fd005a7623864e40bd857b34cf5b33` |
| Issued authorization row | `318e81e55537fb790ceab00bf0abeef4266744004d34050c91e714ba2b764021` |
| Consumed authorization row | `926efad7663fa02a8a5ec494bb61e68e3ad296ed9e5f82f6b8a503d374ab21f8` |

The authorization records the actual absolute artifact path. The issued and
consumed rows, source chain, manifest, fixture identities, and target resolve
without modification. No second execution occurred.

## What passed

All six fits returned finite parameter vectors, and the complete fixed
denominator is present: 96 evidence rows, 888 coordinate rows, 24 point rows,
and 688 entrywise Jacobian rows. The no-fit retrospective audit independently
reconstructs class counts and all evidence/point aggregations. It obtains:

| Check | Maximum combined ratio |
|---|---:|
| Analytic score versus independent oracle | 0.8123224 |
| Five-point finite-difference score | 0.002249138 |
| Log-scale transformation Jacobian | 0.4989336 |
| Positive-slope transformation Jacobian | 0.7571565 |

All are at or below the frozen unit-ratio rule. All constructed points are in
the finite region. Their maximum raw boundary excess is
`8.881784e-16`, below the maximum binary64 construction allowance
`1.162562e-14`. Retained fits are correctly handed to extreme-slope review;
these facts support the narrow statement that the recorded implementation-
mathematics checks passed at the evaluated vectors.

## Why confirmation is rejected

Two independent failures prevent acceptance:

1. `BRAID5-C` and `FAN7-C` reached optimizer code 1 (`iteration_limit`) and
   have `FitReadiness = blocked`. The other four fits have code 0 but remain
   `review`, not inference-ready. The prospectively sealed fit gate therefore
   fails with two blocked and four review fits.
2. The runner's final decision did not include fit convergence/readiness and
   returned `v4_candidate_score_confirmation_pass`. This is a false-positive
   aggregation decision relative to the sealed validation contract.

The prospectively sealed validator also has a narrower implementation defect:
it compares an unnamed 24-value `SlopeRegion` vector with an equal `vapply()`
result carrying names by `identical()`. Values agree 24/24 after removing the
names attribute, and every other independently reconstructed numerical
aggregation passes. This false-negative validator defect does not rescue the
confirmation, because the two blocked fits independently fail the fit gate.
The sealed runner, authorization, and validator are preserved unchanged so
their artifact-bound hashes remain auditable.

## Claim disposition

The authoritative retrospective status is
`rejected_runner_false_positive_and_blocked_fits`:

- `NumericalImplementationChecksPass = TRUE`;
- `SealedValidatorAccepted = FALSE`;
- `FitGatePass = FALSE`;
- `RunnerDecisionFalsePositive = TRUE`;
- `ConfirmationAccepted = FALSE`.

Retry and rule adjustment are not authorized. The result does not freeze a
general score tolerance, prove a global GPCM boundary, authorize inference, or
promote the 0.2.3 bounded-GPCM capability. The proper roadmap response is to
retain review-only public scope, repair future validation infrastructure under
a new prospective contract/version, and avoid rerunning this sealed design.
