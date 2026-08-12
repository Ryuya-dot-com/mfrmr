# ConQuest candidate-003 numerical review for mfrmr 0.2.3

Status: all 57 prospectively frozen exact-reported-decimal rows pass for
candidate 003, 2026-08-12. This confirms the bounded reported-decimal
comparison; it does not establish equality of hidden unrounded optimizer
solutions, scientific equivalence, or inference readiness.

## Bound comparison identity

| Field | Value |
| --- | --- |
| Candidate ID | `mfrmr-0.2.3-conquest-six-arm-003` |
| Numerical-review contract | `mfrmr_conquest_six_arm_candidate_003_numerical_review_v1` |
| Frozen tolerance-table SHA-256 | `64ab3338dc5e5144d98a7a8775512b5665f407e4d8778972521ff5bfe8754521` |
| Locale-independent 54-coordinate bundle SHA-256 | `77ada46c876b3280b054f423b6a5717e71643ad65716796256f92c08c90b0dac` |
| Locale-independent 57-row ledger SHA-256 | `8a248d978ee4b319351110404380caa242bf58e4cb20abbd9d3d745b45c2b8f0` |
| Source-precision scope | `exact_reported_decimal` |

The coordinate and ledger hashes use explicit radix ordering followed by a
numeric canonical row key. This prevents locale-dependent ordering of mixed-
case coordinate names from changing the evidence hash.

## Cross-engine result

The prospective external limits are `1e-5` for common model coordinates and
`2e-6` for positive deviance. Every coordinate within each estimand class must
meet both its signed interval and absolute limit; a class does not pass by
averaging compensating errors.

| Family | estimand class | maximum absolute ConQuest − mfrmr difference | limit |
| --- | --- | ---: | ---: |
| Binary | population intercept | 9.126076e-7 | 1e-5 |
| Binary | population slope | 1.002108e-6 | 1e-5 |
| Binary | population variance | 5.761704e-6 | 1e-5 |
| Binary | item difficulty | 1.160647e-6 | 1e-5 |
| Binary | deviance | 4.141540e-7 | 2e-6 |
| RSM | population intercept | 7.925587e-8 | 1e-5 |
| RSM | population slope | 6.960769e-7 | 1e-5 |
| RSM | population variance | 2.733885e-6 | 1e-5 |
| RSM | rater severity | 5.723291e-7 | 1e-5 |
| RSM | criterion difficulty | 5.723181e-7 | 1e-5 |
| RSM | shared step | 1.785341e-6 | 1e-5 |
| RSM | deviance | 2.220039e-7 | 2e-6 |
| PCM | population intercept | 1.756509e-7 | 1e-5 |
| PCM | population slope | 8.856360e-7 | 1e-5 |
| PCM | population variance | 1.927770e-6 | 1e-5 |
| PCM | rater severity | 2.878647e-7 | 1e-5 |
| PCM | criterion difficulty | 3.262862e-7 | 1e-5 |
| PCM | criterion-specific step | 2.096538e-6 | 1e-5 |
| PCM | deviance | 4.315290e-7 | 2e-6 |

All 19 `EXT-CQ-TOL` rows pass. The comparison uses the exact decimal strings
retained in the native CSV exports and independently verifies the 7- and
9-dimensional RSM/PCM A matrices. It does not infer extra digits between the
reported decimal and an undocumented hidden solution.

## Integration result

The prospective q61-minus-q31 limit is `2e-6` for both common coordinates and
deviance. ConQuest q31 and q61 final CSV coordinates are identical at their
retained decimal precision for Binary, RSM, and PCM, so all ConQuest-side
differences are zero. The largest mfrmr-side differences are:

| Family | maximum absolute q61 − q31 difference |
| --- | ---: |
| Binary | 1.130346e-14 |
| RSM | 1.651801e-11 |
| PCM | 1.660005e-11 |

All 38 `IC-INTEGRATION-TOL` rows pass: 19 for ConQuest and 19 for mfrmr.

## Scope and disposition

| Field | Value |
| --- | --- |
| `CoordinateRowsObserved` | `54` |
| `ToleranceRowsObserved` | `57` |
| `ToleranceRowsPassed` | `57` |
| `CrossEngineRowsPassed` | `19/19` |
| `IntegrationRowsPassed` | `38/38` |
| `ComparisonPassed` | `TRUE` |
| `ReportedDecimalConfirmationPassed` | `TRUE` |
| `HiddenSolutionIntervalAvailable` | `FALSE` |
| `HiddenSolutionEquivalenceEligible` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |
| `InferenceReady` | `FALSE` |
| `DFFFitRankInvarianceEvaluated` | `FALSE` |
| `GenericConfirmationAuthorized` | `FALSE` |
| `ReleaseAuthorized` | `FALSE` |
| `SparseExtensionAuthorized` | `FALSE` |
| `GPCMExtensionAuthorized` | `FALSE` |
| `LargeSimulationAuthorized` | `FALSE` |

The comparison closes the bounded candidate-003 Binary/RSM/PCM MML overlap at
the exact-reported-decimal layer. It does not test DFF decisions, infit/outfit,
person or rater rankings, Hessian coverage, sparse allocation, extreme-score
behavior, or GPCM free-slope behavior. Those remain separate claims and must
not inherit this pass.

## Source identities

| Artifact | SHA-256 |
| --- | --- |
| `conquest-six-arm-candidate-003-numerical-review-0.2.3.R` | `31eaa5fcc273219aa3347396030562105265ac89410472cb685182b1e09f5edb` |
| `conquest-six-arm-candidate-003-execution-result-0.2.3.R` | `cd450342e1ccec8ca5393f95be3f7a069d7b805a54b3f26da400efa879bb20c3` |
| `tests/testthat/test-conquest-six-arm-candidate-003-numerical-review.R` | `941c95ac7536eb12063fa8b68caa84287e461f4875710969fbb15ca679e22af2` |
