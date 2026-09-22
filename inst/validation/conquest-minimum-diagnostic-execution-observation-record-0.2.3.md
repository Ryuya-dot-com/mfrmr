# ConQuest minimum diagnostic execution observation for mfrmr 0.2.3

Status: `diagnostic_halted_fixture_signal_defect_no_rerun_authorized`,
2026-08-15.

- Specification:
  `0.2.3-conquest-minimum-diagnostic-execution-observation-v1`
- Contract:
  `mfrmr_conquest_minimum_diagnostic_execution_observation_v1`
- Candidate: `mfrmr-0.2.3-conquest-p2-minimum-diagnostic-001`
- Output root:
  `validation-results/conquest-p2-minimum-diagnostic-20260815-v1`
  (ignored retained evidence; not committed)

## Outcome

The run-once harness prepared the exact four-arm bundle. All four fixed mfrmr
fits completed with the expected free dimensions (RSM 10, PCM 14), but all four
remained not inference-ready under the existing readiness contract. This state
was retained rather than upgraded.

The first ConQuest arm, RSM q31, exited with status 0 and the terminal marker,
but estimation stopped when the latent variance estimate became negative.
Only two of eight native outputs were nonempty. Four registered downstream
failure patterns were present: model not estimated, unknown equation symbol,
compute error, and print error. The harness therefore classified semantic
failure and did not launch RSM q61 or either PCM arm.

| Engine | Authorized cap | Attempted | Structurally complete | Unattempted |
| --- | ---: | ---: | ---: | ---: |
| mfrmr | 4 | 4 | 4 | 0 |
| ConQuest | 4 | 1 | 0 | 3 |

This is a retained failed diagnostic, not a cross-engine numerical comparison.
It provides no evidence of equivalence or inequivalence.

## Engine-independent fixture diagnosis

The failure is not adequately described as a ConQuest command problem. Direct
inspection of the sealed fixture, without fitting either engine, gives:

| Quantity | Observed |
| --- | ---: |
| Persons | 48 |
| Response rows | 288 |
| Responses per Person | 6 |
| Person total-score support | 8 or 10 only |
| Persons at score 8 / 10 | 24 / 24 |
| Mean total score for X=-1 / X=+1 | 9 / 9 |
| Correlation of Person total score with X | 0 |
| Each Rater-by-category count | 18 |
| Each Criterion-by-category count | 24 |

The modular deterministic response rule exactly balances every Rater and
Criterion over categories and supplies no total-score separation by X. The
four retained mfrmr population estimates independently localize the same issue:
the fitted variance is approximately zero rather than an ordinary interior
population variance. Those estimates are diagnostic traces only and are not
used for cross-engine acceptance.

The P2 construction gate proved connectivity, category support, dimensions,
and mathematical coordinate maps, but did not require nondegenerate empirical
population signal. That omission is now classified as a fixture-contract
defect for this proposed numerical comparison row.

## Decision

| Authority | Value |
| --- | --- |
| `CandidateRunOnceConsumed` | `TRUE` |
| `ExactTwoRowSliceCompleted` | `FALSE` |
| `CurrentCandidateRerunAuthorized` | `FALSE` |
| `ReplacementCandidateExecutionAuthorized` | `FALSE` |
| `FixtureSupersessionRequired` | `TRUE` |
| `IndependentReviewIsNextExecutionBlocker` | `FALSE` |
| `IndependentReviewStillBlocksEvidencePromotion` | `TRUE` |
| `IndependentComprehensiveReviewPassed` | `FALSE` |
| `EvidencePromotionAuthorized` | `FALSE` |
| `WiderExecutionAuthorized` | `FALSE` |
| `P3ExecutionAuthorized` | `FALSE` |
| `PublicClaimAuthorized` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |

An independent post-output review is not the next execution blocker because
there is no promotable comparison result. The higher-value next step is to
supersede the response generator and add a prospective nondegenerate-signal
gate while preserving the sparse graph, support, dimensions, and metric
contract. Independence remains mandatory before any later successful result
is promoted.

No current-candidate rerun, q-only retry, node-range adjustment, partial-output
salvage, or PCM-first attempt is authorized. A replacement requires a new
candidate identity, clean candidate directory, refreshed data-free runtime
sentinel, and new minimum authorization.
