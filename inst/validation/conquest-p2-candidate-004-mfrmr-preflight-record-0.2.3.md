# ConQuest P2 candidate-004 mfrmr preflight contract for mfrmr 0.2.3

Status: `candidate_004_mfrmr_preflight_contract_frozen_execution_unopened`,
2026-08-15.

- Specification: `0.2.3-conquest-p2-candidate-004-mfrmr-preflight-v1`
- Contract: `mfrmr_conquest_p2_candidate_004_mfrmr_preflight_v1`
- Candidate: `mfrmr-0.2.3-conquest-p2-minimum-diagnostic-004`
- Initial fit cap: six (RSM/PCM at q31/q61/q121)
- Conditional fit cap: two (RSM/PCM at q241)
- Frozen output basename:
  `conquest-p2-candidate-004-mfrmr-preflight-20260815-v1`

## Sequential integration rule

q31 is retained as a diagnostic and cannot pass or fail the integration gate.
The complete RSM/PCM q61--q121 slice is tested first. If both families pass,
q121 is selected and q241 is not fit. If either family fails, both q241 arms
are run and the complete q121--q241 slice is tested. q241 is the hard ceiling;
failure there stops candidate 004 without node expansion, threshold changes,
seed replacement, response repair, or refitting.

For a dense pair to pass, both endpoint fits must pass the inherited dimension,
optimizer, numerical, readiness-state, and population-variance gates. The
expanded coordinate denominator is 13 for RSM and 19 for PCM. Maximum
coordinate movement and marginal-deviance movement must each be at most the
unchanged `2e-6` P2 limits for both families.

The upper fit is additionally reevaluated on the candidate data through the
qualified `[-12,12]` mode-centered split integral. This path reconstructs
probabilities from the fitted population, Rater, Criterion, and step tables;
it does not substitute generating truth. Stored-versus-continuous deviance
movement must be at most `1e-7`, and the declared numerical-plus-tail deviance
error must be at most `1e-8`.

## Fit and claim boundary

Expected free dimensions remain RSM 10 and PCM 14, with a population-variance
floor of 0.05. The exact `design_rank_not_evaluated` hold may retain numerical
diagnostic eligibility but remains `InferenceReady=FALSE`; any other readiness
hold is fatal for a selected pair.

Execution requires an explicit opt-in, the mfrmr 0.2.3 namespace loaded from
this source root, and a nonexistent directory with the frozen basename. It can
attempt each planned arm once and cannot launch ConQuest. A pass authorizes
only a new external-authorization review.

## Current decision

- `MfrmrPreflightExecutionOpened=FALSE`
- `MfrmrPreflightExecutionConsumed=FALSE`
- `Q31Governing=FALSE`
- `Q241ConditionalOnly=TRUE`
- `EligibleForNewExternalAuthorizationReview=FALSE`
- `ExternalExecutionAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `TruthRecoveryAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
