# ConQuest candidate-003 numerical-reference preflight for mfrmr 0.2.3

Status: all six candidate-003 mfrmr numerical references are source- and
artifact-bound; external execution handoff is not frozen, 2026-08-12. No
candidate-003 ConQuest process has been launched and all 50 expected outputs
remain absent.

## Identity and provenance

| Field | Value |
| --- | --- |
| Candidate ID | `mfrmr-0.2.3-conquest-six-arm-003` |
| Reference source commit | `4f86fa187e010d3c9faff647c88abc38ddcf5b0f` |
| Reference-artifact bundle SHA-256 | `0d23be47efce2965c8f4fa76c93d6aa569bc5aa313bce6550286ac2d9f7942a8` |
| Reference-source bundle SHA-256 | `cd37c3b75517c7af6afb4834fd6ec26d3e6b254a0a966c9b425d15d74ad986c2` |
| Reference-provenance bundle SHA-256 | `556c87bcfa8b70e46e4f89389edbe99a31e9dcd8cc7577e2e8e22bcbbb10d7c1` |
| Candidate binding | `mfrmr_conquest_six_arm_candidate_003_binding_v1` |
| Numerical-reference contract | `mfrmr_conquest_six_arm_candidate_003_reference_v1` |

The 16 primary reference artifacts have the same hashes as candidate 002.
This is deterministic reproduction under unchanged estimator, fixture, and
quadrature contracts, not reuse of a ConQuest result. Candidate 003 has fresh
working and output paths and has not been externally executed.

The additive source manifest, reference manifest, and q-sensitivity file are
bound separately. Every path and SHA-256 in the additive source manifest was
checked against the candidate-003 repository source, its aggregate source-tree
hash was reconstructed, and all four reference-manifest rows agree with it.

## Numerical result

| Arm | free dimension | deviance | terminal gradient sup norm | independent oracle | local full rank | inference-ready |
| --- | ---: | ---: | ---: | --- | --- | --- |
| Binary q31 | 8 | 424.738979414154 | 1.50e-7 | not separately implemented | not retained | no |
| Binary q61 | 8 | 424.738979414154 | 1.50e-7 | not separately implemented | not retained | no |
| RSM q31 | 7 | 930.984395777999 | 4.96e-6 | pass | 7/7 | no |
| RSM q61 | 7 | 930.984395777996 | 4.96e-6 | pass | 7/7 | no |
| PCM q31 | 9 | 930.504779568474 | 1.30e-6 | pass | 9/9 | no |
| PCM q61 | 9 | 930.504779568471 | 1.30e-6 | pass | 9/9 | no |

RSM and PCM pass independent adjacent-category probability and marginal-
likelihood oracles, quadrature-weight checks, and exhaustive 512-pattern
local score-rank audits. The Binary reference basis remains explicitly weaker:
finite internally consistent coordinates, centered item constraint, finite
objective, and terminal gradient below `1e-5`. Neither a Binary independent
oracle nor a Binary local-rank claim is inferred.

All six references retain `InferenceReady = FALSE`. Numerical-reference
readiness is only permission to compare arithmetic quantities under the frozen
coordinate map and tolerance table; it is not an inferential or scientific
equivalence claim.

## q31/q61 integration stability

| Family | maximum coordinate difference | coordinate limit | deviance difference | deviance limit | result |
| --- | ---: | ---: | ---: | ---: | --- |
| Binary | 1.13e-14 | 2e-6 | 0 | 2e-6 | pass |
| RSM | 1.65e-11 | 2e-6 | 2.96e-12 | 2e-6 | pass |
| PCM | 1.66e-11 | 2e-6 | 2.96e-12 | 2e-6 | pass |

These are within-mfrmr checks made without reading any candidate-003 ConQuest
output. They do not establish cross-engine equivalence.

## Machine disposition

| Field | Value |
| --- | --- |
| `NumericalReferenceReady` | `TRUE` |
| `InferenceReady` | `FALSE` |
| `NumericalReferencePromotesInference` | `FALSE` |
| `CandidateExecutionAuthorized` | `FALSE` |
| `ExecutionHoldReason` | `candidate_003_execution_handoff_not_frozen` |
| `ComparisonAuthorized` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |
| `ConfirmationAuthorized` | `FALSE` |
| `SparseExtensionAuthorized` | `FALSE` |
| `LargeSimulationAuthorized` | `FALSE` |

The next gate is a candidate-003-specific execution handoff. It must recheck
the exact executable, source/bundle/reference identities, six working
directories and stdin commands, and the still-empty 50-output manifest. It may
authorize only the six bounded executions, not comparison or confirmation.

## Source identities

| Artifact | SHA-256 |
| --- | --- |
| `conquest-six-arm-candidate-003-reference-preflight-0.2.3.R` | `0a6efd41749bc1b144f256a1daf549ee759e453891932ba793668f5c5a574e35` |
| `conquest-six-arm-candidate-003-binding-0.2.3.R` | `968a5ec6685f9051adfa69bddd18a28d312152182b055d117b39e979ec74387e` |
| `tests/testthat/test-conquest-six-arm-candidate-003-reference-preflight.R` | `868517ab50eaeacc7583521a26681ce0a492d21f2c3d63e534efcac345fd0ae2` |

