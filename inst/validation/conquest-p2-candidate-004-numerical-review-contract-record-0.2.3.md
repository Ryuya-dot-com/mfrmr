# ConQuest P2 candidate-004 numerical-review contract for mfrmr 0.2.3

Status: `candidate_004_numerical_adjudication_contract_frozen_no_metric_result_recorded`,
2026-08-15.

- Specification:
  `0.2.3-conquest-p2-candidate-004-numerical-review-contract-v1`
- Contract:
  `mfrmr_conquest_p2_candidate_004_numerical_review_contract_v1`
- Candidate: `mfrmr-0.2.3-conquest-p2-minimum-diagnostic-004`

This contract was written after the four native output schemas were available
for inspection. It therefore does not claim an unseen-output freeze. The
scientific acceptance budgets, q61--q121 governing pair, conditional-
probability bound, and ordering tie bands all predate candidate 004 and are
reused without change. No candidate-004 numerical result is embedded in this
record, and the reviewer is committed before its full metric computation.

## Fixed budgets

| quantity | absolute limit | basis |
| --- | ---: | --- |
| ConQuest − mfrmr common coordinate | `1e-5` | frozen exact-reported-decimal P2 rule |
| ConQuest − mfrmr positive deviance | `2e-6` | frozen matched-constant P2 rule |
| q121 − q61 coordinate, each engine | `2e-6` | frozen successor integration rule |
| q121 − q61 deviance, each engine | `2e-6` | frozen successor integration rule |
| conditional probability | model-specific derived bound | frozen A-matrix transport rule |
| Rater/Criterion tie classification | `2e-5` tie band | twice the coordinate budget |

ConQuest decimal tokens are exact reported-output estimands. The file rounding
rule and hidden optimizer solution remain unknown. Exact displayed equality is
therefore not hidden-solution equality.

## Complete candidate-004 numerical-core denominator

| layer | atomic count |
| --- | ---: |
| Native A matrices | 4 |
| Raw final reported tokens, including deviance | 52 |
| Cross-engine coordinates, q61 and q121 | 64 |
| Cross-engine deviances, q61 and q121 | 4 |
| Within-engine q61--q121 coordinates | 64 |
| Within-engine q61--q121 deviances | 4 |
| q121 conditional probabilities | 480 |
| q121 Rater/Criterion pair classifications | 18 |
| EAP typed-ineligible Person records | 96 |
| Posterior-SD typed-ineligible Person records | 96 |
| mfrmr readiness-retention rows | 2 |
| decision-consequence rows | 2 |

Free native coordinates are expanded under the declared sum-zero constraints:
Rater R4, Criterion C3, the shared RSM third step, and each PCM Criterion's
third step are reconstructed from their retained decimal source tokens. The
native A matrix must match the repository's conditional-log-kernel matrix
after semantic GIN/Rater/Criterion/category reindexing; byte identity is not a
scientific gate.

The review uses both q61 and q121 for cross-engine checks, even though q121 is
the governing upper grid. This prevents an engine-by-integration discrepancy
from being hidden by reporting only the selected endpoint. EAP and posterior
SD remain numerically ineligible because their posterior identity and budget
were not frozen; their rows stay in the denominator as typed states.

This is the complete numerical core for the two candidate-004 RSM/PCM rows,
not the complete P2 design portfolio. Missingness, extreme-person, unused-
category, disconnected-design, DFF, fit, and broader P2/P3 rows remain open.
Even a full pass cannot make mfrmr inference-ready while
`design_rank_not_evaluated` remains, and cannot authorize rerun, widening,
evidence promotion, or a public claim without independent review.

## Current decision

- `MetricResultRecorded=FALSE`
- `Candidate004OutputTuned=FALSE`
- `RerunAuthorized=FALSE`
- `IndependentComprehensiveReviewPassed=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `WiderExecutionAuthorized=FALSE`
- `P3ExecutionAuthorized=FALSE`
- `PublicClaimAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
