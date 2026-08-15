# ConQuest P2 candidate-003 mfrmr preflight observation for mfrmr 0.2.3

Status: `candidate_003_mfrmr_preflight_consumed_integration_unresolved`; four
mfrmr fits passed their structural/numerical gates, but both prospectively
frozen q31--q61 movement gates failed, 2026-08-15.

- Specification:
  `0.2.3-conquest-p2-candidate-003-mfrmr-preflight-observation-v1`
- Contract:
  `mfrmr_conquest_p2_candidate_003_mfrmr_preflight_observation_v1`
- Candidate: `mfrmr-0.2.3-conquest-p2-minimum-diagnostic-003`
- Retained ignored output:
  `validation-results/conquest-p2-candidate-003-mfrmr-preflight-20260815-v1`

## Observation

All four planned fits were attempted once. RSM returned the expected 10 free
parameters and PCM returned 14. Every optimizer status was converged/pass,
every boundary state was finite, no warning was retained, and the fitted
population variances were 0.632997--0.635786. Thus the near-zero variance
failure in candidate 001 was not reproduced.

All four fits remain `InferenceReady=FALSE` with the one prospectively allowed
diagnostic hold `design_rank_not_evaluated`. This is retained as a limitation,
not converted into a pass for uncertainty or rank-dependent claims.

| Family | Complete coordinates | Max absolute q31--q61 coordinate movement | Absolute deviance movement | Frozen limit for each | Result |
| --- | ---: | ---: | ---: | ---: | --- |
| RSM | 13 / 13 | 0.00000521916 | 0.00001354642 | 0.000002 | fail |
| PCM | 19 / 19 | 0.00000536115 | 0.00001291986 | 0.000002 | fail |

The largest coordinate movement in both families was population variance.
Other above-limit coordinates included Rater severities and population
coefficients. The mismatch is small in absolute terms but exceeds a rule fixed
before these outputs existed. It is therefore `integration_unresolved`, not a
pass, and it is not repaired by changing the tolerance after inspection.

## Decision

- `CandidateMfrmrPreflightConsumed=TRUE`
- `CandidateMfrmrPreflightRerunAuthorized=FALSE`
- `EligibleForNewExternalAuthorizationReview=FALSE`
- `CandidateExternalExecutionAuthorized=FALSE`
- `ThresholdChangeAuthorized=FALSE`
- `SeedSearchAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `TruthRecoveryAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`

Candidate 003 is closed before ConQuest execution. The next work is not a seed
search and not a post-hoc tolerance increase. Before generating a disjoint
candidate, the project must justify and freeze a successor integration ladder
that distinguishes a diagnostic starting grid from a governing dense-grid
convergence comparison. Candidate-003 output may motivate the question but may
not validate the successor rule.
