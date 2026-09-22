# ConQuest P2 candidate-004 mfrmr preflight observation for mfrmr 0.2.3

Status: `candidate_004_mfrmr_preflight_passed_external_review_required`; the
complete q61--q121 RSM/PCM slice passed, so q241 was not run, 2026-08-15.

- Specification:
  `0.2.3-conquest-p2-candidate-004-mfrmr-preflight-observation-v1`
- Contract:
  `mfrmr_conquest_p2_candidate_004_mfrmr_preflight_observation_v1`
- Attempted fits: 6/8 cap
- Selected dense pair: q61--q121
- q241 attempted: no
- ConQuest processes launched: zero

## Fit-state observation

All six fits converged without warnings, returned the expected dimensions
(RSM 10; PCM 14), had finite boundary/numerical states, and retained population
variances from `0.70012` to `0.71468`, above the frozen 0.05 floor. All six
remain `InferenceReady=FALSE` solely because
`ReadinessReasonCodes=design_rank_not_evaluated`. This exact hold preserved
numerical diagnostic eligibility but did not become an inference-ready claim.

## Integration observation

| Layer | RSM coordinate / deviance | PCM coordinate / deviance | Role |
| --- | ---: | ---: | --- |
| q31--q61 | `5.04e-6` / `1.52e-5` | `8.97e-6` / `2.73e-5` | diagnostic; above `2e-6` |
| q61--q121 | `4.94e-10` / `7.44e-10` | `1.16e-9` / `1.91e-9` | governing; pass |

At the fitted q121 coordinates, stored-versus-log-centered continuous deviance
movements were `9.09e-13` for RSM and `2.27e-13` for PCM. Declared continuous
deviance error bounds were approximately `1.87e-11` for each family. Both the
`1e-7` target-agreement gate and `1e-8` declared-error gate passed.

The q31 differences are retained as evidence that the starting grid is not a
safe governing grid for this fixture. They do not fail candidate 004 because
their diagnostic role was frozen before fitting. Conversely, the dense pass
does not retroactively rescue candidate 003 or make q31 generally adequate.

## Decision

- `SixInitialFitsAttempted=TRUE`
- `Q241Attempted=FALSE`
- `DensePair1Selected=TRUE`
- `DesignRankNotEvaluatedIsInferenceReady=FALSE`
- `EligibleForNewExternalAuthorizationReview=TRUE`
- `ExternalExecutionAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `TruthRecoveryAuthorized=FALSE`
- `Candidate003Reclassified=FALSE`
- `ScientificEquivalenceInferred=FALSE`

The internal preflight is consumed and cannot be rerun. A new external output
root, a fresh semantic sentinel, a candidate-specific minimum audit, and a
separate run-once authorization remain required before ConQuest can execute.
