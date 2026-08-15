# ConQuest P2 candidate-003 mfrmr preflight contract for mfrmr 0.2.3

Status: `mfrmr_preflight_contract_frozen_execution_unopened`, 2026-08-15.

- Specification: `0.2.3-conquest-p2-candidate-003-mfrmr-preflight-v1`
- Contract: `mfrmr_conquest_p2_candidate_003_mfrmr_preflight_v1`
- Candidate: `mfrmr-0.2.3-conquest-p2-minimum-diagnostic-003`
- Fit cap: four mfrmr fits; RSM and PCM at q=31 and q=61
- ConQuest process cap: zero
- Frozen output basename:
  `conquest-p2-candidate-003-mfrmr-preflight-20260815-v1`

## Frozen pass boundary

Every fit must return its expected free dimension (RSM 10; PCM 14), converged
optimizer state, `ConvergenceSeverity=pass`, `NumericalState=ready`, finite
boundary state, a finite population variance of at least 0.05, and a retained
readiness state. The q31--q61 maximum movement over every expanded reported
population/facet/step coordinate and the deviance movement must each be no more
than the already frozen P2 mfrmr threshold of `2e-6`. The complete expanded
coordinate denominators are fixed at 13 for RSM and 19 for PCM; a matching but
incomplete subset cannot pass.

`InferenceReady=TRUE` is accepted but not presumed. The single exact hold
`FitReadiness=review`, `EstimabilityState=not_evaluated`, and
`ReadinessReasonCodes=design_rank_not_evaluated` may retain diagnostic
eligibility. It remains `InferenceReady=FALSE` and cannot support uncertainty,
fit, rank, or evidence-promotion claims. Any other readiness reason is fatal.

The variance floor is an anti-collapse gate on the unit-slope latent scale, not
a recovery tolerance. Candidate 001 produced variances near `1e-12`; requiring
0.05 distinguishes an interior diagnostic target without claiming proximity to
the generating value.

## Execution boundary

The harness requires an explicit `authorize=TRUE`, the mfrmr 0.2.3 namespace
loaded from the requested source root, and a new nonexistent output directory.
That directory must have the frozen candidate-specific basename. It attempts
each arm once, retains fit objects, warnings, errors, summaries,
expanded coordinates, and q movement, and never invokes ConQuest. It uses no
file or executable hash as a scientific gate.

Even a complete pass sets only
`EligibleForNewExternalAuthorizationReview=TRUE`. It does not set
`ExternalExecutionAuthorized`, `EvidencePromotionAuthorized`,
`TruthRecoveryAuthorized`, or `ScientificEquivalenceInferred`.

## Current decision

- `MfrmrPreflightExecutionOpened=FALSE`
- `EligibleForNewExternalAuthorizationReview=FALSE`
- `ExternalExecutionAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `TruthRecoveryAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
