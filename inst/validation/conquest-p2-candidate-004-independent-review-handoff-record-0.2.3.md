# Candidate-004 independent-review handoff for mfrmr 0.2.3

Status: `candidate_004_bounded_review_handoff_frozen_unreviewed`,
2026-08-15.

- Specification:
  `0.2.3-conquest-p2-candidate-004-independent-review-handoff-v1`
- Contract:
  `mfrmr_conquest_p2_candidate_004_independent_review_handoff_v1`
- Candidate: `mfrmr-0.2.3-conquest-p2-minimum-diagnostic-004`
- Review result: not yet opened

## Selected claim

The only claim sent to independent review is the bounded
exact-reported-decimal ConQuest comparison for candidate 004's paired RSM/PCM
q61/q121 numerical core. A passing review may make that result eligible for
internal evidence promotion. It cannot by itself authorize a public claim.

This path was chosen because all complete numerical-core denominators and the
reviewer's semantic controls have passed, while the retained identification
hold does not invalidate a narrowly described technical comparison. Solving a
global continuous-integral identification problem first would be necessary for
an inference-ready claim, but would not be proportionate to this bounded claim.

## Independence boundary

The reviewer must not have authored any candidate-004 fixture, fit,
authorization, execution, numerical review, rank review, adversarial-control
record, or this handoff. The reviewer must disclose conflicts and describe a
separate calculation implementation. Raw artifacts must be the primary
evidence; the same-author observation may be used only to locate discrepancies
after the independent results are fixed.

Code review or rerunning the repository tests alone is insufficient. A new
ConQuest run is neither required nor permitted by this handoff. If either raw
artifact root is unavailable or malformed, the correct result is `blocked`,
not a repair, rerun, changed budget, or reduced denominator.

## Primary local evidence

- `validation-results/conquest-p2-candidate-004-external-20260815-v1`
- `validation-results/conquest-p2-candidate-004-mfrmr-preflight-20260815-v1`

These roots are intentionally ignored local evidence, not distributable
package contents. Scientific acceptance is semantic and denominator-complete;
byte identity is not an acceptance criterion.

## Required review checklist

- [ ] Record reviewer identity, date, conflict disclosure, and all authorship
  and execution non-overlap attestations.
- [ ] Open both retained roots read-only; do not launch ConQuest or refit
  mfrmr.
- [ ] Compare all 288 long-format fixture rows semantically, allowing irrelevant
  numeric storage modes but no value, label, or design change.
- [ ] Independently derive and inspect all four commands and all four native
  A matrices against the intended RSM/PCM designs.
- [ ] Verify four terminal executions and all 32 required native outputs.
- [ ] Parse all 52 final parameter tokens at their exact reported decimal
  precision without inferring hidden solution intervals.
- [ ] Independently reconstruct and judge all 64 cross-engine coordinates and
  four matched-constant positive deviances under the frozen budgets.
- [ ] Independently reconstruct all 64 coordinate and four deviance q61--q121
  movements for both engines.
- [ ] Independently reconstruct and judge all 480 q121 conditional-probability
  cells and all 18 facet-ordering classifications.
- [ ] Retain all 96 EAP and 96 posterior-SD rows as typed ineligible; do not
  silently remove them from the denominator.
- [ ] Retain both mfrmr readiness holds and both nonpromotion decision rows.
- [ ] Independently exercise all seven semantic invariance or rejection
  classes; missing atomic rows must fail closed.
- [ ] Record every task as `pass`, `fail`, or `blocked`, with discrepancies and
  their consequences. No task may be omitted.

## Claims that remain outside this review

Hidden optimizer equality, EAP equivalence, posterior-SD equivalence, mfrmr
inference readiness, global marginal identification, continuous-integral
identification, GPCM/DFF coverage, the complete P2 portfolio, general software
interchangeability, and any public release claim remain unauthorized.

## Decision rule

Only an eligible independent reviewer plus `pass` on all fifteen tasks yields
`bounded_review_passed`. Any numerical or semantic discrepancy yields
`bounded_review_failed`; missing evidence or unfinished work yields
`bounded_review_incomplete`; reviewer overlap yields
`independence_not_met`. None of these outcomes authorizes a candidate rerun,
wider execution, P3, inference readiness, hidden-solution equality, scientific
equivalence, or a public claim.

## Current decision

- `ReviewerAssigned=FALSE`
- `IndependentBoundedReviewPassed=FALSE`
- `BoundedInternalEvidencePromotionEligible=FALSE`
- `CandidateRerunAuthorized=FALSE`
- `WiderExecutionAuthorized=FALSE`
- `P3ExecutionAuthorized=FALSE`
- `MfrmrInferenceReady=FALSE`
- `PublicClaimAuthorized=FALSE`
- `HiddenSolutionEqualityInferred=FALSE`
- `ScientificEquivalenceInferred=FALSE`
