# ConQuest P2 candidate-004 numerical observation for mfrmr 0.2.3

Status:
`candidate_004_same_author_numeric_core_passed_independent_promotion_review_pending`,
2026-08-15.

- Specification:
  `0.2.3-conquest-p2-candidate-004-numerical-observation-v1`
- Contract:
  `mfrmr_conquest_p2_candidate_004_numerical_observation_v1`
- Review role: same-author technical adjudication, not independent evidence
  promotion

## Result

Every frozen candidate-004 numerical-core denominator was complete and passed.
No failed, ineligible, or derived row was removed.

| layer | passed / expected |
| --- | ---: |
| Native A matrices | 4 / 4 |
| Raw reported tokens | 52 / 52 |
| Cross-engine coordinates at q61 and q121 | 64 / 64 |
| Cross-engine matched-constant deviances | 4 / 4 |
| Within-engine q61--q121 coordinates | 64 / 64 |
| Within-engine q61--q121 deviances | 4 / 4 |
| q121 conditional probabilities | 480 / 480 |
| q121 facet ordering classifications | 18 / 18 |
| EAP typed-ineligible Person records | 96 / 96 |
| posterior-SD typed-ineligible Person records | 96 / 96 |
| mfrmr readiness-retention rows | 2 / 2 |
| decision-consequence rows | 2 / 2 |

## Cross-engine coordinates and deviance

The largest coordinate difference in every arm is population variance.

| arm | maximum absolute coordinate difference | limit |
| --- | ---: | ---: |
| RSM q61 | `1.3406760339673696e-6` | `1e-5` |
| RSM q121 | `1.3411705229726678e-6` | `1e-5` |
| PCM q61 | `2.2665197839666362e-6` | `1e-5` |
| PCM q121 | `2.2676791689990594e-6` | `1e-5` |

The matched-constant positive-deviance differences are
`1.0522603588469792e-7`, `1.0448206921864767e-7`,
`4.5912008772575064e-7`, and `4.5721401420451002e-7` in the same arm order;
all are below `2e-6`. The matched-constant claim is conditional on the exact
candidate data, unit response weights, Gaussian regression population model,
semantic command, and A-matrix checks enforced by the reviewer.

## Integration and output precision

All 26 ConQuest q61/q121 final-token pairs are lexically identical. Their
reported q movement is therefore zero. This is only equality of exact reported
decimals: the CSV rounding rule and hidden optimizer intervals remain unknown,
so hidden-solution equality is not inferred.

The mfrmr q61--q121 maximum coordinate movements are
`4.9448900529824868e-10` for RSM and `1.1593850324231880e-9` for PCM. The
corresponding positive-deviance movements after CSV reparse are
`7.4396666605025530e-10` and `1.9060735212406144e-9`. All four ConQuest fits
and all retained mfrmr references use the selected dense pair; every ConQuest
history contains 50 iterations.

## Conditional probabilities and ordering

The maximum absolute probability differences over each family's full
5-theta-by-4-Rater-by-3-Criterion-by-4-category grid are:

| family | maximum | location | conservative limit |
| --- | ---: | --- | ---: |
| RSM | `3.9604116575109316e-7` | theta `-0.5`, R4, C1, category 0 | `1.5001125056252111e-4` |
| PCM | `5.3952483569652543e-7` | theta `0.75`, R4, C3, category 1 | `1.5001125056252111e-4` |

All six Rater pairs and three Criterion pairs agree within each family under
the frozen `2e-5` tie band, giving 18/18 classifications.

## What this does not establish

- EAP and posterior SD remain typed-ineligible for numerical comparison because
  their posterior identity and budget were not frozen.
- All six retained mfrmr preflight fits remain non-inference-ready solely at
  `design_rank_not_evaluated`; external agreement cannot remove that hold.
- Candidate 004 covers the two RSM/PCM numerical-core rows, not missingness,
  extremes, unused categories, disconnected designs, DFF/fit decisions, GPCM,
  or the full P2/P3 portfolio.
- This same-author pass does not satisfy independent review and does not infer
  hidden-solution equality or scientific equivalence.

## Current decision

- `SameAuthorNumericCorePassed=TRUE`
- `IndependentComprehensiveReviewPassed=FALSE`
- `MfrmrInferenceReady=FALSE`
- `CompleteP2DesignPortfolioReviewed=FALSE`
- `CandidateRunOnceConsumed=TRUE`
- `RerunAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `WiderExecutionAuthorized=FALSE`
- `P3ExecutionAuthorized=FALSE`
- `PublicClaimAuthorized=FALSE`
- `HiddenSolutionEqualityInferred=FALSE`
- `ScientificEquivalenceInferred=FALSE`
