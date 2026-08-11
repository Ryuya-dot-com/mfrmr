# Draft.83d2b2b1f typed numerical-replay adjudication record

Status: completed repository-only adjudication of immutable viewed ledgers,
2026-08-10.

## Identity

| Object | SHA-256 / scientific identity |
| --- | --- |
| b1d feasibility execution | `04ec60ab6d4351c0d8c6416543fa8ac46e15585bbe85680f829b341beb34a22b` |
| b1e numerical contract | `0538eb1a7636d4d784f06c10bb17f65aa958f4e677005462d6309827292083c6` |
| b1e numerical manifest | `53880242ed7441c93516defbd840c289df32bbc6d0677e4b441bc2543eda8d2f` |
| b1e numerical execution | `37be0b4dbac852454ced612b5f84706678f688f3f3ea7209793111ab6a706d94` |
| b1f typed-replay contract | `8a18d59548ab5d8523e29f7089d2ea70620f51b38e2444e133a2e78974ff0d4a` |
| b1f typed-replay result | `e200a9ee7984bbc3be32ab5ef209ce2eb26c0b42c8df3ad758bab7baf559f8c1` |
| contract artifact | `b6d954e653a7a2e8eee0b722cebf13151f059fb25fbbf52f386da735e16c5e8c` |
| adjudicator source | `101b412ef0df88518e5e8add15d7a9b47b1de32acc2c5055298a2c5496ff67dd` |
| focused test source | `388872d997dd5b5214463e8aa6b57c7648d71700986fd37dfd0a258a2e78a869` |

The scientific result hash contains the contract identity, both upstream
execution identities, all 3,000 atomic adjudication rows, the five-state
counts, and exact-accounting state. It excludes file location and timing.

## Exact result

| Replay state | Count |
| --- | ---: |
| `finite_match` | 2,993 |
| `same_typed_nonfinite_state` | 7 |
| `finite_mismatch` | 0 |
| `nonfinite_state_mismatch` | 0 |
| `finite_nonfinite_mismatch` | 0 |
| **Total** | **3,000** |

All seven non-finite rows are `NA_real_` in both b1d and the b1e default
profile. For every one, `PairReturned=TRUE`,
`LikelihoodDiagnosticAvailable=FALSE`,
`NegativeDropWithinTolerance=FALSE`, and
`ComparisonState=not_evaluable_fit_or_identity_failure` also agree. No
non-finite row is assigned a zero numerical distance, promoted to an available
likelihood comparison, or counted as a material-negative difference.

The exact-ledger tier runs four focused tests and 55 expectations. It calls no
generator, fitting backend, optimizer, bootstrap, or calibration routine.

## Adjudication

- `ExactAccountingPassed = TRUE`;
- `TypedReplayAdjudicationReady = TRUE`;
- `B1eDefaultReplayPassed = FALSE`;
- `NumericalStabilizationReady = FALSE`;
- `NumericalSensitivityEvidenceReady = FALSE`;
- `CalibrationEvidenceReady = FALSE`;
- `ThresholdFrozen = FALSE`;
- `InferenceReady = FALSE`; and
- `DecisionReady = FALSE`.

This is not a retrospective repair of b1e. The b1e finite-only replay rule
remains failed under its own immutable definition. Draft.83d2b2b1f closes the
previously unspecified equality relation for typed non-finite diagnostic
states under a new contract. That distinction prevents both post hoc rule
relaxation and the opposite error of treating two missing values as a finite
likelihood difference.

## Consequence for the next gate

The replay ambiguity is closed, but the substantive glmmTMB instability is
not. Before calibration replicates 201--300 are generated, a new prospective
stabilization contract must bind at least:

1. the exact `start` parameter blocks and their extraction coordinate system;
2. cold-start and current-optimum restart identities;
3. scaled and unscaled gradient diagnostics;
4. Hessian positive-definiteness/eigenvalue diagnostics;
5. each alternative algorithm as a separate profile rather than a pooled
   winner; and
6. denominator-complete reporting of finite, non-finite, boundary, and
   likelihood-identity failures.

The official glmmTMB troubleshooting guidance motivates restart, gradient,
Hessian, and alternative-optimizer checks, while the `glmmTMB()` reference
makes its named internal `start` blocks part of fit identity. The experimental
`diagnose()` helper may supplement, but cannot define, the production gate:

- <https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html>
- <https://glmmtmb.github.io/glmmTMB/reference/glmmTMB.html>
- <https://glmmtmb.github.io/glmmTMB/reference/diagnose.html>

No algorithm, start rule, gradient/Hessian cutoff, practical-equivalence
threshold, bootstrap method, coefficient, or D-study decision is selected by
this adjudication.
