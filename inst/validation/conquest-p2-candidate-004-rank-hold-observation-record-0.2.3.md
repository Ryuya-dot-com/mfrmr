# Candidate-004 rank-hold observation for mfrmr 0.2.3

Status: `candidate_004_local_full_rank_global_nonlinear_identification_open`,
2026-08-15.

- Specification:
  `0.2.3-conquest-p2-candidate-004-rank-hold-observation-v1`
- Contract: `mfrmr_conquest_p2_candidate_004_rank_hold_observation_v1`
- Fits inspected: retained RSM/PCM q61/q121 only
- New fits: zero

## Layered result

| arm | additive rank | full optimizer dimension | observed-pattern score rank | fixed-q local state |
| --- | ---: | ---: | ---: | --- |
| RSM q61 | 9/9 | 10 | 10/10 | locally full-rank sufficient |
| RSM q121 | 9/9 | 10 | 10/10 | locally full-rank sufficient |
| PCM q61 | 13/13 | 14 | 14/14 | locally full-rank sufficient |
| PCM q121 | 13/13 | 14 | 14/14 | locally full-rank sufficient |

All additive ranks and observed-pattern score ranks are unchanged over their
stored three-tolerance ladders. The additive design's smallest normalized
singular value is approximately `0.5134034` and its condition index is
approximately `3.059771` in all four arms. These are descriptive diagnostics,
not post-hoc acceptance thresholds.

The one optimizer coordinate absent from the additive design is
`log_sigma2`. Its analytic and numerical parameter transformation is full rank,
the observed Person-pattern score vectors span the full 10- or 14-coordinate
fixed-quadrature model, and the retained Hessian layer has full positive rank
under its stored diagnostic ladder. Thus no local first-order null direction is
observed at either selected grid.

## Why the hold remains

The saved-fit contract explicitly classifies none of the following:

- global identification of the marginal MML model;
- identification under the continuous rather than fixed-quadrature integral;
- weak information under a prospectively calibrated rule; or
- a readiness consequence from the local rank result.

Accordingly every fit correctly remains
`EstimabilityState=not_evaluated`, `FitReadiness=review`, and
`InferenceReady=FALSE` with `design_rank_not_evaluated`. Rewriting that state
from the local diagnostics would overstate their proof scope.

This creates a claim-dependent fork. A narrowly worded exact-reported-decimal
ConQuest comparison can be independently reviewed while retaining the
non-inference-ready caveat. An inference-ready or general identification claim
requires a separate prospective global/continuous MML argument. Independent
review cannot substitute for that mathematical gap, and that gap need not be
solved merely to preserve the bounded comparison as technical evidence.

## Current decision

- `AllAdditiveDesignsFullRank=TRUE`
- `AllObservedPatternScoresFullRank=TRUE`
- `AllFixedQuadratureLocalStatesFullRank=TRUE`
- `GlobalMarginalIdentificationClassified=FALSE`
- `ContinuousIntegralIdentificationClassified=FALSE`
- `WeakInformationClassified=FALSE`
- `BoundedCrossEngineClaimCanRetainHold=TRUE`
- `InferenceReadyClaimRequiresHoldResolution=TRUE`
- `DesignRankHoldResolved=FALSE`
- `MfrmrInferenceReady=FALSE`
- `ExistingFitReadinessRewritten=FALSE`
- `IndependentComprehensiveReviewPassed=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `PublicClaimAuthorized=FALSE`
