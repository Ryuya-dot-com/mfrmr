# ConQuest P2 candidate-004 execution observation for mfrmr 0.2.3

Status: `candidate_004_four_arm_execution_complete_numerical_review_pending`,
2026-08-15.

- Specification:
  `0.2.3-conquest-p2-candidate-004-execution-observation-v1`
- Contract:
  `mfrmr_conquest_p2_candidate_004_execution_observation_v1`
- Execution identity:
  `mfrmr-0.2.3-conquest-p2-dense-pair-004-external-001`
- Installed runtime: ConQuest 5.47.5 Demonstration Version through the frozen
  x86_64/Rosetta invocation route

## Retained execution denominator

| arm | expected free dimension | attempt count | exit | terminal marker | registered semantic errors | native outputs |
| --- | ---: | ---: | ---: | --- | ---: | ---: |
| RSM q61 | 10 | 1 | 0 | present | 0 | 8/8 |
| RSM q121 | 10 | 1 | 0 | present | 0 | 8/8 |
| PCM q61 | 14 | 1 | 0 | present | 0 | 8/8 |
| PCM q121 | 14 | 1 | 0 | present | 0 | 8/8 |

All four authorized arms reached `End of Program` and produced their complete
declared native output sets. This is a semantic execution-completeness result,
not a numerical-agreement result. In particular, process status zero and file
presence do not establish coordinate identity, matched deviance, integration
stability, scientific equivalence, or mfrmr inference readiness.

The run-once candidate is consumed. No rerun, wider P2 execution, P3 execution,
evidence promotion, or public claim follows from this observation. The next
authorized step is a same-author technical review of the retained output under
the already-frozen metric budgets. Independent review remains necessary only
before evidence promotion, widening, or a public claim.

## Current decision

- `AllFourAttempted=TRUE`
- `AllFourSemanticallyComplete=TRUE`
- `CompleteNativeOutputCount=32`
- `CandidateRunOnceConsumed=TRUE`
- `RerunAuthorized=FALSE`
- `SameAuthorTechnicalReviewAuthorized=TRUE`
- `IndependentComprehensiveReviewPassed=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `WiderExecutionAuthorized=FALSE`
- `P3ExecutionAuthorized=FALSE`
- `PublicClaimAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
