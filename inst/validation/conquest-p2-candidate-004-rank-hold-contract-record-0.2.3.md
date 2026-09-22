# Candidate-004 rank-hold adjudication contract for mfrmr 0.2.3

Status: `candidate_004_rank_hold_contract_frozen_review_not_run`, 2026-08-15.

- Specification: `0.2.3-conquest-p2-candidate-004-rank-hold-contract-v1`
- Contract: `mfrmr_conquest_p2_candidate_004_rank_hold_contract_v1`
- Scope: four retained RSM/PCM q61/q121 mfrmr fits; zero new fits

The candidate-004 preflight's `design_rank_not_evaluated` label must not be
treated as if no rank work exists. The saved fits contain several distinct
layers. This contract reviews them separately and forbids a local layer from
clearing a global hold.

| layer | admissible conclusion |
| --- | --- |
| Additive constrained adjacent-logit design | Full/deficient rank of the 9-dimensional RSM or 13-dimensional PCM additive block |
| `log_sigma2` transformation | Correct local map from the free log variance to positive variance; parameterization diagnostic only |
| Observed Person-pattern score span | Sufficient retained-point local full rank for the implemented fixed-quadrature model when its stated unit-weight and positive-probability assumptions hold |
| Retained-solution Hessian | Local information diagnostic; no uncalibrated weak-information classification |
| Global marginal model | Open unless separately proved |
| Continuous-integral model | Open unless separately connected to the fixed-quadrature result |
| Fit readiness | Remains `review/not_evaluated`, never rewritten by this audit |

The inspection requires full rank at the already-recorded tolerance ladders,
complete parameter maps, no local nullity, and the exact retained
`log_sigma2` nonlinear block. It also requires the saved fit to state that
global identification, continuous-integral identification, weak information,
and boundary implications are not classified.

No new numerical acceptance threshold is introduced. Singular values,
condition indices, Hessian eigenvalues, and gradients remain descriptive under
their original diagnostic contracts. ConQuest agreement is not an input to
the rank conclusion.

## Current decision

- `ReviewRun=FALSE`
- `NewFitAuthorized=FALSE`
- `ReadinessRewriteAuthorized=FALSE`
- `DesignRankHoldResolved=FALSE`
- `MfrmrInferenceReady=FALSE`
- `IndependentComprehensiveReviewPassed=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `PublicClaimAuthorized=FALSE`
